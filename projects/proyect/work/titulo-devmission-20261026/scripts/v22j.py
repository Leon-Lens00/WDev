#!/usr/bin/env python3
"""v22j (23/11/2026): tabla de resultados con varios jugadores; columna de daño más ancha.

Leon tras jugar con 5 jugadores (capturas del 22/11): "se descuadra al jugar con varios jugadores, pero si se muestra
bien si esta un solo jugador, adicional que el espacio del danio hecho por jugador hecho deberia ser mas amplio".
- Causa: cada columna es un solo texttag de varias líneas ("|n" entre filas) y el texttag crece hacia arriba desde su
  punto: la última fila queda en la primera franja (243) y las demás suben sobre el título y la cabecera. Con un
  jugador hay una línea y cuadra. Ahora el punto de las 7 columnas baja (Mvp_N - 1) × 20,805 (1095 × 0,019, el paso
  de las franjas de PuntTabla): la primera fila queda en la primera franja.
- Daño: PuntTabla nueva (puntos_v22j.py) con BAJAS 222, ÉLITES 276, DAÑO 350, BOLSAS 436, CAÍDAS 494, PUNTOS 552
  (antes 246/302/362/422/486/548): el daño tiene ~105 px (antes ~60, ya justo con 5 cifras); el nombre cede ~25 px.
Uso: v22j.py ENTRADA.j SALIDA.j [prueba]   (normal de v22i; prueba de v22i-prueba).
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


viejo = '''    call Punt_Pos(Punt_TT[p * 16], 741.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 1], 797.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 2], 857.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 3], 917.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 4], 981.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 5], 1043.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 6], 539.0, 243.0 + dy, 0.019)
'''
nuevo = '''    // v22j: el texttag de varias líneas crece hacia arriba: su punto baja una fila por jugador más (franjas de
    // 20,805) y la primera fila queda en la primera franja. Columnas de PuntTabla v22j (daño más ancho).
    set a = 243.0 + 20.805 * I2R(IMaxBJ(0, Mvp_N - 1)) + dy
    call Punt_Pos(Punt_TT[p * 16], 717.0, a, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 1], 771.0, a, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 2], 825.0, a, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 3], 931.0, a, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 4], 989.0, a, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 5], 1047.0, a, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 6], 539.0, a, 0.019)
'''
cambia(viejo, nuevo)
# `a` (real local de Punt_Hud) ya no se usa después de la animación de entrada/salida.
i = src.index('function Punt_Hud takes integer p, integer cam returns nothing')
assert '    local real a\n' in src[i:i + 300]
assert src.index('integer Mvp_N') < i

if prueba:
    cambia('lat\\\\v22i-', 'lat\\\\v22j-', src.count('lat\\\\v22i-'))
    cambia('v22i-don.txt', 'v22j-don.txt', src.count('v22i-don.txt'))
    assert 'lat\\\\v22i-' not in src and 'v22i-don.txt' not in src, 'quedan registros v22i'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22j', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
