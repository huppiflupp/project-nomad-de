// admin/i18n/cli.mjs
// Usage from admin/: node i18n/cli.mjs check | extract [--missing out.json]
import { readFileSync, readdirSync, statSync, writeFileSync, existsSync } from 'node:fs'
import { join, relative } from 'node:path'
import { fileURLToPath } from 'node:url'
import babel from '@babel/core'
import plugin from './babel-plugin.mjs'
import { looksHuman, normalize } from './text.mjs'

const SERVER_DIRS = ['app/controllers', 'app/services', 'app/jobs', 'app/validators', 'app/exceptions', 'app/utils']
const SERVER_PROPS = new Set(['message', 'error', 'reason', 'detail'])
const CATALOG_JSON_KEYS = new Set(['name', 'title', 'description', 'tagline', 'subtitle', 'label', 'summary'])
const SEEDER_PROPS = new Set(['friendly_name', 'description'])

function walk(dir, re, out = []) {
  if (!existsSync(dir)) return out
  for (const f of readdirSync(dir)) {
    const p = join(dir, f)
    if (statSync(p).isDirectory()) walk(p, re, out)
    else if (re.test(f) && !f.endsWith('.d.ts')) out.push(p)
  }
  return out
}

const pluginsFor = (file) => (file.endsWith('.tsx') ? ['jsx', 'typescript'] : ['typescript'])

const parse = (code, filename) =>
  babel.parseSync(code, { filename, babelrc: false, configFile: false, parserOpts: { plugins: [...pluginsFor(filename), 'decorators-legacy'] } })

function tplKey(node) {
  let s = ''
  node.quasis.forEach((q, i) => { s += q.value.cooked ?? q.value.raw; if (i < node.expressions.length) s += `{${i}}` })
  return normalize(s)
}
const strValue = (n) =>
  n?.type === 'StringLiteral' ? normalize(n.value) : n?.type === 'TemplateLiteral' ? tplKey(n) : null
// Server messages may pick singular/plural wording with a conditional: collect every branch.
const strValues = (n) =>
  n?.type === 'ConditionalExpression' ? [...strValues(n.consequent), ...strValues(n.alternate)] : [strValue(n)]
const keep = (k) => k && /[A-Za-z]/.test(k) && looksHuman(normalize(k.replace(/\{\d+\}/g, ' ')))

export function collectUi(root) {
  const keys = new Map()
  for (const file of walk(join(root, 'inertia'), /\.(tsx|ts)$/)) {
    const seen = new Set()
    try {
      babel.transformSync(readFileSync(file, 'utf8'), {
        filename: file, babelrc: false, configFile: false, code: false,
        parserOpts: { plugins: pluginsFor(file) }, plugins: [[plugin, { collect: seen }]],
      })
    } catch (e) {
      console.warn(`WARNUNG: ${file} nicht lesbar: ${String(e.message).split('\n')[0]}`)
      continue
    }
    for (const k of seen) if (!keys.has(k)) keys.set(k, relative(root, file))
  }
  return keys
}

export function collectServer(root) {
  const keys = new Map()
  for (const dir of SERVER_DIRS) {
    for (const file of walk(join(root, dir), /\.ts$/)) {
      let ast
      try { ast = parse(readFileSync(file, 'utf8'), file) } catch (e) {
        console.warn(`WARNUNG: ${file} nicht lesbar: ${String(e.message).split('\n')[0]}`)
        continue
      }
      babel.traverse(ast, {
        ObjectProperty(p) {
          const k = p.node.key
          const name = k.type === 'Identifier' ? k.name : k.type === 'StringLiteral' ? k.value : null
          if (!SERVER_PROPS.has(name)) return
          for (const v of strValues(p.node.value)) if (keep(v) && !keys.has(v)) keys.set(v, relative(root, file))
        },
        NewExpression(p) {
          const c = p.node.callee
          if (c.type !== 'Identifier' || !/(Exception|Error)$/.test(c.name)) return
          const v = strValue(p.node.arguments[0])
          if (keep(v) && !keys.has(v)) keys.set(v, relative(root, file))
        },
      })
    }
  }
  return keys
}

