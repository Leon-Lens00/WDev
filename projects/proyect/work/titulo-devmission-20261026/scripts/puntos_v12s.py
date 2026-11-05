"""Spawn points for Dev Mission v12s (31/10/2026): an even grid over the area a character can walk to from the start.

war3map.wpm only holds terrain and doodads. Trees and pathing blockers are destructables of war3map.doo (life byte other than 255), and in
this map they close whole pockets, so each one marks its footprint as blocked. The flood keeps the body of a unit clear of walls.

Usage: puntos_v12s.py EXTRACTED_DIR  (prints a summary)
"""
from collections import deque
from pathlib import Path
import struct
import sys

START = 1400., -23000.
STEP = 11  # pathing cells of 32
BODY = 1  # cells kept clear around a walking unit
MARGIN = 3  # cells kept clear around a spawn
LIMIT = 100


def load(d):
    b = Path(d, 'war3map.w3e').read_bytes()
    p = 13
    p += 4 + 4 * struct.unpack_from('<I', b, p)[0]
    p += 4 + 4 * struct.unpack_from('<I', b, p)[0]
    ox, oy = struct.unpack_from('<ff', b, p + 8)
    q = Path(d, 'war3map.wpm').read_bytes()
    pw, ph = struct.unpack_from('<II', q, 8)
    return ox, oy, pw, ph, q[16:]


def destructables(d):
    b = Path(d, 'war3map.doo').read_bytes()
    p = 16
    out = []
    for _ in range(struct.unpack_from('<I', b, 12)[0]):
        x, y = struct.unpack_from('<ff', b, p + 8)
        p += 36
        life = b[p + 1]
        p += 2
        sets = struct.unpack_from('<iI', b, p)[1]
        p += 8
        for _ in range(sets):
            p += 4 + 8 * struct.unpack_from('<I', b, p)[0]
        p += 4
        if life != 255:
            out.append((x, y))
    return out


def reachable(d):
    ox, oy, pw, ph, wpm = load(d)
    blocked = set()
    for x, y in destructables(d):
        i, j = int((x - ox) / 32), int((y - oy) / 32)
        blocked.update((i + a, j + b) for a in range(-2, 2) for b in range(-2, 2))
    walk = lambda i, j: 0 <= i < pw and 0 <= j < ph and not wpm[j * pw + i] & 2 and (i, j) not in blocked
    clear = lambda i, j, r: all(walk(i + a, j + b) for a in range(-r, r + 1) for b in range(-r, r + 1))
    s = int((START[0] - ox) / 32), int((START[1] - oy) / 32)
    seen = {s}
    q = deque([s])
    while q:
        i, j = q.popleft()
        for n in ((i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)):
            if n not in seen and clear(*n, BODY):
                seen.add(n)
                q.append(n)
    return seen, clear, ox, oy


def points(d):
    seen, clear, ox, oy = reachable(d)
    x0, y0 = min(c[0] for c in seen), min(c[1] for c in seen)
    out = [(ox + i * 32, oy + j * 32) for i, j in sorted(seen) if not (i - x0) % STEP and not (j - y0) % STEP and clear(i, j, MARGIN)]
    assert 0 < len(out) <= LIMIT, len(out)
    return out, len(seen)


if __name__ == '__main__':
    p, n = points(sys.argv[1])
    print(len(p), 'puntos de', n, 'celdas; x', min(c[0] for c in p), max(c[0] for c in p), 'y', min(c[1] for c in p), max(c[1] for c in p))
