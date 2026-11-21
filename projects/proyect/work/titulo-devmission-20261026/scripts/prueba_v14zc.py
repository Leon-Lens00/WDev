#!/usr/bin/env python3
"""Sólo prueba, v14zc: la de v14zb (prueba_v14zb.py, registro en lat\\v14zc-N.txt) más el chat «-luz N» para elegir en
vivo la luz del héroe entre war3mapImported\\Luz1.mdx … Luz10.mdx (luz_variantes.cjs); «-luz 0» la quita. Entra con la 1
(la de v14zb). Luz_Poner se llama igual que en v14zb y el chat es común, así que el cambio vale para todos.
Uso: prueba_v14zc.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal = sys.argv[1:3]
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14zb.py'), *sys.argv[1:]], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call PreloadGenEnd("lat\\\\v14zb-"', 'call PreloadGenEnd("lat\\\\v14zc-"')
s = base.once(s, 'effect array Luz_Fx\n', 'effect array Luz_Fx\ninteger Luz_N= 1\n')
s = base.once(s, '''        if Variante > 0 and GetUnitTypeId(Game_Hero[p]) != 0 then
            set Luz_Fx[p] = AddSpecialEffectTarget("war3mapImported\\\\LightWhite1500.mdx", Game_Hero[p], "origin")''',
              '''        if Variante > 0 and Luz_N > 0 and GetUnitTypeId(Game_Hero[p]) != 0 then
            set Luz_Fx[p] = AddSpecialEffectTarget("war3mapImported\\\\Luz" + I2S(Luz_N) + ".mdx", Game_Hero[p], "origin")''')
D = ['sin luz', 'Z 17, alcance 1500, int 300, amb 2 (v14zb)', 'Z 17, alcance 700, int 300, amb 2 (original)',
     'Z 200, alcance 1500, int 300, amb 2', 'Z 400, alcance 1500, int 300, amb 2', 'Z 200, alcance 1500, int 600, amb 2',
     'Z 200, alcance 1500, int 1000, amb 2', 'Z 200, alcance 1500, int 600, amb 5', 'Z 400, alcance 1500, int 1000, amb 5',
     'Z 200, plena hasta 600 y 1500, int 300, amb 2', 'Z 200, alcance 3000, int 600, amb 2']
s = base.once(s, '''    elseif m == "-variante dia" then
''', '''    elseif SubString(m, 0, 5) == "-luz " then
        set Luz_N = S2I(SubString(m, 5, StringLength(m)))
        if Luz_N < 0 or Luz_N > 10 then
            set Luz_N = 0
        endif
        call Luz_Poner()
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 30, "Luz " + I2S(Luz_N) + ": " + Luz_Texto(Luz_N))
    elseif m == "-variante dia" then
''')
f = 'function Luz_Texto takes integer n returns string\n'
for i, d in enumerate(D):
    f += '    if n == %d then\n        return "%s"\n    endif\n' % (i, d)
f += '    return ""\nendfunction\n\nfunction Prueba_Chat takes nothing returns nothing\n'
s = base.once(s, 'function Prueba_Chat takes nothing returns nothing\n', f)
Path(sal).write_text(s, encoding='latin-1', newline='')
