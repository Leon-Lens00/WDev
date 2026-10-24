globals
//globals from IsDestructableTree:
constant boolean LIBRARY_IsDestructableTree=true
constant integer IsDestructableTree__HARVESTER_UNIT_ID= 'hpea'
constant integer IsDestructableTree__HARVEST_ABILITY= 'Ahrl'
constant integer IsDestructableTree__HARVEST_ORDER_ID= 0xD0032
constant player IsDestructableTree__NEUTRAL_PLAYER= Player(PLAYER_NEUTRAL_PASSIVE)
unit IsDestructableTree__harvester= null
//endglobals from IsDestructableTree
//globals from RegisterPlayerUnitEvent:
constant boolean LIBRARY_RegisterPlayerUnitEvent=true
trigger array RegisterPlayerUnitEvent__t
//endglobals from RegisterPlayerUnitEvent
//globals from TimerUtils:
constant boolean LIBRARY_TimerUtils=true
        //How to tweak timer utils:
        // USE_HASH_TABLE = true  (new blue)
        //  * SAFEST
        //  * SLOWEST (though hash tables are kind of fast)
        //
        // USE_HASH_TABLE = false, USE_FLEXIBLE_OFFSET = true  (orange)
        //  * kinda safe (except there is a limit in the number of timers)
        //  * ALMOST FAST
        //
        // USE_HASH_TABLE = false, USE_FLEXIBLE_OFFSET = false (red)
        //  * THE FASTEST (though is only  faster than the previous method
        //                  after using the optimizer on the map)
        //  * THE LEAST SAFE ( you may have to tweak OFSSET manually for it to
        //                     work)
        //
constant boolean TimerUtils__USE_HASH_TABLE= true
constant boolean TimerUtils__USE_FLEXIBLE_OFFSET= false

constant integer TimerUtils__OFFSET= 0x100000
integer TimerUtils__VOFFSET= TimerUtils__OFFSET
              
        //Timers to preload at map init:
constant integer TimerUtils__QUANTITY= 256
        
        //Changing this  to something big will allow you to keep recycling
        // timers even when there are already AN INCREDIBLE AMOUNT of timers in
        // the stack. But it will make things far slower so that's probably a bad idea...
constant integer TimerUtils__ARRAY_SIZE= 8190

// processed:         integer array TimerUtils__data[TimerUtils__ARRAY_SIZE]
hashtable TimerUtils__ht
// processed:         timer array TimerUtils__tT[TimerUtils__ARRAY_SIZE]
integer TimerUtils__tN= 0
constant integer TimerUtils__HELD=0x28829022
        //use a totally random number here, the more improbable someone uses it, the better.
        
boolean TimerUtils__didinit= false
//endglobals from TimerUtils
//globals from WorldBounds:
constant boolean LIBRARY_WorldBounds=true
//endglobals from WorldBounds
//globals from Missile:
constant boolean LIBRARY_Missile=true
    
        
constant real Missile_TIMER_TIMEOUT= 1. / 32.
        
         
constant player Missile_NEUTRAL_PASSIVE= Player(15)
        
        
constant integer Missile_DUMMY_UNIT_ID= 'dumi'
    
        
constant real Missile_MAXIMUM_COLLISION_SIZE= 197.
        
        
constant integer Missile_COLLISION_TYPE_CIRCLE= 0
constant integer Missile_COLLISION_TYPE_RECTANGLE= 1
    
        
constant real Missile_COLLISION_ACCURACY_FACTOR= 1.
    
// Optional toogles:
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//      Set booleans listed below to "true" and the compiler will write 
//      the feature into your map. Otherwise this code is completly ignored.                                        
//          • Yay, I want that           --> "true"
//          • Naah that's useless for me --> "false"
        
        
constant boolean Missile_USE_COLLISION_Z_FILTER= true
        
        
constant boolean Missile_WRITE_DELAYED_MISSILE_RECYCLING= true
        
        
constant real Missile__DELAYED_MISSILE_DEATH_ANIMATION_TIME= 2.

        
constant boolean Missile_USE_DESTRUCTABLE_FILTER= true
constant boolean Missile_USE_ITEM_FILTER= true
        // Core constant handle variables of Missile.
constant trigger Missile__CORE= CreateTrigger()
constant trigger Missile__MOVE= CreateTrigger()
constant timer Missile__TMR= CreateTimer()
constant location Missile__LOC= Location(0., 0.)
constant rect Missile__RECT= Rect(0., 0., 0., 0.)
constant group Missile__GROUP= CreateGroup()
constant hashtable Missile__HASH= InitHashtable()
        // For starting and stopping the timer.
integer Missile__active= 0
        // Arrays for data structure.
integer array Missile__instances
integer array Missile__missileList
boolexpr array Missile__expression
triggercondition array Missile__condition
integer array Missile__remove
boolean array Missile__destroying
boolean array Missile__recycling
integer array Missile__nextNode
integer array Missile__prevNode
        // Internal widget filter functions.
boolexpr Missile__destFilter
boolexpr Missile__itemFilter
boolexpr Missile__unitFilter
//endglobals from Missile
//globals from SpellEffectEvent:
constant boolean LIBRARY_SpellEffectEvent=true
//endglobals from SpellEffectEvent
    // User-defined
unit array udg_CF_Caster
integer udg_CF_MaxIndex= 0
integer array udg_CF_Level
integer udg_CF_Ability= 0
unit array udg_CF_Target
real udg_CF_Gap= 0
integer array udg_CF_Waves
integer array udg_CF_Loop
string udg_CF_CEff
integer udg_CF_MaxEff= 0
string udg_CF_LineEff
real array udg_CF_Damage
attacktype udg_CF_Attacktype= null
damagetype udg_CF_Damagetype= null
integer udg_CF_CurrentIndex= 0
real array udg_CF_PeriodicDamage
string udg_CF_BurnAttach
string udg_CF_BurnEff
string udg_CF_HitEff
string udg_CF_HitAttach
player udg_CF_Neutral= null

    // Generated
sound gg_snd_RainOfFireLoop1= null
trigger gg_trg_Missile= null
trigger gg_trg_TimerUtils= null
trigger gg_trg_SpellEffectEvent= null
trigger gg_trg_RegisterPlayerUnitEvent= null
trigger gg_trg_WorldBounds= null
trigger gg_trg_IsDestructableTree= null
trigger gg_trg_Armageddon= null
trigger gg_trg_This_Map_only= null
constant integer Armageddon__ARMAGEDDON_ABILITY= 'A001'
        
        // Damage options.
constant attacktype Armageddon__ATTACK_TYPE= ATTACK_TYPE_NORMAL
constant damagetype Armageddon__DAMAGE_TYPE= DAMAGE_TYPE_FIRE
        
        // Missile constants.
constant real Armageddon__METEOR_START_HEIGHT= 1300.
        
        // Effect options.
                                // EVENT_PLAYER_UNIT_SPELL_EFFECT.
constant string Armageddon__ON_EFFECT_EVENT_FX= "Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosTarget.mdl"
constant string Armageddon__ON_CASTER_FX= "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl"
constant string Armageddon__CASTER_FX_ATTACH_POINT= "origin"
constant string Armageddon__ON_DAMAGE_UNIT_FX= "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
constant string Armageddon__DAMAGE_FX_ATTACH_POINT= "chest"
        
        // Spell concept.
                                 // EVENT_PLAYER_UNIT_ISSUED_ORDER or EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER.
constant boolean Armageddon__IS_IMMEDIATE_ORDER= true
constant boolean Armageddon__IMPACT_DAMAGES_TREES= true
constant boolean Armageddon__DAMAGE_FLYING_UNITS= true
real map__X= - 1500
real map__Y= - 2280
real map__X0= 1177
real map__Y0= 1370
unit map__HERO

trigger l__library_init

//JASSHelper struct globals:
constant integer si__IsDestructableTree__I=1
constant integer si__WorldBounds=2
integer s__WorldBounds_maxX
integer s__WorldBounds_maxY
integer s__WorldBounds_minX
integer s__WorldBounds_minY
integer s__WorldBounds_centerX
integer s__WorldBounds_centerY
rect s__WorldBounds_world
region s__WorldBounds_worldRegion
constant integer si__Missile__RecycleBin=3
constant timer s__Missile__RecycleBin_t= CreateTimer()
integer s__Missile__RecycleBin_max= 0
unit array s__Missile__RecycleBin_dummy
real array s__Missile__RecycleBin_time
constant integer si__MissilePosition=4
integer array s__MissilePosition_recycler
integer s__MissilePosition_alloc= 0
real array s__MissilePosition_x
real array s__MissilePosition_y
real array s__MissilePosition_z
real array s__MissilePosition_angle
real array s__MissilePosition_distance
real array s__MissilePosition_square
real array s__MissilePosition_slope
real array s__MissilePosition_alpha
integer array s__MissilePosition_ref
constant integer si__Missile=5
integer s__Missile_Missile__MissileStructure__collectionCount= 0
integer s__Missile_Missile__MissileStructure__nodeCount= 0
integer array s__Missile_Missile__MissileStructure___list
integer array s__Missile_Missile__MissileStructure___next
integer array s__Missile_Missile__MissileStructure___prev
integer array s__Missile_Missile__MissileStructure___first
integer array s__Missile_Missile__MissileStructure___last
constant string s__Missile_ORIGIN= "origin"
constant real s__Missile_HIT_BOX= ( 2. / 3. )
boolean array s__Missile_launched
real array s__Missile_posX
real array s__Missile_posY
real array s__Missile_dist
boolean array s__Missile_allocated
unit array s__Missile_dummy
integer array s__Missile_origin
integer array s__Missile_impact
real array s__Missile_terrainZ
real array s__Missile_x
real array s__Missile_y
real array s__Missile_z
real array s__Missile_angle
real array s__Missile_prevX
real array s__Missile_prevY
real array s__Missile_prevZ
integer array s__Missile_collisionType
unit array s__Missile_source
unit array s__Missile_target
real array s__Missile_distance
player array s__Missile_owner
real array s__Missile_speed
real array s__Missile_acceleration
real array s__Missile_damage
integer array s__Missile_data
boolean array s__Missile_recycle
real array s__Missile_turn
real array s__Missile_collision
effect array s__Missile_sfx
string array s__Missile_path
real array s__Missile_open
real array s__Missile_height
real array s__Missile_scaling
boolean array s__Missile_wantDestroy
integer s__Missile_temp= 0
integer array s__Missile_stackSize
boolean s__Missile_circle= true
constant integer si__SpellEffectEvent__S=6
hashtable s__SpellEffectEvent__S_ht= InitHashtable()
constant integer si__Armageddon__Meteor=7
constant integer si__Armageddon__Armageddon=8
integer si__Armageddon__Armageddon_F=0
integer si__Armageddon__Armageddon_I=0
integer array si__Armageddon__Armageddon_V
unit array s__Armageddon__Armageddon_source
player array s__Armageddon__Armageddon_user
timer array s__Armageddon__Armageddon_clock
effect array s__Armageddon__Armageddon_fx
sound array s__Armageddon__Armageddon_snd
real array s__Armageddon__Armageddon_centerX
real array s__Armageddon__Armageddon_centerY
real array s__Armageddon__Armageddon_size
real array s__Armageddon__Armageddon_time
real array s__Armageddon__Armageddon_interval
integer array s__Armageddon__Armageddon_count
integer array s__Armageddon__Armageddon_order
integer array s__Armageddon__Armageddon_level
boolean array s__Armageddon__Armageddon_move
boolean array s__Armageddon__Armageddon_channel
constant integer si__map__preload=9
constant integer si__map__xxx=10
integer array s__TimerUtils__data
timer array s__TimerUtils__tT
trigger array st___prototype2

endglobals
    native UnitAlive takes unit id returns boolean


//Generated allocator of Armageddon__Armageddon
function s__Armageddon__Armageddon__allocate takes nothing returns integer
 local integer this=si__Armageddon__Armageddon_F
    if (this!=0) then
        set si__Armageddon__Armageddon_F=si__Armageddon__Armageddon_V[this]
    else
        set si__Armageddon__Armageddon_I=si__Armageddon__Armageddon_I+1
        set this=si__Armageddon__Armageddon_I
    endif
    if (this>8190) then
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,1000.,"Unable to allocate id for an object of type: Armageddon__Armageddon")
        return 0
    endif

    set si__Armageddon__Armageddon_V[this]=-1
 return this
endfunction

//Generated destructor of Armageddon__Armageddon
function s__Armageddon__Armageddon_deallocate takes integer this returns nothing
    if this==null then
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,1000.,"Attempt to destroy a null struct of type: Armageddon__Armageddon")
        return
    elseif (si__Armageddon__Armageddon_V[this]!=-1) then
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,1000.,"Double free of type: Armageddon__Armageddon")
        return
    endif
    set si__Armageddon__Armageddon_V[this]=si__Armageddon__Armageddon_F
    set si__Armageddon__Armageddon_F=this
endfunction
function sc___prototype2_execute takes integer i returns nothing

    call TriggerExecute(st___prototype2[i])
endfunction
function sc___prototype2_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype2[i])

endfunction

//library IsDestructableTree:
    function IsDestructableTree takes destructable d returns boolean
        //*  851973 is the order id for stunned, it will interrupt the preceding harvest order.
        return ( IssueTargetOrderById(IsDestructableTree__harvester, IsDestructableTree__HARVEST_ORDER_ID, d) ) and ( IssueImmediateOrderById(IsDestructableTree__harvester, 851973) )
    endfunction
    function IsDestructableDead takes destructable d returns boolean
        return ( GetWidgetLife(d) <= 0.405 )
    endfunction
    function IsDestructableAlive takes destructable d returns boolean
        return ( GetWidgetLife(d) > .405 )
    endfunction
    function IsTreeAlive takes destructable tree returns boolean
        return IsDestructableAlive(tree) and IsDestructableTree(tree)
    endfunction
    function KillTree takes destructable tree returns boolean
        if ( IsTreeAlive(tree) ) then
            call KillDestructable(tree)
            return true
        endif
        return false
    endfunction
    function IsDestructableTree__Init takes nothing returns nothing
