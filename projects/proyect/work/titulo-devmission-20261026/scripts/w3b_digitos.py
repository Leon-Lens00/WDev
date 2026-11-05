"""Add the countdown digits' texture destructables (DT1D-DT26, ModeDigit0-9) to war3map.w3b and their imports
to war3map.imp (Dev Mission title v8f, 28/10/2026), as w3b_modos.py does for the mode screen's pieces.

Usage: w3b_digitos.py IN_W3B OUT_W3B IN_IMP OUT_IMP
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_modos import add

TEXTURES = [('DT' + c, f'ModeDigit{n}') for n, c in enumerate(['1D', '1E', '1F', '20', '21', '22', '23', '24', '25', '26'])]
IMPORTS = [f'war3mapImported\\{n}.blp' for _, n in TEXTURES]

if __name__ == '__main__':
    add(TEXTURES, IMPORTS, sys.argv)
