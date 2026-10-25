// E16 laboratory: SurvivalAudit.j (sha256 71f4629b1768b8addd49d4bee1295ae762acc0e0e7dfd1d9f27543a205fc7304) plus a read-only observer of the
// multiboard title during rest phases. RestTime must own the title while a countdown runs.
// Executes the original ten stage configurations and real rest/victory flow.
// A test-only sweeper kills enemies after spawn: this verifies progression,
// not combat difficulty, survival skill or human input.
library WaveRestBoardAudit initializer Init requires stage1, WaveDamageCredit, WavePointApi, RestTimeState, GameState
globals
    private string array lines
    private integer n = 0
    private integer checks = 0
    private integer failures = 0
    private integer starts = 0
    private integer finishes = 0
    private integer spawned = 0
    private integer deaths = 0
    private real elapsed = 0.
    private group queued = CreateGroup()
    private timer monitor = CreateTimer()
    private boolean begun = false
    private boolean endLogged = false
    private unit hero
    private unit markerA
    private unit markerB
    private unit markerC
    // Rest-board observer (read only)
    private timer boardSampler = CreateTimer()
    private integer restSamples = 0
    private integer foreignSamples = 0
    private integer purchaseSamples = 0
    private string firstForeign = ""
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
    call Preload("WAVESYS RESTBOARD @RUN@ " + stage)
    call Preload("checks=" + I2S(checks) + " failures=" + I2S(failures) + " starts=" + I2S(starts) + " finishes=" + I2S(finishes) + " spawns=" + I2S(spawned) + " deaths=" + I2S(deaths) + " elapsed=" + R2S(elapsed))
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
private function OnStart takes nothing returns nothing
    local Wave w = GetWaveEventWave()
    local integer expected = 10 * TargetWave - 3
    local integer expectedSlots = 5 * TargetWave + 1
    if not begun then
        return
    endif
    set starts = starts + 1
    if TargetWave == 1 then
        set expected = 5
        set expectedSlots = 5
    endif
    call Check(w.waveIndex == starts and TargetWave == starts, "stage index " + I2S(starts))
    call Check(w.totalToSpawn == expected and w.remainingToSpawn == expected, "wave " + I2S(starts) + " total=" + I2S(w.totalToSpawn) + " expected=" + I2S(expected))
    call Check(w.slotCount == expectedSlots, "wave " + I2S(starts) + " slot count=" + I2S(w.slotCount))
    call Check(w.pointCount == 3 and w.nearUnitCount == 1, "fixed marker points and active hero reach stage")
    call Check(w.nearUnitChance == 15 and w.interval == .25 and w.perPlayerLimit == 30, "stage spawn pacing unchanged")
    call Save("wave-start")
endfunction
private function OnSpawn takes nothing returns nothing
    if begun then
        set spawned = spawned + 1
        call GroupAddUnit(queued, GetWaveEventUnit())
    endif
endfunction
private function OnDeath takes nothing returns nothing
    if begun then
        set deaths = deaths + 1
    endif
endfunction
private function OnFinish takes nothing returns nothing
    local Wave w = GetWaveEventWave()
    if begun then
        set finishes = finishes + 1
        call Check(w.activeOnMap == 0 and w.remainingToSpawn == 0, "wave " + I2S(finishes) + " natural finish reconciles all spawned units")
        call Save("wave-finish")
    endif
endfunction
private function Has takes string s, string part returns boolean
    local integer i = 0
    local integer m = StringLength(part)
    local integer last = StringLength(s) - m
    loop
        exitwhen i > last
        if SubString(s, i, i + m) == part then
            return true
        endif
        set i = i + 1
    endloop
    return false
endfunction
// While a rest countdown runs, every sampled title must be RestTime's countdown title.
private function SampleBoard takes nothing returns nothing
    local string title
    if SwlsMultiboard == null or RestPhaseState == REST_PHASE_NONE or endLogged then
        return
    endif
    set title = MultiboardGetTitleText(SwlsMultiboard)
    set restSamples = restSamples + 1
    if Has(title, "Tienda: ") then
        set purchaseSamples = purchaseSamples + 1
    elseif not Has(title, "Inicia en: ") then
        set foreignSamples = foreignSamples + 1
        if firstForeign == "" then
            set firstForeign = title
        endif
    endif
