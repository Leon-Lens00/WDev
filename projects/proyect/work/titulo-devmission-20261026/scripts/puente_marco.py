"""Temporary test bridge for the portrait frame (Dev Mission title v11e, 30/10/2026). NOT for integration.

Hero screen with the Tauren chosen and its animations cycling; after 12 s the strategy board at half and then full
growth, so the frame can be read against the portrait in both places.

Usage: puente_marco.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def once(s, old, new):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


BRIDGE = '''// TEMPORARY test bridge (scripts/puente_marco.py).
integer Marco_I = 0
'''
FUNCS = '''function Marco_Next takes nothing returns nothing
    set Marco_I = Marco_I + 1
    if Marco_I > 5 then
        set Marco_I = 1
    endif
    call SetUnitAnimationByIndex(Hero_Portrait, Marco_I)
endfunction

function Marco_Full takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    call Strat_Grow(1)
    call SetTextTagText(Strat_Tag[2], "Jefe tauren", 0.032)
    call Strat_TextAt(Strat_Tag[2], 968, 412, 0.032, 160.0)
    call SetTextTagVisibility(Strat_Tag[2], true)
endfunction

function Marco_Strat takes nothing returns nothing
    local integer i = 0
    call DestroyTimer(GetExpiredTimer())
    loop
        exitwhen i > 7
        call Title_Show(Hero_Bg[i], false)
        set i = i + 1
    endloop
    call Hero_Pieces(false)
    call SetUnitScale(Hero_Portrait, 0, 0, 0)
    if not Boss_Built then
        call Boss_Build()
    endif
    if not Strat_Built then
        call Strat_Build()
    endif
    call Strat_Show()
    call Strat_Grow(0.5)
    call TimerStart(CreateTimer(), 1.5, false, function Marco_Full)
endfunction

function Marco_Show takes nothing returns nothing
    local integer i = 0
    call DestroyTimer(GetExpiredTimer())
    loop
        exitwhen i > 5
        call Title_Show(Hero_Bg[i], true)
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 39
        if Hero_Icon[i] == 'DT2R' then
            set Hero_Choice[0] = i
        endif
        set i = i + 1
    endloop
    call Hero_ShowPortrait(0)
    call Marco_Next()
    call TimerStart(CreateTimer(), 2.0, true, function Marco_Next)
    call TimerStart(CreateTimer(), 12.0, false, function Marco_Strat)
endfunction

function Marco_Bridge takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    call SetCameraBounds(Title_X() - 1, Title_Y() - 1, Title_X() - 1, Title_Y() + 1, Title_X() + 1, Title_Y() + 1, Title_X() + 1, Title_Y() - 1)
    call Title_Camera()
    call Title_Background()
    set Title_Active = false
    set Hero_Active = true
    set Hero_Ready = false
    call Hero_Build()
    call Hero_Pieces(true)
    call TimerStart(CreateTimer(), 0.15, false, function Title_Reveal)
    call TimerStart(CreateTimer(), 0.3, false, function Marco_Show)
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = once(s, 'endglobals\n', BRIDGE + 'endglobals\n')
    s = once(s, '// v9c: the missile diagnostic multiboard', FUNCS + '// v9c: the missile diagnostic multiboard')
    s = once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
             '    call TimerStart(CreateTimer(), 0.1, false, function Marco_Bridge)\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
