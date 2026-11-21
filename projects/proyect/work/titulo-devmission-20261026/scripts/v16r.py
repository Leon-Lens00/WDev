#!/usr/bin/env python3
"""v16r (08/11/2026): el cuelgue con 8 escopetas (SPAS-12) y casillas de bala baratas.

Informe: Proyect/informes/errores/2026-11-08-152941-estres-misiles-limite-operaciones.md.

1. Disparo en su propio hilo. RapidPair_tick recorría a todos los tiradores en un hilo y adelantaba nextShot DESPUÉS
   de disparar. Con 8 tiradores x 8 perdigones el hilo superaba el límite de operaciones: se cortaba antes de adelantar
   nextShot, el mismo tirador volvía a disparar en cada tick (32 por segundo) y los siguientes no se procesaban.
   Ahora cada disparo (tick y primer disparo de cast) va en un TriggerEvaluate propio (Par_Emitir) y nextShot queda
   adelantado 0,25 s antes de disparar; al terminar se pone el intervalo real, como antes.
2. Casillas de bala baratas. Bala_Libre (v16q) calculaba cada casilla nueva con GroundCollision_clear: 9 pruebas con
   objeto (SetItemPosition) y la prueba de árboles con órdenes de cosecha, y vaciaba la tabla en cada ronda. Ahora:
   - Bala_Celda: una sola prueba de suelo por casilla de 16 (GroundCollision_point en su centro), guardada para
     siempre; el círculo de 8 puntos de clear se responde con las casillas donde caen esos puntos (error <= 11).
   - Bala_Arbol: el tipo de cada destructible (bloquea o no) se guarda por handle; la orden de cosecha sólo se da la
     primera vez. La vida se mira siempre.
   - La tabla por clase de radio ya no se vacía al empezar la ronda (nada cambia el terreno en partida).
3. Boca del arma: shootFamily usaba GroundCollision_trace (4 clear) por perdigón; ahora Bala_Boca, dos casillas.
4. Tandas de 8 balas (antes 16) y rescate: si una bala no terminó su pasada anterior (su tanda se cortó), se termina
   en lugar de volver a procesarla en cada tick.
El héroe, el dash y el bot siguen con GroundCollision_trace sin cambios.
Uso: v16r.py ENTRADA.j SALIDA.j   (ENTRADA = v16q/war3map.j)
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

N = '\r\n'
ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')

s = once(s, 'trigger Bala_Tanda= null\n', '''trigger Bala_Tanda= null
hashtable Bala_Suelo= InitHashtable()
boolean array Bala_Dentro
trigger Par_Disparo= null
integer Par_Actual= 0
real Par_Base= 0.
boolean Par_Ajustar= false
''')

# 2. Casillas: suelo por casilla y árboles por handle.
s = once(s, '''    function Bala_Clase takes real r returns integer
''', '''    // v16r: suelo de la casilla de 16 donde cae (px, py), probado una vez en su centro: 1 libre, 2 bloqueado.
    function Bala_Celda takes real px,real py returns boolean
        local integer ix= R2I(( px - s__WorldBounds_minX ) / 16.)
        local integer iy= R2I(( py - s__WorldBounds_minY ) / 16.)
        local integer v= LoadInteger(Bala_Suelo, ix, iy)
        if v == 0 then
            set v=2
            if s__GroundCollision_point(s__WorldBounds_minX + ix * 16 + 8. , s__WorldBounds_minY + iy * 16 + 8.) then
                set v=1
            endif
            call SaveInteger(Bala_Suelo, ix, iy, v)
        endif
        return v == 1
    endfunction

    // v16r: como GroundCollision_destructable, con el tipo (bloquea o no) guardado por handle en la fila -1.
    function Bala_Arbol takes nothing returns nothing
        local destructable d= GetEnumDestructable()
        local real dx= GetDestructableX(d) - s__GroundCollision_testX
        local real dy= GetDestructableY(d) - s__GroundCollision_testY
        local integer h
        local integer k
        if not s__GroundCollision_destBlocked and GetWidgetLife(d) > 0.405 and dx * dx + dy * dy <= ( s__GroundCollision_testRadius + 32. ) * ( s__GroundCollision_testRadius + 32. ) then
            set h=GetHandleId(d)
            set k=LoadInteger(Bala_Suelo, - 1, h)
            if k == 0 then
                set k=2
                if GetDestructableOccluderHeight(d) >= 32. or IsTreeAlive(d) then
                    set k=1
                endif
                call SaveInteger(Bala_Suelo, - 1, h, k)
            endif
            if k == 1 then
                set s__GroundCollision_destBlocked=true
            endif
        endif
        set d=null
    endfunction

    // v16r: GroundCollision_clear con Bala_Celda y Bala_Arbol.
    function Bala_Calcular takes real px,real py,real r returns boolean
        local integer i= 0
        local real a
        if px - r <= s__WorldBounds_minX or px + r >= s__WorldBounds_maxX or py - r <= s__WorldBounds_minY or py + r >= s__WorldBounds_maxY then
            return false
        endif
        if not Bala_Celda(px , py) then
            return false
        endif
        loop
            exitwhen i == 8
            set a=I2R(i) * bj_PI / 4.
            if not Bala_Celda(px + ( r + 2. ) * Cos(a) , py + ( r + 2. ) * Sin(a)) then
                return false
            endif
            set i=i + 1
        endloop
        set s__GroundCollision_testX=px
        set s__GroundCollision_testY=py
        set s__GroundCollision_testRadius=r
        set s__GroundCollision_destBlocked=false
        call SetRect(s__GroundCollision_area, px - r - 64., py - r - 64., px + r + 64., py + r + 64.)
        call EnumDestructablesInRect(s__GroundCollision_area, null, function Bala_Arbol)
        call SetRect(s__GroundCollision_area, 0., 0., 256., 256.)
        return not s__GroundCollision_destBlocked
    endfunction

    function Bala_Clase takes real r returns integer
''')
s = once(s, '            return s__GroundCollision_clear(px , py , r)\n', '            return Bala_Calcular(px , py , r)\n')
s = once(s, '        set libre=s__GroundCollision_clear(s__WorldBounds_minX + ix * 16 + 8. , s__WorldBounds_minY + iy * 16 + 8. , r)\n',
         '        set libre=Bala_Calcular(s__WorldBounds_minX + ix * 16 + 8. , s__WorldBounds_minY + iy * 16 + 8. , r)\n')
s = once(s, '    set Bala_Epoca = Bala_Epoca + 1\n    call DevWave_Start(Ronda_Numero)\n', '    call DevWave_Start(Ronda_Numero)\n')

# 3. Boca del arma.
s = once(s, '''    function s__RapidBolt_sweep takes integer m returns integer
''', '''    // v16r: la boca del arma (de a hacia b, 24) en dos casillas; deja x, y en el último punto libre.
    function Bala_Boca takes real ax,real ay,real bx,real by,real r returns nothing
        local integer pot= Bala_Clase(r)
        set s__GroundCollision_x=ax
        set s__GroundCollision_y=ay
        set s__GroundCollision_hit=null
        set s__GroundCollision_reason=1
        if not Bala_Libre(( ax + bx ) * 0.5 , ( ay + by ) * 0.5 , r , pot) then
            return
        endif
        set s__GroundCollision_x=( ax + bx ) * 0.5
        set s__GroundCollision_y=( ay + by ) * 0.5
        if not Bala_Libre(bx , by , r , pot) then
            return
        endif
        set s__GroundCollision_x=bx
        set s__GroundCollision_y=by
        set s__GroundCollision_reason=0
    endfunction

    function s__RapidBolt_sweep takes integer m returns integer
''')
s = once(s, '        call s__GroundCollision_trace(x , y , x + dx * 24. / distance , y + dy * 24. / distance , r , caster , GetOwningPlayer(caster) , false)\n',
         '        call Bala_Boca(x , y , x + dx * 24. / distance , y + dy * 24. / distance , r)\n')
# Una bala nueva no hereda la marca de rescate de otra que usó el mismo índice.
s = once(s, '        set s__RapidBolt_source[m]=caster\n', '        set Bala_Dentro[m]=false\n        set s__RapidBolt_source[m]=caster\n')

# 4. Tandas de 8 y rescate.
s = once(s, '''                exitwhen 0 == this or n == 16
                set Bala_Cursor=(s__Missile_Missile__MissileStructure____next[(this)])
                if s__Missile_wantDestroy[this] then
''', '''                exitwhen 0 == this or n == 8
                set Bala_Cursor=(s__Missile_Missile__MissileStructure____next[(this)])
                if Bala_Dentro[this] then
                    // Su pasada anterior se cortó por el límite de operaciones: se termina en vez de repetirla.
                    set Bala_Dentro[this]=false
                    call s__RapidBolt_missileTerminateP(this)
                elseif s__Missile_wantDestroy[this] then
''')
s = once(s, '''                else
                    if s__Missile_stackSize[this] > 0 then
                        call s__Missile_updateStack(this)
                    endif
''', '''                else
                    set Bala_Dentro[this]=true
                    if s__Missile_stackSize[this] > 0 then
                        call s__Missile_updateStack(this)
                    endif
''')
s = once(s, '''                    if s__Missile_allocated[this] and (s__RapidBolt_resolve((this))) then
                        call s__RapidBolt_missileTerminateP(this)
                    endif
                endif
                set n=n + 1
''', '''                    if s__Missile_allocated[this] and (s__RapidBolt_resolve((this))) then
                        call s__RapidBolt_missileTerminateP(this)
                    endif
                    set Bala_Dentro[this]=false
                endif
                set n=n + 1
''')
s = once(s, '        // v16q: tandas de 16 balas,', '        // v16q/v16r: tandas de 8 balas,')

# 1. Disparo en su propio hilo.
s = once(s, '''    function s__RapidPair_cast takes integer this,real px,real py returns nothing
''', '''    // v16r: cada disparo en su propio hilo (TriggerEvaluate) con su límite de operaciones. ajustar: desde el tick;
    // nextShot queda adelantado 0,25 s y, si el disparo termina, pasa a base + intervalo como antes.
    function Par_DispararP takes nothing returns boolean
        local integer this= Par_Actual
        local boolean ajustar= Par_Ajustar
        local real base= Par_Base
        call s__RapidPair_emit(this)
        if ajustar then
            set s__RapidPair_nextShot[this]=base + Arm_Intervalo(this)
        endif
        return false
    endfunction

    function Par_Emitir takes integer this,boolean ajustar returns nothing
        if Par_Disparo == null then
            set Par_Disparo=CreateTrigger()
            call TriggerAddCondition(Par_Disparo, Condition(function Par_DispararP))
        endif
        set Par_Actual=this
        set Par_Ajustar=ajustar
        set Par_Base=s__RapidPair_nextShot[this]
        if ajustar then
            set s__RapidPair_nextShot[this]=Par_Base + 0.25
        endif
        call TriggerEvaluate(Par_Disparo)
    endfunction

    function s__RapidPair_cast takes integer this,real px,real py returns nothing
''')
s = once(s, '''            set s__RapidPair_nextShot[this]=time + Arm_Int[Arm_W(p)]
            call s__RapidPair_emit(this)
''', '''            set s__RapidPair_nextShot[this]=time + Arm_Int[Arm_W(p)]
            call Par_Emitir(this , false)
''')
s = once(s, '''                            call s__RapidPair_emit(this)
                            set s__RapidPair_nextShot[this]=s__RapidPair_nextShot[this] + Arm_Intervalo(this)
''', '''                            call Par_Emitir(this , true)
''')
assert s.count('call s__RapidPair_emit(') == 1
assert 'Bala_Epoca + 1' not in s
Path(sal).write_text(s, encoding='latin-1', newline='')
print('v16r')
