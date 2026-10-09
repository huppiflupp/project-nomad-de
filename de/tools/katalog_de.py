#!/usr/bin/env python3
"""katalog_de.py – ergänzt collections/wikipedia.json und collections/kiwix-categories.json um die deutschsprachigen Inhalte
(Teilprojekt B). Idempotent: bestehende deutsche Einträge (id beginnt mit "de-" bzw. Kategorie-Slug endet auf "-de") werden ersetzt.
Die Auswahl und die deutschen Texte stehen hier; Version, Adresse und Größe holt kiwix_katalog.py live aus dem Kiwix-Katalog.

  python3 de/tools/katalog_de.py          schreibt die Katalogdateien neu
"""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kiwix_katalog as K

COLL = K.COLL
KAT = K.katalog()
SPEC_VERSION = os.environ.get('SPEC_VERSION', '2026-10-09')   # neue Fassung der Spezifikation: NOMAD lädt sie dann neu


def res(name, flavour, titel, beschreibung):
    v = KAT.get((name, flavour))
    if not v:
        sys.exit(f'nicht im Kiwix-Katalog: {name} [{flavour}]')
    return dict(id=name + (f'_{flavour}' if flavour else ''), version=v['version'], title=titel, description=beschreibung,
                url=v['url'], size_mb=v['size_mb'])


# ---- Wikipedia (Einfachauswahl) ----
WIKI = [
    ('de-top-mini', 'wikipedia_de_top', 'mini', 'Deutsche Wikipedia – Schnellreferenz',
     'Die wichtigsten deutschen Artikel in Kurzfassung. Gut zum schnellen Nachschlagen.'),
    ('de-top-nopic', 'wikipedia_de_top', 'nopic', 'Deutsche Wikipedia – Beliebte Artikel',
     'Die wichtigsten deutschen Artikel in voller Länge, ohne Bilder. Guter Mittelweg zwischen Inhalt und Größe.'),
    ('de-all-mini', 'wikipedia_de_all', 'mini', 'Deutsche Wikipedia – Komplett (Kompakt)',
     'Alle deutschen Artikel, jeweils nur die Einleitung.'),
    ('de-all-nopic', 'wikipedia_de_all', 'nopic', 'Deutsche Wikipedia – Komplett (ohne Bilder)',
     'Alle deutschen Artikel in voller Länge, ohne Bilder. Umfassendes Offline-Nachschlagewerk.'),
    ('de-all-maxi', 'wikipedia_de_all', 'maxi', 'Deutsche Wikipedia – Komplett (Vollständig)',
     'Alle deutschen Artikel mit Bildern und Medien. Nur für große Datenträger.'),
]

