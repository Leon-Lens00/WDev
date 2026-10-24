//TESH.scrollpos=59
//TESH.alwaysfold=0
scope map

    globals
        private real X  = -1500
        private real Y  = -2280
        private real X0 = 1177
        private real Y0 = 1370
    endglobals
    
    private struct preload extends array
        static method sfx takes nothing returns nothing
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl", 2300,-2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl", 2300,-2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", 2300,-2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Volcano\\VolcanoDeath.mdl", 2300,-2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorTarget.mdl", 2300,-2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", 2300,-2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", 2300,-2900))
            call DestroyEffect(AddSpecialEffect("Doodads\\BlackCitadel\\Props\\RuneArt\\RuneArt1.mdl", 2300,-2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\Possession\\PossessionMissile.mdl", 2300,-2900))

        endmethod
    endstruct
    
    private struct xxx extends array
    private static method spawn takes nothing returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i == 4
            set u = CreateUnit(Player(1), 'ugho', X, Y, 0)
            call IssuePointOrder(u, "attack", X0, Y0)
            set u = CreateUnit(Player(2), 'ugho', X0, Y0, 0)
            call IssuePointOrder(u, "attack", X, Y)
            set i = i + 1
        endloop
        set u = null
    endmethod
    
    private static method revive takes nothing returns boolean
        local player p = GetTriggerPlayer()
        local unit u 
        if p == Player(1) then
            set u = CreateUnit(p, 'ugho', X, Y, 0)
            call IssuePointOrder(u, "attack", X0, Y0)
        elseif p == Player(2) then
            set u = CreateUnit(p, 'ugho', X0, Y0, 0)
            call IssuePointOrder(u, "attack", X, Y)
        elseif IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) then
            call ReviveHero(GetTriggerUnit(), 0,0, true)
        endif
        set u = null
        set p = null
        return false
    endmethod

    private static method reset takes nothing returns boolean
        call ClearTextMessages()
        call GroupEnumUnitsOfPlayer(bj_lastCreatedGroup, Player(0), null)
        loop
            set bj_lastCreatedUnit = FirstOfGroup(bj_lastCreatedGroup)
            exitwhen bj_lastCreatedUnit == null
            call GroupRemoveUnit(bj_lastCreatedGroup, bj_lastCreatedUnit)
            call UnitResetCooldown(bj_lastCreatedUnit)
            call SetUnitState(bj_lastCreatedUnit, UNIT_STATE_MANA, GetUnitState(bj_lastCreatedUnit, UNIT_STATE_MAX_MANA))    
        endloop
        return false
    endmethod
    
    private static method NewHero takes integer unitId returns nothing
        local unit u = CreateUnit(Player(0), unitId, 0, 0, 0)
        call SetHeroLevel(u, 12, true)
        set u = null
    endmethod
    
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.revive)
        call thistype.spawn() 
        call NewHero('Hblm')
        call NewHero('Uktl')
        call NewHero('Obla')
        call NewHero('Hmkg')
        call NewHero('Hvwd')
        call FogModifierStart(CreateFogModifierRect(Player(0), FOG_OF_WAR_VISIBLE, WorldBounds.world, false, false))
        call TriggerRegisterPlayerEventEndCinematic(t, Player(0))
        call TriggerAddCondition(t, Condition(function thistype.reset))
        call BJDebugMsg("Press |cffdaa520ESC|r to reset cooldowns and refresh mana")
        set t = null
        call preload.sfx()
    endmethod
    endstruct
endscope

