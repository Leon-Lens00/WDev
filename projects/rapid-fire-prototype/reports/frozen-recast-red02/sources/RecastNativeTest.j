library RFBurstRecastTest requires RFBurstLog, RFBurstPair
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
        // Keep removed unit references until next-tick native clearance checks.
    endfunction

    private function ReleaseSceneRefs takes nothing returns nothing
        set actor = null
        set caster = null
        set target = null
        set control = null
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
        call Abort("global 20 game-second deadline; remaining assertions unreached")
    endfunction

    private function OnDamage takes nothing returns boolean
        local real amount = GetEventDamage()
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
        call Finish()
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

    private function Tick takes nothing returns nothing
        local real life
        local boolean accepted
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

    function RF_StartRecastTest takes nothing returns nothing
        call RB_LogBegin()
        call RB_LogCase("B01-four-shot-native-effects")
        call SetPlayerAlliance(Player(0),Player(1),ALLIANCE_PASSIVE,false)
        call SetPlayerAlliance(Player(1),Player(0),ALLIANCE_PASSIVE,false)
        set clock = CreateTimer()
        set runner = CreateTimer()
        call TimerStart(clock,20.,false,function Deadline)
        call SpawnScene()
        if not done then
            call TimerStart(runner,PERIOD,true,function Tick)
        endif
    endfunction
endlibrary
