"""Boss select v9q texture (Dev Mission title, 29/10/2026).

The user asked for the hero screen's pick button (Lock in) under the boss name. BossPick (512 x 128) is the hero
mockup's Lock in box as cleaned by texturas_heroe.clean, the same box as LockGlow (mockup x 1222-1596,
y 700-814) so the glow lies on it: opaque inside the button's frame (x 1236-1580, y 722-797), outside it alpha
from the red channel (metal near white, nebula saturated blue); the rows above 713 (the panel frame over the
button) are cut.

Usage: texturas_v9q.py HERO_MOCKUP OUT_DIR
"""
from pathlib import Path
import json, sys
import numpy as np
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent))
import texturas_heroe as th
from nebulosa_limpia import gauss

LOCK = (1222, 1596, 700, 814)
INSIDE = (1236, 1580, 722, 797)
TOP = 713

if __name__ == '__main__':
    a = np.asarray(Image.open(sys.argv[1]).convert('RGB')).astype(float)
    OUT = Path(sys.argv[2])
    OUT.mkdir(parents=True, exist_ok=True)
    c = np.clip(th.clean(a), 0, 255)
    x0, x1, y0, y1 = LOCK
    al = np.clip((c[..., 0] - 45) / 100, 0, 1)
    ix0, ix1, iy0, iy1 = INSIDE
    al[iy0:iy1, ix0:ix1] = 1
    al[:TOP] = 0
    rgba = np.dstack([c[y0:y1, x0:x1], al[y0:y1, x0:x1] * 255]).round().astype(np.uint8)
    im = Image.fromarray(rgba, 'RGBA').resize((512, 128), Image.Resampling.LANCZOS)
    im.save(OUT / 'BossPick.png')
    report = {'BossPick': {'blp_sha256': th.blp(im, OUT / 'BossPick.blp'), 'box_px': [x1 - x0, y1 - y0]}}

    # v9r: BossPickGlow, LockGlow's recipe (texturas_v9i.py) without the panel frame above the button, which the
    # user saw as an extra glow along the top.
    b = c[y0:y1, x0:x1]
    bright = np.clip((b.max(2) - 40) / 180, 0, 1)
    bright[:TOP - y0] = 0
    glow = np.clip(gauss(bright, 5) * 1.6 + bright * 0.5, 0, 1)
    rgb = glow[..., None] * (np.array([0.45, 0.8, 1.0]) * 255)
    g = Image.fromarray(rgb.round().astype(np.uint8)).resize((512, 128), Image.Resampling.LANCZOS).convert('RGBA')
    g.save(OUT / 'BossPickGlow.png')
    report['BossPickGlow'] = {'blp_sha256': th.blp(g, OUT / 'BossPickGlow.blp')}
    (OUT / 'v9q.json').write_text(json.dumps(report, indent=1))
    print('ok', report)
