globals
//globals from DemoMap:
constant boolean LIBRARY_DemoMap=true
real DemoMap___X= - 1500
real DemoMap___Y= - 2280
real DemoMap___X0= 1177
real DemoMap___Y0= 1370
unit DemoMap_HERO
//endglobals from DemoMap
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
    
        
constant real Missile_TIMER_TIMEOUT= 0.031250000
        
         
constant player Missile_NEUTRAL_PASSIVE= Player(PLAYER_NEUTRAL_PASSIVE)
        
        
constant integer Missile_DUMMY_UNIT_ID= 'h000'
    
        
constant real Missile_MAXIMUM_COLLISION_SIZE= 197.
        
        
//      Set booleans listed below to "true" and the compiler will write 
//      the feature into your map. Otherwise this code is completly ignored.                                        
//          o Yay, I want that           --> "true"
//          o Naah that's useless for me --> "false"

        
constant boolean Missile_USE_DESTRUCTABLE_FILTER= true
        
        
constant boolean Missile_USE_COLLISION_Z_FILTER= true
        
        
constant boolean Missile_WRITE_DELAYED_MISSILE_RECYCLING= true
        
        
constant real Missile__DELAYED_MISSILE_DEATH_ANIMATION_TIME= 2.
trigger Missile__core= CreateTrigger()
timer Missile__clock= CreateTimer()
integer Missile__active= 0
        
integer array Missile__instances
integer array Missile__missileStack
boolexpr array Missile__expression
triggercondition array Missile__condition
//endglobals from Missile
//globals from Hydra:
constant boolean LIBRARY_Hydra=true
        // Constants required in Hydra.
constant real Hydra__TWO_PI= bj_PI * 2
constant real Hydra__DEFAULT_BODYSIZE= 48.
constant integer Hydra__LOCUST= 'Aloc'
constant integer Hydra__TIMED_LIFE= 'BTLF'
constant integer Hydra__CROW_FORM= 'Amrf'
constant string Hydra__ATTACK= "attack "
constant string Hydra__BIRTH= "birth "
constant string Hydra__STAND= "stand "
constant timer Hydra__STAMP= CreateTimer()
        // Available animationSuffixes. Global for ever unit type.
string array Hydra__animationSuffix
        
        // Tracks how many Hydra instances are allocated
integer Hydra__allocCount= 0
//endglobals from Hydra
//globals from IceHydra:
constant boolean LIBRARY_IceHydra=true
constant integer IceHydra___HYDRA_ABILITY= 'A000'
constant integer IceHydra___HYDRA_UNIT_ID= 'o000'
//endglobals from IceHydra
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
unit udg_BS_Target= null
unit udg_BS_Caster= null
player udg_BS_Player= null

    // Generated
rect gg_rct_Region_000= null
trigger gg_trg_Missile= null
trigger gg_trg_TimerUtils= null
trigger gg_trg_World_Bounds= null
trigger gg_trg_Error_Message= null
trigger gg_trg_Hydra= null
trigger gg_trg_Hydra_Template= null
trigger gg_trg_Fire_Hydra= null
trigger gg_trg_Ice_Hydra= null
trigger gg_trg_Friendly_Hydra= null
trigger gg_trg_Easter_Egg= null
trigger gg_trg_Hill_Guardian= null
trigger gg_trg_This_Map_only= null
trigger gg_trg_Hydra_Copy= null
trigger gg_trg_New_Structure= null
constant integer FireHydra___HYDRA_ABILITY= 'A002'
constant integer FireHydra___HYDRA_UNIT_ID= 'o002'
constant integer FriendlyHydra___HYDRA_ABILITY= 'A001'
constant integer FriendlyHydra___HYDRA_UNIT_ID= 'o002'
constant integer EasterEgg___HYDRA_ABILITY= 'A004'
constant integer EasterEgg___HYDRA_UNIT_ID= 'o001'
integer array EasterEgg___count
boolean EasterEgg___paused= false
unit HillGuard___REVENANT= null
boolean HillGuard___READY= true
integer HillGuard___GUARDIAN= 0

trigger l__library_init

//JASSHelper struct globals:
constant integer si__DemoMap___preload=1
constant integer si__DemoMap___xxx=2
constant integer si__WorldBounds=3
integer s__WorldBounds_maxX
integer s__WorldBounds_maxY
integer s__WorldBounds_minX
integer s__WorldBounds_minY
integer s__WorldBounds_centerX
integer s__WorldBounds_centerY
rect s__WorldBounds_world
region s__WorldBounds_worldRegion
constant integer si__Missile__RecycleBin=4
timer s__Missile__RecycleBin_t= CreateTimer()
integer s__Missile__RecycleBin_alloc= 0
unit array s__Missile__RecycleBin_dummy
real array s__Missile__RecycleBin_time
constant integer si__MissilePosition=5
integer array s__MissilePosition_recycler
integer s__MissilePosition_alloc= 0
location s__MissilePosition_loc= Location(0., 0.)
real array s__MissilePosition_x
real array s__MissilePosition_y
real array s__MissilePosition_z
real array s__MissilePosition_angle
real array s__MissilePosition_distance
real array s__MissilePosition_slope
real array s__MissilePosition_alpha
integer array s__MissilePosition_ref
constant integer si__Missile=6
integer s__Missile_Missile__MissileStructure__collectionCount= 0
integer s__Missile_Missile__MissileStructure__nodeCount= 0
integer array s__Missile_Missile__MissileStructure___list
integer array s__Missile_Missile__MissileStructure___next
integer array s__Missile_Missile__MissileStructure___prev
integer array s__Missile_Missile__MissileStructure___first
integer array s__Missile_Missile__MissileStructure___last
constant boolean s__Missile_MORE_SAFETY= false
boolean array s__Missile_launched
constant string s__Missile_ORIGIN= "origin"
constant real s__Missile_HIT_BOX= ( 2. / 3. )
group s__Missile_enumGroup= CreateGroup()
boolean array s__Missile_allocated
effect array s__Missile_sfx
string array s__Missile_path
real array s__Missile_missileScale
real array s__Missile_angle
real array s__Missile_xPrivate
real array s__Missile_yPrivate
integer array s__Missile_origin
integer array s__Missile_impact
real array s__Missile_terrainZ
real array s__Missile_x
real array s__Missile_y
real array s__Missile_z
unit array s__Missile_dummy
group array s__Missile_unitsHit
boolean array s__Missile_wantDestroy
boolean array s__Missile_recycle
real array s__Missile_distance
unit array s__Missile_target
unit array s__Missile_source
player array s__Missile_owner
real array s__Missile_collision
real array s__Missile_collisionZ
real array s__Missile_speed
real array s__Missile_height
real array s__Missile_turn
real array s__Missile_open
real array s__Missile_damage
real array s__Missile_acceleration
integer array s__Missile_data
rect s__Missile_enumRect= Rect(0., 0., 0., 0.)
integer s__Missile_temp= 0
real s__Missile_tempDist= 0
constant integer si__Hydra__HydraHead=7
integer s__Hydra__HydraHead_Hydra__HydraStructure__collectionCount= 0
integer s__Hydra__HydraHead_Hydra__HydraStructure__nodeCount= 0
boolean array s__Hydra__HydraHead_Hydra__HydraStructure__isNode
boolean array s__Hydra__HydraHead_Hydra__HydraStructure__isCollection
integer array s__Hydra__HydraHead_size
integer array s__Hydra__HydraHead_Hydra__HydraStructure___list
integer array s__Hydra__HydraHead_Hydra__HydraStructure___next
integer array s__Hydra__HydraHead_Hydra__HydraStructure___prev
integer array s__Hydra__HydraHead_Hydra__HydraStructure___first
integer array s__Hydra__HydraHead_Hydra__HydraStructure___last
unit array s__Hydra__HydraHead_unit
unit array s__Hydra__HydraHead_target
real array s__Hydra__HydraHead_x
real array s__Hydra__HydraHead_y
real array s__Hydra__HydraHead_z
real array s__Hydra__HydraHead_unitZ
real array s__Hydra__HydraHead_lastShot
integer array s__Hydra__HydraHead_number
real array s__Hydra__HydraHead_aimX
real array s__Hydra__HydraHead_aimY
real array s__Hydra__HydraHead_aimZ
real array s__Hydra__HydraHead_aimAngle
constant integer si__Hydra=8
integer si__Hydra_F=0
integer si__Hydra_I=0
integer array si__Hydra_V
group s__Hydra_enu= CreateGroup()
group s__Hydra_grp= CreateGroup()
integer array s__Hydra_list
integer array s__Hydra_currentHead
integer array s__Hydra_nextShootingHead
timer array s__Hydra_shoot
timer array s__Hydra_lifeTimer
unit array s__Hydra_source
player array s__Hydra_owner
integer array s__Hydra_typeId
boolean array s__Hydra_summoned
real array s__Hydra_posX
real array s__Hydra_posY
real array s__Hydra_posZ
real array s__Hydra_angle
real array s__Hydra_timeScale
real array s__Hydra_interval
real array s__Hydra_headHeight
real array s__Hydra_attackSpeed
real array s__Hydra_attackRange
real array s__Hydra_bodysize
real array s__Hydra_birthAnimationTime
integer array s__Hydra_heads
boolean array s__Hydra_hasArcOrCurve
real array s__Hydra_attackPeriod_p
real array s__Hydra_animationTime_p
real array s__Hydra_animationTimeOriginal
real array s__Hydra_duration_p
real array s__Hydra_scale_p
real array s__Hydra_offset_p
constant integer si__IceHydra=9
constant integer si__FireHydra=10
constant integer si__FriendlyHydra=11
constant integer si__HammerTime=12
constant integer si__Guard=13
integer array s__TimerUtils__data
timer array s__TimerUtils__tT
trigger array st__Hydra_onSummonHead
trigger array st__Hydra_onRemoveHead
trigger array st__Hydra_onTargetFilter
trigger array st__Hydra_onFire
integer array si__Hydra_type
trigger array st__Hydra_onDestroy
trigger st__Hydra_attemptShoot
trigger st__Hydra_killHead
trigger st__Hydra_create
trigger array st___prototype6
unit f__arg_unit1
unit f__arg_unit2
player f__arg_player1
integer f__arg_integer1
real f__arg_real1
real f__arg_real2
real f__arg_real3
real f__arg_real4
real f__arg_real5
integer f__arg_this
boolean f__result_boolean
integer f__result_integer

endglobals
    native UnitAlive takes unit id returns boolean


//Generated method caller for Hydra.onSummonHead
function sc__Hydra_onSummonHead takes integer this,unit head returns nothing
    set f__arg_this=this
    set f__arg_unit1=head
    call TriggerEvaluate(st__Hydra_onSummonHead[si__Hydra_type[this]])
endfunction

//Generated method caller for Hydra.onRemoveHead
function sc__Hydra_onRemoveHead takes integer this,unit head returns nothing
    set f__arg_this=this
    set f__arg_unit1=head
    call TriggerEvaluate(st__Hydra_onRemoveHead[si__Hydra_type[this]])
endfunction

//Generated method caller for Hydra.onTargetFilter
function sc__Hydra_onTargetFilter takes integer this,unit target,player owner returns boolean
    set f__arg_this=this
    set f__arg_unit1=target
    set f__arg_player1=owner
    call TriggerEvaluate(st__Hydra_onTargetFilter[si__Hydra_type[this]])
 return f__result_boolean
endfunction

//Generated method caller for Hydra.onFire
function sc__Hydra_onFire takes integer this,unit shooter,unit target,integer missile returns nothing
    set f__arg_this=this
    set f__arg_unit1=shooter
    set f__arg_unit2=target
    set f__arg_integer1=missile
    call TriggerEvaluate(st__Hydra_onFire[si__Hydra_type[this]])
endfunction

//Generated method caller for Hydra.attemptShoot
function sc__Hydra_attemptShoot takes nothing returns nothing
    call TriggerEvaluate(st__Hydra_attemptShoot)
endfunction

//Generated method caller for Hydra.killHead
function sc__Hydra_killHead takes nothing returns nothing
    call TriggerEvaluate(st__Hydra_killHead)
endfunction

//Generated method caller for Hydra.create
function sc__Hydra_create takes unit whichUnit,integer unitId,real x,real y,real z,real face,real spawnInterval returns integer
    set f__arg_unit1=whichUnit
    set f__arg_integer1=unitId
    set f__arg_real1=x
    set f__arg_real2=y
    set f__arg_real3=z
    set f__arg_real4=face
    set f__arg_real5=spawnInterval
    call TriggerEvaluate(st__Hydra_create)
 return f__result_integer
endfunction

//Generated allocator of Hydra
function s__Hydra__allocate takes nothing returns integer
 local integer this=si__Hydra_F
    if (this!=0) then
        set si__Hydra_F=si__Hydra_V[this]
    else
        set si__Hydra_I=si__Hydra_I+1
        set this=si__Hydra_I
    endif
    if (this>8190) then
        call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,1000.,"Unable to allocate id for an object of type: Hydra")
        return 0
    endif

    set si__Hydra_type[this]=8
    set si__Hydra_V[this]=-1
 return this
endfunction

//Generated destructor of Hydra
function sc__Hydra_deallocate takes integer this returns nothing
    if this==null then
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,1000.,"Attempt to destroy a null struct of type: Hydra")
        return
    elseif (si__Hydra_V[this]!=-1) then
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,1000.,"Double free of type: Hydra")
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__Hydra_onDestroy[si__Hydra_type[this]])
    set si__Hydra_V[this]=si__Hydra_F
    set si__Hydra_F=this
endfunction

//Generated method caller for Guard.onTargetFilter
function sc__Guard_onTargetFilter takes integer this,unit target,player owner returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner)
endfunction

//Generated method caller for Guard.onFire
function sc__Guard_onFire takes integer this,unit shooter,unit target,integer missile returns nothing
    set f__arg_this=this
    set f__arg_unit1=shooter
    set f__arg_unit2=target
    set f__arg_integer1=missile
    call TriggerEvaluate(st__Hydra_onFire[13])
endfunction

//Generated allocator of Guard
function s__Guard__allocate takes unit whichUnit ,integer unitId ,real x ,real y ,real z ,real face ,real spawnInterval returns integer
 local integer this=sc__Hydra_create(whichUnit,unitId,x,y,z,face,spawnInterval)
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__Hydra_type[this]=13
    set kthis=this

 return this
endfunction


//Generated method caller for IceHydra.onFire
function sc__IceHydra_onFire takes integer this,unit shooter,unit target,integer missile returns nothing
    set f__arg_this=this
    set f__arg_unit1=shooter
    set f__arg_unit2=target
    set f__arg_integer1=missile
    call TriggerEvaluate(st__Hydra_onFire[9])
endfunction

//Generated method caller for IceHydra.onTargetFilter
function sc__IceHydra_onTargetFilter takes integer this,unit target,player owner returns boolean
            return UnitAlive(target) and IsUnitEnemy(target, owner)
endfunction

//Generated method caller for IceHydra.onRemoveHead
function sc__IceHydra_onRemoveHead takes integer this,unit head returns nothing
endfunction

//Generated method caller for IceHydra.onSummonHead
function sc__IceHydra_onSummonHead takes integer this,unit head returns nothing
endfunction

//Generated allocator of IceHydra
function s__IceHydra__allocate takes unit whichUnit ,integer unitId ,real x ,real y ,real z ,real face ,real spawnInterval returns integer
 local integer this=sc__Hydra_create(whichUnit,unitId,x,y,z,face,spawnInterval)
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__Hydra_type[this]=9
    set kthis=this

 return this
endfunction


//Generated method caller for FireHydra.onFire
function sc__FireHydra_onFire takes integer this,unit shooter,unit target,integer missile returns nothing
    set f__arg_this=this
    set f__arg_unit1=shooter
    set f__arg_unit2=target
    set f__arg_integer1=missile
    call TriggerEvaluate(st__Hydra_onFire[10])
endfunction

//Generated method caller for FireHydra.onTargetFilter
function sc__FireHydra_onTargetFilter takes integer this,unit target,player owner returns boolean
            return UnitAlive(target) and IsUnitEnemy(target, owner)
endfunction

//Generated method caller for FireHydra.onRemoveHead
function sc__FireHydra_onRemoveHead takes integer this,unit head returns nothing
endfunction

//Generated method caller for FireHydra.onSummonHead
function sc__FireHydra_onSummonHead takes integer this,unit head returns nothing
endfunction

//Generated allocator of FireHydra
function s__FireHydra__allocate takes unit whichUnit ,integer unitId ,real x ,real y ,real z ,real face ,real spawnInterval returns integer
 local integer this=sc__Hydra_create(whichUnit,unitId,x,y,z,face,spawnInterval)
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__Hydra_type[this]=10
    set kthis=this

 return this
endfunction


//Generated method caller for FriendlyHydra.onFire
function sc__FriendlyHydra_onFire takes integer this,unit shooter,unit target,integer missile returns nothing
    set f__arg_this=this
    set f__arg_unit1=shooter
    set f__arg_unit2=target
    set f__arg_integer1=missile
    call TriggerEvaluate(st__Hydra_onFire[11])
endfunction

//Generated method caller for FriendlyHydra.onTargetFilter
function sc__FriendlyHydra_onTargetFilter takes integer this,unit target,player owner returns boolean
            return UnitAlive(target) and IsUnitAlly(target, owner) and GetWidgetLife(target) != GetUnitState(target, UNIT_STATE_MAX_LIFE)
endfunction

//Generated method caller for FriendlyHydra.onRemoveHead
function sc__FriendlyHydra_onRemoveHead takes integer this,unit head returns nothing
endfunction

//Generated method caller for FriendlyHydra.onSummonHead
function sc__FriendlyHydra_onSummonHead takes integer this,unit head returns nothing
endfunction

//Generated allocator of FriendlyHydra
function s__FriendlyHydra__allocate takes unit whichUnit ,integer unitId ,real x ,real y ,real z ,real face ,real spawnInterval returns integer
 local integer this=sc__Hydra_create(whichUnit,unitId,x,y,z,face,spawnInterval)
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__Hydra_type[this]=11
    set kthis=this

 return this
endfunction


//Generated method caller for HammerTime.onFire
function sc__HammerTime_onFire takes integer this,unit shooter,unit target,integer missile returns nothing
    set f__arg_this=this
    set f__arg_unit1=shooter
    set f__arg_unit2=target
    set f__arg_integer1=missile
    call TriggerEvaluate(st__Hydra_onFire[12])
endfunction

//Generated method caller for HammerTime.onTargetFilter
function sc__HammerTime_onTargetFilter takes integer this,unit target,player owner returns boolean
            return UnitAlive(target) and IsUnitEnemy(target, owner)
endfunction

//Generated method caller for HammerTime.onRemoveHead
function sc__HammerTime_onRemoveHead takes integer this,unit head returns nothing
            call RemoveUnit(head)
endfunction

//Generated method caller for HammerTime.onSummonHead
function sc__HammerTime_onSummonHead takes integer this,unit head returns nothing
    set f__arg_this=this
    set f__arg_unit1=head
    call TriggerEvaluate(st__Hydra_onSummonHead[12])
endfunction

//Generated allocator of HammerTime
function s__HammerTime__allocate takes unit whichUnit ,integer unitId ,real x ,real y ,real z ,real face ,real spawnInterval returns integer
 local integer this=sc__Hydra_create(whichUnit,unitId,x,y,z,face,spawnInterval)
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__Hydra_type[this]=12
    set kthis=this

 return this
endfunction

function sc___prototype6_execute takes integer i returns nothing

    call TriggerExecute(st___prototype6[i])
endfunction
function sc___prototype6_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype6[i])

endfunction

//library DemoMap:

    
        function s__DemoMap___preload_sfx takes nothing returns nothing
            call RemoveUnit(CreateUnit(Player(15), 'o002', 0, 0, 0))
            call RemoveUnit(CreateUnit(Player(15), 'o000', 0, 0, 0))
            call RemoveUnit(CreateUnit(Player(15), 'o001', 0, 0, 0))
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", 0, 0))
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", 0, 0))
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl", 0, 0))
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl", 0, 0))
            call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl", 0, 0))
        endfunction
    
    function s__DemoMap___xxx_spawn takes nothing returns nothing
        local integer i= 0
        local unit u
        loop
            exitwhen i == 2
            set u=CreateUnit(Player(1), 'hfoo', DemoMap___X, DemoMap___Y, 0)
            call IssuePointOrder(u, "attack", DemoMap___X0, DemoMap___Y0)
            set u=CreateUnit(Player(1), 'ehpr', DemoMap___X, DemoMap___Y, 0)
            call IssuePointOrder(u, "attack", DemoMap___X0, DemoMap___Y0)
            set u=CreateUnit(Player(2), 'ugho', DemoMap___X0, DemoMap___Y0, 0)
            call IssuePointOrder(u, "attack", DemoMap___X, DemoMap___Y)
            set u=CreateUnit(Player(2), 'ugar', DemoMap___X0, DemoMap___Y0, 0)
            call IssuePointOrder(u, "attack", DemoMap___X, DemoMap___Y)
            set i=i + 1
        endloop
        set u=null
    endfunction
    
    function s__DemoMap___xxx_revive takes nothing returns boolean
        local player p= GetTriggerPlayer()
        local integer id= GetUnitTypeId(GetTriggerUnit())
        local unit u
        if p == Player(1) and GetUnitAbilityLevel(GetTriggerUnit(), 'Aloc') == 0 then
            set u=CreateUnit(p, id, DemoMap___X, DemoMap___Y, 0)
            call IssuePointOrder(u, "attack", DemoMap___X0, DemoMap___Y0)
        elseif p == Player(2) and GetUnitAbilityLevel(GetTriggerUnit(), 'Aloc') == 0 then
            set u=CreateUnit(p, id, DemoMap___X0, DemoMap___Y0, 0)
            call IssuePointOrder(u, "attack", DemoMap___X, DemoMap___Y)
        elseif GetTriggerUnit() == DemoMap_HERO then
            call ReviveHero(DemoMap_HERO, 0, 0, true)
        endif
        set u=null
        set p=null
        return false
    endfunction

    function s__DemoMap___xxx_reset takes nothing returns boolean
        call ClearTextMessages()
        call UnitResetCooldown(DemoMap_HERO)
        call SetUnitState(DemoMap_HERO, UNIT_STATE_MANA, GetUnitState(DemoMap_HERO, UNIT_STATE_MAX_MANA))
        return false
    endfunction
    
    function s__DemoMap___xxx_onInit takes nothing returns nothing
        local trigger t= CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
        call TriggerAddCondition(t, Condition(function s__DemoMap___xxx_revive))
        call s__DemoMap___xxx_spawn()
        set t=CreateTrigger()
        set DemoMap_HERO=CreateUnit(Player(0), 'Uktl', 0, 0, 0)
        call SetHeroLevel(DemoMap_HERO, 12, true)
        call FogModifierStart(CreateFogModifierRect(Player(0), FOG_OF_WAR_VISIBLE, s__WorldBounds_world, false, false))
        call TriggerRegisterPlayerEventEndCinematic(t, Player(0))
        call TriggerAddCondition(t, Condition(function s__DemoMap___xxx_reset))
        call BJDebugMsg("Press |cffdaa520ESC|r to reset cooldowns and refresh mana")
        set t=null
        call s__DemoMap___preload_sfx()
        call AddSpecialEffectTarget("UI\\Feedback\\SelectionCircleEnemy\\SelectionCircleEnemy.mdx", DemoMap_HERO, "origin")
    endfunction

