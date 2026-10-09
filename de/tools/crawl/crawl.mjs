// de/tools/crawl/crawl.mjs – öffnet alle Seiten mit nomad_lang=de und meldet verdächtig englischen Text.
// Aufruf: node crawl.mjs http://localhost:18080 > report.json
// Gegenprobe: LANG=en node crawl.mjs … > report-en.json  (meldet dann verdächtig deutschen Text)
// LANG wird nur beachtet, wenn er genau "en" oder "de" ist (sonst z. B. de_DE.UTF-8 aus der Shell → de).
import { chromium } from 'playwright'
import { readFileSync } from 'node:fs'
const base = process.argv[2] ?? 'http://localhost:18080'
const lang = ['en', 'de'].includes(process.env.LANG) ? process.env.LANG : 'de'
const DOCS = ['home', 'getting-started', 'faq', 'about', 'api-reference', 'community-add-ons', 'drug-reference',
  'release-notes', 'supply-depot-apps', 'updates', 'use-cases']
const PAGES = ['/home', '/easy-setup', '/easy-setup/complete', '/supply-depot', '/maps', '/chat',
  '/chat?knowledge_base=true', '/about',
  ...DOCS.map((d) => `/docs/${d}`), '/drug-reference', '/drug-reference/interactions', '/conditions',
  '/settings/system', '/settings/apps', '/settings/models', '/settings/maps', '/settings/zim',
  '/settings/zim/remote-explorer', '/settings/creator-packs', '/settings/benchmark', '/settings/update',
  '/settings/legal', '/settings/support', '/settings/advanced',
  '/settings/knowledge-base' /* existiert nicht → prüft die 404-Seite */]
