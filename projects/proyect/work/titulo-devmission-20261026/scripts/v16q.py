#!/usr/bin/env python3
"""v16q (08/11/2026): balas de RapidBolt baratas y sin cortes por el límite de operaciones.

Informe: Proyect/informes/errores/2026-11-08-152941-estres-misiles-limite-operaciones.md. Con 8 tiradores de MP5 la
pasada de RapidBolt superaba el límite de operaciones, las balas sin resolver se acumulaban (4096) y el juego se
colgaba. Tres cambios, sólo para las balas (GroundCollision_trace sigue igual para el héroe, el dash y el bot):

1. Bala_Barrer sustituye a RapidBolt_sweep -> GroundCollision_trace(units=true):
   - una sola búsqueda de unidades por bala y tick (centro del tramo, radio medio tramo + radio + 256, que contiene
     todos los círculos de radio + 256 que antes se buscaban en cada paso) y prueba exacta del primer contacto del
     círculo de la bala con el cuerpo (UnitHitShape) a lo largo del tramo; sin forma registrada, IsUnitInRangeXY en
     el punto más cercano del tramo, como antes;
   - paredes y árboles con GroundCollision_clear en el centro de casillas de 16, guardado en una tabla por casilla y
     radio de bala (6, 16,2, 18 y 30); otros radios se calculan sin tabla. Pasos de 16 en lugar de 8. La tabla se
     vacía (Bala_Epoca) al empezar cada ronda; en partida nada mata árboles ni crea bloqueos de terreno.
   - el orden pared/unidad es el de antes: gana la pared si está en el mismo paso o antes que el contacto.
   - se quita GetLocationZ por paso, que no se usaba.
2. RapidBolt_missileIterateP recorre las balas en tandas de 16 con TriggerEvaluate (cada tanda tiene su propio
   límite de operaciones), como Missile_move. El cursor avanza antes de procesar cada bala: si una tanda se cortara,
   la siguiente sigue con la bala siguiente y no se repite ninguna.
Uso: v16q.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

N = '\r\n'
ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')

s = once(s, 'integer Ronda_Numero = 1\n', '''integer Ronda_Numero = 1
hashtable Bala_Rejilla= InitHashtable()
integer Bala_Epoca= 1
integer Bala_Cursor= 0
trigger Bala_Tanda= null
''')

BARRER = '''    // v16q: la pared o el árbol en el centro de la casilla de 16 de (px, py) para una bala de radio r, guardado por
    // casilla: bits 2k (calculado) y 2k+1 (bloqueado) de la clase pot = 4^k; encima, la época de la ronda.
    function Bala_Clase takes real r returns integer
        if r == 6. then
            return 1
        elseif r == 16.2 then
            return 4
        elseif r == 18. then
            return 16
        elseif r == 30. then
            return 64
        endif
        return 0
    endfunction

    function Bala_Libre takes real px,real py,real r,integer pot returns boolean
        local integer ix
        local integer iy
        local integer v
        local integer q
        local boolean libre
        if pot == 0 or px <= s__WorldBounds_minX or py <= s__WorldBounds_minY then
            return s__GroundCollision_clear(px , py , r)
        endif
        set ix=R2I(( px - s__WorldBounds_minX ) / 16.)
        set iy=R2I(( py - s__WorldBounds_minY ) / 16.)
        set v=LoadInteger(Bala_Rejilla, ix, iy)
        if v / 256 != Bala_Epoca then
            set v=Bala_Epoca * 256
        endif
        set q=( v - ( v / 256 ) * 256 ) / pot
        if q - ( q / 2 ) * 2 == 1 then
            set q=q / 2
            return q - ( q / 2 ) * 2 == 0
        endif
        set libre=s__GroundCollision_clear(s__WorldBounds_minX + ix * 16 + 8. , s__WorldBounds_minY + iy * 16 + 8. , r)
        if libre then
            set v=v + pot
        else
            set v=v + 3 * pot
        endif
        call SaveInteger(Bala_Rejilla, ix, iy, v)
        return libre
    endfunction

    // v16q: el tramo prev -> actual de la bala m. 0 libre, 1 pared (x, y = último punto libre), 2 unidad (hit; x, y =
    // primer contacto). Mismos resultados globales que GroundCollision_trace.
    function Bala_Barrer takes integer m returns integer
        local real ax= s__Missile_prevX[m]
        local real ay= s__Missile_prevY[m]
        local real dx= s__Missile_x[m] - ax
        local real dy= s__Missile_y[m] - ay
        local real r= s__RapidBolt_hitRadius[m]
        local real l2= dx * dx + dy * dy
        local real l= SquareRoot(l2)
        local unit src= s__RapidBolt_source[m]
        local player owner= s__RapidBolt_owner[m]
        local group skip= Bala_Grupo[m]
        local integer pot= Bala_Clase(r)
        local integer steps= R2I(l / 16.) + 1
        local integer i= 1
        local real mejor= 2.
        local unit blanco= null
        local unit u
        local real body
        local real ex
        local real ey
        local real tp
        local real h2
        local real rr
        local real s0
        local real s1
        local real lim
        local real nx
        local real ny
        set s__GroundCollision_x=ax
        set s__GroundCollision_y=ay
        set s__GroundCollision_hit=null
        set s__GroundCollision_reason=0
        call GroupEnumUnitsInRange(s__GroundCollision_targets, ax + dx * 0.5, ay + dy * 0.5, l * 0.5 + r + 256., null)
        loop
            set u=FirstOfGroup(s__GroundCollision_targets)
            exitwhen u == null
            call GroupRemoveUnit(s__GroundCollision_targets, u)
            if s__GroundCollision_isTarget(u , src , owner) and not IsUnitInGroup(u, skip) then
                set ex=GetUnitX(u) - ax
                set ey=GetUnitY(u) - ay
                if l2 > 0. then
                    set tp=( ex * dx + ey * dy ) / l2
                else
                    set tp=0.
                endif
                set body=s__UnitHitShape_radius(u)
                if body >= 0. then
                    set rr=( r + body ) * ( r + body )
                    set h2=ex * ex + ey * ey - tp * tp * l2
                    if h2 <= rr then
                        if l > 0. then
                            set s0=tp - SquareRoot(rr - h2) / l
                            set s1=tp + SquareRoot(rr - h2) / l
                        else
                            set s0=0.
                            set s1=0.
                            if ex * ex + ey * ey > rr then
                                set s0=2.
                            endif
                        endif
                        if s0 < 0. then
                            set s0=0.
                        endif
                        if s1 >= 0. and s0 <= 1. and s0 < mejor then
                            set mejor=s0
                            set blanco=u
                        endif
                    endif
                else
                    if tp < 0. then
                        set tp=0.
                    elseif tp > 1. then
                        set tp=1.
                    endif
                    if tp < mejor and IsUnitInRangeXY(u, ax + dx * tp, ay + dy * tp, r) then
                        set mejor=tp
                        set blanco=u
                    endif
                endif
            endif
        endloop
        // Paredes hasta el paso del contacto; si coinciden en el mismo paso, gana la pared (como antes).
        set lim=I2R(steps)
        if blanco != null then
            set lim=mejor * I2R(steps) + 1.
        endif
        loop
            exitwhen i > steps or I2R(i) > lim
            set nx=ax + dx * I2R(i) / I2R(steps)
            set ny=ay + dy * I2R(i) / I2R(steps)
            if not Bala_Libre(nx , ny , r , pot) then
                set s__GroundCollision_reason=1
                set blanco=null
                exitwhen true
            endif
            set s__GroundCollision_x=nx
            set s__GroundCollision_y=ny
            set i=i + 1
        endloop
        if blanco != null then
            set s__GroundCollision_hit=blanco
            set s__GroundCollision_x=ax + dx * mejor
            set s__GroundCollision_y=ay + dy * mejor
            set s__GroundCollision_reason=2
        endif
        set src=null
        set owner=null
        set skip=null
        set blanco=null
        set u=null
        return s__GroundCollision_reason
    endfunction

    function s__RapidBolt_sweep takes integer m returns integer
'''
i = s.index('    function s__RapidBolt_sweep takes integer m returns integer\r\n')
j = s.index('    endfunction\r\n', i) + len('    endfunction\r\n')
s = s[:i] + BARRER.replace('\n', N) + '        return Bala_Barrer(m)\r\n    endfunction\r\n' + s[j:]

ITER = '''        // v16q: tandas de 16 balas, cada una con su propio límite de operaciones (ver v16q.py).
        function Bala_TandaP takes nothing returns boolean
            local integer this= Bala_Cursor
            local integer n= 0
            loop
                exitwhen 0 == this or n == 16
                set Bala_Cursor=(s__Missile_Missile__MissileStructure____next[(this)])
                if s__Missile_wantDestroy[this] then
                    call s__RapidBolt_missileTerminateP(this)
                else
                    if s__Missile_stackSize[this] > 0 then
                        call s__Missile_updateStack(this)
                    endif
                    // Runs when the destination is reached.
                    if s__Missile_recycle[this] and s__Missile_allocated[this] then
                        if s__RapidBolt_onFinish(this) then
                            call s__RapidBolt_missileTerminateP(this)
                        endif
                    endif
                    // Runs every Missile_TIMER_TIMEOUT.
                    if s__Missile_allocated[this] and (s__RapidBolt_resolve((this))) then
                        call s__RapidBolt_missileTerminateP(this)
                    endif
                endif
                set n=n + 1
                set this=Bala_Cursor
            endloop
            return 0 == Bala_Cursor
        endfunction

        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__RapidBolt_missileIterateP takes nothing returns boolean
            local integer i= 0
            if Bala_Tanda == null then
                set Bala_Tanda=CreateTrigger()
                call TriggerAddCondition(Bala_Tanda, Condition(function Bala_TandaP))
            endif
            set Bala_Cursor=(s__Missile_Missile__MissileStructure____first[(Missile__missileList[si__RapidBolt])])
            loop
                exitwhen 0 == Bala_Cursor or i == 600
                call TriggerEvaluate(Bala_Tanda)
                set i=i + 1
            endloop
            return false
        endfunction
'''
i = s.index('        // Runs every Missile_TIMER_TIMEOUT for this struct.\r\n        function s__RapidBolt_missileIterateP')
j = s.index('        endfunction\r\n', i) + len('        endfunction\r\n')
s = s[:i] + ITER.replace('\n', N) + s[j:]

# Tabla vacía en cada ronda (por si algo cambiara el terreno entre rondas).
s = once(s, '    call DevWave_Start(Ronda_Numero)\n', '    set Bala_Epoca = Bala_Epoca + 1\n    call DevWave_Start(Ronda_Numero)\n')

Path(sal).write_text(s, encoding='latin-1', newline='')
print('v16q')
