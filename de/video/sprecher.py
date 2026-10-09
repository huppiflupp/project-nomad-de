#!/usr/bin/env python3
"""sprecher.py – erzeugt die deutsche Sprecherstimme für die Videos (Piper, Stimme „thorsten“ high, aus sprachlern-ki; in der Rückprobe
deutlich besser als Kyutai Pocket TTS: 8–18 % statt 27–43 % Abweichung bei gleichen Texten).
Läuft mit dem venv von sprachlern-ki:  ~/sprachlern-ki/.venv/bin/python sprecher.py szenen.json ausgabeordner
szenen.json: {"video": "v1", "szenen": [{"id": "s01", "text": "..."}, ...]}  (von bauen.py geschrieben)
Je Szene entsteht <id>.wav (mono) und <id>.txt (Rückprobe); Satz für Satz erzeugt, 0,25 s Pause, Rückprobe mit faster-whisper.
"""
import json, os, re, sys, time
import numpy as np

LENGTH = float(os.environ.get('TEMPO', '1.08'))   # >1 = langsamer; für Zuhörer ab 60 etwas ruhiger
VOICE = os.path.expanduser('~/sprachlern-ki/models/piper/de/de_DE/thorsten/high/de_DE-thorsten-high.onnx')
# Aussprachehilfen (Schreibweise nur für die Sprachausgabe; Untertitel zeigen den Originaltext)
AUSSPRACHE = [('NOMAD', 'Nomad'), ('Kiwix', 'Kiwiks'), ('Ollama', 'Olama'), ('llama.cpp', 'Lama Zeh Pe Pe'), ('USB-SSD', 'U-Es-Be-Es-Es-De'),
              ('USB', 'U-Es-Be'), ('SSD', 'Es-Es-De'), ('KI', 'Ka-I'), ('PDF', 'Pe-De-Eff'), ('HTML', 'Ha-Te-Em-El'), ('WLAN', 'Wi-Lan'),
              ('GPU', 'Ge-Pe-U'), ('CPU', 'Ze-Pe-U'), ('Ubuntu', 'Ubuntu'), ('GB', 'Gigabyte'), ('MB', 'Megabyte'), ('Wh', 'Wattstunden'),
              ('docker', 'Docker'), ('Token/s', 'Token pro Sekunde'), ('ca.', 'circa'), ('z. B.', 'zum Beispiel'), ('bzw.', 'beziehungsweise')]


def aussprache(text):
    for a, b in AUSSPRACHE:
        text = text.replace(a, b)
    return text


def saetze(text):
    teile = re.split(r'(?<=[.!?:])\s+', text.strip())
    return [t for t in teile if t]


def normal(s):
    s = s.lower().replace('ß', 'ss')
    return re.sub(r'[^a-zäöü0-9 ]', ' ', s).split()


def wer(ref, hyp):
    r, h = normal(ref), normal(hyp)
    d = [[0] * (len(h) + 1) for _ in range(len(r) + 1)]
    for i in range(len(r) + 1):
        d[i][0] = i
    for j in range(len(h) + 1):
        d[0][j] = j
    for i in range(1, len(r) + 1):
        for j in range(1, len(h) + 1):
            d[i][j] = min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + (r[i - 1] != h[j - 1]))
    return d[-1][-1] / max(1, len(r))


def main():
    spec = json.load(open(sys.argv[1]))
    out = sys.argv[2]
    os.makedirs(out, exist_ok=True)
    from piper import PiperVoice, SynthesisConfig
    import io, wave
    voice = PiperVoice.load(VOICE)
    cfg = SynthesisConfig(length_scale=LENGTH)
    sr = voice.config.sample_rate

    def sprich(satz):
        buf = io.BytesIO()
        with wave.open(buf, 'wb') as w:
            voice.synthesize_wav(aussprache(satz), w, syn_config=cfg)
        buf.seek(0)
        with wave.open(buf, 'rb') as w:
            return np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(np.float32) / 32768.0
    from faster_whisper import WhisperModel
    asr = WhisperModel(os.environ.get('WHISPER', 'small'), device='cpu', compute_type='int8')
    import soundfile as sf
    pause = np.zeros(int(sr * 0.25), dtype=np.float32)
    bericht = []
    for sz in spec['szenen']:
        wav = os.path.join(out, sz['id'] + '.wav')
        if os.path.exists(wav) and not os.environ.get('NEU'):
            continue
        t0 = time.time()
        teile = []
        for satz in saetze(sz['text']):
            a = sprich(satz)
            teile += [a, pause]
        audio = np.concatenate(teile)
        sf.write(wav, audio, sr)
        segs, _ = asr.transcribe(wav, language='de', beam_size=5)
        hyp = ' '.join(s.text for s in segs)
        w = wer(sz['text'], hyp)
        open(os.path.join(out, sz['id'] + '.txt'), 'w').write(hyp)
        bericht.append((sz['id'], len(audio) / sr, w))
        print(f"{sz['id']}: {len(audio)/sr:5.1f} s, Abweichung {w:.0%}, {time.time()-t0:.0f} s Rechenzeit", flush=True)
        if w > 0.2:
            print('  Soll:', sz['text'][:160], '\n  Hörprobe:', hyp[:160], flush=True)
    json.dump(bericht, open(os.path.join(out, 'bericht.json'), 'w'))


if __name__ == '__main__':
    main()
