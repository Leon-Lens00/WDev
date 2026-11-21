#!/usr/bin/env python3
"""v19b (18/11/2026): todas las habilidades del Tauren y de Cairne a la vez (Leon: "implementa todas para un test mas
rapido probando todas"). Sustituye el bloque de copias de v19a por un motor común; objetos en objetos_v19b.py.

Motor (un reloj de 0,03 s, hasta 200 piezas): copias ('hCp0' Tauren, 'hCp1' Cairne, 'hCp2' espíritu), proyectiles
('dumi' con modelo pegado y altura de vuelo), piezas sin unidad (grieta, estampida). Daño con fuente 'dumi' del jugador
(cuenta para él), Her_Dano, Dano_Ataque(6) y Barras_Golpe. Aturdir = PauseUnit con contador (128; no toca unidades ya
pausadas por otro); ralentizar = 50 % de la velocidad guardada (128); rayos con vida de 0,24 s (64).
Tauren: Embestida (v19a), Tótem arrojado, Lanzar roca, Bombardeo, Garra espiritual, Rugido desafiante; pasiva Disparo
encantado en Arm_Impacto (cada 4.º impacto ×3 y onda a 200).
Cairne: Grieta ancestral, Lanza ancestral, Espíritu ancestral, Estampida, Tótem del trueno, Marca ancestral; pasivas
Réplica (cada golpe principal aturde alrededor de Cairne y del golpe) y Espíritus guardianes (al reaparecer, vía
RapidPair_rise, y una vez por ronda bajo el 25 % de vida, comprobado cada 0,25 s).
Libros: 'h005' → 'ALTb', 'h006' → 'ALCb'.
Prueba: cada pieza principal anota al terminar "hab <nombre> jP golpes G dano D" (lat\\v19b-bolsas.txt).
Uso: v19b.py ENTRADA.j (de v19a) SALIDA.j [prueba]
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


# --- Quitar el bloque de v19a (funciones y registro); sus globales se reutilizan. ---
a = src.index(U('// v19a: copia espiritual. Las habilidades las hace una copia'))
b = src.index('function Don_Init takes nothing returns nothing')
viejo = src[a:b]
assert viejo.count('function Cop_') == 9 and 'Don_' not in viejo.replace('Don_Init', ''), viejo.count('function Cop_')
src = src[:a] + src[b:]

cambia('integer Emp_N = 0\n', 'integer Emp_N = 0\n'
       'effect array Cop_E\ninteger array Cop_T\nreal array Cop_SX\nreal array Cop_SY\nreal array Cop_TX\n'
       'real array Cop_TY\nreal array Cop_X\nreal array Cop_Y\nreal array Cop_H\ninteger array Cop_NT\n'
       'integer array Cop_Gen\nreal array Cop_V\nreal array Cop_D\nunit array Cop_Ob\nboolean Cop_Activo = false\n'
       'unit array Cop_FU\nreal Cop_oEmp = 0.\nboolean Cop_oLat = false\nreal Cop_oAtu = 0.\nreal Cop_oFre = 0.\n'
       'real Cop_oPct = 0.\nboolean Cop_oSeg = false\nreal Cop_oX2 = 0.\nreal Cop_oY2 = 0.\nboolean Cop_oTirar = false\n'
       'real Cop_oSuma = 0.\ngroup Cop_Marcados = null\nlocation Cop_Loc = null\n'
       'real Cop_HX = 0.\nreal Cop_HY = 0.\nreal Cop_PX = 0.\nreal Cop_PY = 0.\nreal Cop_LA = 0.\nreal Cop_LD = 0.\n'
       'integer array Bom_Golpes\nreal array Bom_Total\n'
       'unit array Atu_U\ninteger array Atu_K\neffect array Atu_E\ninteger Atu_N = 0\n'
       'unit array Fre_U\ninteger array Fre_K\nreal array Fre_V\ninteger Fre_N = 0\n'
       'lightning array Ray_L\ninteger array Ray_K\ninteger Ray_N = 0\n'
       'boolean array Gua_Rise\ninteger array Gua_Ronda\ninteger array Enc_K\ngroup Enc_Grupo = null\n')

# --- Disparo encantado (Tauren): en el impacto de cada bala. ---
cambia('''    function Arm_Impacto takes integer m,unit caster,unit target returns nothing
''', '''    // v19b: Disparo encantado del Tauren: onda del 4.º impacto, el daño de la bala a 200 alrededor del blanco.
    function Enc_Onda takes unit caster,player owner,unit target,real d,integer tipo returns nothing
        local real x= GetUnitX(target)
        local real y= GetUnitY(target)
        local boolean antes= s__GroundCollision_shaped
        local unit u
        if Enc_Grupo == null then
            set Enc_Grupo=CreateGroup()
        endif
        call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Human\\\\FlakCannons\\\\FlakTarget.mdl", x, y))
        set s__GroundCollision_shaped=true
        call GroupEnumUnitsInRange(Enc_Grupo, x, y, 328., null)
        loop
            set u=FirstOfGroup(Enc_Grupo)
            exitwhen u == null
            call GroupRemoveUnit(Enc_Grupo, u)
            if u != target and s__GroundCollision_isTarget(u , caster , owner) and s__GroundCollision_touches(u , x , y , 200.) then
                call UnitDamageTarget(caster, u, d, false, false, Dano_Ataque(tipo), Dano_TipoArma, null)
                call Barras_Golpe(caster, u)
            endif
        endloop
        set s__GroundCollision_shaped=antes
    endfunction

    function Arm_Impacto takes integer m,unit caster,unit target returns nothing
''')
cambia('''        set d=Her_Dano(GetPlayerId(s__RapidBolt_owner[m]) , d)
        call UnitDamageTarget(caster, target, d, false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)
''', '''        set d=Her_Dano(GetPlayerId(s__RapidBolt_owner[m]) , d)
        if GetUnitTypeId(Game_Hero[GetPlayerId(s__RapidBolt_owner[m])]) == 'h005' then
            set Enc_K[GetPlayerId(s__RapidBolt_owner[m])]=Enc_K[GetPlayerId(s__RapidBolt_owner[m])] + 1
            if Enc_K[GetPlayerId(s__RapidBolt_owner[m])] >= 4 then
                set Enc_K[GetPlayerId(s__RapidBolt_owner[m])]=0
                call Enc_Onda(caster , s__RapidBolt_owner[m] , target , d , Bala_Tipo[m])
                set d=d * 3.
            endif
        endif
        call UnitDamageTarget(caster, target, d, false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)
''')

# --- Espíritus guardianes: aviso al reaparecer. ---
cambia('''    set Vidas_Escudo[p] = AddSpecialEffectTarget(Vidas_FX, u, "origin")
''', '''    set Vidas_Escudo[p] = AddSpecialEffectTarget(Vidas_FX, u, "origin")
    // v19b: Espíritus guardianes de Cairne al reaparecer (los lanza Gua_Tick).
    set Gua_Rise[p] = GetUnitTypeId(u) == 'h006'
''')

M_TOTEM = 'units\\\\orc\\\\StasisTotem\\\\StasisTotem.mdl'
M_ROCA = 'Abilities\\\\Weapons\\\\AncientProtectorMissile\\\\AncientProtectorMissile.mdl'
M_LANZA = 'Abilities\\\\Weapons\\\\SpiritOfVengeanceMissile\\\\SpiritOfVengeanceMissile.mdl'
M_KODO = 'Abilities\\\\Spells\\\\Other\\\\Stampede\\\\StampedeMissile.mdl'
M_TRUENO = 'units\\\\orc\\\\HealingWard\\\\HealingWard.mdl'
FX = {
    'polvo': 'Objects\\\\Spawnmodels\\\\Undead\\\\ImpaleTargetDust\\\\ImpaleTargetDust.mdl',
    'pisoton': 'Abilities\\\\Spells\\\\Orc\\\\WarStomp\\\\WarStompCaster.mdl',
    'trueno': 'Abilities\\\\Spells\\\\Human\\\\Thunderclap\\\\ThunderClapCaster.mdl',
    'aturdido': 'Abilities\\\\Spells\\\\Human\\\\Thunderclap\\\\ThunderclapTarget.mdl',
    'rugido': 'Abilities\\\\Spells\\\\NightElf\\\\BattleRoar\\\\RoarCaster.mdl',
    'espiritu': 'Abilities\\\\Spells\\\\Orc\\\\AncestralSpirit\\\\AncestralSpiritCaster.mdl',
    'grieta': 'Abilities\\\\Spells\\\\Undead\\\\Impale\\\\ImpaleHitTarget.mdl',
    'rayo': 'Abilities\\\\Weapons\\\\Bolt\\\\BoltImpact.mdl',
    'marca': 'Abilities\\\\Spells\\\\Undead\\\\Curse\\\\CurseTarget.mdl',
    'explota': 'Objects\\\\Spawnmodels\\\\Other\\\\NeutralBuildingExplosion\\\\NeutralBuildingExplosion.mdl',
    'chispa': 'Abilities\\\\Spells\\\\Human\\\\FlakCannons\\\\FlakTarget.mdl',
    'cura': 'Abilities\\\\Spells\\\\Human\\\\Heal\\\\HealTarget.mdl',
}

COP = r'''// v19b: motor de copias de Tauren y Cairne. Leon (18/11/2026): todas las habilidades las hace una copia; el héroe
// sigue libre. Piezas: 1 Embestida, 2 Tótem arrojado, 3 Roca, 4 Garra, 5 Rugido, 6 Bombardeo, 7 piedra del Bombardeo,
// 8 gesto, 9 Grieta, 10 Lanza, 12 Espíritu ancestral, 13 Tótem del trueno, 14 Marca, 15 Estampida, 16 corredor.
function Cop_Nombre takes integer t returns string
    if t == 1 then
        return "embestida"
    elseif t == 2 then
        return "totem"
    elseif t == 3 then
        return "roca"
    elseif t == 4 then
        return "garra"
    elseif t == 5 then
        return "rugido"
    elseif t == 6 then
        return "bombardeo"
    elseif t == 9 then
        return "grieta"
    elseif t == 10 then
        return "lanza"
    elseif t == 12 then
        return "espiritu"
    elseif t == 13 then
        return "trueno"
    elseif t == 14 then
        return "marca"
    elseif t == 15 then
        return "estampida"
    elseif t == 16 then
        return "corredor"
    endif
    return "pieza" + I2S(t)
endfunction

function Cop_Fuente takes integer p returns unit
    if Cop_FU[p] == null or GetUnitTypeId(Cop_FU[p]) == 0 then
        set Cop_FU[p] = CreateUnit(Player(p), 'dumi', GetUnitX(Game_Hero[p]), GetUnitY(Game_Hero[p]), 0.)
    endif
    return Cop_FU[p]
endfunction

function Cop_Dentro takes real x, real y returns boolean
    return x > GetRectMinX(bj_mapInitialPlayableArea) + 64. and x < GetRectMaxX(bj_mapInitialPlayableArea) - 64. and y > GetRectMinY(bj_mapInitialPlayableArea) + 64. and y < GetRectMaxY(bj_mapInitialPlayableArea) - 64.
endfunction

function Cop_Z takes real x, real y returns real
    if Cop_Loc == null then
        set Cop_Loc = Location(x, y)
    endif
    call MoveLocation(Cop_Loc, x, y)
    return GetLocationZ(Cop_Loc)
endfunction

function Cop_Opc takes nothing returns nothing
    set Cop_oEmp = 0.
    set Cop_oLat = false
    set Cop_oAtu = 0.
    set Cop_oFre = 0.
    set Cop_oPct = 0.
    set Cop_oSeg = false
    set Cop_oTirar = false
endfunction

// Empujón de 5 pasos (0,15 s). Sin estructuras; se para en suelo no transitable.
function Cop_Empujar takes unit u, real ang, real dist returns nothing
    if Emp_N >= 128 or IsUnitType(u, UNIT_TYPE_STRUCTURE) then
        return
    endif
    set Emp_U[Emp_N] = u
    set Emp_VX[Emp_N] = dist / 5. * Cos(ang)
    set Emp_VY[Emp_N] = dist / 5. * Sin(ang)
    set Emp_K[Emp_N] = 5
    set Emp_N = Emp_N + 1
endfunction

// Aturdir: pausa con contador. No toca unidades que otro sistema ya tiene en pausa.
function Cop_Aturdir takes unit u, real s returns nothing
    local integer i = 0
    local integer k = R2I(s / 0.03)
    loop
        exitwhen i >= Atu_N
        if Atu_U[i] == u then
            if Atu_K[i] < k then
                set Atu_K[i] = k
            endif
            return
        endif
        set i = i + 1
    endloop
    if Atu_N >= 128 or IsUnitPaused(u) or IsUnitType(u, UNIT_TYPE_STRUCTURE) then
        return
    endif
    call PauseUnit(u, true)
    set Atu_U[Atu_N] = u
    set Atu_K[Atu_N] = k
    set Atu_E[Atu_N] = AddSpecialEffectTarget("FX_aturdido", u, "overhead")
    set Atu_N = Atu_N + 1
endfunction

// Ralentizar al 50 % de la velocidad que tenía; al acabar se le devuelve.
function Cop_Frenar takes unit u, real s returns nothing
    local integer i = 0
    local integer k = R2I(s / 0.03)
    loop
        exitwhen i >= Fre_N
        if Fre_U[i] == u then
            if Fre_K[i] < k then
                set Fre_K[i] = k
            endif
            return
        endif
        set i = i + 1
    endloop
    if Fre_N >= 128 or IsUnitType(u, UNIT_TYPE_STRUCTURE) then
        return
    endif
    set Fre_U[Fre_N] = u
    set Fre_K[Fre_N] = k
    set Fre_V[Fre_N] = GetUnitMoveSpeed(u)
    call SetUnitMoveSpeed(u, Fre_V[Fre_N] * 0.5)
    set Fre_N = Fre_N + 1
endfunction

function Cop_Rayo takes real x, real y, unit u returns nothing
    if Ray_N >= 64 then
        return
    endif
    set Ray_L[Ray_N] = AddLightningEx("CLPB", true, x, y, Cop_Z(x, y) + 150., GetUnitX(u), GetUnitY(u), Cop_Z(GetUnitX(u), GetUnitY(u)) + 60.)
    set Ray_K[Ray_N] = 8
    set Ray_N = Ray_N + 1
endfunction

function Cop_EstadosTick takes nothing returns nothing
    local integer i = Emp_N - 1
    local real x
    local real y
    loop
        exitwhen i < 0
        if Emp_K[i] <= 0 or GetUnitTypeId(Emp_U[i]) == 0 or GetWidgetLife(Emp_U[i]) <= 0.405 then
            set Emp_N = Emp_N - 1
            set Emp_U[i] = Emp_U[Emp_N]
            set Emp_VX[i] = Emp_VX[Emp_N]
            set Emp_VY[i] = Emp_VY[Emp_N]
            set Emp_K[i] = Emp_K[Emp_N]
            set Emp_U[Emp_N] = null
        else
            set x = GetUnitX(Emp_U[i]) + Emp_VX[i]
            set y = GetUnitY(Emp_U[i]) + Emp_VY[i]
            if IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) or not Cop_Dentro(x, y) then
                set Emp_K[i] = 0
            else
                call SetUnitX(Emp_U[i], x)
                call SetUnitY(Emp_U[i], y)
                set Emp_K[i] = Emp_K[i] - 1
            endif
        endif
        set i = i - 1
    endloop
    set i = Atu_N - 1
    loop
        exitwhen i < 0
        set Atu_K[i] = Atu_K[i] - 1
        if Atu_K[i] <= 0 or GetUnitTypeId(Atu_U[i]) == 0 or GetWidgetLife(Atu_U[i]) <= 0.405 then
            if GetUnitTypeId(Atu_U[i]) != 0 then
                call PauseUnit(Atu_U[i], false)
            endif
            call DestroyEffect(Atu_E[i])
            set Atu_N = Atu_N - 1
            set Atu_U[i] = Atu_U[Atu_N]
            set Atu_K[i] = Atu_K[Atu_N]
            set Atu_E[i] = Atu_E[Atu_N]
            set Atu_U[Atu_N] = null
            set Atu_E[Atu_N] = null
        endif
        set i = i - 1
    endloop
    set i = Fre_N - 1
    loop
        exitwhen i < 0
        set Fre_K[i] = Fre_K[i] - 1
        if Fre_K[i] <= 0 or GetUnitTypeId(Fre_U[i]) == 0 or GetWidgetLife(Fre_U[i]) <= 0.405 then
            if GetUnitTypeId(Fre_U[i]) != 0 then
                call SetUnitMoveSpeed(Fre_U[i], Fre_V[i])
            endif
            set Fre_N = Fre_N - 1
            set Fre_U[i] = Fre_U[Fre_N]
            set Fre_K[i] = Fre_K[Fre_N]
            set Fre_V[i] = Fre_V[Fre_N]
            set Fre_U[Fre_N] = null
        endif
        set i = i - 1
    endloop
    set i = Ray_N - 1
    loop
        exitwhen i < 0
        set Ray_K[i] = Ray_K[i] - 1
        if Ray_K[i] <= 0 then
            call DestroyLightning(Ray_L[i])
            set Ray_N = Ray_N - 1
            set Ray_L[i] = Ray_L[Ray_N]
            set Ray_K[i] = Ray_K[Ray_N]
            set Ray_L[Ray_N] = null
        endif
        set i = i - 1
    endloop
endfunction

// Golpe de área de la copia del jugador p a r de (x, y), o a r del segmento (x, y)-(Cop_oX2, Cop_oY2) con Cop_oSeg.
// g (si no es null): golpea a cada unidad una sola vez. Opciones en Cop_o*: empujón (lateral respecto de a o hacia
// fuera), aturdir, ralentizar, % de vida máxima (hasta +1500) y juntar sobre la línea. Devuelve los golpeados; el
// daño hecho queda en Cop_oSuma.
function Cop_Area takes integer p, group g, real a, real x, real y, real r, real dano returns integer
    local unit src = Cop_Fuente(p)
    local player o = Player(p)
    local boolean antes = s__GroundCollision_shaped
    local unit u
    local real cx = x
    local real cy = y
    local real er = r
    local real qx = x
    local real qy = y
    local real dx = 0.
    local real dy = 0.
    local real l2 = 0.
    local real t
    local real d
    local real ang
    local integer n = 0
    if Cop_Enum == null then
        set Cop_Enum = CreateGroup()
    endif
    if Cop_oSeg then
        set dx = Cop_oX2 - x
        set dy = Cop_oY2 - y
        set l2 = dx * dx + dy * dy
        set cx = x + dx / 2.
        set cy = y + dy / 2.
        set er = SquareRoot(l2) / 2. + r
    endif
    set Cop_oSuma = 0.
    set s__GroundCollision_shaped = true
    call GroupEnumUnitsInRange(Cop_Enum, cx, cy, er + 128., null)
    loop
        set u = FirstOfGroup(Cop_Enum)
        exitwhen u == null
        call GroupRemoveUnit(Cop_Enum, u)
        if Cop_oSeg then
            set t = 0.
            if l2 > 1. then
                set t = RMaxBJ(0., RMinBJ(1., ((GetUnitX(u) - x) * dx + (GetUnitY(u) - y) * dy) / l2))
            endif
            set qx = x + t * dx
            set qy = y + t * dy
        endif
        if s__GroundCollision_isTarget(u, src, o) and s__GroundCollision_touches(u, qx, qy, r) and not (g != null and IsUnitInGroup(u, g)) then
            if g != null then
                call GroupAddUnit(g, u)
            endif
            set d = dano
            if Cop_oPct > 0. then
                set d = d + RMinBJ(1500., Cop_oPct * GetUnitState(u, UNIT_STATE_MAX_LIFE))
            endif
            if d > 0. then
                set d = Her_Dano(p, d)
                call UnitDamageTarget(src, u, d, false, false, Dano_Ataque(6), Dano_TipoArma, null)
                call Barras_Golpe(src, u)
                set Cop_oSuma = Cop_oSuma + d
            endif
            set n = n + 1
            if GetWidgetLife(u) > 0.405 then
                if Cop_oTirar and not IsTerrainPathable(qx, qy, PATHING_TYPE_WALKABILITY) then
                    call SetUnitX(u, qx)
                    call SetUnitY(u, qy)
                endif
                if Cop_oEmp != 0. then
                    if Cop_oLat then
                        set ang = a + bj_PI / 2.
                        if Cos(a) * (GetUnitY(u) - qy) - Sin(a) * (GetUnitX(u) - qx) < 0. then
                            set ang = a - bj_PI / 2.
                        endif
                    else
                        set ang = Atan2(GetUnitY(u) - qy, GetUnitX(u) - qx)
                    endif
                    call Cop_Empujar(u, ang, Cop_oEmp)
                endif
                if Cop_oAtu > 0. then
                    call Cop_Aturdir(u, Cop_oAtu)
                endif
                if Cop_oFre > 0. then
                    call Cop_Frenar(u, Cop_oFre)
                endif
            endif
        endif
    endloop
    set s__GroundCollision_shaped = antes
    set src = null
    set o = null
    return n
endfunction

function Cop_Sumar takes integer i, integer n returns nothing
    set Cop_Golpes[i] = Cop_Golpes[i] + n
    set Cop_Total[i] = Cop_Total[i] + Cop_oSuma
endfunction

// Acerca a los enemigos a r de (x, y) hasta "minimo" del centro, "paso" por llamada.
function Cop_Atraer takes integer p, real x, real y, real r, real paso, real minimo returns nothing
    local unit src = Cop_Fuente(p)
    local player o = Player(p)
    local unit u
    local real dx
    local real dy
    local real d
    local real nx
    local real ny
    if Cop_Enum == null then
        set Cop_Enum = CreateGroup()
    endif
    call GroupEnumUnitsInRange(Cop_Enum, x, y, r, null)
    loop
        set u = FirstOfGroup(Cop_Enum)
        exitwhen u == null
        call GroupRemoveUnit(Cop_Enum, u)
        if s__GroundCollision_isTarget(u, src, o) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            set dx = x - GetUnitX(u)
            set dy = y - GetUnitY(u)
            set d = SquareRoot(dx * dx + dy * dy)
            if d > minimo then
                set nx = GetUnitX(u) + dx / d * RMinBJ(paso, d - minimo)
                set ny = GetUnitY(u) + dy / d * RMinBJ(paso, d - minimo)
                if not IsTerrainPathable(nx, ny, PATHING_TYPE_WALKABILITY) then
                    call SetUnitX(u, nx)
                    call SetUnitY(u, ny)
                endif
            endif
        endif
    endloop
    set src = null
    set o = null
endfunction

// Rugido: los enemigos a r van hacia (x, y).
function Cop_Provocar takes integer p, real x, real y, real r returns nothing
    local unit src = Cop_Fuente(p)
    local player o = Player(p)
    local unit u
    if Cop_Enum == null then
        set Cop_Enum = CreateGroup()
    endif
    call GroupEnumUnitsInRange(Cop_Enum, x, y, r, null)
    loop
        set u = FirstOfGroup(Cop_Enum)
        exitwhen u == null
        call GroupRemoveUnit(Cop_Enum, u)
        if s__GroundCollision_isTarget(u, src, o) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitPaused(u) then
            call IssuePointOrder(u, "move", x, y)
        endif
    endloop
    set src = null
    set o = null
endfunction

// Réplica (pasiva de Cairne): aturde 1 s a 250 de Cairne y 0,75 s a 250 del golpe.
function Cop_Replica takes integer p, real x, real y returns nothing
    local unit h = Game_Hero[p]
    if GetUnitTypeId(h) == 'h006' and UnitAlive(h) then
        call DestroyEffect(AddSpecialEffect("FX_pisoton", GetUnitX(h), GetUnitY(h)))
        call Cop_Opc()
        set Cop_oAtu = 1.
        call Cop_Area(p, null, 0., GetUnitX(h), GetUnitY(h), 250., 0.)
        set Cop_oAtu = 0.75
        call Cop_Area(p, null, 0., x, y, 250., 0.)
        call Cop_Opc()
    endif
    set h = null
endfunction

function Cop_Nuevo takes integer p, integer t returns integer
    local integer i = Cop_N
    if i >= 200 then
        return -1
    endif
    set Cop_N = i + 1
    set Cop_U[i] = null
    set Cop_E[i] = null
    set Cop_G[i] = null
    set Cop_Ob[i] = null
    set Cop_P[i] = p
    set Cop_T[i] = t
    set Cop_Fase[i] = 0
    set Cop_K[i] = 0
    set Cop_Gen[i] = 0
    set Cop_H[i] = 0.
    set Cop_NT[i] = 0
    set Cop_V[i] = 0.
    set Cop_D[i] = 0.
    set Cop_A[i] = 0.
    set Cop_Rest[i] = 0.
    set Cop_Golpes[i] = 0
    set Cop_Total[i] = 0.
    return i
endfunction

function Cop_Unidad takes integer i, integer tipo, real x, real y, real ang returns nothing
    set Cop_U[i] = CreateUnit(Player(Cop_P[i]), tipo, x, y, ang * bj_RADTODEG)
    call SetUnitVertexColor(Cop_U[i], 140, 210, 255, 150)
    call SetUnitPathing(Cop_U[i], false)
    set Cop_X[i] = x
    set Cop_Y[i] = y
    set Cop_A[i] = ang
endfunction

function Cop_Proyectil takes integer i, string m, real x, real y, real ang, real z returns nothing
    set Cop_U[i] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'dumi', x, y, ang * bj_RADTODEG)
    call SetUnitFlyHeight(Cop_U[i], z, 0.)
    set Cop_E[i] = AddSpecialEffectTarget(m, Cop_U[i], "origin")
    set Cop_X[i] = x
    set Cop_Y[i] = y
    set Cop_A[i] = ang
endfunction

// Vuelo en arco de (SX, SY) a (TX, TY) en NT pasos con altura H; true al llegar.
function Cop_Vuelo takes integer i returns boolean
    local real t = I2R(Cop_K[i]) / I2R(Cop_NT[i])
    if t > 1. then
        set t = 1.
    endif
    set Cop_X[i] = Cop_SX[i] + (Cop_TX[i] - Cop_SX[i]) * t
    set Cop_Y[i] = Cop_SY[i] + (Cop_TY[i] - Cop_SY[i]) * t
    call SetUnitX(Cop_U[i], Cop_X[i])
    call SetUnitY(Cop_U[i], Cop_Y[i])
    call SetUnitFlyHeight(Cop_U[i], 60. + 4. * Cop_H[i] * t * (1. - t), 0.)
    return t >= 1.
endfunction

function Cop_Quitar takes integer i returns nothing
    local integer j
    local integer p = Cop_P[i]
    if Cop_T[i] == 6 then
        set Cop_Golpes[i] = Bom_Golpes[p]
        set Cop_Total[i] = Bom_Total[p]
    endif
    if Cop_T[i] != 7 and Cop_T[i] != 8 then
        set Cop_Log = "hab " + Cop_Nombre(Cop_T[i]) + " j" + I2S(p) + " golpes " + I2S(Cop_Golpes[i]) + " dano " + I2S(R2I(Cop_Total[i]))
        call ExecuteFunc("Cop_Anotar")
    endif
    if Cop_E[i] != null then
        call DestroyEffect(Cop_E[i])
    endif
    if Cop_U[i] != null then
        call RemoveUnit(Cop_U[i])
    endif
    if Cop_G[i] != null then
        call DestroyGroup(Cop_G[i])
    endif
    if Cop_T[i] == 14 and Cop_Ob[i] != null then
        call GroupRemoveUnit(Cop_Marcados, Cop_Ob[i])
    endif
    set Cop_N = Cop_N - 1
    set j = Cop_N
    set Cop_U[i] = Cop_U[j]
    set Cop_E[i] = Cop_E[j]
    set Cop_G[i] = Cop_G[j]
    set Cop_Ob[i] = Cop_Ob[j]
    set Cop_P[i] = Cop_P[j]
    set Cop_T[i] = Cop_T[j]
    set Cop_Fase[i] = Cop_Fase[j]
    set Cop_K[i] = Cop_K[j]
    set Cop_Gen[i] = Cop_Gen[j]
    set Cop_H[i] = Cop_H[j]
    set Cop_NT[i] = Cop_NT[j]
    set Cop_V[i] = Cop_V[j]
    set Cop_D[i] = Cop_D[j]
    set Cop_A[i] = Cop_A[j]
    set Cop_Rest[i] = Cop_Rest[j]
    set Cop_Golpes[i] = Cop_Golpes[j]
    set Cop_Total[i] = Cop_Total[j]
    set Cop_SX[i] = Cop_SX[j]
    set Cop_SY[i] = Cop_SY[j]
    set Cop_TX[i] = Cop_TX[j]
    set Cop_TY[i] = Cop_TY[j]
    set Cop_X[i] = Cop_X[j]
    set Cop_Y[i] = Cop_Y[j]
    set Cop_U[j] = null
    set Cop_E[j] = null
    set Cop_G[j] = null
    set Cop_Ob[j] = null
endfunction

// Avanza la pieza i "paso" en su ángulo; false si sale del mapa (o, con suelo, si no es transitable).
function Cop_Avanzar takes integer i, real paso, boolean suelo returns boolean
    local real x = Cop_X[i] + paso * Cop_Cos(i)
    local real y = Cop_Y[i] + paso * Sin(Cop_A[i])
    if not Cop_Dentro(x, y) or (suelo and IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY)) then
        return false
    endif
    set Cop_X[i] = x
    set Cop_Y[i] = y
    if Cop_U[i] != null then
        call SetUnitX(Cop_U[i], x)
        call SetUnitY(Cop_U[i], y)
    endif
    return true
endfunction

// 1 Embestida: amago 7 pasos, carga 33 por paso (300 a 140, una vez, aparta 180), golpe al paso 12 (500 a 260).
function Cop_T1 takes integer i returns nothing
    local real s
    if Cop_Fase[i] == 0 then
        if Cop_K[i] >= 7 then
            set Cop_Fase[i] = 1
            set Cop_K[i] = 0
            call SetUnitTimeScale(Cop_U[i], 2.5)
            call SetUnitAnimation(Cop_U[i], "walk")
        endif
    elseif Cop_Fase[i] == 1 then
        set s = RMinBJ(33., Cop_Rest[i])
        if s <= 0. or not Cop_Avanzar(i, s, true) then
            set Cop_Fase[i] = 2
            set Cop_K[i] = 0
            call SetUnitTimeScale(Cop_U[i], 1.5)
            call SetUnitAnimation(Cop_U[i], "attack slam")
        else
            set Cop_Rest[i] = Cop_Rest[i] - s
            call Cop_Opc()
            set Cop_oEmp = 180.
            set Cop_oLat = true
            call Cop_Sumar(i, Cop_Area(Cop_P[i], Cop_G[i], Cop_A[i], Cop_X[i], Cop_Y[i], 140., 300.))
            if ModuloInteger(Cop_K[i], 3) == 0 then
                call DestroyEffect(AddSpecialEffect("FX_polvo", Cop_X[i], Cop_Y[i]))
            endif
        endif
    elseif Cop_K[i] == 12 then
        set Cop_TX[i] = Cop_X[i] + 120. * Cop_Cos(i)
        set Cop_TY[i] = Cop_Y[i] + 120. * Sin(Cop_A[i])
        call DestroyEffect(AddSpecialEffect("FX_pisoton", Cop_TX[i], Cop_TY[i]))
        call Cop_Opc()
        set Cop_oEmp = 150.
        call Cop_Sumar(i, Cop_Area(Cop_P[i], null, Cop_A[i], Cop_TX[i], Cop_TY[i], 260., 500.))
    elseif Cop_K[i] >= 30 then
        call SetUnitTimeScale(Cop_U[i], 1.)
        set Cop_Fase[i] = 99
        set Cop_K[i] = 0
    endif
endfunction

// 2 Tótem arrojado: vuelo 0,5 s, cae (250 a 200, aturde 1 s), 4 s ralentizando a 300, vuelve al héroe (200 a 120).
function Cop_T2 takes integer i returns nothing
    local unit h = Game_Hero[Cop_P[i]]
    local real dx
    local real dy
    local real d
    if Cop_Fase[i] == 0 then
        if Cop_Vuelo(i) then
            call SetUnitFlyHeight(Cop_U[i], 0., 0.)
            call DestroyEffect(AddSpecialEffect("FX_trueno", Cop_X[i], Cop_Y[i]))
            call Cop_Opc()
            set Cop_oAtu = 1.
            call Cop_Sumar(i, Cop_Area(Cop_P[i], null, 0., Cop_X[i], Cop_Y[i], 200., 250.))
            set Cop_Fase[i] = 1
            set Cop_K[i] = 0
        endif
    elseif Cop_Fase[i] == 1 then
        if ModuloInteger(Cop_K[i], 17) == 0 then
            call Cop_Opc()
            set Cop_oFre = 1.2
            call Cop_Area(Cop_P[i], null, 0., Cop_X[i], Cop_Y[i], 300., 0.)
        endif
        if Cop_K[i] >= 133 then
            set Cop_Fase[i] = 2
            set Cop_K[i] = 0
            call SetUnitFlyHeight(Cop_U[i], 80., 0.)
        endif
    else
        set dx = GetUnitX(h) - Cop_X[i]
        set dy = GetUnitY(h) - Cop_Y[i]
        set d = SquareRoot(dx * dx + dy * dy)
        if d < 60. or Cop_K[i] >= 90 or not UnitAlive(h) then
            call Cop_Quitar(i)
        else
            set Cop_A[i] = Atan2(dy, dx)
            call Cop_Avanzar(i, RMinBJ(40., d), false)
            call Cop_Opc()
            call Cop_Sumar(i, Cop_Area(Cop_P[i], Cop_G[i], Cop_A[i], Cop_X[i], Cop_Y[i], 120., 200.))
        endif
    endif
    set h = null
endfunction

// 3 Lanzar roca: arco al punto (D a 180) y 3 botes hacia delante, cada uno 60 % de largo y 80 % de daño.
function Cop_T3 takes integer i returns nothing
    if Cop_Vuelo(i) then
        call DestroyEffect(AddSpecialEffect("M_ROCA", Cop_X[i], Cop_Y[i]))
        call DestroyEffect(AddSpecialEffect("FX_polvo", Cop_X[i], Cop_Y[i]))
        call Cop_Opc()
        call Cop_Sumar(i, Cop_Area(Cop_P[i], null, 0., Cop_X[i], Cop_Y[i], 180., Cop_D[i]))
        set Cop_Rest[i] = RMaxBJ(150., Cop_Rest[i] * 0.6)
        set Cop_SX[i] = Cop_X[i]
        set Cop_SY[i] = Cop_Y[i]
        set Cop_TX[i] = Cop_X[i] + Cop_Rest[i] * Cop_Cos(i)
        set Cop_TY[i] = Cop_Y[i] + Cop_Rest[i] * Sin(Cop_A[i])
        if Cop_Gen[i] >= 3 or not Cop_Dentro(Cop_TX[i], Cop_TY[i]) then
            call Cop_Quitar(i)
        else
            set Cop_Gen[i] = Cop_Gen[i] + 1
            set Cop_D[i] = Cop_D[i] * 0.8
            set Cop_NT[i] = IMaxBJ(8, R2I(Cop_NT[i] * 0.75))
            set Cop_H[i] = Cop_H[i] * 0.6
            set Cop_K[i] = 0
        endif
    endif
endfunction

// 4 Garra espiritual: 2,5 s atrayendo a 450 (500/s) hasta 90; al final 250 a 250.
function Cop_T4 takes integer i returns nothing
    if ModuloInteger(Cop_K[i], 2) == 0 then
        call Cop_Atraer(Cop_P[i], Cop_X[i], Cop_Y[i], 450., 30., 90.)
    endif
    if Cop_K[i] >= 83 then
        call DestroyEffect(AddSpecialEffect("FX_espiritu", Cop_X[i], Cop_Y[i]))
        call Cop_Opc()
        call Cop_Sumar(i, Cop_Area(Cop_P[i], null, 0., Cop_X[i], Cop_Y[i], 250., 250.))
        set Cop_Fase[i] = 99
        set Cop_K[i] = 0
    endif
endfunction

// 5 Rugido desafiante: 4 s llamando a los de 700; luego 500 a 350 y aturde 1 s.
function Cop_T5 takes integer i returns nothing
    if ModuloInteger(Cop_K[i], 33) == 1 then
        call DestroyEffect(AddSpecialEffect("FX_rugido", Cop_X[i], Cop_Y[i]))
        call SetUnitAnimation(Cop_U[i], "stand victory")
    endif
    if ModuloInteger(Cop_K[i], 10) == 0 then
        call Cop_Provocar(Cop_P[i], Cop_X[i], Cop_Y[i], 700.)
    endif
    if Cop_K[i] >= 133 then
        call DestroyEffect(AddSpecialEffect("FX_trueno", Cop_X[i], Cop_Y[i]))
        call DestroyEffect(AddSpecialEffect("FX_rugido", Cop_X[i], Cop_Y[i]))
        call Cop_Opc()
        set Cop_oAtu = 1.
        call Cop_Sumar(i, Cop_Area(Cop_P[i], null, 0., Cop_X[i], Cop_Y[i], 350., 500.))
        set Cop_Fase[i] = 99
        set Cop_K[i] = 0
    endif
endfunction

// 6 Bombardeo: 8 s; cada 3 pasos una piedra en espiral (+22°, radio de 900 a 200 bajando 100 cada 16).
function Cop_T6 takes integer i returns nothing
    local integer j
    local real a
    local real x
    local real y
    if ModuloInteger(Cop_K[i], 84) == 1 then
        call SetUnitAnimation(Cop_U[i], "attack slam")
    endif
    if ModuloInteger(Cop_K[i], 3) == 0 then
        set Cop_V[i] = Cop_V[i] + 22.
        set Cop_Gen[i] = Cop_Gen[i] + 1
        if ModuloInteger(Cop_Gen[i], 16) == 0 then
            set Cop_Rest[i] = Cop_Rest[i] - 100.
            if Cop_Rest[i] < 200. then
                set Cop_Rest[i] = 900.
            endif
        endif
        set a = Cop_V[i] * bj_DEGTORAD
        set x = Cop_X[i] + Cop_Rest[i] * Cos(a)
        set y = Cop_Y[i] + Cop_Rest[i] * Sin(a)
        if Cop_Dentro(x, y) then
            set j = Cop_Nuevo(Cop_P[i], 7)
            if j >= 0 then
                set Cop_SX[j] = Cop_X[i]
                set Cop_SY[j] = Cop_Y[i]
                set Cop_TX[j] = x
                set Cop_TY[j] = y
                set Cop_NT[j] = 17
                set Cop_H[j] = 300.
                set Cop_D[j] = 180.
                call Cop_Proyectil(j, "M_ROCA", Cop_X[i], Cop_Y[i], a, 150.)
            endif
        endif
    endif
    if Cop_K[i] >= 266 then
        call SetUnitTimeScale(Cop_U[i], 1.)
        set Cop_Fase[i] = 99
        set Cop_K[i] = 0
    endif
endfunction

// 7 piedra del Bombardeo: 180 a 150 al caer.
function Cop_T7 takes integer i returns nothing
    local integer p = Cop_P[i]
    if Cop_Vuelo(i) then
        call DestroyEffect(AddSpecialEffect("M_ROCA", Cop_X[i], Cop_Y[i]))
        call Cop_Opc()
        set Bom_Golpes[p] = Bom_Golpes[p] + Cop_Area(p, null, 0., Cop_X[i], Cop_Y[i], 150., Cop_D[i])
        set Bom_Total[p] = Bom_Total[p] + Cop_oSuma
        call Cop_Quitar(i)
    endif
endfunction

// 9 Grieta ancestral: polvo a lo largo de 900 en 0,75 s; al paso 50 se parte.
function Cop_T9 takes integer i returns nothing
    local integer s
    local real c = Cop_Cos(i)
    local real n = Sin(Cop_A[i])
    if Cop_K[i] <= 24 and ModuloInteger(Cop_K[i], 2) == 0 then
        set s = Cop_K[i] / 2
        call DestroyEffect(AddSpecialEffect("FX_polvo", Cop_SX[i] + Cop_Rest[i] * s / 12. * c, Cop_SY[i] + Cop_Rest[i] * s / 12. * n))
    elseif Cop_K[i] >= 50 then
        set s = 0
        loop
            exitwhen s > 6
            call DestroyEffect(AddSpecialEffect("FX_grieta", Cop_SX[i] + Cop_Rest[i] * s / 6. * c, Cop_SY[i] + Cop_Rest[i] * s / 6. * n))
            set s = s + 1
        endloop
        call Cop_Opc()
        set Cop_oSeg = true
        set Cop_oX2 = Cop_TX[i]
        set Cop_oY2 = Cop_TY[i]
        set Cop_oTirar = true
        set Cop_oFre = 2.
        set Cop_oPct = 0.06
        call Cop_Sumar(i, Cop_Area(Cop_P[i], null, Cop_A[i], Cop_SX[i], Cop_SY[i], 150., 250.))
        call Cop_Opc()
        call Cop_Replica(Cop_P[i], (Cop_SX[i] + Cop_TX[i]) / 2., (Cop_SY[i] + Cop_TY[i]) / 2.)
        call Cop_Quitar(i)
    endif
endfunction

// 10 Lanza ancestral: 45 por paso, atraviesa (D a 100, una vez); la primera se parte en 3 de 500 (150).
function Cop_T10 takes integer i returns nothing
    local real s = RMinBJ(Cop_V[i], Cop_Rest[i])
    local integer j
    local integer k
    if Cop_Avanzar(i, s, false) then
        set Cop_Rest[i] = Cop_Rest[i] - s
        call Cop_Opc()
        call Cop_Sumar(i, Cop_Area(Cop_P[i], Cop_G[i], Cop_A[i], Cop_X[i], Cop_Y[i], 100., Cop_D[i]))
    else
        set Cop_Rest[i] = 0.
    endif
    if Cop_Rest[i] <= 0. then
        if Cop_Gen[i] == 0 then
            set k = -1
            loop
                exitwhen k > 1
                set j = Cop_Nuevo(Cop_P[i], 10)
                if j >= 0 then
                    set Cop_Gen[j] = 1
                    set Cop_Rest[j] = 500.
                    set Cop_V[j] = 45.
                    set Cop_D[j] = 150.
                    set Cop_G[j] = CreateGroup()
                    call Cop_Proyectil(j, "M_LANZA", Cop_X[i], Cop_Y[i], Cop_A[i] + k * 0.52, 60.)
                endif
                set k = k + 1
            endloop
            call Cop_Replica(Cop_P[i], Cop_X[i], Cop_Y[i])
        endif
        call Cop_Quitar(i)
    endif
endfunction

// 12 Espíritu ancestral: sale 23 por paso (150 a 140), pisa (350 a 300), vuelve 30 por paso (100) y cura.
function Cop_T12 takes integer i returns nothing
    local unit h = Game_Hero[Cop_P[i]]
    local real s
    local real dx
    local real dy
    local real d
    if Cop_Fase[i] == 0 then
        set s = RMinBJ(23., Cop_Rest[i])
        if s <= 0. or not Cop_Avanzar(i, s, false) then
            set Cop_Fase[i] = 1
            set Cop_K[i] = 0
            call SetUnitTimeScale(Cop_U[i], 1.5)
            call SetUnitAnimation(Cop_U[i], "attack slam")
        else
            set Cop_Rest[i] = Cop_Rest[i] - s
            call Cop_Opc()
            call Cop_Sumar(i, Cop_Area(Cop_P[i], Cop_G[i], Cop_A[i], Cop_X[i], Cop_Y[i], 140., 150.))
        endif
    elseif Cop_Fase[i] == 1 then
        if Cop_K[i] == 12 then
            set dx = Cop_X[i] + 60. * Cop_Cos(i)
            set dy = Cop_Y[i] + 60. * Sin(Cop_A[i])
            call DestroyEffect(AddSpecialEffect("FX_pisoton", dx, dy))
            call Cop_Opc()
            call Cop_Sumar(i, Cop_Area(Cop_P[i], null, 0., dx, dy, 300., 350.))
            call Cop_Replica(Cop_P[i], dx, dy)
        elseif Cop_K[i] >= 30 then
            set Cop_Fase[i] = 2
            set Cop_K[i] = 0
            call GroupClear(Cop_G[i])
            call SetUnitTimeScale(Cop_U[i], 2.)
            call SetUnitAnimation(Cop_U[i], "walk")
        endif
    elseif Cop_Fase[i] == 2 then
        set dx = GetUnitX(h) - Cop_X[i]
        set dy = GetUnitY(h) - Cop_Y[i]
        set d = SquareRoot(dx * dx + dy * dy)
        if d < 80. or Cop_K[i] >= 200 or not UnitAlive(h) then
            if UnitAlive(h) and Cop_Golpes[i] > 0 then
                call SetWidgetLife(h, GetWidgetLife(h) + RMinBJ(300., 15. * Cop_Golpes[i]))
                call DestroyEffect(AddSpecialEffectTarget("FX_cura", h, "origin"))
            endif
            call SetUnitTimeScale(Cop_U[i], 1.)
            set Cop_Fase[i] = 99
            set Cop_K[i] = 0
        else
            set Cop_A[i] = Atan2(dy, dx)
            call SetUnitFacing(Cop_U[i], Cop_A[i] * bj_RADTODEG)
            call Cop_Avanzar(i, RMinBJ(30., d), false)
            call Cop_Opc()
            call Cop_Sumar(i, Cop_Area(Cop_P[i], Cop_G[i], Cop_A[i], Cop_X[i], Cop_Y[i], 140., 100.))
        endif
    endif
    set h = null
endfunction

// Rayos del Tótem del trueno: hasta n enemigos a 600, 150 cada uno.
function Cop_Rayos takes integer i, integer n returns nothing
    local integer p = Cop_P[i]
    local unit src = Cop_Fuente(p)
    local player o = Player(p)
    local unit u
    local real d
    call GroupEnumUnitsInRange(Cop_Enum, Cop_X[i], Cop_Y[i], 600., null)
    loop
        set u = FirstOfGroup(Cop_Enum)
        exitwhen u == null
        call GroupRemoveUnit(Cop_Enum, u)
        if n > 0 and s__GroundCollision_isTarget(u, src, o) then
            set n = n - 1
            call Cop_Rayo(Cop_X[i], Cop_Y[i], u)
            call DestroyEffect(AddSpecialEffect("FX_rayo", GetUnitX(u), GetUnitY(u)))
            set d = Her_Dano(p, 150.)
            call UnitDamageTarget(src, u, d, false, false, Dano_Ataque(6), Dano_TipoArma, null)
            call Barras_Golpe(src, u)
            set Cop_Golpes[i] = Cop_Golpes[i] + 1
            set Cop_Total[i] = Cop_Total[i] + d
        endif
    endloop
    set src = null
    set o = null
endfunction

// 13 Tótem del trueno: vuelo 0,5 s (150 a 200); 6 s atrayendo a 600 (100/s) y rayos cada 0,5 s.
function Cop_T13 takes integer i returns nothing
    if Cop_Fase[i] == 0 then
        if Cop_Vuelo(i) then
            call SetUnitFlyHeight(Cop_U[i], 0., 0.)
            call DestroyEffect(AddSpecialEffect("FX_trueno", Cop_X[i], Cop_Y[i]))
            call Cop_Opc()
            call Cop_Sumar(i, Cop_Area(Cop_P[i], null, 0., Cop_X[i], Cop_Y[i], 200., 150.))
            call Cop_Replica(Cop_P[i], Cop_X[i], Cop_Y[i])
            set Cop_Fase[i] = 1
            set Cop_K[i] = 0
        endif
    else
        if ModuloInteger(Cop_K[i], 2) == 0 then
            call Cop_Atraer(Cop_P[i], Cop_X[i], Cop_Y[i], 600., 6., 150.)
        endif
        if ModuloInteger(Cop_K[i], 17) == 0 then
            call Cop_Rayos(i, 3)
        endif
        if Cop_K[i] >= 200 then
            call Cop_Quitar(i)
        endif
    endif
endfunction

// Contagio de la Marca: hasta 3 enemigos sin marcar a 450, explotan a los 1,5 s (250 a 250).
function Cop_Contagiar takes integer i returns nothing
    local integer p = Cop_P[i]
    local unit src = Cop_Fuente(p)
    local player o = Player(p)
    local unit u
    local integer n = 3
    local integer j
    call GroupEnumUnitsInRange(Cop_Enum, Cop_X[i], Cop_Y[i], 450., null)
    loop
        set u = FirstOfGroup(Cop_Enum)
        exitwhen u == null
        call GroupRemoveUnit(Cop_Enum, u)
        if n > 0 and u != Cop_Ob[i] and s__GroundCollision_isTarget(u, src, o) and not IsUnitInGroup(u, Cop_Marcados) then
            set j = Cop_Nuevo(p, 14)
            if j >= 0 then
                set n = n - 1
                set Cop_Gen[j] = 1
                set Cop_Ob[j] = u
                set Cop_NT[j] = 50
                set Cop_D[j] = 250.
                set Cop_X[j] = GetUnitX(u)
                set Cop_Y[j] = GetUnitY(u)
                set Cop_E[j] = AddSpecialEffectTarget("FX_marca", u, "overhead")
                call GroupAddUnit(Cop_Marcados, u)
            endif
        endif
    endloop
    set src = null
    set o = null
endfunction

// 14 Marca ancestral: sigue al marcado; a los NT pasos (o si muere) explota.
function Cop_T14 takes integer i returns nothing
    local boolean vivo = GetUnitTypeId(Cop_Ob[i]) != 0 and GetWidgetLife(Cop_Ob[i]) > 0.405
    if vivo then
        set Cop_X[i] = GetUnitX(Cop_Ob[i])
        set Cop_Y[i] = GetUnitY(Cop_Ob[i])
    endif
    if Cop_K[i] >= Cop_NT[i] or not vivo then
        call Cop_Opc()
        if Cop_Gen[i] == 0 then
            call DestroyEffect(AddSpecialEffect("FX_explota", Cop_X[i], Cop_Y[i]))
            call Cop_Sumar(i, Cop_Area(Cop_P[i], null, 0., Cop_X[i], Cop_Y[i], 300., Cop_D[i]))
            call Cop_Contagiar(i)
            call Cop_Replica(Cop_P[i], Cop_X[i], Cop_Y[i])
        else
            call DestroyEffect(AddSpecialEffect("FX_chispa", Cop_X[i], Cop_Y[i]))
            call DestroyEffect(AddSpecialEffect("FX_trueno", Cop_X[i], Cop_Y[i]))
            call Cop_Sumar(i, Cop_Area(Cop_P[i], null, 0., Cop_X[i], Cop_Y[i], 250., Cop_D[i]))
        endif
        call Cop_Quitar(i)
    endif
endfunction

// 15 Estampida: cada 4 pasos un kodo espiritual desde detrás de Cairne (frente de 700), 14 en total.
function Cop_T15 takes integer i returns nothing
    local integer j
    local real off
    local real c = Cop_Cos(i)
    local real n = Sin(Cop_A[i])
    local real x
    local real y
    if ModuloInteger(Cop_K[i], 4) == 1 then
        set Cop_Gen[i] = Cop_Gen[i] + 1
        set off = GetRandomReal(-350., 350.)
        set x = Cop_SX[i] - 200. * c - off * n
        set y = Cop_SY[i] - 200. * n + off * c
        if Cop_Dentro(x, y) then
            set j = Cop_Nuevo(Cop_P[i], 16)
            if j >= 0 then
                set Cop_Rest[j] = 1600.
                set Cop_V[j] = 30.
                set Cop_D[j] = 180.
                set Cop_H[j] = 60.
                set Cop_G[j] = CreateGroup()
                call Cop_Proyectil(j, "M_KODO", x, y, Cop_A[i], 0.)
            endif
        endif
    endif
    if Cop_Gen[i] >= 14 then
        call Cop_Quitar(i)
    endif
endfunction

// 16 corredor (kodo de la Estampida o, con Gen 1, copia de Espíritus guardianes): D una vez y aparta H a un lado.
function Cop_T16 takes integer i returns nothing
    local real s = RMinBJ(Cop_V[i], Cop_Rest[i])
    if s > 0. and Cop_Avanzar(i, s, Cop_Gen[i] == 1) then
        set Cop_Rest[i] = Cop_Rest[i] - s
        call Cop_Opc()
        set Cop_oEmp = Cop_H[i]
        set Cop_oLat = true
        call Cop_Sumar(i, Cop_Area(Cop_P[i], Cop_G[i], Cop_A[i], Cop_X[i], Cop_Y[i], 120., Cop_D[i]))
    else
        set Cop_Rest[i] = 0.
    endif
    if Cop_Rest[i] <= 0. then
        if Cop_Gen[i] == 1 then
            call SetUnitTimeScale(Cop_U[i], 1.)
            set Cop_Fase[i] = 99
            set Cop_K[i] = 0
        else
            call Cop_Quitar(i)
        endif
    endif
endfunction

function Cop_Tick takes nothing returns nothing
    local integer i = Cop_N - 1
    local integer t
    loop
        exitwhen i < 0
        if i < Cop_N then
            set Cop_K[i] = Cop_K[i] + 1
            set t = Cop_T[i]
            if Cop_Fase[i] == 99 then
                call SetUnitVertexColor(Cop_U[i], 140, 210, 255, IMaxBJ(0, 150 - 15 * Cop_K[i]))
                if Cop_K[i] >= 10 then
                    call Cop_Quitar(i)
                endif
            elseif t == 1 then
                call Cop_T1(i)
            elseif t == 2 then
                call Cop_T2(i)
            elseif t == 3 then
                call Cop_T3(i)
            elseif t == 4 then
                call Cop_T4(i)
            elseif t == 5 then
                call Cop_T5(i)
            elseif t == 6 then
                call Cop_T6(i)
            elseif t == 7 then
                call Cop_T7(i)
            elseif t == 8 then
                if Cop_K[i] >= Cop_NT[i] then
                    set Cop_Fase[i] = 99
                    set Cop_K[i] = 0
                endif
            elseif t == 9 then
                call Cop_T9(i)
            elseif t == 10 then
                call Cop_T10(i)
            elseif t == 12 then
                call Cop_T12(i)
            elseif t == 13 then
                call Cop_T13(i)
            elseif t == 14 then
                call Cop_T14(i)
            elseif t == 15 then
                call Cop_T15(i)
            elseif t == 16 then
                call Cop_T16(i)
            else
                call Cop_Quitar(i)
            endif
        endif
        set i = i - 1
    endloop
    call Cop_EstadosTick()
    if Cop_N == 0 and Emp_N == 0 and Atu_N == 0 and Fre_N == 0 and Ray_N == 0 then
        call PauseTimer(Cop_Reloj)
        set Cop_Activo = false
    endif
endfunction

function Cop_Arrancar takes nothing returns nothing
    if Cop_Reloj == null then
        set Cop_Reloj = CreateTimer()
    endif
    if not Cop_Activo then
        set Cop_Activo = true
        call TimerStart(Cop_Reloj, 0.03, true, function Cop_Tick)
    endif
endfunction

// Inicio común de los puentes: jugador (o -1), héroe en Cop_HX/HY, punto en Cop_PX/PY, ángulo y distancia.
function Cop_Inicio takes nothing returns integer
    local unit c = GetTriggerUnit()
    local integer this = s__RapidPair_fromController(c)
    local integer p = GetPlayerId(GetOwningPlayer(c))
    set c = null
    if this == 0 or s__RapidPair_down[this] or not UnitAlive(Game_Hero[p]) or Cop_N >= 190 then
        return -1
    endif
    set Cop_HX = GetUnitX(Game_Hero[p])
    set Cop_HY = GetUnitY(Game_Hero[p])
    set Cop_PX = GetSpellTargetX()
    set Cop_PY = GetSpellTargetY()
    set Cop_LA = Atan2(Cop_PY - Cop_HY, Cop_PX - Cop_HX)
    set Cop_LD = SquareRoot((Cop_PX - Cop_HX) * (Cop_PX - Cop_HX) + (Cop_PY - Cop_HY) * (Cop_PY - Cop_HY))
    return p
endfunction

// Lleva el punto a una distancia entre a y b del héroe (si queda fuera del mapa, deja el punto pulsado).
function Cop_Punto takes real a, real b returns nothing
    local real d = RMinBJ(b, RMaxBJ(a, Cop_LD))
    local real x = Cop_HX + d * Cos(Cop_LA)
    local real y = Cop_HY + d * Sin(Cop_LA)
    if Cop_Dentro(x, y) then
        set Cop_PX = x
        set Cop_PY = y
        set Cop_LD = d
    endif
endfunction

// Copia que sólo hace el gesto junto al héroe y se desvanece.
function Cop_Gesto takes integer p, integer tipo, string anim, integer pasos returns nothing
    local integer i = Cop_Nuevo(p, 8)
    if i >= 0 then
        call Cop_Unidad(i, tipo, Cop_HX, Cop_HY, Cop_LA)
        call SetUnitAnimation(Cop_U[i], anim)
        set Cop_NT[i] = pasos
    endif
endfunction

function Cop_Lanzar takes integer i, string m, integer pasos, real alto returns nothing
    set Cop_SX[i] = Cop_HX
    set Cop_SY[i] = Cop_HY
    set Cop_TX[i] = Cop_PX
    set Cop_TY[i] = Cop_PY
    set Cop_NT[i] = pasos
    set Cop_H[i] = alto
    call Cop_Proyectil(i, m, Cop_HX, Cop_HY, Cop_LA, 60.)
endfunction

// --- Tauren ---
function Cop_Embestida takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    set i = Cop_Nuevo(p, 1)
    if i >= 0 then
        call Cop_Unidad(i, 'hCp0', Cop_HX, Cop_HY, Cop_LA)
        call SetUnitAnimation(Cop_U[i], "stand ready")
        set Cop_Rest[i] = RMinBJ(1000., RMaxBJ(350., Cop_LD))
        set Cop_G[i] = CreateGroup()
        call Cop_Arrancar()
    endif
endfunction

function Cop_Totem takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    call Cop_Punto(150., 900.)
    call Cop_Gesto(p, 'hCp0', "attack", 30)
    set i = Cop_Nuevo(p, 2)
    if i >= 0 then
        call Cop_Lanzar(i, "M_TOTEM", 17, 250.)
        set Cop_G[i] = CreateGroup()
    endif
    call Cop_Arrancar()
endfunction

function Cop_Roca takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    call Cop_Punto(150., 1000.)
    call Cop_Gesto(p, 'hCp0', "attack", 30)
    set i = Cop_Nuevo(p, 3)
    if i >= 0 then
        call Cop_Lanzar(i, "M_ROCA", 20, 350.)
        set Cop_D[i] = 300.
        set Cop_Rest[i] = Cop_LD
    endif
    call Cop_Arrancar()
endfunction

function Cop_Bombardeo takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    call Cop_Punto(0., 900.)
    set i = Cop_Nuevo(p, 6)
    if i >= 0 then
        call Cop_Unidad(i, 'hCp0', Cop_PX, Cop_PY, Cop_LA)
        call SetUnitTimeScale(Cop_U[i], 0.5)
        set Cop_V[i] = Cop_LA * bj_RADTODEG
        set Cop_Rest[i] = 900.
        set Bom_Golpes[p] = 0
        set Bom_Total[p] = 0.
        call Cop_Arrancar()
    endif
endfunction

function Cop_Garra takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    call Cop_Punto(300., 1000.)
    set i = Cop_Nuevo(p, 4)
    if i >= 0 then
        call Cop_Unidad(i, 'hCp2', Cop_PX, Cop_PY, Cop_LA + bj_PI)
        call SetUnitVertexColor(Cop_U[i], 120, 255, 160, 170)
        call SetUnitAnimation(Cop_U[i], "spell morph")
        call DestroyEffect(AddSpecialEffect("FX_espiritu", Cop_PX, Cop_PY))
        call Cop_Arrancar()
    endif
endfunction

function Cop_Rugido takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    call Cop_Punto(0., 700.)
    set i = Cop_Nuevo(p, 5)
    if i >= 0 then
        call Cop_Unidad(i, 'hCp0', Cop_PX, Cop_PY, Cop_LA)
        call Cop_Arrancar()
    endif
endfunction

// --- Cairne ---
function Cop_Grieta takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    call Cop_Gesto(p, 'hCp1', "attack slam", 40)
    set i = Cop_Nuevo(p, 9)
    if i >= 0 then
        set Cop_A[i] = Cop_LA
        set Cop_SX[i] = Cop_HX
        set Cop_SY[i] = Cop_HY
        set Cop_Rest[i] = 900.
        set Cop_TX[i] = Cop_HX + 900. * Cos(Cop_LA)
        set Cop_TY[i] = Cop_HY + 900. * Sin(Cop_LA)
        if not Cop_Dentro(Cop_TX[i], Cop_TY[i]) then
            set Cop_TX[i] = Cop_PX
            set Cop_TY[i] = Cop_PY
            set Cop_Rest[i] = Cop_LD
        endif
    endif
    call Cop_Arrancar()
endfunction

function Cop_Lanza takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    call Cop_Gesto(p, 'hCp1', "attack", 30)
    set i = Cop_Nuevo(p, 10)
    if i >= 0 then
        call Cop_Proyectil(i, "M_LANZA", Cop_HX, Cop_HY, Cop_LA, 60.)
        set Cop_Rest[i] = 1100.
        set Cop_V[i] = 45.
        set Cop_D[i] = 250.
        set Cop_G[i] = CreateGroup()
    endif
    call Cop_Arrancar()
endfunction

function Cop_Espiritu takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    call Cop_Punto(400., 1000.)
    set i = Cop_Nuevo(p, 12)
    if i >= 0 then
        call Cop_Unidad(i, 'hCp1', Cop_HX, Cop_HY, Cop_LA)
        call SetUnitTimeScale(Cop_U[i], 2.)
        call SetUnitAnimation(Cop_U[i], "walk")
        call DestroyEffect(AddSpecialEffect("FX_espiritu", Cop_HX, Cop_HY))
        set Cop_Rest[i] = Cop_LD
        set Cop_G[i] = CreateGroup()
        call Cop_Arrancar()
    endif
endfunction

function Cop_Estampida takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    call Cop_Gesto(p, 'hCp1', "stand victory", 40)
    call DestroyEffect(AddSpecialEffect("FX_rugido", Cop_HX, Cop_HY))
    set i = Cop_Nuevo(p, 15)
    if i >= 0 then
        set Cop_A[i] = Cop_LA
        set Cop_SX[i] = Cop_HX
        set Cop_SY[i] = Cop_HY
    endif
    call Cop_Replica(p, Cop_HX, Cop_HY)
    call Cop_Arrancar()
endfunction

function Cop_Trueno takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    call Cop_Punto(150., 900.)
    call Cop_Gesto(p, 'hCp1', "attack", 30)
    set i = Cop_Nuevo(p, 13)
    if i >= 0 then
        call Cop_Lanzar(i, "M_TRUENO", 17, 250.)
    endif
    call Cop_Arrancar()
endfunction

function Cop_Marca takes nothing returns nothing
    local integer p = Cop_Inicio()
    local unit src
    local player o
    local unit u
    local unit mejor = null
    local integer i
    if p < 0 then
        return
    endif
    set src = Cop_Fuente(p)
    set o = Player(p)
    call Cop_Gesto(p, 'hCp1', "spell slam", 35)
    if Cop_Enum == null then
        set Cop_Enum = CreateGroup()
    endif
    if Cop_Marcados == null then
        set Cop_Marcados = CreateGroup()
    endif
    call GroupEnumUnitsInRange(Cop_Enum, Cop_PX, Cop_PY, 400., null)
    loop
        set u = FirstOfGroup(Cop_Enum)
        exitwhen u == null
        call GroupRemoveUnit(Cop_Enum, u)
        if s__GroundCollision_isTarget(u, src, o) and not IsUnitInGroup(u, Cop_Marcados) then
            if mejor == null or GetUnitState(u, UNIT_STATE_MAX_LIFE) > GetUnitState(mejor, UNIT_STATE_MAX_LIFE) then
                set mejor = u
            endif
        endif
    endloop
    if mejor != null then
        set i = Cop_Nuevo(p, 14)
        if i >= 0 then
            set Cop_Ob[i] = mejor
            set Cop_NT[i] = 100
            set Cop_D[i] = 500.
            set Cop_X[i] = GetUnitX(mejor)
            set Cop_Y[i] = GetUnitY(mejor)
            set Cop_E[i] = AddSpecialEffectTarget("FX_marca", mejor, "overhead")
            call GroupAddUnit(Cop_Marcados, mejor)
        endif
    endif
    call Cop_Arrancar()
    set src = null
    set o = null
    set mejor = null
endfunction

// Espíritus guardianes: 3 copias de Cairne en tres direcciones, 900 a 27 por paso, 250 una vez y apartan 120.
function Cop_Guardianes takes integer p returns nothing
    local unit h = Game_Hero[p]
    local integer k = 0
    local integer i
    local real a = GetUnitFacing(h) * bj_DEGTORAD
    call DestroyEffect(AddSpecialEffect("FX_espiritu", GetUnitX(h), GetUnitY(h)))
    loop
        exitwhen k > 2
        set i = Cop_Nuevo(p, 16)
        if i >= 0 then
            call Cop_Unidad(i, 'hCp1', GetUnitX(h), GetUnitY(h), a + k * 2.0944)
            call SetUnitTimeScale(Cop_U[i], 2.)
            call SetUnitAnimation(Cop_U[i], "walk")
            set Cop_Gen[i] = 1
            set Cop_Rest[i] = 900.
            set Cop_V[i] = 27.
            set Cop_D[i] = 250.
            set Cop_H[i] = 120.
            set Cop_G[i] = CreateGroup()
        endif
        set k = k + 1
    endloop
    call Cop_Arrancar()
    set h = null
endfunction

function Gua_Tick takes nothing returns nothing
    local integer p = 0
    local unit h
    local integer this
    loop
        exitwhen p > 11
        set h = Game_Hero[p]
        if h != null and GetUnitTypeId(h) == 'h006' then
            if Gua_Rise[p] then
                set Gua_Rise[p] = false
                call Cop_Guardianes(p)
            elseif Gua_Ronda[p] != Ronda_Numero and UnitAlive(h) and GetWidgetLife(h) < 0.25 * GetUnitState(h, UNIT_STATE_MAX_LIFE) then
                set this = s__RapidPair_fromController(Game_Ctrl[p])
                if this != 0 and not s__RapidPair_down[this] then
                    set Gua_Ronda[p] = Ronda_Numero
                    call Cop_Guardianes(p)
                endif
            endif
        endif
        set p = p + 1
    endloop
    set h = null
endfunction

'''
COP = COP.replace('Cop_Cos(i)', 'Cos(Cop_A[i])')
for k, v in FX.items():
    COP = COP.replace(f'"FX_{k}"', f'"{v}"')
for k, v in (('M_TOTEM', M_TOTEM), ('M_ROCA', M_ROCA), ('M_LANZA', M_LANZA), ('M_KODO', M_KODO),
             ('M_TRUENO', M_TRUENO)):
    COP = COP.replace(f'"{k}"', f'"{v}"')
assert '"FX_' not in COP and '"M_' not in COP
if prueba:
    COP += '''// v19b-prueba: cada pieza principal al terminar.
function Cop_Anotar takes nothing returns nothing
    call Bolsa_Anotar(Cop_Log)
endfunction

'''
else:
    COP += '''// Sin registro en la versión normal.
function Cop_Anotar takes nothing returns nothing
endfunction

'''
cambia('function Don_Init takes nothing returns nothing\n', COP + 'function Don_Init takes nothing returns nothing\n')
cambia("    call RegisterSpellEffectEvent('ATb1', function Cop_Embestida)\n",
       "    call RegisterSpellEffectEvent('ATb1', function Cop_Embestida)\n"
       "    call RegisterSpellEffectEvent('ATb2', function Cop_Totem)\n"
       "    call RegisterSpellEffectEvent('ATb3', function Cop_Roca)\n"
       "    call RegisterSpellEffectEvent('ATb4', function Cop_Bombardeo)\n"
       "    call RegisterSpellEffectEvent('ATb5', function Cop_Garra)\n"
       "    call RegisterSpellEffectEvent('ATb6', function Cop_Rugido)\n"
       "    call RegisterSpellEffectEvent('ACb1', function Cop_Grieta)\n"
       "    call RegisterSpellEffectEvent('ACb2', function Cop_Lanza)\n"
       "    call RegisterSpellEffectEvent('ACb3', function Cop_Espiritu)\n"
       "    call RegisterSpellEffectEvent('ACb4', function Cop_Estampida)\n"
       "    call RegisterSpellEffectEvent('ACb5', function Cop_Trueno)\n"
       "    call RegisterSpellEffectEvent('ACb6', function Cop_Marca)\n"
       "    set Cop_Marcados = CreateGroup()\n"
       "    call TimerStart(CreateTimer(), 0.25, true, function Gua_Tick)\n")
cambia('''    if id == 'h005' then
        call UnitAddAbility(Game_Ctrl[p], 'ALTb')
    elseif''', '''    if id == 'h005' then
        call UnitAddAbility(Game_Ctrl[p], 'ALTb')
    elseif id == 'h006' then
        call UnitAddAbility(Game_Ctrl[p], 'ALCb')
    elseif''')
# Precarga de las copias y modelos nuevos (junto a la de v19a).
pre = ''.join(f'    call DestroyEffect(AddSpecialEffect("{m}", -12000., 9000.))\n'
              for m in [M_TOTEM, M_ROCA, M_LANZA, M_KODO, M_TRUENO] + [FX[k] for k in
                        ('trueno', 'aturdido', 'rugido', 'espiritu', 'grieta', 'rayo', 'marca', 'explota', 'chispa', 'cura')])
cambia('''    // v18z: runas de las curaciones y sus efectos.
''', '''    // v19b: copias de Cairne y del espíritu, y modelos de las habilidades de Tauren y Cairne.
    call RemoveUnit(CreateUnit(Player(15), 'hCp1', -12000., 9000., 0.))
    call RemoveUnit(CreateUnit(Player(15), 'hCp2', -12000., 9000., 0.))
''' + pre + '''    // v18z: runas de las curaciones y sus efectos.
''')
if prueba:
    n = src.count('lat\\\\v19a-')
    assert n > 0, n
    src = src.replace('lat\\\\v19a-', 'lat\\\\v19b-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19b', 'prueba' if prueba else 'normal')
