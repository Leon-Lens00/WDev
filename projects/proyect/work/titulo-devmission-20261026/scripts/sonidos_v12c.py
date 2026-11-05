"""Dev Mission title v12c (30/10/2026): error sound, Tauren voices, portrait Talk, 5 s before the boss panel.

- cells and boxes with no function yet keep their preselect and answer with Sound\\Interface\\Error.wav;
- choosing the Tauren plays HeroTaurenChieftainWhat1 ("I stand ready" slot);
- when the hero clock ends it plays HeroTaurenChieftainYesAttack2 ("Honor guide me!" slot);
- the portrait plays DIALOGUE_RIGHT_TALK for exactly the voice's length, then goes back to idle;
- the wait between the end of the hero clock and Boss_Start goes from 0.6 to 5 s.

Usage: sonidos_v12c.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def once(s, old, new):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


GLOBALS = '''sound UI_ErrorSnd= null
sound Hero_VoicePick= null
sound Hero_VoiceEnd= null
timer array Hero_TalkTimer
'''

SOUNDS = '''    set UI_ErrorSnd = CreateSound("Sound\\\\Interface\\\\Error.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(UI_ErrorSnd, 614)
    call SetSoundChannel(UI_ErrorSnd, 0)
    call SetSoundVolume(UI_ErrorSnd, 127)
    set Hero_VoicePick = CreateSound("Units\\\\Orc\\\\HeroTaurenChieftain\\\\HeroTaurenChieftainWhat1.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(Hero_VoicePick, 1550)
    call SetSoundChannel(Hero_VoicePick, 0)
    call SetSoundVolume(Hero_VoicePick, 127)
    set Hero_VoiceEnd = CreateSound("Units\\\\Orc\\\\HeroTaurenChieftain\\\\HeroTaurenChieftainYesAttack2.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(Hero_VoiceEnd, 1904)
    call SetSoundChannel(Hero_VoiceEnd, 0)
    call SetSoundVolume(Hero_VoiceEnd, 127)
    loop
        exitwhen i > 7
        set Hero_TalkTimer[i] = CreateTimer()
        set i = i + 1
    endloop
'''

ERROR = '''function UI_Error takes integer p returns nothing
    if GetLocalPlayer() == Player(p) then
        call StopSound(UI_ErrorSnd, false, false)
        call StartSound(UI_ErrorSnd)
    endif
endfunction

'''

VOICE = '''// The timer runs on every client; only the sound and the animation are local.
function Hero_TalkEnd takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 7
        if GetExpiredTimer() == Hero_TalkTimer[p] then
            if GetLocalPlayer() == Player(p) then
                call SetUnitAnimationByIndex(Hero_Portrait, DIALOGUE_RIGHT_IDLE)
            endif
            return
        endif
        set p = p + 1
    endloop
endfunction

// secs is the sound's own length: GetSoundDuration is not used for a synchronized timer.
function Hero_Say takes integer p, sound s, real secs returns nothing
    if GetLocalPlayer() == Player(p) then
        call StopSound(Hero_VoicePick, false, false)
        call StopSound(Hero_VoiceEnd, false, false)
        call StartSound(s)
        call SetUnitAnimationByIndex(Hero_Portrait, DIALOGUE_RIGHT_TALK)
    endif
    call TimerStart(Hero_TalkTimer[p], secs, false, function Hero_TalkEnd)
endfunction

// The portrait is gone: its voice goes with it.
function Hero_Mute takes integer p returns nothing
    call PauseTimer(Hero_TalkTimer[p])
    if GetLocalPlayer() == Player(p) then
        call StopSound(Hero_VoicePick, false, false)
        call StopSound(Hero_VoiceEnd, false, false)
        call SetUnitAnimationByIndex(Hero_Portrait, DIALOGUE_RIGHT_IDLE)
    endif
endfunction

'''

END = '''// Everyone with a real hero speaks when the clock ends, locked in or not.
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
    assert s.startswith('globals' + N) or (N + 'globals' + N) in s
    i = s.index('globals' + N) + len('globals' + N)
    s = s[:i] + GLOBALS.replace('\n', N) + s[i:]
    s = once(s, 'function UI_Sounds takes nothing returns nothing\n',
             'function UI_Sounds takes nothing returns nothing\n    local integer i = 0\n')
    s = once(s, '    call SetSoundVolume(UI_ClickSnd, 100)\nendfunction\n',
             '    call SetSoundVolume(UI_ClickSnd, 100)\n' + SOUNDS + 'endfunction\n')
    s = once(s, 'function Title_ShowHover takes integer p returns nothing\n',
             ERROR + 'function Title_ShowHover takes integer p returns nothing\n')
    s = once(s, '    if kind != 12 then\n        return\n    endif\n    if not Title_Registered[p] then\n',
             '    if kind != 12 then\n        if Title_Registered[p] then\n            call UI_Error(p)\n'
             '        endif\n        return\n    endif\n    if not Title_Registered[p] then\n')
    s = once(s, 'function Hero_Put takes unit u, real px, real py returns nothing\n',
             VOICE + 'function Hero_Put takes unit u, real px, real py returns nothing\n')
    s = once(s, '    if k < 0 or Hero_Icon[k] == 0 then\n        return\n    endif\n    set Hero_Locked[p] = true\n',
             '    if k < 0 or Hero_Icon[k] == 0 then\n        call UI_Error(p)\n        return\n    endif\n'
             '    set Hero_Locked[p] = true\n')
    s = once(s, '    if b < 0 or Boss_Icon[b] == 0 then\n        return\n    endif\n    set Boss_Picked[p] = true\n',
             '    if b < 0 or Boss_Icon[b] == 0 then\n        call UI_Error(p)\n        return\n    endif\n'
             '    set Boss_Picked[p] = true\n')
    s = once(s, '    if b < 0 or b > 39 or Boss_Icon[b] == 0 or Boss_Choice[p] == b then\n        return\n    endif\n',
             '    if b >= 0 and b <= 39 and Boss_Icon[b] == 0 then\n        call UI_Error(p)\n        return\n    endif\n'
             '    if b < 0 or b > 39 or Boss_Choice[p] == b then\n        return\n    endif\n')
    s = once(s, '''    if k < 0 or k > 39 or Hero_Choice[p] == k then
        return
    endif
    set Hero_Choice[p] = k
    call UI_Click(p)
    call Hero_Put(Hero_Glow[p], Hero_CellX(k), Hero_CellY(k))
    call Title_Show(Hero_Glow[p], true)
    call Hero_ShowPortrait(p)
''', '''    if k < 0 or k > 39 then
        return
    endif
    if Hero_Choice[p] == k then
        if Hero_Icon[k] == 0 then
            call UI_Error(p)
        endif
        return
    endif
    set Hero_Choice[p] = k
    if Hero_Icon[k] == 0 then
        call UI_Error(p)
        call Hero_Mute(p)
    else
        call UI_Click(p)
    endif
    call Hero_Put(Hero_Glow[p], Hero_CellX(k), Hero_CellY(k))
    call Title_Show(Hero_Glow[p], true)
    call Hero_ShowPortrait(p)
    if Hero_Icon[k] != 0 then
        call Hero_Say(p, Hero_VoicePick, 1.55)
    endif
''')
    s = once(s, 'function Hero_ClockTick takes nothing returns nothing\n',
             END + 'function Hero_ClockTick takes nothing returns nothing\n')
    s = once(s, '            call TimerStart(CreateTimer(), 0.6, false, function Boss_Start)\n        endif\n    endif\nendfunction\n',
             '            call Hero_SayEnd()\n            call TimerStart(CreateTimer(), 5, false, function Boss_Start)\n'
             '        endif\n    endif\nendfunction\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
