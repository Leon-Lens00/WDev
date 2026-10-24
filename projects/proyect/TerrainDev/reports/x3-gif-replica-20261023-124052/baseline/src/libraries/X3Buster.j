// Local Warcraft adaptation of the user-supplied X3 interaction, not SNES code.
library X3Buster requires Missile, GroundCollision, TimerUtils
private keyword X3Body

private struct X3Flash
    private unit dummy
    private effect art
    readonly static integer live = 0
    private static method finish takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local thistype this = GetTimerData(t)
        call DestroyEffect(art)
        call RecycleMissile(dummy)
        set art = null
        set dummy = null
        set live = live-1
        call ReleaseTimer(t)
        call deallocate()
        set t = null
    endmethod
    static method play takes real x, real y, real z returns nothing
        local thistype this = allocate()
        local timer t = NewTimerEx(this)
        set dummy = GetRecycledMissile(x,y,z,0.)
        set art = AddSpecialEffectTarget("X3Buster\\X3_Flash_Union.mdx",dummy,"origin")
        set live = live+1
        call TimerStart(t,0.18,false,function thistype.finish)
        set t = null
    endmethod
endstruct

struct X3Buster
    static constant real ORBIT_SPEED = 600.
    static constant real PULSE_SPEED = 1100.
    static constant real FUSED_SPEED = 1200.
    static constant real PULSE_DELAY = 0.25
    static constant real ORBIT_RADIUS = 32.
    static constant real ORBIT_HZ = 2.5
    static constant real RANGE = 1400.
    static constant real LIFETIME = 4.
    static constant integer LIMIT = 64
    readonly unit caster
    readonly player owner
    readonly real originX
    readonly real originY
    readonly real angle
    readonly real born
    readonly integer state // 0 charged; 1 orbit/pulse; 2 fused; 3 cancelled
    readonly Missile green
    readonly Missile orange
    readonly Missile pulse
    readonly Missile fused
    readonly Missile sat1
    readonly Missile sat2
    readonly Missile sat3
    readonly Missile sat4
    readonly integer bodies
    readonly boolean waiting
    private boolean automatic
    private integer next
    private integer previous
    private static integer first = 0
    private static timer clock = CreateTimer()
    private static timer ticker = CreateTimer()
    readonly static integer live = 0
    readonly static integer projectiles = 0
    readonly static integer created = 0
    readonly static integer retired = 0
    readonly static integer fusions = 0
    readonly static integer hits = 0
    readonly static integer walls = 0
    readonly static integer pulses = 0
    readonly static integer satellites = 0
    readonly static real lastFusionX = 0.
    readonly static real lastFusionY = 0.
    readonly static real lastFusionAge = 0.

    static method now takes nothing returns real
        return TimerGetElapsed(clock)
    endmethod
    static method flashCount takes nothing returns integer
        return X3Flash.live
    endmethod
    method available takes Missile m returns boolean
        return m != 0 and m.allocated and not m.wantDestroy and m.data == this
    endmethod
    method track takes Missile m returns nothing
        set bodies = bodies+1
        set projectiles = projectiles+1
        set created = created+1
    endmethod
    method untrack takes Missile m returns nothing
        if green == m then
            set green = 0
        elseif orange == m then
            set orange = 0
        elseif pulse == m then
            set pulse = 0
        elseif fused == m then
            set fused = 0
        elseif sat1 == m then
            set sat1 = 0
        elseif sat2 == m then
            set sat2 = 0
        elseif sat3 == m then
            set sat3 = 0
        elseif sat4 == m then
            set sat4 = 0
        endif
        set bodies = bodies-1
        set projectiles = projectiles-1
        set retired = retired+1
    endmethod
    // Marks only this cast's bodies. onRemove remains their sole cleanup owner.
    method cancel takes nothing returns nothing
        set waiting = false
        set state = 3
        if available(green) then
            call green.destroy()
        endif
        if available(orange) then
            call orange.destroy()
        endif
        if available(pulse) then
            call pulse.destroy()
        endif
        if available(fused) then
            call fused.destroy()
        endif
        if available(sat1) then
            call sat1.destroy()
        endif
        if available(sat2) then
            call sat2.destroy()
        endif
        if available(sat3) then
            call sat3.destroy()
        endif
        if available(sat4) then
            call sat4.destroy()
        endif
    endmethod
    // Can also be called by a future manual second-release/charge controller.
    method releasePulse takes nothing returns boolean
        if not waiting or state != 1 then
            return false
        endif
        set waiting = false
        if not GroundCollision.alive(caster) then
            return false
        endif
        set pulse = X3Body.spawn(this,3,originX,originY,angle,RANGE)
        set pulses = pulses+1
        return true
    endmethod
    private method merge takes real x, real y returns nothing
        local real remaining = RMaxBJ(1.,RANGE-SquareRoot((x-originX)*(x-originX)+(y-originY)*(y-originY)))
        set state = 2
        set waiting = false
        // All flags are set before child creation: no second union or impact.
        call green.destroy()
        call orange.destroy()
        call pulse.destroy()
        set fusions = fusions+1
        set lastFusionX = x
        set lastFusionY = y
        set lastFusionAge = now()-born
        call X3Flash.play(x,y,70.)
        set fused = X3Body.spawn(this,4,x,y,angle,remaining)
        set sat1 = X3Body.spawn(this,5,x-24.*Cos(angle),y-24.*Sin(angle),angle-0.70,600.)
        set sat2 = X3Body.spawn(this,6,x-24.*Cos(angle),y-24.*Sin(angle),angle-0.35,600.)
        set sat3 = X3Body.spawn(this,7,x-24.*Cos(angle),y-24.*Sin(angle),angle+0.35,600.)
        set sat4 = X3Body.spawn(this,8,x-24.*Cos(angle),y-24.*Sin(angle),angle+0.70,600.)
        set satellites = satellites+4
    endmethod
    method tryFusion takes Missile m returns boolean
        local real oldGap
        local real gap
        local real fraction
        if state != 1 or not available(green) or not available(orange) or not available(pulse) then
            return false
        endif
        set oldGap = (green.prevX-m.prevX)*Cos(angle)+(green.prevY-m.prevY)*Sin(angle)
        set gap = (green.x-m.x)*Cos(angle)+(green.y-m.y)*Sin(angle)
        if oldGap <= 0. or gap > 0. then
            return false
        endif
        set fraction = oldGap/(oldGap-gap)
        // Resolve only the part BEFORE the union. A later hit in this tick
        // belongs to the resulting shot and cannot cancel an earlier union.
        if X3Body.resolveAt(green,fraction) then
            call green.destroy()
        endif
        if X3Body.resolveAt(orange,fraction) then
            call orange.destroy()
        endif
        if X3Body.resolveAt(m,fraction) then
            call m.destroy()
        endif
        if state != 1 or not available(green) or not available(orange) or not available(pulse) then
            return false
        endif
        call merge(m.prevX+(m.x-m.prevX)*fraction,m.prevY+(m.y-m.prevY)*fraction)
        return true
    endmethod
    method countHit takes integer reason returns nothing
        if reason == 2 then
            set hits = hits+1
        elseif reason == 1 then
            set walls = walls+1
        endif
    endmethod
    private static method tick takes nothing returns nothing
        local thistype this = first
        local thistype following
        loop
            exitwhen this == 0
            set following = next
            if now()-born >= LIFETIME or GetUnitTypeId(caster) == 0 then
                call cancel()
            endif
            if waiting and automatic and now()-born+0.0001 >= PULSE_DELAY then
                call releasePulse()
            endif
            if bodies == 0 and not waiting then
                if previous == 0 then
                    set first = next
                else
                    set thistype(previous).next = next
                endif
                if next != 0 then
                    set thistype(next).previous = previous
                endif
                set caster = null
                set owner = null
                set live = live-1
                call deallocate()
            endif
            set this = following
        endloop
        if first == 0 then
            call PauseTimer(ticker)
        endif
    endmethod
    // mode0: charged pulse; mode1: automatic cross shot; mode2: manual release API.
    static method fire takes unit source, real tx, real ty, integer mode returns thistype
        local thistype this
        local real x = GetUnitX(source)
        local real y = GetUnitY(source)
        local real dx = tx-x
        local real dy = ty-y
        if not GroundCollision.alive(source) or live >= LIMIT or mode < 0 or mode > 2 then
            return 0
        endif
        set this = allocate()
        if dx*dx+dy*dy < 64. then
            set angle = GetUnitFacing(source)*bj_DEGTORAD
        else
            set angle = Atan2(dy,dx)
        endif
        // Reject a blocked muzzle before creating any body or crossing bounds.
        if GroundCollision.trace(x,y,x+24.*Cos(angle),y+24.*Sin(angle),29.,source,GetOwningPlayer(source),false) != 0 then
            call deallocate()
            return 0
        endif
        set originX = x+24.*Cos(angle)
        set originY = y+24.*Sin(angle)
        set caster = source
        set owner = GetOwningPlayer(source)
        set born = now()
        set state = 0
        set bodies = 0
        set green = 0
        set orange = 0
        set pulse = 0
        set fused = 0
        set sat1 = 0
        set sat2 = 0
        set sat3 = 0
        set sat4 = 0
        set waiting = mode != 0
        set automatic = mode == 1
        set previous = 0
        set next = first
        if first != 0 then
            set thistype(first).previous = this
        else
            call TimerStart(ticker,1./32.,true,function thistype.tick)
        endif
        set first = this
        set live = live+1
        if mode == 0 then
            set pulse = X3Body.spawn(this,0,originX,originY,angle,RANGE)
        else
            set state = 1
            set green = X3Body.spawn(this,1,originX,originY,angle,RANGE)
            set orange = X3Body.spawn(this,2,originX,originY,angle,RANGE)
        endif
        return this
    endmethod
    private static method onInit takes nothing returns nothing
        call TimerStart(clock,1000000.,false,null)
    endmethod
