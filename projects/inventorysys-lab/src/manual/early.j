// Early hooks depend ONLY on natives and recorder globals; no gameplay handles.
function ILM_Bool takes boolean value returns string
    if value then
        return "1"
    endif
    return "0"
endfunction

function ILM_Now takes nothing returns integer
    return R2I(TimerGetElapsed(ILM_Clock) * 1000.0)
endfunction

function ILM_Append takes string source, string eventName, string data returns nothing
    set ILM_Sequence = ILM_Sequence + 1
    set ILM_Queue[ILM_Tail] = "IL141M|" + ILM_BUILD + "|" + ILM_Session + "|" + I2S((ILM_Sequence - 1) / ILM_CHUNK_ROWS) + "|" + I2S(ILM_Sequence) + "|" + I2S(ILM_Now()) + "|" + source + "|" + eventName + "|" + data
    set ILM_Tail = ILM_Tail + 1
    if ILM_Tail == ILM_QUEUE_ROWS then
        set ILM_Tail = 0
    endif
    set ILM_Queued = ILM_Queued + 1
endfunction

function ILM_Log takes string source, string eventName, string data returns nothing
    if not ILM_Active then
        return
    endif
    // Always reserve one queue position and one total row for TERMINAL.
    if ILM_Queued >= ILM_QUEUE_ROWS - 1 or ILM_Sequence >= ILM_CHUNK_ROWS * ILM_MAX_CHUNKS - 1 then
        set ILM_Dropped = ILM_Dropped + 1
        set ILM_Active = false
        set ILM_Reason = "OVERFLOW"
        set ILM_EndPending = true
        return
    endif
    call ILM_Append(source, eventName, data)
    set ILM_Dirty = true
endfunction
