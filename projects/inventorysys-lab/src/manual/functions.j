// Late helpers use only the original PUBLIC inventory getters and demo hero.
function ILM_Say takes string message returns nothing
    call DisplayTimedTextToPlayer(Player(0), 0, 0, 15, "IL141M: " + message)
endfunction

function ILM_Guidance takes nothing returns nothing
    call ILM_Say("Ready, NOT recording. Single client / Player 0 only. Original controls remain yours.")
    call ILM_Say("-im start <label> | -im status | -im mark | -im save | -im stop")
    call ILM_Say("NEW label each launch: 1-32 ASCII letters/digits/_/-, first alphanumeric. Never reuse files.")
    call ILM_Say("Writing is unverified until files are checked. No semantic PASS certification.")
endfunction

function ILM_Label takes string text returns boolean
    local string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
    local integer i = 0
    local integer j
    local integer bound = 62
    local string c
    if StringLength(text) < 1 or StringLength(text) > 32 then
        return false
    endif
    loop
        exitwhen i == StringLength(text)
        set c = SubString(text, i, i + 1)
        set j = 0
        loop
            exitwhen j == bound or c == SubString(alphabet, j, j + 1)
            set j = j + 1
        endloop
        if j == bound then
            return false
        endif
        set i = i + 1
        set bound = 64
    endloop
    return true
endfunction