//library DemoMap ends
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
                call sc___prototype6_evaluate(1)
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
        return 100. // LoadReal(hash, GetHandleId(whichUnit), KEY_UNIT_BODY_SIZE)<- Example
    endfunction

    
    function GetDestructableHeight takes destructable whichDestructable returns real
        return GetDestructableOccluderHeight(whichDestructable)
    endfunction
    


// Hello and welcome to Missile.
// I wrote a guideline for every piece of code inside Missile, so you 
// can easily understand how the code gets compiled and evaluated.
//
// Let's go!
       
    // If you set WRITE_DELAYED_MISSILE_RECYCLING from the configs to true, the compiler will write
    // a recycler bin, doing delayed dummy unit recycling, into Missle. 
    // If set to false, no code is created here as the code is ignored via "static if".
    //
    // The code of the macro is located at the bottom of Missile, as it would hurt read-ability if placed here.
//textmacro instance: WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")
//#     static if Missile_WRITE_DELAYED_MISSILE_RECYCLING then
            // In order to play a proper death animation,
            // RecycleBin to recycles missiles after 
            // DEFAULT_DEATH_ANIMATION_TIME
         
                function s__Missile__RecycleBin_handlerFunc takes nothing returns nothing
                    local integer index= 0
                    loop
                        exitwhen index == s__Missile__RecycleBin_alloc
                        set s__Missile__RecycleBin_time[index]=s__Missile__RecycleBin_time[index] - 1
                        if ( 0 >= s__Missile__RecycleBin_time[index] ) then
                        
//#                         static if LIBRARY_MissileRecycler then
//#                             call RecycleMissile(Missile__RecycleBin.dummy[index])
//#                     
//#                         elseif Dummy.create.exists and LIBRARY_Dummy then
//#                             call Dummy[Missile__RecycleBin.dummy[index]].destroy()
//#                         
//#                         elseif LIBRARY_xedummy and xedummy.release.exists then
//#                             call xedummy.release(Missile__RecycleBin.dummy[index])
//#                     
//#                         else
                                call RemoveUnit(s__Missile__RecycleBin_dummy[index])
//#                         endif
                        
                            set s__Missile__RecycleBin_dummy[index]=null
                            set s__Missile__RecycleBin_alloc=s__Missile__RecycleBin_alloc - 1
                            set s__Missile__RecycleBin_dummy[index]=s__Missile__RecycleBin_dummy[s__Missile__RecycleBin_alloc]
                            set s__Missile__RecycleBin_time[index]=s__Missile__RecycleBin_time[s__Missile__RecycleBin_alloc]
                            set s__Missile__RecycleBin_dummy[s__Missile__RecycleBin_alloc]=null
                            set index=index - 1
                        
                            if ( 0 == s__Missile__RecycleBin_alloc ) then
                                call PauseTimer(s__Missile__RecycleBin_t)
                            endif
                        
                        endif
                        set index=index + 1
                    endloop
                endfunction
        
                function s__Missile__RecycleBin_recycle takes unit toRecycle returns nothing
                    if ( 0 == s__Missile__RecycleBin_alloc ) then
                        call TimerStart(s__Missile__RecycleBin_t, 1., true, function s__Missile__RecycleBin_handlerFunc)
                    endif
                    set s__Missile__RecycleBin_dummy[s__Missile__RecycleBin_alloc]=toRecycle
                    set s__Missile__RecycleBin_time[s__Missile__RecycleBin_alloc]=Missile__DELAYED_MISSILE_DEATH_ANIMATION_TIME + TimerGetRemaining(s__Missile__RecycleBin_t)
                    set s__Missile__RecycleBin_alloc=s__Missile__RecycleBin_alloc + 1
                endfunction
        
//#     endif
//end of: WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")
    
    function Missile_GetLocZ takes real x,real y returns real
        call MoveLocation(s__MissilePosition_loc, x, y)
        return GetLocationZ(s__MissilePosition_loc)
    endfunction
    
    // This macro boxes a missiles positions and does the required trigonometry.
    //
    // The code of the macro is located at the bottom of Missile, as it would hurt read-ability if placed here.
//textmacro instance: WRITE_MISSILE_POSITION_CODE()
            
            
            
            function s__MissilePosition_math takes integer a,integer b returns boolean
                set s__MissilePosition_angle[a]=Atan2(s__MissilePosition_y[b] - s__MissilePosition_y[a], s__MissilePosition_x[b] - s__MissilePosition_x[a])
                set s__MissilePosition_distance[a]=SquareRoot(( s__MissilePosition_x[b] - s__MissilePosition_x[a] ) * ( s__MissilePosition_x[b] - s__MissilePosition_x[a] ) + ( s__MissilePosition_y[b] - s__MissilePosition_y[a] ) * ( s__MissilePosition_y[b] - s__MissilePosition_y[a] ))
                if ( s__MissilePosition_distance[a] != 0 ) then
                    set s__MissilePosition_slope[a]=( s__MissilePosition_z[b] - s__MissilePosition_z[a] ) / s__MissilePosition_distance[a]
                else // Error! I decide we do this math again!
                    set s__MissilePosition_x[a]=s__MissilePosition_x[a] + .0001
                    return false
                endif
                set s__MissilePosition_alpha[a]=Atan(s__MissilePosition_slope[a]) * bj_RADTODEG
                
                set s__MissilePosition_angle[b]=s__MissilePosition_angle[a] + bj_PI
                set s__MissilePosition_distance[b]=s__MissilePosition_distance[a]
                set s__MissilePosition_slope[b]=- s__MissilePosition_slope[a]
                set s__MissilePosition_alpha[b]=- s__MissilePosition_alpha[a]
                return true
            endfunction
            
            function s__MissilePosition_link takes integer a,integer b returns nothing
                set s__MissilePosition_ref[a]=b
                set s__MissilePosition_ref[b]=a
                loop
                    exitwhen s__MissilePosition_math(a , b)
                endloop
            endfunction
            
            function s__MissilePosition_move takes integer this,real toX,real toY,real toZ returns nothing
                call MoveLocation(s__MissilePosition_loc, toX, toY)
                set s__MissilePosition_x[this]=toX
                set s__MissilePosition_y[this]=toY
                set s__MissilePosition_z[this]=toZ + GetLocationZ(s__MissilePosition_loc)
                if ( s__MissilePosition_ref[this] != this ) then
                    loop
                        exitwhen s__MissilePosition_math(this , s__MissilePosition_ref[this])
                    endloop
                endif
            endfunction
    
            function s__MissilePosition_destroy takes integer this returns nothing
                set s__MissilePosition_recycler[this]=s__MissilePosition_recycler[0]
                set s__MissilePosition_recycler[0]=this
            endfunction
    
            function s__MissilePosition_create takes real x,real y,real z returns integer
                local integer this= s__MissilePosition_recycler[0]
                 if ( 0 == this ) then
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
    
    // keywords are replaced directives for a scope.
    // Missiles structure works like a list with the folling methods:
    // allocateCollection(), allocateNode(), insertEnd(node) and remove()
    //
    // MissileStructure is implemented as a module
    // The code is located at the bottom of Missile, as it would also hurt read-ability if placed here.
//Implemented from module Missile__MissileStructure:
        
//#         static if LIBRARY_ErrorMessage then
//#              private boolean Missile__MissileStructure__isNode
//#              private boolean Missile__MissileStructure__isCollection
//#         endif
        
        function s__Missile__get_list takes integer this returns integer
//#             static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
//#                  call ThrowError(this == 0,    "MissileStructure", "list", "Missile", this, "Attempted To Read Null Node.")
//#                  call ThrowError(not Missile__MissileStructure__isNode,   "MissileStructure", "list", "Missile", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile__MissileStructure___list[this]
        endfunction
        
        function s__Missile__get_next takes integer this returns integer
//#             static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
//#                  call ThrowError(this == 0,    "MissileStructure", "next", "Missile", this, "Attempted To Go Out Of Bounds.")
//#                  call ThrowError(not Missile__MissileStructure__isNode,   "MissileStructure", "next", "Missile", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile__MissileStructure___next[this]
        endfunction
        
        function s__Missile__get_prev takes integer this returns integer
//#             static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
//#                  call ThrowError(this == 0,    "MissileStructure", "prev", "Missile", this, "Attempted To Go Out Of Bounds.")
//#                  call ThrowError(not Missile__MissileStructure__isNode,   "MissileStructure", "prev", "Missile", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile__MissileStructure___prev[this]
        endfunction
        
        function s__Missile__get_first takes integer this returns integer
//#             static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
//#                  call ThrowError(this == 0,        "MissileStructure", "first", "Missile", this, "Attempted To Read Null List.")
//#                  call ThrowError(not Missile__MissileStructure__isCollection, "MissileStructure", "first", "Missile", this, "Attempted To Read Invalid List.")
//#             endif
            return s__Missile_Missile__MissileStructure___first[this]
        endfunction
        
        function s__Missile__get_last takes integer this returns integer
//#             static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
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
            
            return this
        endfunction
        
        function s__Missile_insertEnd takes integer this,integer node returns integer
            
//#             static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
//#                  call ThrowError(this == 0,        "MissileStructure", "enqueue", "Missile", this, "Attempted To Enqueue On To Null List.")
//#                  call ThrowError(not Missile__MissileStructure__isCollection, "MissileStructure", "enqueue", "Missile", this, "Attempted To Enqueue On To Invalid List.")
//#                  set node.Missile__MissileStructure__isNode = true
//#             endif
            
            
            set s__Missile_Missile__MissileStructure___list[node]=this
        
            if ( s__Missile_Missile__MissileStructure___first[this] == 0 ) then
                set s__Missile_Missile__MissileStructure___first[this]=node
                set s__Missile_Missile__MissileStructure___last[this]=node
                set s__Missile_Missile__MissileStructure___prev[node]=0
            else
                set s__Missile_Missile__MissileStructure___next[s__Missile_Missile__MissileStructure___last[this]]=node
                set s__Missile_Missile__MissileStructure___prev[node]=s__Missile_Missile__MissileStructure___last[this]
                set s__Missile_Missile__MissileStructure___last[this]=node
            endif
            
            set s__Missile_Missile__MissileStructure___next[node]=0
            
            return node
        endfunction
        
        function s__Missile_remove takes integer this returns nothing
            local integer node= this
            set this=s__Missile_Missile__MissileStructure___list[node]
            
//#             static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
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
        endfunction
        
        // I included enormous debug safety to Missile, 
        // in order to eradicate wrong user usage.
        // You should do this with every system you write. 
        //
        // Set MORE_SAFETY to false, once major mistakes are
        // purged from your code. It will create a more realistic
        // performance to a non DEBUG_MODE code, because many
        // error checks are then excluded via "static if".
        // 
        // Placed here on purpose, to ensure that less experienced users
        // recieve the full range of debug features. Basically they will
        // never find this constant boolean :)!
        
        // launched prevents double launching! Very logical. DEBUG_MODE only.
        
        // Effect attach point name. Read-only for shared usage in your map.
        // Of course only if you read until here :)!
        
        // Defines a default unit hit box in range of 0 to 1,
        // while 0 is the toe and 1 the head of a unit.
        
        // Please do not use this group from somewhere else,
        // as it may conflict with Missiles code execution.
        // Rather go with bj_lastCreatedGroup.
        
        // Prevents a double free case.
        
        // Useful struct members. Names chosen to be self-explaining.
        
        
        
        // For curved missiles the position of a missile is not
        // equal to the x/y required by Missiles trigonometry.
        // Therefore we need this member two times.
        // x/y/z for your needs and xPrivate/yPrivate for cool mathematics.
        

        // wantDestroy deallocates an instance on the next
        // timer callback. 100% safe to use.
        
        // recycle is set to true, when a missile reached
        // it's destination. Then it may be destroyed.
        
        // distance traveled.
        
        // Members for your needs.
        // No operator overloading, expect in a few cases.
        
        // As the dummy always belongs to the neutral player.
        // You can add a pseudo owner for faster onCollide evaluation.
        // No monitoring or nulling included. Use carefully.

// I really don't know how wc3 works with negative collision values. (bug free???)
// So I decided to monitor collision and eventually collisionZ.

//# static if true and LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
//# 
//#         // operators allow us to check for invalid arguments like value < 0
//#          private real collisionDebug
//#         method operator collision= takes real value returns nothing
//#              call ThrowError((value < 0), "Missile", "collision=", "collision", this, "Found Collision Below Zero [" + R2S(value) + "]!")
//#              set collisionDebug = value
//#         endmethod
//#         method operator collision takes nothing returns real
//#              return collisionDebug
//#         endmethod
//#         
//#         // Same applies for collisionZ
//#         static if Missile_USE_COLLISION_Z_FILTER then
//#              private real collisionZDebug
//#             method operator collisionZ= takes real value returns nothing
//#                  call ThrowError((value < 0), "Missile", "collisionZ=", "collisionZ", this, "Found CollisionZ Below Zero [" + R2S(value) + "]!")
//#                  set collisionZDebug = value
//#             endmethod
//#             method operator collisionZ takes nothing returns real
//#                  return collisionZDebug
//#             endmethod        
//#         endif
//# else
    
    // Without debug mode we give a shit on monitoring!
    
//#     static if Missile_USE_COLLISION_Z_FILTER then
//#     endif
//# endif

// Speed determines the lenght of our vector for Missile movement.
// Non positive values and zero are invalid. So let's monitor again.

//# static if true and LIBRARY_ErrorMessage then
//#          private real speedDebug
//#         method operator speed= takes real value returns nothing
//#              call ThrowError((value <= 0), "Missile", "speed=", "speed", this, "Speed Values Below Or Equal To Zero Are Not Allowed [" + R2S(value) + "]!")
//#             set speedDebug = value
//#         endmethod
//#         method operator speed takes nothing returns real
//#             return speedDebug
//#         endmethod
//# else
//# endif

        
        // You can attach any data to a missile.
        
        // Dummy is readonly so you can add more than one model.
        function s__Missile__set_model takes integer this,string modelFile returns nothing
            if ( s__Missile_sfx[this] != null ) then
                call DestroyEffect(s__Missile_sfx[this])
            endif
            set s__Missile_path[this]=modelFile
            set s__Missile_sfx[this]=AddSpecialEffectTarget(modelFile, s__Missile_dummy[this], s__Missile_ORIGIN)
        endfunction
        function s__Missile__get_model takes integer this returns string
            return s__Missile_path[this]
        endfunction
       
        // Simple trigonometry, some values will freak out the missile movement.
        function s__Missile__set_curve takes integer this,real value returns nothing
            set s__Missile_open[this]=Tan(value) * s__MissilePosition_distance[s__Missile_origin[this]]
        endfunction
        function s__Missile__get_curve takes integer this returns real
            if ( s__MissilePosition_distance[s__Missile_origin[this]] == 0 ) then
                return 0. // It's a limit of sequence and crashes the thread. Intuitively  chosen 0.
            endif
            return Atan(s__Missile_open[this] / s__MissilePosition_distance[s__Missile_origin[this]])
        endfunction
       
        // Simple trigonometry, some values will freak out the missile movement.
        function s__Missile__set_arc takes integer this,real value returns nothing
            set s__Missile_height[this]=Tan(value) * s__MissilePosition_distance[s__Missile_origin[this]] / 4
        endfunction
        function s__Missile__get_arc takes integer this returns real
            if ( s__MissilePosition_distance[s__Missile_origin[this]] == 0 ) then
                return 0. // It's a limit of sequence and crashes the thread. Intuitively  chosen 0.
            endif
            return Atan(4 * s__Missile_height[this] / s__MissilePosition_distance[s__Missile_origin[this]])
        endfunction
       
        function s__Missile__set_scale takes integer this,real value returns nothing
            call SetUnitScale(s__Missile_dummy[this], value, 1., 1.)
            set s__Missile_missileScale[this]=value
        endfunction
        function s__Missile__get_scale takes integer this returns real
            return s__Missile_missileScale[this]
        endfunction
    
        function s__Missile_bounce takes integer this returns nothing
            call s__MissilePosition_move(s__Missile_origin[this],s__Missile_xPrivate[this] , s__Missile_yPrivate[this] , s__Missile_z[this])
            set s__Missile_distance[this]=0
        endfunction
       
        function s__Missile_deflect takes integer this,real tx,real ty returns nothing
            local real a= 2 * Atan2(ty - s__Missile_yPrivate[this], tx - s__Missile_xPrivate[this]) + bj_PI - s__Missile_angle[this]
            call s__MissilePosition_move(s__Missile_impact[this],s__Missile_xPrivate[this] + ( s__MissilePosition_distance[s__Missile_origin[this]] - s__Missile_distance[this] ) * Cos(a) , s__Missile_yPrivate[this] + ( s__MissilePosition_distance[s__Missile_origin[this]] - s__Missile_distance[this] ) * Sin(a) , s__MissilePosition_z[s__Missile_impact[this]])
            call s__Missile_bounce(this)
        endfunction
        
        function s__Missile_deflectEx takes integer this,real tx,real ty,real tz returns nothing
            call s__MissilePosition_move(s__Missile_impact[this],s__MissilePosition_x[s__Missile_impact[this]] , s__MissilePosition_y[s__Missile_impact[this]] , tz)
            call s__Missile_deflect(this,tx , ty)
        endfunction
    
        function s__Missile_flightTime2Speed takes integer this,real duration returns nothing
            set s__Missile_speed[this]=RMaxBJ(0.00000001, ( s__MissilePosition_distance[s__Missile_origin[this]] - s__Missile_distance[this] ) * Missile_TIMER_TIMEOUT / duration)
        endfunction
    
        // I would expect more from a destroy method :)!
        function s__Missile_destroy takes integer this returns nothing
            set s__Missile_wantDestroy[this]=true
        endfunction
    
        // As user you shouldn't have access to .remove(), so you can use .terminate() instead.
        function s__Missile_terminate takes integer this returns nothing
            set s__Missile_allocated[this]=false
            call DestroyEffect(s__Missile_sfx[this])
            
//#             static if LIBARARY_GroupUtils then
//#                 call ReleaseGroup(unitsHit)
//#             else
                    call DestroyGroup(s__Missile_unitsHit[this])
//#             endif
           
            if ( GetUnitTypeId(s__Missile_dummy[this]) == Missile_DUMMY_UNIT_ID ) then
//#                 static if LIBRARY_MissileRecycler then
//#                     call RecycleMissile(dummy)
//#                 
//#                 elseif Dummy.create.exists and LIBRARY_Dummy then
//#                     call Dummy[dummy].destroy()
//#                     
//#                 elseif LIBRARY_xedummy and xedummy.release.exists then
//#                     call xedummy.release(dummy)
//#                     
//#                 else
                        call RemoveUnit(s__Missile_dummy[this])
//#                 endif
            endif
           
            set s__Missile_recycle[this]=false
            set s__Missile_sfx[this]=null
            set s__Missile_unitsHit[this]=null
            set s__Missile_source[this]=null
            set s__Missile_target[this]=null
            set s__Missile_dummy[this]=null
           
            call s__MissilePosition_destroy(s__Missile_impact[this])
            call s__MissilePosition_destroy(s__Missile_origin[this])
           
            call s__Missile_remove(this)
        endfunction
    
        // Freaky static if ensures these libraries really don't exist.
//#         static if not LIBRARY_MissileRecycler and not LIBRARY_Dummy and not Dummy.create.exists and not LIBRARY_xe_dummy and not xe_dummy.new.exists then
                function s__Missile_newMissileUnit takes real x,real y,real face returns unit
                    // Just in case you have UnitIndexer.
//#                 static if LIBRARY_UnitIndexer then
//#                     set UnitIndexer.enabled = false
//#                 endif
                    set bj_lastCreatedUnit=CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, x, y, face)
                    call SetUnitX(bj_lastCreatedUnit, x)
                    call SetUnitY(bj_lastCreatedUnit, y)
                    call PauseUnit(bj_lastCreatedUnit, true)
//#                 static if LIBRARY_UnitIndexer then
//#                     set UnitIndexer.enabled = true
//#                 endif
                    return bj_lastCreatedUnit
                endfunction
//#         endif
    
        function s__Missile_create takes real originX,real originY,real originZ,real angleP,real distanceP,real impactZ returns integer
            local integer this= s__Missile_allocateNode()
            set s__Missile_origin[this]=s__MissilePosition_create(originX , originY , originZ)
            set s__Missile_impact[this]=s__MissilePosition_create(originX + distanceP * Cos(angleP) , originY + distanceP * Sin(angleP) , impactZ)
            call s__MissilePosition_link(s__Missile_origin[this] , s__Missile_impact[this])
            
            set s__Missile_collision[this]=0
//#             static if Missile_USE_COLLISION_Z_FILTER then
                    set s__Missile_collisionZ[this]=0
//#             endif
            
            set s__Missile_acceleration[this]=0
            set s__Missile_height[this]=0
            set s__Missile_turn[this]=0
            set s__Missile_open[this]=0
            
            set s__Missile_recycle[this]=false
            set s__Missile_wantDestroy[this]=false
            set s__Missile_path[this]=""
            
            set s__Missile_xPrivate[this]=originX
            set s__Missile_yPrivate[this]=originY
            set s__Missile_z[this]=s__MissilePosition_z[s__Missile_origin[this]]
            set s__Missile_angle[this]=angleP
            set s__Missile_distance[this]=0
            
//#             static if LIBRARY_MissileRecycler then
//#                 set dummy = GetRecycledMissile(originX, originY, originZ, angleP*bj_RADTODEG)
//# 
//#             elseif LIBRARY_Dummy and Dummy.create.exists then
//#                 set dummy = Dummy.create(originX, originY, angleP*bj_RADTODEG).unit
//# 
//#             elseif LIBRARY_xedummy and xedummy.new.exists then
//#                 set dummy = xedummy.new(Missile_NEUTRAL_PASSIVE, originX, originY, angleP*bj_RADTODEG)
//#             
//#             else
                    set s__Missile_dummy[this]=s__Missile_newMissileUnit(originX , originY , angleP * bj_RADTODEG)
