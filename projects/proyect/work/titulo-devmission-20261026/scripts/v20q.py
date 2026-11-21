#!/usr/bin/env python3
"""v20q (20/11/2026): todos los personajes empiezan con su técnica Q.
Leon: "los personajes iniciaran con su habilidad Q como base en todos". Goku (Kamehameha), Freezer (You Will Die) y
Trunks (Burning Attack) ya empezaban con la Q; Naruto empezaba con E (Rasenrengan), el Tauren con E (Lanzar roca) y
Cairne con W. Ahora empiezan con RasenShuriken, Embestida espiritual y la Q de Cairne; la otra se consigue por carta.
El CD, el maná y el orden del libro van en objetos_v20q.py.
Uso: v20q.py ENTRADA.j SALIDA.j [prueba]   (normal de v20o; prueba de v20o-prueba)
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


for i, tecla, ini in ((60, 'Q', 1), (61, 'E', 0), (65, 'Q', 1), (68, 'E', 0), (72, 'Q', 1), (75, 'W', 0)):
    cambia(f'    set Tec_Tecla[{i}] = "{tecla}"\n    set Tec_Ini[{i}] = {1 - ini}\n',
           f'    set Tec_Tecla[{i}] = "{tecla}"\n    set Tec_Ini[{i}] = {ini}\n')
if prueba:
    for viejo, nuevo in (('lat\\\\v20o-', 'lat\\\\v20q-'), ('v20o-don.txt', 'v20q-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20q', 'prueba' if prueba else 'normal')
