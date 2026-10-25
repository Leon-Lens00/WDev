// Positive skill execution with original objects/assets. Only generated,
// read-only aura observers inspect private membership for E12 reproduction.
library WaveResourceSkillsAudit initializer Init requires WaveAuraSkills, WaveRangedSkills, WaveMortarSkills, WavePriestSkills, WaveTrapSkills, WaveSiegeZoneSkills, WaveWaveformSkills, IAManager
globals
    private string array lines
    private integer n = 0
    private integer checks = 0
    private integer failures = 0
    private unit array caster
    private unit array hero
    private real array lifeBefore
    private timer phase = CreateTimer()
    private Wave w
    private unit auraSource
    private unit auraVictim
    private unit auraSurvivor
    private unit priestMember
    private integer auraId
    private integer beforeCount
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
    call Preload("WAVESYS RESOURCE SKILLS @RUN@ " + stage)
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
    call Save("progress")
endfunction
private function Finish takes nothing returns nothing
    local integer i = 0
    call Check(not IsUnitPaused(hero[2]), "trap releases its hero after real expiry")
    call Check(GetUnitAbilityLevel(priestMember, 'A004') == 0, "priest temporary passive removed after aura expiry")
    call Check(WaveAuditAuraOwner(auraSurvivor) == 0 and (GetUnitTypeId(auraSurvivor) != 'nrat' or GetUnitAbilityLevel(auraSurvivor, 'AInv') == 0), "aura expiry clears surviving last member owner and granted inventory; owner=" + I2S(WaveAuditAuraOwner(auraSurvivor)))
    call w.destroyWave()
    loop
        exitwhen i >= 7
        call RemoveUnit(caster[i])
        call RemoveUnit(hero[i])
        set PlayerHero[i] = null
        set i = i + 1
    endloop
    call RemoveUnit(auraSource)
    call RemoveUnit(auraSurvivor)
    call RemoveUnit(priestMember)
    call Note("COMPLETE positive normal skill paths and observed effects. Boss branches and sustained saturation are separate coverage.")
    call Save("complete")
    call DestroyTimer(phase)
endfunction
private function Observe takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= 5
        if i != 2 then
            call Check(GetWidgetLife(hero[i]) < lifeBefore[i] - 1., "skill lane " + I2S(i) + " applies native damage; before=" + R2S(lifeBefore[i]) + " after=" + R2S(GetWidgetLife(hero[i])))
        endif
        set i = i + 1
    endloop
    call Check(IsUnitPaused(hero[2]), "trap actually pauses registered enemy hero")
    call Check(GetUnitAbilityLevel(priestMember, 'A004') > 0, "priest aura grants original A004 passive to managed ally")
    call Check(GetUnitTypeId(auraVictim) == 0, "removed aura member has retired in engine")
    call Note("Aura after middle removal: originalCount=" + I2S(beforeCount) + " count=" + I2S(WaveAuditAuraCount(auraId)) + " lastSurvivorOwner=" + I2S(WaveAuditAuraOwner(auraSurvivor)))
    call TimerStart(phase, 10., false, function Finish)
endfunction
private function RemoveMiddle takes nothing returns nothing
    set auraId = WaveAuditAuraId(auraSource)
    set beforeCount = WaveAuditAuraCount(auraId)
    call Check(auraId > 0 and beforeCount >= 3, "real rune aura acquires multiple managed members")
    set auraVictim = WaveAuditAuraAt(auraId, 2)
    if auraVictim == auraSource then
        set auraVictim = WaveAuditAuraAt(auraId, 1)
    endif
    set auraSurvivor = WaveAuditAuraAt(auraId, beforeCount)
    call Check(auraVictim != auraSource and auraVictim != auraSurvivor and GetUnitAbilityLevel(auraSurvivor, 'AInv') > 0, "middle-removal scenario preserves source and distinct last member")
    call RemoveUnit(auraVictim)
    call TimerStart(phase, 2.25, false, function Observe)
