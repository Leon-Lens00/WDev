#!/usr/bin/env python3
"""v16t-gokum (13/11/2026): el movimiento de las habilidades de Goku pasa a Missile de Dev Mission.

Leon (13/11/2026), tras evaluar el movimiento de D.O.N: adaptar las habilidades a nuestro sistema de misiles. La lógica
de D.O.N (tiempos, daños, efectos, sonidos, esperas) no se reescribe: cada trigger periódico de D.O.N que movía una pieza
pierde su temporizador y su acción la ejecuta, paso a paso, un misil de Goku (instancia propia del módulo MissileStruct,
como RapidBolt; la biblioteca Missile no se toca). El misil avanza la pieza y la acción de D.O.N la coloca donde él está.
  1 Kamehameha (Aa, 0,03 s, 60 por paso = 2000/s): la bola. Choca con precipicios y árboles como las balas: el rayo acaba.
  3 Super Dragon Fist (Zx, 0,04 s, paso n8[4411] = 250/s y luego 1625/s): el dragón y Goku con él; Goku choca con
    precipicios y árboles. Si choca antes de lanzarse se queda quieto hasta el lanzamiento, y entonces acaba ahí.
  5 Spirit Bomb (Pa, 0,04 s, 45 por paso = 1125/s): la bomba va por el aire (altura 300), sin choque.
El empuje compartido del Warp Kamehameha (js) sigue con su temporizador de D.O.N, pero el empujado no atraviesa
precipicios ni árboles (trazado de GroundCollision). La teleportación del Warp no cambia (SetUnitPosition ya busca suelo).
Uso: goku_misil.py GLOBALES.j FUNCIONES.j  (los reescribe)
"""
from pathlib import Path
import sys

g_path, f_path = sys.argv[1:3]
f = Path(f_path).read_text(encoding='latin-1')


def una(antes, despues):
    global f
    assert f.count(antes) == 1, (antes, f.count(antes))
    f = f.replace(antes, despues)


# --- sin temporizador propio: los mueve el misil ---
for t, p in [('Aa', '.03'), ('Zx', '.04'), ('Pa', '.04')]:
    una(f'call TriggerRegisterTimerEventPeriodic(GkV_{t},{p})\n', '')
# --- lanzamiento: donde D.O.N encendía el trigger periódico ---
una('call EnableTrigger(GkV_Aa)\n', 'call EnableTrigger(GkV_Aa)\ncall Gk_MisLanzar(1)\n')
una('call EnableTrigger(GkV_Zx)\n', 'call EnableTrigger(GkV_Zx)\ncall Gk_MisLanzar(3)\n')
una('call EnableTrigger(GkV_Pa)\n', 'call EnableTrigger(GkV_Pa)\ncall Gk_MisLanzar(5)\n')
# --- la pieza va donde está el misil (antes: su posición + paso fijo) ---
una('set GkV_c[0]=GkF_fb(GkV_C[0],60.,AngleBetweenPoints(GkV_o[0],GkV_q[0]))\n', 'set GkV_c[0]=Location(Gk_MisX,Gk_MisY)\n')
una('set GkV_r8[4414]=GkF_fb(GkV_r8[4413],I2R(GkV_n8[4411]),AngleBetweenPoints(GkV_r8[4410],GkV_r8[4411]))\n',
    'set GkV_r8[4414]=Location(Gk_MisX,Gk_MisY)\n')
una('set GkV_U4=GkF_fb(GkV_T4,45.,AngleBetweenPoints(GkV_P4,GkV_Q4))\n', 'set GkV_U4=Location(Gk_MisX,Gk_MisY)\n')
# --- el choque termina como el final propio de D.O.N ---
una('function GkF_a07 takes nothing returns boolean\nreturn(GkF_a17())\n',
    'function GkF_a07 takes nothing returns boolean\nreturn(GkF_a17())or(Gk_MisChoque)\n')
una('function GkF_Uu4 takes nothing returns boolean\nreturn(GetBooleanOr(GkF_Uq4(),GkF_Ut4()))\n',
    'function GkF_Uu4 takes nothing returns boolean\nreturn(GetBooleanOr(GkF_Uq4(),GkF_Ut4()))or(Gk_MisChoque and GkV_o8[4410])\n')
# --- empuje del Warp: no atraviesa precipicios ni árboles ---
una('call SetUnitPositionLoc(GkV_zf[GkV_xf],GkV_af[GkV_xf])\n', 'call Gk_Empuje(GkV_xf)\n')
una('function Gk_InitDON takes nothing returns nothing\n', 'function Gk_InitDON takes nothing returns nothing\ncall Gk_MisInit()\n')

