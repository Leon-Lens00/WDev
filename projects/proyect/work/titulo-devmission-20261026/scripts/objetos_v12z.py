#!/usr/bin/env python3
"""v12z: en war3map.doo, de los destructibles colocados solo quedan los árboles.

Quita los D0xx (iconos invisibles del inventario), barriles, barricadas, jaula, muros y bloqueadores de paso.
Los doodads de adorno no se tocan: no son destructibles y su paso ya va en war3map.wpm.
Uso: objetos_v12z.py IN_DOO OUT_DOO
"""
from collections import Counter
from pathlib import Path
import struct
import sys

QUITAR = {'LTex', 'LTbr', 'LTbx', 'LTbs', 'LTba', 'LOcg', 'ZTw1', 'ZTw3',
          'YTpb', 'YTpc', 'YTfb', 'YTfc', 'YTlb'}


def registros(b):
    p = 16
    for _ in range(struct.unpack_from('<I', b, 12)[0]):
        q = p + 38 + 4
        sets = struct.unpack_from('<I', b, q)[0]
        q += 4
        for _ in range(sets):
            q += 4 + 8 * struct.unpack_from('<I', b, q)[0]
        q += 4
        yield p, q
        p = q


if __name__ == '__main__':
    j_in, j_out = sys.argv[1:3]
    b = Path(j_in).read_bytes()
    n = struct.unpack_from('<I', b, 12)[0]
    salida = [b[:16]]
    quitados = Counter()
    fin = 16
    for p, q in registros(b):
        rid = b[p:p + 4].decode('latin-1')
        if rid in QUITAR or rid.startswith('D0'):
            quitados[rid] += 1
        else:
            salida.append(b[p:q])
        fin = q
    salida.append(b[fin:])
    r = bytearray(b''.join(salida))
    struct.pack_into('<I', r, 12, n - sum(quitados.values()))
    Path(j_out).write_bytes(r)
    print(n, '->', n - sum(quitados.values()), sum(quitados.values()), quitados.most_common())
