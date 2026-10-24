//TESH.scrollpos=0
//TESH.alwaysfold=0
//=============================================================
// Name: Missile
// Version: 1.6.1
// Description: A system for your projectile needs.
// Author: BPower
//
// Written in JASS, API designed for usage with GUI.
// Published on hiveworkshop.com
//     - hiveworkshop.com/forums/spells-569/missile-gui-version-1-1-a-275718/
//=============================================================
// Before getting started make sure that you check 
// the settings in trigger Missile Configurate.
//
//     udg_Missile__DummyTypeId 
//        • Make sure you have Vexorians dummy.mdx imported.
//        • Only units of this type id will be recycled. 
//
//=============================================================
//  Variable naming. 
//============================================================= 
// Variables which users shouldn't access have no underscore.
// Array variables which are available at any time have one underscore _.
// Scalar variables which are only available during events have two underscores __.
// 
//=============================================================
//  Missile API. 
//=============================================================  
// Syntax for missile creation in GUI:
//    1. Run trigger Missile Configurate <gen> 
//    2. Set properties via scalar variables.
//    3. Run trigger Missile <gen>
// JASS users may call the create and launch function directly.
//
// Missile operates with custom events.
// This means that you have access to 
// a missile's properties within action functions
// of the Missile trigger interface. 
//
// "udg_Missile__EventId" indicates
// which event trigger has been dispatched.
//
// "udg_Missile__EventIndex" is the array index
// of the triggering missile.
//
// Avaliable events are:
//
//   1.) udg_EVENT_MISSILE_COLLIDE_UNIT
//        • Runs when a missile collides with a unit.
//
//   2.) udg_EVENT_MISSILE_COLLIDE_DEST
//        • Runs when a missile collides with a destructable.
//
//   3.) udg_EVENT_MISSILE_PERIODIC
//        • Runs every missile timer interval.
//
//   4.) udg_EVENT_MISSILE_FINISH
//        • Runs when a missile reaches its impact position.
//
//   5.) udg_EVENT_MISSILE_REMOVE
//        • Runs when a missile is destroyed.
//
//   6.) udg_EVENT_MISSILE_NOTHING
//        • Value of udg_Missile__EventId when accessed
//          from outside a trigger action function.
//
// During every missile event you may use the 
// following GUI generated variables.
// Every scalar variable has an equivalent array variable,
// which you can read and use at any time. 
// For exmple: udg_Missile__Source vs. udg_Missile_Source[index]
//
// Trigger variables which fire Missile events:
//
//    trigger udg_Missile__OnCollideUnit            -    trigger array udg_Missile_OnUnit 
//    trigger udg_Missile__OnCollideDestructable    -    trigger array udg_Missile_OnDest
//    trigger udg_Missile__OnPeridoic               -    trigger array udg_Missile_OnPeriodic
//    trigger udg_Missile__OnRemove                 -    trigger array udg_Missile_OnRemove
//    trigger udg_Missile__OnFinish                 -    trigger array udg_Missile_OnFinish
//
// Variables which mimic a function call:
//
//    location udg_Missile__Origin    
//    location udg_Missile__Impact      
//    boolean  udg_Missile__WantDestroy    -    boolean array udg_Missile_WantDestroy
//    boolean  udg_Missile__Recycle        -    boolean array udg_Missile_Recycle
//    real     udg_Missile__Scale          -    real    array udg_Missile_Scale
//    real     udg_Missile__FlyTime        -    real    array udg_Missile_FlyTime ( Converts time in seconds to a vector lenght )
//    real     udg_Missile__Model          -    string  array udg_Missile_Model   ( Converts a string path to a special effect )
//    real     udg_Missile__Arc            -    real    array udg_Missile_Arc     ( Converts an arc in degree to height value )
//    real     udg_Missile__Curve          -    real    array udg_Missile_Curve   ( Converts a curve in degree to an open value )
//
// Variables for read-only:
//
//    integer udg_Missile__EventId     
//    integer udg_Missile__EventIndex  
//    unit    udg_Missile__Dummy           -    unit array udg_Missile_Dummy
//    real    udg_Missile__Angle           -    real array udg_Missile_Angle    ( In radians )
//    real    udg_Missile__Distance        -    real array udg_Missile_Distance ( Total distance traveled )
//
// Variables for read and set.
//
//    unit    udg_Missile__Source          -    unit    array udg_Missile_Source
//    unit    udg_Missile__Target          -    unit    array udg_Missile_Target    ( Enables homing behaviour towards a target unit )
//    player  udg_Missile__Owner           -    unit    array udg_Missile_Owner     ( Pseudo-owner for better onCollide evaluation ) 
//    real    udg_Missile__ImpactZ         -    real    array udg_Missile_ImpactZ
//    real    udg_Missile__OriginZ         -    real    array udg_Missile_OriginZ
//    real    udg_Missile__Damage          -    real    array udg_Missile_Damage
//    real    udg_Missile__Collision       -    real    array udg_Missile_Collision
//    real    udg_Missile__Speed           -    real    array udg_Missile_Speed
//    real    udg_Missile__Acceleration    -    real    array udg_Missile_Acceleration
//    real    udg_Missile__Height          -    real    array udg_Missile_Height    ( Highest point of the parabola )
//    real    udg_Missile__Open            -    real    array udg_Missile_Open      
//    real    udg_Missile__Turn            -    real    array udg_Missile_Turn      ( Turn ratio per second )
//    real    udg_Missile__Data            -    integer array udg_Missile_Data
//
//=============================================================
// JASS user settings.
//=============================================================

// Set the timer timeout for projectile motion and trigger interface evaluation.
constant function Missile_GetTimerTimeout takes nothing returns real
    return 0.031250000
endfunction

// Set the maximum widget collision radius in this map.
// By default the largest pathing is the human townhall with 196.
constant function Missile_GetMaxCollision takes nothing returns real
    return 196.
endfunction

// Set the owning player of all dummy units.
// It should be a neutral player in your map.
constant function Missile_GetDummyOwner takes nothing returns player
    return Player(PLAYER_NEUTRAL_PASSIVE)
endfunction

