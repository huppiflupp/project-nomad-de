#!/bin/bash

# Project NOMAD Installation Script

###################################################################################################################################################################################################

# Script                | Project NOMAD Installation Script
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

WHIPTAIL_TITLE="Project NOMAD Installation"
NOMAD_DIR="/opt/project-nomad"
MANAGEMENT_COMPOSE_FILE_URL="https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/management_compose.yaml"
START_SCRIPT_URL="https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/start_nomad.sh"
STOP_SCRIPT_URL="https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/stop_nomad.sh"
UPDATE_SCRIPT_URL="https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/update_nomad.sh"
script_option_debug='true'
accepted_terms='false'
local_ip_address=''

###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                           Functions                                                                                             #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################

header() {
  if [[ "${script_option_debug}" != 'true' ]]; then clear; clear; fi
  echo -e "${GREEN}#########################################################################${RESET}\\n"
}

header_red() {
  if [[ "${script_option_debug}" != 'true' ]]; then clear; clear; fi
  echo -e "${RED}#########################################################################${RESET}\\n"
}

banner() {
  echo ""
  echo -e "${GREEN}"
  cat <<'NOMAD_ART'
                             P R O J E C T
                    _   _  ___  __  __    _    ____
                   | \ | |/ _ \|  \/  |  / \  |  _ \
                   |  \| | | | | |\/| | / _ \ | | | |
                   | |\  | |_| | |  | |/ ___ \| |_| |
                   |_| \_|\___/|_|  |_/_/   \_\____/
NOMAD_ART
  echo -e "${RESET}"
  echo -e "${WHITE_R}                 Offline-Wissens- und Lernserver – Deutsche Fassung (inoffiziell)${RESET}\n"
  echo -e "${GREEN}#########################################################################${RESET}\n"
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

check_is_x86_64() {
  local arch
  arch="$(uname -m)"
  if [[ "${arch}" != "x86_64" && "${arch}" != "amd64" ]]; then
    echo -e "${YELLOW}#${RESET} WARNUNG: Erkannte Architektur „${arch}“. NOMAD unterstützt offiziell nur x86_64.\\n"
    echo -e "${YELLOW}#${RESET} Die Unterstützung für ARM64/aarch64 wird in PR #419 verfolgt und ist noch nicht fertig.\\n"
    echo -e "${YELLOW}#${RESET} Ein Fortfahren auf einer nicht unterstützten Architektur schlägt voraussichtlich fehl und kann\\n"
    echo -e "${YELLOW}#${RESET} unvollständige Docker-Images und Dateien hinterlassen, die Sie manuell aufräumen müssen.\\n"
    echo -e "${YELLOW}#${RESET} Es geht in 10 Sekunden weiter ... drücken Sie jetzt Strg+C, um abzubrechen.\\n"
    sleep 10
    return
  fi
  echo -e "${GREEN}#${RESET} Architekturprüfung bestanden (${arch}).\\n"
}

ensure_dependencies_installed() {
  local missing_deps=()

  # Check for curl
  if ! command -v curl &> /dev/null; then
    missing_deps+=("curl")
  fi

  # Check for gpg (required for NVIDIA container toolkit keyring)
  if ! command -v gpg &> /dev/null; then
    missing_deps+=("gpg")
  fi

  # Check for whiptail (used for dialogs, though not currently active)
  # if ! command -v whiptail &> /dev/null; then
  #   missing_deps+=("whiptail")
  # fi

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo -e "${YELLOW}#${RESET} Erforderliche Abhängigkeiten werden installiert: ${missing_deps[*]} ...\\n"
    sudo apt-get update
    sudo apt-get install -y "${missing_deps[@]}"

    # Verify installation
    for dep in "${missing_deps[@]}"; do
      if ! command -v "$dep" &> /dev/null; then
        echo -e "${RED}#${RESET} $dep konnte nicht installiert werden. Bitte installieren Sie es manuell und versuchen Sie es erneut."
        exit 1
      fi
    done
    echo -e "${GREEN}#${RESET} Die Abhängigkeiten wurden erfolgreich installiert.\\n"
  else
    echo -e "${GREEN}#${RESET} Alle erforderlichen Abhängigkeiten sind bereits installiert.\\n"
  fi
}

check_is_debug_mode(){
  # Check if the script is being run in debug mode
  if [[ "${script_option_debug}" == 'true' ]]; then
    echo -e "${YELLOW}#${RESET} Alle Meldungen bleiben auf dem Bildschirm stehen, damit Sie sie in Ruhe lesen können ...\\n"
  else
    clear; clear
  fi
}

generateRandomPass() {
  local length="${1:-32}"  # Default to 32
  local password
  
  # Generate random password using /dev/urandom
  password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length")
  
  echo "$password"
}

ensure_docker_installed() {
  if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}#${RESET} Docker wurde nicht gefunden. Docker wird installiert ...\\n"
    
    # Update package database
    sudo apt-get update
    
    # Install prerequisites
    sudo apt-get install -y ca-certificates curl
    
    # Create directory for keyrings
    # sudo install -m 0755 -d /etc/apt/keyrings
    
    # # Download Docker's official GPG key
    # sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    # sudo chmod a+r /etc/apt/keyrings/docker.asc

    # # Add the repository to Apt sources
    # echo \
    #   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    #   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    #   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # # Update the package database with the Docker packages from the newly added repo
    # sudo apt-get update

    # # Install Docker packages
    # sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Download the Docker convenience script
    curl -fsSL https://get.docker.com -o get-docker.sh

    # Run the Docker installation script
    sudo sh get-docker.sh

    # Check if Docker was installed successfully
    if ! command -v docker &> /dev/null; then
      echo -e "${RED}#${RESET} Die Docker-Installation ist fehlgeschlagen. Bitte prüfen Sie die Logs und versuchen Sie es erneut."
      exit 1
    fi
    
    echo -e "${GREEN}#${RESET} Die Docker-Installation ist abgeschlossen.\\n"
  else
    echo -e "${GREEN}#${RESET} Docker ist bereits installiert.\\n"
    
    # Check if Docker service is running
    if ! systemctl is-active --quiet docker; then
      echo -e "${YELLOW}#${RESET} Docker ist installiert, läuft aber nicht. Es wird versucht, Docker zu starten ...\\n"
      sudo systemctl start docker
      if ! systemctl is-active --quiet docker; then
        echo -e "${RED}#${RESET} Docker konnte nicht gestartet werden. Bitte prüfen Sie den Status des Docker-Dienstes und versuchen Sie es erneut."
        exit 1
      else
        echo -e "${GREEN}#${RESET} Der Docker-Dienst wurde erfolgreich gestartet.\\n"
      fi
    else
      echo -e "${GREEN}#${RESET} Der Docker-Dienst läuft bereits.\\n"
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

setup_nvidia_container_toolkit() {
  # This function attempts to set up NVIDIA GPU support but is non-blocking
  # Any failures will result in warnings but will NOT stop the installation process
  
  echo -e "${YELLOW}#${RESET} Es wird nach einer NVIDIA-GPU gesucht ...\\n"
  
  # Safely detect NVIDIA GPU
  local has_nvidia_gpu=false
  if command -v lspci &> /dev/null; then
    if lspci 2>/dev/null | grep -i nvidia &> /dev/null; then
      has_nvidia_gpu=true
      echo -e "${GREEN}#${RESET} NVIDIA-GPU erkannt.\\n"
    fi
  fi
  
  # Also check for nvidia-smi
  if ! $has_nvidia_gpu && command -v nvidia-smi &> /dev/null; then
    if nvidia-smi &> /dev/null; then
      has_nvidia_gpu=true
      echo -e "${GREEN}#${RESET} NVIDIA-GPU über nvidia-smi erkannt.\\n"
    fi
  fi
  
  if ! $has_nvidia_gpu; then
    echo -e "${YELLOW}#${RESET} Keine NVIDIA-GPU erkannt. Die Installation des NVIDIA Container Toolkits wird übersprungen.\\n"
    return 0
  fi
  
  # Check if nvidia-container-toolkit is already installed
  if command -v nvidia-ctk &> /dev/null; then
    echo -e "${GREEN}#${RESET} Das NVIDIA Container Toolkit ist bereits installiert.\\n"
    return 0
  fi
  
  echo -e "${YELLOW}#${RESET} Das NVIDIA Container Toolkit wird installiert ...\\n"
  
  # Install dependencies per https://docs.ollama.com/docker - wrapped in error handling
  if ! curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey 2>/dev/null | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg 2>/dev/null; then
    echo -e "${YELLOW}#${RESET} Warnung: Der GPG-Schlüssel des NVIDIA Container Toolkits konnte nicht hinzugefügt werden. Es geht trotzdem weiter ...\\n"
    return 0
  fi
  
  if ! curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list 2>/dev/null \
      | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
      | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null 2>&1; then
    echo -e "${YELLOW}#${RESET} Warnung: Das Repository des NVIDIA Container Toolkits konnte nicht hinzugefügt werden. Es geht trotzdem weiter ...\\n"
    return 0
  fi
  
  if ! sudo apt-get update 2>/dev/null; then
    echo -e "${YELLOW}#${RESET} Warnung: Die Paketliste konnte nicht aktualisiert werden. Es geht trotzdem weiter ...\\n"
    return 0
  fi
  
  if ! sudo apt-get install -y nvidia-container-toolkit 2>/dev/null; then
    echo -e "${YELLOW}#${RESET} Warnung: Das NVIDIA Container Toolkit konnte nicht installiert werden. Es geht trotzdem weiter ...\\n"
    return 0
  fi
  
  echo -e "${GREEN}#${RESET} Das NVIDIA Container Toolkit wurde erfolgreich installiert.\\n"
  
  # Configure Docker to use NVIDIA runtime
  echo -e "${YELLOW}#${RESET} Docker wird für die Nutzung der NVIDIA-Laufzeitumgebung konfiguriert ...\\n"
  
  if ! sudo nvidia-ctk runtime configure --runtime=docker 2>/dev/null; then
    echo -e "${YELLOW}#${RESET} nvidia-ctk configure ist fehlgeschlagen, es wird eine manuelle Konfiguration versucht ...\\n"
    
    # Fallback: Manually configure daemon.json
    local daemon_json="/etc/docker/daemon.json"
    local config_success=false
    
    if [[ -f "$daemon_json" ]]; then
      # Backup existing config (best effort)
      sudo cp "$daemon_json" "${daemon_json}.backup" 2>/dev/null || true
      
      # Check if nvidia runtime already exists
      if ! grep -q '"nvidia"' "$daemon_json" 2>/dev/null; then
        # Add nvidia runtime to existing config using jq if available
        if command -v jq &> /dev/null; then
          if sudo jq '. + {"runtimes": {"nvidia": {"path": "nvidia-container-runtime", "runtimeArgs": []}}}' "$daemon_json" > /tmp/daemon.json.tmp 2>/dev/null; then
            if sudo mv /tmp/daemon.json.tmp "$daemon_json" 2>/dev/null; then
              config_success=true
            fi
          fi
          # Clean up temp file if move failed
          sudo rm -f /tmp/daemon.json.tmp 2>/dev/null || true
        else
          echo -e "${YELLOW}#${RESET} jq ist nicht verfügbar, die manuelle Konfiguration von daemon.json wird übersprungen ...\\n"
        fi
      else
        config_success=true  # Already configured
      fi
    else
      # Create new daemon.json with nvidia runtime (best effort)
      if echo '{"runtimes":{"nvidia":{"path":"nvidia-container-runtime","runtimeArgs":[]}}}' | sudo tee "$daemon_json" > /dev/null 2>&1; then
        config_success=true
      fi
    fi
    
    if ! $config_success; then
      echo -e "${YELLOW}#${RESET} Die manuelle Konfiguration von daemon.json war nicht erfolgreich. Für die GPU-Unterstützung ist möglicherweise eine manuelle Einrichtung nötig.\\n"
    fi
  fi
  
  # Restart Docker service
  echo -e "${YELLOW}#${RESET} Der Docker-Dienst wird neu gestartet ...\\n"
  if ! sudo systemctl restart docker 2>/dev/null; then
    echo -e "${YELLOW}#${RESET} Warnung: Der Docker-Dienst konnte nicht neu gestartet werden. Möglicherweise müssen Sie ihn manuell neu starten.\\n"
    return 0
  fi
  
  # Verify NVIDIA runtime is available
  echo -e "${YELLOW}#${RESET} Die Konfiguration der NVIDIA-Laufzeitumgebung wird überprüft ...\\n"
  sleep 2  # Give Docker a moment to fully restart
  
  if docker info 2>/dev/null | grep -q "nvidia"; then
    echo -e "${GREEN}#${RESET} Die NVIDIA-Laufzeitumgebung wurde erfolgreich konfiguriert und überprüft.\\n"
  else
    echo -e "${YELLOW}#${RESET} Warnung: Die NVIDIA-Laufzeitumgebung wurde in den Docker-Informationen nicht gefunden. Die GPU-Beschleunigung funktioniert möglicherweise nicht.\\n"
    echo -e "${YELLOW}#${RESET} Möglicherweise müssen Sie /etc/docker/daemon.json manuell konfigurieren und Docker neu starten.\\n"
  fi
  
  echo -e "${GREEN}#${RESET} Die Konfiguration des NVIDIA Container Toolkits ist abgeschlossen.\\n"
}

get_install_confirmation(){
  echo -e "${YELLOW}#${RESET} Dieses Skript installiert Project NOMAD und seine Abhängigkeiten auf Ihrem Rechner."
  echo -e "${YELLOW}#${RESET} Falls Project NOMAD bereits mit angepasster Konfiguration oder eigenen Daten installiert ist, beachten Sie bitte, dass dieses Installationsskript vorhandene Dateien und Konfigurationen überschreiben kann. Es wird dringend empfohlen, vor dem Fortfahren alle wichtigen Daten und Konfigurationen zu sichern."
  read -p "Möchten Sie wirklich fortfahren? (j/N): " choice
  case "$choice" in
    y|Y|j|J )
      echo -e "${GREEN}#${RESET} Sie haben sich für die Fortsetzung der Installation entschieden."
      ;;
    * )
      echo "Sie haben sich gegen die Fortsetzung der Installation entschieden."
      exit 0
      ;;
  esac
}

