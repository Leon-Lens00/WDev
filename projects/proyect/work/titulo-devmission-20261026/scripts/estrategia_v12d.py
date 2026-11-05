"""Dev Mission title v12d (30/10/2026): the Tauren speaks when the strategy panel is ready.

HeroTaurenChieftainYes3 ("An excellent plan." slot), with no input, once Strat_Ready turns true, plus the portrait
Talk for its length. Hero_SayEnd becomes Hero_SayAll so both automatic lines share one loop.

Usage: estrategia_v12d.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def once(s, old, new):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


SOUND = '''    set Hero_VoiceStrat = CreateSound("Units\\\\Orc\\\\HeroTaurenChieftain\\\\HeroTaurenChieftainYes3.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(Hero_VoiceStrat, 1523)
    call SetSoundChannel(Hero_VoiceStrat, 0)
    call SetSoundVolume(Hero_VoiceStrat, 127)
'''

SAY_ALL = '''// Everyone with a real hero speaks, locked in or not.
function Hero_SayAll takes sound s, real secs returns nothing
    local integer p = 0
    loop
        exitwhen p > 7
        if Title_Registered[p] and Hero_Choice[p] >= 0 and Hero_Icon[Hero_Choice[p]] != 0 then
            call Hero_Say(p, s, secs)
        endif
        set p = p + 1
    endloop
endfunction

'''

OLD_END = '''// Everyone with a real hero speaks when the clock ends, locked in or not.
function Hero_SayEnd takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 7
        if Title_Registered[p] and Hero_Choice[p] >= 0 and Hero_Icon[Hero_Choice[p]] != 0 then
            call Hero_Say(p, Hero_VoiceEnd, 1.904)
        endif
        set p = p + 1
    endloop
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = once(s, 'sound Hero_VoiceEnd= null\n', 'sound Hero_VoiceEnd= null\nsound Hero_VoiceStrat= null\n')
    s = once(s, '    call SetSoundVolume(Hero_VoiceEnd, 127)\n', '    call SetSoundVolume(Hero_VoiceEnd, 127)\n' + SOUND)
    old = '        call StopSound(Hero_VoiceEnd, false, false)\n'.replace('\n', N)
    assert s.count(old) == 2
    s = s.replace(old, old + '        call StopSound(Hero_VoiceStrat, false, false)' + N)
    s = once(s, 'function Hero_Put takes unit u, real px, real py returns nothing\n',
             SAY_ALL + 'function Hero_Put takes unit u, real px, real py returns nothing\n')
    s = once(s, OLD_END, '')
    s = once(s, '            call Hero_SayEnd()\n', '            call Hero_SayAll(Hero_VoiceEnd, 1.904)\n')
    s = once(s, '    set Strat_Ready = true\n    set Strat_Left = 5\n',
             '    set Strat_Ready = true\n    call Hero_SayAll(Hero_VoiceStrat, 1.523)\n    set Strat_Left = 5\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