//#         static if LIBRARY_UnitIndexer then//*  You may adapt this to your own indexer.
//#             set UnitIndexer.enabled = false
//#         endif
        set IsDestructableTree__harvester=CreateUnit(IsDestructableTree__NEUTRAL_PLAYER, IsDestructableTree__HARVESTER_UNIT_ID, 0, 0, 0)
//#         static if LIBRARY_UnitIndexer then
//#             set UnitIndexer.enabled = true
//#         endif
        call UnitAddAbility(IsDestructableTree__harvester, IsDestructableTree__HARVEST_ABILITY)
        call UnitAddAbility(IsDestructableTree__harvester, 'Aloc')
        call ShowUnit(IsDestructableTree__harvester, false)
    endfunction
    //*  Seriously?
//Implemented from module IsDestructableTree__Inits:
        function s__IsDestructableTree__I_IsDestructableTree__Inits__onInit takes nothing returns nothing
            call IsDestructableTree__Init()
        endfunction
    

//library IsDestructableTree ends
//library RegisterPlayerUnitEvent:
   
    function RegisterPlayerUnitEvent takes playerunitevent p,code c returns nothing
        local integer i= GetHandleId(p)
        local integer k= 15
        if RegisterPlayerUnitEvent__t[i] == null then
            set RegisterPlayerUnitEvent__t[i]=CreateTrigger()
            loop
                call TriggerRegisterPlayerUnitEvent(RegisterPlayerUnitEvent__t[i], Player(k), p, null)
                exitwhen k == 0
                set k=k - 1
            endloop
        endif
        call TriggerAddCondition(RegisterPlayerUnitEvent__t[i], Filter(c))
    endfunction
   
    function RegisterPlayerUnitEventForPlayer takes playerunitevent p,code c,player pl returns nothing
        local integer i= 16 * GetHandleId(p) + GetPlayerId(pl)
        if RegisterPlayerUnitEvent__t[i] == null then
            set RegisterPlayerUnitEvent__t[i]=CreateTrigger()
            call TriggerRegisterPlayerUnitEvent(RegisterPlayerUnitEvent__t[i], pl, p, null)
        endif
        call TriggerAddCondition(RegisterPlayerUnitEvent__t[i], Filter(c))
    endfunction
   
    function GetPlayerUnitEventTrigger takes playerunitevent p returns trigger
        return RegisterPlayerUnitEvent__t[GetHandleId(p)]
    endfunction

//library RegisterPlayerUnitEvent ends
//library TimerUtils:
//*********************************************************************
//* TimerUtils (red+blue+orange flavors for 1.24b+) 2.0
//* ----------
//*
//*  To implement it , create a custom text trigger called TimerUtils
//* and paste the contents of this script there.
//*
//*  To copy from a map to another, copy the trigger holding this
//* library to your map.
//*
//* (requires vJass)   More scripts: htt://www.wc3c.net
//*
//* For your timer needs:
//*  * Attaching
//*  * Recycling (with double-free protection)
//*
//* set t=NewTimer()      : Get a timer (alternative to CreateTimer)
//* set t=NewTimerEx(x)   : Get a timer (alternative to CreateTimer), call
//*                            Initialize timer data as x, instead of 0.
//*
//* ReleaseTimer(t)       : Relese a timer (alt to DestroyTimer)
//* SetTimerData(t,2)     : Attach value 2 to timer
//* GetTimerData(t)       : Get the timer's value.
//*                         You can assume a timer's value is 0
//*                         after NewTimer.
//*
//* Multi-flavor:
//*    Set USE_HASH_TABLE to true if you don't want to complicate your life.
//*
//* If you like speed and giberish try learning about the other flavors.
//*
//********************************************************************

//================================================================

    //==================================================================================================
    
    

    //It is dependent on jasshelper's recent inlining optimization in order to perform correctly.
    function SetTimerData takes timer t,integer value returns nothing
//#         static if TimerUtils__USE_HASH_TABLE  then
                // new blue
                call SaveInteger(TimerUtils__ht, 0, GetHandleId(t), value)
                
//#         elseif (TimerUtils__USE_FLEXIBLE_OFFSET) then
//#             // orange
//#             static if  true  then
//#                 if(GetHandleId(t)-TimerUtils__VOFFSET<0) then
//#                     call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
//#                 endif
//#             endif
//#             set TimerUtils__data[GetHandleId(t)-TimerUtils__VOFFSET]=value
//#         else
//#             // new red
//#             static if  true  then
//#                 if(GetHandleId(t)-TimerUtils__OFFSET<0) then
//#                     call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
//#                 endif
//#             endif
//#             set TimerUtils__data[GetHandleId(t)-TimerUtils__OFFSET]=value
//#         endif        
    endfunction

    function GetTimerData takes timer t returns integer
//#         static if TimerUtils__USE_HASH_TABLE  then
                // new blue
                return LoadInteger(TimerUtils__ht, 0, GetHandleId(t))
                
//#         elseif (TimerUtils__USE_FLEXIBLE_OFFSET) then
//#             // orange
//#             static if  true  then
//#                 if(GetHandleId(t)-TimerUtils__VOFFSET<0) then
//#                     call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
//#                 endif
//#             endif
//#             return TimerUtils__data[GetHandleId(t)-TimerUtils__VOFFSET]
//#         else
//#             // new red
//#             static if  true  then
//#                 if(GetHandleId(t)-TimerUtils__OFFSET<0) then
//#                     call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
//#                 endif
//#             endif
//#             return TimerUtils__data[GetHandleId(t)-TimerUtils__OFFSET]
//#         endif        
    endfunction

    //==========================================================================================

    //==========================================================================================
    // I needed to decide between duplicating code ignoring the "Once and only once" rule
    // and using the ugly textmacros. I guess textmacros won.
    //

    function NewTimerEx takes integer value returns timer
        if ( TimerUtils__tN == 0 ) then
            if ( not TimerUtils__didinit ) then
                //This extra if shouldn't represent a major performance drawback
                //because QUANTITY rule is not supposed to be broken every day. 
                call sc___prototype2_evaluate(1)
                set TimerUtils__tN=TimerUtils__tN - 1
            else
                //If this happens then the QUANTITY rule has already been broken, try to fix the
                // issue, else fail.
                 call BJDebugMsg("NewTimer: Warning, Exceeding TimerUtils_QUANTITY, make sure all timers are getting recycled correctly")
                set s__TimerUtils__tT[0]= CreateTimer()
//#                 static if  not TimerUtils__USE_HASH_TABLE  then
//#                      call BJDebugMsg("In case of errors, please increase it accordingly, or set TimerUtils_USE_HASH_TABLE to true")
//#                     static if  TimerUtils__USE_FLEXIBLE_OFFSET  then
//#                         if (GetHandleId(TimerUtils__tT[0])-TimerUtils__VOFFSET<0) or (GetHandleId(TimerUtils__tT[0])-TimerUtils__VOFFSET>=TimerUtils__ARRAY_SIZE) then
//#                             //all right, couldn't fix it
//#                             call BJDebugMsg("NewTimer: Unable to allocate a timer, you should probably set TimerUtils_USE_HASH_TABLE to true or fix timer leaks.")
//#                             return null
//#                         endif
//#                     else
//#                         if (GetHandleId(TimerUtils__tT[0])-TimerUtils__OFFSET<0) or (GetHandleId(TimerUtils__tT[0])-TimerUtils__OFFSET>=TimerUtils__ARRAY_SIZE) then
//#                             //all right, couldn't fix it
//#                             call BJDebugMsg("NewTimer: Unable to allocate a timer, you should probably set TimerUtils_USE_HASH_TABLE to true or fix timer leaks.")
//#                             return null
//#                         endif
//#                     endif
//#                 endif
            endif
        else
            set TimerUtils__tN=TimerUtils__tN - 1
        endif
        call SetTimerData(s__TimerUtils__tT[TimerUtils__tN] , value)
     return s__TimerUtils__tT[TimerUtils__tN]
    endfunction
    
    function NewTimer takes nothing returns timer
        return NewTimerEx(0)
    endfunction


    //==========================================================================================
    function ReleaseTimer takes timer t returns nothing
        if ( t == null ) then
             call BJDebugMsg("Warning: attempt to release a null timer")
            return
        endif
        if ( TimerUtils__tN == TimerUtils__ARRAY_SIZE ) then
             call BJDebugMsg("Warning: Timer stack is full, destroying timer!!")

            //stack is full, the map already has much more troubles than the chance of bug
            call DestroyTimer(t)
        else
            call PauseTimer(t)
            if ( GetTimerData(t) == TimerUtils__HELD ) then
                 call BJDebugMsg("Warning: ReleaseTimer: Double free!")
                return
            endif
            call SetTimerData(t , TimerUtils__HELD)
            set s__TimerUtils__tT[TimerUtils__tN]= t
            set TimerUtils__tN=TimerUtils__tN + 1
        endif
    endfunction

    function TimerUtils__init takes nothing returns nothing
     local integer i=0
     local integer o=- 1
     local boolean oops= false
        if ( TimerUtils__didinit ) then
            return
        else
            set TimerUtils__didinit=true
        endif
     
//#         static if  TimerUtils__USE_HASH_TABLE   then
                set TimerUtils__ht=InitHashtable()
                loop
                    exitwhen ( i == TimerUtils__QUANTITY )
                    set s__TimerUtils__tT[i]= CreateTimer()
                    call SetTimerData(s__TimerUtils__tT[i] , TimerUtils__HELD)
                    set i=i + 1
                endloop
                set TimerUtils__tN=TimerUtils__QUANTITY
//#         else
//#             loop
//#                 set i=0
//#                 loop
//#                     exitwhen (i==TimerUtils__QUANTITY)
//#                     set TimerUtils__tT[i] = CreateTimer()
//#                     if(i==0) then
//#                         set TimerUtils__VOFFSET = GetHandleId(TimerUtils__tT[i])
//#                         static if TimerUtils__USE_FLEXIBLE_OFFSET  then
//#                             set o=TimerUtils__VOFFSET
//#                         else
//#                             set o=TimerUtils__OFFSET
//#                         endif
//#                     endif
//#                     if (GetHandleId(TimerUtils__tT[i])-o>=TimerUtils__ARRAY_SIZE) then
//#                         exitwhen true
//#                     endif
//#                     if (GetHandleId(TimerUtils__tT[i])-o>=0)  then
//#                         set i=i+1
//#                     endif
//#                 endloop
//#                 set TimerUtils__tN = i
//#                 exitwhen(TimerUtils__tN == TimerUtils__QUANTITY)
//#                 set oops = true
//#                 exitwhen not TimerUtils__USE_FLEXIBLE_OFFSET
//#                  call BJDebugMsg("TimerUtils_init: Failed a initialization attempt, will try again")               
//#             endloop
//#             
//#             if(oops) then
//#                 static if   TimerUtils__USE_FLEXIBLE_OFFSET  then
//#                      call BJDebugMsg("The problem has been fixed.")
//#                     //If this message doesn't appear then there is so much
//#                     //handle id fragmentation that it was impossible to preload
//#                     //so many timers and the thread crashed! Therefore this
//#                     //debug message is useful.
//#                 elseif true  then
//#                     call BJDebugMsg("There were problems and the new timer limit is "+I2S(i))
//#                     call BJDebugMsg("This is a rare ocurrence, if the timer limit is too low:")
//#                     call BJDebugMsg("a) Change USE_FLEXIBLE_OFFSET to true (reduces performance a little)")
//#                     call BJDebugMsg("b) or try changing OFFSET to "+I2S(TimerUtils__VOFFSET) )
//#                 endif
//#             endif
//#         endif

    endfunction


//library TimerUtils ends
//library WorldBounds:
	
		
		
		
		
//Implemented from module WorldBounds__WorldBoundInit:
  function s__WorldBounds_WorldBounds__WorldBoundInit__onInit takes nothing returns nothing
			set s__WorldBounds_world=GetWorldBounds()
			
			set s__WorldBounds_maxX=R2I(GetRectMaxX(s__WorldBounds_world))
			set s__WorldBounds_maxY=R2I(GetRectMaxY(s__WorldBounds_world))
			set s__WorldBounds_minX=R2I(GetRectMinX(s__WorldBounds_world))
			set s__WorldBounds_minY=R2I(GetRectMinY(s__WorldBounds_world))
			
			set s__WorldBounds_centerX=R2I(( s__WorldBounds_maxX + s__WorldBounds_minX ) / 2)
			set s__WorldBounds_centerY=R2I(( s__WorldBounds_minY + s__WorldBounds_maxY ) / 2)
			
			set s__WorldBounds_worldRegion=CreateRegion()
			
			call RegionAddRect(s__WorldBounds_worldRegion, s__WorldBounds_world)
  endfunction

//library WorldBounds ends
//library Missile:

    
    function GetUnitBodySize takes unit whichUnit returns real
        return 100. // Other example: return LoadReal(hash, GetHandleId(whichUnit), KEY_UNIT_BODY_SIZE)
    endfunction

    
    function GetDestructableHeight takes destructable d returns real
        return GetDestructableOccluderHeight(d) // Other example: return 100.
    endfunction

    
    function GetItemHeight takes item i returns real
        return 16.
    endfunction
    
    
    function Missile__ToogleUnitIndexer takes boolean enable returns boolean
        local boolean prev= true
        // set UnitIndexer.enabled = enable
        return prev
    endfunction
    