//#             endif

            set s__Missile_allocated[this]=true
            
//#             static if LIBRARY_GroupUtils then
//#                 set unitsHit    = NewGroup()
//#             else
                    set s__Missile_unitsHit[this]=CreateGroup()
//#             endif
            
            call MoveLocation(s__MissilePosition_loc, originX, originY)
            call SetUnitFlyHeight(s__Missile_dummy[this], s__MissilePosition_z[s__Missile_origin[this]] - GetLocationZ(s__MissilePosition_loc), 0.)
            
             set s__Missile_launched[this]=false
            return this
        endfunction
    
        // Currently a private method. In future updates it will be public again and similiar
        // to create(), but you can pass in any existing unit, instead poping a dummy unit from the stack.
         function s__Missile_createEx takes unit missileDummy,real impactX,real impactY,real impactZ returns integer
            local integer this= s__Missile_allocateNode()
            local real originX= GetUnitX(missileDummy)
            local real originY= GetUnitY(missileDummy)
            local real originZ= GetUnitFlyHeight(missileDummy)
            set s__Missile_origin[this]=s__MissilePosition_create(originX , originY , originZ)
            set s__Missile_impact[this]=s__MissilePosition_create(impactX , impactY , impactZ)
            
            call s__MissilePosition_link(s__Missile_origin[this] , s__Missile_impact[this])
//#             static if true and LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
//#                  call ThrowError((GetUnitTypeId(missileDummy) == 0), "Missile", "createEx", "missileDummy", this, "Invalid Missile Dummy Unit (null)!")
//#             endif

            set s__Missile_collision[this]=0
//#             static if Missile_USE_COLLISION_Z_FILTER then
                    set s__Missile_collisionZ[this]=0
//#             endif
            
            set s__Missile_acceleration[this]=0
            set s__Missile_height[this]=0
            set s__Missile_turn[this]=0
            set s__Missile_open[this]=0
            
            set s__Missile_recycle[this]=false
            set s__Missile_wantDestroy[this]=false
            set s__Missile_path[this]=""
            
            set s__Missile_xPrivate[this]=originX
            set s__Missile_yPrivate[this]=originY
            set s__Missile_z[this]=originZ
            set s__Missile_angle[this]=s__MissilePosition_angle[s__Missile_origin[this]]
            set s__Missile_distance[this]=0
            set s__Missile_dummy[this]=missileDummy
            set s__Missile_allocated[this]=true
            
//#             static if LIBRARY_GroupUtils then
//#                 set unitsHit    = NewGroup()
//#             else
                    set s__Missile_unitsHit[this]=CreateGroup()
//#             endif
            
            call MoveLocation(s__MissilePosition_loc, originX, originY)
            call SetUnitFlyHeight(missileDummy, s__MissilePosition_z[s__Missile_origin[this]] - GetLocationZ(s__MissilePosition_loc), 0.)
            
             set s__Missile_launched[this]=false
            return this
        endfunction
        
        // This one is new. I think it is useful.
        function s__Missile_createXYZ takes real x,real y,real z,real impactX,real impactY,real impactZ returns integer
            local real angleP= Atan2(impactY - y, impactX - x)
            local real distance= SquareRoot(( x - impactX ) * ( x - impactX ) + ( y - impactY ) * ( y - impactY ))
            return s__Missile_create(x , y , z , angleP , distance , impactZ)
        endfunction
    
        // Periodic loop every 1/32 seconds. Runs once per active missile struct.
        function s__Missile_move takes integer this returns nothing
            local integer loc
            local real a
            local real d
            local real s
            local unit u
            
            local real h
            local real tx
            local real ty
            local real index
            
            loop
                exitwhen ( this == 0 )
                set loc=s__Missile_origin[this]
                set u=s__Missile_target[this]
                set h=s__Missile_height[this]
                
                // Missile target.
                if ( u != null ) then
                    if ( 0 != GetUnitTypeId(u) ) then
                        set tx=GetUnitX(u)
                        set ty=GetUnitY(u)
                        set a=Atan2(ty - s__Missile_yPrivate[this], tx - s__Missile_xPrivate[this])
                        // Does not hit the toe, but hits the chest.
                        // Why so? Because of HIT_BOX and GetUnitBodySize(u)
                        call s__MissilePosition_move(s__Missile_impact[this],tx , ty , GetUnitFlyHeight(u) + GetUnitBodySize(u) * s__Missile_HIT_BOX)
                        set s__Missile_distance[this]=s__MissilePosition_distance[loc] - SquareRoot(( tx - s__Missile_xPrivate[this] ) * ( tx - s__Missile_xPrivate[this] ) + ( ty - s__Missile_yPrivate[this] ) * ( ty - s__Missile_yPrivate[this] ))
                    else
                        set s__Missile_target[this]=null
                    endif
                else
                    set a=s__MissilePosition_angle[loc]
                endif
            
                // Missile turn
                if ( 0 != s__Missile_turn[this] ) and ( Cos(s__Missile_angle[this] - a) < Cos(s__Missile_turn[this]) ) then
                    if ( Sin(a - s__Missile_angle[this]) >= 0 ) then
                        set s__Missile_angle[this]=s__Missile_angle[this] + s__Missile_turn[this]
                    else
                        set s__Missile_angle[this]=s__Missile_angle[this] - s__Missile_turn[this]
                    endif
                else
                    set s__Missile_angle[this]=a
                endif
                
                set d=s__MissilePosition_distance[loc]
                set s=s__Missile_distance[this] + s__Missile_speed[this]
                set s__Missile_distance[this]=s
               
                set u=s__Missile_dummy[this]
               
                set tx=s__Missile_xPrivate[this] + s__Missile_speed[this] * Cos(s__Missile_angle[this])
                set ty=s__Missile_yPrivate[this] + s__Missile_speed[this] * Sin(s__Missile_angle[this])
                set s__Missile_speed[this]=s__Missile_speed[this] + s__Missile_acceleration[this]
                set s__Missile_xPrivate[this]=tx
                set s__Missile_yPrivate[this]=ty
            
                // Missile curve
                if ( s__Missile_open[this] != 0 ) then
                    set a=4 * s__Missile_open[this] * s * ( d - s ) / ( d * d )
                    set tx=tx + a * Cos(s__Missile_angle[this] + 1.57)
                    set ty=ty + a * Sin(s__Missile_angle[this] + 1.57)
                    call SetUnitFacing(u, ( s__Missile_angle[this] + Atan(- ( ( 4 * s__Missile_open[this] ) * ( 2 * s - d ) ) / ( d * d )) ) * bj_RADTODEG)
                else
                    call SetUnitFacing(u, s__Missile_angle[this] * bj_RADTODEG)
                endif
                
                // Missile x/y
                set s__Missile_x[this]=tx
                set s__Missile_y[this]=ty
                
//#                 static if not LIBRARY_BoundSentinel and LIBRARY_WorldBounds then
                        if ( tx > s__WorldBounds_maxX ) or ( tx < s__WorldBounds_minX ) or ( ty > s__WorldBounds_maxY ) or ( ty < s__WorldBounds_minY ) then
                            set s__Missile_wantDestroy[this]=true
                        else
                            call SetUnitX(u, tx)
                            call SetUnitY(u, ty)
                        endif
//#                 else
//#                     call SetUnitX(u, tx)
//#                     call SetUnitY(u, ty)
//#                 endif

                // Missile z
                call MoveLocation(s__MissilePosition_loc, tx, ty)
                set s__Missile_terrainZ[this]=GetLocationZ(s__MissilePosition_loc)
                if ( h != 0 ) or ( s__MissilePosition_slope[loc] != 0 ) then
                    set s__Missile_z[this]=s__MissilePosition_z[loc] - s__Missile_terrainZ[this] + s__MissilePosition_slope[loc] * s
                    set index=s__MissilePosition_alpha[loc]
                    if ( h != 0 ) then
                        set s__Missile_z[this]=s__Missile_z[this] + ( 4 * h * s * ( d - s ) / ( d * d ) )
                        set index=index - Atan(( ( 4 * h ) * ( 2 * s - d ) ) / ( d * d )) * bj_RADTODEG
                    endif
                    call SetUnitAnimationByIndex(u, R2I(index + 90.5))
                else
                    set s__Missile_z[this]=s__MissilePosition_z[loc] - s__Missile_terrainZ[this]
                endif
                call SetUnitFlyHeight(u, s__Missile_z[this], 0)
               
                if ( s >= d ) then
                    set s__Missile_recycle[this]=true
                endif
               
                set this=s__Missile__get_next(this)
            endloop
            set u=null
        endfunction
        
// Optional code stays optional.
//# static if Missile_USE_DESTRUCTABLE_FILTER then
    
            // After several test it turned out, that the square used in EnumDestructablesInRect leaves out
            // destructables which are within an appropriate range of the projectile.
            // Sadly there is no IsDestructableInRange native!!!
            function s__Missile_actionFuncDest takes nothing returns nothing
                local destructable d= GetEnumDestructable()
                local real xd= GetDestructableX(d)
                local real yd= GetDestructableY(d)
                local real dist= ( s__Missile_x[s__Missile_temp] - xd ) * ( s__Missile_x[s__Missile_temp] - xd ) + ( s__Missile_y[s__Missile_temp] - yd ) * ( s__Missile_y[s__Missile_temp] - yd )
//#             static if Missile_USE_COLLISION_Z_FILTER then
                    local real collideZ= Missile_GetLocZ(xd , yd) - s__Missile_terrainZ[s__Missile_temp]
                    if ( dist <= bj_enumDestructableRadius ) and ( collideZ + GetDestructableHeight(d) >= s__Missile_z[s__Missile_temp] - s__Missile_collisionZ[s__Missile_temp] ) and ( collideZ <= s__Missile_z[s__Missile_temp] + s__Missile_collisionZ[s__Missile_temp] ) then
                        if ( dist < s__Missile_tempDist ) then
                            set s__Missile_tempDist=dist
                            set bj_destRandomCurrentPick=d
                        endif
                    endif
//#             else
//#                 if (dist <= bj_enumDestructableRadius) then
//#                     if (dist < Missile.tempDist) then
//#                         set Missile.tempDist         = dist
//#                         set bj_destRandomCurrentPick = d
//#                     endif
//#                 endif                    
//#             endif
                set d=null
            endfunction
//# endif

//# static if Missile_WRITE_DELAYED_MISSILE_RECYCLING then
        function s__Missile_nullBefore takes integer this returns nothing
            set s__Missile_dummy[this]=null
        endfunction
//# endif

// Does not check for 'Aloc' and 'Amrf' as they could be customized.
//# static if Missile.MORE_SAFETY and true and LIBRARY_ErrorMessage then
//#     private static method onInit takes nothing returns nothing
//#         static if LIBRARY_UnitIndexer then
//#              set UnitIndexer.enabled = false
//#         endif
//#          set bj_lastCreatedUnit      = CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, 0, 0, 0)
//#          call ThrowError((GetUnitTypeId(bj_lastCreatedUnit) != Missile_DUMMY_UNIT_ID), "Missile", "DEBUG_MISSILE", "typeid",    0, "Missile Setup For DUMMY_UNIT_ID Is Incorrect! Map Can't Use Missile!")
//#          call ThrowError((Missile_MAXIMUM_COLLISION_SIZE < 0),                         "Missile", "DEBUG_MISSILE", "collision", 0, "Missile Setup For MAXIMUM_COLLISION_SIZE Is Incorrect, Below Zero! Map Can't Use Missile!")
//#          call RemoveUnit(bj_lastCreatedUnit)
//#          set bj_lastCreatedUnit      = null
//#         static if LIBRARY_UnitIndexer then
//#              set UnitIndexer.enabled = true
//#         endif
//#     endmethod
//# endif

    // You made it to the end of Missile, but we are not finished.
    // Do you remember about the data structure, the delayed recycler
    // and of course our interface module "MissileStruct"
    //
    // This comes now!
    
    
    // Debug code taken from List (credits to Nestharus)
    
    // Can private as the MissileStruct module is written here.
    
    function Missile__Fire takes nothing returns nothing
        call TriggerEvaluate(Missile__core)
    endfunction
    
    function Missile__MissileCreateExpression takes integer structId,code func returns nothing
        set Missile__expression[structId]=Condition(func)
    endfunction
    
    // Start timer if not already running.
    function Missile__StartPeriodic takes integer structId returns nothing
        if ( Missile__instances[structId] == 0 ) then
            set Missile__condition[structId]=TriggerAddCondition(Missile__core, Missile__expression[structId])
            if ( Missile__active == 0 ) then
                call TimerStart(Missile__clock, Missile_TIMER_TIMEOUT, true, function Missile__Fire)
            endif
            set Missile__active=Missile__active + 1
        endif
        set Missile__instances[structId]=Missile__instances[structId] + 1
    endfunction
    
    // And stops it.
    function Missile__StopPeriodic takes integer structId returns nothing
        set Missile__instances[structId]=Missile__instances[structId] - 1
        if ( Missile__instances[structId] == 0 ) then
            set Missile__active=Missile__active - 1
            if ( Missile__active == 0 ) then
                call PauseTimer(Missile__clock)
            endif
            call TriggerRemoveCondition(Missile__core, Missile__condition[structId])
            set Missile__condition[structId]=null
        endif
    endfunction
    
    // Now the popular MissileStruct.
    // How is it working? Let's see!
    //
    // P in the end of all methods hopefully prevents
    // any conflicting code.
    
    
    
// The end!

//library Missile ends
//library Hydra:

// Hydra Code. Changes may causes errors.


    // Toogles unit indexer systems in the best way possible.
    // Considers the previous library setup ( enabled or not )
    function Hydra__ToogleUnitIndexer takes boolean enable returns boolean
        local boolean prevSetup= true
//#         static if LIBRARY_UnitIndexer then
//#             set prevSetup = UnitIndexer.enabled
//#             set UnitIndexer.enabled = enable
//#         elseif LIBRARY_UnitIndexerGUI then
//#             set prevSetup = udg_UnitIndexerEnabled
//#             set udg_UnitIndexerEnabled = enable
//#         elseif LIBRARY_UnitDex then
//#             set prevSetup = UnitDex.Enabled
//#             set UnitDex.Enabled = enable
//#         endif
        return prevSetup
    endfunction
    
    // Data structure; complexity: List
//Implemented from module Hydra__HydraStructure:
    
        
        function s__Hydra__HydraHead__get_list takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,    "List", "list", "Hydra__HydraHead", this, "Attempted To Read Null Node.")
//#                  call ThrowError(not Hydra__HydraStructure__isNode,   "List", "list", "Hydra__HydraHead", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Hydra__HydraHead_Hydra__HydraStructure___list[this]
        endfunction
        
        function s__Hydra__HydraHead__get_next takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,    "List", "next", "Hydra__HydraHead", this, "Attempted To Go Out Of Bounds.")
//#                  call ThrowError(not Hydra__HydraStructure__isNode,   "List", "next", "Hydra__HydraHead", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Hydra__HydraHead_Hydra__HydraStructure___next[this]
        endfunction
        
        function s__Hydra__HydraHead__get_prev takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,    "List", "prev", "Hydra__HydraHead", this, "Attempted To Go Out Of Bounds.")
//#                  call ThrowError(not Hydra__HydraStructure__isNode,   "List", "prev", "Hydra__HydraHead", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Hydra__HydraHead_Hydra__HydraStructure___prev[this]
        endfunction
        
        function s__Hydra__HydraHead__get_first takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,        "List", "first", "Hydra__HydraHead", this, "Attempted To Read Null List.")
//#                  call ThrowError(not Hydra__HydraStructure__isCollection, "List", "first", "Hydra__HydraHead", this, "Attempted To Read Invalid List.")
//#             endif
            return s__Hydra__HydraHead_Hydra__HydraStructure___first[this]
        endfunction
        
        function s__Hydra__HydraHead__get_last takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,        "List", "last", "Hydra__HydraHead", this, "Attempted To Read Null List.")
//#                  call ThrowError(not Hydra__HydraStructure__isCollection, "List", "last", "Hydra__HydraHead", this, "Attempted To Read Invalid List.")
//#             endif
            return s__Hydra__HydraHead_Hydra__HydraStructure___last[this]
        endfunction
        
        function s__Hydra__HydraHead_Hydra__HydraStructure__allocateCollection takes nothing returns integer
            local integer this= s__Hydra__HydraHead_Hydra__HydraStructure___first[(0)]
            
            if ( 0 == this ) then
//#                 static if LIBRARY_ErrorMessage then
//#                      call ThrowError(Hydra__HydraStructure__collectionCount == 8191, "List", "Hydra__HydraStructure__allocateCollection", "Hydra__HydraHead", 0, "Overflow.")
//#                 endif
               
                set this=s__Hydra__HydraHead_Hydra__HydraStructure__collectionCount + 1
                set s__Hydra__HydraHead_Hydra__HydraStructure__collectionCount=this
            else
                set s__Hydra__HydraHead_Hydra__HydraStructure___first[(0)]=s__Hydra__HydraHead_Hydra__HydraStructure___first[this]
            endif
            
            return this
        endfunction
        
        function s__Hydra__HydraHead_Hydra__HydraStructure__allocateNode takes nothing returns integer
            local integer this= s__Hydra__HydraHead_Hydra__HydraStructure___next[(0)]
            
            if ( 0 == this ) then
                
//#                 static if LIBRARY_ErrorMessage then
//#                      call ThrowError(Hydra__HydraStructure__nodeCount == 8191, "List", "Hydra__HydraStructure__allocateNode", "Hydra__HydraHead", 0, "Overflow.")
//#                 endif
               
                set this=s__Hydra__HydraHead_Hydra__HydraStructure__nodeCount + 1
                set s__Hydra__HydraHead_Hydra__HydraStructure__nodeCount=this
            else
                set s__Hydra__HydraHead_Hydra__HydraStructure___next[(0)]=s__Hydra__HydraHead_Hydra__HydraStructure___next[this]
            endif
            
            return this
        endfunction
        
        function s__Hydra__HydraHead_create takes nothing returns integer
            local integer this= s__Hydra__HydraHead_Hydra__HydraStructure__allocateCollection()
            
             set s__Hydra__HydraHead_Hydra__HydraStructure__isCollection[this]=true
            
            set s__Hydra__HydraHead_Hydra__HydraStructure___first[this]=0
            set s__Hydra__HydraHead_size[this]=0
            return this
        endfunction
        function s__Hydra__HydraHead_enqueue takes integer this returns integer
            local integer node= s__Hydra__HydraHead_Hydra__HydraStructure__allocateNode()
            
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,        "List", "enqueue", "Hydra__HydraHead", this, "Attempted To Enqueue On To Null List.")
//#                  call ThrowError(not Hydra__HydraStructure__isCollection, "List", "enqueue", "Hydra__HydraHead", this, "Attempted To Enqueue On To Invalid List.")
//#             endif
            
             set s__Hydra__HydraHead_Hydra__HydraStructure__isNode[node]=true
            
            set s__Hydra__HydraHead_Hydra__HydraStructure___list[node]=this
        
            if ( s__Hydra__HydraHead_Hydra__HydraStructure___first[this] == 0 ) then
                set s__Hydra__HydraHead_Hydra__HydraStructure___first[this]=node
                set s__Hydra__HydraHead_Hydra__HydraStructure___last[this]=node
                set s__Hydra__HydraHead_Hydra__HydraStructure___prev[node]=0
            else
                set s__Hydra__HydraHead_Hydra__HydraStructure___next[s__Hydra__HydraHead_Hydra__HydraStructure___last[this]]=node
                set s__Hydra__HydraHead_Hydra__HydraStructure___prev[node]=s__Hydra__HydraHead_Hydra__HydraStructure___last[this]
                set s__Hydra__HydraHead_Hydra__HydraStructure___last[this]=node
            endif
            
            set s__Hydra__HydraHead_Hydra__HydraStructure___next[node]=0
            set s__Hydra__HydraHead_size[this]=s__Hydra__HydraHead_size[this] + 1
            return node
        endfunction
        function s__Hydra__HydraHead_remove takes integer this returns nothing
            local integer node= this
            set this=s__Hydra__HydraHead_Hydra__HydraStructure___list[node]
            
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(node == 0,        "List", "remove", "Hydra__HydraHead", this, "Attempted To Remove Null Node.")
//#                  call ThrowError(not node.Hydra__HydraStructure__isNode,  "List", "remove", "Hydra__HydraHead", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
//#             endif
            
             set s__Hydra__HydraHead_Hydra__HydraStructure__isNode[node]=false
            
            set s__Hydra__HydraHead_Hydra__HydraStructure___list[node]=0
        
            if ( 0 == s__Hydra__HydraHead_Hydra__HydraStructure___prev[node] ) then
                set s__Hydra__HydraHead_Hydra__HydraStructure___first[this]=s__Hydra__HydraHead_Hydra__HydraStructure___next[node]
            else
                set s__Hydra__HydraHead_Hydra__HydraStructure___next[s__Hydra__HydraHead_Hydra__HydraStructure___prev[node]]=s__Hydra__HydraHead_Hydra__HydraStructure___next[node]
            endif
            if ( 0 == s__Hydra__HydraHead_Hydra__HydraStructure___next[node] ) then
                set s__Hydra__HydraHead_Hydra__HydraStructure___last[this]=s__Hydra__HydraHead_Hydra__HydraStructure___prev[node]
            else
                set s__Hydra__HydraHead_Hydra__HydraStructure___prev[s__Hydra__HydraHead_Hydra__HydraStructure___next[node]]=s__Hydra__HydraHead_Hydra__HydraStructure___prev[node]
            endif
            
            set s__Hydra__HydraHead_Hydra__HydraStructure___next[node]=s__Hydra__HydraHead_Hydra__HydraStructure___next[(0)]
            set s__Hydra__HydraHead_Hydra__HydraStructure___next[(0)]=node
            set s__Hydra__HydraHead_size[this]=s__Hydra__HydraHead_size[this] - 1
        endfunction
        function s__Hydra__HydraHead_clear takes integer this returns nothing
             local integer node= s__Hydra__HydraHead_Hydra__HydraStructure___first[this]
           
//#            static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,            "List", "clear", "Hydra__HydraHead", this, "Attempted To Clear Null List.")
//#                  call ThrowError(not Hydra__HydraStructure__isCollection,     "List", "clear", "Hydra__HydraHead", this, "Attempted To Clear Invalid List.")
//#            endif
           
