"""v10r: the presentation's end. The theme (9.85 s, heard from m 0.4) ends at m 10.25, as the user's intro video does:
fade to black over its last 0.6 s, then, in the dark, the scene removed and Title_Exit (the game camera on the
player's start location), and the fade in.
Usage: fin_v10r.py IN.j OUT.j
"""
import sys

src, dst = sys.argv[1], sys.argv[2]
j = open(src, encoding='latin-1', newline='').read()


def rep(old, new):
    global j
    old, new = old.replace('\n', '\r\n'), new.replace('\n', '\r\n')
    assert j.count(old) == 1, old
    j = j.replace(old, new)


rep('''    set m = Pres_Time - 3.2
    if m > 7 then
        call PauseTimer(Pres_T)
        return
    endif
''', '''    set m = Pres_Time - 3.2
    // The end (v10r): black as the theme ends (m 10.25), then the game on the start location, faded in.
    if m >= 9.65 and m < 9.67 then
        call Pres_Black(0, 255, 0.6)
    elseif m >= 10.3 then
        // Pres_Reset and Title_Exit come later in the script.
        call PauseTimer(Pres_T)
        call ExecuteFunc("Pres_Finish")
        return
    endif
    if m > 7 then
        return
    endif
''')
rep('''    call TimerStart(CreateTimer(), 0.2, false, function ConversationUI___Start)
endfunction
''', '''    call TimerStart(CreateTimer(), 0.2, false, function ConversationUI___Start)
endfunction

// v10r: the presentation's end, in the dark (from Pres_Tick by name).
function Pres_Finish takes nothing returns nothing
    call Pres_Reset()
    call Title_Exit()
    call Pres_Black(255, 0, 0.8)
endfunction
''')
open(dst, 'w', encoding='latin-1', newline='').write(j)