// Hello and welcome to Missile.
// I wrote a guideline for every piece of code inside Missile, so you 
// can easily understand how the it gets compiled and evaluated.
//
// Let's go!
        
    
    function Missile_GetLocZ takes real x,real y returns real
        call MoveLocation(Missile__LOC, x, y)
        return GetLocationZ(Missile__LOC)
    endfunction
    
    // For WRITE_DELAYED_MISSILE_RECYCLING = true Missile will hold back
    // dummies for DELAYED_MISSILE_DEATH_ANIMATION_TIME before they are recylced. ( Code placed in a static if )
    //
//textmacro instance: WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")
//#     static if Missile_WRITE_DELAYED_MISSILE_RECYCLING then
    
         
                function s__Missile__RecycleBin_onPeriodic takes nothing returns nothing
                    local integer dex= 0
                    loop
                        exitwhen dex == s__Missile__RecycleBin_max
                        set s__Missile__RecycleBin_time[dex]=s__Missile__RecycleBin_time[dex] - 1
                        if 0 >= s__Missile__RecycleBin_time[dex] then
                        
//#                         static if LIBRARY_MissileRecycler then
//#                             call RecycleMissile(Missile__RecycleBin.dummy[dex])
//#                     
//#                         elseif Dummy.create.exists and LIBRARY_Dummy then
//#                             call Dummy[Missile__RecycleBin.dummy[dex]].destroy()
//#                         
//#                         elseif LIBRARY_xedummy and xedummy.release.exists then
//#                             call xedummy.release(Missile__RecycleBin.dummy[dex])
//#                     
//#                         else
                                call RemoveUnit(s__Missile__RecycleBin_dummy[dex])
//#                         endif
                        
                            set s__Missile__RecycleBin_dummy[dex]=null
                            set s__Missile__RecycleBin_max=s__Missile__RecycleBin_max - 1
                            set s__Missile__RecycleBin_dummy[dex]=s__Missile__RecycleBin_dummy[s__Missile__RecycleBin_max]
                            set s__Missile__RecycleBin_time[dex]=s__Missile__RecycleBin_time[s__Missile__RecycleBin_max]
                            set s__Missile__RecycleBin_dummy[s__Missile__RecycleBin_max]=null
                            set dex=dex - 1
                        
                            if 0 == s__Missile__RecycleBin_max then
                                call PauseTimer(s__Missile__RecycleBin_t)
                            endif
                        
                        endif
                        set dex=dex + 1
                    endloop
                endfunction
        
                function s__Missile__RecycleBin_recycle takes unit toRecycle returns nothing
                    if 0 == s__Missile__RecycleBin_max then
                        call TimerStart(s__Missile__RecycleBin_t, 1., true, function s__Missile__RecycleBin_onPeriodic)
                    endif
                    set s__Missile__RecycleBin_dummy[s__Missile__RecycleBin_max]=toRecycle
                    set s__Missile__RecycleBin_time[s__Missile__RecycleBin_max]=Missile__DELAYED_MISSILE_DEATH_ANIMATION_TIME + TimerGetRemaining(s__Missile__RecycleBin_t)
                    set s__Missile__RecycleBin_max=s__Missile__RecycleBin_max + 1
                endfunction
        
//#     endif
//end of: WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")
    
    // The code of WRITE_MISSILE_POSITION_CODE boxes a missiles position and does the required trigonometry.
    //
//textmacro instance: WRITE_MISSILE_POSITION_CODE()
            
            // Readonly members you can access.
            
            // Creates an origin - impact link.
            
            function s__MissilePosition_math takes integer a,integer b returns nothing
                local real dx
                local real dy
                loop
                    set dx=s__MissilePosition_x[b] - s__MissilePosition_x[a]
                    set dy=s__MissilePosition_y[b] - s__MissilePosition_y[a]
                    set dx=dx * dx + dy * dy
                    set dy=SquareRoot(dx)
                    exitwhen dx != 0. and dy != 0.
                    set s__MissilePosition_x[b]=s__MissilePosition_x[b] + .01
                    set s__MissilePosition_z[b]=s__MissilePosition_z[b] - Missile_GetLocZ(s__MissilePosition_x[b] - .01 , s__MissilePosition_y[b]) + Missile_GetLocZ(s__MissilePosition_x[b] , s__MissilePosition_y[b])
                endloop
                
                set s__MissilePosition_square[a]=dx
                set s__MissilePosition_distance[a]=dy
                set s__MissilePosition_angle[a]=Atan2(s__MissilePosition_y[b] - s__MissilePosition_y[a], s__MissilePosition_x[b] - s__MissilePosition_x[a])
                set s__MissilePosition_slope[a]=( s__MissilePosition_z[b] - s__MissilePosition_z[a] ) / dy
                set s__MissilePosition_alpha[a]=Atan(s__MissilePosition_slope[a]) * bj_RADTODEG
                // Set b.
                if s__MissilePosition_ref[b] == a then
                    set s__MissilePosition_angle[b]=s__MissilePosition_angle[a] + bj_PI
                    set s__MissilePosition_distance[b]=dy
                    set s__MissilePosition_slope[b]=- s__MissilePosition_slope[a]
                    set s__MissilePosition_alpha[b]=- s__MissilePosition_alpha[a]
                    set s__MissilePosition_square[b]=dx
                endif
            endfunction
            
            function s__MissilePosition_link takes integer a,integer b returns nothing
                set s__MissilePosition_ref[a]=b
                set s__MissilePosition_ref[b]=a
                call s__MissilePosition_math(a , b)
            endfunction
    
            function s__MissilePosition_move takes integer this,real toX,real toY,real toZ returns nothing
                set s__MissilePosition_x[this]=toX
                set s__MissilePosition_y[this]=toY
                set s__MissilePosition_z[this]=toZ + Missile_GetLocZ(toX , toY)
                if s__MissilePosition_ref[this] != this then
                    call s__MissilePosition_math(this , s__MissilePosition_ref[this])
                endif
            endfunction
    
            function s__MissilePosition_destroy takes integer this returns nothing
                set s__MissilePosition_recycler[this]=s__MissilePosition_recycler[0]
                set s__MissilePosition_recycler[0]=this
            endfunction
    
            function s__MissilePosition_create takes real x,real y,real z returns integer
                local integer this= s__MissilePosition_recycler[0]
                 if 0 == this then
                    set s__MissilePosition_alloc=s__MissilePosition_alloc + 1
                    set this=s__MissilePosition_alloc
                else
                    set s__MissilePosition_recycler[0]=s__MissilePosition_recycler[this]
                endif
                set s__MissilePosition_ref[this]=this
                call s__MissilePosition_move(this,x , y , z)
                return this
            endfunction
    
//end of: WRITE_MISSILE_POSITION_CODE()
    
    // Missiles structure works like a linked list with the folling methods:
    // allocateCollection(), allocateNode(), insertFront(node) and remove()
    //
//Implemented from module Missile__MissileStructure:
        
//#         static if LIBRARY_ErrorMessage then
//#              private boolean Missile__MissileStructure__isNode
//#              private boolean Missile__MissileStructure__isCollection
//#         endif
        
        function s__Missile__get_list takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,    "MissileStructure", "list", "Missile", this, "Attempted To Read Null Node.")
//#                  call ThrowError(not Missile__MissileStructure__isNode,   "MissileStructure", "list", "Missile", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile__MissileStructure___list[this]
        endfunction
        
        function s__Missile__get_next takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,    "MissileStructure", "next", "Missile", this, "Attempted To Go Out Of Bounds.")
//#                  call ThrowError(not Missile__MissileStructure__isNode,   "MissileStructure", "next", "Missile", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile__MissileStructure___next[this]
        endfunction
        
        function s__Missile__get_prev takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,    "MissileStructure", "prev", "Missile", this, "Attempted To Go Out Of Bounds.")
//#                  call ThrowError(not Missile__MissileStructure__isNode,   "MissileStructure", "prev", "Missile", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile__MissileStructure___prev[this]
        endfunction
        
        function s__Missile__get_first takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,        "MissileStructure", "first", "Missile", this, "Attempted To Read Null List.")
//#                  call ThrowError(not Missile__MissileStructure__isCollection, "MissileStructure", "first", "Missile", this, "Attempted To Read Invalid List.")
//#             endif
            return s__Missile_Missile__MissileStructure___first[this]
        endfunction
        
        function s__Missile__get_last takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,        "MissileStructure", "last", "Missile", this, "Attempted To Read Null List.")
//#                  call ThrowError(not Missile__MissileStructure__isCollection, "MissileStructure", "last", "Missile", this, "Attempted To Read Invalid List.")
//#             endif
            return s__Missile_Missile__MissileStructure___last[this]
        endfunction
        
        function s__Missile_allocateCollection takes nothing returns integer
            local integer this= s__Missile_Missile__MissileStructure___first[(0)]
            
            if ( 0 == this ) then
//#                 static if LIBRARY_ErrorMessage then
//#                      call ThrowError(Missile__MissileStructure__collectionCount == 8191, "MissileStructure", "allocateCollection", "Missile", 0, "Overflow.")
//#                 endif
                
                set this=s__Missile_Missile__MissileStructure__collectionCount + 1
                set s__Missile_Missile__MissileStructure__collectionCount=this
            else
                set s__Missile_Missile__MissileStructure___first[(0)]=s__Missile_Missile__MissileStructure___first[this]
            endif
            
//#             static if LIBRARY_ErrorMessage then
//#                  set Missile__MissileStructure__isCollection = true
//#             endif
            
            set s__Missile_Missile__MissileStructure___first[this]=0
            
            return this
        endfunction
        
        function s__Missile_allocateNode takes nothing returns integer
            local integer this= s__Missile_Missile__MissileStructure___next[(0)]
            
            if ( 0 == this ) then
