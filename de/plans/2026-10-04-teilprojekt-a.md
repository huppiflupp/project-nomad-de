# Teilprojekt A: Fork und Übersetzung – Umsetzungsplan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eine installierbare, öffentlich veröffentlichte deutsche Fassung von Project NOMAD (Oberfläche, Anleitungen, Install-Skripte), die aus dem Fork `huppiflupp/project-nomad-de` installiert und aktualisiert wird.

**Architecture:** Englischer Text ist der Schlüssel. Ein Babel-Plugin ersetzt beim Vite-Build JSX-Texte, Text-Attribute und Text-Eigenschaften durch `__t("…")`. Ein Axios-Interceptor übersetzt Servermeldungen und Katalogtexte im Browser. Anleitungen liegen als zweite Fassung in `admin/docs-de/`. Alle Verweise auf Crosstalk-Repo/Images zeigen auf den Fork; eine Prüfung verhindert Rückfälle.

**Tech Stack:** AdonisJS 6, Inertia 2 + React 19, Vite 6, `@vitejs/plugin-react` 4.7 (Babel), Node 22, Tests mit `node:test` über `ts-node-maintained` (`npm run test:unit`), Docker/GHCR, Bash.

**Spec:** `de/specs/2026-10-04-teilprojekt-a-fork-und-uebersetzung.md` (inkl. **Nachtrag** am Ende – er geht vor).

## Global Constraints

- Anrede in allen deutschen Texten: **„Sie“** („Klicken Sie“, „Ihre Daten“), nie „du“.
- Sprachen `de` (Standard ohne Cookie, unabhängig von der Browsersprache) und `en`; Cookie **`nomad_lang`**, Werte `de`|`en`; Wechsel lädt die Seite neu.
- Fehlt eine Übersetzung, erscheint der englische Text – nie ein leerer String, nie ein Schlüsselname.
- Versionen reines SemVer, **Patch = 100 × Upstream-Patch + n**; erste Fassung `1.35.1` (Basis Upstream `1.35.0`).
- Repo `huppiflupp/project-nomad-de`, Images `ghcr.io/huppiflupp/project-nomad-de`, `…-de-sidecar-updater`, `…-de-disk-collector`, `…-de-translate`.
- Unverändert lassen: `Crosstalk-Solutions/project-nomad-maps`, `ghcr.io/crosstalk-solutions/nomad-sysbench`, alle Fremd-Images.
- Fork-Code in neuen Dateien (`admin/i18n/`, `admin/docs-de/`, `de/`); Eingriffe in Upstream-Dateien klein halten, Befehle/Logik in Skripten nie ändern, nur Texte.
- Name „Project NOMAD – Deutsche Fassung (inoffiziell)“, Verweis auf Crosstalk Solutions; Apache-2.0 bleibt.
- Auf ai395 nie `/opt/project-nomad` bzw. `/home/seeas/nomad` (pausiertes NOMAD) anfassen; keine Container namens `nomad_*` starten.
- Git-Identität im Repo: `huppiflupp <144213886+huppiflupp@users.noreply.github.com>`; Commit-Nachrichten enden mit `Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>`.
- Arbeit auf Zweig `de/teil-a`, Merge nach `main` erst in Task 16.

## Review Focus

1. **Übersetzter Text, der als Wert weiterverwendet wird** (z. B. `if (tab.label === 'Settings')`, ein `title`, der an die API geht): erwartet wird, dass die Funktion unverändert bleibt. → Test in Task 3 (Vergleich mit Literal wird nicht umgeschrieben) und Grep-Schritt in Task 15.
2. **Katalog-`name`, der als Kennung zurück an den Server geht**: Auswahl/Download muss auch auf Deutsch funktionieren. → Test in Task 5 (`slug`/`id`/`url` bleiben unangetastet) und Grep-Schritt in Task 5.
3. **Dynamische Servermeldungen mit Werten** („Deleted 3 files“, Dateinamen mit Sonderzeichen wie `a.b(1).zim`): müssen per Muster übersetzt werden, ohne dass Regex-Sonderzeichen stören. → Test in Task 2.
4. **Kaputtes oder fremdes Cookie** (`nomad_lang=fr`, mehrere Cookies, kein Cookie): erwartet wird Deutsch. → Test in Task 2.
5. **Anleitung fehlt auf Deutsch / Pfad-Tricks** (`../`, neue Upstream-Anleitung ohne Übersetzung): erwartet wird die englische Fassung bzw. Fehler wie bisher, nie Zugriff außerhalb. → Test in Task 8.

---

### Task 1: Spec und Plan veröffentlichen, Arbeitszweig

**Files:** keine Code-Dateien.

- [ ] **Step 1:** Zweig anlegen und Stand pushen.

```bash
cd ~/projects/project-nomad-de
git checkout -b de/teil-a
git add de/plans && git commit -m "docs(de): Umsetzungsplan Teilprojekt A

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
git push -u origin de/teil-a
```

- [ ] **Step 2:** Abhängigkeiten für die Entwicklung installieren und Ausgangslage messen.

```bash
cd admin && npm ci && npm run test:unit 2>&1 | tail -5 && npm run typecheck 2>&1 | tail -3
```
Expected: Tests grün (Zahl notieren in `de/STAND.md`, Abschnitt „Ausgangslage“); Typecheck ohne Fehler. Zusätzlich `npx tsc --noEmit -p inertia 2>&1 | grep -c "error TS"` – Zahl als Ausgangswert notieren (der Server-Typecheck schließt `inertia/` aus). Schlagen Upstream-Tests schon vorher fehl, die Namen in `de/STAND.md` notieren – sie gelten später nicht als Regression.

---

### Task 2: Übersetzungskern `admin/i18n/core.ts`

**Files:**
- Create: `admin/i18n/core.ts`
- Test: `admin/tests/unit/i18n_core.spec.ts`

**Interfaces:**
- Produces:
  - `type Lang = 'de' | 'en'`, `type Dict = Record<string, string>`
  - `normalize(s: string): string`
  - `parseLang(cookieHeader: string | null | undefined): Lang`
  - `compile(dict: Dict): Compiled`
  - `translate(c: Compiled | null, key: string, args?: unknown[]): string` – exakter Treffer, sonst Englisch; setzt `{n}` ein
  - `translateDynamic(c: Compiled | null, text: string): string` – exakt, dann Muster, sonst unverändert
  - `localizeData(data: unknown, fns: { message: (s: string) => string; catalog: (s: string) => string }): unknown`
  - Konstanten `LANG_COOKIE = 'nomad_lang'`, `MESSAGE_KEYS`, `CATALOG_KEYS`

- [ ] **Step 1: Failing test schreiben**

```ts
// admin/tests/unit/i18n_core.spec.ts
import * as assert from 'node:assert/strict'
import { test } from 'node:test'
import {
  compile, localizeData, normalize, parseLang, translate, translateDynamic,
} from '../../i18n/core.js'

const dict = compile({
  'Save changes': 'Änderungen speichern',
  'Deleted {0} files': '{0} Dateien gelöscht',
  'Moved {0} to {1}': '{0} nach {1} verschoben',
  'Downloading {0}': '{0} wird heruntergeladen',
  'Downloading {0} ({1}%)': '{0} wird heruntergeladen ({1} %)',
  'Medicine': 'Medizin',
  'Empty': '',
})

test('normalize collapses whitespace', () => {
  assert.equal(normalize('  Save\n   changes '), 'Save changes')
})

test('parseLang defaults to de for missing, foreign or broken cookies', () => {
  assert.equal(parseLang(undefined), 'de')
  assert.equal(parseLang(''), 'de')
  assert.equal(parseLang('nomad_lang=fr'), 'de')
  assert.equal(parseLang('nomad_lang='), 'de')
  assert.equal(parseLang('other=1; nomad_lang=en; x=2'), 'en')
  assert.equal(parseLang('nomad_lang=en'), 'en')
  assert.equal(parseLang('xnomad_lang=en'), 'de')
})

test('translate: exact hit, args, fallback to English, empty value ignored', () => {
  assert.equal(translate(dict, 'Save changes'), 'Änderungen speichern')
  assert.equal(translate(dict, 'Deleted {0} files', [3]), '3 Dateien gelöscht')
  assert.equal(translate(dict, 'Unknown {0}', ['x']), 'Unknown x')
  assert.equal(translate(dict, 'Empty'), 'Empty')
  assert.equal(translate(null, 'Deleted {0} files', [2]), 'Deleted 2 files')
})

test('translateDynamic matches patterns incl. regex characters and reordering', () => {
  assert.equal(translateDynamic(dict, 'Deleted 3 files'), '3 Dateien gelöscht')
  assert.equal(translateDynamic(dict, 'Moved a.b(1).zim to /x/[y]'), 'a.b(1).zim nach /x/[y] verschoben')
  assert.equal(translateDynamic(dict, 'Downloading w.zim (40%)'), 'w.zim wird heruntergeladen (40 %)')
  assert.equal(translateDynamic(dict, 'Nothing here'), 'Nothing here')
  assert.equal(translateDynamic(null, 'Deleted 3 files'), 'Deleted 3 files')
})

test('localizeData translates message and catalog fields, leaves ids alone', () => {
  const out = localizeData(
    { message: 'Deleted 2 files', items: [{ name: 'Medicine', slug: 'Medicine', id: 'Medicine', url: 'Medicine' }], count: 1 },
    { message: (s) => translateDynamic(dict, s), catalog: (s) => translateDynamic(dict, s) },
  ) as any
  assert.equal(out.message, '2 Dateien gelöscht')
  assert.equal(out.items[0].name, 'Medizin')
  assert.equal(out.items[0].slug, 'Medicine')
  assert.equal(out.items[0].id, 'Medicine')
  assert.equal(out.items[0].url, 'Medicine')
  assert.equal(out.count, 1)
})

test('localizeData survives cycles, null and deep nesting', () => {
  const a: any = { message: 'Deleted 1 files' }
  a.self = a
  const out = localizeData({ a, n: null, d: [[[[[[[[[[{ message: 'Deleted 9 files' }]]]]]]]]]] }, {
    message: (s) => translateDynamic(dict, s), catalog: (s) => s,
  }) as any
  assert.equal(out.a.message, '1 Dateien gelöscht')
  assert.equal(out.n, null)
})
```

- [ ] **Step 2: Test laufen lassen**

Run: `cd admin && node --import ts-node-maintained/register/esm --test tests/unit/i18n_core.spec.ts`
Expected: FAIL (`Cannot find module '../../i18n/core.js'`).

- [ ] **Step 3: Implementieren**

