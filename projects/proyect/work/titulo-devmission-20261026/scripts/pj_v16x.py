#!/usr/bin/env python3
"""v16x (13/11/2026): tras -pj los enemigos de la oleada se quedaban quietos (Leon: "lo malo que la wave sys los
enemigos se quedan en pausa"). -pj sólo cambiaba DevWave__Targets; la IA de oleadas tiene su propia lista de blancos
(WaveAI__TargetUnit, de WaveAIRegisterTarget) y la oleada en curso su lista nearUnits. Al quitar el cuerpo viejo la IA
quedaba sin blancos vivos. Ahora el cuerpo nuevo sustituye al viejo en las dos listas.
Uso: pj_v16x.py v16w/war3map.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()
crlf = lambda s: s.replace('\n', '\r\n').encode('latin-1')
a = crlf("""    if DevWave__First == viejo then
        set DevWave__First = Game_Hero[p]
    endif
    call RemoveUnit(viejo)
""")
b = crlf("""    if DevWave__First == viejo then
        set DevWave__First = Game_Hero[p]
    endif
    // v16x: blancos de la IA de oleadas y unidades cercanas de la oleada en curso
    if WaveAIUnregisterTarget(viejo) then
        call WaveAIRegisterTarget(Game_Hero[p])
    endif
    if Ronda_Wave != 0 and not s__Wave_isDestroyed[Ronda_Wave] then
        set i = 0
        loop
            exitwhen i >= s__Wave_nearUnitCount[Ronda_Wave]
            if s___Wave_nearUnits[s__Wave_nearUnits[Ronda_Wave] + i] == viejo then
                set s___Wave_nearUnits[s__Wave_nearUnits[Ronda_Wave] + i] = Game_Hero[p]
            endif
            set i = i + 1
        endloop
    endif
    call RemoveUnit(viejo)
""")
assert j.count(a) == 1, j.count(a)
j = j.replace(a, b)
Path(sys.argv[2]).write_bytes(j)
print('v16x: -pj pasa los blancos de la IA de oleadas')