//#                 static if LIBRARY_ErrorMessage then
//#                      call ThrowError(Missile__MissileStructure__nodeCount == 8191, "MissileStructure", "allocateNode", "Missile", 0, "Overflow.")
//#                 endif
                
                set this=s__Missile_Missile__MissileStructure__nodeCount + 1
                set s__Missile_Missile__MissileStructure__nodeCount=this
            else
                set s__Missile_Missile__MissileStructure___next[(0)]=s__Missile_Missile__MissileStructure___next[this]
            endif
            
            set s__Missile_allocated[this]=true
            
            return this
        endfunction
        
        function s__Missile_insertFront takes integer this,integer node returns integer
            
            // Extra static unique list for missile motion.
            set Missile__nextNode[node]=0
            set Missile__prevNode[node]=Missile__prevNode[0]
            set Missile__nextNode[Missile__prevNode[0]]=node
            set Missile__prevNode[0]=node
            
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,        "List", "push", "Missile", this, "Attempted To Push On To Null List.")
//#                  call ThrowError(not Missile__MissileStructure__isCollection, "List", "push", "Missile", this, "Attempted To Push On To Invalid List.")
//#                  set node.Missile__MissileStructure__isNode = true
//#             endif
            
            set s__Missile_Missile__MissileStructure___list[node]=this
        
            if ( s__Missile_Missile__MissileStructure___first[this] == 0 ) then
                set s__Missile_Missile__MissileStructure___first[this]=node
                set s__Missile_Missile__MissileStructure___last[this]=node
                set s__Missile_Missile__MissileStructure___next[node]=0
            else
                set s__Missile_Missile__MissileStructure___prev[s__Missile_Missile__MissileStructure___first[this]]=node
                set s__Missile_Missile__MissileStructure___next[node]=s__Missile_Missile__MissileStructure___first[this]
                set s__Missile_Missile__MissileStructure___first[this]=node
            endif
            
            set s__Missile_Missile__MissileStructure___prev[node]=0
            
            return node
        endfunction
      
        function s__Missile_Missile__remove takes integer this returns nothing
            local integer node= this
            set this=s__Missile_Missile__MissileStructure___list[node]
            
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(node == 0,        "MissileStructure", "remove", "Missile", this, "Attempted To Remove Null Node.")
//#                  call ThrowError(not node.Missile__MissileStructure__isNode,  "MissileStructure", "remove", "Missile", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
//#                  set node.Missile__MissileStructure__isNode = false
//#             endif
            
            set s__Missile_Missile__MissileStructure___list[node]=0
        
            if ( 0 == s__Missile_Missile__MissileStructure___prev[node] ) then
                set s__Missile_Missile__MissileStructure___first[this]=s__Missile_Missile__MissileStructure___next[node]
            else
                set s__Missile_Missile__MissileStructure___next[s__Missile_Missile__MissileStructure___prev[node]]=s__Missile_Missile__MissileStructure___next[node]
            endif
            if ( 0 == s__Missile_Missile__MissileStructure___next[node] ) then
                set s__Missile_Missile__MissileStructure___last[this]=s__Missile_Missile__MissileStructure___prev[node]
            else
                set s__Missile_Missile__MissileStructure___prev[s__Missile_Missile__MissileStructure___next[node]]=s__Missile_Missile__MissileStructure___prev[node]
            endif
            
            set s__Missile_Missile__MissileStructure___next[node]=s__Missile_Missile__MissileStructure___next[(0)]
            set s__Missile_Missile__MissileStructure___next[(0)]=node
            
            set s__Missile_allocated[node]=false
            
            // Static unique list for missile motion.
            set Missile__nextNode[Missile__prevNode[node]]=Missile__nextNode[node]
            set Missile__prevNode[Missile__nextNode[node]]=Missile__prevNode[node]
        endfunction

        // Constants:
        // ==========
        //
        // Attach point name for effects created by model=. 
        
        // Set a ficitional hit box in range of 0 to 1,
        // while 0 is the toe and 1 the head of a unit.
        
        // DEBUG_MODE only members:
        // ========================
        //
        // Checks for double launching. Throws an error message. 

        // Private members:
        // ================
        //        
        // The position of a missile using curve= does not
        // match the position used by Missile's trigonometry.
        // Therefore we need this member two times.
        // Readable x / y / z for your needs and posX / posY for cool mathematics.
        
        // Readonly members:
        // =================
        //
        // Prevents a double free case.
        
        // The dummy unit.
        
        // Position members for your needs.
        
        // Collision detection type. ( Evaluated new in each loop )
        
        // Members you can set:
        // ====================
        //

        // Setting collision z is deprecated since Missile v2.5. 
        function s__Missile__set_collisionZ takes integer this,real value returns nothing
        endfunction
        function s__Missile__get_collisionZ takes integer this returns real
            return s__Missile_collision[this]
        endfunction
        
        // Operator overloading:
        // =====================
        //
        // Special effect on the missile dummy. For multiple effect attaching, access unit "dummy" directly.
        function s__Missile__set_model takes integer this,string file returns nothing
            if s__Missile_sfx[this] != null then
                call DestroyEffect(s__Missile_sfx[this])
                set s__Missile_sfx[this]=null
            endif
                                    // null and ""
            if StringLength(file) > 0 then
                set s__Missile_sfx[this]=AddSpecialEffectTarget(file, s__Missile_dummy[this], s__Missile_ORIGIN)
                set s__Missile_path[this]=file
            else
                set s__Missile_path[this]=null
            endif
        endfunction
        function s__Missile__get_model takes integer this returns string
            return s__Missile_path[this]
        endfunction
       
       // Enables curved movement for your missile. 
       // Remember that the result of Tan(PI/2) is infinity.
        function s__Missile__set_curve takes integer this,real value returns nothing
            set s__Missile_open[this]=Tan(value) * s__MissilePosition_distance[s__Missile_origin[this]]
        endfunction
        function s__Missile__get_curve takes integer this returns real
            return Atan(s__Missile_open[this] / s__MissilePosition_distance[s__Missile_origin[this]])
        endfunction
       
        // Enables arcing movement for your missile.
        function s__Missile__set_arc takes integer this,real value returns nothing
            set s__Missile_height[this]=Tan(value) * s__MissilePosition_distance[s__Missile_origin[this]] / 4
        endfunction
        function s__Missile__get_arc takes integer this returns real
            return Atan(4 * s__Missile_height[this] / s__MissilePosition_distance[s__Missile_origin[this]])
        endfunction
       
        function s__Missile__set_scale takes integer this,real value returns nothing
            call SetUnitScale(s__Missile_dummy[this], value, 0., 0.)
            set s__Missile_scaling[this]=value
        endfunction
        function s__Missile__get_scale takes integer this returns real
            return s__Missile_scaling[this]
        endfunction
        
        // Methods:
        // ========
        //
        function s__Missile_bounce takes integer this returns nothing
            call s__MissilePosition_move(s__Missile_origin[this],s__Missile_x[this] , s__Missile_y[this] , s__Missile_z[this])
            set s__Missile_dist[this]=0.
        endfunction
       
        function s__Missile_deflect takes integer this,real tx,real ty returns nothing
            local real a= 2. * Atan2(ty - s__Missile_y[this], tx - s__Missile_x[this]) + bj_PI - s__Missile_angle[this]
            call s__MissilePosition_move(s__Missile_impact[this],s__Missile_x[this] + ( s__MissilePosition_distance[s__Missile_origin[this]] - s__Missile_dist[this] ) * Cos(a) , s__Missile_y[this] + ( s__MissilePosition_distance[s__Missile_origin[this]] - s__Missile_dist[this] ) * Sin(a) , s__MissilePosition_z[s__Missile_impact[this]])
            call s__Missile_bounce(this)
        endfunction
        
        function s__Missile_deflectEx takes integer this,real tx,real ty,real tz returns nothing
            call s__MissilePosition_move(s__Missile_impact[this],s__MissilePosition_x[s__Missile_impact[this]] , s__MissilePosition_y[s__Missile_impact[this]] , tz)
            call s__Missile_deflect(this,tx , ty)
        endfunction
    
        function s__Missile_flightTime2Speed takes integer this,real duration returns nothing
            set s__Missile_speed[this]=RMaxBJ(0.00000001, ( s__MissilePosition_distance[s__Missile_origin[this]] - s__Missile_dist[this] ) * Missile_TIMER_TIMEOUT / RMaxBJ(0.00000001, duration))
        endfunction
        
        function s__Missile_setMovementSpeed takes integer this,real value returns nothing
            set s__Missile_speed[this]=value * Missile_TIMER_TIMEOUT
        endfunction
    
        function s__Missile_destroy takes integer this returns nothing
            set s__Missile_wantDestroy[this]=true
        endfunction

        // Instantly destroys a missile.
        function s__Missile_terminate takes integer this returns nothing
            if s__Missile_allocated[this] then
                call s__Missile_Missile__remove(this)
                call s__MissilePosition_destroy(s__Missile_impact[this])
                call s__MissilePosition_destroy(s__Missile_origin[this])
            
                call DestroyEffect(s__Missile_sfx[this])
                call FlushChildHashtable(Missile__HASH, this)
                if GetUnitTypeId(s__Missile_dummy[this]) == Missile_DUMMY_UNIT_ID then
                    // MissileRecycler > Dummy > xe.
//#                     static if LIBRARY_MissileRecycler then
//#                         call RecycleMissile(dummy)
//#                     elseif LIBRARY_Dummy and Dummy.create.exists then
//#                         call Dummy[dummy].destroy()
//#                     elseif LIBRARY_xedummy and xedummy.release.exists then
//#                         call xedummy.release(dummy)
//#                     else
                            call RemoveUnit(s__Missile_dummy[this])
//#                     endif
                endif
                set s__Missile_sfx[this]=null
                set s__Missile_source[this]=null
                set s__Missile_target[this]=null
                set s__Missile_dummy[this]=null
                set s__Missile_owner[this]=null
            endif
        endfunction
        
        // Runs in createEx.
    
        // Launches a dummy of your choice.
        function s__Missile_createEx takes unit missileDummy,real impactX,real impactY,real impactZ returns integer
            local integer this= s__Missile_allocateNode()
            local real originX= GetUnitX(missileDummy)
            local real originY= GetUnitY(missileDummy)
            local real originZ= GetUnitFlyHeight(missileDummy)
            //
//textmacro instance: MISSILE_RESET_ALL_MEMBERS()
            set s__Missile_path[this]=null
            set s__Missile_speed[this]=0.
            set s__Missile_acceleration[this]=0.
            set s__Missile_distance[this]=0.
            set s__Missile_dist[this]=0
            set s__Missile_dist[this]=0.
            set s__Missile_height[this]=0.
            set s__Missile_turn[this]=0.
            set s__Missile_open[this]=0.
            set s__Missile_collision[this]=0.
            set s__Missile_collisionType[this]=0
            set s__Missile_stackSize[this]=0
            set s__Missile_scaling[this]=1.
            set s__Missile_wantDestroy[this]=false
            set s__Missile_recycle[this]=false
//end of: MISSILE_RESET_ALL_MEMBERS()
            //
            set s__Missile_origin[this]=s__MissilePosition_create(originX , originY , originZ)
            set s__Missile_impact[this]=s__MissilePosition_create(impactX , impactY , impactZ)
            call s__MissilePosition_link(s__Missile_origin[this] , s__Missile_impact[this])
                        
            set s__Missile_posX[this]=originX
            set s__Missile_posY[this]=originY
            set s__Missile_x[this]=originX
            set s__Missile_y[this]=originY
            set s__Missile_z[this]=originZ
            set s__Missile_angle[this]=s__MissilePosition_angle[s__Missile_origin[this]]
            set s__Missile_dummy[this]=missileDummy
            
            call SetUnitFlyHeight(missileDummy, originZ, 0.)
            call SaveUnitHandle(Missile__HASH, this, GetHandleId(missileDummy), missileDummy)
            //
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowWarning(GetUnitTypeId(missileDummy) == 0, "Missile", "createEx", "missileDummy", this, "Invalid missile dummy unit ( null )!")
//#             endif
             set s__Missile_launched[this]=false
            return this
        endfunction
    
        // Freaky static if ensures these libraries really don't exist.
//#         static if not LIBRARY_MissileRecycler and not LIBRARY_Dummy and not Dummy.create.exists and not LIBRARY_xe_dummy and not xe_dummy.new.exists then
                function s__Missile_newMissileUnit takes real x,real y,real z,real face returns unit
                    local boolean prev= Missile__ToogleUnitIndexer(false)
                    set bj_lastCreatedUnit=CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, x, y, face)
                    call Missile__ToogleUnitIndexer(prev)
                    call SetUnitX(bj_lastCreatedUnit, x)
                    call SetUnitY(bj_lastCreatedUnit, y)
                    call UnitAddAbility(bj_lastCreatedUnit, 'Amrf')
                    call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0.)
                    call PauseUnit(bj_lastCreatedUnit, true)
                    return bj_lastCreatedUnit
                endfunction
//#         endif
    
        // MissileRecylcer > Dummy > xe > Missile.
    
        // Wrapper to createEx.
        function s__Missile_create takes real x,real y,real z,real angle,real distance,real impactZ returns integer
            local real impactX= x + distance * Cos(angle)
            local real impactY= y + distance * Sin(angle)
            // Get the dummy unit.
//textmacro instance: MISSILE_GET_DUMMY_FROM_LIBRARY()
//#             static if LIBRARY_MissileRecycler then
//#                 return createEx(GetRecycledMissile(x, y, z, angle*bj_RADTODEG), impactX, impactY, impactZ)
//#         
//#             elseif LIBRARY_Dummy and Dummy.create.exists then
//#                 local Dummy dummy = Dummy.create(x, y, angle*bj_RADTODEG)
//#                 call SetUnitFlyHeight(dummy.unit, z, 0.)
//#                 return createEx(dummy.unit, impactX, impactY, impactZ)
//#         
//#             elseif LIBRARY_xedummy and xedummy.new.exists then
//#                 set bj_lastCreatedUnit = xedummy.new(Missile_NEUTRAL_PASSIVE, x, y, angle*bj_RADTODEG)
//#                 call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0.)
//#                 return createEx(bj_lastCreatedUnit, impactX, impactY, impactZ)
//#             
//#             else
                    return s__Missile_createEx(s__Missile_newMissileUnit(x , y , z , angle * bj_RADTODEG) , impactX , impactY , impactZ)
//#             endif
//end of: MISSILE_GET_DUMMY_FROM_LIBRARY()
        endfunction
        
        // Wrapper to createEx.
        function s__Missile_createXYZ takes real x,real y,real z,real impactX,real impactY,real impactZ returns integer
            local real angle= Atan2(impactY - y, impactX - x)
            // Get the dummy unit.
//textmacro instance: MISSILE_GET_DUMMY_FROM_LIBRARY()
//#             static if LIBRARY_MissileRecycler then
//#                 return createEx(GetRecycledMissile(x, y, z, angle*bj_RADTODEG), impactX, impactY, impactZ)
//#         
//#             elseif LIBRARY_Dummy and Dummy.create.exists then
//#                 local Dummy dummy = Dummy.create(x, y, angle*bj_RADTODEG)
//#                 call SetUnitFlyHeight(dummy.unit, z, 0.)
//#                 return createEx(dummy.unit, impactX, impactY, impactZ)
//#         
//#             elseif LIBRARY_xedummy and xedummy.new.exists then
//#                 set bj_lastCreatedUnit = xedummy.new(Missile_NEUTRAL_PASSIVE, x, y, angle*bj_RADTODEG)
//#                 call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0.)
//#                 return createEx(bj_lastCreatedUnit, impactX, impactY, impactZ)
//#             
//#             else
                    return s__Missile_createEx(s__Missile_newMissileUnit(x , y , z , angle * bj_RADTODEG) , impactX , impactY , impactZ)