// Fictional z height for units in your map.
function Missile_GetUnitBodySize takes unit whichUnit returns real
    return 100.
endfunction

// Fictional z height for destructables in your map.
function Missile_GetDestructableHeight takes destructable whichDest returns real
    return GetDestructableOccluderHeight(whichDest)
endfunction

// Fictional value for the maximum effect death time in your map.
constant function Missile_GetEffectDeathTime takes nothing returns integer
    return 3
endfunction

//=============================================================
// Required utility functions.
//=============================================================

// Debugging Missile.
// Change the condition from "true" to "false" or delete 
// the content of this function to disable error messages.
function Missile_ErrorMessage takes boolean expr, string func, string object, integer index, string text returns nothing
    local string orange = "|cffffa500" 
    local string blue   = "|cff99b4d1"
    local string next   = "\n"
    local string space  = "    "
    local string str    = space + next
    if expr and true then
        set str = str +                       orange + "Error in Trigger Missile|r" 
        set str = str + next + next + space + orange + "Function: |r"    + blue + func       + "|r" 
        set str = str        + next + space + orange + "Object: |r"      + blue + object     + "|r"
        set str = str        + next + space + orange + "Index: |r"       + blue + I2S(index) + "|r"
        set str = str        + next + space + orange + "Description: |r" + blue + text       + "|r"
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, 3600.00, str)
    endif
endfunction

// Returns the proper Z height of point p(x/y).
function Missile_GetLocZ takes real x, real y returns real
    call MoveLocation(udg_MissileLocZ, x, y)
    return GetLocationZ(udg_MissileLocZ)
endfunction

function Missile_GetArc takes integer index returns real
    return Tan(udg_Missile__Arc*bj_DEGTORAD)*udg_Missile_AB_Distance[index]/4
endfunction

function Missile_GetCurve takes integer index returns real
    return Tan(udg_Missile__Curve*bj_DEGTORAD)*udg_Missile_AB_Distance[index]
endfunction

// Converts fly time to missile speed.
// Doesn't take acceleration into account.
function Missile_GetFlyTime takes integer index returns real                
    return (udg_Missile_AB_Distance[index] - udg_Missile_AB_Traveled[index])/RMaxBJ(0.0000001, udg_Missile__FlyTime)
endfunction

function Missile_Math takes integer index returns nothing
    local real dx
    local real dy
    local real iz// Allows to set an impact offset in z.
    
    if udg_Missile_Target[index] != null and GetUnitTypeId(udg_Missile_Target[index]) != 0 then
        set udg_Missile_OriginX[index] = GetUnitX(udg_Missile_Dummy[index])
        set udg_Missile_OriginY[index] = GetUnitY(udg_Missile_Dummy[index])
        set udg_Missile_OriginZ[index] = GetUnitFlyHeight(udg_Missile_Dummy[index])
        set udg_Missile_ImpactX[index] = GetUnitX(udg_Missile_Target[index])
        set udg_Missile_ImpactY[index] = GetUnitY(udg_Missile_Target[index])
        set udg_Missile_AB_Traveled[index] = 0.00
        // Once you set a homing target you'll lose arc & curve settings.
        // That may get patched in the next version update.
        set udg_Missile_Open[index] = 0.00
        set udg_Missile_Height[index] = 0.00
        set udg_Missile_Curve[index] = 0.00
        set udg_Missile_Arc[index] = 0.00
        set iz = GetUnitFlyHeight(udg_Missile_Target[index]) + udg_Missile_ImpactZ[index]
    else
        set iz = udg_Missile_ImpactZ[index]
    endif
    
    loop
        set dx = udg_Missile_OriginX[index] - udg_Missile_ImpactX[index]
        set dy = udg_Missile_OriginY[index] - udg_Missile_ImpactY[index]
        set dx = dx*dx + dy*dy
        set dy = SquareRoot(dx)
        exitwhen dx != 0.00 and dy != 0.00// Check for parabola limits.
        set udg_Missile_OriginX[index] = udg_Missile_OriginX[index] + 0.01
    endloop    
    set udg_Missile_A_Z[index] = Missile_GetLocZ(udg_Missile_OriginX[index], udg_Missile_OriginY[index])
    set udg_Missile_B_Z[index] = Missile_GetLocZ(udg_Missile_ImpactX[index], udg_Missile_ImpactY[index]) 
    set udg_Missile_AB_Square[index] = dx
    set udg_Missile_AB_Distance[index] = dy
    set udg_Missile_AB_Angle[index] = Atan2(udg_Missile_ImpactY[index] - udg_Missile_OriginY[index], udg_Missile_ImpactX[index] - udg_Missile_OriginX[index])
    set udg_Missile_AB_Pitch[index] = ((iz + udg_Missile_B_Z[index]) - (udg_Missile_OriginZ[index] + udg_Missile_A_Z[index]))/dy
endfunction

// Doesn't include all array types. Only those which require a reset.
function Missile_ResetArrays takes integer index returns nothing
    set udg_Missile_AB_Traveled[index]  = 0.00
    set udg_Missile_Acceleration[index] = 0.00
    set udg_Missile_Arc[index]          = 0.00
    set udg_Missile_Collision[index]    = 0.00
    set udg_Missile_Curve[index]        = 0.00
    set udg_Missile_CurveX[index]       = 0.00
    set udg_Missile_CurveY[index]       = 0.00
    set udg_Missile_Damage[index]       = 0.00
    set udg_Missile_Data[index]         = 0
    set udg_Missile_Distance[index]     = 0.00
    set udg_Missile_Dummy[index]        = null
    set udg_Missile_Effect[index]       = null
    set udg_Missile_Model[index]        = null
    set udg_Missile_FlyTime[index]      = 0.00
    set udg_Missile_Height[index]       = 0.00
    set udg_Missile_OriginZ[index]      = 0.00
    set udg_Missile_ImpactZ[index]      = 0.00
    set udg_Missile_OnUnit[index]       = null
    set udg_Missile_OnDest[index]       = null
    set udg_Missile_OnPeriodic[index]   = null
    set udg_Missile_OnFinish[index]     = null
    set udg_Missile_OnRemove[index]     = null
    set udg_Missile_Open[index]         = 0.00
    set udg_Missile_Owner[index]        = null
    set udg_Missile_Recycle[index]      = false
    set udg_Missile_Scale[index]        = 1.00
    set udg_Missile_Source[index]       = null
    set udg_Missile_Speed[index]        = 0.00
    set udg_Missile_Target[index]       = null
    set udg_Missile_Turn[index]         = 0.00
    set udg_Missile_WantDestroy[index]  = false
