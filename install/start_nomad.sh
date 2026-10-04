#!/bin/bash

echo "Project-NOMAD-Container werden gesucht ..."

# -a to include all containers (running and stopped)
containers=$(docker ps -a --filter "name=^nomad_" --format "{{.Names}}")

if [ -z "$containers" ]; then
    echo "Keine Container für Project NOMAD gefunden. Ist es installiert?"
    exit 0
fi

echo "Folgende Container wurden gefunden:"
echo "$containers"
echo ""

for container in $containers; do
    echo "Container wird gestartet: $container"
    if docker start "$container"; then
        echo "✓ $container erfolgreich gestartet"
    else
        echo "✗ $container konnte nicht gestartet werden"
    fi
    echo ""
done

echo "Der Start aller Project-NOMAD-Container wurde angestoßen."
