# Bootfähiges NOMAD-System für die USB-SSD

Ziel: Ein Windows-PC bleibt unangetastet und startet NOMAD von einer USB-SSD. Das Image enthält Ubuntu 26.04 LTS (Desktop),
Docker und die NOMAD-Images, aber **keine Inhalte** (Wikipedia, Karten, KI). NOMAD wird beim ersten Start eingerichtet,
dabei entstehen eigene Schlüssel und Passwörter je Stick.

## Bauen (auf x9 in einer VM, alles reproduzierbar)

1. Ubuntu-26.04-Server-Cloud-Image (`ubuntu-26.04-server-cloudimg-amd64.img`) kopieren, auf 24 GB vergrößern.
2. Im Abbild (per `qemu-nbd`) Benutzer `seeas` mit SSH-Schlüssel und Host-Schlüssel anlegen, `cloud-init.disabled` setzen.
   Hinweis: Cloud-init lief in der VM nicht an; das Einrichten von Hand im Abbild war die Lösung.
3. VM starten, `provision.sh <install-Ordner>` als root ausführen (Desktop, Docker, Images, Erststart-Dienst, Autologin).
4. `finalize.sh` ausführen (entfernt Bau-Zugang, SSH, Schlüssel), VM herunterfahren.
5. Dateisystem auf 13 GB verkleinern (`resize2fs`), Rohabbild ziehen (`qemu-img convert -O raw`), Partition 1 mit `sgdisk`
   auf 13 GiB setzen (Start 2324480, Ende 29587455, Typ- und Partitions-GUID beibehalten), Datei kürzen, `sgdisk -e`.
6. `xz -T0 -6` und Prüfsumme.

## Testen (in der VM)

Image auf eine größere „Platte“ (64 GB) kopieren, per UEFI **mit Secure Boot** starten. Ergebnis vom 2026-10-09:
Start bis zum Desktop in etwa einer Minute, Autologin, Erststart richtet NOMAD ein (ca. 1 Minute, ohne Internet), Browser
öffnet die Kommandozentrale, Systempartition ist auf die ganze Platte gewachsen (62,9 GB).

## Zugang im fertigen System

Benutzer `nomad`, Passwort `nomad`, Autologin an. **Passwort ändern**, sobald das System im Netz steht (Handbuch).
SSH ist aus. Hostname `nomad`.

## Nicht in der VM testbar

Boot an echter Hardware (Boot-Menü, Secure Boot-Schlüssel, Grafik, WLAN), Geschwindigkeit der USB-SSD.

## Ergebnis des Baus (2026-10-09)

`nomad.img.xz`: 4,9 GB (entpackt 14,1 GiB), SHA-256 `20c0094ee54dd556d6f3284fd7696cbbe2027996254f4d375e2ac9f1a1e260f8`.
Liegt auf x9 unter `/data/vms/image-build/`; noch nicht veröffentlicht.

## Offen

- Erststart ohne Netzwerkkabel am echten PC prüfen (NetworkManager, WLAN-Auswahl).
- Ob ein Update über die Oberfläche funktioniert, obwohl im Image `pull_policy: missing` statt `always` gilt (der Updater zieht Images selbst).
- Kein erzwungener Passwortwechsel beim ersten Start; für Laien ggf. einen Dialog einbauen.
- Schlüssel (SSH-Host-Schlüssel) entstehen je Stick beim ersten Start; die NOMAD-Zugangsdaten (APP_KEY, Datenbankpasswort) erzeugt der Installer ebenfalls erst dann.
