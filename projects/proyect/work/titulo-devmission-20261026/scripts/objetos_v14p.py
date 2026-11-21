#!/usr/bin/env python3
"""Objetos de v14p: las habilidades de arma Aw00..Aw06 pasan de 3 a 6 niveles (un nivel por tier).

Cada nivel nuevo copia los campos del nivel 1 (canal sin objetivo, la orden propia del arma y sus opciones); sin eso
los niveles 4..6 tomarían los de Canal y la orden «channel». Título y texto de cada nivel salen de armas_v14p.

Uso: objetos_v14p.py DIR_ENTRADA DIR_SALIDA (war3map.w3a)
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a
from armas_v14p import ARMAS, TIERS, rasgo

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
Z = b'\0\0\0\0'

version, tablas = parse_w3a((src / 'war3map.w3a').read_bytes())
n = 0
for i, f in enumerate(tablas[1]):
    if not (f[1].startswith(b'Aw0') and f[1][3:] in b'0123456'):
        continue
    c = int(f[1][3:])
    mods = f[2]
    assert struct.unpack('<I', next(m[4] for m in mods if m[0] == b'alev'))[0] == 3, f[1]
    tecla = next(m[4] for m in mods if m[0] == b'ahky').decode()
    nuevos = [(m[0], m[1], m[2], m[3], struct.pack('<I', TIERS), m[5]) if m[0] == b'alev' else m for m in mods if m[2] == 0]
    plantilla = [m for m in mods if m[2] == 1 and m[0] not in (b'atp1', b'aub1')]
    assert len(plantilla) == 10 and any(m[0] == b'Ncl6' for m in plantilla), f[1]
    for t in range(1, TIERS + 1):
        a = ARMAS[c * TIERS + t - 1]
        nuevos += [(b'atp1', 3, t, 0, f'{a[0]} T{t} (|cffffcc00{tecla}|r)'.encode('utf-8'), Z),
                   (b'aub1', 3, t, 0, f'Activa esta arma. {rasgo(c, a)}.'.encode('utf-8'), Z)]
        nuevos += [(m[0], m[1], t, m[3], m[4], m[5]) for m in plantilla]
    tablas[1][i] = (f[0], f[1], nuevos)
    n += 1
assert n == 7, n
salida = encode_w3a(version, tablas)
assert encode_w3a(*parse_w3a(salida)) == salida and parse_w3a(salida)[1][1] == tablas[1]
(dst / 'war3map.w3a').write_bytes(salida)
print('w3a: 7 habilidades de arma con', TIERS, 'niveles')
