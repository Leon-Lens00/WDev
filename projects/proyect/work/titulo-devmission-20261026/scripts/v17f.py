#!/usr/bin/env python3
"""v17f (14/11/2026): cada bala crea su propio sonido 3D, sin tope global, y la cola del disparo anterior baja.

Leon (14/11/2026): "puedes crear el audio cada momento que sale el proyectil, asi no tendria poblema con otros jugadores
usando el mismo arma". Ya era un CreateSound por disparo; v17f quita el tope común de 10 disparos por 0,25 s (podía
callar a otros jugadores) y, para que se oiga el ritmo sin recortar la toma, el disparo anterior del mismo jugador baja a
1/3 de volumen al salir el siguiente. Cada jugador guarda sus 4 últimos sonidos (sin KillSoundWhenDone, así el handle
sigue siendo válido cuando se toca); el de hace 4 disparos se detiene y se libera con StopSound(s, true, false).
Escopeta: un sonido por disparo (no por perdigón), como antes.
Uso: v17f.py v17e/war3map.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')


def una(antes, despues):
    global j
    antes, despues = crlf(antes), crlf(despues)
    assert j.count(antes) == 1, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


una('timer Son_Musica= null\n', 'timer Son_Musica= null\n// v17f: 4 últimos disparos por jugador (p * 4 + k)\nsound array Son_Ring\ninteger array Son_RingI\n')
una('''function Son_Disparo takes unit a, integer w returns nothing
    if Son_Hueco(0) then
        call Son_3D(Son_Arma[w], GetUnitX(a), GetUnitY(a), 127, "MissilesEAX", GetOwningPlayer(a))
    endif
endfunction
''', '''// v17f: como Son_3D, pero devuelve el sonido y no lo libera al acabar (lo libera Son_Disparo 4 disparos después).
function Son_Crear takes string f, real x, real y, integer vol, string eax, player owner returns sound
    local sound s
    local integer v = vol
    set Son_Tono = ModuloInteger(Son_Tono + 7, 11)
    if GetLocalPlayer() != owner then
        set v = vol * 3 / 4
    endif
    set s = CreateSound(f, false, true, true, 10, 10, eax)
    call SetSoundChannel(s, 11)
    call SetSoundDistances(s, 600., 10000.)
    call SetSoundDistanceCutoff(s, 3000.)
    call SetSoundPitch(s, 0.95 + 0.01 * I2R(Son_Tono))
    call SetSoundVolume(s, v)
    call SetSoundPosition(s, x, y, 0.)
    call StartSound(s)
    return s
endfunction

// v17f: un sonido por bala, sin tope común; la cola del disparo anterior de este jugador baja a 1/3.
function Son_Disparo takes unit a, integer w returns nothing
    local integer p = GetPlayerId(GetOwningPlayer(a))
    local integer i = Son_RingI[p]
    local integer prev = p * 4 + ModuloInteger(i + 3, 4)
    local integer v = 127
    if Son_Arma[w] == null or Son_Arma[w] == "" then
        return
    endif
    if GetLocalPlayer() != Player(p) then
        set v = 95
    endif
    if Son_Ring[prev] != null then
        call SetSoundVolume(Son_Ring[prev], v / 3)
    endif
    if Son_Ring[p * 4 + i] != null then
        call StopSound(Son_Ring[p * 4 + i], true, false)
    endif
    set Son_Ring[p * 4 + i] = Son_Crear(Son_Arma[w], GetUnitX(a), GetUnitY(a), 127, "MissilesEAX", Player(p))
    set Son_RingI[p] = ModuloInteger(i + 1, 4)
endfunction
''')
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17f: sonido por bala con cola atenuada')
