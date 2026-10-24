library WaveSkillsAudit initializer Init requires IAManager, WaveBarrierSkills, WaveAuraSkills, WaveRangedSkills, WaveSiegeSkills, WaveMortarSkills, WavePriestSkills, WaveTrapSkills, WaveSiegeZoneSkills, WaveWaveformSkills
globals
    private string array lines
    private integer lineCount = 0
    private integer checks = 0
    private integer failures = 0
    private timer phaseTimer = CreateTimer()
    private unit hero
    private unit source
    private unit wrong
    private Wave w
endglobals
private function Note takes string message returns nothing
    set lines[lineCount] = message
    set lineCount = lineCount + 1
    call BJDebugMsg(message)
endfunction
private function Save takes string stage returns nothing
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("WAVESYS SKILLS @RUN@ " + stage)
    call Preload("checks=" + I2S(checks) + " failures=" + I2S(failures))
    loop
        exitwhen i >= lineCount
        call Preload(lines[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("Logs\\WaveSysAudit-@RUN@.txt")
endfunction
private function Check takes boolean ok, string message returns nothing
    set checks = checks + 1
    if ok then
        call Note("PASS " + message)
    else
        set failures = failures + 1
        call Note("FAIL " + message)
    endif
    call Save("progress")
endfunction
private function Finish takes nothing returns nothing
    call Check(w.isDestroyed, "forced cleanup returns and destroys skill test wave")
    call AIClearTrackedHeroes()
    call RemoveUnit(hero)
    call RemoveUnit(wrong)
    call Note("COMPLETE skill entry guards and real barrier/AI interaction; no claim for missing custom assets.")
    call Save("complete")
    call DestroyTimer(phaseTimer)
endfunction
private function AfterBarrier takes nothing returns nothing
    call Check(WaveBarrierCheckPlayerProjectile(901, Player(0), GetUnitX(source), GetUnitY(source), WAVE_BARRIER_PROJECTILE_KIND_NORMAL) == WAVE_BARRIER_INTERACTION_NONE, "barrier expires after its real five-second duration")
    call Check(GetUnitCurrentOrder(source) == OrderId("attack"), "AI resumes attack against same distant hero after barrier stop; actual order=" + I2S(GetUnitCurrentOrder(source)))
    call Save("before-cleanup")
    call TimerStart(phaseTimer, 0.5, false, function Finish)
    call w.terminate(true)
endfunction
private function AfterSpawn takes nothing returns nothing
    local unit probe
    local real x
    local real y
    set source = w.getActiveIndexedUnit(1)
    call Check(source != null, "real Wave spawn materializes barrier source")
    call Check(GetUnitCurrentOrder(source) == OrderId("attack"), "AI has cached a real attack before skill interrupts it")
    call Check(WaveBarrierSkillsTryExecute(source, hero, 100000), "real barrier starts after seeded initial cooldown")
    set x = GetUnitX(source)
    set y = GetUnitY(source)
    call Check(WaveBarrierCheckPlayerProjectile(101, Player(0), x, y, WAVE_BARRIER_PROJECTILE_KIND_NORMAL) == WAVE_BARRIER_INTERACTION_BLOCK, "enemy normal projectile is blocked inside barrier")
    call Check(WaveBarrierCheckPlayerProjectile(101, Player(0), x, y, WAVE_BARRIER_PROJECTILE_KIND_NORMAL) == WAVE_BARRIER_INTERACTION_NONE, "same projectile trace is not processed twice inside barrier")
    call WaveBarrierClearProjectileTrace(101)
    call Check(WaveBarrierCheckPlayerProjectile(101, Player(0), x, y, WAVE_BARRIER_PROJECTILE_KIND_NORMAL) == WAVE_BARRIER_INTERACTION_BLOCK, "clearing trace permits a fresh entry")
    call Check(WaveBarrierCheckPlayerProjectile(102, Player(8), x, y, WAVE_BARRIER_PROJECTILE_KIND_NORMAL) == WAVE_BARRIER_INTERACTION_NONE, "friendly projectile passes barrier")
    call Check(WaveBarrierCheckPlayerProjectile(103, Player(0), x + 1000., y, WAVE_BARRIER_PROJECTILE_KIND_NORMAL) == WAVE_BARRIER_INTERACTION_NONE, "outside projectile passes barrier")
    call Check(WaveBarrierCheckPlayerProjectile(104, Player(0), x, y, WAVE_BARRIER_PROJECTILE_KIND_WIND) == WAVE_BARRIER_INTERACTION_WIND, "wind interaction dispatch")
    call Check(WaveBarrierCheckPlayerProjectile(105, Player(0), x, y, WAVE_BARRIER_PROJECTILE_KIND_RAY) == WAVE_BARRIER_INTERACTION_RAY, "ray interaction dispatch")
    call WaveBarrierSetProjectileInteraction(WAVE_BARRIER_PROJECTILE_KIND_NORMAL, WAVE_BARRIER_INTERACTION_NONE)
    call Check(WaveBarrierCheckPlayerProjectile(106, Player(0), x, y, WAVE_BARRIER_PROJECTILE_KIND_NORMAL) == WAVE_BARRIER_INTERACTION_NONE, "interaction policy can be disabled")
    call WaveBarrierSetProjectileInteraction(WAVE_BARRIER_PROJECTILE_KIND_NORMAL, WAVE_BARRIER_INTERACTION_BLOCK)
    call Check(WaveBarrierCheckPlayerProjectile(0, null, x, y, 0) == WAVE_BARRIER_INTERACTION_NONE, "invalid projectile identity/owner guarded")
    set probe = CreateUnit(Player(15), 'dumi', x, y + 1000., 0.)
    if probe == null or GetUnitTypeId(probe) == 0 then
        call Note("BLOCKED visual/missile integration: original dumi object is absent in this laboratory base.")
    else
        call Note("AVAILABLE dumi object in base; its object fields/imports still require provenance comparison.")
        call RemoveUnit(probe)
    endif
    call Save("barrier-active")
    call TimerStart(phaseTimer, 5.75, false, function AfterBarrier)
    set probe = null
endfunction
private function Begin takes nothing returns nothing
    set hero = CreateUnit(Player(1), 'Hpal', -2500., 3000., 0.)
    set wrong = CreateUnit(Player(8), 'ugho', -6400., 3300., 0.)
    call PauseUnit(hero, true)
    call PauseUnit(wrong, true)
    call SetPlayerAlliance(Player(8), Player(1), ALLIANCE_PASSIVE, false)
    call SetPlayerAlliance(Player(1), Player(8), ALLIANCE_PASSIVE, false)
    call SetPlayerAlliance(Player(8), Player(0), ALLIANCE_PASSIVE, false)
    call Check(hero != null and wrong != null, "standard native skill guard fixtures exist")
    call Check(not WaveBarrierSkillsTryExecute(wrong, hero, 0), "barrier rejects wrong source type")
    call Check(not WaveAuraSkillsTryExecute(wrong, hero, 0), "phase aura rejects wrong source type")
    call Check(not WaveRangedSkillsTryExecute(wrong, hero, 0), "ranged rejects wrong source type")
    call Check(not WaveMortarSkillsTryExecute(wrong, hero, 0), "mortar rejects wrong source type")
    call Check(not WavePriestSkillsTryExecute(wrong, hero, 0), "priest rejects wrong source type")
    call Check(not WaveTrapSkillsTryExecute(wrong, hero, 0), "trap rejects wrong source type")
    call Check(not WaveSiegeZoneSkillsTryExecute(wrong, hero, 0), "siege zone rejects wrong source type")
    call Check(not WaveWaveformSkillsTryExecute(wrong, hero, 0), "waveform rejects wrong source type")
    call Check(not WaveBarrierSkillsTryExecute(null, hero, 0) and not WaveRangedSkillsTryExecute(null, hero, 0) and not WaveMortarSkillsTryExecute(null, hero, 0), "null source rejected by barrier/ranged/mortar")
    call Check(not WaveAuraSkillsTryExecute(null, hero, 0) and not WavePriestSkillsTryExecute(null, hero, 0) and not WaveTrapSkillsTryExecute(null, hero, 0), "null source rejected by aura/priest/trap")
    call Check(not WaveSiegeZoneSkillsTryExecute(null, hero, 0) and not WaveWaveformSkillsTryExecute(null, hero, 0), "null source rejected by zone/waveform")
    call Check(not WaveSiegeSkillsTryExecute(wrong, hero, 100000), "legacy siege handler is explicitly disabled (returns false)")
    call Note("Disabled legacy siege is an observed capability state, not approval of its unused projectile code.")
    call AISetDynamicScheduler(false)
    call AISetFixedTickMs(150)
    call AISetFixedBudget(48)
    call AISetTrackedHeroForPlayer(1, hero)
    set w = Wave.create(1, 0, 60., null, "", 1, 10, "")
    call w.addPoint(-6500., 3000.)
    call w.addSlotEx('hfoo', 1, 1, 1, 0, -1, false, Player(8), AI_PROFILE_MELEE, 0, 0, 1.)
    call w.start()
    call w.trySpawn()
    call Save("source-pending")
    call PanCameraToTimed(-6500., 3000., 0.)
    call TimerStart(phaseTimer, 2.25, false, function AfterSpawn)
endfunction
private function Init takes nothing returns nothing
    call FogEnable(false)
    call FogMaskEnable(false)
    call Save("initialized")
    call TimerStart(phaseTimer, 2.0, false, function Begin)
endfunction
endlibrary
