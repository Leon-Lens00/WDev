"""Hero select screen textures from the user's mockup (Dev Mission title v9f, 29/10/2026).

The user's mockup (fuentes/seleccion-heroe-maqueta.webp, 1774 x 887) is the whole screen: nebula, title, the
eight player slots, the 8 x 5 grid, the hero panel and Lock in. Its elements sit on a painted nebula with no
alpha, so instead of matting each one the mockup itself becomes the background, cleaned of what changes:
- the lit cell (row 3, column 4) gets the plain cell above it (115 px up, the best alignment): a 200 x 150 window,
  periodic with the grid, so its bloom goes too (feathered over 12 px);
- the "0:30" digits are filled by diffusion from their border (the clock is drawn with digit pictures);
- "Nombre del heroe" is replaced row by row by the bar's own colour from both sides (blank for now).
The cleaned mockup goes at screen offset (80, 15) in 1920 x 1080 (title centre at y 62 as the mode screen,
Lock in ends at 808, over the console), mirrored outwards to 2048 x 1024 and cut in 8 tiles of 512.

The lit cell minus the plain one is the cell's glow. Its brightness, tinted with each slot's glow colour
measured in the mockup (players 1-8: red, blue, teal, purple, yellow, orange, green, pink), gives one 128 x 128
glow per player, drawn additively over the chosen cell ('uidg'). The clock's colon is drawn like the digits
(texturas_digitos.py). BLP1 paletted as grid.blp, but every level dithered, for the nebula's gradients.

v9h (29/10/2026): the user asked for more room between the cells, using the empty space left of the grid and
between the grid and the panel. The 40 cells are lifted out (nebulosa_limpia.without_cells fills their place
from the 14 px of real background between them) and pasted back, each one as it was, with columns 142 apart
from x 128 instead of 113.89 from 217 (frames x 90-1160; the panel starts at 1236). Rows stay.

Usage: texturas_heroe.py MOCKUP OUT_DIR
"""
from pathlib import Path
import hashlib, json, struct, sys
import numpy as np
from PIL import Image

SRC, OUT = Path(sys.argv[1]), Path(sys.argv[2])
OFFSET = (80, 15)
LIT, PLAIN = (560, 502), (560, 387)
COLS = [217 + 113.89 * c for c in range(8)]
NEW_COLS = [128 + 142 * c for c in range(8)]
ROWS = [274 + 113.25 * r for r in range(5)]
SLOTS = [442.5, 532.5, 622.5, 712.5, 1048.5, 1136.5, 1224.5, 1312]


