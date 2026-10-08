#!/bin/bash

# Project NOMAD — Disk Collector Migration Script
#
# Script                | Project NOMAD Disk Collector Migration Script
# Version               | 1.0.0
# Author                | Crosstalk Solutions, LLC
# Website               | https://crosstalksolutions.com
#
# PURPOSE:
#   One-time migration from the host-based disk info collector to the
#   disk-collector Docker sidecar. The old approach used a nohup background
#   process that wrote to /tmp/nomad-disk-info.json, which was bind-mounted
#   into the admin container. This broke on host reboots because /tmp is
#   cleared and Docker would create a directory at the mount point instead of a file.
#
#   The new approach uses a disk-collector sidecar container that reads host
#   disk info via the /:/host:ro,rslave bind-mount pattern (same pattern as Prometheus
#   node-exporter, and no SYS_ADMIN or privileged capabilities required) and writes directly to
#   /opt/project-nomad/storage/nomad-disk-info.json, which the admin container
#   already reads via its existing storage bind-mount. Thus, no admin image update
#   or new volume mounts required.

###############################################################################
# Color Codes
###############################################################################

RESET='\033[0m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
GREEN='\033[1;32m'
WHITE_R='\033[39m'

###############################################################################
# Constants
###############################################################################

NOMAD_DIR="/opt/project-nomad"
COMPOSE_FILE="${NOMAD_DIR}/compose.yml"
COMPOSE_PROJECT_NAME="project-nomad"

###############################################################################
# Pre-flight Checks
###############################################################################

check_is_bash() {
  if [[ -z "$BASH_VERSION" ]]; then
    echo -e "${RED}#${RESET} Dieses Skript muss mit bash ausgeführt werden."
    echo -e "${RED}#${RESET} Beispiel: bash $(basename "$0")"
    exit 1
  fi
  echo -e "${GREEN}#${RESET} Läuft in bash.\n"
}

check_has_sudo() {
  if sudo -n true 2>/dev/null; then
    echo -e "${GREEN}#${RESET} sudo-Rechte bestätigt.\n"
  else
    echo -e "${RED}#${RESET} Dieses Skript benötigt sudo-Rechte."
    echo -e "${RED}#${RESET} Beispiel: sudo bash $(basename "$0")"
    exit 1
  fi
}

check_confirmation() {
  echo -e "${YELLOW}#${RESET} Dieses Skript migriert Ihre Project-NOMAD-Installation vom"
  echo -e "${YELLOW}#${RESET} hostbasierten Datenträger-Informationssammler auf den neuen disk-collector-Sidecar."
  echo -e "${YELLOW}#${RESET} Es ändert compose.yml und startet den gesamten Compose-Stack neu,"
  echo -e "${YELLOW}#${RESET} um den alten /tmp-Bind-Mount zu entfernen und den disk-collector-Sidecar zu starten."
  echo -e "${YELLOW}#${RESET} Bitte stellen Sie sicher, dass Sie vor dem Fortfahren eine Datensicherung haben.\n"

  echo -e "${RED}#${RESET} STOPP: Wenn Sie Ihre compose.yml oder die Speicherkonfiguration von NOMAD angepasst haben (ungewöhnlich), nehmen Sie diese Änderungen bitte manuell vor, statt dieses Skript zu verwenden!\n"
  read -rp "Möchten Sie fortfahren? (j/N) " response
  if [[ ! "$response" =~ ^[YyJj]$ ]]; then
    echo -e "${RED}#${RESET} Abbruch. Es wurden keine Änderungen vorgenommen."
    exit 0
  fi
  echo -e "${GREEN}#${RESET} Bestätigung erhalten. Die Migration wird durchgeführt ...\n"
}

check_docker_running() {
  if ! command -v docker &>/dev/null; then
    echo -e "${RED}#${RESET} Docker ist nicht installiert. Es kann nicht fortgefahren werden."
    exit 1
  fi
  if ! systemctl is-active --quiet docker; then
    echo -e "${RED}#${RESET} Docker läuft nicht. Bitte starten Sie Docker und versuchen Sie es erneut."
    exit 1
  fi
  echo -e "${GREEN}#${RESET} Docker läuft.\n"
}