export function collectCatalog(root) {
  const keys = new Map()
  const visit = (v, file) => {
    if (Array.isArray(v)) return v.forEach((x) => visit(x, file))
    if (!v || typeof v !== 'object') return
    for (const [k, x] of Object.entries(v)) {
      if (typeof x === 'string' && CATALOG_JSON_KEYS.has(k)) {
        const n = normalize(x)
        if (keep(n) && !keys.has(n)) keys.set(n, file)
      } else visit(x, file)
    }
  }
  for (const file of walk(join(root, '..', 'collections'), /\.json$/)) {
    visit(JSON.parse(readFileSync(file, 'utf8')), relative(join(root, '..'), file))
  }
  const seeder = join(root, 'database/seeders/service_seeder.ts')
  if (existsSync(seeder)) {
    babel.traverse(parse(readFileSync(seeder, 'utf8'), seeder), {
      ObjectProperty(p) {
        const k = p.node.key
        if (k.type !== 'Identifier' || !SEEDER_PROPS.has(k.name)) return
        const v = strValue(p.node.value)
        if (keep(v) && !keys.has(v)) keys.set(v, 'admin/database/seeders/service_seeder.ts')
      },
    })
  }
  return keys
}

const ph = (s) => [...String(s).matchAll(/\{(\d+)\}/g)].map((m) => m[1]).sort().join(',')

export function checkDicts({ ui, server, catalog, de, cat }) {
  const deN = new Map(Object.entries(de).map(([k, v]) => [normalize(k), v]))
  const catN = new Map(Object.entries(cat).map(([k, v]) => [normalize(k), v]))
  const missing = []
  for (const [k, f] of [...ui, ...server]) if (!deN.get(k) && !missing.includes(`${f}: ${k}`)) missing.push(`${f}: ${k}`)
  // tc() looks only into the catalog dictionary (user data must never hit UI patterns)
  for (const [k, f] of catalog) if (!catN.get(k)) missing.push(`${f}: ${k}`)
  const badPlaceholders = []
  for (const [k, v] of [...deN, ...catN]) if (v && ph(k) !== ph(v)) badPlaceholders.push(`${k} -> ${v}`)
  const used = new Set([...ui.keys(), ...server.keys(), ...catalog.keys()])
  const orphans = [...deN.keys()].filter((k) => !used.has(k))
  return { missing, badPlaceholders, orphans }
}

function main() {
  const root = process.cwd()
  const [cmd, flag, out] = process.argv.slice(2)
  const ui = collectUi(root)
  const server = collectServer(root)
  const catalog = collectCatalog(root)
  const de = JSON.parse(readFileSync(join(root, 'i18n/de.json'), 'utf8'))
  const cat = JSON.parse(readFileSync(join(root, 'i18n/catalog.de.json'), 'utf8'))
  const r = checkDicts({ ui, server, catalog, de, cat })
  console.log(`Oberfläche ${ui.size}, Server ${server.size}, Kataloge ${catalog.size} Texte`)
  console.log(`fehlend ${r.missing.length}, Platzhalter-Fehler ${r.badPlaceholders.length}, verwaist ${r.orphans.length}`)
  if (cmd === 'extract' && flag === '--missing' && out) {
    const obj = {}
    for (const line of r.missing) obj[line.slice(line.indexOf(': ') + 2)] = ''
    writeFileSync(out, JSON.stringify(obj, null, 1) + '\n')
    console.log(`→ ${out}`)
    return
  }
  if (cmd === 'check') {
    r.missing.slice(0, 200).forEach((l) => console.log('FEHLT ' + l))
    r.badPlaceholders.forEach((l) => console.log('PLATZHALTER ' + l))
    process.exit(r.missing.length || r.badPlaceholders.length ? 1 : 0)
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main()