def blp(image, target):
    image = image.convert('RGBA')
    pal = image.convert('RGB').quantize(colors=256, method=Image.Quantize.MEDIANCUT)
    palette = pal.getpalette()[:768]
    palette += [0] * (768 - len(palette))
    bgra = b''.join(bytes((palette[i + 2], palette[i + 1], palette[i], 0)) for i in range(0, 768, 3))
    levels, (w, h) = [], image.size
    while True:
        mip = image.resize((w, h), Image.Resampling.BOX)
        idx = mip.convert('RGB').quantize(palette=pal, dither=Image.Dither.FLOYDSTEINBERG).tobytes()
        levels.append(idx + mip.getchannel('A').tobytes())
        if w == 1 and h == 1:
            break
        w, h = max(1, w // 2), max(1, h // 2)
    offsets, p = [], 156 + 1024
    for level in levels:
        offsets.append(p)
        p += len(level)
    header = b'BLP1' + struct.pack('<6I', 1, 8, *image.size, 4, 1)
    header += struct.pack('<16I', *(offsets + [0] * (16 - len(offsets))))
    header += struct.pack('<16I', *([len(x) for x in levels] + [0] * (16 - len(levels))))
    payload = header + bgra + b''.join(levels)
    target.write_bytes(payload)
    return hashlib.sha256(payload).hexdigest()


def feather(size, inner, outer):
    d = np.abs(np.arange(size) - (size - 1) / 2)
    m = np.clip((outer - d) / (outer - inner), 0, 1)
    return np.minimum.outer(m, m)[..., None]


def diffuse(a, x0, x1, y0, y1, steps=1500):
    r = a[y0 - 1:y1 + 2, x0 - 1:x1 + 2].copy()
    inner = r[1:-1, 1:-1]
    inner[:] = r[[0, -1]].mean((0, 1))
    for _ in range(steps):
        inner[:] = (r[:-2, 1:-1] + r[2:, 1:-1] + r[1:-1, :-2] + r[1:-1, 2:]) / 4
    a[y0 - 1:y1 + 2, x0 - 1:x1 + 2] = r


def clean(a):
    out = a.copy()
    hx, hy = 100, 75
    (lx, ly), (px, py) = LIT, PLAIN
    mx = np.clip((hx - np.abs(np.arange(2 * hx) - hx + 0.5)) / 12, 0, 1)
    my = np.clip((hy - np.abs(np.arange(2 * hy) - hy + 0.5)) / 12, 0, 1)
    m = np.minimum.outer(my, mx)[..., None]
    lit, plain = a[ly - hy:ly + hy, lx - hx:lx + hx], a[py - hy:py + hy, px - hx:px + hx]
    out[ly - hy:ly + hy, lx - hx:lx + hx] = plain * m + lit * (1 - m)
    diffuse(out, 826, 944, 92, 139)
    left, right = out[243:274, 1270:1287].mean(1), out[243:274, 1530:1547].mean(1)
    f = np.linspace(0, 1, 1530 - 1287)[None, :, None]
    out[243:274, 1287:1530] = left[:, None] * (1 - f) + right[:, None] * f
    return out


def spread(c):
    """The cells moved to NEW_COLS over the mockup without cells: opaque to +-42 px, feathered to +-48."""
    sys.path.insert(0, str(Path(__file__).parent))
    from nebulosa_limpia import without_cells
    out = np.clip(without_cells(c), 0, 255)
    d = np.abs(np.arange(96) - 47.5)
    m1 = np.clip((48 - d) / 6, 0, 1)
    m = np.minimum.outer(m1, m1)[..., None]
    for y in ROWS:
        for x, nx in zip(COLS, NEW_COLS):
            sx, sy, tx = int(round(x)) - 48, int(round(y)) - 48, int(round(nx)) - 48
            cell = c[sy:sy + 96, sx:sx + 96]
            out[sy:sy + 96, tx:tx + 96] = cell * m + out[sy:sy + 96, tx:tx + 96] * (1 - m)
    return out


def slot_colour(a, cx):
    r = a[85:165, int(cx) - 45:int(cx) + 45].reshape(-1, 3)
    mx, mn = r.max(1), r.min(1)
    keep = (mx > 120) & ((mx - mn) / (mx + 1) > 0.55)
    c = r[keep].mean(0)
    return c / c.max()


if __name__ == '__main__':
    OUT.mkdir(parents=True, exist_ok=True)
    a = np.asarray(Image.open(SRC).convert('RGB')).astype(float)
    assert a.shape == (887, 1774, 3), a.shape
    c = spread(clean(a))
    Image.fromarray(c.round().astype(np.uint8)).save(OUT / 'HeroFondoLimpio.png')
    ox, oy = OFFSET
    big = np.pad(c, ((oy, 1024 - oy - 887), (ox, 2048 - ox - 1774), (0, 0)), mode='reflect')
    report = {}
    for j in range(2):
        for i in range(4):
            name = f'HeroBg{j * 4 + i}'
            t = Image.fromarray(big[512 * j:512 * j + 512, 512 * i:512 * i + 512].round().astype(np.uint8)).convert('RGBA')
            report[name] = {'screen_centre': [256 + 512 * i, 256 + 512 * j], 'blp_sha256': blp(t, OUT / f'{name}.blp')}
    Image.fromarray(big[:1080 if big.shape[0] > 1080 else None, :1920].round().astype(np.uint8)).save(OUT / 'previa-fondo.png')

    (lx, ly), (px, py) = LIT, PLAIN
    g = np.clip(a[ly - 64:ly + 64, lx - 64:lx + 64] - a[py - 64:py + 64, px - 64:px + 64], 0, None)
    g = g.max(2)
    g = np.clip((g - 12) / 160, 0, 1) * feather(128, 56, 63)[..., 0]
    sheet = Image.new('RGB', (8 * 136, 136), (0, 0, 0))
    plain = Image.fromarray(a[py - 64:py + 64, px - 64:px + 64].round().astype(np.uint8))
    for p, cx in enumerate(SLOTS):
        col = slot_colour(a, cx)
        rgb = np.clip(g[..., None] * (0.8 * col + 0.2) * 255 * 1.15, 0, 255)
        im = Image.fromarray(np.dstack([rgb, np.where(g > 0, 255, 0)]).astype(np.uint8), 'RGBA')
        name = f'HeroGlow{p + 1}'
        report[name] = {'colour': [round(float(x), 3) for x in col], 'blp_sha256': blp(im, OUT / f'{name}.blp')}
        prev = np.clip(np.asarray(plain, float) + rgb, 0, 255).astype(np.uint8)
        sheet.paste(Image.fromarray(prev), (p * 136 + 4, 4))
    sheet.save(OUT / 'previa-resaltes.png')

    sys.argv = [sys.argv[0], str(OUT)]
    sys.path.insert(0, str(Path(__file__).parent))
    from texturas_digitos import digit
    colon = digit(':').resize((64, 128), Image.Resampling.LANCZOS)
    colon.save(OUT / 'HeroColon.png')
    report['HeroColon'] = {'blp_sha256': blp(colon, OUT / 'HeroColon.blp')}
    (OUT / 'heroe.json').write_text(json.dumps(report, indent=1))
    print(json.dumps({k: v.get('colour', '') for k, v in report.items() if 'Glow' in k}))
