"""Boss select textures (Dev Mission title v9j, 29/10/2026).

From the user's boss mockup (fuentes/seleccion-boss-maqueta.webp, 1774 x 887, same frame as the hero one):
- BossTitleL/R, BossLabel, BossOrnL/R: the mockup's title, "Tiempo de seleccion" and the name's ornaments as
  pictures; the user asked for the Start screen's animated background under them (from_hero and background(),
  two earlier static backgrounds, are kept but unused). background() is the mockup without what the screen draws as pieces: the 40 cells (they fly in from the hero
  screen), the 8 slots, the clock digits, the sphere with the hydra (a 3D effect and a picture) and the text
  "Nombre del boss" (BossName); title, its ornaments, "Tiempo de seleccion" and the name's ornaments stay.
  Filled as nebulosa_limpia.fill, detail from a dark strip between the left cells and the sphere;
- BossName (256 x 128): "Nereus", the boss's name in Dev Us Dimensional v0.76a (TRIGSTR_1025), made from the
  mockup's own glyphs: N, e, r, e, s from "Nombre del boss" and u as the n of "Seleccion" turned 180 degrees,
  scaled to the name's x-height; alpha from brightness;
- BossNereus (512, alpha): Dev Us's boss card FOnBOss.blp (350 x 350, no alpha) resized, cut to its circle;
- BTNHydra: Dev Us's button, 64 x 64, as it is (copied, not converted).

Usage: texturas_boss.py MOCKUP DEVUS_EXTRAIDO OUT_DIR
"""
from pathlib import Path
import json, shutil, sys
import numpy as np
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent))
import texturas_heroe as th
from nebulosa_limpia import fill

LEFT = [73, 232, 391]
RIGHT = [1383, 1542, 1700]
ROWS = [263, 368, 474, 580, 683]
BOTTOM = ([291, 425, 559, 694, 828, 956, 1089, 1222, 1356, 1487], 795)
SPHERE = (888, 404, 228)
NAME_BOX = (664, 1116, 626, 706)
DONOR = (455, 640, 180, 640)
NAME = {'N': (672, 716), 'e': (859, 883), 'r': (832, 856), 'e2': (936, 962), 's': (1063, 1084)}
NAME_Y = (626, 706)
TITLE_N = ((880, 906), (20, 72))
# Lettering kept as pictures: name, mockup box (x0, x1, y0, y1), texture size.
PIECES = [('BossTitleL', (505, 898, 22, 82), (512, 128)), ('BossTitleR', (898, 1290, 22, 82), (512, 128)),
          ('BossLabel', (802, 972, 147, 175), (256, 32)), ('BossOrnL', (500, 664, 645, 695), (256, 64)),
          ('BossOrnR', (1116, 1280, 645, 695), (256, 64))]


def background(a):
    m = np.zeros(a.shape[:2], bool)

    def box(x0, x1, y0, y1):
        m[max(0, int(y0)):int(y1), max(0, int(x0)):int(x1)] = True
    for y in ROWS:
        for x in LEFT + RIGHT:
            box(x - 56, x + 56, y - 56, y + 56)
    xs, y = BOTTOM
    for x in xs:
        box(x - 60, x + 60, y - 60, y + 60)
    for x in th.SLOTS:
        box(x - 52, x + 52, 78, 176)
    yy, xx = np.mgrid[:a.shape[0], :a.shape[1]]
    cx, cy, r = SPHERE
    m |= (xx - cx) ** 2 + (yy - cy) ** 2 < r * r
    box(*NAME_BOX[:2], *NAME_BOX[2:])
    out = np.clip(fill(a, m, DONOR), 0, 255)
    th.diffuse(out, 826, 944, 92, 139)
    return out


def from_hero(hero, a):
    """The hero screen's own background (v9i HeroFondoPiezas.png: no cells, slots or portrait), as the user asked:
    its title filled and the mockup's "Seleccion de boss" laid over it, the portrait panel filled, detail from the
    nebula right of it, the name's two ornaments from the mockup; alpha from brightness."""
    m = np.zeros(hero.shape[:2], bool)
    m[18:84, 500:1295] = True
    out = np.clip(fill(hero, m, (300, 1150, 178, 220)), 0, 255)
    m[:] = False
    m[188:820, 1210:1604] = True
    out = np.clip(fill(out, m, (1606, 1772, 150, 860)), 0, 255)
    for x0, x1, y0, y1 in ((500, 1295, 18, 84), (490, 668, 650, 704), (1112, 1290, 650, 704)):
        src = a[y0:y1, x0:x1]
        al = np.clip((src.max(2) - 45) / 110, 0, 1)[..., None]
        out[y0:y1, x0:x1] = src * al + out[y0:y1, x0:x1] * (1 - al)
    return out


def glyph(a, x0, x1, y0, y1, pad=3):
    return a[y0:y1, x0 - pad:x1 + pad]


