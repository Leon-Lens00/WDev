"""Dev Mission v12t (31/10/2026): the bot takes part in the menus and makes its own choices, and the round emblem shrinks.

It signs up when the mode screen opens, if there is at most one human in the game. From then on it goes through the same handlers as a
click, with random pauses: mode, hero (at random), boss (at random among the available ones) and one look at the strategy board.

Usage: menu_v12t.py IN_J OUT_J
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

import puente_v12 as base

GLOBAL_OLD = 'integer Bot_P = -1\n'
GLOBAL_NEW = GLOBAL_OLD + '''timer Bot_Menus = null
integer Bot_Pausa = 0
boolean Bot_VioTablero = false
'''
SIGN_OLD = '''function Mode_Start takes nothing returns nothing
    local integer i = 0
    set Title_Active = false
'''
SIGN_NEW = '''function Mode_Start takes nothing returns nothing
    local integer i = 0
    call ExecuteFunc("Bot_Inscribir")
    set Title_Active = false
'''
ANCHOR = '// v8e: the 20 s are over. Choosing stops (no hover, no clicks); the screen stays with the rhombuses lit.\n'
MENU = '''// A random pause before each choice, as a person would take.
function Bot_Turno takes nothing returns boolean
    if Bot_Pausa > 0 then
        set Bot_Pausa = Bot_Pausa - 1
        return false
    endif
    set Bot_Pausa = GetRandomInt(2, 8)
    return true
endfunction

function Bot_ElegirBoss takes nothing returns nothing
    local integer array lista
    local integer n = 0
    local integer b = 0
    loop
        exitwhen b > 39
        if Boss_Icon[b] != 0 then
            set lista[n] = b
            set n = n + 1
        endif
        set b = b + 1
    endloop
    if n > 0 then
        call Boss_OnHit(Bot_P, 200 + lista[GetRandomInt(0, n - 1)])
    endif
endfunction

function Bot_Menu takes nothing returns nothing
    if Title_Exited then
        call PauseTimer(Bot_Menus)
    elseif Strat_Active then
        if Strat_Ready and not Bot_VioTablero and Bot_Turno() then
            set Bot_VioTablero = true
            call Strat_OnHit(Bot_P, 300 + GetRandomInt(0, 9))
        endif
    elseif Boss_Active then
        if Boss_Ready and not Boss_Picked[Bot_P] and Bot_Turno() then
            if Boss_Choice[Bot_P] < 0 then
                call Bot_ElegirBoss()
            else
                call Boss_OnHit(Bot_P, 240)
            endif
        endif
    elseif Hero_Active then
        if Hero_Ready and not Hero_Locked[Bot_P] and Bot_Turno() then
            if Hero_Choice[Bot_P] < 0 then
                call Hero_OnHit(Bot_P, 100 + GetRandomInt(0, 1))
            else
                call Hero_OnHit(Bot_P, 140)
            endif
        endif
    elseif Mode_Ready and Mode_Choice[Bot_P] != 2 and Bot_Turno() then
        call Mode_OnHit(Bot_P, 12)
    endif
endfunction

// Same count as Bot_Entrar: with a second human there is no bot, in the menus or in the game.
function Bot_Inscribir takes nothing returns nothing
    local integer p = 7
    local integer humanos = 0
    if Bot_P >= 0 then
        return
    endif
    loop
        exitwhen p < 0
        if GetPlayerController(Player(p)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then
            set humanos = humanos + 1
        else
            set Bot_P = p
        endif
        set p = p - 1
    endloop
    if humanos > Bot_HUMANOS or Bot_P < 0 then
        set Bot_P = -1
        return
    endif
    set Title_Registered[Bot_P] = true
    set Title_Count = Title_Count + 1
    call SetPlayerName(Player(Bot_P), "Bot")
    set Bot_Menus = CreateTimer()
    call TimerStart(Bot_Menus, 0.25, true, function Bot_Menu)
endfunction

'''
ENTER = (('''    local integer p = 0
    local integer humanos = 0
    loop
        exitwhen p > 7
        if Game_On[p] then
''', '''    local integer p = 0
    local integer humanos = 0
    local boolean elegido = Bot_P >= 0
    loop
        exitwhen p > 7
        if Game_On[p] then
'''), ('''    set Hero_Choice[Bot_P] = 1 - Hero_Choice[Game_First]
''', '''    if not elegido or Hero_Choice[Bot_P] < 0 then
        set Hero_Choice[Bot_P] = GetRandomInt(0, 1)
    endif
'''))
ICON = (('constant real Ronda_ICONO_Y = 106.\n', 'constant real Ronda_ICONO_Y = 100.\n'), ('constant real Ronda_TITULO_Y = 90.\n', 'constant real Ronda_TITULO_Y = 88.\n'),
        ('constant real Ronda_CIFRA_Y = 126.\n', 'constant real Ronda_CIFRA_Y = 116.\n'))

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    for old, new in ((GLOBAL_OLD, GLOBAL_NEW), (SIGN_OLD, SIGN_NEW), (ANCHOR, MENU + ANCHOR)) + ENTER + ICON:
        s = base.once(s, old, new)
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok')
