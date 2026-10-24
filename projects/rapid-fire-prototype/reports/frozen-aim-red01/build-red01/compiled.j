globals
//globals from RFBurstLog:
constant boolean LIBRARY_RFBurstLog=true
constant string RB_RUN_ID= "rf-burst-aim-red-20261020-01"
string array RFBurstLog__rows
integer RFBurstLog__count= 0
integer RFBurstLog__cases= 0
integer RFBurstLog__checks= 0
integer RFBurstLog__failures= 0
string RFBurstLog__current= ""
trigger RFBurstLog__writer= null
//endglobals from RFBurstLog
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
//globals from DummyRecycler:
constant boolean LIBRARY_DummyRecycler=true
        //The rawcode of the Dummy Unit
constant integer DummyRecycler__DUMMY_ID= 'e000'
     
        //The owner of the Dummy Unit
constant player DummyRecycler__OWNER= Player(PLAYER_NEUTRAL_PASSIVE)
     
        //The number of indexed angle. The higher the value the:
        // - Lesser the turning time for the Dummy Units.
        // - Higher the total number of Dummy Units created at Map Initialization.
        //          Recommended Value: 10 (Max difference of 18 degrees)
constant integer DummyRecycler__ANGLES_COUNT= 10
     
        //The number of Dummy units per ANGLES_COUNT. The higher the value the:
        // - Higher the number of units that can be recycled per angle, when
        //   no more units are in queue, the system will resort to use CreateUnit.
        // - Higher the total number of Dummy Units created at Map Initialization.
        //    Recommended Value: 3 to 5 (for less overhead in Map Loading Screen)
constant integer DummyRecycler__STORED_UNIT_COUNT= 3
     
        //The maximum number of Dummy units that can exist. When the system resort
        //to using CreateUnit, the unit will be permanently added to the Dummy
        //List. To avoid spamming Dummy Units and having too much free Dummy
        //Units to allocate, the maximum number of Dummy Units is capped.
        //               Recommended Value: 80 to 120
constant integer DummyRecycler__MAX_DUMMY_COUNT= 100
     
        //When a certain angle have less than BORROW_REQUEST units in its list,
        //it will start to borrow Dummy Units from the list with the highest
        //Dummy Unit count.
        //      Recommended Value: Half of maximum STORED_UNIT_COUNT
constant integer DummyRecycler__BORROW_REQUEST= 5
     
        //It will only return a Dummy if the current dummy is close
        //to it's appropriate facing angle. This is to avoid returning
        //a Dummy which is still turning to face it's list angle.
constant real DummyRecycler__ANGLE_TOLERANCE= 10.0
     
        //An additional option to automatically hide recycled dummy units in the
        //corner of the map camera bounds
constant boolean DummyRecycler__HIDE_ON_MAP_CORNER= true
integer DummyRecycler__dummyCount= DummyRecycler__ANGLES_COUNT * DummyRecycler__STORED_UNIT_COUNT
real array DummyRecycler__angle
integer array DummyRecycler__count
integer array DummyRecycler__countHead
integer array DummyRecycler__countNext
integer array DummyRecycler__countPrev
integer array DummyRecycler__next
integer array DummyRecycler__prev
unit array DummyRecycler__dummy
integer DummyRecycler__upper
integer DummyRecycler__lower
integer DummyRecycler__lastInstance
constant real DummyRecycler__FACING_OFFSET= 180.0 / DummyRecycler__ANGLES_COUNT
//endglobals from DummyRecycler
//globals from Missiles:
constant boolean LIBRARY_Missiles=true
        // The update period of the system
constant real Missiles_PERIOD= 1. / 40.
        // The max amount of Missiles processed in a PERIOD
        // You can play around with both these values to find
        // your sweet spot. If equal to 0, the system will
        // process all missiles at once every period.
constant real Missiles_SWEET_SPOT= 150
        // Candidate padding for unit sizes and measured Classic widget-enumeration
        // omissions. Visitors retain the original logical collision geometry.
constant real Missiles___COLLISION_SIZE= 128.
        // item size used in z collision
constant real Missiles___ITEM_SIZE= 16.
        // The raw code of the dummy unit.
constant integer Missiles___DUMMY= 'e000'
        // How long takes for the missile to be removed.
        // This is necessary so the death animation of the
        // effect can play through
constant real Missiles___RECYCLE_TIME= 2.
        // Needed, don't touch.
location Missiles___LOC= Location(0., 0.)
hashtable Missiles___table= InitHashtable()
//endglobals from Missiles
//globals from RFBurstPair:
constant boolean LIBRARY_RFBurstPair=true
constant real RFBurstPair___CADENCE= .25
constant real RFBurstPair___RANGE= 1500.
constant real RFBurstPair___SPEED= 1200.
constant real RFBurstPair___HIT_RADIUS= 32.
constant real RFBurstPair___LAUNCH_HEIGHT= 80.
unit RFBurstPair___actor= null
unit RFBurstPair___controller= null
player RFBurstPair___pairOwner= null
trigger RFBurstPair___castHook= null
trigger RFBurstPair___observer= null
timer RFBurstPair___fireTimer= null
location RFBurstPair___terrain= null
integer RFBurstPair___epoch= 0
integer RFBurstPair___remaining= 0
boolean RFBurstPair___notifying= false
real RFBurstPair___heading= 0.
integer RFBurstPair___shot= 0
unit RFBurstPair___shotSource= null
real RFBurstPair___shotX= 0.
real RFBurstPair___shotY= 0.
//endglobals from RFBurstPair
//globals from RFBurstAimTest:
constant boolean LIBRARY_RFBurstAimTest=true
constant real RFBurstAimTest__PERIOD= .03125
constant real RFBurstAimTest__CADENCE_TOLERANCE= .03125
constant real RFBurstAimTest__HP_TOLERANCE= .10
unit RFBurstAimTest__actor= null
unit RFBurstAimTest__caster= null
unit RFBurstAimTest__target= null
unit RFBurstAimTest__control= null
timer RFBurstAimTest__clock= null
timer RFBurstAimTest__runner= null
trigger RFBurstAimTest__damageHook= null
trigger RFBurstAimTest__spellHook= null
trigger RFBurstAimTest__shotHook= null
integer RFBurstAimTest__phase= 0
boolean RFBurstAimTest__done= false
boolean RFBurstAimTest__calibrated= false
integer RFBurstAimTest__calibrationHits= 0
real RFBurstAimTest__calibrationHP= 0.
real RFBurstAimTest__calibrationDamage= 0.
boolean RFBurstAimTest__calibrationSource= false
integer RFBurstAimTest__controlHits= 0
integer RFBurstAimTest__hits= 0
boolean RFBurstAimTest__hitValuesOK= true
boolean RFBurstAimTest__hitSourcesOK= true
integer RFBurstAimTest__shots= 0
boolean RFBurstAimTest__projectilesOK= true
real array RFBurstAimTest__shotTime
integer RFBurstAimTest__castEvents= 0
real RFBurstAimTest__orderTime= 0.
real RFBurstAimTest__castTime= 0.
real RFBurstAimTest__aimX= 0.
real RFBurstAimTest__aimY= 0.
real RFBurstAimTest__targetStart= 0.
real RFBurstAimTest__controlStart= 0.
boolean RFBurstAimTest__recastCase= false
integer RFBurstAimTest__expectedCast= 0
boolean RFBurstAimTest__pendingRecast= false
boolean RFBurstAimTest__recastRequested= false
boolean RFBurstAimTest__recastQualified= false
boolean RFBurstAimTest__earlyPulse= false
real RFBurstAimTest__recastDue= 0.
real RFBurstAimTest__recastIssue= 0.
real RFBurstAimTest__recastEffect= 0.
integer RFBurstAimTest__recastEffectShots= 0
boolean RFBurstAimTest__aimCase= false
unit RFBurstAimTest__northTarget= null
unit RFBurstAimTest__northControl= null
location RFBurstAimTest__groundProbe= null
group RFBurstAimTest__corridorUnits= null
rect RFBurstAimTest__corridorRect= null
boolean RFBurstAimTest__corridorClear= true
integer RFBurstAimTest__destSeen= 0
real RFBurstAimTest__northStart= 0.
real RFBurstAimTest__northControlStart= 0.
integer RFBurstAimTest__eastHits= 0
integer RFBurstAimTest__northHits= 0
integer RFBurstAimTest__northCalibrationHits= 0
real RFBurstAimTest__northCalibrationHP= 0.
real RFBurstAimTest__northCalibrationDamage= 0.
boolean RFBurstAimTest__northCalibrationSource= false
boolean RFBurstAimTest__northCalibrationAccepted= false
integer RFBurstAimTest__firstFlight= 0
unit RFBurstAimTest__firstDummy= null
unit RFBurstAimTest__firstSource= null
real RFBurstAimTest__firstOriginX= 0.
real RFBurstAimTest__firstOriginY= 0.
real RFBurstAimTest__firstInitialX= 0.
real RFBurstAimTest__firstInitialY= 0.
real RFBurstAimTest__eastDX= 0.
real RFBurstAimTest__eastDY= 0.
boolean RFBurstAimTest__postSample= false
real RFBurstAimTest__sampleTime= 0.
real RFBurstAimTest__sampleAdvance= 0.
real RFBurstAimTest__sampleCross= 0.
boolean RFBurstAimTest__firstEastBeforeSecond= false
real RFBurstAimTest__firstEastTime= 0.
integer RFBurstAimTest__firstEastShots= 0
boolean RFBurstAimTest__northBeforeSecond= false
//endglobals from RFBurstAimTest


//JASSHelper struct globals:
constant integer si__WorldBounds=1
integer s__WorldBounds_maxX
integer s__WorldBounds_maxY
integer s__WorldBounds_minX
integer s__WorldBounds_minY
integer s__WorldBounds_centerX
integer s__WorldBounds_centerY
rect s__WorldBounds_world
region s__WorldBounds_worldRegion
real s__WorldBounds_playMaxX
real s__WorldBounds_playMaxY
real s__WorldBounds_playMinX
real s__WorldBounds_playMinY
constant integer si__DummyRecycler__S=2
hashtable s__DummyRecycler__S_hash= InitHashtable()
constant integer si__Missiles___MissileEvents=3
integer si__Missiles___MissileEvents_F=0
integer si__Missiles___MissileEvents_I=0
integer array si__Missiles___MissileEvents_V
integer array si__Missiles___MissileEvents_type
trigger array st__Missiles___MissileEvents_onDestroy
trigger array st__Missiles___MissileEvents_onHit
trigger array st__Missiles___MissileEvents_onMissile
trigger array st__Missiles___MissileEvents_onDestructable
trigger array st__Missiles___MissileEvents_onItem
trigger array st__Missiles___MissileEvents_onCliff
trigger array st__Missiles___MissileEvents_onTerrain
trigger array st__Missiles___MissileEvents_onTileset
trigger array st__Missiles___MissileEvents_onPeriod
trigger array st__Missiles___MissileEvents_onFinish
trigger array st__Missiles___MissileEvents_onBoundaries
trigger array st__Missiles___MissileEvents_onPause
trigger array st__Missiles___MissileEvents_onResume
trigger array st__Missiles___MissileEvents_onRemove
constant integer si__Missiles___Pool=4
integer si__Missiles___Pool_F=0
integer si__Missiles___Pool_I=0
integer array si__Missiles___Pool_V
player s__Missiles___Pool_player= Player(PLAYER_NEUTRAL_PASSIVE)
timer array s__Missiles___Pool_timer
unit array s__Missiles___Pool_unit
constant integer si__Missiles___Coordinates=5
integer si__Missiles___Coordinates_F=0
integer si__Missiles___Coordinates_I=0
integer array si__Missiles___Coordinates_V
real array s__Missiles___Coordinates_x
real array s__Missiles___Coordinates_y
real array s__Missiles___Coordinates_z
real array s__Missiles___Coordinates_angle
real array s__Missiles___Coordinates_distance
real array s__Missiles___Coordinates_square
real array s__Missiles___Coordinates_slope
real array s__Missiles___Coordinates_alpha
integer array s__Missiles___Coordinates_ref
constant integer si__Missiles=6
timer s__Missiles_timer= CreateTimer()
group s__Missiles_group= CreateGroup()
rect s__Missiles_rect= Rect(0., 0., 0., 0.)
hashtable s__Missiles_Missiles___table= InitHashtable()
hashtable s__Missiles_missileHits= InitHashtable()
integer s__Missiles_last= 0
integer s__Missiles_temp= 0
integer s__Missiles_id= - 1
integer s__Missiles_pid= - 1
real s__Missiles_dilation= 1
integer array s__Missiles_missiles
integer array s__Missiles_frozen
integer array s__Missiles_collection
integer s__Missiles_count= - 1
real array s__Missiles_cA
effect array s__Missiles_effect
string array s__Missiles_path
real array s__Missiles_size
real array s__Missiles_height
real array s__Missiles_open
real array s__Missiles_toZ
real array s__Missiles_time
real array s__Missiles_sight
integer array s__Missiles_pkey
integer array s__Missiles_index
boolean array s__Missiles_active
integer array s__Missiles_pins
integer array s__Missiles_generation
real array s__Missiles_progress
real array s__Missiles_nextProgress
real array s__Missiles_baseX
real array s__Missiles_baseY
real array s__Missiles_nextBaseX
real array s__Missiles_nextBaseY
fogmodifier array s__Missiles_visionFog
player array s__Missiles_visionOwner
real array s__Missiles_visionRadius
real array s__Missiles_visionX
real array s__Missiles_visionY
integer array s__Missiles_impact
integer array s__Missiles_origin
real array s__Missiles_x
real array s__Missiles_y
real array s__Missiles_z
real array s__Missiles_prevX
real array s__Missiles_prevY
real array s__Missiles_prevZ
real array s__Missiles_nextX
real array s__Missiles_nextY
real array s__Missiles_nextZ
real array s__Missiles_turn
real array s__Missiles_veloc
real array s__Missiles_travel
unit array s__Missiles_dummy
boolean array s__Missiles_launched
boolean array s__Missiles_allocated
boolean array s__Missiles_finished
boolean array s__Missiles_paused
integer array s__Missiles_tileset
unit array s__Missiles_source
unit array s__Missiles_target
player array s__Missiles_owner
boolean array s__Missiles_collideZ
real array s__Missiles_collision
real array s__Missiles_damage
real array s__Missiles_acceleration
integer array s__Missiles_data
integer array s__Missiles_type
constant integer si__RFBurstPair___RBProjectile=7
unit array s__RFBurstPair___RBProjectile_savedActor
unit array s__RFBurstPair___RBProjectile_savedController
player array s__RFBurstPair___RBProjectile_savedOwner
boolean array s__RFBurstPair___RBProjectile_spent
integer array s__TimerUtils__data
timer array s__TimerUtils__tT
trigger st__Missiles_terminate
trigger st__Missiles_reset
trigger st__Missiles_release
trigger st__Missiles_move
trigger st__Missiles_create
trigger array st___prototype3
unit f__arg_unit1
integer f__arg_integer1
destructable f__arg_destructable1
item f__arg_item1
real f__arg_real1
real f__arg_real2
real f__arg_real3
real f__arg_real4
real f__arg_real5
real f__arg_real6
integer f__arg_this
boolean f__result_boolean
integer f__result_integer

endglobals


//Generated method caller for Missiles___MissileEvents.onHit
function sc__Missiles___MissileEvents_onHit takes integer this,unit hit returns boolean
    set f__arg_this=this
    set f__arg_unit1=hit
    //An error in the next line would mean declaration for Missiles___MissileEvents.onHit had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles___MissileEvents_onHit[si__Missiles___MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles___MissileEvents.onHit
