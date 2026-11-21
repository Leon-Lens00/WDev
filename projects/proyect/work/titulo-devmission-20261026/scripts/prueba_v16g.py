#!/usr/bin/env python3
"""Sólo prueba, v16g: las notas del tutorial de prueba_v16a.py en lat\\v16g-1.txt (hasta 900) y, desde la fase 11
(primer disparo), el estado de la pareja real cada 0,5 s: posición, tiros emitidos, dashes, arma y balas, recarga,
movimiento artificial, efecto de los pies y del dash, y maná del controlador.
Uso: prueba_v16g.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import subprocess, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once
subprocess.run([sys.executable, '-I', str(Path(__file__).resolve().parent / 'prueba_v16a.py')] + sys.argv[1:3], check=True)
s = Path(sys.argv[2]).read_text(encoding='latin-1', newline='')
assert s.count('lat\\\\v16a-') == 1
s = s.replace('lat\\\\v16a-', 'lat\\\\v16g-')
s = once(s, 'if Prueba_TN < 200 then', 'if Prueba_TN < 900 then')
s = once(s, 'integer Prueba_TN= 0\n', 'integer Prueba_TN= 0\nreal Prueba_EstT= 0.\n')
s = once(s, '''    call Tut_Hud()
    call Tut_Marca()''', '''    if Tut_Fase >= 11 and Tut_T >= Prueba_EstT then
        set Prueba_EstT = Tut_T + 0.5
        call Tut_Estado("t")
    endif
    call Tut_Hud()
    call Tut_Marca()''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
