//TESH.scrollpos=24
//TESH.alwaysfold=0
library DemoMap

    globals
        private real X  = -1500
        private real Y  = -2280
        private real X0 = 1177
        private real Y0 = 1370
        public unit HERO 
    endglobals
    
    private struct preload extends array
        static method sfx takes nothing returns nothing
            call RemoveUnit(CreateUnit(Player(15), 'o002', 0, 0, 0))
            call RemoveUnit(CreateUnit(Player(15), 'o000', 0, 0, 0))
            call RemoveUnit(CreateUnit(Player(15), 'o001', 0, 0, 0))
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", 0, 0))
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", 0, 0))
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl", 0, 0))
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl", 0, 0))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl", 0, 0))
        endmethod
    endstruct
    
    private struct xxx extends array
    private static method spawn takes nothing returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i == 2
            set u = CreateUnit(Player(1), 'hfoo', X, Y, 0)
            call IssuePointOrder(u, "attack", X0, Y0)
            set u = CreateUnit(Player(1), 'ehpr', X, Y, 0)
            call IssuePointOrder(u, "attack", X0, Y0)
            set u = CreateUnit(Player(2), 'ugho', X0, Y0, 0)
            call IssuePointOrder(u, "attack", X, Y)
            set u = CreateUnit(Player(2), 'ugar', X0, Y0, 0)
            call IssuePointOrder(u, "attack", X, Y)
            set i = i + 1
        endloop
        set u = null
    endmethod
    
    private static method revive takes nothing returns boolean
        local player p   = GetTriggerPlayer()
        local integer id = GetUnitTypeId(GetTriggerUnit())
        local unit u 
        if p == Player(1) and GetUnitAbilityLevel(GetTriggerUnit(), 'Aloc') == 0 then
            set u = CreateUnit(p, id, X, Y, 0)
            call IssuePointOrder(u, "attack", X0, Y0)
        elseif p == Player(2)and GetUnitAbilityLevel(GetTriggerUnit(), 'Aloc') == 0 then
            set u = CreateUnit(p, id, X0, Y0, 0)
            call IssuePointOrder(u, "attack", X, Y)
        elseif GetTriggerUnit() == HERO then
            call ReviveHero(HERO, 0,0, true)
        endif
        set u = null
        set p = null
        return false
    endmethod

    private static method reset takes nothing returns boolean
        call ClearTextMessages()
        call UnitResetCooldown(HERO)
        call SetUnitState(HERO, UNIT_STATE_MANA, GetUnitState(HERO, UNIT_STATE_MAX_MANA))
        return false
    endmethod
    
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
        call TriggerAddCondition(t, Condition( function thistype.revive))
        call thistype.spawn() 
        set t = CreateTrigger()
        set HERO   = CreateUnit(Player(0), 'Uktl', 0,0,0)
        call SetHeroLevel(HERO, 12, true)
        call FogModifierStart(CreateFogModifierRect(Player(0), FOG_OF_WAR_VISIBLE, WorldBounds.world, false, false))
        call TriggerRegisterPlayerEventEndCinematic(t, Player(0))
        call TriggerAddCondition(t, Condition(function thistype.reset))
        call BJDebugMsg("Press |cffdaa520ESC|r to reset cooldowns and refresh mana")
        set t = null
        call preload.sfx()
        call AddSpecialEffectTarget("UI\\Feedback\\SelectionCircleEnemy\\SelectionCircleEnemy.mdx", HERO, "origin")
    endmethod
    endstruct
endlibrary

