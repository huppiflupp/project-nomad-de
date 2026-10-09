# Erste Schritte mit NOMAD

Diese Anleitung hilft Ihnen, das Beste aus Ihrem NOMAD-Server herauszuholen.

---

## Systemanforderungen

Wenn NOMAD bei Ihnen bereits läuft, können Sie diesen Abschnitt überspringen. Er ist für den Fall gedacht, dass Sie einen zweiten Server planen, auf andere Hardware umziehen oder jemand anderem bei der Einrichtung helfen.

### Betriebssystem

NOMAD läuft unter Debian-basiertem Linux.

| Unterstützungsstufe | Betriebssystem |
|---|---|
| **Empfohlen** | Ubuntu 26.04 LTS |
| **Ebenfalls unterstützt** | Ubuntu 24.04 LTS, Debian 12 |
| **Von der Community unterstützt** | Windows über WSL2, andere Debian-Derivate |

Ubuntu 26.04 LTS ist die Version, auf der wir testen und die wir für Neuinstallationen empfehlen. Wenn Sie bereits 24.04 LTS oder Debian 12 einsetzen, müssen Sie nicht neu installieren – beide werden weiterhin unterstützt.

Ubuntu Desktop ist die freundlichere Wahl, wenn Sie von Windows oder macOS kommen. Ubuntu Server funktioniert genauso gut, wenn Sie sich im Terminal wohlfühlen, und NOMAD braucht in beiden Fällen keine Desktop-Umgebung, da alles über den Browser bedient wird.

macOS und nicht Debian-basierte Distributionen wie Fedora oder Arch werden offiziell nicht unterstützt.

### Hardware

NOMAD selbst ist ressourcenschonend. Die Anforderungen hängen von den Inhalten und Werkzeugen ab, die Sie installieren, und davon, ob Sie KI lokal ausführen möchten.

**Minimum, ohne lokale KI:**

- 2-GHz-Dual-Core-Prozessor
- 4 GB RAM
- 5 GB freier Speicherplatz, plus Platz für alle Inhalte, die Sie herunterladen

**Empfohlen, mit lokaler KI:**

- AMD Ryzen 7 oder Intel Core i7 oder besser
- 32 GB RAM
- NVIDIA RTX 3060 oder AMD-Äquivalent, mehr VRAM ermöglicht größere Modelle
- 250 GB oder mehr freier Speicherplatz, vorzugsweise auf einer SSD

Eine stabile Internetverbindung wird nur während der Installation benötigt. Danach ist NOMAD darauf ausgelegt, vollständig offline zu laufen.

### Hinweis zu GPU-Treibern

Das Installationsprogramm richtet Docker und das NVIDIA Container Toolkit für Sie ein, installiert aber **nicht** den GPU-Treiber selbst. Diesen benötigen Sie vorab auf dem Host.

Unter Ubuntu geht das am einfachsten, indem Sie bei der Einrichtung **„Install third-party drivers for graphics and Wi-Fi hardware“** ankreuzen. Falls Sie das übersprungen oder die GPU später eingebaut haben, installieren Sie zuerst den Treiber und verwenden Sie dann **Neuinstallation erzwingen** beim KI-Assistenten im [Supply Depot](/supply-depot), damit er erkannt wird.

Ohne GPU funktioniert der KI-Assistent trotzdem. Er läuft dann auf der CPU, was deutlich langsamer ist.

---

## Schnellstart-Assistent

Wenn Sie NOMAD zum ersten Mal verwenden, hilft Ihnen der Schnellstart-Assistent bei der gesamten Einrichtung.

**[Schnellstart starten →](/easy-setup)**

![Schnellstart-Assistent – Schritt 1: Funktionen auswählen](/docs/easy-setup-step1-de.webp)

Der Assistent führt Sie in vier einfachen Schritten durch die Einrichtung:
1. **Funktionen** – Wählen Sie, was aktiviert werden soll: Wissensbibliothek, KI-Assistent, Bildungsplattform, Karten, Daten-Tools und Notizen
2. **Karten** – Wählen Sie geografische Regionen für Offline-Karten
3. **Inhalte** – Wählen Sie kuratierte Inhaltssammlungen in den Stufen Basis, Standard oder Umfassend

