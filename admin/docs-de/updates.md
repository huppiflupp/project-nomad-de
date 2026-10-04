# NOMAD aktuell halten

NOMAD funktioniert am besten, wenn es aktuell gehalten wird, solange Sie Internet haben – so ist es beim nächsten Offline-Einsatz mit der neuesten Software und den neuesten Inhalten bereit. Diese Seite erklärt, was aktualisiert werden kann, wie Sie das bei Bedarf selbst tun und wie NOMAD es automatisch für Sie erledigt.

---

## Die drei Arten von Updates

Drei verschiedene Dinge können aktualisiert werden, und Sie steuern jedes einzeln:

1. **Software (der Kern)** – NOMAD selbst: die Kommandozentrale, neue Funktionen, Fehlerbehebungen und Sicherheitsverbesserungen.
2. **Apps** – die installierbaren Apps aus dem [Supply Depot](/supply-depot) (Kiwix, der KI-Assistent und alle weiteren, die Sie hinzugefügt haben).
3. **Inhalte** – Ihr Offline-Material: Wikipedia und andere Kiwix-Bibliotheken sowie heruntergeladene Kartenregionen.

Sie können jedes davon bei Bedarf aktualisieren oder jedes automatisch aktualisieren lassen.

---

## Manuell aktualisieren

So suchen Sie selbst nach Updates und installieren sie:

1. Gehen Sie zu **[Einstellungen → Nach Updates suchen](/settings/update)**.
2. Wenn ein Software-Update verfügbar ist, klicken Sie, um es zu installieren. NOMAD lädt das Update herunter und startet neu (meist 2–5 Minuten).
3. Apps können über ihre Karte im [Supply Depot](/supply-depot) mit **Verwalten › Update** aktualisiert werden.
4. Inhalte verwalten Sie unter **Einstellungen → Content-Manager** und im **Inhalts-Explorer**, wo Sie neuere Versionen installierter Bibliotheken und Karten herunterladen können.

Sollte ein Software- oder App-Update einmal fehlschlagen, ist NOMAD darauf ausgelegt, sich sauber zu erholen – die bisherige funktionierende Version läuft weiter, Ihr Server bleibt also verfügbar.

---

## Automatische Updates

NOMAD kann sich selbst aktuell halten, ohne dass Sie daran denken müssen, nachzusehen. **Automatische Updates sind optional und standardmäßig aus** – nichts wird von selbst aktualisiert, bis Sie es einschalten. Sie verwalten alles unter **Einstellungen → Updates**.

Für alle drei gilt:

- **Sie wählen ein Zeitfenster.** Automatische Updates laufen nur in den von Ihnen festgelegten Stunden, sodass sie Sie nie mitten in der Nutzung unterbrechen.
- **Hauptversionen werden nie automatisch installiert.** Nur Minor- und Patch-Updates werden von selbst angewendet; ein großer Versionssprung wartet immer darauf, dass Sie ihn bewusst manuell durchführen.
- **Sicherheitsprüfungen kommen zuerst.** Bevor etwas angewendet wird, stellt NOMAD sicher, dass genügend Speicherplatz vorhanden ist und kein anderes Update, kein Download und keine Installation bereits läuft.
- **Offline zu sein schadet nicht.** Kann NOMAD zum Prüfen das Internet nicht erreichen, überspringt es diese Runde einfach und versucht es später erneut.

### Automatische Software-Updates (Kern)

Schalten Sie dies unter **Einstellungen → Updates** ein. Ist es aktiviert, aktualisiert NOMAD seinen Kern innerhalb Ihres gewählten Zeitfensters auf neuere Releases derselben Hauptversion, und zwar nach einer konfigurierbaren **Abklingzeit** (damit ein brandneues Release Gelegenheit hat, sich zu bewähren, bevor Ihr Server es übernimmt). Dieselbe Seite zeigt den Schalter, das Zeitfenster, die Einstellung der Abklingzeit und den Live-Status. Schlagen Updates wiederholt aus einem echten Grund fehl, schaltet NOMAD die Funktion wieder aus und benachrichtigt Sie, statt endlos weiterzuprobieren.

### Automatische App-Updates

Automatische App-Updates sind auf **zwei Ebenen** optional: ein Hauptschalter unter **Einstellungen → Updates** *und* ein Schalter pro App auf der Karte der jeweiligen App im [Supply Depot](/supply-depot). Beide müssen eingeschaltet sein, damit sich eine App selbst aktualisiert. App-Updates teilen sich Zeitfenster und Abklingzeit mit dem Kern, wenden nur Minor- und Patch-Versionen an und ziehen sich automatisch für jede einzelne App zurück, die wiederholt fehlschlägt.

### Automatische Inhalts-Updates

Auch installierte Wikipedia-/ZIM-Bibliotheken und Kartenregionen können sich selbst aktualisieren. Da Inhalts-Downloads groß sind (oft viele Gigabyte), laufen Inhalts-Updates in einem **eigenen Nachtzeitfenster** mit einer **Bandbreitenbegrenzung**, getrennt vom Zeitplan für Software und Apps. NOMAD prüft die Upstream-Kataloge von Kiwix und Karten direkt, und wenn eine Wikipedia-Bibliothek durch eine neuere Version ersetzt wird, hält es die KI-Wissensdatenbank automatisch synchron.

---

## Early-Access-Kanal

Möchten Sie neue Funktionen, bevor sie das stabile Release erreichen? Aktivieren Sie den **Early-Access-Kanal** auf der Seite [Nach Updates suchen](/settings/update), um Release-Candidate-Builds zu erhalten. Early-Access-Builds können Ecken und Kanten haben – Sie können jederzeit zum stabilen Kanal zurückwechseln.

---

## Bevor Sie offline gehen

Was auch immer Sie wählen: Die wichtigste Gewohnheit ist einfach: **aktualisieren, solange Sie noch Internet haben.** Ob Sie es von Hand tun oder automatische Updates übernehmen lassen – stellen Sie sicher, dass Software und Inhalte aktuell sind, bevor Sie an einen Ort ohne Verbindung aufbrechen. Wenn Sie offline sind, haben Sie von allem die zuletzt synchronisierten Versionen bereit.

**[Nach Updates suchen →](/settings/update)** · **[Neuerungen in jeder Version ansehen →](/docs/release-notes)**
