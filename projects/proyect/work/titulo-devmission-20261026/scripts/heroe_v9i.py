"""Hero select v9i (Dev Mission title, 29/10/2026). Patches the compiled war3map.j of v9h (CRLF kept).

Pieces instead of the cells painted on the background (texturas_v9i.py):
- every cell is the "?" square (CellQ, 96 px, depth 402) under its frame (CellFrame, transparent inside, 401); a
  cell with a hero shows the hero's button (62 px, 402) instead of the "?" square. Hero_Icon[k] is the button's
  destructable texture; for now only cell 0, the game's Tauren Chieftain ('DT2R');
- the 8 top slots are the same pieces at 65/76 (82 px) with the player's cell glow (HeroGlow, 109.5 px) always on;
  on Lock in the player's slot shows the hero's button (53 px), made then (never re-skinned);
- Lock in: a trackable (kind 140, HeroHitLock.mdx) whose hover lights LockGlow additively for that player only
  (scale, in GetLocalPlayer: visual); a click locks the player's hero if the chosen cell has one;
- when every registered player (slots 1-8) has locked and more than 3 s are left, the clock drops to 3;
- the panel shows the UI system's Tauren portrait ('dta0', billboarded, idle DIALOGUE_RIGHT_IDLE) for a player
  whose chosen cell is the Tauren's, 176 px tall over the portrait window, by scale in GetLocalPlayer.

Usage: heroe_v9i.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def L(s):
    return s.replace('\n', N)


def once(s, old, new):
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


GLOBALS = L('''unit array Hero_CellQ
unit array Hero_CellFrame
unit array Hero_CellIcon
integer array Hero_Icon
unit array Hero_SlotQ
unit array Hero_SlotFrame
unit array Hero_SlotGlow
unit array Hero_SlotIcon
boolean array Hero_Locked
boolean array Hero_LockHover
unit Hero_LockGlow= null
unit Hero_Portrait= null
real Hero_PortraitScale= 0
''')

HELPERS = L('''
// v9i: the top slots, mockup x + 80: 522.5 + 90 p for players 1-4, 1128.5 + 88 (p - 4) for 5-8; y 138.5.
function Hero_SlotX takes integer p returns real
    if p < 4 then
        return 522.5 + 90.0 * p
    endif
    return 1128.5 + 88.0 * (p - 4)
endfunction

// Lock in lit for player p while the mouse is on it and the hero is not locked; only on p's screen.
function Hero_ShowLockHover takes integer p returns nothing
    local real s = 0
    if Hero_LockHover[p] and not Hero_Locked[p] then
        set s = LoadReal(Title_HT, GetHandleId(Hero_LockGlow), 1)
    endif
    if GetLocalPlayer() == Player(p) then
        call SetUnitScale(Hero_LockGlow, s, s, s)
    endif
endfunction

// The panel's portrait on p's screen: the Tauren's while p's chosen cell is the Tauren's.
function Hero_ShowPortrait takes integer p returns nothing
    local real s = 0
    if Hero_Choice[p] >= 0 and Hero_Icon[Hero_Choice[p]] == 'DT2R' then
        set s = Hero_PortraitScale
    endif
    if GetLocalPlayer() == Player(p) then
        call SetUnitScale(Hero_Portrait, s, s, s)
    endif
endfunction
''')

BUILD = L('''    set i = 0
    loop
        exitwhen i > 39
        set Hero_Icon[i] = 0
        set Hero_CellQ[i] = Title_Pic('uidb', Hero_CellX(i), Hero_CellY(i), 96, 96, 402, 'DT2O')
        call Title_Show(Hero_CellQ[i], false)
        set Hero_CellFrame[i] = Title_Pic('uidb', Hero_CellX(i), Hero_CellY(i), 96, 96, 401, 'DT2P')
        call Title_Show(Hero_CellFrame[i], false)
        set i = i + 1
    endloop
    // The heroes so far: the cell's button under its frame.
    set Hero_Icon[0] = 'DT2R'
    set i = 0
    loop
        exitwhen i > 39
        if Hero_Icon[i] != 0 then
            set Hero_CellIcon[i] = Title_Pic('uidb', Hero_CellX(i), Hero_CellY(i), 62, 62, 402, Hero_Icon[i])
            call Title_Show(Hero_CellIcon[i], false)
        endif
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 7
        set Hero_SlotQ[i] = Title_Pic('uidb', Hero_SlotX(i), 138.5, 82, 82, 402, 'DT2O')
        call Title_Show(Hero_SlotQ[i], false)
        set Hero_SlotFrame[i] = Title_Pic('uidb', Hero_SlotX(i), 138.5, 82, 82, 401, 'DT2P')
        call Title_Show(Hero_SlotFrame[i], false)
        set Hero_SlotGlow[i] = Title_Pic('uidg', Hero_SlotX(i), 138.5, 109.5, 109.5, 399, Hero_GlowTex[i])
        call Title_Show(Hero_SlotGlow[i], false)
        set i = i + 1
    endloop
    set Hero_LockGlow = Title_Pic('uidg', 1489, 772, 374, 114, 399, 'DT2Q')
    call Title_Show(Hero_LockGlow, false)
    // The card is 21.4 tall at scale 1 (ConversationUI portraits, +-10.7); 176 px at depth 405.
    set Hero_PortraitScale = 176 * (0.302 / 387.73819261) * 405 / 21.4
    set Hero_Portrait = CreateUnit(CAMERA_DUMMY_PLAYER, 'dta0', Title_WX(394, 405), Title_WY(1487, 405), 0)
    call UnitAddAbility(Hero_Portrait, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(Hero_Portrait, s__Interface_DESTROYER_FORM_ID)
    call SetUnitFlyHeight(Hero_Portrait, Title_D() + Title_Eye - 405, 0)
    call SetUnitAnimationByIndex(Hero_Portrait, DIALOGUE_RIGHT_IDLE)
    call SetUnitScale(Hero_Portrait, 0, 0, 0)
endfunction
''')

PIECES = L('''
// Every cell and slot piece shown or hidden (cells with a hero show its button instead of the "?" square).
function Hero_Pieces takes boolean on returns nothing
    local integer i = 0
    loop
        exitwhen i > 39
        call Title_Show(Hero_CellQ[i], on and Hero_Icon[i] == 0)
        call Title_Show(Hero_CellFrame[i], on)
        if Hero_Icon[i] != 0 then
            call Title_Show(Hero_CellIcon[i], on)
        endif
        if i < 8 then
            call Title_Show(Hero_SlotQ[i], on)
            call Title_Show(Hero_SlotFrame[i], on)
            call Title_Show(Hero_SlotGlow[i], on)
            if Hero_SlotIcon[i] != null then
                call RemoveUnit(Hero_SlotIcon[i])
                set Hero_SlotIcon[i] = null
            endif
        endif
        set i = i + 1
    endloop
    call Title_Show(Hero_LockGlow, false)
    call SetUnitScale(Hero_Portrait, 0, 0, 0)
endfunction
''')

LOCK = L('''// Lock in: p keeps the chosen cell's hero; the slot shows its button. Everybody locked -> at most 3 s left.
function Hero_Lock takes integer p returns nothing
    local integer k = Hero_Choice[p]
    local integer i = 0
    local integer n = 0
    if k < 0 or Hero_Icon[k] == 0 then
        return
    endif
    set Hero_Locked[p] = true
    call Hero_ShowLockHover(p)
    call Title_Show(Hero_SlotQ[p], false)
    set Hero_SlotIcon[p] = Title_Pic('uidb', Hero_SlotX(p), 138.5, 53, 53, 402, Hero_Icon[k])
    loop
        exitwhen i > 7
        if Title_Registered[i] and not Hero_Locked[i] then
            set n = n + 1
        endif
        set i = i + 1
    endloop
    if n == 0 and Hero_Left > 3 then
        set Hero_Left = 3
        set Hero_Ticks = 0
        call Hero_ClockShow(3)
    endif
endfunction

function Hero_OnTrack takes integer p, integer kind returns nothing
    local boolean on = kind == 140 and Hero_Ready
    if on != Hero_LockHover[p] then
        set Hero_LockHover[p] = on
        call Hero_ShowLockHover(p)
    endif
endfunction

function Hero_OnHit takes integer p, integer kind returns nothing
    local integer k = kind - 100
    if not Hero_Ready or p > 7 or not Title_Registered[p] or Hero_Locked[p] then
        return
    endif
    if kind == 140 then
        call Hero_Lock(p)
        return
    endif
    if k < 0 or k > 39 or Hero_Choice[p] == k then
        return
    endif
    set Hero_Choice[p] = k
    call Hero_Put(Hero_Glow[p], Hero_CellX(k), Hero_CellY(k))
    call Title_Show(Hero_Glow[p], true)
    call Hero_ShowPortrait(p)
endfunction
''')

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='utf-8', newline='')
    s = once(s, 'unit array Hero_Glow' + N, 'unit array Hero_Glow' + N + GLOBALS)

    i = s.index('function Hero_CellY takes')
    j = s.index('endfunction' + N, i) + len('endfunction' + N)
    s = s[:j] + HELPERS + s[j:]

    i = s.index('function Hero_Build takes')
    j = s.index('endfunction' + N, i)
    s = s[:j] + BUILD + s[j + len('endfunction' + N):]
    i = s.index('// Hidden pieces, no unit, not active')
    s = s[:i] + PIECES.lstrip(N) + N + s[i:]

    s = once(s, L('''                call Title_Track(p, "war3mapImported\\\\HeroHitCell.mdx", Title_WX(Hero_CellY(k), depth), Title_WY(Hero_CellX(k), depth), 100 + k)
                set k = k + 1
            endloop
'''), L('''                call Title_Track(p, "war3mapImported\\\\HeroHitCell.mdx", Title_WX(Hero_CellY(k), depth), Title_WY(Hero_CellX(k), depth), 100 + k)
                set k = k + 1
            endloop
            call Title_Track(p, "war3mapImported\\\\HeroHitLock.mdx", Title_WX(772, depth), Title_WY(1489, depth), 140)
'''))

    s = once(s, L('''        call Title_Show(Hero_Glow[i], false)
        set i = i + 1
    endloop
    call Hero_ClockShow(-1)
'''), L('''        call Title_Show(Hero_Glow[i], false)
        set i = i + 1
    endloop
    call Hero_Pieces(false)
    call Hero_ClockShow(-1)
'''))
    s = once(s, L('''        set Hero_Choice[i] = -1
        if i < 8 then
            call Title_Show(Hero_Bg[i], true)
            call Title_Show(Hero_Glow[i], false)
        endif
        set i = i + 1
    endloop
'''), L('''        set Hero_Choice[i] = -1
        set Hero_Locked[i] = false
        set Hero_LockHover[i] = false
        if i < 8 then
            call Title_Show(Hero_Bg[i], true)
            call Title_Show(Hero_Glow[i], false)
        endif
        set i = i + 1
    endloop
    call Hero_Pieces(true)
'''))

    i = s.index('function Hero_OnHit takes')
    j = s.index('endfunction' + N, i) + len('endfunction' + N)
    s = s[:i] + LOCK + s[j:]

    s = once(s, L('''    local boolean on = LoadInteger(Title_HT, id, 1) == 0 and Title_Active and not Title_Registered[p]
    if Hero_Active then
        return
    endif
'''), L('''    local boolean on = LoadInteger(Title_HT, id, 1) == 0 and Title_Active and not Title_Registered[p]
    if Hero_Active then
        call Hero_OnTrack(p, LoadInteger(Title_HT, id, 1))
        return
    endif
'''))
    # Time up: no Lock in any more, so its light goes out for everybody.
    s = once(s, L('''        if Hero_Left <= 0 then
            set Hero_Ready = false
        endif
'''), L('''        if Hero_Left <= 0 then
            set Hero_Ready = false
            call Title_Show(Hero_LockGlow, false)
        endif
'''))
    Path(sys.argv[2]).write_text(s, encoding='utf-8', newline='')
    print('ok', len(s))
