import json, sys, time, urllib.request
URL = sys.argv[1]; MODELL = sys.argv[2]; MODUS = sys.argv[3]; AUS = sys.argv[4]
texte = json.load(open('texte.json'))
SYS = {
 'wortgetreu': 'Du bist ein Fachübersetzer für Erste Hilfe und Notfallvorsorge. Übersetze den englischen Text ins Deutsche. Verwende die Anrede „Sie“. Übersetze genau und vollständig; behalte alle Zahlen und Einheiten unverändert bei. Gib nur die Übersetzung aus.',
 'metrisch': 'Du bist ein Fachübersetzer für Erste Hilfe und Notfallvorsorge. Übersetze den englischen Text ins Deutsche. Verwende die Anrede „Sie“. Übersetze genau und vollständig. Behalte alle Zahlen und Einheiten bei; ergänze bei nicht metrischen Einheiten (Fuß, Zoll, Gallone, °F) in Klammern den gerundeten metrischen Wert. Gib nur die Übersetzung aus.',
}[MODUS]
out, tok, t0 = {}, 0, time.time()
for k, v in texte.items():
    body = {'model': MODELL, 'messages': [{'role': 'system', 'content': SYS}, {'role': 'user', 'content': v}], 'temperature': 0.2, 'max_tokens': 600,
            'chat_template_kwargs': {'enable_thinking': False}}
    r = urllib.request.Request(URL + '/v1/chat/completions', json.dumps(body).encode(), {'Content-Type': 'application/json'})
    d = json.load(urllib.request.urlopen(r, timeout=600))
    out[k] = d['choices'][0]['message']['content'].strip()
    tok += d['usage']['completion_tokens']
dt = time.time() - t0
worte = sum(len(v.split()) for v in texte.values())
json.dump({'text': out, 'sekunden': dt, 'worte': worte, 'token': tok}, open(AUS, 'w'), ensure_ascii=False, indent=1)
print(f'{MODUS}: {worte} Wörter in {dt:.1f} s = {worte/dt:.1f} Wörter/s ({tok} Token)')
