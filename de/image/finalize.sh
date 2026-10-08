#!/usr/bin/env bash
# de/image/finalize.sh – ALLERLETZTER Schritt im Bau-System, danach herunterfahren und das Abbild ziehen.
# Entfernt den Bau-Zugang (Benutzer seeas, SSH) und alles, was je Stick neu entstehen muss.
set -euo pipefail
systemctl disable ssh.service ssh.socket >/dev/null 2>&1 || true
rm -f /etc/ssh/ssh_host_*
rm -rf /var/log/journal/* /var/log/*.log /var/log/apt/* /root/.ssh /root/.bash_history
: > /etc/machine-id; rm -f /var/lib/dbus/machine-id
rm -f /etc/sudoers.d/seeas
userdel -r seeas 2>/dev/null || true
echo "finalize.sh fertig – jetzt: sudo poweroff"
