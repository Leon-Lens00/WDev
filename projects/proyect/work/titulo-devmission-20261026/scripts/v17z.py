#!/usr/bin/env python3
"""v17z (15/11/2026): iconos de las tarjetas de la súper élite delante de su fondo.

v17y-prueba de Leon (con grabación): la escalera funciona, pero los iconos siguen oscuros. Causa: lo translúcido se
ordena por la distancia real al ojo de la cámara, no por el rango de HealthBars__Place (distancia a lo largo del eje).
Cerca del borde izquierdo la distancia real es rango × sqrt(1 + desvío²): el icono (398, x 60) queda a ~482,6 y el fondo
(412, x 180, más cerca del centro) a ~479,5, así que el fondo, con su relleno oscuro al 84 %, se dibuja encima.
- Icono a 380 (tamaño ×380/400 para verse igual): en todo el deslizamiento (dx 0 a −420) queda 19 a 22 unidades por
  delante del fondo, como el relleno de la tienda a 385 frente al marco.
Sólo cambia el j. Prueba: registros en lat\\v17z-*.txt.
Uso: v17z.py v17y/war3map.j SALIDA.j [prueba]
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
u8 = lambda s: s.encode('utf-8').decode('latin-1')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(u8(antes)), crlf(u8(despues))
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


una('''                call HealthBars__Place(u, cam, 60. + dx, y, 398.)
''', '''                // v17z: a 380; a 398 quedaba detrás del fondo en distancia real a la cámara (ver v17z.py).
                call HealthBars__Place(u, cam, 60. + dx, y, 380.)
''')
una('''            call Arm_Foto(u, 46., 46., tex)
            call ShowUnit(u, false)
            set Sup_Ico[p * 4 + k] = u
''', '''            call Arm_Foto(u, 46. * 380. / 400., 46. * 380. / 400., tex)
            call ShowUnit(u, false)
            set Sup_Ico[p * 4 + k] = u
''')
if prueba:
    for n in ('super', 'precarga', 'cuadros'):
        una(f'call PreloadGenEnd("lat\\\\v17y-{n}.txt")', f'call PreloadGenEnd("lat\\\\v17z-{n}.txt")')
    assert 'lat\\\\v17y-' not in j

Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17z: iconos de la súper élite a 380' + (' + registro' if prueba else ''))
