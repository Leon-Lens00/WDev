library RFBurstNativeTest requires RFBurstLog, RFBurstPair
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
    endglobals

    private function Pose takes unit u returns string
        return "type="+I2S(GetUnitTypeId(u))+" xy="+R2S(GetUnitX(u))+","+R2S(GetUnitY(u))+" facing="+R2S(GetUnitFacing(u))+" order="+I2S(GetUnitCurrentOrder(u))+" hp="+R2S(GetWidgetLife(u))
    endfunction

    private function Finish takes nothing returns nothing
        if done then
            return
        endif
        set done = true
        call PauseTimer(runner)
        call PauseTimer(clock)
        call RB_Dispose()
        call DestroyTrigger(spellHook)
        call DestroyTrigger(damageHook)
        call DestroyTrigger(shotHook)
        call RemoveUnit(actor)
        call RemoveUnit(caster)
        call RemoveUnit(target)
        call RemoveUnit(control)
        call DestroyTimer(runner)
        call DestroyTimer(clock)
        set runner = null
        set clock = null
        set spellHook = null
        set damageHook = null
        set shotHook = null
        set actor = null
        set caster = null
        set target = null
        set control = null
        call RB_LogComplete()
    endfunction

    private function Abort takes string why returns nothing
        call RB_LogRecord("FAIL","ABORT-fixture",why)
        call Finish()
    endfunction

    private function Deadline takes nothing returns nothing
        call Abort("global 12 game-second deadline; remaining assertions unreached")
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
        return false
    endfunction

    private function OnSpell takes nothing returns boolean
        set castEvents = castEvents+1
        call RB_LogRecord("OBS","native-spell-effect","ability="+I2S(GetSpellAbilityId())+" source="+I2S(GetHandleId(GetTriggerUnit()))+" xy="+R2S(GetSpellTargetX())+","+R2S(GetSpellTargetY()))
        if phase != 4 or GetTriggerUnit() != caster or GetSpellAbilityId() != 'A00G' or RAbsBJ(GetSpellTargetX()-aimX) > .01 or RAbsBJ(GetSpellTargetY()-aimY) > .01 then
            // Defer cleanup until outside native event dispatch.
            set phase = -1
            return false
        endif
        set castTime = TimerGetElapsed(clock)
        set targetStart = GetWidgetLife(target)
        set controlStart = GetWidgetLife(control)
        set phase = 5
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
        call Finish()
    endfunction

    private function Tick takes nothing returns nothing
        local real life
        local boolean accepted
        if phase == -1 then
            call Abort("unexpected native spell effect/source/ability/point or duplicate event")
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
            if castEvents != 1 then
                call Abort("expected exactly one native cast event")
            elseif TimerGetElapsed(clock)-castTime >= 3. then
                call RB_LogCheck(true,"native-cast-effect-ready","one matching source/A00G/actual target point; observation horizon3s relative to native event")
                call Assess()
            endif
        endif
    endfunction

    function RF_StartBurstTest takes nothing returns nothing
        call RB_LogBegin()
        call RB_LogCase("B01-four-shot-native-effects")
        call SetPlayerAlliance(Player(0),Player(1),ALLIANCE_PASSIVE,false)
        call SetPlayerAlliance(Player(1),Player(0),ALLIANCE_PASSIVE,false)
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
        // Register harness observer BEFORE the application's native cast hook so
        // future synchronous immediate emissions have an actual event baseline.
        set spellHook = CreateTrigger()
        call TriggerRegisterUnitEvent(spellHook,caster,EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(spellHook,Condition(function OnSpell))
        set shotHook = CreateTrigger()
        call TriggerAddCondition(shotHook,Condition(function OnShot))
        set clock = CreateTimer()
        set runner = CreateTimer()
        call TimerStart(clock,12.,false,function Deadline)
        if not RB_InitializePair(actor,caster,shotHook) then
            call Abort("public InitializePair refused validated rawcode contract")
            return
        endif
        call TimerStart(runner,PERIOD,true,function Tick)
    endfunction
endlibrary
