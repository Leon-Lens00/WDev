"""Objects and imports of the hero select screen (Dev Mission title v9f, 29/10/2026).

- Destructables DT27-DT2E (HeroBg0-7), DT2F-DT2M (HeroGlow1-8) and DT2N (HeroColon), 'ATtc' copies of D000 with
  btxf and bnam changed, as w3b_modos.py; their BLP under war3mapImported\\.
- 'uidg': a copy of 'uidm' (as 'uidb', w3u_titulo.py) whose model is TitleDummyAdd.mdl, TitleDummyBlend.mdl with
  FilterMode Additive, so the players' glows add light over the chosen cell.
- war3mapImported\\HeroHitCell.mdx, the cells' click zone (zona_clic.py).
Fails if any id or path is already used.

Usage: objetos_heroe.py IN_W3B OUT_W3B IN_W3U OUT_W3U IN_IMP OUT_IMP
"""
from pathlib import Path
import json, struct, sys
sys.path.insert(0, str(Path(__file__).parent))
from w3b_titulo import parse, encode
from w3b_modos import add

IDS = '789ABCDEFGHIJKLMN'
NAMES = [f'HeroBg{n}' for n in range(8)] + [f'HeroGlow{n}' for n in range(1, 9)] + ['HeroColon']
TEXTURES = [(f'DT2{c}', n) for c, n in zip(IDS, NAMES)]
MODEL = 'war3mapImported\\TitleDummyAdd.mdl'
IMPORTS = [f'war3mapImported\\{n}.blp' for n in NAMES] + [MODEL, 'war3mapImported\\HeroHitCell.mdx']

if __name__ == '__main__':
    w3b_in, w3b_out, w3u_in, w3u_out, imp_in, imp_out = sys.argv[1:7]
    add(TEXTURES, IMPORTS, [None, w3b_in, w3b_out, imp_in, imp_out])
    src = Path(w3u_in).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    assert all(new != b'uidg' for t in tables for _, new, _ in t), 'uidg exists'
    base, _, mods = next(r for r in tables[1] if r[1] == b'uidm')
    new = [(mid, ty, MODEL.encode() if mid == b'umdl' else v, end) for mid, ty, v, end in mods]
    assert sum(m[0] == b'umdl' for m in new) == 1
    tables[1].append((base, b'uidg', new))
    Path(w3u_out).write_bytes(encode(version, tables))
    print(json.dumps({'unit': 'uidg', 'textures': TEXTURES[0][0] + '-' + TEXTURES[-1][0]}))
