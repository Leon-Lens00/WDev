"""Digits 0-9 for the mode select screen's countdown (Dev Mission title v8f, 28/10/2026).

In v8e the countdown was the title's texttag moved under the logo, but in game it showed over "MISSION",
about 120 px higher and 55 px further right than its point: texttag projection off the screen centre does not
follow the pictures' pixel mapping. The countdown is now drawn with pictures, which land where they are put.
Style of the nebula palette, as the reworked Start (texturas_paleta.py): ice-blue fill from white at the top to
blue at the bottom, dark navy outline and a soft violet glow (blended, 'uidb'). Every digit has the same
canvas, so they share baseline and centre; the quad gets back the canvas aspect in JASS (CANVAS below).

Usage: texturas_digitos.py OUT_DIR
"""
from pathlib import Path
import json, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont
sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts')
from grid import blp

OUT = Path(sys.argv[1])
FONT = '/usr/share/fonts/noto/NotoSerif-Bold.ttf'
CANVAS = (176, 256)          # aspect 0.6875, texture 64 x 128


def digit(ch):
    font = ImageFont.truetype(FONT, 190)
    w, h = CANVAS
    shape = Image.new('L', CANVAS, 0)
    d = ImageDraw.Draw(shape)
    d.text((w / 2, h / 2 + 4), ch, font=font, fill=255, anchor='mm')
    outline = Image.new('L', CANVAS, 0)
    ImageDraw.Draw(outline).text((w / 2, h / 2 + 4), ch, font=font, fill=255, anchor='mm', stroke_width=9,
                                 stroke_fill=255)
    glow = outline.filter(ImageFilter.GaussianBlur(10))
    y = np.linspace(0, 1, h)[:, None] * np.ones((1, w))
    top, mid, bot = np.array([255, 255, 255]), np.array([200, 228, 255]), np.array([92, 150, 255])
    fill = np.where(y[..., None] < 0.5, top + (mid - top) * (y[..., None] / 0.5),
                    mid + (bot - mid) * ((y[..., None] - 0.5) / 0.5))
    navy = np.array([14, 18, 52])
    violet = np.array([150, 90, 255])
    s = np.asarray(shape, float)[..., None] / 255
    o = np.asarray(outline, float)[..., None] / 255
    g = np.asarray(glow, float)[..., None] / 255 * 0.75
    rgb = fill * s + navy * (1 - s)
    a_core = np.maximum(s, o)
    rgb = np.where(a_core > 0, rgb, violet)
    alpha = np.maximum(a_core, g)
    img = np.dstack([rgb, alpha * 255]).round().clip(0, 255).astype(np.uint8)
    return Image.fromarray(img, 'RGBA')


if __name__ == '__main__':
    OUT.mkdir(parents=True, exist_ok=True)
    report = {}
    sheet = Image.new('RGBA', (10 * 90, 140), (10, 10, 25, 255))
    for n in range(10):
        im = digit(str(n))
        im.save(OUT / f'ModeDigit{n}-grande.png')
        tex = im.resize((64, 128), Image.Resampling.LANCZOS)
        tex.save(OUT / f'ModeDigit{n}.png')
        report[f'ModeDigit{n}'] = {'canvas': list(CANVAS), 'aspect': round(CANVAS[0] / CANVAS[1], 4),
                                   'texture': [64, 128], 'blp_sha256': blp(tex, OUT / f'ModeDigit{n}.blp')}
        th = im.copy()
        th.thumbnail((88, 128))
        sheet.alpha_composite(th, (n * 90, 6))
    sheet.convert('RGB').save(OUT / 'previa-digitos.png')
    (OUT / 'digitos.json').write_text(json.dumps(report, indent=1))
    print('ok', len(report))
