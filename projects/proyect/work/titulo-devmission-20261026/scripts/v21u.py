#!/usr/bin/env python3
"""v21u (22/11/2026): las piezas de D.O.N por el aire también chocan con árboles y precipicios.

Leon (v21t): la esfera de Finish Buster (W de Trunks, vuela a 300) atravesaba árboles y precipicios; "que se comporte
como todos los demás". Don_Pon dejaba sin choque las piezas con altura de vuelo >= 150 (v16u). Se quita esa excepción:
toda pieza de Freezer, Trunks y Naruto que D.O.N coloca con Don_Pon se queda en el último punto libre, como las de
Goku (Gk_MisPaso no miraba la altura). El final sigue siendo el de D.O.N (la esfera explota ahí al acabar su vida).
Se mantiene el límite de 400 por paso (v21g).
Uso: v21u.py ENTRADA.j SALIDA.j [prueba]   (normal de v21t; prueba de v21t-prueba).
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


cambia("""    if u != null and GetUnitFlyHeight(u) < 150. then
        // v21g:""", """    // v21u: también por el aire (antes, altura >= 150 sin choque): árboles y precipicios paran toda pieza.
    if u != null then
        // v21g:""")
if prueba:
    cambia('lat\\\\v21t-', 'lat\\\\v21u-', src.count('lat\\\\v21t-'))
    cambia('v21t-don.txt', 'v21u-don.txt', src.count('v21t-don.txt'))
    assert 'lat\\\\v21t-' not in src and 'v21t-don.txt' not in src, 'quedan registros v21t'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21u', 'prueba' if prueba else 'normal')
