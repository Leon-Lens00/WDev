"""Dev Mission title v12e (30/10/2026): two heroes, each with its own portrait, icon, name and voices.

Cell 0 is the plain Tauren (Units\\Orc\\Tauren), cell 1 Cairne (Units\\Orc\\Cairne, portrait 'dca0'). Hero_Voice holds
three lines per hero: 0 chosen, 1 clock ended, 2 strategy ready. The English lines are the wiki's for each file.

Usage: personajes_v12e.py IN_J OUT_J FRIZQT.ttf
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import texttags_v12 as tt

N = '\r\n'
once = tt.once

# (file, ms) for hero * 3 + moment.
VOICES = [
    ('Units\\\\Orc\\\\Tauren\\\\TaurenWhat1.wav', 861),        # "Bring it on!"
    ('Units\\\\Orc\\\\Tauren\\\\TaurenReady1.wav', 2410),      # "May my ancestors watch over me."
    ('Units\\\\Orc\\\\Tauren\\\\TaurenYes3.wav', 780),         # "Well done."
    ('Units\\\\Orc\\\\Cairne\\\\CairneWhat3.wav', 1618),       # "Take heart, young one."
    ('Units\\\\Orc\\\\Cairne\\\\CairnePissed4.wav', 3377),     # "I pray this old body does not fail me."
    ('Units\\\\Orc\\\\Cairne\\\\CairneYes1.wav', 1457),        # "Precisely."
]

GLOBALS = '''unit Hero_Cairne= null
sound array Hero_Voice
real array Hero_VoiceLen
'''

NEW_VOICE = '''function Hero_NewVoice takes integer i, string path, integer ms returns nothing
    set Hero_Voice[i] = CreateSound(path, false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(Hero_Voice[i], ms)
    call SetSoundChannel(Hero_Voice[i], 0)
    call SetSoundVolume(Hero_Voice[i], 127)
    set Hero_VoiceLen[i] = ms * 0.001
endfunction

'''

PORTRAIT = '''function Hero_ShowPortrait takes integer p returns nothing
    local real t = 0
    local real c = 0
    if Hero_Choice[p] == 0 then
        set t = Hero_PortraitScale
    elseif Hero_Choice[p] == 1 then
        set c = Hero_PortraitScale
    endif
    if GetLocalPlayer() == Player(p) then
        call SetUnitScale(Hero_Portrait, t, t, t)
        call SetUnitScale(Hero_Cairne, c, c, c)
    endif
endfunction

// Local callers only. Portrait - 1 is sequence 1 in the Tauren and 0 in Cairne.
function Hero_Idle takes nothing returns nothing
    call SetUnitAnimationByIndex(Hero_Portrait, DIALOGUE_RIGHT_IDLE)
    call SetUnitAnimationByIndex(Hero_Cairne, 0)
endfunction

function Hero_StopVoices takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 5
        call StopSound(Hero_Voice[i], false, false)
        set i = i + 1
    endloop
endfunction

// The timer runs on every client; only the sound and the animation are local.
function Hero_TalkEnd takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 7
        if GetExpiredTimer() == Hero_TalkTimer[p] then
            if GetLocalPlayer() == Player(p) then
                call Hero_Idle()
            endif
            return
        endif
        set p = p + 1
    endloop
endfunction

// moment: 0 chosen, 1 clock ended, 2 strategy ready. Hero_VoiceLen, not GetSoundDuration, for a synchronized timer.
function Hero_Say takes integer p, integer moment returns nothing
    local integer k = Hero_Choice[p] * 3 + moment
    if GetLocalPlayer() == Player(p) then
        call Hero_StopVoices()
        call StartSound(Hero_Voice[k])
        call Hero_Idle()
        if Hero_Choice[p] == 0 then
            call SetUnitAnimationByIndex(Hero_Portrait, DIALOGUE_RIGHT_TALK)
        else
            call SetUnitAnimationByIndex(Hero_Cairne, 1)
        endif
    endif
    call TimerStart(Hero_TalkTimer[p], Hero_VoiceLen[k], false, function Hero_TalkEnd)
endfunction

// The portrait is gone: its voice goes with it.
function Hero_Mute takes integer p returns nothing
    call PauseTimer(Hero_TalkTimer[p])
    if GetLocalPlayer() == Player(p) then
        call Hero_StopVoices()
        call Hero_Idle()
    endif
endfunction

// Everyone with a real hero speaks, locked in or not.
function Hero_SayAll takes integer moment returns nothing
    local integer p = 0
    loop
        exitwhen p > 7
        if Title_Registered[p] and Hero_Choice[p] >= 0 and Hero_Icon[Hero_Choice[p]] != 0 then
            call Hero_Say(p, moment)
        endif
        set p = p + 1
    endloop
endfunction

'''

CAIRNE_UNIT = '''    set Hero_Cairne = CreateUnit(CAMERA_DUMMY_PLAYER, 'dca0', Title_WX(394, 405), Title_WY(1487, 405), 0)
    call UnitAddAbility(Hero_Cairne, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(Hero_Cairne, s__Interface_DESTROYER_FORM_ID)
    call SetUnitFlyHeight(Hero_Cairne, Title_D() + Title_Eye - 405, 0)
    call SetUnitAnimationByIndex(Hero_Cairne, 0)
'''

STRAT_PORTRAIT = '''function Strat_ShowPortrait takes real f returns nothing
    local integer p = GetPlayerId(GetLocalPlayer())
    local real t = 0
    local real c = 0
    if p < 12 and Hero_Choice[p] == 0 then
        set t = Strat_PortS * f
    elseif p < 12 and Hero_Choice[p] == 1 then
        set c = Strat_PortS * f
    endif
    call SetUnitScale(Hero_Portrait, t, t, t)
    call SetUnitScale(Hero_Cairne, c, c, c)
endfunction
'''


def between(s, a, b, new):
    i, j = s.index(a), s.index(b)
    assert s.count(a) == 1 and i < j, a
    return s[:i] + new.replace('\n', N) + s[j:]


if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = once(s, 'sound Hero_VoicePick= null\nsound Hero_VoiceEnd= null\nsound Hero_VoiceStrat= null\n', GLOBALS)
    s = once(s, 'function UI_Sounds takes nothing returns nothing\n', NEW_VOICE + 'function UI_Sounds takes nothing returns nothing\n')
    s = between(s, '    set Hero_VoicePick = CreateSound(', '    loop\r\n        exitwhen i > 7\r\n        set Hero_TalkTimer[i]',
                ''.join(f'    call Hero_NewVoice({i}, "{f}", {ms})\n' for i, (f, ms) in enumerate(VOICES)))
    s = between(s, 'function Hero_ShowPortrait takes integer p returns nothing', 'function Hero_Put takes unit u', PORTRAIT)
    s = once(s, '    set Hero_Icon[0] = \'DT2R\'\n', '    set Hero_Icon[0] = \'DT3Q\'\n    set Hero_Icon[1] = \'DT2R\'\n')
    s = once(s, '    call SetUnitAnimationByIndex(Hero_Portrait, DIALOGUE_RIGHT_IDLE)\n    call SetUnitScale(Hero_Portrait, 0, 0, 0)\n',
             '    call SetUnitAnimationByIndex(Hero_Portrait, DIALOGUE_RIGHT_IDLE)\n' + CAIRNE_UNIT
             + '    call SetUnitScale(Hero_Portrait, 0, 0, 0)\n')
    old = '    call SetUnitScale(Hero_Portrait, 0, 0, 0)' + N
    s = s.replace(old, old + '    call SetUnitScale(Hero_Cairne, 0, 0, 0)' + N)
    s = once(s, '    call SetUnitX(Hero_Portrait, Title_WX(311, 405))\n    call SetUnitY(Hero_Portrait, Title_WY(968, 405))\n',
             '    call SetUnitX(Hero_Portrait, Title_WX(311, 405))\n    call SetUnitY(Hero_Portrait, Title_WY(968, 405))\n'
             '    call SetUnitX(Hero_Cairne, Title_WX(311, 405))\n    call SetUnitY(Hero_Cairne, Title_WY(968, 405))\n')
    s = once(s, '    call SetUnitX(Hero_Portrait, Title_WX(394, 405))\n    call SetUnitY(Hero_Portrait, Title_WY(1487, 405))\n',
             '    call SetUnitX(Hero_Portrait, Title_WX(394, 405))\n    call SetUnitY(Hero_Portrait, Title_WY(1487, 405))\n'
             '    call SetUnitX(Hero_Cairne, Title_WX(394, 405))\n    call SetUnitY(Hero_Cairne, Title_WY(1487, 405))\n')
    s = between(s, 'function Strat_ShowPortrait takes real f returns nothing', 'function Strat_Show takes nothing returns nothing', STRAT_PORTRAIT + '\n')
    i = s.index("    if me < 12 and Hero_Choice[me] >= 0 and Hero_Icon[Hero_Choice[me]] == 'DT2R' then")
    j = s.index('    else' + N, i)
    names = ''
    for k, (word) in enumerate(('Tauren', 'Cairne')):
        head = 'if' if k == 0 else 'elseif'
        names += (f'    {head} me < 12 and Hero_Choice[me] == {k} then\n'
                  f'        call SetTextTagText(Strat_Tag[2], {tt.grad(word)}, 0.032)\n'
                  f'        call Strat_TextAt(Strat_Tag[2], 968, 412, 0.032, {tt.width(word, 0.032):.1f})\n')
    s = s[:i] + names.replace('\n', N) + s[j:]
    s = once(s, '            call Hero_SayAll(Hero_VoiceEnd, 1.904)\n', '            call Hero_SayAll(1)\n')
    s = once(s, '    call Hero_SayAll(Hero_VoiceStrat, 1.523)\n', '    call Hero_SayAll(2)\n')
    s = once(s, '        call Hero_Say(p, Hero_VoicePick, 1.55)\n', '        call Hero_Say(p, 0)\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
