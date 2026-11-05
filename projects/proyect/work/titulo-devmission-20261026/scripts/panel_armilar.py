"""Panel 1 after the intro: armillary logo, logo behind its peak and staircase entry (v9b, 28/10/2026).
Patches the compiled war3map.j of v9 (CRLF kept).

The user asked that when the intro model ends, panel 1 comes in with a fade from black showing only the
background (no clock, logo or rhombuses), with their armillary logo model (ModelEditor logo-armilar-v5, unit
'uida' from armilar_objetos.py) over it; at the model's brightness peak our logo appears behind the glow, and when
the model ends Start and the rhombuses come up from below like a staircase while the clock comes down from above.
They also asked that the song start exactly with the W of the intro.
- Song: in the v9 recording (wf-recorder, video and audio on one clock) the W showed at 11.77 s and the song began
  at 10.40 s, 1.37 s before it (the W is at 1608 ms of the model; the music starts about 0.24 s after PlayMusic).
  Intro_Show now starts the song 1.37 s later (Intro_Music).
- The armillary unit is created with the intro unit (Intro_Begin), so its textures load early; its Stand is
  invisible. Its logo contour (Wire.blp, 2300 x 2300 quad at z -620) spans canvas pixels 10-501 of 512, 2210
  units, and is the outline of our logo (ModeLogo, content 2-509 of 512 on the 568 px picture, so 563.6 px). With
  the contour Panel_ArmDepth 390 below the eye (in front of the logo picture at 400, so the glow covers it):
  2210 s = 563.6 * (0.544 / 718.1893) * 390, s 0.07539; centre under the logo's pixel (960, 419); facing 90 like
  the intro (model +X right, +Y up with camera rotation 180).
- Title_Begin builds the scene as before but, instead of Title_Restart, Panel_Begin hides the logo, Start, the
  rhombuses and the clock, and plays the armillary Birth (8 s). The title's fade from black (Title_Reveal) is
  unchanged. Panel_Logo (5.6 s, the peak) shows the logo; Panel_Entry (8 s) removes the unit and starts the entry.
- Entry: Start (and its hover picture) rises from below the screen (py 1180) in 0.55 s, the eight rhombuses follow
  0.12 s later, 0.07 s apart, 0.5 s each, and the clock (20) comes down from py -80 to 112 in 0.6 s from 0.2 s;
  ease-out cubic (Mode_Ease 0), 0.02 s timer. The rhombuses that move are copies (Entry_Gem): the real ones are
  not moved, because the War Club skin change used to light them fails on moved pieces (v8d). At the end
  Title_Restart starts the registration as before (20 s, Start clickable) and the title message is shown.
- Title_Restart (also -titulo) first calls Entry_Stop, which puts every piece where it ends, shows the logo and
  the real rhombuses and hides the copies, so -titulo during the panel leaves a normal title. Panel_Logo and
  Panel_Entry do nothing but clean up if the title was restarted (Title_Active) or left meanwhile.

Usage: panel_armilar.py IN_J OUT_J
"""
from pathlib import Path
import sys

GLOBALS = '''unit Panel_Arm= null
real Panel_ArmDepth= 390.
real Panel_ArmScale= 0.07539
boolean Entry_Active= false
real Entry_Time= 0.
timer Entry_Timer= null
unit array Entry_Gem
'''

ENTRY = '''// v9b: Start and the rhombuses come up from below like a staircase; the clock comes down from above.
function Entry_PY takes real py, real t0, real dur, real from returns real
    return from + (py - from) * Mode_Ease((Entry_Time - t0) / dur, 0)
endfunction

function Entry_Put takes unit u, real px, real py returns nothing
    local real d = LoadReal(Title_HT, GetHandleId(u), 2)
    call SetUnitX(u, Title_WX(py, d))
    call SetUnitY(u, Title_WY(px, d))
endfunction

function Entry_Place takes nothing returns nothing
    local integer p = 0
    local real py = Entry_PY(622.3, 0, 0.55, 1180)
    call Entry_Put(Title_Start, 960, py)
    call Entry_Put(Title_StartHover, 960, py)
    loop
        exitwhen p > 7
        call Entry_Put(Entry_Gem[p], 960 + (p - 3.5) * 87.2, Entry_PY(774.9, 0.12 + p * 0.07, 0.5, 1180))
        set p = p + 1
    endloop
    call Clock_Show(20, 960, Entry_PY(112, 0.2, 0.6, -80))
endfunction

// Every piece where it ends; called by Title_Restart.
function Entry_Stop takes nothing returns nothing
    local integer p = 0
    if Entry_Active then
        set Entry_Active = false
        call PauseTimer(Entry_Timer)
        set Entry_Time = 9.
        call Entry_Place()
    endif
    call Title_Show(Title_Logo, true)
    loop
        exitwhen p > 7
        call Title_Show(Entry_Gem[p], false)
        call Title_Show(Title_Gem[p], true)
        set p = p + 1
    endloop
endfunction

'''