![Inhaltsstufen – Basis, Standard und Umfassend](/docs/easy-setup-tiers-de.webp)
4. **Überprüfen** – Bestätigen Sie Ihre Auswahl und starten Sie die Downloads

Je nach Auswahl können die Downloads eine Weile dauern. Den Fortschritt können Sie im Bereich „Einstellungen“ verfolgen, bereits installierte Funktionen weiter nutzen oder den Server bei großen Downloads über Nacht laufen lassen.

---

## Die Werkzeuge im Überblick

### Wissensbibliothek – Offline-Wissen (Kiwix)

Die Wissensbibliothek speichert komprimierte Versionen von Websites und Nachschlagewerken, die ohne Internet funktionieren.

**Was enthalten ist:**
- Die vollständige Wikipedia (Millionen von Artikeln)
- Medizinische Nachschlagewerke und Erste-Hilfe-Anleitungen
- Anleitungen und Überlebenswissen
- Klassische Bücher aus dem Project Gutenberg

**So verwenden Sie sie:**
1. Klicken Sie auf der Startseite der Kommandozentrale oder im [Supply Depot](/supply-depot) auf **Wissensbibliothek**
2. Wählen Sie eine Sammlung (zum Beispiel Wikipedia)
3. Suchen oder stöbern Sie wie auf der gewohnten Website

---

### Bildungsplattform – Offline-Kurse (Kolibri)

Die Bildungsplattform bietet vollständige Lernkurse, die offline funktionieren.

**Was enthalten ist:**
- Khan-Academy-Videokurse
- Mathematik, Naturwissenschaften, Lesen und mehr
- Lernfortschritt für Lernende
- Für alle Altersgruppen geeignet

**So verwenden Sie sie:**
1. Klicken Sie auf der Startseite der Kommandozentrale oder im [Supply Depot](/supply-depot) auf **Bildungsplattform**
2. Melden Sie sich an oder erstellen Sie ein Lernkonto
3. Stöbern Sie in den Kursen und legen Sie los

**Tipp:** Kolibri unterstützt mehrere Benutzer. Legen Sie für jedes Familienmitglied ein Konto an, um den individuellen Fortschritt zu verfolgen.

---

### KI-Assistent – integrierter Chat

![Oberfläche des KI-Chats](/docs/ai-chat-de.webp)

NOMAD enthält eine integrierte KI-Chat-Oberfläche auf Basis von Ollama. Sie läuft vollständig auf Ihrem Server – kein Internet nötig, keine Daten werden irgendwohin gesendet.

**Was sie kann:**
- Fragen zu jedem Thema beantworten
- Komplexe Zusammenhänge einfach erklären
- Beim Schreiben und Überarbeiten helfen
- Ihre hochgeladenen Dokumente über die Wissensdatenbank einbeziehen
- Ideen sammeln und bei der Problemlösung unterstützen

**So verwenden Sie sie:**
1. Klicken Sie in der Kommandozentrale auf **KI-Chat** oder öffnen Sie den [Chat](/chat)
2. Geben Sie Ihre Frage oder Ihren Auftrag ein
3. Die KI antwortet im Gesprächsstil

**Tipp:** Formulieren Sie Ihre Fragen konkret. Statt „Erzähl mir etwas über Pflanzen“ fragen Sie besser: „Welches Gemüse wächst gut im Schatten?“

**Hinweis:** Der KI-Assistent muss zuerst installiert sein. Aktivieren Sie ihn im Schnellstart oder installieren Sie ihn über das [Supply Depot](/supply-depot).

**GPU-Beschleunigung:** Wenn Ihr Server eine NVIDIA-GPU hat, richtet das NOMAD-Installationsprogramm die GPU-Unterstützung für Sie ein (es installiert das [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) und konfiguriert Docker automatisch). Sie benötigen nur den NVIDIA-Treiber auf dem Host, den Sie unter Ubuntu erhalten, indem Sie bei der Einrichtung „Install third-party drivers“ aktivieren. Mit GPU antwortet die KI dramatisch schneller (10- bis 20-fache Verbesserung). Wenn Sie später eine GPU hinzufügen, öffnen Sie das [Supply Depot](/supply-depot) und wählen Sie beim KI-Assistenten **Neuinstallation erzwingen**, um sie zu aktivieren.

