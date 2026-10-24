globals
//globals from DummyCaster:
constant boolean LIBRARY_DummyCaster=true
constant integer UNITS_DUMMY_CASTER= 'dcst'
   
    
constant player DummyCaster__PLAYER_OWNER= Player(15)
unit DummyCaster__u
//endglobals from DummyCaster
//globals from ErrorMessage:
constant boolean LIBRARY_ErrorMessage=true
//endglobals from ErrorMessage
//globals from IsDestructableTree:
constant boolean LIBRARY_IsDestructableTree=true
constant integer IsDestructableTree___HARVESTER_UNIT_ID= 'hpea'
constant integer IsDestructableTree___HARVEST_ABILITY= 'Ahrl'
constant integer IsDestructableTree___HARVEST_ORDER_ID= 0xD0032
constant player IsDestructableTree___NEUTRAL_PLAYER= Player(PLAYER_NEUTRAL_PASSIVE)
unit IsDestructableTree___harvester= null
//endglobals from IsDestructableTree
//globals from RegisterPlayerUnitEvent:
constant boolean LIBRARY_RegisterPlayerUnitEvent=true
trigger array RegisterPlayerUnitEvent___t
//endglobals from RegisterPlayerUnitEvent
//globals from Table:
constant boolean LIBRARY_Table=true
integer Table__less= 0
integer Table__more= 8190
    //Configure it if you use more than 8190 "key" variables in your map (this will never happen though).
   
hashtable Table__ht= InitHashtable()
constant integer Table__sizeK=22
constant integer Table__listK=127
//endglobals from Table
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
constant boolean TimerUtils___USE_HASH_TABLE= true
constant boolean TimerUtils___USE_FLEXIBLE_OFFSET= false

constant integer TimerUtils___OFFSET= 0x100000
integer TimerUtils___VOFFSET= TimerUtils___OFFSET
              
        //Timers to preload at map init:
constant integer TimerUtils___QUANTITY= 256
        
        //Changing this  to something big will allow you to keep recycling
        // timers even when there are already AN INCREDIBLE AMOUNT of timers in
        // the stack. But it will make things far slower so that's probably a bad idea...
constant integer TimerUtils___ARRAY_SIZE= 8190

// processed:         integer array TimerUtils___data[TimerUtils___ARRAY_SIZE]
hashtable TimerUtils___ht
// processed:         timer array TimerUtils___tT[TimerUtils___ARRAY_SIZE]
integer TimerUtils___tN= 0
constant integer TimerUtils___HELD=0x28829022
        //use a totally random number here, the more improbable someone uses it, the better.
        
boolean TimerUtils___didinit= false
//endglobals from TimerUtils
//globals from WorldBounds:
constant boolean LIBRARY_WorldBounds=true
//endglobals from WorldBounds
//globals from GroundCollision:
constant boolean LIBRARY_GroundCollision=true
//endglobals from GroundCollision
//globals from MissileDiagnostics:
constant boolean LIBRARY_MissileDiagnostics=true
//endglobals from MissileDiagnostics
//globals from SpellEffectEvent:
constant boolean LIBRARY_SpellEffectEvent=true
//endglobals from SpellEffectEvent
//globals from GroundMotion:
constant boolean LIBRARY_GroundMotion=true
//endglobals from GroundMotion
//globals from MissileRecycler:
constant boolean LIBRARY_MissileRecycler=true
        //-------------------------------------------------------------------
        // You must configure the dummy unit with the one created from the
        // ObjectMerger statement above.
        //
constant integer MissileRecycler__DUMMY_ID= 'dumi'
player MissileRecycler__OWNER= Player(bj_PLAYER_NEUTRAL_EXTRA)

constant integer MissileRecycler__ANG_N= 8
constant integer MissileRecycler__ANG_STORAGE_MAX= 12

constant real MissileRecycler__DEATH_TIME= 2.
        //the unit to complete its "death" animation in this timeframe. Must
        //be higher than 0.74 seconds to allow the unit time to turn. This
        //number should not be lower than the maximum death-animation time of
        //your missile-units' effect attachments, just to be safe.
constant integer MissileRecycler__ANG_VAL= 360 / MissileRecycler__ANG_N
constant integer MissileRecycler__ANG_MID= MissileRecycler__ANG_VAL / 2

        //Misc vars
unit array MissileRecycler__stack
real array MissileRecycler__timeStamp
integer array MissileRecycler__queueNext
integer array MissileRecycler__queueLast
integer MissileRecycler__recycle= 0
timer MissileRecycler__gameTime= CreateTimer()
integer array MissileRecycler__queueStack
integer MissileRecycler__queueStackN= 0
//endglobals from MissileRecycler
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
        
        
constant real Missile___DELAYED_MISSILE_DEATH_ANIMATION_TIME= 2.

        
constant boolean Missile_USE_DESTRUCTABLE_FILTER= true
constant boolean Missile_USE_ITEM_FILTER= true
        // Core constant handle variables of Missile.
constant trigger Missile___CORE= CreateTrigger()
constant trigger Missile___MOVE= CreateTrigger()
constant timer Missile___TMR= CreateTimer()
constant location Missile___LOC= Location(0., 0.)
constant rect Missile___RECT= Rect(0., 0., 0., 0.)
constant group Missile___GROUP= CreateGroup()
constant hashtable Missile___HASH= InitHashtable()
        // For starting and stopping the timer.
integer Missile___active= 0
        // Arrays for data structure.
integer array Missile___instances
integer array Missile___missileList
boolexpr array Missile___expression
triggercondition array Missile___condition
integer array Missile___remove
boolean array Missile___destroying
boolean array Missile___recycling
integer array Missile___nextNode
integer array Missile___prevNode
        // Internal widget filter functions.
boolexpr Missile___destFilter
boolexpr Missile___itemFilter
boolexpr Missile___unitFilter
//endglobals from Missile
//globals from RapidFire:
constant boolean LIBRARY_RapidFire=true
//endglobals from RapidFire
//globals from X3Buster:
constant boolean LIBRARY_X3Buster=true
//endglobals from X3Buster
//globals from RapidFireDemo:
constant boolean LIBRARY_RapidFireDemo=true
//endglobals from RapidFireDemo
//globals from RapidFireProbe:
constant boolean LIBRARY_RapidFireProbe=true
integer RapidFireProbe___p= 0
integer RapidFireProbe___q= 0
integer RapidFireProbe___stage= 0
integer RapidFireProbe___checks= 0
integer RapidFireProbe___failures= 0
string array RapidFireProbe___lines
integer RapidFireProbe___count= 0
real RapidFireProbe___since
real RapidFireProbe___sx= - 4700.
real RapidFireProbe___sy= 3024.
integer RapidFireProbe___baseline
integer RapidFireProbe___createdBaseline
integer RapidFireProbe___oldFlight
integer RapidFireProbe___instants
integer RapidFireProbe___expectedHandoffs
integer RapidFireProbe___expectedHits
integer RapidFireProbe___expectedWalls
real RapidFireProbe___startX
real RapidFireProbe___startY
real RapidFireProbe___expectedNext
real RapidFireProbe___last= - 1000.
real RapidFireProbe___minimum= 99999.
integer RapidFireProbe___observed= 0
boolean RapidFireProbe___one= false
boolean RapidFireProbe___two= false
unit RapidFireProbe___target
destructable RapidFireProbe___tree
timer RapidFireProbe___t= null
real RapidFireProbe___cx1= 0.
real RapidFireProbe___cy1= 0.
real RapidFireProbe___cx2= 0.
real RapidFireProbe___cy2= 0.
integer RapidFireProbe___cliffIndex= 0
real RapidFireProbe___firstEmission= - 1.
real RapidFireProbe___firstEnd= - 1.
//endglobals from RapidFireProbe
//globals from ShotColorProbe:
constant boolean LIBRARY_ShotColorProbe=true
unit array ShotColorProbe__displayUnit
effect array ShotColorProbe__displayEffect
texttag array ShotColorProbe__label
lightning array ShotColorProbe__ring
integer ShotColorProbe__displays= 0
integer ShotColorProbe__rings= 0
integer ShotColorProbe__checks= 0
integer ShotColorProbe__failures= 0
string array ShotColorProbe__lines
integer ShotColorProbe__stage= 0
timer ShotColorProbe__ticker= CreateTimer()
real ShotColorProbe__since
integer ShotColorProbe__p
integer ShotColorProbe__prior
real ShotColorProbe__nextTime
integer ShotColorProbe__countBefore
string array ShotColorProbe__expected
real ShotColorProbe__originalX
real ShotColorProbe__originalY
//endglobals from ShotColorProbe
//globals from X3BusterDemo:
constant boolean LIBRARY_X3BusterDemo=true
//endglobals from X3BusterDemo
//globals from X3Probe:
constant boolean LIBRARY_X3Probe=true
integer X3Probe__checks= 0
integer X3Probe__failures= 0
integer X3Probe__stage= - 1
integer X3Probe__search= 0
string array X3Probe__lines
real X3Probe__since
real X3Probe__sx= - 4700.
real X3Probe__sy= 3024.
unit X3Probe__source
unit X3Probe__target
destructable X3Probe__tree
integer X3Probe__shot
integer X3Probe__second
integer X3Probe__baseline
integer X3Probe__births
integer X3Probe__hitBase
integer X3Probe__wallBase
integer X3Probe__satelliteBase
boolean X3Probe__one= false
timer X3Probe__ticker= CreateTimer()
timer X3Probe__showing= CreateTimer()
integer array X3Probe__capped
integer X3Probe__capIndex= 0
//endglobals from X3Probe
    // Generated
rect gg_rct_Region_001= null
rect gg_rct_Region_000= null
rect gg_rct_Region_002= null
rect gg_rct_Region_003= null
rect gg_rct_Region_004= null
rect gg_rct_Region_005= null
rect gg_rct_Region_006= null
rect gg_rct_Region_007= null
rect gg_rct_Region_008= null
rect gg_rct_Region_008_Copy= null
rect gg_rct_Region_010= null
rect gg_rct_Region_003_Copy= null
sound gg_snd_WaterWaterFallLoop1= null
sound gg_snd_FreakyForest4= null
trigger gg_trg_Melee_Initialization= null
trigger gg_trg_TurtleNet= null
unit gg_unit_ntrd_0023= null


//JASSHelper struct globals:



//JASSHelper struct globals:
constant integer si__DummyCaster=1
constant integer si__IsDestructableTree___I=2
constant integer si__Table__dex=3
constant integer si__Table__handles=4
constant integer si__Table__agents=5
constant integer si__Table__reals=6
constant integer si__Table__booleans=7
constant integer si__Table__strings=8
constant integer si__Table__players=9
constant integer si__Table__widgets=10
constant integer si__Table__destructables=11
constant integer si__Table__items=12
constant integer si__Table__units=13
constant integer si__Table__abilitys=14
constant integer si__Table__timers=15
constant integer si__Table__triggers=16
constant integer si__Table__triggerconditions=17
constant integer si__Table__triggeractions=18
constant integer si__Table__events=19
constant integer si__Table__forces=20
constant integer si__Table__groups=21
constant integer si__Table__locations=22
constant integer si__Table__rects=23
constant integer si__Table__boolexprs=24
constant integer si__Table__sounds=25
constant integer si__Table__effects=26
constant integer si__Table__unitpools=27
constant integer si__Table__itempools=28
constant integer si__Table__quests=29
constant integer si__Table__questitems=30
constant integer si__Table__defeatconditions=31
constant integer si__Table__timerdialogs=32
constant integer si__Table__leaderboards=33
constant integer si__Table__multiboards=34
constant integer si__Table__multiboarditems=35
constant integer si__Table__trackables=36
constant integer si__Table__dialogs=37
constant integer si__Table__buttons=38
constant integer si__Table__texttags=39
constant integer si__Table__lightnings=40
constant integer si__Table__images=41
constant integer si__Table__ubersplats=42
constant integer si__Table__regions=43
constant integer si__Table__fogstates=44
constant integer si__Table__fogmodifiers=45
constant integer si__Table__hashtables=46
constant integer si__Table=47
constant integer si__TableArray=48
integer s__TableArray_tempTable
integer s__TableArray_tempEnd
constant integer si__WorldBounds=49
integer s__WorldBounds_maxX
integer s__WorldBounds_maxY
integer s__WorldBounds_minX
integer s__WorldBounds_minY
integer s__WorldBounds_centerX
integer s__WorldBounds_centerY
rect s__WorldBounds_world
region s__WorldBounds_worldRegion
constant integer si__GroundCollision=50
real s__GroundCollision_x
real s__GroundCollision_y
unit s__GroundCollision_hit= null
integer s__GroundCollision_reason= 0
item s__GroundCollision_probe
rect s__GroundCollision_area= Rect(0., 0., 256., 256.)
group s__GroundCollision_targets= CreateGroup()
location s__GroundCollision_heightPoint= Location(0., 0.)
item array s__GroundCollision_hidden
integer s__GroundCollision_hiddenCount= 0
real s__GroundCollision_testX
real s__GroundCollision_testY
real s__GroundCollision_testRadius
boolean s__GroundCollision_destBlocked
constant integer si__MissileStats=51
integer s__MissileStats_active= 0
integer s__MissileStats_peakActive= 0
integer s__MissileStats_created= 0
integer s__MissileStats_retired= 0
integer s__MissileStats_oldestSeconds= 0
integer s__MissileStats_tracked= 0
integer s__MissileStats_peakTracked= 0
integer s__MissileStats_borrowed= 0
integer s__MissileStats_pooled= 0
integer s__MissileStats_deferred= 0
integer s__MissileStats_pending= 0
integer s__MissileStats_overdue= 0
integer s__MissileStats_preloadTotal= 0
integer s__MissileStats_newTotal= 0
integer s__MissileStats_reusedTotal= 0
integer s__MissileStats_adoptedTotal= 0
integer s__MissileStats_disposed= 0
integer s__MissileStats_lost= 0
integer s__MissileStats_invalid= 0
integer s__MissileStats_omitted= 0
integer s__MissileStats_errors= 0
integer s__MissileStats_inconsistent= 0
integer s__MissileStats_alarms= 0
integer s__MissileStats_capacity= 0
integer s__MissileStats_checks= 0
integer s__MissileStats_renders= 0
multiboard s__MissileStats_board= null
constant integer s__MissileStats_LIMIT= 8190
constant real s__MissileStats_GRACE= 1.25
constant integer s__MissileStats_OLD_AGE= 30
integer s__MissileStats_index
timer s__MissileStats_clock= CreateTimer()
timer s__MissileStats_watcher= CreateTimer()
timer s__MissileStats_painter= CreateTimer()
boolean s__MissileStats_queued= false
boolean s__MissileStats_initialized= false
unit array s__MissileStats_units
integer array s__MissileStats_state
real array s__MissileStats_deadline
boolean array s__MissileStats_warned
integer array s__MissileStats_nodeSlot
integer array s__MissileStats_nodes
real array s__MissileStats_born
boolean array s__MissileStats_hidden
string array s__MissileStats_cell
string s__MissileStats_title= ""
constant integer si__SpellEffectEvent__S=52
integer s__SpellEffectEvent__S_tb
constant integer si__GroundMotion=53
integer si__GroundMotion_F=0
integer si__GroundMotion_I=0
integer array si__GroundMotion_V
unit array s__GroundMotion_body
boolean array s__GroundMotion_artificial
boolean array s__GroundMotion_blocked
boolean array s__GroundMotion_hasGoal
real array s__GroundMotion_goalX
real array s__GroundMotion_goalY
integer s__GroundMotion_instantTransitions= 0
integer s__GroundMotion_xySteps= 0
integer s__GroundMotion_handoffs= 0
real array s__GroundMotion_speed
real array s__GroundMotion_radius
constant integer si__Missile___RecycleBin=54
constant timer s__Missile___RecycleBin_t= CreateTimer()
integer s__Missile___RecycleBin_max= 0
unit array s__Missile___RecycleBin_dummy
real array s__Missile___RecycleBin_time
constant integer si__MissilePosition=55
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
constant integer si__Missile=56
integer s__Missile_Missile___MissileStructure___collectionCount= 0
integer s__Missile_Missile___MissileStructure___nodeCount= 0
integer array s__Missile_Missile___MissileStructure____list
integer array s__Missile_Missile___MissileStructure____next
integer array s__Missile_Missile___MissileStructure____prev
integer array s__Missile_Missile___MissileStructure____first
integer array s__Missile_Missile___MissileStructure____last
constant string s__Missile_ORIGIN= "origin"
constant real s__Missile_HIT_BOX= ( 2. / 3. )
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
constant integer si__RapidBolt=57
constant real s__RapidBolt_HIT_RADIUS= 16.
constant real s__RapidBolt_VISUAL_SCALE= s__RapidBolt_HIT_RADIUS / 5.832
unit array s__RapidBolt_source
player array s__RapidBolt_owner
integer s__RapidBolt_live= 0
integer s__RapidBolt_hits= 0
integer s__RapidBolt_walls= 0
constant integer si__RapidPair=58
integer si__RapidPair_F=0
integer si__RapidPair_I=0
integer array si__RapidPair_V
unit array s__RapidPair_controller
unit array s__RapidPair_actor
integer array s__RapidPair_motion
boolean array s__RapidPair_firing
integer array s__RapidPair_pending
real array s__RapidPair_aimX
real array s__RapidPair_aimY
real array s__RapidPair_nextShot
real array s__RapidPair_lastShot
integer array s__RapidPair_lastMissile
integer s__RapidPair_pairs= 0
integer s__RapidPair_bursts= 0
integer s__RapidPair_remaining= 0
integer s__RapidPair_emitted= 0
integer s__RapidPair_recasts= 0
integer s__RapidPair_attacks= 0
real s__RapidPair_minInterval= 99999.
integer s__RapidPair_moving= 0
integer s__RapidPair_blocked= 0
timer array s__RapidPair_reset
playercolor array s__RapidPair_tint
boolean array s__RapidPair_hasTint
integer array s__RapidPair_next
integer array s__RapidPair_previous
integer s__RapidPair_first= 0
integer s__RapidPair_controls
integer s__RapidPair_actors
timer s__RapidPair_clock= CreateTimer()
timer s__RapidPair_ticker= CreateTimer()
constant real s__RapidPair_INTERVAL= 0.25
constant integer si__X3Buster__X3Flash=59
integer si__X3Buster__X3Flash_F=0
integer si__X3Buster__X3Flash_I=0
integer array si__X3Buster__X3Flash_V
unit array s__X3Buster__X3Flash_dummy
effect array s__X3Buster__X3Flash_art
integer s__X3Buster__X3Flash_live= 0
constant integer si__X3Buster=60
integer si__X3Buster_F=0
integer si__X3Buster_I=0
integer array si__X3Buster_V
constant real s__X3Buster_ORBIT_SPEED= 600.
constant real s__X3Buster_PULSE_SPEED= 1100.
constant real s__X3Buster_FUSED_SPEED= 1200.
constant real s__X3Buster_PULSE_DELAY= 0.25
constant real s__X3Buster_ORBIT_RADIUS= 32.
constant real s__X3Buster_ORBIT_HZ= 2.5
constant real s__X3Buster_RANGE= 1400.
constant real s__X3Buster_LIFETIME= 4.
constant integer s__X3Buster_LIMIT= 64
unit array s__X3Buster_caster
player array s__X3Buster_owner
real array s__X3Buster_originX
real array s__X3Buster_originY
real array s__X3Buster_angle
real array s__X3Buster_born
integer array s__X3Buster_state
integer array s__X3Buster_green
integer array s__X3Buster_orange
integer array s__X3Buster_pulse
integer array s__X3Buster_fused
integer array s__X3Buster_sat1
integer array s__X3Buster_sat2
integer array s__X3Buster_sat3
integer array s__X3Buster_sat4
integer array s__X3Buster_bodies
boolean array s__X3Buster_waiting
boolean array s__X3Buster_automatic
integer array s__X3Buster_next
integer array s__X3Buster_previous
integer s__X3Buster_first= 0
timer s__X3Buster_clock= CreateTimer()
timer s__X3Buster_ticker= CreateTimer()
integer s__X3Buster_live= 0
integer s__X3Buster_projectiles= 0
integer s__X3Buster_created= 0
integer s__X3Buster_retired= 0
integer s__X3Buster_fusions= 0
integer s__X3Buster_hits= 0
integer s__X3Buster_walls= 0
integer s__X3Buster_pulses= 0
integer s__X3Buster_satellites= 0
real s__X3Buster_lastFusionX= 0.
real s__X3Buster_lastFusionY= 0.
real s__X3Buster_lastFusionAge= 0.
constant integer si__X3Buster__X3Body=61
integer array s__X3Buster__X3Body_kind
real array s__X3Buster__X3Body_lastX
real array s__X3Buster__X3Body_lastY
real array s__X3Buster__X3Body_processed
boolean array s__X3Buster__X3Body_blocked
constant integer si__RapidDemo=62
integer s__RapidDemo_pair= 0
boolean s__RapidDemo_extended= false
unit array s__RapidDemo_targets
integer array s__TimerUtils___data
timer array s__TimerUtils___tT
trigger st__X3Buster__X3Body_resolve
trigger st__X3Buster__X3Body_spawn
trigger array st___prototype2
integer f__arg_integer1
integer f__arg_integer2
real f__arg_real1
real f__arg_real2
real f__arg_real3
real f__arg_real4
boolean f__result_boolean
integer f__result_integer

endglobals
    native UnitAlive takes unit id returns boolean


//Generated method caller for X3Buster__X3Body.resolve
function sc__X3Buster__X3Body_resolve takes integer m returns boolean
    set f__arg_integer1=m
    call TriggerEvaluate(st__X3Buster__X3Body_resolve)
 return f__result_boolean
endfunction

//Generated method caller for X3Buster__X3Body.spawn
function sc__X3Buster__X3Body_spawn takes integer s,integer form,real x,real y,real facing,real length returns integer
    set f__arg_integer1=s
    set f__arg_integer2=form
    set f__arg_real1=x
    set f__arg_real2=y
    set f__arg_real3=facing
    set f__arg_real4=length
    call TriggerEvaluate(st__X3Buster__X3Body_spawn)
 return f__result_integer
endfunction

//Generated allocator of X3Buster
function s__X3Buster__allocate takes nothing returns integer
 local integer this=si__X3Buster_F
    if (this!=0) then
        set si__X3Buster_F=si__X3Buster_V[this]
    else
        set si__X3Buster_I=si__X3Buster_I+1
        set this=si__X3Buster_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__X3Buster_V[this]=-1
 return this
endfunction

//Generated destructor of X3Buster
function s__X3Buster_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__X3Buster_V[this]!=-1) then
        return
    endif
    set si__X3Buster_V[this]=si__X3Buster_F
    set si__X3Buster_F=this
endfunction

//Generated allocator of X3Buster__X3Flash
function s__X3Buster__X3Flash__allocate takes nothing returns integer
 local integer this=si__X3Buster__X3Flash_F
    if (this!=0) then
        set si__X3Buster__X3Flash_F=si__X3Buster__X3Flash_V[this]
    else
        set si__X3Buster__X3Flash_I=si__X3Buster__X3Flash_I+1
        set this=si__X3Buster__X3Flash_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__X3Buster__X3Flash_V[this]=-1
 return this
endfunction

//Generated destructor of X3Buster__X3Flash
function s__X3Buster__X3Flash_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__X3Buster__X3Flash_V[this]!=-1) then
        return
    endif
    set si__X3Buster__X3Flash_V[this]=si__X3Buster__X3Flash_F
    set si__X3Buster__X3Flash_F=this
endfunction

//Generated allocator of RapidPair
function s__RapidPair__allocate takes nothing returns integer
 local integer this=si__RapidPair_F
    if (this!=0) then
        set si__RapidPair_F=si__RapidPair_V[this]
    else
        set si__RapidPair_I=si__RapidPair_I+1
        set this=si__RapidPair_I
    endif
    if (this>8190) then
        return 0
    endif

   set s__RapidPair_firing[this]= false
   set s__RapidPair_pending[this]= 0
   set s__RapidPair_nextShot[this]= 0.
   set s__RapidPair_lastShot[this]= - 1000.
   set s__RapidPair_lastMissile[this]= 0
    set si__RapidPair_V[this]=-1
 return this
endfunction

//Generated destructor of RapidPair
function s__RapidPair_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__RapidPair_V[this]!=-1) then
        return
    endif
    set si__RapidPair_V[this]=si__RapidPair_F
    set si__RapidPair_F=this
endfunction

//Generated allocator of GroundMotion
function s__GroundMotion__allocate takes nothing returns integer
 local integer this=si__GroundMotion_F
    if (this!=0) then
        set si__GroundMotion_F=si__GroundMotion_V[this]
    else
        set si__GroundMotion_I=si__GroundMotion_I+1
        set this=si__GroundMotion_I
    endif
    if (this>8190) then
        return 0
    endif

   set s__GroundMotion_artificial[this]= false
   set s__GroundMotion_blocked[this]= false
   set s__GroundMotion_hasGoal[this]= false
   set s__GroundMotion_speed[this]= 350.
   set s__GroundMotion_radius[this]= 24.
    set si__GroundMotion_V[this]=-1
 return this
endfunction

//Generated destructor of GroundMotion
function s__GroundMotion_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__GroundMotion_V[this]!=-1) then
        return
    endif
    set si__GroundMotion_V[this]=si__GroundMotion_F
    set si__GroundMotion_F=this
endfunction
function sc___prototype2_execute takes integer i returns nothing

    call TriggerExecute(st___prototype2[i])
endfunction
function sc___prototype2_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype2[i])

endfunction


//Implemented from module DummyCaster__N:
        function s__DummyCaster_DummyCaster__N__onInit takes nothing returns nothing





                set DummyCaster__u=CreateUnit(DummyCaster__PLAYER_OWNER, UNITS_DUMMY_CASTER, 0, 0, 0)

            call SetUnitPosition(DummyCaster__u, 32256, 32256)
        endfunction
        function s__DummyCaster_prep takes integer a,player p,integer l returns nothing
            call UnitAddAbility(DummyCaster__u, a)
            if ( 1 < l ) then
                call SetUnitAbilityLevel(DummyCaster__u, a, l)
            endif
            if ( null != p ) then
                call SetUnitOwner(DummyCaster__u, p, false)
            endif
        endfunction
        function s__DummyCaster_finish takes integer a returns nothing
            call SetUnitOwner(DummyCaster__u, DummyCaster__PLAYER_OWNER, false)
            call UnitRemoveAbility(DummyCaster__u, a)
        endfunction
        function s__DummyCaster_cast takes integer this,player p,integer level,integer order,real x,real y returns boolean
            local boolean b
            call SetUnitX(DummyCaster__u, x)
            call SetUnitY(DummyCaster__u, y)
            call s__DummyCaster_prep(this , p , level)
            set b=IssueImmediateOrderById(DummyCaster__u, order)
            call s__DummyCaster_finish(this)
            call SetUnitPosition(DummyCaster__u, 32256, 32256)
            return b
        endfunction
        function s__DummyCaster_castTarget takes integer this,player p,integer level,integer order,widget t returns boolean
            local boolean b
            call s__DummyCaster_prep(this , p , level)
            set b=IssueTargetOrderById(DummyCaster__u, order, t)
            call s__DummyCaster_finish(this)
            return b
        endfunction
        function s__DummyCaster_castPoint takes integer this,player p,integer level,integer order,real x,real y returns boolean
            local boolean b
            call s__DummyCaster_prep(this , p , level)
            set b=IssuePointOrderById(DummyCaster__u, order, x, y)
            call s__DummyCaster_finish(this)
            return b
        endfunction




























































    function IsDestructableTree takes destructable d returns boolean
        //*  851973 is the order id for stunned, it will interrupt the preceding harvest order.
        return ( IssueTargetOrderById(IsDestructableTree___harvester, IsDestructableTree___HARVEST_ORDER_ID, d) ) and ( IssueImmediateOrderById(IsDestructableTree___harvester, 851973) )
    endfunction
    function IsDestructableDead takes destructable d returns boolean
        return ( GetWidgetLife(d) <= 0.405 )
    endfunction
    function IsDestructableAlive takes destructable d returns boolean
        return ( GetWidgetLife(d) > .405 )
    endfunction
    function IsTreeAlive takes destructable tree returns boolean
        return (GetWidgetLife((tree)) > .405) and (( IssueTargetOrderById(IsDestructableTree___harvester, IsDestructableTree___HARVEST_ORDER_ID, (tree)) ) and ( IssueImmediateOrderById(IsDestructableTree___harvester, 851973) )) // INLINED!!
    endfunction
    function KillTree takes destructable tree returns boolean
        if ( IsTreeAlive(tree) ) then
            call KillDestructable(tree)
            return true
        endif
        return false
    endfunction
    function IsDestructableTree___Init takes nothing returns nothing



        set IsDestructableTree___harvester=CreateUnit(IsDestructableTree___NEUTRAL_PLAYER, IsDestructableTree___HARVESTER_UNIT_ID, 0, 0, 0)



        call UnitAddAbility(IsDestructableTree___harvester, IsDestructableTree___HARVEST_ABILITY)
        call UnitAddAbility(IsDestructableTree___harvester, 'Aloc')
        call ShowUnit(IsDestructableTree___harvester, false)
    endfunction
    //*  Seriously?
//Implemented from module IsDestructableTree___Inits:
        function s__IsDestructableTree___I_IsDestructableTree___Inits___onInit takes nothing returns nothing
            call IsDestructableTree___Init()
        endfunction
    

   
    function RegisterPlayerUnitEvent takes playerunitevent p,code c returns nothing
        local integer i= GetHandleId(p)
        local integer k= 15
        if RegisterPlayerUnitEvent___t[i] == null then
            set RegisterPlayerUnitEvent___t[i]=CreateTrigger()
            loop
                call TriggerRegisterPlayerUnitEvent(RegisterPlayerUnitEvent___t[i], Player(k), p, null)
                exitwhen k == 0
                set k=k - 1
            endloop
        endif
        call TriggerAddCondition(RegisterPlayerUnitEvent___t[i], Filter(c))
    endfunction
   
    function RegisterPlayerUnitEventForPlayer takes playerunitevent p,code c,player pl returns nothing
        local integer i= 16 * GetHandleId(p) + GetPlayerId(pl)
        if RegisterPlayerUnitEvent___t[i] == null then
            set RegisterPlayerUnitEvent___t[i]=CreateTrigger()
            call TriggerRegisterPlayerUnitEvent(RegisterPlayerUnitEvent___t[i], pl, p, null)
        endif
        call TriggerAddCondition(RegisterPlayerUnitEvent___t[i], Filter(c))
    endfunction
   
    function GetPlayerUnitEventTrigger takes playerunitevent p returns trigger
        return RegisterPlayerUnitEvent___t[GetHandleId(p)]
    endfunction

   
   
    function s__Table__dex__get_size takes nothing returns integer
        return Table__sizeK
    endfunction
    function s__Table__dex__get_list takes nothing returns integer
        return Table__listK
    endfunction
   
    function s__Table__handles_has takes integer this,integer key returns boolean
        return HaveSavedHandle(Table__ht, this, key)
    endfunction
    function s__Table__handles_remove takes integer this,integer key returns nothing
        call RemoveSavedHandle(Table__ht, this, key)
    endfunction
   
    function s__Table__agents__setindex takes integer this,integer key,agent value returns nothing
        call SaveAgentHandle(Table__ht, this, key, value)
    endfunction
   
   
   