accept_terms() {
  printf "\n\n"
  echo "Lizenzvereinbarung und Nutzungsbedingungen"
  echo "__________________________"
  printf "\n\n"
  echo "Project NOMAD steht unter der Apache License 2.0. Den vollständigen Lizenztext finden Sie unter https://www.apache.org/licenses/LICENSE-2.0 oder in der Datei LICENSE dieses Repositorys."
  printf "\n"
  echo "Mit der Annahme dieser Vereinbarung bestätigen Sie, dass Sie die Bedingungen der Apache License 2.0 gelesen und verstanden haben und sich bei der Nutzung von Project NOMAD an sie halten."
  echo -e "\n\n"
  read -p "Ich habe die Lizenzvereinbarung und Nutzungsbedingungen gelesen und akzeptiere sie (j/N)? " choice
  case "$choice" in
    y|Y|j|J )
      accepted_terms='true'
      ;;
    * )
      echo "Die Lizenzvereinbarung und Nutzungsbedingungen wurden nicht akzeptiert. Die Installation kann nicht fortgesetzt werden."
      exit 1
      ;;
  esac
}

create_nomad_directory(){
  # Ensure the main installation directory exists
  if [[ ! -d "$NOMAD_DIR" ]]; then
    echo -e "${YELLOW}#${RESET} Das Verzeichnis für Project NOMAD wird unter $NOMAD_DIR angelegt ...\\n"
    sudo mkdir -p "$NOMAD_DIR"
    sudo chown "$(whoami):$(whoami)" "$NOMAD_DIR"

    echo -e "${GREEN}#${RESET} Das Verzeichnis wurde erfolgreich angelegt.\\n"
  else
    echo -e "${GREEN}#${RESET} Das Verzeichnis $NOMAD_DIR existiert bereits.\\n"
  fi

  # Also ensure the directory has a /storage/logs/ subdirectory
  sudo mkdir -p "${NOMAD_DIR}/storage/logs"

  # Create a admin.log file in the logs directory
  sudo touch "${NOMAD_DIR}/storage/logs/admin.log"
}

