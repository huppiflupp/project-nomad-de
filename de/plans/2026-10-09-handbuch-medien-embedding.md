# Plan: Handbuch fertigstellen, Medien (Präsentation, Videos), Repo-Texte, Embedding-Untersuchung

Stand 2026-10-09. Fortsetzung von `2026-10-08-handbuch-und-usb-image.md`. Auftrag des Nutzers vom 2026-10-09.

## Arbeitspakete

| Nr. | Paket | Inhalt | Ergebnis |
|---|---|---|---|
| W1 | Handbuch fertigstellen | Screenshots zuschneiden und beschriften, Kapitel 10 mit den GPU-Zahlen aktualisieren, **HTML-Fassung** von Handbuch und Installationsanleitung | `de/handbuch/` PDF + HTML |
| W2 | Task 18 und 19 | `de/SYNC.md` (Abgleich mit Upstream); deutsche Bilder für die 8 Anleitungsbilder | `de/SYNC.md`, deutsche Bilder in `admin/public/` bzw. Doku |
| W3 | GitHub-Repo | Beschreibung („About“), Themen, restliche englische Texte in README, Releases, Ordner-READMEs | Repo komplett deutsch (Original-Verweise bleiben) |
| W4 | Präsentation | Neue PowerPoint mit Bildern. Storyboard aus der alten Fassung (20 Textfolien, `~/Downloads` auf 245k), Bilder per ComfyUI (`flux`, `qwen_image`, `z_image`) und echte Screenshots | `de/praesentation/NOMAD-Praesentation.pptx` |
| W5 | Videos | V1 Konzept, V2 Installation, V3 Betrieb, V4 Erweiterungen (andere Inhalte, LLM-Betrieb). Folien/Bilder + Sprecherstimme + ffmpeg; B-Roll optional per ComfyUI-Video (`ltx-2.5`, `wan2.2`) | `de/video/` |
| W6 | Embedding-Untersuchung (**separat, im Hintergrund**) | Befund festgehalten, Ursache später klären | `de/tests/notfall-ki-messung.md`, Abschnitt „Nachtrag“ |

## Reihenfolge

1. W3 (klein, sofort sichtbar), W2, W1 (Handbuch ist Grundlage für W4/W5).
2. W4 (Präsentation); Storyboard und Bilder gelten danach auch als Drehbuch für W5.
3. W5 in der Reihenfolge V1 → V2 → V3 → V4.
4. W6 getrennt, wenn der Nutzer es freigibt.

```
W3 ─┐
W2 ─┼─> W1 ─> W4 ─> W5 (V1 → V2 → V3 → V4)
    │
W6 ─┴─ (unabhängig, später)
```

## W6: Stand des Embedding-Befunds (nicht bearbeiten, nur festhalten)

Messung 2026-10-09 (Details in `de/tests/notfall-ki-messung.md`):
- CPU-Embedding: Test-VM 370 Token/s, 245k 1000 Token/s; GPU (x9, llama.cpp) 26.000–50.000 Token/s.
- Ende-zu-Ende mit GPU-Backend: CDC (178 MB) 15.529 Chunks in 7,5 min, NHS (17 MB) 10.386 Chunks in 6 min, Wikipedia-Top-Mini (331 MB) 2 % in 17 min.
- Die GPU lag nur bei ≈ 5 % Auslastung, die VM-CPU bei ≈ 1 Kern. Der Engpass liegt **nach** dem Embedding, vermutlich in der ZIM-Verarbeitung
  (`ZIMExtractionService`: libzim-Zugriff, Parsen mit cheerio, Stapelgröße `ZIM_BATCH_SIZE = 50`, ein Job je Stapel, 2 parallele Jobs, Upserts in Qdrant).
- Offene Fragen: Wie viel Zeit entfällt auf Extraktion, Chunking, Embedding-Aufruf, Qdrant-Upsert? Löst Upstream das schon (Issues, neuere Versionen)?
  Text ist Text: Eine Vorab-Umwandlung ZIM → Text/JSONL könnte den Aufwand je Chunk senken.
- **Fund im Upstream (2026-10-09, nur festgehalten):** Das Original kennt die Ursache. `ZIMExtractionService.extractZIMContent()` öffnet das Archiv je Stapel neu und
  läuft bis zum Offset von Eintrag 0 an (`archive.iterByPath()`, dabei wird für jeden übersprungenen Eintrag `entry.item` dereferenziert). Jeder Stapel kostet also
  proportional zum Offset, die Aufnahme einer ZIM ist **O(n²)**. Issues: Crosstalk-Solutions/project-nomad **#1185** (offen, Wikipedia maxi: 13,7 Tage für 5,83 %) und **#1212**
  (geschlossen; gemessen: `ZIM_BATCH_SIZE` 50 → 500 gab ×2,7, → 5000 etwa ×9, 5,5 → 50 Einträge/s). Korrektur-PR **#1386** „seek ZIM batches instead of rescanning from the start“ (offen).
  Das passt zu unserer Messung (große ZIM: Fortschritt bremst, GPU im Leerlauf). Bei einem Abgleich (`de/SYNC.md`) prüfen, ob #1386 in eine neue Version gelangt;
  sonst eigene Umsetzung (Seek statt Rescan, größere Stapel) erwägen.
- Weitere Erkenntnisse: PDF-ZIMs liefern fast keinen Text (1–2 Chunks); Indexieren startet ohne Warnung für alles.

## Offene Entscheidungen (Nutzer)

- Sprecherstimme und Länge der Videos (Vorschlag: 3–6 min je Video, deutsche Sprecherstimme, Untertitel).
- Ob Präsentation und Videos öffentlich im Repo (Release-Dateien) liegen sollen.
