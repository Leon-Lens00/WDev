#!/usr/bin/env python3
"""v14zy (07/11/2026): 60 s en cada pantalla de elección de la intro y 3 s en cuanto todos eligieron.
- Start (título): 5 -> 60 s. Al pulsar Start todos los humanos presentes, baja a 3 s (antes no bajaba).
- Modo: 5 -> 60 s. Al elegir modo todos los inscritos, baja a 3 s (antes no bajaba).
- Héroe: ya era 60 s y bajaba a 3 al fijar todos; sin cambios.
- Jefe: 30 -> 60 s; ya bajaba a 3 al elegir todos.
El tablero de estrategia (5 s, sólo mirar) no cambia.
Uso: v14zy.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
# Start
s = once(s, '    set Title_Count = 0\n    set Title_Left = 5\n', '    set Title_Count = 0\n    set Title_Left = 60\n')
s = once(s, '    call Clock_Show(5, 960, Entry_PY(112, 0.2, 0.6, -80))\n', '    call Clock_Show(60, 960, Entry_PY(112, 0.2, 0.6, -80))\n')
s = once(s, '''    set Title_Registered[p] = true
    set Title_Count = Title_Count + 1
    call UI_Click(p)
''', '''    set Title_Registered[p] = true
    set Title_Count = Title_Count + 1
    call UI_Click(p)
    // v14zy: every human present pressed Start -> 3 s left.
    if Title_Count >= Intro_Humanos() and Title_Left > 3 then
        set Title_Left = 3
        set Title_Ticks = 0
        call Title_ClockText()
    endif
''')
s = once(s, 'function Title_OnHit takes nothing returns nothing\n', '''// v14zy: user players in the game (0..11).
function Intro_Humanos takes nothing returns integer
    local integer p = 0
    local integer n = 0
    loop
        exitwhen p > 11
        if GetPlayerController(Player(p)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then
            set n = n + 1
        endif
        set p = p + 1
    endloop
    return n
endfunction

function Title_OnHit takes nothing returns nothing
''')
# Modo
s = once(s, '        set Mode_Left = 5\n        set Mode_Ticks = 0\n', '        set Mode_Left = 60\n        set Mode_Ticks = 0\n')
s = once(s, '''    set Mode_Choice[p] = 2
    call UI_Click(p)
    if p < 8 then
        call Title_Show(Mode_GemLit[p], true)
    endif
endfunction
''', '''    set Mode_Choice[p] = 2
    call UI_Click(p)
    if p < 8 then
        call Title_Show(Mode_GemLit[p], true)
    endif
    // v14zy: every registered player chose -> 3 s left.
    set p = 0
    loop
        exitwhen p > 11
        if Title_Registered[p] and Mode_Choice[p] != 2 then
            return
        endif
        set p = p + 1
    endloop
    if Mode_Left > 3 then
        set Mode_Left = 3
        set Mode_Ticks = 0
        call Clock_Show(Mode_Left, 504, 628)
    endif
endfunction
''')
# Jefe
s = once(s, '    set Boss_Left = 30\n    set Boss_Ticks = 0\n    set Boss_Ready = true\n    call Hero_ClockShow(30)\n',
         '    set Boss_Left = 60\n    set Boss_Ticks = 0\n    set Boss_Ready = true\n    call Hero_ClockShow(60)\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('ok', len(s))
