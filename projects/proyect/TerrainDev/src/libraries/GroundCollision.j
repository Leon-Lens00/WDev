// TerrainDev Classic 1.27b. Hidden-item walkability technique: Rising_Dusk/BPower.
// Validates swept ground footprints; no mutation of actors or missile libraries.
library GroundCollision initializer Init requires WorldBounds, IsDestructableTree
struct GroundCollision extends array
    readonly static real x
    readonly static real y
    readonly static unit hit = null
    readonly static integer reason = 0 // 0 clear, 1 ground/destructible, 2 enemy
    private static item probe
    private static rect area = Rect(0.,0.,256.,256.)
    private static group targets = CreateGroup()
    private static location heightPoint = Location(0.,0.)
    private static item array hidden
    private static integer hiddenCount = 0
    private static real testX
    private static real testY
    private static real testRadius
    private static boolean destBlocked

    static method alive takes unit u returns boolean
        return GetUnitTypeId(u) != 0 and GetWidgetLife(u) > 0.405
    endmethod

    private static method hideItem takes nothing returns nothing
        local item it = GetEnumItem()
        if it != probe and IsItemVisible(it) then
            set hidden[hiddenCount] = it
            set hiddenCount = hiddenCount+1
            call SetItemVisible(it,false)
        endif
        set it = null
    endmethod

    private static method point takes real px, real py returns boolean
        local real dx
        local real dy
        if IsTerrainPathable(px,py,PATHING_TYPE_WALKABILITY) then
            return false
        endif
        call MoveRectTo(area,px,py)
        call EnumItemsInRect(area,null,function thistype.hideItem)
        call SetItemPosition(probe,px,py)
        set dx = GetItemX(probe)-px
        set dy = GetItemY(probe)-py
        call SetItemVisible(probe,false)
        loop
            exitwhen hiddenCount == 0
            set hiddenCount = hiddenCount-1
            call SetItemVisible(hidden[hiddenCount],true)
            set hidden[hiddenCount] = null
        endloop
        return dx*dx+dy*dy <= 1.
    endmethod

    private static method destructable takes nothing returns nothing
        local destructable d = GetEnumDestructable()
        local real dx = GetDestructableX(d)-testX
        local real dy = GetDestructableY(d)-testY
        if not destBlocked and GetWidgetLife(d) > 0.405 and dx*dx+dy*dy <= (testRadius+32.)*(testRadius+32.) then
            // Native pathing covers authored footprints. This also catches live
            // trees/solid tall destructibles with missing/small footprints.
            if GetDestructableOccluderHeight(d) >= 32. or IsTreeAlive(d) then
                set destBlocked = true
            endif
        endif
        set d = null
    endmethod

    static method height takes real px, real py returns real
        call MoveLocation(heightPoint,px,py)
        return GetLocationZ(heightPoint)
    endmethod

    static method clear takes real px, real py, real radius returns boolean
        local integer i = 0
        local real a
        if px-radius <= WorldBounds.minX or px+radius >= WorldBounds.maxX or py-radius <= WorldBounds.minY or py+radius >= WorldBounds.maxY then
            return false
        endif
        if not point(px,py) then
            return false
        endif
        loop
            exitwhen i == 8
            set a = I2R(i)*bj_PI/4.
            if not point(px+(radius+2.)*Cos(a),py+(radius+2.)*Sin(a)) then
                return false
            endif
            set i = i+1
        endloop
        set testX = px
        set testY = py
        set testRadius = radius
        set destBlocked = false
        call SetRect(area,px-radius-64.,py-radius-64.,px+radius+64.,py+radius+64.)
        call EnumDestructablesInRect(area,null,function thistype.destructable)
        // Restore the query rectangle size expected by the item probe.
        call SetRect(area,0.,0.,256.,256.)
        return not destBlocked
    endmethod

    static method trace takes real ax, real ay, real bx, real by, real radius, unit source, player owner, boolean units returns integer
        local real dx = bx-ax
        local real dy = by-ay
        local integer steps = R2I(SquareRoot(dx*dx+dy*dy)/8.)+1
        local integer i = 1
        local real nx
        local real ny
        local real lastZ = height(ax,ay)
        local real z
        local unit u
        set x = ax
        set y = ay
        set hit = null
        set reason = 0
        loop
            exitwhen i > steps
            set nx = ax+dx*I2R(i)/I2R(steps)
            set ny = ay+dy*I2R(i)/I2R(steps)
            set z = height(nx,ny)
            if not clear(nx,ny,radius) or RAbsBJ(z-lastZ) > 24. then
                set reason = 1
                return reason
            endif
            if units then
                call GroupEnumUnitsInRange(targets,nx,ny,radius+128.,null)
                loop
                    set u = FirstOfGroup(targets)
                    exitwhen u == null
                    call GroupRemoveUnit(targets,u)
                    if u != source and alive(u) and IsUnitEnemy(u,owner) and not IsUnitType(u,UNIT_TYPE_FLYING) and GetUnitTypeId(u) != 'dumi' and GetUnitTypeId(u) != 'dcst' and GetUnitTypeId(u) != 'rfct' then
                        if IsUnitInRangeXY(u,nx,ny,radius) then
                            set hit = u
                            set x = nx
                            set y = ny
                            set reason = 2
                            call GroupClear(targets)
                            set u = null
                            return reason
                        endif
                    endif
                endloop
            endif
            set x = nx
            set y = ny
            set lastZ = z
            set i = i+1
        endloop
        set u = null
        return 0
    endmethod

    static method initialize takes nothing returns nothing
        set probe = CreateItem('wolg',WorldBounds.minX+128.,WorldBounds.minY+128.)
        call SetItemVisible(probe,false)
    endmethod
endstruct
private function Init takes nothing returns nothing
    call GroundCollision.initialize()
endfunction
endlibrary
