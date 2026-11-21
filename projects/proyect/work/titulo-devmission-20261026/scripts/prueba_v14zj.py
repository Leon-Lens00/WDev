#!/usr/bin/env python3
"""Sólo prueba, v14zj: las de prueba_v14zi.py con el registro en lat\\v14zj-N.txt, más:
- «-compra C T»: intenta comprar el tier T de la categoría C como el botón Comprar de la tienda (Shop_Comprar).
- el registro de cada chat añade las rondas pasadas, la categoría activa y el tier 1 del cuchillo.
Uso: prueba_v14zj.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal = sys.argv[1:3]
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14zi.py')] + sys.argv[1:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
assert s.count('lat\\\\v14zi-') == 1
s = s.replace('lat\\\\v14zi-', 'lat\\\\v14zj-')
s = base.once(s, '''    elseif m == "-fin" then
''', '''    elseif SubString(m, 0, 8) == "-compra " then
        set Shop_Cat[p] = S2I(SubString(m, 8, 9))
        set Shop_Ver[p] = S2I(SubString(m, 10, 11))
        call Shop_Comprar(p)
    elseif m == "-fin" then
''')
s = base.once(s, '''    call Prueba_Log("chat " + m + " oro " + I2S(GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)) + Prueba_Armas(p))''',
              '''    call Prueba_Log("chat " + m + " oro " + I2S(GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)) + Prueba_Armas(p) + " pasadas " + I2S(Ronda_Pasadas()) + " ronda " + I2S(Ronda_Numero) + " cat " + I2S(Arm_Cat[p]) + " cuchillo " + I2S(Arm_Tier[p * 7 + 5]))''')
Path(sal).write_text(s, encoding='latin-1', newline='')
