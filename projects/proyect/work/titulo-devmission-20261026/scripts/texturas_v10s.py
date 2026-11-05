"""The boss's name for the end of the presentation (v10s, 29/10/2026).

As in the user's intro video (fuentes/presentacion/referencia-audio.mp4, "BURN ROOSTER" under the frozen
character): capitals in a pixel style, gold from pale yellow at the top to orange at the bottom, a dark outline.
The name is the boss's, "Nereus" (BossName, texturas_boss.py). Drawn at 128 x 16 without antialiasing
(Fira Sans Condensed ExtraBold), outlined, and scaled x4 by nearest neighbour: PresNombre.blp, 512 x 64.

Usage: texturas_v10s.py OUT_DIR
"""
from pathlib import Path
import json, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont
sys.path.insert(0, str(Path(__file__).parent))
out = Path(sys.argv[1])
sys.argv[1:] = ['-', '-']  # texturas_heroe reads its own two arguments when imported; only its blp() is used
import texturas_heroe as th

FONT = '/usr/share/fonts/TTF/FiraSansCondensed-ExtraBold.ttf'
TEXT = 'NEREUS'
W, H, K = 128, 16, 4

out.mkdir(parents=True, exist_ok=True)
font = ImageFont.truetype(FONT, 15)
mask = Image.new('L', (W, H), 0)
d = ImageDraw.Draw(mask)
d.fontmode = '1'
x0, y0, x1, y1 = d.textbbox((0, 0), TEXT, font=font)
d.text(((W - (x1 - x0)) // 2 - x0, (H - (y1 - y0)) // 2 - y0), TEXT, font=font, fill=255)
m = np.asarray(mask) > 127
rows = np.nonzero(m.any(1))[0]
top, bottom = rows[0], rows[-1]
# A one-pixel dark outline around the letters (8 neighbours).
ring = np.zeros_like(m)
for dy in (-1, 0, 1):
    for dx in (-1, 0, 1):
        ring |= np.roll(np.roll(m, dy, 0), dx, 1)
ring &= ~m
img = np.zeros((H, W, 4), np.uint8)
t = np.clip((np.arange(H) - top) / max(bottom - top, 1), 0, 1)[:, None]
top_c, mid_c, low_c = np.array([255, 250, 190]), np.array([255, 214, 60]), np.array([235, 120, 20])
grad = np.where((t < 0.5)[..., None], top_c + (mid_c - top_c) * (t / 0.5)[..., None],
                mid_c + (low_c - mid_c) * ((t - 0.5) / 0.5)[..., None])[:, 0, :]
img[m, :3] = np.broadcast_to(grad[:, None, :], (H, W, 3))[m]
img[m, 3] = 255
img[ring] = (40, 18, 8, 255)
big = Image.fromarray(img, 'RGBA').resize((W * K, H * K), Image.NEAREST)
big.save(out / 'PresNombre.png')
cols = np.nonzero((m | ring).any(0))[0]
report = {'PresNombre': {'blp_sha256': th.blp(big, out / 'PresNombre.blp'), 'size': [W * K, H * K],
                         'ink_px': [int(cols[0]) * K, int(cols[-1] + 1) * K], 'cap_rows': [int(top) * K, int(bottom + 1) * K]}}
print(json.dumps(report))
