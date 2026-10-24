//TESH.scrollpos=45
//TESH.alwaysfold=0
library IceHydra initializer Init uses Hydra

    globals
        private constant integer HYDRA_ABILITY = 'A000'
        private constant integer HYDRA_UNIT_ID = 'o000'
    endglobals

    struct IceHydra extends Hydra

        private static method onRemove takes Missile missile returns boolean
            return true
        endmethod
    
        private static method onTerrain takes Missile missile returns boolean
            return true
        endmethod
    
        private static method onCollide takes Missile missile, unit hit returns boolean
            if UnitAlive(hit) and IsUnitEnemy(hit, missile.owner) then
                if IsUnitType(hit, UNIT_TYPE_STRUCTURE) then
                    return UnitDamageTarget(missile.source, hit, missile.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
                endif
                return UnitDamageTarget(missile.source, hit, missile.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
            endif
            return false
        endmethod
    
        implement MissileStruct
        
        method onFire takes unit shooter, unit target, Missile missile returns nothing
            set missile.model      = "Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl"
            set missile.scale      = 0.8
            set missile.damage     = GetRandomReal(15, 30)
            set missile.collision  = 32.
            set missile.collisionZ = 15.
            set missile.speed      = 35.        
            call thistype.launch(missile)
        endmethod
        
        method onTargetFilter takes unit target, player owner returns boolean
            return UnitAlive(target) and IsUnitEnemy(target, owner) 
        endmethod
    
        method onRemoveHead takes unit head returns nothing
        endmethod
    
        method onSummonHead takes unit head returns nothing
        endmethod
        
    endstruct

    private function OnCast takes nothing returns boolean
        local IceHydra hydra   
        local real x    = GetSpellTargetX()
        local real y    = GetSpellTargetY() 
        local real z    = 0.
        local real face = GetRandomReal(0., 2*bj_PI)*bj_RADTODEG
        local real interval = 1.523

        if (GetSpellAbilityId() == HYDRA_ABILITY) then
            set hydra                     = IceHydra.create(GetTriggerUnit(), HYDRA_UNIT_ID, x, y, z, face, interval)
            set hydra.headHeight          = 55.
            set hydra.scale               = 1.2
            set hydra.attackAnimationTime = .5
            set hydra.attackPeriod        = .2
            set hydra.attackSpeed         = .6
            set hydra.duration            = 10.
            set hydra.attackRange         = 1200.
            set hydra.heads               = 3
            set hydra.offset              = 8.
            set hydra.hasArcOrCurve       = false
            set hydra.birthAnimationTime  = 1.
            //call hydra.optimize()
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
    
endlibrary