endfunction

function Missile_SaveUserData takes integer index returns nothing
    local boolean math = false
    
    set udg_Missile_OnUnit[index]       = udg_Missile__OnCollideUnit
    set udg_Missile_OnDest[index]       = udg_Missile__OnCollideDestructable
    set udg_Missile_OnPeriodic[index]   = udg_Missile__OnPeriodic
    set udg_Missile_OnFinish[index]     = udg_Missile__OnFinish
    set udg_Missile_OnRemove[index]     = udg_Missile__OnRemove
    set udg_Missile_Source[index]       = udg_Missile__Source 
    set udg_Missile_Target[index]       = udg_Missile__Target
    set udg_Missile_Owner[index]        = udg_Missile__Owner
    set udg_Missile_Data[index]         = udg_Missile__Data
    set udg_Missile_Collision[index]    = udg_Missile__Collision
    set udg_Missile_WantDestroy[index]  = udg_Missile__WantDestroy
    set udg_Missile_Damage[index]       = udg_Missile__Damage
    set udg_Missile_Acceleration[index] = udg_Missile__Acceleration
    set udg_Missile_Turn[index]         = udg_Missile__Turn
    
    // The user set a new origin point.
    if udg_Missile__Origin != null then
        set udg_Missile_OriginX[index] = GetLocationX(udg_Missile__Origin) 
        set udg_Missile_OriginY[index] = GetLocationY(udg_Missile__Origin) 
        call RemoveLocation(udg_Missile__Origin)
        set udg_Missile__Origin = null
        set math = true
    endif
    if udg_Missile_OriginZ[index] != udg_Missile__OriginZ then
        set udg_Missile_OriginZ[index] = udg_Missile__OriginZ
        set math = true
    endif

    if udg_Missile__Impact != null then
        set udg_Missile_ImpactX[index] = GetLocationX(udg_Missile__Impact) 
        set udg_Missile_ImpactY[index] = GetLocationY(udg_Missile__Impact)
        call RemoveLocation(udg_Missile__Impact)
        set udg_Missile__Impact = null
        set math = true
    endif
    if udg_Missile_ImpactZ[index] != udg_Missile__ImpactZ then
        set udg_Missile_ImpactZ[index] = udg_Missile__ImpactZ
        set math = true
    endif
    if math then
        call Missile_Math(index)
    endif

    // The user defined a new model.
    if udg_Missile_Model[index] != udg_Missile__Model then
        set udg_Missile_Model[index] = udg_Missile__Model
        if udg_Missile_Effect[index] != null then
            call DestroyEffect(udg_Missile_Effect[index])
        endif
        if StringLength(udg_Missile__Model) > 0 then
            set udg_Missile_Effect[index] = AddSpecialEffectTarget(udg_Missile__Model, udg_Missile_Dummy[index], "origin")
        else
            set udg_Missile_Effect[index] = null
        endif
    endif
    
    // Default scaling on Missile_Create is 1.00.
    if udg_Missile_Scale[index] != udg_Missile__Scale then
        set udg_Missile_Scale[index] = udg_Missile__Scale
        call SetUnitScale(udg_Missile_Dummy[index], udg_Missile__Scale, 0.00, 0.00)
    endif
    
    if udg_Missile_Curve[index] != udg_Missile__Curve then
        set udg_Missile_Curve[index] = udg_Missile__Curve
        set udg_Missile_Open[index] = Missile_GetCurve(index)
    else
        set udg_Missile_Open[index] = udg_Missile__Open
    endif

    if udg_Missile_Arc[index] != udg_Missile__Arc then
        set udg_Missile_Arc[index] = udg_Missile__Arc
        set udg_Missile_Height[index] = Missile_GetArc(index)
    else
        set udg_Missile_Height[index] = udg_Missile__Height
    endif

    if udg_Missile_FlyTime[index] != udg_Missile__FlyTime then
        set udg_Missile_FlyTime[index] = udg_Missile__FlyTime
        set udg_Missile_Speed[index] = Missile_GetFlyTime(index)
    else
        set udg_Missile_Speed[index] = udg_Missile__Speed
    endif
endfunction

function Missile_LoadData takes integer index returns nothing
    set udg_Missile__Index                 = index

    // Load event triggers.
    set udg_Missile__OnCollideUnit         = udg_Missile_OnUnit[index]
    set udg_Missile__OnCollideDestructable = udg_Missile_OnDest[index]
    set udg_Missile__OnPeriodic            = udg_Missile_OnPeriodic[index]
    set udg_Missile__OnFinish              = udg_Missile_OnFinish[index]
    set udg_Missile__OnRemove              = udg_Missile_OnRemove[index]
    
    // Load other handle types.
    set udg_Missile__Dummy                 = udg_Missile_Dummy[index]
    set udg_Missile__Source                = udg_Missile_Source[index] 
    set udg_Missile__Target                = udg_Missile_Target[index]
    set udg_Missile__Owner                 = udg_Missile_Owner[index]
    
    set udg_Missile__Damage                = udg_Missile_Damage[index]
    set udg_Missile__Collision             = udg_Missile_Collision[index] 
    set udg_Missile__Model                 = udg_Missile_Model[index] 
    set udg_Missile__Data                  = udg_Missile_Data[index]
    set udg_Missile__Scale                 = udg_Missile_Scale[index]
    set udg_Missile__WantDestroy           = udg_Missile_WantDestroy[index]
    
    set udg_Missile__Speed                 = udg_Missile_Speed[index]
    set udg_Missile__Acceleration          = udg_Missile_Acceleration[index]
    set udg_Missile__Open                  = udg_Missile_Open[index]
    set udg_Missile__Turn                  = udg_Missile_Turn[index]
    set udg_Missile__Height                = udg_Missile_Height[index]
    set udg_Missile__Angle                 = udg_Missile_Angle[index]
    set udg_Missile__Distance              = udg_Missile_Distance[index]
    set udg_Missile__Arc                   = udg_Missile_Arc[index]
    set udg_Missile__Curve                 = udg_Missile_Curve[index]
    set udg_Missile__FlyTime               = udg_Missile_FlyTime[index]
    
    set udg_Missile__OriginZ               = udg_Missile_OriginZ[index]
    set udg_Missile__ImpactZ               = udg_Missile_ImpactZ[index]
