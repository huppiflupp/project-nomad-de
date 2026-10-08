#!/bin/bash

echo "Laufende Docker-Container von Project NOMAD werden gesucht ..."

containers=$(docker ps --filter "name=^nomad_" --format "{{.Names}}")

if [ -z "$containers" ]; then
    echo "Keine laufenden Container für Project NOMAD gefunden."
    exit 0
fi

echo "Folgende laufende Container wurden gefunden:"
echo "$containers"
echo ""

for container in $containers; do
    echo "Container wird sauber beendet: $container"
    if docker stop "$container"; then
        echo "✓ $container erfolgreich beendet"
    else
        echo "✗ $container konnte nicht beendet werden"
    fi
    echo ""
done

echo "Das saubere Herunterfahren aller Project-NOMAD-Container wurde angestoßen."
