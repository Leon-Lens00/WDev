#!/usr/bin/env python3
"""v14zh (06/11/2026): tarde más oscura y anaranjada. Parte del j de v14zg.

- La tarde usa la meseta de las 18,8 h de tarde_v14zh.cjs (Dark Nights: directa 0,06 y ambiental 0,04, naranjas).
  Medido en v14zh-capturas: entre mesetas la imagen apenas cambia (brillo sin linterna 0,073 a 0,070), porque con la
  cámara a ~2850 y la niebla de 1500 a 5000 manda el color de la niebla.
- Por eso el tono de la tarde va en la niebla: Tarde_N elige uno de cuatro naranjas, del más claro (1, el de antes
  algo más vivo) al más oscuro (4). Por defecto el 3. Mismo inicio y fin de niebla.

Uso: v14zh.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')
s = once(s, 'timer Bat_Reloj= null\n', 'timer Bat_Reloj= null\n// v14zh: hora de la tarde (meseta de tarde_v14zh.cjs).\nreal Tarde_Hora= 18.8\ninteger Tarde_N= 3\n')
s = once(s, '''        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 19.15)
        set Storm_TF_zstart = 1500.
        set Storm_TF_zend = 5000.
        set Storm_TF_red = 0.22
        set Storm_TF_green = 0.12
        set Storm_TF_blue = 0.04
''', '''        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, Tarde_Hora)
        set Storm_TF_zstart = 1500.
        set Storm_TF_zend = 5000.
        call Tarde_Niebla()
''')
s = once(s, 'function Variante_Aplicar takes integer v returns nothing\n', '''// v14zh: color de la niebla de la tarde según Tarde_N (1 claro .. 4 oscuro), siempre naranja.
function Tarde_Niebla takes nothing returns nothing
    if Tarde_N == 1 then
        set Storm_TF_red = 0.30
        set Storm_TF_green = 0.13
        set Storm_TF_blue = 0.03
    elseif Tarde_N == 2 then
        set Storm_TF_red = 0.22
        set Storm_TF_green = 0.09
        set Storm_TF_blue = 0.02
    elseif Tarde_N == 3 then
        set Storm_TF_red = 0.15
        set Storm_TF_green = 0.06
        set Storm_TF_blue = 0.012
    else
        set Storm_TF_red = 0.09
        set Storm_TF_green = 0.035
        set Storm_TF_blue = 0.008
    endif
endfunction

function Variante_Aplicar takes integer v returns nothing
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
