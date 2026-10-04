#!/bin/bash

# Project NOMAD Update Sidecar - Polls for update requests and executes them

SHARED_DIR="/shared"
REQUEST_FILE="${SHARED_DIR}/update-request"
STATUS_FILE="${SHARED_DIR}/update-status"
LOG_FILE="${SHARED_DIR}/update-log"
COMPOSE_FILE="/opt/project-nomad/compose.yml"
COMPOSE_PROJECT_NAME="project-nomad"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

write_status() {
    local stage="$1"
    local progress="$2"
    local message="$3"
    
    cat > "$STATUS_FILE" <<EOF
{
  "stage": "$stage",
  "progress": $progress,
  "message": "$message",
  "timestamp": "$(date -Iseconds)"
}
EOF
}

perform_update() {
    local target_tag="$1"

    log "Update-Anfrage erhalten – Systemupdate startet (Ziel-Tag: ${target_tag})"

    # Clear old logs
    > "$LOG_FILE"

    # Stage 1: Starting
    write_status "starting" 0 "System update initiated"
    log "Systemupdate gestartet"
    sleep 1

    # Apply target image tag to compose.yml before pulling
    log "Image-Tag „${target_tag}“ wird in compose.yml gesetzt ..."
    if sed -i "s|\(image: ghcr\.io/huppiflupp/project-nomad-de\):.*|\1:${target_tag}|" "$COMPOSE_FILE" 2>> "$LOG_FILE"; then
        log "Der Admin-Image-Tag in compose.yml wurde erfolgreich auf „${target_tag}“ gesetzt"
    else
        log "FEHLER: Der Image-Tag in compose.yml konnte nicht aktualisiert werden"
        write_status "error" 0 "Failed to update compose.yml image tag - check logs"
        return 1
    fi

    # Stage 2: Pulling images
    write_status "pulling" 20 "Pulling latest Docker images..."
    log "Die neuesten Docker-Images werden geladen ..."

    # Snapshot the images backing our managed repos before the pull supersedes
    # them, so the post-update cleanup can drop only NOMAD's own dangling layers.
    PRE_UPDATE_IMAGE_IDS=$(snapshot_managed_image_ids)

    if docker compose -p "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" pull >> "$LOG_FILE" 2>&1; then
        log "Die neuesten Images wurden erfolgreich geladen"
        write_status "pulled" 60 "Images pulled successfully"
    else
        log "FEHLER: Die Images konnten nicht geladen werden"
        write_status "error" 0 "Failed to pull Docker images - check logs"
        return 1
    fi
    
    sleep 2
    
    # Stage 3: Recreating containers individually (excluding updater)
    write_status "recreating" 65 "Recreating containers individually..."
    log "Container werden einzeln neu erstellt (ohne Updater) ..."
    
    # List of services to update (excluding updater)
    SERVICES_TO_UPDATE="admin mysql redis dozzle"
    
    local current_progress=65
    local progress_per_service=8  # (95 - 65) / 4 services ≈ 8% per service
    
    for service in $SERVICES_TO_UPDATE; do
        log "Dienst wird aktualisiert: $service"
        write_status "recreating" $current_progress "Recreating $service..."
        
        # Stop the service
        log "  $service wird beendet ..."
        docker compose -p "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" stop "$service" >> "$LOG_FILE" 2>&1 || log "  WARNUNG: $service konnte nicht beendet werden"
        
        # Remove the container
        log "  Alter Container von $service wird entfernt ..."
        docker compose -p "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" rm -f "$service" >> "$LOG_FILE" 2>&1 || log "  WARNUNG: $service konnte nicht entfernt werden"
        
        # Recreate and start with new image
        log "  Neuer Container von $service wird gestartet ..."
        if docker compose -p "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" up -d --no-deps "$service" >> "$LOG_FILE" 2>&1; then
            log "  ✓ $service erfolgreich neu erstellt"
        else
            log "  FEHLER: $service konnte nicht neu erstellt werden"
            write_status "error" $current_progress "Failed to recreate $service - check logs"
            return 1
        fi
        
        current_progress=$((current_progress + progress_per_service))
    done
    
    log "Alle Container wurden erfolgreich neu erstellt"

    # Stage 4: Reclaim disk from superseded images (best-effort; never fails the update)
    prune_old_images

    write_status "complete" 100 "System update completed successfully"
    log "Systemupdate erfolgreich abgeschlossen"

    return 0
}

# Record the full image IDs currently backing our compose-managed repositories
# BEFORE we pull. After the pull, the old digests of moving tags (e.g. :latest)
# become dangling <none> images; knowing their IDs lets the cleanup target only
# NOMAD's own images and leave every other app's dangling images on this shared
# host's Docker daemon alone. --no-trunc so IDs match `docker images` output later.
snapshot_managed_image_ids() {
    local managed_repos
    managed_repos=$(docker compose -p "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" config --images 2>/dev/null \
        | sed 's/[:@].*$//' | sort -u)
    [ -z "$managed_repos" ] && return 0
    docker images --no-trunc --format '{{.Repository}} {{.ID}}' | while IFS=' ' read -r repo id; do
        echo "$managed_repos" | grep -qxF "$repo" && echo "$id"
    done | sort -u
}

