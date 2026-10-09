# Videos (Entwurf 1, 2026-10-09)

Vier kurze Videos aus Standbildern, deutscher Sprecherstimme und Untertiteln (je etwa 3 Minuten):

| Datei | Inhalt |
|---|---|
| `v1-konzept` | Was ist NOMAD, warum, ab wann geht es ohne Internet (aus der Präsentation) |
| `v2-installation` | USB-SSD (Etcher, Start vom Stick, Passwort) und kurz Weg 2 (Ubuntu, Installer) |
| `v3-betrieb` | Inhalte laden, Offline-Test, Notfall-Karte, Update, Strom, Handbuch |
| `v4-erweiterungen-ki` | Karten für Länder, KI einrichten, Modelle, Warnungen, Indexieren, GPU |

Bauen: `python3 bauen.py v1 v2 v3 v4` (Ergebnis `ausgabe/*.mp4` und `.srt`, die MP4 liegen nicht im Git).
Die Sprecherstimme (Piper „thorsten“, aus `~/sprachlern-ki`) wird von `sprecher.py` erzeugt und mit faster-whisper rückgeprüft.
Szenen und Sprechertexte stehen in `videos.py`; V1 nutzt die Notizen aus `../praesentation/folien.py`.

## Nächste Schritte (Erweiterungen)

- Echte Bildschirmaufnahmen statt Standbilder in V2 und V3 (Etcher unter Windows, Schnellstart, Chat).
- Kurze Bewegtbilder (B-Roll) aus ComfyUI (`ltx-2.5`, `wan2.2`) für die Konzeptszenen.
- Weitere Videos: Strom und Solar, Backup, eigene Dokumente, KI-Server im Heimnetz (llama.cpp), Fehlersuche.
- Aussprache der Fremdwörter prüfen (Kiwix, Ollama, gemma); Rückprobe zeigte 2–26 % Abweichung je Szene.
- Nach Veröffentlichung des Images: Download-Szene (V2, b03) mit der echten Adresse aktualisieren.
