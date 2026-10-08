# Plan: Handbuch (LaTeX) und bootfähiges USB-Image

Stand 2026-10-08. Ausgangslage: Teilprojekt A ist bis Task 16 fertig (Release v1.35.1, Images auf ghcr, Pakete öffentlich).

## Ziele

- Ein **offline-fähiges System**, das auch Menschen über 60 mit wenig IT-Erfahrung einrichten können.
- **Hauptweg:** Windows-PC bleibt unangetastet, NOMAD startet von einer **USB-SSD** (Weg 2).
- **Alternative:** Ubuntu 26.04 normal auf einem eigenen Rechner installieren (Weg 1).
- Ein **gedrucktes Handbuch** (LaTeX), das man zum Stick oder Notfall-Laptop legt.
- Kein macOS (Entscheidung 2026-10-08). WSL2 bleibt Verweis auf die Upstream-Anleitung.

## Entscheidungen

| Frage | Entscheidung |
|---|---|
| Live-Stick | Verworfen: nichts bleibt erhalten, Docker läuft schlecht auf dem Live-Dateisystem. |
| Bootfähiges Image | Ubuntu 26.04.1 + Docker + NOMAD vorinstalliert, **ohne Inhalte**; Aufspielen mit Rufus oder balenaEtcher; erste Anmeldung vergrößert das System auf die ganze SSD. |
| Mindest-Datenträger | USB-SSD, USB 3, mindestens 512 GB. Normale USB-Sticks sind zu langsam und zu klein. |
| Handbuch-Format | LaTeX (`xelatex`), Quellen in `de/handbuch/`, PDF als Release-Datei. |
| Reihenfolge | Erst Test von `main` (Weg 1), daraus Screenshots und Image, dann Handbuch fertigstellen. |
| Image-Bau | Eigenes Teilprojekt E, damit das Handbuch nicht davon abhängt. |

## Phasen

### Phase 1 – Teilprojekt A abschließen
1. **Task 17 (Rest):** frische Ubuntu-26.04-Desktop-VM auf x9, Installation von `main` mit dem veröffentlichten Befehl, Schnellstart, Inhalte laden, Offline-Test (Netz trennen), Update-Test auf 1.35.2. Dabei **Screenshots** vom Ubuntu-Installer, Terminal, Browser.
2. **Task 19:** deutsche Screenshots der 8 vorhandenen Anleitungsbilder.
3. **Task 18:** Probe-Abgleich mit Upstream, `de/SYNC.md`.
4. **Kleinigkeiten:** toter Kiwix-Link `devdocs_en_bash_2026-01.zim` (CI „Validate Collection URLs“), Kategorie „Ai“ → „KI“, „Download“ in `/docs/drug-reference`.

### Phase 2 – Teilprojekt E: bootfähiges USB-Image
1. Basis: Ubuntu 26.04.1 in x9-VM auf rohes Image installieren (UEFI), automatischer Anmeldeschritt, SSH aus.
2. Docker und NOMAD vorinstallieren (Images vorab ziehen, ca. 4 GB), Dienste starten beim Boot.
3. Erster Start: Partition auf die ganze SSD vergrößern, Rechnername und Netzwerk (DHCP), Browser öffnet die NOMAD-Adresse.
4. Image verkleinern und komprimieren, Prüfsumme, als Release-Datei oder Download.
5. Test: UEFI-Boot in der VM von einem USB-Datenträger-Abbild; Secure Boot mit und ohne.
6. Offen, nicht testbar in der VM: Fremd-Hardware (Grafik, WLAN, Boot-Menü). Prüfung an einem echten Windows-PC durch den Nutzer.

### Phase 3 – Handbuch (LaTeX)
Kapitel:

