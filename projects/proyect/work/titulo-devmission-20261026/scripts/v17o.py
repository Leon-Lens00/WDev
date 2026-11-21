#!/usr/bin/env python3
"""v17o (14/11/2026): precarga de lo nuevo de v17h a v17n.

Leon tras probar v17n: "funciono bien, solo seria agregar todos nuestros elementos nuevo a la precarga para no tener
cuelgues". Precarga_Todo (al empezar) no tenía nada de la presentación ni de la barra del jefe:
- Preload de los archivos: las 18 texturas Jefe*.blp, los 9 PresJefe{n}.mdx y las 9 HealthJefe{n}.mdx (a la caché).
- Primer uso, que es lo que carga de verdad: una pieza de cada textura de la presentación con JefePres_Dummy (como al
  presentar: 'uidb' / 'uidg' con su piel), y una unidad de cada modelo de jefe girado ('upj2'..'upjA'), de cada barra de
  jefe ('hbk2'..'hbkA') y de cada icono de jefe ('hbj2'..'hbjA'); se crean y se quitan lejos, como los tipos de oleada.
Uso: v17o.py v17n/war3map.j SALIDA.j (y v17n-prueba/war3map.j para la de prueba)
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(antes), crlf(despues)
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


TEX = (['JefeOscuro', 'JefeRafaga', 'JefeBarra', 'JefeAviso'] + [f'JefeRayo{k}' for k in range(1, 6)]
       + [f'JefeNombre{n}' for n in range(2, 11)])
arch = [f'war3mapImported\\\\{t}.blp' for t in TEX] + [f'war3mapImported\\\\PresJefe{n}.mdx' for n in range(2, 11)]
arch += [f'UI\\\\HealthBarsHorizontal\\\\HealthJefe{c}.mdx' for c in '23456789A']
una('    call PreloadEnd(2.0)\n',
    '    // v17o: presentación y barra del jefe.\n'
    + ''.join(f'    call Preload("{a}")\n' for a in arch)
    + '    call PreloadEnd(2.0)\n')

una('''    // v17d: todos los sonidos (truenos incluidos) a volumen 0 en Son_Init.
    call Son_Init()
''', '''    // v17o: presentación del jefe (texturas con su pieza, como al presentar) y modelos de jefe, barras e iconos.
    set i = 0
    loop
        exitwhen i > 8
        if i == 0 or i == 3 then
            call RemoveUnit(JefePres_Dummy('uidb', 'DP00' + i, 100., 100., 300., 270.))
        else
            call RemoveUnit(JefePres_Dummy('uidg', 'DP00' + i, 100., 100., 300., 270.))
        endif
        set i = i + 1
    endloop
    set i = 2
    loop
        exitwhen i > 10
        if i == 10 then
            call RemoveUnit(JefePres_Dummy('uidb', 'DPNA', 100., 100., 300., 270.))
            call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'upjA', x, y, 0.))
            call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'hbkA', x, y, 0.))
            call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'hbjA', x, y, 0.))
        else
            call RemoveUnit(JefePres_Dummy('uidb', 'DPN0' + i, 100., 100., 300., 270.))
            call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'upj0' + i, x, y, 0.))
            call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'hbk0' + i, x, y, 0.))
            call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'hbj0' + i, x, y, 0.))
        endif
        set i = i + 1
    endloop
    set JefePres_U = null
    // v17d: todos los sonidos (truenos incluidos) a volumen 0 en Son_Init.
    call Son_Init()
''')
una('// v17h: presentación del jefe de ronda (scripts/v17h.py); v17n',
    '// v17h: presentación del jefe de ronda (scripts/v17h.py); v17o (scripts/v17o.py): todo en Precarga_Todo; v17n')
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17o: precarga de la presentación y la barra del jefe')
