#!/usr/bin/env python3
"""Datos del mapa editable de puntos de oleada: terreno de v13b, solo inicios y un marcador 'nPto' en el centro.

También lee los marcadores de un war3mapUnits.doo guardado por el editor.
Uso: puntos_editor_v13b.py crear DIR_FUENTE DIR_V13B DIR_SALIDA | leer war3mapUnits.doo
"""
from pathlib import Path
import struct
import sys

CENTRO = -192., -512.
NEUTRAL_PASIVO = 15


def registros(b):
    """Devuelve (inicio, fin) de cada unidad de un war3mapUnits.doo clásico, versión 8."""
    p = 16
    for _ in range(struct.unpack_from('<I', b, 12)[0]):
        i = p
        p += 4 + 4 + 12 + 4 + 12 + 1 + 4 + 2 + 4 + 4 + 4
        sets = struct.unpack_from('<I', b, p)[0]
        p += 4
        for _ in range(sets):
            p += 4 + 8 * struct.unpack_from('<I', b, p)[0]
        p += 4 + 4 + 4 + 12
        p += 4 + 8 * struct.unpack_from('<I', b, p)[0]
        p += 4 + 12 * struct.unpack_from('<I', b, p)[0]
        azar = struct.unpack_from('<I', b, p)[0]
        p += 4
        if azar == 0:
            p += 4
        elif azar == 1:
            p += 8
        else:
            p += 4 + 8 * struct.unpack_from('<I', b, p)[0]
        p += 4 + 4 + 4
        yield i, p
    assert p == len(b), (p, len(b))


def marcador(modelo, ident):
    """Copia un inicio sin datos propios y lo convierte en nPto neutral."""
    r = bytearray(modelo)
    r[:8] = b'nPto' + struct.pack('<I', 0)
    struct.pack_into('<fff', r, 8, CENTRO[0], CENTRO[1], 0.)
    struct.pack_into('<f', r, 20, 4.712389)
    struct.pack_into('<I', r, 37, NEUTRAL_PASIVO)
    struct.pack_into('<I', r, len(r) - 4, ident)
    return bytes(r)


def crear(fuente, v13b, out):
    u = (fuente / 'war3mapUnits.doo').read_bytes()
    rs = list(registros(u))
    inicios = [u[a:c] for a, c in rs if u[a:a + 4] == b'sloc']
    assert len(inicios) == 2
    ident = max(struct.unpack_from('<I', u, c - 4)[0] for _, c in rs) + 1
    filas = inicios + [marcador(inicios[0], ident)]
    (out / 'war3mapUnits.doo').write_bytes(u[:12] + struct.pack('<I', len(filas)) + b''.join(filas))
    w = (v13b / 'war3map.w3u').read_bytes()
    obj = w[w.index(b'ncopnPto'):]
    (out / 'war3map.w3u').write_bytes(w[:4] + struct.pack('<II', 0, 1) + obj)
    (out / 'war3map.doo').write_bytes((v13b / 'war3map.doo').read_bytes())
    (out / 'war3map.imp').write_bytes(struct.pack('<II', 1, 0))
    (out / 'war3map.w3r').write_bytes(struct.pack('<II', 5, 0))


def leer(archivo):
    u = Path(archivo).read_bytes()
    for a, _ in registros(u):
        if u[a:a + 4] == b'nPto':
            yield struct.unpack_from('<ff', u, a + 8)


if __name__ == '__main__':
    if sys.argv[1] == 'crear':
        fuente, v13b, out = map(Path, sys.argv[2:5])
        out.mkdir(exist_ok=True)
        crear(fuente, v13b, out)
    else:
        print(list(leer(sys.argv[2])))
