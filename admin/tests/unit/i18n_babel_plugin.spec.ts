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
