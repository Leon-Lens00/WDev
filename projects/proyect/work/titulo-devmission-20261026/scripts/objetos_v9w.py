"""Objects and imports of the presentation v9w (Dev Mission title, 29/10/2026).

- destructable textures (w3b_modos.add): DT3K PresAro, DT3L PresTri, DT3M PresW (texturas_v9w.py);
- unit types, copies of the UI dummy 'uidm' with only the model changed: 'ubt8' the game's Hydra turned to the
  camera (mdx_rotar.py, war3mapImported\\PresHydra.mdx, textures from the game), 'ubt9' the user's radial nebula
  V3 (NebulaRadialV3), 'ubta' / 'ubtb' the user's converging glow, horizontal / vertical (ConvergeGlowV1);
- imports: the BLPs above, the four models, the nebula's 7 and the glow's 4 textures at the paths the models name,
  and the theme war3mapImported\\PresTema.mp3.
Fails if an id or path is already used.

Usage: objetos_v9w.py IN_W3B OUT_W3B IN_IMP OUT_IMP IN_W3U OUT_W3U
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

TEXTURES = [('DT3K', 'PresAro'), ('DT3L', 'PresTri'), ('DT3M', 'PresW')]
UNITS = {'ubt8': 'war3mapImported\\PresHydra.mdx', 'ubt9': 'war3mapImported\\Nebula_Radial_PlusZ.mdx',
         'ubta': 'war3mapImported\\Glow_Horizontal.mdx', 'ubtb': 'war3mapImported\\Glow_Vertical.mdx'}
NEBULA = [f'NebulaRadialV3\\{n}.blp' for n in ('Dust', 'Gas', 'Halo', 'Light', 'Solid', 'Streak', 'Wisp')]
GLOW = [f'ConvergeGlowV1\\{n}.blp' for n in ('Band', 'Line', 'Rim', 'Soft')]
IMPORTS = ([f'war3mapImported\\{n}.blp' for _, n in TEXTURES] + list(UNITS.values()) + NEBULA + GLOW
           + ['war3mapImported\\PresTema.mp3'])

if __name__ == '__main__':
    w3b_modos.add(TEXTURES, IMPORTS, sys.argv)
    src = Path(sys.argv[5]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src
    used = {new for t in tables for _, new, _ in t}
    base, _, mods = next(r for r in tables[1] if r[1] == b'uidm')
    for rid, model in UNITS.items():
        assert rid.encode() not in used, rid
        tables[1].append((base, rid.encode(), [(mid, ty, model.encode() if mid == b'umdl' else v, end)
                                               for mid, ty, v, end in mods]))
    Path(sys.argv[6]).write_bytes(encode(version, tables))
    print(json.dumps({'units': UNITS, 'imports': len(IMPORTS)}))
