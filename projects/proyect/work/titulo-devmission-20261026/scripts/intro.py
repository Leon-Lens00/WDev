"""Intro before the Dev Mission title (v9, 28/10/2026). Patches the compiled war3map.j of v8j (CRLF kept).

The user asked for 3 s of black at the start, then their intro model (ModelEditor intro-w-nebula-v8-fade, unit
'uidi' from intro_objetos.py) with their song starting together with it. The title comes after the model, as
before (the user will send the second part later).
- main already puts up the black filter (v8j). Title_Init no longer starts Title_Begin after 0.1 s but
  Intro_Begin, and clears the map's default music (SetMapMusic "Music" in main) so nothing plays under the black.
- Intro_Begin (0.1 s): title camera bounds and camera (rotation 180), and the intro unit already created, facing
  90 like the nebula background, at height Intro_Height with scale Intro_Scale. Its Stand is invisible, so its
  textures load under the black.
- Intro_Show (3 s from the start): Birth (sequence 0, 12.5 s), the song (PlayMusic) and the filter off.
- Intro_End (12.5 s later): black again, the unit removed, then Title_Begin on the same timer, which fades the
  title in from black as in v8j. If the title was left with -salirtitulo meanwhile, only the unit and the filter go.
Framing: the ModelEditor viewer fits 3000 x 1700 (x 1.08) at the model's z -60 with a 60 degree vertical FOV,
i.e. 3264 x 1836 on a 16:9 screen. The title camera sees 2 * 0.727 * depth across (Title_WY), with the eye
D + Eye = 1530.35 above the ground; with the plane at height H - 60 s: 1.454 (1530.35 - H + 60 s) = 3264 s,
so H 300 gives s 0.5634. The music is the same for everybody; nothing here is local.

Usage: intro.py IN_J OUT_J
"""
from pathlib import Path
import sys

GLOBALS = '''unit Intro_U= null
real Intro_Height= 300.
real Intro_Scale= 0.5634
'''

FUNCS = r'''// v9: intro. 3 s of black (main's filter), the user's intro model with the song for 12.5 s, then the title.
function Intro_End takes nothing returns nothing
    call RemoveUnit(Intro_U)
    set Intro_U = null
    if Title_Exited then
        call DestroyTimer(GetExpiredTimer())
        call DisplayCineFilter(false)
        return
    endif
    call Title_Black(255, 255, 0)
    call TimerStart(GetExpiredTimer(), 0., false, function Title_Begin)
endfunction

function Intro_Show takes nothing returns nothing
    call Title_Camera()
    call SetUnitAnimationByIndex(Intro_U, 0)
    call PlayMusic("war3mapImported\\IntroCancion.mp3")
    call DisplayCineFilter(false)
    call TimerStart(GetExpiredTimer(), 12.5, false, function Intro_End)
endfunction

function Intro_Begin takes nothing returns nothing
    call SetCameraBounds(Title_X() - 1, Title_Y() - 1, Title_X() - 1, Title_Y() + 1, Title_X() + 1, Title_Y() + 1, Title_X() + 1, Title_Y() - 1)
    call Title_Camera()
    set Intro_U = CreateUnit(CAMERA_DUMMY_PLAYER, 'uidi', Title_X(), Title_Y(), 90)
    call UnitAddAbility(Intro_U, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(Intro_U, s__Interface_DESTROYER_FORM_ID)
    call UnitAddAbility(Intro_U, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(Intro_U, s__Interface_LOCUST_ID)
    call SetUnitFlyHeight(Intro_U, Intro_Height, 0)
    call SetUnitScale(Intro_U, Intro_Scale, Intro_Scale, Intro_Scale)
    call TimerStart(GetExpiredTimer(), 2.9, false, function Intro_Show)
endfunction

'''


def once(text, old, new):
    assert text.count(old) == 1, old
    return text.replace(old, new)


if __name__ == '__main__':
    j = Path(sys.argv[1]).read_bytes().decode('utf-8').replace('\r\n', '\n')
    j = once(j, 'unit Title_Bg= null\n', 'unit Title_Bg= null\n' + GLOBALS)
    j = once(j, 'function Title_Init takes nothing returns nothing\n', FUNCS + 'function Title_Init takes nothing returns nothing\n')
    j = once(j, '    call TimerStart(CreateTimer(), 0.1, false, function Title_Begin)\n',
             '    call ClearMapMusic()\n    call StopMusic(false)\n'
             '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n')
    Path(sys.argv[2]).write_bytes(j.replace('\n', '\r\n').encode('utf-8'))
    print('ok', len(j))
