# Teilprojekte B bis D: deutsche Inhalte, Übersetzung, Fachdienste

Stand 2026-10-09. Fortsetzung von `2026-10-04-teilprojekt-a-fork-und-uebersetzung.md` (dort die Zerlegung A–D).

| # | Teilprojekt | Stand |
|---|---|---|
| **B** | Deutsche Inhaltskataloge | **umgesetzt** (Katalog, Pflegeskript, Test); Folgearbeiten unten |
| **C** | Übersetzungsengine | **Kern umgesetzt** (Dienst 0.1.1, Zahlenprüfung, deutsche Leiste, Messung); Veröffentlichung und LLM-Option offen |
| **D** | Deutsche Fachdienste (Arzneimittel, Beschwerden) | **Recherche**, Lizenz ungeklärt; Entscheidung nötig |

---

## B – Deutsche Kataloge (umgesetzt)

**Was:** Die Kataloge liegen in `collections/` und werden von NOMAD zur Laufzeit aus unserem Repo geladen (`DISTRIBUTION.rawBase`). Änderungen wirken ohne Release.

- `collections/wikipedia.json`: fünf **deutsche Wikipedia-Optionen** (Schnellreferenz 137 MB, Beliebte Artikel 1,2 GB, Komplett kompakt 4,6 GB, ohne Bilder 18 GB, vollständig 51 GB) vor den englischen. Die englischen heißen jetzt „Englische Wikipedia – …“.
- `collections/kiwix-categories.json`: drei **deutsche Kategorien** vor den englischen, je Basis/Standard/Umfassend: *Medizin (Deutsch)* 0,16 / 0,20 / 0,69 GB (WikiMed, Molekularbiologie),
  *Nachschlagen und Lernen (Deutsch)* 0,26 / 6,3 / 18,6 GB (Klexikon, PhET, Wikibooks, Wikiversity, Wiktionary, Fach-Wikipedias, Wikivoyage, Wikisource, Projekt Gutenberg),
  *Alltag und Technik (Deutsch)* 0,03 / 0,21 / 3,8 GB (Koch-Wiki, freeCodeCamp, Informatik, iFixit). Englische Kategorien tragen „(Englisch)“.
- Quelle der Adressen, Größen, Versionen: Kiwix-Katalog. `de/tools/kiwix_katalog.py` (suchen, prüfen, aktualisieren) und `de/tools/katalog_de.py` (erzeugt die deutschen Einträge).
  `python3 de/tools/kiwix_katalog.py pruefen` zeigt veraltete Einträge; zum Stand 2026-10-09: 29 Einträge des Originals sind veraltet (neuere Fassung im Kiwix-Katalog), 2 fehlen im Katalog (NHS, Militärmedizin; die Adressen antworten noch).
  **Empfehlung:** `aktualisieren` monatlich laufen lassen (ändert Größen und Versionen; Nutzer sehen dann „Update verfügbar“).
- Karten: Länderauswahl im Karten-Manager mit Schnellwahl **DACH**, deutsche Länder- und Kontinentnamen (`Intl.DisplayNames`). Kuratierte Regionen des Originals bleiben US-Gebiete.
- Test `admin/tests/unit/catalogs_de.spec.ts` (Schema, eindeutige Kennungen, Stufenketten, Adressformate); CI-Prüfer kennt deutsche Einträge (keine Übersetzung nötig).

**Folgearbeiten B**
1. *Überleben und Vorsorge* hat **keinen deutschen Inhalt** (Kiwix hat keinen). Optionen: (a) BBK-Ratgeber und weitere amtliche Notfall-Broschüren als PDF aufnehmen (**Lizenz klären**, Weitergabe nicht automatisch erlaubt),
   (b) englische Pakete maschinell übersetzen (Teilprojekt C, auf Anforderung je Seite), (c) eigene deutsche Texte (Notfallkarte, Handbuch) in der Wissensdatenbank anbieten.
2. Screenshots im Handbuch und in den Videos (Schnellstart „Inhalte“, Stufen-Dialog) zeigen noch die englischen Kategorien; Neuaufnahme mit der VM.
3. Indexierung für die KI: deutsche ZIMs (WikiMed de 160 MB) wurden noch nicht gemessen.

---

## C – Übersetzungsengine

**Ausgangslage:** Das Original liefert `install/nomad-translate` (Bergamot, Proxy vor Kiwix, „Diese Seite übersetzen“-Leiste, Sprachen als Cookie). Ein eigener Reader ist ausdrücklich nicht Ziel.

**Messung** (`de/tests/uebersetzung/README.md`, zehn Notfalltexte): Bergamot 856 Wörter/s mit mehreren Fehlern (teils sachlich relevant) und **einer verlorenen Zahl**; Qwen3.6-35B 24,5 Wörter/s, deutlich besser, alle Zahlen und alle Umrechnungen korrekt.

**Umgesetzt**
- Dienst auf Stand des Originals (0.1.1) gebracht; Seeder zeigt auf `ghcr.io/huppiflupp/project-nomad-de-translate:0.1.1`; Standardsprache nur `de` (Original: fr,es,de).
- `install/nomad-translate/de_zusatz.py`: **Zahlenprüfung** (markiert Absätze, in denen Zahlen der Vorlage fehlen, Tooltip mit Original), deutsche Leiste und Sprachnamen, Hinweis „Maschinell übersetzt …“. Tests `test_de_zusatz.py` (11), in der CI.
- Ende-zu-Ende geprüft gegen eine nachgebaute Kiwix-Seite: genau der Absatz mit fehlenden Zahlen wurde markiert, keiner der anderen.

