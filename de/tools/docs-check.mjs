// de/tools/docs-check.mjs – vergleicht admin/docs/X.md mit admin/docs-de/X.md
import { readFileSync, readdirSync, existsSync } from 'node:fs'
const en = 'admin/docs', de = 'admin/docs-de'
// Diese Dateien enthalten bewusst abweichende Codeblöcke (Installationsbefehle zeigen auf den Fork).
const ALLOW_CODE_DIFF = ['getting-started.md', 'faq.md', 'updates.md']
// release-notes.md: deutscher Abschnitt vorangestellt, Rest englisch – keine Überschriften-Prüfung.
const SKIP_HEADINGS = ['release-notes.md']
const count = (s, re) => (s.match(re) || []).length
const codeBlocks = (s) => s.match(/```[\s\S]*?```/g) || []
// Deutsche Bildfassungen heißen name-de.webp; für den Vergleich gelten sie als dasselbe Bild.
const links = (s) => [...s.matchAll(/\]\(([^)]+)\)/g)].map((m) => m[1].replace(/-de\.webp$/, ".webp")).sort()
const tags = (s) => (s.match(/\{%[^%]*%\}/g) || []).map((x) => x.replace(/"[^"]*"/g, '""')).sort()
let bad = 0
for (const f of readdirSync(en).filter((f) => f.endsWith('.md'))) {
  if (!existsSync(`${de}/${f}`)) { console.log(`FEHLT ${f}`); bad++; continue }
  const a = readFileSync(`${en}/${f}`, 'utf8'), b = readFileSync(`${de}/${f}`, 'utf8')
  const checks = [
    ['Codeblöcke', JSON.stringify(codeBlocks(a)), JSON.stringify(codeBlocks(b))],
    ['Links', JSON.stringify(links(a)), JSON.stringify(links(b))],
    ['Markdoc-Tags', JSON.stringify(tags(a)), JSON.stringify(tags(b))],
    ['Bilder', count(a, /!\[/g), count(b, /!\[/g)],
  ]
  if (!SKIP_HEADINGS.includes(f)) checks.unshift(['Überschriften', count(a, /^#{1,6} /gm), count(b, /^#{1,6} /gm)])
  for (const [name, x, y] of checks) {
    if (x === y) continue
    if (name === 'Codeblöcke' && ALLOW_CODE_DIFF.includes(f)) {
      if (codeBlocks(a).length !== codeBlocks(b).length) { console.log(`${f}: Anzahl Codeblöcke weicht ab`); bad++ }
      continue
    }
    console.log(`${f}: ${name} weichen ab`); bad++
  }
  if (f !== 'release-notes.md' && /\b(du|dich|dir|dein(?:e[mnrs]?)?)\b/i.test(b.replace(/```[\s\S]*?```/g, ''))) { console.log(`${f}: du-Form`); bad++ }
}
console.log(bad ? `${bad} Probleme` : 'docs-check: ok')
process.exit(bad ? 1 : 0)