//Run these textmacros to include the entire hashtable API as wrappers.
//Don't be intimidated by the number of macros - Vexorian's map optimizer is
//supposed to kill functions which inline (all of these functions inline).
//textmacro instance: NEW_ARRAY_BASIC("Real", "Real", "real")
    function s__Table__reals__getindex takes integer this,integer key returns real
        return LoadReal(Table__ht, this, key)
    endfunction
    function s__Table__reals__setindex takes integer this,integer key,real value returns nothing
        call SaveReal(Table__ht, this, key, value)
    endfunction
    function s__Table__reals_has takes integer this,integer key returns boolean
        return HaveSavedReal(Table__ht, this, key)
    endfunction
    function s__Table__reals_remove takes integer this,integer key returns nothing
        call RemoveSavedReal(Table__ht, this, key)
    endfunction
//end of: NEW_ARRAY_BASIC("Real", "Real", "real")
//textmacro instance: NEW_ARRAY_BASIC("Boolean", "Boolean", "boolean")
    function s__Table__booleans__getindex takes integer this,integer key returns boolean
        return LoadBoolean(Table__ht, this, key)
    endfunction
    function s__Table__booleans__setindex takes integer this,integer key,boolean value returns nothing
        call SaveBoolean(Table__ht, this, key, value)
    endfunction
    function s__Table__booleans_has takes integer this,integer key returns boolean
        return HaveSavedBoolean(Table__ht, this, key)
    endfunction
    function s__Table__booleans_remove takes integer this,integer key returns nothing
        call RemoveSavedBoolean(Table__ht, this, key)
    endfunction
//end of: NEW_ARRAY_BASIC("Boolean", "Boolean", "boolean")
//textmacro instance: NEW_ARRAY_BASIC("String", "Str", "string")
    function s__Table__strings__getindex takes integer this,integer key returns string
        return LoadStr(Table__ht, this, key)
    endfunction
    function s__Table__strings__setindex takes integer this,integer key,string value returns nothing
        call SaveStr(Table__ht, this, key, value)
    endfunction
    function s__Table__strings_has takes integer this,integer key returns boolean
        return HaveSavedString(Table__ht, this, key)
    endfunction
    function s__Table__strings_remove takes integer this,integer key returns nothing
        call RemoveSavedString(Table__ht, this, key)
    endfunction
//end of: NEW_ARRAY_BASIC("String", "Str", "string")
   
//textmacro instance: NEW_ARRAY("Player", "player")
    function s__Table__players__getindex takes integer this,integer key returns player
        return LoadPlayerHandle(Table__ht, this, key)
    endfunction
    function s__Table__players__setindex takes integer this,integer key,player value returns nothing
        call SavePlayerHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Player", "player")
//textmacro instance: NEW_ARRAY("Widget", "widget")
    function s__Table__widgets__getindex takes integer this,integer key returns widget
        return LoadWidgetHandle(Table__ht, this, key)
    endfunction
    function s__Table__widgets__setindex takes integer this,integer key,widget value returns nothing
        call SaveWidgetHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Widget", "widget")
//textmacro instance: NEW_ARRAY("Destructable", "destructable")
    function s__Table__destructables__getindex takes integer this,integer key returns destructable
        return LoadDestructableHandle(Table__ht, this, key)
    endfunction
    function s__Table__destructables__setindex takes integer this,integer key,destructable value returns nothing
        call SaveDestructableHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Destructable", "destructable")
//textmacro instance: NEW_ARRAY("Item", "item")
    function s__Table__items__getindex takes integer this,integer key returns item
        return LoadItemHandle(Table__ht, this, key)
    endfunction
    function s__Table__items__setindex takes integer this,integer key,item value returns nothing
        call SaveItemHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Item", "item")
//textmacro instance: NEW_ARRAY("Unit", "unit")
    function s__Table__units__getindex takes integer this,integer key returns unit
        return LoadUnitHandle(Table__ht, this, key)
    endfunction
    function s__Table__units__setindex takes integer this,integer key,unit value returns nothing
        call SaveUnitHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Unit", "unit")
//textmacro instance: NEW_ARRAY("Ability", "ability")
    function s__Table__abilitys__getindex takes integer this,integer key returns ability
        return LoadAbilityHandle(Table__ht, this, key)
    endfunction
    function s__Table__abilitys__setindex takes integer this,integer key,ability value returns nothing
        call SaveAbilityHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Ability", "ability")
//textmacro instance: NEW_ARRAY("Timer", "timer")
    function s__Table__timers__getindex takes integer this,integer key returns timer
        return LoadTimerHandle(Table__ht, this, key)
    endfunction
    function s__Table__timers__setindex takes integer this,integer key,timer value returns nothing
        call SaveTimerHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Timer", "timer")
//textmacro instance: NEW_ARRAY("Trigger", "trigger")
    function s__Table__triggers__getindex takes integer this,integer key returns trigger
        return LoadTriggerHandle(Table__ht, this, key)
    endfunction
    function s__Table__triggers__setindex takes integer this,integer key,trigger value returns nothing
        call SaveTriggerHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Trigger", "trigger")
//textmacro instance: NEW_ARRAY("TriggerCondition", "triggercondition")
    function s__Table__triggerconditions__getindex takes integer this,integer key returns triggercondition
        return LoadTriggerConditionHandle(Table__ht, this, key)
    endfunction
    function s__Table__triggerconditions__setindex takes integer this,integer key,triggercondition value returns nothing
        call SaveTriggerConditionHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TriggerCondition", "triggercondition")
//textmacro instance: NEW_ARRAY("TriggerAction", "triggeraction")
    function s__Table__triggeractions__getindex takes integer this,integer key returns triggeraction
        return LoadTriggerActionHandle(Table__ht, this, key)
    endfunction
    function s__Table__triggeractions__setindex takes integer this,integer key,triggeraction value returns nothing
        call SaveTriggerActionHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TriggerAction", "triggeraction")
//textmacro instance: NEW_ARRAY("TriggerEvent", "event")
    function s__Table__events__getindex takes integer this,integer key returns event
        return LoadTriggerEventHandle(Table__ht, this, key)
    endfunction
    function s__Table__events__setindex takes integer this,integer key,event value returns nothing
        call SaveTriggerEventHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TriggerEvent", "event")
//textmacro instance: NEW_ARRAY("Force", "force")
    function s__Table__forces__getindex takes integer this,integer key returns force
        return LoadForceHandle(Table__ht, this, key)
    endfunction
    function s__Table__forces__setindex takes integer this,integer key,force value returns nothing
        call SaveForceHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Force", "force")
//textmacro instance: NEW_ARRAY("Group", "group")
    function s__Table__groups__getindex takes integer this,integer key returns group
        return LoadGroupHandle(Table__ht, this, key)
    endfunction
    function s__Table__groups__setindex takes integer this,integer key,group value returns nothing
        call SaveGroupHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Group", "group")
//textmacro instance: NEW_ARRAY("Location", "location")
    function s__Table__locations__getindex takes integer this,integer key returns location
        return LoadLocationHandle(Table__ht, this, key)
    endfunction
    function s__Table__locations__setindex takes integer this,integer key,location value returns nothing
        call SaveLocationHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Location", "location")
//textmacro instance: NEW_ARRAY("Rect", "rect")
    function s__Table__rects__getindex takes integer this,integer key returns rect
        return LoadRectHandle(Table__ht, this, key)
    endfunction
    function s__Table__rects__setindex takes integer this,integer key,rect value returns nothing
        call SaveRectHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Rect", "rect")
//textmacro instance: NEW_ARRAY("BooleanExpr", "boolexpr")
    function s__Table__boolexprs__getindex takes integer this,integer key returns boolexpr
        return LoadBooleanExprHandle(Table__ht, this, key)
    endfunction
    function s__Table__boolexprs__setindex takes integer this,integer key,boolexpr value returns nothing
        call SaveBooleanExprHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("BooleanExpr", "boolexpr")
//textmacro instance: NEW_ARRAY("Sound", "sound")
    function s__Table__sounds__getindex takes integer this,integer key returns sound
        return LoadSoundHandle(Table__ht, this, key)
    endfunction
    function s__Table__sounds__setindex takes integer this,integer key,sound value returns nothing
        call SaveSoundHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Sound", "sound")
//textmacro instance: NEW_ARRAY("Effect", "effect")
    function s__Table__effects__getindex takes integer this,integer key returns effect
        return LoadEffectHandle(Table__ht, this, key)
    endfunction
    function s__Table__effects__setindex takes integer this,integer key,effect value returns nothing
        call SaveEffectHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Effect", "effect")
//textmacro instance: NEW_ARRAY("UnitPool", "unitpool")
    function s__Table__unitpools__getindex takes integer this,integer key returns unitpool
        return LoadUnitPoolHandle(Table__ht, this, key)
    endfunction
    function s__Table__unitpools__setindex takes integer this,integer key,unitpool value returns nothing
        call SaveUnitPoolHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("UnitPool", "unitpool")
//textmacro instance: NEW_ARRAY("ItemPool", "itempool")
    function s__Table__itempools__getindex takes integer this,integer key returns itempool
        return LoadItemPoolHandle(Table__ht, this, key)
    endfunction
    function s__Table__itempools__setindex takes integer this,integer key,itempool value returns nothing
        call SaveItemPoolHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("ItemPool", "itempool")
//textmacro instance: NEW_ARRAY("Quest", "quest")
    function s__Table__quests__getindex takes integer this,integer key returns quest
        return LoadQuestHandle(Table__ht, this, key)
    endfunction
    function s__Table__quests__setindex takes integer this,integer key,quest value returns nothing
        call SaveQuestHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Quest", "quest")
//textmacro instance: NEW_ARRAY("QuestItem", "questitem")
    function s__Table__questitems__getindex takes integer this,integer key returns questitem
        return LoadQuestItemHandle(Table__ht, this, key)
    endfunction
    function s__Table__questitems__setindex takes integer this,integer key,questitem value returns nothing
        call SaveQuestItemHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("QuestItem", "questitem")
//textmacro instance: NEW_ARRAY("DefeatCondition", "defeatcondition")
    function s__Table__defeatconditions__getindex takes integer this,integer key returns defeatcondition
        return LoadDefeatConditionHandle(Table__ht, this, key)
    endfunction
    function s__Table__defeatconditions__setindex takes integer this,integer key,defeatcondition value returns nothing
        call SaveDefeatConditionHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("DefeatCondition", "defeatcondition")
//textmacro instance: NEW_ARRAY("TimerDialog", "timerdialog")
    function s__Table__timerdialogs__getindex takes integer this,integer key returns timerdialog
        return LoadTimerDialogHandle(Table__ht, this, key)
    endfunction
    function s__Table__timerdialogs__setindex takes integer this,integer key,timerdialog value returns nothing
        call SaveTimerDialogHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TimerDialog", "timerdialog")
//textmacro instance: NEW_ARRAY("Leaderboard", "leaderboard")
    function s__Table__leaderboards__getindex takes integer this,integer key returns leaderboard
        return LoadLeaderboardHandle(Table__ht, this, key)
    endfunction
    function s__Table__leaderboards__setindex takes integer this,integer key,leaderboard value returns nothing
        call SaveLeaderboardHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Leaderboard", "leaderboard")
//textmacro instance: NEW_ARRAY("Multiboard", "multiboard")
    function s__Table__multiboards__getindex takes integer this,integer key returns multiboard
        return LoadMultiboardHandle(Table__ht, this, key)
    endfunction
    function s__Table__multiboards__setindex takes integer this,integer key,multiboard value returns nothing
        call SaveMultiboardHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Multiboard", "multiboard")
//textmacro instance: NEW_ARRAY("MultiboardItem", "multiboarditem")
    function s__Table__multiboarditems__getindex takes integer this,integer key returns multiboarditem
        return LoadMultiboardItemHandle(Table__ht, this, key)
    endfunction
    function s__Table__multiboarditems__setindex takes integer this,integer key,multiboarditem value returns nothing
        call SaveMultiboardItemHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("MultiboardItem", "multiboarditem")
//textmacro instance: NEW_ARRAY("Trackable", "trackable")
    function s__Table__trackables__getindex takes integer this,integer key returns trackable
        return LoadTrackableHandle(Table__ht, this, key)
    endfunction
    function s__Table__trackables__setindex takes integer this,integer key,trackable value returns nothing
        call SaveTrackableHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Trackable", "trackable")
//textmacro instance: NEW_ARRAY("Dialog", "dialog")
    function s__Table__dialogs__getindex takes integer this,integer key returns dialog
        return LoadDialogHandle(Table__ht, this, key)
    endfunction
    function s__Table__dialogs__setindex takes integer this,integer key,dialog value returns nothing
        call SaveDialogHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Dialog", "dialog")
//textmacro instance: NEW_ARRAY("Button", "button")
    function s__Table__buttons__getindex takes integer this,integer key returns button
        return LoadButtonHandle(Table__ht, this, key)
    endfunction
    function s__Table__buttons__setindex takes integer this,integer key,button value returns nothing
        call SaveButtonHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Button", "button")
//textmacro instance: NEW_ARRAY("TextTag", "texttag")
    function s__Table__texttags__getindex takes integer this,integer key returns texttag
        return LoadTextTagHandle(Table__ht, this, key)
    endfunction
    function s__Table__texttags__setindex takes integer this,integer key,texttag value returns nothing
        call SaveTextTagHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TextTag", "texttag")
//textmacro instance: NEW_ARRAY("Lightning", "lightning")
    function s__Table__lightnings__getindex takes integer this,integer key returns lightning
        return LoadLightningHandle(Table__ht, this, key)
    endfunction
    function s__Table__lightnings__setindex takes integer this,integer key,lightning value returns nothing
        call SaveLightningHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Lightning", "lightning")
//textmacro instance: NEW_ARRAY("Image", "image")
    function s__Table__images__getindex takes integer this,integer key returns image
        return LoadImageHandle(Table__ht, this, key)
    endfunction
    function s__Table__images__setindex takes integer this,integer key,image value returns nothing
        call SaveImageHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Image", "image")
//textmacro instance: NEW_ARRAY("Ubersplat", "ubersplat")
    function s__Table__ubersplats__getindex takes integer this,integer key returns ubersplat
        return LoadUbersplatHandle(Table__ht, this, key)
    endfunction
    function s__Table__ubersplats__setindex takes integer this,integer key,ubersplat value returns nothing
        call SaveUbersplatHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Ubersplat", "ubersplat")
//textmacro instance: NEW_ARRAY("Region", "region")
    function s__Table__regions__getindex takes integer this,integer key returns region
        return LoadRegionHandle(Table__ht, this, key)
    endfunction
    function s__Table__regions__setindex takes integer this,integer key,region value returns nothing
        call SaveRegionHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Region", "region")
//textmacro instance: NEW_ARRAY("FogState", "fogstate")
    function s__Table__fogstates__getindex takes integer this,integer key returns fogstate
        return LoadFogStateHandle(Table__ht, this, key)
    endfunction
    function s__Table__fogstates__setindex takes integer this,integer key,fogstate value returns nothing
        call SaveFogStateHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("FogState", "fogstate")
//textmacro instance: NEW_ARRAY("FogModifier", "fogmodifier")
    function s__Table__fogmodifiers__getindex takes integer this,integer key returns fogmodifier
        return LoadFogModifierHandle(Table__ht, this, key)
    endfunction
    function s__Table__fogmodifiers__setindex takes integer this,integer key,fogmodifier value returns nothing
        call SaveFogModifierHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("FogModifier", "fogmodifier")
