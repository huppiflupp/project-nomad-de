# Community-Add-ons

Project NOMAD wird mit einer kuratierten Auswahl an integrierten Werkzeugen und Inhalten ausgeliefert, doch die Community hat begonnen, Add-ons zu entwickeln, die die Plattform um spezialisierte Offline-Inhaltspakete erweitern. Dies sind Drittprojekte, die nicht vom NOMAD-Team gepflegt werden. Installieren Sie sie nach eigenem Ermessen und richten Sie Fehlermeldungen oder Funktionswünsche bitte an das jeweilige Repository des Add-ons.

Haben Sie ein NOMAD-Add-on entwickelt? Eröffnen Sie ein Issue im [GitHub-Repository von Project NOMAD](https://github.com/Crosstalk-Solutions/project-nomad/issues/new) oder schreiben Sie uns über das [Kontaktformular auf projectnomad.us](https://www.projectnomad.us/contact). Wir prüfen es dann für die Aufnahme auf dieser Seite.

---

## ZIM-Inhaltspakete

ZIM-Inhaltspakete legen zusätzliches Offline-Referenzmaterial in Ihre bestehende Kiwix-Bibliothek. Sie werden in der Regel mit einem `install.sh`-Skript geliefert, das Quellmaterial herunterlädt, mit `zimwriterfs` eine ZIM-Datei erstellt und diese bei Ihrem laufenden Kiwix-Container registriert.

### Feldhandbücher des US-Militärs

**Repository:** [github.com/jrsphoto/ZIM-military-field-manuals](https://github.com/jrsphoto/ZIM-military-field-manuals)

Rund 180 gemeinfreie Feldhandbücher des US-Militärs zu Feldmedizin, Überleben, Erster Hilfe im Kampfeinsatz, Kartenlesen und mehr. Zusammengefasst in einer durchsuchbaren ZIM-Datei, die sich in Ihre Kiwix-Bibliothek einfügt.

Die fertige ZIM-Datei ist etwa 2 GB groß. Der Builder lädt während des Baus etwa 2 GB an PDF-Quelldateien von archive.org herunter.

### W3Schools-Programmierarchiv

**Repository:** [github.com/kennethbrewer3/ZIM-w3schools-offline](https://github.com/kennethbrewer3/ZIM-w3schools-offline)

Eine vollständige Offline-Kopie der W3Schools-Programmiertutorials zu HTML, CSS, JavaScript, Python, SQL und mehr. Gut geeignet, um Programmieren zu lernen, Syntax nachzuschlagen oder Programmierung in einer Umgebung ohne Internet zu unterrichten.

Die fertige ZIM-Datei ist etwa 700 MB groß. Der Builder lädt während des Baus etwa 6 GB an Quelldateien von einem GitHub-Mirror herunter.

---

## Ein Community-Add-on installieren

Jedes Add-on hat eigene Installationshinweise, aber die meisten ZIM-Pakete folgen demselben Ablauf:

1. Klonen Sie das Repository des Add-ons per SSH auf Ihren NOMAD-Host.
2. Prüfen Sie die README auf erforderliche Build-Abhängigkeiten. Die meisten benötigen `git`, `python3`, `unzip` und `zim-tools`.
3. Führen Sie das enthaltene `install.sh` mit dem Parameter `--deploy` aus und geben Sie dabei den Pfad Ihrer Kiwix-Bibliothek (`/opt/project-nomad/storage/zim`) und den Namen Ihres Kiwix-Containers (`nomad_kiwix_server`) an.
4. Das Skript baut die ZIM-Datei, kopiert sie in Ihre Kiwix-Bibliothek, registriert sie bei Kiwix und startet den Kiwix-Container neu.

Sobald das Skript fertig ist, erscheinen die neuen Inhalte beim nächsten Laden in Ihrer Wissensbibliothek.

Rechnen Sie damit, dass der erste Build je nach Größe des Add-ons und CPU Ihres Hosts von wenigen Minuten bis zu einer Stunde oder länger dauern kann.

---

## Hinweis zum Support

Diese Add-ons werden von der Community entwickelt und gepflegt. Wenn bei einem Installationsskript oder den Inhalten einer ZIM-Datei etwas schiefgeht, eröffnen Sie bitte ein Issue im Repository des jeweiligen Add-ons und nicht bei Project NOMAD. Wir helfen gerne, wenn das Problem NOMAD selbst betrifft, zum Beispiel wenn Kiwix nach einer Installation eine neue ZIM-Datei nicht erkennt, können aber keine Inhalte von Drittanbietern pflegen oder unterstützen.
