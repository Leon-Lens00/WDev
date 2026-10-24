// Functional audit of exact core sources; does not patch production code.
library WaveFeatureAudit initializer Init requires WaveTest, WavePointGroups
globals
    private string array lines
    private integer lineCount = 0
    private integer checks = 0
    private integer failures = 0
    private integer array started
    private integer array paused
    private integer array resumed
    private integer array finished
    private integer array spawned
    private integer array died
    private timer phaseTimer = CreateTimer()
    private Wave fxWave
    private Wave cancelledWave
    private Wave externalWave
    private Wave recycledWave
    private integer recycledId
    private integer oldToken
    private integer oldSlot
    private unit nearUnit
    private unit externalUnit
    private unit externalSource
    private unit manualUnit
    private unit fxUnit
    private real reservedX
    private real reservedY
    private integer timerBaseline
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
    call Preload("WAVESYS FEATURES @RUN@ " + stage)
    call Preload("checks=" + I2S(checks) + " failures=" + I2S(failures))
    loop
        exitwhen i >= lineCount
        call Preload(lines[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("Logs\\WaveSysAudit-@RUN@.txt")
endfunction
private function StartEvent takes nothing returns nothing
    local integer w = GetWaveEventWave()
    set started[w] = started[w] + 1
endfunction
private function PauseEvent takes nothing returns nothing
    local integer w = GetWaveEventWave()
    set paused[w] = paused[w] + 1
endfunction
private function ResumeEvent takes nothing returns nothing
    local integer w = GetWaveEventWave()
    set resumed[w] = resumed[w] + 1
endfunction
private function FinishEvent takes nothing returns nothing
    local integer w = GetWaveEventWave()
    set finished[w] = finished[w] + 1
endfunction
private function SpawnEvent takes nothing returns nothing
    local Wave w = GetWaveEventWave()
    set spawned[w] = spawned[w] + 1
    if w == fxWave then
        set fxUnit = GetWaveEventUnit()
    endif
endfunction
private function DeathEvent takes nothing returns nothing
    local integer w = GetWaveEventWave()
    set died[w] = died[w] + 1
endfunction
private function NewWave takes integer cap, integer chance returns Wave
    return Wave.create(cap, chance, 60.0, null, "", 1, 10, "")
endfunction

private function Final takes nothing returns nothing
    local integer before = finished[fxWave]
    local unit u = fxWave.getActiveIndexedUnit(1)
    call Check(u != null and fxWave.remainingToSpawn == 0 and fxWave.activeOnMap == 1, "second spawn consumes remaining amount")
    if u != null then
        call KillUnit(u)
    endif
    call Check(fxWave.activeOnMap == 0 and fxWave.getToKillRemaining() == 0 and fxWave.getKillsDone() == 2, "two normal deaths reconcile objectives and true kill counters")
    call fxWave.onTick()
    call Check(fxWave.isDestroyed and finished[fxWave] == before + 1, "natural completion fires once and destroys empty wave")
    call fxWave.finish()
    call Check(finished[fxWave] == before + 1, "repeated finish is idempotent before reuse")
    call RemoveUnit(nearUnit)
    call RemoveUnit(externalUnit)
    call RemoveUnit(manualUnit)
    call RemoveUnit(externalSource)
    call Check(GetTimerUtilsInUse() == timerBaseline, "all Wave/FX pooled timers returned; actual=" + I2S(GetTimerUtilsInUse()) + " baseline=" + I2S(timerBaseline))
    call Note("COMPLETE functional audit; observed failures are retained product findings.")
    call Save("complete")
    call DestroyTimer(phaseTimer)
    set u = null
endfunction

private function AfterMaterialize takes nothing returns nothing
    local integer before
    local unit u = fxWave.getActiveIndexedUnit(1)
    call Check(u != null and fxUnit == u and spawned[fxWave] >= 1, "FX reservation materializes and dispatches spawn context")
    call Check(u != null and GetUnitTypeId(u) == 'hfoo' and GetOwningPlayer(u) == Player(8), "materialized rawcode and owner match slot")
    call Check(u != null and IsWaveManagedUnit(u) and GetWaveByUnit(u) == fxWave and GetWaveSlotByUnit(u) == fxWave.slots[0], "materialized unit has wave/slot/index mapping")
    call Check(u != null and SwlsDistance(GetUnitX(u), GetUnitY(u), reservedX, reservedY) < 128., "materialization uses reserved point despite reference moving")
    call Check(cancelledWave.isDestroyed, "graceful termination drains pending reservation and destroys wave")
    call Check(recycledWave.remainingToSpawn == 2 and recycledWave.slots[0].remaining == 2 and recycledWave.activeOnMap == 0, "destroyed old pending timer cannot mutate recycled wave; actual remaining=" + I2S(recycledWave.remainingToSpawn))
    call Note("Recycled wave id=" + I2S(recycledWave) + " old token=" + I2S(oldToken) + " new token=" + I2S(recycledWave.waveToken) + " oldSlot=" + I2S(oldSlot) + " newSlot=" + I2S(recycledWave.slots[0]))
    call recycledWave.destroyWave()

    // Separate wave: known E02 in external death must not affect normal death.
    set externalSource = externalWave.getActiveIndexedUnit(1)
    call Check(externalSource != null, "external scenario really materialized a source")
    set externalUnit = CreateUnit(Player(9), 'hfoo', -4700., 3100., 0.)
    set before = externalWave.activeOnMap
    call registerExternalUnit(externalSource, externalUnit, true)
    call Check(externalWave.activeOnMap == before + 1 and GetWaveByUnit(externalUnit) == externalWave and ExternalIsBoss[GetHandleId(externalUnit)] == 1, "external boss registration updates mappings and counters")
    call registerExternalUnit(externalSource, externalUnit, true)
    call Check(externalWave.activeOnMap == before + 1, "duplicate external registration does not double count")
    call Check(not WaveCanSpawnUnitFromDefaultOwnerPid(externalSource, 8) and WaveCanSpawnUnitFromDefaultOwnerPid(externalSource, 10), "spawn helper enforces occupied owner cap and allows free owner")
    set manualUnit = WaveSpawnUnitFromDefaultOwnerPid(externalSource, 'hfoo', 10, -4750., 3050.)
    call Check(manualUnit != null and GetOwningPlayer(manualUnit) == Player(10) and not IsWaveManagedUnit(manualUnit), "spawn helper creates unit; registration is an explicit second step")
    call externalWave.destroyWave()
    call Check(not IsWaveManagedUnit(externalSource) and not IsWaveManagedUnit(externalUnit), "explicit destruction clears normal/external wave mappings")
    set before = died[fxWave]
    if u != null then
        call KillUnit(u)
    endif
    call Check(died[fxWave] == before + 1 and not IsWaveManagedUnit(u) and fxWave.activeOnMap == 0, "normal death dispatches context, clears mapping and frees cap")
    call fxWave.trySpawn()
    call Save("second-reservation")
    call TimerStart(phaseTimer, 1.75, false, function Final)
    set u = null
endfunction

private function BeforeMaterialize takes nothing returns nothing
    call Check(fxWave.getActiveIndexedCount() == 0 and fxWave.activeOnMap == 1, "effect stage has reservation but no materialized unit before 1.5 seconds")
    call Save("effect-visible")
    call TimerStart(phaseTimer, 1.15, false, function AfterMaterialize)
endfunction

private function Begin takes nothing returns nothing
    local Wave w
    local Wave z
    local WaveSlot s
    local integer i = 0
    local integer before
    local boolean ok = true
    local real distance
    local unit anchor
    call Note("BEGIN exact core feature audit; no source corrections")
    set timerBaseline = GetTimerUtilsInUse()
    set w = Wave.create(0, -5, 0., null, "", 2, 10, "")
    call Check(w.perPlayerLimit == 1 and w.nearUnitChance == 0 and w.interval == 0.25, "create clamps invalid cap/chance/interval")
    call Check(w.activeOnMap == 0 and w.getToKillRemaining() == 0 and not w.isRunning and w.loopTimer == null, "new instance starts empty and inactive")
    call w.addSlot(0, 1, 1, 0, 0, -1, false, Player(8))
    call w.addSlot('hfoo', 0, 1, 0, 0, -1, false, Player(8))
    call w.addSlot('hfoo', 1, 1, 0, 0, -1, false, null)
    call Check(w.slotCount == 0 and w.totalToSpawn == 0, "invalid rawcode/amount/owner rejected without counters")
    call w.addSlotEx('hfoo', 2, 0, 3, -1, -1, false, Player(8), 101, 7, 3, 0.)
    set s = w.slots[0]
    call Check(s.limit == 1 and s.fxId == 0 and s.threatWeight == 1.0 and s.aiProfileId == 101 and s.laneId == 7 and s.behaviorFlags == 3, "slot defaults and AI metadata")
    call w.addSlot('hfoo', 1, 1, 9, 999, -1, true, Player(9))
    call Check(w.pickSlot() == w.slots[1] and w.slots[1].fxId == FX_MAX, "highest eligible priority chosen; excessive FX clamped")
    set w.activeByPlayer[9] = 1
    call Check(w.pickSlot() == s, "owner cap excludes otherwise highest priority")
    set w.activeByPlayer[9] = 0
    set w.slots[1].active = 1
    call Check(w.pickSlot() == s, "slot cap excludes otherwise highest priority")
    call w.destroyWave()

    set w = NewWave(4, 0)
    call w.addSlot('hfoo', 1, 1, -1, 0, -1, false, Player(8))
    call Check(w.pickSlot() == w.slots[0], "negative priority can still select the only valid slot")
    call w.destroyWave()
    set w = NewWave(4, 0)
    call w.addSlot('hfoo', 2, 1, 1, 0, 1, true, Player(8))
    call Check(w.pickSlot() == 0 and w.getToKillRemaining() == 2, "killGate self-dependency is observable; configuration is blocked")
    call w.destroyWave()

    set w = NewWave(4, 0)
    call w.addSlotByPlayers('hfoo', 3, false, 1, 1, 0, -1, false)
    call Check(w.slotCount == 5 and w.totalToSpawn == 15 and GetPlayerId(w.slots[0].owner) == 8 and GetPlayerId(w.slots[4].owner) == 12, "ByPlayers creates all five default owner slots without scaling")
    call w.destroyWave()
    set w = NewWave(4, 0)
    call w.upsertSlotExByPlayer(99, 'hfoo', 2, false, 1, 1, 0, -1, false, Player(8), 1, 0, 0, 1.)
    call w.upsertSlotExByPlayer(99, 'hfoo', 3, false, 9, 9, 0, -1, false, Player(8), 9, 0, 0, 1.)
    call Check(w.slotCount == 1 and w.totalToSpawn == 5 and w.slots[0].total == 5 and w.slots[0].limit == 1, "upsert adds amount without replacing existing slot policy")
    call w.setAdditionalPerPlayerPercent(-20.)
    call Check(w.getAdditionalPerPlayerPercent() == 0., "negative per-player percentage clamped")
    call w.setFinishFunctionName("Example")
    call Check(w.getFinishFunctionName() == "Example", "finish callback name setter/getter")
    call w.setFinishFunctionName("")
    call w.destroyWave()

    set w = NewWave(4, 0)
    loop
        exitwhen i >= 101
        call w.addPoint(-4800., 3000.)
        call w.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
        set i = i + 1
    endloop
    call Check(w.pointCount == 100 and w.slotCount == 100 and w.totalToSpawn == 100, "fixed point/slot limits reject overflow without counting it")
    call w.destroyWave()

    set nearUnit = CreateUnit(Player(0), 'hfoo', -4800., 3000., 0.)
    set w = NewWave(4, 100)
    call w.addNearUnit(nearUnit)
    set i = 0
    loop
        exitwhen i >= 32
        if not w.selectSpawnPoint(256.) then
            set ok = false
        else
            set distance = SquareRoot((w.spawnX-GetUnitX(nearUnit))*(w.spawnX-GetUnitX(nearUnit))+(w.spawnY-GetUnitY(nearUnit))*(w.spawnY-GetUnitY(nearUnit)))
            if distance < 63.5 or distance > 256.5 or IsTerrainPathable(w.spawnX,w.spawnY,PATHING_TYPE_WALKABILITY) then
                set ok = false
            endif
        endif
        set i = i + 1
    endloop
    call Check(ok, "32 near samples stay within 64..256 and walkable terrain")
    call w.destroyWave()
    set anchor = CreateUnit(Player(0), 'hfoo', -4800., 3200., 0.)
    call KillUnit(anchor)
    set w = NewWave(4, 100)
    call w.addNearUnit(anchor)
    call w.addPoint(-4900., 3000.)
    call Check(w.selectSpawnPoint(256.) and w.spawnX == -4900. and w.spawnY == 3000., "dead near reference falls back to fixed point")
    call w.destroyWave()
    call RemoveUnit(anchor)
    set w = NewWave(4, 100)
    call Check(not w.selectSpawnPoint(256.), "no references and no fixed points rejects spawn")
    call w.destroyWave()

    set w = NewWave(4, 0)
    set before = started[w]
    call w.start()
    call w.start()
    call Check(w.isOperational() and started[w] == before + 1, "start is idempotent and operational")
    set before = paused[w]
    call w.pause()
    call w.pause()
    call Check(w.isPaused and not w.isOperational() and paused[w] == before + 1, "pause is idempotent and suspends tick operation")
    set before = resumed[w]
    call w.resume()
    call w.resume()
    call Check(w.isOperational() and resumed[w] == before + 1, "resume is idempotent and operational")
    call w.destroyWave()
    set w = NewWave(4, 0)
    set anchor = CreateUnit(Player(0), 'hfoo', -5000., 3200., 0.)
    call BindWaveToUnitDeath(w, anchor, true)
    call Check(WaveAffiliateWaveByUnit[GetHandleId(anchor)] == w, "affiliate bind is indexed")
    call KillUnit(anchor)
    call Check(w.isDestroyed and not WaveAffiliateWaveByUnit.has(GetHandleId(anchor)), "anchor death terminates empty bound wave and clears bind")
    call RemoveUnit(anchor)

    set fxWave = NewWave(1, 100)
    call fxWave.addNearUnit(nearUnit)
    call fxWave.addSlot('hfoo', 2, 1, 1, 1, -1, false, Player(8))
    call fxWave.start()
    call fxWave.trySpawn()
    set reservedX = fxWave.spawnX
    set reservedY = fxWave.spawnY
    call fxWave.trySpawn()
    call Check(fxWave.activeOnMap == 1 and fxWave.remainingToSpawn == 1 and fxWave.getActiveIndexedCount() == 0, "reservation consumes owner/slot caps before unit creation")
    call SetUnitX(nearUnit, -4200.)
    call SetUnitY(nearUnit, 3000.)
    set cancelledWave = NewWave(1, 0)
    call cancelledWave.addPoint(-4900., 3200.)
    call cancelledWave.addSlot('hfoo', 2, 1, 1, 0, -1, false, Player(9))
    call cancelledWave.trySpawn()
    call cancelledWave.terminate(false)
    call Check(cancelledWave.terminateRequested and cancelledWave.activeOnMap == 1 and cancelledWave.remainingToSpawn == 0, "termination cancels unreserved amount and waits for reserved timer")
    set externalWave = NewWave(1, 0)
    call externalWave.addPoint(-4750., 3150.)
    call externalWave.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call externalWave.trySpawn()

    set w = NewWave(1, 0)
    call w.addPoint(-4600., 3200.)
    call w.addSlot('hfoo', 1, 1, 1, 0, -1, false, Player(8))
    call w.trySpawn()
    set recycledId = w
    set oldToken = w.waveToken
    set oldSlot = w.slots[0]
    call w.destroyWave()
    set recycledWave = NewWave(1, 0)
    call recycledWave.addSlot('hfoo', 2, 1, 1, 0, -1, false, Player(8))
    call Check(recycledWave == recycledId and recycledWave.waveToken != oldToken, "reuse fixture truly reuses wave id with new token")
    call PanCameraToTimed(-4800., 3000., 0.)
    call Save("reserved")
    call TimerStart(phaseTimer, 0.60, false, function BeforeMaterialize)
    set anchor = null
endfunction

private function Init takes nothing returns nothing
    call RegisterWaveStartEvent(function StartEvent)
    call RegisterWavePauseEvent(function PauseEvent)
    call RegisterWaveResumeEvent(function ResumeEvent)
    call RegisterWaveFinishEvent(function FinishEvent)
    call RegisterWaveSpawnEvent(function SpawnEvent)
    call RegisterWaveDeathEvent(function DeathEvent)
    call FogEnable(false)
    call FogMaskEnable(false)
    call TimerStart(phaseTimer, 1.0, false, function Begin)
endfunction
endlibrary
