# Stand der deutschen Fassung

## Ausgangslage (Upstream 5e1702e, 2026-10-04, ai395, Node 22.23.2)

- `npm run test:unit`: 608 Tests, 598 bestanden, **10 fehlgeschlagen bereits im Upstream-Stand** (gelten nicht als Regression):
  app_auto_update, content_auto_update, content_auto_update_backoff, custom_app_guard, drug_ingest_status,
  drug_interactions, drug_labels, ollama_controller_chat, ollama_done_reason, rag_retrieval_toggle (`tests/unit/*.spec.ts`).
- `npm run typecheck` (Server): fehlerfrei.
- `npx tsc --noEmit -p inertia` (Oberfläche): **35** `error TS` im Upstream-Stand (Ausgangswert; neue Fehler darüber sind Regressionen).

## Review Focus 2 (Task 5)

Frage: Gehen Felder aus `CATALOG_KEYS` (`name`, `title`, `description`, `label`, `friendly_name` …), die der
Browser-Interceptor übersetzt, als Kennung/Wert an den Server zurück? Geprüft: alle `api.ts`-Methoden mit Body/Params
und ihre Aufrufer (easy-setup, settings/zim, settings/maps, settings/models, settings/apps, supply-depot, home, chat/CollectionsManager).

Kennungen, die **nicht** betroffen sind (sie laufen über Schlüssel außerhalb von `CATALOG_KEYS`):
- Dienste: `service_name` (apps.tsx:87/133/156/193, supply-depot.tsx:215, home.tsx:141, easy-setup/index.tsx:422).
- Kategorien/Stufen/Kartensammlungen: `slug` (maps.tsx:130, easy-setup/index.tsx:429/433, remote-explorer.tsx:391).
- Wikipedia-Optionen: `id` (remote-explorer.tsx:426, easy-setup/index.tsx:443).
- Content-Updates: `resource_id`/`download_url` (ResourceUpdateInfo, ContentUpdatesSection.tsx:42/72).
- Wissenssammlungen (RAG): Namen sind `string[]` ohne Schlüssel, werden nicht übersetzt (CollectionsManager.tsx:32/44).

Felder `name`, die als Kennung zurückgehen, aber Dateinamen/Modell-Tags sind (kein Katalogtext, Treffer nur bei exaktem
Katalogeintrag, derzeit praktisch ausgeschlossen; Katalog ist beim Stand dieses Tasks noch leer):
- ZIM-/Karten-Dateinamen: zim/index.tsx:107 (`deleteZimFile(file.name…)`), maps.tsx:159 (`deleteMapRegionFile(file.name)`).
- Ollama-Modell-Tags: models.tsx:465/637, easy-setup/index.tsx:1092 -> `downloadModel`/`deleteModel`.
- Eigene Bibliothek: remote-explorer.tsx:880 (`dir.name` nur Anzeige, URL wird gesendet), :364 (`file.url`).
Restrisiko: Falls künftig Katalogeinträge mit Wortlaut eines Dateinamens/Modell-Tags angelegt werden, müssen diese Aufrufe
mit `skipLocalize` versehen werden.

Echter Rückläufer: `listRemoteZimFiles` (api.ts) -> `title`/`summary`/`author` des Eintrags werden in
remote-explorer.tsx:350-355 per `downloadRemoteZimFile` als gespeicherte Metadaten zurückgeschickt (zim_controller.ts:39).
Maßnahme: dieser Aufruf trägt `{ skipLocalize: true }`, der Interceptor überspringt ihn (`response.config.skipLocalize`).
Fremde Kiwix-Titel sind ohnehin kein Katalogtext; die Anzeige braucht dort kein `tc(…)`.

## Texte (Task 6)

`node i18n/cli.mjs check` (aus `admin/`), Wörterbücher noch leer:
- Oberfläche: 1285 Texte, Server: 394, Kataloge: 401.
- fehlend 2080 (Summe abzüglich Überschneidungen), Platzhalter-Fehler 0, verwaist 0; Exit 1 wie erwartet.
- Parser-Plugins je Endung (`.ts`: typescript, `.tsx`: jsx+typescript); keine Datei nicht lesbar.

## Sichtprüfung (Task 15)

Testinstanz `de/dev/compose.yml` (Port 18080, ohne Docker-Socket), Crawl `de/tools/crawl/crawl.mjs` über 36 Seiten
(alle Oberflächenrouten aus `admin/start/routes.ts`, alle 11 Anleitungen, eine 404-Seite). Ergebnis Deutsch:
außerhalb der Liste unten keine englischen Texte. Gegenprobe Englisch (`LANG=en`): keine deutschen Texte.
Nicht prüfbar ohne Docker-Socket: `/chat` (404 ohne installierten KI-Assistenten) und Dialoge laufender Apps –
dort per Codedurchsicht geprüft.

### Bewusst englisch

- **Versionshinweise** (`docs-de/release-notes.md`): deutscher Abschnitt vorangestellt, ältere Einträge englisch
  (siehe `de/tools/docs-check.mjs`).
- **Fremde Oberflächen und Meldungen in Anleitungen**: Menüpunkte anderer Programme in Anführungszeichen
  („Install third-party drivers …“ im Ubuntu-Installer, „Open from computer“, **Save**, **Location of Calibre
  Database** in Stirling/Calibre-Web), App-Namen (File Browser, IT Tools), Fehlermeldungen als Überschrift
  (`ERROR: Failed to load the XML library file …` in der FAQ).