endfunction

function Missile_ResetScalars takes nothing returns nothing
    if udg_Missile__Origin != null then
        call RemoveLocation(udg_Missile__Origin)
        set udg_Missile__Origin = null
    endif
    if udg_Missile__Impact != null then
        call RemoveLocation(udg_Missile__Origin)
        set udg_Missile__Impact = null
    endif
    set udg_Missile__WantDestroy           = false
    set udg_Missile__Recycle               = false
    set udg_Missile__OnCollideUnit         = null
    set udg_Missile__OnPeriodic            = null
    set udg_Missile__OnFinish              = null
    set udg_Missile__OnCollideDestructable = null
    set udg_Missile__OnRemove              = null
    set udg_Missile__Dummy                 = null
    set udg_Missile__Source                = null
    set udg_Missile__Target                = null
    set udg_Missile__Owner                 = null
    set udg_Missile__Model                 = null
    set udg_Missile__Angle                 = 0.00
    set udg_Missile__Collision             = 0.00
    set udg_Missile__Damage                = 0.00
    set udg_Missile__Speed                 = 0.00
    set udg_Missile__Acceleration          = 0.00
    set udg_Missile__Open                  = 0.00
    set udg_Missile__Height                = 0.00
    set udg_Missile__Turn                  = 0.00
    set udg_Missile__Distance              = 0.00
    set udg_Missile__ImpactZ               = 0.00
    set udg_Missile__OriginZ               = 0.00
    set udg_Missile__Arc                   = 0.00
    set udg_Missile__Curve                 = 0.00
    set udg_Missile__FlyTime               = 0.00
    set udg_Missile__Scale                 = 1.00
    set udg_Missile__EventId               = udg_EVENT_MISSILE_NOTHING
    set udg_Missile__Data                  = 0
    set udg_Missile__Index                 = 0
endfunction

//=============================================================
// Wrapper functions.
//=============================================================

function Missile_RunTrigger takes integer index, trigger trig, integer eventId returns boolean
    set udg_Missile__EventId = eventId
    set udg_Missile__EventIndex = index
    call Missile_LoadData(index)
    if TriggerEvaluate(trig) then
        call TriggerExecute(trig)
        call Missile_SaveUserData(index)
    endif
    // Just in case the user accidently changes udg_Missile__Index.
    set udg_Missile__EventIndex = 0
    set udg_Missile__EventId = udg_EVENT_MISSILE_NOTHING
    return udg_Missile__WantDestroy
endfunction  

//=============================================================
// Delayed dummy recycler. Data structure stack.
//=============================================================
// According to my tests:
//    - Using KillUnit(unit) will remove the 'Aloc' effect for group enumerations.
//    - Using UnitApplyTimedLife(unit, 'BTLF', 0.01) keeps on dropping the fps until you hit 0.
//
// The cleanest approach appears to be RemoveUnit(unit). Using a stack with timed dummy
// recycling helps us to properly display the attached special effects.

function Missile_UpdateStack takes nothing returns nothing
    local integer index = 0
    
    loop
        exitwhen index == udg_MissileDummyCount

        if udg_MissileDummyTime[index] <= 0 then
            call RemoveUnit(udg_MissileDummyStack[index])
            
            set udg_MissileDummyCount = udg_MissileDummyCount - 1
            if  udg_MissileDummyCount == 0 then
                set udg_MissileDummyStack[index] = null
                call PauseTimer(udg_MissileDummyTimer)
            else
                set udg_MissileDummyStack[index] = udg_MissileDummyStack[udg_MissileDummyCount]
                set udg_MissileDummyTime[index] = udg_MissileDummyTime[udg_MissileDummyCount]
                set udg_MissileDummyStack[udg_MissileDummyCount] = null
            endif
        else
            set udg_MissileDummyTime[index] = udg_MissileDummyTime[index] - 1
            set index = index + 1
        endif
    endloop
endfunction

function Missile_RecycleDummy takes unit dummy returns nothing
    if GetUnitTypeId(dummy) == udg_Missile__DummyTypeId then
        
        set udg_MissileDummyTime[udg_MissileDummyCount] = Missile_GetEffectDeathTime()// Approximate death time for special effects.
        set udg_MissileDummyStack[udg_MissileDummyCount] = dummy
        
        if udg_MissileDummyCount == 0 then
            call TimerStart(udg_MissileDummyTimer, 1., true, function Missile_UpdateStack)
        endif
        set udg_MissileDummyCount = udg_MissileDummyCount + 1
    endif
endfunction

//=============================================================
// Missile structure. Static unique doubly linked list.
//=============================================================

function Missile_SetListNextNode takes integer node, integer nextNode returns nothing
    set udg_MissileNextNode[node] = nextNode
endfunction
constant function Missile_GetListNextNode takes integer node returns integer
    return udg_MissileNextNode[node]
endfunction

function Missile_SetListPrevNode takes integer node, integer prevNode returns nothing
    set udg_MissilePrevNode[node] = prevNode
endfunction
constant function Missile_GetListPrevNode takes integer node returns integer
    return udg_MissilePrevNode[node]
endfunction

function Missile_SetListFirstNode takes integer node returns nothing
    set udg_MissileNextNode[0] = node
endfunction
constant function Missile_GetListFirstNode takes nothing returns integer
    return udg_MissileNextNode[0]
endfunction

function Missile_SetListLastNode takes integer node returns nothing
    set udg_MissilePrevNode[0] = node
endfunction
constant function Missile_GetListLastNode takes nothing returns integer
    return udg_MissilePrevNode[0]
