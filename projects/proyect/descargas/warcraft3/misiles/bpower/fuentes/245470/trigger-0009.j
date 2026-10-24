//TESH.scrollpos=286
//TESH.alwaysfold=0
scope Armageddon initializer Init /* v2.4.1
*************************************************************************************
*
*   This terrible force of nature's vengeance rains down flaming stones around the caster,
*   pummeling any opponents foolish enough to be caught in its fury.
*   ©Blizzard Entertainment, Diablo II
*
*************************************************************************************
*
*   Requires Missile, TimerUtils, SpellEffectEvent and RegisterPlayerUnitEvent.
*       - Credits to Bribe, Magtheridon96 and Vexorian
*   
*   Optionally IsDestructableTree to run an onDestructable collision.
*
*************************************************************************************/
//**
//*  User settings:
//*  ==============
    // One declaration of native "UnitAlive" per map script is enough.
    native UnitAlive takes unit id returns boolean

    globals
        private constant integer ARMAGEDDON_ABILITY    = 'A001'
        
        // Damage options.
        private constant attacktype ATTACK_TYPE        = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE        = DAMAGE_TYPE_FIRE
        
        // Missile constants.
        private constant real METEOR_START_HEIGHT      = 1300.
        
        // Effect options.
                                // EVENT_PLAYER_UNIT_SPELL_EFFECT.
        private constant string ON_EFFECT_EVENT_FX     = "Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosTarget.mdl"
        private constant string ON_CASTER_FX           = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl"
        private constant string CASTER_FX_ATTACH_POINT = "origin"
        private constant string ON_DAMAGE_UNIT_FX      = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
        private constant string DAMAGE_FX_ATTACH_POINT = "chest"
        
        // Spell concept.
                                 // EVENT_PLAYER_UNIT_ISSUED_ORDER or EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER.
        private constant boolean IS_IMMEDIATE_ORDER    = true
        private constant boolean IMPACT_DAMAGES_TREES  = true// Requires library IsDestructableTree.
        private constant boolean DAMAGE_FLYING_UNITS   = true// Requires USE_COLLISION_Z_FILTER = true in library Missile.
    endglobals
    
    // Set if the spell moves along with the caster. 
    private function IsSpellMovingWithCaster takes unit caster, integer level returns boolean
        return true
    endfunction
    
    // Set if the caster has to channel the spell.
    // In case the spell is channeling, make sure the "follow through time" field of the ability fits the spell duration.
    private function IsSpellChanneling takes unit caster, integer level returns boolean
        return true
    endfunction
    
    // Set how many meteor should be created per second. 
    // This function is re-evaluated each second, therefore a GetRandomInt() also makes sense here.
    private constant function GetMeteorsPerSecond takes integer level returns integer
        return 1 + (2*level)
    endfunction
    
    // Set the total spell duration.
    private constant function GetSpellDuration takes integer level returns real
        return 6. + (2*level)
    endfunction
    
    // Set the maximum field size in which effects take place.
    private constant function GetSpellFieldSize takes integer level returns real
        return 500. + (50*level)
    endfunction
    
    // Set the expected fly time per meteor. 
    private function GetMeteorFlyTime takes integer level returns real
        return GetRandomReal(2., 3)
    endfunction
    
    // Filter valid target units. Runs on unit collision.
    // Do NOT filter for flying units. This is done internally inside the spell script.
    private function FilterUnits takes unit target, player p returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, p)
    endfunction
    
    // Runs each time before a new meteor is created.
    private function GlobalCasterCondition takes unit caster returns boolean
        return UnitAlive(caster)
    endfunction
    
    // Customize all missile members to your needs. "speed", "source", "owner" and "acceleration" are reserved and will be overriden.
    private function CustomizeMeteor takes Missile missile, unit caster, integer level returns nothing
        local real scale = GetRandomReal(.8, 1.3)
        set missile.scale = scale
        set missile.damage = 55. + 20.*level*scale
        set missile.collision = 96.*scale
        set missile.collisionZ = 96.*scale// Only required for if you want to damage flying units in mid air.
        set missile.model = "Abilities\\Spells\\Other\\Volcano\\VolcanoMissile.mdl"
    endfunction
    
    // You may delete the following content and return null for no sound.
    private function GetSoundHandle takes nothing returns sound
        local string file = "Abilities\\Spells\\Demon\\RainOfFire\\RainOfFireLoop1.wav"
        local sound snd = CreateSound(file, true, true, true, 10, 10, "")
        call SetSoundChannel(snd, 5)
        call SetSoundVolume(snd, 127)
        call SetSoundDistances(snd, 600, 10000)
        call SetSoundDistanceCutoff(snd, 3000)
        call SetSoundConeAngles(snd, 0, 0, 127)
        call SetSoundConeOrientation(snd, 0, 0, 0)
        call StartSound(snd)
        set bj_lastPlayedSound = snd
        set snd = null
        return bj_lastPlayedSound// null
    endfunction

