// de/tools/crawl/doc-bilder.mjs – nimmt die acht Anleitungsbilder der Doku neu auf, mit deutscher Oberfläche.
// Aufruf: node doc-bilder.mjs http://localhost:18088 <Ausgabeordner>   (PNG; Umwandlung in WebP macht das Aufrufer-Skript)
// Voraussetzung: NOMAD mit Wissensbibliothek (Kiwix), geladener Karte, KI-Assistent mit Modell; Internet für den Inhalts-Explorer.
import { chromium } from 'playwright'
import { mkdirSync } from 'node:fs'
const base = process.argv[2] ?? 'http://localhost:18088'
const out = process.argv[3] ?? '.'
const MODEL = process.env.MODEL ?? 'gemma4:E4B'
const FRAGE = process.env.FRAGE ?? 'Wie bereite ich Trinkwasser im Notfall auf?'
mkdirSync(out, { recursive: true })
const browser = await chromium.launch()
const ctx = await browser.newContext({ viewport: { width: 1200, height: 600 } })
await ctx.addCookies([{ name: 'nomad_lang', value: 'de', url: base }])

async function seite(pfad, hoehe, datei, vorher) {
  const page = await ctx.newPage()
  await page.setViewportSize({ width: 1200, height: hoehe })
  await page.goto(base + pfad, { waitUntil: 'networkidle' })
  if (vorher) await vorher(page)
  await page.screenshot({ path: `${out}/${datei}.png` })
  console.log('ok', datei)
  await page.close()
}

await seite('/home', 556, 'dashboard')
await seite('/easy-setup', 866, 'easy-setup-step1')

// Stufen-Dialog: Schnellstart bis Schritt „Inhalte“, Kategorie Medizin anklicken
await seite('/easy-setup', 735, 'easy-setup-tiers', async (page) => {
  const next = page.getByRole('button', { name: 'Weiter', exact: true })
  await page.getByText('Wissensbibliothek', { exact: true }).first().click().catch(() => {})
  for (let i = 0; i < 2 && (await next.count()) && !(await next.isDisabled()); i++) {
    await next.click()
    await page.waitForLoadState('networkidle')
  }
  await page.getByText('Medizin', { exact: true }).first().click()
  await page.waitForTimeout(800)
})

// KI-Chat mit echter Antwort
await seite('/chat', 594, 'ai-chat', async (page) => {
  const sel = page.locator('select').nth(1)
  const wert = await sel.evaluate((el, m) => [...el.options].find((o) => o.text.toLowerCase().includes(m.toLowerCase()))?.value, MODEL)
  if (wert !== undefined) await sel.selectOption(wert)
  const feld = page.getByPlaceholder(/Schreiben Sie eine Nachricht/)
  await feld.fill(FRAGE)
  await feld.press('Enter')
  await page.waitForSelector('text=Quellen', { timeout: 180000 }).catch(() => {})
  await page.waitForTimeout(1500)
})

// Wissensdatenbank (Hochladen-Dialog)
await seite('/chat', 700, 'knowledge-base', async (page) => {
  await page.getByRole('button', { name: /Wissensdatenbank/ }).first().click()
  await page.waitForTimeout(800)
})

await seite('/maps', 588, 'maps', async (page) => {
  // Ansicht auf Deutschland (die geladene Karte), per Koordinatenfeld und Mausrad
  const feld = page.getByPlaceholder(/lat/i).first()
  await feld.fill('51.0, 10.3')
  await feld.press('Enter')
  await page.waitForTimeout(3000)
  await page.mouse.move(600, 300)
  for (let i = 0; i < 4; i++) { await page.mouse.wheel(0, -300); await page.waitForTimeout(500) }
  await page.waitForTimeout(5000)
})
await seite('/settings/zim/remote-explorer', 588, 'content-explorer', async (page) => { await page.waitForTimeout(4000) })
await seite('/settings/benchmark', 588, 'benchmark', async (page) => {
  // „Nur System“ liefert in wenigen Minuten einen NOMAD-Score ohne KI-Lauf
  if (process.env.BENCHMARK !== '0') {
    await page.getByRole('button', { name: /Nur System/ }).click()
    await page.waitForSelector('text=/NOMAD.?Score/i', { timeout: 600000 }).catch(() => {})
    await page.waitForTimeout(2000)
  }
})
await browser.close()
