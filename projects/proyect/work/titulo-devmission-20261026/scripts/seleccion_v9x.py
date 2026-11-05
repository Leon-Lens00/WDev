"""Presentation v9x (Dev Mission title, 29/10/2026): v9w with the motion and times measured on the reference.
Patches v9v's war3map.j (CRLF kept).

After v9w the user asked to improve the motion and the times. Measured frame by frame on the reference (ring
640 px there = 700 here): the parts cross the centre fast and overshoot much further than v9w (at m 1.3 the ring
+55 px below, the triangle +190 below, the W -155 above), then drift back (m 1.6: +46, +136, -96) and snap at
m 1.8 with a full-screen pale flash; the ring stays whitened until m 2.5. The emblem dims a little when the
silhouette appears (m 3.6-3.8), the reveal (m 5.2) and the stop (m 5.8) are full-screen flashes too, and the
emblem goes dark at m 6.0. The character is about 0.6 of the ring tall (the v9w hydra was a third of that).

v9w notes:

The user's request after v9v, from their reference video (fuentes/presentacion/referencia.mp4) and theme
(fuentes/presentacion/tema.mp3, 9.85 s):
- the strategy time is 5 s; when it ends the music fades out, the screen goes black, 2 s later the scene fades in,
  everything else gone: the user's radial nebula V3 instead of the animated background;
- the emblem's three parts (ring, triangle, W) come in fast, ring and triangle from the top, the W from the bottom,
  slow down short of their places, creep, then stop dead at the centre with a flash (additive copies on top) and
  the horizontal converging glow; the emblem stays brighter for a while, then normal;
- the game's Hydra (turned to the camera, mdx_rotar.py) fades in as a black silhouette walking (animation index 0),
  is revealed in colour with the vertical glow and casts its Spell (index 3) when the reference character takes its
  entrance pose, and freezes (time scale 0) when the reference stops, with the horizontal glow again; the emblem
  then goes dark.
Times are the theme's (m), aligned on the reference: its hits at 1.85 s (emblem in place) and 5.25 s (entrance
pose) fall on the video's 5.23 s and 8.57 s, so m = video - 3.4. Everything is the same on every client.

Usage: seleccion_v9w.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def L(s):
    return s.replace('\n', N)


def once(s, old, new):
    old, new = L(old), L(new)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


GLOBALS = '''timer Pres_T= null
real Pres_Time= 0
boolean Pres_On= false
boolean Pres_Built= false
integer Pres_Step= 0
sound Pres_Snd= null
unit Pres_Bg= null
unit Pres_Hydra= null
unit Pres_GH= null
unit Pres_GV= null
real Pres_GHAt= -9
real Pres_GVAt= -9
unit array Pres_Pic
unit array Pres_Hi
'''

FUNCS = '''// v9w: the presentation (scripts/seleccion_v9w.py). The screen filter as Title_Black.
function Pres_Black takes integer a0, integer a1, real dur returns nothing
    call SetCineFilterTexture("ReplaceableTextures\\\\CameraMasks\\\\Black_mask.blp")
    call SetCineFilterBlendMode(BLEND_MODE_BLEND)
    call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
    call SetCineFilterStartUV(0, 0, 1, 1)
    call SetCineFilterEndUV(0, 0, 1, 1)
    call SetCineFilterStartColor(0, 0, 0, a0)
    call SetCineFilterEndColor(0, 0, 0, a1)
    call SetCineFilterDuration(dur)
    call DisplayCineFilter(true)
endfunction

// Emblem parts: 0 ring, 1 triangle, 2 W (texturas_v9w.py places and sizes).
function Pres_PX takes integer i returns real
    if i == 2 then
        return 953.1
    endif
    return 954.7
endfunction

function Pres_PY takes integer i returns real
    if i == 0 then
        return 414.2
    elseif i == 1 then
        return 471.0
    endif
    return 415.8
endfunction

// Vertical offset of part i at theme time m (v9x, measured): from off the screen across the centre with a quintic
// ease-out to the overshoot at 1.3 s, a smooth drift back to 1.8 s, then dead stop. Ring and triangle from the
// top (overshoot below), the W from the bottom (overshoot above).
function Pres_Off takes integer i, real m returns real
    local real a = -900
    local real p = 55
    local real e = 41
    local real t
    if i == 1 then
        set p = 190
        set e = 107
    elseif i == 2 then
        set a = 900
        set p = -155
        set e = -64
    endif
    if m < 0.75 then
        return a
    elseif m < 1.3 then
        set t = 1 - (m - 0.75) / 0.55
        return a + (p - a) * (1 - t * t * t * t * t)
    elseif m < 1.8 then
        set t = (m - 1.3) / 0.5
        return p + (e - p) * t * t * (3 - 2 * t)
    endif
    return 0.0
endfunction

// Additive copies' strength: the ring whitened after the stop (1.8 s), back to normal by 2.5 s.
function Pres_Glow takes real m returns real
    if m >= 1.8 and m < 2.5 then
        return 255 * (1 - (m - 1.8) / 0.7)
    endif
    return 0.0
endfunction

// The emblem's own colour: full, a little dimmer when the silhouette comes (3.5-3.8 s), dark after the stop.
function Pres_Dim takes real m returns integer
    if m < 3.5 then
        return 255
    elseif m < 3.8 then
        return R2I(255 - 85 * (m - 3.5) / 0.3)
    elseif m < 5.8 then
        return 170
    elseif m < 6.0 then
        return R2I(170 - 90 * (m - 5.8) / 0.2)
    endif
    return 80
endfunction

// A full-screen pale flash fading out in 0.3 s (the reference's stop, reveal and pose frames).
function Pres_Flash takes nothing returns nothing
    call SetCineFilterTexture("ReplaceableTextures\\\\CameraMasks\\\\White_mask.blp")
    call SetCineFilterBlendMode(BLEND_MODE_BLEND)
    call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
    call SetCineFilterStartUV(0, 0, 1, 1)
    call SetCineFilterEndUV(0, 0, 1, 1)
    call SetCineFilterStartColor(255, 250, 225, 215)
    call SetCineFilterEndColor(255, 250, 225, 0)
    call SetCineFilterDuration(0.3)
    call DisplayCineFilter(true)
endfunction

function Pres_HideBoard takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 39
        call Title_Show(Hero_CellQ[i], false)
        call Title_Show(Hero_CellFrame[i], false)
        if Boss_Icon[i] != 0 then
            call Title_Show(Boss_CellIcon[i], false)
        endif
        if i < 5 then
            call Title_Show(Strat_Pic[i], false)
        endif
        if i < 4 then
            call SetUnitScale(Strat_Card[i], 0, 0, 0)
            call SetTextTagVisibility(Strat_Tag[i], false)
        endif
        if i < 2 then
            call SetUnitScale(Strat_Shield[i], 0, 0, 0)
        endif
        if i < 8 then
            call SetUnitScale(Strat_Hi[i], 0, 0, 0)
            call SetUnitScale(Strat_Sel[i], 0, 0, 0)
        endif
        set i = i + 1
    endloop
    call Title_Show(Strat_BossFrame, false)
    call Title_Show(Strat_BossIcon, false)
    call SetUnitScale(Hero_Portrait, 0, 0, 0)
    call Clock_Show(-1, 0, 0)
    if Title_Bg != null then
        call SetUnitScale(Title_Bg, 0, 0, 0)
    endif
endfunction

function Pres_Build takes nothing returns nothing
    local integer i = 0
    local integer array tex
    local real array w
    local real array h
    set tex[0] = 'DT3K'
    set tex[1] = 'DT3L'
    set tex[2] = 'DT3M'
    set w[0] = 700
    set h[0] = 674.8
    set w[1] = 504.5
    set h[1] = 416.2
    set w[2] = 438.3
    set h[2] = 368.9
    // The nebula where the animated background was (fly height 300, depth Title_D + Title_Eye - 300).
    set Pres_Bg = Strat_FxAt('ubt9', 961, 438.17, Title_D() + Title_Eye - 300, 0.65, 1)
    loop
        exitwhen i > 2
        set Pres_Pic[i] = Title_Pic('uidb', Pres_PX(i), Pres_PY(i) + Pres_Off(i, 0), w[i], h[i], 404 - i, tex[i])
        set Pres_Hi[i] = Title_Pic('uidg', Pres_PX(i), Pres_PY(i) + Pres_Off(i, 0), w[i], h[i], 403.5 - i, tex[i])
        call SetUnitVertexColor(Pres_Hi[i], 0, 0, 0, 0)
        set i = i + 1
    endloop
    // The hydra about 0.6 of the ring tall (v9x: x2.65 at depth 300, in front of the emblem at 401-404), a black
    // silhouette, hidden until 3.6 s.
    set Pres_Hydra = CreateUnit(CAMERA_DUMMY_PLAYER, 'ubt8', Title_WX(440, 300), Title_WY(961, 300), 0)
    call UnitAddAbility(Pres_Hydra, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(Pres_Hydra, s__Interface_DESTROYER_FORM_ID)
    call UnitAddAbility(Pres_Hydra, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(Pres_Hydra, s__Interface_LOCUST_ID)
    call SetUnitFlyHeight(Pres_Hydra, Title_D() + Title_Eye - 300, 0)
    call SetUnitScale(Pres_Hydra, 0.556, 0.556, 0.556)
    call SetUnitVertexColor(Pres_Hydra, 0, 0, 0, 0)
    // The glows in front of everything, the band as wide as the screen (2400 model units).
    set Pres_GH = Strat_FxAt('ubta', 961, 430, 330, 0, 1)
    set Pres_GV = Strat_FxAt('ubtb', 961, 430, 330, 0, 1)
    set Pres_Built = true
endfunction

function Pres_Pulse takes unit u returns nothing
    local real s = 1920 * (0.544 / 718.18930543) * 330 / 2400
    call SetUnitScale(u, s, s, s)
    call SetUnitAnimationByIndex(u, 0)
endfunction

// A glow's convergence (Birth 0.65 s, non-looping) would fall back to its looping Stand: Death after it, then gone.
function Pres_GlowEnd takes unit u, real at, real m returns nothing
    if m >= at + 0.65 and m < at + 0.67 then
        call SetUnitAnimationByIndex(u, 2)
    elseif m >= at + 0.8 and m < at + 0.82 then
        call SetUnitScale(u, 0, 0, 0)
    endif
endfunction

function Pres_Tick takes nothing returns nothing
    local real m
    local real g
    local integer d
    local integer i = 0
    local integer a
    set Pres_Time = Pres_Time + 0.02
    if Pres_Step == 0 and Pres_Time >= 1.0 then
        set Pres_Step = 1
        call Pres_HideBoard()
        call Pres_Build()
    elseif Pres_Step == 1 and Pres_Time >= 3.0 then
        set Pres_Step = 2
        call StartSound(Pres_Snd)
        call Pres_Black(255, 0, 0.3)
    elseif Pres_Step == 2 and Pres_Time >= 3.35 then
        set Pres_Step = 3
        call DisplayCineFilter(false)
    endif
    if Pres_Step < 2 then
        return
    endif
    set m = Pres_Time - 3.0
    if m > 7 then
        call PauseTimer(Pres_T)
        return
    endif
    set g = Pres_Glow(m)
    set d = Pres_Dim(m)
    loop
        exitwhen i > 2
        call Hero_Put(Pres_Pic[i], Pres_PX(i), Pres_PY(i) + Pres_Off(i, m))
        call Hero_Put(Pres_Hi[i], Pres_PX(i), Pres_PY(i) + Pres_Off(i, m))
        call SetUnitVertexColor(Pres_Pic[i], d, d, d, 255)
        call SetUnitVertexColor(Pres_Hi[i], R2I(g), R2I(g), R2I(g), R2I(g))
        set i = i + 1
    endloop
    if Pres_Step == 3 and m >= 1.8 then
        set Pres_Step = 4
        call Pres_Flash()
        set Pres_GHAt = m
        call Pres_Pulse(Pres_GH)
    elseif Pres_Step == 4 and m >= 3.6 then
        set Pres_Step = 5
        call SetUnitAnimationByIndex(Pres_Hydra, 0)
    elseif Pres_Step == 5 and m >= 5.2 then
        set Pres_Step = 6
        call Pres_Flash()
        call SetUnitVertexColor(Pres_Hydra, 255, 255, 255, 255)
        call SetUnitAnimationByIndex(Pres_Hydra, 3)
        set Pres_GVAt = m
        call Pres_Pulse(Pres_GV)
    elseif Pres_Step == 6 and m >= 5.8 then
        set Pres_Step = 7
        call Pres_Flash()
        call SetUnitTimeScale(Pres_Hydra, 0)
        set Pres_GHAt = m
        call Pres_Pulse(Pres_GH)
    endif
    call Pres_GlowEnd(Pres_GH, Pres_GHAt, m)
    call Pres_GlowEnd(Pres_GV, Pres_GVAt, m)
    if Pres_Step == 5 then
        set a = R2I(RMinBJ((m - 3.6) / 0.2, 1) * 255)
        call SetUnitVertexColor(Pres_Hydra, 0, 0, 0, a)
    endif
endfunction

// Strategy time up: the music fades out, black in 1 s, the scene built in the dark, 2 s later it fades in.
function Pres_Begin takes nothing returns nothing
    if Pres_On then
        return
    endif
    set Pres_On = true
    set Pres_Time = 0
    set Pres_Step = 0
    set Pres_GHAt = -9
    set Pres_GVAt = -9
    call StopMusic(true)
    call Pres_Black(0, 255, 1.0)
    if Pres_Snd == null then
        set Pres_Snd = CreateSound("war3mapImported\\\\PresTema.mp3", false, false, false, 10, 10, "DefaultEAXON")
        call SetSoundDuration(Pres_Snd, 9850)
    endif
    if Pres_T == null then
        set Pres_T = CreateTimer()
    endif
    call TimerStart(Pres_T, 0.02, true, function Pres_Tick)
endfunction

// -titulo: the presentation gone.
function Pres_Reset takes nothing returns nothing
    local integer i = 0
    if not Pres_On then
        return
    endif
    set Pres_On = false
    call PauseTimer(Pres_T)
    call StopSound(Pres_Snd, false, false)
    call DisplayCineFilter(false)
    if Pres_Built then
        call RemoveUnit(Pres_Bg)
        call RemoveUnit(Pres_Hydra)
        call RemoveUnit(Pres_GH)
        call RemoveUnit(Pres_GV)
        loop
            exitwhen i > 2
            call RemoveUnit(Pres_Pic[i])
            call RemoveUnit(Pres_Hi[i])
            set Pres_Pic[i] = null
            set Pres_Hi[i] = null
            set i = i + 1
        endloop
        set Pres_Bg = null
        set Pres_Hydra = null
        set Pres_GH = null
        set Pres_GV = null
        set Pres_Built = false
    endif
    if Title_Bg != null then
        call SetUnitScale(Title_Bg, Title_BgScale, Title_BgScale, Title_BgScale)
    endif
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='utf-8', newline='')
    s = once(s, 'real Strat_PX= 0\n', GLOBALS + 'real Strat_PX= 0\n')
    s = once(s, '''    set Strat_Left = 30
    set Strat_Ticks = 0
    call Hero_ClockShow(30)
''', '''    set Strat_Left = 5
    set Strat_Ticks = 0
    call Hero_ClockShow(5)
''')
    s = once(s, 'function Strat_Tick takes nothing returns nothing\n', FUNCS + 'function Strat_Tick takes nothing returns nothing\n')
    s = once(s, '''                    call SetUnitScale(Strat_Hi[p], 0, 0, 0)
                    set p = p + 1
                endloop
            endif''', '''                    call SetUnitScale(Strat_Hi[p], 0, 0, 0)
                    set p = p + 1
                endloop
                call Pres_Begin()
            endif''')
    s = once(s, '    call Strat_Reset()\n', '    call Strat_Reset()\n    call Pres_Reset()\n')
    Path(sys.argv[2]).write_bytes(s.encode('utf-8'))
    print('ok', len(s))
