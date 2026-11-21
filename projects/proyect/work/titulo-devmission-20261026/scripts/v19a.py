#!/usr/bin/env python3
"""v19a (18/11/2026): copia espiritual y Embestida espiritual del Tauren (primera habilidad hecha por la copia).

Leon (18/11/2026): "al castear se crea una copia dummy del personaje invulnerable y esa hace los cast"; vale también
para los de D.O.N más adelante. Medidas de referencia: CHARGE de Gaven (Impossible Bosses BetaV3V, sólo ideas y
números; código propio).
- Libro: el Tauren ('h005') recibe 'ALTb' (Embestida espiritual); Cairne sigue con 'ALTa'.
- Copia ('hCp0', objetos_v19a.py): aparece en la posición del héroe mirando al punto, translúcida y azulada
  (140, 210, 255, alfa 150), del jugador, invulnerable y sin selección. El héroe no recibe ninguna orden.
- Embestida: 0,2 s de amago (Stand Ready); carga hacia el punto (de 350 a 1000) a 1100/s con Walk a 250 %; cada
  enemigo que toca a 140 recibe 300 (una vez) y se aparta 180 hacia su lado de la línea en 0,15 s. Para antes si el
  suelo no es transitable. Al final Attack Slam a 150 %: en el impacto (0,36 s) 500 a 260 alrededor del punto 120
  delante, pisotón de guerra y empujón 150 hacia fuera. Luego se desvanece en 0,3 s.
- Daño: fuente la copia (cuenta para el jugador), con Her_Dano (Filo y crítico de las cartas) y Barras_Golpe.
- Hasta 24 copias a la vez; un reloj de 0,03 s para copias y empujones (128 a la vez).
Prueba: cada embestida anota golpes y daño al terminar (lat\\v19a-bolsas.txt vía Bolsa_Anotar).
Uso: v19a.py ENTRADA.j SALIDA.j [prueba]
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


cambia('integer Cur_N = 0\n', 'integer Cur_N = 0\n'
       'unit array Cop_U\ninteger array Cop_P\nreal array Cop_A\nreal array Cop_Rest\ninteger array Cop_Fase\n'
       'integer array Cop_K\ngroup array Cop_G\ninteger array Cop_Golpes\nreal array Cop_Total\ninteger Cop_N = 0\n'
       'timer Cop_Reloj = null\ngroup Cop_Enum = null\nstring Cop_Log = ""\n'
       'unit array Emp_U\nreal array Emp_VX\nreal array Emp_VY\ninteger array Emp_K\ninteger Emp_N = 0\n')

COP = r'''// v19a: copia espiritual. Las habilidades las hace una copia invulnerable; el héroe sigue libre (Leon, 18/11/2026).
function Cop_Crear takes integer p, integer tipo, real x, real y, real ang returns unit
    local unit u = CreateUnit(Player(p), tipo, x, y, ang * bj_RADTODEG)
    call SetUnitVertexColor(u, 140, 210, 255, 150)
    call SetUnitPathing(u, false)
    return u
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

function Cop_EmpujesTick takes nothing returns nothing
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
            if IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
                set Emp_K[i] = 0
            else
                call SetUnitX(Emp_U[i], x)
                call SetUnitY(Emp_U[i], y)
                set Emp_K[i] = Emp_K[i] - 1
            endif
        endif
        set i = i - 1
    endloop
endfunction

// Daña a los enemigos a r de (x, y). unaVez: sólo los que la copia no golpeó aún (carga); lateral: aparta hacia su
// lado de la línea de la carga, si no hacia fuera de (x, y).
function Cop_Golpear takes integer i, real x, real y, real r, real dano, real emp, boolean unaVez, boolean lateral returns nothing
    local unit c = Cop_U[i]
    local player o = Player(Cop_P[i])
    local unit u
    local real a
    local real d
    if Cop_Enum == null then
        set Cop_Enum = CreateGroup()
    endif
    set s__GroundCollision_shaped = true
    call GroupEnumUnitsInRange(Cop_Enum, x, y, r + 128., null)
    loop
        set u = FirstOfGroup(Cop_Enum)
        exitwhen u == null
        call GroupRemoveUnit(Cop_Enum, u)
        if s__GroundCollision_isTarget(u, c, o) and s__GroundCollision_touches(u, x, y, r) and not (unaVez and IsUnitInGroup(u, Cop_G[i])) then
            if unaVez then
                call GroupAddUnit(Cop_G[i], u)
            endif
            set d = Her_Dano(Cop_P[i], dano)
            call UnitDamageTarget(c, u, d, false, false, Dano_Ataque(6), Dano_TipoArma, null)
            call Barras_Golpe(c, u)
            set Cop_Golpes[i] = Cop_Golpes[i] + 1
            set Cop_Total[i] = Cop_Total[i] + d
            if lateral then
                set a = Cop_A[i] + bj_PI / 2.
                if Cos(Cop_A[i]) * (GetUnitY(u) - y) - Sin(Cop_A[i]) * (GetUnitX(u) - x) < 0. then
                    set a = Cop_A[i] - bj_PI / 2.
                endif
            else
                set a = Atan2(GetUnitY(u) - y, GetUnitX(u) - x)
            endif
            call Cop_Empujar(u, a, emp)
        endif
    endloop
    set s__GroundCollision_shaped = false
    set c = null
    set o = null
endfunction

function Cop_Quitar takes integer i returns nothing
    call RemoveUnit(Cop_U[i])
    call DestroyGroup(Cop_G[i])
    set Cop_N = Cop_N - 1
    set Cop_U[i] = Cop_U[Cop_N]
    set Cop_P[i] = Cop_P[Cop_N]
    set Cop_A[i] = Cop_A[Cop_N]
    set Cop_Rest[i] = Cop_Rest[Cop_N]
    set Cop_Fase[i] = Cop_Fase[Cop_N]
    set Cop_K[i] = Cop_K[Cop_N]
    set Cop_G[i] = Cop_G[Cop_N]
    set Cop_Golpes[i] = Cop_Golpes[Cop_N]
    set Cop_Total[i] = Cop_Total[Cop_N]
    set Cop_U[Cop_N] = null
    set Cop_G[Cop_N] = null
endfunction

// Embestida: fase 0 amago (7 pasos), 1 carga (33 por paso), 2 golpe (impacto al paso 12, fin al 30), 3 desvanecer.
function Cop_Tick takes nothing returns nothing
    local integer i = Cop_N - 1
    local unit u
    local real x
    local real y
    local real s
    loop
        exitwhen i < 0
        set u = Cop_U[i]
        set Cop_K[i] = Cop_K[i] + 1
        if Cop_Fase[i] == 0 then
            if Cop_K[i] >= 7 then
                set Cop_Fase[i] = 1
                set Cop_K[i] = 0
                call SetUnitTimeScale(u, 2.5)
                call SetUnitAnimation(u, "walk")
            endif
        elseif Cop_Fase[i] == 1 then
            set s = RMinBJ(33., Cop_Rest[i])
            set x = GetUnitX(u) + s * Cos(Cop_A[i])
            set y = GetUnitY(u) + s * Sin(Cop_A[i])
            if s <= 0. or IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
                set Cop_Fase[i] = 2
                set Cop_K[i] = 0
                call SetUnitTimeScale(u, 1.5)
                call SetUnitAnimation(u, "attack slam")
            else
                call SetUnitX(u, x)
                call SetUnitY(u, y)
                set Cop_Rest[i] = Cop_Rest[i] - s
                call Cop_Golpear(i, x, y, 140., 300., 180., true, true)
                if ModuloInteger(Cop_K[i], 3) == 0 then
                    call DestroyEffect(AddSpecialEffect("Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl", x, y))
                endif
            endif
        elseif Cop_Fase[i] == 2 then
            if Cop_K[i] == 12 then
                set x = GetUnitX(u) + 120. * Cos(Cop_A[i])
                set y = GetUnitY(u) + 120. * Sin(Cop_A[i])
                call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y))
                call Cop_Golpear(i, x, y, 260., 500., 150., false, false)
            elseif Cop_K[i] >= 30 then
                set Cop_Fase[i] = 3
                set Cop_K[i] = 0
                call SetUnitTimeScale(u, 1.)
            endif
        else
            call SetUnitVertexColor(u, 140, 210, 255, 150 - 15 * Cop_K[i])
            if Cop_K[i] >= 10 then
                set Cop_Log = "embestida j" + I2S(Cop_P[i]) + " golpes " + I2S(Cop_Golpes[i]) + " dano " + I2S(R2I(Cop_Total[i]))
                call ExecuteFunc("Cop_Anotar")
                call Cop_Quitar(i)
            endif
        endif
        set i = i - 1
    endloop
    call Cop_EmpujesTick()
    if Cop_N == 0 and Emp_N == 0 then
        call PauseTimer(Cop_Reloj)
    endif
    set u = null
endfunction

// Puente 'ATb1' del controlador: la copia carga hacia el punto; el héroe no recibe ninguna orden.
function Cop_Embestida takes nothing returns nothing
    local unit c = GetTriggerUnit()
    local integer this = s__RapidPair_fromController(c)
    local integer p = GetPlayerId(GetOwningPlayer(c))
    local unit h = Game_Hero[p]
    local real x
    local real y
    local real d
    if this == 0 or s__RapidPair_down[this] or not UnitAlive(h) or Cop_N >= 24 then
        set c = null
        set h = null
        return
    endif
    set x = GetUnitX(h)
    set y = GetUnitY(h)
    set d = SquareRoot((GetSpellTargetX() - x) * (GetSpellTargetX() - x) + (GetSpellTargetY() - y) * (GetSpellTargetY() - y))
    set Cop_A[Cop_N] = Atan2(GetSpellTargetY() - y, GetSpellTargetX() - x)
    set Cop_U[Cop_N] = Cop_Crear(p, 'hCp0', x, y, Cop_A[Cop_N])
    call SetUnitAnimation(Cop_U[Cop_N], "stand ready")
    set Cop_P[Cop_N] = p
    set Cop_Rest[Cop_N] = RMinBJ(1000., RMaxBJ(350., d))
    set Cop_Fase[Cop_N] = 0
    set Cop_K[Cop_N] = 0
    set Cop_G[Cop_N] = CreateGroup()
    set Cop_Golpes[Cop_N] = 0
    set Cop_Total[Cop_N] = 0.
    set Cop_N = Cop_N + 1
    if Cop_Reloj == null then
        set Cop_Reloj = CreateTimer()
    endif
    call TimerStart(Cop_Reloj, 0.03, true, function Cop_Tick)
    set c = null
    set h = null
endfunction

'''
if prueba:
    COP += '''// v19a-prueba: cada embestida al terminar.
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
cambia('    call Don_MotInit()\n', "    call Don_MotInit()\n    call RegisterSpellEffectEvent('ATb1', function Cop_Embestida)\n")
cambia('''    if id != 'hGok' and id != 'hFrz' and id != 'hTrk' and id != 'hNar' then
        call UnitAddAbility(Game_Ctrl[p], 'ALTa')
    endif
''', '''    if id == 'h005' then
        call UnitAddAbility(Game_Ctrl[p], 'ALTb')
    elseif id != 'hGok' and id != 'hFrz' and id != 'hTrk' and id != 'hNar' then
        call UnitAddAbility(Game_Ctrl[p], 'ALTa')
    endif
''')
# Precarga de la copia y de los efectos nuevos.
cambia('''    // v18z: runas de las curaciones y sus efectos.
''', '''    // v19a: copia espiritual del Tauren y efectos de la Embestida.
    call RemoveUnit(CreateUnit(Player(15), 'hCp0', -12000., 9000., 0.))
    call DestroyEffect(AddSpecialEffect("Objects\\\\Spawnmodels\\\\Undead\\\\ImpaleTargetDust\\\\ImpaleTargetDust.mdl", -12000., 9000.))
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Orc\\\\WarStomp\\\\WarStompCaster.mdl", -12000., 9000.))
    // v18z: runas de las curaciones y sus efectos.
''')
if prueba:
    n = src.count('lat\\\\v18z-')
    assert n > 0, n
    src = src.replace('lat\\\\v18z-', 'lat\\\\v19a-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19a', 'prueba' if prueba else 'normal')
