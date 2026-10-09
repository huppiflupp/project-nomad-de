"""Tests für de_zusatz.py (ohne Bergamot, ohne Netz).  python3 install/nomad-translate/test_de_zusatz.py"""
import os, sys, unittest
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import de_zusatz as z


class Zahlen(unittest.TestCase):
    def test_tausender_englisch_und_deutsch_gleich(self):
        self.assertEqual(z.zahlen("above 6,500 feet"), z.zahlen("über 6.500 Fuß"))
        self.assertEqual(z.zahlen("between 162.400 and 162.550 MHz"), z.zahlen("zwischen 162,400 und 162,550 MHz"))

    def test_dezimal(self):
        self.assertEqual(z.zahlen("1.5 liters"), z.zahlen("1,5 Liter"))

    def test_fehlende_zahl_wird_gemeldet(self):
        q = "Apply an ice pack for 15 to 20 minutes every two to three hours for the first 48 hours."
        ziel = "Tragen Sie eine Eispackung alle zwei bis drei Stunden für die ersten 48 Stunden auf."  # 15 und 20 fehlen
        self.assertEqual(z.fehlende_zahlen(q, ziel), {"15": 1, "20": 1})

    def test_vollstaendig_ist_leer(self):
        self.assertEqual(z.fehlende_zahlen("Cook poultry to 165°F (74°C).", "Garen Sie Geflügel auf 165 °F (74 °C)."), {})

    def test_zusaetzliche_umrechnung_stoert_nicht(self):
        self.assertEqual(z.fehlende_zahlen("one gallon of water", "eine Gallone (ca. 3,8 Liter) Wasser"), {})
        self.assertEqual(z.fehlende_zahlen("at least 20 feet away", "mindestens 20 Fuß (ca. 6 Meter) entfernt"), {})

    def test_zahl_doppelt_in_vorlage(self):
        self.assertEqual(z.fehlende_zahlen("2 to 2 hours", "2 Stunden"), {"2": 1})


class Markieren(unittest.TestCase):
    def test_markierung_enthaelt_original_und_fehlende(self):
        out, n = z.pruefen(["for 15 minutes"], ["für Minuten"], ["für Minuten"])
        self.assertEqual(n, 1)
        self.assertIn("<mark", out[0])
        self.assertIn("15", out[0])
        self.assertIn("for 15 minutes", out[0])

    def test_unauffaellig_bleibt_unveraendert(self):
        out, n = z.pruefen(["for 15 minutes"], ["15 Minuten"], ["<b>15 Minuten</b>"])
        self.assertEqual((out, n), (["<b>15 Minuten</b>"], 0))

    def test_html_im_tooltip_wird_maskiert(self):
        out, _ = z.pruefen(['say "5" <now>'], ["sagen"], ["sagen"])
        self.assertNotIn('<now>', out[0])


class Beschriftung(unittest.TestCase):
    def test_sprachnamen_deutsch(self):
        self.assertEqual(z.sprache("fr", "French"), "Französisch")
        self.assertEqual(z.sprache("xx", "Foo"), "Foo")

    def test_status_nennt_warnung(self):
        self.assertIn("abweichenden Zahlen", z.status_text(1200, 30, 400, 2))
        self.assertNotIn("abweichenden", z.status_text(1200, 30, 400, 0))


if __name__ == "__main__":
    unittest.main()