endfunction

function Missile_ListRemoveNode takes integer node returns nothing
    call Missile_SetListNextNode(Missile_GetListPrevNode(node), Missile_GetListNextNode(node))
    call Missile_SetListPrevNode(Missile_GetListNextNode(node), Missile_GetListPrevNode(node))
endfunction

function Missile_ListPushNode takes integer node returns nothing
    call Missile_SetListPrevNode(Missile_GetListFirstNode(), node)
    call Missile_SetListNextNode(node, Missile_GetListFirstNode())
    call Missile_SetListFirstNode(node)
    call Missile_SetListPrevNode(node, 0)
endfunction

function Missile_AllocateNode takes nothing returns integer
    local integer node = udg_MissileRecycler[0]
    
    if node == 0 then
        set node = udg_MissileNodes + 1
           // Overflow
        if node == JASS_MAX_ARRAY_SIZE then
            call Missile_ErrorMessage(true, "Missile_AllocateNode", "udg_MissileNodes", JASS_MAX_ARRAY_SIZE, "Stack overflow!")
            return 0
        endif
    
        set udg_MissileNodes = node
    else
        set udg_MissileRecycler[0] = udg_MissileRecycler[node]
    endif
    
    set udg_MissileAllocated[node] = true
    
    return node
endfunction

function Missile_RecycleNode takes integer node returns nothing
    set udg_MissileAllocated[node] = false
    set udg_MissileRecycler[node] = udg_MissileRecycler[0]
    set udg_MissileRecycler[0] = node
endfunction

//=================================================================
// Destructor & Cleanup.
//=================================================================

function Missile_Clear takes integer index returns nothing
    if udg_Missile_Effect[index] != null then
        call DestroyEffect(udg_Missile_Effect[index])
    endif
    call Missile_RecycleDummy(udg_Missile_Dummy[index])
    call Missile_ResetArrays(index)
    call FlushChildHashtable(udg_MissileHash, index)
endfunction

function Missile_Destroy takes integer index returns nothing
    if udg_MissileAllocated[index] then
        if udg_MissileLaunched[index] then
            if udg_Missile_OnRemove[index] != null then
                call Missile_RunTrigger(index, udg_Missile_OnRemove[index], udg_EVENT_MISSILE_REMOVE)
            endif
            
            call Missile_ListRemoveNode(index)
            if Missile_GetListFirstNode() == 0 then
                call PauseTimer(udg_MissileTimer)
            endif
            set udg_MissileLaunched[index] = false 
        endif
        
        call Missile_Clear(index)
        call Missile_RecycleNode(index)
    else
        call Missile_ErrorMessage(true, "Missile_Destroy", "udg_MissileAllocated", index, "Attempt to destroy invalid node!")
    endif
endfunction

//=============================================================
// Widget collision code.
//=============================================================

// For a rectangle collision z values are
// very inaccurate, hence they are completly ignored.
function Missile_IsWidgetInRectangleRad takes integer index, widget w returns boolean
    local real wx = GetWidgetX(w)
    local real wy = GetWidgetY(w) 
    local real dx = udg_Missile_PosX[index] - udg_Missile_PrevX[index]
    local real dy = udg_Missile_PosY[index] - udg_Missile_PrevY[index]
    local real s  = (dx*(wx - udg_Missile_PrevX[index]) + dy*(wy - udg_Missile_PrevY[index]))/RMaxBJ(0.0001, (dx*dx + dy*dy))
    if s < 0.00 then
        set s = 0.00
    elseif s > 1.00 then
        set s = 1.00
    endif
    set dx = (udg_Missile_PrevX[index] + s*dx) - wx
    set dy = (udg_Missile_PrevY[index] + s*dy) - wy
    return dx*dx + dy*dy <= udg_Missile_Collision[index]*udg_Missile_Collision[index] 
endfunction
                                                    
function Missile_IsWidgetInRange takes integer index, widget w, real wz, real distance returns boolean
    local real wx = GetWidgetX(w)
    local real wy = GetWidgetY(w)
    local real dz = Missile_GetLocZ(wx, wy) - udg_Missile_TerrainZ[index]
    return IsUnitInRangeXY(udg_Missile_Dummy[index], wx, wy, distance) and dz + wz >= udg_Missile_PosZ[index] and dz <= udg_Missile_PosZ[index] + distance
endfunction

function Missile_SetRectRectangle takes integer index returns rect
    local real x1 = udg_Missile_PrevX[index] 
    local real y1 = udg_Missile_PrevY[index]
    local real x2 = udg_Missile_PosX[index]
    local real y2 = udg_Missile_PosY[index]
    local real d = udg_Missile_Collision[index] + Missile_GetMaxCollision()
    // What is min, what is max ...
    if x1 < x2 then
        if y1 < y2 then
            call SetRect(udg_MissileRect, x1 - d, y1 - d, x2 + d, y2 + d)
        else
            call SetRect(udg_MissileRect, x1 - d, y2 - d, x2 + d, y1 + d)
        endif
    else
        if y1 < y2 then
            call SetRect(udg_MissileRect, x2 - d, y1 - d, x1 + d, y2 + d)
        else
            call SetRect(udg_MissileRect, x2 - d, y2 - d, x1 + d, y1 + d)
        endif
    endif 
    return udg_MissileRect
endfunction

function Missile_SetRectCircle takes integer index returns rect
    local real x = udg_Missile_PosX[index]
    local real y = udg_Missile_PosY[index] 
    local real d = udg_Missile_Collision[index] + Missile_GetMaxCollision()
    call SetRect(udg_MissileRect, x - d, y - d, x + d, y + d)
    return udg_MissileRect
endfunction

