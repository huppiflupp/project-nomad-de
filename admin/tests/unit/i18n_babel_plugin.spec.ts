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
  const { out } = run('const A = () => <p>Read the <a href="/docs">user guide</a> before you start.</p>')
  assert.match(out, /__t\("Read the"\)\}\{" "\}/)
  assert.match(out, /__t\("user guide"\)/)
  assert.match(out, /\{" "\}\{__t\("before you start\."\)\}/)
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

test('display-text calls and extra text props are wrapped', () => {
  const { out, collect } = run(
    'const A = ({e}) => { showError(`Failed to save: ${e}`); window.confirm("Discard all changes?"); console.log("Not for users here"); return <Tip text="Shown on hover" helpText="Some help text" /> }'
  )
  assert.match(out, /showError\(__t\("Failed to save: \{0\}", e\)\)/)
  assert.match(out, /window\.confirm\(__t\("Discard all changes\?"\)\)/)
  assert.match(out, /console\.log\("Not for users here"\)/)
  assert.match(out, /text=\{__t\("Shown on hover"\)\}/)
  assert.ok(collect.has('Some help text'))
})

test('children with JSX/logical/mixed conditionals are not merged into one key', () => {
  const a = run('const A = ({c, n}) => <p>{n} tiers available{!c && <span> - Click to choose</span>}</p>')
  assert.doesNotMatch(a.out, /\{\d\}/)
  assert.match(a.out, /__t\("tiers available"\)/)
  assert.match(a.out, /__t\("- Click to choose"\)/)
  const b = run('const A = ({n}) => <p>{n} map region{n !== 1 && "s"} selected</p>')
  assert.doesNotMatch(b.out, /\{\d\}/)
  assert.match(b.out, /n !== 1 && "s"/)
  const c = run('const A = ({a}) => <p>Status: {a ? "Ready now" : <b>Busy</b>}</p>')
  assert.doesNotMatch(c.out, /\{\d\}/)
  assert.match(c.out, /__t\("Ready now"\)/)
  assert.match(c.out, /__t\("Busy"\)/)
  const d = run('const A = ({xs}) => <ul>Items {xs.map((x) => <li key={x}>{x}</li>)}</ul>')
  assert.doesNotMatch(d.out, /\{\d\}/)
})

test('plain values and string-only conditionals still merge, optional chains included', () => {
  const { out } = run('const A = ({c, s}) => <p>Items: {c.resources?.length} | Size: {s} {c.on ? "on" : "off"}</p>')
  assert.match(out, /__t\("Items: \{0\} \| Size: \{1\} \{2\}", c\.resources\?\.length, s, c\.on \? "on" : "off"\)/)
})

test('object children/cta props and member display calls are wrapped; non-literal args are not', () => {
  const { out } = run(
    'const f = (msg) => { open({ children: "Close this window", cta: "Get started now" }); uppy.info("Upload finished well"); showError(msg); setError(err.message) }'
  )
  assert.match(out, /children: __t\("Close this window"\)/)
  assert.match(out, /cta: __t\("Get started now"\)/)
  assert.match(out, /uppy\.info\(__t\("Upload finished well"\)\)/)
  assert.match(out, /showError\(msg\)/)
  assert.match(out, /setError\(err\.message\)/)
})

test('|| and ?? with value-like sides keep the merged sentence', () => {
  const { out } = run('const A = ({s, g}) => <p>Install {s.friendly_name || s.service_name} on {g ?? "none"} now?</p>')
  assert.match(out, /__t\("Install \{0\} on \{1\} now\?", s\.friendly_name \|\| s\.service_name, g \?\? "none"\)/)
  const b = run('const A = ({s}) => <p>Install {s.ok || <b>nothing</b>} now</p>')
  assert.doesNotMatch(b.out, /\{\d\}/)
})