//#             endif
//end of: MISSILE_GET_DUMMY_FROM_LIBRARY()
        endfunction
    
        // Missile motion takes place every Missile_TIMER_TIMEOUT
        // before accessing each active struct.
        function s__Missile_move takes nothing returns boolean
            local integer loops= 0
            local integer limit= 150
            local integer this= s__Missile_temp
            
            local integer p
            local real a
            local real d
            local unit u
            local real newX
            local real newY
            local real vel
            local real point
            local real pitch
            loop
                exitwhen 0 == this or loops == limit
                set p=s__Missile_origin[this]
                
                // Save previous, respectively current missile position.
                set s__Missile_prevX[this]=s__Missile_x[this]
                set s__Missile_prevY[this]=s__Missile_y[this]
                set s__Missile_prevZ[this]=s__Missile_z[this]
                
                // Evaluate the collision type.
                set vel=s__Missile_speed[this]
                set s__Missile_speed[this]=vel + s__Missile_acceleration[this]
                if vel < s__Missile_collision[this] * Missile_COLLISION_ACCURACY_FACTOR then
                    set s__Missile_collisionType[this]=Missile_COLLISION_TYPE_CIRCLE
                else
                    set s__Missile_collisionType[this]=Missile_COLLISION_TYPE_RECTANGLE
                endif
                
                // Update missile guidance to its intended target.
                set u=s__Missile_target[this]
                if u != null then
                    if 0 == GetUnitTypeId(u) then
                        set s__Missile_target[this]=null
                    else
                        call s__MissilePosition_move(s__Missile_origin[this],s__Missile_x[this] , s__Missile_y[this] , s__Missile_z[this])
                        call s__MissilePosition_move(s__Missile_impact[this],GetUnitX(u) , GetUnitY(u) , GetUnitFlyHeight(u) + GetUnitBodySize(u) * s__Missile_HIT_BOX)
                        set s__Missile_dist[this]=0
                        set s__Missile_height[this]=0
                        call s__Missile__set_curve(this,0)
                    endif
                endif
                set a=s__MissilePosition_angle[p]
                
                // Update the missile facing angle depending on the turn ratio.
                if 0. != s__Missile_turn[this] and Cos(s__Missile_angle[this] - a) < Cos(s__Missile_turn[this]) then
                    if 0. > Sin(a - s__Missile_angle[this]) then
                        set s__Missile_angle[this]=s__Missile_angle[this] - s__Missile_turn[this]
                    else
                        set s__Missile_angle[this]=s__Missile_angle[this] + s__Missile_turn[this]
                    endif
                else
                    set s__Missile_angle[this]=a
                endif
                
                // Update the missile position on the parabola.
                set d=s__MissilePosition_distance[p] // origin - impact distance.
                
                set s__Missile_recycle[this]=s__Missile_dist[this] + vel >= d
                if s__Missile_recycle[this] then // Maximum distance reached. 
                    set point=d
                    set s__Missile_distance[this]=s__Missile_distance[this] + d - s__Missile_dist[this]
                else
                    set s__Missile_distance[this]=s__Missile_distance[this] + vel
                    set point=s__Missile_dist[this] + vel
                endif
                set s__Missile_dist[this]=point
                
                set newX=s__Missile_posX[this] + vel * Cos(s__Missile_angle[this])
                set newY=s__Missile_posY[this] + vel * Sin(s__Missile_angle[this])
                set s__Missile_posX[this]=newX
                set s__Missile_posY[this]=newY
                
                // Update point(x/y) if a curving trajectory is defined.
                set u=s__Missile_dummy[this]
                if 0. != s__Missile_open[this] and s__Missile_target[this] == null then
                    set vel=4 * s__Missile_open[this] * point * ( d - point ) / s__MissilePosition_square[p]
                    set a=s__Missile_angle[this] + bj_PI / 2
                    set newX=newX + vel * Cos(a)
                    set newY=newY + vel * Sin(a)
                    set a=s__Missile_angle[this] + Atan(- ( ( 4 * s__Missile_open[this] ) * ( 2 * point - d ) ) / s__MissilePosition_square[p])
                else
                    set a=s__Missile_angle[this]
                endif
                set s__Missile_x[this]=newX
                set s__Missile_y[this]=newY
                
                // Update pos z if an arc or height is set.
                call MoveLocation(Missile__LOC, newX, newY)
                set s__Missile_terrainZ[this]=GetLocationZ(Missile__LOC)
                set pitch=s__MissilePosition_alpha[p]
                if 0. == s__Missile_height[this] and 0. == pitch then
                    set s__Missile_z[this]=s__MissilePosition_z[p] - s__Missile_terrainZ[this]
                else
                    set s__Missile_z[this]=s__MissilePosition_z[p] - s__Missile_terrainZ[this] + s__MissilePosition_slope[p] * point
                    if 0. != s__Missile_height[this] and s__Missile_target[this] == null then
                        set s__Missile_z[this]=s__Missile_z[this] + ( 4 * s__Missile_height[this] * point * ( d - point ) / s__MissilePosition_square[p] )
                        set pitch=pitch - Atan(( ( 4 * s__Missile_height[this] ) * ( 2 * point - d ) ) / s__MissilePosition_square[p]) * bj_RADTODEG
                    endif
                endif
                // Update the pitch angle of the dummy unit. 
                if GetUnitTypeId(u) == Missile_DUMMY_UNIT_ID then
                    call SetUnitAnimationByIndex(u, R2I(pitch + 90.5))
                endif
                
                // Move the missile dummy via native.
                call SetUnitFlyHeight(u, s__Missile_z[this], 0.)
                call SetUnitFacing(u, a * bj_RADTODEG)
                
                // WorldBounds > BoundSentinel.
//#                 static if not LIBRARY_BoundSentinel and not LIBRARY_WorldBounds then
//#                     if RectContainsCoords(bj_mapInitialPlayableArea, newX, newY) then
//#                         call SetUnitX(u, newX)
//#                         call SetUnitY(u, newY)
//#                     endif                    
//#                 elseif LIBRARY_WorldBounds then
                        if newX < s__WorldBounds_maxX and newX > s__WorldBounds_minX and newY < s__WorldBounds_maxY and newY > s__WorldBounds_minY then
                            call SetUnitX(u, newX)
                            call SetUnitY(u, newY)
                        endif
//#                 else
//#                     call SetUnitX(u, newX)
//#                     call SetUnitY(u, newY)
//#                 endif
                
                set loops=loops + 1
                set this=Missile__nextNode[this]
            endloop
            
            set u=null
            set s__Missile_temp=this
            return this == 0
        endfunction
            
        // Widget collision API:
        // =====================
        //
        // Runs automatically on widget collision.
        function s__Missile_hitWidget takes integer this,widget w returns nothing
            if w != null then
                call SaveWidgetHandle(Missile__HASH, this, GetHandleId(w), w)
            endif
        endfunction
        
        // All widget which have been hit return true.
        function s__Missile_hasHitWidget takes integer this,widget w returns boolean
            return HaveSavedHandle(Missile__HASH, this, GetHandleId(w))
        endfunction
        
        // Removes a widget from the missile's memory of hit widgets. ( This widget can be hit again )
        function s__Missile_removeHitWidget takes integer this,widget w returns nothing
            if w != null then
                call RemoveSavedHandle(Missile__HASH, this, GetHandleId(w))
            endif
        endfunction
        
        // Flushes a missile's memory for collision. ( All widgets can be hit again )
        function s__Missile_flushHitWidgets takes integer this returns nothing
            call FlushChildHashtable(Missile__HASH, this)
            call s__Missile_hitWidget(this,s__Missile_dummy[this])
        endfunction
        
        // Tells missile to call removeHitWidget(w) after "seconds" time.
        // Does not apply to widgets, which are already hit by this missile.
        function s__Missile_enableHitAfter takes integer this,widget w,real seconds returns nothing
            local integer id= GetHandleId(w)
            if w != null then
                if not HaveSavedInteger(Missile__HASH, this, id) then
                    call SaveInteger(Missile__HASH, this, id, s__Missile_stackSize[this])
                    call SaveInteger(Missile__HASH, this, s__Missile_stackSize[this], id)
                    set s__Missile_stackSize[this]=s__Missile_stackSize[this] + 1
                endif
                call SaveReal(Missile__HASH, this, id, seconds) // Set time.
            endif
        endfunction
        
        function s__Missile_updateStack takes integer this returns nothing
            local integer dex= 0
            local integer id
            local real time
            loop
                exitwhen dex == s__Missile_stackSize[this]
                set id=LoadInteger(Missile__HASH, this, dex)
                set time=LoadReal(Missile__HASH, this, id) - Missile_TIMER_TIMEOUT
                if time <= 0. or not HaveSavedHandle(Missile__HASH, this, id) then
                    set s__Missile_stackSize[this]=s__Missile_stackSize[this] - 1
                    set id=LoadInteger(Missile__HASH, this, s__Missile_stackSize[this])
                    call SaveInteger(Missile__HASH, this, dex, id)
                    call SaveInteger(Missile__HASH, this, id, dex)
                    // Enables hit.
                    call RemoveSavedHandle(Missile__HASH, this, id)
                    // Remove data from stack.
                    call RemoveSavedReal(Missile__HASH, this, id)
                    call RemoveSavedInteger(Missile__HASH, this, id)
                    call RemoveSavedInteger(Missile__HASH, this, s__Missile_stackSize[this])
                else
                    call SaveReal(Missile__HASH, this, id, time)
                    set dex=dex + 1
                endif
            endloop
        endfunction
    
        // Widget collision code:
        // ======================
        //
        //
        // 1.) Rectangle collision for fast moving missiles with small collision radius.
        //        
        // Runs for destructables and items in a rectangle.
        // Checks if widget w is in collision range of a missile.
        // Is not precise in z - axis collision.
        function s__Missile_isWidgetInRectangle takes integer this,widget w,real wz,real distance returns boolean
            local real wx= GetWidgetX(w)
            local real wy= GetWidgetY(w)
            local real dz= Missile_GetLocZ(wx , wy) - s__Missile_terrainZ[this]
            local real dx= s__Missile_x[this] - s__Missile_prevX[this]
            local real dy= s__Missile_y[this] - s__Missile_prevY[this]
            local real s= ( dx * ( wx - s__Missile_prevX[this] ) + dy * ( wy - s__Missile_prevY[this] ) ) / ( dx * dx + dy * dy )
            
            if s < 0. then
                set s=0.
            elseif s > 1 then
                set s=1.
            endif
            set dx=( s__Missile_prevX[this] + s * dx ) - wx
            set dy=( s__Missile_prevY[this] + s * dy ) - wy

            return dx * dx + dy * dy <= distance * distance and dz + wz >= s__Missile_z[this] - distance and dz <= s__Missile_z[this] + distance
        endfunction        
        //
        // 2.) Circular collision detection for all other missiles.
        //
        // Returns true for widgets in a xyz collision range. 
        function s__Missile_isWidgetInRange takes integer this,widget w,real wz,real distance returns boolean
            local real wx= GetWidgetX(w)
            local real wy= GetWidgetY(w)
            local real dz= Missile_GetLocZ(wx , wy) - s__Missile_terrainZ[this]
            //     collision in plane x and y,            collision in z axis.
            return IsUnitInRangeXY(s__Missile_dummy[this], wx, wy, distance) and dz + wz >= s__Missile_z[this] - distance and dz <= s__Missile_z[this] + distance
        endfunction        
        //
        //  3.) Action functions inside the widget enumeration thread.
        //
        // Runs for every enumerated destructable.
        //  • Directly filters out already hit destructables.
        //  • Distance formula based on the Pythagorean theorem.
        //                         
        function s__Missile_filterDests takes nothing returns boolean
            local destructable d= GetFilterDestructable()
            local boolean b= false
            if not HaveSavedHandle(Missile__HASH, s__Missile_temp, GetHandleId(d)) then
                if s__Missile_circle then
                    set b=s__Missile_isWidgetInRange(s__Missile_temp,d , GetDestructableHeight(d) , s__Missile_collision[s__Missile_temp])
                else
                    set b=s__Missile_isWidgetInRectangle(s__Missile_temp,d , GetDestructableHeight(d) , s__Missile_collision[s__Missile_temp])
                endif
            endif
            set d=null
            return b
        endfunction
        //
        // Runs for every enumerated item.
        //  • Directly filters out already hit items.
        //  • Distance formula based on the Pythagorean theorem.
        //  • Items have a fix collision size of 16.
        // 
        function s__Missile_filterItems takes nothing returns boolean
            local item i= GetFilterItem()
            local boolean b= false
            if not HaveSavedHandle(Missile__HASH, s__Missile_temp, GetHandleId(i)) then
                if s__Missile_circle then // Item in missile collision size or item pathing in missile range.
                    set b=s__Missile_isWidgetInRange(s__Missile_temp,i , GetItemHeight(i) , RMaxBJ(s__Missile_collision[s__Missile_temp], 16.))
                else
                    set b=s__Missile_isWidgetInRectangle(s__Missile_temp,i , GetItemHeight(i) , RMaxBJ(s__Missile_collision[s__Missile_temp], 16.))
                endif
            endif
            set i=null
            return b
        endfunction
        //
        //  4.) Filter function for rectangle unit collision.
        //
        // Runs for every enumerated units.
        //  • Filters out units which are not in collision range in plane x / y.
        //  • Inlined and therefore a bit faster than item and destructable collision.
        //
        function s__Missile_filterUnits takes nothing returns boolean
            local integer this= s__Missile_temp
            local unit u= GetFilterUnit()
            local real dx
            local real dy
            local real s
            local boolean is= false
            
            if not HaveSavedHandle(Missile__HASH, this, GetHandleId(u)) then
                set dx=s__Missile_x[this] - s__Missile_prevX[this]
                set dy=s__Missile_y[this] - s__Missile_prevY[this]
                set s=( dx * ( GetUnitX(u) - s__Missile_prevX[this] ) + dy * ( GetUnitY(u) - s__Missile_prevY[this] ) ) / ( dx * dx + dy * dy )
                if s < 0. then
                    set s=0.
                elseif s > 1. then
                    set s=1.
                endif
                set is=IsUnitInRangeXY(u, s__Missile_prevX[this] + s * dx, s__Missile_prevY[this] + s * dy, s__Missile_collision[this])
            endif
            
            set u=null
            return is
        endfunction
        //
        // 5.) Proper rect preparation.
        //
        // For rectangle.
        function s__Missile_prepareRectRectangle takes integer this returns nothing
            local real x1= s__Missile_prevX[this]
            local real y1= s__Missile_prevY[this]
            local real x2= s__Missile_x[this]
            local real y2= s__Missile_y[this]
            local real d= s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE
            // What is min, what is max ...
            if x1 < x2 then
                if y1 < y2 then
                    call SetRect(Missile__RECT, x1 - d, y1 - d, x2 + d, y2 + d)
                else
                    call SetRect(Missile__RECT, x1 - d, y2 - d, x2 + d, y1 + d)
                endif
            elseif y1 < y2 then
                call SetRect(Missile__RECT, x2 - d, y1 - d, x1 + d, y2 + d)
            else
                call SetRect(Missile__RECT, x2 - d, y2 - d, x1 + d, y1 + d)
            endif
        endfunction
        //
        // For circular.
        function s__Missile_prepareRectCircle takes integer this returns nothing
            local real d= s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE
            call SetRect(Missile__RECT, s__Missile_x[this] - d, s__Missile_y[this] - d, s__Missile_x[this] + d, s__Missile_y[this] + d)
        endfunction
        //
        // 5.) API for the MissileStruct iteration.
        //
        function s__Missile_groupEnumUnitsRectangle takes integer this returns nothing
            call s__Missile_prepareRectRectangle(this)
            set s__Missile_temp=this
            call GroupEnumUnitsInRect(Missile__GROUP, Missile__RECT, Missile__unitFilter)
        endfunction
        //
        // Prepares destructable enumeration, then runs enumDests.
        function s__Missile_checkDestCollision takes integer this,code func returns nothing
            set s__Missile_circle=s__Missile_collisionType[this] == Missile_COLLISION_TYPE_CIRCLE
            if s__Missile_circle then
                call s__Missile_prepareRectCircle(this)
            else
                call s__Missile_prepareRectRectangle(this)
            endif
            //
            set s__Missile_temp=this
            call EnumDestructablesInRect(Missile__RECT, Missile__destFilter, func)
        endfunction
        //
        // Prepares item enumeration, then runs enumItems.
        function s__Missile_checkItemCollision takes integer this,code func returns nothing
            set s__Missile_circle=s__Missile_collisionType[this] == Missile_COLLISION_TYPE_CIRCLE
            if s__Missile_circle then
                call s__Missile_prepareRectCircle(this)
            else
                call s__Missile_prepareRectRectangle(this)
            endif
            //
            set s__Missile_temp=this
            call EnumItemsInRect(Missile__RECT, Missile__itemFilter, func)
        endfunction

