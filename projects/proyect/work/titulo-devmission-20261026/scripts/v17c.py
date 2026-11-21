#!/usr/bin/env python3
"""v17c (14/11/2026): v17b con entrada directa a la partida, sin intro ni tutorial.

Leon (14/11/2026): "inicia directo al mapa, con intro y tutoriak desactivados".
Vuelve al arranque anterior a v17a (v16t): Title_Init lanza Tut_Begin, que se salta el tutorial y llama a Tut_Entrar
(registra a los jugadores, Title_Begin y Title_Exit al momento); Tut_TrasTitulo empieza en false para que Title_Exit
abra la partida (Title_Partida) en lugar del tutorial.
Uso: v17c.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()
crlf = lambda b: b.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')


def una(antes, despues):
    global j
    antes, despues = crlf(antes.encode('latin-1')), crlf(despues.encode('latin-1'))
    assert j.count(antes) == 1, (antes[:90], j.count(antes))
    j = j.replace(antes, despues)


una('    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
    '    // v17c: entrada directa (sin intro, título ni tutorial).\n'
    '    call TimerStart(CreateTimer(), 0.1, false, function Tut_Begin)\n')
una('    if not Tut_Libre() then\n        call RemoveLocation(l)\n',
    '    if true then\n        // v17c: sin tutorial.\n        call RemoveLocation(l)\n')
una('boolean Tut_TrasTitulo= true\n', 'boolean Tut_TrasTitulo= false\n')
Path(sys.argv[2]).write_bytes(j)
print('v17c: entrada directa')
