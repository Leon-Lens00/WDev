globals
//globals from RFBurstLog:
constant boolean LIBRARY_RFBurstLog=true
constant string RB_RUN_ID= "rf-burst-recast-red-20261020-02"
string array RFBurstLog___rows
integer RFBurstLog___count= 0
integer RFBurstLog___cases= 0
integer RFBurstLog___checks= 0
integer RFBurstLog___failures= 0
string RFBurstLog___current= ""
trigger RFBurstLog___writer= null
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
//globals from DummyRecycler:
constant boolean LIBRARY_DummyRecycler=true
        //The rawcode of the Dummy Unit
constant integer DummyRecycler___DUMMY_ID= 'e000'
     
        //The owner of the Dummy Unit
constant player DummyRecycler___OWNER= Player(PLAYER_NEUTRAL_PASSIVE)
     
        //The number of indexed angle. The higher the value the:
        // - Lesser the turning time for the Dummy Units.
        // - Higher the total number of Dummy Units created at Map Initialization.
        //          Recommended Value: 10 (Max difference of 18 degrees)
constant integer DummyRecycler___ANGLES_COUNT= 10
     
        //The number of Dummy units per ANGLES_COUNT. The higher the value the:
        // - Higher the number of units that can be recycled per angle, when
        //   no more units are in queue, the system will resort to use CreateUnit.
        // - Higher the total number of Dummy Units created at Map Initialization.
        //    Recommended Value: 3 to 5 (for less overhead in Map Loading Screen)
constant integer DummyRecycler___STORED_UNIT_COUNT= 3
     
        //The maximum number of Dummy units that can exist. When the system resort
        //to using CreateUnit, the unit will be permanently added to the Dummy
        //List. To avoid spamming Dummy Units and having too much free Dummy
        //Units to allocate, the maximum number of Dummy Units is capped.
        //               Recommended Value: 80 to 120
constant integer DummyRecycler___MAX_DUMMY_COUNT= 100
     
        //When a certain angle have less than BORROW_REQUEST units in its list,
        //it will start to borrow Dummy Units from the list with the highest
        //Dummy Unit count.
        //      Recommended Value: Half of maximum STORED_UNIT_COUNT
constant integer DummyRecycler___BORROW_REQUEST= 5
     
        //It will only return a Dummy if the current dummy is close
        //to it's appropriate facing angle. This is to avoid returning
        //a Dummy which is still turning to face it's list angle.
constant real DummyRecycler___ANGLE_TOLERANCE= 10.0
     
        //An additional option to automatically hide recycled dummy units in the
        //corner of the map camera bounds
constant boolean DummyRecycler___HIDE_ON_MAP_CORNER= true
integer DummyRecycler___dummyCount= DummyRecycler___ANGLES_COUNT * DummyRecycler___STORED_UNIT_COUNT
real array DummyRecycler___angle
integer array DummyRecycler___count
integer array DummyRecycler___countHead
integer array DummyRecycler___countNext
integer array DummyRecycler___countPrev
integer array DummyRecycler___next
integer array DummyRecycler___prev
unit array DummyRecycler___dummy
integer DummyRecycler___upper
integer DummyRecycler___lower
integer DummyRecycler___lastInstance
constant real DummyRecycler___FACING_OFFSET= 180.0 / DummyRecycler___ANGLES_COUNT
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
constant real Missiles__COLLISION_SIZE= 128.
        // item size used in z collision
constant real Missiles__ITEM_SIZE= 16.
        // The raw code of the dummy unit.
constant integer Missiles__DUMMY= 'e000'
        // How long takes for the missile to be removed.
        // This is necessary so the death animation of the
        // effect can play through
constant real Missiles__RECYCLE_TIME= 2.
        // Needed, don't touch.
location Missiles__LOC= Location(0., 0.)
hashtable Missiles__table= InitHashtable()
//endglobals from Missiles
//globals from RFBurstPair:
constant boolean LIBRARY_RFBurstPair=true
constant real RFBurstPair__CADENCE= .25
constant real RFBurstPair__RANGE= 1500.
constant real RFBurstPair__SPEED= 1200.
constant real RFBurstPair__HIT_RADIUS= 32.
constant real RFBurstPair__LAUNCH_HEIGHT= 80.
unit RFBurstPair__actor= null
unit RFBurstPair__controller= null
player RFBurstPair__pairOwner= null
trigger RFBurstPair__castHook= null
trigger RFBurstPair__observer= null
timer RFBurstPair__fireTimer= null
location RFBurstPair__terrain= null
integer RFBurstPair__epoch= 0
integer RFBurstPair__remaining= 0
boolean RFBurstPair__notifying= false
real RFBurstPair__heading= 0.
integer RFBurstPair__shot= 0
unit RFBurstPair__shotSource= null
real RFBurstPair__shotX= 0.
real RFBurstPair__shotY= 0.
//endglobals from RFBurstPair
//globals from RFBurstRecastTest:
constant boolean LIBRARY_RFBurstRecastTest=true
constant real RFBurstRecastTest___PERIOD= .03125
constant real RFBurstRecastTest___CADENCE_TOLERANCE= .03125
constant real RFBurstRecastTest___HP_TOLERANCE= .10
unit RFBurstRecastTest___actor= null
unit RFBurstRecastTest___caster= null
unit RFBurstRecastTest___target= null
unit RFBurstRecastTest___control= null
timer RFBurstRecastTest___clock= null
timer RFBurstRecastTest___runner= null
trigger RFBurstRecastTest___damageHook= null
trigger RFBurstRecastTest___spellHook= null
trigger RFBurstRecastTest___shotHook= null
integer RFBurstRecastTest___phase= 0
boolean RFBurstRecastTest___done= false
boolean RFBurstRecastTest___calibrated= false
integer RFBurstRecastTest___calibrationHits= 0
real RFBurstRecastTest___calibrationHP= 0.
real RFBurstRecastTest___calibrationDamage= 0.
boolean RFBurstRecastTest___calibrationSource= false
integer RFBurstRecastTest___controlHits= 0
integer RFBurstRecastTest___hits= 0
boolean RFBurstRecastTest___hitValuesOK= true
boolean RFBurstRecastTest___hitSourcesOK= true
integer RFBurstRecastTest___shots= 0
boolean RFBurstRecastTest___projectilesOK= true
real array RFBurstRecastTest___shotTime
integer RFBurstRecastTest___castEvents= 0
real RFBurstRecastTest___orderTime= 0.
real RFBurstRecastTest___castTime= 0.
real RFBurstRecastTest___aimX= 0.
real RFBurstRecastTest___aimY= 0.
real RFBurstRecastTest___targetStart= 0.
real RFBurstRecastTest___controlStart= 0.
boolean RFBurstRecastTest___recastCase= false
integer RFBurstRecastTest___expectedCast= 0
boolean RFBurstRecastTest___pendingRecast= false
boolean RFBurstRecastTest___recastRequested= false
boolean RFBurstRecastTest___recastQualified= false
boolean RFBurstRecastTest___earlyPulse= false
real RFBurstRecastTest___recastDue= 0.
real RFBurstRecastTest___recastIssue= 0.
real RFBurstRecastTest___recastEffect= 0.
integer RFBurstRecastTest___recastEffectShots= 0
//endglobals from RFBurstRecastTest


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
constant integer si__DummyRecycler___S=2
hashtable s__DummyRecycler___S_hash= InitHashtable()
constant integer si__Missiles__MissileEvents=3
integer si__Missiles__MissileEvents_F=0
integer si__Missiles__MissileEvents_I=0
integer array si__Missiles__MissileEvents_V
integer array si__Missiles__MissileEvents_type
trigger array st__Missiles__MissileEvents_onDestroy
trigger array st__Missiles__MissileEvents_onHit
trigger array st__Missiles__MissileEvents_onMissile
trigger array st__Missiles__MissileEvents_onDestructable
trigger array st__Missiles__MissileEvents_onItem
trigger array st__Missiles__MissileEvents_onCliff
trigger array st__Missiles__MissileEvents_onTerrain
trigger array st__Missiles__MissileEvents_onTileset
trigger array st__Missiles__MissileEvents_onPeriod
trigger array st__Missiles__MissileEvents_onFinish
trigger array st__Missiles__MissileEvents_onBoundaries
trigger array st__Missiles__MissileEvents_onPause
trigger array st__Missiles__MissileEvents_onResume
trigger array st__Missiles__MissileEvents_onRemove
constant integer si__Missiles__Pool=4
integer si__Missiles__Pool_F=0
integer si__Missiles__Pool_I=0
integer array si__Missiles__Pool_V
player s__Missiles__Pool_player= Player(PLAYER_NEUTRAL_PASSIVE)
timer array s__Missiles__Pool_timer
unit array s__Missiles__Pool_unit
constant integer si__Missiles__Coordinates=5
integer si__Missiles__Coordinates_F=0
integer si__Missiles__Coordinates_I=0
integer array si__Missiles__Coordinates_V
real array s__Missiles__Coordinates_x
real array s__Missiles__Coordinates_y
real array s__Missiles__Coordinates_z
real array s__Missiles__Coordinates_angle
real array s__Missiles__Coordinates_distance
real array s__Missiles__Coordinates_square
real array s__Missiles__Coordinates_slope
real array s__Missiles__Coordinates_alpha
integer array s__Missiles__Coordinates_ref
constant integer si__Missiles=6
timer s__Missiles_timer= CreateTimer()
group s__Missiles_group= CreateGroup()
rect s__Missiles_rect= Rect(0., 0., 0., 0.)
hashtable s__Missiles_Missiles__table= InitHashtable()
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
constant integer si__RFBurstPair__RBProjectile=7
unit array s__RFBurstPair__RBProjectile_savedActor
unit array s__RFBurstPair__RBProjectile_savedController
player array s__RFBurstPair__RBProjectile_savedOwner
boolean array s__RFBurstPair__RBProjectile_spent
integer array s__TimerUtils___data
timer array s__TimerUtils___tT
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


//Generated method caller for Missiles__MissileEvents.onHit
function sc__Missiles__MissileEvents_onHit takes integer this,unit hit returns boolean
    set f__arg_this=this
    set f__arg_unit1=hit
    //An error in the next line would mean declaration for Missiles__MissileEvents.onHit had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles__MissileEvents_onHit[si__Missiles__MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles__MissileEvents.onHit
