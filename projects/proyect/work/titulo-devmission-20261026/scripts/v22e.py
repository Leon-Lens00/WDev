#!/usr/bin/env python3
"""v22e (23/11/2026): la R de Vegito ya no se lanza dos veces; el retrato de Vegito sube (retrato_vt22e.cjs).

Leon tras v22d-prueba: "el portrait esta algo bajo y la R parece que lanza otra luego de la 1ra".
- Registro v22d-don.txt: la copia c4 lanza A0DS (rainoffire) a 46.734 y otra vez a 53.039 (k126), justo después de
  "vegito R choca": G2F_SKTrail_vegito despausa la copia al acabar y la copia retoma la orden que tenía al pausarse
  (las técnicas reales no tienen recarga: la lleva el libro). Vegeta, Trunks y la X de Vegito ya mandan "stop"
  ($D0004 = 851972) a la copia; la R y la W de Vegito no. Se manda "stop" tras despausar en las dos (la W no se
  repitió en el registro, pero tiene el mismo camino).
Registro (sólo prueba): "vegito R/W stop tras despausar".
Uso: v22e.py ENTRADA.j SALIDA.j [prueba]   (normal de v22d; prueba de v22d-prueba).
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


for quien, c, sig in (('R', '4850', 'call SetUnitTimeScalePercent(G2V_Caster[4850],100)\n'),
                      ('W', '80', None)):
    viejo = 'call PauseUnit(G2V_Caster[%s],false)\n' % c
    # Sólo dentro de la función de Vegito (G2V_Caster[80] también lo despausan otros personajes).
    fn = 'function G2F_SKTrail_vegito_Actions' if quien == 'R' else 'function G2F_bigbangv_vegito2_Actions'
    i = src.index(fn)
    j = src.index('\nendfunction\n', i)
    cuerpo = src[i:j]
    assert cuerpo.count(viejo) == 1, (quien, cuerpo.count(viejo))
    nuevo = viejo + ('// v22e: sin "stop" la copia retoma su orden al despausarse y lanza otra vez la técnica.\n'
                     'call IssueImmediateOrderById(G2V_Caster[%s],$D0004)\n' % c)
    if prueba:
        nuevo += ('set Cop_Log = "vegito %s stop tras despausar"\ncall ExecuteFunc("Cop_Anotar")\n' % quien)
    src = src[:i] + cuerpo.replace(viejo, U(nuevo)) + src[j:]

if prueba:
    assert 'function Cop_Anotar' in src, 'Cop_Anotar en prueba'
    cambia('lat\\\\v22d-', 'lat\\\\v22e-', src.count('lat\\\\v22d-'))
    cambia('v22d-don.txt', 'v22e-don.txt', src.count('v22d-don.txt'))
    assert 'lat\\\\v22d-' not in src and 'v22d-don.txt' not in src, 'quedan registros v22d'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22e', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
