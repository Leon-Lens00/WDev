"""Round counter icon for Dev Mission v12s (31/10/2026): full-colour biohazard emblem, BLP and model, written without PIL.

Steel rim in the HUD's blue and ice tones, dark disc so that the title stays readable, red biohazard sign with bevel and grit.

Usage: icono_v12s.py IN_MDX OUT_MDX OUT_BLP [OUT_RAW]
"""
from math import atan2, cos, exp, hypot, pi, sin
from pathlib import Path
import random
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import icono_v12q as base

SIZE = 256
HALF = 19.
LIGHT = (-0.55, 0.75)
random.seed(1998)
GRIT = [random.random() for _ in range(4096)]


def grit(x, y):
    i, j = int((x + 1) * 90), int((y + 1) * 90)
    return GRIT[(i * 73 + j * 151) & 4095] * .6 + GRIT[(i // 3 * 37 + j // 3 * 91) & 4095] * .4


def mix(a, b, t):
    t = max(0., min(1., t))
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


def sign(x, y):
    """Signed distance of the biohazard sign, negative inside, and of its inner ring."""
    best = 9.
    for k in range(3):
        a = pi / 2 + k * 2 * pi / 3
        outer = hypot(x - .34 * cos(a), y - .34 * sin(a)) - .34
        hole = .245 - hypot(x - .47 * cos(a), y - .47 * sin(a))
        best = min(best, max(outer, hole))
    r = hypot(x, y)
    best = min(best, max(r - .305, .245 - r))
    best = max(best, .075 - r)
    for k in range(3):
        a = pi / 2 + k * 2 * pi / 3
        along = x * cos(a) + y * sin(a)
        across = abs(-x * sin(a) + y * cos(a))
        if 0 < along < .19:
            best = max(best, .022 - across)
    return best


def pixel(x, y):
    r = hypot(x, y)
    if r > .985:
        return 0., 0., 0., 0.
    edge = min(1., (.985 - r) * 60)
    angle = atan2(y, x)
    n = (x * LIGHT[0] + y * LIGHT[1]) / max(r, .001)
    g = grit(x, y)
    if r > .80:
        # Steel rim with bevel, twelve notches and an ice edge.
        t = (r - .80) / .185
        c = mix((46, 60, 84), (138, 166, 196), .5 + .5 * n * (1 - 2 * t))
        c = mix(c, (24, 30, 44), abs(t - .5) * 1.3 - .35)
        notch = abs(((angle / (2 * pi) * 12) % 1) - .5)
        if notch < .05 and .84 < r < .95:
            c = (14, 18, 28)
        if notch > .44 and .85 < r < .94:
            c = mix(c, (199, 247, 255), .75)
    elif r > .775:
        c = mix((90, 200, 230), (199, 247, 255), .5 + .5 * n)
    else:
        # Dark disc: radial shade, fine hazard lines near the rim, faint ice glow.
        c = mix((30, 34, 46), (9, 10, 16), r / .78)
        if r > .62 and ((angle / (2 * pi) * 36) % 1) < .5:
            c = mix(c, (150, 28, 30), .55 * (1 - abs(r - .70) / .08))
        if abs(r - .62) < .008:
            c = mix(c, (138, 166, 196), .7)
        c = tuple(v * (.86 + .28 * g) for v in c)
        d = sign(x * 1.42, y * 1.42) / 1.42
        if d < 0:
            depth = min(1., -d / .05)
            dx = sign((x + .01) * 1.42, y * 1.42) - sign((x - .01) * 1.42, y * 1.42)
            dy = sign(x * 1.42, (y + .01) * 1.42) - sign(x * 1.42, (y - .01) * 1.42)
            bevel = (dx * LIGHT[0] + dy * LIGHT[1]) * -18 * (1 - depth)
            s = mix((116, 8, 14), (228, 34, 30), .25 + .75 * (.5 + .5 * (y + .4)))
            s = mix(s, (255, 150, 96), max(0., bevel))
            s = mix(s, (40, 2, 6), max(0., -bevel))
            c = tuple(v * (.84 + .3 * g) for v in s)
        else:
            c = mix(c, (214, 30, 30), .55 * exp(-d * 34))
    return c[0], c[1], c[2], 255. * edge


def image():
    rows = []
    for j in range(SIZE):
        for i in range(SIZE):
            t = [0.] * 4
            for sj in (.25, .75):
                for si in (.25, .75):
                    p = pixel(((i + si) / SIZE - .5) * 2, (.5 - (j + sj) / SIZE) * 2)
                    a = p[3]
                    t[0] += p[0] * a
                    t[1] += p[1] * a
                    t[2] += p[2] * a
                    t[3] += a
            a = t[3] / 4
            rows.append(tuple(int(min(255, v / t[3])) for v in t[:3]) + (int(a),) if t[3] else (0, 0, 0, 0))
    return rows


def palette(pixels):
    boxes = [sorted({p[:3] for p in pixels if p[3]})]
    while len(boxes) < 255:
        boxes.sort(key=lambda b: max(max(c[i] for c in b) - min(c[i] for c in b) for i in range(3)) * len(b) ** .5)
        box = boxes.pop()
        if len(box) < 2:
            boxes.append(box)
            break
        axis = max(range(3), key=lambda i: max(c[i] for c in box) - min(c[i] for c in box))
        box.sort(key=lambda c: c[axis])
        boxes += [box[:len(box) // 2], box[len(box) // 2:]]
    return [tuple(sum(c[i] for c in b) // len(b) for i in range(3)) for b in boxes]


def down(p, w, h):
    n = max(1, w // 2), max(1, h // 2)
    out = []
    for y in range(n[1]):
        for x in range(n[0]):
            q = [p[y * 2 * w + x * 2], p[y * 2 * w + x * 2 + 1], p[(y * 2 + 1) * w + x * 2], p[(y * 2 + 1) * w + x * 2 + 1]]
            a = sum(c[3] for c in q)
            out.append(tuple(sum(c[i] * c[3] for c in q) // a for i in range(3)) + (a // 4,) if a else (0, 0, 0, 0))
    return out, n[0], n[1]


def blp(pixels):
    colours = palette(pixels)
    cache = {}

    def index(c):
        if c not in cache:
            cache[c] = min(range(len(colours)), key=lambda k: sum((colours[k][i] - c[i]) ** 2 for i in range(3)))
        return cache[c]
    levels = []
    p, w, h = pixels, SIZE, SIZE
    while True:
        levels.append(bytes(index(c[:3]) for c in p) + bytes(c[3] for c in p))
        if w == 1:
            break
        p, w, h = down(p, w, h)
    bgra = b''.join(bytes((c[2], c[1], c[0], 0)) for c in colours).ljust(1024, b'\0')
    offsets, q = [], 156 + 1024
    for level in levels:
        offsets.append(q)
        q += len(level)
    head = b'BLP1' + struct.pack('<6I', 1, 8, SIZE, SIZE, 4, 1)
    head += struct.pack('<16I', *(offsets + [0] * (16 - len(offsets))))
    head += struct.pack('<16I', *([len(x) for x in levels] + [0] * (16 - len(levels))))
    return head + bgra + b''.join(levels)


if __name__ == '__main__':
    base.HALF = HALF
    Path(sys.argv[2]).write_bytes(base.model(Path(sys.argv[1]).read_bytes()))
    pixels = image()
    Path(sys.argv[3]).write_bytes(blp(pixels))
    if len(sys.argv) > 4:
        Path(sys.argv[4]).write_bytes(b''.join(bytes(p) for p in pixels))
    print('ok')
