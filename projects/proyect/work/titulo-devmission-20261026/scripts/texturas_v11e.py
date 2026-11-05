"""Portrait frame v11e (Dev Mission title, 30/10/2026): one frame for the hero select and the strategy board, cut to
the portrait's wall (27 x 21.4 model units) and drawn IN FRONT of the portrait, so its wide band covers the box's edges.

- StratFrame (512 x 512): the ornaments of the v9t frame, enlarged and fitted by 9-slice to the box's proportions, over
  an opaque band; the opening is transparent and hides BOX_INSET texels of the box on each side. Texel (256, 256) is the
  portrait's centre;
- PortraitDark (32 x 32): the dark at 0.85 that was inside the old frame, now a picture of its own behind the portrait;
- HeroPanelT: the hero panel without its inner frame, which the new one replaces.

Usage: texturas_v11e.py OLD_FRAME_PNG OLD_PANEL_PNG OUT_DIR
"""
from pathlib import Path
import json, sys
import numpy as np
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent))
import texturas_heroe as th

SIZE = 512
BOX = (404, 320)            # the wall, 13.5 x 10.7 units each way, in texels
BOX_INSET = 14              # box texels hidden behind the band on each side
OUTER = (444, 360)          # the ornaments' line
OLD_LINE = (98, 414, 44, 211)   # that line in the old frame
OLD_HOLE = (104, 408, 50, 206)  # the old inside
ZOOM = 1.35
CORNER = 46                 # corner slice around the line's corners, in enlarged texels
DIAMOND = 66                # half width of the bottom diamond, in enlarged texels
# The panel's inner frame (rectangle kept clear of the outer frame) and its clean inside.
PANEL_LINES = (34, 478, 128, 482)
PANEL_CLEAN = (54, 460, 158, 448)


def premul(a):
    a = a.astype(float)
    a[..., :3] *= a[..., 3:4] / 255
    return a


def unpremul(a):
    out = a.copy()
    k = np.where(a[..., 3] > 0, 255 / np.maximum(a[..., 3], 1e-6), 0)
    out[..., :3] = np.clip(a[..., :3] * k[..., None], 0, 255)
    return out


def enlarge(a, z):
    h, w = a.shape[:2]
    size = (round(w * z), round(h * z))
    return np.dstack([np.asarray(Image.fromarray(a[..., c].astype(np.float32), 'F').resize(size, Image.Resampling.LANCZOS))
                      for c in range(4)]).clip(0, 255)


def stretch(a, w, h):
    return np.dstack([np.asarray(Image.fromarray(a[..., c].astype(np.float32), 'F').resize((w, h), Image.Resampling.BICUBIC))
                      for c in range(4)]).clip(0, 255)


def over(dst, src, x, y):
    h, w = src.shape[:2]
    d = dst[y:y + h, x:x + w]
    d[...] = src + d * (1 - src[..., 3:4] / 255)


def ornaments(old):
    """The old frame's lines, spikes and diamond (premultiplied), stretched so the line falls on OUTER."""
    a = premul(old)
    x0, x1, y0, y1 = OLD_HOLE
    a[y0:y1, x0:x1] = 0
    r = enlarge(a, ZOOM)
    lx0, lx1, ly0, ly1 = [round(v * ZOOM) for v in OLD_LINE]
    c = CORNER
    out = np.zeros((SIZE, SIZE, 4))
    nx0, ny0 = (SIZE - OUTER[0]) // 2, (SIZE - OUTER[1]) // 2
    nx1, ny1 = nx0 + OUTER[0], ny0 + OUTER[1]
    # Edges: the old span between corners stretched to the new one, each with its spikes' margin.
    m = 12
    over(out, stretch(r[ly0 - m:ly0 + m, lx0 + c:lx1 - c], nx1 - nx0 - 2 * c, 2 * m), nx0 + c, ny0 - m)
    over(out, stretch(r[ly1 - m:ly1 + m, lx0 + c:lx1 - c], nx1 - nx0 - 2 * c, 2 * m), nx0 + c, ny1 - m)
    over(out, stretch(r[ly0 + c:ly1 - c, lx0 - m:lx0 + m], 2 * m, ny1 - ny0 - 2 * c), nx0 - m, ny0 + c)
    over(out, stretch(r[ly0 + c:ly1 - c, lx1 - m:lx1 + m], 2 * m, ny1 - ny0 - 2 * c), nx1 - m, ny0 + c)
    # Corners and the bottom diamond at their own size.
    e = 20
    for ox, nx, sx0, sx1 in ((lx0, nx0, -e, c), (lx1, nx1, -c, e)):
        for oy, ny, sy0, sy1 in ((ly0, ny0, -e, c), (ly1, ny1, -c, e)):
            s = r[oy + sy0:oy + sy1, ox + sx0:ox + sx1]
            out[ny + sy0:ny + sy1, nx + sx0:nx + sx1] = 0
            over(out, s, nx + sx0, ny + sy0)
    mid = (lx0 + lx1) // 2
    s = r[ly1 - 24:ly1 + 34, mid - DIAMOND:mid + DIAMOND]
    x = SIZE // 2 - DIAMOND
    out[ny1 - 24:ny1 + 34, x:x + 2 * DIAMOND] *= (s[..., 3:4] < 8)
    over(out, s, x, ny1 - 24)
    return out


