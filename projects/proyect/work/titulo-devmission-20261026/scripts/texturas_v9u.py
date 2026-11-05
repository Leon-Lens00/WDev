"""Information panel v9u (Dev Mission title, 29/10/2026): one texture instead of v9t's two halves, which showed a
seam (each half's edge filtered against its transparent padding). The mockup's panel (546-1228 x 480-692, as
texturas_v9t.py StratInfoL/R, inside dark at 0.85, the sample text painted over) is cut at 1:1 and stretched to
512 x 256 (the game draws it back at 545.6 x 169.6, the 0.8 of v9t).

Usage: texturas_v9u.py MOCKUP OUT_DIR
"""
from pathlib import Path
import json, sys
import numpy as np
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent))
import texturas_heroe as th
import texturas_v9t as t9

BOX = (546, 1228, 480, 692)

if __name__ == '__main__':
    a = np.asarray(Image.open(sys.argv[1]).convert('RGB')).astype(float)
    OUT = Path(sys.argv[2])
    OUT.mkdir(parents=True, exist_ok=True)
    x0, x1, y0, y1 = BOX
    im = t9.piece(a, BOX, (x1 - x0, y1 - y0), (564, 1208, 501, 663), [(570, 1202, 574, 655)])
    im = im.resize((512, 256), Image.Resampling.LANCZOS)
    im.save(OUT / 'StratInfo.png')
    report = {'StratInfo': {'blp_sha256': th.blp(im, OUT / 'StratInfo.blp')}}
    (OUT / 'v9u.json').write_text(json.dumps(report, indent=1))
    print('ok', json.dumps(report))
