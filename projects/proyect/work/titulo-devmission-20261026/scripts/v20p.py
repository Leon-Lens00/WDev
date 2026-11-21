#!/usr/bin/env python3
"""v20p-lan (20/11/2026): LAN de dos jugadores, rojo y morado (azul y verde azulado cerrados en map.cfg), para probar
la partida con un hueco entre jugadores. Pedido de Leon: "vida infinita a los jugadores para probar mejor".
- Vidas: se empieza con 99 y caer no resta (el héroe cae y reaparece como siempre; la racha se rompe y la caída cuenta
  para las estrellas igual que antes). Comprar vida sigue sumando.
- Sin registros: es la normal v20o con ese cambio.
Uso: v20p.py ENTRADA.j SALIDA.j   (de v20o)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')


def cambia(viejo, nuevo, veces=1):
    global src
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('constant integer Vidas_INICIO = 3\n', 'constant integer Vidas_INICIO = 99\n')
cambia('''    set Vidas_Actual[p] = Vidas_Actual[p] - 1
    call DisplayTimedTextToPlayer(Player(p), 0., 0., 3., "Vidas: " + I2S(Vidas_Actual[p]))
''', '''    // v20p-lan: vidas infinitas para la prueba (caer no resta).
    call DisplayTimedTextToPlayer(Player(p), 0., 0., 3., "Vidas: " + I2S(Vidas_Actual[p]) + " (infinitas en la LAN)")
''')
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20p-lan')
