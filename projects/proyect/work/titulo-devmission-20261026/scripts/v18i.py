#!/usr/bin/env python3
"""v18i (15/11/2026), correcciones de la prueba de v18h:
- Aviso de ESC (DSE9 "Press [ESC] to buy supplies" junto al golem y DSEA "[ESC] Pick up Ammo" junto a los cofres
  verdes de munición): en la grabación 20261115_163328 la tinta cae en y 527-549 frente a 516-539 del texto de v18f
  (centro en x igual). Las dos piezas comparten cy: 524,7 -> 514,2 (10,5 px más arriba).
- Las escalas de las bolsas van en objetos_v18i.py (sólo w3u).
Uso: v18i.py v18h/war3map.j SALIDA.j [prueba]
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'


def una(antes, despues, n=1):
    global j
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


una('call HealthBars__Place(u, cam, 1014.0, 524.7, 400.)', 'call HealthBars__Place(u, cam, 1014.0, 514.2, 400.)')
una('call HealthBars__Place(u, cam, 1075.9, 524.7, 400.)', 'call HealthBars__Place(u, cam, 1075.9, 514.2, 400.)')
if prueba:
    for n in ('super', 'precarga', 'bolsas', 'cuadros'):
        una(f'call PreloadGenEnd("lat\\\\v18h-{n}.txt")', f'call PreloadGenEnd("lat\\\\v18i-{n}.txt")')
    assert 'PreloadGenEnd("lat\\\\v18h-' not in j
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v18i: aviso de ESC 10,5 px más arriba' + (' + registro' if prueba else ''))
