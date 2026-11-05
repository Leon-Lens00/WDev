"""Emblem textures of the presentation v9w (Dev Mission title, 29/10/2026): the user's three emblem parts
(fuentes/presentacion/emblema/..., 1254 x 1254 PNG with alpha: ring, triangle, W) each cut to its visible content
(alpha > 32) and stretched to 512 x 512. The game draws each at the size and place the package README gives for
the approved composition in a 1280 canvas (ring 75,80 1110x1070; triangle 230,375 800x660; W 280,325 695x585),
scaled by K around the canvas centre.

Usage: texturas_v9w.py EMBLEM_DIR OUT_DIR
"""
from pathlib import Path
import json, sys
import numpy as np
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent))
import texturas_heroe as th

PARTS = [('PresAro', '01-aro.png', (75, 80, 1110, 1070)), ('PresTri', '02-triangulo.png', (230, 375, 800, 660)),
         ('PresW', '03-W.png', (280, 325, 695, 585))]
K = 700 / 1110
CENTRE = (961.0, 430.0)

if __name__ == '__main__':
    src, OUT = Path(sys.argv[1]), Path(sys.argv[2])
    OUT.mkdir(parents=True, exist_ok=True)
    report = {}
    for name, fn, (x, y, w, h) in PARTS:
        im = Image.open(src / fn).convert('RGBA')
        a = np.asarray(im)[..., 3]
        ys, xs = np.nonzero(a > 32)
        crop = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1)).resize((512, 512), Image.Resampling.LANCZOS)
        crop.save(OUT / f'{name}.png')
        report[name] = {'blp_sha256': th.blp(crop, OUT / f'{name}.blp'),
                        'content_box': [int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1],
                        'screen_centre': [round(CENTRE[0] + (x + w / 2 - 640) * K, 1), round(CENTRE[1] + (y + h / 2 - 640) * K, 1)],
                        'screen_size': [round(w * K, 1), round(h * K, 1)]}
    (OUT / 'v9w.json').write_text(json.dumps(report, indent=1))
    print(json.dumps(report, indent=1))
