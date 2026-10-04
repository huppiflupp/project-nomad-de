import * as assert from 'node:assert/strict'
import { test } from 'node:test'
import { mkdtempSync, mkdirSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'
import { tmpdir } from 'node:os'
// DocsService itself pulls in the Adonis logger (needs a booted app); its path logic lives in DocsLocator.
import { DocsLocator } from '../../app/utils/docs_locator.js'

function fixture() {
  const dir = mkdtempSync(join(tmpdir(), 'docs-'))
  mkdirSync(join(dir, 'docs')); mkdirSync(join(dir, 'docs-de'))
  writeFileSync(join(dir, 'docs', 'home.md'), '# Home\n')
  writeFileSync(join(dir, 'docs', 'faq.md'), '# FAQ\n')
  writeFileSync(join(dir, 'docs', 'new-upstream.md'), '# New\n')
  writeFileSync(join(dir, 'docs-de', 'home.md'), '# Startseite\n')
  writeFileSync(join(dir, 'docs-de', 'faq.md'), '# Häufige Fragen\n')
  return new DocsLocator(dir)
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
  const de = await s.listDocs('de')
  assert.deepEqual(de.map((d) => d.slug), ['home', 'faq', 'new-upstream'])
  assert.deepEqual(de.map((d) => d.title).slice(0, 2), ['Startseite', 'Häufige Fragen'])
  const en = await s.listDocs('en')
  assert.equal(en.find((d) => d.slug === 'faq')!.title, 'FAQ')
})
