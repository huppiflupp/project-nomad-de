# Teilprojekt A: Fork und Übersetzung

Stand: 2026-10-04 · Status: Entwurf zur Prüfung

## Gesamtvorhaben und Einordnung

Project NOMAD (Crosstalk Solutions, Apache-2.0) ist ein Offline-Wissensserver. Dieser Fork
`huppiflupp/project-nomad-de` macht daraus eine öffentliche deutsche Fassung für
Deutschsprachige. Das Gesamtvorhaben ist in vier Teilprojekte zerlegt, jedes mit eigener
Spezifikation, eigenem Plan und eigener Umsetzung:

| # | Teilprojekt | hängt ab von |
|---|---|---|
| **A** | **Fork und Übersetzung** (dieses Dokument) | – |
| B | Deutsche Inhaltskataloge: Wikipedia de als Standard, deutschsprachige Kiwix-Pakete, Karten DACH/Europa; US-Inhalte bleiben wählbar | A |
| C | Übersetzungsengine: Messvergleich Bergamot / MedGemma 4B / nexus-medical, Ausbau von `nomad-translate` (Zwischenspeicher, Tabellen, API, Medizin-Weiche, Zahlenabgleich, Kennzeichnung „maschinell übersetzt“) | A (Messung parallel möglich) |
| D | Deutsche Fachdienste: Arzneimittel/Medizin aus deutschen Quellen, Rückfall auf AT/CH, dann US-Dienste über C | B, C |

## Ziel von A

Nach A gibt es eine installierbare deutsche NOMAD-Fassung:

- **Oberfläche** vollständig auf Deutsch (Anrede **„Sie“**), Englisch umschaltbar.
- **Anleitungen** (`admin/docs/*.md`), README, FAQ und Meldungen der Install-Skripte auf Deutsch.
- **Eigene Images und Releases**: Installation, Updates und Kataloge kommen aus dem Fork,
  nicht von Upstream. Ein Update aus der Oberfläche darf die deutsche Fassung nie durch
  das englische Original ersetzen.
- Mit vertretbarem Aufwand **mit Upstream-Releases synchron** zu halten.

Nicht Teil von A: andere Inhalte (B), Übersetzung von Inhalten wie Artikeln oder FDA-Daten (C),
neue Dienste (D), Chinesisch oder weitere Sprachen. Der Mechanismus ist aber nicht auf Deutsch
festgelegt; weitere Sprachen wären nur ein weiteres Wörterbuch.

## 1. Repo, Zweige, Versionen

- GitHub-Fork `huppiflupp/project-nomad-de`, lokal `~/projects/project-nomad-de` auf ai395.
  Remote `upstream` = `Crosstalk-Solutions/project-nomad`.
- `main` ist die deutsche Fassung.
- **Abgleich nur bei Upstream-Releases** (`v1.35.0`, `v1.36.0` …): Zweig `sync/v1.36.0` von `main`,
  `git merge v1.36.0`, Konflikte lösen, Übersetzungsprüfung (Abschnitt 4.6) und Tests grün,
  dann Merge nach `main` und Release.
- **Versionen** `v<upstream>-de.<n>`, z. B. `v1.35.0-de.1`. Die Basis-Version bleibt erkennbar,
  `n` zählt eigene Releases auf dieser Basis.
- **Fork-eigene Dateien liegen in `de/`** (Wörterbücher, Werkzeuge, Spezifikationen, Pläne),
  damit Upstream-Merges sie nie berühren. Eingriffe in Upstream-Dateien werden klein und
  gebündelt gehalten.
- Dateien, die der Fork komplett ersetzt (README.md, FAQ.md), bekommen in `.gitattributes`
  `merge=ours`, damit sie bei jedem Abgleich nicht kollidieren. Die englischen Originale
  bleiben über Upstream erreichbar, README verlinkt sie.
- Ausgangsbasis: Upstream `main` am 2026-10-04 (`5e1702e`, `v1.35.0` + 2 Commits zu Katalog-URLs).

## 2. Umstellung von Crosstalk auf den Fork

Neue Datei `admin/constants/distribution.ts` als einzige Stelle für die Herkunft:

```ts
export const DISTRIBUTION = {
  repo: 'huppiflupp/project-nomad-de',     // Releases, Kataloge, Install-Skripte
  registry: 'ghcr.io/huppiflupp',         // eigene Images
  rawBase: 'https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main',
  mapsRepo: 'Crosstalk-Solutions/project-nomad-maps', // bis Teilprojekt B unverändert
  upstreamRepo: 'Crosstalk-Solutions/project-nomad',  // für Hinweise „basiert auf“
}
```

Umgestellt werden (Stand Upstream `5e1702e`):

