library RapidFire initializer Init requires GroundMotion, Missile, Table, TimerUtils, SpellEffectEvent, RegisterPlayerUnitEvent
struct RapidBolt extends array
    // Collision stays independent of the decorative trail and death flash.
    // Firebrand test (26/10/2026): solid head 22.7..29.7 units at scale 1
    // (reports/firebrand-medidas-20261026); radius 30 chosen by the user.
    static constant real HIT_RADIUS = 30.
    static constant real VISUAL_SCALE = 1.
    // Fixed flight distance of every bolt (user request), independent of the cast point.
    static constant real RANGE = 1350.
    // Families: separate missiles sharing the burst mechanics (Q/W/R).
    static constant integer FIREBRAND = 0
    static constant integer SHOTS = 1
    static constant integer SHOTS_II = 3
    // Vinz models shifted in X at base scale 1 (assets/shots-ajustados, made by
    // scripts/shots_ajustados.cjs): the Stand tip sits at +radius, so the hit circle
    // stays on the missile origin. Half-widths: Vol. I 5.8, Vol. II 18,
    // Vol. II Green 16.2.
    static constant real SHOTS_SCALE = 1.
    static constant real SHOTS_II_SCALE = 1.
    private static unit array source
    private static player array owner
    private static real array hitRadius
    readonly static integer live = 0
    readonly static integer hits = 0
    readonly static integer walls = 0

    static method radiusOf takes integer f returns real
        if f == SHOTS then
            return 6.
        elseif f == SHOTS_II then
            return 18.
        endif
        return HIT_RADIUS
    endmethod
    static method scaleOf takes integer f returns real
        if f == SHOTS then
            return SHOTS_SCALE
        elseif f == SHOTS_II then
            return SHOTS_II_SCALE
        endif
        return VISUAL_SCALE
    endmethod
    // Per-model collision: a circle of the body half-width on the missile origin.
    static method radiusFor takes playercolor value, integer f returns real
        if f == SHOTS_II and (value == PLAYER_COLOR_GREEN or value == PLAYER_COLOR_AQUA) then
            return 16.2*SHOTS_II_SCALE
        endif
        return radiusOf(f)*scaleOf(f)
    endmethod
    private static method sweep takes Missile m returns integer
        local integer result
        // Enemy bodies follow each model's selection circle (UnitHitShape).
        set GroundCollision.shaped = true
        set result = GroundCollision.trace(m.prevX,m.prevY,m.x,m.y,hitRadius[m],source[m],owner[m],true)
        set GroundCollision.shaped = false
        return result
    endmethod

    private static method resolve takes Missile m returns boolean
        local integer result
        local unit target
        local unit caster = source[m]
        set result = sweep(m)
        set target = GroundCollision.hit
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

    static method firebrandColor takes playercolor value returns string
        // Nine unmodified Firebrand originals; the three remaining colors reuse the nearest hue.
        if value == PLAYER_COLOR_RED then
            return "Red"
        elseif value == PLAYER_COLOR_BLUE or value == PLAYER_COLOR_LIGHT_BLUE then
            return "Blue"
        elseif value == PLAYER_COLOR_CYAN then
            return "Teal"
        elseif value == PLAYER_COLOR_PURPLE then
            return "Purple"
        elseif value == PLAYER_COLOR_YELLOW then
            return "Yellow"
        elseif value == PLAYER_COLOR_ORANGE or value == PLAYER_COLOR_BROWN then
            return "Orange"
        elseif value == PLAYER_COLOR_GREEN or value == PLAYER_COLOR_AQUA then
            return "Green"
        elseif value == PLAYER_COLOR_PINK then
            return "Pink"
        endif
        // Light gray also covers neutral/unknown colors outside the Classic 12.
        return "Silver"
    endmethod
    static method modelForColor takes playercolor value returns string
        return "FirebrandShots\\Firebrand Shot "+firebrandColor(value)+".mdx"
    endmethod

    static method originalColor takes playercolor value returns string
        // Six original colors; the other player colors reuse the nearest hue.
        if value == PLAYER_COLOR_RED then
            return "Red"
        elseif value == PLAYER_COLOR_BLUE or value == PLAYER_COLOR_LIGHT_BLUE or value == PLAYER_COLOR_CYAN then
            return "Blue"
        elseif value == PLAYER_COLOR_PURPLE or value == PLAYER_COLOR_PINK then
            return "Purple"
        elseif value == PLAYER_COLOR_ORANGE or value == PLAYER_COLOR_BROWN then
            return "Orange"
        elseif value == PLAYER_COLOR_GREEN or value == PLAYER_COLOR_AQUA then
            return "Green"
        endif
        // Yellow also covers light gray and neutral/unknown colors.
        return "Yellow"
    endmethod
    static method modelOf takes playercolor value, integer f returns string
        if f == SHOTS then
            return "ShotsAjustados\\Shot "+originalColor(value)+".mdx"
        elseif f == SHOTS_II then
            return "ShotsAjustados\\Shot II "+originalColor(value)+".mdx"
        endif
        return modelForColor(value)
    endmethod
    // Windwalk (Vinz) on the feet, in the hue of the bolt this family fires
    // (assets/windwalk-colores: nine colors, Shots uses six of them).
    static method walkModelOf takes playercolor value, integer f returns string
        if f == SHOTS or f == SHOTS_II then
            return "Windwalk\\Windwalk "+originalColor(value)+".mdx"
        endif
        return "Windwalk\\Windwalk "+firebrandColor(value)+".mdx"
    endmethod

    static method shootFamily takes unit caster, real px, real py, playercolor color, integer f returns Missile
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
        // The point only gives the direction: every bolt flies RANGE, near or far cast.
        set length = RANGE
        set px = x+dx*length/distance
        set py = y+dy*length/distance
        call GroundCollision.trace(x,y,x+dx*24./distance,y+dy*24./distance,radiusFor(color,f),caster,GetOwningPlayer(caster),false)
        // Fly just above the ground (Z = body radius, relative to terrain): at 70
        // the bolts looked like they passed over units the planar circle hits.
        set m = Missile.createXYZ(GroundCollision.x,GroundCollision.y,radiusFor(color,f),px,py,radiusFor(color,f))
        set source[m] = caster
        set owner[m] = GetOwningPlayer(caster)
        set m.owner = owner[m]
        // Ability-specific swept collision chooses obstacles before damage;
        // it does not change the common module's callback ordering.
        set m.collision = 0.
        set hitRadius[m] = radiusFor(color,f)
        set m.model = modelOf(color,f)
        set m.scale = scaleOf(f)
        call m.setMovementSpeed(1200.)
        set live = live+1
        call launch(m)
        return m
    endmethod
    static method shootColor takes unit caster, real px, real py, playercolor color returns Missile
        return shootFamily(caster,px,py,color,FIREBRAND)
    endmethod
    // Existing consumers keep the same API and take the owner's current color.
    static method shoot takes unit caster, real px, real py returns Missile
        return shootColor(caster,px,py,GetPlayerColor(GetOwningPlayer(caster)))
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
    readonly integer family = 0 // RapidBolt family of the current burst
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
    private playercolor tint
    private boolean hasTint
    private effect walk = null
    private string walkModel = null
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
    method color takes nothing returns playercolor
        if hasTint then
            return tint
        endif
        return GetPlayerColor(GetOwningPlayer(actor))
    endmethod
    // The feet effect lives exactly while the actor is in artificial motion and
    // follows the current color/family; DestroyEffect plays its Death fade.
    private method showWalk takes nothing returns nothing
        local string path = RapidBolt.walkModelOf(color(),family)
        if not motion.artificial or (walk != null and path == walkModel) then
            return
        endif
        if walk != null then
            call DestroyEffect(walk)
        endif
        set walk = AddSpecialEffectTarget(path,actor,"origin")
        set walkModel = path
    endmethod
    private method hideWalk takes nothing returns nothing
        if walk != null then
            call DestroyEffect(walk)
            set walk = null
            set walkModel = null
        endif
    endmethod
    // Classic has no GetUnitColor. Use this setter for individual/team overrides.
    // Red is enum0 (equal to null in Classic), so absence is a separate flag.
    method setColor takes playercolor value returns nothing
        set tint = value
        set hasTint = true
        call SetUnitColor(actor,color())
        call SetUnitColor(controller,color())
        call showWalk()
    endmethod
    method clearColor takes nothing returns nothing
        set hasTint = false
        set tint = null
        call SetUnitColor(actor,color())
        call SetUnitColor(controller,color())
        call showWalk()
    endmethod
    // The burst aims at the point RANGE away in the cast direction, not at the cast
    // point: while the actor moves, facing and every shot keep that far target, so a
    // near cast does not swing or flip the direction when the actor walks past it.
    private method aimAt takes real px, real py returns nothing
        local real x = GetUnitX(actor)
        local real y = GetUnitY(actor)
        local real dx = px-x
        local real dy = py-y
        local real distance = SquareRoot(dx*dx+dy*dy)
        if distance < 8. then
            set dx = Cos(GetUnitFacing(actor)*bj_DEGTORAD)
            set dy = Sin(GetUnitFacing(actor)*bj_DEGTORAD)
            set distance = 1.
        endif
        set aimX = x+dx*RapidBolt.RANGE/distance
        set aimY = y+dy*RapidBolt.RANGE/distance
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
        set lastMissile = RapidBolt.shootFamily(actor,aimX,aimY,color(),family)
    endmethod
    method cast takes real px, real py returns nothing
        if not GroundCollision.alive(actor) then
            return
        endif
        call aimAt(px,py)
        if firing then
            set remaining = remaining+6-pending
            set pending = 6
            set recasts = recasts+1
            call showWalk()
            return
        endif
        set firing = true
        set bursts = bursts+1
        set pending = 6
        set remaining = remaining+6
        // Initial instant transition, if needed, precedes the first attack.
        call motion.enter()
        call showWalk()
        call SetUnitTimeScale(actor,3.)
        set nextShot = now()+INTERVAL
        call emit()
    endmethod
    // A recast with another family refills the burst and switches its pending shots.
    method castFamily takes real px, real py, integer f returns nothing
        set family = f
        call cast(px,py)
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
            call hideWalk()
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
        set family = 0
        set tint = null
        set hasTint = false
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
        set tint = null
        set hasTint = false
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
        local integer id = GetSpellAbilityId()
        local integer f = RapidBolt.FIREBRAND
        if id == 'Arp1' then
            set f = RapidBolt.SHOTS
        elseif id == 'Arp3' then
            set f = RapidBolt.SHOTS_II
        endif
        if this != 0 then
            call castFamily(GetSpellTargetX(),GetSpellTargetY(),f)
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
        call RegisterSpellEffectEvent('Arp1',function thistype.spell)
        call RegisterSpellEffectEvent('Arp3',function thistype.spell)
    endmethod
endstruct
private function Init takes nothing returns nothing
    call RapidPair.initialize()
endfunction
endlibrary