function Missile_RunUnitCollision takes integer index returns nothing
    local real    size      = udg_Missile_Collision[index]
    local boolean rectangle = size < udg_Missile_Speed[index]*Missile_GetTimerTimeout()
    local real    collideZ
    local boolean hit 
    local unit    u
    
    if rectangle then
        call GroupEnumUnitsInRect(udg_MissileGroup, Missile_SetRectRectangle(index), null)
    else
        call GroupEnumUnitsInRange(udg_MissileGroup, udg_Missile_PosX[index], udg_Missile_PosY[index], size + Missile_GetMaxCollision(), null)
    endif
        
    loop
        set u = FirstOfGroup(udg_MissileGroup)
        exitwhen u == null
        call GroupRemoveUnit(udg_MissileGroup, u)
        // Chech if missile already hit this unit.
        if not HaveSavedHandle(udg_MissileHash, index, GetHandleId(u)) then
            set hit = false

            // Evaluate rectangle collision.
            if rectangle then 
                set hit = Missile_IsWidgetInRectangleRad(index, u)   
                
            // Evaluate circular collision.
            elseif IsUnitInRange(u, udg_Missile_Dummy[index], size) then
                set collideZ = Missile_GetLocZ(GetUnitX(u), GetUnitY(u)) + GetUnitFlyHeight(u) - udg_Missile_TerrainZ[index]
                set hit = (collideZ + Missile_GetUnitBodySize(u) >= udg_Missile_PosZ[index] - size) and (collideZ <= udg_Missile_PosZ[index] + size)
            endif
            
            if hit then
                call SaveUnitHandle(udg_MissileHash, index, GetHandleId(u), u)
                set udg_Missile__UnitHit = u
                if Missile_RunTrigger(index, udg_Missile_OnUnit[index], udg_EVENT_MISSILE_COLLIDE_UNIT) then
                    call Missile_Destroy(index)
                    exitwhen true
                endif
            endif
        endif
    endloop
        
    set u = null
    set udg_Missile__UnitHit = null
endfunction

function Missile_EnumDestructables takes nothing returns nothing
    local integer index = udg_Missile__Index
    local destructable d = GetEnumDestructable() 
    local boolean hit
    
    // Enum trigger action threads can't be canceled. Therefore 
    // the code must check for each trigger execution if the index is still allocated.
    if udg_MissileAllocated[index] and not HaveSavedHandle(udg_MissileHash, index, GetHandleId(d)) then
        set hit = false
            
        // Run rectangle collision.
        if udg_Missile_Collision[index] < udg_Missile_Speed[index]*Missile_GetTimerTimeout() then
            set hit = Missile_IsWidgetInRectangleRad(index, d) 
        else
            // Run circular collision.
            set hit = Missile_IsWidgetInRange(index, d, Missile_GetDestructableHeight(d), udg_Missile_Collision[index])
        endif
            
        if hit then
            call SaveDestructableHandle(udg_MissileHash, index, GetHandleId(d), d)
            set udg_Missile__DestructableHit = d
            if Missile_RunTrigger(index, udg_Missile_OnDest[index], udg_EVENT_MISSILE_COLLIDE_DEST) then
                call Missile_Destroy(index)
            endif
            set udg_Missile__DestructableHit = null
        endif
    endif
    
    set d = null
endfunction

function Missile_RunDestructableCollision takes integer index returns nothing
    set udg_Missile__Index = index
    if udg_Missile_Collision[index] < udg_Missile_Speed[index]*Missile_GetTimerTimeout() then
        call EnumDestructablesInRect(Missile_SetRectRectangle(index), null, function Missile_EnumDestructables)
    else
        call EnumDestructablesInRect(Missile_SetRectCircle(index), null, function Missile_EnumDestructables)
    endif
endfunction

//=============================================================
// Core. 
//=============================================================

function Missile_UpdatePosition takes integer index returns nothing
    local real velocity = udg_Missile_Speed[index]*Missile_GetTimerTimeout()
    local real turn     = udg_Missile_Turn[index]*Missile_GetTimerTimeout()
    local unit missile  = udg_Missile_Dummy[index]
    local real posX     = GetUnitX(missile)
    local real posY     = GetUnitY(missile)
    local real posZ     
    local real angle 
    local real point // Current point on the parabola curve.
    local real pitch
    local real square
    local real distance
    local real curveX
    local real curveY
    
    // Save previous, respectively current missile position.
    // This is required for a possible rectangle collision.
    set udg_Missile_PrevX[index] = posX
    set udg_Missile_PrevY[index] = posY
    
    // For further calculations local real velocity is used instead of speed[index]. 
    set udg_Missile_Speed[index] = udg_Missile_Speed[index] + udg_Missile_Acceleration[index]
    
    // Update missile guidance to its intended target.
    if udg_Missile_Target[index] != null then
        if GetUnitTypeId(udg_Missile_Target[index]) == 0 then
            set udg_Missile_Target[index] = null
        else
            call Missile_Math(index)
        endif
    endif
    
    // For read-abilty improvement, eventually also performance.
    set square = udg_Missile_AB_Square[index]
    set distance = udg_Missile_AB_Distance[index]
    set point = udg_Missile_AB_Traveled[index]

    // Update the missile angle dependant on the turn ratio.
    if turn != 0.00 and Cos(udg_Missile_Angle[index] - udg_Missile_AB_Angle[index]) < Cos(turn) then
        if Sin(udg_Missile_AB_Angle[index] - udg_Missile_Angle[index]) < 0.00 then
            set udg_Missile_Angle[index] = udg_Missile_Angle[index] - turn
        else
            set udg_Missile_Angle[index] = udg_Missile_Angle[index] + turn
        endif
    else
        set udg_Missile_Angle[index] = udg_Missile_AB_Angle[index]
    endif

    // Update the missile point on the parabola.
    set udg_Missile_Recycle[index] = point + velocity >= distance

    if udg_Missile_Recycle[index] then
        set udg_Missile_Distance[index] = udg_Missile_Distance[index] + distance - point
        set point = udg_Missile_AB_Distance[index]
    else
        set udg_Missile_Distance[index] = udg_Missile_Distance[index] + velocity
        set point = point + velocity
    endif
    set udg_Missile_AB_Traveled[index] = point
    
    // Set new position in plane x & y, as well as the facing angle in radians. 
    set angle = udg_Missile_Angle[index]
    set posX = posX + velocity*Cos(angle)
    set posY = posY + velocity*Sin(angle)
    
    // Update point(x/y) if a curving trajectory is defined.
    if udg_Missile_Open[index] != 0.00 then
        set velocity = 4*udg_Missile_Open[index]*point*(distance - point)/square
        set curveX   = velocity*Cos(angle + bj_PI/2) 
        set curveY   = velocity*Sin(angle + bj_PI/2) 
        set posX     = posX + velocity*Cos(angle + bj_PI/2) - udg_Missile_CurveX[index]
        set posY     = posY + velocity*Sin(angle + bj_PI/2) - udg_Missile_CurveY[index]
        set angle    = angle + Atan(-((4*udg_Missile_Open[index])*(2*point - distance))/square)
        // Save the current offset in plane x / y.
        set udg_Missile_CurveX[index] = curveX
        set udg_Missile_CurveY[index] = curveY
    endif
    
    // Update point(x,y,z) if an arc or height is defined.
    set pitch = udg_Missile_AB_Pitch[index]
    set udg_Missile_TerrainZ[index] = Missile_GetLocZ(posX, posY)
    if udg_Missile_Height[index] == 0.00 and pitch == 0.00 then
        set posZ = udg_Missile_OriginZ[index] + udg_Missile_A_Z[index] - udg_Missile_TerrainZ[index]
    else
        set posZ = udg_Missile_OriginZ[index] + udg_Missile_A_Z[index] - udg_Missile_TerrainZ[index] + pitch*point 
        set pitch = Atan(pitch)*bj_RADTODEG
        if udg_Missile_Height[index] != 0.00 then
            set posZ = posZ + 4*udg_Missile_Height[index]*point*(distance - point)/square
            set pitch = pitch - Atan(((4*udg_Missile_Height[index])*(2*point - distance))/square)*bj_RADTODEG
        endif
    endif
    // Update the pitch angle of the dummy unit. 
    if GetUnitTypeId(missile) == udg_Missile__DummyTypeId then
        call SetUnitAnimationByIndex(missile, R2I(pitch + 90.5))
    endif
    
    set udg_Missile_PosX[index] = posX
    set udg_Missile_PosY[index] = posY
    set udg_Missile_PosZ[index] = posZ
    
    // Finally update the missile dummy position and facing angle.
    call SetUnitFacing(missile, angle*bj_RADTODEG)
    call SetUnitFlyHeight(missile, posZ, 0.00)
    if posX < udg_MissileMaxX and posX > udg_MissileMinX and posY < udg_MissileMaxY and posY > udg_MissileMinY then
        call SetUnitX(missile, posX)
        call SetUnitY(missile, posY)
    endif
    
    set missile = null
