# Szenen der vier Videos. Jede Szene: id, text (Sprecher, ohne Abkürzungen schreiben), und entweder bild (Name, siehe bauen.py)
# oder karte=dict(titel=..., punkte=[...]) für eine Textkarte. 'titel' ist die Einblendung unten (optional).
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'praesentation'))
from folien import SLIDES


def aus_folie(nr, id_, titel=None, karte=None):
    s = SLIDES[nr - 1]
    d = dict(id=id_, text=s['notiz'], titel=titel or s['titel'])
    if karte:
        d['karte'] = karte
    elif s.get('bild'):
        d['bild'] = s['bild']
    else:
        d['karte'] = dict(titel=s['titel'], punkte=[p.replace('**', '') for p in s.get('punkte', [])] or
                          ['%s: %s' % (k, ' · '.join(p)) for k, p in s.get('karten', [])])
    return d


V1 = dict(name='v1-konzept', titel='NOMAD – Was ist das? (Konzept)', szenen=[
    aus_folie(1, 'a01', 'NOMAD – Wissen, das ohne Internet funktioniert'),
    aus_folie(2, 'a02'), aus_folie(3, 'a03'), aus_folie(4, 'a04'), aus_folie(5, 'a05'), aus_folie(6, 'a06'),
    aus_folie(7, 'a07'), aus_folie(8, 'a08'), aus_folie(9, 'a09'), aus_folie(10, 'a10'),
    dict(id='a11', titel='Ab wann geht es ohne Internet?', karte=dict(titel='Ab wann geht es ohne Internet?', punkte=[
        'Gestartet: Anleitungen lesen', 'Inhalte geladen: Wikipedia und Nachschlagewerke', 'Karten geladen: Karte der geladenen Länder',
        'KI eingerichtet: Fragen an den Assistenten']), text=SLIDES[14]['notiz']),
    aus_folie(23, 'a12'), aus_folie(25, 'a13'),
])

