library RFPathingCandidate requires RFProbeLog
    globals
        // EXPERIMENT, not an engine-certified mover. Square samples deliberately
        // overapproximate stock radius16. Gaps/thin blockers may still defeat it.
        private constant real RADIUS = 16.
        private constant real MAX_STEP = 350.*.03125
        private item probe = null
        private rect bounds = null
        private item array savedItems
        private boolean array savedVisible
        private integer savedCount = 0
        private boolean overflow = false
        private group nearby = null
    endglobals

    function RF_PathInit takes nothing returns nothing
        set bounds = GetWorldBounds()
        set nearby = CreateGroup()
        set probe = CreateItem('ratf', 0., 0.)
        call SetItemVisible(probe, false)
    endfunction

    private function Gather takes nothing returns nothing
        local item it = GetEnumItem()
        if it != probe then
            if savedCount < 128 then
                set savedItems[savedCount] = it
                set savedVisible[savedCount] = IsItemVisible(it)
                set savedCount = savedCount + 1
            else
                set overflow = true
            endif
        endif
        set it = null
    endfunction

    private function Point takes real x, real y returns boolean
        local rect area = Rect(x-256., y-256., x+256., y+256.)
        local integer i = 0
        local real dx
        local real dy
        local boolean blocked = IsTerrainPathable(x,y,PATHING_TYPE_WALKABILITY)
        local boolean result
        set savedCount = 0
        set overflow = false
        call EnumItemsInRect(area, null, function Gather)
        loop
            exitwhen i >= savedCount
            call SetItemVisible(savedItems[i], false)
            set i = i + 1
        endloop
        call SetItemPosition(probe,x,y)
        set dx = GetItemX(probe)-x
        set dy = GetItemY(probe)-y
        // Tolerance1 is a conservative candidate, not the published tolerance10
        // point heuristic or an unsigned Manhattan expression.
        set result = not overflow and not blocked and dx*dx+dy*dy <= 1.
        call RF_Record("OBS", "native-item-point", "wanted="+R2S(x)+","+R2S(y)+" actual="+R2S(GetItemX(probe))+","+R2S(GetItemY(probe))+" walkBlocked="+RF_Bool(blocked)+" nearby="+I2S(savedCount)+" overflow="+RF_Bool(overflow))
        set i = 0
        loop
            exitwhen i >= savedCount
            call SetItemVisible(savedItems[i],savedVisible[i])
            set savedItems[i] = null
            set i = i + 1
        endloop
        call RemoveRect(area)
        set area = null
        return result
    endfunction

    function RF_Eligible takes unit actor, unit controller, real x, real y returns boolean
        local integer i = -1
        local integer j
        local boolean result = true
        local unit u
        local boolean overlap
        // Stay inside actual world bounds with the whole sampled footprint.
        if x-RADIUS < GetRectMinX(bounds) or y-RADIUS < GetRectMinY(bounds) or x+RADIUS > GetRectMaxX(bounds) or y+RADIUS > GetRectMaxY(bounds) then
            call RF_Record("OBS", "native-bounds", "x="+R2S(x)+" y="+R2S(y)+" min="+R2S(GetRectMinX(bounds))+","+R2S(GetRectMinY(bounds))+" max="+R2S(GetRectMaxX(bounds))+","+R2S(GetRectMaxY(bounds)))
            return false
        endif
        loop
            exitwhen i > 1
            set j = -1
            loop
                exitwhen j > 1
                if not Point(x+i*RADIUS,y+j*RADIUS) then
                    set result = false
                endif
                set j = j + 1
            endloop
            set i = i + 1
        endloop
        // Bounded fixture broadphase, NOT universal arbitrary-building support.
        // Native IsUnitInRangeXY footprint semantics are measured, not assumed.
        call GroupEnumUnitsInRange(nearby,x,y,600.,null)
        loop
            set u = FirstOfGroup(nearby)
            exitwhen u == null
            call GroupRemoveUnit(nearby,u)
            if u != actor and u != controller and GetWidgetLife(u) > .405 and not IsUnitType(u,UNIT_TYPE_FLYING) and GetUnitAbilityLevel(u,'Aloc') == 0 then
                set overlap = IsUnitInRangeXY(u,x,y,RADIUS)
                call RF_Record("OBS", "native-unit-range", "id="+I2S(GetUnitTypeId(u))+" actual="+R2S(GetUnitX(u))+","+R2S(GetUnitY(u))+" query="+R2S(x)+","+R2S(y)+" range16="+RF_Bool(overlap)+" order="+I2S(GetUnitCurrentOrder(u)))
                if overlap then
                    set result = false
                endif
            endif
        endloop
        set u = null
        return result
    endfunction

    function RF_TryStep takes unit actor, unit controller, real x, real y returns boolean
        local real ax = GetUnitX(actor)
        local real ay = GetUnitY(actor)
        local real dx = x-ax
        local real dy = y-ay
        local integer i = 1
        // At most two <=5.469-unit samples. Validate the entire short step BEFORE
        // writing actor XY, so a rejected call does not partially translate it.
        if dx*dx+dy*dy > MAX_STEP*MAX_STEP then
            return false
        endif
        loop
            exitwhen i > 2
            if not RF_Eligible(actor,controller,ax+dx*i*.5,ay+dy*i*.5) then
                return false
            endif
            set i = i + 1
        endloop
        call SetUnitX(actor,x)
        call SetUnitY(actor,y)
        return true
    endfunction

    function RF_PathCleanup takes nothing returns nothing
        call RemoveItem(probe)
        call DestroyGroup(nearby)
        call RemoveRect(bounds)
        set probe = null
        set nearby = null
        set bounds = null
    endfunction
endlibrary
