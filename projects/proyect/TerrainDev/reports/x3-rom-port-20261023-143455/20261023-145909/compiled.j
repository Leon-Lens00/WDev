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
//globals from X3Kinematics:
constant boolean LIBRARY_X3Kinematics=true
//endglobals from X3Kinematics
//globals from GroundCollision:
constant boolean LIBRARY_GroundCollision=true
//endglobals from GroundCollision
//globals from MissileDiagnostics:
constant boolean LIBRARY_MissileDiagnostics=true
//endglobals from MissileDiagnostics
//globals from SpellEffectEvent:
constant boolean LIBRARY_SpellEffectEvent=true
//endglobals from SpellEffectEvent
//globals from X3Oracle:
constant boolean LIBRARY_X3Oracle=true
//endglobals from X3Oracle
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
integer RapidFireProbe__p= 0
integer RapidFireProbe__q= 0
integer RapidFireProbe__stage= 0
integer RapidFireProbe__checks= 0
integer RapidFireProbe__failures= 0
string array RapidFireProbe__lines
integer RapidFireProbe__count= 0
real RapidFireProbe__since
real RapidFireProbe__sx= - 4700.
real RapidFireProbe__sy= 3024.
integer RapidFireProbe__baseline
integer RapidFireProbe__createdBaseline
integer RapidFireProbe__oldFlight
integer RapidFireProbe__instants
integer RapidFireProbe__expectedHandoffs
integer RapidFireProbe__expectedHits
integer RapidFireProbe__expectedWalls
real RapidFireProbe__startX
real RapidFireProbe__startY
real RapidFireProbe__expectedNext
real RapidFireProbe__last= - 1000.
real RapidFireProbe__minimum= 99999.
integer RapidFireProbe__observed= 0
boolean RapidFireProbe__one= false
boolean RapidFireProbe__two= false
unit RapidFireProbe__target
destructable RapidFireProbe__tree
timer RapidFireProbe__t= null
real RapidFireProbe__cx1= 0.
real RapidFireProbe__cy1= 0.
real RapidFireProbe__cx2= 0.
real RapidFireProbe__cy2= 0.
integer RapidFireProbe__cliffIndex= 0
real RapidFireProbe__firstEmission= - 1.
real RapidFireProbe__firstEnd= - 1.
//endglobals from RapidFireProbe
//globals from ShotColorProbe:
constant boolean LIBRARY_ShotColorProbe=true
unit array ShotColorProbe___displayUnit
effect array ShotColorProbe___displayEffect
texttag array ShotColorProbe___label
lightning array ShotColorProbe___ring
integer ShotColorProbe___displays= 0
integer ShotColorProbe___rings= 0
integer ShotColorProbe___checks= 0
integer ShotColorProbe___failures= 0
string array ShotColorProbe___lines
integer ShotColorProbe___stage= 0
timer ShotColorProbe___ticker= CreateTimer()
real ShotColorProbe___since
integer ShotColorProbe___p
integer ShotColorProbe___prior
real ShotColorProbe___nextTime
integer ShotColorProbe___countBefore
string array ShotColorProbe___expected
real ShotColorProbe___originalX
real ShotColorProbe___originalY
//endglobals from ShotColorProbe
//globals from X3BusterDemo:
constant boolean LIBRARY_X3BusterDemo=true
//endglobals from X3BusterDemo
//globals from X3Probe:
constant boolean LIBRARY_X3Probe=true
integer X3Probe___checks= 0
integer X3Probe___failures= 0
integer X3Probe___stage= - 1
integer X3Probe___search= 0
string array X3Probe___lines
real X3Probe___since
real X3Probe___sx= - 4700.
real X3Probe___sy= 3024.
unit X3Probe___source
unit X3Probe___target
destructable X3Probe___tree
integer X3Probe___shot
integer X3Probe___second
integer X3Probe___baseline
integer X3Probe___births
integer X3Probe___hitBase
integer X3Probe___wallBase
integer X3Probe___satelliteBase
boolean X3Probe___one= false
timer X3Probe___ticker= CreateTimer()
timer X3Probe___showing= CreateTimer()
integer array X3Probe___capped
integer X3Probe___capIndex= 0
real X3Probe___facingImmediate
real X3Probe___facingSettled
real X3Probe___fallbackAngle
integer X3Probe___nativePair
real X3Probe___firstDamage= 0.
real X3Probe___fusedDamage= 0.
trigger X3Probe___damageWatch
real X3Probe___catchX
real X3Probe___catchY
real X3Probe___sampleGreen
real X3Probe___sampleOrange
real X3Probe___sampleCore
real X3Probe___sampleSpeed
real X3Probe___reverseExpected= 0.
real X3Probe___boundaryDamage= 0.
real X3Probe___previousClock= - 1.
integer X3Probe___repeatedClock= 0
integer X3Probe___physicalCallbacks= 0
real X3Probe___greenBirthX= 0.
real X3Probe___greenMinimumX= 0.
real X3Probe___greenRetreat= 0.
real X3Probe___finalGreenSpeed= 0.
real X3Probe___finalOrangeSpeed= 0.
integer X3Probe___damageEvents= 0
//endglobals from X3Probe
//globals from X3NativeProbe:
constant boolean LIBRARY_X3NativeProbe=true
integer X3NativeProbe___checks= 0
integer X3NativeProbe___failures= 0
string array X3NativeProbe___lines
integer X3NativeProbe___stage= - 1
timer X3NativeProbe___ticker= CreateTimer()
real X3NativeProbe___since= 0.
real X3NativeProbe___formationStarted
real X3NativeProbe___sx
real X3NativeProbe___sy
unit X3NativeProbe___source
unit X3NativeProbe___target
destructable X3NativeProbe___tree
integer X3NativeProbe___shot
integer X3NativeProbe___second
integer X3NativeProbe___pair
integer X3NativeProbe___births
integer X3NativeProbe___merges
integer X3NativeProbe___baseCreated
integer X3NativeProbe___baseRetired
integer X3NativeProbe___baseHits
integer X3NativeProbe___baseWalls
boolean X3NativeProbe___sawFormation
integer X3NativeProbe___visualProfile= 1
timer X3NativeProbe___showing= CreateTimer()
string X3NativeProbe___diagnostics= ""
real X3NativeProbe___targetBirthLife
real X3NativeProbe___unionRecordX
real X3NativeProbe___unionRecordY
real X3NativeProbe___unionAngle
real X3NativeProbe___targetX
real X3NativeProbe___targetY
//endglobals from X3NativeProbe
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
constant integer si__X3Kinematics=50
constant integer s__X3Kinematics_ORIGINAL= 1
constant integer s__X3Kinematics_ZERO_PROJECT= 2
constant real s__X3Kinematics_FPS= 60.0988062658451
constant real s__X3Kinematics_SCALE= 2.
real array s__X3Kinematics_wave
constant integer si__GroundCollision=51
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
constant integer si__MissileStats=52
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
constant integer si__SpellEffectEvent__S=53
integer s__SpellEffectEvent__S_tb
constant integer si__X3Oracle=54
integer s__X3Oracle_valueChecks= 0
integer s__X3Oracle_valueFailures= 0
real s__X3Oracle_maxError= 0.
boolean s__X3Oracle_done= false
integer s__X3Oracle_batch= 0
constant integer si__GroundMotion=55
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
constant integer si__Missile___RecycleBin=56
constant timer s__Missile___RecycleBin_t= CreateTimer()
integer s__Missile___RecycleBin_max= 0
unit array s__Missile___RecycleBin_dummy
real array s__Missile___RecycleBin_time
constant integer si__MissilePosition=57
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
constant integer si__Missile=58
integer s__Missile_Missile___MissileStructure__collectionCount= 0
integer s__Missile_Missile___MissileStructure__nodeCount= 0
integer array s__Missile_Missile___MissileStructure___list
integer array s__Missile_Missile___MissileStructure___next
integer array s__Missile_Missile___MissileStructure___prev
integer array s__Missile_Missile___MissileStructure___first
integer array s__Missile_Missile___MissileStructure___last
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
constant integer si__RapidBolt=59
constant real s__RapidBolt_HIT_RADIUS= 16.
constant real s__RapidBolt_VISUAL_SCALE= s__RapidBolt_HIT_RADIUS / 5.832
unit array s__RapidBolt_source
player array s__RapidBolt_owner
integer s__RapidBolt_live= 0
integer s__RapidBolt_hits= 0
integer s__RapidBolt_walls= 0
constant integer si__RapidPair=60
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
constant integer si__X3Buster___X3Flash=61
integer si__X3Buster___X3Flash_F=0
integer si__X3Buster___X3Flash_I=0
integer array si__X3Buster___X3Flash_V
unit array s__X3Buster___X3Flash_dummy
effect array s__X3Buster___X3Flash_art
integer s__X3Buster___X3Flash_live= 0
constant integer si__X3Buster=62
integer si__X3Buster_F=0
integer si__X3Buster_I=0
integer array si__X3Buster_V
constant real s__X3Buster_STEP= 1. / 32.
constant real s__X3Buster_ORBIT_SPEED= 260.
constant real s__X3Buster_PULSE_INITIAL= 650.
constant real s__X3Buster_PULSE_ACCEL= 1800.
constant real s__X3Buster_PULSE_SPEED= 1500.
constant real s__X3Buster_FUSED_INITIAL= 70.
constant real s__X3Buster_FUSED_ACCEL= 900.
constant real s__X3Buster_FUSED_SPEED= 1200.
constant real s__X3Buster_FORMATION_TIME= 0.09375
constant real s__X3Buster_GREEN_INITIAL= - 626.
constant real s__X3Buster_GREEN_ACCEL= 4363.
constant real s__X3Buster_GREEN_SPEED= 1140.
constant real s__X3Buster_ORANGE_INITIAL= - 400.
constant real s__X3Buster_ORANGE_ACCEL= 2666.666667
constant real s__X3Buster_ORANGE_SPEED= 1080.
constant real s__X3Buster_PULSE_DELAY= 0.375
constant real s__X3Buster_ORBIT_RADIUS= 32.
constant real s__X3Buster_ORBIT_HZ= 2.5
constant real s__X3Buster_RANGE= 1400.
constant real s__X3Buster_LIFETIME= 4.
constant integer s__X3Buster_LIMIT= 64
constant integer s__X3Buster_GIF= 0
constant integer s__X3Buster_ORIGINAL= 1
constant integer s__X3Buster_ZERO_PROJECT= 2
integer array s__X3Buster_profile
boolean array s__X3Buster_forming
timer array s__X3Buster_formationTimer
real array s__X3Buster_unionX
real array s__X3Buster_unionY
real array s__X3Buster_unionRemaining
unit array s__X3Buster_caster
player array s__X3Buster_owner
real array s__X3Buster_originX
real array s__X3Buster_originY
real array s__X3Buster_angle
real array s__X3Buster_born
integer array s__X3Buster_state
integer array s__X3Buster_green
integer array s__X3Buster_blue
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
constant integer si__X3Buster___X3Body=63
integer array s__X3Buster___X3Body_kind
real array s__X3Buster___X3Body_lastX
real array s__X3Buster___X3Body_lastY
real array s__X3Buster___X3Body_processed
boolean array s__X3Buster___X3Body_blocked
real array s__X3Buster___X3Body_age
boolean array s__X3Buster___X3Body_prepared
real array s__X3Buster___X3Body_startX
real array s__X3Buster___X3Body_startY
real array s__X3Buster___X3Body_length
constant integer si__RapidDemo=64
integer s__RapidDemo_pair= 0
boolean s__RapidDemo_extended= false
unit array s__RapidDemo_targets
constant integer si__X3Demo=65
integer s__X3Demo_profile= s__X3Buster_ORIGINAL
integer array s__TimerUtils___data
timer array s__TimerUtils___tT
trigger st__X3Buster___X3Body_prepare
trigger st__X3Buster___X3Body_ageOf
trigger st__X3Buster___X3Body_centerX
trigger st__X3Buster___X3Body_centerY
trigger st__X3Buster___X3Body_resolveAt
trigger st__X3Buster___X3Body_spawn
trigger array st___prototype2
integer f__arg_integer1
integer f__arg_integer2
real f__arg_real1
real f__arg_real2
real f__arg_real3
real f__arg_real4
real f__result_real
boolean f__result_boolean
integer f__result_integer

endglobals
    native UnitAlive takes unit id returns boolean


//Generated method caller for X3Buster___X3Body.prepare
function sc__X3Buster___X3Body_prepare takes integer m returns nothing
        // A long-duration timer reading is not a unique physical tick ID.
        // The body's own callback consumes this flag after all partial sweeps.
        if not s__X3Buster___X3Body_prepared[m] then
            set s__X3Buster___X3Body_prepared[m]=true
            set s__X3Buster___X3Body_age[m]=s__X3Buster___X3Body_age[m] + s__X3Buster_STEP
        endif
endfunction

//Generated method caller for X3Buster___X3Body.ageOf
function sc__X3Buster___X3Body_ageOf takes integer m returns real
        return s__X3Buster___X3Body_age[m]
endfunction

//Generated method caller for X3Buster___X3Body.centerX
function sc__X3Buster___X3Body_centerX takes integer m,real fraction returns real
    set f__arg_integer1=m
    set f__arg_real1=fraction
    call TriggerEvaluate(st__X3Buster___X3Body_centerX)
 return f__result_real
endfunction

//Generated method caller for X3Buster___X3Body.centerY
function sc__X3Buster___X3Body_centerY takes integer m,real fraction returns real
    set f__arg_integer1=m
    set f__arg_real1=fraction
    call TriggerEvaluate(st__X3Buster___X3Body_centerY)
 return f__result_real
endfunction

//Generated method caller for X3Buster___X3Body.resolveAt
function sc__X3Buster___X3Body_resolveAt takes integer m,real fraction returns boolean
    set f__arg_integer1=m
    set f__arg_real1=fraction
    call TriggerEvaluate(st__X3Buster___X3Body_resolveAt)
 return f__result_boolean
endfunction

//Generated method caller for X3Buster___X3Body.spawn
function sc__X3Buster___X3Body_spawn takes integer s,integer form,real x,real y,real facing,real range returns integer
    set f__arg_integer1=s
    set f__arg_integer2=form
    set f__arg_real1=x
    set f__arg_real2=y
    set f__arg_real3=facing
    set f__arg_real4=range
    call TriggerEvaluate(st__X3Buster___X3Body_spawn)
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

//Generated allocator of X3Buster___X3Flash
function s__X3Buster___X3Flash__allocate takes nothing returns integer
 local integer this=si__X3Buster___X3Flash_F
    if (this!=0) then
        set si__X3Buster___X3Flash_F=si__X3Buster___X3Flash_V[this]
    else
        set si__X3Buster___X3Flash_I=si__X3Buster___X3Flash_I+1
        set this=si__X3Buster___X3Flash_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__X3Buster___X3Flash_V[this]=-1
 return this
endfunction

//Generated destructor of X3Buster___X3Flash
function s__X3Buster___X3Flash_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__X3Buster___X3Flash_V[this]!=-1) then
        return
    endif
    set si__X3Buster___X3Flash_V[this]=si__X3Buster___X3Flash_F
    set si__X3Buster___X3Flash_F=this
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
        function s__DummyCaster_DummyCaster__N___onInit takes nothing returns nothing





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
        function s__IsDestructableTree___I_IsDestructableTree___Inits__onInit takes nothing returns nothing
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
  function s__WorldBounds_WorldBounds___WorldBoundInit__onInit takes nothing returns nothing
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


    function s__X3Kinematics_formation takes integer profile returns real
        if profile == s__X3Kinematics_ZERO_PROJECT then
            return 8. / s__X3Kinematics_FPS
        endif
        return 18. / s__X3Kinematics_FPS
    endfunction
    function s__X3Kinematics_pulseDelay takes integer profile returns real
        // Demonstration timing: observed birth of the second body relative to
        // the first carrier, not simulation of charging a controller button.
        if profile == s__X3Kinematics_ZERO_PROJECT then
            return 13. / s__X3Kinematics_FPS
        endif
        return 17. / s__X3Kinematics_FPS
    endfunction
    function s__X3Kinematics_helixPixel takes integer n returns real
        local real k
        if n <= 15 then
            return 0.5 * n + ( 1. / 32. ) * n * ( n + 1 ) * 0.5
        elseif n <= 32 then
            set k=I2R(n - 15)
            return 11.25 + 0.96875 * k + 0.25 * k * ( k + 1. ) * 0.5
        endif
        return 65.96875 + 5.25 * I2R(n - 32)
    endfunction
    function s__X3Kinematics_xPixel takes integer profile,integer form,integer n returns real
        local real initial= - 6.
        local real accel= 96. / 256.
        local integer cap
        local real k
        if form == 4 then
            if profile == s__X3Kinematics_ZERO_PROJECT then
                // ROM stores 10, but clamps to 8 BEFORE its first displacement.
                return 8. * n
            endif
            set initial=0.
            set accel=24. / 256.
        elseif form == 5 or form == 8 then
            if profile == s__X3Kinematics_ZERO_PROJECT then
                set initial=1.
                set accel=48. / 256.
            else
                set initial=- 8.
                set accel=127. / 256.
            endif
        elseif profile == s__X3Kinematics_ZERO_PROJECT then
            set initial=- 3.
        endif
        set cap=R2I(( 8. - initial ) / accel)
        if I2R(cap) * accel < 8. - initial then
            set cap=cap + 1
        endif
        if n <= cap then
            set k=I2R(n)
            return initial * k + accel * k * ( k + 1. ) * 0.5
        endif
        set k=I2R(cap)
        // The native limit precedes acceleration: the stable step is 8+a.
        return initial * k + accel * k * ( k + 1. ) * 0.5 + ( 8. + accel ) * I2R(n - cap)
    endfunction
    function s__X3Kinematics_yPixel takes integer profile,integer form,integer n returns real
        local real vy= 0.75
        local real ay= 0.
        local real k= I2R(n)
        if form == 4 then
            return 0.
        elseif form == 5 or form == 8 then
            set vy=1.5
            if profile == s__X3Kinematics_ZERO_PROJECT then
                set vy=5.
                set ay=96. / 256.
            endif
        elseif profile == s__X3Kinematics_ZERO_PROJECT then
            set vy=7.
            set ay=112. / 256.
        endif
        if form == 7 or form == 8 then
            set vy=- vy
            set ay=- ay
        endif
        return - vy * k + ay * k * ( k + 1. ) * 0.5
    endfunction
    function s__X3Kinematics_forward takes integer profile,integer form,real age returns real
        local real frame= RMaxBJ(0., age * s__X3Kinematics_FPS)
        local integer n= R2I(frame)
        local real f= frame - I2R(n)
        local real a
        if form == 1 or form == 2 or form == 9 then
            set a=s__X3Kinematics_helixPixel(n)
            return s__X3Kinematics_SCALE * ( a + ( s__X3Kinematics_helixPixel(n + 1) - a ) * f )
        elseif form == 0 or form == 3 then
            // Four native steps of growth; step 5 first displaces by 8 pixels.
            return s__X3Kinematics_SCALE * 8. * RMaxBJ(0., frame - 4.)
        endif
        set a=s__X3Kinematics_xPixel(profile , form , n)
        return s__X3Kinematics_SCALE * ( a + ( s__X3Kinematics_xPixel(profile , form , n + 1) - a ) * f )
    endfunction
    function s__X3Kinematics_orbitForward takes integer form,real age returns real
        local real frame= RMaxBJ(0., age * s__X3Kinematics_FPS)
        local integer n= R2I(frame)
        local real f= frame - I2R(n)
        local real offset= 4.
        local real a= I2R(R2I(0.5 + s__X3Kinematics_helixPixel(n))) - 0.5
        local real b= I2R(R2I(0.5 + s__X3Kinematics_helixPixel(n + 1))) - 0.5
        if form == 2 then
            set offset=8.
        elseif form == 9 then
            set offset=0.
        endif
        return s__X3Kinematics_SCALE * ( a + ( b - a ) * f + offset )
    endfunction
    function s__X3Kinematics_orbitY takes integer form,integer n returns real
        local integer phase= 0
        local integer i= 1
        local real y= - 6.
        set n=ModuloInteger(n, 16)
        if form == 2 then
            set phase=4
            set y=0.
        elseif form == 9 then
            set phase=8
            set y=7.
        endif
        loop
            exitwhen i > n
            set y=y - s__X3Kinematics_wave[ModuloInteger(phase + i, 16)]
            set i=i + 1
        endloop
        return y
    endfunction
    function s__X3Kinematics_side takes integer profile,integer form,real age returns real
        local real frame= RMaxBJ(0., age * s__X3Kinematics_FPS)
        local integer n= R2I(frame)
        local real f= frame - I2R(n)
        local real a
        if form == 1 or form == 2 or form == 9 then
            set a=s__X3Kinematics_orbitY(form , n)
            return - s__X3Kinematics_SCALE * ( a + ( s__X3Kinematics_orbitY(form , n + 1) - a ) * f )
        endif
        set a=s__X3Kinematics_yPixel(profile , form , n)
        // SNES screen-down is the opposite of Warcraft's left-perpendicular.
        return - s__X3Kinematics_SCALE * ( a + ( s__X3Kinematics_yPixel(profile , form , n + 1) - a ) * f )
    endfunction
    function s__X3Kinematics_onInit takes nothing returns nothing
        set s__X3Kinematics_wave[0]=- 1.
        set s__X3Kinematics_wave[1]=- 2.
        set s__X3Kinematics_wave[2]=- 6.
        set s__X3Kinematics_wave[3]=- 3.
        set s__X3Kinematics_wave[4]=- 3.
        set s__X3Kinematics_wave[5]=- 6.
        set s__X3Kinematics_wave[6]=- 2.
        set s__X3Kinematics_wave[7]=- 1.
        set s__X3Kinematics_wave[8]=1.
        set s__X3Kinematics_wave[9]=2.
        set s__X3Kinematics_wave[10]=6.
        set s__X3Kinematics_wave[11]=3.
        set s__X3Kinematics_wave[12]=3.
        set s__X3Kinematics_wave[13]=6.
        set s__X3Kinematics_wave[14]=2.
        set s__X3Kinematics_wave[15]=1.
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
 
    function s__SpellEffectEvent__S_SpellEffectEvent__M___onInit takes nothing returns nothing

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
 

    function s__X3Oracle_Scalar takes real actual,real expected returns nothing
        local real error= RAbsBJ(actual - expected)
        set s__X3Oracle_valueChecks=s__X3Oracle_valueChecks + 1
        set s__X3Oracle_maxError=RMaxBJ(s__X3Oracle_maxError, error)
        if error > 0.012 then
            set s__X3Oracle_valueFailures=s__X3Oracle_valueFailures + 1
            if s__X3Oracle_valueFailures < 8 then
                call DisplayTimedTextToPlayer(Player(0), 0., 0., 60., "ORACLE FAIL " + I2S(s__X3Oracle_valueChecks) + " actual " + R2S(actual) + " expected " + R2S(expected))
            endif
        endif
    endfunction
    function s__X3Oracle_Combined takes integer p,integer form,integer n,real x,real y,real vx,real vy returns nothing
        local real t= I2R(n) / s__X3Kinematics_FPS
        local real previous= I2R(n - 1) / s__X3Kinematics_FPS
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(p , form , t) , x)
        call s__X3Oracle_Scalar(s__X3Kinematics_side(p , form , t) , y)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(p , form , t) - s__X3Kinematics_forward(p , form , previous) , vx)
        call s__X3Oracle_Scalar(s__X3Kinematics_side(p , form , t) - s__X3Kinematics_side(p , form , previous) , vy)
    endfunction
    function s__X3Oracle_Orb takes integer form,integer n,real x,real y returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_orbitForward(form , I2R(n) / s__X3Kinematics_FPS) , x)
        call s__X3Oracle_Scalar(s__X3Kinematics_side(1 , form , I2R(n) / s__X3Kinematics_FPS) , y)
    endfunction
    function s__X3Oracle_Batch0 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 1 , - 11.25000000 , - 1.50000000 , - 11.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 1 , - 11.25000000 , 1.50000000 , - 11.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 1 , - 15.00781250 , - 3.00000000 , - 15.00781250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 1 , - 15.00781250 , 3.00000000 , - 15.00781250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 1 , 0.18750000 , - 0.00000000 , 0.18750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 2 , - 21.75000000 , - 3.00000000 , - 10.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 2 , - 21.75000000 , 3.00000000 , - 10.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 2 , - 29.02343750 , - 6.00000000 , - 14.01562500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 2 , - 29.02343750 , 6.00000000 , - 14.01562500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 2 , 0.56250000 , - 0.00000000 , 0.37500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 3 , - 31.50000000 , - 4.50000000 , - 9.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 3 , - 31.50000000 , 4.50000000 , - 9.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 3 , - 42.04687500 , - 9.00000000 , - 13.02343750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 3 , - 42.04687500 , 9.00000000 , - 13.02343750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 3 , 1.12500000 , - 0.00000000 , 0.56250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 4 , - 40.50000000 , - 6.00000000 , - 9.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 4 , - 40.50000000 , 6.00000000 , - 9.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 4 , - 54.07812500 , - 12.00000000 , - 12.03125000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 4 , - 54.07812500 , 12.00000000 , - 12.03125000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 4 , 1.87500000 , - 0.00000000 , 0.75000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch1 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 5 , - 48.75000000 , - 7.50000000 , - 8.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 5 , - 48.75000000 , 7.50000000 , - 8.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 5 , - 65.11718750 , - 15.00000000 , - 11.03906250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 5 , - 65.11718750 , 15.00000000 , - 11.03906250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 5 , 2.81250000 , - 0.00000000 , 0.93750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 6 , - 56.25000000 , - 9.00000000 , - 7.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 6 , - 56.25000000 , 9.00000000 , - 7.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 6 , - 75.16406250 , - 18.00000000 , - 10.04687500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 6 , - 75.16406250 , 18.00000000 , - 10.04687500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 6 , 3.93750000 , - 0.00000000 , 1.12500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 7 , - 63.00000000 , - 10.50000000 , - 6.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 7 , - 63.00000000 , 10.50000000 , - 6.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 7 , - 84.21875000 , - 21.00000000 , - 9.05468750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 7 , - 84.21875000 , 21.00000000 , - 9.05468750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 7 , 5.25000000 , - 0.00000000 , 1.31250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 8 , - 69.00000000 , - 12.00000000 , - 6.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 8 , - 69.00000000 , 12.00000000 , - 6.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 8 , - 92.28125000 , - 24.00000000 , - 8.06250000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 8 , - 92.28125000 , 24.00000000 , - 8.06250000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 8 , 6.75000000 , - 0.00000000 , 1.50000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch2 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 9 , - 74.25000000 , - 13.50000000 , - 5.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 9 , - 74.25000000 , 13.50000000 , - 5.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 9 , - 99.35156250 , - 27.00000000 , - 7.07031250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 9 , - 99.35156250 , 27.00000000 , - 7.07031250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 9 , 8.43750000 , - 0.00000000 , 1.68750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 10 , - 78.75000000 , - 15.00000000 , - 4.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 10 , - 78.75000000 , 15.00000000 , - 4.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 10 , - 105.42968750 , - 30.00000000 , - 6.07812500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 10 , - 105.42968750 , 30.00000000 , - 6.07812500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 10 , 10.31250000 , - 0.00000000 , 1.87500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 11 , - 82.50000000 , - 16.50000000 , - 3.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 11 , - 82.50000000 , 16.50000000 , - 3.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 11 , - 110.51562500 , - 33.00000000 , - 5.08593750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 11 , - 110.51562500 , 33.00000000 , - 5.08593750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 11 , 12.37500000 , - 0.00000000 , 2.06250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 12 , - 85.50000000 , - 18.00000000 , - 3.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 12 , - 85.50000000 , 18.00000000 , - 3.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 12 , - 114.60937500 , - 36.00000000 , - 4.09375000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 12 , - 114.60937500 , 36.00000000 , - 4.09375000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 12 , 14.62500000 , - 0.00000000 , 2.25000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch3 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 13 , - 87.75000000 , - 19.50000000 , - 2.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 13 , - 87.75000000 , 19.50000000 , - 2.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 13 , - 117.71093750 , - 39.00000000 , - 3.10156250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 13 , - 117.71093750 , 39.00000000 , - 3.10156250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 13 , 17.06250000 , - 0.00000000 , 2.43750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 14 , - 89.25000000 , - 21.00000000 , - 1.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 14 , - 89.25000000 , 21.00000000 , - 1.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 14 , - 119.82031250 , - 42.00000000 , - 2.10937500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 14 , - 119.82031250 , 42.00000000 , - 2.10937500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 14 , 19.68750000 , - 0.00000000 , 2.62500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 15 , - 90.00000000 , - 22.50000000 , - 0.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 15 , - 90.00000000 , 22.50000000 , - 0.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 15 , - 120.93750000 , - 45.00000000 , - 1.11718750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 15 , - 120.93750000 , 45.00000000 , - 1.11718750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 15 , 22.50000000 , - 0.00000000 , 2.81250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 16 , - 90.00000000 , - 24.00000000 , 0.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 16 , - 90.00000000 , 24.00000000 , 0.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 16 , - 121.06250000 , - 48.00000000 , - 0.12500000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 16 , - 121.06250000 , 48.00000000 , - 0.12500000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 16 , 25.50000000 , - 0.00000000 , 3.00000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch4 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 17 , - 89.25000000 , - 25.50000000 , 0.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 17 , - 89.25000000 , 25.50000000 , 0.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 17 , - 120.19531250 , - 51.00000000 , 0.86718750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 17 , - 120.19531250 , 51.00000000 , 0.86718750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 17 , 28.68750000 , - 0.00000000 , 3.18750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 18 , - 87.75000000 , - 27.00000000 , 1.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 18 , - 87.75000000 , 27.00000000 , 1.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 18 , - 118.33593750 , - 54.00000000 , 1.85937500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 18 , - 118.33593750 , 54.00000000 , 1.85937500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 18 , 32.06250000 , - 0.00000000 , 3.37500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 19 , - 85.50000000 , - 28.50000000 , 2.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 19 , - 85.50000000 , 28.50000000 , 2.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 19 , - 115.48437500 , - 57.00000000 , 2.85156250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 19 , - 115.48437500 , 57.00000000 , 2.85156250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 19 , 35.62500000 , - 0.00000000 , 3.56250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 20 , - 82.50000000 , - 30.00000000 , 3.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 20 , - 82.50000000 , 30.00000000 , 3.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 20 , - 111.64062500 , - 60.00000000 , 3.84375000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 20 , - 111.64062500 , 60.00000000 , 3.84375000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 20 , 39.37500000 , - 0.00000000 , 3.75000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch5 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 21 , - 78.75000000 , - 31.50000000 , 3.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 21 , - 78.75000000 , 31.50000000 , 3.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 21 , - 106.80468750 , - 63.00000000 , 4.83593750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 21 , - 106.80468750 , 63.00000000 , 4.83593750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 21 , 43.31250000 , - 0.00000000 , 3.93750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 22 , - 74.25000000 , - 33.00000000 , 4.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 22 , - 74.25000000 , 33.00000000 , 4.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 22 , - 100.97656250 , - 66.00000000 , 5.82812500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 22 , - 100.97656250 , 66.00000000 , 5.82812500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 22 , 47.43750000 , - 0.00000000 , 4.12500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 23 , - 69.00000000 , - 34.50000000 , 5.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 23 , - 69.00000000 , 34.50000000 , 5.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 23 , - 94.15625000 , - 69.00000000 , 6.82031250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 23 , - 94.15625000 , 69.00000000 , 6.82031250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 23 , 51.75000000 , - 0.00000000 , 4.31250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 24 , - 63.00000000 , - 36.00000000 , 6.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 24 , - 63.00000000 , 36.00000000 , 6.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 24 , - 86.34375000 , - 72.00000000 , 7.81250000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 24 , - 86.34375000 , 72.00000000 , 7.81250000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 24 , 56.25000000 , - 0.00000000 , 4.50000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch6 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 25 , - 56.25000000 , - 37.50000000 , 6.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 25 , - 56.25000000 , 37.50000000 , 6.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 25 , - 77.53906250 , - 75.00000000 , 8.80468750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 25 , - 77.53906250 , 75.00000000 , 8.80468750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 25 , 60.93750000 , - 0.00000000 , 4.68750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 26 , - 48.75000000 , - 39.00000000 , 7.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 26 , - 48.75000000 , 39.00000000 , 7.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 26 , - 67.74218750 , - 78.00000000 , 9.79687500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 26 , - 67.74218750 , 78.00000000 , 9.79687500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 26 , 65.81250000 , - 0.00000000 , 4.87500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 27 , - 40.50000000 , - 40.50000000 , 8.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 27 , - 40.50000000 , 40.50000000 , 8.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 27 , - 56.95312500 , - 81.00000000 , 10.78906250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 27 , - 56.95312500 , 81.00000000 , 10.78906250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 27 , 70.87500000 , - 0.00000000 , 5.06250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 28 , - 31.50000000 , - 42.00000000 , 9.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 28 , - 31.50000000 , 42.00000000 , 9.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 28 , - 45.17187500 , - 84.00000000 , 11.78125000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 28 , - 45.17187500 , 84.00000000 , 11.78125000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 28 , 76.12500000 , - 0.00000000 , 5.25000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch7 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 29 , - 21.75000000 , - 43.50000000 , 9.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 29 , - 21.75000000 , 43.50000000 , 9.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 29 , - 32.39843750 , - 87.00000000 , 12.77343750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 29 , - 32.39843750 , 87.00000000 , 12.77343750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 29 , 81.56250000 , - 0.00000000 , 5.43750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 30 , - 11.25000000 , - 45.00000000 , 10.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 30 , - 11.25000000 , 45.00000000 , 10.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 30 , - 18.63281250 , - 90.00000000 , 13.76562500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 30 , - 18.63281250 , 90.00000000 , 13.76562500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 30 , 87.18750000 , - 0.00000000 , 5.62500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 31 , 0.00000000 , - 46.50000000 , 11.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 31 , 0.00000000 , 46.50000000 , 11.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 31 , - 3.87500000 , - 93.00000000 , 14.75781250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 31 , - 3.87500000 , 93.00000000 , 14.75781250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 31 , 93.00000000 , - 0.00000000 , 5.81250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 32 , 12.00000000 , - 48.00000000 , 12.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 32 , 12.00000000 , 48.00000000 , 12.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 32 , 11.87500000 , - 96.00000000 , 15.75000000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 32 , 11.87500000 , 96.00000000 , 15.75000000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 32 , 99.00000000 , - 0.00000000 , 6.00000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch8 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 33 , 24.75000000 , - 49.50000000 , 12.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 33 , 24.75000000 , 49.50000000 , 12.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 33 , 28.61718750 , - 99.00000000 , 16.74218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 33 , 28.61718750 , 99.00000000 , 16.74218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 33 , 105.18750000 , - 0.00000000 , 6.18750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 34 , 38.25000000 , - 51.00000000 , 13.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 34 , 38.25000000 , 51.00000000 , 13.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 34 , 45.60937500 , - 102.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 34 , 45.60937500 , 102.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 34 , 111.56250000 , - 0.00000000 , 6.37500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 35 , 52.50000000 , - 52.50000000 , 14.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 35 , 52.50000000 , 52.50000000 , 14.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 35 , 62.60156250 , - 105.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 35 , 62.60156250 , 105.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 35 , 118.12500000 , - 0.00000000 , 6.56250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 36 , 67.50000000 , - 54.00000000 , 15.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 36 , 67.50000000 , 54.00000000 , 15.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 36 , 79.59375000 , - 108.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 36 , 79.59375000 , 108.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 36 , 124.87500000 , - 0.00000000 , 6.75000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch9 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 37 , 83.25000000 , - 55.50000000 , 15.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 37 , 83.25000000 , 55.50000000 , 15.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 37 , 96.58593750 , - 111.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 37 , 96.58593750 , 111.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 37 , 131.81250000 , - 0.00000000 , 6.93750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 38 , 99.75000000 , - 57.00000000 , 16.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 38 , 99.75000000 , 57.00000000 , 16.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 38 , 113.57812500 , - 114.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 38 , 113.57812500 , 114.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 38 , 138.93750000 , - 0.00000000 , 7.12500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 39 , 116.50000000 , - 58.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 39 , 116.50000000 , 58.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 39 , 130.57031250 , - 117.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 39 , 130.57031250 , 117.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 39 , 146.25000000 , - 0.00000000 , 7.31250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 40 , 133.25000000 , - 60.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 40 , 133.25000000 , 60.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 40 , 147.56250000 , - 120.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 40 , 147.56250000 , 120.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 40 , 153.75000000 , - 0.00000000 , 7.50000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch10 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 41 , 150.00000000 , - 61.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 41 , 150.00000000 , 61.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 41 , 164.55468750 , - 123.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 41 , 164.55468750 , 123.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 41 , 161.43750000 , - 0.00000000 , 7.68750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 42 , 166.75000000 , - 63.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 42 , 166.75000000 , 63.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 42 , 181.54687500 , - 126.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 42 , 181.54687500 , 126.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 42 , 169.31250000 , - 0.00000000 , 7.87500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 43 , 183.50000000 , - 64.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 43 , 183.50000000 , 64.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 43 , 198.53906250 , - 129.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 43 , 198.53906250 , 129.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 43 , 177.37500000 , - 0.00000000 , 8.06250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 44 , 200.25000000 , - 66.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 44 , 200.25000000 , 66.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 44 , 215.53125000 , - 132.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 44 , 215.53125000 , 132.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 44 , 185.62500000 , - 0.00000000 , 8.25000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch11 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 45 , 217.00000000 , - 67.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 45 , 217.00000000 , 67.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 45 , 232.52343750 , - 135.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 45 , 232.52343750 , 135.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 45 , 194.06250000 , - 0.00000000 , 8.43750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 46 , 233.75000000 , - 69.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 46 , 233.75000000 , 69.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 46 , 249.51562500 , - 138.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 46 , 249.51562500 , 138.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 46 , 202.68750000 , - 0.00000000 , 8.62500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 47 , 250.50000000 , - 70.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 47 , 250.50000000 , 70.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 47 , 266.50781250 , - 141.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 47 , 266.50781250 , 141.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 47 , 211.50000000 , - 0.00000000 , 8.81250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 48 , 267.25000000 , - 72.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 48 , 267.25000000 , 72.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 48 , 283.50000000 , - 144.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 48 , 283.50000000 , 144.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 48 , 220.50000000 , - 0.00000000 , 9.00000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch12 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 49 , 284.00000000 , - 73.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 49 , 284.00000000 , 73.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 49 , 300.49218750 , - 147.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 49 , 300.49218750 , 147.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 49 , 229.68750000 , - 0.00000000 , 9.18750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 50 , 300.75000000 , - 75.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 50 , 300.75000000 , 75.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 50 , 317.48437500 , - 150.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 50 , 317.48437500 , 150.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 50 , 239.06250000 , - 0.00000000 , 9.37500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 51 , 317.50000000 , - 76.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 51 , 317.50000000 , 76.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 51 , 334.47656250 , - 153.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 51 , 334.47656250 , 153.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 51 , 248.62500000 , - 0.00000000 , 9.56250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 52 , 334.25000000 , - 78.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 52 , 334.25000000 , 78.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 52 , 351.46875000 , - 156.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 52 , 351.46875000 , 156.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 52 , 258.37500000 , - 0.00000000 , 9.75000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch13 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 53 , 351.00000000 , - 79.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 53 , 351.00000000 , 79.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 4 , 53 , 268.31250000 , - 0.00000000 , 9.93750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 54 , 278.43750000 , - 0.00000000 , 10.12500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 55 , 288.75000000 , - 0.00000000 , 10.31250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 56 , 299.25000000 , - 0.00000000 , 10.50000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 57 , 309.93750000 , - 0.00000000 , 10.68750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 58 , 320.81250000 , - 0.00000000 , 10.87500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 59 , 331.87500000 , - 0.00000000 , 11.06250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 60 , 343.12500000 , - 0.00000000 , 11.25000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 1 , - 5.25000000 , - 13.12500000 , - 5.25000000 , - 13.12500000)
        call s__X3Oracle_Combined(2 , 6 , 1 , - 5.25000000 , 13.12500000 , - 5.25000000 , 13.12500000)
        call s__X3Oracle_Combined(2 , 8 , 1 , 2.37500000 , - 9.25000000 , 2.37500000 , - 9.25000000)
        call s__X3Oracle_Combined(2 , 5 , 1 , 2.37500000 , 9.25000000 , 2.37500000 , 9.25000000)
        call s__X3Oracle_Combined(2 , 4 , 1 , 16.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 2 , - 9.75000000 , - 25.37500000 , - 4.50000000 , - 12.25000000)
        call s__X3Oracle_Combined(2 , 6 , 2 , - 9.75000000 , 25.37500000 , - 4.50000000 , 12.25000000)
        call s__X3Oracle_Combined(2 , 8 , 2 , 5.12500000 , - 17.75000000 , 2.75000000 , - 8.50000000)
        call s__X3Oracle_Combined(2 , 5 , 2 , 5.12500000 , 17.75000000 , 2.75000000 , 8.50000000)
        call s__X3Oracle_Combined(2 , 4 , 2 , 32.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch14 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 7 , 3 , - 13.50000000 , - 36.75000000 , - 3.75000000 , - 11.37500000)
        call s__X3Oracle_Combined(2 , 6 , 3 , - 13.50000000 , 36.75000000 , - 3.75000000 , 11.37500000)
        call s__X3Oracle_Combined(2 , 8 , 3 , 8.25000000 , - 25.50000000 , 3.12500000 , - 7.75000000)
        call s__X3Oracle_Combined(2 , 5 , 3 , 8.25000000 , 25.50000000 , 3.12500000 , 7.75000000)
        call s__X3Oracle_Combined(2 , 4 , 3 , 48.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 4 , - 16.50000000 , - 47.25000000 , - 3.00000000 , - 10.50000000)
        call s__X3Oracle_Combined(2 , 6 , 4 , - 16.50000000 , 47.25000000 , - 3.00000000 , 10.50000000)
        call s__X3Oracle_Combined(2 , 8 , 4 , 11.75000000 , - 32.50000000 , 3.50000000 , - 7.00000000)
        call s__X3Oracle_Combined(2 , 5 , 4 , 11.75000000 , 32.50000000 , 3.50000000 , 7.00000000)
        call s__X3Oracle_Combined(2 , 4 , 4 , 64.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 5 , - 18.75000000 , - 56.87500000 , - 2.25000000 , - 9.62500000)
        call s__X3Oracle_Combined(2 , 6 , 5 , - 18.75000000 , 56.87500000 , - 2.25000000 , 9.62500000)
        call s__X3Oracle_Combined(2 , 8 , 5 , 15.62500000 , - 38.75000000 , 3.87500000 , - 6.25000000)
        call s__X3Oracle_Combined(2 , 5 , 5 , 15.62500000 , 38.75000000 , 3.87500000 , 6.25000000)
        call s__X3Oracle_Combined(2 , 4 , 5 , 80.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 6 , - 20.25000000 , - 65.62500000 , - 1.50000000 , - 8.75000000)
        call s__X3Oracle_Combined(2 , 6 , 6 , - 20.25000000 , 65.62500000 , - 1.50000000 , 8.75000000)
        call s__X3Oracle_Combined(2 , 8 , 6 , 19.87500000 , - 44.25000000 , 4.25000000 , - 5.50000000)
        call s__X3Oracle_Combined(2 , 5 , 6 , 19.87500000 , 44.25000000 , 4.25000000 , 5.50000000)
        call s__X3Oracle_Combined(2 , 4 , 6 , 96.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch15 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 7 , 7 , - 21.00000000 , - 73.50000000 , - 0.75000000 , - 7.87500000)
        call s__X3Oracle_Combined(2 , 6 , 7 , - 21.00000000 , 73.50000000 , - 0.75000000 , 7.87500000)
        call s__X3Oracle_Combined(2 , 8 , 7 , 24.50000000 , - 49.00000000 , 4.62500000 , - 4.75000000)
        call s__X3Oracle_Combined(2 , 5 , 7 , 24.50000000 , 49.00000000 , 4.62500000 , 4.75000000)
        call s__X3Oracle_Combined(2 , 4 , 7 , 112.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 8 , - 21.00000000 , - 80.50000000 , 0.00000000 , - 7.00000000)
        call s__X3Oracle_Combined(2 , 6 , 8 , - 21.00000000 , 80.50000000 , 0.00000000 , 7.00000000)
        call s__X3Oracle_Combined(2 , 8 , 8 , 29.50000000 , - 53.00000000 , 5.00000000 , - 4.00000000)
        call s__X3Oracle_Combined(2 , 5 , 8 , 29.50000000 , 53.00000000 , 5.00000000 , 4.00000000)
        call s__X3Oracle_Combined(2 , 4 , 8 , 128.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 9 , - 20.25000000 , - 86.62500000 , 0.75000000 , - 6.12500000)
        call s__X3Oracle_Combined(2 , 6 , 9 , - 20.25000000 , 86.62500000 , 0.75000000 , 6.12500000)
        call s__X3Oracle_Combined(2 , 8 , 9 , 34.87500000 , - 56.25000000 , 5.37500000 , - 3.25000000)
        call s__X3Oracle_Combined(2 , 5 , 9 , 34.87500000 , 56.25000000 , 5.37500000 , 3.25000000)
        call s__X3Oracle_Combined(2 , 4 , 9 , 144.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 10 , - 18.75000000 , - 91.87500000 , 1.50000000 , - 5.25000000)
        call s__X3Oracle_Combined(2 , 6 , 10 , - 18.75000000 , 91.87500000 , 1.50000000 , 5.25000000)
        call s__X3Oracle_Combined(2 , 8 , 10 , 40.62500000 , - 58.75000000 , 5.75000000 , - 2.50000000)
        call s__X3Oracle_Combined(2 , 5 , 10 , 40.62500000 , 58.75000000 , 5.75000000 , 2.50000000)
        call s__X3Oracle_Combined(2 , 4 , 10 , 160.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch16 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 7 , 11 , - 16.50000000 , - 96.25000000 , 2.25000000 , - 4.37500000)
        call s__X3Oracle_Combined(2 , 6 , 11 , - 16.50000000 , 96.25000000 , 2.25000000 , 4.37500000)
        call s__X3Oracle_Combined(2 , 8 , 11 , 46.75000000 , - 60.50000000 , 6.12500000 , - 1.75000000)
        call s__X3Oracle_Combined(2 , 5 , 11 , 46.75000000 , 60.50000000 , 6.12500000 , 1.75000000)
        call s__X3Oracle_Combined(2 , 4 , 11 , 176.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 12 , - 13.50000000 , - 99.75000000 , 3.00000000 , - 3.50000000)
        call s__X3Oracle_Combined(2 , 6 , 12 , - 13.50000000 , 99.75000000 , 3.00000000 , 3.50000000)
        call s__X3Oracle_Combined(2 , 8 , 12 , 53.25000000 , - 61.50000000 , 6.50000000 , - 1.00000000)
        call s__X3Oracle_Combined(2 , 5 , 12 , 53.25000000 , 61.50000000 , 6.50000000 , 1.00000000)
        call s__X3Oracle_Combined(2 , 4 , 12 , 192.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 13 , - 9.75000000 , - 102.37500000 , 3.75000000 , - 2.62500000)
        call s__X3Oracle_Combined(2 , 6 , 13 , - 9.75000000 , 102.37500000 , 3.75000000 , 2.62500000)
        call s__X3Oracle_Combined(2 , 8 , 13 , 60.12500000 , - 61.75000000 , 6.87500000 , - 0.25000000)
        call s__X3Oracle_Combined(2 , 5 , 13 , 60.12500000 , 61.75000000 , 6.87500000 , 0.25000000)
        call s__X3Oracle_Combined(2 , 4 , 13 , 208.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 14 , - 5.25000000 , - 104.12500000 , 4.50000000 , - 1.75000000)
        call s__X3Oracle_Combined(2 , 6 , 14 , - 5.25000000 , 104.12500000 , 4.50000000 , 1.75000000)
        call s__X3Oracle_Combined(2 , 8 , 14 , 67.37500000 , - 61.25000000 , 7.25000000 , 0.50000000)
        call s__X3Oracle_Combined(2 , 5 , 14 , 67.37500000 , 61.25000000 , 7.25000000 , - 0.50000000)
        call s__X3Oracle_Combined(2 , 4 , 14 , 224.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch17 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 7 , 15 , 0.00000000 , - 105.00000000 , 5.25000000 , - 0.87500000)
        call s__X3Oracle_Combined(2 , 6 , 15 , 0.00000000 , 105.00000000 , 5.25000000 , 0.87500000)
        call s__X3Oracle_Combined(2 , 8 , 15 , 75.00000000 , - 60.00000000 , 7.62500000 , 1.25000000)
        call s__X3Oracle_Combined(2 , 5 , 15 , 75.00000000 , 60.00000000 , 7.62500000 , - 1.25000000)
        call s__X3Oracle_Combined(2 , 4 , 15 , 240.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 16 , 6.00000000 , - 105.00000000 , 6.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 6 , 16 , 6.00000000 , 105.00000000 , 6.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 8 , 16 , 83.00000000 , - 58.00000000 , 8.00000000 , 2.00000000)
        call s__X3Oracle_Combined(2 , 5 , 16 , 83.00000000 , 58.00000000 , 8.00000000 , - 2.00000000)
        call s__X3Oracle_Combined(2 , 4 , 16 , 256.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 17 , 12.75000000 , - 104.12500000 , 6.75000000 , 0.87500000)
        call s__X3Oracle_Combined(2 , 6 , 17 , 12.75000000 , 104.12500000 , 6.75000000 , - 0.87500000)
        call s__X3Oracle_Combined(2 , 8 , 17 , 91.37500000 , - 55.25000000 , 8.37500000 , 2.75000000)
        call s__X3Oracle_Combined(2 , 5 , 17 , 91.37500000 , 55.25000000 , 8.37500000 , - 2.75000000)
        call s__X3Oracle_Combined(2 , 4 , 17 , 272.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 18 , 20.25000000 , - 102.37500000 , 7.50000000 , 1.75000000)
        call s__X3Oracle_Combined(2 , 6 , 18 , 20.25000000 , 102.37500000 , 7.50000000 , - 1.75000000)
        call s__X3Oracle_Combined(2 , 8 , 18 , 100.12500000 , - 51.75000000 , 8.75000000 , 3.50000000)
        call s__X3Oracle_Combined(2 , 5 , 18 , 100.12500000 , 51.75000000 , 8.75000000 , - 3.50000000)
        call s__X3Oracle_Combined(2 , 4 , 18 , 288.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch18 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 7 , 19 , 28.50000000 , - 99.75000000 , 8.25000000 , 2.62500000)
        call s__X3Oracle_Combined(2 , 6 , 19 , 28.50000000 , 99.75000000 , 8.25000000 , - 2.62500000)
        call s__X3Oracle_Combined(2 , 8 , 19 , 109.25000000 , - 47.50000000 , 9.12500000 , 4.25000000)
        call s__X3Oracle_Combined(2 , 5 , 19 , 109.25000000 , 47.50000000 , 9.12500000 , - 4.25000000)
        call s__X3Oracle_Combined(2 , 4 , 19 , 304.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 20 , 37.50000000 , - 96.25000000 , 9.00000000 , 3.50000000)
        call s__X3Oracle_Combined(2 , 6 , 20 , 37.50000000 , 96.25000000 , 9.00000000 , - 3.50000000)
        call s__X3Oracle_Combined(2 , 8 , 20 , 118.75000000 , - 42.50000000 , 9.50000000 , 5.00000000)
        call s__X3Oracle_Combined(2 , 5 , 20 , 118.75000000 , 42.50000000 , 9.50000000 , - 5.00000000)
        call s__X3Oracle_Combined(2 , 4 , 20 , 320.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 21 , 47.25000000 , - 91.87500000 , 9.75000000 , 4.37500000)
        call s__X3Oracle_Combined(2 , 6 , 21 , 47.25000000 , 91.87500000 , 9.75000000 , - 4.37500000)
        call s__X3Oracle_Combined(2 , 8 , 21 , 128.62500000 , - 36.75000000 , 9.87500000 , 5.75000000)
        call s__X3Oracle_Combined(2 , 5 , 21 , 128.62500000 , 36.75000000 , 9.87500000 , - 5.75000000)
        call s__X3Oracle_Combined(2 , 4 , 21 , 336.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 22 , 57.75000000 , - 86.62500000 , 10.50000000 , 5.25000000)
        call s__X3Oracle_Combined(2 , 6 , 22 , 57.75000000 , 86.62500000 , 10.50000000 , - 5.25000000)
        call s__X3Oracle_Combined(2 , 8 , 22 , 138.87500000 , - 30.25000000 , 10.25000000 , 6.50000000)
        call s__X3Oracle_Combined(2 , 5 , 22 , 138.87500000 , 30.25000000 , 10.25000000 , - 6.50000000)
        call s__X3Oracle_Combined(2 , 7 , 23 , 69.00000000 , - 80.50000000 , 11.25000000 , 6.12500000)
    endfunction
    function s__X3Oracle_Batch19 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 6 , 23 , 69.00000000 , 80.50000000 , 11.25000000 , - 6.12500000)
        call s__X3Oracle_Combined(2 , 8 , 23 , 149.50000000 , - 23.00000000 , 10.62500000 , 7.25000000)
        call s__X3Oracle_Combined(2 , 5 , 23 , 149.50000000 , 23.00000000 , 10.62500000 , - 7.25000000)
        call s__X3Oracle_Combined(2 , 7 , 24 , 81.00000000 , - 73.50000000 , 12.00000000 , 7.00000000)
        call s__X3Oracle_Combined(2 , 6 , 24 , 81.00000000 , 73.50000000 , 12.00000000 , - 7.00000000)
        call s__X3Oracle_Combined(2 , 8 , 24 , 160.50000000 , - 15.00000000 , 11.00000000 , 8.00000000)
        call s__X3Oracle_Combined(2 , 5 , 24 , 160.50000000 , 15.00000000 , 11.00000000 , - 8.00000000)
        call s__X3Oracle_Combined(2 , 7 , 25 , 93.75000000 , - 65.62500000 , 12.75000000 , 7.87500000)
        call s__X3Oracle_Combined(2 , 6 , 25 , 93.75000000 , 65.62500000 , 12.75000000 , - 7.87500000)
        call s__X3Oracle_Combined(2 , 8 , 25 , 171.87500000 , - 6.25000000 , 11.37500000 , 8.75000000)
        call s__X3Oracle_Combined(2 , 5 , 25 , 171.87500000 , 6.25000000 , 11.37500000 , - 8.75000000)
        call s__X3Oracle_Combined(2 , 7 , 26 , 107.25000000 , - 56.87500000 , 13.50000000 , 8.75000000)
        call s__X3Oracle_Combined(2 , 6 , 26 , 107.25000000 , 56.87500000 , 13.50000000 , - 8.75000000)
        call s__X3Oracle_Combined(2 , 8 , 26 , 183.62500000 , 3.25000000 , 11.75000000 , 9.50000000)
        call s__X3Oracle_Combined(2 , 5 , 26 , 183.62500000 , - 3.25000000 , 11.75000000 , - 9.50000000)
        call s__X3Oracle_Combined(2 , 7 , 27 , 121.50000000 , - 47.25000000 , 14.25000000 , 9.62500000)
        call s__X3Oracle_Combined(2 , 6 , 27 , 121.50000000 , 47.25000000 , 14.25000000 , - 9.62500000)
        call s__X3Oracle_Combined(2 , 8 , 27 , 195.75000000 , 13.50000000 , 12.12500000 , 10.25000000)
        call s__X3Oracle_Combined(2 , 5 , 27 , 195.75000000 , - 13.50000000 , 12.12500000 , - 10.25000000)
        call s__X3Oracle_Combined(2 , 7 , 28 , 136.50000000 , - 36.75000000 , 15.00000000 , 10.50000000)
    endfunction
    function s__X3Oracle_Batch20 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 6 , 28 , 136.50000000 , 36.75000000 , 15.00000000 , - 10.50000000)
        call s__X3Oracle_Combined(2 , 8 , 28 , 208.25000000 , 24.50000000 , 12.50000000 , 11.00000000)
        call s__X3Oracle_Combined(2 , 5 , 28 , 208.25000000 , - 24.50000000 , 12.50000000 , - 11.00000000)
        call s__X3Oracle_Combined(2 , 7 , 29 , 152.25000000 , - 25.37500000 , 15.75000000 , 11.37500000)
        call s__X3Oracle_Combined(2 , 6 , 29 , 152.25000000 , 25.37500000 , 15.75000000 , - 11.37500000)
        call s__X3Oracle_Combined(2 , 8 , 29 , 221.12500000 , 36.25000000 , 12.87500000 , 11.75000000)
        call s__X3Oracle_Combined(2 , 5 , 29 , 221.12500000 , - 36.25000000 , 12.87500000 , - 11.75000000)
        call s__X3Oracle_Combined(2 , 7 , 30 , 168.75000000 , - 13.12500000 , 16.50000000 , 12.25000000)
        call s__X3Oracle_Combined(2 , 6 , 30 , 168.75000000 , 13.12500000 , 16.50000000 , - 12.25000000)
        call s__X3Oracle_Combined(2 , 8 , 30 , 234.37500000 , 48.75000000 , 13.25000000 , 12.50000000)
        call s__X3Oracle_Combined(2 , 5 , 30 , 234.37500000 , - 48.75000000 , 13.25000000 , - 12.50000000)
        call s__X3Oracle_Combined(2 , 7 , 31 , 185.50000000 , - 0.00000000 , 16.75000000 , 13.12500000)
        call s__X3Oracle_Combined(2 , 6 , 31 , 185.50000000 , - 0.00000000 , 16.75000000 , - 13.12500000)
        call s__X3Oracle_Combined(2 , 8 , 31 , 248.00000000 , 62.00000000 , 13.62500000 , 13.25000000)
        call s__X3Oracle_Combined(2 , 5 , 31 , 248.00000000 , - 62.00000000 , 13.62500000 , - 13.25000000)
        call s__X3Oracle_Combined(2 , 7 , 32 , 202.25000000 , 14.00000000 , 16.75000000 , 14.00000000)
        call s__X3Oracle_Combined(2 , 6 , 32 , 202.25000000 , - 14.00000000 , 16.75000000 , - 14.00000000)
        call s__X3Oracle_Combined(2 , 8 , 32 , 262.00000000 , 76.00000000 , 14.00000000 , 14.00000000)
        call s__X3Oracle_Combined(2 , 5 , 32 , 262.00000000 , - 76.00000000 , 14.00000000 , - 14.00000000)
        call s__X3Oracle_Combined(2 , 7 , 33 , 219.00000000 , 28.87500000 , 16.75000000 , 14.87500000)
    endfunction
    function s__X3Oracle_Batch21 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 6 , 33 , 219.00000000 , - 28.87500000 , 16.75000000 , - 14.87500000)
        call s__X3Oracle_Combined(2 , 8 , 33 , 276.37500000 , 90.75000000 , 14.37500000 , 14.75000000)
        call s__X3Oracle_Combined(2 , 5 , 33 , 276.37500000 , - 90.75000000 , 14.37500000 , - 14.75000000)
        call s__X3Oracle_Combined(2 , 7 , 34 , 235.75000000 , 44.62500000 , 16.75000000 , 15.75000000)
        call s__X3Oracle_Combined(2 , 6 , 34 , 235.75000000 , - 44.62500000 , 16.75000000 , - 15.75000000)
        call s__X3Oracle_Combined(2 , 8 , 34 , 291.12500000 , 106.25000000 , 14.75000000 , 15.50000000)
        call s__X3Oracle_Combined(2 , 5 , 34 , 291.12500000 , - 106.25000000 , 14.75000000 , - 15.50000000)
        call s__X3Oracle_Combined(2 , 7 , 35 , 252.50000000 , 61.25000000 , 16.75000000 , 16.62500000)
        call s__X3Oracle_Combined(2 , 6 , 35 , 252.50000000 , - 61.25000000 , 16.75000000 , - 16.62500000)
        call s__X3Oracle_Combined(2 , 8 , 35 , 306.25000000 , 122.50000000 , 15.12500000 , 16.25000000)
        call s__X3Oracle_Combined(2 , 5 , 35 , 306.25000000 , - 122.50000000 , 15.12500000 , - 16.25000000)
        call s__X3Oracle_Combined(2 , 7 , 36 , 269.25000000 , 78.75000000 , 16.75000000 , 17.50000000)
        call s__X3Oracle_Combined(2 , 6 , 36 , 269.25000000 , - 78.75000000 , 16.75000000 , - 17.50000000)
        call s__X3Oracle_Combined(2 , 8 , 36 , 321.75000000 , 139.50000000 , 15.50000000 , 17.00000000)
        call s__X3Oracle_Combined(2 , 5 , 36 , 321.75000000 , - 139.50000000 , 15.50000000 , - 17.00000000)
        call s__X3Oracle_Combined(2 , 7 , 37 , 286.00000000 , 97.12500000 , 16.75000000 , 18.37500000)
        call s__X3Oracle_Combined(2 , 6 , 37 , 286.00000000 , - 97.12500000 , 16.75000000 , - 18.37500000)
        call s__X3Oracle_Combined(2 , 8 , 37 , 337.62500000 , 157.25000000 , 15.87500000 , 17.75000000)
        call s__X3Oracle_Combined(2 , 5 , 37 , 337.62500000 , - 157.25000000 , 15.87500000 , - 17.75000000)
        call s__X3Oracle_Combined(2 , 7 , 38 , 302.75000000 , 116.37500000 , 16.75000000 , 19.25000000)
    endfunction
    function s__X3Oracle_Batch22 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 6 , 38 , 302.75000000 , - 116.37500000 , 16.75000000 , - 19.25000000)
        call s__X3Oracle_Combined(2 , 7 , 39 , 319.50000000 , 136.50000000 , 16.75000000 , 20.12500000)
        call s__X3Oracle_Combined(2 , 6 , 39 , 319.50000000 , - 136.50000000 , 16.75000000 , - 20.12500000)
        call s__X3Oracle_Combined(2 , 7 , 40 , 336.25000000 , 157.50000000 , 16.75000000 , 21.00000000)
        call s__X3Oracle_Combined(2 , 6 , 40 , 336.25000000 , - 157.50000000 , 16.75000000 , - 21.00000000)
        call s__X3Oracle_Combined(1 , 7 , 1 , - 11.25000000 , - 1.50000000 , - 11.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 1 , - 11.25000000 , 1.50000000 , - 11.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 1 , - 15.00781250 , - 3.00000000 , - 15.00781250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 1 , - 15.00781250 , 3.00000000 , - 15.00781250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 1 , 0.18750000 , - 0.00000000 , 0.18750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 2 , - 21.75000000 , - 3.00000000 , - 10.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 2 , - 21.75000000 , 3.00000000 , - 10.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 2 , - 29.02343750 , - 6.00000000 , - 14.01562500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 2 , - 29.02343750 , 6.00000000 , - 14.01562500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 2 , 0.56250000 , - 0.00000000 , 0.37500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 3 , - 31.50000000 , - 4.50000000 , - 9.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 3 , - 31.50000000 , 4.50000000 , - 9.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 3 , - 42.04687500 , - 9.00000000 , - 13.02343750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 3 , - 42.04687500 , 9.00000000 , - 13.02343750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 3 , 1.12500000 , - 0.00000000 , 0.56250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch23 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 4 , - 40.50000000 , - 6.00000000 , - 9.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 4 , - 40.50000000 , 6.00000000 , - 9.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 4 , - 54.07812500 , - 12.00000000 , - 12.03125000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 4 , - 54.07812500 , 12.00000000 , - 12.03125000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 4 , 1.87500000 , - 0.00000000 , 0.75000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 5 , - 48.75000000 , - 7.50000000 , - 8.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 5 , - 48.75000000 , 7.50000000 , - 8.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 5 , - 65.11718750 , - 15.00000000 , - 11.03906250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 5 , - 65.11718750 , 15.00000000 , - 11.03906250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 5 , 2.81250000 , - 0.00000000 , 0.93750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 6 , - 56.25000000 , - 9.00000000 , - 7.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 6 , - 56.25000000 , 9.00000000 , - 7.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 6 , - 75.16406250 , - 18.00000000 , - 10.04687500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 6 , - 75.16406250 , 18.00000000 , - 10.04687500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 6 , 3.93750000 , - 0.00000000 , 1.12500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 7 , - 63.00000000 , - 10.50000000 , - 6.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 7 , - 63.00000000 , 10.50000000 , - 6.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 7 , - 84.21875000 , - 21.00000000 , - 9.05468750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 7 , - 84.21875000 , 21.00000000 , - 9.05468750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 7 , 5.25000000 , - 0.00000000 , 1.31250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch24 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 8 , - 69.00000000 , - 12.00000000 , - 6.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 8 , - 69.00000000 , 12.00000000 , - 6.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 8 , - 92.28125000 , - 24.00000000 , - 8.06250000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 8 , - 92.28125000 , 24.00000000 , - 8.06250000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 8 , 6.75000000 , - 0.00000000 , 1.50000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 9 , - 74.25000000 , - 13.50000000 , - 5.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 9 , - 74.25000000 , 13.50000000 , - 5.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 9 , - 99.35156250 , - 27.00000000 , - 7.07031250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 9 , - 99.35156250 , 27.00000000 , - 7.07031250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 9 , 8.43750000 , - 0.00000000 , 1.68750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 10 , - 78.75000000 , - 15.00000000 , - 4.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 10 , - 78.75000000 , 15.00000000 , - 4.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 10 , - 105.42968750 , - 30.00000000 , - 6.07812500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 10 , - 105.42968750 , 30.00000000 , - 6.07812500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 10 , 10.31250000 , - 0.00000000 , 1.87500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 11 , - 82.50000000 , - 16.50000000 , - 3.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 11 , - 82.50000000 , 16.50000000 , - 3.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 11 , - 110.51562500 , - 33.00000000 , - 5.08593750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 11 , - 110.51562500 , 33.00000000 , - 5.08593750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 11 , 12.37500000 , - 0.00000000 , 2.06250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch25 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 12 , - 85.50000000 , - 18.00000000 , - 3.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 12 , - 85.50000000 , 18.00000000 , - 3.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 12 , - 114.60937500 , - 36.00000000 , - 4.09375000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 12 , - 114.60937500 , 36.00000000 , - 4.09375000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 12 , 14.62500000 , - 0.00000000 , 2.25000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 13 , - 87.75000000 , - 19.50000000 , - 2.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 13 , - 87.75000000 , 19.50000000 , - 2.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 13 , - 117.71093750 , - 39.00000000 , - 3.10156250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 13 , - 117.71093750 , 39.00000000 , - 3.10156250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 13 , 17.06250000 , - 0.00000000 , 2.43750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 14 , - 89.25000000 , - 21.00000000 , - 1.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 14 , - 89.25000000 , 21.00000000 , - 1.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 14 , - 119.82031250 , - 42.00000000 , - 2.10937500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 14 , - 119.82031250 , 42.00000000 , - 2.10937500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 14 , 19.68750000 , - 0.00000000 , 2.62500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 15 , - 90.00000000 , - 22.50000000 , - 0.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 15 , - 90.00000000 , 22.50000000 , - 0.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 15 , - 120.93750000 , - 45.00000000 , - 1.11718750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 15 , - 120.93750000 , 45.00000000 , - 1.11718750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 15 , 22.50000000 , - 0.00000000 , 2.81250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch26 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 16 , - 90.00000000 , - 24.00000000 , - 0.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 16 , - 90.00000000 , 24.00000000 , - 0.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 16 , - 121.06250000 , - 48.00000000 , - 0.12500000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 16 , - 121.06250000 , 48.00000000 , - 0.12500000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 16 , 25.50000000 , - 0.00000000 , 3.00000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 17 , - 89.25000000 , - 25.50000000 , 0.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 17 , - 89.25000000 , 25.50000000 , 0.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 17 , - 120.19531250 , - 51.00000000 , 0.86718750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 17 , - 120.19531250 , 51.00000000 , 0.86718750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 17 , 28.68750000 , - 0.00000000 , 3.18750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 18 , - 87.75000000 , - 27.00000000 , 1.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 18 , - 87.75000000 , 27.00000000 , 1.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 18 , - 118.33593750 , - 54.00000000 , 1.85937500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 18 , - 118.33593750 , 54.00000000 , 1.85937500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 18 , 32.06250000 , - 0.00000000 , 3.37500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 19 , - 85.50000000 , - 28.50000000 , 2.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 19 , - 85.50000000 , 28.50000000 , 2.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 19 , - 115.48437500 , - 57.00000000 , 2.85156250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 19 , - 115.48437500 , 57.00000000 , 2.85156250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 19 , 35.62500000 , - 0.00000000 , 3.56250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch27 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 20 , - 82.50000000 , - 30.00000000 , 3.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 20 , - 82.50000000 , 30.00000000 , 3.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 20 , - 111.64062500 , - 60.00000000 , 3.84375000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 20 , - 111.64062500 , 60.00000000 , 3.84375000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 20 , 39.37500000 , - 0.00000000 , 3.75000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 21 , - 78.75000000 , - 31.50000000 , 3.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 21 , - 78.75000000 , 31.50000000 , 3.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 21 , - 106.80468750 , - 63.00000000 , 4.83593750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 21 , - 106.80468750 , 63.00000000 , 4.83593750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 21 , 43.31250000 , - 0.00000000 , 3.93750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 22 , - 74.25000000 , - 33.00000000 , 4.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 22 , - 74.25000000 , 33.00000000 , 4.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 22 , - 100.97656250 , - 66.00000000 , 5.82812500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 22 , - 100.97656250 , 66.00000000 , 5.82812500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 22 , 47.43750000 , - 0.00000000 , 4.12500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 23 , - 69.00000000 , - 34.50000000 , 5.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 23 , - 69.00000000 , 34.50000000 , 5.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 23 , - 94.15625000 , - 69.00000000 , 6.82031250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 23 , - 94.15625000 , 69.00000000 , 6.82031250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 23 , 51.75000000 , - 0.00000000 , 4.31250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch28 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 24 , - 63.00000000 , - 36.00000000 , 6.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 24 , - 63.00000000 , 36.00000000 , 6.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 24 , - 86.34375000 , - 72.00000000 , 7.81250000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 24 , - 86.34375000 , 72.00000000 , 7.81250000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 24 , 56.25000000 , - 0.00000000 , 4.50000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 25 , - 56.25000000 , - 37.50000000 , 6.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 25 , - 56.25000000 , 37.50000000 , 6.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 25 , - 77.53906250 , - 75.00000000 , 8.80468750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 25 , - 77.53906250 , 75.00000000 , 8.80468750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 25 , 60.93750000 , - 0.00000000 , 4.68750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 26 , - 48.75000000 , - 39.00000000 , 7.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 26 , - 48.75000000 , 39.00000000 , 7.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 26 , - 67.74218750 , - 78.00000000 , 9.79687500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 26 , - 67.74218750 , 78.00000000 , 9.79687500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 26 , 65.81250000 , - 0.00000000 , 4.87500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 27 , - 40.50000000 , - 40.50000000 , 8.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 27 , - 40.50000000 , 40.50000000 , 8.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 27 , - 56.95312500 , - 81.00000000 , 10.78906250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 27 , - 56.95312500 , 81.00000000 , 10.78906250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 27 , 70.87500000 , - 0.00000000 , 5.06250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch29 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 28 , - 31.50000000 , - 42.00000000 , 9.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 28 , - 31.50000000 , 42.00000000 , 9.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 28 , - 45.17187500 , - 84.00000000 , 11.78125000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 28 , - 45.17187500 , 84.00000000 , 11.78125000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 28 , 76.12500000 , - 0.00000000 , 5.25000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 29 , - 21.75000000 , - 43.50000000 , 9.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 29 , - 21.75000000 , 43.50000000 , 9.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 29 , - 32.39843750 , - 87.00000000 , 12.77343750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 29 , - 32.39843750 , 87.00000000 , 12.77343750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 29 , 81.56250000 , - 0.00000000 , 5.43750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 30 , - 11.25000000 , - 45.00000000 , 10.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 30 , - 11.25000000 , 45.00000000 , 10.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 30 , - 18.63281250 , - 90.00000000 , 13.76562500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 30 , - 18.63281250 , 90.00000000 , 13.76562500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 30 , 87.18750000 , - 0.00000000 , 5.62500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 31 , - 0.00000000 , - 46.50000000 , 11.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 31 , - 0.00000000 , 46.50000000 , 11.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 31 , - 3.87500000 , - 93.00000000 , 14.75781250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 31 , - 3.87500000 , 93.00000000 , 14.75781250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 31 , 93.00000000 , - 0.00000000 , 5.81250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch30 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 32 , 12.00000000 , - 48.00000000 , 12.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 32 , 12.00000000 , 48.00000000 , 12.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 32 , 11.87500000 , - 96.00000000 , 15.75000000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 32 , 11.87500000 , 96.00000000 , 15.75000000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 32 , 99.00000000 , - 0.00000000 , 6.00000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 33 , 24.75000000 , - 49.50000000 , 12.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 33 , 24.75000000 , 49.50000000 , 12.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 33 , 28.61718750 , - 99.00000000 , 16.74218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 33 , 28.61718750 , 99.00000000 , 16.74218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 33 , 105.18750000 , - 0.00000000 , 6.18750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 34 , 38.25000000 , - 51.00000000 , 13.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 34 , 38.25000000 , 51.00000000 , 13.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 34 , 45.60937500 , - 102.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 34 , 45.60937500 , 102.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 34 , 111.56250000 , - 0.00000000 , 6.37500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 35 , 52.50000000 , - 52.50000000 , 14.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 35 , 52.50000000 , 52.50000000 , 14.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 35 , 62.60156250 , - 105.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 35 , 62.60156250 , 105.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 35 , 118.12500000 , - 0.00000000 , 6.56250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch31 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 36 , 67.50000000 , - 54.00000000 , 15.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 36 , 67.50000000 , 54.00000000 , 15.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 36 , 79.59375000 , - 108.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 36 , 79.59375000 , 108.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 36 , 124.87500000 , - 0.00000000 , 6.75000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 37 , 83.25000000 , - 55.50000000 , 15.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 37 , 83.25000000 , 55.50000000 , 15.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 37 , 96.58593750 , - 111.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 37 , 96.58593750 , 111.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 37 , 131.81250000 , - 0.00000000 , 6.93750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 38 , 99.75000000 , - 57.00000000 , 16.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 38 , 99.75000000 , 57.00000000 , 16.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 38 , 113.57812500 , - 114.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 38 , 113.57812500 , 114.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 38 , 138.93750000 , - 0.00000000 , 7.12500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 39 , 116.50000000 , - 58.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 39 , 116.50000000 , 58.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 39 , 130.57031250 , - 117.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 39 , 130.57031250 , 117.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 39 , 146.25000000 , - 0.00000000 , 7.31250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch32 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 40 , 133.25000000 , - 60.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 40 , 133.25000000 , 60.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 40 , 147.56250000 , - 120.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 40 , 147.56250000 , 120.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 40 , 153.75000000 , - 0.00000000 , 7.50000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 41 , 150.00000000 , - 61.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 41 , 150.00000000 , 61.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 41 , 164.55468750 , - 123.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 41 , 164.55468750 , 123.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 41 , 161.43750000 , - 0.00000000 , 7.68750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 42 , 166.75000000 , - 63.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 42 , 166.75000000 , 63.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 42 , 181.54687500 , - 126.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 42 , 181.54687500 , 126.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 42 , 169.31250000 , - 0.00000000 , 7.87500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 43 , 183.50000000 , - 64.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 43 , 183.50000000 , 64.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 43 , 198.53906250 , - 129.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 43 , 198.53906250 , 129.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 43 , 177.37500000 , - 0.00000000 , 8.06250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch33 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 44 , 200.25000000 , - 66.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 44 , 200.25000000 , 66.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 44 , 215.53125000 , - 132.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 44 , 215.53125000 , 132.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 44 , 185.62500000 , - 0.00000000 , 8.25000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 45 , 217.00000000 , - 67.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 45 , 217.00000000 , 67.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 4 , 45 , 194.06250000 , - 0.00000000 , 8.43750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 46 , 202.68750000 , - 0.00000000 , 8.62500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 47 , 211.50000000 , - 0.00000000 , 8.81250000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 1 , - 5.25000000 , - 13.12500000 , - 5.25000000 , - 13.12500000)
        call s__X3Oracle_Combined(2 , 6 , 1 , - 5.25000000 , 13.12500000 , - 5.25000000 , 13.12500000)
        call s__X3Oracle_Combined(2 , 8 , 1 , 2.37500000 , - 9.25000000 , 2.37500000 , - 9.25000000)
        call s__X3Oracle_Combined(2 , 5 , 1 , 2.37500000 , 9.25000000 , 2.37500000 , 9.25000000)
        call s__X3Oracle_Combined(2 , 4 , 1 , 16.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 2 , - 9.75000000 , - 25.37500000 , - 4.50000000 , - 12.25000000)
        call s__X3Oracle_Combined(2 , 6 , 2 , - 9.75000000 , 25.37500000 , - 4.50000000 , 12.25000000)
        call s__X3Oracle_Combined(2 , 8 , 2 , 5.12500000 , - 17.75000000 , 2.75000000 , - 8.50000000)
        call s__X3Oracle_Combined(2 , 5 , 2 , 5.12500000 , 17.75000000 , 2.75000000 , 8.50000000)
        call s__X3Oracle_Combined(2 , 4 , 2 , 32.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch34 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 7 , 3 , - 13.50000000 , - 36.75000000 , - 3.75000000 , - 11.37500000)
        call s__X3Oracle_Combined(2 , 6 , 3 , - 13.50000000 , 36.75000000 , - 3.75000000 , 11.37500000)
        call s__X3Oracle_Combined(2 , 8 , 3 , 8.25000000 , - 25.50000000 , 3.12500000 , - 7.75000000)
        call s__X3Oracle_Combined(2 , 5 , 3 , 8.25000000 , 25.50000000 , 3.12500000 , 7.75000000)
        call s__X3Oracle_Combined(2 , 4 , 3 , 48.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 4 , - 16.50000000 , - 47.25000000 , - 3.00000000 , - 10.50000000)
        call s__X3Oracle_Combined(2 , 6 , 4 , - 16.50000000 , 47.25000000 , - 3.00000000 , 10.50000000)
        call s__X3Oracle_Combined(2 , 8 , 4 , 11.75000000 , - 32.50000000 , 3.50000000 , - 7.00000000)
        call s__X3Oracle_Combined(2 , 5 , 4 , 11.75000000 , 32.50000000 , 3.50000000 , 7.00000000)
        call s__X3Oracle_Combined(2 , 4 , 4 , 64.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 5 , - 18.75000000 , - 56.87500000 , - 2.25000000 , - 9.62500000)
        call s__X3Oracle_Combined(2 , 6 , 5 , - 18.75000000 , 56.87500000 , - 2.25000000 , 9.62500000)
        call s__X3Oracle_Combined(2 , 8 , 5 , 15.62500000 , - 38.75000000 , 3.87500000 , - 6.25000000)
        call s__X3Oracle_Combined(2 , 5 , 5 , 15.62500000 , 38.75000000 , 3.87500000 , 6.25000000)
        call s__X3Oracle_Combined(2 , 4 , 5 , 80.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 6 , - 20.25000000 , - 65.62500000 , - 1.50000000 , - 8.75000000)
        call s__X3Oracle_Combined(2 , 6 , 6 , - 20.25000000 , 65.62500000 , - 1.50000000 , 8.75000000)
        call s__X3Oracle_Combined(2 , 8 , 6 , 19.87500000 , - 44.25000000 , 4.25000000 , - 5.50000000)
        call s__X3Oracle_Combined(2 , 5 , 6 , 19.87500000 , 44.25000000 , 4.25000000 , 5.50000000)
        call s__X3Oracle_Combined(2 , 4 , 6 , 96.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch35 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 7 , 7 , - 21.00000000 , - 73.50000000 , - 0.75000000 , - 7.87500000)
        call s__X3Oracle_Combined(2 , 6 , 7 , - 21.00000000 , 73.50000000 , - 0.75000000 , 7.87500000)
        call s__X3Oracle_Combined(2 , 8 , 7 , 24.50000000 , - 49.00000000 , 4.62500000 , - 4.75000000)
        call s__X3Oracle_Combined(2 , 5 , 7 , 24.50000000 , 49.00000000 , 4.62500000 , 4.75000000)
        call s__X3Oracle_Combined(2 , 4 , 7 , 112.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 8 , - 21.00000000 , - 80.50000000 , - 0.00000000 , - 7.00000000)
        call s__X3Oracle_Combined(2 , 6 , 8 , - 21.00000000 , 80.50000000 , - 0.00000000 , 7.00000000)
        call s__X3Oracle_Combined(2 , 8 , 8 , 29.50000000 , - 53.00000000 , 5.00000000 , - 4.00000000)
        call s__X3Oracle_Combined(2 , 5 , 8 , 29.50000000 , 53.00000000 , 5.00000000 , 4.00000000)
        call s__X3Oracle_Combined(2 , 4 , 8 , 128.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 9 , - 20.25000000 , - 86.62500000 , 0.75000000 , - 6.12500000)
        call s__X3Oracle_Combined(2 , 6 , 9 , - 20.25000000 , 86.62500000 , 0.75000000 , 6.12500000)
        call s__X3Oracle_Combined(2 , 8 , 9 , 34.87500000 , - 56.25000000 , 5.37500000 , - 3.25000000)
        call s__X3Oracle_Combined(2 , 5 , 9 , 34.87500000 , 56.25000000 , 5.37500000 , 3.25000000)
        call s__X3Oracle_Combined(2 , 4 , 9 , 144.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 10 , - 18.75000000 , - 91.87500000 , 1.50000000 , - 5.25000000)
        call s__X3Oracle_Combined(2 , 6 , 10 , - 18.75000000 , 91.87500000 , 1.50000000 , 5.25000000)
        call s__X3Oracle_Combined(2 , 8 , 10 , 40.62500000 , - 58.75000000 , 5.75000000 , - 2.50000000)
        call s__X3Oracle_Combined(2 , 5 , 10 , 40.62500000 , 58.75000000 , 5.75000000 , 2.50000000)
        call s__X3Oracle_Combined(2 , 4 , 10 , 160.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch36 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 7 , 11 , - 16.50000000 , - 96.25000000 , 2.25000000 , - 4.37500000)
        call s__X3Oracle_Combined(2 , 6 , 11 , - 16.50000000 , 96.25000000 , 2.25000000 , 4.37500000)
        call s__X3Oracle_Combined(2 , 8 , 11 , 46.75000000 , - 60.50000000 , 6.12500000 , - 1.75000000)
        call s__X3Oracle_Combined(2 , 5 , 11 , 46.75000000 , 60.50000000 , 6.12500000 , 1.75000000)
        call s__X3Oracle_Combined(2 , 4 , 11 , 176.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 12 , - 13.50000000 , - 99.75000000 , 3.00000000 , - 3.50000000)
        call s__X3Oracle_Combined(2 , 6 , 12 , - 13.50000000 , 99.75000000 , 3.00000000 , 3.50000000)
        call s__X3Oracle_Combined(2 , 8 , 12 , 53.25000000 , - 61.50000000 , 6.50000000 , - 1.00000000)
        call s__X3Oracle_Combined(2 , 5 , 12 , 53.25000000 , 61.50000000 , 6.50000000 , 1.00000000)
        call s__X3Oracle_Combined(2 , 4 , 12 , 192.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 13 , - 9.75000000 , - 102.37500000 , 3.75000000 , - 2.62500000)
        call s__X3Oracle_Combined(2 , 6 , 13 , - 9.75000000 , 102.37500000 , 3.75000000 , 2.62500000)
        call s__X3Oracle_Combined(2 , 8 , 13 , 60.12500000 , - 61.75000000 , 6.87500000 , - 0.25000000)
        call s__X3Oracle_Combined(2 , 5 , 13 , 60.12500000 , 61.75000000 , 6.87500000 , 0.25000000)
        call s__X3Oracle_Combined(2 , 4 , 13 , 208.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 14 , - 5.25000000 , - 104.12500000 , 4.50000000 , - 1.75000000)
        call s__X3Oracle_Combined(2 , 6 , 14 , - 5.25000000 , 104.12500000 , 4.50000000 , 1.75000000)
        call s__X3Oracle_Combined(2 , 8 , 14 , 67.37500000 , - 61.25000000 , 7.25000000 , 0.50000000)
        call s__X3Oracle_Combined(2 , 5 , 14 , 67.37500000 , 61.25000000 , 7.25000000 , - 0.50000000)
        call s__X3Oracle_Combined(2 , 7 , 15 , - 0.00000000 , - 105.00000000 , 5.25000000 , - 0.87500000)
    endfunction
    function s__X3Oracle_Batch37 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 6 , 15 , - 0.00000000 , 105.00000000 , 5.25000000 , 0.87500000)
        call s__X3Oracle_Combined(2 , 8 , 15 , 75.00000000 , - 60.00000000 , 7.62500000 , 1.25000000)
        call s__X3Oracle_Combined(2 , 5 , 15 , 75.00000000 , 60.00000000 , 7.62500000 , - 1.25000000)
        call s__X3Oracle_Combined(2 , 7 , 16 , 6.00000000 , - 105.00000000 , 6.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 6 , 16 , 6.00000000 , 105.00000000 , 6.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 8 , 16 , 83.00000000 , - 58.00000000 , 8.00000000 , 2.00000000)
        call s__X3Oracle_Combined(2 , 5 , 16 , 83.00000000 , 58.00000000 , 8.00000000 , - 2.00000000)
        call s__X3Oracle_Combined(2 , 7 , 17 , 12.75000000 , - 104.12500000 , 6.75000000 , 0.87500000)
        call s__X3Oracle_Combined(2 , 6 , 17 , 12.75000000 , 104.12500000 , 6.75000000 , - 0.87500000)
        call s__X3Oracle_Combined(2 , 8 , 17 , 91.37500000 , - 55.25000000 , 8.37500000 , 2.75000000)
        call s__X3Oracle_Combined(2 , 5 , 17 , 91.37500000 , 55.25000000 , 8.37500000 , - 2.75000000)
        call s__X3Oracle_Combined(2 , 7 , 18 , 20.25000000 , - 102.37500000 , 7.50000000 , 1.75000000)
        call s__X3Oracle_Combined(2 , 6 , 18 , 20.25000000 , 102.37500000 , 7.50000000 , - 1.75000000)
        call s__X3Oracle_Combined(2 , 8 , 18 , 100.12500000 , - 51.75000000 , 8.75000000 , 3.50000000)
        call s__X3Oracle_Combined(2 , 5 , 18 , 100.12500000 , 51.75000000 , 8.75000000 , - 3.50000000)
        call s__X3Oracle_Combined(2 , 7 , 19 , 28.50000000 , - 99.75000000 , 8.25000000 , 2.62500000)
        call s__X3Oracle_Combined(2 , 6 , 19 , 28.50000000 , 99.75000000 , 8.25000000 , - 2.62500000)
        call s__X3Oracle_Combined(2 , 8 , 19 , 109.25000000 , - 47.50000000 , 9.12500000 , 4.25000000)
        call s__X3Oracle_Combined(2 , 5 , 19 , 109.25000000 , 47.50000000 , 9.12500000 , - 4.25000000)
        call s__X3Oracle_Combined(2 , 7 , 20 , 37.50000000 , - 96.25000000 , 9.00000000 , 3.50000000)
    endfunction
    function s__X3Oracle_Batch38 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 6 , 20 , 37.50000000 , 96.25000000 , 9.00000000 , - 3.50000000)
        call s__X3Oracle_Combined(2 , 8 , 20 , 118.75000000 , - 42.50000000 , 9.50000000 , 5.00000000)
        call s__X3Oracle_Combined(2 , 5 , 20 , 118.75000000 , 42.50000000 , 9.50000000 , - 5.00000000)
        call s__X3Oracle_Combined(2 , 7 , 21 , 47.25000000 , - 91.87500000 , 9.75000000 , 4.37500000)
        call s__X3Oracle_Combined(2 , 6 , 21 , 47.25000000 , 91.87500000 , 9.75000000 , - 4.37500000)
        call s__X3Oracle_Combined(2 , 8 , 21 , 128.62500000 , - 36.75000000 , 9.87500000 , 5.75000000)
        call s__X3Oracle_Combined(2 , 5 , 21 , 128.62500000 , 36.75000000 , 9.87500000 , - 5.75000000)
        call s__X3Oracle_Combined(2 , 7 , 22 , 57.75000000 , - 86.62500000 , 10.50000000 , 5.25000000)
        call s__X3Oracle_Combined(2 , 6 , 22 , 57.75000000 , 86.62500000 , 10.50000000 , - 5.25000000)
        call s__X3Oracle_Combined(2 , 8 , 22 , 138.87500000 , - 30.25000000 , 10.25000000 , 6.50000000)
        call s__X3Oracle_Combined(2 , 5 , 22 , 138.87500000 , 30.25000000 , 10.25000000 , - 6.50000000)
        call s__X3Oracle_Combined(2 , 7 , 23 , 69.00000000 , - 80.50000000 , 11.25000000 , 6.12500000)
        call s__X3Oracle_Combined(2 , 6 , 23 , 69.00000000 , 80.50000000 , 11.25000000 , - 6.12500000)
        call s__X3Oracle_Combined(2 , 8 , 23 , 149.50000000 , - 23.00000000 , 10.62500000 , 7.25000000)
        call s__X3Oracle_Combined(2 , 5 , 23 , 149.50000000 , 23.00000000 , 10.62500000 , - 7.25000000)
        call s__X3Oracle_Combined(2 , 7 , 24 , 81.00000000 , - 73.50000000 , 12.00000000 , 7.00000000)
        call s__X3Oracle_Combined(2 , 6 , 24 , 81.00000000 , 73.50000000 , 12.00000000 , - 7.00000000)
        call s__X3Oracle_Combined(2 , 8 , 24 , 160.50000000 , - 15.00000000 , 11.00000000 , 8.00000000)
        call s__X3Oracle_Combined(2 , 5 , 24 , 160.50000000 , 15.00000000 , 11.00000000 , - 8.00000000)
        call s__X3Oracle_Combined(2 , 7 , 25 , 93.75000000 , - 65.62500000 , 12.75000000 , 7.87500000)
    endfunction
    function s__X3Oracle_Batch39 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 6 , 25 , 93.75000000 , 65.62500000 , 12.75000000 , - 7.87500000)
        call s__X3Oracle_Combined(2 , 8 , 25 , 171.87500000 , - 6.25000000 , 11.37500000 , 8.75000000)
        call s__X3Oracle_Combined(2 , 5 , 25 , 171.87500000 , 6.25000000 , 11.37500000 , - 8.75000000)
        call s__X3Oracle_Combined(2 , 7 , 26 , 107.25000000 , - 56.87500000 , 13.50000000 , 8.75000000)
        call s__X3Oracle_Combined(2 , 6 , 26 , 107.25000000 , 56.87500000 , 13.50000000 , - 8.75000000)
        call s__X3Oracle_Combined(2 , 8 , 26 , 183.62500000 , 3.25000000 , 11.75000000 , 9.50000000)
        call s__X3Oracle_Combined(2 , 5 , 26 , 183.62500000 , - 3.25000000 , 11.75000000 , - 9.50000000)
        call s__X3Oracle_Combined(2 , 7 , 27 , 121.50000000 , - 47.25000000 , 14.25000000 , 9.62500000)
        call s__X3Oracle_Combined(2 , 6 , 27 , 121.50000000 , 47.25000000 , 14.25000000 , - 9.62500000)
        call s__X3Oracle_Combined(2 , 8 , 27 , 195.75000000 , 13.50000000 , 12.12500000 , 10.25000000)
        call s__X3Oracle_Combined(2 , 5 , 27 , 195.75000000 , - 13.50000000 , 12.12500000 , - 10.25000000)
        call s__X3Oracle_Combined(2 , 7 , 28 , 136.50000000 , - 36.75000000 , 15.00000000 , 10.50000000)
        call s__X3Oracle_Combined(2 , 6 , 28 , 136.50000000 , 36.75000000 , 15.00000000 , - 10.50000000)
        call s__X3Oracle_Combined(2 , 8 , 28 , 208.25000000 , 24.50000000 , 12.50000000 , 11.00000000)
        call s__X3Oracle_Combined(2 , 5 , 28 , 208.25000000 , - 24.50000000 , 12.50000000 , - 11.00000000)
        call s__X3Oracle_Combined(2 , 7 , 29 , 152.25000000 , - 25.37500000 , 15.75000000 , 11.37500000)
        call s__X3Oracle_Combined(2 , 6 , 29 , 152.25000000 , 25.37500000 , 15.75000000 , - 11.37500000)
        call s__X3Oracle_Combined(2 , 7 , 30 , 168.75000000 , - 13.12500000 , 16.50000000 , 12.25000000)
        call s__X3Oracle_Combined(2 , 6 , 30 , 168.75000000 , 13.12500000 , 16.50000000 , - 12.25000000)
        call s__X3Oracle_Combined(2 , 7 , 31 , 185.50000000 , - 0.00000000 , 16.75000000 , 13.12500000)
    endfunction
    function s__X3Oracle_Batch40 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 6 , 31 , 185.50000000 , - 0.00000000 , 16.75000000 , - 13.12500000)
        call s__X3Oracle_Combined(2 , 7 , 32 , 202.25000000 , 14.00000000 , 16.75000000 , 14.00000000)
        call s__X3Oracle_Combined(2 , 6 , 32 , 202.25000000 , - 14.00000000 , 16.75000000 , - 14.00000000)
        call s__X3Oracle_Combined(2 , 7 , 33 , 219.00000000 , 28.87500000 , 16.75000000 , 14.87500000)
        call s__X3Oracle_Combined(2 , 6 , 33 , 219.00000000 , - 28.87500000 , 16.75000000 , - 14.87500000)
        call s__X3Oracle_Combined(1 , 7 , 1 , - 11.25000000 , - 1.50000000 , - 11.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 1 , - 11.25000000 , 1.50000000 , - 11.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 1 , - 15.00781250 , - 3.00000000 , - 15.00781250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 1 , - 15.00781250 , 3.00000000 , - 15.00781250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 1 , 0.18750000 , - 0.00000000 , 0.18750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 2 , - 21.75000000 , - 3.00000000 , - 10.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 2 , - 21.75000000 , 3.00000000 , - 10.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 2 , - 29.02343750 , - 6.00000000 , - 14.01562500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 2 , - 29.02343750 , 6.00000000 , - 14.01562500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 2 , 0.56250000 , - 0.00000000 , 0.37500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 3 , - 31.50000000 , - 4.50000000 , - 9.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 3 , - 31.50000000 , 4.50000000 , - 9.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 3 , - 42.04687500 , - 9.00000000 , - 13.02343750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 3 , - 42.04687500 , 9.00000000 , - 13.02343750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 3 , 1.12500000 , - 0.00000000 , 0.56250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch41 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 4 , - 40.50000000 , - 6.00000000 , - 9.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 4 , - 40.50000000 , 6.00000000 , - 9.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 4 , - 54.07812500 , - 12.00000000 , - 12.03125000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 4 , - 54.07812500 , 12.00000000 , - 12.03125000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 4 , 1.87500000 , - 0.00000000 , 0.75000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 5 , - 48.75000000 , - 7.50000000 , - 8.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 5 , - 48.75000000 , 7.50000000 , - 8.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 5 , - 65.11718750 , - 15.00000000 , - 11.03906250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 5 , - 65.11718750 , 15.00000000 , - 11.03906250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 5 , 2.81250000 , - 0.00000000 , 0.93750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 6 , - 56.25000000 , - 9.00000000 , - 7.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 6 , - 56.25000000 , 9.00000000 , - 7.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 6 , - 75.16406250 , - 18.00000000 , - 10.04687500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 6 , - 75.16406250 , 18.00000000 , - 10.04687500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 6 , 3.93750000 , - 0.00000000 , 1.12500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 7 , - 63.00000000 , - 10.50000000 , - 6.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 7 , - 63.00000000 , 10.50000000 , - 6.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 7 , - 84.21875000 , - 21.00000000 , - 9.05468750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 7 , - 84.21875000 , 21.00000000 , - 9.05468750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 7 , 5.25000000 , - 0.00000000 , 1.31250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch42 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 8 , - 69.00000000 , - 12.00000000 , - 6.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 8 , - 69.00000000 , 12.00000000 , - 6.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 8 , - 92.28125000 , - 24.00000000 , - 8.06250000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 8 , - 92.28125000 , 24.00000000 , - 8.06250000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 8 , 6.75000000 , - 0.00000000 , 1.50000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 9 , - 74.25000000 , - 13.50000000 , - 5.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 9 , - 74.25000000 , 13.50000000 , - 5.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 9 , - 99.35156250 , - 27.00000000 , - 7.07031250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 9 , - 99.35156250 , 27.00000000 , - 7.07031250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 9 , 8.43750000 , - 0.00000000 , 1.68750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 10 , - 78.75000000 , - 15.00000000 , - 4.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 10 , - 78.75000000 , 15.00000000 , - 4.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 10 , - 105.42968750 , - 30.00000000 , - 6.07812500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 10 , - 105.42968750 , 30.00000000 , - 6.07812500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 10 , 10.31250000 , - 0.00000000 , 1.87500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 11 , - 82.50000000 , - 16.50000000 , - 3.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 11 , - 82.50000000 , 16.50000000 , - 3.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 11 , - 110.51562500 , - 33.00000000 , - 5.08593750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 11 , - 110.51562500 , 33.00000000 , - 5.08593750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 11 , 12.37500000 , - 0.00000000 , 2.06250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch43 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 12 , - 85.50000000 , - 18.00000000 , - 3.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 12 , - 85.50000000 , 18.00000000 , - 3.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 12 , - 114.60937500 , - 36.00000000 , - 4.09375000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 12 , - 114.60937500 , 36.00000000 , - 4.09375000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 12 , 14.62500000 , - 0.00000000 , 2.25000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 13 , - 87.75000000 , - 19.50000000 , - 2.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 13 , - 87.75000000 , 19.50000000 , - 2.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 13 , - 117.71093750 , - 39.00000000 , - 3.10156250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 13 , - 117.71093750 , 39.00000000 , - 3.10156250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 13 , 17.06250000 , - 0.00000000 , 2.43750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 14 , - 89.25000000 , - 21.00000000 , - 1.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 14 , - 89.25000000 , 21.00000000 , - 1.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 14 , - 119.82031250 , - 42.00000000 , - 2.10937500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 14 , - 119.82031250 , 42.00000000 , - 2.10937500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 14 , 19.68750000 , - 0.00000000 , 2.62500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 15 , - 90.00000000 , - 22.50000000 , - 0.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 15 , - 90.00000000 , 22.50000000 , - 0.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 15 , - 120.93750000 , - 45.00000000 , - 1.11718750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 15 , - 120.93750000 , 45.00000000 , - 1.11718750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 15 , 22.50000000 , - 0.00000000 , 2.81250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch44 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 16 , - 90.00000000 , - 24.00000000 , 0.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 16 , - 90.00000000 , 24.00000000 , 0.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 16 , - 121.06250000 , - 48.00000000 , - 0.12500000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 16 , - 121.06250000 , 48.00000000 , - 0.12500000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 16 , 25.50000000 , - 0.00000000 , 3.00000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 17 , - 89.25000000 , - 25.50000000 , 0.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 17 , - 89.25000000 , 25.50000000 , 0.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 17 , - 120.19531250 , - 51.00000000 , 0.86718750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 17 , - 120.19531250 , 51.00000000 , 0.86718750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 17 , 28.68750000 , - 0.00000000 , 3.18750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 18 , - 87.75000000 , - 27.00000000 , 1.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 18 , - 87.75000000 , 27.00000000 , 1.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 18 , - 118.33593750 , - 54.00000000 , 1.85937500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 18 , - 118.33593750 , 54.00000000 , 1.85937500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 18 , 32.06250000 , - 0.00000000 , 3.37500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 19 , - 85.50000000 , - 28.50000000 , 2.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 19 , - 85.50000000 , 28.50000000 , 2.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 19 , - 115.48437500 , - 57.00000000 , 2.85156250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 19 , - 115.48437500 , 57.00000000 , 2.85156250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 19 , 35.62500000 , - 0.00000000 , 3.56250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch45 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 20 , - 82.50000000 , - 30.00000000 , 3.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 20 , - 82.50000000 , 30.00000000 , 3.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 20 , - 111.64062500 , - 60.00000000 , 3.84375000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 20 , - 111.64062500 , 60.00000000 , 3.84375000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 20 , 39.37500000 , - 0.00000000 , 3.75000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 21 , - 78.75000000 , - 31.50000000 , 3.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 21 , - 78.75000000 , 31.50000000 , 3.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 21 , - 106.80468750 , - 63.00000000 , 4.83593750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 21 , - 106.80468750 , 63.00000000 , 4.83593750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 21 , 43.31250000 , - 0.00000000 , 3.93750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 22 , - 74.25000000 , - 33.00000000 , 4.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 22 , - 74.25000000 , 33.00000000 , 4.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 22 , - 100.97656250 , - 66.00000000 , 5.82812500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 22 , - 100.97656250 , 66.00000000 , 5.82812500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 22 , 47.43750000 , - 0.00000000 , 4.12500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 23 , - 69.00000000 , - 34.50000000 , 5.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 23 , - 69.00000000 , 34.50000000 , 5.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 23 , - 94.15625000 , - 69.00000000 , 6.82031250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 23 , - 94.15625000 , 69.00000000 , 6.82031250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 23 , 51.75000000 , - 0.00000000 , 4.31250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch46 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 24 , - 63.00000000 , - 36.00000000 , 6.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 24 , - 63.00000000 , 36.00000000 , 6.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 24 , - 86.34375000 , - 72.00000000 , 7.81250000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 24 , - 86.34375000 , 72.00000000 , 7.81250000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 24 , 56.25000000 , - 0.00000000 , 4.50000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 25 , - 56.25000000 , - 37.50000000 , 6.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 25 , - 56.25000000 , 37.50000000 , 6.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 25 , - 77.53906250 , - 75.00000000 , 8.80468750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 25 , - 77.53906250 , 75.00000000 , 8.80468750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 25 , 60.93750000 , - 0.00000000 , 4.68750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 26 , - 48.75000000 , - 39.00000000 , 7.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 26 , - 48.75000000 , 39.00000000 , 7.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 26 , - 67.74218750 , - 78.00000000 , 9.79687500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 26 , - 67.74218750 , 78.00000000 , 9.79687500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 26 , 65.81250000 , - 0.00000000 , 4.87500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 27 , - 40.50000000 , - 40.50000000 , 8.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 27 , - 40.50000000 , 40.50000000 , 8.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 27 , - 56.95312500 , - 81.00000000 , 10.78906250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 27 , - 56.95312500 , 81.00000000 , 10.78906250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 27 , 70.87500000 , - 0.00000000 , 5.06250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch47 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 28 , - 31.50000000 , - 42.00000000 , 9.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 28 , - 31.50000000 , 42.00000000 , 9.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 28 , - 45.17187500 , - 84.00000000 , 11.78125000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 28 , - 45.17187500 , 84.00000000 , 11.78125000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 28 , 76.12500000 , - 0.00000000 , 5.25000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 29 , - 21.75000000 , - 43.50000000 , 9.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 29 , - 21.75000000 , 43.50000000 , 9.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 29 , - 32.39843750 , - 87.00000000 , 12.77343750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 29 , - 32.39843750 , 87.00000000 , 12.77343750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 29 , 81.56250000 , - 0.00000000 , 5.43750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 30 , - 11.25000000 , - 45.00000000 , 10.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 30 , - 11.25000000 , 45.00000000 , 10.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 30 , - 18.63281250 , - 90.00000000 , 13.76562500 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 30 , - 18.63281250 , 90.00000000 , 13.76562500 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 30 , 87.18750000 , - 0.00000000 , 5.62500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 31 , 0.00000000 , - 46.50000000 , 11.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 31 , 0.00000000 , 46.50000000 , 11.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 31 , - 3.87500000 , - 93.00000000 , 14.75781250 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 31 , - 3.87500000 , 93.00000000 , 14.75781250 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 31 , 93.00000000 , - 0.00000000 , 5.81250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch48 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 32 , 12.00000000 , - 48.00000000 , 12.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 32 , 12.00000000 , 48.00000000 , 12.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 32 , 11.87500000 , - 96.00000000 , 15.75000000 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 32 , 11.87500000 , 96.00000000 , 15.75000000 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 32 , 99.00000000 , - 0.00000000 , 6.00000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 33 , 24.75000000 , - 49.50000000 , 12.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 33 , 24.75000000 , 49.50000000 , 12.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 33 , 28.61718750 , - 99.00000000 , 16.74218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 33 , 28.61718750 , 99.00000000 , 16.74218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 33 , 105.18750000 , - 0.00000000 , 6.18750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 34 , 38.25000000 , - 51.00000000 , 13.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 34 , 38.25000000 , 51.00000000 , 13.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 34 , 45.60937500 , - 102.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 34 , 45.60937500 , 102.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 34 , 111.56250000 , - 0.00000000 , 6.37500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 35 , 52.50000000 , - 52.50000000 , 14.25000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 35 , 52.50000000 , 52.50000000 , 14.25000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 35 , 62.60156250 , - 105.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 35 , 62.60156250 , 105.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 35 , 118.12500000 , - 0.00000000 , 6.56250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch49 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 36 , 67.50000000 , - 54.00000000 , 15.00000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 36 , 67.50000000 , 54.00000000 , 15.00000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 36 , 79.59375000 , - 108.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 36 , 79.59375000 , 108.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 36 , 124.87500000 , - 0.00000000 , 6.75000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 37 , 83.25000000 , - 55.50000000 , 15.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 37 , 83.25000000 , 55.50000000 , 15.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 37 , 96.58593750 , - 111.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 37 , 96.58593750 , 111.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 37 , 131.81250000 , - 0.00000000 , 6.93750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 38 , 99.75000000 , - 57.00000000 , 16.50000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 38 , 99.75000000 , 57.00000000 , 16.50000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 38 , 113.57812500 , - 114.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 38 , 113.57812500 , 114.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 38 , 138.93750000 , - 0.00000000 , 7.12500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 39 , 116.50000000 , - 58.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 39 , 116.50000000 , 58.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 39 , 130.57031250 , - 117.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 39 , 130.57031250 , 117.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 39 , 146.25000000 , - 0.00000000 , 7.31250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch50 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 40 , 133.25000000 , - 60.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 40 , 133.25000000 , 60.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 40 , 147.56250000 , - 120.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 40 , 147.56250000 , 120.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 40 , 153.75000000 , - 0.00000000 , 7.50000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 41 , 150.00000000 , - 61.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 41 , 150.00000000 , 61.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 41 , 164.55468750 , - 123.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 41 , 164.55468750 , 123.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 41 , 161.43750000 , - 0.00000000 , 7.68750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 42 , 166.75000000 , - 63.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 42 , 166.75000000 , 63.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 42 , 181.54687500 , - 126.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 42 , 181.54687500 , 126.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 42 , 169.31250000 , - 0.00000000 , 7.87500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 43 , 183.50000000 , - 64.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 43 , 183.50000000 , 64.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 43 , 198.53906250 , - 129.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 43 , 198.53906250 , 129.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 43 , 177.37500000 , - 0.00000000 , 8.06250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch51 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 44 , 200.25000000 , - 66.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 44 , 200.25000000 , 66.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 44 , 215.53125000 , - 132.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 44 , 215.53125000 , 132.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 44 , 185.62500000 , - 0.00000000 , 8.25000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 45 , 217.00000000 , - 67.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 45 , 217.00000000 , 67.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 45 , 232.52343750 , - 135.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 45 , 232.52343750 , 135.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 45 , 194.06250000 , - 0.00000000 , 8.43750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 46 , 233.75000000 , - 69.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 46 , 233.75000000 , 69.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 46 , 249.51562500 , - 138.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 46 , 249.51562500 , 138.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 46 , 202.68750000 , - 0.00000000 , 8.62500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 47 , 250.50000000 , - 70.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 47 , 250.50000000 , 70.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 47 , 266.50781250 , - 141.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 47 , 266.50781250 , 141.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 47 , 211.50000000 , - 0.00000000 , 8.81250000 , 0.00000000)
    endfunction
    function s__X3Oracle_Batch52 takes nothing returns nothing
        call s__X3Oracle_Combined(1 , 7 , 48 , 267.25000000 , - 72.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 48 , 267.25000000 , 72.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 48 , 283.50000000 , - 144.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 48 , 283.50000000 , 144.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 48 , 220.50000000 , - 0.00000000 , 9.00000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 49 , 284.00000000 , - 73.50000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 49 , 284.00000000 , 73.50000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 8 , 49 , 300.49218750 , - 147.00000000 , 16.99218750 , - 3.00000000)
        call s__X3Oracle_Combined(1 , 5 , 49 , 300.49218750 , 147.00000000 , 16.99218750 , 3.00000000)
        call s__X3Oracle_Combined(1 , 4 , 49 , 229.68750000 , - 0.00000000 , 9.18750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 7 , 50 , 300.75000000 , - 75.00000000 , 16.75000000 , - 1.50000000)
        call s__X3Oracle_Combined(1 , 6 , 50 , 300.75000000 , 75.00000000 , 16.75000000 , 1.50000000)
        call s__X3Oracle_Combined(1 , 4 , 50 , 239.06250000 , - 0.00000000 , 9.37500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 51 , 248.62500000 , - 0.00000000 , 9.56250000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 52 , 258.37500000 , - 0.00000000 , 9.75000000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 53 , 268.31250000 , - 0.00000000 , 9.93750000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 54 , 278.43750000 , - 0.00000000 , 10.12500000 , 0.00000000)
        call s__X3Oracle_Combined(1 , 4 , 55 , 288.75000000 , - 0.00000000 , 10.31250000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 1 , - 5.25000000 , - 13.12500000 , - 5.25000000 , - 13.12500000)
        call s__X3Oracle_Combined(2 , 6 , 1 , - 5.25000000 , 13.12500000 , - 5.25000000 , 13.12500000)
    endfunction
    function s__X3Oracle_Batch53 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 8 , 1 , 2.37500000 , - 9.25000000 , 2.37500000 , - 9.25000000)
        call s__X3Oracle_Combined(2 , 5 , 1 , 2.37500000 , 9.25000000 , 2.37500000 , 9.25000000)
        call s__X3Oracle_Combined(2 , 4 , 1 , 16.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 2 , - 9.75000000 , - 25.37500000 , - 4.50000000 , - 12.25000000)
        call s__X3Oracle_Combined(2 , 6 , 2 , - 9.75000000 , 25.37500000 , - 4.50000000 , 12.25000000)
        call s__X3Oracle_Combined(2 , 8 , 2 , 5.12500000 , - 17.75000000 , 2.75000000 , - 8.50000000)
        call s__X3Oracle_Combined(2 , 5 , 2 , 5.12500000 , 17.75000000 , 2.75000000 , 8.50000000)
        call s__X3Oracle_Combined(2 , 4 , 2 , 32.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 3 , - 13.50000000 , - 36.75000000 , - 3.75000000 , - 11.37500000)
        call s__X3Oracle_Combined(2 , 6 , 3 , - 13.50000000 , 36.75000000 , - 3.75000000 , 11.37500000)
        call s__X3Oracle_Combined(2 , 8 , 3 , 8.25000000 , - 25.50000000 , 3.12500000 , - 7.75000000)
        call s__X3Oracle_Combined(2 , 5 , 3 , 8.25000000 , 25.50000000 , 3.12500000 , 7.75000000)
        call s__X3Oracle_Combined(2 , 4 , 3 , 48.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 4 , - 16.50000000 , - 47.25000000 , - 3.00000000 , - 10.50000000)
        call s__X3Oracle_Combined(2 , 6 , 4 , - 16.50000000 , 47.25000000 , - 3.00000000 , 10.50000000)
        call s__X3Oracle_Combined(2 , 8 , 4 , 11.75000000 , - 32.50000000 , 3.50000000 , - 7.00000000)
        call s__X3Oracle_Combined(2 , 5 , 4 , 11.75000000 , 32.50000000 , 3.50000000 , 7.00000000)
        call s__X3Oracle_Combined(2 , 4 , 4 , 64.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 5 , - 18.75000000 , - 56.87500000 , - 2.25000000 , - 9.62500000)
        call s__X3Oracle_Combined(2 , 6 , 5 , - 18.75000000 , 56.87500000 , - 2.25000000 , 9.62500000)
    endfunction
    function s__X3Oracle_Batch54 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 8 , 5 , 15.62500000 , - 38.75000000 , 3.87500000 , - 6.25000000)
        call s__X3Oracle_Combined(2 , 5 , 5 , 15.62500000 , 38.75000000 , 3.87500000 , 6.25000000)
        call s__X3Oracle_Combined(2 , 4 , 5 , 80.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 6 , - 20.25000000 , - 65.62500000 , - 1.50000000 , - 8.75000000)
        call s__X3Oracle_Combined(2 , 6 , 6 , - 20.25000000 , 65.62500000 , - 1.50000000 , 8.75000000)
        call s__X3Oracle_Combined(2 , 8 , 6 , 19.87500000 , - 44.25000000 , 4.25000000 , - 5.50000000)
        call s__X3Oracle_Combined(2 , 5 , 6 , 19.87500000 , 44.25000000 , 4.25000000 , 5.50000000)
        call s__X3Oracle_Combined(2 , 4 , 6 , 96.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 7 , - 21.00000000 , - 73.50000000 , - 0.75000000 , - 7.87500000)
        call s__X3Oracle_Combined(2 , 6 , 7 , - 21.00000000 , 73.50000000 , - 0.75000000 , 7.87500000)
        call s__X3Oracle_Combined(2 , 8 , 7 , 24.50000000 , - 49.00000000 , 4.62500000 , - 4.75000000)
        call s__X3Oracle_Combined(2 , 5 , 7 , 24.50000000 , 49.00000000 , 4.62500000 , 4.75000000)
        call s__X3Oracle_Combined(2 , 4 , 7 , 112.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 8 , - 21.00000000 , - 80.50000000 , 0.00000000 , - 7.00000000)
        call s__X3Oracle_Combined(2 , 6 , 8 , - 21.00000000 , 80.50000000 , 0.00000000 , 7.00000000)
        call s__X3Oracle_Combined(2 , 8 , 8 , 29.50000000 , - 53.00000000 , 5.00000000 , - 4.00000000)
        call s__X3Oracle_Combined(2 , 5 , 8 , 29.50000000 , 53.00000000 , 5.00000000 , 4.00000000)
        call s__X3Oracle_Combined(2 , 4 , 8 , 128.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 9 , - 20.25000000 , - 86.62500000 , 0.75000000 , - 6.12500000)
        call s__X3Oracle_Combined(2 , 6 , 9 , - 20.25000000 , 86.62500000 , 0.75000000 , 6.12500000)
    endfunction
    function s__X3Oracle_Batch55 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 8 , 9 , 34.87500000 , - 56.25000000 , 5.37500000 , - 3.25000000)
        call s__X3Oracle_Combined(2 , 5 , 9 , 34.87500000 , 56.25000000 , 5.37500000 , 3.25000000)
        call s__X3Oracle_Combined(2 , 4 , 9 , 144.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 10 , - 18.75000000 , - 91.87500000 , 1.50000000 , - 5.25000000)
        call s__X3Oracle_Combined(2 , 6 , 10 , - 18.75000000 , 91.87500000 , 1.50000000 , 5.25000000)
        call s__X3Oracle_Combined(2 , 8 , 10 , 40.62500000 , - 58.75000000 , 5.75000000 , - 2.50000000)
        call s__X3Oracle_Combined(2 , 5 , 10 , 40.62500000 , 58.75000000 , 5.75000000 , 2.50000000)
        call s__X3Oracle_Combined(2 , 4 , 10 , 160.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 11 , - 16.50000000 , - 96.25000000 , 2.25000000 , - 4.37500000)
        call s__X3Oracle_Combined(2 , 6 , 11 , - 16.50000000 , 96.25000000 , 2.25000000 , 4.37500000)
        call s__X3Oracle_Combined(2 , 8 , 11 , 46.75000000 , - 60.50000000 , 6.12500000 , - 1.75000000)
        call s__X3Oracle_Combined(2 , 5 , 11 , 46.75000000 , 60.50000000 , 6.12500000 , 1.75000000)
        call s__X3Oracle_Combined(2 , 4 , 11 , 176.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 12 , - 13.50000000 , - 99.75000000 , 3.00000000 , - 3.50000000)
        call s__X3Oracle_Combined(2 , 6 , 12 , - 13.50000000 , 99.75000000 , 3.00000000 , 3.50000000)
        call s__X3Oracle_Combined(2 , 8 , 12 , 53.25000000 , - 61.50000000 , 6.50000000 , - 1.00000000)
        call s__X3Oracle_Combined(2 , 5 , 12 , 53.25000000 , 61.50000000 , 6.50000000 , 1.00000000)
        call s__X3Oracle_Combined(2 , 4 , 12 , 192.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 13 , - 9.75000000 , - 102.37500000 , 3.75000000 , - 2.62500000)
        call s__X3Oracle_Combined(2 , 6 , 13 , - 9.75000000 , 102.37500000 , 3.75000000 , 2.62500000)
    endfunction
    function s__X3Oracle_Batch56 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 8 , 13 , 60.12500000 , - 61.75000000 , 6.87500000 , - 0.25000000)
        call s__X3Oracle_Combined(2 , 5 , 13 , 60.12500000 , 61.75000000 , 6.87500000 , 0.25000000)
        call s__X3Oracle_Combined(2 , 4 , 13 , 208.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 14 , - 5.25000000 , - 104.12500000 , 4.50000000 , - 1.75000000)
        call s__X3Oracle_Combined(2 , 6 , 14 , - 5.25000000 , 104.12500000 , 4.50000000 , 1.75000000)
        call s__X3Oracle_Combined(2 , 8 , 14 , 67.37500000 , - 61.25000000 , 7.25000000 , 0.50000000)
        call s__X3Oracle_Combined(2 , 5 , 14 , 67.37500000 , 61.25000000 , 7.25000000 , - 0.50000000)
        call s__X3Oracle_Combined(2 , 4 , 14 , 224.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 15 , 0.00000000 , - 105.00000000 , 5.25000000 , - 0.87500000)
        call s__X3Oracle_Combined(2 , 6 , 15 , 0.00000000 , 105.00000000 , 5.25000000 , 0.87500000)
        call s__X3Oracle_Combined(2 , 8 , 15 , 75.00000000 , - 60.00000000 , 7.62500000 , 1.25000000)
        call s__X3Oracle_Combined(2 , 5 , 15 , 75.00000000 , 60.00000000 , 7.62500000 , - 1.25000000)
        call s__X3Oracle_Combined(2 , 4 , 15 , 240.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 16 , 6.00000000 , - 105.00000000 , 6.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 6 , 16 , 6.00000000 , 105.00000000 , 6.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 8 , 16 , 83.00000000 , - 58.00000000 , 8.00000000 , 2.00000000)
        call s__X3Oracle_Combined(2 , 5 , 16 , 83.00000000 , 58.00000000 , 8.00000000 , - 2.00000000)
        call s__X3Oracle_Combined(2 , 4 , 16 , 256.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 17 , 12.75000000 , - 104.12500000 , 6.75000000 , 0.87500000)
        call s__X3Oracle_Combined(2 , 6 , 17 , 12.75000000 , 104.12500000 , 6.75000000 , - 0.87500000)
    endfunction
    function s__X3Oracle_Batch57 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 8 , 17 , 91.37500000 , - 55.25000000 , 8.37500000 , 2.75000000)
        call s__X3Oracle_Combined(2 , 5 , 17 , 91.37500000 , 55.25000000 , 8.37500000 , - 2.75000000)
        call s__X3Oracle_Combined(2 , 4 , 17 , 272.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 18 , 20.25000000 , - 102.37500000 , 7.50000000 , 1.75000000)
        call s__X3Oracle_Combined(2 , 6 , 18 , 20.25000000 , 102.37500000 , 7.50000000 , - 1.75000000)
        call s__X3Oracle_Combined(2 , 8 , 18 , 100.12500000 , - 51.75000000 , 8.75000000 , 3.50000000)
        call s__X3Oracle_Combined(2 , 5 , 18 , 100.12500000 , 51.75000000 , 8.75000000 , - 3.50000000)
        call s__X3Oracle_Combined(2 , 4 , 18 , 288.00000000 , - 0.00000000 , 16.00000000 , 0.00000000)
        call s__X3Oracle_Combined(2 , 7 , 19 , 28.50000000 , - 99.75000000 , 8.25000000 , 2.62500000)
        call s__X3Oracle_Combined(2 , 6 , 19 , 28.50000000 , 99.75000000 , 8.25000000 , - 2.62500000)
        call s__X3Oracle_Combined(2 , 8 , 19 , 109.25000000 , - 47.50000000 , 9.12500000 , 4.25000000)
        call s__X3Oracle_Combined(2 , 5 , 19 , 109.25000000 , 47.50000000 , 9.12500000 , - 4.25000000)
        call s__X3Oracle_Combined(2 , 7 , 20 , 37.50000000 , - 96.25000000 , 9.00000000 , 3.50000000)
        call s__X3Oracle_Combined(2 , 6 , 20 , 37.50000000 , 96.25000000 , 9.00000000 , - 3.50000000)
        call s__X3Oracle_Combined(2 , 8 , 20 , 118.75000000 , - 42.50000000 , 9.50000000 , 5.00000000)
        call s__X3Oracle_Combined(2 , 5 , 20 , 118.75000000 , 42.50000000 , 9.50000000 , - 5.00000000)
        call s__X3Oracle_Combined(2 , 7 , 21 , 47.25000000 , - 91.87500000 , 9.75000000 , 4.37500000)
        call s__X3Oracle_Combined(2 , 6 , 21 , 47.25000000 , 91.87500000 , 9.75000000 , - 4.37500000)
        call s__X3Oracle_Combined(2 , 8 , 21 , 128.62500000 , - 36.75000000 , 9.87500000 , 5.75000000)
        call s__X3Oracle_Combined(2 , 5 , 21 , 128.62500000 , 36.75000000 , 9.87500000 , - 5.75000000)
    endfunction
    function s__X3Oracle_Batch58 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 7 , 22 , 57.75000000 , - 86.62500000 , 10.50000000 , 5.25000000)
        call s__X3Oracle_Combined(2 , 6 , 22 , 57.75000000 , 86.62500000 , 10.50000000 , - 5.25000000)
        call s__X3Oracle_Combined(2 , 8 , 22 , 138.87500000 , - 30.25000000 , 10.25000000 , 6.50000000)
        call s__X3Oracle_Combined(2 , 5 , 22 , 138.87500000 , 30.25000000 , 10.25000000 , - 6.50000000)
        call s__X3Oracle_Combined(2 , 7 , 23 , 69.00000000 , - 80.50000000 , 11.25000000 , 6.12500000)
        call s__X3Oracle_Combined(2 , 6 , 23 , 69.00000000 , 80.50000000 , 11.25000000 , - 6.12500000)
        call s__X3Oracle_Combined(2 , 8 , 23 , 149.50000000 , - 23.00000000 , 10.62500000 , 7.25000000)
        call s__X3Oracle_Combined(2 , 5 , 23 , 149.50000000 , 23.00000000 , 10.62500000 , - 7.25000000)
        call s__X3Oracle_Combined(2 , 7 , 24 , 81.00000000 , - 73.50000000 , 12.00000000 , 7.00000000)
        call s__X3Oracle_Combined(2 , 6 , 24 , 81.00000000 , 73.50000000 , 12.00000000 , - 7.00000000)
        call s__X3Oracle_Combined(2 , 8 , 24 , 160.50000000 , - 15.00000000 , 11.00000000 , 8.00000000)
        call s__X3Oracle_Combined(2 , 5 , 24 , 160.50000000 , 15.00000000 , 11.00000000 , - 8.00000000)
        call s__X3Oracle_Combined(2 , 7 , 25 , 93.75000000 , - 65.62500000 , 12.75000000 , 7.87500000)
        call s__X3Oracle_Combined(2 , 6 , 25 , 93.75000000 , 65.62500000 , 12.75000000 , - 7.87500000)
        call s__X3Oracle_Combined(2 , 8 , 25 , 171.87500000 , - 6.25000000 , 11.37500000 , 8.75000000)
        call s__X3Oracle_Combined(2 , 5 , 25 , 171.87500000 , 6.25000000 , 11.37500000 , - 8.75000000)
        call s__X3Oracle_Combined(2 , 7 , 26 , 107.25000000 , - 56.87500000 , 13.50000000 , 8.75000000)
        call s__X3Oracle_Combined(2 , 6 , 26 , 107.25000000 , 56.87500000 , 13.50000000 , - 8.75000000)
        call s__X3Oracle_Combined(2 , 8 , 26 , 183.62500000 , 3.25000000 , 11.75000000 , 9.50000000)
        call s__X3Oracle_Combined(2 , 5 , 26 , 183.62500000 , - 3.25000000 , 11.75000000 , - 9.50000000)
    endfunction
    function s__X3Oracle_Batch59 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 7 , 27 , 121.50000000 , - 47.25000000 , 14.25000000 , 9.62500000)
        call s__X3Oracle_Combined(2 , 6 , 27 , 121.50000000 , 47.25000000 , 14.25000000 , - 9.62500000)
        call s__X3Oracle_Combined(2 , 8 , 27 , 195.75000000 , 13.50000000 , 12.12500000 , 10.25000000)
        call s__X3Oracle_Combined(2 , 5 , 27 , 195.75000000 , - 13.50000000 , 12.12500000 , - 10.25000000)
        call s__X3Oracle_Combined(2 , 7 , 28 , 136.50000000 , - 36.75000000 , 15.00000000 , 10.50000000)
        call s__X3Oracle_Combined(2 , 6 , 28 , 136.50000000 , 36.75000000 , 15.00000000 , - 10.50000000)
        call s__X3Oracle_Combined(2 , 8 , 28 , 208.25000000 , 24.50000000 , 12.50000000 , 11.00000000)
        call s__X3Oracle_Combined(2 , 5 , 28 , 208.25000000 , - 24.50000000 , 12.50000000 , - 11.00000000)
        call s__X3Oracle_Combined(2 , 7 , 29 , 152.25000000 , - 25.37500000 , 15.75000000 , 11.37500000)
        call s__X3Oracle_Combined(2 , 6 , 29 , 152.25000000 , 25.37500000 , 15.75000000 , - 11.37500000)
        call s__X3Oracle_Combined(2 , 8 , 29 , 221.12500000 , 36.25000000 , 12.87500000 , 11.75000000)
        call s__X3Oracle_Combined(2 , 5 , 29 , 221.12500000 , - 36.25000000 , 12.87500000 , - 11.75000000)
        call s__X3Oracle_Combined(2 , 7 , 30 , 168.75000000 , - 13.12500000 , 16.50000000 , 12.25000000)
        call s__X3Oracle_Combined(2 , 6 , 30 , 168.75000000 , 13.12500000 , 16.50000000 , - 12.25000000)
        call s__X3Oracle_Combined(2 , 8 , 30 , 234.37500000 , 48.75000000 , 13.25000000 , 12.50000000)
        call s__X3Oracle_Combined(2 , 5 , 30 , 234.37500000 , - 48.75000000 , 13.25000000 , - 12.50000000)
        call s__X3Oracle_Combined(2 , 7 , 31 , 185.50000000 , - 0.00000000 , 16.75000000 , 13.12500000)
        call s__X3Oracle_Combined(2 , 6 , 31 , 185.50000000 , - 0.00000000 , 16.75000000 , - 13.12500000)
        call s__X3Oracle_Combined(2 , 8 , 31 , 248.00000000 , 62.00000000 , 13.62500000 , 13.25000000)
        call s__X3Oracle_Combined(2 , 5 , 31 , 248.00000000 , - 62.00000000 , 13.62500000 , - 13.25000000)
    endfunction
    function s__X3Oracle_Batch60 takes nothing returns nothing
        call s__X3Oracle_Combined(2 , 7 , 32 , 202.25000000 , 14.00000000 , 16.75000000 , 14.00000000)
        call s__X3Oracle_Combined(2 , 6 , 32 , 202.25000000 , - 14.00000000 , 16.75000000 , - 14.00000000)
        call s__X3Oracle_Combined(2 , 8 , 32 , 262.00000000 , 76.00000000 , 14.00000000 , 14.00000000)
        call s__X3Oracle_Combined(2 , 5 , 32 , 262.00000000 , - 76.00000000 , 14.00000000 , - 14.00000000)
        call s__X3Oracle_Combined(2 , 7 , 33 , 219.00000000 , 28.87500000 , 16.75000000 , 14.87500000)
        call s__X3Oracle_Combined(2 , 6 , 33 , 219.00000000 , - 28.87500000 , 16.75000000 , - 14.87500000)
        call s__X3Oracle_Combined(2 , 8 , 33 , 276.37500000 , 90.75000000 , 14.37500000 , 14.75000000)
        call s__X3Oracle_Combined(2 , 5 , 33 , 276.37500000 , - 90.75000000 , 14.37500000 , - 14.75000000)
        call s__X3Oracle_Combined(2 , 7 , 34 , 235.75000000 , 44.62500000 , 16.75000000 , 15.75000000)
        call s__X3Oracle_Combined(2 , 6 , 34 , 235.75000000 , - 44.62500000 , 16.75000000 , - 15.75000000)
        call s__X3Oracle_Combined(2 , 8 , 34 , 291.12500000 , 106.25000000 , 14.75000000 , 15.50000000)
        call s__X3Oracle_Combined(2 , 5 , 34 , 291.12500000 , - 106.25000000 , 14.75000000 , - 15.50000000)
        call s__X3Oracle_Combined(2 , 7 , 35 , 252.50000000 , 61.25000000 , 16.75000000 , 16.62500000)
        call s__X3Oracle_Combined(2 , 6 , 35 , 252.50000000 , - 61.25000000 , 16.75000000 , - 16.62500000)
        call s__X3Oracle_Combined(2 , 7 , 36 , 269.25000000 , 78.75000000 , 16.75000000 , 17.50000000)
        call s__X3Oracle_Combined(2 , 6 , 36 , 269.25000000 , - 78.75000000 , 16.75000000 , - 17.50000000)
        call s__X3Oracle_Combined(2 , 7 , 37 , 286.00000000 , 97.12500000 , 16.75000000 , 18.37500000)
        call s__X3Oracle_Combined(2 , 6 , 37 , 286.00000000 , - 97.12500000 , 16.75000000 , - 18.37500000)
        call s__X3Oracle_Combined(2 , 7 , 38 , 302.75000000 , 116.37500000 , 16.75000000 , 19.25000000)
        call s__X3Oracle_Combined(2 , 6 , 38 , 302.75000000 , - 116.37500000 , 16.75000000 , - 19.25000000)
    endfunction
    function s__X3Oracle_Batch61 takes nothing returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(1) / s__X3Kinematics_FPS) , 1.06250000)
        call s__X3Oracle_Orb(9 , 1 , 1.00000000 , - 10.00000000)
        call s__X3Oracle_Orb(2 , 1 , 17.00000000 , - 12.00000000)
        call s__X3Oracle_Orb(1 , 1 , 9.00000000 , 8.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(2) / s__X3Kinematics_FPS) , 2.18750000)
        call s__X3Oracle_Orb(9 , 2 , 1.00000000 , 2.00000000)
        call s__X3Oracle_Orb(2 , 2 , 17.00000000 , - 16.00000000)
        call s__X3Oracle_Orb(1 , 2 , 9.00000000 , - 4.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(3) / s__X3Kinematics_FPS) , 3.37500000)
        call s__X3Oracle_Orb(9 , 3 , 3.00000000 , 8.00000000)
        call s__X3Oracle_Orb(2 , 3 , 19.00000000 , - 18.00000000)
        call s__X3Oracle_Orb(1 , 3 , 11.00000000 , - 10.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(4) / s__X3Kinematics_FPS) , 4.62500000)
        call s__X3Oracle_Orb(9 , 4 , 3.00000000 , 14.00000000)
        call s__X3Oracle_Orb(2 , 4 , 19.00000000 , - 16.00000000)
        call s__X3Oracle_Orb(1 , 4 , 11.00000000 , - 16.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(5) / s__X3Kinematics_FPS) , 5.93750000)
        call s__X3Oracle_Orb(9 , 5 , 5.00000000 , 26.00000000)
        call s__X3Oracle_Orb(2 , 5 , 21.00000000 , - 12.00000000)
        call s__X3Oracle_Orb(1 , 5 , 13.00000000 , - 28.00000000)
    endfunction
    function s__X3Oracle_Batch62 takes nothing returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(6) / s__X3Kinematics_FPS) , 7.31250000)
        call s__X3Oracle_Orb(9 , 6 , 7.00000000 , 30.00000000)
        call s__X3Oracle_Orb(2 , 6 , 23.00000000 , - 0.00000000)
        call s__X3Oracle_Orb(1 , 6 , 15.00000000 , - 32.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(7) / s__X3Kinematics_FPS) , 8.75000000)
        call s__X3Oracle_Orb(9 , 7 , 7.00000000 , 32.00000000)
        call s__X3Oracle_Orb(2 , 7 , 23.00000000 , 6.00000000)
        call s__X3Oracle_Orb(1 , 7 , 15.00000000 , - 34.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(8) / s__X3Kinematics_FPS) , 10.25000000)
        call s__X3Oracle_Orb(9 , 8 , 9.00000000 , 30.00000000)
        call s__X3Oracle_Orb(2 , 8 , 25.00000000 , 12.00000000)
        call s__X3Oracle_Orb(1 , 8 , 17.00000000 , - 32.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(9) / s__X3Kinematics_FPS) , 11.81250000)
        call s__X3Oracle_Orb(9 , 9 , 11.00000000 , 26.00000000)
        call s__X3Oracle_Orb(2 , 9 , 27.00000000 , 24.00000000)
        call s__X3Oracle_Orb(1 , 9 , 19.00000000 , - 28.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(10) / s__X3Kinematics_FPS) , 13.43750000)
        call s__X3Oracle_Orb(9 , 10 , 13.00000000 , 14.00000000)
        call s__X3Oracle_Orb(2 , 10 , 29.00000000 , 28.00000000)
        call s__X3Oracle_Orb(1 , 10 , 21.00000000 , - 16.00000000)
    endfunction
    function s__X3Oracle_Batch63 takes nothing returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(11) / s__X3Kinematics_FPS) , 15.12500000)
        call s__X3Oracle_Orb(9 , 11 , 15.00000000 , 8.00000000)
        call s__X3Oracle_Orb(2 , 11 , 31.00000000 , 30.00000000)
        call s__X3Oracle_Orb(1 , 11 , 23.00000000 , - 10.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(12) / s__X3Kinematics_FPS) , 16.87500000)
        call s__X3Oracle_Orb(9 , 12 , 15.00000000 , 2.00000000)
        call s__X3Oracle_Orb(2 , 12 , 31.00000000 , 28.00000000)
        call s__X3Oracle_Orb(1 , 12 , 23.00000000 , - 4.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(13) / s__X3Kinematics_FPS) , 18.68750000)
        call s__X3Oracle_Orb(9 , 13 , 17.00000000 , - 10.00000000)
        call s__X3Oracle_Orb(2 , 13 , 33.00000000 , 24.00000000)
        call s__X3Oracle_Orb(1 , 13 , 25.00000000 , 8.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(14) / s__X3Kinematics_FPS) , 20.56250000)
        call s__X3Oracle_Orb(9 , 14 , 19.00000000 , - 14.00000000)
        call s__X3Oracle_Orb(2 , 14 , 35.00000000 , 12.00000000)
        call s__X3Oracle_Orb(1 , 14 , 27.00000000 , 12.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(15) / s__X3Kinematics_FPS) , 22.50000000)
        call s__X3Oracle_Orb(9 , 15 , 21.00000000 , - 16.00000000)
        call s__X3Oracle_Orb(2 , 15 , 37.00000000 , 6.00000000)
        call s__X3Oracle_Orb(1 , 15 , 29.00000000 , 14.00000000)
    endfunction
    function s__X3Oracle_Batch64 takes nothing returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(16) / s__X3Kinematics_FPS) , 24.93750000)
        call s__X3Oracle_Orb(9 , 16 , 23.00000000 , - 14.00000000)
        call s__X3Oracle_Orb(2 , 16 , 39.00000000 , - 0.00000000)
        call s__X3Oracle_Orb(1 , 16 , 31.00000000 , 12.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(17) / s__X3Kinematics_FPS) , 27.87500000)
        call s__X3Oracle_Orb(9 , 17 , 27.00000000 , - 10.00000000)
        call s__X3Oracle_Orb(2 , 17 , 43.00000000 , - 12.00000000)
        call s__X3Oracle_Orb(1 , 17 , 35.00000000 , 8.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(18) / s__X3Kinematics_FPS) , 31.31250000)
        call s__X3Oracle_Orb(9 , 18 , 31.00000000 , 2.00000000)
        call s__X3Oracle_Orb(2 , 18 , 47.00000000 , - 16.00000000)
        call s__X3Oracle_Orb(1 , 18 , 39.00000000 , - 4.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(19) / s__X3Kinematics_FPS) , 35.25000000)
        call s__X3Oracle_Orb(9 , 19 , 35.00000000 , 8.00000000)
        call s__X3Oracle_Orb(2 , 19 , 51.00000000 , - 18.00000000)
        call s__X3Oracle_Orb(1 , 19 , 43.00000000 , - 10.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(20) / s__X3Kinematics_FPS) , 39.68750000)
        call s__X3Oracle_Orb(9 , 20 , 39.00000000 , 14.00000000)
        call s__X3Oracle_Orb(2 , 20 , 55.00000000 , - 16.00000000)
        call s__X3Oracle_Orb(1 , 20 , 47.00000000 , - 16.00000000)
    endfunction
    function s__X3Oracle_Batch65 takes nothing returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(21) / s__X3Kinematics_FPS) , 44.62500000)
        call s__X3Oracle_Orb(9 , 21 , 43.00000000 , 26.00000000)
        call s__X3Oracle_Orb(2 , 21 , 59.00000000 , - 12.00000000)
        call s__X3Oracle_Orb(1 , 21 , 51.00000000 , - 28.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(22) / s__X3Kinematics_FPS) , 50.06250000)
        call s__X3Oracle_Orb(9 , 22 , 49.00000000 , 30.00000000)
        call s__X3Oracle_Orb(2 , 22 , 65.00000000 , - 0.00000000)
        call s__X3Oracle_Orb(1 , 22 , 57.00000000 , - 32.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(23) / s__X3Kinematics_FPS) , 56.00000000)
        call s__X3Oracle_Orb(9 , 23 , 55.00000000 , 32.00000000)
        call s__X3Oracle_Orb(2 , 23 , 71.00000000 , 6.00000000)
        call s__X3Oracle_Orb(1 , 23 , 63.00000000 , - 34.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(24) / s__X3Kinematics_FPS) , 62.43750000)
        call s__X3Oracle_Orb(9 , 24 , 61.00000000 , 30.00000000)
        call s__X3Oracle_Orb(2 , 24 , 77.00000000 , 12.00000000)
        call s__X3Oracle_Orb(1 , 24 , 69.00000000 , - 32.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(25) / s__X3Kinematics_FPS) , 69.37500000)
        call s__X3Oracle_Orb(9 , 25 , 69.00000000 , 26.00000000)
        call s__X3Oracle_Orb(2 , 25 , 85.00000000 , 24.00000000)
        call s__X3Oracle_Orb(1 , 25 , 77.00000000 , - 28.00000000)
    endfunction
    function s__X3Oracle_Batch66 takes nothing returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(26) / s__X3Kinematics_FPS) , 76.81250000)
        call s__X3Oracle_Orb(9 , 26 , 75.00000000 , 14.00000000)
        call s__X3Oracle_Orb(2 , 26 , 91.00000000 , 28.00000000)
        call s__X3Oracle_Orb(1 , 26 , 83.00000000 , - 16.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(27) / s__X3Kinematics_FPS) , 84.75000000)
        call s__X3Oracle_Orb(9 , 27 , 83.00000000 , 8.00000000)
        call s__X3Oracle_Orb(2 , 27 , 99.00000000 , 30.00000000)
        call s__X3Oracle_Orb(1 , 27 , 91.00000000 , - 10.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(28) / s__X3Kinematics_FPS) , 93.18750000)
        call s__X3Oracle_Orb(9 , 28 , 93.00000000 , 2.00000000)
        call s__X3Oracle_Orb(2 , 28 , 109.00000000 , 28.00000000)
        call s__X3Oracle_Orb(1 , 28 , 101.00000000 , - 4.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(29) / s__X3Kinematics_FPS) , 102.12500000)
        call s__X3Oracle_Orb(9 , 29 , 101.00000000 , - 10.00000000)
        call s__X3Oracle_Orb(2 , 29 , 117.00000000 , 24.00000000)
        call s__X3Oracle_Orb(1 , 29 , 109.00000000 , 8.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(30) / s__X3Kinematics_FPS) , 111.56250000)
        call s__X3Oracle_Orb(9 , 30 , 111.00000000 , - 14.00000000)
        call s__X3Oracle_Orb(2 , 30 , 127.00000000 , 12.00000000)
        call s__X3Oracle_Orb(1 , 30 , 119.00000000 , 12.00000000)
    endfunction
    function s__X3Oracle_Batch67 takes nothing returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(31) / s__X3Kinematics_FPS) , 121.50000000)
        call s__X3Oracle_Orb(9 , 31 , 121.00000000 , - 16.00000000)
        call s__X3Oracle_Orb(2 , 31 , 137.00000000 , 6.00000000)
        call s__X3Oracle_Orb(1 , 31 , 129.00000000 , 14.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(32) / s__X3Kinematics_FPS) , 131.93750000)
        call s__X3Oracle_Orb(9 , 32 , 131.00000000 , - 14.00000000)
        call s__X3Oracle_Orb(2 , 32 , 147.00000000 , - 0.00000000)
        call s__X3Oracle_Orb(1 , 32 , 139.00000000 , 12.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(33) / s__X3Kinematics_FPS) , 142.43750000)
        call s__X3Oracle_Orb(9 , 33 , 141.00000000 , - 10.00000000)
        call s__X3Oracle_Orb(2 , 33 , 157.00000000 , - 12.00000000)
        call s__X3Oracle_Orb(1 , 33 , 149.00000000 , 8.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(34) / s__X3Kinematics_FPS) , 152.93750000)
        call s__X3Oracle_Orb(9 , 34 , 151.00000000 , 2.00000000)
        call s__X3Oracle_Orb(2 , 34 , 167.00000000 , - 16.00000000)
        call s__X3Oracle_Orb(1 , 34 , 159.00000000 , - 4.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(35) / s__X3Kinematics_FPS) , 163.43750000)
        call s__X3Oracle_Orb(9 , 35 , 163.00000000 , 8.00000000)
        call s__X3Oracle_Orb(2 , 35 , 179.00000000 , - 18.00000000)
        call s__X3Oracle_Orb(1 , 35 , 171.00000000 , - 10.00000000)
    endfunction
    function s__X3Oracle_Batch68 takes nothing returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(36) / s__X3Kinematics_FPS) , 173.93750000)
        call s__X3Oracle_Orb(9 , 36 , 173.00000000 , 14.00000000)
        call s__X3Oracle_Orb(2 , 36 , 189.00000000 , - 16.00000000)
        call s__X3Oracle_Orb(1 , 36 , 181.00000000 , - 16.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(37) / s__X3Kinematics_FPS) , 184.43750000)
        call s__X3Oracle_Orb(9 , 37 , 183.00000000 , 26.00000000)
        call s__X3Oracle_Orb(2 , 37 , 199.00000000 , - 12.00000000)
        call s__X3Oracle_Orb(1 , 37 , 191.00000000 , - 28.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(38) / s__X3Kinematics_FPS) , 194.93750000)
        call s__X3Oracle_Orb(9 , 38 , 193.00000000 , 30.00000000)
        call s__X3Oracle_Orb(2 , 38 , 209.00000000 , - 0.00000000)
        call s__X3Oracle_Orb(1 , 38 , 201.00000000 , - 32.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(39) / s__X3Kinematics_FPS) , 205.43750000)
        call s__X3Oracle_Orb(9 , 39 , 205.00000000 , 32.00000000)
        call s__X3Oracle_Orb(2 , 39 , 221.00000000 , 6.00000000)
        call s__X3Oracle_Orb(1 , 39 , 213.00000000 , - 34.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(40) / s__X3Kinematics_FPS) , 215.93750000)
        call s__X3Oracle_Orb(9 , 40 , 215.00000000 , 30.00000000)
        call s__X3Oracle_Orb(2 , 40 , 231.00000000 , 12.00000000)
        call s__X3Oracle_Orb(1 , 40 , 223.00000000 , - 32.00000000)
    endfunction
    function s__X3Oracle_Batch69 takes nothing returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(41) / s__X3Kinematics_FPS) , 226.43750000)
        call s__X3Oracle_Orb(9 , 41 , 225.00000000 , 26.00000000)
        call s__X3Oracle_Orb(2 , 41 , 241.00000000 , 24.00000000)
        call s__X3Oracle_Orb(1 , 41 , 233.00000000 , - 28.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(42) / s__X3Kinematics_FPS) , 236.93750000)
        call s__X3Oracle_Orb(9 , 42 , 235.00000000 , 14.00000000)
        call s__X3Oracle_Orb(2 , 42 , 251.00000000 , 28.00000000)
        call s__X3Oracle_Orb(1 , 42 , 243.00000000 , - 16.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(43) / s__X3Kinematics_FPS) , 247.43750000)
        call s__X3Oracle_Orb(9 , 43 , 247.00000000 , 8.00000000)
        call s__X3Oracle_Orb(2 , 43 , 263.00000000 , 30.00000000)
        call s__X3Oracle_Orb(1 , 43 , 255.00000000 , - 10.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(44) / s__X3Kinematics_FPS) , 257.93750000)
        call s__X3Oracle_Orb(9 , 44 , 257.00000000 , 2.00000000)
        call s__X3Oracle_Orb(2 , 44 , 273.00000000 , 28.00000000)
        call s__X3Oracle_Orb(1 , 44 , 265.00000000 , - 4.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(45) / s__X3Kinematics_FPS) , 268.43750000)
        call s__X3Oracle_Orb(9 , 45 , 267.00000000 , - 10.00000000)
        call s__X3Oracle_Orb(2 , 45 , 283.00000000 , 24.00000000)
        call s__X3Oracle_Orb(1 , 45 , 275.00000000 , 8.00000000)
    endfunction
    function s__X3Oracle_Batch70 takes nothing returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(46) / s__X3Kinematics_FPS) , 278.93750000)
        call s__X3Oracle_Orb(9 , 46 , 277.00000000 , - 14.00000000)
        call s__X3Oracle_Orb(2 , 46 , 293.00000000 , 12.00000000)
        call s__X3Oracle_Orb(1 , 46 , 285.00000000 , 12.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(47) / s__X3Kinematics_FPS) , 289.43750000)
        call s__X3Oracle_Orb(9 , 47 , 289.00000000 , - 16.00000000)
        call s__X3Oracle_Orb(2 , 47 , 305.00000000 , 6.00000000)
        call s__X3Oracle_Orb(1 , 47 , 297.00000000 , 14.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(48) / s__X3Kinematics_FPS) , 299.93750000)
        call s__X3Oracle_Orb(9 , 48 , 299.00000000 , - 14.00000000)
        call s__X3Oracle_Orb(2 , 48 , 315.00000000 , - 0.00000000)
        call s__X3Oracle_Orb(1 , 48 , 307.00000000 , 12.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(49) / s__X3Kinematics_FPS) , 310.43750000)
        call s__X3Oracle_Orb(9 , 49 , 309.00000000 , - 10.00000000)
        call s__X3Oracle_Orb(2 , 49 , 325.00000000 , - 12.00000000)
        call s__X3Oracle_Orb(1 , 49 , 317.00000000 , 8.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(50) / s__X3Kinematics_FPS) , 320.93750000)
        call s__X3Oracle_Orb(9 , 50 , 319.00000000 , 2.00000000)
        call s__X3Oracle_Orb(2 , 50 , 335.00000000 , - 16.00000000)
        call s__X3Oracle_Orb(1 , 50 , 327.00000000 , - 4.00000000)
    endfunction
    function s__X3Oracle_Batch71 takes nothing returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(51) / s__X3Kinematics_FPS) , 331.43750000)
        call s__X3Oracle_Orb(9 , 51 , 331.00000000 , 8.00000000)
        call s__X3Oracle_Orb(1 , 51 , 339.00000000 , - 10.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 1 , I2R(52) / s__X3Kinematics_FPS) , 341.93750000)
        call s__X3Oracle_Orb(9 , 52 , 341.00000000 , 14.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(5) / s__X3Kinematics_FPS) , 16.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(6) / s__X3Kinematics_FPS) , 32.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(7) / s__X3Kinematics_FPS) , 48.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(8) / s__X3Kinematics_FPS) , 64.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(9) / s__X3Kinematics_FPS) , 80.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(10) / s__X3Kinematics_FPS) , 96.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(11) / s__X3Kinematics_FPS) , 112.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(12) / s__X3Kinematics_FPS) , 128.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(13) / s__X3Kinematics_FPS) , 144.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(14) / s__X3Kinematics_FPS) , 160.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(15) / s__X3Kinematics_FPS) , 176.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(16) / s__X3Kinematics_FPS) , 192.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(17) / s__X3Kinematics_FPS) , 208.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(18) / s__X3Kinematics_FPS) , 224.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(19) / s__X3Kinematics_FPS) , 240.00000000)
    endfunction
    function s__X3Oracle_Batch72 takes nothing returns nothing
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(20) / s__X3Kinematics_FPS) , 256.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(21) / s__X3Kinematics_FPS) , 272.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(22) / s__X3Kinematics_FPS) , 288.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(23) / s__X3Kinematics_FPS) , 304.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(24) / s__X3Kinematics_FPS) , 320.00000000)
        call s__X3Oracle_Scalar(s__X3Kinematics_forward(1 , 3 , I2R(25) / s__X3Kinematics_FPS) , 336.00000000)
    endfunction
    function s__X3Oracle_step takes nothing returns nothing
        if s__X3Oracle_batch == 0 then
            call s__X3Oracle_Batch0()
        elseif s__X3Oracle_batch == 1 then
            call s__X3Oracle_Batch1()
        elseif s__X3Oracle_batch == 2 then
            call s__X3Oracle_Batch2()
        elseif s__X3Oracle_batch == 3 then
            call s__X3Oracle_Batch3()
        elseif s__X3Oracle_batch == 4 then
            call s__X3Oracle_Batch4()
        elseif s__X3Oracle_batch == 5 then
            call s__X3Oracle_Batch5()
        elseif s__X3Oracle_batch == 6 then
            call s__X3Oracle_Batch6()
        elseif s__X3Oracle_batch == 7 then
            call s__X3Oracle_Batch7()
        elseif s__X3Oracle_batch == 8 then
            call s__X3Oracle_Batch8()
        elseif s__X3Oracle_batch == 9 then
            call s__X3Oracle_Batch9()
        elseif s__X3Oracle_batch == 10 then
            call s__X3Oracle_Batch10()
        elseif s__X3Oracle_batch == 11 then
            call s__X3Oracle_Batch11()
        elseif s__X3Oracle_batch == 12 then
            call s__X3Oracle_Batch12()
        elseif s__X3Oracle_batch == 13 then
            call s__X3Oracle_Batch13()
        elseif s__X3Oracle_batch == 14 then
            call s__X3Oracle_Batch14()
        elseif s__X3Oracle_batch == 15 then
            call s__X3Oracle_Batch15()
        elseif s__X3Oracle_batch == 16 then
            call s__X3Oracle_Batch16()
        elseif s__X3Oracle_batch == 17 then
            call s__X3Oracle_Batch17()
        elseif s__X3Oracle_batch == 18 then
            call s__X3Oracle_Batch18()
        elseif s__X3Oracle_batch == 19 then
            call s__X3Oracle_Batch19()
        elseif s__X3Oracle_batch == 20 then
            call s__X3Oracle_Batch20()
        elseif s__X3Oracle_batch == 21 then
            call s__X3Oracle_Batch21()
        elseif s__X3Oracle_batch == 22 then
            call s__X3Oracle_Batch22()
        elseif s__X3Oracle_batch == 23 then
            call s__X3Oracle_Batch23()
        elseif s__X3Oracle_batch == 24 then
            call s__X3Oracle_Batch24()
        elseif s__X3Oracle_batch == 25 then
            call s__X3Oracle_Batch25()
        elseif s__X3Oracle_batch == 26 then
            call s__X3Oracle_Batch26()
        elseif s__X3Oracle_batch == 27 then
            call s__X3Oracle_Batch27()
        elseif s__X3Oracle_batch == 28 then
            call s__X3Oracle_Batch28()
        elseif s__X3Oracle_batch == 29 then
            call s__X3Oracle_Batch29()
        elseif s__X3Oracle_batch == 30 then
            call s__X3Oracle_Batch30()
        elseif s__X3Oracle_batch == 31 then
            call s__X3Oracle_Batch31()
        elseif s__X3Oracle_batch == 32 then
            call s__X3Oracle_Batch32()
        elseif s__X3Oracle_batch == 33 then
            call s__X3Oracle_Batch33()
        elseif s__X3Oracle_batch == 34 then
            call s__X3Oracle_Batch34()
        elseif s__X3Oracle_batch == 35 then
            call s__X3Oracle_Batch35()
        elseif s__X3Oracle_batch == 36 then
            call s__X3Oracle_Batch36()
        elseif s__X3Oracle_batch == 37 then
            call s__X3Oracle_Batch37()
        elseif s__X3Oracle_batch == 38 then
            call s__X3Oracle_Batch38()
        elseif s__X3Oracle_batch == 39 then
            call s__X3Oracle_Batch39()
        elseif s__X3Oracle_batch == 40 then
            call s__X3Oracle_Batch40()
        elseif s__X3Oracle_batch == 41 then
            call s__X3Oracle_Batch41()
        elseif s__X3Oracle_batch == 42 then
            call s__X3Oracle_Batch42()
        elseif s__X3Oracle_batch == 43 then
            call s__X3Oracle_Batch43()
        elseif s__X3Oracle_batch == 44 then
            call s__X3Oracle_Batch44()
        elseif s__X3Oracle_batch == 45 then
            call s__X3Oracle_Batch45()
        elseif s__X3Oracle_batch == 46 then
            call s__X3Oracle_Batch46()
        elseif s__X3Oracle_batch == 47 then
            call s__X3Oracle_Batch47()
        elseif s__X3Oracle_batch == 48 then
            call s__X3Oracle_Batch48()
        elseif s__X3Oracle_batch == 49 then
            call s__X3Oracle_Batch49()
        elseif s__X3Oracle_batch == 50 then
            call s__X3Oracle_Batch50()
        elseif s__X3Oracle_batch == 51 then
            call s__X3Oracle_Batch51()
        elseif s__X3Oracle_batch == 52 then
            call s__X3Oracle_Batch52()
        elseif s__X3Oracle_batch == 53 then
            call s__X3Oracle_Batch53()
        elseif s__X3Oracle_batch == 54 then
            call s__X3Oracle_Batch54()
        elseif s__X3Oracle_batch == 55 then
            call s__X3Oracle_Batch55()
        elseif s__X3Oracle_batch == 56 then
            call s__X3Oracle_Batch56()
        elseif s__X3Oracle_batch == 57 then
            call s__X3Oracle_Batch57()
        elseif s__X3Oracle_batch == 58 then
            call s__X3Oracle_Batch58()
        elseif s__X3Oracle_batch == 59 then
            call s__X3Oracle_Batch59()
        elseif s__X3Oracle_batch == 60 then
            call s__X3Oracle_Batch60()
        elseif s__X3Oracle_batch == 61 then
            call s__X3Oracle_Batch61()
        elseif s__X3Oracle_batch == 62 then
            call s__X3Oracle_Batch62()
        elseif s__X3Oracle_batch == 63 then
            call s__X3Oracle_Batch63()
        elseif s__X3Oracle_batch == 64 then
            call s__X3Oracle_Batch64()
        elseif s__X3Oracle_batch == 65 then
            call s__X3Oracle_Batch65()
        elseif s__X3Oracle_batch == 66 then
            call s__X3Oracle_Batch66()
        elseif s__X3Oracle_batch == 67 then
            call s__X3Oracle_Batch67()
        elseif s__X3Oracle_batch == 68 then
            call s__X3Oracle_Batch68()
        elseif s__X3Oracle_batch == 69 then
            call s__X3Oracle_Batch69()
        elseif s__X3Oracle_batch == 70 then
            call s__X3Oracle_Batch70()
        elseif s__X3Oracle_batch == 71 then
            call s__X3Oracle_Batch71()
        elseif s__X3Oracle_batch == 72 then
            call s__X3Oracle_Batch72()
        else
            set s__X3Oracle_done=true
        endif
        set s__X3Oracle_batch=s__X3Oracle_batch + 1
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

            return s__Missile_Missile___MissileStructure___list[this]
        endfunction
        
        function s__Missile__get_next takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,    "MissileStructure", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
// NO_DEBUG:                 debug call ThrowError(not isNode,   "MissileStructure", "next", "thistype", this, "Attempted To Read Invalid Node.")

            return s__Missile_Missile___MissileStructure___next[this]
        endfunction
        
        function s__Missile__get_prev takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,    "MissileStructure", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
// NO_DEBUG:                 debug call ThrowError(not isNode,   "MissileStructure", "prev", "thistype", this, "Attempted To Read Invalid Node.")

            return s__Missile_Missile___MissileStructure___prev[this]
        endfunction
        
        function s__Missile__get_first takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,        "MissileStructure", "first", "thistype", this, "Attempted To Read Null List.")
// NO_DEBUG:                 debug call ThrowError(not isCollection, "MissileStructure", "first", "thistype", this, "Attempted To Read Invalid List.")

            return s__Missile_Missile___MissileStructure___first[this]
        endfunction
        
        function s__Missile__get_last takes integer this returns integer

// NO_DEBUG:                 debug call ThrowError(this == 0,        "MissileStructure", "last", "thistype", this, "Attempted To Read Null List.")
// NO_DEBUG:                 debug call ThrowError(not isCollection, "MissileStructure", "last", "thistype", this, "Attempted To Read Invalid List.")

            return s__Missile_Missile___MissileStructure___last[this]
        endfunction
        
        function s__Missile_allocateCollection takes nothing returns integer
            local integer this= s__Missile_Missile___MissileStructure___first[(0)]
            
            if ( 0 == this ) then

// NO_DEBUG:                     debug call ThrowError(collectionCount == 8191, "MissileStructure", "allocateCollection", "thistype", 0, "Overflow.")

                
                set this=s__Missile_Missile___MissileStructure__collectionCount + 1
                set s__Missile_Missile___MissileStructure__collectionCount=this
            else
                set s__Missile_Missile___MissileStructure___first[(0)]=s__Missile_Missile___MissileStructure___first[this]
            endif
            

// NO_DEBUG:                 debug set isCollection = true

            
            set s__Missile_Missile___MissileStructure___first[this]=0
            
            return this
        endfunction
        
        function s__Missile_allocateNode takes nothing returns integer
            local integer this= s__Missile_Missile___MissileStructure___next[(0)]
            
            if ( 0 == this ) then

// NO_DEBUG:                     debug call ThrowError(nodeCount == 8191, "MissileStructure", "allocateNode", "thistype", 0, "Overflow.")

                
                set this=s__Missile_Missile___MissileStructure__nodeCount + 1
                set s__Missile_Missile___MissileStructure__nodeCount=this
            else
                set s__Missile_Missile___MissileStructure___next[(0)]=s__Missile_Missile___MissileStructure___next[this]
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

            
            set s__Missile_Missile___MissileStructure___list[node]=this
        
            if ( s__Missile_Missile___MissileStructure___first[this] == 0 ) then
                set s__Missile_Missile___MissileStructure___first[this]=node
                set s__Missile_Missile___MissileStructure___last[this]=node
                set s__Missile_Missile___MissileStructure___next[node]=0
            else
                set s__Missile_Missile___MissileStructure___prev[s__Missile_Missile___MissileStructure___first[this]]=node
                set s__Missile_Missile___MissileStructure___next[node]=s__Missile_Missile___MissileStructure___first[this]
                set s__Missile_Missile___MissileStructure___first[this]=node
            endif
            
            set s__Missile_Missile___MissileStructure___prev[node]=0
            
            return node
        endfunction
      
        function s__Missile_Missile___remove takes integer this returns nothing
            local integer node= this
            set this=s__Missile_Missile___MissileStructure___list[node]
            

// NO_DEBUG:                 debug call ThrowError(node == 0,        "MissileStructure", "remove", "thistype", this, "Attempted To Remove Null Node.")
// NO_DEBUG:                 debug call ThrowError(not node.isNode,  "MissileStructure", "remove", "thistype", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
// NO_DEBUG:                 debug set node.isNode = false

            
            set s__Missile_Missile___MissileStructure___list[node]=0
        
            if ( 0 == s__Missile_Missile___MissileStructure___prev[node] ) then
                set s__Missile_Missile___MissileStructure___first[this]=s__Missile_Missile___MissileStructure___next[node]
            else
                set s__Missile_Missile___MissileStructure___next[s__Missile_Missile___MissileStructure___prev[node]]=s__Missile_Missile___MissileStructure___next[node]
            endif
            if ( 0 == s__Missile_Missile___MissileStructure___next[node] ) then
                set s__Missile_Missile___MissileStructure___last[this]=s__Missile_Missile___MissileStructure___prev[node]
            else
                set s__Missile_Missile___MissileStructure___prev[s__Missile_Missile___MissileStructure___next[node]]=s__Missile_Missile___MissileStructure___prev[node]
            endif
            
            set s__Missile_Missile___MissileStructure___next[node]=s__Missile_Missile___MissileStructure___next[(0)]
            set s__Missile_Missile___MissileStructure___next[(0)]=node
            
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
            local integer this= (s__Missile_Missile___MissileStructure___first[(Missile___missileList[si__RapidBolt])]) // INLINED!!
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            loop
                exitwhen 0 == this
                set node=(s__Missile_Missile___MissileStructure___next[(this)]) // The linked list should not lose the next node. // INLINED!!
               
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
        
        function s__RapidBolt_MissileStruct__onInit takes nothing returns nothing
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


    function s__X3Buster___X3Flash_finish takes nothing returns nothing
        local timer t= GetExpiredTimer()
        local integer this= (LoadInteger(TimerUtils___ht, 0, GetHandleId((t)))) // INLINED!!
        call DestroyEffect(s__X3Buster___X3Flash_art[this])
        call RecycleMissile(s__X3Buster___X3Flash_dummy[this])
        set s__X3Buster___X3Flash_art[this]=null
        set s__X3Buster___X3Flash_dummy[this]=null
        set s__X3Buster___X3Flash_live=s__X3Buster___X3Flash_live - 1
        call ReleaseTimer(t)
        call s__X3Buster___X3Flash_deallocate(this)
        set t=null
    endfunction
    function s__X3Buster___X3Flash_playFor takes real x,real y,real z,real duration returns nothing
        local integer this= s__X3Buster___X3Flash__allocate()
        local timer t= NewTimerEx(this)
        set s__X3Buster___X3Flash_dummy[this]=GetRecycledMissile(x , y , z , 0.)
        set s__X3Buster___X3Flash_art[this]=AddSpecialEffectTarget("X3Buster\\X3_Flash_Union.mdx", s__X3Buster___X3Flash_dummy[this], "origin")
        set s__X3Buster___X3Flash_live=s__X3Buster___X3Flash_live + 1
        call TimerStart(t, duration, false, function s__X3Buster___X3Flash_finish)
        set t=null
    endfunction
    function s__X3Buster___X3Flash_play takes real x,real y,real z returns nothing
        call s__X3Buster___X3Flash_playFor(x , y , z , 0.18)
    endfunction

    // GIF approximation, units/second. These are NOT extracted SNES constants.

    function s__X3Buster_now takes nothing returns real
        return TimerGetElapsed(s__X3Buster_clock)
    endfunction
    // Analytic integral: negative starting velocity, acceleration, then a cap.
    // Sampling its differences gives the same path without Euler drift.
    function s__X3Buster_ramp takes real initial,real accel,real maximum,real age returns real
        local real cap= ( maximum - initial ) / accel
        if age <= 0. then
            return 0.
        elseif age <= cap then
            return initial * age + 0.5 * accel * age * age
        endif
        return initial * cap + 0.5 * accel * cap * cap + maximum * ( age - cap )
    endfunction
    function s__X3Buster_travel takes integer form,real age returns real
        if form == 1 or form == 2 then
            return s__X3Buster_ORBIT_SPEED * age
        elseif form == 0 or form == 3 then
            return s__X3Buster_ramp(s__X3Buster_PULSE_INITIAL , s__X3Buster_PULSE_ACCEL , s__X3Buster_PULSE_SPEED , age)
        endif
        set age=RMaxBJ(0., age - s__X3Buster_FORMATION_TIME)
        if form == 4 then
            return s__X3Buster_ramp(s__X3Buster_FUSED_INITIAL , s__X3Buster_FUSED_ACCEL , s__X3Buster_FUSED_SPEED , age)
        elseif form == 5 or form == 8 then
            return s__X3Buster_ramp(s__X3Buster_GREEN_INITIAL , s__X3Buster_GREEN_ACCEL , s__X3Buster_GREEN_SPEED , age)
        endif
        return s__X3Buster_ramp(s__X3Buster_ORANGE_INITIAL , s__X3Buster_ORANGE_ACCEL , s__X3Buster_ORANGE_SPEED , age)
    endfunction
    function s__X3Buster_lateral takes integer form,real age returns real
        local real offset
        set age=RMaxBJ(0., age - s__X3Buster_FORMATION_TIME)
        if form == 5 or form == 8 then
            set offset=20. + 200. * age
        else
            set offset=12. + 100. * age
        endif
        if form == 5 or form == 6 then
            return - offset
        endif
        return offset
    endfunction
    function s__X3Buster_trajectory takes integer this,integer form,real t returns real
        if s__X3Buster_profile[this] != s__X3Buster_GIF then
            return s__X3Kinematics_forward(s__X3Buster_profile[this] , form , t)
        endif
        return s__X3Buster_travel(form , t)
    endfunction
    function s__X3Buster_ageOf takes integer m returns real
        return (s__X3Buster___X3Body_age[(m)]) // INLINED!!
    endfunction
    function s__X3Buster_flashCount takes nothing returns integer
        return s__X3Buster___X3Flash_live
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
        elseif s__X3Buster_blue[this] == m then
            set s__X3Buster_blue[this]=0
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
        if s__X3Buster_forming[this] then
            set s__X3Buster_forming[this]=false
            call ReleaseTimer(s__X3Buster_formationTimer[this])
            set s__X3Buster_formationTimer[this]=null
        endif
        set s__X3Buster_state[this]=3
        if s__X3Buster_available(this,s__X3Buster_green[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_green[this])]=true // INLINED!!
        endif
        if s__X3Buster_available(this,s__X3Buster_orange[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_orange[this])]=true // INLINED!!
        endif
        if s__X3Buster_available(this,s__X3Buster_blue[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_blue[this])]=true // INLINED!!
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
        set s__X3Buster_pulse[this]=sc__X3Buster___X3Body_spawn(this , 3 , s__X3Buster_originX[this] , s__X3Buster_originY[this] , s__X3Buster_angle[this] , s__X3Buster_RANGE)
        set s__X3Buster_pulses=s__X3Buster_pulses + 1
        return true
    endfunction
    function s__X3Buster_emitFusion takes integer this returns nothing
        local real shift= 0.
        set s__X3Buster_state[this]=2
        if s__X3Buster_profile[this] == s__X3Buster_GIF then
            set shift=24.
        endif
        set s__X3Buster_fused[this]=sc__X3Buster___X3Body_spawn(this , 4 , s__X3Buster_unionX[this] , s__X3Buster_unionY[this] , s__X3Buster_angle[this] , s__X3Buster_unionRemaining[this])
        set s__X3Buster_sat1[this]=sc__X3Buster___X3Body_spawn(this , 5 , s__X3Buster_unionX[this] - shift * Cos(s__X3Buster_angle[this]) , s__X3Buster_unionY[this] - shift * Sin(s__X3Buster_angle[this]) , s__X3Buster_angle[this] , 600.)
        set s__X3Buster_sat2[this]=sc__X3Buster___X3Body_spawn(this , 6 , s__X3Buster_unionX[this] - shift * Cos(s__X3Buster_angle[this]) , s__X3Buster_unionY[this] - shift * Sin(s__X3Buster_angle[this]) , s__X3Buster_angle[this] , 600.)
        set s__X3Buster_sat3[this]=sc__X3Buster___X3Body_spawn(this , 7 , s__X3Buster_unionX[this] - shift * Cos(s__X3Buster_angle[this]) , s__X3Buster_unionY[this] - shift * Sin(s__X3Buster_angle[this]) , s__X3Buster_angle[this] , 600.)
        set s__X3Buster_sat4[this]=sc__X3Buster___X3Body_spawn(this , 8 , s__X3Buster_unionX[this] - shift * Cos(s__X3Buster_angle[this]) , s__X3Buster_unionY[this] - shift * Sin(s__X3Buster_angle[this]) , s__X3Buster_angle[this] , 600.)
        set s__X3Buster_satellites=s__X3Buster_satellites + 4
    endfunction
    function s__X3Buster_finishFormation takes nothing returns nothing
        local timer t= GetExpiredTimer()
        local integer this= (LoadInteger(TimerUtils___ht, 0, GetHandleId((t)))) // INLINED!!
        set s__X3Buster_formationTimer[this]=null
        set s__X3Buster_forming[this]=false
        call ReleaseTimer(t)
        if s__X3Buster_state[this] == 4 and s__GroundCollision_alive(s__X3Buster_caster[this]) then
            call s__X3Buster_emitFusion(this)
        else
            call s__X3Buster_cancel(this)
        endif
        set t=null
    endfunction
    function s__X3Buster_merge takes integer this,real x,real y returns nothing
        set s__X3Buster_unionRemaining[this]=RMaxBJ(1., s__X3Buster_RANGE - SquareRoot(( x - s__X3Buster_originX[this] ) * ( x - s__X3Buster_originX[this] ) + ( y - s__X3Buster_originY[this] ) * ( y - s__X3Buster_originY[this] )))
        set s__X3Buster_unionX[this]=x
        set s__X3Buster_unionY[this]=y
        set s__X3Buster_state[this]=2
        set s__X3Buster_waiting[this]=false
        set s__Missile_wantDestroy[(s__X3Buster_green[this])]=true // INLINED!!
        set s__Missile_wantDestroy[(s__X3Buster_orange[this])]=true // INLINED!!
        if s__X3Buster_available(this,s__X3Buster_blue[this]) then
            set s__Missile_wantDestroy[(s__X3Buster_blue[this])]=true // INLINED!!
        endif
        set s__Missile_wantDestroy[(s__X3Buster_pulse[this])]=true // INLINED!!
        set s__X3Buster_fusions=s__X3Buster_fusions + 1
        set s__X3Buster_lastFusionX=x
        set s__X3Buster_lastFusionY=y
        set s__X3Buster_lastFusionAge=(TimerGetElapsed(s__X3Buster_clock)) - s__X3Buster_born[this] // INLINED!!
        if s__X3Buster_profile[this] == s__X3Buster_GIF then
            call s__X3Buster___X3Flash_playFor(((x )*1.0) , (( y )*1.0) , (( 70.)*1.0) , 0.18) // INLINED!!
            call s__X3Buster_emitFusion(this)
        else
            // Snap to the second pulse; the five bodies do not exist during
            // formation. This timer is cancelled before this cast can be freed.
            set s__X3Buster_state[this]=4
            set s__X3Buster_forming[this]=true
            set s__X3Buster_formationTimer[this]=NewTimerEx(this)
            call s__X3Buster___X3Flash_playFor(x , y , 70. , s__X3Kinematics_formation(s__X3Buster_profile[this]))
            call TimerStart(s__X3Buster_formationTimer[this], s__X3Kinematics_formation(s__X3Buster_profile[this]), false, function s__X3Buster_finishFormation)
        endif
    endfunction
    function s__X3Buster_tryFusion takes integer this,integer m returns boolean
        local real oldGap
        local real gap
        local real fraction
        local real low= 0.
        local real high= 1.
        local integer i= 0
        local real reach= 0.
        if s__X3Buster_state[this] != 1 or not s__X3Buster_available(this,s__X3Buster_green[this]) or not s__X3Buster_available(this,s__X3Buster_orange[this]) or not s__X3Buster_available(this,s__X3Buster_pulse[this]) then
            return false
        endif
        if s__X3Buster_profile[this] != s__X3Buster_GIF and not s__X3Buster_available(this,s__X3Buster_blue[this]) then
            return false
        endif
        set oldGap=( s__Missile_prevX[s__X3Buster_green[this]] - s__Missile_prevX[m] ) * Cos(s__X3Buster_angle[this]) + ( s__Missile_prevY[s__X3Buster_green[this]] - s__Missile_prevY[m] ) * Sin(s__X3Buster_angle[this])
        set gap=( s__Missile_x[s__X3Buster_green[this]] - s__Missile_x[m] ) * Cos(s__X3Buster_angle[this]) + ( s__Missile_y[s__X3Buster_green[this]] - s__Missile_y[m] ) * Sin(s__X3Buster_angle[this])
        if s__X3Buster_profile[this] == s__X3Buster_GIF and ( oldGap <= 0. or gap > 0. ) then
            return false
        endif
        // Both bodies moved before callbacks. Use their analytic within-step
        // trajectories: linear interpolation would shift an accelerating catch.
        call sc__X3Buster___X3Body_prepare(s__X3Buster_green[this])
        call sc__X3Buster___X3Body_prepare(s__X3Buster_orange[this])
        call sc__X3Buster___X3Body_prepare(m)
        if s__X3Buster_profile[this] != s__X3Buster_GIF then
            // A Warcraft fusion envelope calibrated from the observed native
            // encounter. It does not replace GroundCollision's world filters.
            set reach=30. * s__X3Kinematics_SCALE
            set low=RMaxBJ(0., ( 4. / s__X3Kinematics_FPS - (s__X3Buster___X3Body_age[(m)]) + s__X3Buster_STEP ) / s__X3Buster_STEP) // INLINED!!
            if low > 1. then
                return false
            endif
            if s__X3Buster_available(this,s__X3Buster_blue[this]) then
                call sc__X3Buster___X3Body_prepare(s__X3Buster_blue[this])
            endif
            set gap=( sc__X3Buster___X3Body_centerX(s__X3Buster_green[this] , 1.) - sc__X3Buster___X3Body_centerX(m , 1.) ) * Cos(s__X3Buster_angle[this]) + ( sc__X3Buster___X3Body_centerY(s__X3Buster_green[this] , 1.) - sc__X3Buster___X3Body_centerY(m , 1.) ) * Sin(s__X3Buster_angle[this])
            if gap > reach then
                return false
            endif
        endif
        loop
            exitwhen i == 16
            set fraction=( low + high ) * 0.5
            set gap=( sc__X3Buster___X3Body_centerX(s__X3Buster_green[this] , fraction) - sc__X3Buster___X3Body_centerX(m , fraction) ) * Cos(s__X3Buster_angle[this]) + ( sc__X3Buster___X3Body_centerY(s__X3Buster_green[this] , fraction) - sc__X3Buster___X3Body_centerY(m , fraction) ) * Sin(s__X3Buster_angle[this])
            if gap > reach then
                set low=fraction
            else
                set high=fraction
            endif
            set i=i + 1
        endloop
        set fraction=high
        // Resolve only the part BEFORE the union. A later hit in this tick
        // belongs to the resulting shot and cannot cancel an earlier union.
        if sc__X3Buster___X3Body_resolveAt(s__X3Buster_green[this] , fraction) then
            set s__Missile_wantDestroy[(s__X3Buster_green[this])]=true // INLINED!!
        endif
        if sc__X3Buster___X3Body_resolveAt(s__X3Buster_orange[this] , fraction) then
            set s__Missile_wantDestroy[(s__X3Buster_orange[this])]=true // INLINED!!
        endif
        if s__X3Buster_profile[this] != s__X3Buster_GIF and s__X3Buster_available(this,s__X3Buster_blue[this]) and sc__X3Buster___X3Body_resolveAt(s__X3Buster_blue[this] , fraction) then
            set s__Missile_wantDestroy[(s__X3Buster_blue[this])]=true // INLINED!!
        endif
        if sc__X3Buster___X3Body_resolveAt(m , fraction) then
            set s__Missile_wantDestroy[(m)]=true // INLINED!!
        endif
        if s__X3Buster_state[this] != 1 or not s__X3Buster_available(this,s__X3Buster_green[this]) or not s__X3Buster_available(this,s__X3Buster_orange[this]) or not s__X3Buster_available(this,s__X3Buster_pulse[this]) then
            return false
        endif
        if s__X3Buster_profile[this] != s__X3Buster_GIF and not s__X3Buster_available(this,s__X3Buster_blue[this]) then
            return false
        endif
        call s__X3Buster_merge(this,sc__X3Buster___X3Body_centerX(m , fraction) , sc__X3Buster___X3Body_centerY(m , fraction))
        return true
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
            if s__X3Buster_waiting[this] and s__X3Buster_automatic[this] then
                if ( s__X3Buster_profile[this] == s__X3Buster_GIF and (TimerGetElapsed(s__X3Buster_clock)) - s__X3Buster_born[this] + 0.0001 >= s__X3Buster_PULSE_DELAY ) or ( s__X3Buster_profile[this] != s__X3Buster_GIF and (TimerGetElapsed(s__X3Buster_clock)) - s__X3Buster_born[this] + 0.0001 >= s__X3Kinematics_pulseDelay(s__X3Buster_profile[this]) ) then // INLINED!!
                    call s__X3Buster_releasePulse(this)
                endif
            endif
            if s__X3Buster_bodies[this] == 0 and not s__X3Buster_waiting[this] and not s__X3Buster_forming[this] then
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
    function s__X3Buster_fireProfile takes unit source,real tx,real ty,integer mode,integer selectedProfile returns integer
        local integer this
        local real x= GetUnitX(source)
        local real y= GetUnitY(source)
        local real dx= tx - x
        local real dy= ty - y
        if not s__GroundCollision_alive(source) or s__X3Buster_live >= s__X3Buster_LIMIT or mode < 0 or mode > 2 or selectedProfile < s__X3Buster_GIF or selectedProfile > s__X3Buster_ZERO_PROJECT then
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
        set s__X3Buster_profile[this]=selectedProfile
        set s__X3Buster_forming[this]=false
        set s__X3Buster_formationTimer[this]=null
        set s__X3Buster_state[this]=0
        set s__X3Buster_bodies[this]=0
        set s__X3Buster_green[this]=0
        set s__X3Buster_orange[this]=0
        set s__X3Buster_blue[this]=0
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
            set s__X3Buster_pulse[this]=sc__X3Buster___X3Body_spawn(this , 0 , s__X3Buster_originX[this] , s__X3Buster_originY[this] , s__X3Buster_angle[this] , s__X3Buster_RANGE)
        else
            set s__X3Buster_state[this]=1
            set s__X3Buster_green[this]=sc__X3Buster___X3Body_spawn(this , 1 , s__X3Buster_originX[this] , s__X3Buster_originY[this] , s__X3Buster_angle[this] , s__X3Buster_RANGE)
            set s__X3Buster_orange[this]=sc__X3Buster___X3Body_spawn(this , 2 , s__X3Buster_originX[this] , s__X3Buster_originY[this] , s__X3Buster_angle[this] , s__X3Buster_RANGE)
            if s__X3Buster_profile[this] != s__X3Buster_GIF then
                set s__X3Buster_blue[this]=sc__X3Buster___X3Body_spawn(this , 9 , s__X3Buster_originX[this] , s__X3Buster_originY[this] , s__X3Buster_angle[this] , s__X3Buster_RANGE)
            endif
        endif
        return this
    endfunction
    function s__X3Buster_fire takes unit source,real tx,real ty,integer mode returns integer
        return s__X3Buster_fireProfile(source , tx , ty , mode , s__X3Buster_GIF)
    endfunction
    function s__X3Buster_onInit takes nothing returns nothing
        call TimerStart(s__X3Buster_clock, 1000000., false, null)
    endfunction


    // Called once per shared physical tick, including partial fusion sweeps.
    function s__X3Buster___X3Body_prepare takes integer m returns nothing
        // A long-duration timer reading is not a unique physical tick ID.
        // The body's own callback consumes this flag after all partial sweeps.
        if not s__X3Buster___X3Body_prepared[m] then
            set s__X3Buster___X3Body_prepared[m]=true
            set s__X3Buster___X3Body_age[m]=s__X3Buster___X3Body_age[m] + s__X3Buster_STEP
        endif
    endfunction
    function s__X3Buster___X3Body_ageOf takes integer m returns real
        return s__X3Buster___X3Body_age[m]
    endfunction
    function s__X3Buster___X3Body_centerX takes integer m,real fraction returns real
        local integer s= s__Missile_data[m]
        return s__X3Buster___X3Body_startX[m] + RMinBJ(s__X3Buster___X3Body_length[m], s__X3Buster_trajectory(s,s__X3Buster___X3Body_kind[m] , s__X3Buster___X3Body_age[m] - s__X3Buster_STEP + s__X3Buster_STEP * fraction)) * Cos(s__X3Buster_angle[s])
    endfunction
    function s__X3Buster___X3Body_centerY takes integer m,real fraction returns real
        local integer s= s__Missile_data[m]
        return s__X3Buster___X3Body_startY[m] + RMinBJ(s__X3Buster___X3Body_length[m], s__X3Buster_trajectory(s,s__X3Buster___X3Body_kind[m] , s__X3Buster___X3Body_age[m] - s__X3Buster_STEP + s__X3Buster_STEP * fraction)) * Sin(s__X3Buster_angle[s])
    endfunction

    function s__X3Buster___X3Body_sample takes integer m,real sampleAge returns boolean
        local integer s= s__Missile_data[m]
        local real distance= RMinBJ(s__X3Buster___X3Body_length[m], s__X3Buster_trajectory(s,s__X3Buster___X3Body_kind[m] , sampleAge))
        local real x= s__X3Buster___X3Body_startX[m] + distance * Cos(s__X3Buster_angle[s])
        local real y= s__X3Buster___X3Body_startY[m] + distance * Sin(s__X3Buster_angle[s])
        local real fraction= ( sampleAge - s__X3Buster___X3Body_age[m] + s__X3Buster_STEP ) / s__X3Buster_STEP
        local real z= s__Missile_prevZ[m] + ( s__Missile_z[m] - s__Missile_prevZ[m] ) * fraction
        local real phase
        local real side
        local real radius= 29.
        local real damage= 75.
        local integer result
        local unit target
        if s__X3Buster_profile[s] != s__X3Buster_GIF and ( s__X3Buster___X3Body_kind[m] == 1 or s__X3Buster___X3Body_kind[m] == 2 or s__X3Buster___X3Body_kind[m] == 9 ) then
            set distance=RMinBJ(s__X3Buster___X3Body_length[m], s__X3Kinematics_orbitForward(s__X3Buster___X3Body_kind[m] , sampleAge))
            set side=s__X3Kinematics_side(s__X3Buster_profile[s] , s__X3Buster___X3Body_kind[m] , sampleAge)
            set x=s__X3Buster___X3Body_startX[m] + distance * Cos(s__X3Buster_angle[s]) - Sin(s__X3Buster_angle[s]) * side
            set y=s__X3Buster___X3Body_startY[m] + distance * Sin(s__X3Buster_angle[s]) + Cos(s__X3Buster_angle[s]) * side
            set radius=12.65
            set damage=35.
        elseif s__X3Buster___X3Body_kind[m] == 1 or s__X3Buster___X3Body_kind[m] == 2 then
            set phase=2. * bj_PI * s__X3Buster_ORBIT_HZ * sampleAge
            if s__X3Buster___X3Body_kind[m] == 2 then
                set phase=phase + bj_PI
            endif
            set side=s__X3Buster_ORBIT_RADIUS * Cos(phase)
            set x=x - Sin(s__X3Buster_angle[s]) * side
            set y=y + Cos(s__X3Buster_angle[s]) * side
            set z=z + s__X3Buster_ORBIT_RADIUS * Sin(phase)
            set radius=12.65
            set damage=35.
        elseif s__X3Buster___X3Body_kind[m] == 4 then
            set radius=41.25
            set damage=150.
        elseif s__X3Buster___X3Body_kind[m] >= 5 then
            if s__X3Buster_profile[s] == s__X3Buster_GIF then
                set side=s__X3Buster_lateral(s__X3Buster___X3Body_kind[m] , sampleAge)
            else
                set side=s__X3Kinematics_side(s__X3Buster_profile[s] , s__X3Buster___X3Body_kind[m] , sampleAge)
            endif
            set x=x - Sin(s__X3Buster_angle[s]) * side
            set y=y + Cos(s__X3Buster_angle[s]) * side
            set radius=12.65
            set damage=25.
        endif
        set result=s__GroundCollision_trace(s__X3Buster___X3Body_lastX[m] , s__X3Buster___X3Body_lastY[m] , x , y , radius , s__X3Buster_caster[s] , s__X3Buster_owner[s] , true)
        set target=s__GroundCollision_hit
        // Render the swept position, including backwards/lateral motion. The
        // central Missile coordinate remains the signed longitudinal carrier.
        call SetUnitX(s__Missile_dummy[m], s__GroundCollision_x)
        call SetUnitY(s__Missile_dummy[m], s__GroundCollision_y)
        call SetUnitFlyHeight(s__Missile_dummy[m], RMaxBJ(0., z), 0.)
        set s__X3Buster___X3Body_lastX[m]=x
        set s__X3Buster___X3Body_lastY[m]=y
        if result == 0 and z < 0. then
            set result=1
        endif
        if result != 0 then
            set s__X3Buster___X3Body_blocked[m]=true
            // Collision result/target are captured before damage can reenter.
            call s__X3Buster_countHit(s,result)
            if result == 2 and GetUnitTypeId(s__X3Buster_caster[s]) != 0 then
                call UnitDamageTarget(s__X3Buster_caster[s], target, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif
        endif
        set target=null
        return result != 0
    endfunction
    function s__X3Buster___X3Body_resolveAt takes integer m,real fraction returns boolean
        local real untilAge
        local real nextAge
        local integer s= s__Missile_data[m]
        call s__X3Buster___X3Body_prepare(m)
        set untilAge=s__X3Buster___X3Body_age[m] - s__X3Buster_STEP + s__X3Buster_STEP * fraction
        if s__Missile_wantDestroy[m] or s__X3Buster___X3Body_blocked[m] then
            return true
        endif
        // Four curved-path substeps at most per full tick. They also detect a
        // backwards/forwards turn whose two endpoints might otherwise coincide.
        loop
            exitwhen s__X3Buster___X3Body_processed[m] + 0.0000001 >= untilAge
            set nextAge=RMinBJ(untilAge, s__X3Buster___X3Body_processed[m] + s__X3Buster_STEP * 0.25)
            if s__X3Buster_profile[s] != s__X3Buster_GIF then
                set nextAge=RMinBJ(nextAge, I2R(R2I(s__X3Buster___X3Body_processed[m] * s__X3Kinematics_FPS + 0.00001) + 1) / s__X3Kinematics_FPS)
            endif
            if s__X3Buster___X3Body_sample(m , nextAge) then
                return true
            endif
            set s__X3Buster___X3Body_processed[m]=nextAge
        endloop
        return false
    endfunction
    function s__X3Buster___X3Body_resolve takes integer m returns boolean
        return s__X3Buster___X3Body_resolveAt(m , 1.)
    endfunction
    function s__X3Buster___X3Body_onPeriod takes integer m returns boolean
        local integer s= s__Missile_data[m]
        call s__X3Buster___X3Body_prepare(m)
        if s__X3Buster___X3Body_kind[m] == 3 and s__X3Buster_tryFusion(s,m) then
            return true
        endif
        if (s__X3Buster___X3Body_resolveAt((m) , 1.)) then // INLINED!!
            return true
        endif
        // Missile.speed is displacement per tick, not units/second.
        // Let Missile detect arrival using its own origin.distance. An external
        // rounded range can leave a zero-speed carrier just short of that end.
        // sample() clamps the rendered/swept position, including the last tick.
        set s__Missile_speed[m]=s__X3Buster_trajectory(s,s__X3Buster___X3Body_kind[m] , s__X3Buster___X3Body_age[m] + s__X3Buster_STEP) - s__X3Buster_trajectory(s,s__X3Buster___X3Body_kind[m] , s__X3Buster___X3Body_age[m])
        set s__X3Buster___X3Body_prepared[m]=false
        return false
    endfunction
    function s__X3Buster___X3Body_onFinish takes integer m returns boolean
call s__X3Buster___X3Body_resolveAt((m) , 1.) // INLINED!!
        return true
    endfunction
    function s__X3Buster___X3Body_onRemove takes integer m returns boolean
        local integer s= s__Missile_data[m]
        call s__X3Buster_untrack(s,m)
        set s__Missile_data[m]=0
        set s__X3Buster___X3Body_blocked[m]=false
        return false
    endfunction
//Implemented from module MissileStruct:
        function s__X3Buster___X3Body_launch takes integer missile returns nothing

// NO_DEBUG:                 debug call ThrowError(missile.launched, "thistype", "launch", "missile.launched", missile, "This missile was already launched before!")

// NO_DEBUG:             debug set missile.launched = true
            //
            call s__Missile_insertFront(Missile___missileList[si__X3Buster___X3Body],missile)
            call Missile___StartPeriodic(si__X3Buster___X3Body)
        endfunction
        // Called from missileIterate. "P" to avoid code collision.
        function s__X3Buster___X3Body_missileTerminateP takes integer node returns nothing
            if s__Missile_allocated[node] then


                        if s__X3Buster___X3Body_onRemove(node) and GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID then
                            call s__Missile___RecycleBin_recycle(s__Missile_dummy[node])
                            set s__Missile_dummy[(node)]=null // INLINED!!
                        endif




            
                call s__Missile_terminate(node)
                call Missile___StopPeriodic(si__X3Buster___X3Body)
            endif
        endfunction
























        













    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__X3Buster___X3Body_missileIterateP takes nothing returns boolean
            local integer this= (s__Missile_Missile___MissileStructure___first[(Missile___missileList[si__X3Buster___X3Body])]) // INLINED!!
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            loop
                exitwhen 0 == this
                set node=(s__Missile_Missile___MissileStructure___next[(this)]) // The linked list should not lose the next node. // INLINED!!
               
                if s__Missile_wantDestroy[this] then
                    call s__X3Buster___X3Body_missileTerminateP(this)
                else
                    if s__Missile_stackSize[this] > 0 then
                        call s__Missile_updateStack(this)
                    endif
                    
                    // Runs unit collision.







































                    
                    // Runs destructable collision.






                    
                    // Runs item collision.






                
                    // Runs when the destination is reached.
                    if s__Missile_recycle[this] and s__Missile_allocated[this] then

                            if s__X3Buster___X3Body_onFinish(this) then
                                call s__X3Buster___X3Body_missileTerminateP(this)
                            endif



                    endif
                
                    // Runs on terrian collision.





                
                    // Runs every Missile_TIMER_TIMEOUT.

                        if s__Missile_allocated[this] and s__X3Buster___X3Body_onPeriod(this) then
                            call s__X3Buster___X3Body_missileTerminateP(this)
                        endif

                endif
                set this=node
            endloop
            
            set u=null



                return false

        endfunction
        
        function s__X3Buster___X3Body_MissileStruct__onInit takes nothing returns nothing
            set Missile___missileList[(si__X3Buster___X3Body)]=s__Missile_allocateCollection() // INLINED!!
            set Missile___expression[(si__X3Buster___X3Body )]=Condition(( function s__X3Buster___X3Body_missileIterateP)) // INLINED!!
        endfunction

    function s__X3Buster___X3Body_spawn takes integer s,integer form,real x,real y,real facing,real range returns integer
        local integer m= s__Missile_createXYZ(x , y , 70. , x + range * Cos(facing) , y + range * Sin(facing) , 70.)
        set s__Missile_data[m]=s
        set s__Missile_owner[m]=s__X3Buster_owner[s]
        set s__Missile_collision[m]=0.
        set s__X3Buster___X3Body_kind[m]=form
        set s__X3Buster___X3Body_processed[m]=0.
        set s__X3Buster___X3Body_age[m]=0.
        set s__X3Buster___X3Body_prepared[m]=false
        set s__X3Buster___X3Body_startX[m]=x
        set s__X3Buster___X3Body_startY[m]=y
        set s__X3Buster___X3Body_length[m]=s__MissilePosition_distance[s__Missile_origin[m]]
        set s__X3Buster___X3Body_blocked[m]=false
        set s__X3Buster___X3Body_lastX[m]=x
        set s__X3Buster___X3Body_lastY[m]=y
        if form == 1 or form == 2 or form >= 5 then
            if form == 1 or form == 5 or form == 8 or form == 9 then
                call s__Missile__set_model(m,"X3Buster\\X3_Orbe_Verde.mdx")
            else
                call s__Missile__set_model(m,"X3Buster\\X3_Orbe_Naranja.mdx")
            endif
            call s__Missile__set_scale(m,0.55)
        elseif form == 4 then
            call s__Missile__set_model(m,"X3Buster\\X3_Cross_Buster.mdx")
            call s__Missile__set_scale(m,1.)
        else
            call s__Missile__set_model(m,"X3Buster\\X3_Buster_Cargado.mdx")
            call s__Missile__set_scale(m,1.)
        endif
        set s__Missile_speed[m]=s__X3Buster_trajectory(s,form , s__X3Buster_STEP)
        // Start each visual at its real lateral position; do not pop out of
        // the carrier center on its first callback. Check terrain before moving.
        if s__X3Buster_profile[s] != s__X3Buster_GIF then
            set s__X3Buster___X3Body_processed[m]=0.
            if form == 1 or form == 2 or form == 9 then
                set s__X3Buster___X3Body_processed[m]=s__X3Kinematics_side(s__X3Buster_profile[s] , form , 0.)
                set s__X3Buster___X3Body_lastX[m]=x + s__X3Kinematics_orbitForward(form , 0.) * Cos(facing) - Sin(facing) * s__X3Buster___X3Body_processed[m]
                set s__X3Buster___X3Body_lastY[m]=y + s__X3Kinematics_orbitForward(form , 0.) * Sin(facing) + Cos(facing) * s__X3Buster___X3Body_processed[m]
            endif
            if s__GroundCollision_trace(x , y , s__X3Buster___X3Body_lastX[m] , s__X3Buster___X3Body_lastY[m] , 12.65 , s__X3Buster_caster[s] , s__X3Buster_owner[s] , false) != 0 then
                set s__X3Buster___X3Body_blocked[m]=true
                call s__X3Buster_countHit(s,1)
                set s__Missile_wantDestroy[(m)]=true // INLINED!!
            endif
            call SetUnitX(s__Missile_dummy[m], s__GroundCollision_x)
            call SetUnitY(s__Missile_dummy[m], s__GroundCollision_y)
        elseif form == 1 or form == 2 then
            if form == 1 then
                set s__X3Buster___X3Body_processed[m]=s__X3Buster_ORBIT_RADIUS
            else
                set s__X3Buster___X3Body_processed[m]=- s__X3Buster_ORBIT_RADIUS
            endif
        elseif form >= 5 then
            set s__X3Buster___X3Body_processed[m]=s__X3Buster_lateral(form , 0.)
        endif
        if s__X3Buster_profile[s] == s__X3Buster_GIF and ( form == 1 or form == 2 or form >= 5 ) then
            set s__X3Buster___X3Body_lastX[m]=x - Sin(facing) * s__X3Buster___X3Body_processed[m]
            set s__X3Buster___X3Body_lastY[m]=y + Cos(facing) * s__X3Buster___X3Body_processed[m]
            if s__GroundCollision_trace(x , y , s__X3Buster___X3Body_lastX[m] , s__X3Buster___X3Body_lastY[m] , 12.65 , s__X3Buster_caster[s] , s__X3Buster_owner[s] , false) != 0 then
                set s__X3Buster___X3Body_blocked[m]=true
                call s__X3Buster_countHit(s,1)
                set s__Missile_wantDestroy[(m)]=true // INLINED!!
            endif
            call SetUnitX(s__Missile_dummy[m], s__GroundCollision_x)
            call SetUnitY(s__Missile_dummy[m], s__GroundCollision_y)
        endif
        set s__X3Buster___X3Body_processed[m]=0.
        call s__X3Buster_track(s,m)
        call s__X3Buster___X3Body_launch(m)
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

function RapidFireProbe__Note takes string s returns nothing
    set RapidFireProbe__lines[RapidFireProbe__count]=s
    set RapidFireProbe__count=RapidFireProbe__count + 1
endfunction
function RapidFireProbe__Check takes boolean ok,string label returns nothing
    set RapidFireProbe__checks=RapidFireProbe__checks + 1
    if ok then
        call RapidFireProbe__Note("PASS " + label)
    else
        set RapidFireProbe__failures=RapidFireProbe__failures + 1
        call RapidFireProbe__Note("FAIL " + label)
    endif
endfunction
function RapidFireProbe__Save takes string status returns nothing
    local integer i= 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("RAPID 20261023-145909 " + status)
    loop
        exitwhen i == RapidFireProbe__count
        call Preload(RapidFireProbe__lines[i])
        set i=i + 1
    endloop
    call Preload("checks=" + I2S(RapidFireProbe__checks) + " failures=" + I2S(RapidFireProbe__failures) + " observed=" + I2S(RapidFireProbe__observed) + " minimum=" + R2S(RapidFireProbe__minimum) + " emitted=" + I2S(s__RapidPair_emitted) + " live=" + I2S(s__RapidBolt_live) + " pairs=" + I2S(s__RapidPair_pairs))
    call PreloadGenEnd("Logs\\TerrainDev-20261023-145909-rapid.txt")
endfunction
function RapidFireProbe__Advance takes integer value returns nothing
    set RapidFireProbe__stage=value
    set RapidFireProbe__since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
    set RapidFireProbe__one=false
    set RapidFireProbe__two=false
    call RapidFireProbe__Save("PROGRESS stage=" + I2S(RapidFireProbe__stage))
endfunction
function RapidFireProbe__Body takes real x,real y returns integer
    return s__RapidPair_create(CreateUnit(Player(0), 'rfct', s__WorldBounds_minX + 256., s__WorldBounds_minY + 256., 0.) , CreateUnit(Player(0), 'rfex', x, y, 0.))
endfunction
function RapidFireProbe__Reset takes nothing returns nothing
    local unit body= s__RapidPair_actor[RapidFireProbe__p]
    call s__RapidPair_destroy(RapidFireProbe__p)
    call RemoveUnit(body)
    set RapidFireProbe__p=RapidFireProbe__Body(RapidFireProbe__sx , RapidFireProbe__sy)
    set body=null
endfunction
function RapidFireProbe__CliffCase takes integer i returns nothing
    if i == 0 then
        set RapidFireProbe__cx1=- 3168.
        set RapidFireProbe__cy1=- 5632.
        set RapidFireProbe__cx2=- 2848.
        set RapidFireProbe__cy2=- 5632.
    elseif i == 1 then
        set RapidFireProbe__cx1=- 1760.
        set RapidFireProbe__cy1=- 4480.
        set RapidFireProbe__cx2=- 1440.
        set RapidFireProbe__cy2=- 4480.
    elseif i == 2 then
        set RapidFireProbe__cx1=- 5504.
        set RapidFireProbe__cy1=- 3424.
        set RapidFireProbe__cx2=- 5504.
        set RapidFireProbe__cy2=- 3104.
    elseif i == 3 then
        set RapidFireProbe__cx1=- 5376.
        set RapidFireProbe__cy1=- 3424.
        set RapidFireProbe__cx2=- 5376.
        set RapidFireProbe__cy2=- 3104.
    elseif i == 4 then
        set RapidFireProbe__cx1=2048.
        set RapidFireProbe__cy1=- 2784.
        set RapidFireProbe__cx2=2048.
        set RapidFireProbe__cy2=- 2464.
    elseif i == 5 then
        set RapidFireProbe__cx1=2176.
        set RapidFireProbe__cy1=800.
        set RapidFireProbe__cx2=2176.
        set RapidFireProbe__cy2=1120.
    elseif i == 6 then
        set RapidFireProbe__cx1=2304.
        set RapidFireProbe__cy1=800.
        set RapidFireProbe__cx2=2304.
        set RapidFireProbe__cy2=1120.
    elseif i == 7 then
        set RapidFireProbe__cx1=2432.
        set RapidFireProbe__cy1=800.
        set RapidFireProbe__cx2=2432.
        set RapidFireProbe__cy2=1120.
    elseif i == 8 then
        set RapidFireProbe__cx1=1824.
        set RapidFireProbe__cy1=1152.
        set RapidFireProbe__cx2=2144.
        set RapidFireProbe__cy2=1152.
    elseif i == 9 then
        set RapidFireProbe__cx1=- 2944.
        set RapidFireProbe__cy1=1184.
        set RapidFireProbe__cx2=- 2944.
        set RapidFireProbe__cy2=1504.
    elseif i == 10 then
        set RapidFireProbe__cx1=- 2816.
        set RapidFireProbe__cy1=1184.
        set RapidFireProbe__cx2=- 2816.
        set RapidFireProbe__cy2=1504.
    elseif i == 11 then
        set RapidFireProbe__cx1=- 2688.
        set RapidFireProbe__cy1=1184.
        set RapidFireProbe__cx2=- 2688.
        set RapidFireProbe__cy2=1504.
    elseif i == 12 then
        set RapidFireProbe__cx1=- 3680.
        set RapidFireProbe__cy1=1920.
        set RapidFireProbe__cx2=- 3360.
        set RapidFireProbe__cy2=1920.
    elseif i == 13 then
        set RapidFireProbe__cx1=1536.
        set RapidFireProbe__cy1=1824.
        set RapidFireProbe__cx2=1536.
        set RapidFireProbe__cy2=2144.
    elseif i == 14 then
        set RapidFireProbe__cx1=1664.
        set RapidFireProbe__cy1=1824.
        set RapidFireProbe__cx2=1664.
        set RapidFireProbe__cy2=2144.
    elseif i == 15 then
        set RapidFireProbe__cx1=- 3680.
        set RapidFireProbe__cy1=2048.
        set RapidFireProbe__cx2=- 3360.
        set RapidFireProbe__cy2=2048.
    elseif i == 16 then
        set RapidFireProbe__cx1=- 5248.
        set RapidFireProbe__cy1=5280.
        set RapidFireProbe__cx2=- 5248.
        set RapidFireProbe__cy2=5600.
    elseif i == 17 then
        set RapidFireProbe__cx1=- 2016.
        set RapidFireProbe__cy1=5504.
        set RapidFireProbe__cx2=- 1696.
        set RapidFireProbe__cy2=5504.
    elseif i == 18 then
        set RapidFireProbe__cx1=- 2688.
        set RapidFireProbe__cy1=5664.
        set RapidFireProbe__cx2=- 2688.
        set RapidFireProbe__cy2=5984.
    elseif i == 19 then
        set RapidFireProbe__cx1=- 2016.
        set RapidFireProbe__cy1=5888.
        set RapidFireProbe__cx2=- 1696.
        set RapidFireProbe__cy2=5888.
    elseif i == 20 then
        set RapidFireProbe__cx1=- 2016.
        set RapidFireProbe__cy1=6016.
        set RapidFireProbe__cx2=- 1696.
        set RapidFireProbe__cy2=6016.
    endif
endfunction
function RapidFireProbe__Tick takes nothing returns nothing
    local real elapsed= (TimerGetElapsed(s__RapidPair_clock)) - RapidFireProbe__since // INLINED!!
    local real travelled
    local real angle
    local integer result
    local unit body
    if RapidFireProbe__stage == 1 and s__RapidPair_firing[RapidFireProbe__p] and RapidFireProbe__firstEmission < 0. then
        set RapidFireProbe__firstEmission=s__RapidPair_lastShot[RapidFireProbe__p]
    endif
    if RapidFireProbe__stage == 1 and not s__RapidPair_firing[RapidFireProbe__p] and RapidFireProbe__firstEmission > 0. and RapidFireProbe__firstEnd < 0. then
        set RapidFireProbe__firstEnd=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
    endif
    if RapidFireProbe__p != 0 and s__RapidPair_lastShot[RapidFireProbe__p] != RapidFireProbe__last and s__RapidPair_lastShot[RapidFireProbe__p] > 0. then
        if RapidFireProbe__last > 0. and s__RapidPair_lastShot[RapidFireProbe__p] - RapidFireProbe__last < RapidFireProbe__minimum then
            set RapidFireProbe__minimum=s__RapidPair_lastShot[RapidFireProbe__p] - RapidFireProbe__last
        endif
        set RapidFireProbe__last=s__RapidPair_lastShot[RapidFireProbe__p]
        set RapidFireProbe__observed=RapidFireProbe__observed + 1
        call RapidFireProbe__Note("SHOT stage=" + I2S(RapidFireProbe__stage) + " time=" + R2S(RapidFireProbe__last) + " pending=" + I2S(s__RapidPair_pending[RapidFireProbe__p]) + " aim=" + R2S(s__RapidPair_aimX[RapidFireProbe__p]) + "," + R2S(s__RapidPair_aimY[RapidFireProbe__p]))
    endif
    if RapidFireProbe__stage == 0 then
        call RapidFireProbe__Save("BEFORE BODY")
        set RapidFireProbe__p=RapidFireProbe__Body(RapidFireProbe__sx , RapidFireProbe__sy)
        call RapidFireProbe__Save("BEFORE TRACE")
        call RapidFireProbe__Check(s__GroundCollision_trace(RapidFireProbe__sx , RapidFireProbe__sy , RapidFireProbe__sx + 320. , RapidFireProbe__sy , 24. , s__RapidPair_actor[RapidFireProbe__p] , Player(0) , false) == 0 , "open lane 320 ground units")
        call RapidFireProbe__Save("AFTER TRACE")
        call RapidFireProbe__Check(GetUnitAbilityLevel(s__RapidPair_controller[RapidFireProbe__p], 'Arpf') == 1 and GetUnitAbilityLevel(s__RapidPair_actor[RapidFireProbe__p], 'Arpf') == 0 , "ability only on controller")
        set RapidFireProbe__baseline=s__RapidPair_emitted
        set RapidFireProbe__createdBaseline=s__MissileStats_created
        call RapidFireProbe__Check(IssuePointOrder(s__RapidPair_controller[RapidFireProbe__p], "channel", RapidFireProbe__sx + 900., RapidFireProbe__sy) , "native point cast accepted")
        call RapidFireProbe__Advance(1)
    elseif RapidFireProbe__stage == 1 and elapsed > 2.1 then
        call RapidFireProbe__Check(s__RapidPair_emitted - RapidFireProbe__baseline == 6 , "native cast emitted exactly six")
        call RapidFireProbe__Check(s__MissileStats_created - RapidFireProbe__createdBaseline == 6 and s__RapidBolt_live == 0 , "six real Missile instances created and retired")
        call RapidFireProbe__Check(not s__RapidPair_firing[RapidFireProbe__p] and s__RapidPair_pending[RapidFireProbe__p] == 0 , "initial burst tail ended")
        call RapidFireProbe__Check(RAbsBJ(RapidFireProbe__firstEnd - RapidFireProbe__firstEmission - 1.5) < 0.032 , "burst protection ends 1.5 seconds after first emission")
        call RapidFireProbe__Note("WINDOW first=" + R2S(RapidFireProbe__firstEmission) + " end=" + R2S(RapidFireProbe__firstEnd))
        set RapidFireProbe__baseline=s__RapidPair_emitted
        call s__RapidPair_cast(RapidFireProbe__p,RapidFireProbe__sx + 900. , RapidFireProbe__sy)
        set RapidFireProbe__oldFlight=s__RapidPair_lastMissile[RapidFireProbe__p]
        call RapidFireProbe__Advance(2)
    elseif RapidFireProbe__stage == 2 then
        if elapsed >= 0.125 and not RapidFireProbe__one then
            set RapidFireProbe__expectedNext=s__RapidPair_nextShot[RapidFireProbe__p]
            set RapidFireProbe__expectedHits=s__RapidPair_emitted
            call s__RapidPair_cast(RapidFireProbe__p,RapidFireProbe__sx , RapidFireProbe__sy + 600.)
            call RapidFireProbe__Check(s__RapidPair_pending[RapidFireProbe__p] == 6 and s__RapidPair_nextShot[RapidFireProbe__p] == RapidFireProbe__expectedNext and s__RapidPair_emitted == RapidFireProbe__expectedHits , "early recast six, same clock, no extra shot")
            call RapidFireProbe__Check(s__Missile_allocated[RapidFireProbe__oldFlight] and s__MissilePosition_x[s__Missile_impact[RapidFireProbe__oldFlight]] == RapidFireProbe__sx + 900. and s__MissilePosition_y[s__Missile_impact[RapidFireProbe__oldFlight]] == RapidFireProbe__sy , "already launched missile keeps its original aim")
            set RapidFireProbe__one=true
        endif
        if elapsed >= 0.28125 and not RapidFireProbe__two then
            call RapidFireProbe__Check(s__MissilePosition_y[s__Missile_impact[s__RapidPair_lastMissile[RapidFireProbe__p]]] == RapidFireProbe__sy + 600. and s__MissilePosition_x[s__Missile_impact[s__RapidPair_lastMissile[RapidFireProbe__p]]] == RapidFireProbe__sx , "next missile uses new aim")
            set RapidFireProbe__expectedNext=s__RapidPair_nextShot[RapidFireProbe__p]
            set RapidFireProbe__expectedHits=s__RapidPair_emitted
            call s__RapidPair_cast(RapidFireProbe__p,RapidFireProbe__sx + 800. , RapidFireProbe__sy + 100.)
            call RapidFireProbe__Check(s__RapidPair_pending[RapidFireProbe__p] == 6 and s__RapidPair_nextShot[RapidFireProbe__p] == RapidFireProbe__expectedNext and s__RapidPair_emitted == RapidFireProbe__expectedHits , "late recast six, same clock, new aim")
            set RapidFireProbe__two=true
        endif
        if elapsed > 2.2 then
            call RapidFireProbe__Check(s__RapidPair_emitted - RapidFireProbe__baseline == 8 and not s__RapidPair_firing[RapidFireProbe__p] , "two recasts produced eight scheduled emissions")
            call RapidFireProbe__Reset()
            call s__GroundMotion_destination(s__RapidPair_motion[(RapidFireProbe__p)],((RapidFireProbe__sx + 1050. )*1.0) , (( RapidFireProbe__sy)*1.0)) // INLINED!!
            call RapidFireProbe__Advance(3)
        endif
    elseif RapidFireProbe__stage == 3 and elapsed > 0.3 then
        call RapidFireProbe__Check(GetUnitCurrentOrder(s__RapidPair_actor[RapidFireProbe__p]) == 851986 and GetUnitX(s__RapidPair_actor[RapidFireProbe__p]) > RapidFireProbe__sx + 30. , "native locomotion before cast")
        set RapidFireProbe__instants=s__GroundMotion_instantTransitions
        set RapidFireProbe__expectedHandoffs=s__GroundMotion_handoffs
        call s__RapidPair_cast(RapidFireProbe__p,GetUnitX(s__RapidPair_actor[RapidFireProbe__p]) , RapidFireProbe__sy + 600.)
        set RapidFireProbe__startX=GetUnitX(s__RapidPair_actor[RapidFireProbe__p])
        set RapidFireProbe__startY=GetUnitY(s__RapidPair_actor[RapidFireProbe__p])
        call RapidFireProbe__Check(GetUnitCurrentOrder(s__RapidPair_actor[RapidFireProbe__p]) == 0 and s__GroundMotion_instantTransitions == RapidFireProbe__instants + 1 , "instant first tick cancels native move")
        call RapidFireProbe__Advance(4)
    elseif RapidFireProbe__stage == 4 then
        if elapsed > 0.2 and not RapidFireProbe__one then
            set travelled=GetUnitX(s__RapidPair_actor[RapidFireProbe__p]) - RapidFireProbe__startX
            call RapidFireProbe__Note("MOVE distance=" + R2S(travelled) + " seconds=" + R2S(elapsed) + " facing=" + R2S(GetUnitFacing(s__RapidPair_actor[RapidFireProbe__p])))
            call RapidFireProbe__Check(RAbsBJ(travelled - 350. * elapsed) < 15. and RAbsBJ(GetUnitY(s__RapidPair_actor[RapidFireProbe__p]) - RapidFireProbe__startY) < 1. , "artificial speed 350 without double native travel")
            call RapidFireProbe__Check(GetUnitFacing(s__RapidPair_actor[RapidFireProbe__p]) > 80. and GetUnitFacing(s__RapidPair_actor[RapidFireProbe__p]) < 115. , "aim facing independent of movement")
            set RapidFireProbe__expectedNext=s__RapidPair_nextShot[RapidFireProbe__p]
            call s__RapidPair_cast(RapidFireProbe__p,RapidFireProbe__sx + 1000. , RapidFireProbe__sy + 500.)
            call RapidFireProbe__Check(s__RapidPair_nextShot[RapidFireProbe__p] == RapidFireProbe__expectedNext and s__GroundMotion_instantTransitions == RapidFireProbe__instants + 1 , "moving recast does not repeat instant transition")
            call RapidFireProbe__Check(IssuePointOrder(s__RapidPair_controller[RapidFireProbe__p], "move", RapidFireProbe__sx + 1050., RapidFireProbe__sy + 32.) , "proxy point move accepted during burst")
            call RapidFireProbe__Check(s__GroundMotion_goalY[s__RapidPair_motion[RapidFireProbe__p]] == RapidFireProbe__sy + 32. , "new move target captured")
            set RapidFireProbe__one=true
        endif
        if elapsed > 2. then
            call RapidFireProbe__Check(not s__RapidPair_firing[RapidFireProbe__p] and s__GroundMotion_handoffs == RapidFireProbe__expectedHandoffs + 1 and GetUnitCurrentOrder(s__RapidPair_actor[RapidFireProbe__p]) == 851986 , "one native handoff for unfinished route")
            call RapidFireProbe__Reset()
            set RapidFireProbe__expectedHandoffs=s__GroundMotion_handoffs
            call s__RapidPair_cast(RapidFireProbe__p,RapidFireProbe__sx + 900. , RapidFireProbe__sy)
            call s__GroundMotion_destination(s__RapidPair_motion[(RapidFireProbe__p)],((RapidFireProbe__sx + 40. )*1.0) , (( RapidFireProbe__sy)*1.0)) // INLINED!!
            call RapidFireProbe__Advance(5)
        endif
    elseif RapidFireProbe__stage == 5 and elapsed > 1.7 then
        call RapidFireProbe__Check(not s__GroundMotion_hasGoal[s__RapidPair_motion[RapidFireProbe__p]] and RAbsBJ(GetUnitX(s__RapidPair_actor[RapidFireProbe__p]) - ( RapidFireProbe__sx + 40. )) < 3. , "short artificial route arrived")
        call RapidFireProbe__Check(s__GroundMotion_handoffs == RapidFireProbe__expectedHandoffs and GetUnitCurrentOrder(s__RapidPair_actor[RapidFireProbe__p]) == 0 , "no native move after arrival")
        call RapidFireProbe__Reset()
        set RapidFireProbe__target=CreateUnit(Player(12), 'rftg', RapidFireProbe__sx + 160., RapidFireProbe__sy, 0.)
        call PauseUnit(RapidFireProbe__target, true)
        set RapidFireProbe__expectedHits=s__RapidBolt_hits
        call s__RapidBolt_shoot(s__RapidPair_actor[RapidFireProbe__p] , RapidFireProbe__sx + 500. , RapidFireProbe__sy)
        call RapidFireProbe__Advance(6)
    elseif RapidFireProbe__stage == 6 and elapsed > 0.6 then
        call RapidFireProbe__Check(s__RapidBolt_hits == RapidFireProbe__expectedHits + 1 and GetWidgetLife(RapidFireProbe__target) < 2000. and GetWidgetLife(RapidFireProbe__target) > 1960. , "projectile expectedHits enemy once and retires")
        call RemoveUnit(RapidFireProbe__target)
        set RapidFireProbe__target=CreateUnit(Player(0), 'rftg', RapidFireProbe__sx + 110., RapidFireProbe__sy, 0.)
        call PauseUnit(RapidFireProbe__target, true)
        call s__RapidPair_cast(RapidFireProbe__p,RapidFireProbe__sx + 600. , RapidFireProbe__sy)
        call s__GroundMotion_destination(s__RapidPair_motion[(RapidFireProbe__p)],((RapidFireProbe__sx + 250. )*1.0) , (( RapidFireProbe__sy)*1.0)) // INLINED!!
        call RapidFireProbe__Advance(7)
    elseif RapidFireProbe__stage == 7 and elapsed > 1.7 then
        call RapidFireProbe__Check(GetUnitX(s__RapidPair_actor[RapidFireProbe__p]) > RapidFireProbe__sx + 245. , "artificial movement ignores unit collision")
        call RemoveUnit(RapidFireProbe__target)
        call RapidFireProbe__Reset()
        set RapidFireProbe__tree=CreateDestructable('LTlt', RapidFireProbe__sx + 180., RapidFireProbe__sy, 0., 1., 0)
        set RapidFireProbe__target=CreateUnit(Player(12), 'rftg', RapidFireProbe__sx + 360., RapidFireProbe__sy, 0.)
        call PauseUnit(RapidFireProbe__target, true)
        set RapidFireProbe__expectedWalls=s__RapidBolt_walls
        set RapidFireProbe__expectedHits=s__RapidBolt_hits
        call s__RapidPair_cast(RapidFireProbe__p,RapidFireProbe__sx + 600. , RapidFireProbe__sy)
        call s__GroundMotion_destination(s__RapidPair_motion[(RapidFireProbe__p)],((RapidFireProbe__sx + 500. )*1.0) , (( RapidFireProbe__sy)*1.0)) // INLINED!!
        call RapidFireProbe__Advance(8)
    elseif RapidFireProbe__stage == 8 and elapsed > 1.4 then
        call RapidFireProbe__Check(s__GroundMotion_blocked[s__RapidPair_motion[RapidFireProbe__p]] and GetUnitX(s__RapidPair_actor[RapidFireProbe__p]) < RapidFireProbe__sx + 150. , "live tree blocks artificial movement")
        call RapidFireProbe__Check(s__RapidBolt_walls > RapidFireProbe__expectedWalls and s__RapidBolt_hits == RapidFireProbe__expectedHits and GetWidgetLife(RapidFireProbe__target) == 2000. , "tree stops projectiles before target behind it")
        call KillDestructable(RapidFireProbe__tree)
        call RapidFireProbe__Advance(9)
    elseif RapidFireProbe__stage == 9 and elapsed > 1.2 then
        call RapidFireProbe__Check(not s__GroundCollision_alive(null) , "null units rejected")
        call RapidFireProbe__Check(GetUnitX(s__RapidPair_actor[RapidFireProbe__p]) > RapidFireProbe__sx + 200. , "native travel can continue after dead tree")
        call RemoveDestructable(RapidFireProbe__tree)
        call RemoveUnit(RapidFireProbe__target)
        call RapidFireProbe__Reset()
        set RapidFireProbe__q=RapidFireProbe__Body(RapidFireProbe__sx , RapidFireProbe__sy - 48.)
        call s__RapidPair_cast(RapidFireProbe__p,RapidFireProbe__sx + 600. , RapidFireProbe__sy)
        call s__RapidPair_cast(RapidFireProbe__q,RapidFireProbe__sx + 600. , RapidFireProbe__sy - 48.)
        set RapidFireProbe__expectedNext=s__RapidPair_nextShot[RapidFireProbe__q]
        call s__RapidPair_cast(RapidFireProbe__p,RapidFireProbe__sx , RapidFireProbe__sy + 500.)
        call RapidFireProbe__Check(s__RapidPair_nextShot[RapidFireProbe__q] == RapidFireProbe__expectedNext and s__RapidPair_pending[RapidFireProbe__q] == 5 and s__RapidPair_aimY[RapidFireProbe__q] == RapidFireProbe__sy - 48. , "two pairs isolated during recast")
        call RapidFireProbe__Advance(10)
    elseif RapidFireProbe__stage == 10 and elapsed > 2. then
        call RapidFireProbe__Check(not s__RapidPair_firing[RapidFireProbe__p] and not s__RapidPair_firing[RapidFireProbe__q] and s__RapidBolt_live == 0 and s__MissileStats_active == 0 , "two concurrent emitters and real projectiles drain")
        set body=s__RapidPair_actor[RapidFireProbe__q]
        call s__RapidPair_cast(RapidFireProbe__q,RapidFireProbe__sx + 600. , RapidFireProbe__sy)
        call KillUnit(body)
        set RapidFireProbe__q=0
        call RapidFireProbe__Advance(11)
    elseif RapidFireProbe__stage == 11 and elapsed > 1.5 then
        call RapidFireProbe__Check(s__RapidPair_pairs == 2 and s__RapidPair_bursts == 0 and s__RapidPair_remaining == 0 and s__RapidBolt_live == 0 , "death cleans controller, emitter, pending and projectile state")
        call RapidFireProbe__Check(RapidFireProbe__minimum >= 0.249 and RapidFireProbe__minimum <= 0.282 and RapidFireProbe__observed >= 30 , "positive emission coverage with clean intervals")
        call RapidFireProbe__Check(MultiboardGetRowCount(s__MissileStats_board) == 25 , "diagnostics extended to 25 rows")
        call RapidFireProbe__Advance(12)
    elseif RapidFireProbe__stage == 12 then
        call RapidFireProbe__CliffCase(RapidFireProbe__cliffIndex)
        if s__GroundCollision_clear(RapidFireProbe__cx1 , RapidFireProbe__cy1 , 24.) and s__GroundCollision_clear(RapidFireProbe__cx2 , RapidFireProbe__cy2 , 24.) and RAbsBJ(s__GroundCollision_height(RapidFireProbe__cx1 , RapidFireProbe__cy1) - s__GroundCollision_height(RapidFireProbe__cx2 , RapidFireProbe__cy2)) > 64. then
            call RapidFireProbe__Note("CLIFF from=" + R2S(RapidFireProbe__cx1) + "," + R2S(RapidFireProbe__cy1) + " to=" + R2S(RapidFireProbe__cx2) + "," + R2S(RapidFireProbe__cy2) + " levels=" + I2S(GetTerrainCliffLevel(RapidFireProbe__cx1, RapidFireProbe__cy1)) + "," + I2S(GetTerrainCliffLevel(RapidFireProbe__cx2, RapidFireProbe__cy2)))
            call RapidFireProbe__Check(true , "authored cliff endpoints are walkable with real elevation change")
            call RapidFireProbe__Check(s__GroundCollision_trace(RapidFireProbe__cx1 , RapidFireProbe__cy1 , RapidFireProbe__cx2 , RapidFireProbe__cy2 , 24. , s__RapidPair_actor[RapidFireProbe__p] , Player(0) , false) == 1 , "authored cliff blocks swept movement first direction")
            call RapidFireProbe__Check(s__GroundCollision_trace(RapidFireProbe__cx2 , RapidFireProbe__cy2 , RapidFireProbe__cx1 , RapidFireProbe__cy1 , 24. , s__RapidPair_actor[RapidFireProbe__p] , Player(0) , false) == 1 , "authored cliff blocks swept movement reverse direction")
            call RapidFireProbe__Advance(13)
        else
            set RapidFireProbe__cliffIndex=RapidFireProbe__cliffIndex + 1
            if RapidFireProbe__cliffIndex >= 21 then
                call RapidFireProbe__Check(false , "positive authored cliff coverage was not found")
                call RapidFireProbe__Advance(13)
            endif
        endif
    elseif RapidFireProbe__stage == 13 then
        call RapidFireProbe__Note("RAMP heights=" + R2S(s__GroundCollision_height(- 1600. , - 4992.)) + "," + R2S(s__GroundCollision_height(- 1344. , - 4992.)))
        call RapidFireProbe__Check(RAbsBJ(s__GroundCollision_height(- 1600. , - 4992.) - s__GroundCollision_height(- 1344. , - 4992.)) > 64. , "authored ramp has real elevation change")
        call RapidFireProbe__Check(s__GroundCollision_trace(- 1600. , - 4992. , - 1344. , - 4992. , 24. , s__RapidPair_actor[RapidFireProbe__p] , Player(0) , false) == 0 , "authored descending ramp remains walkable")
        call RapidFireProbe__Check(s__GroundCollision_trace(- 1344. , - 4992. , - 1600. , - 4992. , 24. , s__RapidPair_actor[RapidFireProbe__p] , Player(0) , false) == 0 , "authored ascending ramp remains walkable")
        call RapidFireProbe__Advance(14)
    elseif RapidFireProbe__stage == 14 then
        call SetTerrainPathable(RapidFireProbe__sx + 160., RapidFireProbe__sy, PATHING_TYPE_WALKABILITY, false)
        call RapidFireProbe__Check(IsTerrainPathable(RapidFireProbe__sx + 160., RapidFireProbe__sy, PATHING_TYPE_WALKABILITY) , "native wall pathing really blocked")
        call RapidFireProbe__Check(s__GroundCollision_trace(RapidFireProbe__sx , RapidFireProbe__sy , RapidFireProbe__sx + 320. , RapidFireProbe__sy , 24. , s__RapidPair_actor[RapidFireProbe__p] , Player(0) , false) == 1 and s__GroundCollision_x < RapidFireProbe__sx + 160. , "narrow pathing wall stops a segment spanning both sides")
        call SetTerrainPathable(RapidFireProbe__sx + 160., RapidFireProbe__sy, PATHING_TYPE_WALKABILITY, true)
        call RapidFireProbe__Check(not IsTerrainPathable(RapidFireProbe__sx + 160., RapidFireProbe__sy, PATHING_TYPE_WALKABILITY) , "native wall removed before endpoint test")
        call RapidFireProbe__Check(s__GroundCollision_trace(s__WorldBounds_maxX - 96. , s__WorldBounds_maxY - 96. , s__WorldBounds_maxX + 32. , s__WorldBounds_maxY + 32. , 24. , s__RapidPair_actor[RapidFireProbe__p] , Player(0) , false) == 1 , "world edge blocks movement")
        call RapidFireProbe__Reset()
        set RapidFireProbe__target=CreateUnit(Player(12), 'rftg', RapidFireProbe__sx + 450., RapidFireProbe__sy, 0.)
        call PauseUnit(RapidFireProbe__target, true)
        set RapidFireProbe__expectedHits=s__RapidBolt_hits
        call s__RapidBolt_shoot(s__RapidPair_actor[RapidFireProbe__p] , RapidFireProbe__sx + 450. , RapidFireProbe__sy)
        call RapidFireProbe__Advance(15)
    elseif RapidFireProbe__stage == 15 and elapsed > 0.6 then
        call RapidFireProbe__Check(s__RapidBolt_hits == RapidFireProbe__expectedHits + 1 and GetWidgetLife(RapidFireProbe__target) < 2000. , "target at final missile endpoint is not skipped")
        call RemoveUnit(RapidFireProbe__target)
        call RapidFireProbe__Save("COMPLETE")
        call PauseTimer(RapidFireProbe__t)
        call DestroyTimer(RapidFireProbe__t)
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 30., "RAPID TEST COMPLETE checks=" + I2S(RapidFireProbe__checks) + " failures=" + I2S(RapidFireProbe__failures))
    endif
    set body=null
endfunction
function RapidFireProbe__Begin takes nothing returns nothing
    call RapidFireProbe__Note("BEGIN timer=" + I2S(GetHandleId(RapidFireProbe__t)) + " clock=" + R2S((TimerGetElapsed(s__RapidPair_clock)))) // INLINED!!
    call RapidFireProbe__Save("BEGIN")
    set RapidFireProbe__since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
    set RapidFireProbe__t=CreateTimer()
    call TimerStart(RapidFireProbe__t, 1. / 32., true, function RapidFireProbe__Tick)
    call RapidFireProbe__Note("AFTER START timer=" + I2S(GetHandleId(RapidFireProbe__t)) + " timeout=" + R2S(TimerGetTimeout(RapidFireProbe__t)) + " expired=" + I2S(GetHandleId(GetExpiredTimer())))
    call RapidFireProbe__Save("STARTED")
    call DestroyTimer(GetExpiredTimer())
endfunction
function RapidFireProbe__Queue takes nothing returns nothing
    call TimerStart(CreateTimer(), 0.03125, false, function RapidFireProbe__Begin)
endfunction
function RapidFireProbe__Init takes nothing returns nothing
    local trigger l__RapidFireProbe__t= CreateTrigger()
    call TriggerRegisterPlayerChatEvent(l__RapidFireProbe__t, Player(0), "-rapid", true)
    call TriggerAddAction(l__RapidFireProbe__t, function RapidFireProbe__Queue)
    set l__RapidFireProbe__t=null
endfunction

function ShotColorProbe___Check takes boolean value,string message returns nothing
    if value then
        set ShotColorProbe___lines[ShotColorProbe___checks]="PASS " + message
    else
        set ShotColorProbe___lines[ShotColorProbe___checks]="FAIL " + message
        set ShotColorProbe___failures=ShotColorProbe___failures + 1
    endif
    set ShotColorProbe___checks=ShotColorProbe___checks + 1
endfunction
function ShotColorProbe___Clear takes nothing returns nothing
    loop
        exitwhen ShotColorProbe___displays == 0
        set ShotColorProbe___displays=ShotColorProbe___displays - 1
        call DestroyEffect(ShotColorProbe___displayEffect[ShotColorProbe___displays])
        call RemoveUnit(ShotColorProbe___displayUnit[ShotColorProbe___displays])
        call DestroyTextTag(ShotColorProbe___label[ShotColorProbe___displays])
        set ShotColorProbe___displayEffect[ShotColorProbe___displays]=null
        set ShotColorProbe___displayUnit[ShotColorProbe___displays]=null
        set ShotColorProbe___label[ShotColorProbe___displays]=null
    endloop
    loop
        exitwhen ShotColorProbe___rings == 0
        set ShotColorProbe___rings=ShotColorProbe___rings - 1
        call DestroyLightning(ShotColorProbe___ring[ShotColorProbe___rings])
        set ShotColorProbe___ring[ShotColorProbe___rings]=null
    endloop
endfunction
function ShotColorProbe___Display takes real x,real y,playercolor color,real scale,string text,boolean marker returns nothing
    local integer i= 0
    local real a
    local real b
    local real z= s__GroundCollision_height(x , y) + 70.
    set ShotColorProbe___displayUnit[ShotColorProbe___displays]=CreateUnit(Player(0), 'dumi', x, y, 0.)
    call SetUnitX(ShotColorProbe___displayUnit[ShotColorProbe___displays], x)
    call SetUnitY(ShotColorProbe___displayUnit[ShotColorProbe___displays], y)
    call SetUnitFlyHeight(ShotColorProbe___displayUnit[ShotColorProbe___displays], 70., 0.)
    call SetUnitScale(ShotColorProbe___displayUnit[ShotColorProbe___displays], scale, scale, scale)
    set ShotColorProbe___displayEffect[ShotColorProbe___displays]=AddSpecialEffectTarget(s__RapidBolt_modelForColor(color), ShotColorProbe___displayUnit[ShotColorProbe___displays], "origin")
    set ShotColorProbe___label[ShotColorProbe___displays]=CreateTextTag()
    call SetTextTagText(ShotColorProbe___label[ShotColorProbe___displays], text, 0.022)
    call SetTextTagPos(ShotColorProbe___label[ShotColorProbe___displays], x - 55., y + 48., 75.)
    set ShotColorProbe___displays=ShotColorProbe___displays + 1
    if marker then
        loop
            exitwhen i == 24
            set a=I2R(i) * bj_PI / 12.
            set b=I2R(i + 1) * bj_PI / 12.
            set ShotColorProbe___ring[ShotColorProbe___rings]=AddLightningEx("DRAL", false, x + 16. * Cos(a), y + 16. * Sin(a), z, x + 16. * Cos(b), y + 16. * Sin(b), z)
            call SetLightningColor(ShotColorProbe___ring[ShotColorProbe___rings], 1., 1., 1., 0.8)
            set ShotColorProbe___rings=ShotColorProbe___rings + 1
            set i=i + 1
        endloop
    endif
endfunction
function ShotColorProbe___Camera takes nothing returns nothing
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
function ShotColorProbe___Calibrate takes nothing returns nothing
    call ShotColorProbe___Clear()
    call ShotColorProbe___Camera()
    call ShotColorProbe___Display(- 4400. , 3260. , PLAYER_COLOR_CYAN , 1. , "1.00 x" , true)
    call ShotColorProbe___Display(- 4400. , 3040. , PLAYER_COLOR_CYAN , 1.5 , "1.50 x" , true)
    call ShotColorProbe___Display(- 4400. , 2820. , PLAYER_COLOR_CYAN , 2.7434842 , "2.74 x" , true)
    call DisplayTimedTextToPlayer(Player(0), 0., 0., 60., "CALIBRACION: circulo radio16 en el origen/punta; estela hacia atras. Grosor del cuerpo, halo y Death son distintos.")
endfunction
function ShotColorProbe___Palette takes nothing returns nothing
    local integer i= 0
    call ShotColorProbe___Clear()
    call ShotColorProbe___Camera()
    loop
        exitwhen i == 12
        call ShotColorProbe___Display(- 4670. + I2R(ModuloInteger(i, 3)) * 340. , 3340. - I2R(i / 3) * 190. , ConvertPlayerColor(i) , s__RapidBolt_VISUAL_SCALE , I2S(i) , false)
        set i=i + 1
    endloop
    call DisplayTimedTextToPlayer(Player(0), 0., 0., 60., "PALETA CLASSIC: 0 rojo,1 azul,2 cian,3 purpura,4 amarillo,5 naranja,6 verde,7 rosa,8 gris,9 azul claro,10 aqua,11 marron.")
endfunction
function ShotColorProbe___Save takes nothing returns nothing
    local integer i= 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("COLOR 20261023-145909 COMPLETE")
    loop
        exitwhen i == ShotColorProbe___checks
        call Preload(ShotColorProbe___lines[i])
        set i=i + 1
    endloop
    call Preload("checks=" + I2S(ShotColorProbe___checks) + " failures=" + I2S(ShotColorProbe___failures) + " live=" + I2S(s__RapidBolt_live) + " created=" + I2S(s__MissileStats_created) + " retired=" + I2S(s__MissileStats_retired) + " scale=" + R2S(s__RapidBolt_VISUAL_SCALE))
    call PreloadGenEnd("Logs\\TerrainDev-20261023-145909-colors.txt")
endfunction
function ShotColorProbe___Tick takes nothing returns nothing
    local real elapsed= (TimerGetElapsed(s__RapidPair_clock)) - ShotColorProbe___since // INLINED!!
    if ShotColorProbe___stage == 1 and elapsed >= 0.25 then
        call ShotColorProbe___Check(s__RapidBolt_live == 0 , "all twelve direct shots retired")
        call SetPlayerColor(Player(0), PLAYER_COLOR_ORANGE)
        set ShotColorProbe___prior=s__RapidBolt_shoot(s__RapidPair_actor[ShotColorProbe___p] , - 3800. , 3024.)
        call ShotColorProbe___Check((s__Missile_path[(ShotColorProbe___prior)]) == ShotColorProbe___expected[5] , "owner color differs from player slot") // INLINED!!
        set s__Missile_wantDestroy[(ShotColorProbe___prior)]=true // INLINED!!
        call s__RapidPair_setColor(ShotColorProbe___p,PLAYER_COLOR_RED)
        call s__RapidPair_cast(ShotColorProbe___p,- 3800. , 3024.)
        set ShotColorProbe___prior=s__RapidPair_lastMissile[ShotColorProbe___p]
        call ShotColorProbe___Check((s__Missile_path[(ShotColorProbe___prior)]) == ShotColorProbe___expected[0] , "explicit red override wins over orange owner") // INLINED!!
        set ShotColorProbe___since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
        set ShotColorProbe___stage=2
    elseif ShotColorProbe___stage == 2 and elapsed >= 0.125 then
        set ShotColorProbe___nextTime=s__RapidPair_nextShot[ShotColorProbe___p]
        set ShotColorProbe___countBefore=s__RapidPair_emitted
        call s__RapidPair_setColor(ShotColorProbe___p,PLAYER_COLOR_PINK)
        call s__RapidPair_cast(ShotColorProbe___p,- 3800. , 3024.)
        call ShotColorProbe___Check(s__RapidPair_pending[ShotColorProbe___p] == 6 and s__RapidPair_nextShot[ShotColorProbe___p] == ShotColorProbe___nextTime and s__RapidPair_emitted == ShotColorProbe___countBefore , "colored recast preserves next shot and replenishes six")
        set ShotColorProbe___stage=3
    elseif ShotColorProbe___stage == 3 and elapsed >= 0.28125 then
        call ShotColorProbe___Check((s__Missile_path[(s__RapidPair_lastMissile[ShotColorProbe___p])]) == ShotColorProbe___expected[7] , "next recast shot uses updated override") // INLINED!!
        call ShotColorProbe___Check(s__Missile_allocated[ShotColorProbe___prior] and (s__Missile_path[(ShotColorProbe___prior)]) == ShotColorProbe___expected[0] , "flying shot keeps previous red color") // INLINED!!
        call SetPlayerColor(Player(0), PLAYER_COLOR_YELLOW)
        call s__RapidPair_clearColor(ShotColorProbe___p)
        call s__RapidPair_cast(ShotColorProbe___p,- 3800. , 3024.)
        set ShotColorProbe___since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
        set ShotColorProbe___stage=4
    elseif ShotColorProbe___stage == 4 and elapsed >= 0.28125 then
        call ShotColorProbe___Check((s__Missile_path[(s__RapidPair_lastMissile[ShotColorProbe___p])]) == ShotColorProbe___expected[4] , "cleared override follows changed owner color") // INLINED!!
        call s__RapidPair_setColor(ShotColorProbe___p,PLAYER_COLOR_GREEN)
        call s__RapidPair_cast(ShotColorProbe___p,- 3800. , 3024.)
        set ShotColorProbe___since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
        set ShotColorProbe___stage=5
    elseif ShotColorProbe___stage == 5 and elapsed >= 0.28125 then
        call ShotColorProbe___Check((s__Missile_path[(s__RapidPair_lastMissile[ShotColorProbe___p])]) == ShotColorProbe___expected[6] , "explicit team color overrides player color") // INLINED!!
        call SetPlayerColor(Player(1), PLAYER_COLOR_PURPLE)
        call SetUnitOwner(s__RapidPair_actor[ShotColorProbe___p], Player(1), true)
        call s__RapidPair_clearColor(ShotColorProbe___p)
        call s__RapidPair_cast(ShotColorProbe___p,- 3800. , 3024.)
        set ShotColorProbe___since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
        set ShotColorProbe___stage=6
    elseif ShotColorProbe___stage == 6 and elapsed >= 0.28125 then
        call ShotColorProbe___Check((s__Missile_path[(s__RapidPair_lastMissile[ShotColorProbe___p])]) == ShotColorProbe___expected[3] , "changed owner selects its current color") // INLINED!!
        call ShotColorProbe___Check(RAbsBJ((s__Missile_scaling[(s__RapidPair_lastMissile[ShotColorProbe___p])]) - s__RapidBolt_VISUAL_SCALE) < 0.0001 , "scale applied on reused projectile dummy") // INLINED!!
        call ShotColorProbe___Check(s__RapidPair_minInterval >= 0.249 , "color changes do not shorten firing interval")
        call SetUnitOwner(s__RapidPair_actor[ShotColorProbe___p], Player(0), true)
        call SetPlayerColor(Player(0), PLAYER_COLOR_RED)
        call SetPlayerColor(Player(1), PLAYER_COLOR_BLUE)
        call s__RapidPair_clearColor(ShotColorProbe___p)
        set ShotColorProbe___since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
        set ShotColorProbe___stage=7
    elseif ShotColorProbe___stage == 7 and elapsed >= 4. then
        call ShotColorProbe___Check(not s__RapidPair_firing[ShotColorProbe___p] and s__RapidPair_pending[ShotColorProbe___p] == 0 and s__RapidBolt_live == 0 , "burst finishes with zero pending/live")
        call ShotColorProbe___Check(s__MissileStats_created == s__MissileStats_retired , "all real missile instances retired")
        // Do not leave a collidable demo actor at the next laboratory's spawn.
        call SetUnitPosition(s__RapidPair_actor[ShotColorProbe___p], ShotColorProbe___originalX, ShotColorProbe___originalY)
        call IssueImmediateOrder(s__RapidPair_actor[ShotColorProbe___p], "stop")
        call ShotColorProbe___Save()
        call PauseTimer(ShotColorProbe___ticker)
        call ClearTextMessages()
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 60., "COLOR COMPLETE: " + I2S(ShotColorProbe___checks) + " checks / " + I2S(ShotColorProbe___failures) + " failures. -palette / -calibrate")
    endif
endfunction
function ShotColorProbe___Tests takes nothing returns nothing
    local integer i= 0
    local integer m
    if ShotColorProbe___stage != 0 then
        return
    endif
    set ShotColorProbe___p=s__RapidDemo_pair
    set ShotColorProbe___originalX=GetUnitX(s__RapidPair_actor[ShotColorProbe___p])
    set ShotColorProbe___originalY=GetUnitY(s__RapidPair_actor[ShotColorProbe___p])
    call SetUnitPosition(s__RapidPair_actor[ShotColorProbe___p], - 4700., 3024.)
    call IssueImmediateOrder(s__RapidPair_actor[ShotColorProbe___p], "stop")
    loop
        exitwhen i == 12
        call SetPlayerColor(Player(0), ConvertPlayerColor(i))
        set m=s__RapidBolt_shoot(s__RapidPair_actor[ShotColorProbe___p] , - 3800. , 3024.)
        call ShotColorProbe___Check((s__Missile_path[(m)]) == ShotColorProbe___expected[i] , "model for owner color " + I2S(i)) // INLINED!!
        call ShotColorProbe___Check(RAbsBJ((s__Missile_scaling[(m)]) - s__RapidBolt_VISUAL_SCALE) < 0.0001 , "scale for owner color " + I2S(i)) // INLINED!!
        set s__Missile_wantDestroy[(m)]=true // INLINED!!
        set i=i + 1
    endloop
    call ShotColorProbe___Check(PLAYER_COLOR_RED == null and s__RapidBolt_modelForColor(PLAYER_COLOR_RED) == ShotColorProbe___expected[0] , "Classic red enum0 remains a valid explicit color")
    call ShotColorProbe___Check(s__RapidBolt_modelForColor(ConvertPlayerColor(12)) == ShotColorProbe___expected[8] , "neutral color fallback gray")
    call ShotColorProbe___Check(s__RapidBolt_HIT_RADIUS == 16. , "collision radius unchanged")
    set ShotColorProbe___stage=1
    set ShotColorProbe___since=(TimerGetElapsed(s__RapidPair_clock)) // INLINED!!
    call TimerStart(ShotColorProbe___ticker, 1. / 32., true, function ShotColorProbe___Tick)
endfunction
function ShotColorProbe___Init takes nothing returns nothing
    local trigger a= CreateTrigger()
    local trigger b= CreateTrigger()
    local trigger c= CreateTrigger()
    set ShotColorProbe___expected[0]="ShotsTeam\\Shot_00_Red.mdx"
    set ShotColorProbe___expected[1]="ShotsTeam\\Shot_01_Blue.mdx"
    set ShotColorProbe___expected[2]="ShotsTeam\\Shot_02_Cyan.mdx"
    set ShotColorProbe___expected[3]="ShotsTeam\\Shot_03_Purple.mdx"
    set ShotColorProbe___expected[4]="ShotsTeam\\Shot_04_Yellow.mdx"
    set ShotColorProbe___expected[5]="ShotsTeam\\Shot_05_Orange.mdx"
    set ShotColorProbe___expected[6]="ShotsTeam\\Shot_06_Green.mdx"
    set ShotColorProbe___expected[7]="ShotsTeam\\Shot_07_Pink.mdx"
    set ShotColorProbe___expected[8]="ShotsTeam\\Shot_08_LightGray.mdx"
    set ShotColorProbe___expected[9]="ShotsTeam\\Shot_09_LightBlue.mdx"
    set ShotColorProbe___expected[10]="ShotsTeam\\Shot_10_Aqua.mdx"
    set ShotColorProbe___expected[11]="ShotsTeam\\Shot_11_Brown.mdx"
    call TriggerRegisterPlayerChatEvent(a, Player(0), "-calibrate", true)
    call TriggerAddAction(a, function ShotColorProbe___Calibrate)
    call TriggerRegisterPlayerChatEvent(b, Player(0), "-palette", true)
    call TriggerAddAction(b, function ShotColorProbe___Palette)
    call TriggerRegisterPlayerChatEvent(c, Player(0), "-testcolors", true)
    call TriggerAddAction(c, function ShotColorProbe___Tests)
    set a=null
    set b=null
    set c=null
endfunction

// Compatibility fixtures may opt into GIF; delivered W/E use the USA profile.
function X3BusterDemo__Cast takes nothing returns nothing
    local integer pair= (LoadInteger(Table__ht, (s__RapidPair_controls), (GetHandleId((GetTriggerUnit()))))) // INLINED!!
    local integer shot
    local integer mode= 0
    local integer profile= s__X3Demo_profile
    if pair != 0 then
        if GetSpellAbilityId() == 'Ax3s' or GetSpellAbilityId() == 'Ax3z' then
            set mode=1
        endif
        if GetSpellAbilityId() == 'Ax3z' then
            set profile=s__X3Buster_ZERO_PROJECT
        endif
        set shot=s__X3Buster_fireProfile(s__RapidPair_actor[pair] , GetSpellTargetX() , GetSpellTargetY() , mode , profile)
        if not s__RapidPair_firing[pair] then
            call SetUnitFacingTimed(s__RapidPair_actor[pair], Atan2(GetSpellTargetY() - GetUnitY(s__RapidPair_actor[pair]), GetSpellTargetX() - GetUnitX(s__RapidPair_actor[pair])) * bj_RADTODEG, 0.)
            call SetUnitAnimation(s__RapidPair_actor[pair], "attack")
        endif
    endif
endfunction
function X3BusterDemo__Init takes nothing returns nothing
    call RegisterSpellEffectEvent('Ax3c' , function X3BusterDemo__Cast)
    call RegisterSpellEffectEvent('Ax3s' , function X3BusterDemo__Cast)
    call RegisterSpellEffectEvent('Ax3z' , function X3BusterDemo__Cast)
endfunction

function X3Probe___Check takes boolean value,string label returns nothing
    set X3Probe___lines[X3Probe___checks]="PASS " + label
    if not value then
        set X3Probe___lines[X3Probe___checks]="FAIL " + label
        set X3Probe___failures=X3Probe___failures + 1
    endif
    set X3Probe___checks=X3Probe___checks + 1
endfunction
function X3Probe___Save takes string status returns nothing
    local integer i= 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("X3 20261023-145909 " + status)
    loop
        exitwhen i == X3Probe___checks
        call Preload(X3Probe___lines[i])
        set i=i + 1
    endloop
    call Preload("checks=" + I2S(X3Probe___checks) + " failures=" + I2S(X3Probe___failures) + " casts=" + I2S(s__X3Buster_live) + " live=" + I2S(s__X3Buster_projectiles) + " created=" + I2S(s__X3Buster_created) + " retired=" + I2S(s__X3Buster_retired) + " fusions=" + I2S(s__X3Buster_fusions) + " flashes=" + I2S((s__X3Buster___X3Flash_live))) // INLINED!!
    call Preload("facingImmediate=" + R2S(X3Probe___facingImmediate) + " facingSettled=" + R2S(X3Probe___facingSettled) + " fallbackDegrees=" + R2S(X3Probe___fallbackAngle * bj_RADTODEG))
    call Preload("boundaryFirstDamage=" + R2S(X3Probe___boundaryDamage) + " expectedFusedDamage=" + R2S(X3Probe___fusedDamage) + " reverseFirstDamage=" + R2S(X3Probe___firstDamage) + " reverseExpected=" + R2S(X3Probe___reverseExpected))
    call Preload("physicalCallbacks=" + I2S(X3Probe___physicalCallbacks) + " repeatedClockReadings=" + I2S(X3Probe___repeatedClock))
    call Preload("greenRetreat=" + R2S(X3Probe___greenRetreat) + " greenFinalSpeed=" + R2S(X3Probe___finalGreenSpeed) + " orangeFinalSpeed=" + R2S(X3Probe___finalOrangeSpeed) + " reverseDamageEvents=" + I2S(X3Probe___damageEvents))
    call PreloadGenEnd("Logs\\TerrainDev-20261023-145909-x3.txt")
endfunction
function X3Probe___Advance takes integer nextStage returns nothing
    set X3Probe___stage=nextStage
    set X3Probe___since=(TimerGetElapsed(s__X3Buster_clock)) // INLINED!!
    set X3Probe___one=false
    call X3Probe___Save("PROGRESS " + I2S(X3Probe___stage))
endfunction
function X3Probe___Damage takes nothing returns nothing
    set X3Probe___damageEvents=X3Probe___damageEvents + 1
    if X3Probe___firstDamage == 0. then
        set X3Probe___firstDamage=GetEventDamage()
    endif
endfunction
function X3Probe___Tick takes nothing returns nothing
    local real elapsed= (TimerGetElapsed(s__X3Buster_clock)) - X3Probe___since // INLINED!!
    local real gy
    local real oy
    local integer i
    local integer c
    set X3Probe___physicalCallbacks=X3Probe___physicalCallbacks + 1
    if X3Probe___previousClock == (TimerGetElapsed(s__X3Buster_clock)) then // INLINED!!
        set X3Probe___repeatedClock=X3Probe___repeatedClock + 1
    endif
    set X3Probe___previousClock=(TimerGetElapsed(s__X3Buster_clock)) // INLINED!!
    if X3Probe___stage >= 40 and X3Probe___stage <= 43 and s__X3Buster_sat1[X3Probe___shot] != 0 then
        set X3Probe___greenMinimumX=RMinBJ(X3Probe___greenMinimumX, GetUnitX(s__Missile_dummy[s__X3Buster_sat1[X3Probe___shot]]))
    endif
    if X3Probe___stage == 0 then
        if s__GroundCollision_trace(X3Probe___sx , X3Probe___sy , X3Probe___sx + 850. , X3Probe___sy , 78. , null , Player(0) , false) == 0 then
            set X3Probe___source=CreateUnit(Player(0), 'rfex', X3Probe___sx, X3Probe___sy, 0.)
            call X3Probe___Check(true , "real unobstructed lane found")
            set X3Probe___shot=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 0) , s__X3Buster_GIF)) // INLINED!!
            call X3Probe___Check(X3Probe___shot != 0 and s__X3Buster_bodies[X3Probe___shot] == 1 , "charged shot creates one body")
            call X3Probe___Check((s__Missile_path[(s__X3Buster_pulse[X3Probe___shot])]) == "X3Buster\\X3_Buster_Cargado.mdx" , "charged model A selected") // INLINED!!
            call X3Probe___Check(RAbsBJ((s__Missile_scaling[(s__X3Buster_pulse[X3Probe___shot])]) - 1.) < 0.001 , "charged width58 matches radius29") // INLINED!!
            call X3Probe___Advance(1)
        else
            set X3Probe___search=X3Probe___search + 1
            set X3Probe___sy=X3Probe___sy - 160.
            if X3Probe___search == 35 then
                call X3Probe___Check(false , "real unobstructed lane found")
                call X3Probe___Save("COMPLETE")
                call PauseTimer(X3Probe___ticker)
            endif
        endif
    elseif X3Probe___stage == 1 and elapsed >= 0.2 then
        call X3Probe___Check(s__Missile_x[s__X3Buster_pulse[X3Probe___shot]] > X3Probe___sx + 160. and s__Missile_x[s__X3Buster_pulse[X3Probe___shot]] < X3Probe___sx + 270. , "charged advances with accelerating pulse trajectory")
        call X3Probe___Check(s__Missile_speed[s__X3Buster_pulse[X3Probe___shot]] / s__X3Buster_STEP > s__X3Buster_PULSE_INITIAL + 200. and s__Missile_speed[s__X3Buster_pulse[X3Probe___shot]] / s__X3Buster_STEP < s__X3Buster_PULSE_SPEED , "charged pulse gains speed below its cap")
        call X3Probe___Check(RAbsBJ(s__Missile_y[s__X3Buster_pulse[X3Probe___shot]] - X3Probe___sy) < 0.01 , "charged flight remains straight")
        call X3Probe___Check(RAbsBJ(GetUnitX(X3Probe___source) - X3Probe___sx) < 0.01 , "physics does not move caster")
        call s__X3Buster_cancel(X3Probe___shot)
        call X3Probe___Advance(2)
    elseif X3Probe___stage == 2 and elapsed >= 0.125 then
        call X3Probe___Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 , "cancel retires charged body and cast")
        set X3Probe___baseline=s__X3Buster_fusions
        set X3Probe___births=s__X3Buster_created
        set X3Probe___satelliteBase=s__X3Buster_satellites
        set X3Probe___shot=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 1) , s__X3Buster_GIF)) // INLINED!!
        call X3Probe___Check(s__X3Buster_bodies[X3Probe___shot] == 2 and s__X3Buster_pulse[X3Probe___shot] == 0 and s__X3Buster_waiting[X3Probe___shot] , "two orbs precede delayed pulse")
        call X3Probe___Advance(3)
    elseif X3Probe___stage == 3 then
        if elapsed >= 0.125 and not X3Probe___one then
            set X3Probe___one=true
            set gy=GetUnitY(s__Missile_dummy[s__X3Buster_green[X3Probe___shot]])
            set oy=GetUnitY(s__Missile_dummy[s__X3Buster_orange[X3Probe___shot]])
            call X3Probe___Check(RAbsBJ(gy - oy) > 1. , "two bodies orbit independently in XY")
            call X3Probe___Check(RAbsBJ(gy + oy - 2. * X3Probe___sy) < 0.1 , "orb offsets remain opposite")
            call X3Probe___Check(GetUnitFlyHeight(s__Missile_dummy[s__X3Buster_green[X3Probe___shot]]) > GetUnitFlyHeight(s__Missile_dummy[s__X3Buster_orange[X3Probe___shot]]) + 1. , "orbit includes opposite height offsets")
            call X3Probe___Check(s__X3Buster_pulse[X3Probe___shot] == 0 , "no early second pulse")
            call X3Probe___Check(s__Missile_x[s__X3Buster_green[X3Probe___shot]] < X3Probe___sx + 100. , "initial orbs travel slowly ahead of the pulse")
        endif
        if elapsed >= 0.44 then
            call X3Probe___Check(s__X3Buster_pulse[X3Probe___shot] != 0 and s__Missile_x[s__X3Buster_pulse[X3Probe___shot]] < s__Missile_x[s__X3Buster_green[X3Probe___shot]] , "second pulse launches behind orbs")
            call X3Probe___Check(s__X3Buster_fusions == X3Probe___baseline , "separation alone cannot trigger fusion")
            call X3Probe___Advance(4)
        endif
    elseif X3Probe___stage == 4 and s__X3Buster_state[X3Probe___shot] == 2 then
        call X3Probe___Check(s__X3Buster_state[X3Probe___shot] == 2 and s__X3Buster_fusions == X3Probe___baseline + 1 , "catching pulse produces exactly one fusion")
        call X3Probe___Check(s__X3Buster_green[X3Probe___shot] == 0 and s__X3Buster_orange[X3Probe___shot] == 0 and s__X3Buster_pulse[X3Probe___shot] == 0 , "three precursor bodies retired after union")
        call X3Probe___Check(s__X3Buster_fused[X3Probe___shot] != 0 and (s__Missile_path[(s__X3Buster_fused[X3Probe___shot])]) == "X3Buster\\X3_Cross_Buster.mdx" , "union produces model C") // INLINED!!
        call X3Probe___Check(s__X3Buster_satellites == X3Probe___satelliteBase + 4 , "union emits four satellites")
        call X3Probe___Check(s__X3Buster_created == X3Probe___births + 8 , "bounded emission budget eight bodies per super shot")
        call X3Probe___Check(s__X3Buster_lastFusionX > X3Probe___sx + 130. and s__X3Buster_lastFusionX < X3Probe___sx + 230. , "fusion occurs at actual catch location")
        call X3Probe___Check(s__X3Buster_lastFusionAge > 0.45 and s__X3Buster_lastFusionAge < 0.70 , "catch timing matches accelerating relative motion")
        call X3Probe___Check(GetUnitY(s__Missile_dummy[s__X3Buster_sat1[X3Probe___shot]]) < GetUnitY(s__Missile_dummy[s__X3Buster_sat4[X3Probe___shot]]) , "satellites separate on opposite curved paths")
        set X3Probe___sampleGreen=GetUnitX(s__Missile_dummy[s__X3Buster_sat1[X3Probe___shot]])
        set X3Probe___greenBirthX=X3Probe___sampleGreen
        set X3Probe___greenMinimumX=X3Probe___sampleGreen
        set X3Probe___sampleOrange=GetUnitX(s__Missile_dummy[s__X3Buster_sat2[X3Probe___shot]])
        set X3Probe___sampleCore=s__Missile_x[s__X3Buster_fused[X3Probe___shot]]
        call X3Probe___Advance(40)
    elseif X3Probe___stage == 40 and elapsed >= 0.09375 then
        call X3Probe___Check(GetUnitX(s__Missile_dummy[s__X3Buster_sat1[X3Probe___shot]]) < X3Probe___sampleGreen - 6. , "green satellite really travels backwards after union")
        call X3Probe___Check(GetUnitX(s__Missile_dummy[s__X3Buster_sat2[X3Probe___shot]]) < X3Probe___sampleOrange - 3. , "orange satellite really travels backwards after union")
        call X3Probe___Check(s__Missile_speed[s__X3Buster_sat1[X3Probe___shot]] < 0. and s__Missile_speed[s__X3Buster_sat2[X3Probe___shot]] < 0. , "satellite longitudinal velocity starts negative")
        call X3Probe___Check(s__Missile_x[s__X3Buster_fused[X3Probe___shot]] > X3Probe___sampleCore and s__Missile_x[s__X3Buster_fused[X3Probe___shot]] < X3Probe___sampleCore + 40. , "core starts gently without a backwards jump")
        set X3Probe___sampleGreen=GetUnitX(s__Missile_dummy[s__X3Buster_sat1[X3Probe___shot]])
        set X3Probe___sampleSpeed=s__Missile_speed[s__X3Buster_fused[X3Probe___shot]]
        call X3Probe___Advance(41)
    elseif X3Probe___stage == 41 and elapsed >= 0.125 then
        set X3Probe___sampleGreen=RMinBJ(X3Probe___sampleGreen, GetUnitX(s__Missile_dummy[s__X3Buster_sat1[X3Probe___shot]]))
        call X3Probe___Advance(42)
    elseif X3Probe___stage == 42 and elapsed >= 0.125 then
        call X3Probe___Check(GetUnitX(s__Missile_dummy[s__X3Buster_sat1[X3Probe___shot]]) > X3Probe___sampleGreen + 5. , "satellite turns around and accelerates forwards")
        call X3Probe___Check(s__Missile_speed[s__X3Buster_sat1[X3Probe___shot]] > 0. and s__Missile_speed[s__X3Buster_sat2[X3Probe___shot]] > 0. , "both satellite families reverse their velocity")
        call X3Probe___Check(s__Missile_speed[s__X3Buster_fused[X3Probe___shot]] > X3Probe___sampleSpeed + 3. , "core accelerates after formation")
        call X3Probe___Check(RAbsBJ(GetUnitY(s__Missile_dummy[s__X3Buster_sat1[X3Probe___shot]]) + GetUnitY(s__Missile_dummy[s__X3Buster_sat4[X3Probe___shot]]) - 2. * X3Probe___sy) < 0.1 and RAbsBJ(GetUnitY(s__Missile_dummy[s__X3Buster_sat1[X3Probe___shot]]) - X3Probe___sy) > RAbsBJ(GetUnitY(s__Missile_dummy[s__X3Buster_sat2[X3Probe___shot]]) - X3Probe___sy) + 8. , "green and orange paths spread symmetrically at different rates")
        call X3Probe___Advance(43)
    elseif X3Probe___stage == 43 and elapsed >= 0.375 then
        set X3Probe___greenRetreat=X3Probe___greenBirthX - X3Probe___greenMinimumX
        set X3Probe___finalGreenSpeed=s__Missile_speed[s__X3Buster_sat1[X3Probe___shot]] / s__X3Buster_STEP
        set X3Probe___finalOrangeSpeed=s__Missile_speed[s__X3Buster_sat2[X3Probe___shot]] / s__X3Buster_STEP
        call X3Probe___Check(RAbsBJ(s__Missile_speed[s__X3Buster_sat1[X3Probe___shot]] / s__X3Buster_STEP - s__X3Buster_GREEN_SPEED) < 0.2 , "green satellite reaches its sustained speed limit")
        call X3Probe___Check(RAbsBJ(s__Missile_speed[s__X3Buster_sat2[X3Probe___shot]] / s__X3Buster_STEP - s__X3Buster_ORANGE_SPEED) < 0.2 , "orange satellite reaches its sustained speed limit")
        call X3Probe___Advance(5)
    elseif X3Probe___stage == 5 and elapsed >= 1.7 then
        call X3Probe___Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 , "complete super shot leaves no active bodies")
        call X3Probe___Check((s__X3Buster___X3Flash_live) == 0 , "union flash cleans up its own timer and dummy") // INLINED!!
        call X3Probe___Check(s__X3Buster_created == s__X3Buster_retired , "all emitted bodies retired exactly once")
        set X3Probe___baseline=s__X3Buster_fusions
        set X3Probe___shot=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 2) , s__X3Buster_GIF)) // INLINED!!
        call X3Probe___Advance(6)
    elseif X3Probe___stage == 6 and elapsed >= 0.16 then
        call X3Probe___Check(s__X3Buster_pulse[X3Probe___shot] == 0 and s__X3Buster_waiting[X3Probe___shot] , "manual API waits for release")
        call X3Probe___Check(s__X3Buster_releasePulse(X3Probe___shot) , "manual release emits one pulse")
        call X3Probe___Check(not s__X3Buster_releasePulse(X3Probe___shot) , "duplicate release is rejected")
        call X3Probe___Advance(7)
    elseif X3Probe___stage == 7 and elapsed >= 0.5 then
        call X3Probe___Check(s__X3Buster_fusions == X3Probe___baseline + 1 , "manual second pulse can fuse")
        call s__X3Buster_cancel(X3Probe___shot)
        call X3Probe___Advance(8)
    elseif X3Probe___stage == 8 and elapsed >= 0.125 then
        set X3Probe___baseline=s__X3Buster_fusions
        set X3Probe___shot=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 1) , s__X3Buster_GIF)) // INLINED!!
        set s__Missile_wantDestroy[(s__X3Buster_green[X3Probe___shot])]=true // INLINED!!
        call X3Probe___Advance(9)
    elseif X3Probe___stage == 9 and elapsed >= 0.8 then
        call X3Probe___Check(s__X3Buster_fusions == X3Probe___baseline and s__X3Buster_fused[X3Probe___shot] == 0 , "missing orb prevents fusion")
        call s__X3Buster_cancel(X3Probe___shot)
        call X3Probe___Advance(10)
    elseif X3Probe___stage == 10 and elapsed >= 0.125 then
        set X3Probe___baseline=s__X3Buster_fusions
        set X3Probe___hitBase=s__X3Buster_hits
        set X3Probe___target=CreateUnit(Player(12), 'rftg', X3Probe___sx + 120., X3Probe___sy, 180.)
        set X3Probe___shot=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 1) , s__X3Buster_GIF)) // INLINED!!
        call X3Probe___Advance(11)
    elseif X3Probe___stage == 11 and elapsed >= 0.9 then
        call X3Probe___Check(s__X3Buster_hits > X3Probe___hitBase and GetWidgetLife(X3Probe___target) < 2000. , "real enemy collision applies damage")
        call X3Probe___Check(s__X3Buster_fusions == X3Probe___baseline , "enemy impact before union prevents fusion")
        call RemoveUnit(X3Probe___target)
        set X3Probe___target=null
        call s__X3Buster_cancel(X3Probe___shot)
        call X3Probe___Advance(12)
    elseif X3Probe___stage == 12 and elapsed >= 0.125 then
        set X3Probe___baseline=s__X3Buster_fusions
        set X3Probe___wallBase=s__X3Buster_walls
        set X3Probe___tree=CreateDestructable('LTlt', X3Probe___sx + 130., X3Probe___sy, 0., 1., 0)
        set X3Probe___shot=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 1) , s__X3Buster_GIF)) // INLINED!!
        call X3Probe___Advance(13)
    elseif X3Probe___stage == 13 and elapsed >= 0.9 then
        call X3Probe___Check(s__X3Buster_walls > X3Probe___wallBase , "real destructible blocks projectile sweeps")
        call X3Probe___Check(s__X3Buster_fusions == X3Probe___baseline , "obstacle before union prevents fusion")
        call RemoveDestructable(X3Probe___tree)
        set X3Probe___tree=null
        call s__X3Buster_cancel(X3Probe___shot)
        call X3Probe___Advance(14)
    elseif X3Probe___stage == 14 and elapsed >= 0.125 then
        set X3Probe___baseline=s__X3Buster_fusions
        set X3Probe___shot=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 1) , s__X3Buster_GIF)) // INLINED!!
        set X3Probe___second=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 1) , s__X3Buster_GIF)) // INLINED!!
        call X3Probe___Advance(15)
    elseif X3Probe___stage == 15 and elapsed >= 0.75 then
        call X3Probe___Check(s__X3Buster_fusions == X3Probe___baseline + 2 , "simultaneous casts fuse only their own components")
        call X3Probe___Check(s__X3Buster_fused[X3Probe___shot] != s__X3Buster_fused[X3Probe___second] and s__X3Buster_state[X3Probe___shot] == 2 and s__X3Buster_state[X3Probe___second] == 2 , "independent resulting missiles per cast")
        call s__X3Buster_cancel(X3Probe___shot)
        call s__X3Buster_cancel(X3Probe___second)
        call X3Probe___Advance(16)
    elseif X3Probe___stage == 16 and elapsed >= 0.125 then
        call SetUnitFacing(X3Probe___source, 90.)
        set X3Probe___facingImmediate=GetUnitFacing(X3Probe___source)
        set X3Probe___shot=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx )*1.0) , (( X3Probe___sy )*1.0) , ( 0) , s__X3Buster_GIF)) // INLINED!!
        set X3Probe___fallbackAngle=s__X3Buster_angle[X3Probe___shot]
        call X3Probe___Check(RAbsBJ(s__X3Buster_angle[X3Probe___shot] - X3Probe___facingImmediate * bj_DEGTORAD) < 0.01 , "zero-distance aim falls back to unit facing")
        call s__X3Buster_cancel(X3Probe___shot)
        call X3Probe___Advance(17)
    elseif X3Probe___stage == 17 and elapsed >= 0.5 then
        set X3Probe___facingSettled=GetUnitFacing(X3Probe___source)
        call X3Probe___Check(RAbsBJ(X3Probe___facingSettled - 90.) < 0.1 , "native facing reaches requested angle after motor ticks")
        set X3Probe___shot=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 1) , s__X3Buster_GIF)) // INLINED!!
        call RemoveUnit(X3Probe___source)
        set X3Probe___source=null
        call X3Probe___Advance(18)
    elseif X3Probe___stage == 18 and elapsed >= 0.2 then
        call X3Probe___Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 , "removed caster cancels pending and flying bodies")
        call X3Probe___Check(s__X3Buster_created == s__X3Buster_retired , "interrupted casts preserve balanced lifecycle")
        set X3Probe___source=CreateUnit(Player(0), 'rfex', X3Probe___sx, X3Probe___sy, 0.)
        set X3Probe___capIndex=0
        call X3Probe___Advance(19)
    elseif X3Probe___stage == 19 then
        set i=0
        loop
            exitwhen i == 4
            set X3Probe___capped[X3Probe___capIndex]=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 2) , s__X3Buster_GIF)) // INLINED!!
            set X3Probe___capIndex=X3Probe___capIndex + 1
            set i=i + 1
        endloop
        if X3Probe___capIndex < 64 then
            return
        endif
        set c=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 2) , s__X3Buster_GIF)) // INLINED!!
        call X3Probe___Check(c == 0 and s__X3Buster_live == 64 , "concurrent cast limit rejects overflow")
        set i=0
        loop
            exitwhen i == 64
            call s__X3Buster_cancel((X3Probe___capped[i]))
            set i=i + 1
        endloop
        call X3Probe___Advance(20)
    elseif X3Probe___stage == 20 and elapsed >= 0.5 then
        call X3Probe___Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 , "all capped and cancelled casts retire")
        call X3Probe___Check(s__X3Buster_created == s__X3Buster_retired , "final created equals retired")
        call X3Probe___Check((s__X3Buster___X3Flash_live) == 0 , "final flash count zero") // INLINED!!
        call RemoveUnit(X3Probe___source)
        set X3Probe___source=CreateUnit(Player(0), 'rfex', X3Probe___sx, X3Probe___sy, 0.)
        set X3Probe___nativePair=s__RapidPair_create(CreateUnit(Player(0), 'rfct', s__WorldBounds_minX + 256., s__WorldBounds_minY + 256., 0.) , X3Probe___source)
        set X3Probe___births=s__X3Buster_created
        call X3Probe___Check(IssuePointOrder(s__RapidPair_controller[X3Probe___nativePair], "carrionswarm", X3Probe___sx + 1400., X3Probe___sy) , "native W order accepted by controller")
        call X3Probe___Advance(21)
    elseif X3Probe___stage == 21 and elapsed >= 0.25 then
        call X3Probe___Check(s__X3Buster_created == X3Probe___births + 1 , "native W spell event creates charged physics")
        call X3Probe___Check(GetUnitCurrentOrder(X3Probe___source) == 0 , "visible executor receives no spell order")
        call X3Probe___Advance(22)
    elseif X3Probe___stage == 22 and elapsed >= 1.5 then
        set X3Probe___births=s__X3Buster_created
        set X3Probe___baseline=s__X3Buster_fusions
        call X3Probe___Check(IssuePointOrder(s__RapidPair_controller[X3Probe___nativePair], "shockwave", X3Probe___sx + 1400., X3Probe___sy) , "native E order accepted by controller")
        call X3Probe___Advance(23)
    elseif X3Probe___stage == 23 and elapsed >= 0.75 then
        call X3Probe___Check(s__X3Buster_fusions == X3Probe___baseline + 1 and s__X3Buster_created == X3Probe___births + 8 , "native E spell event completes cross-shot sequence")
        call X3Probe___Advance(24)
    elseif X3Probe___stage == 24 and elapsed >= 2.2 then
        call X3Probe___Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 and s__X3Buster_created == s__X3Buster_retired , "native abilities leave balanced zero-active state")
        call s__RapidPair_destroy(X3Probe___nativePair)
        set X3Probe___baseline=s__X3Buster_fusions
        set X3Probe___shot=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 1) , s__X3Buster_GIF)) // INLINED!!
        call X3Probe___Advance(25)
    elseif X3Probe___stage == 25 then
        if s__X3Buster_pulse[X3Probe___shot] != 0 then
            set gy=s__Missile_x[s__X3Buster_green[X3Probe___shot]] - s__Missile_x[s__X3Buster_pulse[X3Probe___shot]]
            if gy > 0. and gy <= s__Missile_speed[s__X3Buster_pulse[X3Probe___shot]] - s__Missile_speed[s__X3Buster_green[X3Probe___shot]] then
                set X3Probe___catchX=s__Missile_x[s__X3Buster_green[X3Probe___shot]] + gy * s__Missile_speed[s__X3Buster_green[X3Probe___shot]] / ( s__Missile_speed[s__X3Buster_pulse[X3Probe___shot]] - s__Missile_speed[s__X3Buster_green[X3Probe___shot]] )
                set X3Probe___catchY=X3Probe___sy
                set X3Probe___target=CreateUnit(Player(12), 'rftg', X3Probe___catchX + 50., X3Probe___catchY, 180.)
                set i=0
                loop
                    call SetUnitX(X3Probe___target, X3Probe___catchX + 50. + I2R(i) * 2.)
                    exitwhen ( s__GroundCollision_trace(s__Missile_x[s__X3Buster_pulse[X3Probe___shot]] , X3Probe___sy , X3Probe___catchX , X3Probe___sy , 29. , X3Probe___source , Player(0) , true) == 0 and s__GroundCollision_trace(s__Missile_x[s__X3Buster_pulse[X3Probe___shot]] , X3Probe___sy , s__Missile_x[s__X3Buster_pulse[X3Probe___shot]] + s__Missile_speed[s__X3Buster_pulse[X3Probe___shot]] , X3Probe___sy , 29. , X3Probe___source , Player(0) , true) == 2 ) or i == 25
                    set i=i + 1
                endloop
                call X3Probe___Check(i < 25 , "boundary fixture clear before union and enemy later in same tick")
                set X3Probe___damageWatch=CreateTrigger()
                call TriggerRegisterUnitEvent(X3Probe___damageWatch, X3Probe___target, EVENT_UNIT_DAMAGED)
                call TriggerAddAction(X3Probe___damageWatch, function X3Probe___Damage)
                // Calibrate native armor/resistance before observing the shot.
                call UnitDamageTarget(X3Probe___source, X3Probe___target, 150., false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                set X3Probe___fusedDamage=X3Probe___firstDamage
                set X3Probe___firstDamage=0.
                call SetWidgetLife(X3Probe___target, 2000.)
                call X3Probe___Advance(26)
            endif
        endif
        if elapsed > 1. then
            call X3Probe___Check(false , "boundary fixture clear before union and enemy later in same tick")
            call X3Probe___Advance(26)
        endif
    elseif X3Probe___stage == 26 and elapsed >= 0.3 then
        set X3Probe___boundaryDamage=X3Probe___firstDamage
        call X3Probe___Check(s__X3Buster_fusions == X3Probe___baseline + 1 and X3Probe___fusedDamage > 0. and RAbsBJ(X3Probe___firstDamage - X3Probe___fusedDamage) < 0.1 , "fusion precedes later enemy impact inside the same tick")
        call DestroyTrigger(X3Probe___damageWatch)
        set X3Probe___damageWatch=null
        call RemoveUnit(X3Probe___target)
        set X3Probe___target=null
        call s__X3Buster_cancel(X3Probe___shot)
        call X3Probe___Advance(27)
    elseif X3Probe___stage == 27 and elapsed >= 0.2 then
        call X3Probe___Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 and s__X3Buster_created == s__X3Buster_retired , "boundary case cleanup remains balanced")
        set X3Probe___shot=(s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 1) , s__X3Buster_GIF)) // INLINED!!
        set X3Probe___hitBase=s__X3Buster_hits
        call X3Probe___Advance(28)
    elseif X3Probe___stage == 28 and s__X3Buster_state[X3Probe___shot] == 2 then
        set X3Probe___target=CreateUnit(Player(12), 'rftg', s__X3Buster_lastFusionX - 80., X3Probe___sy - 55., 180.)
        call X3Probe___Check(s__GroundCollision_trace(s__X3Buster_lastFusionX , X3Probe___sy , s__X3Buster_lastFusionX + 150. , X3Probe___sy , 41.25 , X3Probe___source , Player(0) , true) == 0 , "backwards-collision target stays clear of the forward core")
        set X3Probe___firstDamage=0.
        set X3Probe___damageWatch=CreateTrigger()
        call TriggerRegisterUnitEvent(X3Probe___damageWatch, X3Probe___target, EVENT_UNIT_DAMAGED)
        call TriggerAddAction(X3Probe___damageWatch, function X3Probe___Damage)
        call UnitDamageTarget(X3Probe___source, X3Probe___target, 25., false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
        set X3Probe___reverseExpected=X3Probe___firstDamage
        set X3Probe___firstDamage=0.
        set X3Probe___damageEvents=0
        call SetWidgetLife(X3Probe___target, 2000.)
        call X3Probe___Advance(29)
    elseif X3Probe___stage == 29 and elapsed >= 0.45 then
        call X3Probe___Check(s__X3Buster_hits > X3Probe___hitBase and X3Probe___reverseExpected > 0. and RAbsBJ(X3Probe___firstDamage - X3Probe___reverseExpected) < 0.1 and X3Probe___damageEvents == 1 , "retreating satellite sweeps its real path and damages once")
        call DestroyTrigger(X3Probe___damageWatch)
        set X3Probe___damageWatch=null
        call RemoveUnit(X3Probe___target)
        set X3Probe___target=null
        call s__X3Buster_cancel(X3Probe___shot)
        call X3Probe___Advance(30)
    elseif X3Probe___stage == 30 and elapsed >= 0.2 then
        call X3Probe___Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 and s__X3Buster_created == s__X3Buster_retired , "retrograde collision leaves balanced zero-active state")
        call RemoveUnit(X3Probe___source)
        set X3Probe___source=null
        call X3Probe___Save("COMPLETE")
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 60., "X3 COMPLETE " + I2S(X3Probe___checks) + " checks / " + I2S(X3Probe___failures) + " failures. -x3show para demostracion.")
        call PauseTimer(X3Probe___ticker)
        set X3Probe___stage=- 2
    endif
endfunction
function X3Probe___Begin takes nothing returns nothing
    if X3Probe___stage != - 1 then
        return
    endif
    set X3Probe___stage=0
    set X3Probe___since=(TimerGetElapsed(s__X3Buster_clock)) // INLINED!!
    call TimerStart(X3Probe___ticker, 1. / 32., true, function X3Probe___Tick)
endfunction
function X3Probe___Repeat takes nothing returns nothing
    local integer s= (s__X3Buster_fireProfile((X3Probe___source ) , (( X3Probe___sx + 1400. )*1.0) , (( X3Probe___sy )*1.0) , ( 1) , s__X3Buster_GIF)) // INLINED!!
endfunction
function X3Probe___Show takes nothing returns nothing
    if X3Probe___stage != - 2 then
        return
    endif
    set X3Probe___source=CreateUnit(Player(0), 'rfex', X3Probe___sx, X3Probe___sy, 0.)
    call SetCameraTargetController(null, 0., 0., false)
    call PanCameraToTimed(X3Probe___sx + 450., X3Probe___sy, 0.)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 1350., 0.)
    call FogEnable(false)
    call FogMaskEnable(false)
    call SetTimeOfDay(12.)
    call SuspendTimeOfDay(true)
    call MultiboardDisplay(s__MissileStats_board, false)
    call ClearTextMessages()
    call TimerStart(X3Probe___showing, 2.5, true, function X3Probe___Repeat)
    call X3Probe___Repeat()
endfunction
function X3ProbeLaneX takes nothing returns real
    return X3Probe___sx
endfunction
function X3ProbeLaneY takes nothing returns real
    return X3Probe___sy
endfunction
function X3Probe___Init takes nothing returns nothing
    local trigger t= CreateTrigger()
    set s__X3Demo_profile=s__X3Buster_GIF
    call TriggerRegisterPlayerChatEvent(t, Player(0), "-x3test", true)
    call TriggerAddAction(t, function X3Probe___Begin)
    set t=CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t, Player(0), "-x3show", true)
    call TriggerAddAction(t, function X3Probe___Show)
    set t=null
endfunction

function X3NativeProbe___Check takes boolean ok,string label returns nothing
    set X3NativeProbe___lines[X3NativeProbe___checks]="PASS " + label
    if not ok then
        set X3NativeProbe___lines[X3NativeProbe___checks]="FAIL " + label
        set X3NativeProbe___failures=X3NativeProbe___failures + 1
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 60., X3NativeProbe___lines[X3NativeProbe___checks])
    endif
    set X3NativeProbe___checks=X3NativeProbe___checks + 1
endfunction
function X3NativeProbe___Save takes string status returns nothing
    local integer i= 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("NATIVE 20261023-145909 " + status)
    loop
        exitwhen i == X3NativeProbe___checks
        call Preload(X3NativeProbe___lines[i])
        set i=i + 1
    endloop
    call Preload("checks=" + I2S(X3NativeProbe___checks) + " failures=" + I2S(X3NativeProbe___failures) + " oracle=" + I2S(s__X3Oracle_valueChecks) + " oracleFailures=" + I2S(s__X3Oracle_valueFailures) + " maxError=" + R2S(s__X3Oracle_maxError))
    call Preload(X3NativeProbe___diagnostics)
    call Preload("casts=" + I2S(s__X3Buster_live) + " live=" + I2S(s__X3Buster_projectiles) + " created=" + I2S(s__X3Buster_created - X3NativeProbe___baseCreated) + " retired=" + I2S(s__X3Buster_retired - X3NativeProbe___baseRetired) + " flashes=" + I2S((s__X3Buster___X3Flash_live))) // INLINED!!
    call PreloadGenEnd("Logs\\TerrainDev-20261023-145909-native.txt")
endfunction
function X3NativeProbe___Advance takes integer n returns nothing
    set X3NativeProbe___stage=n
    set X3NativeProbe___since=(TimerGetElapsed(s__X3Buster_clock)) // INLINED!!
    call X3NativeProbe___Save("PROGRESS " + I2S(n))
endfunction
function X3NativeProbe___Position takes integer m,integer form,real ox,real oy,real angle,integer profile returns boolean
    local real t= (s__X3Buster___X3Body_age[((m))]) // INLINED!!
    local real x= s__X3Kinematics_forward(profile , form , t)
    local real y= s__X3Kinematics_side(profile , form , t)
    if form == 1 or form == 2 or form == 9 then
        set x=s__X3Kinematics_orbitForward(form , t)
    endif
    return RAbsBJ(GetUnitX(s__Missile_dummy[m]) - ( ox + x * Cos(angle) - y * Sin(angle) )) < 0.15 and RAbsBJ(GetUnitY(s__Missile_dummy[m]) - ( oy + x * Sin(angle) + y * Cos(angle) )) < 0.15
endfunction
function X3NativeProbe___Tick takes nothing returns nothing
    local real elapsed= (TimerGetElapsed(s__X3Buster_clock)) - X3NativeProbe___since // INLINED!!
    if elapsed > 9. then
        call X3NativeProbe___Check(false , "bounded stage timeout " + I2S(X3NativeProbe___stage))
        call X3NativeProbe___Save("TIMEOUT")
        call PauseTimer(X3NativeProbe___ticker)
        return
    endif
    if X3NativeProbe___stage == 0 then
        call s__X3Oracle_step()
        if s__X3Oracle_done then
            call X3NativeProbe___Check(s__X3Oracle_valueChecks == 5259 and s__X3Oracle_valueFailures == 0 , "5259 ROM CSV values match vJASS within 0.012 world units")
            set X3NativeProbe___sx=(X3Probe___sx) // INLINED!!
            set X3NativeProbe___sy=(X3Probe___sy) // INLINED!!
            set X3NativeProbe___source=CreateUnit(Player(0), 'rfex', X3NativeProbe___sx, X3NativeProbe___sy, 0.)
            set X3NativeProbe___births=s__X3Buster_created
            set X3NativeProbe___merges=s__X3Buster_fusions
            set X3NativeProbe___shot=s__X3Buster_fireProfile(X3NativeProbe___source , X3NativeProbe___sx + 1400. , X3NativeProbe___sy , 2 , s__X3Buster_ORIGINAL)
            call X3NativeProbe___Check(X3NativeProbe___shot != 0 and s__X3Buster_profile[X3NativeProbe___shot] == 1 and s__X3Buster_bodies[X3NativeProbe___shot] == 3 and s__X3Buster_blue[X3NativeProbe___shot] != 0 , "USA starts three owned helix components")
            call X3NativeProbe___Check(X3NativeProbe___Position(s__X3Buster_green[X3NativeProbe___shot] , 1 , s__X3Buster_originX[X3NativeProbe___shot] , s__X3Buster_originY[X3NativeProbe___shot] , s__X3Buster_angle[X3NativeProbe___shot] , 1) and X3NativeProbe___Position(s__X3Buster_orange[X3NativeProbe___shot] , 2 , s__X3Buster_originX[X3NativeProbe___shot] , s__X3Buster_originY[X3NativeProbe___shot] , s__X3Buster_angle[X3NativeProbe___shot] , 1) and X3NativeProbe___Position(s__X3Buster_blue[X3NativeProbe___shot] , 9 , s__X3Buster_originX[X3NativeProbe___shot] , s__X3Buster_originY[X3NativeProbe___shot] , s__X3Buster_angle[X3NativeProbe___shot] , 1) , "three components start at their native offsets")
            call X3NativeProbe___Advance(1)
        endif
    elseif X3NativeProbe___stage == 1 and elapsed >= 0.18 then
        call X3NativeProbe___Check(X3NativeProbe___Position(s__X3Buster_green[X3NativeProbe___shot] , 1 , s__X3Buster_originX[X3NativeProbe___shot] , s__X3Buster_originY[X3NativeProbe___shot] , s__X3Buster_angle[X3NativeProbe___shot] , 1) and X3NativeProbe___Position(s__X3Buster_orange[X3NativeProbe___shot] , 2 , s__X3Buster_originX[X3NativeProbe___shot] , s__X3Buster_originY[X3NativeProbe___shot] , s__X3Buster_angle[X3NativeProbe___shot] , 1) and X3NativeProbe___Position(s__X3Buster_blue[X3NativeProbe___shot] , 9 , s__X3Buster_originX[X3NativeProbe___shot] , s__X3Buster_originY[X3NativeProbe___shot] , s__X3Buster_angle[X3NativeProbe___shot] , 1) , "three rendered helix paths follow native knots")
        call X3NativeProbe___Check(s__X3Buster_releasePulse(X3NativeProbe___shot) , "manual USA second pulse accepted")
        call X3NativeProbe___Advance(2)
    elseif X3NativeProbe___stage == 2 and s__X3Buster_forming[X3NativeProbe___shot] then
        set X3NativeProbe___formationStarted=(TimerGetElapsed(s__X3Buster_clock)) // INLINED!!
        call X3NativeProbe___Check(s__X3Buster_state[X3NativeProbe___shot] == 4 and s__X3Buster_fused[X3NativeProbe___shot] == 0 and s__X3Buster_created == X3NativeProbe___births + 4 , "USA union retires four precursors before five-body emission")
        call X3NativeProbe___Check(s__X3Buster_fusions == X3NativeProbe___merges + 1 and (s__X3Buster___X3Flash_live) == 1 , "USA union has exactly one flash and one fusion") // INLINED!!
        call X3NativeProbe___Check(RAbsBJ(s__X3Buster_lastFusionX - s__X3Buster_originX[X3NativeProbe___shot]) < 0.15 , "union relocates to the still-growing second pulse")
        call X3NativeProbe___Advance(3)
    elseif X3NativeProbe___stage == 3 and elapsed >= 0.09 then
        call X3NativeProbe___Check(s__X3Buster_forming[X3NativeProbe___shot] and s__X3Buster_fused[X3NativeProbe___shot] == 0 and s__X3Buster_projectiles == 0 , "USA formation retains cast with zero missile bodies")
        call X3NativeProbe___Advance(4)
    elseif X3NativeProbe___stage == 4 and not s__X3Buster_forming[X3NativeProbe___shot] then
        call X3NativeProbe___Check(s__X3Buster_state[X3NativeProbe___shot] == 2 and s__X3Buster_bodies[X3NativeProbe___shot] == 5 and s__X3Buster_created == X3NativeProbe___births + 9 , "USA emits core plus four satellites exactly once")
        call X3NativeProbe___Check(RAbsBJ((TimerGetElapsed(s__X3Buster_clock)) - X3NativeProbe___formationStarted - s__X3Kinematics_formation(1)) < 0.05 , "USA formation lasts native 18 frames within engine tick tolerance") // INLINED!!
        call X3NativeProbe___Advance(5)
    elseif X3NativeProbe___stage == 5 and elapsed >= 0.12 then
        call X3NativeProbe___Check(X3NativeProbe___Position(s__X3Buster_fused[X3NativeProbe___shot] , 4 , s__X3Buster_lastFusionX , s__X3Buster_lastFusionY , s__X3Buster_angle[X3NativeProbe___shot] , 1) , "USA core render follows native acceleration")
        call X3NativeProbe___Check(X3NativeProbe___Position(s__X3Buster_sat1[X3NativeProbe___shot] , 5 , s__X3Buster_lastFusionX , s__X3Buster_lastFusionY , s__X3Buster_angle[X3NativeProbe___shot] , 1) and X3NativeProbe___Position(s__X3Buster_sat2[X3NativeProbe___shot] , 6 , s__X3Buster_lastFusionX , s__X3Buster_lastFusionY , s__X3Buster_angle[X3NativeProbe___shot] , 1) and X3NativeProbe___Position(s__X3Buster_sat3[X3NativeProbe___shot] , 7 , s__X3Buster_lastFusionX , s__X3Buster_lastFusionY , s__X3Buster_angle[X3NativeProbe___shot] , 1) and X3NativeProbe___Position(s__X3Buster_sat4[X3NativeProbe___shot] , 8 , s__X3Buster_lastFusionX , s__X3Buster_lastFusionY , s__X3Buster_angle[X3NativeProbe___shot] , 1) , "USA four rendered satellites follow native retreat and separation")
        call X3NativeProbe___Check(GetUnitX(s__Missile_dummy[s__X3Buster_sat1[X3NativeProbe___shot]]) < s__X3Buster_lastFusionX - 40. , "USA first pair visibly retreats before accelerating")
        call s__X3Buster_cancel(X3NativeProbe___shot)
        call X3NativeProbe___Advance(6)
    elseif X3NativeProbe___stage == 6 and elapsed >= 0.3 then
        call X3NativeProbe___Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 , "USA cancellation retires every body")
        call SetUnitX(X3NativeProbe___source, X3NativeProbe___sx + 750.)
        set X3NativeProbe___births=s__X3Buster_created
        set X3NativeProbe___merges=s__X3Buster_fusions
        set X3NativeProbe___shot=s__X3Buster_fireProfile(X3NativeProbe___source , X3NativeProbe___sx - 650. , X3NativeProbe___sy , 1 , 2)
        call X3NativeProbe___Check(X3NativeProbe___shot != 0 and s__X3Buster_profile[X3NativeProbe___shot] == 2 and s__X3Buster_bodies[X3NativeProbe___shot] == 3 , "Zero Project starts independently facing left")
        call X3NativeProbe___Advance(7)
    elseif X3NativeProbe___stage == 7 and s__X3Buster_forming[X3NativeProbe___shot] then
        set X3NativeProbe___formationStarted=(TimerGetElapsed(s__X3Buster_clock)) // INLINED!!
        call X3NativeProbe___Check(s__X3Buster_fusions == X3NativeProbe___merges + 1 and s__X3Buster_created == X3NativeProbe___births + 4 and s__X3Buster_fused[X3NativeProbe___shot] == 0 , "Zero Project automatic second pulse enters formation")
        call X3NativeProbe___Advance(8)
    elseif X3NativeProbe___stage == 8 and not s__X3Buster_forming[X3NativeProbe___shot] then
        call X3NativeProbe___Check(s__X3Buster_state[X3NativeProbe___shot] == 2 and s__X3Buster_bodies[X3NativeProbe___shot] == 5 and s__X3Buster_created == X3NativeProbe___births + 9 , "Zero Project emits five bodies")
        call X3NativeProbe___Check(RAbsBJ((TimerGetElapsed(s__X3Buster_clock)) - X3NativeProbe___formationStarted - s__X3Kinematics_formation(2)) < 0.05 , "Zero Project formation lasts native 8 frames within engine tick tolerance") // INLINED!!
        call X3NativeProbe___Advance(9)
    elseif X3NativeProbe___stage == 9 and elapsed >= 0.15 then
        call X3NativeProbe___Check(X3NativeProbe___Position(s__X3Buster_fused[X3NativeProbe___shot] , 4 , s__X3Buster_lastFusionX , s__X3Buster_lastFusionY , s__X3Buster_angle[X3NativeProbe___shot] , 2) , "Zero Project core has immediate native capped speed")
        call X3NativeProbe___Check(X3NativeProbe___Position(s__X3Buster_sat1[X3NativeProbe___shot] , 5 , s__X3Buster_lastFusionX , s__X3Buster_lastFusionY , s__X3Buster_angle[X3NativeProbe___shot] , 2) and X3NativeProbe___Position(s__X3Buster_sat2[X3NativeProbe___shot] , 6 , s__X3Buster_lastFusionX , s__X3Buster_lastFusionY , s__X3Buster_angle[X3NativeProbe___shot] , 2) and X3NativeProbe___Position(s__X3Buster_sat3[X3NativeProbe___shot] , 7 , s__X3Buster_lastFusionX , s__X3Buster_lastFusionY , s__X3Buster_angle[X3NativeProbe___shot] , 2) and X3NativeProbe___Position(s__X3Buster_sat4[X3NativeProbe___shot] , 8 , s__X3Buster_lastFusionX , s__X3Buster_lastFusionY , s__X3Buster_angle[X3NativeProbe___shot] , 2) , "Zero Project four curved trajectories rotate correctly to left")
        call s__X3Buster_cancel(X3NativeProbe___shot)
        call X3NativeProbe___Advance(10)
    elseif X3NativeProbe___stage == 10 and elapsed >= 0.3 then
        call SetUnitX(X3NativeProbe___source, X3NativeProbe___sx)
        set X3NativeProbe___shot=s__X3Buster_fireProfile(X3NativeProbe___source , X3NativeProbe___sx + 1400. , X3NativeProbe___sy , 2 , 1)
        call s__X3Buster_releasePulse(X3NativeProbe___shot)
        call X3NativeProbe___Advance(11)
    elseif X3NativeProbe___stage == 11 and s__X3Buster_forming[X3NativeProbe___shot] then
        set X3NativeProbe___births=s__X3Buster_created
        call s__X3Buster_cancel(X3NativeProbe___shot)
        call X3NativeProbe___Advance(12)
    elseif X3NativeProbe___stage == 12 and elapsed >= 0.5 then
        call X3NativeProbe___Check(s__X3Buster_created == X3NativeProbe___births and s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 and (s__X3Buster___X3Flash_live) == 0 , "cancelling formation releases its timer without delayed emission or flash leak") // INLINED!!
        set X3NativeProbe___shot=s__X3Buster_fireProfile(X3NativeProbe___source , X3NativeProbe___sx + 1400. , X3NativeProbe___sy , 2 , 1)
        set X3NativeProbe___merges=s__X3Buster_fusions
        set s__Missile_wantDestroy[(s__X3Buster_blue[X3NativeProbe___shot])]=true // INLINED!!
        call s__X3Buster_releasePulse(X3NativeProbe___shot)
        call X3NativeProbe___Advance(13)
    elseif X3NativeProbe___stage == 13 and elapsed >= 0.6 then
        call X3NativeProbe___Check(s__X3Buster_fusions == X3NativeProbe___merges and not s__X3Buster_forming[X3NativeProbe___shot] , "missing third helix component prevents native union")
        call s__X3Buster_cancel(X3NativeProbe___shot)
        call X3NativeProbe___Advance(14)
    elseif X3NativeProbe___stage == 14 and elapsed >= 0.2 then
        set X3NativeProbe___shot=s__X3Buster_fireProfile(X3NativeProbe___source , X3NativeProbe___sx + 1400. , X3NativeProbe___sy , 2 , 2)
        call s__X3Buster_releasePulse(X3NativeProbe___shot)
        call X3NativeProbe___Advance(15)
    elseif X3NativeProbe___stage == 15 and s__X3Buster_forming[X3NativeProbe___shot] then
        set X3NativeProbe___births=s__X3Buster_created
        call KillUnit(X3NativeProbe___source)
        call X3NativeProbe___Advance(16)
    elseif X3NativeProbe___stage == 16 and elapsed >= 0.4 then
        call X3NativeProbe___Check(s__X3Buster_created == X3NativeProbe___births and s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 , "dead source during formation cannot emit delayed bodies")
        call RemoveUnit(X3NativeProbe___source)
        set X3NativeProbe___source=CreateUnit(Player(0), 'rfex', X3NativeProbe___sx, X3NativeProbe___sy, 0.)
        set X3NativeProbe___births=s__X3Buster_created
        set X3NativeProbe___merges=s__X3Buster_fusions
        set X3NativeProbe___shot=s__X3Buster_fireProfile(X3NativeProbe___source , X3NativeProbe___sx + 1400. , X3NativeProbe___sy , 1 , 1)
        set X3NativeProbe___second=s__X3Buster_fireProfile(X3NativeProbe___source , X3NativeProbe___sx + 1400. , X3NativeProbe___sy , 1 , 2)
        call X3NativeProbe___Advance(17)
    elseif X3NativeProbe___stage == 17 and elapsed >= 0.85 then
        call X3NativeProbe___Check(s__X3Buster_fusions == X3NativeProbe___merges + 2 and s__X3Buster_created == X3NativeProbe___births + 18 , "simultaneous USA and mod casts keep separate pairs and formation timers")
        call X3NativeProbe___Check(s__X3Buster_profile[X3NativeProbe___shot] == 1 and s__X3Buster_profile[X3NativeProbe___second] == 2 , "profile remains immutable for each live cast")
        call s__X3Buster_cancel(X3NativeProbe___shot)
        call s__X3Buster_cancel(X3NativeProbe___second)
        call X3NativeProbe___Advance(18)
    elseif X3NativeProbe___stage == 18 and elapsed >= 0.3 then
        set X3NativeProbe___pair=s__RapidPair_create(CreateUnit(Player(0), 'rfct', s__WorldBounds_minX + 256., s__WorldBounds_minY + 256., 0.) , X3NativeProbe___source)
        set s__X3Demo_profile=1
        set X3NativeProbe___births=s__X3Buster_created
        set X3NativeProbe___merges=s__X3Buster_fusions
        call X3NativeProbe___Check(IssuePointOrder(s__RapidPair_controller[X3NativeProbe___pair], "shockwave", X3NativeProbe___sx + 1400., X3NativeProbe___sy) , "controller accepts native E USA order")
        call X3NativeProbe___Advance(19)
    elseif X3NativeProbe___stage == 19 and elapsed >= 0.85 then
        call X3NativeProbe___Check(s__X3Buster_fusions == X3NativeProbe___merges + 1 and s__X3Buster_created == X3NativeProbe___births + 9 , "native E selects the three-component USA sequence")
        call X3NativeProbe___Check(GetUnitCurrentOrder(X3NativeProbe___source) == 0 , "native E does not issue a spell order to visible actor")
        call X3NativeProbe___Advance(20)
    elseif X3NativeProbe___stage == 20 and elapsed >= 3.8 then
        set X3NativeProbe___births=s__X3Buster_created
        set X3NativeProbe___merges=s__X3Buster_fusions
        call X3NativeProbe___Check(IssuePointOrder(s__RapidPair_controller[X3NativeProbe___pair], "breathoffire", X3NativeProbe___sx + 1400., X3NativeProbe___sy) , "controller accepts native R Zero Project order")
        call X3NativeProbe___Advance(21)
    elseif X3NativeProbe___stage == 21 and elapsed >= 0.8 then
        call X3NativeProbe___Check(s__X3Buster_fusions == X3NativeProbe___merges + 1 and s__X3Buster_created == X3NativeProbe___births + 9 , "native R selects Zero Project without conflicting with E or Rapid Fire")
        call X3NativeProbe___Check(GetUnitCurrentOrder(X3NativeProbe___source) == 0 , "native R leaves visible actor without a spell order")
        call X3NativeProbe___Advance(22)
    elseif X3NativeProbe___stage == 22 and elapsed >= 3.8 then
        call s__RapidPair_destroy(X3NativeProbe___pair)
        set X3NativeProbe___baseHits=s__X3Buster_hits
        set X3NativeProbe___target=CreateUnit(Player(12), 'rftg', X3NativeProbe___sx + 230., X3NativeProbe___sy, 180.)
        set X3NativeProbe___shot=s__X3Buster_fireProfile(X3NativeProbe___source , X3NativeProbe___sx + 1400. , X3NativeProbe___sy , 0 , 1)
        call X3NativeProbe___Advance(23)
    elseif X3NativeProbe___stage == 23 and elapsed >= 0.65 then
        call X3NativeProbe___Check(s__X3Buster_hits == X3NativeProbe___baseHits + 1 and GetWidgetLife(X3NativeProbe___target) < GetUnitState(X3NativeProbe___target, UNIT_STATE_MAX_LIFE) , "native charged pulse sweeps enemy and damages once")
        call X3NativeProbe___Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 , "native charged enemy impact retires pulse")
        call RemoveUnit(X3NativeProbe___target)
        set X3NativeProbe___tree=CreateDestructable('LTlt', X3NativeProbe___sx + 230., X3NativeProbe___sy, 0., 1., 0)
        set X3NativeProbe___baseWalls=s__X3Buster_walls
        set X3NativeProbe___shot=s__X3Buster_fireProfile(X3NativeProbe___source , X3NativeProbe___sx + 1400. , X3NativeProbe___sy , 0 , 2)
        call X3NativeProbe___Advance(24)
    elseif X3NativeProbe___stage == 24 and elapsed >= 0.65 then
        call X3NativeProbe___Check(s__X3Buster_walls == X3NativeProbe___baseWalls + 1 and s__X3Buster_live == 0 , "native charged pulse stops at destructible tree")
        call RemoveDestructable(X3NativeProbe___tree)
        set X3NativeProbe___shot=s__X3Buster_fireProfile(X3NativeProbe___source , X3NativeProbe___sx + 1400. , X3NativeProbe___sy , 2 , 1)
        call s__X3Buster_releasePulse(X3NativeProbe___shot)
        call X3NativeProbe___Advance(25)
    elseif X3NativeProbe___stage == 25 and s__X3Buster_forming[X3NativeProbe___shot] then
        set X3NativeProbe___baseHits=s__X3Buster_hits
        set X3NativeProbe___baseWalls=s__X3Buster_walls
        set X3NativeProbe___unionRecordX=s__X3Buster_lastFusionX
        set X3NativeProbe___target=CreateUnit(Player(12), 'rftg', X3NativeProbe___unionRecordX - 90., X3NativeProbe___sy + 20., 0.)
        set X3NativeProbe___targetBirthLife=GetWidgetLife(X3NativeProbe___target)
        set X3NativeProbe___diagnostics="baselineBehind=" + I2S(s__GroundCollision_trace(X3NativeProbe___unionRecordX , X3NativeProbe___sy , X3NativeProbe___unionRecordX - 120. , X3NativeProbe___sy + 36. , 12.65 , X3NativeProbe___source , Player(0) , false)) + " requested=" + R2S(X3NativeProbe___unionRecordX - 90.) + "," + R2S(X3NativeProbe___sy + 20.) + " actual=" + R2S(GetUnitX(X3NativeProbe___target)) + "," + R2S(GetUnitY(X3NativeProbe___target))
        call X3NativeProbe___Advance(26)
    elseif X3NativeProbe___stage == 26 and elapsed >= 0.5 then
        set X3NativeProbe___diagnostics=X3NativeProbe___diagnostics + " unionY=" + R2S(s__X3Buster_lastFusionY) + " angle=" + R2S(s__X3Buster_angle[X3NativeProbe___shot]) + " maxLife=" + R2S(GetUnitState(X3NativeProbe___target, UNIT_STATE_MAX_LIFE)) + " hits=" + I2S(s__X3Buster_hits - X3NativeProbe___baseHits) + " walls=" + I2S(s__X3Buster_walls - X3NativeProbe___baseWalls) + " life=" + R2S(X3NativeProbe___targetBirthLife) + "->" + R2S(GetWidgetLife(X3NativeProbe___target))
        call s__X3Buster_cancel(X3NativeProbe___shot)
        call RemoveUnit(X3NativeProbe___target)
        call X3NativeProbe___Advance(27)
    elseif X3NativeProbe___stage == 27 and elapsed >= 0.5 then
        call SetUnitX(X3NativeProbe___source, X3NativeProbe___sx + 300.)
        set X3NativeProbe___shot=s__X3Buster_fireProfile(X3NativeProbe___source , X3NativeProbe___sx + 1400. , X3NativeProbe___sy , 2 , 1)
        call s__X3Buster_releasePulse(X3NativeProbe___shot)
        call X3NativeProbe___Advance(28)
    elseif X3NativeProbe___stage == 28 and s__X3Buster_forming[X3NativeProbe___shot] then
        set X3NativeProbe___baseHits=s__X3Buster_hits
        set X3NativeProbe___baseWalls=s__X3Buster_walls
        set X3NativeProbe___unionRecordX=s__X3Buster_lastFusionX
        set X3NativeProbe___unionRecordY=s__X3Buster_lastFusionY
        set X3NativeProbe___unionAngle=s__X3Buster_angle[X3NativeProbe___shot]
        set X3NativeProbe___targetX=X3NativeProbe___unionRecordX - 90. * Cos(X3NativeProbe___unionAngle) - 20. * Sin(X3NativeProbe___unionAngle)
        set X3NativeProbe___targetY=X3NativeProbe___unionRecordY - 90. * Sin(X3NativeProbe___unionAngle) + 20. * Cos(X3NativeProbe___unionAngle)
        set X3NativeProbe___target=CreateUnit(Player(12), 'rftg', X3NativeProbe___targetX, X3NativeProbe___targetY, 0.)
        // CreateUnit may displace a body to avoid another test's actor. Place the
        // target exactly on the real cast axis, then verify its terrain/position.
        call SetUnitX(X3NativeProbe___target, X3NativeProbe___targetX)
        call SetUnitY(X3NativeProbe___target, X3NativeProbe___targetY)
        set X3NativeProbe___targetBirthLife=GetWidgetLife(X3NativeProbe___target)
        call X3NativeProbe___Check(s__GroundCollision_trace(X3NativeProbe___unionRecordX , X3NativeProbe___unionRecordY , X3NativeProbe___unionRecordX - 120. * Cos(X3NativeProbe___unionAngle) - 36. * Sin(X3NativeProbe___unionAngle) , X3NativeProbe___unionRecordY - 120. * Sin(X3NativeProbe___unionAngle) + 36. * Cos(X3NativeProbe___unionAngle) , 12.65 , X3NativeProbe___source , Player(0) , false) == 0 and RAbsBJ(GetUnitX(X3NativeProbe___target) - X3NativeProbe___targetX) < 1. and RAbsBJ(GetUnitY(X3NativeProbe___target) - X3NativeProbe___targetY) < 1. , "native retreat fixture has clear terrain and undisplaced target")
        set X3NativeProbe___diagnostics=X3NativeProbe___diagnostics + " correctTarget=" + R2S(X3NativeProbe___targetX) + "," + R2S(X3NativeProbe___targetY) + " actualUnion=" + R2S(X3NativeProbe___unionRecordX) + "," + R2S(X3NativeProbe___unionRecordY) + " actualAngle=" + R2S(X3NativeProbe___unionAngle)
        call X3NativeProbe___Advance(29)
    elseif X3NativeProbe___stage == 29 and elapsed >= 0.5 then
        call X3NativeProbe___Check(s__X3Buster_hits > X3NativeProbe___baseHits and GetWidgetLife(X3NativeProbe___target) < X3NativeProbe___targetBirthLife , "native retreating satellites sweep enemies behind union point")
        set X3NativeProbe___diagnostics=X3NativeProbe___diagnostics + " relocatedHits=" + I2S(s__X3Buster_hits - X3NativeProbe___baseHits) + " relocatedWalls=" + I2S(s__X3Buster_walls - X3NativeProbe___baseWalls) + " relocatedLife=" + R2S(X3NativeProbe___targetBirthLife) + "->" + R2S(GetWidgetLife(X3NativeProbe___target))
        call s__X3Buster_cancel(X3NativeProbe___shot)
        call RemoveUnit(X3NativeProbe___target)
        call X3NativeProbe___Advance(30)
    elseif X3NativeProbe___stage == 30 and elapsed >= 0.5 then
        call X3NativeProbe___Check(s__X3Buster_live == 0 and s__X3Buster_projectiles == 0 and (s__X3Buster___X3Flash_live) == 0 , "native tests finish with zero casts projectiles and flashes") // INLINED!!
        call X3NativeProbe___Check(s__X3Buster_created - X3NativeProbe___baseCreated == s__X3Buster_retired - X3NativeProbe___baseRetired , "all native created bodies retire exactly once")
        call RemoveUnit(X3NativeProbe___source)
        set X3NativeProbe___source=null
        call X3NativeProbe___Save("COMPLETE")
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 60., "NATIVE COMPLETE " + I2S(X3NativeProbe___checks) + " checks / " + I2S(X3NativeProbe___failures) + " failures; oracle " + I2S(s__X3Oracle_valueFailures) + ". -usa / -zero para ver.")
        call PauseTimer(X3NativeProbe___ticker)
        set X3NativeProbe___stage=- 2
    endif
endfunction
function X3NativeProbe___Begin takes nothing returns nothing
    if X3NativeProbe___stage != - 1 then
        return
    endif
    set X3NativeProbe___baseCreated=s__X3Buster_created
    set X3NativeProbe___baseRetired=s__X3Buster_retired
    call X3NativeProbe___Advance(0)
    call TimerStart(X3NativeProbe___ticker, 1. / 32., true, function X3NativeProbe___Tick)
endfunction
function X3NativeProbe___Repeat takes nothing returns nothing
    local integer s= s__X3Buster_fireProfile(X3NativeProbe___source , X3NativeProbe___sx + 1400. , X3NativeProbe___sy , 1 , X3NativeProbe___visualProfile)
    call SetUnitAnimation(X3NativeProbe___source, "attack")
endfunction
function X3NativeProbe___Show takes nothing returns nothing
    if X3NativeProbe___stage != - 2 then
        return
    endif
    if X3NativeProbe___source == null then
        set X3NativeProbe___source=CreateUnit(Player(0), 'rfex', X3NativeProbe___sx, X3NativeProbe___sy, 0.)
    endif
    set X3NativeProbe___visualProfile=1
    if GetEventPlayerChatString() == "-zero" then
        set X3NativeProbe___visualProfile=2
    endif
    call SetCameraTargetController(null, 0., 0., false)
    call PanCameraToTimed(X3NativeProbe___sx + 400., X3NativeProbe___sy, 0.)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 1000., 0.)
    call FogEnable(false)
    call FogMaskEnable(false)
    call SetTimeOfDay(12.)
    call SuspendTimeOfDay(true)
    call MultiboardDisplay(s__MissileStats_board, false)
    call ClearTextMessages()
    call DisplayTimedTextToPlayer(Player(0), 0., 0., 60., "Perfil " + I2S(X3NativeProbe___visualProfile) + " : 1 USA / 2 Zero Project")
    call TimerStart(X3NativeProbe___showing, 2.5, true, function X3NativeProbe___Repeat)
endfunction
function X3NativeProbe___Init takes nothing returns nothing
    local trigger t= CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t, Player(0), "-native", true)
    call TriggerAddAction(t, function X3NativeProbe___Begin)
    set t=CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t, Player(0), "-usa", true)
    call TriggerRegisterPlayerChatEvent(t, Player(0), "-zero", true)
    call TriggerAddAction(t, function X3NativeProbe___Show)
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



// Local mathematical port of observed X3 USA / Zero Project 4.1 motion.
// Oracle: labs/x3-snes; no ROM code or ROM assets are imported into this map.

// Local Warcraft adaptation of the user-supplied X3 interaction, not SNES code.


// Laboratory only: never imported into the delivered editable sources.

// Engine laboratory, excluded from the delivered map.

// Engine laboratory only. The lane is selected from the real map, not flattened.


// Test-only lifecycle/integration lab; mathematical expectations come from CSV.



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

    call ExecuteFunc("jasshelper__init3454")


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
function sa__X3Buster___X3Body_prepare takes nothing returns boolean
local integer m=f__arg_integer1
        if not s__X3Buster___X3Body_prepared[m] then
            set s__X3Buster___X3Body_prepared[m]=true
            set s__X3Buster___X3Body_age[m]=s__X3Buster___X3Body_age[m] + s__X3Buster_STEP
        endif
   return true
endfunction
function sa__X3Buster___X3Body_ageOf takes nothing returns boolean
local integer m=f__arg_integer1
set f__result_real= s__X3Buster___X3Body_age[m]
   return true
endfunction
function sa__X3Buster___X3Body_centerX takes nothing returns boolean
local integer m=f__arg_integer1
local real fraction=f__arg_real1
        local integer s= s__Missile_data[m]
set f__result_real= s__X3Buster___X3Body_startX[m] + RMinBJ(s__X3Buster___X3Body_length[m], s__X3Buster_trajectory(s,s__X3Buster___X3Body_kind[m] , s__X3Buster___X3Body_age[m] - s__X3Buster_STEP + s__X3Buster_STEP * fraction)) * Cos(s__X3Buster_angle[s])
   return true
endfunction
function sa__X3Buster___X3Body_centerY takes nothing returns boolean
local integer m=f__arg_integer1
local real fraction=f__arg_real1
        local integer s= s__Missile_data[m]
set f__result_real= s__X3Buster___X3Body_startY[m] + RMinBJ(s__X3Buster___X3Body_length[m], s__X3Buster_trajectory(s,s__X3Buster___X3Body_kind[m] , s__X3Buster___X3Body_age[m] - s__X3Buster_STEP + s__X3Buster_STEP * fraction)) * Sin(s__X3Buster_angle[s])
   return true
endfunction
function sa__X3Buster___X3Body_resolveAt takes nothing returns boolean
local integer m=f__arg_integer1
local real fraction=f__arg_real1
        local real untilAge
        local real nextAge
        local integer s= s__Missile_data[m]
        call s__X3Buster___X3Body_prepare(m)
        set untilAge=s__X3Buster___X3Body_age[m] - s__X3Buster_STEP + s__X3Buster_STEP * fraction
        if s__Missile_wantDestroy[m] or s__X3Buster___X3Body_blocked[m] then
set f__result_boolean= true
return true
        endif
        loop
            exitwhen s__X3Buster___X3Body_processed[m] + 0.0000001 >= untilAge
            set nextAge=RMinBJ(untilAge, s__X3Buster___X3Body_processed[m] + s__X3Buster_STEP * 0.25)
            if s__X3Buster_profile[s] != s__X3Buster_GIF then
                set nextAge=RMinBJ(nextAge, I2R(R2I(s__X3Buster___X3Body_processed[m] * s__X3Kinematics_FPS + 0.00001) + 1) / s__X3Kinematics_FPS)
            endif
            if s__X3Buster___X3Body_sample(m , nextAge) then
set f__result_boolean= true
return true
            endif
            set s__X3Buster___X3Body_processed[m]=nextAge
        endloop
set f__result_boolean= false
   return true
endfunction
function sa__X3Buster___X3Body_spawn takes nothing returns boolean
local integer s=f__arg_integer1
local integer form=f__arg_integer2
local real x=f__arg_real1
local real y=f__arg_real2
local real facing=f__arg_real3
local real range=f__arg_real4
        local integer m= s__Missile_createXYZ(x , y , 70. , x + range * Cos(facing) , y + range * Sin(facing) , 70.)
        set s__Missile_data[m]=s
        set s__Missile_owner[m]=s__X3Buster_owner[s]
        set s__Missile_collision[m]=0.
        set s__X3Buster___X3Body_kind[m]=form
        set s__X3Buster___X3Body_processed[m]=0.
        set s__X3Buster___X3Body_age[m]=0.
        set s__X3Buster___X3Body_prepared[m]=false
        set s__X3Buster___X3Body_startX[m]=x
        set s__X3Buster___X3Body_startY[m]=y
        set s__X3Buster___X3Body_length[m]=s__MissilePosition_distance[s__Missile_origin[m]]
        set s__X3Buster___X3Body_blocked[m]=false
        set s__X3Buster___X3Body_lastX[m]=x
        set s__X3Buster___X3Body_lastY[m]=y
        if form == 1 or form == 2 or form >= 5 then
            if form == 1 or form == 5 or form == 8 or form == 9 then
                call s__Missile__set_model(m,"X3Buster\\X3_Orbe_Verde.mdx")
            else
                call s__Missile__set_model(m,"X3Buster\\X3_Orbe_Naranja.mdx")
            endif
            call s__Missile__set_scale(m,0.55)
        elseif form == 4 then
            call s__Missile__set_model(m,"X3Buster\\X3_Cross_Buster.mdx")
            call s__Missile__set_scale(m,1.)
        else
            call s__Missile__set_model(m,"X3Buster\\X3_Buster_Cargado.mdx")
            call s__Missile__set_scale(m,1.)
        endif
        set s__Missile_speed[m]=s__X3Buster_trajectory(s,form , s__X3Buster_STEP)
        if s__X3Buster_profile[s] != s__X3Buster_GIF then
            set s__X3Buster___X3Body_processed[m]=0.
            if form == 1 or form == 2 or form == 9 then
                set s__X3Buster___X3Body_processed[m]=s__X3Kinematics_side(s__X3Buster_profile[s] , form , 0.)
                set s__X3Buster___X3Body_lastX[m]=x + s__X3Kinematics_orbitForward(form , 0.) * Cos(facing) - Sin(facing) * s__X3Buster___X3Body_processed[m]
                set s__X3Buster___X3Body_lastY[m]=y + s__X3Kinematics_orbitForward(form , 0.) * Sin(facing) + Cos(facing) * s__X3Buster___X3Body_processed[m]
            endif
            if s__GroundCollision_trace(x , y , s__X3Buster___X3Body_lastX[m] , s__X3Buster___X3Body_lastY[m] , 12.65 , s__X3Buster_caster[s] , s__X3Buster_owner[s] , false) != 0 then
                set s__X3Buster___X3Body_blocked[m]=true
                call s__X3Buster_countHit(s,1)
                set s__Missile_wantDestroy[(m)]=true // INLINED!!
            endif
            call SetUnitX(s__Missile_dummy[m], s__GroundCollision_x)
            call SetUnitY(s__Missile_dummy[m], s__GroundCollision_y)
        elseif form == 1 or form == 2 then
            if form == 1 then
                set s__X3Buster___X3Body_processed[m]=s__X3Buster_ORBIT_RADIUS
            else
                set s__X3Buster___X3Body_processed[m]=- s__X3Buster_ORBIT_RADIUS
            endif
        elseif form >= 5 then
            set s__X3Buster___X3Body_processed[m]=s__X3Buster_lateral(form , 0.)
        endif
        if s__X3Buster_profile[s] == s__X3Buster_GIF and ( form == 1 or form == 2 or form >= 5 ) then
            set s__X3Buster___X3Body_lastX[m]=x - Sin(facing) * s__X3Buster___X3Body_processed[m]
            set s__X3Buster___X3Body_lastY[m]=y + Cos(facing) * s__X3Buster___X3Body_processed[m]
            if s__GroundCollision_trace(x , y , s__X3Buster___X3Body_lastX[m] , s__X3Buster___X3Body_lastY[m] , 12.65 , s__X3Buster_caster[s] , s__X3Buster_owner[s] , false) != 0 then
                set s__X3Buster___X3Body_blocked[m]=true
                call s__X3Buster_countHit(s,1)
                set s__Missile_wantDestroy[(m)]=true // INLINED!!
            endif
            call SetUnitX(s__Missile_dummy[m], s__GroundCollision_x)
            call SetUnitY(s__Missile_dummy[m], s__GroundCollision_y)
        endif
        set s__X3Buster___X3Body_processed[m]=0.
        call s__X3Buster_track(s,m)
        call s__X3Buster___X3Body_launch(m)
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

function jasshelper__init3454 takes nothing returns nothing
    set st__X3Buster___X3Body_prepare=CreateTrigger()
    call TriggerAddCondition(st__X3Buster___X3Body_prepare,Condition( function sa__X3Buster___X3Body_prepare))
    set st__X3Buster___X3Body_ageOf=CreateTrigger()
    call TriggerAddCondition(st__X3Buster___X3Body_ageOf,Condition( function sa__X3Buster___X3Body_ageOf))
    set st__X3Buster___X3Body_centerX=CreateTrigger()
    call TriggerAddCondition(st__X3Buster___X3Body_centerX,Condition( function sa__X3Buster___X3Body_centerX))
    set st__X3Buster___X3Body_centerY=CreateTrigger()
    call TriggerAddCondition(st__X3Buster___X3Body_centerY,Condition( function sa__X3Buster___X3Body_centerY))
    set st__X3Buster___X3Body_resolveAt=CreateTrigger()
    call TriggerAddCondition(st__X3Buster___X3Body_resolveAt,Condition( function sa__X3Buster___X3Body_resolveAt))
    set st__X3Buster___X3Body_spawn=CreateTrigger()
    call TriggerAddCondition(st__X3Buster___X3Body_spawn,Condition( function sa__X3Buster___X3Body_spawn))
    set st___prototype2[1]=CreateTrigger()
    call TriggerAddAction(st___prototype2[1],function sa___prototype2_TimerUtils___init)
    call TriggerAddCondition(st___prototype2[1],Condition(function sa___prototype2_TimerUtils___init))


call ExecuteFunc("s__DummyCaster_DummyCaster__N___onInit")
//------------------------------------
call ExecuteFunc("s__IsDestructableTree___I_IsDestructableTree___Inits__onInit")
//------------------------------------
call ExecuteFunc("TimerUtils___init")
//------------------------------------
call ExecuteFunc("s__WorldBounds_WorldBounds___WorldBoundInit__onInit")
//------------------------------------
call ExecuteFunc("s__X3Kinematics_onInit")
//------------------------------------
call ExecuteFunc("GroundCollision__Init")
//------------------------------------
call ExecuteFunc("MissileDiagnostics___Init")
//------------------------------------
call ExecuteFunc("s__SpellEffectEvent__S_SpellEffectEvent__M___onInit")
//------------------------------------
call ExecuteFunc("MissileRecycler__PreInit")
//------------------------------------
call ExecuteFunc("s__Missile_onInit")
//------------------------------------
call ExecuteFunc("s__RapidBolt_MissileStruct__onInit")
call ExecuteFunc("RapidFire__Init")
//------------------------------------
call ExecuteFunc("s__X3Buster_onInit")
call ExecuteFunc("s__X3Buster___X3Body_MissileStruct__onInit")
//------------------------------------
call ExecuteFunc("RapidFireDemo___Init")
//------------------------------------
call ExecuteFunc("RapidFireProbe__Init")
//------------------------------------
call ExecuteFunc("ShotColorProbe___Init")
//------------------------------------
call ExecuteFunc("X3BusterDemo__Init")
//------------------------------------
call ExecuteFunc("X3Probe___Init")
//------------------------------------
call ExecuteFunc("X3NativeProbe___Init")
//------------------------------------

endfunction