```ts
// admin/i18n/core.ts
// Shared translation core for the German distribution (huppiflupp/project-nomad-de).
// English source text is the key; see de/specs/2026-10-04-teilprojekt-a-fork-und-uebersetzung.md.

export type Lang = 'de' | 'en'
export type Dict = Record<string, string>

export const LANG_COOKIE = 'nomad_lang'

/** Response fields that carry server messages (translated with UI dictionary + patterns). */
export const MESSAGE_KEYS = new Set(['message', 'error', 'reason', 'detail', 'statusMessage'])
/** Response fields that carry catalog/service texts (translated only on exact catalog hit). */
export const CATALOG_KEYS = new Set([
  'name', 'title', 'description', 'tagline', 'subtitle', 'label', 'summary', 'friendly_name',
])

interface Pattern { re: RegExp; order: number[]; out: string; weight: number }
export interface Compiled { exact: Map<string, string>; patterns: Pattern[] }

export function normalize(s: string): string {
  return String(s).replace(/\s+/g, ' ').trim()
}

export function parseLang(cookieHeader: string | null | undefined): Lang {
  const m = /(?:^|;\s*)nomad_lang=(de|en)(?:;|$)/.exec(cookieHeader ?? '')
  return m ? (m[1] as Lang) : 'de'
}

function escapeRe(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

export function compile(dict: Dict): Compiled {
  const exact = new Map<string, string>()
  const patterns: Pattern[] = []
  for (const [rawKey, value] of Object.entries(dict)) {
    if (!value) continue
    const key = normalize(rawKey)
    exact.set(key, value)
    if (/\{\d+\}/.test(key)) {
      const order: number[] = []
      const src = key
        .split(/(\{\d+\})/)
        .map((part) => {
          const m = /^\{(\d+)\}$/.exec(part)
          if (!m) return escapeRe(part)
          order.push(Number(m[1]))
          return '([\\s\\S]+?)'
        })
        .join('')
      patterns.push({
        re: new RegExp(`^${src}$`),
        order,
        out: value,
        weight: key.replace(/\{\d+\}/g, '').length,
      })
    }
  }
  patterns.sort((a, b) => b.weight - a.weight)
  return { exact, patterns }
}

function format(template: string, args: unknown[]): string {
  return template.replace(/\{(\d+)\}/g, (all, i) => (Number(i) < args.length ? String(args[Number(i)]) : all))
}

export function translate(c: Compiled | null, key: string, args: unknown[] = []): string {
  const hit = c?.exact.get(normalize(key))
  return format(hit ?? key, args)
}

export function translateDynamic(c: Compiled | null, text: string): string {
  if (!c || typeof text !== 'string') return text
  const core = normalize(text)
  if (!core) return text
  const hit = c.exact.get(core)
  if (hit !== undefined) return hit
  for (const p of c.patterns) {
    const m = p.re.exec(core)
    if (!m) continue
    const values: string[] = []
    p.order.forEach((idx, j) => (values[idx] = m[j + 1]))
    return format(p.out, values)
  }
  return text
}

export function localizeData(
  data: unknown,
  fns: { message: (s: string) => string; catalog: (s: string) => string },
): unknown {
  const seen = new WeakSet<object>()
  const walk = (value: unknown, depth: number): unknown => {
    if (depth > 12 || value === null || typeof value !== 'object') return value
    if (seen.has(value as object)) return value
    seen.add(value as object)
    if (Array.isArray(value)) {
      for (let i = 0; i < value.length; i++) value[i] = walk(value[i], depth + 1)
      return value
    }
    const obj = value as Record<string, unknown>
    for (const [k, v] of Object.entries(obj)) {
      if (typeof v === 'string') {
        if (MESSAGE_KEYS.has(k)) obj[k] = fns.message(v)
        else if (CATALOG_KEYS.has(k)) obj[k] = fns.catalog(v)
      } else {
        obj[k] = walk(v, depth + 1)
      }
    }
    return obj
  }
  return walk(data, 0)
}
```

- [ ] **Step 4: Test grün**

Run: `cd admin && node --import ts-node-maintained/register/esm --test tests/unit/i18n_core.spec.ts`
Expected: PASS (6 Tests).

- [ ] **Step 5: Commit**

```bash
git add admin/i18n/core.ts admin/tests/unit/i18n_core.spec.ts
git commit -m "feat(i18n): Übersetzungskern mit Mustern und Cookie-Sprache

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
```

---

### Task 3: Babel-Plugin für die Oberfläche

**Files:**
- Create: `admin/i18n/text.mjs`, `admin/i18n/babel-plugin.mjs`
- Modify: `admin/package.json` (devDependency `@babel/core` explizit, Version wie in `node_modules/@babel/core/package.json`)
- Test: `admin/tests/unit/i18n_babel_plugin.spec.ts`

**Interfaces:**
- Consumes: nichts aus Task 2 (Plugin läuft zur Bauzeit, erzeugt nur Aufrufe).
- Produces:
  - Default-Export `nomadI18n(babel, opts)` mit Optionen `{ runtime?: string = '~/i18n/runtime', collect?: Set<string>, include?: RegExp = /\/inertia\//, exclude?: RegExp = /\/inertia\/i18n\// }`
  - Erzeugte Aufrufe: `__t("<englischer Schlüssel>", ...args)`, Import `import { __t } from '<runtime>'`
  - `TEXT_PROPS` (Set der übersetzten Attribut-/Eigenschaftsnamen)
  - aus `text.mjs`: `normalize(s)`, `looksHuman(s)`

- [ ] **Step 1: Failing test schreiben**

```ts
// admin/tests/unit/i18n_babel_plugin.spec.ts
import * as assert from 'node:assert/strict'
import { test } from 'node:test'
import { transformSync } from '@babel/core'
// @ts-ignore – plain ESM build helper
import plugin from '../../i18n/babel-plugin.mjs'

function run(code: string, filename = '/x/admin/inertia/pages/demo.tsx') {
  const collect = new Set<string>()
  const out = transformSync(code, {
    filename, babelrc: false, configFile: false,
    parserOpts: { plugins: ['jsx', 'typescript'] },
    plugins: [[plugin, { collect }]],
  })!.code!
  return { out, collect }
}

test('plain JSX text becomes __t call and import is added once', () => {
  const { out, collect } = run('export const A = () => <div><p>Save changes</p><p>Cancel</p></div>')
  assert.match(out, /import \{ __t \} from "~\/i18n\/runtime"/)
  assert.match(out, /\{__t\("Save changes"\)\}/)
  assert.deepEqual([...collect].sort(), ['Cancel', 'Save changes'])
})

test('text with expressions becomes one key with placeholders', () => {
  const { out } = run('const A = ({n, s}) => <p>Deleted {n} files from {s}</p>')
  assert.match(out, /__t\("Deleted \{0\} files from \{1\}", n, s\)/)
})

test('mixed element children keep edge spaces', () => {
  const { out } = run('const A = () => <p>Read the <a href="/docs">docs</a> first.</p>')
  assert.match(out, /__t\("Read the"\)\}\{" "\}/)
  assert.match(out, /__t\("docs"\)/)
  assert.match(out, /__t\("first\."\)/)
})

test('text attributes and conditional strings are wrapped, others not', () => {
  const { out } = run('const A = ({b}) => <input placeholder="Search files" className="Big Box" title={b ? "Open now" : "Closed today"} />')
  assert.match(out, /placeholder=\{__t\("Search files"\)\}/)
  assert.match(out, /className="Big Box"/)
  assert.match(out, /__t\("Open now"\)/)
  assert.match(out, /__t\("Closed today"\)/)
})

test('object text properties incl. template literals are wrapped', () => {
  const { out } = run('const f = (n) => addNotification({ message: `Deleted ${n} files`, type: "error" })')
  assert.match(out, /message: __t\("Deleted \{0\} files", n\)/)
  assert.match(out, /type: "error"/)
})

test('comparisons, code tags, non-human strings and files outside inertia stay untouched', () => {
  const { out } = run('const A = ({t}) => <div>{t.label === "Settings" ? 1 : 2}<code>Run this now</code><p>OK</p><p>v1.2</p></div>')
  assert.match(out, /t\.label === "Settings"/)
  assert.match(out, /<code>Run this now<\/code>/)
  assert.doesNotMatch(out, /__t\("v1\.2"\)/)
  const other = run('const A = () => <p>Save changes</p>', '/x/admin/app/foo.tsx')
  assert.doesNotMatch(other.out, /__t/)
})

test('runtime module itself is never rewritten', () => {
  const { out } = run('export const x = { label: "Deutsch" }', '/x/admin/inertia/i18n/runtime.ts')
  assert.doesNotMatch(out, /__t/)
})

test('explicit t() calls are collected', () => {
  const { collect } = run('import { t } from "~/i18n/runtime"; confirm(t("Really delete?"))')
  assert.ok(collect.has('Really delete?'))
})
```

- [ ] **Step 2: Test laufen lassen** – Run: `cd admin && node --import ts-node-maintained/register/esm --test tests/unit/i18n_babel_plugin.spec.ts` · Expected: FAIL (Modul fehlt).

- [ ] **Step 3: `text.mjs` schreiben** (Regeln aus dem alten `extract.js`, damit das Wörterbuch von 2026-09-18 passt)

```js
// admin/i18n/text.mjs
// Shared by the Babel plugin and the i18n CLI. Mirrors normalize() in core.ts.
export function normalize(s) {
  return String(s).replace(/\s+/g, ' ').trim()
}

/** True for strings a person reads; false for class names, slugs, identifiers, URLs, code. */
export function looksHuman(s) {
  if (s.length < 2 || !/[A-Za-z]{2}/.test(s)) return false
  if (/^(https?:|\/|\.\/|#|@|[a-z0-9_.-]+\/[a-z0-9_./-]*$)/i.test(s)) return false
  if (/^[a-z0-9_:.\-[\]/!%]+( [a-z0-9_:.\-[\]/!%()]+)*$/.test(s) && /[-:]/.test(s)) return false
  if (/^[a-z][a-zA-Z0-9_.]*$/.test(s)) return false
  if (/^[A-Z0-9_]+$/.test(s)) return false
  if (/^Icon[A-Z]\w+$/.test(s)) return false
  if (/^[a-z0-9-]+$/.test(s)) return false
  if (/^\w+\/[\w.+-]+$/.test(s)) return false
  if (/[{};]\s*$/.test(s) && /[=(]/.test(s)) return false
  if (/^v?\d+(\.\d+)*$/.test(s)) return false
  return /[A-Z]/.test(s[0]) || / /.test(s) || /[.!?:]$/.test(s)
}
```

Hinweis zum Test „OK“: `looksHuman('OK')` ist `false` (`^[A-Z0-9_]+$`) – gewollt, „OK“ bleibt „OK“.

- [ ] **Step 4: `babel-plugin.mjs` schreiben**