| Stelle | heute |
|---|---|
| `admin/app/services/collection_manifest_service.ts:32-35` | Kataloge von Crosstalk |
| `admin/app/services/zim_service.ts:47` | Wikipedia-Katalog |
| `admin/app/services/system_service.ts:691,698` | Release-/Update-Prüfung |
| `admin/app/services/kiwix_catalog_service.ts:29` | Karten-API (bleibt `mapsRepo`) |
| `install/install_nomad.sh`, `install/run_updater_fixes.sh` | Download von Skripten/Compose |
| `install/management_compose.yaml`, `install/migrate-disk-collector.sh` | Image-Namen |
| `.github/workflows/build-*.yml` | Ziel-Registry |
| `.github/ISSUE_TEMPLATE/config.yml` | Links auf Issues/Sicherheitsmeldungen |

Shell- und YAML-Dateien können die TS-Konstante nicht lesen; dort wird umgeschrieben, und die
Prüfung `de/tools/check-distribution.sh` schlägt fehl, sobald irgendwo außerhalb von `de/`,
Doku und Tests noch `Crosstalk-Solutions/project-nomad` (ohne `-maps`) oder
`ghcr.io/crosstalk-solutions` steht. Sie läuft in CI und nach jedem Abgleich.

Fremd-Images (Kiwix, Ollama, CyberChef, Qdrant …) bleiben unverändert.

**Auftritt:** Name „Project NOMAD – Deutsche Fassung (inoffiziell)“. README, Fußzeile und
Über-Seite verweisen auf Original und Crosstalk Solutions. Lizenz Apache-2.0 bleibt; eine
`NOTICE`-Ergänzung nennt die Änderungen des Forks.

## 3. Sprachwahl

- Sprachen: `de` (Standard) und `en`.
- Gespeichert im Cookie `nomad_lang`, gesetzt über einen Umschalter in der Kopfzeile und in den
  Einstellungen. Ohne Cookie gilt `de`, unabhängig von der Browsersprache: Wer die deutsche
  Fassung installiert, will Deutsch.
- Ein Wechsel lädt die Seite neu. Ein Umschalten ohne Neuladen ist nicht nötig.
- `<html lang>` folgt der Sprache (Edge-Vorlage in `admin/resources/views`).

## 4. Übersetzungsmechanismus

### 4.1 Wörterbuch

- `de/i18n/de.json`: Schlüssel = **englischer Originaltext**, Wert = deutscher Text. Platzhalter
  `{0}`, `{1}` für eingesetzte Werte. Ein Wörterbuch für Oberfläche und Server.
- `de/i18n/catalog.de.json`: Texte aus den Inhaltskatalogen (Abschnitt 6), getrennt, weil sie sich
  unabhängig vom Code ändern.
- Startbestand: die 2.110 Einträge aus `huppiflupp/project-nomad-fedora/i18n/de.json`
  (18.09.2026), maschinell von „du“ auf „Sie“ umgestellt und von Hand nachgesehen.
- `en` braucht kein Wörterbuch (Schlüssel = Text).
- Fehlt ein Eintrag, erscheint der englische Text. Es gibt nie eine leere Stelle oder einen
  Schlüssel wie `settings.save`.

### 4.2 Oberfläche: automatisch zur Bauzeit

Ein Babel-Plugin `de/build/babel-plugin-i18n.mjs`, eingebunden über `@vitejs/plugin-react`
(`babel.plugins`) in `admin/vite.config.ts`, schreibt beim Bauen um:

- JSX-Text: `<p>Save changes</p>` → `<p>{__t("Save changes")}</p>`
- String-Attribute `placeholder`, `title`, `aria-label`, `alt`, `label`, `description`,
  `helperText` an JSX-Elementen.
- Ausdrücke mit gemischtem Text und Werten innerhalb eines Elements (`Deleted {count} files`)
  werden zu `__t("Deleted {0} files", count)`.

`__t` (in `de/i18n/runtime.ts`) liest die Sprache einmal beim Start aus dem Cookie und schlägt im
mitgebündelten Wörterbuch nach; normalisiert wird wie im alten `extract.js` (Leerraum
zusammenziehen, trimmen). Das Wörterbuch wird zur Bauzeit importiert, also kein Nachladen und
kein englisches Aufblitzen.

Leerer Text, reine Zahlen/Symbole und Inhalte in `<code>`, `<pre>`, `<kbd>` werden übersprungen.

### 4.3 Oberfläche: von Hand markiert

Was das Plugin nicht sieht, wird in Upstream-Dateien mit `t()` aus `de/i18n/runtime.ts` markiert:

- Strings außerhalb von JSX: `addNotification({ message: '…' })` (114 Aufrufe), Spalten- und
  Menü-Definitionen in `admin/constants` und `admin/inertia/lib` (~22 Felder), `confirm()`-Texte,
  Template-Literale.
- Seitentitel (`<Head title=…>`).

