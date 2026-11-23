#!/usr/bin/env python3
"""v20u (20/11/2026), fase 4 del rework de habilidades (docs/planes/devmission-rework-habilidades-v20r.md).
Técnicas de un blanco en área. Las 7 que la copia lanza sobre una unidad (Warp Kamehameha A0IA, Imprisonment A0IV,
Death Break A0J1, Heat Dome A086, Burning Slash A03W, Senpuu Odama A0AI, Rasenrengan A0F5) ya repetían su daño a 300
del blanco (Dcp_Eco, v19d). Ahora además:
- Al lanzar, hasta 8 enemigos a 300 del blanco (no jefes, no pausados, no ya juntados) se juntan con él en 0,4 s a 80
  y siguen su movimiento cada 0,04 s: posición, altura de vuelo, giro y pausa. Así reciben el mismo golpe y se ven con
  el blanco. Se sueltan cuando la técnica acaba (0,4 s tranquila: sin motor de D.O.N, copia sin orden, blanco sin
  pausa y en el suelo), si el blanco muere o a los 10 s; al soltarlos se recolocan en suelo transitable.
- Dcp_Eco repite el daño a 12 enemigos (antes 8), para que quepan los juntados y los que llegan.
Uso: v20u.py ENTRADA.j SALIDA.j [prueba]   (normal de v20t; prueba de v20t-prueba)
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


cambia('real array Prc_Listo\n', '''real array Prc_Listo
// v20u: técnicas de un blanco en área: grupos que siguen al blanco (Jun_*), 8 casillas por grupo.
integer Jun_N= 0
unit array Jun_T
unit array Jun_C
integer array Jun_A
integer array Jun_K
integer array Jun_Q
integer array Jun_P
unit array Jun_U
real array Jun_Ang
real array Jun_D0
boolean array Jun_Pz
group Jun_Todos= null
group Jun_Enum= null
timer Jun_Reloj= null
unit Jun_PT= null
unit Jun_PC= null
integer Jun_PA= 0
integer Jun_PP= 0
''')
cambia('// v19d: el daño de la copia o de las piezas del jugador sobre el objetivo se repite a 8 enemigos a 300 de él.',
       '// v19d: el daño de la copia o de las piezas del jugador sobre el objetivo se repite a 12 enemigos a 300 de él (v20u).')
cambia('        if n < 8 and e != u and UnitAlive(e) and IsUnitEnemy(e, Player(p))',
       '        if n < 12 and e != u and UnitAlive(e) and IsUnitEnemy(e, Player(p))')
cambia('''        call TriggerAddAction(Dcp_Tr[i], function Dcp_Eco)
    endif
''', '''        call TriggerAddAction(Dcp_Tr[i], function Dcp_Eco)
        // v20u: los enemigos junto al blanco siguen su movimiento (Jun_Iniciar, más abajo).
        set Jun_PT = t
        set Jun_PC = c
        set Jun_PA = a
        set Jun_PP = p
        call ExecuteFunc("Jun_Iniciar")
        set Jun_PT = null
        set Jun_PC = null
    endif
''')
cambia('function Don_Relevo takes nothing returns nothing\n', '''// v20u: técnicas de un blanco en área. Los enemigos a 300 del blanco al lanzar se juntan con él (a 80 en 0,4 s) y
// siguen su posición, altura, giro y pausa mientras dura la técnica; el daño se lo repite Dcp_Eco.
function Jun_Dentro takes real x, real y returns boolean
    return x > GetRectMinX(bj_mapInitialPlayableArea) + 64. and x < GetRectMaxX(bj_mapInitialPlayableArea) - 64. and y > GetRectMinY(bj_mapInitialPlayableArea) + 64. and y < GetRectMaxY(bj_mapInitialPlayableArea) - 64.
endfunction

function Jun_Soltar takes integer s returns nothing
    local unit u = Jun_U[s]
    if u != null then
        call GroupRemoveUnit(Jun_Todos, u)
        if Jun_Pz[s] then
            call PauseUnit(u, false)
        endif
        if GetUnitTypeId(u) != 0 and UnitAlive(u) then
            if not IsUnitType(u, UNIT_TYPE_FLYING) then
                call SetUnitFlyHeight(u, GetUnitDefaultFlyHeight(u), 0.)
            endif
            call SetUnitPosition(u, GetUnitX(u), GetUnitY(u))
        endif
    endif
    set Jun_U[s] = null
    set Jun_Pz[s] = false
    set u = null
endfunction

function Jun_Cerrar takes integer i returns nothing
    local integer l = Jun_N - 1
    local integer j = 0
    set Cop_Log = "area fin j" + I2S(Jun_P[i]) + " tics " + I2S(Jun_K[i])
    call ExecuteFunc("Cop_Anotar")
    loop
        exitwhen j >= 8
        call Jun_Soltar(i * 8 + j)
        if i < l then
            set Jun_U[i * 8 + j] = Jun_U[l * 8 + j]
            set Jun_Ang[i * 8 + j] = Jun_Ang[l * 8 + j]
            set Jun_D0[i * 8 + j] = Jun_D0[l * 8 + j]
            set Jun_Pz[i * 8 + j] = Jun_Pz[l * 8 + j]
            set Jun_U[l * 8 + j] = null
            set Jun_Pz[l * 8 + j] = false
        endif
        set j = j + 1
    endloop
    if i < l then
        set Jun_T[i] = Jun_T[l]
        set Jun_C[i] = Jun_C[l]
        set Jun_A[i] = Jun_A[l]
        set Jun_K[i] = Jun_K[l]
        set Jun_Q[i] = Jun_Q[l]
        set Jun_P[i] = Jun_P[l]
    endif
    set Jun_T[l] = null
    set Jun_C[l] = null
    set Jun_N = l
endfunction

function Jun_Tick takes nothing returns nothing
    local integer i = 0
    local integer j
    local integer s
    local unit t
    local unit c
    local unit u
    local real tx
    local real ty
    local real h
    local real f
    local real r
    local real x
    local real y
    local boolean pz
    local boolean fin
    loop
        exitwhen i >= Jun_N
        set t = Jun_T[i]
        set c = Jun_C[i]
        set Jun_K[i] = Jun_K[i] + 1
        set fin = Jun_K[i] >= 250 or t == null or GetUnitTypeId(t) == 0 or not UnitAlive(t)
        if not fin then
            if Jun_K[i] >= 25 and not Don_EnCurso(Jun_A[i]) and (GetUnitTypeId(c) == 0 or IsUnitHidden(c) or (not IsUnitPaused(c) and GetUnitCurrentOrder(c) == 0)) and not IsUnitPaused(t) and GetUnitFlyHeight(t) <= GetUnitDefaultFlyHeight(t) + 5. then
                set Jun_Q[i] = Jun_Q[i] + 1
            else
                set Jun_Q[i] = 0
            endif
            set fin = Jun_Q[i] >= 10
        endif
        if fin then
            call Jun_Cerrar(i)
        else
            set tx = GetUnitX(t)
            set ty = GetUnitY(t)
            set h = GetUnitFlyHeight(t)
            set f = GetUnitFacing(t)
            set pz = IsUnitPaused(t)
            set j = 0
            loop
                exitwhen j >= 8
                set s = i * 8 + j
                set u = Jun_U[s]
                if u != null then
                    if GetUnitTypeId(u) == 0 or not UnitAlive(u) then
                        call Jun_Soltar(s)
                    else
                        set r = Jun_D0[s]
                        if r > 80. then
                            set r = 80. + (r - 80.) * RMaxBJ(0., 1. - I2R(Jun_K[i]) / 10.)
                        endif
                        set x = tx + r * Cos(Jun_Ang[s])
                        set y = ty + r * Sin(Jun_Ang[s])
                        if Jun_Dentro(x, y) then
                            call SetUnitX(u, x)
                            call SetUnitY(u, y)
                        endif
                        if not IsUnitType(u, UNIT_TYPE_FLYING) then
                            call SetUnitFlyHeight(u, h, 0.)
                        endif
                        call SetUnitFacing(u, f)
                        if pz and not IsUnitPaused(u) then
                            call PauseUnit(u, true)
                            set Jun_Pz[s] = true
                        elseif not pz and Jun_Pz[s] then
                            call PauseUnit(u, false)
                            set Jun_Pz[s] = false
                        endif
                    endif
                endif
                set j = j + 1
            endloop
            set i = i + 1
        endif
    endloop
    set t = null
    set c = null
    set u = null
endfunction

function Jun_Iniciar takes nothing returns nothing
    local unit t = Jun_PT
    local integer p = Jun_PP
    local integer i
    local integer n = 0
    local integer id
    local unit e
    local real tx
    local real ty
    if Jun_Todos == null then
        set Jun_Todos = CreateGroup()
        set Jun_Enum = CreateGroup()
    endif
    if t == null or not UnitAlive(t) or Jun_N >= 24 then
        set t = null
        return
    endif
    // El nuevo blanco deja el grupo que lo llevaba.
    if IsUnitInGroup(t, Jun_Todos) then
        set i = 0
        loop
            exitwhen i >= Jun_N * 8
            if Jun_U[i] == t then
                call Jun_Soltar(i)
            endif
            set i = i + 1
        endloop
    endif
    set i = Jun_N
    set tx = GetUnitX(t)
    set ty = GetUnitY(t)
    call GroupEnumUnitsInRange(Jun_Enum, tx, ty, 300., null)
    loop
        set e = FirstOfGroup(Jun_Enum)
        exitwhen e == null
        call GroupRemoveUnit(Jun_Enum, e)
        set id = GetUnitTypeId(e)
        if n < 8 and e != t and UnitAlive(e) and IsUnitEnemy(e, Player(p)) and not IsUnitType(e, UNIT_TYPE_STRUCTURE) and GetUnitAbilityLevel(e, 'Aloc') == 0 and not IsUnitPaused(e) and not IsUnitInGroup(e, Jun_Todos) and e != DevJefe and not (id >= 'nj00' and id <= 'nj0A') then
            set Jun_U[i * 8 + n] = e
            set Jun_Ang[i * 8 + n] = Atan2(GetUnitY(e) - ty, GetUnitX(e) - tx)
            set Jun_D0[i * 8 + n] = SquareRoot((GetUnitX(e) - tx) * (GetUnitX(e) - tx) + (GetUnitY(e) - ty) * (GetUnitY(e) - ty))
            set Jun_Pz[i * 8 + n] = false
            call GroupAddUnit(Jun_Todos, e)
            if not IsUnitType(e, UNIT_TYPE_FLYING) and UnitAddAbility(e, 'Amrf') then
                call UnitRemoveAbility(e, 'Amrf')
            endif
            set n = n + 1
        endif
    endloop
    set Cop_Log = "area j" + I2S(p) + " tecnica " + I2S(Jun_PA) + " juntos " + I2S(n)
    call ExecuteFunc("Cop_Anotar")
    if n > 0 then
        set Jun_T[i] = t
        set Jun_C[i] = Jun_PC
        set Jun_A[i] = Jun_PA
        set Jun_K[i] = 0
        set Jun_Q[i] = 0
        set Jun_P[i] = p
        loop
            exitwhen n >= 8
            set Jun_U[i * 8 + n] = null
            set Jun_Pz[i * 8 + n] = false
            set n = n + 1
        endloop
        set Jun_N = i + 1
        if Jun_Reloj == null then
            set Jun_Reloj = CreateTimer()
            call TimerStart(Jun_Reloj, 0.04, true, function Jun_Tick)
        endif
    endif
    set t = null
endfunction

function Don_Relevo takes nothing returns nothing
''')
if prueba:
    for viejo, nuevo in (('lat\\\\v20t-', 'lat\\\\v20u-'), ('v20t-don.txt', 'v20u-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20u', 'prueba' if prueba else 'normal')
