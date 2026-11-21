#!/usr/bin/env python3
"""v18f (15/11/2026), fase 3 del plan: las 8 etiquetas fijas de la tienda dejan de ser texttags.

"Categorías", "Precio", "Daño", "Cargador", "Cadencia", "Precisión", "Oro" y "Salir (Esc)" pasan a piezas Shop_Pic con
su textura ('DSE0'..'DSE7', etiquetas_v18f.py), a profundidad 397 (delante de paneles y cajas, 398-460). Como el resto
de piezas de la tienda entran en Shop_Pz: Shop_Mostrar las enseña sólo en el cliente de quien la abre. Al abrir la
tienda se crean 8 texttags menos (Shop_Textos: de 45 a 37).
Prueba: registros en lat\\v18f-*.txt.
Uso: v18f.py v18e/war3map.j SALIDA.j DIR_ETIQUETAS [prueba]
"""
from pathlib import Path
import json, sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
E = json.loads((Path(sys.argv[3]) / 'etiquetas.json').read_text())['etiquetas']
prueba = len(sys.argv) > 4 and sys.argv[4] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
u8 = lambda s: s.encode('utf-8').decode('latin-1')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(u8(antes)), crlf(u8(despues))
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


una('''    call Shop_Tag(137, 92, 0.026, 0, "Categorías")
    call Shop_Tag(1140, 96, 0.02, 0, "Precio")
    call Shop_Tag(950, 522, 0.017, 0, "Daño")
    call Shop_Tag(1140, 522, 0.017, 0, "Cargador")
    call Shop_Tag(950, 606, 0.017, 0, "Cadencia")
    call Shop_Tag(1140, 606, 0.017, 0, "Precisión")
    call Shop_Tag(1424, 562, 0.024, 0, "Oro")
    call Shop_Tag(250, 758, 0.024, 0, "Salir (Esc)")
''', '''    // v18f: Categorías, Precio, Daño, Cargador, Cadencia, Precisión, Oro y Salir (Esc) son piezas (Shop_Construir).
''')
una('// Sólo en el cliente de quien abre la tienda: 44 texttags que quedan libres para el juego al cerrarla.',
    '// Sólo en el cliente de quien abre la tienda: 37 texttags (v18f) que quedan libres para el juego al cerrarla.')
piezas = ''.join(f"    call Shop_Pic({e['px']}, {e['py']}, {e['w']}, {e['h']}, 397, '{e['id']}')\n" for e in E)
una('''    call Shop_Pic(307, 773, 340, 62, 399, 'DS06')
    set Shop_Hit = CreateTrigger()
''', '''    call Shop_Pic(307, 773, 340, 62, 399, 'DS06')
    // v18f: etiquetas fijas pintadas (etiquetas_v18f.py), en vez de texttags de Shop_Textos.
''' + piezas + '''    set Shop_Hit = CreateTrigger()
''')

if prueba:
    for n in ('super', 'precarga', 'cuadros'):
        una(f'call PreloadGenEnd("lat\\\\v18e-{n}.txt")', f'call PreloadGenEnd("lat\\\\v18f-{n}.txt")')
    assert 'lat\\\\v18e-' not in j
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v18f: 8 etiquetas fijas de la tienda pasan a textura' + (' + registro' if prueba else ''))
