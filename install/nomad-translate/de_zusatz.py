"""Ergänzungen der deutschen Fassung zum Übersetzungsdienst (huppiflupp/project-nomad-de).

Bewusst in einer eigenen Datei, damit `proxy.py` (aus dem Original) nur wenige Zeilen Abweichung hat und Abgleiche einfach bleiben.

- Zahlenprüfung: Die kleine Bergamot-Maschine lässt gelegentlich Zahlen weg (gemessen: aus „15 to 20 minutes“ wurde nichts).
  Fehlt in einer übersetzten Passage eine Zahl der Vorlage, wird die Passage markiert; ein Hinhalten der Maus zeigt den Originaltext.
- Deutsche Beschriftung der Leiste und Sprachnamen.
"""
import html
import re
from collections import Counter

TITEL = "Diese Seite übersetzen"
HINWEIS = "Maschinell übersetzt. Bei Medizin und Sicherheit bitte das Original prüfen."
ORIGINAL = "Original"

SPRACHEN = {
    "de": "Deutsch", "fr": "Französisch", "es": "Spanisch", "it": "Italienisch", "pt": "Portugiesisch", "nl": "Niederländisch",
    "pl": "Polnisch", "cs": "Tschechisch", "sk": "Slowakisch", "sl": "Slowenisch", "hu": "Ungarisch", "ro": "Rumänisch",
    "bg": "Bulgarisch", "hr": "Kroatisch", "sr": "Serbisch", "uk": "Ukrainisch", "ru": "Russisch", "tr": "Türkisch",
    "el": "Griechisch", "sv": "Schwedisch", "da": "Dänisch", "nb": "Norwegisch", "fi": "Finnisch", "et": "Estnisch",
    "lv": "Lettisch", "lt": "Litauisch", "ca": "Katalanisch", "eu": "Baskisch", "gl": "Galicisch", "is": "Isländisch",
    "he": "Hebräisch", "fa": "Persisch", "hi": "Hindi", "bn": "Bengalisch", "ta": "Tamil", "te": "Telugu", "ur": "Urdu",
    "vi": "Vietnamesisch", "id": "Indonesisch", "ms": "Malaiisch", "af": "Afrikaans", "ja": "Japanisch", "ko": "Koreanisch",
}


def sprache(code: str, englisch: str) -> str:
    return SPRACHEN.get(code, englisch)


def status_text(words: int, blocks: int, ms: int, auffaellig: int) -> str:
    s = f"{words:,} Wörter · {blocks} Absätze · {ms:,} ms".replace(",", ".")
    if auffaellig:
        s += f" · ⚠ {auffaellig} Absatz/Absätze mit abweichenden Zahlen (markiert)"
    return s


_NUM = re.compile(r"\d[\d.,  ]*\d|\d")


def zahlen(text: str) -> Counter:
    """Zahlen eines Textes in Normalform (ohne Tausendertrenner, Dezimalpunkt), als Zähler.

    Englisch „6,500“ und „162.400“ und deutsch „6.500“ und „162,400“ sollen als gleich gelten, wenn es sich um Tausendergruppen
    handelt; ein einzelnes Trennzeichen mit genau drei Nachkommastellen ist mehrdeutig und wird als Tausendertrenner gelesen.
    """
    out: Counter = Counter()
    for m in _NUM.finditer(text.replace(" ", " ")):
        z = m.group(0).strip().rstrip(".,")
        z = re.sub(r"(?<=\d) (?=\d{3}\b)", "", z)               # 6 500 -> 6500
        z = re.sub(r"(?<=\d)[.,](?=\d{3}(?!\d))", "", z)         # Tausendertrenner
        out[z.replace(",", ".")] += 1
    return out


def fehlende_zahlen(quelle: str, ziel: str) -> dict:
    """Zahlen der Vorlage, die in der Übersetzung nicht (oft genug) vorkommen."""
    return dict(zahlen(quelle) - zahlen(ziel))


def markieren(ziel_html: str, quelle_text: str, fehlend: dict) -> str:
    """Umhüllt eine übersetzte Passage mit einer gelben Markierung; der Tooltip nennt die fehlenden Zahlen und das Original."""
    hinweis = "Zahlen prüfen – fehlt in der Übersetzung: " + ", ".join(sorted(fehlend)) + ". Original: " + quelle_text.strip()
    return f'<mark class="nomad-zahlen" title="{html.escape(hinweis, quote=True)}" style="background:#ffe9a8">{ziel_html}</mark>'


def pruefen(quellen_plain: list[str], ziele_plain: list[str], ziele_out: list[str]) -> tuple[list[str], int]:
    """Gibt (Ausgaben mit Markierung, Zahl der auffälligen Passagen) zurück."""
    res, n = [], 0
    for q, z, out in zip(quellen_plain, ziele_plain, ziele_out):
        f = fehlende_zahlen(q, z)
        if f:
            res.append(markieren(out, q, f))
            n += 1
        else:
            res.append(out)
    return res, n
