#!/usr/bin/env python3
"""kiwix_katalog.py – Pflege der Kiwix-Einträge in collections/kiwix-categories.json und collections/wikipedia.json.

Kiwix benennt Pakete mit Datum (wikipedia_de_all_nopic_2026-10.zim) und löscht alte Stände; Einträge mit festem Datum
verfallen deshalb (so geschehen bei devdocs_en_bash). Dieses Skript schlägt den aktuellen Stand im Kiwix-Katalog nach.

  python3 de/tools/kiwix_katalog.py suche <Muster> [--lang deu|eng]   Pakete im Katalog suchen (Name, Variante, Größe, Datum)
  python3 de/tools/kiwix_katalog.py pruefen                            alle Katalogeinträge gegen den aktuellen Stand prüfen
  python3 de/tools/kiwix_katalog.py aktualisieren                      Version, Adresse und Größe der veralteten Einträge ersetzen
  python3 de/tools/kiwix_katalog.py eintrag <Name> [<Variante>]        fertigen Eintrag (id, version, url, size_mb) ausgeben

Der Schlüssel eines Eintrags ist (Paketname, Variante), abgeleitet aus der Adresse: …/wikipedia_de_all_nopic_2026-10.zim
→ ("wikipedia_de_all", "nopic"). Einträge ohne Treffer im Katalog (Paket entfernt) meldet `pruefen` als FEHLT.
"""
import json, os, re, sys, urllib.request
import xml.etree.ElementTree as ET

HERE = os.path.dirname(os.path.abspath(__file__))
COLL = os.path.join(HERE, '..', '..', 'collections')
OPDS = 'https://library.kiwix.org/catalog/v2/entries?count=500&lang=%s'
NS = {'a': 'http://www.w3.org/2005/Atom'}
FILE_RE = re.compile(r'^(?P<name>.+?)(?:_(?P<flavour>maxi|mini|nopic))?_(?P<date>\d{4}-\d{2})\.zim$')


def lade(lang):
    out, start, seite = {}, 0, 500
    while True:
        with urllib.request.urlopen(OPDS % lang + '&start=%d' % start, timeout=180) as r:
            root = ET.fromstring(r.read())
        eintraege_ = root.findall('a:entry', NS)
        for e in eintraege_:
            name = e.findtext('a:name', namespaces=NS)
            flavour = e.findtext('a:flavour', namespaces=NS) or ''
            for l in e.findall('a:link', NS):
                if (l.get('type') or '').startswith('application/x-zim'):
                    href = l.get('href').replace('lb.download.kiwix.org', 'download.kiwix.org').removesuffix('.meta4')
                    m = FILE_RE.match(href.rsplit('/', 1)[-1])
                    if not m:
                        continue
                    out[(name, flavour)] = dict(url=href, version=m.group('date'), size_mb=round(int(l.get('length')) / 1e6),
                                                updated=(e.findtext('a:updated', namespaces=NS) or '')[:10], title=e.findtext('a:title', namespaces=NS))
        start += len(eintraege_)
        if len(eintraege_) < seite:
            return out


def katalog():
    alles = {}
    for lang in ('deu', 'eng', 'mul'):
        alles.update(lade(lang))
    return alles


def schluessel(url):
    m = FILE_RE.match(url.rsplit('/', 1)[-1])
    return (m.group('name'), m.group('flavour') or '') if m else None


def eintraege():
    """alle (Datei, Liste-der-Einträge) mit url-Feld in den beiden Katalogdateien"""
    res = []
    for datei in ('kiwix-categories.json', 'wikipedia.json'):
        pfad = os.path.join(COLL, datei)
        data = json.load(open(pfad))
        todo = []
        if 'categories' in data:
            for c in data['categories']:
                for t in c['tiers']:
                    todo += t['resources']
        else:
            todo += data['options']
        res.append((pfad, data, [r for r in todo if r.get('url')]))
    return res


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else 'pruefen'
    if cmd == 'suche':
        muster = re.compile(sys.argv[2], re.I)
        for (n, f), v in sorted(lade(sys.argv[sys.argv.index('--lang') + 1] if '--lang' in sys.argv else 'deu').items()):
            if muster.search(n):
                print(f"{v['size_mb']:>7} MB  {n} [{f or '-'}]  {v['version']}  (aktualisiert {v['updated']})")
        return
    if cmd == 'eintrag':
        n, f = sys.argv[2], (sys.argv[3] if len(sys.argv) > 3 else '')
        v = katalog().get((n, f))
        if not v:
            sys.exit(f'nicht gefunden: {n} [{f}]')
        print(json.dumps(dict(id=n + (f'_{f}' if f else ''), version=v['version'], url=v['url'], size_mb=v['size_mb']), indent=2))
        return
    kat = katalog()
    veraltet = fehlt = ok = 0
    for pfad, data, liste in eintraege():
        geaendert = False
        for r in liste:
            k = schluessel(r['url'])
            if not k:
                continue
            neu = kat.get(k)
            if not neu:
                print(f"FEHLT     {r.get('id')}: {k} nicht mehr im Kiwix-Katalog"); fehlt += 1
            elif neu['version'] != r.get('version') or neu['url'] != r['url']:
                print(f"VERALTET  {r.get('id')}: {r.get('version')} -> {neu['version']}, {r.get('size_mb')} -> {neu['size_mb']} MB"); veraltet += 1
                if cmd == 'aktualisieren':
                    r['version'], r['url'], r['size_mb'] = neu['version'], neu['url'], neu['size_mb']
                    geaendert = True
            else:
                ok += 1
        if geaendert:
            json.dump(data, open(pfad, 'w'), indent=2, ensure_ascii=False)
            open(pfad, 'a').write('\n')
    print(f'{ok} aktuell, {veraltet} veraltet, {fehlt} fehlen')
    sys.exit(1 if (fehlt or (veraltet and cmd == 'pruefen')) else 0)


if __name__ == '__main__':
    main()
