// ITL technical probes. Plain lowered public JASS APIs; never core storage oracles.
function ITL_Flush takes nothing returns boolean
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    loop
        exitwhen i >= ITL_LineCount
        call Preload(ITL_Lines[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("Logs\\IL141-" + ITL_RUN + ".pld")
    return true
endfunction

function ITL_Allowed takes string c returns boolean
    local string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 _=.,:+-"
    local integer i = 0
    loop
        exitwhen i >= StringLength(alphabet)
        if SubString(alphabet, i, i+1) == c then
            return true
        endif
        set i = i + 1
    endloop
    return false
endfunction

function ITL_Safe takes string text returns boolean
    local integer i = 0
    local string c
    if StringLength(text) < 1 or StringLength(text) > 160 then
        return false
    endif
    loop
        exitwhen i >= StringLength(text)
        set c = SubString(text, i, i+1)
        if not ITL_Allowed(c) then
            return false
        endif
        set i = i + 1
    endloop
    return true
endfunction

function ITL_Validate takes nothing returns boolean
    return ITL_Safe(ITL_Payload)
endfunction

function ITL_Log takes string kind, string detail returns nothing
    if ITL_LogFault then
        return
    endif
    set ITL_Payload = detail
    if ITL_LineCount >= 512 or not TriggerEvaluate(ITL_Validator) then
        set ITL_LogFault = true
        return
    endif
    set ITL_LineCount = ITL_LineCount + 1
    set ITL_Lines[ITL_LineCount-1] = "IL141|" + ITL_RUN + "|" + I2S(ITL_LineCount) + "|" + kind + "|" + ITL_Current + "|" + detail
    // Independent condition thread keeps cumulative flush work outside case budget.
    call TriggerEvaluate(ITL_Persist)
endfunction

function ITL_CountText takes integer p, integer f, integer o, integer s returns string
    return "pass=" + I2S(p) + " fail=" + I2S(f) + " obs=" + I2S(o) + " skip=" + I2S(s)
endfunction

function ITL_Record takes string status, string detail returns nothing
    local integer index = 0
    if status == "FAIL" then
        set index = 1
    elseif status == "OBS" then
        set index = 2
    elseif status == "SKIP" then
        set index = 3
    endif
    set ITL_Local[index] = ITL_Local[index] + 1
    set ITL_Total[index] = ITL_Total[index] + 1
    call ITL_Log(status, detail)
endfunction

function ITL_Check takes boolean ok, string detail returns nothing
    if ok then
        call ITL_Record("PASS", detail)
    else
        call ITL_Record("FAIL", detail)
    endif
endfunction

function ITL_Near takes real a, real b returns boolean
    return RAbsBJ(a-b) < 0.5
endfunction

function ITL_SamePosition takes unit u, real x, real y returns boolean
    return GetUnitTypeId(u) == 'uidm' and ITL_Near(GetUnitX(u), x) and ITL_Near(GetUnitY(u), y)
endfunction

// Constructors are synchronous: enumerate a native before/after group difference.
// No library .picture/.dummy field is read. Only exact new uidm handles are owned.
function ITL_Create takes integer slot returns nothing
    local group before = CreateGroup()
    local group after = CreateGroup()
    local unit u
    local integer n = 0
    call GroupEnumUnitsOfPlayer(before, Player(13), null)
    call ITL_Log("CHECK", "before=constructor slot=" + I2S(slot))
    if ITL_Mode == 1 then
        set ITL_Ids[slot] = s__UIButton_create(-0.6 + slot*0.15, 0.5, 0.1, 0.1, 0., 0)
    elseif ITL_Mode == 2 then
        set ITL_Ids[slot] = s__UIPicture_create(-0.6 + slot*0.15, 0.5, 0.1, 0.1, 0., 0)
    else
        set ITL_Ids[slot] = s__UIText_create(-0.6 + slot*0.15, 0.5, 0.)
    endif
    call ITL_Log("CHECK", "after=constructor slot=" + I2S(slot))
    call GroupEnumUnitsOfPlayer(after, Player(13), null)
    set ITL_Units[slot] = null
    loop
        set u = FirstOfGroup(after)
        exitwhen u == null
        call GroupRemoveUnit(after, u)
        if not IsUnitInGroup(u, before) and GetUnitTypeId(u) == 'uidm' and GetOwningPlayer(u) == Player(13) then
            set n = n + 1
            // Retain only typed handles proven newly created by this synchronous call.
            if n == 1 then
                set ITL_Units[slot] = u
            endif
        endif
    endloop
    call DestroyGroup(before)
    call DestroyGroup(after)
    set before = null
    set after = null
    set u = null
    call ITL_Check(n == 1 and ITL_Ids[slot] > 0 and GetUnitTypeId(ITL_Units[slot]) == 'uidm', "constructor expected=new-uidm1 actual=" + I2S(n) + " id=" + I2S(ITL_Ids[slot]))
    if n != 1 or ITL_Ids[slot] <= 0 then
        set ITL_Stop = true
    endif
endfunction

function ITL_Show takes integer slot, boolean flag returns nothing
    if ITL_Mode == 1 then
        call s__UIButton_show(ITL_Ids[slot], flag, ITL_Camera)
    elseif ITL_Mode == 2 then
        call s__UIPicture_show(ITL_Ids[slot], flag, ITL_Camera)
    else
        call s__UIText_show(ITL_Ids[slot], flag, ITL_Camera)
    endif
endfunction

function ITL_Direct takes integer slot returns nothing
    if ITL_Mode == 1 then
        call s__UIButton_update(ITL_Ids[slot])
    elseif ITL_Mode == 2 then
        call s__UIPicture_update(ITL_Ids[slot])
    else
        call s__UIText_update(ITL_Ids[slot])
    endif
endfunction

function ITL_UpdateAll takes nothing returns nothing
    if ITL_Mode == 1 then
        call s__UIButton_updateAll()
    elseif ITL_Mode == 2 then
        call s__UIPicture_updateAll()
    else
        call s__UIText_updateAll()
    endif
endfunction

function ITL_RemoveOwned takes integer slot returns nothing
    if ITL_Units[slot] != null and GetUnitTypeId(ITL_Units[slot]) != 0 then
        call RemoveUnit(ITL_Units[slot])
    endif
    set ITL_Units[slot] = null
endfunction

function ITL_Destroy takes integer slot returns nothing
    call ITL_Log("CHECK", "before=destroy slot=" + I2S(slot))
    if ITL_Mode == 1 then
        call s__UIButton_destroy(ITL_Ids[slot])
    elseif ITL_Mode == 2 then
        call s__UIPicture_destroy(ITL_Ids[slot])
    else
        call s__UIText_destroy(ITL_Ids[slot])
    endif
    call ITL_Log("CHECK", "after=destroy slot=" + I2S(slot))
    // Record the baseline defect BEFORE native cleanup of the owned UIText dummy.
    call ITL_Check(GetUnitTypeId(ITL_Units[slot]) == 0, "expected=removed actual-type=" + I2S(GetUnitTypeId(ITL_Units[slot])))
    call ITL_RemoveOwned(slot)
endfunction

function ITL_Readiness takes nothing returns nothing
    local real x
    local real y
    set ITL_Camera = s__Camera_create()
    if ITL_Camera <= 0 then
        set ITL_Stop = true
        call ITL_Record("FAIL", "fixture-camera expected=positive-owned-id actual=" + I2S(ITL_Camera))
        return
    endif
    call s__Camera_setPosition(ITL_Camera, 0., 0., 0.)
    call ITL_Record("OBS", "routine-cameras=1 retained-until-map-shutdown unsafe-destructor-not-used")
    call ITL_Create(0)
    if ITL_Stop then
        return
    endif
    call ITL_Show(0, true)
    // show() calls update before marking displayed; use actual public direct update.
    call ITL_Direct(0)
    set x = GetUnitX(ITL_Units[0])
    set y = GetUnitY(ITL_Units[0])
    call s__Camera_setPosition(ITL_Camera, 64., 32., 0.)
    call ITL_Direct(0)
    set ITL_ProjectionReady = GetUnitTypeId(ITL_Units[0]) == 'uidm' and not ITL_SamePosition(ITL_Units[0], x, y)
    set ITL_Ready = ITL_ProjectionReady and ITL_Camera > 0
    call ITL_Check(ITL_Ready, "projection expected=direct-moved64,32 actual-dx=" + R2S(GetUnitX(ITL_Units[0])-x) + " dy=" + R2S(GetUnitY(ITL_Units[0])-y))
    call ITL_Show(0, false)
    call ITL_Destroy(0)
endfunction

function ITL_HiddenPair takes nothing returns nothing
    local integer old
    local real started = TimerGetElapsed(ITL_Clock)
    set ITL_Pair = ITL_Pair + 1
    if ITL_Pair <= 16 then
        call ITL_Create(0)
        if ITL_Stop then
            return
        endif
        set old = ITL_Ids[0]
        call ITL_Destroy(0)
        // No intervening same-class allocation: generated allocator pops freelist first.
        call ITL_Create(0)
        if ITL_Stop then
            return
        endif
        call ITL_Check(ITL_Ids[0] == old, "immediate-id-reuse expected=" + I2S(old) + " actual=" + I2S(ITL_Ids[0]))
        call ITL_Destroy(0)
        call ITL_Record("OBS", "hidden-pair=" + I2S(ITL_Pair) + " ctor=2 destroy=2 seconds=" + R2S(TimerGetElapsed(ITL_Clock)-started))
    endif
endfunction

function ITL_ShowHide takes nothing returns nothing
    local real x
    local real y
    call ITL_Create(0)
    if ITL_Stop then
        return
    endif
    call ITL_Show(0, true)
    call ITL_Show(0, true)
    call ITL_Direct(0)
    set x = GetUnitX(ITL_Units[0])
    set y = GetUnitY(ITL_Units[0])
    call s__Camera_setPosition(ITL_Camera, 96., 48., 0.)
    call ITL_UpdateAll()
    set ITL_BulkX[0] = GetUnitX(ITL_Units[0])
    set ITL_BulkY[0] = GetUnitY(ITL_Units[0])
    call ITL_Direct(0)
    call ITL_Check(not ITL_SamePosition(ITL_Units[0], x, y) and ITL_SamePosition(ITL_Units[0], ITL_BulkX[0], ITL_BulkY[0]), "repeat-show moved-camera updateAll expected=direct actual-x=" + R2S(GetUnitX(ITL_Units[0])) + " y=" + R2S(GetUnitY(ITL_Units[0])))
    set x = GetUnitX(ITL_Units[0])
    set y = GetUnitY(ITL_Units[0])
    call ITL_Show(0, false)
    call ITL_Show(0, false)
    if ITL_Mode == 3 then
        call ITL_Check(ITL_SamePosition(ITL_Units[0], x, y), "UIText hide preserves native position expected=unchanged")
    else
        call ITL_Check(ITL_SamePosition(ITL_Units[0], 0., 0.), "hide expected=origin actual-x=" + R2S(GetUnitX(ITL_Units[0])) + " y=" + R2S(GetUnitY(ITL_Units[0])))
    endif
    call ITL_Show(0, true)
    call ITL_Direct(0)
    call ITL_UpdateAll()
    call ITL_Check(ITL_SamePosition(ITL_Units[0], x, y), "reshow direct-update expected=original-projection")
    call ITL_Show(0, false)
    call ITL_Destroy(0)
endfunction

function ITL_Membership takes nothing returns nothing
    local integer i = 0
    local integer missing = 0
    local integer changed = 0
    local integer live = 0
    local boolean ready = ITL_ProjectionReady
    // LAST case: A B C shown, destroy A visible, then D overwrites extra traversal slot.
    loop
        exitwhen i >= 3
        call ITL_Create(i)
        if ITL_Stop then
            return
        endif
        call ITL_Show(i, true)
        call ITL_Direct(i)
        set i = i + 1
    endloop
    call ITL_Destroy(0)
    call ITL_Create(3)
    if ITL_Stop then
        return
    endif
    call ITL_Show(3, true)
    call ITL_Direct(3)
    set i = 1
    loop
        exitwhen i > 3
        set ITL_X[i] = GetUnitX(ITL_Units[i])
        set ITL_Y[i] = GetUnitY(ITL_Units[i])
        set i = i + 1
    endloop
    call s__Camera_setPosition(ITL_Camera, 192., 96., 0.)
    call ITL_Log("CHECK", "before=membership-updateAll")
    call ITL_UpdateAll()
    call ITL_Log("CHECK", "after=membership-updateAll")
    set i = 1
    loop
        exitwhen i > 3
        set ITL_BulkX[i] = GetUnitX(ITL_Units[i])
        set ITL_BulkY[i] = GetUnitY(ITL_Units[i])
        if GetUnitTypeId(ITL_Units[i]) == 'uidm' then
            set live = live + 1
        endif
        if not ITL_SamePosition(ITL_Units[i], ITL_X[i], ITL_Y[i]) then
            set changed = changed + 1
        endif
        call ITL_Direct(i)
        // Independent direct update on SAME camera establishes expected native coordinates.
        if ITL_SamePosition(ITL_Units[i], ITL_X[i], ITL_Y[i]) then
            set ready = false
        endif
        if not ITL_SamePosition(ITL_Units[i], ITL_BulkX[i], ITL_BulkY[i]) then
            set missing = missing + 1
        endif
        call ITL_Record("OBS", "member=" + I2S(i) + " bulk-x=" + R2S(ITL_BulkX[i]) + " direct-x=" + R2S(GetUnitX(ITL_Units[i])) + " direct-y=" + R2S(GetUnitY(ITL_Units[i])))
        set i = i + 1
    endloop
    call ITL_Check(ready and live == 3, "membership readiness expected=direct-moved3 live3 actual-live=" + I2S(live))
    if ready and live == 3 then
        call ITL_Check(missing == 0 and changed == 3, "membership expected=changed3 missing0 actual-changed=" + I2S(changed) + " missing=" + I2S(missing))
    else
        call ITL_Record("SKIP", "membership dependent-oracle unavailable - no list verdict")
    endif
    set i = 1
    loop
        exitwhen i > 3
        call ITL_RemoveOwned(i)
        set i = i + 1
    endloop
    call ITL_Record("OBS", "owned-units native-cleaned shared membership not restored - disposable-map end now")
endfunction

function ITL_CameraProbe takes nothing returns nothing
    set ITL_Camera = s__Camera_create()
    if ITL_Camera <= 0 then
        call ITL_Record("FAIL", "standalone-camera expected=positive-owned-id actual=" + I2S(ITL_Camera))
        call ITL_Record("SKIP", "no owned camera - dangerous destructor not attempted")
        return
    endif
    call s__Camera_setPosition(ITL_Camera, 32., 16., 0.)
    call ITL_Check(ITL_Camera > 0, "standalone-camera expected=public-created actual=" + I2S(ITL_Camera))
    call ITL_Log("CHECK", "before=Camera.destroy watchdog-prearmed call-once no-retry")
    call s__Camera_destroy(ITL_Camera)
    call ITL_Log("CHECK", "after=Camera.destroy returned")
    call ITL_Record("OBS", "Camera.destroy returned - no private allocator or cleanup assertion available")
endfunction

function ITL_BeatTick takes nothing returns nothing
    set ITL_Beat = ITL_Beat + 1
endfunction

function ITL_TimerCleanup takes nothing returns nothing
    local integer i = 0
    local integer unretired = 0
    set ITL_HarnessCleanup = true
    loop
        exitwhen i >= ITL_TimerCount
        if not ITL_Retired[i] and not ITL_CleanupAttempted[i] and ITL_Timers[i] != null then
            // Mark attempt BEFORE entry: even rejected cleanup must never be retried.
            set ITL_CleanupAttempted[i] = true
            call ReleaseTimer(ITL_Timers[i])
        endif
        if not ITL_Retired[i] then
            set unretired = unretired + 1
        endif
        set i = i + 1
    endloop
    set ITL_HarnessCleanup = false
    call ITL_Check(unretired == 0, "harness-cleanup expected=all-tracked-retired actual-unretired=" + I2S(unretired))
    if unretired != 0 then
        set ITL_Stop = true
    endif
    call ITL_Record("OBS", "harness-cleanup-retired=" + I2S(ITL_CleanupRetired) + " distinct-from-baseline")
    set ITL_OwnedButton = 0
endfunction

function ITL_TimerVerdict takes nothing returns nothing
    local boolean ready = ITL_Clicks > 0 and ITL_Acquired > 0 and ITL_Beat > ITL_StartBeat
    call ITL_Check(ready, "timer-readiness clicks=" + I2S(ITL_Clicks) + " acquired=" + I2S(ITL_Acquired) + " heartbeat=" + I2S(ITL_Beat-ITL_StartBeat))
    call ITL_Record("OBS", "baseline-deficit before=harness-cleanup acquired=" + I2S(ITL_Acquired) + " expired=" + I2S(ITL_ExpiredCount) + " released=" + I2S(ITL_Released) + " destroyed=" + I2S(ITL_Destroyed))
    if ready then
        call ITL_Check(ITL_ExpiredCount > 0, "configured-delay0.6 expected=actual-expiry observed=" + I2S(ITL_ExpiredCount))
        call ITL_Check(ITL_Acquired == ITL_Released + ITL_Destroyed, "owned-timer expected=one-retirement-per-acquisition actual-deficit=" + I2S(ITL_Acquired-ITL_Released-ITL_Destroyed))
    else
        call ITL_Record("SKIP", "timer-retirement dependent on positive real click readiness - no timer-bug verdict")
    endif
    call ITL_TimerCleanup()
endfunction

function ITL_Complete takes nothing returns nothing
    set ITL_Current = "-"
    call ITL_Log("COMPLETE", "cases=" + I2S(ITL_Cases) + " " + ITL_CountText(ITL_Total[0], ITL_Total[1], ITL_Total[2], ITL_Total[3]))
    if ITL_LogFault then
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 120., "ITL LOG FAULT - incomplete evidence - close this disposable game now")
    else
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 120., "ITL COMPLETE failures=" + I2S(ITL_Total[1]) + " - close this disposable game now")
    endif
    call DestroyTimer(ITL_Next)
    call DestroyTimer(ITL_Watch)
    call DestroyTimer(ITL_PhaseTimer)
    call DestroyTimer(ITL_Heartbeat)
    call DestroyTimer(ITL_Clock)
    // Three bounded lab triggers and one routine camera (or aborted camera) until shutdown.
