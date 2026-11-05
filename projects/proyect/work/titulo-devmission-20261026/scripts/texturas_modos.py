"""Textures for the Dev Mission mode select screen (v8, 27/10/2026) from the user's nebula menu materials
(Proyect/output/menu-nebulosa-materiales-20261027-v1, generated PNGs with real alpha).

Adjustments made to the materials:
- every piece is cropped to its silhouette (alpha > 8) plus a small margin, so the quad's aspect is the piece's;
- the active and locked boxes are cut with the same rectangle (their union), so swapping them does not shift
  the frame; the five rhombuses of the atlas are centred on one common canvas, so they all line up;
- alpha below 6 is cleared (stray haze), and the colour of the transparent pixels is filled from the nearest
  visible ones (a few dilation passes), so bilinear filtering and the mipmaps do not pull a dark or foreign
  fringe into the edges;
- players 5-8 (yellow, orange, green, pink) get the blue rhombus with the crystal hue turned, as the title's
  rhombuses (texturas_maqueta.py); the atlas has only red, blue, cyan, purple and off.
Textures are powers of two, at most 512; each piece is stretched to its texture and the quad gets back the
crop's aspect in JASS (sizes in modos.json).

Usage: texturas_modos.py MATERIALS_DIR OUT_DIR
"""
from pathlib import Path
import colorsys, json, sys
import numpy as np
from PIL import Image, ImageFilter
sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts')
from grid import blp

SRC, OUT = Path(sys.argv[1]), Path(sys.argv[2])
PLAYER_HUES = {5: 59, 6: 31, 7: 110, 8: 323}


def bbox(im, cut=8, pad=6):
    a = np.asarray(im.getchannel('A')) > cut
    ys, xs = np.nonzero(a)
    return (max(0, xs.min() - pad), max(0, ys.min() - pad), min(im.width, xs.max() + 1 + pad),
            min(im.height, ys.max() + 1 + pad))


def clean(im):
    """Clear faint alpha and bleed the visible colour into the transparent pixels."""
    a = np.asarray(im, float).copy()
    a[a[..., 3] < 6, 3] = 0
    rgb, alpha = a[..., :3], a[..., 3]
    known = alpha > 0
    for _ in range(12):
        if known.all():
            break
        acc = np.zeros_like(rgb)
        cnt = np.zeros(known.shape)
        for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (-1, 1), (1, -1), (1, 1)):
            k = np.roll(np.roll(known, dy, 0), dx, 1)
            c = np.roll(np.roll(rgb, dy, 0), dx, 1)
            acc[k] += c[k]
            cnt[k] += 1
        new = (~known) & (cnt > 0)
        rgb[new] = acc[new] / cnt[new][:, None]
        known = known | new
    return Image.fromarray(np.dstack([rgb, alpha]).round().clip(0, 255).astype(np.uint8), 'RGBA')


def rehue(im, hue):
    """Turn the blue crystal (hue 165-290, saturation over 0.35, so its cyan core too but not the bluish steel) to the given hue; the steel frame keeps its colour."""
    px = np.asarray(im, float) / 255
    out = px.copy()
    for y in range(px.shape[0]):
        for x in range(px.shape[1]):
            r, g, b, a = px[y, x]
            hh, s, v = colorsys.rgb_to_hsv(r, g, b)
            if s > 0.35 and 165 / 360 <= hh <= 290 / 360:
                nh = (hh - 222 / 360 + hue / 360) % 1
                nv = min(1, v * (1.25 if hue in (59, 110) else 1.0))
                out[y, x, :3] = colorsys.hsv_to_rgb(nh, s, nv)
    return Image.fromarray((out * 255).round().astype(np.uint8), 'RGBA')


def bands(im, axis, cut=8, gap=6):
    """Runs of rows (axis 0) or columns (axis 1) holding visible pixels, split by gaps of at least gap."""
    a = (np.asarray(im.getchannel('A')) > cut).any(axis=1 - axis)
    runs, start, empty = [], None, 0
    for i, v in enumerate(a):
        if v:
            if start is None:
                start = i
            empty = 0
        elif start is not None:
            empty += 1
            if empty >= gap:
                runs.append((start, i - empty + 1))
                start, empty = None, 0
    if start is not None:
        runs.append((start, len(a)))
    return runs


