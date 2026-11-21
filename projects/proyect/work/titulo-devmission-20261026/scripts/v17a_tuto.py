#!/usr/bin/env python3
"""v17a-tuto (13/11/2026): v17a con entrada directa al tutorial (sin intro ni título).

Leon (13/11/2026): "dame una con entrada directa al tuto".
- Title_Init arranca Tut_Begin en lugar de Intro_Begin.
- Tut_TrasTitulo = false: al terminar el tutorial, Tut_Entrar registra a los jugadores, pasa por Title_Begin y
  Title_Exit (como en v16z) y Title_Exit abre la partida con Title_Partida.
Uso: v17a_tuto.py v17a/war3map.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()


def una(a, b):
    global j
    a, b = a.replace(b'\n', b'\r\n'), b.replace(b'\n', b'\r\n')
    assert j.count(a) == 1, (a, j.count(a))
    j = j.replace(a, b)


una(b'    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
    b'    // v17a-tuto: entrada directa al tutorial.\n    call TimerStart(CreateTimer(), 0.1, false, function Tut_Begin)\n')
una(b'boolean Tut_TrasTitulo= true\n', b'boolean Tut_TrasTitulo= false\n')
Path(sys.argv[2]).write_bytes(j)
print('v17a-tuto: tutorial directo y partida')