function sx__Missiles___MissileEvents_onHit takes integer this,unit hit returns nothing
    set f__arg_this=this
    set f__arg_unit1=hit
    call TriggerExecute(st__Missiles___MissileEvents_onHit[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles___MissileEvents.onMissile
function sc__Missiles___MissileEvents_onMissile takes integer this,integer missile returns boolean
    set f__arg_this=this
    set f__arg_integer1=missile
    //An error in the next line would mean declaration for Missiles___MissileEvents.onMissile had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles___MissileEvents_onMissile[si__Missiles___MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles___MissileEvents.onMissile
function sx__Missiles___MissileEvents_onMissile takes integer this,integer missile returns nothing
    set f__arg_this=this
    set f__arg_integer1=missile
    call TriggerExecute(st__Missiles___MissileEvents_onMissile[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles___MissileEvents.onDestructable
function sc__Missiles___MissileEvents_onDestructable takes integer this,destructable dest returns boolean
    set f__arg_this=this
    set f__arg_destructable1=dest
    //An error in the next line would mean declaration for Missiles___MissileEvents.onDestructable had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles___MissileEvents_onDestructable[si__Missiles___MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles___MissileEvents.onDestructable
function sx__Missiles___MissileEvents_onDestructable takes integer this,destructable dest returns nothing
    set f__arg_this=this
    set f__arg_destructable1=dest
    call TriggerExecute(st__Missiles___MissileEvents_onDestructable[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles___MissileEvents.onItem
function sc__Missiles___MissileEvents_onItem takes integer this,item i returns boolean
    set f__arg_this=this
    set f__arg_item1=i
    //An error in the next line would mean declaration for Missiles___MissileEvents.onItem had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles___MissileEvents_onItem[si__Missiles___MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles___MissileEvents.onItem
function sx__Missiles___MissileEvents_onItem takes integer this,item i returns nothing
    set f__arg_this=this
    set f__arg_item1=i
    call TriggerExecute(st__Missiles___MissileEvents_onItem[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles___MissileEvents.onCliff
function sc__Missiles___MissileEvents_onCliff takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles___MissileEvents.onCliff had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles___MissileEvents_onCliff[si__Missiles___MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles___MissileEvents.onCliff
function sx__Missiles___MissileEvents_onCliff takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles___MissileEvents_onCliff[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles___MissileEvents.onTerrain
function sc__Missiles___MissileEvents_onTerrain takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles___MissileEvents.onTerrain had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles___MissileEvents_onTerrain[si__Missiles___MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles___MissileEvents.onTerrain
function sx__Missiles___MissileEvents_onTerrain takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles___MissileEvents_onTerrain[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles___MissileEvents.onTileset
function sc__Missiles___MissileEvents_onTileset takes integer this,integer tileset returns boolean
    set f__arg_this=this
    set f__arg_integer1=tileset
    //An error in the next line would mean declaration for Missiles___MissileEvents.onTileset had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles___MissileEvents_onTileset[si__Missiles___MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles___MissileEvents.onTileset
function sx__Missiles___MissileEvents_onTileset takes integer this,integer tileset returns nothing
    set f__arg_this=this
    set f__arg_integer1=tileset
    call TriggerExecute(st__Missiles___MissileEvents_onTileset[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles___MissileEvents.onPeriod
function sc__Missiles___MissileEvents_onPeriod takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles___MissileEvents.onPeriod had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles___MissileEvents_onPeriod[si__Missiles___MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles___MissileEvents.onPeriod
function sx__Missiles___MissileEvents_onPeriod takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles___MissileEvents_onPeriod[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles___MissileEvents.onFinish
function sc__Missiles___MissileEvents_onFinish takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles___MissileEvents.onFinish had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles___MissileEvents_onFinish[si__Missiles___MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles___MissileEvents.onFinish
function sx__Missiles___MissileEvents_onFinish takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles___MissileEvents_onFinish[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles___MissileEvents.onBoundaries
function sc__Missiles___MissileEvents_onBoundaries takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles___MissileEvents.onBoundaries had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles___MissileEvents_onBoundaries[si__Missiles___MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles___MissileEvents.onBoundaries
function sx__Missiles___MissileEvents_onBoundaries takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles___MissileEvents_onBoundaries[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles___MissileEvents.onPause
function sc__Missiles___MissileEvents_onPause takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles___MissileEvents.onPause had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles___MissileEvents_onPause[si__Missiles___MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles___MissileEvents.onPause
function sx__Missiles___MissileEvents_onPause takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles___MissileEvents_onPause[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles___MissileEvents.onResume
function sc__Missiles___MissileEvents_onResume takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles___MissileEvents.onResume had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles___MissileEvents_onResume[si__Missiles___MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles___MissileEvents.onResume
function sx__Missiles___MissileEvents_onResume takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles___MissileEvents_onResume[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles___MissileEvents.onRemove
function sc__Missiles___MissileEvents_onRemove takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__Missiles___MissileEvents_onRemove[si__Missiles___MissileEvents_type[this]])
endfunction

//Generated method executor for Missiles___MissileEvents.onRemove
function sx__Missiles___MissileEvents_onRemove takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles___MissileEvents_onRemove[si__Missiles___MissileEvents_type[this]])
endfunction
//Generated destructor of Missiles___MissileEvents
function sc__Missiles___MissileEvents_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Missiles___MissileEvents_V[this]!=-1) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__Missiles___MissileEvents_onDestroy[si__Missiles___MissileEvents_type[this]])
    set si__Missiles___MissileEvents_V[this]=si__Missiles___MissileEvents_F
    set si__Missiles___MissileEvents_F=this
endfunction

//Generated allocator of Missiles___Coordinates
function s__Missiles___Coordinates__allocate takes nothing returns integer
 local integer this=si__Missiles___Coordinates_F
    if (this!=0) then
        set si__Missiles___Coordinates_F=si__Missiles___Coordinates_V[this]
    else
        set si__Missiles___Coordinates_I=si__Missiles___Coordinates_I+1
        set this=si__Missiles___Coordinates_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Missiles___Coordinates_V[this]=-1
 return this
endfunction

//Generated destructor of Missiles___Coordinates
function s__Missiles___Coordinates_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Missiles___Coordinates_V[this]!=-1) then
        return
    endif
    set si__Missiles___Coordinates_V[this]=si__Missiles___Coordinates_F
    set si__Missiles___Coordinates_F=this
endfunction

//Generated allocator of Missiles___Pool
function s__Missiles___Pool__allocate takes nothing returns integer
 local integer this=si__Missiles___Pool_F
    if (this!=0) then
        set si__Missiles___Pool_F=si__Missiles___Pool_V[this]
    else
        set si__Missiles___Pool_I=si__Missiles___Pool_I+1
        set this=si__Missiles___Pool_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Missiles___Pool_V[this]=-1
 return this
endfunction

//Generated destructor of Missiles___Pool
function s__Missiles___Pool_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Missiles___Pool_V[this]!=-1) then
        return
    endif
    set si__Missiles___Pool_V[this]=si__Missiles___Pool_F
    set si__Missiles___Pool_F=this
endfunction

//Generated method caller for Missiles.terminate
function sc__Missiles_terminate takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__Missiles_terminate)
endfunction

//Generated method caller for Missiles.reset
function sc__Missiles_reset takes integer this returns nothing
            set s__Missiles_launched[this]=false
            set s__Missiles_finished[this]=false
            set s__Missiles_collideZ[this]=false
            set s__Missiles_paused[this]=false
            set s__Missiles_source[this]=null
            set s__Missiles_target[this]=null
            set s__Missiles_owner[this]=null
            set s__Missiles_effect[this]=null
            set s__Missiles_dummy[this]=null
            set s__Missiles_path[this]=""
            set s__Missiles_open[this]=0.
            set s__Missiles_height[this]=0.
            set s__Missiles_veloc[this]=0.
            set s__Missiles_acceleration[this]=0.
            set s__Missiles_collision[this]=0.
            set s__Missiles_damage[this]=0.
            set s__Missiles_travel[this]=0.
            set s__Missiles_turn[this]=0.
            set s__Missiles_size[this]=0.
            set s__Missiles_time[this]=0.
            set s__Missiles_sight[this]=0.
            set s__Missiles_progress[this]=0.
            set s__Missiles_nextProgress[this]=0.
            set s__Missiles_visionFog[this]=null
            set s__Missiles_visionOwner[this]=null
            set s__Missiles_visionRadius[this]=0.
            set s__Missiles_data[this]=0
            set s__Missiles_type[this]=0
            set s__Missiles_tileset[this]=0
            set s__Missiles_pkey[this]=- 1
            set s__Missiles_index[this]=- 1
endfunction

//Generated method caller for Missiles.release
function sc__Missiles_release takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__Missiles_release)
endfunction

//Generated method caller for Missiles.move
function sc__Missiles_move takes nothing returns nothing
    call TriggerEvaluate(st__Missiles_move)
endfunction

//Generated method caller for Missiles.create
function sc__Missiles_create takes real x,real y,real z,real toX,real toY,real toZ returns integer
    set f__arg_real1=x
    set f__arg_real2=y
    set f__arg_real3=z
    set f__arg_real4=toX
    set f__arg_real5=toY
    set f__arg_real6=toZ
    call TriggerEvaluate(st__Missiles_create)
 return f__result_integer
endfunction

//Generated allocator of Missiles
function s__Missiles__allocate takes nothing returns integer
 local integer kthis
 local integer this=si__Missiles___MissileEvents_F
    if (this!=0) then
        set si__Missiles___MissileEvents_F=si__Missiles___MissileEvents_V[this]
    else
        set si__Missiles___MissileEvents_I=si__Missiles___MissileEvents_I+1
        set this=si__Missiles___MissileEvents_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Missiles___MissileEvents_type[this]=6
    set kthis=this

    set si__Missiles___MissileEvents_V[this]=-1
 return this
endfunction


//Generated method caller for RFBurstPair___RBProjectile.onHit
function sc__RFBurstPair___RBProjectile_onHit takes integer this,unit hit returns boolean
    set f__arg_this=this
    set f__arg_unit1=hit
    call TriggerEvaluate(st__Missiles___MissileEvents_onHit[7])
 return f__result_boolean
endfunction

//Generated method caller for RFBurstPair___RBProjectile.onPeriod
function sc__RFBurstPair___RBProjectile_onPeriod takes integer this returns boolean
    set f__arg_this=this
    call TriggerEvaluate(st__Missiles___MissileEvents_onPeriod[7])
 return f__result_boolean
endfunction

//Generated method caller for RFBurstPair___RBProjectile.onRemove
function sc__RFBurstPair___RBProjectile_onRemove takes integer this returns nothing
            // Core owns allocator/dummy/effect/coordinates and their cleanup.
            set s__RFBurstPair___RBProjectile_savedActor[this]=null
            set s__RFBurstPair___RBProjectile_savedController[this]=null
            set s__RFBurstPair___RBProjectile_savedOwner[this]=null
            set s__RFBurstPair___RBProjectile_spent[this]=true
endfunction

//Generated allocator of RFBurstPair___RBProjectile
function s__RFBurstPair___RBProjectile__allocate takes real x ,real y ,real z ,real toX ,real toY ,real toZ returns integer
 local integer this=sc__Missiles_create(x,y,z,toX,toY,toZ)
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__Missiles___MissileEvents_type[this]=7
    set kthis=this

 return this
endfunction

function sc___prototype3_execute takes integer i returns nothing

    call TriggerExecute(st___prototype3[i])
endfunction
function sc___prototype3_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype3[i])

endfunction

    // Adapted from the frozen prerequisite Preload snapshot logger, not imported.

    function RFBurstLog__Snapshot takes nothing returns boolean
        local integer i= 0
        call PreloadGenClear()
        call PreloadGenStart()
        loop
            exitwhen i >= RFBurstLog__count
            call Preload(RFBurstLog__rows[i])
            set i=i + 1
        endloop
        call PreloadGenEnd("Logs\\RF-rf-burst-aim-red-20261020-01.txt")
        return true
    endfunction

    function RFBurstLog__Log takes string text returns nothing
        set RFBurstLog__rows[RFBurstLog__count]="RM28|" + RB_RUN_ID + "|" + text
        set RFBurstLog__count=RFBurstLog__count + 1
        call TriggerEvaluate(RFBurstLog__writer)
    endfunction

    function RB_LogBegin takes nothing returns nothing
        set RFBurstLog__writer=CreateTrigger()
        call TriggerAddCondition(RFBurstLog__writer, Condition(function RFBurstLog__Snapshot))
        call RFBurstLog__Log("BEGIN|RFBurstAim")
    endfunction

    function RB_LogCase takes string id returns nothing
        set RFBurstLog__current=id
        set RFBurstLog__cases=RFBurstLog__cases + 1
        call RFBurstLog__Log("CASE|" + id)
    endfunction

    function RB_LogRecord takes string status,string name,string detail returns nothing
        set RFBurstLog__checks=RFBurstLog__checks + 1
        if status == "FAIL" then
            set RFBurstLog__failures=RFBurstLog__failures + 1
        endif
        call RFBurstLog__Log("CHECK|" + RFBurstLog__current + "|" + status + "|" + name + "|" + detail)
    endfunction

    function RB_LogCheck takes boolean ok,string name,string detail returns nothing
        if ok then
            call RB_LogRecord("PASS" , name , detail)
        else
            call RB_LogRecord("FAIL" , name , detail)
        endif
    endfunction

    function RB_LogComplete takes nothing returns nothing
        call RFBurstLog__Log("COMPLETE|" + I2S(RFBurstLog__cases) + "|" + I2S(RFBurstLog__checks) + "|" + I2S(RFBurstLog__failures) + "|0")
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 120., "Burst RED complete: failures=" + I2S(RFBurstLog__failures))
        call DestroyTrigger(RFBurstLog__writer)
        set RFBurstLog__writer=null
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
            call SaveInteger(TimerUtils__ht, 0, GetHandleId(t), value)
            

















    endfunction

    function GetTimerData takes timer t returns integer

            // new blue
            return LoadInteger(TimerUtils__ht, 0, GetHandleId(t))
            

















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
                call TriggerEvaluate(st___prototype3[(1)]) // INLINED!!
                set TimerUtils__tN=TimerUtils__tN - 1
            else
                //If this happens then the QUANTITY rule has already been broken, try to fix the
                // issue, else fail.
// NO_DEBUG:                 debug call BJDebugMsg("NewTimer: Warning, Exceeding TimerUtils_QUANTITY, make sure all timers are getting recycled correctly")
                set s__TimerUtils__tT[0]= CreateTimer()
















            endif
        else
            set TimerUtils__tN=TimerUtils__tN - 1
        endif
        call SaveInteger(TimerUtils__ht, 0, GetHandleId((s__TimerUtils__tT[TimerUtils__tN] )), ( value)) // INLINED!!
     return s__TimerUtils__tT[TimerUtils__tN]
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
        if ( TimerUtils__tN == TimerUtils__ARRAY_SIZE ) then
// NO_DEBUG:             debug call BJDebugMsg("Warning: Timer stack is full, destroying timer!!")
// NO_DEBUG: 
            //stack is full, the map already has much more troubles than the chance of bug
            call DestroyTimer(t)
        else
            call PauseTimer(t)
            if ( (LoadInteger(TimerUtils__ht, 0, GetHandleId((t)))) == TimerUtils__HELD ) then // INLINED!!
// NO_DEBUG:                 debug call BJDebugMsg("Warning: ReleaseTimer: Double free!")
                return
            endif
            call SaveInteger(TimerUtils__ht, 0, GetHandleId((t )), ( TimerUtils__HELD)) // INLINED!!
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
     

            set TimerUtils__ht=InitHashtable()
            loop
                exitwhen ( i == TimerUtils__QUANTITY )
                set s__TimerUtils__tT[i]= CreateTimer()
                call SaveInteger(TimerUtils__ht, 0, GetHandleId((s__TimerUtils__tT[i] )), ( TimerUtils__HELD)) // INLINED!!
                set i=i + 1
            endloop
            set TimerUtils__tN=TimerUtils__QUANTITY












































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
        set s__WorldBounds_playMaxX=GetRectMaxX(bj_mapInitialPlayableArea)
        set s__WorldBounds_playMaxY=GetRectMaxY(bj_mapInitialPlayableArea)
        set s__WorldBounds_playMinX=GetRectMinX(bj_mapInitialPlayableArea)
        set s__WorldBounds_playMinY=GetRectMinY(bj_mapInitialPlayableArea)
        set s__WorldBounds_worldRegion=CreateRegion()
        call RegionAddRect(s__WorldBounds_worldRegion, s__WorldBounds_world)
        endfunction
    


 
    //Every time a new dummy unit is retrieved, it will apply this resets
    //If it is redundant/you dont need it, remove it.
// =============================================================== //
// ==================== END CONFIGURATION ======================== //
// =============================================================== //
 
 
 



















 
 
//Implemented from module DummyRecycler__M:
     




     
        function s__DummyRecycler__S_DummyRecycler__M__onInit takes nothing returns nothing
            local real add= 360.0 / DummyRecycler__ANGLES_COUNT
            local real a= 0
            local integer this= DummyRecycler__ANGLES_COUNT
            local integer head= 0
            local integer cHead= JASS_MAX_ARRAY_SIZE - 1
            local integer i= R2I(DummyRecycler__MAX_DUMMY_COUNT / DummyRecycler__ANGLES_COUNT + 0.5)
            set DummyRecycler__upper=DummyRecycler__STORED_UNIT_COUNT
            set DummyRecycler__lower=DummyRecycler__STORED_UNIT_COUNT



            //Initialize countHeads
            loop
                exitwhen i < 0
                set DummyRecycler__countNext[cHead]=cHead
                set DummyRecycler__countPrev[cHead]=cHead
                set DummyRecycler__countHead[i]=cHead
                set cHead=cHead - 1
                set i=i - 1
            endloop
            set cHead=DummyRecycler__countHead[DummyRecycler__STORED_UNIT_COUNT] //All heads will be inserted here initially
            //Create the Dummy units
            loop
                exitwhen a >= 360
                //Initialize head
                set DummyRecycler__next[head]=head
                set DummyRecycler__prev[head]=head
                set DummyRecycler__count[head]=DummyRecycler__STORED_UNIT_COUNT
                set DummyRecycler__angle[head]=a
                //Insert head in the Count List
                set DummyRecycler__countNext[head]=cHead
                set DummyRecycler__countPrev[head]=DummyRecycler__countPrev[cHead]
                set DummyRecycler__countNext[DummyRecycler__countPrev[head]]=head
                set DummyRecycler__countPrev[DummyRecycler__countNext[head]]=head
                set i=0
                loop
                    exitwhen i >= DummyRecycler__STORED_UNIT_COUNT
                    //Queued Linked List
                    set DummyRecycler__next[this]=head
                    set DummyRecycler__prev[this]=DummyRecycler__prev[head]
                    set DummyRecycler__next[DummyRecycler__prev[this]]=this
                    set DummyRecycler__prev[DummyRecycler__next[this]]=this


                            set DummyRecycler__dummy[this]=CreateUnit(DummyRecycler__OWNER, DummyRecycler__DUMMY_ID, s__WorldBounds_maxX, s__WorldBounds_maxY, a)






                    call PauseUnit(DummyRecycler__dummy[this], true)



                        call SaveInteger(s__DummyRecycler__S_hash, GetHandleId(DummyRecycler__dummy[this]), 0, this)

                    set this=this + 1
                    set i=i + 1
                endloop
                set head=head + 1
                set a=a + add
            endloop
            set DummyRecycler__lastInstance=this
        endfunction
     
 
    function DummyRecycler__GetHead takes integer facing returns integer
        if facing < 0 or facing >= 360 then
            set facing=facing - ( facing / 360 ) * 360
            if facing < 0 then
                set facing=facing + 360
            endif
        endif
        return R2I(( facing * DummyRecycler__ANGLES_COUNT / 360.0 ))
    endfunction
 
    function ShowDummy takes unit u,boolean flag returns nothing
        if IsUnitHidden(u) == flag then
            call ShowUnit(u, flag)
            if flag and GetUnitTypeId(u) == DummyRecycler__DUMMY_ID then
                call UnitRemoveAbility(u, 'Aloc')
                call UnitAddAbility(u, 'Aloc')
            endif
        endif
    endfunction
 
    function GetRecycledDummy takes real x,real y,real z,real facing returns unit
        local integer head= DummyRecycler__GetHead(R2I(facing + DummyRecycler__FACING_OFFSET))
        local integer this= DummyRecycler__next[head]
        local integer cHead
     
        //If there are Dummy Units in the Queue List already facing close to the appropriate angle
        if this != head and RAbsBJ(GetUnitFacing(DummyRecycler__dummy[this]) - DummyRecycler__angle[head]) <= DummyRecycler__ANGLE_TOLERANCE then
            //Remove from the Queue List
            set DummyRecycler__next[DummyRecycler__prev[this]]=DummyRecycler__next[this]
            set DummyRecycler__prev[DummyRecycler__next[this]]=DummyRecycler__prev[this]
            //For double free protection
            set DummyRecycler__next[this]=- 1
            //Unit Properties
            set bj_lastCreatedUnit=DummyRecycler__dummy[this]
            call SetUnitX(bj_lastCreatedUnit, x)
            call SetUnitY(bj_lastCreatedUnit, y)
            call SetUnitFacing(bj_lastCreatedUnit, facing)
            call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0)
//textmacro instance: DUMMY_UNIT_RESET()
        call SetUnitScale(bj_lastCreatedUnit, 1, 0, 0)
        call SetUnitVertexColor(bj_lastCreatedUnit, 255, 255, 255, 255)
        call SetUnitAnimationByIndex(bj_lastCreatedUnit, 90)
        call ShowDummy(bj_lastCreatedUnit , true)
//end of: DUMMY_UNIT_RESET()
            //Update Count and Bounds
            set DummyRecycler__count[head]=DummyRecycler__count[head] - 1
         
            //------------------------------------------------
            //                 Unit Sharing
            //------------------------------------------------
            if DummyRecycler__count[head] < DummyRecycler__BORROW_REQUEST and DummyRecycler__count[DummyRecycler__countNext[DummyRecycler__countHead[DummyRecycler__upper]]] > DummyRecycler__count[head] then
                set DummyRecycler__count[head]=DummyRecycler__count[head] + 1
                set this=DummyRecycler__next[DummyRecycler__countNext[DummyRecycler__countHead[DummyRecycler__upper]]]
                call SetUnitFacing(DummyRecycler__dummy[this], DummyRecycler__angle[head])
                //Remove
                set DummyRecycler__next[DummyRecycler__prev[this]]=DummyRecycler__next[this]
                set DummyRecycler__prev[DummyRecycler__next[this]]=DummyRecycler__prev[this]
                //Add to the Current List
                set DummyRecycler__next[this]=head
                set DummyRecycler__prev[this]=DummyRecycler__prev[head]
                set DummyRecycler__next[DummyRecycler__prev[this]]=this
                set DummyRecycler__prev[DummyRecycler__next[this]]=this
                set head=DummyRecycler__countNext[DummyRecycler__countHead[DummyRecycler__upper]]
                set DummyRecycler__count[head]=DummyRecycler__count[head] - 1
            endif
         
            //---------------------------
            //Update Count Lists
            //---------------------------
            //Remove from the current Count List
            set DummyRecycler__countNext[DummyRecycler__countPrev[head]]=DummyRecycler__countNext[head]
            set DummyRecycler__countPrev[DummyRecycler__countNext[head]]=DummyRecycler__countPrev[head]
            //Add to the new Count List
            set cHead=DummyRecycler__countHead[DummyRecycler__count[head]]
            set DummyRecycler__countNext[head]=cHead
            set DummyRecycler__countPrev[head]=DummyRecycler__countPrev[cHead]
            set DummyRecycler__countNext[DummyRecycler__countPrev[head]]=head
            set DummyRecycler__countPrev[DummyRecycler__countNext[head]]=head
         
            //---------------------------
            //  Update Bounds
            //---------------------------
            set cHead=DummyRecycler__countHead[DummyRecycler__upper]
            if DummyRecycler__countNext[cHead] == cHead then
                set DummyRecycler__upper=DummyRecycler__upper - 1
            endif
            if DummyRecycler__count[head] < DummyRecycler__lower then
                set DummyRecycler__lower=DummyRecycler__count[head]
            endif
        else
            set bj_lastCreatedUnit=CreateUnit(DummyRecycler__OWNER, DummyRecycler__DUMMY_ID, x, y, facing)
            call PauseUnit(bj_lastCreatedUnit, true)
            call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0)
            if DummyRecycler__dummyCount < DummyRecycler__MAX_DUMMY_COUNT then
                set this=DummyRecycler__lastInstance
                //For double free protection
                set DummyRecycler__next[this]=- 1
                set DummyRecycler__dummy[this]=bj_lastCreatedUnit



                    call SaveInteger(s__DummyRecycler__S_hash, GetHandleId(bj_lastCreatedUnit), 0, this)

                set DummyRecycler__lastInstance=DummyRecycler__lastInstance + 1
            endif
            set DummyRecycler__dummyCount=DummyRecycler__dummyCount + 1
        endif

        return bj_lastCreatedUnit
    endfunction
 
    function RecycleDummy takes unit u returns nothing



            local integer this= LoadInteger(s__DummyRecycler__S_hash, GetHandleId(u), 0)

        local integer head
        local integer cHead
     
        //If the unit is a legit Dummy Unit
        if this > 0 and DummyRecycler__next[this] == - 1 then
            //Find where to insert based on the list having the least number of units
            set head=DummyRecycler__countNext[DummyRecycler__countHead[DummyRecycler__lower]]
            set DummyRecycler__next[this]=head
            set DummyRecycler__prev[this]=DummyRecycler__prev[head]
            set DummyRecycler__next[DummyRecycler__prev[this]]=this
            set DummyRecycler__prev[DummyRecycler__next[this]]=this
            //Update Status
            call SetUnitFacing(u, DummyRecycler__angle[head])
            call PauseUnit(u, true)
            call SetUnitOwner(u, DummyRecycler__OWNER, false)


                    call SetUnitX(u, s__WorldBounds_maxX)
                    call SetUnitY(u, s__WorldBounds_maxY)








            set DummyRecycler__count[head]=DummyRecycler__count[head] + 1
         
            //---------------------------
            //    Update Count Lists
            //---------------------------
            //Remove
            set DummyRecycler__countNext[DummyRecycler__countPrev[head]]=DummyRecycler__countNext[head]
            set DummyRecycler__countPrev[DummyRecycler__countNext[head]]=DummyRecycler__countPrev[head]
            //Add to the new Count List
            set cHead=DummyRecycler__countHead[DummyRecycler__count[head]]
            set DummyRecycler__countNext[head]=cHead
            set DummyRecycler__countPrev[head]=DummyRecycler__countPrev[cHead]
            set DummyRecycler__countNext[DummyRecycler__countPrev[head]]=head
            set DummyRecycler__countPrev[DummyRecycler__countNext[head]]=head
         
            //---------------------------
            //  Update Bounds
            //---------------------------
            set cHead=DummyRecycler__countHead[DummyRecycler__lower]
            if DummyRecycler__countNext[cHead] == cHead then
                set DummyRecycler__lower=DummyRecycler__lower + 1
            endif
            if DummyRecycler__count[head] > DummyRecycler__upper then
                set DummyRecycler__upper=DummyRecycler__count[head]
            endif
        elseif this == 0 then
            call RemoveUnit(u)
// NO_DEBUG:         debug elseif DummyRecycler__next[this] != -1 then
// NO_DEBUG:             debug call BJDebugMsg("|cffffcc00[DummyRecycler]:|r Attempted to recycle a pending/free Dummy Unit.")
        endif
     
    endfunction
 
    function DummyRecycler__Expires takes nothing returns nothing
        local timer t= GetExpiredTimer()
        local integer id= GetHandleId(t)




            call RecycleDummy(LoadUnitHandle(s__DummyRecycler__S_hash, id, 0))
            call FlushChildHashtable(s__DummyRecycler__S_hash, id)

        call DestroyTimer(t)
        set t=null
    endfunction

    function DummyAddRecycleTimer takes unit u,real time returns nothing
        local timer t= CreateTimer()



            call SaveUnitHandle(s__DummyRecycler__S_hash, GetHandleId(t), 0, u)

        call TimerStart(t, time, false, function DummyRecycler__Expires)
        set t=null
    endfunction
 
    function GetRecycledDummyAnyAngle takes real x,real y,real z returns unit
        return GetRecycledDummy(x , y , z , DummyRecycler__angle[DummyRecycler__countNext[DummyRecycler__countHead[DummyRecycler__upper]]])
    endfunction
 
    // runtextmacro DUMMY_DEBUG_TOOLS()
 

    
    // Thanks and Credits to BPower, Dirac and Vexorian for the Missile Library's at which i based
    // this Missiles library. Credits to Vexorian for the dummy model.
    
    // How to Import:
    //     1 -First copy the Missile dummy unit into your map and then import the dummy.mdx
    //     model, setting the missile dummy model path to imported dummy.mdx model.
    //     Dummy model: https://www.hiveworkshop.com/threads/vexorians-dummy-model.149230/
    //     WorldBounds: https://github.com/nestharus/JASS/blob/master/jass/Systems/WorldBounds/script.j
    //     DummyRecycler: https://www.hiveworkshop.com/threads/dummy-recycler-v1-25.277659/
    
    //     2 - Copy this library into your map and set the
    //         DUMMY_RAW_CODE to the raw code of the missile dummy (ctrl + d) and you
    //         are done
    
    
    
    
    

    
    function Missiles___GetLocZ takes real x,real y returns real
        call MoveLocation(Missiles___LOC, x, y)
        return GetLocationZ(Missiles___LOC)
    endfunction

    constant function Missiles___GetUnitCollisionSize takes unit u returns real
        return 64.
    endfunction
    
    function Missiles___GetMapCliffLevel takes nothing returns integer
        return GetTerrainCliffLevel(s__WorldBounds_maxX, s__WorldBounds_maxY)
    endfunction
    
    function Missiles___GetUnitZ takes unit u returns real
        return Missiles___GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u)
    endfunction
    
    function Missiles___SetUnitZ takes unit u,real z returns nothing
        call SetUnitFlyHeight(u, z - Missiles___GetLocZ(GetUnitX(u) , GetUnitY(u)), 0)
    endfunction

    
        
        function s__Missiles___Pool_onExpire takes nothing returns nothing
            local integer this= (LoadInteger(TimerUtils__ht, 0, GetHandleId((GetExpiredTimer())))) // INLINED!!

            call ReleaseTimer(s__Missiles___Pool_timer[this])
            call RemoveUnit(s__Missiles___Pool_unit[this])
            call s__Missiles___Pool_deallocate(this)
            
            set s__Missiles___Pool_timer[this]=null
            set s__Missiles___Pool_unit[this]=null
        endfunction

        function s__Missiles___Pool_recycle takes unit dummy,real delay returns nothing
            local integer this

            if GetUnitTypeId(dummy) != Missiles___DUMMY then
// NO_DEBUG:                 debug call BJDebugMsg("[DummyPool] Error: Trying to recycle a non dummy unit")
            else
                set this=s__Missiles___Pool__allocate()
                set s__Missiles___Pool_timer[this]=NewTimerEx(this)
                set s__Missiles___Pool_unit[this]=dummy
                
                call TimerStart(s__Missiles___Pool_timer[this], delay, false, function s__Missiles___Pool_onExpire)
            endif
        endfunction
        
        function s__Missiles___Pool_retrieve takes real x,real y,real z,real face returns unit
            set bj_lastCreatedUnit=CreateUnit(s__Missiles___Pool_player, Missiles___DUMMY, x, y, face)
            call Missiles___SetUnitZ(bj_lastCreatedUnit , z)
            call UnitRemoveAbility(bj_lastCreatedUnit, 'Amrf')

            return bj_lastCreatedUnit
        endfunction


        // Creates an origin - impact link.

        function s__Missiles___Coordinates_math takes integer a,integer b returns nothing
            local real dx
            local real dy
            loop
                set dx=s__Missiles___Coordinates_x[b] - s__Missiles___Coordinates_x[a]
                set dy=s__Missiles___Coordinates_y[b] - s__Missiles___Coordinates_y[a]
                set dx=dx * dx + dy * dy
                set dy=SquareRoot(dx)
                exitwhen dx != 0. and dy != 0.
                set s__Missiles___Coordinates_x[b]=s__Missiles___Coordinates_x[b] + .01
                set s__Missiles___Coordinates_z[b]=s__Missiles___Coordinates_z[b] - Missiles___GetLocZ(s__Missiles___Coordinates_x[b] - .01 , s__Missiles___Coordinates_y[b]) + Missiles___GetLocZ(s__Missiles___Coordinates_x[b] , s__Missiles___Coordinates_y[b])
            endloop

            set s__Missiles___Coordinates_square[a]=dx
            set s__Missiles___Coordinates_distance[a]=dy
            set s__Missiles___Coordinates_angle[a]=Atan2(s__Missiles___Coordinates_y[b] - s__Missiles___Coordinates_y[a], s__Missiles___Coordinates_x[b] - s__Missiles___Coordinates_x[a])
            set s__Missiles___Coordinates_slope[a]=( s__Missiles___Coordinates_z[b] - s__Missiles___Coordinates_z[a] ) / dy
            set s__Missiles___Coordinates_alpha[a]=Atan(s__Missiles___Coordinates_slope[a]) * bj_RADTODEG
            // Set b.
            if s__Missiles___Coordinates_ref[b] == a then
                set s__Missiles___Coordinates_angle[b]=s__Missiles___Coordinates_angle[a] + bj_PI
                set s__Missiles___Coordinates_distance[b]=dy
                set s__Missiles___Coordinates_slope[b]=- s__Missiles___Coordinates_slope[a]
                set s__Missiles___Coordinates_alpha[b]=- s__Missiles___Coordinates_alpha[a]
                set s__Missiles___Coordinates_square[b]=dx
            endif
        endfunction

        function s__Missiles___Coordinates_link takes integer a,integer b returns nothing
            set s__Missiles___Coordinates_ref[a]=b
            set s__Missiles___Coordinates_ref[b]=a
            call s__Missiles___Coordinates_math(a , b)
        endfunction

        function s__Missiles___Coordinates_move takes integer this,real toX,real toY,real toZ returns nothing
            set s__Missiles___Coordinates_x[this]=toX
            set s__Missiles___Coordinates_y[this]=toY
            set s__Missiles___Coordinates_z[this]=toZ + Missiles___GetLocZ(toX , toY)
            if s__Missiles___Coordinates_ref[this] != this then
                call s__Missiles___Coordinates_math(this , s__Missiles___Coordinates_ref[this])
            endif
        endfunction

        function s__Missiles___Coordinates_destroy takes integer this returns nothing
            call s__Missiles___Coordinates_deallocate(this)
        endfunction

        function s__Missiles___Coordinates_create takes real x,real y,real z returns integer
            local integer this= s__Missiles___Coordinates__allocate()
            set s__Missiles___Coordinates_ref[this]=this
            call s__Missiles___Coordinates_move(this,x , y , z)
            return this
        endfunction
    
    
    
    
  
  
  
    
    
    
    
    

    
    
    
    
    
    
    
        
        
        // Active scheduler membership owns the ID until remove detaches it.
        // Pins protect non-scheduler callback dispatch (pause/resume/remove).
        // Uncurved current sample; setters refresh prediction without advancing it.
        
        
        
    
        function s__Missiles_predict takes integer this returns nothing
            local real d= s__Missiles___Coordinates_distance[s__Missiles_origin[this]]
            local real q= s__Missiles_progress[this] + s__Missiles_veloc[this] * s__Missiles_dilation
            local real advance
            local real lateral
            if not s__Missiles_allocated[this] then
                return
            endif
            if q > d then
                set q=d
            endif
            set advance=q - s__Missiles_progress[this]
            set s__Missiles_nextProgress[this]=q
            set s__Missiles_nextBaseX[this]=s__Missiles_baseX[this] + advance * Cos(s__Missiles_cA[this])
            set s__Missiles_nextBaseY[this]=s__Missiles_baseY[this] + advance * Sin(s__Missiles_cA[this])
            if q >= d then
                set s__Missiles_nextBaseX[this]=s__Missiles___Coordinates_x[s__Missiles_impact[this]]
                set s__Missiles_nextBaseY[this]=s__Missiles___Coordinates_y[s__Missiles_impact[this]]
            endif
            set lateral=4 * s__Missiles_open[this] * q * ( d - q ) / ( d * d )
            set s__Missiles_nextX[this]=s__Missiles_nextBaseX[this] + lateral * Cos(s__Missiles_cA[this] + bj_PI / 2)
            set s__Missiles_nextY[this]=s__Missiles_nextBaseY[this] + lateral * Sin(s__Missiles_cA[this] + bj_PI / 2)
            set s__Missiles_nextZ[this]=s__Missiles___Coordinates_z[s__Missiles_origin[this]] + s__Missiles___Coordinates_slope[s__Missiles_origin[this]] * q + 4 * s__Missiles_height[this] * q * ( d - q ) / ( d * d )
        endfunction

        function s__Missiles_clearVision takes integer this returns nothing
            if s__Missiles_visionFog[this] != null then
                call FogModifierStop(s__Missiles_visionFog[this])
                call DestroyFogModifier(s__Missiles_visionFog[this])
                set s__Missiles_visionFog[this]=null
            endif
            set s__Missiles_visionOwner[this]=null
        endfunction

        // Explicit circular revelation; not unit sight or terrain/tree occlusion.
        function s__Missiles_refreshVision takes integer this returns nothing
            local player p= s__Missiles_owner[this]
            local boolean reveal= p != null
            if not s__Missiles_allocated[this] then
                call s__Missiles_clearVision(this)
                set p=null
                return
            endif
            if p == null then
                if s__Missiles_source[this] != null and GetUnitTypeId(s__Missiles_source[this]) != 0 then
                    set p=GetOwningPlayer(s__Missiles_source[this])
                    set reveal=true
                else
                    set p=Player(PLAYER_NEUTRAL_PASSIVE)
                endif
            endif
            if GetOwningPlayer(s__Missiles_dummy[this]) != p then
                call SetUnitOwner(s__Missiles_dummy[this], p, false)
            endif
            // Neutral fallback owns the dummy, but absence of an owner grants no reveal.
            if s__Missiles_sight[this] <= 0. or not reveal then
                call s__Missiles_clearVision(this)
            elseif s__Missiles_visionFog[this] == null or s__Missiles_visionOwner[this] != p or s__Missiles_visionRadius[this] != s__Missiles_sight[this] or s__Missiles_visionX[this] != s__Missiles_x[this] or s__Missiles_visionY[this] != s__Missiles_y[this] then
                call s__Missiles_clearVision(this)
                set s__Missiles_visionOwner[this]=p
                set s__Missiles_visionRadius[this]=s__Missiles_sight[this]
                set s__Missiles_visionX[this]=s__Missiles_x[this]
                set s__Missiles_visionY[this]=s__Missiles_y[this]
                set s__Missiles_visionFog[this]=CreateFogModifierRadius(p, FOG_OF_WAR_VISIBLE, s__Missiles_x[this], s__Missiles_y[this], s__Missiles_sight[this], true, false)
                call FogModifierStart(s__Missiles_visionFog[this])
            endif
            set p=null
        endfunction

//Implemented from module Missiles___Operators:
        
        function s__Missiles__set_model takes integer this,string fxpath returns nothing
            call DestroyEffect(s__Missiles_effect[this])
            set s__Missiles_path[this]=fxpath
            set s__Missiles_effect[this]=AddSpecialEffectTarget(fxpath, s__Missiles_dummy[this], "origin")
        endfunction
    
        function s__Missiles__get_model takes integer this returns string
            return s__Missiles_path[this]
        endfunction
    
        
        function s__Missiles__set_curve takes integer this,real value returns nothing
            set s__Missiles_open[this]=Tan(value * bj_DEGTORAD) * s__Missiles___Coordinates_distance[s__Missiles_origin[this]]
            call s__Missiles_predict(this)
        endfunction
    
        function s__Missiles__get_curve takes integer this returns real
            return Atan(s__Missiles_open[this] / s__Missiles___Coordinates_distance[s__Missiles_origin[this]]) * bj_RADTODEG
        endfunction
    
        
        function s__Missiles__set_arc takes integer this,real value returns nothing
            set s__Missiles_height[this]=Tan(value * bj_DEGTORAD) * s__Missiles___Coordinates_distance[s__Missiles_origin[this]] / 4
            call s__Missiles_predict(this)
        endfunction
    
        function s__Missiles__get_arc takes integer this returns real
            return Atan(4 * s__Missiles_height[this] / s__Missiles___Coordinates_distance[s__Missiles_origin[this]]) * bj_RADTODEG
        endfunction
    
        
        function s__Missiles__set_scale takes integer this,real v returns nothing
            call SetUnitScale(s__Missiles_dummy[this], v, v, v)
            set s__Missiles_size[this]=v
        endfunction
    
        function s__Missiles__get_scale takes integer this returns real
            return s__Missiles_size[this]
        endfunction

        
        function s__Missiles__set_speed takes integer this,real newspeed returns nothing
            set s__Missiles_veloc[this]=newspeed * Missiles_PERIOD
            call s__Missiles_predict(this)
        endfunction

        function s__Missiles__get_speed takes integer this returns real
            return s__Missiles_veloc[this] / Missiles_PERIOD
        endfunction

        
        function s__Missiles__set_duration takes integer this,real flightTime returns nothing
            set s__Missiles_veloc[this]=RMaxBJ(0.00000001, ( s__Missiles___Coordinates_distance[s__Missiles_origin[this]] - s__Missiles_progress[this] ) * Missiles_PERIOD / RMaxBJ(0.00000001, flightTime))
            set s__Missiles_time[this]=flightTime
            call s__Missiles_predict(this)
        endfunction

        function s__Missiles__get_duration takes integer this returns real
            return s__Missiles_time[this]
        endfunction
        
        
        function s__Missiles__set_vision takes integer this,real sightRange returns nothing
            set s__Missiles_sight[this]=sightRange
            call s__Missiles_refreshVision(this)
        endfunction

        function s__Missiles__get_vision takes integer this returns real
            return s__Missiles_sight[this]
        endfunction
//Implemented from module Missiles___Methods:
        
        function s__Missiles_bounce takes integer this returns nothing
            call s__Missiles___Coordinates_move(s__Missiles_origin[this],s__Missiles_x[this] , s__Missiles_y[this] , s__Missiles_z[this] - Missiles___GetLocZ(s__Missiles_x[this] , s__Missiles_y[this]))
            
            set s__Missiles_travel[this]=0
            set s__Missiles_progress[this]=0.
            set s__Missiles_baseX[this]=s__Missiles_x[this]
            set s__Missiles_baseY[this]=s__Missiles_y[this]
            set s__Missiles_cA[this]=s__Missiles___Coordinates_angle[s__Missiles_origin[this]]
            set s__Missiles_finished[this]=false
            call s__Missiles_predict(this)
        endfunction
        
        function s__Missiles_deflect takes integer this,real tx,real ty,real tz returns nothing
            local real locZ= Missiles___GetLocZ(s__Missiles_x[this] , s__Missiles_y[this])
            
            set s__Missiles_target[this]=null
            set s__Missiles_toZ[this]=tz
            
            if s__Missiles_z[this] < locZ and (st__Missiles___MissileEvents_onTerrain[si__Missiles___MissileEvents_type[this]]!=null) then
                set s__Missiles_nextX[this]=s__Missiles_prevX[this]
                set s__Missiles_nextY[this]=s__Missiles_prevY[this]
                set s__Missiles_nextZ[this]=s__Missiles_prevZ[this]
            endif
            
            call s__Missiles___Coordinates_move(s__Missiles_impact[this],tx , ty , tz)
            call s__Missiles___Coordinates_move(s__Missiles_origin[this],s__Missiles_x[this] , s__Missiles_y[this] , s__Missiles_z[this] - locZ)
            
            set s__Missiles_travel[this]=0
            set s__Missiles_progress[this]=0.
            set s__Missiles_baseX[this]=s__Missiles_x[this]
            set s__Missiles_baseY[this]=s__Missiles_y[this]
            set s__Missiles_cA[this]=s__Missiles___Coordinates_angle[s__Missiles_origin[this]]
            set s__Missiles_finished[this]=false
            call s__Missiles_predict(this)
        endfunction
        
        function s__Missiles_deflectTarget takes integer this,unit u returns nothing
            call s__Missiles_deflect(this,GetUnitX(u) , GetUnitY(u) , s__Missiles_toZ[this])
            set s__Missiles_target[this]=u
        endfunction

        
        function s__Missiles_flushAll takes integer this returns nothing
            call FlushChildHashtable(s__Missiles_Missiles___table, this)
            call FlushChildHashtable(s__Missiles_missileHits, this)
        endfunction

        function s__Missiles_flush takes integer this,widget w returns nothing
            if w != null then
                call RemoveSavedBoolean(s__Missiles_Missiles___table, this, GetHandleId(w))
            endif
        endfunction

        function s__Missiles_hitted takes integer this,widget w returns boolean
            return HaveSavedBoolean(s__Missiles_Missiles___table, this, GetHandleId(w))
        endfunction

        
        function s__Missiles_pause takes integer this,boolean flag returns nothing
        local integer aux
        local boolean stop

        if not s__Missiles_allocated[this] then
            return
        endif
        set s__Missiles_paused[this]=flag
        if not s__Missiles_paused[this] and s__Missiles_pkey[this] != - 1 then
            // Keep this lifetime pinned across a callback that may terminate it.
            set s__Missiles_pins[this]=s__Missiles_pins[this] + 1
            set s__Missiles_active[this]=true
            set s__Missiles_id=s__Missiles_id + 1
            set s__Missiles_missiles[s__Missiles_id]=this
            set aux=s__Missiles_frozen[s__Missiles_pid]
            set s__Missiles_pkey[aux]=s__Missiles_pkey[this]
            set s__Missiles_frozen[s__Missiles_pkey[this]]=s__Missiles_frozen[s__Missiles_pid]
            set s__Missiles_pid=s__Missiles_pid - 1
            set s__Missiles_pkey[this]=- 1

            if s__Missiles_id + 1 > Missiles_SWEET_SPOT and Missiles_SWEET_SPOT > 0 then
                set s__Missiles_dilation=( s__Missiles_id + 1 ) / Missiles_SWEET_SPOT
            else
                set s__Missiles_dilation=1.
            endif

            if s__Missiles_id == 0 then
                call TimerStart(s__Missiles_timer, Missiles_PERIOD, true, function sc__Missiles_move)
            endif
            
            if (st__Missiles___MissileEvents_onResume[si__Missiles___MissileEvents_type[this]]!=null) then
                set stop=sc__Missiles___MissileEvents_onResume(this)
                if s__Missiles_allocated[this] then
                    if stop or s__Missiles_finished[this] then
                        call sc__Missiles_terminate(this)
                    endif
                endif
            else
                if s__Missiles_finished[this] then
                    call sc__Missiles_terminate(this)
                endif
            endif
            set s__Missiles_pins[this]=s__Missiles_pins[this] - 1
            call sc__Missiles_release(this)
        endif
        endfunction

        
        function s__Missiles_onDest takes nothing returns nothing
            local integer this= s__Missiles_temp
            local destructable d= GetEnumDestructable()
            local real dz
            local real tz
            local boolean stop

            // Native enumeration continues visiting handles after termination.
            if not s__Missiles_allocated[this] then
                set d=null
                return
            endif
            // Padding only finds candidates; do not widen the logical square.
            if RAbsBJ(GetWidgetX(d) - s__Missiles_x[this]) > s__Missiles_collision[this] or RAbsBJ(GetWidgetY(d) - s__Missiles_y[this]) > s__Missiles_collision[this] then
                set d=null
                return
            endif
            if not HaveSavedBoolean(s__Missiles_Missiles___table, this, GetHandleId(d)) then
                if s__Missiles_collideZ[this] then
                    set dz=Missiles___GetLocZ(GetWidgetX(d) , GetWidgetY(d))
                    set tz=GetDestructableOccluderHeight(d)
                    if dz + tz >= s__Missiles_z[this] - s__Missiles_collision[this] and dz <= s__Missiles_z[this] + s__Missiles_collision[this] then
                        call SaveBoolean(s__Missiles_Missiles___table, this, GetHandleId(d), true)
                        set stop=sc__Missiles___MissileEvents_onDestructable(this,d)
                        if s__Missiles_allocated[this] and stop then
                            set d=null
                            call sc__Missiles_terminate(this)
                            return
                        endif
                    endif
                else
                    call SaveBoolean(s__Missiles_Missiles___table, this, GetHandleId(d), true)
                    set stop=sc__Missiles___MissileEvents_onDestructable(this,d)
                    if s__Missiles_allocated[this] and stop then
                        set d=null
                        call sc__Missiles_terminate(this)
                        return
                    endif
                endif
            endif

            set d=null
        endfunction

        
        function s__Missiles_onItems takes nothing returns nothing
            local integer this= s__Missiles_temp
            local item i= GetEnumItem()
            local real dz
            local boolean stop

            if not s__Missiles_allocated[this] then
                set i=null
                return
            endif
            if RAbsBJ(GetItemX(i) - s__Missiles_x[this]) > s__Missiles_collision[this] or RAbsBJ(GetItemY(i) - s__Missiles_y[this]) > s__Missiles_collision[this] then
                set i=null
                return
            endif
            if not HaveSavedBoolean(s__Missiles_Missiles___table, this, GetHandleId(i)) then
                if s__Missiles_collideZ[this] then
                    set dz=Missiles___GetLocZ(GetItemX(i) , GetItemY(i))
                    if dz + Missiles___ITEM_SIZE >= s__Missiles_z[this] - s__Missiles_collision[this] and dz <= s__Missiles_z[this] + s__Missiles_collision[this] then
                        call SaveBoolean(s__Missiles_Missiles___table, this, GetHandleId(i), true)
                        set stop=sc__Missiles___MissileEvents_onItem(this,i)
                        if s__Missiles_allocated[this] and stop then
                            set i=null
                            call sc__Missiles_terminate(this)
                            return
                        endif
                    endif
                else
                    call SaveBoolean(s__Missiles_Missiles___table, this, GetHandleId(i), true)
                    set stop=sc__Missiles___MissileEvents_onItem(this,i)
                    if s__Missiles_allocated[this] and stop then
                        set i=null
                        call sc__Missiles_terminate(this)
                        return
                    endif
                endif
            endif

            set i=null
        endfunction

        
        function s__Missiles_terminate takes integer this returns nothing
        local integer aux
    
        if s__Missiles_allocated[this] then
            // Block recursive terminate/launch before calling user code. Resources
            // stay readable until onRemove returns; no allocator reuse meanwhile.
            set s__Missiles_allocated[this]=false
            set s__Missiles_pins[this]=s__Missiles_pins[this] + 1
            
            if s__Missiles_pkey[this] != - 1 then
                set aux=s__Missiles_frozen[s__Missiles_pid]
                set s__Missiles_pkey[aux]=s__Missiles_pkey[this]
                set s__Missiles_frozen[s__Missiles_pkey[this]]=s__Missiles_frozen[s__Missiles_pid]
                set s__Missiles_pid=s__Missiles_pid - 1
                set s__Missiles_pkey[this]=- 1
            endif
            
            if (st__Missiles___MissileEvents_onRemove[si__Missiles___MissileEvents_type[this]]!=null) then
                call sc__Missiles___MissileEvents_onRemove(this)
            endif
            
            if s__Missiles_index[this] != - 1 then
                set aux=s__Missiles_collection[s__Missiles_count]
                set s__Missiles_index[aux]=s__Missiles_index[this]
                set s__Missiles_collection[s__Missiles_index[this]]=s__Missiles_collection[s__Missiles_count]
                set s__Missiles_count=s__Missiles_count - 1
                set s__Missiles_index[this]=- 1
            endif


                call SetUnitOwner(s__Missiles_dummy[this], Player(PLAYER_NEUTRAL_PASSIVE), false)
                call DummyAddRecycleTimer(s__Missiles_dummy[this] , Missiles___RECYCLE_TIME)



            call s__Missiles_clearVision(this)
            call s__Missiles___Coordinates_deallocate((s__Missiles_origin[this])) // INLINED!!
            call s__Missiles___Coordinates_deallocate((s__Missiles_impact[this])) // INLINED!!
            call DestroyEffect(s__Missiles_effect[this])
            call sc__Missiles_reset(this)
            call s__Missiles_flushAll(this)
            set s__Missiles_pins[this]=s__Missiles_pins[this] - 1
            call sc__Missiles_release(this)
        endif
        endfunction

        
        function s__Missiles_reset takes integer this returns nothing
            set s__Missiles_launched[this]=false
            set s__Missiles_finished[this]=false
            set s__Missiles_collideZ[this]=false
            set s__Missiles_paused[this]=false
            set s__Missiles_source[this]=null
            set s__Missiles_target[this]=null
            set s__Missiles_owner[this]=null
            set s__Missiles_effect[this]=null
            set s__Missiles_dummy[this]=null
            set s__Missiles_path[this]=""
            set s__Missiles_open[this]=0.
            set s__Missiles_height[this]=0.
            set s__Missiles_veloc[this]=0.
            set s__Missiles_acceleration[this]=0.
            set s__Missiles_collision[this]=0.
            set s__Missiles_damage[this]=0.
            set s__Missiles_travel[this]=0.
            set s__Missiles_turn[this]=0.
            set s__Missiles_size[this]=0.
            set s__Missiles_time[this]=0.
            set s__Missiles_sight[this]=0.
            set s__Missiles_progress[this]=0.
            set s__Missiles_nextProgress[this]=0.
            set s__Missiles_visionFog[this]=null
            set s__Missiles_visionOwner[this]=null
            set s__Missiles_visionRadius[this]=0.
            set s__Missiles_data[this]=0
            set s__Missiles_type[this]=0
            set s__Missiles_tileset[this]=0
            set s__Missiles_pkey[this]=- 1
            set s__Missiles_index[this]=- 1
        endfunction
        
        // The only Missiles allocator-release site. Cleanup and ID ownership are
        // separate: active terminal instances still occupy a scheduler slot.
        function s__Missiles_release takes integer this returns nothing
            if not s__Missiles_allocated[this] and not s__Missiles_active[this] and s__Missiles_pins[this] == 0 then
                call sc__Missiles___MissileEvents_deallocate(this)
            endif
        endfunction

        
        function s__Missiles_remove takes integer this,integer i returns integer
            local boolean stop

            set s__Missiles_pins[this]=s__Missiles_pins[this] + 1
            // Detach BEFORE onPause: a nested resume owns a new active slot.
            set s__Missiles_missiles[i]=s__Missiles_missiles[s__Missiles_id]
            set s__Missiles_id=s__Missiles_id - 1
            set s__Missiles_active[this]=false

            if s__Missiles_id + 1 > Missiles_SWEET_SPOT and Missiles_SWEET_SPOT > 0 then
                set s__Missiles_dilation=( s__Missiles_id + 1 ) / Missiles_SWEET_SPOT
            else
                set s__Missiles_dilation=1
            endif

            if s__Missiles_id == - 1 then
                call PauseTimer(s__Missiles_timer)
            endif
            
            if s__Missiles_allocated[this] and s__Missiles_paused[this] then
//Implemented from module Missiles___OnPause:
        set s__Missiles_pid=s__Missiles_pid + 1
        set s__Missiles_pkey[this]=s__Missiles_pid
        set s__Missiles_frozen[s__Missiles_pid]=this
        
        if (st__Missiles___MissileEvents_onPause[si__Missiles___MissileEvents_type[this]]!=null) then
            set stop=sc__Missiles___MissileEvents_onPause(this)
            if s__Missiles_allocated[this] and stop then
                call s__Missiles_terminate(this)
            endif
        endif
            else
//Implemented from module Missiles___OnRemove:
            endif
            set s__Missiles_pins[this]=s__Missiles_pins[this] - 1
            call s__Missiles_release(this)

            return i - 1
        endfunction
    
        
        function s__Missiles_move takes nothing returns nothing
            local integer j= 0
            local integer i
            local integer k
            local unit u
            local real a
            local real d
            local real s
            local real h
            local real c
            local real dx
            local real dy
            local real vel
            local real yaw
            local real pitch
            local integer missile
            local integer o
            local integer this
            local boolean stop

            if Missiles_SWEET_SPOT > 0 then
                set i=s__Missiles_last
            else
                set i=0
            endif
        
            loop
                exitwhen ( ( j >= Missiles_SWEET_SPOT and Missiles_SWEET_SPOT > 0 ) or j > s__Missiles_id )
                set this=s__Missiles_missiles[i]
                    set s__Missiles_temp=this
                    if s__Missiles_allocated[this] and not s__Missiles_paused[this] then
//Implemented from module Missiles___OnHit:
        set o=s__Missiles_origin[this]
        set h=s__Missiles_height[this]
        set c=s__Missiles_open[this]
        set d=s__Missiles___Coordinates_distance[o]
        
        if (st__Missiles___MissileEvents_onHit[si__Missiles___MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                call GroupEnumUnitsInRange(s__Missiles_group, s__Missiles_x[this], s__Missiles_y[this], s__Missiles_collision[this] + Missiles___COLLISION_SIZE, null)
                loop
                    set u=FirstOfGroup(s__Missiles_group)
                    exitwhen u == null or not s__Missiles_allocated[this]
                        if not HaveSavedBoolean(s__Missiles_Missiles___table, this, GetHandleId(u)) then
                            if IsUnitInRangeXY(u, s__Missiles_x[this], s__Missiles_y[this], s__Missiles_collision[this]) then
                                if s__Missiles_collideZ[this] then
                                    set dx=Missiles___GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u)
                                    set dy=Missiles___GetUnitCollisionSize(u)
                                    if dx + dy >= s__Missiles_z[this] - s__Missiles_collision[this] and dx <= s__Missiles_z[this] + s__Missiles_collision[this] then
                                        call SaveBoolean(s__Missiles_Missiles___table, this, GetHandleId(u), true)
                                        set stop=sc__Missiles___MissileEvents_onHit(this,u)
                                        if s__Missiles_allocated[this] and stop then
                                            call s__Missiles_terminate(this)
                                        endif
                                        exitwhen not s__Missiles_allocated[this]
                                    endif
                                else
                                    call SaveBoolean(s__Missiles_Missiles___table, this, GetHandleId(u), true)
                                    set stop=sc__Missiles___MissileEvents_onHit(this,u)
                                    if s__Missiles_allocated[this] and stop then
                                        call s__Missiles_terminate(this)
                                    endif
                                    exitwhen not s__Missiles_allocated[this]
                                endif
                            endif
                        endif
                    call GroupRemoveUnit(s__Missiles_group, u)
                endloop
            endif
        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles___OnMissile:
        if (st__Missiles___MissileEvents_onMissile[si__Missiles___MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                set k=0
                loop
                    exitwhen k > s__Missiles_count or not s__Missiles_allocated[this]
                        set missile=s__Missiles_collection[k]
                        if missile != this and s__Missiles_allocated[missile] then
                            if LoadInteger(s__Missiles_missileHits, this, missile) != s__Missiles_generation[missile] then
                                set dx=s__Missiles_x[missile] - s__Missiles_x[this]
                                set dy=s__Missiles_y[missile] - s__Missiles_y[this]
                                if SquareRoot(dx * dx + dy * dy) <= s__Missiles_collision[this] then
                                    call SaveInteger(s__Missiles_missileHits, this, missile, s__Missiles_generation[missile])
                                    set stop=sc__Missiles___MissileEvents_onMissile(this,missile)
                                    if s__Missiles_allocated[this] and stop then
                                        call s__Missiles_terminate(this)
                                    endif
                                    exitwhen not s__Missiles_allocated[this]
                                endif
                            endif
                        endif
                    set k=k + 1
                endloop
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles___OnDestructable:
        if (st__Missiles___MissileEvents_onDestructable[si__Missiles___MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                set dx=s__Missiles_collision[this] + Missiles___COLLISION_SIZE
                call SetRect(s__Missiles_rect, s__Missiles_x[this] - dx, s__Missiles_y[this] - dx, s__Missiles_x[this] + dx, s__Missiles_y[this] + dx)
                call EnumDestructablesInRect(s__Missiles_rect, null, function s__Missiles_onDest)
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles___OnItem:
        if (st__Missiles___MissileEvents_onItem[si__Missiles___MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                set dx=s__Missiles_collision[this] + Missiles___COLLISION_SIZE
                call SetRect(s__Missiles_rect, s__Missiles_x[this] - dx, s__Missiles_y[this] - dx, s__Missiles_x[this] + dx, s__Missiles_y[this] + dx)
                call EnumItemsInRect(s__Missiles_rect, null, function s__Missiles_onItems)
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles___OnCliff:
        if (st__Missiles___MissileEvents_onCliff[si__Missiles___MissileEvents_type[this]]!=null) then
            set dx=GetTerrainCliffLevel(s__Missiles_nextX[this], s__Missiles_nextY[this])
            set dy=GetTerrainCliffLevel(s__Missiles_x[this], s__Missiles_y[this])
            if dy < dx and s__Missiles_z[this] < ( dx - (GetTerrainCliffLevel(s__WorldBounds_maxX, s__WorldBounds_maxY)) ) * bj_CLIFFHEIGHT then // INLINED!!
                set stop=sc__Missiles___MissileEvents_onCliff(this)
                if s__Missiles_allocated[this] and stop then
                    call s__Missiles_terminate(this)
                endif
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles___OnTerrain:
        if (st__Missiles___MissileEvents_onTerrain[si__Missiles___MissileEvents_type[this]]!=null) then
            if Missiles___GetLocZ(s__Missiles_x[this] , s__Missiles_y[this]) > s__Missiles_z[this] then
                set stop=sc__Missiles___MissileEvents_onTerrain(this)
                if s__Missiles_allocated[this] and stop then
                    call s__Missiles_terminate(this)
                endif
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles___OnTileset:
        if (st__Missiles___MissileEvents_onTileset[si__Missiles___MissileEvents_type[this]]!=null) then
            set k=GetTerrainType(s__Missiles_x[this], s__Missiles_y[this])
            if k != s__Missiles_tileset[this] then
                set stop=sc__Missiles___MissileEvents_onTileset(this,k)
                if s__Missiles_allocated[this] and stop then
                    call s__Missiles_terminate(this)
                endif
            endif
            if s__Missiles_allocated[this] then
                set s__Missiles_tileset[this]=k
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles___OnPeriod:
        if (st__Missiles___MissileEvents_onPeriod[si__Missiles___MissileEvents_type[this]]!=null) then
            set stop=sc__Missiles___MissileEvents_onPeriod(this)
            if s__Missiles_allocated[this] and stop then
                call s__Missiles_terminate(this)
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles___OnOrient:
        // Refresh after callbacks: onPeriod may have moved the target.
        set u=s__Missiles_target[this]
        if u != null and GetUnitTypeId(u) != 0 then
            call s__Missiles___Coordinates_move(s__Missiles_impact[this],GetUnitX(u) , GetUnitY(u) , GetUnitFlyHeight(u) + s__Missiles_toZ[this])
            set dx=s__Missiles___Coordinates_x[s__Missiles_impact[this]] - s__Missiles_baseX[this]
            set dy=s__Missiles___Coordinates_y[s__Missiles_impact[this]] - s__Missiles_baseY[this]
            set a=Atan2(dy, dx)
            set s__Missiles_progress[this]=s__Missiles___Coordinates_distance[s__Missiles_origin[this]] - SquareRoot(dx * dx + dy * dy)
        else
            set a=s__Missiles___Coordinates_angle[s__Missiles_origin[this]]
            set s__Missiles_target[this]=null
        endif
        set o=s__Missiles_origin[this]
        set d=s__Missiles___Coordinates_distance[o]
        set h=s__Missiles_height[this]
        set c=s__Missiles_open[this]
        if s__Missiles_turn[this] != 0 and not ( Cos(s__Missiles_cA[this] - a) >= Cos(s__Missiles_turn[this]) ) then
            if Sin(a - s__Missiles_cA[this]) >= 0 then
                set s__Missiles_cA[this]=s__Missiles_cA[this] + s__Missiles_turn[this]
            else
                set s__Missiles_cA[this]=s__Missiles_cA[this] - s__Missiles_turn[this]
            endif
        else
            set s__Missiles_cA[this]=a
        endif

        // Promote one complete XYZ sample, then predict the next one.
        call s__Missiles_predict(this)
        set s__Missiles_prevX[this]=s__Missiles_x[this]
        set s__Missiles_prevY[this]=s__Missiles_y[this]
        set s__Missiles_prevZ[this]=s__Missiles_z[this]
        set s__Missiles_x[this]=s__Missiles_nextX[this]
        set s__Missiles_y[this]=s__Missiles_nextY[this]
        set s__Missiles_z[this]=s__Missiles_nextZ[this]
        set s__Missiles_baseX[this]=s__Missiles_nextBaseX[this]
        set s__Missiles_baseY[this]=s__Missiles_nextBaseY[this]
        set s__Missiles_progress[this]=s__Missiles_nextProgress[this]
        set s=s__Missiles_progress[this]
        set s__Missiles_veloc[this]=s__Missiles_veloc[this] + s__Missiles_acceleration[this]
        call s__Missiles_predict(this)
        // Historical public travel convention: next progress during flight.
        set s__Missiles_travel[this]=s__Missiles_nextProgress[this]
        set pitch=s__Missiles___Coordinates_alpha[o] - Atan(4 * h * ( 2 * s - d ) / ( d * d )) * bj_RADTODEG
        set yaw=( s__Missiles_cA[this] + Atan(- 4 * c * ( 2 * s - d ) / ( d * d )) ) * bj_RADTODEG
        call s__Missiles_refreshVision(this)
//Implemented from module Missiles___OnFinish:
        if s >= d then
            set s__Missiles_finished[this]=true
            if (st__Missiles___MissileEvents_onFinish[si__Missiles___MissileEvents_type[this]]!=null) then
                set stop=sc__Missiles___MissileEvents_onFinish(this)
                if s__Missiles_allocated[this] then
                    if stop then
                        call s__Missiles_terminate(this)
                    elseif s__Missiles_travel[this] > 0 and not s__Missiles_paused[this] then
                        call s__Missiles_terminate(this)
                    endif
                endif
            else
                call s__Missiles_terminate(this)
            endif
        endif

        if s__Missiles_allocated[this] then
            call SetUnitAnimationByIndex(s__Missiles_dummy[this], R2I(pitch + 90.5))
            call SetUnitFacing(s__Missiles_dummy[this], yaw)
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles___OnBoundaries:
        if not ( s__Missiles_x[this] > s__WorldBounds_maxX or s__Missiles_x[this] < s__WorldBounds_minX or s__Missiles_y[this] > s__WorldBounds_maxY or s__Missiles_y[this] < s__WorldBounds_minY ) then
            call SetUnitX(s__Missiles_dummy[this], s__Missiles_x[this])
            call SetUnitY(s__Missiles_dummy[this], s__Missiles_y[this])
            call Missiles___SetUnitZ(s__Missiles_dummy[this] , s__Missiles_z[this])
        else
            if (st__Missiles___MissileEvents_onBoundaries[si__Missiles___MissileEvents_type[this]]!=null) then
                set stop=sc__Missiles___MissileEvents_onBoundaries(this)
                if s__Missiles_allocated[this] and stop then
                    call s__Missiles_terminate(this)
                endif
            endif
        endif
                        endif
                    else
                        set i=s__Missiles_remove(this,i)
                        set j=j - 1
                    endif
                set i=i + 1
                set j=j + 1

                if i > s__Missiles_id and Missiles_SWEET_SPOT > 0 then
                    set i=0
                endif
            endloop
            set s__Missiles_last=i

            set u=null
        endfunction
        
        
        function s__Missiles_launch takes integer this returns nothing
            if not s__Missiles_launched[this] and s__Missiles_allocated[this] then
                set s__Missiles_launched[this]=true
                set s__Missiles_active[this]=true
                set s__Missiles_id=s__Missiles_id + 1
                set s__Missiles_missiles[s__Missiles_id]=this
                set s__Missiles_count=s__Missiles_count + 1
                set s__Missiles_index[this]=s__Missiles_count
                set s__Missiles_collection[s__Missiles_count]=this
                
                if s__Missiles_id + 1 > Missiles_SWEET_SPOT and Missiles_SWEET_SPOT > 0 then
                    set s__Missiles_dilation=( s__Missiles_id + 1 ) / Missiles_SWEET_SPOT
                else
                    set s__Missiles_dilation=1.
                endif

                if s__Missiles_id == 0 then
                    call TimerStart(s__Missiles_timer, Missiles_PERIOD, true, function s__Missiles_move)
                endif
            endif
        endfunction

        
        function s__Missiles_create takes real x,real y,real z,real toX,real toY,real toZ returns integer
            local integer this= s__Missiles__allocate()
            local real face= Atan2(toY - y, toX - x) * bj_RADTODEG

            call s__Missiles_reset(this)
            call s__Missiles_flushAll(this)
            set s__Missiles_active[this]=false
            set s__Missiles_pins[this]=0
            // Never reset this slot's generation when a lifetime ends.
            set s__Missiles_generation[this]=s__Missiles_generation[this] + 1
            set s__Missiles_origin[this]=s__Missiles___Coordinates_create(x , y , z)
            set s__Missiles_impact[this]=s__Missiles___Coordinates_create(toX , toY , toZ)
            call s__Missiles___Coordinates_link(s__Missiles_origin[this] , s__Missiles_impact[this])
            set s__Missiles_allocated[this]=true
            set s__Missiles_cA[this]=s__Missiles___Coordinates_angle[s__Missiles_origin[this]]
            set s__Missiles_x[this]=x
            set s__Missiles_y[this]=y
            set s__Missiles_z[this]=s__Missiles___Coordinates_z[s__Missiles_origin[this]]
            set s__Missiles_prevX[this]=x
            set s__Missiles_prevY[this]=y
            set s__Missiles_prevZ[this]=s__Missiles___Coordinates_z[s__Missiles_origin[this]]
            set s__Missiles_nextX[this]=x
            set s__Missiles_nextY[this]=y
            set s__Missiles_nextZ[this]=s__Missiles___Coordinates_z[s__Missiles_origin[this]]
            set s__Missiles_toZ[this]=toZ
            set s__Missiles_baseX[this]=x
            set s__Missiles_baseY[this]=y
            set s__Missiles_nextBaseX[this]=x
            set s__Missiles_nextBaseY[this]=y


                set s__Missiles_dummy[this]=GetRecycledDummy(x , y , z , face)



            call Missiles___SetUnitZ(s__Missiles_dummy[this] , s__Missiles___Coordinates_z[s__Missiles_origin[this]])

            return this
        endfunction

    // Minimal B01/B02 plus same-aim R03 candidate. Caller owns pair/observer.
    // Active casts reset pending shots only; latest-aim behavior is deferred.

    function RFBurstPair___LiveOwned takes unit u,player p returns boolean
        return u != null and GetUnitTypeId(u) != 0 and GetWidgetLife(u) > .405 and GetOwningPlayer(u) == p
    endfunction

        // Per-flight snapshots, never references to the current global pair.

        function s__RFBurstPair___RBProjectile_spawn takes unit visible,unit logical,player owning,real x,real y,real endX,real endY,real endZ returns integer
            local integer this= s__RFBurstPair___RBProjectile__allocate(x , y , RFBurstPair___LAUNCH_HEIGHT , endX , endY , endZ)
            set s__RFBurstPair___RBProjectile_savedActor[this]=visible
            set s__RFBurstPair___RBProjectile_savedController[this]=logical
            set s__RFBurstPair___RBProjectile_savedOwner[this]=owning
            set s__RFBurstPair___RBProjectile_spent[this]=false
            set s__Missiles_source[this]=visible
            set s__Missiles_owner[this]=owning
            call s__Missiles__set_speed(this,RFBurstPair___SPEED)
            set s__Missiles_collision[this]=RFBurstPair___HIT_RADIUS
            set s__Missiles_collideZ[this]=false
            call s__Missiles__set_model(this,"Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl")
            return this
        endfunction

        function s__RFBurstPair___RBProjectile_onHit takes integer this,unit hit returns boolean
            if s__RFBurstPair___RBProjectile_spent[this] or not RFBurstPair___LiveOwned(s__RFBurstPair___RBProjectile_savedActor[this] , s__RFBurstPair___RBProjectile_savedOwner[this]) then
                return true
            endif
            if hit == s__RFBurstPair___RBProjectile_savedActor[this] or hit == s__RFBurstPair___RBProjectile_savedController[this] or GetUnitTypeId(hit) == 0 or GetWidgetLife(hit) <= .405 or not IsUnitEnemy(hit, s__RFBurstPair___RBProjectile_savedOwner[this]) then
                return false
            endif
            // Commit termination intent BEFORE native damage dispatch. Damage
            // handlers may dispose/reinitialize the pair or terminate this flight.
            set s__RFBurstPair___RBProjectile_spent[this]=true
            call UnitDamageTarget(s__RFBurstPair___RBProjectile_savedActor[this], hit, 10., true, true, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL, null)
            // No instance/global writes after that external callback boundary.
            return true
        endfunction

        function s__RFBurstPair___RBProjectile_onPeriod takes integer this returns boolean
            return not RFBurstPair___LiveOwned(s__RFBurstPair___RBProjectile_savedActor[this] , s__RFBurstPair___RBProjectile_savedOwner[this])
        endfunction

        function s__RFBurstPair___RBProjectile_onRemove takes integer this returns nothing
            // Core owns allocator/dummy/effect/coordinates and their cleanup.
            set s__RFBurstPair___RBProjectile_savedActor[this]=null
            set s__RFBurstPair___RBProjectile_savedController[this]=null
            set s__RFBurstPair___RBProjectile_savedOwner[this]=null
            set s__RFBurstPair___RBProjectile_spent[this]=true
        endfunction

    // Same callback-scoped ABI as RED. Observe, do not retain recycled IDs.
    function RB_GetShotMissile takes nothing returns integer
        return RFBurstPair___shot
    endfunction

    function RB_GetShotSource takes nothing returns unit
        return RFBurstPair___shotSource
    endfunction

    function RB_GetShotX takes nothing returns real
        return RFBurstPair___shotX
    endfunction

    function RB_GetShotY takes nothing returns real
        return RFBurstPair___shotY
    endfunction

    function RFBurstPair___ClearShot takes nothing returns nothing
        set RFBurstPair___shot=0
        set RFBurstPair___shotSource=null
        set RFBurstPair___shotX=0.
        set RFBurstPair___shotY=0.
    endfunction

    function RFBurstPair___CancelBurst takes nothing returns nothing
        set RFBurstPair___epoch=RFBurstPair___epoch + 1
        set RFBurstPair___remaining=0
        set RFBurstPair___notifying=false
        if RFBurstPair___fireTimer != null then
            call PauseTimer(RFBurstPair___fireTimer)
        endif
        call RFBurstPair___ClearShot()
    endfunction

    function RFBurstPair___PairReady takes nothing returns boolean
        return RFBurstPair___LiveOwned(RFBurstPair___actor , RFBurstPair___pairOwner) and RFBurstPair___LiveOwned(RFBurstPair___controller , RFBurstPair___pairOwner)
    endfunction

    function RFBurstPair___Emit takes nothing returns nothing
        local integer ticket= RFBurstPair___epoch
        local unit visible= RFBurstPair___actor
        local unit logical= RFBurstPair___controller
        local player owning= RFBurstPair___pairOwner
        local trigger listener= RFBurstPair___observer
        local integer m
        local real x
        local real y
        local real endX
        local real endY
        local real absoluteZ
        local real endZ
        if RFBurstPair___remaining <= 0 or RFBurstPair___notifying then
            set visible=null
            set logical=null
            set owning=null
            set listener=null
            return
        endif
        if not (RFBurstPair___LiveOwned(RFBurstPair___actor , RFBurstPair___pairOwner) and RFBurstPair___LiveOwned(RFBurstPair___controller , RFBurstPair___pairOwner)) then // INLINED!!
            call RFBurstPair___CancelBurst()
            set visible=null
            set logical=null
            set owning=null
            set listener=null
            return
        endif
        // Commit all cadence/count state before core creation or observer code.
        set RFBurstPair___remaining=RFBurstPair___remaining - 1
        set RFBurstPair___notifying=true
        if RFBurstPair___remaining == 0 then
            call PauseTimer(RFBurstPair___fireTimer)
        endif
        set x=GetUnitX(visible)
        set y=GetUnitY(visible)
        set endX=x + RFBurstPair___RANGE * Cos(RFBurstPair___heading)
        set endY=y + RFBurstPair___RANGE * Sin(RFBurstPair___heading)
        call MoveLocation(RFBurstPair___terrain, x, y)
        set absoluteZ=GetLocationZ(RFBurstPair___terrain) + RFBurstPair___LAUNCH_HEIGHT
        call MoveLocation(RFBurstPair___terrain, endX, endY)
        // Core constructor arguments are terrain-relative. Keep world Z level
        // rather than accidentally aiming at endpoint terrain+80 on a slope.
        set endZ=absoluteZ - GetLocationZ(RFBurstPair___terrain)
        set m=s__RFBurstPair___RBProjectile_spawn(visible , logical , owning , x , y , endX , endY , endZ)
        if RFBurstPair___epoch != ticket or not RFBurstPair___LiveOwned(visible , owning) then
            call s__Missiles_terminate(m)
            if RFBurstPair___epoch == ticket then
                call RFBurstPair___CancelBurst()
            endif
        else
            call s__Missiles_launch(m)
            set RFBurstPair___shot=m
            set RFBurstPair___shotSource=visible
            set RFBurstPair___shotX=s__Missiles_x[m]
            set RFBurstPair___shotY=s__Missiles_y[m]
            call TriggerEvaluate(listener)
            // A listener can Dispose+Initialize+cast recursively. Never clear
            // views or mutate timers belonging to that newer pair/burst epoch.
            if RFBurstPair___epoch == ticket then
                call RFBurstPair___ClearShot()
                set RFBurstPair___notifying=false
            endif
        endif
        set visible=null
        set logical=null
        set owning=null
        set listener=null
    endfunction

    function RFBurstPair___OnFire takes nothing returns nothing
        if GetExpiredTimer() == RFBurstPair___fireTimer then
            call RFBurstPair___Emit()
        endif
    endfunction

    function RFBurstPair___OnCast takes nothing returns boolean
        if GetTriggerUnit() != RFBurstPair___controller or GetSpellAbilityId() != 'A00G' then
            return false
        endif
        if not (RFBurstPair___LiveOwned(RFBurstPair___actor , RFBurstPair___pairOwner) and RFBurstPair___LiveOwned(RFBurstPair___controller , RFBurstPair___pairOwner)) then // INLINED!!
            call RFBurstPair___CancelBurst()
            return false
        endif
        if RFBurstPair___remaining > 0 then
            // Reset count only: keep the running timer phase and fixed heading.
            set RFBurstPair___remaining=4
            return false
        endif
        if RFBurstPair___notifying then
            // Preserve the idle/final-pulse reentrancy guard.
            return false
        endif
        set RFBurstPair___epoch=RFBurstPair___epoch + 1
        set RFBurstPair___heading=Atan2(GetSpellTargetY() - GetUnitY(RFBurstPair___actor), GetSpellTargetX() - GetUnitX(RFBurstPair___actor))
        set RFBurstPair___remaining=4
        // One reused per-pair timer; phase starts before the immediate pulse.
        call TimerStart(RFBurstPair___fireTimer, RFBurstPair___CADENCE, true, function RFBurstPair___OnFire)
        call RFBurstPair___Emit()
        return false
    endfunction

    function RB_Dispose takes nothing returns nothing
        call RFBurstPair___CancelBurst()
        if RFBurstPair___castHook != null then
            call DestroyTrigger(RFBurstPair___castHook)
        endif
        if RFBurstPair___fireTimer != null then
            call DestroyTimer(RFBurstPair___fireTimer)
        endif
        if RFBurstPair___terrain != null then
            call RemoveLocation(RFBurstPair___terrain)
        endif
        set RFBurstPair___castHook=null
        set RFBurstPair___fireTimer=null
        set RFBurstPair___terrain=null
        set RFBurstPair___observer=null
        set RFBurstPair___actor=null
        set RFBurstPair___controller=null
        set RFBurstPair___pairOwner=null
        // Existing flights keep snapshots; no caller unit/observer destruction.
    endfunction

    function RB_InitializePair takes unit visible,unit logical,trigger shotObserver returns boolean
        if RFBurstPair___castHook != null or RFBurstPair___fireTimer != null or visible == null or logical == null or visible == logical or shotObserver == null then
            return false
        endif
        if GetUnitTypeId(visible) != 'o000' or GetUnitTypeId(logical) != 'o001' or GetUnitAbilityLevel(logical, 'A00G') != 1 then
            return false
        endif
        if not RFBurstPair___LiveOwned(visible , GetOwningPlayer(visible)) or not RFBurstPair___LiveOwned(logical , GetOwningPlayer(visible)) then
            return false
        endif
        set RFBurstPair___epoch=RFBurstPair___epoch + 1
        set RFBurstPair___actor=visible
        set RFBurstPair___controller=logical
        set RFBurstPair___pairOwner=GetOwningPlayer(visible)
        set RFBurstPair___observer=shotObserver
        set RFBurstPair___remaining=0
        set RFBurstPair___notifying=false
        call RFBurstPair___ClearShot()
        set RFBurstPair___terrain=Location(0., 0.)
        set RFBurstPair___fireTimer=CreateTimer()
        set RFBurstPair___castHook=CreateTrigger()
        call TriggerRegisterUnitEvent(RFBurstPair___castHook, RFBurstPair___controller, EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(RFBurstPair___castHook, Condition(function RFBurstPair___OnCast))
        return true
    endfunction


    function RFBurstAimTest__Pose takes unit u returns string
        return "type=" + I2S(GetUnitTypeId(u)) + " xy=" + R2S(GetUnitX(u)) + "," + R2S(GetUnitY(u)) + " facing=" + R2S(GetUnitFacing(u)) + " order=" + I2S(GetUnitCurrentOrder(u)) + " hp=" + R2S(GetWidgetLife(u))
    endfunction

    function RFBurstAimTest__ClearScene takes nothing returns nothing
        call RB_Dispose()
        if RFBurstAimTest__spellHook != null then
            call DestroyTrigger(RFBurstAimTest__spellHook)
            call DestroyTrigger(RFBurstAimTest__damageHook)
            call DestroyTrigger(RFBurstAimTest__shotHook)
        endif
        set RFBurstAimTest__spellHook=null
        set RFBurstAimTest__damageHook=null
        set RFBurstAimTest__shotHook=null
        if GetUnitTypeId(RFBurstAimTest__actor) != 0 then
            call RemoveUnit(RFBurstAimTest__actor)
        endif
        if GetUnitTypeId(RFBurstAimTest__caster) != 0 then
            call RemoveUnit(RFBurstAimTest__caster)
        endif
        if GetUnitTypeId(RFBurstAimTest__target) != 0 then
            call RemoveUnit(RFBurstAimTest__target)
        endif
        if GetUnitTypeId(RFBurstAimTest__control) != 0 then
            call RemoveUnit(RFBurstAimTest__control)
        endif
        if GetUnitTypeId(RFBurstAimTest__northTarget) != 0 then
            call RemoveUnit(RFBurstAimTest__northTarget)
        endif
        if GetUnitTypeId(RFBurstAimTest__northControl) != 0 then
            call RemoveUnit(RFBurstAimTest__northControl)
        endif
        // Keep removed unit references until next-tick native clearance checks.
    endfunction

    function RFBurstAimTest__ReleaseSceneRefs takes nothing returns nothing
        set RFBurstAimTest__actor=null
        set RFBurstAimTest__caster=null
        set RFBurstAimTest__target=null
        set RFBurstAimTest__control=null
        set RFBurstAimTest__northTarget=null
        set RFBurstAimTest__northControl=null
        set RFBurstAimTest__firstFlight=0
        set RFBurstAimTest__firstDummy=null
        set RFBurstAimTest__firstSource=null
    endfunction

    function RFBurstAimTest__Finish takes nothing returns nothing
        if RFBurstAimTest__done then
            return
        endif
        set RFBurstAimTest__done=true
        call PauseTimer(RFBurstAimTest__runner)
        call PauseTimer(RFBurstAimTest__clock)
        call RFBurstAimTest__ClearScene()
        call RFBurstAimTest__ReleaseSceneRefs()
        call RemoveLocation(RFBurstAimTest__groundProbe)
        call DestroyGroup(RFBurstAimTest__corridorUnits)
        call RemoveRect(RFBurstAimTest__corridorRect)
        set RFBurstAimTest__groundProbe=null
        set RFBurstAimTest__corridorUnits=null
        set RFBurstAimTest__corridorRect=null
        call DestroyTimer(RFBurstAimTest__runner)
        call DestroyTimer(RFBurstAimTest__clock)
        set RFBurstAimTest__runner=null
        set RFBurstAimTest__clock=null
        call RB_LogComplete()
    endfunction

    function RFBurstAimTest__Abort takes string why returns nothing
        call RB_LogRecord("FAIL" , "ABORT-fixture" , why)
        call RFBurstAimTest__Finish()
    endfunction

    function RFBurstAimTest__Deadline takes nothing returns nothing
        call RFBurstAimTest__Abort("global 25 game-second deadline; remaining assertions unreached")
    endfunction

    function RFBurstAimTest__FirstLive takes nothing returns boolean
        return RFBurstAimTest__firstFlight != 0 and s__Missiles_allocated[RFBurstAimTest__firstFlight] and s__Missiles_launched[RFBurstAimTest__firstFlight] and s__Missiles_dummy[RFBurstAimTest__firstFlight] == RFBurstAimTest__firstDummy and GetUnitTypeId(RFBurstAimTest__firstDummy) != 0 and s__Missiles_source[RFBurstAimTest__firstFlight] == RFBurstAimTest__firstSource and RFBurstAimTest__firstSource == RFBurstAimTest__actor
    endfunction

    function RFBurstAimTest__AimDamage takes real amount returns boolean
        local real now= TimerGetElapsed(RFBurstAimTest__clock)
        local unit victim= GetTriggerUnit()
        if victim == RFBurstAimTest__control or victim == RFBurstAimTest__northControl then
            set RFBurstAimTest__controlHits=RFBurstAimTest__controlHits + 1
        elseif RFBurstAimTest__phase == 1 and victim == RFBurstAimTest__target then
            set RFBurstAimTest__calibrationHits=RFBurstAimTest__calibrationHits + 1
            set RFBurstAimTest__calibrationDamage=amount
            set RFBurstAimTest__calibrationSource=GetEventDamageSource() == RFBurstAimTest__actor
        elseif RFBurstAimTest__phase == 2 and victim == RFBurstAimTest__northTarget then
            set RFBurstAimTest__northCalibrationHits=RFBurstAimTest__northCalibrationHits + 1
            set RFBurstAimTest__northCalibrationDamage=amount
            set RFBurstAimTest__northCalibrationSource=GetEventDamageSource() == RFBurstAimTest__actor
        elseif RFBurstAimTest__phase >= 4 and ( victim == RFBurstAimTest__target or victim == RFBurstAimTest__northTarget ) then
            set RFBurstAimTest__hits=RFBurstAimTest__hits + 1
            set RFBurstAimTest__hitValuesOK=RFBurstAimTest__hitValuesOK and RAbsBJ(amount - 10.) <= .01
            set RFBurstAimTest__hitSourcesOK=RFBurstAimTest__hitSourcesOK and GetEventDamageSource() == RFBurstAimTest__actor
            if victim == RFBurstAimTest__target then
                set RFBurstAimTest__eastHits=RFBurstAimTest__eastHits + 1
                if RFBurstAimTest__eastHits == 1 then
                    set RFBurstAimTest__firstEastTime=now
                    set RFBurstAimTest__firstEastShots=RFBurstAimTest__shots
                    set RFBurstAimTest__firstEastBeforeSecond=RFBurstAimTest__shots == 1 and RFBurstAimTest__northHits == 0 and now < RFBurstAimTest__shotTime[1] + .25 and RAbsBJ(amount - 10.) <= .01 and GetEventDamageSource() == RFBurstAimTest__actor
                endif
            else
                set RFBurstAimTest__northHits=RFBurstAimTest__northHits + 1
                if RFBurstAimTest__shots == 1 then
                    set RFBurstAimTest__northBeforeSecond=true
                endif
            endif
            if RFBurstAimTest__hits <= 8 then
                call RB_LogRecord("OBS" , "aim-native-damage" , "time=" + R2S(now) + " victim=" + I2S(GetHandleId(victim)) + " east=" + I2S(RFBurstAimTest__eastHits) + " north=" + I2S(RFBurstAimTest__northHits) + " value=" + R2S(amount) + " source=" + I2S(GetHandleId(GetEventDamageSource())) + " actor=" + I2S(GetHandleId(RFBurstAimTest__actor)) + " shots=" + I2S(RFBurstAimTest__shots))
            endif
        endif
        set victim=null
        return false
    endfunction

    function RFBurstAimTest__AimShot takes nothing returns boolean
        local integer m= (RFBurstPair___shot) // INLINED!!
        local boolean valid= false
        local real distance
        set RFBurstAimTest__shots=RFBurstAimTest__shots + 1
        if m != 0 then
            set valid=s__Missiles_allocated[m] and s__Missiles_launched[m] and s__Missiles_dummy[m] != null
            set valid=valid and GetUnitTypeId(s__Missiles_dummy[m]) != 0 and s__Missiles_dummy[m] != RFBurstAimTest__actor and s__Missiles_dummy[m] != RFBurstAimTest__caster
            set valid=valid and s__Missiles_source[m] == RFBurstAimTest__actor and (RFBurstPair___shotSource) == RFBurstAimTest__actor // INLINED!!
            set valid=valid and RAbsBJ(s__Missiles_x[m] - GetUnitX(RFBurstAimTest__actor)) <= 1. and RAbsBJ(s__Missiles_y[m] - GetUnitY(RFBurstAimTest__actor)) <= 1.
            set valid=valid and RAbsBJ((RFBurstPair___shotX) - s__Missiles_x[m]) <= .01 and RAbsBJ((RFBurstPair___shotY) - s__Missiles_y[m]) <= .01 // INLINED!!
        endif
        set RFBurstAimTest__projectilesOK=RFBurstAimTest__projectilesOK and valid and RFBurstAimTest__phase == 5
        if RFBurstAimTest__shots <= 8 then
            set RFBurstAimTest__shotTime[RFBurstAimTest__shots]=TimerGetElapsed(RFBurstAimTest__clock)
            call RB_LogRecord("OBS" , "aim-public-SHOT" , "index=" + I2S(RFBurstAimTest__shots) + " time=" + R2S(RFBurstAimTest__shotTime[RFBurstAimTest__shots]) + " missile=" + I2S(m) + " source=" + I2S(GetHandleId((RFBurstPair___shotSource)))) // INLINED!!
        endif
        if RFBurstAimTest__shots == 1 then
            if not RFBurstAimTest__projectilesOK then
                set RFBurstAimTest__phase=- 1
            else
                // Borrowed ID is examined ONLY while there is still one shot
                // and no impact. No private generation/angle getter is assumed.
                set RFBurstAimTest__firstFlight=m
                set RFBurstAimTest__firstDummy=s__Missiles_dummy[m]
                set RFBurstAimTest__firstSource=s__Missiles_source[m]
                set RFBurstAimTest__firstOriginX=(RFBurstPair___shotX) // INLINED!!
                set RFBurstAimTest__firstOriginY=(RFBurstPair___shotY) // INLINED!!
                set RFBurstAimTest__firstInitialX=s__Missiles_x[m]
                set RFBurstAimTest__firstInitialY=s__Missiles_y[m]
                set RFBurstAimTest__eastDX=GetUnitX(RFBurstAimTest__target) - RFBurstAimTest__firstOriginX
                set RFBurstAimTest__eastDY=GetUnitY(RFBurstAimTest__target) - RFBurstAimTest__firstOriginY
                set distance=SquareRoot(RFBurstAimTest__eastDX * RFBurstAimTest__eastDX + RFBurstAimTest__eastDY * RFBurstAimTest__eastDY)
                set RFBurstAimTest__eastDX=RFBurstAimTest__eastDX / distance
                set RFBurstAimTest__eastDY=RFBurstAimTest__eastDY / distance
                set RFBurstAimTest__recastDue=RFBurstAimTest__shotTime[1] + .0625
                set RFBurstAimTest__pendingRecast=true
                call RB_LogRecord("OBS" , "first-flight-borrowed" , "origin=" + R2S(RFBurstAimTest__firstOriginX) + "," + R2S(RFBurstAimTest__firstOriginY) + " initial=" + R2S(RFBurstAimTest__firstInitialX) + "," + R2S(RFBurstAimTest__firstInitialY) + " dummy=" + I2S(GetHandleId(RFBurstAimTest__firstDummy)) + " source=" + I2S(GetHandleId(RFBurstAimTest__firstSource)))
            endif
        elseif RFBurstAimTest__recastRequested and TimerGetElapsed(RFBurstAimTest__clock) < RFBurstAimTest__shotTime[1] + .25 - .0001 then
            set RFBurstAimTest__earlyPulse=true
        endif
        return false
    endfunction

    function RFBurstAimTest__AimSpell takes nothing returns boolean
        local real now= TimerGetElapsed(RFBurstAimTest__clock)
        set RFBurstAimTest__castEvents=RFBurstAimTest__castEvents + 1
        call RB_LogRecord("OBS" , "aim-native-effect" , "event=" + I2S(RFBurstAimTest__castEvents) + " time=" + R2S(now) + " shots=" + I2S(RFBurstAimTest__shots) + " ability=" + I2S(GetSpellAbilityId()) + " source=" + I2S(GetHandleId(GetTriggerUnit())) + " xy=" + R2S(GetSpellTargetX()) + "," + R2S(GetSpellTargetY()))
        if GetTriggerUnit() != RFBurstAimTest__caster or GetSpellAbilityId() != 'A00G' or RAbsBJ(GetSpellTargetX() - RFBurstAimTest__aimX) > .01 or RAbsBJ(GetSpellTargetY() - RFBurstAimTest__aimY) > .01 then
            set RFBurstAimTest__phase=- 1
        elseif RFBurstAimTest__phase == 4 and RFBurstAimTest__expectedCast == 1 and RFBurstAimTest__castEvents == 1 then
            set RFBurstAimTest__expectedCast=0
            set RFBurstAimTest__castTime=now
            set RFBurstAimTest__targetStart=GetWidgetLife(RFBurstAimTest__target)
            set RFBurstAimTest__controlStart=GetWidgetLife(RFBurstAimTest__control)
            set RFBurstAimTest__northStart=GetWidgetLife(RFBurstAimTest__northTarget)
            set RFBurstAimTest__northControlStart=GetWidgetLife(RFBurstAimTest__northControl)
            set RFBurstAimTest__phase=5
            call RB_LogRecord("OBS" , "aim-first-effect-latency" , "issue=" + R2S(RFBurstAimTest__orderTime) + " effect=" + R2S(now) + " latency=" + R2S(now - RFBurstAimTest__orderTime))
        elseif RFBurstAimTest__phase == 5 and RFBurstAimTest__expectedCast == 2 and RFBurstAimTest__castEvents == 2 then
            set RFBurstAimTest__expectedCast=0
            set RFBurstAimTest__recastEffect=now
            set RFBurstAimTest__recastEffectShots=RFBurstAimTest__shots
            if RFBurstAimTest__shots != 1 or RFBurstAimTest__hits != 0 or now < RFBurstAimTest__recastIssue or now >= RFBurstAimTest__shotTime[1] + .25 or not (RFBurstAimTest__firstFlight != 0 and s__Missiles_allocated[RFBurstAimTest__firstFlight] and s__Missiles_launched[RFBurstAimTest__firstFlight] and s__Missiles_dummy[RFBurstAimTest__firstFlight] == RFBurstAimTest__firstDummy and GetUnitTypeId(RFBurstAimTest__firstDummy) != 0 and s__Missiles_source[RFBurstAimTest__firstFlight] == RFBurstAimTest__firstSource and RFBurstAimTest__firstSource == RFBurstAimTest__actor) then // INLINED!!
                set RFBurstAimTest__phase=- 1
            else
                set RFBurstAimTest__recastQualified=true
                call RB_LogRecord("OBS" , "aim-second-effect-qualified" , "first=" + R2S(RFBurstAimTest__shotTime[1]) + " due=" + R2S(RFBurstAimTest__recastDue) + " issue=" + R2S(RFBurstAimTest__recastIssue) + " effect=" + R2S(now) + " latency=" + R2S(now - RFBurstAimTest__recastIssue) + " oldFlightXY=" + R2S(s__Missiles_x[RFBurstAimTest__firstFlight]) + "," + R2S(s__Missiles_y[RFBurstAimTest__firstFlight]) + " shots=1 hits=0")
            endif
        else
            set RFBurstAimTest__phase=- 1
        endif
        return false
    endfunction

    function RFBurstAimTest__OnDamage takes nothing returns boolean
        local real amount= GetEventDamage()
        if RFBurstAimTest__aimCase then
            return RFBurstAimTest__AimDamage(amount)
        endif
        if GetTriggerUnit() == RFBurstAimTest__control then
            set RFBurstAimTest__controlHits=RFBurstAimTest__controlHits + 1
        elseif GetTriggerUnit() == RFBurstAimTest__target then
            if RFBurstAimTest__phase == 1 then
                set RFBurstAimTest__calibrationHits=RFBurstAimTest__calibrationHits + 1
                set RFBurstAimTest__calibrationDamage=amount
                set RFBurstAimTest__calibrationSource=GetEventDamageSource() == RFBurstAimTest__actor
            elseif RFBurstAimTest__phase >= 4 then
                set RFBurstAimTest__hits=RFBurstAimTest__hits + 1
                set RFBurstAimTest__hitValuesOK=RFBurstAimTest__hitValuesOK and RAbsBJ(amount - 10.) <= .01
                set RFBurstAimTest__hitSourcesOK=RFBurstAimTest__hitSourcesOK and GetEventDamageSource() == RFBurstAimTest__actor
                if RFBurstAimTest__hits <= 8 then
                    call RB_LogRecord("OBS" , "native-damage" , "time=" + R2S(TimerGetElapsed(RFBurstAimTest__clock)) + " value=" + R2S(amount) + " source=" + I2S(GetHandleId(GetEventDamageSource())) + " visible=" + I2S(GetHandleId(RFBurstAimTest__actor)))
                endif
            endif
        endif
        return false
    endfunction

    function RFBurstAimTest__OnShot takes nothing returns boolean
        local integer m= (RFBurstPair___shot) // INLINED!!
        local boolean valid= false
        if RFBurstAimTest__aimCase then
            return RFBurstAimTest__AimShot()
        endif
        set RFBurstAimTest__shots=RFBurstAimTest__shots + 1
        // Public diagnostic pulse alone is NOT evidence of a real projectile.
        if m != 0 then
            set valid=s__Missiles_allocated[m] and s__Missiles_launched[m] and s__Missiles_dummy[m] != null
            set valid=valid and GetUnitTypeId(s__Missiles_dummy[m]) != 0 and s__Missiles_dummy[m] != RFBurstAimTest__actor and s__Missiles_dummy[m] != RFBurstAimTest__caster
            set valid=valid and s__Missiles_source[m] == RFBurstAimTest__actor and (RFBurstPair___shotSource) == RFBurstAimTest__actor // INLINED!!
            set valid=valid and RAbsBJ(s__Missiles_x[m] - GetUnitX(RFBurstAimTest__actor)) <= 1. and RAbsBJ(s__Missiles_y[m] - GetUnitY(RFBurstAimTest__actor)) <= 1.
            set valid=valid and RAbsBJ((RFBurstPair___shotX) - s__Missiles_x[m]) <= .01 and RAbsBJ((RFBurstPair___shotY) - s__Missiles_y[m]) <= .01 // INLINED!!
        endif
        set RFBurstAimTest__projectilesOK=RFBurstAimTest__projectilesOK and valid and RFBurstAimTest__phase == 5
        if RFBurstAimTest__shots <= 8 then
            set RFBurstAimTest__shotTime[RFBurstAimTest__shots]=TimerGetElapsed(RFBurstAimTest__clock)
            call RB_LogRecord("OBS" , "SHOT-public-pulse" , "index=" + I2S(RFBurstAimTest__shots) + " time=" + R2S(RFBurstAimTest__shotTime[RFBurstAimTest__shots]) + " missile=" + I2S(m) + " source=" + I2S(GetHandleId((RFBurstPair___shotSource)))) // INLINED!!
        endif
        if RFBurstAimTest__recastCase and RFBurstAimTest__shots == 2 then
            if not RFBurstAimTest__projectilesOK then
                set RFBurstAimTest__phase=- 1
            else
                set RFBurstAimTest__recastDue=RFBurstAimTest__shotTime[2] + .125
                set RFBurstAimTest__pendingRecast=true
            endif
        endif
        if RFBurstAimTest__recastCase and RFBurstAimTest__recastRequested and RFBurstAimTest__shots > 2 and TimerGetElapsed(RFBurstAimTest__clock) < RFBurstAimTest__shotTime[2] + .25 - .0001 then
            set RFBurstAimTest__earlyPulse=true
        endif
        return false
    endfunction

    function RFBurstAimTest__OnSpell takes nothing returns boolean
        local real now= TimerGetElapsed(RFBurstAimTest__clock)
        if RFBurstAimTest__aimCase then
            return RFBurstAimTest__AimSpell()
        endif
        set RFBurstAimTest__castEvents=RFBurstAimTest__castEvents + 1
        call RB_LogRecord("OBS" , "native-spell-effect" , "event=" + I2S(RFBurstAimTest__castEvents) + " time=" + R2S(now) + " shots=" + I2S(RFBurstAimTest__shots) + " ability=" + I2S(GetSpellAbilityId()) + " source=" + I2S(GetHandleId(GetTriggerUnit())) + " xy=" + R2S(GetSpellTargetX()) + "," + R2S(GetSpellTargetY()))
        if GetTriggerUnit() != RFBurstAimTest__caster or GetSpellAbilityId() != 'A00G' or RAbsBJ(GetSpellTargetX() - RFBurstAimTest__aimX) > .01 or RAbsBJ(GetSpellTargetY() - RFBurstAimTest__aimY) > .01 then
            set RFBurstAimTest__phase=- 1
        elseif RFBurstAimTest__expectedCast == 1 and RFBurstAimTest__castEvents == 1 and RFBurstAimTest__phase == 4 then
            set RFBurstAimTest__expectedCast=0
            set RFBurstAimTest__castTime=now
            set RFBurstAimTest__targetStart=GetWidgetLife(RFBurstAimTest__target)
            set RFBurstAimTest__controlStart=GetWidgetLife(RFBurstAimTest__control)
            set RFBurstAimTest__phase=5
            call RB_LogRecord("OBS" , "first-native-effect-latency" , "issue=" + R2S(RFBurstAimTest__orderTime) + " effect=" + R2S(now) + " latency=" + R2S(now - RFBurstAimTest__orderTime))
        elseif RFBurstAimTest__recastCase and RFBurstAimTest__expectedCast == 2 and RFBurstAimTest__castEvents == 2 and RFBurstAimTest__phase == 5 then
            set RFBurstAimTest__expectedCast=0
            set RFBurstAimTest__recastEffect=now
            set RFBurstAimTest__recastEffectShots=RFBurstAimTest__shots
            call RB_LogRecord("OBS" , "second-native-effect-latency" , "secondShot=" + R2S(RFBurstAimTest__shotTime[2]) + " due=" + R2S(RFBurstAimTest__recastDue) + " issue=" + R2S(RFBurstAimTest__recastIssue) + " effect=" + R2S(now) + " latency=" + R2S(now - RFBurstAimTest__recastIssue) + " shots=" + I2S(RFBurstAimTest__shots))
            if RFBurstAimTest__shots != 2 or now >= RFBurstAimTest__shotTime[2] + .25 or now < RFBurstAimTest__recastIssue then
                set RFBurstAimTest__phase=- 1
            else
                set RFBurstAimTest__recastQualified=true
            endif
        else
            // Cleanup is deferred outside native callback/shot dispatch.
            set RFBurstAimTest__phase=- 1
        endif
        return false
    endfunction

    function RFBurstAimTest__At takes unit u,real x,real y returns boolean
        return GetUnitTypeId(u) != 0 and RAbsBJ(GetUnitX(u) - x) <= 1. and RAbsBJ(GetUnitY(u) - y) <= 1.
    endfunction

    function RFBurstAimTest__BodyReady takes unit u returns boolean
        return GetUnitTypeId(u) == 'o000' and GetWidgetLife(u) > 100. and GetUnitAbilityLevel(u, 'A00G') == 0 and GetUnitAbilityLevel(u, 'Ablo') == 0
    endfunction

    function RFBurstAimTest__SceneReady takes nothing returns boolean
        local integer i= 0
        local real x
        // Placement gates ONLY. Spawn success is not walkability/transit proof.
        if not RFBurstAimTest__At(RFBurstAimTest__actor , - 2223.5 , 4352.) or not RFBurstAimTest__At(RFBurstAimTest__caster , - 5500. , - 5500.) or not RFBurstAimTest__At(RFBurstAimTest__target , - 1967.5 , 4352.) or not RFBurstAimTest__At(RFBurstAimTest__control , - 1967.5 , 4864.) then
            return false
        endif
        if not RFBurstAimTest__BodyReady(RFBurstAimTest__actor) or not RFBurstAimTest__BodyReady(RFBurstAimTest__target) or not RFBurstAimTest__BodyReady(RFBurstAimTest__control) or GetUnitTypeId(RFBurstAimTest__caster) != 'o001' then
            return false
        endif
        if GetUnitAbilityLevel(RFBurstAimTest__caster, 'A00G') != 1 or GetUnitAbilityLevel(RFBurstAimTest__caster, 'Ablo') != 0 or IsUnitPaused(RFBurstAimTest__actor) or IsUnitPaused(RFBurstAimTest__caster) then
            return false
        endif
        if not IsUnitEnemy(RFBurstAimTest__target, Player(0)) or not IsUnitEnemy(RFBurstAimTest__control, Player(0)) or not IsUnitEnemy(RFBurstAimTest__actor, Player(1)) then
            return false
        endif
        if GetOwningPlayer(RFBurstAimTest__target) != Player(1) or GetOwningPlayer(RFBurstAimTest__control) != Player(1) or not IsUnitPaused(RFBurstAimTest__target) or not IsUnitPaused(RFBurstAimTest__control) then
            return false
        endif
        if RAbsBJ(GetUnitFacing(RFBurstAimTest__actor)) > .01 or GetUnitCurrentOrder(RFBurstAimTest__actor) != 0 or GetWidgetLife(RFBurstAimTest__caster) <= 0.405 then
            return false
        endif
        loop
            exitwhen i > 8
            set x=GetUnitX(RFBurstAimTest__actor) + ( GetUnitX(RFBurstAimTest__target) - GetUnitX(RFBurstAimTest__actor) ) * I2R(i) / 8.
            if IsTerrainPathable(x, GetUnitY(RFBurstAimTest__actor), PATHING_TYPE_WALKABILITY) then
                return false
            endif
            set i=i + 1
        endloop
        return not IsTerrainPathable(GetUnitX(RFBurstAimTest__control), GetUnitY(RFBurstAimTest__control), PATHING_TYPE_WALKABILITY)
    endfunction

    function RFBurstAimTest__HasFlights takes unit sourceUnit returns boolean
        local integer i= 0
        local integer m
        if s__Missiles_count >= 32 then
            return true
        endif
        loop
            exitwhen i > s__Missiles_count
            set m=s__Missiles_collection[i]
            if s__Missiles_allocated[m] and s__Missiles_source[m] == sourceUnit then
                return true
            endif
            set i=i + 1
        endloop
        return false
    endfunction

    function RFBurstAimTest__RemovedAbsent takes nothing returns boolean
        local group g= CreateGroup()
        local unit u
        local integer fixtureIndex= 0
        local integer seen= 0
        local boolean ok= GetUnitTypeId(RFBurstAimTest__actor) == 0 and GetUnitTypeId(RFBurstAimTest__caster) == 0 and GetUnitTypeId(RFBurstAimTest__target) == 0 and GetUnitTypeId(RFBurstAimTest__control) == 0
        loop
            exitwhen fixtureIndex == 2 or not ok
            if fixtureIndex == 0 then
                call GroupEnumUnitsInRange(g, - 2223.5, 4352., 1024., null)
            else
                call GroupEnumUnitsInRange(g, - 5500., - 5500., 128., null)
            endif
            loop
                set u=FirstOfGroup(g)
                exitwhen u == null or not ok
                set seen=seen + 1
                set ok=seen <= 128 and u != RFBurstAimTest__actor and u != RFBurstAimTest__caster and u != RFBurstAimTest__target and u != RFBurstAimTest__control
                call GroupRemoveUnit(g, u)
            endloop
            set fixtureIndex=fixtureIndex + 1
        endloop
        call DestroyGroup(g)
        set g=null
        set u=null
        return ok
    endfunction

    function RFBurstAimTest__CompleteRegression takes nothing returns nothing
        call RB_LogCase("R03-active-recast-reset-and-cadence")
        if RFBurstAimTest__HasFlights(RFBurstAimTest__actor) then
            call RFBurstAimTest__Abort("prior actor still has public allocated flights after3s; no fresh-case admission")
            return
        endif
        call RB_LogCheck(true , "prior-flights-clear" , "public core collection has no allocated flight from prior actor")
        call RFBurstAimTest__ClearScene()
        set RFBurstAimTest__phase=6
    endfunction

    function RFBurstAimTest__Assess takes nothing returns nothing
        local real targetEnd= GetWidgetLife(RFBurstAimTest__target)
        local real controlEnd= GetWidgetLife(RFBurstAimTest__control)
        local real differential= ( controlEnd - RFBurstAimTest__controlStart ) - ( targetEnd - RFBurstAimTest__targetStart )
        local integer i= 2
        call RB_LogRecord("OBS" , "actor-end" , RFBurstAimTest__Pose(RFBurstAimTest__actor))
        call RB_LogRecord("OBS" , "target-control-HP" , "target=" + R2S(RFBurstAimTest__targetStart) + "->" + R2S(targetEnd) + " control=" + R2S(RFBurstAimTest__controlStart) + "->" + R2S(controlEnd) + " differential=" + R2S(differential))
        call RB_LogCheck(RFBurstAimTest__shots == 4 , "four-shot-notifications" , "actual=" + I2S(RFBurstAimTest__shots) + " expected=4")
        call RB_LogCheck(RFBurstAimTest__shots == 4 and RFBurstAimTest__projectilesOK , "four-real-public-projectiles" , "live launched Missiles, separate native dummy, visible source and actual actor origin required at each pulse")
        call RB_LogCheck(RFBurstAimTest__hits == 4 , "four-native-hits" , "actual=" + I2S(RFBurstAimTest__hits) + " expected=4")
        call RB_LogCheck(RFBurstAimTest__hits == 4 and RFBurstAimTest__hitValuesOK , "native-ten-per-hit" , "each GetEventDamage must be10 tolerance=.01; no calibration events counted")
        call RB_LogCheck(RFBurstAimTest__hits == 4 and RFBurstAimTest__hitSourcesOK , "visible-damage-source" , "each GetEventDamageSource must equal visible actor, not logical caster")
        call RB_LogCheck(RAbsBJ(differential - 40.) <= RFBurstAimTest__HP_TOLERANCE , "native-HP-differential40" , "actual=" + R2S(differential) + " tolerance=.10; same-type paired regen control")
        call RB_LogCheck(RFBurstAimTest__controlHits == 0 , "control-undamaged" , "actual=" + I2S(RFBurstAimTest__controlHits))
        call RB_LogCheck(targetEnd > .405 and controlEnd > .405 , "targets-survive" , "target=" + R2S(targetEnd) + " control=" + R2S(controlEnd))
        call RB_LogCase("B02-default-cadence")
        if RFBurstAimTest__shots != 4 then
            call RB_LogRecord("FAIL" , "missing-cadence-observations" , "need4 actual shot pulses/3 adjacent intervals; actual=" + I2S(RFBurstAimTest__shots))
        else
            loop
                exitwhen i > 4
                call RB_LogCheck(RAbsBJ(( RFBurstAimTest__shotTime[i] - RFBurstAimTest__shotTime[i - 1] ) - .25) <= RFBurstAimTest__CADENCE_TOLERANCE , "cadence-interval" + I2S(i - 1) , "actual=" + R2S(RFBurstAimTest__shotTime[i] - RFBurstAimTest__shotTime[i - 1]) + " expected=.25 tolerance=.03125")
                set i=i + 1
            endloop
        endif
        call RFBurstAimTest__CompleteRegression()
    endfunction

    function RFBurstAimTest__BeginAim takes nothing returns nothing
        call RB_LogCase("R04-new-aim-future-shots")
        if RFBurstAimTest__HasFlights(RFBurstAimTest__actor) then
            call RFBurstAimTest__Abort("prior R03 actor has allocated flights after observation; aim scene unavailable")
            return
        endif
        call RB_LogCheck(true , "prior-R03-flights-clear" , "public core source-flight absence before disposal")
        call RFBurstAimTest__ClearScene()
        set RFBurstAimTest__phase=7
    endfunction

    function RFBurstAimTest__AssessRecast takes nothing returns nothing
        local real targetEnd= GetWidgetLife(RFBurstAimTest__target)
        local real controlEnd= GetWidgetLife(RFBurstAimTest__control)
        local real differential= ( controlEnd - RFBurstAimTest__controlStart ) - ( targetEnd - RFBurstAimTest__targetStart )
        local integer i= 2
        call RB_LogRecord("OBS" , "actor-end" , RFBurstAimTest__Pose(RFBurstAimTest__actor))
        call RB_LogRecord("OBS" , "recast-target-control-HP" , "shots=" + I2S(RFBurstAimTest__shots) + " hits=" + I2S(RFBurstAimTest__hits) + " target=" + R2S(RFBurstAimTest__targetStart) + "->" + R2S(targetEnd) + " control=" + R2S(RFBurstAimTest__controlStart) + "->" + R2S(controlEnd) + " differential=" + R2S(differential))
        call RB_LogCheck(RFBurstAimTest__recastQualified and RFBurstAimTest__castEvents == 2 and RFBurstAimTest__recastEffectShots == 2 , "native-active-window-ready" , "exact second source/A00G/point effect at observed shot2 and before shot2+.25")
        call RB_LogCheck(RFBurstAimTest__shots == 6 , "reset-to-four-not-add-or-ignore" , "actual=" + I2S(RFBurstAimTest__shots) + " expected=6; ignore gives4/add gives8")
        call RB_LogCheck(RFBurstAimTest__shots == 6 and RFBurstAimTest__projectilesOK , "six-real-public-projectiles" , "live launched core missiles/separate dummy/source/current actor origin required")
        call RB_LogCheck(RFBurstAimTest__hits == 6 , "six-native-hits" , "actual=" + I2S(RFBurstAimTest__hits) + " expected=6")
        call RB_LogCheck(RFBurstAimTest__hits == 6 and RFBurstAimTest__hitValuesOK , "native-ten-per-hit" , "six real target UNIT_DAMAGED values10 tolerance=.01")
        call RB_LogCheck(RFBurstAimTest__hits == 6 and RFBurstAimTest__hitSourcesOK , "visible-damage-source" , "all6 GetEventDamageSource equal visible actor")
        call RB_LogCheck(RAbsBJ(differential - 60.) <= RFBurstAimTest__HP_TOLERANCE , "native-HP-differential60" , "actual=" + R2S(differential) + " tolerance=.10; same-type paired regen control")
        call RB_LogCheck(RFBurstAimTest__controlHits == 0 , "control-undamaged" , "actual=" + I2S(RFBurstAimTest__controlHits))
        call RB_LogCheck(targetEnd > .405 and controlEnd > .405 , "targets-survive" , "target=" + R2S(targetEnd) + " control=" + R2S(controlEnd))
        call RB_LogCheck(not RFBurstAimTest__earlyPulse , "no-extra-immediate-recast-shot" , "no observed post-recast pulse before secondShot+.25 (float epsilon .0001)")
        loop
            exitwhen i > 6
            if i <= RFBurstAimTest__shots then
                call RB_LogCheck(RAbsBJ(( RFBurstAimTest__shotTime[i] - RFBurstAimTest__shotTime[i - 1] ) - .25) <= RFBurstAimTest__CADENCE_TOLERANCE , "recast-cadence-interval" + I2S(i - 1) , "actual=" + R2S(RFBurstAimTest__shotTime[i] - RFBurstAimTest__shotTime[i - 1]) + " expected=.25 tolerance=.03125")
            else
                call RB_LogRecord("FAIL" , "missing-recast-cadence-interval" + I2S(i - 1) , "need6 real shots/5 adjacent intervals; actual shots=" + I2S(RFBurstAimTest__shots))
            endif
            set i=i + 1
        endloop
        call RFBurstAimTest__BeginAim()
    endfunction

    function RFBurstAimTest__ResetObservations takes nothing returns nothing
        set RFBurstAimTest__phase=0
        set RFBurstAimTest__calibrated=false
        set RFBurstAimTest__calibrationHits=0
        set RFBurstAimTest__calibrationHP=0.
        set RFBurstAimTest__calibrationDamage=0.
        set RFBurstAimTest__calibrationSource=false
        set RFBurstAimTest__controlHits=0
        set RFBurstAimTest__hits=0
        set RFBurstAimTest__hitValuesOK=true
        set RFBurstAimTest__hitSourcesOK=true
        set RFBurstAimTest__shots=0
        set RFBurstAimTest__projectilesOK=true
        set RFBurstAimTest__castEvents=0
        set RFBurstAimTest__orderTime=0.
        set RFBurstAimTest__castTime=0.
        set RFBurstAimTest__targetStart=0.
        set RFBurstAimTest__controlStart=0.
        set RFBurstAimTest__expectedCast=0
        set RFBurstAimTest__pendingRecast=false
        set RFBurstAimTest__recastRequested=false
        set RFBurstAimTest__recastQualified=false
        set RFBurstAimTest__earlyPulse=false
        set RFBurstAimTest__recastDue=0.
        set RFBurstAimTest__recastIssue=0.
        set RFBurstAimTest__recastEffect=0.
        set RFBurstAimTest__recastEffectShots=0
    endfunction

    function RFBurstAimTest__SpawnScene takes nothing returns nothing
        call RFBurstAimTest__ResetObservations()
        set RFBurstAimTest__actor=CreateUnit(Player(0), 'o000', - 2223.5, 4352., 0.)
        set RFBurstAimTest__caster=CreateUnit(Player(0), 'o001', - 5500., - 5500., 0.)
        set RFBurstAimTest__target=CreateUnit(Player(1), 'o000', - 1967.5, 4352., 0.)
        set RFBurstAimTest__control=CreateUnit(Player(1), 'o000', - 1967.5, 4864., 0.)
        call PauseUnit(RFBurstAimTest__target, true)
        call PauseUnit(RFBurstAimTest__control, true)
        set RFBurstAimTest__damageHook=CreateTrigger()
        call TriggerRegisterUnitEvent(RFBurstAimTest__damageHook, RFBurstAimTest__target, EVENT_UNIT_DAMAGED)
        call TriggerRegisterUnitEvent(RFBurstAimTest__damageHook, RFBurstAimTest__control, EVENT_UNIT_DAMAGED)
        call TriggerAddCondition(RFBurstAimTest__damageHook, Condition(function RFBurstAimTest__OnDamage))
        set RFBurstAimTest__spellHook=CreateTrigger()
        call TriggerRegisterUnitEvent(RFBurstAimTest__spellHook, RFBurstAimTest__caster, EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(RFBurstAimTest__spellHook, Condition(function RFBurstAimTest__OnSpell))
        set RFBurstAimTest__shotHook=CreateTrigger()
        call TriggerAddCondition(RFBurstAimTest__shotHook, Condition(function RFBurstAimTest__OnShot))
        if not RB_InitializePair(RFBurstAimTest__actor , RFBurstAimTest__caster , RFBurstAimTest__shotHook) then
            call RFBurstAimTest__Abort("public InitializePair refused validated rawcode contract")
        endif
    endfunction

    function RFBurstAimTest__AimDestructable takes nothing returns nothing
        set RFBurstAimTest__destSeen=RFBurstAimTest__destSeen + 1
        if RFBurstAimTest__destSeen > 128 or GetWidgetLife(GetEnumDestructable()) > .405 then
            set RFBurstAimTest__corridorClear=false
        endif
    endfunction

    function RFBurstAimTest__AimRayClear takes unit endpoint returns boolean
        local real x= GetUnitX(RFBurstAimTest__actor)
        local real y= GetUnitY(RFBurstAimTest__actor)
        local real dx= GetUnitX(endpoint) - x
        local real dy= GetUnitY(endpoint) - y
        local real distance= SquareRoot(dx * dx + dy * dy)
        local real px
        local real py
        local real baseZ
        local integer level= GetTerrainCliffLevel(x, y)
        local integer stepIndex= 0
        local integer sideIndex
        local integer seen= 0
        local unit u
        call MoveLocation(RFBurstAimTest__groundProbe, x, y)
        set baseZ=GetLocationZ(RFBurstAimTest__groundProbe)
        set dx=dx / distance
        set dy=dy / distance
        loop
            exitwhen stepIndex > 16
            set sideIndex=- 1
            loop
                exitwhen sideIndex > 1
                set px=x + ( GetUnitX(endpoint) - x ) * I2R(stepIndex) / 16. - dy * I2R(sideIndex) * 48.
                set py=y + ( GetUnitY(endpoint) - y ) * I2R(stepIndex) / 16. + dx * I2R(sideIndex) * 48.
                call MoveLocation(RFBurstAimTest__groundProbe, px, py)
                if IsTerrainPathable(px, py, PATHING_TYPE_WALKABILITY) or GetTerrainCliffLevel(px, py) != level or RAbsBJ(GetLocationZ(RFBurstAimTest__groundProbe) - baseZ) > 1. then
                    return false
                endif
                set sideIndex=sideIndex + 1
            endloop
            set stepIndex=stepIndex + 1
        endloop
        call SetRect(RFBurstAimTest__corridorRect, RMinBJ(x, GetUnitX(endpoint)) - 48., RMinBJ(y, GetUnitY(endpoint)) - 48., RMaxBJ(x, GetUnitX(endpoint)) + 48., RMaxBJ(y, GetUnitY(endpoint)) + 48.)
        set RFBurstAimTest__corridorClear=true
        set RFBurstAimTest__destSeen=0
        call EnumDestructablesInRect(RFBurstAimTest__corridorRect, null, function RFBurstAimTest__AimDestructable)
        call GroupEnumUnitsInRect(RFBurstAimTest__corridorUnits, RFBurstAimTest__corridorRect, null)
        loop
            set u=FirstOfGroup(RFBurstAimTest__corridorUnits)
            exitwhen u == null
            set seen=seen + 1
            if seen > 128 or ( u != RFBurstAimTest__actor and u != endpoint and GetWidgetLife(u) > .405 ) then
                set RFBurstAimTest__corridorClear=false
            endif
            call GroupRemoveUnit(RFBurstAimTest__corridorUnits, u)
            exitwhen seen > 128
        endloop
        call GroupClear(RFBurstAimTest__corridorUnits)
        set u=null
        return RFBurstAimTest__corridorClear
    endfunction

    function RFBurstAimTest__AimSceneReady takes nothing returns boolean
        local real ex= GetUnitX(RFBurstAimTest__target) - GetUnitX(RFBurstAimTest__actor)
        local real ey= GetUnitY(RFBurstAimTest__target) - GetUnitY(RFBurstAimTest__actor)
        local real nx= GetUnitX(RFBurstAimTest__northTarget) - GetUnitX(RFBurstAimTest__actor)
        local real ny= GetUnitY(RFBurstAimTest__northTarget) - GetUnitY(RFBurstAimTest__actor)
        local real el= SquareRoot(ex * ex + ey * ey)
        local real nl= SquareRoot(nx * nx + ny * ny)
        if not RFBurstAimTest__At(RFBurstAimTest__actor , - 3136. , 2624.) or not RFBurstAimTest__At(RFBurstAimTest__caster , - 5500. , - 5500.) or not RFBurstAimTest__At(RFBurstAimTest__target , - 2880. , 2624.) or not RFBurstAimTest__At(RFBurstAimTest__northTarget , - 3136. , 2880.) or not RFBurstAimTest__At(RFBurstAimTest__control , - 2880. , 3136.) or not RFBurstAimTest__At(RFBurstAimTest__northControl , - 3648. , 2880.) then
            return false
        endif
        if not RFBurstAimTest__BodyReady(RFBurstAimTest__actor) or not RFBurstAimTest__BodyReady(RFBurstAimTest__target) or not RFBurstAimTest__BodyReady(RFBurstAimTest__northTarget) or not RFBurstAimTest__BodyReady(RFBurstAimTest__control) or not RFBurstAimTest__BodyReady(RFBurstAimTest__northControl) then
            return false
        endif
        if GetUnitTypeId(RFBurstAimTest__caster) != 'o001' or GetUnitAbilityLevel(RFBurstAimTest__caster, 'A00G') != 1 or GetUnitAbilityLevel(RFBurstAimTest__caster, 'Ablo') != 0 or GetWidgetLife(RFBurstAimTest__caster) <= .405 or IsUnitPaused(RFBurstAimTest__actor) or IsUnitPaused(RFBurstAimTest__caster) then
            return false
        endif
        if not IsUnitPaused(RFBurstAimTest__target) or not IsUnitPaused(RFBurstAimTest__northTarget) or not IsUnitPaused(RFBurstAimTest__control) or not IsUnitPaused(RFBurstAimTest__northControl) or RAbsBJ(GetUnitFacing(RFBurstAimTest__actor)) > .01 or GetUnitCurrentOrder(RFBurstAimTest__actor) != 0 then
            return false
        endif
        if GetOwningPlayer(RFBurstAimTest__target) != Player(1) or GetOwningPlayer(RFBurstAimTest__northTarget) != Player(1) or GetOwningPlayer(RFBurstAimTest__control) != Player(1) or GetOwningPlayer(RFBurstAimTest__northControl) != Player(1) then
            return false
        endif
        if not IsUnitEnemy(RFBurstAimTest__target, Player(0)) or not IsUnitEnemy(RFBurstAimTest__northTarget, Player(0)) or not IsUnitEnemy(RFBurstAimTest__control, Player(0)) or not IsUnitEnemy(RFBurstAimTest__northControl, Player(0)) or not IsUnitEnemy(RFBurstAimTest__actor, Player(1)) then
            return false
        endif
        if el < 254. or el > 258. or nl < 254. or nl > 258. or ( ex * nx + ey * ny ) / ( el * nl ) > .7071068 then
            return false
        endif
        call RB_LogRecord("OBS" , "actual-two-ray-geometry" , "eastDelta=" + R2S(ex) + "," + R2S(ey) + " northDelta=" + R2S(nx) + "," + R2S(ny) + " cosine=" + R2S(( ex * nx + ey * ny ) / ( el * nl )))
        // Controls are hundreds of units off BOTH rays by actual placement.
        if not RFBurstAimTest__AimRayClear(RFBurstAimTest__target) or not RFBurstAimTest__AimRayClear(RFBurstAimTest__northTarget) then
            return false
        endif
        return not IsTerrainPathable(GetUnitX(RFBurstAimTest__control), GetUnitY(RFBurstAimTest__control), PATHING_TYPE_WALKABILITY) and not IsTerrainPathable(GetUnitX(RFBurstAimTest__northControl), GetUnitY(RFBurstAimTest__northControl), PATHING_TYPE_WALKABILITY)
    endfunction

    function RFBurstAimTest__SpawnAimScene takes nothing returns nothing
        call RFBurstAimTest__ResetObservations()
        set RFBurstAimTest__actor=CreateUnit(Player(0), 'o000', - 3136., 2624., 0.)
        set RFBurstAimTest__caster=CreateUnit(Player(0), 'o001', - 5500., - 5500., 0.)
        set RFBurstAimTest__target=CreateUnit(Player(1), 'o000', - 2880., 2624., 0.)
        set RFBurstAimTest__northTarget=CreateUnit(Player(1), 'o000', - 3136., 2880., 0.)
        set RFBurstAimTest__control=CreateUnit(Player(1), 'o000', - 2880., 3136., 0.)
        set RFBurstAimTest__northControl=CreateUnit(Player(1), 'o000', - 3648., 2880., 0.)
        call PauseUnit(RFBurstAimTest__target, true)
        call PauseUnit(RFBurstAimTest__northTarget, true)
        call PauseUnit(RFBurstAimTest__control, true)
        call PauseUnit(RFBurstAimTest__northControl, true)
        set RFBurstAimTest__damageHook=CreateTrigger()
        call TriggerRegisterUnitEvent(RFBurstAimTest__damageHook, RFBurstAimTest__target, EVENT_UNIT_DAMAGED)
        call TriggerRegisterUnitEvent(RFBurstAimTest__damageHook, RFBurstAimTest__northTarget, EVENT_UNIT_DAMAGED)
        call TriggerRegisterUnitEvent(RFBurstAimTest__damageHook, RFBurstAimTest__control, EVENT_UNIT_DAMAGED)
        call TriggerRegisterUnitEvent(RFBurstAimTest__damageHook, RFBurstAimTest__northControl, EVENT_UNIT_DAMAGED)
        call TriggerAddCondition(RFBurstAimTest__damageHook, Condition(function RFBurstAimTest__OnDamage))
        set RFBurstAimTest__spellHook=CreateTrigger()
        call TriggerRegisterUnitEvent(RFBurstAimTest__spellHook, RFBurstAimTest__caster, EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(RFBurstAimTest__spellHook, Condition(function RFBurstAimTest__OnSpell))
        set RFBurstAimTest__shotHook=CreateTrigger()
        call TriggerAddCondition(RFBurstAimTest__shotHook, Condition(function RFBurstAimTest__OnShot))
        if not RB_InitializePair(RFBurstAimTest__actor , RFBurstAimTest__caster , RFBurstAimTest__shotHook) then
            call RFBurstAimTest__Abort("fresh aim pair public initialization failed")
        endif
    endfunction

    function RFBurstAimTest__AssessAim takes nothing returns nothing
        local real eastDiff= ( GetWidgetLife(RFBurstAimTest__control) - RFBurstAimTest__controlStart ) - ( GetWidgetLife(RFBurstAimTest__target) - RFBurstAimTest__targetStart )
        local real northDiff= ( GetWidgetLife(RFBurstAimTest__northControl) - RFBurstAimTest__northControlStart ) - ( GetWidgetLife(RFBurstAimTest__northTarget) - RFBurstAimTest__northStart )
        local integer i= 2
        call RB_LogRecord("OBS" , "aim-HP-pairs" , "east=" + R2S(RFBurstAimTest__targetStart) + "->" + R2S(GetWidgetLife(RFBurstAimTest__target)) + " eastControl=" + R2S(RFBurstAimTest__controlStart) + "->" + R2S(GetWidgetLife(RFBurstAimTest__control)) + " north=" + R2S(RFBurstAimTest__northStart) + "->" + R2S(GetWidgetLife(RFBurstAimTest__northTarget)) + " northControl=" + R2S(RFBurstAimTest__northControlStart) + "->" + R2S(GetWidgetLife(RFBurstAimTest__northControl)))
        call RB_LogCheck(RFBurstAimTest__recastQualified and RFBurstAimTest__castEvents == 2 and RFBurstAimTest__recastEffectShots == 1 , "aim-inflight-native-window" , "exact NORTH effect at public shot1 while same first flight live/no impact")
        call RB_LogCheck(RFBurstAimTest__shots == 5 , "five-total-real-shots" , "actual=" + I2S(RFBurstAimTest__shots) + " expected=5")
        call RB_LogCheck(RFBurstAimTest__shots == 5 and RFBurstAimTest__projectilesOK , "five-public-live-missiles" , "actual live separate dummy/visible source/current actor origin at every pulse")
        call RB_LogCheck(RFBurstAimTest__hits == 5 and RFBurstAimTest__hitValuesOK and RFBurstAimTest__hitSourcesOK , "five-native-ten-visible-source" , "actual hits=" + I2S(RFBurstAimTest__hits) + " every native amount10/source actor")
        call RB_LogCheck(RFBurstAimTest__eastHits == 1 , "east-first-only" , "actual=" + I2S(RFBurstAimTest__eastHits) + " expected=1")
        call RB_LogCheck(RFBurstAimTest__northHits == 4 , "north-four-future-hits" , "actual=" + I2S(RFBurstAimTest__northHits) + " expected=4")
        call RB_LogCheck(RAbsBJ(eastDiff - 10.) <= RFBurstAimTest__HP_TOLERANCE , "east-HP-differential10" , "actual=" + R2S(eastDiff) + " tolerance=.10")
        call RB_LogCheck(RAbsBJ(northDiff - 40.) <= RFBurstAimTest__HP_TOLERANCE , "north-HP-differential40" , "actual=" + R2S(northDiff) + " tolerance=.10")
        call RB_LogCheck(RFBurstAimTest__controlHits == 0 , "both-controls-undamaged" , "actual=" + I2S(RFBurstAimTest__controlHits))
        call RB_LogCheck(GetWidgetLife(RFBurstAimTest__target) > .405 and GetWidgetLife(RFBurstAimTest__northTarget) > .405 and GetWidgetLife(RFBurstAimTest__control) > .405 and GetWidgetLife(RFBurstAimTest__northControl) > .405 , "all-four-bodies-survive" , "native widget life remains positive")
        call RB_LogCheck(not RFBurstAimTest__earlyPulse , "no-immediate-aim-recast-emission" , "no pulse before firstShot+.25 (float epsilon .0001)")
        loop
            exitwhen i > 5
            if i <= RFBurstAimTest__shots then
                call RB_LogCheck(RAbsBJ(( RFBurstAimTest__shotTime[i] - RFBurstAimTest__shotTime[i - 1] ) - .25) <= RFBurstAimTest__CADENCE_TOLERANCE , "aim-cadence-interval" + I2S(i - 1) , "actual=" + R2S(RFBurstAimTest__shotTime[i] - RFBurstAimTest__shotTime[i - 1]) + " expected=.25 tolerance=.03125")
            else
                call RB_LogRecord("FAIL" , "missing-aim-interval" + I2S(i - 1) , "need5 actual shot notifications/4 adjacent intervals")
            endif
            set i=i + 1
        endloop
        call RB_LogCase("R05-existing-flight-heading")
        call RB_LogCheck(RFBurstAimTest__postSample , "post-dispatch-first-flight-observed" , "same borrowed ID/dummy/source live at shot1/no impacts before sample")
        call RB_LogCheck(RFBurstAimTest__sampleAdvance > 0. and RFBurstAimTest__sampleCross <= 1. , "first-flight-old-ray-advance" , "advance=" + R2S(RFBurstAimTest__sampleAdvance) + " crossTrack=" + R2S(RFBurstAimTest__sampleCross) + " tolerance=1 sampleTime=" + R2S(RFBurstAimTest__sampleTime))
        call RB_LogCheck(RFBurstAimTest__firstEastBeforeSecond , "first-native-east-impact-before-shot2" , "firstEastTime=" + R2S(RFBurstAimTest__firstEastTime) + " observedShots=" + I2S(RFBurstAimTest__firstEastShots) + " firstShot=" + R2S(RFBurstAimTest__shotTime[1]) + " nextBoundary=" + R2S(RFBurstAimTest__shotTime[1] + .25))
        call RB_LogCheck(not RFBurstAimTest__northBeforeSecond , "no-premature-north-impact" , "native north impacts before second emission must be zero")
        call RFBurstAimTest__Finish()
    endfunction

    function RFBurstAimTest__AimTick takes nothing returns nothing
        local real now= TimerGetElapsed(RFBurstAimTest__clock)
        local real life
        local real dx
        local real dy
        local boolean accepted
        if RFBurstAimTest__phase == - 1 then
            call RFBurstAimTest__Abort("aim native effect/source/point/window or live-flight qualification failed")
        elseif RFBurstAimTest__phase == 0 then
            call RB_LogRecord("OBS" , "aim-actor-ready" , RFBurstAimTest__Pose(RFBurstAimTest__actor))
            call RB_LogRecord("OBS" , "aim-caster-ready" , RFBurstAimTest__Pose(RFBurstAimTest__caster))
            call RB_LogRecord("OBS" , "aim-east-ready" , RFBurstAimTest__Pose(RFBurstAimTest__target))
            call RB_LogRecord("OBS" , "aim-north-ready" , RFBurstAimTest__Pose(RFBurstAimTest__northTarget))
            call RB_LogRecord("OBS" , "aim-east-control-ready" , RFBurstAimTest__Pose(RFBurstAimTest__control))
            call RB_LogRecord("OBS" , "aim-north-control-ready" , RFBurstAimTest__Pose(RFBurstAimTest__northControl))
            if not RFBurstAimTest__AimSceneReady() then
                call RFBurstAimTest__Abort("aim actual placement/type/enemy/pause/abilities/flat unobstructed corridors unavailable")
                return
            endif
            set RFBurstAimTest__phase=1
            set RFBurstAimTest__calibrationHP=GetWidgetLife(RFBurstAimTest__target)
            set RFBurstAimTest__calibrated=UnitDamageTarget(RFBurstAimTest__actor, RFBurstAimTest__target, 10., true, true, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL, null)
        elseif RFBurstAimTest__phase == 1 then
            call RB_LogRecord("OBS" , "aim-east-calibration" , "hits=" + I2S(RFBurstAimTest__calibrationHits) + " value=" + R2S(RFBurstAimTest__calibrationDamage) + " HP=" + R2S(RFBurstAimTest__calibrationHP) + "->" + R2S(GetWidgetLife(RFBurstAimTest__target)))
            if not RFBurstAimTest__calibrated or RFBurstAimTest__calibrationHits != 1 or not RFBurstAimTest__calibrationSource or RAbsBJ(RFBurstAimTest__calibrationDamage - 10.) > .01 or GetWidgetLife(RFBurstAimTest__target) >= RFBurstAimTest__calibrationHP or RFBurstAimTest__controlHits != 0 then
                call RFBurstAimTest__Abort("native EAST physical10 calibration unavailable")
                return
            endif
            set RFBurstAimTest__northCalibrationHP=GetWidgetLife(RFBurstAimTest__northTarget)
            set RFBurstAimTest__phase=2
            set RFBurstAimTest__northCalibrationAccepted=UnitDamageTarget(RFBurstAimTest__actor, RFBurstAimTest__northTarget, 10., true, true, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL, null)
        elseif RFBurstAimTest__phase == 2 then
            call RB_LogRecord("OBS" , "aim-north-calibration" , "hits=" + I2S(RFBurstAimTest__northCalibrationHits) + " value=" + R2S(RFBurstAimTest__northCalibrationDamage) + " HP=" + R2S(RFBurstAimTest__northCalibrationHP) + "->" + R2S(GetWidgetLife(RFBurstAimTest__northTarget)))
            if not RFBurstAimTest__northCalibrationAccepted or RFBurstAimTest__northCalibrationHits != 1 or not RFBurstAimTest__northCalibrationSource or RAbsBJ(RFBurstAimTest__northCalibrationDamage - 10.) > .01 or GetWidgetLife(RFBurstAimTest__northTarget) >= RFBurstAimTest__northCalibrationHP or RFBurstAimTest__controlHits != 0 then
                call RFBurstAimTest__Abort("native NORTH physical10 calibration unavailable")
                return
            endif
            set life=RMinBJ(RMinBJ(GetUnitState(RFBurstAimTest__target, UNIT_STATE_MAX_LIFE), GetUnitState(RFBurstAimTest__northTarget, UNIT_STATE_MAX_LIFE)), RMinBJ(GetUnitState(RFBurstAimTest__control, UNIT_STATE_MAX_LIFE), GetUnitState(RFBurstAimTest__northControl, UNIT_STATE_MAX_LIFE))) - 10.
            if life <= 60. then
                call RFBurstAimTest__Abort("aim paired health margin unavailable")
                return
            endif
            call SetWidgetLife(RFBurstAimTest__target, life)
            call SetWidgetLife(RFBurstAimTest__northTarget, life)
            call SetWidgetLife(RFBurstAimTest__control, life)
            call SetWidgetLife(RFBurstAimTest__northControl, life)
            if RAbsBJ(GetWidgetLife(RFBurstAimTest__target) - life) > .001 or RAbsBJ(GetWidgetLife(RFBurstAimTest__northTarget) - life) > .001 or RAbsBJ(GetWidgetLife(RFBurstAimTest__control) - life) > .001 or RAbsBJ(GetWidgetLife(RFBurstAimTest__northControl) - life) > .001 then
                call RFBurstAimTest__Abort("aim identical native health reset failed")
                return
            endif
            set RFBurstAimTest__phase=3
        elseif RFBurstAimTest__phase == 3 then
            set RFBurstAimTest__aimX=GetUnitX(RFBurstAimTest__target)
            set RFBurstAimTest__aimY=GetUnitY(RFBurstAimTest__target)
            set RFBurstAimTest__orderTime=now
            set RFBurstAimTest__expectedCast=1
            set RFBurstAimTest__phase=4
            set accepted=IssuePointOrder(RFBurstAimTest__caster, "channel", RFBurstAimTest__aimX, RFBurstAimTest__aimY)
            call RB_LogCheck(accepted , "native-east-order-accepted" , "actual EAST point=" + R2S(RFBurstAimTest__aimX) + "," + R2S(RFBurstAimTest__aimY))
            if not accepted then
                call RFBurstAimTest__Abort("initial EAST native point order rejected")
            endif
        elseif RFBurstAimTest__phase == 4 then
            if now - RFBurstAimTest__orderTime >= 2. then
                call RFBurstAimTest__Abort("EAST native effect deadline2s")
            endif
        elseif RFBurstAimTest__phase == 5 then
            if RFBurstAimTest__pendingRecast and now >= RFBurstAimTest__recastDue then
                if RFBurstAimTest__shots != 1 or RFBurstAimTest__hits != 0 or not (RFBurstAimTest__firstFlight != 0 and s__Missiles_allocated[RFBurstAimTest__firstFlight] and s__Missiles_launched[RFBurstAimTest__firstFlight] and s__Missiles_dummy[RFBurstAimTest__firstFlight] == RFBurstAimTest__firstDummy and GetUnitTypeId(RFBurstAimTest__firstDummy) != 0 and s__Missiles_source[RFBurstAimTest__firstFlight] == RFBurstAimTest__firstSource and RFBurstAimTest__firstSource == RFBurstAimTest__actor) then // INLINED!!
                    call RFBurstAimTest__Abort("first flight/one-shot/no-impact input window unavailable")
                    return
                endif
                // Future tick, not inside observer. Precommit before native call.
                set RFBurstAimTest__aimX=GetUnitX(RFBurstAimTest__northTarget)
                set RFBurstAimTest__aimY=GetUnitY(RFBurstAimTest__northTarget)
                set RFBurstAimTest__pendingRecast=false
                set RFBurstAimTest__recastRequested=true
                set RFBurstAimTest__expectedCast=2
                set RFBurstAimTest__recastIssue=now
                call RB_LogRecord("OBS" , "native-north-order" , "firstShot=" + R2S(RFBurstAimTest__shotTime[1]) + " due=" + R2S(RFBurstAimTest__recastDue) + " issue=" + R2S(now) + " actual=" + R2S(RFBurstAimTest__aimX) + "," + R2S(RFBurstAimTest__aimY))
                set accepted=IssuePointOrder(RFBurstAimTest__caster, "channel", RFBurstAimTest__aimX, RFBurstAimTest__aimY)
                call RB_LogCheck(accepted , "native-north-order-accepted" , "actual NORTH point, phase/expected event committed before order")
                if not accepted then
                    call RFBurstAimTest__Abort("native NORTH recast order rejected")
                endif
            elseif RFBurstAimTest__recastQualified and not RFBurstAimTest__postSample then
                if RFBurstAimTest__shots != 1 or RFBurstAimTest__hits != 0 or now >= RFBurstAimTest__shotTime[1] + .25 or not (RFBurstAimTest__firstFlight != 0 and s__Missiles_allocated[RFBurstAimTest__firstFlight] and s__Missiles_launched[RFBurstAimTest__firstFlight] and s__Missiles_dummy[RFBurstAimTest__firstFlight] == RFBurstAimTest__firstDummy and GetUnitTypeId(RFBurstAimTest__firstDummy) != 0 and s__Missiles_source[RFBurstAimTest__firstFlight] == RFBurstAimTest__firstSource and RFBurstAimTest__firstSource == RFBurstAimTest__actor) then // INLINED!!
                    call RFBurstAimTest__Abort("post-dispatch next-tick same live first-flight/no-impact sample unavailable")
                    return
                endif
                set RFBurstAimTest__sampleTime=now
                set dx=s__Missiles_x[RFBurstAimTest__firstFlight] - RFBurstAimTest__firstInitialX
                set dy=s__Missiles_y[RFBurstAimTest__firstFlight] - RFBurstAimTest__firstInitialY
                set RFBurstAimTest__sampleAdvance=dx * RFBurstAimTest__eastDX + dy * RFBurstAimTest__eastDY
                set RFBurstAimTest__sampleCross=RAbsBJ(dx * RFBurstAimTest__eastDY - dy * RFBurstAimTest__eastDX)
                call RB_LogRecord("OBS" , "first-flight-post-dispatch" , "time=" + R2S(now) + " xy=" + R2S(s__Missiles_x[RFBurstAimTest__firstFlight]) + "," + R2S(s__Missiles_y[RFBurstAimTest__firstFlight]) + " advance=" + R2S(RFBurstAimTest__sampleAdvance) + " cross=" + R2S(RFBurstAimTest__sampleCross) + " shots=1 hits=0")
                set RFBurstAimTest__postSample=true
                // Never dereference borrowed ID after an impact/later emission.
                set RFBurstAimTest__firstFlight=0
                set RFBurstAimTest__firstDummy=null
                set RFBurstAimTest__firstSource=null
            elseif RFBurstAimTest__recastRequested and not RFBurstAimTest__recastQualified and ( RFBurstAimTest__hits > 0 or now >= RFBurstAimTest__shotTime[1] + .25 ) then
                call RFBurstAimTest__Abort("NORTH effect not qualified while first flight live before impact/shot2")
            elseif not RFBurstAimTest__recastRequested and now - RFBurstAimTest__castTime >= .25 then
                call RFBurstAimTest__Abort("first live missile notification unavailable")
            elseif RFBurstAimTest__recastQualified and RFBurstAimTest__postSample and now - RFBurstAimTest__recastEffect >= 3. then
                call RFBurstAimTest__AssessAim()
            endif
        endif
    endfunction

    function RFBurstAimTest__Tick takes nothing returns nothing
        local real life
        local boolean accepted
        if RFBurstAimTest__aimCase then
            call RFBurstAimTest__AimTick()
            return
        endif
        if RFBurstAimTest__phase == 7 then
            if not RFBurstAimTest__RemovedAbsent() then
                call RFBurstAimTest__Abort("next-tick R03 units not cleared for aim scene")
                return
            endif
            call RB_LogCheck(true , "prior-R03-unit-clearance" , "removed type0/native-group absence on next tick")
            call RFBurstAimTest__ReleaseSceneRefs()
            set RFBurstAimTest__aimCase=true
            call RFBurstAimTest__SpawnAimScene()
            return
        endif
        if RFBurstAimTest__phase == - 1 then
            call RFBurstAimTest__Abort("unexpected native spell effect/source/ability/point or duplicate event")
        elseif RFBurstAimTest__phase == 6 then
            if not RFBurstAimTest__RemovedAbsent() then
                call RFBurstAimTest__Abort("next-tick prior-unit type0/native group clearance unavailable")
                return
            endif
            call RB_LogCheck(true , "prior-unit-clearance" , "removed type0/native group absence observed on next harness tick")
            call RFBurstAimTest__ReleaseSceneRefs()
            set RFBurstAimTest__recastCase=true
            call RFBurstAimTest__SpawnScene()
        elseif RFBurstAimTest__phase == 0 then
            call RB_LogRecord("OBS" , "actor-ready" , RFBurstAimTest__Pose(RFBurstAimTest__actor))
            call RB_LogRecord("OBS" , "caster-ready" , RFBurstAimTest__Pose(RFBurstAimTest__caster) + " A00G=" + I2S(GetUnitAbilityLevel(RFBurstAimTest__caster, 'A00G')))
            call RB_LogRecord("OBS" , "target-ready" , RFBurstAimTest__Pose(RFBurstAimTest__target))
            call RB_LogRecord("OBS" , "control-ready" , RFBurstAimTest__Pose(RFBurstAimTest__control))
            if not RFBurstAimTest__SceneReady() then
                call RFBurstAimTest__Abort("type/life/enemy/placement/abilities/pause/facing/order/fresh static path flag readiness unavailable")
                return
            endif
            set RFBurstAimTest__phase=1
            set RFBurstAimTest__calibrationHP=GetWidgetLife(RFBurstAimTest__target)
            // Explicit physical base mapping for this controlled scene. No spell,
            // fire, magic, universal, AOE, burn or armor-getter assumption.
            set RFBurstAimTest__calibrated=UnitDamageTarget(RFBurstAimTest__actor, RFBurstAimTest__target, 10., true, true, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL, null)
        elseif RFBurstAimTest__phase == 1 then
            call RB_LogRecord("OBS" , "native-calibration" , "events=" + I2S(RFBurstAimTest__calibrationHits) + " damage=" + R2S(RFBurstAimTest__calibrationDamage) + " HPbefore=" + R2S(RFBurstAimTest__calibrationHP) + " HPafter=" + R2S(GetWidgetLife(RFBurstAimTest__target)))
            if not RFBurstAimTest__calibrated or RFBurstAimTest__calibrationHits != 1 or not RFBurstAimTest__calibrationSource or RAbsBJ(RFBurstAimTest__calibrationDamage - 10.) > .01 or GetWidgetLife(RFBurstAimTest__target) >= RFBurstAimTest__calibrationHP or RFBurstAimTest__controlHits != 0 then
                call RFBurstAimTest__Abort("physical10 native calibration unavailable; no burst-rule RED inferred")
                return
            endif
            set life=RMinBJ(GetUnitState(RFBurstAimTest__target, UNIT_STATE_MAX_LIFE), GetUnitState(RFBurstAimTest__control, UNIT_STATE_MAX_LIFE)) - 10.
            if life <= 60. then
                call RFBurstAimTest__Abort("insufficient controlled health margin")
                return
            endif
            call SetWidgetLife(RFBurstAimTest__target, life)
            call SetWidgetLife(RFBurstAimTest__control, life)
            if RAbsBJ(GetWidgetLife(RFBurstAimTest__target) - life) > .001 or RAbsBJ(GetWidgetLife(RFBurstAimTest__control) - life) > .001 then
                call RFBurstAimTest__Abort("same native starting health reset failed")
                return
            endif
            set RFBurstAimTest__phase=3
        elseif RFBurstAimTest__phase == 3 then
            set RFBurstAimTest__hits=0
            set RFBurstAimTest__controlHits=0
            set RFBurstAimTest__shots=0
            set RFBurstAimTest__aimX=GetUnitX(RFBurstAimTest__target)
            set RFBurstAimTest__aimY=GetUnitY(RFBurstAimTest__target)
            set RFBurstAimTest__orderTime=TimerGetElapsed(RFBurstAimTest__clock)
            set RFBurstAimTest__expectedCast=1
            set RFBurstAimTest__phase=4
            set accepted=IssuePointOrder(RFBurstAimTest__caster, "channel", RFBurstAimTest__aimX, RFBurstAimTest__aimY)
            call RB_LogCheck(accepted , "native-point-order-accepted" , "actual target point=" + R2S(RFBurstAimTest__aimX) + "," + R2S(RFBurstAimTest__aimY))
            if not accepted then
                call RFBurstAimTest__Abort("native point order rejected; behavior assertions not run")
            endif
        elseif RFBurstAimTest__phase == 4 then
            if TimerGetElapsed(RFBurstAimTest__clock) - RFBurstAimTest__orderTime >= 2. then
                call RFBurstAimTest__Abort("native Channel effect deadline2s; no behavior assertions without actual event")
            endif
        elseif RFBurstAimTest__phase == 5 then
            if RFBurstAimTest__recastCase then
                if RFBurstAimTest__pendingRecast and TimerGetElapsed(RFBurstAimTest__clock) >= RFBurstAimTest__recastDue then
                    if RFBurstAimTest__shots != 2 then
                        call RFBurstAimTest__Abort("active-window input unavailable: not exactly2 observed shots")
                        return
                    endif
                    // Commit BEFORE IssuePointOrder: native effect may be synchronous.
                    set RFBurstAimTest__pendingRecast=false
                    set RFBurstAimTest__recastRequested=true
                    set RFBurstAimTest__expectedCast=2
                    set RFBurstAimTest__recastIssue=TimerGetElapsed(RFBurstAimTest__clock)
                    call RB_LogRecord("OBS" , "recast-point-order" , "secondShot=" + R2S(RFBurstAimTest__shotTime[2]) + " due=" + R2S(RFBurstAimTest__recastDue) + " issue=" + R2S(RFBurstAimTest__recastIssue))
                    set accepted=IssuePointOrder(RFBurstAimTest__caster, "channel", RFBurstAimTest__aimX, RFBurstAimTest__aimY)
                    call RB_LogCheck(accepted , "native-recast-order-accepted" , "same actual target point=" + R2S(RFBurstAimTest__aimX) + "," + R2S(RFBurstAimTest__aimY))
                    if not accepted then
                        call RFBurstAimTest__Abort("native recast order rejected; no behavioral recast RED")
                    endif
                elseif RFBurstAimTest__recastRequested and not RFBurstAimTest__recastQualified and TimerGetElapsed(RFBurstAimTest__clock) >= RFBurstAimTest__shotTime[2] + .25 then
                    call RFBurstAimTest__Abort("second native effect absent before secondShot+.25; no active-window qualification")
                elseif not RFBurstAimTest__recastRequested and TimerGetElapsed(RFBurstAimTest__clock) - RFBurstAimTest__castTime >= .75 then
                    call RFBurstAimTest__Abort("two live public projectile notifications unavailable by first-effect+.75")
                elseif RFBurstAimTest__recastQualified and TimerGetElapsed(RFBurstAimTest__clock) - RFBurstAimTest__recastEffect >= 3. then
                    call RFBurstAimTest__AssessRecast()
                endif
            elseif RFBurstAimTest__castEvents != 1 then
                call RFBurstAimTest__Abort("expected exactly one native cast event")
            elseif TimerGetElapsed(RFBurstAimTest__clock) - RFBurstAimTest__castTime >= 3. then
                call RB_LogCheck(true , "native-cast-effect-ready" , "one matching source/A00G/actual target point; observation horizon3s relative to native event")
                call RFBurstAimTest__Assess()
            endif
        endif
    endfunction

    function RF_StartAimTest takes nothing returns nothing
        call RB_LogBegin()
        call RB_LogCase("B01-four-shot-native-effects")
        call SetPlayerAlliance(Player(0), Player(1), ALLIANCE_PASSIVE, false)
        call SetPlayerAlliance(Player(1), Player(0), ALLIANCE_PASSIVE, false)
        set RFBurstAimTest__clock=CreateTimer()
        set RFBurstAimTest__runner=CreateTimer()
        set RFBurstAimTest__groundProbe=Location(0., 0.)
        set RFBurstAimTest__corridorUnits=CreateGroup()
        set RFBurstAimTest__corridorRect=Rect(0., 0., 0., 0.)
        call TimerStart(RFBurstAimTest__clock, 25., false, function RFBurstAimTest__Deadline)
        call RFBurstAimTest__SpawnScene()
        if not RFBurstAimTest__done then
            call TimerStart(RFBurstAimTest__runner, RFBurstAimTest__PERIOD, true, function RFBurstAimTest__Tick)
        endif
    endfunction

// BEGIN IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\relativistic-classic\src\libraries\TimerUtils.j



// END IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\relativistic-classic\src\libraries\TimerUtils.j
// BEGIN IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\relativistic-classic\src\libraries\WorldBounds.j


// END IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\relativistic-classic\src\libraries\WorldBounds.j
// BEGIN IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\relativistic-classic\src\libraries\DummyRecycler.j


// END IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\relativistic-classic\src\libraries\DummyRecycler.j
// BEGIN IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\relativistic-classic\src\Missiles.j


// END IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\relativistic-classic\src\Missiles.j
// BEGIN IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\AimLogRed01.j

// END IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\AimLogRed01.j
// BEGIN IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\PairCore.j

// END IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\PairCore.j
// BEGIN IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\AimNativeTest.j

// END IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\AimNativeTest.j
function RCStartHarness takes nothing returns nothing
    call RF_StartAimTest()
endfunction
// BEGIN IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\AimMapMainRed01.j
// Separate external-source executable. Inherited W3I/WCT/WTG are unchanged;
// one runtime P0, not an editor-save or multiplayer certificate.
function config takes nothing returns nothing
    local integer i= 1
    call SetMapName("Rapid Fire Aim RED B01 B02 R03 R04 R05")
    call SetMapDescription("rf-burst-aim-red-20261020-01: new-aim native RED with existing-flight regression")
    call SetPlayers(1)
    call SetTeams(1)
    call SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
    call DefineStartLocation(0, - 2223.5, 4352.)
    call SetPlayerStartLocation(Player(0), 0)
    call ForcePlayerStartLocation(Player(0), 0)
    call SetPlayerTeam(Player(0), 0)
    call SetPlayerColor(Player(0), PLAYER_COLOR_RED)
    call SetPlayerRacePreference(Player(0), RACE_PREF_ORC)
    call SetPlayerRaceSelectable(Player(0), false)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
    loop
        exitwhen i >= 12
        call SetPlayerController(Player(i), MAP_CONTROL_NONE)
        call SetPlayerSlotAvailable(Player(i), MAP_CONTROL_NONE)
        set i=i + 1
    endloop
endfunction

function main takes nothing returns nothing
    call SetCameraBounds(- 6656. + GetCameraMargin(CAMERA_MARGIN_LEFT), - 6784. + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 6656. - GetCameraMargin(CAMERA_MARGIN_RIGHT), 6528. - GetCameraMargin(CAMERA_MARGIN_TOP), - 6656. + GetCameraMargin(CAMERA_MARGIN_LEFT), 6528. - GetCameraMargin(CAMERA_MARGIN_TOP), 6656. - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 6784. + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl")
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("LordaeronSummerDay")
    call SetAmbientNightSound("LordaeronSummerNight")
    call InitBlizzard()

    call ExecuteFunc("jasshelper__init6441")

    call PanCameraTo(- 2223.5, 4352.)
    call RF_StartAimTest() // INLINED!!
endfunction

// END IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\AimMapMainRed01.j



//All initializer functions called in proper order:

//Functions for BigArrays:
function sa__Missiles_terminate takes nothing returns boolean
local integer this=f__arg_this
        local integer aux
        if s__Missiles_allocated[this] then
            set s__Missiles_allocated[this]=false
            set s__Missiles_pins[this]=s__Missiles_pins[this] + 1
            if s__Missiles_pkey[this] != - 1 then
                set aux=s__Missiles_frozen[s__Missiles_pid]
                set s__Missiles_pkey[aux]=s__Missiles_pkey[this]
                set s__Missiles_frozen[s__Missiles_pkey[this]]=s__Missiles_frozen[s__Missiles_pid]
                set s__Missiles_pid=s__Missiles_pid - 1
                set s__Missiles_pkey[this]=- 1
            endif
            if (st__Missiles___MissileEvents_onRemove[si__Missiles___MissileEvents_type[this]]!=null) then
                call sc__Missiles___MissileEvents_onRemove(this)
            endif
            if s__Missiles_index[this] != - 1 then
                set aux=s__Missiles_collection[s__Missiles_count]
                set s__Missiles_index[aux]=s__Missiles_index[this]
                set s__Missiles_collection[s__Missiles_index[this]]=s__Missiles_collection[s__Missiles_count]
                set s__Missiles_count=s__Missiles_count - 1
                set s__Missiles_index[this]=- 1
            endif
                call SetUnitOwner(s__Missiles_dummy[this], Player(PLAYER_NEUTRAL_PASSIVE), false)
                call DummyAddRecycleTimer(s__Missiles_dummy[this] , Missiles___RECYCLE_TIME)
            call s__Missiles_clearVision(this)
            call s__Missiles___Coordinates_deallocate((s__Missiles_origin[this])) // INLINED!!
            call s__Missiles___Coordinates_deallocate((s__Missiles_impact[this])) // INLINED!!
            call DestroyEffect(s__Missiles_effect[this])
            call sc__Missiles_reset(this)
            call s__Missiles_flushAll(this)
            set s__Missiles_pins[this]=s__Missiles_pins[this] - 1
            call sc__Missiles_release(this)
        endif
   return true
endfunction
function sa__Missiles_reset takes nothing returns boolean
local integer this=f__arg_this
            set s__Missiles_launched[this]=false
            set s__Missiles_finished[this]=false
            set s__Missiles_collideZ[this]=false
            set s__Missiles_paused[this]=false
            set s__Missiles_source[this]=null
            set s__Missiles_target[this]=null
            set s__Missiles_owner[this]=null
            set s__Missiles_effect[this]=null
            set s__Missiles_dummy[this]=null
            set s__Missiles_path[this]=""
            set s__Missiles_open[this]=0.
            set s__Missiles_height[this]=0.
            set s__Missiles_veloc[this]=0.
            set s__Missiles_acceleration[this]=0.
            set s__Missiles_collision[this]=0.
            set s__Missiles_damage[this]=0.
            set s__Missiles_travel[this]=0.
            set s__Missiles_turn[this]=0.
            set s__Missiles_size[this]=0.
            set s__Missiles_time[this]=0.
            set s__Missiles_sight[this]=0.
            set s__Missiles_progress[this]=0.
            set s__Missiles_nextProgress[this]=0.
            set s__Missiles_visionFog[this]=null
            set s__Missiles_visionOwner[this]=null
            set s__Missiles_visionRadius[this]=0.
            set s__Missiles_data[this]=0
            set s__Missiles_type[this]=0
            set s__Missiles_tileset[this]=0
            set s__Missiles_pkey[this]=- 1
            set s__Missiles_index[this]=- 1
   return true
endfunction
function sa__Missiles_release takes nothing returns boolean
local integer this=f__arg_this
            if not s__Missiles_allocated[this] and not s__Missiles_active[this] and s__Missiles_pins[this] == 0 then
                call sc__Missiles___MissileEvents_deallocate(this)
            endif
   return true
endfunction
function sa__Missiles_move takes nothing returns boolean

            local integer j= 0
            local integer i
            local integer k
            local unit u
            local real a
            local real d
            local real s
            local real h
            local real c
            local real dx
            local real dy
            local real vel
            local real yaw
            local real pitch
            local integer missile
            local integer o
            local integer this
            local boolean stop
            if Missiles_SWEET_SPOT > 0 then
                set i=s__Missiles_last
            else
                set i=0
            endif
            loop
                exitwhen ( ( j >= Missiles_SWEET_SPOT and Missiles_SWEET_SPOT > 0 ) or j > s__Missiles_id )
                set this=s__Missiles_missiles[i]
                    set s__Missiles_temp=this
                    if s__Missiles_allocated[this] and not s__Missiles_paused[this] then
        set o=s__Missiles_origin[this]
        set h=s__Missiles_height[this]
        set c=s__Missiles_open[this]
        set d=s__Missiles___Coordinates_distance[o]
        if (st__Missiles___MissileEvents_onHit[si__Missiles___MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                call GroupEnumUnitsInRange(s__Missiles_group, s__Missiles_x[this], s__Missiles_y[this], s__Missiles_collision[this] + Missiles___COLLISION_SIZE, null)
                loop
                    set u=FirstOfGroup(s__Missiles_group)
                    exitwhen u == null or not s__Missiles_allocated[this]
                        if not HaveSavedBoolean(s__Missiles_Missiles___table, this, GetHandleId(u)) then
                            if IsUnitInRangeXY(u, s__Missiles_x[this], s__Missiles_y[this], s__Missiles_collision[this]) then
                                if s__Missiles_collideZ[this] then
                                    set dx=Missiles___GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u)
                                    set dy=Missiles___GetUnitCollisionSize(u)
                                    if dx + dy >= s__Missiles_z[this] - s__Missiles_collision[this] and dx <= s__Missiles_z[this] + s__Missiles_collision[this] then
                                        call SaveBoolean(s__Missiles_Missiles___table, this, GetHandleId(u), true)
                                        set stop=sc__Missiles___MissileEvents_onHit(this,u)
                                        if s__Missiles_allocated[this] and stop then
                                            call s__Missiles_terminate(this)
                                        endif
                                        exitwhen not s__Missiles_allocated[this]
                                    endif
                                else
                                    call SaveBoolean(s__Missiles_Missiles___table, this, GetHandleId(u), true)
                                    set stop=sc__Missiles___MissileEvents_onHit(this,u)
                                    if s__Missiles_allocated[this] and stop then
                                        call s__Missiles_terminate(this)
                                    endif
                                    exitwhen not s__Missiles_allocated[this]
                                endif
                            endif
                        endif
                    call GroupRemoveUnit(s__Missiles_group, u)
                endloop
            endif
        endif
                        if s__Missiles_allocated[this] then
        if (st__Missiles___MissileEvents_onMissile[si__Missiles___MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                set k=0
                loop
                    exitwhen k > s__Missiles_count or not s__Missiles_allocated[this]
                        set missile=s__Missiles_collection[k]
                        if missile != this and s__Missiles_allocated[missile] then
                            if LoadInteger(s__Missiles_missileHits, this, missile) != s__Missiles_generation[missile] then
                                set dx=s__Missiles_x[missile] - s__Missiles_x[this]
                                set dy=s__Missiles_y[missile] - s__Missiles_y[this]
                                if SquareRoot(dx * dx + dy * dy) <= s__Missiles_collision[this] then
                                    call SaveInteger(s__Missiles_missileHits, this, missile, s__Missiles_generation[missile])
                                    set stop=sc__Missiles___MissileEvents_onMissile(this,missile)
                                    if s__Missiles_allocated[this] and stop then
                                        call s__Missiles_terminate(this)
                                    endif
                                    exitwhen not s__Missiles_allocated[this]
                                endif
                            endif
                        endif
                    set k=k + 1
                endloop
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
        if (st__Missiles___MissileEvents_onDestructable[si__Missiles___MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                set dx=s__Missiles_collision[this] + Missiles___COLLISION_SIZE
                call SetRect(s__Missiles_rect, s__Missiles_x[this] - dx, s__Missiles_y[this] - dx, s__Missiles_x[this] + dx, s__Missiles_y[this] + dx)
                call EnumDestructablesInRect(s__Missiles_rect, null, function s__Missiles_onDest)
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
        if (st__Missiles___MissileEvents_onItem[si__Missiles___MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                set dx=s__Missiles_collision[this] + Missiles___COLLISION_SIZE
                call SetRect(s__Missiles_rect, s__Missiles_x[this] - dx, s__Missiles_y[this] - dx, s__Missiles_x[this] + dx, s__Missiles_y[this] + dx)
                call EnumItemsInRect(s__Missiles_rect, null, function s__Missiles_onItems)
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
        if (st__Missiles___MissileEvents_onCliff[si__Missiles___MissileEvents_type[this]]!=null) then
            set dx=GetTerrainCliffLevel(s__Missiles_nextX[this], s__Missiles_nextY[this])
            set dy=GetTerrainCliffLevel(s__Missiles_x[this], s__Missiles_y[this])
            if dy < dx and s__Missiles_z[this] < ( dx - (GetTerrainCliffLevel(s__WorldBounds_maxX, s__WorldBounds_maxY)) ) * bj_CLIFFHEIGHT then // INLINED!!
                set stop=sc__Missiles___MissileEvents_onCliff(this)
                if s__Missiles_allocated[this] and stop then
                    call s__Missiles_terminate(this)
                endif
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
        if (st__Missiles___MissileEvents_onTerrain[si__Missiles___MissileEvents_type[this]]!=null) then
            if Missiles___GetLocZ(s__Missiles_x[this] , s__Missiles_y[this]) > s__Missiles_z[this] then
                set stop=sc__Missiles___MissileEvents_onTerrain(this)
                if s__Missiles_allocated[this] and stop then
                    call s__Missiles_terminate(this)
                endif
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
        if (st__Missiles___MissileEvents_onTileset[si__Missiles___MissileEvents_type[this]]!=null) then
            set k=GetTerrainType(s__Missiles_x[this], s__Missiles_y[this])
            if k != s__Missiles_tileset[this] then
                set stop=sc__Missiles___MissileEvents_onTileset(this,k)
                if s__Missiles_allocated[this] and stop then
                    call s__Missiles_terminate(this)
                endif
            endif
            if s__Missiles_allocated[this] then
                set s__Missiles_tileset[this]=k
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
        if (st__Missiles___MissileEvents_onPeriod[si__Missiles___MissileEvents_type[this]]!=null) then
            set stop=sc__Missiles___MissileEvents_onPeriod(this)
            if s__Missiles_allocated[this] and stop then
                call s__Missiles_terminate(this)
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
        set u=s__Missiles_target[this]
        if u != null and GetUnitTypeId(u) != 0 then
            call s__Missiles___Coordinates_move(s__Missiles_impact[this],GetUnitX(u) , GetUnitY(u) , GetUnitFlyHeight(u) + s__Missiles_toZ[this])
            set dx=s__Missiles___Coordinates_x[s__Missiles_impact[this]] - s__Missiles_baseX[this]
            set dy=s__Missiles___Coordinates_y[s__Missiles_impact[this]] - s__Missiles_baseY[this]
            set a=Atan2(dy, dx)
            set s__Missiles_progress[this]=s__Missiles___Coordinates_distance[s__Missiles_origin[this]] - SquareRoot(dx * dx + dy * dy)
        else
            set a=s__Missiles___Coordinates_angle[s__Missiles_origin[this]]
            set s__Missiles_target[this]=null
        endif
        set o=s__Missiles_origin[this]
        set d=s__Missiles___Coordinates_distance[o]
        set h=s__Missiles_height[this]
        set c=s__Missiles_open[this]
        if s__Missiles_turn[this] != 0 and not ( Cos(s__Missiles_cA[this] - a) >= Cos(s__Missiles_turn[this]) ) then
            if Sin(a - s__Missiles_cA[this]) >= 0 then
                set s__Missiles_cA[this]=s__Missiles_cA[this] + s__Missiles_turn[this]
            else
                set s__Missiles_cA[this]=s__Missiles_cA[this] - s__Missiles_turn[this]
            endif
        else
            set s__Missiles_cA[this]=a
        endif
        call s__Missiles_predict(this)
        set s__Missiles_prevX[this]=s__Missiles_x[this]
        set s__Missiles_prevY[this]=s__Missiles_y[this]
        set s__Missiles_prevZ[this]=s__Missiles_z[this]
        set s__Missiles_x[this]=s__Missiles_nextX[this]
        set s__Missiles_y[this]=s__Missiles_nextY[this]
        set s__Missiles_z[this]=s__Missiles_nextZ[this]
        set s__Missiles_baseX[this]=s__Missiles_nextBaseX[this]
        set s__Missiles_baseY[this]=s__Missiles_nextBaseY[this]
        set s__Missiles_progress[this]=s__Missiles_nextProgress[this]
        set s=s__Missiles_progress[this]
        set s__Missiles_veloc[this]=s__Missiles_veloc[this] + s__Missiles_acceleration[this]
        call s__Missiles_predict(this)
        set s__Missiles_travel[this]=s__Missiles_nextProgress[this]
        set pitch=s__Missiles___Coordinates_alpha[o] - Atan(4 * h * ( 2 * s - d ) / ( d * d )) * bj_RADTODEG
        set yaw=( s__Missiles_cA[this] + Atan(- 4 * c * ( 2 * s - d ) / ( d * d )) ) * bj_RADTODEG
        call s__Missiles_refreshVision(this)
        if s >= d then
            set s__Missiles_finished[this]=true
            if (st__Missiles___MissileEvents_onFinish[si__Missiles___MissileEvents_type[this]]!=null) then
                set stop=sc__Missiles___MissileEvents_onFinish(this)
                if s__Missiles_allocated[this] then
                    if stop then
                        call s__Missiles_terminate(this)
                    elseif s__Missiles_travel[this] > 0 and not s__Missiles_paused[this] then
                        call s__Missiles_terminate(this)
                    endif
                endif
            else
                call s__Missiles_terminate(this)
            endif
        endif
        if s__Missiles_allocated[this] then
            call SetUnitAnimationByIndex(s__Missiles_dummy[this], R2I(pitch + 90.5))
            call SetUnitFacing(s__Missiles_dummy[this], yaw)
        endif
                        endif
                        if s__Missiles_allocated[this] then
        if not ( s__Missiles_x[this] > s__WorldBounds_maxX or s__Missiles_x[this] < s__WorldBounds_minX or s__Missiles_y[this] > s__WorldBounds_maxY or s__Missiles_y[this] < s__WorldBounds_minY ) then
            call SetUnitX(s__Missiles_dummy[this], s__Missiles_x[this])
            call SetUnitY(s__Missiles_dummy[this], s__Missiles_y[this])
            call Missiles___SetUnitZ(s__Missiles_dummy[this] , s__Missiles_z[this])
        else
            if (st__Missiles___MissileEvents_onBoundaries[si__Missiles___MissileEvents_type[this]]!=null) then
                set stop=sc__Missiles___MissileEvents_onBoundaries(this)
                if s__Missiles_allocated[this] and stop then
                    call s__Missiles_terminate(this)
                endif
            endif
        endif
                        endif
                    else
                        set i=s__Missiles_remove(this,i)
                        set j=j - 1
                    endif
                set i=i + 1
                set j=j + 1
                if i > s__Missiles_id and Missiles_SWEET_SPOT > 0 then
                    set i=0
                endif
            endloop
            set s__Missiles_last=i
            set u=null
   return true
endfunction
function sa__Missiles_create takes nothing returns boolean
local real x=f__arg_real1
local real y=f__arg_real2
local real z=f__arg_real3
local real toX=f__arg_real4
local real toY=f__arg_real5
local real toZ=f__arg_real6
            local integer this= s__Missiles__allocate()
            local real face= Atan2(toY - y, toX - x) * bj_RADTODEG
            call s__Missiles_reset(this)
            call s__Missiles_flushAll(this)
            set s__Missiles_active[this]=false
            set s__Missiles_pins[this]=0
            set s__Missiles_generation[this]=s__Missiles_generation[this] + 1
            set s__Missiles_origin[this]=s__Missiles___Coordinates_create(x , y , z)
            set s__Missiles_impact[this]=s__Missiles___Coordinates_create(toX , toY , toZ)
            call s__Missiles___Coordinates_link(s__Missiles_origin[this] , s__Missiles_impact[this])
            set s__Missiles_allocated[this]=true
            set s__Missiles_cA[this]=s__Missiles___Coordinates_angle[s__Missiles_origin[this]]
            set s__Missiles_x[this]=x
            set s__Missiles_y[this]=y
            set s__Missiles_z[this]=s__Missiles___Coordinates_z[s__Missiles_origin[this]]
            set s__Missiles_prevX[this]=x
            set s__Missiles_prevY[this]=y
            set s__Missiles_prevZ[this]=s__Missiles___Coordinates_z[s__Missiles_origin[this]]
            set s__Missiles_nextX[this]=x
            set s__Missiles_nextY[this]=y
            set s__Missiles_nextZ[this]=s__Missiles___Coordinates_z[s__Missiles_origin[this]]
            set s__Missiles_toZ[this]=toZ
            set s__Missiles_baseX[this]=x
            set s__Missiles_baseY[this]=y
            set s__Missiles_nextBaseX[this]=x
            set s__Missiles_nextBaseY[this]=y
                set s__Missiles_dummy[this]=GetRecycledDummy(x , y , z , face)
            call Missiles___SetUnitZ(s__Missiles_dummy[this] , s__Missiles___Coordinates_z[s__Missiles_origin[this]])
set f__result_integer= this
   return true
endfunction
function sa__RFBurstPair___RBProjectile_onHit takes nothing returns boolean
    set f__result_boolean=s__RFBurstPair___RBProjectile_onHit(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__RFBurstPair___RBProjectile_onPeriod takes nothing returns boolean
local integer this=f__arg_this
set f__result_boolean= not RFBurstPair___LiveOwned(s__RFBurstPair___RBProjectile_savedActor[this] , s__RFBurstPair___RBProjectile_savedOwner[this])
   return true
endfunction
function sa__RFBurstPair___RBProjectile_onRemove takes nothing returns boolean
local integer this=f__arg_this
            set s__RFBurstPair___RBProjectile_savedActor[this]=null
            set s__RFBurstPair___RBProjectile_savedController[this]=null
            set s__RFBurstPair___RBProjectile_savedOwner[this]=null
            set s__RFBurstPair___RBProjectile_spent[this]=true
   return true
endfunction
function sa___prototype3_TimerUtils__init takes nothing returns boolean

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
                call SaveInteger(TimerUtils__ht, 0, GetHandleId((s__TimerUtils__tT[i] )), ( TimerUtils__HELD)) // INLINED!!
                set i=i + 1
            endloop
            set TimerUtils__tN=TimerUtils__QUANTITY
    return true
endfunction

function jasshelper__init6441 takes nothing returns nothing
    set st__Missiles___MissileEvents_onHit[6]=null
    set st__Missiles___MissileEvents_onMissile[6]=null
    set st__Missiles___MissileEvents_onMissile[7]=null
    set st__Missiles___MissileEvents_onDestructable[6]=null
    set st__Missiles___MissileEvents_onDestructable[7]=null
    set st__Missiles___MissileEvents_onItem[6]=null
    set st__Missiles___MissileEvents_onItem[7]=null
    set st__Missiles___MissileEvents_onCliff[6]=null
    set st__Missiles___MissileEvents_onCliff[7]=null
    set st__Missiles___MissileEvents_onTerrain[6]=null
    set st__Missiles___MissileEvents_onTerrain[7]=null
    set st__Missiles___MissileEvents_onTileset[6]=null
    set st__Missiles___MissileEvents_onTileset[7]=null
    set st__Missiles___MissileEvents_onPeriod[6]=null
    set st__Missiles___MissileEvents_onFinish[6]=null
    set st__Missiles___MissileEvents_onFinish[7]=null
    set st__Missiles___MissileEvents_onBoundaries[6]=null
    set st__Missiles___MissileEvents_onBoundaries[7]=null
    set st__Missiles___MissileEvents_onPause[6]=null
    set st__Missiles___MissileEvents_onPause[7]=null
    set st__Missiles___MissileEvents_onResume[6]=null
    set st__Missiles___MissileEvents_onResume[7]=null
    set st__Missiles___MissileEvents_onRemove[6]=null
    set st__Missiles_terminate=CreateTrigger()
    call TriggerAddCondition(st__Missiles_terminate,Condition( function sa__Missiles_terminate))
    set st__Missiles_reset=CreateTrigger()
    call TriggerAddCondition(st__Missiles_reset,Condition( function sa__Missiles_reset))
    set st__Missiles_release=CreateTrigger()
    call TriggerAddCondition(st__Missiles_release,Condition( function sa__Missiles_release))
    set st__Missiles_move=CreateTrigger()
    call TriggerAddCondition(st__Missiles_move,Condition( function sa__Missiles_move))
    set st__Missiles_create=CreateTrigger()
    call TriggerAddCondition(st__Missiles_create,Condition( function sa__Missiles_create))
    set st__Missiles___MissileEvents_onDestroy[6]=null
    set st__Missiles___MissileEvents_onDestroy[7]=null
    set st__Missiles___MissileEvents_onHit[7]=CreateTrigger()
    call TriggerAddCondition(st__Missiles___MissileEvents_onHit[7],Condition( function sa__RFBurstPair___RBProjectile_onHit))
    call TriggerAddAction(st__Missiles___MissileEvents_onHit[7], function sa__RFBurstPair___RBProjectile_onHit)
    set st__Missiles___MissileEvents_onPeriod[7]=CreateTrigger()
    call TriggerAddCondition(st__Missiles___MissileEvents_onPeriod[7],Condition( function sa__RFBurstPair___RBProjectile_onPeriod))
    call TriggerAddAction(st__Missiles___MissileEvents_onPeriod[7], function sa__RFBurstPair___RBProjectile_onPeriod)
    set st__Missiles___MissileEvents_onRemove[7]=CreateTrigger()
    call TriggerAddCondition(st__Missiles___MissileEvents_onRemove[7],Condition( function sa__RFBurstPair___RBProjectile_onRemove))
    call TriggerAddAction(st__Missiles___MissileEvents_onRemove[7], function sa__RFBurstPair___RBProjectile_onRemove)
    set st___prototype3[1]=CreateTrigger()
    call TriggerAddAction(st___prototype3[1],function sa___prototype3_TimerUtils__init)
    call TriggerAddCondition(st___prototype3[1],Condition(function sa___prototype3_TimerUtils__init))


call ExecuteFunc("TimerUtils__init")
//------------------------------------
call ExecuteFunc("s__WorldBounds_WorldBounds___WorldBoundInit__onInit")
//------------------------------------
call ExecuteFunc("s__DummyRecycler__S_DummyRecycler__M__onInit")
//------------------------------------

endfunction

