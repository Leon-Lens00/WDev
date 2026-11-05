"""v11b: the sphere effect's sound (Boss_PickSnd) another 10 % lower, as the user asked: 46 to 41.
Usage: sonidos_v11b.py IN.j OUT.j
"""
import sys

src, dst = sys.argv[1], sys.argv[2]
j = open(src, encoding='latin-1', newline='').read()
old = '    call SetSoundVolume(Boss_PickSnd, 46)\r\n'
assert j.count(old) == 1
open(dst, 'w', encoding='latin-1', newline='').write(j.replace(old, old.replace('46', '41')))
