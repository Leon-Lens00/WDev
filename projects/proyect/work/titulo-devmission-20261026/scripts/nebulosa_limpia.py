"""The mockup's nebula with no interface on it (Dev Mission title v9h, 29/10/2026).

Start, mode and hero screens share this background; the hero screen draws its title, slots, cells and panel
over it as separate pictures (texturas_heroe.py). Input is the cleaned mockup (HeroFondoLimpio.png, 1774 x 887)
and the masks of every interface element:
- title text and its ornaments, the 8 player slots, "Tiempo de seleccion", the 40 cells: small, on the dark
  centre; filled with the masked Gaussian average at growing radii (normalised convolution), plus the fine
  detail (image minus a 3 px blur) of the nearest unmasked donor among a few fixed offsets;
- the hero panel (x 1222-1592): over the bright right nebula, so it takes real nebula instead: the right edge
  strip mirrored at x 1592 for its right half, the strip left of it mirrored at x 1222 for its left half,
  crossfaded over 60 px in the middle, then the rim feathered like the small masks.

Usage: nebulosa_limpia.py HERO_FONDO_LIMPIO OUT_PNG [MASK_PNG]
"""
from pathlib import Path
import sys
import numpy as np
from PIL import Image

COLS = [217 + 113.89 * c for c in range(8)]
ROWS = [274 + 113.25 * r for r in range(5)]
SLOTS = [442.5, 532.5, 622.5, 712.5, 1048.5, 1136.5, 1224.5, 1312]
PANEL = (1222, 1592, 198, 808)


def gauss(a, s):
    """Gaussian blur over axes 0 and 1 by FFT, edges reflected."""
    pad = int(3 * s) + 1
    b = np.pad(a, ((pad, pad), (pad, pad)) + ((0, 0),) * (a.ndim - 2), mode='reflect')
    h, w = b.shape[:2]
    fy, fx = np.fft.fftfreq(h)[:, None], np.fft.rfftfreq(w)[None, :]
    k = np.exp(-2 * (np.pi * s) ** 2 * (fx ** 2 + fy ** 2))
    if a.ndim == 3:
        k = k[..., None]
    out = np.fft.irfft2(np.fft.rfft2(b, axes=(0, 1)) * k, s=(h, w), axes=(0, 1))
    return out[pad:pad + a.shape[0], pad:pad + a.shape[1]]


def masks(shape):
    """Every interface element and the same without the panel. The cells' boxes (+-50) leave the real
    background in the 14 px between them, so the fill keeps the grid area's own brightness."""
    m = np.zeros(shape[:2], bool)

    def box(x0, x1, y0, y1):
        m[max(0, int(y0)):int(y1), max(0, int(x0)):int(x1)] = True
    box(500, 1295, 20, 82)
    for x in SLOTS:
        box(x - 52, x + 52, 78, 176)
    box(795, 980, 146, 174)
    for y in ROWS:
        for x in COLS:
            box(x - 50, x + 50, y - 50, y + 50)
    small = m.copy()
    x0, x1, y0, y1 = PANEL
    box(x0, x1, y0, y1)
    return m, small


def panel(a):
    """Bright nebula for the panel's box: the left edge strip turned 180 degrees on its left half, the right
    edge strip flipped upside down on its right half (no mirror line), crossfaded over 60 px, rim feathered."""
    x0, x1, y0, y1 = PANEL
    pad, w = 30, PANEL[1] - PANEL[0] + 60
    half = w // 2 + 30
    left = a[::-1, :half][:, ::-1]
    right = a[::-1, a.shape[1] - half:]
    f = np.clip((np.arange(w) - (w / 2 - 30)) / 60, 0, 1)[None, :, None]
    region = np.zeros((a.shape[0], w, 3))
    region[:, :half] += left * (1 - f[:, :half])
    region[:, w - half:] += right * f[:, w - half:]
    full = a.copy()
    full[:, x0 - pad:x1 + pad] = region
    pm = np.zeros(a.shape[:2])
    pm[y0:y1, x0:x1] = 1
    pm = np.clip(gauss(pm, 14) * 2 - 0.2, 0, 1)
    return a * (1 - pm[..., None]) + full * pm[..., None]


def fill(a, m, donor, seed=7):
    """Masked Gaussian average at growing radii, plus fine detail tiled from donor (x0, x1, y0, y1)."""
    known = (~m).astype(float)
    low = None
    for s in (160, 96, 48, 24, 12, 6, 3):
        num, den = gauss(a * known[..., None], s), gauss(known, s)
        est = num / np.maximum(den, 1e-6)[..., None]
        if low is None:
            low = est
        else:
            w = np.clip(den / 0.4, 0, 1)[..., None]
            low = low * (1 - w) + est * w
    detail = a - gauss(a, 2.5)
    dx0, dx1, dy0, dy1 = donor
    rng = np.random.default_rng(seed)
    tex = np.zeros_like(a)
    t = 40
    for y in range(0, a.shape[0], t):
        for x in range(0, a.shape[1], t):
            sx, sy = rng.integers(dx0, dx1 - t), rng.integers(dy0, dy1 - t)
            patch = detail[sy:sy + t, sx:sx + t]
            if rng.integers(2):
                patch = patch[:, ::-1]
            if rng.integers(2):
                patch = patch[::-1]
            hh, ww = tex[y:y + t, x:x + t].shape[:2]
            tex[y:y + t, x:x + t] = patch[:hh, :ww]
    soft = np.clip(gauss(m.astype(float), 3) * 2 - 0.5, 0, 1)
    soft = np.maximum(soft, m)
    return a * (1 - soft[..., None]) + (low + tex) * soft[..., None]


def without_cells(a):
    """The mockup with only its 40 cells removed (title, slots and panel kept), for the hero screen."""
    m = np.zeros(a.shape[:2], bool)
    for y in ROWS:
        for x in COLS:
            m[int(y - 50):int(y + 50), int(x - 50):int(x + 50)] = True
    return fill(a, m, (300, 1150, 178, 220))


if __name__ == '__main__':
    a = np.asarray(Image.open(sys.argv[1]).convert('RGB')).astype(float)
    m, small = masks(a.shape)
    b = fill(a, m, (300, 1150, 178, 220))
    c = panel(b)
    Image.fromarray(np.clip(c, 0, 255).round().astype(np.uint8)).save(sys.argv[2])
    if len(sys.argv) > 3:
        Image.fromarray((m * 255).astype(np.uint8)).save(sys.argv[3])
