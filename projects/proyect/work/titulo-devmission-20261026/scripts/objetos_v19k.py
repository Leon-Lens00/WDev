#!/usr/bin/env python3
"""v19k (19/11/2026), Leon: "apliquemosles mejor hotkeys a los DON tomando de referencia la original y tambien ordenando
del mas fuerte al mas ligero, apliquemos al menu de mejoras tambien que permitira aprender esas habilidad
individualmente segun la seleccion".
- w3a: los puentes de los libros ALGk/ALFz/ALTr/ALNa (tecla V) llevan la tecla de la habilidad real en Battle Stadium
  D.O.N 1.8c (ahky de su w3a; Spirit Bomb, Power Up de Freezer, Finish Sign y Odama Rasengan van en T). Kyuubi Chakra
  Blast también es T en D.O.N, pero allí cambia con la forma; aquí comparte libro con Odama Rasengan y pasa a D.
  Botones del más fuerte al más ligero: fila de arriba de izquierda a derecha y luego la segunda (técnica definitiva y
  enfriamientos largos primero; transformaciones y Power Up al final).
- w3b: destructables de textura DK00..DK0M (copias de D000, como DC00..DC0J) con el icono de cada técnica, para sus
  cartas en las mejoras del héroe.
Uso: objetos_v19k.py DIR_ENTRADA (w3a y w3b de v19j) DIR_SALIDA
"""
from pathlib import Path
import json, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a
from w3b_titulo import parse, encode

# (puente, tecla), del más fuerte al más ligero, por héroe; el orden de esta lista es también el de las cartas 40-62.
ORDEN = [
    [('AGk3', 'R'), ('AGk5', 'T'), ('AGk2', 'W'), ('AGk1', 'Q'), ('AGk4', 'X')],
    [('AFz4', 'R'), ('AFz1', 'X'), ('AFz2', 'E'), ('AFz5', 'W'), ('AFz3', 'Q'), ('AFz6', 'T')],
    [('ATr5', 'R'), ('ATr6', 'T'), ('ATr3', 'E'), ('ATr2', 'W'), ('ATr4', 'Q'), ('ATr1', 'X')],
    [('ANa3', 'R'), ('ANa6', 'D'), ('ANa2', 'T'), ('ANa5', 'Q'), ('ANa4', 'E'), ('ANa1', 'X')],
]
src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(exist_ok=True)
I = lambda v: v.to_bytes(4, 'little')

b = (src / 'war3map.w3a').read_bytes()
va, ta = parse_w3a(b)
assert encode_w3a(va, ta) == b
filas = {r[1]: r for t in ta for r in t}
iconos = []
for heroe in ORDEN:
    for k, (pid, tecla) in enumerate(heroe):
        mods = filas[pid.encode()][2]
        hechos = set()
        for j, m in enumerate(mods):
            if m[0] == b'ahky':
                mods[j] = m[:4] + (tecla.encode(),) + m[5:]
            elif m[0] == b'abpx':
                mods[j] = m[:4] + (I(k % 4),) + m[5:]
            elif m[0] == b'abpy':
                mods[j] = m[:4] + (I(k // 4),) + m[5:]
            elif m[0] == b'atp1':
                v = m[4]
                assert v.endswith(b'|r)') and v[-6:-4] == b'00', v
                mods[j] = m[:4] + (v[:-4] + tecla.encode() + b'|r)',) + m[5:]
            elif m[0] == b'aart':
                iconos.append((pid, m[4]))
            else:
                continue
            hechos.add(m[0])
        assert hechos == {b'ahky', b'abpx', b'abpy', b'atp1', b'aart'}, (pid, hechos)
(dst / 'war3map.w3a').write_bytes(encode_w3a(va, ta))

b = (src / 'war3map.w3b').read_bytes()
version, tables = parse(b)
assert encode(version, tables) == b
used = {new for _, new, _ in tables[1]}
template = next(r for r in tables[1] if r[1] == b'D000')
ids = []
for k, (pid, ruta) in enumerate(iconos):
    new = ('DK0' + '0123456789ABCDEFGHIJKLM'[k]).encode()
    assert new not in used, new
    mods = []
    for mid, ty, v, _ in template[2]:
        if mid == b'btxf':
            v = ruta
        elif mid == b'bnam':
            v = b'Carta ' + pid.encode()
        mods.append((mid, ty, v, new))
    tables[1].append((b'ATtc', new, mods))
    ids.append((new.decode(), pid, ruta.decode()))
assert len(ids) == 23
(dst / 'war3map.w3b').write_bytes(encode(version, tables))
print(json.dumps(ids))
