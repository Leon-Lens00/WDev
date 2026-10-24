library RFNativeReference requires RFProbeLog
    globals
        private unit reference = null
        private unit removedReference = null
        private group clearance = null
        private real goalX = 0.
        private real goalY = 0.
        private real startX = 0.
        private real startY = 0.
        private real previousX = 0.
        private real previousY = 0.
        private real actualRestX = 0.
        private real actualRestY = 0.
        private boolean moveAccepted = false
        private integer stableSamples = 0
        private integer waits = 0
        private real transitX
        private real transitY
        private boolean transitBefore = false
        private boolean transitWindow = false
        private boolean transitAfter = false
        private boolean transitDetour = false
    endglobals

    function RF_ReferenceInit takes nothing returns nothing
        set clearance = CreateGroup()
    endfunction

    function RF_ReferenceRemove takes nothing returns nothing
        if reference != null then
            call RF_Record("OBS","reference-before-removal","actual="+R2S(GetUnitX(reference))+","+R2S(GetUnitY(reference)))
            set removedReference = reference
            call RemoveUnit(reference)
            set reference = null
        endif
    endfunction

    function RF_ReferenceClear takes real x, real y returns boolean
        local unit u
        local boolean clear = true
        if removedReference != null then
            call GroupEnumUnitsInRange(clearance,x,y,2048.,null)
            loop
                set u = FirstOfGroup(clearance)
                exitwhen u == null
                call GroupRemoveUnit(clearance,u)
                if u == removedReference then
                    set clear = false
                endif
            endloop
            set clear = clear and GetUnitTypeId(removedReference)==0
            call RF_Check(clear,"public-reference-clearance","removedType="+I2S(GetUnitTypeId(removedReference))+" presentInNativeGroup="+RF_Bool(not clear))
            if clear then
                set removedReference = null
            endif
        endif
        set u = null
        return clear
    endfunction

    // Spawn-placement data ONLY, never native walkability/transit evidence.
    // Remove immediately; caller waits a tick and public clearance before query.
    function RF_PlacementAt takes real x, real y returns boolean
        local boolean ready
        set reference = CreateUnit(Player(0),'o000',x,y,0.)
        set ready = GetUnitTypeId(reference)=='o000' and RAbsBJ(GetUnitX(reference)-x)<=1. and RAbsBJ(GetUnitY(reference)-y)<=1.
        call RF_Record("OBS","native-spawn-placement","wanted="+R2S(x)+","+R2S(y)+" actual="+R2S(GetUnitX(reference))+","+R2S(GetUnitY(reference))+" placed="+RF_Bool(ready)+" flying="+RF_Bool(IsUnitType(reference,UNIT_TYPE_FLYING))+" order="+I2S(GetUnitCurrentOrder(reference)))
        call RF_ReferenceRemove()
        return ready
    endfunction

    function RF_ReferenceMove takes real x, real y returns boolean
        local boolean startReady
        set goalX = x
        set goalY = y
        set waits = 0
        set stableSamples = 0
        set actualRestX = 0.
        set actualRestY = 0.
        set moveAccepted = false
        set reference = CreateUnit(Player(0),'o000',x-64.,y,0.)
        set startX = GetUnitX(reference)
        set startY = GetUnitY(reference)
        set previousX = startX
        set previousY = startY
        set startReady = GetUnitTypeId(reference)=='o000' and GetWidgetLife(reference)>.405 and RAbsBJ(startX-(x-64.))<=1. and RAbsBJ(startY-y)<=1.
        if startReady then
            set moveAccepted = IssuePointOrder(reference,"move",x,y)
        endif
        call RF_Record("OBS","native-reference-move-start","actualStart="+R2S(startX)+","+R2S(startY)+" nominalGoal="+R2S(x)+","+R2S(y)+" startReady="+RF_Bool(startReady)+" orderAccepted="+RF_Bool(moveAccepted))
        if not startReady or not moveAccepted then
            call RF_Record("FAIL","native-reference-start-abort","strict start placement or native Move acceptance failed")
            return false
        endif
        return true
    endfunction

    // 0=pending,1=ACTUAL occupied rest captured,-1=failed readiness. No nominal
    // goal-distance admission or widened arrival tolerance. Three unchanged XY
    // intervals with native order0 must follow an accepted, displaced Move.
    function RF_ReferencePoll takes nothing returns integer
        local real x = GetUnitX(reference)
        local real y = GetUnitY(reference)
        local real dx = x-startX
        local real dy = y-startY
        local integer order = GetUnitCurrentOrder(reference)
        set waits = waits+1
        if GetUnitTypeId(reference)!='o000' or GetWidgetLife(reference)<=.405 then
            call RF_Record("FAIL","native-reference-invalid-abort","nativeType="+I2S(GetUnitTypeId(reference))+" life="+R2S(GetWidgetLife(reference)))
            call RF_ReferenceRemove()
            return -1
        endif
        if order==0 and x==previousX and y==previousY then
            set stableSamples = stableSamples+1
        else
            set stableSamples = 0
        endif
        set previousX = x
        set previousY = y
        call RF_Record("OBS","native-reference-rest-sample","actual="+R2S(x)+","+R2S(y)+" nominalError="+R2S(x-goalX)+","+R2S(y-goalY)+" order="+I2S(order)+" stable="+I2S(stableSamples)+" elapsed="+R2S(waits*.125))
        if moveAccepted and order==0 and stableSamples>=3 then
            if dx*dx+dy*dy<=0. then
                call RF_Record("FAIL","native-reference-zero-displacement","actual="+R2S(x)+","+R2S(y)+" status=stable-but-not-moved")
                call RF_ReferenceRemove()
                return -1
            endif
            // x/y were read from the LIVE native reference in this callback,
            // before removal. Neither candidate eligibility nor nominal goal
            // supplies these values. Rest certifies ONLY this occupied point.
            set actualRestX = x
            set actualRestY = y
            call RF_Record("OBS","native-rest-anchor","nominalGoal="+R2S(goalX)+","+R2S(goalY)+" actualRest="+R2S(actualRestX)+","+R2S(actualRestY)+" error="+R2S(x-goalX)+","+R2S(y-goalY)+" order="+I2S(order)+" status=stable-native-occupied")
            call RF_Record("OBS","native-rest-provenance","source=live-reference-GetUnitXY-before-removal start="+R2S(startX)+","+R2S(startY)+" displacementSquared="+R2S(dx*dx+dy*dy)+" stableIntervals="+I2S(stableSamples))
            call RF_ReferenceRemove()
            return 1
        endif
        if waits >= 15 then
            call RF_Record("FAIL","native-reference-rest-deadline","actual="+R2S(x)+","+R2S(y)+" order="+I2S(order)+" displacementSquared="+R2S(dx*dx+dy*dy)+" stable="+I2S(stableSamples)+" elapsed=1.875")
            call RF_ReferenceRemove()
            return -1
        endif
        return 0
    endfunction

    // Read only after RF_ReferencePoll returns1. These are captured native XY,
    // not an estimator and not a fallback to the requested goal.
    function RF_ReferenceRestX takes nothing returns real
        return actualRestX
    endfunction

    function RF_ReferenceRestY takes nothing returns real
        return actualRestY
    endfunction

    private function TransitFinish takes string reason, boolean observed returns integer
        call RF_Record("OBS","native-transit-summary","status="+reason+" before="+RF_Bool(transitBefore)+" window="+RF_Bool(transitWindow)+" after="+RF_Bool(transitAfter)+" detour="+RF_Bool(transitDetour))
        call RF_ReferenceRemove()
        if observed then
            return 1
        endif
        return -1
    endfunction

    // Separate normal-pathing Shaman, NEVER actor or Missiles.dummy. The goal
    // is128 beyond the tested point; exact goal arrival is not required.
    function RF_TransitStart takes real x, real y returns boolean
        local boolean ready
        local real speed
        set transitX = x
        set transitY = y
        set waits = 0
        set transitWindow = false
        set transitAfter = false
        set transitDetour = false
        set reference = CreateUnit(Player(0),'o000',x-128.,y,0.)
        set startX = GetUnitX(reference)
        set startY = GetUnitY(reference)
        set previousX = startX
        set goalX = x+128.
        set transitBefore = startX<x-16.
        // Speed change belongs ONLY to this disposable movement reference.
        call SetUnitMoveSpeed(reference,160.)
        set speed = GetUnitMoveSpeed(reference)
        set ready = GetUnitTypeId(reference)=='o000' and GetWidgetLife(reference)>.405 and RAbsBJ(startX-(x-128.))<=1. and RAbsBJ(startY-y)<=1. and speed>0. and speed<=192.
        set moveAccepted = false
        if ready then
            set moveAccepted = IssuePointOrder(reference,"move",goalX,y)
        endif
        call RF_Record("OBS","native-transit-start","actual="+R2S(startX)+","+R2S(startY)+" goal="+R2S(goalX)+","+R2S(y)+" speed="+R2S(speed)+" accepted="+RF_Bool(moveAccepted))
        call RF_Record("OBS","native-transit-criteria","point="+R2S(x)+","+R2S(y)+" windowX=16 corridorY=8 dt=.125 deadline=3; observed poses only, no chord/arrival proof")
        if not ready or not moveAccepted then
            call TransitFinish("unavailable-start",false)
            return false
        endif
        return true
    endfunction

    // 0=pending,1=observed before/window/after poses,-1=unavailable transit.
    // No interpolation, inferred blocked point, exact arrival or continuous proof.
    function RF_TransitPoll takes nothing returns integer
        local real x = GetUnitX(reference)
        local real y = GetUnitY(reference)
        local real dx = x-startX
        local real dy = y-startY
        local integer order = GetUnitCurrentOrder(reference)
        set waits = waits+1
        call RF_Record("OBS","native-transit-pose","actual="+R2S(x)+","+R2S(y)+" order="+I2S(order)+" elapsed="+R2S(waits*.125)+" displacementSquared="+R2S(dx*dx+dy*dy))
        if GetUnitTypeId(reference)!='o000' or GetWidgetLife(reference)<=.405 then
            return TransitFinish("unavailable-reference",false)
        endif
        if RAbsBJ(y-transitY)>8. or x<startX-1. or x>goalX+1. or x<previousX-1. then
            set transitDetour = true
        endif
        set previousX = x
        if order==OrderId("move") and RAbsBJ(x-transitX)<=16. and RAbsBJ(y-transitY)<=8. and dx*dx+dy*dy>0. then
            set transitWindow = true
        endif
        if x>transitX+16. and RAbsBJ(y-transitY)<=8. then
            set transitAfter = true
        endif
        if transitDetour then
            return TransitFinish("unavailable-observed-detour",false)
        elseif transitBefore and transitWindow and transitAfter then
            return TransitFinish("observed-poses-through-window-not-continuous",true)
        elseif order==0 or waits>=24 then
            return TransitFinish("unavailable-stop-or-deadline-not-blocked-proof",false)
        endif
        return 0
    endfunction

    function RF_ReferenceCleanup takes nothing returns nothing
        call RF_ReferenceRemove()
        if removedReference != null then
            call RemoveUnit(removedReference)
            call RF_Check(GetUnitTypeId(removedReference)==0,"reference-abort-cleanup","remainingType="+I2S(GetUnitTypeId(removedReference)))
        endif
        call DestroyGroup(clearance)
        set clearance = null
        set removedReference = null
    endfunction
endlibrary