report = {}


def save(name, im, size):
    im = clean(im)
    im.save(OUT / f'{name}-recorte.png')
    tex = clean(im.resize(size, Image.Resampling.LANCZOS))
    tex.save(OUT / f'{name}.png')
    report[name] = {'crop': list(im.size), 'aspect': round(im.width / im.height, 4), 'texture': list(size),
                    'blp_sha256': blp(tex, OUT / f'{name}.blp')}


if __name__ == '__main__':
    OUT.mkdir(parents=True, exist_ok=True)
    logo = Image.open(SRC / '01-logo.png').convert('RGBA')
    save('ModeLogo', logo.crop(bbox(logo)), (512, 256))

    act = Image.open(SRC / '02-cuadro-activo.png').convert('RGBA')
    lock = Image.open(SRC / '03-cuadro-bloqueado.png').convert('RGBA')
    a, b = bbox(act, pad=2), bbox(lock, pad=2)
    box = (min(a[0], b[0]), min(a[1], b[1]), max(a[2], b[2]), max(a[3], b[3]))
    save('ModeBoxActive', act.crop(box), (512, 128))
    save('ModeBoxLocked', lock.crop(box), (512, 128))

    pad = Image.open(SRC / '05-candado.png').convert('RGBA')
    save('ModeLock', pad.crop(bbox(pad)), (128, 128))

    atlas = Image.open(SRC / '04-rombos-atlas.png').convert('RGBA')
    cols = bands(atlas, 1, gap=10)
    assert len(cols) == 5, cols
    gems = [atlas.crop((x0, 0, x1, atlas.height)) for x0, x1 in cols]
    gems = [g.crop(bbox(g, pad=2)) for g in gems]
    w, h = max(g.width for g in gems), max(g.height for g in gems)
    canvas = []
    for g in gems:
        c = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        c.alpha_composite(g, ((w - g.width) // 2, (h - g.height) // 2))
        canvas.append(c)
    for k in range(4):
        save(f'ModeGem{k + 1}', canvas[k], (64, 128))
    for p, hue in PLAYER_HUES.items():
        save(f'ModeGem{p}', rehue(canvas[1], hue), (64, 128))
    save('ModeGemOff', canvas[4], (64, 128))

    texts = Image.open(SRC / '06-textos-atlas.png').convert('RGBA')
    rows = bands(texts, 0, gap=8)
    if len(rows) == 3:
        # The descender of "supervivencia" touches "1-10 waves + Boss": split that band at its thinnest row.
        y0, y1 = rows[1]
        count = (np.asarray(texts.getchannel('A')) > 8).sum(axis=1)
        mid = y0 + (y1 - y0) // 2
        cut = mid + int(np.argmin(count[mid:y1 - (y1 - y0) // 6]))
        rows[1:2] = [(y0, cut), (cut, y1)]
    assert len(rows) == 4, rows
    sizes = [(512, 64), (512, 64), (256, 32), (128, 64)]
    for (y0, y1), name, size in zip(rows, ['ModeTitle', 'ModeName', 'ModeDesc', 'ModeUnknown'], sizes):
        r = texts.crop((0, y0, texts.width, y1))
        save(name, r.crop(bbox(r, pad=4)), size)

    # Preview of every piece on black.
    names = list(report)
    sheet = Image.new('RGBA', (1100, 120 * ((len(names) + 1) // 2)), (0, 0, 0, 255))
    for i, n in enumerate(names):
        im = Image.open(OUT / f'{n}-recorte.png')
        im.thumbnail((520, 110))
        sheet.alpha_composite(im, (10 + 550 * (i % 2), 5 + 120 * (i // 2)))
    sheet.convert('RGB').save(OUT / 'previa-negro.png')
    (OUT / 'modos.json').write_text(json.dumps(report, indent=1))
    print(json.dumps({k: (v['crop'], v['aspect'], v['texture']) for k, v in report.items()}, indent=0))