download_management_compose_file() {
  local compose_file_path="${NOMAD_DIR}/compose.yml"

  echo -e "${YELLOW}#${RESET} Die docker-compose-Datei für die Verwaltung wird heruntergeladen ...\\n"
  if ! curl -fsSL "$MANAGEMENT_COMPOSE_FILE_URL" -o "$compose_file_path"; then
    echo -e "${RED}#${RESET} Die docker-compose-Datei konnte nicht heruntergeladen werden. Bitte prüfen Sie die URL und versuchen Sie es erneut."
    exit 1
  fi
  echo -e "${GREEN}#${RESET} Die docker-compose-Datei wurde erfolgreich nach $compose_file_path heruntergeladen.\\n"

  local app_key=$(generateRandomPass)
  local db_root_password=$(generateRandomPass)
  local db_user_password=$(generateRandomPass)

  # If MySQL data directory exists from a previous install attempt, remove it.
  # MySQL only initializes credentials on first startup when the data dir is empty.
  # If stale data exists, MySQL ignores the new passwords above and uses the old ones,
  # causing "Access denied" errors when the admin container tries to connect.
  if [[ -d "${NOMAD_DIR}/mysql" ]]; then
    echo -e "${YELLOW}#${RESET} Das vorhandene MySQL-Datenverzeichnis wird entfernt, damit die Zugangsdaten übereinstimmen ...\\n"
    sudo rm -rf "${NOMAD_DIR}/mysql"
  fi

  # Inject dynamic env values into the compose file
  echo -e "${YELLOW}#${RESET} Die Umgebungsvariablen der docker-compose-Datei werden konfiguriert ...\\n"
  sed -i "s|URL=replaceme|URL=http://${local_ip_address}:8080|g" "$compose_file_path"
  sed -i "s|APP_KEY=replaceme|APP_KEY=${app_key}|g" "$compose_file_path"
  
  sed -i "s|DB_PASSWORD=replaceme|DB_PASSWORD=${db_user_password}|g" "$compose_file_path"
  sed -i "s|MYSQL_ROOT_PASSWORD=replaceme|MYSQL_ROOT_PASSWORD=${db_root_password}|g" "$compose_file_path"
  sed -i "s|MYSQL_PASSWORD=replaceme|MYSQL_PASSWORD=${db_user_password}|g" "$compose_file_path"
  
  echo -e "${GREEN}#${RESET} Die docker-compose-Datei wurde erfolgreich konfiguriert.\\n"
}

