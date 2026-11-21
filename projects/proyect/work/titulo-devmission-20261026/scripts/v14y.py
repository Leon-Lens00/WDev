#!/usr/bin/env python3
"""v14y: visión clásica y tarde oscura. Parte del j de v14w (sin la linterna de v14x, que se descarta).

- Ya no se revela todo el campo de juego: se quita el FOG_OF_WAR_VISIBLE de Rect(-7296, -7296, 5888, 5632) de
  Game_Enter (queda el de menús y tienda, Rect(800, 7700, 4000, 9700)) y HudMask_Apply activa la niebla de guerra
  (FogEnable true, con la máscara negra de antes). Cada jugador ve sólo el círculo de sus unidades; h005 y h006 ven
  1100 (objetos_v14y.py).
- Tarde como la referencia de Leon (marrón oscuro, media ~0,11): 18:36 (sol ~0,5 de Dark Nights) y niebla marrón
  0,30/0,17/0,06 de 1500 a 5000.
Uso: v14y.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, '    call FogModifierStart(CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, Rect(-7296.0, -7296.0, 5888.0, 5632.0), true, true))\n', '')
s = base.once(s, '''    call FogEnable(false)
    call FogMaskEnable(true)
endfunction
''', '''    call FogEnable(true)
    call FogMaskEnable(true)
endfunction
''')
s = base.once(s, '''        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 18.25)
        set Storm_TF_zstart = 1900.
        set Storm_TF_zend = 6000.
        set Storm_TF_red = 0.95
        set Storm_TF_green = 0.5
        set Storm_TF_blue = 0.18
''', '''        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 18.6)
        set Storm_TF_zstart = 1500.
        set Storm_TF_zend = 5000.
        set Storm_TF_red = 0.3
        set Storm_TF_green = 0.17
        set Storm_TF_blue = 0.06
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