# ---- Kategorien (Sprache de), je drei Stufen ----
KATEGORIEN = [
    dict(name='Medizin (Deutsch)', slug='medizin-de', icon='IconStethoscope', language='de',
         description='Deutschsprachige Medizin: Medizin-Enzyklopädie und Grundlagen aus der Wikipedia.',
         tiers=[
             ('medizin-de-basis', 'Basis', 'Medizin-Enzyklopädie der deutschen Wikipedia (WikiMed), ohne Bilder.', True, None, [
                 ('wikipedia_de_medicine', 'nopic', 'Wikipedia Medizin (WikiMed)', 'Die medizinischen Artikel der deutschen Wikipedia, ohne Bilder.')]),
             ('medizin-de-standard', 'Standard', 'Dazu die biologischen Grundlagen. Enthält alles aus Basis.', None, 'medizin-de-basis', [
                 ('wikipedia_de_molcell', 'nopic', 'Wikipedia Molekular- und Zellbiologie', 'Biologische Grundlagen der Medizin, ohne Bilder.')]),
             ('medizin-de-umfassend', 'Umfassend', 'Medizin-Enzyklopädie mit Bildern. Enthält alles aus Standard.', None, 'medizin-de-standard', [
                 ('wikipedia_de_medicine', 'maxi', 'Wikipedia Medizin (WikiMed) mit Bildern', 'Die medizinischen Artikel mit Abbildungen und Grafiken.')]),
         ]),
    dict(name='Nachschlagen und Lernen (Deutsch)', slug='bildung-de', icon='IconSchool', language='de',
         description='Deutschsprachige Nachschlagewerke, Lehrbücher und Lernmaterial.',
         tiers=[
             ('bildung-de-basis', 'Basis', 'Kinderlexikon, Simulationen und Rechtschreibhilfe. Klein und sofort nützlich.', True, None, [
                 ('klexikon_de_all', 'nopic', 'Klexikon – das Kinderlexikon', 'Verständliche Erklärungen für Kinder, auch für Erwachsene gut zum Einstieg.'),
                 ('phet_de_all', '', 'PhET Interaktive Simulationen', 'Physik, Chemie, Biologie und Mathematik zum Ausprobieren.'),
                 ('wikipedia_de_mathematics', 'nopic', 'Wikipedia Mathematik', 'Mathematik-Artikel der deutschen Wikipedia, ohne Bilder.')]),
             ('bildung-de-standard', 'Standard', 'Lehrbücher, Hochschulkurse, Wörterbuch und Naturwissenschaften. Enthält alles aus Basis.', None, 'bildung-de-basis', [
                 ('wikibooks_de_all', 'nopic', 'Wikibooks', 'Freie deutsche Lehr- und Sachbücher, ohne Bilder.'),
                 ('wikiversity_de_all', 'nopic', 'Wikiversity', 'Freie Lernressourcen und Kurse, ohne Bilder.'),
                 ('wiktionary_de_all', 'nopic', 'Wiktionary', 'Deutsches Wörterbuch mit Bedeutung, Herkunft und Grammatik.'),
                 ('wikipedia_de_physics', 'nopic', 'Wikipedia Physik', 'Physik-Artikel der deutschen Wikipedia, ohne Bilder.'),
                 ('wikipedia_de_chemistry', 'nopic', 'Wikipedia Chemie', 'Chemie-Artikel der deutschen Wikipedia, ohne Bilder.'),
                 ('wikipedia_de_geography', 'nopic', 'Wikipedia Geographie', 'Länder, Städte und Landschaften, ohne Bilder.'),
                 ('wikipedia_de_history', 'nopic', 'Wikipedia Geschichte', 'Geschichts-Artikel der deutschen Wikipedia, ohne Bilder.'),
                 ('wikipedia_de_climate-change', 'nopic', 'Wikipedia Klimawandel', 'Artikel zu Klima und Klimawandel, ohne Bilder.'),
                 ('wikivoyage_de_all', 'nopic', 'Wikivoyage', 'Reiseführer der deutschen Wikivoyage, ohne Bilder.')]),
             ('bildung-de-umfassend', 'Umfassend', 'Dazu Quellentexte und die deutsche Literatur. Enthält alles aus Standard.', None, 'bildung-de-standard', [
                 ('wikisource_de_all', 'nopic', 'Wikisource', 'Freie Quellentexte und Dokumente, ohne Bilder.'),
                 ('gutenberg_de_all', '', 'Projekt Gutenberg – Bibliothek', 'Tausende deutsche Bücher und Klassiker der Literatur.')]),
         ]),
    dict(name='Alltag und Technik (Deutsch)', slug='alltag-de', icon='IconTool', language='de',
         description='Deutschsprachige Anleitungen: Kochen, Computer und Reparieren.',
         tiers=[
             ('alltag-de-basis', 'Basis', 'Koch-Rezepte und Programmieren lernen. Sehr klein.', True, None, [
                 ('kochwiki.org_de_all', 'nopic', 'Koch-Wiki', 'Rezepte und Kochtechniken, ohne Bilder.'),
                 ('freecodecamp_de_all', '', 'freeCodeCamp', 'Programmieren lernen mit deutschen Tutorials.')]),
             ('alltag-de-standard', 'Standard', 'Dazu Koch-Wiki mit Bildern und Informatik-Artikel. Enthält alles aus Basis.', None, 'alltag-de-basis', [
                 ('kochwiki.org_de_all', 'maxi', 'Koch-Wiki mit Bildern', 'Rezepte und Kochtechniken mit Fotos.'),
                 ('wikipedia_de_computer', 'nopic', 'Wikipedia Informatik', 'Informatik-Artikel der deutschen Wikipedia, ohne Bilder.')]),
             ('alltag-de-umfassend', 'Umfassend', 'Dazu die deutschen iFixit-Reparaturanleitungen. Enthält alles aus Standard.', None, 'alltag-de-standard', [
                 ('ifixit_de_all', '', 'iFixit Reparaturanleitungen', 'Schritt-für-Schritt-Anleitungen zum Reparieren von Geräten.')]),
         ]),
]


def baue():
    # Wikipedia
    pw = os.path.join(COLL, 'wikipedia.json')
    w = json.load(open(pw))
    w['options'] = [o for o in w['options'] if not o['id'].startswith('de-')]
    neu = [dict(id=i, name=n, description=b, size_mb=KAT[(k, f)]['size_mb'], url=KAT[(k, f)]['url'], version=KAT[(k, f)]['version'])
           for i, k, f, n, b in WIKI]
    keine = [o for o in w['options'] if o['id'] == 'none']
    rest = [o for o in w['options'] if o['id'] != 'none']
    w['options'] = keine + neu + rest
    w['spec_version'] = SPEC_VERSION
    open(pw, 'w').write(json.dumps(w, indent=2, ensure_ascii=False) + '\n')
    # Kategorien
    pk = os.path.join(COLL, 'kiwix-categories.json')
    k = json.load(open(pk))
    k['categories'] = [c for c in k['categories'] if not c['slug'].endswith('-de')]
    deutsch = []
    for c in KATEGORIEN:
        tiers = []
        for slug, name, besch, empf, inkl, rs in c['tiers']:
            t = dict(name=name, slug=slug, description=besch)
            if empf:
                t['recommended'] = True
            if inkl:
                t['includesTier'] = inkl
            t['resources'] = [res(*r) for r in rs]
            tiers.append(t)
        deutsch.append(dict(name=c['name'], slug=c['slug'], icon=c['icon'], description=c['description'], language=c['language'], tiers=tiers))
    k['categories'] = deutsch + k['categories']   # deutsche Kategorien zuerst
    k['spec_version'] = SPEC_VERSION
    open(pk, 'w').write(json.dumps(k, indent=2, ensure_ascii=False) + '\n')
    print('geschrieben:', len(neu), 'Wikipedia-Optionen,', len(KATEGORIEN), 'Kategorien')


if __name__ == '__main__':
    baue()