//# static if Missile_WRITE_DELAYED_MISSILE_RECYCLING then
        function s__Missile_nullBefore takes integer this returns nothing
            set s__Missile_dummy[this]=null
        endfunction
//# endif

// Does not check for 'Aloc' and 'Amrf' as they could be customized.
        function s__Missile_onInit takes nothing returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  local boolean prev = Missile__ToogleUnitIndexer(false)
//#                  local unit dummy = CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, 0., 0., 0.)
//#                  call Missile__ToogleUnitIndexer(prev)
//#                 //
//#                  call ThrowError((GetUnitTypeId(dummy) != Missile_DUMMY_UNIT_ID), "Missile", "DEBUG_MISSILE", "type id",    0, "Global setup for public integer DUMMY_UNIT_ID is incorrect! This map currently can't use Missile!")
//#                  call ThrowError((Missile_MAXIMUM_COLLISION_SIZE < 0),            "Missile", "DEBUG_MISSILE", "collision",  0, "Global setup for public real MAXIMUM_COLLISION_SIZE is incorrect, below zero! This map currently can't use Missile!")
//#                  call RemoveUnit(dummy)
//#                  set dummy = null
//#             endif
            //
            set Missile__unitFilter=Filter(function s__Missile_filterUnits)
            set Missile__destFilter=Filter(function s__Missile_filterDests)
            set Missile__itemFilter=Filter(function s__Missile_filterItems)
            call TriggerAddCondition(Missile__MOVE, Condition(function s__Missile_move))
        endfunction
        
    // You made it to the end of Missile, but we are not finished.
    // Do you remember about the data structure, the delayed recycler
    // and of course our interface module "MissileStruct"
    //
    // This comes now!
    
    // Debug code taken from List ( full credits to Nestharus )

    // Boolean expressions per struct:
    // ===============================
    //     
    // Condition function for the core trigger evaluation. ( Runs for all struct using module MissileStruct )
    function Missile__MissileCreateExpression takes integer structId,code func returns nothing
        set Missile__expression[structId]=Condition(func)
    endfunction
    
    // Creates a collection for a struct. ( Runs for all struct using module MissileStruct )
    function Missile__MissileCreateCollection takes integer structId returns nothing
        set Missile__missileList[structId]=s__Missile_allocateCollection()
    endfunction
    
    // Core:
    // =====
    //
    // Fires every Missile_TIMER_TIMEOUT.
    function Missile__Fire takes nothing returns nothing
        local integer i= Missile__remove[0]
        set Missile__remove[0]=0
        loop
            exitwhen 0 == i
            if Missile__recycling[i] then
                call TriggerRemoveCondition(Missile__CORE, Missile__condition[i])
                set Missile__condition[i]=null
                set Missile__active=Missile__active - 1
            endif
            set Missile__destroying[i]=false
            set Missile__recycling[i]=false
            set i=Missile__remove[i]
        endloop
        
        if 0 == Missile__active then
            call PauseTimer(Missile__TMR)
        else
            // Move all launched missiles.
            set s__Missile_temp=Missile__nextNode[0]
            set i=0
            loop
                exitwhen TriggerEvaluate(Missile__MOVE)
                exitwhen i == 60 // Moved over 8910 missiles, something buggy happened.
                set i=i + 1 // This case is impossible, hence never happens. But if I'm wrong, which also never happens 
            endloop // then the map 100% crashes. i == 66 will prevent the game crash and Missile will start to 
                                // to debug itself over the next iterations.
        
            // Access all structs using module MissileStruct. 
//#             static if true and LIBRARY_ErrorMesssage then
//#                 if not TriggerEvaluate(Missile__CORE) then
//#                     call ThrowWarning(true, "Missile", "Fire", "op limit", 0, "You just ran into a op limit!\nThe op limit protection of Missile is insufficient for your map.\nThe code of the missile module can't run in one thread and must be splitted.\nIf unsure make a post in the official 'The Hive Workshop' forum thread of Missile!")
//#                 endif
//#             else
                    call TriggerEvaluate(Missile__CORE)
//#             endif
        endif
    endfunction
    
    // Conditionally starts the timer.
    function Missile__StartPeriodic takes integer structId returns nothing
        if 0 == Missile__instances[structId] or Missile__destroying[structId] then
            if Missile__destroying[structId] then
                set Missile__recycling[structId]=false
            else
                if 0 == Missile__active then
                    call TimerStart(Missile__TMR, Missile_TIMER_TIMEOUT, true, function Missile__Fire)
                endif
                set Missile__active=Missile__active + 1
                set Missile__condition[structId]=TriggerAddCondition(Missile__CORE, Missile__expression[structId])
            endif
        endif
        set Missile__instances[structId]=Missile__instances[structId] + 1
    endfunction
    
    // Conditionally stops the timer in the next callback.
    function Missile__StopPeriodic takes integer structId returns nothing
        set Missile__instances[structId]=Missile__instances[structId] - 1
        if 0 == Missile__instances[structId] and Missile__condition[structId] != null then
            if not Missile__destroying[structId] and not Missile__recycling[structId] then
                set Missile__destroying[structId]=true
                set Missile__recycling[structId]=true
                set Missile__remove[structId]=Missile__remove[0]
                set Missile__remove[0]=structId
            endif
        endif
    endfunction
    
    // Modules:
    // ========
    //
    // You want to place module MissileLaunch at the very top of your struct.
    
    
    // Allows you to inject missile in certain stages of the motion process.
    
    
    // Missile position:
    // =================
    //
    // Simple trigonometry.
    
    // Delayed dummy recycling:
    // ========================
    //
    // Ensures proper fx death animations.
    
// The end!

//library Missile ends
//library SpellEffectEvent:
 
//============================================================================
 
//============================================================================
//Implemented from module SpellEffectEvent__M:
   
//#     static if LIBRARY_Table then
//#         static Table tb
//#     else
//#     endif
   
    function s__SpellEffectEvent__S_onCast takes nothing returns nothing
//#         static if LIBRARY_Table then
//#             call TriggerEvaluate(.tb.trigger[GetSpellAbilityId()])
//#         else
                call TriggerEvaluate(LoadTriggerHandle(s__SpellEffectEvent__S_ht, 0, GetSpellAbilityId()))
//#         endif
    endfunction
 
    function s__SpellEffectEvent__S_SpellEffectEvent__M__onInit takes nothing returns nothing
//#         static if LIBRARY_Table then
//#             set .tb = Table.create()
//#         endif
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT , function s__SpellEffectEvent__S_onCast)
    endfunction
 
//============================================================================
function RegisterSpellEffectEvent takes integer abil,code onCast returns nothing
//#     static if LIBRARY_Table then
//#         if not SpellEffectEvent__S.tb.handle.has(abil) then
//#             set SpellEffectEvent__S.tb.trigger[abil] = CreateTrigger()
//#         endif
//#         call TriggerAddCondition(SpellEffectEvent__S.tb.trigger[abil], Filter(onCast))
//#     else
            if not HaveSavedHandle(s__SpellEffectEvent__S_ht, 0, abil) then
                call SaveTriggerHandle(s__SpellEffectEvent__S_ht, 0, abil, CreateTrigger())
            endif
            call TriggerAddCondition(LoadTriggerHandle(s__SpellEffectEvent__S_ht, 0, abil), Filter(onCast))
//#     endif
endfunction
 

//library SpellEffectEvent ends
//===========================================================================
// 
// Armageddon
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Date: Tue Mar 29 11:48:41 2016
//   Map Author: BPower
// 
//===========================================================================

//***************************************************************************
//*
//*  Global Variables
//*
//***************************************************************************


function InitGlobals takes nothing returns nothing
    local integer i= 0
    set udg_CF_MaxIndex=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_CF_Level[i]=0
        set i=i + 1
    endloop

    set udg_CF_Gap=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_CF_Waves[i]=0
        set i=i + 1
    endloop

    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_CF_Loop[i]=0
        set i=i + 1
    endloop

    set udg_CF_CEff=""
    set udg_CF_MaxEff=0
    set udg_CF_LineEff=""
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_CF_Damage[i]=0
        set i=i + 1
    endloop

    set udg_CF_CurrentIndex=0
    set i=0
    loop
        exitwhen ( i > 1 )
        set udg_CF_PeriodicDamage[i]=0
        set i=i + 1
    endloop

    set udg_CF_BurnAttach=""
    set udg_CF_BurnEff=""
    set udg_CF_HitEff=""
    set udg_CF_HitAttach=""
endfunction

//***************************************************************************
//*
//*  Sounds
//*
//***************************************************************************

function InitSounds takes nothing returns nothing
    set gg_snd_RainOfFireLoop1=CreateSound("Abilities\\Spells\\Demon\\RainOfFire\\RainOfFireLoop1.wav", false, true, true, 10, 10, "SpellsEAX")
    call SetSoundParamsFromLabel(gg_snd_RainOfFireLoop1, "RainOfFireLoop")
    call SetSoundDuration(gg_snd_RainOfFireLoop1, 4000)
endfunction

//***************************************************************************
//*
//*  Unit Creation
//*
//***************************************************************************

//===========================================================================
function CreateBuildingsForPlayer1 takes nothing returns nothing
    local player p= Player(1)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'hgtw', - 1152.0, - 2624.0, 270.000)
    set u=CreateUnit(p, 'hgtw', - 1920.0, - 1984.0, 270.000)
    set u=CreateUnit(p, 'hgtw', - 1984.0, - 2688.0, 270.000)
endfunction

//===========================================================================
function CreateBuildingsForPlayer2 takes nothing returns nothing
    local player p= Player(2)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'hgtw', 832.0, 1664.0, 270.000)
    set u=CreateUnit(p, 'hgtw', 1600.0, 1088.0, 270.000)
    set u=CreateUnit(p, 'hgtw', 1600.0, 1856.0, 270.000)
endfunction

//===========================================================================
function CreateNeutralHostile takes nothing returns nothing
    local player p= Player(PLAYER_NEUTRAL_AGGRESSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'ufro', - 1257.1, - 30.0, 24.930)
endfunction

//===========================================================================
function CreatePlayerBuildings takes nothing returns nothing
    call CreateBuildingsForPlayer1()
    call CreateBuildingsForPlayer2()
endfunction

//===========================================================================
function CreatePlayerUnits takes nothing returns nothing
endfunction

//===========================================================================
function CreateAllUnits takes nothing returns nothing
    call CreatePlayerBuildings()
    call CreateNeutralHostile()
    call CreatePlayerUnits()
endfunction

//***************************************************************************
//*
//*  Triggers
//*
//***************************************************************************

//===========================================================================
// Trigger: Missile
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: TimerUtils
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: SpellEffectEvent
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
//============================================================================
// SpellEffectEvent
// - Version 1.1.0.0
//
// API
// ---
//     RegisterSpellEffectEvent(integer abil, code onCast)
//
// Requires
// --------
//     RegisterPlayerUnitEvent: hiveworkshop.com/forums/showthread.php?t=203338
//
// Optional
// --------
//     Table: hiveworkshop.com/forums/showthread.php?t=188084
//
// Trigger: RegisterPlayerUnitEvent
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0

