//TESH.scrollpos=7
//TESH.alwaysfold=0
native UnitAlive takes unit id returns boolean

scope FrozenOrb initializer Init
//=========================================================================
// Name: Frozen Orb; ©Blizzard Entertainment, Diablo II
// Version: 2.1
// Author: BPower
// Requirements: Missile, SpellEffectEvent
// Credits: Bribe for SpellEffectEvent 
//=========================================================================
// Description:
// A pulsating orb that shreds an area with Ice Bolts. 
// Each Bolt deals damage and has chance to burst dying enemies,
// leaving no corpse behind. 
//=========================================================================

// User settings:
// ==============

    globals
        private constant integer    FROZEN_ORB_ABILITY  = 'A001'
        private constant attacktype ATTACK_TYPE         = ATTACK_TYPE_NORMAL       
        private constant damagetype DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC
        private constant real       MISSILE_FLY_HEIGHT  = 50.00// Shared over all missiles of FrozenOrb. 
        private constant string     ON_BURST_SFX        = "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl"
    endglobals
        
    // Set the maximum fly distance for the main orb.
    private constant function GetOrbMaxDistance takes integer level returns real
        return 800. + level*0.
    endfunction
    
    // Set the maximum fly distance for the ice bolts.
    private constant function GetIceBoltMaxDistance takes integer level returns real
        return 400. + level*0.
    endfunction

    // Set the amount of ice bolts created when the main orb explodes.
    private constant function GetIceBoltCountOnExplode takes integer level returns integer
        return 12
    endfunction
    
    // You have full access granted to all members and methods from library Missile.
    // However missile.data, missile.source and missile.owner are reserved.
    private function CustomizeFrozenOrb takes Missile orb, integer level returns nothing
        set orb.speed = 13.
        set orb.model = "Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl"
        set orb.scale = .75
    endfunction
    
    // Same as CustomizeFrozenOrb, but for ice bolts.
    private function CustomizeIceBolt takes Missile bolt, integer level returns nothing
        set bolt.speed = 20.
        set bolt.model = "Abilities\\Weapons\\LichMissile\\LichMissile.mdl"  
        set bolt.scale = .65
        set bolt.damage = 10. + 20.*level
        set bolt.collision = 48.
    endfunction
        
    // Filter which units are hit by ice bolts.
    private function TargetFilter takes unit target, player owner returns boolean
        return not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(target, UNIT_TYPE_STRUCTURE) and UnitAlive(target) and IsUnitEnemy(target, owner)
    endfunction
    
    // Set the chance to burst an enemy to ice. Real comparison in range of 0 - 100.
    // Return smaller or equal to 0 if you don't need this feature.
    private constant function GetBurstChance takes integer level returns real
        return 5. + 5.*level
    endfunction
        
    // Filter out all units which shouldn't be removed from the game on burst. Heroes, .. etc
    // Those units who pass the filter get removed from the game and are inevitably gone.
    private function ExplodeFilter takes unit target returns boolean
        return not IsUnitType(target, UNIT_TYPE_MECHANICAL) and not IsUnitType(target, UNIT_TYPE_HERO)
    endfunction

    // The following struct "Buff" creates the buff- and frostnova effect of Frozen Orb.
    // Adjust the constants to your needs.
    private struct Buff extends array
        
        // Buff type settings. 
        private static constant integer CASTER_UNIT_ID = 'n000'
        private static constant integer BUFF_ORDER_ID  = 852226// OrderId("frostnova")
        private static constant integer BUFF_ABILITY   = 'A002'
        
        private static unit caster = null
        
        static method castTarget takes player owner, unit target returns nothing
            call SetUnitOwner(caster, owner, false)
            call IssueTargetOrderById(caster, BUFF_ORDER_ID, target)
            call SetUnitOwner(caster, Missile_NEUTRAL_PASSIVE, false)            
        endmethod
    
        private static method onInit takes nothing returns nothing
            set caster = CreateUnit(Missile_NEUTRAL_PASSIVE, CASTER_UNIT_ID, 0., 0., 0.)
            call SetUnitPosition(caster, 2147483647, 2147483647)
            call UnitAddAbility(caster, BUFF_ABILITY)
            call ShowUnit(caster, false)
        endmethod
    endstruct
    
