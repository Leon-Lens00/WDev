"""Objects for v12g (Dev Mission title, 30/10/2026): units of the player, one life bar, separate icons.

Adds the icon units 'hbi0' (Tauren) and 'hbi1' (Cairne), copies of 'hbhr' with their own model, and 'ocai': Cairne as a
normal unit, built on 'otau' with the look of 'Ocbh', so it is not a hero. Fails if an id is already used.

Usage: objetos_v12g.py IN_W3B OUT_W3B IN_IMP OUT_IMP IN_W3U OUT_W3U
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

ICONS = [(b'hbi0', 'HealthIconTauren'), (b'hbi1', 'HealthIconCairne')]
NONE = b'\0\0\0\0'
CAIRNE = [(b'umdl', 3, b'units\\orc\\HeroTaurenChieftainCIN\\HeroTaurenChieftainCIN.mdl', NONE),
          (b'uico', 3, b'ReplaceableTextures\\CommandButtons\\BTNHeroTaurenChieftain.blp', NONE),
          (b'unam', 3, b'Cairne', NONE),
          (b'usnd', 3, b'Cairne', NONE),
          (b'usca', 1, struct.pack('<f', 1.), NONE),
          (b'ussc', 1, struct.pack('<f', 2.), NONE)]


def model(name):
    return f'UI\\HealthBarsHorizontal\\{name}.mdx'


if __name__ == '__main__':
    w3b_modos.add([], [model(name) for _, name in ICONS], sys.argv)

    src = Path(sys.argv[5]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    used = {new for t in tables for _, new, _ in t}
    assert not used & {b'ocai', b'hbi0', b'hbi1'}, 'id'
    base, _, mods = next(r for r in tables[1] if r[1] == b'hbhr')
    for rid, name in ICONS:
        tables[1].append((base, rid, [(m, t, model(name).encode() if m == b'umdl' else
                                       f'Health icon {name}'.encode() if m == b'unam' else v, e)
                                      for m, t, v, e in mods]))
    tables[1].append((b'otau', b'ocai', CAIRNE))
    Path(sys.argv[6]).write_bytes(encode(version, tables))
    print('ok')
