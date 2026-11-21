#!/usr/bin/env python3
"""Objetos de v14zo (07/11/2026): sólo war3map.imp, con los 14 sonidos de las rachas (racha-v14zo/, copiados de
WaveSys/resources/devmission-v096/war3mapImported) en war3mapImported\\. Las voces de los personajes son del juego.
Uso: objetos_v14zo.py IMP_ENTRADA IMP_SALIDA
"""
from pathlib import Path
import struct
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from v14zo_datos import SONIDOS

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
imp = src.read_bytes()
v, n = struct.unpack_from('<II', imp, 0)
i, nombres = 8, []
for _ in range(n):
    j = imp.index(b'\0', i + 1)
    nombres.append(imp[i + 1:j].decode('utf-8'))
    i = j + 1
assert i == len(imp)
nuevos = ['war3mapImported\\' + f for f in SONIDOS]
assert not set(nuevos) & set(nombres)
dst.write_bytes(struct.pack('<II', v, n + len(nuevos)) + imp[8:] + b''.join(bytes([13]) + p.encode() + b'\0' for p in nuevos))
print('imports', n + len(nuevos))
