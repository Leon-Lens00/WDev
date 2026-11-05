"""Strategy board textures v9t (Dev Mission title, 29/10/2026).

From the user's strategy mockup (fuentes/estrategia/estrategia-maqueta.webp, 1774 x 887, same frame as the boss and
hero ones: screen = mockup + (80, 15)) and their rock example (fuentes/estrategia/roca-esfera.png, a screenshot of
the rock character inside the sphere):
- StratTitleL/R, StratLabel, StratEnter: "Fase de estrategia" with its ornaments, "Tiempo de estrategia" and
  "Entrando a partida con:" as pictures at 1:1, alpha from the red channel (lettering near white, nebula blue), as
  texturas_boss.py PIECES;
- StratFrame: the portrait frame (mockup 714-1056 x 230-422); the Tauren picture inside is taken out (the game puts
  the hero select's 3D portrait there), the inside dark at alpha 0.85;
- StratInfoL/R: the information panel (546-1228 x 480-692) in two halves of 341 px; heading "Informacion" kept,
  the sample text under it painted over with the panel's dark (the game writes texttags there), inside at 0.85;
- StratRock (512): the rock screenshot cut to a circle inside the sphere's rim, as the boss card (BossNereus).

Usage: texturas_v9t.py MOCKUP ROCK OUT_DIR
"""
from pathlib import Path
import json, sys
import numpy as np
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent))
import texturas_heroe as th

DARK = np.array([1.0, 3.0, 12.0])
# name, mockup box (x0, x1, y0, y1), texture size, inside box (dark at 0.85) or None, boxes painted dark.
PIECES = [('StratTitleL', (505, 898, 22, 82), (512, 128), None, []),
          ('StratTitleR', (898, 1290, 22, 82), (512, 128), None, []),
          ('StratLabel', (795, 980, 146, 176), (256, 32), None, []),
          ('StratEnter', (738, 1036, 194, 228), (512, 64), None, []),
          ('StratFrame', (714, 1056, 230, 422), (512, 256), (733, 1037, 248, 404), [(733, 1037, 248, 404)]),
          ('StratInfoL', (546, 887, 480, 692), (512, 256), (564, 1208, 501, 663), [(570, 1202, 574, 655)]),
          ('StratInfoR', (887, 1228, 480, 692), (512, 256), (564, 1208, 501, 663), [(570, 1202, 574, 655)])]
# The rock screenshot's sphere: centre and the radius kept inside its rim.
ROCK = (190, 143, 112)


def piece(a, box, size, inside, dark):
    x0, x1, y0, y1 = box
    src = a.copy()
    al = np.clip((src[..., 0] - 45) / 100, 0, 1)
    if inside:
        ix0, ix1, iy0, iy1 = inside
        for dx0, dx1, dy0, dy1 in dark:
            src[dy0:dy1, dx0:dx1] = DARK
        sub = src[iy0:iy1, ix0:ix1]
        al[iy0:iy1, ix0:ix1] = np.maximum(np.clip((sub[..., 0] - 45) / 100, 0, 1), 0.85)
    t = np.zeros((size[1], size[0], 4))
    ox, oy = (size[0] - (x1 - x0)) // 2, (size[1] - (y1 - y0)) // 2
    t[oy:oy + y1 - y0, ox:ox + x1 - x0, :3] = src[y0:y1, x0:x1]
    t[oy:oy + y1 - y0, ox:ox + x1 - x0, 3] = al[y0:y1, x0:x1] * 255
    return Image.fromarray(t.round().astype(np.uint8), 'RGBA')


def rock(path):
    a = Image.open(path).convert('RGB')
    cx, cy, r = ROCK
    im = a.crop((cx - r, cy - r, cx + r, cy + r)).resize((512, 512), Image.Resampling.LANCZOS)
    d = np.hypot(*np.mgrid[:512, :512] - 255.5)
    alpha = np.clip((255 - d) / 6, 0, 1) * 255
    return Image.fromarray(np.dstack([np.asarray(im), alpha]).round().astype(np.uint8), 'RGBA')


if __name__ == '__main__':
    a = np.asarray(Image.open(sys.argv[1]).convert('RGB')).astype(float)
    OUT = Path(sys.argv[3])
    OUT.mkdir(parents=True, exist_ok=True)
    report = {}
    for nm, box, size, inside, dark in PIECES:
        im = piece(a, box, size, inside, dark)
        im.save(OUT / f'{nm}.png')
        x0, x1, y0, y1 = box
        report[nm] = {'blp_sha256': th.blp(im, OUT / f'{nm}.blp'),
                      'centre_screen': [(x0 + x1) / 2 + 80, (y0 + y1) / 2 + 15]}
    im = rock(sys.argv[2])
    im.save(OUT / 'StratRock.png')
    report['StratRock'] = {'blp_sha256': th.blp(im, OUT / 'StratRock.blp')}
    (OUT / 'v9t.json').write_text(json.dumps(report, indent=1))
    print('ok', json.dumps(report))