```js
// admin/i18n/babel-plugin.mjs
// Build-time i18n for the German distribution: rewrites user-visible English text in
// inertia/ files into __t("English text", ...args). English text is the dictionary key.
import { looksHuman, normalize } from './text.mjs'

export const TEXT_PROPS = new Set([
  'placeholder', 'title', 'aria-label', 'alt', 'label', 'description', 'helperText', 'tooltip',
  'subtitle', 'message', 'confirmText', 'cancelText', 'emptyMessage', 'heading', 'buttonText',
])
const SKIP_TAGS = new Set(['code', 'pre', 'kbd', 'samp', 'script', 'style', 'svg'])
const T = '__t'
const MARK = Symbol('nomadI18n')

export default function nomadI18n({ types: t }, opts = {}) {
  const runtime = opts.runtime ?? '~/i18n/runtime'
  const include = opts.include ?? /\/inertia\//
  const exclude = opts.exclude ?? /\/inertia\/i18n\//
  const collect = opts.collect

  const active = (state) => {
    const f = (state.filename ?? '').replace(/\\/g, '/')
    return include.test(f) && !exclude.test(f)
  }
  const human = (key) => /[A-Za-z]/.test(key) && looksHuman(normalize(key.replace(/\{\d+\}/g, ' ')))

  function mk(key, args, state) {
    state.nomadI18nUsed = true
    collect?.add(key)
    const node = t.callExpression(t.identifier(T), [t.stringLiteral(key), ...args])
    node[MARK] = true
    return node
  }

  function templateKey(tpl) {
    let key = ''
    tpl.quasis.forEach((q, i) => {
      key += q.value.cooked ?? q.value.raw
      if (i < tpl.expressions.length) key += `{${i}}`
    })
    return normalize(key)
  }

  // Returns a replacement node, or null (conditionals/logicals are patched in place).
  function wrapExpr(node, state) {
    if (!node || node[MARK]) return null
    if (t.isStringLiteral(node)) {
      const key = normalize(node.value)
      return human(key) ? mk(key, [], state) : null
    }
    if (t.isTemplateLiteral(node)) {
      const key = templateKey(node)
      if (!human(key)) return null
      return mk(key, node.expressions.map((e) => wrapExpr(e, state) ?? e), state)
    }
    if (t.isConditionalExpression(node)) {
      node.consequent = wrapExpr(node.consequent, state) ?? node.consequent
      node.alternate = wrapExpr(node.alternate, state) ?? node.alternate
      return null
    }
    if (t.isLogicalExpression(node)) {
      // &&, || and ??: only the right-hand side can be display text
      node.right = wrapExpr(node.right, state) ?? node.right
      return null
    }
    return null
  }

  function edge(raw, which) {
    const m = which === 'lead' ? /^\s*/.exec(raw)[0] : /\s*$/.exec(raw)[0]
    return m && !m.includes('\n') ? ' ' : ''
  }

  function handleChildren(path, state) {
    const kids = path.node.children
    const inline = kids.every((c) => t.isJSXText(c) || t.isJSXExpressionContainer(c))
    if (inline && kids.some((c) => t.isJSXExpressionContainer(c) && !t.isJSXEmptyExpression(c.expression))) {
      let key = ''
      let hasText = false
      const args = []
      for (const c of kids) {
        if (t.isJSXText(c)) {
          key += c.value
          if (c.value.trim()) hasText = true
        } else if (t.isJSXEmptyExpression(c.expression)) {
          continue
        } else if (t.isStringLiteral(c.expression)) {
          key += c.expression.value
          hasText = true
        } else {
          key += `{${args.length}}`
          args.push(c.expression)
        }
      }
      key = normalize(key)
      if (hasText && human(key)) {
        const wrapped = args.map((a) => wrapExpr(a, state) ?? a)
        path.node.children = [t.jsxExpressionContainer(mk(key, wrapped, state))]
        return
      }
    }
    const out = []
    for (const c of kids) {
      if (t.isJSXText(c)) {
        const key = normalize(c.value)
        if (key && human(key)) {
          const lead = edge(c.value, 'lead')
          const trail = edge(c.value, 'trail')
          if (lead) out.push(t.jsxExpressionContainer(t.stringLiteral(lead)))
          out.push(t.jsxExpressionContainer(mk(key, [], state)))
          if (trail) out.push(t.jsxExpressionContainer(t.stringLiteral(trail)))
          continue
        }
      } else if (t.isJSXExpressionContainer(c)) {
        const r = wrapExpr(c.expression, state)
        if (r) {
          out.push(t.jsxExpressionContainer(r))
          continue
        }
      }
      out.push(c)
    }
    path.node.children = out
  }

  return {
    name: 'nomad-i18n',
    visitor: {
      Program: {
        exit(path, state) {
          if (!state.nomadI18nUsed || path.scope.hasBinding(T)) return
          path.unshiftContainer(
            'body',
            t.importDeclaration([t.importSpecifier(t.identifier(T), t.identifier(T))], t.stringLiteral(runtime)),
          )
        },
      },
      JSXElement(path, state) {
        if (!active(state)) return
        const name = path.node.openingElement.name
        if (t.isJSXIdentifier(name) && SKIP_TAGS.has(name.name)) {
          path.skip()
          return
        }
        handleChildren(path, state)
      },
      JSXFragment(path, state) {
        if (active(state)) handleChildren(path, state)
      },
      JSXAttribute(path, state) {
        if (!active(state)) return
        const n = path.node.name
        const attr = t.isJSXNamespacedName(n) ? `${n.namespace.name}:${n.name.name}` : n.name
        if (!TEXT_PROPS.has(attr)) return
        const v = path.node.value
        if (t.isStringLiteral(v)) {
          const r = wrapExpr(v, state)
          if (r) path.node.value = t.jsxExpressionContainer(r)
        } else if (t.isJSXExpressionContainer(v)) {
          const r = wrapExpr(v.expression, state)
          if (r) v.expression = r
        }
      },
      ObjectProperty(path, state) {
        if (!active(state) || path.node.computed) return
        const k = path.node.key
        const name = t.isIdentifier(k) ? k.name : t.isStringLiteral(k) ? k.value : null
        if (!name || !TEXT_PROPS.has(name)) return
        const r = wrapExpr(path.node.value, state)
        if (r) path.node.value = r
      },
      CallExpression(path, state) {
        if (!collect || !active(state)) return
        const c = path.node.callee
        const a = path.node.arguments[0]
        if (t.isIdentifier(c) && (c.name === 't' || c.name === T) && t.isStringLiteral(a)) {
          collect.add(normalize(a.value))
        }
      },
    },
  }
}
```

Kanten-Leerzeichen bei gemischten Kindern werden als `{" "}` ausgegeben (nicht als JSXText), weil Babel einzelne Leerzeichen-JSXText sonst beim Ausgeben verlieren kann.

- [ ] **Step 5: `@babel/core` als devDependency eintragen**

```bash
cd admin && v=$(node -p "require('@babel/core/package.json').version") && npm i -D --save-exact @babel/core@$v
```

- [ ] **Step 6: Test grün** – Run wie Step 2 · Expected: PASS (8 Tests).

- [ ] **Step 7: Commit**

```bash
git add admin/i18n/text.mjs admin/i18n/babel-plugin.mjs admin/tests/unit/i18n_babel_plugin.spec.ts admin/package.json admin/package-lock.json
git commit -m "feat(i18n): Babel-Plugin übersetzt Oberflächentexte zur Bauzeit

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
```

---

### Task 4: Laufzeit, Vite-Einbindung, Sprachumschalter

**Files:**
- Create: `admin/inertia/i18n/runtime.ts`, `admin/inertia/i18n/LanguageSwitch.tsx`, `admin/i18n/de.json` (vorerst `{}`), `admin/i18n/catalog.de.json` (vorerst `{}`)
- Modify: `admin/vite.config.ts` (Plugin einhängen), `admin/inertia/components/Footer.tsx` (Umschalter + Hinweis „inoffiziell“)

**Interfaces:**
- Consumes: `compile`, `translate`, `translateDynamic`, `parseLang`, `localizeData`, `LANG_COOKIE`, `Lang` aus `admin/i18n/core.ts`.
- Produces (aus `~/i18n/runtime`): `__t(key, ...args): string`, `t` (gleich `__t`), `tm(text): string` (Servermeldung), `tc(text): string` (Katalog), `localize<T>(data: T): T`, `getLang(): Lang`, `setLang(l: Lang): void`.

- [ ] **Step 1: Laufzeit schreiben**

```ts
// admin/inertia/i18n/runtime.ts
// Browser side of the German distribution's i18n. Language is read once from the
// nomad_lang cookie; switching reloads the page (see setLang).
import de from '../../i18n/de.json'
import catalogDe from '../../i18n/catalog.de.json'
import {
  compile, localizeData, parseLang, translate, translateDynamic, LANG_COOKIE, type Lang,
} from '../../i18n/core'

const lang: Lang = typeof document === 'undefined' ? 'de' : parseLang(document.cookie)
const ui = lang === 'de' ? compile(de as Record<string, string>) : null
const catalog = lang === 'de' ? compile(catalogDe as Record<string, string>) : null

if (typeof document !== 'undefined') document.documentElement.lang = lang

export function getLang(): Lang {
  return lang
}

export function __t(key: string, ...args: unknown[]): string {
  return translate(ui, key, args)
}
export const t = __t

/** Server message (may contain values): exact match, then {n} patterns. */
export function tm(text: string): string {
  return translateDynamic(ui, text)
}

/** Catalog/service text: exact match in the catalog dictionary, then UI dictionary. */
export function tc(text: string): string {
  const c = translateDynamic(catalog, text)
  return c !== text ? c : translateDynamic(ui, text)
}

export function localize<T>(data: T): T {
  if (lang === 'en') return data
  return localizeData(data, { message: tm, catalog: tc }) as T
}

export function setLang(next: Lang): void {
  document.cookie = `${LANG_COOKIE}=${next}; path=/; max-age=31536000; SameSite=Lax`
  window.location.reload()
}
```

- [ ] **Step 2: Vite einhängen** – in `admin/vite.config.ts` den Import ergänzen und `react()` ersetzen:

```ts
import nomadI18n from './i18n/babel-plugin.mjs'
// …
plugins: [inertia({ ssr: { enabled: false } }), react({ babel: { plugins: [[nomadI18n, { runtime: '~/i18n/runtime' }]] } }), tailwindcss(), adonisjs({ entrypoints: ['inertia/app/app.tsx'], reload: ['resources/views/**/*.edge'] })],
```

- [ ] **Step 3: Umschalter schreiben**

```tsx
// admin/inertia/i18n/LanguageSwitch.tsx
import { getLang, setLang } from './runtime'

export default function LanguageSwitch() {
  const lang = getLang()
  const other = lang === 'de' ? 'en' : 'de'
  return (
    <button
      onClick={() => setLang(other)}
      className="text-sm/6 text-gray-500 hover:text-desert-green cursor-pointer"
      title={lang === 'de' ? 'Switch to English' : 'Auf Deutsch umschalten'}
    >
      {lang === 'de' ? 'English' : 'Deutsch'}
    </button>
  )
}
```

(Die Datei liegt unter `inertia/i18n/` und wird vom Plugin nicht umgeschrieben – die Beschriftungen sind absichtlich in der jeweils anderen Sprache.)

- [ ] **Step 4: Footer** – in `admin/inertia/components/Footer.tsx` nach `<ThemeToggle />` einfügen:

```tsx
        <span className="text-gray-300">|</span>
        <LanguageSwitch />
```
mit `import LanguageSwitch from '~/i18n/LanguageSwitch'`, und unter der bestehenden Zeile (`Project NOMAD&trade; Command Center v{appVersion}`) einen zweiten `<p>`:

```tsx
      <p className="pb-3 text-center text-xs text-text-secondary">
        Unofficial German edition of{' '}
        <a className="underline" href="https://github.com/Crosstalk-Solutions/project-nomad">Project NOMAD</a>{' '}
        by Crosstalk Solutions · <a className="underline" href="https://github.com/huppiflupp/project-nomad-de">huppiflupp/project-nomad-de</a>
      </p>
```
(Text englisch – das Plugin übersetzt ihn; der Eintrag kommt in Task 7 ins Wörterbuch.)

