#!/usr/bin/env python3
"""comfy_bilder.py – erzeugt die Illustrationen der Präsentation mit ComfyUI (Flux 1 schnell).
Aufruf:  python3 comfy_bilder.py bilder.json ausgabeordner [--nur name1,name2]
bilder.json: {"stil": "...", "bilder": {"name": "Bildbeschreibung", ...}}
Zugangsdaten: ~/.config/comfyui/claude-zugang (COMFYUI_USER, COMFYUI_PASS), ComfyUI auf 127.0.0.1:8188 hinter Caddy-Basic-Auth.
"""
import base64, json, os, random, re, sys, time, urllib.parse, urllib.request

BASE = os.environ.get('COMFYUI_URL', 'http://127.0.0.1:8188')


def zugang():
    d = {}
    for line in open(os.path.expanduser('~/.config/comfyui/claude-zugang')):
        m = re.match(r'\s*(?:export\s+)?(\w+)=(.*)', line)
        if m:
            d[m.group(1)] = m.group(2).strip().strip('"\'')
    return d['COMFYUI_USER'], d['COMFYUI_PASS']


USER, PW = zugang()
AUTH = 'Basic ' + base64.b64encode(f'{USER}:{PW}'.encode()).decode()


def req(path, data=None):
    r = urllib.request.Request(BASE + path, data=json.dumps(data).encode() if data is not None else None,
                               headers={'Authorization': AUTH, 'Content-Type': 'application/json'})
    return urllib.request.urlopen(r, timeout=600)


def workflow(prompt, seed, w, h):
    return {
        '1': {'class_type': 'CheckpointLoaderSimple', 'inputs': {'ckpt_name': 'flux1-schnell-fp8.safetensors'}},
        '2': {'class_type': 'CLIPTextEncode', 'inputs': {'text': prompt, 'clip': ['1', 1]}},
        '3': {'class_type': 'ConditioningZeroOut', 'inputs': {'conditioning': ['2', 0]}},
        '4': {'class_type': 'EmptyLatentImage', 'inputs': {'width': w, 'height': h, 'batch_size': 1}},
        '5': {'class_type': 'KSampler', 'inputs': {'seed': seed, 'steps': 4, 'cfg': 1.0, 'sampler_name': 'euler',
                                                     'scheduler': 'simple', 'denoise': 1.0, 'model': ['1', 0],
                                                     'positive': ['2', 0], 'negative': ['3', 0], 'latent_image': ['4', 0]}},
        '6': {'class_type': 'VAEDecode', 'inputs': {'samples': ['5', 0], 'vae': ['1', 2]}},
        '7': {'class_type': 'SaveImage', 'inputs': {'images': ['6', 0], 'filename_prefix': 'nomad_praes'}},
    }


def erzeuge(name, text, stil, ausgabe, w=1344, h=768, seed=None):
    seed = seed if seed is not None else random.randint(1, 2**31)
    pid = json.load(req('/prompt', {'prompt': workflow(f'{text}. {stil}', seed, w, h)}))['prompt_id']
    for _ in range(600):
        hist = json.load(req('/history/' + pid))
        if pid in hist and hist[pid].get('outputs'):
            img = hist[pid]['outputs']['7']['images'][0]
            q = urllib.parse.urlencode({'filename': img['filename'], 'subfolder': img['subfolder'], 'type': img['type']})
            data = req('/view?' + q).read()
            open(os.path.join(ausgabe, name + '.png'), 'wb').write(data)
            return True
        time.sleep(2)
    return False


if __name__ == '__main__':
    spec = json.load(open(sys.argv[1]))
    out = sys.argv[2]
    os.makedirs(out, exist_ok=True)
    nur = set(sys.argv[sys.argv.index('--nur') + 1].split(',')) if '--nur' in sys.argv else None
    for name, text in spec['bilder'].items():
        if nur and name not in nur:
            continue
        if os.path.exists(os.path.join(out, name + '.png')) and not nur:
            print('vorhanden', name, flush=True)
            continue
        t = time.time()
        ok = erzeuge(name, text, spec['stil'], out)
        print('ok' if ok else 'FEHLER', name, f'{time.time()-t:.0f}s', flush=True)
