# Übersetzung Englisch → Deutsch: Messung (Teilprojekt C), 2026-10-09

Frage: Wie gut übersetzt der in NOMAD eingebaute Dienst (Bergamot, `install/nomad-translate`) Notfall- und Medizintexte, und lohnt ein Sprachmodell?

Testmaterial: `texte.json`, zehn englische Absätze (Wasser, Blutung, Unterkühlung, Lebensmittel, Kohlenmonoxid, Paracetamol, Verbrennung,
Austrocknung, Funk, Verstauchung) im Stil von CDC, NHS und Ready.gov, mit amerikanischen Einheiten (Fuß, Zoll, Gallone, °F).
Rohergebnisse: `ergebnis-*.json`. Skripte: `bergamot_lauf.py` (im Container `ghcr.io/crosstalk-solutions/project-nomad-translate:0.1.1`),
`llm_lauf.py` (OpenAI-kompatibler Server), `zahlen_pruefen.py`. Die Modelle (`modelle/`, 71 MB) sind nicht im Git.
Beurteilung der Texte: Durchsicht durch die Autorin/den Autor dieses Dokuments (Claude), keine unabhängige Prüfung durch Fachleute.

## Ergebnis

| | Bergamot (en→de, 37 MB, CPU) | Qwen3.6-35B-A3B (llama.cpp, ai395) |
|---|---|---|
| Tempo | **856 Wörter/s** (481 Wörter in 0,56 s) | 24,5 Wörter/s |
| Zahlen der Vorlage erhalten | **2 von ~60 fehlen** (Verstauchung: „15 bis 20 Minuten“ verloren) | alle erhalten |
| Fachsprache, Grammatik | mehrere Fehler (siehe unten) | gut; Genusfehler („einen Gallone“, „sterilen Gaze“) |
| Einheiten | unverändert (Fuß, °F, Gallone) | unverändert oder mit metrischer Ergänzung in Klammern (alle Umrechnungen stimmten) |
| Anspruch | 0,3 GB, läuft auf jedem PC | ≥ 8 GB Arbeitsspeicher, besser GPU |

Auffällige Fehler von Bergamot (teils sachlich relevant): „… oder **brennen Sie auf** Gesicht, Händen …“ (statt Verbrennungen im Gesicht), „Antihaft-**Abricht**“,
„**handgeknacktes** Radio“ (Handkurbelradio), „Ruhe, Eis, Kompression und **Höhe**“ (Hochlagern), „Anzeichen sind **zitternd**“, „Schmerzen und Schmerzen“,
„alle zwei bis drei Stunden alle zwei bis drei Stunden“, „Lassen Sie … niemals länger als zwei Stunden …“ ohne Verb (unvollständig), „Platziere“ (du-Form in Sie-Text),
„Nehmen Sie nicht mehr als 8 Tabletten“ blieb richtig. Qwen im wörtlichen Modus übersetzte „cool water“ als „lauwarm“ (Fehler); im Modus mit metrischer Ergänzung „kühl“.
Beide Systeme übernehmen US-spezifische Inhalte unverändert (NOAA-Frequenzen), das ist ein Inhaltsproblem, kein Übersetzungsproblem.

## Folgerungen

1. **Bergamot bleibt der Standard** (Geschwindigkeit, läuft überall), aber mit **Warnhinweis „maschinell übersetzt, bei Medizin und Sicherheit das Original prüfen“** und
   **Zahlenprüfung** (umgesetzt: `install/nomad-translate/de_zusatz.py`). Die Prüfung markiert im Test genau den Absatz, in dem Zahlen fehlten, und keinen der neun anderen.
2. **Sprachmodell als Option „Qualitätsübersetzung“** für ausgewählte Seiten (Medizin, Sicherheit), wenn der KI-Assistent läuft: etwa 25 Wörter/s, also eine Seite von 1000 Wörtern in
   rund 40 s; Ergebnisse zwischenspeichern. Noch nicht umgesetzt (Plan: `de/specs/2026-10-09-teilprojekte-b-bis-d.md`).
3. Weitere Prüfungen, die sich lohnen und billig sind: Sie-Form-Prüfung der Ausgabe (ein „Platziere“ fiel auf), Verb-fehlt-Erkennung ist schwer; Bergamot liefert Wort-Vertrauenswerte
   (`x-bergamot-word-score`), die aktuell verworfen werden.
4. Testmaterial ausbauen (50 Absätze, echte ZIM-Seiten CDC/NHS), erst dann Entscheidungen über LLM-Standard treffen.