//textmacro instance: NEW_ARRAY("Hashtable", "hashtable")
    function s__Table__hashtables__getindex takes integer this,integer key returns hashtable
        return LoadHashtableHandle(Table__ht, this, key)
    endfunction
    function s__Table__hashtables__setindex takes integer this,integer key,hashtable value returns nothing
        call SaveHashtableHandle(Table__ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Hashtable", "hashtable")
   
   
    // Implement modules for intuitive syntax (tb.handle; tb.unit; etc.)
//Implemented from module Table__realm:
    function s__Table__get_real takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__booleanm:
    function s__Table__get_boolean takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__stringm:
    function s__Table__get_string takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__playerm:
    function s__Table__get_player takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__widgetm:
    function s__Table__get_widget takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__destructablem:
    function s__Table__get_destructable takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__itemm:
    function s__Table__get_item takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__unitm:
    function s__Table__get_unit takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__abilitym:
    function s__Table__get_ability takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__timerm:
    function s__Table__get_timer takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__triggerm:
    function s__Table__get_trigger takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__triggerconditionm:
    function s__Table__get_triggercondition takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__triggeractionm:
    function s__Table__get_triggeraction takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__eventm:
    function s__Table__get_event takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__forcem:
    function s__Table__get_force takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__groupm:
    function s__Table__get_group takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__locationm:
    function s__Table__get_location takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__rectm:
    function s__Table__get_rect takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__boolexprm:
    function s__Table__get_boolexpr takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__soundm:
    function s__Table__get_sound takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__effectm:
    function s__Table__get_effect takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__unitpoolm:
    function s__Table__get_unitpool takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__itempoolm:
    function s__Table__get_itempool takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__questm:
    function s__Table__get_quest takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__questitemm:
    function s__Table__get_questitem takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__defeatconditionm:
    function s__Table__get_defeatcondition takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__timerdialogm:
    function s__Table__get_timerdialog takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__leaderboardm:
    function s__Table__get_leaderboard takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__multiboardm:
    function s__Table__get_multiboard takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__multiboarditemm:
    function s__Table__get_multiboarditem takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__trackablem:
    function s__Table__get_trackable takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__dialogm:
    function s__Table__get_dialog takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__buttonm:
    function s__Table__get_button takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__texttagm:
    function s__Table__get_texttag takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__lightningm:
    function s__Table__get_lightning takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__imagem:
    function s__Table__get_image takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__ubersplatm:
    function s__Table__get_ubersplat takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__regionm:
    function s__Table__get_region takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__fogstatem:
    function s__Table__get_fogstate takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__fogmodifierm:
    function s__Table__get_fogmodifier takes integer this returns integer
        return this
    endfunction
//Implemented from module Table__hashtablem:
    function s__Table__get_hashtable takes integer this returns integer
        return this
    endfunction
   
    function s__Table__get_handle takes integer this returns integer
        return this
    endfunction
   
    function s__Table__get_agent takes integer this returns integer
        return this
    endfunction
   
    //set this = tb[GetSpellAbilityId()]
    function s__Table__getindex takes integer this,integer key returns integer
        return LoadInteger(Table__ht, this, key)
    endfunction
   
    //set tb[389034] = 8192
    function s__Table__setindex takes integer this,integer key,integer tb returns nothing
        call SaveInteger(Table__ht, this, key, tb)
    endfunction
   
    //set b = tb.has(2493223)
    function s__Table_has takes integer this,integer key returns boolean
        return HaveSavedInteger(Table__ht, this, key)
    endfunction
   
    //call tb.remove(294080)
    function s__Table_remove takes integer this,integer key returns nothing
        call RemoveSavedInteger(Table__ht, this, key)
    endfunction
   
    //Remove all data from a Table instance
    function s__Table_flush takes integer this returns nothing
        call FlushChildHashtable(Table__ht, this)
    endfunction
   
    //local Table tb = Table.create()
    function s__Table_create takes nothing returns integer
        local integer this= (LoadInteger(Table__ht, ((Table__listK)), (0))) // INLINED!!
       
        if this == 0 then
            set this=Table__more + 1
            set Table__more=this
        else
            call SaveInteger(Table__ht, ((Table__listK)), (0), ( (LoadInteger(Table__ht, ((Table__listK)), (this))))) // INLINED!!
            call RemoveSavedInteger(Table__ht, ((Table__listK)), (this)) //Clear hashed memory // INLINED!!
        endif
       
// NO_DEBUG:         debug set Table__dex.list[this] = -1
        return this
    endfunction
   
    // Removes all data from a Table instance and recycles its index.
    //
    //     call tb.destroy()
    //
    function s__Table_destroy takes integer this returns nothing
// NO_DEBUG:         debug if Table__dex.list[this] != -1 then
// NO_DEBUG:             debug call BJDebugMsg("Table Error: Tried to double-free instance: " + I2S(this))
// NO_DEBUG:             debug return
// NO_DEBUG:         debug endif
       
        call FlushChildHashtable(Table__ht, (this)) // INLINED!!
       
        call SaveInteger(Table__ht, ((Table__listK)), (this), ( (LoadInteger(Table__ht, ((Table__listK)), (0))))) // INLINED!!
        call SaveInteger(Table__ht, ((Table__listK)), (0), ( this)) // INLINED!!
    endfunction
   
//ignored textmacro command: TABLE_BC_METHODS()
   
//ignored textmacro command: TABLE_BC_STRUCTS()
   
   
    //Returns a new TableArray to do your bidding. Simply use:
    //
    //    local TableArray ta = TableArray[array_size]
    //
    function s__TableArray__staticgetindex takes integer array_size returns integer
        local integer tb= (LoadInteger(Table__ht, ((Table__sizeK)), (array_size))) // INLINED!!
        local integer this= (LoadInteger(Table__ht, (tb), (0))) // INLINED!!
       
// NO_DEBUG:         debug if array_size <= 0 then
// NO_DEBUG:             debug call BJDebugMsg("TypeError: Invalid specified TableArray size: " + I2S(array_size))
// NO_DEBUG:             debug return 0
// NO_DEBUG:         debug endif
       
        if this == 0 then
            set this=Table__less - array_size
            set Table__less=this
        else
            call SaveInteger(Table__ht, (tb), (0), ( (LoadInteger(Table__ht, (tb), (this))))) //Set the last destroyed to the last-last destroyed // INLINED!!
            call RemoveSavedInteger(Table__ht, (tb), (this)) //Clear hashed memory // INLINED!!
        endif
       
        call SaveInteger(Table__ht, ((Table__sizeK)), (this), ( array_size)) //This remembers the array size // INLINED!!
        return this
    endfunction
   
    //Returns the size of the TableArray
    function s__TableArray__get_size takes integer this returns integer
        return (LoadInteger(Table__ht, ((Table__sizeK)), (this))) // INLINED!!
    endfunction
   
    //This magic method enables two-dimensional[array][syntax] for Tables,
    //similar to the two-dimensional utility provided by hashtables them-
    //selves.
    //
    //ta[integer a].unit[integer b] = unit u
    //ta[integer a][integer c] = integer d
    //
    //Inline-friendly when not running in debug mode
    //
    function s__TableArray__getindex takes integer this,integer key returns integer










        return this + key
    endfunction
   
    //Destroys a TableArray without flushing it; I assume you call .flush()
    //if you want it flushed too. This is a public method so that you don't
    //have to loop through all TableArray indices to flush them if you don't
    //need to (ie. if you were flushing all child-keys as you used them).
    //
    function s__TableArray_destroy takes integer this returns nothing
        local integer tb= (LoadInteger(Table__ht, ((Table__sizeK)), ((LoadInteger(Table__ht, ((Table__sizeK)), ((this))))))) // INLINED!!
       
// NO_DEBUG:         debug if this.size == 0 then
// NO_DEBUG:             debug call BJDebugMsg("TypeError: Tried to destroy an invalid TableArray: " + I2S(this))
// NO_DEBUG:             debug return
// NO_DEBUG:         debug endif
       
        if tb == 0 then
            //Create a Table to index recycled instances with their array size
            set tb=s__Table_create()
            call SaveInteger(Table__ht, ((Table__sizeK)), ((LoadInteger(Table__ht, ((Table__sizeK)), ((this))))), ( tb)) // INLINED!!
        endif
       
        call RemoveSavedInteger(Table__ht, ((Table__sizeK)), (this)) //Clear the array size from hash memory // INLINED!!
       
        call SaveInteger(Table__ht, (tb), (this), ( (LoadInteger(Table__ht, (tb), (0))))) // INLINED!!
        call SaveInteger(Table__ht, (tb), (0), ( this)) // INLINED!!
    endfunction
   
   
    //Avoids hitting the op limit
    function s__TableArray_clean takes nothing returns nothing
        local integer tb= s__TableArray_tempTable
        local integer end= tb + 0x1000
        if end < s__TableArray_tempEnd then
            set s__TableArray_tempTable=end
            call ForForce(bj_FORCE_PLAYER[0], function s__TableArray_clean)
        else
            set end=s__TableArray_tempEnd
        endif
        loop
            call FlushChildHashtable(Table__ht, (tb)) // INLINED!!
            set tb=tb + 1
            exitwhen tb == end
        endloop
    endfunction
   
    //Flushes the TableArray and also destroys it. Doesn't get any more
    //similar to the FlushParentHashtable native than this.
    //
    function s__TableArray_flush takes integer this returns nothing
// NO_DEBUG:         debug if this.size == 0 then
// NO_DEBUG:             debug call BJDebugMsg("TypeError: Tried to flush an invalid TableArray instance: " + I2S(this))
// NO_DEBUG:             debug return
// NO_DEBUG:         debug endif
        set s__TableArray_tempTable=this
        set s__TableArray_tempEnd=this + (LoadInteger(Table__ht, ((Table__sizeK)), ((this)))) // INLINED!!
        call ForForce(bj_FORCE_PLAYER[0], function s__TableArray_clean)
        call s__TableArray_destroy(this)
    endfunction
   
   

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

            // new blue
            call SaveInteger(TimerUtils___ht, 0, GetHandleId(t), value)
            

















    endfunction

    function GetTimerData takes timer t returns integer

            // new blue
            return LoadInteger(TimerUtils___ht, 0, GetHandleId(t))
            

















    endfunction

    //==========================================================================================

    //==========================================================================================
    // I needed to decide between duplicating code ignoring the "Once and only once" rule
    // and using the ugly textmacros. I guess textmacros won.
    //

    function NewTimerEx takes integer value returns timer
        if ( TimerUtils___tN == 0 ) then
            if ( not TimerUtils___didinit ) then
                //This extra if shouldn't represent a major performance drawback
                //because QUANTITY rule is not supposed to be broken every day. 
                call TriggerEvaluate(st___prototype2[(1)]) // INLINED!!
                set TimerUtils___tN=TimerUtils___tN - 1
            else
                //If this happens then the QUANTITY rule has already been broken, try to fix the
                // issue, else fail.
// NO_DEBUG:                 debug call BJDebugMsg("NewTimer: Warning, Exceeding TimerUtils_QUANTITY, make sure all timers are getting recycled correctly")
                set s__TimerUtils___tT[0]= CreateTimer()
















            endif
        else
            set TimerUtils___tN=TimerUtils___tN - 1
        endif
        call SaveInteger(TimerUtils___ht, 0, GetHandleId((s__TimerUtils___tT[TimerUtils___tN] )), ( value)) // INLINED!!
     return s__TimerUtils___tT[TimerUtils___tN]
    endfunction
    
    function NewTimer takes nothing returns timer
        return NewTimerEx(0)
    endfunction


    //==========================================================================================
    function ReleaseTimer takes timer t returns nothing
        if ( t == null ) then
// NO_DEBUG:             debug call BJDebugMsg("Warning: attempt to release a null timer")
            return
        endif
        if ( TimerUtils___tN == TimerUtils___ARRAY_SIZE ) then
// NO_DEBUG:             debug call BJDebugMsg("Warning: Timer stack is full, destroying timer!!")
// NO_DEBUG: 
            //stack is full, the map already has much more troubles than the chance of bug
            call DestroyTimer(t)
        else
            call PauseTimer(t)
            if ( (LoadInteger(TimerUtils___ht, 0, GetHandleId((t)))) == TimerUtils___HELD ) then // INLINED!!
// NO_DEBUG:                 debug call BJDebugMsg("Warning: ReleaseTimer: Double free!")
                return
            endif
            call SaveInteger(TimerUtils___ht, 0, GetHandleId((t )), ( TimerUtils___HELD)) // INLINED!!
            set s__TimerUtils___tT[TimerUtils___tN]= t
            set TimerUtils___tN=TimerUtils___tN + 1
        endif
    endfunction

    function TimerUtils___init takes nothing returns nothing
     local integer i=0
     local integer o=- 1
     local boolean oops= false
        if ( TimerUtils___didinit ) then
            return
        else
            set TimerUtils___didinit=true
        endif
     

            set TimerUtils___ht=InitHashtable()
            loop
                exitwhen ( i == TimerUtils___QUANTITY )
                set s__TimerUtils___tT[i]= CreateTimer()
                call SaveInteger(TimerUtils___ht, 0, GetHandleId((s__TimerUtils___tT[i] )), ( TimerUtils___HELD)) // INLINED!!
                set i=i + 1
            endloop
            set TimerUtils___tN=TimerUtils___QUANTITY












































    endfunction


	
		
		
		
		
//Implemented from module WorldBounds___WorldBoundInit:
  function s__WorldBounds_WorldBounds___WorldBoundInit___onInit takes nothing returns nothing
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


    function s__GroundCollision_alive takes unit u returns boolean
        return GetUnitTypeId(u) != 0 and GetWidgetLife(u) > 0.405
    endfunction

    function s__GroundCollision_hideItem takes nothing returns nothing
        local item it= GetEnumItem()
        if it != s__GroundCollision_probe and IsItemVisible(it) then
            set s__GroundCollision_hidden[s__GroundCollision_hiddenCount]=it
            set s__GroundCollision_hiddenCount=s__GroundCollision_hiddenCount + 1
            call SetItemVisible(it, false)
        endif
        set it=null
    endfunction

    function s__GroundCollision_point takes real px,real py returns boolean
        local real dx
        local real dy
        if IsTerrainPathable(px, py, PATHING_TYPE_WALKABILITY) then
            return false
        endif
        call MoveRectTo(s__GroundCollision_area, px, py)
        call EnumItemsInRect(s__GroundCollision_area, null, function s__GroundCollision_hideItem)
        call SetItemPosition(s__GroundCollision_probe, px, py)
        set dx=GetItemX(s__GroundCollision_probe) - px
        set dy=GetItemY(s__GroundCollision_probe) - py
        call SetItemVisible(s__GroundCollision_probe, false)
        loop
            exitwhen s__GroundCollision_hiddenCount == 0
            set s__GroundCollision_hiddenCount=s__GroundCollision_hiddenCount - 1
            call SetItemVisible(s__GroundCollision_hidden[s__GroundCollision_hiddenCount], true)
            set s__GroundCollision_hidden[s__GroundCollision_hiddenCount]=null
        endloop
        return dx * dx + dy * dy <= 1.
    endfunction

    function s__GroundCollision_destructable takes nothing returns nothing
        local destructable d= GetEnumDestructable()
        local real dx= GetDestructableX(d) - s__GroundCollision_testX
        local real dy= GetDestructableY(d) - s__GroundCollision_testY
        if not s__GroundCollision_destBlocked and GetWidgetLife(d) > 0.405 and dx * dx + dy * dy <= ( s__GroundCollision_testRadius + 32. ) * ( s__GroundCollision_testRadius + 32. ) then
            // Native pathing covers authored footprints. This also catches live
            // trees/solid tall destructibles with missing/small footprints.
            if GetDestructableOccluderHeight(d) >= 32. or IsTreeAlive(d) then
                set s__GroundCollision_destBlocked=true
            endif
        endif
        set d=null
    endfunction

    function s__GroundCollision_height takes real px,real py returns real
        call MoveLocation(s__GroundCollision_heightPoint, px, py)
        return GetLocationZ(s__GroundCollision_heightPoint)
    endfunction

    function s__GroundCollision_clear takes real px,real py,real radius returns boolean
        local integer i= 0
        local real a
        if px - radius <= s__WorldBounds_minX or px + radius >= s__WorldBounds_maxX or py - radius <= s__WorldBounds_minY or py + radius >= s__WorldBounds_maxY then
            return false
        endif
        if not s__GroundCollision_point(px , py) then
            return false
        endif
        loop
            exitwhen i == 8
            set a=I2R(i) * bj_PI / 4.
            if not s__GroundCollision_point(px + ( radius + 2. ) * Cos(a) , py + ( radius + 2. ) * Sin(a)) then
                return false
            endif
            set i=i + 1
        endloop
        set s__GroundCollision_testX=px
        set s__GroundCollision_testY=py
        set s__GroundCollision_testRadius=radius
        set s__GroundCollision_destBlocked=false
        call SetRect(s__GroundCollision_area, px - radius - 64., py - radius - 64., px + radius + 64., py + radius + 64.)
        call EnumDestructablesInRect(s__GroundCollision_area, null, function s__GroundCollision_destructable)
        // Restore the query rectangle size expected by the item probe.
        call SetRect(s__GroundCollision_area, 0., 0., 256., 256.)
        return not s__GroundCollision_destBlocked
    endfunction

    function s__GroundCollision_trace takes real ax,real ay,real bx,real by,real radius,unit source,player owner,boolean units returns integer
        local real dx= bx - ax
        local real dy= by - ay
        local integer steps= R2I(SquareRoot(dx * dx + dy * dy) / 8.) + 1
        local integer i= 1
        local real nx
        local real ny
        local real lastZ= s__GroundCollision_height(ax , ay)
        local real z
        local unit u
        set s__GroundCollision_x=ax
        set s__GroundCollision_y=ay
        set s__GroundCollision_hit=null
        set s__GroundCollision_reason=0
        loop
            exitwhen i > steps
            set nx=ax + dx * I2R(i) / I2R(steps)
            set ny=ay + dy * I2R(i) / I2R(steps)
            set z=s__GroundCollision_height(nx , ny)
            if not s__GroundCollision_clear(nx , ny , radius) or RAbsBJ(z - lastZ) > 24. then
                set s__GroundCollision_reason=1
                return s__GroundCollision_reason
            endif
            if units then
                call GroupEnumUnitsInRange(s__GroundCollision_targets, nx, ny, radius + 128., null)
                loop
                    set u=FirstOfGroup(s__GroundCollision_targets)
                    exitwhen u == null
                    call GroupRemoveUnit(s__GroundCollision_targets, u)
                    if u != source and s__GroundCollision_alive(u) and IsUnitEnemy(u, owner) and not IsUnitType(u, UNIT_TYPE_FLYING) and GetUnitTypeId(u) != 'dumi' and GetUnitTypeId(u) != 'dcst' and GetUnitTypeId(u) != 'rfct' then
                        if IsUnitInRangeXY(u, nx, ny, radius) then
                            set s__GroundCollision_hit=u
                            set s__GroundCollision_x=nx
                            set s__GroundCollision_y=ny
                            set s__GroundCollision_reason=2
                            call GroupClear(s__GroundCollision_targets)
                            set u=null
                            return s__GroundCollision_reason
                        endif
                    endif
                endloop
            endif
            set s__GroundCollision_x=nx
            set s__GroundCollision_y=ny
            set lastZ=z
            set i=i + 1
        endloop
        set u=null
        return 0
    endfunction

    function s__GroundCollision_initialize takes nothing returns nothing
        set s__GroundCollision_probe=CreateItem('wolg', s__WorldBounds_minX + 128., s__WorldBounds_minY + 128.)
        call SetItemVisible(s__GroundCollision_probe, false)
    endfunction
function GroundCollision__Init takes nothing returns nothing
    call s__GroundCollision_initialize()
endfunction


    // Public read-only snapshot. Death/timeout observations have <=1s latency.

    // 1 reserve; 2 borrowed; 3 waiting for fx; 4 timed-life disposal.

    function s__MissileStats_value takes integer row,string text returns nothing
        local multiboarditem mbi
        if s__MissileStats_cell[row] != text then
            set s__MissileStats_cell[row]=text
            set mbi=MultiboardGetItem(s__MissileStats_board, row, 1)
            call MultiboardSetItemValue(mbi, text)
            call MultiboardReleaseItem(mbi)
            set mbi=null
        endif
    endfunction

    function s__MissileStats_label takes integer row,string text returns nothing
        local multiboarditem mbi= MultiboardGetItem(s__MissileStats_board, row, 0)
        call MultiboardSetItemValue(mbi, text)
        call MultiboardSetItemWidth(mbi, 0.17)
        call MultiboardReleaseItem(mbi)
        set mbi=MultiboardGetItem(s__MissileStats_board, row, 1)
        call MultiboardSetItemWidth(mbi, 0.12)
        call MultiboardReleaseItem(mbi)
        set mbi=null
    endfunction

    function s__MissileStats_warning takes integer n returns string
        if n > 0 then
            return "|cffff5555" + I2S(n) + "|r"
        endif
        return I2S(n)
    endfunction

    function s__MissileStats_draw takes nothing returns nothing
        local string nextTitle
        set s__MissileStats_queued=false
        if s__MissileStats_board == null then
            set s__MissileStats_board=CreateMultiboard()
            call MultiboardSetRowCount(s__MissileStats_board, 19)
            call MultiboardSetColumnCount(s__MissileStats_board, 2)
            call MultiboardSetItemsStyle(s__MissileStats_board, true, false)
            call s__MissileStats_label(0 , "Instancias / pico")
            call s__MissileStats_label(1 , "Creadas / retiradas")
            call s__MissileStats_label(2 , "Instancia mas antigua")
            call s__MissileStats_label(3 , "Dummies vivos / pico")
            call s__MissileStats_label(4 , "Dummies prestados")
            call s__MissileStats_label(5 , "Reserva / capacidad")
            call s__MissileStats_label(6 , "Esperando efectos")
            call s__MissileStats_label(7 , "Descarte pendiente")
            call s__MissileStats_label(8 , "Esperas vencidas")
            call s__MissileStats_label(9 , "Precreados / nuevos")
            call s__MissileStats_label(10 , "Reutilizaciones")
            call s__MissileStats_label(11 , "Descartes expirados")
            call s__MissileStats_label(12 , "Perdidas inesperadas")
            call s__MissileStats_label(13 , "Reciclajes invalidos")
            call s__MissileStats_label(14 , "Externos / omitidos")
            call s__MissileStats_label(15 , "Inconsistencias / errores")
            call s__MissileStats_label(16 , "Alarmas historicas")
            call s__MissileStats_label(17 , "Revisiones de vida")
            call s__MissileStats_label(18 , "Ver / ocultar")
            call MultiboardDisplay(s__MissileStats_board, true)
            call MultiboardMinimize(s__MissileStats_board, false)
        endif
        if s__MissileStats_overdue > 0 or s__MissileStats_lost > 0 or s__MissileStats_invalid > 0 or s__MissileStats_omitted > 0 or s__MissileStats_errors > 0 or s__MissileStats_inconsistent > 0 then
            set nextTitle="|cffff5555Misiles: ALERTA|r"
        elseif s__MissileStats_alarms > 0 then
            set nextTitle="|cffffcc44Misiles: revisar historial|r"
        elseif s__MissileStats_oldestSeconds >= s__MissileStats_OLD_AGE then
            set nextTitle="|cffffcc44Misiles: revisar edad|r"
        elseif s__MissileStats_active > 0 or s__MissileStats_deferred > 0 or s__MissileStats_pending > 0 then
            set nextTitle="|cff66ccffMisiles: actividad|r"
        else
            set nextTitle="|cff66ff88Misiles: OK|r"
        endif
        if nextTitle != s__MissileStats_title then
            set s__MissileStats_title=nextTitle
            call MultiboardSetTitleText(s__MissileStats_board, s__MissileStats_title)
        endif
        call s__MissileStats_value(0 , I2S(s__MissileStats_active) + " / " + I2S(s__MissileStats_peakActive))
        call s__MissileStats_value(1 , I2S(s__MissileStats_created) + " / " + I2S(s__MissileStats_retired))
        call s__MissileStats_value(2 , I2S(s__MissileStats_oldestSeconds) + " s (aviso 30)")
        call s__MissileStats_value(3 , I2S(s__MissileStats_tracked) + " / " + I2S(s__MissileStats_peakTracked))
        call s__MissileStats_value(4 , I2S(s__MissileStats_borrowed))
        call s__MissileStats_value(5 , I2S(s__MissileStats_pooled) + " / " + I2S(s__MissileStats_capacity))
        call s__MissileStats_value(6 , I2S(s__MissileStats_deferred))
        call s__MissileStats_value(7 , I2S(s__MissileStats_pending))
        call s__MissileStats_value(8 , s__MissileStats_warning(s__MissileStats_overdue))
        call s__MissileStats_value(9 , I2S(s__MissileStats_preloadTotal) + " / " + I2S(s__MissileStats_newTotal))
        call s__MissileStats_value(10 , I2S(s__MissileStats_reusedTotal))
        call s__MissileStats_value(11 , I2S(s__MissileStats_disposed))
        call s__MissileStats_value(12 , s__MissileStats_warning(s__MissileStats_lost))
        call s__MissileStats_value(13 , s__MissileStats_warning(s__MissileStats_invalid))
        call s__MissileStats_value(14 , I2S(s__MissileStats_adoptedTotal) + " / " + s__MissileStats_warning(s__MissileStats_omitted))
        call s__MissileStats_value(15 , s__MissileStats_warning(s__MissileStats_inconsistent) + " / " + s__MissileStats_warning(s__MissileStats_errors))
        call s__MissileStats_value(16 , I2S(s__MissileStats_alarms))
        call s__MissileStats_value(17 , I2S(s__MissileStats_checks) + " (cada 1 s)")
        call s__MissileStats_value(18 , "-misiles")
        set s__MissileStats_renders=s__MissileStats_renders + 1
    endfunction

    function s__MissileStats_touch takes nothing returns nothing
        if s__MissileStats_initialized and not s__MissileStats_queued then
            set s__MissileStats_queued=true
            // Coalesce all hooks in this execution; no drawing in physics loops.
            call TimerStart(s__MissileStats_painter, 0., false, function s__MissileStats_draw)
        endif
    endfunction

    function s__MissileStats_error takes nothing returns nothing
        set s__MissileStats_errors=s__MissileStats_errors + 1
        set s__MissileStats_alarms=s__MissileStats_alarms + 1
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_changeState takes integer slot,integer nextState returns nothing
        if s__MissileStats_state[slot] == 1 then
            set s__MissileStats_pooled=s__MissileStats_pooled - 1
        elseif s__MissileStats_state[slot] == 2 then
            set s__MissileStats_borrowed=s__MissileStats_borrowed - 1
        elseif s__MissileStats_state[slot] == 3 then
            set s__MissileStats_deferred=s__MissileStats_deferred - 1
        elseif s__MissileStats_state[slot] == 4 then
            set s__MissileStats_pending=s__MissileStats_pending - 1
        endif
        set s__MissileStats_state[slot]=nextState
        set s__MissileStats_warned[slot]=false
        if nextState == 1 then
            set s__MissileStats_pooled=s__MissileStats_pooled + 1
        elseif nextState == 2 then
            set s__MissileStats_borrowed=s__MissileStats_borrowed + 1
        elseif nextState == 3 then
            set s__MissileStats_deferred=s__MissileStats_deferred + 1
        elseif nextState == 4 then
            set s__MissileStats_pending=s__MissileStats_pending + 1
        endif
    endfunction

    function s__MissileStats_track takes unit u returns integer
        local integer slot
        if u == null then
            call s__MissileStats_error()
            return 0
        endif
        set slot=(LoadInteger(Table__ht, (s__MissileStats_index), (GetHandleId(u)))) // INLINED!!
        if slot != 0 then
            return slot
        endif
        if s__MissileStats_tracked == s__MissileStats_LIMIT then
            set s__MissileStats_omitted=s__MissileStats_omitted + 1
            set s__MissileStats_alarms=s__MissileStats_alarms + 1
            call s__MissileStats_touch()
            return 0
        endif
        set s__MissileStats_tracked=s__MissileStats_tracked + 1
        set slot=s__MissileStats_tracked
        set s__MissileStats_units[slot]=u
        set s__MissileStats_state[slot]=0
        set s__MissileStats_deadline[slot]=0.
        set s__MissileStats_warned[slot]=false
        call SaveInteger(Table__ht, (s__MissileStats_index), (GetHandleId(u)), ( slot)) // INLINED!!
        if s__MissileStats_tracked > s__MissileStats_peakTracked then
            set s__MissileStats_peakTracked=s__MissileStats_tracked
        endif
        return slot
    endfunction

    // Called exactly once by the recycler initializer, then once per preload.
    function s__MissileStats_configure takes integer slots returns nothing
        set s__MissileStats_capacity=slots
        call s__MissileStats_touch()
    endfunction
    function s__MissileStats_preload takes unit u returns nothing
        local integer slot= s__MissileStats_track(u)
        set s__MissileStats_preloadTotal=s__MissileStats_preloadTotal + 1
        if slot != 0 then
            call s__MissileStats_changeState(slot , 1)
        endif
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_acquire takes unit u,boolean reused returns nothing
        local integer slot= s__MissileStats_track(u)
        if reused then
            set s__MissileStats_reusedTotal=s__MissileStats_reusedTotal + 1
        else
            set s__MissileStats_newTotal=s__MissileStats_newTotal + 1
        endif
        if slot != 0 then
            call s__MissileStats_changeState(slot , 2)
            set s__MissileStats_deadline[slot]=0.
        endif
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_returned takes unit u,boolean stored,real duration returns nothing
        local integer slot= (LoadInteger(Table__ht, (s__MissileStats_index), (GetHandleId(u)))) // INLINED!!
        if slot == 0 then
            set s__MissileStats_adoptedTotal=s__MissileStats_adoptedTotal + 1
            set slot=s__MissileStats_track(u)
        endif
        if slot != 0 then
            if stored then
                call s__MissileStats_changeState(slot , 1)
            else
                call s__MissileStats_changeState(slot , 4)
            endif
            set s__MissileStats_deadline[slot]=TimerGetElapsed(s__MissileStats_clock) + duration
        endif
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_delay takes unit u,real duration returns nothing
        local integer slot= (LoadInteger(Table__ht, (s__MissileStats_index), (GetHandleId(u)))) // INLINED!!
        if slot != 0 then
            call s__MissileStats_changeState(slot , 3)
            set s__MissileStats_deadline[slot]=TimerGetElapsed(s__MissileStats_clock) + duration
        endif
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_invalidReturn takes nothing returns nothing
        set s__MissileStats_invalid=s__MissileStats_invalid + 1
        set s__MissileStats_alarms=s__MissileStats_alarms + 1
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_allocated takes integer node returns nothing
        // Classic arrays also support the core's last valid node ID, 8191.
        // LIMIT applies only to the separate unit-handle tracking table.
        if node < 1 or node > 8191 then
            set s__MissileStats_omitted=s__MissileStats_omitted + 1
            call s__MissileStats_error()
            return
        endif
        if s__MissileStats_nodeSlot[node] != 0 then
            call s__MissileStats_error()
            return
        endif
        set s__MissileStats_active=s__MissileStats_active + 1
        set s__MissileStats_created=s__MissileStats_created + 1
        set s__MissileStats_nodes[s__MissileStats_active]=node
        set s__MissileStats_nodeSlot[node]=s__MissileStats_active
        set s__MissileStats_born[node]=TimerGetElapsed(s__MissileStats_clock)
        if s__MissileStats_active > s__MissileStats_peakActive then
            set s__MissileStats_peakActive=s__MissileStats_active
        endif
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_released takes integer node returns nothing
        local integer slot= s__MissileStats_nodeSlot[node]
        if slot == 0 then
            call s__MissileStats_error()
            return
        endif
        set s__MissileStats_nodes[slot]=s__MissileStats_nodes[s__MissileStats_active]
        set s__MissileStats_nodeSlot[s__MissileStats_nodes[slot]]=slot
        set s__MissileStats_nodeSlot[node]=0
        set s__MissileStats_nodes[s__MissileStats_active]=0
        set s__MissileStats_active=s__MissileStats_active - 1
        set s__MissileStats_retired=s__MissileStats_retired + 1
        call s__MissileStats_touch()
    endfunction

    // Public for fixtures; the live observer also calls it once per second.
    function s__MissileStats_inspect takes nothing returns nothing
        local integer i= 1
        local integer age
        local integer bad= 0
        local real now= TimerGetElapsed(s__MissileStats_clock)
        set s__MissileStats_oldestSeconds=0
        set s__MissileStats_overdue=0
        set s__MissileStats_inconsistent=0
        loop
            exitwhen i > s__MissileStats_active
            set age=R2I(now - s__MissileStats_born[s__MissileStats_nodes[i]])
            if age > s__MissileStats_oldestSeconds then
                set s__MissileStats_oldestSeconds=age
            endif
            set i=i + 1
        endloop
        set i=1
        loop
            exitwhen i > s__MissileStats_tracked
            if GetUnitTypeId(s__MissileStats_units[i]) == 0 or GetWidgetLife(s__MissileStats_units[i]) <= 0.405 then
                if s__MissileStats_state[i] == 4 then
                    set s__MissileStats_disposed=s__MissileStats_disposed + 1
                else
                    set s__MissileStats_lost=s__MissileStats_lost + 1
                    set s__MissileStats_alarms=s__MissileStats_alarms + 1
                endif
                call RemoveSavedInteger(Table__ht, (s__MissileStats_index), (GetHandleId(s__MissileStats_units[i]))) // INLINED!!
                call s__MissileStats_changeState(i , 0)
                if i != s__MissileStats_tracked then
                    set s__MissileStats_units[i]=s__MissileStats_units[s__MissileStats_tracked]
                    set s__MissileStats_state[i]=s__MissileStats_state[s__MissileStats_tracked]
                    set s__MissileStats_deadline[i]=s__MissileStats_deadline[s__MissileStats_tracked]
                    set s__MissileStats_warned[i]=s__MissileStats_warned[s__MissileStats_tracked]
                    call SaveInteger(Table__ht, (s__MissileStats_index), (GetHandleId(s__MissileStats_units[i])), ( i)) // INLINED!!
                endif
                set s__MissileStats_units[s__MissileStats_tracked]=null
                set s__MissileStats_state[s__MissileStats_tracked]=0
                set s__MissileStats_deadline[s__MissileStats_tracked]=0.
                set s__MissileStats_warned[s__MissileStats_tracked]=false
                set s__MissileStats_tracked=s__MissileStats_tracked - 1
            else
                set bad=0
                if ( s__MissileStats_state[i] == 3 or s__MissileStats_state[i] == 4 ) and now > s__MissileStats_deadline[i] + s__MissileStats_GRACE then
                    set s__MissileStats_overdue=s__MissileStats_overdue + 1
                    set bad=1
                endif
                if s__MissileStats_state[i] == 1 and GetUnitUserData(s__MissileStats_units[i]) != - 1 then
                    set s__MissileStats_inconsistent=s__MissileStats_inconsistent + 1
                    set bad=1
                endif
                if bad == 1 and not s__MissileStats_warned[i] then
                    set s__MissileStats_warned[i]=true
                    set s__MissileStats_alarms=s__MissileStats_alarms + 1
                endif
                set i=i + 1
            endif
        endloop
        if s__MissileStats_active != s__MissileStats_created - s__MissileStats_retired or s__MissileStats_tracked != s__MissileStats_pooled + s__MissileStats_borrowed + s__MissileStats_deferred + s__MissileStats_pending then
            set s__MissileStats_inconsistent=s__MissileStats_inconsistent + 1
        endif
        set s__MissileStats_checks=s__MissileStats_checks + 1
        call s__MissileStats_touch()
    endfunction

    function s__MissileStats_watch takes nothing returns nothing
        call s__MissileStats_inspect()
    endfunction

    function s__MissileStats_toggle takes nothing returns nothing
        local integer id= GetPlayerId(GetTriggerPlayer())
        set s__MissileStats_hidden[id]=not s__MissileStats_hidden[id]
        if GetLocalPlayer() == GetTriggerPlayer() then
            // Visual only: no handle creation, game-state writes or RNG here.
            call MultiboardDisplay(s__MissileStats_board, not s__MissileStats_hidden[id])
        endif
    endfunction

    function s__MissileStats_initialize takes nothing returns nothing
        local trigger command= CreateTrigger()
        local integer i= 0
        set s__MissileStats_index=s__Table_create()
        call TimerStart(s__MissileStats_clock, 1000000., false, null)
        call TimerStart(s__MissileStats_watcher, 1., true, function s__MissileStats_watch)
        loop
            exitwhen i == bj_MAX_PLAYERS
            call TriggerRegisterPlayerChatEvent(command, Player(i), "-misiles", true)
            set i=i + 1
        endloop
        call TriggerAddAction(command, function s__MissileStats_toggle)
        set command=null
        set s__MissileStats_initialized=true
        call s__MissileStats_touch()
    endfunction

function MissileDiagnostics___Init takes nothing returns nothing
    call s__MissileStats_initialize()
endfunction

 
//============================================================================
 
//============================================================================
//Implemented from module SpellEffectEvent__M:
   




   
    function s__SpellEffectEvent__S_onCast takes nothing returns nothing

            call TriggerEvaluate((LoadTriggerHandle(Table__ht, (((s__SpellEffectEvent__S_tb))), (GetSpellAbilityId())))) // INLINED!!



    endfunction
 
    function s__SpellEffectEvent__S_SpellEffectEvent__M__onInit takes nothing returns nothing

            set s__SpellEffectEvent__S_tb=s__Table_create()

        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT , function s__SpellEffectEvent__S_onCast)
    endfunction
 
//============================================================================
function RegisterSpellEffectEvent takes integer abil,code onCast returns nothing

        if not (HaveSavedHandle(Table__ht, (((s__SpellEffectEvent__S_tb))), (abil))) then // INLINED!!
            call SaveTriggerHandle(Table__ht, (((s__SpellEffectEvent__S_tb))), (abil), ( CreateTrigger())) // INLINED!!
        endif
        call TriggerAddCondition((LoadTriggerHandle(Table__ht, (((s__SpellEffectEvent__S_tb))), (abil))), Filter(onCast)) // INLINED!!






endfunction
 


    function s__GroundMotion_create takes unit u returns integer
        local integer this= s__GroundMotion__allocate()
        set s__GroundMotion_body[this]=u
        set s__GroundMotion_artificial[this]=false
        set s__GroundMotion_blocked[this]=false
        set s__GroundMotion_hasGoal[this]=false
        set s__GroundMotion_speed[this]=350.
        set s__GroundMotion_radius[this]=24.
        return this
    endfunction

    function s__GroundMotion_destination takes integer this,real px,real py returns nothing
        set s__GroundMotion_goalX[this]=px
        set s__GroundMotion_goalY[this]=py
        set s__GroundMotion_hasGoal[this]=true
        set s__GroundMotion_blocked[this]=false
        if not s__GroundMotion_artificial[this] then
            call IssuePointOrder(s__GroundMotion_body[this], "move", px, py)
        endif
    endfunction

    function s__GroundMotion_enter takes integer this returns nothing
        local integer order= GetUnitCurrentOrder(s__GroundMotion_body[this])
        if s__GroundMotion_artificial[this] then
            return
        endif
        set s__GroundMotion_artificial[this]=true
        set s__GroundMotion_blocked[this]=false
        call SetUnitPathing(s__GroundMotion_body[this], false)
        if order == 851986 or order == 851971 or order == 851990 then
            // Initial zero-duration tick, before the first attack animation.
            // Proven in this 1.27b runtime to cancel native locomotion.
            call SetUnitPosition(s__GroundMotion_body[this], GetUnitX(s__GroundMotion_body[this]), GetUnitY(s__GroundMotion_body[this]))
            set s__GroundMotion_instantTransitions=s__GroundMotion_instantTransitions + 1
        endif
    endfunction

    function s__GroundMotion_step takes integer this,real dt returns nothing
        local real ax= GetUnitX(s__GroundMotion_body[this])
        local real ay= GetUnitY(s__GroundMotion_body[this])
        local real dx
        local real dy
        local real distance
        local real advance
        local real nx
        local real ny
        if not s__GroundMotion_artificial[this] or not s__GroundMotion_hasGoal[this] or not s__GroundCollision_alive(s__GroundMotion_body[this]) then
            return
        endif
        set dx=s__GroundMotion_goalX[this] - ax
        set dy=s__GroundMotion_goalY[this] - ay
        set distance=SquareRoot(dx * dx + dy * dy)
        if distance <= 2. then
            set s__GroundMotion_hasGoal[this]=false
            set s__GroundMotion_blocked[this]=false
            return
        endif
        set advance=RMinBJ(s__GroundMotion_speed[this] * dt, distance)
        set s__GroundMotion_blocked[this]=s__GroundCollision_trace(ax , ay , ax + dx * advance / distance , ay + dy * advance / distance , s__GroundMotion_radius[this] , s__GroundMotion_body[this] , GetOwningPlayer(s__GroundMotion_body[this]) , false) != 0
        set nx=s__GroundCollision_x
        set ny=s__GroundCollision_y
        call SetUnitX(s__GroundMotion_body[this], nx)
        call SetUnitY(s__GroundMotion_body[this], ny)
        set s__GroundMotion_xySteps=s__GroundMotion_xySteps + 1
        if not s__GroundMotion_blocked[this] and distance <= advance + 2. then
            set s__GroundMotion_hasGoal[this]=false
        endif
    endfunction

    function s__GroundMotion_leave takes integer this,boolean resume returns nothing
        if s__GroundMotion_artificial[this] then
            set s__GroundMotion_artificial[this]=false
            set s__GroundMotion_blocked[this]=false
            call SetUnitPathing(s__GroundMotion_body[this], true)
            if resume and s__GroundMotion_hasGoal[this] and s__GroundCollision_alive(s__GroundMotion_body[this]) then
                call IssuePointOrder(s__GroundMotion_body[this], "move", s__GroundMotion_goalX[this], s__GroundMotion_goalY[this])
                set s__GroundMotion_handoffs=s__GroundMotion_handoffs + 1
            endif
        endif
    endfunction

    function s__GroundMotion_destroy takes integer this returns nothing
        call s__GroundMotion_leave(this,false)
        set s__GroundMotion_body[this]=null
        set s__GroundMotion_hasGoal[this]=false
        call s__GroundMotion_deallocate(this)
    endfunction

    //=======================================================================
    // Save the map, then delete the exclaimation mark in the following line.
    // Make sure that you don't have an object in your map with the rawcode
    // 'dumi' and also configure the model path (war3mapImported\dummy.mdl)
    // to the dummy.mdx model created by Vexorian.
    // ObjectMerger disabled: dumi is supplied by the TerrainDev object-data build.

    //Thanks to Vexorian that Optimizer 5.0 no longer kills natives



    function MissileRecycler__ToggleIndexer takes boolean flag returns nothing







    endfunction









    //=======================================================================
    // Get a recycled dummy missile unit. If there are no recycled dummies
    // that are already facing the angle you need, it creates a new dummy for
    // you.
    //
    function GetRecycledMissile takes real x,real y,real z,real facing returns unit
        local integer i= ModuloInteger(R2I(facing), 360) / MissileRecycler__ANG_VAL
        local integer this= MissileRecycler__queueNext[i]
        local unit u
        if this != 0 and TimerGetElapsed(MissileRecycler__gameTime) >= MissileRecycler__timeStamp[this] then
            //Dequeue this
            set MissileRecycler__queueNext[i]=MissileRecycler__queueNext[this]
            if MissileRecycler__queueNext[i] == 0 then
                set MissileRecycler__queueLast[i]=i
            endif
            //Recycle this index
            set MissileRecycler__queueLast[this]=MissileRecycler__recycle
            set MissileRecycler__recycle=this
            //Add queue index to available stack
            set MissileRecycler__queueStack[MissileRecycler__queueStackN]=i
            set MissileRecycler__queueStackN=MissileRecycler__queueStackN + 1
            //Old unit will return as new
            set u=MissileRecycler__stack[this]
            call SetUnitFacing(u, facing)
            call SetUnitUserData(u, 0)
            //Reset the dummy's properties.
            call SetUnitVertexColor(u, 255, 255, 255, 255)
            call SetUnitAnimationByIndex(u, 90)
            call SetUnitScale(u, 1, 0, 0)

                call s__MissileStats_acquire(u , true)

            //call PauseUnit(u, false) -- you can disable "resets" that you don't need to worry about.
// NO_DEBUG:             debug call MissileRecycler__Print("Recycling")
        else
// NO_DEBUG:             debug call MissileRecycler__Print("Creating new")
            call MissileRecycler__ToggleIndexer(false)
            set u=CreateUnit(MissileRecycler__OWNER, MissileRecycler__DUMMY_ID, x, y, facing)
            call MissileRecycler__ToggleIndexer(true)
            call PauseUnit(u, true)

                call s__MissileStats_acquire(u , false)

        endif
        call SetUnitX(u, x)
        call SetUnitY(u, y)
        call SetUnitFlyHeight(u, z, 0)
        set bj_lastCreatedUnit=u
        set u=null
        return bj_lastCreatedUnit
    endfunction

    //=======================================================================
    // You should recycle the dummy missile unit when its job is done.
    //
    function RecycleMissile takes unit u returns nothing
        local integer i
        local integer this= MissileRecycler__recycle
        if GetUnitTypeId(u) == MissileRecycler__DUMMY_ID and UnitAlive(u) and GetUnitUserData(u) != - 1 then
            if MissileRecycler__queueStackN == 0 then
// NO_DEBUG:                 debug call MissileRecycler__Print("Stack is full - removing surplus unit")

                    call s__MissileStats_returned(u , false , MissileRecycler__DEATH_TIME)

                // TerrainDev / Classic 1.27b: paused units freeze timed life.
                // Only surplus units leave the paused pool before disposal.
                call PauseUnit(u, false)
                call UnitApplyTimedLife(u, 'BTLF', MissileRecycler__DEATH_TIME)
                return
            endif
            //Recycle this
            set MissileRecycler__recycle=MissileRecycler__queueLast[this]
            //Index the dummy unit to an available facing angle.
            //Get the last vacant angle index.
            set MissileRecycler__queueStackN=MissileRecycler__queueStackN - 1
            set i=MissileRecycler__queueStack[MissileRecycler__queueStackN]
            //Enqueue this
            set MissileRecycler__queueNext[MissileRecycler__queueLast[i]]=this
            set MissileRecycler__queueLast[i]=this
            set MissileRecycler__queueNext[this]=0
            //Allow a time barrier for the effect to destroy/turn to complete.
            set MissileRecycler__timeStamp[this]=TimerGetElapsed(MissileRecycler__gameTime) + MissileRecycler__DEATH_TIME
            set MissileRecycler__stack[this]=u
            call SetUnitFacing(u, i * MissileRecycler__ANG_VAL + MissileRecycler__ANG_MID)
            call SetUnitOwner(u, MissileRecycler__OWNER, false)
            //Prevent double-free of this unit.
            call SetUnitUserData(u, - 1)

                call s__MissileStats_returned(u , true , MissileRecycler__DEATH_TIME)

        else

                call s__MissileStats_invalidReturn()