download_helper_scripts() {
  local start_script_path="${NOMAD_DIR}/start_nomad.sh"
  local stop_script_path="${NOMAD_DIR}/stop_nomad.sh"
  local update_script_path="${NOMAD_DIR}/update_nomad.sh"

  echo -e "${YELLOW}#${RESET} Hilfsskripte werden heruntergeladen ...\\n"
  if ! curl -fsSL --retry 5 --retry-delay 3 "$START_SCRIPT_URL" -o "$start_script_path"; then
    echo -e "${RED}#${RESET} Das Startskript konnte nicht heruntergeladen werden. Bitte prüfen Sie die URL und versuchen Sie es erneut."
    exit 1
  fi
  chmod +x "$start_script_path"

  if ! curl -fsSL --retry 5 --retry-delay 3 "$STOP_SCRIPT_URL" -o "$stop_script_path"; then
    echo -e "${RED}#${RESET} Das Stoppskript konnte nicht heruntergeladen werden. Bitte prüfen Sie die URL und versuchen Sie es erneut."
    exit 1
  fi
  chmod +x "$stop_script_path"

  if ! curl -fsSL --retry 5 --retry-delay 3 "$UPDATE_SCRIPT_URL" -o "$update_script_path"; then
    echo -e "${RED}#${RESET} Das Update-Skript konnte nicht heruntergeladen werden. Bitte prüfen Sie die URL und versuchen Sie es erneut."
    exit 1
  fi
  chmod +x "$update_script_path"

  echo -e "${GREEN}#${RESET} Die Hilfsskripte wurden erfolgreich nach $start_script_path, $stop_script_path und $update_script_path heruntergeladen.\\n"
}