//===========================================================================
// Trigger: WorldBounds
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: IsDestructableTree
//===========================================================================
//TESH.scrollpos=21
//TESH.alwaysfold=0
// Trigger: Armageddon
//===========================================================================
//TESH.scrollpos=286
//TESH.alwaysfold=0
// scope Armageddon begins
//**
//*  User settings:
//*  ==============
    // One declaration of native "UnitAlive" per map script is enough.


    
    // Set if the spell moves along with the caster. 
    function Armageddon__IsSpellMovingWithCaster takes unit caster,integer level returns boolean
        return true
    endfunction
    
    // Set if the caster has to channel the spell.
    // In case the spell is channeling, make sure the "follow through time" field of the ability fits the spell duration.
    function Armageddon__IsSpellChanneling takes unit caster,integer level returns boolean
        return true
    endfunction
    
    // Set how many meteor should be created per second. 
    // This function is re-evaluated each second, therefore a GetRandomInt() also makes sense here.
    constant function Armageddon__GetMeteorsPerSecond takes integer level returns integer
        return 1 + ( 2 * level )
    endfunction
    
    // Set the total spell duration.
    constant function Armageddon__GetSpellDuration takes integer level returns real
        return 6. + ( 2 * level )
    endfunction
    
    // Set the maximum field size in which effects take place.
    constant function Armageddon__GetSpellFieldSize takes integer level returns real
        return 500. + ( 50 * level )
    endfunction
    
    // Set the expected fly time per meteor. 
    function Armageddon__GetMeteorFlyTime takes integer level returns real
        return GetRandomReal(2., 3)
    endfunction
    
    // Filter valid target units. Runs on unit collision.
    // Do NOT filter for flying units. This is done internally inside the spell script.
    function Armageddon__FilterUnits takes unit target,player p returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, p)
    endfunction
    
    // Runs each time before a new meteor is created.
    function Armageddon__GlobalCasterCondition takes unit caster returns boolean
        return UnitAlive(caster)
    endfunction
    
    // Customize all missile members to your needs. "speed", "source", "owner" and "acceleration" are reserved and will be overriden.
    function Armageddon__CustomizeMeteor takes integer missile,unit caster,integer level returns nothing
        local real scale= GetRandomReal(.8, 1.3)
        call s__Missile__set_scale(missile,scale)
        set s__Missile_damage[missile]=55. + 20. * level * scale
        set s__Missile_collision[missile]=96. * scale
        call s__Missile__set_collisionZ(missile,96. * scale) // Only required for if you want to damage flying units in mid air.
        call s__Missile__set_model(missile,"Abilities\\Spells\\Other\\Volcano\\VolcanoMissile.mdl")
    endfunction
    
    // You may delete the following content and return null for no sound.
    function Armageddon__GetSoundHandle takes nothing returns sound
        local string file= "Abilities\\Spells\\Demon\\RainOfFire\\RainOfFireLoop1.wav"
        local sound snd= CreateSound(file, true, true, true, 10, 10, "")
        call SetSoundChannel(snd, 5)
        call SetSoundVolume(snd, 127)
        call SetSoundDistances(snd, 600, 10000)
        call SetSoundDistanceCutoff(snd, 3000)
        call SetSoundConeAngles(snd, 0, 0, 127)
        call SetSoundConeOrientation(snd, 0, 0, 0)
        call StartSound(snd)
        set bj_lastPlayedSound=snd
        set snd=null
        return bj_lastPlayedSound // null
    endfunction

//========================================================================
// Armageddon code. Make changes carefully.
//========================================================================
    
    // Uses Missile's API.
        
        // Runs on any destructable collision. You'll need IsDestructableTree.
//#         static if LIBRARY_IsDestructableTree and Armageddon__IMPACT_DAMAGES_TREES then
                function s__Armageddon__Meteor_onDestructable takes integer missile,destructable hit returns boolean
                    if IsTreeAlive(hit) then
                        if ( s__Missile_damage[missile] > ( GetWidgetLife(hit) + .405 ) ) then
                            call KillDestructable(hit)
                        else
                            call SetWidgetLife(hit, GetWidgetLife(hit) - s__Missile_damage[missile])
                            call SetDestructableAnimation(hit, "stand hit")
                        endif
                    endif
                    return false
                endfunction
//#         endif
        
        // Runs on any unit collision. Written to hit flying units in mid air.
        // Requires Missile_USE_COLLISION_Z_FILTER = true.
//#         static if Missile_USE_COLLISION_Z_FILTER and Armageddon__DAMAGE_FLYING_UNITS then
                function s__Armageddon__Meteor_onCollide takes integer missile,unit hit returns boolean
                    if IsUnitType(hit, UNIT_TYPE_FLYING) and Armageddon__FilterUnits(hit , s__Missile_owner[missile]) then
                        if UnitDamageTarget(s__Missile_source[missile], hit, s__Missile_damage[missile], false, false, Armageddon__ATTACK_TYPE, Armageddon__DAMAGE_TYPE, null) then
                            call DestroyEffect(AddSpecialEffectTarget(Armageddon__ON_DAMAGE_UNIT_FX, hit, Armageddon__DAMAGE_FX_ATTACH_POINT))
                        endif
                    endif
                    return false
                endfunction
//#         endif
        
        // Runs when a missile launched from the Armageddon struct is deallocated. 
        // Written to hit non flying units in collision range.
        function s__Armageddon__Meteor_onRemove takes integer missile returns boolean
            local unit u
            call GroupEnumUnitsInRange(bj_lastCreatedGroup, s__Missile_x[missile], s__Missile_y[missile], s__Missile_collision[missile] + Missile_MAXIMUM_COLLISION_SIZE, null)
            loop
                set u=FirstOfGroup(bj_lastCreatedGroup)
                exitwhen u == null
                call GroupRemoveUnit(bj_lastCreatedGroup, u)
                if IsUnitInRange(s__Missile_dummy[missile], u, s__Missile_collision[missile]) and not IsUnitType(u, UNIT_TYPE_FLYING) and Armageddon__FilterUnits(u , s__Missile_owner[missile]) then
                    if UnitDamageTarget(s__Missile_source[missile], u, s__Missile_damage[missile], false, false, Armageddon__ATTACK_TYPE, Armageddon__DAMAGE_TYPE, null) then
                        call DestroyEffect(AddSpecialEffectTarget(Armageddon__ON_DAMAGE_UNIT_FX, u, Armageddon__DAMAGE_FX_ATTACH_POINT))
                    endif
                endif
            endloop
            return true
        endfunction
        
        // Enables the Missile interface for this struct.
//Implemented from module MissileStruct:
        function s__Armageddon__Meteor_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "Armageddon__Meteor", "launch", "missile.launched", missile, "This missile was already launched before!")
//#             endif
             set s__Missile_launched[missile]=true
            //
            call s__Missile_insertFront(Missile__missileList[si__Armageddon__Meteor],missile)
            call Missile__StartPeriodic(si__Armageddon__Meteor)
        endfunction
        // Called from missileIterate. "P" to avoid code collision.
        function s__Armageddon__Meteor_missileTerminateP takes integer node returns nothing
            if s__Missile_allocated[node] then
//#                 static if Armageddon__Meteor.onRemove.exists then
//#                     static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile__RecycleBin.recycle.exists then
                            if s__Armageddon__Meteor_onRemove(node) and GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID then
                                call s__Missile__RecycleBin_recycle(s__Missile_dummy[node])
                                call s__Missile_nullBefore(node)
                            endif
//#                     else
//#                         call Armageddon__Meteor.onRemove(node)
//#                     endif
//#                 endif
            
                call s__Missile_terminate(node)
                call Missile__StopPeriodic(si__Armageddon__Meteor)
            endif
        endfunction

//# static if true then
        // Runs check during compile time.
//#     static if Armageddon__Meteor.onMissile.exists then
//#         Error Message from library Missile in struct Armageddon__Meteor !
//#         Armageddon__Meteor.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#         Armageddon__Meteor.onMissile is currently not supported by library Missile. 
//#         Please delete or re-name that method.
//#     endif
//# endif

//#     static if Armageddon__Meteor.onItem.exists then
//#         private static method MissileAction__missileActionItem takes nothing returns nothing
//#             local item i = GetEnumItem()
//#             local Missile this = Missile.temp
//#             if this.allocated then
//#                 call SaveItemHandle(Missile__HASH, this, GetHandleId(i), i) 
//#                 if Armageddon__Meteor.onItem(this, i) then
//#                     call missileTerminateP(this)
//#                 endif
//#             endif
//#             set i = null
//#         endmethod
//#     endif
        
//#     static if Armageddon__Meteor.onDestructable.exists then
            function s__Armageddon__Meteor_MissileAction__missileActionDest takes nothing returns nothing
                local destructable d= GetEnumDestructable()
                local integer this= s__Missile_temp
                if s__Missile_allocated[this] then
                    call SaveDestructableHandle(Missile__HASH, this, GetHandleId(d), d)
                    if s__Armageddon__Meteor_onDestructable(this , d) then
                        call s__Armageddon__Meteor_missileTerminateP(this)
                    endif
                endif
                set d=null
            endfunction
//#     endif
    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__Armageddon__Meteor_missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile__missileList[si__Armageddon__Meteor])
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            loop
                exitwhen 0 == this
                set node=s__Missile__get_next(this) // The linked list should not lose the next node.
               
                if s__Missile_wantDestroy[this] then
                    call s__Armageddon__Meteor_missileTerminateP(this)
                else
                    if s__Missile_stackSize[this] > 0 then
                        call s__Missile_updateStack(this)
                    endif
                    
                    // Runs unit collision.
//#                     static if Armageddon__Meteor.onCollide.exists then
                            if s__Missile_allocated[this] and 0. < s__Missile_collision[this] then
                                set b=s__Missile_collisionType[this] == Missile_COLLISION_TYPE_RECTANGLE
                                if b then
                                    call s__Missile_groupEnumUnitsRectangle(this)
                                else
                                    call GroupEnumUnitsInRange(Missile__GROUP, s__Missile_x[this], s__Missile_y[this], s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE, null)
                                endif
                                loop
                                    set u=FirstOfGroup(Missile__GROUP)
                                    exitwhen u == null
                                    call GroupRemoveUnit(Missile__GROUP, u)
                                    if not HaveSavedHandle(Missile__HASH, this, GetHandleId(u)) then
                                        if IsUnitInRange(u, s__Missile_dummy[this], s__Missile_collision[this]) or b then
                                            // Eventually run z collision checks.
//#                                         static if Missile_USE_COLLISION_Z_FILTER then
                                                set collideZ=Missile_GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u) - s__Missile_terrainZ[this]
                                                if ( collideZ + GetUnitBodySize(u) >= s__Missile_z[this] - s__Missile__get_collisionZ(this) ) and ( collideZ <= s__Missile_z[this] + s__Missile__get_collisionZ(this) ) then
                                                    // Mark as hit.
                                                    call SaveUnitHandle(Missile__HASH, this, GetHandleId(u), u)
                                                    if s__Armageddon__Meteor_onCollide(this , u) then
                                                        call s__Armageddon__Meteor_missileTerminateP(this)
                                                        exitwhen true
                                                    endif
                                                endif
        
//#                                         else
//#                                             // Runs unit collision without z collision checks.
//#                                             call SaveUnitHandle(Missile__HASH, this, GetHandleId(u), u)
//#                                             if Armageddon__Meteor.onCollide(this, u) then
//#                                                 call Armageddon__Meteor.missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                         endif
                                        endif
                                    endif
                                endloop
                            endif
//#                     endif
                    
                    // Runs destructable collision.
//#                     static if Armageddon__Meteor.onDestructable.exists then
                            // Check if the missile is not terminated.
                            if s__Missile_allocated[this] and 0. < s__Missile_collision[this] then
                                call s__Missile_checkDestCollision(this,function s__Armageddon__Meteor_MissileAction__missileActionDest)
                            endif
//#                     endif
                    
                    // Runs item collision.
//#                     static if Armageddon__Meteor.onItem.exists then
//#                         //  Check if the missile is not terminated.
//#                         if this.allocated and 0. < this.collision then
//#                             call this.checkItemCollision(function Armageddon__Meteor.MissileAction__missileActionItem)
//#                         endif
//#                     endif
                
                    // Runs when the destination is reached.
                    if s__Missile_recycle[this] and s__Missile_allocated[this] then
//#                         static if Armageddon__Meteor.onFinish.exists then
//#                             if Armageddon__Meteor.onFinish(this) then
//#                                 call Armageddon__Meteor.missileTerminateP(this)
//#                             endif
//#                         else
                                call s__Armageddon__Meteor_missileTerminateP(this)
//#                         endif
                    endif
                
                    // Runs on terrian collision.
//#                     static if Armageddon__Meteor.onTerrain.exists then
//#                         if this.allocated and 0. > this.z and Armageddon__Meteor.onTerrain(this) then
//#                             call missileTerminateP(this)
//#                         endif
//#                     endif
                
                    // Runs every Missile_TIMER_TIMEOUT.
//#                     static if Armageddon__Meteor.onPeriod.exists then
//#                         if this.allocated and Armageddon__Meteor.onPeriod(this) then
//#                             call missileTerminateP(this)
//#                         endif
//#                     endif
                endif
                set this=node
            endloop
            
            set u=null
//#             static if true and LIBRARY_ErrorMessage then
//#                 return true
//#             else
                    return false
