#!/usr/bin/env bash
# de/tools/release.sh <version> – baut alle Images des Forks und legt das GitHub-Release an.
# Version: Patch = 100 × Upstream-Patch + n (siehe de/specs/…-teilprojekt-a…md, Nachtrag 1).
set -euo pipefail
v=${1:?Version, z. B. 1.35.1}
[[ $v =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Version muss X.Y.Z sein"; exit 1; }
R=huppiflupp/project-nomad-de
for wf in build-primary-image build-sidecar-updater build-disk-collector; do
  gh workflow run "$wf.yml" -R "$R" --ref main -f version="$v" -f tag_latest=true
done
echo "Workflows gestartet – warten: gh run list -R $R -L 5"
read -rp "Alle Builds grün? (j/n) " a; [[ $a =~ ^[JjYy]$ ]] || exit 1
gh release create "v$v" -R "$R" --target main --title "v$v – Deutsche Fassung" --notes-file "de/release-notes/v$v.md"
