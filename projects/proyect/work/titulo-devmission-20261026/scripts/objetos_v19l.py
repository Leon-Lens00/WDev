#!/usr/bin/env python3
"""v19l (19/11/2026): iconos de cartas nuevas de las mejoras del héroe (sólo war3map.w3b).
- DL00..DL0E: técnicas de Tauren (Bombardeo, Rugido, Embestida, Garra, Tótem arrojado, Lanzar roca, Disparo
  encantado) y Cairne (Estampida, Marca, Grieta, Tótem del trueno, Espíritu, Lanza, Espíritus guardianes, Réplica),
  con el icono (aart) de su habilidad en el w3a; el orden es el de las cartas 63-77 (v19l.py).
- DM00..DM07: malditas Sed de sangre, Codicia, Pacto mutante, Ruleta y economía Reembolso, Imán, Interés, Bolsa doble.
Todas son copias de D000 (como DC00..DC0J y DK00..DK0M) con otra textura.
Uso: objetos_v19l.py DIR_ENTRADA (w3a y w3b de v19k) DIR_SALIDA
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a
from w3b_titulo import parse, encode

ARTE = {'ATbP': b'ReplaceableTextures\\CommandButtons\\BTNSearingArrows.blp'}
TECNICAS = ['ATb4', 'ATb6', 'ATb1', 'ATb5', 'ATb2', 'ATb3', 'ATbP',
            'ACb4', 'ACb6', 'ACb1', 'ACb5', 'ACb3', 'ACb2', 'ACbQ', 'ACbP']
CARTAS = [('Sed de sangre', 'BTNVampiricAura'), ('Codicia', 'BTNPillage'), ('Pacto mutante', 'BTNPlagueCloud'),
          ('Ruleta', 'BTNSacrificialSkull'), ('Reembolso', 'BTNMerchant'), ('Iman', 'BTNMonsterLure'),
          ('Interes', 'BTNGoldMine'), ('Bolsa doble', 'BTNGoldRing')]
src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)

va, ta = parse_w3a((src / 'war3map.w3a').read_bytes())
arte = {}
for t in ta:
    for _, rid, mods in t:
        for m in mods:
            if m[0] == b'aart':
                arte[rid.decode()] = m[4]
b = (src / 'war3map.w3b').read_bytes()
version, tables = parse(b)
assert encode(version, tables) == b
used = {r[1] for t in tables for r in t}
template = next(r for r in tables[1] if r[1] == b'D000')
lista = [('DL0' + '0123456789ABCDE'[k], 'Carta ' + pid, ARTE.get(pid, arte[pid])) for k, pid in enumerate(TECNICAS)]
lista += [('DM0%d' % k, 'Carta ' + nom, ('ReplaceableTextures\\CommandButtons\\%s.blp' % btn).encode())
          for k, (nom, btn) in enumerate(CARTAS)]
for new, nom, ruta in lista:
    new = new.encode()
    assert new not in used and ruta.lower().endswith(b'.blp'), (new, ruta)
    mods = []
    for mid, ty, v, _ in template[2]:
        if mid == b'btxf':
            v = ruta
        elif mid == b'bnam':
            v = nom.encode()
        mods.append((mid, ty, v, new))
    tables[1].append((b'ATtc', new, mods))
assert len(lista) == 23
(dst / 'war3map.w3b').write_bytes(encode(version, tables))
print(json.dumps([(a, c.decode()) for a, _, c in lista]))