// NO_DEBUG:             debug call BJDebugMsg("[MissileRecycler] Error: Attempt to recycle invalid unit.")
        endif
    endfunction

    //=======================================================================
    // I didn't need this function after all
    //
    function RecycleMissileDelayed takes unit u,real r returns nothing
        call RecycleMissile(u)
    endfunction

    //=======================================================================
    // Map the dummy units to their facing angles (map below is if ANG_N is
    // 4 and ANG_STORAGE_MAX is 3).
    //
    // angle[0] (0)   -  [4] [5] [6]
    // angle[1] (90)  -  [7] [8] [9]
    // angle[2] (180) - [10][11][12]
    // angle[3] (270) - [13][14][15]
    //
    function MissileRecycler__Init takes nothing returns nothing
        local integer end
        local integer i= MissileRecycler__ANG_N
        local integer n= i
        local integer angle
        local real x= GetRectMaxX(bj_mapInitialPlayableArea)
        local real y= GetRectMaxY(bj_mapInitialPlayableArea)
        local unit u

            call s__MissileStats_configure(MissileRecycler__ANG_N * MissileRecycler__ANG_STORAGE_MAX)

        call MissileRecycler__ToggleIndexer(false)
        loop
            set i=i - 1
            set MissileRecycler__queueNext[i]=n
            set angle=i * MissileRecycler__ANG_VAL + MissileRecycler__ANG_MID
            set end=n + MissileRecycler__ANG_STORAGE_MAX
            set MissileRecycler__queueLast[i]=end - 1
            loop
                set MissileRecycler__queueNext[n]=n + 1
                set u=CreateUnit(MissileRecycler__OWNER, MissileRecycler__DUMMY_ID, x, y, angle)
                set MissileRecycler__stack[n]=u
                call PauseUnit(u, true)
                call SetUnitUserData(u, - 1)

                    call s__MissileStats_preload(u)

                set n=n + 1
                exitwhen n == end
            endloop
            set MissileRecycler__queueNext[n - 1]=0
            exitwhen i == 0
        endloop
        call MissileRecycler__ToggleIndexer(true)
        call TimerStart(MissileRecycler__gameTime, 1000000., false, null)
        set u=null
    endfunction

    function MissileRecycler__PreInit takes nothing returns nothing



            call MissileRecycler__Init()

    endfunction



    
    function GetUnitBodySize takes unit whichUnit returns real
        return 100. // Other example: return LoadReal(hash, GetHandleId(whichUnit), KEY_UNIT_BODY_SIZE)
    endfunction

    
    function GetDestructableHeight takes destructable d returns real
        return GetDestructableOccluderHeight(d) // Other example: return 100.
    endfunction

    
    function GetItemHeight takes item i returns real
        return 16.
    endfunction
    
    
    function Missile___ToogleUnitIndexer takes boolean enable returns boolean
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
        call MoveLocation(Missile___LOC, x, y)
        return GetLocationZ(Missile___LOC)
    endfunction
    
    // For WRITE_DELAYED_MISSILE_RECYCLING = true Missile will hold back
    // dummies for DELAYED_MISSILE_DEATH_ANIMATION_TIME before they are recylced. ( Code placed in a static if )
    //
//textmacro instance: WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")


     
            function s__Missile___RecycleBin_onPeriodic takes nothing returns nothing
                local integer dex= 0
                loop
                    exitwhen dex == s__Missile___RecycleBin_max
                    set s__Missile___RecycleBin_time[dex]=s__Missile___RecycleBin_time[dex] - 1
                    if 0 >= s__Missile___RecycleBin_time[dex] then
                    

                            call RecycleMissile(s__Missile___RecycleBin_dummy[dex])
                    









                    
                        set s__Missile___RecycleBin_dummy[dex]=null
                        set s__Missile___RecycleBin_max=s__Missile___RecycleBin_max - 1
                        set s__Missile___RecycleBin_dummy[dex]=s__Missile___RecycleBin_dummy[s__Missile___RecycleBin_max]
                        set s__Missile___RecycleBin_time[dex]=s__Missile___RecycleBin_time[s__Missile___RecycleBin_max]
                        set s__Missile___RecycleBin_dummy[s__Missile___RecycleBin_max]=null
                        set dex=dex - 1
                    
                        if 0 == s__Missile___RecycleBin_max then
                            call PauseTimer(s__Missile___RecycleBin_t)
                        endif
                    
                    endif
                    set dex=dex + 1
                endloop
            endfunction
    
            function s__Missile___RecycleBin_recycle takes unit toRecycle returns nothing
                if 0 == s__Missile___RecycleBin_max then
                    call TimerStart(s__Missile___RecycleBin_t, 1., true, function s__Missile___RecycleBin_onPeriodic)
                endif
                set s__Missile___RecycleBin_dummy[s__Missile___RecycleBin_max]=toRecycle
                set s__Missile___RecycleBin_time[s__Missile___RecycleBin_max]=Missile___DELAYED_MISSILE_DEATH_ANIMATION_TIME + TimerGetRemaining(s__Missile___RecycleBin_t)

                    // The existing bin advances in whole seconds; allow its next tick.
                    call s__MissileStats_delay(toRecycle , Missile___DELAYED_MISSILE_DEATH_ANIMATION_TIME + 1.)

                set s__Missile___RecycleBin_max=s__Missile___RecycleBin_max + 1
            endfunction
    

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
//Implemented from module Missile___MissileStructure:
        

// NO_DEBUG:             debug private boolean isNode
// NO_DEBUG:             debug private boolean isCollection

        
        function s__Missile__get_list takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,    "MissileStructure", "list", "thistype", this, "Attempted To Read Null Node.")
// NO_DEBUG:                 debug call ThrowError(not isNode,   "MissileStructure", "list", "thistype", this, "Attempted To Read Invalid Node.")

            return s__Missile_Missile___MissileStructure____list[this]
        endfunction
        
        function s__Missile__get_next takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,    "MissileStructure", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
// NO_DEBUG:                 debug call ThrowError(not isNode,   "MissileStructure", "next", "thistype", this, "Attempted To Read Invalid Node.")

            return s__Missile_Missile___MissileStructure____next[this]
        endfunction
        
        function s__Missile__get_prev takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,    "MissileStructure", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
// NO_DEBUG:                 debug call ThrowError(not isNode,   "MissileStructure", "prev", "thistype", this, "Attempted To Read Invalid Node.")

            return s__Missile_Missile___MissileStructure____prev[this]
        endfunction
        
        function s__Missile__get_first takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,        "MissileStructure", "first", "thistype", this, "Attempted To Read Null List.")
// NO_DEBUG:                 debug call ThrowError(not isCollection, "MissileStructure", "first", "thistype", this, "Attempted To Read Invalid List.")

            return s__Missile_Missile___MissileStructure____first[this]
        endfunction
        
        function s__Missile__get_last takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,        "MissileStructure", "last", "thistype", this, "Attempted To Read Null List.")
// NO_DEBUG:                 debug call ThrowError(not isCollection, "MissileStructure", "last", "thistype", this, "Attempted To Read Invalid List.")

            return s__Missile_Missile___MissileStructure____last[this]
        endfunction
        
        function s__Missile_allocateCollection takes nothing returns integer
            local integer this= s__Missile_Missile___MissileStructure____first[(0)]
            
            if ( 0 == this ) then

// NO_DEBUG:                     debug call ThrowError(collectionCount == 8191, "MissileStructure", "allocateCollection", "thistype", 0, "Overflow.")

                
                set this=s__Missile_Missile___MissileStructure___collectionCount + 1
                set s__Missile_Missile___MissileStructure___collectionCount=this
            else
                set s__Missile_Missile___MissileStructure____first[(0)]=s__Missile_Missile___MissileStructure____first[this]
            endif
            

// NO_DEBUG:                 debug set isCollection = true

            
            set s__Missile_Missile___MissileStructure____first[this]=0
            
            return this
        endfunction
        
        function s__Missile_allocateNode takes nothing returns integer
            local integer this= s__Missile_Missile___MissileStructure____next[(0)]
            
            if ( 0 == this ) then

// NO_DEBUG:                     debug call ThrowError(nodeCount == 8191, "MissileStructure", "allocateNode", "thistype", 0, "Overflow.")

                
                set this=s__Missile_Missile___MissileStructure___nodeCount + 1
                set s__Missile_Missile___MissileStructure___nodeCount=this
            else
                set s__Missile_Missile___MissileStructure____next[(0)]=s__Missile_Missile___MissileStructure____next[this]
            endif
            
            set s__Missile_allocated[this]=true
            
            return this
        endfunction
        
        function s__Missile_insertFront takes integer this,integer node returns integer
            
            // Extra static unique list for missile motion.
            set Missile___nextNode[node]=0
            set Missile___prevNode[node]=Missile___prevNode[0]
            set Missile___nextNode[Missile___prevNode[0]]=node
            set Missile___prevNode[0]=node
            

// NO_DEBUG:                 debug call ThrowError(this == 0,        "List", "push", "thistype", this, "Attempted To Push On To Null List.")
// NO_DEBUG:                 debug call ThrowError(not isCollection, "List", "push", "thistype", this, "Attempted To Push On To Invalid List.")
// NO_DEBUG:                 debug set node.isNode = true

            
            set s__Missile_Missile___MissileStructure____list[node]=this
        
            if ( s__Missile_Missile___MissileStructure____first[this] == 0 ) then
                set s__Missile_Missile___MissileStructure____first[this]=node
                set s__Missile_Missile___MissileStructure____last[this]=node
                set s__Missile_Missile___MissileStructure____next[node]=0
            else
                set s__Missile_Missile___MissileStructure____prev[s__Missile_Missile___MissileStructure____first[this]]=node
                set s__Missile_Missile___MissileStructure____next[node]=s__Missile_Missile___MissileStructure____first[this]
                set s__Missile_Missile___MissileStructure____first[this]=node
            endif
            
            set s__Missile_Missile___MissileStructure____prev[node]=0
            
            return node
        endfunction
      
        function s__Missile_Missile___remove takes integer this returns nothing
            local integer node= this
            set this=s__Missile_Missile___MissileStructure____list[node]
            

// NO_DEBUG:                 debug call ThrowError(node == 0,        "MissileStructure", "remove", "thistype", this, "Attempted To Remove Null Node.")
// NO_DEBUG:                 debug call ThrowError(not node.isNode,  "MissileStructure", "remove", "thistype", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
// NO_DEBUG:                 debug set node.isNode = false

            
            set s__Missile_Missile___MissileStructure____list[node]=0
        
            if ( 0 == s__Missile_Missile___MissileStructure____prev[node] ) then
                set s__Missile_Missile___MissileStructure____first[this]=s__Missile_Missile___MissileStructure____next[node]
            else
                set s__Missile_Missile___MissileStructure____next[s__Missile_Missile___MissileStructure____prev[node]]=s__Missile_Missile___MissileStructure____next[node]
            endif
            if ( 0 == s__Missile_Missile___MissileStructure____next[node] ) then
                set s__Missile_Missile___MissileStructure____last[this]=s__Missile_Missile___MissileStructure____prev[node]
            else
                set s__Missile_Missile___MissileStructure____prev[s__Missile_Missile___MissileStructure____next[node]]=s__Missile_Missile___MissileStructure____prev[node]
            endif
            
            set s__Missile_Missile___MissileStructure____next[node]=s__Missile_Missile___MissileStructure____next[(0)]
            set s__Missile_Missile___MissileStructure____next[(0)]=node
            
            set s__Missile_allocated[node]=false
            
            // Static unique list for missile motion.
            set Missile___nextNode[Missile___prevNode[node]]=Missile___nextNode[node]
            set Missile___prevNode[Missile___nextNode[node]]=Missile___prevNode[node]
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
// NO_DEBUG:         debug boolean launched 
// NO_DEBUG: 
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

                    call s__MissileStats_released(this)

                call s__Missile_Missile___remove(this)
                call s__MissilePosition_destroy(s__Missile_impact[this])
                call s__MissilePosition_destroy(s__Missile_origin[this])
            
                call DestroyEffect(s__Missile_sfx[this])
                call FlushChildHashtable(Missile___HASH, this)
                if GetUnitTypeId(s__Missile_dummy[this]) == Missile_DUMMY_UNIT_ID then
                    // MissileRecycler > Dummy > xe.

                        call RecycleMissile(s__Missile_dummy[this])







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
            call SaveUnitHandle(Missile___HASH, this, GetHandleId(missileDummy), missileDummy)
            //

// NO_DEBUG:                 debug call ThrowWarning(GetUnitTypeId(missileDummy) == 0, "Missile", "createEx", "missileDummy", this, "Invalid missile dummy unit ( null )!")

// NO_DEBUG:             debug set launched = false

                call s__MissileStats_allocated(this)

            return this
        endfunction
    
        // Freaky static if ensures these libraries really don't exist.













    
        // MissileRecylcer > Dummy > xe > Missile.
    
        // Wrapper to createEx.
        function s__Missile_create takes real x,real y,real z,real angle,real distance,real impactZ returns integer
            local real impactX= x + distance * Cos(angle)
            local real impactY= y + distance * Sin(angle)
            // Get the dummy unit.
//textmacro instance: MISSILE_GET_DUMMY_FROM_LIBRARY()

                return s__Missile_createEx(GetRecycledMissile(x , y , z , angle * bj_RADTODEG) , impactX , impactY , impactZ)
        













//end of: MISSILE_GET_DUMMY_FROM_LIBRARY()
        endfunction
        
        // Wrapper to createEx.
        function s__Missile_createXYZ takes real x,real y,real z,real impactX,real impactY,real impactZ returns integer
            local real angle= Atan2(impactY - y, impactX - x)
            // Get the dummy unit.
//textmacro instance: MISSILE_GET_DUMMY_FROM_LIBRARY()

                return s__Missile_createEx(GetRecycledMissile(x , y , z , angle * bj_RADTODEG) , impactX , impactY , impactZ)
        













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
                call MoveLocation(Missile___LOC, newX, newY)
                set s__Missile_terrainZ[this]=GetLocationZ(Missile___LOC)
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






                    if newX < s__WorldBounds_maxX and newX > s__WorldBounds_minX and newY < s__WorldBounds_maxY and newY > s__WorldBounds_minY then
                        call SetUnitX(u, newX)
                        call SetUnitY(u, newY)
                    endif




                
                set loops=loops + 1
                set this=Missile___nextNode[this]
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
                call SaveWidgetHandle(Missile___HASH, this, GetHandleId(w), w)
            endif
        endfunction
        
        // All widget which have been hit return true.
        function s__Missile_hasHitWidget takes integer this,widget w returns boolean
            return HaveSavedHandle(Missile___HASH, this, GetHandleId(w))
        endfunction
        
        // Removes a widget from the missile's memory of hit widgets. ( This widget can be hit again )
        function s__Missile_removeHitWidget takes integer this,widget w returns nothing
            if w != null then
                call RemoveSavedHandle(Missile___HASH, this, GetHandleId(w))
            endif
        endfunction
        
        // Flushes a missile's memory for collision. ( All widgets can be hit again )
        function s__Missile_flushHitWidgets takes integer this returns nothing
            call FlushChildHashtable(Missile___HASH, this)
            call s__Missile_hitWidget(this,s__Missile_dummy[this])
        endfunction
        
        // Tells missile to call removeHitWidget(w) after "seconds" time.
        // Does not apply to widgets, which are already hit by this missile.
        function s__Missile_enableHitAfter takes integer this,widget w,real seconds returns nothing
            local integer id= GetHandleId(w)
            if w != null then
                if not HaveSavedInteger(Missile___HASH, this, id) then
                    call SaveInteger(Missile___HASH, this, id, s__Missile_stackSize[this])
                    call SaveInteger(Missile___HASH, this, s__Missile_stackSize[this], id)
                    set s__Missile_stackSize[this]=s__Missile_stackSize[this] + 1
                endif
                call SaveReal(Missile___HASH, this, id, seconds) // Set time.
            endif
        endfunction
        
        function s__Missile_updateStack takes integer this returns nothing
            local integer dex= 0
            local integer id
            local real time
            loop
                exitwhen dex == s__Missile_stackSize[this]
                set id=LoadInteger(Missile___HASH, this, dex)
                set time=LoadReal(Missile___HASH, this, id) - Missile_TIMER_TIMEOUT
                if time <= 0. or not HaveSavedHandle(Missile___HASH, this, id) then
                    set s__Missile_stackSize[this]=s__Missile_stackSize[this] - 1
                    set id=LoadInteger(Missile___HASH, this, s__Missile_stackSize[this])
                    call SaveInteger(Missile___HASH, this, dex, id)
                    call SaveInteger(Missile___HASH, this, id, dex)
                    // Enables hit.
                    call RemoveSavedHandle(Missile___HASH, this, id)
                    // Remove data from stack.
                    call RemoveSavedReal(Missile___HASH, this, id)
                    call RemoveSavedInteger(Missile___HASH, this, id)
                    call RemoveSavedInteger(Missile___HASH, this, s__Missile_stackSize[this])
                else
                    call SaveReal(Missile___HASH, this, id, time)
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
            if not HaveSavedHandle(Missile___HASH, s__Missile_temp, GetHandleId(d)) then
                if s__Missile_circle then
                    set b=s__Missile_isWidgetInRange(s__Missile_temp,d , (GetDestructableOccluderHeight((d))) , s__Missile_collision[s__Missile_temp]) // INLINED!!
                else
                    set b=s__Missile_isWidgetInRectangle(s__Missile_temp,d , (GetDestructableOccluderHeight((d))) , s__Missile_collision[s__Missile_temp]) // INLINED!!
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
            if not HaveSavedHandle(Missile___HASH, s__Missile_temp, GetHandleId(i)) then
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
            
            if not HaveSavedHandle(Missile___HASH, this, GetHandleId(u)) then
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
                    call SetRect(Missile___RECT, x1 - d, y1 - d, x2 + d, y2 + d)
                else
                    call SetRect(Missile___RECT, x1 - d, y2 - d, x2 + d, y1 + d)
                endif
            elseif y1 < y2 then
                call SetRect(Missile___RECT, x2 - d, y1 - d, x1 + d, y2 + d)
            else
                call SetRect(Missile___RECT, x2 - d, y2 - d, x1 + d, y1 + d)
            endif
        endfunction
        //
        // For circular.
        function s__Missile_prepareRectCircle takes integer this returns nothing
            local real d= s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE
            call SetRect(Missile___RECT, s__Missile_x[this] - d, s__Missile_y[this] - d, s__Missile_x[this] + d, s__Missile_y[this] + d)
        endfunction
        //
        // 5.) API for the MissileStruct iteration.
        //
        function s__Missile_groupEnumUnitsRectangle takes integer this returns nothing
            call s__Missile_prepareRectRectangle(this)
            set s__Missile_temp=this
            call GroupEnumUnitsInRect(Missile___GROUP, Missile___RECT, Missile___unitFilter)
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
            call EnumDestructablesInRect(Missile___RECT, Missile___destFilter, func)
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
            call EnumItemsInRect(Missile___RECT, Missile___itemFilter, func)
        endfunction


    function s__Missile_nullBefore takes integer this returns nothing
        set s__Missile_dummy[this]=null
    endfunction


// Does not check for 'Aloc' and 'Amrf' as they could be customized.
        function s__Missile_onInit takes nothing returns nothing

// NO_DEBUG:                 debug local boolean prev = Missile___ToogleUnitIndexer(false)
// NO_DEBUG:                 debug local unit dummy = CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, 0., 0., 0.)
// NO_DEBUG:                 debug call Missile___ToogleUnitIndexer(prev)
                //
