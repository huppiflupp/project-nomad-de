# Häufig gestellte Fragen

## Allgemeine Fragen

### Was ist NOMAD?
NOMAD ist ein persönlicher Server, der Ihnen Zugang zu Wissen, Bildung und KI-Unterstützung bietet, ohne dass eine Internetverbindung nötig ist. Er läuft auf Ihrer eigenen Hardware, hält Ihre Daten privat und ist jederzeit verfügbar.

### Brauche ich Internet, um NOMAD zu nutzen?
Nein – das ist ja der Sinn der Sache. Sobald Ihre Inhalte heruntergeladen sind, funktioniert alles offline. Internet benötigen Sie nur, um:
- neue Inhalte herunterzuladen
- die Software zu aktualisieren
- die neuesten Versionen von Wikipedia, Karten usw. zu synchronisieren

### Welches Betriebssystem braucht NOMAD?
Ein Debian-basiertes Linux. **Ubuntu 26.04 LTS empfehlen wir und testen wir** für Neuinstallationen.

Ubuntu 24.04 LTS und Debian 12 werden ebenfalls unterstützt, Sie müssen also nicht neu installieren, wenn Sie bereits eines davon nutzen. Windows-Nutzer können der [WSL2-Anleitung](https://www.projectnomad.us/install/wsl2) folgen, die von der Community unterstützt wird.

macOS und nicht Debian-basierte Distributionen wie Fedora oder Arch werden offiziell nicht unterstützt. NOMAD braucht keine Desktop-Umgebung, daher ist Ubuntu Server eine gute Wahl, wenn Sie sich am Terminal wohlfühlen.

Eine vollständige Anleitung einschließlich der Ubuntu-Installation selbst finden Sie im [Installationsleitfaden](https://www.projectnomad.us/install).

### Welche Hardware brauche ich?
NOMAD ist für leistungsfähige Hardware ausgelegt, besonders wenn Sie die KI-Funktionen nutzen möchten. Empfohlen:
- Moderne Mehrkern-CPU (AMD Ryzen 7 mit Radeon-Grafik ist der Geheimtipp der Community)
- 16 GB+ RAM (32 GB+ für beste KI-Leistung)
- SSD-Speicher (die Größe hängt von den Inhalten ab – mindestens 500 GB, empfohlen 1 TB+)
- NVIDIA- oder AMD-GPU empfohlen für schnellere KI-Antworten

**Detaillierte Empfehlungen für drei Preisklassen (150–1.000+ US-Dollar) finden Sie im [Hardware-Leitfaden](https://www.projectnomad.us/hardware).**

### Wie viel RAM brauche ich?

**Ohne den KI-Assistenten bleibt der gesamte Stack unter 1 GB.** Gemessen an einer laufenden
Installation: die Kommandozentrale 241 MB, MySQL 444 MB, Redis 9 MB, Kiwix 101 MB und der
Index der Wissensdatenbank 155 MB. Deshalb sind 4 GB ein echtes und kein
vorsichtiges Minimum.

**Die KI ist die Variable, und es ist das Modell, nicht NOMAD.** Ollama braucht im Leerlauf
etwa 1,2 GB, und ein Modell benötigt beim Antworten ungefähr seine Download-Größe im Speicher,
ein 8B-Modell mit ~4,6 GB braucht also etwa so viel zusätzlich.
**8 GB sind für ein kleines Modell machbar, 16 GB sind komfortabel, und 32 GB sind die Empfehlung, wenn Sie größere Modelle betreiben möchten.**

Woher dieser Speicher kommt, hängt von Ihrer Hardware ab. Mit einer dedizierten GPU
wird das Modell in den VRAM geladen und berührt den Arbeitsspeicher nie, daher bestimmt der VRAM,
welche Modelle Sie ausführen können. Mit einer integrierten GPU oder ganz ohne GPU kommt er aus dem
Arbeitsspeicher, weshalb ein reiner CPU-Rechner mehr davon braucht.

### Wie viel Speicherplatz brauche ich?

**Für die Installation von NOMAD selbst: etwa 5 GB, lassen Sie also 10 GB frei.** Das umfasst die
Kommandozentrale und ihre Datenbank, noch ohne Inhalte. Mit dem KI-Assistenten
sind es insgesamt etwa 25 GB, weil Ollama und ein Allzweck-Modell
beide groß sind.

Danach hängt es ganz davon ab, was Sie herunterladen:
- Vollständige Wikipedia: ~95 GB
- Khan-Academy-Kurse: ~50 GB
- Medizinische Nachschlagewerke: ~500 MB
- US-Bundesstaaten-Karten: je ~2–3 GB
- KI-Modelle: 10–40 GB je nach Modell

Beginnen Sie mit dem Wesentlichen und fügen Sie bei Bedarf mehr hinzu.

---

## Fragen zu Inhalten

### Wie füge ich weitere Wikipedia-Inhalte hinzu?
1. Gehen Sie zu **Einstellungen** (Hamburger-Menü → Einstellungen)
2. Klicken Sie auf **Inhalts-Explorer**
3. Durchsuchen Sie die verfügbaren Wikipedia-Pakete
4. Klicken Sie bei den gewünschten Einträgen auf Herunterladen

Mit dem **Inhalts-Explorer** können Sie auch alle weiteren verfügbaren ZIM-Inhalte jenseits von Wikipedia durchsuchen.

### Wie füge ich weitere Bildungskurse hinzu?
1. Öffnen Sie **Kolibri**
2. Melden Sie sich als Administrator an
3. Gehen Sie zu **Device → Channels**
4. Durchsuchen und importieren Sie verfügbare Kanäle

### Wie aktuell sind die Inhalte?
Inhalte sind so aktuell wie zum Zeitpunkt des letzten Downloads. Wikipedia-Abzüge werden in der Regel monatlich aktualisiert. Datumsangaben finden Sie in den Dateinamen oder Beschreibungen.

### Kann ich eigene Dateien hinzufügen?
Ja – mit der Wissensdatenbank. Laden Sie PDFs, Textdateien und andere Dokumente in die [Wissensdatenbank](/knowledge-base) hoch, und die KI kann beim Beantworten Ihrer Fragen darauf zurückgreifen. Dabei wird eine semantische Suche genutzt, um relevante Informationen aus Ihren hochgeladenen Dateien zu finden.

Für Kiwix-Inhalte verwendet NOMAD Standard-ZIM-Dateien. Für Bildungsinhalte nutzt Kolibri sein eigenes Kanalformat.

### Was sind die Stufen der kuratierten Sammlungen?
Bei der Auswahl von Inhalten im Schnellstart-Assistenten oder im Inhalts-Explorer sind Sammlungen in drei Stufen organisiert:
- **Basis** – Kerninhalte der Kategorie (kleinster Download)
- **Standard** – Basis plus weitere nützliche Inhalte
- **Umfassend** – Alles, was für die Kategorie verfügbar ist (größter Download)

So können Sie Inhaltsabdeckung und Speicherbedarf gegeneinander abwägen.

---

## KI-Fragen

### Wie nutze ich den KI-Chat?
1. Öffnen Sie den [KI-Chat](/chat) in der Kommandozentrale
2. Geben Sie Ihre Frage oder Anfrage ein
3. Die KI antwortet im Gesprächsstil

Die KI muss zuvor installiert sein – aktivieren Sie sie beim Schnellstart oder installieren Sie sie über die Seite [Supply Depot](/supply-depot).

### Wie lade ich Dokumente in die Wissensdatenbank hoch?
1. Gehen Sie zur **[Wissensdatenbank →](/knowledge-base)**
2. Laden Sie Ihre Dokumente hoch (PDFs, Textdateien usw.)
3. Die Dokumente werden automatisch verarbeitet und indexiert
4. Stellen Sie Fragen im KI-Chat – die KI greift bei Bedarf auf Ihre hochgeladenen Dokumente zurück

Sie können Dokumente auch wieder aus der Wissensdatenbank entfernen, wenn sie nicht mehr benötigt werden.

Die NOMAD-Dokumentation wird automatisch zur Wissensdatenbank hinzugefügt, wenn der KI-Assistent installiert wird.

### Was ist der System-Benchmark?
Der System-Benchmark testet die Leistung Ihrer Hardware und erzeugt einen NOMAD-Score – eine gewichtete Gesamtwertung aus CPU-, Speicher-, Festplatten- und KI-Leistung. Sie können einen Builder-Tag erstellen (eine NOMAD-typische Identität wie „Tactical-Llama-1234“) und Ihre Ergebnisse mit der [Community-Bestenliste](https://benchmark.projectnomad.us) teilen.

Gehen Sie zum **[System-Benchmark →](/settings/benchmark)**, um einen auszuführen.

### Was ist der Early-Access-Kanal?
Mit dem Early-Access-Kanal können Sie sich dafür entscheiden, Release-Candidate-Builds mit den neuesten Funktionen und Verbesserungen zu erhalten, bevor sie in stabilen Versionen erscheinen. Sie können ihn unter **Einstellungen → Nach Updates suchen** aktivieren oder deaktivieren. Early-Access-Builds können Fehler enthalten – wenn Sie Stabilität bevorzugen, bleiben Sie im stabilen Kanal.

---

## Fehlerbehebung

### Eine Funktion lädt nicht oder zeigt eine leere Seite

**Probieren Sie diese Schritte:**
1. Warten Sie 30 Sekunden – manche Funktionen brauchen Zeit zum Starten
2. Aktualisieren Sie die Seite (Strg+R bzw. Cmd+R)
3. Gehen Sie zurück zur Kommandozentrale und versuchen Sie es erneut
4. Prüfen Sie unter Einstellungen → System, ob der Dienst läuft
5. Versuchen Sie, den Dienst neu zu starten (im Supply Depot Stoppen, dann Starten)

### Karten zeigen einen grauen/leeren Bereich

Die Karten-Funktion benötigt heruntergeladene Kartendaten. Wenn Sie einen leeren Bereich sehen:
1. Gehen Sie zu **Einstellungen → Karten-Manager**
2. Laden Sie Kartenregionen für Ihr Gebiet herunter
3. Warten Sie, bis die Downloads abgeschlossen sind
4. Kehren Sie zu den Karten zurück und aktualisieren Sie die Seite

### ERROR: Failed to load the XML library file '/data/kiwix-library.xml'

Das bedeutet meist, dass der Dienst der Wissensbibliothek gestartet wurde, bevor sein Kiwix-Bibliotheksindex vollständig initialisiert war.

Versuchen Sie diesen Wiederherstellungsablauf:
1. Gehen Sie zum **[Supply Depot](/supply-depot)**
2. Stoppen Sie die **Wissensbibliothek (Kiwix)**
3. Warten Sie 10–15 Sekunden und starten Sie sie dann erneut
4. Besteht der Fehler weiter, führen Sie auf derselben Seite **Neuinstallation erzwingen** für die Wissensbibliothek aus

Aktualisieren Sie nach Abschluss von Neustart bzw. Neuinstallation die Seite der Wissensbibliothek.

### KI-Antworten sind langsam

Lokale KI braucht erhebliche Rechenleistung. So verbessern Sie die Geschwindigkeit:
- **Eine GPU hinzufügen** – Eine NVIDIA-GPU mit dem NVIDIA Container Toolkit kann die KI-Geschwindigkeit um das 10- bis 20-Fache oder mehr steigern
- Andere Anwendungen auf dem Server schließen
- Für ausreichende Kühlung sorgen (Überhitzung führt zu Drosselung)
- Ein kleineres/schnelleres KI-Modell verwenden, falls verfügbar

### Wie aktiviere ich die GPU-Beschleunigung für die KI?

NOMAD erkennt NVIDIA-GPUs automatisch, wenn das NVIDIA Container Toolkit auf dem Host-System installiert ist. So richten Sie die GPU-Beschleunigung ein:

1. **Bauen Sie eine NVIDIA-GPU** in Ihren Server ein (falls noch nicht vorhanden)
2. **Installieren Sie das NVIDIA Container Toolkit** auf dem Host – folgen Sie der [offiziellen Installationsanleitung](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
3. **Installieren Sie den KI-Assistenten neu** – Gehen Sie zum [Supply Depot](/supply-depot), suchen Sie den KI-Assistenten und klicken Sie auf **Neuinstallation erzwingen**

NOMAD erkennt die GPU bei der Installation und konfiguriert die KI automatisch für deren Nutzung. Im Installationsfortschritt sehen Sie „NVIDIA container runtime detected“.

**Tipp:** Führen Sie vor und nach der Einrichtung einen [System-Benchmark](/settings/benchmark) aus, um den Unterschied zu sehen. Mit GPU-Beschleunigung erreichen Systeme typischerweise 100+ Token pro Sekunde gegenüber 10–15 allein mit der CPU.

### Ich habe meine GPU hinzugefügt/geändert, aber die KI ist immer noch langsam

Wenn Sie eine GPU hinzufügen oder austauschen, muss NOMAD den KI-Container neu konfigurieren, damit er sie nutzt:

1. Stellen Sie sicher, dass das **NVIDIA Container Toolkit** auf dem Host installiert ist
2. Gehen Sie zum **[Supply Depot](/supply-depot)**
3. Suchen Sie den **KI-Assistenten** und klicken Sie auf **Neuinstallation erzwingen**

Die erzwungene Neuinstallation erstellt den KI-Container mit aktivierter GPU-Unterstützung neu. Ohne diesen Schritt läuft die KI weiterhin nur auf der CPU.

### Ich sehe die Warnung „GPU passthrough not working“

NOMAD prüft, ob Ihre GPU im KI-Container tatsächlich erreichbar ist. Wird auf dem Host eine GPU erkannt, die im Container nicht funktioniert, sehen Sie auf den Seiten Systeminformationen und KI-Einstellungen ein Warnbanner. Klicken Sie auf die Schaltfläche **„Fix: Reinstall AI Assistant“**, um den Container mit korrektem GPU-Zugriff neu zu erstellen. Ihre heruntergeladenen KI-Modelle bleiben dabei erhalten.

### KI-Chat nicht verfügbar

Die Seite des KI-Chats setzt voraus, dass der KI-Assistent zuvor installiert ist:
1. Gehen Sie zum **[Supply Depot](/supply-depot)**
2. Installieren Sie den **KI-Assistenten**
3. Warten Sie, bis die Installation abgeschlossen ist
4. Der KI-Chat ist dann über den Startbildschirm oder den [Chat](/chat) erreichbar

### Upload in die Wissensdatenbank hängt

Wenn ein Dokument-Upload in die Wissensdatenbank zu hängen scheint:
1. Prüfen Sie unter **Einstellungen → Supply Depot**, ob der KI-Assistent läuft
2. Große Dokumente brauchen Zeit zur Verarbeitung – warten Sie einige Minuten
3. Laden Sie ein kleineres Dokument hoch, um zu prüfen, ob das System funktioniert
4. Prüfen Sie unter **Einstellungen → System** auf Fehlermeldungen

### Benchmark lässt sich nicht an die Bestenliste senden

Um Ergebnisse mit der Community-Bestenliste zu teilen:
- Sie müssen einen **vollständigen Benchmark** ausführen (nicht „Nur System“ oder „Nur KI“)
- Der Benchmark muss KI-Ergebnisse enthalten (der KI-Assistent muss installiert sein und funktionieren)
- Ihr Score muss höher sein als jede frühere Einsendung derselben Hardware

Schlägt das Senden fehl, finden Sie Details in der Fehlermeldung.

### „Service unavailable“ oder Verbindungsfehler

Möglicherweise startet der Dienst noch. Warten Sie 1–2 Minuten und versuchen Sie es erneut.

Besteht das Problem weiter:
1. Gehen Sie zu **Einstellungen → Supply Depot**
2. Suchen Sie den betroffenen Dienst
3. Klicken Sie auf **Neu starten**
4. Warten Sie 30 Sekunden und versuchen Sie es dann erneut

### Downloads hängen oder schlagen fehl

1. Prüfen Sie Ihre Internetverbindung
2. Gehen Sie zu **Einstellungen** und prüfen Sie den verfügbaren Speicherplatz
3. Ist der Speicher voll, löschen Sie nicht benötigte Inhalte
4. Brechen Sie den hängenden Download ab und versuchen Sie es erneut

### Der Server startet nicht

Wenn Sie die Kommandozentrale gar nicht erreichen:
1. Prüfen Sie, ob die Server-Hardware eingeschaltet ist
2. Prüfen Sie die Netzwerkverbindung
3. Versuchen Sie, direkt über die IP-Adresse des Servers zuzugreifen
4. Prüfen Sie die Server-Logs, wenn Sie Konsolenzugriff haben

### Ich habe mein Kolibri-Passwort vergessen

Kolibri-Passwörter werden separat verwaltet:
1. Als Administrator können Sie Benutzerpasswörter in der Benutzerverwaltung von Kolibri zurücksetzen
2. Wenn Sie das Administrator-Passwort vergessen haben, müssen Sie es möglicherweise über die Kommandozeile zurücksetzen (wenden Sie sich an Ihren Administrator)

---

## Updates und Wartung

### Wie aktualisiere ich NOMAD?
1. Gehen Sie zu **Einstellungen → Nach Updates suchen**
2. Ist ein Update verfügbar, klicken Sie, um es zu installieren
3. Das System lädt die Updates herunter und startet automatisch neu
4. Das dauert in der Regel 2–5 Minuten

### Sollte ich regelmäßig aktualisieren?
Ja, solange Sie Internetzugang haben. Updates enthalten:
- Fehlerbehebungen
- Neue Funktionen
- Sicherheitsverbesserungen
- Leistungsverbesserungen

### Kann sich NOMAD automatisch aktualisieren?
Ja. NOMAD kann seine Software, seine installierten Apps und seine Inhalte selbstständig aktuell halten. Automatische Updates sind **optional und standardmäßig deaktiviert** – Sie aktivieren, was Sie möchten, unter **Einstellungen → Updates** (und für Apps zusätzlich mit einem Schalter pro App im Supply Depot). Sie laufen nur innerhalb eines von Ihnen gewählten Zeitfensters, nach Sicherheitsprüfungen, und wenden nie automatisch Sprünge auf eine neue Hauptversion an. Eine ausführliche Anleitung finden Sie im **[Update-Leitfaden](/docs/updates)**.

### Wie aktualisiere ich Inhalte (Wikipedia usw.)?
Inhalts-Updates sind von Software-Updates getrennt:
1. Gehen Sie zu **Einstellungen → Content-Manager** oder zum **Inhalts-Explorer**
2. Prüfen Sie, ob neuere Versionen Ihrer installierten Inhalte verfügbar sind
3. Laden Sie aktualisierte Versionen nach Bedarf herunter

Sie können auch **automatische Inhalts-Updates** aktivieren, damit installierte Wikipedia-/ZIM-Bibliotheken und Kartenregionen sich über Nacht selbst aktualisieren – siehe den [Update-Leitfaden](/docs/updates).

Tipp: Neue Wikipedia-Abzüge erscheinen etwa monatlich.

### Was passiert, wenn ein Update fehlschlägt?
Das System ist darauf ausgelegt, sich ordnungsgemäß zu erholen. Wenn ein Update fehlschlägt:
1. Die vorherige Version sollte weiterhin funktionieren
2. Versuchen Sie das Update später erneut
3. Prüfen Sie unter Einstellungen → System auf Fehlermeldungen

### Wartung über die Kommandozeile

Für erweiterte Fehlersuche oder wenn Sie die Weboberfläche nicht erreichen, enthält NOMAD Hilfsskripte in `/opt/project-nomad`:

**Alle Dienste starten:**
```bash
sudo bash /opt/project-nomad/start_nomad.sh
```

**Alle Dienste stoppen:**
```bash
sudo bash /opt/project-nomad/stop_nomad.sh
```

**Kommandozentrale aktualisieren:**
```bash
sudo bash /opt/project-nomad/update_nomad.sh
```
*Hinweis: Dies aktualisiert nur die Kommandozentrale, nicht die einzelnen Apps. Aktualisieren Sie Apps über die Weboberfläche.*

**NOMAD deinstallieren:**
```bash
curl -fsSL https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/uninstall_nomad.sh -o uninstall_nomad.sh
sudo bash uninstall_nomad.sh
```
*Warnung: Dies kann nicht rückgängig gemacht werden. Alle Daten werden gelöscht.*

---

## Datenschutz und Sicherheit

### Sind meine Daten privat?
Ja. NOMAD läuft vollständig auf Ihrer Hardware. Ihre Suchanfragen, KI-Unterhaltungen und Nutzungsdaten verlassen Ihren Server nie.

### Können andere auf meinen Server zugreifen?
Standardmäßig ist NOMAD in Ihrem lokalen Netzwerk erreichbar. Jeder im selben Netzwerk kann darauf zugreifen. Für öffentliche Netzwerke sollten Sie zusätzliche Sicherheitsmaßnahmen erwägen.

### Sendet die KI Daten irgendwohin?
Nein. Die KI läuft vollständig lokal. Ihre Unterhaltungen werden an keinen externen Dienst gesendet. Der KI-Chat ist in die Kommandozentrale integriert – es gibt keinen separaten Dienst zu konfigurieren.

---

## Weitere Hilfe

### Die KI kann helfen
Stellen Sie im [KI-Chat](/chat) eine Frage. Die lokale KI kann Fragen zu vielen Themen beantworten, auch zur technischen Fehlersuche. Wenn Sie die NOMAD-Dokumentation in die Wissensdatenbank hochgeladen haben, kann sie auch bei NOMAD-spezifischen Fragen helfen.

### Die Dokumentation lesen
Sie sind bereits in der Dokumentation. Nutzen Sie das Menü, um bestimmte Themen zu finden.

### Der Community beitreten
Holen Sie sich Hilfe von anderen NOMAD-Nutzern auf **[Discord](https://discord.com/invite/crosstalksolutions)**.

### Versionshinweise
Sehen Sie, was sich in jeder Version geändert hat: **[Versionshinweise](/docs/release-notes)**
