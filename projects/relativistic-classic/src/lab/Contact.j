library LabContact requires LabSupport
    globals
        private item outsideItem = null
        private integer nativeCount = 0
        private integer nativeEligible = 0
        private string nativeLabel = ""
        private real nativeX = 0.
        private real nativeY = 0.
        private real nativeRadius = 0.
    endglobals

    private function NativeItem takes nothing returns nothing
        local item obj = GetEnumItem()
        local real px = GetItemX(obj)
        local real py = GetItemY(obj)
        if GetItemTypeId(obj) == RM_ITEM then
            set nativeCount = nativeCount + 1
            if RAbsBJ(px-nativeX) <= nativeRadius and RAbsBJ(py-nativeY) <= nativeRadius then
                set nativeEligible = nativeEligible + 1
            endif
            call RM_Record("OBS", nativeLabel + "-member", "item=" + I2S(GetHandleId(obj)) + " x=" + R2S(px) + " y=" + R2S(py) + " life=" + R2S(GetWidgetLife(obj)))
        endif
        set obj = null
    endfunction

    private function NativeTree takes nothing returns nothing
        local destructable obj = GetEnumDestructable()
        local real px = GetDestructableX(obj)
        local real py = GetDestructableY(obj)
        if GetDestructableTypeId(obj) == RM_TREE then
            set nativeCount = nativeCount + 1
            if RAbsBJ(px-nativeX) <= nativeRadius and RAbsBJ(py-nativeY) <= nativeRadius then
                set nativeEligible = nativeEligible + 1
            endif
            call RM_Record("OBS", nativeLabel + "-member", "tree=" + I2S(GetHandleId(obj)) + " x=" + R2S(px) + " y=" + R2S(py) + " life=" + R2S(GetWidgetLife(obj)))
        endif
        set obj = null
    endfunction

    private function NativeProbe takes real px, real py, real radius, boolean trees, string label returns nothing
        local integer pass = 0
        local real pad = 0.
        local rect area = Rect(0., 0., 0., 0.)
        set nativeX = px
        set nativeY = py
        set nativeRadius = radius
        loop
            exitwhen pass > 1
            set nativeLabel = label + "-pad" + I2S(R2I(pad))
            set nativeCount = 0
            set nativeEligible = 0
            call SetRect(area, px-radius-pad, py-radius-pad, px+radius+pad, py+radius+pad)
            if trees then
                call EnumDestructablesInRect(area, null, function NativeTree)
            else
                call EnumItemsInRect(area, null, function NativeItem)
            endif
            call RM_Record("OBS", nativeLabel, "candidates=" + I2S(nativeCount) + " eligible-original-aabb=" + I2S(nativeEligible) + " radius=" + R2S(radius))
            set pad = 128.
            set pass = pass + 1
        endloop
        call RemoveRect(area)
        set area = null
    endfunction

    struct LabContactMissile extends Missiles
        method onHit takes unit u returns boolean
            if u == RM_U then
                set RM_HITS[data] = RM_HITS[data] + 1
            endif
            return false
        endmethod
        method onItem takes item i returns boolean
            if i == RM_I then
                set RM_ITEMS[data] = RM_ITEMS[data] + 1
            elseif RM_CASE == 25 and i == outsideItem then
                set RM_ITEMS[2] = RM_ITEMS[2] + 1
            endif
            return false
        endmethod
        method onDestructable takes destructable d returns boolean
            if d == RM_D then
                set RM_DESTS[data] = RM_DESTS[data] + 1
            endif
            return false
        endmethod
        method onMissile takes Missiles other returns boolean
            if data == 1 then
                set RM_MISSILES[1] = RM_MISSILES[1] + 1
                if RM_CASE == 26 then
                    call other.terminate()
                    call terminate()
                    return false
                endif
            endif
            return false
        endmethod
        method onPeriod takes nothing returns boolean
            set RM_PERIODS[data] = RM_PERIODS[data] + 1
            return false
        endmethod
        method onRemove takes nothing returns nothing
            set RM_REMOVE[data] = RM_REMOVE[data] + 1
            set RM_DUMMY[data] = dummy
            set RM_X[data] = GetUnitX(dummy)
        endmethod
    endstruct

    function RM_ContactCreate takes integer tag, real x returns LabContactMissile
        local LabContactMissile m = LabContactMissile.create(x, 0., 100., x+2000., 0., 100.)
        call RM_Visual(m, tag)
        set m.speed = 0.
        set RM_M[tag] = m
        return m
    endfunction

    private function ObserveItem takes item obj, string label returns nothing
        local string visibility = "hidden"
        if IsItemVisible(obj) then
            set visibility = "visible"
        endif
        call RM_Record("OBS", label + "-position", "x=" + R2S(GetItemX(obj)) + " y=" + R2S(GetItemY(obj)) + " ground=" + R2S(RM_Ground(GetItemX(obj), GetItemY(obj))))
        call RM_Record("OBS", label + "-state", "rawcode=" + I2S(GetItemTypeId(obj)) + " life=" + R2S(GetWidgetLife(obj)) + " visibility=" + visibility)
        call RM_Check(GetWidgetLife(obj) > 0. and IsItemVisible(obj), label + "-live-visible", "native state; no forced visibility/life")
    endfunction

    private function ObserveTree takes destructable obj, string label returns nothing
        call RM_Record("OBS", label + "-position", "x=" + R2S(GetDestructableX(obj)) + " y=" + R2S(GetDestructableY(obj)) + " ground=" + R2S(RM_Ground(GetDestructableX(obj), GetDestructableY(obj))))
        call RM_Record("OBS", label + "-state", "rawcode=" + I2S(GetDestructableTypeId(obj)) + " life=" + R2S(GetWidgetLife(obj)) + " occluder=" + R2S(GetDestructableOccluderHeight(obj)))
        call RM_Check(GetWidgetLife(obj) > 0., label + "-live", "native life; no forced life")
    endfunction

    function RM_ContactStart takes nothing returns nothing
        local LabContactMissile a
        local LabContactMissile b
        local real px
        local real py
        local real absoluteZ
        if RM_CASE == 21 then
            set RM_I = CreateItem(RM_ITEM, 0., 0.)
            set px = GetItemX(RM_I)
            set py = GetItemY(RM_I)
            set absoluteZ = RM_Ground(px, py)+100.
            // Test Z/flush at the native item position, not its requested position.
            // Equal absolute endpoints also isolate the known impact-Z core bug.
            set a = LabContactMissile.create(px, py, 100., px+1., py, absoluteZ-RM_Ground(px+1., py))
            call RM_Visual(a, 1)
            set a.speed = 0.
            set RM_M[1] = a
        elseif RM_CASE == 24 then
            set a = LabContactMissile.create(-500., 0., 100., 2500., 0., 100.)
            call RM_Visual(a, 1)
            set RM_M[1] = a
            set a.speed = 40000.
        else
            set a = RM_ContactCreate(1, 0.)
        endif
        set a.collision = 100.
        if RM_CASE == 20 or RM_CASE == 24 then
            set RM_U = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), RM_UNIT, 0., 0., 0.)
            call PauseUnit(RM_U, true)
            call RM_Check(GetUnitTypeId(RM_U) == RM_UNIT, "unit-fixture", "ntrg from recovered CreateUnit")
        elseif RM_CASE == 21 or RM_CASE == 25 then
            if RM_CASE == 25 then
                set RM_I = CreateItem(RM_ITEM, 90., 90.)
                set outsideItem = CreateItem(RM_ITEM, 160., 0.)
                call ObserveItem(outsideItem, "outside-logical-item")
                call RM_Check(RAbsBJ(GetItemX(outsideItem)-a.x) > a.collision and RAbsBJ(GetItemX(outsideItem)-a.x) < a.collision+128., "outside-item-broadphase-only", "candidate must remain outside original square")
            else
                set a.collideZ = true
                set a.collision = 10.
                call RM_Near(a.x, GetItemX(RM_I), .01, "item-fixture-overlap-x")
                call RM_Near(a.y, GetItemY(RM_I), .01, "item-fixture-overlap-y")
                call RM_Check(a.z-a.collision > RM_Ground(GetItemX(RM_I), GetItemY(RM_I))+16., "item-fixture-z-separated", "source item extent16 below missile interval")
            endif
            call RM_Check(GetItemTypeId(RM_I) == RM_ITEM, "item-fixture", "I001 declared in w3t and recovered CreateItem")
            call ObserveItem(RM_I, "item-requested-" + I2S(RM_CASE))
        elseif RM_CASE == 22 then
            set RM_D = CreateDestructable(RM_TREE, 0., 0., 0., 1., 0)
            call RM_Check(GetDestructableTypeId(RM_D) == RM_TREE, "tree-fixture", "LTlt first recovered war3map.doo entry")
        elseif RM_CASE == 23 or RM_CASE == 26 then
            set b = RM_ContactCreate(2, 0.)
            set RM_OLD_ID = b
            call b.launch()
            if RM_CASE == 26 then
                set a.speed = 400.
                set RM_LIMIT = 4
            endif
        endif
        if RM_CASE == 24 then
            // 1000 units/tick: samples -500,+500; radius10 never reaches unit.
            set a.collision = 10.
        endif
        if RM_CASE == 21 or RM_CASE == 25 then
            call NativeProbe(a.x, a.y, a.collision, false, "native-before-original")
        endif
        call a.launch()
    endfunction

    function RM_ContactStep takes nothing returns nothing
        local LabContactMissile a = RM_M[1]
        local LabContactMissile c
        if RM_STAGE == 1 then
            if RM_CASE == 20 then
                call RM_Equal(RM_HITS[1], 1, "unit-hit-once")
                call RM_Check(a.hitted(RM_U), "hitted-public", "unit recorded")
                call a.flush(RM_U)
                call RM_Check(not a.hitted(RM_U), "flush-widget", "unit forgotten immediately")
            elseif RM_CASE == 21 then
                call RM_Equal(RM_ITEMS[1], 0, "item-z-rejection")
                set a.collideZ = false
            elseif RM_CASE == 22 then
                call RM_Equal(RM_DESTS[1], 1, "tree-hit-once")
                call RM_Check(a.hitted(RM_D), "tree-hit-memory", "widget recorded")
                call a.flush(RM_D)
            elseif RM_CASE == 23 then
                call RM_Equal(RM_MISSILES[1], 1, "missile-hit-once")
                call RM_M[2].terminate()
            endif
        elseif RM_STAGE == 2 then
            if RM_CASE == 20 then
                call RM_Equal(RM_HITS[1], 2, "unit-rehit-after-flush")
                call a.flushAll()
                call RM_Check(not a.hitted(RM_U), "flush-all-memory", "unit forgotten")
            elseif RM_CASE == 21 then
                call RM_Equal(RM_ITEMS[1], 1, "item-hit-no-z")
                call RM_Check(a.hitted(RM_I), "item-hit-memory", "widget recorded")
                call a.flush(RM_I)
            elseif RM_CASE == 23 then
                set c = RM_ContactCreate(3, 0.)
                set RM_NEW_ID = c
                call c.launch()
                call RM_Equal(RM_NEW_ID, RM_OLD_ID, "allocator-reuse-fixture")
            endif
        elseif RM_STAGE == 3 then
            if RM_CASE == 23 then
                call RM_Equal(RM_MISSILES[1], 2, "new-generation-must-hit-persistent-A")
                call a.flushAll()
            endif
        endif
        if RM_STAGE == RM_LIMIT then
            if RM_CASE == 20 then
                call RM_Equal(RM_HITS[1], 3, "unit-flush-all-rehit")
            elseif RM_CASE == 21 then
                call RM_Equal(RM_ITEMS[1], 2, "item-flush-rehit")
            elseif RM_CASE == 22 then
                call RM_Equal(RM_DESTS[1], 2, "tree-flush-rehit")
            elseif RM_CASE == 23 then
                // Baseline 2 here means flush repaired stale identity; still fails prior rule.
                call RM_Equal(RM_MISSILES[1], 3, "missile-flush-all-rehit")
            elseif RM_CASE == 24 then
                call RM_Equal(RM_HITS[1], 0, "point-sampled-fast-crossing")
                call RM_Record("OBS", "not-swept", "current API samples positions; swept crossing guarantee is not provided")
            elseif RM_CASE == 25 then
                call RM_Equal(RM_ITEMS[1], 1, "rectangle-corner-item")
                call RM_Record("OBS", "square-not-circle", "90,90 lies inside radius100 rectangle but outside circle")
                call RM_Equal(RM_ITEMS[2], 0, "outside-logical-item-rejected")
                call RemoveItem(outsideItem)
                set outsideItem = null
            elseif RM_CASE == 26 then
                call RM_Equal(RM_REMOVE[1], 1, "enumerator-self-remove-once")
                call RM_Equal(RM_REMOVE[2], 1, "enumerator-other-remove-once")
                call RM_Equal(RM_MISSILES[1], 1, "enumerator-callback-once")
                call RM_Near(GetUnitX(RM_DUMMY[1]), RM_X[1], .01, "enumerator-no-post-remove-dummy-write")
                call RM_Near(a.x, RM_X[1], .01, "enumerator-no-post-remove-public-write")
            endif
        endif
    endfunction

    globals
        private unit array ruleUnits
        private item array ruleItems
        private destructable array ruleTrees
        private Missiles array ruleBodies
        private integer array originalHits
        private integer array freshHits
        private integer firstHit = 0
        private integer contactKind = 0
        private boolean explicitFalse = false
        private real fixtureBottom = 0.
        private real fixtureTop = 0.
        private real fixtureX = 0.
        private real fixtureY = 0.
        private real fixtureRadius = 10.
    endglobals

    private function RuleContact takes Missiles m, integer index returns boolean
        if index == 0 then
            return false
        endif
        if m.data == 1 then
            set originalHits[index] = originalHits[index] + 1
            set firstHit = index
            if explicitFalse then
                call m.terminate()
                return false
            endif
            return true
        elseif m.data == 2 then
            set freshHits[index] = freshHits[index] + 1
        endif
        return false
    endfunction

    struct LabContactRule extends Missiles
        method onHit takes unit u returns boolean
            local integer i = 1
            loop
                exitwhen i > 3
                if u == ruleUnits[i] then
                    if RM_CASE == 35 then
                        set RM_HITS[data] = RM_HITS[data] + 1
                        return false
                    endif
                    return RuleContact(this, i)
                endif
                set i = i + 1
            endloop
            return false
        endmethod
        method onItem takes item obj returns boolean
            local integer i = 1
            loop
                exitwhen i > 3
                if obj == ruleItems[i] then
                    return RuleContact(this, i)
                endif
                set i = i + 1
            endloop
            return false
        endmethod
        method onDestructable takes destructable obj returns boolean
            local integer i = 1
            loop
                exitwhen i > 3
                if obj == ruleTrees[i] then
                    if RM_CASE == 36 then
                        set RM_HITS[data] = RM_HITS[data] + 1
                        return false
                    endif
                    return RuleContact(this, i)
                endif
                set i = i + 1
            endloop
            return false
        endmethod
        method onMissile takes Missiles other returns boolean
            local integer i = 1
            loop
                exitwhen i > 3
                if other == ruleBodies[i] then
                    return RuleContact(this, i)
                endif
                set i = i + 1
            endloop
            return false
        endmethod
        method onRemove takes nothing returns nothing
            set RM_REMOVE[data] = RM_REMOVE[data] + 1
        endmethod
    endstruct

    private function RuleCreate takes integer tag, real absoluteZ returns LabContactRule
        // Flat absolute endpoints isolate collision from unequal-height core bugs.
        local LabContactRule m = LabContactRule.create(fixtureX, fixtureY, absoluteZ-RM_Ground(fixtureX, fixtureY), fixtureX+1., fixtureY, absoluteZ-RM_Ground(fixtureX+1., fixtureY))
        call RM_Visual(m, tag)
        set m.speed = 0.
        set m.collision = fixtureRadius
        set RM_M[tag] = m
        return m
    endfunction

    private function RemoveRuleFixture takes integer i returns nothing
        if ruleUnits[i] != null then
            call RemoveUnit(ruleUnits[i])
            set ruleUnits[i] = null
        endif
        if ruleItems[i] != null then
            call RemoveItem(ruleItems[i])
            set ruleItems[i] = null
        endif
        if ruleTrees[i] != null then
            call RemoveDestructable(ruleTrees[i])
            set ruleTrees[i] = null
        endif
        if ruleBodies[i] != 0 then
            call ruleBodies[i].terminate()
            set ruleBodies[i] = 0
        endif
    endfunction

    function RM_ContactRuleCleanup takes nothing returns nothing
        local integer i = 1
        loop
            exitwhen i > 3
            call RemoveRuleFixture(i)
            set i = i + 1
        endloop
    endfunction

    private function BoundaryProbe takes integer tag returns nothing
        local real height
        local LabContactRule m
        if tag == 1 then
            set height = fixtureTop + 10.
        elseif tag == 2 then
            set height = fixtureTop + 10.125
        elseif tag == 3 then
            set height = fixtureBottom - 10.
        else
            set height = fixtureBottom - 10.125
        endif
        set m = RuleCreate(tag, height)
        set m.collideZ = true
        call RM_Near(m.z, height, .01, "boundary-fixture-absolute-z-" + I2S(tag))
        call m.launch()
    endfunction

    function RM_ContactRuleStart takes nothing returns nothing
        local integer i = 1
        local integer count = 3
        local LabContactRule m
        local real px
        local real py
        set firstHit = 0
        set fixtureX = 0.
        set fixtureY = 0.
        set fixtureRadius = 10.
        set RM_LIMIT = 4
        set explicitFalse = RM_CASE == 38 or RM_CASE == 40 or RM_CASE == 42 or RM_CASE == 44
        if RM_CASE == 35 or RM_CASE == 37 or RM_CASE == 38 then
            set contactKind = 1
        elseif RM_CASE == 39 or RM_CASE == 40 then
            set contactKind = 2
        elseif RM_CASE == 36 or RM_CASE == 41 or RM_CASE == 42 then
            set contactKind = 3
        else
            set contactKind = 4
        endif
        if RM_CASE == 35 or RM_CASE == 36 then
            set count = 1
        endif
        loop
            exitwhen i > 3
            set originalHits[i] = 0
            set freshHits[i] = 0
            if i <= count then
                if contactKind == 1 then
                    set ruleUnits[i] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), RM_UNIT, 0., 0., 0.)
                    call PauseUnit(ruleUnits[i], true)
                    call SetUnitX(ruleUnits[i], 0.)
                    call SetUnitY(ruleUnits[i], 0.)
                    call RM_Equal(GetUnitTypeId(ruleUnits[i]), RM_UNIT, "rule-unit-fixture-" + I2S(i))
                elseif contactKind == 2 then
                    set ruleItems[i] = CreateItem(RM_ITEM, 0., 0.)
                    call RM_Equal(GetItemTypeId(ruleItems[i]), RM_ITEM, "rule-item-fixture-" + I2S(i))
                    call ObserveItem(ruleItems[i], "rule-item-requested-0-0-" + I2S(i))
                    set px = GetItemX(ruleItems[i])
                    set py = GetItemY(ruleItems[i])
                    // Lifetime tests need all three inside the SAME enumeration.
                    // Radius is derived from native positions, never callback results.
                    set fixtureRadius = RMaxBJ(fixtureRadius, RMaxBJ(RAbsBJ(px), RAbsBJ(py))+1.)
                elseif contactKind == 3 then
                    set ruleTrees[i] = CreateDestructable(RM_TREE, 0., 0., 0., 1., 0)
                    call RM_Equal(GetDestructableTypeId(ruleTrees[i]), RM_TREE, "rule-tree-fixture-" + I2S(i))
                    call ObserveTree(ruleTrees[i], "rule-tree-requested-0-0-" + I2S(i))
                    set px = GetDestructableX(ruleTrees[i])
                    set py = GetDestructableY(ruleTrees[i])
                    if RM_CASE == 36 then
                        set fixtureX = px
                        set fixtureY = py
                    else
                        set fixtureRadius = RMaxBJ(fixtureRadius, RMaxBJ(RAbsBJ(px), RAbsBJ(py))+1.)
                    endif
                else
                    set m = RuleCreate(9+i, RM_Ground(0., 0.)+100.)
                    set m.collision = 0.
                    set ruleBodies[i] = m
                    call m.launch()
                endif
            endif
            set i = i + 1
        endloop
        call RM_Record("OBS", "rule-enumeration-geometry", "x=" + R2S(fixtureX) + " y=" + R2S(fixtureY) + " radius=" + R2S(fixtureRadius))
        if RM_CASE == 36 then
            set ruleTrees[2] = CreateDestructable(RM_TREE, fixtureX+96., fixtureY, 0., 1., 0)
            call ObserveTree(ruleTrees[2], "outside-logical-tree")
            call RM_Check(RAbsBJ(GetDestructableX(ruleTrees[2])-fixtureX) > fixtureRadius and RAbsBJ(GetDestructableX(ruleTrees[2])-fixtureX) < fixtureRadius+128., "outside-tree-broadphase-only", "boundary counts must exclude expanded-only candidate")
        endif
        if contactKind == 2 or contactKind == 3 then
            call NativeProbe(fixtureX, fixtureY, fixtureRadius, contactKind == 3, "native-before-original")
        endif
        set fixtureBottom = RM_Ground(fixtureX, fixtureY)
        if RM_CASE == 35 then
            set fixtureBottom = fixtureBottom + GetUnitFlyHeight(ruleUnits[1])
            // Recovered Classic API explicitly uses a fixed64 unit vertical extent.
            set fixtureTop = fixtureBottom + 64.
            call BoundaryProbe(1)
        elseif RM_CASE == 36 then
            // Source onDest: dz=terrain at actual widget XY; tz=occluder height.
            // dz+tz >= missileZ-radius AND dz <= missileZ+radius (inclusive).
            set fixtureTop = fixtureBottom + GetDestructableOccluderHeight(ruleTrees[1])
            call RM_Record("OBS", "tree-z-interval", "bottom=" + R2S(fixtureBottom) + " top=" + R2S(fixtureTop) + " radius=10")
            call BoundaryProbe(1)
        else
            set m = RuleCreate(1, fixtureBottom+100.)
            set RM_OLD_ID = m
            call m.launch()
        endif
    endfunction

    function RM_ContactRuleStep takes nothing returns nothing
        local integer i = 1
        local integer total = 0
        local integer expected
        local LabContactRule m
        if RM_CASE == 35 or RM_CASE == 36 then
            if RM_STAGE == 1 or RM_STAGE == 3 then
                set expected = 1
            else
                set expected = 0
            endif
            call RM_Equal(RM_HITS[RM_STAGE], expected, "vertical-boundary-probe-" + I2S(RM_STAGE))
            call RM_M[RM_STAGE].terminate()
            if RM_STAGE < 4 then
                call BoundaryProbe(RM_STAGE+1)
            endif
            return
        endif
        if RM_STAGE == 1 then
            loop
                exitwhen i > 3
                set total = total + originalHits[i]
                set i = i + 1
            endloop
            call RM_Equal(total, 1, "first-contact-only")
            call RM_Equal(RM_REMOVE[1], 1, "contact-remove-once")
            call RM_Check(firstHit >= 1 and firstHit <= 3, "first-contact-fixture", "enumeration order irrelevant")
            if firstHit >= 1 and firstHit <= 3 then
                call RemoveRuleFixture(firstHit)
            endif
            // .25 seconds later: scheduler has retired the original, not reentry.
            set m = RuleCreate(2, fixtureBottom+100.)
            call RM_Equal(m, RM_OLD_ID, "retired-contact-id-reused")
            if contactKind == 2 or contactKind == 3 then
                call NativeProbe(fixtureX, fixtureY, fixtureRadius, contactKind == 3, "native-before-fresh")
            endif
            call m.launch()
        elseif RM_STAGE == 2 then
            loop
                exitwhen i > 3
                if i == firstHit then
                    set expected = 0
                else
                    set expected = 1
                endif
                call RM_Equal(freshHits[i], expected, "fresh-public-contact-remaining-" + I2S(i))
                set total = total + freshHits[i]
                set i = i + 1
            endloop
            call RM_Equal(total, 2, "fresh-hits-both-remaining")
        elseif RM_STAGE == 3 then
            call RM_M[2].terminate()
        else
            call RM_Equal(RM_REMOVE[1], 1, "retired-contact-remove-still-once")
            call RM_Equal(RM_REMOVE[2], 1, "fresh-contact-remove-once")
        endif
    endfunction
endlibrary