- **Ollama-Modellkatalog** (Einstellungen → KI-Assistent): Beschreibungen und Altersangaben („1 year ago“)
  kommen von ollama.com.
- **Kiwix-Katalog** (Inhalts-Explorer): Titel, Zusammenfassungen und Kategorien der ZIM-Dateien (Inhalte,
  Teilprojekt C).
- **Namen der US-Kartenregionen** (Pacific Region …) im Kartenkatalog: Eigennamen, so im Katalog belassen.
- **Builder-Tag-Wörter** (`inertia/lib/builderTagWords.ts`): Teil des öffentlichen Benchmark-Namens.
- **Theme-Namen** „Day Ops“/„Night Ops“: Markenbegriffe der Oberfläche (so im Wörterbuch festgelegt).
- **Tastennamen/Werte** im Code (`Enter`, `Escape`, `Manual`, `Always`): keine Anzeige.
- **Selten angezeigte Zusätze** in Servermeldungen, die als Textverkettung gebaut werden und deshalb nicht ganz
  passen: Hinweis „N files failed to dispatch …“ nach Neu-Einbetten/Neuaufbau und die Bereinigungsnotiz der
  Wissensdatenbank-Prüfung („; purged N orphaned sources …“). Der Hauptsatz ohne Zusatz ist übersetzt.
- **Browser-Netzwerkfehler** („Failed to fetch“) und Upstream-Entwicklerfehler (`useModal must be used within …`).

### Schlüssel ohne Fundstelle (verwaist, gewollt)

`node i18n/cli.mjs check` meldet 39 verwaiste Einträge. Sie werden zur Laufzeit dynamisch nachgeschlagen und vom
Sammler nicht gesehen: Statusmeldungen des Update-Sidecars (`install/sidecar-updater/update-watcher.sh`,
`write_status`), Hinweise aus `inertia/lib/vision_guidance.ts` und `kb_file_grouping.ts` (per `tm` angezeigt),
`HTTP error: {0}`, die Bild-Fehlermeldung aus `ollama_controller.ts`, Voreinstellungen aus `constants/ollama.ts`
(Relevanz, Antwortstil), die Ergebnismeldungen von Neu-Einbetten/Neuaufbau in `rag_service.ts` (Textverkettung), Spaltenköpfe aus Tabellenschlüsseln (`Author`, `Source`, `Updated`) und
Seitenleisten-Einträge (`Service Logs & Metrics`, `API Reference`).

## Abschlussprüfung (Final-Review)

- **Absichtlich deutsch an das Modell:** Die Chat-Hilfsprompts in `ChatInterface.tsx` (`CONTINUE_PROMPT`
  „Continue exactly where you left off …“ und „Describe the attached image.“ bei Bild ohne Text) laufen durch `t()`
  und gehen in der Sprache der Oberfläche an das Modell. Ebenso wird der Standardtitel neuer Chats („New Chat“ →
  „Neuer Chat“) beim Anlegen gespeichert; danach ist er Nutzerdaten und wird nicht mehr übersetzt.
- **Nutzerdaten bleiben unübersetzt:** `tc()` (Katalogfelder `name`, `title`, `description` …) übersetzt nur noch bei
  exaktem Treffer in `catalog.de.json` – keine Oberflächen-Wörter, keine Platzhalter-Muster. Eigene Apps und
  Link-Kacheln (`is_custom`/`is_link_tile`) und Markdoc-Bäume der Anleitungen (`$$mdtype`) überspringt
  `localizeData` ganz; Chat-Sitzungen, Kartenmarker, eigene Bibliotheken und `getCustomApp` laden mit `skipLocalize`.
- **Seitenwechsel ohne Neuladen:** Inertia 2 holt Folgeseiten über die Standard-Axios-Instanz (`responseType: "text"`);
  `inertia/app/app.tsx` übersetzt deren `props` per Interceptor wie die der ersten Seite.
- **Sätze mit Bedingungen:** Das Babel-Plugin fasst Kinder nur zu einem Satzschlüssel zusammen, wenn jeder Ausdruck
  ein schlichter Wert ist (kein `&&`, kein JSX, keine Boolean-Zweige). Plural-Bruchstücke (`file{s}`) sind als ganze
  Sätze je Anzahl gebaut; die englische Ausgabe ist unverändert.
- **CI** (`.github/workflows/de-checks.yml`) führt nur die Tests `tests/unit/i18n_*.spec.ts` aus; die übrigen
  Upstream-Tests laufen lokal mit `npm run test:unit` (10 bekannte Upstream-Fehlschläge, siehe oben).
- **Crawl erweitert:** meldet zusätzlich gerenderte Werte (`false`, `undefined`, `null`, `NaN`, `[object Object]`;
  ausgenommen die Versionshinweise), klickt sich durch die Einstellungs-Seitenleiste (Inertia-Navigation, mit
  Prüfung, dass nicht neu geladen wurde) und den Schnellstart bis zur Prüfseite. Ergebnis 2026-10-04: 0 gerenderte
  Werte in Deutsch und Englisch, alle Klick-Seiten deutsch.
