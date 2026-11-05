"""Puente temporal de prueba (Dev Mission v12e, 30/10/2026). NO integrar.

Sobre puente_v12 simula los clics del jugador 1: caja de modo sin funcion, casilla "?" de heroe, heroe elegido
(CELDA: 0 Tauren, 1 Cairne) y casilla vacia de boss, para ejercitar sonido de error, voz y Talk sin raton.
Uso: puente_v12e.py IN_J OUT_J CELDA
"""
from pathlib import Path
import sys

import puente_v12 as base

SIM = '''// TEMPORARY test bridge (scripts/puente_v12e.py).
integer Puente_Paso = 0
'''
FUNCS = '''// TEMPORARY test bridge (scripts/puente_v12e.py).
function Puente_Sim takes nothing returns nothing
    if Puente_Paso == 0 and Mode_Ready then
        set Puente_Paso = 1
        call Mode_OnHit(0, 10)
    elseif Puente_Paso == 1 and Hero_Ready and Hero_Left <= 5 then
        set Puente_Paso = 2
        call Hero_OnHit(0, 102)
    elseif Puente_Paso == 2 and Hero_Ready and Hero_Left <= 4 then
        set Puente_Paso = 3
        call Hero_OnHit(0, CELDA)
    elseif Puente_Paso == 3 and Boss_Ready and Boss_Left <= 5 then
        set Puente_Paso = 4
        call Boss_OnHit(0, 239)
    endif
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    FUNCS = FUNCS.replace('CELDA', str(100 + int(sys.argv[3])))
    s = base.once(s, '// v9c: the missile diagnostic multiboard', FUNCS + '// v9c: the missile diagnostic multiboard')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + SIM.replace('\n', base.N) + s[i:]
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
                  '    call TimerStart(CreateTimer(), 0.25, true, function Puente_Sim)\n'
                  '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