- [ ] **Step 5: Bau prüfen**

Run: `cd admin && npm run typecheck && npx tsc --noEmit -p inertia 2>&1 | tail -5 && npx vite build --logLevel warn 2>&1 | tail -5 && grep -l 'Back to Home' public/assets/*.js | head -1`
Expected: beide Typechecks ohne **neue** Fehler gegenüber der Ausgangslage (Task 1 Step 2 – dort `npx tsc --noEmit -p inertia` ebenfalls einmal laufen lassen und die Fehlerzahl notieren); Build ok; eine Asset-Datei enthält „Back to Home“. Lehnt `tsc -p inertia` den JSON-Import ab: `"resolveJsonModule": true` in `admin/inertia/tsconfig.json` ergänzen. Lehnt `vite.config.ts` den `.mjs`-Import ab: `admin/i18n/babel-plugin.d.mts` mit `declare const p: any; export default p` anlegen.

- [ ] **Step 6: Commit**

```bash
git add admin/inertia/i18n admin/i18n/de.json admin/i18n/catalog.de.json admin/vite.config.ts admin/inertia/components/Footer.tsx admin/i18n/*.d.mts 2>/dev/null
git commit -m "feat(i18n): Laufzeit, Vite-Einbindung und Sprachumschalter

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
```

---

### Task 5: Servermeldungen und Katalogtexte im Browser übersetzen

**Files:**
- Modify: `admin/inertia/lib/api.ts` (Interceptor im Konstruktor), `admin/inertia/app/app.tsx` (Anfangs-Props in `setup`)

**Interfaces:**
- Consumes: `localize` aus `~/i18n/runtime` (Task 4).

- [ ] **Step 1: Interceptor** – in `admin/inertia/lib/api.ts` nach `axios.create({...})` im Konstruktor:

```ts
    // German distribution: translate server messages and catalog texts (admin/i18n).
    this.client.interceptors.response.use(
      (response) => {
        response.data = localize(response.data)
        return response
      },
      (error) => {
        if (error?.response?.data) error.response.data = localize(error.response.data)
        return Promise.reject(error)
      },
    )
```
und oben `import { localize } from '~/i18n/runtime'`.

- [ ] **Step 2: Anfangs-Props** – in `admin/inertia/app/app.tsx`, erste Zeile im `setup({ el, App, props })`-Körper:

```ts
    props.initialPage.props = localize(props.initialPage.props)
```
mit `import { localize } from '~/i18n/runtime'`.

- [ ] **Step 3: Review-Focus 2 prüfen – werden Katalognamen als Kennung zurückgeschickt?**

Run: `cd admin && grep -rnE "\.(name|title|label)\b" inertia --include=*.tsx --include=*.ts | grep -E "api\.|post\(|put\(|delete\(|params|body" | head -40`
Für jeden Treffer, bei dem ein Feld aus `CATALOG_KEYS` (`name`, `title`, `label` …) als Wert an die API zurückgeht: Upstream-Logik nicht umbauen, sondern diese eine Antwort von der Übersetzung ausnehmen – den betreffenden Aufruf in `api.ts` mit `{ skipLocalize: true }` als Axios-Config versehen und im Interceptor als erste Zeile `if ((response.config as any)?.skipLocalize) return response` ergänzen; die Anzeige an dieser Stelle dann mit `tc(…)` übersetzen. Ergebnis der Prüfung in `de/STAND.md` notieren („keine Treffer“ ist ein gültiges Ergebnis).

- [ ] **Step 4: Bau + Unit-Tests**

Run: `cd admin && npm run typecheck && npx vite build --logLevel warn && npm run test:unit 2>&1 | tail -3`
Expected: alles grün.

- [ ] **Step 5: Commit** – `git add admin/inertia/lib/api.ts admin/inertia/app/app.tsx de/STAND.md && git commit -m "feat(i18n): Servermeldungen und Katalogtexte im Browser übersetzen" -m "Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"`

---

### Task 6: Werkzeug `extract`/`check`

**Files:**
- Create: `admin/i18n/cli.mjs`
- Test: `admin/tests/unit/i18n_cli.spec.ts`

**Interfaces:**
- Consumes: Plugin (Task 3) im `collect`-Modus, `normalize`/`looksHuman` aus `text.mjs`.
- Produces: `collectUi(root): Map<key,file>`, `collectServer(root): Map<key,file>`, `collectCatalog(root): Map<key,file>`, `checkDicts({ui, server, catalog, de, cat}): { missing: string[], badPlaceholders: string[], orphans: string[] }`; CLI `node i18n/cli.mjs check|extract [--missing <datei>]` (Aufruf aus `admin/`), Exit 1 bei fehlenden Einträgen oder Platzhalter-Fehlern.

- [ ] **Step 1: Failing test**

```ts
// admin/tests/unit/i18n_cli.spec.ts
import * as assert from 'node:assert/strict'
import { test } from 'node:test'
// @ts-ignore
import { checkDicts } from '../../i18n/cli.mjs'

test('checkDicts reports missing keys, placeholder mismatches and orphans', () => {
  const r = checkDicts({
    ui: new Map([['Save', 'a.tsx'], ['Deleted {0} files', 'b.tsx']]),
    server: new Map([['Not found', 'c.ts']]),
    catalog: new Map([['Medicine', 'collections/x.json']]),
    de: { 'Save': 'Speichern', 'Deleted {0} files': 'Dateien gelöscht', 'Old text': 'Alt' },
    cat: {},
  })
  assert.deepEqual(r.missing.sort(), ['c.ts: Not found', 'collections/x.json: Medicine'])
  assert.deepEqual(r.badPlaceholders, ['Deleted {0} files -> Dateien gelöscht'])
  assert.deepEqual(r.orphans, ['Old text'])
})
```

- [ ] **Step 2:** Run `cd admin && node --import ts-node-maintained/register/esm --test tests/unit/i18n_cli.spec.ts` · Expected: FAIL.

- [ ] **Step 3: Implementieren**

```js
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

const parse = (code, filename) =>
  babel.parseSync(code, { filename, babelrc: false, configFile: false, parserOpts: { plugins: ['jsx', 'typescript', 'decorators-legacy'] } })

function tplKey(node) {
  let s = ''
  node.quasis.forEach((q, i) => { s += q.value.cooked ?? q.value.raw; if (i < node.expressions.length) s += `{${i}}` })
  return normalize(s)
}
const strValue = (n) =>
  n?.type === 'StringLiteral' ? normalize(n.value) : n?.type === 'TemplateLiteral' ? tplKey(n) : null
const keep = (k) => k && /[A-Za-z]/.test(k) && looksHuman(normalize(k.replace(/\{\d+\}/g, ' ')))

export function collectUi(root) {
  const keys = new Map()
  for (const file of walk(join(root, 'inertia'), /\.(tsx|ts)$/)) {
    const seen = new Set()
    babel.transformSync(readFileSync(file, 'utf8'), {
      filename: file, babelrc: false, configFile: false, code: false,
      parserOpts: { plugins: ['jsx', 'typescript'] }, plugins: [[plugin, { collect: seen }]],
    })
    for (const k of seen) if (!keys.has(k)) keys.set(k, relative(root, file))
  }
  return keys
}

export function collectServer(root) {
  const keys = new Map()
  for (const dir of SERVER_DIRS) {
    for (const file of walk(join(root, dir), /\.ts$/)) {
      const ast = parse(readFileSync(file, 'utf8'), file)
      babel.traverse(ast, {
        ObjectProperty(p) {
          const k = p.node.key
          const name = k.type === 'Identifier' ? k.name : k.type === 'StringLiteral' ? k.value : null
          if (!SERVER_PROPS.has(name)) return
          const v = strValue(p.node.value)
          if (keep(v) && !keys.has(v)) keys.set(v, relative(root, file))
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
  for (const [k, f] of catalog) if (!catN.get(k) && !deN.get(k)) missing.push(`${f}: ${k}`)
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
```

- [ ] **Step 4:** Test grün (Run wie Step 2), dann echter Lauf: `cd admin && node i18n/cli.mjs check | head -3` · Expected: Zeile „Oberfläche N, Server M, Kataloge K Texte“, Exit 1 (Wörterbuch noch leer). Zahlen in `de/STAND.md` notieren.

- [ ] **Step 5: Commit** – `git add admin/i18n/cli.mjs admin/tests/unit/i18n_cli.spec.ts de/STAND.md && git commit -m "feat(i18n): extract/check für fehlende Übersetzungen" -m "Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"`

---

### Task 7: Wörterbücher füllen (Sie-Form)

**Files:**
- Modify: `admin/i18n/de.json`, `admin/i18n/catalog.de.json`
- Create: `de/tools/sie-check.mjs`

- [ ] **Step 1: Prüfskript für die Anrede**

```js
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
```

- [ ] **Step 2: Altbestand übernehmen und umstellen.** `~/src/project-nomad-fedora/i18n/de.json` (2.110 Einträge, du-Form) in Teile zu je ~300 Einträgen zerlegen; jeden Teil mit dieser Anweisung umstellen lassen (Unteragent oder von Hand): *„Stelle jeden Wert von ‚du‘ auf ‚Sie‘ um (Imperativ ‚Klicke‘→‚Klicken Sie‘, ‚deine‘→‚Ihre‘, ‚kannst du‘→‚können Sie‘). Schlüssel, Platzhalter `{0}`, HTML-Entities und Fachbegriffe unverändert. Gib nur JSON zurück.“* Nur Einträge übernehmen, deren Schlüssel `check` als benötigt meldet (verwaiste weglassen). Ergebnis nach `admin/i18n/de.json` (Schlüssel alphabetisch, `JSON.stringify(obj, null, 1)`).

- [ ] **Step 3: Lücken füllen.** `cd admin && node i18n/cli.mjs extract --missing ../de/tmp-missing.json`, in Teilen übersetzen (gleiche Regeln, Sie-Form, Platzhalter erhalten, Produktnamen wie Kiwix/Ollama/Qdrant/CyberChef/Kolibri/Supply Depot nicht übersetzen; „Knowledge Base“→„Wissensdatenbank“, „Easy Setup“→„Schnellstart“, „Command Center“→„Kommandozentrale“, „Supply Depot“ bleibt). Katalogtexte (Herkunft `collections/…` oder `service_seeder.ts`) gehören in `catalog.de.json`, alles andere in `de.json`. `de/tmp-missing.json` danach löschen (nicht committen).

- [ ] **Step 4: Prüfen**

Run: `cd admin && node i18n/cli.mjs check && node ../de/tools/sie-check.mjs i18n/de.json i18n/catalog.de.json`
Expected: `fehlend 0, Platzhalter-Fehler 0`, Exit 0; `du-Formen: 0`.

- [ ] **Step 5: Stichprobe von Hand:** 40 zufällige Einträge ansehen (`node -e "const d=require('./i18n/de.json');const k=Object.keys(d);for(let i=0;i<40;i++){const x=k[Math.floor(Math.random()*k.length)];console.log(x,'=>',d[x])}"`), Auffälliges korrigieren.

- [ ] **Step 6: Commit** – `git add admin/i18n/*.json de/tools/sie-check.mjs && git commit -m "feat(i18n): deutsches Wörterbuch (Sie-Form) für Oberfläche, Server und Kataloge" -m "Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"`

