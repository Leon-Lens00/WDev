// Laboratory only. Lifecycle contract E13/E03/E02 (docs/planes/ciclo-vida-e13-e03-e02-2026-10-24.md).
// Regressions R3, R5-R12 plus invariants I1/I3. Clean core since rework phase 1: no TheEnd stub needed.
library WaveLifecycleAudit initializer Init requires WaveTest, Table
globals
    private string array lines
    private integer lineCount = 0
    private integer checks = 0
    private integer failures = 0
    private timer phaseTimer = CreateTimer()
    private integer array finishCount

    // R3 two live waves
    private Wave waveA = 0
    private Wave waveB = 0
    // R5 external boss death
    private Wave waveE = 0
    private unit r5Ext = null
    private integer r5Exits = 0
    private boolean r5Boss = false
    private boolean r5Retired = true
    // R6 RemoveUnit with natural ticks
    private Wave waveR = 0
    private unit r6Unit = null
    private integer r6Exits = 0
    private boolean r6Retired = false
    private integer r6Type = 0
    private unit r6Killer = null
    // R7 RemoveUnit during terminate(false)
    private Wave waveT = 0
    // R8 RemoveUnit while paused
    private Wave waveP = 0
    // R9 WaveRetireUnit then RemoveUnit
    private Wave waveX = 0
    private unit r9Unit = null
    private integer r9Exits = 0
    // R10 kill then remove / kill and keep ticking
    private Wave waveK = 0
    private unit r10Unit = null
    private integer r10Exits = 0
    private integer r10RetiredExits = 0
    private Wave waveD = 0
    // R11 external removal
    private Wave waveX2 = 0
    private unit r11Ext = null
    private integer r11Exits = 0
    private boolean r11Retired = false
    private boolean r11External = false
    // R12 killGate opened by a retirement
    private Wave waveG = 0
    // Premise probe: what a hashtable and a variable return for a removed unit
    private Table probeTable = 0
    private unit probeUnit = null
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
    call Preload("WAVESYS LIFECYCLE @RUN@ " + stage)
    call Preload("checks=" + I2S(checks) + " failures=" + I2S(failures))
    loop
        exitwhen i >= lineCount
        call Preload(lines[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("Logs\\WaveSysAudit-@RUN@.txt")
endfunction

private function Inv takes Wave w, string tag returns nothing
    call Check(w.activeOnMap == w.pendingReservations + w.getActiveIndexedCount(), tag + " I1 active=" + I2S(w.activeOnMap) + " reserved=" + I2S(w.pendingReservations) + " tracked=" + I2S(w.getActiveIndexedCount()))
    call Check(w.totalKilled == w.remainingToSpawn + w.activeOnMap, tag + " I3 objective=" + I2S(w.totalKilled) + " remaining=" + I2S(w.remainingToSpawn) + " active=" + I2S(w.activeOnMap))
endfunction

private function NewWave takes real interval returns Wave
    local Wave w = Wave.create(5, 0, interval, 1, 1)
    call w.addPoint(-4800., 3000.)
    return w
endfunction

private function OnFinish takes nothing returns nothing
    local integer w = GetWaveEventWave()
    set finishCount[w] = finishCount[w] + 1
endfunction

private function OnDeath takes nothing returns nothing
    local unit u = GetWaveEventUnit()
    if u == r5Ext then
        set r5Exits = r5Exits + 1
        set r5Boss = IsWaveEventBoss()
        set r5Retired = IsWaveEventRetired()
    elseif u == r6Unit then
        set r6Exits = r6Exits + 1
        set r6Retired = IsWaveEventRetired()
        set r6Type = GetWaveEventUnitTypeId()
        set r6Killer = GetWaveEventKiller()
    elseif u == r9Unit then
        set r9Exits = r9Exits + 1
    elseif u == r10Unit then
        set r10Exits = r10Exits + 1
        if IsWaveEventRetired() then
            set r10RetiredExits = r10RetiredExits + 1
        endif
    elseif u == r11Ext then
        set r11Exits = r11Exits + 1
        set r11Retired = IsWaveEventRetired()
        set r11External = IsWaveEventExternal()
    endif
    set u = null
endfunction

private function Cleanup takes Wave w returns nothing
    if (w != 0) and (not w.isDestroyed) then
        call w.terminate(true)
        if not w.isDestroyed then
            call w.destroyWave()
        endif
    endif
endfunction

private function Final takes nothing returns nothing
    // R8 after resume: the remaining unit is spawned again.
    call Check(not waveP.isPaused and waveP.slots[0].remaining == 0 and waveP.getActiveIndexedCount() == 1, "R8 resume spawns the remaining unit; tracked=" + I2S(waveP.getActiveIndexedCount()))
    call Inv(waveP, "R8 after resume")
    call Cleanup(waveB)
    call Cleanup(waveE)
    call Cleanup(waveP)
    call Cleanup(waveD)
    call Cleanup(waveX2)
    call Cleanup(waveG)
    call Note("COMPLETE lifecycle audit; failures are product observations, not approval.")
    call Save("complete")
    call DestroyTimer(phaseTimer)
endfunction

private function Phase3 takes nothing returns nothing
    local unit u
    // R6: natural ticks reconciled the removal and finished the wave.
    call Check(waveR.isDestroyed and finishCount[waveR] == 1, "R6 RemoveUnit is reconciled by natural ticks and the wave finishes once")
    call Check(waveR.retiredCount == 1 and waveR.killsDone == 0 and waveR.totalKilled == 0, "R6 retirement meets the objective without counting a kill")
    call Check(r6Exits == 1 and r6Retired and r6Killer == null, "R6 one retired exit event with null killer; exits=" + I2S(r6Exits))
    call Check(r6Type == 'hfoo', "R6 event exposes the registered unit type after removal; type=" + I2S(r6Type))
    call Check(not IsWaveManagedUnit(r6Unit), "R6 retired unit mappings cleared")
    // R7: removal while draining a graceful termination.
    call Check(waveT.isDestroyed and finishCount[waveT] == 1 and waveT.retiredCount == 1, "R7 removal of the last live unit completes terminate(false)")
    // R8: removal while paused.
    call Check(waveP.isPaused and waveP.activeOnMap == 0 and waveP.retiredCount == 1, "R8 removal is reconciled while paused")
    call Check(waveP.slots[0].remaining == 1 and waveP.pendingReservations == 0, "R8 no new reservation while paused")
    call Inv(waveP, "R8 paused")
    call waveP.resume()
    // R9: explicit retire then RemoveUnit; one more tick must not count it twice.
    call waveX.onTick()
    call Check(waveX.isDestroyed and waveX.retiredCount == 1 and r9Exits == 1, "R9 sweep does not retire an explicitly retired unit again")
    // R10a: kill then immediate RemoveUnit is one death.
    call waveK.onTick()
    call Check(waveK.isDestroyed and waveK.killsDone == 1 and waveK.retiredCount == 0, "R10 kill then RemoveUnit stays a single death")
    call Check(r10Exits == 1 and r10RetiredExits == 0, "R10 exactly one non-retired exit event; exits=" + I2S(r10Exits))
    // R10b: a dead (not removed) unit is never swept as retired.
    call Check(waveD.killsDone == 1 and waveD.retiredCount == 0 and waveD.activeOnMap == 1, "R10 corpse is not swept as a retirement across ticks")
    call Inv(waveD, "R10 corpse")
    // R11: external removal.
    call Check(r11Exits == 1 and r11Retired and r11External, "R11 external removal fires one retired external exit")
    call Check(waveX2.retiredCount == 1 and waveX2.activeOnMap == 1 and waveX2.activeUnits == 1 and not IsWaveManagedUnit(r11Ext), "R11 external removal releases counters and mappings; source stays")
    call Inv(waveX2, "R11")
    // R12: the retirement lowered the objective, so the gated slot opened.
    call Check(waveG.slots[1].remaining == 0 and waveG.slots[1].active == 1, "R12 killGate slot opens after a retirement; remaining=" + I2S(waveG.slots[1].remaining) + " objective=" + I2S(waveG.totalKilled))
    call Inv(waveG, "R12")
    call Save("phase3")
    call TimerStart(phaseTimer, 2.75, false, function Final)
    set u = null
endfunction

private function Phase2 takes nothing returns nothing
    local unit u
    local boolean ok
    call Note("PROBE removed unit: hashtable load null=" + I2S(WaveDebugBoolToInt(probeTable.unit[1] == null)) + " variable type=" + I2S(GetUnitTypeId(probeUnit)) + " variable hid=" + I2S(GetHandleId(probeUnit)))
    // R3: terminating A neither touched B nor left A alive.
    call Check(waveA.isDestroyed and finishCount[waveA] == 1, "R3 terminated wave drains its own reservations and finishes once")
    call Check(not waveB.isDestroyed and waveB.getActiveIndexedCount() == 2 and waveB.activeOnMap == 2 and waveB.pendingReservations == 0 and waveB.slots[0].active == 2, "R3 other live wave materialized both reservations untouched")
    call Inv(waveB, "R3 B")
    // R5: external boss death.
    set u = waveE.getActiveIndexedUnit(1)
    call Check(u != null, "R5 external source materialized")
    set r5Ext = CreateUnit(Player(8), 'hfoo', -4700., 3100., 0.)
    call registerExternalUnit(u, r5Ext, true)
    call Check(waveE.activeBosses == 1 and waveE.activeOnMap == 2, "R5 external boss registered")
    call KillUnit(r5Ext)
    call Check(r5Exits == 1 and r5Boss and not r5Retired, "R5 external boss death reaches listeners as a boss death")
    call Check(waveE.activeBosses == 0 and waveE.killsDoneBoss == 1 and waveE.activeOnMap == 1 and not IsWaveManagedUnit(r5Ext), "R5 external boss counters and mappings released")
    call Inv(waveE, "R5")
    // R6: remove the only unit of a naturally ticking wave.
    set r6Unit = waveR.getActiveIndexedUnit(1)
    call Check(r6Unit != null and waveR.retiredCount == 0, "R6 unit materialized")
    call RemoveUnit(r6Unit)
    // R7
    set u = waveT.getActiveIndexedUnit(1)
    call Check(u != null, "R7 unit materialized")
    call waveT.terminate(false)
    call Check(not waveT.isDestroyed, "R7 graceful termination waits for the live unit")
    call RemoveUnit(u)
    // R8
    set u = waveP.getActiveIndexedUnit(1)
    call Check(u != null and waveP.slots[0].remaining == 1, "R8 first unit live, second waiting on slot limit")
    call waveP.pause()
    call RemoveUnit(u)
    // R9
    set r9Unit = waveX.getActiveIndexedUnit(1)
    set ok = WaveRetireUnit(r9Unit)
    call Check(ok and waveX.activeOnMap == 0 and waveX.retiredCount == 1 and not IsWaveManagedUnit(r9Unit), "R9 WaveRetireUnit releases synchronously")
    call Check(r9Exits == 1, "R9 explicit retirement fires one exit event")
    call RemoveUnit(r9Unit)
    call Check(not WaveRetireUnit(r9Unit), "R9 second retirement is rejected")
    // R10a / R10b
    set r10Unit = waveK.getActiveIndexedUnit(1)
    call KillUnit(r10Unit)
    call RemoveUnit(r10Unit)
    set u = waveD.getActiveIndexedUnit(1)
    call KillUnit(u)
    // R11
    set u = waveX2.getActiveIndexedUnit(1)
    call Check(u != null, "R11 external source materialized")
    set r11Ext = CreateUnit(Player(8), 'hfoo', -4700., 2900., 0.)
    call registerExternalUnit(u, r11Ext, false)
    call Check(IsWaveManagedUnit(r11Ext) and waveX2.activeOnMap == 2, "R11 external registered")
    call RemoveUnit(r11Ext)
    // R12
    set u = waveG.getActiveIndexedUnit(1)
    call Check(u != null and waveG.slots[1].remaining == 1 and waveG.slots[1].active == 0, "R12 gated slot closed before the retirement; objective=" + I2S(waveG.totalKilled))
    call RemoveUnit(u)
    call Save("phase2")
    call TimerStart(phaseTimer, 0.75, false, function Phase3)
    set u = null
endfunction

private function Begin takes nothing returns nothing
    call Note("BEGIN lifecycle audit: Warcraft III Classic 1.27b, core sources with E02/E13/E03 changes")
    set probeTable = Table.create()
    set probeUnit = CreateUnit(Player(15), 'hpea', -5200., 3300., 0.)
    set probeTable.unit[1] = probeUnit
    call RemoveUnit(probeUnit)
    // R3: two waves with two reservations each; terminate A only.
    set waveA = NewWave(10.)
    call waveA.addSlot('hfoo', 2, 2, 1, 0, -1, false, Player(8))
    call waveA.start()
    call waveA.trySpawn()
    call waveA.trySpawn()
    set waveB = NewWave(10.)
    call waveB.addSlot('hfoo', 2, 2, 1, 0, -1, false, Player(8))
    call waveB.start()
    call waveB.trySpawn()
    call waveB.trySpawn()
    call waveA.terminate(false)
    call Check(waveB.activeOnMap == 2 and waveB.pendingReservations == 2 and waveB.remainingToSpawn == 0, "R3 terminating A leaves B reservations intact")
    call Inv(waveB, "R3 B reserved")
    // R5 / R9 / R10 / R11 sources: one manual reservation each.
    set waveE = NewWave(10.)
    call waveE.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call waveE.start()
    call waveE.trySpawn()
    set waveX = NewWave(10.)
    call waveX.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call waveX.start()
    call waveX.trySpawn()
    set waveK = NewWave(10.)
    call waveK.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call waveK.start()
    call waveK.trySpawn()
    set waveD = NewWave(0.25)
    call waveD.addSlot('hfoo', 2, 2, 1, 0, -1, false, Player(8))
    call waveD.start()
    call waveD.trySpawn()
    call waveD.trySpawn()
    set waveX2 = NewWave(0.25)
    call waveX2.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call waveX2.start()
    call waveX2.trySpawn()
    // R6 / R7: naturally ticking waves.
    set waveR = NewWave(0.25)
    call waveR.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call waveR.start()
    set waveT = NewWave(0.25)
    call waveT.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call waveT.start()
    call waveT.trySpawn()
    // R8: two units, one at a time.
    set waveP = NewWave(0.25)
    call waveP.addSlot('hfoo', 2, 1, 1, 0, -1, false, Player(8))
    call waveP.start()
    // R12: slot B (killGate 1) only opens when the objective drops from 2 to 1.
    set waveG = NewWave(0.25)
    call waveG.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call waveG.addSlot('hrif', 1, 1, 0, 0, 1, false, Player(8))
    call waveG.start()
    call Save("begin")
    call TimerStart(phaseTimer, 2.0, false, function Phase2)
endfunction

private function Init takes nothing returns nothing
    call RegisterWaveFinishEvent(function OnFinish)
    call RegisterWaveDeathEvent(function OnDeath)
    call FogEnable(false)
    call FogMaskEnable(false)
    call PanCameraToTimed(-4800., 3000., 0.)
    call TimerStart(phaseTimer, 1.0, false, function Begin)
endfunction
endlibrary
