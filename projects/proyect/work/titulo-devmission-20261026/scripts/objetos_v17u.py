#!/usr/bin/env python3
"""v17u (14/11/2026): objetos de la súper élite (fase 2 del plan devmission-mejoras-darkmoon.md).

Habilidades de objeto con niveles (campos comprobados en AbilityMetaData.slk de 1.27b, classic-assets):
- 'Sp0L' (AIlf, Ilif): truco de vida máxima. Nivel 1 = 0, nivel k + 2 = 2^k (k 0..13). Se añade, se sube de nivel y
  se quita: la vida extra se queda (sólo se resta la del nivel 1).
- 'Sp0M' (AIat, Iatt): daño extra del multiplicador, nivel L = +L (60 niveles). Sirve también de marca de súper élite.
- Mejoras de estadística, 100 niveles cada una:
  'Sp0D' daño (AIat, +2·L), 'Sp0A' armadura (AIde, Idef +L), 'Sp0V' robo de vida (AIva, Ivam L %),
  'Sp0S' velocidad de ataque (AIsx, Isx1 L %), 'Sp0E' evasión (AIev, Eev1 L %), 'Sp0R' regeneración (Arel, Ihpr +L),
  'Sp0O' velocidad de movimiento (AIms, Imvb +L).
Iconos de las tarjetas: destructables DE00-DE0D (copias de D000 como en objetos_v17s.py) con BTN del juego,
comprobados con wc3ctl extract en war3.mpq / War3x.mpq. Falla si un id ya existe.

Uso: objetos_v17u.py IN_W3A OUT_W3A IN_W3B OUT_W3B
"""
from pathlib import Path
import json, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a
from w3b_titulo import parse, encode

Z = b'\0\0\0\0'


def texto(mid, level, s, data=0):
    return (mid, 3, level, data, s.encode('utf-8'), Z)


def entero(mid, level, n, data=0):
    return (mid, 0, level, data, struct.pack('<i', n), Z)


def unreal(mid, level, x, data=0):
    return (mid, 2, level, data, struct.pack('<f', x), Z)


# (nuevo, base, nombre, campo, niveles, valor(L), tipo)
HAB = [
    ('Sp0L', 'AIlf', 'Súper élite: vida', 'Ilif', 15, lambda L: 0 if L == 1 else 2 ** (L - 2), entero),
    ('Sp0M', 'AIat', 'Súper élite: daño del multiplicador', 'Iatt', 60, lambda L: L, entero),
    ('Sp0D', 'AIat', 'Súper élite: daño', 'Iatt', 100, lambda L: 2 * L, entero),
    ('Sp0A', 'AIde', 'Súper élite: armadura', 'Idef', 100, lambda L: L, entero),
    ('Sp0V', 'AIva', 'Súper élite: robo de vida', 'Ivam', 100, lambda L: L / 100, unreal),
    ('Sp0S', 'AIsx', 'Súper élite: velocidad de ataque', 'Isx1', 100, lambda L: L / 100, unreal),
    ('Sp0E', 'AIev', 'Súper élite: evasión', 'Eev1', 100, lambda L: L / 100, unreal),
    ('Sp0R', 'Arel', 'Súper élite: regeneración', 'Ihpr', 100, lambda L: L, entero),
    ('Sp0O', 'AIms', 'Súper élite: velocidad de movimiento', 'Imvb', 100, lambda L: L, entero),
]

ICONOS = ['ClawsOfAttack', 'HumanArmorUpTwo', 'VampiricAura', 'Glove', 'Evasion', 'Regenerate', 'BootsOfSpeed',
          'Bash', 'CriticalStrike', 'HardenedSkin', 'ThornShield', 'CleavingAttack', 'OrbOfFrost', 'SlowPoison']

a_in, a_out, b_in, b_out = sys.argv[1:5]
src = Path(a_in).read_bytes()
version, tablas = parse_w3a(src)
assert encode_w3a(version, tablas) == src, 'w3a: ida y vuelta distinta'
usados = {r[1] for r in tablas[1]}
for new, base, nombre, campo, niveles, valor, tipo in HAB:
    assert new.encode() not in usados, new
    mods = [texto(b'anam', 0, nombre), entero(b'alev', 0, niveles)]
    for L in range(1, niveles + 1):
        mods.append(tipo(campo.encode(), L, valor(L), 1))
    tablas[1].append((base.encode(), new.encode(), mods))
salida = encode_w3a(version, tablas)
assert encode_w3a(*parse_w3a(salida)) == salida
Path(a_out).write_bytes(salida)

src = Path(b_in).read_bytes()
version, tables = parse(src)
assert encode(version, tables) == src, 'w3b: ida y vuelta distinta'
used = {new for _, new, _ in tables[1]}
template = next(r for r in tables[1] if r[1] == b'D000')
ids = []
for k, nombre in enumerate(ICONOS):
    new = ('DE0' + '0123456789ABCD'[k]).encode()
    assert new not in used, new
    mods = []
    for mid, ty, v, _ in template[2]:
        if mid == b'btxf':
            v = f'ReplaceableTextures\\CommandButtons\\BTN{nombre}.blp'.encode()
        elif mid == b'bnam':
            v = f'Super {nombre}'.encode()
        mods.append((mid, ty, v, new))
    tables[1].append((b'ATtc', new, mods))
    ids.append(new.decode())
Path(b_out).write_bytes(encode(version, tables))
print(json.dumps({'habilidades': [h[0] for h in HAB], 'destructables': ids}))
