# Notfall-KI: Messung (Phase 4, Schritt 1–2)

Stand 2026-10-09. NOMAD 1.35.1 (Weg-1-Testrechner, VM `nomad-de-ubuntu` auf x9), Ollama 0.33.3 in NOMAD, Embedding `nomic-embed-text:v1.5`.
Rohdaten der Modellmessung: `notfall-ki-rohdaten-245k-cpu.txt`.

## Frage 1: Nutzt die KI die per Kiwix geladenen Inhalte?

**Ja, aber nur nach ausdrücklicher Indexierung, und nur für ZIMs mit HTML-Text.**

- NOMAD zerlegt ZIM-Dateien in Textstücke und legt sie in Qdrant ab (`ZIMExtractionService`, `RagService`). Standard im Chat: Banner
  „Ihre N vorhandenen Dateien für KI-Assistent indizieren?“ mit Knopf **Vorhandene Inhalte indizieren** (Richtlinie `Manual`; ZIMs stehen
  bis dahin auf `pending_decision`). Ein Klick startet **alles** sofort, ohne Hinweis auf Dauer oder Größe.
- Die deutschen NOMAD-Docs (`docs-de`, 12 Dateien) sind indexiert (laut NOMAD automatisch nach der KI-Installation); der Chat nennt dann Quellen.
- Gemessen an den sechs Medizin-ZIMs des Testrechners (Zeile „indexed“ = fertig):

| ZIM | Größe | Ergebnis |
|---|---:|---|
| `wikipedia_en_100_mini` | 4,5 MB | **1364 Chunks**, 4,7 min (Test-VM) |
| `fas-military-medicine` | 81 MB | **1 Chunk** (PDF-Buch-ZIM, kaum Text extrahiert) |
| `zimgit-medicine` (Medical Library) | 70 MB | **2 Chunks** (ebenso) |
| `wwwnc.cdc.gov` | 178 MB | läuft; 13 % nach ~20 min (abgebrochen) |
| `nhs.uk medicines` | 17 MB | läuft (abgebrochen) |
| `wikipedia_en_top_mini` | 331 MB | nicht begonnen |

**Befund:** PDF-basierte ZIMs (u. a. Military Medicine, Medical Library) sind für die KI praktisch unsichtbar. In Kiwix bleiben sie lesbar.

### Indexierungsdauer (nur Text-ZIMs)

- Test-VM (4 vCPU Xeon E5-2697 v2, kein AVX2, 8 GB): ≈ **1 min je MB ZIM** (Wikipedia-100: 4,5 MB → 4,7 min; CDC 178 MB → ≈ 3 h).
- Embedding-Rate bei 16 Texten à ≈ 600 Token: VM 0,6 Chunks/s, 245k (Ultra 5 245K, nur CPU) 1,7 Chunks/s → modernes Desktop-CPU ≈ **2,8× schneller**,
  also grob **20 s je MB**. Eine GPU wurde nicht gemessen.
- Beispiel „Medizin Essential“ (HTML-Teil ≈ 525 MB: CDC, NHS, Wikipedia Top-Mini): alter PC ≈ 9 h, moderner Desktop ≈ 3 h.
- Die Indexierung belegt die CPU voll; ein Chat währenddessen lief in einen Serverfehler (HTTP 500 nach 307 s). **Nicht gleichzeitig chatten.**

## Frage 2: Welche Modelle auf welcher Hardware?

Messrechner 245k (Intel Core Ultra 5 245K, 14 Kerne, **nur CPU**, Ollama im Container, `num_ctx` 4096, 3 deutsche Fragen, Temperatur 0,2).
Tempo = erzeugte Token je Sekunde; Prompt = Verarbeitung von ≈ 1900 Token Kontext (so viel liefert die Wissenssuche etwa mit).

