#!/usr/bin/env python3
"""v22a (22/11/2026): la Bijuu Dama de Kurama se para al chocar y estalla al acabar su vida.

Leon tras v21z-prueba: "va bien pero explota al chocar, debe cumplir su tiempo de vida, asi como la W, se para al
chocar y explora de acuerdo a su tiempo de vida".
v21z mataba la pieza hKu0 en el choque. Ahora se queda en el último punto libre (velocidad 0, sin más trazos) hasta que
acaba su vida (2,5 s desde que sale); entonces G2F_Bijuu_Dama_sfx hace la explosión ahí. Mientras espera sigue dañando
a los enemigos que entren en 400 (una vez cada uno), como la esfera de la W de Trunks en v21u.
Registro (sólo prueba): "kurama R choca en X Y" una vez por lanzamiento.
Uso: v22a.py ENTRADA.j SALIDA.j [prueba]   (normal de v21z; prueba de v21z-prueba).
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


cambia('''                // v21z: la Bijuu Dama de Kurama (hKu0) para en árboles y precipicios, como Don_Pon (v21u).
                set choca = false
                if GetUnitTypeId(u) == 'hKu0' and s__GroundCollision_trace(''',
       '''                // v21z: la Bijuu Dama de Kurama (hKu0) para en árboles y precipicios, como Don_Pon (v21u).
                // v22a: se queda ahí (velocidad 0) hasta acabar su vida; no muere al chocar.
                set choca = false
                if GetUnitTypeId(u) == 'hKu0' and G2V_WaveSpeed[i] > 0 and s__GroundCollision_trace(''')
cambia('''                    set choca = true
                    set x = s__GroundCollision_x
                    set y = s__GroundCollision_y
''', '''                    set choca = true
                    set x = s__GroundCollision_x
                    set y = s__GroundCollision_y
                    set G2V_WaveSpeed[i] = 0
''')
cambia('''                    if choca then
                        call KillUnit(u)
                    endif
''', '')
if prueba:
    cambia('lat\\\\v21z-', 'lat\\\\v22a-', src.count('lat\\\\v21z-'))
    cambia('v21z-don.txt', 'v22a-don.txt', src.count('v21z-don.txt'))
    assert 'lat\\\\v21z-' not in src and 'v21z-don.txt' not in src, 'quedan registros v21z'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22a', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
