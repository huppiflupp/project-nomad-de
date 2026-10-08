# Abnahme auf x9 (Task 17) – Stand 2026-10-08

Testumgebung: Wegwerf-VM `nomad-de-test` (Ubuntu 24.04 Cloud-Image, 4 vCPU, 8 GiB, 60 GB) auf x9,
libvirt `qemu:///system`, Netz `default`; Disk `/data/vms/nomad-de-test.qcow2`.

**Abweichung vom Plan:** `main` enthält noch den Upstream-Stand und auf ghcr.io gibt es noch keine Images
(Task 16 steht aus). Deshalb Branch-Test: Installer, Compose und Hilfsskripte von `de/teil-a` (Commit ad59500)
per `file://` statt `raw.githubusercontent.com/.../main`; die drei Images lokal gebaut (`nomad-de:dev`,
`install/sidecar-updater`, `install/sidecar-disk-collector`), als `ghcr.io/huppiflupp/…:latest` getaggt und per
`docker save | docker load` in die VM gebracht. Docker vorab per get.docker.com installiert.
Da das Compose `pull_policy: always` setzt, brach der Installer beim Pull mit `denied` ab (erwartbar ohne
veröffentlichte Images); der Stack wurde danach mit `docker compose up -d --pull missing` gestartet.

## Ergebnisse

| Schritt | Ergebnis |
|---|---|
| 3 Installer | Alle Meldungen deutsch (Hinweis, Lizenz, Verzeichnis, Hilfsskripte, Compose). Ende mit Fehler beim Image-Pull, siehe oben. |
| 4.1 `docker ps` | Nur `ghcr.io/huppiflupp/project-nomad-de{,-sidecar-updater,-disk-collector}` plus mysql, redis, dozzle. |
| 4.2 Crawl, 45 Seiten | Englisch: 0 Funde. Deutsch: 7 Seiten mit Funden, alle in der „bewusst englisch“-Liste von `STAND.md` (Fremdoberflächen in Anleitungen, Fehlermeldung in FAQ, Versionshinweise, Ollama-Modellbeschreibungen, Kiwix-Katalog). Zu prüfen: „Download“ in `/docs/drug-reference`. |
| 4.3 Anleitungen | Cookie `nomad_lang=de` → „Willkommen bei Project NOMAD“, `en` → „Welcome to Project NOMAD“. |
| 4.4 App installieren | Kiwix per `/api/system/services/install` installiert, Container läuft; Supply-Depot-Seite komplett deutsch (Kategorie von Ollama zeigt „Ai“ statt „KI“). |
| 4.5 KI-Chat | Nicht durchgeführt (optional). |
| 5 Update-Test | Offen, braucht das Release (Task 16). |
