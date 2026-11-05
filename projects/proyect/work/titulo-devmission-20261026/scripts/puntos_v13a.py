"""Puntos de oleada de v13a: las regiones IN de IziPizi (Trig_RondaInt) que caen dentro de la arena central.

Cada punto va a la celda libre más cercana de su región. IN_Copiar_4 e IN_Copiar_5 se dejan fuera: son recintos cerrados
de 900 celdas, sin salida a la arena, y una oleada ahí no terminaría nunca.
Uso: puntos_v13a.py SALIDA_J
"""
from pathlib import Path
import sys

PUNTOS = ((-5952, -2624), (-12768, -2624), (-12640, -4960), (-5952, -5088), (-9440, -4992), (-9440, -2560))

if __name__ == '__main__':
    Path(sys.argv[1]).write_text(''.join(f'        call DevWave_Punto(w,{x}. , {y}.)\n' for x, y in PUNTOS))
    print(len(PUNTOS), 'puntos')
