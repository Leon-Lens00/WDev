"""Strategy title v9v (Dev Mission title, 29/10/2026): "Fase de estrategia" with its ornaments in one texture instead
of v9t's two halves (StratTitleL/R), which the user saw split. The mockup's box (505-1290 x 22-82, alpha from the red
channel as texturas_v9t.py) is cut at 1:1 and stretched to 512 x 64 (the game draws it back at 785 x 60).

Usage: texturas_v9v.py MOCKUP OUT_DIR
"""
from pathlib import Path
import json, sys
import numpy as np
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent))
import texturas_heroe as th
import texturas_v9t as t9

BOX = (505, 1290, 22, 82)

if __name__ == '__main__':
    a = np.asarray(Image.open(sys.argv[1]).convert('RGB')).astype(float)
    OUT = Path(sys.argv[2])
    OUT.mkdir(parents=True, exist_ok=True)
    x0, x1, y0, y1 = BOX
    im = t9.piece(a, BOX, (x1 - x0, y1 - y0), None, []).resize((512, 64), Image.Resampling.LANCZOS)
    im.save(OUT / 'StratTitle.png')
    report = {'StratTitle': {'blp_sha256': th.blp(im, OUT / 'StratTitle.blp')}}
    (OUT / 'v9v.json').write_text(json.dumps(report, indent=1))
    print('ok', json.dumps(report))
