#!/usr/bin/env python3
"""Sólo prueba, v14zh: las de prueba_v14zg.py (vida ilimitada, «-bateria N», «-cargas N», «-fin») con el registro en
lat\\v14zh-N.txt y el chat «-tarde N» (1..4), que elige el naranja N de la niebla de tarde (1 el más claro, 4 el más oscuro) y
aplica la tarde. La normal usa el 3.
Uso: prueba_v14zh.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal = sys.argv[1:3]
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14zg.py')] + sys.argv[1:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
assert s.count('lat\\\\v14zg-') == 1
s = s.replace('lat\\\\v14zg-', 'lat\\\\v14zh-')
s = base.once(s, '''    elseif m == "-fin" then
''', '''    elseif SubString(m, 0, 7) == "-tarde " then
        set c = IMinBJ(4, IMaxBJ(1, S2I(SubString(m, 7, StringLength(m)))))
        set Tarde_N = c
        call Variante_Aplicar(1)
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 30, "Tarde " + I2S(c) + " niebla " + R2S(Storm_TF_red) + " " + R2S(Storm_TF_green) + " " + R2S(Storm_TF_blue))
    elseif m == "-fin" then
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
