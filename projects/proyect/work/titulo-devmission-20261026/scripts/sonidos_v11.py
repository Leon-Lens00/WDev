"""v11: the pre-select takes the sound of clicking an ability (Dev Mission title, 30/10/2026). The user's choice,
after hearing v10v: UISounds.slk's InterfaceClick, MouseClick1.wav at volume 127, instead of MouseOver1.wav. Also the
sphere effect's sound (SecodIntoEfect, the only one left: the models' SND events are silenced) 35 % lower: 70 to 46.
Usage: sonidos_v11.py IN.j OUT.j
"""
import sys

src, dst = sys.argv[1], sys.argv[2]
j = open(src, encoding='latin-1', newline='').read()


def rep(old, new):
    global j
    old, new = old.replace('\n', '\r\n'), new.replace('\n', '\r\n')
    assert j.count(old) == 1, old
    j = j.replace(old, new)


rep('''CreateSound("Sound\\\\Interface\\\\MouseOver1.wav", false''', '''CreateSound("Sound\\\\Interface\\\\MouseClick1.wav", false''')
rep('''    call SetSoundDuration(UI_OverSnd, 202)
''', '''    call SetSoundDuration(UI_OverSnd, 239)
''')
rep('''    call SetSoundVolume(Boss_PickSnd, 70)
''', '''    call SetSoundVolume(Boss_PickSnd, 46)
''')
open(dst, 'w', encoding='latin-1', newline='').write(j)