//#             static if true then
                    loop
                        exitwhen node == 0
                        set s__Hydra__HydraHead_Hydra__HydraStructure__isNode[node]=false
                        set node=s__Hydra__HydraHead_Hydra__HydraStructure___next[node]
                    endloop
//#             endif
            
            if ( s__Hydra__HydraHead_Hydra__HydraStructure___first[this] == 0 ) then
                return
            endif
            
            set s__Hydra__HydraHead_Hydra__HydraStructure___next[s__Hydra__HydraHead_Hydra__HydraStructure___last[this]]=s__Hydra__HydraHead_Hydra__HydraStructure___next[(0)]
            set s__Hydra__HydraHead_Hydra__HydraStructure___next[(0)]=s__Hydra__HydraHead_Hydra__HydraStructure___first[this]
            
            set s__Hydra__HydraHead_Hydra__HydraStructure___first[this]=0
            set s__Hydra__HydraHead_Hydra__HydraStructure___last[this]=0
        endfunction
        function s__Hydra__HydraHead_destroy takes integer this returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,            "List", "destroy", "Hydra__HydraHead", this, "Attempted To Destroy Null List.")
//#                  call ThrowError(not Hydra__HydraStructure__isCollection,     "List", "destroy", "Hydra__HydraHead", this, "Attempted To Destroy Invalid List.")
//#             endif
            
//#             static if true then
                     call s__Hydra__HydraHead_clear(this)
                    
                     set s__Hydra__HydraHead_Hydra__HydraStructure__isCollection[this]=false
//#             else
//#                 if (Hydra__HydraStructure___first != 0) then
//#                     set Hydra__HydraStructure___last.Hydra__HydraStructure___next = Hydra__HydraHead(0).Hydra__HydraStructure___next
//#                     set Hydra__HydraHead(0).Hydra__HydraStructure___next = Hydra__HydraStructure___first
//#                     
//#                     set Hydra__HydraStructure___last = 0
//#                 endif
//#             endif
            
            set s__Hydra__HydraHead_Hydra__HydraStructure___first[this]=s__Hydra__HydraHead_Hydra__HydraStructure___first[(0)]
            set s__Hydra__HydraHead_Hydra__HydraStructure___first[(0)]=this
            set s__Hydra__HydraHead_size[this]=0
        endfunction
        
    
    
        //grp for a better target evaluation.
    
        
    

        // Available stub methods.
        function s__Hydra_onSummonHead takes integer this,unit head returns nothing
        endfunction
        function s__Hydra_onRemoveHead takes integer this,unit head returns nothing
        endfunction
        function s__Hydra_onTargetFilter takes integer this,unit target,player owner returns boolean
            return UnitAlive(target) and IsUnitEnemy(target, owner)
        endfunction
        function s__Hydra_onFire takes integer this,unit shooter,unit target,integer missile returns nothing
            call s__Missile_terminate(missile)
        endfunction

        function s__Hydra__set_attackAnimationTime takes integer this,real value returns nothing
            set s__Hydra_animationTimeOriginal[this]=value
            set s__Hydra_animationTime_p[this]=value
            if ( 0. != s__Hydra_attackPeriod_p[this] and s__Hydra_attackPeriod_p[this] < value ) then
                set s__Hydra_timeScale[this]=value / s__Hydra_attackPeriod_p[this]
                set s__Hydra_animationTime_p[this]=s__Hydra_attackPeriod_p[this]
            endif
        endfunction

        function s__Hydra__set_attackPeriod takes integer this,real value returns nothing
            set s__Hydra_attackPeriod_p[this]=value
            if ( value < s__Hydra_animationTime_p[this] and s__Hydra_animationTimeOriginal[this] != 0. ) then
                set s__Hydra_timeScale[this]=s__Hydra_animationTimeOriginal[this] / value
                set s__Hydra_animationTime_p[this]=value
            endif
        endfunction
        
        function s__Hydra__set_duration takes integer this,real time returns nothing
            if ( 0. <= time ) then
                call PauseTimer(s__Hydra_lifeTimer[this])
            elseif ( s__Hydra_summoned[this] ) and ( s__Hydra__HydraHead_size[s__Hydra_list[this]] != 0 ) then
                call TimerStart(s__Hydra_lifeTimer[this], time, false, function sc__Hydra_killHead)
            endif
            set s__Hydra_duration_p[this]=time
        endfunction
        
        function s__Hydra__set_scale takes integer this,real value returns nothing
            local integer node
            if ( s__Hydra_summoned[this] ) then
                set node=s__Hydra__HydraHead__get_first(s__Hydra_list[this])
                loop
                    exitwhen node == 0
                    call SetUnitScale(s__Hydra__HydraHead_unit[node], value, 0, 0)
                    set s__Hydra__HydraHead_unitZ[node]=s__Hydra__HydraHead_z[node] + s__Hydra_headHeight[this] * value
                    set node=s__Hydra__HydraHead__get_next(node)
                endloop
            endif
            set s__Hydra_offset_p[this]=s__Hydra_offset_p[this] * value
            set s__Hydra_scale_p[this]=value
        endfunction
        
        function s__Hydra__get_scale takes integer this returns real
            return s__Hydra_scale_p[this]
        endfunction
        
        function s__Hydra__set_offset takes integer this,real value returns nothing
            set s__Hydra_offset_p[this]=value * s__Hydra__get_scale(this)
        endfunction
        
        function s__Hydra_optimize takes integer this returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError((heads <= 0),                 "Hydra", "optimize", "heads",         this, "Can't use optimize() before heads are set above 0!")
//#                  call ThrowError((attackPeriod_p <= 0),        "Hydra", "optimize", "attackPeriod",  this, "Can't use optimize() before attackPeriod is set!")
//#                  call ThrowError((attackSpeed <= 0),           "Hydra", "optimize", "attackSpeed",   this, "Can't use optimize() before attackSpeed is set!")
//#                  call ThrowError((animationTimeOriginal <= 0), "Hydra", "optimize", "animationTime", this, "Can't use optimize() before attackAnimationTime is set!")
//#             endif
            
            call s__Hydra__set_attackPeriod(this,( s__Hydra_attackSpeed[this] / s__Hydra_heads[this] ))
        endfunction
        
        function s__Hydra_destroy takes integer this returns nothing
            local integer head= s__Hydra__HydraHead__get_first(s__Hydra_list[this])

            call ReleaseTimer(s__Hydra_lifeTimer[this])
            call ReleaseTimer(s__Hydra_shoot[this])
            loop
                exitwhen ( 0 == head )
                if ( UnitAlive(s__Hydra__HydraHead_unit[head]) ) then
                    call sc__Hydra_onRemoveHead(this,s__Hydra__HydraHead_unit[head])
                    call UnitApplyTimedLife(s__Hydra__HydraHead_unit[head], Hydra__TIMED_LIFE, 0.001)
                endif
                set s__Hydra__HydraHead_unit[head]=null
                set s__Hydra__HydraHead_target[head]=null
                set head=s__Hydra__HydraHead__get_next(head)
            endloop
            call s__Hydra__HydraHead_destroy(s__Hydra_list[this])
            
            set s__Hydra_owner[this]=null
            set s__Hydra_shoot[this]=null
            set s__Hydra_lifeTimer[this]=null
            set s__Hydra_source[this]=null
            set s__Hydra_summoned[this]=false
            
            set Hydra__allocCount=Hydra__allocCount - 1
            if ( Hydra__allocCount == 0 ) then
                call PauseTimer(Hydra__STAMP)
            endif
            call sc__Hydra_deallocate(this)
        endfunction
    
        // It took some time until I found the proper Z offset calculation for non arcing missiles.
        // Warcraft III terrain surface says no-no to simple geometry and congruent triangles. 
        // It is like this:
        //      1. head.unitZ == GetUnitFlyHeight(head) + headHeight*scale
        //      2. this.z     == GetUnitFlyHeight(head.target) + GetUnitBodySize(head.target)*Missile.HIT_BOX
        //      3. dZ         == LocZ(impactX, impactY) - head.UnitZ + LocZ(originX, originY)
        //      4. endZ       == head.unitZ + dZ*(maxDistance/distance) - LocZ(maxDistanceImpactX, maxDistanceImpactY)
        function s__Hydra_fire takes nothing returns nothing
            local timer t= GetExpiredTimer()
            local integer this= (GetTimerData(t))
            local integer head= s__Hydra_currentHead[this]
            local real sin= Sin(s__Hydra__HydraHead_aimAngle[head])
            local real cos= Cos(s__Hydra__HydraHead_aimAngle[head])
            local real ox= s__Hydra__HydraHead_x[head] + s__Hydra_offset_p[this] * cos
            local real oy= s__Hydra__HydraHead_y[head] + s__Hydra_offset_p[this] * sin
            local real a= s__Hydra_attackPeriod_p[this] - s__Hydra_animationTime_p[this]
            local real d
            local real dZ
            local real endZ
            local integer missile
            
            if ( s__Hydra_hasArcOrCurve[this] ) then
                set missile=s__Missile_createXYZ(ox , oy , s__Hydra__HydraHead_unitZ[head] , s__Hydra__HydraHead_aimX[head] , s__Hydra__HydraHead_aimY[head] , s__Hydra__HydraHead_aimZ[head])
            else
                set d=RMaxBJ(SquareRoot(( ox - s__Hydra__HydraHead_aimX[head] ) * ( ox - s__Hydra__HydraHead_aimX[head] ) + ( oy - s__Hydra__HydraHead_aimY[head] ) * ( oy - s__Hydra__HydraHead_aimY[head] )), 1.)
                set dZ=( Missile_GetLocZ(s__Hydra__HydraHead_aimX[head] , s__Hydra__HydraHead_aimY[head]) + s__Hydra__HydraHead_aimZ[head] ) - ( s__Hydra__HydraHead_unitZ[head] + Missile_GetLocZ(ox , oy) )
                set endZ=s__Hydra__HydraHead_unitZ[head] + ( dZ * ( s__Hydra_attackRange[this] / d ) - Missile_GetLocZ(ox + s__Hydra_attackRange[this] * cos , oy + s__Hydra_attackRange[this] * sin) )
                set missile=s__Missile_create(ox , oy , s__Hydra__HydraHead_unitZ[head] , s__Hydra__HydraHead_aimAngle[head] , s__Hydra_attackRange[this] , endZ)
            endif
            set s__Missile_source[missile]=s__Hydra_source[this]
            set s__Missile_owner[missile]=s__Hydra_owner[this]
            set s__Missile_data[missile]=this
            
            // Fire stub method onFire
            call sc__Hydra_onFire(this,s__Hydra__HydraHead_unit[head] , s__Hydra__HydraHead_target[head] , missile)
            
//#             static if LIBRARY_ErrorMessage then
//#                  if (hasArcOrCurve) and ((not (missile.arc != 0.)) and (not (missile.curve != 0.))) then
//#                      call ThrowWarning(true, "Hydra", "fire", "hasArcOrCurve", this, "Don't set it to true, when you don't use arced or curved missiles!")
//#                  elseif not (hasArcOrCurve) and (((missile.arc != 0.) or (missile.curve != 0.))) then
//#                      call ThrowWarning(true, "Hydra", "fire", "hasArcOrCurve", this, "Arc & Curve settings are only valid if hasArcOrCurve is set to true")
//#                  endif
//#             endif
           
            if ( 1. != s__Hydra_timeScale[this] ) then
                call SetUnitTimeScale(s__Hydra__HydraHead_unit[head], 1.)
            endif
            call QueueUnitAnimation(s__Hydra__HydraHead_unit[s__Hydra_currentHead[this]], Hydra__STAND + Hydra__animationSuffix[s__Hydra__HydraHead_number[head]])
           
            if ( 0. > a ) then
                set a=0.
            endif
        
            call TimerStart(t, a, false, function sc__Hydra_attemptShoot)
            set t=null
        endfunction

        
        function s__Hydra_evaluateTarget takes integer this,integer node returns boolean
            local real dist
            local real ndist
            local real bdist
            local unit u
            local unit new= null
            local unit best= null
            local unit old= s__Hydra__HydraHead_target[node]
            local real x
            local real y
            local real ox
            local real oy
            local integer temp
            
            // First check the previous target.
            // Evaluates stub method onTargetFilter
            if ( IsUnitInRange(old, s__Hydra__HydraHead_unit[node], s__Hydra_attackRange[this]) ) and ( sc__Hydra_onTargetFilter(this,old , s__Hydra_owner[this]) ) then
                set old=null
                return true
            else
                set s__Hydra__HydraHead_target[node]=null // Clear the previous target.
                call GroupClear(s__Hydra_grp)
                
                
                // Units targeted by the other heads of this instance, have a lower priority.
                set temp=s__Hydra__HydraHead__get_first(s__Hydra_list[this])
                loop
                    exitwhen ( 0 == temp )
                    if ( s__Hydra__HydraHead_target[temp] != null ) then
                        call GroupAddUnit(s__Hydra_grp, s__Hydra__HydraHead_target[temp])
                    endif
                    set temp=s__Hydra__HydraHead__get_next(temp)
                endloop
                
                set ox=s__Hydra__HydraHead_x[node]
                set oy=s__Hydra__HydraHead_y[node]
                call GroupEnumUnitsInRange(s__Hydra_enu, ox, oy, s__Hydra_attackRange[this] + Missile_MAXIMUM_COLLISION_SIZE, null)
        
                // The old target probably has an high error quote,
                // therefore it gets the lowest priority.
                call GroupRemoveUnit(s__Hydra_enu, old)
                loop
                    set u=FirstOfGroup(s__Hydra_enu)
                    exitwhen u == null
                    call GroupRemoveUnit(s__Hydra_enu, u)
                    
                    if IsUnitInRange(u, s__Hydra__HydraHead_unit[node], s__Hydra_attackRange[this]) and sc__Hydra_onTargetFilter(this,u , s__Hydra_owner[this]) then
                        set x=GetUnitX(u)
                        set y=GetUnitY(u)
                        set dist=( ( x - ox ) * ( x - ox ) + ( y - oy ) * ( y - oy ) ) //screw squareroot
                        if ( new == null ) or ( dist < ndist ) then
                            set ndist=dist
                            set new=u
                        endif
                        
                        if not ( IsUnitInGroup(u, s__Hydra_grp) ) then
                            if ( best == null ) or ( dist < bdist ) then
                                set best=u
                                set bdist=dist
                            endif
                        endif
                    endif
                endloop
                
                if ( best != null ) then
                    set s__Hydra__HydraHead_target[node]=best
                    set best=null
                    
                elseif ( new != null ) then
                    set s__Hydra__HydraHead_target[node]=new
                    
                elseif ( sc__Hydra_onTargetFilter(this,old , s__Hydra_owner[this]) and IsUnitInRange(old, s__Hydra__HydraHead_unit[node], s__Hydra_attackRange[this]) ) then
                    set s__Hydra__HydraHead_target[node]=old
                endif
                set new=null
                set old=null
            endif

            return ( s__Hydra__HydraHead_target[node] != null )
        endfunction
    
        function s__Hydra_attemptShoot takes nothing returns nothing
            local timer t= GetExpiredTimer()
            local integer this= (GetTimerData(t))
            local real elapsed= TimerGetElapsed(Hydra__STAMP)
            local integer head= s__Hydra_nextShootingHead[this]
            local real timeout

            if ( s__Hydra__HydraHead_lastShot[head] + s__Hydra_attackSpeed[this] <= elapsed ) then

                if ( s__Hydra_evaluateTarget(this,head) ) then
                
                    set s__Hydra_nextShootingHead[this]=s__Hydra__HydraHead__get_next(head)
                    if ( s__Hydra_nextShootingHead[this] == 0 ) then
                        set s__Hydra_nextShootingHead[this]=s__Hydra__HydraHead__get_first(s__Hydra_list[this])
                    endif
                    
                    // Taking aim, before the shoot animation starts.
                    set s__Hydra__HydraHead_aimX[head]=GetUnitX(s__Hydra__HydraHead_target[head])
                    set s__Hydra__HydraHead_aimY[head]=GetUnitY(s__Hydra__HydraHead_target[head])
                    set s__Hydra__HydraHead_aimZ[head]=GetUnitFlyHeight(s__Hydra__HydraHead_target[head]) + GetUnitBodySize(s__Hydra__HydraHead_target[head]) * s__Missile_HIT_BOX
                    set s__Hydra__HydraHead_aimAngle[head]=Atan2(s__Hydra__HydraHead_aimY[head] - s__Hydra__HydraHead_y[head], s__Hydra__HydraHead_aimX[head] - s__Hydra__HydraHead_x[head])
                    set s__Hydra_currentHead[this]=head
                    set s__Hydra__HydraHead_lastShot[head]=elapsed
                
                    //  Initiate the shooting process.
                    call SetUnitFacing(s__Hydra__HydraHead_unit[head], s__Hydra__HydraHead_aimAngle[head] * bj_RADTODEG)
                
                    if ( 1. != s__Hydra_timeScale[this] ) then
                        call SetUnitTimeScale(s__Hydra__HydraHead_unit[head], s__Hydra_timeScale[this])
                    endif
                
                    call SetUnitAnimation(s__Hydra__HydraHead_unit[head], Hydra__ATTACK + Hydra__animationSuffix[s__Hydra__HydraHead_number[head]])
                    call TimerStart(t, s__Hydra_animationTime_p[this], false, function s__Hydra_fire)
                    
                elseif ( s__Hydra__HydraHead_size[s__Hydra_list[this]] > 1 ) then
                
                    // This head can't shoot, we pass in a timeout and
                    // move to the next head.
                    set s__Hydra__HydraHead_lastShot[head]=elapsed
                    set head=s__Hydra__HydraHead__get_next(head)
                    if ( head == 0 ) then
                        set head=s__Hydra__HydraHead__get_first(s__Hydra_list[this])
                    endif
                    set s__Hydra_nextShootingHead[this]=head
                    
                    set timeout=s__Hydra__HydraHead_lastShot[head] + s__Hydra_attackSpeed[this] - elapsed
                    if ( timeout < 0 ) then
                        set timeout=0.
                    elseif ( timeout > s__Hydra_attackPeriod_p[this] ) then
                        set timeout=s__Hydra_attackPeriod_p[this]
                    endif
                    
                    call TimerStart(t, timeout, false, function s__Hydra_attemptShoot)
                else
                    call TimerStart(t, s__Hydra_attackPeriod_p[this], false, function s__Hydra_attemptShoot)
                endif
            else
                call TimerStart(t, RMaxBJ(0., s__Hydra__HydraHead_lastShot[head] + s__Hydra_attackSpeed[this] - elapsed), false, function s__Hydra_attemptShoot)
            endif
            set t=null
        endfunction
        
        function s__Hydra_killHead takes nothing returns nothing
            local integer this= (GetTimerData(GetExpiredTimer()))
            local integer head= s__Hydra__HydraHead__get_first(s__Hydra_list[this])
            local integer node= s__Hydra__HydraHead__get_next(head)
            local real time= RMaxBJ(.0001, s__Hydra__HydraHead_lastShot[head] + ( s__Hydra_animationTime_p[this] * 2. ) - TimerGetElapsed(Hydra__STAMP))
            
            // In case this head is still in the shoot animation foreward or backwards,
            // we show that shoot animation before killing it.
            call UnitApplyTimedLife(s__Hydra__HydraHead_unit[head], Hydra__TIMED_LIFE, time)
            
            // Evaluate stub method onRemoveHead
            call sc__Hydra_onRemoveHead(this,s__Hydra__HydraHead_unit[head])
            set s__Hydra__HydraHead_unit[head]=null
            call s__Hydra__HydraHead_remove(head)
            if ( 0 == s__Hydra__HydraHead__get_first(s__Hydra_list[this]) ) then
                call s__Hydra_destroy(this)
            else
                if ( s__Hydra_nextShootingHead[this] == head ) then
                    if ( node == 0 ) then
                        set s__Hydra_nextShootingHead[this]=s__Hydra__HydraHead__get_first(s__Hydra_list[this])
                    else
                        set s__Hydra_nextShootingHead[this]=node
                    endif
                endif
                call TimerStart(s__Hydra_lifeTimer[this], s__Hydra_interval[this], false, function s__Hydra_killHead)
            endif
        endfunction
        
        // Create a new head without firing off an onIndex event.
        function s__Hydra_addHeadEx takes integer this,real x,real y,real z,real face returns nothing
            local integer node= s__Hydra__HydraHead_enqueue(s__Hydra_list[this])
            local string suffix= Hydra__animationSuffix[s__Hydra__HydraHead_size[s__Hydra_list[this]]]
            local boolean prev= Hydra__ToogleUnitIndexer(false)
            local unit head= CreateUnit(s__Hydra_owner[this], s__Hydra_typeId[this], x, y, face)
            call Hydra__ToogleUnitIndexer(prev)
            call SetUnitFlyHeight(head, z, 0.)
            if ( 1. != s__Hydra_scale_p[this] ) then
                call SetUnitScale(head, s__Hydra_scale_p[this], 1., 1.)
            endif
            call UnitAddAbility(head, Hydra__LOCUST)
            call UnitAddAbility(head, Hydra__CROW_FORM)
            call SetUnitAnimation(head, Hydra__BIRTH + suffix)
            call QueueUnitAnimation(head, Hydra__STAND + suffix)
            
            set s__Hydra__HydraHead_unit[node]=head
            set s__Hydra__HydraHead_target[node]=null
            set s__Hydra__HydraHead_lastShot[node]=TimerGetElapsed(Hydra__STAMP) - s__Hydra_attackSpeed[this] + s__Hydra_birthAnimationTime[this]
            set s__Hydra__HydraHead_x[node]=GetUnitX(head)
            set s__Hydra__HydraHead_y[node]=GetUnitY(head)
            set s__Hydra__HydraHead_z[node]=z
            set s__Hydra__HydraHead_unitZ[node]=z + s__Hydra_headHeight[this] * s__Hydra_scale_p[this]
            set s__Hydra__HydraHead_number[node]=s__Hydra__HydraHead_size[s__Hydra_list[this]]
                
            // Evaluate stub method onSummonHead.
            call sc__Hydra_onSummonHead(this,head)
            set head=null
        endfunction
        
        function s__Hydra_addHead takes integer this,real x,real y,real z,real face returns boolean
            if ( s__Hydra_summoned[this] ) and ( s__Hydra__HydraHead_size[s__Hydra_list[this]] > 0 ) then
                call s__Hydra_addHeadEx(this,x , y , z , face)
                return true
            endif
            return false
        endfunction
        
        // Periodically called until all Hydra heads are created.
        function s__Hydra_spawn takes nothing returns nothing
            local timer t= GetExpiredTimer()
            local integer this= (GetTimerData(t))
            local real a= s__Hydra_angle[this] * bj_DEGTORAD + s__Hydra__HydraHead_size[s__Hydra_list[this]] * ( Hydra__TWO_PI / s__Hydra_heads[this] )
            call s__Hydra_addHeadEx(this,( s__Hydra_bodysize[this] * s__Hydra_scale_p[this] ) * Cos(a) + s__Hydra_posX[this] , ( s__Hydra_bodysize[this] * s__Hydra_scale_p[this] ) * Sin(a) + s__Hydra_posY[this] , s__Hydra_posZ[this] , a * bj_RADTODEG)
            
            if ( s__Hydra__HydraHead_size[s__Hydra_list[this]] == 1 ) then
                set s__Hydra_nextShootingHead[this]=s__Hydra__HydraHead__get_first(s__Hydra_list[this])
                call TimerStart(t, s__Hydra_interval[this], true, function s__Hydra_spawn)
            endif
            
            if ( s__Hydra__HydraHead_size[s__Hydra_list[this]] >= s__Hydra_heads[this] ) then
                call ReleaseTimer(t)
            endif
            set t=null
        endfunction
    
        function s__Hydra_summon takes integer this returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError((summoned),                     "Hydra",    "summon", "summoned",              this, "This Hydra is already summoned!")
