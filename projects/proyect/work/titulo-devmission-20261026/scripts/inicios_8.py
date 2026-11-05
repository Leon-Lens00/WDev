"""Start locations for players 3-8 of the Dev Mission title copy (26/10/2026).

The base is the 2 player melee map Swamped Temple: player 1 at (-5376, 2688), player 2 at (2944, -5696) and
three expansion gold mines. Melee Initialization stays, so each new player gets a town hall and workers at its
start location: it needs a buildable, walkable square (24 x 24 pathing cells, 768 units, around a 512 unit
town hall) away from the other starts, mines and the map's regions. Players 3-5 go next to the expansion mines
(the side facing the map centre, as the editor's melee layouts do); 6-8 to the free buildable squares farthest
from every other start inside the melee area. Reads the extracted w3e, wpm and units; prints JSON.

Usage: inicios_8.py EXTRACTED_DIR
"""
from pathlib import Path
import json, math, struct, sys
import numpy as np

D = Path(sys.argv[1])
STARTS = [(-5376, 2688), (2944, -5696)]
EXPANSIONS = [(4864, -320), (-3840, -4160), (-64, 4608)]
MINES = [(-6080, 3072), (3328, -6400)] + EXPANSIONS
REGIONS = [(-3776, -704, -3136, -32), (-1248, -1600, 608, 256), (2208, 1984, 2528, 2272), (-2656, -5568, -2240, -5248),
           (-5920, -2272, -4352, -288), (160, 384, 672, 896), (896, -192, 1216, 64), (-1568, -480, -1312, -128)]
AREA = (-7680, -7680, 6144, 5888)
HALF = 12          # pathing cells: 24 x 24 = 768 units
NO_WALK, NO_BUILD = 0x02, 0x08

e = (D / 'war3map.w3e').read_bytes()
o = 13; o += 4 + 4 * struct.unpack_from('<i', e, o)[0]; o += 4 + 4 * struct.unpack_from('<i', e, o)[0]
ox, oy = struct.unpack_from('<ff', e, o + 8)
p = (D / 'war3map.wpm').read_bytes()
pw, ph = struct.unpack_from('<ii', p, 8)
cells = np.frombuffer(p, np.uint8, pw * ph, 16).reshape(ph, pw)
bad = (cells & (NO_WALK | NO_BUILD)) != 0
# Summed table: a square is free when it holds no blocked cell.
s = np.pad(bad.cumsum(0).cumsum(1), ((1, 0), (1, 0)))


def free(x, y):
    cx, cy = int((x - ox) // 32), int((y - oy) // 32)
    if cx - HALF < 0 or cy - HALF < 0 or cx + HALF > pw or cy + HALF > ph:
        return False
    a, b, c, d = cy - HALF, cy + HALF, cx - HALF, cx + HALF
    return s[b, d] - s[a, d] - s[b, c] + s[a, c] == 0


def clear(x, y, taken):
    if any(math.dist((x, y), t) < 2400 for t in taken) or any(math.dist((x, y), m) < 600 for m in MINES):
        return False
    return not any(x0 - 600 < x < x1 + 600 and y0 - 600 < y < y1 + 600 for x0, y0, x1, y1 in REGIONS)


taken = list(STARTS)
out = []
for mx, my in EXPANSIONS:
    best = None
    for r in range(640, 1281, 64):
        for k in range(32):
            a = 2 * math.pi * k / 32
            x, y = round((mx + r * math.cos(a)) / 64) * 64, round((my + r * math.sin(a)) / 64) * 64
            if free(x, y) and clear(x, y, taken):
                score = math.dist((x, y), (0, 0))
                if best is None or score < best[0]:
                    best = (score, x, y)
        if best:
            break
    assert best, f'no spot next to mine {mx, my}'
    taken.append(best[1:])
    out.append({'start': best[1:], 'mine': (mx, my)})
for _ in range(3):
    best = None
    for y in range(AREA[1], AREA[3] + 1, 128):
        for x in range(AREA[0], AREA[2] + 1, 128):
            if free(x, y) and clear(x, y, taken):
                score = min(math.dist((x, y), t) for t in taken)
                if best is None or score > best[0]:
                    best = (score, x, y)
    assert best, 'no free square'
    taken.append(best[1:])
    out.append({'start': best[1:], 'nearest_start': round(best[0])})
print(json.dumps({'origin': [ox, oy], 'wpm': [pw, ph], 'players_3_8': out}))
