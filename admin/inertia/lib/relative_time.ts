import { getLang } from '~/i18n/runtime'

// Der Modellkatalog liefert Zeitangaben als englischen Text ("2 years ago", "54 minutes ago"). Auf Deutsch rechnen wir sie
// mit Intl.RelativeTimeFormat um ("vor 2 Jahren"); andere Texte bleiben unverändert.
const UNITS: Record<string, Intl.RelativeTimeFormatUnit> = {
  second: 'second',
  minute: 'minute',
  hour: 'hour',
  day: 'day',
  week: 'week',
  month: 'month',
  year: 'year',
}

export function localizeRelativeTime(text: string | null | undefined): string {
  if (!text || getLang() !== 'de') return text ?? ''
  const m = /^(\d+|an?|one)\s+(second|minute|hour|day|week|month|year)s?\s+ago$/i.exec(text.trim())
  if (!m) return text
  const n = /^\d+$/.test(m[1]) ? Number(m[1]) : 1
  try {
    return new Intl.RelativeTimeFormat('de', { numeric: 'always' }).format(-n, UNITS[m[2].toLowerCase()])
  } catch {
    return text
  }
}
