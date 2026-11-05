"""Textures for the Dev Mission title taken from the user's mockup (26/10/2026).

The mockup (1774 x 887) shows the Start button and the eight rhombuses on a cloudy background: player 1-4
coloured with a glow (red, blue, teal, purple, the same order as the 1.27b player colours) and 5-8 grey. Each
piece is cut out and separated from its background ("colour to alpha"): the background under the piece is a
plane fitted to the ring of pixels around the crop, alpha is how far each pixel is from it (towards white or
black, whichever applies) and the colour is unmixed from it. Only the solid shape is kept from that: what
lies around it is mostly cloud texture, so the glow of players 1-4 is redrawn as the blurred shape in the
crystal's colour. The glow stays as soft alpha, so these textures
need a blended material (TitleDummyBlend.mdl), not the alpha test of UI\\dummy.mdl.
Players 5-8 (yellow, orange, green, pink) have no coloured rhombus in the mockup: they are the blue one with
the crystal and glow hues turned to the player colour (the gold frame is outside the blue hue range).

Usage: texturas_maqueta.py MOCKUP_PNG OUT_DIR
Writes PNG previews, BLPs and maqueta.json (crop boxes, centres and sizes in 1920 x 1080 pixels).
"""
from pathlib import Path
import colorsys, json, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts')
from grid import blp

SRC, OUT = Path(sys.argv[1]), Path(sys.argv[2])
SCALE = 1920 / 1774
GEM_X0, GEM_DX, GEM_Y = 604.5, 80.6, 716
GEM_HALF = (34, 46)
START_BOX = (786, 538, 988, 612)
CUT = 0.07
# Rhombus frame measured on the red one (mockup pixels around its centre 606, 717: 25 across, 33 up/down
# from the centre), two pixels wider, in crop coordinates; the button's frame spans 794-980 x 545-605.
GEM_SHAPE = [(GEM_HALF[0] + 1, GEM_HALF[1] + 1 - 36), (GEM_HALF[0] + 1 + 28, GEM_HALF[1] + 1),
             (GEM_HALF[0] + 1, GEM_HALF[1] + 1 + 36), (GEM_HALF[0] + 1 - 28, GEM_HALF[1] + 1)]
START_SHAPE = [(792 - 786, 543 - 538), (982 - 786, 543 - 538), (982 - 786, 607 - 538), (792 - 786, 607 - 538)]
PLAYER_HUES = {5: 59, 6: 31, 7: 110, 8: 323}


def plane(ring_xy, ring_rgb, w, h):
    """Least squares plane per channel over the ring, evaluated on the whole crop."""
    a = np.c_[ring_xy, np.ones(len(ring_xy))]
    coef, *_ = np.linalg.lstsq(a, ring_rgb, rcond=None)
    yy, xx = np.mgrid[0:h, 0:w]
    return np.clip(np.dstack([xx, yy, np.ones_like(xx)]) @ coef, 1, 254)


def unblend(img, box, ring=3):
    x0, y0, x1, y1 = box
    big = np.asarray(img.crop((x0 - ring, y0 - ring, x1 + ring, y1 + ring)).convert('RGB'), float)
    h, w = big.shape[:2]
    m = np.zeros((h, w), bool)
    m[:ring], m[-ring:], m[:, :ring], m[:, -ring:] = True, True, True, True
    yy, xx = np.nonzero(m)
    bg = plane(np.c_[xx, yy], big[m], w, h)
    up = np.where(big > bg, (big - bg) / (255 - bg), (bg - big) / bg)
    a = up.max(axis=2)
    a = np.where(a < CUT, 0, (a - CUT) / (1 - CUT))
    safe = np.maximum(a, 1e-3)[..., None]
    rgb = np.clip(bg + (big - bg) / safe, 0, 255)
    rgba = np.dstack([rgb, a * 255])[ring:-ring, ring:-ring]
    return Image.fromarray(rgba.round().astype(np.uint8), 'RGBA')


