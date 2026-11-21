#!/usr/bin/env python3
"""v17v (14/11/2026): v17u con las bonificaciones de la súper élite por bits (ver objetos_v17v.py).

v17u-prueba de Leon (1 min 23 s, sin vídeo): 2 súper élites en la ronda 1, tarjetas creadas y quitadas al morir, fin de
oleada correcto; pero la vida máxima bajó de 120 a 90 (debía subir a 150). Causa en objetos_v17v.py. Cambios:
- Vida: 'ALh0'..'ALhA' del mapa (+10·2^b, como DevFuego_Aparece), en pasos de 10.
- Daño (multiplicador + mejora), armadura, velocidad de ataque y regeneración: una habilidad por bit, sin niveles.
- Velocidad de movimiento: SetUnitMoveSpeed. Evasión y robo de vida siguen con niveles.
- Marca de súper élite: 'SpM0'.
Prueba: el registro pasa a lat\\v17v-super.txt y anota la vida, la velocidad y los bits que quedaron puestos.
Uso: v17v.py v17u/war3map.j SALIDA.j [prueba]
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


una("    if GetUnitAbilityLevel(u, 'Sp0M') == 0 then\n", "    if GetUnitAbilityLevel(u, 'SpM0') == 0 then\n")
una("GetUnitAbilityLevel(u, 'Sp0M') == 0 and Sup_Base", "GetUnitAbilityLevel(u, 'SpM0') == 0 and Sup_Base")
una('''    set Sup_StHab[0] = 'Sp0D'
''', '''    set Sup_StHab[0] = 'SpD0'
''')
una('''    set Sup_StHab[1] = 'Sp0A'
''', '''    set Sup_StHab[1] = 'SpA0'
''')
una('''    set Sup_StHab[3] = 'Sp0S'
''', '''    set Sup_StHab[3] = 'SpS0'
''')
una('''    set Sup_StHab[5] = 'Sp0R'
''', '''    set Sup_StHab[5] = 'SpR0'
''')
una('''    set Sup_StHab[6] = 'Sp0O'
''', '''    set Sup_StHab[6] = 0
''')
una('''    set Sup_StHab[2] = 'Sp0V'
''', '''    set Sup_StHab[2] = 'SpV0'
''')
una('''    set Sup_StHab[4] = 'Sp0E'
''', '''    set Sup_StHab[4] = 'SpE0'
''')
# Precarga al crear el HUD (Game_Enter): sin el primer uso a mitad de oleada.
una('''    call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function Sup_Muere)
endfunction
''', '''    call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function Sup_Muere)
    call Sup_Precargar()
endfunction
''')
una('''function Sup_Init takes nothing returns nothing''', '''// v17v: añade y quita todas las habilidades de la súper élite a una pieza al entrar, para que no se carguen la
// primera vez a mitad de oleada; el modelo de la marca, con Preload (sólo calienta la caché).
function Sup_Precargar takes nothing returns nothing
    local unit d = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'uidb', 0., 0., 0.)
    local integer b = 0
    call ShowUnit(d, false)
    call UnitAddAbility(d, 'SpM0')
    loop
        exitwhen b > 9
        if b < 8 then
            call UnitAddAbility(d, 'SpD0' + b)
        endif
        if b < 7 then
            call UnitAddAbility(d, 'SpA0' + b)
            call UnitAddAbility(d, 'SpS0' + b)
            call UnitAddAbility(d, 'SpR0' + b)
            call UnitAddAbility(d, Sup_PaId[b])
        endif
        call UnitAddAbility(d, 'SpE0' + b)
        call UnitAddAbility(d, 'SpV0' + b)
        set b = b + 1
    endloop
    call RemoveUnit(d)
    set d = null
    call Preload("Abilities\\\\Spells\\\\Undead\\\\UnholyFrenzy\\\\UnholyFrenzyTarget.mdl")
endfunction

function Sup_Init takes nothing returns nothing''')

# Función de bits, antes de Sup_Valor.
una('''// Valor de la mejora t en la ronda r''', '''// v17v: n en binario con las habilidades de un nivel base + b (b < nb; base 'SpD0', 'SpA0'...: dígitos seguidos).
function Sup_Bits takes unit u, integer base, integer n, integer nb returns nothing
    local integer b = 0
    loop
        exitwhen n <= 0 or b >= nb
        if ModuloInteger(n, 2) == 1 then
            call UnitAddAbility(u, base + b)
        endif
        set n = n / 2
        set b = b + 1
    endloop
endfunction

// Valor de la mejora t en la ronda r''')

una('''    // Vida: 'Sp0L' nivel b + 2 da 2^b; al quitarla se resta el nivel 1, que es 0. Se conserva la proporción.
    set hp = GetUnitState(u, UNIT_STATE_MAX_LIFE)
    set vida = GetWidgetLife(u)
    set v = R2I(hp * (m - 1.) + 0.5)
    set b = 0
    loop
        exitwhen v <= 0 or b > 13
        if ModuloInteger(v, 2) == 1 then
            call UnitAddAbility(u, 'Sp0L')
            call SetUnitAbilityLevel(u, 'Sp0L', b + 2)
            call UnitRemoveAbility(u, 'Sp0L')
        endif
        set v = v / 2
        set b = b + 1
    endloop
    call SetWidgetLife(u, vida * GetUnitState(u, UNIT_STATE_MAX_LIFE) / hp)
    call UnitAddAbility(u, 'Sp0M')
    call SetUnitAbilityLevel(u, 'Sp0M', IMaxBJ(1, IMinBJ(60, R2I(Sup_Base(id) * (m - 1.) + 0.5))))
''', '''    // Vida: 'ALh0'..'ALhA' del mapa (+10·2^b al añadir; al quitarlas en el nivel 2 se resta 0), en pasos de 10.
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
    call SetWidgetLife(u, vida * GetUnitState(u, UNIT_STATE_MAX_LIFE) / hp)
    call UnitAddAbility(u, 'SpM0')
    set dano = R2I(Sup_Base(id) * (m - 1.) + 0.5)
''')
una('''    local real vida
    local unit u
    local unit e = null
''', '''    local real vida
    local integer dano
    local unit u
    local unit e = null
''')
una('''        set v = Sup_Valor(t, r)
        if t == 0 then
            set v = IMaxBJ(1, IMinBJ(100, v / 2))
            set Sup_Val[i * 2 + k] = 2 * v
        else
            if t == 4 then
                set v = IMinBJ(50, v)
            endif
            set v = IMaxBJ(1, IMinBJ(100, v))
            set Sup_Val[i * 2 + k] = v
        endif
        call UnitAddAbility(u, Sup_StHab[t])
        call SetUnitAbilityLevel(u, Sup_StHab[t], v)
        set k = k + 1
    endloop
''', '''        set v = IMaxBJ(1, Sup_Valor(t, r))
        if t == 0 then
            set v = IMinBJ(255 - dano, v)
            set dano = dano + v
        elseif t == 2 or t == 4 then
            // Evasión y robo de vida: una habilidad de un nivel por tramo de 5 % (5-50), redondeado.
            set v = IMinBJ(10, IMaxBJ(1, (v + 2) / 5))
            call UnitAddAbility(u, Sup_StHab[t] + v - 1)
            set v = 5 * v
        elseif t == 6 then
            call SetUnitMoveSpeed(u, GetUnitMoveSpeed(u) + v)
        else
            set v = IMinBJ(127, v)
            call Sup_Bits(u, Sup_StHab[t], v, 7)
        endif
        set Sup_Val[i * 2 + k] = v
        set k = k + 1
    endloop
    call Sup_Bits(u, 'SpD0', dano, 8)
''')

if prueba:
    una('''    call Sup_Anotar("r" + I2S(r) + " super " + I2S(i) + " " + UnitId2String(id) + " de " + I2S(n) + " candidatos; x" + R2SW(m, 1, 2) + " vida " + R2SW(hp, 1, 0) + "->" + R2SW(GetUnitState(u, UNIT_STATE_MAX_LIFE), 1, 0) + " (" + R2SW(GetWidgetLife(u), 1, 0) + ") dano+" + I2S(GetUnitAbilityLevel(u, 'Sp0M'))''',
        '''    call Sup_Anotar("r" + I2S(r) + " super " + I2S(i) + " " + UnitId2String(id) + " de " + I2S(n) + " candidatos; x" + R2SW(m, 1, 2) + " vida " + R2SW(hp, 1, 0) + "->" + R2SW(GetUnitState(u, UNIT_STATE_MAX_LIFE), 1, 0) + " (" + R2SW(GetWidgetLife(u), 1, 0) + ") dano total+" + I2S(dano) + " bits " + I2S(Sup_Hay(u, 'SpD0', 8)) + " armadura " + I2S(Sup_Hay(u, 'SpA0', 7)) + " velataque " + I2S(Sup_Hay(u, 'SpS0', 7)) + " regen " + I2S(Sup_Hay(u, 'SpR0', 7)) + " velmov " + R2SW(GetUnitMoveSpeed(u), 1, 0)''')
    una('''function Sup_Bits takes unit u''', '''// v17v-prueba: suma de los bits que la unidad tiene puestos, para comprobar Sup_Bits.
function Sup_Hay takes unit u, integer base, integer nb returns integer
    local integer b = 0
    local integer s = 0
    local integer f = 1
    loop
        exitwhen b >= nb
        if GetUnitAbilityLevel(u, base + b) > 0 then
            set s = s + f
        endif
        set f = f * 2
        set b = b + 1
    endloop
    return s
endfunction

function Sup_Bits takes unit u''')
    una('call PreloadGenEnd("lat\\\\v17u-super.txt")', 'call PreloadGenEnd("lat\\\\v17v-super.txt")')
    una('call PreloadGenEnd("lat\\\\v17u-cuadros.txt")', 'call PreloadGenEnd("lat\\\\v17v-cuadros.txt")')

assert "'Sp0" not in j and 'SetUnitAbilityLevel(u, Sup_StHab' not in j
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17v: súper élite por bits' + (' + registro' if prueba else ''))
