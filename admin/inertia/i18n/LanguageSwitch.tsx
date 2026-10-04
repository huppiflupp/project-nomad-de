import { getLang, setLang } from './runtime'

export default function LanguageSwitch() {
  const lang = getLang()
  const other = lang === 'de' ? 'en' : 'de'
  return (
    <button
      onClick={() => setLang(other)}
      className="text-sm/6 text-gray-500 hover:text-desert-green cursor-pointer"
      title={lang === 'de' ? 'Switch to English' : 'Auf Deutsch umschalten'}
    >
      {lang === 'de' ? 'English' : 'Deutsch'}
    </button>
  )
}
