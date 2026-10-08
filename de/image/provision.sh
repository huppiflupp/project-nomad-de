#!/usr/bin/env bash
# de/image/provision.sh – läuft IM Bau-System (Ubuntu 26.04 Server-Cloud-Image, als root) und macht daraus das
# bootfähige NOMAD-System für die USB-SSD. Aufruf: sudo bash provision.sh <Ordner-mit-install-Dateien>
# Das Ergebnis enthält Desktop, Docker und die NOMAD-Images, aber noch KEIN installiertes NOMAD und keine Inhalte:
# NOMAD wird beim ersten Start eingerichtet (eigene Schlüssel je Stick), siehe nomad-firstboot.sh.
set -euo pipefail
SRC=${1:?Ordner mit install_nomad.sh, management_compose.yaml, start/stop/update_nomad.sh}
export DEBIAN_FRONTEND=noninteractive

echo "== 1/7 Desktop, Netzwerk, Sprache"
apt-get update -qq
apt-get install -y -qq ubuntu-desktop-minimal network-manager language-pack-de language-pack-gnome-de \
  gnome-initial-setup- fonts-dejavu-core curl ca-certificates cloud-guest-utils firefox
apt-get purge -y -qq cloud-init netplan.io 2>/dev/null || true   # Netzwerk macht NetworkManager

echo "== 2/7 Docker"
curl -fsSL https://get.docker.com | sh >/dev/null 2>&1
systemctl enable docker >/dev/null

echo "== 3/7 NOMAD-Dateien und Images vorab"
install -d /usr/share/nomad-de/install
cp "$SRC"/install_nomad.sh "$SRC"/management_compose.yaml "$SRC"/start_nomad.sh "$SRC"/stop_nomad.sh "$SRC"/update_nomad.sh \
   /usr/share/nomad-de/install/
cd /usr/share/nomad-de/install
# offline einrichtbar: Dateien lokal holen, Images nur ziehen, wenn sie fehlen
sed -i 's#https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/#file:///usr/share/nomad-de/install/#' install_nomad.sh
sed -i 's/pull_policy: always/pull_policy: missing/' management_compose.yaml
for img in $(grep -E '^\s+image:' management_compose.yaml | awk '{print $2}'); do docker pull -q "$img" >/dev/null; done
docker images --format '{{.Repository}}:{{.Tag}}  {{.Size}}'

echo "== 4/7 Erststart-Dienst"
install -m 755 /dev/stdin /usr/local/sbin/nomad-firstboot.sh <<'EOS'
#!/usr/bin/env bash
# Beim ersten Start: Platte voll nutzen, NOMAD einrichten. Danach läuft er ohne Internet.
set -u
LOG=/var/log/nomad-firstboot.log; exec >>"$LOG" 2>&1
echo "== $(date) Erststart"
# 1. Systempartition auf die ganze Platte vergrößern
root=$(findmnt -no SOURCE /); disk=$(lsblk -no PKNAME "$root"); part=$(echo "$root" | grep -o '[0-9]*$')
growpart "/dev/$disk" "$part" || true
resize2fs "$root" || true
# 2. SSH-Schlüssel erzeugen (jeder Stick bekommt eigene)
ssh-keygen -A
# 3. NOMAD einrichten (Images liegen schon da; Antworten j/j für die beiden Rückfragen)
printf 'j\nj\n' | bash /usr/share/nomad-de/install/install_nomad.sh
echo "== fertig: $(date)"
touch /var/lib/nomad-firstboot.done
EOS
cat > /etc/systemd/system/nomad-firstboot.service <<'EOS'
[Unit]
Description=NOMAD beim ersten Start einrichten
After=docker.service network-online.target
Wants=network-online.target
ConditionPathExists=!/var/lib/nomad-firstboot.done
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/nomad-firstboot.sh
TimeoutStartSec=1800
[Install]
WantedBy=multi-user.target
EOS
systemctl enable nomad-firstboot.service >/dev/null

echo "== 5/7 Benutzer, Anmeldung, Browser"
id nomad >/dev/null 2>&1 || useradd -m -s /bin/bash -G sudo,docker -c "NOMAD" nomad
echo 'nomad:nomad' | chpasswd
mkdir -p /etc/gdm3
cat > /etc/gdm3/custom.conf <<'EOS'
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=nomad
EOS
cat > /usr/local/bin/nomad-oeffnen <<'EOS'
#!/usr/bin/env bash
# Wartet, bis die Kommandozentrale antwortet, und öffnet sie im Browser.
for i in $(seq 1 180); do curl -sf -m 3 http://localhost:8080/api/health >/dev/null && break; sleep 5; done
exec firefox http://localhost:8080
EOS
chmod 755 /usr/local/bin/nomad-oeffnen
cat > /etc/xdg/autostart/nomad-oeffnen.desktop <<'EOS'
[Desktop Entry]
Type=Application
Name=NOMAD öffnen
Exec=/usr/local/bin/nomad-oeffnen
EOS
install -d /usr/share/applications
cat > /usr/share/applications/nomad.desktop <<'EOS'
[Desktop Entry]
Type=Application
Name=NOMAD Kommandozentrale
Comment=Offline-Wissensserver öffnen
Exec=firefox http://localhost:8080
Icon=web-browser
Categories=Network;
EOS

echo "== 6/7 Sprache, Zeitzone, Tastatur, kein Sperrbildschirm"
timedatectl set-timezone Europe/Berlin
localectl set-locale LANG=de_DE.UTF-8
sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="de"/' /etc/default/keyboard   # localectl kennt im Server-Image keine Tabellen
echo nomad > /etc/hostname
sed -i 's/ubuntu/nomad/g' /etc/hosts 2>/dev/null || true
install -d /etc/dconf/db/local.d /etc/dconf/profile
printf 'user-db:user\nsystem-db:local\n' > /etc/dconf/profile/user
cat > /etc/dconf/db/local.d/00-nomad <<'EOS'
[org/gnome/desktop/screensaver]
lock-enabled=false
[org/gnome/desktop/session]
idle-delay=uint32 0
[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-type='nothing'
sleep-inactive-battery-type='nothing'
[org/gnome/desktop/input-sources]
sources=[('xkb', 'de')]
EOS
dconf update
# Bildschirmschoner/Ruhezustand ganz aus: dieser Rechner soll laufen
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target >/dev/null

echo "== 7/7 Aufräumen"
apt-get autoremove -y -qq >/dev/null; apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache
echo "provision.sh fertig – danach finalize.sh (SSH aus, Schlüssel und Bau-Zugang entfernen)"
