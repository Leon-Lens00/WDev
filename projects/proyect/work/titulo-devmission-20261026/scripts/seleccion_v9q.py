"""Boss select v9q (Dev Mission title, 29/10/2026). Patches the compiled war3map.j of v9p (CRLF kept).

The user's requests after v9p:
- the hero screen's pick button under the boss name: BossPick ('DT38', texturas_v9q.py, the Lock in box 374 x 114)
  at (968, 757), depth 401, with LockGlow ('DT2Q') at 399 under the mouse (one picture, scaled on the hovering
  player's screen only); the bottom row split in the middle and each half pushed outwards (centres 188-720 and
  1216-1748, pitch 133) so the button fits; its trackable (kind 240, BossHitPick.mdx 355 x 87 px) at depth 400 as
  the boss cells;
- a cell click only chooses p's candidate (p's glow on the cell); Pick confirms it: p's vote, slot icon and the
  centre plays that boss's pick (Boss_Display) for everybody. Everybody picked -> at most 3 s left, as Lock in;
- time up: the most picked boss; a tie (everybody different included) is drawn among the tied bosses only; no
  pick at all draws among every boss. GetRandomInt runs on every client outside GetLocalPlayer. The centre plays
  the winner's pick;
- 2 s after that the camera and the Start background move right (+Y in the world, rotation 180) by Boss_Pan over
  1.2 s (smoothstep), leaving the boss pieces behind: the next board, empty for now. The camera bounds are widened
  for the pan and restored by Boss_Reset (-titulo).
The card is skinned with the boss's texture (Boss_Icon) in Boss_Display; there is still one boss (Nereus).

Usage: seleccion_v9q.py IN_J OUT_J
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


BOUNDS = ('call SetCameraBounds(Title_X() - 1, Title_Y() - 1, Title_X() - 1, Title_Y() + {0}1, Title_X() + 1, '
          'Title_Y() + {0}1, Title_X() + 1, Title_Y() - 1)')

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='utf-8', newline='')
    s = once(s, 'integer array Boss_Choice\n', '''integer array Boss_Choice
boolean array Boss_Picked
boolean array Boss_PickHover
unit Boss_PickBtn= null
unit Boss_PickGlow= null
integer Boss_Final= -1
real Boss_PanTime= -1
real Boss_Pan= 640
real Title_PanY= 0
''')
    s = once(s, '    call SetCameraPosition(Title_X(), Title_Y())\nendfunction\n',
             '    call SetCameraPosition(Title_X(), Title_Y() + Title_PanY)\nendfunction\n')

    # Bottom row in two halves around the pick button.
    s = once(s, '    return 368.5 + 133.0 * (b - 30)\n', '''    // v9q: the pick button between the bottom row's halves.
    if b < 35 then
        return 188.0 + 133.0 * (b - 30)
    endif
    return 1216.0 + 133.0 * (b - 35)
''')

    # The button and its glow.
    s = once(s, '''    set Boss_Name = Title_Pic('uidb', 970, 663, 256, 128, 403, 'DT30')
    call Title_Show(Boss_Name, false)
''', '''    set Boss_Name = Title_Pic('uidb', 970, 663, 256, 128, 403, 'DT30')
    call Title_Show(Boss_Name, false)
    // v9q: the hero screen's pick button (the Lock in box) under the name, LockGlow over it under the mouse.
    set Boss_PickBtn = Title_Pic('uidb', 968, 757, 374, 114, 401, 'DT38')
    call Title_Show(Boss_PickBtn, false)
    set Boss_PickGlow = Title_Pic('uidg', 968, 757, 374, 114, 399, 'DT2Q')
    call Title_Show(Boss_PickGlow, false)
''')
    s = once(s, '''                call Title_Track(p, "war3mapImported\\\\BossHitCell.mdx", Title_WX(Boss_CellY(b), depth), Title_WY(Boss_CellX(b), depth), 200 + b)
                set b = b + 1
            endloop
''', '''                call Title_Track(p, "war3mapImported\\\\BossHitCell.mdx", Title_WX(Boss_CellY(b), depth), Title_WY(Boss_CellX(b), depth), 200 + b)
                set b = b + 1
            endloop
            call Title_Track(p, "war3mapImported\\\\BossHitPick.mdx", Title_WX(759.5, depth), Title_WY(968, depth), 240)
''')

    # Pick glow, the card's texture, the decision.
    s = once(s, '''// The centre shows boss cell b: Dev Us's pick''', '''// The pick button's glow on p's screen while p's mouse is on it and p has not picked.
function Boss_ShowPickHover takes integer p returns nothing
    local real s = 0
    if Boss_PickHover[p] and Boss_Ready and not Boss_Picked[p] then
        set s = LoadReal(Title_HT, GetHandleId(Boss_PickGlow), 1)
    endif
    if GetLocalPlayer() == Player(p) then
        call SetUnitScale(Boss_PickGlow, s, s, s)
    endif
endfunction

// The centre shows boss cell b: Dev Us's pick''')
    s = once(s, '''    call Title_Show(Boss_Card, true)
    call Title_Show(Boss_Name, true)
    if Boss_Shield == null then''', '''    call Title_Skin(Boss_Card, Boss_Icon[b])
    call Title_Show(Boss_Card, true)
    call Title_Show(Boss_Name, true)
    if Boss_Shield == null then''')
    s = once(s, '''function Boss_Fly takes nothing returns nothing''', '''// Time up: the most picked boss; a tie (everybody different included) is drawn among the tied bosses only, no
// pick at all among every boss. GetRandomInt runs on every client (synchronised). The centre plays the winner's
// pick and 2 s later the camera moves to the next board.
function Boss_Decide takes nothing returns nothing
    local integer array votes
    local integer array tied
    local integer n = 0
    local integer best = 0
    local integer i = 0
    local integer b
    loop
        exitwhen i > 39
        set votes[i] = 0
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 7
        if Title_Registered[i] and Boss_Picked[i] then
            set b = Boss_Choice[i]
            set votes[b] = votes[b] + 1
            if votes[b] > best then
                set best = votes[b]
            endif
        endif
        set i = i + 1
    endloop
    set b = 0
    loop
        exitwhen b > 39
        if Boss_Icon[b] != 0 and votes[b] == best then
            set tied[n] = b
            set n = n + 1
        endif
        set b = b + 1
    endloop
    set Boss_Final = tied[GetRandomInt(0, n - 1)]
    call Boss_Display(Boss_Final)
    set Boss_PanTime = Boss_Time + 2
    ''' + BOUNDS.format('Boss_Pan + ') + '''
endfunction

function Boss_Fly takes nothing returns nothing''')
    s = once(s, '''    set Boss_Landed = true
    loop''', '''    set Boss_Landed = true
    call Title_Show(Boss_PickBtn, true)
    loop''')

    # Tick: the decision at 0 and the pan.
    s = once(s, '''function Boss_Tick takes nothing returns nothing
    local integer i = 0
''', '''function Boss_Tick takes nothing returns nothing
    local integer i = 0
    local real t
''')
    s = once(s, '''            set Boss_FxTime = -1
        endif
    endif
    if Boss_Ready then''', '''            set Boss_FxTime = -1
        endif
    endif
    if Boss_PanTime >= 0 and Boss_Time >= Boss_PanTime then
        set t = RMinBJ((Boss_Time - Boss_PanTime) / 1.2, 1)
        set Title_PanY = Boss_Pan * t * t * (3 - 2 * t)
        call SetUnitY(Title_Bg, Title_Y() + Title_PanY)
        call SetCameraPosition(Title_X(), Title_Y() + Title_PanY)
        if t >= 1 then
            set Boss_PanTime = -1
        endif
    endif
    if Boss_Ready then''')
    s = once(s, '''                loop
                    exitwhen i > 11
                    call SetUnitScale(Boss_Neon[i], 0, 0, 0)
                    set i = i + 1
                endloop
            endif
''', '''                loop
                    exitwhen i > 11
                    call SetUnitScale(Boss_Neon[i], 0, 0, 0)
                    set i = i + 1
                endloop
                call SetUnitScale(Boss_PickGlow, 0, 0, 0)
                call Boss_Decide()
            endif
''')

    # Start and reset.
    s = once(s, '''        if i < 12 then
            set Boss_Choice[i] = -1
            set Boss_Hover[i] = -1
''', '''        if i < 12 then
            set Boss_Choice[i] = -1
            set Boss_Picked[i] = false
            set Boss_PickHover[i] = false
            set Boss_Hover[i] = -1
''')
    s = once(s, '''    set Boss_Active = true
    set Boss_Landed = false
''', '''    set Boss_Active = true
    set Boss_Landed = false
    set Boss_Final = -1
    set Boss_PanTime = -1
''')
    s = once(s, '''    call Title_Show(Boss_Card, false)
    call Title_Show(Boss_Name, false)
    call Boss_Remove(Boss_Shield)''', '''    call Title_Show(Boss_Card, false)
    call Title_Show(Boss_Name, false)
    call Title_Show(Boss_PickBtn, false)
    call SetUnitScale(Boss_PickGlow, 0, 0, 0)
    set Boss_PanTime = -1
    if Title_PanY != 0 then
        set Title_PanY = 0
        ''' + BOUNDS.format('') + '''
        if Title_Bg != null then
            call SetUnitY(Title_Bg, Title_Y())
        endif
    endif
    call Boss_Remove(Boss_Shield)''')

    # Hover and hits.
    s = once(s, '''function Boss_OnTrack takes integer p, integer kind returns nothing
    local integer b = kind - 200
    local real s = 0
''', '''function Boss_OnTrack takes integer p, integer kind returns nothing
    local integer b = kind - 200
    local real s = 0
    local boolean on = kind == 240 and Boss_Ready
    if on != Boss_PickHover[p] then
        set Boss_PickHover[p] = on
        call Boss_ShowPickHover(p)
    endif
''')
    i = s.index(L('function Boss_OnHit takes integer p, integer kind returns nothing\n'))
    j = s.index(L('// Hidden pieces, no unit, not active'), i)
    s = s[:i] + L('''// Pick: p's vote is p's chosen cell; the slot shows it and the centre plays its pick for everybody. Everybody
// picked -> at most 3 s left.
function Boss_Pick takes integer p returns nothing
    local integer b = Boss_Choice[p]
    local integer i = 0
    local integer n = 0
    if b < 0 or Boss_Icon[b] == 0 then
        return
    endif
    set Boss_Picked[p] = true
    call Boss_ShowPickHover(p)
    call Title_Show(Hero_SlotQ[p], false)
    if Boss_SlotIcon[p] != null then
        call RemoveUnit(Boss_SlotIcon[p])
    endif
    set Boss_SlotIcon[p] = Title_Pic('uidb', Hero_SlotX(p), 138.5, 53, 53, 402, 'DT32')
    call Boss_Display(b)
    loop
        exitwhen i > 7
        if Title_Registered[i] and not Boss_Picked[i] then
            set n = n + 1
        endif
        set i = i + 1
    endloop
    if n == 0 and Boss_Left > 3 then
        set Boss_Left = 3
        set Boss_Ticks = 0
        call Hero_ClockShow(3)
    endif
endfunction

// A cell: p's candidate (p's glow on it); the pick button confirms it.
function Boss_OnHit takes integer p, integer kind returns nothing
    local integer b = kind - 200
    if not Boss_Ready or p > 7 or not Title_Registered[p] or Boss_Picked[p] then
        return
    endif
    if kind == 240 then
        call Boss_Pick(p)
        return
    endif
    if b < 0 or b > 39 or Boss_Icon[b] == 0 or Boss_Choice[p] == b then
        return
    endif
    set Boss_Choice[p] = b
    call Hero_Put(Hero_Glow[p], Boss_CellX(b), Boss_CellY(b))
    call Title_Show(Hero_Glow[p], true)
endfunction

''') + s[j:]
    Path(sys.argv[2]).write_text(s, encoding='utf-8', newline='')
    print('ok', len(s))
