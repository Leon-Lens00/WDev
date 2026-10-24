// Plain JASS adapter. Only actual public lowered methods, never library arrays.
function IL_Flush takes nothing returns boolean
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    loop
        exitwhen i >= IL_LineCount
        call Preload(IL_Lines[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("Logs\\IL141-" + IL_RUN + ".pld")
    return true
endfunction

function IL_Safe takes string text returns boolean
    local integer i = 0
    local string c
    if StringLength(text) < 1 or StringLength(text) > 160 then
        return false
    endif
    loop
        exitwhen i >= StringLength(text)
        // Callers supply fixed ASCII literals plus I2S only; reject delimiters
        // defensively without a costly nested whitelist loop in the case thread.
        set c = SubString(text, i, i+1)
        if c == "|" or c == "\"" or c == "\\" or c == "\n" or c == "\r" then
            return false
        endif
        set i = i + 1
    endloop
    return true
endfunction

function IL_Log takes string kind, string payload returns nothing
    if IL_LogFault then
        return
    endif
    if IL_LineCount >= 512 or not IL_Safe(payload) then
        set IL_LogFault = true
        return
    endif
    set IL_LineCount = IL_LineCount + 1
    set IL_Lines[IL_LineCount-1] = "IL141|" + IL_RUN + "|" + I2S(IL_LineCount) + "|" + kind + "|" + IL_Current + "|" + payload
    // Persistence has its own trigger-condition operation budget.
    call TriggerEvaluate(IL_Persist)
endfunction

function IL_Record takes string status, string detail returns nothing
    if status == "PASS" then
        set IL_Pass = IL_Pass + 1
        set IL_CP = IL_CP + 1
    elseif status == "FAIL" then
        set IL_Fail = IL_Fail + 1
        set IL_CF = IL_CF + 1
    elseif status == "OBS" then
        set IL_Obs = IL_Obs + 1
        set IL_CO = IL_CO + 1
    elseif status == "SKIP" then
        set IL_Skip = IL_Skip + 1
        set IL_CS = IL_CS + 1
    endif
    call IL_Log(status, detail)
endfunction

function IL_Check takes boolean ok, string detail returns nothing
    if ok then
        call IL_Record("PASS", detail)
    else
        call IL_Record("FAIL", detail)
    endif
endfunction

function IL_CountText takes integer p, integer f, integer o, integer s returns string
    return "pass=" + I2S(p) + " fail=" + I2S(f) + " obs=" + I2S(o) + " skip=" + I2S(s)
endfunction

function IL_Snapshot takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= 150
        set IL_Saved[i] = s__Inventory_getItem(IL_Inv, i)
        set IL_Custom[i] = s__Inventory_getItemId(IL_Inv, i)
        set i = i + 1
    endloop
    set IL_SavedCount = s__Inventory_itemsOfType(IL_Inv, 'rst1')
    set IL_SavedZero = s__Inventory_itemsOfType(IL_Inv, 0)
    set IL_SavedStr = GetHeroStr(IL_Hero, true)
    set IL_SavedAgi = GetHeroAgi(IL_Hero, true)
    set IL_SavedInt = GetHeroInt(IL_Hero, true)
endfunction

function IL_InventoryUnchanged takes nothing returns boolean
    local integer i = 0
    loop
        exitwhen i >= 150
        if s__Inventory_getItem(IL_Inv, i) != IL_Saved[i] or s__Inventory_getItemId(IL_Inv, i) != IL_Custom[i] then
            return false
        endif
        set i = i + 1
    endloop
    return s__Inventory_itemsOfType(IL_Inv, 'rst1') == IL_SavedCount and s__Inventory_itemsOfType(IL_Inv, 0) == IL_SavedZero
endfunction

function IL_Unchanged takes nothing returns boolean
    return IL_InventoryUnchanged() and GetHeroStr(IL_Hero, true) == IL_SavedStr and GetHeroAgi(IL_Hero, true) == IL_SavedAgi and GetHeroInt(IL_Hero, true) == IL_SavedInt
endfunction

function IL_Layout takes integer count returns boolean
    local integer i = 0
    local integer expected
    loop
        exitwhen i >= 150
        set expected = 0
        if i < count then
            set expected = IL_Fixture
        endif
        if s__Inventory_getItem(IL_Inv, i) != expected then
            return false
        endif
        set i = i + 1
    endloop
    return s__Inventory_itemsOfType(IL_Inv, 'rst1') == count
endfunction

function IL_ClearOwned takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= 30
        // Never remove a preexisting item or another type inserted during the run.
        if IL_Owned[i] and s__Inventory_getItem(IL_Inv, i) == IL_Fixture then
            call s__Inventory_setItem(IL_Inv, i, 0)
        endif
        set IL_Owned[i] = false
        set i = i + 1
    endloop
endfunction

function IL_ReadyHero takes nothing returns nothing
    local group g = CreateGroup()
    local unit u
    local integer n = 0
    local boolean controlled = GetPlayerController(Player(0)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(0)) == PLAYER_SLOT_STATE_PLAYING
    call IL_Check(controlled, "Player0 playing human controller")
    call GroupEnumUnitsOfPlayer(g, Player(0), null)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        if IsUnitType(u, UNIT_TYPE_HERO) and GetOwningPlayer(u) == Player(0) and GetWidgetLife(u) > 0.405 then
            set n = n + 1
            set IL_Hero = u
        endif
    endloop
    call DestroyGroup(g)
    set g = null
    set u = null
    call IL_Check(n == 1, "native-enumeration heroes=" + I2S(n))
    if n != 1 or not controlled then
        return
    endif
    set IL_Inv = s__Inventory__staticgetindex(IL_Hero)
    set IL_Gear = s__Equipment__staticgetindex(IL_Hero)
    set IL_Fixture = GetInvItem('rst1')
    set IL_Ready = IL_Inv > 0 and IL_Gear > 0 and IL_Fixture > 0
    call IL_Check(IL_Ready, "public-lookup inventory=" + I2S(IL_Inv) + " equipment=" + I2S(IL_Gear) + " fixture=" + I2S(IL_Fixture))
    set IL_BaseStr = GetHeroStr(IL_Hero, true)
    set IL_BaseAgi = GetHeroAgi(IL_Hero, true)
    set IL_BaseInt = GetHeroInt(IL_Hero, true)
endfunction

function IL_OnPickup takes nothing returns nothing
    if GetTriggerUnit() == IL_Hero and GetManipulatedItem() == IL_Physical then
        set IL_PickEvents = IL_PickEvents + 1
    endif
endfunction

function IL_Initial takes nothing returns nothing
    local integer i = 0
    set IL_Empty = true
    loop
        exitwhen i >= 150
        set IL_InitialCustom[i] = s__Inventory_getItemId(IL_Inv, i)
        if s__Inventory_getItem(IL_Inv, i) != 0 then
            set IL_Empty = false
        endif
        set i = i + 1
    endloop
    set IL_Empty = IL_Empty and s__Inventory_itemsOfType(IL_Inv, 'rst1') == 0
    call IL_Check(IL_Empty, "initial-empty150 and fixture-count0")
    call IL_Record("OBS", "currentPage has no callable getter - page0 inferred from first add at index0")
endfunction

function IL_InventoryCase takes nothing returns nothing
    local boolean ok
    local integer i
    if IL_Case == 3 then
        call IL_Snapshot()
        call IL_Log("CHECK", "before=add0")
        set ok = s__Inventory_addItem(IL_Inv, 0)
        call IL_Log("CHECK", "after=add0")
        call IL_Check(not ok and IL_Unchanged(), "add0 rejected and all150-identities custom-ids counts stats preserved")
    elseif IL_Case == 4 or IL_Case == 5 then
        set i = IL_Case - 4
        if not IL_Layout(i) then
            call IL_Record("SKIP", "prior-layout failed - no add")
            return
        endif
        // Record ownership before entering a possibly aborting library call.
        set IL_Owned[i] = true
        call IL_Log("CHECK", "before=add-fixture")
        set ok = s__Inventory_addItem(IL_Inv, IL_Fixture)
        call IL_Log("CHECK", "after=add-fixture")
        call IL_Check(ok and IL_Layout(i+1), "registered-rst1 duplicate count=" + I2S(i+1) + " page0-layout")
    elseif IL_Case == 6 then
        if not IL_Layout(2) then
            call IL_Record("SKIP", "prior-layout failed - no fill")
            return
        endif
        set i = 2
        set ok = true
        loop
            exitwhen i >= 30
            set IL_Owned[i] = true
            call IL_Log("CHECK", "before=fill index=" + I2S(i))
            if not s__Inventory_addItem(IL_Inv, IL_Fixture) then
                set ok = false
            endif
            call IL_Log("CHECK", "after=fill index=" + I2S(i))
            set i = i + 1
        endloop
        call IL_Check(ok and IL_Layout(30), "fill30 current-page not capacity150")
    elseif IL_Case == 7 then
        if not IL_Layout(30) then
            call IL_Record("SKIP", "prior-layout failed - no overflow")
            return
        endif
        call IL_Snapshot()
        call IL_Log("CHECK", "before=add31")
        set ok = s__Inventory_addItem(IL_Inv, IL_Fixture)
        call IL_Log("CHECK", "after=add31")
        call IL_Check(not ok and IL_Unchanged() and IL_Layout(30), "reject31 unchanged30-identities type-count30 and other120-empty")
    elseif IL_Case == 8 then
        if not IL_Layout(30) then
            call IL_Record("SKIP", "prior-layout failed - no remove-refill")
            return
        endif
        call IL_Log("CHECK", "before=remove-refill")
        call s__Inventory_setItem(IL_Inv, 7, 0)
        call IL_Check(s__Inventory_getItem(IL_Inv, 7) == 0 and s__Inventory_itemsOfType(IL_Inv, 'rst1') == 29 and s__Inventory_findFreeSlot(IL_Inv, 0) == 7, "remove-one count29 free7")
        set ok = s__Inventory_addItem(IL_Inv, IL_Fixture)
        call IL_Log("CHECK", "after=remove-refill")
        call IL_Check(ok and IL_Layout(30), "refill free7 count30 exact-layout")
    elseif IL_Case == 9 then
        call IL_Log("CHECK", "before=fixture-cleanup")
        call IL_ClearOwned()
        call IL_Log("CHECK", "after=fixture-cleanup")
        if not IL_Layout(0) then
            call IL_Record("FAIL", "cleanup did not restore empty inventory - pickup not attempted")
            return
        endif
        set IL_Physical = CreateItem('rst1', GetUnitX(IL_Hero), GetUnitY(IL_Hero))
        set IL_Owned[0] = true
        call IL_Log("CHECK", "before=native-UnitAddItem")
        set ok = UnitAddItem(IL_Hero, IL_Physical)
        call IL_Log("CHECK", "after=native-UnitAddItem")
        // Native return is recorded, not assumed true after the event removes the item.
        if ok then
            call IL_Record("OBS", "UnitAddItem-return=true")
        else
            call IL_Record("OBS", "UnitAddItem-return=false")
        endif
        call IL_Check(IL_PickEvents == 1 and GetItemTypeId(IL_Physical) == 0 and IL_Layout(1) and s__Inventory_getItemId(IL_Inv, 0) > 0, "real-pickup event1 physical-removed retained-instance-with-custom-id")
    endif
endfunction

function IL_EquipmentCase takes nothing returns nothing
    local boolean ok
    if IL_Case == 10 then
        call IL_Snapshot()
        call IL_Log("CHECK", "before=wrong-slot0")
        set ok = s__Equipment_equip(IL_Gear, IL_Fixture, 0)
        call IL_Log("CHECK", "after=wrong-slot0")
        call IL_Check(not ok and IL_Unchanged(), "wrong-slot0 reject unchanged-inventory counts all-hero-stats")
    elseif IL_Case == 11 then
        call IL_Snapshot()
        call IL_Log("CHECK", "before=equip-slot8")
        set IL_Equipped = s__Equipment_equip(IL_Gear, IL_Fixture, 8)
        call IL_Log("CHECK", "after=equip-slot8")
        call IL_Check(IL_Equipped and IL_InventoryUnchanged() and GetHeroStr(IL_Hero, true) == IL_BaseStr+3 and GetHeroAgi(IL_Hero, true) == IL_BaseAgi and GetHeroInt(IL_Hero, true) == IL_BaseInt, "fixed-rst1 equip +3 strength only")
    elseif IL_Case == 12 then
        if not IL_Equipped then
            call IL_Record("SKIP", "equip did not succeed - occupied test unsafe")
            return
        endif
        call IL_Snapshot()
        call IL_Log("CHECK", "before=occupied-slot8")
        set ok = s__Equipment_equip(IL_Gear, IL_Fixture, 8)
        call IL_Log("CHECK", "after=occupied-slot8")
        call IL_Check(not ok and IL_Unchanged(), "occupied-slot8 reject unchanged-inventory counts all-hero-stats")
    elseif IL_Case == 13 then
        if not IL_Equipped then
            call IL_Record("SKIP", "no owned equipment - never unequip unrelated gear")
            return
        endif
        call IL_Snapshot()
        call IL_Log("CHECK", "before=unequip-slot8")
        set ok = s__Equipment_unequip(IL_Gear, IL_Fixture, 8)
        call IL_Log("CHECK", "after=unequip-slot8")
        if ok then
            set IL_Equipped = false
        endif
        call IL_Check(ok and IL_InventoryUnchanged() and GetHeroStr(IL_Hero, true) == IL_BaseStr and GetHeroAgi(IL_Hero, true) == IL_BaseAgi and GetHeroInt(IL_Hero, true) == IL_BaseInt, "unequip exact-stat-restoration")
    endif
endfunction

function IL_Restore takes nothing returns nothing
    local boolean ok
    local boolean customRestored = true
    local integer i = 0
    if IL_Equipped then
        call IL_Log("CHECK", "before=cleanup-owned-equipment")
        set ok = s__Equipment_unequip(IL_Gear, IL_Fixture, 8)
        call IL_Log("CHECK", "after=cleanup-owned-equipment")
        call IL_Check(ok, "cleanup-owned-equipment returned")
        if ok then
            set IL_Equipped = false
        endif
    endif
    if IL_Ready and IL_Empty then
        call IL_Log("CHECK", "before=cleanup-owned-items")
        call IL_ClearOwned()
        call IL_Log("CHECK", "after=cleanup-owned-items")
        call IL_Check(IL_Layout(0) and GetHeroStr(IL_Hero, true) == IL_BaseStr and GetHeroAgi(IL_Hero, true) == IL_BaseAgi and GetHeroInt(IL_Hero, true) == IL_BaseInt, "restore-empty inventory and original-stats")
        loop
            exitwhen i >= 150
            if s__Inventory_getItemId(IL_Inv, i) != IL_InitialCustom[i] then
                set customRestored = false
            endif
            set i = i + 1
        endloop
        call IL_Check(customRestored, "restore-original-custom-ids - baseline may retain pickup metadata")
        if not customRestored then
            call IL_Record("OBS", "setItem0 does not clear custom-id metadata and no callable context setter exists - restart map")
        endif
    endif
    if IL_Physical != null then
        if GetItemTypeId(IL_Physical) != 0 then
            call RemoveItem(IL_Physical)
        endif
        set IL_Physical = null
    endif
    call IL_Record("SKIP", "pages - use real page arrows and inspect all five pages")
    call IL_Record("SKIP", "sell-drop - select item use buttons confirm and cancel dialogs")
    call IL_Record("SKIP", "sockets - select gem then target confirm and cancel dialog")
    call IL_Record("SKIP", "Camera.destroy destructive recursion probe disabled - original unchanged")
    call IL_Record("OBS", "equipment fields have no callable getters - occupancy inferred by rejection and restoration")
    call IL_Record("OBS", "no public live-instance or timer counters - leak absence not established")
    call IL_Record("OBS", "original local-player data reaches world mutations - multiplayer untested")
endfunction

// Forward scheduling is kept below all scenario bodies; each case uses a new thread.
function IL_Complete takes nothing returns nothing
    set IL_Current = "-"
    call IL_Log("COMPLETE", "cases=" + I2S(IL_Cases) + " " + IL_CountText(IL_Pass, IL_Fail, IL_Obs, IL_Skip))
    call DisplayTimedTextToPlayer(Player(0), 0., 0., 120., "IL141 " + IL_RUN + " COMPLETE failures=" + I2S(IL_Fail) + " - interactive coverage remains inconclusive")
    call DestroyTrigger(IL_PickTrigger)
    call DestroyTimer(IL_Watch)
    call DestroyTimer(IL_Next)
    // IL_Persist/IL_Work remain two bounded lab triggers until map shutdown.
endfunction

function IL_Dispatch takes nothing returns nothing
    set IL_Case = IL_Case + 1
    set IL_Cases = IL_Cases + 1
    set IL_Current = I2S(IL_Case)
    set IL_CP = 0
    set IL_CF = 0
    set IL_CO = 0
    set IL_CS = 0
    set IL_Active = true
    call IL_Log("CASE", "before")
    call TriggerExecute(IL_Work)
endfunction

function IL_Close takes nothing returns nothing
    set IL_Active = false
    call PauseTimer(IL_Watch)
    call IL_Log("RESULT", IL_CountText(IL_CP, IL_CF, IL_CO, IL_CS))
    if IL_Case == 14 then
        call IL_Complete()
    else
        call TimerStart(IL_Next, 0.10, false, function IL_Dispatch)
    endif
endfunction

function IL_Timeout takes nothing returns nothing
    if IL_Active then
        call IL_Record("FAIL", "watchdog exception-path - case did not return - no after marker fabricated")
        // Stop dependent probes, but keep bounded cleanup and honest completion.
        set IL_Ready = false
        call IL_Record("OBS", "aborted call state and restoration unknown - restart map before manual evaluation")
        call IL_Close()
    endif
endfunction

function IL_Run takes nothing returns nothing
    // Watchdog is armed before any scenario API call and persisted before dispatch.
    call TimerStart(IL_Watch, 4., false, function IL_Timeout)
    call IL_Log("CHECK", "watchdog=armed before=scenario")
    if IL_Case == 1 then
        call IL_ReadyHero()
    elseif IL_Case == 14 then
        call IL_Restore()
    elseif not IL_Ready then
        call IL_Record("SKIP", "readiness failed - dependent call not attempted")
    elseif IL_Case == 2 then
        call IL_Initial()
    elseif not IL_Empty then
        call IL_Record("SKIP", "preexisting inventory preserved - dependent call not attempted")
    elseif IL_Case <= 9 then
        call IL_InventoryCase()
    else
        call IL_EquipmentCase()
    endif
    call IL_Log("CHECK", "after=scenario returned")
    call IL_Close()
endfunction

function IL_Start takes nothing returns nothing
    set IL_Persist = CreateTrigger()
    call TriggerAddCondition(IL_Persist, Condition(function IL_Flush))
    set IL_Work = CreateTrigger()
    call TriggerAddAction(IL_Work, function IL_Run)
    set IL_Next = CreateTimer()
    set IL_Watch = CreateTimer()
    set IL_PickTrigger = CreateTrigger()
    call TriggerRegisterPlayerUnitEvent(IL_PickTrigger, Player(0), EVENT_PLAYER_UNIT_PICKUP_ITEM, null)
    call TriggerAddAction(IL_PickTrigger, function IL_OnPickup)
    call IL_Log("BEGIN", "schema=1")
    // End-of-main hook never replaces or manually invokes the original initializers.
    call TimerStart(IL_Next, 2., false, function IL_Dispatch)
endfunction
