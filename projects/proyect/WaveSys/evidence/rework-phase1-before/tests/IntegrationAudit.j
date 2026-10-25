// All 114 active libraries, real lifecycle/damage/AI/rest handlers.
// MapBootstrap and stage1 startup are disabled only in the generated input.
library WaveIntegrationAudit initializer Init requires HeroLives, WaveDamageCredit, InitialGoldConfig, InitialWaveMultiboard, RestTimeEndFlow, IAManager, AIManagerUtils
globals
    private string array lines
    private integer lineCount = 0
    private integer checks = 0
    private integer failures = 0
    private timer phaseTimer = CreateTimer()
    private unit hero
    private unit enemy
    private unit aiHero
    private unit aiEnemy
    private Wave aiWave
    private integer pid = 0
    private integer nextCalls = 0
    private string restTitle = ""
    private boolean restReturned = false
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
    call Preload("WAVESYS INTEGRATION @RUN@ " + stage)
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
    call Check(nextCalls == 1 and RestPhaseState == REST_PHASE_NONE and RestPhaseRemaining == 0, "ten-second purchase countdown dispatches next callback exactly once")
    call Check(HeroLivesGetCurrent(pid) == 10 and UnitAlive(hero), "rest leaves active player alive with ten revives")
    call RestTimeStopPhaseTimer()
    call HeroLivesCancelPlayerState(pid)
    call AIClearTrackedHeroes()
    call RemoveUnit(hero)
    call RemoveUnit(enemy)
    call RemoveUnit(aiHero)
    set PlayerHero[pid] = null
    call Note("COMPLETE all-library integration; original custom objects/imports and victory remain separate cases.")
    call Save("complete")
    call DestroyTimer(phaseTimer)
endfunction

private function ObserveBoard takes nothing returns nothing
    local string current = MultiboardGetTitleText(SwlsMultiboard)
    call Check(restReturned, "rest handler returns to its caller")
    call Check(current == restTitle, "initial board writer preserves rest title between countdown ticks")
    call Note("Rest title requested=" + restTitle + "; actual after 0.25s=" + current)
    call Save("rest-countdown")
    call TimerStart(phaseTimer, 10.0, false, function Finish)
endfunction

private function Exhausted takes nothing returns nothing
    local integer gold = GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_GOLD)
    call Check(not UnitAlive(hero) and HeroLivesGetCurrent(pid) == 0, "next death at zero revives stays dead after delay")
    set TargetWave = 1
    set SwlsWaveStartTrigger = null
    call Save("before-rest-handler")
    // Arm observation first so an aborted handler cannot hide the outcome.
    call TimerStart(phaseTimer, 0.25, false, function ObserveBoard)
    call RestTimeOnWaveFinished("WaveAuditNext")
    set restReturned = true
    call Check(TargetWave == 2 and not isWavez and WaveTgg == "WaveAuditNext", "real rest flow advances wave and records next callback")
    call Check(UnitAlive(hero) and HeroLivesGetCurrent(pid) == 10, "real rest flow revives and resets lives through new player registry")
    call Check(GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_GOLD) == gold + 2, "real rest flow rewards active player two gold")
    call Check(RestPhaseState == REST_PHASE_PURCHASE and RestPhaseRemaining == 10, "real rest flow starts ten-second purchase phase")
    set restTitle = MultiboardGetTitleText(SwlsMultiboard)
endfunction

