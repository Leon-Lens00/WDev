// Presentacion de apariciones de oleada: efectos de entrada (reserva) y salida (materializacion).
// Escucha los eventos del nucleo; el nucleo solo guarda fxId como dato del slot.
library WaveSpawnFx initializer Init requires Table, WaveTest
    globals
        constant integer WAVE_FX_MAX = 19
        private string array WaveFxIn
        private string array WaveFxOut
        // fxId heredado por unidades creadas con los ayudantes de WaveOwnerPolicy.
        private Table WaveFxByUnit
    endglobals

    function WaveSpawnFxIn takes integer fxId, real x, real y returns nothing
        if fxId > 0 and fxId <= WAVE_FX_MAX then
            call DestroyEffect(AddSpecialEffect(WaveFxIn[fxId], x, y))
        endif
    endfunction

    function WaveSpawnFxOut takes integer fxId, unit u returns nothing
        if fxId > 0 and fxId <= WAVE_FX_MAX and u != null then
            call DestroyEffect(AddSpecialEffectTarget(WaveFxOut[fxId], u, "origin"))
        endif
    endfunction

    function WaveSetSpawnFxIdForUnit takes unit u, integer fxId returns nothing
        if u != null and fxId > 0 then
            set WaveFxByUnit[GetHandleId(u)] = fxId
        endif
    endfunction

    // fxId del slot de la unidad o, para unidades creadas por los ayudantes, el heredado.
    function WaveGetSpawnFxIdForUnit takes unit u returns integer
        local WaveSlot s
        local integer hid
        if u == null or GetUnitTypeId(u) == 0 then
            return 0
        endif
        set s = GetWaveSlotByUnit(u)
        if s != 0 then
            return s.fxId
        endif
        set hid = GetHandleId(u)
        if WaveFxByUnit.has(hid) then
            return WaveFxByUnit[hid]
        endif
        return 0
    endfunction

    private function OnReserve takes nothing returns nothing
        local WaveSlot s = GetWaveEventSlot()
        if s != 0 then
            call WaveSpawnFxIn(s.fxId, GetWaveEventX(), GetWaveEventY())
        endif
    endfunction

    private function OnSpawn takes nothing returns nothing
        local WaveSlot s = GetWaveEventSlot()
        if s != 0 and not IsWaveEventExternal() then
            call WaveSpawnFxOut(s.fxId, GetWaveEventUnit())
        endif
    endfunction

    private function OnExit takes nothing returns nothing
        local unit u = GetWaveEventUnit()
        if u != null then
            call WaveFxByUnit.remove(GetHandleId(u))
        endif
        set u = null
    endfunction

    private function Init takes nothing returns nothing
        set WaveFxByUnit = Table.create()
        set WaveFxIn[1] = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl"
        set WaveFxOut[1] = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl"
        set WaveFxIn[2] = "Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl"
        set WaveFxOut[2] = "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl"
        set WaveFxIn[3] = "Abilities\\Spells\\Undead\\CarrionSwarm\\CarrionSwarmDamage.mdl"
        set WaveFxOut[3] = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl"
        set WaveFxIn[4] = "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl"
        set WaveFxOut[4] = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl"
        set WaveFxIn[5] = "Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl"
        set WaveFxOut[5] = "Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosDone.mdl"
        set WaveFxIn[6] = "Abilities\\Spells\\Items\\StaffOfPurification\\PurificationCaster.mdl"
        set WaveFxOut[6] = "Abilities\\Spells\\Items\\StaffOfPurification\\PurificationTarget.mdl"
        set WaveFxIn[7] = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"
        set WaveFxOut[7] = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl"
        set WaveFxIn[8] = "Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl"
        set WaveFxOut[8] = "Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl"
        set WaveFxIn[9] = "Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl"
        set WaveFxOut[9] = "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl"
        set WaveFxIn[10] = "Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl"
        set WaveFxOut[10] = "Objects\\Spawnmodels\\Undead\\UCancelDeath\\UCancelDeath.mdl"
        set WaveFxIn[11] = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        set WaveFxOut[11] = "Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl"
        set WaveFxIn[12] = "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl"
        set WaveFxOut[12] = "Objects\\Spawnmodels\\NightElf\\NECancelDeath\\NECancelDeath.mdl"
        set WaveFxIn[13] = "Objects\\Spawnmodels\\Other\\ToonBoom\\ToonBoom.mdl"
        set WaveFxOut[13] = "Abilities\\Spells\\Items\\AIem\\AIemTarget.mdl"
        set WaveFxIn[14] = "Abilities\\Spells\\Other\\Awaken\\Awaken.mdl"
        set WaveFxOut[14] = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl"
        set WaveFxIn[15] = "Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdl"
        set WaveFxOut[15] = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl"
        set WaveFxIn[16] = "Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl"
        set WaveFxOut[16] = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
        set WaveFxIn[17] = "Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl"
        set WaveFxOut[17] = "Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl"
        set WaveFxIn[18] = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
        set WaveFxOut[18] = "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl"
        set WaveFxIn[19] = "Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl"
        set WaveFxOut[19] = "Abilities\\Spells\\Items\\TomeOfRetraining\\TomeOfRetrainingCaster.mdl"
        call RegisterWaveReserveEvent(function OnReserve)
        call RegisterWaveSpawnEvent(function OnSpawn)
        call RegisterWaveDeathEvent(function OnExit)
    endfunction
endlibrary