V2 = dict(name='v2-installation', titel='NOMAD installieren – Schritt für Schritt', szenen=[
    dict(id='b01', bild='usb', titel='Zwei Wege zu NOMAD',
         text='In diesem Video richten wir NOMAD ein. Es gibt zwei Wege. Der einfache Weg ist eine USB-SSD: Ihr Windows-Rechner bleibt dabei unberührt. Der zweite Weg ist ein eigener Rechner mit Ubuntu. Wir zeigen zuerst den einfachen Weg und danach kurz den zweiten.'),
    dict(id='b02', karte=dict(titel='Das brauchen Sie', punkte=['Eine USB-SSD mit mindestens 512 Gigabyte und USB 3', 'Einen Windows-Rechner mit Internet, zum Herunterladen',
         'Etwa 6 Gigabyte freien Platz', 'Das kostenlose Programm balenaEtcher']), titel='Das brauchen Sie',
         text='Sie brauchen eine USB-SSD mit mindestens 512 Gigabyte und USB drei. Ein normaler USB-Stick ist zu klein und zu langsam. Dazu einen Windows-Rechner mit Internet, etwa sechs Gigabyte freien Platz und das kostenlose Programm balenaEtcher.'),
    dict(id='b03', karte=dict(titel='Das System herunterladen', punkte=['github.com/huppiflupp/project-nomad-de/releases', 'Datei nomad.img.xz, etwa 5 Gigabyte, nicht entpacken',
         'Prüfsumme notieren und mit certutil vergleichen']), titel='Das System herunterladen',
         text='Laden Sie auf der Release-Seite des Projekts die Datei nomad Punkt img Punkt x z herunter. Sie ist etwa fünf Gigabyte groß. Entpacken Sie sie nicht, Etcher kann sie so lesen. Notieren Sie die Prüfsumme und vergleichen Sie sie mit dem Windows-Befehl certutil, damit Sie sicher sind, dass die Datei vollständig ist.'),
    dict(id='b04', karte=dict(titel='Mit Etcher auf die USB-SSD schreiben', punkte=['1. Aus Datei flashen: nomad.img.xz wählen', '2. Ziel wählen: Ihre USB-SSD, Größe kontrollieren',
         '3. Flash!: Administrator-Abfrage bestätigen', 'Beim Schreiben wird die SSD vollständig gelöscht']), titel='Auf die USB-SSD schreiben',
         text='Starten Sie balenaEtcher. Wählen Sie die Datei, wählen Sie als Ziel Ihre USB-SSD und kontrollieren Sie die Größe. Achtung: Beim Schreiben wird die SSD vollständig gelöscht, wählen Sie nie die Platte, auf der Windows läuft. Dann auf Flash klicken und warten, bis der Vorgang erfolgreich abgeschlossen ist.'),
    dict(id='b05', karte=dict(titel='Den Rechner von der USB-SSD starten', punkte=['Rechner herunterfahren, nicht neu starten', 'SSD anschließen, einschalten, sofort mehrfach die Taste fürs Startmenü',
         'Dell, Acer, Lenovo: F12 · Asus: Esc · HP: F9 · MSI: F11', 'USB-SSD wählen, Eingabetaste']), titel='Von der USB-SSD starten',
         text='Fahren Sie den Rechner herunter, schließen Sie die SSD an und schalten Sie ein. Drücken Sie sofort mehrfach die Taste für das Startmenü, bei vielen Geräten F zwölf, bei Asus Escape, bei HP F neun. Wählen Sie dort Ihre USB-SSD aus und bestätigen Sie mit der Eingabetaste.'),
    dict(id='b06', bild='img-boot1', titel='Etwa eine Minute bis zum Desktop',
         text='Nach etwa einer Minute erscheint der Desktop. Eine Anmeldung ist nicht nötig. Beim allerersten Start richtet sich das System ein und vergrößert sich auf die ganze Platte. Das dauert ein bis zwei Minuten länger, schalten Sie in dieser Zeit nicht aus. Auch ohne Internet funktioniert das.'),
    dict(id='b07', bild='img-boot2', titel='Die Kommandozentrale öffnet sich',
         text='Sobald NOMAD bereit ist, öffnet sich der Browser mit der Kommandozentrale. Wenn Sie diese Seite sehen, ist alles eingerichtet.'),
    dict(id='b08', karte=dict(titel='Passwort ändern', punkte=['Terminal öffnen: Strg + Alt + T', 'Eingeben: passwd, Eingabetaste', 'Altes Passwort: nomad, dann zweimal das neue',
         'Neues Passwort in die Tabelle im Handbuch eintragen']), titel='Anfangspasswort ändern',
         text='Ein wichtiger Schritt: Benutzer und Passwort sind bei jeder USB-SSD gleich, nämlich nomad. Ändern Sie das Passwort, sobald das System steht. Öffnen Sie mit Strg, Alt und T ein Terminal, geben Sie passwd ein, dann das alte und zweimal das neue Passwort. Beim Tippen erscheint nichts, das ist normal.'),
    dict(id='b09', bild='02-sprache-de', titel='Weg 2: Ubuntu installieren',
         text='Der zweite Weg ist ein eigener Rechner mit Ubuntu. Sie schreiben den Ubuntu-Stick mit Etcher, starten davon und wählen als Sprache Deutsch.'),
    dict(id='b10', bild='10-festplatte', titel='Achtung: alles wird gelöscht',
         text='Wichtig ist die Festplatten-Auswahl: Festplatte löschen und Ubuntu installieren. Das löscht alles auf dieser Platte. Nutzen Sie diesen Weg nur für einen Rechner, der danach nur noch für NOMAD gedacht ist.'),
    dict(id='b11', bild='29-installer-start', titel='NOMAD mit einem Befehl installieren',
         text='Nach der Anmeldung öffnen Sie ein Terminal und geben drei Befehle ein, die im Handbuch stehen. Der Installer meldet sich auf Deutsch und fragt, ob er fortfahren soll. Antworten Sie mit j und danach auf die Lizenzfrage ebenfalls mit j.'),
    dict(id='b12', bild='32-fertig', titel='Installation abgeschlossen',
         text='Am Ende steht, dass die Installation erfolgreich abgeschlossen wurde, und die Adresse der Oberfläche: http doppelpunkt Schrägstrich Schrägstrich localhost doppelpunkt 8080. Öffnen Sie diese Adresse im Browser, und die Kommandozentrale erscheint.'),
    dict(id='b13', bild='34-nomad-start', titel='Weiter mit dem Schnellstart',
         text='Jetzt ist NOMAD eingerichtet, aber noch leer. Im nächsten Video laden wir die Inhalte herunter und testen, ob alles ohne Internet funktioniert. Dafür klicken Sie auf Schnellstart.'),
])

