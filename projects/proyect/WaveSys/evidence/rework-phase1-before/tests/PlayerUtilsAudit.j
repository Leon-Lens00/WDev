// Laboratory only. The tested roster and facade are the production source.
library WavePlayerAudit initializer Init requires WavePlayerUtils, optional PlayerUtils
globals
    private string array lines
    private integer lineCount = 0
    private integer checks = 0
    private integer failures = 0
    private integer transitions = 0
    private integer row = 0
    private boolean array expected
    private boolean array seen
    private WavePlayerRoster roster = 0
    private timer phaseTimer = CreateTimer()
endglobals

private function Note takes string message returns nothing
    set lines[lineCount] = message
    set lineCount = lineCount + 1
    call BJDebugMsg(message)
endfunction

private function Check takes boolean ok, string message returns nothing
    set checks = checks + 1
    if ok then
        call Note("PASS " + message)
    else
        set failures = failures + 1
        call Note("FAIL " + message)
    endif
endfunction

private function Save takes string stage returns nothing
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("WAVESYS PLAYER AUDIT @RUN@ " + stage)
    call Preload("checks=" + I2S(checks) + " failures=" + I2S(failures) + " removalTransitions=" + I2S(transitions))
    loop
        exitwhen i >= lineCount
        call Preload(lines[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("Logs\\WaveSysAudit-@RUN@.txt")
endfunction

// Compare actual public enumeration and membership to an independent expected
// set, including uniqueness, missing members, bounds and cardinality.
private function Matches takes WavePlayerRoster r, integer count returns boolean
    local integer i = 0
    local integer pid
    local boolean ok = r.count == count and r.at(-1) == -1 and r.at(count) == -1
    loop
        exitwhen i >= 12
        set seen[i] = false
        if r.contains(i) != expected[i] then
            set ok = false
        endif
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i >= r.count
        set pid = r.at(i)
        if pid < 0 or pid >= 12 then
            set ok = false
        elseif seen[pid] or not expected[pid] then
            set ok = false
        else
            set seen[pid] = true
        endif
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i >= 12
        if seen[i] != expected[i] then
            set ok = false
        endif
        set i = i + 1
    endloop
    return ok
endfunction

private function MatrixRow takes nothing returns nothing
    local integer pid = 0
    local integer step = 0
    local boolean ok = true
    call roster.clear()
    loop
        exitwhen pid >= 12
        set expected[pid] = true
        if not roster.add(pid) then
            set ok = false
        endif
        set pid = pid + 1
    endloop
    if not Matches(roster, 12) then
        set ok = false
    endif
    loop
        exitwhen step >= 12
        // 5 and 12 are coprime: visit all ids in a nontrivial order.
        set pid = ModuloInteger(row + step * 5, 12)
        set expected[pid] = false
        if not roster.remove(pid) then
            set ok = false
        endif
        if not Matches(roster, 11 - step) then
            set ok = false
            call Note("MISMATCH row=" + I2S(row) + " step=" + I2S(step) + " removed=" + I2S(pid))
        endif
        set transitions = transitions + 1
        set step = step + 1
    endloop
    call Check(ok, "all dense/membership invariants after 12 removals; rotation=" + I2S(row))
    set row = row + 1
    if row < 12 then
        call TimerStart(phaseTimer, 0.05, false, function MatrixRow)
    else
        call roster.destroy()
        set roster = WavePlayerRoster.create()
        call Check(roster.count == 0 and not roster.contains(0) and not roster.contains(11), "destroy/reallocate leaves no stale membership")
        call Check(roster.add(11) and roster.at(0) == 11, "reallocated roster can be populated")
        call roster.destroy()
        set roster = 0
        call Note("COMPLETE player registry audit; native client disconnects remain a separate multiplayer test.")
        call Save("complete")
        call DestroyTimer(phaseTimer)
    endif
endfunction

private function Begin takes nothing returns nothing
    local integer pid = 0
    local integer humans = 0
    local integer i = 0
    local WavePlayer u
    local WavePlayerRoster second
    local boolean ok = true
    local string originalName = GetPlayerName(Player(0))
    local playercolor originalColor = GetPlayerColor(Player(0))
    call Note("BEGIN exact WavePlayerUtils source, Warcraft III Classic 1.27b")
    set roster = WavePlayerRoster.create()
    call Check(roster.count == 0 and roster.at(0) == -1 and not roster.contains(0), "empty set and bounds")
    call Check(not roster.add(-1) and not roster.add(12) and not roster.add(15) and roster.count == 0, "reject invalid and neutral slot ids")
    call Check(roster.add(0) and roster.contains(0) and roster.at(0) == 0, "player id zero and dense index zero are valid")
    call Check(not roster.add(0) and roster.count == 1, "duplicate zero is rejected")
    call Check(not roster.remove(8) and not roster.remove(-1) and not roster.remove(12) and roster.count == 1, "absent/invalid removal does not mutate")
    call Check(roster.add(1) and roster.add(2) and roster.add(3), "populate original E04 reproduction")
    call Check(roster.remove(1) and roster.at(1) == 3 and roster.count == 3, "middle leave moves last player")
    call Check(roster.remove(3) and roster.count == 2 and roster.at(0) == 0 and roster.at(1) == 2 and not roster.contains(3), "E04: moved player's subsequent leave retains players zero/two")
    call Check(not roster.remove(3) and roster.count == 2, "duplicate leave is idempotent")
    call Check(roster.remove(0) and roster.at(0) == 2 and roster.count == 1, "first leave retains remaining player")
    call Check(roster.remove(2) and roster.count == 0 and roster.at(0) == -1, "last leave empties set")
    call Check(roster.add(11) and roster.add(4) and roster.add(0), "sparse nonconsecutive slots")
    set second = WavePlayerRoster.create()
    call Check(second.add(7) and second.count == 1 and not second.contains(11), "independent roster has independent inverse")
    call roster.clear()
    call Check(roster.count == 0 and not roster.contains(11) and not roster.contains(4) and not roster.contains(0), "clear resets all occupied memberships")
    call Check(second.count == 1 and second.contains(7) and roster.add(7), "clear does not affect another roster")
    call second.destroy()
    call roster.clear()

    // The production singleton is never mutated by the roster tests.
    loop
        exitwhen pid >= bj_MAX_PLAYER_SLOTS
        if pid < 12 and GetPlayerController(Player(pid)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING then
            set humans = humans + 1
            if not WavePlayer.fromIndex(pid).isPlaying then
                set ok = false
            endif
        elseif WavePlayer.fromIndex(pid).isPlaying then
            set ok = false
        endif
        set pid = pid + 1
    endloop
    call Check(ok and humans > 0 and WavePlayer.AmountPlaying == humans, "active roster matches native USER/PLAYING slots; humans=" + I2S(humans))
    set ok = true
    loop
        exitwhen i >= WavePlayer.AmountPlaying
        set u = WavePlayer.fromPlaying(i)
        if not u.isPlaying or u.handle != Player(u.id) or u.toPlayer() != u.handle or WavePlayer[u.handle] != u then
            set ok = false
        endif
        set i = i + 1
    endloop
    call Check(ok, "facade enumeration, native handles and ids agree")
    call Check(WavePlayer.fromPlaying(-1) == WavePlayer.NULL and WavePlayer.fromPlaying(humans) == WavePlayer.NULL, "facade enumeration bounds")
    call Check(WavePlayer.fromIndex(-1) == WavePlayer.NULL and WavePlayer.fromIndex(16) == WavePlayer.NULL and WavePlayer[null] == WavePlayer.NULL, "facade invalid identity is explicit NULL=-1")
    call Check(WavePlayer.fromIndex(0).id == 0 and WavePlayer.fromIndex(0).handle == Player(0), "facade zero does not alias NULL")
    call Check(WavePlayer(WavePlayer.NULL).handle == null and not WavePlayer(WavePlayer.NULL).isPlaying, "invalid facade access is safe")
    call Check(WavePlayer.Local == GetLocalPlayer() and WavePlayer.LocalId == GetPlayerId(GetLocalPlayer()), "local identity cached for visual gates")
    call SetPlayerName(Player(0), "WaveRegistryAudit")
    call SetPlayerColor(Player(0), PLAYER_COLOR_RED)
    call Check(WavePlayer.fromIndex(0).name == "WaveRegistryAudit" and WavePlayer.fromIndex(0).nameColored == "|cFFFF0303WaveRegistryAudit|r", "native rename and red color id zero")
    call SetPlayerColor(Player(0), PLAYER_COLOR_BLUE)
    call Check(WavePlayer.fromIndex(0).nameColored == "|cFF0042FFWaveRegistryAudit|r", "colored name follows current native color")
    call SetPlayerName(Player(0), originalName)
    call SetPlayerColor(Player(0), originalColor)
    static if LIBRARY_PlayerUtils then
        call Check(User.AmountPlaying == humans and User[Player(0)].handle == WavePlayer.fromIndex(0).handle, "legacy User and WavePlayer coexist with separate storage")
    else
        call Check(true, "standalone compilation has no legacy PlayerUtils/UI dependency")
    endif
    call Save("before-matrix")
    call TimerStart(phaseTimer, 0.05, false, function MatrixRow)
endfunction

private function Init takes nothing returns nothing
    call FogEnable(false)
    call FogMaskEnable(false)
    call TimerStart(phaseTimer, 1.0, false, function Begin)
endfunction
endlibrary
