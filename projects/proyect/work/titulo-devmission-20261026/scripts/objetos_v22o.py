#!/usr/bin/env python3
"""v22o (23/11/2026): técnicas del Tauren y de Cairne sin maná, con recargas largas y textos sin cifras de daño.

Como Goku en v21m: Q 20 s, W 30 s, E 30 s, R 90 s y maná 0. El daño ya no es fijo: lo marca el tier de cada técnica
(cartas "Subir tier"), y el texto lo dice. La Estampida pasa a ser circular (v22o.py). Espíritus guardianes (pasiva)
pierde la cifra de 250.
Uso: objetos_v22o.py ENTRADA.w3a SALIDA.w3a   (ENTRADA = w3a de v22n)
"""
from pathlib import Path
import struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from objetos_v12k import encode_w3a, parse_w3a

COLA = '|n|cff808080Recarga %d s, sin maná. El daño sube con el tier.|r'
T = {
    b'ATb1': (20., 'Una copia espiritual del Tauren aparece a su lado y carga hasta el punto (350 a 1000): golpea a cada '
             'enemigo que toca y se lo lleva por delante, y al final golpea el suelo alrededor. El Tauren sigue libre: '
             'no se para ni se arriesga.'),
    b'ATb2': (30., 'Lanza un tótem al punto (hasta 900): daña y aturde 1 s alrededor. Se queda 4 s ralentizando un 50 % '
             'y luego vuelve al Tauren dañando a su paso. La hace una copia; el héroe sigue libre.'),
    b'ATb3': (30., 'Lanza una roca en arco al punto (hasta 1000): daña en un área grande y rebota 3 veces hacia delante '
             '(cada bote hace menos). La hace una copia; el héroe sigue libre.'),
    b'ATb4': (90., 'Definitiva. La copia se planta en el punto (hasta 900) y durante 8 s lanza rocas en espiral '
             'alrededor. La hace una copia; el héroe sigue libre.'),
    b'ACb1': (20., 'Abre una grieta de 900 hacia el punto. A los 1,5 s se parte: daña (más el 6 % de la vida máxima, '
             'hasta +1500) cerca de la línea, junta a los enemigos sobre ella y los ralentiza un 50 % 2 s. La hace una '
             'copia; el héroe sigue libre.'),
    b'ACb5': (30., 'Lanza un tótem al punto (hasta 900) que daña al caer. Dura 6 s: atrae a los enemigos a 600 y cada '
             '0,5 s lanza rayos a 3 de ellos. La hace una copia; el héroe sigue libre.'),
    b'ACb3': (30., 'La copia sale hasta el punto (400 a 1000) dañando al pasar, pisa y vuelve a Cairne dañando; al '
             'llegar le cura 15 por enemigo tocado (hasta 300).'),
    b'ACb4': (90., 'Definitiva. Durante 8 s, kodos espirituales corren en círculo alrededor del punto (hasta 900), a '
             'distintas distancias: dañan a cada enemigo que tocan y lo apartan.'),
}
GUARD = ('Al reaparecer, y una vez por ronda al bajar del 25 % de vida, salen 3 copias de Cairne en tres direcciones: '
         'dañan a cada enemigo que tocan y lo apartan. El daño sube con el tier.')

a_in, a_out = sys.argv[1:3]
ver, tabs = parse_w3a(Path(a_in).read_bytes())
n = 0
g = 0
for tab in tabs:
    for k, r in enumerate(tab):
        if r[1] == b'ACbQ':
            km = []
            for mid, ty, lvl, dat, v, end in r[2]:
                if mid == b'aub1':
                    assert '250 a cada enemigo' in v.decode('utf-8')
                    v = GUARD.encode('utf-8')
                    g += 1
                km.append((mid, ty, lvl, dat, v, end))
            tab[k] = (r[0], r[1], km)
            continue
        if r[1] not in T:
            continue
        cd, txt = T[r[1]]
        km = []
        vistos = set()
        for mid, ty, lvl, dat, v, end in r[2]:
            if mid == b'amcs':
                v = struct.pack('<i', 0)
            elif mid == b'acdn':
                v = struct.pack('<f', cd)
            elif mid == b'aub1':
                assert 'Recarga ' in v.decode('utf-8'), r[1]
                v = (txt + COLA % cd).encode('utf-8')
            if mid in (b'amcs', b'acdn', b'aub1'):
                assert lvl == 1, (r[1], mid, lvl)
                vistos.add(mid)
            km.append((mid, ty, lvl, dat, v, end))
        assert vistos == {b'amcs', b'acdn', b'aub1'}, (r[1], vistos)
        tab[k] = (r[0], r[1], km)
        n += 1
assert n == 8 and g == 1, (n, g)
out = encode_w3a(ver, tabs)
assert encode_w3a(*parse_w3a(out)) == out
Path(a_out).write_bytes(out)
print('w3a v22o:', len(out), 'bytes;', n, 'puentes')
