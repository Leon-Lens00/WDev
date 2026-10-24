//TESH.scrollpos=106
//TESH.alwaysfold=0
library HydraTemplate uses Hydra
//******************************************************************************
//*
//* A guide to individual Hydra structs 
//* ===================================
//*  
//*  First and foremost Hydra uses the vJass feature "Extending structs".
//*     - http://www.hiveworkshop.com/forums/tutorial-submission-283/vjass-meet-vjass-extending-structs-267719/#post2706474
//*  
//* Which means that each of your custom Hydra-types will extend Hydra. Example: FireHydra extends Hydra
//* That makes customization very flexible, as Hydra will evaluate several stub methods
//* in the respective child struct like the target filter or the missile setup.
//*
//*  The projectiles fired by hydra units are outsourced to library Missile,
//* as consequence you have full access granted to the Missile API, which
//* can be individual per child struct. This means projectiles fired by
//* i.e. FireHydra can have a different behaviour than those fired by an i.e. IceHydra
//* If you haven't done it already, please do a proper setup for the globals in library Missile
//*
//*  struct Hydra has a boolean member named hasArcOrCurve. You have to set it per Hydra instance you create
//* to false or true. Set it to true, if you wish to setup curve= or arc= for that custom Hydra.
//* Don't forget it, because otherwise the projectiles fired in the struct will go crazy.
//* in DEBUG_MODE you will recieve a warning, if you forget to set hasArcOrCurve.  
//*
//*  Below you will find an example struct, how a custum Hydra could look like
//* For more examples check out IceHydra, FriendlyHydra, EasterEgg, ... in this map.
//*
//*
//********************************************************************************

