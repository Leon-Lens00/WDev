"""v18m (15/11/2026), fase 7: iconos de la pantalla de inicio de la tienda, destructables de textura DC0H-DC0J,
copias de D000 como DC00-DC0G (objetos_v17s.py), con btxf en iconos del juego comprobados con wc3ctl extract:
DwarvenLongRifle (war3.mpq) para Armas, UnholyFrenzy (war3.mpq) para Mutación Evo, SpellBookBLS (War3x.mpq) para
Habilidades. Sin importaciones nuevas. Falla si un id ya existe.

Uso: objetos_v18m.py IN_W3B OUT_W3B
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

ICONOS = [('DC0H', 'DwarvenLongRifle'), ('DC0I', 'UnholyFrenzy'), ('DC0J', 'SpellBookBLS')]

src = Path(sys.argv[1]).read_bytes()
version, tables = parse(src)
assert encode(version, tables) == src, 'round trip differs'
used = {new for _, new, _ in tables[1]}
template = next(r for r in tables[1] if r[1] == b'D000')
for rid, nombre in ICONOS:
    new = rid.encode()
    assert new not in used, new
    mods = []
    for mid, ty, v, _ in template[2]:
        if mid == b'btxf':
            v = f'ReplaceableTextures\\CommandButtons\\BTN{nombre}.blp'.encode()
        elif mid == b'bnam':
            v = f'Cuadro {nombre}'.encode()
        mods.append((mid, ty, v, new))
    tables[1].append((b'ATtc', new, mods))
out = encode(version, tables)
assert encode(*parse(out)) == out
Path(sys.argv[2]).write_bytes(out)
print(json.dumps({'destructables': [r for r, _ in ICONOS], 'custom': len(tables[1])}))
