#!/usr/bin/env python3
"""v20o (20/11/2026): recuento de la tabla MVP un 50 % más rápido (Leon: "aceleremos un 50 la velocidad de contador").
Antes: cada columna giraba 1,5 s, la ruleta de nombres empezaba a 7,5 s y el resultado se fijaba a 10 s de Mvp_Ini.
Ahora todo ÷ 1,5: columna 1 s (MVP_PASO), ruleta a 5 s (5 × paso), resultado a 6,67 s (paso × 10 / 1,5).
Lo de después de fijarse (ataque, muerte, salida a +5 s) no cambia.
Uso: v20o.py ENTRADA.j SALIDA.j [prueba]   (normal de v20n; prueba de v20n-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')


def cambia(viejo, nuevo, veces=1):
    global src
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('real Mvp_Ini = 0.\n', 'real Mvp_Ini = 0.\n// v20o: segundos que gira cada columna de la tabla MVP (antes 1,5).\nconstant real MVP_PASO = 1.0\n')
cambia('    local real s = Mvp_Ini + 1.5 * c\n    local real e = s + 1.5\n',
       '    local real s = Mvp_Ini + MVP_PASO * c\n    local real e = s + MVP_PASO\n')
cambia('        if Punt_T < Mvp_Ini + 7.5 then\n', '        if Punt_T < Mvp_Ini + 5. * MVP_PASO then\n')
cambia('Punt_T >= Mvp_Ini + 1.5 * c then', 'Punt_T >= Mvp_Ini + MVP_PASO * c then')
cambia('    set Mvp_Fija = Mvp_Ini + 10.\n', '    set Mvp_Fija = Mvp_Ini + MVP_PASO * 10. / 1.5\n')
if prueba:
    for viejo, nuevo in (('lat\\\\v20n-', 'lat\\\\v20o-'), ('v20n-don.txt', 'v20o-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20o', 'prueba' if prueba else 'normal')
