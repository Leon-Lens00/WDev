#!/usr/bin/env python3
"""v21t (22/11/2026): la W de Trunks (A0GV Finish Buster) pasa de Serpent Ward (AOsw) a Channel (ANcl).

Registro de v21s-prueba: 1 de 6 W con "copia NO ACEPTA ... ward". AOsw coloca un guardián y el juego rechaza la orden
si el punto no se puede pisar; el código de D.O.N sólo usa el id y el punto, no el guardián (Hwe2 ya era 0).
Channel: blanco punto (Ncl2 2), visible (Ncl3 1), sin espera ni arte, orden propia "clusterrockets" (sin uso en el
mapa), para no chocar con otra habilidad de la copia hCpT. Se quitan las filas Hwe2 de AOsw; el resto (alcance 2500,
sin enfriamiento ni maná, 4 niveles, textos) sigue igual.
Uso: objetos_v21t.py ENTRADA.w3a SALIDA.w3a
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

ver, tabs = parse_w3a(Path(sys.argv[1]).read_bytes())
Z = b'\x00\x00\x00\x00'
hecho = 0
for t in tabs:
    for k, (base, nid, mods) in enumerate(t):
        if nid != b'A0GV':
            continue
        assert base == b'AOsw', base
        n = len(mods)
        mods = [m for m in mods if m[0] != b'Hwe2']
        assert n - len(mods) == 4, n - len(mods)
        assert not any(m[0].startswith(b'Ncl') for m in mods)
        for lv in range(1, 5):
            mods += [(b'Ncl1', 2, lv, 1, Z, Z), (b'Ncl2', 0, lv, 2, struct.pack('<i', 2), Z),
                     (b'Ncl3', 0, lv, 3, struct.pack('<i', 1), Z), (b'Ncl4', 2, lv, 4, Z, Z),
                     (b'Ncl5', 0, lv, 5, Z, Z), (b'Ncl6', 3, lv, 6, b'clusterrockets', Z)]
        t[k] = (b'ANcl', nid, mods)
        hecho += 1
assert hecho == 1, hecho
Path(sys.argv[2]).write_bytes(encode_w3a(ver, tabs))
print('v21t: A0GV Channel clusterrockets')