start_management_containers() {
  echo -e "${YELLOW}#${RESET} Die Verwaltungscontainer werden mit docker compose gestartet ...\\n"
  if ! sudo docker compose -p project-nomad -f "${NOMAD_DIR}/compose.yml" up -d; then
    echo -e "${RED}#${RESET} Die Verwaltungscontainer konnten nicht gestartet werden. Bitte prüfen Sie die Logs und versuchen Sie es erneut."
    exit 1
  fi
  echo -e "${GREEN}#${RESET} Die Verwaltungscontainer wurden erfolgreich gestartet.\\n"
}

get_local_ip() {
  local_ip_address=$(hostname -I | awk '{print $1}')
  if [[ -z "$local_ip_address" ]]; then
    echo -e "${RED}#${RESET} Die lokale IP-Adresse konnte nicht ermittelt werden. Bitte prüfen Sie Ihre Netzwerkkonfiguration."
    exit 1
  fi
}
verify_gpu_setup() {
  # This function only displays GPU setup status and is completely non-blocking
  # It never exits or returns error codes - purely informational
  
  echo -e "\\n${YELLOW}#${RESET} Überprüfung der GPU-Einrichtung\\n"
  echo -e "${YELLOW}===========================================${RESET}\\n"
  
  # Check if NVIDIA GPU is present
  if command -v nvidia-smi &> /dev/null; then
    echo -e "${GREEN}✓${RESET} NVIDIA-GPU erkannt:"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null | while read -r line; do
      echo -e "  ${WHITE_R}$line${RESET}"
    done
    echo ""
  else
    echo -e "${YELLOW}○${RESET} Keine NVIDIA-GPU erkannt (nvidia-smi nicht verfügbar)\\n"
  fi
  
  # Check if NVIDIA Container Toolkit is installed
  if command -v nvidia-ctk &> /dev/null; then
    echo -e "${GREEN}✓${RESET} NVIDIA Container Toolkit installiert: $(nvidia-ctk --version 2>/dev/null | head -n1)\\n"
  else
    echo -e "${YELLOW}○${RESET} NVIDIA Container Toolkit nicht installiert\\n"
  fi
  
  # Check if Docker has NVIDIA runtime
  if docker info 2>/dev/null | grep -q "nvidia"; then
    echo -e "${GREEN}✓${RESET} Docker-NVIDIA-Laufzeitumgebung konfiguriert\\n"
  else
    echo -e "${YELLOW}○${RESET} Docker-NVIDIA-Laufzeitumgebung nicht erkannt\\n"
  fi
  
  # Check for AMD GPU — restrict to display controller classes to avoid false positives
  # from AMD CPU host bridges, PCI bridges, and chipset devices.
  local has_amd_gpu='false'
  local amd_gfx_version=''
  if command -v lspci &> /dev/null; then
    if lspci 2>/dev/null | grep -iE "VGA|3D controller|Display" | grep -iE "amd|radeon" &> /dev/null; then
      has_amd_gpu='true'
      echo -e "${GREEN}✓${RESET} AMD-GPU erkannt – die ROCm-Beschleunigung wird automatisch eingerichtet, sobald der KI-Assistent installiert wird.\\n"

      # Map AMD codename → gfx version so the admin can pick the right HSA_OVERRIDE_GFX_VERSION.
      # gfx1030/1100/1101/1102 are on AMD's official ROCm allowlist and need NO override —
      # forcing one (e.g. 11.0.0) breaks GPU discovery on these. Other variants do need it.
      local amd_devices
      amd_devices=$(lspci -vmm 2>/dev/null | awk -F'\t' '/^Class:.*(VGA|3D|Display)/{c=1} c && /^Device:/{print $2; c=0}')
      if echo "${amd_devices}" | grep -iq 'Navi 21'; then
        amd_gfx_version='gfx1030'
      elif echo "${amd_devices}" | grep -iq 'Navi 22'; then
        amd_gfx_version='gfx1031'
      elif echo "${amd_devices}" | grep -iq 'Navi 23'; then
        amd_gfx_version='gfx1032'
      elif echo "${amd_devices}" | grep -iq 'Navi 24'; then
        amd_gfx_version='gfx1034'
      elif echo "${amd_devices}" | grep -iq 'Rembrandt'; then
        amd_gfx_version='gfx1035'
      elif echo "${amd_devices}" | grep -iEq 'Phoenix[0-9]?|Hawk ?Point ?[0-9]?|Radeon (780M|760M)'; then
        # Phoenix (Ryzen 7040) / Hawk Point (Ryzen 8040) — 780M & 760M are both gfx1103.
        # lspci device strings vary (Phoenix1/Phoenix2/Phoenix3, "Hawk Point", "HawkPoint1", or the bare
        # "Radeon 780M Graphics" marketing name), so match all of them or the marker goes
        # missing and the 780M silently drops to CPU. Kept before the Strix branches so a
        # "Radeon 780M" string can't be miscaught. See gfx1103 regression.
        amd_gfx_version='gfx1103'
      elif echo "${amd_devices}" | grep -iEq 'Strix Halo'; then
        amd_gfx_version='gfx1151'
      elif echo "${amd_devices}" | grep -iEq 'Strix( Point)?'; then
        amd_gfx_version='gfx1150'
      elif echo "${amd_devices}" | grep -iq 'Navi 31'; then
        amd_gfx_version='gfx1100'
      elif echo "${amd_devices}" | grep -iq 'Navi 32'; then
        amd_gfx_version='gfx1101'
      elif echo "${amd_devices}" | grep -iq 'Navi 33'; then
        amd_gfx_version='gfx1102'
      fi
    fi
  fi

  # Write detected GPU type to a marker file the admin container can read. The admin
  # container lacks lspci and AMD GPUs don't register a Docker runtime, so this is the
  # only reliable way for the admin to know an AMD GPU is present at install time.
  local gpu_marker_path="${NOMAD_DIR}/storage/.nomad-gpu-type"
  if command -v nvidia-smi &> /dev/null; then
    echo 'nvidia' | sudo tee "${gpu_marker_path}" > /dev/null 2>&1 || true
  elif [[ "${has_amd_gpu}" == 'true' ]]; then
    echo 'amd' | sudo tee "${gpu_marker_path}" > /dev/null 2>&1 || true
  else
    sudo rm -f "${gpu_marker_path}" 2>/dev/null || true
  fi

  # Companion marker used by the admin to pick the right HSA_OVERRIDE_GFX_VERSION for
  # the detected card. Absence of this file means "unknown gfx" — the admin falls back
  # to its built-in default. Always rewrite (or remove) on install to keep state fresh.
  local amd_gfx_marker_path="${NOMAD_DIR}/storage/.nomad-amd-gfx"
  if [[ -n "${amd_gfx_version}" ]]; then
    echo "${amd_gfx_version}" | sudo tee "${amd_gfx_marker_path}" > /dev/null 2>&1 || true
  else
    sudo rm -f "${amd_gfx_marker_path}" 2>/dev/null || true
  fi

  echo -e "${YELLOW}===========================================${RESET}\\n"

  # Summary
  if command -v nvidia-smi &> /dev/null && docker info 2>/dev/null | grep -q "nvidia"; then
    echo -e "${GREEN}#${RESET} Die GPU-Beschleunigung ist korrekt eingerichtet! Der KI-Assistent nutzt Ihre GPU.\\n"
  elif [[ "${has_amd_gpu}" == 'true' ]]; then
    echo -e "${GREEN}#${RESET} Die GPU-Beschleunigung (AMD/ROCm) wird aktiviert, sobald der KI-Assistent über das Dashboard installiert wird.\\n"
  else
    echo -e "${YELLOW}#${RESET} Keine GPU-Beschleunigung erkannt. Der KI-Assistent läuft nur auf der CPU.\\n"
    if command -v nvidia-smi &> /dev/null && ! docker info 2>/dev/null | grep -q "nvidia"; then
      echo -e "${YELLOW}#${RESET} Tipp: Ihre GPU wurde erkannt, aber die Docker-Laufzeitumgebung ist nicht konfiguriert.\\n"
      echo -e "${YELLOW}#${RESET} Starten Sie Docker neu: ${WHITE_R}sudo systemctl restart docker${RESET}\\n"
    fi
  fi
}

