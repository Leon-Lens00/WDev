library RFIntegratedTest requires RFBurstLog, RFBurstPair, RFDemo
    // One native battery, public orders/effects/collection/damage. No stored ID
    // is ever dereferenced; numeric flight tokens are comparisons only.
    globals
        private unit actor = null
        private unit logical = null
        private unit enemy = null
        private unit downstream = null
        private unit blocker = null
        private destructable tree = null
        private trigger shotsHook = null
        private trigger damageHook = null
        private timer clock = null
        private timer runner = null
        private location probe = null
        private group surveyGroup = null
        private rect surveyRect = null
        private integer scene = 0
        private integer phase = 0
        private integer pulses = 0
        private integer live = 0
        private integer hits = 0
        private integer wrongDamage = 0
        private integer downHits = 0
        private integer stage = 0
        private boolean done = false
        private boolean fault = false
        private boolean clearRay = true
        private boolean admission = false
        private boolean moverSpeed = true
        private boolean moverFacing = true
        private boolean sawScript = false
        private boolean sawBlocked = false
        private boolean sawResume = false
        private boolean resumedDisplacement = false
        private boolean blockedStable = true
        private real blockedX = 0.
        private real blockedY = 0.
        private boolean sawNativeBefore = false
        private boolean reentered = false
        private real start = 0.
        private real cleanupAt = 0.
        private real castAt = -1.
        private real ax = -3136.
        private real ay = 2624.
        private real angle = 0.
        private real wallLo = 0.
        private real wallHi = 0.
        private real edgeDistance = 0.
        private real sourceHP = 0.
        private real enemyHP = 0.
        private real downstreamHP = 0.
        private real treeHP = 0.
        private real blockerHP = 0.
        private real prevX = 0.
        private real prevY = 0.
        private real stoppedX = 0.
        private real stoppedY = 0.
        private real scriptDistance = 0.
        private integer scriptTicks = 0
        private integer array token
        private boolean array closed
        private boolean array seen
        private real array birth
        private real array bx
        private real array by
        private real array bz
        private real array lx
        private real array ly
        private real array ld
        private real array absent
        private real array direction
    endglobals

    private function Now takes nothing returns real
        return TimerGetElapsed(clock)
    endfunction
    private function Ground takes real x, real y returns real
        call MoveLocation(probe,x,y)
        return GetLocationZ(probe)
    endfunction
    private function Distance takes real x, real y, real xx, real yy returns real
        return SquareRoot((x-xx)*(x-xx)+(y-yy)*(y-yy))
    endfunction
    private function At takes unit u, real x, real y returns boolean
        return Distance(GetUnitX(u),GetUnitY(u),x,y) <= 1.
    endfunction
    private function Bodies takes nothing returns boolean
        return GetUnitTypeId(actor) == 'o000' and GetWidgetLife(actor) > .405 and GetOwningPlayer(actor) == Player(0) and GetUnitTypeId(logical) == 'o001' and GetWidgetLife(logical) > .405 and GetOwningPlayer(logical) == Player(0) and not IsUnitPaused(actor) and not IsUnitPaused(logical) and not IsUnitHidden(actor) and not IsUnitHidden(logical) and At(logical,-5500.,-5500.)
    endfunction

    private function Scan takes integer incoming returns nothing
        local integer i = 0
        local integer j = 1
        local integer match
        local Missiles m
        local real d
        set live = 0
        loop
            exitwhen j > pulses or j > 16
            set seen[j] = false
            set j = j+1
        endloop
        if Missiles.count > 64 then
            set fault = true
            return
        endif
        loop
            exitwhen i > Missiles.count
            set m = Missiles.collection[i]
            if m.allocated and m.source == actor then
                set live = live+1
                set match = 0
                set j = 1
                loop
                    exitwhen j > pulses or j > 16
                    if not closed[j] and token[j] == m then
                        set match = j
                    endif
                    set j = j+1
                endloop
                if m != incoming then
                    if match == 0 then
                        set fault = true
                    else
                        set seen[match] = true
                        set lx[match] = m.x
                        set ly[match] = m.y
                        set d = Distance(m.x,m.y,bx[match],by[match])
                        set ld[match] = RMaxBJ(ld[match],d)
                        // World height and launch heading remain snapshots even
                        // while actor moves/recasts. No homing toward old point.
                        if RAbsBJ(m.z-bz[match]) > .1 or RAbsBJ((m.x-bx[match])*Sin(direction[match])-(m.y-by[match])*Cos(direction[match])) > 1. then
                            set fault = true
                        endif
                    endif
                endif
            endif
            set i = i+1
        endloop
        set j = 1
        loop
            exitwhen j > pulses or j > 16
            if not closed[j] and not seen[j] then
                set closed[j] = true
                set absent[j] = Now()
            endif
            set j = j+1
        endloop
    endfunction

    private function OnShot takes nothing returns boolean
        local Missiles m = RB_GetShotMissile()
        local integer j = 1
        local real expected = angle
        loop
            exitwhen j > pulses or j > 16
            if not closed[j] and token[j] == m then
                set fault = true
            endif
            set j = j+1
        endloop
        call Scan(m)
        set pulses = pulses+1
        if pulses > 16 or m == 0 then
            set fault = true
            return false
        endif
        if castAt < 0. then
            set castAt = Now()
        endif
        if scene == 1 and pulses >= 2 then
            set expected = bj_PI
        endif
        set token[pulses] = m
        set closed[pulses] = false
        set birth[pulses] = Now()
        set bx[pulses] = m.x
        set by[pulses] = m.y
        set bz[pulses] = m.z
        set lx[pulses] = m.x
        set ly[pulses] = m.y
        set ld[pulses] = 0.
        set absent[pulses] = 0.
        set direction[pulses] = expected
        if not m.allocated or not m.launched or m.source != actor or RB_GetShotSource() != actor or not At(actor,m.x,m.y) or RAbsBJ(m.z-Ground(m.x,m.y)-80.) > .1 or RAbsBJ(m.nextX-m.x-30.*Cos(expected)) > .1 or RAbsBJ(m.nextY-m.y-30.*Sin(expected)) > .1 then
            set fault = true
        endif
        call RB_LogCheck(RB_GetCommandedScale() == 3.,"shot-attack-scale-command","pulse="+I2S(pulses)+" ledger only; visual gesture requires inspection")
        if scene == 9 and not reentered then
            set reentered = true
            call RB_Dispose()
            call RB_LogCheck(RB_InitializePair(actor,logical,shotsHook),"observer-reinitialize","same units, fresh pair while old Emit callback is on stack")
        endif
        return false
    endfunction

    private function OnDamage takes nothing returns boolean
        if GetTriggerUnit() == enemy then
            set hits = hits+1
            if GetEventDamageSource() != actor or RAbsBJ(GetEventDamage()-10.) > .01 then
                set wrongDamage = wrongDamage+1
            endif
        elseif GetTriggerUnit() == downstream then
            set downHits = downHits+1
        endif
        return false
    endfunction

    private function VisitDest takes nothing returns nothing
        if GetDestructableLife(GetEnumDestructable()) > 0. then
            set clearRay = false
        endif
    endfunction

    private function Corridor takes real x1, real y1, real x2, real y2 returns boolean
        local unit u
        set clearRay = true
        call SetRect(surveyRect,RMinBJ(x1,x2)-160.,RMinBJ(y1,y2)-160.,RMaxBJ(x1,x2)+160.,RMaxBJ(y1,y2)+160.)
        call GroupEnumUnitsInRect(surveyGroup,surveyRect,null)
        loop
            set u = FirstOfGroup(surveyGroup)
            exitwhen u == null
            call GroupRemoveUnit(surveyGroup,u)
            if u != actor and u != logical and GetWidgetLife(u) > .405 then
                // Previous dummy bodies are not flights, but are not ignored.
                set clearRay = false
            endif
        endloop
        call EnumDestructablesInRect(surveyRect,null,function VisitDest)
        set u = null
        return clearRay
    endfunction

    private function WallCandidate takes real y returns boolean
        local integer k = 1
        local real z
        local real g
        local boolean higher = false
        call RemoveUnit(actor)
        set ax = -3952.
        set ay = y
        set actor = CreateUnit(Player(0),'o000',ax,ay,0.)
        set z = Ground(GetUnitX(actor),GetUnitY(actor))+80.
        set wallLo = 0.
        set wallHi = 0.
        loop
            exitwhen k > 20
            set g = Ground(GetUnitX(actor)+30.*k,GetUnitY(actor))
            if wallHi == 0. and g > z then
                set wallLo = 30.*(k-1)
                set wallHi = 30.*k
                set higher = GetTerrainCliffLevel(GetUnitX(actor)+30.*k,GetUnitY(actor)) > GetTerrainCliffLevel(GetUnitX(actor),GetUnitY(actor))
            endif
            set k = k+1
        endloop
        call RB_LogRecord("OBS","native-wall-candidate","wanted="+R2S(ax)+","+R2S(ay)+" actual="+R2S(GetUnitX(actor))+","+R2S(GetUnitY(actor))+" worldZ="+R2S(z)+" intersection="+R2S(wallLo)+".."+R2S(wallHi)+" groundEast256="+R2S(Ground(ax+256.,ay)))
        return At(actor,ax,ay) and not IsTerrainPathable(ax,ay,PATHING_TYPE_WALKABILITY) and higher and wallHi > 0. and wallLo >= 30. and Corridor(ax,ay,ax+wallHi+64.,ay)
    endfunction

    private function BoundaryCandidate takes integer which returns boolean
        local real x = -3136.
        local real y = 2624.
        local real z
        local real k = 0.
        local boolean ok = true
        if which == 0 then
            set x = WorldBounds.minX+96.
            set angle = bj_PI
        elseif which == 1 then
            set x = WorldBounds.maxX-96.
            set angle = 0.
        elseif which == 2 then
            set y = WorldBounds.minY+96.
            set angle = -bj_PI/2.
        else
            set y = WorldBounds.maxY-96.
            set angle = bj_PI/2.
        endif
        call RemoveUnit(actor)
        set actor = CreateUnit(Player(0),'o000',x,y,angle*bj_RADTODEG)
        set ax = GetUnitX(actor)
        set ay = GetUnitY(actor)
        set edgeDistance = 96.
        set z = Ground(ax,ay)+80.
        loop
            exitwhen k >= 96.
            if Ground(ax+k*Cos(angle),ay+k*Sin(angle)) > z then
                set ok = false
            endif
            set k = k+16.
        endloop
        call RB_LogRecord("OBS","native-boundary-candidate","side="+I2S(which)+" wanted="+R2S(x)+","+R2S(y)+" actual="+R2S(ax)+","+R2S(ay)+" ground="+R2S(z-80.)+" world="+I2S(WorldBounds.minX)+","+I2S(WorldBounds.maxX)+","+I2S(WorldBounds.minY)+","+I2S(WorldBounds.maxY))
        return ok and At(actor,x,y) and not IsTerrainPathable(ax,ay,PATHING_TYPE_WALKABILITY) and Corridor(ax,ay,ax+96.*Cos(angle),ay+96.*Sin(angle))
    endfunction

    private function ClearFlights takes nothing returns nothing
        local integer i = 0
        local Missiles m
        loop
            exitwhen i > Missiles.count
            set m = Missiles.collection[i]
            if m.allocated and m.source == actor then
                call m.terminate()
            else
                set i = i+1
            endif
        endloop
    endfunction

    private function RemoveScene takes nothing returns nothing
        call RB_Dispose()
        call ClearFlights()
        if damageHook != null then
            call DestroyTrigger(damageHook)
        endif
        call RemoveUnit(actor)
        call RemoveUnit(logical)
        call RemoveUnit(enemy)
        call RemoveUnit(downstream)
        call RemoveUnit(blocker)
        if tree != null then
            call RemoveDestructable(tree)
        endif
        set actor = null
        set logical = null
        set enemy = null
        set downstream = null
        set blocker = null
        set tree = null
        set damageHook = null
    endfunction

    private function Finish takes nothing returns nothing
        if done then
            return
        endif
        set done = true
        call PauseTimer(runner)
        call RemoveScene()
        call DestroyTimer(runner)
        call DestroyTrigger(shotsHook)
        call RemoveLocation(probe)
        call DestroyGroup(surveyGroup)
        call RemoveRect(surveyRect)
        call RB_LogComplete()
        call RF_StartDemo()
        call DestroyTimer(clock)
        set clock = null
        set runner = null
        set shotsHook = null
        set probe = null
        set surveyGroup = null
        set surveyRect = null
    endfunction

    private function Abort takes string reason returns nothing
        call RB_LogRecord("FAIL","ABORT-fixture",reason+"; no behavioral PASS inferred")
        call Finish()
    endfunction
    private function Deadline takes nothing returns nothing
        call Abort("global90 game-second deadline")
    endfunction

    private function Cast takes real a returns nothing
        call RB_LogCheck(IssuePointOrder(logical,"channel",GetUnitX(actor)+1500.*Cos(a),GetUnitY(actor)+1500.*Sin(a)),"public-cast-order","native Channel point order; effect required by pulse deadline")
    endfunction

    private function CreateScene takes nothing returns nothing
        local integer i = 0
        set scene = scene+1
        set pulses = 0
        set hits = 0
        set downHits = 0
        set wrongDamage = 0
        set live = 0
        set stage = 0
        set fault = false
        set admission = true
        set castAt = -1.
        set angle = 0.
        set ax = -3136.
        set ay = 2624.
        set scriptTicks = 0
        set scriptDistance = 0.
        set moverSpeed = true
        set moverFacing = true
        set sawScript = false
        set sawBlocked = false
        set sawResume = false
        set resumedDisplacement = false
        set blockedStable = true
        set sawNativeBefore = false
        set reentered = false
        set actor = CreateUnit(Player(0),'o000',ax,ay,0.)
        set logical = CreateUnit(Player(0),'o001',-5500.,-5500.,0.)
        if scene == 1 then
            call RB_LogCase("I01-recast-phase-moving-takeover")
        elseif scene == 2 then
            call RB_LogCase("I02-flat-range-flight-lifetimes")
        elseif scene == 3 then
            call RB_LogCase("I03-first-enemy-physical-source")
        elseif scene == 4 then
            call RB_LogCase("I04-live-tree-no-downstream-damage")
        elseif scene == 5 then
            call RB_LogCase("I05-native-physical-wall")
            set admission = WallCandidate(5136.)
            if not admission then
                set admission = WallCandidate(5104.)
            endif
        elseif scene == 6 then
            call RB_LogCase("I06-world-boundary")
            set admission = false
            loop
                exitwhen i >= 4 or admission
                set admission = BoundaryCandidate(i)
                set i = i+1
            endloop
        elseif scene == 7 then
            call RB_LogCase("I07-blocked-stop-native-resume")
        elseif scene == 8 then
            call RB_LogCase("I08-arrival-facing-shooting")
        else
            call RB_LogCase("I09-observer-reentry-owner-change")
        endif
        if scene != 5 and scene != 6 then
            set admission = At(actor,ax,ay) and Corridor(ax,ay,ax+1500.,ay)
        endif
        set admission = admission and At(logical,-5500.,-5500.) and Bodies()
        if scene == 3 or scene == 4 then
            set enemy = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'o000',ax+512.,ay,180.)
            set downstream = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'o000',ax+768.,ay,180.)
            call PauseUnit(enemy,true)
            call PauseUnit(downstream,true)
            set admission = admission and At(enemy,ax+512.,ay) and At(downstream,ax+768.,ay)
            set enemyHP = GetWidgetLife(enemy)
            set downstreamHP = GetWidgetLife(downstream)
            set damageHook = CreateTrigger()
            call TriggerRegisterUnitEvent(damageHook,enemy,EVENT_UNIT_DAMAGED)
            call TriggerRegisterUnitEvent(damageHook,downstream,EVENT_UNIT_DAMAGED)
            call TriggerAddCondition(damageHook,Condition(function OnDamage))
        endif
        if scene == 3 then
            set blocker = CreateUnit(Player(0),'o000',ax+256.,ay,0.)
            call PauseUnit(blocker,true)
            set blockerHP = GetWidgetLife(blocker)
            set admission = admission and At(blocker,ax+256.,ay)
        endif
        if scene == 4 then
            set tree = CreateDestructable('LTlt',ax+128.,ay,0.,1.,0)
            set treeHP = GetDestructableLife(tree)
            set admission = admission and treeHP > 0. and RAbsBJ(GetDestructableX(tree)-ax-128.) <= 1. and RAbsBJ(GetDestructableY(tree)-ay) <= 1.
        elseif scene == 7 then
            set blocker = CreateUnit(Player(0),'o000',ax,ay+128.,0.)
            call PauseUnit(blocker,true)
            set admission = admission and At(blocker,ax,ay+128.)
        endif
        set sourceHP = GetWidgetLife(actor)
        set prevX = GetUnitX(actor)
        set prevY = GetUnitY(actor)
        set start = Now()
        set phase = 1
        if not admission then
            call Abort("native placement/corridor/physical candidate unavailable in scene"+I2S(scene))
            return
        endif
        if not RB_InitializePair(actor,logical,shotsHook) then
            call Abort("pair initialization rejected")
            return
        endif
        call RB_LogRecord("OBS","admission","scene="+I2S(scene)+" actual="+R2S(ax)+","+R2S(ay)+" sourceHP="+R2S(sourceHP)+" prior flights closed and recycler wait3s before fixture")
        if scene == 1 then
            call RB_LogCheck(IssuePointOrder(logical,"move",ax,ay+1200.),"native-controller-move","cast takeover follows after .25s of actual movement")
        elseif scene == 8 then
            set angle = bj_PI/2.
            call Cast(angle)
            call RB_LogCheck(IssuePointOrder(logical,"move",ax+64.,ay),"short-script-destination","64 units while firing north")
        elseif scene == 7 then
            call Cast(0.)
            call RB_LogCheck(IssuePointOrder(logical,"move",ax,ay+1200.),"blocked-move-order","owned blocker at north128; no collision bypass")
        else
            call Cast(angle)
        endif
    endfunction

    private function Assess takes nothing returns nothing
        local integer j = 1
        local integer expected = 4
        local boolean cadence = true
        local boolean closure = true
        local boolean lifetime = true
        local boolean path = true
        local boolean movedBetweenShots = false
        local real age
        if scene == 1 then
            set expected = 5
        elseif scene == 9 then
            set expected = 2
        endif
        loop
            exitwhen j > pulses or j > 16
            set age = absent[j]-birth[j]
            set closure = closure and closed[j]
            if j > 1 and scene != 9 then
                set cadence = cadence and RAbsBJ(birth[j]-birth[j-1]-.25) <= .032
            endif
            if scene == 2 then
                set lifetime = lifetime and age >= 1.225 and age <= 1.35 and ld[j] >= 1410. and ld[j] <= 1500.1
            elseif scene == 4 then
                set lifetime = lifetime and age > 0. and age <= .25 and ld[j] < 220.
            elseif scene == 5 then
                set lifetime = lifetime and age >= RMaxBJ(0.,wallLo/1200.-.05) and age <= wallHi/1200.+.09 and ld[j] <= wallHi+30. and ld[j] >= RMaxBJ(0.,wallLo-90.)
            elseif scene == 6 then
                set lifetime = lifetime and age > 0. and age <= edgeDistance/1200.+.1 and ld[j] <= edgeDistance+30.
            endif
            if scene == 1 and j >= 2 then
                set path = path and RAbsBJ(direction[j]-bj_PI) < .01 and bx[j] <= ax+1. and by[j] > ay
                set movedBetweenShots = movedBetweenShots or RAbsBJ(by[j]-by[j-1]) > 10.
            endif
            if scene == 2 or scene == 4 or scene == 5 or scene == 6 then
                call RB_LogRecord("OBS","measured-flight-bracket","pulse="+I2S(j)+" lastDistance="+R2S(ld[j])+" ageAtAbsence="+R2S(age))
            endif
            set j = j+1
        endloop
        call RB_LogCheck(pulses == expected,"real-public-launch-count","actual="+I2S(pulses)+" expected="+I2S(expected))
        call RB_LogCheck(cadence,"preserved-quarter-second-phase","recast adds no immediate pulse; actual launch timestamps")
        call RB_LogCheck(closure and live == 0,"all-flights-closed-before-cleanup","fresh public collection and per-serial absence; no recycled ID dereference")
        call RB_LogCheck(not fault,"flight-source-origin-fixed-height-heading","birth and every actual flight sample checked against its own snapshot")
        call RB_LogCheck(RB_GetRemaining() == 0 and RB_GetCommandedScale() == 1.,"exhaustion-normalizes-commanded-scale","100percent command ledger, not an invented engine getter")
        call RB_LogCheck(RAbsBJ(GetWidgetLife(actor)-sourceHP) <= .01,"source-health-unchanged","HP before="+R2S(sourceHP)+" after="+R2S(GetWidgetLife(actor)))
        if scene == 1 then
            call RB_LogCheck(sawNativeBefore and sawScript and scriptTicks >= 4 and moverSpeed and scriptDistance > 40.,"native-to-script350","sampled displacement="+R2S(scriptDistance)+" ticks="+I2S(scriptTicks)+" each unblocked step10.9375")
            call RB_LogCheck(path and moverFacing and movedBetweenShots,"future-angle-launched-heading-facing","moving actor does not reaim at old world point; cast updates only")
        elseif scene == 2 then
            call RB_LogCheck(lifetime,"range1500-speed1200","actual far travel and1.25s lifetime brackets, not parameter presence")
        elseif scene == 3 then
            call RB_LogCheck(hits == 4 and wrongDamage == 0 and RAbsBJ(enemyHP-GetWidgetLife(enemy)-40.) <= .01,"four-native10-visible-source-hits","hits="+I2S(hits)+" wrong="+I2S(wrongDamage)+" actualHPloss="+R2S(enemyHP-GetWidgetLife(enemy)))
            call RB_LogCheck(downHits == 0 and GetWidgetLife(downstream) == downstreamHP and GetWidgetLife(blocker) == blockerHP,"no-friendly-damage-pierce-or-splash","friendly in flight lane passed unchanged; downstream native events and HP unchanged")
        elseif scene == 4 then
            call RB_LogCheck(lifetime and hits == 0 and downHits == 0 and GetWidgetLife(enemy) == enemyHP and GetWidgetLife(downstream) == downstreamHP and GetDestructableLife(tree) == treeHP,"tree-terminates-without-damage","early actual closure; both downstream HP/events and live tree HP unchanged")
        elseif scene == 5 then
            call RB_LogCheck(lifetime,"physical-ground-wall-termination","native first ground greater than worldZ bracket="+R2S(wallLo)+".."+R2S(wallHi)+"; no legacy corner-level predicate")
        elseif scene == 6 then
            call RB_LogCheck(lifetime,"actual-world-boundary-termination","naturally placed actor96 from actual WorldBounds; no forced placement")
        elseif scene == 7 then
            call RB_LogCheck(sawBlocked and blockedStable and sawResume and resumedDisplacement,"blocked-footprint-and-native-handoff","blocked actual XY unchanged before exhaustion; native Move and measured displacement afterward")
            call RB_LogCheck(Distance(GetUnitX(actor),GetUnitY(actor),stoppedX,stoppedY) <= 1. and not RB_HasGoal(),"stop-clears-goal-and-motion","native stopped position retained to end; no burst count/phase changes")
        elseif scene == 8 then
            call RB_LogCheck(At(actor,ax+64.,ay) and not RB_HasGoal() and moverFacing and pulses == 4 and bx[1] < bx[2] and RAbsBJ(bx[2]-ax-64.) <= 1.,"arrival-with-fixed-facing-and-firing","actual64 translation between launches, north facing during motion, no native resume after arrival")
        else
            call RB_LogCheck(reentered and RB_GetRemaining() == 0,"observer-reentry-and-owner-invalidation","new pair survives old Emit return; second burst stops on controller owner change")
        endif
        set phase = 2
        set cleanupAt = Now()
    endfunction

    private function Tick takes nothing returns nothing
        local real t = Now()-start
        local real step
        if done then
            return
        endif
        call Scan(0)
        if phase == 2 then
            if live != 0 then
                call Abort("source flight reappeared after closure")
                return
            endif
            if Now()-cleanupAt >= 3. then
                if scene >= 9 then
                    call Finish()
                else
                    call RemoveScene()
                    call CreateScene()
                endif
            endif
            return
        endif
        if not Bodies() and not (scene == 9 and stage >= 2) then
            call Abort("pair identity/life/ownership changed unexpectedly")
            return
        endif
        if scene == 1 then
            if stage == 0 and t >= .25 then
                set sawNativeBefore = GetUnitY(actor) > ay+20. and GetUnitCurrentOrder(actor) == OrderId("move")
                set stage = 1
                call Cast(0.)
                set prevX = GetUnitX(actor)
                set prevY = GetUnitY(actor)
            elseif stage == 1 and castAt >= 0. and Now()-castAt >= .125 then
                set stage = 2
                call Cast(bj_PI)
            elseif stage == 2 and castAt >= 0. and Now()-castAt >= .625 then
                set stage = 3
                call IssueImmediateOrder(logical,"stop")
            elseif stage == 3 and castAt >= 0. and Now()-castAt >= .75 then
                set stage = 4
                call IssuePointOrder(logical,"move",ax,ay+1200.)
            endif
            if RB_IsScriptMoving() and RB_GetRemaining() > 0 and stage == 2 and Now()-castAt >= .15625 then
                set sawScript = true
                set step = Distance(GetUnitX(actor),GetUnitY(actor),prevX,prevY)
                if step > .01 then
                    set scriptTicks = scriptTicks+1
                    set scriptDistance = scriptDistance+step
                    set moverSpeed = moverSpeed and RAbsBJ(step-10.9375) <= .2
                endif
                // Facing can take engine turn time after recast; measure after.25.
                if Now()-castAt >= .375 then
                    set moverFacing = moverFacing and RAbsBJ(GetUnitFacing(actor)-180.) <= 3.
                endif
            endif
        elseif scene == 7 then
            if RB_IsBlocked() then
                if not sawBlocked then
                    set blockedX = GetUnitX(actor)
                    set blockedY = GetUnitY(actor)
                    set sawBlocked = true
                endif
                set blockedStable = blockedStable and Distance(GetUnitX(actor),GetUnitY(actor),blockedX,blockedY) <= .1 and GetUnitY(actor) <= ay+32.
            endif
            if t >= .8125 and t < 1.125 then
                set sawResume = sawResume or GetUnitCurrentOrder(actor) == OrderId("move")
                set resumedDisplacement = resumedDisplacement or Distance(GetUnitX(actor),GetUnitY(actor),prevX,prevY) > 1.
            endif
            if stage == 0 and t >= 1.125 then
                set stage = 1
                call IssueImmediateOrder(logical,"stop")
            elseif stage == 1 and t >= 1.25 then
                set stage = 2
                set stoppedX = GetUnitX(actor)
                set stoppedY = GetUnitY(actor)
            endif
        elseif scene == 8 then
            if t >= .125 and t < .7 then
                set moverFacing = moverFacing and RAbsBJ(GetUnitFacing(actor)-90.) <= 3.
            endif
        elseif scene == 9 then
            if stage == 0 and t >= .375 then
                call RB_LogCheck(RB_GetRemaining() == 0 and RB_GetCommandedScale() == 1.,"new-pair-not-overwritten","old observer returned without clearing/new timer writes")
                set stage = 1
                call Cast(0.)
            elseif stage == 1 and t >= .5 then
                set stage = 2
                call SetUnitOwner(logical,Player(1),false)
            endif
        endif
        set prevX = GetUnitX(actor)
        set prevY = GetUnitY(actor)
        if castAt < 0. and t >= 2. then
            call Abort("native spell effect/pulse deadline2s")
            return
        endif
        if t >= 3.5 then
            call Assess()
        endif
    endfunction

    function RF_StartIntegratedTest takes nothing returns nothing
        call RB_LogBegin()
        set clock = CreateTimer()
        set runner = CreateTimer()
        set probe = Location(0.,0.)
        set surveyGroup = CreateGroup()
        set surveyRect = Rect(0.,0.,0.,0.)
        set shotsHook = CreateTrigger()
        call TriggerAddCondition(shotsHook,Condition(function OnShot))
        call TimerStart(clock,90.,false,function Deadline)
        call CreateScene()
        if not done then
            call TimerStart(runner,.03125,true,function Tick)
        endif
    endfunction
endlibrary