const EN = /\b(the|and|your|you|with|this|that|from|will|are|is|to|of|for|not|no|click|select|download|install|update|settings|loading|error)\b/gi
const DE = /[äöüß]|\b(der|die|das|und|Sie|nicht|mit|für|wird|ist|eine?|Ihre?)\b/i
const DE_COUNT = /[äöüß]|\b(der|die|das|und|Sie|nicht|mit|für|wird|ist|eine?|Ihre?)\b/gi
// Zweite Prüfung: sichtbarer Text, der wörtlich ein englischer Wörterbuchschlüssel ist (mit abweichender
// Übersetzung), ist sicher unübersetzt – findet auch kurze Texte wie Menüpunkte, die die Wortheuristik übersieht.
const norm = (s) => String(s).replace(/\s+/g, ' ').trim()
const dictKeys = new Set()
for (const f of ['de.json', 'catalog.de.json']) {
  const d = JSON.parse(readFileSync(new URL(`../../../admin/i18n/${f}`, import.meta.url), 'utf8'))
  for (const [k, v] of Object.entries(d)) if (v && norm(k) !== norm(v) && !/\{\d+\}/.test(k)) dictKeys.add(norm(k))
}
// Dritte Prüfung (beide Sprachen): Werte, die als Text gerendert wurden ("false", "[object Object]" …).
const BOGUS = /\b(false|undefined|null|NaN)\b|\[object Object\]/
// Sichtbare Texte und Text-Attribute einer Seite (ohne Code-Blöcke).
const collect = (page) =>
  page.evaluate(() => {
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
// Versionshinweise sind Commit-Prosa ("add null check …") – dort keine Prüfung auf gerenderte Werte.
const BOGUS_EXEMPT = new Set(['/docs/release-notes'])
const judge = (texts, p = '') => {
  const suspicious =
    lang === 'de'
      ? texts.filter((s) => (s.match(EN) || []).length >= 2 && !DE.test(s))
      : texts.filter((s) => (s.match(DE_COUNT) || []).length >= 2 && s !== 'Deutsch')
  const untranslated = lang === 'de' ? texts.filter((s) => dictKeys.has(norm(s)) && !suspicious.includes(s)) : []
  const bogus = BOGUS_EXEMPT.has(p) ? [] : texts.filter((s) => BOGUS.test(s))
  return { suspicious, untranslated, bogus }
}
const browser = await chromium.launch()
const ctx = await browser.newContext()
await ctx.addCookies([{ name: 'nomad_lang', value: lang, url: base }])
const report = []
for (const p of PAGES) {
  const page = await ctx.newPage()
  const res = await page.goto(base + p, { waitUntil: 'networkidle' }).catch((e) => ({ status: () => String(e) }))
  const texts = await collect(page)
  report.push({ page: p, url: page.url(), status: res.status(), lang, ...judge(texts, p) })
  await page.close()
}

// Interaktion 1: Seitenleiste der Einstellungen per Klick (Inertia-Navigation ohne Neuladen).
// Ein Merker am window-Objekt beweist, dass kein voller Seitenaufruf stattfand.
{
  const page = await ctx.newPage()
  await page.goto(base + '/settings/system', { waitUntil: 'networkidle' })
  await page.evaluate(() => { window.__crawlMarker = 1 })
  for (const target of ['/settings/maps', '/settings/zim', '/settings/benchmark', '/settings/update', '/settings/legal', '/supply-depot']) {
    const link = page.locator(`a[href="${target}"]`).first()
    if (!(await link.count())) {
      report.push({ page: `click ${target}`, lang, error: 'Link nicht gefunden' })
      continue
    }
    await link.click()
    await page.waitForURL(`**${target}`)
    await page.waitForLoadState('networkidle')
    const clientSide = await page.evaluate(() => window.__crawlMarker === 1)
    const texts = await collect(page)
    report.push({ page: `click ${target}`, url: page.url(), lang, clientSide, ...judge(texts) })
  }
  await page.close()
}

// Interaktion 2: Schnellstart Schritt für Schritt bis zur Prüfseite; die Zusammenfassung unten steht
// auf jedem Schritt. Ohne Internet bleibt "Weiter" gesperrt – dann wird nur Schritt 1 geprüft.
{
  const page = await ctx.newPage()
  await page.goto(base + '/easy-setup', { waitUntil: 'networkidle' })
  const next = page.getByRole('button', { name: lang === 'de' ? 'Weiter' : 'Next', exact: true })
  for (let step = 1; step <= 7; step++) {
    const texts = await collect(page)
    const summary = await page.locator('p', { hasText: /(selected|ausgewählt)$/ }).last().textContent({ timeout: 2000 }).catch(() => null)
    report.push({ page: `easy-setup step ${step}`, lang, summary, ...judge(texts) })
    if (!(await next.count()) || (await next.isDisabled())) break
    await next.click()
    await page.waitForLoadState('networkidle')
  }
  await page.close()
}
// Interaktion 3: Dialog der Inhaltsstufen (Schnellstart, Schritt 3). Er öffnet sich erst per Klick; die Seitenläufe
// oben sehen ihn deshalb nicht (so blieben "resources included" und Verwandtes lange unentdeckt).
{
  const page = await ctx.newPage()
  await page.goto(base + '/easy-setup', { waitUntil: 'networkidle' })
  const next = page.getByRole('button', { name: lang === 'de' ? 'Weiter' : 'Next', exact: true })
  await page.getByText(lang === 'de' ? 'Wissensbibliothek' : 'Information Library', { exact: true }).first().click().catch(() => {})
  for (let i = 0; i < 2 && (await next.count()) && !(await next.isDisabled()); i++) {
    await next.click()
    await page.waitForLoadState('networkidle')
  }
  const card = page.getByText(lang === 'de' ? 'Medizin (Deutsch)' : 'Medicine', { exact: true }).first()
  if (await card.count()) {
    await card.click()
    await page.waitForTimeout(500)
    const dialog = page.locator('[role="dialog"], .fixed').last()
    const texts = (await dialog.allInnerTexts()).join('\n').split('\n').map((x) => x.trim()).filter(Boolean)
    report.push({ page: 'easy-setup Stufen-Dialog', lang, ...judge(texts) })
  } else report.push({ page: 'easy-setup Stufen-Dialog', lang, error: 'Kategorie nicht gefunden (Katalog nicht geladen?)' })
  await page.close()
}
// Interaktion 4: Dialoge, die per Klick aufgehen, dürfen die Seite nicht abstürzen lassen (JS-Fehler = leere Seite).
// Anlass: v1.35.3 – ein bei jedem Rendern neues `locale`-Objekt ließ den Upload-Dialog der Wissensdatenbank in eine Endlosschleife laufen.
{
  const page = await ctx.newPage()
  const fehler = []
  page.on('pageerror', (e) => fehler.push(String(e).slice(0, 160)))
  await page.goto(base + '/chat', { waitUntil: 'networkidle' }).catch(() => {})
  const knopf = page.getByRole('button', { name: lang === 'de' ? /Wissensdatenbank/ : /Knowledge Base/ }).first()
  if (await knopf.count()) {
    await knopf.click()
    await page.waitForTimeout(2000)
    const laenge = (await page.innerText('body')).length
    report.push({ page: 'chat Wissensdatenbank-Dialog', lang, ...(fehler.length || laenge < 50 ? { error: `Seite abgestürzt: ${fehler[0] ?? 'leer'}` } : { ok: true }) })
  } else report.push({ page: 'chat Wissensdatenbank-Dialog', lang, skipped: 'KI-Assistent nicht installiert' })
  await page.close()
}
await browser.close()
console.log(JSON.stringify(report, null, 1))
