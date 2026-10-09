import { getLang } from '~/i18n/runtime'

// Länder-, Regions- und Kontinentnamen kommen vom Server auf Englisch (aus den Protomaps-Daten). In der deutschen
// Oberfläche zeigen wir sie deutsch an; die Namen liefert der Browser selbst (Intl.DisplayNames), es braucht kein Wörterbuch.

const CONTINENTS_DE: Record<string, string> = {
  Africa: 'Afrika',
  Asia: 'Asien',
  Europe: 'Europa',
  'North America': 'Nordamerika',
  'South America': 'Südamerika',
  Oceania: 'Ozeanien',
  Antarctica: 'Antarktis',
}

let regionNames: Intl.DisplayNames | null | undefined

function regions(): Intl.DisplayNames | null {
  if (regionNames === undefined) {
    try {
      regionNames = new Intl.DisplayNames(['de'], { type: 'region' })
    } catch {
      regionNames = null
    }
  }
  return regionNames
}

/** Deutscher Ländername zum ISO-Code (z. B. "DE" → "Deutschland"), sonst der englische Name. */
export function countryName(code: string, fallback: string): string {
  if (getLang() !== 'de') return fallback
  try {
    return regions()?.of(code) ?? fallback
  } catch {
    return fallback
  }
}

/** Deutscher Kontinent-/Gruppenname ("Europe" → "Europa"), sonst unverändert. */
export function continentName(name: string): string {
  return getLang() === 'de' ? (CONTINENTS_DE[name] ?? name) : name
}
