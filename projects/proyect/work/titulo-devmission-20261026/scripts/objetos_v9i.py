"""Destructable textures and imports for hero select v9i (Dev Mission title, 29/10/2026), as w3b_modos.add:
DT2O CellQ, DT2P CellFrame, DT2Q LockGlow (imported), DT2R the game's own Tauren Chieftain button
(ReplaceableTextures\\CommandButtons\\BTNHeroTaurenChieftain.blp, not imported); imports the three BLPs and
HeroHitLock.mdx (Lock in's hit zone, zona_clic.py). Fails if an id or path is already used.

Usage: objetos_v9i.py IN_W3B OUT_W3B IN_IMP OUT_IMP
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

TEXTURES = [('DT2O', 'CellQ'), ('DT2P', 'CellFrame'), ('DT2Q', 'LockGlow')]
IMPORTS = [f'war3mapImported\\{n}.blp' for _, n in TEXTURES] + ['war3mapImported\\HeroHitLock.mdx']
GAME = ('DT2R', 'ReplaceableTextures\\CommandButtons\\BTNHeroTaurenChieftain.blp', 'BTNHeroTaurenChieftain')

if __name__ == '__main__':
    w3b_modos.add(TEXTURES, IMPORTS, sys.argv)
    version, tables = parse(Path(sys.argv[2]).read_bytes())
    rid, path, name = GAME
    template = next(r for r in tables[1] if r[1] == b'D000')
    assert rid.encode() not in {r[1] for r in tables[1]}
    mods = [(m, t, path.encode() if m == b'btxf' else name.encode() if m == b'bnam' else v, rid.encode())
            for m, t, v, _ in template[2]]
    tables[1].append((b'ATtc', rid.encode(), mods))
    Path(sys.argv[2]).write_bytes(encode(version, tables))
    print('game texture', rid, path)
