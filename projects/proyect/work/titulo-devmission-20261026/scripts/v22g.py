#!/usr/bin/env python3
"""v22g (23/11/2026): la E de Vegito admite varias a la vez (hasta 6): la del botón y las de Afterimage.

Leon tras v22f: "no soporta instancias verdad? ejemplo la pasiva lanzo E, y si yo lanzo E manual ese ya no se lanza,
deberian poder ejecutarse mas independientes, 2-3 o mas".
- En 2.1a la E (G2F_spiritsword, 2 y 3) guarda todo en G2V_Caster[$B4]/[$B5], G2V_Point[$B4..$BC] y G2V_Int, y la
  mueven dos disparadores periódicos (0,12 y 0,04 s): una sola a la vez. Dcp_Ocupada y Don_EnCurso('A03F') bloqueaban
  la segunda.
- Ahora Vte_Inicio (acción de G2T_spiritsword) toma una de 6 ranuras (Vte_*) y un solo reloj de 0,04 s (Vte_Tick)
  lleva cada E: agarre (0,1 s + 1 s), arrastre (16 pasos de 0,12 s, 45), empuje (40 pasos de 0,04 s, 12), golpe final
  (550, daño completo) y cierre (1 s + 0,3 s). Mismos efectos, piezas, sonidos, temblor y deslizamientos que 2.1a y
  v22f; el golpe del recorrido (200, mitad, una vez a cada enemigo) por instancia. Al despausar la copia, "stop".
- Dcp_Ocupada('A03F') sólo bloquea con las 6 ranuras ocupadas; Don_EnCurso('A03F') = alguna E en curso;
  Afterimage ya no espera a que acabe otra E.
- G2F_spiritsword2/3 quedan sin usar (nadie los activa).
Registro (sólo prueba): "vegito E ranura N activas M", "vegito E sin ranura".
Uso: v22g.py ENTRADA.j SALIDA.j [prueba]   (normal de v22f; prueba de v22f-prueba).
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


def reg(texto):
    """Línea de registro sólo en prueba (texto es una expresión JASS de cadena)."""
    if not prueba:
        return ''
    return '        set Cop_Log = ' + texto + '\n        call ExecuteFunc("Cop_Anotar")\n'


cambia('boolean Vt_EDeAfter=false\n', '''boolean Vt_EDeAfter=false
// v22g: E de Vegito por ranuras (1-6). Vte_F: 0 libre, 1 agarre, 2 arrastre, 3 empuje, 4 cierre.
unit array Vte_C
unit array Vte_T
integer array Vte_F
integer array Vte_N
integer array Vte_Acc
boolean array Vte_Ag
real array Vte_Ang
real array Vte_X
real array Vte_Y
integer array Vte_K
real array Vte_B
integer array Vte_S
group array Vte_G
effect array Vte_E1
effect array Vte_E2
timer Vte_Reloj=null
boolean Vte_Corre=false
integer Vte_Activas=0
''')

suma = '                call Gk_Suma(Vte_S[i], Vte_K[i], c, u, d)\n' if prueba else ''
codigo = '''// v22g: E de Vegito por ranuras (varias a la vez). Mismos pasos que G2F_spiritsword, 2 y 3 de 2.1a.
function Vte_Pos takes integer i returns nothing
    if GetUnitTypeId(Vte_T[i]) != 0 then
        set Vte_X[i] = GetUnitX(Vte_T[i])
        set Vte_Y[i] = GetUnitY(Vte_T[i])
    endif
endfunction
function Vte_Recorrido takes integer i returns nothing
    call Fz_Area(Vte_C[i], Vte_X[i], Vte_Y[i], 200., 0.5 * Gk_TDano(Vte_C[i], Vte_K[i], Vte_B[i]), Vte_G[i], Vte_S[i], Vte_K[i])
endfunction
// Arrastre (spiritsword2): cada 0,12 s el blanco avanza 45; tras el agarre Vegito salta a él y golpea.
function Vte_Paso2 takes integer i returns nothing
    local unit c = Vte_C[i]
    local unit u
    local real nx
    local real ny
    set Vte_N[i] = Vte_N[i] + 1
    call Vte_Pos(i)
    set nx = Vte_X[i] + 45. * Cos(Vte_Ang[i] * bj_DEGTORAD)
    set ny = Vte_Y[i] + 45. * Sin(Vte_Ang[i] * bj_DEGTORAD)
    call SetUnitPosition(Vte_T[i], nx, ny)
    if not Vte_Ag[i] then
        call SetUnitPosition(c, Vte_X[i], Vte_Y[i])
        call Son_DONSuena(G2S_RockHeavyBashFlesh1, 6)
        call PlaySoundOnUnitBJ(G2S_teleport2, 50., c)
        call CreateUnit(GetOwningPlayer(c), 'h00T', nx, ny, Vte_Ang[i])
        call DestroyEffect(AddSpecialEffectTarget("war3mapImported\\\\EFFECT2.mdx", c, "right hand"))
        call SetUnitAnimation(c, "attack")
    endif
    call Vte_Recorrido(i)
    if Vte_N[i] >= 16 then
        call Son_DONSuena(G2S_RockHeavyBashFlesh3, 6)
        call PlaySoundOnUnitBJ(G2S_strongkick, 80., c)
        call CreateUnit(GetOwningPlayer(c), 'h00T', nx, ny, Vte_Ang[i])
        call SetUnitTimeScale(c, .35)
        call SetUnitAnimation(Vte_T[i], "death")
        call SetUnitAnimation(c, "attack slam")
        call UnitAddAbility(c, 'A0BX')
        set Vte_E1[i] = AddSpecialEffectTarget("Abilities\\\\Spells\\\\NightElf\\\\Rejuvenation\\\\RejuvenationTarget.mdl", c, "origin")
        set Vte_E2[i] = AddSpecialEffectTarget("Abilities\\\\Spells\\\\NightElf\\\\Rejuvenation\\\\RejuvenationTarget.mdl", c, "right hand")
        set Vte_N[i] = 0
        set Vte_F[i] = 3
    endif
    set c = null
    set u = null
endfunction
// Empuje (spiritsword3): cada 0,04 s el blanco se aleja 12 de Vegito; a los 40 pasos, golpe final en 550.
function Vte_Paso3 takes integer i returns nothing
    local unit c = Vte_C[i]
    local unit u
    local real a
    local real x
    local real y
    local real d
    local group g
    local location L
    set Vte_N[i] = Vte_N[i] + 1
    call Vte_Pos(i)
    set a = Atan2(Vte_Y[i] - GetUnitY(c), Vte_X[i] - GetUnitX(c))
    call SetUnitPosition(Vte_T[i], Vte_X[i] + 12. * Cos(a), Vte_Y[i] + 12. * Sin(a))
    call DestroyEffect(AddSpecialEffectTarget("war3mapImported\\\\DivineRage.mdx", c, "right hand"))
    call DestroyEffect(AddSpecialEffectTarget("Objects\\\\Spawnmodels\\\\Human\\\\HumanBlood\\\\HumanBloodLarge0.mdl", Vte_T[i], "chest"))
    call Vte_Recorrido(i)
    if Vte_N[i] >= 40 then
        set x = Vte_X[i]
        set y = Vte_Y[i]
        set L = Location(x, y)
        set G2V_CameraGroup = GetUnitsInRangeOfLocMatching(1500., L, Condition(function G2F_spiritsword3_Func011Func005002003))
        call ForGroupBJ(G2V_CameraGroup, function G2F_spiritsword3_Func011Func006A)
        call DestroyGroup(G2V_CameraGroup)
        set d = Gk_TDano(c, Vte_K[i], Vte_B[i])
        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, x, y, 550., null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if UnitAlive(u) and IsUnitEnemy(u, GetOwningPlayer(c)) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                call UnitDamageTarget(c, u, d, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
''' + suma + '''            endif
        endloop
        call DestroyGroup(g)
        set g = null
        call DestroyEffect(AddSpecialEffectTarget("war3mapImported\\\\OrcSmallDeathExplode.mdx", Vte_T[i], "chest"))
        call DestroyEffect(AddSpecialEffectTarget("Objects\\\\Spawnmodels\\\\Human\\\\HumanBlood\\\\HumanBloodLarge0.mdl", Vte_T[i], "chest"))
        call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Human\\\\ThunderClap\\\\ThunderClapCaster.mdl", x, y))
        call SetUnitPosition(c, x + 50. * Cos(Vte_Ang[i] * bj_DEGTORAD), y + 50. * Sin(Vte_Ang[i] * bj_DEGTORAD))
        call CreateNUnitsAtLoc(1, 'h052', GetOwningPlayer(c), L, .0)
        call SetUnitScalePercent(bj_lastCreatedUnit, 150., 150., 150.)
        call SetUnitTimeScalePercent(bj_lastCreatedUnit, 65.)
        set bj_forLoopAIndex = 1
        loop
            exitwhen bj_forLoopAIndex > 10
            call CreateNUnitsAtLoc(1, 'h0D3', GetOwningPlayer(c), L, GetRandomReal(0, 360))
            call UnitApplyTimedLifeBJ(.2, 'BTLF', bj_lastCreatedUnit)
            call SetUnitVertexColorBJ(bj_lastCreatedUnit, 40., 50., 90., 89.)
            call SetUnitTimeScalePercent(bj_lastCreatedUnit, GetRandomReal(15., 45.))
            call SetUnitScalePercent(bj_lastCreatedUnit, GetRandomReal(150., 330.), GetRandomReal(150., 330.), GetRandomReal(150., 330.))
            set bj_forLoopAIndex = bj_forLoopAIndex + 1
        endloop
        call CreateNUnitsAtLoc(1, 'h01B', GetOwningPlayer(c), L, GetRandomReal(0, 360))
        call SetUnitTimeScalePercent(bj_lastCreatedUnit, 125.)
        call CreateNUnitsAtLoc(1, 'h01B', GetOwningPlayer(c), L, GetRandomReal(0, 360))
        call SetUnitTimeScalePercent(bj_lastCreatedUnit, 125.)
        call CreateNUnitsAtLoc(1, 'h0DM', GetOwningPlayer(c), L, GetRandomReal(0, 360))
        call SetUnitScalePercent(bj_lastCreatedUnit, 250., 250., 250.)
        call SetUnitTimeScalePercent(bj_lastCreatedUnit, 75.)
        call CreateNUnitsAtLoc(1, 'h0DM', GetOwningPlayer(c), L, GetRandomReal(0, 360))
        call SetUnitScalePercent(bj_lastCreatedUnit, 250., 250., 250.)
        call SetUnitTimeScalePercent(bj_lastCreatedUnit, 75.)
        call CreateNUnitsAtLoc(1, 'h070', GetOwningPlayer(c), L, GetRandomReal(0, 360))
        call SetUnitTimeScalePercent(bj_lastCreatedUnit, 300.)
        call CreateNUnitsAtLoc(1, 'h0CB', GetOwningPlayer(c), L, GetRandomReal(0, 360))
        call SetUnitScalePercent(bj_lastCreatedUnit, 300., 300., 300.)
        // Deslizamientos de 2.1a: sus funciones leen G2V_Caster[$B4] y G2V_Point[$B7] (sólo durante esta llamada).
        set G2V_Caster[$B4] = c
        set G2V_Point[$B7] = L
        set bj_forLoopAIndex = 1
        loop
            exitwhen bj_forLoopAIndex > 15
            set G2V_Group[$B4] = GetRandomSubGroup(1, GetUnitsInRangeOfLocMatching(400., L, Condition(function G2F_spiritsword3_Func011Func038Func001002002003)))
            call ForGroupBJ(G2V_Group[$B4], function G2F_spiritsword3_Func011Func038Func002A)
            call DestroyGroup(G2V_Group[$B4])
            set bj_forLoopAIndex = bj_forLoopAIndex + 1
        endloop
        call GroupClear(G2V_Group3[67])
        set G2V_Caster[$B4] = null
        set G2V_Point[$B7] = null
        call RemoveLocation(L)
        set L = null
        set Vte_N[i] = 0
        set Vte_F[i] = 4
    endif
    set c = null
    set u = null
endfunction
// Cierre: a 1 s se quitan efectos y temblor y se suelta la copia (con "stop"); a 1,3 s se libera la ranura.
function Vte_Paso4 takes integer i returns nothing
    set Vte_N[i] = Vte_N[i] + 1
    if Vte_N[i] == 25 then
        call DestroyEffect(Vte_E1[i])
        call DestroyEffect(Vte_E2[i])
        set Vte_E1[i] = null
        set Vte_E2[i] = null
        call ForForce(bj_FORCE_ALL_PLAYERS, function G2F_spiritsword3_Func011Func043A)
        call PauseUnit(Vte_C[i], false)
        call IssueImmediateOrderById(Vte_C[i], 851972)
        call UnitRemoveAbility(Vte_C[i], 'A0BX')
    elseif Vte_N[i] >= 33 then
        set Vte_F[i] = 0
        set Vte_C[i] = null
        set Vte_T[i] = null
        call GroupClear(Vte_G[i])
        set Vte_Activas = Vte_Activas - 1
    endif
endfunction
function Vte_Tick takes nothing returns nothing
    local integer i = 1
    local integer n = 0
    loop
        exitwhen i > 6
        if Vte_F[i] == 2 then
            set Vte_Acc[i] = Vte_Acc[i] + 1
            if Vte_Acc[i] >= 3 then
                set Vte_Acc[i] = 0
                call Vte_Paso2(i)
            endif
        elseif Vte_F[i] == 3 then
            call Vte_Paso3(i)
        elseif Vte_F[i] == 4 then
            call Vte_Paso4(i)
        endif
        if Vte_F[i] != 0 then
            set n = n + 1
        endif
        set i = i + 1
    endloop
    if n == 0 then
        call PauseTimer(Vte_Reloj)
        set Vte_Corre = false
    endif
endfunction
// Acción de G2T_spiritsword (A03F): agarre en este hilo; el resto, Vte_Tick.
function Vte_Inicio takes nothing returns nothing
    local unit c = GetSpellAbilityUnit()
    local unit t = GetSpellTargetUnit()
    local integer i = 1
    local real tx
    local real ty
    local real f
    local location L
    loop
        exitwhen i > 6 or Vte_F[i] == 0
        set i = i + 1
    endloop
    if i > 6 or t == null then
''' + reg('"vegito E sin ranura"') + '''        set c = null
        set t = null
        return
    endif
    set Vte_F[i] = 1
    set Vte_C[i] = c
    set Vte_T[i] = t
    set Vte_X[i] = GetUnitX(t)
    set Vte_Y[i] = GetUnitY(t)
    set Vte_Activas = Vte_Activas + 1
    if Vte_G[i] == null then
        set Vte_G[i] = CreateGroup()
    endif
    call GroupClear(Vte_G[i])
    call GroupAddUnit(Vte_G[i], t)
    // v22f: la E de la copia de Afterimage usa la técnica 104 (1500); la del botón, la 101 (2500).
    if Vt_EDeAfter and GetUnitTypeId(c) == 'hCpW' then
        set Vte_K[i] = 104
        set Vte_B[i] = 1500.
        set Vte_S[i] = 27
    else
        set Vte_K[i] = 101
        set Vte_B[i] = 2500.
        set Vte_S[i] = 25
    endif
''' + reg('"vegito E ranura " + I2S(i) + " activas " + I2S(Vte_Activas)') + '''    call TriggerSleepAction(.1)
    call PauseUnit(c, true)
    call SetUnitFacingToFaceUnitTimed(t, c, 0)
    call Vte_Pos(i)
    set tx = Vte_X[i]
    set ty = Vte_Y[i]
    set Vte_Ang[i] = bj_RADTODEG * Atan2(ty - GetUnitY(c), tx - GetUnitX(c))
    call DestroyEffect(AddSpecialEffect("war3mapImported\\\\BlackBlink.mdx", GetUnitX(c), GetUnitY(c)))
    set f = GetUnitFacing(t) * bj_DEGTORAD
    call SetUnitPosition(c, tx + 80. * Cos(f), ty + 80. * Sin(f))
    call SetUnitAnimation(c, "Spell Slam Swim")
    call SetUnitAnimation(t, "death")
    call PlaySoundOnUnitBJ(G2S_teleport2, 50., c)
    call SetUnitTimeScale(c, 1.5)
    call Son_DONSuena(G2S_RockHeavyBashFlesh1, 6)
    call PlaySoundOnUnitBJ(G2S_strongkick, 80., c)
    call SetUnitTimeScale(CreateUnit(GetOwningPlayer(c), 'h00T', tx, ty, Vte_Ang[i]), .5)
    call DestroyEffect(AddSpecialEffectTarget("Objects\\\\Spawnmodels\\\\Human\\\\HumanBlood\\\\HumanBloodLarge0.mdl", t, "chest"))
    set Vte_N[i] = 0
    set Vte_Acc[i] = 0
    set Vte_Ag[i] = true
    set Vte_F[i] = 2
    if Vte_Reloj == null then
        set Vte_Reloj = CreateTimer()
    endif
    if not Vte_Corre then
        set Vte_Corre = true
        call TimerStart(Vte_Reloj, .04, true, function Vte_Tick)
    endif
    call TriggerSleepAction(1.)
    set L = Location(tx, ty)
    set G2V_CameraGroup = GetUnitsInRangeOfLocMatching(1500., L, Condition(function G2F_spiritsword_Func030002003))
    call ForGroupBJ(G2V_CameraGroup, function G2F_spiritsword_Func031A)
    call DestroyGroup(G2V_CameraGroup)
    call RemoveLocation(L)
    set L = null
    if Vte_C[i] == c then
        set Vte_Ag[i] = false
        call SetUnitTimeScale(c, 2.)
    endif
    set c = null
    set t = null
endfunction
'''
cambia('function G2F_Banshee_Blast_Conditions takes nothing returns boolean\n',
       codigo + 'function G2F_Banshee_Blast_Conditions takes nothing returns boolean\n')

cambia('call TriggerAddAction(G2T_spiritsword,function G2F_spiritsword_Actions)',
       'call TriggerAddAction(G2T_spiritsword,function Vte_Inicio)')

# Ocupada / en curso.
cambia('''function Dcp_Ocupada takes integer p, integer a returns boolean
    local integer i = 0
''', '''function Dcp_Ocupada takes integer p, integer a returns boolean
    local integer i = 0
    if a == 'A03F' then
        // v22g: la E de Vegito admite 6 a la vez (Vte_*): sólo se bloquea con todas las ranuras ocupadas.
        loop
            set i = i + 1
            exitwhen i > 6
            if Vte_F[i] == 0 then
                return false
            endif
        endloop
        return true
    endif
''')
cambia('''    elseif a == 'A03F' then
        return G2V_Caster[$B4] != null
''', '''    elseif a == 'A03F' then
        // v22g: alguna E de Vegito en curso.
        return Vte_Activas > 0
''')
cambia("            if GetRandomInt(1, 100) <= 25 and G2V_Caster[$B4] == null and not Dcp_Ocupada(p, 'A03F') then\n",
       "            if GetRandomInt(1, 100) <= 25 and not Dcp_Ocupada(p, 'A03F') then\n")

assert src.index('function Fz_Area ') < src.index('function Vte_Pos ')
assert src.index('function G2F_spiritsword3_Func011Func038Func002A ') < src.index('function Vte_Paso3 ')
assert src.index('function Vte_Inicio ') < src.index('call TriggerAddAction(G2T_spiritsword,function Vte_Inicio)')

if prueba:
    assert 'function Cop_Anotar' in src, 'Cop_Anotar en prueba'
    cambia('lat\\\\v22f-', 'lat\\\\v22g-', src.count('lat\\\\v22f-'))
    cambia('v22f-don.txt', 'v22g-don.txt', src.count('v22f-don.txt'))
    assert 'lat\\\\v22f-' not in src and 'v22f-don.txt' not in src, 'quedan registros v22f'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22g', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
