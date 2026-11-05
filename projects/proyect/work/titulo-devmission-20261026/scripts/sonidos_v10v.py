"""v10v: the interface's own sounds on the title's buttons (Dev Mission title, 30/10/2026).

Both are in war3.mpq, so nothing is imported: pre-select (the mouse enters a button or cell) MouseOver1.wav, select
(a click that changes something) BigButtonClick.wav, the game's menu button click (UISounds.slk: MenuButtonClick).
Heard only by the player concerned, as the hover effects are shown: UI_Over and UI_Click touch nothing else, and
the sounds are created for everybody at the start, not at their first use.
Usage: sonidos_v10v.py IN.j OUT.j
"""
import sys

src, dst = sys.argv[1], sys.argv[2]
j = open(src, encoding='latin-1', newline='').read()


def rep(old, new):
    global j
    old, new = old.replace('\n', '\r\n'), new.replace('\n', '\r\n')
    assert j.count(old) == 1, old
    j = j.replace(old, new)


rep('''sound Pres_Snd= null
''', '''sound Pres_Snd= null
sound UI_OverSnd= null
sound UI_ClickSnd= null
''')
rep('''function Title_ShowHover takes integer p returns nothing
''', '''// v10v: the interface's sounds, for player p only.
function UI_Sounds takes nothing returns nothing
    set UI_OverSnd = CreateSound("Sound\\\\Interface\\\\MouseOver1.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(UI_OverSnd, 202)
    call SetSoundChannel(UI_OverSnd, 0)
    call SetSoundVolume(UI_OverSnd, 127)
    set UI_ClickSnd = CreateSound("Sound\\\\Interface\\\\BigButtonClick.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(UI_ClickSnd, 390)
    call SetSoundChannel(UI_ClickSnd, 0)
    call SetSoundVolume(UI_ClickSnd, 100)
endfunction

function UI_Over takes integer p returns nothing
    if GetLocalPlayer() == Player(p) then
        call StopSound(UI_OverSnd, false, false)
        call StartSound(UI_OverSnd)
    endif
endfunction

function UI_Click takes integer p returns nothing
    if GetLocalPlayer() == Player(p) then
        call StopSound(UI_ClickSnd, false, false)
        call StartSound(UI_ClickSnd)
    endif
endfunction

function Title_ShowHover takes integer p returns nothing
''')
# The title's start button.
rep('''    if on != Title_Hover[p] then
        set Title_Hover[p] = on
        call Title_ShowHover(p)
    endif
''', '''    if on != Title_Hover[p] then
        set Title_Hover[p] = on
        call Title_ShowHover(p)
        if on then
            call UI_Over(p)
        endif
    endif
''')
rep('''    set Title_Registered[p] = true
    set Title_Count = Title_Count + 1
''', '''    set Title_Registered[p] = true
    set Title_Count = Title_Count + 1
    call UI_Click(p)
''')
# The mode screen.
rep('''    if b != Mode_Hover[p] then
        set Mode_Hover[p] = b
        call Mode_ShowHover(p)
    endif
''', '''    if b != Mode_Hover[p] then
        set Mode_Hover[p] = b
        call Mode_ShowHover(p)
        if b >= 0 then
            call UI_Over(p)
        endif
    endif
''')
rep('''    set Mode_Choice[p] = 2
    if p < 8 then
        call Title_Show(Mode_GemLit[p], true)
    endif
''', '''    set Mode_Choice[p] = 2
    call UI_Click(p)
    if p < 8 then
        call Title_Show(Mode_GemLit[p], true)
    endif
''')
# The hero select.
rep('''    if k != Hero_HiCell[p] then
        call Hero_ShowHi(p, k)
    endif
    if on != Hero_LockHover[p] then
        set Hero_LockHover[p] = on
        call Hero_ShowLockHover(p)
    endif
''', '''    if k != Hero_HiCell[p] then
        call Hero_ShowHi(p, k)
        if k >= 0 then
            call UI_Over(p)
        endif
    endif
    if on != Hero_LockHover[p] then
        set Hero_LockHover[p] = on
        call Hero_ShowLockHover(p)
        if on then
            call UI_Over(p)
        endif
    endif
''')
rep('''    set Hero_Locked[p] = true
    call Hero_ShowLockHover(p)
''', '''    set Hero_Locked[p] = true
    call UI_Click(p)
    call Hero_ShowLockHover(p)
''')
rep('''    set Hero_Choice[p] = k
    call Hero_Put(Hero_Glow[p], Hero_CellX(k), Hero_CellY(k))
    call Title_Show(Hero_Glow[p], true)
    call Hero_ShowPortrait(p)
endfunction

// Called by Title_Tick''', '''    set Hero_Choice[p] = k
    call UI_Click(p)
    call Hero_Put(Hero_Glow[p], Hero_CellX(k), Hero_CellY(k))
    call Title_Show(Hero_Glow[p], true)
    call Hero_ShowPortrait(p)
endfunction

// Called by Title_Tick''')
# The boss select.
rep('''    if on != Boss_PickHover[p] then
        set Boss_PickHover[p] = on
        call Boss_ShowPickHover(p)
    endif
''', '''    if on != Boss_PickHover[p] then
        set Boss_PickHover[p] = on
        call Boss_ShowPickHover(p)
        if on then
            call UI_Over(p)
        endif
    endif
''')
rep('''    set Boss_Hover[p] = b
    if b >= 0 then
        call Hero_Put(Boss_Neon[p], Boss_CellX(b), Boss_CellY(b))
        set s = LoadReal(Title_HT, GetHandleId(Boss_Neon[p]), 1)
    endif
''', '''    set Boss_Hover[p] = b
    if b >= 0 then
        call Hero_Put(Boss_Neon[p], Boss_CellX(b), Boss_CellY(b))
        set s = LoadReal(Title_HT, GetHandleId(Boss_Neon[p]), 1)
        call UI_Over(p)
    endif
''')
rep('''    set Boss_Picked[p] = true
    call Boss_ShowPickHover(p)
''', '''    set Boss_Picked[p] = true
    call UI_Click(p)
    call Boss_ShowPickHover(p)
''')
rep('''    set Boss_Choice[p] = b
    call Hero_Put(Hero_Glow[p], Boss_CellX(b), Boss_CellY(b))
''', '''    set Boss_Choice[p] = b
    call UI_Click(p)
    call Hero_Put(Hero_Glow[p], Boss_CellX(b), Boss_CellY(b))
''')
# The strategy phase.
rep('''        call Hero_Put(Strat_Hi[p], Strat_SqX(q), Strat_SqY(q))
        set s = LoadReal(Title_HT, GetHandleId(Strat_Hi[p]), 1)
''', '''        call Hero_Put(Strat_Hi[p], Strat_SqX(q), Strat_SqY(q))
        set s = LoadReal(Title_HT, GetHandleId(Strat_Hi[p]), 1)
        call UI_Over(p)
''')
rep('''    set Strat_View[p] = v
    call Strat_PutSel(p)
''', '''    set Strat_View[p] = v
    call UI_Click(p)
    call Strat_PutSel(p)
''')
# At the start, with the rest of the title's setup.
rep('''    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)
''', '''    call UI_Sounds()
    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)
''')
open(dst, 'w', encoding='latin-1', newline='').write(j)
