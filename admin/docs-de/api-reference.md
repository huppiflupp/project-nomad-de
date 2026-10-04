# API-Referenz

NOMAD stellt für alle Vorgänge eine REST-API bereit. Alle Endpunkte liegen unter `/api/` und liefern JSON.

---

## Interaktive Referenz

Die vollständige, stets aktuelle Endpunkt-Referenz wird direkt aus den Routen und Validatoren der
Anwendung erzeugt und als interaktive [Scalar](https://scalar.com)-Oberfläche bereitgestellt:

- **[/reference](/reference)** – alle Endpunkte, Anfrage-/Antwortschemata durchsuchen und Aufrufe live ausprobieren
- **[/api/openapi.json](/api/openapi.json)** – das rohe OpenAPI-3.1-Dokument (Import in Postman, Insomnia, Codegeneratoren usw.)

Da sie aus denselben VineJS-Validatoren abgeleitet ist, gegen die die API prüft, weicht sie nie
von der Implementierung ab. Nutzen Sie sie bevorzugt statt jeder handgeschriebenen Endpunktliste.

---

## Konventionen

**Basis-URL:** `http://<your-server>/api`

**Antworten:**
- Erfolgsantworten enthalten `{ "success": true }` und einen HTTP-2xx-Status
- Fehlerantworten liefern den passenden HTTP-Status (400, 404, 409, 500) mit einer Fehlermeldung
- Lang laufende Vorgänge (Downloads, Benchmarks, Einbettungen) liefern 201 oder 202 mit einer Job- bzw. Benchmark-ID zum Abfragen

**Asynchrones Muster:** Job absenden → ID erhalten → einen Status-Endpunkt abfragen, bis der Vorgang abgeschlossen ist.