//=====================================================================
// Frozen orb source code. Make changes carefully.
//=====================================================================
// You can extend struct IceBolt and / or struct FrozenOrb with 
// available Missile API, such as onDestructable, onTerrain ...
    
    private struct IceBolt extends array
        static constant real OFFSET = 32.// That ice bolts don't emit 
                                         // directly from the center of the orb.
        real chance
        
        private static method onRemove takes Missile missile returns boolean
            return true
        endmethod
                              // Runs when a missile collides with a unit.
        private static method onCollide takes Missile missile, unit hit returns boolean
            local thistype this = thistype(missile)
            
            if TargetFilter(hit, missile.owner) then
                call Buff.castTarget(missile.owner, hit)
                call UnitDamageTarget(missile.source, hit, missile.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null)
                
                if GetUnitTypeId(hit) != 0 and GetRandomReal(0., 100.) < chance and ExplodeFilter(hit) then
                    call DestroyEffect(AddSpecialEffect(ON_BURST_SFX, missile.x, missile.y))
                    call RemoveUnit(hit)
                endif
                return true// returning true will destroy the missile instance.
            endif
            return false// returning false will keep the missile flying.
        endmethod
        
        implement MissileStruct
    endstruct
    
    private function CreateIceBolt takes Missile orb, real angle, integer level returns nothing
        local real x = orb.x + IceBolt.OFFSET*Cos(angle)
        local real y = orb.y + IceBolt.OFFSET*Sin(angle)
        local Missile missile = Missile.create(x, y, MISSILE_FLY_HEIGHT, angle, GetIceBoltMaxDistance(level), MISSILE_FLY_HEIGHT)
    
        set IceBolt(missile).chance = GetBurstChance(level)
        call CustomizeIceBolt(missile, level)
        set missile.source = orb.source
        set missile.owner = orb.owner
        call IceBolt.launch(missile)
    endfunction
    
    private struct FrozenOrb extends array
        static constant real SPACING_ON_PERIOD = bj_PI*3/5
        static constant real SPACING_ON_REMOVE = bj_PI/4 
        
        integer level
                      // When the main orb gets deallocated.
        static method onRemove takes Missile missile returns boolean
            local thistype this = thistype(missile)
            local integer index = 0
            local integer count = GetIceBoltCountOnExplode(level)
            local real space = 2*bj_PI/count
            
            loop
                exitwhen index >= count
                call CreateIceBolt(missile, index*space + thistype.SPACING_ON_REMOVE, level)
                set index = index + 1
            endloop
            
            return true
        endmethod
                      // Every Missile_TIMER_TIMEOUT interval.
        static method onPeriod takes Missile missile returns boolean
            local thistype this = thistype(missile)
            
            call CreateIceBolt(missile, thistype.SPACING_ON_PERIOD*missile.data, level)
            set missile.data = missile.data + 1
            return false
        endmethod
    
        implement MissileStruct
    endstruct
                     // EVENT_PLAYER_UNIT_SPELL_EFFECT.
    private function OnEffect takes nothing returns nothing
        local unit source = GetTriggerUnit()
        local real x = GetUnitX(source)
        local real y = GetUnitY(source)
        local real angle = Atan2(GetSpellTargetY() - y, GetSpellTargetX() - x)
        local integer level = GetUnitAbilityLevel(source, FROZEN_ORB_ABILITY)
        local Missile missile = Missile.create(x, y, MISSILE_FLY_HEIGHT, angle, GetOrbMaxDistance(level), MISSILE_FLY_HEIGHT)
        
        set FrozenOrb(missile).level = level
        call CustomizeFrozenOrb(missile, level)
        set missile.source = source
        set missile.owner = GetTriggerPlayer()
        call FrozenOrb.launch(missile)
        
        set source = null 
    endfunction
    
    private function Init takes nothing returns nothing
        call RegisterSpellEffectEvent(FROZEN_ORB_ABILITY, function OnEffect)    
    endfunction
    
endscope