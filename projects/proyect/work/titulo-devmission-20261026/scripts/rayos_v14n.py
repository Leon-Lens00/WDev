#!/usr/bin/env python3
"""v14n: Splats\\LightningData.slk del mapa = el del juego (War3x.mpq de 1.27b, el que manda) + los 9 rayos de ShootingGay 0.7.

El de ShootingGay parte de una tabla sin LEAS (Magic Leash), así que no se importa tal cual: se copian sus filas nuevas
sobre la del juego. B3LS trae la carpeta en la columna del comentario (le falta Dir); aquí va en Dir.
Rayos (ancho en el suelo; texturas en ReplaceableTextures\\Weather): AIMI línea fina (3), ARLE flechas (16), BLNK/BLNP
blink (32), BOLG rayo grueso (128), BLSR/B3LS láser azul (256), BLAS láser azul y WLSR blanco (768).
Uso: rayos_v14n.py SLK_JUEGO SLK_SHOOTINGGAY SALIDA
"""
from pathlib import Path
import sys


def filas(p):
    t = Path(p).read_text(encoding='latin-1').replace('\r', '')
    r, y, x = {}, None, None
    for l in t.split('\n'):
        if not l.startswith('C;'):
            continue
        f = {q[0]: q[1:] for q in l.split(';')[1:] if q}
        y = int(f['Y']) if 'Y' in f else y
        x = int(f['X']) if 'X' in f else x
        r.setdefault(y, {})[x] = f.get('K', '')
    cab = r.pop(1)
    return cab, [r[k] for k in sorted(r)]


cab, juego = filas(sys.argv[1])
cab_sg, sg = filas(sys.argv[2])
assert cab == cab_sg, 'columnas distintas'
col = {v: k for k, v in cab.items()}
nombres = {f[1] for f in juego}
nuevas = [dict(f) for f in sg if f[1] not in nombres]
assert [f[1] for f in nuevas] == ['"%s"' % n for n in ('AIMI', 'BLAS', 'ARLE', 'BLNK', 'BOLG', 'BLSR', 'BLNP', 'WLSR', 'B3LS')], nuevas
for f in nuevas:
    if f.get(col['"Dir"']) is None:
        f[col['"comment"']], f[col['"Dir"']] = '"Blue Laser 3"', '"ReplaceableTextures\\Weather"'
tabla = [cab] + juego + nuevas
lineas = ['ID;PWXL;N;E', f'B;Y{len(tabla)};X{len(cab)};D0']
for y, f in enumerate(tabla, 1):
    for x in sorted(f):
        if f[x] is not None:
            lineas.append(f'C;X{x};Y{y};K{f[x]}' if x == 1 else f'C;X{x};K{f[x]}')
lineas.append('E')
Path(sys.argv[3]).write_bytes(('\r\n'.join(lineas) + '\r\n').encode('latin-1'))
print('ok', len(juego), 'del juego +', len(nuevas), 'nuevas')
