"""Puente temporal de prueba (Dev Mission v12e, 30/10/2026). NO integrar.

Va directo a la seleccion de heroe: sin intro, sin logo y sin pantalla de modos. Elige CELDA (0 Tauren, 1 Cairne)
y deja correr el reloj hasta estrategia, para ver retrato, voz y Talk en pocos segundos.
Uso: puente_directo_v12e.py IN_J OUT_J CELDA
"""
from pathlib import Path
import sys

import puente_v12 as base

GLOBALS = '''// TEMPORARY test bridge (scripts/puente_directo_v12e.py).
integer Puente_Paso = 0
boolean Puente_Listo = false
'''
FUNCS = '''// TEMPORARY test bridge (scripts/puente_directo_v12e.py).
function Puente_Sim takes nothing returns nothing
    if Puente_Paso == 0 and Puente_Listo then
        set Puente_Paso = 1
        call Mode_Start()
        call Hero_Begin()
    elseif Puente_Paso == 1 and Hero_Ready and Hero_Left <= 10 then
        set Puente_Paso = 2
        call Hero_OnHit(0, CELDA)
    endif
endfunction

function Puente_Directo takes nothing returns nothing
    set Title_Registered[0] = true
    set Title_Count = 1
    set Title_Left = 999
    call Title_Begin()
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = base.once(s, '// v9c: the missile diagnostic multiboard',
                  FUNCS.replace('CELDA', str(100 + int(sys.argv[3]))) + '// v9c: the missile diagnostic multiboard')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + GLOBALS.replace('\n', base.N) + s[i:]
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
                  '    call TimerStart(CreateTimer(), 0.25, true, function Puente_Sim)\n'
                  '    call TimerStart(CreateTimer(), 0.1, false, function Puente_Directo)\n')
    # La entrada del titulo acaba en Title_Restart, que borra el registro y el estado: el salto va despues.
    s = base.once(s, '    set Title_Active = true\n', '    set Title_Active = true\n    set Title_Registered[0] = true\n    set Title_Count = 1\n    set Title_Left = 999\n    set Puente_Listo = true\n')
    for old, new in [('call TimerStart(CreateTimer(), 5.6, false, function Hero_Show)', 'call TimerStart(CreateTimer(), 0.3, false, function Hero_Show)'),
                     ('call TimerStart(GetExpiredTimer(), 2.4, false, function Hero_Go)', 'call TimerStart(GetExpiredTimer(), 0.3, false, function Hero_Go)'),
                     ('call TimerStart(CreateTimer(), 5.6, false, function Panel_Logo)', 'call TimerStart(CreateTimer(), 0.2, false, function Panel_Logo)'),
                     ('call TimerStart(GetExpiredTimer(), 2.4, false, function Panel_Entry)', 'call TimerStart(GetExpiredTimer(), 0.2, false, function Panel_Entry)'),
                     ('    set Hero_Left = 60\n', '    set Hero_Left = 12\n'),
                     ('    set Boss_Left = 30\n', '    set Boss_Left = 3\n')]:
        s = base.once(s, old, new)
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