---

### Task 8: Anleitungen sprachabhängig ausliefern

**Files:**
- Modify: `admin/app/services/docs_service.ts`, `admin/app/controllers/docs_controller.ts`, `admin/app/services/rag_service.ts:2063-2068` (`_nomadDocsRoots`), `Dockerfile` (eine `COPY`-Zeile), `admin/inertia/layouts/DocsLayout.tsx` (nur falls Titel dort nicht über Props/API kommen – siehe Step 5)
- Create: `admin/docs-de/.gitkeep`
- Test: `admin/tests/unit/i18n_docs_service.spec.ts`

**Interfaces:**
- Consumes: `parseLang`, `Lang` aus `admin/i18n/core.ts`.
- Produces: `DocsService` mit `constructor(baseDir = process.cwd())`, `getDocs(lang: Lang = 'en')`, `parseFile(slug: string, lang: Lang = 'en')`, `resolveDocPath(slug: string, lang: Lang): Promise<string>` (wirft bei Traversal/fehlender Datei).

- [ ] **Step 1: Failing test**

```ts
// admin/tests/unit/i18n_docs_service.spec.ts
import * as assert from 'node:assert/strict'
import { test } from 'node:test'
import { mkdtempSync, mkdirSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'
import { tmpdir } from 'node:os'
import { DocsService } from '../../app/services/docs_service.js'

function fixture() {
  const dir = mkdtempSync(join(tmpdir(), 'docs-'))
  mkdirSync(join(dir, 'docs')); mkdirSync(join(dir, 'docs-de'))
  writeFileSync(join(dir, 'docs', 'home.md'), '# Home\n')
  writeFileSync(join(dir, 'docs', 'faq.md'), '# FAQ\n')
  writeFileSync(join(dir, 'docs', 'new-upstream.md'), '# New\n')
  writeFileSync(join(dir, 'docs-de', 'home.md'), '# Startseite\n')
  writeFileSync(join(dir, 'docs-de', 'faq.md'), '# Häufige Fragen\n')
  return new DocsService(dir)
}

test('German doc is used when present, English otherwise', async () => {
  const s = fixture()
  assert.match(await s.resolveDocPath('home', 'de'), /docs-de\/home\.md$/)
  assert.match(await s.resolveDocPath('new-upstream', 'de'), /docs\/new-upstream\.md$/)
  assert.match(await s.resolveDocPath('home', 'en'), /docs\/home\.md$/)
})

test('traversal and unknown slugs are rejected in both languages', async () => {
  const s = fixture()
  await assert.rejects(s.resolveDocPath('../docs/home', 'de'))
  await assert.rejects(s.resolveDocPath('../../etc/passwd', 'en'))
  await assert.rejects(s.resolveDocPath('missing', 'de'))
})

test('German list keeps English slugs and order, takes titles from the German heading', async () => {
  const s = fixture()
  const de = await s.getDocs('de')
  assert.deepEqual(de.map((d) => d.slug), ['home', 'faq', 'new-upstream'])
  assert.deepEqual(de.map((d) => d.title).slice(0, 2), ['Startseite', 'Häufige Fragen'])
  const en = await s.getDocs('en')
  assert.equal(en.find((d) => d.slug === 'faq')!.title, 'FAQ')
})
```

- [ ] **Step 2:** Run `cd admin && node --import ts-node-maintained/register/esm --test tests/unit/i18n_docs_service.spec.ts` · Expected: FAIL (`resolveDocPath` fehlt / Konstruktor ohne Argument).

- [ ] **Step 3: `DocsService` umbauen** (bestehende Methoden `parse`, `prettify`, `getConfig`, `DOC_ORDER`, `TITLE_OVERRIDES` bleiben unverändert):

```ts
import type { Lang } from '../../i18n/core.js'
import { readFile } from 'node:fs/promises'

export class DocsService {
  private docsPath: string
  private docsDePath: string

  constructor(baseDir: string = process.cwd()) {
    this.docsPath = path.join(baseDir, 'docs')
    this.docsDePath = path.join(baseDir, 'docs-de')
  }

  // … DOC_ORDER unverändert …

  async getDocs(lang: Lang = 'en') {
    const contents = await listDirectoryContentsRecursive(this.docsPath)
    const files: Array<{ title: string; slug: string }> = []
    for (const item of contents) {
      if (item.type === 'file' && item.name.endsWith('.md')) {
        const slug = item.name.replace(/\.md$/, '')
        files.push({ title: (lang === 'de' && (await this.germanTitle(slug))) || this.prettify(item.name), slug })
      }
    }
    return files.sort((a, b) => (DocsService.DOC_ORDER[a.slug] ?? 999) - (DocsService.DOC_ORDER[b.slug] ?? 999))
  }

  private async germanTitle(slug: string): Promise<string | null> {
    try {
      const md = await readFile(path.join(this.docsDePath, `${slug}.md`), 'utf8')
      return /^#\s+(.+)$/m.exec(md)?.[1].trim() ?? null
    } catch {
      return null
    }
  }

  async resolveDocPath(slug: string, lang: Lang): Promise<string> {
    if (!slug) throw new Error('Filename is required')
    const filename = slug.endsWith('.md') ? slug : `${slug}.md`
    const roots = lang === 'de' ? [this.docsDePath, this.docsPath] : [this.docsPath]
    for (const root of roots) {
      const base = path.resolve(root)
      const full = path.resolve(path.join(root, filename))
      // Prevent path traversal — resolved path must stay within the docs directory
      if (!full.startsWith(base + path.sep)) throw new Error('Invalid document slug')
      if (await getFileStatsIfExists(full)) return full
    }
    throw new Error(`File not found: ${filename}`)
  }

  async parseFile(_filename: string, lang: Lang = 'en') {
    try {
      const fullPath = await this.resolveDocPath(_filename, lang)
      const fileStream = await getFile(fullPath, 'stream')
      if (!fileStream) throw new Error(`Failed to read file stream: ${_filename}`)
      return this.parse(await streamToString(fileStream))
    } catch (error) {
      throw new InternalServerErrorException(`Error parsing file: ${(error as Error).message}`)
    }
  }
```
Hinweis: `listDirectoryContentsRecursive(this.docsPath)` liest nur `docs/`; `docs-de/` ist ein Geschwisterordner und wird nicht mitgelistet. Prüfen, ob `getDocs` rekursiv Unterordner von `docs/` mitzählt (heute keine vorhanden) – unverändert lassen.
Falls `DocsService` per `@inject()` mit Konstruktor-Argument Probleme macht (Adonis-Container versucht `baseDir` aufzulösen): Parameter-Default reicht nicht → statische Fabrik `static forBase(dir)` für den Test und parameterloser Konstruktor; Test entsprechend anpassen.

- [ ] **Step 4: Controller** (`admin/app/controllers/docs_controller.ts`):

```ts
import { parseLang } from '../../i18n/core.js'
// …
    async list({ request }: HttpContext) {
        return await this.docsService.getDocs(parseLang(request.header('cookie')));
    }

    async show({ params, inertia, request }: HttpContext) {
        const content = await this.docsService.parseFile(params.slug, parseLang(request.header('cookie')));
        return inertia.render('docs/show', {
            content,
        });
    }
```
Andere Aufrufer von `getDocs`/`parseFile` suchen (`grep -rn "getDocs\|parseFile" admin/app admin/start`) und ihnen ebenfalls die Sprache übergeben.

- [ ] **Step 5: Wissensdatenbank und Image**
  - `rag_service.ts` `_nomadDocsRoots`: `docsDir: existsSync(join(process.cwd(), 'docs-de')) ? join(process.cwd(), 'docs-de') : join(process.cwd(), 'docs')` (Import `existsSync` aus `node:fs`). Kommentar: `// German distribution: embed the German docs.`
  - `Dockerfile`: nach `COPY admin/docs /app/docs` die Zeile `COPY admin/docs-de /app/docs-de`.
  - `admin/docs-de/.gitkeep` anlegen.
  - DocsLayout: prüfen, woher die Seitenliste kommt (`grep -n "docs" admin/inertia/layouts/DocsLayout.tsx`). Kommt sie über `/api/docs/list`, liefert der Server schon deutsche Titel – nichts tun.

- [ ] **Step 6:** Tests grün: `cd admin && node --import ts-node-maintained/register/esm --test tests/unit/i18n_docs_service.spec.ts && npm run test:unit 2>&1 | tail -3 && npm run typecheck`

- [ ] **Step 7: Commit** – `git add -A admin/app/services/docs_service.ts admin/app/controllers/docs_controller.ts admin/app/services/rag_service.ts Dockerfile admin/docs-de admin/tests/unit/i18n_docs_service.spec.ts && git commit -m "feat(docs): deutsche Anleitungen aus docs-de mit Rückfall auf Englisch" -m "Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"`

---

### Task 9: Die 11 Anleitungen übersetzen

**Files:**
- Create: `admin/docs-de/{about,api-reference,community-add-ons,drug-reference,faq,getting-started,home,release-notes,supply-depot-apps,updates,use-cases}.md`, `de/tools/docs-check.mjs`

- [ ] **Step 1: Strukturprüfung schreiben**

```js
// de/tools/docs-check.mjs – vergleicht admin/docs/X.md mit admin/docs-de/X.md
import { readFileSync, readdirSync, existsSync } from 'node:fs'
const en = 'admin/docs', de = 'admin/docs-de'
const count = (s, re) => (s.match(re) || []).length
const codeBlocks = (s) => s.match(/```[\s\S]*?```/g) || []
const links = (s) => [...s.matchAll(/\]\(([^)]+)\)/g)].map((m) => m[1]).sort()
const tags = (s) => (s.match(/\{%[^%]*%\}/g) || []).map((x) => x.replace(/"[^"]*"/g, '""')).sort()
let bad = 0
for (const f of readdirSync(en).filter((f) => f.endsWith('.md'))) {
  if (!existsSync(`${de}/${f}`)) { console.log(`FEHLT ${f}`); bad++; continue }
  const a = readFileSync(`${en}/${f}`, 'utf8'), b = readFileSync(`${de}/${f}`, 'utf8')
  const checks = [
    ['Überschriften', count(a, /^#{1,6} /gm), count(b, /^#{1,6} /gm)],
    ['Codeblöcke', JSON.stringify(codeBlocks(a)), JSON.stringify(codeBlocks(b))],
    ['Links', JSON.stringify(links(a)), JSON.stringify(links(b))],
    ['Markdoc-Tags', JSON.stringify(tags(a)), JSON.stringify(tags(b))],
    ['Bilder', count(a, /!\[/g), count(b, /!\[/g)],
  ]
  for (const [name, x, y] of checks) if (x !== y) { console.log(`${f}: ${name} weichen ab`); bad++ }
  if (/\b(du|dich|dir|dein\w*)\b/i.test(b.replace(/```[\s\S]*?```/g, ''))) { console.log(`${f}: du-Form`); bad++ }
}
console.log(bad ? `${bad} Probleme` : 'docs-check: ok')
process.exit(bad ? 1 : 0)
```