function sx__Missiles__MissileEvents_onHit takes integer this,unit hit returns nothing
    set f__arg_this=this
    set f__arg_unit1=hit
    call TriggerExecute(st__Missiles__MissileEvents_onHit[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles__MissileEvents.onMissile
function sc__Missiles__MissileEvents_onMissile takes integer this,integer missile returns boolean
    set f__arg_this=this
    set f__arg_integer1=missile
    //An error in the next line would mean declaration for Missiles__MissileEvents.onMissile had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles__MissileEvents_onMissile[si__Missiles__MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles__MissileEvents.onMissile
function sx__Missiles__MissileEvents_onMissile takes integer this,integer missile returns nothing
    set f__arg_this=this
    set f__arg_integer1=missile
    call TriggerExecute(st__Missiles__MissileEvents_onMissile[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles__MissileEvents.onDestructable
function sc__Missiles__MissileEvents_onDestructable takes integer this,destructable dest returns boolean
    set f__arg_this=this
    set f__arg_destructable1=dest
    //An error in the next line would mean declaration for Missiles__MissileEvents.onDestructable had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles__MissileEvents_onDestructable[si__Missiles__MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles__MissileEvents.onDestructable
function sx__Missiles__MissileEvents_onDestructable takes integer this,destructable dest returns nothing
    set f__arg_this=this
    set f__arg_destructable1=dest
    call TriggerExecute(st__Missiles__MissileEvents_onDestructable[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles__MissileEvents.onItem
function sc__Missiles__MissileEvents_onItem takes integer this,item i returns boolean
    set f__arg_this=this
    set f__arg_item1=i
    //An error in the next line would mean declaration for Missiles__MissileEvents.onItem had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles__MissileEvents_onItem[si__Missiles__MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles__MissileEvents.onItem
function sx__Missiles__MissileEvents_onItem takes integer this,item i returns nothing
    set f__arg_this=this
    set f__arg_item1=i
    call TriggerExecute(st__Missiles__MissileEvents_onItem[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles__MissileEvents.onCliff
function sc__Missiles__MissileEvents_onCliff takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles__MissileEvents.onCliff had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles__MissileEvents_onCliff[si__Missiles__MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles__MissileEvents.onCliff
function sx__Missiles__MissileEvents_onCliff takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles__MissileEvents_onCliff[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles__MissileEvents.onTerrain
function sc__Missiles__MissileEvents_onTerrain takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles__MissileEvents.onTerrain had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles__MissileEvents_onTerrain[si__Missiles__MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles__MissileEvents.onTerrain
function sx__Missiles__MissileEvents_onTerrain takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles__MissileEvents_onTerrain[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles__MissileEvents.onTileset
function sc__Missiles__MissileEvents_onTileset takes integer this,integer tileset returns boolean
    set f__arg_this=this
    set f__arg_integer1=tileset
    //An error in the next line would mean declaration for Missiles__MissileEvents.onTileset had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles__MissileEvents_onTileset[si__Missiles__MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles__MissileEvents.onTileset
function sx__Missiles__MissileEvents_onTileset takes integer this,integer tileset returns nothing
    set f__arg_this=this
    set f__arg_integer1=tileset
    call TriggerExecute(st__Missiles__MissileEvents_onTileset[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles__MissileEvents.onPeriod
function sc__Missiles__MissileEvents_onPeriod takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles__MissileEvents.onPeriod had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles__MissileEvents_onPeriod[si__Missiles__MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles__MissileEvents.onPeriod
function sx__Missiles__MissileEvents_onPeriod takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles__MissileEvents_onPeriod[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles__MissileEvents.onFinish
function sc__Missiles__MissileEvents_onFinish takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles__MissileEvents.onFinish had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles__MissileEvents_onFinish[si__Missiles__MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles__MissileEvents.onFinish
function sx__Missiles__MissileEvents_onFinish takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles__MissileEvents_onFinish[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles__MissileEvents.onBoundaries
function sc__Missiles__MissileEvents_onBoundaries takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles__MissileEvents.onBoundaries had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles__MissileEvents_onBoundaries[si__Missiles__MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles__MissileEvents.onBoundaries
function sx__Missiles__MissileEvents_onBoundaries takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles__MissileEvents_onBoundaries[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles__MissileEvents.onPause
function sc__Missiles__MissileEvents_onPause takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles__MissileEvents.onPause had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles__MissileEvents_onPause[si__Missiles__MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles__MissileEvents.onPause
function sx__Missiles__MissileEvents_onPause takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles__MissileEvents_onPause[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles__MissileEvents.onResume
function sc__Missiles__MissileEvents_onResume takes integer this returns boolean
    set f__arg_this=this
    //An error in the next line would mean declaration for Missiles__MissileEvents.onResume had a wrong default (false)
    set f__result_boolean=false
    call TriggerEvaluate(st__Missiles__MissileEvents_onResume[si__Missiles__MissileEvents_type[this]])
 return f__result_boolean
endfunction

//Generated method executor for Missiles__MissileEvents.onResume
function sx__Missiles__MissileEvents_onResume takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles__MissileEvents_onResume[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method caller for Missiles__MissileEvents.onRemove
function sc__Missiles__MissileEvents_onRemove takes integer this returns nothing
    set f__arg_this=this
    call TriggerEvaluate(st__Missiles__MissileEvents_onRemove[si__Missiles__MissileEvents_type[this]])
endfunction

//Generated method executor for Missiles__MissileEvents.onRemove
function sx__Missiles__MissileEvents_onRemove takes integer this returns nothing
    set f__arg_this=this
    call TriggerExecute(st__Missiles__MissileEvents_onRemove[si__Missiles__MissileEvents_type[this]])
endfunction
//Generated destructor of Missiles__MissileEvents
function sc__Missiles__MissileEvents_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Missiles__MissileEvents_V[this]!=-1) then
        return
    endif
    set f__arg_this=this
    call TriggerEvaluate(st__Missiles__MissileEvents_onDestroy[si__Missiles__MissileEvents_type[this]])
    set si__Missiles__MissileEvents_V[this]=si__Missiles__MissileEvents_F
    set si__Missiles__MissileEvents_F=this
endfunction

//Generated allocator of Missiles__Coordinates
function s__Missiles__Coordinates__allocate takes nothing returns integer
 local integer this=si__Missiles__Coordinates_F
    if (this!=0) then
        set si__Missiles__Coordinates_F=si__Missiles__Coordinates_V[this]
    else
        set si__Missiles__Coordinates_I=si__Missiles__Coordinates_I+1
        set this=si__Missiles__Coordinates_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Missiles__Coordinates_V[this]=-1
 return this
endfunction

//Generated destructor of Missiles__Coordinates
function s__Missiles__Coordinates_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Missiles__Coordinates_V[this]!=-1) then
        return
    endif
    set si__Missiles__Coordinates_V[this]=si__Missiles__Coordinates_F
    set si__Missiles__Coordinates_F=this
endfunction

//Generated allocator of Missiles__Pool
function s__Missiles__Pool__allocate takes nothing returns integer
 local integer this=si__Missiles__Pool_F
    if (this!=0) then
        set si__Missiles__Pool_F=si__Missiles__Pool_V[this]
    else
        set si__Missiles__Pool_I=si__Missiles__Pool_I+1
        set this=si__Missiles__Pool_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Missiles__Pool_V[this]=-1
 return this
endfunction

//Generated destructor of Missiles__Pool
function s__Missiles__Pool_deallocate takes integer this returns nothing
    if this==null then
        return
    elseif (si__Missiles__Pool_V[this]!=-1) then
        return
    endif
    set si__Missiles__Pool_V[this]=si__Missiles__Pool_F
    set si__Missiles__Pool_F=this
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
 local integer this=si__Missiles__MissileEvents_F
    if (this!=0) then
        set si__Missiles__MissileEvents_F=si__Missiles__MissileEvents_V[this]
    else
        set si__Missiles__MissileEvents_I=si__Missiles__MissileEvents_I+1
        set this=si__Missiles__MissileEvents_I
    endif
    if (this>8190) then
        return 0
    endif

    set si__Missiles__MissileEvents_type[this]=6
    set kthis=this

    set si__Missiles__MissileEvents_V[this]=-1
 return this
endfunction


//Generated method caller for RFBurstPair__RBProjectile.onHit
function sc__RFBurstPair__RBProjectile_onHit takes integer this,unit hit returns boolean
    set f__arg_this=this
    set f__arg_unit1=hit
    call TriggerEvaluate(st__Missiles__MissileEvents_onHit[7])
 return f__result_boolean
endfunction

//Generated method caller for RFBurstPair__RBProjectile.onPeriod
function sc__RFBurstPair__RBProjectile_onPeriod takes integer this returns boolean
    set f__arg_this=this
    call TriggerEvaluate(st__Missiles__MissileEvents_onPeriod[7])
 return f__result_boolean
endfunction

//Generated method caller for RFBurstPair__RBProjectile.onRemove
function sc__RFBurstPair__RBProjectile_onRemove takes integer this returns nothing
            // Core owns allocator/dummy/effect/coordinates and their cleanup.
            set s__RFBurstPair__RBProjectile_savedActor[this]=null
            set s__RFBurstPair__RBProjectile_savedController[this]=null
            set s__RFBurstPair__RBProjectile_savedOwner[this]=null
            set s__RFBurstPair__RBProjectile_spent[this]=true
endfunction

//Generated allocator of RFBurstPair__RBProjectile
function s__RFBurstPair__RBProjectile__allocate takes real x ,real y ,real z ,real toX ,real toY ,real toZ returns integer
 local integer this=sc__Missiles_create(x,y,z,toX,toY,toZ)
 local integer kthis
    if(this==0) then
        return 0
    endif
    set si__Missiles__MissileEvents_type[this]=7
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

    function RFBurstLog___Snapshot takes nothing returns boolean
        local integer i= 0
        call PreloadGenClear()
        call PreloadGenStart()
        loop
            exitwhen i >= RFBurstLog___count
            call Preload(RFBurstLog___rows[i])
            set i=i + 1
        endloop
        call PreloadGenEnd("Logs\\RF-rf-burst-recast-red-20261020-02.txt")
        return true
    endfunction

    function RFBurstLog___Log takes string text returns nothing
        set RFBurstLog___rows[RFBurstLog___count]="RM28|" + RB_RUN_ID + "|" + text
        set RFBurstLog___count=RFBurstLog___count + 1
        call TriggerEvaluate(RFBurstLog___writer)
    endfunction

    function RB_LogBegin takes nothing returns nothing
        set RFBurstLog___writer=CreateTrigger()
        call TriggerAddCondition(RFBurstLog___writer, Condition(function RFBurstLog___Snapshot))
        call RFBurstLog___Log("BEGIN|RFBurstRecast")
    endfunction

    function RB_LogCase takes string id returns nothing
        set RFBurstLog___current=id
        set RFBurstLog___cases=RFBurstLog___cases + 1
        call RFBurstLog___Log("CASE|" + id)
    endfunction

    function RB_LogRecord takes string status,string name,string detail returns nothing
        set RFBurstLog___checks=RFBurstLog___checks + 1
        if status == "FAIL" then
            set RFBurstLog___failures=RFBurstLog___failures + 1
        endif
        call RFBurstLog___Log("CHECK|" + RFBurstLog___current + "|" + status + "|" + name + "|" + detail)
    endfunction

    function RB_LogCheck takes boolean ok,string name,string detail returns nothing
        if ok then
            call RB_LogRecord("PASS" , name , detail)
        else
            call RB_LogRecord("FAIL" , name , detail)
        endif
    endfunction

    function RB_LogComplete takes nothing returns nothing
        call RFBurstLog___Log("COMPLETE|" + I2S(RFBurstLog___cases) + "|" + I2S(RFBurstLog___checks) + "|" + I2S(RFBurstLog___failures) + "|0")
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 120., "Burst RED complete: failures=" + I2S(RFBurstLog___failures))
        call DestroyTrigger(RFBurstLog___writer)
        set RFBurstLog___writer=null
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
                call TriggerEvaluate(st___prototype3[(1)]) // INLINED!!
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


    
//Implemented from module WorldBounds__WorldBoundInit:

    function s__WorldBounds_WorldBounds__WorldBoundInit___onInit takes nothing returns nothing
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
 
 
 



















 
 
//Implemented from module DummyRecycler___M:
     




     
        function s__DummyRecycler___S_DummyRecycler___M___onInit takes nothing returns nothing
            local real add= 360.0 / DummyRecycler___ANGLES_COUNT
            local real a= 0
            local integer this= DummyRecycler___ANGLES_COUNT
            local integer head= 0
            local integer cHead= JASS_MAX_ARRAY_SIZE - 1
            local integer i= R2I(DummyRecycler___MAX_DUMMY_COUNT / DummyRecycler___ANGLES_COUNT + 0.5)
            set DummyRecycler___upper=DummyRecycler___STORED_UNIT_COUNT
            set DummyRecycler___lower=DummyRecycler___STORED_UNIT_COUNT



            //Initialize countHeads
            loop
                exitwhen i < 0
                set DummyRecycler___countNext[cHead]=cHead
                set DummyRecycler___countPrev[cHead]=cHead
                set DummyRecycler___countHead[i]=cHead
                set cHead=cHead - 1
                set i=i - 1
            endloop
            set cHead=DummyRecycler___countHead[DummyRecycler___STORED_UNIT_COUNT] //All heads will be inserted here initially
            //Create the Dummy units
            loop
                exitwhen a >= 360
                //Initialize head
                set DummyRecycler___next[head]=head
                set DummyRecycler___prev[head]=head
                set DummyRecycler___count[head]=DummyRecycler___STORED_UNIT_COUNT
                set DummyRecycler___angle[head]=a
                //Insert head in the Count List
                set DummyRecycler___countNext[head]=cHead
                set DummyRecycler___countPrev[head]=DummyRecycler___countPrev[cHead]
                set DummyRecycler___countNext[DummyRecycler___countPrev[head]]=head
                set DummyRecycler___countPrev[DummyRecycler___countNext[head]]=head
                set i=0
                loop
                    exitwhen i >= DummyRecycler___STORED_UNIT_COUNT
                    //Queued Linked List
                    set DummyRecycler___next[this]=head
                    set DummyRecycler___prev[this]=DummyRecycler___prev[head]
                    set DummyRecycler___next[DummyRecycler___prev[this]]=this
                    set DummyRecycler___prev[DummyRecycler___next[this]]=this


                            set DummyRecycler___dummy[this]=CreateUnit(DummyRecycler___OWNER, DummyRecycler___DUMMY_ID, s__WorldBounds_maxX, s__WorldBounds_maxY, a)






                    call PauseUnit(DummyRecycler___dummy[this], true)



                        call SaveInteger(s__DummyRecycler___S_hash, GetHandleId(DummyRecycler___dummy[this]), 0, this)

                    set this=this + 1
                    set i=i + 1
                endloop
                set head=head + 1
                set a=a + add
            endloop
            set DummyRecycler___lastInstance=this
        endfunction
     
 
    function DummyRecycler___GetHead takes integer facing returns integer
        if facing < 0 or facing >= 360 then
            set facing=facing - ( facing / 360 ) * 360
            if facing < 0 then
                set facing=facing + 360
            endif
        endif
        return R2I(( facing * DummyRecycler___ANGLES_COUNT / 360.0 ))
    endfunction
 
    function ShowDummy takes unit u,boolean flag returns nothing
        if IsUnitHidden(u) == flag then
            call ShowUnit(u, flag)
            if flag and GetUnitTypeId(u) == DummyRecycler___DUMMY_ID then
                call UnitRemoveAbility(u, 'Aloc')
                call UnitAddAbility(u, 'Aloc')
            endif
        endif
    endfunction
 
    function GetRecycledDummy takes real x,real y,real z,real facing returns unit
        local integer head= DummyRecycler___GetHead(R2I(facing + DummyRecycler___FACING_OFFSET))
        local integer this= DummyRecycler___next[head]
        local integer cHead
     
        //If there are Dummy Units in the Queue List already facing close to the appropriate angle
        if this != head and RAbsBJ(GetUnitFacing(DummyRecycler___dummy[this]) - DummyRecycler___angle[head]) <= DummyRecycler___ANGLE_TOLERANCE then
            //Remove from the Queue List
            set DummyRecycler___next[DummyRecycler___prev[this]]=DummyRecycler___next[this]
            set DummyRecycler___prev[DummyRecycler___next[this]]=DummyRecycler___prev[this]
            //For double free protection
            set DummyRecycler___next[this]=- 1
            //Unit Properties
            set bj_lastCreatedUnit=DummyRecycler___dummy[this]
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
            set DummyRecycler___count[head]=DummyRecycler___count[head] - 1
         
            //------------------------------------------------
            //                 Unit Sharing
            //------------------------------------------------
            if DummyRecycler___count[head] < DummyRecycler___BORROW_REQUEST and DummyRecycler___count[DummyRecycler___countNext[DummyRecycler___countHead[DummyRecycler___upper]]] > DummyRecycler___count[head] then
                set DummyRecycler___count[head]=DummyRecycler___count[head] + 1
                set this=DummyRecycler___next[DummyRecycler___countNext[DummyRecycler___countHead[DummyRecycler___upper]]]
                call SetUnitFacing(DummyRecycler___dummy[this], DummyRecycler___angle[head])
                //Remove
                set DummyRecycler___next[DummyRecycler___prev[this]]=DummyRecycler___next[this]
                set DummyRecycler___prev[DummyRecycler___next[this]]=DummyRecycler___prev[this]
                //Add to the Current List
                set DummyRecycler___next[this]=head
                set DummyRecycler___prev[this]=DummyRecycler___prev[head]
                set DummyRecycler___next[DummyRecycler___prev[this]]=this
                set DummyRecycler___prev[DummyRecycler___next[this]]=this
                set head=DummyRecycler___countNext[DummyRecycler___countHead[DummyRecycler___upper]]
                set DummyRecycler___count[head]=DummyRecycler___count[head] - 1
            endif
         
            //---------------------------
            //Update Count Lists
            //---------------------------
            //Remove from the current Count List
            set DummyRecycler___countNext[DummyRecycler___countPrev[head]]=DummyRecycler___countNext[head]
            set DummyRecycler___countPrev[DummyRecycler___countNext[head]]=DummyRecycler___countPrev[head]
            //Add to the new Count List
            set cHead=DummyRecycler___countHead[DummyRecycler___count[head]]
            set DummyRecycler___countNext[head]=cHead
            set DummyRecycler___countPrev[head]=DummyRecycler___countPrev[cHead]
            set DummyRecycler___countNext[DummyRecycler___countPrev[head]]=head
            set DummyRecycler___countPrev[DummyRecycler___countNext[head]]=head
         
            //---------------------------
            //  Update Bounds
            //---------------------------
            set cHead=DummyRecycler___countHead[DummyRecycler___upper]
            if DummyRecycler___countNext[cHead] == cHead then
                set DummyRecycler___upper=DummyRecycler___upper - 1
            endif
            if DummyRecycler___count[head] < DummyRecycler___lower then
                set DummyRecycler___lower=DummyRecycler___count[head]
            endif
        else
            set bj_lastCreatedUnit=CreateUnit(DummyRecycler___OWNER, DummyRecycler___DUMMY_ID, x, y, facing)
            call PauseUnit(bj_lastCreatedUnit, true)
            call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0)
            if DummyRecycler___dummyCount < DummyRecycler___MAX_DUMMY_COUNT then
                set this=DummyRecycler___lastInstance
                //For double free protection
                set DummyRecycler___next[this]=- 1
                set DummyRecycler___dummy[this]=bj_lastCreatedUnit



                    call SaveInteger(s__DummyRecycler___S_hash, GetHandleId(bj_lastCreatedUnit), 0, this)

                set DummyRecycler___lastInstance=DummyRecycler___lastInstance + 1
            endif
            set DummyRecycler___dummyCount=DummyRecycler___dummyCount + 1
        endif

        return bj_lastCreatedUnit
    endfunction
 
    function RecycleDummy takes unit u returns nothing



            local integer this= LoadInteger(s__DummyRecycler___S_hash, GetHandleId(u), 0)

        local integer head
        local integer cHead
     
        //If the unit is a legit Dummy Unit
        if this > 0 and DummyRecycler___next[this] == - 1 then
            //Find where to insert based on the list having the least number of units
            set head=DummyRecycler___countNext[DummyRecycler___countHead[DummyRecycler___lower]]
            set DummyRecycler___next[this]=head
            set DummyRecycler___prev[this]=DummyRecycler___prev[head]
            set DummyRecycler___next[DummyRecycler___prev[this]]=this
            set DummyRecycler___prev[DummyRecycler___next[this]]=this
            //Update Status
            call SetUnitFacing(u, DummyRecycler___angle[head])
            call PauseUnit(u, true)
            call SetUnitOwner(u, DummyRecycler___OWNER, false)


                    call SetUnitX(u, s__WorldBounds_maxX)
                    call SetUnitY(u, s__WorldBounds_maxY)








            set DummyRecycler___count[head]=DummyRecycler___count[head] + 1
         
            //---------------------------
            //    Update Count Lists
            //---------------------------
            //Remove
            set DummyRecycler___countNext[DummyRecycler___countPrev[head]]=DummyRecycler___countNext[head]
            set DummyRecycler___countPrev[DummyRecycler___countNext[head]]=DummyRecycler___countPrev[head]
            //Add to the new Count List
            set cHead=DummyRecycler___countHead[DummyRecycler___count[head]]
            set DummyRecycler___countNext[head]=cHead
            set DummyRecycler___countPrev[head]=DummyRecycler___countPrev[cHead]
            set DummyRecycler___countNext[DummyRecycler___countPrev[head]]=head
            set DummyRecycler___countPrev[DummyRecycler___countNext[head]]=head
         
            //---------------------------
            //  Update Bounds
            //---------------------------
            set cHead=DummyRecycler___countHead[DummyRecycler___lower]
            if DummyRecycler___countNext[cHead] == cHead then
                set DummyRecycler___lower=DummyRecycler___lower + 1
            endif
            if DummyRecycler___count[head] > DummyRecycler___upper then
                set DummyRecycler___upper=DummyRecycler___count[head]
            endif
        elseif this == 0 then
            call RemoveUnit(u)
// NO_DEBUG:         debug elseif DummyRecycler___next[this] != -1 then
// NO_DEBUG:             debug call BJDebugMsg("|cffffcc00[DummyRecycler]:|r Attempted to recycle a pending/free Dummy Unit.")
        endif
     
    endfunction
 
    function DummyRecycler___Expires takes nothing returns nothing
        local timer t= GetExpiredTimer()
        local integer id= GetHandleId(t)




            call RecycleDummy(LoadUnitHandle(s__DummyRecycler___S_hash, id, 0))
            call FlushChildHashtable(s__DummyRecycler___S_hash, id)

        call DestroyTimer(t)
        set t=null
    endfunction

    function DummyAddRecycleTimer takes unit u,real time returns nothing
        local timer t= CreateTimer()



            call SaveUnitHandle(s__DummyRecycler___S_hash, GetHandleId(t), 0, u)

        call TimerStart(t, time, false, function DummyRecycler___Expires)
        set t=null
    endfunction
 
    function GetRecycledDummyAnyAngle takes real x,real y,real z returns unit
        return GetRecycledDummy(x , y , z , DummyRecycler___angle[DummyRecycler___countNext[DummyRecycler___countHead[DummyRecycler___upper]]])
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
    
    
    
    
    

    
    function Missiles__GetLocZ takes real x,real y returns real
        call MoveLocation(Missiles__LOC, x, y)
        return GetLocationZ(Missiles__LOC)
    endfunction

    constant function Missiles__GetUnitCollisionSize takes unit u returns real
        return 64.
    endfunction
    
    function Missiles__GetMapCliffLevel takes nothing returns integer
        return GetTerrainCliffLevel(s__WorldBounds_maxX, s__WorldBounds_maxY)
    endfunction
    
    function Missiles__GetUnitZ takes unit u returns real
        return Missiles__GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u)
    endfunction
    
    function Missiles__SetUnitZ takes unit u,real z returns nothing
        call SetUnitFlyHeight(u, z - Missiles__GetLocZ(GetUnitX(u) , GetUnitY(u)), 0)
    endfunction

    
        
        function s__Missiles__Pool_onExpire takes nothing returns nothing
            local integer this= (LoadInteger(TimerUtils___ht, 0, GetHandleId((GetExpiredTimer())))) // INLINED!!

            call ReleaseTimer(s__Missiles__Pool_timer[this])
            call RemoveUnit(s__Missiles__Pool_unit[this])
            call s__Missiles__Pool_deallocate(this)
            
            set s__Missiles__Pool_timer[this]=null
            set s__Missiles__Pool_unit[this]=null
        endfunction

        function s__Missiles__Pool_recycle takes unit dummy,real delay returns nothing
            local integer this

            if GetUnitTypeId(dummy) != Missiles__DUMMY then
// NO_DEBUG:                 debug call BJDebugMsg("[DummyPool] Error: Trying to recycle a non dummy unit")
            else
                set this=s__Missiles__Pool__allocate()
                set s__Missiles__Pool_timer[this]=NewTimerEx(this)
                set s__Missiles__Pool_unit[this]=dummy
                
                call TimerStart(s__Missiles__Pool_timer[this], delay, false, function s__Missiles__Pool_onExpire)
            endif
        endfunction
        
        function s__Missiles__Pool_retrieve takes real x,real y,real z,real face returns unit
            set bj_lastCreatedUnit=CreateUnit(s__Missiles__Pool_player, Missiles__DUMMY, x, y, face)
            call Missiles__SetUnitZ(bj_lastCreatedUnit , z)
            call UnitRemoveAbility(bj_lastCreatedUnit, 'Amrf')

            return bj_lastCreatedUnit
        endfunction


        // Creates an origin - impact link.

        function s__Missiles__Coordinates_math takes integer a,integer b returns nothing
            local real dx
            local real dy
            loop
                set dx=s__Missiles__Coordinates_x[b] - s__Missiles__Coordinates_x[a]
                set dy=s__Missiles__Coordinates_y[b] - s__Missiles__Coordinates_y[a]
                set dx=dx * dx + dy * dy
                set dy=SquareRoot(dx)
                exitwhen dx != 0. and dy != 0.
                set s__Missiles__Coordinates_x[b]=s__Missiles__Coordinates_x[b] + .01
                set s__Missiles__Coordinates_z[b]=s__Missiles__Coordinates_z[b] - Missiles__GetLocZ(s__Missiles__Coordinates_x[b] - .01 , s__Missiles__Coordinates_y[b]) + Missiles__GetLocZ(s__Missiles__Coordinates_x[b] , s__Missiles__Coordinates_y[b])
            endloop

            set s__Missiles__Coordinates_square[a]=dx
            set s__Missiles__Coordinates_distance[a]=dy
            set s__Missiles__Coordinates_angle[a]=Atan2(s__Missiles__Coordinates_y[b] - s__Missiles__Coordinates_y[a], s__Missiles__Coordinates_x[b] - s__Missiles__Coordinates_x[a])
            set s__Missiles__Coordinates_slope[a]=( s__Missiles__Coordinates_z[b] - s__Missiles__Coordinates_z[a] ) / dy
            set s__Missiles__Coordinates_alpha[a]=Atan(s__Missiles__Coordinates_slope[a]) * bj_RADTODEG
            // Set b.
            if s__Missiles__Coordinates_ref[b] == a then
                set s__Missiles__Coordinates_angle[b]=s__Missiles__Coordinates_angle[a] + bj_PI
                set s__Missiles__Coordinates_distance[b]=dy
                set s__Missiles__Coordinates_slope[b]=- s__Missiles__Coordinates_slope[a]
                set s__Missiles__Coordinates_alpha[b]=- s__Missiles__Coordinates_alpha[a]
                set s__Missiles__Coordinates_square[b]=dx
            endif
        endfunction

        function s__Missiles__Coordinates_link takes integer a,integer b returns nothing
            set s__Missiles__Coordinates_ref[a]=b
            set s__Missiles__Coordinates_ref[b]=a
            call s__Missiles__Coordinates_math(a , b)
        endfunction

        function s__Missiles__Coordinates_move takes integer this,real toX,real toY,real toZ returns nothing
            set s__Missiles__Coordinates_x[this]=toX
            set s__Missiles__Coordinates_y[this]=toY
            set s__Missiles__Coordinates_z[this]=toZ + Missiles__GetLocZ(toX , toY)
            if s__Missiles__Coordinates_ref[this] != this then
                call s__Missiles__Coordinates_math(this , s__Missiles__Coordinates_ref[this])
            endif
        endfunction

        function s__Missiles__Coordinates_destroy takes integer this returns nothing
            call s__Missiles__Coordinates_deallocate(this)
        endfunction

        function s__Missiles__Coordinates_create takes real x,real y,real z returns integer
            local integer this= s__Missiles__Coordinates__allocate()
            set s__Missiles__Coordinates_ref[this]=this
            call s__Missiles__Coordinates_move(this,x , y , z)
            return this
        endfunction
    
    
    
    
  
  
  
    
    
    
    
    

    
    
    
    
    
    
    
        
        
        // Active scheduler membership owns the ID until remove detaches it.
        // Pins protect non-scheduler callback dispatch (pause/resume/remove).
        // Uncurved current sample; setters refresh prediction without advancing it.
        
        
        
    
        function s__Missiles_predict takes integer this returns nothing
            local real d= s__Missiles__Coordinates_distance[s__Missiles_origin[this]]
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
                set s__Missiles_nextBaseX[this]=s__Missiles__Coordinates_x[s__Missiles_impact[this]]
                set s__Missiles_nextBaseY[this]=s__Missiles__Coordinates_y[s__Missiles_impact[this]]
            endif
            set lateral=4 * s__Missiles_open[this] * q * ( d - q ) / ( d * d )
            set s__Missiles_nextX[this]=s__Missiles_nextBaseX[this] + lateral * Cos(s__Missiles_cA[this] + bj_PI / 2)
            set s__Missiles_nextY[this]=s__Missiles_nextBaseY[this] + lateral * Sin(s__Missiles_cA[this] + bj_PI / 2)
            set s__Missiles_nextZ[this]=s__Missiles__Coordinates_z[s__Missiles_origin[this]] + s__Missiles__Coordinates_slope[s__Missiles_origin[this]] * q + 4 * s__Missiles_height[this] * q * ( d - q ) / ( d * d )
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

//Implemented from module Missiles__Operators:
        
        function s__Missiles__set_model takes integer this,string fxpath returns nothing
            call DestroyEffect(s__Missiles_effect[this])
            set s__Missiles_path[this]=fxpath
            set s__Missiles_effect[this]=AddSpecialEffectTarget(fxpath, s__Missiles_dummy[this], "origin")
        endfunction
    
        function s__Missiles__get_model takes integer this returns string
            return s__Missiles_path[this]
        endfunction
    
        
        function s__Missiles__set_curve takes integer this,real value returns nothing
            set s__Missiles_open[this]=Tan(value * bj_DEGTORAD) * s__Missiles__Coordinates_distance[s__Missiles_origin[this]]
            call s__Missiles_predict(this)
        endfunction
    
        function s__Missiles__get_curve takes integer this returns real
            return Atan(s__Missiles_open[this] / s__Missiles__Coordinates_distance[s__Missiles_origin[this]]) * bj_RADTODEG
        endfunction
    
        
        function s__Missiles__set_arc takes integer this,real value returns nothing
            set s__Missiles_height[this]=Tan(value * bj_DEGTORAD) * s__Missiles__Coordinates_distance[s__Missiles_origin[this]] / 4
            call s__Missiles_predict(this)
        endfunction
    
        function s__Missiles__get_arc takes integer this returns real
            return Atan(4 * s__Missiles_height[this] / s__Missiles__Coordinates_distance[s__Missiles_origin[this]]) * bj_RADTODEG
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
            set s__Missiles_veloc[this]=RMaxBJ(0.00000001, ( s__Missiles__Coordinates_distance[s__Missiles_origin[this]] - s__Missiles_progress[this] ) * Missiles_PERIOD / RMaxBJ(0.00000001, flightTime))
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
//Implemented from module Missiles__Methods:
        
        function s__Missiles_bounce takes integer this returns nothing
            call s__Missiles__Coordinates_move(s__Missiles_origin[this],s__Missiles_x[this] , s__Missiles_y[this] , s__Missiles_z[this] - Missiles__GetLocZ(s__Missiles_x[this] , s__Missiles_y[this]))
            
            set s__Missiles_travel[this]=0
            set s__Missiles_progress[this]=0.
            set s__Missiles_baseX[this]=s__Missiles_x[this]
            set s__Missiles_baseY[this]=s__Missiles_y[this]
            set s__Missiles_cA[this]=s__Missiles__Coordinates_angle[s__Missiles_origin[this]]
            set s__Missiles_finished[this]=false
            call s__Missiles_predict(this)
        endfunction
        
        function s__Missiles_deflect takes integer this,real tx,real ty,real tz returns nothing
            local real locZ= Missiles__GetLocZ(s__Missiles_x[this] , s__Missiles_y[this])
            
            set s__Missiles_target[this]=null
            set s__Missiles_toZ[this]=tz
            
            if s__Missiles_z[this] < locZ and (st__Missiles__MissileEvents_onTerrain[si__Missiles__MissileEvents_type[this]]!=null) then
                set s__Missiles_nextX[this]=s__Missiles_prevX[this]
                set s__Missiles_nextY[this]=s__Missiles_prevY[this]
                set s__Missiles_nextZ[this]=s__Missiles_prevZ[this]
            endif
            
            call s__Missiles__Coordinates_move(s__Missiles_impact[this],tx , ty , tz)
            call s__Missiles__Coordinates_move(s__Missiles_origin[this],s__Missiles_x[this] , s__Missiles_y[this] , s__Missiles_z[this] - locZ)
            
            set s__Missiles_travel[this]=0
            set s__Missiles_progress[this]=0.
            set s__Missiles_baseX[this]=s__Missiles_x[this]
            set s__Missiles_baseY[this]=s__Missiles_y[this]
            set s__Missiles_cA[this]=s__Missiles__Coordinates_angle[s__Missiles_origin[this]]
            set s__Missiles_finished[this]=false
            call s__Missiles_predict(this)
        endfunction
        
        function s__Missiles_deflectTarget takes integer this,unit u returns nothing
            call s__Missiles_deflect(this,GetUnitX(u) , GetUnitY(u) , s__Missiles_toZ[this])
            set s__Missiles_target[this]=u
        endfunction

        
        function s__Missiles_flushAll takes integer this returns nothing
            call FlushChildHashtable(s__Missiles_Missiles__table, this)
            call FlushChildHashtable(s__Missiles_missileHits, this)
        endfunction

        function s__Missiles_flush takes integer this,widget w returns nothing
            if w != null then
                call RemoveSavedBoolean(s__Missiles_Missiles__table, this, GetHandleId(w))
            endif
        endfunction

        function s__Missiles_hitted takes integer this,widget w returns boolean
            return HaveSavedBoolean(s__Missiles_Missiles__table, this, GetHandleId(w))
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
            
            if (st__Missiles__MissileEvents_onResume[si__Missiles__MissileEvents_type[this]]!=null) then
                set stop=sc__Missiles__MissileEvents_onResume(this)
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
            if not HaveSavedBoolean(s__Missiles_Missiles__table, this, GetHandleId(d)) then
                if s__Missiles_collideZ[this] then
                    set dz=Missiles__GetLocZ(GetWidgetX(d) , GetWidgetY(d))
                    set tz=GetDestructableOccluderHeight(d)
                    if dz + tz >= s__Missiles_z[this] - s__Missiles_collision[this] and dz <= s__Missiles_z[this] + s__Missiles_collision[this] then
                        call SaveBoolean(s__Missiles_Missiles__table, this, GetHandleId(d), true)
                        set stop=sc__Missiles__MissileEvents_onDestructable(this,d)
                        if s__Missiles_allocated[this] and stop then
                            set d=null
                            call sc__Missiles_terminate(this)
                            return
                        endif
                    endif
                else
                    call SaveBoolean(s__Missiles_Missiles__table, this, GetHandleId(d), true)
                    set stop=sc__Missiles__MissileEvents_onDestructable(this,d)
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
            if not HaveSavedBoolean(s__Missiles_Missiles__table, this, GetHandleId(i)) then
                if s__Missiles_collideZ[this] then
                    set dz=Missiles__GetLocZ(GetItemX(i) , GetItemY(i))
                    if dz + Missiles__ITEM_SIZE >= s__Missiles_z[this] - s__Missiles_collision[this] and dz <= s__Missiles_z[this] + s__Missiles_collision[this] then
                        call SaveBoolean(s__Missiles_Missiles__table, this, GetHandleId(i), true)
                        set stop=sc__Missiles__MissileEvents_onItem(this,i)
                        if s__Missiles_allocated[this] and stop then
                            set i=null
                            call sc__Missiles_terminate(this)
                            return
                        endif
                    endif
                else
                    call SaveBoolean(s__Missiles_Missiles__table, this, GetHandleId(i), true)
                    set stop=sc__Missiles__MissileEvents_onItem(this,i)
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
            
            if (st__Missiles__MissileEvents_onRemove[si__Missiles__MissileEvents_type[this]]!=null) then
                call sc__Missiles__MissileEvents_onRemove(this)
            endif
            
            if s__Missiles_index[this] != - 1 then
                set aux=s__Missiles_collection[s__Missiles_count]
                set s__Missiles_index[aux]=s__Missiles_index[this]
                set s__Missiles_collection[s__Missiles_index[this]]=s__Missiles_collection[s__Missiles_count]
                set s__Missiles_count=s__Missiles_count - 1
                set s__Missiles_index[this]=- 1
            endif


                call SetUnitOwner(s__Missiles_dummy[this], Player(PLAYER_NEUTRAL_PASSIVE), false)
                call DummyAddRecycleTimer(s__Missiles_dummy[this] , Missiles__RECYCLE_TIME)



            call s__Missiles_clearVision(this)
            call s__Missiles__Coordinates_deallocate((s__Missiles_origin[this])) // INLINED!!
            call s__Missiles__Coordinates_deallocate((s__Missiles_impact[this])) // INLINED!!
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
                call sc__Missiles__MissileEvents_deallocate(this)
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
//Implemented from module Missiles__OnPause:
        set s__Missiles_pid=s__Missiles_pid + 1
        set s__Missiles_pkey[this]=s__Missiles_pid
        set s__Missiles_frozen[s__Missiles_pid]=this
        
        if (st__Missiles__MissileEvents_onPause[si__Missiles__MissileEvents_type[this]]!=null) then
            set stop=sc__Missiles__MissileEvents_onPause(this)
            if s__Missiles_allocated[this] and stop then
                call s__Missiles_terminate(this)
            endif
        endif
            else
//Implemented from module Missiles__OnRemove:
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
//Implemented from module Missiles__OnHit:
        set o=s__Missiles_origin[this]
        set h=s__Missiles_height[this]
        set c=s__Missiles_open[this]
        set d=s__Missiles__Coordinates_distance[o]
        
        if (st__Missiles__MissileEvents_onHit[si__Missiles__MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                call GroupEnumUnitsInRange(s__Missiles_group, s__Missiles_x[this], s__Missiles_y[this], s__Missiles_collision[this] + Missiles__COLLISION_SIZE, null)
                loop
                    set u=FirstOfGroup(s__Missiles_group)
                    exitwhen u == null or not s__Missiles_allocated[this]
                        if not HaveSavedBoolean(s__Missiles_Missiles__table, this, GetHandleId(u)) then
                            if IsUnitInRangeXY(u, s__Missiles_x[this], s__Missiles_y[this], s__Missiles_collision[this]) then
                                if s__Missiles_collideZ[this] then
                                    set dx=Missiles__GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u)
                                    set dy=Missiles__GetUnitCollisionSize(u)
                                    if dx + dy >= s__Missiles_z[this] - s__Missiles_collision[this] and dx <= s__Missiles_z[this] + s__Missiles_collision[this] then
                                        call SaveBoolean(s__Missiles_Missiles__table, this, GetHandleId(u), true)
                                        set stop=sc__Missiles__MissileEvents_onHit(this,u)
                                        if s__Missiles_allocated[this] and stop then
                                            call s__Missiles_terminate(this)
                                        endif
                                        exitwhen not s__Missiles_allocated[this]
                                    endif
                                else
                                    call SaveBoolean(s__Missiles_Missiles__table, this, GetHandleId(u), true)
                                    set stop=sc__Missiles__MissileEvents_onHit(this,u)
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
//Implemented from module Missiles__OnMissile:
        if (st__Missiles__MissileEvents_onMissile[si__Missiles__MissileEvents_type[this]]!=null) then
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
                                    set stop=sc__Missiles__MissileEvents_onMissile(this,missile)
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
//Implemented from module Missiles__OnDestructable:
        if (st__Missiles__MissileEvents_onDestructable[si__Missiles__MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                set dx=s__Missiles_collision[this] + Missiles__COLLISION_SIZE
                call SetRect(s__Missiles_rect, s__Missiles_x[this] - dx, s__Missiles_y[this] - dx, s__Missiles_x[this] + dx, s__Missiles_y[this] + dx)
                call EnumDestructablesInRect(s__Missiles_rect, null, function s__Missiles_onDest)
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles__OnItem:
        if (st__Missiles__MissileEvents_onItem[si__Missiles__MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                set dx=s__Missiles_collision[this] + Missiles__COLLISION_SIZE
                call SetRect(s__Missiles_rect, s__Missiles_x[this] - dx, s__Missiles_y[this] - dx, s__Missiles_x[this] + dx, s__Missiles_y[this] + dx)
                call EnumItemsInRect(s__Missiles_rect, null, function s__Missiles_onItems)
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles__OnCliff:
        if (st__Missiles__MissileEvents_onCliff[si__Missiles__MissileEvents_type[this]]!=null) then
            set dx=GetTerrainCliffLevel(s__Missiles_nextX[this], s__Missiles_nextY[this])
            set dy=GetTerrainCliffLevel(s__Missiles_x[this], s__Missiles_y[this])
            if dy < dx and s__Missiles_z[this] < ( dx - (GetTerrainCliffLevel(s__WorldBounds_maxX, s__WorldBounds_maxY)) ) * bj_CLIFFHEIGHT then // INLINED!!
                set stop=sc__Missiles__MissileEvents_onCliff(this)
                if s__Missiles_allocated[this] and stop then
                    call s__Missiles_terminate(this)
                endif
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles__OnTerrain:
        if (st__Missiles__MissileEvents_onTerrain[si__Missiles__MissileEvents_type[this]]!=null) then
            if Missiles__GetLocZ(s__Missiles_x[this] , s__Missiles_y[this]) > s__Missiles_z[this] then
                set stop=sc__Missiles__MissileEvents_onTerrain(this)
                if s__Missiles_allocated[this] and stop then
                    call s__Missiles_terminate(this)
                endif
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles__OnTileset:
        if (st__Missiles__MissileEvents_onTileset[si__Missiles__MissileEvents_type[this]]!=null) then
            set k=GetTerrainType(s__Missiles_x[this], s__Missiles_y[this])
            if k != s__Missiles_tileset[this] then
                set stop=sc__Missiles__MissileEvents_onTileset(this,k)
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
//Implemented from module Missiles__OnPeriod:
        if (st__Missiles__MissileEvents_onPeriod[si__Missiles__MissileEvents_type[this]]!=null) then
            set stop=sc__Missiles__MissileEvents_onPeriod(this)
            if s__Missiles_allocated[this] and stop then
                call s__Missiles_terminate(this)
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
//Implemented from module Missiles__OnOrient:
        // Refresh after callbacks: onPeriod may have moved the target.
        set u=s__Missiles_target[this]
        if u != null and GetUnitTypeId(u) != 0 then
            call s__Missiles__Coordinates_move(s__Missiles_impact[this],GetUnitX(u) , GetUnitY(u) , GetUnitFlyHeight(u) + s__Missiles_toZ[this])
            set dx=s__Missiles__Coordinates_x[s__Missiles_impact[this]] - s__Missiles_baseX[this]
            set dy=s__Missiles__Coordinates_y[s__Missiles_impact[this]] - s__Missiles_baseY[this]
            set a=Atan2(dy, dx)
            set s__Missiles_progress[this]=s__Missiles__Coordinates_distance[s__Missiles_origin[this]] - SquareRoot(dx * dx + dy * dy)
        else
            set a=s__Missiles__Coordinates_angle[s__Missiles_origin[this]]
            set s__Missiles_target[this]=null
        endif
        set o=s__Missiles_origin[this]
        set d=s__Missiles__Coordinates_distance[o]
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
        set pitch=s__Missiles__Coordinates_alpha[o] - Atan(4 * h * ( 2 * s - d ) / ( d * d )) * bj_RADTODEG
        set yaw=( s__Missiles_cA[this] + Atan(- 4 * c * ( 2 * s - d ) / ( d * d )) ) * bj_RADTODEG
        call s__Missiles_refreshVision(this)
//Implemented from module Missiles__OnFinish:
        if s >= d then
            set s__Missiles_finished[this]=true
            if (st__Missiles__MissileEvents_onFinish[si__Missiles__MissileEvents_type[this]]!=null) then
                set stop=sc__Missiles__MissileEvents_onFinish(this)
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
//Implemented from module Missiles__OnBoundaries:
        if not ( s__Missiles_x[this] > s__WorldBounds_maxX or s__Missiles_x[this] < s__WorldBounds_minX or s__Missiles_y[this] > s__WorldBounds_maxY or s__Missiles_y[this] < s__WorldBounds_minY ) then
            call SetUnitX(s__Missiles_dummy[this], s__Missiles_x[this])
            call SetUnitY(s__Missiles_dummy[this], s__Missiles_y[this])
            call Missiles__SetUnitZ(s__Missiles_dummy[this] , s__Missiles_z[this])
        else
            if (st__Missiles__MissileEvents_onBoundaries[si__Missiles__MissileEvents_type[this]]!=null) then
                set stop=sc__Missiles__MissileEvents_onBoundaries(this)
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
            set s__Missiles_origin[this]=s__Missiles__Coordinates_create(x , y , z)
            set s__Missiles_impact[this]=s__Missiles__Coordinates_create(toX , toY , toZ)
            call s__Missiles__Coordinates_link(s__Missiles_origin[this] , s__Missiles_impact[this])
            set s__Missiles_allocated[this]=true
            set s__Missiles_cA[this]=s__Missiles__Coordinates_angle[s__Missiles_origin[this]]
            set s__Missiles_x[this]=x
            set s__Missiles_y[this]=y
            set s__Missiles_z[this]=s__Missiles__Coordinates_z[s__Missiles_origin[this]]
            set s__Missiles_prevX[this]=x
            set s__Missiles_prevY[this]=y
            set s__Missiles_prevZ[this]=s__Missiles__Coordinates_z[s__Missiles_origin[this]]
            set s__Missiles_nextX[this]=x
            set s__Missiles_nextY[this]=y
            set s__Missiles_nextZ[this]=s__Missiles__Coordinates_z[s__Missiles_origin[this]]
            set s__Missiles_toZ[this]=toZ
            set s__Missiles_baseX[this]=x
            set s__Missiles_baseY[this]=y
            set s__Missiles_nextBaseX[this]=x
            set s__Missiles_nextBaseY[this]=y


                set s__Missiles_dummy[this]=GetRecycledDummy(x , y , z , face)



            call Missiles__SetUnitZ(s__Missiles_dummy[this] , s__Missiles__Coordinates_z[s__Missiles_origin[this]])

            return this
        endfunction

    // Minimal B01/B02 GREEN candidate. One caller-owned pair and shot observer.
    // Active recasts are TEMPORARILY IGNORED, not the final S1 reset contract.

    function RFBurstPair__LiveOwned takes unit u,player p returns boolean
        return u != null and GetUnitTypeId(u) != 0 and GetWidgetLife(u) > .405 and GetOwningPlayer(u) == p
    endfunction

        // Per-flight snapshots, never references to the current global pair.

        function s__RFBurstPair__RBProjectile_spawn takes unit visible,unit logical,player owning,real x,real y,real endX,real endY,real endZ returns integer
            local integer this= s__RFBurstPair__RBProjectile__allocate(x , y , RFBurstPair__LAUNCH_HEIGHT , endX , endY , endZ)
            set s__RFBurstPair__RBProjectile_savedActor[this]=visible
            set s__RFBurstPair__RBProjectile_savedController[this]=logical
            set s__RFBurstPair__RBProjectile_savedOwner[this]=owning
            set s__RFBurstPair__RBProjectile_spent[this]=false
            set s__Missiles_source[this]=visible
            set s__Missiles_owner[this]=owning
            call s__Missiles__set_speed(this,RFBurstPair__SPEED)
            set s__Missiles_collision[this]=RFBurstPair__HIT_RADIUS
            set s__Missiles_collideZ[this]=false
            call s__Missiles__set_model(this,"Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl")
            return this
        endfunction

        function s__RFBurstPair__RBProjectile_onHit takes integer this,unit hit returns boolean
            if s__RFBurstPair__RBProjectile_spent[this] or not RFBurstPair__LiveOwned(s__RFBurstPair__RBProjectile_savedActor[this] , s__RFBurstPair__RBProjectile_savedOwner[this]) then
                return true
            endif
            if hit == s__RFBurstPair__RBProjectile_savedActor[this] or hit == s__RFBurstPair__RBProjectile_savedController[this] or GetUnitTypeId(hit) == 0 or GetWidgetLife(hit) <= .405 or not IsUnitEnemy(hit, s__RFBurstPair__RBProjectile_savedOwner[this]) then
                return false
            endif
            // Commit termination intent BEFORE native damage dispatch. Damage
            // handlers may dispose/reinitialize the pair or terminate this flight.
            set s__RFBurstPair__RBProjectile_spent[this]=true
            call UnitDamageTarget(s__RFBurstPair__RBProjectile_savedActor[this], hit, 10., true, true, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL, null)
            // No instance/global writes after that external callback boundary.
            return true
        endfunction

        function s__RFBurstPair__RBProjectile_onPeriod takes integer this returns boolean
            return not RFBurstPair__LiveOwned(s__RFBurstPair__RBProjectile_savedActor[this] , s__RFBurstPair__RBProjectile_savedOwner[this])
        endfunction

        function s__RFBurstPair__RBProjectile_onRemove takes integer this returns nothing
            // Core owns allocator/dummy/effect/coordinates and their cleanup.
            set s__RFBurstPair__RBProjectile_savedActor[this]=null
            set s__RFBurstPair__RBProjectile_savedController[this]=null
            set s__RFBurstPair__RBProjectile_savedOwner[this]=null
            set s__RFBurstPair__RBProjectile_spent[this]=true
        endfunction

    // Same callback-scoped ABI as RED. Observe, do not retain recycled IDs.
    function RB_GetShotMissile takes nothing returns integer
        return RFBurstPair__shot
    endfunction

    function RB_GetShotSource takes nothing returns unit
        return RFBurstPair__shotSource
    endfunction

    function RB_GetShotX takes nothing returns real
        return RFBurstPair__shotX
    endfunction

    function RB_GetShotY takes nothing returns real
        return RFBurstPair__shotY
    endfunction

    function RFBurstPair__ClearShot takes nothing returns nothing
        set RFBurstPair__shot=0
        set RFBurstPair__shotSource=null
        set RFBurstPair__shotX=0.
        set RFBurstPair__shotY=0.
    endfunction

    function RFBurstPair__CancelBurst takes nothing returns nothing
        set RFBurstPair__epoch=RFBurstPair__epoch + 1
        set RFBurstPair__remaining=0
        set RFBurstPair__notifying=false
        if RFBurstPair__fireTimer != null then
            call PauseTimer(RFBurstPair__fireTimer)
        endif
        call RFBurstPair__ClearShot()
    endfunction

    function RFBurstPair__PairReady takes nothing returns boolean
        return RFBurstPair__LiveOwned(RFBurstPair__actor , RFBurstPair__pairOwner) and RFBurstPair__LiveOwned(RFBurstPair__controller , RFBurstPair__pairOwner)
    endfunction

    function RFBurstPair__Emit takes nothing returns nothing
        local integer ticket= RFBurstPair__epoch
        local unit visible= RFBurstPair__actor
        local unit logical= RFBurstPair__controller
        local player owning= RFBurstPair__pairOwner
        local trigger listener= RFBurstPair__observer
        local integer m
        local real x
        local real y
        local real endX
        local real endY
        local real absoluteZ
        local real endZ
        if RFBurstPair__remaining <= 0 or RFBurstPair__notifying then
            set visible=null
            set logical=null
            set owning=null
            set listener=null
            return
        endif
        if not (RFBurstPair__LiveOwned(RFBurstPair__actor , RFBurstPair__pairOwner) and RFBurstPair__LiveOwned(RFBurstPair__controller , RFBurstPair__pairOwner)) then // INLINED!!
            call RFBurstPair__CancelBurst()
            set visible=null
            set logical=null
            set owning=null
            set listener=null
            return
        endif
        // Commit all cadence/count state before core creation or observer code.
        set RFBurstPair__remaining=RFBurstPair__remaining - 1
        set RFBurstPair__notifying=true
        if RFBurstPair__remaining == 0 then
            call PauseTimer(RFBurstPair__fireTimer)
        endif
        set x=GetUnitX(visible)
        set y=GetUnitY(visible)
        set endX=x + RFBurstPair__RANGE * Cos(RFBurstPair__heading)
        set endY=y + RFBurstPair__RANGE * Sin(RFBurstPair__heading)
        call MoveLocation(RFBurstPair__terrain, x, y)
        set absoluteZ=GetLocationZ(RFBurstPair__terrain) + RFBurstPair__LAUNCH_HEIGHT
        call MoveLocation(RFBurstPair__terrain, endX, endY)
        // Core constructor arguments are terrain-relative. Keep world Z level
        // rather than accidentally aiming at endpoint terrain+80 on a slope.
        set endZ=absoluteZ - GetLocationZ(RFBurstPair__terrain)
        set m=s__RFBurstPair__RBProjectile_spawn(visible , logical , owning , x , y , endX , endY , endZ)
        if RFBurstPair__epoch != ticket or not RFBurstPair__LiveOwned(visible , owning) then
            call s__Missiles_terminate(m)
            if RFBurstPair__epoch == ticket then
                call RFBurstPair__CancelBurst()
            endif
        else
            call s__Missiles_launch(m)
            set RFBurstPair__shot=m
            set RFBurstPair__shotSource=visible
            set RFBurstPair__shotX=s__Missiles_x[m]
            set RFBurstPair__shotY=s__Missiles_y[m]
            call TriggerEvaluate(listener)
            // A listener can Dispose+Initialize+cast recursively. Never clear
            // views or mutate timers belonging to that newer pair/burst epoch.
            if RFBurstPair__epoch == ticket then
                call RFBurstPair__ClearShot()
                set RFBurstPair__notifying=false
            endif
        endif
        set visible=null
        set logical=null
        set owning=null
        set listener=null
    endfunction

    function RFBurstPair__OnFire takes nothing returns nothing
        if GetExpiredTimer() == RFBurstPair__fireTimer then
            call RFBurstPair__Emit()
        endif
    endfunction

    function RFBurstPair__OnCast takes nothing returns boolean
        if GetTriggerUnit() != RFBurstPair__controller or GetSpellAbilityId() != 'A00G' then
            return false
        endif
        if not (RFBurstPair__LiveOwned(RFBurstPair__actor , RFBurstPair__pairOwner) and RFBurstPair__LiveOwned(RFBurstPair__controller , RFBurstPair__pairOwner)) then // INLINED!!
            call RFBurstPair__CancelBurst()
            return false
        endif
        if RFBurstPair__remaining > 0 or RFBurstPair__notifying then
            // Deliberate incomplete behavior awaiting incremental recast RED.
            return false
        endif
        set RFBurstPair__epoch=RFBurstPair__epoch + 1
        set RFBurstPair__heading=Atan2(GetSpellTargetY() - GetUnitY(RFBurstPair__actor), GetSpellTargetX() - GetUnitX(RFBurstPair__actor))
        set RFBurstPair__remaining=4
        // One reused per-pair timer; phase starts before the immediate pulse.
        call TimerStart(RFBurstPair__fireTimer, RFBurstPair__CADENCE, true, function RFBurstPair__OnFire)
        call RFBurstPair__Emit()
        return false
    endfunction

    function RB_Dispose takes nothing returns nothing
        call RFBurstPair__CancelBurst()
        if RFBurstPair__castHook != null then
            call DestroyTrigger(RFBurstPair__castHook)
        endif
        if RFBurstPair__fireTimer != null then
            call DestroyTimer(RFBurstPair__fireTimer)
        endif
        if RFBurstPair__terrain != null then
            call RemoveLocation(RFBurstPair__terrain)
        endif
        set RFBurstPair__castHook=null
        set RFBurstPair__fireTimer=null
        set RFBurstPair__terrain=null
        set RFBurstPair__observer=null
        set RFBurstPair__actor=null
        set RFBurstPair__controller=null
        set RFBurstPair__pairOwner=null
        // Existing flights keep snapshots; no caller unit/observer destruction.
    endfunction

    function RB_InitializePair takes unit visible,unit logical,trigger shotObserver returns boolean
        if RFBurstPair__castHook != null or RFBurstPair__fireTimer != null or visible == null or logical == null or visible == logical or shotObserver == null then
            return false
        endif
        if GetUnitTypeId(visible) != 'o000' or GetUnitTypeId(logical) != 'o001' or GetUnitAbilityLevel(logical, 'A00G') != 1 then
            return false
        endif
        if not RFBurstPair__LiveOwned(visible , GetOwningPlayer(visible)) or not RFBurstPair__LiveOwned(logical , GetOwningPlayer(visible)) then
            return false
        endif
        set RFBurstPair__epoch=RFBurstPair__epoch + 1
        set RFBurstPair__actor=visible
        set RFBurstPair__controller=logical
        set RFBurstPair__pairOwner=GetOwningPlayer(visible)
        set RFBurstPair__observer=shotObserver
        set RFBurstPair__remaining=0
        set RFBurstPair__notifying=false
        call RFBurstPair__ClearShot()
        set RFBurstPair__terrain=Location(0., 0.)
        set RFBurstPair__fireTimer=CreateTimer()
        set RFBurstPair__castHook=CreateTrigger()
        call TriggerRegisterUnitEvent(RFBurstPair__castHook, RFBurstPair__controller, EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(RFBurstPair__castHook, Condition(function RFBurstPair__OnCast))
        return true
    endfunction


    function RFBurstRecastTest___Pose takes unit u returns string
        return "type=" + I2S(GetUnitTypeId(u)) + " xy=" + R2S(GetUnitX(u)) + "," + R2S(GetUnitY(u)) + " facing=" + R2S(GetUnitFacing(u)) + " order=" + I2S(GetUnitCurrentOrder(u)) + " hp=" + R2S(GetWidgetLife(u))
    endfunction

    function RFBurstRecastTest___ClearScene takes nothing returns nothing
        call RB_Dispose()
        if RFBurstRecastTest___spellHook != null then
            call DestroyTrigger(RFBurstRecastTest___spellHook)
            call DestroyTrigger(RFBurstRecastTest___damageHook)
            call DestroyTrigger(RFBurstRecastTest___shotHook)
        endif
        set RFBurstRecastTest___spellHook=null
        set RFBurstRecastTest___damageHook=null
        set RFBurstRecastTest___shotHook=null
        if GetUnitTypeId(RFBurstRecastTest___actor) != 0 then
            call RemoveUnit(RFBurstRecastTest___actor)
        endif
        if GetUnitTypeId(RFBurstRecastTest___caster) != 0 then
            call RemoveUnit(RFBurstRecastTest___caster)
        endif
        if GetUnitTypeId(RFBurstRecastTest___target) != 0 then
            call RemoveUnit(RFBurstRecastTest___target)
        endif
        if GetUnitTypeId(RFBurstRecastTest___control) != 0 then
            call RemoveUnit(RFBurstRecastTest___control)
        endif
        // Keep removed unit references until next-tick native clearance checks.
    endfunction

    function RFBurstRecastTest___ReleaseSceneRefs takes nothing returns nothing
        set RFBurstRecastTest___actor=null
        set RFBurstRecastTest___caster=null
        set RFBurstRecastTest___target=null
        set RFBurstRecastTest___control=null
    endfunction

    function RFBurstRecastTest___Finish takes nothing returns nothing
        if RFBurstRecastTest___done then
            return
        endif
        set RFBurstRecastTest___done=true
        call PauseTimer(RFBurstRecastTest___runner)
        call PauseTimer(RFBurstRecastTest___clock)
        call RFBurstRecastTest___ClearScene()
        call RFBurstRecastTest___ReleaseSceneRefs()
        call DestroyTimer(RFBurstRecastTest___runner)
        call DestroyTimer(RFBurstRecastTest___clock)
        set RFBurstRecastTest___runner=null
        set RFBurstRecastTest___clock=null
        call RB_LogComplete()
    endfunction

    function RFBurstRecastTest___Abort takes string why returns nothing
        call RB_LogRecord("FAIL" , "ABORT-fixture" , why)
        call RFBurstRecastTest___Finish()
    endfunction

    function RFBurstRecastTest___Deadline takes nothing returns nothing
        call RFBurstRecastTest___Abort("global 20 game-second deadline; remaining assertions unreached")
    endfunction

    function RFBurstRecastTest___OnDamage takes nothing returns boolean
        local real amount= GetEventDamage()
        if GetTriggerUnit() == RFBurstRecastTest___control then
            set RFBurstRecastTest___controlHits=RFBurstRecastTest___controlHits + 1
        elseif GetTriggerUnit() == RFBurstRecastTest___target then
            if RFBurstRecastTest___phase == 1 then
                set RFBurstRecastTest___calibrationHits=RFBurstRecastTest___calibrationHits + 1
                set RFBurstRecastTest___calibrationDamage=amount
                set RFBurstRecastTest___calibrationSource=GetEventDamageSource() == RFBurstRecastTest___actor
            elseif RFBurstRecastTest___phase >= 4 then
                set RFBurstRecastTest___hits=RFBurstRecastTest___hits + 1
                set RFBurstRecastTest___hitValuesOK=RFBurstRecastTest___hitValuesOK and RAbsBJ(amount - 10.) <= .01
                set RFBurstRecastTest___hitSourcesOK=RFBurstRecastTest___hitSourcesOK and GetEventDamageSource() == RFBurstRecastTest___actor
                if RFBurstRecastTest___hits <= 8 then
                    call RB_LogRecord("OBS" , "native-damage" , "time=" + R2S(TimerGetElapsed(RFBurstRecastTest___clock)) + " value=" + R2S(amount) + " source=" + I2S(GetHandleId(GetEventDamageSource())) + " visible=" + I2S(GetHandleId(RFBurstRecastTest___actor)))
                endif
            endif
        endif
        return false
    endfunction

    function RFBurstRecastTest___OnShot takes nothing returns boolean
        local integer m= (RFBurstPair__shot) // INLINED!!
        local boolean valid= false
        set RFBurstRecastTest___shots=RFBurstRecastTest___shots + 1
        // Public diagnostic pulse alone is NOT evidence of a real projectile.
        if m != 0 then
            set valid=s__Missiles_allocated[m] and s__Missiles_launched[m] and s__Missiles_dummy[m] != null
            set valid=valid and GetUnitTypeId(s__Missiles_dummy[m]) != 0 and s__Missiles_dummy[m] != RFBurstRecastTest___actor and s__Missiles_dummy[m] != RFBurstRecastTest___caster
            set valid=valid and s__Missiles_source[m] == RFBurstRecastTest___actor and (RFBurstPair__shotSource) == RFBurstRecastTest___actor // INLINED!!
            set valid=valid and RAbsBJ(s__Missiles_x[m] - GetUnitX(RFBurstRecastTest___actor)) <= 1. and RAbsBJ(s__Missiles_y[m] - GetUnitY(RFBurstRecastTest___actor)) <= 1.
            set valid=valid and RAbsBJ((RFBurstPair__shotX) - s__Missiles_x[m]) <= .01 and RAbsBJ((RFBurstPair__shotY) - s__Missiles_y[m]) <= .01 // INLINED!!
        endif
        set RFBurstRecastTest___projectilesOK=RFBurstRecastTest___projectilesOK and valid and RFBurstRecastTest___phase == 5
        if RFBurstRecastTest___shots <= 8 then
            set RFBurstRecastTest___shotTime[RFBurstRecastTest___shots]=TimerGetElapsed(RFBurstRecastTest___clock)
            call RB_LogRecord("OBS" , "SHOT-public-pulse" , "index=" + I2S(RFBurstRecastTest___shots) + " time=" + R2S(RFBurstRecastTest___shotTime[RFBurstRecastTest___shots]) + " missile=" + I2S(m) + " source=" + I2S(GetHandleId((RFBurstPair__shotSource)))) // INLINED!!
        endif
        if RFBurstRecastTest___recastCase and RFBurstRecastTest___shots == 2 then
            if not RFBurstRecastTest___projectilesOK then
                set RFBurstRecastTest___phase=- 1
            else
                set RFBurstRecastTest___recastDue=RFBurstRecastTest___shotTime[2] + .125
                set RFBurstRecastTest___pendingRecast=true
            endif
        endif
        if RFBurstRecastTest___recastCase and RFBurstRecastTest___recastRequested and RFBurstRecastTest___shots > 2 and TimerGetElapsed(RFBurstRecastTest___clock) < RFBurstRecastTest___shotTime[2] + .25 - .0001 then
            set RFBurstRecastTest___earlyPulse=true
        endif
        return false
    endfunction

    function RFBurstRecastTest___OnSpell takes nothing returns boolean
        local real now= TimerGetElapsed(RFBurstRecastTest___clock)
        set RFBurstRecastTest___castEvents=RFBurstRecastTest___castEvents + 1
        call RB_LogRecord("OBS" , "native-spell-effect" , "event=" + I2S(RFBurstRecastTest___castEvents) + " time=" + R2S(now) + " shots=" + I2S(RFBurstRecastTest___shots) + " ability=" + I2S(GetSpellAbilityId()) + " source=" + I2S(GetHandleId(GetTriggerUnit())) + " xy=" + R2S(GetSpellTargetX()) + "," + R2S(GetSpellTargetY()))
        if GetTriggerUnit() != RFBurstRecastTest___caster or GetSpellAbilityId() != 'A00G' or RAbsBJ(GetSpellTargetX() - RFBurstRecastTest___aimX) > .01 or RAbsBJ(GetSpellTargetY() - RFBurstRecastTest___aimY) > .01 then
            set RFBurstRecastTest___phase=- 1
        elseif RFBurstRecastTest___expectedCast == 1 and RFBurstRecastTest___castEvents == 1 and RFBurstRecastTest___phase == 4 then
            set RFBurstRecastTest___expectedCast=0
            set RFBurstRecastTest___castTime=now
            set RFBurstRecastTest___targetStart=GetWidgetLife(RFBurstRecastTest___target)
            set RFBurstRecastTest___controlStart=GetWidgetLife(RFBurstRecastTest___control)
            set RFBurstRecastTest___phase=5
            call RB_LogRecord("OBS" , "first-native-effect-latency" , "issue=" + R2S(RFBurstRecastTest___orderTime) + " effect=" + R2S(now) + " latency=" + R2S(now - RFBurstRecastTest___orderTime))
        elseif RFBurstRecastTest___recastCase and RFBurstRecastTest___expectedCast == 2 and RFBurstRecastTest___castEvents == 2 and RFBurstRecastTest___phase == 5 then
            set RFBurstRecastTest___expectedCast=0
            set RFBurstRecastTest___recastEffect=now
            set RFBurstRecastTest___recastEffectShots=RFBurstRecastTest___shots
            call RB_LogRecord("OBS" , "second-native-effect-latency" , "secondShot=" + R2S(RFBurstRecastTest___shotTime[2]) + " due=" + R2S(RFBurstRecastTest___recastDue) + " issue=" + R2S(RFBurstRecastTest___recastIssue) + " effect=" + R2S(now) + " latency=" + R2S(now - RFBurstRecastTest___recastIssue) + " shots=" + I2S(RFBurstRecastTest___shots))
            if RFBurstRecastTest___shots != 2 or now >= RFBurstRecastTest___shotTime[2] + .25 or now < RFBurstRecastTest___recastIssue then
                set RFBurstRecastTest___phase=- 1
            else
                set RFBurstRecastTest___recastQualified=true
            endif
        else
            // Cleanup is deferred outside native callback/shot dispatch.
            set RFBurstRecastTest___phase=- 1
        endif
        return false
    endfunction

    function RFBurstRecastTest___At takes unit u,real x,real y returns boolean
        return GetUnitTypeId(u) != 0 and RAbsBJ(GetUnitX(u) - x) <= 1. and RAbsBJ(GetUnitY(u) - y) <= 1.
    endfunction

    function RFBurstRecastTest___BodyReady takes unit u returns boolean
        return GetUnitTypeId(u) == 'o000' and GetWidgetLife(u) > 100. and GetUnitAbilityLevel(u, 'A00G') == 0 and GetUnitAbilityLevel(u, 'Ablo') == 0
    endfunction

    function RFBurstRecastTest___SceneReady takes nothing returns boolean
        local integer i= 0
        local real x
        // Placement gates ONLY. Spawn success is not walkability/transit proof.
        if not RFBurstRecastTest___At(RFBurstRecastTest___actor , - 2223.5 , 4352.) or not RFBurstRecastTest___At(RFBurstRecastTest___caster , - 5500. , - 5500.) or not RFBurstRecastTest___At(RFBurstRecastTest___target , - 1967.5 , 4352.) or not RFBurstRecastTest___At(RFBurstRecastTest___control , - 1967.5 , 4864.) then
            return false
        endif
        if not RFBurstRecastTest___BodyReady(RFBurstRecastTest___actor) or not RFBurstRecastTest___BodyReady(RFBurstRecastTest___target) or not RFBurstRecastTest___BodyReady(RFBurstRecastTest___control) or GetUnitTypeId(RFBurstRecastTest___caster) != 'o001' then
            return false
        endif
        if GetUnitAbilityLevel(RFBurstRecastTest___caster, 'A00G') != 1 or GetUnitAbilityLevel(RFBurstRecastTest___caster, 'Ablo') != 0 or IsUnitPaused(RFBurstRecastTest___actor) or IsUnitPaused(RFBurstRecastTest___caster) then
            return false
        endif
        if not IsUnitEnemy(RFBurstRecastTest___target, Player(0)) or not IsUnitEnemy(RFBurstRecastTest___control, Player(0)) or not IsUnitEnemy(RFBurstRecastTest___actor, Player(1)) then
            return false
        endif
        if GetOwningPlayer(RFBurstRecastTest___target) != Player(1) or GetOwningPlayer(RFBurstRecastTest___control) != Player(1) or not IsUnitPaused(RFBurstRecastTest___target) or not IsUnitPaused(RFBurstRecastTest___control) then
            return false
        endif
        if RAbsBJ(GetUnitFacing(RFBurstRecastTest___actor)) > .01 or GetUnitCurrentOrder(RFBurstRecastTest___actor) != 0 or GetWidgetLife(RFBurstRecastTest___caster) <= 0.405 then
            return false
        endif
        loop
            exitwhen i > 8
            set x=GetUnitX(RFBurstRecastTest___actor) + ( GetUnitX(RFBurstRecastTest___target) - GetUnitX(RFBurstRecastTest___actor) ) * I2R(i) / 8.
            if IsTerrainPathable(x, GetUnitY(RFBurstRecastTest___actor), PATHING_TYPE_WALKABILITY) then
                return false
            endif
            set i=i + 1
        endloop
        return not IsTerrainPathable(GetUnitX(RFBurstRecastTest___control), GetUnitY(RFBurstRecastTest___control), PATHING_TYPE_WALKABILITY)
    endfunction

    function RFBurstRecastTest___HasFlights takes unit sourceUnit returns boolean
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

    function RFBurstRecastTest___RemovedAbsent takes nothing returns boolean
        local group g= CreateGroup()
        local unit u
        local integer fixtureIndex= 0
        local integer seen= 0
        local boolean ok= GetUnitTypeId(RFBurstRecastTest___actor) == 0 and GetUnitTypeId(RFBurstRecastTest___caster) == 0 and GetUnitTypeId(RFBurstRecastTest___target) == 0 and GetUnitTypeId(RFBurstRecastTest___control) == 0
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
                set ok=seen <= 128 and u != RFBurstRecastTest___actor and u != RFBurstRecastTest___caster and u != RFBurstRecastTest___target and u != RFBurstRecastTest___control
                call GroupRemoveUnit(g, u)
            endloop
            set fixtureIndex=fixtureIndex + 1
        endloop
        call DestroyGroup(g)
        set g=null
        set u=null
        return ok
    endfunction

    function RFBurstRecastTest___CompleteRegression takes nothing returns nothing
        call RB_LogCase("R03-active-recast-reset-and-cadence")
        if RFBurstRecastTest___HasFlights(RFBurstRecastTest___actor) then
            call RFBurstRecastTest___Abort("prior actor still has public allocated flights after3s; no fresh-case admission")
            return
        endif
        call RB_LogCheck(true , "prior-flights-clear" , "public core collection has no allocated flight from prior actor")
        call RFBurstRecastTest___ClearScene()
        set RFBurstRecastTest___phase=6
    endfunction

    function RFBurstRecastTest___Assess takes nothing returns nothing
        local real targetEnd= GetWidgetLife(RFBurstRecastTest___target)
        local real controlEnd= GetWidgetLife(RFBurstRecastTest___control)
        local real differential= ( controlEnd - RFBurstRecastTest___controlStart ) - ( targetEnd - RFBurstRecastTest___targetStart )
        local integer i= 2
        call RB_LogRecord("OBS" , "actor-end" , RFBurstRecastTest___Pose(RFBurstRecastTest___actor))
        call RB_LogRecord("OBS" , "target-control-HP" , "target=" + R2S(RFBurstRecastTest___targetStart) + "->" + R2S(targetEnd) + " control=" + R2S(RFBurstRecastTest___controlStart) + "->" + R2S(controlEnd) + " differential=" + R2S(differential))
        call RB_LogCheck(RFBurstRecastTest___shots == 4 , "four-shot-notifications" , "actual=" + I2S(RFBurstRecastTest___shots) + " expected=4")
        call RB_LogCheck(RFBurstRecastTest___shots == 4 and RFBurstRecastTest___projectilesOK , "four-real-public-projectiles" , "live launched Missiles, separate native dummy, visible source and actual actor origin required at each pulse")
        call RB_LogCheck(RFBurstRecastTest___hits == 4 , "four-native-hits" , "actual=" + I2S(RFBurstRecastTest___hits) + " expected=4")
        call RB_LogCheck(RFBurstRecastTest___hits == 4 and RFBurstRecastTest___hitValuesOK , "native-ten-per-hit" , "each GetEventDamage must be10 tolerance=.01; no calibration events counted")
        call RB_LogCheck(RFBurstRecastTest___hits == 4 and RFBurstRecastTest___hitSourcesOK , "visible-damage-source" , "each GetEventDamageSource must equal visible actor, not logical caster")
        call RB_LogCheck(RAbsBJ(differential - 40.) <= RFBurstRecastTest___HP_TOLERANCE , "native-HP-differential40" , "actual=" + R2S(differential) + " tolerance=.10; same-type paired regen control")
        call RB_LogCheck(RFBurstRecastTest___controlHits == 0 , "control-undamaged" , "actual=" + I2S(RFBurstRecastTest___controlHits))
        call RB_LogCheck(targetEnd > .405 and controlEnd > .405 , "targets-survive" , "target=" + R2S(targetEnd) + " control=" + R2S(controlEnd))
        call RB_LogCase("B02-default-cadence")
        if RFBurstRecastTest___shots != 4 then
            call RB_LogRecord("FAIL" , "missing-cadence-observations" , "need4 actual shot pulses/3 adjacent intervals; actual=" + I2S(RFBurstRecastTest___shots))
        else
            loop
                exitwhen i > 4
                call RB_LogCheck(RAbsBJ(( RFBurstRecastTest___shotTime[i] - RFBurstRecastTest___shotTime[i - 1] ) - .25) <= RFBurstRecastTest___CADENCE_TOLERANCE , "cadence-interval" + I2S(i - 1) , "actual=" + R2S(RFBurstRecastTest___shotTime[i] - RFBurstRecastTest___shotTime[i - 1]) + " expected=.25 tolerance=.03125")
                set i=i + 1
            endloop
        endif
        call RFBurstRecastTest___CompleteRegression()
    endfunction

    function RFBurstRecastTest___AssessRecast takes nothing returns nothing
        local real targetEnd= GetWidgetLife(RFBurstRecastTest___target)
        local real controlEnd= GetWidgetLife(RFBurstRecastTest___control)
        local real differential= ( controlEnd - RFBurstRecastTest___controlStart ) - ( targetEnd - RFBurstRecastTest___targetStart )
        local integer i= 2
        call RB_LogRecord("OBS" , "actor-end" , RFBurstRecastTest___Pose(RFBurstRecastTest___actor))
        call RB_LogRecord("OBS" , "recast-target-control-HP" , "shots=" + I2S(RFBurstRecastTest___shots) + " hits=" + I2S(RFBurstRecastTest___hits) + " target=" + R2S(RFBurstRecastTest___targetStart) + "->" + R2S(targetEnd) + " control=" + R2S(RFBurstRecastTest___controlStart) + "->" + R2S(controlEnd) + " differential=" + R2S(differential))
        call RB_LogCheck(RFBurstRecastTest___recastQualified and RFBurstRecastTest___castEvents == 2 and RFBurstRecastTest___recastEffectShots == 2 , "native-active-window-ready" , "exact second source/A00G/point effect at observed shot2 and before shot2+.25")
        call RB_LogCheck(RFBurstRecastTest___shots == 6 , "reset-to-four-not-add-or-ignore" , "actual=" + I2S(RFBurstRecastTest___shots) + " expected=6; ignore gives4/add gives8")
        call RB_LogCheck(RFBurstRecastTest___shots == 6 and RFBurstRecastTest___projectilesOK , "six-real-public-projectiles" , "live launched core missiles/separate dummy/source/current actor origin required")
        call RB_LogCheck(RFBurstRecastTest___hits == 6 , "six-native-hits" , "actual=" + I2S(RFBurstRecastTest___hits) + " expected=6")
        call RB_LogCheck(RFBurstRecastTest___hits == 6 and RFBurstRecastTest___hitValuesOK , "native-ten-per-hit" , "six real target UNIT_DAMAGED values10 tolerance=.01")
        call RB_LogCheck(RFBurstRecastTest___hits == 6 and RFBurstRecastTest___hitSourcesOK , "visible-damage-source" , "all6 GetEventDamageSource equal visible actor")
        call RB_LogCheck(RAbsBJ(differential - 60.) <= RFBurstRecastTest___HP_TOLERANCE , "native-HP-differential60" , "actual=" + R2S(differential) + " tolerance=.10; same-type paired regen control")
        call RB_LogCheck(RFBurstRecastTest___controlHits == 0 , "control-undamaged" , "actual=" + I2S(RFBurstRecastTest___controlHits))
        call RB_LogCheck(targetEnd > .405 and controlEnd > .405 , "targets-survive" , "target=" + R2S(targetEnd) + " control=" + R2S(controlEnd))
        call RB_LogCheck(not RFBurstRecastTest___earlyPulse , "no-extra-immediate-recast-shot" , "no observed post-recast pulse before secondShot+.25 (float epsilon .0001)")
        loop
            exitwhen i > 6
            if i <= RFBurstRecastTest___shots then
                call RB_LogCheck(RAbsBJ(( RFBurstRecastTest___shotTime[i] - RFBurstRecastTest___shotTime[i - 1] ) - .25) <= RFBurstRecastTest___CADENCE_TOLERANCE , "recast-cadence-interval" + I2S(i - 1) , "actual=" + R2S(RFBurstRecastTest___shotTime[i] - RFBurstRecastTest___shotTime[i - 1]) + " expected=.25 tolerance=.03125")
            else
                call RB_LogRecord("FAIL" , "missing-recast-cadence-interval" + I2S(i - 1) , "need6 real shots/5 adjacent intervals; actual shots=" + I2S(RFBurstRecastTest___shots))
            endif
            set i=i + 1
        endloop
        call RFBurstRecastTest___Finish()
    endfunction

    function RFBurstRecastTest___ResetObservations takes nothing returns nothing
        set RFBurstRecastTest___phase=0
        set RFBurstRecastTest___calibrated=false
        set RFBurstRecastTest___calibrationHits=0
        set RFBurstRecastTest___calibrationHP=0.
        set RFBurstRecastTest___calibrationDamage=0.
        set RFBurstRecastTest___calibrationSource=false
        set RFBurstRecastTest___controlHits=0
        set RFBurstRecastTest___hits=0
        set RFBurstRecastTest___hitValuesOK=true
        set RFBurstRecastTest___hitSourcesOK=true
        set RFBurstRecastTest___shots=0
        set RFBurstRecastTest___projectilesOK=true
        set RFBurstRecastTest___castEvents=0
        set RFBurstRecastTest___orderTime=0.
        set RFBurstRecastTest___castTime=0.
        set RFBurstRecastTest___targetStart=0.
        set RFBurstRecastTest___controlStart=0.
        set RFBurstRecastTest___expectedCast=0
        set RFBurstRecastTest___pendingRecast=false
        set RFBurstRecastTest___recastRequested=false
        set RFBurstRecastTest___recastQualified=false
        set RFBurstRecastTest___earlyPulse=false
        set RFBurstRecastTest___recastDue=0.
        set RFBurstRecastTest___recastIssue=0.
        set RFBurstRecastTest___recastEffect=0.
        set RFBurstRecastTest___recastEffectShots=0
    endfunction

    function RFBurstRecastTest___SpawnScene takes nothing returns nothing
        call RFBurstRecastTest___ResetObservations()
        set RFBurstRecastTest___actor=CreateUnit(Player(0), 'o000', - 2223.5, 4352., 0.)
        set RFBurstRecastTest___caster=CreateUnit(Player(0), 'o001', - 5500., - 5500., 0.)
        set RFBurstRecastTest___target=CreateUnit(Player(1), 'o000', - 1967.5, 4352., 0.)
        set RFBurstRecastTest___control=CreateUnit(Player(1), 'o000', - 1967.5, 4864., 0.)
        call PauseUnit(RFBurstRecastTest___target, true)
        call PauseUnit(RFBurstRecastTest___control, true)
        set RFBurstRecastTest___damageHook=CreateTrigger()
        call TriggerRegisterUnitEvent(RFBurstRecastTest___damageHook, RFBurstRecastTest___target, EVENT_UNIT_DAMAGED)
        call TriggerRegisterUnitEvent(RFBurstRecastTest___damageHook, RFBurstRecastTest___control, EVENT_UNIT_DAMAGED)
        call TriggerAddCondition(RFBurstRecastTest___damageHook, Condition(function RFBurstRecastTest___OnDamage))
        set RFBurstRecastTest___spellHook=CreateTrigger()
        call TriggerRegisterUnitEvent(RFBurstRecastTest___spellHook, RFBurstRecastTest___caster, EVENT_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(RFBurstRecastTest___spellHook, Condition(function RFBurstRecastTest___OnSpell))
        set RFBurstRecastTest___shotHook=CreateTrigger()
        call TriggerAddCondition(RFBurstRecastTest___shotHook, Condition(function RFBurstRecastTest___OnShot))
        if not RB_InitializePair(RFBurstRecastTest___actor , RFBurstRecastTest___caster , RFBurstRecastTest___shotHook) then
            call RFBurstRecastTest___Abort("public InitializePair refused validated rawcode contract")
        endif
    endfunction

    function RFBurstRecastTest___Tick takes nothing returns nothing
        local real life
        local boolean accepted
        if RFBurstRecastTest___phase == - 1 then
            call RFBurstRecastTest___Abort("unexpected native spell effect/source/ability/point or duplicate event")
        elseif RFBurstRecastTest___phase == 6 then
            if not RFBurstRecastTest___RemovedAbsent() then
                call RFBurstRecastTest___Abort("next-tick prior-unit type0/native group clearance unavailable")
                return
            endif
            call RB_LogCheck(true , "prior-unit-clearance" , "removed type0/native group absence observed on next harness tick")
            call RFBurstRecastTest___ReleaseSceneRefs()
            set RFBurstRecastTest___recastCase=true
            call RFBurstRecastTest___SpawnScene()
        elseif RFBurstRecastTest___phase == 0 then
            call RB_LogRecord("OBS" , "actor-ready" , RFBurstRecastTest___Pose(RFBurstRecastTest___actor))
            call RB_LogRecord("OBS" , "caster-ready" , RFBurstRecastTest___Pose(RFBurstRecastTest___caster) + " A00G=" + I2S(GetUnitAbilityLevel(RFBurstRecastTest___caster, 'A00G')))
            call RB_LogRecord("OBS" , "target-ready" , RFBurstRecastTest___Pose(RFBurstRecastTest___target))
            call RB_LogRecord("OBS" , "control-ready" , RFBurstRecastTest___Pose(RFBurstRecastTest___control))
            if not RFBurstRecastTest___SceneReady() then
                call RFBurstRecastTest___Abort("type/life/enemy/placement/abilities/pause/facing/order/fresh static path flag readiness unavailable")
                return
            endif
            set RFBurstRecastTest___phase=1
            set RFBurstRecastTest___calibrationHP=GetWidgetLife(RFBurstRecastTest___target)
            // Explicit physical base mapping for this controlled scene. No spell,
            // fire, magic, universal, AOE, burn or armor-getter assumption.
            set RFBurstRecastTest___calibrated=UnitDamageTarget(RFBurstRecastTest___actor, RFBurstRecastTest___target, 10., true, true, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL, null)
        elseif RFBurstRecastTest___phase == 1 then
            call RB_LogRecord("OBS" , "native-calibration" , "events=" + I2S(RFBurstRecastTest___calibrationHits) + " damage=" + R2S(RFBurstRecastTest___calibrationDamage) + " HPbefore=" + R2S(RFBurstRecastTest___calibrationHP) + " HPafter=" + R2S(GetWidgetLife(RFBurstRecastTest___target)))
            if not RFBurstRecastTest___calibrated or RFBurstRecastTest___calibrationHits != 1 or not RFBurstRecastTest___calibrationSource or RAbsBJ(RFBurstRecastTest___calibrationDamage - 10.) > .01 or GetWidgetLife(RFBurstRecastTest___target) >= RFBurstRecastTest___calibrationHP or RFBurstRecastTest___controlHits != 0 then
                call RFBurstRecastTest___Abort("physical10 native calibration unavailable; no burst-rule RED inferred")
                return
            endif
            set life=RMinBJ(GetUnitState(RFBurstRecastTest___target, UNIT_STATE_MAX_LIFE), GetUnitState(RFBurstRecastTest___control, UNIT_STATE_MAX_LIFE)) - 10.
            if life <= 60. then
                call RFBurstRecastTest___Abort("insufficient controlled health margin")
                return
            endif
            call SetWidgetLife(RFBurstRecastTest___target, life)
            call SetWidgetLife(RFBurstRecastTest___control, life)
            if RAbsBJ(GetWidgetLife(RFBurstRecastTest___target) - life) > .001 or RAbsBJ(GetWidgetLife(RFBurstRecastTest___control) - life) > .001 then
                call RFBurstRecastTest___Abort("same native starting health reset failed")
                return
            endif
            set RFBurstRecastTest___phase=3
        elseif RFBurstRecastTest___phase == 3 then
            set RFBurstRecastTest___hits=0
            set RFBurstRecastTest___controlHits=0
            set RFBurstRecastTest___shots=0
            set RFBurstRecastTest___aimX=GetUnitX(RFBurstRecastTest___target)
            set RFBurstRecastTest___aimY=GetUnitY(RFBurstRecastTest___target)
            set RFBurstRecastTest___orderTime=TimerGetElapsed(RFBurstRecastTest___clock)
            set RFBurstRecastTest___expectedCast=1
            set RFBurstRecastTest___phase=4
            set accepted=IssuePointOrder(RFBurstRecastTest___caster, "channel", RFBurstRecastTest___aimX, RFBurstRecastTest___aimY)
            call RB_LogCheck(accepted , "native-point-order-accepted" , "actual target point=" + R2S(RFBurstRecastTest___aimX) + "," + R2S(RFBurstRecastTest___aimY))
            if not accepted then
                call RFBurstRecastTest___Abort("native point order rejected; behavior assertions not run")
            endif
        elseif RFBurstRecastTest___phase == 4 then
            if TimerGetElapsed(RFBurstRecastTest___clock) - RFBurstRecastTest___orderTime >= 2. then
                call RFBurstRecastTest___Abort("native Channel effect deadline2s; no behavior assertions without actual event")
            endif
        elseif RFBurstRecastTest___phase == 5 then
            if RFBurstRecastTest___recastCase then
                if RFBurstRecastTest___pendingRecast and TimerGetElapsed(RFBurstRecastTest___clock) >= RFBurstRecastTest___recastDue then
                    if RFBurstRecastTest___shots != 2 then
                        call RFBurstRecastTest___Abort("active-window input unavailable: not exactly2 observed shots")
                        return
                    endif
                    // Commit BEFORE IssuePointOrder: native effect may be synchronous.
                    set RFBurstRecastTest___pendingRecast=false
                    set RFBurstRecastTest___recastRequested=true
                    set RFBurstRecastTest___expectedCast=2
                    set RFBurstRecastTest___recastIssue=TimerGetElapsed(RFBurstRecastTest___clock)
                    call RB_LogRecord("OBS" , "recast-point-order" , "secondShot=" + R2S(RFBurstRecastTest___shotTime[2]) + " due=" + R2S(RFBurstRecastTest___recastDue) + " issue=" + R2S(RFBurstRecastTest___recastIssue))
                    set accepted=IssuePointOrder(RFBurstRecastTest___caster, "channel", RFBurstRecastTest___aimX, RFBurstRecastTest___aimY)
                    call RB_LogCheck(accepted , "native-recast-order-accepted" , "same actual target point=" + R2S(RFBurstRecastTest___aimX) + "," + R2S(RFBurstRecastTest___aimY))
                    if not accepted then
                        call RFBurstRecastTest___Abort("native recast order rejected; no behavioral recast RED")
                    endif
                elseif RFBurstRecastTest___recastRequested and not RFBurstRecastTest___recastQualified and TimerGetElapsed(RFBurstRecastTest___clock) >= RFBurstRecastTest___shotTime[2] + .25 then
                    call RFBurstRecastTest___Abort("second native effect absent before secondShot+.25; no active-window qualification")
                elseif not RFBurstRecastTest___recastRequested and TimerGetElapsed(RFBurstRecastTest___clock) - RFBurstRecastTest___castTime >= .75 then
                    call RFBurstRecastTest___Abort("two live public projectile notifications unavailable by first-effect+.75")
                elseif RFBurstRecastTest___recastQualified and TimerGetElapsed(RFBurstRecastTest___clock) - RFBurstRecastTest___recastEffect >= 3. then
                    call RFBurstRecastTest___AssessRecast()
                endif
            elseif RFBurstRecastTest___castEvents != 1 then
                call RFBurstRecastTest___Abort("expected exactly one native cast event")
            elseif TimerGetElapsed(RFBurstRecastTest___clock) - RFBurstRecastTest___castTime >= 3. then
                call RB_LogCheck(true , "native-cast-effect-ready" , "one matching source/A00G/actual target point; observation horizon3s relative to native event")
                call RFBurstRecastTest___Assess()
            endif
        endif
    endfunction

    function RF_StartRecastTest takes nothing returns nothing
        call RB_LogBegin()
        call RB_LogCase("B01-four-shot-native-effects")
        call SetPlayerAlliance(Player(0), Player(1), ALLIANCE_PASSIVE, false)
        call SetPlayerAlliance(Player(1), Player(0), ALLIANCE_PASSIVE, false)
        set RFBurstRecastTest___clock=CreateTimer()
        set RFBurstRecastTest___runner=CreateTimer()
        call TimerStart(RFBurstRecastTest___clock, 20., false, function RFBurstRecastTest___Deadline)
        call RFBurstRecastTest___SpawnScene()
        if not RFBurstRecastTest___done then
            call TimerStart(RFBurstRecastTest___runner, RFBurstRecastTest___PERIOD, true, function RFBurstRecastTest___Tick)
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
// BEGIN IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\RecastLogRed02.j

// END IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\RecastLogRed02.j
// BEGIN IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\PairCore.j

// END IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\PairCore.j
// BEGIN IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\RecastNativeTest.j

// END IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\RecastNativeTest.j
function RCStartHarness takes nothing returns nothing
    call RF_StartRecastTest()
endfunction
// BEGIN IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\RecastMapMainRed02.j
// Separate external-source executable. Inherited W3I/WCT/WTG are unchanged;
// one runtime P0, not an editor-save or multiplayer certificate.
function config takes nothing returns nothing
    local integer i= 1
    call SetMapName("Rapid Fire Recast RED B01 B02 R03")
    call SetMapDescription("rf-burst-recast-red-20261020-02: unchanged emitter; native active-recast RED")
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

    call ExecuteFunc("jasshelper__init6168")

    call PanCameraTo(- 2223.5, 4352.)
    call RF_StartRecastTest() // INLINED!!
endfunction

// END IMPORT OF Z:\home\snz\Documentos\ChatGPT\WDev\projects\rapid-fire-prototype\src\prototype\RecastMapMainRed02.j



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
            if (st__Missiles__MissileEvents_onRemove[si__Missiles__MissileEvents_type[this]]!=null) then
                call sc__Missiles__MissileEvents_onRemove(this)
            endif
            if s__Missiles_index[this] != - 1 then
                set aux=s__Missiles_collection[s__Missiles_count]
                set s__Missiles_index[aux]=s__Missiles_index[this]
                set s__Missiles_collection[s__Missiles_index[this]]=s__Missiles_collection[s__Missiles_count]
                set s__Missiles_count=s__Missiles_count - 1
                set s__Missiles_index[this]=- 1
            endif
                call SetUnitOwner(s__Missiles_dummy[this], Player(PLAYER_NEUTRAL_PASSIVE), false)
                call DummyAddRecycleTimer(s__Missiles_dummy[this] , Missiles__RECYCLE_TIME)
            call s__Missiles_clearVision(this)
            call s__Missiles__Coordinates_deallocate((s__Missiles_origin[this])) // INLINED!!
            call s__Missiles__Coordinates_deallocate((s__Missiles_impact[this])) // INLINED!!
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
                call sc__Missiles__MissileEvents_deallocate(this)
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
        set d=s__Missiles__Coordinates_distance[o]
        if (st__Missiles__MissileEvents_onHit[si__Missiles__MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                call GroupEnumUnitsInRange(s__Missiles_group, s__Missiles_x[this], s__Missiles_y[this], s__Missiles_collision[this] + Missiles__COLLISION_SIZE, null)
                loop
                    set u=FirstOfGroup(s__Missiles_group)
                    exitwhen u == null or not s__Missiles_allocated[this]
                        if not HaveSavedBoolean(s__Missiles_Missiles__table, this, GetHandleId(u)) then
                            if IsUnitInRangeXY(u, s__Missiles_x[this], s__Missiles_y[this], s__Missiles_collision[this]) then
                                if s__Missiles_collideZ[this] then
                                    set dx=Missiles__GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u)
                                    set dy=Missiles__GetUnitCollisionSize(u)
                                    if dx + dy >= s__Missiles_z[this] - s__Missiles_collision[this] and dx <= s__Missiles_z[this] + s__Missiles_collision[this] then
                                        call SaveBoolean(s__Missiles_Missiles__table, this, GetHandleId(u), true)
                                        set stop=sc__Missiles__MissileEvents_onHit(this,u)
                                        if s__Missiles_allocated[this] and stop then
                                            call s__Missiles_terminate(this)
                                        endif
                                        exitwhen not s__Missiles_allocated[this]
                                    endif
                                else
                                    call SaveBoolean(s__Missiles_Missiles__table, this, GetHandleId(u), true)
                                    set stop=sc__Missiles__MissileEvents_onHit(this,u)
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
        if (st__Missiles__MissileEvents_onMissile[si__Missiles__MissileEvents_type[this]]!=null) then
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
                                    set stop=sc__Missiles__MissileEvents_onMissile(this,missile)
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
        if (st__Missiles__MissileEvents_onDestructable[si__Missiles__MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                set dx=s__Missiles_collision[this] + Missiles__COLLISION_SIZE
                call SetRect(s__Missiles_rect, s__Missiles_x[this] - dx, s__Missiles_y[this] - dx, s__Missiles_x[this] + dx, s__Missiles_y[this] + dx)
                call EnumDestructablesInRect(s__Missiles_rect, null, function s__Missiles_onDest)
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
        if (st__Missiles__MissileEvents_onItem[si__Missiles__MissileEvents_type[this]]!=null) then
            if s__Missiles_allocated[this] and s__Missiles_collision[this] > 0 then
                set dx=s__Missiles_collision[this] + Missiles__COLLISION_SIZE
                call SetRect(s__Missiles_rect, s__Missiles_x[this] - dx, s__Missiles_y[this] - dx, s__Missiles_x[this] + dx, s__Missiles_y[this] + dx)
                call EnumItemsInRect(s__Missiles_rect, null, function s__Missiles_onItems)
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
        if (st__Missiles__MissileEvents_onCliff[si__Missiles__MissileEvents_type[this]]!=null) then
            set dx=GetTerrainCliffLevel(s__Missiles_nextX[this], s__Missiles_nextY[this])
            set dy=GetTerrainCliffLevel(s__Missiles_x[this], s__Missiles_y[this])
            if dy < dx and s__Missiles_z[this] < ( dx - (GetTerrainCliffLevel(s__WorldBounds_maxX, s__WorldBounds_maxY)) ) * bj_CLIFFHEIGHT then // INLINED!!
                set stop=sc__Missiles__MissileEvents_onCliff(this)
                if s__Missiles_allocated[this] and stop then
                    call s__Missiles_terminate(this)
                endif
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
        if (st__Missiles__MissileEvents_onTerrain[si__Missiles__MissileEvents_type[this]]!=null) then
            if Missiles__GetLocZ(s__Missiles_x[this] , s__Missiles_y[this]) > s__Missiles_z[this] then
                set stop=sc__Missiles__MissileEvents_onTerrain(this)
                if s__Missiles_allocated[this] and stop then
                    call s__Missiles_terminate(this)
                endif
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
        if (st__Missiles__MissileEvents_onTileset[si__Missiles__MissileEvents_type[this]]!=null) then
            set k=GetTerrainType(s__Missiles_x[this], s__Missiles_y[this])
            if k != s__Missiles_tileset[this] then
                set stop=sc__Missiles__MissileEvents_onTileset(this,k)
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
        if (st__Missiles__MissileEvents_onPeriod[si__Missiles__MissileEvents_type[this]]!=null) then
            set stop=sc__Missiles__MissileEvents_onPeriod(this)
            if s__Missiles_allocated[this] and stop then
                call s__Missiles_terminate(this)
            endif
        endif
                        endif
                        if s__Missiles_allocated[this] then
        set u=s__Missiles_target[this]
        if u != null and GetUnitTypeId(u) != 0 then
            call s__Missiles__Coordinates_move(s__Missiles_impact[this],GetUnitX(u) , GetUnitY(u) , GetUnitFlyHeight(u) + s__Missiles_toZ[this])
            set dx=s__Missiles__Coordinates_x[s__Missiles_impact[this]] - s__Missiles_baseX[this]
            set dy=s__Missiles__Coordinates_y[s__Missiles_impact[this]] - s__Missiles_baseY[this]
            set a=Atan2(dy, dx)
            set s__Missiles_progress[this]=s__Missiles__Coordinates_distance[s__Missiles_origin[this]] - SquareRoot(dx * dx + dy * dy)
        else
            set a=s__Missiles__Coordinates_angle[s__Missiles_origin[this]]
            set s__Missiles_target[this]=null
        endif
        set o=s__Missiles_origin[this]
        set d=s__Missiles__Coordinates_distance[o]
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
        set pitch=s__Missiles__Coordinates_alpha[o] - Atan(4 * h * ( 2 * s - d ) / ( d * d )) * bj_RADTODEG
        set yaw=( s__Missiles_cA[this] + Atan(- 4 * c * ( 2 * s - d ) / ( d * d )) ) * bj_RADTODEG
        call s__Missiles_refreshVision(this)
        if s >= d then
            set s__Missiles_finished[this]=true
            if (st__Missiles__MissileEvents_onFinish[si__Missiles__MissileEvents_type[this]]!=null) then
                set stop=sc__Missiles__MissileEvents_onFinish(this)
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
            call Missiles__SetUnitZ(s__Missiles_dummy[this] , s__Missiles_z[this])
        else
            if (st__Missiles__MissileEvents_onBoundaries[si__Missiles__MissileEvents_type[this]]!=null) then
                set stop=sc__Missiles__MissileEvents_onBoundaries(this)
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
            set s__Missiles_origin[this]=s__Missiles__Coordinates_create(x , y , z)
            set s__Missiles_impact[this]=s__Missiles__Coordinates_create(toX , toY , toZ)
            call s__Missiles__Coordinates_link(s__Missiles_origin[this] , s__Missiles_impact[this])
            set s__Missiles_allocated[this]=true
            set s__Missiles_cA[this]=s__Missiles__Coordinates_angle[s__Missiles_origin[this]]
            set s__Missiles_x[this]=x
            set s__Missiles_y[this]=y
            set s__Missiles_z[this]=s__Missiles__Coordinates_z[s__Missiles_origin[this]]
            set s__Missiles_prevX[this]=x
            set s__Missiles_prevY[this]=y
            set s__Missiles_prevZ[this]=s__Missiles__Coordinates_z[s__Missiles_origin[this]]
            set s__Missiles_nextX[this]=x
            set s__Missiles_nextY[this]=y
            set s__Missiles_nextZ[this]=s__Missiles__Coordinates_z[s__Missiles_origin[this]]
            set s__Missiles_toZ[this]=toZ
            set s__Missiles_baseX[this]=x
            set s__Missiles_baseY[this]=y
            set s__Missiles_nextBaseX[this]=x
            set s__Missiles_nextBaseY[this]=y
                set s__Missiles_dummy[this]=GetRecycledDummy(x , y , z , face)
            call Missiles__SetUnitZ(s__Missiles_dummy[this] , s__Missiles__Coordinates_z[s__Missiles_origin[this]])
set f__result_integer= this
   return true
endfunction
function sa__RFBurstPair__RBProjectile_onHit takes nothing returns boolean
    set f__result_boolean=s__RFBurstPair__RBProjectile_onHit(f__arg_this,f__arg_unit1)
   return true
endfunction
function sa__RFBurstPair__RBProjectile_onPeriod takes nothing returns boolean
local integer this=f__arg_this
set f__result_boolean= not RFBurstPair__LiveOwned(s__RFBurstPair__RBProjectile_savedActor[this] , s__RFBurstPair__RBProjectile_savedOwner[this])
   return true
endfunction
function sa__RFBurstPair__RBProjectile_onRemove takes nothing returns boolean
local integer this=f__arg_this
            set s__RFBurstPair__RBProjectile_savedActor[this]=null
            set s__RFBurstPair__RBProjectile_savedController[this]=null
            set s__RFBurstPair__RBProjectile_savedOwner[this]=null
            set s__RFBurstPair__RBProjectile_spent[this]=true
   return true
endfunction
function sa___prototype3_TimerUtils___init takes nothing returns boolean

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

function jasshelper__init6168 takes nothing returns nothing
    set st__Missiles__MissileEvents_onHit[6]=null
    set st__Missiles__MissileEvents_onMissile[6]=null
    set st__Missiles__MissileEvents_onMissile[7]=null
    set st__Missiles__MissileEvents_onDestructable[6]=null
    set st__Missiles__MissileEvents_onDestructable[7]=null
    set st__Missiles__MissileEvents_onItem[6]=null
    set st__Missiles__MissileEvents_onItem[7]=null
    set st__Missiles__MissileEvents_onCliff[6]=null
    set st__Missiles__MissileEvents_onCliff[7]=null
    set st__Missiles__MissileEvents_onTerrain[6]=null
    set st__Missiles__MissileEvents_onTerrain[7]=null
    set st__Missiles__MissileEvents_onTileset[6]=null
    set st__Missiles__MissileEvents_onTileset[7]=null
    set st__Missiles__MissileEvents_onPeriod[6]=null
    set st__Missiles__MissileEvents_onFinish[6]=null
    set st__Missiles__MissileEvents_onFinish[7]=null
    set st__Missiles__MissileEvents_onBoundaries[6]=null
    set st__Missiles__MissileEvents_onBoundaries[7]=null
    set st__Missiles__MissileEvents_onPause[6]=null
    set st__Missiles__MissileEvents_onPause[7]=null
    set st__Missiles__MissileEvents_onResume[6]=null
    set st__Missiles__MissileEvents_onResume[7]=null
    set st__Missiles__MissileEvents_onRemove[6]=null
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
    set st__Missiles__MissileEvents_onDestroy[6]=null
    set st__Missiles__MissileEvents_onDestroy[7]=null
    set st__Missiles__MissileEvents_onHit[7]=CreateTrigger()
    call TriggerAddCondition(st__Missiles__MissileEvents_onHit[7],Condition( function sa__RFBurstPair__RBProjectile_onHit))
    call TriggerAddAction(st__Missiles__MissileEvents_onHit[7], function sa__RFBurstPair__RBProjectile_onHit)
    set st__Missiles__MissileEvents_onPeriod[7]=CreateTrigger()
    call TriggerAddCondition(st__Missiles__MissileEvents_onPeriod[7],Condition( function sa__RFBurstPair__RBProjectile_onPeriod))
    call TriggerAddAction(st__Missiles__MissileEvents_onPeriod[7], function sa__RFBurstPair__RBProjectile_onPeriod)
    set st__Missiles__MissileEvents_onRemove[7]=CreateTrigger()
    call TriggerAddCondition(st__Missiles__MissileEvents_onRemove[7],Condition( function sa__RFBurstPair__RBProjectile_onRemove))
    call TriggerAddAction(st__Missiles__MissileEvents_onRemove[7], function sa__RFBurstPair__RBProjectile_onRemove)
    set st___prototype3[1]=CreateTrigger()
    call TriggerAddAction(st___prototype3[1],function sa___prototype3_TimerUtils___init)
    call TriggerAddCondition(st___prototype3[1],Condition(function sa___prototype3_TimerUtils___init))


call ExecuteFunc("TimerUtils___init")
//------------------------------------
call ExecuteFunc("s__WorldBounds_WorldBounds__WorldBoundInit___onInit")
//------------------------------------
call ExecuteFunc("s__DummyRecycler___S_DummyRecycler___M___onInit")
//------------------------------------

endfunction

