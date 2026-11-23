#!/usr/bin/env python3
"""v21c (22/11/2026): Leon: quitar las transformaciones por muertes (v20s) para darles un rework aparte.
Causa del fallo visto en partida real (5 jugadores, copia de Leon de v21b): Frm_Matar corre dentro del disparador
de muertes compartido (Oro_Muerte) y lanza GkF_B77/TrF_gi4 de D.O.N, que hacen DisableTrigger(GetTriggeringTrigger())
y apagan ese disparador: sin oro por baja, rachas, bajas de resultados ni MVP. Frm_Fin (fin de oleada) llama a
GkF_Bf7/TrF_go4 con el mismo riesgo sobre WaveEvtFinish. Se desconectan las dos llamadas; las funciones quedan sin uso.
Uso: v21c.py ENTRADA.j SALIDA.j [prueba]   (normal de v21b; prueba de v21b-prueba).
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


cambia('''    local integer id = GetUnitTypeId(u)
    call Frm_Matar(k, u)
''', '''    local integer id = GetUnitTypeId(u)
    // v21c: sin transformaciones por muertes (Frm_Matar apagaba el disparador de muertes compartido).
''')
cambia('''        call Frm_Fin()
        call ExecuteFunc("ArmC_Municion")
''', '''        // v21c: sin Frm_Fin (las transformaciones por muertes están quitadas).
        call ExecuteFunc("ArmC_Municion")
''')

if prueba:
    for v, n in (('lat\\\\v21b-', 'lat\\\\v21c-'), ('v21b-don.txt', 'v21c-don.txt')):
        assert v in src, v
        src = src.replace(v, n)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
