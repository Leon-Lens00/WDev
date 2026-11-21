#!/usr/bin/env python3
"""v20k-prueba (20/11/2026): sobre v20j-prueba. En la partida de Leon, las copias 'hMg1'..'hMg3' de v20j (pistas de las
raíces inclinadas y después billboard) no se vieron y desde la primera ningún modelo nuevo volvió a dibujarse en el
cuadro. Se sustituyen los tres MDX (mismas rutas y tipos) por el método del retrato: ayudante MvpVista con giro fijo
en secuencia global bajo el hueso billboard, sin tocar las pistas del original (mvp_frente.cjs con grados).
El j sólo cambia el prefijo de los registros.
Uso: v20k.py ENTRADA.j SALIDA.j prueba   (de v20j-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
assert len(sys.argv) > 3 and sys.argv[3] == 'prueba'
for viejo, nuevo in (('lat\\\\v20j-', 'lat\\\\v20k-'), ('v20j-don.txt', 'v20k-don.txt')):
    assert viejo in src, viejo
    src = src.replace(viejo, nuevo)
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20k prueba')
