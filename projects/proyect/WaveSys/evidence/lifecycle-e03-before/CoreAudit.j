// Laboratory only. Exact Wave/Table/TimerUtils/WavePointGroups sources.
// TheEnd is a harness boundary; all test waves use an empty finish callback.
library WaveCoreAudit initializer Init requires WaveTest, WavePointGroups
globals
    private string array lines
    private integer lineCount = 0
    private integer checks = 0
    private integer failures = 0
    private Wave pausedWave = 0
    private Wave removedWave = 0
    private Wave externalWave = 0
    private unit externalUnit = null
    private unit sourceUnit = null
    private unit markerA = null
    private unit markerB = null
    private unit markerC = null
    private integer externalDeaths = 0
    private boolean nestedStart = false
    private integer nestedWaveId = 0
    private integer nestedReadId = -1
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
    call Preload("WAVESYS CORE AUDIT @RUN@ " + stage)
    call Preload("checks=" + I2S(checks) + " failures=" + I2S(failures))
    loop
        exitwhen i >= lineCount
        call Preload(lines[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("Logs\\WaveSysAudit-@RUN@.txt")
endfunction

private function StartNestedPause takes nothing returns nothing
    local Wave w = GetWaveEventWave()
    if nestedStart and w == nestedWaveId then
        call w.pause()
    endif
endfunction

private function ReadOuterStart takes nothing returns nothing
    if nestedStart then
        set nestedReadId = GetWaveEventWave()
    endif
endfunction

private function OnWaveDeath takes nothing returns nothing
    if GetWaveEventUnit() == externalUnit then
        set externalDeaths = externalDeaths + 1
    endif
endfunction

private function Final takes nothing returns nothing
    call Check(externalDeaths == 1, "external unit death reaches WaveDeath listeners; actual=" + I2S(externalDeaths))
    call Check(not IsWaveManagedUnit(externalUnit), "external unit death clears WaveByUnit mapping")
    call Check(externalWave.activeOnMap == 1, "external death leaves exactly the source alive")
    call Note("External active index=" + I2S(externalWave.getActiveIndexedCount()))
    // Direct destruction here is laboratory cleanup after the observed fault.
    call externalWave.destroyWave()
    call RemoveUnit(sourceUnit)
    call RemoveUnit(externalUnit)
    set sourceUnit = null
    set externalUnit = null
    call Note("COMPLETE: engine tests ended; failures are product observations, not approval.")
    call Save("complete")
    call DestroyTimer(phaseTimer)
endfunction

private function AfterSpawns takes nothing returns nothing
    local unit u = pausedWave.getActiveIndexedUnit(1)
    local unit removed = removedWave.getActiveIndexedUnit(1)
    local integer key = pausedWave * WAVE_ACTIVE_STRIDE + 1
    call Check(GetUnitTypeId(markerA) == 0 and GetUnitTypeId(markerB) == 0 and GetUnitTypeId(markerC) == 0, "collected markers removed after engine update")
    call Check(u == null, "paused wave does not materialize its pending spawn")
    call Note("Paused state=" + I2S(WaveDebugBoolToInt(pausedWave.isPaused)) + " tracked=" + I2S(pausedWave.getActiveIndexedCount()))
    if u != null then
        call KillUnit(u)
        call Check(pausedWave.activeOnMap == 0, "ordinary death releases active counter")
        call Check(not WaveActiveUnitByKey.handle.has(key), "ordinary death removes saved unit handle")
    endif
    call pausedWave.terminate(false)
    call Check(removed != null, "RemoveUnit scenario really spawned a unit")
    call RemoveUnit(removed)
    call Check(removedWave.activeOnMap == 0, "RemoveUnit releases active counter")
    call Note("After RemoveUnit: active=" + I2S(removedWave.activeOnMap) + " tracked=" + I2S(removedWave.getActiveIndexedCount()))
    call removedWave.destroyWave()
    set sourceUnit = externalWave.getActiveIndexedUnit(1)
    call Check(sourceUnit != null, "external scenario has a live Wave source")
    set externalUnit = CreateUnit(Player(8), 'hfoo', -4600., 3100., 0.)
    call registerExternalUnit(sourceUnit, externalUnit, false)
    call Check(IsWaveManagedUnit(externalUnit), "external unit registered before death")
    call Save("before-external-death")
    // Schedule observer before the kill: an aborted death callback cannot hide the result.
    call TimerStart(phaseTimer, 0.25, false, function Final)
    call KillUnit(externalUnit)
    set u = null
    set removed = null
endfunction

private function Begin takes nothing returns nothing
    local rect area = Rect(-5100., 2800., -4400., 3300.)
    local unit a = CreateUnit(Player(15), 'hpea', -5000., 3000., 0.)
    local unit b = CreateUnit(Player(15), 'hpea', -4900., 3100., 0.)
    local unit c = CreateUnit(Player(15), 'hpea', -5000., 3000., 0.)
    local Wave w
    local integer i = 0
    local integer added
    local integer before
    call Note("BEGIN: Warcraft III Classic 1.27b, exact core sources, isolated map")
    call Check(a != null and b != null and c != null, "all three marker fixtures created")
    // CreateUnit applies placement corrections. Force the duplicate coordinates
    // so the fixture tests the system's epsilon, not engine spawn displacement.
    call SetUnitX(a, -5000.)
    call SetUnitY(a, 3000.)
    call SetUnitX(c, -5000.)
    call SetUnitY(c, 3000.)
    call Check(GetUnitX(a) == GetUnitX(c) and GetUnitY(a) == GetUnitY(c), "duplicate marker coordinates established")
    set markerA = a
    set markerB = b
    set markerC = c
    call WavePointGroupRegister("AuditMarkers", area, 'hpea')
    call WavePointGroupsBuild()
    call Check(WavePointGroupCount("AuditMarkers") == 2, "marker collection deduplicates repeated coordinates")
    call Check(WavePointGroupGetPointY("AuditMarkers", 0) > WavePointGroupGetPointY("AuditMarkers", 1), "marker order is descending Y")
    set w = Wave.create(3, 0, 0.25, null, "", 1, 1, "")
    loop
        exitwhen i == 99
        call w.addPoint(-5000., 3000.)
        set i = i + 1
    endloop
    set before = w.pointCount
    set added = WavePointGroupApplyToWave(w, "AuditMarkers")
    call Note("Point apply: reported=" + I2S(added) + " actual added=" + I2S(w.pointCount - before))
    call Check(added == w.pointCount - before, "point application reports the actual inserted count")
    call w.destroyWave()

    set w = Wave.create(3, 0, 0.25, null, "", 1, 1, "")
    call w.addSlot('hfoo', 2, 1, 1, 0, 1, true, Player(8))
    call Note("Self killGate fixture: remaining=" + I2S(w.getToKillRemaining()) + " selected slot=" + I2S(w.pickSlot()))
    call w.destroyWave()

    set w = Wave.create(3, 0, 0.25, null, "", 1, 1, "")
    set nestedWaveId = w
    set nestedStart = true
    call w.start()
    set nestedStart = false
    call Check(nestedReadId == nestedWaveId, "nested pause preserves outer start context; read=" + I2S(nestedReadId))
    call w.terminate(false)

    set pausedWave = Wave.create(3, 0, 10., null, "", 1, 1, "")
    call pausedWave.addPoint(-5000., 3000.)
    call pausedWave.addSlot('hfoo', 1, 1, 1, 1, -1, false, Player(8))
    call pausedWave.start()
    call pausedWave.trySpawn()
    call pausedWave.pause()
    call Check(pausedWave.activeOnMap == 1 and pausedWave.getActiveIndexedCount() == 0, "pause fixture has exactly one pending reservation")

    set removedWave = Wave.create(3, 0, 10., null, "", 1, 1, "")
    call removedWave.addPoint(-4800., 3000.)
    call removedWave.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call removedWave.start()
    call removedWave.trySpawn()

    set externalWave = Wave.create(3, 0, 10., null, "", 1, 1, "")
    call externalWave.addPoint(-4600., 3000.)
    call externalWave.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call externalWave.start()
    call externalWave.trySpawn()
    call Save("pending")
    call TimerStart(phaseTimer, 2.0, false, function AfterSpawns)
    call RemoveRect(area)
    set area = null
    set a = null
    set b = null
    set c = null
endfunction

private function Init takes nothing returns nothing
    call RegisterWaveStartEvent(function StartNestedPause)
    call RegisterWaveStartEvent(function ReadOuterStart)
    call RegisterWaveDeathEvent(function OnWaveDeath)
    call FogEnable(false)
    call FogMaskEnable(false)
    call PanCameraToTimed(-4800., 3000., 0.)
    call TimerStart(phaseTimer, 1.0, false, function Begin)
endfunction
endlibrary
