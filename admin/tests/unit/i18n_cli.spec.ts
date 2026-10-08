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

test('checkDicts wants catalog texts in the catalog dictionary, a UI entry is not enough', () => {
  const r = checkDicts({
    ui: new Map(), server: new Map(),
    catalog: new Map([['Notes', 'seeder.ts'], ['Medicine', 'x.json']]),
    de: { 'Notes': 'Notizen' },
    cat: { 'Medicine': 'Medizin' },
  })
  assert.deepEqual(r.missing, ['seeder.ts: Notes'])
})
