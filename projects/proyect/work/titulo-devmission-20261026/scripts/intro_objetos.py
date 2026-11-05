"""Objects and imports for the Dev Mission intro (v9, 28/10/2026).

The user's intro model (ModelEditor intro-w-nebula-v8-fade, Intro_W_Nebula.mdx + 44 BLP under
IntroWNebulaV8Fade\\) is a flat XY plane facing +Z with an opaque backdrop 100 below its origin, so it goes on a
flying unit, as the title's nebula background ('uidn', w3u_fondo.py): 'uidi' copies every field of 'uidm' and
changes only the model. The song is imported as war3mapImported\\IntroCancion.mp3. Imports get flag 13
(custom path) like the other entries. Fails if 'uidi' or any path is already used.

Usage: intro_objetos.py IN_W3U OUT_W3U IN_IMP OUT_IMP INTRO_DIR
"""
from pathlib import Path
import json, struct, sys
sys.path.insert(0, str(Path(__file__).parent))
from w3b_titulo import parse, encode

MODEL = 'IntroWNebulaV8Fade\\Intro_W_Nebula.mdx'
SONG = 'war3mapImported\\IntroCancion.mp3'

if __name__ == '__main__':
    intro = Path(sys.argv[5])
    src = Path(sys.argv[1]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    assert all(new != b'uidi' for t in tables for _, new, _ in t), 'uidi exists'
    base, _, mods = next(r for r in tables[1] if r[1] == b'uidm')
    new = [(mid, ty, MODEL.encode() if mid == b'umdl' else v, end) for mid, ty, v, end in mods]
    assert sum(m[0] == b'umdl' for m in new) == 1
    tables[1].append((base, b'uidi', new))
    Path(sys.argv[2]).write_bytes(encode(version, tables))

    imports = [MODEL] + sorted(f'IntroWNebulaV8Fade\\{p.name}' for p in (intro / 'IntroWNebulaV8Fade').glob('*.blp')) + [SONG]
    assert len(imports) == 46, len(imports)
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
    print(json.dumps({'unit': 'uidi', 'fields': len(new), 'imports': n + len(imports), 'added': len(imports)}))