ENTRY2 = '''function Entry_Tick takes nothing returns nothing
    set Entry_Time = Entry_Time + 0.02
    call Entry_Place()
    if Entry_Time >= 1.15 then
        call Title_Restart()
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 20, "Pantalla de titulo: pulsa Start antes de que acabe la cuenta. -titulo reinicia; -salirtitulo sale.")
    endif
endfunction

function Entry_Start takes nothing returns nothing
    local integer p = 0
    set Entry_Active = true
    set Entry_Time = 0
    call Entry_Place()
    call Title_Show(Title_Start, true)
    loop
        exitwhen p > 7
        call Title_Show(Entry_Gem[p], true)
        set p = p + 1
    endloop
    call TimerStart(Entry_Timer, 0.02, true, function Entry_Tick)
endfunction

// v9b: panel 1 after the intro. Only the background, the armillary logo over it, our logo at its peak.
function Panel_ArmCreate takes nothing returns nothing
    local real d = Panel_ArmDepth
    set Panel_Arm = CreateUnit(CAMERA_DUMMY_PLAYER, 'uida', Title_WX(419, d), Title_WY(960, d), 90)
    call UnitAddAbility(Panel_Arm, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(Panel_Arm, s__Interface_DESTROYER_FORM_ID)
    call UnitAddAbility(Panel_Arm, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(Panel_Arm, s__Interface_LOCUST_ID)
    call SetUnitFlyHeight(Panel_Arm, Title_D() + Title_Eye - d + 620 * Panel_ArmScale, 0)
    call SetUnitScale(Panel_Arm, Panel_ArmScale, Panel_ArmScale, Panel_ArmScale)
endfunction

function Panel_Entry takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    call RemoveUnit(Panel_Arm)
    set Panel_Arm = null
    if Title_Exited or Title_Active or Entry_Active then
        return
    endif
    call Entry_Start()
endfunction

function Panel_Logo takes nothing returns nothing
    if not (Title_Exited or Title_Active) then
        call Title_Show(Title_Logo, true)
    endif
    call TimerStart(GetExpiredTimer(), 2.4, false, function Panel_Entry)
endfunction

function Panel_Begin takes nothing returns nothing
    local integer p = 0
    set Title_Active = false
    set Entry_Timer = CreateTimer()
    call Title_Show(Title_Logo, false)
    call Title_Show(Title_Start, false)
    loop
        exitwhen p > 7
        set Entry_Gem[p] = Title_Pic('uidb', 960 + (p - 3.5) * 87.2, 774.9, 73.6, 99.6, 400, 'DT03')
        call Title_Show(Entry_Gem[p], false)
        call Title_Show(Title_Gem[p], false)
        set p = p + 1
    endloop
    call Clock_Show(-1, 0, 0)
    call SetUnitAnimationByIndex(Panel_Arm, 0)
    call TimerStart(CreateTimer(), 5.6, false, function Panel_Logo)
endfunction

'''

MUSIC = r'''function Intro_Music takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    call PlayMusic("war3mapImported\\IntroCancion.mp3")
endfunction

'''


def once(text, old, new):
    assert text.count(old) == 1, old
    return text.replace(old, new)


if __name__ == '__main__':
    j = Path(sys.argv[1]).read_bytes().decode('utf-8').replace('\r\n', '\n')
    j = once(j, 'unit Title_Bg= null\n', 'unit Title_Bg= null\n' + GLOBALS)
    j = once(j, 'function Title_Restart takes nothing returns nothing\n', ENTRY + 'function Title_Restart takes nothing returns nothing\n')
    j = once(j, '    call Mode_Reset()\n    loop\n        exitwhen p > 11\n        set Title_Registered[p] = false\n',
             '    call Entry_Stop()\n    call Mode_Reset()\n    loop\n        exitwhen p > 11\n        set Title_Registered[p] = false\n')
    j = once(j, '// v8j: black from the first frame', ENTRY2 + '// v8j: black from the first frame')
    j = once(j, '    call Title_Restart()\n    call TimerStart(Title_Timer, 0.05, true, function Title_Tick)\n',
             '    call Panel_Begin()\n    call TimerStart(Title_Timer, 0.05, true, function Title_Tick)\n')
    j = once(j, '    call TimerStart(CreateTimer(), 0.15, false, function Title_Reveal)\n    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 20, "Pantalla de titulo: pulsa Start antes de que acabe la cuenta. -titulo reinicia; -salirtitulo sale.")\n',
             '    call TimerStart(CreateTimer(), 0.15, false, function Title_Reveal)\n')
    j = once(j, 'function Intro_End takes nothing returns nothing\n', MUSIC + 'function Intro_End takes nothing returns nothing\n')
    j = once(j, '    call PlayMusic("war3mapImported\\\\IntroCancion.mp3")\n    call DisplayCineFilter(false)\n',
             '    call TimerStart(CreateTimer(), 1.37, false, function Intro_Music)\n    call DisplayCineFilter(false)\n')
    j = once(j, '    call SetUnitScale(Intro_U, Intro_Scale, Intro_Scale, Intro_Scale)\n',
             '    call SetUnitScale(Intro_U, Intro_Scale, Intro_Scale, Intro_Scale)\n    call Panel_ArmCreate()\n')
    Path(sys.argv[2]).write_bytes(j.replace('\n', '\r\n').encode('utf-8'))
    print('ok', len(j))
