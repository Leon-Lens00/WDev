#!/usr/bin/env python3
"""v18u-prueba (15/11/2026): v18t-prueba sin oleadas ni música, para probar el cuadro de resultados (Leon).

- DevWave_Arrancar ya no lanza la ronda 1: no salen unidades, no suena el tema de la oleada y no corre la tirada de
  élites. Se para y se vacía la música del mapa. Se avisa en pantalla de usar "-punt [N]".
- Sólo variante de prueba. Registros v18t -> v18u.  Uso: v18u.py ENTRADA.j SALIDA.j prueba
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
assert (sys.argv[3] if len(sys.argv) > 3 else '') == 'prueba'


def cambia(viejo, nuevo, veces=1):
    global src
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('''    call RegisterWaveFinishEvent(function Ronda_AlTerminar)
    call Ronda_Lanzar()
endfunction
''', '''    call RegisterWaveFinishEvent(function Ronda_AlTerminar)
    // v18u-prueba: sin oleadas ni música, para probar el cuadro de resultados con "-punt [N]".
    call StopMusic(false)
    call ClearMapMusic()
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "Prueba sin oleadas: escribe -punt o -punt N para ver el cuadro de resultados.")
endfunction
''')
assert src.count('lat\\\\v18t-') == 4
src = src.replace('lat\\\\v18t-', 'lat\\\\v18u-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18u prueba')
