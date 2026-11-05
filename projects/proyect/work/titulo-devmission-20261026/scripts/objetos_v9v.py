"""Objects and imports of v9v (Dev Mission title, 29/10/2026): the single strategy title texture DT3J StratTitle.
Fails if an id or path is already used.

Usage: objetos_v9v.py IN_W3B OUT_W3B IN_IMP OUT_IMP
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos

TEXTURES = [('DT3J', 'StratTitle')]

if __name__ == '__main__':
    w3b_modos.add(TEXTURES, [f'war3mapImported\\{n}.blp' for _, n in TEXTURES], sys.argv)
