#!/usr/bin/env python3
"""Sólo prueba, v16a: el tutorial guarda sus notas (fases con su tiempo, blancos en pantalla, inicio y fin) en memoria
y las escribe de una vez al terminar, con la pantalla ya en negro, en lat\\v16a-1.txt (escribir puede costar ~170 ms).
Uso: prueba_v16a.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = once(s, 'real Tut_X= 8000.\n', 'string array Prueba_TL\ninteger Prueba_TN= 0\nreal Tut_X= 8000.\n')
s = once(s, '''function Tut_Nota takes string s returns nothing
endfunction
''', r'''function Tut_Nota takes string s returns nothing
    local integer i= 0
    if Prueba_TN < 200 then
        set Prueba_TL[Prueba_TN] = s
        set Prueba_TN = Prueba_TN + 1
    endif
    if SubString(s, 0, 4) == "fin " then
        set Prueba_TL[Prueba_TN] = "tauren " + R2S(GetUnitX(Tut_Tauren)) + " " + R2S(GetUnitY(Tut_Tauren)) + " car " + I2S(Tut_Car[0]) + " " + I2S(Tut_Car[1]) + " " + I2S(Tut_Car[2]) + " fase " + I2S(Tut_Fase)
        set Prueba_TN = Prueba_TN + 1
        call PreloadGenClear()
        loop
            exitwhen i >= Prueba_TN
            call Preload(Prueba_TL[i])
            set i = i + 1
        endloop
        call PreloadGenEnd("lat\\v16a-1.txt")
    endif
endfunction
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
