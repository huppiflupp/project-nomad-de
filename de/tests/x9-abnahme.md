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

# Teil 2: Test von `main` mit Ubuntu 26.04.1 Desktop (2026-10-08, Abend)

VM `nomad-de-ubuntu` auf x9 (4 vCPU, 8 GiB, 80 GB, UEFI), Ubuntu 26.04.1 LTS Desktop aus der ISO, Installation von Hand
über die Oberfläche (Screenshots in `de/handbuch/bilder/roh/`). Danach die Befehle aus dem README, **ohne** Umwege:
`apt-get install curl`, Skript von `raw.githubusercontent.com/.../main/install/install_nomad.sh` laden, `sudo bash install_nomad.sh`.

## Ergebnis

| Schritt | Ergebnis |
|---|---|
| Ubuntu installieren | ca. 15 Minuten, alle Seiten deutsch; Weg: Sprache, Tastatur, Netz, Installieren, Standard-Installation, Treiber-Haken, Festplatte löschen, keine Verschlüsselung, Konto, Zeitzone, Zusammenfassung |
| NOMAD-Installer von `main` | **erfolgreich**, ca. 2 Minuten, alle Meldungen deutsch, Images von ghcr ohne Anmeldung gezogen |
| Kommandozentrale | deutsch, Fuß zeigt „v1.35.1“ und „Inoffizielle deutsche Fassung …“ |
| Schnellstart | Wissensbibliothek, Medizin-Basis (4 Dateien), Wikipedia Schnellreferenz: 662 MB, im LAN in unter 1 Minute geladen |
| **Offline-Test** | Netz der VM getrennt: `ping` 100 % Verlust, GitHub nicht erreichbar. Kiwix (6 Bücher, mit Bildern) und die deutschen Anleitungen funktionieren weiter |

## Funde (offen)

1. **Karten:** Schnellstart bietet nur US-Regionen (Pacific, Mountain, … New England). Deutschland nur über den Karten-Manager. Katalog für Deutschland fehlt (Teilprojekt B).
2. **Inhalte nur englisch:** alle 6 geladenen Kiwix-Bücher sind „EN“. Kein deutsches Wikipedia im Schnellstart.
3. **Englische Reste im Dialog der Inhaltsstufen:** „4 resources included“, „2 additional resources(plus alles aus Basis)“ (Leerzeichen fehlt). Der Crawl findet das nicht, weil der Dialog erst per Klick aufgeht.
4. **Aktivitätsprotokoll englisch:** auf der Schnellstart-Abschlussseite stehen englische Zeilen („Downloading Wikipedia ZIM file …“, „Pre-install actions … completed successfully“). Diese Meldungen kommen als Server-Ereignisse und laufen am Übersetzer vorbei.
5. **Installer-Hinweis:** „Der Debug-Modus ist aktiviert, das Skript leert den Bildschirm nicht“ – prüfen, ob das gewollt ist oder ein Rest.
6. **Auto-Index:** Der Dialog nennt „zusätzlicher Speicherplatz, wenn diese für den KI-Assistenten indiziert werden … Auto-Index Einstellung ist Immer“. Das heißt: NOMAD indiziert Kiwix-Inhalte für die KI (Notfall-KI, Phase 4). Noch nicht mit einem Modell geprüft.
7. **Tastatur:** In der VM gilt die deutsche Belegung; ein Hilfsskript für die Eingabe musste darauf angepasst werden (nur Testwerkzeug).

## Noch offen aus Task 17

Update-Test auf 1.35.2 (braucht ein zweites Release). KI-Chat (Ollama, kleines Modell) und die Frage, ob die Antworten auf die geladenen Inhalte zugreifen.