**Offen**
1. **Image veröffentlichen:** `ghcr.io/huppiflupp/project-nomad-de-translate` existiert **noch nicht** (Workflow `build-translate-proxy` lief nie, `docker pull` liefert „denied“). Ohne das schlägt die Installation von „Translated Library“ in unserer Fassung fehl.
   Schritte: Workflow mit `version=0.1.1` starten, danach das Paket auf GitHub **öffentlich** stellen (Paketeinstellungen, nur der Inhaber kann das).
2. **Qualitätsübersetzung per Sprachmodell** (Option je Seite, nutzt den KI-Assistenten, Ergebnis zwischenspeichern, Prompt wie im Test „metrisch“).
3. **Zwischenspeicher** für übersetzte Absätze (Hash aus Quelle und Sprache), damit die zweite Ansicht sofort erscheint.
4. Wort-Vertrauenswerte von Bergamot (`x-bergamot-word-score`) nutzen: unsichere Stellen dezent markieren.
5. Testmaterial auf etwa 50 Absätze aus echten ZIM-Seiten (CDC, NHS) erweitern, bevor über einen LLM-Standard entschieden wird.

---

## D – Deutsche Fachdienste

**Ist-Stand im Original:** Die *Arzneimittel-Referenz* nutzt den openFDA-Datensatz (Beipackzettel der US-Behörde; Ressource `openfda-drug-labels`, Stufe *Medizin → Standard*; 1,7 GB Download, 8–10 GB indiziert),
*Beschwerden* (`collections/conditions.json`, Situation → rezeptfreie Wirkstoffe, englische Suchbegriffe) und *Wechselwirkungen* (aus denselben Daten). Für Deutschland passen Wirkstoff- und Markennamen und die Zulassung nicht (Acetaminophen statt Paracetamol, US-Marken).

**Recherche der Quellen (2026-10-09, unvollständig):**

| Quelle | Inhalt | Lizenz/Nutzung (Stand der Recherche) |
|---|---|---|
| **Swissmedic / AIPS** (Schweiz) | Fachinformation und Patienteninformation der zugelassenen Humanarzneimittel, **XML-Gesamtdatei**, deutsch/französisch/italienisch | Download vorhanden; Betrieb durch Refdata mit eigenen Nutzungsbedingungen (`refdata.ch/de/terms-of-use-aips-sai`). Das Register „Daten von Human- und Tierarzneimitteln“ auf opendata.swiss trägt ein offenes Nutzungslabel (kommerziell erlaubt, Quellenangabe nicht verlangt), enthält aber vermutlich nur Registerdaten. **Wiederverwendung der Texte ungeklärt, schriftliche Bestätigung nötig.** |
| **PharmNet.Bund / BfArM** (Deutschland) | Arzneimittelinformationssystem mit Fach- und Gebrauchsinformation aller Mittel im deutschen Verkehr | Recherche seit 02/2025 kostenfrei; **kein Hinweis auf eine Massennutzungs- oder Open-Data-Lizenz gefunden.** Direkte Seiten waren für den Abruf gesperrt. Anfrage an das BfArM nötig. |
| **AGES / BASG** (Österreich) | Arzneispezialitätenregister, Fachinformationen | Lizenz nicht ermittelt (data.gv.at prüfen) |
| **Wikipedia de (WikiMed), CC BY-SA** | Wirkstoff- und Krankheitsartikel | **Frei nutzbar**, bereits in Teilprojekt B enthalten (Medizin Deutsch) |
| Wechselwirkungen | keine offene deutsche Quelle gefunden (üblich: kommerzielle Datenbanken) | – |

**Entscheidungsvorlage (Nutzer):**
1. Sollen wir bei BfArM, Refdata/Swissmedic und AGES **schriftlich** die Nutzungsrechte erfragen? (ich kann Anschreiben entwerfen; der Nutzer sendet sie)
2. Solange offen: **Arzneimittel-Referenz in der deutschen Fassung deaktivieren oder deutlich als „US-Daten, Englisch“ kennzeichnen**, die Stufe *Medizin (Englisch) → Standard* behält sie (wird so schon unter „(Englisch)“ geführt).
3. Eigene, kleine **deutsche Beschwerdenliste** (etwa 40 Situationen mit rezeptfreien Wirkstoffen wie Paracetamol, Ibuprofen; Hinweise und Warnsignale) als redaktionelle Eigenleistung, geprüft an Wikipedia und amtlichen Patienteninformationen. Das ist lizenzsicher, braucht aber fachliche Prüfung (Apotheker/Arzt).

**Aufwand grob:** D1 Lizenzklärung (Wartezeit, nicht Arbeit), D2 Einlesen der gewählten Quelle (XML → Suchdatenbank, Anpassung der Datentypen `DrugLabelDetail`), D3 Oberfläche und Haftungshinweise deutsch, D4 Beschwerdenliste.

---

## Reihenfolge und Abhängigkeiten

1. Translate-Image veröffentlichen (C, braucht nur Zustimmung) → danach „Translated Library“ in der Oberfläche nutzbar.
2. Katalogpflege monatlich (B).
3. Lizenzanfragen für D versenden; parallel D3/D4 vorbereiten.
4. Qualitätsübersetzung per Sprachmodell (C2) und Zwischenspeicher (C3).
5. Deutsche Notfall-Inhalte für *Überleben und Vorsorge* (B1), abhängig von Lizenz oder Übersetzung.
