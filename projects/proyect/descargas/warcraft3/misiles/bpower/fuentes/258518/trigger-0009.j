//TESH.scrollpos=47
//TESH.alwaysfold=0
scope FireHydra initializer Init

    globals
        private constant integer HYDRA_ABILITY = 'A002'
        private constant integer HYDRA_UNIT_ID = 'o002'
    endglobals

    struct FireHydra extends Hydra

        private static method onRemove takes Missile missile returns boolean
            return true
        endmethod
    
        private static method onTerrain takes Missile missile returns boolean
            return true
        endmethod
    
        private static method onCollide takes Missile missile, unit hit returns boolean
            if UnitAlive(hit) and IsUnitEnemy(hit, missile.owner) then
                return UnitDamageTarget(missile.source, hit, missile.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
            endif
            return false
        endmethod
    
        implement MissileStruct
        
        method onFire takes unit shooter, unit target, Missile missile returns nothing
            set missile.model      = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
            set missile.scale      = 1.
            set missile.damage     = GetRandomReal(50, 150)
            set missile.collision  = 32.
            set missile.collisionZ = 15.
            set missile.speed      = 27.        
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
        local FireHydra hydra   
        local real x    = GetSpellTargetX()
        local real y    = GetSpellTargetY() 
        local real z    = 0.
        local real face = GetRandomReal(0., 2*bj_PI)*bj_RADTODEG
        local real interval = .23

        if (GetSpellAbilityId() == HYDRA_ABILITY) then
            set hydra                     = FireHydra.create(GetTriggerUnit(), HYDRA_UNIT_ID, x, y, z, face, interval)
            set hydra.heads               = 3   
            set hydra.attackAnimationTime = .5 
            set hydra.attackSpeed         = 3.  
            set hydra.attackPeriod        = .25
            set hydra.duration            = 12
            set hydra.attackRange         = 950.
            set hydra.headHeight          = 55. 
            set hydra.scale               = 1.  
            set hydra.hasArcOrCurve       = false
            set hydra.birthAnimationTime  = 1.
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