// NO_DEBUG:                 debug call ThrowError((GetUnitTypeId(dummy) != Missile_DUMMY_UNIT_ID), "Missile", "DEBUG_MISSILE", "type id",    0, "Global setup for public integer DUMMY_UNIT_ID is incorrect! This map currently can't use Missile!")
// NO_DEBUG:                 debug call ThrowError((Missile_MAXIMUM_COLLISION_SIZE < 0),            "Missile", "DEBUG_MISSILE", "collision",  0, "Global setup for public real MAXIMUM_COLLISION_SIZE is incorrect, below zero! This map currently can't use Missile!")
// NO_DEBUG:                 debug call RemoveUnit(dummy)
// NO_DEBUG:                 debug set dummy = null

            //
            set Missile___unitFilter=Filter(function s__Missile_filterUnits)
            set Missile___destFilter=Filter(function s__Missile_filterDests)
            set Missile___itemFilter=Filter(function s__Missile_filterItems)
            call TriggerAddCondition(Missile___MOVE, Condition(function s__Missile_move))
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
    function Missile___MissileCreateExpression takes integer structId,code func returns nothing
        set Missile___expression[structId]=Condition(func)
    endfunction
    
    // Creates a collection for a struct. ( Runs for all struct using module MissileStruct )
    function Missile___MissileCreateCollection takes integer structId returns nothing
        set Missile___missileList[structId]=s__Missile_allocateCollection()
    endfunction
    
    // Core:
    // =====
    //
    // Fires every Missile_TIMER_TIMEOUT.
    function Missile___Fire takes nothing returns nothing
        local integer i= Missile___remove[0]
        set Missile___remove[0]=0
        loop
            exitwhen 0 == i
            if Missile___recycling[i] then
                call TriggerRemoveCondition(Missile___CORE, Missile___condition[i])
                set Missile___condition[i]=null
                set Missile___active=Missile___active - 1
            endif
            set Missile___destroying[i]=false
            set Missile___recycling[i]=false
            set i=Missile___remove[i]
        endloop
        
        if 0 == Missile___active then
            call PauseTimer(Missile___TMR)
        else
            // Move all launched missiles.
            set s__Missile_temp=Missile___nextNode[0]
            set i=0
            loop
                exitwhen TriggerEvaluate(Missile___MOVE)
                exitwhen i == 60 // Moved over 8910 missiles, something buggy happened.
                set i=i + 1 // This case is impossible, hence never happens. But if I'm wrong, which also never happens 
            endloop // then the map 100% crashes. i == 66 will prevent the game crash and Missile will start to 
                                // to debug itself over the next iterations.
        
            // Access all structs using module MissileStruct. 





                call TriggerEvaluate(Missile___CORE)

        endif
    endfunction
    
    // Conditionally starts the timer.
    function Missile___StartPeriodic takes integer structId returns nothing
        if 0 == Missile___instances[structId] or Missile___destroying[structId] then
            if Missile___destroying[structId] then
                set Missile___recycling[structId]=false
            else
                if 0 == Missile___active then
                    call TimerStart(Missile___TMR, Missile_TIMER_TIMEOUT, true, function Missile___Fire)
                endif
                set Missile___active=Missile___active + 1
                set Missile___condition[structId]=TriggerAddCondition(Missile___CORE, Missile___expression[structId])
            endif
        endif
        set Missile___instances[structId]=Missile___instances[structId] + 1
    endfunction
    
    // Conditionally stops the timer in the next callback.
    function Missile___StopPeriodic takes integer structId returns nothing
        set Missile___instances[structId]=Missile___instances[structId] - 1
        if 0 == Missile___instances[structId] and Missile___condition[structId] != null then
            if not Missile___destroying[structId] and not Missile___recycling[structId] then
                set Missile___destroying[structId]=true
                set Missile___recycling[structId]=true
                set Missile___remove[structId]=Missile___remove[0]
                set Missile___remove[0]=structId
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

    // Collision stays independent of the decorative trail and death flash.
    // Stand body width is 11.664 model units in all twelve unmodified variants.
    // Calibrated in game against the radius16 marker; glow/trail are decorative.

    function s__RapidBolt_resolve takes integer m returns boolean
        local integer result= s__GroundCollision_trace(s__Missile_prevX[m] , s__Missile_prevY[m] , s__Missile_x[m] , s__Missile_y[m] , s__RapidBolt_HIT_RADIUS , s__RapidBolt_source[m] , s__RapidBolt_owner[m] , true)
        local unit target= s__GroundCollision_hit
        local unit caster= s__RapidBolt_source[m]
        if result == 2 then
            set s__RapidBolt_hits=s__RapidBolt_hits + 1
            if GetUnitTypeId(caster) != 0 then
                call UnitDamageTarget(caster, target, 25., false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif
        elseif result == 1 or s__Missile_z[m] < 0. then
            set s__RapidBolt_walls=s__RapidBolt_walls + 1
            set result=1
        endif
        set target=null
        set caster=null
        return result != 0
    endfunction
    function s__RapidBolt_onPeriod takes integer m returns boolean
        return s__RapidBolt_resolve(m)
    endfunction
    function s__RapidBolt_onFinish takes integer m returns boolean
        call s__RapidBolt_resolve(m)
        return true
    endfunction
    function s__RapidBolt_onRemove takes integer m returns boolean
        set s__RapidBolt_source[m]=null
        set s__RapidBolt_owner[m]=null
        set s__RapidBolt_live=s__RapidBolt_live - 1
        return false
    endfunction
//Implemented from module MissileStruct:
        function s__RapidBolt_launch takes integer missile returns nothing

// NO_DEBUG:                 debug call ThrowError(missile.launched, "thistype", "launch", "missile.launched", missile, "This missile was already launched before!")

// NO_DEBUG:             debug set missile.launched = true
            //
            call s__Missile_insertFront(Missile___missileList[si__RapidBolt],missile)
            call Missile___StartPeriodic(si__RapidBolt)
        endfunction
        // Called from missileIterate. "P" to avoid code collision.
        function s__RapidBolt_missileTerminateP takes integer node returns nothing
            if s__Missile_allocated[node] then


                        if s__RapidBolt_onRemove(node) and GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID then
                            call s__Missile___RecycleBin_recycle(s__Missile_dummy[node])
                            set s__Missile_dummy[(node)]=null // INLINED!!
                        endif




            
                call s__Missile_terminate(node)
                call Missile___StopPeriodic(si__RapidBolt)
            endif
        endfunction
























        













    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__RapidBolt_missileIterateP takes nothing returns boolean
            local integer this= (s__Missile_Missile___MissileStructure____first[(Missile___missileList[si__RapidBolt])]) // INLINED!!
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            loop
                exitwhen 0 == this
                set node=(s__Missile_Missile___MissileStructure____next[(this)]) // The linked list should not lose the next node. // INLINED!!
               
                if s__Missile_wantDestroy[this] then
                    call s__RapidBolt_missileTerminateP(this)
                else
                    if s__Missile_stackSize[this] > 0 then
                        call s__Missile_updateStack(this)
                    endif
                    
                    // Runs unit collision.







































                    
                    // Runs destructable collision.






                    
                    // Runs item collision.






                
                    // Runs when the destination is reached.
                    if s__Missile_recycle[this] and s__Missile_allocated[this] then

                            if s__RapidBolt_onFinish(this) then
                                call s__RapidBolt_missileTerminateP(this)
                            endif



                    endif
                
                    // Runs on terrian collision.





                
                    // Runs every Missile_TIMER_TIMEOUT.

                        if s__Missile_allocated[this] and (s__RapidBolt_resolve((this))) then // INLINED!!
                            call s__RapidBolt_missileTerminateP(this)
                        endif

                endif
                set this=node
            endloop
            
            set u=null



                return false

        endfunction
        
        function s__RapidBolt_MissileStruct___onInit takes nothing returns nothing
            set Missile___missileList[(si__RapidBolt)]=s__Missile_allocateCollection() // INLINED!!
            set Missile___expression[(si__RapidBolt )]=Condition(( function s__RapidBolt_missileIterateP)) // INLINED!!
        endfunction

    function s__RapidBolt_modelForColor takes playercolor value returns string
        if value == PLAYER_COLOR_RED then
            return "ShotsTeam\\Shot_00_Red.mdx"
        elseif value == PLAYER_COLOR_BLUE then
            return "ShotsTeam\\Shot_01_Blue.mdx"
        elseif value == PLAYER_COLOR_CYAN then
            return "ShotsTeam\\Shot_02_Cyan.mdx"
        elseif value == PLAYER_COLOR_PURPLE then
            return "ShotsTeam\\Shot_03_Purple.mdx"
        elseif value == PLAYER_COLOR_YELLOW then
            return "ShotsTeam\\Shot_04_Yellow.mdx"
        elseif value == PLAYER_COLOR_ORANGE then
            return "ShotsTeam\\Shot_05_Orange.mdx"
        elseif value == PLAYER_COLOR_GREEN then
            return "ShotsTeam\\Shot_06_Green.mdx"
        elseif value == PLAYER_COLOR_PINK then
            return "ShotsTeam\\Shot_07_Pink.mdx"
        elseif value == PLAYER_COLOR_LIGHT_BLUE then
            return "ShotsTeam\\Shot_09_LightBlue.mdx"
        elseif value == PLAYER_COLOR_AQUA then
            return "ShotsTeam\\Shot_10_Aqua.mdx"
        elseif value == PLAYER_COLOR_BROWN then
            return "ShotsTeam\\Shot_11_Brown.mdx"
        endif
        // Light gray also covers neutral/unknown colors outside the Classic 12.
        return "ShotsTeam\\Shot_08_LightGray.mdx"
    endfunction

    function s__RapidBolt_shootColor takes unit caster,real px,real py,playercolor color returns integer
        local real x= GetUnitX(caster)
        local real y= GetUnitY(caster)
        local real dx= px - x
        local real dy= py - y
        local real distance= SquareRoot(dx * dx + dy * dy)
        local real angle
        local real length
        local integer m
        if distance < 8. then
            set angle=GetUnitFacing(caster) * bj_DEGTORAD
            set distance=600.
            set dx=distance * Cos(angle)
            set dy=distance * Sin(angle)
        endif
        set length=RMinBJ(distance, 1000.)
        set px=x + dx * length / distance
        set py=y + dy * length / distance
        call s__GroundCollision_trace(x , y , x + dx * 24. / distance , y + dy * 24. / distance , s__RapidBolt_HIT_RADIUS , caster , GetOwningPlayer(caster) , false)
        set m=s__Missile_createXYZ(s__GroundCollision_x , s__GroundCollision_y , 70. , px , py , 70.)
        set s__RapidBolt_source[m]=caster
        set s__RapidBolt_owner[m]=GetOwningPlayer(caster)
        set s__Missile_owner[m]=s__RapidBolt_owner[m]
        // Ability-specific swept collision chooses obstacles before damage;
        // it does not change the common module's callback ordering.
        set s__Missile_collision[m]=0.
        call s__Missile__set_model(m,s__RapidBolt_modelForColor(color))
        call s__Missile__set_scale(m,s__RapidBolt_VISUAL_SCALE)
        set s__Missile_speed[(m)]=((1200.)*1.0) * Missile_TIMER_TIMEOUT // INLINED!!
        set s__RapidBolt_live=s__RapidBolt_live + 1
        call s__RapidBolt_launch(m)
        return m
    endfunction
    // Existing consumers keep the same API and take the owner's current color.
    function s__RapidBolt_shoot takes unit caster,real px,real py returns integer
        return s__RapidBolt_shootColor(caster , px , py , GetPlayerColor(GetOwningPlayer(caster)))
    endfunction


    function s__RapidPair_now takes nothing returns real
        return TimerGetElapsed(s__RapidPair_clock)
    endfunction
    function s__RapidPair_fromController takes unit u returns integer
        return (LoadInteger(Table__ht, (s__RapidPair_controls), (GetHandleId(u)))) // INLINED!!
    endfunction
    function s__RapidPair_fromActor takes unit u returns integer
        return (LoadInteger(Table__ht, (s__RapidPair_actors), (GetHandleId(u)))) // INLINED!!
    endfunction
    function s__RapidPair_color takes integer this returns playercolor
        if s__RapidPair_hasTint[this] then
            return s__RapidPair_tint[this]
        endif
        return GetPlayerColor(GetOwningPlayer(s__RapidPair_actor[this]))
    endfunction
    // Classic has no GetUnitColor. Use this setter for individual/team overrides.
    // Red is enum0 (equal to null in Classic), so absence is a separate flag.
    function s__RapidPair_setColor takes integer this,playercolor value returns nothing
        set s__RapidPair_tint[this]=value
        set s__RapidPair_hasTint[this]=true
        call SetUnitColor(s__RapidPair_actor[this], s__RapidPair_color(this))
        call SetUnitColor(s__RapidPair_controller[this], s__RapidPair_color(this))
    endfunction
    function s__RapidPair_clearColor takes integer this returns nothing
        set s__RapidPair_hasTint[this]=false
        set s__RapidPair_tint[this]=null
        call SetUnitColor(s__RapidPair_actor[this], s__RapidPair_color(this))
        call SetUnitColor(s__RapidPair_controller[this], s__RapidPair_color(this))
    endfunction
    function s__RapidPair_face takes integer this returns nothing
        local real dx= s__RapidPair_aimX[this] - GetUnitX(s__RapidPair_actor[this])
        local real dy= s__RapidPair_aimY[this] - GetUnitY(s__RapidPair_actor[this])
        if dx * dx + dy * dy > 0.01 then
            call SetUnitFacingTimed(s__RapidPair_actor[this], Atan2(dy, dx) * bj_RADTODEG, 0.)
        endif
    endfunction
    function s__RapidPair_emit takes integer this returns nothing
        local real gap= (TimerGetElapsed(s__RapidPair_clock)) - s__RapidPair_lastShot[this] // INLINED!!
        if s__RapidPair_lastShot[this] > - 1. and gap < s__RapidPair_minInterval then
            set s__RapidPair_minInterval=gap
        endif
        set s__RapidPair_lastShot[this]=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
        set s__RapidPair_pending[this]=s__RapidPair_pending[this] - 1
        set s__RapidPair_remaining=s__RapidPair_remaining - 1
        set s__RapidPair_emitted=s__RapidPair_emitted + 1
        call s__RapidPair_face(this)
        call SetUnitAnimation(s__RapidPair_actor[this], "attack")
        set s__RapidPair_attacks=s__RapidPair_attacks + 1
        set s__RapidPair_lastMissile[this]=s__RapidBolt_shootColor(s__RapidPair_actor[this] , s__RapidPair_aimX[this] , s__RapidPair_aimY[this] , s__RapidPair_color(this))
    endfunction
    function s__RapidPair_cast takes integer this,real px,real py returns nothing
        if not s__GroundCollision_alive(s__RapidPair_actor[this]) then
            return
        endif
        set s__RapidPair_aimX[this]=px
        set s__RapidPair_aimY[this]=py
        if s__RapidPair_firing[this] then
            set s__RapidPair_remaining=s__RapidPair_remaining + 6 - s__RapidPair_pending[this]
            set s__RapidPair_pending[this]=6
            set s__RapidPair_recasts=s__RapidPair_recasts + 1
            return
        endif
        set s__RapidPair_firing[this]=true
        set s__RapidPair_bursts=s__RapidPair_bursts + 1
        set s__RapidPair_pending[this]=6
        set s__RapidPair_remaining=s__RapidPair_remaining + 6
        // Initial instant transition, if needed, precedes the first attack.
        call s__GroundMotion_enter(s__RapidPair_motion[this])
        call SetUnitTimeScale(s__RapidPair_actor[this], 3.)
        set s__RapidPair_nextShot[this]=(TimerGetElapsed(s__RapidPair_clock)) + s__RapidPair_INTERVAL // INLINED!!
        call s__RapidPair_emit(this)
    endfunction
    function s__RapidPair_finish takes integer this,boolean resume returns nothing
        if s__RapidPair_firing[this] then
            set s__RapidPair_firing[this]=false
            set s__RapidPair_bursts=s__RapidPair_bursts - 1
            set s__RapidPair_remaining=s__RapidPair_remaining - s__RapidPair_pending[this]
            set s__RapidPair_pending[this]=0
            if GetUnitTypeId(s__RapidPair_actor[this]) != 0 then
                call SetUnitTimeScale(s__RapidPair_actor[this], 1.)
                call ResetUnitAnimation(s__RapidPair_actor[this])
            endif
            call s__GroundMotion_leave(s__RapidPair_motion[this],resume)
        endif
    endfunction
    function s__RapidPair_park takes nothing returns nothing
        local integer this= (LoadInteger(TimerUtils___ht, 0, GetHandleId((GetExpiredTimer())))) // INLINED!!
        call SetUnitPosition(s__RapidPair_controller[this], s__WorldBounds_minX + 256., s__WorldBounds_minY + 256.)
    endfunction
    function s__RapidPair_move takes integer this,real px,real py returns nothing
        call s__GroundMotion_destination(s__RapidPair_motion[this],px , py)
    endfunction
    function s__RapidPair_create takes unit proxy,unit visible returns integer
        local integer this= s__RapidPair__allocate()
        set s__RapidPair_controller[this]=proxy
        set s__RapidPair_actor[this]=visible
        set s__RapidPair_firing[this]=false
        set s__RapidPair_pending[this]=0
        set s__RapidPair_lastShot[this]=- 1000.
        set s__RapidPair_lastMissile[this]=0
        set s__RapidPair_tint[this]=null
        set s__RapidPair_hasTint[this]=false
        set s__RapidPair_aimX[this]=GetUnitX(visible) + 500.
        set s__RapidPair_aimY[this]=GetUnitY(visible)
        set s__RapidPair_reset[this]=NewTimerEx(this)
        set s__RapidPair_motion[this]=s__GroundMotion_create(visible)
        call SaveInteger(Table__ht, (s__RapidPair_controls), (GetHandleId(proxy)), ( this)) // INLINED!!
        call SaveInteger(Table__ht, (s__RapidPair_actors), (GetHandleId(visible)), ( this)) // INLINED!!
        set s__RapidPair_previous[this]=0
        set s__RapidPair_next[this]=s__RapidPair_first
        if s__RapidPair_first != 0 then
            set s__RapidPair_previous[(s__RapidPair_first)]=this
        endif
        set s__RapidPair_first=this
        set s__RapidPair_pairs=s__RapidPair_pairs + 1
        return this
    endfunction
    function s__RapidPair_destroy takes integer this returns nothing
        call s__RapidPair_finish(this,false)
        call s__GroundMotion_destroy(s__RapidPair_motion[this])
        call RemoveSavedInteger(Table__ht, (s__RapidPair_controls), (GetHandleId(s__RapidPair_controller[this]))) // INLINED!!
        call RemoveSavedInteger(Table__ht, (s__RapidPair_actors), (GetHandleId(s__RapidPair_actor[this]))) // INLINED!!
        call ReleaseTimer(s__RapidPair_reset[this])
        call RemoveUnit(s__RapidPair_controller[this])
        if s__RapidPair_previous[this] == 0 then
            set s__RapidPair_first=s__RapidPair_next[this]
        else
            set s__RapidPair_next[(s__RapidPair_previous[this])]=s__RapidPair_next[this]
        endif
        if s__RapidPair_next[this] != 0 then
            set s__RapidPair_previous[(s__RapidPair_next[this])]=s__RapidPair_previous[this]
        endif
        set s__RapidPair_controller[this]=null
        set s__RapidPair_actor[this]=null
        set s__RapidPair_reset[this]=null
        set s__RapidPair_tint[this]=null
        set s__RapidPair_hasTint[this]=false
        set s__RapidPair_pairs=s__RapidPair_pairs - 1
        call s__RapidPair_deallocate(this)
    endfunction
    function s__RapidPair_tick takes nothing returns nothing
        local integer this= s__RapidPair_first
        local integer following
        local real time= (TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
        set s__RapidPair_moving=0
        set s__RapidPair_blocked=0
        loop
            exitwhen this == 0
            set following=s__RapidPair_next[this]
            if not s__GroundCollision_alive(s__RapidPair_actor[this]) or not s__GroundCollision_alive(s__RapidPair_controller[this]) then
                call s__RapidPair_destroy(this)
            else
                call SetWidgetLife(s__RapidPair_controller[this], GetWidgetLife(s__RapidPair_actor[this]))
                if s__RapidPair_firing[this] then
                    call s__GroundMotion_step(s__RapidPair_motion[this],1. / 32.)
                    call s__RapidPair_face(this)
                    if time + 0.0001 >= s__RapidPair_nextShot[this] then
                        if s__RapidPair_pending[this] > 0 then
                            call s__RapidPair_emit(this)
                            set s__RapidPair_nextShot[this]=s__RapidPair_nextShot[this] + s__RapidPair_INTERVAL
                        else
                            call s__RapidPair_finish(this,true)
                        endif
                    endif
                    if s__GroundMotion_hasGoal[s__RapidPair_motion[this]] then
                        set s__RapidPair_moving=s__RapidPair_moving + 1
                    endif
                    if s__GroundMotion_blocked[s__RapidPair_motion[this]] then
                        set s__RapidPair_blocked=s__RapidPair_blocked + 1
                    endif
                endif
            endif
            set this=following
        endloop
    endfunction
    function s__RapidPair_pointOrder takes nothing returns nothing
        local integer this= (LoadInteger(Table__ht, (s__RapidPair_controls), (GetHandleId((GetTriggerUnit()))))) // INLINED!!
        local integer order= GetIssuedOrderId()
        if this != 0 then
            // A new cast must not be cancelled by a queued proxy move reset.
            call PauseTimer(s__RapidPair_reset[this])
            if order == 851986 or order == 851971 then
                call s__GroundMotion_destination(s__RapidPair_motion[(this)],((GetOrderPointX() )*1.0) , (( GetOrderPointY())*1.0)) // INLINED!!
                call TimerStart(s__RapidPair_reset[this], 0., false, function s__RapidPair_park)
            endif
        endif
    endfunction
    function s__RapidPair_spell takes nothing returns nothing
        local integer this= (LoadInteger(Table__ht, (s__RapidPair_controls), (GetHandleId((GetTriggerUnit()))))) // INLINED!!
        if this != 0 then
            call s__RapidPair_cast(this,GetSpellTargetX() , GetSpellTargetY())
        endif
    endfunction
    function s__RapidPair_selected takes nothing returns nothing
        local integer this= (LoadInteger(Table__ht, (s__RapidPair_actors), (GetHandleId((GetTriggerUnit()))))) // INLINED!!
        if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
            // Selection only; all gameplay state is outside the local branch.
            call ClearSelection()
            call SelectUnit(s__RapidPair_controller[this], true)
        endif
    endfunction
    function s__RapidPair_initialize takes nothing returns nothing
        set s__RapidPair_controls=s__Table_create()
        set s__RapidPair_actors=s__Table_create()
        call TimerStart(s__RapidPair_clock, 1000000., false, null)
        call TimerStart(s__RapidPair_ticker, 1. / 32., true, function s__RapidPair_tick)
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER , function s__RapidPair_pointOrder)
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED , function s__RapidPair_selected)
        call RegisterSpellEffectEvent('Arpf' , function s__RapidPair_spell)
    endfunction
function RapidFire__Init takes nothing returns nothing
    call s__RapidPair_initialize()
endfunction


    function s__X3Buster__X3Flash_finish takes nothing returns nothing
        local timer t= GetExpiredTimer()
        local integer this= (LoadInteger(TimerUtils___ht, 0, GetHandleId((t)))) // INLINED!!
        call DestroyEffect(s__X3Buster__X3Flash_art[this])
        call RecycleMissile(s__X3Buster__X3Flash_dummy[this])
        set s__X3Buster__X3Flash_art[this]=null
        set s__X3Buster__X3Flash_dummy[this]=null
        set s__X3Buster__X3Flash_live=s__X3Buster__X3Flash_live - 1
        call ReleaseTimer(t)
        call s__X3Buster__X3Flash_deallocate(this)
        set t=null
    endfunction
    function s__X3Buster__X3Flash_play takes real x,real y,real z returns nothing
        local integer this= s__X3Buster__X3Flash__allocate()
        local timer t= NewTimerEx(this)
        set s__X3Buster__X3Flash_dummy[this]=GetRecycledMissile(x , y , z , 0.)
        set s__X3Buster__X3Flash_art[this]=AddSpecialEffectTarget("X3Buster\\X3_Flash_Union.mdx", s__X3Buster__X3Flash_dummy[this], "origin")
        set s__X3Buster__X3Flash_live=s__X3Buster__X3Flash_live + 1
        call TimerStart(t, 0.18, false, function s__X3Buster__X3Flash_finish)
        set t=null
    endfunction


    function s__X3Buster_now takes nothing returns real
        return TimerGetElapsed(s__X3Buster_clock)
    endfunction
    function s__X3Buster_flashCount takes nothing returns integer
        return s__X3Buster__X3Flash_live
    endfunction
    function s__X3Buster_available takes integer this,integer m returns boolean
        return m != 0 and s__Missile_allocated[m] and not s__Missile_wantDestroy[m] and s__Missile_data[m] == this
    endfunction
    function s__X3Buster_track takes integer this,integer m returns nothing
        set s__X3Buster_bodies[this]=s__X3Buster_bodies[this] + 1
        set s__X3Buster_projectiles=s__X3Buster_projectiles + 1
        set s__X3Buster_created=s__X3Buster_created + 1
    endfunction
    function s__X3Buster_untrack takes integer this,integer m returns nothing
        if s__X3Buster_green[this] == m then
            set s__X3Buster_green[this]=0
        elseif s__X3Buster_orange[this] == m then
            set s__X3Buster_orange[this]=0
        elseif s__X3Buster_pulse[this] == m then
            set s__X3Buster_pulse[this]=0
        elseif s__X3Buster_fused[this] == m then
            set s__X3Buster_fused[this]=0
        elseif s__X3Buster_sat1[this] == m then
            set s__X3Buster_sat1[this]=0
        elseif s__X3Buster_sat2[this] == m then
            set s__X3Buster_sat2[this]=0
        elseif s__X3Buster_sat3[this] == m then
            set s__X3Buster_sat3[this]=0
        elseif s__X3Buster_sat4[this] == m then
            set s__X3Buster_sat4[this]=0
        endif
        set s__X3Buster_bodies[this]=s__X3Buster_bodies[this] - 1
        set s__X3Buster_projectiles=s__X3Buster_projectiles - 1
        set s__X3Buster_retired=s__X3Buster_retired + 1
    endfunction
    // Marks only this cast's bodies. onRemove remains their sole cleanup owner.
    function s__X3Buster_cancel takes integer this returns nothing
        set s__X3Buster_waiting[this]=false
        set s__X3Buster_state[this]=3
        if s__X3Buster_available(this,s__X3Buster_green[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_green[this])]=true // INLINED!!
        endif
        if s__X3Buster_available(this,s__X3Buster_orange[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_orange[this])]=true // INLINED!!
        endif
        if s__X3Buster_available(this,s__X3Buster_pulse[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_pulse[this])]=true // INLINED!!
        endif
        if s__X3Buster_available(this,s__X3Buster_fused[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_fused[this])]=true // INLINED!!
        endif
        if s__X3Buster_available(this,s__X3Buster_sat1[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_sat1[this])]=true // INLINED!!
        endif
        if s__X3Buster_available(this,s__X3Buster_sat2[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_sat2[this])]=true // INLINED!!
        endif
        if s__X3Buster_available(this,s__X3Buster_sat3[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_sat3[this])]=true // INLINED!!
        endif
        if s__X3Buster_available(this,s__X3Buster_sat4[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_sat4[this])]=true // INLINED!!
        endif
    endfunction
    // Can also be called by a future manual second-release/charge controller.
    function s__X3Buster_releasePulse takes integer this returns boolean
        if not s__X3Buster_waiting[this] or s__X3Buster_state[this] != 1 then
            return false
        endif
        set s__X3Buster_waiting[this]=false
        if not s__GroundCollision_alive(s__X3Buster_caster[this]) then
            return false
        endif
        set s__X3Buster_pulse[this]=sc__X3Buster__X3Body_spawn(this , 3 , s__X3Buster_originX[this] , s__X3Buster_originY[this] , s__X3Buster_angle[this] , s__X3Buster_RANGE)
        set s__X3Buster_pulses=s__X3Buster_pulses + 1
        return true
    endfunction
    function s__X3Buster_merge takes integer this,real x,real y returns nothing
        local real remaining= RMaxBJ(1., s__X3Buster_RANGE - SquareRoot(( x - s__X3Buster_originX[this] ) * ( x - s__X3Buster_originX[this] ) + ( y - s__X3Buster_originY[this] ) * ( y - s__X3Buster_originY[this] )))
        set s__X3Buster_state[this]=2
        set s__X3Buster_waiting[this]=false
        // All flags are set before child creation: no second union or impact.
        set s__Missile_wantDestroy[(s__X3Buster_green[this])]=true // INLINED!!
        set s__Missile_wantDestroy[(s__X3Buster_orange[this])]=true // INLINED!!
        set s__Missile_wantDestroy[(s__X3Buster_pulse[this])]=true // INLINED!!
        set s__X3Buster_fusions=s__X3Buster_fusions + 1
        set s__X3Buster_lastFusionX=x
        set s__X3Buster_lastFusionY=y
        set s__X3Buster_lastFusionAge=(TimerGetElapsed(s__X3Buster_clock)) - s__X3Buster_born[this] // INLINED!!
        call s__X3Buster__X3Flash_play(x , y , 70.)
        set s__X3Buster_fused[this]=sc__X3Buster__X3Body_spawn(this , 4 , x , y , s__X3Buster_angle[this] , remaining)
        set s__X3Buster_sat1[this]=sc__X3Buster__X3Body_spawn(this , 5 , x - 24. * Cos(s__X3Buster_angle[this]) , y - 24. * Sin(s__X3Buster_angle[this]) , s__X3Buster_angle[this] - 0.70 , 600.)
        set s__X3Buster_sat2[this]=sc__X3Buster__X3Body_spawn(this , 6 , x - 24. * Cos(s__X3Buster_angle[this]) , y - 24. * Sin(s__X3Buster_angle[this]) , s__X3Buster_angle[this] - 0.35 , 600.)
        set s__X3Buster_sat3[this]=sc__X3Buster__X3Body_spawn(this , 7 , x - 24. * Cos(s__X3Buster_angle[this]) , y - 24. * Sin(s__X3Buster_angle[this]) , s__X3Buster_angle[this] + 0.35 , 600.)
        set s__X3Buster_sat4[this]=sc__X3Buster__X3Body_spawn(this , 8 , x - 24. * Cos(s__X3Buster_angle[this]) , y - 24. * Sin(s__X3Buster_angle[this]) , s__X3Buster_angle[this] + 0.70 , 600.)
        set s__X3Buster_satellites=s__X3Buster_satellites + 4
    endfunction
    function s__X3Buster_tryFusion takes integer this,integer m returns nothing
        local real oldGap
        local real gap
        local real fraction
        if s__X3Buster_state[this] != 1 or not s__X3Buster_available(this,s__X3Buster_green[this]) or not s__X3Buster_available(this,s__X3Buster_orange[this]) or not s__X3Buster_available(this,s__X3Buster_pulse[this]) then
            return
        endif
        // Core moves all bodies first. Resolve both orbit sweeps even if their
        // callbacks occur later than this pulse; distance guards prevent repeats.
        if sc__X3Buster__X3Body_resolve(s__X3Buster_green[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_green[this])]=true // INLINED!!
        endif
        if sc__X3Buster__X3Body_resolve(s__X3Buster_orange[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_orange[this])]=true // INLINED!!
        endif
        if s__X3Buster_state[this] != 1 or not s__X3Buster_available(this,s__X3Buster_green[this]) or not s__X3Buster_available(this,s__X3Buster_orange[this]) or not s__X3Buster_available(this,s__X3Buster_pulse[this]) then
            return
        endif
        set oldGap=( s__Missile_prevX[s__X3Buster_green[this]] - s__Missile_prevX[m] ) * Cos(s__X3Buster_angle[this]) + ( s__Missile_prevY[s__X3Buster_green[this]] - s__Missile_prevY[m] ) * Sin(s__X3Buster_angle[this])
        set gap=( s__Missile_x[s__X3Buster_green[this]] - s__Missile_x[m] ) * Cos(s__X3Buster_angle[this]) + ( s__Missile_y[s__X3Buster_green[this]] - s__Missile_y[m] ) * Sin(s__X3Buster_angle[this])
        if oldGap > 0. and gap <= 0. then
            set fraction=oldGap / ( oldGap - gap )
            call s__X3Buster_merge(this,s__Missile_prevX[m] + ( s__Missile_x[m] - s__Missile_prevX[m] ) * fraction , s__Missile_prevY[m] + ( s__Missile_y[m] - s__Missile_prevY[m] ) * fraction)
        endif
    endfunction
    function s__X3Buster_countHit takes integer this,integer reason returns nothing
        if reason == 2 then
            set s__X3Buster_hits=s__X3Buster_hits + 1
        elseif reason == 1 then
            set s__X3Buster_walls=s__X3Buster_walls + 1
        endif
    endfunction
    function s__X3Buster_tick takes nothing returns nothing
        local integer this= s__X3Buster_first
        local integer following
        loop
            exitwhen this == 0
            set following=s__X3Buster_next[this]
            if (TimerGetElapsed(s__X3Buster_clock)) - s__X3Buster_born[this] >= s__X3Buster_LIFETIME or GetUnitTypeId(s__X3Buster_caster[this]) == 0 then // INLINED!!
                call s__X3Buster_cancel(this)
            endif
            if s__X3Buster_waiting[this] and s__X3Buster_automatic[this] and (TimerGetElapsed(s__X3Buster_clock)) - s__X3Buster_born[this] + 0.0001 >= s__X3Buster_PULSE_DELAY then // INLINED!!
                call s__X3Buster_releasePulse(this)
            endif
            if s__X3Buster_bodies[this] == 0 and not s__X3Buster_waiting[this] then
                if s__X3Buster_previous[this] == 0 then
                    set s__X3Buster_first=s__X3Buster_next[this]
                else
                    set s__X3Buster_next[(s__X3Buster_previous[this])]=s__X3Buster_next[this]
                endif
                if s__X3Buster_next[this] != 0 then
                    set s__X3Buster_previous[(s__X3Buster_next[this])]=s__X3Buster_previous[this]
                endif
                set s__X3Buster_caster[this]=null
                set s__X3Buster_owner[this]=null
                set s__X3Buster_live=s__X3Buster_live - 1
                call s__X3Buster_deallocate(this)
            endif
            set this=following
        endloop
        if s__X3Buster_first == 0 then
            call PauseTimer(s__X3Buster_ticker)
        endif
    endfunction
    // mode0: charged pulse; mode1: automatic cross shot; mode2: manual release API.
    function s__X3Buster_fire takes unit source,real tx,real ty,integer mode returns integer
        local integer this
        local real x= GetUnitX(source)
        local real y= GetUnitY(source)
        local real dx= tx - x
        local real dy= ty - y
        if not s__GroundCollision_alive(source) or s__X3Buster_live >= s__X3Buster_LIMIT or mode < 0 or mode > 2 then
            return 0
        endif
        set this=s__X3Buster__allocate()
        if dx * dx + dy * dy < 64. then
            set s__X3Buster_angle[this]=GetUnitFacing(source) * bj_DEGTORAD
        else
            set s__X3Buster_angle[this]=Atan2(dy, dx)
        endif
        // Reject a blocked muzzle before creating any body or crossing bounds.
        if s__GroundCollision_trace(x , y , x + 24. * Cos(s__X3Buster_angle[this]) , y + 24. * Sin(s__X3Buster_angle[this]) , 29. , source , GetOwningPlayer(source) , false) != 0 then
            call s__X3Buster_deallocate(this)
            return 0
        endif
        set s__X3Buster_originX[this]=x + 24. * Cos(s__X3Buster_angle[this])
        set s__X3Buster_originY[this]=y + 24. * Sin(s__X3Buster_angle[this])
        set s__X3Buster_caster[this]=source
        set s__X3Buster_owner[this]=GetOwningPlayer(source)
        set s__X3Buster_born[this]=(TimerGetElapsed(s__X3Buster_clock)) // INLINED!!
        set s__X3Buster_state[this]=0
        set s__X3Buster_bodies[this]=0
        set s__X3Buster_green[this]=0
        set s__X3Buster_orange[this]=0
        set s__X3Buster_pulse[this]=0
        set s__X3Buster_fused[this]=0
        set s__X3Buster_sat1[this]=0
        set s__X3Buster_sat2[this]=0
        set s__X3Buster_sat3[this]=0
        set s__X3Buster_sat4[this]=0
        set s__X3Buster_waiting[this]=mode != 0
        set s__X3Buster_automatic[this]=mode == 1
        set s__X3Buster_previous[this]=0
        set s__X3Buster_next[this]=s__X3Buster_first
        if s__X3Buster_first != 0 then
            set s__X3Buster_previous[(s__X3Buster_first)]=this
        else
            call TimerStart(s__X3Buster_ticker, 1. / 32., true, function s__X3Buster_tick)
        endif
        set s__X3Buster_first=this
        set s__X3Buster_live=s__X3Buster_live + 1
        if mode == 0 then
            set s__X3Buster_pulse[this]=sc__X3Buster__X3Body_spawn(this , 0 , s__X3Buster_originX[this] , s__X3Buster_originY[this] , s__X3Buster_angle[this] , s__X3Buster_RANGE)
        else
            set s__X3Buster_state[this]=1
            set s__X3Buster_green[this]=sc__X3Buster__X3Body_spawn(this , 1 , s__X3Buster_originX[this] , s__X3Buster_originY[this] , s__X3Buster_angle[this] , s__X3Buster_RANGE)
            set s__X3Buster_orange[this]=sc__X3Buster__X3Body_spawn(this , 2 , s__X3Buster_originX[this] , s__X3Buster_originY[this] , s__X3Buster_angle[this] , s__X3Buster_RANGE)
        endif
        return this
    endfunction
    function s__X3Buster_onInit takes nothing returns nothing
        call TimerStart(s__X3Buster_clock, 1000000., false, null)
    endfunction


    function s__X3Buster__X3Body_resolve takes integer m returns boolean
        local integer s= s__Missile_data[m]
        local real x= s__Missile_x[m]
        local real y= s__Missile_y[m]
        local real z= s__Missile_z[m]
        local real phase
        local real side
        local real radius= 29.
        local real damage= 75.
        local integer result
        local unit target
        if s__Missile_wantDestroy[m] or s__X3Buster__X3Body_blocked[m] then
            return true
        endif
        if s__X3Buster__X3Body_processed[m] == s__Missile_distance[m] then
            return false
        endif
        set s__X3Buster__X3Body_processed[m]=s__Missile_distance[m]
        if s__X3Buster__X3Body_kind[m] == 1 or s__X3Buster__X3Body_kind[m] == 2 then
            set phase=2. * bj_PI * s__X3Buster_ORBIT_HZ * s__Missile_distance[m] / s__X3Buster_ORBIT_SPEED
            if s__X3Buster__X3Body_kind[m] == 2 then
                set phase=phase + bj_PI
            endif
            set side=s__X3Buster_ORBIT_RADIUS * Cos(phase)
            set x=x - Sin(s__X3Buster_angle[s]) * side
            set y=y + Cos(s__X3Buster_angle[s]) * side
            set z=z + s__X3Buster_ORBIT_RADIUS * Sin(phase)
            set radius=12.65
            set damage=35.
        elseif s__X3Buster__X3Body_kind[m] == 4 then
            set radius=41.25
            set damage=150.
        elseif s__X3Buster__X3Body_kind[m] >= 5 then
            set radius=12.65
            set damage=25.
        endif
        set result=s__GroundCollision_trace(s__X3Buster__X3Body_lastX[m] , s__X3Buster__X3Body_lastY[m] , x , y , radius , s__X3Buster_caster[s] , s__X3Buster_owner[s] , true)
        set target=s__GroundCollision_hit
        if s__X3Buster__X3Body_kind[m] == 1 or s__X3Buster__X3Body_kind[m] == 2 then
            // Trace before translating: an orbital offset may cross the edge
            // even while the center is still within WorldBounds.
            call SetUnitX(s__Missile_dummy[m], s__GroundCollision_x)
            call SetUnitY(s__Missile_dummy[m], s__GroundCollision_y)
            call SetUnitFlyHeight(s__Missile_dummy[m], RMaxBJ(0., z), 0.)
        endif
        set s__X3Buster__X3Body_lastX[m]=x
        set s__X3Buster__X3Body_lastY[m]=y
        if result == 0 and z < 0. then
            set result=1
        endif
        if result != 0 then
            set s__X3Buster__X3Body_blocked[m]=true
            // Collision result/target are captured before damage can reenter.
            call s__X3Buster_countHit(s,result)
            if result == 2 and GetUnitTypeId(s__X3Buster_caster[s]) != 0 then
                call UnitDamageTarget(s__X3Buster_caster[s], target, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif
        endif
        set target=null
        return result != 0
    endfunction
    function s__X3Buster__X3Body_onPeriod takes integer m returns boolean
        local integer s= s__Missile_data[m]
        if s__X3Buster__X3Body_resolve(m) then
            return true
        endif
        if s__X3Buster__X3Body_kind[m] == 3 then
            call s__X3Buster_tryFusion(s,m)
        endif
        return false
    endfunction
    function s__X3Buster__X3Body_onFinish takes integer m returns boolean
        call s__X3Buster__X3Body_resolve(m)
        return true
    endfunction
    function s__X3Buster__X3Body_onRemove takes integer m returns boolean
        local integer s= s__Missile_data[m]
        call s__X3Buster_untrack(s,m)
        set s__Missile_data[m]=0
        set s__X3Buster__X3Body_blocked[m]=false
        return false
    endfunction
//Implemented from module MissileStruct:
        function s__X3Buster__X3Body_launch takes integer missile returns nothing

// NO_DEBUG:                 debug call ThrowError(missile.launched, "thistype", "launch", "missile.launched", missile, "This missile was already launched before!")

// NO_DEBUG:             debug set missile.launched = true
            //
            call s__Missile_insertFront(Missile___missileList[si__X3Buster__X3Body],missile)
            call Missile___StartPeriodic(si__X3Buster__X3Body)
        endfunction
        // Called from missileIterate. "P" to avoid code collision.
        function s__X3Buster__X3Body_missileTerminateP takes integer node returns nothing
            if s__Missile_allocated[node] then


                        if s__X3Buster__X3Body_onRemove(node) and GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID then
                            call s__Missile___RecycleBin_recycle(s__Missile_dummy[node])
                            set s__Missile_dummy[(node)]=null // INLINED!!
                        endif




            
                call s__Missile_terminate(node)
                call Missile___StopPeriodic(si__X3Buster__X3Body)
            endif
        endfunction
























        













    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__X3Buster__X3Body_missileIterateP takes nothing returns boolean
            local integer this= (s__Missile_Missile___MissileStructure____first[(Missile___missileList[si__X3Buster__X3Body])]) // INLINED!!
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            loop
                exitwhen 0 == this
                set node=(s__Missile_Missile___MissileStructure____next[(this)]) // The linked list should not lose the next node. // INLINED!!
               
                if s__Missile_wantDestroy[this] then
                    call s__X3Buster__X3Body_missileTerminateP(this)
                else
                    if s__Missile_stackSize[this] > 0 then
                        call s__Missile_updateStack(this)
                    endif
                    
                    // Runs unit collision.







































                    
                    // Runs destructable collision.






                    
                    // Runs item collision.






                
                    // Runs when the destination is reached.
                    if s__Missile_recycle[this] and s__Missile_allocated[this] then

                            if s__X3Buster__X3Body_onFinish(this) then
                                call s__X3Buster__X3Body_missileTerminateP(this)
                            endif



                    endif
                
                    // Runs on terrian collision.





                
                    // Runs every Missile_TIMER_TIMEOUT.

                        if s__Missile_allocated[this] and s__X3Buster__X3Body_onPeriod(this) then
                            call s__X3Buster__X3Body_missileTerminateP(this)
                        endif

                endif
                set this=node
            endloop
            
            set u=null



                return false

        endfunction
        
        function s__X3Buster__X3Body_MissileStruct___onInit takes nothing returns nothing
            set Missile___missileList[(si__X3Buster__X3Body)]=s__Missile_allocateCollection() // INLINED!!
            set Missile___expression[(si__X3Buster__X3Body )]=Condition(( function s__X3Buster__X3Body_missileIterateP)) // INLINED!!
        endfunction

    function s__X3Buster__X3Body_spawn takes integer s,integer form,real x,real y,real facing,real length returns integer
        local integer m= s__Missile_createXYZ(x , y , 70. , x + length * Cos(facing) , y + length * Sin(facing) , 70.)
        set s__Missile_data[m]=s
        set s__Missile_owner[m]=s__X3Buster_owner[s]
        set s__Missile_collision[m]=0.
        set s__X3Buster__X3Body_kind[m]=form
        set s__X3Buster__X3Body_processed[m]=- 1.
        set s__X3Buster__X3Body_blocked[m]=false
        set s__X3Buster__X3Body_lastX[m]=x
        set s__X3Buster__X3Body_lastY[m]=y
        if form == 1 or form == 2 or form >= 5 then
            if form == 1 or form == 5 or form == 8 then
                call s__Missile__set_model(m,"X3Buster\\X3_Orbe_Verde.mdx")
            else
                call s__Missile__set_model(m,"X3Buster\\X3_Orbe_Naranja.mdx")
            endif
            call s__Missile__set_scale(m,0.55)
            if form < 3 then
                set s__Missile_speed[(m)]=((s__X3Buster_ORBIT_SPEED)*1.0) * Missile_TIMER_TIMEOUT // INLINED!!
            else
                set s__Missile_speed[(m)]=((700.)*1.0) * Missile_TIMER_TIMEOUT // INLINED!!
            endif
        elseif form == 4 then
            call s__Missile__set_model(m,"X3Buster\\X3_Cross_Buster.mdx")
            call s__Missile__set_scale(m,1.)
            set s__Missile_speed[(m)]=((s__X3Buster_FUSED_SPEED)*1.0) * Missile_TIMER_TIMEOUT // INLINED!!
        else
            call s__Missile__set_model(m,"X3Buster\\X3_Buster_Cargado.mdx")
            call s__Missile__set_scale(m,1.)
            set s__Missile_speed[(m)]=((s__X3Buster_PULSE_SPEED)*1.0) * Missile_TIMER_TIMEOUT // INLINED!!
        endif
        call s__X3Buster_track(s,m)
        call s__X3Buster__X3Body_launch(m)
        return m
    endfunction

    function s__RapidDemo_row takes integer r,string name,string value returns nothing
        local multiboarditem cell= MultiboardGetItem(s__MissileStats_board, r, 0)
        call MultiboardSetItemStyle(cell, true, false)
        call MultiboardSetItemWidth(cell, 0.17)
        call MultiboardSetItemValue(cell, name)
        call MultiboardReleaseItem(cell)
        set cell=MultiboardGetItem(s__MissileStats_board, r, 1)
        call MultiboardSetItemStyle(cell, true, false)
        call MultiboardSetItemWidth(cell, 0.12)
        call MultiboardSetItemValue(cell, value)
        call MultiboardReleaseItem(cell)
        set cell=null
    endfunction
    function s__RapidDemo_panel takes nothing returns nothing
        if s__MissileStats_board != null then
            if not s__RapidDemo_extended then
                call MultiboardSetRowCount(s__MissileStats_board, 25)
                set s__RapidDemo_extended=true
            endif
            call s__RapidDemo_row(19 , "Rafagas / pendientes" , I2S(s__RapidPair_bursts) + " / " + I2S(s__RapidPair_remaining))
            call s__RapidDemo_row(20 , "Move art. / bloqueado" , I2S(s__RapidPair_moving) + " / " + I2S(s__RapidPair_blocked))
            call s__RapidDemo_row(21 , "Tiros / recasts" , I2S(s__RapidPair_emitted) + " / " + I2S(s__RapidPair_recasts))
            if s__RapidPair_minInterval == 99999. then
                call s__RapidDemo_row(22 , "Intervalo min / base" , "-- / 250 ms")
            else
                call s__RapidDemo_row(22 , "Intervalo min / base" , I2S(R2I(s__RapidPair_minInterval * 1000. + 0.5)) + " / 250 ms")
            endif
            call s__RapidDemo_row(23 , "Instantaneos / XY" , I2S(s__GroundMotion_instantTransitions) + " / " + I2S(s__GroundMotion_xySteps))
            call s__RapidDemo_row(24 , "Retornos / proyectiles" , I2S(s__GroundMotion_handoffs) + " / " + I2S(s__RapidBolt_live))
        endif
    endfunction
    function s__RapidDemo_setup takes nothing returns nothing
        local integer i= 0
        local real x= GetStartLocationX(0) + 384.
        local real y= GetStartLocationY(0) - 256.
        local real bx= x
        local real by= y
        local unit actor
        local unit controller
        loop
            exitwhen s__GroundCollision_clear(x , y , 24.) or i == 100
            set x=bx + I2R(ModuloInteger(i, 10)) * 96.
            set y=by + I2R(i / 10) * 96.
            set i=i + 1
        endloop
        set actor=CreateUnit(Player(0), 'rfex', x, y, 0.)
        set controller=CreateUnit(Player(0), 'rfct', s__WorldBounds_minX + 256., s__WorldBounds_minY + 256., 0.)
        call SetUnitVertexColor(controller, 255, 255, 255, 0)
        set s__RapidDemo_pair=s__RapidPair_create(controller , actor)
        set i=0
        loop
            exitwhen i == 3
            set s__RapidDemo_targets[i]=CreateUnit(Player(12), 'rftg', x + 450. + I2R(i) * 180., y + 96. * I2R(i), 180.)
            call PauseUnit(s__RapidDemo_targets[i], true)
            set i=i + 1
        endloop
        if GetLocalPlayer() == Player(0) then
            call ClearSelection()
            call SelectUnit(controller, true)
            call SetCameraTargetController(actor, 0., 0., false)
        endif
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 18., "Rapid Fire: Q y apunta. Clic derecho en suelo para mover. Recast repone 6 sin reiniciar intervalo. -misiles muestra/oculta el panel.")
        set actor=null
        set controller=null
    endfunction
    function s__RapidDemo_start takes nothing returns nothing
        call s__RapidDemo_setup()
        call DestroyTimer(GetExpiredTimer())
    endfunction
    function s__RapidDemo_initialize takes nothing returns nothing
        call TimerStart(CreateTimer(), 0.25, false, function s__RapidDemo_start)
        call TimerStart(CreateTimer(), 0.25, true, function s__RapidDemo_panel)
    endfunction
