"""Objects and imports for the armillary logo of the Dev Mission title (v9b, 28/10/2026).

The user's model (ModelEditor logo-armilar-v5-solo-modelo, Logo_Armilar_Nebula.mdx + 3 BLP under LogoArmilarV5\\)
is, like the intro, an XY plane facing +Z (logo contour at z -620, Birth 8 s, Stand invisible), so it goes on a
flying unit: 'uida' copies every field of 'uidm' and changes only the model, as 'uidi' (intro_objetos.py).
Imports get flag 13 (custom path). Fails if 'uida' or any path is already used.

Usage: armilar_objetos.py IN_W3U OUT_W3U IN_IMP OUT_IMP ARMILAR_DIR
"""
from pathlib import Path
import json, struct, sys
sys.path.insert(0, str(Path(__file__).parent))
from w3b_titulo import parse, encode

MODEL = 'LogoArmilarV5\\Logo_Armilar_Nebula.mdx'

if __name__ == '__main__':
    src_dir = Path(sys.argv[5])
    src = Path(sys.argv[1]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    assert all(new != b'uida' for t in tables for _, new, _ in t), 'uida exists'
    base, _, mods = next(r for r in tables[1] if r[1] == b'uidm')
    new = [(mid, ty, MODEL.encode() if mid == b'umdl' else v, end) for mid, ty, v, end in mods]
    assert sum(m[0] == b'umdl' for m in new) == 1
    tables[1].append((base, b'uida', new))
    Path(sys.argv[2]).write_bytes(encode(version, tables))

    imports = [MODEL] + sorted(f'LogoArmilarV5\\{p.name}' for p in (src_dir / 'LogoArmilarV5').glob('*.blp'))
    assert len(imports) == 4, imports
    imp = Path(sys.argv[3]).read_bytes()
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
    Path(sys.argv[4]).write_bytes(struct.pack('<II', 1, n + len(imports)) + imp[8:] + extra)
    print(json.dumps({'unit': 'uida', 'fields': len(new), 'imports': n + len(imports), 'added': len(imports)}))
