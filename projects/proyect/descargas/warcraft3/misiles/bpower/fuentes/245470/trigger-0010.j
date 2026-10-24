//TESH.scrollpos=3
//TESH.alwaysfold=0
scope map

    globals
        private real X  = -1500
        private real Y  = -2280
        private real X0 = 1177
        private real Y0 = 1370
        private unit HERO
    endglobals
    
    private struct preload extends array
        static method sfx takes nothing returns nothing
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Volcano\\VolcanoMissile.mdl", 2300,-2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosTarget.mdl", 2300,-2900))
        endmethod
    endstruct
    
    private struct xxx extends array
    private static method spawn takes nothing returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i == 4
            set u = CreateUnit(Player(1), 'hfoo', X, Y, 0)
            call IssuePointOrder(u, "attack", X0, Y0)
            set u = CreateUnit(Player(1), 'ehip', X, Y, 0)
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
        local player p = GetTriggerPlayer()
        local integer id = GetUnitTypeId(GetTriggerUnit())
        local unit u
        if p == Player(1) then
            set u = CreateUnit(p, id, X, Y, 0)
            call IssuePointOrder(u, "attack", X0, Y0)
        elseif p == Player(2) then
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
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.revive)
        call thistype.spawn() 
        set HERO    = CreateUnit(Player(0), 'Hblm', 0,0,0)
        //set HERO2   = CreateUnit(Player(0), 'Uktl', 0,0,0)
        call SetHeroLevel(HERO, 12, true)
        //call SetHeroLevel(HERO2, 12, true)
        call FogModifierStart(CreateFogModifierRect(Player(0), FOG_OF_WAR_VISIBLE, GetWorldBounds(), false, false))
        call TriggerRegisterPlayerEventEndCinematic(t, Player(0))
        call TriggerAddCondition(t, Condition(function thistype.reset))
        call BJDebugMsg("Press |cffdaa520ESC|r to reset cooldowns and refresh mana")
        set t = null
        call preload.sfx()
    endmethod
    endstruct
endscope

