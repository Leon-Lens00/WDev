#!/usr/bin/env python3
"""v14t: niebla de la partida más oscura. Parte del j de v14s.

La niebla negra de v14s (1730/5190) era la del mapa de OVOgenez escalada a la cámara de juego, que está más alta de lo
normal (distancia 2856 en lugar de 1650). Leon la quiere más oscura, como se ve el original: empieza en 1000 y acaba en
4500. Con eso, en el objetivo de la cámara la niebla ya cubre ~53 %, y el borde superior de la pantalla casi negro.

Uso: v14t.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, '''// v14s: niebla negra de la partida (la de Storm, escalada a la cámara de juego). El periódico de Storm la aplica.
function Storm_Oscuro takes nothing returns nothing
    set Storm_TF_style = 0
    set Storm_TF_zstart = 1730.
    set Storm_TF_zend = 5190.
'''.encode('utf-8').decode('latin-1'), '''// v14t: niebla negra de la partida, más cerrada que la de Storm escalada (v14s: 1730/5190). El periódico de Storm la aplica.
function Storm_Oscuro takes nothing returns nothing
    set Storm_TF_style = 0
    set Storm_TF_zstart = 1000.
    set Storm_TF_zend = 4500.
'''.encode('utf-8').decode('latin-1'))
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v14t: niebla 1000/4500')