//#                  call ThrowError((typeId == 0),                  "Hydra",    "summon", "unitId",                this, "Passed in Hydra unit type id is invalid ( 0 )!")
//#                  call ThrowError((heads <= 0),                   "Hydra",    "summon", "heads",                 this, "Passed in value is invalid ( <= 0 )!")
//#                  call ThrowError((attackRange <= 0),             "Hydra",    "summon", "attackRange",           this, "Passed in value is invalid ( <= 0 )!")
//#                  call ThrowError((attackPeriod_p <= 0),          "Hydra",    "summon", "attackPeriod",          this, "Passed in value is invalid ( <= 0 )!")
//#                  call ThrowError((animationTimeOriginal <= 0),   "Hydra",    "summon", "attackAnimationTime",   this, "Passed in value is invalid ( <= 0 )!")
//#                  call ThrowWarning((headHeight < 0),             "Hydra",    "summon", "headHeight",            this, "Passed in value is invalid ( below 0 )!")
//#                  call ThrowWarning((GetUnitTypeId(source) == 0), "Hydra",    "summon", "GetUnitTypeId(source)", this, "Passed in unit is invalid ( null )!")
//#             endif
            
            if not ( s__Hydra_summoned[this] ) then
                set s__Hydra_summoned[this]=true
                call TimerStart(NewTimerEx(this), 0., false, function s__Hydra_spawn)
                call TimerStart(s__Hydra_shoot[this], s__Hydra_birthAnimationTime[this], false, function s__Hydra_attemptShoot)
                if ( s__Hydra_duration_p[this] > 0. ) then
                    call TimerStart(s__Hydra_lifeTimer[this], s__Hydra_duration_p[this], false, function s__Hydra_killHead)
                endif
            endif
        endfunction

        function s__Hydra_create takes unit whichUnit,integer unitId,real x,real y,real z,real face,real spawnInterval returns integer
      local integer this= s__Hydra__allocate()
            set s__Hydra_list[this]=s__Hydra__HydraHead_create()
            set s__Hydra_shoot[this]=NewTimerEx(this)
            set s__Hydra_lifeTimer[this]=NewTimerEx(this)
            set s__Hydra_owner[this]=GetOwningPlayer(whichUnit)
            
            // Set members.
            set s__Hydra_source[this]=whichUnit
            set s__Hydra_typeId[this]=unitId
            set s__Hydra_posX[this]=x
            set s__Hydra_posY[this]=y
            set s__Hydra_posZ[this]=z
            set s__Hydra_angle[this]=face
            set s__Hydra_scale_p[this]=1.
            set s__Hydra_timeScale[this]=1.
            set s__Hydra_attackPeriod_p[this]=0.
            set s__Hydra_offset_p[this]=0.
            set s__Hydra_duration_p[this]=0.
            set s__Hydra_animationTimeOriginal[this]=0.
            set s__Hydra_birthAnimationTime[this]=0.
            set s__Hydra_bodysize[this]=Hydra__DEFAULT_BODYSIZE
            set s__Hydra_interval[this]=spawnInterval
            set s__Hydra_hasArcOrCurve[this]=false
            
            if ( Hydra__allocCount == 0 ) then
                call TimerStart(Hydra__STAMP, 604800, false, null)
            endif
            set Hydra__allocCount=Hydra__allocCount + 1
                
            // Debug safety for method summon.
             set s__Hydra_heads[this]=0
             set s__Hydra_attackSpeed[this]=0.
             set s__Hydra_headHeight[this]=- 1.
             set s__Hydra_attackRange[this]=0.
            
            return this
        endfunction
    
        function s__Hydra_onInit takes nothing returns nothing
            set Hydra__animationSuffix[0]="first"
            set Hydra__animationSuffix[1]="second"
            set Hydra__animationSuffix[2]="third"
            set Hydra__animationSuffix[3]="fourth"
            set Hydra__animationSuffix[4]="fifth"
        endfunction
    
    
    // Credits to Nestharus for a properly working
    // debug algorithm in list modules.
    

//library Hydra ends
//library IceHydra:



        function s__IceHydra_onRemove takes integer missile returns boolean
            return true
        endfunction
    
        function s__IceHydra_onTerrain takes integer missile returns boolean
            return true
        endfunction
    
        function s__IceHydra_onCollide takes integer missile,unit hit returns boolean
            if UnitAlive(hit) and IsUnitEnemy(hit, s__Missile_owner[missile]) then
                if IsUnitType(hit, UNIT_TYPE_STRUCTURE) then
                    return UnitDamageTarget(s__Missile_source[missile], hit, s__Missile_damage[missile], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
                endif
                return UnitDamageTarget(s__Missile_source[missile], hit, s__Missile_damage[missile], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
            endif
            return false
        endfunction
    
//Implemented from module MissileStruct:
        
// Why not run some debug checks first.
//# static if true then
    
//#         static if not Missile_USE_DESTRUCTABLE_FILTER and IceHydra.onDestructable.exists then
//#             Error Message from library Missile in struct IceHydra !
//#             IceHydra.onDestructable is a reserved name for Missile, once you implemented MissileStruct.
//#             Either you forgot to set Missile_USE_DESTRUCTABLE_FILTER = true in library Missile or re-name that method. 
//#         endif
            
//#         static if not Missile_USE_DESTRUCTABLE_FILTER and IceHydra.onDestructableFilter.exists then
//#             Error Message from library Missile in struct IceHydra !
//#             IceHydra.onDestructableFilter is a reserved name for Missile, once you implemented MissileStruct.
//#             Either you forget to set Missile_USE_DESTRUCTABLE_FILTER = true in library Missile or re-name that method. 
//#         endif
    
//#         static if Missile_USE_DESTRUCTABLE_FILTER and IceHydra.onDestructableFilter.exists and not IceHydra.onDestructable.exists then
//#             Error Message from library Missile in struct IceHydra !
//#             IceHydra.onDestructableFilter only be used, when IceHydra.onDestructable is also declared.
//#         endif
            
//#         static if IceHydra.onMissile.exists then
//#             Error Message from library Missile in struct IceHydra !
//#             IceHydra.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#             IceHydra.onMissile is currently not supported by library Missile. 
//#             Please delete or re-name that method.
//#         endif
//# endif
        
//#         static if Missile_USE_DESTRUCTABLE_FILTER and IceHydra.onDestructableFilter.exists then
//#             // Stupid name chosen, to be unique in that struct ... hopefully.
//#             private static boolexpr MissileStruct__destConditionP = null
//#         endif
        
        // Stupid name ensures not to be called accidently.
        function s__IceHydra_MissileStruct__missileTerminateP takes integer node returns nothing
//#             static if IceHydra.onRemove.exists then
//#                 static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile__RecycleBin.recycle.exists then
                        if s__IceHydra_onRemove(node) and ( GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID ) then
                            call s__Missile__RecycleBin_recycle(s__Missile_dummy[node])
                            call s__Missile_nullBefore(node)
                        endif
//#                 else
//#                     call IceHydra.onRemove(node)
//#                 endif
//#             endif
            
            call s__Missile_terminate(node)
            call Missile__StopPeriodic(si__IceHydra)
        endfunction
    
        // Returns boolean to be compile-able with Cohadars JassHelper.
        function s__IceHydra_MissileStruct__missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile__missileStack[si__IceHydra])
            local integer node
            local real collideZ
            local unit u
            
            // Move the whole stack.
            call s__Missile_move(this)
            loop
                exitwhen this == 0
                set node=s__Missile__get_next(this)
               
                if ( s__Missile_wantDestroy[this] ) then
//#                     static if IceHydra.onFinish.exists then
//#                         if IceHydra.onFinish(this) then
//#                             call IceHydra.MissileStruct__missileTerminateP(this)
//#                         endif
//#                     else
                            call s__IceHydra_MissileStruct__missileTerminateP(this)
//#                     endif
                else
                
//#                     static if IceHydra.onCollide.exists then
                            if ( 0 != s__Missile_collision[this] ) then
                                call GroupEnumUnitsInRange(s__Missile_enumGroup, s__Missile_x[this], s__Missile_y[this], s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE, null)
                                loop
                                    set u=FirstOfGroup(s__Missile_enumGroup)
                                    exitwhen u == null
                                    call GroupRemoveUnit(s__Missile_enumGroup, u)
                                    if ( u != s__Missile_target[this] ) and IsUnitInRange(u, s__Missile_dummy[this], s__Missile_collision[this]) then
                                        
//#                                     static if Missile_USE_COLLISION_Z_FILTER then
                                            set collideZ=Missile_GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u) - s__Missile_terrainZ[this]
                                            if ( collideZ + GetUnitBodySize(u) >= s__Missile_z[this] - s__Missile_collisionZ[this] ) and ( collideZ <= s__Missile_z[this] + s__Missile_collisionZ[this] ) then
                                                if not ( IsUnitInGroup(u, s__Missile_unitsHit[this]) ) then
                                                    if s__IceHydra_onCollide(this , u) then
                                                        call s__IceHydra_MissileStruct__missileTerminateP(this)
                                                        exitwhen true
                                                    endif
                                        
                                                    call GroupAddUnit(s__Missile_unitsHit[this], u)
                                                endif
                                            endif
                                        
//#                                     else
//#                                     
//#                                         if not (IsUnitInGroup(u, this.unitsHit)) then
//#                                             if IceHydra.onCollide(this, u) then
//#                                                 call IceHydra.MissileStruct__missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                     
//#                                             call GroupAddUnit(this.unitsHit, u)
//#                                         endif                                    
//#                                     
//#                                     endif
                                    endif
                                endloop
                            endif
//#                     endif
                        
//#                     static if IceHydra.onDestructable.exists then
//#                         // Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             set bj_enumDestructableRadius = this.collision + Missile_MAXIMUM_COLLISION_SIZE
//#                             set bj_destRandomCurrentPick  = null
//#                             call SetRect(Missile.enumRect, this.x - bj_enumDestructableRadius, this.y - bj_enumDestructableRadius, this.x + bj_enumDestructableRadius, this.y + bj_enumDestructableRadius)
//#                             set bj_enumDestructableRadius = this.collision*this.collision
//#                             set Missile.temp              = this
//#                             set Missile.tempDist          = bj_enumDestructableRadius + 1
//#                             static if IceHydra.onDestructableFilter.exists then
//#                                 call EnumDestructablesInRect(Missile.enumRect, IceHydra.MissileStruct__destConditionP, function Missile.actionFuncDest)
//#                             else
//#                                 call EnumDestructablesInRect(Missile.enumRect, null, function Missile.actionFuncDest)
//#                             endif
//#                             if (bj_destRandomCurrentPick != null) and IceHydra.onDestructable(this, bj_destRandomCurrentPick) then
//#                                 call MissileStruct__missileTerminateP(this)
//#                             endif
//#                         endif
//#                     endif
                
                    if ( s__Missile_recycle[this] ) and ( s__Missile_allocated[this] ) then
//#                         static if IceHydra.onCollide.exists then
//#                             static if IceHydra.onFinish.exists then
//#                                 if (this.target == null) then
//#                                     if IceHydra.onFinish(this) then
//#                                         call IceHydra.MissileStruct__missileTerminateP(this)
//#                                     else
//#                                         set this.recycle = false
//#                                     endif
//#                                     
//#                                 elseif IceHydra.onCollide(this, this.target) then
//#                                     call IceHydra.MissileStruct__missileTerminateP(this)
//#                                 else
//#                                     set this.recycle = false
//#                                 endif
//#                             else
                                    if ( s__Missile_target[this] == null ) then
                                        call s__IceHydra_MissileStruct__missileTerminateP(this)
                                    elseif s__IceHydra_onCollide(this , s__Missile_target[this]) then
                                        call s__IceHydra_MissileStruct__missileTerminateP(this)
                                    else
                                        set s__Missile_recycle[this]=false
                                    endif
//#                             endif
//#                         else
//#                             static if IceHydra.onFinish.exists then
//#                                 if IceHydra.onFinish(this) then
//#                                     call IceHydra.MissileStruct__missileTerminateP(this)
//#                                 else
//#                                     set this.recycle = false
//#                                 endif
//#                             else
//#                                 call IceHydra.MissileStruct__missileTerminateP(this)
//#                             endif
//#                         endif                    
                    endif
                
//#                     static if IceHydra.onTerrain.exists then
                            if ( s__Missile_allocated[this] ) and ( s__Missile_z[this] < 0 ) and s__IceHydra_onTerrain(this) then
//#                             static if IceHydra.onFinish.exists then
//#                                 if IceHydra.onFinish(this) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             else
                                    call s__IceHydra_MissileStruct__missileTerminateP(this)
//#                             endif
                            endif
//#                     endif
                
                    // Runs last
//#                     static if IceHydra.onPeriod.exists then
//#                         if (this.allocated) and IceHydra.onPeriod(this) then
//#                             static if IceHydra.onFinish.exists then
//#                                 if IceHydra.onFinish(this) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             else
//#                                 call MissileStruct__missileTerminateP(this)
//#                             endif 
//#                         endif
//#                     endif
                endif
                set this=node
            endloop
           
            set u=null
            return false
        endfunction
    
        function s__IceHydra_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "IceHydra", "launch", "missile.launched", missile, "Missile Was Already Launched Before!")
//#             endif
        
            call s__Missile_insertEnd(Missile__missileStack[si__IceHydra],missile)
            call Missile__StartPeriodic(si__IceHydra)
             set s__Missile_launched[missile]=true
        endfunction
    
        function s__IceHydra_MissileStruct__onInit takes nothing returns nothing
            set Missile__missileStack[si__IceHydra]=s__Missile_allocateCollection()
            call Missile__MissileCreateExpression(si__IceHydra , function s__IceHydra_MissileStruct__missileIterateP)
//#             static if IceHydra.onDestructableFilter.exists then
//#                 set IceHydra.MissileStruct__destConditionP  = Condition(function IceHydra.onDestructableFilter)
//#             endif
        endfunction
    
        
        function s__IceHydra_onFire takes integer this,unit shooter,unit target,integer missile returns nothing
            call s__Missile__set_model(missile,"Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl")
            call s__Missile__set_scale(missile,0.8)
            set s__Missile_damage[missile]=GetRandomReal(15, 30)
            set s__Missile_collision[missile]=32.
            set s__Missile_collisionZ[missile]=15.
            set s__Missile_speed[missile]=35.
            call s__IceHydra_launch(missile)
        endfunction
        
        function s__IceHydra_onTargetFilter takes integer this,unit target,player owner returns boolean
            return UnitAlive(target) and IsUnitEnemy(target, owner)
        endfunction
    
        function s__IceHydra_onRemoveHead takes integer this,unit head returns nothing
        endfunction
    
        function s__IceHydra_onSummonHead takes integer this,unit head returns nothing
        endfunction
        

    function IceHydra___OnCast takes nothing returns boolean
        local integer hydra
        local real x= GetSpellTargetX()
        local real y= GetSpellTargetY()
        local real z= 0.
        local real face= GetRandomReal(0., 2 * bj_PI) * bj_RADTODEG
        local real interval= 1.523

        if ( GetSpellAbilityId() == IceHydra___HYDRA_ABILITY ) then
            set hydra=s__IceHydra__allocate(GetTriggerUnit() , IceHydra___HYDRA_UNIT_ID , x , y , z , face , interval)
            set s__Hydra_headHeight[hydra]=55.
            call s__Hydra__set_scale(hydra,1.2)
            call s__Hydra__set_attackAnimationTime(hydra,.5)
            call s__Hydra__set_attackPeriod(hydra,.2)
            set s__Hydra_attackSpeed[hydra]=.6
            call s__Hydra__set_duration(hydra,10.)
            set s__Hydra_attackRange[hydra]=1200.
            set s__Hydra_heads[hydra]=3
            call s__Hydra__set_offset(hydra,8.)
            set s__Hydra_hasArcOrCurve[hydra]=false
            set s__Hydra_birthAnimationTime[hydra]=1.
            //call hydra.optimize()
            call s__Hydra_summon(hydra)
        endif
        return false
    endfunction
    
    function IceHydra___Init takes nothing returns nothing
        local trigger t= CreateTrigger()
        if UnitAddAbility(DemoMap_HERO, IceHydra___HYDRA_ABILITY) then
            call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            call TriggerAddCondition(t, Condition(function IceHydra___OnCast))
        endif
    endfunction
    

//library IceHydra ends
//===========================================================================
// 
// Hydra
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Date: Mon Oct 26 14:45:49 2015
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
function CreateNeutralHostileBuildings takes nothing returns nothing
    local player p= Player(PLAYER_NEUTRAL_AGGRESSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'hgtw', 1024.0, - 1472.0, 270.000)
endfunction

//===========================================================================
function CreateNeutralHostile takes nothing returns nothing
    local player p= Player(PLAYER_NEUTRAL_AGGRESSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=CreateUnit(p, 'otau', 506.8, - 785.8, 42.030)
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
    call CreateNeutralHostileBuildings()
    call CreatePlayerBuildings()
    call CreateNeutralHostile()
    call CreatePlayerUnits()
endfunction

//***************************************************************************
//*
//*  Regions
//*
//***************************************************************************

function CreateRegions takes nothing returns nothing
    local weathereffect we

    set gg_rct_Region_000=Rect(64.0, - 2624.0, 352.0, - 2368.0)
endfunction

//***************************************************************************
//*
//*  Custom Script Code
//*
//***************************************************************************
//TESH.scrollpos=0
//TESH.alwaysfold=0

//***************************************************************************
//*
//*  Triggers
//*
//***************************************************************************

//===========================================================================
// Trigger: Missile
//===========================================================================
//TESH.scrollpos=452
//TESH.alwaysfold=0
// Trigger: TimerUtils
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: World Bounds
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
// Trigger: Hydra
//===========================================================================
//TESH.scrollpos=319
//TESH.alwaysfold=0
//===========================================================================
// Trigger: Fire Hydra
//===========================================================================
//TESH.scrollpos=47
//TESH.alwaysfold=0
// scope FireHydra begins



        function s__FireHydra_onRemove takes integer missile returns boolean
            return true
        endfunction
    
        function s__FireHydra_onTerrain takes integer missile returns boolean
            return true
        endfunction
    
        function s__FireHydra_onCollide takes integer missile,unit hit returns boolean
            if UnitAlive(hit) and IsUnitEnemy(hit, s__Missile_owner[missile]) then
                return UnitDamageTarget(s__Missile_source[missile], hit, s__Missile_damage[missile], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
            endif
            return false
        endfunction
    
//Implemented from module MissileStruct:
        
// Why not run some debug checks first.
//# static if true then
    
//#         static if not Missile_USE_DESTRUCTABLE_FILTER and FireHydra.onDestructable.exists then
//#             Error Message from library Missile in struct FireHydra !
//#             FireHydra.onDestructable is a reserved name for Missile, once you implemented MissileStruct.
//#             Either you forgot to set Missile_USE_DESTRUCTABLE_FILTER = true in library Missile or re-name that method. 
//#         endif
            
//#         static if not Missile_USE_DESTRUCTABLE_FILTER and FireHydra.onDestructableFilter.exists then
//#             Error Message from library Missile in struct FireHydra !
//#             FireHydra.onDestructableFilter is a reserved name for Missile, once you implemented MissileStruct.
//#             Either you forget to set Missile_USE_DESTRUCTABLE_FILTER = true in library Missile or re-name that method. 
//#         endif
    
//#         static if Missile_USE_DESTRUCTABLE_FILTER and FireHydra.onDestructableFilter.exists and not FireHydra.onDestructable.exists then
//#             Error Message from library Missile in struct FireHydra !
//#             FireHydra.onDestructableFilter only be used, when FireHydra.onDestructable is also declared.
//#         endif
            
//#         static if FireHydra.onMissile.exists then
//#             Error Message from library Missile in struct FireHydra !
//#             FireHydra.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#             FireHydra.onMissile is currently not supported by library Missile. 
//#             Please delete or re-name that method.
//#         endif
//# endif
        
//#         static if Missile_USE_DESTRUCTABLE_FILTER and FireHydra.onDestructableFilter.exists then
//#             // Stupid name chosen, to be unique in that struct ... hopefully.
//#             private static boolexpr MissileStruct__destConditionP = null
//#         endif
        
        // Stupid name ensures not to be called accidently.
        function s__FireHydra_MissileStruct__missileTerminateP takes integer node returns nothing
//#             static if FireHydra.onRemove.exists then
//#                 static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile__RecycleBin.recycle.exists then
                        if s__FireHydra_onRemove(node) and ( GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID ) then
                            call s__Missile__RecycleBin_recycle(s__Missile_dummy[node])
                            call s__Missile_nullBefore(node)
                        endif
//#                 else
//#                     call FireHydra.onRemove(node)
//#                 endif
//#             endif
            
            call s__Missile_terminate(node)
            call Missile__StopPeriodic(si__FireHydra)
        endfunction
    
        // Returns boolean to be compile-able with Cohadars JassHelper.
        function s__FireHydra_MissileStruct__missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile__missileStack[si__FireHydra])
            local integer node
            local real collideZ
            local unit u
            
            // Move the whole stack.
            call s__Missile_move(this)
            loop
                exitwhen this == 0
                set node=s__Missile__get_next(this)
               
                if ( s__Missile_wantDestroy[this] ) then
//#                     static if FireHydra.onFinish.exists then
//#                         if FireHydra.onFinish(this) then
//#                             call FireHydra.MissileStruct__missileTerminateP(this)
//#                         endif
//#                     else
                            call s__FireHydra_MissileStruct__missileTerminateP(this)
//#                     endif
                else
                
//#                     static if FireHydra.onCollide.exists then
                            if ( 0 != s__Missile_collision[this] ) then
                                call GroupEnumUnitsInRange(s__Missile_enumGroup, s__Missile_x[this], s__Missile_y[this], s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE, null)
                                loop
                                    set u=FirstOfGroup(s__Missile_enumGroup)
                                    exitwhen u == null
                                    call GroupRemoveUnit(s__Missile_enumGroup, u)
                                    if ( u != s__Missile_target[this] ) and IsUnitInRange(u, s__Missile_dummy[this], s__Missile_collision[this]) then
                                        
//#                                     static if Missile_USE_COLLISION_Z_FILTER then
                                            set collideZ=Missile_GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u) - s__Missile_terrainZ[this]
                                            if ( collideZ + GetUnitBodySize(u) >= s__Missile_z[this] - s__Missile_collisionZ[this] ) and ( collideZ <= s__Missile_z[this] + s__Missile_collisionZ[this] ) then
                                                if not ( IsUnitInGroup(u, s__Missile_unitsHit[this]) ) then
                                                    if s__FireHydra_onCollide(this , u) then
                                                        call s__FireHydra_MissileStruct__missileTerminateP(this)
                                                        exitwhen true
                                                    endif
                                        
                                                    call GroupAddUnit(s__Missile_unitsHit[this], u)
                                                endif
                                            endif
                                        