function RapidFireDemo___Init takes nothing returns nothing
    call s__RapidDemo_initialize()
endfunction

function RapidFireProbe___Note takes string s returns nothing
    set RapidFireProbe___lines[RapidFireProbe___count]=s
    set RapidFireProbe___count=RapidFireProbe___count + 1
endfunction
function RapidFireProbe___Check takes boolean ok,string label returns nothing
    set RapidFireProbe___checks=RapidFireProbe___checks + 1
    if ok then
        call RapidFireProbe___Note("PASS " + label)
    else
        set RapidFireProbe___failures=RapidFireProbe___failures + 1
        call RapidFireProbe___Note("FAIL " + label)
    endif
endfunction
function RapidFireProbe___Save takes string status returns nothing
    local integer i= 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("RAPID 20261022-202306 " + status)
    loop
        exitwhen i == RapidFireProbe___count
        call Preload(RapidFireProbe___lines[i])
        set i=i + 1
    endloop
    call Preload("checks=" + I2S(RapidFireProbe___checks) + " failures=" + I2S(RapidFireProbe___failures) + " observed=" + I2S(RapidFireProbe___observed) + " minimum=" + R2S(RapidFireProbe___minimum) + " emitted=" + I2S(s__RapidPair_emitted) + " live=" + I2S(s__RapidBolt_live) + " pairs=" + I2S(s__RapidPair_pairs))
    call PreloadGenEnd("Logs\\TerrainDev-20261022-202306-rapid.txt")
endfunction
function RapidFireProbe___Advance takes integer value returns nothing
    set RapidFireProbe___stage=value
    set RapidFireProbe___since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
    set RapidFireProbe___one=false
    set RapidFireProbe___two=false
    call RapidFireProbe___Save("PROGRESS stage=" + I2S(RapidFireProbe___stage))
endfunction
function RapidFireProbe___Body takes real x,real y returns integer
    return s__RapidPair_create(CreateUnit(Player(0), 'rfct', s__WorldBounds_minX + 256., s__WorldBounds_minY + 256., 0.) , CreateUnit(Player(0), 'rfex', x, y, 0.))
endfunction
function RapidFireProbe___Reset takes nothing returns nothing
    local unit body= s__RapidPair_actor[RapidFireProbe___p]
    call s__RapidPair_destroy(RapidFireProbe___p)
    call RemoveUnit(body)
    set RapidFireProbe___p=RapidFireProbe___Body(RapidFireProbe___sx , RapidFireProbe___sy)
    set body=null
endfunction
function RapidFireProbe___CliffCase takes integer i returns nothing
    if i == 0 then
        set RapidFireProbe___cx1=- 3168.
        set RapidFireProbe___cy1=- 5632.
        set RapidFireProbe___cx2=- 2848.
        set RapidFireProbe___cy2=- 5632.
    elseif i == 1 then
        set RapidFireProbe___cx1=- 1760.
        set RapidFireProbe___cy1=- 4480.
        set RapidFireProbe___cx2=- 1440.
        set RapidFireProbe___cy2=- 4480.
    elseif i == 2 then
        set RapidFireProbe___cx1=- 5504.
        set RapidFireProbe___cy1=- 3424.
        set RapidFireProbe___cx2=- 5504.
        set RapidFireProbe___cy2=- 3104.
    elseif i == 3 then
        set RapidFireProbe___cx1=- 5376.
        set RapidFireProbe___cy1=- 3424.
        set RapidFireProbe___cx2=- 5376.
        set RapidFireProbe___cy2=- 3104.
    elseif i == 4 then
        set RapidFireProbe___cx1=2048.
        set RapidFireProbe___cy1=- 2784.
        set RapidFireProbe___cx2=2048.
        set RapidFireProbe___cy2=- 2464.
    elseif i == 5 then
        set RapidFireProbe___cx1=2176.
        set RapidFireProbe___cy1=800.
        set RapidFireProbe___cx2=2176.
        set RapidFireProbe___cy2=1120.
    elseif i == 6 then
        set RapidFireProbe___cx1=2304.
        set RapidFireProbe___cy1=800.
        set RapidFireProbe___cx2=2304.
        set RapidFireProbe___cy2=1120.
    elseif i == 7 then
        set RapidFireProbe___cx1=2432.
        set RapidFireProbe___cy1=800.
        set RapidFireProbe___cx2=2432.
        set RapidFireProbe___cy2=1120.
    elseif i == 8 then
        set RapidFireProbe___cx1=1824.
        set RapidFireProbe___cy1=1152.
        set RapidFireProbe___cx2=2144.
        set RapidFireProbe___cy2=1152.
    elseif i == 9 then
        set RapidFireProbe___cx1=- 2944.
        set RapidFireProbe___cy1=1184.
        set RapidFireProbe___cx2=- 2944.
        set RapidFireProbe___cy2=1504.
    elseif i == 10 then
        set RapidFireProbe___cx1=- 2816.
        set RapidFireProbe___cy1=1184.
        set RapidFireProbe___cx2=- 2816.
        set RapidFireProbe___cy2=1504.
    elseif i == 11 then
        set RapidFireProbe___cx1=- 2688.
        set RapidFireProbe___cy1=1184.
        set RapidFireProbe___cx2=- 2688.
        set RapidFireProbe___cy2=1504.
    elseif i == 12 then
        set RapidFireProbe___cx1=- 3680.
        set RapidFireProbe___cy1=1920.
        set RapidFireProbe___cx2=- 3360.
        set RapidFireProbe___cy2=1920.
    elseif i == 13 then
        set RapidFireProbe___cx1=1536.
        set RapidFireProbe___cy1=1824.
        set RapidFireProbe___cx2=1536.
        set RapidFireProbe___cy2=2144.
    elseif i == 14 then
        set RapidFireProbe___cx1=1664.
        set RapidFireProbe___cy1=1824.
        set RapidFireProbe___cx2=1664.
        set RapidFireProbe___cy2=2144.
    elseif i == 15 then
        set RapidFireProbe___cx1=- 3680.
        set RapidFireProbe___cy1=2048.
        set RapidFireProbe___cx2=- 3360.
        set RapidFireProbe___cy2=2048.
    elseif i == 16 then
        set RapidFireProbe___cx1=- 5248.
        set RapidFireProbe___cy1=5280.
        set RapidFireProbe___cx2=- 5248.
        set RapidFireProbe___cy2=5600.
    elseif i == 17 then
        set RapidFireProbe___cx1=- 2016.
        set RapidFireProbe___cy1=5504.
        set RapidFireProbe___cx2=- 1696.
        set RapidFireProbe___cy2=5504.
    elseif i == 18 then
        set RapidFireProbe___cx1=- 2688.
        set RapidFireProbe___cy1=5664.
        set RapidFireProbe___cx2=- 2688.
        set RapidFireProbe___cy2=5984.
    elseif i == 19 then
        set RapidFireProbe___cx1=- 2016.
        set RapidFireProbe___cy1=5888.
        set RapidFireProbe___cx2=- 1696.
        set RapidFireProbe___cy2=5888.
    elseif i == 20 then
        set RapidFireProbe___cx1=- 2016.
        set RapidFireProbe___cy1=6016.
        set RapidFireProbe___cx2=- 1696.
        set RapidFireProbe___cy2=6016.
    endif
endfunction
function RapidFireProbe___Tick takes nothing returns nothing
    local real elapsed= (TimerGetElapsed(s__RapidPair_clock)) - RapidFireProbe___since // INLINED!!
    local real travelled
    local real angle
    local integer result
    local unit body
    if RapidFireProbe___stage == 1 and s__RapidPair_firing[RapidFireProbe___p] and RapidFireProbe___firstEmission < 0. then
        set RapidFireProbe___firstEmission=s__RapidPair_lastShot[RapidFireProbe___p]
    endif
    if RapidFireProbe___stage == 1 and not s__RapidPair_firing[RapidFireProbe___p] and RapidFireProbe___firstEmission > 0. and RapidFireProbe___firstEnd < 0. then
        set RapidFireProbe___firstEnd=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
    endif
    if RapidFireProbe___p != 0 and s__RapidPair_lastShot[RapidFireProbe___p] != RapidFireProbe___last and s__RapidPair_lastShot[RapidFireProbe___p] > 0. then
        if RapidFireProbe___last > 0. and s__RapidPair_lastShot[RapidFireProbe___p] - RapidFireProbe___last < RapidFireProbe___minimum then
            set RapidFireProbe___minimum=s__RapidPair_lastShot[RapidFireProbe___p] - RapidFireProbe___last
        endif
        set RapidFireProbe___last=s__RapidPair_lastShot[RapidFireProbe___p]
        set RapidFireProbe___observed=RapidFireProbe___observed + 1
        call RapidFireProbe___Note("SHOT stage=" + I2S(RapidFireProbe___stage) + " time=" + R2S(RapidFireProbe___last) + " pending=" + I2S(s__RapidPair_pending[RapidFireProbe___p]) + " aim=" + R2S(s__RapidPair_aimX[RapidFireProbe___p]) + "," + R2S(s__RapidPair_aimY[RapidFireProbe___p]))
    endif
    if RapidFireProbe___stage == 0 then
        call RapidFireProbe___Save("BEFORE BODY")
        set RapidFireProbe___p=RapidFireProbe___Body(RapidFireProbe___sx , RapidFireProbe___sy)
        call RapidFireProbe___Save("BEFORE TRACE")
        call RapidFireProbe___Check(s__GroundCollision_trace(RapidFireProbe___sx , RapidFireProbe___sy , RapidFireProbe___sx + 320. , RapidFireProbe___sy , 24. , s__RapidPair_actor[RapidFireProbe___p] , Player(0) , false) == 0 , "open lane 320 ground units")
        call RapidFireProbe___Save("AFTER TRACE")
        call RapidFireProbe___Check(GetUnitAbilityLevel(s__RapidPair_controller[RapidFireProbe___p], 'Arpf') == 1 and GetUnitAbilityLevel(s__RapidPair_actor[RapidFireProbe___p], 'Arpf') == 0 , "ability only on controller")
        set RapidFireProbe___baseline=s__RapidPair_emitted
        set RapidFireProbe___createdBaseline=s__MissileStats_created
        call RapidFireProbe___Check(IssuePointOrder(s__RapidPair_controller[RapidFireProbe___p], "channel", RapidFireProbe___sx + 900., RapidFireProbe___sy) , "native point cast accepted")
        call RapidFireProbe___Advance(1)
    elseif RapidFireProbe___stage == 1 and elapsed > 2.1 then
        call RapidFireProbe___Check(s__RapidPair_emitted - RapidFireProbe___baseline == 6 , "native cast emitted exactly six")
        call RapidFireProbe___Check(s__MissileStats_created - RapidFireProbe___createdBaseline == 6 and s__RapidBolt_live == 0 , "six real Missile instances created and retired")
        call RapidFireProbe___Check(not s__RapidPair_firing[RapidFireProbe___p] and s__RapidPair_pending[RapidFireProbe___p] == 0 , "initial burst tail ended")
        call RapidFireProbe___Check(RAbsBJ(RapidFireProbe___firstEnd - RapidFireProbe___firstEmission - 1.5) < 0.032 , "burst protection ends 1.5 seconds after first emission")
        call RapidFireProbe___Note("WINDOW first=" + R2S(RapidFireProbe___firstEmission) + " end=" + R2S(RapidFireProbe___firstEnd))
        set RapidFireProbe___baseline=s__RapidPair_emitted
        call s__RapidPair_cast(RapidFireProbe___p,RapidFireProbe___sx + 900. , RapidFireProbe___sy)
        set RapidFireProbe___oldFlight=s__RapidPair_lastMissile[RapidFireProbe___p]
        call RapidFireProbe___Advance(2)
    elseif RapidFireProbe___stage == 2 then
        if elapsed >= 0.125 and not RapidFireProbe___one then
            set RapidFireProbe___expectedNext=s__RapidPair_nextShot[RapidFireProbe___p]
            set RapidFireProbe___expectedHits=s__RapidPair_emitted
            call s__RapidPair_cast(RapidFireProbe___p,RapidFireProbe___sx , RapidFireProbe___sy + 600.)
            call RapidFireProbe___Check(s__RapidPair_pending[RapidFireProbe___p] == 6 and s__RapidPair_nextShot[RapidFireProbe___p] == RapidFireProbe___expectedNext and s__RapidPair_emitted == RapidFireProbe___expectedHits , "early recast six, same clock, no extra shot")
            call RapidFireProbe___Check(s__Missile_allocated[RapidFireProbe___oldFlight] and s__MissilePosition_x[s__Missile_impact[RapidFireProbe___oldFlight]] == RapidFireProbe___sx + 900. and s__MissilePosition_y[s__Missile_impact[RapidFireProbe___oldFlight]] == RapidFireProbe___sy , "already launched missile keeps its original aim")
            set RapidFireProbe___one=true
        endif
        if elapsed >= 0.28125 and not RapidFireProbe___two then
            call RapidFireProbe___Check(s__MissilePosition_y[s__Missile_impact[s__RapidPair_lastMissile[RapidFireProbe___p]]] == RapidFireProbe___sy + 600. and s__MissilePosition_x[s__Missile_impact[s__RapidPair_lastMissile[RapidFireProbe___p]]] == RapidFireProbe___sx , "next missile uses new aim")
            set RapidFireProbe___expectedNext=s__RapidPair_nextShot[RapidFireProbe___p]
            set RapidFireProbe___expectedHits=s__RapidPair_emitted
            call s__RapidPair_cast(RapidFireProbe___p,RapidFireProbe___sx + 800. , RapidFireProbe___sy + 100.)
            call RapidFireProbe___Check(s__RapidPair_pending[RapidFireProbe___p] == 6 and s__RapidPair_nextShot[RapidFireProbe___p] == RapidFireProbe___expectedNext and s__RapidPair_emitted == RapidFireProbe___expectedHits , "late recast six, same clock, new aim")
            set RapidFireProbe___two=true
        endif
        if elapsed > 2.2 then
            call RapidFireProbe___Check(s__RapidPair_emitted - RapidFireProbe___baseline == 8 and not s__RapidPair_firing[RapidFireProbe___p] , "two recasts produced eight scheduled emissions")
            call RapidFireProbe___Reset()
            call s__GroundMotion_destination(s__RapidPair_motion[(RapidFireProbe___p)],((RapidFireProbe___sx + 1050. )*1.0) , (( RapidFireProbe___sy)*1.0)) // INLINED!!
            call RapidFireProbe___Advance(3)
        endif
    elseif RapidFireProbe___stage == 3 and elapsed > 0.3 then
        call RapidFireProbe___Check(GetUnitCurrentOrder(s__RapidPair_actor[RapidFireProbe___p]) == 851986 and GetUnitX(s__RapidPair_actor[RapidFireProbe___p]) > RapidFireProbe___sx + 30. , "native locomotion before cast")
        set RapidFireProbe___instants=s__GroundMotion_instantTransitions
        set RapidFireProbe___expectedHandoffs=s__GroundMotion_handoffs
        call s__RapidPair_cast(RapidFireProbe___p,GetUnitX(s__RapidPair_actor[RapidFireProbe___p]) , RapidFireProbe___sy + 600.)
        set RapidFireProbe___startX=GetUnitX(s__RapidPair_actor[RapidFireProbe___p])
        set RapidFireProbe___startY=GetUnitY(s__RapidPair_actor[RapidFireProbe___p])
        call RapidFireProbe___Check(GetUnitCurrentOrder(s__RapidPair_actor[RapidFireProbe___p]) == 0 and s__GroundMotion_instantTransitions == RapidFireProbe___instants + 1 , "instant first tick cancels native move")
        call RapidFireProbe___Advance(4)
    elseif RapidFireProbe___stage == 4 then
        if elapsed > 0.2 and not RapidFireProbe___one then
            set travelled=GetUnitX(s__RapidPair_actor[RapidFireProbe___p]) - RapidFireProbe___startX
            call RapidFireProbe___Note("MOVE distance=" + R2S(travelled) + " seconds=" + R2S(elapsed) + " facing=" + R2S(GetUnitFacing(s__RapidPair_actor[RapidFireProbe___p])))
            call RapidFireProbe___Check(RAbsBJ(travelled - 350. * elapsed) < 15. and RAbsBJ(GetUnitY(s__RapidPair_actor[RapidFireProbe___p]) - RapidFireProbe___startY) < 1. , "artificial speed 350 without double native travel")
            call RapidFireProbe___Check(GetUnitFacing(s__RapidPair_actor[RapidFireProbe___p]) > 80. and GetUnitFacing(s__RapidPair_actor[RapidFireProbe___p]) < 115. , "aim facing independent of movement")
            set RapidFireProbe___expectedNext=s__RapidPair_nextShot[RapidFireProbe___p]
            call s__RapidPair_cast(RapidFireProbe___p,RapidFireProbe___sx + 1000. , RapidFireProbe___sy + 500.)
            call RapidFireProbe___Check(s__RapidPair_nextShot[RapidFireProbe___p] == RapidFireProbe___expectedNext and s__GroundMotion_instantTransitions == RapidFireProbe___instants + 1 , "moving recast does not repeat instant transition")
            call RapidFireProbe___Check(IssuePointOrder(s__RapidPair_controller[RapidFireProbe___p], "move", RapidFireProbe___sx + 1050., RapidFireProbe___sy + 32.) , "proxy point move accepted during burst")
            call RapidFireProbe___Check(s__GroundMotion_goalY[s__RapidPair_motion[RapidFireProbe___p]] == RapidFireProbe___sy + 32. , "new move target captured")
            set RapidFireProbe___one=true
        endif
        if elapsed > 2. then
            call RapidFireProbe___Check(not s__RapidPair_firing[RapidFireProbe___p] and s__GroundMotion_handoffs == RapidFireProbe___expectedHandoffs + 1 and GetUnitCurrentOrder(s__RapidPair_actor[RapidFireProbe___p]) == 851986 , "one native handoff for unfinished route")
            call RapidFireProbe___Reset()
            set RapidFireProbe___expectedHandoffs=s__GroundMotion_handoffs
            call s__RapidPair_cast(RapidFireProbe___p,RapidFireProbe___sx + 900. , RapidFireProbe___sy)
            call s__GroundMotion_destination(s__RapidPair_motion[(RapidFireProbe___p)],((RapidFireProbe___sx + 40. )*1.0) , (( RapidFireProbe___sy)*1.0)) // INLINED!!
            call RapidFireProbe___Advance(5)
        endif
    elseif RapidFireProbe___stage == 5 and elapsed > 1.7 then
        call RapidFireProbe___Check(not s__GroundMotion_hasGoal[s__RapidPair_motion[RapidFireProbe___p]] and RAbsBJ(GetUnitX(s__RapidPair_actor[RapidFireProbe___p]) - ( RapidFireProbe___sx + 40. )) < 3. , "short artificial route arrived")
        call RapidFireProbe___Check(s__GroundMotion_handoffs == RapidFireProbe___expectedHandoffs and GetUnitCurrentOrder(s__RapidPair_actor[RapidFireProbe___p]) == 0 , "no native move after arrival")
        call RapidFireProbe___Reset()
        set RapidFireProbe___target=CreateUnit(Player(12), 'rftg', RapidFireProbe___sx + 160., RapidFireProbe___sy, 0.)
        call PauseUnit(RapidFireProbe___target, true)
        set RapidFireProbe___expectedHits=s__RapidBolt_hits
        call s__RapidBolt_shoot(s__RapidPair_actor[RapidFireProbe___p] , RapidFireProbe___sx + 500. , RapidFireProbe___sy)
        call RapidFireProbe___Advance(6)
    elseif RapidFireProbe___stage == 6 and elapsed > 0.6 then
        call RapidFireProbe___Check(s__RapidBolt_hits == RapidFireProbe___expectedHits + 1 and GetWidgetLife(RapidFireProbe___target) < 2000. and GetWidgetLife(RapidFireProbe___target) > 1960. , "projectile expectedHits enemy once and retires")
        call RemoveUnit(RapidFireProbe___target)
        set RapidFireProbe___target=CreateUnit(Player(0), 'rftg', RapidFireProbe___sx + 110., RapidFireProbe___sy, 0.)
        call PauseUnit(RapidFireProbe___target, true)
        call s__RapidPair_cast(RapidFireProbe___p,RapidFireProbe___sx + 600. , RapidFireProbe___sy)
        call s__GroundMotion_destination(s__RapidPair_motion[(RapidFireProbe___p)],((RapidFireProbe___sx + 250. )*1.0) , (( RapidFireProbe___sy)*1.0)) // INLINED!!
        call RapidFireProbe___Advance(7)
    elseif RapidFireProbe___stage == 7 and elapsed > 1.7 then
        call RapidFireProbe___Check(GetUnitX(s__RapidPair_actor[RapidFireProbe___p]) > RapidFireProbe___sx + 245. , "artificial movement ignores unit collision")
        call RemoveUnit(RapidFireProbe___target)
        call RapidFireProbe___Reset()
        set RapidFireProbe___tree=CreateDestructable('LTlt', RapidFireProbe___sx + 180., RapidFireProbe___sy, 0., 1., 0)
        set RapidFireProbe___target=CreateUnit(Player(12), 'rftg', RapidFireProbe___sx + 360., RapidFireProbe___sy, 0.)
        call PauseUnit(RapidFireProbe___target, true)
        set RapidFireProbe___expectedWalls=s__RapidBolt_walls
        set RapidFireProbe___expectedHits=s__RapidBolt_hits
        call s__RapidPair_cast(RapidFireProbe___p,RapidFireProbe___sx + 600. , RapidFireProbe___sy)
        call s__GroundMotion_destination(s__RapidPair_motion[(RapidFireProbe___p)],((RapidFireProbe___sx + 500. )*1.0) , (( RapidFireProbe___sy)*1.0)) // INLINED!!
        call RapidFireProbe___Advance(8)
    elseif RapidFireProbe___stage == 8 and elapsed > 1.4 then
        call RapidFireProbe___Check(s__GroundMotion_blocked[s__RapidPair_motion[RapidFireProbe___p]] and GetUnitX(s__RapidPair_actor[RapidFireProbe___p]) < RapidFireProbe___sx + 150. , "live tree blocks artificial movement")
        call RapidFireProbe___Check(s__RapidBolt_walls > RapidFireProbe___expectedWalls and s__RapidBolt_hits == RapidFireProbe___expectedHits and GetWidgetLife(RapidFireProbe___target) == 2000. , "tree stops projectiles before target behind it")
        call KillDestructable(RapidFireProbe___tree)
        call RapidFireProbe___Advance(9)
    elseif RapidFireProbe___stage == 9 and elapsed > 1.2 then
        call RapidFireProbe___Check(not s__GroundCollision_alive(null) , "null units rejected")
        call RapidFireProbe___Check(GetUnitX(s__RapidPair_actor[RapidFireProbe___p]) > RapidFireProbe___sx + 200. , "native travel can continue after dead tree")
        call RemoveDestructable(RapidFireProbe___tree)
        call RemoveUnit(RapidFireProbe___target)
        call RapidFireProbe___Reset()
        set RapidFireProbe___q=RapidFireProbe___Body(RapidFireProbe___sx , RapidFireProbe___sy - 48.)
        call s__RapidPair_cast(RapidFireProbe___p,RapidFireProbe___sx + 600. , RapidFireProbe___sy)
        call s__RapidPair_cast(RapidFireProbe___q,RapidFireProbe___sx + 600. , RapidFireProbe___sy - 48.)
        set RapidFireProbe___expectedNext=s__RapidPair_nextShot[RapidFireProbe___q]
        call s__RapidPair_cast(RapidFireProbe___p,RapidFireProbe___sx , RapidFireProbe___sy + 500.)
        call RapidFireProbe___Check(s__RapidPair_nextShot[RapidFireProbe___q] == RapidFireProbe___expectedNext and s__RapidPair_pending[RapidFireProbe___q] == 5 and s__RapidPair_aimY[RapidFireProbe___q] == RapidFireProbe___sy - 48. , "two pairs isolated during recast")
        call RapidFireProbe___Advance(10)
    elseif RapidFireProbe___stage == 10 and elapsed > 2. then
        call RapidFireProbe___Check(not s__RapidPair_firing[RapidFireProbe___p] and not s__RapidPair_firing[RapidFireProbe___q] and s__RapidBolt_live == 0 and s__MissileStats_active == 0 , "two concurrent emitters and real projectiles drain")
        set body=s__RapidPair_actor[RapidFireProbe___q]
        call s__RapidPair_cast(RapidFireProbe___q,RapidFireProbe___sx + 600. , RapidFireProbe___sy)
        call KillUnit(body)
        set RapidFireProbe___q=0
        call RapidFireProbe___Advance(11)
    elseif RapidFireProbe___stage == 11 and elapsed > 1.5 then
        call RapidFireProbe___Check(s__RapidPair_pairs == 2 and s__RapidPair_bursts == 0 and s__RapidPair_remaining == 0 and s__RapidBolt_live == 0 , "death cleans controller, emitter, pending and projectile state")
        call RapidFireProbe___Check(RapidFireProbe___minimum >= 0.249 and RapidFireProbe___minimum <= 0.282 and RapidFireProbe___observed >= 30 , "positive emission coverage with clean intervals")
        call RapidFireProbe___Check(MultiboardGetRowCount(s__MissileStats_board) == 25 , "diagnostics extended to 25 rows")
        call RapidFireProbe___Advance(12)
    elseif RapidFireProbe___stage == 12 then
        call RapidFireProbe___CliffCase(RapidFireProbe___cliffIndex)
        if s__GroundCollision_clear(RapidFireProbe___cx1 , RapidFireProbe___cy1 , 24.) and s__GroundCollision_clear(RapidFireProbe___cx2 , RapidFireProbe___cy2 , 24.) and RAbsBJ(s__GroundCollision_height(RapidFireProbe___cx1 , RapidFireProbe___cy1) - s__GroundCollision_height(RapidFireProbe___cx2 , RapidFireProbe___cy2)) > 64. then
            call RapidFireProbe___Note("CLIFF from=" + R2S(RapidFireProbe___cx1) + "," + R2S(RapidFireProbe___cy1) + " to=" + R2S(RapidFireProbe___cx2) + "," + R2S(RapidFireProbe___cy2) + " levels=" + I2S(GetTerrainCliffLevel(RapidFireProbe___cx1, RapidFireProbe___cy1)) + "," + I2S(GetTerrainCliffLevel(RapidFireProbe___cx2, RapidFireProbe___cy2)))
            call RapidFireProbe___Check(true , "authored cliff endpoints are walkable with real elevation change")
            call RapidFireProbe___Check(s__GroundCollision_trace(RapidFireProbe___cx1 , RapidFireProbe___cy1 , RapidFireProbe___cx2 , RapidFireProbe___cy2 , 24. , s__RapidPair_actor[RapidFireProbe___p] , Player(0) , false) == 1 , "authored cliff blocks swept movement first direction")
            call RapidFireProbe___Check(s__GroundCollision_trace(RapidFireProbe___cx2 , RapidFireProbe___cy2 , RapidFireProbe___cx1 , RapidFireProbe___cy1 , 24. , s__RapidPair_actor[RapidFireProbe___p] , Player(0) , false) == 1 , "authored cliff blocks swept movement reverse direction")
            call RapidFireProbe___Advance(13)
        else
            set RapidFireProbe___cliffIndex=RapidFireProbe___cliffIndex + 1
            if RapidFireProbe___cliffIndex >= 21 then
                call RapidFireProbe___Check(false , "positive authored cliff coverage was not found")
                call RapidFireProbe___Advance(13)
            endif
        endif
    elseif RapidFireProbe___stage == 13 then
        call RapidFireProbe___Note("RAMP heights=" + R2S(s__GroundCollision_height(- 1600. , - 4992.)) + "," + R2S(s__GroundCollision_height(- 1344. , - 4992.)))
        call RapidFireProbe___Check(RAbsBJ(s__GroundCollision_height(- 1600. , - 4992.) - s__GroundCollision_height(- 1344. , - 4992.)) > 64. , "authored ramp has real elevation change")
        call RapidFireProbe___Check(s__GroundCollision_trace(- 1600. , - 4992. , - 1344. , - 4992. , 24. , s__RapidPair_actor[RapidFireProbe___p] , Player(0) , false) == 0 , "authored descending ramp remains walkable")
        call RapidFireProbe___Check(s__GroundCollision_trace(- 1344. , - 4992. , - 1600. , - 4992. , 24. , s__RapidPair_actor[RapidFireProbe___p] , Player(0) , false) == 0 , "authored ascending ramp remains walkable")
        call RapidFireProbe___Advance(14)
    elseif RapidFireProbe___stage == 14 then
        call SetTerrainPathable(RapidFireProbe___sx + 160., RapidFireProbe___sy, PATHING_TYPE_WALKABILITY, false)
        call RapidFireProbe___Check(IsTerrainPathable(RapidFireProbe___sx + 160., RapidFireProbe___sy, PATHING_TYPE_WALKABILITY) , "native wall pathing really blocked")
        call RapidFireProbe___Check(s__GroundCollision_trace(RapidFireProbe___sx , RapidFireProbe___sy , RapidFireProbe___sx + 320. , RapidFireProbe___sy , 24. , s__RapidPair_actor[RapidFireProbe___p] , Player(0) , false) == 1 and s__GroundCollision_x < RapidFireProbe___sx + 160. , "narrow pathing wall stops a segment spanning both sides")
        call SetTerrainPathable(RapidFireProbe___sx + 160., RapidFireProbe___sy, PATHING_TYPE_WALKABILITY, true)
        call RapidFireProbe___Check(not IsTerrainPathable(RapidFireProbe___sx + 160., RapidFireProbe___sy, PATHING_TYPE_WALKABILITY) , "native wall removed before endpoint test")
        call RapidFireProbe___Check(s__GroundCollision_trace(s__WorldBounds_maxX - 96. , s__WorldBounds_maxY - 96. , s__WorldBounds_maxX + 32. , s__WorldBounds_maxY + 32. , 24. , s__RapidPair_actor[RapidFireProbe___p] , Player(0) , false) == 1 , "world edge blocks movement")
        call RapidFireProbe___Reset()
        set RapidFireProbe___target=CreateUnit(Player(12), 'rftg', RapidFireProbe___sx + 450., RapidFireProbe___sy, 0.)
        call PauseUnit(RapidFireProbe___target, true)
        set RapidFireProbe___expectedHits=s__RapidBolt_hits
        call s__RapidBolt_shoot(s__RapidPair_actor[RapidFireProbe___p] , RapidFireProbe___sx + 450. , RapidFireProbe___sy)
        call RapidFireProbe___Advance(15)
    elseif RapidFireProbe___stage == 15 and elapsed > 0.6 then
        call RapidFireProbe___Check(s__RapidBolt_hits == RapidFireProbe___expectedHits + 1 and GetWidgetLife(RapidFireProbe___target) < 2000. , "target at final missile endpoint is not skipped")
        call RemoveUnit(RapidFireProbe___target)
        call RapidFireProbe___Save("COMPLETE")
        call PauseTimer(RapidFireProbe___t)
        call DestroyTimer(RapidFireProbe___t)
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 30., "RAPID TEST COMPLETE checks=" + I2S(RapidFireProbe___checks) + " failures=" + I2S(RapidFireProbe___failures))
    endif
    set body=null