endfunction
private function Tick takes nothing returns nothing
    local unit u = FirstOfGroup(queued)
    set elapsed = elapsed + .10
    if elapsed < .15 then
        call Check(GetUnitTypeId(markerA) == 0 and GetUnitTypeId(markerB) == 0 and GetUnitTypeId(markerC) == 0, "marker capture removes original marker units after engine retirement")
    endif
    loop
        exitwhen u == null
        call GroupRemoveUnit(queued, u)
        if GetWidgetLife(u) > .405 then
            call WaveRecordDamageCredit(hero, u)
            call UnitDamageTarget(hero, u, 10000000., true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, null)
        endif
        set u = FirstOfGroup(queued)
    endloop
    if finishes == 10 and not endLogged then
        set endLogged = true
        call Check(starts == 10 and TargetWave == 11, "all ten original stages advance to eleven")
        call Check(spawned == 518 and deaths == 518, "all 518 configured enemies spawn and die; actual=" + I2S(spawned) + "/" + I2S(deaths))
        call Check(RestSurvivalEndSequenceActive, "real final eighteen-second victory sequence starts")
        call Check(restSamples > 0 and purchaseSamples > 0, "rest observer sampled real purchase countdowns; samples=" + I2S(restSamples) + " purchase=" + I2S(purchaseSamples))
        call Check(foreignSamples == 0, "rest countdown title is never overwritten during rests; foreign=" + I2S(foreignSamples) + "/" + I2S(restSamples))
        if firstForeign != "" then
            call Note("First foreign title: " + firstForeign)
        endif
        call Note("COMPLETE ten actual configurations, real spawn/death and nine real purchase countdowns. Victory UI still requires screenshot after final delay.")
        call Save("before-victory")
    endif
    if elapsed > 360. and not endLogged then
        call Check(false, "progress watchdog exceeded six minutes")
        call Save("watchdog")
        call PauseTimer(monitor)
    endif
    set u = null
endfunction
private function Begin takes nothing returns nothing
    local unit a
    local unit b
    local unit c
    local rect area = Rect(-7000., 2500., -5000., 4500.)
    call DestroyTimer(GetExpiredTimer())
    set SwlsSound = null
    set hero = CreateUnit(Player(0), 'Hpal', -3500., 3000., 0.)
    set PlayerHero[0] = hero
    call SetUnitInvulnerable(hero, true)
    call PauseUnit(hero, true)
    call HeroLivesRefreshActivePlayers()
    call Check(WavePlayer.AmountPlaying == 1, "single-human fixture roster")
    set a = CreateUnit(Player(15), 'l00A', -6500., 3000., 0.)
    set b = CreateUnit(Player(15), 'l00A', -6000., 3500., 0.)
    set c = CreateUnit(Player(15), 'l00A', -5500., 4000., 0.)
    set markerA = a
    set markerB = b
    set markerC = c
    call Check(a != null and b != null and c != null, "original l00A resource creates marker units")
    call WavePointGroupsClear()
    call WavePointGroupRegister("Stage1_ThePueblo", area, 'l00A')
    call WavePointGroupsBuild()
    call Check(WavePointGroupCount("Stage1_ThePueblo") == 3, "marker capture registers three spawn positions")
    set SwlsWaveStartTrigger = CreateTrigger()
    call TriggerAddAction(SwlsWaveStartTrigger, function Trig_w1_Actions)
    set TargetWave = 1
    set begun = true
    call RegisterWaveStartEvent(function OnStart)
    call RegisterWaveSpawnEvent(function OnSpawn)
    call RegisterWaveDeathEvent(function OnDeath)
    call RegisterWaveFinishEvent(function OnFinish)
    call TimerStart(monitor, .10, true, function Tick)
    call TimerStart(boardSampler, .05, true, function SampleBoard)
    call Trig_w1_Actions()
    call PanCameraToTimed(-6000., 3500., 0.)
    call Save("started")
    set a = null
    set b = null
    set c = null
    set area = null
endfunction
private function Init takes nothing returns nothing
    local timer t = CreateTimer()
    call FogEnable(false)
    call FogMaskEnable(false)
    call TimerStart(t, 2., false, function Begin)
    set t = null
endfunction
endlibrary