//#                                     else
//#                                     
//#                                         if not (IsUnitInGroup(u, this.unitsHit)) then
//#                                             if FireHydra.onCollide(this, u) then
//#                                                 call FireHydra.MissileStruct__missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                     
//#                                             call GroupAddUnit(this.unitsHit, u)
//#                                         endif                                    
//#                                     
//#                                     endif
                                    endif
                                endloop
                            endif
//#                     endif
                        
//#                     static if FireHydra.onDestructable.exists then
//#                         // Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             set bj_enumDestructableRadius = this.collision + Missile_MAXIMUM_COLLISION_SIZE
//#                             set bj_destRandomCurrentPick  = null
//#                             call SetRect(Missile.enumRect, this.x - bj_enumDestructableRadius, this.y - bj_enumDestructableRadius, this.x + bj_enumDestructableRadius, this.y + bj_enumDestructableRadius)
//#                             set bj_enumDestructableRadius = this.collision*this.collision
//#                             set Missile.temp              = this
//#                             set Missile.tempDist          = bj_enumDestructableRadius + 1
//#                             static if FireHydra.onDestructableFilter.exists then
//#                                 call EnumDestructablesInRect(Missile.enumRect, FireHydra.MissileStruct__destConditionP, function Missile.actionFuncDest)
//#                             else
//#                                 call EnumDestructablesInRect(Missile.enumRect, null, function Missile.actionFuncDest)
//#                             endif
//#                             if (bj_destRandomCurrentPick != null) and FireHydra.onDestructable(this, bj_destRandomCurrentPick) then
//#                                 call MissileStruct__missileTerminateP(this)
//#                             endif
//#                         endif
//#                     endif
                
                    if ( s__Missile_recycle[this] ) and ( s__Missile_allocated[this] ) then
//#                         static if FireHydra.onCollide.exists then
//#                             static if FireHydra.onFinish.exists then
//#                                 if (this.target == null) then
//#                                     if FireHydra.onFinish(this) then
//#                                         call FireHydra.MissileStruct__missileTerminateP(this)
//#                                     else
//#                                         set this.recycle = false
//#                                     endif
//#                                     
//#                                 elseif FireHydra.onCollide(this, this.target) then
//#                                     call FireHydra.MissileStruct__missileTerminateP(this)
//#                                 else
//#                                     set this.recycle = false
//#                                 endif
//#                             else
                                    if ( s__Missile_target[this] == null ) then
                                        call s__FireHydra_MissileStruct__missileTerminateP(this)
                                    elseif s__FireHydra_onCollide(this , s__Missile_target[this]) then
                                        call s__FireHydra_MissileStruct__missileTerminateP(this)
                                    else
                                        set s__Missile_recycle[this]=false
                                    endif
//#                             endif
//#                         else
//#                             static if FireHydra.onFinish.exists then
//#                                 if FireHydra.onFinish(this) then
//#                                     call FireHydra.MissileStruct__missileTerminateP(this)
//#                                 else
//#                                     set this.recycle = false
//#                                 endif
//#                             else
//#                                 call FireHydra.MissileStruct__missileTerminateP(this)
//#                             endif
//#                         endif                    
                    endif
                
//#                     static if FireHydra.onTerrain.exists then
                            if ( s__Missile_allocated[this] ) and ( s__Missile_z[this] < 0 ) and s__FireHydra_onTerrain(this) then
//#                             static if FireHydra.onFinish.exists then
//#                                 if FireHydra.onFinish(this) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             else
                                    call s__FireHydra_MissileStruct__missileTerminateP(this)
//#                             endif
                            endif
//#                     endif
                
                    // Runs last
//#                     static if FireHydra.onPeriod.exists then
//#                         if (this.allocated) and FireHydra.onPeriod(this) then
//#                             static if FireHydra.onFinish.exists then
//#                                 if FireHydra.onFinish(this) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             else
//#                                 call MissileStruct__missileTerminateP(this)
//#                             endif 
//#                         endif
//#                     endif
                endif
                set this=node
            endloop
           
            set u=null
            return false
        endfunction
    
        function s__FireHydra_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "FireHydra", "launch", "missile.launched", missile, "Missile Was Already Launched Before!")
//#             endif
        
            call s__Missile_insertEnd(Missile__missileStack[si__FireHydra],missile)
            call Missile__StartPeriodic(si__FireHydra)
             set s__Missile_launched[missile]=true
        endfunction
    
        function s__FireHydra_MissileStruct__onInit takes nothing returns nothing
            set Missile__missileStack[si__FireHydra]=s__Missile_allocateCollection()
            call Missile__MissileCreateExpression(si__FireHydra , function s__FireHydra_MissileStruct__missileIterateP)
//#             static if FireHydra.onDestructableFilter.exists then
//#                 set FireHydra.MissileStruct__destConditionP  = Condition(function FireHydra.onDestructableFilter)
//#             endif
        endfunction
    
        
        function s__FireHydra_onFire takes integer this,unit shooter,unit target,integer missile returns nothing
            call s__Missile__set_model(missile,"Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl")
            call s__Missile__set_scale(missile,1.)
            set s__Missile_damage[missile]=GetRandomReal(50, 150)
            set s__Missile_collision[missile]=32.
            set s__Missile_collisionZ[missile]=15.
            set s__Missile_speed[missile]=27.
            call s__FireHydra_launch(missile)
        endfunction
        
        function s__FireHydra_onTargetFilter takes integer this,unit target,player owner returns boolean
            return UnitAlive(target) and IsUnitEnemy(target, owner)
        endfunction
    
        function s__FireHydra_onRemoveHead takes integer this,unit head returns nothing
        endfunction
    
        function s__FireHydra_onSummonHead takes integer this,unit head returns nothing
        endfunction
        

    function FireHydra___OnCast takes nothing returns boolean
        local integer hydra
        local real x= GetSpellTargetX()
        local real y= GetSpellTargetY()
        local real z= 0.
        local real face= GetRandomReal(0., 2 * bj_PI) * bj_RADTODEG
        local real interval= .23

        if ( GetSpellAbilityId() == FireHydra___HYDRA_ABILITY ) then
            set hydra=s__FireHydra__allocate(GetTriggerUnit() , FireHydra___HYDRA_UNIT_ID , x , y , z , face , interval)
            set s__Hydra_heads[hydra]=3
            call s__Hydra__set_attackAnimationTime(hydra,.5)
            set s__Hydra_attackSpeed[hydra]=3.
            call s__Hydra__set_attackPeriod(hydra,.25)
            call s__Hydra__set_duration(hydra,12)
            set s__Hydra_attackRange[hydra]=950.
            set s__Hydra_headHeight[hydra]=55.
            call s__Hydra__set_scale(hydra,1.)
            set s__Hydra_hasArcOrCurve[hydra]=false
            set s__Hydra_birthAnimationTime[hydra]=1.
            call s__Hydra_summon(hydra)
        endif
        return false
    endfunction
    
    function FireHydra___Init takes nothing returns nothing
        local trigger t= CreateTrigger()
        if UnitAddAbility(DemoMap_HERO, FireHydra___HYDRA_ABILITY) then
            call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            call TriggerAddCondition(t, Condition(function FireHydra___OnCast))
        endif
    endfunction
    
// scope FireHydra ends

//===========================================================================
// Trigger: Ice Hydra
//===========================================================================
//TESH.scrollpos=45
//TESH.alwaysfold=0

//===========================================================================
// Trigger: Friendly Hydra
//===========================================================================
//TESH.scrollpos=45
//TESH.alwaysfold=0
// scope FriendlyHydra begins



        function s__FriendlyHydra_onRemove takes integer missile returns boolean
            return true
        endfunction
    
        function s__FriendlyHydra_onTerrain takes integer missile returns boolean
            return true
        endfunction
    
        function s__FriendlyHydra_onCollide takes integer missile,unit hit returns boolean
            if ( UnitAlive(hit) and IsUnitAlly(hit, s__Missile_owner[missile]) ) then
                call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl", hit, "origin"))
                call SetWidgetLife(hit, GetWidgetLife(hit) + s__Missile_damage[missile])
                return true
            endif
            return false
        endfunction
    
//Implemented from module MissileStruct:
        
// Why not run some debug checks first.
//# static if true then
    
//#         static if not Missile_USE_DESTRUCTABLE_FILTER and FriendlyHydra.onDestructable.exists then
//#             Error Message from library Missile in struct FriendlyHydra !
//#             FriendlyHydra.onDestructable is a reserved name for Missile, once you implemented MissileStruct.
//#             Either you forgot to set Missile_USE_DESTRUCTABLE_FILTER = true in library Missile or re-name that method. 
//#         endif
            
//#         static if not Missile_USE_DESTRUCTABLE_FILTER and FriendlyHydra.onDestructableFilter.exists then
//#             Error Message from library Missile in struct FriendlyHydra !
//#             FriendlyHydra.onDestructableFilter is a reserved name for Missile, once you implemented MissileStruct.
//#             Either you forget to set Missile_USE_DESTRUCTABLE_FILTER = true in library Missile or re-name that method. 
//#         endif
    
//#         static if Missile_USE_DESTRUCTABLE_FILTER and FriendlyHydra.onDestructableFilter.exists and not FriendlyHydra.onDestructable.exists then
//#             Error Message from library Missile in struct FriendlyHydra !
//#             FriendlyHydra.onDestructableFilter only be used, when FriendlyHydra.onDestructable is also declared.
//#         endif
            
//#         static if FriendlyHydra.onMissile.exists then
//#             Error Message from library Missile in struct FriendlyHydra !
//#             FriendlyHydra.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#             FriendlyHydra.onMissile is currently not supported by library Missile. 
//#             Please delete or re-name that method.
//#         endif
//# endif
        
//#         static if Missile_USE_DESTRUCTABLE_FILTER and FriendlyHydra.onDestructableFilter.exists then
//#             // Stupid name chosen, to be unique in that struct ... hopefully.
//#             private static boolexpr MissileStruct__destConditionP = null
//#         endif
        
        // Stupid name ensures not to be called accidently.
        function s__FriendlyHydra_MissileStruct__missileTerminateP takes integer node returns nothing
//#             static if FriendlyHydra.onRemove.exists then
//#                 static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile__RecycleBin.recycle.exists then
                        if s__FriendlyHydra_onRemove(node) and ( GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID ) then
                            call s__Missile__RecycleBin_recycle(s__Missile_dummy[node])
                            call s__Missile_nullBefore(node)
                        endif
//#                 else
//#                     call FriendlyHydra.onRemove(node)
//#                 endif
//#             endif
            
            call s__Missile_terminate(node)
            call Missile__StopPeriodic(si__FriendlyHydra)
        endfunction
    
        // Returns boolean to be compile-able with Cohadars JassHelper.
        function s__FriendlyHydra_MissileStruct__missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile__missileStack[si__FriendlyHydra])
            local integer node
            local real collideZ
            local unit u
            
            // Move the whole stack.
            call s__Missile_move(this)
            loop
                exitwhen this == 0
                set node=s__Missile__get_next(this)
               
                if ( s__Missile_wantDestroy[this] ) then
//#                     static if FriendlyHydra.onFinish.exists then
//#                         if FriendlyHydra.onFinish(this) then
//#                             call FriendlyHydra.MissileStruct__missileTerminateP(this)
//#                         endif
//#                     else
                            call s__FriendlyHydra_MissileStruct__missileTerminateP(this)
//#                     endif
                else
                
//#                     static if FriendlyHydra.onCollide.exists then
                            if ( 0 != s__Missile_collision[this] ) then
                                call GroupEnumUnitsInRange(s__Missile_enumGroup, s__Missile_x[this], s__Missile_y[this], s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE, null)
                                loop
                                    set u=FirstOfGroup(s__Missile_enumGroup)
                                    exitwhen u == null
                                    call GroupRemoveUnit(s__Missile_enumGroup, u)
                                    if ( u != s__Missile_target[this] ) and IsUnitInRange(u, s__Missile_dummy[this], s__Missile_collision[this]) then
                                        
//#                                     static if Missile_USE_COLLISION_Z_FILTER then
                                            set collideZ=Missile_GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u) - s__Missile_terrainZ[this]
                                            if ( collideZ + GetUnitBodySize(u) >= s__Missile_z[this] - s__Missile_collisionZ[this] ) and ( collideZ <= s__Missile_z[this] + s__Missile_collisionZ[this] ) then
                                                if not ( IsUnitInGroup(u, s__Missile_unitsHit[this]) ) then
                                                    if s__FriendlyHydra_onCollide(this , u) then
                                                        call s__FriendlyHydra_MissileStruct__missileTerminateP(this)
                                                        exitwhen true
                                                    endif
                                        
                                                    call GroupAddUnit(s__Missile_unitsHit[this], u)
                                                endif
                                            endif
                                        
//#                                     else
//#                                     
//#                                         if not (IsUnitInGroup(u, this.unitsHit)) then
//#                                             if FriendlyHydra.onCollide(this, u) then
//#                                                 call FriendlyHydra.MissileStruct__missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                     
//#                                             call GroupAddUnit(this.unitsHit, u)
//#                                         endif                                    
//#                                     
//#                                     endif
                                    endif
                                endloop
                            endif
//#                     endif
                        
//#                     static if FriendlyHydra.onDestructable.exists then
//#                         // Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             set bj_enumDestructableRadius = this.collision + Missile_MAXIMUM_COLLISION_SIZE
//#                             set bj_destRandomCurrentPick  = null
//#                             call SetRect(Missile.enumRect, this.x - bj_enumDestructableRadius, this.y - bj_enumDestructableRadius, this.x + bj_enumDestructableRadius, this.y + bj_enumDestructableRadius)
//#                             set bj_enumDestructableRadius = this.collision*this.collision
//#                             set Missile.temp              = this
//#                             set Missile.tempDist          = bj_enumDestructableRadius + 1
//#                             static if FriendlyHydra.onDestructableFilter.exists then
//#                                 call EnumDestructablesInRect(Missile.enumRect, FriendlyHydra.MissileStruct__destConditionP, function Missile.actionFuncDest)
//#                             else
//#                                 call EnumDestructablesInRect(Missile.enumRect, null, function Missile.actionFuncDest)
//#                             endif
//#                             if (bj_destRandomCurrentPick != null) and FriendlyHydra.onDestructable(this, bj_destRandomCurrentPick) then
//#                                 call MissileStruct__missileTerminateP(this)
//#                             endif
//#                         endif
//#                     endif
                
                    if ( s__Missile_recycle[this] ) and ( s__Missile_allocated[this] ) then
//#                         static if FriendlyHydra.onCollide.exists then
//#                             static if FriendlyHydra.onFinish.exists then
//#                                 if (this.target == null) then
//#                                     if FriendlyHydra.onFinish(this) then
//#                                         call FriendlyHydra.MissileStruct__missileTerminateP(this)
//#                                     else
//#                                         set this.recycle = false
//#                                     endif
//#                                     
//#                                 elseif FriendlyHydra.onCollide(this, this.target) then
//#                                     call FriendlyHydra.MissileStruct__missileTerminateP(this)
//#                                 else
//#                                     set this.recycle = false
//#                                 endif
//#                             else
                                    if ( s__Missile_target[this] == null ) then
                                        call s__FriendlyHydra_MissileStruct__missileTerminateP(this)
                                    elseif s__FriendlyHydra_onCollide(this , s__Missile_target[this]) then
                                        call s__FriendlyHydra_MissileStruct__missileTerminateP(this)
                                    else
                                        set s__Missile_recycle[this]=false
                                    endif
//#                             endif
//#                         else
//#                             static if FriendlyHydra.onFinish.exists then
//#                                 if FriendlyHydra.onFinish(this) then
//#                                     call FriendlyHydra.MissileStruct__missileTerminateP(this)
//#                                 else
//#                                     set this.recycle = false
//#                                 endif
//#                             else
//#                                 call FriendlyHydra.MissileStruct__missileTerminateP(this)
//#                             endif
//#                         endif                    
                    endif
                
//#                     static if FriendlyHydra.onTerrain.exists then
                            if ( s__Missile_allocated[this] ) and ( s__Missile_z[this] < 0 ) and s__FriendlyHydra_onTerrain(this) then
//#                             static if FriendlyHydra.onFinish.exists then
//#                                 if FriendlyHydra.onFinish(this) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             else
                                    call s__FriendlyHydra_MissileStruct__missileTerminateP(this)
//#                             endif
                            endif
//#                     endif
                
                    // Runs last
//#                     static if FriendlyHydra.onPeriod.exists then
//#                         if (this.allocated) and FriendlyHydra.onPeriod(this) then
//#                             static if FriendlyHydra.onFinish.exists then
//#                                 if FriendlyHydra.onFinish(this) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             else
//#                                 call MissileStruct__missileTerminateP(this)
//#                             endif 
//#                         endif
//#                     endif
                endif
                set this=node
            endloop
           
            set u=null
            return false
        endfunction
    
        function s__FriendlyHydra_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "FriendlyHydra", "launch", "missile.launched", missile, "Missile Was Already Launched Before!")
//#             endif
        
            call s__Missile_insertEnd(Missile__missileStack[si__FriendlyHydra],missile)
            call Missile__StartPeriodic(si__FriendlyHydra)
             set s__Missile_launched[missile]=true
        endfunction
    
        function s__FriendlyHydra_MissileStruct__onInit takes nothing returns nothing
            set Missile__missileStack[si__FriendlyHydra]=s__Missile_allocateCollection()
            call Missile__MissileCreateExpression(si__FriendlyHydra , function s__FriendlyHydra_MissileStruct__missileIterateP)
//#             static if FriendlyHydra.onDestructableFilter.exists then
//#                 set FriendlyHydra.MissileStruct__destConditionP  = Condition(function FriendlyHydra.onDestructableFilter)
//#             endif
        endfunction
    
        
        function s__FriendlyHydra_onFire takes integer this,unit shooter,unit target,integer missile returns nothing
            call s__Missile__set_model(missile,"Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl")
            call s__Missile__set_scale(missile,1.2)
            set s__Missile_damage[missile]=GetRandomReal(25., 40.)
            set s__Missile_collision[missile]=32.
            set s__Missile_collisionZ[missile]=15.
            set s__Missile_speed[missile]=8.
            call s__Missile__set_arc(missile,( bj_PI / 2.5 )) // You can only use arc/curve when hasArcOrCurve is set to true.
            set s__Missile_target[missile]=target
            call s__FriendlyHydra_launch(missile)
        endfunction
        
        function s__FriendlyHydra_onTargetFilter takes integer this,unit target,player owner returns boolean
            return UnitAlive(target) and IsUnitAlly(target, owner) and GetWidgetLife(target) != GetUnitState(target, UNIT_STATE_MAX_LIFE)
        endfunction
    
        function s__FriendlyHydra_onRemoveHead takes integer this,unit head returns nothing
        endfunction
    
        function s__FriendlyHydra_onSummonHead takes integer this,unit head returns nothing
        endfunction
        

    function FriendlyHydra___OnCast takes nothing returns boolean
        local integer hydra
        local real x= GetSpellTargetX()
        local real y= GetSpellTargetY()
        local real z= 0.
        local real face= GetRandomReal(0., 2 * bj_PI) * bj_RADTODEG
        local real interval= .23

        if ( GetSpellAbilityId() == FriendlyHydra___HYDRA_ABILITY ) then
            set hydra=s__FriendlyHydra__allocate(GetTriggerUnit() , FriendlyHydra___HYDRA_UNIT_ID , x , y , z , face , interval)
            set s__Hydra_headHeight[hydra]=55.
            call s__Hydra__set_scale(hydra,1.2)
            call s__Hydra__set_attackAnimationTime(hydra,.5)
            call s__Hydra__set_attackPeriod(hydra,1.)
            set s__Hydra_attackSpeed[hydra]=3.
            call s__Hydra__set_duration(hydra,20.)
            set s__Hydra_attackRange[hydra]=600.
            set s__Hydra_heads[hydra]=3
            call s__Hydra__set_offset(hydra,8.)
            set s__Hydra_hasArcOrCurve[hydra]=true
            set s__Hydra_birthAnimationTime[hydra]=1.
            call s__Hydra_optimize(hydra)
            call s__Hydra_summon(hydra)
        endif
        return false
    endfunction
    
    function FriendlyHydra___Init takes nothing returns nothing
        local trigger t= CreateTrigger()
        if UnitAddAbility(DemoMap_HERO, FriendlyHydra___HYDRA_ABILITY) then
            call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            call TriggerAddCondition(t, Condition(function FriendlyHydra___OnCast))
        endif
    endfunction
    
// scope FriendlyHydra ends

