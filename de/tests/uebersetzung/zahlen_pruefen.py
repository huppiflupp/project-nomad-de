import json, re, collections
texte = json.load(open('texte.json'))
def zahlen(s):
    s = s.replace(' ', ' ')
    out = collections.Counter()
    for m in re.finditer(r'\d[\d.,]*', s):
        z = m.group(0).rstrip('.,')
        z = re.sub(r'(?<=\d)[.,](?=\d{3}(?!\d))', '', z)   # Tausendertrenner
        z = z.replace(',', '.')
        out[z] += 1
    return out
def pruefe(name, datei):
    t = json.load(open(datei))['text']
    fehl = 0; zeilen = []
    for k, en in texte.items():
        e, d = zahlen(en), zahlen(t[k])
        verloren = e - d
        if verloren: fehl += sum(verloren.values()); zeilen.append(f'  {k}: fehlt in Übersetzung {dict(verloren)}')
    print(f'{name}: {fehl} Zahl(en) der Vorlage fehlen' + ('' if not zeilen else '\n' + '\n'.join(zeilen)))
pruefe('Bergamot', 'ergebnis-bergamot-sauber.json')
pruefe('Qwen wortgetreu', 'ergebnis-qwen-wortgetreu.json')
pruefe('Qwen metrisch', 'ergebnis-qwen-metrisch.json')