---

### Wissensdatenbank – KI mit Dokumentenwissen

![Oberfläche zum Hochladen in die Wissensdatenbank](/docs/knowledge-base-de.webp)

Mit der Wissensdatenbank laden Sie Dokumente hoch, damit die KI sie beim Beantworten Ihrer Fragen heranziehen kann. Sie nutzt die semantische Suche (RAG über Qdrant), um relevante Informationen aus Ihren hochgeladenen Dateien zu finden.

**Unterstützte Dateitypen:**
- PDFs, Textdateien und andere Dokumentformate
- Die NOMAD-Dokumentation wird automatisch geladen, sobald der KI-Assistent installiert ist

**So verwenden Sie sie:**
1. Öffnen Sie die **[Wissensdatenbank →](/knowledge-base)**
2. Laden Sie Ihre Dokumente hoch (PDFs, Textdateien usw.)
3. Die Dokumente werden automatisch verarbeitet und indiziert
4. Stellen Sie Fragen im KI-Chat – die KI zieht Ihre hochgeladenen Dokumente heran, wenn sie relevant sind
5. Entfernen Sie Dokumente, die Sie nicht mehr brauchen – sie werden aus dem Index und vom lokalen Speicher gelöscht

**Anwendungsfälle:**
- Notfallpläne hochladen, um in einer Krise schnell nachschlagen zu können
- Technische Handbücher und Arbeitsanweisungen für Einsatzorte ohne Internet laden
- Lehrpläne für den Heimunterricht hinzufügen
- Fachartikel für wissenschaftliche Arbeit speichern

---

### Karten – Offline-Navigation

![Offline-Kartenansicht](/docs/maps-de.webp)

Sehen Sie Karten ohne Internet an. Laden Sie die benötigten Regionen herunter, bevor Sie offline gehen.

**So verwenden Sie sie:**
1. Klicken Sie in der Kommandozentrale auf **Karten**
2. Navigieren Sie durch Ziehen und Zoomen
3. Suchen Sie Orte über die Suchleiste

**So fügen Sie weitere Kartenregionen hinzu:**
1. Öffnen Sie **Einstellungen → Karten-Manager**
2. Wählen Sie die benötigten Regionen aus
3. Klicken Sie auf „Herunterladen“

**Tipp:** Laden Sie Karten für Gegenden herunter, in die Sie häufig reisen, sowie für angrenzende Regionen – für alle Fälle.

**[Karten öffnen →](/maps)**

---

## Ihren Server verwalten

### Weitere Inhalte hinzufügen

Wenn sich Ihr Bedarf ändert, können Sie jederzeit weitere Inhalte hinzufügen:

- **Weitere Apps:** Einstellungen → Supply Depot
- **Weitere Nachschlagewerke:** Einstellungen → Inhalts-Explorer oder Content-Manager
- **Weitere Kartenregionen:** Einstellungen → Karten-Manager
- **Weitere Bildungsinhalte:** Über den integrierten Inhaltsbrowser von Kolibri

### Wikipedia-Auswahl

![Inhalts-Explorer – Wikipedia-Pakete und kuratierte Sammlungen durchsuchen und herunterladen](/docs/content-explorer-de.webp)

NOMAD enthält ein eigenes Werkzeug zur Verwaltung von Wikipedia-Inhalten, mit dem Sie Wikipedia-Pakete durchsuchen und herunterladen.

**So verwenden Sie es:**
1. Öffnen Sie den **[Inhalts-Explorer →](/settings/zim/remote-explorer)**
2. Durchsuchen Sie die verfügbaren Wikipedia-Pakete nach Sprache und Größe
3. Wählen Sie die gewünschten Pakete aus und laden Sie sie herunter

**Hinweis:** Wenn Sie ein anderes Wikipedia-Paket auswählen, ersetzt es die zuvor heruntergeladene Version. Es ist immer nur eine Wikipedia-Auswahl aktiv.

### System-Benchmark

![System-Benchmark mit NOMAD Score und Builder-Tag](/docs/benchmark-de.webp)

Testen Sie die Leistung Ihrer Hardware und sehen Sie, wie sich Ihr NOMAD-System im Vergleich zur Community schlägt.

