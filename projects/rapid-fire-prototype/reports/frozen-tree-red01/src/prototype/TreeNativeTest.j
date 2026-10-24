library RFBurstTreeTest requires RFBurstLog, RFBurstPair
    // Two fresh scenes, adapted from BurstNativeTest (not the Aim suite).
    // Collection entries are borrowed ONLY during a fresh bounded scan.
    globals
        private constant real PERIOD = .03125
        private constant real AX = -3136.
        private constant real AY = 2624.
        private unit actor = null
        private unit caster = null
        private unit target = null
        private unit control = null
        private destructable tree = null
        private timer clock = null
        private timer runner = null
        private trigger damageHook = null
        private trigger spellHook = null
        private trigger shotHook = null
        private integer phase = 0
        private integer scene = 0
        private boolean done = false
        private boolean qualified = false
        private boolean absentPassed = false
        private string fault = ""
        private integer calibrationHits = 0
        private real calibrationHP = 0.
        private real calibrationDamage = 0.
        private boolean calibrationSource = false
        private boolean calibrated = false
        private integer hits = 0
        private integer controlHits = 0
        private boolean hitValuesOK = true
        private boolean hitSourcesOK = true
        private integer shots = 0
        private boolean projectilesOK = true
        private integer castEvents = 0
        private real castTime = 0.
        private real orderTime = 0.
        private real aimX = 0.
        private real aimY = 0.
        private real targetStart = 0.
        private real controlStart = 0.
        private real treeStart = 0.
        private boolean bodiesOK = true
        private boolean treeOK = true
        private integer liveCount = 0
        private integer array token
        private boolean array closed
        private boolean array seen
        private real array birth
        private real array lastTime
        private real array lastX
        private real array lastY
        private real array firstAbsent
        private integer corridorUnits = 0
        private integer corridorTrees = 0
        private integer ownedTrees = 0
        private boolean corridorOK = true
        private real corridorY = 0.
        private real array absentX
        private real array absentY
    endglobals

    private function Pose takes unit u returns string
        return "type="+I2S(GetUnitTypeId(u))+" xy="+R2S(GetUnitX(u))+","+R2S(GetUnitY(u))+" hp="+R2S(GetWidgetLife(u))+" owner="+I2S(GetPlayerId(GetOwningPlayer(u)))+" order="+I2S(GetUnitCurrentOrder(u))
    endfunction

    private function LiveOwned takes unit u, integer raw, player p returns boolean
        return GetUnitTypeId(u) == raw and GetWidgetLife(u) > .405 and GetOwningPlayer(u) == p
    endfunction

    private function Bodies takes nothing returns boolean
        return LiveOwned(actor,'o000',Player(0)) and LiveOwned(caster,'o001',Player(0)) and LiveOwned(target,'o000',Player(1)) and LiveOwned(control,'o000',Player(1))
    endfunction

    private function RemoveScene takes nothing returns nothing
        // Called only AFTER the finite observation, or explicit fixture abort.
        call RB_Dispose()
        if damageHook != null then
            call DestroyTrigger(damageHook)
            call DestroyTrigger(spellHook)
            call DestroyTrigger(shotHook)
        endif
        set damageHook = null
        set spellHook = null
        set shotHook = null
        call RemoveUnit(actor)
        call RemoveUnit(caster)
        call RemoveUnit(target)
        call RemoveUnit(control)
        if tree != null then
            call RemoveDestructable(tree)
        endif
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
        set runner = null
        set clock = null
        set actor = null
        set caster = null
        set target = null
        set control = null
        set tree = null
        call RB_LogComplete()
    endfunction

    private function Abort takes string why returns nothing
        call RB_LogRecord("FAIL","ABORT-fixture",why+"; behavior unqualified, no tree RED inferred")
        call Finish()
    endfunction

    private function Deadline takes nothing returns nothing
        call Abort("global15 game-second deadline; unreached assertions remain pending")
    endfunction

    private function At takes unit u, real x, real y returns boolean
        return GetUnitTypeId(u) != 0 and RAbsBJ(GetUnitX(u)-x) <= 1. and RAbsBJ(GetUnitY(u)-y) <= 1.
    endfunction

    private function InWorld takes real x, real y, real pad returns boolean
        return x-pad > WorldBounds.minX and x+pad < WorldBounds.maxX and y-pad > WorldBounds.minY and y+pad < WorldBounds.maxY
    endfunction

    private function TreeWitness takes nothing returns boolean
        if scene == 0 then
            return tree == null
        endif
        return GetDestructableTypeId(tree) == 'LTlt' and GetDestructableLife(tree) > .405 and RAbsBJ(GetDestructableX(tree)-(AX+128.)) <= 1. and RAbsBJ(GetDestructableY(tree)-AY) <= 1.
    endfunction

    private function VisitTree takes nothing returns nothing
        local destructable d = GetEnumDestructable()
        set corridorTrees = corridorTrees+1
        if corridorTrees > 64 then
            set corridorOK = false
        elseif scene == 1 and d == tree and TreeWitness() then
            set ownedTrees = ownedTrees+1
        else
            // No life filter: the immutable core enumerates dead widgets too.
            set corridorOK = false
        endif
        set d = null
    endfunction

    private function Corridor takes nothing returns boolean
        local group g = CreateGroup()
        local rect r
        local unit u
        local real x = GetUnitX(actor)
        local real y = GetUnitY(actor)
        set corridorUnits = 0
        set corridorTrees = 0
        set ownedTrees = 0
        set corridorOK = true
        // Entire 1500 ray plus core candidate pad128 and logical collision32.
        // Broad conservative native enumeration; no footprint/LOS inference.
        set r = Rect(x-160.,y-160.,x+1660.,y+160.)
        call GroupEnumUnitsInRect(g,r,null)
        call RemoveRect(r)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g,u)
            set corridorUnits = corridorUnits+1
            if corridorUnits > 256 then
                set corridorOK = false
                exitwhen true
            endif
            if GetUnitX(u) >= x-160. and GetUnitX(u) <= x+1660. and RAbsBJ(GetUnitY(u)-y) <= 160. then
                if u != actor and u != target then
                    set corridorOK = false
                endif
            endif
        endloop
        call DestroyGroup(g)
        set corridorY = y
        set r = Rect(x-160.,corridorY-160.,x+1660.,corridorY+160.)
        call EnumDestructablesInRect(r,null,function VisitTree)
        call RemoveRect(r)
        call RB_LogRecord("OBS","native-corridor","unitsScanned="+I2S(corridorUnits)+" destructables="+I2S(corridorTrees)+" owned="+I2S(ownedTrees)+" no life filter; full1500+160 broadphase")
        set g = null
        set r = null
        set u = null
        return corridorOK and ownedTrees == scene
    endfunction

    private function SceneReady takes nothing returns boolean
        if not Bodies() or not At(actor,AX,AY) or not At(caster,-5500.,-5500.) or not At(target,AX+512.,AY) or not At(control,AX+512.,AY+512.) then
            return false
        endif
        if GetWidgetLife(actor) <= 100. or GetWidgetLife(target) <= 100. or GetWidgetLife(control) <= 100. then
            return false
        endif
        if GetUnitAbilityLevel(caster,'A00G') != 1 or GetUnitAbilityLevel(caster,'Ablo') != 0 or GetUnitAbilityLevel(actor,'A00G') != 0 or GetUnitAbilityLevel(actor,'Ablo') != 0 then
            return false
        endif
        if GetUnitAbilityLevel(target,'A00G') != 0 or GetUnitAbilityLevel(target,'Ablo') != 0 or GetUnitAbilityLevel(control,'A00G') != 0 or GetUnitAbilityLevel(control,'Ablo') != 0 then
            return false
        endif
        if IsUnitPaused(actor) or IsUnitPaused(caster) or not IsUnitPaused(target) or not IsUnitPaused(control) then
            return false
        endif
        if not IsUnitEnemy(target,Player(0)) or not IsUnitEnemy(control,Player(0)) or not IsUnitEnemy(actor,Player(1)) or GetPlayerAlliance(Player(0),Player(1),ALLIANCE_PASSIVE) or GetPlayerAlliance(Player(1),Player(0),ALLIANCE_PASSIVE) then
            return false
        endif
        if GetUnitCurrentOrder(actor) != 0 or RAbsBJ(GetUnitFacing(actor)) > .01 or not TreeWitness() then
            return false
        endif
        if not InWorld(AX,AY,160.) or not InWorld(AX+1500.,AY,160.) or not InWorld(GetUnitX(control),GetUnitY(control),32.) or not InWorld(-5500.,-5500.,32.) then
            return false
        endif
        if scene == 0 then
            set absentX[0] = GetUnitX(actor)
            set absentY[0] = GetUnitY(actor)
            set absentX[1] = GetUnitX(target)
            set absentY[1] = GetUnitY(target)
            set absentX[2] = GetUnitX(control)
            set absentY[2] = GetUnitY(control)
        elseif RAbsBJ(GetUnitX(actor)-absentX[0]) > .01 or RAbsBJ(GetUnitY(actor)-absentY[0]) > .01 or RAbsBJ(GetUnitX(target)-absentX[1]) > .01 or RAbsBJ(GetUnitY(target)-absentY[1]) > .01 or RAbsBJ(GetUnitX(control)-absentX[2]) > .01 or RAbsBJ(GetUnitY(control)-absentY[2]) > .01 then
            return false
        endif
        // Terrain path flags are NOT missile obstruction. Owned tree pathing is
        // expected, not an unintended blocker. Native contacts qualify the ray.
        return Corridor()
    endfunction

    private function Scan takes integer incoming returns nothing
        local integer i = 0
        local integer j
        local integer match
        local Missiles m
        local real now = TimerGetElapsed(clock)
        set liveCount = 0
        if Missiles.count >= 32 then
            set fault = "public collection overflow32"
            return
        endif
        set j = 1
        loop
            exitwhen j > shots or j > 4
            set seen[j] = false
            set j = j+1
        endloop
        loop
            exitwhen i > Missiles.count
            // Only this freshly acquired entry is dereferenced, never token[].
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
                        set fault = "unmapped source flight or ambiguous allocator reuse"
                    else
                        set seen[match] = true
                        set lastTime[match] = now
                        set lastX[match] = m.x
                        set lastY[match] = m.y
                    endif
                endif
            endif
            set i = i+1
        endloop
        if liveCount > 4 then
            set fault = "more than four live application flights"
        endif
        set j = 1
        loop
            exitwhen j > shots or j > 4
            if not closed[j] and not seen[j] then
                set closed[j] = true
                set firstAbsent[j] = now
                call RB_LogRecord("OBS","flight-absence-bracket","serial="+I2S(j)+" birth="+R2S(birth[j])+" lastLive="+R2S(lastTime[j])+" xy="+R2S(lastX[j])+","+R2S(lastY[j])+" firstAbsent="+R2S(now))
            endif
            set j = j+1
        endloop
    endfunction

    private function OnShot takes nothing returns boolean
        local Missiles m = RB_GetShotMissile()
        local integer j = 1
        local boolean valid = false
        // Birth pulse serial, not a private generation getter. If an ID is reused
        // before we observed its absence, reject rather than read the old ID.
        loop
            exitwhen j > shots or j > 4
            if not closed[j] and token[j] == m then
                set fault = "ID reused before observed absence; lifetime unqualified"
                return false
            endif
            set j = j+1
        endloop
        call Scan(m)
        set shots = shots+1
        if shots > 4 then
            set fault = "more than four birth pulses"
            return false
        endif
        if m != 0 then
            set valid = m.allocated and m.launched and m.dummy != null
            set valid = valid and GetUnitTypeId(m.dummy) != 0 and m.dummy != actor and m.dummy != caster and m.dummy != target and m.dummy != control
            set valid = valid and m.source == actor and RB_GetShotSource() == actor
            set valid = valid and RAbsBJ(m.x-GetUnitX(actor)) <= 1. and RAbsBJ(m.y-GetUnitY(actor)) <= 1.
            set valid = valid and RAbsBJ(RB_GetShotX()-m.x) <= .01 and RAbsBJ(RB_GetShotY()-m.y) <= .01
        endif
        set projectilesOK = projectilesOK and valid and phase == 5
        if not valid then
            set fault = "birth pulse has no qualified live public projectile"
            return false
        endif
        set token[shots] = m
        set closed[shots] = false
        set birth[shots] = TimerGetElapsed(clock)
        set lastTime[shots] = birth[shots]
        set lastX[shots] = m.x
        set lastY[shots] = m.y
        call RB_LogRecord("OBS","SHOT-public-birth","serial="+I2S(shots)+" time="+R2S(birth[shots])+" liveID="+I2S(m)+" xy="+R2S(m.x)+","+R2S(m.y)+" dummy="+I2S(GetHandleId(m.dummy))+" visibleSource="+I2S(GetHandleId(m.source)))
        return false
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
            elseif phase == 5 then
                set hits = hits+1
                set hitValuesOK = hitValuesOK and RAbsBJ(amount-10.) <= .01
                set hitSourcesOK = hitSourcesOK and GetEventDamageSource() == actor
                call RB_LogRecord("OBS","native-damage","time="+R2S(TimerGetElapsed(clock))+" value="+R2S(amount)+" source="+I2S(GetHandleId(GetEventDamageSource()))+" visible="+I2S(GetHandleId(actor)))
            else
                set fault = "target damage outside calibration/observation"
            endif
        endif
        return false
    endfunction

    private function OnSpell takes nothing returns boolean
        set castEvents = castEvents+1
        call RB_LogRecord("OBS","native-spell-effect","time="+R2S(TimerGetElapsed(clock))+" ability="+I2S(GetSpellAbilityId())+" source="+I2S(GetHandleId(GetTriggerUnit()))+" point="+R2S(GetSpellTargetX())+","+R2S(GetSpellTargetY()))
        if phase != 4 or GetTriggerUnit() != caster or GetSpellAbilityId() != 'A00G' or RAbsBJ(GetSpellTargetX()-aimX) > .01 or RAbsBJ(GetSpellTargetY()-aimY) > .01 then
            set fault = "unexpected spell source/ability/point/count"
            return false
        endif
        set castTime = TimerGetElapsed(clock)
        set targetStart = GetWidgetLife(target)
        set controlStart = GetWidgetLife(control)
        set phase = 5
        return false
    endfunction

    private function Assess takes nothing returns boolean
        local real diff = (GetWidgetLife(control)-controlStart)-(GetWidgetLife(target)-targetStart)
        local integer i = 1
        local boolean cadence = shots == 4
        local boolean lifetime = shots == 4
        local boolean effects
        loop
            exitwhen i > shots or i > 4
            if i > 1 then
                set cadence = cadence and RAbsBJ((birth[i]-birth[i-1])-.25) <= PERIOD
            endif
            if scene == 0 then
                // Empirical baseline must travel to the farther enemy, then end.
                set lifetime = lifetime and closed[i] and lastX[i] >= aimX-110. and lastX[i] <= aimX+2. and RAbsBJ(lastY[i]-aimY) <= 2.
                set lifetime = lifetime and firstAbsent[i]-birth[i] >= .30 and firstAbsent[i]-birth[i] <= .55
            else
                // Tree origin128, box32, core step30/.025: first candidate
                // contact near .100-.150; +.03125 sampling, finite .18125 cap.
                // Last scalar64..176 excludes enemy contact near x464/.4s.
                set lifetime = lifetime and closed[i] and firstAbsent[i]-birth[i] >= .0625 and firstAbsent[i]-birth[i] <= .18125
                set lifetime = lifetime and lastX[i]-AX >= 64. and lastX[i]-AX <= 176. and RAbsBJ(lastY[i]-AY) <= 2.
            endif
            set i = i+1
        endloop
        call RB_LogRecord("OBS","paired-HP","target="+R2S(targetStart)+"->"+R2S(GetWidgetLife(target))+" control="+R2S(controlStart)+"->"+R2S(GetWidgetLife(control))+" differential="+R2S(diff))
        call RB_LogCheck(shots == 4 and projectilesOK,"four-real-public-launches","actual="+I2S(shots)+" live allocated/launched/separate dummy/source/current origin at birth")
        call RB_LogCheck(cadence,"three-adjacent-quarter-second-intervals","four public birth times; tolerance=.03125")
        call RB_LogCheck(liveCount == 0,"no-source-flights-at-horizon","fresh collection scan at actual effect+3s; no disposal before observation")
        call RB_LogCheck(bodiesOK and Bodies(),"bodies-live-owned-throughout","actor/controller/target/control alive and expected owners at every observer tick")
        call RB_LogCheck(controlHits == 0,"control-undamaged","native control events="+I2S(controlHits))
        if scene == 0 then
            set effects = hits == 4 and hitValuesOK and hitSourcesOK and RAbsBJ(diff-40.) <= .10
            call RB_LogCheck(hits == 4,"four-native-hits","actual="+I2S(hits))
            call RB_LogCheck(hits == 4 and hitValuesOK and hitSourcesOK,"physical10-visible-source","each actual event10 + visible source; calibration excluded")
            call RB_LogCheck(RAbsBJ(diff-40.) <= .10,"paired-HP-differential40","actual="+R2S(diff)+" tolerance=.10")
            call RB_LogCheck(lifetime,"far-enemy-travel-then-extinction","each last-live x>=enemy-110; absence age .30..55; not dummy recycling")
        else
            set effects = hits == 0 and RAbsBJ(diff) <= .10 and treeOK
            call RB_LogCheck(hits == 0,"tree-prevents-native-enemy-damage","actual events="+I2S(hits)+" expected0; downstream impacts are behavioral FAIL, not fixture ABORT")
            call RB_LogCheck(RAbsBJ(diff) <= .10,"paired-HP-differential0","actual="+R2S(diff)+" tolerance=.10")
            call RB_LogCheck(treeOK and TreeWitness(),"tree-live-HP-unchanged","start="+R2S(treeStart)+" end="+R2S(GetDestructableLife(tree))+" no tree removal/death/damage allowed")
            call RB_LogCheck(lifetime,"four-early-near-tree-extinctions","each first absence age<=.18125; last-live x offset64..176/y+-2; enemy512/.4s cannot satisfy")
        endif
        return qualified and effects and lifetime and cadence and projectilesOK and shots == 4 and liveCount == 0 and bodiesOK and Bodies() and controlHits == 0
    endfunction

    private function CreateScene takes nothing returns nothing
        set fault = ""
        set qualified = false
        set shots = 0
        set hits = 0
        set controlHits = 0
        set castEvents = 0
        set calibrationHits = 0
        set hitValuesOK = true
        set hitSourcesOK = true
        set projectilesOK = true
        set bodiesOK = true
        set treeOK = true
        set actor = CreateUnit(Player(0),'o000',AX,AY,0.)
        set caster = CreateUnit(Player(0),'o001',-5500.,-5500.,0.)
        set target = CreateUnit(Player(1),'o000',AX+512.,AY,0.)
        set control = CreateUnit(Player(1),'o000',AX+512.,AY+512.,0.)
        call PauseUnit(target,true)
        call PauseUnit(control,true)
        set tree = null
        if scene == 1 then
            set tree = CreateDestructable('LTlt',AX+128.,AY,0.,1.,0)
            set treeStart = GetDestructableLife(tree)
        endif
        set damageHook = CreateTrigger()
        call TriggerRegisterUnitEvent(damageHook,target,EVENT_UNIT_DAMAGED)
        call TriggerRegisterUnitEvent(damageHook,control,EVENT_UNIT_DAMAGED)
        call TriggerAddCondition(damageHook,Condition(function OnDamage))
        // Observer before application's event hook: baseline precedes sync shot.
        set spellHook = CreateTrigger()
        call TriggerRegisterUnitEvent(spellHook,caster,EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(spellHook,Condition(function OnSpell))
        set shotHook = CreateTrigger()
        call TriggerAddCondition(shotHook,Condition(function OnShot))
        if not RB_InitializePair(actor,caster,shotHook) then
            set fault = "InitializePair rejected fresh pair"
        endif
        set phase = 0
    endfunction

    private function RemovedAbsent takes nothing returns boolean
        local group g = CreateGroup()
        local unit u
        local integer n = 0
        local integer site = 0
        local boolean ok = GetUnitTypeId(actor) == 0 and GetUnitTypeId(caster) == 0 and GetUnitTypeId(target) == 0 and GetUnitTypeId(control) == 0
        loop
            exitwhen site > 1
            if site == 0 then
                call GroupEnumUnitsInRange(g,AX+256.,AY+256.,1024.,null)
            else
                call GroupEnumUnitsInRange(g,-5500.,-5500.,128.,null)
            endif
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g,u)
                set n = n+1
                if u == actor or u == caster or u == target or u == control or n > 256 then
                    set ok = false
                endif
                exitwhen n > 256
            endloop
            set site = site+1
        endloop
        call DestroyGroup(g)
        set g = null
        set u = null
        call Scan(0)
        return ok and fault == "" and liveCount == 0
    endfunction

    private function Tick takes nothing returns nothing
        local real life
        local boolean accepted
        if fault != "" then
            call Abort(fault)
            return
        endif
        if phase == 6 then
            // Next-tick native type AND group absence, no wait/retry/fallback.
            if not RemovedAbsent() then
                call Abort("old bodies/flights not absent on next tick")
                return
            endif
            set scene = 1
            call RB_LogCase("R07-live-tree-termination")
            call CreateScene()
            return
        endif
        call Scan(0)
        if fault != "" then
            call Abort(fault)
            return
        endif
        if phase == 0 then
            call RB_LogRecord("OBS","actor-ready",Pose(actor))
            call RB_LogRecord("OBS","controller-ready",Pose(caster))
            call RB_LogRecord("OBS","target-ready",Pose(target))
            call RB_LogRecord("OBS","control-ready",Pose(control))
            call RB_LogRecord("OBS","tree-ready","type="+I2S(GetDestructableTypeId(tree))+" xy="+R2S(GetDestructableX(tree))+","+R2S(GetDestructableY(tree))+" life="+R2S(GetDestructableLife(tree)))
            if liveCount != 0 or not SceneReady() then
                call Abort("fresh actual geometry512/ownership/alliance/life/abilities/pause/world/tree/corridor unavailable; no terrain/pathing inference")
                return
            endif
            set phase = 1
            set calibrationHP = GetWidgetLife(target)
            set calibrated = UnitDamageTarget(actor,target,10.,true,true,ATTACK_TYPE_MELEE,DAMAGE_TYPE_NORMAL,null)
        elseif phase == 1 then
            call RB_LogRecord("OBS","native-calibration","events="+I2S(calibrationHits)+" damage="+R2S(calibrationDamage)+" HP="+R2S(calibrationHP)+"->"+R2S(GetWidgetLife(target)))
            if not calibrated or calibrationHits != 1 or not calibrationSource or RAbsBJ(calibrationDamage-10.) > .01 or GetWidgetLife(target) >= calibrationHP or controlHits != 0 then
                call Abort("physical10 visible-source native calibration unavailable")
                return
            endif
            set life = RMinBJ(GetUnitState(target,UNIT_STATE_MAX_LIFE),GetUnitState(control,UNIT_STATE_MAX_LIFE))-10.
            call SetWidgetLife(target,life)
            call SetWidgetLife(control,life)
            if life <= 60. or RAbsBJ(GetWidgetLife(target)-life) > .001 or RAbsBJ(GetWidgetLife(control)-life) > .001 then
                call Abort("same-type equal native HP reset failed")
                return
            endif
            set phase = 3
        elseif phase == 3 then
            if not SceneReady() or liveCount != 0 then
                call Abort("fixture changed before actual order")
                return
            endif
            set qualified = true
            set aimX = GetUnitX(target)
            set aimY = GetUnitY(target)
            set orderTime = TimerGetElapsed(clock)
            set phase = 4
            // All expected-event state committed BEFORE possibly synchronous cast.
            set accepted = IssuePointOrder(caster,"channel",aimX,aimY)
            call RB_LogCheck(accepted,"native-point-order-accepted","EAST actual target="+R2S(aimX)+","+R2S(aimY))
            if not accepted then
                call Abort("native Channel order rejected")
            endif
        elseif phase == 4 then
            if TimerGetElapsed(clock)-orderTime >= 2. then
                call Abort("native effect deadline2s")
            endif
        elseif phase == 5 then
            set bodiesOK = bodiesOK and Bodies()
            if scene == 1 then
                set treeOK = treeOK and TreeWitness() and RAbsBJ(GetDestructableLife(tree)-treeStart) <= .01
            endif
            if castEvents != 1 then
                call Abort("actual effect count not1")
            elseif TimerGetElapsed(clock)-castTime >= 3. then
                call RB_LogCheck(qualified,"native-fixture-qualified","actual order/effect/calibration/corridor; observation3s from effect, not producer intent")
                if scene == 0 then
                    set absentPassed = Assess()
                    if not absentPassed then
                        call Abort("absent positive failed; present contrast not admitted")
                        return
                    endif
                    call RemoveScene()
                    set phase = 6
                else
                    // Missing early extinction/HP prevention on admitted fixture
                    // stays FAIL above, never reclassified as fixture-unready.
                    set accepted = Assess()
                    call Finish()
                endif
            endif
        endif
    endfunction

    function RF_StartTreeTest takes nothing returns nothing
        call RB_LogBegin()
        call RB_LogCase("R06-tree-absent-positive")
        call SetPlayerAlliance(Player(0),Player(1),ALLIANCE_PASSIVE,false)
        call SetPlayerAlliance(Player(1),Player(0),ALLIANCE_PASSIVE,false)
        set clock = CreateTimer()
        set runner = CreateTimer()
        call TimerStart(clock,15.,false,function Deadline)
        call CreateScene()
        call TimerStart(runner,PERIOD,true,function Tick)
    endfunction
endlibrary
