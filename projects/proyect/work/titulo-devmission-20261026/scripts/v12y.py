#!/usr/bin/env python3
"""v12y: entra directo a la partida y el personaje siempre es el Tauren.

La intro y los menús siguen en el script, sin arrancar: basta volver a `Intro_Begin` para recuperarlos.
Uso: v12y.py IN_J OUT_J
"""
from pathlib import Path
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

ENTRADA = '''// v12y: sin intro ni menús; todo humano presente entra con el Tauren.
function Entrada_Directa takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 7
        if GetPlayerController(Player(p)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then
            set Title_Registered[p] = true
            set Title_Count = Title_Count + 1
        endif
        set p = p + 1
    endloop
    call Title_Begin()
    call TimerStart(CreateTimer(), 0.1, false, function Title_Exit)
endfunction

function Intro_Begin takes nothing returns nothing
'''

if __name__ == '__main__':
    j_in, j_out = sys.argv[1:3]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    s = base.once(s, "    if Hero_Choice[p] == 1 then\n        set id='h006'\n    endif\n    set Game_Hero[p]=CreateUnit(", '    set Game_Hero[p]=CreateUnit(')
    s = base.once(s, 'function Intro_Begin takes nothing returns nothing\n', ENTRADA)
    s = base.once(s, 'TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n', 'TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)\n')
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