endfunction

function ITL_Dispatch takes nothing returns nothing
    local integer i = 0
    set ITL_Case = ITL_Case + 1
    set ITL_Cases = ITL_Cases + 1
    set ITL_Current = "case-" + I2S(ITL_Case)
    loop
        exitwhen i == 4
        set ITL_Local[i] = 0
        set i = i + 1
    endloop
    set ITL_Active = true
    call TriggerExecute(ITL_Work)
endfunction

function ITL_Close takes nothing returns nothing
    set ITL_Active = false
    call PauseTimer(ITL_Watch)
    call ITL_Log("RESULT", ITL_CountText(ITL_Local[0], ITL_Local[1], ITL_Local[2], ITL_Local[3]))
    if ITL_Stop or ITL_LogFault or ITL_Mode == 0 or ITL_Mode == 4 or (ITL_Mode != 1 and ITL_Case == 19) or ITL_Case == 21 then
        call ITL_Complete()
    else
        call TimerStart(ITL_Next, 0.10, false, function ITL_Dispatch)
    endif
endfunction

function ITL_Timeout takes nothing returns nothing
    if ITL_Active then
        set ITL_Stop = true
        call PauseTimer(ITL_PhaseTimer)
        call ITL_Record("FAIL", "watchdog did not return or finish - liveness or cleanup-nonreturn explicit-failure")
        call ITL_Record("OBS", "aborted-state cleanup-unknown - no retry no dependent calls - close owned game")
        // This living independent runner may honestly complete; frozen VM cannot.
        call ITL_Close()
    endif
