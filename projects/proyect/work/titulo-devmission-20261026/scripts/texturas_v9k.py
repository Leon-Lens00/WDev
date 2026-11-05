"""Hero/boss select v9k textures (Dev Mission title, 29/10/2026).

The user asked for the hero select on the Start screen's animated background, like the boss select, and for a
cell under the mouse to light up like a mode box does (the mode screen swaps in a bright copy of the box):
- CellHi (128, alpha): v9i's CellFrame recoloured as the mode screen's active box (dark blue metal -> cyan ->
  white) with a soft cyan halo from its own alpha; drawn over the cell's frame, transparent inside like it;
- HeroTitleL/R (512 x 128): the hero mockup's title and its two ornament lines at 1:1, alpha from the red channel
  (the lettering is near white, the nebula behind it saturated blue), as BossTitleL/R;
- HeroPanelT/B (512 x 512 each, stretched): the portrait panel with Lock in (mockup x 1222-1592, y 198-808), from
  the mockup as cleaned by texturas_heroe.clean with the portrait window emptied (texturas_v9i.clear_portrait),
  split at y 503; opaque inside the frame (x 1236-1578, y 214-795), outside it alpha from the red channel.
"Tiempo de seleccion" is BossLabel (same place in both mockups).

Usage: texturas_v9k.py HERO_MOCKUP CELLFRAME_PNG OUT_DIR
"""
from pathlib import Path
import json, sys
import numpy as np
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent))
import texturas_heroe as th
from texturas_v9i import clear_portrait
from nebulosa_limpia import gauss

TITLES = [('HeroTitleL', (505, 898, 15, 79)), ('HeroTitleR', (898, 1290, 15, 79))]
PANEL = (1222, 1592, 198, 808)
INSIDE = (1236, 1578, 214, 795)
SPLIT = 503


def rgba(rgb, alpha):
    return Image.fromarray(np.dstack([np.clip(rgb, 0, 255), np.clip(alpha, 0, 1) * 255]).round().astype(np.uint8), 'RGBA')


def cell_hi(frame):
    f = np.asarray(frame).astype(float)
    al = f[..., 3] / 255
    lum = f[..., :3].mean(2) / 255
    # Dark metal -> deep blue, mid -> cyan, highlights -> white, as the active mode box's edges.
    stops = np.array([[0.0, 20, 40, 110], [0.35, 40, 120, 230], [0.65, 110, 220, 255], [1.0, 255, 255, 255]])
    rgb = np.stack([np.interp(np.clip(lum * 1.35, 0, 1), stops[:, 0], stops[:, c]) for c in (1, 2, 3)], -1)
    halo = np.clip(gauss(al, 3.5) * 1.3, 0, 0.75)
    a = np.maximum(al, halo)
    w = np.where(a > 0, al / np.maximum(a, 1e-6), 0)[..., None]
    rgb = rgb * w + np.array([70, 190, 255]) * (1 - w)
    return rgba(rgb, a)


if __name__ == '__main__':
    a = np.asarray(Image.open(sys.argv[1]).convert('RGB')).astype(float)
    OUT = Path(sys.argv[3])
    OUT.mkdir(parents=True, exist_ok=True)
    report = {}

    hi = cell_hi(Image.open(sys.argv[2]).convert('RGBA'))
    hi.save(OUT / 'CellHi.png')
    report['CellHi'] = {'blp_sha256': th.blp(hi, OUT / 'CellHi.blp')}

    for nm, (x0, x1, y0, y1) in TITLES:
        src = a[y0:y1, x0:x1]
        t = np.zeros((128, 512, 4))
        ox, oy = (512 - (x1 - x0)) // 2, (128 - (y1 - y0)) // 2
        t[oy:oy + y1 - y0, ox:ox + x1 - x0, :3] = src
        t[oy:oy + y1 - y0, ox:ox + x1 - x0, 3] = np.clip((src[..., 0] - 45) / 100, 0, 1) * 255
        im = Image.fromarray(t.round().astype(np.uint8), 'RGBA')
        im.save(OUT / f'{nm}.png')
        report[nm] = {'blp_sha256': th.blp(im, OUT / f'{nm}.blp'), 'centre_screen': [(x0 + x1) / 2 + 80, (y0 + y1) / 2 + 15]}

    c = clear_portrait(np.clip(th.clean(a), 0, 255))
    x0, x1, y0, y1 = PANEL
    al = np.clip((c[..., 0] - 45) / 100, 0, 1)
    ix0, ix1, iy0, iy1 = INSIDE
    al[iy0:iy1, ix0:ix1] = 1
    for nm, (p0, p1) in (('HeroPanelT', (y0, SPLIT)), ('HeroPanelB', (SPLIT, y1))):
        im = rgba(c[p0:p1, x0:x1], al[p0:p1, x0:x1]).resize((512, 512), Image.Resampling.LANCZOS)
        im.save(OUT / f'{nm}.png')
        report[nm] = {'blp_sha256': th.blp(im, OUT / f'{nm}.blp'), 'size_px': [x1 - x0, p1 - p0],
                      'centre_screen': [(x0 + x1) / 2 + 80, (p0 + p1) / 2 + 15]}

    prev = Image.new('RGBA', (1920, 1024), (8, 10, 30, 255))
    for nm, (x0_, x1_, y0_, y1_) in TITLES:
        prev.alpha_composite(Image.open(OUT / f'{nm}.png'), (int((x0_ + x1_) / 2 + 80 - 256), int((y0_ + y1_) / 2 + 15 - 64)))
    for nm in ('HeroPanelT', 'HeroPanelB'):
        w, h = report[nm]['size_px']
        cx, cy = report[nm]['centre_screen']
        prev.alpha_composite(Image.open(OUT / f'{nm}.png').resize((w, h)), (int(cx - w / 2), int(cy - h / 2)))
    fr = Image.open(sys.argv[2]).convert('RGBA').resize((96, 96))
    prev.alpha_composite(fr, (300, 300))
    prev.alpha_composite(fr, (420, 300))
    prev.alpha_composite(hi.resize((96, 96)), (420, 300))
    prev.convert('RGB').save(OUT / 'previa-v9k.png')
    (OUT / 'v9k.json').write_text(json.dumps(report, indent=1))
    print('ok', sorted(report))