endfunction
function RapidFireProbe___Begin takes nothing returns nothing
    call RapidFireProbe___Note("BEGIN timer=" + I2S(GetHandleId(RapidFireProbe___t)) + " clock=" + R2S((TimerGetElapsed(s__RapidPair_clock)))) // INLINED!!
    call RapidFireProbe___Save("BEGIN")
    set RapidFireProbe___since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
    set RapidFireProbe___t=CreateTimer()
    call TimerStart(RapidFireProbe___t, 1. / 32., true, function RapidFireProbe___Tick)
    call RapidFireProbe___Note("AFTER START timer=" + I2S(GetHandleId(RapidFireProbe___t)) + " timeout=" + R2S(TimerGetTimeout(RapidFireProbe___t)) + " expired=" + I2S(GetHandleId(GetExpiredTimer())))
    call RapidFireProbe___Save("STARTED")
    call DestroyTimer(GetExpiredTimer())
endfunction
function RapidFireProbe___Queue takes nothing returns nothing
    call TimerStart(CreateTimer(), 0.03125, false, function RapidFireProbe___Begin)
endfunction
function RapidFireProbe___Init takes nothing returns nothing
    local trigger l__RapidFireProbe___t= CreateTrigger()
    call TriggerRegisterPlayerChatEvent(l__RapidFireProbe___t, Player(0), "-rapid", true)
    call TriggerAddAction(l__RapidFireProbe___t, function RapidFireProbe___Queue)
    set l__RapidFireProbe___t=null
endfunction

function ShotColorProbe__Check takes boolean value,string message returns nothing
    if value then
        set ShotColorProbe__lines[ShotColorProbe__checks]="PASS " + message
    else
        set ShotColorProbe__lines[ShotColorProbe__checks]="FAIL " + message
        set ShotColorProbe__failures=ShotColorProbe__failures + 1
    endif
    set ShotColorProbe__checks=ShotColorProbe__checks + 1
endfunction
function ShotColorProbe__Clear takes nothing returns nothing
    loop
        exitwhen ShotColorProbe__displays == 0
        set ShotColorProbe__displays=ShotColorProbe__displays - 1
        call DestroyEffect(ShotColorProbe__displayEffect[ShotColorProbe__displays])
        call RemoveUnit(ShotColorProbe__displayUnit[ShotColorProbe__displays])
        call DestroyTextTag(ShotColorProbe__label[ShotColorProbe__displays])
        set ShotColorProbe__displayEffect[ShotColorProbe__displays]=null
        set ShotColorProbe__displayUnit[ShotColorProbe__displays]=null
        set ShotColorProbe__label[ShotColorProbe__displays]=null
    endloop
    loop
        exitwhen ShotColorProbe__rings == 0
        set ShotColorProbe__rings=ShotColorProbe__rings - 1
        call DestroyLightning(ShotColorProbe__ring[ShotColorProbe__rings])
        set ShotColorProbe__ring[ShotColorProbe__rings]=null
    endloop
endfunction
function ShotColorProbe__Display takes real x,real y,playercolor color,real scale,string text,boolean marker returns nothing
    local integer i= 0
    local real a
    local real b
    local real z= s__GroundCollision_height(x , y) + 70.
    set ShotColorProbe__displayUnit[ShotColorProbe__displays]=CreateUnit(Player(0), 'dumi', x, y, 0.)
    call SetUnitX(ShotColorProbe__displayUnit[ShotColorProbe__displays], x)
    call SetUnitY(ShotColorProbe__displayUnit[ShotColorProbe__displays], y)
    call SetUnitFlyHeight(ShotColorProbe__displayUnit[ShotColorProbe__displays], 70., 0.)
    call SetUnitScale(ShotColorProbe__displayUnit[ShotColorProbe__displays], scale, scale, scale)
    set ShotColorProbe__displayEffect[ShotColorProbe__displays]=AddSpecialEffectTarget(s__RapidBolt_modelForColor(color), ShotColorProbe__displayUnit[ShotColorProbe__displays], "origin")
    set ShotColorProbe__label[ShotColorProbe__displays]=CreateTextTag()
    call SetTextTagText(ShotColorProbe__label[ShotColorProbe__displays], text, 0.022)
    call SetTextTagPos(ShotColorProbe__label[ShotColorProbe__displays], x - 55., y + 48., 75.)
    set ShotColorProbe__displays=ShotColorProbe__displays + 1
    if marker then
        loop
            exitwhen i == 24
            set a=I2R(i) * bj_PI / 12.
            set b=I2R(i + 1) * bj_PI / 12.
            set ShotColorProbe__ring[ShotColorProbe__rings]=AddLightningEx("DRAL", false, x + 16. * Cos(a), y + 16. * Sin(a), z, x + 16. * Cos(b), y + 16. * Sin(b), z)
            call SetLightningColor(ShotColorProbe__ring[ShotColorProbe__rings], 1., 1., 1., 0.8)
            set ShotColorProbe__rings=ShotColorProbe__rings + 1
            set i=i + 1
        endloop
    endif
endfunction
function ShotColorProbe__Camera takes nothing returns nothing
    call SetCameraTargetController(null, 0., 0., false)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 1650., 0.)
    call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 295., 0.)
    call PanCameraToTimed(- 4310., 3040., 0.)
    call FogEnable(false)
    call FogMaskEnable(false)
    call SetTimeOfDay(12.)
    call SuspendTimeOfDay(true)
    call MultiboardDisplay(s__MissileStats_board, false)
    call ClearTextMessages()
endfunction
function ShotColorProbe__Calibrate takes nothing returns nothing
    call ShotColorProbe__Clear()
    call ShotColorProbe__Camera()
    call ShotColorProbe__Display(- 4400. , 3260. , PLAYER_COLOR_CYAN , 1. , "1.00 x" , true)
    call ShotColorProbe__Display(- 4400. , 3040. , PLAYER_COLOR_CYAN , 1.5 , "1.50 x" , true)
    call ShotColorProbe__Display(- 4400. , 2820. , PLAYER_COLOR_CYAN , 2.7434842 , "2.74 x" , true)
    call DisplayTimedTextToPlayer(Player(0), 0., 0., 60., "CALIBRACION: circulo radio16 en el origen/punta; estela hacia atras. Grosor del cuerpo, halo y Death son distintos.")
endfunction
function ShotColorProbe__Palette takes nothing returns nothing
    local integer i= 0
    call ShotColorProbe__Clear()
    call ShotColorProbe__Camera()
    loop
        exitwhen i == 12
        call ShotColorProbe__Display(- 4670. + I2R(ModuloInteger(i, 3)) * 340. , 3340. - I2R(i / 3) * 190. , ConvertPlayerColor(i) , s__RapidBolt_VISUAL_SCALE , I2S(i) , false)
        set i=i + 1
    endloop
    call DisplayTimedTextToPlayer(Player(0), 0., 0., 60., "PALETA CLASSIC: 0 rojo,1 azul,2 cian,3 purpura,4 amarillo,5 naranja,6 verde,7 rosa,8 gris,9 azul claro,10 aqua,11 marron.")
endfunction
function ShotColorProbe__Save takes nothing returns nothing
    local integer i= 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("COLOR 20261022-202306 COMPLETE")
    loop
        exitwhen i == ShotColorProbe__checks
        call Preload(ShotColorProbe__lines[i])
        set i=i + 1
    endloop
    call Preload("checks=" + I2S(ShotColorProbe__checks) + " failures=" + I2S(ShotColorProbe__failures) + " live=" + I2S(s__RapidBolt_live) + " created=" + I2S(s__MissileStats_created) + " retired=" + I2S(s__MissileStats_retired) + " scale=" + R2S(s__RapidBolt_VISUAL_SCALE))
    call PreloadGenEnd("Logs\\TerrainDev-20261022-202306-colors.txt")
endfunction
function ShotColorProbe__Tick takes nothing returns nothing
    local real elapsed= (TimerGetElapsed(s__RapidPair_clock)) - ShotColorProbe__since // INLINED!!
    if ShotColorProbe__stage == 1 and elapsed >= 0.25 then
        call ShotColorProbe__Check(s__RapidBolt_live == 0 , "all twelve direct shots retired")
        call SetPlayerColor(Player(0), PLAYER_COLOR_ORANGE)
        set ShotColorProbe__prior=s__RapidBolt_shoot(s__RapidPair_actor[ShotColorProbe__p] , - 3800. , 3024.)
        call ShotColorProbe__Check((s__Missile_path[(ShotColorProbe__prior)]) == ShotColorProbe__expected[5] , "owner color differs from player slot") // INLINED!!
        set s__Missile_wantDestroy[(ShotColorProbe__prior)]=true // INLINED!!
        call s__RapidPair_setColor(ShotColorProbe__p,PLAYER_COLOR_RED)
        call s__RapidPair_cast(ShotColorProbe__p,- 3800. , 3024.)
        set ShotColorProbe__prior=s__RapidPair_lastMissile[ShotColorProbe__p]
        call ShotColorProbe__Check((s__Missile_path[(ShotColorProbe__prior)]) == ShotColorProbe__expected[0] , "explicit red override wins over orange owner") // INLINED!!
        set ShotColorProbe__since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
        set ShotColorProbe__stage=2
    elseif ShotColorProbe__stage == 2 and elapsed >= 0.125 then
        set ShotColorProbe__nextTime=s__RapidPair_nextShot[ShotColorProbe__p]
        set ShotColorProbe__countBefore=s__RapidPair_emitted
        call s__RapidPair_setColor(ShotColorProbe__p,PLAYER_COLOR_PINK)
        call s__RapidPair_cast(ShotColorProbe__p,- 3800. , 3024.)
        call ShotColorProbe__Check(s__RapidPair_pending[ShotColorProbe__p] == 6 and s__RapidPair_nextShot[ShotColorProbe__p] == ShotColorProbe__nextTime and s__RapidPair_emitted == ShotColorProbe__countBefore , "colored recast preserves next shot and replenishes six")
        set ShotColorProbe__stage=3
    elseif ShotColorProbe__stage == 3 and elapsed >= 0.28125 then
        call ShotColorProbe__Check((s__Missile_path[(s__RapidPair_lastMissile[ShotColorProbe__p])]) == ShotColorProbe__expected[7] , "next recast shot uses updated override") // INLINED!!
        call ShotColorProbe__Check(s__Missile_allocated[ShotColorProbe__prior] and (s__Missile_path[(ShotColorProbe__prior)]) == ShotColorProbe__expected[0] , "flying shot keeps previous red color") // INLINED!!
        call SetPlayerColor(Player(0), PLAYER_COLOR_YELLOW)
        call s__RapidPair_clearColor(ShotColorProbe__p)
        call s__RapidPair_cast(ShotColorProbe__p,- 3800. , 3024.)
        set ShotColorProbe__since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
        set ShotColorProbe__stage=4
    elseif ShotColorProbe__stage == 4 and elapsed >= 0.28125 then
        call ShotColorProbe__Check((s__Missile_path[(s__RapidPair_lastMissile[ShotColorProbe__p])]) == ShotColorProbe__expected[4] , "cleared override follows changed owner color") // INLINED!!
        call s__RapidPair_setColor(ShotColorProbe__p,PLAYER_COLOR_GREEN)
        call s__RapidPair_cast(ShotColorProbe__p,- 3800. , 3024.)
        set ShotColorProbe__since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
        set ShotColorProbe__stage=5
    elseif ShotColorProbe__stage == 5 and elapsed >= 0.28125 then
        call ShotColorProbe__Check((s__Missile_path[(s__RapidPair_lastMissile[ShotColorProbe__p])]) == ShotColorProbe__expected[6] , "explicit team color overrides player color") // INLINED!!
        call SetPlayerColor(Player(1), PLAYER_COLOR_PURPLE)
        call SetUnitOwner(s__RapidPair_actor[ShotColorProbe__p], Player(1), true)
        call s__RapidPair_clearColor(ShotColorProbe__p)
        call s__RapidPair_cast(ShotColorProbe__p,- 3800. , 3024.)
        set ShotColorProbe__since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
        set ShotColorProbe__stage=6
    elseif ShotColorProbe__stage == 6 and elapsed >= 0.28125 then
        call ShotColorProbe__Check((s__Missile_path[(s__RapidPair_lastMissile[ShotColorProbe__p])]) == ShotColorProbe__expected[3] , "changed owner selects its current color") // INLINED!!
        call ShotColorProbe__Check(RAbsBJ((s__Missile_scaling[(s__RapidPair_lastMissile[ShotColorProbe__p])]) - s__RapidBolt_VISUAL_SCALE) < 0.0001 , "scale applied on reused projectile dummy") // INLINED!!
        call ShotColorProbe__Check(s__RapidPair_minInterval >= 0.249 , "color changes do not shorten firing interval")
        call SetUnitOwner(s__RapidPair_actor[ShotColorProbe__p], Player(0), true)
        call SetPlayerColor(Player(0), PLAYER_COLOR_RED)
        call SetPlayerColor(Player(1), PLAYER_COLOR_BLUE)
        call s__RapidPair_clearColor(ShotColorProbe__p)
        set ShotColorProbe__since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
        set ShotColorProbe__stage=7
    elseif ShotColorProbe__stage == 7 and elapsed >= 4. then
        call ShotColorProbe__Check(not s__RapidPair_firing[ShotColorProbe__p] and s__RapidPair_pending[ShotColorProbe__p] == 0 and s__RapidBolt_live == 0 , "burst finishes with zero pending/live")
        call ShotColorProbe__Check(s__MissileStats_created == s__MissileStats_retired , "all real missile instances retired")
        // Do not leave a collidable demo actor at the next laboratory's spawn.
        call SetUnitPosition(s__RapidPair_actor[ShotColorProbe__p], ShotColorProbe__originalX, ShotColorProbe__originalY)
        call IssueImmediateOrder(s__RapidPair_actor[ShotColorProbe__p], "stop")
        call ShotColorProbe__Save()
        call PauseTimer(ShotColorProbe__ticker)
        call ClearTextMessages()
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 60., "COLOR COMPLETE: " + I2S(ShotColorProbe__checks) + " checks / " + I2S(ShotColorProbe__failures) + " failures. -palette / -calibrate")
    endif
endfunction
function ShotColorProbe__Tests takes nothing returns nothing
    local integer i= 0
    local integer m
    if ShotColorProbe__stage != 0 then
        return
    endif
    set ShotColorProbe__p=s__RapidDemo_pair
    set ShotColorProbe__originalX=GetUnitX(s__RapidPair_actor[ShotColorProbe__p])
    set ShotColorProbe__originalY=GetUnitY(s__RapidPair_actor[ShotColorProbe__p])
    call SetUnitPosition(s__RapidPair_actor[ShotColorProbe__p], - 4700., 3024.)
    call IssueImmediateOrder(s__RapidPair_actor[ShotColorProbe__p], "stop")
    loop
        exitwhen i == 12
        call SetPlayerColor(Player(0), ConvertPlayerColor(i))
        set m=s__RapidBolt_shoot(s__RapidPair_actor[ShotColorProbe__p] , - 3800. , 3024.)
        call ShotColorProbe__Check((s__Missile_path[(m)]) == ShotColorProbe__expected[i] , "model for owner color " + I2S(i)) // INLINED!!
        call ShotColorProbe__Check(RAbsBJ((s__Missile_scaling[(m)]) - s__RapidBolt_VISUAL_SCALE) < 0.0001 , "scale for owner color " + I2S(i)) // INLINED!!
        set s__Missile_wantDestroy[(m)]=true // INLINED!!
        set i=i + 1
    endloop
    call ShotColorProbe__Check(PLAYER_COLOR_RED == null and s__RapidBolt_modelForColor(PLAYER_COLOR_RED) == ShotColorProbe__expected[0] , "Classic red enum0 remains a valid explicit color")
    call ShotColorProbe__Check(s__RapidBolt_modelForColor(ConvertPlayerColor(12)) == ShotColorProbe__expected[8] , "neutral color fallback gray")
    call ShotColorProbe__Check(s__RapidBolt_HIT_RADIUS == 16. , "collision radius unchanged")
    set ShotColorProbe__stage=1
    set ShotColorProbe__since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
    call TimerStart(ShotColorProbe__ticker, 1. / 32., true, function ShotColorProbe__Tick)
endfunction
function ShotColorProbe__Init takes nothing returns nothing
    local trigger a= CreateTrigger()
    local trigger b= CreateTrigger()
    local trigger c= CreateTrigger()
    set ShotColorProbe__expected[0]="ShotsTeam\\Shot_00_Red.mdx"
    set ShotColorProbe__expected[1]="ShotsTeam\\Shot_01_Blue.mdx"
    set ShotColorProbe__expected[2]="ShotsTeam\\Shot_02_Cyan.mdx"
    set ShotColorProbe__expected[3]="ShotsTeam\\Shot_03_Purple.mdx"
    set ShotColorProbe__expected[4]="ShotsTeam\\Shot_04_Yellow.mdx"
    set ShotColorProbe__expected[5]="ShotsTeam\\Shot_05_Orange.mdx"
    set ShotColorProbe__expected[6]="ShotsTeam\\Shot_06_Green.mdx"
    set ShotColorProbe__expected[7]="ShotsTeam\\Shot_07_Pink.mdx"
    set ShotColorProbe__expected[8]="ShotsTeam\\Shot_08_LightGray.mdx"
    set ShotColorProbe__expected[9]="ShotsTeam\\Shot_09_LightBlue.mdx"
    set ShotColorProbe__expected[10]="ShotsTeam\\Shot_10_Aqua.mdx"
    set ShotColorProbe__expected[11]="ShotsTeam\\Shot_11_Brown.mdx"
    call TriggerRegisterPlayerChatEvent(a, Player(0), "-calibrate", true)
    call TriggerAddAction(a, function ShotColorProbe__Calibrate)
    call TriggerRegisterPlayerChatEvent(b, Player(0), "-palette", true)
    call TriggerAddAction(b, function ShotColorProbe__Palette)
    call TriggerRegisterPlayerChatEvent(c, Player(0), "-testcolors", true)
    call TriggerAddAction(c, function ShotColorProbe__Tests)
    set a=null
    set b=null
    set c=null
endfunction

function X3BusterDemo___Cast takes nothing returns nothing
    local integer pair= (LoadInteger(Table__ht, (s__RapidPair_controls), (GetHandleId((GetTriggerUnit()))))) // INLINED!!
    local integer shot
    local integer mode= 0
    if pair != 0 then
        if GetSpellAbilityId() == 'Ax3s' then
            set mode=1
        endif
        set shot=s__X3Buster_fire(s__RapidPair_actor[pair] , GetSpellTargetX() , GetSpellTargetY() , mode)
        if not s__RapidPair_firing[pair] then
            call SetUnitFacingTimed(s__RapidPair_actor[pair], Atan2(GetSpellTargetY() - GetUnitY(s__RapidPair_actor[pair]), GetSpellTargetX() - GetUnitX(s__RapidPair_actor[pair])) * bj_RADTODEG, 0.)
            call SetUnitAnimation(s__RapidPair_actor[pair], "attack")
        endif
    endif
endfunction
function X3BusterDemo___Init takes nothing returns nothing
    call RegisterSpellEffectEvent('Ax3c' , function X3BusterDemo___Cast)
    call RegisterSpellEffectEvent('Ax3s' , function X3BusterDemo___Cast)
endfunction

function X3Probe__Check takes boolean value,string label returns nothing
    set X3Probe__lines[X3Probe__checks]="PASS " + label
    if not value then
        set X3Probe__lines[X3Probe__checks]="FAIL " + label
        set X3Probe__failures=X3Probe__failures + 1
    endif
    set X3Probe__checks=X3Probe__checks + 1
endfunction
function X3Probe__Save takes string status returns nothing
    local integer i= 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("X3 20261022-202306 " + status)
    loop
        exitwhen i == X3Probe__checks
        call Preload(X3Probe__lines[i])
        set i=i + 1
    endloop
    call Preload("checks=" + I2S(X3Probe__checks) + " failures=" + I2S(X3Probe__failures) + " casts=" + I2S(s__X3Buster_live) + " live=" + I2S(s__X3Buster_projectiles) + " created=" + I2S(s__X3Buster_created) + " retired=" + I2S(s__X3Buster_retired) + " fusions=" + I2S(s__X3Buster_fusions) + " flashes=" + I2S((s__X3Buster__X3Flash_live))) // INLINED!!
    call PreloadGenEnd("Logs\\TerrainDev-20261022-202306-x3.txt")
endfunction
function X3Probe__Advance takes integer nextStage returns nothing
    set X3Probe__stage=nextStage
    set X3Probe__since=(TimerGetElapsed(s__X3Buster_clock)) // INLINED!!
    set X3Probe__one=false
    call X3Probe__Save("PROGRESS " + I2S(X3Probe__stage))
