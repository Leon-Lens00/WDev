"""Hero select v9i textures: cells as pieces (Dev Mission title, 29/10/2026).

The user asked that a cell's frame have a transparent inside, with the dark "?" square under it by default and a
game icon under it once a hero is set; the top slots' glow the same as a chosen cell's; Lock in lit under the
mouse; the panel's portrait from the UI system (a 3D model, so the mockup's picture goes). From the mockup as
cleaned by texturas_heroe.clean:
- HeroBg0-7: no cells (nebulosa_limpia.without_cells), no slots (their frames and painted glows filled like the
  cells), the portrait window's picture replaced by the panel's own empty inside (same x, rows 490-665);
- CellQ (128, alpha): a plain cell (column 2, row 0), 96 px around its centre, opaque inside its frame box
  (x/y 8-89 of the 96), so it can go anywhere;
- CellFrame (128, alpha): the same crop, only the frame: the 8-18 px band of the box opaque, elsewhere alpha from
  brightness, the "?" area (24-72 x 22-74) cleared, so what is under the frame shows through;
- LockGlow (512 x 128): Lock in (mockup x 1222-1596, y 700-814) brightened and blurred, cyan, drawn additively.
BLP as texturas_heroe.blp (paletted, dithered).

Usage: texturas_v9i.py MOCKUP OUT_DIR
"""
from pathlib import Path
import json, sys
import numpy as np
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent))
import texturas_heroe as th
from nebulosa_limpia import without_cells, fill, gauss

CELL = (217 + 113.89 * 2, 274)
LOCK = (1222, 1596, 700, 814)
PORTRAIT = (1258, 1556, 291, 467)


def clear_slots(c):
    m = np.zeros(c.shape[:2], bool)
    for x in th.SLOTS:
        m[78:176, int(x - 52):int(x + 52)] = True
    return np.clip(fill(c, m, (300, 1150, 178, 220)), 0, 255)


def clear_portrait(c):
    x0, x1, y0, y1 = PORTRAIT
    out = c.copy()
    out[y0:y1, x0:x1] = c[490:490 + (y1 - y0), x0:x1]
    return out


def cell_crop(c):
    x, y = int(round(CELL[0])), int(round(CELL[1]))
    return c[y - 48:y + 48, x - 48:x + 48]


def rgba(rgb, alpha, size):
    im = Image.fromarray(np.dstack([np.clip(rgb, 0, 255), np.clip(alpha, 0, 1) * 255]).round().astype(np.uint8), 'RGBA')
    return im.resize(size, Image.Resampling.LANCZOS)


if __name__ == '__main__':
    OUT = Path(sys.argv[2])
    OUT.mkdir(parents=True, exist_ok=True)
    a = np.asarray(Image.open(sys.argv[1]).convert('RGB')).astype(float)
    c = th.clean(a)
    report = {}

    crop = cell_crop(c)
    i = np.arange(96)
    box = ((i >= 8) & (i <= 89)).astype(float)
    q_alpha = np.minimum.outer(box, box)
    report['CellQ'] = {'blp_sha256': th.blp(rgba(crop, q_alpha, (128, 128)), OUT / 'CellQ.blp')}
    lum = crop.mean(2)
    f_alpha = np.clip((lum - 20) / 60, 0, 1)
    outer, inner = (i >= 8) & (i <= 89), (i >= 19) & (i <= 78)
    ring = np.logical_and.outer(outer, outer) & ~np.logical_and.outer(inner, inner)
    f_alpha[ring] = 1
    f_alpha[22:75, 24:73] = 0
    frame = rgba(crop, f_alpha, (128, 128))
    report['CellFrame'] = {'blp_sha256': th.blp(frame, OUT / 'CellFrame.blp')}
    frame.save(OUT / 'CellFrame.png')

    x0, x1, y0, y1 = LOCK
    b = c[y0:y1, x0:x1]
    bright = np.clip((b.max(2) - 40) / 180, 0, 1)
    glow = np.clip(gauss(bright, 5) * 1.6 + bright * 0.5, 0, 1)
    tint = np.array([0.45, 0.8, 1.0]) * 255
    rgb = glow[..., None] * tint
    lock = Image.fromarray(rgb.round().astype(np.uint8)).resize((512, 128), Image.Resampling.LANCZOS).convert('RGBA')
    report['LockGlow'] = {'blp_sha256': th.blp(lock, OUT / 'LockGlow.blp')}
    lock.save(OUT / 'LockGlow.png')

    bg = clear_portrait(clear_slots(np.clip(without_cells(c), 0, 255)))
    Image.fromarray(bg.round().astype(np.uint8)).save(OUT / 'HeroFondoPiezas.png')
    ox, oy = th.OFFSET
    big = np.pad(bg, ((oy, 1024 - oy - 887), (ox, 2048 - ox - 1774), (0, 0)), mode='reflect')
    for j in range(2):
        for k in range(4):
            name = f'HeroBg{j * 4 + k}'
            t = Image.fromarray(big[512 * j:512 * j + 512, 512 * k:512 * k + 512].round().astype(np.uint8)).convert('RGBA')
            report[name] = {'blp_sha256': th.blp(t, OUT / f'{name}.blp')}
    prev = Image.fromarray(big[:, :1920].round().astype(np.uint8)).convert('RGBA')
    q = rgba(crop, q_alpha, (96, 96))
    fr = frame.resize((96, 96), Image.Resampling.LANCZOS)
    for r in range(5):
        for col in range(8):
            px, py = int(208 + 142 * col) - 48, int(289 + 113.25 * r) - 48
            prev.alpha_composite(q, (px, py))
            prev.alpha_composite(fr, (px, py))
    for x in th.SLOTS:
        s = int(96 * 65 / 76)
        prev.alpha_composite(q.resize((s, s)), (int(x + 80 - s / 2), int(138.5 - s / 2)))
        prev.alpha_composite(fr.resize((s, s)), (int(x + 80 - s / 2), int(138.5 - s / 2)))
    prev.convert('RGB').save(OUT / 'previa-piezas.png')
    (OUT / 'v9i.json').write_text(json.dumps(report, indent=1))
    print('ok', sorted(report))
