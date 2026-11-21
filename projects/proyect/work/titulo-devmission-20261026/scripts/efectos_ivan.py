#!/usr/bin/env python3
"""earthLOW.mdx de Twilight's Eve Final sin sombreado ni niebla (12/11/2026, Leon): con los modelos Dark Nights del
mapa la Tierra salía oscura. Pone Unshaded (0x1) y Unfogged (0x20) en las 4 capas; nada más cambia.
Uso: efectos_ivan.py ENTRADA.mdx SALIDA.mdx
"""
import struct, sys
b = bytearray(open(sys.argv[1], 'rb').read()); p = 4; n_capas = 0
while p < len(b):
    t = bytes(b[p:p + 4]); n = struct.unpack_from('<I', b, p + 4)[0]; q = p + 8
    if t == b'MTLS':
        e = q + n
        while q < e:
            ms = struct.unpack_from('<I', b, q)[0]; assert b[q + 12:q + 16] == b'LAYS'
            l = q + 20
            for _ in range(struct.unpack_from('<I', b, q + 16)[0]):
                ls, fm, sf = struct.unpack_from('<III', b, l)
                struct.pack_into('<I', b, l + 8, sf | 0x1 | 0x20); n_capas += 1; l += ls
            q += ms
    p += 8 + n
assert n_capas == 4, n_capas
open(sys.argv[2], 'wb').write(b)
print('earthLOW: unshaded + unfogged en', n_capas, 'capas')
