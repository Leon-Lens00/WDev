// Real inventory/weapon APIs plus timeout selection. Direct fire bypasses
// missing U0AF input ability explicitly; it cannot validate normal key input.
library WaveGameplayApiAudit initializer Init requires WeaponInventorySystem, SelectionSystem, TenderSystem
globals
    private string array lines
    private integer n = 0
    private integer checks = 0
    private integer failures = 0
    private timer phase = CreateTimer()
    private unit hero
    private unit target
    private integer profile = 0
    private integer hits = 0
    private integer launched = 0
    private trigger damage = CreateTrigger()
    private integer initialStarts = 0
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
    call Preload("WAVESYS GAMEPLAY API @RUN@ " + stage)
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
private function OnDamage takes nothing returns nothing
    if GetTriggerUnit() == target and GetEventDamage() > 0. then
        set hits = hits + 1
    endif
endfunction
private function InitialStart takes nothing returns nothing
    set initialStarts = initialStarts + 1
endfunction
private function Finish takes nothing returns nothing
    call Check(initialStarts == 1, "selection reaches real initial countdown and dispatches once")
    call Note("COMPLETE inventory state, thirteen direct fire entries and timeout selection. Native U0AF/U0C1/U0C2 input remains blocked by absent object definitions.")
    call Save("complete")
    call DestroyTimer(phase)
endfunction
private function AfterSelection takes nothing returns nothing
    set hero = PlayerHero[0]
    call Check(hero != null and GetUnitTypeId(hero) != 0 and IsUnitType(hero, UNIT_TYPE_HERO), "real selection timeout creates one original custom hero")
    call Check(HeroLivesGetCurrent(0) == 10 and PlayerCamera[0] != 0, "selected hero has lives and camera")
    call Check(Client[hero] != 0 and Client[hero].displayed, "selection creates and shows real UI client")
    call Check(WaveTgg == "Trig_w1_Actions" and RestPhaseState == REST_PHASE_INITIAL, "selection begins original preparation flow")
    call Note("Portability boundary: fixed original spawnY=24064 lies outside independent TerrainDev bounds; this is not the original terrain.")
    call TimerStart(phase, 11., false, function Finish)
endfunction
private function NextWeapon takes nothing returns nothing
    if profile > 0 then
        call Note("OBSERVED " + WeaponProfileGetName(profile) + " native damage events=" + I2S(hits))
        call RemoveUnit(target)
    endif
    set profile = profile + 1
    if profile > WEAPON_PROFILE_LAST then
        call Check(launched == 13, "all thirteen real direct-fire API entries return success")
        call RemoveUnit(hero)
        set PlayerHero[0] = null
        set SwlsWaveStartTrigger = CreateTrigger()
        call TriggerAddAction(SwlsWaveStartTrigger, function InitialStart)
        call SelectionSystem.start()
        call Note("Original six-choice dialog opened; waiting real ten-second timeout.")
        call Save("selection-open")
        call TimerStart(phase, 10.5, false, function AfterSelection)
        return
    endif
    set hits = 0
    set target = CreateUnit(Player(8), 'hfoo', -5400., 3000., 180.)
    call PauseUnit(target, true)
    call TriggerRegisterUnitEvent(damage, target, EVENT_UNIT_DAMAGED)
    call WeaponInventorySetSlotWeapon(Player(0), 1, profile, 50)
    call WeaponInventorySetActiveSlot(Player(0), 1)
    if WeaponInventoryFireActive(Player(0), GetUnitX(target), GetUnitY(target)) then
        set launched = launched + 1
        call Note("STARTED " + WeaponProfileGetName(profile))
    else
        call Note("REJECTED " + WeaponProfileGetName(profile))
    endif
    call Save("weapon-progress")
    call TimerStart(phase, 5., false, function NextWeapon)
