#!/usr/bin/env python3
"""v17x (14/11/2026): objetos de BonusMod v3.3.1 (Earth-Fury, basado en weaaddar) y SetUnitMaxState para la súper élite.

v17w-prueba se cerró en el paso 4 de la precarga: las 'SpA*' (base AIde). BonusMod hace la armadura con AId1 y el
daño con AItg. Leon pasó /home/snz/Descargas/BonusMod.w3x (sólo lectura; sha256 87a192f5…). Este script:
- quita las 'SpD*', 'SpA*', 'SpS*', 'SpR*' de v17v (siguen 'SpM0', 'SpE*', 'SpV*');
- quita las '(A)'..'(I)' viejas del mapa (de D.O.N, sin código que las use y distintas de las de BonusMod);
- copia tal cual de BonusMod.w3x las '(A)'..'(I)' y 'Zx00'/'Zx01' (SetUnitMaxState).
Uso: objetos_v17x.py IN_W3A BONUSMOD_W3A OUT_W3A
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a

src = Path(sys.argv[1]).read_bytes()
version, tablas = parse_w3a(src)
assert encode_w3a(version, tablas) == src, 'w3a: ida y vuelta distinta'
_, bm = parse_w3a(Path(sys.argv[2]).read_bytes())
assert not bm[0], 'BonusMod: tabla original no vacía'
nuevas = [r for r in bm[1] if r[1][:1] == b'(' or r[1] in (b'Zx00', b'Zx01')]
assert len(nuevas) == len(bm[1]) == 109, len(nuevas)
quitar = lambda new: new[:3] in (b'SpD', b'SpA', b'SpS', b'SpR') or new[:1] == b'('
viejas = [r[1].decode('latin-1') for r in tablas[1] if quitar(r[1])]
assert sum(1 for v in viejas if v.startswith('Sp')) == 29, viejas
tablas[1] = [r for r in tablas[1] if not quitar(r[1])]
usados = {r[1] for t in tablas for r in t}
for r in nuevas:
    assert r[1] not in usados, r[1]
tablas[1] += nuevas
salida = encode_w3a(version, tablas)
assert encode_w3a(*parse_w3a(salida)) == salida
Path(sys.argv[3]).write_bytes(salida)
print(json.dumps({'quitadas': len(viejas), 'copiadas': len(nuevas)}))
