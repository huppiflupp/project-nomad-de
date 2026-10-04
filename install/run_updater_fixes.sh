#!/bin/bash

# Project NOMAD - One-Time Updater Fix Script
#
# Script                | Project NOMAD One-Time Updater Fix Script
# Version               | 1.0.0
# Author                | Crosstalk Solutions, LLC
# Website               | https://crosstalksolutions.com
#
# PURPOSE:
#   This is a one-time migration script. It deploys two fixes to the sidecar
#   updater that cannot be applied through the normal in-app update mechanism:
#
#   Fix 1 — Sidecar volume write access
#     Removes the :ro (read-only) flag from the sidecar's /opt/project-nomad
#     volume mount in compose.yml. The sidecar must be able to write to
#     compose.yml so it can set the correct Docker image tag when installing
#     RC or stable versions.
#
#   Fix 2 — RC-aware sidecar watcher
#     Downloads the updated sidecar Dockerfile (adds jq) and update-watcher.sh
#     (reads target_tag from the update request and applies it to compose.yml
#     before pulling images), then rebuilds and restarts the sidecar container.
#
#   NOTE: The companion fix in the admin service (system_update_service.ts,
#   which writes the target_tag into the update request) ships in the GHCR
#   image and will take effect automatically on the next normal app update.

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
SIDECAR_DIR="${NOMAD_DIR}/sidecar-updater"
COMPOSE_PROJECT_NAME="project-nomad"

SIDECAR_DOCKERFILE_URL="https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/sidecar-updater/Dockerfile"
SIDECAR_SCRIPT_URL="https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/sidecar-updater/update-watcher.sh"

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

check_confirmation() {
  echo -e "${YELLOW}#${RESET} Dies ist ein Korrekturskript für ein ganz bestimmtes Problem. Sie müssen es vermutlich nicht ausführen, es sei denn, das NOMAD-Team hat Sie ausdrücklich dazu aufgefordert."
  echo -e "${YELLOW}#${RESET} Bitte stellen Sie sicher, dass Sie vor dem Fortfahren eine Datensicherung haben."
  read -rp "Möchten Sie fortfahren? (j/N) " response
  if [[ ! "$response" =~ ^[YyJj]$ ]]; then
    echo -e "${RED}#${RESET} Abbruch. Es wurden keine Änderungen vorgenommen."
    exit 0
  fi
  echo -e "${GREEN}#${RESET} Bestätigung erhalten. Die Korrekturen werden durchgeführt ...\n"
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
    echo -e "${RED}#${RESET} Bitte stellen Sie sicher, dass Project NOMAD installiert ist, bevor Sie dieses Skript ausführen."
    exit 1
  fi
  echo -e "${GREEN}#${RESET} compose.yml unter ${COMPOSE_FILE} gefunden.\n"
}

check_sidecar_dir() {
  if [[ ! -d "$SIDECAR_DIR" ]]; then
    echo -e "${RED}#${RESET} Das Sidecar-Verzeichnis wurde unter ${SIDECAR_DIR} nicht gefunden."
    echo -e "${RED}#${RESET} Bitte stellen Sie sicher, dass Project NOMAD installiert ist, bevor Sie dieses Skript ausführen."
    exit 1
  fi
  echo -e "${GREEN}#${RESET} Sidecar-Verzeichnis unter ${SIDECAR_DIR} gefunden.\n"
}

###############################################################################
# Fix 1 — Remove :ro from sidecar volume mount
###############################################################################

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

fix_sidecar_volume_mount() {
  # Idempotent: skip if :ro is already absent from the sidecar mount line
  if ! grep -q '/opt/project-nomad:/opt/project-nomad:ro' "$COMPOSE_FILE"; then
    echo -e "${GREEN}#${RESET} Der Sidecar-Volume-Mount ist bereits beschreibbar – keine Änderung nötig.\n"
    return 0
  fi

  echo -e "${YELLOW}#${RESET} Die :ro-Einschränkung des Sidecar-Volume-Mounts in compose.yml wird entfernt ..."
  sed -i 's|/opt/project-nomad:/opt/project-nomad:ro.*|/opt/project-nomad:/opt/project-nomad # Writable access required so the updater can set the correct image tag in compose.yml|' "$COMPOSE_FILE"

  if grep -q '/opt/project-nomad:/opt/project-nomad:ro' "$COMPOSE_FILE"; then
    echo -e "${RED}#${RESET} :ro konnte nicht aus compose.yml entfernt werden. Bitte passen Sie die Datei manuell an:"
    echo -e "${WHITE_R}    - /opt/project-nomad:/opt/project-nomad:ro${RESET}  →  ${WHITE_R}- /opt/project-nomad:/opt/project-nomad${RESET}"
    exit 1
  fi

  echo -e "${GREEN}#${RESET} Der Sidecar-Volume-Mount wurde erfolgreich aktualisiert.\n"
}