V3 = dict(name='v3-betrieb', titel='NOMAD im Betrieb – Inhalte, Offline-Test, Notfall', szenen=[
    dict(id='c01', bild='35-schnellstart-1', titel='Inhalte laden – dafür brauchen Sie Internet',
         text='Jetzt machen wir aus dem leeren NOMAD einen Wissensserver. Dafür brauchen Sie Internet, und Sie sollten Zeit einplanen. Der Rechner muss am Netzteil hängen und darf währenddessen nicht ausgeschaltet werden. Der Schnellstart hat vier Schritte: Apps, Karten, Inhalte und Überprüfen.'),
    dict(id='c02', bild='39-medizin-stufen', titel='Drei Stufen je Themenbereich',
         text='Jeder Themenbereich hat drei Stufen: Essential, Standard und Comprehensive. Alle Bereiche zusammen sind in der kleinsten Stufe etwa sechs Gigabyte, in der mittleren etwa sechsunddreißig und in der größten etwa neunundachtzig Gigabyte. Beginnen Sie mit Essential. Größeres können Sie jederzeit nachladen.'),
    dict(id='c03', bild='38-inhalte', titel='Wikipedia in mehreren Größen',
         text='Wikipedia gibt es in mehreren Größen, von dreihundert Megabyte bis über hundertzwanzig Gigabyte. Alle sind englischsprachig. Für den Anfang genügt die Schnellreferenz mit den hunderttausend wichtigsten Artikeln.'),
    dict(id='c04', bild='41-ueberpruefen', titel='Überprüfen und starten',
         text='Zum Schluss sehen Sie eine Zusammenfassung mit der Gesamtgröße. Prüfen Sie, ob der Platz reicht, und schließen Sie die Einrichtung ab.'),
    dict(id='c05', bild='43-downloads', titel='Fortschritt beobachten',
         text='Auf der Seite Downloads sehen Sie, was geladen wird. Nach einem Neustart geht das Laden an der Stelle weiter, an der es aufgehört hat. Sind keine aktiven Downloads mehr da, machen Sie sofort den Offline-Test, solange das Internet noch erreichbar ist.'),
    dict(id='c06', bild='44-offline-test-terminal', titel='Offline-Test: Internet trennen',
         text='Für den Offline-Test ziehen Sie das Netzwerkkabel oder schalten das WLAN aus. Zum Beweis geben Sie im Terminal ping ein. Es muss hundert Prozent Paketverlust erscheinen. Starten Sie danach den Rechner ohne Netz neu. Das ist der eigentliche Test, denn im Notfall startet er genau so.'),
    dict(id='c07', bild='45-kiwix-offline', titel='Die Wissensbibliothek ohne Internet',
         text='Nach dem Neustart öffnen Sie die Kommandozentrale und die Wissensbibliothek. Alle geladenen Bücher sind da. Suchen Sie einen Begriff, öffnen Sie einen Artikel und haken Sie die Checkliste im Handbuch ab.'),
    dict(id='c08', bild='47-wikipedia-offline', titel='Ein Wikipedia-Artikel ohne Netz',
         text='Auch Wikipedia öffnet Artikel samt Seitenlinks, ganz ohne Verbindung. Die Texte sind überwiegend englisch, das ist richtig so, die geladenen Bücher sind englischsprachig.'),
    dict(id='c09', karte=dict(titel='Die Notfall-Karte', punkte=['Adresse: http://localhost:8080', 'Seite lädt nicht: zwei Minuten warten',
         'Dann: sudo bash /opt/project-nomad/start_nomad.sh', 'Ausschalten: Ein/Aus-Symbol, nie die SSD abziehen', 'Eine Seite im Handbuch, zum Heraustrennen']), titel='Die Notfall-Karte',
         text='Im Handbuch gibt es eine Notfall-Karte auf einer Seite. Darauf stehen die Adresse von NOMAD, was Sie tun, wenn die Seite nicht lädt, wie Sie sauber ausschalten und wo Ihre Notizen stehen. Drucken Sie sie aus und legen Sie sie sichtbar neben den Rechner.'),
    dict(id='c10', bild='upd4', titel='Aktualisieren, wenn Internet da ist',
         text='Aktualisieren können Sie nur mit Internet. Unter Einstellungen, System-Update, klicken Sie auf Erneut prüfen und dann auf Update starten. Das dauert etwa drei Minuten, zwischendurch erscheinen erwartete Verbindungsfehler. Danach steht dort, dass das System aktuell ist. Machen Sie dann den Offline-Test noch einmal.'),
    dict(id='c11', bild='energie', titel='Strom im Notfall',
         text='Ein Notebook braucht im Betrieb etwa zwanzig Watt. Eine Powerbank mit neunundneunzig Wattstunden reicht für gut vier Stunden, eine Powerstation mit fünfhundert Wattstunden für gut einen Tag. Sparen Sie Strom: Bildschirm dunkel, WLAN aus, nur bei Bedarf einschalten. Im Handbuch steht die Rechnung zum Selbstausfüllen.'),
    dict(id='c12', bild='handbuch', titel='Das Handbuch zum Ausdrucken',
         text='Drucken Sie das Handbuch aus und legen Sie es zur USB-SSD. Füllen Sie die Tabellen aus: Softwarestand, geladene Inhalte und Zugangsdaten. Wenn es darauf ankommt, hat man meistens alles vergessen, deshalb steht dort jeder Schritt.'),
])

