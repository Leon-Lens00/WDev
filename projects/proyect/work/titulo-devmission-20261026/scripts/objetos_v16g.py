#!/usr/bin/env python3
"""Objetos de v16g (08/11/2026), a petición de Leon tras el vídeo de v16f: las unidades del tutorial no huyen al
recibir daño. 'ufle' (Can Flee) = 0 en 'nmcf' (tabla original) y 'nj02' (jefe de la oleada 2, tabla propia).
Afecta también a esos dos tipos en la partida real. Lo demás del w3u queda igual.
Uso: objetos_v16g.py ENTRADA.w3u SALIDA.w3u (war3map.w3u de v16f)
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import encode, parse

NO_FLEE = (b'ufle', 0, struct.pack('<i', 0), b'\0\0\0\0')
b = Path(sys.argv[1]).read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
n = 0
for t, clave in ((0, b'nmcf'), (1, b'nj02')):
    for fila in tablas[t]:
        if (fila[0] if t == 0 else fila[1]) == clave:
            assert not any(m[0] == b'ufle' for m in fila[2]), clave
            fila[2].append(NO_FLEE)
            n += 1
assert n == 2, n
sal = encode(version, tablas)
assert encode(*parse(sal)) == sal
Path(sys.argv[2]).write_bytes(sal)
print('ufle 0: nmcf nj02')
