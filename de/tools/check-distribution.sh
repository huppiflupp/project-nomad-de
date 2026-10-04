#!/usr/bin/env bash
# de/tools/check-distribution.sh – schlägt fehl, wenn außerhalb von Doku/Tests/de noch
# Upstream-Repo oder -Images referenziert werden (Ausnahmen: project-nomad-maps, nomad-sysbench).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
hits=$(git grep -nIiE 'crosstalk-?solutions/project-nomad([^-a-z0-9_]|$)|ghcr\.io/crosstalk-solutions/project-nomad' -- . \
  ':!de/' ':!*.md' ':!admin/docs/' ':!admin/docs-de/' ':!admin/tests/' ':!.github/workflows/release.yml' \
  ':!admin/inertia/components/Footer.tsx' ':!admin/constants/distribution.ts' ':!admin/scripts/' || true)
if [ -n "$hits" ]; then
  echo "Upstream-Verweise gefunden:"; echo "$hits"; exit 1
fi
echo "check-distribution: ok"
