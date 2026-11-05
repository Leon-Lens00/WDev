"""Title Start button and rhombuses in the nebula/logo palette (Dev Mission title v8e, 28/10/2026).

The user asked for the gold outlines of the Start button and the eight rhombuses (texturas-maqueta, from their
mockup) to match the nebula and the new logo: silver steel with ice-blue highlights and violet shadows. Only
gold pixels (hue 18-70, saturation over 0.2) are changed; their value is kept and the hue goes from violet in
the shadows to ice blue in the highlights, with low saturation (steel). The Start text, gold too, becomes the
same pale ice blue. Alpha, the blue face of the button and the crystals are untouched.

The rhombus frames are not the same mask for every texture: 1-4 and the grey one are separate crops of the
mockup, so each one uses its own gold mask; 5-8 are the blue one (2) with the crystal hue turned, so the yellow
(5) and orange (6) crystals, which are gold-hued too, are protected by changing only what lies on rhombus 2's
frame mask (grown by one pixel).

Usage: texturas_paleta.py IN_DIR OUT_DIR
"""
from pathlib import Path
import json, sys
import numpy as np
from PIL import Image, ImageFilter
import matplotlib.colors as mc
sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts')
from grid import blp

SRC, OUT = Path(sys.argv[1]), Path(sys.argv[2])
NAMES = ['TitleStart', 'TitleStartHover', 'TitleGemGrey'] + [f'TitleGem{n}' for n in range(1, 9)]


def load(name):
    return np.asarray(Image.open(SRC / f'{name}.png').convert('RGBA'), float) / 255


def gold(a):
    h = mc.rgb_to_hsv(a[..., :3])
    return (a[..., 3] > 0.02) & (h[..., 0] * 360 > 18) & (h[..., 0] * 360 < 70) & (h[..., 1] > 0.2)


def steel(a, mask):
    h = mc.rgb_to_hsv(a[..., :3])
    v = h[..., 2]
    nh = (265 - 55 * np.clip(v * 1.15, 0, 1)) / 360
    ns = 0.12 + 0.3 * h[..., 1]
    nv = np.clip(v * 1.08, 0, 1)
    rgb = mc.hsv_to_rgb(np.dstack([nh, ns, nv]))
    out = a.copy()
    out[mask, :3] = rgb[mask]
    return out


if __name__ == '__main__':
    OUT.mkdir(parents=True, exist_ok=True)
    frame2 = gold(load('TitleGem2'))
    frame2 = np.asarray(Image.fromarray(frame2.astype(np.uint8) * 255).filter(ImageFilter.MaxFilter(3))) > 0
    report = {}
    for name in NAMES:
        a = load(name)
        mask = gold(a)
        if name in ('TitleGem5', 'TitleGem6'):
            mask &= frame2
        out = steel(a, mask)
        im = Image.fromarray((out * 255).round().clip(0, 255).astype(np.uint8), 'RGBA')
        im.save(OUT / f'{name}.png')
        report[name] = {'changed_pixels': int(mask.sum()), 'size': list(im.size), 'blp_sha256': blp(im, OUT / f'{name}.blp')}
    (OUT / 'paleta.json').write_text(json.dumps(report, indent=1))
    sheet = Image.new('RGBA', (1200, 300), (10, 10, 25, 255))
    x = 10
    for name in NAMES:
        im = Image.open(OUT / f'{name}.png')
        im.thumbnail((200 if 'Start' in name else 90, 140))
        sheet.alpha_composite(im, (x, 10 if 'Start' in name else 160))
        x = x + im.width + 10 if 'Start' in name else x + 100
        if name == 'TitleStartHover':
            x = 10
    sheet.convert('RGB').save(OUT / 'previa.png')
    print(json.dumps({k: v['changed_pixels'] for k, v in report.items()}))
