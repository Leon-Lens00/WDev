#!/usr/bin/env python3
"""Objetos de v14zl (07/11/2026): vida base (uhpm) de las élites 'ne00'..'ne09' de 320 a 160, el 20 % de los 800 del
jefe de la ronda 1. v14zl.py suma el resto al aparecer. Lo demás del w3u queda igual.
Uso: objetos_v14zl.py ENTRADA.w3u SALIDA.w3u (war3map.w3u extraído de v14zk)
"""
from pathlib import Path
import struct
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import encode, parse

ent, sal = Path(sys.argv[1]), Path(sys.argv[2])
b = ent.read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
hechos = set()
for n, tabla in enumerate(tablas):
    for i, fila in enumerate(tabla):
        clave = (fila[0] if n == 0 else fila[1]).decode()
        if clave in {'ne0%d' % k for k in range(10)}:
            mods = []
            for mid, ty, v, end in fila[2]:
                if mid == b'uhpm':
                    assert struct.unpack('<i', v)[0] == 320, (clave, v)
                    v = struct.pack('<i', 160)
                    hechos.add(clave)
                mods.append((mid, ty, v, end))
            tabla[i] = (fila[0], fila[1], mods)
assert len(hechos) == 10, hechos
sal.write_bytes(encode(version, tablas))
print('ok', sorted(hechos))