function ILM_WriteChunk takes nothing returns nothing
    local integer i = 0
    // Only the current chunk is retained. Sealed chunks are never rewritten.
    if ILM_ChunkCount == 0 or not ILM_ChunkDirty then
        return
    endif
    call PreloadGenClear()
    call PreloadGenStart()
    loop
        exitwhen i == ILM_ChunkCount
        call Preload(ILM_Chunk[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("Logs\\IL141M-" + ILM_BUILD + "--" + ILM_Session + "--" + I2S(ILM_ChunkIndex) + ".pld")
    set ILM_ChunkDirty = false
endfunction

function ILM_Sample takes nothing returns nothing
    local integer i = 0
    local integer itemValue
    local integer customValue
    local integer strength
    local integer agility
    local integer intelligence
    local integer gold
    if not ILM_Active then
        return
    endif
    // Public getters only: no socket-table reconstruction or tempCustomId writes.
    loop
        exitwhen i == 150 or not ILM_Active
        set itemValue = s__Inventory_getItem(ILM_Inventory, i)
        set customValue = s__Inventory_getItemId(ILM_Inventory, i)
        if itemValue != ILM_Items[i] or customValue != ILM_Custom[i] then
            call ILM_Log("sample", "SLOT", "slot=" + I2S(i) + " item=" + I2S(itemValue) + " cid=" + I2S(customValue))
            set ILM_Items[i] = itemValue
            set ILM_Custom[i] = customValue
        endif
        set i = i + 1
    endloop
    set strength = GetHeroStr(ILM_Hero, true)
    set agility = GetHeroAgi(ILM_Hero, true)
    set intelligence = GetHeroInt(ILM_Hero, true)
    set gold = GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD)
    if strength != ILM_Str or agility != ILM_Agi or intelligence != ILM_Int or gold != ILM_Gold then
        call ILM_Log("sample", "STATS", "str=" + I2S(strength) + " agi=" + I2S(agility) + " int=" + I2S(intelligence) + " gold=" + I2S(gold))
        set ILM_Str = strength
        set ILM_Agi = agility
        set ILM_Int = intelligence
        set ILM_Gold = gold
    endif
    set ILM_LastSample = ILM_Now()
    set ILM_Dirty = false
endfunction

function ILM_Persist takes nothing returns boolean
    local boolean terminal = ILM_EndPending
    // This trigger owns persistence and its operation budget, never an early hook.
    if terminal then
        call ILM_Append("recorder", "TERMINAL", "reason=" + ILM_Reason + " rows=" + I2S(ILM_Sequence + 1) + " dropped=" + I2S(ILM_Dropped))
        set ILM_EndPending = false
    endif
    loop
        exitwhen ILM_Queued == 0
        set ILM_Chunk[ILM_ChunkCount] = ILM_Queue[ILM_Head]
        set ILM_Queue[ILM_Head] = null
        set ILM_Head = ILM_Head + 1
        if ILM_Head == ILM_QUEUE_ROWS then
            set ILM_Head = 0
        endif
        set ILM_Queued = ILM_Queued - 1
        set ILM_ChunkCount = ILM_ChunkCount + 1
        set ILM_ChunkDirty = true
        if ILM_ChunkCount == ILM_CHUNK_ROWS then
            call ILM_WriteChunk()
            set ILM_ChunkCount = 0
            set ILM_ChunkIndex = ILM_ChunkIndex + 1
        endif
    endloop
    call ILM_WriteChunk()
    set ILM_SavePending = false
    if terminal then
        call ILM_Say("Recorder stopped: " + ILM_Reason + "; rows=" + I2S(ILM_Sequence) + "; refused=" + I2S(ILM_Dropped) + ". Gameplay continues.")
        call ILM_Say("Persistence requested, NOT filesystem-verified. OVERFLOW means partial coverage; later actions are unrecorded.")
    endif
    return true
endfunction

function ILM_Tick takes nothing returns nothing
    // Dirty bursts coalesce; also poll once/second for changes outside our hooks.
    if ILM_Active and ((ILM_Dirty and ILM_Now() - ILM_LastSample >= 250) or ILM_Now() - ILM_LastSample >= 1000) then
        call ILM_Sample()
    endif
    if ILM_Queued > 0 or ILM_EndPending or ILM_SavePending then
        call TriggerEvaluate(ILM_Work)
    endif
endfunction

function ILM_Status takes nothing returns nothing
    if not ILM_Used then
        call ILM_Guidance()
    elseif ILM_Active then
        call ILM_Say("Recording " + ILM_BUILD + " / " + ILM_Session + "; rows=" + I2S(ILM_Sequence) + "; queued=" + I2S(ILM_Queued) + "; chunk=" + I2S(ILM_ChunkIndex) + ". Writing unverified.")
    else
        call ILM_Say("NOT recording: " + ILM_Reason + "; rows=" + I2S(ILM_Sequence) + ". No restart this launch. Gameplay continues unrecorded.")
    endif
endfunction

function ILM_Command takes nothing returns nothing
    local string text = GetEventPlayerChatString()
    local string label
    if text == "-im status" then
        call ILM_Status()
        return
    endif
    if SubString(text, 0, 10) == "-im start " then
        set label = SubString(text, 10, StringLength(text))
        if ILM_Used then
            call ILM_Say("Start refused: one session per launch, even after stop. Nothing changed.")
        elseif not ILM_Label(label) then
            call ILM_Say("Start refused: invalid label. Use 1-32 ASCII letters/digits/_/-, first alphanumeric.")
        elseif s__User_AmountPlaying != 1 or GetPlayerController(Player(0)) != MAP_CONTROL_USER or PlayerHero[0] == null then
            call ILM_Say("Start refused: requires the original single-client Player 0 hero. Nothing changed.")
        else
            set ILM_Hero = PlayerHero[0]
            set ILM_Inventory = s__Inventory__staticgetindex(ILM_Hero)
            if ILM_Inventory <= 0 then
                call ILM_Say("Start refused: original inventory not ready. Nothing changed.")
                return
            endif
            set ILM_Session = label
            set ILM_Used = true
            set ILM_Active = true
            call ILM_Log("recorder", "BEGIN", "schema=1")
            call ILM_Sample()
            set ILM_SavePending = true
            call ILM_Say("Recording " + ILM_BUILD + " / " + label + ". Original bag/equipment controls remain yours. Writing unverified.")
        endif
        return
    endif
    if text == "-im mark" or text == "-im save" or text == "-im stop" then
        if not ILM_Active then
            call ILM_Status()
            call ILM_Say("Command refused: recorder not active. No new observations recorded.")
            return
        endif
        if text == "-im mark" then
            call ILM_Log("recorder", "MARK", "manual")
            call ILM_Say("Mark requested. Writing unverified.")
        else
            call ILM_Sample()
            if text == "-im stop" and ILM_Active then
                set ILM_Active = false
                set ILM_Reason = "USER_STOP"
                set ILM_EndPending = true
            endif
            set ILM_SavePending = true
            call ILM_Say("Checkpoint requested; writing unverified. Stop affects recorder only.")
        endif
        return
    endif
    call ILM_Say("Unknown command. Exact forms: -im start <label> | -im status | -im mark | -im save | -im stop")
endfunction

function ILM_Init takes nothing returns nothing
    set ILM_Clock = CreateTimer()
    set ILM_Poll = CreateTimer()
    set ILM_Work = CreateTrigger()
    set ILM_Chat = CreateTrigger()
    call TimerStart(ILM_Clock, 1000000.0, false, null)
    call TriggerAddCondition(ILM_Work, Condition(function ILM_Persist))
    call TriggerRegisterPlayerChatEvent(ILM_Chat, Player(0), "-im", false)
    call TriggerAddAction(ILM_Chat, function ILM_Command)
    call TimerStart(ILM_Poll, 0.25, true, function ILM_Tick)
    call ILM_Guidance()
endfunction