//#             endif
        endfunction
        
        function s__Armageddon__Meteor_MissileStruct__onInit takes nothing returns nothing
            call Missile__MissileCreateCollection(si__Armageddon__Meteor)
            call Missile__MissileCreateExpression(si__Armageddon__Meteor , function s__Armageddon__Meteor_missileIterateP)
        endfunction

    function Armageddon__Random takes nothing returns real
        return GetRandomReal(0., 1.)
    endfunction
    
    function Armageddon__GetRandomRange takes real radius returns real
        local real r= Armageddon__Random() + Armageddon__Random()
        if r > 1. then
            return ( 2 - r ) * radius
        endif
        return r * radius
    endfunction
    
    function Armageddon__CreateMeteor takes unit source,player owner,real centerX,real centerY,real maxRange,integer level returns nothing
        // Get point of creation.
        local real theta= 2 * bj_PI * Armageddon__Random()
        local real radius= Armageddon__GetRandomRange(maxRange)
        local real posX= centerX + radius * Cos(theta)
        local real posY= centerY + radius * Sin(theta)
        
        // Get the fly angle and maximum distance towards it.
        local real angle= 2 * bj_PI * Armageddon__Random()
        local real maxX= centerX + maxRange * Cos(angle)
        local real maxY= centerY + maxRange * Sin(angle)
        
        // Get the maximum distance without leaving the field.
        local real dX= posX - maxX
        local real dY= posY - maxY
        local integer missile= s__Missile_create(posX , posY , Armageddon__METEOR_START_HEIGHT , angle , SquareRoot(dX * dX + dY * dY) * Armageddon__Random() , 0.)
        
        // Allow user customization.
        call Armageddon__CustomizeMeteor(missile , source , level)
        // Set or override important missile fields.
        set s__Missile_source[missile]=source
        set s__Missile_owner[missile]=owner
        set s__Missile_acceleration[missile]=0.
        call s__Missile_flightTime2Speed(missile,Armageddon__GetMeteorFlyTime(level))
        call s__Armageddon__Meteor_launch(missile)
    endfunction
    
        // implement Alloc
        //
        // Members.
        //
        // Spell concept members.
        
        function s__Armageddon__Armageddon_clear takes integer this returns nothing
            if s__Armageddon__Armageddon_snd[this] != null then
                call StopSound(s__Armageddon__Armageddon_snd[this], true, true)
                set s__Armageddon__Armageddon_snd[this]=null
            endif
            call DestroyEffect(s__Armageddon__Armageddon_fx[this])
            call ReleaseTimer(s__Armageddon__Armageddon_clock[this])
            call s__Armageddon__Armageddon_deallocate(this)
            
            set s__Armageddon__Armageddon_clock[this]=null
            set s__Armageddon__Armageddon_source[this]=null
            set s__Armageddon__Armageddon_user[this]=null
            set s__Armageddon__Armageddon_fx[this]=null
        endfunction
        
        function s__Armageddon__Armageddon_onPeriodic takes nothing returns nothing
            local integer this= GetTimerData(GetExpiredTimer())
            local boolean fire= ( s__Armageddon__Armageddon_count[this] > 0 )
            // Evaluate global conditions.
            if not Armageddon__GlobalCasterCondition(s__Armageddon__Armageddon_source[this]) or s__Armageddon__Armageddon_time[this] <= 0. or ( s__Armageddon__Armageddon_channel[this] and ( s__Armageddon__Armageddon_order[this] != GetUnitCurrentOrder(s__Armageddon__Armageddon_source[this]) ) ) then
                call s__Armageddon__Armageddon_clear(this)
            else
                // Update time members.
                set s__Armageddon__Armageddon_time[this]=s__Armageddon__Armageddon_time[this] - s__Armageddon__Armageddon_interval[this]
                set s__Armageddon__Armageddon_count[this]=s__Armageddon__Armageddon_count[this] - 1
                if s__Armageddon__Armageddon_count[this] <= 0 then
                    set s__Armageddon__Armageddon_count[this]=Armageddon__GetMeteorsPerSecond(s__Armageddon__Armageddon_level[this])
                    set s__Armageddon__Armageddon_interval[this]=1. / IMaxBJ(1, s__Armageddon__Armageddon_count[this])
                    call TimerStart(s__Armageddon__Armageddon_clock[this], s__Armageddon__Armageddon_interval[this], true, function s__Armageddon__Armageddon_onPeriodic)
                endif
                // Update the center position.
                if s__Armageddon__Armageddon_move[this] then
                    set s__Armageddon__Armageddon_centerX[this]=GetUnitX(s__Armageddon__Armageddon_source[this])
                    set s__Armageddon__Armageddon_centerY[this]=GetUnitY(s__Armageddon__Armageddon_source[this])
                    if ( s__Armageddon__Armageddon_snd[this] != null ) then
                        call SetSoundPosition(s__Armageddon__Armageddon_snd[this], s__Armageddon__Armageddon_centerX[this], s__Armageddon__Armageddon_centerY[this], 0.)
                    endif
                endif
                if fire then
                    // Create a new meteor.
                    call Armageddon__CreateMeteor(s__Armageddon__Armageddon_source[this] , s__Armageddon__Armageddon_user[this] , s__Armageddon__Armageddon_centerX[this] , s__Armageddon__Armageddon_centerY[this] , s__Armageddon__Armageddon_size[this] , s__Armageddon__Armageddon_level[this])
                endif
            endif
        endfunction
    
                     // EVENT_PLAYER_UNIT_SPELL_EFFECT.
    function Armageddon__OnEffect takes nothing returns nothing
        local unit source= GetTriggerUnit()
        local integer level= GetUnitAbilityLevel(source, Armageddon__ARMAGEDDON_ABILITY)
        local integer dex= s__Armageddon__Armageddon__allocate()
    
        set s__Armageddon__Armageddon_source[dex]=source
        set s__Armageddon__Armageddon_level[dex]=level
        set s__Armageddon__Armageddon_clock[dex]=NewTimerEx(dex)
        set s__Armageddon__Armageddon_user[dex]=GetTriggerPlayer()
        set s__Armageddon__Armageddon_order[dex]=GetUnitCurrentOrder(source)
        set s__Armageddon__Armageddon_time[dex]=Armageddon__GetSpellDuration(level)
        set s__Armageddon__Armageddon_count[dex]=Armageddon__GetMeteorsPerSecond(level)
        set s__Armageddon__Armageddon_move[dex]=Armageddon__IsSpellMovingWithCaster(source , level)
        set s__Armageddon__Armageddon_size[dex]=Armageddon__GetSpellFieldSize(level) * .5
        set s__Armageddon__Armageddon_channel[dex]=Armageddon__IsSpellChanneling(source , level)
        
//#         static if Armageddon__IS_IMMEDIATE_ORDER then
                set s__Armageddon__Armageddon_centerX[dex]=GetUnitX(source)
                set s__Armageddon__Armageddon_centerY[dex]=GetUnitY(source)
//#         else
//#             set dex.centerX = GetSpellTargetX()
//#             set dex.centerY = GetSpellTargetY()
//#         endif
        // Run effects.
        set s__Armageddon__Armageddon_snd[dex]=Armageddon__GetSoundHandle()
        if s__Armageddon__Armageddon_snd[dex] != null then
            call SetSoundPosition(s__Armageddon__Armageddon_snd[dex], s__Armageddon__Armageddon_centerX[dex], s__Armageddon__Armageddon_centerY[dex], 0.)
        endif
        call DestroyEffect(AddSpecialEffect(Armageddon__ON_EFFECT_EVENT_FX, s__Armageddon__Armageddon_centerX[dex], s__Armageddon__Armageddon_centerY[dex]))
        set s__Armageddon__Armageddon_fx[dex]=AddSpecialEffectTarget(Armageddon__ON_CASTER_FX, source, Armageddon__CASTER_FX_ATTACH_POINT)
        // Start the spell.
        set s__Armageddon__Armageddon_interval[dex]=1. / IMaxBJ(1, s__Armageddon__Armageddon_count[dex])
        call TimerStart(s__Armageddon__Armageddon_clock[dex], s__Armageddon__Armageddon_interval[dex], true, function s__Armageddon__Armageddon_onPeriodic)
        
        set source=null
    endfunction
    
    function Armageddon__Init takes nothing returns nothing
        call RegisterSpellEffectEvent(Armageddon__ARMAGEDDON_ABILITY , function Armageddon__OnEffect)
    endfunction
// scope Armageddon ends
//===========================================================================
// Trigger: This Map only
//===========================================================================
//TESH.scrollpos=3
//TESH.alwaysfold=0
// scope map begins

    
        function s__map__preload_sfx takes nothing returns nothing
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Volcano\\VolcanoMissile.mdl", 2300, - 2900))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosTarget.mdl", 2300, - 2900))
        endfunction
    
    function s__map__xxx_spawn takes nothing returns nothing
        local integer i= 0
        local unit u
        loop
            exitwhen i == 4
            set u=CreateUnit(Player(1), 'hfoo', map__X, map__Y, 0)
            call IssuePointOrder(u, "attack", map__X0, map__Y0)
            set u=CreateUnit(Player(1), 'ehip', map__X, map__Y, 0)
            call IssuePointOrder(u, "attack", map__X0, map__Y0)
            set u=CreateUnit(Player(2), 'ugho', map__X0, map__Y0, 0)
            call IssuePointOrder(u, "attack", map__X, map__Y)
            set u=CreateUnit(Player(2), 'ugar', map__X0, map__Y0, 0)
            call IssuePointOrder(u, "attack", map__X, map__Y)
            set i=i + 1
        endloop
        set u=null
    endfunction
    
    function s__map__xxx_revive takes nothing returns boolean
        local player p= GetTriggerPlayer()
        local integer id= GetUnitTypeId(GetTriggerUnit())
        local unit u
        if p == Player(1) then
            set u=CreateUnit(p, id, map__X, map__Y, 0)
            call IssuePointOrder(u, "attack", map__X0, map__Y0)
        elseif p == Player(2) then
            set u=CreateUnit(p, id, map__X0, map__Y0, 0)
            call IssuePointOrder(u, "attack", map__X, map__Y)
        elseif GetTriggerUnit() == map__HERO then
            call ReviveHero(map__HERO, 0, 0, true)
        endif
        set u=null
        set p=null
        return false
    endfunction

    function s__map__xxx_reset takes nothing returns boolean
        call ClearTextMessages()
        call UnitResetCooldown(map__HERO)
        call SetUnitState(map__HERO, UNIT_STATE_MANA, GetUnitState(map__HERO, UNIT_STATE_MAX_MANA))
        return false
    endfunction
    
    function s__map__xxx_onInit takes nothing returns nothing
        local trigger t= CreateTrigger()
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH , function s__map__xxx_revive)
        call s__map__xxx_spawn()
        set map__HERO=CreateUnit(Player(0), 'Hblm', 0, 0, 0)
        //set HERO2   = CreateUnit(Player(0), 'Uktl', 0,0,0)
        call SetHeroLevel(map__HERO, 12, true)
        //call SetHeroLevel(HERO2, 12, true)
        call FogModifierStart(CreateFogModifierRect(Player(0), FOG_OF_WAR_VISIBLE, GetWorldBounds(), false, false))
        call TriggerRegisterPlayerEventEndCinematic(t, Player(0))
        call TriggerAddCondition(t, Condition(function s__map__xxx_reset))
        call BJDebugMsg("Press |cffdaa520ESC|r to reset cooldowns and refresh mana")
        set t=null
        call s__map__preload_sfx()
    endfunction
// scope map ends

//===========================================================================
function InitCustomTriggers takes nothing returns nothing
    //Function not found: call InitTrig_Missile()
    //Function not found: call InitTrig_TimerUtils()
    //Function not found: call InitTrig_SpellEffectEvent()
    //Function not found: call InitTrig_RegisterPlayerUnitEvent()
    //Function not found: call InitTrig_WorldBounds()
    //Function not found: call InitTrig_IsDestructableTree()
    //Function not found: call InitTrig_Armageddon()
    //Function not found: call InitTrig_This_Map_only()
endfunction

//***************************************************************************
//*
//*  Players
//*
//***************************************************************************

function InitCustomPlayerSlots takes nothing returns nothing

    // Player 0
    call SetPlayerStartLocation(Player(0), 0)
    call SetPlayerColor(Player(0), ConvertPlayerColor(0))
    call SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(0), true)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)

endfunction

function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_002
    call SetPlayerTeam(Player(0), 0)

endfunction

//***************************************************************************
//*
//*  Main Initialization
//*
//***************************************************************************

//===========================================================================
function main takes nothing returns nothing
    call SetCameraBounds(- 3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCAshenvale\\DNCAshenvaleTerrain\\DNCAshenvaleTerrain.mdl", "Environment\\DNC\\DNCAshenvale\\DNCAshenvaleUnit\\DNCAshenvaleUnit.mdl")
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("AshenvaleDay")
    call SetAmbientNightSound("AshenvaleNight")
    call SetMapMusic("Music", true, 0)
    call InitSounds()
    call CreateAllUnits()
    call InitBlizzard()

call ExecuteFunc("jasshelper__initstructs144584265")
call ExecuteFunc("TimerUtils__init")
call Armageddon__Init()

    call InitGlobals()
    call InitCustomTriggers()

endfunction

//***************************************************************************
//*
//*  Map Configuration
//*
//***************************************************************************

function config takes nothing returns nothing
    call SetMapName("TRIGSTR_018")
    call SetMapDescription("TRIGSTR_020")
    call SetPlayers(1)
    call SetTeams(1)
    call SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)

    call DefineStartLocation(0, - 512.0, - 768.0)

    // Player setup
    call InitCustomPlayerSlots()
    call SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
    call InitGenericPlayerSlots()
endfunction




//Struct method generated initializers/callers:

//Functions for BigArrays:
function sa___prototype2_TimerUtils__init takes nothing returns boolean

     local integer i=0
     local integer o=- 1
     local boolean oops= false
        if ( TimerUtils__didinit ) then
    return true
        else
            set TimerUtils__didinit=true
        endif
                set TimerUtils__ht=InitHashtable()
                loop
                    exitwhen ( i == TimerUtils__QUANTITY )
                    set s__TimerUtils__tT[i]= CreateTimer()
                    call SetTimerData(s__TimerUtils__tT[i] , TimerUtils__HELD)
                    set i=i + 1
                endloop
                set TimerUtils__tN=TimerUtils__QUANTITY
    return true
endfunction

function jasshelper__initstructs144584265 takes nothing returns nothing
    set st___prototype2[1]=CreateTrigger()
    call TriggerAddAction(st___prototype2[1],function sa___prototype2_TimerUtils__init)
    call TriggerAddCondition(st___prototype2[1],Condition(function sa___prototype2_TimerUtils__init))

call ExecuteFunc("s__IsDestructableTree__I_IsDestructableTree__Inits__onInit")

call ExecuteFunc("s__WorldBounds_WorldBounds__WorldBoundInit__onInit")




call ExecuteFunc("s__SpellEffectEvent__S_SpellEffectEvent__M__onInit")

call ExecuteFunc("s__Armageddon__Meteor_MissileStruct__onInit")




    call ExecuteFunc("s__Missile_onInit")
    call ExecuteFunc("s__map__xxx_onInit")
endfunction