endfunction
private function Begin takes nothing returns nothing
    local integer i = 0
    local unit probe
    local unit shop
    set SwlsSound = null
    set hero = CreateUnit(Player(0), 'Hpal', -6000., 3000., 0.)
    set PlayerHero[0] = hero
    call PauseUnit(hero, true)
    call SetPlayerAlliance(Player(8), Player(0), ALLIANCE_PASSIVE, false)
    call SetPlayerAlliance(Player(0), Player(8), ALLIANCE_PASSIVE, false)
    call WeaponInventoryEnsurePlayer(Player(0))
    call Check(WeaponInventoryGetActiveProfile(Player(0)) == WEAPON_PROFILE_HANDGUN and WeaponInventoryGetActiveAmmo(Player(0)) == WEAPON_AMMO_INFINITE, "inventory initializes active handgun with infinite ammo")
    call Check(not WeaponInventorySetSlotWeapon(Player(0), 0, 2, 10) and not WeaponInventorySetSlotWeapon(Player(0), 1, 999, 10), "inventory rejects invalid slot/profile")
    call Check(WeaponInventoryGiveWeapon(Player(0), WEAPON_PROFILE_SHOTGUN, 2), "weapon grant succeeds")
    call Check(WeaponInventoryGetActiveProfile(Player(0)) == WEAPON_PROFILE_SHOTGUN and WeaponInventoryGetActiveAmmo(Player(0)) == 2, "first weapon occupies active handgun slot")
    call WeaponInventoryConsumeShot(Player(0))
    call Check(WeaponInventoryGetActiveAmmo(Player(0)) == 1, "shot consumes one ammo")
    call WeaponInventoryConsumeShot(Player(0))
    call Check(WeaponInventoryGetActiveProfile(Player(0)) == WEAPON_PROFILE_HANDGUN, "last shot restores handgun")
    call WeaponInventorySetSlotWeapon(Player(0), 1, WEAPON_PROFILE_SHOTGUN, -8)
    call Check(WeaponInventoryGetActiveAmmo(Player(0)) == 0, "negative finite ammo clamps to zero")
    call Check(not WeaponInventoryCanStartFire(Player(0)) and WeaponInventoryGetActiveProfile(Player(0)) == WEAPON_PROFILE_HANDGUN, "empty gun cannot begin and falls back")
    call WeaponInventoryGiveWeapon(Player(0), WEAPON_PROFILE_SHOTGUN, 2)
    call WeaponInventoryGiveWeapon(Player(0), WEAPON_PROFILE_SHOTGUN, 3)
    call Check(WeaponInventoryGetActiveAmmo(Player(0)) == 5, "duplicate pickup adds ammo")
    call WeaponInventoryGiveWeapon(Player(0), WEAPON_PROFILE_HEAVY_MACHINE_GUN, 4)
    call Check(WeaponInventoryGetSlotProfile(Player(0), 2) == WEAPON_PROFILE_HEAVY_MACHINE_GUN, "second type fills other handgun slot")
    call WeaponInventoryResetActiveSlotOnDeath(Player(0))
    call Check(WeaponInventoryGetSlotProfile(Player(0), 1) == WEAPON_PROFILE_HANDGUN and WeaponInventoryGetSlotProfile(Player(0), 2) == WEAPON_PROFILE_HEAVY_MACHINE_GUN, "death reset affects active slot while retaining secondary")
    call Check(GetUnitAbilityLevel(hero, 'U0AF') > 0, "original resources provide inventory fire ability U0AF")
    call Check(GetUnitAbilityLevel(hero, 'U0C1') > 0 and GetUnitAbilityLevel(hero, 'U0C2') > 0, "original resources provide both native slot selector abilities")
    set probe = CreateUnit(Player(15), 'pRSN', -6500., 3500., 0.)
    call Check(probe != null and GetUnitTypeId(probe) == 'pRSN', "original resources provide configured prisoner pickup unit")
    call RemoveUnit(probe)
    set shop = RefreshTenderUnitByType('h004', -6000., 3300., 0.)
    call Check(shop != null and GetUnitTypeId(shop) == 'h004', "original tender resource creates")
    call Check(IsUnitNearTender(hero, 500.), "tender proximity accepts nearby hero")
    call Check(not IsUnitNearTender(null, 500.), "tender proximity guards null hero")
    loop
        exitwhen i >= 6
        set probe = CreateUnit(Player(15), SelectionGetHeroUnitId(i), -7000., 3000., 0.)
        call Check(probe != null and GetUnitTypeId(probe) == SelectionGetHeroUnitId(i) and IsUnitType(probe, UNIT_TYPE_HERO), "original selection hero object " + I2S(i) + " exists")
        call RemoveUnit(probe)
        set i = i + 1
    endloop
    call PanCameraToTimed(-5700., 3000., 0.)
    call TriggerAddAction(damage, function OnDamage)
    call NextWeapon()
    set shop = null
    set probe = null
endfunction
private function Init takes nothing returns nothing
    call FogEnable(false)
    call FogMaskEnable(false)
    call TimerStart(phase, 2., false, function Begin)
endfunction
endlibrary
