library RFBurstPair requires Missiles
    // Minimal burst/reset/aim candidate. Caller owns pair/observer.
    // Active casts update future heading; launched flights keep their own path.
    globals
        private constant real CADENCE = .25
        private constant real RANGE = 1500.
        private constant real SPEED = 1200.
        private constant real HIT_RADIUS = 32.
        private constant real LAUNCH_HEIGHT = 80.
        private unit actor = null
        private unit controller = null
        private player pairOwner = null
        private trigger castHook = null
        private trigger observer = null
        private timer fireTimer = null
        private location terrain = null
        private integer epoch = 0
        private integer remaining = 0
        private boolean notifying = false
        private real heading = 0.
        private Missiles shot = 0
        private unit shotSource = null
        private real shotX = 0.
        private real shotY = 0.
    endglobals

    private function LiveOwned takes unit u, player p returns boolean
        return u != null and GetUnitTypeId(u) != 0 and GetWidgetLife(u) > .405 and GetOwningPlayer(u) == p
    endfunction

    private struct RBProjectile extends Missiles
        // Per-flight snapshots, never references to the current global pair.
        private unit savedActor
        private unit savedController
        private player savedOwner
        private boolean spent

        static method spawn takes unit visible, unit logical, player owning, real x, real y, real endX, real endY, real endZ returns thistype
            local thistype this = thistype.create(x,y,LAUNCH_HEIGHT,endX,endY,endZ)
            set savedActor = visible
            set savedController = logical
            set savedOwner = owning
            set spent = false
            set source = visible
            set owner = owning
            set speed = SPEED
            set collision = HIT_RADIUS
            set collideZ = false
            set model = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
            return this
        endmethod

        method onHit takes unit hit returns boolean
            if spent or not LiveOwned(savedActor,savedOwner) then
                return true
            endif
            if hit == savedActor or hit == savedController or GetUnitTypeId(hit) == 0 or GetWidgetLife(hit) <= .405 or not IsUnitEnemy(hit,savedOwner) then
                return false
            endif
            // Commit termination intent BEFORE native damage dispatch. Damage
            // handlers may dispose/reinitialize the pair or terminate this flight.
            set spent = true
            call UnitDamageTarget(savedActor,hit,10.,true,true,ATTACK_TYPE_MELEE,DAMAGE_TYPE_NORMAL,null)
            // No instance/global writes after that external callback boundary.
            return true
        endmethod

        method onDestructable takes destructable dest returns boolean
            return GetDestructableLife(dest) > 0.
        endmethod

        method onPeriod takes nothing returns boolean
            return not LiveOwned(savedActor,savedOwner)
        endmethod

        method onRemove takes nothing returns nothing
            // Core owns allocator/dummy/effect/coordinates and their cleanup.
            set savedActor = null
            set savedController = null
            set savedOwner = null
            set spent = true
        endmethod
    endstruct

    // Same callback-scoped ABI as RED. Observe, do not retain recycled IDs.
    function RB_GetShotMissile takes nothing returns Missiles
        return shot
    endfunction

    function RB_GetShotSource takes nothing returns unit
        return shotSource
    endfunction

    function RB_GetShotX takes nothing returns real
        return shotX
    endfunction

    function RB_GetShotY takes nothing returns real
        return shotY
    endfunction

    private function ClearShot takes nothing returns nothing
        set shot = 0
        set shotSource = null
        set shotX = 0.
        set shotY = 0.
    endfunction

    private function CancelBurst takes nothing returns nothing
        set epoch = epoch+1
        set remaining = 0
        set notifying = false
        if fireTimer != null then
            call PauseTimer(fireTimer)
        endif
        call ClearShot()
    endfunction

    private function PairReady takes nothing returns boolean
        return LiveOwned(actor,pairOwner) and LiveOwned(controller,pairOwner)
    endfunction

    private function Emit takes nothing returns nothing
        local integer ticket = epoch
        local unit visible = actor
        local unit logical = controller
        local player owning = pairOwner
        local trigger listener = observer
        local RBProjectile m
        local real x
        local real y
        local real endX
        local real endY
        local real absoluteZ
        local real endZ
        if remaining <= 0 or notifying then
            set visible = null
            set logical = null
            set owning = null
            set listener = null
            return
        endif
        if not PairReady() then
            call CancelBurst()
            set visible = null
            set logical = null
            set owning = null
            set listener = null
            return
        endif
        // Commit all cadence/count state before core creation or observer code.
        set remaining = remaining-1
        set notifying = true
        if remaining == 0 then
            call PauseTimer(fireTimer)
        endif
        set x = GetUnitX(visible)
        set y = GetUnitY(visible)
        set endX = x+RANGE*Cos(heading)
        set endY = y+RANGE*Sin(heading)
        call MoveLocation(terrain,x,y)
        set absoluteZ = GetLocationZ(terrain)+LAUNCH_HEIGHT
        call MoveLocation(terrain,endX,endY)
        // Core constructor arguments are terrain-relative. Keep world Z level
        // rather than accidentally aiming at endpoint terrain+80 on a slope.
        set endZ = absoluteZ-GetLocationZ(terrain)
        set m = RBProjectile.spawn(visible,logical,owning,x,y,endX,endY,endZ)
        if epoch != ticket or not LiveOwned(visible,owning) then
            call m.terminate()
            if epoch == ticket then
                call CancelBurst()
            endif
        else
            call m.launch()
            set shot = m
            set shotSource = visible
            set shotX = m.x
            set shotY = m.y
            call TriggerEvaluate(listener)
            // A listener can Dispose+Initialize+cast recursively. Never clear
            // views or mutate timers belonging to that newer pair/burst epoch.
            if epoch == ticket then
                call ClearShot()
                set notifying = false
            endif
        endif
        set visible = null
        set logical = null
        set owning = null
        set listener = null
    endfunction

    private function OnFire takes nothing returns nothing
        if GetExpiredTimer() == fireTimer then
            call Emit()
        endif
    endfunction

    private function OnCast takes nothing returns boolean
        if GetTriggerUnit() != controller or GetSpellAbilityId() != 'A00G' then
            return false
        endif
        if not PairReady() then
            call CancelBurst()
            return false
        endif
        if remaining > 0 then
            // Reset count and future heading only; keep the running timer phase.
            set remaining = 4
            set heading = Atan2(GetSpellTargetY()-GetUnitY(actor),GetSpellTargetX()-GetUnitX(actor))
            return false
        endif
        if notifying then
            // Preserve the idle/final-pulse reentrancy guard.
            return false
        endif
        set epoch = epoch+1
        set heading = Atan2(GetSpellTargetY()-GetUnitY(actor),GetSpellTargetX()-GetUnitX(actor))
        set remaining = 4
        // One reused per-pair timer; phase starts before the immediate pulse.
        call TimerStart(fireTimer,CADENCE,true,function OnFire)
        call Emit()
        return false
    endfunction

    function RB_Dispose takes nothing returns nothing
        call CancelBurst()
        if castHook != null then
            call DestroyTrigger(castHook)
        endif
        if fireTimer != null then
            call DestroyTimer(fireTimer)
        endif
        if terrain != null then
            call RemoveLocation(terrain)
        endif
        set castHook = null
        set fireTimer = null
        set terrain = null
        set observer = null
        set actor = null
        set controller = null
        set pairOwner = null
        // Existing flights keep snapshots; no caller unit/observer destruction.
    endfunction

    function RB_InitializePair takes unit visible, unit logical, trigger shotObserver returns boolean
        if castHook != null or fireTimer != null or visible == null or logical == null or visible == logical or shotObserver == null then
            return false
        endif
        if GetUnitTypeId(visible) != 'o000' or GetUnitTypeId(logical) != 'o001' or GetUnitAbilityLevel(logical,'A00G') != 1 then
            return false
        endif
        if not LiveOwned(visible,GetOwningPlayer(visible)) or not LiveOwned(logical,GetOwningPlayer(visible)) then
            return false
        endif
        set epoch = epoch+1
        set actor = visible
        set controller = logical
        set pairOwner = GetOwningPlayer(visible)
        set observer = shotObserver
        set remaining = 0
        set notifying = false
        call ClearShot()
        set terrain = Location(0.,0.)
        set fireTimer = CreateTimer()
        set castHook = CreateTrigger()
        call TriggerRegisterUnitEvent(castHook,controller,EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(castHook,Condition(function OnCast))
        return true
    endfunction
endlibrary