endfunction

function ITL_TimerPhase takes nothing returns nothing
    local boolean accepted
    if not ITL_Active then
        return
    endif
    if ITL_Phase == 0 then
        set ITL_FirstAcquired = ITL_Acquired
        set ITL_FirstClicks = ITL_Clicks
        if ITL_Case == 20 then
            // Outside the actual click callback, between native polling callbacks.
            call ITL_Show(0, false)
            call ITL_Destroy(0)
            call ITL_Log("CHECK", "pending-button destroyed-before-expiry")
        elseif ITL_Acquired > 0 then
            call SelectUnit(ITL_Units[0], true)
            set accepted = s__UIButton_clickPeriodicSelect(Player(0), true)
            call ITL_Check(not accepted and ITL_Acquired == ITL_FirstAcquired and ITL_Clicks == ITL_FirstClicks, "delay suppression expected=no-second-acquisition actual=" + I2S(ITL_Acquired))
        endif
        set ITL_Phase = 1
        call TimerStart(ITL_PhaseTimer, 0.7, false, function ITL_TimerPhase)
        return
    elseif ITL_Phase == 1 and ITL_Case == 19 then
        if ITL_FirstAcquired > 0 and ITL_ExpiredCount > 0 then
            call SelectUnit(ITL_Units[0], true)
            set accepted = s__UIButton_clickPeriodicSelect(Player(0), true)
            call ITL_Check(accepted and ITL_Acquired == ITL_FirstAcquired+1 and ITL_Clicks == ITL_FirstClicks+1, "after-expiry reaccept expected=one-new-click actual=" + I2S(ITL_Clicks))
        else
            call ITL_Record("FAIL", "first real callback or acquisition not observed by0.8 - reaccept not attempted")
            call ITL_Record("SKIP", "reaccept readiness unavailable")
        endif
        set ITL_Phase = 2
        call TimerStart(ITL_PhaseTimer, 0.7, false, function ITL_TimerPhase)
        return
    endif
    if ITL_Case == 19 then
        call ITL_Show(0, false)
        call ITL_Destroy(0)
    endif
    call ITL_TimerVerdict()
    call ITL_Log("CHECK", "after=timer-window returned")
    call ITL_Close()