1. Was ist NOMAD, und ab wann ist es offline? (Tabelle: sofort da / nach dem Laden / braucht Internet)
2. Vorbereitung unter Windows: USB-SSD, Image schreiben (Weg 2) bzw. Ubuntu-Stick erstellen (Weg 1)
3. Ubuntu installieren (Weg 1), mit Screenshots
4. NOMAD installieren, Schnellstart
5. Daten laden: Inhaltsstufen, Wikipedia, Karten, KI-Modelle, jeweils Größe und Dauer (aus `size_mb` der Kataloge)
6. Offline-Test: Netzwerkkabel ziehen, Checkliste
7. Notfall-Karte (eine Seite): Neustart, Adresse wiederfinden, Fehlerbehebung
8. Energie: Formeln und Beispielrechnung (Leistung, Laufzeit am Akku oder Solar, Kosten); Annahmen gekennzeichnet; Tabelle für eigene Messwerte
9. Tabellen zum Ausfüllen: Softwarestand, Inhaltsliste, Hardware, Zugangsdaten, Backup
10. Notfall-KI: lokales Sprachmodell einrichten und mit den geladenen Daten nutzen (siehe Phase 4)

Gestaltung: große Schrift, Befehle in Kästen, Kästchen zum Abhaken, Ausfüllzeilen. Zusätzlich als PDF zum Ausdrucken.

### Phase 4 – Notfall-KI (lokales LLM mit Zugriff auf die geladenen Daten)
Grundlage ist, was NOMAD schon hat: KI-Chat über Ollama und die Wissensdatenbank (RAG über Qdrant). Die Wissensdatenbank
nimmt laut Anleitung hochgeladene Dateien (PDF, Text) auf; die NOMAD-Dokumentation wird automatisch geladen, sobald der
KI-Assistent installiert ist.

1. **Klären (Messung, nicht raten):** Kann die KI die per Kiwix geladenen Inhalte (Wikipedia, medizinische Nachschlagewerke) nutzen,
   oder nur hochgeladene Dateien? Wenn nur Dateien: Weg suchen, ZIM-Inhalte oder Auszüge daraus in die Wissensdatenbank zu bringen,
   oder die Kiwix-Suche als Werkzeug anbinden. Ergebnis mit Zahlen festhalten.
2. **Modellstufen nach Hardware:** schwacher PC ohne GPU (kleines Modell, z. B. 1–2 Mrd. Parameter), mittlerer PC mit 16 GB RAM,
   PC mit NVIDIA-GPU. Je Stufe Modell, Speicherbedarf und gemessene Antwortzeit ins Handbuch; Deutsch-Qualität prüfen.
3. **Kapitel „Notfall-KI“:** installieren (Schnellstart oder Supply Depot), GPU-Hinweis, Fragen stellen, Grenzen
   (kann irren; bei Medizin und Sicherheit Quellen prüfen), Handbuch-PDF und Notfallpläne in die Wissensdatenbank laden.
4. **Einrichtungshelfer (Stufe 2, komplexer):** ein kleines Modell im Image vorinstalliert, mit Handbuch und `docs-de` in der
   Wissensdatenbank, damit es schon beim ersten Start offline Fragen zur Einrichtung beantwortet. Nur, wenn die Hardware es trägt;
   sonst bleibt das gedruckte Handbuch der Weg. Es führt nur Anleitungen aus, es ändert nichts am System ohne Bestätigung.

## Abhängigkeiten

- Handbuch Kapitel 3–6 und alle Screenshots hängen an Phase 1 (Task 17).
- Image-Bau (Phase 2) nutzt dieselben Schritte wie Task 17.
- Handbuch Kapitel 2 (Weg 2) braucht das fertige Image.
- Kapitel 7–9 (Notfallkarte, Energie, Tabellen) sind unabhängig und können früh entstehen.
- Phase 4 Schritt 1 (Messung) kann auf der Ubuntu-VM aus Task 17 laufen; Schritt 4 braucht das Image.

## Nicht Teil dieses Plans

macOS, WSL2-Anleitung (nur Verweis), Teilprojekte B–D (deutsche Kataloge, Übersetzungsengine, Fachdienste).
