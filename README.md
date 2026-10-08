<div align="center">
<img src="admin/public/nomad-primary.svg" width="200" alt="Project NOMAD"/>

# Project NOMAD – Deutsche Fassung
### Wissen, das nie offline geht

</div>

> Unofficial German edition of Project NOMAD. For the original (English) see [Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad).

---

## Was ist das?

Dies ist eine **inoffizielle deutsche Fassung** von [Project NOMAD](https://github.com/Crosstalk-Solutions/project-nomad) der Crosstalk Solutions, LLC. Project NOMAD ist ein eigenständiger, Offline-first-fähiger Wissens- und Bildungsserver mit wichtigen Werkzeugen, Wissen und KI – damit Sie jederzeit und überall informiert und handlungsfähig bleiben.

Dieser Fork steht in keiner Verbindung zu Crosstalk Solutions. Er beruht auf dem Original, steht wie dieses unter der Apache License 2.0 und wird von Zeit zu Zeit mit dem Original abgeglichen. Nähere Angaben finden Sie in der Datei [NOTICE](NOTICE).

## Was ist übersetzt – und was nicht?

**Übersetzt:**
- die Oberfläche der Kommandozentrale (Deutsch ist Standard; über den Sprachumschalter in der Fußzeile wechseln Sie auf Englisch, die Auswahl steht im Cookie `nomad_lang`)
- alle 11 Anleitungen in der Anwendung (`admin/docs-de`)
- README, FAQ sowie die Installations- und Wartungsskripte (`install/`)

**Noch nicht übersetzt:** die Inhalte. Wikipedia- und andere ZIM-Pakete, Karten und Arzneimitteldaten stammen unverändert vom Original.

**Geplant** (Folgeprojekte B, C, D): deutsche Inhaltskataloge, Offline-Maschinenübersetzung einschließlich eines medizinischen Modells sowie deutschsprachige Fachquellen.

**Hinweis zu Creator Packs:** Creator Packs sind in dieser Fassung ausgeblendet, da kein Berechtigungsschlüssel (Entitlement Key) vorliegt.

## Installation und Schnellstart

Project NOMAD lässt sich auf jedem Debian-basierten Betriebssystem installieren (empfohlen: Ubuntu 26.04 LTS; 24.04 LTS und Debian 12 werden ebenfalls unterstützt). Die Installation erfolgt komplett im Terminal; alle Werkzeuge und Ressourcen bedienen Sie anschließend im Browser. Eine Desktop-Umgebung ist nicht nötig, wenn Sie NOMAD als „Server“ einrichten und von anderen Geräten darauf zugreifen möchten.

**Bevor Sie beginnen:** NOMAD selbst benötigt etwa **5 GB Plattenplatz und weniger als 1 GB RAM**. Den meisten Platz belegen die Offline-Inhalte, die Sie später hinzufügen; der Speicherbedarf steigt vor allem durch den KI-Assistenten. Beides finden Sie unter [Systemvoraussetzungen](#systemvoraussetzungen), die Größen einzelner Inhalte in der [FAQ](FAQ.md).

*Hinweis: Zum Ausführen des Installationsskripts sind sudo-/Root-Rechte erforderlich.*

### Schnellinstallation (nur Debian-basierte Systeme)

```bash
sudo apt-get update && \
sudo apt-get install -y curl && \
curl -fsSL https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/install_nomad.sh \
  -o install_nomad.sh && \
sudo bash install_nomad.sh
```

(Das Skript wird bewusst erst heruntergeladen und dann ausgeführt, weil es Rückfragen stellt; per Pipe nach `bash` könnte es Ihre Eingaben nicht lesen.)

Project NOMAD ist nun auf Ihrem Gerät installiert. Öffnen Sie einen Browser und rufen Sie `http://localhost:8080` (oder `http://GERÄTE-IP:8080`) auf, um loszulegen.

Eine ausführliche Schritt-für-Schritt-Anleitung des Originals (einschließlich der Ubuntu-Installation, auf Englisch) finden Sie im [Installationsleitfaden](https://www.projectnomad.us/install). Für Windows gibt es die von der Community unterstützte [WSL2-Anleitung](https://www.projectnomad.us/install/wsl2) (Englisch), die native Docker- und Docker-Desktop-Installation abdeckt.

### Erweiterte Installation

Für mehr Kontrolle kopieren Sie die [Docker-Compose-Vorlage](https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/management_compose.yaml) in eine Datei `docker-compose.yml` und passen sie an (ersetzen Sie alle Platzhalter durch Ihre tatsächlichen Werte). Starten Sie danach mit `docker compose up -d` die Kommandozentrale und ihre Abhängigkeiten. Hinweis: Diese Methode ist nur für fortgeschrittene Anwender gedacht, da sie Docker-Kenntnisse und manuelle Konfiguration voraussetzt.

## Updates und Versionsnummern

Updates installieren Sie aus der Oberfläche der Kommandozentrale. Optional lassen sich Minor- und Patch-Updates automatisch einspielen (siehe unten). Das Update-Skript `update_nomad.sh` finden Sie im Abschnitt [Hilfsskripte](#hilfsskripte).

Die Versionsnummern dieser Fassung folgen reinem SemVer und knüpfen an das Original an: **Patch = 100 × Patch des Originals + n**.

| Deutsche Fassung | beruht auf Project NOMAD |
|---|---|
| 1.35.1 (erste deutsche Version) | 1.35.0 |
| 1.35.101 | 1.35.1 |
| 1.36.1 | 1.36.0 |

Eine deutsche Version „1.35.1 beruht auf 1.35.0“; erscheint im Original 1.35.1, wird daraus 1.35.101, bei Original 1.36.0 entsprechend 1.36.1.

## Fehler melden

- **Fehler in der deutschen Fassung** (Übersetzung, Install-Skripte, Sprachumschalter, Anleitungen): bitte als Issue in diesem Repository melden.
- **Fehler im Original** (Funktionen, die auch in der englischen Fassung auftreten): bitte beim [Original-Projekt](https://github.com/Crosstalk-Solutions/project-nomad/issues) melden.

Sicherheitslücken melden Sie bitte gemäß [SECURITY.md](SECURITY.md).

## So funktioniert es

NOMAD besteht aus einer Verwaltungsoberfläche („Kommandozentrale“) samt API, die eine Sammlung containerisierter Werkzeuge und Ressourcen über [Docker](https://www.docker.com/) steuert. Sie übernimmt Installation, Konfiguration und Updates – Sie müssen sich darum nicht kümmern.

**Eingebaute Funktionen:**
- **KI-Chat mit Wissensdatenbank** – lokaler KI-Chat auf Basis von [Ollama](https://ollama.com/) oder einer OpenAI-kompatiblen Software wie LM Studio oder llama.cpp, mit Dokument-Upload und semantischer Suche (RAG über [Qdrant](https://qdrant.tech/))
- **Wissensbibliothek** – Wikipedia offline, medizinische Nachschlagewerke, E-Books und mehr über [Kiwix](https://kiwix.org/)
- **Bildungsplattform** – Khan-Academy-Kurse mit Lernfortschritt über [Kolibri](https://learningequality.org/kolibri/)
- **Offline-Karten** – herunterladbare regionale Karten über [ProtoMaps](https://protomaps.com)
- **Datenwerkzeuge** – Verschlüsselung, Kodierung und Analyse über [CyberChef](https://gchq.github.io/CyberChef/)
- **Notizen** – lokale Notizen mit [FlatNotes](https://github.com/dullage/flatnotes)
- **System-Benchmark** – Hardware-Bewertung mit einer [Community-Bestenliste](https://benchmark.projectnomad.us)
- **Supply Depot** – ein App-Katalog für die Installation per Klick (PDF-Werkzeuge, Dateibrowser, E-Book-Bibliothek, Passwortmanager u. a.) sowie die Möglichkeit, eigene Docker-Container zu betreiben
- **Automatische Updates** – optionale, selbsttätige Updates für die Kernsoftware, installierte Apps und Offline-Inhalte nach einem Zeitplan, den Sie bestimmen
- **Schnellstart-Assistent** – geführte Ersteinrichtung mit kuratierten Inhaltssammlungen

Außerdem bietet NOMAD eingebaute Werkzeuge wie eine Wikipedia-Auswahl, die ZIM-Bibliotheksverwaltung und den Inhalts-Explorer.

## Funktionsübersicht

| Funktion | Technik | Was Sie bekommen |
|-----------|-----------|-------------|
| Wissensbibliothek | Kiwix | Wikipedia offline, medizinische Nachschlagewerke, Überlebensratgeber, E-Books |
| KI-Assistent | Ollama + Qdrant | Eingebauter Chat mit Dokument-Upload und semantischer Suche |
| Bildungsplattform | Kolibri | Khan-Academy-Kurse, Lernfortschritt, Mehrbenutzerbetrieb |
| Offline-Karten | ProtoMaps | Herunterladbare regionale Karten zum Ansehen und Suchen offline |
| Datenwerkzeuge | CyberChef | Verschlüsselung, Kodierung, Hashing und Datenanalyse |
| Notizen | FlatNotes | Lokale Notizen mit Markdown-Unterstützung |
| System-Benchmark | Eingebaut | Hardware-Bewertung, Builder Tags und Community-Bestenliste |
| Supply Depot | Eingebaut | App-Katalog per Klick + eigene Docker-Container |

## Systemvoraussetzungen

Viele vergleichbare Offline-Notfallrechner laufen auf minimaler, genügsamer Hardware. Project NOMAD ist hier das Gegenteil: Um die verfügbaren KI-Werkzeuge zu betreiben, empfehlen wir ausdrücklich ein leistungsstarkes Gerät mit GPU, damit Sie Ihre Installation voll ausschöpfen können.

Im Kern ist NOMAD aber sehr schlank. Für eine minimale Installation der Verwaltungsanwendung genügen folgende Mindestanforderungen:

*Hinweis: Project NOMAD wird von keinem Hardwarehersteller gesponsert und ist so herstellerunabhängig wie möglich ausgelegt. Die genannte Hardware dient nur als Beispiel bzw. zum Vergleich.*

#### Mindestanforderungen
- Prozessor: 2-GHz-Dual-Core-Prozessor oder besser
- RAM: 4 GB Arbeitsspeicher (der gesamte Stack ohne KI läuft mit weniger als 1 GB)
- Speicher: mindestens 5 GB freier Plattenplatz (für eine komfortable Installation besser 10 GB)
- Betriebssystem: Debian-basiert (empfohlen: Ubuntu 26.04 LTS)
- Stabile Internetverbindung (nur während der Installation nötig)

Mit dem KI-Assistenten wächst die Installation auf etwa **25 GB**, weil Ollama und ein allgemeines Modell beide groß sind und ein Modell beim Antworten ungefähr seine Downloadgröße an Speicher braucht. Dieser Speicher kommt bei einer dedizierten GPU aus dem VRAM, sonst aus dem Arbeitsspeicher – das ist der Hauptgrund für die deutlich höheren Werte unten.

Zum Betrieb von LLMs und der übrigen KI-Werkzeuge:

#### Empfohlene Ausstattung
- Prozessor: AMD Ryzen 7 oder Intel Core i7 oder besser
- RAM: 32 GB Arbeitsspeicher
- Grafik: NVIDIA RTX 3060 oder AMD-Äquivalent oder besser (mehr VRAM = größere Modelle)
- Speicher: mindestens 250 GB freier Plattenplatz (vorzugsweise SSD)
- Betriebssystem: Debian-basiert (empfohlen: Ubuntu 26.04 LTS)
- Stabile Internetverbindung (nur während der Installation nötig)

**Detaillierte Kaufempfehlungen für drei Preisklassen (150 bis über 1.000 US-Dollar) finden Sie im [Hardware-Leitfaden](https://www.projectnomad.us/hardware)** (Englisch).

Noch einmal: Project NOMAD selbst ist sehr schlank – die Werkzeuge und Ressourcen, die Sie mit NOMAD installieren, bestimmen die benötigte Hardware für Ihren Einsatzzweck.

#### KI-Modelle auf einem anderen Rechner betreiben

Standardmäßig versucht der NOMAD-Installer, beim Installieren des KI-Assistenten Ollama auf dem Host einzurichten. Möchten Sie das KI-Modell auf einem anderen Rechner betreiben, öffnen Sie die Einstellungen des KI-Assistenten und tragen die URL eines Ollama- oder OpenAI-kompatiblen API-Servers (z. B. LM Studio) ein.  
Wenn Sie Ollama auf einem anderen Rechner nutzen, müssen Sie den Server mit der Option `OLLAMA_HOST=0.0.0.0` starten.  
Ollama ist der bevorzugte Weg, da es Funktionen wie den Modell-Download bietet, die die OpenAI-API nicht unterstützt. Bei LM Studio müssen Sie Modelle zum Beispiel mit LM Studio selbst herunterladen.
Für die Einrichtung des Ollama-/OpenAI-Servers auf dem anderen Rechner sind Sie selbst verantwortlich.

## Häufig gestellte Fragen (FAQ)

Antworten auf häufige Fragen finden Sie in der [FAQ](FAQ.md).

## Internetnutzung und Datenschutz

Project NOMAD ist für den Offline-Betrieb gedacht. Eine Internetverbindung ist nur bei der Erstinstallation (zum Herunterladen von Abhängigkeiten) nötig und wenn Sie später zusätzliche Werkzeuge und Ressourcen herunterladen. Ansonsten braucht NOMAD keine Internetverbindung und enthält KEINERLEI eingebaute Telemetrie.

Zum Testen der Internetverbindung fragt NOMAD zuerst den Hilfsendpunkt von Cloudflare ab, `https://1.1.1.1/cdn-cgi/trace`. Ist dieser nicht erreichbar (etwa weil Ihr Netzwerk `1.1.1.1` sperrt), weicht NOMAD auf andere Endpunkte aus, die die Anwendung ohnehin kontaktiert (die GitHub-API und die Project-NOMAD-API), und gilt als online, sobald einer davon antwortet.

Den Endpunkt für diese Prüfung können Sie auf zwei Wegen ändern: über die Oberfläche unter **Einstellungen → Erweitert** (wird lokal auf Ihrer Instanz gespeichert) oder über die Umgebungsvariable `INTERNET_STATUS_TEST_URL`. Ist die Umgebungsvariable gesetzt, hat sie immer Vorrang vor dem in der Oberfläche eingestellten Wert. Ist keines von beiden gesetzt, gelten die oben genannten Standardwerte.

## Sicherheit

Project NOMAD soll absichtlich offen und ohne Hürden verfügbar sein – es enthält keine Anmeldung. Wenn Sie Ihr Gerät nach der Installation mit einem lokalen Netzwerk verbinden (etwa damit andere Geräte auf die Ressourcen zugreifen können), können Sie Ports sperren oder öffnen, um zu steuern, welche Dienste erreichbar sind.

**Wird es künftig eine Anmeldung geben?** Vielleicht. Derzeit hat das keine Priorität, aber bei genügend Nachfrage könnte das Original in einer späteren Version eine optionale Authentifizierung einbauen, etwa für Familien mit Jugendschutz oder Klassen mit Lehrer- und Administratorkonten. Dazu gibt es einen Vorschlag auf der öffentlichen Roadmap des Originals (Englisch): https://roadmap.projectnomad.us/posts/1/user-authentication-please-build-in-user-auth-with-admin-user-roles

Bis dahin empfehlen wir, den Zugriff auf Netzwerkebene zu steuern, wenn Sie Ihre NOMAD-Instanz für andere Geräte im lokalen Netz freigeben. NOMAD ist nicht dafür ausgelegt, direkt im Internet erreichbar zu sein; wir raten ausdrücklich davon ab, außer Sie wissen genau, was Sie tun, haben geeignete Sicherheitsmaßnahmen getroffen und kennen die Risiken.

## Mitwirken

Beiträge sind willkommen. Hinweise dazu finden Sie in [CONTRIBUTING.md](CONTRIBUTING.md). Für die Pflege dieses Forks siehe außerdem [de/README.md](de/README.md).

### Automatische Updates testen (Trockenlauf)

Die Kommandozentrale kann **Minor-/Patch-Updates** ihrer selbst automatisch innerhalb eines einstellbaren Zeitfensters installieren – nach einer Wartezeit und nur, wenn die Vorabprüfungen bestehen (genug Plattenplatz für das neue Image, keine laufenden Downloads oder App-Installationen). Hauptversionen (Major) erfordern immer ein manuelles Update.

Da sich diese Logik mit echten Versionssprüngen kaum prüfen lässt, führt ein Ace-Befehl die **gesamte Entscheidungskette aus, ohne je ein Update auszulösen**. Führen Sie ihn im Verzeichnis `admin/` aus:

```bash
# 1) Deterministische Szenarien – ohne Netzwerk, Datenbank oder Docker.
#    Prüft jeden Zweig (nur Major, Wartezeit, Vorabversion/Entwurf, Zeitfenster-Umbruch, …)
#    und endet bei Fehlern mit einem Wert ungleich 0, ist also für CI geeignet.
node ace auto-update:dry-run --scenarios

# 2) Simulieren: „Was passiert, wenn ich gerade Version 1.32.0 betreibe?“
#    gegen den LIVE-Feed der GitHub-Releases und mit echten Vorabprüfungen:
node ace auto-update:dry-run --current=1.32.0 --force-enabled

# 3) Vollständig offline mit vorgegebener Release-Liste und fester Uhrzeit:
node ace auto-update:dry-run --current=1.32.0 --force-enabled \
  --releases-file=./fixtures/releases.json --now=2026-06-04T21:00:00Z \
  --window-start=20:00 --window-end=23:00 --cooloff=72 --skip-preflight
```

Der Befehl gibt die ermittelte Entscheidung aus – aktuelle Version, ob die Uhrzeit im Zeitfenster liegt, das infrage kommende Ziel (falls vorhanden) und Hindernisse bei den Vorabprüfungen – und endet mit einem eindeutigen Urteil wie `WOULD UPDATE → v1.33.2` oder `WOULD NOT UPDATE (outside-window): …`. **Es wird nie ein echtes Update angefordert.**

| Option | Beschreibung |
|------|-------------|
| `--scenarios` | Die eingebaute deterministische Szenarienprüfung ausführen und beenden |
| `--current=<version>` | Diese Version als aktuell laufende simulieren (z. B. `1.32.0`) |
| `--force-enabled` | Automatische Updates als aktiviert behandeln, unabhängig von der gespeicherten Einstellung |
| `--cooloff=<hours>` | Wartezeit überschreiben |
| `--window-start=<HH:MM>` / `--window-end=<HH:MM>` | Update-Zeitfenster überschreiben |
| `--now=<ISO timestamp>` | Die Uhr auf einen bestimmten Zeitpunkt setzen |
| `--releases-file=<path>` | Eine lokale JSON-Liste von Releases statt GitHub verwenden (offline) |
| `--skip-preflight` | Die Vorabprüfungen für Docker, Plattenplatz und Warteschlange überspringen |

## Community und Ressourcen

- **Original-Projekt:** [Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad) – Quelle dieser Fassung
- **Website des Originals:** [www.projectnomad.us](https://www.projectnomad.us) (Englisch)
- **Discord des Originals:** [Community beitreten](https://discord.com/invite/crosstalksolutions) (Englisch)
- **Benchmark-Bestenliste:** [benchmark.projectnomad.us](https://benchmark.projectnomad.us) – So schneidet Ihre Hardware im Vergleich zu anderen NOMAD-Systemen ab
- **FAQ:** [FAQ.md](FAQ.md) – Antworten auf häufige Fragen
- **Community-Add-ons:** [admin/docs/community-add-ons.md](admin/docs/community-add-ons.md) – Von der Community erstellte Inhaltspakete (Englisch)

## Lizenz

Project NOMAD steht unter der [Apache License 2.0](LICENSE). Urheberrecht des Originals: Crosstalk Solutions, LLC; siehe [NOTICE](NOTICE).

## Hilfsskripte

Nach der Installation bringt Project NOMAD einige Hilfsskripte mit, falls Sie Probleme beheben oder Wartungsarbeiten durchführen müssen, die sich nicht über die Kommandozentrale erledigen lassen. Alle Skripte liegen im Installationsverzeichnis von Project NOMAD, `/opt/project-nomad`.

###### Startskript – startet alle installierten Project-NOMAD-Container
```bash
sudo bash /opt/project-nomad/start_nomad.sh
```

###### Stoppskript – stoppt alle installierten Project-NOMAD-Container
```bash
sudo bash /opt/project-nomad/stop_nomad.sh
```

###### Update-Skript – versucht, die neuesten Images der Kommandozentrale und ihrer Abhängigkeiten (z. B. MySQL) zu laden und die Container neu zu erstellen. Hinweis: Es aktualisiert *nur* die Container der Kommandozentrale, nicht die installierbaren Anwendungen – das erledigen Sie über die Oberfläche der Kommandozentrale
```bash
sudo bash /opt/project-nomad/update_nomad.sh
```

###### Deinstallationsskript – Sie möchten neu anfangen? Mit dem Deinstallationsskript geht es einfach. Hinweis: Das lässt sich nicht rückgängig machen!
```bash
curl -fsSL https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/uninstall_nomad.sh -o uninstall_nomad.sh && sudo bash uninstall_nomad.sh
```
