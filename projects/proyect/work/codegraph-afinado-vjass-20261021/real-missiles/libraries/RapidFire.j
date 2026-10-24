library RapidFire initializer Init requires GroundMotion, Missile, Table, TimerUtils, SpellEffectEvent, RegisterPlayerUnitEvent
struct RapidBolt extends array
    private static unit array source
    private static player array owner
    readonly static integer live = 0
    readonly static integer hits = 0
    readonly static integer walls = 0

    private static method resolve takes Missile m returns boolean
        local integer result = GroundCollision.trace(m.prevX,m.prevY,m.x,m.y,16.,source[m],owner[m],true)
        local unit target = GroundCollision.hit
        local unit caster = source[m]
        if result == 2 then
            set hits = hits+1
            if GetUnitTypeId(caster) != 0 then
                call UnitDamageTarget(caster,target,25.,false,false,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_MAGIC,null)
            endif
        elseif result == 1 or m.z < 0. then
            set walls = walls+1
            set result = 1
        endif
        set target = null
        set caster = null
        return result != 0
    endmethod
    static method onPeriod takes Missile m returns boolean
        return resolve(m)
    endmethod
    static method onFinish takes Missile m returns boolean
        call resolve(m)
        return true
    endmethod
    static method onRemove takes Missile m returns boolean
        set source[m] = null
        set owner[m] = null
        set live = live-1
        return false
    endmethod
    implement MissileStruct

    static method shoot takes unit caster, real px, real py returns Missile
        local real x = GetUnitX(caster)
        local real y = GetUnitY(caster)
        local real dx = px-x
        local real dy = py-y
        local real distance = SquareRoot(dx*dx+dy*dy)
        local real angle
        local real length
        local Missile m
        if distance < 8. then
            set angle = GetUnitFacing(caster)*bj_DEGTORAD
            set distance = 600.
            set dx = distance*Cos(angle)
            set dy = distance*Sin(angle)
        endif
        set length = RMinBJ(distance,1000.)
        set px = x+dx*length/distance
        set py = y+dy*length/distance
        call GroundCollision.trace(x,y,x+dx*24./distance,y+dy*24./distance,16.,caster,GetOwningPlayer(caster),false)
        set m = Missile.createXYZ(GroundCollision.x,GroundCollision.y,70.,px,py,70.)
        set source[m] = caster
        set owner[m] = GetOwningPlayer(caster)
        set m.owner = owner[m]
        // Ability-specific swept collision chooses obstacles before damage;
        // it does not change the common module's callback ordering.
        set m.collision = 0.
        set m.model = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
        call m.setMovementSpeed(1200.)
        set live = live+1
        call launch(m)
        return m
    endmethod
endstruct

