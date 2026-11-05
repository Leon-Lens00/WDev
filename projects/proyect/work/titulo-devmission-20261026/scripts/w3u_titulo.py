"""Add the title screen's blended picture dummy to war3map.w3u (Dev Mission title, 26/10/2026).

'uidb' copies every field of the UI system's 'uidm' ('ewsp' based) and changes only the model to
war3mapImported\\TitleDummyBlend.mdl, a copy of UI\\dummy.mdl whose layer is FilterMode Blend instead of
Transparent (alpha test), so the rhombuses' glow and soft edges taken from the mockup keep their alpha. The
inventory and dialogue keep 'uidm'. Same file layout as war3map.w3b (no levels in unit data); the end marker
of unit fields is 0, as in 'uidm'. Fails if 'uidb' is already used.

Usage: w3u_titulo.py IN_W3U OUT_W3U
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).parent))
from w3b_titulo import parse, encode

MODEL = b'war3mapImported\\TitleDummyBlend.mdl'

if __name__ == '__main__':
    src = Path(sys.argv[1]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    assert all(new != b'uidb' for t in tables for _, new, _ in t), 'uidb exists'
    base, _, mods = next(r for r in tables[1] if r[1] == b'uidm')
    new = [(mid, ty, MODEL if mid == b'umdl' else v, end) for mid, ty, v, end in mods]
    assert sum(m[0] == b'umdl' for m in new) == 1
    tables[1].append((base, b'uidb', new))
    out = encode(version, tables)
    Path(sys.argv[2]).write_bytes(out)
    print(json.dumps({'added': 'uidb', 'base': base.decode(), 'fields': len(new), 'custom': len(tables[1]),
                      'bytes': len(out)}))
