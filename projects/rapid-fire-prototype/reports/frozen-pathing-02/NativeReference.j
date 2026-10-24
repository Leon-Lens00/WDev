library RFNativeReference requires RFProbeLog
    globals
        private unit reference = null
        private unit removedReference = null
        private group clearance = null
        private real goalX = 0.
        private real goalY = 0.
        private integer waits = 0
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

    // Independent body occupancy, not a call to the collision candidate. Each
    // probe is removed immediately; caller waits a timer tick then checks clear.
    function RF_BodyOccupies takes real x, real y returns boolean
        local boolean ready
        set reference = CreateUnit(Player(0),'o000',x,y,0.)
        set ready = GetUnitTypeId(reference)=='o000' and RAbsBJ(GetUnitX(reference)-x)<=1. and RAbsBJ(GetUnitY(reference)-y)<=1.
        call RF_Record("OBS","native-body-occupancy","wanted="+R2S(x)+","+R2S(y)+" actual="+R2S(GetUnitX(reference))+","+R2S(GetUnitY(reference))+" occupies="+RF_Bool(ready)+" flying="+RF_Bool(IsUnitType(reference,UNIT_TYPE_FLYING))+" order="+I2S(GetUnitCurrentOrder(reference)))
        call RF_ReferenceRemove()
        return ready
    endfunction

    function RF_ReferenceMove takes real x, real y returns boolean
        set goalX = x
        set goalY = y
        set waits = 0
        set reference = CreateUnit(Player(0),'o000',x-64.,y,0.)
        call RF_Record("OBS","native-reference-move-start","actual="+R2S(GetUnitX(reference))+","+R2S(GetUnitY(reference))+" goal="+R2S(x)+","+R2S(y))
        return GetUnitTypeId(reference)=='o000' and RAbsBJ(GetUnitX(reference)-(x-64.))<=1. and RAbsBJ(GetUnitY(reference)-y)<=1. and IssuePointOrder(reference,"move",x,y)
    endfunction

    // 0=pending,1=arrived,-1=deadline. Arrival within8 proves native movement
    // into the vicinity; a separate exact body-occupancy probe follows it.
    function RF_ReferencePoll takes nothing returns integer
        local real dx = GetUnitX(reference)-goalX
        local real dy = GetUnitY(reference)-goalY
        set waits = waits+1
        call RF_Record("OBS","native-reference-move-sample","actual="+R2S(GetUnitX(reference))+","+R2S(GetUnitY(reference))+" order="+I2S(GetUnitCurrentOrder(reference))+" elapsed="+R2S(waits*.125))
        if dx*dx+dy*dy <= 64. then
            call RF_ReferenceRemove()
            return 1
        endif
        if waits >= 15 then
            call RF_ReferenceRemove()
            return -1
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
