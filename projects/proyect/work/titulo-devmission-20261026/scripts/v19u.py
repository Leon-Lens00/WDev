#!/usr/bin/env python3
"""v19u (19/11/2026), fase 2 del plan devmission-v20-mutaciones-rachas-mvp.md: auditoría de mutaciones y mejoras.
Auditoría sobre v19t (tabla en el plan): las 18 mutaciones (0-17) tienen efecto en Mut_Aparece / Mut_Muere /
DevWave_Elite / DevJefe_Mirar / WaveAI__Init / DevWave_Start, y la -prueba ya anota sus unidades por oleada
(Mut_Anotar) y deja sumarlas con "-mut N". Las mejoras del héroe que salen en la tienda tienen consumidor, salvo una:
- Zancada (22) subía la velocidad nativa del héroe, pero el héroe lo mueve GroundMotion a 350 fijos: no hacía nada.
  Ahora suma a la velocidad de GroundMotion (Her_Zancada, que se vuelve a aplicar si cambia el cuerpo con -pj).
Caparazón espinoso (Leon: "con poca vida del jugador hace demasiado daño ... reducirlo o pasarlo a la baraja de
mejoras del enemigo"): era el aura nativa 'ANth', que además reparte espinas a todos los aliados cercanos.
- Sale de la tirada al azar de pasivas de súper élite y de Corona / Élite feroz (Sup_PaAzar: 0-6 sin el 3).
- La carta de Mutación Evo 13 "Caparazón" (tortugas +3 armadura y 'ANth') pasa a ser "Espinas": cada élite que sale
  con ella devuelve al héroe del jugador que la golpea el 8 % del daño por carta, con tope de 2 % de su vida máxima por
  golpe y 6 % por segundo, sin bajar nunca de 1 de vida (SetWidgetLife: no mata ni da crédito). Las tortugas conservan
  +3 de armadura por carta, sin aura.
- Cua_MuestraFin ya no dice "(aún sin efecto)".
- Prueba: Mut_Anotar añade lo devuelto por Espinas a cada jugador en la oleada; Her_Log, la velocidad de GroundMotion.
Uso: v19u.py ENTRADA.j SALIDA.j [prueba]   (normal de v19t; prueba de v19t-prueba)
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


# --- globales ---
cambia('integer array Mut_Cuenta\n', '''integer array Mut_Cuenta
// v19u: Espinas (Mutación Evo 13) y Zancada sobre GroundMotion.
trigger Esp_Tr = null
integer Esp_N = 0
real array Esp_T
real array Esp_Acum
real array Esp_Total
integer array Esp_Golpes
integer array Her_Zancada
''')

# --- pasivas al azar sin Caparazón espinoso ---
cambia('''function Sup_Init takes nothing returns nothing
''', '''// v19u: pasiva de súper élite al azar sin el 3 ('ANth', Caparazón espinoso: ahora es la carta Espinas).
function Sup_PaAzar takes nothing returns integer
    local integer r = GetRandomInt(0, 5)
    if r >= 3 then
        return r + 1
    endif
    return r
endfunction

function Sup_Init takes nothing returns nothing
''')
cambia('''    set Sup_Pa[i * 2] = GetRandomInt(0, 6)
    loop
        set t = GetRandomInt(0, 6)''', '''    set Sup_Pa[i * 2] = Sup_PaAzar()
    loop
        set t = Sup_PaAzar()''')
cambia('call UnitAddAbility(u, Sup_PaId[GetRandomInt(0, 6)])', 'call UnitAddAbility(u, Sup_PaId[Sup_PaAzar()])', 2)
# Pasivas de la animación de barajar (Sup_RT + 2 / + 3; la tirada final es Sup_Pa).
cambia('''        set t = GetRandomInt(0, 6)
        set Sup_RT[i * 48 + b * 4 + 2] = t
        set k = GetRandomInt(0, 5)
        if k >= t then
            set k = k + 1
        endif
        set Sup_RT[i * 48 + b * 4 + 3] = k''', '''        set t = Sup_PaAzar()
        set Sup_RT[i * 48 + b * 4 + 2] = t
        loop
            set k = Sup_PaAzar()
            exitwhen k != t
        endloop
        set Sup_RT[i * 48 + b * 4 + 3] = k''')
assert 'Sup_PaId[GetRandomInt' not in src

# v19t movió la baraja (Sup_Hud) pero no la posición con que la tirada crea los textos: el mismo alto desde el inicio.
cambia('R2SW(Sup_M[i], 1, 2), 30. - 420., 296., 0.017)', 'R2SW(Sup_M[i], 1, 2), 30. - 420., 561., 0.017)')
cambia('R2SW(m, 1, 2), 30. - 420., 296., 0.017)', 'R2SW(m, 1, 2), 30. - 420., 561., 0.017)')
cambia('s, 92. - 420., 345. + 62. * k - 11., 0.017)', 's, 92. - 420., 610. + 62. * k - 11., 0.017)')

# --- Espinas ---
cambia('''// v18x: efectos de la Mutación Evo al salir cada unidad de la wave (código común).
function Mut_Aparece takes nothing returns nothing''', '''// v19u: Espinas (Mutación Evo 13). La élite golpeada devuelve al héroe del dueño del golpe el 8 % por carta, con tope
// de 2 % de su vida máxima por golpe y 6 % por segundo; nunca baja de 1 de vida. Código común (daño sincronizado).
function Esp_Dano takes nothing returns nothing
    local unit s = GetEventDamageSource()
    local real d = GetEventDamage()
    local integer p
    local unit h
    local real m
    local real r
    local real ahora
    if s == null or d < 1. or Cua_Activa[13] <= 0 then
        set s = null
        return
    endif
    set p = GetPlayerId(GetOwningPlayer(s))
    set s = null
    if p < 0 or p > 11 or not Game_On[p] then
        return
    endif
    set h = Game_Hero[p]
    if h == null or not UnitAlive(h) or GetUnitAbilityLevel(h, 'Avul') > 0 then
        set h = null
        return
    endif
    set m = GetUnitState(h, UNIT_STATE_MAX_LIFE)
    set ahora = TimerGetElapsed(s__RapidPair_clock)
    if ahora - Esp_T[p] >= 1. or ahora < Esp_T[p] then
        set Esp_T[p] = ahora
        set Esp_Acum[p] = 0.
    endif
    set r = RMinBJ(0.08 * Cua_Activa[13] * d, 0.02 * m)
    set r = RMinBJ(r, 0.06 * m - Esp_Acum[p])
    set r = RMinBJ(r, GetWidgetLife(h) - 1.)
    if r >= 0.5 then
        if Esp_Acum[p] <= 0. then
            call DestroyEffect(AddSpecialEffectTarget("Abilities\\\\Spells\\\\NightElf\\\\ThornsAura\\\\ThornsAuraDamage.mdl", h, "chest"))
        endif
        set Esp_Acum[p] = Esp_Acum[p] + r
        set Esp_Total[p] = Esp_Total[p] + r
        set Esp_Golpes[p] = Esp_Golpes[p] + 1
        call SetWidgetLife(h, GetWidgetLife(h) - r)
    endif
    set h = null
endfunction

// v18x: efectos de la Mutación Evo al salir cada unidad de la wave (código común).
function Mut_Aparece takes nothing returns nothing''')
cambia('''    if id >= 'ne00' and id <= 'ne09' then
        set n = Cua_Activa[6]''', '''    if id >= 'ne00' and id <= 'ne09' then
        // v19u: Espinas.
        if Cua_Activa[13] > 0 then
            if Esp_Tr == null then
                set Esp_Tr = CreateTrigger()
                call TriggerAddAction(Esp_Tr, function Esp_Dano)
            endif
            call TriggerRegisterUnitEvent(Esp_Tr, u, EVENT_UNIT_DAMAGED)
            set Esp_N = Esp_N + 1
            set Mut_Cuenta[13] = Mut_Cuenta[13] + 1
        endif
        set n = Cua_Activa[6]''')
cambia('''        call BM_Add(u, 0, 3 * Cua_Activa[13])
        call UnitAddAbility(u, 'ANth')
''', '''        call BM_Add(u, 0, 3 * Cua_Activa[13])
''')
cambia('''    set Cua_Nom[13] = "Caparazón"
    set Cua_Des[13] = "Las tortugas ganan +3|nde armadura y espinas."''',
       '''    set Cua_Nom[13] = "Espinas"
    set Cua_Des[13] = "Las élites devuelven 8 %|ndel daño; tortugas +3 arm."''')

# Las élites de la oleada anterior ya no cuentan: se rehace el disparador antes de la siguiente.
cambia('''    set Mut_T = -1.
    loop
        exitwhen p > 11
        // v18q: la muestra abre la tienda''', '''    set Mut_T = -1.
    // v19u: disparador de Espinas nuevo para cada oleada (los eventos de unidades muertas no se borran solos).
    if Esp_Tr != null then
        call DestroyTrigger(Esp_Tr)
        set Esp_Tr = null
        set Esp_N = 0
    endif
    loop
        exitwhen p > 11
        // v18q: la muestra abre la tienda''')
cambia('"Mutación Evo (aún sin efecto): " + s)', '"Mutación Evo: " + s)')

# --- Zancada ---
cambia('''    elseif x == 22 and u != null then
        call SetUnitMoveSpeed(u, GetUnitMoveSpeed(u) + v)''', '''    elseif x == 22 and u != null then
        // v19u: el héroe lo mueve GroundMotion (350 fijos), no su velocidad nativa.
        call SetUnitMoveSpeed(u, GetUnitMoveSpeed(u) + v)
        set Her_Zancada[p] = Her_Zancada[p] + v
        if Game_Pair[p] != 0 then
            set s__GroundMotion_speed[s__RapidPair_motion[Game_Pair[p]]] = 350. + Her_Zancada[p]
        endif''')
cambia('''    set Game_Pair[p]=s__RapidPair_create(Game_Ctrl[p] , Game_Hero[p])
    call Arm_Pareja(p)''', '''    set Game_Pair[p]=s__RapidPair_create(Game_Ctrl[p] , Game_Hero[p])
    // v19u: Zancada sobrevive al cambio de cuerpo.
    set s__GroundMotion_speed[s__RapidPair_motion[Game_Pair[p]]] = 350. + Her_Zancada[p]
    call Arm_Pareja(p)''')
cambia('''" refrescos " + I2S(Her_Refrescos[p])
    set u = null''', '''" refrescos " + I2S(Her_Refrescos[p]) + " vel " + I2S(350 + Her_Zancada[p])
    set u = null''')

if prueba:
    cambia('''        set Mut_Cuenta[i] = 0
        set i = i + 1
    endloop
    call Bolsa_Anotar(s)
endfunction''', '''        set Mut_Cuenta[i] = 0
        set i = i + 1
    endloop
    // v19u-prueba: lo que Espinas quitó a cada héroe en la oleada.
    set i = 0
    loop
        exitwhen i > 11
        if Esp_Golpes[i] > 0 then
            set s = s + "; espinas j" + I2S(i) + " " + I2S(Esp_Golpes[i]) + " golpes " + I2S(R2I(Esp_Total[i])) + " de " + I2S(R2I(GetUnitState(Game_Hero[i], UNIT_STATE_MAX_LIFE)))
        endif
        set Esp_Golpes[i] = 0
        set Esp_Total[i] = 0.
        set i = i + 1
    endloop
    call Bolsa_Anotar(s)
endfunction''')
    for viejo, nuevo in (('lat\\\\v19t-', 'lat\\\\v19u-'), ('v19t-don.txt', 'v19u-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19u', 'prueba' if prueba else 'normal')
