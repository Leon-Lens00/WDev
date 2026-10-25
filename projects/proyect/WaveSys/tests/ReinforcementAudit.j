// Laboratory only. Boss reinforcements: IAManager only requests them; the stage (stage1) provides the composition.
// A real zA01 boss in a wave with waveIndex 3 must, after its AI cast, receive hpea/hmil/hfoo +1 per default owner.
library WaveReinforcementAudit initializer Init requires stage1, IAManager, WaveOwnerPolicy
globals
    private string array lines
    private integer n = 0
    private integer checks = 0
    private integer failures = 0
    private timer phase = CreateTimer()
    private Wave w = 0
    private unit hero = null
    private unit boss = null
    private integer beforeTotal = 0
    private integer beforeRemaining = 0
    private integer beforeSlots = 0
    private integer polls = 0
endglobals

private function Note takes string s returns nothing
    set lines[n] = s
    set n = n + 1
    call BJDebugMsg(s)
endfunction

private function Save takes string stage returns nothing
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("WAVESYS REINFORCEMENT @RUN@ " + stage)
    call Preload("checks=" + I2S(checks) + " failures=" + I2S(failures))
    loop
        exitwhen i >= n
        call Preload(lines[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("Logs\\WaveSysAudit-@RUN@.txt")
endfunction

private function Check takes boolean ok, string s returns nothing
    set checks = checks + 1
    if ok then
        call Note("PASS " + s)
    else
        set failures = failures + 1
        call Note("FAIL " + s)
    endif
endfunction

private function SlotOwnedBy takes string label, integer slotGroup, integer rawcode returns integer
    local integer i = 0
    local integer found = 0
    loop
        exitwhen i >= w.slotCount
        if w.slots[i].slotGroupId == slotGroup and w.slots[i].unitId == rawcode and WaveIsDefaultOwnerPlayerId(GetPlayerId(w.slots[i].owner)) then
            set found = found + 1
        endif
        set i = i + 1
    endloop
    return found
endfunction

private function Finish takes nothing returns nothing
    call Note("COMPLETE reinforcement audit; failures are product observations, not approval.")
    call Save("complete")
    if not w.isDestroyed then
        call w.terminate(true)
        if not w.isDestroyed then
            call w.destroyWave()
        endif
    endif
    call DestroyTimer(phase)
endfunction

private function Poll takes nothing returns nothing
    set polls = polls + 1
    if w.totalToSpawn == beforeTotal and polls < 45 then
        call TimerStart(phase, 1.0, false, function Poll)
        return
    endif
    call Check(w.totalToSpawn > beforeTotal, "boss AI requested reinforcements within 45 s; polls=" + I2S(polls))
    call Check(w.totalToSpawn - beforeTotal == 15 and w.remainingToSpawn - beforeRemaining == 15, "stage composition for wave 3 adds 15 units; added=" + I2S(w.totalToSpawn - beforeTotal))
    call Check(w.slotCount - beforeSlots == 15, "one slot per default owner and type; new slots=" + I2S(w.slotCount - beforeSlots))
    call Check(SlotOwnedBy("hpea", AI_STAGE1_SLOT_GROUP_HPEA, 'hpea') == 5 and SlotOwnedBy("hmil", AI_STAGE1_SLOT_GROUP_HMIL, 'hmil') == 5 and SlotOwnedBy("hfoo", AI_STAGE1_SLOT_GROUP_HFOO, 'hfoo') == 5, "hpea, hmil and hfoo slots for owners 8..12")
    call Check(SlotOwnedBy("hrif", AI_STAGE1_SLOT_GROUP_HRIF, 'hrif') == 0, "types of later waves are not added to wave 3")
    call Check(w.toKillRemaining == w.remainingToSpawn + w.activeOnMap, "objective invariant holds after reinforcement")
    call Finish()
endfunction

private function AfterSpawn takes nothing returns nothing
    set boss = w.getActiveIndexedUnit(1)
    call Check(boss != null and GetUnitTypeId(boss) == 'zA01', "zA01 boss materialized in the wave")
    if boss != null then
        call SetUnitInvulnerable(boss, true)
    endif
    set beforeTotal = w.totalToSpawn
    set beforeRemaining = w.remainingToSpawn
    set beforeSlots = w.slotCount
    call Save("boss-alive")
    call TimerStart(phase, 1.0, false, function Poll)
endfunction

private function Begin takes nothing returns nothing
    set hero = CreateUnit(Player(0), 'Hpal', -3000., 2400., 0.)
    call SetUnitInvulnerable(hero, true)
    call PauseUnit(hero, true)
    set PlayerHero[0] = hero
    call AISetTrackedHeroForPlayer(0, hero)
    // The integration builder disables InitStage1 (scenario entry); register the stage provider as InitStage1 does.
    call Stage1RegisterBossReinforcements()
    set w = Wave.create(30, 0, 60., 3, 10)
    call w.addPoint(-5500., 2400.)
    call w.addSlotEx('zA01', 1, 1, 1, 0, -1, true, Player(11), AI_PROFILE_BOSS, 0, 0, 1.)
    call w.start()
    call w.trySpawn()
    call PanCameraToTimed(-5500., 2400., 0.)
    call Save("started")
    call TimerStart(phase, 2.0, false, function AfterSpawn)
endfunction

private function Init takes nothing returns nothing
    call FogEnable(false)
    call FogMaskEnable(false)
    call TimerStart(phase, 2.0, false, function Begin)
endfunction
endlibrary
