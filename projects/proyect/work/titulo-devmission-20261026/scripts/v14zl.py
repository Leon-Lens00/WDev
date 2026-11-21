#!/usr/bin/env python3
"""v14zl (07/11/2026): fase 3 de docs/planes/devmission-armas-rachas-v14zj.md (élites). Parte del j de v14zk.

- Vida de las élites al 20 % de la del jefe de la ronda (antes 40 %). La vida base de 'ne00'..'ne09' baja a 160 en el
  w3u (objetos_v14zl.py), el 20 % de los 800 del jefe de la ronda 1; el resto se suma al aparecer con 'ALh0'..'ALhA'.
- En su propia ronda, la élite del tipo nuevo sólo llega con la primera llamada de refuerzos del jefe (una por
  jugador). Los eventos por muertes de la oleada (i × Total / n) sólo traen élites de los tipos de rondas anteriores:
  desde la ronda siguiente la élite del tipo entra en la oleada normal. En la ronda 1 no hay jefe ni élites; la del
  tipo 1 aparece por primera vez en la oleada de la ronda 2.

Uso: v14zl.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def u8(t):
    return t.encode('utf-8').decode('latin-1')


ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')

s = once(s, '        set n=R2I(( 0.40 * I2R(R2I(800. * ( 1. + 0.75 * ( Ronda_Numero - 1 ) ) + 0.5)) - 320. ) / 10. + 0.5)\n',
         '        set n=R2I(( 0.20 * I2R(R2I(800. * ( 1. + 0.75 * ( Ronda_Numero - 1 ) ) + 0.5)) - 160. ) / 10. + 0.5)\n')
s = once(s, '''        set DevWave_EliteSig=1
        set DevWave_EliteE=n
''', u8('''        set DevWave_EliteSig=1
        // v14zl: los eventos por muertes sólo traen élites de los tipos viejos (0 .. n - 2); la del nuevo, el jefe.
        set DevWave_EliteE=n - 1
'''))
s = once(s, '''    set DevJefe_Llamadas=DevJefe_Llamadas + 1
    set o=IMinBJ(DevJefe_Llamadas, 6)
''', u8('''    set DevJefe_Llamadas=DevJefe_Llamadas + 1
    set o=IMinBJ(DevJefe_Llamadas, 6)
    // v14zl: la primera llamada trae la élite del tipo nuevo de la ronda, una por jugador.
    if DevJefe_Llamadas == 1 then
        call DevWave_Elite(DevWave_NTipos - 1)
    endif
'''))
# DevWave_Elite tiene que estar antes que DevJefe_Aplicar (JASS no admite llamadas hacia delante).
assert s.index('function DevWave_Elite takes') < s.index('function DevJefe_Aplicar takes')
Path(sal).write_text(s, encoding='latin-1', newline='')