- [ ] **Step 2: Übersetzen.** Je Datei (gut parallelisierbar, ein Unteragent pro Datei): Sie-Form, Codeblöcke/Befehle/URLs/Markdoc-Tags `{% … %}` unverändert, Bildpfade unverändert, Begriffe wie in Task 7. Installationsbefehle in `getting-started.md`/`faq.md` auf den Fork-Befehl aus Spec Abschnitt 7 umstellen – **Achtung:** das ändert Codeblöcke; in diesen Dateien die abweichenden Codeblöcke in `docs-check.mjs` durch eine Ausnahme `ALLOW_CODE_DIFF = ['getting-started.md', 'faq.md', 'updates.md']` zulassen und den Unterschied im Commit benennen. `release-notes.md`: oben ein deutscher Abschnitt „## Deutsche Fassung“ mit „1.35.1 – erste deutsche Fassung, beruht auf Project NOMAD 1.35.0“, darunter die Upstream-Notizen **englisch** mit dem Satz „Die folgenden Versionshinweise stammen aus dem Original und sind nicht übersetzt.“ – für diese Datei Überschriften-Prüfung auslassen.

- [ ] **Step 3:** Run `node de/tools/docs-check.mjs` · Expected: `docs-check: ok`.

- [ ] **Step 4: Commit** – `git add admin/docs-de de/tools/docs-check.mjs && git commit -m "docs(de): alle Anleitungen auf Deutsch" -m "Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"`

---

### Task 10: Herkunft auf den Fork umstellen (TypeScript)

**Files:**
- Create: `admin/constants/distribution.ts`
- Modify: `admin/app/services/collection_manifest_service.ts:31-36`, `admin/app/services/zim_service.ts:47`, `admin/app/services/system_service.ts:691,698`, `admin/app/services/auto_update_service.ts:21-22`, `admin/database/seeders/service_seeder.ts:553`, `admin/constants/ollama.ts` (`SYSTEM_PROMPTS.default`)
- Test: `admin/tests/unit/i18n_distribution.spec.ts`

**Interfaces:**
- Produces: `DISTRIBUTION = { repo, registry, imageRepo, rawBase, releasesApi, translateImage, mapsRepo, upstreamRepo }` (alle `string`).

- [ ] **Step 1: Failing test**

```ts
// admin/tests/unit/i18n_distribution.spec.ts
import * as assert from 'node:assert/strict'
import { test } from 'node:test'
import { DISTRIBUTION } from '../../constants/distribution.js'

test('distribution points at the German fork', () => {
  assert.equal(DISTRIBUTION.repo, 'huppiflupp/project-nomad-de')
  assert.equal(DISTRIBUTION.imageRepo, 'ghcr.io/huppiflupp/project-nomad-de')
  assert.equal(DISTRIBUTION.releasesApi, 'https://api.github.com/repos/huppiflupp/project-nomad-de/releases')
  assert.equal(DISTRIBUTION.rawBase, 'https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main')
  assert.equal(DISTRIBUTION.mapsRepo, 'Crosstalk-Solutions/project-nomad-maps')
})
```

- [ ] **Step 2:** Run test · Expected: FAIL.

- [ ] **Step 3: Implementieren**

```ts
// admin/constants/distribution.ts
// Where this distribution comes from. The German edition (huppiflupp/project-nomad-de)
// installs, updates and loads its catalogs from the fork, never from upstream.
const repo = 'huppiflupp/project-nomad-de'
const registry = 'ghcr.io/huppiflupp'

export const DISTRIBUTION = {
  repo,
  registry,
  imageRepo: `${registry}/project-nomad-de`,
  translateImage: `${registry}/project-nomad-de-translate`,
  rawBase: `https://raw.githubusercontent.com/${repo}/refs/heads/main`,
  releasesApi: `https://api.github.com/repos/${repo}/releases`,
  mapsRepo: 'Crosstalk-Solutions/project-nomad-maps',
  upstreamRepo: 'Crosstalk-Solutions/project-nomad',
} as const
```

Ersetzungen (Import jeweils `import { DISTRIBUTION } from '../../constants/distribution.js'`, im Seeder Pfad `'../../constants/distribution.js'` relativ zu `database/seeders` prüfen):
  - `collection_manifest_service.ts` `SPEC_URLS`: alle vier auf `` `${DISTRIBUTION.rawBase}/collections/<datei>.json` `` (auch `maps`, das heute die `github.com/…/raw/…`-Form nutzt).
  - `zim_service.ts:47`: `` const WIKIPEDIA_OPTIONS_URL = `${DISTRIBUTION.rawBase}/collections/wikipedia.json` ``
  - `system_service.ts:691`: `DISTRIBUTION.releasesApi`; `:698`: `` `${DISTRIBUTION.releasesApi}/latest` ``
  - `auto_update_service.ts`: `const NOMAD_IMAGE_REPO = DISTRIBUTION.imageRepo`, `const RELEASES_URL = DISTRIBUTION.releasesApi`
  - `service_seeder.ts:553`: `` container_image: `${DISTRIBUTION.translateImage}:0.1.0`, ``
  - `constants/ollama.ts`, Ende von `SYSTEM_PROMPTS.default` vor dem schließenden Backtick: `` - Answer in the language the user writes in. If that is unclear, answer in German.\n ``

- [ ] **Step 4:** Run `cd admin && npm run test:unit 2>&1 | tail -3 && npm run typecheck` · Expected: grün. Schlägt ein vorhandener Test fehl, weil er eine Crosstalk-URL erwartet (z. B. `app_auto_update.spec.ts`), den erwarteten Wert im Test auf `DISTRIBUTION.*` umstellen – nicht die Logik.

- [ ] **Step 5: Commit** – `git add -A admin/constants admin/app/services admin/database/seeders admin/tests/unit && git commit -m "feat(de): Kataloge, Updates und Images aus dem Fork" -m "Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"`

---

### Task 11: Herkunft umstellen (Shell, YAML, Workflows) und Prüfung

**Files:**
- Create: `de/tools/check-distribution.sh`
- Modify: `install/install_nomad.sh`, `install/run_updater_fixes.sh`, `install/management_compose.yaml`, `install/migrate-disk-collector.sh`, `install/sidecar-updater/update-watcher.sh:46`, `.github/workflows/build-{primary-image,sidecar-updater,disk-collector,translate-proxy}.yml`, `.github/ISSUE_TEMPLATE/config.yml`, `Dockerfile` (LABEL-Block)

- [ ] **Step 1: Prüfskript (zuerst, damit es rot ist)**

```bash
#!/usr/bin/env bash
# de/tools/check-distribution.sh – schlägt fehl, wenn außerhalb von Doku/Tests/de noch
# Upstream-Repo oder -Images referenziert werden (Ausnahmen: project-nomad-maps, nomad-sysbench).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
hits=$(git grep -nIiE 'crosstalk-?solutions/project-nomad([^-a-z0-9_]|$)|ghcr\.io/crosstalk-solutions/project-nomad' -- . \
  ':!de/' ':!*.md' ':!admin/docs/' ':!admin/docs-de/' ':!admin/tests/' ':!.github/workflows/release.yml' \
  ':!admin/inertia/components/Footer.tsx' ':!admin/constants/distribution.ts' || true)
if [ -n "$hits" ]; then
  echo "Upstream-Verweise gefunden:"; echo "$hits"; exit 1
fi
echo "check-distribution: ok"
```
`chmod +x`, Run: `bash de/tools/check-distribution.sh` · Expected: FAIL mit Trefferliste (Install-Skripte, Compose, Workflows, Dockerfile-Labels, Updater).

- [ ] **Step 2: Ersetzen** (nur diese beiden Muster, Maps/Sysbench bleiben):

```bash
files=$(git grep -lIiE 'crosstalk-?solutions/project-nomad([^-a-z0-9_]|$)|ghcr\.io/crosstalk-solutions/project-nomad' -- install .github/workflows .github/ISSUE_TEMPLATE Dockerfile)
sed -i -E \
  -e 's#ghcr\.io/crosstalk-solutions/project-nomad#ghcr.io/huppiflupp/project-nomad-de#g' \
  -e 's#Crosstalk-?Solutions/project-nomad/#huppiflupp/project-nomad-de/#g' \
  -e 's#Crosstalk-?Solutions/project-nomad([^-a-zA-Z0-9_]|$)#huppiflupp/project-nomad-de\1#g' \
  $files
