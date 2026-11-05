"""Add the title screen's texture destructables to war3map.w3b (Dev Mission title, 26/10/2026).

The UI system changes a dummy's texture with War Club on a destructable whose replaceable texture field
(btxf) is the wanted image (UserInterface.ApplySkin). The existing ones (D000...) are 'ATtc' copies with a
fixed set of fields; the new ones copy D000's fields and change only btxf and bnam. The 4-byte end marker of
each field is the object's id, as in D000. Fails if any new id is already used.

Usage: w3b_titulo.py IN_W3B OUT_W3B
"""
from pathlib import Path
import json, struct, sys

TEXTURES = [('DT00', 'TitleLogo'), ('DT01', 'TitleStart'), ('DT02', 'TitleStartHover'), ('DT03', 'TitleGemGrey')]
TEXTURES += [('DT%02X' % (4 + n), f'TitleGem{n + 1}') for n in range(8)]


def parse(b):
    i, tables = 4, []
    for _ in range(2):
        n = struct.unpack_from('<I', b, i)[0]; i += 4
        rows = []
        for _ in range(n):
            base, new = b[i:i + 4], b[i + 4:i + 8]; i += 8
            m = struct.unpack_from('<I', b, i)[0]; i += 4
            mods = []
            for _ in range(m):
                mid, ty = b[i:i + 4], struct.unpack_from('<I', b, i + 4)[0]; i += 8
                if ty == 3:
                    j = b.index(b'\0', i); v = b[i:j]; i = j + 1
                else:
                    v = b[i:i + 4]; i += 4
                mods.append((mid, ty, v, b[i:i + 4])); i += 4
            rows.append((base, new, mods))
        tables.append(rows)
    assert i == len(b), (i, len(b))
    return struct.unpack_from('<I', b, 0)[0], tables


def encode(version, tables):
    out = [struct.pack('<I', version)]
    for rows in tables:
        out.append(struct.pack('<I', len(rows)))
        for base, new, mods in rows:
            out.append(base + new + struct.pack('<I', len(mods)))
            for mid, ty, v, end in mods:
                out.append(mid + struct.pack('<I', ty) + (v + b'\0' if ty == 3 else v) + end)
    return b''.join(out)


if __name__ == '__main__':
    src = Path(sys.argv[1]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    used = {new for _, new, _ in tables[1]}
    template = next(r for r in tables[1] if r[1] == b'D000')
    for rid, name in TEXTURES:
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
    Path(sys.argv[2]).write_bytes(out)
    print(json.dumps({'added': [f'{r} war3mapImported\\{n}.blp' for r, n in TEXTURES], 'custom': len(tables[1]),
                      'bytes': len(out)}, indent=1))
