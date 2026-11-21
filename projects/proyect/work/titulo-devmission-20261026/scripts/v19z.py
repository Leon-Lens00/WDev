#!/usr/bin/env python3
"""v19z (19/11/2026), fase 7 del plan devmission-v20-mutaciones-rachas-mvp.md: primera mejora rara de habilidad.
- Carta rara 85 "Shuriken triple" (Naruto, con RasenShuriken aprendido; una vez): el RasenShuriken sale con 2 shuriken
  más que giran alrededor del principal, se cierran sobre él a medida que avanza y llegan al mismo destino. Cada
  extra hace la mitad del daño del principal una vez por enemigo durante el vuelo; al juntarse en la explosión, la
  explosión hace +50 % de daño.
- Sólo sale en los pulls de racha (no en first blood ni en las tiradas normales), en la cuarta casilla y siempre con
  calidad T5: 45 / 60 / 75 % según la calidad mínima del pull (T2 / T3 / T4). También tras refrescar ese paso.
- Etiqueta "Rara" dorada; icono el de la técnica (Cua_Tex[60]).
- El RasenShuriken de D.O.N es de una sola instancia (globales NaV_*), así que los extras también: Rs_Lanzar,
  Rs_Paso (cada tick del motor NaV_kB, 0,04 s) y Rs_Quitar.
- Prueba: se anota cada lanzamiento triple y los golpes de los extras.
Uso: v19z.py ENTRADA.j SALIDA.j [prueba]   (normal de v19y; prueba de v19y-prueba)
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
cambia('string Her_PullLog = ""\n', '''string Her_PullLog = ""
// v19z: mejoras raras de habilidad. RasenShuriken triple (una instancia, como NaV_*).
boolean array Rara_Rs
boolean Rs_On = false
unit array Rs_U
real Rs_Ang = 0.
real Rs_R = 0.
integer Rs_Fin = 0
real Rs_Mult = 1.
integer Rs_Golpes = 0
group Rs_Grupo = null
''')

# --- extras del RasenShuriken (antes de NaF_Fg7, que lanza, y de NaF_Fl7, el motor) ---
cambia('function NaF_Fg7 takes nothing returns nothing\n', '''// v19z: Shuriken triple.
function Rs_Quitar takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 1
        if Rs_U[i] != null then
            call RemoveUnit(Rs_U[i])
            set Rs_U[i] = null
        endif
        set i = i + 1
    endloop
    set Rs_On = false
endfunction

function Rs_Filtro takes nothing returns boolean
    local unit u = GetFilterUnit()
    local boolean b = UnitAlive(u) and IsUnitEnemy(u, GetOwningPlayer(NaV_s8[5140])) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitInGroup(u, Rs_Grupo)
    set u = null
    return b
endfunction

function Rs_Lanzar takes nothing returns nothing
    local integer p = GetPlayerId(GetOwningPlayer(NaV_s8[5140]))
    local integer i = 0
    call Rs_Quitar()
    set Rs_Mult = 1.
    if p < 0 or p > 11 or not Rara_Rs[p] or NaV_s8[5141] == null then
        return
    endif
    if Rs_Grupo == null then
        set Rs_Grupo = CreateGroup()
    endif
    call GroupClear(Rs_Grupo)
    loop
        exitwhen i > 1
        set Rs_U[i] = CreateUnit(GetOwningPlayer(NaV_s8[5140]), 'h0D2', GetUnitX(NaV_s8[5141]), GetUnitY(NaV_s8[5141]), GetUnitFacing(NaV_s8[5141]))
        call SetUnitTimeScalePercent(Rs_U[i], 70.)
        call SetUnitPathing(Rs_U[i], false)
        call SetUnitScalePercent(Rs_U[i], 1., 1., 1.)
        set i = i + 1
    endloop
    set Rs_Ang = GetUnitFacing(NaV_s8[5141]) + 90.
    set Rs_R = 0.
    set Rs_Fin = 0
    set Rs_On = true
endfunction

function Rs_Paso takes nothing returns nothing
    local real x
    local real y
    local real r
    local real a
    local real s
    local integer i = 0
    local group g
    local unit u
    if not Rs_On then
        return
    endif
    if NaV_s8[5141] == null or Rs_U[0] == null then
        call Rs_Quitar()
        return
    endif
    set x = GetUnitX(NaV_s8[5141])
    set y = GetUnitY(NaV_s8[5141])
    if not NaV_o8[5140] then
        // En vuelo: el radio se cierra de 260 a 40 en los 50 pasos del principal.
        set r = 40. + 220. * (1. - I2R(IMinBJ(50, NaV_n8[5140])) / 50.)
        set Rs_R = r
        set s = 0.8 * I2R(IMinBJ(50, NaV_n8[5140]))
    else
        // Explosión: los extras se juntan con el principal en 6 pasos (0,24 s).
        set Rs_Fin = Rs_Fin + 1
        set r = Rs_R * (1. - I2R(Rs_Fin) / 6.)
        set s = 40.
    endif
    set Rs_Ang = Rs_Ang + 24.
    set g = CreateGroup()
    loop
        exitwhen i > 1
        set a = (Rs_Ang + 180. * i) * bj_DEGTORAD
        call SetUnitX(Rs_U[i], RMaxBJ(GetRectMinX(bj_mapInitialPlayableArea), RMinBJ(GetRectMaxX(bj_mapInitialPlayableArea), x + r * Cos(a))))
        call SetUnitY(Rs_U[i], RMaxBJ(GetRectMinY(bj_mapInitialPlayableArea), RMinBJ(GetRectMaxY(bj_mapInitialPlayableArea), y + r * Sin(a))))
        call SetUnitScalePercent(Rs_U[i], s, s, s)
        if not NaV_o8[5140] then
            call GroupEnumUnitsInRange(g, GetUnitX(Rs_U[i]), GetUnitY(Rs_U[i]), 150., Condition(function Rs_Filtro))
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g, u)
                call GroupAddUnit(Rs_Grupo, u)
                call UnitDamageTargetBJ(NaV_s8[5140], u, 0.5 * I2R(NaV_Se[5140]), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL)
                call DestroyEffect(AddSpecialEffectTarget("war3mapImported\\\\BloodEX2.mdx", u, "chest"))
                set Rs_Golpes = Rs_Golpes + 1
            endloop
        endif
        set i = i + 1
    endloop
    call DestroyGroup(g)
    set g = null
    if NaV_o8[5140] and Rs_Fin >= 6 then
        call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Human\\\\Thunderclap\\\\ThunderClapCaster.mdl", x, y))
        set Rs_Mult = 1.5
        call Rs_Quitar()
    endif
endfunction

function NaF_Fg7 takes nothing returns nothing
''')
cambia('''call EnableTrigger(NaV_kB)
call Don_Motor(NaV_kB,.04)
''', '''call EnableTrigger(NaV_kB)
call Don_Motor(NaV_kB,.04)
call Rs_Lanzar()
''')
cambia('''function NaF_Fl7 takes nothing returns nothing
if(NaF_FI7())then
''', '''function NaF_Fl7 takes nothing returns nothing
call Rs_Paso()
if(NaF_FI7())then
''')
cambia('call UnitDamageTargetBJ(NaV_s8[5140],GetEnumUnit(),(I2R(Na_Stat(0))/12.),',
       'call UnitDamageTargetBJ(NaV_s8[5140],GetEnumUnit(),(I2R(Na_Stat(0))/12.)*Rs_Mult,')
# Al terminar la explosión, la siguiente vuelve al daño normal.
cambia('''call StopSoundBJ(NaV_fo,false)
call StopSoundBJ(NaV_ym,false)
''', '''call StopSoundBJ(NaV_fo,false)
call StopSoundBJ(NaV_ym,false)
call Rs_Quitar()
set Rs_Mult = 1.
''')

# --- carta ---
cambia('''// v19y: 4 cartas de un pull extra''', '''// v19z: carta rara disponible para p (0 si ninguna).
function Rara_Carta takes integer p returns integer
    call Tec_Rango(p)
    if Tec_A == 57 and Tec_Niv[p * 100 + 60] > 0 and not Rara_Rs[p] then
        return 85
    endif
    return 0
endfunction

// v19z: en un pull de racha, la cuarta carta puede ser la rara (T5): 30 + 15 por calidad mínima (T2 = 1).
function Rara_Poner takes integer p, integer k, integer minq returns nothing
    local integer x = Rara_Carta(p)
    if x > 0 and GetRandomInt(1, 100) <= 30 + 15 * minq then
        set Cua_HCand[k + 3] = x
        set Her_Cal[k + 3] = 4
        set Her_Tipo[k + 3] = -1
    endif
endfunction

// v19y: 4 cartas de un pull extra''')
cambia('''                call Her_CartasExtra(p, p * 40 + (2 + Her_Extra[p]) * 5, q)
''', '''                call Her_CartasExtra(p, p * 40 + (2 + Her_Extra[p]) * 5, q)
                call Rara_Poner(p, p * 40 + (2 + Her_Extra[p]) * 5, q)
''')
cambia('''        call Her_CartasExtra(p, Her_K(p, 0), Her_ExMin[p * 8 + Cua_Paso[p] - 5])
''', '''        call Her_CartasExtra(p, Her_K(p, 0), Her_ExMin[p * 8 + Cua_Paso[p] - 5])
        if not (Her_ExFB[p] and Cua_Paso[p] == 5) then
            call Rara_Poner(p, Her_K(p, 0), Her_ExMin[p * 8 + Cua_Paso[p] - 5])
        endif
''')
cambia('''    set Cua_Tex[84] = 'DC0S'
''', '''    set Cua_Tex[84] = 'DC0S'
    // v19z: rara de habilidad.
    set Cua_Nom[85] = "Shuriken triple"
    set Cua_Des[85] = "RasenShuriken|nlanza 3."
    set Cua_Tex[85] = Cua_Tex[60]
''')
cambia('''    elseif x == 83 or x == 84 then
        return "|cffff7070Arma|r|n"''', '''    elseif x == 83 or x == 84 then
        return "|cffff7070Arma|r|n"
    elseif x == 85 then
        return "|cffffc83cRara|r|n"''')
cambia('''    elseif x == 83 or x == 84 then
        set Her_R = 255
        set Her_G = 112
        set Her_B = 112''', '''    elseif x == 83 or x == 84 then
        set Her_R = 255
        set Her_G = 112
        set Her_B = 112
    elseif x == 85 then
        set Her_R = 255
        set Her_G = 200
        set Her_B = 60''')
cambia('''    elseif x == 83 then
        return Her_Txt + "+" + I2S(v) + " % de daño|nde " + Her_TipoTxt + "."''', '''    elseif x == 85 then
        return Her_Txt + "2 shuriken más giran y|nexplosión +50 %."
    elseif x == 83 then
        return Her_Txt + "+" + I2S(v) + " % de daño|nde " + Her_TipoTxt + "."''', 2)
cambia('''    elseif x == 83 or x == 84 then
        // v19y: tipo de arma''', '''    elseif x == 85 then
        set Rara_Rs[p] = true
    elseif x == 83 or x == 84 then
        // v19y: tipo de arma''')

if prueba:
    cambia('''call Rs_Quitar()
set Rs_Mult = 1.
''', '''call Bolsa_Anotar("rasen triple " + I2S(IntegerTertiaryOp(Rs_Mult > 1., 1, 0)) + " golpes extra " + I2S(Rs_Golpes))
set Rs_Golpes = 0
call Rs_Quitar()
set Rs_Mult = 1.
''')
    for viejo, nuevo in (('lat\\\\v19y-', 'lat\\\\v19z-'), ('v19y-don.txt', 'v19z-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19z', 'prueba' if prueba else 'normal')
