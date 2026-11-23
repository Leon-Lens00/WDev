#!/usr/bin/env python3
"""v22n (23/11/2026): icono de la tarjeta de racha en la columna derecha; cifra de caídas dentro de la lápida.

Leon tras v22m-prueba: "solo un minimo ajuste al numero de muertes que esta un poco descuadrado y otros en el cuadro de
rachas no muestra el icono en la segunda columna, el primera que sale a su izquierda si mostraba".
- Racha: lo translúcido del HUD se ordena por la distancia real al ojo, no por el rango (memoria orden-translucido).
  Columna derecha (cx 1125): el icono (cx + 170,6, rango 398) queda 335 px a la derecha del centro y el fondo (cx,
  rango 400) a 165: distancia real ~426 contra ~419, el icono sale detrás del fondo y no se ve. Columna izquierda
  (cx 705): al revés, se veía. En la columna derecha icono y marco se acercan 14 (384 y 376): ~5 por delante del fondo
  en toda la altura de la pantalla. Crecen ~3,5 % los dos (el icono sigue cabiendo en el marco).
- Caídas: la cifra de la lápida estaba ~10 px por encima del centro del recuadro: 538 a 548.
Uso: v22n.py ENTRADA.j SALIDA.j [prueba]   (normal de v22m; prueba de v22m-prueba).
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('''            call HealthBars__Place(Racha_Cara[v * 2] , cam , cx + 170.6 , y , 398. + d)
            call HealthBars__Place(Racha_Marco[v] , cam , cx + 170.6 , y , 390. + d)
''', '''            // v22n: en la columna derecha, icono y marco 14 más cerca: por distancia real al ojo quedaban detrás del fondo.
            call HealthBars__Place(Racha_Cara[v * 2] , cam , cx + 170.6 , y , 398. + d - 14. * I2R(ModuloInteger(Racha_CHueco[k], 2)))
            call HealthBars__Place(Racha_Marco[v] , cam , cx + 170.6 , y , 390. + d - 14. * I2R(ModuloInteger(Racha_CHueco[k], 2)))
''')
cambia('call Punt_PosC(Punt_TT[p * 16 + 9], v, 894.0, 538 + dy, 0.028)',
       'call Punt_PosC(Punt_TT[p * 16 + 9], v, 894.0, 548 + dy, 0.028)')

if prueba:
    assert 'function Cop_Anotar' in src
    cambia('lat\\\\v22m-', 'lat\\\\v22n-', src.count('lat\\\\v22m-'))
    cambia('v22m-don.txt', 'v22n-don.txt', src.count('v22m-don.txt'))
    assert 'lat\\\\v22m-' not in src and 'v22m-don.txt' not in src, 'quedan registros v22m'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22n', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