private function AfterProtection takes nothing returns nothing
    local real hp = GetUnitState(hero, UNIT_STATE_LIFE)
    call UnitDamageTarget(enemy, hero, 10., true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    call Check(GetUnitState(hero, UNIT_STATE_LIFE) < hp, "revive protection expires and native damage applies again")
    set aiEnemy = aiWave.getActiveIndexedUnit(1)
    call Check(aiEnemy != null and GetUnitCurrentOrder(aiEnemy) == OrderId("attack"), "Wave spawn event reaches IAManager and produces native attack order")
    if aiEnemy != null then
        call Note("AI order=" + I2S(GetUnitCurrentOrder(aiEnemy)) + " target distance=" + R2S(SwlsDistance(GetUnitX(aiEnemy),GetUnitY(aiEnemy),GetUnitX(aiHero),GetUnitY(aiHero))))
    endif
    call aiWave.terminate(true)
    call Check(aiWave.isDestroyed, "forced normal-wave termination and AI finish cleanup complete")
    call AIClearTrackedHeroes()
    call TimerStart(phaseTimer, 1.75, false, function Exhausted)
    call KillUnit(hero)
endfunction

private function AfterRevive takes nothing returns nothing
    local real hp = GetUnitState(hero, UNIT_STATE_LIFE)
    call Check(UnitAlive(hero) and HeroLivesGetCurrent(pid) == 0, "last available revive materializes after 1.5s even when counter now zero")
    call Check(WaveGetDamageCreditOwnerPid(enemy) == -1, "damage credit expires after 1.5 seconds")
    call UnitDamageTarget(enemy, hero, 10., true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    call Check(GetUnitState(hero, UNIT_STATE_LIFE) == hp, "fresh revival blocks damage during protection")
    call Save("revived")
    call TimerStart(phaseTimer, 2.10, false, function AfterProtection)
endfunction

private function Begin takes nothing returns nothing
    local integer originalGold
    // Normal stage startup assigns this before any rest. This laboratory
    // enters rest directly, so explicitly supply its no-sound starting state.
    set SwlsSound = null
    call Note("BEGIN real libraries: lifecycle, credit, AI, gold, rest and board")
    call Check(WavePlayer.AmountPlaying == User.AmountPlaying and WavePlayer.AmountPlaying > 0, "new gameplay roster and legacy UI initialize together")
    set pid = WavePlayer.fromPlaying(0).id
    set hero = CreateUnit(Player(pid), 'Hpal', -4800., 3000., 0.)
    set enemy = CreateUnit(Player(8), 'hfoo', -4700., 3300., 0.)
    set aiHero = CreateUnit(Player(1), 'Hamg', -4800., 2400., 0.)
    call PauseUnit(enemy, true)
    call PauseUnit(aiHero, true)
    call SetPlayerAlliance(Player(8), Player(pid), ALLIANCE_PASSIVE, false)
    call SetPlayerAlliance(Player(pid), Player(8), ALLIANCE_PASSIVE, false)
    call SetPlayerAlliance(Player(8), Player(1), ALLIANCE_PASSIVE, false)
    call SetPlayerAlliance(Player(1), Player(8), ALLIANCE_PASSIVE, false)
    call Check(hero != null and enemy != null and aiHero != null and IsUnitType(hero, UNIT_TYPE_HERO), "real standard hero/enemy fixtures exist")
    set PlayerHero[pid] = hero
    call PauseUnit(hero, true)
    call HeroLivesInitHero(pid, hero)
    call Check(HeroLivesGetCurrent(pid) == 10 and HeroLivesGetRemaining(-1) == 0, "hero lives initialize to ten and invalid id is guarded")
    call HeroLivesSetCurrent(pid, -3)
    call Check(HeroLivesGetCurrent(pid) == 0, "negative lives clamp to zero")
    call HeroLivesSetCurrent(pid, 1)
    set originalGold = GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_GOLD)
    call InitInitialPlayerGold()
    call Check(GetPlayerState(Player(pid), PLAYER_STATE_RESOURCE_GOLD) == originalGold + 1, "initial gold configuration uses new active roster")
    call WaveRecordDamageCredit(hero, enemy)
    call Check(WaveGetDamageCreditOwnerPid(enemy) == pid, "credit accepts player id zero without treating it as absent")
    call WaveClearDamageCredit(enemy)
    call Check(WaveGetDamageCreditOwnerPid(enemy) == -1, "credit clear removes integer and real entries")
    call WaveRecordDamageCredit(hero, enemy)
    call Check(AIIntervalToMs(0., 350) == 350 and AIIntervalToMs(0.001, 350) == 50 and AIClampInt(999, 16, 192) == 192, "AI scheduler conversions and bounds")
    call AISetDynamicScheduler(false)
    call AISetFixedTickMs(150)
    call AISetFixedBudget(48)
    call AISetTrackedHeroForPlayer(1, aiHero)
    set aiWave = Wave.create(1, 0, 60., null, "", 1, 10, "")
    call aiWave.addPoint(-5500., 2400.)
    call aiWave.addSlotEx('ugho', 1, 1, 1, 0, -1, false, Player(8), AI_PROFILE_MELEE, 0, 0, 1.)
    call aiWave.start()
    call aiWave.trySpawn()
    set isWavez = true
    call InitInitialWaveMultiboard()
    call Check(SwlsMultiboard != null, "real initial board initializes")
    call KillUnit(hero)
    call Check(not UnitAlive(hero) and HeroLivesGetCurrent(pid) == 0, "active-wave death consumes exactly one revive")
    call PanCameraToTimed(-4800., 2800., 0.)
    call Save("death-pending")
    call TimerStart(phaseTimer, 1.75, false, function AfterRevive)
endfunction

function WaveAuditNext takes nothing returns nothing
    set nextCalls = nextCalls + 1
    set isWavez = true
    call Note("Next callback entered through real RestTime dispatcher")
endfunction

private function Init takes nothing returns nothing
    call FogEnable(false)
    call FogMaskEnable(false)
    call Save("initialized")
    call TimerStart(phaseTimer, 2.0, false, function Begin)
endfunction
endlibrary
