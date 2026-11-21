#!/usr/bin/env python3
"""v17x (14/11/2026): v17w con BonusMod v3.3.1 y SetUnitMaxState para la súper élite.

Créditos: BonusMod de Earth-Fury, basado en el trabajo de weaaddar; SetUnitMaxState y AbilityPreload incluidos en el
mapa de ejemplo BonusMod.w3x que pasó Leon (/home/snz/Descargas/BonusMod.w3x, sólo lectura). Aquí se pasa a JASS
normal sólo lo que se usa: BM_Set/BM_Get/BM_Add (habilidad de un nivel por bit + una negativa, permanentes) y
BM_VidaMax (habilidad 'Zx01' de 19 niveles: niveles 11-19 = -1..-256, que al quitarla suman).
v17w-prueba se cerró en el paso 4 de la precarga ('SpA*', base AIde). Cambios:
- Armadura '(A)' AId1, daño '(B)' AItg, regeneración '(E)' Arel, velocidad de ataque '(I)' AIsx (objetos_v17x.py).
- Vida máxima con BM_VidaMax en vez de 'ALh*'.
- Precarga como AbilityPreload: durante la carga (desde main), en una 'zsmc' de Player(15) oculta con Aloc.
  La de prueba escribe cada paso en lat\\v17x-precarga.txt antes de hacerlo.
Uso: v17x.py v17w/war3map.j SALIDA.j [prueba]
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


una('''integer Sup_PrePaso = 0
''', '''integer Sup_PrePaso = 0
integer array BM_Raw
integer array BM_Neg
integer array BM_N
integer array BM_Pot
''')

# Bloque de v17w (marca + precarga aplazada) -> BonusMod.
ini = j.index(u8('// v17w: marca el paso de la precarga'))
fin = j.index('endfunction', j.index('function Sup_Precargar takes nothing returns nothing')) + len('endfunction')
marca = '''    call PreloadGenClear()
    call Preload("paso " + I2S(n) + " " + s)
    call PreloadGenEnd("lat\\\\v17x-precarga.txt")
''' if prueba else ''
bloque = '''// v17x: BonusMod v3.3.1 (Earth-Fury, basado en weaaddar) en JASS normal. Tipo t: 0 armadura '(A)', 1 daño '(B)',
// 2 regeneración de vida '(E)', 3 velocidad de ataque % '(I)'. Rango de -2^N a 2^N - 1.
function BM_Set takes unit u, integer t, integer amount returns integer
    local integer i = BM_N[t] - 1
    local integer out = 0
    local boolean neg = false
    if amount < - BM_Pot[BM_N[t]] then
        set amount = - BM_Pot[BM_N[t]]
    elseif amount > BM_Pot[BM_N[t]] - 1 then
        set amount = BM_Pot[BM_N[t]] - 1
    endif
    if amount < 0 then
        set neg = true
        set amount = amount + BM_Pot[BM_N[t]]
        set out = - BM_Pot[BM_N[t]]
    endif
    loop
        exitwhen i < 0
        if amount >= BM_Pot[i] then
            call UnitAddAbility(u, BM_Raw[t] + i)
            call UnitMakeAbilityPermanent(u, true, BM_Raw[t] + i)
            set amount = amount - BM_Pot[i]
            set out = out + BM_Pot[i]
        else
            call UnitRemoveAbility(u, BM_Raw[t] + i)
        endif
        set i = i - 1
    endloop
    if neg then
        call UnitAddAbility(u, BM_Neg[t])
        call UnitMakeAbilityPermanent(u, true, BM_Neg[t])
    else
        call UnitRemoveAbility(u, BM_Neg[t])
    endif
    return out
endfunction

function BM_Get takes unit u, integer t returns integer
    local integer i = 0
    local integer s = 0
    if GetUnitAbilityLevel(u, BM_Neg[t]) > 0 then
        set s = - BM_Pot[BM_N[t]]
    endif
    loop
        exitwhen i >= BM_N[t]
        if GetUnitAbilityLevel(u, BM_Raw[t] + i) > 0 then
            set s = s + BM_Pot[i]
        endif
        set i = i + 1
    endloop
    return s
endfunction

function BM_Add takes unit u, integer t, integer n returns integer
    return BM_Set(u, t, BM_Get(u, t) + n)
endfunction

// v17x: SetUnitMaxState (del mismo mapa de ejemplo) para la vida máxima. 'Zx01' nivel 2 + b = +2^b y nivel 11 + b =
// -2^b; el nivel puesto no suma y al quitarla se resta su valor: para sumar se usa el negativo.
function BM_VidaMax takes unit u, integer n returns nothing
    local integer i = 8
    local integer off = 11
    if n < 0 then
        set off = 2
        set n = - n
    endif
    loop
        exitwhen n <= 0 or i < 0
        if n >= BM_Pot[i] then
            call UnitAddAbility(u, 'Zx01')
            call SetUnitAbilityLevel(u, 'Zx01', off + i)
            call UnitRemoveAbility(u, 'Zx01')
            set n = n - BM_Pot[i]
        else
            set i = i - 1
        endif
    endloop
endfunction

function BM_Marca takes integer n, string s returns nothing
    set Sup_PrePaso = n
''' + marca + '''endfunction

function BM_Cargar takes unit d, integer t returns nothing
    local integer i = 0
    loop
        exitwhen i >= BM_N[t]
        call UnitAddAbility(d, BM_Raw[t] + i)
        set i = i + 1
    endloop
    call UnitAddAbility(d, BM_Neg[t])
endfunction

// v17x: tipos y precarga durante la carga (desde main), como AbilityPreload: pieza 'zsmc' de Player(15), oculta,
// con Aloc y vida temporal. Así ninguna habilidad de la súper élite se carga por primera vez a mitad de oleada.
function BM_Init takes nothing returns nothing
    local unit d
    local integer i = 1
    set BM_Pot[0] = 1
    loop
        exitwhen i > 16
        set BM_Pot[i] = BM_Pot[i - 1] * 2
        set i = i + 1
    endloop
    set BM_Raw[0] = '(A)a'
    set BM_Neg[0] = '(A)-'
    set BM_N[0] = 10
    set BM_Raw[1] = '(B)a'
    set BM_Neg[1] = '(B)-'
    set BM_N[1] = 14
    set BM_Raw[2] = '(E)a'
    set BM_Neg[2] = '(E)-'
    set BM_N[2] = 11
    set BM_Raw[3] = '(I)a'
    set BM_Neg[3] = '(I)-'
    set BM_N[3] = 10
    call BM_Marca(1, "crear pieza")
    set d = CreateUnit(Player(15), 'zsmc', 0., 0., 0.)
    call UnitApplyTimedLife(d, 0, .001)
    call ShowUnit(d, false)
    call UnitAddAbility(d, 'Aloc')
    call BM_Marca(2, "armadura (A)")
    call BM_Cargar(d, 0)
    call BM_Marca(3, "dano (B)")
    call BM_Cargar(d, 1)
    call BM_Marca(4, "regeneracion (E)")
    call BM_Cargar(d, 2)
    call BM_Marca(5, "vel. ataque (I)")
    call BM_Cargar(d, 3)
    call BM_Marca(6, "vida Zx01")
    call UnitAddAbility(d, 'Zx01')
    call BM_Marca(7, "marca SpM0")
    call UnitAddAbility(d, 'SpM0')
    call BM_Marca(8, "evasion SpE")
    set i = 0
    loop
        exitwhen i > 9
        call UnitAddAbility(d, 'SpE0' + i)
        set i = i + 1
    endloop
    call BM_Marca(9, "robo de vida SpV")
    set i = 0
    loop
        exitwhen i > 9
        call UnitAddAbility(d, 'SpV0' + i)
        set i = i + 1
    endloop
    call BM_Marca(10, "pasiva AIbx")
    call UnitAddAbility(d, 'AIbx')
    call BM_Marca(11, "pasiva AIcs")
    call UnitAddAbility(d, 'AIcs')
    call BM_Marca(12, "pasiva Assk")
    call UnitAddAbility(d, 'Assk')
    call BM_Marca(13, "pasiva ANth")
    call UnitAddAbility(d, 'ANth')
    call BM_Marca(14, "pasiva ACce")
    call UnitAddAbility(d, 'ACce')
    call BM_Marca(15, "pasiva AIob")
    call UnitAddAbility(d, 'AIob')
    call BM_Marca(16, "pasiva AIsz")
    call UnitAddAbility(d, 'AIsz')
    call BM_Marca(17, "modelo de la marca")
    call Preload("Abilities\\\\Spells\\\\Undead\\\\UnholyFrenzy\\\\UnholyFrenzyTarget.mdl")
    call BM_Marca(18, "fin")
    set d = null
endfunction'''
j = j[:ini] + crlf(u8(bloque)) + j[fin:]

una('''    call Sup_Precargar()
''', '')
una('''    set Sup_StHab[0] = 'SpD0'
''', '''    set Sup_StHab[0] = 1
''')
una('''    set Sup_StHab[1] = 'SpA0'
''', '''    set Sup_StHab[1] = 0
''')
una('''    set Sup_StHab[3] = 'SpS0'
''', '''    set Sup_StHab[3] = 3
''')
una('''    set Sup_StHab[5] = 'SpR0'
''', '''    set Sup_StHab[5] = 2
''')
una('''    // Vida: 'ALh0'..'ALhA' del mapa (+10·2^b al añadir; al quitarlas en el nivel 2 se resta 0), en pasos de 10.
    // v17u lo hacía con niveles y la vida bajaba (el nivel no suma; quitar resta el nivel actual).
    set hp = GetUnitState(u, UNIT_STATE_MAX_LIFE)
    set vida = GetWidgetLife(u)
    set v = R2I(hp * (m - 1.) / 10. + 0.5)
    set b = 0
    loop
        exitwhen v <= 0 or b > 10
        if ModuloInteger(v, 2) == 1 then
            if b == 10 then
                set t = 'ALhA'
            else
                set t = 'ALh0' + b
            endif
            call UnitAddAbility(u, t)
            call SetUnitAbilityLevel(u, t, 2)
            call UnitRemoveAbility(u, t)
        endif
        set v = v / 2
        set b = b + 1
    endloop
''', '''    // Vida: SetUnitMaxState ('Zx01', v17x). Se conserva la proporción de vida actual.
    set hp = GetUnitState(u, UNIT_STATE_MAX_LIFE)
    set vida = GetWidgetLife(u)
    call BM_VidaMax(u, R2I(hp * (m - 1.) + 0.5))
''')
una('''            call Sup_Bits(u, Sup_StHab[t], v, 7)
''', '''            call BM_Add(u, Sup_StHab[t], v)
''')
una('''    call Sup_Bits(u, 'SpD0', dano, 8)
''', '''    call BM_Add(u, 1, dano)
''')
una('''(b < nb; base 'SpD0', 'SpA0'...: dígitos seguidos).''', '''(b < nb; bases de dígitos seguidos).''')
# BM_Init durante la carga: al final de main.
a = j.index('function main takes nothing returns nothing')
e = j.index('\r\nendfunction', a)
j = j[:e] + '\r\n    call ExecuteFunc("BM_Init")' + j[e:]

if prueba:
    una('''" bits " + I2S(Sup_Hay(u, 'SpD0', 8)) + " armadura " + I2S(Sup_Hay(u, 'SpA0', 7)) + " velataque " + I2S(Sup_Hay(u, 'SpS0', 7)) + " regen " + I2S(Sup_Hay(u, 'SpR0', 7))''',
        '''" bonus " + I2S(BM_Get(u, 1)) + " armadura " + I2S(BM_Get(u, 0)) + " velataque " + I2S(BM_Get(u, 3)) + " regen " + I2S(BM_Get(u, 2))''')
    una('call PreloadGenEnd("lat\\\\v17w-super.txt")', 'call PreloadGenEnd("lat\\\\v17x-super.txt")')
    una('call PreloadGenEnd("lat\\\\v17w-cuadros.txt")', 'call PreloadGenEnd("lat\\\\v17x-cuadros.txt")')
for viejo in ("'SpD", "'SpA", "'SpS", "'SpR", 'lat\\\\v17w-', 'Sup_PrecargarYa'):
    assert viejo not in j, viejo
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17x: BonusMod' + (' + marcas' if prueba else ''))