| Modell | Größe | Prompt (Token/s) | Antwort (Token/s) | Deutsch-Qualität, Erste Hilfe / Wasser |
|---|---:|---:|---:|---|
| `qwen3:1.7b` | 1,4 GB | 129 | 26 | **gefährlicher Unsinn** („Blut in Plastikbeutel sammeln“, „Salz ins Wasser“) |
| `llama3.2:3b` | 2,0 GB | 71 | 16 | brauchbar, ungenau (Kochdauer 10–15 min, „Wunde nicht reinigen“) |
| `gemma3:4b` | 3,4 GB | 62 | 15 | gut (Druckverband, Hochlagern, 112); Wassermenge zu hoch (3–4 l) |
| `qwen3:4b` | 2,5 GB | 52 | 12 | denkt laut **auf Englisch**, Antwort unbrauchbar (Denkmodus ließ sich nicht abschalten) |
| `qwen3:8b` | 5,2 GB | 29 | 7 | gut; schlägt Jod/Chlor vor; langsam |
| `gemma4:e4b` | 6,6 GB | 50 | 14 | **am besten**: korrekt, „Sie“-Form, 112, Fremdkörper nicht entfernen, 2–3 l |

Test-VM (alter Xeon, 4 vCPU): `gemma3:4b` brauchte für **eine Frage mit 2000 Token Kontext 205 s nur für den Kontext** (≈ 10 Token/s), eine Chat-Antwort
etwa 2–5 min. Dort ist die KI zum Ausprobieren nutzbar, im Notfall zu langsam.

**Beispiel für Fehlantwort mit Quelle (Screenshot `ki09-chat-antwort`):** Frage „Wie viel Plattenplatz braucht NOMAD?“ an `gemma3:4b` mit Wissensdatenbank an.
Antwort: „Die App benötigt keinen lokalen Festplattenspeicher … Funkgerät …“, Quelle `faq.md` wird angezeigt, der Inhalt stimmt nicht.
→ Angezeigte Quelle ≠ richtige Antwort; Handbuch warnt.

### Empfehlung für das Handbuch

| Rechner | Modell | Hinweis |
|---|---|---|
| ≤ 8 GB RAM, alt, ohne GPU | `gemma3:4b` (3,4 GB) | langsam; nur für kurze Fragen |
| 16 GB RAM, moderne CPU | `gemma4:e4b` (6,6 GB) | ≈ 14 Token/s, Prompt ≈ 50 Token/s |
| NVIDIA-GPU ≥ 8 GB | `gemma4:e4b` oder größer | nicht gemessen |
| nicht verwenden | `qwen3:*`, `qwen3:1.7b` | Denkmodus auf Englisch / unsinnige Antworten |

## Weitere Befunde (Oberfläche)

- `NOMAD.md` (Systemprompt-Vorlage) ist komplett **englisch** (`ki11-nomad-md-englisch`). Für deutsche Antworten wäre eine deutsche Vorlage nötig („Antworte immer auf Deutsch, Sie-Form, …“).
- Dropzone der Wissensdatenbank: „Drop files here or browse files“ (Bibliotheksstring, nicht übersetzt).
- Modellliste: Beschreibungen englisch, „Zuletzt aktualisiert“ mit „1 year ago“.
- Die App-Verwaltung heißt in der Oberfläche **Supply Depot** (Handbuch korrigiert).
- Die Test-VM sperrt den Bildschirm nach 5 min; `gsettings … lock-enabled false` gesetzt.

## Nicht gemessen / offen

- GPU-Tempo (Karte auf 245k durch den LLM-Verbund belegt, Docker/Podman-GPU nicht eingerichtet).
- Einrichtungshelfer im Image (Phase 4, Schritt 4): `gemma3:4b` (3,4 GB) wäre die kleinste brauchbare Wahl; auf schwacher Hardware zu langsam. Entscheidung offen.
- Retrieval-Qualität mit indexiertem Wikipedia/CDC (Indexierung vorzeitig abgebrochen).