//=================================================================================
    
    //*  Declare a new custom hydra type which extends Hydra
    //* Here I have chosen the struct name AcidHydra.   
    struct AcidHydra extends Hydra

    //*
    //*  Acces the API of library Missile ( for detailed information read library Missile ).
    //* As already mentioned above, you have granted full access to the API of library Missile.
    //* You can declare various static method which will be called if a Missile launched from this struct,
    //* meets the condition for the respective static method.
    //*
    //* Available static methods are:
    //*
    //*     static method onCollide takes Missile missile, unit hit returns boolean
    //*          -   Runs every time the missile collides with a unit.
    //*
    //*     static method onPeriod takes Missile missile returns boolean
    //*          -   Runs every Missile_TIMER_TIMEOUT seconds.
    //*
    //*     static method onFinish takes Missile missile returns boolean
    //*          -   Runs whenever the missile finishes it's course.
    //*          -   Runs before the missile is destroyed.
    //*          -   Does not run, if a Missile is destroyed by another method.
    //*
    //*     static method onRemove takes Missile missile returns boolean
    //*          -   Runs whenever the missile is deallocated.
    //*          -   Return true will recycle a Missile delayed ( only if WRITE_DELAYED_MISSILE_RECYCLING = true )
    //*          -   Return false will recycle a Missile right away.
    //*          -   Runs always, if declared!!
    //*
    //*     static method onDestructableFilter takes nothing returns boolean
    //*          -   Runs before onDestructable.
    //*          -   May create a better filter for enumerated destructables.
    //*          -   Only method which has no impact on the Missile instance.
    //*
    //*     static method onDestructable takes Missile missile, destructable hit returns boolean
    //*          -   Runs every time the missile collides with a destructable.
    //*          -   Can use onDestructableFilter ( optional ) 
    //*          -   Runs after onDestructableFilter ( if filter is declared )
    //*
    //*       Hint: missile.data is always the respective Hydra instance.
    //*
    //*  Let's see some of the static methods I declared for this struct. 
    
        private static method onRemove takes Missile missile returns boolean
            return true
        endmethod
        
        //* Will kill the missile, when it collides i.e. with a wall.
        private static method onTerrain takes Missile missile returns boolean
            return true
        endmethod
        
        //* Will kill the missile when it deals damage.
        //* You can read missile members, like missile.source, missile.damage, ....
        private static method onCollide takes Missile missile, unit hit returns boolean
            if UnitAlive(hit) and IsUnitEnemy(hit, missile.owner) then
                return UnitDamageTarget(missile.source, hit, missile.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
            endif
            return false
        endmethod
        
        //*  module MissileStruct is required, that a hydra unit can fire missiles at all.
        //* The best place for it is above the Hydra stub methods and below the Missile API.
        //* In this position the JassHelper will not generate extra pseudo-code duplicates.
        implement MissileStruct
        
    //*  Access the Hydra API: ( for detailed information read library Hydra. )
    //* As mentioned above you can customize a couple of stub methods located 
    //* in library Hydra, our parent struct. A declaration of method onFire
    //* is required, that a Hydra type of this struct can fire missiles at all. 
    //*
    //*  Available stub methods are:
    //* 
    //*      public stub method onSummonHead takes unit head returns nothing
    //*          - runs each time a new head is summoned.
    //*
    //*      public stub method onRemoveHead takes unit head returns nothing 
    //*          - runs each time a head dies.
    //*
    //*      public stub method onTargetFilter takes unit target, player owner returns boolean
    //*          - customize a target filter. As you can see each different Hydra type can have it's own filter.
    //*  
    //*      public stub method onFire takes unit shooter, unit target, Missile missile returns nothing
    //*          - customize the missile datas here. ( damage, model, arc, curve, ... )
    //*          - from this method you have to launch the missile via thistype.launch(missile)
    //*          
    //*  Let's see some example code:
    
        //*  Here we have access to the shooting head and the already created missile instance.
        //* missile.source, missile.owner are already set and don't need further changes.
        //* missile.data is already set to this AcidHydra instance, you can override it if required.
        private method onFire takes unit shooter, unit target, Missile missile returns nothing
            set missile.model      = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
            set missile.scale      = 1.
            set missile.damage     = GetRandomReal(50, 150)
            set missile.collision  = 32.
            set missile.collisionZ = 15.
            set missile.speed      = 27.
            //*  You have to launch the Missile here. It will tell library Missile, that it's
            //* a missile fired from excacly this struct.
            call thistype.launch(missile)
        endmethod
        
        //*  Another stub method, which runs each time a new head of type AcidHydra is created
        private method onSummonHead takes unit summoned returns nothing
            //*  call BJDebugMsg("summoned")
        endmethod
        
        //*  Here you can customize, which units can the AcidHydra target.
        //* Example: Just enemies structure type units are valid targets.
        private method onTargetFilter takes unit target, player owner returns boolean
            return IsUnitType(target, UNIT_TYPE_STRUCTURE) and IsUnitEnemy(target, owner) and UnitAlive(target)
        endmethod
        
    endstruct

    //*  Here you will learn how to create a AcidHydra instance.
    //* I choose a spell as example:
    private function OnCast takes nothing returns boolean
    
        //*  Declare a new Acidydra local.
        local AcidHydra hydra   
        local real x        = GetSpellTargetX()
        local real y        = GetSpellTargetY() 
        local real z        = 0.
        local real face     = GetRandomReal(0., 2*bj_PI)*bj_RADTODEG
        //*  This is the spawn interval between each heads.
        //* CreateHead - wait interval - CreatHead - wait interval - ...
        local real interval = .23

        if (GetSpellAbilityId() == 'xxxx') then
             
            //*  static method create takes unit whichUnit, integer unitid, real x, real y, z, real angle, spawnInterval returns Hydra
            set hydra                     = AcidHydra.create(GetTriggerUnit(), 'hfoo', x, y, z, face, interval)
            
            //*  Customize hydra members. 
            //* Each member has a default setting, which is done in static method create.
            //* You will recieve an error message, if you forget to setup a mandatory member.
            set hydra.heads               = 3     // By default 0.
            set hydra.attackAnimationTime = .5    // Read it in the object editor and divide it with 1/2. ( the second half is the backswing )
            set hydra.attackSpeed         = 3.    // By default 0.
            set hydra.attackPeriod        = .25   // By default 0.
            set hydra.duration            = 12    // By default 0.
            set hydra.attackRange         = 950.  // By default 0. 
            set hydra.headHeight          = 55.   // By default 0.
            set hydra.scale               = 1.    // By default 1.
            set hydra.hasArcOrCurve       = false // By default false
            set hydra.birthAnimationTime  = 0.    // By default 0.
            
            // *Summon it.
            call hydra.summon()
        endif
        return false
    endfunction
    
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        if UnitAddAbility(DemoMap_HERO, 'xxxx') then
            call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            call TriggerAddCondition(t, Condition(function OnCast))
        endif
    endfunction
    
endscope