GLOB = """integer Gk_MIS = 71
real Gk_MisX = 0.
real Gk_MisY = 0.
boolean Gk_MisChoque = false
integer array Gk_MisTipo
integer array Gk_MisDe
boolean array Gk_MisBloq
real array Gk_MisPx
real array Gk_MisPy
real array Gk_MisAcum
"""

CODIGO = r"""
// v16t-gokum: misiles de Goku (goku_misil.py). Instancia propia del módulo MissileStruct (struct id Gk_MIS), como RapidBolt.
function Gk_MisTrig takes integer k returns trigger
if k == 1 then
return GkV_Aa
elseif k == 3 then
return GkV_Zx
endif
return GkV_Pa
endfunction

function Gk_MisPeriodo takes integer k returns real
if k == 1 then
return .03
endif
return .04
endfunction

function Gk_MisFuente takes integer k returns unit
if k == 1 then
return GkV_Rd[0]
elseif k == 3 then
return GkV_s8[4410]
endif
return GkV_O4
endfunction

// Un paso: el misil ya avanzó; se comprueba el choque y se ejecuta la acción de D.O.N, que coloca la pieza en Gk_MisX/Y.
function Gk_MisPaso takes integer m returns boolean
local integer k = Gk_MisTipo[m]
local trigger t = Gk_MisTrig(k)
local unit u = Gk_MisFuente(k)
local real x = s__Missile_x[m]
local real y = s__Missile_y[m]
if not IsTriggerEnabled(t) then
set t = null
set u = null
return true
endif
if s__Missile_recycle[m] and not Gk_MisBloq[m] then
// llegó al final de su recorrido: se queda ahí y, salvo la bomba, cuenta como choque
set Gk_MisBloq[m] = k != 5
endif
if k != 5 and not Gk_MisBloq[m] then
if s__GroundCollision_trace(Gk_MisPx[m], Gk_MisPy[m], x, y, 24., u, GetOwningPlayer(u), false) != 0 then
set Gk_MisBloq[m] = true
set Gk_MisPx[m] = s__GroundCollision_x
set Gk_MisPy[m] = s__GroundCollision_y
endif
endif
if not Gk_MisBloq[m] then
set Gk_MisPx[m] = x
set Gk_MisPy[m] = y
endif
set Gk_MisX = Gk_MisPx[m]
set Gk_MisY = Gk_MisPy[m]
set Gk_MisChoque = Gk_MisBloq[m]
// la acción de D.O.N conserva su ritmo (contadores y fases por paso): se ejecuta cada 0,03 o 0,04 s acumulados
set Gk_MisAcum[m] = Gk_MisAcum[m] + Missile_TIMER_TIMEOUT
loop
exitwhen Gk_MisAcum[m] < Gk_MisPeriodo(k) - .0001 or not IsTriggerEnabled(t)
set Gk_MisAcum[m] = Gk_MisAcum[m] - Gk_MisPeriodo(k)
call TriggerExecute(t)
endloop
set Gk_MisChoque = false
if k == 3 then
set s__Missile_speed[m] = I2R(GkV_n8[4411]) * 25. * Missile_TIMER_TIMEOUT
endif
set u = null
if not IsTriggerEnabled(t) then
set t = null
return true
endif
set t = null
return false
endfunction

function Gk_MisQuitar takes integer m returns boolean
local integer k = Gk_MisTipo[m]
local trigger t
if k != 0 and Gk_MisDe[k] == m then
set Gk_MisDe[k] = 0
set t = Gk_MisTrig(k)
if k != 5 and IsTriggerEnabled(t) then
set Gk_MisX = Gk_MisPx[m]
set Gk_MisY = Gk_MisPy[m]
set Gk_MisChoque = true
call TriggerExecute(t)
set Gk_MisChoque = false
endif
set t = null
endif
set Gk_MisAcum[m] = 0.
set Gk_MisTipo[m] = 0
set Gk_MisBloq[m] = false
return false
endfunction

function Gk_MisTerminar takes integer node returns nothing
if s__Missile_allocated[node] then
if Gk_MisQuitar(node) and GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID then
call s__Missile__RecycleBin_recycle(s__Missile_dummy[node])
set s__Missile_dummy[node] = null
endif
call s__Missile_terminate(node)
call Missile__StopPeriodic(Gk_MIS)
endif
endfunction

function Gk_MisIterar takes nothing returns boolean
local integer this = s__Missile_Missile__MissileStructure____first[Missile__missileList[Gk_MIS]]
local integer sig
loop
exitwhen this == 0
set sig = s__Missile_Missile__MissileStructure____next[this]
if s__Missile_wantDestroy[this] then
call Gk_MisTerminar(this)
else
if s__Missile_stackSize[this] > 0 then
call s__Missile_updateStack(this)
endif
if s__Missile_allocated[this] and Gk_MisPaso(this) then
call Gk_MisTerminar(this)
endif
endif
set this = sig
endloop
return false
endfunction

function Gk_MisInit takes nothing returns nothing
set Missile__missileList[Gk_MIS] = s__Missile_allocateCollection()
set Missile__expression[Gk_MIS] = Condition(function Gk_MisIterar)
endfunction

// Lanza el misil que mueve la pieza de la habilidad k desde donde está, en la dirección de D.O.N.
function Gk_MisLanzar takes integer k returns nothing
local integer m
local unit p
local real a
local real v
local real x
local real y
local real d
if k == 1 then
set p = GkV_a[0]
set a = Atan2(GetLocationY(GkV_q[0]) - GetLocationY(GkV_o[0]), GetLocationX(GkV_q[0]) - GetLocationX(GkV_o[0]))
set v = 60. / .03
elseif k == 3 then
set p = GkV_s8[4413]
set a = Atan2(GetLocationY(GkV_r8[4411]) - GetLocationY(GkV_r8[4410]), GetLocationX(GkV_r8[4411]) - GetLocationX(GkV_r8[4410]))
set v = I2R(GkV_n8[4411]) / .04
else
set p = GkV_S4
set a = Atan2(GetLocationY(GkV_Q4) - GetLocationY(GkV_P4), GetLocationX(GkV_Q4) - GetLocationX(GkV_P4))
set v = 45. / .04
endif
if Gk_MisDe[k] != 0 then
call s__Missile_destroy(Gk_MisDe[k])
set Gk_MisDe[k] = 0
endif
if p == null then
return
endif
set x = GetUnitX(p)
set y = GetUnitY(p)
set d = 8000.
if Cos(a) > .001 then
set d = RMinBJ(d, (s__WorldBounds_maxX - 64. - x) / Cos(a))
elseif Cos(a) < -.001 then
set d = RMinBJ(d, (s__WorldBounds_minX + 64. - x) / Cos(a))
endif
if Sin(a) > .001 then
set d = RMinBJ(d, (s__WorldBounds_maxY - 64. - y) / Sin(a))
elseif Sin(a) < -.001 then
set d = RMinBJ(d, (s__WorldBounds_minY + 64. - y) / Sin(a))
endif
set d = RMaxBJ(d, 1.)
set m = s__Missile_createXYZ(x, y, 0., x + d * Cos(a), y + d * Sin(a), 0.)
set s__Missile_owner[m] = GetOwningPlayer(p)
set s__Missile_collision[m] = 0.
set s__Missile_speed[m] = v * Missile_TIMER_TIMEOUT
set Gk_MisTipo[m] = k
set Gk_MisBloq[m] = false
set Gk_MisAcum[m] = 0.
set Gk_MisPx[m] = x
set Gk_MisPy[m] = y
set Gk_MisDe[k] = m
call s__Missile_insertFront(Missile__missileList[Gk_MIS], m)
call Missile__StartPeriodic(Gk_MIS)
set p = null
endfunction

// Empuje compartido de D.O.N (js): el paso se corta en precipicios y árboles y el empuje acaba ahí.
function Gk_Empuje takes integer i returns nothing
local unit u = GkV_zf[i]
if s__GroundCollision_trace(GetLocationX(GkV_Af[i]), GetLocationY(GkV_Af[i]), GetLocationX(GkV_af[i]), GetLocationY(GkV_af[i]), 16., u, GetOwningPlayer(u), false) != 0 then
call MoveLocation(GkV_af[i], s__GroundCollision_x, s__GroundCollision_y)
set GkV_Bf[i] = 0
endif
call SetUnitPositionLoc(u, GkV_af[i])
set u = null
endfunction
"""
# Los helpers van antes de su primer uso (I0, el empuje, es de las primeras funciones del trasplante).
f = CODIGO.lstrip('\n') + f
for n in ['Gk_MisLanzar(1)', 'Gk_MisLanzar(3)', 'Gk_MisLanzar(5)', 'Gk_Empuje(', 'Gk_MisInit()']:
    assert f.index('function ' + n.split('(')[0]) < f.index('call ' + n), n
Path(f_path).write_text(f, encoding='latin-1')
Path(g_path).write_text(Path(g_path).read_text(encoding='latin-1') + GLOB, encoding='latin-1')
print('misiles: Kamehameha, Super Dragon Fist y Spirit Bomb con Missile; empuje con choque')
