"""Turn the title copy's war3map.w3i (version 25, 2 user players) into 8 user players (26/10/2026).

Players 3-8 copy player 1's record (user, same race, fixed start flag, priority flags cleared) with their own
id, name and start location from inicios.json. The single force already has every player (mask -1). Everything after the forces
(upgrades, tech, random groups and item tables) is copied as is. The parser stops with an error if the file
is not version 25 or does not re-encode byte for byte before the change.

Usage: w3i_8.py IN_W3I INICIOS_JSON OUT_W3I [--dump]
"""
from pathlib import Path
import json, struct, sys

src = Path(sys.argv[1]).read_bytes()


class R:
    def __init__(s, b): s.b, s.o = b, 0
    def i(s): v = struct.unpack_from('<i', s.b, s.o)[0]; s.o += 4; return v
    def f(s): v = struct.unpack_from('<f', s.b, s.o)[0]; s.o += 4; return v
    def c(s, n=1): v = s.b[s.o:s.o + n]; s.o += n; return v
    def z(s): e = s.b.index(b'\0', s.o); v = s.b[s.o:e]; s.o = e + 1; return v


r = R(src)
assert r.i() == 25
r.o = 12
for _ in range(3): r.z()
r.z()  # recommended players
r.o += 8 * 4 + 4 * 4 + 4 + 4 + 4 + 1
r.i(); r.z(); r.z(); r.z(); r.z()      # loading screen
r.i(); r.z(); r.z(); r.z(); r.z()      # game data set, prologue
r.i(); r.o += 4 * 3 + 4; r.i(); r.z(); r.c(1); r.c(4)   # fog, weather, sound env, light, water
head_end = r.o
n = r.i()
players = []
for _ in range(n):
    pid, typ, race, fixed = r.i(), r.i(), r.i(), r.i()
    name = r.z(); x, y = r.f(), r.f(); lo, hi = r.i(), r.i()
    players.append(dict(id=pid, type=typ, race=race, fixed=fixed, name=name, x=x, y=y, lo=lo, hi=hi))
nf = r.i()
forces = [dict(flags=r.i(), mask=r.i(), name=r.z()) for _ in range(nf)]
tail = src[r.o:]


def encode(players, forces):
    b = bytearray(src[:head_end]) + struct.pack('<i', len(players))
    for p in players:
        b += struct.pack('<iiii', p['id'], p['type'], p['race'], p['fixed']) + p['name'] + b'\0'
        b += struct.pack('<ffii', p['x'], p['y'], p['lo'], p['hi'])
    b += struct.pack('<i', len(forces))
    for f in forces:
        b += struct.pack('<ii', f['flags'], f['mask']) + f['name'] + b'\0'
    return bytes(b + tail)


assert encode(players, forces) == src, 'round trip differs'
if '--dump' in sys.argv:
    print(players, forces, len(tail)); sys.exit()
assert len(players) == 2 and [p['id'] for p in players] == [0, 1]
starts = [e['start'] for e in json.loads(Path(sys.argv[2]).read_text())['players_3_8']]
for k, (x, y) in enumerate(starts):
    p = dict(players[0], id=k + 2, name=b'Jugador %d' % (k + 3), x=float(x), y=float(y), lo=0, hi=0)
    players.append(p)
assert forces[0]['mask'] == -1
out = encode(players, forces)
Path(sys.argv[3]).write_bytes(out)
print(json.dumps({'players': [(p['id'], p['type'], p['race'], p['name'].decode(), p['x'], p['y']) for p in players],
                  'forces': [(f['flags'], hex(f['mask']), f['name'].decode()) for f in forces], 'bytes': len(out)}))
