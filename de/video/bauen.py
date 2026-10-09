#!/usr/bin/env python3
"""bauen.py – baut die Videos aus videos.py (Standbilder mit sanftem Zoom + deutsche Sprecherstimme + Untertitel).
Aufruf:  python3 bauen.py v1 [v2 …]  (Ergebnis: de/video/ausgabe/<name>.mp4 und .srt; Arbeitsdateien in de/video/arbeit/<name>/)
Voraussetzungen: ffmpeg, Pillow, sprachlern-ki-venv (Piper) – siehe sprecher.py. Ohne Argument: alle.
"""
import json, os, re, subprocess, sys, wave

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from videos import VIDEOS
from PIL import Image, ImageDraw, ImageFont, ImageFilter

W, H, FPS = 1920, 1080, 25
BRAUN, HELL, AMBER = (0x3B, 0x40, 0x21), (0xF4, 0xED, 0xD8), (0xD9, 0x8E, 0x04)
FONT_B = '/usr/share/fonts/liberation-sans-fonts/LiberationSans-Bold.ttf'
FONT_R = '/usr/share/fonts/liberation-sans-fonts/LiberationSans-Regular.ttf'
SPRECHER_PY = os.path.expanduser('~/sprachlern-ki/.venv/bin/python')


def bildpfad(name):
    repo = os.path.abspath(os.path.join(HERE, '..', '..'))
    for p in (f'../praesentation/bilder/{name}.jpg', f'../handbuch/bilder/annot/{name}.png', f'../handbuch/bilder/roh/{name}.png',
              f'../praesentation/bilder/{name}.png'):
        if os.path.exists(os.path.join(HERE, p)):
            return os.path.join(HERE, p)
    webp = os.path.join(repo, 'admin', 'public', 'docs', name + '.webp')
    if os.path.exists(webp):
        return webp
    raise FileNotFoundError(name)


def font(pfad, px):
    return ImageFont.truetype(pfad, px)


def umbruch(draw, text, f, breite):
    zeilen, cur = [], ''
    for wort in text.split():
        t = (cur + ' ' + wort).strip()
        if draw.textlength(t, font=f) <= breite:
            cur = t
        else:
            zeilen.append(cur); cur = wort
    if cur:
        zeilen.append(cur)
    return zeilen


def rahmen(video_titel, szene_titel):
    img = Image.new('RGB', (W, H), HELL)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, W, 84], fill=BRAUN)
    d.text((48, 42), 'NOMAD', font=font(FONT_B, 40), fill='white', anchor='lm')
    d.text((W - 48, 42), video_titel, font=font(FONT_R, 30), fill=HELL, anchor='rm')
    if szene_titel:
        d.rectangle([0, H - 112, W, H], fill=BRAUN)
        d.rectangle([0, H - 112, 18, H], fill=AMBER)
        d.text((60, H - 56), szene_titel, font=font(FONT_B, 48), fill='white', anchor='lm')
    return img


def bildszene(video_titel, sz):
    img = rahmen(video_titel, sz.get('titel'))
    pic = Image.open(bildpfad(sz['bild'])).convert('RGB')
    maxw, maxh = W - 160, H - 84 - 112 - 60
    s = min(maxw / pic.width, maxh / pic.height)
    pic = pic.resize((int(pic.width * s), int(pic.height * s)), Image.LANCZOS)
    x, y = (W - pic.width) // 2, 84 + 30 + (maxh - pic.height) // 2
    schatten = Image.new('RGBA', (pic.width + 40, pic.height + 40), (0, 0, 0, 0))
    ImageDraw.Draw(schatten).rectangle([20, 20, pic.width + 20, pic.height + 20], fill=(0, 0, 0, 90))
    schatten = schatten.filter(ImageFilter.GaussianBlur(10))
    img.paste(schatten, (x - 20, y - 14), schatten)
    img.paste(pic, (x, y))
    ImageDraw.Draw(img).rectangle([x - 1, y - 1, x + pic.width, y + pic.height], outline=(0xBB, 0xBB, 0xBB), width=2)
    return img