V4 = dict(name='v4-erweiterungen-ki', titel='NOMAD erweitern – Karten, eigene Dokumente und die Notfall-KI', szenen=[
    dict(id='d01', bild='bibliothek', titel='Was noch möglich ist',
         text='In diesem Video geht es um Erweiterungen: Karten für ganze Länder, eigene Dokumente und die Notfall-KI, ein Sprachassistent, der auf Ihrem Rechner läuft, ohne Internet.'),
    dict(id='d02', bild='map01-karten-manager', titel='Karten: Länder auswählen',
         text='Karten laden Sie im Karten-Manager. Der empfohlene Weg ist Länder auswählen. NOMAD schneidet nur die gewählten Länder aus einer Weltkarte heraus und zeigt vorher die Größe an. Die Weltkarte als Ganzes hat dagegen über hundertzwanzig Gigabyte.'),
    dict(id='d03', bild='map02-laender-waehlen', titel='Land, Zoomstufe, Download',
         text='Kreuzen Sie das Land an, stellen Sie mit dem Regler die Zoomstufe ein und starten Sie den Download. Deutschland bis zur Stadtebene braucht etwa einhundertzwanzig Megabyte, mit einzelnen Straßen sind es über fünf Gigabyte. Die Länderliste ist englisch, die Karten selbst funktionieren ohne Internet.'),
    dict(id='d04', bild='map03-karte-deutschland', titel='Die Karte von Deutschland, offline',
         text='So sieht das Ergebnis aus: die Karte von Deutschland, vollständig offline. Die Ortsnamen sind allerdings englisch beschriftet.'),
    dict(id='d05', bild='ki03-supply-depot', titel='Den KI-Assistenten installieren',
         text='Der KI-Assistent wird im Supply Depot installiert, oder Sie haken ihn im Schnellstart an. Dafür brauchen Sie Internet, denn das Sprachmodell wird einmal heruntergeladen.'),
    dict(id='d06', bild='ki05-modelle', titel='Welches Modell?',
         text='Unter Einstellungen, KI-Assistent, laden Sie ein Modell. Wir haben sechs Modelle mit deutschen Fragen getestet. Am besten war gemma vier e vier mit etwa sieben Gigabyte, ab sechzehn Gigabyte Arbeitsspeicher. Mit nur acht Gigabyte nehmen Sie gemma drei vier b. Meiden Sie die Modelle der Reihe qwen drei und alle unter zwei Gigabyte. Sie antworten bei Erster Hilfe falsch.'),
    dict(id='d07', bild='ki07-chat-leer', titel='Der Chat',
         text='Im Chat wählen Sie oben das Modell und können die Wissensdatenbank ein- oder ausschalten. Ist sie an, sucht die KI vor jeder Antwort in Ihren Dokumenten und nennt am Ende die Quellen.'),
    dict(id='d08', bild='ki09-chat-antwort', titel='Vorsicht: Quellen sind kein Beweis',
         text='Eine wichtige Warnung: Dieses kleine Modell hat auf die Frage nach dem Plattenplatz eine erfundene Geschichte über ein Funkgerät geantwortet, und trotzdem die Quelle F A Q angegeben. Eine genannte Quelle ist kein Beweis, dass die Antwort stimmt. Prüfen Sie bei Medizin, Sicherheit und Recht jede Antwort an der Quelle.'),
    dict(id='d09', bild='ki13-wissensdatenbank-liste', titel='Eigene Inhalte durchsuchbar machen',
         text='Wollen Sie, dass die KI auch Wikipedia und die Nachschlagewerke nutzt, müssen Sie diese indizieren. Ein Klick startet das für alle geladenen Inhalte, ohne Warnung. Das kann sehr lange dauern: Ein Nachschlagewerk von hundertachtundsiebzig Megabyte brauchte auf einem alten Rechner etwa drei Stunden, mit Grafikkarte siebeneinhalb Minuten. Indizieren Sie gezielt und über Nacht.'),
    dict(id='d10', karte=dict(titel='Schneller mit Grafikkarte', punkte=['gemma4:e4b, nur Prozessor: 14 Token pro Sekunde', 'Mit Grafikkarte: 106 Token pro Sekunde',
         'Kontext lesen: 50 gegen 2700 pro Sekunde', 'Auch ein zweiter Rechner im Netz kann die KI übernehmen (llama.cpp)']), titel='Schneller mit Grafikkarte',
         text='Mit einer Grafikkarte ist die KI deutlich schneller. In unserem Test antwortete das Modell auf dem Prozessor mit vierzehn Token pro Sekunde, auf einer älteren NVIDIA-Karte mit hundertsechs. NOMAD kann die KI auch von einem zweiten, stärkeren Rechner im Heimnetz beziehen, zum Beispiel über llama punkt c p p.'),
    dict(id='d11', karte=dict(titel='Grenzen, ehrlich benannt', punkte=['Nicht alle Nachschlagewerke sind für die KI durchsuchbar (PDF-Bücher)', 'Große Wikipedia-Pakete: viele Stunden Indexierung',
         'Inhalte und Karten-Beschriftung überwiegend englisch', 'Die KI ist ein Helfer, kein Arzt']), titel='Grenzen',
         text='Zur Ehrlichkeit gehören die Grenzen. Nachschlagewerke, die als PDF vorliegen, kann die KI praktisch nicht durchsuchen. Große Wikipedia-Pakete brauchen viele Stunden. Die Inhalte sind überwiegend englisch. Und die KI ist ein Helfer zum Suchen und Erklären, kein Arzt.'),
    dict(id='d12', bild='schluss', titel='Zum Schluss',
         text='Das war der Überblick über die Erweiterungen. Alles Weitere steht im Handbuch, das Sie als PDF und als Webseite im Projekt finden. Vielen Dank fürs Zuschauen.'),
])

VIDEOS = {'v1': V1, 'v2': V2, 'v3': V3, 'v4': V4}
