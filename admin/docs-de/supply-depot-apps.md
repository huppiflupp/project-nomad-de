# Supply-Depot-Apps

Im Supply Depot installieren Sie zusätzliche Apps auf Ihrem NOMAD, die über die eingebauten Werkzeuge hinausgehen. Jede App läuft in einem eigenen Container auf Ihrem NOMAD, vollständig offline, und erhält eine Schaltfläche **Öffnen**, sobald die Installation abgeschlossen ist.

Diese Seite beschreibt, was Sie wissen müssen, um jede App *speziell auf dem NOMAD* in Betrieb zu nehmen: ob eine Anmeldung nötig ist, wie die Standard-Zugangsdaten lauten, wo Ihre Dateien landen und was Sie vorab bereithalten sollten. Sie erklärt nicht, wie die Apps selbst bedient werden. Jede App ist ein eigenes Open-Source-Projekt mit eigener Dokumentation, und wir verlinken bei jeder App dorthin.

Ein kurzer Hinweis zu Anmeldungen: Einige dieser Apps haben eigene Konten, getrennt von Ihrer NOMAD-Anmeldung. Wo eine App eine Anmeldung verlangt, nennen wir Ihnen die Anfangs-Zugangsdaten und sagen, ob Sie diese ändern sollten.

---

## Ihre Apps verwalten

Jede App, die Sie installieren, erhält auf ihrer Karte ein Menü **Verwalten**. Dort können Sie:

- **Docs** — direkt zu den NOMAD-Einstiegshinweisen für diese App springen (dieselben App-Abschnitte, die Sie weiter unten finden).
- **Bearbeiten** — die Einstellungen einer App ändern: Port-Zuordnungen, Volume-Bindungen, Umgebungsvariablen sowie Speicher- und CPU-Limits. Das funktioniert auch bei kuratierten Apps, nicht nur bei eigenen. Ihre Änderungen werden mit der bestehenden Konfiguration der App zusammengeführt, sodass erweiterte Einstellungen (etwa der GPU-Zugriff beim KI-Assistenten) erhalten bleiben, und eine bearbeitete App wird nicht mehr durch Katalog-Updates überschrieben.
- **Protokolle** und **Statistiken** — eine Live-Ansicht der Protokollausgabe einer App oder ihrer aktuellen Speicher- und CPU-Nutzung öffnen, praktisch, wenn etwas nicht wie erwartet funktioniert.
- **Update** und **Entfernen** — die neueste Version einer App holen oder die App entfernen (auf Wunsch samt ihrem Image). Wenn der neue Container nach einem Update nicht startet, kehrt NOMAD automatisch zur funktionierenden Version zurück.

**Welche Version läuft:** Jede App-Karte zeigt die installierte Version direkt neben dem App-Namen (zum Beispiel `Kiwix · 3.7.0`). Ist eine neuere Version verfügbar, erscheint auf der Karte ein orangefarbenes Label **Update verfügbar**, damit es auf einen Blick zu erkennen ist.

**Eigene „Öffnen“-Links:** Standardmäßig verweist die Schaltfläche **Öffnen** auf die App unter der eigenen Adresse Ihres NOMAD. Wenn Sie einen Reverse-Proxy oder lokales DNS betreiben und eine App lieber unter einer gefälligeren Adresse öffnen möchten (zum Beispiel `https://jellyfin.myhomelab.net`), legen Sie über **Verwalten › Bearbeiten** eine eigene Start-URL fest. NOMAD bewahrt Ihren ursprünglichen Link sicher auf, sodass Sie jederzeit zurückwechseln können, und die Änderung bleibt über Upgrades hinweg erhalten.

**Apps automatisch aktuell halten:** Installierte Apps können sich selbstständig aktualisieren. Das ist auf zwei Ebenen optional zuschaltbar — ein Hauptschalter unter **Einstellungen → Updates** und ein Schalter pro App im Supply Depot — und es werden immer nur Minor- und Patch-Updates automatisch eingespielt (Major-Versionen bleiben stets manuell). Die ganze Geschichte finden Sie in der [Update-Anleitung](/docs/updates).

---

## Eine eigene App einbinden

Über den kuratierten Katalog hinaus kann das Supply Depot **Ihren eigenen Docker-Container** als verwaltete App neben allem anderen betreiben. Klicken Sie auf **Eigene App hinzufügen** und teilen Sie NOMAD Folgendes mit:

- das **Image**, das geladen werden soll (zum Beispiel `ghcr.io/owner/app:1.2.3`),
- alle **Port-Zuordnungen**, **Volume-Bindungen**, **Umgebungsvariablen** und **Speicher-/CPU-Limits**, die es benötigt.

Während Sie die Angaben eintragen, führt NOMAD live eine Vorabprüfung durch und warnt Sie vor Dingen wie Port-Konflikten oder riskanten Einstellungen. Manche Warnungen (eine nicht vertrauenswürdige Registry oder ein `:latest`-Tag, dessen Version sich nicht verfolgen lässt) sind nur Hinweise, und Sie können **Verstanden – trotzdem installieren** wählen; wirklich unsichere Konfigurationen werden dagegen grundsätzlich blockiert.

Nach der Installation verhält sich eine eigene App wie jede andere: Sie erhält dasselbe Menü **Verwalten** (Bearbeiten, Protokolle, Statistiken, Update, Entfernen), zeigt ihre Version auf der Karte an und kann sich für automatische Updates anmelden. NOMAD sichert Host-Pfad-Bindungen ab und beschränkt Protokolle und Statistiken auf seine eigenen verwalteten Container, sodass eine eigene App nicht über das hinausgreifen kann, was Sie ihr zugestehen.

> Eine eigene App ist genau das — Ihre eigene. NOMAD führt sie aus und hält sich heraus; für Software außerhalb des kuratierten Katalogs gibt es weder Einrichtungsanleitungen noch Hilfe. Wie die App zu verwenden ist, entnehmen Sie der Dokumentation des jeweiligen Projekts.

---

## Stirling PDF {% #stirling-pdf %}

Eine vollständige Werkzeugkiste für die Arbeit mit PDFs, komplett auf Ihrer eigenen Hardware. Dateien zusammenführen und teilen, in PDF und aus PDF konvertieren, komprimieren, drehen, Passwörter hinzufügen oder entfernen, eingescannte Dokumente per OCR durchsuchbar machen, signieren, stempeln und schwärzen. Es sind über 50 Werkzeuge enthalten, und weil alles lokal läuft, verlässt keines Ihrer Dokumente jemals Ihren NOMAD.