def halo(im, raw, shape, glow=0.0, radius=6):
    """Keep the solid shape (and a one pixel band for its antialiased edge) and drop the rest of the crop,
    which is cloud texture. shape is the polygon (crop pixels) the piece lies in; four pixels inside it the
    piece is opaque and keeps its raw pixels (unmixing would turn mid greys translucent against the dark
    background). With glow > 0 a clean glow is drawn around it: the shape blurred, in the mean colour of its
    saturated (crystal) pixels."""
    a = np.asarray(im, float)
    inside = Image.new('L', (a.shape[1], a.shape[0]), 0)
    ImageDraw.Draw(inside).polygon(shape, fill=255)
    inner = np.asarray(inside.filter(ImageFilter.MinFilter(9))) > 0
    a[inner, :3] = np.asarray(raw.convert('RGB'), float)[inner]
    a[inner, 3] = 255
    solid = Image.fromarray(((a[..., 3] > 150) & (np.asarray(inside) > 0)).astype(np.uint8) * 255, 'L')
    band = np.asarray(solid.filter(ImageFilter.MaxFilter(3)), float) > 0
    out = np.zeros_like(a)
    band &= np.asarray(inside) > 0
    out[band] = a[band]
    if glow > 0:
        rgb = a[..., :3] / 255
        mx, mn = rgb.max(axis=2), rgb.min(axis=2)
        crystal = (np.asarray(solid) > 0) & (mx - mn > 0.35 * np.maximum(mx, 1e-3))
        colour = a[..., :3][crystal].mean(axis=0) if crystal.any() else np.zeros(3)
        colour = colour * (255 / max(colour.max(), 1))
        g = np.asarray(solid.filter(ImageFilter.GaussianBlur(radius)), float) * glow
        outside = ~band
        out[outside, :3] = colour
        out[outside, 3] = g[outside]
    return Image.fromarray(out.round().astype(np.uint8), 'RGBA')


def rehue(im, hue):
    """Turn the blue crystal and glow (hue 190-290) to the given hue; the frame keeps its colour."""
    px = np.asarray(im, float) / 255
    out = px.copy()
    for y in range(px.shape[0]):
        for x in range(px.shape[1]):
            r, g, b, a = px[y, x]
            hh, s, v = colorsys.rgb_to_hsv(r, g, b)
            if s > 0.3 and 190 / 360 <= hh <= 290 / 360:
                nh = (hh - 222 / 360 + hue / 360) % 1
                # Yellow and green look darker than blue at the same value; lift them a little.
                nv = min(1, v * (1.25 if hue in (59, 110) else 1.0))
                out[y, x, :3] = colorsys.hsv_to_rgb(nh, s, nv)
    return Image.fromarray((out * 255).round().astype(np.uint8), 'RGBA')


def save(name, im, size, report, box):
    tex = im.resize(size, Image.Resampling.LANCZOS)
    im.save(OUT / f'{name}-recorte.png')
    tex.save(OUT / f'{name}.png')
    x0, y0, x1, y1 = box
    report[name] = {'crop': box, 'centre_1920': [round((x0 + x1) / 2 * SCALE, 1), round((y0 + y1) / 2 * SCALE, 1)],
                    'size_1920': [round((x1 - x0) * SCALE, 1), round((y1 - y0) * SCALE, 1)],
                    'texture': list(size), 'blp_sha256': blp(tex, OUT / f'{name}.blp')}


if __name__ == '__main__':
    OUT.mkdir(parents=True, exist_ok=True)
    img = Image.open(SRC)
    report = {}
    gems = []
    for k in range(8):
        cx = round(GEM_X0 + k * GEM_DX)
        box = (cx - GEM_HALF[0], GEM_Y - GEM_HALF[1], cx + GEM_HALF[0], GEM_Y + GEM_HALF[1])
        gems.append((box, halo(unblend(img, box), img.crop(box), GEM_SHAPE, glow=0.0 if k >= 4 else 0.85)))
    for k in range(4):
        save(f'TitleGem{k + 1}', gems[k][1], (128, 128), report, gems[k][0])
    for p, hue in PLAYER_HUES.items():
        save(f'TitleGem{p}', rehue(gems[1][1], hue), (128, 128), report, gems[1][0])
    save('TitleGemGrey', gems[4][1], (128, 128), report, gems[4][0])
    start = halo(unblend(img, START_BOX), img.crop(START_BOX), START_SHAPE)
    save('TitleStart', start, (256, 128), report, START_BOX)
    lit = np.asarray(start, float)
    lit[..., :3] = np.clip(lit[..., :3] * 1.3 + 12, 0, 255)
    save('TitleStartHover', Image.fromarray(lit.round().astype(np.uint8), 'RGBA'), (256, 128), report, START_BOX)
    # Preview on black, as in game, at 3x.
    sheet = Image.new('RGBA', (8 * 80 + 220, 100), (0, 0, 0, 255))
    for k, name in enumerate(['TitleGem%d' % (i + 1) for i in range(8)]):
        g = Image.open(OUT / f'{name}-recorte.png')
        sheet.alpha_composite(g, (10 + k * 80, 4))
    sheet.alpha_composite(Image.open(OUT / 'TitleStart-recorte.png'), (8 * 80 + 10, 13))
    sheet.resize((sheet.width * 3, sheet.height * 3), Image.Resampling.LANCZOS).save(OUT / 'previa-negro.png')
    (OUT / 'maqueta.json').write_text(json.dumps(report, indent=1))
    print(json.dumps({k: (v['centre_1920'], v['size_1920']) for k, v in report.items()}))
