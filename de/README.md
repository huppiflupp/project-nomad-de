# Verzeichnis `de/` – Pflege der deutschen Fassung

Dieses Verzeichnis enthält alles, was nur für den deutschen Fork gilt und im Original nicht vorkommt.

| Pfad | Inhalt |
|---|---|
| `STAND.md` | Arbeitsstand der Übersetzung und Abgleiche |
| `specs/` | Entwurfsdokumente der Teilprojekte |
| `plans/` | Umsetzungspläne |
| `tools/` | Prüfskripte: `check-distribution.sh` (Verteilung/Install-Skripte verweisen auf den Fork), `script-check.sh`, `docs-check.mjs`, `sie-check.mjs` (Sie-Form) |

## Abgleich mit dem Original (Merge-Regeln)

`README.md` und `FAQ.md` sind im Fork komplett deutsch. Damit ein Merge vom Original sie nicht überschreibt, steht in `.gitattributes`:

```
README.md merge=ours
FAQ.md merge=ours
```

Der Merge-Treiber `ours` ist nur lokale Git-Konfiguration und muss auf **jedem Klon** einmal gesetzt werden:

```bash
git config merge.ours.driver true
```

Änderungen am Original-README/-FAQ müssen daher von Hand geprüft und übersetzt übernommen werden. (Die ausführliche Beschreibung des Abgleichs folgt in `de/SYNC.md`.)

## Versionierung

Reines SemVer; Patch = 100 × Patch des Originals + n. Die erste deutsche Version 1.35.1 beruht auf Project NOMAD 1.35.0; Original 1.35.1 wird zu 1.35.101, Original 1.36.0 zu 1.36.1.