endfunction

function Missile_Core takes nothing returns boolean
    local integer loops = 0   // Iteration counter.
    local integer limit = 100 // Maximum iterations per trigger evaluate.
    local integer index
    local integer next 
    loop
        exitwhen udg_Missile__Index == 0 
        exitwhen limit == loops
        
        set index = udg_Missile__Index
        set next = Missile_GetListNextNode(index)
        
        if udg_Missile_WantDestroy[index] then
            call Missile_Destroy(index) 
        else
            set udg_Missile__Index = next
            call Missile_UpdatePosition(index)
            set udg_Missile__Index = index
                
            // Run unit collision code.
            if udg_MissileAllocated[index] and udg_Missile_OnUnit[index] != null and udg_Missile_Collision[index] > 0.00 then
                call Missile_RunUnitCollision(index)
            endif

            // Run destructable collision code.
            if udg_MissileAllocated[index] and udg_Missile_OnDest[index] != null and udg_Missile_Collision[index] > 0.00 then
                call Missile_RunDestructableCollision(index)
            endif
        
            // Runs when the impact point is reached.
            if udg_MissileAllocated[index] and udg_Missile_Recycle[index] then
                if udg_Missile_OnFinish[index] != null then
                    if Missile_RunTrigger(index, udg_Missile_OnFinish[index], udg_EVENT_MISSILE_FINISH) then
                        call Missile_Destroy(index)
                    endif
                else
                    call Missile_Destroy(index)
                endif
            endif
            
            // Runs periodically every timer timeout.
            if udg_MissileAllocated[index] and udg_Missile_OnPeriodic[index] != null then 
                if Missile_RunTrigger(index, udg_Missile_OnPeriodic[index], udg_EVENT_MISSILE_PERIODIC) then
                    call Missile_Destroy(index)
                endif
            endif
        endif
        
        set loops = loops + 1
        set udg_Missile__Index = next
    endloop
    
    return udg_Missile__Index == 0
endfunction
         // Missile_GetTimerTimeout()
function Missile_OnPeriodic takes nothing returns nothing
    set udg_Missile__Index = Missile_GetListFirstNode()
    loop
        exitwhen TriggerEvaluate(udg_MissileCore) 
    endloop
    call Missile_ResetScalars()
endfunction

function Missile_InitNewMissile takes integer index returns nothing
    local real originX = GetLocationX(udg_Missile__Origin)
    local real originY = GetLocationY(udg_Missile__Origin)
    local real face    = Atan2(GetLocationY(udg_Missile__Impact) - originY, GetLocationX(udg_Missile__Impact) - originX)*bj_RADTODEG 
        
    // A user may pass his/her own units as projectile dummies.
    if udg_Missile__Dummy == null then
        set bj_lastCreatedUnit = CreateUnit(Missile_GetDummyOwner(), udg_Missile__DummyTypeId, originX, originY, face)
        set udg_Missile__Dummy = bj_lastCreatedUnit// GUI compatibility for function CreateUnitAtLocSaveLast.
        call UnitAddAbility(udg_Missile__Dummy, 'Aloc')
        call PauseUnit(udg_Missile__Dummy, true) 
    endif
    
    // Enables fly height manipulation for the dummy. 
    if UnitAddAbility(udg_Missile__Dummy, 'Amrf') and UnitRemoveAbility(udg_Missile__Dummy, 'Amrf') then
    endif
    call SetUnitFlyHeight(udg_Missile__Dummy, udg_Missile__OriginZ, 0.00)
    
    set udg_Missile_Dummy[index] = udg_Missile__Dummy
    set udg_Missile_Scale[index] = 1.00
    set udg_Missile_Angle[index] = GetUnitFacing(udg_Missile__Dummy)*bj_DEGTORAD
    
    // Prevent the missile from colliding with itself.
    call SaveUnitHandle(udg_MissileHash, index, GetHandleId(udg_Missile__Dummy), udg_Missile__Dummy)
