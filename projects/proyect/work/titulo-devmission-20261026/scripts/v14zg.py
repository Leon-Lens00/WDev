#!/usr/bin/env python3
"""v14zg (06/11/2026): la batería sólo baja durante la oleada. Parte del j de v14zf.

- Al empezar el descanso (Ronda_AlTerminar) la batería vuelve a 100 sola, además de las 2 recargas de v14zf.
- Bat_Paso sólo descuenta con Ronda_Activa y sin Ronda_Descanso: no baja antes de la primera oleada ni en el
  descanso, y sigue sin bajar de día o con la tienda abierta.

Uso: v14zg.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def u8(t):
    return t.encode('utf-8').decode('latin-1')


ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')
s = once(s, u8('''// v14zf: 0,1 s de batería cada 0,10 s; no baja de día ni con la tienda abierta.
'''), u8('''// v14zf: 0,1 s de batería cada 0,10 s; no baja de día ni con la tienda abierta. v14zg: sólo durante la oleada.
'''))
s = once(s, '''        if Bat_T[p] > 0. and Variante != 0 and GetUnitTypeId(Game_Hero[p]) != 0 and not Shop_Open[p] then
''', '''        if Bat_T[p] > 0. and Ronda_Activa and not Ronda_Descanso and Variante != 0 and GetUnitTypeId(Game_Hero[p]) != 0 and not Shop_Open[p] then
''')
s = once(s, '''                set Bat_Cargas[p] = Bat_Cargas[p] + 2
''', '''                set Bat_Cargas[p] = Bat_Cargas[p] + 2
                set Bat_T[p] = 100.
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
