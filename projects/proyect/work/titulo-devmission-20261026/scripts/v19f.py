#!/usr/bin/env python3
"""v19f (19/11/2026), correcciones tras el registro de v19e-prueba (Leon: "varias habilidades no se estan casteando
con el dummy", "sobretodo en las DON"):
- Dragon Fist y Burning Attack: con base ANrf (objetos_v19f.py) su orden es rainoffire.
- Copia ocupada por técnica, no por jugador: en el registro, 14 pulsaciones de otras técnicas se quedaron en "Ahora no:
  la copia sigue con otra técnica" porque D.O.N deja la copia pausada 2-5 s. El estado de D.O.N es uno por técnica,
  así que sólo se espera a la copia de la misma técnica (Destructo Disc sigue admitiendo varias).
Uso: v19f.py ENTRADA.j SALIDA.j [prueba]   (normal de v19d; prueba de v19e-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('''function Dcp_Ocupada takes integer p returns boolean
    local integer i = 0
    loop
        exitwhen i >= Dcp_N
        if Dcp_P[i] == p and Dcp_F[i] == 0 and Dcp_A[i] != 'A0IY' then
''', '''// v19f: ocupada sólo la copia de la misma técnica (el estado de D.O.N es uno por técnica).
function Dcp_GkReal takes integer a returns integer
    if a == 'AGk1' then
        return 'A00P'
    elseif a == 'AGk2' then
        return 'A0IA'
    elseif a == 'AGk3' then
        return 'A0BZ'
    endif
    return 'A01G'
endfunction

function Dcp_Ocupada takes integer p, integer a returns boolean
    local integer i = 0
    loop
        exitwhen i >= Dcp_N
        if Dcp_P[i] == p and Dcp_F[i] == 0 and Dcp_A[i] == a and a != 'A0IY' then
''')
cambia('''            elseif Dcp_Ocupada(GetPlayerId(GetOwningPlayer(b))) then
                call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 2., "Ahora no: la copia sigue con otra técnica.")
''', '''            elseif Dcp_Ocupada(GetPlayerId(GetOwningPlayer(b)), Dcp_GkReal(a)) then
                call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 2., "Todavía en curso: espera a que termine.")
''')
cambia('''            if Don_BotReal[n] != 'A0IY' and Dcp_Ocupada(GetPlayerId(GetOwningPlayer(b))) then
                call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 2., "Ahora no: la copia sigue con otra técnica.")
''', '''            if Dcp_Ocupada(GetPlayerId(GetOwningPlayer(b)), Don_BotReal[n]) then
                call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 2., "Todavía en curso: espera a que termine.")
''')
cambia('''call Dcp_Lanzar(b, 'A0BZ', 2, "impale", null, x, y)''', '''call Dcp_Lanzar(b, 'A0BZ', 2, "rainoffire", null, x, y)''')
cambia('''    set Don_BotReal[Don_Bots] = 'A05B'
    set Don_BotObj[Don_Bots] = 2
    set Don_BotOrden[Don_Bots] = "shockwave"
''', '''    set Don_BotReal[Don_Bots] = 'A05B'
    set Don_BotObj[Don_Bots] = 2
    set Don_BotOrden[Don_Bots] = "rainoffire"
''')
if prueba:
    cambia('''" ocupada " + Dia_B(Dcp_Ocupada(p))''', '''" ocupada " + Dia_B(Dcp_Ocupada(p, r))''')
    cambia('''call Dia_Pulsa(GetTriggerPlayer(), a, 'A0BZ', "impale", 2''', '''call Dia_Pulsa(GetTriggerPlayer(), a, 'A0BZ', "rainoffire", 2''')
    for viejo, nuevo in (('lat\\\\v19e-', 'lat\\\\v19f-'), ('v19e-don.txt', 'v19f-don.txt')):
        assert viejo in src
        src = src.replace(viejo, nuevo)
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19f', 'prueba' if prueba else 'normal')
