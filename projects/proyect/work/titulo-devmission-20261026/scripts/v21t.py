#!/usr/bin/env python3
"""v21t (22/11/2026): la W de Trunks (A0GV) se ordena con "clusterrockets" (Channel, objetos_v21t.py) en lugar de "ward".
Prueba: registros lat\\v21t-*.
Uso: v21t.py ENTRADA.j SALIDA.j [prueba]   (normal de v21s; prueba de v21s-prueba).
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


cambia("""    set Don_BotReal[Don_Bots] = 'A0GV'
    set Don_BotObj[Don_Bots] = 2
    set Don_BotOrden[Don_Bots] = "ward"
""", """    set Don_BotReal[Don_Bots] = 'A0GV'
    set Don_BotObj[Don_Bots] = 2
    // v21t: A0GV es Channel (antes Serpent Ward, que se rechazaba en suelo no transitable).
    set Don_BotOrden[Don_Bots] = "clusterrockets"
""")
assert '"clusterrockets"' not in src.replace('set Don_BotOrden[Don_Bots] = "clusterrockets"', '', 1)
if prueba:
    cambia('lat\\\\v21s-', 'lat\\\\v21t-', src.count('lat\\\\v21s-'))
    cambia('v21s-don.txt', 'v21t-don.txt', src.count('v21s-don.txt'))
    assert 'lat\\\\v21s-' not in src and 'v21s-don.txt' not in src, 'quedan registros v21s'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21t', 'prueba' if prueba else 'normal')