def name(a):
    y0, y1 = NAME_Y
    parts = [glyph(a, *NAME['N'], y0, y1), glyph(a, *NAME['e'], y0, y1), glyph(a, *NAME['r'], y0, y1),
             glyph(a, *NAME['e2'], y0, y1)]
    # u: the title's n turned round, scaled from the title's x-height to the name's (n 26 -> e of the name).
    (nx0, nx1), (ty0, ty1) = TITLE_N
    n = a[ty0:ty1, nx0 - 3:nx1 + 3]
    lit = n.max(2) > 110
    rows = np.where(lit.any(1))[0]
    n = n[rows.min():rows.max() + 1]
    e = a[y0:y1, NAME['e'][0]:NAME['e'][1]].max(2) > 110
    er = np.where(e.any(1))[0]
    k = (er.max() - er.min() + 1) / n.shape[0]
    u = np.asarray(Image.fromarray(n.astype(np.uint8)).rotate(180).resize(
        (int(round(n.shape[1] * k)), int(round(n.shape[0] * k))), Image.Resampling.LANCZOS)).astype(float)
    cell = np.zeros((y1 - y0, u.shape[1], 3))
    top = er.min()
    cell[top:top + u.shape[0]] = u[:y1 - y0 - top]
    parts.append(cell)
    parts.append(glyph(a, *NAME['s'], y0, y1))
    rgb = np.concatenate(parts, 1)
    alpha = np.clip((rgb[..., 0] - 35) / 100, 0, 1)
    h, w = rgb.shape[:2]
    canvas = np.zeros((128, 256, 4))
    ox, oy = (256 - w) // 2, (128 - h) // 2
    canvas[oy:oy + h, ox:ox + w, :3] = rgb
    canvas[oy:oy + h, ox:ox + w, 3] = alpha * 255
    return Image.fromarray(canvas.round().astype(np.uint8), 'RGBA'), w


def card(src):
    im = Image.open(src).convert('RGB').resize((512, 512), Image.Resampling.LANCZOS)
    d = np.hypot(*np.mgrid[:512, :512] - 255.5)
    alpha = np.clip((255 - d) / 6, 0, 1) * 255
    return Image.fromarray(np.dstack([np.asarray(im), alpha]).round().astype(np.uint8), 'RGBA')


if __name__ == '__main__':
    a = np.asarray(Image.open(sys.argv[1]).convert('RGB')).astype(float)
    devus, OUT = Path(sys.argv[2]), Path(sys.argv[3])
    OUT.mkdir(parents=True, exist_ok=True)
    report = {}
    # The user asked for the Start screen's animated background under the boss select: no BossBg, only the
    # mockup's lettering as pictures at 1:1 (alpha from brightness), centred in power-of-two textures.
    for nm, (x0, x1, y0, y1), size in PIECES:
        src = a[y0:y1, x0:x1]
        # red, not brightness: the lettering is near white, the nebula behind it saturated blue.
        al = np.clip((src[..., 0] - 45) / 100, 0, 1) * 255
        t = np.zeros((size[1], size[0], 4))
        ox, oy = (size[0] - (x1 - x0)) // 2, (size[1] - (y1 - y0)) // 2
        t[oy:oy + y1 - y0, ox:ox + x1 - x0, :3] = src
        t[oy:oy + y1 - y0, ox:ox + x1 - x0, 3] = al
        im = Image.fromarray(t.round().astype(np.uint8), 'RGBA')
        im.save(OUT / f'{nm}.png')
        report[nm] = {'blp_sha256': th.blp(im, OUT / f'{nm}.blp'), 'centre_screen': [(x0 + x1) / 2 + 80, (y0 + y1) / 2 + 15]}
    nm_im, width = name(a)
    nm_im.save(OUT / 'BossName.png')
    report['BossName'] = {'blp_sha256': th.blp(nm_im, OUT / 'BossName.blp'), 'width_px': width}
    c = card(devus / 'FOnBOss.blp')
    c.save(OUT / 'BossNereus.png')
    report['BossNereus'] = {'blp_sha256': th.blp(c, OUT / 'BossNereus.blp')}
    shutil.copyfile(devus / 'war3mapImported' / 'BTNHydra.blp', OUT / 'BTNHydra.blp')

    prev = Image.new('RGBA', (1920, 1024), (8, 10, 30, 255))
    for nm, (x0, x1, y0, y1), size in PIECES:
        im = Image.open(OUT / f'{nm}.png')
        prev.alpha_composite(im, (int((x0 + x1) / 2 + 80 - size[0] / 2), int((y0 + y1) / 2 + 15 - size[1] / 2)))
    prev.alpha_composite(c.resize((356, 356)), (int(968 - 178), int(417 - 178)))
    prev.alpha_composite(nm_im, (970 - 128, 678 - 64))
    prev.convert('RGB').save(OUT / 'previa-boss.png')
    (OUT / 'v9j.json').write_text(json.dumps(report, indent=1))
    print('ok', sorted(report), width)
