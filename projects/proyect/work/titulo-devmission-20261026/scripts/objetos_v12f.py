"""Objects for v12f (Dev Mission title, 30/10/2026): a hero life panel for each character.

HealthHero.mdx draws the character icon from one fixed texture path (the Paladin). This script writes two copies
that only change that 260-byte path, and adds their imports and the units 'hbh0' (Tauren) and 'hbh1' (Cairne),
copies of 'hbhr'. Fails if an id or path is already used.

Usage: objetos_v12f.py IN_W3B OUT_W3B IN_IMP OUT_IMP IN_W3U OUT_W3U IN_MDX OUT_DIR
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

OLD = b'ReplaceableTextures\\CommandButtons\\BTNHeroPaladin.blp'
BARS = [(b'hbh0', 'HealthHeroTauren', 'ReplaceableTextures\\CommandButtons\\BTNTauren.blp'),
        (b'hbh1', 'HealthHeroCairne', 'ReplaceableTextures\\CommandButtons\\BTNHeroTaurenChieftain.blp')]


def model(name):
    return f'UI\\HealthBarsHorizontal\\{name}.mdx'


if __name__ == '__main__':
    src = Path(sys.argv[7]).read_bytes()
    assert src.count(OLD + b'\0') == 1, 'icon path'
    for _, name, path in BARS:
        i = src.index(OLD)
        out = bytearray(src)
        out[i:i + 260] = path.encode().ljust(260, b'\0')
        assert len(out) == len(src)
        Path(sys.argv[8], name + '.mdx').write_bytes(out)

    w3b_modos.add([], [model(name) for _, name, _ in BARS], sys.argv)

    src = Path(sys.argv[5]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    base, _, mods = next(r for r in tables[1] if r[1] == b'hbhr')
    for rid, name, _ in BARS:
        assert all(new != rid for t in tables for _, new, _ in t), rid
        tables[1].append((base, rid, [(m, t, model(name).encode() if m == b'umdl' else
                                       f'Health bar {name}'.encode() if m == b'unam' else v, e)
                                      for m, t, v, e in mods]))
    Path(sys.argv[6]).write_bytes(encode(version, tables))
    print('ok', [b[0] for b in BARS])
