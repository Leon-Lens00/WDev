#!/usr/bin/env python3
"""v22h (23/11/2026): el botón de la E de Vegito ya no se rechaza mientras corre la E de Afterimage.

Registro v22g-don.txt (Leon): Afterimage lanza la E a 16.453 ("vegito E ranura 1 activas 1") y el botón a 18.094 da
"pulsa ... curso 1 ocupada 0" sin copia: el botón (Gk_Comando) mira Don_EnCurso antes que Dcp_Ocupada y v22g hacía
Don_EnCurso('A03F') = alguna E en curso. Ahora Don_EnCurso('A03F') es verdadero sólo con las 6 ranuras ocupadas, igual
que Dcp_Ocupada. Otros consumidores: Dcp_Tick suelta copias a k160 (8 s) si no está en curso (la E dura ~5 s y la copia
se suelta antes por "sin orden"); Jun_* sigue mientras la copia esté pausada.
Uso: v22h.py ENTRADA.j SALIDA.j [prueba]   (normal de v22g; prueba de v22g-prueba).
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


cambia('''    elseif a == 'A03F' then
        // v22g: alguna E de Vegito en curso.
        return Vte_Activas > 0
''', '''    elseif a == 'A03F' then
        // v22h: la E de Vegito admite 6 a la vez: "en curso" sólo con las 6 ranuras ocupadas (el botón la pide aparte).
        return Vte_Activas >= 6
''')

if prueba:
    cambia('lat\\\\v22g-', 'lat\\\\v22h-', src.count('lat\\\\v22g-'))
    cambia('v22g-don.txt', 'v22h-don.txt', src.count('v22g-don.txt'))
    assert 'lat\\\\v22g-' not in src and 'v22g-don.txt' not in src, 'quedan registros v22g'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22h', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
