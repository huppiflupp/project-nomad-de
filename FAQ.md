# Häufig gestellte Fragen (FAQ)

Antworten auf einige der häufigsten Fragen zu Project NOMAD. Dies ist die deutsche Übersetzung der FAQ des Originals; Befehle verweisen auf diesen Fork. Aussagen zum Original-Team („wir“) beziehen sich auf die Entwickler von Project NOMAD (Crosstalk Solutions).

## Kann ich die Ports anpassen, die NOMAD verwendet?

Ja, Sie können die Ports der Kernkomponenten von NOMAD (Kommandozentrale, MySQL, Redis) anpassen. Details dazu finden Sie im Abschnitt [Erweiterte Installation](README.md#erweiterte-installation) der README.

Hinweis: Stand 24.03.2026 unterstützen nur die in der Datei `docker-compose.yml` definierten Kernkomponenten die Anpassung der Ports – die installierbaren Anwendungen (z. B. Ollama, Kiwix usw.) noch nicht. Das Original arbeitet an mehreren Pull Requests, die dies in einer künftigen Version für alle installierbaren Anwendungen ermöglichen sollen.

## Kann ich den Speicherort für die Daten von NOMAD ändern?

Ja, Sie können den Speicherort der NOMAD-Inhalte ändern, indem Sie in der Datei `docker-compose.yml` die entsprechenden Bind-Mounts auf den gewünschten Speicherort auf Ihrem Host legen. Details dazu finden Sie im Abschnitt [Erweiterte Installation](README.md#erweiterte-installation) der README.

## Kann ich die Daten von NOMAD auf einer externen Platte oder einem Netzwerkspeicher ablegen?

Kurz gesagt: Ja, aber das können wir nicht für Sie einrichten (und für die beste Leistung empfehlen wir eine lokale Platte).

Ausführlich: Eigene Speicherpfade, Einhängepunkte und externe Laufwerke (etwa iSCSI-, SMB- oder NFS-Volumes) **sind möglich**, hängen aber von Ihrer individuellen Konfiguration auf dem Host ab, die vor dem Start von NOMAD erfolgen und dann über die compose.yml durchgereicht werden muss, denn das ist eine *Angelegenheit des Hosts*, nicht von NOMAD (siehe oben). NOMAD kann das nicht für Sie einrichten, und das Installationsskript könnte auch nicht alle denkbaren Konfigurationen unterstützen.

## Kann ich NOMAD auf einem Mac, unter WSL2 oder auf einer nicht Debian-basierten Distribution betreiben?

**WSL2 unter Windows** wird von der Community unterstützt, siehe die [WSL2-Anleitung](https://www.projectnomad.us/install/wsl2) (Englisch) – sie beschreibt zwei Installationswege (natives Docker und Docker Desktop) mit allen bekannten Stolperfallen und mit gemessenen Leistungswerten im Vergleich zu echter Hardware.

**macOS und andere, nicht Debian-basierte Linux-Distributionen** werden nicht offiziell unterstützt. Näheres unter [Warum setzt NOMAD ein Debian-basiertes Betriebssystem voraus?](#warum-setzt-nomad-ein-debian-basiertes-betriebssystem-voraus)

## Warum setzt NOMAD ein Debian-basiertes Betriebssystem voraus?

Project NOMAD ist derzeit für Debian-basierte Linux-Distributionen ausgelegt (empfohlen: Ubuntu 26.04 LTS), weil die Installationsskripte und Docker-Konfigurationen auf diese Umgebung abgestimmt sind. Technisch lassen sich die Docker-Container zwar auch auf anderen Betriebssystemen mit Docker-Unterstützung betreiben, doch der Installationsvorgang wurde für nicht Debian-basierte Systeme weder getestet noch optimiert, sodass wir derzeit keinen reibungslosen Ablauf garantieren können.

Die Unterstützung weiterer Betriebssysteme soll später folgen; da die Entwicklungsressourcen eines freien Open-Source-Projekts begrenzt sind, musste das Original-Team seine Arbeit für die erste Version auf wenige Plattformen konzentrieren. Debian-basiertes Linux wurde als Ausgangspunkt gewählt, weil es weit verbreitet, leicht aufzusetzen und eine stabile Umgebung für Docker-Container ist.

Für Windows bietet die [WSL2-Anleitung](https://www.projectnomad.us/install/wsl2) einen von der Community unterstützten Weg. Community-Mitglieder haben im Discord des Originals und in den [GitHub Discussions](https://github.com/Crosstalk-Solutions/project-nomad/discussions) außerdem Anleitungen für andere Plattformen (z. B. macOS) veröffentlicht. Wenn Sie NOMAD auf einem nicht Debian-basierten System betreiben möchten, lohnt sich ein Blick dorthin. Bedenken Sie jedoch, dass dabei Probleme auftreten können, bei denen wir Ihnen nicht helfen können, und dass Sie für die Fehlersuche mehr technisches Wissen brauchen.

## Kann ich NOMAD auf einem Raspberry Pi oder einem anderen ARM-Gerät betreiben?

Project NOMAD ist derzeit für die x86-64-Architektur ausgelegt. Für ARM-Geräte wie den Raspberry Pi wurde es weder getestet noch optimiert, und es gibt keine offiziellen Images für ARM.

Die Unterstützung von ARM-Geräten steht auf der Roadmap des Originals; der anfängliche Schwerpunkt lag auf x86-64-Hardware wegen ihrer weiten Verbreitung und Kompatibilität mit vielen Anwendungen.

Community-Mitglieder haben im Discord des Originals und in den [GitHub Discussions](https://github.com/Crosstalk-Solutions/project-nomad/discussions) eigene ARM-kompatible Images und Installationsanleitungen für Raspberry Pi und andere ARM-Geräte veröffentlicht. Diese werden vom Kernteam nicht offiziell unterstützt; für ihre Funktion und bei Problemen damit kann keine Gewähr übernommen werden.

## Welche Hardware benötigt NOMAD?

Project NOMAD selbst ist sehr schlank und läuft auch auf bescheidener x86-64-Hardware. Welche Anforderungen Ihre Installation tatsächlich hat, bestimmen aber die Werkzeuge und Ressourcen, die Sie mit NOMAD installieren. Detaillierte Kaufempfehlungen für verschiedene Preisklassen finden Sie im [Hardware-Leitfaden](https://www.projectnomad.us/hardware) (Englisch); die Mindest- und empfohlenen Werte stehen in der [README](README.md#systemvoraussetzungen).

## Unterstützt NOMAD andere Sprachen als Englisch?

Im Original ist die Oberfläche nur auf Englisch verfügbar. **Diese Fassung** bringt eine deutsche Oberfläche mit (Standard), die Sie über den Sprachumschalter in der Fußzeile auf Englisch umstellen können; alle 11 Anleitungen in der Anwendung sind ebenfalls auf Deutsch. Die **Inhalte** (Wikipedia/ZIM-Pakete, Karten, Arzneimitteldaten) sind dagegen noch überwiegend englisch. Deutsche Inhaltskataloge, Offline-Maschinenübersetzung und deutschsprachige Fachquellen sind als Folgeprojekte geplant. Zum Mitwirken siehe [CONTRIBUTING.md](CONTRIBUTING.md).

## Mit welchen Technologien ist NOMAD gebaut?

Project NOMAD verwendet unter anderem folgende Technologien:
- **Docker:** zur Containerisierung der Kommandozentrale und ihrer Abhängigkeiten
- **Node.js & TypeScript:** für das Backend der Kommandozentrale, insbesondere das Framework [AdonisJS](https://adonisjs.com/)
- **React:** für das Frontend der Kommandozentrale, mit [Vite](https://vitejs.dev/) und [Inertia.js](https://inertiajs.com/) im Hintergrund
- **MySQL:** als Datenbank der Kommandozentrale
- **Redis:** für Caching, Hintergrundaufträge, „Cron“-Aufgaben und weitere interne Abläufe der Kommandozentrale

NOMAD nutzt das Muster „Docker-outside-of-Docker“ („DooD“): Die Kommandozentrale kann so andere Docker-Container auf dem Host verwalten und steuern, ohne dass Docker selbst in einem Container laufen muss. Das bringt bessere Leistung und Kompatibilität mit einer breiteren Palette von Host-Umgebungen und ermöglicht trotzdem leistungsfähige Container-Verwaltung über die Oberfläche der Kommandozentrale.

## Kann ich NOMAD betreiben, wenn auf meinem Rechner schon Docker-Container laufen?

Ja, Sie können Project NOMAD problemlos auf einem Rechner betreiben, auf dem bereits Docker-Container laufen. NOMAD ist darauf ausgelegt, neben anderen Containern zu bestehen, und stört sie nicht, solange keine Portkonflikte oder Ressourcenengpässe auftreten.

Alle Container von NOMAD tragen das Präfix `nomad_` im Namen und lassen sich so leicht erkennen und getrennt von Ihren anderen Containern verwalten. Prüfen Sie bei der Installation die Ports der NOMAD-Kernkomponenten (Kommandozentrale, MySQL, Redis) und passen Sie sie bei Bedarf an, um Konflikte mit Ihren vorhandenen Containern zu vermeiden.

## Warum braucht NOMAD Zugriff auf den Docker-Socket?

Siehe [Mit welchen Technologien ist NOMAD gebaut?](#mit-welchen-technologien-ist-nomad-gebaut)

## Kann ich beliebige KI-Modelle verwenden?

NOMAD nutzt standardmäßig Ollama in einem Docker-Container, um die LLMs für den KI-Assistenten auszuführen. Ein Modell, das Sie zum Beispiel auf HuggingFace finden, lässt sich in NOMAD daher nicht verwenden. Die Modellliste in den Einstellungen des KI-Assistenten (/settings/models) zeigt möglicherweise nicht alle Modelle, die Sie suchen. Haben Sie auf https://ollama.com/search ein Modell gefunden, das Sie ausprobieren möchten, und es fehlt in den Einstellungen, können Sie es mit einem curl-Befehl herunterladen:  
`curl -X POST -H "Content-Type: application/json" -d '{"model":"MODEL_NAME_HERE"}' http://localhost:8080/api/ollama/models` – ersetzen Sie dabei MODEL_NAME_HERE durch den Modellnamen von der Ollama-Website.

## Muss ich die KI-Funktionen von NOMAD installieren?

Nein, die KI-Funktionen von NOMAD (Ollama, Qdrant, eigene RAG-Pipeline usw.) sind optional und für die Kernfunktionen nicht erforderlich.

## Ist NOMAD wirklich kostenlos? Gibt es versteckte Kosten?

Ja, Project NOMAD ist vollständig freie Open-Source-Software unter der Apache License 2.0. Für die Nutzung von NOMAD selbst fallen keine versteckten Kosten oder Gebühren an, und das Original plant keine „Premium“-Funktionen oder kostenpflichtigen Stufen.

Abgesehen von den Kosten für die Hardware, auf der Sie es betreiben, entstehen keine Kosten.

## Verkaufen Sie Hardware oder vorinstallierte Geräte mit NOMAD?

Nein, derzeit werden weder Hardware noch Geräte mit vorinstalliertem NOMAD verkauft. Project NOMAD ist ein freies Open-Source-Projekt; es gibt ausführliche Installationsanleitungen und Hardwareempfehlungen, damit Sie Ihre eigene NOMAD-Instanz auf Hardware Ihrer Wahl aufsetzen können. Der Preis dieses Selbstbau-Ansatzes sind etwas Einrichtungszeit und technisches Know-how, dafür sind Hardwareauswahl und Konfiguration flexibel und lassen sich an Bedarf, Budget und Vorlieben anpassen.

## Wie schnell werden gemeldete Fehler behoben?

Das Original bemüht sich, Fehler so schnell wie möglich zu beheben, bedenken Sie aber, dass Project NOMAD ein freies Open-Source-Projekt ist, das ein kleines Team Freiwilliger betreut. Fehler werden nach Schwere, Auswirkung auf Anwender und benötigtem Aufwand priorisiert. Kritische Fehler, die viele Anwender betreffen, werden in der Regel schneller behoben, weniger schwere können länger dauern. Neben der Entwicklungsarbeit gehören gründliche Tests dazu, damit eine Korrektur keine neuen Fehler oder Rückschritte verursacht – auch das braucht Zeit.

Die Mitarbeit der Community bei der Fehlersuche ist ausdrücklich erwünscht. Wenn Sie ein Problem haben, sehen Sie bitte im Discord des Originals und in den GitHub Discussions nach möglichen Lösungen oder Behelfen, während an einer offiziellen Korrektur gearbeitet wird.

**Für diese deutsche Fassung:** Fehler der Übersetzung, der Install-Skripte oder des Sprachumschalters melden Sie bitte als Issue in diesem Repository; Fehler des Originals bitte beim [Original-Projekt](https://github.com/Crosstalk-Solutions/project-nomad/issues).

## Wie oft erscheinen neue Funktionen oder Updates?

Das Original veröffentlicht regelmäßig Updates und neue Funktionen; der genaue Zeitpunkt hängt von der Komplexität der Funktionen, den Ressourcen des freiwilligen Entwicklungsteams und dem Feedback der Community ab. Kleinere „Patch“-Versionen mit Fehlerbehebungen und kleinen Verbesserungen erscheinen häufiger, größere Funktionsversionen brauchen mehr Entwicklungs- und Testzeit. Die deutsche Fassung zieht nach: Ihre Versionsnummer folgt der des Originals (siehe [README](README.md#updates-und-versionsnummern)); sie erscheint daher zeitversetzt.

## Ich habe einen Pull Request mit einer neuen Funktion oder Fehlerbehebung eingereicht. Wie lange dauert es üblicherweise bis zur Prüfung und Übernahme?

Wir freuen uns über alle Beiträge und bemühen uns, Pull Requests (PRs) so schnell wie möglich zu prüfen und zu übernehmen. Die Dauer hängt von mehreren Faktoren ab, darunter Umfang der Änderungen, aktuelle Auslastung der Betreuer und nötige zusätzliche Tests oder Überarbeitungen.

Da NOMAD noch ein junges Projekt ist, können PRs (besonders für neue Funktionen) länger dauern, weil zunächst die Kernfunktionen und die Stabilität im Vordergrund stehen. Dennoch gibt man sich Mühe, zeitnah Rückmeldung zu geben und Beitragende über den Stand ihres Beitrags auf dem Laufenden zu halten.

## Ich habe eine Frage, die hier nicht beantwortet wird. Wo bekomme ich Hilfe?

Wenn Ihre Frage in dieser FAQ nicht beantwortet wird, fragen Sie gern im Discord des Originals (https://discord.com/invite/crosstalksolutions) oder auf der Seite der GitHub Discussions (https://github.com/Crosstalk-Solutions/project-nomad/discussions) nach. Für Fragen speziell zur deutschen Fassung eröffnen Sie bitte ein Issue in diesem Repository.

## Ich habe einen Vorschlag für eine neue Funktion oder Verbesserung. Wie kann ich ihn teilen?

Vorschläge sind willkommen und erwünscht. Teilen Sie Ihre Ideen (oder stimmen Sie für bestehende Vorschläge ab) auf der öffentlichen Roadmap des Originals unter https://roadmap.projectnomad.us, wo neue Funktionswünsche gesammelt werden. So stellen Sie sicher, dass Ihr Vorschlag vom Entwicklungsteam und der Community gesehen wird, und andere können ihn unterstützen, was bei der Priorisierung hilft.

## Wie aktualisiere und deinstalliere ich NOMAD?

Updates der Kommandozentrale und der installierten Apps erledigen Sie über die Oberfläche; das Update-Skript für die Kommandozentrale lautet:

```bash
sudo bash /opt/project-nomad/update_nomad.sh
```

Zum vollständigen Entfernen (nicht rückgängig zu machen!) dient das Deinstallationsskript dieses Forks:

```bash
curl -fsSL https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/uninstall_nomad.sh -o uninstall_nomad.sh && sudo bash uninstall_nomad.sh
```
