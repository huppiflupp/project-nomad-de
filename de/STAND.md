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
