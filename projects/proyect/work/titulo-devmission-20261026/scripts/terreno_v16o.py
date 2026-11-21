#!/usr/bin/env python3
"""Terreno del tutorial v16o (08/11/2026): en vez del plano azul, el recinto del tutorial (X 6000..10000,
Y 7500..9500) copia las texturas de la aldea del área jugable (casas VillageBuilding en X ~1100..1600,
Y ~-1900..-1450) con el desplazamiento (DX, DY), y sus árboles, casas y adornos.
- Sólo textura y variación de cada vértice: alturas, capas, agua y acantilados del recinto siguen llanos (z 209,5).
- Objetos: los del rectángulo fuente que caen dentro del recinto, menos los del carril del tutorial (donde camina
  el Tauren, aparecen los enemigos y está la caja) con margen, y menos juncos de río y piezas de agua.
  Se añaden al final de la lista de war3map.doo, antes de los doodads especiales, con z del suelo del recinto e
  id de editor nuevo. Los árboles (destructibles) ponen su trazado al cargar; las casas no se graban en el wpm:
  quedan fuera de todo recorrido del guion.
Uso: terreno_v16o.py DIR_ENTRADA DIR_SALIDA (war3map.w3e y war3map.doo)
"""
from pathlib import Path
import struct, sys

DX, DY = 6100, 10550
REC = (6000, 10000, 7500, 9500)
CARRIL = (7850, 9750, 7750, 8750)
Z = 209.5
FUERA = {'LPrs', 'ZWsf', 'LWw0', 'LOsm'}
ARBOLES = {'ZTtw', 'LTlt', 'VTlt', 'ZTtc'}
ESTRUCTURAS = {'VSvb', 'YS15', 'YS07', 'YS03', 'YS09', 'YS13', 'ZSrb', 'LSwl'}

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)

# Texturas.
b = bytearray((src / 'war3map.w3e').read_bytes())
p = 13
nt = struct.unpack_from('<I', b, p)[0]
p += 4 + nt * 4
p += 4 + struct.unpack_from('<I', b, p)[0] * 4
mx, my = struct.unpack_from('<II', b, p)
ox, oy = struct.unpack_from('<ff', b, p + 8)
p += 16
orig = bytes(b)
copiados = 0
for j in range(my):
    y = oy + j * 128
    if not REC[2] <= y <= REC[3]:
        continue
    for i in range(mx):
        x = ox + i * 128
        if not REC[0] <= x <= REC[1]:
            continue
        q = p + (j * mx + i) * 7
        assert orig[q:q + 4] == bytes.fromhex('46218e24') and orig[q + 6] == 3, (x, y, orig[q:q + 7].hex())
        si, sj = i - round(DX / 128), j - round(DY / 128)
        sx, sy = ox + si * 128, oy + sj * 128
        assert abs((x - sx) - DX) <= 64 and abs((y - sy) - DY) <= 64, (x, sx, y, sy)
        s = p + (sj * mx + si) * 7
        b[q + 4] = (orig[q + 4] & 0xF0) | (orig[s + 4] & 0x0F)
        b[q + 5] = orig[s + 5]
        copiados += 1
(dst / 'war3map.w3e').write_bytes(b)

# Objetos.
d = (src / 'war3map.doo').read_bytes()
assert d[:4] == b'W3do'
ver, sub, n = struct.unpack_from('<iii', d, 4)
assert (ver, sub) == (8, 11), (ver, sub)
pos, ents, eids = 16, [], []
for k in range(n):
    q = pos
    pos += 38
    itp, ns = struct.unpack_from('<ii', d, pos)
    pos += 8
    for s in range(ns):
        ni, = struct.unpack_from('<i', d, pos)
        pos += 4 + 8 * ni
    eid, = struct.unpack_from('<i', d, pos)
    pos += 4
    ents.append((q, pos))
    eids.append(eid)
cola = d[pos:]
assert struct.unpack_from('<i', cola, 0)[0] == 0  # versión de los doodads especiales
nuevo = max(eids) + 1
extra, tipos = [], {}
for q, e in ents:
    i = d[q:q + 4].decode('latin-1')
    x, y = struct.unpack_from('<ff', d, q + 8)
    tx, ty = x + DX, y + DY
    if i in FUERA or not (REC[0] + 100 <= tx <= REC[1] - 100 and REC[2] + 100 <= ty <= REC[3] - 50):
        continue
    m = 260 if i in ESTRUCTURAS else 120 if i in ARBOLES else 60
    if CARRIL[0] - m <= tx <= CARRIL[1] + m and CARRIL[2] - m <= ty <= CARRIL[3] + m:
        continue
    r = bytearray(d[q:e])
    struct.pack_into('<fff', r, 8, tx, ty, Z)
    struct.pack_into('<i', r, len(r) - 4, nuevo)
    nuevo += 1
    extra.append(bytes(r))
    tipos[i] = tipos.get(i, 0) + 1
o = bytearray(d[:pos]) + b''.join(extra) + cola
struct.pack_into('<i', o, 12, n + len(extra))
(dst / 'war3map.doo').write_bytes(bytes(o))
print('vertices copiados', copiados, 'objetos', len(extra), dict(sorted(tipos.items(), key=lambda t: -t[1])))