**So verwenden Sie ihn:**
1. Öffnen Sie den **[System-Benchmark →](/settings/benchmark)**
2. Wählen Sie einen Benchmark-Typ: Vollständig, Nur System oder Nur KI
3. Sehen Sie sich Ihren NOMAD Score an (ein gewichteter Gesamtwert aus CPU-, Arbeitsspeicher-, Datenträger- und KI-Leistung)
4. Erstellen Sie einen Builder-Tag (Ihre NOMAD-typische Identität, zum Beispiel „Tactical-Llama-1234“)
5. Teilen Sie Ihre Ergebnisse mit der [Community-Bestenliste](https://benchmark.projectnomad.us)

**Hinweis:** Nur vollständige Benchmarks mit KI-Daten können mit der Community-Bestenliste geteilt werden.

### Aktuell bleiben

Solange Sie Internet haben, sollten Sie regelmäßig nach Updates suchen:

1. Öffnen Sie **Einstellungen → Nach Updates suchen**
2. Wenn Updates verfügbar sind, klicken Sie zum Installieren
3. Warten Sie, bis das Update abgeschlossen ist (Ihr Server wird neu gestartet)

Inhalts-Updates (Wikipedia, Karten usw.) lassen sich getrennt von Software-Updates verwalten.

**Automatische Updates:** NOMAD kann sich auch selbst aktuell halten, ohne dass Sie nachsehen müssen. Software, installierte Apps und Inhalte lassen sich jeweils auf freiwilliger Basis automatisch aktualisieren, mit Sicherheitsprüfungen und einem Zeitfenster, das Sie selbst festlegen. Alle Einzelheiten finden Sie in der **[Anleitung „Updates“](/docs/updates)**.

**Early-Access-Kanal:** Möchten Sie die neuesten Funktionen, bevor sie stabil werden? Aktivieren Sie den Early-Access-Kanal auf der Seite „Nach Updates suchen“, um Release-Candidate-Builds zu erhalten. Sie können jederzeit zum stabilen Kanal zurückwechseln.

### Systemzustand überwachen

Sie können jederzeit nach Ihrem Server sehen:

1. Öffnen Sie **Einstellungen → System**
2. Sehen Sie sich die Auslastung von CPU, Arbeitsspeicher und Speicherplatz an
3. Prüfen Sie Betriebszeit und Status des Systems

---

## Tipps für beste Ergebnisse

### Bevor Sie offline gehen

- **Alles aktualisieren** – Führen Sie Software- und Inhalts-Updates durch
- **Herunterladen, was Sie brauchen** – Karten, Nachschlagewerke, Bildungsinhalte
- **Testen** – Prüfen Sie, ob die Funktionen laufen, solange Sie noch Internet zur Fehlersuche haben

### Speicherverwaltung

Ihr Server hat begrenzten Speicherplatz. Setzen Sie Prioritäten:
- Inhalte, die Sie tatsächlich nutzen werden
- Wichtige Nachschlagewerke (Medizin, Überleben)
- Karten für Ihre Region
- Bildungsinhalte, die zu Ihrem Bedarf passen

Den Speicherverbrauch sehen Sie unter **Einstellungen → System**.

### Hilfe erhalten

- **Dokumentation in der App:** Sie lesen sie gerade
- **KI-Assistent:** Stellen Sie im [KI-Chat](/chat) eine Frage
- **Release Notes:** Sehen Sie nach, was in jeder Version neu ist

---

## Nächste Schritte

Sie sind bereit, NOMAD zu nutzen! Hier sind einige Dinge zum Ausprobieren:

1. **Etwas nachschlagen** – Suchen Sie in der Wissensbibliothek nach einem Thema
2. **Etwas lernen** – Starten Sie einen Khan-Academy-Kurs in der Bildungsplattform
3. **Eine Frage stellen** – Chatten Sie mit der KI im [KI-Chat](/chat)
4. **Karten erkunden** – Suchen Sie Ihre Nachbarschaft im Kartenviewer
5. **Ein Dokument hochladen** – Fügen Sie der [Wissensdatenbank](/knowledge-base) ein PDF hinzu und fragen Sie die KI danach

Viel Freude mit Ihrem Offline-Wissensserver!
