"""Objects and imports of the strategy board v9t (Dev Mission title, 29/10/2026): destructable textures DT3A-DT3H
(texturas_v9t.py) and the click zones StratHitCell.mdx / StratHitBoss.mdx (zona_clic.py at depth 398, nearer the eye
than the boss select's zones at 400, which stay). Fails if an id or path is already used.

Usage: objetos_v9t.py IN_W3B OUT_W3B IN_IMP OUT_IMP
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos

TEXTURES = [('DT3A', 'StratTitleL'), ('DT3B', 'StratTitleR'), ('DT3C', 'StratLabel'), ('DT3D', 'StratEnter'),
            ('DT3E', 'StratFrame'), ('DT3F', 'StratInfoL'), ('DT3G', 'StratInfoR'), ('DT3H', 'StratRock')]

if __name__ == '__main__':
    w3b_modos.add(TEXTURES, [f'war3mapImported\\{n}.blp' for _, n in TEXTURES]
                  + ['war3mapImported\\StratHitCell.mdx', 'war3mapImported\\StratHitBoss.mdx'], sys.argv)
