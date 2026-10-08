# Bootfähiges NOMAD-System für die USB-SSD

Ziel: Ein Windows-PC bleibt unangetastet und startet NOMAD von einer USB-SSD. Das Image enthält Ubuntu 26.04 LTS (Desktop),
Docker und die NOMAD-Images, aber **keine Inhalte** (Wikipedia, Karten, KI). NOMAD wird beim ersten Start eingerichtet,
dabei entstehen eigene Schlüssel und Passwörter je Stick.

## Bauen (auf x9 in einer VM, reproduzierbar)

1. Ubuntu-26.04-Server-Cloud-Image (`ubuntu-26.04-server-cloudimg-amd64.img`) kopieren, auf 24 GB vergrößern.
2. Im Abbild (per `qemu-nbd`) Benutzer `seeas` mit SSH-Schlüssel und Host-Schlüssel anlegen, `cloud-init.disabled` setzen,
   Systempartition mit `growpart`/`resize2fs` vergrößern. Hinweis: Cloud-init lief in der Bau-VM nicht an; das Einrichten
   von Hand im Abbild war die Lösung.
3. VM starten, `provision.sh <install-Ordner>` als root ausführen (Desktop, Docker, Images, Erststart-Dienst, Autologin).
4. `finalize.sh` ausführen (entfernt Bau-Zugang, SSH, Schlüssel), VM von außen herunterfahren.
5. Dateisystem auf 13 GB verkleinern (`resize2fs`), Rohabbild ziehen (`qemu-img convert -O raw`), Partition 1 mit `sgdisk`
   auf 13 GiB setzen (Start 2324480, Ende 29587455, Typ- und Partitions-GUID beibehalten), Datei kürzen, `sgdisk -e`.
6. `xz -T0 -6` und Prüfsumme (`sha256sum`).

## Test in der VM (2026-10-09)

Image auf eine größere „Platte“ (64 GB) kopiert, per UEFI **mit Secure Boot** gestartet:
- Start bis zum Desktop in etwa einer Minute, Autologin, deutsche Oberfläche.
- Erststart richtet NOMAD ein (ca. 1 Minute, ohne Internet), der Browser öffnet die Kommandozentrale.
- Die Systempartition ist auf die ganze Platte gewachsen (62,9 GB), `nomad-firstboot.done` ist gesetzt.

## Zugang im fertigen System

Benutzer `nomad`, Passwort `nomad`, Autologin an. **Passwort ändern**, sobald das System im Netz steht (Handbuch).
SSH ist aus. Rechnername `nomad`.

## Nicht in der VM testbar

Boot an echter Hardware (Boot-Menü, Secure-Boot-Schlüssel, Grafik, WLAN) und die Geschwindigkeit der USB-SSD.

## Offen

- Erststart ohne Netzwerkkabel am echten PC prüfen (NetworkManager, WLAN-Auswahl).
- Ob `pull_policy: missing` beim späteren Update über die Oberfläche weiter funktioniert (Updater zieht Images selbst).
- Kein Passwortwechsel beim ersten Start erzwungen; für Laien ggf. einen Dialog einbauen.
