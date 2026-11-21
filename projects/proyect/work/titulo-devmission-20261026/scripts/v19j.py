#!/usr/bin/env python3
"""v19j (19/11/2026), tras v19i-prueba (lat\\v19i-don.txt): 1381 cadáveres de piezas quitados; sólo 2 restos vivos
(h01M). Una copia de Goku (c36, A0IA "thunderbolt") se quedó en pausa y visible 15 s: se pulsó 3,6 s después de la
anterior (c35). El motor de D.O.N (GkF_qV4) guarda el lanzador en una sola variable (GkV_s8[5850]) y dura ~3,3 s; la
copia anterior ya estaba libre (k57), pero su hilo seguía y al acabar dejó la variable en null, así que la nueva nunca
se despausó. Pasa con cualquier técnica cuyo motor sigue un rato después de soltar a la copia.
- Dcp_Ocupada: la misma técnica sigue ocupada hasta 2 s después de soltar a su copia, y para cualquier jugador (el
  estado de D.O.N es uno por técnica, no por jugador).
- Dcp_Tick: una copia que sigue ocupada a los 8 s sin su técnica en curso se suelta (antes esperaba 15 s).
Uso: v19j.py ENTRADA.j SALIDA.j [prueba]   (normal de v19i; prueba de v19i-prueba)
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


cambia('''        if Dcp_P[i] == p and Dcp_F[i] == 0 and Dcp_A[i] == a and a != 'A0IY' then
''', '''        if Dcp_A[i] == a and a != 'A0IY' and (Dcp_F[i] == 0 or Dcp_K[i] - Dcp_S[i] < 40) then
''')
cambia('if Dcp_K[i] >= 300 or (Dcp_K[i] >= 20 ',
       'if Dcp_K[i] >= 300 or (Dcp_K[i] >= 160 and not Don_EnCurso(Dcp_A[i])) or (Dcp_K[i] >= 20 ')
if prueba:
    for viejo, nuevo in (('lat\\\\v19i-', 'lat\\\\v19j-'), ('v19i-don.txt', 'v19j-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19j', 'prueba' if prueba else 'normal')
