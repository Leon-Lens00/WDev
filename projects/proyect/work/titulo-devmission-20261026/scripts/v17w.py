#!/usr/bin/env python3
"""v17w (14/11/2026): v17v con la precarga de la súper élite aplazada y, en la de prueba, marcada paso a paso.

v17v-prueba de Leon: "cargaba el mapa pero al terminar la barra dio crash". Lo único nuevo al entrar en v17v es
Sup_Precargar (desde Sup_HudCrear -> Sup_Init): pieza oculta 'uidb' a la que se añaden todas las 'Sp*' y las 7 pasivas.
Cambios:
- La precarga corre 3 s después de entrar (temporizador), así un cierre ya no coincide con el fin de la carga.
- Pieza sin ShowUnit(false); las pasivas se añaden una a una.
- Prueba: antes de cada paso escribe "paso N ..." en lat\\v17w-precarga.txt (el archivo queda con el último paso
  alcanzado si el juego se cierra). Los registros de súper élite y cuadros pasan a v17w-*.
Uso: v17w.py v17v/war3map.j SALIDA.j [prueba]
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
u8 = lambda s: s.encode('utf-8').decode('latin-1')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(u8(antes)), crlf(u8(despues))
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


una('''timer Sup_Reloj = null
''', '''timer Sup_Reloj = null
integer Sup_PrePaso = 0
''')

ini = j.index(u8('function Sup_Precargar takes nothing returns nothing'))
fin = j.index('endfunction', ini) + len('endfunction')
marca = '''    call PreloadGenClear()
    call Preload("paso " + I2S(n) + " " + s)
    call PreloadGenEnd("lat\\\\v17w-precarga.txt")
''' if prueba else ''
nueva = '''// v17w: marca el paso de la precarga (en la de prueba lo escribe antes de hacerlo).
function Sup_PreMarca takes integer n, string s returns nothing
    set Sup_PrePaso = n
''' + marca + '''endfunction

// v17w: añade y quita todas las habilidades de la súper élite a una pieza, 3 s después de entrar; el modelo de la
// marca, con Preload (sólo calienta la caché). En v17v se hacía al entrar con la pieza oculta y el juego se cerró.
function Sup_PrecargarYa takes nothing returns nothing
    local unit d
    local integer b = 0
    call DestroyTimer(GetExpiredTimer())
    call Sup_PreMarca(1, "crear pieza")
    set d = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'uidb', 0., 0., 0.)
    call Sup_PreMarca(2, "marca SpM0")
    call UnitAddAbility(d, 'SpM0')
    call Sup_PreMarca(3, "dano SpD")
    loop
        exitwhen b > 7
        call UnitAddAbility(d, 'SpD0' + b)
        set b = b + 1
    endloop
    call Sup_PreMarca(4, "armadura SpA")
    set b = 0
    loop
        exitwhen b > 6
        call UnitAddAbility(d, 'SpA0' + b)
        set b = b + 1
    endloop
    call Sup_PreMarca(5, "vel. ataque SpS")
    set b = 0
    loop
        exitwhen b > 6
        call UnitAddAbility(d, 'SpS0' + b)
        set b = b + 1
    endloop
    call Sup_PreMarca(6, "regeneracion SpR")
    set b = 0
    loop
        exitwhen b > 6
        call UnitAddAbility(d, 'SpR0' + b)
        set b = b + 1
    endloop
    call Sup_PreMarca(7, "evasion SpE")
    set b = 0
    loop
        exitwhen b > 9
        call UnitAddAbility(d, 'SpE0' + b)
        set b = b + 1
    endloop
    call Sup_PreMarca(8, "robo de vida SpV")
    set b = 0
    loop
        exitwhen b > 9
        call UnitAddAbility(d, 'SpV0' + b)
        set b = b + 1
    endloop
    set b = 0
    loop
        exitwhen b > 6
        call Sup_PreMarca(9 + b, "pasiva " + Sup_PaNom[b])
        call UnitAddAbility(d, Sup_PaId[b])
        set b = b + 1
    endloop
    call Sup_PreMarca(16, "quitar pieza")
    call RemoveUnit(d)
    set d = null
    call Sup_PreMarca(17, "modelo de la marca")
    call Preload("Abilities\\\\Spells\\\\Undead\\\\UnholyFrenzy\\\\UnholyFrenzyTarget.mdl")
    call Sup_PreMarca(18, "fin")
endfunction

function Sup_Precargar takes nothing returns nothing
    call TimerStart(CreateTimer(), 3., false, function Sup_PrecargarYa)
endfunction'''
j = j[:ini] + crlf(u8(nueva)) + j[fin:]

if prueba:
    una('call PreloadGenEnd("lat\\\\v17v-super.txt")', 'call PreloadGenEnd("lat\\\\v17w-super.txt")')
    una('call PreloadGenEnd("lat\\\\v17v-cuadros.txt")', 'call PreloadGenEnd("lat\\\\v17w-cuadros.txt")')
assert 'lat\\\\v17v-' not in j, 'quedan registros v17v'
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17w: precarga aplazada' + (' + marcas' if prueba else ''))
