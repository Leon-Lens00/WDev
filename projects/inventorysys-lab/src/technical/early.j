// Early boundary telemetry: typed handles, primitive public inputs, recorder writes only.
// No persistence, timer allocation, pool inspection or library calls in hooks.
function ITL_Boundary takes string eventName, string detail returns nothing
    set ITL_LastBoundary = eventName + " " + detail
endfunction

// Builder's insertion whitelist requires this spelling, not the manual protocol.
function ILM_Log takes string area, string eventName, string detail returns nothing
    call ITL_Boundary(eventName, detail)
endfunction

function ITL_Capture takes timer t, integer data returns string
    local integer i
    if ITL_Active and ITL_OwnedButton > 0 and data == ITL_OwnedButton and t != null then
        if ITL_TimerCount < 8 then
            set i = ITL_TimerCount
            set ITL_Timers[i] = t
            set ITL_TimerGeneration[i] = ITL_Generation
            set ITL_Retired[i] = false
            set ITL_CleanupAttempted[i] = false
            set ITL_Fired[i] = false
            set ITL_TimerCount = i + 1
            set ITL_Acquired = ITL_Acquired + 1
        else
            set ITL_Stop = true
        endif
    endif
    return "acquire-boundary"
endfunction

function ITL_Expired takes timer t returns string
    local integer i = 0
    loop
        exitwhen i >= ITL_TimerCount
        if ITL_Timers[i] == t and not ITL_Retired[i] and not ITL_Fired[i] then
            set ITL_Fired[i] = true
            if ITL_TimerGeneration[i] == ITL_Generation then
                set ITL_ExpiredCount = ITL_ExpiredCount + 1
            endif
            return "owned-expired"
        endif
        set i = i + 1
    endloop
    return "unrelated-expired"
endfunction

function ITL_Retire takes timer t, boolean destroyed returns string
    local integer i = 0
    loop
        exitwhen i >= ITL_TimerCount
        if ITL_Timers[i] == t and not ITL_Retired[i] then
            set ITL_Retired[i] = true
            if ITL_HarnessCleanup then
                set ITL_CleanupRetired = ITL_CleanupRetired + 1
            elseif ITL_TimerGeneration[i] == ITL_Generation then
                if destroyed then
                    set ITL_Destroyed = ITL_Destroyed + 1
                else
                    set ITL_Released = ITL_Released + 1
                endif
            endif
            return "owned-retired"
        endif
        set i = i + 1
    endloop
    return "unrelated-retired"
endfunction

function ITL_Click takes integer buttonId returns string
    if ITL_Active and buttonId == ITL_OwnedButton and buttonId > 0 then
        set ITL_Clicks = ITL_Clicks + 1
    endif
    return "click-boundary"
endfunction
