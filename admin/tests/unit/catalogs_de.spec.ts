import * as assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { test } from 'node:test'
import vine from '@vinejs/vine'

import { zimCategoriesSpecSchema, wikipediaSpecSchema } from '../../app/validators/curated_collections.js'

// Die Kataloge liegen im Repo-Wurzelordner `collections/` (NOMAD lädt sie zur Laufzeit von dort, siehe DISTRIBUTION.rawBase).
const lade = (name: string) => JSON.parse(readFileSync(new URL(`../../../collections/${name}`, import.meta.url), 'utf8'))

test('kiwix-categories.json erfüllt das Schema der Anwendung', async () => {
  await vine.validate({ schema: zimCategoriesSpecSchema, data: lade('kiwix-categories.json') })
})

test('wikipedia.json erfüllt das Schema der Anwendung', async () => {
  await vine.validate({ schema: wikipediaSpecSchema, data: lade('wikipedia.json') })
})

test('Wikipedia-Optionen: eindeutige Kennungen, "none" zuerst, deutsche Optionen vorhanden', () => {
  const ids: string[] = lade('wikipedia.json').options.map((o: { id: string }) => o.id)
  assert.equal(new Set(ids).size, ids.length)
  assert.equal(ids[0], 'none')
  for (const id of ['de-top-mini', 'de-top-nopic', 'de-all-mini', 'de-all-nopic', 'de-all-maxi']) assert.ok(ids.includes(id), id)
})

test('Kategorien: eindeutige Slugs, Stufenketten (includesTier) zeigen auf eine frühere Stufe derselben Kategorie', () => {
  const kat = lade('kiwix-categories.json').categories
  const slugs: string[] = kat.map((c: { slug: string }) => c.slug)
  assert.equal(new Set(slugs).size, slugs.length)
  for (const c of kat) {
    const gesehen = new Set<string>()
    for (const t of c.tiers) {
      if (t.includesTier) assert.ok(gesehen.has(t.includesTier), `${c.slug}/${t.slug}: includesTier ${t.includesTier} unbekannt`)
      gesehen.add(t.slug)
      assert.ok(t.resources.length > 0, `${c.slug}/${t.slug} ohne Inhalte`)
    }
  }
})

test('Deutsche Kategorien: Sprache de, drei Stufen, jede Stufe mit Größe, Adresse von Kiwix', () => {
  const de = lade('kiwix-categories.json').categories.filter((c: { slug: string }) => c.slug.endsWith('-de'))
  assert.ok(de.length >= 3)
  for (const c of de) {
    assert.equal(c.language, 'de')
    assert.equal(c.tiers.length, 3, c.slug)
    assert.ok(c.tiers.some((t: { recommended?: boolean }) => t.recommended), `${c.slug}: keine empfohlene Stufe`)
    for (const t of c.tiers)
      for (const r of t.resources) {
        assert.ok(r.size_mb > 0, `${r.id}: Größe fehlt`)
        assert.match(r.url, /^https:\/\/download\.kiwix\.org\/zim\/.+\.zim$/, r.id)
        assert.match(r.url, /_(\d{4}-\d{2})\.zim$/, r.id)
        assert.ok(r.url.endsWith(`${r.version}.zim`), `${r.id}: Version passt nicht zur Adresse`)
      }
  }
})

test('Ressourcen-Kennungen sind je Kategorie eindeutig', () => {
  for (const c of lade('kiwix-categories.json').categories) {
    const ids: string[] = c.tiers.flatMap((t: { resources: { id: string }[] }) => t.resources.map((r) => r.id))
    assert.equal(new Set(ids).size, ids.length, `${c.slug}: doppelte Kennung`)
  }
})