def band():
    """The opaque band between the opening and the ornaments' line, a bright lip on the opening."""
    b = np.zeros((SIZE, SIZE, 4))
    hw, hh = BOX[0] / 2 - BOX_INSET, BOX[1] / 2 - BOX_INSET
    ow, oh = OUTER[0] / 2, OUTER[1] / 2
    yy, xx = np.mgrid[:SIZE, :SIZE] + 0.5 - SIZE / 2
    # Distance outward from the opening, 0 on its edge.
    d = np.maximum(np.abs(xx) - hw, np.abs(yy) - hh)
    inside_outer = (np.abs(xx) < ow) & (np.abs(yy) < oh)
    t = np.clip(d / (ow - hw), 0, 1)[..., None]
    c = np.array([30.0, 52.0, 100.0]) * (1 - t) + np.array([10.0, 18.0, 44.0]) * t
    # The lip, and a faint second line in the band as the panel's double lines.
    c = c + np.exp(-((d - 1.5) / 1.8) ** 2)[..., None] * np.array([190.0, 205.0, 215.0])
    c = c + np.exp(-((d - 5.0) / 2.6) ** 2)[..., None] * np.array([20.0, 60.0, 150.0])
    c = c + np.exp(-((d - 20.0) / 1.2) ** 2)[..., None] * np.array([60.0, 90.0, 140.0])
    b[..., :3] = c.clip(0, 255)
    b[..., 3] = np.clip(d + 0.5, 0, 1) * inside_outer * 255
    b[..., :3] *= b[..., 3:4] / 255
    return b


def frame(old):
    out = band()
    orn = ornaments(old)
    over(out, orn, 0, 0)
    # Nothing of the ornaments in the opening.
    hw, hh = BOX[0] // 2 - BOX_INSET, BOX[1] // 2 - BOX_INSET
    out[SIZE // 2 - hh:SIZE // 2 + hh, SIZE // 2 - hw:SIZE // 2 + hw] = 0
    return Image.fromarray(unpremul(out).round().astype(np.uint8), 'RGBA')


def panel(old):
    """Mirrors the clean inside over the inner frame's lines (RGB and alpha), leaving the outer frame alone."""
    a = old.astype(float)
    x0, x1, y0, y1 = PANEL_LINES
    cx0, cx1, cy0, cy1 = PANEL_CLEAN
    for y in range(y0, cy0):
        a[y, x0:x1] = a[2 * cy0 - y, x0:x1]
    for y in range(cy1, y1):
        a[y, x0:x1] = a[2 * cy1 - y - 1, x0:x1]
    for x in range(x0, cx0):
        a[y0:y1, x] = a[y0:y1, 2 * cx0 - x]
    for x in range(cx1, x1):
        a[y0:y1, x] = a[y0:y1, 2 * cx1 - x - 1]
    # The old inside was lighter than the panel: down to the panel's level, feathered to the rectangle's edges.
    k = a[60:120, 60:450, :3].mean(axis=(0, 1)) / a[cy0:cy1, cx0:cx1, :3].mean(axis=(0, 1))
    yy, xx = np.mgrid[:a.shape[0], :a.shape[1]]
    w = np.clip(np.minimum.reduce([xx - x0, x1 - xx, yy - y0, y1 - yy]) / 14, 0, 1)[..., None]
    a[..., :3] *= 1 + (k - 1) * w
    return Image.fromarray(a.round().astype(np.uint8), 'RGBA')


if __name__ == '__main__':
    old = np.asarray(Image.open(sys.argv[1]).convert('RGBA'))
    pan = np.asarray(Image.open(sys.argv[2]).convert('RGBA'))
    OUT = Path(sys.argv[3])
    OUT.mkdir(parents=True, exist_ok=True)
    report = {}
    dark = np.zeros((32, 32, 4), np.uint8)
    dark[...] = (1, 3, 12, 217)
    for nm, im in (('StratFrame', frame(old)), ('PortraitDark', Image.fromarray(dark, 'RGBA')), ('HeroPanelT', panel(pan))):
        im.save(OUT / f'{nm}.png')
        report[nm] = {'blp_sha256': th.blp(im, OUT / f'{nm}.blp'), 'bytes': (OUT / f'{nm}.blp').stat().st_size}
    (OUT / 'v11e.json').write_text(json.dumps(report, indent=1))
    print(json.dumps(report))
