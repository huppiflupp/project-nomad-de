# Abgleich mit dem Original (Upstream)

Dieses Dokument beschreibt, wie Änderungen aus Crosstalk Solutions' Project NOMAD in diese deutsche Fassung kommen, und hält den Stand fest.
Original: `https://github.com/Crosstalk-Solutions/project-nomad` (Remote `upstream`).

## Stand 2026-10-09 (Probe, nichts übernommen)

| | |
|---|---|
| Gemeinsame Basis | `5e1702e` (Original v1.35.0, 2026-10-04) |
| Spitze des Originals | `54ee30a` = v1.35.1 + 1 Commit (nur Release-Notizen) |
| Neue Commits im Original | 7 |
| Geänderte Dateien im Original | 11 (335 Zeilen hinzu, 74 weg) |
| Davon auch von uns geändert | **1**: `admin/database/seeders/service_seeder.ts` |
| Probe-Merge (Wegwerf-Zweig) | **1 Konflikt**, nur in `service_seeder.ts` |

Der Fork hat 282 Dateien gegenüber der Basis geändert, überwiegend Übersetzungen, Doku und `de/`. Der Abstand ist klein, weil das Original zwischen v1.35.0 und v1.35.1 wenig bewegt hat.

### Was das Original geändert hat

| Datei(en) | Änderung | Folge für uns |
|---|---|---|
| `admin/app/services/ollama_service.ts`, `admin/app/utils/model_capabilities.ts`, `admin/tests/unit/chat_images.spec.ts` | KI: ein vom Server gemeldetes Modell wird auf Bildunterstützung geprüft, bevor Bilder abgeschaltet werden | Quelltext, mergt ohne Konflikt. Neue Server-Texte? Mit `node i18n/cli.mjs check` prüfen |
| `admin/database/seeders/service_seeder.ts` | Übersetzungs-Image `project-nomad-translate` 0.1.0 → 0.1.1, Kommentare 74 MB → 45–140 MB | **Konflikt**: unsere Zeile nutzt `${DISTRIBUTION.translateImage}:0.1.0`. Lösung: `${DISTRIBUTION.translateImage}:0.1.1`, Kommentare des Originals übernehmen |
| `install/nomad-translate/*` (`proxy.py`, `fetch_models.py`, README, neuer Test) | Übersetzungsdienst lädt alle veröffentlichten Sprachen, leitet Weiterleitungen weiter | Nach dem Merge **Image 0.1.1 in unserem ghcr bauen** (Workflow `build-translate-proxy`), sonst zeigt der Seeder auf ein Image, das es nicht gibt |
| `admin/docs/release-notes.md`, `admin/docs/supply-depot-apps.md` | Doku: Sprachen-Liste (50 Sprachen), Anleitung zur Sprachauswahl | `admin/docs-de/…` entsprechend übersetzen; `node de/tools/docs-check.mjs` meldet Abweichungen |
| `package.json` | Version 1.35.0 → 1.35.1 | Kein Konflikt (unsere Version steuert der Release-Workflow) |

## Rezept für einen Abgleich

```bash
cd ~/projects/project-nomad-de
git remote get-url upstream || git remote add upstream https://github.com/Crosstalk-Solutions/project-nomad.git
git fetch upstream --tags
git log --oneline $(git merge-base HEAD upstream/main)..upstream/main      # was ist neu
git diff --name-only $(git merge-base HEAD upstream/main) upstream/main    # welche Dateien
git checkout -b sync/upstream-<Version>
git merge upstream/main                                                    # Konflikte lösen, siehe Regeln unten
```

Danach, in dieser Reihenfolge:

1. **Texte:** `cd admin && node i18n/cli.mjs check`. Neue englische Texte erscheinen als „fehlend“ und müssen in `admin/i18n/de.json` (Oberfläche, Server) oder `catalog.de.json` (Kataloge) übersetzt werden (Sie-Form, Glossar der Übersetzungsrichtlinien).
2. **Doku:** `node de/tools/docs-check.mjs` (vergleicht `admin/docs` und `admin/docs-de`: Überschriften, Links, Code-Blöcke), `node de/tools/sie-check.mjs` (keine Du-Formen).
3. **Verteilung:** `bash de/tools/check-distribution.sh` (Install-Skripte und Compose zeigen auf den Fork, nicht auf das Original).
4. **Tests:** `npm run test:unit` (Ausgangslage siehe `STAND.md`: 10 bekannte Fehlschläge im Original), `npm run typecheck`, `npx tsc --noEmit -p inertia` (Ausgangswert 35 Fehler).
5. **Seiten-Crawl:** `node de/tools/crawl/crawl.mjs <URL> > report.json` gegen eine Testinstanz (meldet englische Reste).
6. **Images:** Hat das Original Container-Images geändert (Primary, Sidecar-Updater, Disk-Collector, Translate), die Workflows `build-*` mit der neuen Version starten (`de/RELEASE.md`).
7. Pull Request nach `main`, CI abwarten, dann Release (`de/tools/release.sh`).

## Regeln für Konflikte

- `README.md` und `FAQ.md` sind im Fork komplett deutsch und mit `merge=ours` geschützt (`.gitattributes`). Neues aus dem Original dort von Hand nachziehen.
- `admin/docs/*` (Englisch, Original) bleibt unverändert; Übersetzung liegt in `admin/docs-de/*`. Ändert das Original eine Doku, ändert sich nur die englische Datei, die deutsche muss nachgezogen werden.
- Konflikte in Quelltext: die Änderung des Originals übernehmen und unsere Anpassung (z. B. `DISTRIBUTION.*`, `t()`-Aufrufe) darüberlegen. Nie das Original-Verhalten stillschweigend verwerfen.
- Neue sichtbare Texte immer mit `t()` bzw. im Wörterbuch; JSX-Texte übersetzt das Babel-Plugin, Zeichenketten in Ausdrücken (`cond ? 'Text' : 'Text'`) brauchen `t('Text')`.

## Rhythmus

Bei jeder neuen Original-Version (Kontrolle: `git fetch upstream --tags && git tag --list 'v*' --sort=-v:refname | head -3`) einen Abgleich nach obigem Rezept.
Dieses Dokument danach um den neuen Stand ergänzen (Basis-Commit, Zahl der Commits, Konflikte, Besonderheiten).

## Offener Stand

- Abgleich mit v1.35.1 des Originals ist **noch nicht ausgeführt** (nur Probe). Aufwand: ein Konflikt, Wörterbuchprüfung, `docs-de` für Sprachen-Liste und Sprachauswahl, Translate-Image 0.1.1 bauen.
