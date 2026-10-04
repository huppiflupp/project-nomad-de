// Browser side of the German distribution's i18n. Language is read once from the
// nomad_lang cookie; switching reloads the page (see setLang).
import de from '../../i18n/de.json'
import catalogDe from '../../i18n/catalog.de.json'
import {
  compile, localizeData, parseLang, translate, translateDynamic, LANG_COOKIE, type Lang,
} from '../../i18n/core'

const lang: Lang = typeof document === 'undefined' ? 'de' : parseLang(document.cookie)
const ui = lang === 'de' ? compile(de as Record<string, string>) : null
const catalog = lang === 'de' ? compile(catalogDe as Record<string, string>) : null

if (typeof document !== 'undefined') document.documentElement.lang = lang

export function getLang(): Lang {
  return lang
}

export function __t(key: string, ...args: unknown[]): string {
  return translate(ui, key, args)
}
export const t = __t

/** Server message (may contain values): exact match, then {n} patterns. */
export function tm(text: string): string {
  return translateDynamic(ui, text)
}

/** Catalog/service text: exact match in the catalog dictionary, then UI dictionary. */
export function tc(text: string): string {
  const c = translateDynamic(catalog, text)
  return c !== text ? c : translateDynamic(ui, text)
}

export function localize<T>(data: T): T {
  if (lang === 'en') return data
  return localizeData(data, { message: tm, catalog: tc }) as T
}

export function setLang(next: Lang): void {
  document.cookie = `${LANG_COOKIE}=${next}; path=/; max-age=31536000; SameSite=Lax`
  window.location.reload()
}