check_compose_file() {
  if [[ ! -f "$COMPOSE_FILE" ]]; then
    echo -e "${RED}#${RESET} compose.yml wurde unter ${COMPOSE_FILE} nicht gefunden."
    echo -e "${RED}#${RESET} Project NOMAD scheint nicht installiert zu sein oder compose.yml fehlt."
    exit 1
  fi
  echo -e "${GREEN}#${RESET} compose.yml unter ${COMPOSE_FILE} gefunden.\n"
}

# Step 1: Stop old host process
stop_old_host_process() {
  local pid_file="${NOMAD_DIR}/nomad-collect-disk-info.pid"

  if [[ -f "$pid_file" ]]; then
    echo -e "${YELLOW}#${RESET} Der alte Hintergrundprozess collect-disk-info wird beendet ..."
    local pid
    pid=$(cat "$pid_file")
    if kill "$pid" 2>/dev/null; then
      echo -e "${GREEN}#${RESET} Prozess ${pid} beendet.\n"
    else
      echo -e "${YELLOW}#${RESET} Prozess ${pid} lief nicht (bereits beendet).\n"
    fi
    rm -f "$pid_file"
  else
    echo -e "${GREEN}#${RESET} Keine alte PID-Datei von collect-disk-info gefunden – nichts zu beenden.\n"
  fi
}

# Step 2: Backup compose.yml
backup_compose_file() {
  local backup="${COMPOSE_FILE}.bak.$(date +%Y%m%d%H%M%S)"
  echo -e "${YELLOW}#${RESET} compose.yml wird nach ${backup} gesichert ..."
  if cp "$COMPOSE_FILE" "$backup"; then
    echo -e "${GREEN}#${RESET} Sicherung unter ${backup} angelegt.\n"
  else
    echo -e "${RED}#${RESET} Die Sicherung konnte nicht angelegt werden. Abbruch."
    exit 1
  fi
}

# Step 3: Remove old bind-mount from admin volumes
remove_old_bind_mount() {
  if ! grep -q 'nomad-disk-info\.json' "$COMPOSE_FILE"; then
    echo -e "${GREEN}#${RESET} Der alte Bind-Mount /tmp/nomad-disk-info.json wurde nicht gefunden – bereits entfernt.\n"
    return 0
  fi

  echo -e "${YELLOW}#${RESET} Der alte Bind-Mount /tmp/nomad-disk-info.json wird aus den Admin-Volumes entfernt ..."
  sed -i '/\/tmp\/nomad-disk-info\.json:\/app\/storage\/nomad-disk-info\.json/d' "$COMPOSE_FILE"

  if grep -q 'nomad-disk-info\.json' "$COMPOSE_FILE"; then
    echo -e "${RED}#${RESET} Der alte Bind-Mount konnte nicht aus compose.yml entfernt werden. Bitte entfernen Sie ihn manuell:"
    echo -e "${WHITE_R}      - /tmp/nomad-disk-info.json:/app/storage/nomad-disk-info.json${RESET}"
    exit 1
  fi

  echo -e "${GREEN}#${RESET} Alter Bind-Mount entfernt.\n"
}

# Step 4: Add disk-collector service block
add_disk_collector_service() {
  if grep -q 'disk-collector:' "$COMPOSE_FILE"; then
    echo -e "${GREEN}#${RESET} Der Dienst disk-collector ist in compose.yml bereits vorhanden – wird übersprungen.\n"
    return 0
  fi

  echo -e "${YELLOW}#${RESET} Der Dienst disk-collector wird zu compose.yml hinzugefügt ..."

  # Insert the disk-collector service block before the top-level `volumes:` key
  awk '/^volumes:/{
    print "  disk-collector:"
    print "    image: ghcr.io/huppiflupp/project-nomad-de-disk-collector:latest"
    print "    pull_policy: always"
    print "    container_name: nomad_disk_collector"
    print "    restart: unless-stopped"
    print "    volumes:"
    print "      - /:/host:ro,rslave  # Read-only view of host FS with rslave propagation so /sys and /proc submounts are visible"
    print "      - /opt/project-nomad/storage:/storage  # Shared storage dir — disk info written here is read by the admin container"
    print ""
  }
  {print}' "$COMPOSE_FILE" > "${COMPOSE_FILE}.tmp" && mv "${COMPOSE_FILE}.tmp" "$COMPOSE_FILE"

  if ! grep -q 'disk-collector:' "$COMPOSE_FILE"; then
    echo -e "${RED}#${RESET} Der Dienst disk-collector konnte nicht hinzugefügt werden. Bitte fügen Sie ihn manuell vor dem Schlüssel volumes: auf oberster Ebene ein."
    exit 1
  fi

  echo -e "${GREEN}#${RESET} Dienst disk-collector hinzugefügt.\n"
}

