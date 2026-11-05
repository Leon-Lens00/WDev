"""Temporary test bridge for the portrait models (Dev Mission title v11c, 30/10/2026). NOT for integration.

Goes straight to the hero screen with both portraits at the selector's size and walks all their animations,
so the old and the rebuilt models can be compared in the engine on the same screen.

Usage: puente_retratos.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def once(s, old, new):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


BRIDGE = '''// TEMPORARY test bridge (scripts/puente_retratos.py): both portraits side by side, cycling their animations.
unit Retrato_Paladin = null
integer Retrato_I = 0
'''
FUNCS = '''function Retrato_Next takes nothing returns nothing
    set Retrato_I = Retrato_I + 1
    if Retrato_I > 5 then
        set Retrato_I = 1
    endif
    call SetUnitAnimationByIndex(Hero_Portrait, Retrato_I)
    call SetUnitAnimationByIndex(Retrato_Paladin, Retrato_I - 1)
endfunction

function Retrato_Show takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    call SetUnitScale(Hero_Portrait, Hero_PortraitScale, Hero_PortraitScale, Hero_PortraitScale)
    set Retrato_Paladin = CreateUnit(CAMERA_DUMMY_PLAYER, 'dpa0', Title_WX(394, 405), Title_WY(900, 405), 0)
    call UnitAddAbility(Retrato_Paladin, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(Retrato_Paladin, s__Interface_DESTROYER_FORM_ID)
    call SetUnitFlyHeight(Retrato_Paladin, Title_D() + Title_Eye - 405, 0)
    call SetUnitScale(Retrato_Paladin, Hero_PortraitScale, Hero_PortraitScale, Hero_PortraitScale)
    call Retrato_Next()
    call TimerStart(CreateTimer(), 3.0, true, function Retrato_Next)
endfunction

function Retrato_Bridge takes nothing returns nothing
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
    call TimerStart(CreateTimer(), 0.3, false, function Retrato_Show)
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = once(s, 'unit Hero_Portrait= null\n', 'unit Hero_Portrait= null\n' + BRIDGE)
    s = once(s, '// v9c: the missile diagnostic multiboard', FUNCS + '// v9c: the missile diagnostic multiboard')
    s = once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
             '    call TimerStart(CreateTimer(), 0.1, false, function Retrato_Bridge)\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
