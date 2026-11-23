#!/usr/bin/env python3
"""v21b (21/11/2026): Leon: al empezar cada oleada, aviso de -bl 0/1/2 (balas ligeras contra el lag).
El aviso sale en el chat de cada jugador en partida (8 s) desde Ronda_Lanzar, con el modo que tiene puesto.
Uso: v21b.py ENTRADA.j SALIDA.j [prueba]   (normal de v21a; prueba de v21a-prueba).
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


cambia('''    call Ronda_TemaEmpezar()
    call Sup_Ronda()
endfunction
''', '''    call Ronda_TemaEmpezar()
    call Sup_Ronda()
    // v21b: aviso de las balas ligeras en cada oleada (sólo texto en el chat de cada jugador).
    set p = 0
    loop
        exitwhen p > 11
        if Game_On[p] and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
            call DisplayTimedTextToPlayer(Player(p), 0., 0., 8., Ronda_AvisoBalas(p))
        endif
        set p = p + 1
    endloop
endfunction
''')
cambia('''function Ronda_Lanzar takes nothing returns nothing
''', '''// v21b: texto del aviso de balas ligeras con el modo que tiene p.
function Ronda_AvisoBalas takes integer p returns string
    local string s = "normales"
    if Lig_Nivel[p] == 1 then
        set s = "las de los demás ligeras"
    elseif Lig_Nivel[p] == 2 then
        set s = "todas ligeras"
    endif
    return "|cffffcc00¿Lag con muchas balas?|r Escribe |cff7cff7c-bl 1|r (ligeras las de los demás) o |cff7cff7c-bl 2|r (todas ligeras); |cff7cff7c-bl 0|r las deja normales. Ahora: " + s + "."
endfunction

function Ronda_Lanzar takes nothing returns nothing
''')

if prueba:
    for v, n in (('lat\\\\v21a-', 'lat\\\\v21b-'), ('v21a-don.txt', 'v21b-don.txt')):
        assert v in src, v
        src = src.replace(v, n)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21b', 'prueba' if prueba else 'normal')