//===========================================================================
// Trigger: Easter Egg
//===========================================================================
//TESH.scrollpos=2
//TESH.alwaysfold=0
// scope EasterEgg begins

    
    function EasterEgg___PauseSound takes nothing returns nothing
        set EasterEgg___paused=true
        call TriggerSleepAction(1.)
        set EasterEgg___paused=false
    endfunction
    
    function EasterEgg___CoolSound takes string path,player p,boolean forceSound returns nothing
        local sound s
        if not forceSound and EasterEgg___paused then
            return
        endif
        call ExecuteFunc("EasterEgg___PauseSound")
        set s=CreateSound(path, false, false, false, 10, 10, "CombatSoundsEAX")
        if GetLocalPlayer() != p then
            call SetSoundVolume(s, 0)
        endif
        call StartSound(s)
        call KillSoundWhenDone(s)
        set s=null
    endfunction

    
        function s__HammerTime_onDestructable takes integer missile,destructable hit returns boolean
            return true
        endfunction
    
        function s__HammerTime_onRemove takes integer missile returns boolean
            return true
        endfunction
    
        function s__HammerTime_onTerrain takes integer missile returns boolean
            return true
        endfunction
    
        function s__HammerTime_onCollide takes integer missile,unit hit returns boolean
            if UnitAlive(hit) and IsUnitEnemy(hit, s__Missile_owner[missile]) then
                call UnitDamageTarget(s__Missile_source[missile], hit, s__Missile_damage[missile], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
                if not UnitAlive(hit) and ( GetUnitTypeId(hit) != 0 ) then
                    call EasterEgg___CoolSound("Units\\Human\\Muradin\\MuradinYesAttack3.wav" , s__Missile_owner[missile] , false)
                    if ( IsUnitType(hit, UNIT_TYPE_GROUND) ) then
                        call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", GetUnitX(hit), GetUnitY(hit)))
                    endif
                endif
                return true
            endif
            return false
        endfunction
    
//Implemented from module MissileStruct:
        
// Why not run some debug checks first.
//# static if true then
    
//#         static if not Missile_USE_DESTRUCTABLE_FILTER and HammerTime.onDestructable.exists then
//#             Error Message from library Missile in struct HammerTime !
//#             HammerTime.onDestructable is a reserved name for Missile, once you implemented MissileStruct.
//#             Either you forgot to set Missile_USE_DESTRUCTABLE_FILTER = true in library Missile or re-name that method. 
//#         endif
            
//#         static if not Missile_USE_DESTRUCTABLE_FILTER and HammerTime.onDestructableFilter.exists then
//#             Error Message from library Missile in struct HammerTime !
//#             HammerTime.onDestructableFilter is a reserved name for Missile, once you implemented MissileStruct.
//#             Either you forget to set Missile_USE_DESTRUCTABLE_FILTER = true in library Missile or re-name that method. 
//#         endif
    
//#         static if Missile_USE_DESTRUCTABLE_FILTER and HammerTime.onDestructableFilter.exists and not HammerTime.onDestructable.exists then
//#             Error Message from library Missile in struct HammerTime !
//#             HammerTime.onDestructableFilter only be used, when HammerTime.onDestructable is also declared.
//#         endif
            
//#         static if HammerTime.onMissile.exists then
//#             Error Message from library Missile in struct HammerTime !
//#             HammerTime.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#             HammerTime.onMissile is currently not supported by library Missile. 
//#             Please delete or re-name that method.
//#         endif
//# endif
        
//#         static if Missile_USE_DESTRUCTABLE_FILTER and HammerTime.onDestructableFilter.exists then
//#             // Stupid name chosen, to be unique in that struct ... hopefully.
//#             private static boolexpr MissileStruct__destConditionP = null
//#         endif
        
        // Stupid name ensures not to be called accidently.
        function s__HammerTime_MissileStruct__missileTerminateP takes integer node returns nothing
//#             static if HammerTime.onRemove.exists then
//#                 static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile__RecycleBin.recycle.exists then
                        if s__HammerTime_onRemove(node) and ( GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID ) then
                            call s__Missile__RecycleBin_recycle(s__Missile_dummy[node])
                            call s__Missile_nullBefore(node)
                        endif
//#                 else
//#                     call HammerTime.onRemove(node)
//#                 endif
//#             endif
            
            call s__Missile_terminate(node)
            call Missile__StopPeriodic(si__HammerTime)
        endfunction
    
        // Returns boolean to be compile-able with Cohadars JassHelper.
        function s__HammerTime_MissileStruct__missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile__missileStack[si__HammerTime])
            local integer node
            local real collideZ
            local unit u
            
            // Move the whole stack.
            call s__Missile_move(this)
            loop
                exitwhen this == 0
                set node=s__Missile__get_next(this)
               
                if ( s__Missile_wantDestroy[this] ) then
//#                     static if HammerTime.onFinish.exists then
//#                         if HammerTime.onFinish(this) then
//#                             call HammerTime.MissileStruct__missileTerminateP(this)
//#                         endif
//#                     else
                            call s__HammerTime_MissileStruct__missileTerminateP(this)
//#                     endif
                else
                
//#                     static if HammerTime.onCollide.exists then
                            if ( 0 != s__Missile_collision[this] ) then
                                call GroupEnumUnitsInRange(s__Missile_enumGroup, s__Missile_x[this], s__Missile_y[this], s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE, null)
                                loop
                                    set u=FirstOfGroup(s__Missile_enumGroup)
                                    exitwhen u == null
                                    call GroupRemoveUnit(s__Missile_enumGroup, u)
                                    if ( u != s__Missile_target[this] ) and IsUnitInRange(u, s__Missile_dummy[this], s__Missile_collision[this]) then
                                        
//#                                     static if Missile_USE_COLLISION_Z_FILTER then
                                            set collideZ=Missile_GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u) - s__Missile_terrainZ[this]
                                            if ( collideZ + GetUnitBodySize(u) >= s__Missile_z[this] - s__Missile_collisionZ[this] ) and ( collideZ <= s__Missile_z[this] + s__Missile_collisionZ[this] ) then
                                                if not ( IsUnitInGroup(u, s__Missile_unitsHit[this]) ) then
                                                    if s__HammerTime_onCollide(this , u) then
                                                        call s__HammerTime_MissileStruct__missileTerminateP(this)
                                                        exitwhen true
                                                    endif
                                        
                                                    call GroupAddUnit(s__Missile_unitsHit[this], u)
                                                endif
                                            endif
                                        
//#                                     else
//#                                     
//#                                         if not (IsUnitInGroup(u, this.unitsHit)) then
//#                                             if HammerTime.onCollide(this, u) then
//#                                                 call HammerTime.MissileStruct__missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                     
//#                                             call GroupAddUnit(this.unitsHit, u)
//#                                         endif                                    
//#                                     
//#                                     endif
                                    endif
                                endloop
                            endif
//#                     endif
                        
//#                     static if HammerTime.onDestructable.exists then
                            // Check if the missile is not terminated.
                            if ( s__Missile_allocated[this] ) and ( 0 != s__Missile_collision[this] ) then
                                set bj_enumDestructableRadius=s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE
                                set bj_destRandomCurrentPick=null
                                call SetRect(s__Missile_enumRect, s__Missile_x[this] - bj_enumDestructableRadius, s__Missile_y[this] - bj_enumDestructableRadius, s__Missile_x[this] + bj_enumDestructableRadius, s__Missile_y[this] + bj_enumDestructableRadius)
                                set bj_enumDestructableRadius=s__Missile_collision[this] * s__Missile_collision[this]
                                set s__Missile_temp=this
                                set s__Missile_tempDist=bj_enumDestructableRadius + 1
//#                             static if HammerTime.onDestructableFilter.exists then
//#                                 call EnumDestructablesInRect(Missile.enumRect, HammerTime.MissileStruct__destConditionP, function Missile.actionFuncDest)
//#                             else
                                    call EnumDestructablesInRect(s__Missile_enumRect, null, function s__Missile_actionFuncDest)
//#                             endif
                                if ( bj_destRandomCurrentPick != null ) and s__HammerTime_onDestructable(this , bj_destRandomCurrentPick) then
                                    call s__HammerTime_MissileStruct__missileTerminateP(this)
                                endif
                            endif
//#                     endif
                
                    if ( s__Missile_recycle[this] ) and ( s__Missile_allocated[this] ) then
//#                         static if HammerTime.onCollide.exists then
//#                             static if HammerTime.onFinish.exists then
//#                                 if (this.target == null) then
//#                                     if HammerTime.onFinish(this) then
//#                                         call HammerTime.MissileStruct__missileTerminateP(this)
//#                                     else
//#                                         set this.recycle = false
//#                                     endif
//#                                     
//#                                 elseif HammerTime.onCollide(this, this.target) then
//#                                     call HammerTime.MissileStruct__missileTerminateP(this)
//#                                 else
//#                                     set this.recycle = false
//#                                 endif
//#                             else
                                    if ( s__Missile_target[this] == null ) then
                                        call s__HammerTime_MissileStruct__missileTerminateP(this)
                                    elseif s__HammerTime_onCollide(this , s__Missile_target[this]) then
                                        call s__HammerTime_MissileStruct__missileTerminateP(this)
                                    else
                                        set s__Missile_recycle[this]=false
                                    endif
//#                             endif
//#                         else
//#                             static if HammerTime.onFinish.exists then
//#                                 if HammerTime.onFinish(this) then
//#                                     call HammerTime.MissileStruct__missileTerminateP(this)
//#                                 else
//#                                     set this.recycle = false
//#                                 endif
//#                             else
//#                                 call HammerTime.MissileStruct__missileTerminateP(this)
//#                             endif
//#                         endif                    
                    endif
                
//#                     static if HammerTime.onTerrain.exists then
                            if ( s__Missile_allocated[this] ) and ( s__Missile_z[this] < 0 ) and s__HammerTime_onTerrain(this) then
//#                             static if HammerTime.onFinish.exists then
//#                                 if HammerTime.onFinish(this) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             else
                                    call s__HammerTime_MissileStruct__missileTerminateP(this)
//#                             endif
                            endif
//#                     endif
                
                    // Runs last
//#                     static if HammerTime.onPeriod.exists then
//#                         if (this.allocated) and HammerTime.onPeriod(this) then
//#                             static if HammerTime.onFinish.exists then
//#                                 if HammerTime.onFinish(this) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             else
//#                                 call MissileStruct__missileTerminateP(this)
//#                             endif 
//#                         endif
//#                     endif
                endif
                set this=node
            endloop
           
            set u=null
            return false
        endfunction
    
        function s__HammerTime_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "HammerTime", "launch", "missile.launched", missile, "Missile Was Already Launched Before!")
//#             endif
        
            call s__Missile_insertEnd(Missile__missileStack[si__HammerTime],missile)
            call Missile__StartPeriodic(si__HammerTime)
             set s__Missile_launched[missile]=true
        endfunction
    
        function s__HammerTime_MissileStruct__onInit takes nothing returns nothing
            set Missile__missileStack[si__HammerTime]=s__Missile_allocateCollection()
            call Missile__MissileCreateExpression(si__HammerTime , function s__HammerTime_MissileStruct__missileIterateP)
//#             static if HammerTime.onDestructableFilter.exists then
//#                 set HammerTime.MissileStruct__destConditionP  = Condition(function HammerTime.onDestructableFilter)
//#             endif
        endfunction
    
        
        function s__HammerTime_onFire takes integer this,unit shooter,unit target,integer missile returns nothing
            call s__Missile__set_model(missile,"Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl")
            set s__Missile_damage[missile]=GetRandomReal(150, 550)
            set s__Missile_collision[missile]=36. * s__Hydra__get_scale(this)
            set s__Missile_collisionZ[missile]=15. * s__Hydra__get_scale(this)
            set s__Missile_speed[missile]=10.
            call s__Missile__set_scale(missile,s__Hydra__get_scale(this))
            set EasterEgg___count[this]=EasterEgg___count[this] + 1
            if EasterEgg___count[this] == 6 then
                call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Avatar\\AvatarCaster.mdl", shooter, "origin"))
                set s__Hydra_attackSpeed[this]=s__Hydra_attackSpeed[this] / 2.
                call s__Hydra__set_scale(this,s__Hydra__get_scale(this) * 2)
                call SetUnitVertexColor(shooter, 150, 150, 150, 200)
            endif
            call s__HammerTime_launch(missile)
        endfunction
        
        function s__HammerTime_onTargetFilter takes integer this,unit target,player owner returns boolean
            return UnitAlive(target) and IsUnitEnemy(target, owner)
        endfunction
    
        function s__HammerTime_onRemoveHead takes integer this,unit head returns nothing
            call RemoveUnit(head)
        endfunction
    
        function s__HammerTime_onSummonHead takes integer this,unit head returns nothing
            call EasterEgg___CoolSound("Units\\Human\\Muradin\\MuradinYes4.wav" , s__Hydra_owner[this] , true)
            set EasterEgg___count[this]=0
        endfunction
        
    
    function EasterEgg___OnCast takes nothing returns boolean
        local integer hydra
        local real x= GetSpellTargetX()
        local real y= GetSpellTargetY()
        local real z= GetRandomReal(0, 600)
        local real face= GetRandomReal(0., 2 * bj_PI) * bj_RADTODEG
        local real interval= .23

        if ( GetSpellAbilityId() == EasterEgg___HYDRA_ABILITY ) then
            set hydra=s__HammerTime__allocate(GetTriggerUnit() , EasterEgg___HYDRA_UNIT_ID , x , y , z , face , interval)
            set s__Hydra_headHeight[hydra]=45.
            call s__Hydra__set_scale(hydra,.76)
            call s__Hydra__set_attackAnimationTime(hydra,.5)
            call s__Hydra__set_attackPeriod(hydra,.2)
            set s__Hydra_attackSpeed[hydra]=1.
            call s__Hydra__set_duration(hydra,10.)
            set s__Hydra_attackRange[hydra]=750.
            set s__Hydra_heads[hydra]=1
            call s__Hydra__set_offset(hydra,8.)
            set s__Hydra_hasArcOrCurve[hydra]=false
            call s__Hydra_summon(hydra)
        endif
        return false
    endfunction
    
    function EasterEgg___Pre takes nothing returns nothing
        call EasterEgg___CoolSound("Units\\Human\\Muradin\\MuradinYes4.wav" , null , true)
        call EasterEgg___CoolSound("Units\\Human\\Muradin\\MuradinYesAttack3.wav" , null , true)
        call DestroyTimer(GetExpiredTimer())
    endfunction
    
    function EasterEgg___Init takes nothing returns nothing
        local trigger t= CreateTrigger()
        if UnitAddAbility(DemoMap_HERO, EasterEgg___HYDRA_ABILITY) then
            call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            call TriggerAddCondition(t, Condition(function EasterEgg___OnCast))
        endif
        call TimerStart(CreateTimer(), 1., false, function EasterEgg___Pre)
    endfunction
    
// scope EasterEgg ends

//===========================================================================
// Trigger: Hill Guardian
//===========================================================================
//TESH.scrollpos=44
//TESH.alwaysfold=0
// scope HillGuard begins
    

    
// This is the big revenant on the hill. Right corner of the map.
function HillGuard___cb takes nothing returns nothing
    call ReleaseTimer(GetExpiredTimer())
    set HillGuard___READY=true
endfunction


    function s__Guard_onRemove takes integer missile returns boolean
        return true
    endfunction
    
    function s__Guard_onTerrain takes integer missile returns boolean
        return true
    endfunction

    function s__Guard_onCollide takes integer missile,unit hit returns boolean
        if UnitAlive(hit) and IsUnitEnemy(hit, s__Missile_owner[missile]) then
            return UnitDamageTarget(s__Missile_source[missile], hit, s__Missile_damage[missile], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
        endif
        return false
    endfunction

//Implemented from module MissileStruct:
        
// Why not run some debug checks first.
//# static if true then
    
//#         static if not Missile_USE_DESTRUCTABLE_FILTER and Guard.onDestructable.exists then
//#             Error Message from library Missile in struct Guard !
//#             Guard.onDestructable is a reserved name for Missile, once you implemented MissileStruct.
//#             Either you forgot to set Missile_USE_DESTRUCTABLE_FILTER = true in library Missile or re-name that method. 
//#         endif
            
//#         static if not Missile_USE_DESTRUCTABLE_FILTER and Guard.onDestructableFilter.exists then
//#             Error Message from library Missile in struct Guard !
//#             Guard.onDestructableFilter is a reserved name for Missile, once you implemented MissileStruct.
//#             Either you forget to set Missile_USE_DESTRUCTABLE_FILTER = true in library Missile or re-name that method. 
//#         endif
    
//#         static if Missile_USE_DESTRUCTABLE_FILTER and Guard.onDestructableFilter.exists and not Guard.onDestructable.exists then
//#             Error Message from library Missile in struct Guard !
//#             Guard.onDestructableFilter only be used, when Guard.onDestructable is also declared.
//#         endif
            
//#         static if Guard.onMissile.exists then
//#             Error Message from library Missile in struct Guard !
//#             Guard.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#             Guard.onMissile is currently not supported by library Missile. 
//#             Please delete or re-name that method.
//#         endif
//# endif
        
//#         static if Missile_USE_DESTRUCTABLE_FILTER and Guard.onDestructableFilter.exists then
//#             // Stupid name chosen, to be unique in that struct ... hopefully.
//#             private static boolexpr MissileStruct__destConditionP = null
//#         endif
        
        // Stupid name ensures not to be called accidently.
        function s__Guard_MissileStruct__missileTerminateP takes integer node returns nothing
//#             static if Guard.onRemove.exists then
//#                 static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile__RecycleBin.recycle.exists then
                        if s__Guard_onRemove(node) and ( GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID ) then
                            call s__Missile__RecycleBin_recycle(s__Missile_dummy[node])
                            call s__Missile_nullBefore(node)
                        endif
//#                 else
//#                     call Guard.onRemove(node)
//#                 endif
//#             endif
            
            call s__Missile_terminate(node)
            call Missile__StopPeriodic(si__Guard)
        endfunction
    
        // Returns boolean to be compile-able with Cohadars JassHelper.
        function s__Guard_MissileStruct__missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile__missileStack[si__Guard])
            local integer node
            local real collideZ
            local unit u
            
            // Move the whole stack.
            call s__Missile_move(this)
            loop
                exitwhen this == 0
                set node=s__Missile__get_next(this)
               
                if ( s__Missile_wantDestroy[this] ) then
//#                     static if Guard.onFinish.exists then
//#                         if Guard.onFinish(this) then
//#                             call Guard.MissileStruct__missileTerminateP(this)
//#                         endif
//#                     else
                            call s__Guard_MissileStruct__missileTerminateP(this)
//#                     endif
                else
                
//#                     static if Guard.onCollide.exists then
                            if ( 0 != s__Missile_collision[this] ) then
                                call GroupEnumUnitsInRange(s__Missile_enumGroup, s__Missile_x[this], s__Missile_y[this], s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE, null)
                                loop
                                    set u=FirstOfGroup(s__Missile_enumGroup)
                                    exitwhen u == null
                                    call GroupRemoveUnit(s__Missile_enumGroup, u)
                                    if ( u != s__Missile_target[this] ) and IsUnitInRange(u, s__Missile_dummy[this], s__Missile_collision[this]) then
                                        
//#                                     static if Missile_USE_COLLISION_Z_FILTER then
                                            set collideZ=Missile_GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u) - s__Missile_terrainZ[this]
                                            if ( collideZ + GetUnitBodySize(u) >= s__Missile_z[this] - s__Missile_collisionZ[this] ) and ( collideZ <= s__Missile_z[this] + s__Missile_collisionZ[this] ) then
                                                if not ( IsUnitInGroup(u, s__Missile_unitsHit[this]) ) then
                                                    if s__Guard_onCollide(this , u) then
                                                        call s__Guard_MissileStruct__missileTerminateP(this)
                                                        exitwhen true
                                                    endif
                                        
                                                    call GroupAddUnit(s__Missile_unitsHit[this], u)
                                                endif
                                            endif
                                        
//#                                     else
//#                                     
//#                                         if not (IsUnitInGroup(u, this.unitsHit)) then
//#                                             if Guard.onCollide(this, u) then
//#                                                 call Guard.MissileStruct__missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                     
//#                                             call GroupAddUnit(this.unitsHit, u)
//#                                         endif                                    
//#                                     
//#                                     endif
                                    endif
                                endloop
                            endif
//#                     endif
                        
//#                     static if Guard.onDestructable.exists then
//#                         // Check if the missile is not terminated.
//#                         if (this.allocated) and (0 != this.collision) then
//#                             set bj_enumDestructableRadius = this.collision + Missile_MAXIMUM_COLLISION_SIZE
//#                             set bj_destRandomCurrentPick  = null
//#                             call SetRect(Missile.enumRect, this.x - bj_enumDestructableRadius, this.y - bj_enumDestructableRadius, this.x + bj_enumDestructableRadius, this.y + bj_enumDestructableRadius)
//#                             set bj_enumDestructableRadius = this.collision*this.collision
//#                             set Missile.temp              = this
//#                             set Missile.tempDist          = bj_enumDestructableRadius + 1
//#                             static if Guard.onDestructableFilter.exists then
//#                                 call EnumDestructablesInRect(Missile.enumRect, Guard.MissileStruct__destConditionP, function Missile.actionFuncDest)
//#                             else
//#                                 call EnumDestructablesInRect(Missile.enumRect, null, function Missile.actionFuncDest)
//#                             endif
//#                             if (bj_destRandomCurrentPick != null) and Guard.onDestructable(this, bj_destRandomCurrentPick) then
//#                                 call MissileStruct__missileTerminateP(this)
//#                             endif
//#                         endif
//#                     endif
                
                    if ( s__Missile_recycle[this] ) and ( s__Missile_allocated[this] ) then
//#                         static if Guard.onCollide.exists then
//#                             static if Guard.onFinish.exists then
//#                                 if (this.target == null) then
//#                                     if Guard.onFinish(this) then
//#                                         call Guard.MissileStruct__missileTerminateP(this)
//#                                     else
//#                                         set this.recycle = false
//#                                     endif
//#                                     
//#                                 elseif Guard.onCollide(this, this.target) then
//#                                     call Guard.MissileStruct__missileTerminateP(this)
//#                                 else
//#                                     set this.recycle = false
//#                                 endif
//#                             else
                                    if ( s__Missile_target[this] == null ) then
                                        call s__Guard_MissileStruct__missileTerminateP(this)
                                    elseif s__Guard_onCollide(this , s__Missile_target[this]) then
                                        call s__Guard_MissileStruct__missileTerminateP(this)
                                    else
                                        set s__Missile_recycle[this]=false
                                    endif
//#                             endif
//#                         else
//#                             static if Guard.onFinish.exists then
//#                                 if Guard.onFinish(this) then
//#                                     call Guard.MissileStruct__missileTerminateP(this)
//#                                 else
//#                                     set this.recycle = false
//#                                 endif
//#                             else
//#                                 call Guard.MissileStruct__missileTerminateP(this)
//#                             endif
//#                         endif                    
                    endif
                
