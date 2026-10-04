# Arzneimittel-Referenz

Die Arzneimittel-Referenz ist eine durchsuchbare Offline-Datenbank mit **FDA-Beipackzetteln** (Arzneimittel-Labels der US-Arzneimittelbehörde FDA), den offiziellen Informationen, die rezeptfreien und verschreibungspflichtigen Medikamenten beiliegen. Nach der Installation können Sie ein Medikament nach Namen nachschlagen, von einer Situation ausgehend die passenden Medikamente finden und zwei Beipackzettel nebeneinander legen – alles ohne Internetverbindung.

Sie ist eine optionale Erweiterung. Ein frisches NOMAD hat sie nicht, bis Sie sich für die Installation entscheiden, weil der Datensatz groß ist.

> **Dies sind Gesundheitsinformationen, keine medizinische Beratung.** Die Arzneimittel-Referenz zeigt Ihnen den FDA-Beipackzettel-Text des Herstellers und ordnet Situationen rezeptfreien Optionen zu. Sie kann Ärztin oder Arzt, Apotheke oder Pflegefachkraft nicht ersetzen. Befolgen Sie stets die Hinweise auf dem tatsächlichen Produkt, das Sie haben, und holen Sie sich in einem echten Notfall nach Möglichkeit professionelle Hilfe.

Wenn Sie die Arzneimittel-Referenz zum ersten Mal in einem Browser öffnen, sehen Sie diesen Hinweis als Dialog, den Sie bestätigen müssen, bevor die Seite geladen wird. Diese Bestätigung wird pro Browser gespeichert; ein anderer Browser oder ein anderes Gerät zeigt sie daher erneut an.

---

## Installation

Es gibt zwei Wege, die Daten zu erhalten; beide führen zum selben Ergebnis.

**Über den Inhalts-Explorer**, als Teil einer Sammlung:

1. Öffnen Sie auf der Startseite den **Inhalts-Explorer**.
2. Wählen Sie die Kategorie **Medizin**.
3. Wählen Sie die Stufe **Standard**. Ihr Inhalt ist auf der Karte aufgeführt, und Sie sehen darunter **FDA-Arzneimittel-Referenz**.
4. Bestätigen Sie den Download.

**Über die Seite der Arzneimittel-Referenz selbst.** Öffnen Sie **Arzneimittel-Referenz** auf der Startseite. Sind keine Daten installiert, erscheint ein Bereich „Noch keine FDA-Arzneimitteldaten“ mit einer Schaltfläche **FDA-Arzneimitteldaten herunterladen**, die denselben Vorgang startet.

In beiden Fällen läuft er im Hintergrund in zwei Phasen ab:

- **Download** – NOMAD lädt den openFDA-Datensatz der Arzneimittel-Labels herunter, komprimiert etwa **1,7 GB**, in mehreren Teilen. Bricht Ihre Verbindung ab, wird dort fortgesetzt, wo er aufgehört hat.
- **Indizierung** – NOMAD liest diese Labels in eine schnelle Offline-Suchdatenbank ein. Dies ist die längere Phase, und die Daten wachsen auf der Festplatte auf etwa **8 bis 10 GB**.

Sie müssen nicht zusehen. Verlassen Sie die Seite, er läuft weiter, und die Suche schaltet sich von selbst ein, sobald die Indizierung abgeschlossen ist. Die Seite zeigt den Fortschritt beider Phasen, solange sie laufen.

---

## Orientierung

Alles befindet sich hinter einer einzigen Kachel **Arzneimittel-Referenz** auf der Startseite. Sobald Daten installiert sind, hat die Seite drei Tabs.

### Nach Arzneimittel suchen

Geben Sie einen Arzneimittelnamen ein, Marken- oder Wirkstoffname, und NOMAD zeigt passende FDA-Beipackzettel: wofür das Medikament gedacht ist, Dosierung, Warnhinweise und Inhaltsstoffe, direkt aus dem offiziellen Beipackzettel des Herstellers.

Die Ergebnisse werden **nach Wirkstoff gruppiert**, statt als Hunderte nahezu identischer Produkte aufgelistet zu werden. Eine Suche nach einem gängigen Schmerzmittel liefert eine Gruppe je Wirkstoff statt jeder Handelsmarke einzeln, sodass Sie sehen, zwischen was Sie tatsächlich wählen.

### Nach Situation

Gehen Sie vom Problem statt vom Produkt aus. Wählen Sie eine oder mehrere Situationen, etwa Verbrennung, Fieber oder Durchfall, und NOMAD listet die Medikamente auf, deren FDA-Beipackzettel sie abdecken.

Wählen Sie mehr als eine Situation, sucht NOMAD zuerst nach Medikamenten, die **alle** abdecken, und zeigt dann ersatzweise die Ergebnisse für jede Situation einzeln. Das ist nützlich, wenn Sie mehrere Symptome gleichzeitig behandeln müssen und ein einzelnes Produkt möchten, falls es eines gibt.

### FDA-Daten

Zeigt, woher die Daten stammen und in welchem Zustand sie sind: ob sie heruntergeladen und indiziert sind und wie viele Beipackzettel geladen sind. Hier können Sie auch einen Download erneut starten oder die Indizierung neu anstoßen, falls etwas Aufmerksamkeit braucht.

---

## Zwei Medikamente vergleichen

Verwenden Sie auf der Detailseite eines Medikaments **Warnhinweise vergleichen**, um zwei Beipackzettel nebeneinander zu legen und zu lesen, was jeder sagt.

Dabei werden die Warnhinweis-Abschnitte der beiden Hersteller nebeneinander gestellt. Es werden **keine** Wechselwirkungen berechnet, und es wird Ihnen nicht gesagt, ob eine Kombination sicher ist. Ob zwei Medikamente zusammen eingenommen werden können, ist genau die Art von Frage, die Sie an eine Apothekerin, einen Apotheker oder eine Ärztin bzw. einen Arzt richten sollten.

---

## Aktuell halten

FDA-Beipackzettel ändern sich im Lauf der Zeit. Wenn Sie **Automatische Inhalts-Updates** eingeschaltet haben (Einstellungen → Updates), prüft NOMAD regelmäßig, ob openFDA einen neueren Datensatz veröffentlicht hat, und aktualisiert die Arzneimittel-Referenz von selbst, genauso wie Ihre anderen Offline-Inhalte.

Bei ausgeschalteten automatischen Updates bleiben die Daten genau so, wie sie bei der Installation waren, was für die Offline-Nutzung in Ordnung ist. Sie können den Download jederzeit im Tab **FDA-Daten** erneut starten, um die neuesten Daten zu holen.

---

## Hinweis zum Speicherplatz

Die Arzneimittel-Referenz ist der größte einzelne Bestandteil der Sammlung Medizin → Standard. Planen Sie nach der Indizierung etwa **8 bis 10 GB** Festplattenplatz dafür ein, zusätzlich zum Download von 1,7 GB.

Wenn der Speicherplatz knapp ist, zeigt der Inhalts-Explorer die volle Größe einer Stufe an, bevor Sie sich festlegen, sodass Sie sehen, was auf Sie zukommt.
