// Verify retirement after the engine has actually removed the unit.
library WaveRemovalAudit initializer Init requires WaveCore
globals
    private Wave w = 0
    private unit victim = null
    private timer t = CreateTimer()
    private boolean setup = false
endglobals
private function Observe takes nothing returns nothing
    local boolean gone = GetUnitTypeId(victim) == 0
    local integer active = w.activeOnMap
    local integer tracked = w.getActiveIndexedCount()
    local boolean finished
    local boolean terminated
    // Several natural onTick calls have already happened after RemoveUnit.
    call w.onTick()
    set finished = w.isDestroyed
    call w.terminate(true)
    set terminated = w.isDestroyed
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("WAVESYS REMOVAL @RUN@ COMPLETE")
    call Preload("setup=" + I2S(WaveDebugBoolToInt(setup)))
    call Preload("engineRemoved=" + I2S(WaveDebugBoolToInt(gone)))
    call Preload("active=" + I2S(active) + " tracked=" + I2S(tracked))
    call Preload("finished=" + I2S(WaveDebugBoolToInt(finished)))
    call Preload("forceTerminated=" + I2S(WaveDebugBoolToInt(terminated)))
    call PreloadGenEnd("Logs\\WaveSysAudit-@RUN@.txt")
    call BJDebugMsg("Removal audit: setup=" + I2S(WaveDebugBoolToInt(setup)) + " removed=" + I2S(WaveDebugBoolToInt(gone)) + " active=" + I2S(active) + " finished=" + I2S(WaveDebugBoolToInt(finished)) + " terminated=" + I2S(WaveDebugBoolToInt(terminated)))
    if not w.isDestroyed then
        call w.destroyWave()
    endif
    set victim = null
    call DestroyTimer(t)
endfunction
private function Retire takes nothing returns nothing
    set victim = w.getActiveIndexedUnit(1)
    set setup = victim != null and GetUnitTypeId(victim) != 0 and w.activeOnMap == 1
    call RemoveUnit(victim)
    call TimerStart(t, 0.5, false, function Observe)
endfunction
private function Begin takes nothing returns nothing
    set w = Wave.create(2, 0, 0.25, 1, 1)
    call w.addPoint(-4800., 3000.)
    call w.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call w.start()
    call TimerStart(t, 3., false, function Retire)
endfunction
private function Init takes nothing returns nothing
    call TimerStart(t, 1., false, function Begin)
endfunction
endlibrary
