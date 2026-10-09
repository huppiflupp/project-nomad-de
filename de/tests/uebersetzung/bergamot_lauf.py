import json, sys, time
sys.path.insert(0, '/app')
import proxy
texte = json.load(open('/work/texte.json'))
proxy.translate_blocks('ende', ['Warm up.'])      # Modell laden
out, t0, worte = {}, time.time(), 0
for k, v in texte.items():
    out[k] = proxy.translate_blocks('ende', [v])[0]
    worte += len(v.split())
dt = time.time() - t0
json.dump({'text': out, 'sekunden': dt, 'worte': worte}, open('/work/ergebnis-bergamot.json', 'w'), ensure_ascii=False, indent=1)
print(f'{worte} Wörter in {dt:.2f} s = {worte/dt:.0f} Wörter/s')
