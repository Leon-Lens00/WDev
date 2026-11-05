#!/usr/bin/env python3
"""v13b: datos de terreno de Swamped Temple 3.0 para Dev Mission.

De los destructibles quedan solo árboles, igual que en v12z y v13a. El minimapa es el del mapa fuente.
Añade el tipo de unidad 'nPto', marcador de los puntos de oleada.
Uso: terreno_v13b.py DIR_FUENTE DIR_BASE DIR_SALIDA
"""
from pathlib import Path
import struct
import sys

ARBOLES = {b'ZTtw', b'ZTtc', b'LTlt', b'VTlt'}
QUITAR = {b'YTpb', b'YTpc', b'YTfb', b'YTfc', b'YTlb', b'ZTw1', b'ZTw3', b'LTex', b'LTbr', b'LTbs', b'LTbx', b'LTba', b'LTcr', b'LOcg'}
NOMBRE = b'Punto de oleada'


def doo(b):
    salida = []
    p = 16
    for _ in range(struct.unpack_from('<I', b, 12)[0]):
        q = p + 42
        sets = struct.unpack_from('<I', b, q)[0]
        q += 4
        for _ in range(sets):
            q += 4 + 8 * struct.unpack_from('<I', b, q)[0]
        q += 4
        if b[p:p + 4] not in QUITAR:
            salida.append(b[p:q])
        p = q
    return b[:12] + struct.pack('<I', len(salida)) + b''.join(salida) + b[p:]


def w3u(b):
    version, originales = struct.unpack_from('<II', b, 0)
    p = 8
    for _ in range(originales):
        p += 8
        n = struct.unpack_from('<I', b, p)[0]
        p += 4
        for _ in range(n):
            tipo = struct.unpack_from('<I', b, p + 4)[0]
            p += 8
            p = b.index(b'\0', p) + 1 if tipo == 3 else p + 4
            p += 4
    n = struct.unpack_from('<I', b, p)[0]
    assert b'nPto' not in b
    objeto = b'ncopnPto' + struct.pack('<I', 1) + b'unam' + struct.pack('<I', 3) + NOMBRE + b'\0\0\0\0\0'
    return b[:p] + struct.pack('<I', n + 1) + b[p + 4:] + objeto


def w3i(nuestro, fuente):
    r = bytearray(nuestro)
    assert r[0x78] == ord('Z') and fuente[0x78] == ord('Z')
    r[0x3C:0x74] = fuente[0x3C:0x74]
    return bytes(r)


if __name__ == '__main__':
    fuente, base, out = map(Path, sys.argv[1:4])
    out.mkdir(exist_ok=True)
    for f in ('war3map.w3e', 'war3map.wpm', 'war3map.shd', 'war3mapMap.blp'):
        (out / f).write_bytes((fuente / f).read_bytes())
    d = doo((fuente / 'war3map.doo').read_bytes())
    (out / 'war3map.doo').write_bytes(d)
    (out / 'war3map.w3u').write_bytes(w3u((base / 'war3map.w3u').read_bytes()))
    (out / 'war3map.w3i').write_bytes(w3i((base / 'war3map.w3i').read_bytes(), (fuente / 'war3map.w3i').read_bytes()))
    (out / 'war3map.mmp').write_bytes(struct.pack('<II', 0, 0))
    print('doo', struct.unpack_from('<I', d, 12)[0])
