#!/usr/bin/env bash
# de/tools/script-check.sh <datei> – vergleicht mit dem Stand BASE (Standard: Commit-Tag
# de-urls, gesetzt nach Task 11); erlaubt Änderungen nur in echo/printf/read -p/log-Zeilen und Kommentaren.
set -euo pipefail
f=$1
BASE=${BASE:-de-urls}
strip() { grep -vE '^\s*(#|echo|printf|log |read -r?p|read -p)' | grep -vE '^\s*"[^"]*"\s*$' ; }
diff <(git show "$BASE":"$f" | strip) <(strip < "$f") && echo "$f: nur Texte geändert"