endfunction
private function Cast takes nothing returns nothing
    local integer i = 0
    local unit member
    set auraSource = w.getActiveIndexedUnit(1)
    call Check(auraSource != null, "aura source materializes through real Wave FX")
    loop
        exitwhen i >= 3
        set member = CreateUnit(Player(8), 'nrat', GetUnitX(auraSource) + 50.*i, GetUnitY(auraSource) + 80., 0.)
        call PauseUnit(member, true)
        call registerExternalUnit(auraSource, member, false)
        set i = i + 1
    endloop
    // Priest member belongs to same wave as its source via real external map.
    call registerExternalUnit(auraSource, caster[6], false)
    set priestMember = CreateUnit(Player(8), 'nrat', GetUnitX(caster[6]) + 30., GetUnitY(caster[6]), 0.)
    call PauseUnit(priestMember, true)
    call registerExternalUnit(auraSource, priestMember, false)
    call Check(not WaveRangedSkillsTryExecute(caster[0], hero[0], 0), "ranged seeds its real initial cooldown")
    call Check(WaveRangedSkillsTryExecute(caster[0], hero[0], 100000), "ranged starts real telegraph/projectile")
    call Check(not WaveMortarSkillsTryExecute(caster[1], hero[1], 0), "mortar seeds initial cooldown")
    call Check(WaveMortarSkillsTryExecute(caster[1], hero[1], 100000), "mortar launches real missile")
    call Check(not WaveTrapSkillsTryExecute(caster[2], hero[2], 0), "trap seeds initial cooldown")
    call Check(WaveTrapSkillsTryExecute(caster[2], hero[2], 100000), "trap starts windup and real projectile")
    call Check(not WaveSiegeZoneSkillsTryExecute(caster[3], hero[3], 0), "zone seeds initial cooldown")
    call Check(WaveSiegeZoneSkillsTryExecute(caster[3], hero[3], 100000), "zone starts real blast area")
    call Check(not WaveWaveformSkillsTryExecute(caster[4], hero[4], 0), "waveform seeds initial cooldown")
    call Check(WaveWaveformSkillsTryExecute(caster[4], hero[4], 100000), "waveform launches real missile")
    call Check(not WaveAuraSkillsTryExecute(auraSource, hero[5], 0), "rune aura seeds initial cooldown")
    call Check(WaveAuraSkillsTryExecute(auraSource, hero[5], 100000), "rune aura starts with original rspl/A015 resource")
    call Check(not WavePriestSkillsTryExecute(caster[6], hero[6], 0), "priest seeds initial cooldown")
    call Check(WavePriestSkillsTryExecute(caster[6], hero[6], 100000), "priest starts real aura")
    call TimerStart(phase, .5, false, function RemoveMiddle)
    set member = null
endfunction
private function Begin takes nothing returns nothing
    local integer i = 0
    local integer raw
    local real y
    local unit probe = CreateUnit(Player(15), 'dumi', -7500., 4500., 0.)
    call Check(probe != null and GetUnitTypeId(probe) == 'dumi', "original dummy object exists in resource base")
    call RemoveUnit(probe)
    call AISetUseGroupFallbackNoHeroes(false)
    call AIClearTrackedHeroes()
    loop
        exitwhen i >= 7
        set y = 4000. - 2000.*i
        set hero[i] = CreateUnit(Player(i), 'Hpal', -5000., y, 180.)
        set PlayerHero[i] = hero[i]
        call SetPlayerAlliance(Player(8), Player(i), ALLIANCE_PASSIVE, false)
        call SetPlayerAlliance(Player(i), Player(8), ALLIANCE_PASSIVE, false)
        call PauseUnit(hero[i], i != 2)
        call SetUnitAcquireRange(hero[i], 0.)
        set lifeBefore[i] = GetWidgetLife(hero[i])
        if i == 0 then
            set raw = 'hrif'
        elseif i == 1 then
            set raw = 'hmtm'
        elseif i == 2 then
            set raw = 'hsor'
        elseif i == 3 then
            set raw = 'hmtt'
        elseif i == 4 then
            set raw = 'hwt3'
        elseif i == 5 then
            set raw = 'hkni'
        else
            set raw = 'hmpr'
        endif
        set caster[i] = CreateUnit(Player(8), raw, -5900., y, 0.)
        call SetUnitAcquireRange(caster[i], 0.)
        call PauseUnit(caster[i], true)
        set i = i + 1
    endloop
    set w = Wave.create(20, 0, 60., 1, 10)
    call w.addPoint(-5900., -6000.)
    call w.addSlotEx('hkni', 1, 1, 1, 0, -1, false, Player(8), AI_PROFILE_MELEE, 0, 0, 1.)
    call w.start()
    call w.trySpawn()
    call PanCameraToTimed(-5500., 4000., 0.)
    call TimerStart(phase, 2., false, function Cast)
    set probe = null
endfunction
private function Init takes nothing returns nothing
    call FogEnable(false)
    call FogMaskEnable(false)
    call TimerStart(phase, 2., false, function Begin)
endfunction
endlibrary