endfunction

function Missile_BuildLocations takes nothing returns boolean
    if udg_Missile__Origin == null then
        // Build from dummy position.
        if udg_Missile__Dummy != null then
            set udg_Missile__Origin = Location(GetUnitX(udg_Missile__Dummy), GetUnitY(udg_Missile__Dummy))
        // Build from source position
        elseif udg_Missile__Source != null then
            set udg_Missile__Origin = Location(GetUnitX(udg_Missile__Source), GetUnitY(udg_Missile__Source))
        else
            call Missile_ErrorMessage(true, "Missile_BuildLocations", "Missile__Origin", udg_Missile__Index, "Missile is unable to build an origin location.
            The process requires either a target or source unit.")
            return false
        endif
    endif
    
    if udg_Missile__Impact == null then
        // Build from target position.
        if GetUnitTypeId(udg_Missile__Target) != 0 then
            set udg_Missile__Impact = Location(GetUnitX(udg_Missile__Target), GetUnitY(udg_Missile__Target))
        else
            // Build from origin using angle ( radians! ) and distance.
            set udg_Missile__Impact = PolarProjectionBJ(udg_Missile__Origin, udg_Missile__Distance, udg_Missile__Angle*bj_RADTODEG)        
        endif
    endif
    return true
endfunction

// Action function of trigger Missile.
function Missile_Launch takes nothing returns nothing
    local integer index = udg_Missile__Index 
    
    if not udg_MissileAllocated[index] or udg_MissileLaunched[index] then
        
        // This is an invalid situation caused by faulty
        // usage of the Missile API. Missile_Launch was executed
        // without a previous execution of Missile_Create.
        
        // Error identification.
        call Missile_ErrorMessage(udg_MissileLaunched[index], "Missile_Launch", "Missile_Launched", index, "Attempt to double launch a missile!
    Make sure you use Run Missile Configurate <gen> - Your missile settings - Run Missile <gen> syntax.")
    
        call Missile_ErrorMessage(not udg_MissileAllocated[index], "Missile_Launch", "Missile__Index ", index, "Attempt to launch invalid missile index!
    Make sure you use Run Missile Configurate <gen> - Your missile settings - Run Missile <gen> syntax.")

    // Check if Missile has to build an origin or impact location.
    elseif ((udg_Missile__Origin == null) or (udg_Missile__Impact == null)) and not Missile_BuildLocations() then
        call Missile_Destroy(index)
        
    else
        set udg_MissileLaunched[index] = true    
        if Missile_GetListFirstNode() == 0 then
            call TimerStart(udg_MissileTimer, Missile_GetTimerTimeout(), true, function Missile_OnPeriodic)
        endif
        call Missile_ListPushNode(index)
        call Missile_InitNewMissile(index)
        call Missile_SaveUserData(index)
    endif
    
    call Missile_ResetScalars()
    if udg_Missile__EventIndex != 0 then
        call Missile_LoadData(udg_Missile__EventIndex)
    endif
endfunction

// Action function of trigger Missile Configurate.
function Missile_Create takes nothing returns nothing
    // In most cases udg_Missile__Index is 0, thus not allocated.
    if udg_MissileAllocated[udg_Missile__Index] then
    
        // Check if Missile_Create runs from inside a Missile event trigger.
        if udg_Missile__EventIndex == udg_Missile__Index then
            // Save all data from scalar to array variables.
            call Missile_SaveUserData(udg_Missile__EventIndex)
    
        elseif not udg_MissileLaunched[udg_Missile__Index] then
                    
            // This is an invalid situation caused by faulty
            // usage of the Missile API. Missile_Create was executed twice
            // without launching the previously created index.
            // Missile compensates for that error by destroying
            // the forgotten index.
            call Missile_Destroy(udg_Missile__Index)
            
            // Print it for the user.
            call Missile_ErrorMessage(true, "Missile_Create", "Missile_Launched", udg_Missile__Index, "You forgot to launch the previous created missile!
    Make sure you use Run Missile Configurate <gen> - Your missile settings - Run Missile <gen> syntax.")
        
        endif
    endif
    
    call Missile_ResetScalars()
    set udg_Missile__Index = Missile_AllocateNode()
endfunction

//===========================================================================
function InitTrig_Missile takes nothing returns nothing
    if gg_trg_Missile != null then
        return// Missile has already been initialized.
    endif
    
    set udg_MissileHash = InitHashtable()
    set udg_MissileCore = CreateTrigger()
    set udg_MissileRect = GetWorldBounds()
    set udg_MissileLocZ = Location(0.00, 0.00)
    
    // It's necessary to prevent missiles, units in general, from leaving map boundaries.
    set udg_MissileMaxX = R2I(GetRectMaxX(udg_MissileRect)) - 197
    set udg_MissileMaxY = R2I(GetRectMaxY(udg_MissileRect)) - 197
    set udg_MissileMinX = R2I(GetRectMinX(udg_MissileRect)) + 197
    set udg_MissileMinY = R2I(GetRectMinY(udg_MissileRect)) + 197
    
    // Trigger that controlls the trajectory of all missiles.
    call TriggerAddCondition(udg_MissileCore, Condition(function Missile_Core))
    
    // Run the configuration trigger before the first missile is created.
    call TriggerExecute(gg_trg_Missile_Configurate)
    call TriggerClearActions(gg_trg_Missile_Configurate)
    call DestroyTrigger(gg_trg_Missile_Configurate)
    
    // Transform the configurate trigger into the index allocator.
    set gg_trg_Missile_Configurate = CreateTrigger()
    call TriggerAddAction(gg_trg_Missile_Configurate, function Missile_Create)
    
    // Build the launching trigger for missiles.
    set gg_trg_Missile = CreateTrigger()
    call TriggerAddAction(gg_trg_Missile, function Missile_Launch)

    // Set the missile system ready.
    call Missile_ResetScalars()
endfunction