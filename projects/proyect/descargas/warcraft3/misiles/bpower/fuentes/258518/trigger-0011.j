//TESH.scrollpos=45
//TESH.alwaysfold=0
scope FriendlyHydra initializer Init

    globals
        private constant integer HYDRA_ABILITY = 'A001'
        private constant integer HYDRA_UNIT_ID = 'o002'
    endglobals

    struct FriendlyHydra extends Hydra

        private static method onRemove takes Missile missile returns boolean
            return true
        endmethod
    
        private static method onTerrain takes Missile missile returns boolean
            return true
        endmethod
    
        private static method onCollide takes Missile missile, unit hit returns boolean
            if (UnitAlive(hit) and IsUnitAlly(hit, missile.owner)) then
                call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl", hit, "origin"))
                call SetWidgetLife(hit, GetWidgetLife(hit) + missile.damage)
                return true
            endif
            return false
        endmethod
    
        implement MissileStruct
        
        method onFire takes unit shooter, unit target, Missile missile returns nothing
            set missile.model      = "Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl"
            set missile.scale      = 1.2
            set missile.damage     = GetRandomReal(25., 40.)
            set missile.collision  = 32.
            set missile.collisionZ = 15.
            set missile.speed      = 8.        
            set missile.arc        = (bj_PI/2.5)// You can only use arc/curve when hasArcOrCurve is set to true.
            set missile.target     = target
            call thistype.launch(missile)
        endmethod
        
        method onTargetFilter takes unit target, player owner returns boolean
            return UnitAlive(target) and IsUnitAlly(target, owner) and GetWidgetLife(target) != GetUnitState(target, UNIT_STATE_MAX_LIFE) 
        endmethod
    
        method onRemoveHead takes unit head returns nothing
        endmethod
    
        method onSummonHead takes unit head returns nothing
        endmethod
        
    endstruct

    private function OnCast takes nothing returns boolean
        local FriendlyHydra hydra   
        local real x    = GetSpellTargetX()
        local real y    = GetSpellTargetY() 
        local real z    = 0.
        local real face = GetRandomReal(0., 2*bj_PI)*bj_RADTODEG
        local real interval = .23

        if (GetSpellAbilityId() == HYDRA_ABILITY) then
            set hydra                     = FriendlyHydra.create(GetTriggerUnit(), HYDRA_UNIT_ID, x, y, z, face, interval)
            set hydra.headHeight          = 55.
            set hydra.scale               = 1.2
            set hydra.attackAnimationTime = .5
            set hydra.attackPeriod        = 1.
            set hydra.attackSpeed         = 3.
            set hydra.duration            = 20.
            set hydra.attackRange         = 600.
            set hydra.heads               = 3
            set hydra.offset              = 8.
            set hydra.hasArcOrCurve       = true
            set hydra.birthAnimationTime  = 1.
            call hydra.optimize()
            call hydra.summon()
        endif
        return false
    endfunction
    
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        if UnitAddAbility(DemoMap_HERO, HYDRA_ABILITY) then
            call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            call TriggerAddCondition(t, Condition(function OnCast))
        endif
    endfunction
    
endscope

