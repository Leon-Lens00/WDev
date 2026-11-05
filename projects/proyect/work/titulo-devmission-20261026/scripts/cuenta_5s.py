"""Countdowns of 5 s for Start and for the mode choice (Dev Mission title v9d, 28/10/2026).

The user asked for a sample with 5 seconds to press Start and 5 to choose the mode instead of 20. Changes the
three places that set them: Title_Left in Title_Restart, Mode_Left once the mode pieces arrive, and the number
the clock shows while it comes down from above (Entry_Place).

Usage: cuenta_5s.py IN_J OUT_J
"""
from pathlib import Path
import sys

SECONDS = 5
REPLACE = [('    set Title_Left = 20\r\n', f'    set Title_Left = {SECONDS}\r\n'),
           ('        set Mode_Left = 20\r\n', f'        set Mode_Left = {SECONDS}\r\n'),
           ('    call Clock_Show(20, 960, Entry_PY(112', f'    call Clock_Show({SECONDS}, 960, Entry_PY(112')]

if __name__ == '__main__':
    j = open(sys.argv[1], encoding='latin-1', newline='').read()
    for old, new in REPLACE:
        assert j.count(old) == 1, old
        j = j.replace(old, new)
    open(sys.argv[2], 'w', encoding='latin-1', newline='').write(j)
    print('ok', len(REPLACE))
