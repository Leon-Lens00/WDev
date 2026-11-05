"""Objects for v12q (Dev Mission, 31/10/2026): 'hbi2', the round counter icon, a copy of 'hbhr' with its own model.

Usage: objetos_v12q.py IN_W3B OUT_W3B IN_IMP OUT_IMP IN_W3U OUT_W3U
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

MODEL = 'UI\\HealthBarsHorizontal\\RondaIcono.mdx'
TEXTURE = 'UI\\HealthBarsHorizontal\\RondaIcono.blp'

if __name__ == '__main__':
    w3b_modos.add([], [MODEL, TEXTURE], sys.argv)
    src = Path(sys.argv[5]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    assert b'hbi2' not in {new for t in tables for _, new, _ in t}, 'id'
    base, _, mods = next(r for r in tables[1] if r[1] == b'hbhr')
    tables[1].append((base, b'hbi2', [(m, t, MODEL.encode() if m == b'umdl' else b'Round icon' if m == b'unam' else v, e)
                                      for m, t, v, e in mods]))
    Path(sys.argv[6]).write_bytes(encode(version, tables))
    print('ok')
