#!/usr/bin/env python3
"""v18h (15/11/2026), fase 4: unidades de las bolsas de oro, copias de 'dumi' (pie de 'hfoo' con Langosta, sin
colisión ni minimapa) con modelo del juego (ItemData.slk de 1.27b):
- 'nbg0' bolsa común: Objects\\InventoryItems\\PotofGold\\PotofGold.mdl a escala 1,2.
- 'nbg1' bolsa de élite: el mismo a 1,7.
- 'nbg2' bolsa del jefe: Objects\\InventoryItems\\TreasureChest\\treasurechest.mdl a 1,0.
Sólo cambia el w3u. Uso: objetos_v18h.py DIR_ENTRADA (w3u de v18g) DIR_SALIDA
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
BOLSAS = [('nbg0', 'Bolsa de oro', 'Objects\\InventoryItems\\PotofGold\\PotofGold.mdl', 1.2),
          ('nbg1', 'Bolsa de oro de élite', 'Objects\\InventoryItems\\PotofGold\\PotofGold.mdl', 1.7),
          ('nbg2', 'Cofre del jefe', 'Objects\\InventoryItems\\TreasureChest\\treasurechest.mdl', 1.0)]
b = (src / 'war3map.w3u').read_bytes()
version, tablas = parse(b)
assert encode(version, tablas) == b
usados = {new.decode() for _, new, _ in tablas[1]}
base, _, mods = next(r for r in tablas[1] if r[1] == b'dumi')
for rid, nombre, modelo, esc in BOLSAS:
    assert rid not in usados, rid
    m = [x for x in mods if x[0] not in (b'umdl', b'unam', b'usca')]
    m += [(b'umdl', 3, modelo.encode(), b'\0\0\0\0'), (b'unam', 3, nombre.encode('utf-8'), b'\0\0\0\0'),
          (b'usca', 1, struct.pack('<f', esc), b'\0\0\0\0')]
    tablas[1].append((base, rid.encode(), m))
(dst / 'war3map.w3u').write_bytes(encode(version, tablas))
print('w3u: bolsas', ', '.join(r for r, *_ in BOLSAS), '; personalizadas', len(tablas[1]))
