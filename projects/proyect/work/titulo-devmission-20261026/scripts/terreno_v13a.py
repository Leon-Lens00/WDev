#!/usr/bin/env python3
"""v13a: datos de terreno de IziPizi para Dev Mission.

De los destructibles quedan solo árboles; los bloqueadores salen y las dos salidas de la arena central se cierran con BTtw.
El árbol gigante B001 de IziPizi entra como BIz1, porque B001 ya existe en nuestro war3map.w3b.
Uso: terreno_v13a.py DIR_IZI DIR_BASE DIR_SALIDA
"""
from pathlib import Path
import struct
import sys

QUITAR = {'YTfb', 'YTfc', 'Ytlc'}
ID_NUEVO = b'BIz1'
ORIGEN_ARBOL = b'BTtw'
SALIDAS = [(-13632., y) for y in range(-4192, -3487, 64)] + [(x, -1856.) for x in range(-11584, -10303, 64)]


def registros(b):
    p = 16
    for _ in range(struct.unpack_from('<I', b, 12)[0]):
        q = p + 42
        sets = struct.unpack_from('<I', b, q)[0]
        q += 4
        for _ in range(sets):
            q += 4 + 8 * struct.unpack_from('<I', b, q)[0]
        yield p, q + 4
        p = q + 4


def doo(b):
    salida, modelo, ultimo = [], None, 0
    for p, q in registros(b):
        r = bytearray(b[p:q])
        rid = bytes(r[:4])
        ultimo = max(ultimo, struct.unpack_from('<I', r, len(r) - 4)[0])
        if rid.decode('latin-1') in QUITAR:
            continue
        if rid == b'B001':
            r[:4] = ID_NUEVO
        if rid == ORIGEN_ARBOL and modelo is None and len(r) == 50:
            modelo = bytes(r)
        salida.append(bytes(r))
    fin = q
    for i, (x, y) in enumerate(SALIDAS):
        r = bytearray(modelo)
        struct.pack_into('<ff', r, 8, x, y)
        struct.pack_into('<I', r, 4, i % 10)
        struct.pack_into('<fff', r, 24, 1., 1., 1.)
        struct.pack_into('<I', r, len(r) - 4, ultimo + 1 + i)
        salida.append(bytes(r))
    return b[:12] + struct.pack('<I', len(salida)) + b''.join(salida) + b[fin:]


def saltar_objeto(b, p):
    q = p + 8
    n = struct.unpack_from('<I', b, q)[0]
    q += 4
    for _ in range(n):
        tipo = struct.unpack_from('<I', b, q + 4)[0]
        q += 8
        if tipo == 3:
            q = b.index(b'\0', q) + 1
        else:
            q += 4
        q += 4
    return q


def w3b(nuestro, izi):
    p = 8
    for _ in range(struct.unpack_from('<I', nuestro, 4)[0]):
        p = saltar_objeto(nuestro, p)
    cuenta = p
    fin = p + 4
    for _ in range(struct.unpack_from('<I', nuestro, cuenta)[0]):
        fin = saltar_objeto(nuestro, fin)
    assert fin == len(nuestro), (fin, len(nuestro))
    assert ID_NUEVO not in nuestro
    i = izi.index(b'BTtwB001')
    objeto = izi[i:saltar_objeto(izi, i)]
    objeto = objeto[:4] + ID_NUEVO + objeto[8:]
    n = struct.unpack_from('<I', nuestro, cuenta)[0] + 1
    return nuestro[:cuenta] + struct.pack('<I', n) + nuestro[cuenta + 4:] + objeto


def w3i(nuestro, izi):
    r = bytearray(nuestro)
    assert r[0x78] == ord('Z') and izi[0x78] == ord('B')
    r[0x3C:0x74] = izi[0x3C:0x74]
    r[0x78] = izi[0x78]
    return bytes(r)


if __name__ == '__main__':
    izi, base, out = map(Path, sys.argv[1:4])
    out.mkdir(exist_ok=True)
    for f in ('war3map.w3e', 'war3map.wpm', 'war3map.shd'):
        (out / f).write_bytes((izi / f).read_bytes())
    d = doo((izi / 'war3map.doo').read_bytes())
    (out / 'war3map.doo').write_bytes(d)
    (out / 'war3map.w3b').write_bytes(w3b((base / 'war3map.w3b').read_bytes(), (izi / 'war3map.w3b').read_bytes()))
    (out / 'war3map.w3i').write_bytes(w3i((base / 'war3map.w3i').read_bytes(), (izi / 'war3map.w3i').read_bytes()))
    (out / 'war3map.mmp').write_bytes(struct.pack('<II', 0, 0))
    print('doo', struct.unpack_from('<I', d, 12)[0], 'salidas', len(SALIDAS))