endfunction

function ITL_TimerBegin takes nothing returns nothing
    local boolean accepted
    call ITL_Create(0)
    if ITL_Stop then
        call ITL_Close()
        return
    endif
    set ITL_Generation = ITL_Generation + 1
    set ITL_OwnedButton = ITL_Ids[0]
    set ITL_Acquired = 0
    set ITL_ExpiredCount = 0
    set ITL_Released = 0
    set ITL_Destroyed = 0
    set ITL_Clicks = 0
    set ITL_CleanupRetired = 0
    set ITL_StartBeat = ITL_Beat
    call ITL_Show(0, true)
    call ITL_Direct(0)
    call ITL_Log("CHECK", "before=native-select and public-poll configured-delay0.6")
    call SelectUnit(ITL_Units[0], true)
    set accepted = s__UIButton_clickPeriodicSelect(Player(0), true)
    // No fake PASS if native selection is not registered on this client.
    call ITL_Check(accepted and ITL_Clicks > 0 and ITL_Acquired > 0, "native-select expected=actual-click-acquire actual-clicks=" + I2S(ITL_Clicks) + " acquired=" + I2S(ITL_Acquired))
    set ITL_Phase = 0
    call TimerStart(ITL_PhaseTimer, 0.1, false, function ITL_TimerPhase)
