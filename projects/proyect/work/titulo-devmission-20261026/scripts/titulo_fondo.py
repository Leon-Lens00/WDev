"""Put the nebula storm background under the Dev Mission title (v6, 27/10/2026). Patches the compiled
war3map.j of v5 (CRLF kept):
- global Title_Bg;
- Title_Background: an 'uidn' dummy (w3u_fondo.py) at (Title_X, Title_Y), facing 90 so the plane's long side
  runs along screen x, 300 above the ground (the model reaches 250 below its origin, its far sources; the
  trackable quads stay under it, 20 and 8 above the ground), scale 1. Visible width at that depth is
  1.454 x (Title_D + Title_Eye - 300) ~ 1790 for a 2320 wide plane, height 0.841 x ~ 1035 for 1400, so the
  edges (which fade to alpha 0) stay off screen;
- Title_Begin creates it before the pictures; Title_Exit removes it (synced, every client);
- "-fondo H S" (diagnostic) moves it to height H and scale S.

Usage: titulo_fondo.py IN_J OUT_J
"""
from pathlib import Path
import sys

FUNCS = '''
// v6: the user's nebula storm (tormenta-nebula-v8) as the title background, see scripts/titulo_fondo.py.
function Title_Background takes nothing returns nothing
    set Title_Bg = CreateUnit(CAMERA_DUMMY_PLAYER, 'uidn', Title_X(), Title_Y(), 90)
    call UnitAddAbility(Title_Bg, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(Title_Bg, s__Interface_DESTROYER_FORM_ID)
    call UnitAddAbility(Title_Bg, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(Title_Bg, s__Interface_LOCUST_ID)
    call SetUnitFlyHeight(Title_Bg, Title_BgHeight, 0)
    call SetUnitScale(Title_Bg, Title_BgScale, Title_BgScale, Title_BgScale)
endfunction

// Diagnostic: "-fondo H S" puts the background at height H with scale S.
function Title_BackgroundSet takes nothing returns nothing
    local string s = SubString(GetEventPlayerChatString(), 7, StringLength(GetEventPlayerChatString()))
    local integer i = 0
    loop
        exitwhen i >= StringLength(s) or SubString(s, i, i + 1) == " "
        set i = i + 1
    endloop
    set Title_BgHeight = S2R(SubString(s, 0, i))
    if i < StringLength(s) then
        set Title_BgScale = S2R(SubString(s, i + 1, StringLength(s)))
    endif
    if Title_Bg != null then
        call SetUnitFlyHeight(Title_Bg, Title_BgHeight, 0)
        call SetUnitScale(Title_Bg, Title_BgScale, Title_BgScale, Title_BgScale)
    endif
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "Fondo: altura " + R2S(Title_BgHeight) + " escala " + R2S(Title_BgScale))
endfunction

'''


def once(text, old, new):
    assert text.count(old) == 1, old
    return text.replace(old, new)


if __name__ == '__main__':
    j = Path(sys.argv[1]).read_bytes().decode('utf-8').replace('\r\n', '\n')
    j = once(j, 'effect Title_Plane= null\n',
             'effect Title_Plane= null\nunit Title_Bg= null\nreal Title_BgHeight= 300.\nreal Title_BgScale= 1.\n')
    j = once(j, 'function Title_Begin takes nothing returns nothing\n', FUNCS + 'function Title_Begin takes nothing returns nothing\n')
    j = once(j, '    call Title_Camera()\n    set Title_Logo = ', '    call Title_Camera()\n    call Title_Background()\n    set Title_Logo = ')
    j = once(j, '    call Title_Show(Title_StartHover, false)\n    call DestroyTextTag(Title_Clock)\n',
             '    call Title_Show(Title_StartHover, false)\n    call RemoveUnit(Title_Bg)\n    set Title_Bg = null\n'
             '    call DestroyTextTag(Title_Clock)\n')
    j = once(j, '    local trigger o = CreateTrigger()\n', '    local trigger o = CreateTrigger()\n    local trigger f = CreateTrigger()\n')
    j = once(j, '        call TriggerRegisterPlayerChatEvent(o, Player(p), "-rot ", false)\n',
             '        call TriggerRegisterPlayerChatEvent(o, Player(p), "-rot ", false)\n'
             '        call TriggerRegisterPlayerChatEvent(f, Player(p), "-fondo ", false)\n')
    j = once(j, '    call TriggerAddAction(o, function Title_Rotate)\n',
             '    call TriggerAddAction(o, function Title_Rotate)\n    call TriggerAddAction(f, function Title_BackgroundSet)\n')
    j = once(j, '    set o = null\n', '    set o = null\n    set f = null\n')
    Path(sys.argv[2]).write_bytes(j.replace('\n', '\r\n').encode('utf-8'))
    print('ok', len(j))
