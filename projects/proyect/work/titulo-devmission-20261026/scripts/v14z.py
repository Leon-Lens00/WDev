#!/usr/bin/env python3
"""v14z: tarde más oscura y noche azul oscuro, menos negra. Parte del j de v14y.

- Tarde: 18:51 (sol de Dark Nights ~0,3, antes ~0,5) y niebla marrón más oscura 0,22/0,12/0,04 de 1500 a 5000.
- Noche: sigue a las 0:00, con niebla azul oscuro 0,10/0,20/0,35 de 1500 a 5000 (antes negra 1730/5190), que aclara la
  escena con el tono de la muestra de noche de Leon.
La luz radial pegada al héroe (Light - Lights, DarknessFalls003) queda para cuando esté su descarga.
Uso: v14z.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, '''        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 18.6)
        set Storm_TF_zstart = 1500.
        set Storm_TF_zend = 5000.
        set Storm_TF_red = 0.3
        set Storm_TF_green = 0.17
        set Storm_TF_blue = 0.06
''', '''        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 18.85)
        set Storm_TF_zstart = 1500.
        set Storm_TF_zend = 5000.
        set Storm_TF_red = 0.22
        set Storm_TF_green = 0.12
        set Storm_TF_blue = 0.04
''')
s = base.once(s, '''        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 0.)
        set Storm_TF_zstart = 1730.
        set Storm_TF_zend = 5190.
        set Storm_TF_red = 0.
        set Storm_TF_green = 0.
        set Storm_TF_blue = 0.
''', '''        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 0.)
        set Storm_TF_zstart = 1500.
        set Storm_TF_zend = 5000.
        set Storm_TF_red = 0.1
        set Storm_TF_green = 0.2
        set Storm_TF_blue = 0.35
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
