#!/usr/bin/env python3
"""v21l (22/11/2026): la R en Ultra Instinto avanza libre, sin frenar en árboles ni pendientes.

Leon: "en Ultra Instinto (R) ahi si que avanze tranquilamente el dummy ya que spell en area". La copia avanzaba 100 por tick
con Don_Pon (traza y choca); ahora se mueve con SetUnitX/SetUnitY, sin trazado. El resto de técnicas siguen con choque.
Uso: v21l.py ENTRADA.j SALIDA.j [prueba]   (normal de v21k; prueba de v21k-prueba).
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('''set G2V_Point[4412]=PolarProjectionBJ(G2V_Point[4410],100.,G2V_Angle[4410])
call Don_Pon(G2V_Caster[4410],G2V_Point[4412])
''', '''set G2V_Point[4412]=PolarProjectionBJ(G2V_Point[4410],100.,G2V_Angle[4410])
// v21l: técnica de área: la copia avanza libre, sin choque con árboles ni pendientes.
call SetUnitX(G2V_Caster[4410],GetLocationX(G2V_Point[4412]))
call SetUnitY(G2V_Caster[4410],GetLocationY(G2V_Point[4412]))
''')
if prueba:
    cambia('lat\\\\v21k-', 'lat\\\\v21l-', src.count('lat\\\\v21k-'))
    cambia('v21k-don.txt', 'v21l-don.txt', src.count('v21k-don.txt'))
assert not prueba or ('lat\\\\v21k-' not in src and 'v21k-don.txt' not in src), 'quedan registros v21k'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21l', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
