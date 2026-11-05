"""Objects and imports of the boss select (Dev Mission title v9j, 29/10/2026).

- destructable textures (w3b_modos.add): DT2S/DT2T BossTitleL/R, DT2U BossLabel, DT2V/DT2W BossOrnL/R, DT30 BossName, DT31 BossNereus, DT32 BTNHydra;
- unit types for Dev Us Dimensional v0.76a's boss effects, each a copy of the UI system's dummy 'uidm' with only
  the model changed (Dev Us had them as 'h021' etc. on a footman-like base): 'ubs0' Ubershield Azure (the
  hexagonal sphere), 'ubs1' Soul Beam Blue, 'ubs2' Flamestrike Mystic II, 'ubs3' Electric Spark - Classic,
  'ubs4' neon_sprite100 (the cursor's frame); the models are imported under war3mapImported\\Boss*.mdx;
- imports: the BLPs above, the five models, the textures they name by path (two at the archive root, as Dev Us
  had them), the two sounds (pick: SecodIntoEfect.mp3, cursor: XC_LU_CURSOR_MOVES.mp3) and BossHitCell.mdx.
Fails if an id or path is already used.

Usage: objetos_boss.py IN_W3B OUT_W3B IN_IMP OUT_IMP IN_W3U OUT_W3U
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos
from w3b_titulo import parse, encode

TEXTURES = [('DT2S', 'BossTitleL'), ('DT2T', 'BossTitleR'), ('DT2U', 'BossLabel'), ('DT2V', 'BossOrnL'),
            ('DT2W', 'BossOrnR'), ('DT30', 'BossName'), ('DT31', 'BossNereus'), ('DT32', 'BTNHydra')]
MODELS = {'ubs0': 'BossShield', 'ubs1': 'BossSoulBeam', 'ubs2': 'BossFlamestrike', 'ubs3': 'BossSpark',
          'ubs4': 'BossNeon'}
DEVUS_MODELS = {'BossShield': 'Ubershield Azure', 'BossSoulBeam': 'Soul Beam Blue',
                'BossFlamestrike': 'Flamestrike Mystic II', 'BossSpark': 'Electric Spark - Classic',
                'BossNeon': 'neon_sprite100'}
MODEL_TEXTURES = ['AzureGlow4.blp', 'neon_7x7_sprite.blp'] + [f'war3mapImported\\{n}.blp' for n in (
    'AzureGlow4', 'dust3', 'elecsparks_bw_2x2', 'flaresimple01_bw', 'flaresimple02_bw', 'shockwave_bw', 'smoke_bw')]
SOUNDS = ['war3mapImported\\SecodIntoEfect.mp3', 'war3mapImported\\XC_LU_CURSOR_MOVES.mp3']
IMPORTS = ([f'war3mapImported\\{n}.blp' for _, n in TEXTURES] + [f'war3mapImported\\{m}.mdx' for m in MODELS.values()]
           + MODEL_TEXTURES + SOUNDS + ['war3mapImported\\BossHitCell.mdx'])

if __name__ == '__main__':
    w3b_modos.add(TEXTURES, IMPORTS, sys.argv)
    src = Path(sys.argv[5]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src
    used = {new for t in tables for _, new, _ in t}
    base, _, mods = next(r for r in tables[1] if r[1] == b'uidm')
    for rid, model in MODELS.items():
        assert rid.encode() not in used, rid
        path = f'war3mapImported\\{model}.mdx'.encode()
        new = [(mid, ty, path if mid == b'umdl' else v, end) for mid, ty, v, end in mods]
        tables[1].append((base, rid.encode(), new))
    Path(sys.argv[6]).write_bytes(encode(version, tables))
    print(json.dumps({'units': list(MODELS), 'imports': len(IMPORTS)}))
