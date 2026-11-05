"""Add the mode select screen's texture destructables to war3map.w3b and its imports to war3map.imp (Dev Mission
title v8, 27/10/2026). Destructables as in w3b_titulo.py ('ATtc' copies of D000 with btxf and bnam changed);
imports get flag 13 (custom path) like the other war3mapImported entries. Fails if an id or path is already used.

Usage: w3b_modos.py IN_W3B OUT_W3B IN_IMP OUT_IMP
"""
from pathlib import Path
import json, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

TEXTURES = [('DT0C', 'ModeLogo'), ('DT0D', 'ModeTitle'), ('DT0E', 'ModeBoxActive'), ('DT0F', 'ModeBoxLocked'),
            ('DT10', 'ModeLock'), ('DT11', 'ModeName'), ('DT12', 'ModeDesc'), ('DT13', 'ModeUnknown'),
            ('DT14', 'ModeGemOff')]
TEXTURES += [(f'DT1{"56789ABC"[n]}', f'ModeGem{n + 1}') for n in range(8)]
IMPORTS = [f'war3mapImported\\{n}.blp' for _, n in TEXTURES] + ['war3mapImported\\ModeHitBox.mdx']


def add(textures, imports, argv):
    """Destructables for textures, imports for imports; argv = IN_W3B OUT_W3B IN_IMP OUT_IMP at 1-4."""
    src = Path(argv[1]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    used = {new for _, new, _ in tables[1]}
    template = next(r for r in tables[1] if r[1] == b'D000')
    for rid, name in textures:
        new = rid.encode()
        assert new not in used, rid
        mods = []
        for mid, ty, v, _ in template[2]:
            if mid == b'btxf':
                v = f'war3mapImported\\{name}.blp'.encode()
            elif mid == b'bnam':
                v = name.encode()
            mods.append((mid, ty, v, new))
        tables[1].append((b'ATtc', new, mods))
    out = encode(version, tables)
    Path(argv[2]).write_bytes(out)

    imp = Path(argv[3]).read_bytes()
    iv, n = struct.unpack_from('<II', imp, 0)
    assert iv == 1
    i, names = 8, []
    for _ in range(n):
        j = imp.index(b'\0', i + 1)
        names.append(imp[i + 1:j].decode('utf-8'))
        i = j + 1
    assert i == len(imp)
    for p in imports:
        assert p not in names, p
    extra = b''.join(bytes([13]) + p.encode() + b'\0' for p in imports)
    Path(argv[4]).write_bytes(struct.pack('<II', 1, n + len(imports)) + imp[8:] + extra)
    print(json.dumps({'destructables': [r for r, _ in textures], 'custom': len(tables[1]), 'imports': n + len(imports)}))


if __name__ == '__main__':
    add(TEXTURES, IMPORTS, sys.argv)
