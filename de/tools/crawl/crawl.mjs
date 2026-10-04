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
const browser = await chromium.launch()
const ctx = await browser.newContext()
await ctx.addCookies([{ name: 'nomad_lang', value: lang, url: base }])
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
  const suspicious =
    lang === 'de'
      ? texts.filter((s) => (s.match(EN) || []).length >= 2 && !DE.test(s))
      : texts.filter((s) => (s.match(DE_COUNT) || []).length >= 2 && s !== 'Deutsch')
  const untranslated = lang === 'de' ? texts.filter((s) => dictKeys.has(norm(s)) && !suspicious.includes(s)) : []
  report.push({ page: p, url: page.url(), status: res.status(), lang, suspicious, untranslated })
  await page.close()
}
await browser.close()
console.log(JSON.stringify(report, null, 1))
