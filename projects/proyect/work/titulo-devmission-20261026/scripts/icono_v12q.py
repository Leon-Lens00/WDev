"""Round counter icon for Dev Mission v12q (31/10/2026): BLP and model, written without PIL.

A plain red biohazard sign, in the place of the day clock. The model is HealthIconTauren with a centred, larger quad and this texture.

Usage: icono_v12q.py IN_MDX OUT_MDX OUT_BLP
"""
from math import atan2, cos, hypot, pi, sin
from pathlib import Path
import struct
import sys

SIZE = 256
HALF = 18.
TEXTURE = 'UI\\HealthBarsHorizontal\\RondaIcono.blp'


def inside(x, y):
    r = hypot(x, y)
    for k in range(3):
        a = pi / 2 + k * 2 * pi / 3
        cx, cy = 0.46 * cos(a), 0.46 * sin(a)
        ix, iy = 0.64 * cos(a), 0.64 * sin(a)
        if hypot(x - cx, y - cy) < 0.46 and hypot(x - ix, y - iy) > 0.33:
            return True
    if 0.34 < r < 0.42:
        return True
    return False


def image():
    pixels = []
    for j in range(SIZE):
        for i in range(SIZE):
            hit = 0
            for sj in range(3):
                for si in range(3):
                    hit += inside(((i + (si + .5) / 3) / SIZE - .5) * 2, (.5 - (j + (sj + .5) / 3) / SIZE) * 2)
            pixels.append(hit * 255 // 9)
    return pixels


def down(a, w, h):
    n = max(1, w // 2), max(1, h // 2)
    return [(a[y * 2 * w + x * 2] + a[y * 2 * w + x * 2 + 1] + a[(y * 2 + 1) * w + x * 2] + a[(y * 2 + 1) * w + x * 2 + 1]) // 4
            for y in range(n[1]) for x in range(n[0])], n[0], n[1]


def blp(alpha):
    # Same BLP1 paletted layout as hud-calibracion/scripts/grid.py; every texel is the same red, only alpha varies.
    bgra = b''.join(bytes((176 + i * 79 // 255,) * 3 + (0,)) for i in range(256))
    levels = []
    a, w, h = alpha, SIZE, SIZE
    while True:
        levels.append(bytes(255 for _ in a) + bytes(a))
        if w == 1:
            break
        a, w, h = down(a, w, h)
    offsets, p = [], 156 + 1024
    for level in levels:
        offsets.append(p)
        p += len(level)
    head = b'BLP1' + struct.pack('<6I', 1, 8, SIZE, SIZE, 4, 1)
    head += struct.pack('<16I', *(offsets + [0] * (16 - len(offsets))))
    head += struct.pack('<16I', *([len(x) for x in levels] + [0] * (16 - len(levels))))
    return head + bgra + b''.join(levels)


def model(src):
    b = bytearray(src)
    p = b.index(b'VRTX')
    assert struct.unpack_from('<I', b, p + 4)[0] == 4
    for i, (y, z) in enumerate(((-HALF, HALF), (HALF, HALF), (HALF, -HALF), (-HALF, -HALF))):
        struct.pack_into('<3f', b, p + 8 + 12 * i, -0.04, y, z)
    t = b.index(b'TEXS')
    old = b.index(b'ReplaceableTextures', t)
    b[old:old + 260] = TEXTURE.encode().ljust(260, b'\0')
    return bytes(b)


if __name__ == '__main__':
    Path(sys.argv[2]).write_bytes(model(Path(sys.argv[1]).read_bytes()))
    Path(sys.argv[3]).write_bytes(blp(image()))
    print('ok')
