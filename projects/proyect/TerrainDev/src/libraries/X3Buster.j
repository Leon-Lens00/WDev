// Local Warcraft adaptation of the user-supplied X3 interaction, not SNES code.
library X3Buster requires Missile, GroundCollision, TimerUtils, X3Kinematics
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
    static method playFor takes real x, real y, real z, real duration returns nothing
        local thistype this = allocate()
        local timer t = NewTimerEx(this)
        set dummy = GetRecycledMissile(x,y,z,0.)
        set art = AddSpecialEffectTarget("X3Buster\\X3_Flash_Union.mdx",dummy,"origin")
        set live = live+1
        call TimerStart(t,duration,false,function thistype.finish)
        set t = null
    endmethod
    static method play takes real x, real y, real z returns nothing
        call playFor(x,y,z,0.18)
    endmethod
endstruct

struct X3Buster
    // GIF approximation, units/second. These are NOT extracted SNES constants.
    static constant real STEP = 1./32.
    static constant real ORBIT_SPEED = 260.
    static constant real PULSE_INITIAL = 650.
    static constant real PULSE_ACCEL = 1800.
    static constant real PULSE_SPEED = 1500.
    static constant real FUSED_INITIAL = 70.
    static constant real FUSED_ACCEL = 900.
    static constant real FUSED_SPEED = 1200.
    static constant real FORMATION_TIME = 0.09375
    static constant real GREEN_INITIAL = -626.
    static constant real GREEN_ACCEL = 4363.
    static constant real GREEN_SPEED = 1140.
    static constant real ORANGE_INITIAL = -400.
    static constant real ORANGE_ACCEL = 2666.666667
    static constant real ORANGE_SPEED = 1080.
    static constant real PULSE_DELAY = 0.375
    static constant real ORBIT_RADIUS = 32.
    static constant real ORBIT_HZ = 2.5
    static constant real RANGE = 1400.
    static constant real LIFETIME = 4.
    static constant integer LIMIT = 64
    static constant integer GIF = 0
    static constant integer ORIGINAL = 1
    static constant integer ZERO_PROJECT = 2
    readonly integer profile
    readonly boolean forming
    private timer formationTimer
    private real unionX
    private real unionY
    private real unionRemaining
    readonly unit caster
    readonly player owner
    readonly real originX
    readonly real originY
    readonly real angle
    readonly real born
    readonly integer state // 0 charged; 1 orbit/pulse; 2 fused; 3 cancelled; 4 forming
    readonly Missile green
    readonly Missile blue
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
    // Analytic integral: negative starting velocity, acceleration, then a cap.
    // Sampling its differences gives the same path without Euler drift.
    static method ramp takes real initial, real accel, real maximum, real age returns real
        local real cap = (maximum-initial)/accel
        if age <= 0. then
            return 0.
        elseif age <= cap then
            return initial*age+0.5*accel*age*age
        endif
        return initial*cap+0.5*accel*cap*cap+maximum*(age-cap)
    endmethod
    static method travel takes integer form, real age returns real
        if form == 1 or form == 2 then
            return ORBIT_SPEED*age
        elseif form == 0 or form == 3 then
            return ramp(PULSE_INITIAL,PULSE_ACCEL,PULSE_SPEED,age)
        endif
        set age = RMaxBJ(0.,age-FORMATION_TIME)
        if form == 4 then
            return ramp(FUSED_INITIAL,FUSED_ACCEL,FUSED_SPEED,age)
        elseif form == 5 or form == 8 then
            return ramp(GREEN_INITIAL,GREEN_ACCEL,GREEN_SPEED,age)
        endif
        return ramp(ORANGE_INITIAL,ORANGE_ACCEL,ORANGE_SPEED,age)
    endmethod
    static method lateral takes integer form, real age returns real
        local real offset
        set age = RMaxBJ(0.,age-FORMATION_TIME)
        if form == 5 or form == 8 then
            set offset = 20.+200.*age
        else
            set offset = 12.+100.*age
        endif
        if form == 5 or form == 6 then
            return -offset
        endif
        return offset
    endmethod
    method trajectory takes integer form, real t returns real
        if profile != GIF then
            return X3Kinematics.forward(profile,form,t)
        endif
        return travel(form,t)
    endmethod
    static method ageOf takes Missile m returns real
        return X3Body.ageOf(m)
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
        elseif blue == m then
            set blue = 0
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
        if forming then
            set forming = false
            call ReleaseTimer(formationTimer)
            set formationTimer = null
        endif
        set state = 3
        if available(green) then
            call green.destroy()
        endif
        if available(orange) then
            call orange.destroy()
        endif
        if available(blue) then
            call blue.destroy()
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
    private method emitFusion takes nothing returns nothing
        local real shift = 0.
        set state = 2
        if profile == GIF then
            set shift = 24.
        endif
        set fused = X3Body.spawn(this,4,unionX,unionY,angle,unionRemaining)
        set sat1 = X3Body.spawn(this,5,unionX-shift*Cos(angle),unionY-shift*Sin(angle),angle,600.)
        set sat2 = X3Body.spawn(this,6,unionX-shift*Cos(angle),unionY-shift*Sin(angle),angle,600.)
        set sat3 = X3Body.spawn(this,7,unionX-shift*Cos(angle),unionY-shift*Sin(angle),angle,600.)
        set sat4 = X3Body.spawn(this,8,unionX-shift*Cos(angle),unionY-shift*Sin(angle),angle,600.)
        set satellites = satellites+4
    endmethod
    private static method finishFormation takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local thistype this = GetTimerData(t)
        set formationTimer = null
        set forming = false
        call ReleaseTimer(t)
        if state == 4 and GroundCollision.alive(caster) then
            call emitFusion()
        else
            call cancel()
        endif
        set t = null
    endmethod
    private method merge takes real x, real y returns nothing
        set unionRemaining = RMaxBJ(1.,RANGE-SquareRoot((x-originX)*(x-originX)+(y-originY)*(y-originY)))
        set unionX = x
        set unionY = y
        set state = 2
        set waiting = false
        call green.destroy()
        call orange.destroy()
        if available(blue) then
            call blue.destroy()
        endif
        call pulse.destroy()
        set fusions = fusions+1
        set lastFusionX = x
        set lastFusionY = y
        set lastFusionAge = now()-born
        if profile == GIF then
            call X3Flash.play(x,y,70.)
            call emitFusion()
        else
            // Snap to the second pulse; the five bodies do not exist during
            // formation. This timer is cancelled before this cast can be freed.
            set state = 4
            set forming = true
            set formationTimer = NewTimerEx(this)
            call X3Flash.playFor(x,y,70.,X3Kinematics.formation(profile))
            call TimerStart(formationTimer,X3Kinematics.formation(profile),false,function thistype.finishFormation)
        endif
    endmethod
    method tryFusion takes Missile m returns boolean
        local real oldGap
        local real gap
        local real fraction
        local real low = 0.
        local real high = 1.
        local integer i = 0
        local real reach = 0.
        if state != 1 or not available(green) or not available(orange) or not available(pulse) then
            return false
        endif
        if profile != GIF and not available(blue) then
            return false
        endif
        set oldGap = (green.prevX-m.prevX)*Cos(angle)+(green.prevY-m.prevY)*Sin(angle)
        set gap = (green.x-m.x)*Cos(angle)+(green.y-m.y)*Sin(angle)
        if profile == GIF and (oldGap <= 0. or gap > 0.) then
            return false
        endif
        // Both bodies moved before callbacks. Use their analytic within-step
        // trajectories: linear interpolation would shift an accelerating catch.
        call X3Body.prepare(green)
        call X3Body.prepare(orange)
        call X3Body.prepare(m)
        if profile != GIF then
            // A Warcraft fusion envelope calibrated from the observed native
            // encounter. It does not replace GroundCollision's world filters.
            set reach = 30.*X3Kinematics.SCALE
            set low = RMaxBJ(0.,(4./X3Kinematics.FPS-X3Body.ageOf(m)+STEP)/STEP)
            if low > 1. then
                return false
            endif
            if available(blue) then
                call X3Body.prepare(blue)
            endif
            set gap = (X3Body.centerX(green,1.)-X3Body.centerX(m,1.))*Cos(angle)+(X3Body.centerY(green,1.)-X3Body.centerY(m,1.))*Sin(angle)
            if gap > reach then
                return false
            endif
        endif
        loop
            exitwhen i == 16
            set fraction = (low+high)*0.5
            set gap = (X3Body.centerX(green,fraction)-X3Body.centerX(m,fraction))*Cos(angle)+(X3Body.centerY(green,fraction)-X3Body.centerY(m,fraction))*Sin(angle)
            if gap > reach then
                set low = fraction
            else
                set high = fraction
            endif
            set i = i+1
        endloop
        set fraction = high
        // Resolve only the part BEFORE the union. A later hit in this tick
        // belongs to the resulting shot and cannot cancel an earlier union.
        if X3Body.resolveAt(green,fraction) then
            call green.destroy()
        endif
        if X3Body.resolveAt(orange,fraction) then
            call orange.destroy()
        endif
        if profile != GIF and available(blue) and X3Body.resolveAt(blue,fraction) then
            call blue.destroy()
        endif
        if X3Body.resolveAt(m,fraction) then
            call m.destroy()
        endif
        if state != 1 or not available(green) or not available(orange) or not available(pulse) then
            return false
        endif
        if profile != GIF and not available(blue) then
            return false
        endif
        call merge(X3Body.centerX(m,fraction),X3Body.centerY(m,fraction))
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
            if waiting and automatic then
                if (profile == GIF and now()-born+0.0001 >= PULSE_DELAY) or (profile != GIF and now()-born+0.0001 >= X3Kinematics.pulseDelay(profile)) then
                    call releasePulse()
                endif
            endif
            if bodies == 0 and not waiting and not forming then
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
    static method fireProfile takes unit source, real tx, real ty, integer mode, integer selectedProfile returns thistype
        local thistype this
        local real x = GetUnitX(source)
        local real y = GetUnitY(source)
        local real dx = tx-x
        local real dy = ty-y
        if not GroundCollision.alive(source) or live >= LIMIT or mode < 0 or mode > 2 or selectedProfile < GIF or selectedProfile > ZERO_PROJECT then
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
        set profile = selectedProfile
        set forming = false
        set formationTimer = null
        set state = 0
        set bodies = 0
        set green = 0
        set orange = 0
        set blue = 0
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
            if profile != GIF then
                set blue = X3Body.spawn(this,9,originX,originY,angle,RANGE)
            endif
        endif
        return this
    endmethod
    static method fire takes unit source, real tx, real ty, integer mode returns thistype
        return fireProfile(source,tx,ty,mode,GIF)
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
    private static real array age
    private static boolean array prepared
    private static real array startX
    private static real array startY
    private static real array length

    // Called once per shared physical tick, including partial fusion sweeps.
    static method prepare takes Missile m returns nothing
        // A long-duration timer reading is not a unique physical tick ID.
        // The body's own callback consumes this flag after all partial sweeps.
        if not prepared[m] then
            set prepared[m] = true
            set age[m] = age[m]+X3Buster.STEP
        endif
    endmethod
    static method ageOf takes Missile m returns real
        return age[m]
    endmethod
    static method centerX takes Missile m, real fraction returns real
        local X3Buster s = m.data
        return startX[m]+RMinBJ(length[m],s.trajectory(kind[m],age[m]-X3Buster.STEP+X3Buster.STEP*fraction))*Cos(s.angle)
    endmethod
    static method centerY takes Missile m, real fraction returns real
        local X3Buster s = m.data
        return startY[m]+RMinBJ(length[m],s.trajectory(kind[m],age[m]-X3Buster.STEP+X3Buster.STEP*fraction))*Sin(s.angle)
    endmethod

    private static method sample takes Missile m, real sampleAge returns boolean
        local X3Buster s = m.data
        local real distance = RMinBJ(length[m],s.trajectory(kind[m],sampleAge))
        local real x = startX[m]+distance*Cos(s.angle)
        local real y = startY[m]+distance*Sin(s.angle)
        local real fraction = (sampleAge-age[m]+X3Buster.STEP)/X3Buster.STEP
        local real z = m.prevZ+(m.z-m.prevZ)*fraction
        local real phase
        local real side
        local real radius = 29.
        local real damage = 75.
        local integer result
        local unit target
        if s.profile != X3Buster.GIF and (kind[m] == 1 or kind[m] == 2 or kind[m] == 9) then
            set distance = RMinBJ(length[m],X3Kinematics.orbitForward(kind[m],sampleAge))
            set side = X3Kinematics.side(s.profile,kind[m],sampleAge)
            set x = startX[m]+distance*Cos(s.angle)-Sin(s.angle)*side
            set y = startY[m]+distance*Sin(s.angle)+Cos(s.angle)*side
            set radius = 12.65
            set damage = 35.
        elseif kind[m] == 1 or kind[m] == 2 then
            set phase = 2.*bj_PI*X3Buster.ORBIT_HZ*sampleAge
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
            if s.profile == X3Buster.GIF then
                set side = X3Buster.lateral(kind[m],sampleAge)
            else
                set side = X3Kinematics.side(s.profile,kind[m],sampleAge)
            endif
            set x = x-Sin(s.angle)*side
            set y = y+Cos(s.angle)*side
            set radius = 12.65
            set damage = 25.
        endif
        set result = GroundCollision.trace(lastX[m],lastY[m],x,y,radius,s.caster,s.owner,true)
        set target = GroundCollision.hit
        // Render the swept position, including backwards/lateral motion. The
        // central Missile coordinate remains the signed longitudinal carrier.
        call SetUnitX(m.dummy,GroundCollision.x)
        call SetUnitY(m.dummy,GroundCollision.y)
        call SetUnitFlyHeight(m.dummy,RMaxBJ(0.,z),0.)
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
    static method resolveAt takes Missile m, real fraction returns boolean
        local real untilAge
        local real nextAge
        local X3Buster s = m.data
        call prepare(m)
        set untilAge = age[m]-X3Buster.STEP+X3Buster.STEP*fraction
        if m.wantDestroy or blocked[m] then
            return true
        endif
        // Four curved-path substeps at most per full tick. They also detect a
        // backwards/forwards turn whose two endpoints might otherwise coincide.
        loop
            exitwhen processed[m]+0.0000001 >= untilAge
            set nextAge = RMinBJ(untilAge,processed[m]+X3Buster.STEP*0.25)
            if s.profile != X3Buster.GIF then
                set nextAge = RMinBJ(nextAge,I2R(R2I(processed[m]*X3Kinematics.FPS+0.00001)+1)/X3Kinematics.FPS)
            endif
            if sample(m,nextAge) then
                return true
            endif
            set processed[m] = nextAge
        endloop
        return false
    endmethod
    static method resolve takes Missile m returns boolean
        return resolveAt(m,1.)
    endmethod
    static method onPeriod takes Missile m returns boolean
        local X3Buster s = m.data
        call prepare(m)
        if kind[m] == 3 and s.tryFusion(m) then
            return true
        endif
        if resolve(m) then
            return true
        endif
        // Missile.speed is displacement per tick, not units/second.
        // Let Missile detect arrival using its own origin.distance. An external
        // rounded range can leave a zero-speed carrier just short of that end.
        // sample() clamps the rendered/swept position, including the last tick.
        set m.speed = s.trajectory(kind[m],age[m]+X3Buster.STEP)-s.trajectory(kind[m],age[m])
        set prepared[m] = false
        return false
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

    static method spawn takes X3Buster s, integer form, real x, real y, real facing, real range returns Missile
        local Missile m = Missile.createXYZ(x,y,70.,x+range*Cos(facing),y+range*Sin(facing),70.)
        set m.data = s
        set m.owner = s.owner
        set m.collision = 0.
        set kind[m] = form
        set processed[m] = 0.
        set age[m] = 0.
        set prepared[m] = false
        set startX[m] = x
        set startY[m] = y
        set length[m] = m.origin.distance
        set blocked[m] = false
        set lastX[m] = x
        set lastY[m] = y
        if form == 1 or form == 2 or form >= 5 then
            if form == 1 or form == 5 or form == 8 or form == 9 then
                set m.model = "X3Buster\\X3_Orbe_Verde.mdx"
            else
                set m.model = "X3Buster\\X3_Orbe_Naranja.mdx"
            endif
            set m.scale = 0.55
        elseif form == 4 then
            set m.model = "X3Buster\\X3_Cross_Buster.mdx"
            set m.scale = 1.
        else
            set m.model = "X3Buster\\X3_Buster_Cargado.mdx"
            set m.scale = 1.
        endif
        set m.speed = s.trajectory(form,X3Buster.STEP)
        // Start each visual at its real lateral position; do not pop out of
        // the carrier center on its first callback. Check terrain before moving.
        if s.profile != X3Buster.GIF then
            set processed[m] = 0.
            if form == 1 or form == 2 or form == 9 then
                set processed[m] = X3Kinematics.side(s.profile,form,0.)
                set lastX[m] = x+X3Kinematics.orbitForward(form,0.)*Cos(facing)-Sin(facing)*processed[m]
                set lastY[m] = y+X3Kinematics.orbitForward(form,0.)*Sin(facing)+Cos(facing)*processed[m]
            endif
            if GroundCollision.trace(x,y,lastX[m],lastY[m],12.65,s.caster,s.owner,false) != 0 then
                set blocked[m] = true
                call s.countHit(1)
                call m.destroy()
            endif
            call SetUnitX(m.dummy,GroundCollision.x)
            call SetUnitY(m.dummy,GroundCollision.y)
        elseif form == 1 or form == 2 then
            if form == 1 then
                set processed[m] = X3Buster.ORBIT_RADIUS
            else
                set processed[m] = -X3Buster.ORBIT_RADIUS
            endif
        elseif form >= 5 then
            set processed[m] = X3Buster.lateral(form,0.)
        endif
        if s.profile == X3Buster.GIF and (form == 1 or form == 2 or form >= 5) then
            set lastX[m] = x-Sin(facing)*processed[m]
            set lastY[m] = y+Cos(facing)*processed[m]
            if GroundCollision.trace(x,y,lastX[m],lastY[m],12.65,s.caster,s.owner,false) != 0 then
                set blocked[m] = true
                call s.countHit(1)
                call m.destroy()
            endif
            call SetUnitX(m.dummy,GroundCollision.x)
            call SetUnitY(m.dummy,GroundCollision.y)
        endif
        set processed[m] = 0.
        call s.track(m)
        call launch(m)
        return m
    endmethod
endstruct
endlibrary
