# Testinstanz der deutschen Fassung (ai395)

Nur zum Ansehen der Oberfläche. Eigener Compose-Projektname (`nomad-de-dev`), eigener Port (18080),
eigene Daten unter `de/dev/data/` (nicht im Git). **Kein Docker-Socket**: Apps lassen sich hier nicht
installieren und es werden keine Container auf dem Host gestartet – das wird auf x9 getestet.
Die Seiten melden deshalb im Log `connect ENOENT /var/run/docker.sock`; das ist erwartet.

```bash
cd ~/projects/project-nomad-de
docker build -t nomad-de:dev .
docker compose -f de/dev/compose.yml up -d
curl -fsS localhost:18080/api/health      # {"status":"ok"}
docker compose -f de/dev/compose.yml down # Daten bleiben in de/dev/data/
```

Nie ohne `-f de/dev/compose.yml` arbeiten – die produktive Instanz auf ai395 (`nomad_*`, `/opt/project-nomad`)
bleibt unberührt.

## Seiten-Crawl

```bash
cd de/tools/crawl && npm i && npx playwright install chromium
node crawl.mjs http://localhost:18080 > report.json          # Deutsch
LANG=en node crawl.mjs http://localhost:18080 > report-en.json # Gegenprobe Englisch
```

`suspicious`: Text mit mindestens zwei englischen Funktionswörtern und keinem deutschen Merkmal.
`untranslated`: sichtbarer Text, der wörtlich ein englischer Wörterbuchschlüssel ist (findet auch kurze
Texte wie Menüpunkte). Im englischen Lauf meldet `suspicious` verdächtig deutschen Text.

Nicht prüfbar in dieser Instanz: `/chat` (antwortet ohne installierten KI-Assistenten mit 404; ohne
Docker-Socket markiert der Abgleich `nomad_ollama` beim nächsten Seitenaufruf wieder als nicht installiert)
und alle Dialoge, die laufende Apps voraussetzen. Diese Texte wurden per Codedurchsicht geprüft.
