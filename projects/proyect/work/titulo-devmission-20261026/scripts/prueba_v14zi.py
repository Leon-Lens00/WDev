#!/usr/bin/env python3
"""Sólo prueba, v14zi: las de prueba_v14zh.py («-tarde N», vida ilimitada, «-bateria N», «-cargas N», «-fin») con el
registro en lat\\v14zi-N.txt y el chat «-dia N» (1..4), que elige la neblina N del día (1 la más clara, 4 la más
oscura) y aplica el día. La normal usa la 3.
Uso: prueba_v14zi.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal = sys.argv[1:3]
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14zh.py')] + sys.argv[1:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
assert s.count('lat\\\\v14zh-') == 1
s = s.replace('lat\\\\v14zh-', 'lat\\\\v14zi-')
s = base.once(s, '''    elseif m == "-fin" then
''', '''    elseif SubString(m, 0, 5) == "-dia " then
        set c = IMinBJ(4, IMaxBJ(1, S2I(SubString(m, 5, StringLength(m)))))
        set Dia_N = c
        call Variante_Aplicar(0)
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 30, "Dia " + I2S(c) + " niebla " + R2S(Storm_TF_red) + " " + R2S(Storm_TF_green) + " " + R2S(Storm_TF_blue))
    elseif m == "-fin" then
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
