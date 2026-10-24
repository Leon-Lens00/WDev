library RFBurstAimTest requires RFBurstLog, RFBurstPair
    globals
        private constant real PERIOD = .03125
        private constant real CADENCE_TOLERANCE = .03125
        private constant real HP_TOLERANCE = .10
        private unit actor = null
        private unit caster = null
        private unit target = null
        private unit control = null
        private timer clock = null
        private timer runner = null
        private trigger damageHook = null
        private trigger spellHook = null
        private trigger shotHook = null
        private integer phase = 0
        private boolean done = false
        private boolean calibrated = false
        private integer calibrationHits = 0
        private real calibrationHP = 0.
        private real calibrationDamage = 0.
        private boolean calibrationSource = false
        private integer controlHits = 0
        private integer hits = 0
        private boolean hitValuesOK = true
        private boolean hitSourcesOK = true
        private integer shots = 0
        private boolean projectilesOK = true
        private real array shotTime
        private integer castEvents = 0
        private real orderTime = 0.
        private real castTime = 0.
        private real aimX = 0.
        private real aimY = 0.
        private real targetStart = 0.
        private real controlStart = 0.
        private boolean recastCase = false
        private integer expectedCast = 0
        private boolean pendingRecast = false
        private boolean recastRequested = false
        private boolean recastQualified = false
        private boolean earlyPulse = false
        private real recastDue = 0.
        private real recastIssue = 0.
        private real recastEffect = 0.
        private integer recastEffectShots = 0
        private boolean aimCase = false
        private unit northTarget = null
        private unit northControl = null
        private location groundProbe = null
        private group corridorUnits = null
        private rect corridorRect = null
        private boolean corridorClear = true
        private integer destSeen = 0
        private real northStart = 0.
        private real northControlStart = 0.
        private integer eastHits = 0
        private integer northHits = 0
        private integer northCalibrationHits = 0
        private real northCalibrationHP = 0.
        private real northCalibrationDamage = 0.
        private boolean northCalibrationSource = false
        private boolean northCalibrationAccepted = false
        private Missiles firstFlight = 0
        private unit firstDummy = null
        private unit firstSource = null
        private real firstOriginX = 0.
        private real firstOriginY = 0.
        private real firstInitialX = 0.
        private real firstInitialY = 0.
        private real eastDX = 0.
        private real eastDY = 0.
        private boolean postSample = false
        private real sampleTime = 0.
        private real sampleAdvance = 0.
        private real sampleCross = 0.
        private boolean firstEastBeforeSecond = false
        private real firstEastTime = 0.
        private integer firstEastShots = 0
        private boolean northBeforeSecond = false
    endglobals

    private function Pose takes unit u returns string
        return "type="+I2S(GetUnitTypeId(u))+" xy="+R2S(GetUnitX(u))+","+R2S(GetUnitY(u))+" facing="+R2S(GetUnitFacing(u))+" order="+I2S(GetUnitCurrentOrder(u))+" hp="+R2S(GetWidgetLife(u))
    endfunction

    private function ClearScene takes nothing returns nothing
        call RB_Dispose()
        if spellHook != null then
            call DestroyTrigger(spellHook)
            call DestroyTrigger(damageHook)
            call DestroyTrigger(shotHook)
        endif
        set spellHook = null
        set damageHook = null
        set shotHook = null
        if GetUnitTypeId(actor) != 0 then
            call RemoveUnit(actor)
        endif
        if GetUnitTypeId(caster) != 0 then
            call RemoveUnit(caster)
        endif
        if GetUnitTypeId(target) != 0 then
            call RemoveUnit(target)
        endif
        if GetUnitTypeId(control) != 0 then
            call RemoveUnit(control)
        endif
        if GetUnitTypeId(northTarget) != 0 then
            call RemoveUnit(northTarget)
        endif
        if GetUnitTypeId(northControl) != 0 then
            call RemoveUnit(northControl)
        endif
        // Keep removed unit references until next-tick native clearance checks.
    endfunction

    private function ReleaseSceneRefs takes nothing returns nothing
        set actor = null
        set caster = null
        set target = null
        set control = null
        set northTarget = null
        set northControl = null
        set firstFlight = 0
        set firstDummy = null
        set firstSource = null
    endfunction

    private function Finish takes nothing returns nothing
        if done then
            return
        endif
        set done = true
        call PauseTimer(runner)
        call PauseTimer(clock)
        call ClearScene()
        call ReleaseSceneRefs()
        call RemoveLocation(groundProbe)
        call DestroyGroup(corridorUnits)
        call RemoveRect(corridorRect)
        set groundProbe = null
        set corridorUnits = null
        set corridorRect = null
        call DestroyTimer(runner)
        call DestroyTimer(clock)
        set runner = null
        set clock = null
        call RB_LogComplete()
    endfunction

    private function Abort takes string why returns nothing
        call RB_LogRecord("FAIL","ABORT-fixture",why)
        call Finish()
    endfunction

    private function Deadline takes nothing returns nothing
        call Abort("global 25 game-second deadline; remaining assertions unreached")
    endfunction

    private function FirstLive takes nothing returns boolean
        return firstFlight != 0 and firstFlight.allocated and firstFlight.launched and firstFlight.dummy == firstDummy and GetUnitTypeId(firstDummy) != 0 and firstFlight.source == firstSource and firstSource == actor
    endfunction

    private function AimDamage takes real amount returns boolean
        local real now = TimerGetElapsed(clock)
        local unit victim = GetTriggerUnit()
        if victim == control or victim == northControl then
            set controlHits = controlHits+1
        elseif phase == 1 and victim == target then
            set calibrationHits = calibrationHits+1
            set calibrationDamage = amount
            set calibrationSource = GetEventDamageSource() == actor
        elseif phase == 2 and victim == northTarget then
            set northCalibrationHits = northCalibrationHits+1
            set northCalibrationDamage = amount
            set northCalibrationSource = GetEventDamageSource() == actor
        elseif phase >= 4 and (victim == target or victim == northTarget) then
            set hits = hits+1
            set hitValuesOK = hitValuesOK and RAbsBJ(amount-10.) <= .01
            set hitSourcesOK = hitSourcesOK and GetEventDamageSource() == actor
            if victim == target then
                set eastHits = eastHits+1
                if eastHits == 1 then
                    set firstEastTime = now
                    set firstEastShots = shots
                    set firstEastBeforeSecond = shots == 1 and northHits == 0 and now < shotTime[1]+.25 and RAbsBJ(amount-10.) <= .01 and GetEventDamageSource() == actor
                endif
            else
                set northHits = northHits+1
                if shots == 1 then
                    set northBeforeSecond = true
                endif
            endif
            if hits <= 8 then
                call RB_LogRecord("OBS","aim-native-damage","time="+R2S(now)+" victim="+I2S(GetHandleId(victim))+" east="+I2S(eastHits)+" north="+I2S(northHits)+" value="+R2S(amount)+" source="+I2S(GetHandleId(GetEventDamageSource()))+" actor="+I2S(GetHandleId(actor))+" shots="+I2S(shots))
            endif
        endif
        set victim = null
        return false
    endfunction

    private function AimShot takes nothing returns boolean
        local Missiles m = RB_GetShotMissile()
        local boolean valid = false
        local real distance
        set shots = shots+1
        if m != 0 then
            set valid = m.allocated and m.launched and m.dummy != null
            set valid = valid and GetUnitTypeId(m.dummy) != 0 and m.dummy != actor and m.dummy != caster
            set valid = valid and m.source == actor and RB_GetShotSource() == actor
            set valid = valid and RAbsBJ(m.x-GetUnitX(actor)) <= 1. and RAbsBJ(m.y-GetUnitY(actor)) <= 1.
            set valid = valid and RAbsBJ(RB_GetShotX()-m.x) <= .01 and RAbsBJ(RB_GetShotY()-m.y) <= .01
        endif
        set projectilesOK = projectilesOK and valid and phase == 5
        if shots <= 8 then
            set shotTime[shots] = TimerGetElapsed(clock)
            call RB_LogRecord("OBS","aim-public-SHOT","index="+I2S(shots)+" time="+R2S(shotTime[shots])+" missile="+I2S(m)+" source="+I2S(GetHandleId(RB_GetShotSource())))
        endif
        if shots == 1 then
            if not projectilesOK then
                set phase = -1
            else
                // Borrowed ID is examined ONLY while there is still one shot
                // and no impact. No private generation/angle getter is assumed.
                set firstFlight = m
                set firstDummy = m.dummy
                set firstSource = m.source
                set firstOriginX = RB_GetShotX()
                set firstOriginY = RB_GetShotY()
                set firstInitialX = m.x
                set firstInitialY = m.y
                set eastDX = GetUnitX(target)-firstOriginX
                set eastDY = GetUnitY(target)-firstOriginY
                set distance = SquareRoot(eastDX*eastDX+eastDY*eastDY)
                set eastDX = eastDX/distance
                set eastDY = eastDY/distance
                set recastDue = shotTime[1]+.0625
                set pendingRecast = true
                call RB_LogRecord("OBS","first-flight-borrowed","origin="+R2S(firstOriginX)+","+R2S(firstOriginY)+" initial="+R2S(firstInitialX)+","+R2S(firstInitialY)+" dummy="+I2S(GetHandleId(firstDummy))+" source="+I2S(GetHandleId(firstSource)))
            endif
        elseif recastRequested and TimerGetElapsed(clock) < shotTime[1]+.25-.0001 then
            set earlyPulse = true
        endif
        return false
    endfunction

    private function AimSpell takes nothing returns boolean
        local real now = TimerGetElapsed(clock)
        set castEvents = castEvents+1
        call RB_LogRecord("OBS","aim-native-effect","event="+I2S(castEvents)+" time="+R2S(now)+" shots="+I2S(shots)+" ability="+I2S(GetSpellAbilityId())+" source="+I2S(GetHandleId(GetTriggerUnit()))+" xy="+R2S(GetSpellTargetX())+","+R2S(GetSpellTargetY()))
        if GetTriggerUnit() != caster or GetSpellAbilityId() != 'A00G' or RAbsBJ(GetSpellTargetX()-aimX) > .01 or RAbsBJ(GetSpellTargetY()-aimY) > .01 then
            set phase = -1
        elseif phase == 4 and expectedCast == 1 and castEvents == 1 then
            set expectedCast = 0
            set castTime = now
            set targetStart = GetWidgetLife(target)
            set controlStart = GetWidgetLife(control)
            set northStart = GetWidgetLife(northTarget)
            set northControlStart = GetWidgetLife(northControl)
            set phase = 5
            call RB_LogRecord("OBS","aim-first-effect-latency","issue="+R2S(orderTime)+" effect="+R2S(now)+" latency="+R2S(now-orderTime))
        elseif phase == 5 and expectedCast == 2 and castEvents == 2 then
            set expectedCast = 0
            set recastEffect = now
            set recastEffectShots = shots
            if shots != 1 or hits != 0 or now < recastIssue or now >= shotTime[1]+.25 or not FirstLive() then
                set phase = -1
            else
                set recastQualified = true
                call RB_LogRecord("OBS","aim-second-effect-qualified","first="+R2S(shotTime[1])+" due="+R2S(recastDue)+" issue="+R2S(recastIssue)+" effect="+R2S(now)+" latency="+R2S(now-recastIssue)+" oldFlightXY="+R2S(firstFlight.x)+","+R2S(firstFlight.y)+" shots=1 hits=0")
            endif
        else
            set phase = -1
        endif
        return false
    endfunction

    private function OnDamage takes nothing returns boolean
        local real amount = GetEventDamage()
        if aimCase then
            return AimDamage(amount)
        endif
        if GetTriggerUnit() == control then
            set controlHits = controlHits+1
        elseif GetTriggerUnit() == target then
            if phase == 1 then
                set calibrationHits = calibrationHits+1
                set calibrationDamage = amount
                set calibrationSource = GetEventDamageSource() == actor
            elseif phase >= 4 then
                set hits = hits+1
                set hitValuesOK = hitValuesOK and RAbsBJ(amount-10.) <= .01
                set hitSourcesOK = hitSourcesOK and GetEventDamageSource() == actor
                if hits <= 8 then
                    call RB_LogRecord("OBS","native-damage","time="+R2S(TimerGetElapsed(clock))+" value="+R2S(amount)+" source="+I2S(GetHandleId(GetEventDamageSource()))+" visible="+I2S(GetHandleId(actor)))
                endif
            endif
        endif
        return false
    endfunction

    private function OnShot takes nothing returns boolean
        local Missiles m = RB_GetShotMissile()
        local boolean valid = false
        if aimCase then
            return AimShot()
        endif
        set shots = shots+1
        // Public diagnostic pulse alone is NOT evidence of a real projectile.
        if m != 0 then
            set valid = m.allocated and m.launched and m.dummy != null
            set valid = valid and GetUnitTypeId(m.dummy) != 0 and m.dummy != actor and m.dummy != caster
            set valid = valid and m.source == actor and RB_GetShotSource() == actor
            set valid = valid and RAbsBJ(m.x-GetUnitX(actor)) <= 1. and RAbsBJ(m.y-GetUnitY(actor)) <= 1.
            set valid = valid and RAbsBJ(RB_GetShotX()-m.x) <= .01 and RAbsBJ(RB_GetShotY()-m.y) <= .01
        endif
        set projectilesOK = projectilesOK and valid and phase == 5
        if shots <= 8 then
            set shotTime[shots] = TimerGetElapsed(clock)
            call RB_LogRecord("OBS","SHOT-public-pulse","index="+I2S(shots)+" time="+R2S(shotTime[shots])+" missile="+I2S(m)+" source="+I2S(GetHandleId(RB_GetShotSource())))
        endif
        if recastCase and shots == 2 then
            if not projectilesOK then
                set phase = -1
            else
                set recastDue = shotTime[2]+.125
                set pendingRecast = true
            endif
        endif
        if recastCase and recastRequested and shots > 2 and TimerGetElapsed(clock) < shotTime[2]+.25-.0001 then
            set earlyPulse = true
        endif
        return false
    endfunction

    private function OnSpell takes nothing returns boolean
        local real now = TimerGetElapsed(clock)
        if aimCase then
            return AimSpell()
        endif
        set castEvents = castEvents+1
        call RB_LogRecord("OBS","native-spell-effect","event="+I2S(castEvents)+" time="+R2S(now)+" shots="+I2S(shots)+" ability="+I2S(GetSpellAbilityId())+" source="+I2S(GetHandleId(GetTriggerUnit()))+" xy="+R2S(GetSpellTargetX())+","+R2S(GetSpellTargetY()))
        if GetTriggerUnit() != caster or GetSpellAbilityId() != 'A00G' or RAbsBJ(GetSpellTargetX()-aimX) > .01 or RAbsBJ(GetSpellTargetY()-aimY) > .01 then
            set phase = -1
        elseif expectedCast == 1 and castEvents == 1 and phase == 4 then
            set expectedCast = 0
            set castTime = now
            set targetStart = GetWidgetLife(target)
            set controlStart = GetWidgetLife(control)
            set phase = 5
            call RB_LogRecord("OBS","first-native-effect-latency","issue="+R2S(orderTime)+" effect="+R2S(now)+" latency="+R2S(now-orderTime))
        elseif recastCase and expectedCast == 2 and castEvents == 2 and phase == 5 then
            set expectedCast = 0
            set recastEffect = now
            set recastEffectShots = shots
            call RB_LogRecord("OBS","second-native-effect-latency","secondShot="+R2S(shotTime[2])+" due="+R2S(recastDue)+" issue="+R2S(recastIssue)+" effect="+R2S(now)+" latency="+R2S(now-recastIssue)+" shots="+I2S(shots))
            if shots != 2 or now >= shotTime[2]+.25 or now < recastIssue then
                set phase = -1
            else
                set recastQualified = true
            endif
        else
            // Cleanup is deferred outside native callback/shot dispatch.
            set phase = -1
        endif
        return false
    endfunction

    private function At takes unit u, real x, real y returns boolean
        return GetUnitTypeId(u) != 0 and RAbsBJ(GetUnitX(u)-x) <= 1. and RAbsBJ(GetUnitY(u)-y) <= 1.
    endfunction

    private function BodyReady takes unit u returns boolean
        return GetUnitTypeId(u) == 'o000' and GetWidgetLife(u) > 100. and GetUnitAbilityLevel(u,'A00G') == 0 and GetUnitAbilityLevel(u,'Ablo') == 0
    endfunction

    private function SceneReady takes nothing returns boolean
        local integer i = 0
        local real x
        // Placement gates ONLY. Spawn success is not walkability/transit proof.
        if not At(actor,-2223.5,4352.) or not At(caster,-5500.,-5500.) or not At(target,-1967.5,4352.) or not At(control,-1967.5,4864.) then
            return false
        endif
        if not BodyReady(actor) or not BodyReady(target) or not BodyReady(control) or GetUnitTypeId(caster) != 'o001' then
            return false
        endif
        if GetUnitAbilityLevel(caster,'A00G') != 1 or GetUnitAbilityLevel(caster,'Ablo') != 0 or IsUnitPaused(actor) or IsUnitPaused(caster) then
            return false
        endif
        if not IsUnitEnemy(target,Player(0)) or not IsUnitEnemy(control,Player(0)) or not IsUnitEnemy(actor,Player(1)) then
            return false
        endif
        if GetOwningPlayer(target) != Player(1) or GetOwningPlayer(control) != Player(1) or not IsUnitPaused(target) or not IsUnitPaused(control) then
            return false
        endif
        if RAbsBJ(GetUnitFacing(actor)) > .01 or GetUnitCurrentOrder(actor) != 0 or GetWidgetLife(caster) <= 0.405 then
            return false
        endif
        loop
            exitwhen i > 8
            set x = GetUnitX(actor)+(GetUnitX(target)-GetUnitX(actor))*I2R(i)/8.
            if IsTerrainPathable(x,GetUnitY(actor),PATHING_TYPE_WALKABILITY) then
                return false
            endif
            set i = i+1
        endloop
        return not IsTerrainPathable(GetUnitX(control),GetUnitY(control),PATHING_TYPE_WALKABILITY)
    endfunction

    private function HasFlights takes unit sourceUnit returns boolean
        local integer i = 0
        local Missiles m
        if Missiles.count >= 32 then
            return true
        endif
        loop
            exitwhen i > Missiles.count
            set m = Missiles.collection[i]
            if m.allocated and m.source == sourceUnit then
                return true
            endif
            set i = i+1
        endloop
        return false
    endfunction

    private function RemovedAbsent takes nothing returns boolean
        local group g = CreateGroup()
        local unit u
        local integer fixtureIndex = 0
        local integer seen = 0
        local boolean ok = GetUnitTypeId(actor) == 0 and GetUnitTypeId(caster) == 0 and GetUnitTypeId(target) == 0 and GetUnitTypeId(control) == 0
        loop
            exitwhen fixtureIndex == 2 or not ok
            if fixtureIndex == 0 then
                call GroupEnumUnitsInRange(g,-2223.5,4352.,1024.,null)
            else
                call GroupEnumUnitsInRange(g,-5500.,-5500.,128.,null)
            endif
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null or not ok
                set seen = seen+1
                set ok = seen <= 128 and u != actor and u != caster and u != target and u != control
                call GroupRemoveUnit(g,u)
            endloop
            set fixtureIndex = fixtureIndex+1
        endloop
        call DestroyGroup(g)
        set g = null
        set u = null
        return ok
    endfunction

    private function CompleteRegression takes nothing returns nothing
        call RB_LogCase("R03-active-recast-reset-and-cadence")
        if HasFlights(actor) then
            call Abort("prior actor still has public allocated flights after3s; no fresh-case admission")
            return
        endif
        call RB_LogCheck(true,"prior-flights-clear","public core collection has no allocated flight from prior actor")
        call ClearScene()
        set phase = 6
    endfunction

    private function Assess takes nothing returns nothing
        local real targetEnd = GetWidgetLife(target)
        local real controlEnd = GetWidgetLife(control)
        local real differential = (controlEnd-controlStart)-(targetEnd-targetStart)
        local integer i = 2
        call RB_LogRecord("OBS","actor-end",Pose(actor))
        call RB_LogRecord("OBS","target-control-HP","target="+R2S(targetStart)+"->"+R2S(targetEnd)+" control="+R2S(controlStart)+"->"+R2S(controlEnd)+" differential="+R2S(differential))
        call RB_LogCheck(shots == 4,"four-shot-notifications","actual="+I2S(shots)+" expected=4")
        call RB_LogCheck(shots == 4 and projectilesOK,"four-real-public-projectiles","live launched Missiles, separate native dummy, visible source and actual actor origin required at each pulse")
        call RB_LogCheck(hits == 4,"four-native-hits","actual="+I2S(hits)+" expected=4")
        call RB_LogCheck(hits == 4 and hitValuesOK,"native-ten-per-hit","each GetEventDamage must be10 tolerance=.01; no calibration events counted")
        call RB_LogCheck(hits == 4 and hitSourcesOK,"visible-damage-source","each GetEventDamageSource must equal visible actor, not logical caster")
        call RB_LogCheck(RAbsBJ(differential-40.) <= HP_TOLERANCE,"native-HP-differential40","actual="+R2S(differential)+" tolerance=.10; same-type paired regen control")
        call RB_LogCheck(controlHits == 0,"control-undamaged","actual="+I2S(controlHits))
        call RB_LogCheck(targetEnd > .405 and controlEnd > .405,"targets-survive","target="+R2S(targetEnd)+" control="+R2S(controlEnd))
        call RB_LogCase("B02-default-cadence")
        if shots != 4 then
            call RB_LogRecord("FAIL","missing-cadence-observations","need4 actual shot pulses/3 adjacent intervals; actual="+I2S(shots))
        else
            loop
                exitwhen i > 4
                call RB_LogCheck(RAbsBJ((shotTime[i]-shotTime[i-1])-.25) <= CADENCE_TOLERANCE,"cadence-interval"+I2S(i-1),"actual="+R2S(shotTime[i]-shotTime[i-1])+" expected=.25 tolerance=.03125")
                set i = i+1
            endloop
        endif
        call CompleteRegression()
    endfunction

    private function BeginAim takes nothing returns nothing
        call RB_LogCase("R04-new-aim-future-shots")
        if HasFlights(actor) then
            call Abort("prior R03 actor has allocated flights after observation; aim scene unavailable")
            return
        endif
        call RB_LogCheck(true,"prior-R03-flights-clear","public core source-flight absence before disposal")
        call ClearScene()
        set phase = 7
    endfunction

    private function AssessRecast takes nothing returns nothing
        local real targetEnd = GetWidgetLife(target)
        local real controlEnd = GetWidgetLife(control)
        local real differential = (controlEnd-controlStart)-(targetEnd-targetStart)
        local integer i = 2
        call RB_LogRecord("OBS","actor-end",Pose(actor))
        call RB_LogRecord("OBS","recast-target-control-HP","shots="+I2S(shots)+" hits="+I2S(hits)+" target="+R2S(targetStart)+"->"+R2S(targetEnd)+" control="+R2S(controlStart)+"->"+R2S(controlEnd)+" differential="+R2S(differential))
        call RB_LogCheck(recastQualified and castEvents == 2 and recastEffectShots == 2,"native-active-window-ready","exact second source/A00G/point effect at observed shot2 and before shot2+.25")
        call RB_LogCheck(shots == 6,"reset-to-four-not-add-or-ignore","actual="+I2S(shots)+" expected=6; ignore gives4/add gives8")
        call RB_LogCheck(shots == 6 and projectilesOK,"six-real-public-projectiles","live launched core missiles/separate dummy/source/current actor origin required")
        call RB_LogCheck(hits == 6,"six-native-hits","actual="+I2S(hits)+" expected=6")
        call RB_LogCheck(hits == 6 and hitValuesOK,"native-ten-per-hit","six real target UNIT_DAMAGED values10 tolerance=.01")
        call RB_LogCheck(hits == 6 and hitSourcesOK,"visible-damage-source","all6 GetEventDamageSource equal visible actor")
        call RB_LogCheck(RAbsBJ(differential-60.) <= HP_TOLERANCE,"native-HP-differential60","actual="+R2S(differential)+" tolerance=.10; same-type paired regen control")
        call RB_LogCheck(controlHits == 0,"control-undamaged","actual="+I2S(controlHits))
        call RB_LogCheck(targetEnd > .405 and controlEnd > .405,"targets-survive","target="+R2S(targetEnd)+" control="+R2S(controlEnd))
        call RB_LogCheck(not earlyPulse,"no-extra-immediate-recast-shot","no observed post-recast pulse before secondShot+.25 (float epsilon .0001)")
        loop
            exitwhen i > 6
            if i <= shots then
                call RB_LogCheck(RAbsBJ((shotTime[i]-shotTime[i-1])-.25) <= CADENCE_TOLERANCE,"recast-cadence-interval"+I2S(i-1),"actual="+R2S(shotTime[i]-shotTime[i-1])+" expected=.25 tolerance=.03125")
            else
                call RB_LogRecord("FAIL","missing-recast-cadence-interval"+I2S(i-1),"need6 real shots/5 adjacent intervals; actual shots="+I2S(shots))
            endif
            set i = i+1
        endloop
        call BeginAim()
    endfunction

    private function ResetObservations takes nothing returns nothing
        set phase = 0
        set calibrated = false
        set calibrationHits = 0
        set calibrationHP = 0.
        set calibrationDamage = 0.
        set calibrationSource = false
        set controlHits = 0
        set hits = 0
        set hitValuesOK = true
        set hitSourcesOK = true
        set shots = 0
        set projectilesOK = true
        set castEvents = 0
        set orderTime = 0.
        set castTime = 0.
        set targetStart = 0.
        set controlStart = 0.
        set expectedCast = 0
        set pendingRecast = false
        set recastRequested = false
        set recastQualified = false
        set earlyPulse = false
        set recastDue = 0.
        set recastIssue = 0.
        set recastEffect = 0.
        set recastEffectShots = 0
    endfunction

    private function SpawnScene takes nothing returns nothing
        call ResetObservations()
        set actor = CreateUnit(Player(0),'o000',-2223.5,4352.,0.)
        set caster = CreateUnit(Player(0),'o001',-5500.,-5500.,0.)
        set target = CreateUnit(Player(1),'o000',-1967.5,4352.,0.)
        set control = CreateUnit(Player(1),'o000',-1967.5,4864.,0.)
        call PauseUnit(target,true)
        call PauseUnit(control,true)
        set damageHook = CreateTrigger()
        call TriggerRegisterUnitEvent(damageHook,target,EVENT_UNIT_DAMAGED)
        call TriggerRegisterUnitEvent(damageHook,control,EVENT_UNIT_DAMAGED)
        call TriggerAddCondition(damageHook,Condition(function OnDamage))
        set spellHook = CreateTrigger()
        call TriggerRegisterUnitEvent(spellHook,caster,EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(spellHook,Condition(function OnSpell))
        set shotHook = CreateTrigger()
        call TriggerAddCondition(shotHook,Condition(function OnShot))
        if not RB_InitializePair(actor,caster,shotHook) then
            call Abort("public InitializePair refused validated rawcode contract")
        endif
    endfunction

    private function AimDestructable takes nothing returns nothing
        set destSeen = destSeen+1
        if destSeen > 128 or GetWidgetLife(GetEnumDestructable()) > .405 then
            set corridorClear = false
        endif
    endfunction

    private function AimRayClear takes unit endpoint returns boolean
        local real x = GetUnitX(actor)
        local real y = GetUnitY(actor)
        local real dx = GetUnitX(endpoint)-x
        local real dy = GetUnitY(endpoint)-y
        local real distance = SquareRoot(dx*dx+dy*dy)
        local real px
        local real py
        local real baseZ
        local integer level = GetTerrainCliffLevel(x,y)
        local integer stepIndex = 0
        local integer sideIndex
        local integer seen = 0
        local unit u
        call MoveLocation(groundProbe,x,y)
        set baseZ = GetLocationZ(groundProbe)
        set dx = dx/distance
        set dy = dy/distance
        loop
            exitwhen stepIndex > 16
            set sideIndex = -1
            loop
                exitwhen sideIndex > 1
                set px = x+(GetUnitX(endpoint)-x)*I2R(stepIndex)/16.-dy*I2R(sideIndex)*48.
                set py = y+(GetUnitY(endpoint)-y)*I2R(stepIndex)/16.+dx*I2R(sideIndex)*48.
                call MoveLocation(groundProbe,px,py)
                if IsTerrainPathable(px,py,PATHING_TYPE_WALKABILITY) or GetTerrainCliffLevel(px,py) != level or RAbsBJ(GetLocationZ(groundProbe)-baseZ) > 1. then
                    return false
                endif
                set sideIndex = sideIndex+1
            endloop
            set stepIndex = stepIndex+1
        endloop
        call SetRect(corridorRect,RMinBJ(x,GetUnitX(endpoint))-48.,RMinBJ(y,GetUnitY(endpoint))-48.,RMaxBJ(x,GetUnitX(endpoint))+48.,RMaxBJ(y,GetUnitY(endpoint))+48.)
        set corridorClear = true
        set destSeen = 0
        call EnumDestructablesInRect(corridorRect,null,function AimDestructable)
        call GroupEnumUnitsInRect(corridorUnits,corridorRect,null)
        loop
            set u = FirstOfGroup(corridorUnits)
            exitwhen u == null
            set seen = seen+1
            if seen > 128 or (u != actor and u != endpoint and GetWidgetLife(u) > .405) then
                set corridorClear = false
            endif
            call GroupRemoveUnit(corridorUnits,u)
            exitwhen seen > 128
        endloop
        call GroupClear(corridorUnits)
        set u = null
        return corridorClear
    endfunction

    private function AimSceneReady takes nothing returns boolean
        local real ex = GetUnitX(target)-GetUnitX(actor)
        local real ey = GetUnitY(target)-GetUnitY(actor)
        local real nx = GetUnitX(northTarget)-GetUnitX(actor)
        local real ny = GetUnitY(northTarget)-GetUnitY(actor)
        local real el = SquareRoot(ex*ex+ey*ey)
        local real nl = SquareRoot(nx*nx+ny*ny)
        if not At(actor,-3136.,2624.) or not At(caster,-5500.,-5500.) or not At(target,-2880.,2624.) or not At(northTarget,-3136.,2880.) or not At(control,-2880.,3136.) or not At(northControl,-3648.,2880.) then
            return false
        endif
        if not BodyReady(actor) or not BodyReady(target) or not BodyReady(northTarget) or not BodyReady(control) or not BodyReady(northControl) then
            return false
        endif
        if GetUnitTypeId(caster) != 'o001' or GetUnitAbilityLevel(caster,'A00G') != 1 or GetUnitAbilityLevel(caster,'Ablo') != 0 or GetWidgetLife(caster) <= .405 or IsUnitPaused(actor) or IsUnitPaused(caster) then
            return false
        endif
        if not IsUnitPaused(target) or not IsUnitPaused(northTarget) or not IsUnitPaused(control) or not IsUnitPaused(northControl) or RAbsBJ(GetUnitFacing(actor)) > .01 or GetUnitCurrentOrder(actor) != 0 then
            return false
        endif
        if GetOwningPlayer(target) != Player(1) or GetOwningPlayer(northTarget) != Player(1) or GetOwningPlayer(control) != Player(1) or GetOwningPlayer(northControl) != Player(1) then
            return false
        endif
        if not IsUnitEnemy(target,Player(0)) or not IsUnitEnemy(northTarget,Player(0)) or not IsUnitEnemy(control,Player(0)) or not IsUnitEnemy(northControl,Player(0)) or not IsUnitEnemy(actor,Player(1)) then
            return false
        endif
        if el < 254. or el > 258. or nl < 254. or nl > 258. or (ex*nx+ey*ny)/(el*nl) > .7071068 then
            return false
        endif
        call RB_LogRecord("OBS","actual-two-ray-geometry","eastDelta="+R2S(ex)+","+R2S(ey)+" northDelta="+R2S(nx)+","+R2S(ny)+" cosine="+R2S((ex*nx+ey*ny)/(el*nl)))
        // Controls are hundreds of units off BOTH rays by actual placement.
        if not AimRayClear(target) or not AimRayClear(northTarget) then
            return false
        endif
        return not IsTerrainPathable(GetUnitX(control),GetUnitY(control),PATHING_TYPE_WALKABILITY) and not IsTerrainPathable(GetUnitX(northControl),GetUnitY(northControl),PATHING_TYPE_WALKABILITY)
    endfunction

    private function SpawnAimScene takes nothing returns nothing
        call ResetObservations()
        set actor = CreateUnit(Player(0),'o000',-3136.,2624.,0.)
        set caster = CreateUnit(Player(0),'o001',-5500.,-5500.,0.)
        set target = CreateUnit(Player(1),'o000',-2880.,2624.,0.)
        set northTarget = CreateUnit(Player(1),'o000',-3136.,2880.,0.)
        set control = CreateUnit(Player(1),'o000',-2880.,3136.,0.)
        set northControl = CreateUnit(Player(1),'o000',-3648.,2880.,0.)
        call PauseUnit(target,true)
        call PauseUnit(northTarget,true)
        call PauseUnit(control,true)
        call PauseUnit(northControl,true)
        set damageHook = CreateTrigger()
        call TriggerRegisterUnitEvent(damageHook,target,EVENT_UNIT_DAMAGED)
        call TriggerRegisterUnitEvent(damageHook,northTarget,EVENT_UNIT_DAMAGED)
        call TriggerRegisterUnitEvent(damageHook,control,EVENT_UNIT_DAMAGED)
        call TriggerRegisterUnitEvent(damageHook,northControl,EVENT_UNIT_DAMAGED)
        call TriggerAddCondition(damageHook,Condition(function OnDamage))
        set spellHook = CreateTrigger()
        call TriggerRegisterUnitEvent(spellHook,caster,EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(spellHook,Condition(function OnSpell))
        set shotHook = CreateTrigger()
        call TriggerAddCondition(shotHook,Condition(function OnShot))
        if not RB_InitializePair(actor,caster,shotHook) then
            call Abort("fresh aim pair public initialization failed")
        endif
    endfunction

    private function AssessAim takes nothing returns nothing
        local real eastDiff = (GetWidgetLife(control)-controlStart)-(GetWidgetLife(target)-targetStart)
        local real northDiff = (GetWidgetLife(northControl)-northControlStart)-(GetWidgetLife(northTarget)-northStart)
        local integer i = 2
        call RB_LogRecord("OBS","aim-HP-pairs","east="+R2S(targetStart)+"->"+R2S(GetWidgetLife(target))+" eastControl="+R2S(controlStart)+"->"+R2S(GetWidgetLife(control))+" north="+R2S(northStart)+"->"+R2S(GetWidgetLife(northTarget))+" northControl="+R2S(northControlStart)+"->"+R2S(GetWidgetLife(northControl)))
        call RB_LogCheck(recastQualified and castEvents == 2 and recastEffectShots == 1,"aim-inflight-native-window","exact NORTH effect at public shot1 while same first flight live/no impact")
        call RB_LogCheck(shots == 5,"five-total-real-shots","actual="+I2S(shots)+" expected=5")
        call RB_LogCheck(shots == 5 and projectilesOK,"five-public-live-missiles","actual live separate dummy/visible source/current actor origin at every pulse")
        call RB_LogCheck(hits == 5 and hitValuesOK and hitSourcesOK,"five-native-ten-visible-source","actual hits="+I2S(hits)+" every native amount10/source actor")
        call RB_LogCheck(eastHits == 1,"east-first-only","actual="+I2S(eastHits)+" expected=1")
        call RB_LogCheck(northHits == 4,"north-four-future-hits","actual="+I2S(northHits)+" expected=4")
        call RB_LogCheck(RAbsBJ(eastDiff-10.) <= HP_TOLERANCE,"east-HP-differential10","actual="+R2S(eastDiff)+" tolerance=.10")
        call RB_LogCheck(RAbsBJ(northDiff-40.) <= HP_TOLERANCE,"north-HP-differential40","actual="+R2S(northDiff)+" tolerance=.10")
        call RB_LogCheck(controlHits == 0,"both-controls-undamaged","actual="+I2S(controlHits))
        call RB_LogCheck(GetWidgetLife(target) > .405 and GetWidgetLife(northTarget) > .405 and GetWidgetLife(control) > .405 and GetWidgetLife(northControl) > .405,"all-four-bodies-survive","native widget life remains positive")
        call RB_LogCheck(not earlyPulse,"no-immediate-aim-recast-emission","no pulse before firstShot+.25 (float epsilon .0001)")
        loop
            exitwhen i > 5
            if i <= shots then
                call RB_LogCheck(RAbsBJ((shotTime[i]-shotTime[i-1])-.25) <= CADENCE_TOLERANCE,"aim-cadence-interval"+I2S(i-1),"actual="+R2S(shotTime[i]-shotTime[i-1])+" expected=.25 tolerance=.03125")
            else
                call RB_LogRecord("FAIL","missing-aim-interval"+I2S(i-1),"need5 actual shot notifications/4 adjacent intervals")
            endif
            set i = i+1
        endloop
        call RB_LogCase("R05-existing-flight-heading")
        call RB_LogCheck(postSample,"post-dispatch-first-flight-observed","same borrowed ID/dummy/source live at shot1/no impacts before sample")
        call RB_LogCheck(sampleAdvance > 0. and sampleCross <= 1.,"first-flight-old-ray-advance","advance="+R2S(sampleAdvance)+" crossTrack="+R2S(sampleCross)+" tolerance=1 sampleTime="+R2S(sampleTime))
        call RB_LogCheck(firstEastBeforeSecond,"first-native-east-impact-before-shot2","firstEastTime="+R2S(firstEastTime)+" observedShots="+I2S(firstEastShots)+" firstShot="+R2S(shotTime[1])+" nextBoundary="+R2S(shotTime[1]+.25))
        call RB_LogCheck(not northBeforeSecond,"no-premature-north-impact","native north impacts before second emission must be zero")
        call Finish()
    endfunction

    private function AimTick takes nothing returns nothing
        local real now = TimerGetElapsed(clock)
        local real life
        local real dx
        local real dy
        local boolean accepted
        if phase == -1 then
            call Abort("aim native effect/source/point/window or live-flight qualification failed")
        elseif phase == 0 then
            call RB_LogRecord("OBS","aim-actor-ready",Pose(actor))
            call RB_LogRecord("OBS","aim-caster-ready",Pose(caster))
            call RB_LogRecord("OBS","aim-east-ready",Pose(target))
            call RB_LogRecord("OBS","aim-north-ready",Pose(northTarget))
            call RB_LogRecord("OBS","aim-east-control-ready",Pose(control))
            call RB_LogRecord("OBS","aim-north-control-ready",Pose(northControl))
            if not AimSceneReady() then
                call Abort("aim actual placement/type/enemy/pause/abilities/flat unobstructed corridors unavailable")
                return
            endif
            set phase = 1
            set calibrationHP = GetWidgetLife(target)
            set calibrated = UnitDamageTarget(actor,target,10.,true,true,ATTACK_TYPE_MELEE,DAMAGE_TYPE_NORMAL,null)
        elseif phase == 1 then
            call RB_LogRecord("OBS","aim-east-calibration","hits="+I2S(calibrationHits)+" value="+R2S(calibrationDamage)+" HP="+R2S(calibrationHP)+"->"+R2S(GetWidgetLife(target)))
            if not calibrated or calibrationHits != 1 or not calibrationSource or RAbsBJ(calibrationDamage-10.) > .01 or GetWidgetLife(target) >= calibrationHP or controlHits != 0 then
                call Abort("native EAST physical10 calibration unavailable")
                return
            endif
            set northCalibrationHP = GetWidgetLife(northTarget)
            set phase = 2
            set northCalibrationAccepted = UnitDamageTarget(actor,northTarget,10.,true,true,ATTACK_TYPE_MELEE,DAMAGE_TYPE_NORMAL,null)
        elseif phase == 2 then
            call RB_LogRecord("OBS","aim-north-calibration","hits="+I2S(northCalibrationHits)+" value="+R2S(northCalibrationDamage)+" HP="+R2S(northCalibrationHP)+"->"+R2S(GetWidgetLife(northTarget)))
            if not northCalibrationAccepted or northCalibrationHits != 1 or not northCalibrationSource or RAbsBJ(northCalibrationDamage-10.) > .01 or GetWidgetLife(northTarget) >= northCalibrationHP or controlHits != 0 then
                call Abort("native NORTH physical10 calibration unavailable")
                return
            endif
            set life = RMinBJ(RMinBJ(GetUnitState(target,UNIT_STATE_MAX_LIFE),GetUnitState(northTarget,UNIT_STATE_MAX_LIFE)),RMinBJ(GetUnitState(control,UNIT_STATE_MAX_LIFE),GetUnitState(northControl,UNIT_STATE_MAX_LIFE)))-10.
            if life <= 60. then
                call Abort("aim paired health margin unavailable")
                return
            endif
            call SetWidgetLife(target,life)
            call SetWidgetLife(northTarget,life)
            call SetWidgetLife(control,life)
            call SetWidgetLife(northControl,life)
            if RAbsBJ(GetWidgetLife(target)-life) > .001 or RAbsBJ(GetWidgetLife(northTarget)-life) > .001 or RAbsBJ(GetWidgetLife(control)-life) > .001 or RAbsBJ(GetWidgetLife(northControl)-life) > .001 then
                call Abort("aim identical native health reset failed")
                return
            endif
            set phase = 3
        elseif phase == 3 then
            set aimX = GetUnitX(target)
            set aimY = GetUnitY(target)
            set orderTime = now
            set expectedCast = 1
            set phase = 4
            set accepted = IssuePointOrder(caster,"channel",aimX,aimY)
            call RB_LogCheck(accepted,"native-east-order-accepted","actual EAST point="+R2S(aimX)+","+R2S(aimY))
            if not accepted then
                call Abort("initial EAST native point order rejected")
            endif
        elseif phase == 4 then
            if now-orderTime >= 2. then
                call Abort("EAST native effect deadline2s")
            endif
        elseif phase == 5 then
            if pendingRecast and now >= recastDue then
                if shots != 1 or hits != 0 or not FirstLive() then
                    call Abort("first flight/one-shot/no-impact input window unavailable")
                    return
                endif
                // Future tick, not inside observer. Precommit before native call.
                set aimX = GetUnitX(northTarget)
                set aimY = GetUnitY(northTarget)
                set pendingRecast = false
                set recastRequested = true
                set expectedCast = 2
                set recastIssue = now
                call RB_LogRecord("OBS","native-north-order","firstShot="+R2S(shotTime[1])+" due="+R2S(recastDue)+" issue="+R2S(now)+" actual="+R2S(aimX)+","+R2S(aimY))
                set accepted = IssuePointOrder(caster,"channel",aimX,aimY)
                call RB_LogCheck(accepted,"native-north-order-accepted","actual NORTH point, phase/expected event committed before order")
                if not accepted then
                    call Abort("native NORTH recast order rejected")
                endif
            elseif recastQualified and not postSample then
                if shots != 1 or hits != 0 or now >= shotTime[1]+.25 or not FirstLive() then
                    call Abort("post-dispatch next-tick same live first-flight/no-impact sample unavailable")
                    return
                endif
                set sampleTime = now
                set dx = firstFlight.x-firstInitialX
                set dy = firstFlight.y-firstInitialY
                set sampleAdvance = dx*eastDX+dy*eastDY
                set sampleCross = RAbsBJ(dx*eastDY-dy*eastDX)
                call RB_LogRecord("OBS","first-flight-post-dispatch","time="+R2S(now)+" xy="+R2S(firstFlight.x)+","+R2S(firstFlight.y)+" advance="+R2S(sampleAdvance)+" cross="+R2S(sampleCross)+" shots=1 hits=0")
                set postSample = true
                // Never dereference borrowed ID after an impact/later emission.
                set firstFlight = 0
                set firstDummy = null
                set firstSource = null
            elseif recastRequested and not recastQualified and (hits > 0 or now >= shotTime[1]+.25) then
                call Abort("NORTH effect not qualified while first flight live before impact/shot2")
            elseif not recastRequested and now-castTime >= .25 then
                call Abort("first live missile notification unavailable")
            elseif recastQualified and postSample and now-recastEffect >= 3. then
                call AssessAim()
            endif
        endif
    endfunction

    private function Tick takes nothing returns nothing
        local real life
        local boolean accepted
        if aimCase then
            call AimTick()
            return
        endif
        if phase == 7 then
            if not RemovedAbsent() then
                call Abort("next-tick R03 units not cleared for aim scene")
                return
            endif
            call RB_LogCheck(true,"prior-R03-unit-clearance","removed type0/native-group absence on next tick")
            call ReleaseSceneRefs()
            set aimCase = true
            call SpawnAimScene()
            return
        endif
        if phase == -1 then
            call Abort("unexpected native spell effect/source/ability/point or duplicate event")
        elseif phase == 6 then
            if not RemovedAbsent() then
                call Abort("next-tick prior-unit type0/native group clearance unavailable")
                return
            endif
            call RB_LogCheck(true,"prior-unit-clearance","removed type0/native group absence observed on next harness tick")
            call ReleaseSceneRefs()
            set recastCase = true
            call SpawnScene()
        elseif phase == 0 then
            call RB_LogRecord("OBS","actor-ready",Pose(actor))
            call RB_LogRecord("OBS","caster-ready",Pose(caster)+" A00G="+I2S(GetUnitAbilityLevel(caster,'A00G')))
            call RB_LogRecord("OBS","target-ready",Pose(target))
            call RB_LogRecord("OBS","control-ready",Pose(control))
            if not SceneReady() then
                call Abort("type/life/enemy/placement/abilities/pause/facing/order/fresh static path flag readiness unavailable")
                return
            endif
            set phase = 1
            set calibrationHP = GetWidgetLife(target)
            // Explicit physical base mapping for this controlled scene. No spell,
            // fire, magic, universal, AOE, burn or armor-getter assumption.
            set calibrated = UnitDamageTarget(actor,target,10.,true,true,ATTACK_TYPE_MELEE,DAMAGE_TYPE_NORMAL,null)
        elseif phase == 1 then
            call RB_LogRecord("OBS","native-calibration","events="+I2S(calibrationHits)+" damage="+R2S(calibrationDamage)+" HPbefore="+R2S(calibrationHP)+" HPafter="+R2S(GetWidgetLife(target)))
            if not calibrated or calibrationHits != 1 or not calibrationSource or RAbsBJ(calibrationDamage-10.) > .01 or GetWidgetLife(target) >= calibrationHP or controlHits != 0 then
                call Abort("physical10 native calibration unavailable; no burst-rule RED inferred")
                return
            endif
            set life = RMinBJ(GetUnitState(target,UNIT_STATE_MAX_LIFE),GetUnitState(control,UNIT_STATE_MAX_LIFE))-10.
            if life <= 60. then
                call Abort("insufficient controlled health margin")
                return
            endif
            call SetWidgetLife(target,life)
            call SetWidgetLife(control,life)
            if RAbsBJ(GetWidgetLife(target)-life) > .001 or RAbsBJ(GetWidgetLife(control)-life) > .001 then
                call Abort("same native starting health reset failed")
                return
            endif
            set phase = 3
        elseif phase == 3 then
            set hits = 0
            set controlHits = 0
            set shots = 0
            set aimX = GetUnitX(target)
            set aimY = GetUnitY(target)
            set orderTime = TimerGetElapsed(clock)
            set expectedCast = 1
            set phase = 4
            set accepted = IssuePointOrder(caster,"channel",aimX,aimY)
            call RB_LogCheck(accepted,"native-point-order-accepted","actual target point="+R2S(aimX)+","+R2S(aimY))
            if not accepted then
                call Abort("native point order rejected; behavior assertions not run")
            endif
        elseif phase == 4 then
            if TimerGetElapsed(clock)-orderTime >= 2. then
                call Abort("native Channel effect deadline2s; no behavior assertions without actual event")
            endif
        elseif phase == 5 then
            if recastCase then
                if pendingRecast and TimerGetElapsed(clock) >= recastDue then
                    if shots != 2 then
                        call Abort("active-window input unavailable: not exactly2 observed shots")
                        return
                    endif
                    // Commit BEFORE IssuePointOrder: native effect may be synchronous.
                    set pendingRecast = false
                    set recastRequested = true
                    set expectedCast = 2
                    set recastIssue = TimerGetElapsed(clock)
                    call RB_LogRecord("OBS","recast-point-order","secondShot="+R2S(shotTime[2])+" due="+R2S(recastDue)+" issue="+R2S(recastIssue))
                    set accepted = IssuePointOrder(caster,"channel",aimX,aimY)
                    call RB_LogCheck(accepted,"native-recast-order-accepted","same actual target point="+R2S(aimX)+","+R2S(aimY))
                    if not accepted then
                        call Abort("native recast order rejected; no behavioral recast RED")
                    endif
                elseif recastRequested and not recastQualified and TimerGetElapsed(clock) >= shotTime[2]+.25 then
                    call Abort("second native effect absent before secondShot+.25; no active-window qualification")
                elseif not recastRequested and TimerGetElapsed(clock)-castTime >= .75 then
                    call Abort("two live public projectile notifications unavailable by first-effect+.75")
                elseif recastQualified and TimerGetElapsed(clock)-recastEffect >= 3. then
                    call AssessRecast()
                endif
            elseif castEvents != 1 then
                call Abort("expected exactly one native cast event")
            elseif TimerGetElapsed(clock)-castTime >= 3. then
                call RB_LogCheck(true,"native-cast-effect-ready","one matching source/A00G/actual target point; observation horizon3s relative to native event")
                call Assess()
            endif
        endif
    endfunction

    function RF_StartAimTest takes nothing returns nothing
        call RB_LogBegin()
        call RB_LogCase("B01-four-shot-native-effects")
        call SetPlayerAlliance(Player(0),Player(1),ALLIANCE_PASSIVE,false)
        call SetPlayerAlliance(Player(1),Player(0),ALLIANCE_PASSIVE,false)
        set clock = CreateTimer()
        set runner = CreateTimer()
        set groundProbe = Location(0.,0.)
        set corridorUnits = CreateGroup()
        set corridorRect = Rect(0.,0.,0.,0.)
        call TimerStart(clock,25.,false,function Deadline)
        call SpawnScene()
        if not done then
            call TimerStart(runner,PERIOD,true,function Tick)
        endif
    endfunction
endlibrary
