library RFBurstPair requires Missiles, RFConfig
    // Copy-derived from verified Core6442. Singleton pair; flights own snapshots.
    globals
        private constant real LAUNCH_HEIGHT = 80.
        private unit actor = null
        private unit controller = null
        private player pairOwner = null
        private trigger castHook = null
        private trigger orderHook = null
        private trigger observer = null
        private timer fireTimer = null
        private timer moveTimer = null
        private location terrain = null
        private group nearby = null
        private rect footprint = null
        private integer epoch = 0
        private integer remaining = 0
        private boolean notifying = false
        private boolean relaying = false
        private boolean goal = false
        private boolean scriptMoving = false
        private boolean blocked = false
        private boolean treeBlocked = false
        private real goalX = 0.
        private real goalY = 0.
        private real sampleX = 0.
        private real sampleY = 0.
        private real commandedScale = 1.
        private real heading = 0.
        private Missiles shot = 0
        private unit shotSource = null
        private real shotX = 0.
        private real shotY = 0.
    endglobals

    private function LiveOwned takes unit u, player p returns boolean
        return u != null and GetUnitTypeId(u) != 0 and GetWidgetLife(u) > .405 and GetOwningPlayer(u) == p
    endfunction

    private function PairReady takes nothing returns boolean
        return LiveOwned(actor,pairOwner) and LiveOwned(controller,pairOwner)
    endfunction

    private struct RBProjectile extends Missiles
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
            set speed = RF_SPEED
            set collision = RF_RADIUS
            set collideZ = false
            set model = RF_FIREBALL
            return this
        endmethod

        method onHit takes unit hit returns boolean
            if spent or not LiveOwned(savedActor,savedOwner) or not LiveOwned(savedController,savedOwner) then
                return true
            endif
            if hit == savedActor or hit == savedController or GetUnitTypeId(hit) == 0 or GetWidgetLife(hit) <= .405 or not IsUnitEnemy(hit,savedOwner) then
                return false
            endif
            set spent = true
            call UnitDamageTarget(savedActor,hit,RF_DAMAGE,true,true,ATTACK_TYPE_MELEE,DAMAGE_TYPE_NORMAL,null)
            // Native damage is external: no further instance/global writes.
            return true
        endmethod

        method onDestructable takes destructable dest returns boolean
            return GetDestructableLife(dest) > 0.
        endmethod

        method onTerrain takes nothing returns boolean
            // Library dispatch tests actual GetLocationZ(x,y) > world z.
            return true
        endmethod

        method onBoundaries takes nothing returns boolean
            // Library dispatch uses WorldBounds, not camera/playable bounds.
            return true
        endmethod

        method onPeriod takes nothing returns boolean
            return not LiveOwned(savedActor,savedOwner) or not LiveOwned(savedController,savedOwner)
        endmethod

        method onRemove takes nothing returns nothing
            set savedActor = null
            set savedController = null
            set savedOwner = null
            set spent = true
        endmethod
    endstruct

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
    function RB_GetActor takes nothing returns unit
        return actor
    endfunction
    function RB_GetController takes nothing returns unit
        return controller
    endfunction
    function RB_GetRemaining takes nothing returns integer
        return remaining
    endfunction
    function RB_HasGoal takes nothing returns boolean
        return goal
    endfunction
    function RB_IsScriptMoving takes nothing returns boolean
        return scriptMoving
    endfunction
    function RB_IsBlocked takes nothing returns boolean
        return blocked
    endfunction
    function RB_GetCommandedScale takes nothing returns real
        // Command ledger only. Classic has no animation/time-scale getter.
        return commandedScale
    endfunction
    function RB_GetHeading takes nothing returns real
        return heading
    endfunction

    private function ClearShot takes nothing returns nothing
        set shot = 0
        set shotSource = null
        set shotX = 0.
        set shotY = 0.
    endfunction

    private function Scale takes real value returns nothing
        set commandedScale = value
        if GetUnitTypeId(actor) != 0 then
            call SetUnitTimeScale(actor,value)
        endif
    endfunction

    private function CancelBurst takes nothing returns nothing
        set epoch = epoch+1
        set remaining = 0
        set notifying = false
        set goal = false
        set scriptMoving = false
        set blocked = false
        if fireTimer != null then
            call PauseTimer(fireTimer)
        endif
        call ClearShot()
        call Scale(1.)
    endfunction

    private function Ground takes real x, real y returns real
        call MoveLocation(terrain,x,y)
        return GetLocationZ(terrain)
    endfunction

    private function VisitTree takes nothing returns nothing
        local destructable d = GetEnumDestructable()
        // Conservative 128-unit unknown destructible footprint plus actor32.
        if GetDestructableLife(d) > 0. and RAbsBJ(GetDestructableX(d)-sampleX) <= 160. and RAbsBJ(GetDestructableY(d)-sampleY) <= 160. then
            set treeBlocked = true
        endif
        set d = null
    endfunction

    private function OwnFlightVisual takes unit u returns boolean
        local integer i = 0
        local Missiles m
        // A fresh public entry proves an active owned visual, not just rawcode.
        // Pending recycler bodies and unknown dummies are never exempted here.
        loop
            exitwhen i > Missiles.count
            set m = Missiles.collection[i]
            if m.allocated and m.source == actor and m.dummy == u then
                return true
            endif
            set i = i+1
        endloop
        return false
    endfunction

    private function ClearFootprint takes real x, real y, real oldZ returns boolean
        local integer i = -1
        local integer j
        local real px
        local real py
        local unit u
        local boolean clear = true
        if x-32. <= WorldBounds.minX or x+32. >= WorldBounds.maxX or y-32. <= WorldBounds.minY or y+32. >= WorldBounds.maxY then
            return false
        endif
        // Two substeps, each with a 3x3 radius32 grid. No point-placement hacks.
        loop
            exitwhen i > 1
            set j = -1
            loop
                exitwhen j > 1
                set px = x+i*32.
                set py = y+j*32.
                if IsTerrainPathable(px,py,PATHING_TYPE_WALKABILITY) or RAbsBJ(Ground(px,py)-oldZ) > 24. then
                    return false
                endif
                set j = j+1
            endloop
            set i = i+1
        endloop
        call GroupEnumUnitsInRange(nearby,x,y,768.,null)
        loop
            set u = FirstOfGroup(nearby)
            exitwhen u == null
            call GroupRemoveUnit(nearby,u)
            // Actual native footprint OR conservative unknown radius64.
            // Buildings get wider conservative256. Do not ignore unknown units.
            if u != actor and u != controller and GetWidgetLife(u) > .405 and not IsUnitType(u,UNIT_TYPE_FLYING) and not OwnFlightVisual(u) then
                if IsUnitInRangeXY(u,x,y,96.) or (IsUnitType(u,UNIT_TYPE_STRUCTURE) and IsUnitInRangeXY(u,x,y,288.)) then
                    set clear = false
                endif
            endif
        endloop
        set u = null
        if not clear then
            return false
        endif
        set sampleX = x
        set sampleY = y
        set treeBlocked = false
        call SetRect(footprint,x-288.,y-288.,x+288.,y+288.)
        call EnumDestructablesInRect(footprint,null,function VisitTree)
        return not treeBlocked
    endfunction

    private function OnMove takes nothing returns nothing
        local integer ticket = epoch
        local unit visible = null
        local real x
        local real y
        local real dx
        local real dy
        local real dist
        local real step
        local real z
        if not PairReady() then
            if remaining > 0 or goal then
                call CancelBurst()
                // State committed before external order dispatch.
                call IssueImmediateOrder(actor,"stop")
            endif
            return
        endif
        if not goal then
            return
        endif
        set x = GetUnitX(actor)
        set y = GetUnitY(actor)
        set dx = goalX-x
        set dy = goalY-y
        set dist = SquareRoot(dx*dx+dy*dy)
        if dist <= 4. then
            set goal = false
            set scriptMoving = false
            set blocked = false
            return
        endif
        if remaining <= 0 or not scriptMoving or blocked then
            return
        endif
        set step = RMinBJ(RF_MOVE_SPEED*RF_MOVE_PERIOD,dist)
        set dx = dx*step/dist
        set dy = dy*step/dist
        set z = Ground(x,y)
        if not ClearFootprint(x+dx*.5,y+dy*.5,z) or not ClearFootprint(x+dx,y+dy,z) then
            set blocked = true
            // Retain destination for ordinary native pathfinding at exhaustion.
            return
        endif
        set visible = actor
        call SetUnitX(visible,x+dx)
        if epoch != ticket then
            set visible = null
            return
        endif
        call SetUnitY(visible,y+dy)
        set visible = null
        if epoch != ticket then
            return
        endif
        // No native order, facing, or animation call on the script step.
        if step >= dist then
            set goal = false
            set scriptMoving = false
        endif
    endfunction

    private function ResumeNative takes nothing returns nothing
        local unit visible = actor
        local real x = goalX
        local real y = goalY
        local boolean resume = goal
        set scriptMoving = false
        set blocked = false
        call Scale(1.)
        if resume then
            // Last operation: a public order can invoke arbitrary listeners.
            call IssuePointOrder(visible,"move",x,y)
        endif
        set visible = null
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
        else
            set remaining = remaining-1
            set notifying = true
            if remaining == 0 then
                call PauseTimer(fireTimer)
            endif
            call Scale(RF_ATTACK_SCALE)
            call SetUnitAnimation(visible,"attack")
            set x = GetUnitX(visible)
            set y = GetUnitY(visible)
            set endX = x+RF_RANGE*Cos(heading)
            set endY = y+RF_RANGE*Sin(heading)
            set absoluteZ = Ground(x,y)+LAUNCH_HEIGHT
            set endZ = absoluteZ-Ground(endX,endY)
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
                if epoch == ticket then
                    call ClearShot()
                    set notifying = false
                    if remaining == 0 then
                        call ResumeNative()
                    endif
                endif
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
        local integer ticket = epoch
        local real angle
        if GetTriggerUnit() != controller or GetSpellAbilityId() != 'A00G' then
            return false
        endif
        if not PairReady() then
            call CancelBurst()
            return false
        endif
        set angle = Atan2(GetSpellTargetY()-GetUnitY(actor),GetSpellTargetX()-GetUnitX(actor))
        if remaining > 0 then
            set remaining = RF_SHOTS
            set heading = angle
            call SetUnitFacing(actor,angle*bj_RADTODEG)
            return false
        endif
        if notifying then
            return false
        endif
        set epoch = epoch+1
        set ticket = epoch
        set heading = angle
        set remaining = RF_SHOTS
        set scriptMoving = goal
        set blocked = false
        // Stop once on takeover, before facing/animation; remember native goal.
        call IssueImmediateOrder(actor,"stop")
        if epoch != ticket or not PairReady() then
            return false
        endif
        call SetUnitFacing(actor,angle*bj_RADTODEG)
        call TimerStart(fireTimer,1./RF_HZ,true,function OnFire)
        call Emit()
        return false
    endfunction

    private function OnPoint takes nothing returns boolean
        local unit u = GetTriggerUnit()
        local integer id = GetIssuedOrderId()
        local integer ticket = epoch
        local real x = GetOrderPointX()
        local real y = GetOrderPointY()
        if relaying or (id != OrderId("move") and id != OrderId("smart")) or not PairReady() then
            set u = null
            return false
        endif
        set goal = true
        set goalX = x
        set goalY = y
        set blocked = false
        set scriptMoving = remaining > 0
        set relaying = true
        if u == controller then
            call IssueImmediateOrder(controller,"stop")
        endif
        if epoch == ticket then
            if remaining > 0 then
                call IssueImmediateOrder(actor,"stop")
            elseif u == controller then
                call IssuePointOrder(actor,"move",x,y)
            endif
        endif
        if epoch == ticket then
            set relaying = false
        endif
        set u = null
        return false
    endfunction

    private function OnImmediate takes nothing returns boolean
        local integer ticket = epoch
        if relaying or GetIssuedOrderId() != OrderId("stop") or not PairReady() then
            return false
        endif
        // Actor stop from cast takeover must NOT erase its remembered goal.
        // User control is through the controller; actor point orders are tracked.
        if GetTriggerUnit() == actor then
            return false
        endif
        set goal = false
        set scriptMoving = false
        set blocked = false
        set relaying = true
        call IssueImmediateOrder(actor,"stop")
        if epoch == ticket then
            set relaying = false
        endif
        return false
    endfunction

    private function OnTarget takes nothing returns boolean
        local unit target = GetOrderTargetUnit()
        local integer ticket = epoch
        local real x
        local real y
        if relaying or GetIssuedOrderId() != OrderId("smart") or not PairReady() or GetTriggerUnit() != controller then
            set target = null
            return false
        endif
        if target != null then
            set x = GetUnitX(target)
            set y = GetUnitY(target)
        else
            set x = GetWidgetX(GetOrderTarget())
            set y = GetWidgetY(GetOrderTarget())
        endif
        set goal = true
        set goalX = x
        set goalY = y
        set blocked = false
        set scriptMoving = remaining > 0
        set relaying = true
        call IssueImmediateOrder(controller,"stop")
        if epoch == ticket then
            if remaining > 0 then
                call IssueImmediateOrder(actor,"stop")
            else
                call IssuePointOrder(actor,"move",x,y)
            endif
        endif
        if epoch == ticket then
            set relaying = false
        endif
        set target = null
        return false
    endfunction

    private function OnOrder takes nothing returns boolean
        if GetTriggerEventId() == EVENT_UNIT_ISSUED_POINT_ORDER then
            return OnPoint()
        elseif GetTriggerEventId() == EVENT_UNIT_ISSUED_TARGET_ORDER then
            return OnTarget()
        endif
        return OnImmediate()
    endfunction

    function RB_Dispose takes nothing returns nothing
        local unit oldActor = actor
        local unit oldController = controller
        local integer ticket
        call CancelBurst()
        set ticket = epoch
        if castHook != null then
            call DestroyTrigger(castHook)
            call DestroyTrigger(orderHook)
            call DestroyTimer(fireTimer)
            call DestroyTimer(moveTimer)
            call RemoveLocation(terrain)
            call DestroyGroup(nearby)
            call RemoveRect(footprint)
        endif
        set castHook = null
        set orderHook = null
        set fireTimer = null
        set moveTimer = null
        set terrain = null
        set nearby = null
        set footprint = null
        set observer = null
        set actor = null
        set controller = null
        set pairOwner = null
        set relaying = false
        // No shared-state writes after external listeners can initialize a pair.
        call IssueImmediateOrder(oldActor,"stop")
        if epoch == ticket then
            call IssueImmediateOrder(oldController,"stop")
        endif
        set oldActor = null
        set oldController = null
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
        set relaying = false
        set goal = false
        set scriptMoving = false
        set blocked = false
        call Scale(1.)
        call SetUnitMoveSpeed(actor,RF_MOVE_SPEED)
        call ClearShot()
        set terrain = Location(0.,0.)
        set nearby = CreateGroup()
        set footprint = Rect(0.,0.,0.,0.)
        set fireTimer = CreateTimer()
        set moveTimer = CreateTimer()
        set castHook = CreateTrigger()
        set orderHook = CreateTrigger()
        call TriggerRegisterUnitEvent(castHook,controller,EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(castHook,Condition(function OnCast))
        call TriggerRegisterUnitEvent(orderHook,controller,EVENT_UNIT_ISSUED_POINT_ORDER)
        call TriggerRegisterUnitEvent(orderHook,actor,EVENT_UNIT_ISSUED_POINT_ORDER)
        call TriggerRegisterUnitEvent(orderHook,controller,EVENT_UNIT_ISSUED_TARGET_ORDER)
        call TriggerRegisterUnitEvent(orderHook,controller,EVENT_UNIT_ISSUED_ORDER)
        call TriggerAddCondition(orderHook,Condition(function OnOrder))
        call TimerStart(moveTimer,RF_MOVE_PERIOD,true,function OnMove)
        return true
    endfunction
endlibrary