endfunction
function X3Probe__Tick takes nothing returns nothing
    local real elapsed= (TimerGetElapsed(s__X3Buster_clock)) - X3Probe__since // INLINED!!
    local real gy
    local real oy
    local integer i
    local integer c
    if X3Probe__stage == 0 then
        if s__GroundCollision_trace(X3Probe__sx , X3Probe__sy , X3Probe__sx + 850. , X3Probe__sy , 78. , null , Player(0) , false) == 0 then
            set X3Probe__source=CreateUnit(Player(0), 'rfex', X3Probe__sx, X3Probe__sy, 0.)
            call X3Probe__Check(true , "real unobstructed lane found")
            set X3Probe__shot=s__X3Buster_fire(X3Probe__source , X3Probe__sx + 1400. , X3Probe__sy , 0)
            call X3Probe__Check(X3Probe__shot != 0 and s__X3Buster_bodies[X3Probe__shot] == 1 , "charged shot creates one body")
            call X3Probe__Check((s__Missile_path[(s__X3Buster_pulse[X3Probe__shot])]) == "X3Buster\\X3_Buster_Cargado.mdx" , "charged model A selected") // INLINED!!
            call X3Probe__Check(RAbsBJ((s__Missile_scaling[(s__X3Buster_pulse[X3Probe__shot])]) - 1.) < 0.001 , "charged width58 matches radius29") // INLINED!!
            call X3Probe__Advance(1)
        else
            set X3Probe__search=X3Probe__search + 1
            set X3Probe__sy=X3Probe__sy - 160.
            if X3Probe__search == 35 then
                call X3Probe__Check(false , "real unobstructed lane found")
                call X3Probe__Save("COMPLETE")
                call PauseTimer(X3Probe__ticker)
            endif
        endif
    elseif X3Probe__stage == 1 and elapsed >= 0.2 then
        call X3Probe__Check(s__Missile_x[s__X3Buster_pulse[X3Probe__shot]] > X3Probe__sx + 180. and s__Missile_x[s__X3Buster_pulse[X3Probe__shot]] < X3Probe__sx + 310. , "charged advances at1100 per second")
        call X3Probe__Check(RAbsBJ(s__Missile_y[s__X3Buster_pulse[X3Probe__shot]] - X3Probe__sy) < 0.01 , "charged flight remains straight")
        call X3Probe__Check(RAbsBJ(GetUnitX(X3Probe__source) - X3Probe__sx) < 0.01 , "physics does not move caster")
        call s__X3Buster_cancel(X3Probe__shot)
        call X3Probe__Advance(2)
    elseif X3Probe__stage == 2 and elapsed >= 0.125 then
        call X3Probe__Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 , "cancel retires charged body and cast")
        set X3Probe__baseline=s__X3Buster_fusions
        set X3Probe__births=s__X3Buster_created
        set X3Probe__satelliteBase=s__X3Buster_satellites
        set X3Probe__shot=s__X3Buster_fire(X3Probe__source , X3Probe__sx + 1400. , X3Probe__sy , 1)
        call X3Probe__Check(s__X3Buster_bodies[X3Probe__shot] == 2 and s__X3Buster_pulse[X3Probe__shot] == 0 and s__X3Buster_waiting[X3Probe__shot] , "two orbs precede delayed pulse")
        call X3Probe__Advance(3)
    elseif X3Probe__stage == 3 then
        if elapsed >= 0.125 and not X3Probe__one then
            set X3Probe__one=true
            set gy=GetUnitY(s__Missile_dummy[s__X3Buster_green[X3Probe__shot]])
            set oy=GetUnitY(s__Missile_dummy[s__X3Buster_orange[X3Probe__shot]])
            call X3Probe__Check(RAbsBJ(gy - oy) > 1. , "two bodies orbit independently in XY")
            call X3Probe__Check(RAbsBJ(gy + oy - 2. * X3Probe__sy) < 0.1 , "orb offsets remain opposite")
            call X3Probe__Check(GetUnitFlyHeight(s__Missile_dummy[s__X3Buster_green[X3Probe__shot]]) > GetUnitFlyHeight(s__Missile_dummy[s__X3Buster_orange[X3Probe__shot]]) + 1. , "orbit includes opposite height offsets")
            call X3Probe__Check(s__X3Buster_pulse[X3Probe__shot] == 0 , "no early second pulse")
        endif
        if elapsed >= 0.32 then
            call X3Probe__Check(s__X3Buster_pulse[X3Probe__shot] != 0 and s__Missile_x[s__X3Buster_pulse[X3Probe__shot]] < s__Missile_x[s__X3Buster_green[X3Probe__shot]] , "second pulse launches behind orbs")
            call X3Probe__Check(s__X3Buster_fusions == X3Probe__baseline , "separation alone cannot trigger fusion")
            call X3Probe__Advance(4)
        endif
    elseif X3Probe__stage == 4 and elapsed >= 0.35 then
        call X3Probe__Check(s__X3Buster_state[X3Probe__shot] == 2 and s__X3Buster_fusions == X3Probe__baseline + 1 , "catching pulse produces exactly one fusion")
        call X3Probe__Check(s__X3Buster_green[X3Probe__shot] == 0 and s__X3Buster_orange[X3Probe__shot] == 0 and s__X3Buster_pulse[X3Probe__shot] == 0 , "three precursor bodies retired after union")
        call X3Probe__Check(s__X3Buster_fused[X3Probe__shot] != 0 and (s__Missile_path[(s__X3Buster_fused[X3Probe__shot])]) == "X3Buster\\X3_Cross_Buster.mdx" , "union produces model C") // INLINED!!
        call X3Probe__Check(s__X3Buster_satellites == X3Probe__satelliteBase + 4 , "union emits four satellites")
        call X3Probe__Check(s__X3Buster_created == X3Probe__births + 8 , "bounded emission budget eight bodies per super shot")
        call X3Probe__Check(s__X3Buster_lastFusionX > X3Probe__sx + 300. and s__X3Buster_lastFusionX < X3Probe__sx + 430. , "fusion occurs at actual catch location")
        call X3Probe__Check(s__X3Buster_lastFusionAge > 0.48 and s__X3Buster_lastFusionAge < 0.68 , "catch timing matches relative speeds")
        call X3Probe__Check(s__Missile_y[s__X3Buster_sat1[X3Probe__shot]] < s__Missile_y[s__X3Buster_sat4[X3Probe__shot]] , "satellites separate in a fan")
        call X3Probe__Advance(5)
    elseif X3Probe__stage == 5 and elapsed >= 1.7 then
        call X3Probe__Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 , "complete super shot leaves no active bodies")
        call X3Probe__Check((s__X3Buster__X3Flash_live) == 0 , "union flash cleans up its own timer and dummy") // INLINED!!
        call X3Probe__Check(s__X3Buster_created == s__X3Buster_retired , "all emitted bodies retired exactly once")
        set X3Probe__baseline=s__X3Buster_fusions
        set X3Probe__shot=s__X3Buster_fire(X3Probe__source , X3Probe__sx + 1400. , X3Probe__sy , 2)
        call X3Probe__Advance(6)
    elseif X3Probe__stage == 6 and elapsed >= 0.16 then
        call X3Probe__Check(s__X3Buster_pulse[X3Probe__shot] == 0 and s__X3Buster_waiting[X3Probe__shot] , "manual API waits for release")
        call X3Probe__Check(s__X3Buster_releasePulse(X3Probe__shot) , "manual release emits one pulse")
        call X3Probe__Check(not s__X3Buster_releasePulse(X3Probe__shot) , "duplicate release is rejected")
        call X3Probe__Advance(7)
    elseif X3Probe__stage == 7 and elapsed >= 0.5 then
        call X3Probe__Check(s__X3Buster_fusions == X3Probe__baseline + 1 , "manual second pulse can fuse")
        call s__X3Buster_cancel(X3Probe__shot)
        call X3Probe__Advance(8)
    elseif X3Probe__stage == 8 and elapsed >= 0.125 then
        set X3Probe__baseline=s__X3Buster_fusions
        set X3Probe__shot=s__X3Buster_fire(X3Probe__source , X3Probe__sx + 1400. , X3Probe__sy , 1)
        set s__Missile_wantDestroy[(s__X3Buster_green[X3Probe__shot])]=true // INLINED!!
        call X3Probe__Advance(9)
    elseif X3Probe__stage == 9 and elapsed >= 0.8 then
        call X3Probe__Check(s__X3Buster_fusions == X3Probe__baseline and s__X3Buster_fused[X3Probe__shot] == 0 , "missing orb prevents fusion")
        call s__X3Buster_cancel(X3Probe__shot)
        call X3Probe__Advance(10)
    elseif X3Probe__stage == 10 and elapsed >= 0.125 then
        set X3Probe__baseline=s__X3Buster_fusions
        set X3Probe__hitBase=s__X3Buster_hits
        set X3Probe__target=CreateUnit(Player(12), 'rftg', X3Probe__sx + 120., X3Probe__sy, 180.)
        set X3Probe__shot=s__X3Buster_fire(X3Probe__source , X3Probe__sx + 1400. , X3Probe__sy , 1)
        call X3Probe__Advance(11)
    elseif X3Probe__stage == 11 and elapsed >= 0.9 then
        call X3Probe__Check(s__X3Buster_hits > X3Probe__hitBase and GetWidgetLife(X3Probe__target) < 2000. , "real enemy collision applies damage")
        call X3Probe__Check(s__X3Buster_fusions == X3Probe__baseline , "enemy impact before union prevents fusion")
        call RemoveUnit(X3Probe__target)
        set X3Probe__target=null
        call s__X3Buster_cancel(X3Probe__shot)
        call X3Probe__Advance(12)
    elseif X3Probe__stage == 12 and elapsed >= 0.125 then
        set X3Probe__baseline=s__X3Buster_fusions
        set X3Probe__wallBase=s__X3Buster_walls
        set X3Probe__tree=CreateDestructable('LTlt', X3Probe__sx + 130., X3Probe__sy, 0., 1., 0)
        set X3Probe__shot=s__X3Buster_fire(X3Probe__source , X3Probe__sx + 1400. , X3Probe__sy , 1)
        call X3Probe__Advance(13)
    elseif X3Probe__stage == 13 and elapsed >= 0.9 then
        call X3Probe__Check(s__X3Buster_walls > X3Probe__wallBase , "real destructible blocks projectile sweeps")
        call X3Probe__Check(s__X3Buster_fusions == X3Probe__baseline , "obstacle before union prevents fusion")
        call RemoveDestructable(X3Probe__tree)
        set X3Probe__tree=null
        call s__X3Buster_cancel(X3Probe__shot)
        call X3Probe__Advance(14)
    elseif X3Probe__stage == 14 and elapsed >= 0.125 then
        set X3Probe__baseline=s__X3Buster_fusions
        set X3Probe__shot=s__X3Buster_fire(X3Probe__source , X3Probe__sx + 1400. , X3Probe__sy , 1)
        set X3Probe__second=s__X3Buster_fire(X3Probe__source , X3Probe__sx + 1400. , X3Probe__sy , 1)
        call X3Probe__Advance(15)
    elseif X3Probe__stage == 15 and elapsed >= 0.75 then
        call X3Probe__Check(s__X3Buster_fusions == X3Probe__baseline + 2 , "simultaneous casts fuse only their own components")
        call X3Probe__Check(s__X3Buster_fused[X3Probe__shot] != s__X3Buster_fused[X3Probe__second] and s__X3Buster_state[X3Probe__shot] == 2 and s__X3Buster_state[X3Probe__second] == 2 , "independent resulting missiles per cast")
        call s__X3Buster_cancel(X3Probe__shot)
        call s__X3Buster_cancel(X3Probe__second)
        call X3Probe__Advance(16)
    elseif X3Probe__stage == 16 and elapsed >= 0.125 then
        call SetUnitFacing(X3Probe__source, 90.)
        set X3Probe__shot=s__X3Buster_fire(X3Probe__source , X3Probe__sx , X3Probe__sy , 0)
        call X3Probe__Check(RAbsBJ(s__X3Buster_angle[X3Probe__shot] - bj_PI / 2.) < 0.01 , "zero-distance aim falls back to unit facing")
        call s__X3Buster_cancel(X3Probe__shot)
        call X3Probe__Advance(17)
    elseif X3Probe__stage == 17 and elapsed >= 0.125 then
        set X3Probe__shot=s__X3Buster_fire(X3Probe__source , X3Probe__sx + 1400. , X3Probe__sy , 1)
        call RemoveUnit(X3Probe__source)
        set X3Probe__source=null
        call X3Probe__Advance(18)
    elseif X3Probe__stage == 18 and elapsed >= 0.2 then
        call X3Probe__Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 , "removed caster cancels pending and flying bodies")
        call X3Probe__Check(s__X3Buster_created == s__X3Buster_retired , "interrupted casts preserve balanced lifecycle")
        set X3Probe__source=CreateUnit(Player(0), 'rfex', X3Probe__sx, X3Probe__sy, 0.)
        set X3Probe__capIndex=0
        call X3Probe__Advance(19)
    elseif X3Probe__stage == 19 then
        set i=0
        loop
            exitwhen i == 4
            set X3Probe__capped[X3Probe__capIndex]=s__X3Buster_fire(X3Probe__source , X3Probe__sx + 1400. , X3Probe__sy , 2)
            set X3Probe__capIndex=X3Probe__capIndex + 1
            set i=i + 1
        endloop
        if X3Probe__capIndex < 64 then
            return
        endif
        set c=s__X3Buster_fire(X3Probe__source , X3Probe__sx + 1400. , X3Probe__sy , 2)
        call X3Probe__Check(c == 0 and s__X3Buster_live == 64 , "concurrent cast limit rejects overflow")
        set i=0
        loop
            exitwhen i == 64
            call s__X3Buster_cancel((X3Probe__capped[i]))
            set i=i + 1
        endloop
        call X3Probe__Advance(20)
    elseif X3Probe__stage == 20 and elapsed >= 0.5 then
        call X3Probe__Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 , "all capped and cancelled casts retire")
        call X3Probe__Check(s__X3Buster_created == s__X3Buster_retired , "final created equals retired")
        call X3Probe__Check((s__X3Buster__X3Flash_live) == 0 , "final flash count zero") // INLINED!!
        call RemoveUnit(X3Probe__source)
        set X3Probe__source=null
        call X3Probe__Save("COMPLETE")
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 60., "X3 COMPLETE " + I2S(X3Probe__checks) + " checks / " + I2S(X3Probe__failures) + " failures. -x3show para demostracion.")
        call PauseTimer(X3Probe__ticker)
        set X3Probe__stage=- 2
    endif
endfunction
function X3Probe__Begin takes nothing returns nothing
    if X3Probe__stage != - 1 then
        return
    endif
    set X3Probe__stage=0
    set X3Probe__since=(TimerGetElapsed(s__X3Buster_clock)) // INLINED!!
    call TimerStart(X3Probe__ticker, 1. / 32., true, function X3Probe__Tick)
endfunction
function X3Probe__Repeat takes nothing returns nothing
    local integer s= s__X3Buster_fire(X3Probe__source , X3Probe__sx + 1400. , X3Probe__sy , 1)
endfunction
function X3Probe__Show takes nothing returns nothing
    if X3Probe__stage != - 2 then
        return
    endif
    set X3Probe__source=CreateUnit(Player(0), 'rfex', X3Probe__sx, X3Probe__sy, 0.)
    call SetCameraTargetController(null, 0., 0., false)
    call PanCameraToTimed(X3Probe__sx + 450., X3Probe__sy, 0.)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 1350., 0.)
    call FogEnable(false)
    call FogMaskEnable(false)
    call SetTimeOfDay(12.)
    call SuspendTimeOfDay(true)
    call MultiboardDisplay(s__MissileStats_board, false)
    call ClearTextMessages()
    call TimerStart(X3Probe__showing, 2.5, true, function X3Probe__Repeat)
    call X3Probe__Repeat()
endfunction
function X3Probe__Init takes nothing returns nothing
    local trigger t= CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t, Player(0), "-x3test", true)
    call TriggerAddAction(t, function X3Probe__Begin)
    set t=CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t, Player(0), "-x3show", true)
    call TriggerAddAction(t, function X3Probe__Show)
    set t=null
endfunction





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

// TerrainDev local instrumentation, Classic 1.27b. See docs/planes/multiboard-misiles.md.
// Hooks only observe: never kill, unpause, move or recycle gameplay objects.



// TerrainDev Classic 1.27b. Hidden-item walkability technique: Rising_Dusk/BPower.
// Validates swept ground footprints; no mutation of actors or missile libraries.

// Separate movement authority. Does not use/modify Missile.createEx or its timer.



// Local Warcraft adaptation of the user-supplied X3 interaction, not SNES code.


// Laboratory only: never imported into the delivered editable sources.

// Engine laboratory, excluded from the delivered map.

// Engine laboratory only. The lane is selected from the real map, not flattened.



//===========================================================================
// 
// Swamped Temple_v2
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Date: Wed Oct 21 01:40:22 2026
//   Map Author: Kai Trausenegger / Anomines
// 
//===========================================================================

//***************************************************************************
//*
//*  Global Variables
//*
//***************************************************************************


function InitGlobals takes nothing returns nothing
endfunction

//***************************************************************************
//*
//*  Map Item Tables
//*
//***************************************************************************

function ItemTable000000_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('tdx2', 25)
        call RandomDistAddItem('tin2', 25)
        call RandomDistAddItem('tpow', 25)
        call RandomDistAddItem('tst2', 25)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction


//***************************************************************************
//*
//*  Unit Item Tables
//*
//***************************************************************************

function Unit000003_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000007_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000022_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000029_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000031_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000032_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000038_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('I000', 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000039_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('texp', 20)
        call RandomDistAddItem('tdx2', 20)
        call RandomDistAddItem('tin2', 20)
        call RandomDistAddItem('tpow', 20)
        call RandomDistAddItem('tst2', 20)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000043_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000046_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000048_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000054_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000055_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000056_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000067_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000068_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000070_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000072_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000077_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('tdx2', 25)
        call RandomDistAddItem('tin2', 25)
        call RandomDistAddItem('tpow', 25)
        call RandomDistAddItem('tst2', 25)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000079_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000080_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000081_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 2), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000083_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000084_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('tdx2', 25)
        call RandomDistAddItem('tin2', 25)
        call RandomDistAddItem('tpow', 25)
        call RandomDistAddItem('tst2', 25)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000085_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('rhe1', 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000090_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000095_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

function Unit000104_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true

    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif

    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif

    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 5), 100)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif

    endif

    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction


//***************************************************************************
//*
//*  Sounds
//*
//***************************************************************************

function InitSounds takes nothing returns nothing
    set gg_snd_WaterWaterFallLoop1=CreateSound("Sound\\Ambient\\DoodadEffects\\WaterWaterFallLoop1.wav", true, true, true, 30, 30, "DoodadsEAX")
    call SetSoundParamsFromLabel(gg_snd_WaterWaterFallLoop1, "WaterfallLoop")
    call SetSoundDuration(gg_snd_WaterWaterFallLoop1, 1022)
    call SetSoundVolume(gg_snd_WaterWaterFallLoop1, 127)
    set gg_snd_FreakyForest4=CreateSound("Sound\\Ambient\\Ashenvale\\FreakyForest4.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundParamsFromLabel(gg_snd_FreakyForest4, "FreakyForest4")
    call SetSoundDuration(gg_snd_FreakyForest4, 5248)
    call SetSoundVolume(gg_snd_FreakyForest4, 90)
endfunction

//***************************************************************************
//*
//*  Regions
//*
//***************************************************************************

function CreateRegions takes nothing returns nothing
    local weathereffect we

    set gg_rct_Region_001=Rect(- 3776.0, - 704.0, - 3136.0, - 32.0)
    set we=AddWeatherEffect(gg_rct_Region_001, 'LRma')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_000=Rect(- 1248.0, - 1600.0, 608.0, 256.0)
    set we=AddWeatherEffect(gg_rct_Region_000, 'FDwl')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_002=Rect(2208.0, 1984.0, 2528.0, 2272.0)
    set we=AddWeatherEffect(gg_rct_Region_002, 'LRaa')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_003=Rect(- 2656.0, - 5568.0, - 2240.0, - 5248.0)
    set we=AddWeatherEffect(gg_rct_Region_003, 'LRaa')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_004=Rect(- 5920.0, - 2272.0, - 4352.0, - 288.0)
    call SetSoundPosition(gg_snd_WaterWaterFallLoop1, - 5136.0, - 1280.0, 175.4)
    call RegisterStackedSound(gg_snd_WaterWaterFallLoop1, true, 1568.0, 1984.0)
    set gg_rct_Region_005=Rect(160.0, 384.0, 672.0, 896.0)
    set we=AddWeatherEffect(gg_rct_Region_005, 'FDwl')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_006=Rect(896.0, - 192.0, 1216.0, 64.0)
    set we=AddWeatherEffect(gg_rct_Region_006, 'FDwl')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_007=Rect(- 1568.0, - 480.0, - 1312.0, - 128.0)
    set we=AddWeatherEffect(gg_rct_Region_007, 'FDwl')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_008=Rect(2016.0, 1760.0, 2784.0, 2496.0)
    set we=AddWeatherEffect(gg_rct_Region_008, 'FDbl')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_008_Copy=Rect(2272.0, 2048.0, 3040.0, 2784.0)
    set we=AddWeatherEffect(gg_rct_Region_008_Copy, 'FDbh')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_010=Rect(- 2848.0, 5408.0, - 2752.0, 5472.0)
    set we=AddWeatherEffect(gg_rct_Region_010, 'LRma')
    call EnableWeatherEffect(we, true)
    set gg_rct_Region_003_Copy=Rect(- 5344.0, - 2880.0, - 4928.0, - 2560.0)
    set we=AddWeatherEffect(gg_rct_Region_003_Copy, 'LRaa')
    call EnableWeatherEffect(we, true)
endfunction

//***************************************************************************
//*
//*  Triggers
//*
//***************************************************************************

//===========================================================================
// Trigger: Melee Initialization
//
// Default melee game initialization for all players
//===========================================================================
function Trig_Melee_Initialization_Actions takes nothing returns nothing
    call MeleeStartingVisibility()
    call MeleeStartingHeroLimit()
    call MeleeGrantHeroItems()
    call MeleeStartingResources()
    call MeleeClearExcessUnits()
    call MeleeStartingUnits()
    call MeleeStartingAI()
    call MeleeInitVictoryDefeat()
endfunction

//===========================================================================
function InitTrig_Melee_Initialization takes nothing returns nothing
    set gg_trg_Melee_Initialization=CreateTrigger()
    call TriggerAddAction(gg_trg_Melee_Initialization, function Trig_Melee_Initialization_Actions)
    call DisableTrigger(gg_trg_Melee_Initialization)
endfunction

//===========================================================================
// Trigger: TurtleNet
//===========================================================================
function Trig_TurtleNet_Actions takes nothing returns nothing
endfunction

//===========================================================================
function InitTrig_TurtleNet takes nothing returns nothing
    set gg_trg_TurtleNet=CreateTrigger()
    call TriggerRegisterUnitEvent(gg_trg_TurtleNet, gg_unit_ntrd_0023, EVENT_UNIT_TARGET_IN_RANGE)
    call TriggerAddAction(gg_trg_TurtleNet, function Trig_TurtleNet_Actions)
endfunction

//===========================================================================
function InitCustomTriggers takes nothing returns nothing
    call InitTrig_Melee_Initialization()
    call InitTrig_TurtleNet()
endfunction

//===========================================================================
function RunInitializationTriggers takes nothing returns nothing
    // Melee initialization disabled for the Rapid Fire prototype.
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
    call SetPlayerRacePreference(Player(0), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(0), true)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)

    // Player 1
    call SetPlayerStartLocation(Player(1), 1)
    call SetPlayerColor(Player(1), ConvertPlayerColor(1))
    call SetPlayerRacePreference(Player(1), RACE_PREF_RANDOM)
    call SetPlayerRaceSelectable(Player(1), true)
    call SetPlayerController(Player(1), MAP_CONTROL_USER)

endfunction

function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_007
    call SetPlayerTeam(Player(0), 0)
    call SetPlayerTeam(Player(1), 0)

endfunction

function InitAllyPriorities takes nothing returns nothing

    call SetStartLocPrioCount(0, 1)
    call SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(1, 1)
    call SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
endfunction

//***************************************************************************
//*
//*  Main Initialization
//*
//***************************************************************************

//===========================================================================
function main takes nothing returns nothing
    call SetCameraBounds(- 27776.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 27776.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 6400.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 6144.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 27776.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 6144.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 6400.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 27776.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    call SetTerrainFogEx(0, 1900.0, 4000.0, 0.150, 1.000, 1.000, 0.000)
    call SetWaterBaseColor(0, 255, 255, 255)
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("SunkenRuinsDay")
    call SetAmbientNightSound("SunkenRuinsNight")
    call SetMapMusic("Music", true, 0)
    call InitSounds()
    call CreateRegions()
    call InitBlizzard()

    call ExecuteFunc("jasshelper__init5805")


    call ExecuteFunc("jasshelper__init3735")

    call InitGlobals()
    call InitCustomTriggers()
    // Melee initialization disabled for the Rapid Fire prototype.

endfunction

//***************************************************************************
//*
//*  Map Configuration
//*
//***************************************************************************

function config takes nothing returns nothing
    call SetMapName("TRIGSTR_001")
    call SetMapDescription("TRIGSTR_003")
    call SetPlayers(2)
    call SetTeams(2)
    call SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)

    call DefineStartLocation(0, - 5376.0, 2688.0)
    call DefineStartLocation(1, 2944.0, - 5696.0)

    // Player setup
    call InitCustomPlayerSlots()
    call SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(1), MAP_CONTROL_USER)
    call InitGenericPlayerSlots()
    call InitAllyPriorities()
endfunction




//All initializer functions called in proper order:

function jasshelper__init3735 takes nothing returns nothing



endfunction




//All initializer functions called in proper order:

//Functions for BigArrays:
function sa__X3Buster__X3Body_resolve takes nothing returns boolean
local integer m=f__arg_integer1
        local integer s= s__Missile_data[m]
        local real x= s__Missile_x[m]
        local real y= s__Missile_y[m]
        local real z= s__Missile_z[m]
        local real phase
        local real side
        local real radius= 29.
        local real damage= 75.
        local integer result
        local unit target
        if s__Missile_wantDestroy[m] or s__X3Buster__X3Body_blocked[m] then
set f__result_boolean= true
return true
        endif
        if s__X3Buster__X3Body_processed[m] == s__Missile_distance[m] then
set f__result_boolean= false
return true
        endif
        set s__X3Buster__X3Body_processed[m]=s__Missile_distance[m]
        if s__X3Buster__X3Body_kind[m] == 1 or s__X3Buster__X3Body_kind[m] == 2 then
            set phase=2. * bj_PI * s__X3Buster_ORBIT_HZ * s__Missile_distance[m] / s__X3Buster_ORBIT_SPEED
            if s__X3Buster__X3Body_kind[m] == 2 then
                set phase=phase + bj_PI
            endif
            set side=s__X3Buster_ORBIT_RADIUS * Cos(phase)
            set x=x - Sin(s__X3Buster_angle[s]) * side
            set y=y + Cos(s__X3Buster_angle[s]) * side
            set z=z + s__X3Buster_ORBIT_RADIUS * Sin(phase)
            set radius=12.65
            set damage=35.
        elseif s__X3Buster__X3Body_kind[m] == 4 then
            set radius=41.25
            set damage=150.
        elseif s__X3Buster__X3Body_kind[m] >= 5 then
            set radius=12.65
            set damage=25.
        endif
        set result=s__GroundCollision_trace(s__X3Buster__X3Body_lastX[m] , s__X3Buster__X3Body_lastY[m] , x , y , radius , s__X3Buster_caster[s] , s__X3Buster_owner[s] , true)
        set target=s__GroundCollision_hit
        if s__X3Buster__X3Body_kind[m] == 1 or s__X3Buster__X3Body_kind[m] == 2 then
            call SetUnitX(s__Missile_dummy[m], s__GroundCollision_x)
            call SetUnitY(s__Missile_dummy[m], s__GroundCollision_y)
            call SetUnitFlyHeight(s__Missile_dummy[m], RMaxBJ(0., z), 0.)
        endif
        set s__X3Buster__X3Body_lastX[m]=x
        set s__X3Buster__X3Body_lastY[m]=y
        if result == 0 and z < 0. then
            set result=1
        endif
        if result != 0 then
            set s__X3Buster__X3Body_blocked[m]=true
            call s__X3Buster_countHit(s,result)
            if result == 2 and GetUnitTypeId(s__X3Buster_caster[s]) != 0 then
                call UnitDamageTarget(s__X3Buster_caster[s], target, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif
        endif
        set target=null
set f__result_boolean= result != 0
   return true
endfunction
function sa__X3Buster__X3Body_spawn takes nothing returns boolean
local integer s=f__arg_integer1
local integer form=f__arg_integer2
local real x=f__arg_real1
local real y=f__arg_real2
local real facing=f__arg_real3
local real length=f__arg_real4
        local integer m= s__Missile_createXYZ(x , y , 70. , x + length * Cos(facing) , y + length * Sin(facing) , 70.)
        set s__Missile_data[m]=s
        set s__Missile_owner[m]=s__X3Buster_owner[s]
        set s__Missile_collision[m]=0.
        set s__X3Buster__X3Body_kind[m]=form
        set s__X3Buster__X3Body_processed[m]=- 1.
        set s__X3Buster__X3Body_blocked[m]=false
        set s__X3Buster__X3Body_lastX[m]=x
        set s__X3Buster__X3Body_lastY[m]=y
        if form == 1 or form == 2 or form >= 5 then
            if form == 1 or form == 5 or form == 8 then
                call s__Missile__set_model(m,"X3Buster\\X3_Orbe_Verde.mdx")
            else
                call s__Missile__set_model(m,"X3Buster\\X3_Orbe_Naranja.mdx")
            endif
            call s__Missile__set_scale(m,0.55)
            if form < 3 then
                set s__Missile_speed[(m)]=((s__X3Buster_ORBIT_SPEED)*1.0) * Missile_TIMER_TIMEOUT // INLINED!!
            else
                set s__Missile_speed[(m)]=((700.)*1.0) * Missile_TIMER_TIMEOUT // INLINED!!
            endif
        elseif form == 4 then
            call s__Missile__set_model(m,"X3Buster\\X3_Cross_Buster.mdx")
            call s__Missile__set_scale(m,1.)
            set s__Missile_speed[(m)]=((s__X3Buster_FUSED_SPEED)*1.0) * Missile_TIMER_TIMEOUT // INLINED!!
        else
            call s__Missile__set_model(m,"X3Buster\\X3_Buster_Cargado.mdx")
            call s__Missile__set_scale(m,1.)
            set s__Missile_speed[(m)]=((s__X3Buster_PULSE_SPEED)*1.0) * Missile_TIMER_TIMEOUT // INLINED!!
        endif
        call s__X3Buster_track(s,m)
        call s__X3Buster__X3Body_launch(m)
set f__result_integer= m
   return true
endfunction
function sa___prototype2_TimerUtils___init takes nothing returns boolean

     local integer i=0
     local integer o=- 1
     local boolean oops= false
        if ( TimerUtils___didinit ) then
    return true
        else
            set TimerUtils___didinit=true
        endif
            set TimerUtils___ht=InitHashtable()
            loop
                exitwhen ( i == TimerUtils___QUANTITY )
                set s__TimerUtils___tT[i]= CreateTimer()
                call SaveInteger(TimerUtils___ht, 0, GetHandleId((s__TimerUtils___tT[i] )), ( TimerUtils___HELD)) // INLINED!!
                set i=i + 1
            endloop
            set TimerUtils___tN=TimerUtils___QUANTITY
    return true
endfunction

function jasshelper__init5805 takes nothing returns nothing
    set st__X3Buster__X3Body_resolve=CreateTrigger()
    call TriggerAddCondition(st__X3Buster__X3Body_resolve,Condition( function sa__X3Buster__X3Body_resolve))
    set st__X3Buster__X3Body_spawn=CreateTrigger()
    call TriggerAddCondition(st__X3Buster__X3Body_spawn,Condition( function sa__X3Buster__X3Body_spawn))
    set st___prototype2[1]=CreateTrigger()
    call TriggerAddAction(st___prototype2[1],function sa___prototype2_TimerUtils___init)
    call TriggerAddCondition(st___prototype2[1],Condition(function sa___prototype2_TimerUtils___init))


call ExecuteFunc("s__DummyCaster_DummyCaster__N__onInit")
//------------------------------------
call ExecuteFunc("s__IsDestructableTree___I_IsDestructableTree___Inits___onInit")
//------------------------------------
call ExecuteFunc("TimerUtils___init")
//------------------------------------
call ExecuteFunc("s__WorldBounds_WorldBounds___WorldBoundInit___onInit")
//------------------------------------
call ExecuteFunc("GroundCollision__Init")
//------------------------------------
call ExecuteFunc("MissileDiagnostics___Init")
//------------------------------------
call ExecuteFunc("s__SpellEffectEvent__S_SpellEffectEvent__M__onInit")
//------------------------------------
call ExecuteFunc("MissileRecycler__PreInit")
//------------------------------------
call ExecuteFunc("s__Missile_onInit")
//------------------------------------
call ExecuteFunc("s__RapidBolt_MissileStruct___onInit")
call ExecuteFunc("RapidFire__Init")
//------------------------------------
call ExecuteFunc("s__X3Buster_onInit")
call ExecuteFunc("s__X3Buster__X3Body_MissileStruct___onInit")
//------------------------------------
call ExecuteFunc("RapidFireDemo___Init")
//------------------------------------
call ExecuteFunc("RapidFireProbe___Init")
//------------------------------------
call ExecuteFunc("ShotColorProbe__Init")
//------------------------------------
call ExecuteFunc("X3BusterDemo___Init")
//------------------------------------
call ExecuteFunc("X3Probe__Init")
//------------------------------------

endfunction

