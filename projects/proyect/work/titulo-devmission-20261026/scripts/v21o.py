#!/usr/bin/env python3
"""v21o (22/11/2026): sobre v21n; los arreglos de Golden Form y de la W están en los objetos (objetos_v21o.py).
El j sólo cambia en prueba: registros lat\\v21o-* y el registro de Golden da el tipo del cuerpo (hFrz / hFrG) en lugar
del nombre, para ver si la transformación se hizo.
Uso: v21o.py ENTRADA.j SALIDA.j [prueba]   (normal de v21n; prueba de v21n-prueba).
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')


def cambia(viejo, nuevo, veces=1):
    global src
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


if prueba:
    cambia('set Cop_Log="freezer Golden bono "+R2S(Fz_Bono[fzp])+" tipo "+GetUnitName(fzc)\n',
           'set Cop_Log="freezer Golden bono "+R2S(Fz_Bono[fzp])+" tipo "+Dia_Id(GetUnitTypeId(fzc))\n')
    cambia('set Cop_Log="freezer Golden fin tipo "+GetUnitName(fzc)\n',
           'set Cop_Log="freezer Golden fin tipo "+Dia_Id(GetUnitTypeId(fzc))\n')
    cambia('lat\\\\v21n-', 'lat\\\\v21o-', src.count('lat\\\\v21n-'))
    cambia('v21n-don.txt', 'v21o-don.txt', src.count('v21n-don.txt'))
    assert 'lat\\\\v21n-' not in src and 'v21n-don.txt' not in src, 'quedan registros v21n'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21o', 'prueba' if prueba else 'normal')
