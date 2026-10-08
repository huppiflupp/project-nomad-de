#!/bin/bash

# Project NOMAD Uninstall Script

###################################################################################################################################################################################################

# Script                | Project NOMAD Uninstall Script
# Version               | 1.0.0
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
#                                                                                  Constants & Variables                                                                                          #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

NOMAD_DIR="/opt/project-nomad"
MANAGEMENT_COMPOSE_FILE="${NOMAD_DIR}/compose.yml"

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                     Functions                                                                                                   #
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

check_current_directory(){
  if [ "$(pwd)" == "${NOMAD_DIR}" ]; then
    echo "Bitte führen Sie dieses Skript in einem anderen Verzeichnis als ${NOMAD_DIR} aus."
    exit 1
  fi
}

ensure_management_compose_file_exists(){
  if [ ! -f "${MANAGEMENT_COMPOSE_FILE}" ]; then
    echo "Die Docker-Compose-Datei der Verwaltung wurde unter ${MANAGEMENT_COMPOSE_FILE} nicht gefunden. Möglicherweise gibt es ein Problem mit Ihrer Project-NOMAD-Installation."
    exit 1
  fi
}

get_uninstall_confirmation(){
  read -p "Dieses Skript entfernt ALLE Project-NOMAD-Dateien und -Container. DAS LÄSST SICH NICHT RÜCKGÄNGIG MACHEN. Möchten Sie wirklich fortfahren? (j/n): " choice
  case "$choice" in
    y|Y|j|J )
      echo -e "Sie haben sich für die Fortsetzung der Deinstallation entschieden."
      ;;
    n|N )
      echo -e "Sie haben sich gegen die Fortsetzung der Deinstallation entschieden."
      exit 0
      ;;
    * )
      echo "Ungültige Eingabe"
      echo "Sie haben sich gegen die Fortsetzung der Deinstallation entschieden."
      exit 0
      ;;
  esac
}

ensure_docker_installed() {
    if ! command -v docker &> /dev/null; then
        echo "Docker wurde nicht gefunden. Möglicherweise gibt es ein Problem mit Ihrer Docker-Installation."
        exit 1
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

storage_cleanup() {
  read -p "Möchten Sie das Project-NOMAD-Speicherverzeichnis (${NOMAD_DIR}) löschen? Das ist sinnvoll, wenn Sie komplett neu installieren möchten. Dabei werden ALLE gespeicherten NOMAD-Daten DAUERHAFT GELÖSCHT; das lässt sich nicht rückgängig machen! (j/N): " delete_dir_choice
  case "$delete_dir_choice" in
      y|Y|j|J )
          echo "Project-NOMAD-Dateien werden entfernt ..."
          if rm -rf "${NOMAD_DIR}"; then
              echo "Project-NOMAD-Dateien wurden entfernt."
          else
              echo "Warnung: ${NOMAD_DIR} konnte nicht vollständig entfernt werden. Möglicherweise müssen Sie es manuell entfernen."
          fi
          ;;
      * )
          echo "${NOMAD_DIR} wird nicht entfernt."
          ;;
  esac
}

uninstall_nomad() {
    echo "Die Verwaltungscontainer von Project NOMAD werden beendet und entfernt ..."
    docker compose -p project-nomad -f "${MANAGEMENT_COMPOSE_FILE}" down
    echo "Den Verwaltungscontainern wird etwas Zeit zum Beenden gegeben ..."
    sleep 5


    # Stop and remove all containers where name starts with "nomad_"
    echo "Alle App-Container von Project NOMAD werden beendet und entfernt ..."
    docker ps -a --filter "name=^nomad_" --format "{{.Names}}" | xargs -r docker rm -f
    echo "Den App-Containern wird etwas Zeit zum Beenden gegeben ..."
    sleep 5

    echo "Die Container sollten jetzt beendet sein."

    # Remove the shared Docker network (may still exist if app containers were using it during compose down)
    echo "Das Netzwerk project-nomad_default wird entfernt, falls vorhanden ..."
    docker network rm project-nomad_default 2>/dev/null && echo "Netzwerk entfernt." || echo "Netzwerk bereits entfernt oder nicht gefunden."

    # Remove the shared update volume
    echo "Das Volume project-nomad_nomad-update-shared wird entfernt, falls vorhanden ..."
    docker volume rm project-nomad_nomad-update-shared 2>/dev/null && echo "Volume entfernt." || echo "Volume bereits entfernt oder nicht gefunden."

    # Prompt user for storage cleanup and handle it if so
    storage_cleanup

    echo "Project NOMAD wurde deinstalliert. Wir hoffen, Sie bald wiederzusehen!"
}

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                       Main                                                                                                      #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################
check_has_sudo
check_current_directory
ensure_management_compose_file_exists
ensure_docker_installed
check_docker_compose
get_uninstall_confirmation
uninstall_nomad