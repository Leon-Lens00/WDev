"""Puente temporal de prueba (Dev Mission v12, 30/10/2026). NO integrar.

Recorre el flujo real sin clics ni intro: jugador 1 registrado de entrada, cuentas cortas en heroe y boss.
Uso: puente_v12.py IN_J OUT_J
"""
from pathlib import Path
import sys

N = '\r\n'


def once(s, old, new):
    old, new = old.replace('\n', N), new.replace('\n', N)
    assert s.count(old) == 1, old[:80]
    return s.replace(old, new)


FUNCS = '''// TEMPORARY test bridge (scripts/puente_v12.py).
function Puente_V12 takes nothing returns nothing
    set Title_Registered[0] = true
    set Title_Count = 1
    set Title_Left = 5
    call Title_Begin()
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = once(s, '// v9c: the missile diagnostic multiboard', FUNCS + '// v9c: the missile diagnostic multiboard')
    s = once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
             '    call TimerStart(CreateTimer(), 0.1, false, function Puente_V12)\n')
    # Title_Restart borra el registro: se repite ahi, sin depender de un clic en Start.
    s = once(s, '    set Title_Active = true\n', '    set Title_Active = true\n    set Title_Registered[0] = true\n    set Title_Count = 1\n')
    s = once(s, '    set Hero_Left = 60\n', '    set Hero_Left = 6\n')
    s = once(s, '    set Boss_Left = 30\n', '    set Boss_Left = 7\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