**Offizielle Website:** [stirlingpdf.com](https://stirlingpdf.com) · **Quellcode:** [github.com/Stirling-Tools/Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF)

**Beim ersten Öffnen:** Die App öffnet direkt die Werkzeuge, ohne Anmeldung. Wir haben Stirling so eingerichtet, dass der Anmeldebildschirm entfällt, denn auf einem NOMAD ist es ein persönliches Werkzeug in Ihrem eigenen Netzwerk, und eine Passwortschranke steht dabei nur im Weg. Unten links sehen Sie „Guest“, das ist normal.

**Achtung, der Start dauert:** Stirling PDF ist eine große Java-Anwendung. Geben Sie ihr nach der Installation 30 bis 60 Sekunden, bis sie fertig gestartet ist und sauber lädt. Außerdem braucht sie ordentlich Arbeitsspeicher (etwa ein Gigabyte), sodass sie sich auf einem NOMAD mit Reserven wohler fühlt.

**Sie möchten ein Passwort?** Wenn Stirling lieber eine Anmeldung verlangen soll (etwa weil mehrere Personen Ihren NOMAD teilen und Sie diese App absichern möchten), können Sie die Anmeldung über NOMAD wieder einschalten:

1. Suchen Sie auf der Seite Supply Depot Stirling PDF und klicken Sie auf **Verwalten > Bearbeiten**.
2. Ändern Sie unter **Umgebungsvariablen** `SECURITY_ENABLELOGIN=false` in `SECURITY_ENABLELOGIN=true`.
3. Speichern Sie. NOMAD baut die App neu auf, und der Anmeldebildschirm kehrt zurück.

Bei der ersten Anmeldung danach verwenden Sie den Benutzernamen `admin` und das Passwort `stirling`. Stirling verlangt dann sofort, dass Sie ein eigenes Passwort festlegen. Beachten Sie, dass dies der einzige Weg ist, die Anmeldung wieder einzuschalten: Das Einstellungsmenü von Stirling ist nur für angemeldete Benutzer zugänglich. Solange die Anmeldung aus ist, schalten Sie sie daher im Bearbeiten-Dialog von NOMAD ein, nicht innerhalb von Stirling.

**Ihre Daten:** Ihre Einstellungen liegen im Ordner `storage/stirling-pdf` auf Ihrem NOMAD. Die PDFs, die Sie bearbeiten, werden für den Vorgang hochgeladen und anschließend auf Ihr eigenes Gerät heruntergeladen. Stirling ist keine Langzeitbibliothek und behält Ihre Dokumente deshalb nicht.

**Woher Ihre PDFs kommen (und warum Sie die Dateien Ihres NOMAD nicht sehen):** Stirling arbeitet mit Dateien des Geräts, das Sie gerade benutzen, also Ihres Laptops, Telefons oder Tablets. Sie klicken auf „Open from computer“, wählen ein PDF, bearbeiten es und laden das Ergebnis wieder auf dieses Gerät herunter. Stirling kann nicht auf anderweitig auf Ihrem NOMAD gespeicherte Dateien zugreifen und zeigt Ihnen daher weder Ihren Bücher-Ordner noch Ihre Dokumente der Wissensdatenbank noch etwas aus dem File Browser. Liegt das gewünschte PDF bereits auf Ihrem NOMAD, laden Sie es zuerst dort herunter, wo es liegt (zum Beispiel im File Browser), und öffnen dann diese Kopie in Stirling. Das ist ein zusätzlicher Schritt, aber genau deshalb bleiben Ihre Dateien dort, wo Sie sie abgelegt haben, statt in eine andere App gezogen zu werden.

**Funktioniert offline:** Alle PDF-Werkzeuge laufen lokal auf Ihrem NOMAD, daher funktioniert die Werkzeugkiste selbst vollständig offline. Einige Nebenfunktionen greifen auf das Internet zu und tun nichts, solange Sie getrennt sind: die Importoption „Google Drive“ und die Links in der Fußzeile (Survey, Discord, GitHub). Für die eigentliche Arbeit an PDFs spielt nichts davon eine Rolle. Die einzige Kernfunktion mit einem Online-Anteil ist OCR, das Text aus eingescannten Seiten liest: Sie wird mit bereits installiertem Englisch ausgeliefert, und nur das Hinzufügen weiterer Sprachen würde eine Verbindung erfordern.

## File Browser {% #file-browser %}

Ein webbasierter Dateimanager für Ihren NOMAD. Ordner durchsuchen, Dateien hoch- und herunterladen, Ordner anlegen, umbenennen, verschieben und löschen, alles im Browser und ohne etwas auf Ihrem Computer zu installieren. Praktisch, um Dateien auf das Gerät und von ihm herunter zu bekommen oder aufzuräumen, ohne auf die Kommandozeile zu wechseln.

**Offizielle Website:** [filebrowser.org](https://filebrowser.org) · **Quellcode:** [github.com/filebrowser/filebrowser](https://github.com/filebrowser/filebrowser)

**Beim ersten Öffnen:** Sie sehen einen Anmeldebildschirm. Melden Sie sich mit dem Benutzernamen `admin` und dem Passwort `nomad` an. **Ändern Sie dieses Passwort sofort.** Es ist auf jedem NOMAD dasselbe Standardpasswort, solange Sie es nicht ändern, könnte also jeder in Ihrem Netzwerk, der es kennt, hinein. Klicken Sie auf das Zahnrad für die Einstellungen, öffnen Sie Ihre Profileinstellungen und legen Sie ein neues Passwort fest.

Anders als die meisten Apps hier behält File Browser seine Anmeldung absichtlich bei. Die App kann echte Dateien auf Ihrem NOMAD umbenennen und löschen, daher ist ein Passwort selbst im eigenen Netzwerk die richtige Wahl.

**Was Sie sehen können:** File Browser zeigt Ihnen die Inhaltsordner Ihres NOMAD an einem Ort:

- **books** - E-Books, einschließlich allem, was Calibre-Web lesen soll
- **maps** - heruntergeladene Kartendaten
- **media** - Video, Musik und Fotos, einschließlich allem, was Jellyfin bereitstellen soll
- **zim** - heruntergeladene Offline-Inhalte wie Wikipedia und andere Nachschlagebibliotheken
- **kb_uploads** - Dokumente, die Sie der Wissensdatenbank hinzugefügt haben

In diesen Ordnern können Sie hochladen, herunterladen, umbenennen, verschieben und löschen, und alles, was Sie in die oberste Ebene legen, wird ebenfalls gespeichert. Die Ordner im Hintergrund, mit denen die Apps tatsächlich arbeiten (etwa die KI-Modelle, der Suchindex und der Passwort-Tresor), sind bewusst aus File Browser ausgeblendet, damit Sie sie nicht versehentlich durchsuchen oder löschen können.

> **Ein Wort zum Löschen:** Was Sie hier löschen, ist wirklich weg, es gibt keinen Papierkorb. Die Inhalte sind meist ersetzbar (eine Karte oder eine Wikipedia-Bibliothek lässt sich erneut herunterladen), aber wenn Sie ein selbst hinzugefügtes Buch oder Video löschen, ist diese Kopie verloren. Löschen Sie mit derselben Sorgfalt wie auf Ihrem eigenen Computer.

**Funktioniert offline:** Vollständig offline. File Browser läuft komplett auf Ihrem NOMAD und greift für nichts auf das Internet zu, es funktioniert also verbunden wie getrennt genau gleich.

## Calibre-Web {% #calibre-web %}

Ein webbasierter Reader und Bibliotheksverwalter für Ihre E-Book-Sammlung. Lesen Sie Bücher direkt im Browser, ordnen Sie sie nach Autor, Reihe und Schlagwörtern und senden Sie sie an einen Kindle oder einen anderen E-Reader. Die App arbeitet mit dem Ordner „books“ auf Ihrem NOMAD zusammen, sodass Ihre gesamte Bibliothek auf dem Gerät liegt und überallhin mitgeht.

**Offizielle Website:** [github.com/janeczku/calibre-web](https://github.com/janeczku/calibre-web)

**Beim ersten Öffnen:** Calibre-Web braucht eine Bibliothek, auf die es zeigen kann, und NOMAD legt bei der Installation eine leere für Sie an, sodass Sie nicht an einem Einrichtungsfehler hängen bleiben. Der einmalige Ablauf:

1. Öffnen Sie Calibre-Web. Es landet auf einem Bildschirm **Database Configuration**.
2. Geben Sie im Feld **Location of Calibre Database** `/books` ein und klicken Sie auf **Save**. Sie sehen „Database Settings updated“, und Ihre (leere) Bibliothek öffnet sich.
3. Das war die gesamte Einrichtung. Ihre Bibliothek ist bereit, gefüllt zu werden.

Falls Sie irgendwann zur Anmeldung aufgefordert werden, lautet die Standard-Anmeldung `admin` / `admin123`. **Ändern Sie dieses Passwort**, sobald Sie angemeldet sind (klicken Sie oben rechts auf `admin`, dann auf Edit). Es ist auf jedem NOMAD dasselbe Standardpasswort.

**Bücher hinzufügen:** Das Hochladen über die Webseite ist standardmäßig ausgeschaltet. Um es einzuschalten, gehen Sie auf **Admin** (oben rechts) und bearbeiten die Basiskonfiguration so, dass Uploads erlaubt sind; danach erscheint eine Schaltfläche Upload. Sie können E-Book-Dateien auch direkt über File Browser in den Ordner „books“ legen und dann mit dem „Scan“ von Calibre-Web einlesen lassen.

**Ihre Daten:** Ihre Bibliothek liegt im Ordner `books` auf Ihrem NOMAD (demselben `books`, den Sie im File Browser sehen). Jedes Buch, das Sie hinzufügen, wird dort gespeichert; die Sicherung dieses einen Ordners sichert also Ihre gesamte Sammlung.

**Funktioniert offline:** Lesen und Verwalten Ihrer Bibliothek funktioniert vollständig offline. Die einzige Funktion, die auf das Internet zugreift, ist „fetch metadata“, das Buchcover und Beschreibungen aus Online-Quellen holt. Das tut offline nichts, hat aber keinen Einfluss auf das Lesen oder Ordnen der Bücher, die Sie bereits haben.

## IT Tools {% #it-tools %}

Eine Sammlung von über 100 kleinen Hilfsprogrammen, die Sie sonst im Netz zusammensuchen müssten: Hash-Generatoren, Base64- und URL-Encoder, JSON- und SQL-Formatierer, UUID-Generatoren, ein QR-Code-Generator, Farbkonverter und vieles mehr. Alles läuft lokal auf Ihrem NOMAD, sodass Sie es ohne Internetverbindung nutzen können.

**Offizielle Website:** [it-tools.tech](https://it-tools.tech) · **Quellcode:** [github.com/CorentinTh/it-tools](https://github.com/CorentinTh/it-tools)

**Beim ersten Öffnen:** Die App öffnet direkt die Werkzeuge. Keine Anmeldung, kein Konto, keine Einrichtung. Wählen Sie in der Seitenleiste ein Werkzeug aus und nutzen Sie es.

**Ihre Daten:** Es gibt nichts zu verwalten. IT Tools speichert zwischen den Sitzungen nichts auf Ihrem NOMAD, es gibt also keine Dateien, keine einzurichtende Bibliothek und keine Zugangsdaten, die Sie im Blick behalten müssten. Es ist die einfachste App im Supply Depot.

**Funktioniert offline:** Jedes Werkzeug läuft direkt in Ihrem Browser auf der Kopie, die auf Ihrem NOMAD liegt. Nichts hier greift auf das Internet zu, daher funktioniert alles auch offline weiter.

## Excalidraw {% #excalidraw %}

Ein virtuelles Whiteboard für schnelle Diagramme und Skizzen im handgezeichneten Stil. Zeichnen Sie Kästen, Pfeile und Freihandformen, fügen Sie Text und Bilder ein und legen Sie in Sekunden ein Flussdiagramm, ein Netzwerkdiagramm oder eine grobe Idee an. Das Ganze hat einen freundlichen, auf einer Serviette skizzierten Look und läuft direkt in Ihrem Browser.

**Offizielle Website:** [excalidraw.com](https://excalidraw.com) · **Quellcode:** [github.com/excalidraw/excalidraw](https://github.com/excalidraw/excalidraw)

**Beim ersten Öffnen:** Die App öffnet direkt eine leere Zeichenfläche. Keine Anmeldung, kein Konto, keine Einrichtung. Wählen Sie in der Werkzeugleiste eine Form und legen Sie los. Sie sehen einen kurzen Willkommenshinweis, dass Ihre Arbeit in Ihrem Browser gespeichert wird, und das führt zu dem einen Punkt, den man zu Excalidraw auf NOMAD verstehen sollte.

**Wo Ihre Zeichnungen liegen (bitte lesen):** Diese Version von Excalidraw hat keinen Speicher auf Ihrem NOMAD. Ihre Zeichnung wird im Webbrowser gespeichert, den Sie verwenden, auf diesem einen Gerät. Daraus folgt einiges:

- Ihre Zeichnung wird **nicht zwischen Geräten geteilt**. Was Sie auf Ihrem Laptop zeichnen, erscheint nicht, wenn Sie Excalidraw auf Ihrem Telefon öffnen, denn jeder Browser hat seine eigene Kopie.
- Wenn Sie **Ihre Browserdaten löschen** oder ein privates Fenster/Inkognito-Fenster verwenden, ist die Zeichnung weg. Auf dem NOMAD gibt es keine Kopie, auf die Sie zurückgreifen könnten.
- **Speichern Sie Ihre Arbeit deshalb in einer Datei.** Verwenden Sie das Menü (oben links), um mit **Save to...** eine `.excalidraw`-Datei zu speichern, und legen Sie sie an einem sicheren Ort ab, zum Beispiel in Ihrem Medien- oder Dokumentenordner über File Browser. Um später weiterzumachen, nutzen Sie **Open** und laden diese Datei. Nur so behalten Sie eine Zeichnung langfristig oder übertragen sie auf ein anderes Gerät.

**Ihre Daten:** Weil alles in Ihrem Browser bleibt, gibt es für Excalidraw keine NOMAD-Ordner und keine Zugangsdaten zu verwalten. Die Dateien, die Sie speichern, liegen dort, wo Sie sie ablegen.

**Funktioniert offline:** Das Whiteboard selbst funktioniert offline: Sie können zeichnen, bearbeiten und Dateien speichern, ganz ohne Internet. Drei Dinge sollten Sie wissen:

- **Die typische handgezeichnete Schrift kommt aus dem Internet.** Ist Ihr NOMAD offline, kann Excalidraw sie nicht laden und weicht auf eine schlichte Schrift aus, sodass Ihre Diagramme etwas weniger skizzenhaft aussehen. Ihre Zeichnungen selbst sind davon völlig unberührt, nur die Schrift auf dem Bildschirm ändert sich.
- **Excalidraw sendet anonyme Nutzungsstatistiken, wenn Ihr NOMAD online ist.** Die Macher der App haben eine einfache Seitenaufruf-Erfassung eingebaut (über einen Dienst namens Simple Analytics), die festhält, dass die App geöffnet wurde. Ihre Zeichnungen sieht sie nicht, und offline erreicht sie nichts, aber wir möchten, dass Sie davon wissen, da NOMAD ansonsten darauf ausgelegt ist, für sich zu bleiben.
- **Einige Schaltflächen sind Cloud-Funktionen, die auf NOMAD nicht funktionieren.** „Live collaboration“, „Sign up“ und „Excalidraw+“ führen alle zum kostenpflichtigen Online-Dienst der Macher und benötigen das Internet. Sie gehören nicht zu Ihrem Offline-Whiteboard, Sie können sie also ignorieren. Dasselbe gilt für den Formen-Browser **Library**, der aus einer Online-Galerie schöpft.

## Homebox {% #homebox %}

Ein Inventarsystem für zu Hause, um den Überblick über alles zu behalten, was Sie besitzen. Erfassen Sie Ihren Besitz nach Orten und Labels, hängen Sie Fotos an, notieren Sie Seriennummern, Kaufpreise, Garantiedaten und Belege und finden Sie alles per Suche. Ein wirklich nützliches Werkzeug für Versicherungsunterlagen, Garantieverfolgung und die Frage, was Sie haben und wo es ist.

**Offizielle Website:** [homebox.software](https://homebox.software) · **Quellcode:** [github.com/sysadminsmedia/homebox](https://github.com/sysadminsmedia/homebox)

**Beim ersten Öffnen:** Homebox zeigt einen Anmeldebildschirm, aber Sie haben noch kein Konto, also legen Sie eines an. Klicken Sie auf **Register** und füllen Sie aus:

- **Ihre E-Mail-Adresse** (dient als Benutzername für die Anmeldung),
- **Ihren Namen**,
- **ein Passwort** (Homebox zeigt eine Stärkeanzeige und lässt die Registrierung erst zu, wenn das Passwort stark genug ist, verwenden Sie also ein richtiges).

Klicken Sie auf **Register** und melden Sie sich dann mit dieser E-Mail-Adresse und dem Passwort an. Das erste Konto, das Sie anlegen, ist der **Eigentümer** dieser Homebox. Es gibt keine Standard-Zugangsdaten, die Sie ändern müssten, das Konto gehört von Anfang an Ihnen.

**Sie teilen Ihren NOMAD mit anderen?** Standardmäßig erlaubt Homebox jedem, der die App erreichen kann, ein eigenes Konto anzulegen. Das ist in Ordnung, wenn nur Sie sie nutzen oder Sie allen in Ihrem Netzwerk vertrauen. Wenn Sie es lieber absperren möchten, damit sich nach Ihrer eigenen Registrierung niemand sonst mehr registrieren kann:

1. Legen Sie zuerst Ihr Eigentümerkonto an (siehe oben).
2. Suchen Sie auf der Seite Supply Depot Homebox und klicken Sie auf **Verwalten > Bearbeiten**.
3. Fügen Sie unter **Umgebungsvariablen** `HBOX_OPTIONS_ALLOW_REGISTRATION=false` hinzu.
4. Speichern Sie. NOMAD baut die App neu auf, und die Schaltfläche Register legt keine neuen Konten mehr an. Sie können sich weiterhin normal anmelden.

**Ihre Daten:** Alles, was Homebox speichert, liegt in einem Ordner auf Ihrem NOMAD, `storage/homebox`, als einzelne Datenbankdatei (plus alle Fotos und Belege, die Sie anhängen). Die Sicherung dieses einen Ordners sichert Ihr gesamtes Inventar.

**Funktioniert offline:** Vollständig offline. Homebox läuft komplett auf Ihrem NOMAD, hält alle Ihre Daten lokal und erfasst keine Nutzung, funktioniert also gleich, ob Ihr NOMAD verbunden ist oder nicht. Die Links in der Kopfzeile (GitHub, Discord, die Projektwebsite) brauchen das Internet, sind aber nur Verknüpfungen zu den Seiten des Projekts und haben mit Ihrem Inventar nichts zu tun.

## Vaultwarden {% #vaultwarden %}

Ein privater Passwortmanager, der auf Ihrem eigenen NOMAD läuft. Er ist mit Bitwarden kompatibel, sodass Sie Zugangsdaten, sichere Notizen und Kartendaten in einem verschlüsselten Tresor speichern und über die offiziellen Bitwarden-Browsererweiterungen und Smartphone-Apps darauf zugreifen können, alle auf Ihren NOMAD statt auf die Cloud eines anderen ausgerichtet.

**Offizielle Website:** [bitwarden.com](https://bitwarden.com) (für die Apps und Erweiterungen) · **Quellcode:** [github.com/dani-garcia/vaultwarden](https://github.com/dani-garcia/vaultwarden)

**Beim ersten Öffnen sehen Sie eine Sicherheitswarnung. Das ist erwartet, und hier ist der Grund:** Ein Passwortmanager läuft nur über eine sichere Verbindung (HTTPS), daher richtet NOMAD Vaultwarden automatisch mit HTTPS ein. Da Ihr NOMAD Ihr eigenes privates Gerät und keine öffentliche Website ist, verwendet er ein selbstsigniertes Sicherheitszertifikat, und Browser zeigen beim ersten Mal eine Warnung an. Sie wirkt alarmierend, ist aber für ein Gerät im eigenen Netzwerk normal. So kommen Sie einmalig darüber hinweg:

1. Klicken Sie auf der Vaultwarden-Karte auf **Öffnen**. Ihr Browser zeigt etwas wie *„Ihre Verbindung ist nicht privat“* oder *„Nicht sicher“*.
2. Klicken Sie auf **Erweitert** und dann auf **Weiter zu (Adresse Ihres NOMAD)**. (In manchen Browsern heißt die Schaltfläche „Fortfahren“ oder „Risiko akzeptieren“.)
3. Sie landen im Vaultwarden-Tresor. Ihr Browser merkt sich Ihre Entscheidung, sodass die Warnung auf diesem Gerät nicht noch einmal erscheint.

**Ihren Tresor anlegen:** Klicken Sie auf der Anmeldeseite auf **Create account** und legen Sie dann Ihre **E-Mail-Adresse** und ein **Master-Passwort** fest.

> **Ihr Master-Passwort kann nicht wiederhergestellt werden.** Vaultwarden hat von Haus aus keine E-Mail „Passwort vergessen“ und kein Zurücksetzen, weil es Ihr Passwort nie zu sehen bekommt. Wenn Sie es vergessen, ist der Tresor samt Inhalt für immer gesperrt. Wählen Sie etwas Starkes, das Sie nicht verlieren, und erwägen Sie, es an einem physisch sicheren Ort aufzuschreiben.

**Sie teilen Ihren NOMAD mit anderen?** Standardmäßig kann jeder, der Vaultwarden erreicht, ein eigenes Konto anlegen (jedes Konto ist getrennt und verschlüsselt). Wenn Sie lieber möchten, dass sich nach der Einrichtung Ihres Kontos niemand sonst mehr registrieren kann:

1. Legen Sie zuerst Ihr eigenes Konto an.
2. Suchen Sie auf der Seite Supply Depot Vaultwarden und klicken Sie auf **Verwalten > Bearbeiten**.
3. Fügen Sie unter **Umgebungsvariablen** `SIGNUPS_ALLOWED=false` hinzu.
4. Speichern Sie. NOMAD baut die App neu auf, und neue Registrierungen sind ausgeschaltet; bestehende Konten funktionieren weiter.

**Von Smartphone und Browser aus nutzen:** Installieren Sie die offizielle Bitwarden-App oder -Browsererweiterung und wählen Sie auf deren Anmeldebildschirm **self-hosted** (oder „Server URL“) und geben Sie `https://(your NOMAD's address):8480` ein. Beachten Sie, dass einige Smartphone-Apps bei selbstsignierten Zertifikaten strenger sind und die Verbindung verweigern können; der Web-Tresor, den Sie von NOMAD aus öffnen, funktioniert immer.

**Ihre Daten:** Ihr verschlüsselter Tresor liegt im Ordner `storage/vaultwarden` auf Ihrem NOMAD. Die Sicherung dieses Ordners sichert alles. (Das eingebaute Admin-Panel ist ausgeschaltet, solange Sie kein Admin-Token setzen, was die meisten nicht brauchen.)

**Funktioniert offline:** Vollständig offline und privat. Vaultwarden läuft komplett auf Ihrem NOMAD, speichert Ihren Tresor lokal und meldet sich bei niemandem. Die Bitwarden-Apps und -Erweiterungen halten außerdem eine lokale Kopie Ihres Tresors vor, sodass sie Ihre Passwörter auch dann lesen können, wenn Ihr NOMAD oder Ihr Telefon offline ist.

## Jellyfin {% #jellyfin %}

Ihr eigener Medienserver. Richten Sie Jellyfin auf einen Ordner mit Filmen, Serien, Musik und Fotos auf Ihrem NOMAD, und es ordnet alles mit Titelbildern und Details und streamt es an einen Webbrowser, ein Telefon, ein Tablet, einen Smart-TV oder die Jellyfin-Apps. Es ist eine private Offline-Alternative zu den großen Streamingdiensten für Medien, die Sie bereits besitzen.

**Offizielle Website:** [jellyfin.org](https://jellyfin.org) · **Quellcode:** [github.com/jellyfin/jellyfin](https://github.com/jellyfin/jellyfin)

**Beim ersten Öffnen durchlaufen Sie einen Einrichtungsassistenten.** Es sind ein paar kurze Bildschirme:

1. **Sprache** - Wählen Sie Ihre Anzeigesprache und klicken Sie auf Weiter.
2. **Administratorkonto anlegen** - Geben Sie einen Benutzernamen und ein Passwort ein. Dies ist das Hauptkonto, das den Server steuert, vergeben Sie also ein richtiges Passwort und merken Sie es sich. (Weitere Benutzer, auch eingeschränkte für Kinder, können Sie später im Dashboard hinzufügen.)
3. **Medien hinzufügen** - Klicken Sie auf **Add Media Library** und wählen Sie einen Inhaltstyp. Damit es einfach geht, hat NOMAD für jeden Typ bereits einen passenden Ordner in Ihrem Medienordner angelegt, sodass Sie jede Bibliothek nur auf den passenden Ordner richten müssen:
   - **Movies**-Bibliothek → der Ordner `Movies`
   - **Shows**-Bibliothek → der Ordner `TV Shows`
   - **Music**-Bibliothek → der Ordner `Music`
   - **Photos**-Bibliothek → der Ordner `Photos`

   **Richten Sie jede Bibliothek auf ihren eigenen Ordner, nicht auf den gesamten Ordner `media`.** Das ist wichtig: Wenn Sie eine Bibliothek auf `media` selbst richten (der alle anderen enthält) und eine andere zum Beispiel auf `Music` darin, sieht Jellyfin dieselben Dateien doppelt beansprucht, meldet einen „duplicate path“, und Ihre Musik erscheint stillschweigend nicht. Ein Ordner pro Bibliothek hält alles aufgeräumt und funktionsfähig. Sie können diesen Schritt auch überspringen und Bibliotheken später im Dashboard hinzufügen.
4. **Metadaten, Fernzugriff, Abschluss** - Übernehmen Sie auf den restlichen Bildschirmen die Voreinstellungen und schließen Sie ab. Melden Sie sich dann mit dem soeben angelegten Konto an.

**Medien einspielen:** Legen Sie Ihre Dateien in den passenden Unterordner des Ordners **media** auf Ihrem NOMAD (demselben Ordner `media`, den Sie im File Browser sehen): Filme in **Movies**, Serien in **TV Shows**, Musik in **Music** (ein Ordner pro Album funktioniert hervorragend), Bilder in **Photos**. Am einfachsten laden Sie die Dateien mit File Browser hoch (oder legen sie ab, wie Sie möchten) und klicken dann in Jellyfin auf **Scan Library**, um sie einzulesen. Jellyfin liest Unterordner, sodass ein ganzer Albumordner, den Sie in **Music** ablegen, als ein Album erscheint. Es funktioniert außerdem am besten, wenn Dateien eindeutig benannt sind (zum Beispiel `Movie Name (2020).mp4`), was dabei hilft, die richtigen Titelbilder und Details zuzuordnen.

**Ihre Daten:** Ihre Medien liegen in `storage/media`. Die eigenen Einstellungen von Jellyfin, die Benutzerkonten und die heruntergeladenen Titelbilder liegen in `storage/jellyfin`. Ihre Mediendateien werden nie verändert, Jellyfin liest sie nur.

**Funktioniert offline:** Das Streamen Ihrer eigenen Medien funktioniert vollständig offline, genau darum geht es. Der einzige Teil, der das Internet nutzt, ist das **Abrufen von Metadaten**: Wenn Jellyfin einen Film oder eine Serie hinzufügt, versucht es, Titelbild, Beschreibung und Besetzung aus Online-Datenbanken herunterzuladen. Offline geht das nicht, sodass Einträge mit schlichten Namen und ohne Titelbild erscheinen, aber trotzdem einwandfrei abspielbar sind. Sobald Sie wieder online sind, ergänzt ein Bibliotheks-Scan die fehlenden Titelbilder.

> **Ein Hinweis zur Wiedergabeleistung:** Jellyfin spielt die meisten Dateien mühelos ab, aber wenn das Format eines Videos von Ihrem Gerät nicht unterstützt wird, muss Jellyfin es im laufenden Betrieb umwandeln („Transcoding“), was für den Prozessor viel Arbeit bedeutet. NOMAD richtet dafür standardmäßig keine Grafikkartenbeschleunigung ein, sodass sehr große oder hochaufgelöste Videos auf einem bescheidenen NOMAD ruckeln können. Dateien in einem weit verbreiteten Format (wie MP4/H.264) vermeiden das Transcoding und laufen am flüssigsten.

## Meshtastic Web {% #meshtastic-web %}

Ein browserbasiertes Bedienfeld für [Meshtastic](https://meshtastic.org)-Geräte. Meshtastic ist netzunabhängiges Funk-Messaging mit großer Reichweite: kleine, günstige LoRa-Funkgeräte, die ein eigenes Mesh-Netzwerk bilden und Textnachrichten und GPS-Positionen über viele Kilometer ohne Mobilfunk, ohne Internet und ohne Gebühren versenden. Mit dieser App konfigurieren Sie diese Funkgeräte und lesen und senden Nachrichten auf einem großen Bildschirm.

**Offizielle Website:** [meshtastic.org](https://meshtastic.org) · **Quellcode:** [github.com/meshtastic/web](https://github.com/meshtastic/web)

**Sie benötigen ein Meshtastic-Funkgerät, um dies zu nutzen.** Diese App ist nur das Bedienfeld. Für sich allein öffnet sie einen Bildschirm „No devices connected“, weil die eigentliche Arbeit auf einem physischen Meshtastic-Gerät stattfindet (und im Netz der anderen Funkgeräte, mit denen es spricht). Wenn Sie noch keines haben, bringt Ihnen die App nicht viel.

**Beim ersten Öffnen:** Die App öffnet sich direkt, ohne Anmeldung. Klicken Sie auf **New Connection**, und Sie sehen drei Möglichkeiten, sich mit Ihrem Funkgerät zu verbinden:

- **HTTP** - Verbindung zu einem Funkgerät, das bereits in Ihrem WLAN angemeldet ist, durch Eingabe seiner IP-Adresse. **Diese Methode sollten Sie auf NOMAD verwenden** (siehe unten).
- **Bluetooth** - Kopplung mit einem Funkgerät in der Nähe per Bluetooth.
- **Serial** - Verbindung zu einem Funkgerät, das an einen USB-Anschluss angeschlossen ist.

**Der NOMAD-spezifische Haken (Bluetooth und Serial brauchen HTTPS):** Browser erlauben einer Website die Nutzung von Bluetooth oder USB nur, wenn die Seite über eine sichere Verbindung (HTTPS) geladen wurde. NOMAD liefert Meshtastic Web über schlichtes HTTP aus, daher **verbinden die Optionen Bluetooth und Serial auf NOMAD nicht**, Ihr Browser blockiert sie. Die Option, die funktioniert, ist **HTTP**: Bringen Sie Ihr Meshtastic-Funkgerät in dasselbe WLAN (Meshtastic-Funkgeräte können sich in ein WLAN einbuchen) und verbinden Sie sich dann hier über seine IP-Adresse. Wenn Sie unbedingt per USB oder Bluetooth koppeln müssen, tun Sie das stattdessen in der offiziellen Meshtastic-Smartphone-App oder auf der Meshtastic-Website.

**Ihre Daten:** Für diese App gibt es auf Ihrem NOMAD nichts einzurichten oder zu speichern. Die Einstellungen Ihres Funkgeräts liegen auf dem Funkgerät selbst, und die Voreinstellungen dieser App liegen in Ihrem Browser. Es gibt keinen NOMAD-Ordner zu verwalten.

**Funktioniert offline:** Vollständig offline, das ist der ganze Sinn von Meshtastic. Die App wird von Ihrem NOMAD ausgeliefert, und die Kommunikation mit Ihren Funkgeräten läuft über Ihr lokales Netzwerk oder per Funk, niemals über das Internet. Die einzigen Online-Teile sind die Links in der Fußzeile (Vercel, Rechtliches), die für die Nutzung Ihres Mesh keine Rolle spielen.

## Bildungsplattform (Kolibri) {% #kolibri %}

Eine vollständige Offline-Lernplattform von Learning Equality. Kolibri bündelt Videolektionen, Übungen und Lesematerial in strukturierten Kanälen, ordnet sie in Klassen und Lektionen, verfolgt den Lernfortschritt und arbeitet komplett auf Ihrem NOMAD ohne Internet. Es ist für Schulen und Lernende an Orten mit wenig oder gar keiner Verbindung gemacht.

**Offizielle Website:** [learningequality.org/kolibri](https://learningequality.org/kolibri) · **Quellcode:** [github.com/learningequality/kolibri](https://github.com/learningequality/kolibri)

**Beim ersten Öffnen durchlaufen Sie einen kurzen Einrichtungsassistenten.** Wählen Sie Ihren Einrichtungstyp (Facility) und legen Sie das **Administratorkonto** an (dies ist der Superuser, der das gesamte Gerät verwaltet, vergeben Sie also ein richtiges Passwort und merken Sie es sich). Sobald Sie drin sind, importieren Sie Lerninhalte als **Kanäle**.

**Inhalte importieren:** Die Inhalte von Kolibri werden als Kanäle geliefert, die Sie importieren. Öffnen Sie **Device → Channels → Import** und holen Sie die Kanäle entweder aus Kolibri Studio (online) oder importieren Sie sie von einem lokalen Laufwerk oder einem anderen Kolibri-Gerät, wenn Sie die Inhaltsdateien bereits haben. Es gibt sehr viel, importieren Sie also nur die Kanäle, die Sie brauchen; sie können groß sein.

**Inhalte aus der Bildungsplattform (Gen 1) übernehmen:** Frühere NOMAD-Versionen lieferten ein viel älteres Kolibri aus (das Image `treehouses/kolibri:0.12.8`). Die Bildungsplattform „Gen 2“ ist ein neueres, offizielles Upstream-Kolibri und wird **neu** installiert — Ihre alten Kanäle und Lernerdaten werden **nicht** automatisch übernommen, weil die beiden Versionen Daten zu unterschiedlich speichern, um sie sicher zu migrieren. Wenn Sie die alte Version betrieben haben und Ihre bestehenden Kanäle in die neue importieren möchten, gehen Sie so vor:

1. Installieren Sie „Bildungsplattform (Gen 2)“ aus dem Katalog (sie läuft neben der alten auf einem anderen Port, sodass während der Einrichtung nichts gestört wird).
2. Starten Sie die neue, durchlaufen Sie den Einrichtungsassistenten und navigieren Sie dann im Seitenmenü zu **Device > Channels > Import**. Wählen Sie die Option „Local network or internet“ und dann „Add new device“. Geben Sie im erscheinenden Dialog die IP-Adresse Ihres NOMAD mit dem Port der alten Bildungsplattform ein (standardmäßig 8300, zum Beispiel `http://192.168.1.36:8300`), vergeben Sie einen beliebigen Namen und klicken Sie auf „Add“ und dann auf „Continue“. 
3. Sie können nun einzelne Kanäle der alten Bildungsplattform auswählen oder mit „Select entire channels instead“ alles auf einmal importieren. Klicken Sie auf „Import“, wenn Sie bereit sind, und die Übertragung beginnt.
3. Wenn Sie mit der neuen Installation zufrieden sind und alle Inhalte kopiert haben, deinstallieren Sie die alte Bildungsplattform über ihre Karte (sie trägt ein Label **legacy**). Es wird außerdem empfohlen, beim Deinstallieren das Entfernen des alten Images und Daten-Volumes zu wählen, um Verwechslungen zu vermeiden und Platz freizugeben; wenn Sie sie sicherheitshalber noch eine Weile behalten möchten, ist das aber ebenfalls völlig in Ordnung.

**Ihre Daten:** Ihre importierten Kanäle, Klassen und der Lernfortschritt liegen im Ordner `storage/kolibri-gen2` auf Ihrem NOMAD. Die Sicherung dieses Ordners sichert Ihr gesamtes Kolibri.

**Funktioniert offline:** Nach dem Import der Inhalte vollständig offline, dafür ist Kolibri da. Der einzige Schritt, der das Internet nutzt, ist der Import von Kanälen aus Kolibri Studio; alles danach, also Lektionen durchsehen, Übungen machen und den Fortschritt verfolgen, läuft komplett auf Ihrem NOMAD.
## MeshCore Web {% #meshcore-web %}

Ein browserbasierter Client für [MeshCore](https://meshcore.io)-Funkgeräte. MeshCore ist eine weitere Variante des netzunabhängigen LoRa-Mesh-Messagings mit großer Reichweite, ein Geschwister von Meshtastic: kleine Funkgeräte, die ein eigenes Netzwerk bilden und Text und Position über viele Kilometer ohne Mobilfunk, ohne Internet und ohne Gebühren weitergeben. Mit dieser App konfigurieren Sie ein MeshCore-Funkgerät und lesen und senden Nachrichten auf einem großen Bildschirm. Wenn Sie noch keine MeshCore-Geräte betreiben, ist der Meshtastic-Client weiter oben der üblichere Einstieg. Dieser hier ist für Leute da, die MeshCore nutzen.

**Offizielle Website:** [meshcore.io](https://meshcore.io) · **Quellcode:** [github.com/aXistem-dev/meshcore-web](https://github.com/aXistem-dev/meshcore-web) (ein paketierter Build des MeshCore-Clients von Liam Cottle)

**Sie benötigen ein MeshCore-Funkgerät, um dies zu nutzen.** Wie der Meshtastic-Client ist dies nur das Bedienfeld. Ohne angeschlossenes Funkgerät hat es nichts, womit es sprechen könnte.

**Beim ersten Öffnen sehen Sie eine Sicherheitswarnung. Das ist erwartet, und hier ist der Grund:** MeshCore verbindet sich per USB oder Bluetooth mit Ihrem Funkgerät, und Browser erlauben einer Webseite die Nutzung von USB oder Bluetooth nur, wenn die Seite über eine sichere Verbindung (HTTPS) geladen wurde. Deshalb liefert NOMAD diese App über HTTPS aus, und weil Ihr NOMAD ein privates Gerät ohne öffentliche Webadresse ist, verwendet er ein selbstsigniertes Zertifikat, vor dem Browser beim ersten Mal warnen. So kommen Sie einmalig darüber hinweg:

1. Klicken Sie auf der MeshCore-Web-Karte auf **Öffnen**. Ihr Browser zeigt etwas wie *„Ihre Verbindung ist nicht privat“* oder *„Nicht sicher“*.
2. Klicken Sie auf **Erweitert** und dann auf **Weiter zu (Adresse Ihres NOMAD)**. (In manchen Browsern heißt die Schaltfläche „Fortfahren“ oder „Risiko akzeptieren“.)
3. Sie landen in MeshCore Web. Ihr Browser merkt sich Ihre Entscheidung, sodass die Warnung auf diesem Gerät nicht noch einmal erscheint.

**Ihr Funkgerät verbinden:** Verwenden Sie **Chrome oder Edge**, die USB und Bluetooth im Browser am besten unterstützen. Schließen Sie das Funkgerät an den Computer an, an dem Sie surfen (USB), oder halten Sie es in der Nähe (Bluetooth), und verbinden Sie sich dann in der App damit. Das Funkgerät verbindet sich mit **dem Computer, den Sie benutzen**, nicht mit dem NOMAD selbst, verbinden Sie sich also von einem Gerät aus, an dem das Funkgerät angeschlossen oder in Bluetooth-Reichweite ist. Manche Smartphones sind bei selbstsignierten Zertifikaten strenger und verweigern unter Umständen die Verbindung; ein Desktop-Chrome oder -Edge ist am zuverlässigsten.

**Ihre Daten:** Für diese App gibt es auf Ihrem NOMAD nichts einzurichten oder zu speichern. Die Einstellungen Ihres Funkgeräts liegen auf dem Funkgerät selbst, und die Voreinstellungen der App liegen in Ihrem Browser. Es gibt keinen NOMAD-Ordner zu verwalten.

**Funktioniert offline:** Vollständig offline, das ist der ganze Sinn von MeshCore. Die App wird von Ihrem NOMAD ausgeliefert und spricht direkt per USB oder Bluetooth mit Ihrem Funkgerät, niemals über das Internet.

## Übersetzte Bibliothek {% #offline-translation %}

Liest die Wissensbibliothek in einer anderen Sprache. Öffnen Sie einen Artikel, und oben erscheint eine Leiste **Translate this page** mit einer Schaltfläche für jede installierte Sprache sowie **Original**, um zurückzuwechseln. Ihre Auswahl bleibt erhalten, wenn Sie zu anderen Artikeln weiterklicken.

**Warum das statt des KI-Assistenten:** Der KI-Assistent kann übersetzen, aber dies ist auf derselben Maschine etwa 1.600-mal schneller und braucht keine Grafikkarte, funktioniert also auf jedem NOMAD. Außerdem geht es sorgfältiger mit Namen um: Bei der Übersetzung einer Seite übersetzt der KI-Assistent bereitwillig „Project NOMAD“ in eine andere Sprache, dies hier nicht.

**Sprachen auswählen:** Französisch, Spanisch und Deutsch sind standardmäßig eingerichtet. Um das zu ändern, verwenden Sie **Verwalten > Bearbeiten** und setzen `TRANSLATE_LANGS` auf eine durch Kommas getrennte Liste von Sprachcodes, zum Beispiel `fr,it,pt`. Jede Sprache umfasst etwa 74 MB, und neue werden beim nächsten Neustart der App heruntergeladen. Etwa 40 Sprachen sind verfügbar, darunter Hindi, Bengalisch, Tamil, Telugu, Vietnamesisch und Indonesisch. **Chinesisch, Japanisch, Koreanisch, Arabisch und Thai sind nicht verfügbar**, weil es dafür noch kein kompaktes Modell gibt.

**Der erste Start braucht Internet.** Die Sprachmodelle werden beim ersten Start der App heruntergeladen, genau wie bei der Installation jeder anderen App. Danach läuft alles vollständig offline. Wenn Sie die App ohne Verbindung installieren, startet sie trotzdem und die Bibliothek funktioniert weiter, nur eben ohne Übersetzung, bis sie die Modelle holen kann.

**Was nicht übersetzt wird:** Tabellen und Infoboxen, der Seitentitel im Browser-Tab und die eigenen Suchergebnisse von Kiwix. Auch die Suche gleicht weiterhin mit der Originalsprache ab, suchen Sie also auf Englisch und übersetzen Sie den Artikel, auf dem Sie landen.

**Ein Hinweis zu zwei Sprachschaltflächen:** Die Symbolleiste der Bibliothek hat einen Globus, der die *Menüs* um die Seite herum ändert. Die Leiste, die diese App hinzufügt, ändert den *Artikel*. Das sind verschiedene Dinge, und sie liegen nah beieinander, was bedauerlich ist, sich aber nicht verschieben lässt.

**Genauigkeit:** Dies ist maschinelle Übersetzung, und sie ist wörtlich. Sie eignet sich sehr gut, um den Sinn eines Artikels zu erfassen. Verlassen Sie sich nicht blind darauf, wenn es um exakte medizinische oder sicherheitsrelevante Formulierungen geht, bei denen der richtige Begriff in einer anderen Sprache oft nicht der wörtliche ist.

**Ihre Daten:** Die Sprachmodelle liegen in `storage/translate/models`. Nichts, was Sie lesen, wird gespeichert oder irgendwohin gesendet.

**Funktioniert offline:** Ja, sobald die Modelle heruntergeladen sind.