Das sind die einzigen flächigen Eingriffe in Upstream-Code. Jede Markierung ist eine kleine
Änderung pro Zeile; Konflikte lassen sich beim Abgleich durch erneutes Markieren lösen.

### 4.4 Server

- Middleware liest `nomad_lang` und legt die Sprache in den `HttpContext`.
- `t()` serverseitig (gleiches Wörterbuch) für Meldungen, die in der Oberfläche landen:
  `message:`-Antworten in Controllern/Services (~110 Stellen), Fehlermeldungen von Jobs, die per
  Transmit an die Oberfläche gehen.
- VineJS-Validierung bekommt deutsche Standardmeldungen über einen `messagesProvider`.
- Log-Ausgaben bleiben englisch (für Fehlerberichte an Upstream).

### 4.5 Was bewusst englisch bleibt

Log-Ausgaben, API-Feldnamen, Kommandozeilen-Beispiele in Codeblöcken, Namen fremder Dienste
(Kiwix, Ollama, CyberChef), Inhalte (Artikel, ZIM-Titel; das ist Teilprojekt C), Antworten des
KI-Chats (die Sprache bestimmt das Modell; der Systemprompt wird in A auf „Antworte auf Deutsch“
erweitert, wenn `de` aktiv ist).

### 4.6 Wartung: Extraktion und Prüfung

`de/tools/i18n.mjs` (Weiterentwicklung von `extract.js`) mit zwei Befehlen:

- `extract`: sammelt alle Texte, die das Plugin übersetzen würde, plus alle `t()`-Aufrufe in
  Oberfläche und Server.
- `check`: meldet Texte ohne deutschen Eintrag, verwaiste Einträge und Platzhalter-Fehler
  (`{0}` fehlt oder ist zu viel). Exit-Code ≠ 0 bei fehlenden Einträgen.
- Zusätzlich als Warnung: englische `message:`-/`addNotification`-Strings ohne `t()`
  (Heuristik), damit neue Upstream-Stellen auffallen.

`check` läuft in CI bei jedem Push und ist Pflicht auf `sync/*`-Zweigen.

## 5. Anleitungen und Repo-Dokumente

- `admin/docs/de/*.md`: alle 11 Anleitungen übersetzt (`about`, `api-reference`,
  `community-add-ons`, `drug-reference`, `faq`, `getting-started`, `home`, `release-notes`,
  `supply-depot-apps`, `updates`, `use-cases`).
- `DocsService` (`admin/app/services/docs_service.ts`) liest bei `de` aus `docs/de/` und fällt
  pro Datei auf `docs/` zurück, wenn es keine deutsche Fassung gibt. Der Pfadschutz gegen
  Traversal bleibt.
- Die Wissensdatenbank liest beim ersten Start `admin/docs/*.md` ein
  (`admin/app/services/rag_service.ts:2067`). Bei `de` liest sie die deutschen Fassungen ein.
- `release-notes.md`: Die Upstream-Notizen bleiben englisch, darüber steht ein deutscher
  Abschnitt mit den Änderungen des Forks.
- Screenshots (`admin/public/docs/*.webp`) bleiben vorerst englisch. Deutsche Screenshots kommen
  nach der ersten lauffähigen Fassung (Abschnitt 8, letzter Schritt).
- Repo-Wurzel: `README.md` deutsch (mit Installationsbefehl des Forks, Hinweis „inoffiziell“,
  Link zum Original), `FAQ.md` deutsch, beide `merge=ours`. `CONTRIBUTING.md`,
  `CODE_OF_CONDUCT.md`, `SECURITY.md`: kurze deutsche Fassung mit Verweis auf das Original.
- Den Abgleich der Anleitungen bei neuen Releases übernimmt ein Werkzeug
  `de/tools/docs-diff.sh`: Es zeigt, welche englischen Anleitungen sich seit dem letzten
  Abgleich geändert haben, damit die deutschen nachgezogen werden.

## 6. Inhaltskataloge

Die Kataloge (`collections/*.json`) werden zur Laufzeit aus dem Fork geladen (Abschnitt 2). Ihre
Namen und Beschreibungen werden **nicht in den JSON-Dateien** übersetzt, sondern beim Laden
serverseitig über `catalog.de.json` (in `collection_manifest_service.ts` und `zim_service.ts`).
So bleiben die JSON-Dateien identisch zu Upstream und konfliktfrei, und neue Upstream-Einträge
erscheinen sofort, zunächst englisch, bis `check` den fehlenden Eintrag meldet.

Andere Inhalte in den Katalogen sind Teilprojekt B.

## 7. Install-Skripte

