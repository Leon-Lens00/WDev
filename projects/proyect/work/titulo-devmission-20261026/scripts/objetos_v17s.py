"""v17s (14/11/2026): destructables de textura para los iconos de los cuadros (DC00-DC0G), copias de D000 como en
w3b_modos.py, con btxf apuntando a iconos del juego (war3.mpq / War3x.mpq, comprobados con wc3ctl extract): no hay
importaciones nuevas. Falla si un id ya existe.

Uso: objetos_v17s.py IN_W3B OUT_W3B
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

ICONOS = ['SeaTurtleGreen', 'BootsOfSpeed', 'MurlocMutant', 'MurgulTideWarrior', 'SteelMelee', 'SeaTurtleRed',
          'LobstrokkGreen', 'MurgulShadowCaster', 'LobstrokkRed', 'HealthStone', 'SeaWitch', 'CriticalStrike',
          'Curse', 'WarStomp', 'Evasion', 'ShockWave', 'ChestOfGold']

src = Path(sys.argv[1]).read_bytes()
version, tables = parse(src)
assert encode(version, tables) == src, 'round trip differs'
used = {new for _, new, _ in tables[1]}
template = next(r for r in tables[1] if r[1] == b'D000')
ids = []
for k, nombre in enumerate(ICONOS):
    new = ('DC0' + '0123456789ABCDEFG'[k]).encode()
    assert new not in used, new
    mods = []
    for mid, ty, v, _ in template[2]:
        if mid == b'btxf':
            v = f'ReplaceableTextures\\CommandButtons\\BTN{nombre}.blp'.encode()
        elif mid == b'bnam':
            v = f'Cuadro {nombre}'.encode()
        mods.append((mid, ty, v, new))
    tables[1].append((b'ATtc', new, mods))
    ids.append(new.decode())
Path(sys.argv[2]).write_bytes(encode(version, tables))
print(json.dumps({'destructables': ids, 'custom': len(tables[1])}))