struct RapidPair
    readonly unit controller
    readonly unit actor
    readonly GroundMotion motion
    readonly boolean firing = false
    readonly integer pending = 0
    readonly real aimX
    readonly real aimY
    readonly real nextShot = 0.
    readonly real lastShot = -1000.
    readonly Missile lastMissile = 0 // diagnostic reference; valid only while allocated
    readonly static integer pairs = 0
    readonly static integer bursts = 0
    readonly static integer remaining = 0
    readonly static integer emitted = 0
    readonly static integer recasts = 0
    readonly static integer attacks = 0
    readonly static real minInterval = 99999.
    readonly static integer moving = 0
    readonly static integer blocked = 0
    private timer reset
    private integer next
    private integer previous
    private static integer first = 0
    private static Table controls
    private static Table actors
    private static timer clock = CreateTimer()
    private static timer ticker = CreateTimer()
    static constant real INTERVAL = 0.25

    static method now takes nothing returns real
        return TimerGetElapsed(clock)
    endmethod
    static method fromController takes unit u returns thistype
        return controls[GetHandleId(u)]
    endmethod
    static method fromActor takes unit u returns thistype
        return actors[GetHandleId(u)]
    endmethod
    private method face takes nothing returns nothing
        local real dx = aimX-GetUnitX(actor)
        local real dy = aimY-GetUnitY(actor)
        if dx*dx+dy*dy > 0.01 then
            call SetUnitFacingTimed(actor,Atan2(dy,dx)*bj_RADTODEG,0.)
        endif
    endmethod
    private method emit takes nothing returns nothing
        local real gap = now()-lastShot
        if lastShot > -1. and gap < minInterval then
            set minInterval = gap
        endif
        set lastShot = now()
        set pending = pending-1
        set remaining = remaining-1
        set emitted = emitted+1
        call face()
        call SetUnitAnimation(actor,"attack")
        set attacks = attacks+1
        set lastMissile = RapidBolt.shoot(actor,aimX,aimY)
    endmethod
    method cast takes real px, real py returns nothing
        if not GroundCollision.alive(actor) then
            return
        endif
        set aimX = px
        set aimY = py
        if firing then
            set remaining = remaining+6-pending
            set pending = 6
            set recasts = recasts+1
            return
        endif
        set firing = true
        set bursts = bursts+1
        set pending = 6
        set remaining = remaining+6
        // Initial instant transition, if needed, precedes the first attack.
        call motion.enter()
        call SetUnitTimeScale(actor,3.)
        set nextShot = now()+INTERVAL
        call emit()
    endmethod
    private method finish takes boolean resume returns nothing
        if firing then
            set firing = false
            set bursts = bursts-1
            set remaining = remaining-pending
            set pending = 0
            if GetUnitTypeId(actor) != 0 then
                call SetUnitTimeScale(actor,1.)
                call ResetUnitAnimation(actor)
            endif
            call motion.leave(resume)
        endif
    endmethod
    private static method park takes nothing returns nothing
        local thistype this = GetTimerData(GetExpiredTimer())
        call SetUnitPosition(controller,WorldBounds.minX+256.,WorldBounds.minY+256.)
    endmethod
    method move takes real px, real py returns nothing
        call motion.destination(px,py)
    endmethod
    static method create takes unit proxy, unit visible returns thistype
        local thistype this = thistype.allocate()
        set controller = proxy
        set actor = visible
        set firing = false
        set pending = 0
        set lastShot = -1000.
        set lastMissile = 0
        set aimX = GetUnitX(visible)+500.
        set aimY = GetUnitY(visible)
        set reset = NewTimerEx(this)
        set motion = GroundMotion.create(visible)
        set controls[GetHandleId(proxy)] = this
        set actors[GetHandleId(visible)] = this
        set previous = 0
        set next = first
        if first != 0 then
            set thistype(first).previous = this
        endif
        set first = this
        set pairs = pairs+1
        return this
    endmethod
    method destroy takes nothing returns nothing
        call finish(false)
        call motion.destroy()
        call controls.remove(GetHandleId(controller))
        call actors.remove(GetHandleId(actor))
        call ReleaseTimer(reset)
        call RemoveUnit(controller)
        if previous == 0 then
            set first = next
        else
            set thistype(previous).next = next
        endif
        if next != 0 then
            set thistype(next).previous = previous
        endif
        set controller = null
        set actor = null
        set reset = null
        set pairs = pairs-1
        call deallocate()
    endmethod
    private static method tick takes nothing returns nothing
        local thistype this = first
        local thistype following
        local real time = now()
        set moving = 0
        set blocked = 0
        loop
            exitwhen this == 0
            set following = next
            if not GroundCollision.alive(actor) or not GroundCollision.alive(controller) then
                call destroy()
            else
                call SetWidgetLife(controller,GetWidgetLife(actor))
                if firing then
                    call motion.step(1./32.)
                    call face()
                    if time+0.0001 >= nextShot then
                        if pending > 0 then
                            call emit()
                            set nextShot = nextShot+INTERVAL
                        else
                            call finish(true)
                        endif
                    endif
                    if motion.hasGoal then
                        set moving = moving+1
                    endif
                    if motion.blocked then
                        set blocked = blocked+1
                    endif
                endif
            endif
            set this = following
        endloop
    endmethod
    private static method pointOrder takes nothing returns nothing
        local thistype this = fromController(GetTriggerUnit())
        local integer order = GetIssuedOrderId()
        if this != 0 then
            // A new cast must not be cancelled by a queued proxy move reset.
            call PauseTimer(reset)
            if order == 851986 or order == 851971 then
                call move(GetOrderPointX(),GetOrderPointY())
                call TimerStart(reset,0.,false,function thistype.park)
            endif
        endif
    endmethod
    private static method spell takes nothing returns nothing
        local thistype this = fromController(GetTriggerUnit())
        if this != 0 then
            call cast(GetSpellTargetX(),GetSpellTargetY())
        endif
    endmethod
    private static method selected takes nothing returns nothing
        local thistype this = fromActor(GetTriggerUnit())
        if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
            // Selection only; all gameplay state is outside the local branch.
            call ClearSelection()
            call SelectUnit(controller,true)
        endif
    endmethod
    static method initialize takes nothing returns nothing
        set controls = Table.create()
        set actors = Table.create()
        call TimerStart(clock,1000000.,false,null)
        call TimerStart(ticker,1./32.,true,function thistype.tick)
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER,function thistype.pointOrder)
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED,function thistype.selected)
        call RegisterSpellEffectEvent('Arpf',function thistype.spell)
    endmethod
endstruct
private function Init takes nothing returns nothing
    call RapidPair.initialize()
endfunction
endlibrary
