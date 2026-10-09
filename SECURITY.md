# Sicherheitshinweise (deutsche Fassung)

Sicherheitslücken, die nur die deutsche Fassung betreffen (z. B. Install-Skripte oder der Sprachumschalter dieses Forks), melden Sie bitte vertraulich an die Betreuer dieses Repositorys über die Sicherheitsfunktion von GitHub (Security Advisories), nicht als öffentliches Issue. Lücken im Original melden Sie bitte gemäß der folgenden Richtlinie (deutsche Übersetzung des englischen Originals) beim [Original-Projekt](https://github.com/Crosstalk-Solutions/project-nomad). Nur die jeweils neueste Version erhält Sicherheitskorrekturen.

*Übersetzung des Originals (nicht rechtsverbindlich):*

---

# Sicherheitsrichtlinie

## Unterstützte Versionen

Nur die jeweils neueste veröffentlichte Version von Project NOMAD erhält
Sicherheitskorrekturen. Wenn Sie eine ältere Version betreiben, aktualisieren
Sie bitte, bevor Sie ein Problem melden.

## Eine Sicherheitslücke melden

**Bitte eröffnen Sie für eine Sicherheitslücke kein öffentliches Issue.**

Melden Sie sie vertraulich über das in GitHub integrierte Meldeformular:

1. Öffnen Sie den [Reiter „Security“](https://github.com/Crosstalk-Solutions/project-nomad/security)
2. Klicken Sie auf **Report a vulnerability**

Dadurch wird ein privates Advisory angelegt, das nur die Betreuer sehen können.
Es bleibt vertraulich, bis eine Korrektur verfügbar ist und wir uns zur
Veröffentlichung entschließen.

Falls Sie das Formular aus irgendeinem Grund nicht nutzen können, schreiben Sie
stattdessen eine E-Mail an **chris@crosstalksolutions.com**. Bitte nennen Sie
keine Details zum Exploit in einer Discord-Nachricht oder einem öffentlichen
Issue.

### Was Sie angeben sollten

Je mehr davon Sie liefern können, desto schneller können wir das Problem
bestätigen und beheben:

- Die getestete NOMAD-Version und das Betriebssystem des Hosts
- Welche Komponente betroffen ist (Command Center, Installer, Updater-Sidecar,
  eine Supply-Depot-App, der Übermittlungsweg des Benchmarks usw.)
- Schritte zur Reproduktion, am besten mit der genauen Anfrage oder dem
  genauen Befehl
- Was ein Angreifer gewinnt und welchen Zugriff er dafür anfangs braucht
- Einen Lösungsvorschlag, falls Sie einen haben

### Was Sie erwarten können

Project NOMAD wird von einem sehr kleinen Team betreut, deshalb können wir
keine garantierte Antwortzeit zusichern. Wir lesen jede Meldung. Ist eine
Meldung berechtigt, arbeiten wir mit Ihnen an einer Korrektur und nennen Sie im
veröffentlichten Advisory, es sei denn, Sie bleiben lieber anonym.

Wir betreiben kein Bug-Bounty-Programm und können Meldungen nicht vergüten.

## Geltungsbereich

### Im Geltungsbereich

- Remotecodeausführung, Container-Ausbruch oder Rechteausweitung auf dem Host
- Jeder Weg, auf dem eine Gegenstelle, die **nicht** im lokalen Netzwerk ist, eine
  NOMAD-Instanz beeinflussen kann, einschließlich Angriffen über den Browser
  eines Nutzers
- Nicht authentifizierter Zugriff auf Daten außerhalb des NOMAD-Speicherstamms
- Path Traversal, SSRF über das vorgesehene Ziel hinaus oder Injection in der
  API des Command Centers
- Lieferkettenprobleme in unserer Build- und Release-Pipeline
- In dieses Repository eingecheckte Zugangsdaten oder Geheimnisse

### Außerhalb des Geltungsbereichs

Manches, was wie eine Schwachstelle aussieht, sind bewusste Entwurfsentscheidungen
für ein Offline-Produkt als Einzelgerät im lokalen Netzwerk. Meldungen zu
Folgendem werden in der Regel geschlossen:

- **Keine Authentifizierung am Command Center.** Das ist beabsichtigt und im
  [README](README.md#about-security) dokumentiert. NOMAD ist dafür ausgelegt,
  in einem vertrauenswürdigen lokalen Netzwerk offen zu sein. Wenn Sie
  Zugriffskontrolle brauchen, nutzen Sie Maßnahmen auf Netzwerkebene. Es gibt
  einen offenen Roadmap-Eintrag, für den Sie abstimmen können, falls Sie eine
  optionale Authentifizierung wünschen:
  https://roadmap.projectnomad.us/posts/1/user-authentication-please-build-in-user-auth-with-admin-user-roles
- **Alles, was erfordert, NOMAD direkt im Internet zugänglich zu machen.** Das
  wird ausdrücklich nicht unterstützt und davon wird abgeraten.
- **Zugriff durch jemanden, der bereits im lokalen Netzwerk ist.** Der Zugang
  zum lokalen Netzwerk ist von vornherein die Vertrauensgrenze.
- **Anfragen an interne oder private Adressen.** NOMAD soll andere Hosts im
  lokalen Netzwerk erreichen können, daher gelten Ziele nach RFC 1918 nicht als
  SSRF.
- Der Signaturschlüssel für die Benchmark-Übermittlung. Er ist im Image
  enthalten, weil ein Offline-Gerät kein serverseitiges Geheimnis aufbewahren
  kann. Gefälschte Einreichungen werden durch Moderation der Bestenliste
  behandelt, nicht durch den Schlüssel.
- Fehlende Sicherheits-Header, fehlende Ratenbegrenzungen oder ähnliche Befunde
  ohne nachgewiesene Auswirkung auf ein Gerät dieser Bauart.
- Schwachstellen in Supply-Depot-Anwendungen von Drittanbietern. Bitte melden
  Sie diese beim jeweiligen Upstream-Projekt. Sagen Sie uns trotzdem Bescheid,
  wenn das Problem durch die Art entsteht, wie NOMAD die App konfiguriert oder
  bereitstellt.
- Befunde eines automatischen Scanners ohne funktionierenden Proof of Concept.

Wenn Sie nicht sicher sind, ob etwas im Geltungsbereich liegt, melden Sie es.
Wir lesen lieber eine Meldung außerhalb des Geltungsbereichs, als eine echte zu
verpassen.

## Geheimnisse in diesem Repository

In diesem Repository sind Secret Scanning und Push Protection aktiviert. Wenn
Sie glauben, dass eine Zugangsdaten eingecheckt wurde, melden Sie dies bitte
vertraulich nach dem oben beschriebenen Verfahren, statt ein Issue zu eröffnen,
damit sie ausgetauscht werden kann, bevor sie bekannt wird.

Beachten Sie, dass der Installer jedes Datenbankpasswort und jeden
Anwendungsschlüssel bei der Installation lokal erzeugt. Die Platzhalterwerte in
`install/management_compose.yaml` sind keine echten Zugangsdaten.