endstruct

private struct X3Body extends array
    private static integer array kind
    private static real array lastX
    private static real array lastY
    private static real array processed
    private static boolean array blocked

    static method resolveAt takes Missile m, real fraction returns boolean
        local X3Buster s = m.data
        local real x = m.prevX+(m.x-m.prevX)*fraction
        local real y = m.prevY+(m.y-m.prevY)*fraction
        local real z = m.prevZ+(m.z-m.prevZ)*fraction
        local real dx = m.x-m.prevX
        local real dy = m.y-m.prevY
        local real sample = m.distance-(1.-fraction)*SquareRoot(dx*dx+dy*dy)
        local real phase
        local real side
        local real radius = 29.
        local real damage = 75.
        local integer result
        local unit target
        if m.wantDestroy or blocked[m] then
            return true
        endif
        if processed[m] == sample then
            return false
        endif
        set processed[m] = sample
        if kind[m] == 1 or kind[m] == 2 then
            set phase = 2.*bj_PI*X3Buster.ORBIT_HZ*sample/X3Buster.ORBIT_SPEED
            if kind[m] == 2 then
                set phase = phase+bj_PI
            endif
            set side = X3Buster.ORBIT_RADIUS*Cos(phase)
            set x = x-Sin(s.angle)*side
            set y = y+Cos(s.angle)*side
            set z = z+X3Buster.ORBIT_RADIUS*Sin(phase)
            set radius = 12.65
            set damage = 35.
        elseif kind[m] == 4 then
            set radius = 41.25
            set damage = 150.
        elseif kind[m] >= 5 then
            set radius = 12.65
            set damage = 25.
        endif
        set result = GroundCollision.trace(lastX[m],lastY[m],x,y,radius,s.caster,s.owner,true)
        set target = GroundCollision.hit
        if kind[m] == 1 or kind[m] == 2 then
            // Trace before translating: an orbital offset may cross the edge
            // even while the center is still within WorldBounds.
            call SetUnitX(m.dummy,GroundCollision.x)
            call SetUnitY(m.dummy,GroundCollision.y)
            call SetUnitFlyHeight(m.dummy,RMaxBJ(0.,z),0.)
        endif
        set lastX[m] = x
        set lastY[m] = y
        if result == 0 and z < 0. then
            set result = 1
        endif
        if result != 0 then
            set blocked[m] = true
            // Collision result/target are captured before damage can reenter.
            call s.countHit(result)
            if result == 2 and GetUnitTypeId(s.caster) != 0 then
                call UnitDamageTarget(s.caster,target,damage,false,false,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_MAGIC,null)
            endif
        endif
        set target = null
        return result != 0
    endmethod
    static method resolve takes Missile m returns boolean
        return resolveAt(m,1.)
    endmethod
    static method onPeriod takes Missile m returns boolean
        local X3Buster s = m.data
        if kind[m] == 3 and s.tryFusion(m) then
            return true
        endif
        return resolve(m)
    endmethod
    static method onFinish takes Missile m returns boolean
        call resolve(m)
        return true
    endmethod
    static method onRemove takes Missile m returns boolean
        local X3Buster s = m.data
        call s.untrack(m)
        set m.data = 0
        set blocked[m] = false
        return false
    endmethod
    implement MissileStruct

    static method spawn takes X3Buster s, integer form, real x, real y, real facing, real length returns Missile
        local Missile m = Missile.createXYZ(x,y,70.,x+length*Cos(facing),y+length*Sin(facing),70.)
        set m.data = s
        set m.owner = s.owner
        set m.collision = 0.
        set kind[m] = form
        set processed[m] = -1.
        set blocked[m] = false
        set lastX[m] = x
        set lastY[m] = y
        if form == 1 or form == 2 or form >= 5 then
            if form == 1 or form == 5 or form == 8 then
                set m.model = "X3Buster\\X3_Orbe_Verde.mdx"
            else
                set m.model = "X3Buster\\X3_Orbe_Naranja.mdx"
            endif
            set m.scale = 0.55
            if form < 3 then
                call m.setMovementSpeed(X3Buster.ORBIT_SPEED)
            else
                call m.setMovementSpeed(700.)
            endif
        elseif form == 4 then
            set m.model = "X3Buster\\X3_Cross_Buster.mdx"
            set m.scale = 1.
            call m.setMovementSpeed(X3Buster.FUSED_SPEED)
        else
            set m.model = "X3Buster\\X3_Buster_Cargado.mdx"
            set m.scale = 1.
            call m.setMovementSpeed(X3Buster.PULSE_SPEED)
        endif
        call s.track(m)
        call launch(m)
        return m
    endmethod
endstruct
endlibrary