```
Danach von Hand:
  - `install/sidecar-updater/update-watcher.sh:46`: die `sed`-Regex muss jetzt `ghcr\.io/huppiflupp/project-nomad-de` lauten (Punkt escapen, prüfen dass `\1:${target_tag}` erhalten ist).
  - Dockerfile-LABEL: `title="Project NOMAD – Deutsche Fassung (inoffiziell)"`, `description="Inoffizielle deutsche Fassung von Project NOMAD (Crosstalk Solutions)"`, `vendor="huppiflupp (Fork von Crosstalk Solutions, LLC)"`.
  - `.github/workflows/build-translate-proxy.yml`: Image-Name muss `ghcr.io/huppiflupp/project-nomad-de-translate` sein (durch die Ersetzung `project-nomad-translate` → `project-nomad-de-translate` bereits erledigt – prüfen).
  - `git diff --stat` ansehen: nur die erwarteten Dateien.

- [ ] **Step 3:** Run `bash de/tools/check-distribution.sh && bash -n install/*.sh install/sidecar-updater/update-watcher.sh && echo syntax-ok` · Expected: `check-distribution: ok`, `syntax-ok`.

- [ ] **Step 4: Commit** – `git add -A install .github Dockerfile de/tools/check-distribution.sh && git commit -m "build(de): Install-Skripte, Compose, Updater und Workflows auf den Fork" -m "Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"`

---

### Task 12: Install-Skripte auf Deutsch

**Files:**
- Modify: `install/install_nomad.sh`, `update_nomad.sh`, `start_nomad.sh`, `stop_nomad.sh`, `uninstall_nomad.sh`, `run_updater_fixes.sh`, `migrate-disk-collector.sh`, `install/sidecar-updater/update-watcher.sh` (nur `log`-Texte, die der Nutzer sieht – sonst unverändert)
- Create: `de/tools/script-check.sh`

- [ ] **Step 1: Prüfskript** – stellt sicher, dass sich außer Textzeilen nichts geändert hat:

```bash
#!/usr/bin/env bash
# de/tools/script-check.sh <datei> – vergleicht mit dem Stand BASE (Standard: Commit-Tag
# de-urls, gesetzt nach Task 11); erlaubt Änderungen nur in echo/printf/read -p/log-Zeilen und Kommentaren.
set -euo pipefail
f=$1
BASE=${BASE:-de-urls}
strip() { grep -vE '^\s*(#|echo|printf|log |read -r?p|read -p)' | grep -vE '^\s*"[^"]*"\s*$' ; }
diff <(git show "$BASE":"$f" | strip) <(strip < "$f") && echo "$f: nur Texte geändert"
```
Vorher den Stand nach Task 11 markieren: `git tag de-urls <commit von Task 11>` (lokales Tag, nicht pushen).

- [ ] **Step 2: Übersetzen.** In jeder Datei alle Texte in `echo`, `printf`, `read -p` und Prompts auf Deutsch (Sie-Form); Farbcodes, Variablen `${…}`, `$(…)`, Escape-Sequenzen und Befehle unverändert. Ja/Nein-Abfragen: Wenn das Skript `[[ $REPLY =~ ^[Yy]$ ]]` prüft, die Eingabe **auf `^[YyJj]$` erweitern** (einzige erlaubte Logikänderung, im Commit nennen) und im Text „(j/n)“ anzeigen. Kopf-Banner: „Offline-Wissens- und Lernserver – Deutsche Fassung (inoffiziell)“.

- [ ] **Step 3:** Run `for f in install/*.sh; do bash -n "$f"; done && for f in install/install_nomad.sh install/update_nomad.sh install/start_nomad.sh install/stop_nomad.sh install/uninstall_nomad.sh; do bash de/tools/script-check.sh "$f"; done` · Expected: alle „nur Texte geändert“ (außer der dokumentierten J/j-Erweiterung, die `diff` zeigt – manuell bestätigen).

- [ ] **Step 4: Commit** – `git add install de/tools/script-check.sh && git commit -m "feat(de): Install- und Wartungsskripte auf Deutsch" -m "Ja/Nein-Abfragen akzeptieren zusätzlich j/J." -m "Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"`

---

### Task 13: Repo-Dokumente, Lizenz-Hinweis, Merge-Regeln

**Files:**
- Modify: `README.md`, `FAQ.md` (komplett deutsch), `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md` (je deutscher Kopf + Verweis aufs Original, Original darunter unverändert lassen)
- Create: `NOTICE`, `.gitattributes`, `de/README.md` (Übersicht über `de/`)

- [ ] **Step 1: README.md** (deutsch) mit Abschnitten: Was ist das (inoffizielle deutsche Fassung von Project NOMAD, Link Original, Crosstalk Solutions); Was ist übersetzt (Oberfläche mit Umschalter, Anleitungen, Install-Skripte) und was nicht (Inhalte – folgt in späteren Teilprojekten); Installation (Befehl aus Spec Abschnitt 7, Systemvoraussetzungen wie im Original); Updates (aus der Oberfläche, Versionen „1.35.1 beruht auf 1.35.0“ mit der Patch-Regel); Fehler melden (Issues des Forks; Fehler im Original an Upstream); Lizenz Apache-2.0. Englischer Einzeiler oben: „Unofficial German edition of Project NOMAD. For the original (English) see …“.
- [ ] **Step 2: FAQ.md** aus dem Original übersetzen (Sie-Form, Befehle auf den Fork).
- [ ] **Step 3: NOTICE**

```
Project NOMAD – Deutsche Fassung (inoffiziell)
Copyright des Originals: Crosstalk Solutions, LLC – https://github.com/Crosstalk-Solutions/project-nomad
Lizenz: Apache License 2.0 (siehe LICENSE)

Änderungen in diesem Fork (huppiflupp/project-nomad-de):
- Deutsche Oberfläche (admin/i18n/, Babel-Plugin zur Bauzeit), Sprachumschalter
- Deutsche Anleitungen (admin/docs-de/), README, FAQ, Install-Skripte
- Installation, Updates, Kataloge und Images aus diesem Fork
Dieser Fork steht in keiner Verbindung zu Crosstalk Solutions.
```
- [ ] **Step 4: `.gitattributes`** (anhängen bzw. anlegen) und Merge-Treiber aktivieren:

```
README.md merge=ours
FAQ.md merge=ours
```
```bash
git config merge.ours.driver true
```
(Treiber-Einstellung in `de/SYNC.md` dokumentieren – sie ist lokal und muss auf jedem Klon gesetzt werden.)
- [ ] **Step 5:** Run `bash de/tools/check-distribution.sh` (Markdown ist ausgenommen – trotzdem `grep -n "Crosstalk" README.md` ansehen: nur Herkunftsverweise erlaubt).
- [ ] **Step 6: Commit** – `git add README.md FAQ.md CONTRIBUTING.md SECURITY.md CODE_OF_CONDUCT.md NOTICE .gitattributes de/README.md && git commit -m "docs(de): README, FAQ und Hinweise auf Deutsch, NOTICE" -m "Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"`

---

### Task 14: CI-Prüfungen

**Files:**
- Create: `.github/workflows/de-checks.yml`

- [ ] **Step 1: Workflow**

```yaml
name: Deutsche Fassung – Prüfungen
on:
  push:
    branches: [main, 'de/**', 'sync/**']
  pull_request:
jobs:
  checks:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: admin
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
          cache-dependency-path: admin/package-lock.json
      - run: npm ci
      - name: Übersetzungen vollständig
        run: node i18n/cli.mjs check
      - name: Anrede Sie
        run: node ../de/tools/sie-check.mjs i18n/de.json i18n/catalog.de.json
      - name: Anleitungen
        working-directory: .
        run: node de/tools/docs-check.mjs
      - name: Herkunft Fork
        working-directory: .
        run: bash de/tools/check-distribution.sh
      - name: Unit-Tests
        run: npm run test:unit
      - name: Typecheck und Build
        run: npm run typecheck && npm run build
```

- [ ] **Step 2:** Lokal die gleichen Befehle nacheinander ausführen · Expected: alle grün.
- [ ] **Step 3: Commit + Push** – `git add .github/workflows/de-checks.yml && git commit -m "ci(de): Prüfungen für Übersetzung, Herkunft, Tests" -m "Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>" && git push` · dann `gh run watch -R huppiflupp/project-nomad-de $(gh run list -R huppiflupp/project-nomad-de -w de-checks.yml -L1 --json databaseId -q '.[0].databaseId')` · Expected: grün. Hinweis: GitHub schaltet Actions in Forks erst nach Bestätigung frei – falls kein Lauf startet, den Nutzer bitten, unter *Actions* „I understand my workflows, enable them“ zu klicken.

---

### Task 15: Testinstanz auf ai395 und Sichtprüfung aller Seiten

**Files:**
- Create: `de/dev/compose.yml`, `de/dev/README.md`, `de/tools/crawl/package.json`, `de/tools/crawl/crawl.mjs`
- Modify: `.gitignore` (`de/dev/data/`, `de/tools/crawl/node_modules/`, `de/tools/crawl/report*.json`)

- [ ] **Step 1: Compose für die Testinstanz** (eigener Projektname, eigene Ports, eigene Daten, **ohne** Docker-Socket, damit sie keine Container auf ai395 startet):

```yaml
# de/dev/compose.yml – Testinstanz der deutschen Fassung auf ai395 (nur Oberfläche ansehen).
# Kein Docker-Socket: Apps installieren wird hier bewusst nicht getestet (das passiert auf x9).
name: nomad-de-dev
services:
  admin:
    image: nomad-de:dev
    ports: ["18080:8080"]
    volumes:
      - ./data/storage:/app/storage
    environment:
      - NODE_ENV=production
      - NOMAD_STORAGE_PATH=/app/storage
      - PORT=8080
      - LOG_LEVEL=info
      - APP_KEY=devdevdevdevdevdevdevdevdevdevde
      - HOST=0.0.0.0
      - URL=http://localhost:18080
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_DATABASE=nomad
      - DB_USER=nomad_user
      - DB_PASSWORD=devpass
      - DB_NAME=nomad
      - DB_SSL=false
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      mysql: { condition: service_healthy }
      redis: { condition: service_healthy }
  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=devroot
      - MYSQL_DATABASE=nomad
      - MYSQL_USER=nomad_user
      - MYSQL_PASSWORD=devpass
    volumes: [./data/mysql:/var/lib/mysql]
    healthcheck: { test: ["CMD", "mysqladmin", "ping", "-h", "localhost"], interval: 10s, retries: 20 }
  redis:
    image: redis:7-alpine
    volumes: [./data/redis:/data]
    healthcheck: { test: ["CMD", "redis-cli", "ping"], interval: 10s, retries: 10 }
```
Starten: `cd ~/projects/project-nomad-de && docker build -t nomad-de:dev . && docker compose -f de/dev/compose.yml up -d && sleep 60 && curl -fsS localhost:18080/api/health`. Expected: Health-OK. Vorher `ss -ltn | grep 18080` leer. Startet der Admin ohne Docker-Socket nicht (Fehler im Log `docker compose -f de/dev/compose.yml logs admin`), Socket **nur lesend** einhängen (`/var/run/docker.sock:/var/run/docker.sock:ro`) und in `de/dev/README.md` vermerken, dass in dieser Instanz keine Apps installiert werden dürfen.

- [ ] **Step 2: Crawl-Skript**

```json
{ "name": "nomad-de-crawl", "private": true, "type": "module", "dependencies": { "playwright": "^1.50.0" } }
```
```js
// de/tools/crawl/crawl.mjs – öffnet alle Seiten mit nomad_lang=de und meldet verdächtig englischen Text.
// Aufruf: node crawl.mjs http://localhost:18080 > report.json
import { chromium } from 'playwright'
const base = process.argv[2] ?? 'http://localhost:18080'
const PAGES = ['/home', '/easy-setup', '/easy-setup/complete', '/supply-depot', '/maps', '/chat', '/about',
  '/docs/home', '/docs/getting-started', '/docs/faq', '/drug-reference',
  '/settings/system', '/settings/apps', '/settings/models', '/settings/maps', '/settings/zim',
  '/settings/zim/remote-explorer', '/settings/benchmark', '/settings/update', '/settings/legal', '/settings/support',
  '/settings/knowledge-base']
const EN = /\b(the|and|your|you|with|this|that|from|will|are|is|to|of|for|not|no|click|select|download|install|update|settings|loading|error)\b/gi
const DE = /[äöüß]|\b(der|die|das|und|Sie|nicht|mit|für|wird|ist|eine?|Ihre?)\b/i
const browser = await chromium.launch()
const ctx = await browser.newContext()
await ctx.addCookies([{ name: 'nomad_lang', value: 'de', url: base }])
const report = []
for (const p of PAGES) {
  const page = await ctx.newPage()
  const res = await page.goto(base + p, { waitUntil: 'networkidle' }).catch((e) => ({ status: () => String(e) }))
  const texts = await page.evaluate(() => {
    const out = []
    const w = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT)
    for (let n; (n = w.nextNode()); ) {
      const el = n.parentElement
      if (!el || el.closest('code,pre,kbd,script,style') || !el.offsetParent) continue
      const s = n.nodeValue.replace(/\s+/g, ' ').trim()
      if (s) out.push(s)
    }
    for (const el of document.querySelectorAll('[placeholder],[title],[aria-label],[alt]'))
      for (const a of ['placeholder', 'title', 'aria-label', 'alt']) if (el.getAttribute(a)) out.push(el.getAttribute(a))
    return [...new Set(out)]
  })
  const suspicious = texts.filter((s) => (s.match(EN) || []).length >= 2 && !DE.test(s))
  report.push({ page: p, status: res.status(), suspicious })
  await page.close()
}
await browser.close()
console.log(JSON.stringify(report, null, 1))
```
Die Seitenliste vorher mit `grep -n "router.get" admin/start/routes.ts | grep -v "/api/"` abgleichen und fehlende Oberflächenrouten ergänzen.

- [ ] **Step 3:** `cd de/tools/crawl && npm i && npx playwright install chromium && node crawl.mjs http://localhost:18080 > report.json; node -e "const r=require('./report.json');for(const x of r)console.log(x.page,x.status,x.suspicious.length)"`

- [ ] **Step 4: Nacharbeit.** Für jeden verdächtigen Text die Quelle finden (`grep -rn "<text>" admin/inertia admin/app`) und je nach Ursache:
  - String in Variable/Funktionsargument der Oberfläche → `t('…')` aus `~/i18n/runtime` von Hand setzen.
  - Servertext, der über Inertia-Props bei späteren Seitenwechseln kommt (nicht Anfangsseite) → an der Anzeigestelle `tc(…)` bzw. `tm(…)`.
  - Neuer Schlüssel → `node i18n/cli.mjs check` zeigt ihn → in `de.json`/`catalog.de.json` ergänzen.
  - Gewollt englisch (Spec 4.5) → in `de/STAND.md` unter „Bewusst englisch“ auflisten.
  - **Review Focus 1:** `grep -rnE "(label|title|message|description)\s*===\s*['\"]" admin/inertia` – jeden Treffer prüfen; vergleicht Code einen übersetzten Text, die Stelle auf einen nicht übersetzten Vergleichswert umstellen (z. B. `id`), oder die Datei in `exclude` des Plugins aufnehmen, falls die Stelle ohne Logikänderung nicht lösbar ist.
  Neu bauen (`docker build -t nomad-de:dev . && docker compose -f de/dev/compose.yml up -d admin`) und Crawl wiederholen, bis jede Seite `suspicious: []` hat oder nur Einträge aus „Bewusst englisch“.

- [ ] **Step 5: Gegenprobe Englisch:** Crawl mit `nomad_lang=en` (Cookie-Wert im Skript per `LANG=en`-Variable umschaltbar machen) – erwartet: **keine** deutschen Texte außer dem Umschalter („Deutsch“).

- [ ] **Step 6:** Testinstanz stoppen: `docker compose -f de/dev/compose.yml down` (Daten bleiben in `de/dev/data/`).

- [ ] **Step 7: Commit** – `git add de/dev/compose.yml de/dev/README.md de/tools/crawl/package.json de/tools/crawl/crawl.mjs .gitignore admin de/STAND.md && git commit -m "test(de): Testinstanz und Seiten-Crawl; letzte Lücken übersetzt" -m "Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"`

---

### Task 16: Erstes Release 1.35.1

**Files:**
- Create: `de/RELEASE.md`, `de/tools/release.sh`

- [ ] **Step 1: Release-Skript**

```bash
#!/usr/bin/env bash
# de/tools/release.sh <version> – baut alle Images des Forks und legt das GitHub-Release an.
# Version: Patch = 100 × Upstream-Patch + n (siehe de/specs/…-teilprojekt-a…md, Nachtrag 1).
set -euo pipefail
v=${1:?Version, z. B. 1.35.1}
[[ $v =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Version muss X.Y.Z sein"; exit 1; }
R=huppiflupp/project-nomad-de
for wf in build-primary-image build-sidecar-updater build-disk-collector; do
  gh workflow run "$wf.yml" -R "$R" --ref main -f version="$v" -f tag_latest=true
done
echo "Workflows gestartet – warten: gh run list -R $R -L 5"
read -rp "Alle Builds grün? (j/n) " a; [[ $a =~ ^[JjYy]$ ]] || exit 1
gh release create "v$v" -R "$R" --target main --title "v$v – Deutsche Fassung" --notes-file "de/release-notes/v$v.md"
```
Translate-Image separat (eigene Versionierung `0.1.0`): `gh workflow run build-translate-proxy.yml -R huppiflupp/project-nomad-de --ref main` mit den Eingaben, die der Workflow verlangt (`sed -n '/inputs:/,/jobs:/p' .github/workflows/build-translate-proxy.yml`).

- [ ] **Step 2: Secrets.** Die Build-Workflows prüfen `secrets.DEPLOYMENT_AUTHORIZED_USERS`: `gh secret set DEPLOYMENT_AUTHORIZED_USERS -R huppiflupp/project-nomad-de -b huppiflupp`. `CREATOR_PACKS_APP_KEY` bleibt leer (Creator Packs sind dann ausgeblendet – im README erwähnen).

- [ ] **Step 3: Merge nach main und Push** – `git checkout main && git merge --no-ff de/teil-a -m "Teilprojekt A: deutsche Fassung" && git push origin main` (vorher `de-checks` auf `de/teil-a` grün).

- [ ] **Step 4: Release-Notizen** `de/release-notes/v1.35.1.md` (deutsch: „Erste deutsche Fassung, beruht auf Project NOMAD 1.35.0“, Liste aus NOTICE), committen, pushen, dann `bash de/tools/release.sh 1.35.1`.

- [ ] **Step 5: Pakete öffentlich machen.** GHCR legt neue Pakete privat an. Den Nutzer bitten, unter `https://github.com/huppiflupp?tab=packages` für `project-nomad-de`, `project-nomad-de-sidecar-updater`, `project-nomad-de-disk-collector`, `project-nomad-de-translate` jeweils *Package settings → Change visibility → Public* zu wählen. Prüfen: `docker logout ghcr.io; docker pull ghcr.io/huppiflupp/project-nomad-de:1.35.1` · Expected: Pull klappt ohne Anmeldung.

- [ ] **Step 6:** `de/RELEASE.md` mit genau diesen Schritten schreiben, committen, pushen.

---

### Task 17: Frische Installation auf x9 und Update-Test

**Files:**
- Create: `de/tests/x9-abnahme.md` (Protokoll)

- [ ] **Step 1: x9 einschalten** – `bash ~/projects/frickler/kinder-windows-vm/x9-power.sh` (Aufruf-Syntax im Skriptkopf nachlesen), warten bis `ssh x9 true` klappt.

- [ ] **Step 2: Wegwerf-VM statt Host.** Auf x9 laufen die Kinder-VMs (libvirt); Docker auf dem Host würde die FORWARD-Regeln ändern und deren Netz stören. Deshalb eine frische Ubuntu-24.04-VM: `ssh x9 'virt-install --name nomad-de-test --memory 8192 --vcpus 4 --disk size=60,path=/data/vms/nomad-de-test.qcow2 --os-variant ubuntu24.04 --cloud-init user-data=<datei mit seeas-Benutzer + SSH-Schlüssel von ai395> --location <ubuntu-24.04-cloud-image oder ISO> --network network=default --graphics none --noautoconsole'`. Cloud-Image bevorzugen (`--import` mit `noble-server-cloudimg-amd64.img` als Basis); die exakten Pfade/ISOs auf x9 vorher mit `ssh x9 ls /data/vms/iso` prüfen. Ist Speicher knapp (`/data` hat 593 GB frei laut Inventar): 60 GB reichen für A (keine großen Inhalte laden).

- [ ] **Step 3: Installieren** in der VM: `curl -fsSL https://raw.githubusercontent.com/huppiflupp/project-nomad-de/refs/heads/main/install/install_nomad.sh | sudo bash` – Ausgabe mitschneiden (`| tee install.log`). Expected: alle Meldungen deutsch, Ende ohne Fehler.

- [ ] **Step 4: Abnahme prüfen** (Spec Abschnitt 9) und ins Protokoll schreiben:
  1. `sudo docker ps --format '{{.Image}}'` → nur `ghcr.io/huppiflupp/…` und Fremd-Images.
  2. Crawl gegen `http://<vm-ip>:8080` (Task 15 Skript) → keine Funde.
  3. Anleitungen: `/docs/home` deutsch; nach Umschalten auf Englisch englisch.
  4. Eine App installieren (Kiwix mit der kleinen Test-ZIM aus dem Schnellstart) → Meldungen deutsch.
  5. KI-Chat optional (ohne GPU langsam): Ollama mit `qwen3:1.7b`, eine Frage auf Deutsch → Antwort deutsch.

- [ ] **Step 5: Update-Test.** Auf `main` eine sichtbare Kleinigkeit ändern (z. B. Release-Notiz), `bash de/tools/release.sh 1.35.2`; in der VM unter *Einstellungen → Aktualisierung* „Nach Updates suchen“ → 1.35.2 wird angeboten → aktualisieren → danach Oberfläche weiter deutsch, Fußzeile zeigt 1.35.2, `docker ps` zeigt `ghcr.io/huppiflupp/project-nomad-de:1.35.2`.

- [ ] **Step 6: Aufräumen** – VM stoppen (`ssh x9 virsh shutdown nomad-de-test`, Disk behalten für spätere Teilprojekte), x9 ausschalten (`x9-power.sh`). Protokoll committen und pushen.

---

### Task 18: Probe-Abgleich mit Upstream und `de/SYNC.md`

**Files:**
- Create: `de/SYNC.md`

- [ ] **Step 1:** `git fetch upstream --tags`; neuestes Upstream-Release nach `v1.35.0` bestimmen (`git tag --sort=-v:refname | head -3`). Gibt es keins, `upstream/main` verwenden.
- [ ] **Step 2:** `git checkout -b sync/probe main && git merge <tag oder upstream/main>`; Zeit stoppen; Konflikte zählen (`git diff --name-only --diff-filter=U`) und lösen.
- [ ] **Step 3:** `cd admin && npm ci && node i18n/cli.mjs check` → neue Texte übersetzen; `node ../de/tools/docs-check.mjs` und `bash ../de/tools/check-distribution.sh`; Unit-Tests.
- [ ] **Step 4:** `de/SYNC.md` schreiben: Ablauf (Zweig `sync/vX`, Merge, `merge.ours.driver` setzen, Prüfungen, neue englische Anleitungen über `git diff <alter-tag> <neuer-tag> -- admin/docs` finden und `docs-de` nachziehen, Version nach Patch-Regel, Release), Messwerte der Probe (Dauer, Zahl der Konflikte, Dateien), typische Konfliktstellen. Probe-Zweig nur mergen, wenn es ein echtes Release war; sonst verwerfen.
- [ ] **Step 5: Commit + Push** auf `main`.

---

### Task 19: Deutsche Screenshots für die Anleitungen

**Files:**
- Create: `admin/public/docs/de/*.webp` (gleiche Dateinamen wie `admin/public/docs/*.webp`)
- Modify: `admin/docs-de/*.md` (Bildpfade auf `/docs/de/…`), `de/tools/docs-check.mjs` (Bildpfad-Vergleich: Anzahl gleich, Pfade dürfen `/docs/de/` statt `/docs/` enthalten)

- [ ] **Step 1:** Für jedes Bild in `admin/public/docs/` die zugehörige Seite in der x9-VM (oder der Testinstanz) mit `nomad_lang=de` in gleicher Fenstergröße aufnehmen (Playwright `page.screenshot`, Größe aus dem Original lesen: `python3 -c "from PIL import Image;print(Image.open('admin/public/docs/dashboard.webp').size)"`), als WebP speichern.
- [ ] **Step 2:** Bildpfade in `admin/docs-de/*.md` umstellen, `docs-check.mjs` anpassen, Run `node de/tools/docs-check.mjs` · Expected: ok.
- [ ] **Step 3:** Testinstanz neu bauen, eine Anleitung mit Bild öffnen → deutscher Screenshot erscheint.
- [ ] **Step 4: Commit + Push**, Release `1.35.3` mit `de/tools/release.sh` (optional, nach Rücksprache).
