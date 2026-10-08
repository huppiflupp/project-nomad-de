// de/tools/sie-check.mjs – meldet du-Formen in deutschen Werten. Aufruf: node de/tools/sie-check.mjs admin/i18n/de.json …
import { readFileSync } from 'node:fs'
const DU = /\b(du|dich|dir|dein|deine|deinen|deinem|deiner|deines|euch|euer|eure)\b|\b\w+(st)\s+du\b/i
let bad = 0
for (const f of process.argv.slice(2)) {
  for (const [k, v] of Object.entries(JSON.parse(readFileSync(f, 'utf8')))) {
    if (typeof v === 'string' && DU.test(v)) { bad++; console.log(`${f}: ${k} -> ${v}`) }
  }
}
console.log(`du-Formen: ${bad}`)
process.exit(bad ? 1 : 0)
