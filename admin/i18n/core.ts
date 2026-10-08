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

// false/null/undefined render as nothing, like React children do.
function format(template: string, args: unknown[]): string {
  return template.replace(/\{(\d+)\}/g, (all, i) => {
    if (Number(i) >= args.length) return all
    const v = args[Number(i)]
    return v === false || v === null || v === undefined ? '' : String(v)
  })
}

export function translate(c: Compiled | null, key: string, args: unknown[] = []): string {
  const hit = c?.exact.get(normalize(key))
  return format(hit ?? key, args)
}

/** Exact dictionary hit only (no {n} patterns); anything else comes back unchanged. */
export function translateExact(c: Compiled | null, text: string): string {
  if (!c || typeof text !== 'string') return text
  const hit = c.exact.get(normalize(text))
  return hit === undefined ? text : hit
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
    // Markdoc render trees (docs pages) use `name`/`title` for tags and attributes, not texts.
    if ('$$mdtype' in obj) return obj
    // User-defined services (custom apps, link tiles) carry names the user typed.
    if (obj.is_custom || obj.is_link_tile) return obj
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
