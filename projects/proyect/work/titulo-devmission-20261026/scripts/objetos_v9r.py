"""Objects and imports of the boss select v9r (Dev Mission title, 29/10/2026): destructable texture DT39
BossPickGlow (texturas_v9q.py) and its import (w3b_modos.add). Fails if an id or path is already used.

Usage: objetos_v9r.py IN_W3B OUT_W3B IN_IMP OUT_IMP
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos

TEXTURES = [('DT39', 'BossPickGlow')]

if __name__ == '__main__':
    w3b_modos.add(TEXTURES, ['war3mapImported\\BossPickGlow.blp'], sys.argv)