# Reclaim disk left behind by updates. Every update pulls new image versions but
# never removed the old ones, so /var/lib/containerd grows unbounded across
# releases (observed 50+ GB of orphaned layers on long-running installs; issue
# #858). This runs only after a confirmed-successful recreate.
#
# Deliberately conservative for an offline-first appliance: we do NOT run
# `docker system/image prune -a`, which would delete images for installed-but-
# stopped Supply Depot / curated services and force a re-pull that fails with no
# internet. Instead we (1) drop dangling layers and (2) remove only superseded
# tags of the core services this updater manages (the images in compose.yml),
# keeping the refs now in use. Optional/offline images are never touched.
prune_old_images() {
    write_status "pruning" 97 "Reclaiming disk from old images..."
    log "Überholte Docker-Images werden entfernt, um Speicherplatz freizugeben ..."

    # 1. Drop the prior image layers this update left dangling — but ONLY ours.
    #    We snapshotted the managed repos' image IDs before pulling; any of those
    #    IDs now untagged (<none>) is a superseded NOMAD image, safe to remove.
    #    We deliberately do NOT run `docker image prune`, which would also delete
    #    unrelated dangling images from other apps sharing this host's daemon.
    if [ -n "$PRE_UPDATE_IMAGE_IDS" ]; then
        local dangling_now
        dangling_now=$(docker images --no-trunc --filter 'dangling=true' --quiet | sort -u)
        while read -r id; do
            [ -z "$id" ] && continue
            echo "$dangling_now" | grep -qxF "$id" || continue   # keep unless now dangling
            log "  Überholte verwaiste Schicht wird entfernt: $id"
            # No -f: docker refuses if a container still references it, so
            # anything unexpectedly in use is safely skipped.
            docker rmi "$id" >> "$LOG_FILE" 2>&1 || log "  $id übersprungen (noch in Benutzung oder Entfernen fehlgeschlagen)"
        done <<< "$PRE_UPDATE_IMAGE_IDS"
    else
        log "  Kein Image-Snapshot vor dem Update vorhanden; Bereinigung verwaister Schichten wird übersprungen"
    fi

    # 2. Superseded tags of compose-managed repositories only.
    local in_use_raw in_use managed_repos
    in_use_raw=$(docker compose -p "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" config --images 2>/dev/null)
    # `compose config --images` emits an untagged repo as a bare name, but
    # `docker images` always reports `repo:tag`. Normalise bare refs to `:latest`
    # so the in-use check below matches (otherwise the current image, e.g. the
    # updater's own, looks superseded). Digest refs are left as-is.
    in_use=$(echo "$in_use_raw" | while read -r r; do
        [ -z "$r" ] && continue
        case "${r##*/}" in
            *:*|*@*) echo "$r" ;;
            *) echo "$r:latest" ;;
        esac
    done | sort -u)
    if [ -z "$in_use" ]; then
        log "  Die verwendeten Images konnten aus compose nicht ermittelt werden; gezielte Bereinigung übersprungen"
        log "Image-Bereinigung abgeschlossen"
        return 0
    fi

    # Repositories we manage = the in-use refs with the tag/digest stripped off.
    managed_repos=$(echo "$in_use" | sed 's/[:@].*$//' | sort -u)

    while IFS=' ' read -r _img_id img_ref; do
        [ -z "$img_ref" ] && continue
        local repo="${img_ref%%:*}"
        # Only touch repositories this updater manages.
        echo "$managed_repos" | grep -qxF "$repo" || continue
        # Keep any ref that is still in use by the current stack.
        echo "$in_use" | grep -qxF "$img_ref" && continue
        log "  Überholtes Image wird entfernt: $img_ref"
        # No -f: docker refuses to remove an image still referenced by a
        # container, which keeps us safe against removing anything in use.
        docker rmi "$img_ref" >> "$LOG_FILE" 2>&1 || log "  $img_ref übersprungen (noch in Benutzung oder Entfernen fehlgeschlagen)"
    done < <(docker images --format '{{.ID}} {{.Repository}}:{{.Tag}}' | grep -v '<none>')

    log "Image-Bereinigung abgeschlossen"
}

cleanup() {
    log "Update-Sidecar wird beendet"
    exit 0
}

trap cleanup SIGTERM SIGINT

# Main watch loop
log "Update-Sidecar gestartet – wartet auf Update-Anfragen"
write_status "idle" 0 "Ready for update requests"

while true; do
    # Check if an update request file exists
    if [ -f "$REQUEST_FILE" ]; then
        log "Update-Anfragedatei gefunden"
        
        # Read request details
        REQUEST_DATA=$(cat "$REQUEST_FILE" 2>/dev/null || echo "{}")
        log "Anfragedaten: $REQUEST_DATA"

        # Extract target tag from request (defaults to "latest" if not provided)
        TARGET_TAG=$(echo "$REQUEST_DATA" | jq -r '.target_tag // "latest"')
        log "Ziel-Image-Tag: ${TARGET_TAG}"

        # Remove the request file to prevent re-processing
        rm -f "$REQUEST_FILE"

        if perform_update "$TARGET_TAG"; then
            log "Update erfolgreich abgeschlossen"
        else
            log "Update fehlgeschlagen – Details siehe Logs"
        fi
        
        sleep 5
        write_status "idle" 0 "Ready for update requests"
    fi
    
    # Sleep before next check (1 second polling)
    sleep 1
done
