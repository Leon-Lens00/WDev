#!/usr/bin/env python3
"""v21p (22/11/2026): la W de Freezer (A0JD) pasa a base ANrf (objetos_v21p.py); el puente AFz5 la pide con la orden
rainoffire en lugar de impale. Prueba: registros lat\\v21p-*.
Uso: v21p.py ENTRADA.j SALIDA.j [prueba]   (normal de v21o; prueba de v21o-prueba).
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


cambia("""    set Don_BotReal[Don_Bots] = 'A0JD'
    set Don_BotObj[Don_Bots] = 2
    set Don_BotOrden[Don_Bots] = "impale"
""", """    set Don_BotReal[Don_Bots] = 'A0JD'
    set Don_BotObj[Don_Bots] = 2
    // v21p: base ANrf (la de Impale no empezaba en la copia).
    set Don_BotOrden[Don_Bots] = "rainoffire"
""")
if prueba:
    cambia('lat\\\\v21o-', 'lat\\\\v21p-', src.count('lat\\\\v21o-'))
    cambia('v21o-don.txt', 'v21p-don.txt', src.count('v21o-don.txt'))
    assert 'lat\\\\v21o-' not in src and 'v21o-don.txt' not in src, 'quedan registros v21o'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21p', 'prueba' if prueba else 'normal')
