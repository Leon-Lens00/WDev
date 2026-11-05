"""Objects and imports of the boss select v9q (Dev Mission title, 29/10/2026): destructable texture DT38 BossPick
(w3b_modos.add); imports BossPick.blp, the pick button's hit quad BossHitPick.mdx and Zap2x4.blp, the lightning
texture of Electric Spark - Classic (BossSpark.mdx) that the earlier versions did not import (Dev Us has it as
war3mapImported\\zap2x4.blp). Fails if an id or path is already used.

Usage: objetos_v9q.py IN_W3B OUT_W3B IN_IMP OUT_IMP
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos

TEXTURES = [('DT38', 'BossPick')]

if __name__ == '__main__':
    w3b_modos.add(TEXTURES, ['war3mapImported\\BossPick.blp', 'war3mapImported\\BossHitPick.mdx',
                             'war3mapImported\\Zap2x4.blp'], sys.argv)
