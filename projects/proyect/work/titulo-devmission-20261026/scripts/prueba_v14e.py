#!/usr/bin/env python3
"""Sólo prueba, v14e: sin intro ni menús; crea sus trackables igual, para que estén en el mapa, y abre la tienda con oro.

Uso: prueba_v14e.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)', 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
s = base.once(s, '''    call Title_Begin()
    call TimerStart(CreateTimer(), 0.1, false, function Title_Exit)
''', '''    call Title_Begin()
    call Mode_Tracks()
    call Hero_Tracks()
    call Boss_Tracks()
    call Strat_Tracks()
    call TimerStart(CreateTimer(), 0.1, false, function Title_Exit)
''')
s = base.once(s, 'function Title_Exit takes nothing returns nothing\n', '''function Prueba_Abrir takes nothing returns nothing
    set Ronda_Activa = true
    set Ronda_Descanso = true
    call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, 5000)
    call SetUnitInvulnerable(Game_Hero[0], true)
    call SetUnitX(Game_Hero[0], GetUnitX(Shop_Golem))
    call SetUnitY(Game_Hero[0], GetUnitY(Shop_Golem) - 100)
    call Shop_Abrir(0)
endfunction

function Title_Exit takes nothing returns nothing
''')
# La ronda 1 empieza sin descanso y quitaría la invulnerabilidad con la tienda forzada abierta.
s = base.once(s, '        if Game_On[p] and Vidas_EnPartida[p] then\n            call SetUnitInvulnerable(Game_Hero[p], false)\n',
              '        if Game_On[p] and Vidas_EnPartida[p] then\n            call SetUnitInvulnerable(Game_Hero[p], true)\n')
s = base.once(s, '    call ExecuteFunc("Shop_Construir")\n', '    call ExecuteFunc("Shop_Construir")\n    call TimerStart(CreateTimer(), 3., false, function Prueba_Abrir)\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
