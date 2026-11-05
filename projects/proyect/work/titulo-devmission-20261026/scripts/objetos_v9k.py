"""Objects and imports of the hero/boss select v9k (Dev Mission title, 29/10/2026): destructable textures DT33
CellHi, DT34/DT35 HeroTitleL/R, DT36/DT37 HeroPanelT/B (w3b_modos.add). Fails if an id or path is already used.

Usage: objetos_v9k.py IN_W3B OUT_W3B IN_IMP OUT_IMP
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos

TEXTURES = [('DT33', 'CellHi'), ('DT34', 'HeroTitleL'), ('DT35', 'HeroTitleR'), ('DT36', 'HeroPanelT'),
            ('DT37', 'HeroPanelB')]

if __name__ == '__main__':
    w3b_modos.add(TEXTURES, [f'war3mapImported\\{n}.blp' for _, n in TEXTURES], sys.argv)
