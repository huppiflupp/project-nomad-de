import * as assert from 'node:assert/strict'
import { test } from 'node:test'
import {
  compile, localizeData, normalize, parseLang, translate, translateDynamic, translateExact,
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

test('translate renders false/null/undefined args as nothing, keeps 0 and strings', () => {
  assert.equal(translate(null, 'Items: {0} | Size: {1}', [undefined, '2 GB']), 'Items:  | Size: 2 GB')
  assert.equal(translate(null, 'a{0}b{1}c{2}', [false, null, 0]), 'abc0')
  assert.equal(translate(dict, 'Deleted {0} files', [0]), '0 Dateien gelöscht')
})

test('localizeData leaves Markdoc render trees alone', () => {
  const tree = { $$mdtype: 'Tag', name: 'Image', attributes: { title: 'Medicine' }, children: [] }
  const data = { content: tree, title: 'Medicine' }
  localizeData(data, { message: (s) => s, catalog: (s) => translateDynamic(dict, s) })
  assert.equal(data.title, 'Medizin')
  assert.equal(tree.name, 'Image')
  assert.equal(tree.attributes.title, 'Medicine')
})

test('translateExact: catalog hits only, user data with pattern-like text stays untouched', () => {
  assert.equal(translateExact(dict, '  Medicine '), 'Medizin')
  assert.equal(translateExact(dict, 'Deleted 3 files'), 'Deleted 3 files')
  assert.equal(translateExact(dict, 'Downloading Home'), 'Downloading Home')
  assert.equal(translateExact(dict, 'Empty'), 'Empty')
  assert.equal(translateExact(null, 'Medicine'), 'Medicine')
})

test('localizeData leaves user-defined services (custom apps, link tiles) alone', () => {
  const data = [
    { service_name: 'nomad_kiwix', friendly_name: 'Medicine', is_custom: false, is_link_tile: false },
    { service_name: 'link_1', friendly_name: 'Medicine', is_custom: false, is_link_tile: 1 },
    { service_name: 'custom_x', friendly_name: 'Medicine', is_custom: true },
  ]
  localizeData(data, { message: (s) => s, catalog: (s) => translateDynamic(dict, s) })
  assert.deepEqual(data.map((d) => d.friendly_name), ['Medizin', 'Medicine', 'Medicine'])
})
