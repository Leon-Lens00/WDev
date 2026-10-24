library RFBurstCliffTest requires RFBurstLog, RFBurstPair
    // Flight-only observation. No damage/HP oracle, no production callbacks.
    globals
        private constant real PERIOD = .03125
        private constant real STEP = 30.
        private constant real SPEED = 1200.
        private unit actor = null
        private unit caster = null
        private integer actorId = 0
        private integer casterId = 0
        private trigger spellHook = null
        private trigger shotHook = null
        private timer clock = null
        private timer runner = null
        private location probe = null
        private integer scene = 0
        private integer phase = 0
        private boolean done = false
        private boolean admitted = false
        private boolean flatPassed = false
        private string fault = ""
        private real ax = -3136.
        private real ay = 2624.
        private real ox = 0.
        private real oy = 0.
        private real launchZ = 0.
        private real aimX = 0.
        private real aimY = 0.
        private real orderTime = 0.
        private real effectTime = 0.
        private integer effects = 0
        private integer shots = 0
        private integer liveCount = 0
        private integer wallStep = 0
        private real wallLo = 0.
        private real wallHi = 0.
        private real wallAgeLo = 0.
        private real wallAgeHi = 0.
        private boolean corridorOK = true
        private integer trees = 0
        private integer array token
        private integer array dummyToken
        private boolean array closed
        private boolean array seen
        private boolean array pastWall
        private real array birth
        private real array lastTime
        private real array lastX
        private real array lastY
        private real array lastAdvance
        private real array firstAbsent
    endglobals

    private function Bool takes boolean b returns string
        if b then
            return "true"
        endif
        return "false"
    endfunction

    private function Pose takes unit u returns string
        return "id="+I2S(GetHandleId(u))+" type="+I2S(GetUnitTypeId(u))+" xy="+R2S(GetUnitX(u))+","+R2S(GetUnitY(u))+" owner="+I2S(GetPlayerId(GetOwningPlayer(u)))+" alive="+Bool(GetWidgetLife(u) > .405)+" paused="+Bool(IsUnitPaused(u))+" order="+I2S(GetUnitCurrentOrder(u))
    endfunction

    private function Bodies takes nothing returns boolean
        return GetUnitTypeId(actor) == 'o000' and GetUnitTypeId(caster) == 'o001' and GetWidgetLife(actor) > .405 and GetWidgetLife(caster) > .405 and GetOwningPlayer(actor) == Player(0) and GetOwningPlayer(caster) == Player(0) and GetHandleId(actor) == actorId and GetHandleId(caster) == casterId and not IsUnitPaused(actor) and not IsUnitPaused(caster)
    endfunction

    private function At takes unit u, real x, real y returns boolean
        return RAbsBJ(GetUnitX(u)-x) <= 1. and RAbsBJ(GetUnitY(u)-y) <= 1.
    endfunction

    private function Ground takes real x, real y returns real
        call MoveLocation(probe,x,y)
        return GetLocationZ(probe)
    endfunction

    private function InWorld takes real x, real y, real pad returns boolean
        return x-pad > WorldBounds.minX and x+pad < WorldBounds.maxX and y-pad > WorldBounds.minY and y+pad < WorldBounds.maxY
    endfunction

    private function RemoveScene takes nothing returns nothing
        call RB_Dispose()
        if spellHook != null then
            call DestroyTrigger(spellHook)
            call DestroyTrigger(shotHook)
        endif
        call RemoveUnit(actor)
        call RemoveUnit(caster)
        set actor = null
        set caster = null
        set spellHook = null
        set shotHook = null
    endfunction

    private function Finish takes nothing returns nothing
        if done then
            return
        endif
        set done = true
        call PauseTimer(runner)
        call PauseTimer(clock)
        call RemoveScene()
        call DestroyTimer(runner)
        call DestroyTimer(clock)
        call RemoveLocation(probe)
        set runner = null
        set clock = null
        set probe = null
        call RB_LogComplete()
    endfunction

    private function Abort takes string why returns nothing
        call RB_LogRecord("FAIL","ABORT-fixture",why+"; no qualified cliff RED inferred")
        call Finish()
    endfunction

    private function Deadline takes nothing returns nothing
        call Abort("global15 game-second deadline; no retry")
    endfunction

    private function VisitTree takes nothing returns nothing
        local destructable d = GetEnumDestructable()
        set trees = trees+1
        set corridorOK = false
        if trees <= 4 then
            call RB_LogRecord("OBS","unexpected-destructable","handle="+I2S(GetHandleId(d))+" type="+I2S(GetDestructableTypeId(d))+" xy="+R2S(GetDestructableX(d))+","+R2S(GetDestructableY(d))+" life="+R2S(GetDestructableLife(d))+"; no life filter")
        endif
        set d = null
    endfunction

    private function Corridor takes nothing returns boolean
        local group g = CreateGroup()
        local rect area = Rect(ox-160.,oy-160.,ox+1660.,oy+160.)
        local unit u
        local integer n = 0
        set trees = 0
        set corridorOK = true
        call GroupEnumUnitsInRect(g,area,null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g,u)
            set n = n+1
            if n > 256 then
                set corridorOK = false
                exitwhen true
            endif
            if u != actor then
                set corridorOK = false
                call RB_LogRecord("OBS","unexpected-corridor-unit",Pose(u)+"; no old dummy or unknown unit exemption")
            endif
        endloop
        call EnumDestructablesInRect(area,null,function VisitTree)
        call RemoveRect(area)
        call DestroyGroup(g)
        call RB_LogRecord("OBS","full-padded-corridor","units="+I2S(n)+" destructables="+I2S(trees)+" clear="+Bool(corridorOK)+" full1500 plus160")
        set g = null
        set area = null
        set u = null
        return corridorOK
    endfunction

    private function Survey takes nothing returns boolean
        local integer k = 1
        local integer baseLevel = GetTerrainCliffLevel(ox,oy)
        local integer currentLevel = baseLevel
        local integer nextLevel
        local integer cornerLevel = GetTerrainCliffLevel(WorldBounds.maxX,WorldBounds.maxY)
        local real currentGround = Ground(ox,oy)
        local real nextGround
        local real threshold
        local boolean ok = true
        local boolean predicate
        set launchZ = currentGround+80.
        set wallStep = 0
        call RB_LogRecord("OBS","native-launch-survey","actualOrigin="+R2S(ox)+","+R2S(oy)+" groundZ="+R2S(currentGround)+" launchWorldZ="+R2S(launchZ)+" nativeLevel="+I2S(baseLevel)+" nativeNEcornerLevel="+I2S(cornerLevel))
        loop
            exitwhen k > 50
            set nextLevel = GetTerrainCliffLevel(ox+k*STEP,oy)
            set nextGround = Ground(ox+k*STEP,oy)
            set threshold = (nextLevel-cornerLevel)*bj_CLIFFHEIGHT
            set predicate = currentLevel < nextLevel and launchZ < threshold
            call RB_LogRecord("OBS","native-ray-step","step="+I2S(k)+" distance="+R2S(k*STEP)+" levels="+I2S(currentLevel)+"->"+I2S(nextLevel)+" groundZ="+R2S(currentGround)+"->"+R2S(nextGround)+" launchZ="+R2S(launchZ)+" libraryThreshold="+R2S(threshold)+" libraryPredicate="+Bool(predicate))
            if scene == 0 then
                if nextLevel != baseLevel or nextGround >= launchZ or IsTerrainPathable(ox+k*STEP,oy,PATHING_TYPE_WALKABILITY) then
                    set ok = false
                endif
            else
                // Independent physical criterion; libraryPredicate is OBS only.
                if wallStep == 0 then
                    if nextGround >= launchZ then
                        if nextLevel <= currentLevel or currentGround >= launchZ or k*STEP > 600. then
                            set ok = false
                        endif
                        set wallStep = k
                        set wallLo = (k-1)*STEP
                        set wallHi = k*STEP
                    elseif nextLevel != baseLevel then
                        // Earlier level transition/ramp/hill is not this fixture.
                        set ok = false
                    endif
                endif
                if nextLevel < currentLevel or nextLevel > baseLevel+1 then
                    set ok = false
                endif
            endif
            set currentLevel = nextLevel
            set currentGround = nextGround
            set k = k+1
        endloop
        if scene == 1 then
            // OnCliff precedes OnOrient; predicted next is 30 ahead even on
            // first tick (speed setter calls predict). Scheduler phase <=.025.
            // Observer may lag .03125; last seen may trail 37.5+30 units.
            set wallAgeLo = RMaxBJ(0.,wallLo/SPEED-.025)
            set wallAgeHi = wallHi/SPEED+.025+PERIOD
            set ok = ok and wallStep > 0 and wallAgeHi < 1.225
            call RB_LogRecord("OBS","physical-wall-bracket","step="+I2S(wallStep)+" distance=["+R2S(wallLo)+","+R2S(wallHi)+"] absenceAge=["+R2S(wallAgeLo)+","+R2S(wallAgeHi)+"] lastLiveAdvance=["+R2S(RMaxBJ(0.,wallLo-67.5))+","+R2S(wallHi)+"]; physical admission independent of optional callback predicate")
        endif
        return ok
    endfunction

    private function Ready takes nothing returns boolean
        call RB_LogRecord("OBS","pair-readiness",Pose(actor)+" controller "+Pose(caster))
        if not Bodies() or not At(actor,ax,ay) or not At(caster,-5500.,-5500.) then
            return false
        endif
        if GetUnitAbilityLevel(caster,'A00G') != 1 or GetUnitAbilityLevel(caster,'Ablo') != 0 or GetUnitAbilityLevel(actor,'A00G') != 0 or GetUnitAbilityLevel(actor,'Ablo') != 0 then
            return false
        endif
        if GetUnitCurrentOrder(actor) != 0 or GetUnitCurrentOrder(caster) != 0 or RAbsBJ(GetUnitFacing(actor)) > .01 then
            return false
        endif
        set ox = GetUnitX(actor)
        set oy = GetUnitY(actor)
        if not InWorld(ox,oy,160.) or not InWorld(ox+1500.,oy,160.) or not InWorld(-5500.,-5500.,32.) then
            return false
        endif
        if IsTerrainPathable(ox,oy,PATHING_TYPE_WALKABILITY) then
            return false
        endif
        return Corridor() and Survey()
    endfunction

    private function Scan takes integer incoming returns nothing
        local integer i = 0
        local integer j = 1
        local integer match
        local Missiles m
        local real now = TimerGetElapsed(clock)
        set liveCount = 0
        if Missiles.count >= 32 then
            set fault = "public collection overflow32"
            return
        endif
        loop
            exitwhen j > shots or j > 4
            set seen[j] = false
            set j = j+1
        endloop
        loop
            exitwhen i > Missiles.count
            // Tokens are comparisons only; dereference this fresh entry only.
            set m = Missiles.collection[i]
            if m.allocated and m.source == actor then
                set liveCount = liveCount+1
                set match = 0
                set j = 1
                loop
                    exitwhen j > shots or j > 4
                    if not closed[j] and token[j] == m then
                        set match = j
                    endif
                    set j = j+1
                endloop
                if m != incoming then
                    if match == 0 then
                        set fault = "unmapped source flight / unobserved allocator reuse"
                    else
                        set seen[match] = true
                        set lastTime[match] = now
                        set lastX[match] = m.x
                        set lastY[match] = m.y
                        set lastAdvance[match] = m.x-ox
                        if RAbsBJ(m.y-oy) > 2. or RAbsBJ(m.z-launchZ) > .01 or m.owner != Player(0) then
                            set fault = "live flight worldZ/heading/logical owner changed"
                        endif
                        if scene == 1 and not pastWall[match] and m.x-ox > wallHi+STEP then
                            set pastWall[match] = true
                            call RB_LogRecord("OBS","actual-past-physical-wall-travel","serial="+I2S(match)+" age="+R2S(now-birth[match])+" xy="+R2S(m.x)+","+R2S(m.y)+" worldZ="+R2S(m.z)+" advance="+R2S(m.x-ox)+" wallHi="+R2S(wallHi))
                        endif
                    endif
                endif
            endif
            set i = i+1
        endloop
        set j = 1
        loop
            exitwhen j > shots or j > 4
            if not closed[j] and not seen[j] then
                set closed[j] = true
                set firstAbsent[j] = now
                call RB_LogRecord("OBS","flight-closure","serial="+I2S(j)+" birth="+R2S(birth[j])+" lastLive="+R2S(lastTime[j])+" xy="+R2S(lastX[j])+","+R2S(lastY[j])+" advance="+R2S(lastAdvance[j])+" firstAbsent="+R2S(now)+" age="+R2S(now-birth[j]))
            endif
            set j = j+1
        endloop
    endfunction

    private function OnShot takes nothing returns boolean
        local Missiles m = RB_GetShotMissile()
        local integer j = 1
        local boolean valid
        loop
            exitwhen j > shots or j > 4
            if not closed[j] and token[j] == m then
                set fault = "ID reused before observed closure"
                return false
            endif
            set j = j+1
        endloop
        call Scan(m)
        set shots = shots+1
        if shots > 4 or m == 0 then
            set fault = "unexpected public birth count/null missile"
            return false
        endif
        set valid = phase == 2 and m.allocated and m.launched and m.dummy != null
        set valid = valid and m.source == actor and RB_GetShotSource() == actor and m.owner == Player(0)
        set valid = valid and GetUnitTypeId(m.dummy) == 'e000' and m.dummy != actor and m.dummy != caster
        set valid = valid and RAbsBJ(m.x-GetUnitX(actor)) <= 1. and RAbsBJ(m.y-GetUnitY(actor)) <= 1. and RAbsBJ(m.z-launchZ) <= .01
        set valid = valid and RAbsBJ(RB_GetShotX()-m.x) <= .01 and RAbsBJ(RB_GetShotY()-m.y) <= .01
        set valid = valid and RAbsBJ(m.nextX-m.x-STEP) <= .01 and RAbsBJ(m.nextY-m.y) <= .01 and RAbsBJ(m.nextZ-launchZ) <= .01
        set j = 1
        loop
            exitwhen j >= shots
            if dummyToken[j] == GetHandleId(m.dummy) then
                set valid = false
            endif
            set j = j+1
        endloop
        if not valid then
            set fault = "birth allocation/source/dummy/origin/heading/worldZ contract"
            return false
        endif
        // No native Player0 dummy-owner requirement before first processing.
        set dummyToken[shots] = GetHandleId(m.dummy)
        set token[shots] = m
        set closed[shots] = false
        set pastWall[shots] = false
        set birth[shots] = TimerGetElapsed(clock)
        set lastTime[shots] = birth[shots]
        set lastX[shots] = m.x
        set lastY[shots] = m.y
        set lastAdvance[shots] = 0.
        call RB_LogRecord("OBS","real-public-launch","serial="+I2S(shots)+" time="+R2S(birth[shots])+" token="+I2S(m)+" dummy="+I2S(dummyToken[shots])+" nativeOwner="+I2S(GetPlayerId(GetOwningPlayer(m.dummy)))+" source="+I2S(GetHandleId(m.source))+" xyz="+R2S(m.x)+","+R2S(m.y)+","+R2S(m.z))
        return false
    endfunction

    private function OnSpell takes nothing returns boolean
        set effects = effects+1
        call RB_LogRecord("OBS","native-effect","count="+I2S(effects)+" ability="+I2S(GetSpellAbilityId())+" source="+I2S(GetHandleId(GetTriggerUnit()))+" point="+R2S(GetSpellTargetX())+","+R2S(GetSpellTargetY()))
        if phase != 1 or effects != 1 or GetTriggerUnit() != caster or GetSpellAbilityId() != 'A00G' or RAbsBJ(GetSpellTargetX()-aimX) > .01 or RAbsBJ(GetSpellTargetY()-aimY) > .01 then
            set fault = "unexpected native effect"
            return false
        endif
        set effectTime = TimerGetElapsed(clock)
        set phase = 2
        return false
    endfunction

    private function Assess takes nothing returns boolean
        local integer j = 1
        local boolean cadence = shots == 4
        local boolean closure = shots == 4 and liveCount == 0
        local boolean travel = shots == 4
        local boolean redTravel = shots == 4
        local real age
        loop
            exitwhen j > shots or j > 4
            set age = firstAbsent[j]-birth[j]
            set closure = closure and closed[j]
            if j > 1 then
                set cadence = cadence and RAbsBJ(birth[j]-birth[j-1]-.25) <= PERIOD
            endif
            if scene == 0 then
                set travel = travel and lastAdvance[j] >= 1410. and lastAdvance[j] <= 1500. and age >= 1.225 and age <= 1.30625
            else
                set travel = travel and lastAdvance[j] >= RMaxBJ(0.,wallLo-67.5) and lastAdvance[j] <= wallHi and age >= wallAgeLo and age <= wallAgeHi
                set redTravel = redTravel and pastWall[j] and lastAdvance[j] >= 1410. and age >= 1.225 and age <= 1.30625
            endif
            set travel = travel and RAbsBJ(lastY[j]-oy) <= 2.
            set j = j+1
        endloop
        call RB_LogCheck(admitted and effects == 1,"native-admission-and-effect","physical survey and strict pair/corridor passed before actual order/effect")
        call RB_LogCheck(shots == 4,"four-real-launches","actual="+I2S(shots)+" source/origin/heading/worldZ checked at birth and live samples")
        call RB_LogCheck(cadence,"quarter-second-cadence","three intervals tolerance .03125")
        call RB_LogCheck(closure,"four-observed-closures","fresh public scan; no disposal before observation")
        if scene == 0 then
            call RB_LogCheck(travel,"flat-full-range-positive","last advance1410..1500; absence age1.225..1.30625")
        else
            call RB_LogRecord("OBS","qualified-RED-travel-evidence","allFourActuallyPastWallThenFarRange="+Bool(redTravel)+"; false does not prove wall termination; inspect every bracket")
            call RB_LogCheck(travel,"upward-physical-wall-termination","native wall-derived tight early XY/time bracket; late far-range finish is behavior FAIL, not fixture ABORT")
        endif
        return admitted and effects == 1 and shots == 4 and cadence and closure and travel
    endfunction

    private function CreateScene takes nothing returns nothing
        set shots = 0
        set effects = 0
        set admitted = false
        set fault = ""
        set phase = 0
        set actor = CreateUnit(Player(0),'o000',ax,ay,0.)
        set caster = CreateUnit(Player(0),'o001',-5500.,-5500.,0.)
        set actorId = GetHandleId(actor)
        set casterId = GetHandleId(caster)
        set spellHook = CreateTrigger()
        call TriggerRegisterUnitEvent(spellHook,caster,EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(spellHook,Condition(function OnSpell))
        set shotHook = CreateTrigger()
        call TriggerAddCondition(shotHook,Condition(function OnShot))
        // Native observer registration precedes application's synchronous hook.
        if not RB_InitializePair(actor,caster,shotHook) then
            set fault = "fresh pair initialization rejected"
        endif
    endfunction

    private function Tick takes nothing returns nothing
        local boolean accepted
        local integer j = 1
        call Scan(0)
        if fault != "" then
            call Abort(fault)
            return
        endif
        if not Bodies() or not At(actor,ax,ay) or not At(caster,-5500.,-5500.) then
            call Abort("actual pair identity/ownership/life/pause/placement changed")
            return
        endif
        if phase == 0 then
            if liveCount != 0 or not Ready() then
                call Abort("native placement/world/corridor/terrain survey unavailable; native values above, static summary not admission")
                return
            endif
            set admitted = true
            set aimX = ox+1500.
            set aimY = oy
            set orderTime = TimerGetElapsed(clock)
            set phase = 1
            set accepted = IssuePointOrder(caster,"channel",aimX,aimY)
            call RB_LogCheck(accepted,"native-point-order-accepted","state and point set before order; no retry")
            if not accepted then
                call Abort("point order rejected")
            endif
        elseif phase == 1 then
            if TimerGetElapsed(clock)-orderTime >= 2. then
                call Abort("effect deadline2s")
            endif
        elseif phase == 2 and TimerGetElapsed(clock)-effectTime >= 2.5 then
            if scene == 0 then
                set flatPassed = Assess()
                if not flatPassed then
                    // Already assessed FAIL; no wall admission without positive.
                    call Finish()
                    return
                endif
                set phase = 3
            else
                set accepted = Assess()
                call Finish()
            endif
        elseif phase == 3 then
            // Fresh Scan above retained original actor/tokens/counters. Closure
            // proof precedes dispose, old unit removal and fresh scene creation.
            if not flatPassed or shots != 4 or liveCount != 0 then
                call Abort("previous flights not freshly closed")
                return
            endif
            loop
                exitwhen j > 4
                if not closed[j] then
                    call Abort("missing prior serial closure")
                    return
                endif
                set j = j+1
            endloop
            call RB_LogRecord("OBS","prior-four-closed-before-cleanup","fresh source0; all four absence brackets retained before pair disposal")
            call RemoveScene()
            set scene = 1
            set ax = -3952.
            set ay = 5136.
            call RB_LogCase("R09-upward-physical-cliff-termination")
            call CreateScene()
        endif
    endfunction

    function RF_StartCliffTest takes nothing returns nothing
        call RB_LogBegin()
        call RB_LogCase("R08-flat-range-positive")
        set probe = Location(0.,0.)
        set clock = CreateTimer()
        set runner = CreateTimer()
        call TimerStart(clock,15.,false,function Deadline)
        call CreateScene()
        call TimerStart(runner,PERIOD,true,function Tick)
    endfunction
endlibrary
