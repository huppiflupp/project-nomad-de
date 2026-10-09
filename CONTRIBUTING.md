# Mitwirken an der deutschen Fassung (deutsche Fassung)

Beiträge zu dieser deutschen Fassung (Übersetzungen, Korrekturen, Install-Skripte) sind willkommen: Eröffnen Sie ein Issue oder einen Pull Request in diesem Repository. Beiträge, die das Original betreffen (Funktionen, Fehler in der englischen Fassung), gehören dagegen in das [Original-Projekt](https://github.com/Crosstalk-Solutions/project-nomad). Übersetzungen halten Sie bitte in der Sie-Form und nach dem Glossar der Übersetzungsrichtlinien; Hinweise zur Pflege des Forks finden Sie in [de/README.md](de/README.md).

Die folgenden Richtlinien des Originals gelten sinngemäß weiter (deutsche Übersetzung, nicht verbindlich; maßgeblich ist das englische Original).

*Übersetzung des Originals:*

---

# Mitwirken an Project NOMAD

Vielen Dank für Ihr Interesse, an Project NOMAD mitzuwirken! Beiträge aus der Community halten dieses Projekt am Wachsen und machen es besser. Bitte lesen Sie diese Anleitung vollständig, bevor Sie beginnen – das spart Ihnen (und den Betreuern) viel Zeit.

> **Hinweis:** Beiträge werden nicht zwangsläufig angenommen. Alle Pull Requests werden nach Qualität, Relevanz und Übereinstimmung mit den Zielen des Projekts beurteilt. Die Betreuer von Project NOMAD („NOMAD“) behalten sich vor, jeden Pull Request nach eigenem Ermessen anzunehmen, abzulehnen oder zu ändern.

---

## Inhaltsverzeichnis

- [Verhaltenskodex](#verhaltenskodex)
- [Bevor Sie beginnen](#bevor-sie-beginnen)
- [Erste Schritte](#erste-schritte)
- [Entwicklungsablauf](#entwicklungsablauf)
- [Einheitliche Benutzeroberfläche](#einheitliche-benutzeroberfläche)
- [Commit-Nachrichten](#commit-nachrichten)
- [Versionshinweise](#versionshinweise)
- [Versionierung](#versionierung)
- [Pull Request einreichen](#pull-request-einreichen)
- [Feedback und Community](#feedback-und-community)

---

## Verhaltenskodex

Bitte lesen Sie vor Ihrem Beitrag den vollständigen [Verhaltenskodex](https://github.com/Crosstalk-Solutions/project-nomad/blob/main/CODE_OF_CONDUCT.md) (Original, Englisch). Kurz gesagt: Bitte gehen Sie mit den Betreuern und anderen Mitwirkenden stets respektvoll und rücksichtsvoll um.

Wir möchten allen ein einladendes Umfeld bieten. Respektloses oder beleidigendes Verhalten wird nicht geduldet.

---

## Bevor Sie beginnen

**Eröffnen Sie zuerst ein Issue.** Bevor Sie bei einer nicht trivialen Änderung Code schreiben, müssen Sie [ein Issue eröffnen](../../issues/new), um Ihre geplante Änderung zu besprechen. Das vermeidet doppelte Arbeit und stellt sicher, dass Ihr Beitrag zur Ausrichtung des Projekts passt. **Pull Requests ohne zugehöriges Issue können nach Ermessen der Betreuer geschlossen werden.**

**Triviale Korrekturen sind ausgenommen** und können direkt als PR eingereicht werden. Beispiele:
- Korrekturen von Tippfehlern und Grammatik
- Klarstellungen in der Dokumentation
- Kleine Fehlerbehebungen in einer Zeile mit offensichtlicher Ursache

Wenn Sie nicht sicher sind, ob Ihre Änderung als trivial gilt, eröffnen Sie zuerst ein Issue.

Beim Eröffnen eines Issues:
- Verwenden Sie einen klaren, aussagekräftigen Titel
- Beschreiben Sie das Problem, das Sie lösen, oder die Funktion, die Sie hinzufügen möchten
- Bei einem Fehler: Geben Sie die Schritte zur Reproduktion und möglichst viele Angaben zu Ihrer Umgebung an
- Entfernen Sie persönliche oder sensible Informationen in Protokollen, Konfigurationen usw.

---

## Erste Schritte beim Mitwirken
**Bitte beachten Sie**: Dies ist die Einstiegsanleitung für die Entwicklung von und das Mitwirken an NOMAD, NICHT für die [Installation von NOMAD](https://github.com/Crosstalk-Solutions/project-nomad/blob/main/README.md) zur normalen Nutzung! 

### Voraussetzungen

- Ein Debian-basiertes Betriebssystem (empfohlen: Ubuntu 26.04 LTS)
- `sudo`-/Root-Rechte
- Installiertes und laufendes Docker
- Eine stabile Internetverbindung (für den Download von Abhängigkeiten erforderlich)
- Node.js (für Arbeiten am Frontend bzw. an der Verwaltung)

### Forken und Klonen

1. Klicken Sie oben rechts in diesem Repository auf **Fork**
2. Klonen Sie Ihren Fork lokal:
   ```bash
   git clone https://github.com/YOUR_USERNAME/project-nomad.git
   cd project-nomad
   ```
3. Fügen Sie das Upstream-Remote hinzu, damit Sie auf dem Laufenden bleiben:
   ```bash
   git remote add upstream https://github.com/Crosstalk-Solutions/project-nomad.git
   ```

### Keine Release-Version lokal installieren
Da NOMAD stark auf Docker setzt, raten wir davon ab, auf demselben Rechner, auf dem Sie entwickeln, eine Release-Version des Projekts zu installieren. Das kann zu Konflikten bei Ports, Volumes und anderen Ressourcen führen. Besser betreiben Sie Ihre Entwicklungsversion in einer separaten Docker-Umgebung und halten Ihren lokalen Rechner sauber. Es __lässt sich__ durchaus machen, macht Ihre Einrichtung und Ihren Arbeitsablauf aber komplizierter. Wenn Sie sich trotzdem für eine lokale Release-Installation entscheiden, sorgen Sie bitte für eine klare Strategie im Umgang mit möglichen Konflikten und der Ressourcennutzung.

---

## Entwicklungsablauf

1. **Mit Upstream synchronisieren**, bevor Sie neue Arbeit beginnen. Wir bevorzugen Rebasing statt Merge-Commits, um die Git-Historie möglichst sauber und linear zu halten (das erleichtert den Betreuern auch das Prüfen und Übernehmen Ihrer Änderungen). So synchronisieren Sie mit Upstream:
   ```bash
   git fetch upstream
   git checkout dev
   git rebase upstream/dev
   ```

2. **Erstellen Sie einen Feature-Branch** von `dev` mit einem aussagekräftigen Namen:
   ```bash
   git checkout -b fix/issue-123
   # or
   git checkout -b feature/add-new-tool
   ```

3. **Nehmen Sie Ihre Änderungen vor.** Halten Sie sich an den vorhandenen Code-Stil und die Konventionen. Testen Sie Ihre Änderungen vor dem Einreichen lokal gegen eine laufende NOMAD-Instanz.

4. **Wenn Sie den KI-Assistenten oder RAG verändert haben, messen Sie das.** Alles, was Chunking, Embedding, Retrieval, Reranking, Schwellenwerte, die System-Prompts oder den Aufbau des Kontexts betrifft, sollte durch Zahlen statt durch eine Stichprobe belegt sein –
   „im Chatfenster schien es besser“ ist der Weg, auf dem Rückschritte ausgeliefert werden. Aus dem Verzeichnis `admin/`:

   ```bash
   node ace eval:corpus --ingest        # once; safe, never touches your real knowledge base
   node ace eval:retrieval --ablate     # seconds, deterministic, no chat model
   node ace eval:generation --model=<your model> --all-modes
   ```

   Geben Sie die Zahlen vorher/nachher in Ihrem Pull Request an. Was die
   Metriken bedeuten, wie die drei Generierungsmodi einen Fehler im Code von
   einem schlicht zu kleinen Modell unterscheiden und welche bekannten
   Einschränkungen das Testwerkzeug hat, steht in
   [`admin/tests/eval/README.md`](admin/tests/eval/README.md).

5. **Committen Sie Ihre Änderungen** nach [Conventional Commits](#commit-nachrichten).

6. **Pushen Sie Ihren Branch** und eröffnen Sie einen Pull Request.

---

## Einheitliche Benutzeroberfläche

Leitprinzip von NOMAD ist, dass **Benutzerfreundlichkeit an erster Stelle steht**: Ein Bedienelement, das anders aussieht oder sich anders verhält als der Rest der Anwendung, wirkt auf technisch nicht versierte Nutzer kaputt. Neue Arbeiten am Frontend (Inertia/React) sollten optisch und im Verhalten zum Vorhandenen passen. Schauen Sie sich vor dem Hinzufügen eines UI-Elements seine Nachbarn an und verwenden Sie die gemeinsamen Bausteine, statt eine Einzellösung zu bauen.

**Verwenden Sie die gemeinsamen Komponenten** in `admin/inertia/components/` (und `.../components/inputs/`):

| Bedarf | Verwenden | Nicht |
|------|-----|-----|
| Binäre Ein/Aus-Einstellung | `Switch` | ein einfaches `<input type="checkbox">` |
| Erklärende Hover-Hilfe | `InfoTooltip` | ein einfaches `title=`-Attribut oder ein eigener Tooltip |
| Modal / Bestätigungsdialog | `StyledModal` | ein selbstgebautes Overlay |
| Textfeld | `Input` | ein nacktes `<input>` |
| Abschnittsüberschrift | `StyledSectionHeader` | selbst gebaute Überschriften-Markups |

Suchen Sie per Grep nach einer vorhandenen Komponente, bevor Sie eine neue bauen.

**Passen Sie sich den Nachbarn an.** Übernehmen Sie genau die Klassen und Konventionen benachbarter Elemente:

- **Beschriftungen:** Gleichen Sie Zeichensetzung und Groß-/Kleinschreibung benachbarter Beschriftungen an. Wenn das Feld neben Ihrem `Model:` (mit Doppelpunkt) heißt, sollte Ihres `Thinking:` heißen, nicht `Thinking`. Verwenden Sie dieselben Typografie-Tokens (z. B. `text-sm text-text-secondary`).
- **Design:** Verwenden Sie Design-Tokens (`text-*`, `bg-*`, `border-*`), damit das Element im hellen und im dunklen Modus funktioniert. Codieren Sie Farben niemals fest.
- **Platzierung:** Stellen Sie sicher, dass Popovers und Tooltips nicht am Rand des Anzeigebereichs abgeschnitten oder gequetscht werden, auch wenn der Auslöser nahe an einem Bildschirmrand sitzt.

**Wann ein einfaches Bedienelement in Ordnung ist.** Diese Konventionen sollen die Absicht treffen, nicht Grundelemente verbieten. Eine einfache Checkbox ist bei einer Mehrfachauswahl oder einem Einwilligungsfeld angemessen; Radiogruppen und native Auswahlfelder sind in Ordnung, wo es keine gemeinsame Komponente gibt. Es geht darum, zur gemeinsamen Komponente zu greifen, wenn Ihr Fall ihrem Zweck entspricht (ein Schalter für eine binäre Einstellung sollte ein `Switch` sein), nicht darum, Grundelemente abzuschaffen.

**Testen Sie UI-Änderungen in einem echten Browser.** Die meisten dieser Konventionen sind Ermessenssache, die sich mit Werkzeugen nicht vollständig durchsetzen lässt. Die wichtigste Gewohnheit ist daher, Ihre Änderung vor dem Einreichen gegen eine laufende Instanz in einem Browser zu laden. Mehrere Arten von Problemen (abgeschnittene oder gequetschte Tooltips, Layout, das bei anderen Fensterbreiten bricht, leere Seiten durch Renderfehler) sind für die Typprüfung unsichtbar und zeigen sich erst, wenn Sie sich die Seite wirklich ansehen. Prüfen Sie die Zustände, die erscheinen sollen, *und* die, die verborgen sein sollen, und probieren Sie mehr als eine Fensterbreite aus, wenn Layout oder Positionierung eine Rolle spielen.

---

## Commit-Nachrichten

Dieses Projekt verwendet [Conventional Commits](https://www.conventionalcommits.org/). Alle Commit-Nachrichten müssen diesem Format folgen:

```
<type>(<scope>): <description>
```

**Gängige Typen:**

| Typ | Wann verwenden |
|------|-------------|
| `feat` | Eine neue, für Nutzer sichtbare Funktion |
| `fix` | Eine Fehlerbehebung |
| `docs` | Ausschließlich Änderungen an der Dokumentation |
| `refactor` | Codeänderung, die weder Fehlerbehebung noch Funktion ist und die Funktionalität nicht beeinflusst |
| `chore` | Build-Prozess, Aktualisierung von Abhängigkeiten, Werkzeuge |
| `test` | Hinzufügen oder Aktualisieren von Tests |

Der **Scope** ist optional, wird aber empfohlen – er gibt den betroffenen Bereich der Codebasis an (z. B. `api`, `ui`, `maps`).

**Beispiele:**
```
feat(ui): add dark mode toggle to Command Center
fix(api): resolve container status not updating after restart
docs: update hardware requirements in README
chore(deps): bump docker-compose to v2.24
```

---

## Versionshinweise

Die für Menschen lesbaren Versionshinweise liegen in [`admin/docs/release-notes.md`](admin/docs/release-notes.md) und werden direkt in der Oberfläche des Command Centers angezeigt.

Wenn Ihr PR übernommen wird, aktualisieren die Betreuer die Versionshinweise mit einer Zusammenfassung Ihres Beitrags und nennen Sie als Autor. Sie müssen das nicht selbst im PR ergänzen (bitte tun Sie es nicht, da es Merge-Konflikte verursachen kann), können aber gern einen Textvorschlag in die PR-Beschreibung aufnehmen.

---

## Versionierung

Dieses Projekt verwendet [Semantic Versioning](https://semver.org/). Die Versionen werden in der `package.json` im Wurzelverzeichnis verwaltet und von `semantic-release` automatisch aktualisiert. Das Docker-Image `project-nomad` verwendet diese Version. Die Version in `admin/package.json` bleibt bei `0.0.0` und sollte nicht von Hand geändert werden.

---

## Pull Request einreichen

1. Pushen Sie Ihren Branch in Ihren Fork:
   ```bash
   git push origin your-branch-name
   ```
2. Eröffnen Sie einen Pull Request gegen den Branch `dev` dieses Repositorys
3. In der PR-Beschreibung:
   - Fassen Sie zusammen, was Ihre Änderungen bewirken und warum
   - Verweisen Sie auf das zugehörige Issue (z. B. `Closes #123`) – bei nicht trivialen Änderungen erforderlich
   - Nennen Sie relevante Testschritte oder Angaben zur Umgebung
4. Reagieren Sie auf Rückmeldungen – die Betreuer können Änderungen anfordern. Pull Requests, die längere Zeit ohne Aktivität bleiben, können geschlossen werden.

---

## Feedback und Community

Haben Sie Fragen oder möchten Sie Ideen besprechen, bevor Sie ein Issue eröffnen? Treten Sie der Community bei (englischsprachig):

- **Discord:** [Dem Server von Crosstalk Solutions beitreten](https://discord.com/invite/crosstalksolutions) – der beste Ort, um Hilfe zu bekommen, Ihre Aufbauten zu zeigen und sich mit anderen NOMAD-Nutzern auszutauschen
- **Website:** [www.projectnomad.us](https://www.projectnomad.us)
- **Benchmark-Bestenliste:** [benchmark.projectnomad.us](https://benchmark.projectnomad.us)

---

*Project NOMAD steht unter der [Apache License 2.0](LICENSE).*