//#                     static if Guard.onTerrain.exists then
                            if ( s__Missile_allocated[this] ) and ( s__Missile_z[this] < 0 ) and s__Guard_onTerrain(this) then
//#                             static if Guard.onFinish.exists then
//#                                 if Guard.onFinish(this) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             else
                                    call s__Guard_MissileStruct__missileTerminateP(this)
//#                             endif
                            endif
//#                     endif
                
                    // Runs last
//#                     static if Guard.onPeriod.exists then
//#                         if (this.allocated) and Guard.onPeriod(this) then
//#                             static if Guard.onFinish.exists then
//#                                 if Guard.onFinish(this) then
//#                                     call MissileStruct__missileTerminateP(this)
//#                                 endif
//#                             else
//#                                 call MissileStruct__missileTerminateP(this)
//#                             endif 
//#                         endif
//#                     endif
                endif
                set this=node
            endloop
           
            set u=null
            return false
        endfunction
    
        function s__Guard_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "Guard", "launch", "missile.launched", missile, "Missile Was Already Launched Before!")
//#             endif
        
            call s__Missile_insertEnd(Missile__missileStack[si__Guard],missile)
            call Missile__StartPeriodic(si__Guard)
             set s__Missile_launched[missile]=true
        endfunction
    
        function s__Guard_MissileStruct__onInit takes nothing returns nothing
            set Missile__missileStack[si__Guard]=s__Missile_allocateCollection()
            call Missile__MissileCreateExpression(si__Guard , function s__Guard_MissileStruct__missileIterateP)
//#             static if Guard.onDestructableFilter.exists then
//#                 set Guard.MissileStruct__destConditionP  = Condition(function Guard.onDestructableFilter)
//#             endif
        endfunction
    
    
    function s__Guard_onTargetFilter takes integer this,unit target,player owner returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner)
    endfunction
    
    function s__Guard_onFire takes integer this,unit shooter,unit target,integer missile returns nothing
        call s__Missile__set_model(missile,"Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl")
        call s__Missile__set_scale(missile,1.)
        set s__Missile_damage[missile]=GetRandomReal(50, 150)
        set s__Missile_collision[missile]=32.
        set s__Missile_collisionZ[missile]=15.
        set s__Missile_speed[missile]=27.
        call s__Missile__set_arc(missile,bj_PI / 3)
        call s__Missile__set_curve(missile,GetRandomReal(- bj_PI / 3, bj_PI / 3))
        call s__Guard_launch(missile)
    endfunction


function HillGuard___enter takes nothing returns boolean
    local unit u= GetTriggerUnit()
    local real x= GetUnitX(u)
    local real y= GetUnitY(u)
    local player p= GetOwningPlayer(u)
    if Player(0) == p and HillGuard___READY then
        if ( HillGuard___GUARDIAN != 0 ) and s__Hydra_summoned[HillGuard___GUARDIAN] then
            call s__Hydra_destroy(HillGuard___GUARDIAN)
            set HillGuard___GUARDIAN=0
        endif
        set HillGuard___GUARDIAN=s__Guard__allocate(HillGuard___REVENANT , 'o002' , x , y , 0 , 225. , 0.23)
        set s__Hydra_headHeight[HillGuard___GUARDIAN]=55.
        call s__Hydra__set_scale(HillGuard___GUARDIAN,1.0)
        call s__Hydra__set_attackAnimationTime(HillGuard___GUARDIAN,.5)
        set s__Hydra_attackSpeed[HillGuard___GUARDIAN]=3.2
        call s__Hydra__set_attackPeriod(HillGuard___GUARDIAN,.5)
        call s__Hydra__set_duration(HillGuard___GUARDIAN,0.00)
        set s__Hydra_attackRange[HillGuard___GUARDIAN]=750.
        set s__Hydra_heads[HillGuard___GUARDIAN]=5
        set s__Hydra_hasArcOrCurve[HillGuard___GUARDIAN]=true
        set s__Hydra_birthAnimationTime[HillGuard___GUARDIAN]=1.
        call s__Hydra_summon(HillGuard___GUARDIAN)
        //----------------------------
        call SetUnitFacing(HillGuard___REVENANT, Atan2(y - GetUnitY(HillGuard___REVENANT), x - GetUnitX(HillGuard___REVENANT)) * bj_RADTODEG)
        call SetUnitAnimation(HillGuard___REVENANT, "spell")
        call QueueUnitAnimation(HillGuard___REVENANT, "stand")
        set HillGuard___READY=false
        call TimerStart(NewTimer(), 4.00, false, function HillGuard___cb)
    endif
    set p=null
    set u=null
    return false
endfunction
    
    function HillGuard___Init takes nothing returns nothing
        local region r= CreateRegion()
        local trigger t= CreateTrigger()
        local rect c= Rect(64, - 2624, 384, - 2336)

        call RegionAddRect(r, c)
        call TriggerRegisterEnterRegion(t, r, null)
        call TriggerAddCondition(t, Filter(function HillGuard___enter))
        set t=null
        set r=null
        set c=null
    
        set HillGuard___REVENANT=CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'nlrv', 127., - 3072., 0)
        call UnitAddAbility(HillGuard___REVENANT, 'Aloc')
        call UnitAddAbility(HillGuard___REVENANT, 'Abun')

    endfunction

// scope HillGuard ends

//===========================================================================
// Trigger: This Map only
//===========================================================================
//TESH.scrollpos=24
//TESH.alwaysfold=0

//===========================================================================
function InitCustomTriggers takes nothing returns nothing
    //Function not found: call InitTrig_Missile()
    //Function not found: call InitTrig_TimerUtils()
    //Function not found: call InitTrig_World_Bounds()
    //Function not found: call InitTrig_Hydra()
    //Function not found: call InitTrig_Fire_Hydra()
    //Function not found: call InitTrig_Ice_Hydra()
    //Function not found: call InitTrig_Friendly_Hydra()
    //Function not found: call InitTrig_Easter_Egg()
    //Function not found: call InitTrig_Hill_Guardian()
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
    call CreateRegions()
    call CreateAllUnits()
    call InitBlizzard()

call ExecuteFunc("jasshelper__initstructs1115461953")
call ExecuteFunc("TimerUtils__init")
call ExecuteFunc("IceHydra___Init")
call FireHydra___Init()
call FriendlyHydra___Init()
call EasterEgg___Init()
call HillGuard___Init()

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
    call SetMapDescription("")
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
function sa__Hydra_onSummonHead takes nothing returns boolean
    call s__Hydra_onSummonHead(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__Hydra_onRemoveHead takes nothing returns boolean
    call s__Hydra_onRemoveHead(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__Hydra_onTargetFilter takes nothing returns boolean
    set f__result_boolean=s__Hydra_onTargetFilter(f__arg_this,f__arg_unit1,f__arg_player1)
   return true
endfunction
function sa__Hydra_onFire takes nothing returns boolean
    call s__Hydra_onFire(f__arg_this,f__arg_unit1,f__arg_unit2,f__arg_integer1)
   return true
endfunction
function sa__Hydra_attemptShoot takes nothing returns boolean

            local timer t= GetExpiredTimer()
            local integer this= (GetTimerData(t))
            local real elapsed= TimerGetElapsed(Hydra__STAMP)
            local integer head= s__Hydra_nextShootingHead[this]
            local real timeout
            if ( s__Hydra__HydraHead_lastShot[head] + s__Hydra_attackSpeed[this] <= elapsed ) then
                if ( s__Hydra_evaluateTarget(this,head) ) then
                    set s__Hydra_nextShootingHead[this]=s__Hydra__HydraHead__get_next(head)
                    if ( s__Hydra_nextShootingHead[this] == 0 ) then
                        set s__Hydra_nextShootingHead[this]=s__Hydra__HydraHead__get_first(s__Hydra_list[this])
                    endif
                    set s__Hydra__HydraHead_aimX[head]=GetUnitX(s__Hydra__HydraHead_target[head])
                    set s__Hydra__HydraHead_aimY[head]=GetUnitY(s__Hydra__HydraHead_target[head])
                    set s__Hydra__HydraHead_aimZ[head]=GetUnitFlyHeight(s__Hydra__HydraHead_target[head]) + GetUnitBodySize(s__Hydra__HydraHead_target[head]) * s__Missile_HIT_BOX
                    set s__Hydra__HydraHead_aimAngle[head]=Atan2(s__Hydra__HydraHead_aimY[head] - s__Hydra__HydraHead_y[head], s__Hydra__HydraHead_aimX[head] - s__Hydra__HydraHead_x[head])
                    set s__Hydra_currentHead[this]=head
                    set s__Hydra__HydraHead_lastShot[head]=elapsed
                    call SetUnitFacing(s__Hydra__HydraHead_unit[head], s__Hydra__HydraHead_aimAngle[head] * bj_RADTODEG)
                    if ( 1. != s__Hydra_timeScale[this] ) then
                        call SetUnitTimeScale(s__Hydra__HydraHead_unit[head], s__Hydra_timeScale[this])
                    endif
                    call SetUnitAnimation(s__Hydra__HydraHead_unit[head], Hydra__ATTACK + Hydra__animationSuffix[s__Hydra__HydraHead_number[head]])
                    call TimerStart(t, s__Hydra_animationTime_p[this], false, function s__Hydra_fire)
                elseif ( s__Hydra__HydraHead_size[s__Hydra_list[this]] > 1 ) then
                    set s__Hydra__HydraHead_lastShot[head]=elapsed
                    set head=s__Hydra__HydraHead__get_next(head)
                    if ( head == 0 ) then
                        set head=s__Hydra__HydraHead__get_first(s__Hydra_list[this])
                    endif
                    set s__Hydra_nextShootingHead[this]=head
                    set timeout=s__Hydra__HydraHead_lastShot[head] + s__Hydra_attackSpeed[this] - elapsed
                    if ( timeout < 0 ) then
                        set timeout=0.
                    elseif ( timeout > s__Hydra_attackPeriod_p[this] ) then
                        set timeout=s__Hydra_attackPeriod_p[this]
                    endif
                    call TimerStart(t, timeout, false, function s__Hydra_attemptShoot)
                else
                    call TimerStart(t, s__Hydra_attackPeriod_p[this], false, function s__Hydra_attemptShoot)
                endif
            else
                call TimerStart(t, RMaxBJ(0., s__Hydra__HydraHead_lastShot[head] + s__Hydra_attackSpeed[this] - elapsed), false, function s__Hydra_attemptShoot)
            endif
            set t=null
   return true
endfunction
function sa__Hydra_killHead takes nothing returns boolean

            local integer this= (GetTimerData(GetExpiredTimer()))
            local integer head= s__Hydra__HydraHead__get_first(s__Hydra_list[this])
            local integer node= s__Hydra__HydraHead__get_next(head)
            local real time= RMaxBJ(.0001, s__Hydra__HydraHead_lastShot[head] + ( s__Hydra_animationTime_p[this] * 2. ) - TimerGetElapsed(Hydra__STAMP))
            call UnitApplyTimedLife(s__Hydra__HydraHead_unit[head], Hydra__TIMED_LIFE, time)
            call sc__Hydra_onRemoveHead(this,s__Hydra__HydraHead_unit[head])
            set s__Hydra__HydraHead_unit[head]=null
            call s__Hydra__HydraHead_remove(head)
            if ( 0 == s__Hydra__HydraHead__get_first(s__Hydra_list[this]) ) then
                call s__Hydra_destroy(this)
            else
                if ( s__Hydra_nextShootingHead[this] == head ) then
                    if ( node == 0 ) then
                        set s__Hydra_nextShootingHead[this]=s__Hydra__HydraHead__get_first(s__Hydra_list[this])
                    else
                        set s__Hydra_nextShootingHead[this]=node
                    endif
                endif
                call TimerStart(s__Hydra_lifeTimer[this], s__Hydra_interval[this], false, function s__Hydra_killHead)
            endif
   return true
endfunction
function sa__Hydra_create takes nothing returns boolean
    set f__result_integer=s__Hydra_create(f__arg_unit1,f__arg_integer1,f__arg_real1,f__arg_real2,f__arg_real3,f__arg_real4,f__arg_real5)
   return true
endfunction
function sa__Guard_onTargetFilter takes nothing returns boolean
    set f__result_boolean=s__Guard_onTargetFilter(f__arg_this,f__arg_unit1,f__arg_player1)
   return true
endfunction
function sa__Guard_onFire takes nothing returns boolean
    call s__Guard_onFire(f__arg_this,f__arg_unit1,f__arg_unit2,f__arg_integer1)
   return true
endfunction
function sa__IceHydra_onFire takes nothing returns boolean
    call s__IceHydra_onFire(f__arg_this,f__arg_unit1,f__arg_unit2,f__arg_integer1)
   return true
endfunction
function sa__IceHydra_onTargetFilter takes nothing returns boolean
    set f__result_boolean=s__IceHydra_onTargetFilter(f__arg_this,f__arg_unit1,f__arg_player1)
   return true
endfunction
function sa__IceHydra_onRemoveHead takes nothing returns boolean
    call s__IceHydra_onRemoveHead(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__IceHydra_onSummonHead takes nothing returns boolean
    call s__IceHydra_onSummonHead(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__FireHydra_onFire takes nothing returns boolean
    call s__FireHydra_onFire(f__arg_this,f__arg_unit1,f__arg_unit2,f__arg_integer1)
   return true
endfunction
function sa__FireHydra_onTargetFilter takes nothing returns boolean
    set f__result_boolean=s__FireHydra_onTargetFilter(f__arg_this,f__arg_unit1,f__arg_player1)
   return true
endfunction
function sa__FireHydra_onRemoveHead takes nothing returns boolean
    call s__FireHydra_onRemoveHead(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__FireHydra_onSummonHead takes nothing returns boolean
    call s__FireHydra_onSummonHead(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__FriendlyHydra_onFire takes nothing returns boolean
    call s__FriendlyHydra_onFire(f__arg_this,f__arg_unit1,f__arg_unit2,f__arg_integer1)
   return true
endfunction
function sa__FriendlyHydra_onTargetFilter takes nothing returns boolean
    set f__result_boolean=s__FriendlyHydra_onTargetFilter(f__arg_this,f__arg_unit1,f__arg_player1)
   return true
endfunction
function sa__FriendlyHydra_onRemoveHead takes nothing returns boolean
    call s__FriendlyHydra_onRemoveHead(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__FriendlyHydra_onSummonHead takes nothing returns boolean
    call s__FriendlyHydra_onSummonHead(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__HammerTime_onFire takes nothing returns boolean
    call s__HammerTime_onFire(f__arg_this,f__arg_unit1,f__arg_unit2,f__arg_integer1)
   return true
endfunction
function sa__HammerTime_onTargetFilter takes nothing returns boolean
    set f__result_boolean=s__HammerTime_onTargetFilter(f__arg_this,f__arg_unit1,f__arg_player1)
   return true
endfunction
function sa__HammerTime_onRemoveHead takes nothing returns boolean
    call s__HammerTime_onRemoveHead(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__HammerTime_onSummonHead takes nothing returns boolean
    call s__HammerTime_onSummonHead(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa___prototype6_TimerUtils__init takes nothing returns boolean

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
function sa___prototype6_EasterEgg___PauseSound takes nothing returns boolean

        set EasterEgg___paused=true
        call TriggerSleepAction(1.)
        set EasterEgg___paused=false
    return true
endfunction

function jasshelper__initstructs1115461953 takes nothing returns nothing
    set st__Hydra_onSummonHead[8]=CreateTrigger()
    set st__Hydra_onSummonHead[13]=st__Hydra_onSummonHead[8]
    call TriggerAddCondition(st__Hydra_onSummonHead[8],Condition( function sa__Hydra_onSummonHead))
    call TriggerAddAction(st__Hydra_onSummonHead[8], function sa__Hydra_onSummonHead)
    set st__Hydra_onRemoveHead[8]=CreateTrigger()
    set st__Hydra_onRemoveHead[13]=st__Hydra_onRemoveHead[8]
    call TriggerAddCondition(st__Hydra_onRemoveHead[8],Condition( function sa__Hydra_onRemoveHead))
    call TriggerAddAction(st__Hydra_onRemoveHead[8], function sa__Hydra_onRemoveHead)
    set st__Hydra_onTargetFilter[8]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onTargetFilter[8],Condition( function sa__Hydra_onTargetFilter))
    call TriggerAddAction(st__Hydra_onTargetFilter[8], function sa__Hydra_onTargetFilter)
    set st__Hydra_onFire[8]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onFire[8],Condition( function sa__Hydra_onFire))
    call TriggerAddAction(st__Hydra_onFire[8], function sa__Hydra_onFire)
    set st__Hydra_attemptShoot=CreateTrigger()
    call TriggerAddCondition(st__Hydra_attemptShoot,Condition( function sa__Hydra_attemptShoot))
    set st__Hydra_killHead=CreateTrigger()
    call TriggerAddCondition(st__Hydra_killHead,Condition( function sa__Hydra_killHead))
    set st__Hydra_create=CreateTrigger()
    call TriggerAddCondition(st__Hydra_create,Condition( function sa__Hydra_create))
    set st__Hydra_onDestroy[8]=null
    set st__Hydra_onDestroy[9]=null
    set st__Hydra_onDestroy[10]=null
    set st__Hydra_onDestroy[11]=null
    set st__Hydra_onDestroy[12]=null
    set st__Hydra_onDestroy[13]=null
    set st__Hydra_onTargetFilter[13]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onTargetFilter[13],Condition( function sa__Guard_onTargetFilter))
    call TriggerAddAction(st__Hydra_onTargetFilter[13], function sa__Guard_onTargetFilter)
    set st__Hydra_onFire[13]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onFire[13],Condition( function sa__Guard_onFire))
    call TriggerAddAction(st__Hydra_onFire[13], function sa__Guard_onFire)
    set st__Hydra_onFire[9]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onFire[9],Condition( function sa__IceHydra_onFire))
    call TriggerAddAction(st__Hydra_onFire[9], function sa__IceHydra_onFire)
    set st__Hydra_onTargetFilter[9]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onTargetFilter[9],Condition( function sa__IceHydra_onTargetFilter))
    call TriggerAddAction(st__Hydra_onTargetFilter[9], function sa__IceHydra_onTargetFilter)
    set st__Hydra_onRemoveHead[9]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onRemoveHead[9],Condition( function sa__IceHydra_onRemoveHead))
    call TriggerAddAction(st__Hydra_onRemoveHead[9], function sa__IceHydra_onRemoveHead)
    set st__Hydra_onSummonHead[9]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onSummonHead[9],Condition( function sa__IceHydra_onSummonHead))
    call TriggerAddAction(st__Hydra_onSummonHead[9], function sa__IceHydra_onSummonHead)
    set st__Hydra_onFire[10]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onFire[10],Condition( function sa__FireHydra_onFire))
    call TriggerAddAction(st__Hydra_onFire[10], function sa__FireHydra_onFire)
    set st__Hydra_onTargetFilter[10]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onTargetFilter[10],Condition( function sa__FireHydra_onTargetFilter))
    call TriggerAddAction(st__Hydra_onTargetFilter[10], function sa__FireHydra_onTargetFilter)
    set st__Hydra_onRemoveHead[10]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onRemoveHead[10],Condition( function sa__FireHydra_onRemoveHead))
    call TriggerAddAction(st__Hydra_onRemoveHead[10], function sa__FireHydra_onRemoveHead)
    set st__Hydra_onSummonHead[10]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onSummonHead[10],Condition( function sa__FireHydra_onSummonHead))
    call TriggerAddAction(st__Hydra_onSummonHead[10], function sa__FireHydra_onSummonHead)
    set st__Hydra_onFire[11]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onFire[11],Condition( function sa__FriendlyHydra_onFire))
    call TriggerAddAction(st__Hydra_onFire[11], function sa__FriendlyHydra_onFire)
    set st__Hydra_onTargetFilter[11]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onTargetFilter[11],Condition( function sa__FriendlyHydra_onTargetFilter))
    call TriggerAddAction(st__Hydra_onTargetFilter[11], function sa__FriendlyHydra_onTargetFilter)
    set st__Hydra_onRemoveHead[11]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onRemoveHead[11],Condition( function sa__FriendlyHydra_onRemoveHead))
    call TriggerAddAction(st__Hydra_onRemoveHead[11], function sa__FriendlyHydra_onRemoveHead)
    set st__Hydra_onSummonHead[11]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onSummonHead[11],Condition( function sa__FriendlyHydra_onSummonHead))
    call TriggerAddAction(st__Hydra_onSummonHead[11], function sa__FriendlyHydra_onSummonHead)
    set st__Hydra_onFire[12]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onFire[12],Condition( function sa__HammerTime_onFire))
    call TriggerAddAction(st__Hydra_onFire[12], function sa__HammerTime_onFire)
    set st__Hydra_onTargetFilter[12]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onTargetFilter[12],Condition( function sa__HammerTime_onTargetFilter))
    call TriggerAddAction(st__Hydra_onTargetFilter[12], function sa__HammerTime_onTargetFilter)
    set st__Hydra_onRemoveHead[12]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onRemoveHead[12],Condition( function sa__HammerTime_onRemoveHead))
    call TriggerAddAction(st__Hydra_onRemoveHead[12], function sa__HammerTime_onRemoveHead)
    set st__Hydra_onSummonHead[12]=CreateTrigger()
    call TriggerAddCondition(st__Hydra_onSummonHead[12],Condition( function sa__HammerTime_onSummonHead))
    call TriggerAddAction(st__Hydra_onSummonHead[12], function sa__HammerTime_onSummonHead)
    set st___prototype6[1]=CreateTrigger()
    call TriggerAddAction(st___prototype6[1],function sa___prototype6_TimerUtils__init)
    call TriggerAddCondition(st___prototype6[1],Condition(function sa___prototype6_TimerUtils__init))
    set st___prototype6[2]=CreateTrigger()
    call TriggerAddAction(st___prototype6[2],function sa___prototype6_EasterEgg___PauseSound)
    call TriggerAddCondition(st___prototype6[2],Condition(function sa___prototype6_EasterEgg___PauseSound))



call ExecuteFunc("s__WorldBounds_WorldBounds__WorldBoundInit__onInit")






call ExecuteFunc("s__IceHydra_MissileStruct__onInit")

call ExecuteFunc("s__FireHydra_MissileStruct__onInit")

call ExecuteFunc("s__FriendlyHydra_MissileStruct__onInit")

call ExecuteFunc("s__HammerTime_MissileStruct__onInit")

call ExecuteFunc("s__Guard_MissileStruct__onInit")

    call ExecuteFunc("s__DemoMap___xxx_onInit")
    call ExecuteFunc("s__Hydra_onInit")
endfunction

