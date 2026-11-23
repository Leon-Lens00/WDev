#!/usr/bin/env python3
"""v22v (23/11/2026): 5 cartas en Armas (antes 4) y 5 cuadros en cada paso de Mutación Evo (antes 3 con un jugador).

Leon tras v22u-prueba: "en la tienda de armas hay que agregar una tarjeta y 2 en la de jefes, ya que son pocas a
comparacion de las habilidades que lleva 5".
- Armas: la mano tiene 5 cartas (Cua_HCand[p*40+35..39]); la quinta del pull comprado se guarda aparte en la cola
  (HerC_A5C/Q/T[p*8+i]), porque la cola guarda 4 por pull. En Armas la quinta casilla es una carta, no el refresco
  del héroe (Her_Nombre, Her_Des, Her_Tinte).
- Mutación Evo: Cua_NE = 5 siempre (antes 3 con 1-2 jugadores, 4 con 3-5, 5 con 6 o más) y jefe y élites ya no se
  limitan a 4. Con menos candidatas libres salen menos, como antes.
Uso: v22v.py ENTRADA.j SALIDA.j [prueba]   (normal de v22u; prueba de v22u-prueba).
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


# 0) Globales: quinta carta de armas de cada pull de la cola.
cambia('integer array HerC_AT\n', '''integer array HerC_AT
// v22v: quinta carta de la mano de armas de cada pull de la cola (p * 8 + i).
integer array HerC_A5C
integer array HerC_A5Q
integer array HerC_A5T
''')

# 1) Mutación Evo: 5 cuadros por paso.
cambia('''    set Cua_NE = 3
    if n >= 6 then
        set Cua_NE = 5
    elseif n >= 3 then
        set Cua_NE = 4
    endif
''', '''    // v22v: 5 cuadros por paso de Mutación Evo con cualquier número de jugadores.
    set Cua_NE = 5
''')
cambia('IMinBJ(Cua_NE, 4)', 'Cua_NE', 4)

# 2) Armas: 5 cartas en pantalla.
cambia('''    if Cua_Modo[p] == 3 then
        return 4
    endif
''', '''    // v22v: 5 cartas en Armas.
    if Cua_Modo[p] == 3 then
        return 5
    endif
''')
cambia('Cua_EsCarta(p) and c < 4 and (Cua_Item(p, c) == 86',
       'Cua_EsCarta(p) and (c < 4 or Cua_Modo[p] == 3) and (Cua_Item(p, c) == 86')
# La quinta casilla sólo es el refresco en Habilidades.
cambia('''function Her_Nombre takes integer p, integer c returns string
    if c == 4 then
''', '''function Her_Nombre takes integer p, integer c returns string
    if c == 4 and Cua_Modo[p] != 3 then
''')
cambia('''    if c == 4 then
        if Her_Refrescos[p] <= 0 then
            return "|cff909090Sin refrescos.''', '''    if c == 4 and Cua_Modo[p] != 3 then
        if Her_Refrescos[p] <= 0 then
            return "|cff909090Sin refrescos.''')
cambia('''function Her_Tinte takes integer p, integer c returns nothing
    local integer q
    if c == 4 then
''', '''function Her_Tinte takes integer p, integer c returns nothing
    local integer q
    if c == 4 and Cua_Modo[p] != 3 then
''')

# 3) Reparto de la mano de armas: 5 cartas.
cambia('        exitwhen i > 3 or n <= 0\n', '        exitwhen i > 4 or n <= 0\n')
cambia('''    if i <= 3 then
        set lx[0] = 108
''', '''    if i <= 4 then
        set lx[0] = 108
''')
cambia('''    loop
        exitwhen i > 3
        if n > 0 then
            set j = GetRandomInt(0, n - 1)
            call ArmC_Poner(p, i, lx[j], lt[j])
''', '''    loop
        exitwhen i > 4
        if n > 0 then
            set j = GetRandomInt(0, n - 1)
            call ArmC_Poner(p, i, lx[j], lt[j])
''')
cambia('I2S(Cua_HCand[p * 40 + 38]) + " quedan "', 'I2S(Cua_HCand[p * 40 + 38]) + " " + I2S(Cua_HCand[p * 40 + 39]) + " quedan "')
cambia('''    loop
        exitwhen c > 3
        set f = f or Cua_HCand[k + c] == 20
''', '''    loop
        exitwhen c > 4
        set f = f or Cua_HCand[k + c] == 20
''')

# 4) Cola de pulls: la quinta carta de armas.
cambia('''        set HerC_AHecha[a] = HerC_AHecha[a + 1]
''', '''        set HerC_AHecha[a] = HerC_AHecha[a + 1]
        set HerC_A5C[a] = HerC_A5C[a + 1]
        set HerC_A5Q[a] = HerC_A5Q[a + 1]
        set HerC_A5T[a] = HerC_A5T[a + 1]
''')
cambia('''        loop
            exitwhen c > 3
            set x = HerC_AC[b + c]
            set Cua_HCand[k + c] = x
            set Her_Cal[k + c] = HerC_AQ[b + c]
            set Her_Tipo[k + c] = HerC_AT[b + c]
            if x == 86 then
                set t = Arm_Tier[p * 7 + HerC_AT[b + c]]
                if t >= 6 or Ronda_Pasadas() < Arm_Req(t + 1) or (t < 5 and HerC_AQ[b + c] != t) or (t >= 5 and HerC_AQ[b + c] != 6) then
                    set rehacer = true
                endif
            elseif x == 87 and Arm_Tier[p * 7 + HerC_AT[b + c]] > 0 then
                set rehacer = true
            elseif not Car_Disp(p, x, HerC_AT[b + c]) then
''', '''        // v22v: 5 cartas; la quinta en HerC_A5C/Q/T.
        loop
            exitwhen c > 4
            if c < 4 then
                set Cua_HCand[k + c] = HerC_AC[b + c]
                set Her_Cal[k + c] = HerC_AQ[b + c]
                set Her_Tipo[k + c] = HerC_AT[b + c]
            else
                set Cua_HCand[k + c] = HerC_A5C[p * 8]
                set Her_Cal[k + c] = HerC_A5Q[p * 8]
                set Her_Tipo[k + c] = HerC_A5T[p * 8]
            endif
            set x = Cua_HCand[k + c]
            if x == 86 then
                set t = Arm_Tier[p * 7 + Her_Tipo[k + c]]
                if t >= 6 or Ronda_Pasadas() < Arm_Req(t + 1) or (t < 5 and Her_Cal[k + c] != t) or (t >= 5 and Her_Cal[k + c] != 6) then
                    set rehacer = true
                endif
            elseif x == 87 and Arm_Tier[p * 7 + Her_Tipo[k + c]] > 0 then
                set rehacer = true
            elseif not Car_Disp(p, x, Her_Tipo[k + c]) then
''')
cambia('''        loop
            exitwhen c > 3
            if Her_EsMaldita(Cua_HCand[k + c]) then
''', '''        loop
            exitwhen c > 4
            if Her_EsMaldita(Cua_HCand[k + c]) then
''')
cambia('''            set HerC_AC[b + c] = Cua_HCand[k + c]
            set HerC_AQ[b + c] = Her_Cal[k + c]
            set HerC_AT[b + c] = Her_Tipo[k + c]
            set c = c + 1
        endloop
''', '''            set HerC_AC[b + c] = Cua_HCand[k + c]
            set HerC_AQ[b + c] = Her_Cal[k + c]
            set HerC_AT[b + c] = Her_Tipo[k + c]
            set c = c + 1
        endloop
        // v22v: quinta carta de armas.
        set HerC_A5C[p * 8] = Cua_HCand[k + 4]
        set HerC_A5Q[p * 8] = Her_Cal[k + 4]
        set HerC_A5T[p * 8] = Her_Tipo[k + 4]
''')

if prueba:
    assert 'function Cop_Anotar' in src
    cambia('lat\\\\v22u-', 'lat\\\\v22v-', src.count('lat\\\\v22u-'))
    cambia('v22u-don.txt', 'v22v-don.txt', src.count('v22u-don.txt'))
    assert 'lat\\\\v22u-' not in src and 'v22u-don.txt' not in src, 'quedan registros v22u'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22v', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
