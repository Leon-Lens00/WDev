"""Boss select v9s (Dev Mission title, 29/10/2026). Patches the compiled war3map.j of v9r (CRLF kept).

The user's change to the move to the next board: 3 s after the boss is decided (was 2 s) the whole boss screen
shrinks until nothing is left, and only then the camera moves right (v9q/v9r's pan, background at 0.72).
- Boss_ShrinkCollect lists the pieces on screen at that moment: titles and label (Boss_Bg 0-4), the cells' "?"
  squares, frames and boss icons, the players' cell glows, the top slots (square or picked boss icon, frame,
  glow), card, name, pick button, the clock's 0:00 and the sphere effect (Boss_Shield, depth 560, Dev Us scale
  5.5). The rest is already hidden (hover pieces) or gone (beam, flame and spark end 2.6 s after the pick).
- Boss_ShrinkApply(f) scales every piece by f and moves it towards the sphere's centre (968, 402) by f: for a
  piece at depth d the centre's world point is (Title_WX(402, d), Title_WY(968, d)), so on screen the whole
  section shrinks as one image about that point. f goes 1 -> 0 in 0.6 s (smoothstep); 0.3 s later the pan.
- Boss_Reset (-titulo) puts the pieces back at their places, hidden; their owners show them again.

Usage: seleccion_v9s.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def once(s, old, new):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='utf-8', newline='')
    s = once(s, 'real Title_PanY= 0\n', '''real Title_PanY= 0
unit array Boss_SU
real array Boss_SX
real array Boss_SY
real array Boss_SS
real array Boss_SAX
real array Boss_SAY
integer Boss_SN= 0
real Boss_ShrinkTime= -1
''')
    s = once(s, '''// Time up: the most picked boss;''', '''// v9s: one piece on screen for the shrink: its place, its scale s and the sphere centre's world point at its depth.
function Boss_ShrinkAdd takes unit u, real s, real depth returns nothing
    set Boss_SU[Boss_SN] = u
    set Boss_SX[Boss_SN] = GetUnitX(u)
    set Boss_SY[Boss_SN] = GetUnitY(u)
    set Boss_SS[Boss_SN] = s
    set Boss_SAX[Boss_SN] = Title_WX(402, depth)
    set Boss_SAY[Boss_SN] = Title_WY(968, depth)
    set Boss_SN = Boss_SN + 1
endfunction

function Boss_ShrinkPic takes unit u returns nothing
    if u != null then
        call Boss_ShrinkAdd(u, LoadReal(Title_HT, GetHandleId(u), 1), LoadReal(Title_HT, GetHandleId(u), 2))
    endif
endfunction

// Every piece of the boss screen that is shown now (the hover pieces are hidden, the pick effects but the sphere gone).
function Boss_ShrinkCollect takes nothing returns nothing
    local integer i = 0
    set Boss_SN = 0
    loop
        exitwhen i > 39
        if Boss_Icon[Boss_Of[i]] == 0 then
            call Boss_ShrinkPic(Hero_CellQ[i])
        endif
        call Boss_ShrinkPic(Hero_CellFrame[i])
        if Boss_Icon[i] != 0 then
            call Boss_ShrinkPic(Boss_CellIcon[i])
        endif
        if i < 8 then
            if i < 5 then
                call Boss_ShrinkPic(Boss_Bg[i])
            endif
            if Boss_Choice[i] >= 0 then
                call Boss_ShrinkPic(Hero_Glow[i])
            endif
            if Boss_SlotIcon[i] == null then
                call Boss_ShrinkPic(Hero_SlotQ[i])
            else
                call Boss_ShrinkPic(Boss_SlotIcon[i])
            endif
            call Boss_ShrinkPic(Hero_SlotFrame[i])
            call Boss_ShrinkPic(Hero_SlotGlow[i])
        endif
        set i = i + 1
    endloop
    call Boss_ShrinkPic(Boss_Card)
    call Boss_ShrinkPic(Boss_Name)
    call Boss_ShrinkPic(Boss_PickBtn)
    call Boss_ShrinkPic(Clock_Min[0])
    call Boss_ShrinkPic(Clock_Colon)
    call Boss_ShrinkPic(Clock_Tens[0])
    call Boss_ShrinkPic(Clock_Units[0])
    if Boss_Shield != null then
        call Boss_ShrinkAdd(Boss_Shield, 5.5 * 440 * (0.544 / 718.18930543) * 560 / (2 * 78.54 * 5.5), 560)
    endif
endfunction

// f = 1: as collected; f = 0: nothing left, everything at the sphere's centre.
function Boss_ShrinkApply takes real f returns nothing
    local integer i = 0
    local real s
    loop
        exitwhen i >= Boss_SN
        set s = Boss_SS[i] * f
        call SetUnitX(Boss_SU[i], Boss_SAX[i] + (Boss_SX[i] - Boss_SAX[i]) * f)
        call SetUnitY(Boss_SU[i], Boss_SAY[i] + (Boss_SY[i] - Boss_SAY[i]) * f)
        call SetUnitScale(Boss_SU[i], s, s, s)
        set i = i + 1
    endloop
endfunction

// -titulo: the pieces back at their places, hidden (their owners show them again).
function Boss_ShrinkRestore takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= Boss_SN
        call SetUnitX(Boss_SU[i], Boss_SX[i])
        call SetUnitY(Boss_SU[i], Boss_SY[i])
        call SetUnitScale(Boss_SU[i], 0, 0, 0)
        set Boss_SU[i] = null
        set i = i + 1
    endloop
    set Boss_SN = 0
endfunction

// Time up: the most picked boss;''')
    s = once(s, '    set Boss_PanTime = Boss_Time + 2\n', '    set Boss_ShrinkTime = Boss_Time + 3\n')
    s = once(s, '''    if Boss_PanTime >= 0 and Boss_Time >= Boss_PanTime then''', '''    if Boss_ShrinkTime >= 0 and Boss_Time >= Boss_ShrinkTime then
        if Boss_SN == 0 then
            call Boss_ShrinkCollect()
        endif
        set t = RMinBJ((Boss_Time - Boss_ShrinkTime) / 0.6, 1)
        call Boss_ShrinkApply(1 - t * t * (3 - 2 * t))
        if t >= 1 then
            set Boss_ShrinkTime = -1
            set Boss_PanTime = Boss_Time + 0.3
        endif
    endif
    if Boss_PanTime >= 0 and Boss_Time >= Boss_PanTime then''')
    s = once(s, '''    set Boss_Final = -1
    set Boss_PanTime = -1
''', '''    set Boss_Final = -1
    set Boss_PanTime = -1
    set Boss_ShrinkTime = -1
    set Boss_SN = 0
''')
    s = once(s, '''    call DestroyTimer(Boss_Timer)
    set Boss_Timer = null
''', '''    call DestroyTimer(Boss_Timer)
    set Boss_Timer = null
    set Boss_ShrinkTime = -1
    call Boss_ShrinkRestore()
''')
    Path(sys.argv[2]).write_text(s, encoding='utf-8', newline='')
    print('ok', len(s))
