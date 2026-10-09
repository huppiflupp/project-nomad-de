#!/bin/bash
# testinstanz.sh – echte Testinstanz der deutschen Fassung auf ai395 (Docker, alle Dienste).
# Daten liegen in ~/nomad (/opt/project-nomad zeigt dorthin); Oberfläche: http://ai395.fritz.box:18080
#
#   testinstanz.sh status          Zustand der Container
#   testinstanz.sh start | stop    alle nomad_*-Container starten / anhalten
#   testinstanz.sh neu [version]   Verwaltungscontainer neu ziehen (Standard: latest), Inhalte und Datenbank bleiben
#   testinstanz.sh zuruecksetzen   Datenbank, Apps und Einstellungen löschen; storage/ (ZIMs, Karten, Modelle) bleibt
#   testinstanz.sh alles-loeschen  alles löschen, auch storage/ (fragt nach)
set -euo pipefail
D="${NOMAD_DIR:-$HOME/nomad}"
C="docker compose -f $D/compose.yml"
apps() { docker ps -a --format '{{.Names}}' | grep -E '^nomad_' || true; }
case "${1:-status}" in
  status) docker ps -a --filter name=^nomad_ --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' ;;
  start)  apps | xargs -r docker start ;;
  stop)   apps | xargs -r docker stop ;;
  neu)
    v="${2:-latest}"
    sed -i -E "s#(image: ghcr.io/huppiflupp/project-nomad-de(-sidecar-updater|-disk-collector)?):[^ ]+#\1:$v#" "$D/compose.yml"
    $C pull && $C up -d ;;
  zuruecksetzen|alles-loeschen)
    [ "$1" = alles-loeschen ] && { read -p "Auch storage/ (alle Inhalte) löschen? (ja/N) " a; [ "$a" = ja ] || exit 1; }
    $C down -v
    apps | xargs -r docker rm -f
    docker run --rm -v "$D:/n" alpine sh -c 'rm -rf /n/mysql/* /n/redis/*'
    [ "$1" = alles-loeschen ] && docker run --rm -v "$D:/n" alpine sh -c 'rm -rf /n/storage/*'
    $C up -d ;;
  *) sed -n 2,9p "$0"; exit 1 ;;
esac
