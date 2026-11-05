"""Objects and imports of the strategy board v9u (Dev Mission title, 29/10/2026): the boss effects sheared for the
side spheres (mdx_cizalla.py at mockup-screen 330/1605, 425) as unit types 'ubt0'-'ubt7', copies of 'ubs0'-'ubs3'
with only the model changed (even = left, odd = right), plus the single information panel texture DT3I StratInfo.
Fails if an id or path is already used.

Usage: objetos_v9u.py IN_W3B OUT_W3B IN_IMP OUT_IMP IN_W3U OUT_W3U
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

BASES = ['ubs0', 'ubs1', 'ubs2', 'ubs3']
MODELS = ['BossShield', 'BossSoulBeam', 'BossFlamestrike', 'BossSpark']
UNITS = {f'ubt{2 * k + s}': (BASES[k], f'{MODELS[k]}{"LR"[s]}') for k in range(4) for s in range(2)}
TEXTURES = [('DT3I', 'StratInfo')]

if __name__ == '__main__':
    w3b_modos.add(TEXTURES, [f'war3mapImported\\{n}.blp' for _, n in TEXTURES]
                  + [f'war3mapImported\\{m}.mdx' for _, m in UNITS.values()], sys.argv)
    src = Path(sys.argv[5]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src
    used = {new for t in tables for _, new, _ in t}
    for rid, (base_id, model) in UNITS.items():
        assert rid.encode() not in used, rid
        base, _, mods = next(r for r in tables[1] if r[1] == base_id.encode())
        path = f'war3mapImported\\{model}.mdx'.encode()
        tables[1].append((base, rid.encode(), [(mid, ty, path if mid == b'umdl' else v, end) for mid, ty, v, end in mods]))
    Path(sys.argv[6]).write_bytes(encode(version, tables))
    print(json.dumps({'units': UNITS, 'textures': TEXTURES}))
