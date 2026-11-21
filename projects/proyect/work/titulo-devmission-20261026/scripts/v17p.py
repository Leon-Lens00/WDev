#!/usr/bin/env python3
"""v17p (14/11/2026): configuración de jugadores del script a juego con el w3i de w3i_v17p.py.

- SetTeams(2) (antes 8) y config llama a InitCustomTeams (antes InitGenericPlayerSlots, sin efecto en este mapa); raza Humano fija para los jugadores 1-8 (antes aleatoria y elegible).
- InitCustomTeams: Dev Us = jugadores 1-4 (equipo 0), Dev Mission = 5-8 (equipo 1), y aliados entre los 8 desde el
  principio, como escribe el editor para fuerzas aliadas (la visión compartida sigue llegando en
  ConversationUI___Start, al salir del título, como antes).
Uso: v17p.py v17o/war3map.j SALIDA.j ID_CADENA_FUERZA_2 (y v17o-prueba/war3map.j para la de prueba)
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


una('    call SetTeams(8)\n', '    call SetTeams(2)\n')
# Con fuerzas propias el editor llama a InitCustomTeams en lugar de InitGenericPlayerSlots (que con "usar ajustes del
# mapa" no hace nada); hasta v17o InitCustomTeams estaba escrita pero nadie la llamaba.
una('    call InitGenericPlayerSlots()\n', '    call InitCustomTeams()\n')
una('RACE_PREF_RANDOM)\n', 'RACE_PREF_HUMAN)\n', 8)
for p in range(8):
    una(f'    call SetPlayerRaceSelectable(Player({p}), true)\n', f'    call SetPlayerRaceSelectable(Player({p}), false)\n')
una('''function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_007
    call SetPlayerTeam(Player(0), 0)
    call SetPlayerTeam(Player(1), 0)
    call SetPlayerTeam(Player(2), 0)
    call SetPlayerTeam(Player(3), 0)
    call SetPlayerTeam(Player(4), 0)
    call SetPlayerTeam(Player(5), 0)
    call SetPlayerTeam(Player(6), 0)
    call SetPlayerTeam(Player(7), 0)

endfunction
''', f'''function InitCustomTeams takes nothing returns nothing
    local integer i = 0
    local integer k
    // Force: TRIGSTR_007 (Dev Us)
    call SetPlayerTeam(Player(0), 0)
    call SetPlayerTeam(Player(1), 0)
    call SetPlayerTeam(Player(2), 0)
    call SetPlayerTeam(Player(3), 0)
    // Force: TRIGSTR_{sys.argv[3]} (Dev Mission)
    call SetPlayerTeam(Player(4), 1)
    call SetPlayerTeam(Player(5), 1)
    call SetPlayerTeam(Player(6), 1)
    call SetPlayerTeam(Player(7), 1)
    // v17p: las dos fuerzas son aliadas en el juego (en la sala hacen falta dos para jugar en línea).
    loop
        exitwhen i > 7
        set k = 0
        loop
            exitwhen k > 7
            if i != k then
                call SetPlayerAllianceStateAllyBJ(Player(i), Player(k), true)
            endif
            set k = k + 1
        endloop
        set i = i + 1
    endloop
endfunction
''')
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17p: equipos fijos y raza Humano')