def kartenszene(video_titel, sz):
    k = sz['karte']
    img = rahmen(video_titel, sz.get('titel'))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([160, 140, W - 160, H - 150], radius=28, fill='white', outline=BRAUN, width=5)
    ft, fp = font(FONT_B, 78), font(FONT_R, 58)
    y = 190
    for z in umbruch(d, k['titel'], ft, W - 400):
        d.text((220, y), z, font=ft, fill=BRAUN); y += 86
    y += 24
    for p in k['punkte']:
        zl = umbruch(d, p, fp, W - 480)
        d.ellipse([228, y + 24, 248, y + 44], fill=AMBER)
        for z in zl:
            d.text((275, y), z, font=fp, fill=(0x1D, 0x1D, 0x1D)); y += 72
        y += 18
    return img


def dauer(wav):
    with wave.open(wav) as w:
        return w.getnframes() / w.getframerate()


def run(cmd):
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def srt_zeit(t):
    h, r = divmod(t, 3600); m, s = divmod(r, 60)
    return '%02d:%02d:%02d,%03d' % (h, m, int(s), int((s - int(s)) * 1000))


def saetze(text):
    return [t for t in re.split(r'(?<=[.!?:])\s+', text.strip()) if t]


def baue(key):
    v = VIDEOS[key]
    arbeit = os.path.join(HERE, 'arbeit', v['name'])
    os.makedirs(arbeit, exist_ok=True)
    os.makedirs(os.path.join(HERE, 'ausgabe'), exist_ok=True)
    spec = os.path.join(arbeit, 'szenen.json')
    json.dump(dict(video=v['name'], szenen=[dict(id=s['id'], text=s['text']) for s in v['szenen']]), open(spec, 'w'), ensure_ascii=False)
    audio_dir = os.path.join(arbeit, 'audio')
    subprocess.run([SPRECHER_PY, os.path.join(HERE, 'sprecher.py'), spec, audio_dir], check=True)
    clips, srt, t0, nr = [], [], 0.0, 1
    for s in v['szenen']:
        frame = os.path.join(arbeit, s['id'] + '.png')
        (kartenszene if 'karte' in s else bildszene)(v['titel'], s).save(frame)
        wav = os.path.join(audio_dir, s['id'] + '.wav')
        d = dauer(wav) + 0.6
        clip = os.path.join(arbeit, s['id'] + '.mp4')
        n = int(d * FPS)
        zoom = "zoompan=z='1+0.00025*on':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=%d:s=%dx%d:fps=%d" % (n, W, H, FPS)
        run(['ffmpeg', '-y', '-loop', '1', '-t', '%.2f' % d, '-i', frame, '-i', wav, '-vf', zoom + ',format=yuv420p', '-af', 'apad',
             '-t', '%.2f' % d, '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-c:a', 'aac', '-b:a', '160k', '-ar', '44100', '-ac', '2', clip])
        clips.append(clip)
        # Untertitel: Sätze anteilig nach Wortzahl auf die Sprechdauer verteilen
        sa = saetze(s['text'])
        gew = [max(1, len(x.split())) for x in sa]
        sprech = d - 0.6
        pos = t0
        for x, g in zip(sa, gew):
            dd = sprech * g / sum(gew)
            srt.append('%d\n%s --> %s\n%s\n' % (nr, srt_zeit(pos), srt_zeit(pos + dd), x)); nr += 1
            pos += dd
        t0 += d
    liste = os.path.join(arbeit, 'liste.txt')
    open(liste, 'w').write(''.join("file '%s'\n" % c for c in clips))
    srtdatei = os.path.join(HERE, 'ausgabe', v['name'] + '.srt')
    open(srtdatei, 'w', encoding='utf-8').write('\n'.join(srt))
    roh = os.path.join(arbeit, 'roh.mp4')
    run(['ffmpeg', '-y', '-f', 'concat', '-safe', '0', '-i', liste, '-c', 'copy', roh])
    ziel = os.path.join(HERE, 'ausgabe', v['name'] + '.mp4')
    run(['ffmpeg', '-y', '-i', roh, '-i', srtdatei, '-c', 'copy', '-c:s', 'mov_text', '-metadata:s:s:0', 'language=deu',
         '-metadata', 'title=' + v['titel'], '-movflags', '+faststart', ziel])
    print(ziel, '%d Szenen, %.1f min' % (len(clips), t0 / 60))


if __name__ == '__main__':
    for k in (sys.argv[1:] or list(VIDEOS)):
        baue(k)
