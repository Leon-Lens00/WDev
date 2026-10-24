//TESH.scrollpos=2
//TESH.alwaysfold=0
scope EasterEgg initializer Init

    globals
        private constant integer HYDRA_ABILITY = 'A004'
        private constant integer HYDRA_UNIT_ID = 'o001'
        private integer  array   count   
        private boolean          paused = false
    endglobals
    
    private function PauseSound takes nothing returns nothing
        set paused = true
        call TriggerSleepAction(1.)
        set paused = false
    endfunction
    
    private function CoolSound takes string path, player p, boolean forceSound returns nothing
        local sound s 
        if not forceSound and paused then
            return
        endif
        call ExecuteFunc(PauseSound.name)
        set s = CreateSound(path, false, false, false, 10, 10, "CombatSoundsEAX")
        if GetLocalPlayer() != p then
            call SetSoundVolume(s, 0)
        endif
        call StartSound(s)
        call KillSoundWhenDone(s)
        set s = null
    endfunction

    struct HammerTime extends Hydra
    
        private static method onDestructable takes Missile missile, destructable hit returns boolean
            return true
        endmethod
    
        private static method onRemove takes Missile missile returns boolean
            return true
        endmethod
    
        private static method onTerrain takes Missile missile returns boolean
            return true
        endmethod
    
        private static method onCollide takes Missile missile, unit hit returns boolean
            if UnitAlive(hit) and IsUnitEnemy(hit, missile.owner) then
                call UnitDamageTarget(missile.source, hit, missile.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
                if not UnitAlive(hit) and (GetUnitTypeId(hit) != 0) then
                    call CoolSound("Units\\Human\\Muradin\\MuradinYesAttack3.wav", missile.owner, false)
                    if (IsUnitType(hit, UNIT_TYPE_GROUND)) then
                        call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", GetUnitX(hit), GetUnitY(hit)))
                    endif
                endif
                return true
            endif
            return false
        endmethod
    
        implement MissileStruct
        
        method onFire takes unit shooter, unit target, Missile missile returns nothing
            set missile.model      = "Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl"
            set missile.damage     = GetRandomReal(150, 550)
            set missile.collision  = 36.*scale
            set missile.collisionZ = 15.*scale
            set missile.speed      = 10.    
            set missile.scale      = scale
            set count[this]        = count[this] + 1
            if count[this] == 6 then
                call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Avatar\\AvatarCaster.mdl", shooter, "origin"))
                set attackSpeed = attackSpeed/2.
                set scale       = scale*2
                call SetUnitVertexColor(shooter, 150, 150, 150, 200)
            endif
            call thistype.launch(missile)
        endmethod
        
        method onTargetFilter takes unit target, player owner returns boolean
            return UnitAlive(target) and IsUnitEnemy(target, owner) 
        endmethod
    
        method onRemoveHead takes unit head returns nothing
            call RemoveUnit(head)
        endmethod
    
        method onSummonHead takes unit head returns nothing
            call CoolSound("Units\\Human\\Muradin\\MuradinYes4.wav", this.owner, true)
            set count[this] = 0
        endmethod
        
    endstruct
    
    private function OnCast takes nothing returns boolean
        local HammerTime hydra   
        local real x    = GetSpellTargetX()
        local real y    = GetSpellTargetY() 
        local real z    = GetRandomReal(0, 600)
        local real face = GetRandomReal(0., 2*bj_PI)*bj_RADTODEG
        local real interval = .23

        if (GetSpellAbilityId() == HYDRA_ABILITY) then
            set hydra                     = HammerTime.create(GetTriggerUnit(), HYDRA_UNIT_ID, x, y, z, face, interval)
            set hydra.headHeight          = 45.
            set hydra.scale               = .76
            set hydra.attackAnimationTime = .5
            set hydra.attackPeriod        = .2
            set hydra.attackSpeed         = 1.
            set hydra.duration            = 10.
            set hydra.attackRange         = 750.
            set hydra.heads               = 1
            set hydra.offset              = 8.
            set hydra.hasArcOrCurve       = false
            call hydra.summon()
        endif
        return false
    endfunction
    
    private function Pre takes nothing returns nothing
        call CoolSound("Units\\Human\\Muradin\\MuradinYes4.wav", null, true)
        call CoolSound("Units\\Human\\Muradin\\MuradinYesAttack3.wav", null, true)
        call DestroyTimer(GetExpiredTimer())
    endfunction
    
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        if UnitAddAbility(DemoMap_HERO, HYDRA_ABILITY) then
            call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            call TriggerAddCondition(t, Condition(function OnCast))
        endif
        call TimerStart(CreateTimer(), 1., false, function Pre)
    endfunction
    
endscope