- `install/install_nomad.sh`, `update_nomad.sh`, `start_nomad.sh`, `stop_nomad.sh`,
  `uninstall_nomad.sh`, `run_updater_fixes.sh`, `migrate-disk-collector.sh`: Meldungen und
  Rückfragen direkt auf Deutsch umgeschrieben (rund 130 `echo` allein im Installer).
  Eine Sprachweiche in Bash wäre Aufwand ohne Nutzen. Wer Englisch will, nimmt das Original.
- Befehle, Pfade, Variablen und Logik bleiben unverändert, damit Merges nur Textzeilen betreffen.
- Installation: `curl -fsSL https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/install_nomad.sh | sudo bash`

## 8. Bauen, Veröffentlichen, Testen

**CI/Images**
- Die vorhandenen Workflows `build-primary-image`, `build-sidecar-updater`,
  `build-disk-collector`, `build-translate-proxy` und `build-admin-on-pr` bauen nach
  `ghcr.io/huppiflupp/project-nomad-de` bzw. `…-de-sidecar-updater`, `…-de-disk-collector`,
  `…-de-translate`. Die Images sind öffentlich.
- `release.yml` (semantic-release, nur für Crosstalk-Berechtigte) wird ersetzt durch einen
  Workflow, der beim Tag `v*-de.*` baut und ein GitHub-Release mit deutschen Notizen anlegt.
- Neuer Job: `i18n check` und `check-distribution.sh`.
- `validate-collection-urls.yml` bleibt.

**Tests**
- Unit-Tests (vorhandenes Japa-Setup unter `admin/tests/unit`) für: Babel-Plugin (Eingabe-JSX →
  Ausgabe), `__t`/`t` (Platzhalter, Rückfall), Sprach-Middleware, `DocsService`-Rückfall,
  Katalog-Übersetzung.
- Alle vorhandenen Upstream-Tests bleiben grün.
- **Sichtprüfung im Browser:** Ein Playwright-Skript `de/tools/crawl-untranslated.mjs` öffnet alle
  Seiten (Startseite, Easy Setup, alle Settings-Seiten, Docs, Karten, Chat, Supply Depot …) und
  listet sichtbaren Text, der im englischen Wörterbuch als Schlüssel ohne Übersetzung vorkommt
  oder typisch englisch ist. Ergebnis: Liste mit Seite und Text.
- **Testumgebungen:**
  - Entwicklung und schnelle Läufe lokal auf ai395 (Docker vorhanden; das pausierte NOMAD unter
    `/home/seeas/nomad` bleibt unberührt, Testinstanz mit eigenen Ports und eigenem Verzeichnis).
  - **Frische Installation auf x9** (Ubuntu 24.04, der von NOMAD vorgesehene Unterbau): über den
    Installationsbefehl aus Abschnitt 7, einschalten und ausschalten per IPMI.
  - 245k (Nobara + NVIDIA), wenn er frei ist: Installation mit GPU für den KI-Chat.
- Zum Abschluss deutsche Screenshots für die Anleitungen.

## 9. Abnahme

A ist fertig, wenn:

1. Auf x9 eine frische Installation über den Befehl des Forks durchläuft, mit deutschen Meldungen,
   und nur Images aus `ghcr.io/huppiflupp` und Fremd-Images zieht.
2. `i18n check` ohne fehlende Einträge durchläuft und der Browser-Crawl auf keiner Seite
   englische Oberflächentexte findet (Ausnahmen nach 4.5 dokumentiert).
3. Alle 11 Anleitungen auf Deutsch erscheinen; Umschalten auf Englisch zeigt die Originale.
4. Die Update-Prüfung in der Oberfläche das Fork-Release meldet und ein Update auf eine
   Testversion `-de.2` die deutsche Fassung behält.
5. `check-distribution.sh` grün ist.
6. Ein Probe-Abgleich mit dem nächsten Upstream-Release (oder ersatzweise `main` von Upstream)
   dokumentiert ist: Dauer, Zahl der Konflikte, Vorgehen in `de/SYNC.md`.

## Risiken

- **Upstream baut eigenes i18n ein.** Dann wird das Plugin überflüssig, das Wörterbuch nicht:
  die Einträge lassen sich auf deren Schlüssel umziehen. Vor jedem Abgleich prüfen.
- **Plugin übersetzt zu viel** (z. B. ein Text, der als Wert weiterverarbeitet wird statt
  angezeigt). Gegenmittel: Liste ausgenommener Komponenten/Dateien im Plugin, Unit-Tests,
  Crawl.
- **Upstream baut Seiten aus Datenstrukturen statt JSX-Text.** Dann wachsen die `t()`-Stellen;
  `check` mit der Heuristik aus 4.6 macht das sichtbar.
- **Namensrechte:** „Project NOMAD“ gehört Crosstalk Solutions. Der Fork tritt klar als
  inoffiziell auf; verlangt Upstream eine Umbenennung, ist sie auf README, Fußzeile und
  `distribution.ts` begrenzt.
