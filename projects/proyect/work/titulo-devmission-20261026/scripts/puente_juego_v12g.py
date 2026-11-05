"""Puente temporal de prueba (Dev Mission v12g, 30/10/2026). NO integrar.

Va directo a la zona de juego: sin intro, titulo, seleccion ni presentacion. CELDA elige personaje (0 Tauren, 1 Cairne).
Uso: puente_juego_v12g.py IN_J OUT_J CELDA
"""
from pathlib import Path
import sys

import puente_v12 as base

FUNCS = '''// TEMPORARY test bridge (scripts/puente_juego_v12g.py).
function Puente_Juego takes nothing returns nothing
    call Title_Exit()
    set Hero_Choice[0] = CELDA
    call Title_Black(255, 0, 0.2)
    call DestroyTimer(GetExpiredTimer())
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'function Title_Init takes nothing returns nothing\n',
                  FUNCS.replace('CELDA', str(int(sys.argv[3]))) + 'function Title_Init takes nothing returns nothing\n')
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
                  '    call TimerStart(CreateTimer(), 0.1, false, function Puente_Juego)\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
