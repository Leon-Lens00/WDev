#!/usr/bin/env python3
"""v16s (08/11/2026): búsqueda de unidades de cada bala ajustada a los cuerpos normales.

Informe: Proyect/informes/errores/2026-11-08-152941-estres-misiles-limite-operaciones.md. La medición por modos de v16r
(perfil-v16r/20261108-163450) dejó a SPAS-12 con 8 tiradores en 5,2 fps, con 393 tandas cortadas en 15 s. Sin colisión
daba 20,4 fps y no se cortaba ninguna tanda. Bala_Barrer buscaba unidades en medio tramo + radio + 256 alrededor de
cada bala, para no perder el cuerpo más grande (nj0A, 389). Con la multitud alrededor de los héroes, cada perdigón
recorría casi todos los enemigos en JASS.

1. La búsqueda por bala usa medio tramo + radio + 80 (todos los cuerpos de enemigo normal salvo ntrg 108 y ntrd 144,
   élites y jefes).
2. Las unidades con cuerpo > 80 van en una lista aparte (Bala_Grande), rehecha cada 8 ticks (0,25 s) desde la pasada
   de balas. Cada bala las prueba una a una con su cuerpo exacto. Límite: una unidad grande recién aparecida puede
   tardar hasta 0,25 s en entrar en la lista; mientras tanto sólo la toca una bala que pase a menos de radio + 80 de
   su centro.
3. Tandas de 4 balas (antes 8).
La prueba exacta del primer contacto, las paredes y el orden pared/unidad no cambian (Bala_Probar es el mismo cálculo
que hacía el bucle de Bala_Barrer).
Uso: v16s.py ENTRADA.j SALIDA.j   (ENTRADA = v16r/war3map.j)
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

N = '\r\n'
ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')

s = once(s, 'boolean Par_Ajustar= false\n', '''boolean Par_Ajustar= false
unit array Bala_Grande
integer Bala_Grandes= 0
integer Bala_Tic= 0
group Bala_GrupoG= CreateGroup()
real Bala_AX= 0.
real Bala_AY= 0.
real Bala_DX= 0.
real Bala_DY= 0.
real Bala_L2= 0.
real Bala_L= 0.
real Bala_R= 0.
real Bala_Mejor= 2.
unit Bala_Blanco= null
unit Bala_Src= null
player Bala_Owner= null
group Bala_Skip= null
''')

BARRER = '''    // v16s: unidades con cuerpo > 80; la búsqueda por bala sólo cubre cuerpos de hasta 80.
    function Bala_EsGrande takes nothing returns boolean
        local unit u= GetFilterUnit()
        local boolean b= GetUnitTypeId(u) != 0 and GetWidgetLife(u) > 0.405 and s__UnitHitShape_radius(u) > 80.
        set u=null
        return b
    endfunction

    function Bala_Rehacer takes nothing returns nothing
        local unit u
        local integer i= 0
        loop
            exitwhen i >= Bala_Grandes
            set Bala_Grande[i]=null
            set i=i + 1
        endloop
        set Bala_Grandes=0
        call GroupEnumUnitsInRect(Bala_GrupoG, bj_mapInitialPlayableArea, Filter(function Bala_EsGrande))
        loop
            set u=FirstOfGroup(Bala_GrupoG)
            exitwhen u == null
            call GroupRemoveUnit(Bala_GrupoG, u)
            if Bala_Grandes < 400 then
                set Bala_Grande[Bala_Grandes]=u
                set Bala_Grandes=Bala_Grandes + 1
            endif
        endloop
        set u=null
    endfunction

    // v16s: el primer contacto del círculo de la bala (Bala_R) con el cuerpo de u a lo largo del tramo; guarda el
    // menor en Bala_Mejor / Bala_Blanco. Mismo cálculo que el bucle de v16q.
    function Bala_Probar takes unit u returns nothing
        local real ex
        local real ey
        local real tp
        local real h2
        local real rr
        local real s0
        local real s1
        local real body
        if not s__GroundCollision_isTarget(u , Bala_Src , Bala_Owner) or IsUnitInGroup(u, Bala_Skip) then
            return
        endif
        set ex=GetUnitX(u) - Bala_AX
        set ey=GetUnitY(u) - Bala_AY
        if Bala_L2 > 0. then
            set tp=( ex * Bala_DX + ey * Bala_DY ) / Bala_L2
        else
            set tp=0.
        endif
        set body=s__UnitHitShape_radius(u)
        if body >= 0. then
            set rr=( Bala_R + body ) * ( Bala_R + body )
            set h2=ex * ex + ey * ey - tp * tp * Bala_L2
            if h2 <= rr then
                if Bala_L > 0. then
                    set s0=tp - SquareRoot(rr - h2) / Bala_L
                    set s1=tp + SquareRoot(rr - h2) / Bala_L
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
                if s1 >= 0. and s0 <= 1. and s0 < Bala_Mejor then
                    set Bala_Mejor=s0
                    set Bala_Blanco=u
                endif
            endif
        else
            if tp < 0. then
                set tp=0.
            elseif tp > 1. then
                set tp=1.
            endif
            if tp < Bala_Mejor and IsUnitInRangeXY(u, Bala_AX + Bala_DX * tp, Bala_AY + Bala_DY * tp, Bala_R) then
                set Bala_Mejor=tp
                set Bala_Blanco=u
            endif
        endif
    endfunction

    // v16q/v16s: el tramo prev -> actual de la bala m. 0 libre, 1 pared (x, y = último punto libre), 2 unidad (hit;
    // x, y = primer contacto). Mismos resultados globales que GroundCollision_trace.
    function Bala_Barrer takes integer m returns integer
        local real ax= s__Missile_prevX[m]
        local real ay= s__Missile_prevY[m]
        local real dx= s__Missile_x[m] - ax
        local real dy= s__Missile_y[m] - ay
        local real r= s__RapidBolt_hitRadius[m]
        local real l2= dx * dx + dy * dy
        local real l= SquareRoot(l2)
        local integer pot= Bala_Clase(r)
        local integer steps= R2I(l / 16.) + 1
        local integer i= 1
        local real lim
        local real nx
        local real ny
        local unit u
        local unit blanco
        set s__GroundCollision_x=ax
        set s__GroundCollision_y=ay
        set s__GroundCollision_hit=null
        set s__GroundCollision_reason=0
        set Bala_AX=ax
        set Bala_AY=ay
        set Bala_DX=dx
        set Bala_DY=dy
        set Bala_L2=l2
        set Bala_L=l
        set Bala_R=r
        set Bala_Mejor=2.
        set Bala_Blanco=null
        set Bala_Src=s__RapidBolt_source[m]
        set Bala_Owner=s__RapidBolt_owner[m]
        set Bala_Skip=Bala_Grupo[m]
        call GroupEnumUnitsInRange(s__GroundCollision_targets, ax + dx * 0.5, ay + dy * 0.5, l * 0.5 + r + 80., null)
        loop
            set u=FirstOfGroup(s__GroundCollision_targets)
            exitwhen u == null
            call GroupRemoveUnit(s__GroundCollision_targets, u)
            call Bala_Probar(u)
        endloop
        set i=0
        loop
            exitwhen i >= Bala_Grandes
            call Bala_Probar(Bala_Grande[i])
            set i=i + 1
        endloop
        set blanco=Bala_Blanco
        // Paredes hasta el paso del contacto; si coinciden en el mismo paso, gana la pared (como antes).
        set i=1
        set lim=I2R(steps)
        if blanco != null then
            set lim=Bala_Mejor * I2R(steps) + 1.
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
            set s__GroundCollision_x=ax + dx * Bala_Mejor
            set s__GroundCollision_y=ay + dy * Bala_Mejor
            set s__GroundCollision_reason=2
        endif
        set Bala_Blanco=null
        set Bala_Src=null
        set Bala_Skip=null
        set blanco=null
        set u=null
        return s__GroundCollision_reason
    endfunction

'''
i = s.index('    // v16q: el tramo prev -> actual de la bala m.')
j = s.index('    endfunction\r\n', s.index('    function Bala_Barrer takes integer m returns integer\r\n')) + len('    endfunction\r\n')
s = s[:i] + BARRER.replace('\n', N) + s[j:]

s = once(s, '                exitwhen 0 == this or n == 8\n', '                exitwhen 0 == this or n == 4\n')
s = once(s, '        // v16q/v16r: tandas de 8 balas,', '        // v16q/v16s: tandas de 4 balas,')
s = once(s, '''            set Bala_Cursor=(s__Missile_Missile__MissileStructure____first[(Missile__missileList[si__RapidBolt])])
''', '''            set Bala_Tic=Bala_Tic + 1
            if Bala_Tic >= 8 then
                set Bala_Tic=0
                call Bala_Rehacer()
            endif
            set Bala_Cursor=(s__Missile_Missile__MissileStructure____first[(Missile__missileList[si__RapidBolt])])
''')
s = once(s, '                exitwhen 0 == Bala_Cursor or i == 600\n', '                exitwhen 0 == Bala_Cursor or i == 1200\n')
assert s.count('function Bala_Barrer takes') == 1
Path(sal).write_text(s, encoding='latin-1', newline='')
print('v16s')