//========================================================================
// Armageddon code. Make changes carefully.
//========================================================================
    
    // Uses Missile's API.
    private struct Meteor extends array
        
        // Runs on any destructable collision. You'll need IsDestructableTree.
        static if LIBRARY_IsDestructableTree and IMPACT_DAMAGES_TREES then
            static method onDestructable takes Missile missile, destructable hit returns boolean
                if IsTreeAlive(hit) then
                    if (missile.damage > (GetWidgetLife(hit) + .405)) then
                        call KillDestructable(hit)
                    else
                        call SetWidgetLife(hit, GetWidgetLife(hit) - missile.damage)
                        call SetDestructableAnimation(hit, "stand hit")
                    endif
                endif
                return false
            endmethod
        endif
        
        // Runs on any unit collision. Written to hit flying units in mid air.
        // Requires Missile_USE_COLLISION_Z_FILTER = true.
        static if Missile_USE_COLLISION_Z_FILTER and DAMAGE_FLYING_UNITS then
            static method onCollide takes Missile missile, unit hit returns boolean
                if IsUnitType(hit, UNIT_TYPE_FLYING) and FilterUnits(hit, missile.owner) then
                    if UnitDamageTarget(missile.source, hit, missile.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null) then
                        call DestroyEffect(AddSpecialEffectTarget(ON_DAMAGE_UNIT_FX, hit, DAMAGE_FX_ATTACH_POINT))
                    endif
                endif
                return false
            endmethod
        endif
        
        // Runs when a missile launched from the Armageddon struct is deallocated. 
        // Written to hit non flying units in collision range.
        static method onRemove takes Missile missile returns boolean
            local unit u
            call GroupEnumUnitsInRange(bj_lastCreatedGroup, missile.x, missile.y, missile.collision + Missile_MAXIMUM_COLLISION_SIZE, null)
            loop
                set u = FirstOfGroup(bj_lastCreatedGroup)
                exitwhen u == null
                call GroupRemoveUnit(bj_lastCreatedGroup, u)
                if IsUnitInRange(missile.dummy, u, missile.collision) and not IsUnitType(u, UNIT_TYPE_FLYING) and FilterUnits(u, missile.owner) then
                    if UnitDamageTarget(missile.source, u, missile.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, null) then
                        call DestroyEffect(AddSpecialEffectTarget(ON_DAMAGE_UNIT_FX, u, DAMAGE_FX_ATTACH_POINT))
                    endif
                endif
            endloop
            return true
        endmethod
        
        // Enables the Missile interface for this struct.
        implement MissileStruct
    endstruct

    private function Random takes nothing returns real
        return GetRandomReal(0., 1.)
    endfunction
    
    private function GetRandomRange takes real radius returns real
        local real r = Random() + Random()
        if r > 1. then 
            return (2 - r)*radius
        endif
        return r*radius
    endfunction
    
    private function CreateMeteor takes unit source, player owner, real centerX, real centerY, real maxRange, integer level returns nothing
        // Get point of creation.
        local real theta = 2*bj_PI*Random()
        local real radius = GetRandomRange(maxRange)
        local real posX = centerX + radius*Cos(theta)
        local real posY = centerY + radius*Sin(theta)
        
        // Get the fly angle and maximum distance towards it.
        local real angle = 2*bj_PI*Random()
        local real maxX = centerX + maxRange*Cos(angle)
        local real maxY = centerY + maxRange*Sin(angle)
        
        // Get the maximum distance without leaving the field.
        local real dX = posX - maxX
        local real dY = posY - maxY                                                    // Between 0 and max distance.
        local Missile missile = Missile.create(posX, posY, METEOR_START_HEIGHT, angle, SquareRoot(dX*dX + dY*dY)*Random(), 0.)
        
        // Allow user customization.
        call CustomizeMeteor(missile, source, level)
        // Set or override important missile fields.
        set missile.source = source
        set missile.owner = owner
        set missile.acceleration = 0.
        call missile.flightTime2Speed(GetMeteorFlyTime(level))
        call Meteor.launch(missile)
    endfunction
    
    private struct Armageddon// extends array
        // implement Alloc
        //
        // Members.
        unit    source
        player  user
        timer   clock
        effect  fx 
        sound   snd
        //
        real    centerX
        real    centerY
        real    size
        real    time
        real    interval
        integer count
        integer order
        integer level
        // Spell concept members.
        boolean move
        boolean channel
        
        method clear takes nothing returns nothing            
            if snd != null then
                call StopSound(snd, true, true)
                set snd = null
            endif
            call DestroyEffect(fx)
            call ReleaseTimer(clock)
            call deallocate()
            
            set clock = null
            set source = null
            set user = null
            set fx = null
        endmethod
        
        static method onPeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local boolean fire = (count > 0)
            // Evaluate global conditions.
            if not GlobalCasterCondition(source) or time <= 0. or (channel and (order != GetUnitCurrentOrder(source))) then
                call clear()
            else
                // Update time members.
                set time  = time - interval
                set count = count - 1
                if count <= 0 then
                    set count = GetMeteorsPerSecond(level)
                    set interval = 1./IMaxBJ(1, count)
                    call TimerStart(clock, interval, true, function thistype.onPeriodic)
                endif
                // Update the center position.
                if move then 
                    set centerX = GetUnitX(source)
                    set centerY = GetUnitY(source)
                    if (snd != null) then
                        call SetSoundPosition(snd, centerX, centerY, 0.)
                    endif
                endif
                if fire then
                    // Create a new meteor.
                    call CreateMeteor(source, user, centerX, centerY, size, level)
                endif
            endif
        endmethod
    endstruct
    
                     // EVENT_PLAYER_UNIT_SPELL_EFFECT.
    private function OnEffect takes nothing returns nothing
        local unit source = GetTriggerUnit()
        local integer level = GetUnitAbilityLevel(source, ARMAGEDDON_ABILITY) 
        local Armageddon dex = Armageddon.create()
    
        set dex.source  = source 
        set dex.level   = level
        set dex.clock   = NewTimerEx(dex)
        set dex.user    = GetTriggerPlayer()
        set dex.order   = GetUnitCurrentOrder(source)
        set dex.time    = GetSpellDuration(level)
        set dex.count   = GetMeteorsPerSecond(level)
        set dex.move    = IsSpellMovingWithCaster(source, level)
        set dex.size    = GetSpellFieldSize(level)*.5
        set dex.channel = IsSpellChanneling(source, level)
        
        static if IS_IMMEDIATE_ORDER then
            set dex.centerX = GetUnitX(source)
            set dex.centerY = GetUnitY(source)
        else
            set dex.centerX = GetSpellTargetX()
            set dex.centerY = GetSpellTargetY()
        endif
        // Run effects.
        set dex.snd = GetSoundHandle()
        if dex.snd != null then
            call SetSoundPosition(dex.snd, dex.centerX, dex.centerY, 0.)
        endif
        call DestroyEffect(AddSpecialEffect(ON_EFFECT_EVENT_FX, dex.centerX, dex.centerY))
        set dex.fx = AddSpecialEffectTarget(ON_CASTER_FX, source, CASTER_FX_ATTACH_POINT)
        // Start the spell.
        set dex.interval = 1./IMaxBJ(1, dex.count)
        call TimerStart(dex.clock, dex.interval, true, function Armageddon.onPeriodic)
        
        set source = null
    endfunction
    
    private function Init takes nothing returns nothing
        call RegisterSpellEffectEvent(ARMAGEDDON_ABILITY, function OnEffect)
    endfunction
endscope
