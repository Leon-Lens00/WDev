"""Armillary logo v9 in place of v5 (Dev Mission title v9e, 28/10/2026).

The user sent ModelEditor logo-armilar-v9-solo-modelo: same 8 s Birth, peak at 5600 ms, plane z -620 and
2300 canvas as v5 (their timeline.json), so Panel_* timing and placement stay. Only 'uida''s model changes, to
LogoArmilarV9\\Logo_Armilar_Nebula.mdx, and war3map.imp swaps the 4 LogoArmilarV5 entries (MDX, Line, Orb,
Wire) for the 3 of v9 (no Wire). Removing the old files from the archive is left to the packaging step.

Usage: armilar_v9.py IN_W3U OUT_W3U IN_IMP OUT_IMP
"""
from pathlib import Path
import json, struct, sys
sys.path.insert(0, str(Path(__file__).parent))
from w3b_titulo import parse, encode

OLD = 'LogoArmilarV5\\Logo_Armilar_Nebula.mdx'
MODEL = 'LogoArmilarV9\\Logo_Armilar_Nebula.mdx'
NEW_IMPORTS = [MODEL, 'LogoArmilarV9\\Line.blp', 'LogoArmilarV9\\Orb.blp']

if __name__ == '__main__':
    src = Path(sys.argv[1]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    rows = [i for i, r in enumerate(tables[1]) if r[1] == b'uida']
    assert len(rows) == 1
    base, new, mods = tables[1][rows[0]]
    assert [v for mid, _, v, _ in mods if mid == b'umdl'] == [OLD.encode()]
    tables[1][rows[0]] = (base, new, [(mid, ty, MODEL.encode() if mid == b'umdl' else v, end)
                                      for mid, ty, v, end in mods])
    Path(sys.argv[2]).write_bytes(encode(version, tables))

    imp = Path(sys.argv[3]).read_bytes()
    iv, n = struct.unpack_from('<II', imp, 0)
    assert iv == 1
    i, entries = 8, []
    for _ in range(n):
        j = imp.index(b'\0', i + 1)
        entries.append((imp[i], imp[i + 1:j].decode('utf-8')))
        i = j + 1
    assert i == len(imp)
    removed = [p for _, p in entries if p.startswith('LogoArmilarV5\\')]
    assert len(removed) == 4, removed
    kept = [(f, p) for f, p in entries if not p.startswith('LogoArmilarV5\\')]
    assert not any(p in NEW_IMPORTS for _, p in kept)
    kept += [(13, p) for p in NEW_IMPORTS]
    body = b''.join(bytes([f]) + p.encode() + b'\0' for f, p in kept)
    Path(sys.argv[4]).write_bytes(struct.pack('<II', 1, len(kept)) + body)
    print(json.dumps({'removed': removed, 'added': NEW_IMPORTS, 'imports': len(kept)}))
