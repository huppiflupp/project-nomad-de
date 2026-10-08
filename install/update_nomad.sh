#!/bin/bash

# Project NOMAD Update Script

###################################################################################################################################################################################################

# Script                | Project NOMAD Update Script
# Version               | 1.0.1
# Author                | Crosstalk Solutions, LLC
# Website               | https://crosstalksolutions.com

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                           Color Codes                                                                                           #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

RESET='\033[0m'
YELLOW='\033[1;33m'
WHITE_R='\033[39m' # Same as GRAY_R for terminals with white background.
GRAY_R='\033[39m'
RED='\033[1;31m' # Light Red.
GREEN='\033[1;32m' # Light Green.

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                           Functions                                                                                             #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

header_red() {
  if [[ "${script_option_debug}" != 'true' ]]; then clear; clear; fi
  echo -e "${RED}#########################################################################${RESET}\\n"
}

check_has_sudo() {
  if sudo -n true 2>/dev/null; then
    echo -e "${GREEN}#${RESET} Der Benutzer hat sudo-Rechte.\\n"
  else
    echo "Der Benutzer hat keine sudo-Rechte"
    header_red
    echo -e "${RED}#${RESET} Dieses Skript benötigt sudo-Rechte. Bitte führen Sie es mit sudo aus.\\n"
    echo -e "${RED}#${RESET} Zum Beispiel: sudo bash $(basename "$0")"
    exit 1
  fi
}

check_is_bash() {
  if [[ -z "$BASH_VERSION" ]]; then
    header_red
    echo -e "${RED}#${RESET} Dieses Skript benötigt bash. Bitte führen Sie es mit bash aus.\\n"
    echo -e "${RED}#${RESET} Zum Beispiel: bash $(basename "$0")"
    exit 1
  fi
    echo -e "${GREEN}#${RESET} Dieses Skript läuft in bash.\\n"
}

check_is_debian_based() {
  if [[ ! -f /etc/debian_version ]]; then
    header_red
    echo -e "${RED}#${RESET} Dieses Skript ist nur für Debian-basierte Systeme gedacht.\\n"
    echo -e "${RED}#${RESET} Bitte führen Sie es auf einem Debian-basierten System erneut aus."
    exit 1
  fi
    echo -e "${GREEN}#${RESET} Dieses Skript läuft auf einem Debian-basierten System.\\n"
}

get_update_confirmation(){
  read -p "Dieses Skript aktualisiert Project NOMAD und seine Abhängigkeiten auf Ihrem Rechner. Datenverlust ist nicht zu erwarten, dennoch sollten Sie vor dem Fortfahren immer eine Datensicherung anlegen. Möchten Sie wirklich fortfahren? (j/n): " choice
  case "$choice" in
    y|Y|j|J )
      echo -e "${GREEN}#${RESET} Sie haben sich für die Fortsetzung des Updates entschieden."
      ;;
    n|N )
      echo -e "${RED}#${RESET} Sie haben sich gegen die Fortsetzung des Updates entschieden."
      exit 0
      ;;
    * )
      echo "Ungültige Eingabe"
      echo "Sie haben sich gegen die Fortsetzung des Updates entschieden."
      exit 0
      ;;
  esac
}

ensure_docker_installed_and_running() {
  if ! command -v docker &> /dev/null; then
    echo -e "${RED}#${RESET} Docker ist nicht installiert. Das ist unerwartet, da Project NOMAD Docker benötigt. Wollten Sie vielleicht das Installationsskript statt des Update-Skripts verwenden?"
    exit 1
  fi

  if ! systemctl is-active --quiet docker; then
    echo -e "${RED}#${RESET} Docker läuft nicht. Es wird versucht, Docker zu starten ..."
    sudo systemctl start docker
    if ! systemctl is-active --quiet docker; then
      echo -e "${RED}#${RESET} Docker konnte nicht gestartet werden. Bitte starten Sie Docker und versuchen Sie es erneut."
      exit 1
    fi
  fi
}

check_docker_compose() {
  # Check if 'docker compose' (v2 plugin) is available
  if ! docker compose version &>/dev/null; then
    echo -e "${RED}#${RESET} Docker Compose v2 ist nicht installiert oder nicht als Docker-Plugin verfügbar."
    echo -e "${YELLOW}#${RESET} Dieses Skript benötigt „docker compose“ (v2), nicht „docker-compose“ (v1)."
    echo -e "${YELLOW}#${RESET} Eine Anleitung zur Installation von Docker Compose v2 finden Sie in der Docker-Dokumentation unter https://docs.docker.com/compose/install/."
    exit 1
  fi
}

ensure_docker_compose_file_exists() {
  if [ ! -f "/opt/project-nomad/compose.yml" ]; then
    echo -e "${RED}#${RESET} Die Datei compose.yml wurde nicht gefunden. Bitte stellen Sie sicher, dass sie unter /opt/project-nomad/compose.yml vorhanden ist."
    exit 1
  fi
}

force_recreate() {
  echo -e "${YELLOW}#${RESET} Die neuesten Docker-Images werden geladen ..."
  if ! docker compose -p project-nomad -f /opt/project-nomad/compose.yml pull; then
    echo -e "${RED}#${RESET} Die neuesten Docker-Images konnten nicht geladen werden. Bitte prüfen Sie Ihre Netzwerkverbindung und den Status der Docker-Registry und versuchen Sie es dann erneut."
    exit 1
  fi
  
  echo -e "${YELLOW}#${RESET} Die Container werden neu erstellt ..."
  if ! docker compose -p project-nomad -f /opt/project-nomad/compose.yml up -d --force-recreate; then
    echo -e "${RED}#${RESET} Die Container konnten nicht neu erstellt werden. Weitere Details finden Sie in den Docker-Logs."
    exit 1
  fi
}

get_local_ip() {
  local_ip_address=$(hostname -I | awk '{print $1}')
  if [[ -z "$local_ip_address" ]]; then
    echo -e "${RED}#${RESET} Die lokale IP-Adresse konnte nicht ermittelt werden. Bitte prüfen Sie Ihre Netzwerkkonfiguration."
    # Don't exit if we can't determine the local IP address, it's not critical for the installation
  fi
}

success_message() {
  echo -e "${GREEN}#${RESET} Das Update von Project NOMAD wurde erfolgreich abgeschlossen!\\n"
  echo -e "${GREEN}#${RESET} Die Installationsdateien befinden sich unter /opt/project-nomad\\n\n"
  echo -e "${GREEN}#${RESET} Die Kommandozentrale von Project NOMAD sollte bei jedem Neustart Ihres Geräts automatisch starten. Falls Sie sie manuell starten müssen, führen Sie Folgendes aus: ${WHITE_R}${nomad_dir}/start_nomad.sh${RESET}\\n"
  echo -e "${GREEN}#${RESET} Sie erreichen die Verwaltungsoberfläche jetzt unter http://localhost:8080 oder http://${local_ip_address}:8080\\n"
  echo -e "${GREEN}#${RESET} Vielen Dank, dass Sie Project NOMAD unterstützen!\\n"
}

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                           Main Script                                                                                           #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

# Pre-flight checks
check_is_debian_based
check_is_bash
check_has_sudo

# Main update
get_update_confirmation
ensure_docker_installed_and_running
check_docker_compose
ensure_docker_compose_file_exists
force_recreate
get_local_ip
success_message