###############################################################################
# Fix 2 — Download updated sidecar files and rebuild
###############################################################################

download_updated_sidecar_files() {
  echo -e "${YELLOW}#${RESET} Das aktualisierte Sidecar-Dockerfile wird heruntergeladen ..."
  if ! curl -fsSL "$SIDECAR_DOCKERFILE_URL" -o "${SIDECAR_DIR}/Dockerfile"; then
    echo -e "${RED}#${RESET} Das Sidecar-Dockerfile konnte nicht heruntergeladen werden. Prüfen Sie Ihre Netzwerkverbindung."
    exit 1
  fi
  echo -e "${GREEN}#${RESET} Sidecar-Dockerfile aktualisiert.\n"

  echo -e "${YELLOW}#${RESET} Die aktualisierte update-watcher.sh wird heruntergeladen ..."
  if ! curl -fsSL "$SIDECAR_SCRIPT_URL" -o "${SIDECAR_DIR}/update-watcher.sh"; then
    echo -e "${RED}#${RESET} update-watcher.sh konnte nicht heruntergeladen werden. Prüfen Sie Ihre Netzwerkverbindung."
    exit 1
  fi
  chmod +x "${SIDECAR_DIR}/update-watcher.sh"
  echo -e "${GREEN}#${RESET} update-watcher.sh aktualisiert.\n"
}

rebuild_sidecar() {
  echo -e "${YELLOW}#${RESET} Der Updater-Container wird neu gebaut (das kann einen Moment dauern) ..."
  if ! docker compose -p "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" build updater; then
    echo -e "${RED}#${RESET} Der Updater-Container konnte nicht neu gebaut werden. Details finden Sie in der Ausgabe oben."
    exit 1
  fi
  echo -e "${GREEN}#${RESET} Der Updater-Container wurde erfolgreich neu gebaut.\n"
}

restart_sidecar() {
  echo -e "${YELLOW}#${RESET} Vorhandene Updater-Container werden beendet und entfernt ..."

  # Stop and remove via compose first (handles the compose-tracked container)
  docker compose -p "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" stop updater >> /dev/null 2>&1 || true
  docker compose -p "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" rm -f updater >> /dev/null 2>&1 || true

  # Force-remove any stale container still holding the name (e.g. hash-prefixed remnants)
  docker rm -f nomad_updater >> /dev/null 2>&1 || true

  echo -e "${YELLOW}#${RESET} Der aktualisierte Updater-Container wird gestartet ..."
  if ! docker compose -p "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" up -d updater; then
    echo -e "${RED}#${RESET} Der Updater-Container konnte nicht gestartet werden."
    exit 1
  fi
  echo -e "${GREEN}#${RESET} Updater-Container gestartet.\n"
}

verify_sidecar_running() {
  sleep 3
  # Use exact name match to avoid false positives from hash-prefixed stale containers
  if docker ps --filter "name=^nomad_updater$" --filter "status=running" --format '{{.Names}}' | grep -qx "nomad_updater"; then
    echo -e "${GREEN}#${RESET} Der Updater-Container läuft.\n"
  else
    echo -e "${RED}#${RESET} Der Updater-Container scheint nicht zu laufen."
    echo -e "${RED}#${RESET} Seine Logs sehen Sie mit: docker logs nomad_updater"
    exit 1
  fi
}

###############################################################################
# Main
###############################################################################

echo -e "${GREEN}#########################################################################${RESET}"
echo -e "${GREEN}#${RESET}         Project NOMAD – Einmaliges Updater-Korrekturskript       ${GREEN}#${RESET}"
echo -e "${GREEN}#########################################################################${RESET}\n"

check_is_bash
check_has_sudo
check_confirmation
check_docker_running
check_compose_file
check_sidecar_dir

echo -e "${YELLOW}#${RESET} Korrektur 1 startet: Schreibzugriff auf das Sidecar-Volume ...\n"
backup_compose_file
fix_sidecar_volume_mount

echo -e "${YELLOW}#${RESET} Korrektur 2 startet: RC-fähiger Sidecar-Watcher ...\n"
download_updated_sidecar_files
rebuild_sidecar
restart_sidecar
verify_sidecar_running

echo -e "${GREEN}#########################################################################${RESET}"
echo -e "${GREEN}#${RESET} Alle Korrekturen wurden erfolgreich angewendet!"
echo -e "${GREEN}#${RESET}"
echo -e "${GREEN}#${RESET} Der Updater-Sidecar kann jetzt RC- und stabile Versionen korrekt installieren."
echo -e "${GREEN}#${RESET} Die verbleibende Korrektur (target_tag-Unterstützung im Admin-Dienst) wird"
echo -e "${GREEN}#${RESET} automatisch beim nächsten Update von NOMAD über die Oberfläche wirksam."
echo -e "${GREEN}#########################################################################${RESET}\n"
