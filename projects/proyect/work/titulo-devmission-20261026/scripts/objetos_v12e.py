"""Objects for v12e (Dev Mission title, 30/10/2026): cell 0 is now the plain Tauren, cell 1 Cairne.

- DT3Q: the game's own ReplaceableTextures\\CommandButtons\\BTNTauren.blp (not imported), as DT2R in objetos_v9i.py;
- 'dca0': a copy of the portrait unit 'dta0' with the model UI\\Dialogue\\Portraits\\cairne.mdx;
- that model is added to war3map.imp. Fails if an id or path is already used.

Usage: objetos_v12e.py IN_W3B OUT_W3B IN_IMP OUT_IMP IN_W3U OUT_W3U
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

MODEL = 'UI\\Dialogue\\Portraits\\cairne.mdx'
GAME = ('DT3Q', 'ReplaceableTextures\\CommandButtons\\BTNTauren.blp', 'BTNTauren')

if __name__ == '__main__':
    w3b_modos.add([], [MODEL], sys.argv)
    version, tables = parse(Path(sys.argv[2]).read_bytes())
    rid, path, name = GAME
    template = next(r for r in tables[1] if r[1] == b'D000')
    assert rid.encode() not in {r[1] for r in tables[1]}
    mods = [(m, t, path.encode() if m == b'btxf' else name.encode() if m == b'bnam' else v, rid.encode())
            for m, t, v, _ in template[2]]
    tables[1].append((b'ATtc', rid.encode(), mods))
    Path(sys.argv[2]).write_bytes(encode(version, tables))

    src = Path(sys.argv[5]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    assert all(new != b'dca0' for t in tables for _, new, _ in t), 'dca0 exists'
    base, _, mods = next(r for r in tables[1] if r[1] == b'dta0')
    new = [(m, t, MODEL.encode() if m == b'umdl' else b'Dialogue portrait Cairne' if m == b'unam' else v, e)
           for m, t, v, e in mods]
    tables[1].append((base, b'dca0', new))
    Path(sys.argv[6]).write_bytes(encode(version, tables))
    print('ok', rid, 'dca0')