endfunction

function ITL_Run takes nothing returns nothing
    call TimerStart(ITL_Watch, 4., false, function ITL_Timeout)
    call ITL_Log("CASE", "before")
    call ITL_Log("CHECK", "watchdog=armed before=scenario")
    if ITL_Mode == 0 then
        call ITL_Record("FAIL", "unknown mode - no fixture calls")
    elseif ITL_Mode == 4 then
        call ITL_CameraProbe()
    elseif ITL_Case == 1 then
        call ITL_Readiness()
    elseif not ITL_Ready or ITL_Stop then
        call ITL_Record("SKIP", "readiness failed - dependent fixture not attempted")
        set ITL_Stop = true
    elseif ITL_Case <= 17 then
        call ITL_HiddenPair()
    elseif ITL_Case == 18 then
        call ITL_ShowHide()
    elseif ITL_Mode == 1 and ITL_Case <= 20 then
        call ITL_TimerBegin()
        return
    else
        call ITL_Membership()
    endif
    call ITL_Log("CHECK", "after=scenario returned")
    call ITL_Close()
endfunction

function ITL_Init takes nothing returns nothing
    if SubString(ITL_RUN, 0, 11) == "itl-button-" then
        set ITL_Mode = 1
    elseif SubString(ITL_RUN, 0, 12) == "itl-picture-" then
        set ITL_Mode = 2
    elseif SubString(ITL_RUN, 0, 9) == "itl-text-" then
        set ITL_Mode = 3
    elseif SubString(ITL_RUN, 0, 11) == "itl-camera-" then
        set ITL_Mode = 4
    endif
    set ITL_Validator = CreateTrigger()
    call TriggerAddCondition(ITL_Validator, Condition(function ITL_Validate))
    set ITL_Persist = CreateTrigger()
    call TriggerAddCondition(ITL_Persist, Condition(function ITL_Flush))
    set ITL_Work = CreateTrigger()
    call TriggerAddAction(ITL_Work, function ITL_Run)
    set ITL_Next = CreateTimer()
    set ITL_Watch = CreateTimer()
    set ITL_PhaseTimer = CreateTimer()
    set ITL_Heartbeat = CreateTimer()
    set ITL_Clock = CreateTimer()
    call TimerStart(ITL_Heartbeat, 0.05, true, function ITL_BeatTick)
    call TimerStart(ITL_Clock, 120., false, null)
    call ITL_Log("BEGIN", "schema=1")
    call TimerStart(ITL_Next, 2., false, function ITL_Dispatch)
endfunction
