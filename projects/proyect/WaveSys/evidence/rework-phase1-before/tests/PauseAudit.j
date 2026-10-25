// Laboratory only. E09 contract: pause freezes reservations already created; no unit appears until resume,
// and a frozen reservation keeps its remaining time. TheEnd is the harness no-op boundary.
library WavePauseAudit initializer Init requires WaveTest
globals
    private string array lines
    private integer lineCount = 0
    private integer checks = 0
    private integer failures = 0
    private timer phaseTimer = CreateTimer()
    private integer array spawnCount
    private integer array finishCount
    private Wave waveP = 0
    private Wave waveT = 0
    private Wave waveD = 0
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
    call Preload("WAVESYS PAUSE @RUN@ " + stage)
    call Preload("checks=" + I2S(checks) + " failures=" + I2S(failures))
    loop
        exitwhen i >= lineCount
        call Preload(lines[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("Logs\\WaveSysAudit-@RUN@.txt")
endfunction

private function OnSpawn takes nothing returns nothing
    local integer w = GetWaveEventWave()
    set spawnCount[w] = spawnCount[w] + 1
endfunction

private function OnFinish takes nothing returns nothing
    local integer w = GetWaveEventWave()
    set finishCount[w] = finishCount[w] + 1
endfunction

private function NewWave takes nothing returns Wave
    local Wave w = Wave.create(5, 0, 10., null, "", 1, 1, "")
    call w.addPoint(-4800., 3000.)
    call w.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call w.start()
    call w.trySpawn()
    return w
endfunction

private function Late takes nothing returns nothing
    // t = resume + 1.3 s; the frozen reservation had about 1.0 s left.
    call Check(waveP.getActiveIndexedCount() == 1 and spawnCount[waveP] == 1 and waveP.pendingReservations == 0, "frozen reservation materializes after resume with its remaining time")
    call Check(waveP.activeOnMap == 1 and waveP.totalKilled == waveP.remainingToSpawn + waveP.activeOnMap, "counters consistent after materialization")
    call Check(waveT.isDestroyed and finishCount[waveT] == 1 and spawnCount[waveT] == 0, "terminate(false) while paused drains the frozen reservation without creating a unit")
    call waveP.terminate(true)
    if not waveP.isDestroyed then
        call waveP.destroyWave()
    endif
    call Note("COMPLETE pause audit; failures are product observations, not approval.")
    call Save("complete")
    call DestroyTimer(phaseTimer)
endfunction

private function Mid takes nothing returns nothing
    // t = resume + 0.5 s: about 0.5 s of the frozen reservation still remain.
    call Check(waveP.getActiveIndexedCount() == 0 and spawnCount[waveP] == 0 and waveP.pendingReservations == 1, "resumed reservation keeps its remaining time instead of firing at once")
    call TimerStart(phaseTimer, 0.8, false, function Late)
endfunction

private function AfterTerminate takes nothing returns nothing
    call Check(waveT.terminateRequested and not waveT.isDestroyed and spawnCount[waveT] == 0, "terminate(false) while paused waits for the frozen reservation timer")
    // waveD was destroyed directly while paused: its frozen timer was released, nothing may appear.
    call Check(spawnCount[waveD] == 0, "direct destruction while paused releases the frozen reservation")
    call waveP.resume()
    call Check(not waveP.isPaused and waveP.getActiveIndexedCount() == 0, "resume does not materialize instantly")
    call Save("resumed")
    call TimerStart(phaseTimer, 0.5, false, function Mid)
endfunction

private function Paused takes nothing returns nothing
    // t = begin + 2.5 s: unpaused, every reservation would have materialized at begin + 1.5 s.
    call Check(waveP.getActiveIndexedCount() == 0 and spawnCount[waveP] == 0, "paused wave does not materialize a reservation created before pause")
    call Check(waveP.activeOnMap == 1 and waveP.pendingReservations == 1 and waveP.isPaused, "frozen reservation stays counted while paused")
    call Check(waveT.getActiveIndexedCount() == 0 and spawnCount[waveT] == 0, "second paused wave is frozen too")
    call waveT.terminate(false)
    call waveD.destroyWave()
    call Save("paused")
    call TimerStart(phaseTimer, 0.25, false, function AfterTerminate)
endfunction

private function PauseStep takes nothing returns nothing
    // t = begin + 0.5 s: reservations have about 1.0 s left.
    call Check(waveP.pendingReservations == 1 and spawnCount[waveP] == 0, "reservation pending before pause")
    call waveP.pause()
    call waveT.pause()
    call waveD.pause()
    call TimerStart(phaseTimer, 2.0, false, function Paused)
endfunction

private function Begin takes nothing returns nothing
    call Note("BEGIN pause audit: Warcraft III Classic 1.27b, E09 contract")
    set waveP = NewWave()
    set waveT = NewWave()
    set waveD = NewWave()
    call Save("begin")
    call TimerStart(phaseTimer, 0.5, false, function PauseStep)
endfunction

private function Init takes nothing returns nothing
    call RegisterWaveSpawnEvent(function OnSpawn)
    call RegisterWaveFinishEvent(function OnFinish)
    call FogEnable(false)
    call FogMaskEnable(false)
    call PanCameraToTimed(-4800., 3000., 0.)
    call TimerStart(phaseTimer, 1.0, false, function Begin)
endfunction
endlibrary