success_message() {
  echo -e "${GREEN}#${RESET} Die Installation von Project NOMAD wurde erfolgreich abgeschlossen!\\n"
  echo -e "${GREEN}#${RESET} Die Installationsdateien befinden sich unter /opt/project-nomad\\n\n"
  echo -e "${GREEN}#${RESET} Die Kommandozentrale von Project NOMAD sollte bei jedem Neustart Ihres Geräts automatisch starten. Falls Sie sie manuell starten müssen, führen Sie Folgendes aus: ${WHITE_R}${NOMAD_DIR}/start_nomad.sh${RESET}\\n"
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
check_is_x86_64
check_is_bash
check_has_sudo
ensure_dependencies_installed
check_is_debug_mode

# Main install
banner
get_install_confirmation
accept_terms
ensure_docker_installed
check_docker_compose
setup_nvidia_container_toolkit
get_local_ip
create_nomad_directory
download_helper_scripts
download_management_compose_file
start_management_containers
verify_gpu_setup
success_message

# free_space_check() {
#   if [[ "$(df -B1 / | awk 'NR==2{print $4}')" -le '5368709120' ]]; then
#     header_red
#     echo -e "${YELLOW}#${RESET} You only have $(df -B1 / | awk 'NR==2{print $4}' | awk '{ split( "B KB MB GB TB PB EB ZB YB" , v ); s=1; while( $1>1024 && s<9 ){ $1/=1024; s++ } printf "%.1f %s", $1, v[s] }') of disk space available on \"/\"... \\n"
#     while true; do
#       read -rp $'\033[39m#\033[0m Do you want to proceed with running the script? (y/N) ' yes_no
#       case "$yes_no" in
#          [Nn]*|"")
#             free_space_check_response="Cancel script"
#             free_space_check_date="$(date +%s)"
#             echo -e "${YELLOW}#${RESET} OK... Please free up disk space before running the script again..."
#             cancel_script
#             break;;
#          [Yy]*)
#             free_space_check_response="Proceed at own risk"
#             free_space_check_date="$(date +%s)"
#             echo -e "${YELLOW}#${RESET} OK... Proceeding with the script.. please note that failures may occur due to not enough disk space... \\n"; sleep 10
#             break;;
#          *) echo -e "\\n${RED}#${RESET} Invalid input, please answer Yes or No (y/n)...\\n"; sleep 3;;
#       esac
#     done
#     if [[ -n "$(command -v jq)" ]]; then
#       if [[ "$(dpkg-query --showformat='${version}' --show jq 2> /dev/null | sed -e 's/.*://' -e 's/-.*//g' -e 's/[^0-9.]//g' -e 's/\.//g' | sort -V | tail -n1)" -ge "16" && -e "${eus_dir}/db/db.json" ]]; then
#         jq '.scripts."'"${script_name}"'" += {"warnings": {"low-free-disk-space": {"response": "'"${free_space_check_response}"'", "detected-date": "'"${free_space_check_date}"'"}}}' "${eus_dir}/db/db.json" > "${eus_dir}/db/db.json.tmp" 2>> "${eus_dir}/logs/eus-database-management.log"
#       else
#         jq '.scripts."'"${script_name}"'" = (.scripts."'"${script_name}"'" | . + {"warnings": {"low-free-disk-space": {"response": "'"${free_space_check_response}"'", "detected-date": "'"${free_space_check_date}"'"}}})' "${eus_dir}/db/db.json" > "${eus_dir}/db/db.json.tmp" 2>> "${eus_dir}/logs/eus-database-management.log"
#       fi
#       eus_database_move
#     fi
#   fi
# }
