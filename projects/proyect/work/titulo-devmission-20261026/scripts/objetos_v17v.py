#!/usr/bin/env python3
"""v17v (14/11/2026): bonificaciones de la súper élite con habilidades de un solo nivel, una por bit.

v17u-prueba (registro lat\\v17u-super.txt): la vida máxima BAJÓ de 120 a 90 con 'Sp0L'. El nivel que se pone con
SetUnitAbilityLevel no suma su valor; al quitar la habilidad se resta el del nivel actual. Es lo mismo que ya
explicaba la vida de las élites ('ALh0'..'ALhA': +10·2^b al añadir, nivel 2 = 0 al quitar). Por eso las bonificaciones
que se suman al añadir pasan a habilidades de un nivel por bit, que se acumulan con distinto rawcode:
- 'SpM0' (AIat, Iatt 0): sólo marca de súper élite.
- 'SpD0'-'SpD7' daño (AIat, Iatt 2^b), 'SpA0'-'SpA6' armadura (AIde, Idef 2^b),
  'SpS0'-'SpS6' velocidad de ataque (AIsx, Isx1 2^b %), 'SpR0'-'SpR6' regeneración (Arel, Ihpr 2^b).
La vida usa las 'ALh*' del mapa. La velocidad de movimiento pasa a SetUnitMoveSpeed.
Evasión 'SpE0'-'SpE9' (AIev, Eev1 5-50 %) y robo de vida 'SpV0'-'SpV9' (AIva, Ivam 5-50 %): una de un nivel por tramo
de 5 %, porque no se sabe si se acumulan.
Además v17u-prueba se colgaba 1-1,5 s (hilo principal al 100 % en el rastreo) en cada súper élite y en la segunda
partida el juego se cerró en ese momento: lo nuevo en ese instante eran las habilidades de objeto de 100 niveles.
Ninguna habilidad nueva tiene ya más de un nivel y se quitan del w3a las 'Sp0*' de v17u.

Uso: objetos_v17v.py IN_W3A OUT_W3A
"""
from pathlib import Path
import json, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import parse_w3a, encode_w3a

Z = b'\0\0\0\0'


def texto(mid, level, s, data=0):
    return (mid, 3, level, data, s.encode('utf-8'), Z)


def entero(mid, level, n, data=0):
    return (mid, 0, level, data, struct.pack('<i', n), Z)


def unreal(mid, level, x, data=0):
    return (mid, 2, level, data, struct.pack('<f', x), Z)


HAB = [('SpM0', 'AIat', 'Súper élite: marca', 'Iatt', 0, entero)]
for b in range(8):
    HAB.append((f'SpD{b}', 'AIat', f'Súper élite: daño +{2 ** b}', 'Iatt', 2 ** b, entero))
for b in range(7):
    HAB.append((f'SpA{b}', 'AIde', f'Súper élite: armadura +{2 ** b}', 'Idef', 2 ** b, entero))
    HAB.append((f'SpS{b}', 'AIsx', f'Súper élite: velocidad de ataque +{2 ** b} %', 'Isx1', 2 ** b / 100, unreal))
    HAB.append((f'SpR{b}', 'Arel', f'Súper élite: regeneración +{2 ** b}', 'Ihpr', 2 ** b, entero))

for k in range(10):
    HAB.append((f'SpE{k}', 'AIev', f'Súper élite: evasión {5 * (k + 1)} %', 'Eev1', 0.05 * (k + 1), unreal))
    HAB.append((f'SpV{k}', 'AIva', f'Súper élite: robo de vida {5 * (k + 1)} %', 'Ivam', 0.05 * (k + 1), unreal))

src = Path(sys.argv[1]).read_bytes()
version, tablas = parse_w3a(src)
assert encode_w3a(version, tablas) == src, 'w3a: ida y vuelta distinta'
viejas = [r[1] for r in tablas[1] if r[1].startswith(b'Sp0')]
assert len(viejas) == 9, viejas
tablas[1] = [r for r in tablas[1] if not r[1].startswith(b'Sp0')]
usados = {r[1] for r in tablas[1]}
for new, base, nombre, campo, valor, tipo in HAB:
    assert new.encode() not in usados, new
    tablas[1].append((base.encode(), new.encode(),
                      [texto(b'anam', 0, nombre), entero(b'alev', 0, 1), tipo(campo.encode(), 1, valor, 1)]))
salida = encode_w3a(version, tablas)
assert encode_w3a(*parse_w3a(salida)) == salida
Path(sys.argv[2]).write_bytes(salida)
print(json.dumps({'habilidades': [h[0] for h in HAB]}))