# Step 5 — Pull new image and restart the full stack
# This will re-create the admin container and drop the old /tmp bind, and
# also starts the new disk-collector sidecar we just added to compose.yml
restart_stack() {
  echo -e "${YELLOW}#${RESET} Die neuesten Images werden geladen (einschließlich disk-collector) ..."
  if ! docker compose -p "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" pull; then
    echo -e "${RED}#${RESET} Die Images konnten nicht geladen werden. Prüfen Sie Ihre Netzwerkverbindung."
    exit 1
  fi
  echo -e "${GREEN}#${RESET} Images geladen.\n"

  echo -e "${YELLOW}#${RESET} Der Stack wird neu gestartet ..."
  if ! docker compose -p "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" up -d; then
    echo -e "${RED}#${RESET} Der Stack konnte nicht gestartet werden."
    exit 1
  fi
  echo -e "${GREEN}#${RESET} Stack neu gestartet.\n"
}

# Step 6: Verify
verify_disk_collector_running() {
  sleep 3
  if docker ps --filter "name=^nomad_disk_collector$" --filter "status=running" --format '{{.Names}}' | grep -qx "nomad_disk_collector"; then
    echo -e "${GREEN}#${RESET} Der Container disk-collector läuft.\n"
  else
    echo -e "${RED}#${RESET} Der Container disk-collector scheint nicht zu laufen."
    echo -e "${RED}#${RESET} Seine Logs sehen Sie mit: docker logs nomad_disk_collector"
    exit 1
  fi
}

# Main
echo -e "${GREEN}#########################################################################${RESET}"
echo -e "${GREEN}#${RESET}      Project NOMAD – Migrationsskript Disk-Collector            ${GREEN}#${RESET}"
echo -e "${GREEN}#########################################################################${RESET}\n"

check_is_bash
check_has_sudo
check_confirmation
check_docker_running
check_compose_file

echo -e "${YELLOW}#${RESET} Schritt 1: Alter Host-Prozess wird beendet ...\n"
stop_old_host_process

echo -e "${YELLOW}#${RESET} Schritt 2: compose.yml wird gesichert ...\n"
backup_compose_file

echo -e "${YELLOW}#${RESET} Schritt 3: Alter Bind-Mount wird entfernt ...\n"
remove_old_bind_mount

echo -e "${YELLOW}#${RESET} Schritt 4: Dienst disk-collector wird hinzugefügt ...\n"
add_disk_collector_service

echo -e "${YELLOW}#${RESET} Schritt 5: Images werden geladen und der Stack neu gestartet ...\n"
restart_stack

echo -e "${YELLOW}#${RESET} Schritt 6: Es wird geprüft, ob disk-collector läuft ...\n"
verify_disk_collector_running

echo -e "${GREEN}#########################################################################${RESET}"
echo -e "${GREEN}#${RESET} Die Migration wurde erfolgreich abgeschlossen!"
echo -e "${GREEN}#${RESET}"
echo -e "${GREEN}#${RESET} Der disk-collector-Sidecar läuft jetzt und aktualisiert die Datenträgerinformationen"
echo -e "${GREEN}#${RESET} alle 2 Minuten. Der Endpunkt /api/system/info liefert Datenträgerdaten"
echo -e "${GREEN}#${RESET} nach dem ersten Schreibvorgang des Collectors (ca. 5 Sekunden nach dem Start)."
echo -e "${GREEN}#${RESET}"
echo -e "${GREEN}#########################################################################${RESET}\n"
