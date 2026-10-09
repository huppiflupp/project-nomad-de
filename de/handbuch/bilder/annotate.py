#!/usr/bin/env python3
"""Liest annot.json und schreibt beschriftete Bilder nach annot/<name>.png.
Rahmen: #c0392b, 4 px. Marken: roter Kreis (34 px) mit weisser, fetter Zahl.
Koordinaten beziehen sich auf das Originalbild (vor dem Beschneiden)."""
import json, os, sys
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
RED = (0xC0, 0x39, 0x2B)
FONTS = ["/usr/share/fonts/dejavu-sans-fonts/DejaVuSans-Bold.ttf",
         "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
         "/usr/share/fonts/liberation-sans/LiberationSans-Bold.ttf",
         "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"]

def font(size):
    for f in FONTS:
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    try:
        return ImageFont.load_default(size)
    except TypeError:
        return ImageFont.load_default()

def main():
    with open(os.path.join(HERE, "annot.json"), encoding="utf-8") as fh:
        data = json.load(fh)
    out = os.path.join(HERE, "annot")
    os.makedirs(out, exist_ok=True)
    scale = 4  # Überabtastung für glatte Kreise
    for name, a in data.items():
        src = os.path.join(HERE, "roh", name + ".png")
        if not os.path.exists(src):
            print("fehlt:", src, file=sys.stderr)
            continue
        im = Image.open(src).convert("RGB")
        d = ImageDraw.Draw(im)
        for x, y, w, h in a.get("boxes", []):
            d.rectangle([x, y, x + w - 1, y + h - 1], outline=RED, width=4)
        marks = a.get("marks", [])
        if marks:
            r = 17
            big = Image.new("RGBA", (im.width * scale, im.height * scale), (0, 0, 0, 0))
            bd = ImageDraw.Draw(big)
            f = font(20 * scale)
            for m in marks:
                cx, cy = m["x"] * scale, m["y"] * scale
                bd.ellipse([cx - r * scale, cy - r * scale, cx + r * scale, cy + r * scale], fill=RED)
                bd.text((cx, cy), str(m["n"]), font=f, fill="white", anchor="mm")
            big = big.resize(im.size, Image.LANCZOS)
            im.paste(big, (0, 0), big)
        if "crop" in a:
            x, y, w, h = a["crop"]
            im = im.crop((x, y, x + w, y + h))
        im.save(os.path.join(out, name + ".png"))
        print("annot/%s.png" % name)

if __name__ == "__main__":
    main()
