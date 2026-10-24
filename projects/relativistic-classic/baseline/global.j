library TimerUtils initializer init
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
    globals
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
        private constant boolean USE_HASH_TABLE      = true
        private constant boolean USE_FLEXIBLE_OFFSET = false

        private constant integer OFFSET     = 0x100000
        private          integer VOFFSET    = OFFSET
              
        //Timers to preload at map init:
        private constant integer QUANTITY   = 256
        
        //Changing this  to something big will allow you to keep recycling
        // timers even when there are already AN INCREDIBLE AMOUNT of timers in
        // the stack. But it will make things far slower so that's probably a bad idea...
        private constant integer ARRAY_SIZE = 8190

    endglobals

    //==================================================================================================
    globals
        private integer array data[ARRAY_SIZE]
        private hashtable     ht
    endglobals
    
    

    //It is dependent on jasshelper's recent inlining optimization in order to perform correctly.
    function SetTimerData takes timer t, integer value returns nothing
        static if(USE_HASH_TABLE) then
            // new blue
            call SaveInteger(ht,0,GetHandleId(t), value)
            
        elseif (USE_FLEXIBLE_OFFSET) then
            // orange
            static if (DEBUG_MODE) then
                if(GetHandleId(t)-VOFFSET<0) then
                    call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
                endif
            endif
            set data[GetHandleId(t)-VOFFSET]=value
        else
            // new red
            static if (DEBUG_MODE) then
                if(GetHandleId(t)-OFFSET<0) then
                    call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
                endif
            endif
            set data[GetHandleId(t)-OFFSET]=value
        endif        
    endfunction

    function GetTimerData takes timer t returns integer
        static if(USE_HASH_TABLE) then
            // new blue
            return LoadInteger(ht,0,GetHandleId(t) )
            
        elseif (USE_FLEXIBLE_OFFSET) then
            // orange
            static if (DEBUG_MODE) then
                if(GetHandleId(t)-VOFFSET<0) then
                    call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
                endif
            endif
            return data[GetHandleId(t)-VOFFSET]
        else
            // new red
            static if (DEBUG_MODE) then
                if(GetHandleId(t)-OFFSET<0) then
                    call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
                endif
            endif
            return data[GetHandleId(t)-OFFSET]
        endif        
    endfunction

    //==========================================================================================
    globals
        private timer array tT[ARRAY_SIZE]
        private integer tN = 0
        private constant integer HELD=0x28829022
        //use a totally random number here, the more improbable someone uses it, the better.
        
        private boolean       didinit = false
    endglobals
    private keyword init

    //==========================================================================================
    // I needed to decide between duplicating code ignoring the "Once and only once" rule
    // and using the ugly textmacros. I guess textmacros won.
    //
    //! textmacro TIMERUTIS_PRIVATE_NewTimerCommon takes VALUE
    // On second thought, no.
    //! endtextmacro

    function NewTimerEx takes integer value returns timer
        if (tN==0) then
            if (not didinit) then 
                //This extra if shouldn't represent a major performance drawback
                //because QUANTITY rule is not supposed to be broken every day. 
                call init.evaluate()
                set tN = tN - 1
            else
                //If this happens then the QUANTITY rule has already been broken, try to fix the
                // issue, else fail.
                debug call BJDebugMsg("NewTimer: Warning, Exceeding TimerUtils_QUANTITY, make sure all timers are getting recycled correctly")
                set tT[0]=CreateTimer()
                static if( not USE_HASH_TABLE) then
                    debug call BJDebugMsg("In case of errors, please increase it accordingly, or set TimerUtils_USE_HASH_TABLE to true")
                    static if( USE_FLEXIBLE_OFFSET) then
                        if (GetHandleId(tT[0])-VOFFSET<0) or (GetHandleId(tT[0])-VOFFSET>=ARRAY_SIZE) then
                            //all right, couldn't fix it
                            call BJDebugMsg("NewTimer: Unable to allocate a timer, you should probably set TimerUtils_USE_HASH_TABLE to true or fix timer leaks.")
                            return null
                        endif
                    else
                        if (GetHandleId(tT[0])-OFFSET<0) or (GetHandleId(tT[0])-OFFSET>=ARRAY_SIZE) then
                            //all right, couldn't fix it
                            call BJDebugMsg("NewTimer: Unable to allocate a timer, you should probably set TimerUtils_USE_HASH_TABLE to true or fix timer leaks.")
                            return null
                        endif
                    endif
                endif
            endif
        else
            set tN=tN-1
        endif
        call SetTimerData(tT[tN],value)
     return tT[tN]
    endfunction
    
    function NewTimer takes nothing returns timer
        return NewTimerEx(0)
    endfunction


    //==========================================================================================
    function ReleaseTimer takes timer t returns nothing
        if(t==null) then
            debug call BJDebugMsg("Warning: attempt to release a null timer")
            return
        endif
        if (tN==ARRAY_SIZE) then
            debug call BJDebugMsg("Warning: Timer stack is full, destroying timer!!")

            //stack is full, the map already has much more troubles than the chance of bug
            call DestroyTimer(t)
        else
            call PauseTimer(t)
            if(GetTimerData(t)==HELD) then
                debug call BJDebugMsg("Warning: ReleaseTimer: Double free!")
                return
            endif
            call SetTimerData(t,HELD)
            set tT[tN]=t
            set tN=tN+1
        endif    
    endfunction

    private function init takes nothing returns nothing
     local integer i=0
     local integer o=-1
     local boolean oops = false
        if ( didinit ) then
            return
        else
            set didinit = true
        endif
     
        static if( USE_HASH_TABLE ) then
            set ht = InitHashtable()
            loop
                exitwhen(i==QUANTITY)
                set tT[i]=CreateTimer()
                call SetTimerData(tT[i], HELD)
                set i=i+1
            endloop
            set tN = QUANTITY
        else
            loop
                set i=0
                loop
                    exitwhen (i==QUANTITY)
                    set tT[i] = CreateTimer()
                    if(i==0) then
                        set VOFFSET = GetHandleId(tT[i])
                        static if(USE_FLEXIBLE_OFFSET) then
                            set o=VOFFSET
                        else
                            set o=OFFSET
                        endif
                    endif
                    if (GetHandleId(tT[i])-o>=ARRAY_SIZE) then
                        exitwhen true
                    endif
                    if (GetHandleId(tT[i])-o>=0)  then
                        set i=i+1
                    endif
                endloop
                set tN = i
                exitwhen(tN == QUANTITY)
                set oops = true
                exitwhen not USE_FLEXIBLE_OFFSET
                debug call BJDebugMsg("TimerUtils_init: Failed a initialization attempt, will try again")               
            endloop
            
            if(oops) then
                static if ( USE_FLEXIBLE_OFFSET) then
                    debug call BJDebugMsg("The problem has been fixed.")
                    //If this message doesn't appear then there is so much
                    //handle id fragmentation that it was impossible to preload
                    //so many timers and the thread crashed! Therefore this
                    //debug message is useful.
                elseif(DEBUG_MODE) then
                    call BJDebugMsg("There were problems and the new timer limit is "+I2S(i))
                    call BJDebugMsg("This is a rare ocurrence, if the timer limit is too low:")
                    call BJDebugMsg("a) Change USE_FLEXIBLE_OFFSET to true (reduces performance a little)")
                    call BJDebugMsg("b) or try changing OFFSET to "+I2S(VOFFSET) )
                endif
            endif
        endif

    endfunction

endlibrary


library WorldBounds /* v2.0.0.0
************************************************************************************
*
*	struct WorldBounds extends array
*
*	Fields
*	-------------------------
*
*	readonly static integer maxX
*	readonly static integer maxY
*	readonly static integer minX
*	readonly static integer minY
*
*	readonly static integer centerX
*	readonly static integer centerY
*
*	readonly static rect world
*	readonly static region worldRegion
*
************************************************************************************/
private module WorldBoundInit

    private static method onInit takes nothing returns nothing
        set world = GetWorldBounds()
        set maxX = R2I(GetRectMaxX(world))
        set maxY = R2I(GetRectMaxY(world))
        set minX = R2I(GetRectMinX(world))
        set minY = R2I(GetRectMinY(world))
        set centerX = R2I((maxX + minX)/2)
        set centerY = R2I((minY + maxY)/2)
        set playMaxX = GetRectMaxX(bj_mapInitialPlayableArea)
        set playMaxY = GetRectMaxY(bj_mapInitialPlayableArea)
        set playMinX = GetRectMinX(bj_mapInitialPlayableArea)
        set playMinY = GetRectMinY(bj_mapInitialPlayableArea)
        set worldRegion = CreateRegion()
        call RegionAddRect(worldRegion, world)
        endmethod
    endmodule
    
    struct WorldBounds extends array
        readonly static integer maxX
        readonly static integer maxY
        readonly static integer minX
        readonly static integer minY
        readonly static integer centerX
        readonly static integer centerY
        readonly static rect world
        readonly static region worldRegion
        readonly static real playMaxX
        readonly static real playMaxY
        readonly static real playMinX
        readonly static real playMinY
        implement WorldBoundInit
    endstruct
    
endlibrary

library DummyRecycler /*
 
//                      DummyRecycler v1.25
//                          by Flux
//
//  A system that recycles dummy units while considering their facing angle.
//  It can be used as attachment dummies for visual effects or as dummy caster.
//
//  Why is recycling a unit important?
//      Because creating a unit is is one of the slowest function in the game
//      and there are reports that will always leave a permanent tiny bit of
//      memory (0.04 KB).
//      On average, retrieving a pending Dummy is approximately 4x faster compared
//      to creating a new one and recycling a Dummy compared to removing it is
//      approximately 1.3x faster.
//      Furthermore, if you're using a lot of "Unit has entered map" events,
//      using this system will even result to even more better performance
//      because retrieving Dummy units does not cause that event to run.


    */ requires /*
       nothing
     
    */ optional Table/*
        if not found, this system will use a hashtable. Hashtables are limited to
        255 per map.
     
    */ optional WorldBounds /*
        if not found, this system will initialize its own Map Boundaries.
//
//
//  Features:
//
//    -- Dummy Sharing
//        When a Dummy List gets low on unit count, it will borrow Dummy Units
//        from the Dummy List with the highest unit count. The transfer is not
//        instant because the shared Dummy Unit has to turn to the appropriate
//        angle of its new Dummy List before it can be recycled.
//        See BORROW_REQUEST.
//
//    -- Self-balancing recycling algorithm
//        Recycled Dummy Units will be thrown to the List having the least number
//        of Dummy Units.
//
//    -- Recycling least used
//        Allows recycling a Dummy from the Dummy List with the highest
//        unit count. It is useful when the facing angle of the Dummy Unit
//        does not matter.
//        See GetRecycledDummyAnyAngle.
//
//    -- Self-adaptation
//        When there are no free Dummy Units from a Dummy List, it will end up creating
//        a new unit instead but that unit will be permanently added as a Dummy
//        Unit to be recycled increasing the overall total Dummy Unit count.
//
//    -- Count control
//        Allows limiting the overall number of Dummy Units.
//        See MAX_DUMMY_COUNT.
//
//    -- Delayed Recycle
//        Allows recycling Dummy Units after some delay to allocate time for the
//        death animation of Special Effects to be seen.
//        See DummyAddRecycleTimer.
//
// ******************************************************************
// ***************************** API: *******************************
// ******************************************************************
//
//  function GetRecycledDummy takes real x, real y, real z, real facing returns unit
//      - Retrieve an unused Dummy Unit from the List.
//      - The equivalent of CreateUnit.
//      - To use as a Dummy Caster, follow it with PauseUnit(dummy, false).
//
//  function GetRecycledDummyAnyAngle takes real x, real y, real z returns unit
//      - Use this function if the facing angle of the Dummy doesn't matter to you.
//      - It will return a unit from the list having the highest number of unused Dummy Units.
//      - To use as a Dummy Caster, follow it with PauseUnit(dummy, false).
//
//  function RecycleDummy takes unit u returns nothing
//      - Recycle the Dummy unit for it to be used again later.
//      - The equivalent of RemoveUnit.
//
//  function DummyAddRecycleTimer takes unit u, real time returns nothing
//      - Recycle the Dummy unit after a certain time.
//      - Use this to allocate time for the the death animation of an effect attached to the
//        Dummy Unit to finish..
//      - The equivalent of UnitApplyTimedLife.
//
//  function ShowDummy takes unit u, boolean flag returns nothing
//      - Shows/hides Dummy Unit without conflicting with the Locust ability.
//
//--------------------
//      CREDITS
//--------------------
//  Bribe - for the MissileRecycler (vJASS) where I got this concept from
//       http://www.hiveworkshop.com/forums/jass-resources-412/system-missilerecycler-206086/
//        - for the optional Table
//       http://www.hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
//  Vexorian - for the Attachable and Pitch Animation Model (dummy.mdx)
//       http://www.wc3c.net/showthread.php?t=101150
//  Maker and IcemanBo - for the unit permanent 0.04 KB memory leak of units.
//       http://www.hiveworkshop.com/forums/trigger-gui-editor-tutorials-279/memory-leaks-263410/
//  Nestharus - for the data structure
//       http://www.hiveworkshop.com/forums/2809461-post7.html
//            - for the optional WorldBounds
//       http://githubusercontent.com/nestharus/JASS/master/jass/Systems/WorldBounds/script.j

// =============================================================== //
// ====================== CONFIGURATION ========================== //
// =============================================================== */

    globals
        //The rawcode of the Dummy Unit
        private constant integer DUMMY_ID = 'e000'
     
        //The owner of the Dummy Unit
        private constant player OWNER = Player(PLAYER_NEUTRAL_PASSIVE)
     
        //The number of indexed angle. The higher the value the:
        // - Lesser the turning time for the Dummy Units.
        // - Higher the total number of Dummy Units created at Map Initialization.
        //          Recommended Value: 10 (Max difference of 18 degrees)
        private constant integer ANGLES_COUNT = 10
     
        //The number of Dummy units per ANGLES_COUNT. The higher the value the:
        // - Higher the number of units that can be recycled per angle, when
        //   no more units are in queue, the system will resort to use CreateUnit.
        // - Higher the total number of Dummy Units created at Map Initialization.
        //    Recommended Value: 3 to 5 (for less overhead in Map Loading Screen)
        private constant integer STORED_UNIT_COUNT = 3
     
        //The maximum number of Dummy units that can exist. When the system resort
        //to using CreateUnit, the unit will be permanently added to the Dummy
        //List. To avoid spamming Dummy Units and having too much free Dummy
        //Units to allocate, the maximum number of Dummy Units is capped.
        //               Recommended Value: 80 to 120
        private constant integer MAX_DUMMY_COUNT = 100
     
        //When a certain angle have less than BORROW_REQUEST units in its list,
        //it will start to borrow Dummy Units from the list with the highest
        //Dummy Unit count.
        //      Recommended Value: Half of maximum STORED_UNIT_COUNT
        private constant integer BORROW_REQUEST = 5
     
        //It will only return a Dummy if the current dummy is close
        //to it's appropriate facing angle. This is to avoid returning
        //a Dummy which is still turning to face it's list angle.
        private constant real ANGLE_TOLERANCE = 10.0
     
        //An additional option to automatically hide recycled dummy units in the
        //corner of the map camera bounds
        private constant boolean HIDE_ON_MAP_CORNER = true
    endglobals
 
    //Every time a new dummy unit is retrieved, it will apply this resets
    //If it is redundant/you dont need it, remove it.
    //! textmacro DUMMY_UNIT_RESET
        call SetUnitScale(bj_lastCreatedUnit, 1, 0, 0)
        call SetUnitVertexColor(bj_lastCreatedUnit, 255, 255, 255, 255)
        call SetUnitAnimationByIndex(bj_lastCreatedUnit, 90)
        call ShowDummy(bj_lastCreatedUnit, true)
    //! endtextmacro
// =============================================================== //
// ==================== END CONFIGURATION ======================== //
// =============================================================== //
 
 
    globals
        private integer dummyCount = ANGLES_COUNT*STORED_UNIT_COUNT
        private real array angle
        private integer array count
        private integer array countHead
        private integer array countNext
        private integer array countPrev
        private integer array next
        private integer array prev
        private unit array dummy
        private integer upper
        private integer lower
        private integer lastInstance
        private constant real FACING_OFFSET = 180.0/ANGLES_COUNT
    endglobals
 
    static if HIDE_ON_MAP_CORNER and not LIBRARY_WorldBounds then
        private module BoundsInit
     
            readonly static real x
            readonly static real y
         
            private static method onInit takes nothing returns nothing
                local rect map = GetWorldBounds()
                set thistype.x = GetRectMaxX(map)
                set thistype.y = GetRectMaxY(map)
                call RemoveRect(map)
                set map = null
            endmethod
         
        endmodule
     
        private struct Bounds extends array
            implement BoundsInit
        endstruct
    endif
 
    private module M
     
        static if false then
            static Table tb
        else
            static hashtable hash = InitHashtable()
        endif
     
        private static method onInit takes nothing returns nothing
            local real add = 360.0/ANGLES_COUNT
            local real a = 0
            local integer this = ANGLES_COUNT
            local integer head = 0
            local integer cHead = JASS_MAX_ARRAY_SIZE - 1   //avoid allocation collision
            local integer i = R2I(MAX_DUMMY_COUNT/ANGLES_COUNT + 0.5)
            set upper = STORED_UNIT_COUNT
            set lower = STORED_UNIT_COUNT
            static if false then
                set tb = Table.create()
            endif
            //Initialize countHeads
            loop
                exitwhen i < 0
                set countNext[cHead] = cHead
                set countPrev[cHead] = cHead
                set countHead[i] = cHead
                set cHead = cHead - 1
                set i = i - 1
            endloop
            set cHead = countHead[STORED_UNIT_COUNT]  //All heads will be inserted here initially
            //Create the Dummy units
            loop
                exitwhen a >= 360
                //Initialize head
                set next[head] = head
                set prev[head] = head
                set count[head] = STORED_UNIT_COUNT
                set angle[head] = a
                //Insert head in the Count List
                set countNext[head] = cHead
                set countPrev[head] = countPrev[cHead]
                set countNext[countPrev[head]] = head
                set countPrev[countNext[head]] = head
                set i = 0
                loop
                    exitwhen i >= STORED_UNIT_COUNT
                    //Queued Linked List
                    set next[this] = head
                    set prev[this] = prev[head]
                    set next[prev[this]] = this
                    set prev[next[this]] = this
                    static if HIDE_ON_MAP_CORNER then
                        static if LIBRARY_WorldBounds then
                            set dummy[this] = CreateUnit(OWNER, DUMMY_ID, WorldBounds.maxX, WorldBounds.maxY, a)
                        else
                            set dummy[this] = CreateUnit(OWNER, DUMMY_ID, Bounds.x, Bounds.y, a)
                        endif
                    else
                        set dummy[this] = CreateUnit(OWNER, DUMMY_ID, 0, 0, a)
                    endif
                    call PauseUnit(dummy[this], true)
                    static if false then
                        set tb[GetHandleId(dummy[this])] = this
                    else
                        call SaveInteger(hash, GetHandleId(dummy[this]), 0, this)
                    endif
                    set this = this + 1
                    set i = i + 1
                endloop
                set head = head + 1
                set a = a + add
            endloop
            set lastInstance = this
        endmethod
     
    endmodule
 
    private struct S extends array
        implement M
    endstruct
 
    private function GetHead takes integer facing returns integer
        if facing < 0 or facing >= 360 then
            set facing = facing - (facing/360)*360
            if facing < 0 then
                set facing = facing + 360
            endif
        endif
        return R2I((facing*ANGLES_COUNT/360.0))
    endfunction
 
    function ShowDummy takes unit u, boolean flag returns nothing
        if IsUnitHidden(u) == flag then
            call ShowUnit(u, flag)
            if flag and GetUnitTypeId(u) == DUMMY_ID then
                call UnitRemoveAbility(u, 'Aloc')
                call UnitAddAbility(u, 'Aloc')
            endif
        endif
    endfunction
 
    function GetRecycledDummy takes real x, real y, real z, real facing returns unit
        local integer head = GetHead(R2I(facing + FACING_OFFSET))
        local integer this = next[head]
        local integer cHead
     
        //If there are Dummy Units in the Queue List already facing close to the appropriate angle
        if this != head and RAbsBJ(GetUnitFacing(dummy[this]) - angle[head]) <= ANGLE_TOLERANCE then
            //Remove from the Queue List
            set next[prev[this]] = next[this]
            set prev[next[this]] = prev[this]
            //For double free protection
            set next[this] = -1
            //Unit Properties
            set bj_lastCreatedUnit = dummy[this]
            call SetUnitX(bj_lastCreatedUnit, x)
            call SetUnitY(bj_lastCreatedUnit, y)
            call SetUnitFacing(bj_lastCreatedUnit, facing)
            call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0)
            //! runtextmacro DUMMY_UNIT_RESET()
            //Update Count and Bounds
            set count[head] = count[head] - 1
         
            //------------------------------------------------
            //                 Unit Sharing
            //------------------------------------------------
            if count[head] < BORROW_REQUEST and count[countNext[countHead[upper]]] > count[head] then
                set count[head] = count[head] + 1
                set this = next[countNext[countHead[upper]]]
                call SetUnitFacing(dummy[this], angle[head])
                //Remove
                set next[prev[this]] = next[this]
                set prev[next[this]] = prev[this]
                //Add to the Current List
                set next[this] = head
                set prev[this] = prev[head]
                set next[prev[this]] = this
                set prev[next[this]] = this
                set head = countNext[countHead[upper]]
                set count[head] = count[head] - 1
            endif
         
            //---------------------------
            //Update Count Lists
            //---------------------------
            //Remove from the current Count List
            set countNext[countPrev[head]] = countNext[head]
            set countPrev[countNext[head]] = countPrev[head]
            //Add to the new Count List
            set cHead = countHead[count[head]]
            set countNext[head] = cHead
            set countPrev[head] = countPrev[cHead]
            set countNext[countPrev[head]] = head
            set countPrev[countNext[head]] = head
         
            //---------------------------
            //  Update Bounds
            //---------------------------
            set cHead = countHead[upper]
            if countNext[cHead] == cHead then
                set upper = upper - 1
            endif
            if count[head] < lower then
                set lower = count[head]
            endif
        else
            set bj_lastCreatedUnit = CreateUnit(OWNER, DUMMY_ID, x, y, facing)
            call PauseUnit(bj_lastCreatedUnit, true)
            call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0)
            if dummyCount < MAX_DUMMY_COUNT then
                set this = lastInstance
                //For double free protection
                set next[this] = -1
                set dummy[this] = bj_lastCreatedUnit
                static if false then
                    set S.tb[GetHandleId(bj_lastCreatedUnit)] = this
                else
                    call SaveInteger(S.hash, GetHandleId(bj_lastCreatedUnit), 0, this)
                endif
                set lastInstance = lastInstance + 1
            endif
            set dummyCount = dummyCount + 1
        endif

        return bj_lastCreatedUnit
    endfunction
 
    function RecycleDummy takes unit u returns nothing
        static if false then
            local integer this = S.tb[GetHandleId(u)]
        else
            local integer this = LoadInteger(S.hash, GetHandleId(u), 0)
        endif
        local integer head
        local integer cHead
     
        //If the unit is a legit Dummy Unit
        if this > 0 and next[this] == -1 then
            //Find where to insert based on the list having the least number of units
            set head = countNext[countHead[lower]]
            set next[this] = head
            set prev[this] = prev[head]
            set next[prev[this]] = this
            set prev[next[this]] = this
            //Update Status
            call SetUnitFacing(u, angle[head])
            call PauseUnit(u, true)
            call SetUnitOwner(u, OWNER, false)
            static if HIDE_ON_MAP_CORNER then
                static if LIBRARY_WorldBounds then
                    call SetUnitX(u, WorldBounds.maxX)
                    call SetUnitY(u, WorldBounds.maxY)
                else
                    call SetUnitX(u, Bounds.x)
                    call SetUnitY(u, Bounds.y)
                endif
            else
                call SetUnitScale(u, 0, 0, 0)
                call SetUnitVertexColor(u, 0, 0, 0, 0)
            endif
            set count[head] = count[head] + 1
         
            //---------------------------
            //    Update Count Lists
            //---------------------------
            //Remove
            set countNext[countPrev[head]] = countNext[head]
            set countPrev[countNext[head]] = countPrev[head]
            //Add to the new Count List
            set cHead = countHead[count[head]]
            set countNext[head] = cHead
            set countPrev[head] = countPrev[cHead]
            set countNext[countPrev[head]] = head
            set countPrev[countNext[head]] = head
         
            //---------------------------
            //  Update Bounds
            //---------------------------
            set cHead = countHead[lower]
            if countNext[cHead] == cHead then
                set lower = lower + 1
            endif
            if count[head] > upper then
                set upper = count[head]
            endif
        elseif this == 0 then
            call RemoveUnit(u)
        debug elseif next[this] != -1 then
            debug call BJDebugMsg("|cffffcc00[DummyRecycler]:|r Attempted to recycle a pending/free Dummy Unit.")
        endif
     
    endfunction
 
    private function Expires takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer id = GetHandleId(t)
        static if false then
            call RecycleDummy(S.tb.unit[id])
            call S.tb.unit.remove(id)
        else
            call RecycleDummy(LoadUnitHandle(S.hash, id, 0))
            call FlushChildHashtable(S.hash, id)
        endif
        call DestroyTimer(t)
        set t = null
    endfunction

    function DummyAddRecycleTimer takes unit u, real time returns nothing
        local timer t = CreateTimer()
        static if false then
            set S.tb.unit[GetHandleId(t)] = u
        else
            call SaveUnitHandle(S.hash, GetHandleId(t), 0, u)
        endif
        call TimerStart(t, time, false, function Expires)
        set t = null
    endfunction
 
    function GetRecycledDummyAnyAngle takes real x, real y, real z returns unit
        return GetRecycledDummy(x, y, z, angle[countNext[countHead[upper]]])
    endfunction
 
    // runtextmacro DUMMY_DEBUG_TOOLS()
 
endlibrary

library Missiles requires WorldBounds, TimerUtils optional DummyRecycler
    /* ----------------------- Missiles v2.8 by Chopinski ----------------------- */
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
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The update period of the system
        public  constant real    PERIOD             = 1./40.
        // The max amount of Missiles processed in a PERIOD
        // You can play around with both these values to find
        // your sweet spot. If equal to 0, the system will
        // process all missiles at once every period.
        public  constant real    SWEET_SPOT         = 150
        // the avarage collision size compensation when detecting
        // collisions
        private constant real    COLLISION_SIZE     = 128.
        // item size used in z collision
        private constant real    ITEM_SIZE          = 16.
        // The raw code of the dummy unit.
        private constant integer DUMMY              = 'e000'
        // How long takes for the missile to be removed.
        // This is necessary so the death animation of the
        // effect can play through
        private constant real    RECYCLE_TIME       = 2.
        // Needed, don't touch.
        private location         LOC                = Location(0., 0.)
        private hashtable        table              = InitHashtable()
    endglobals

    private interface MissileEvents
        method onHit takes unit hit returns boolean defaults false
        method onMissile takes Missiles missile returns boolean defaults false
        method onDestructable takes destructable dest returns boolean defaults false
        method onItem takes item i returns boolean defaults false
        method onCliff takes nothing returns boolean defaults false
        method onTerrain takes nothing returns boolean defaults false
        method onTileset takes integer tileset returns boolean defaults false
        method onPeriod takes nothing returns boolean defaults false
        method onFinish takes nothing returns boolean defaults false
        method onBoundaries takes nothing returns boolean defaults false
        method onPause takes nothing returns boolean defaults false
        method onResume takes nothing returns boolean defaults false
        method onRemove takes nothing returns nothing defaults nothing
    endinterface
    
    private function GetLocZ takes real x, real y returns real
        call MoveLocation(LOC, x, y)
        return GetLocationZ(LOC)
    endfunction

    private constant function GetUnitCollisionSize takes unit u returns real
        return 64.
    endfunction
    
    private function GetMapCliffLevel takes nothing returns integer
        return GetTerrainCliffLevel(WorldBounds.maxX, WorldBounds.maxY)
    endfunction
    
    private function GetUnitZ takes unit u returns real
        return GetLocZ(GetUnitX(u), GetUnitY(u)) + GetUnitFlyHeight(u)
    endfunction
    
    private function SetUnitZ takes unit u, real z returns nothing
        call SetUnitFlyHeight(u, z - GetLocZ(GetUnitX(u), GetUnitY(u)), 0)
    endfunction

    private struct Pool
        private static player player = Player(PLAYER_NEUTRAL_PASSIVE)
    
        timer timer
        unit  unit
        
        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call ReleaseTimer(timer)
            call RemoveUnit(unit)
            call deallocate()
            
            set timer = null
            set unit = null
        endmethod

        static method recycle takes unit dummy, real delay returns nothing
            local thistype this

            if GetUnitTypeId(dummy) != DUMMY then
                debug call BJDebugMsg("[DummyPool] Error: Trying to recycle a non dummy unit")
            else
                set this = thistype.allocate()
                set timer = NewTimerEx(this)
                set unit = dummy
                
                call TimerStart(timer, delay, false, function thistype.onExpire)
            endif
        endmethod
        
        static method retrieve takes real x, real y, real z, real face returns unit
            set bj_lastCreatedUnit = CreateUnit(player, DUMMY, x, y, face)
            call SetUnitZ(bj_lastCreatedUnit, z)
            call UnitRemoveAbility(bj_lastCreatedUnit, 'Amrf')

            return bj_lastCreatedUnit
        endmethod
    endstruct

    private struct Coordinates
        readonly real x
        readonly real y
        readonly real z
        readonly real angle
        readonly real distance
        readonly real square
        readonly real slope
        readonly real alpha

        // Creates an origin - impact link.
        private thistype ref

        private static method math takes thistype a, thistype b returns nothing
            local real dx
            local real dy
            loop
                set dx = b.x - a.x
                set dy = b.y - a.y
                set dx = dx*dx + dy*dy
                set dy = SquareRoot(dx)
                exitwhen dx != 0. and dy != 0.
                set b.x = b.x + .01
                set b.z = b.z - GetLocZ(b.x -.01, b.y) + GetLocZ(b.x, b.y)
            endloop

            set a.square   = dx
            set a.distance = dy
            set a.angle    = Atan2(b.y - a.y, b.x - a.x)
            set a.slope    = (b.z - a.z)/dy
            set a.alpha    = Atan(a.slope)*bj_RADTODEG
            // Set b.
            if b.ref == a then
                set b.angle     = a.angle + bj_PI
                set b.distance  = dy
                set b.slope     = -a.slope
                set b.alpha     = -a.alpha
                set b.square    = dx
            endif
        endmethod

        static method link takes thistype a, thistype b returns nothing
            set a.ref = b
            set b.ref = a
            call math(a, b)
        endmethod

        method move takes real toX, real toY, real toZ returns nothing
            set x = toX
            set y = toY
            set z = toZ + GetLocZ(toX, toY)
            if ref != this then
                call math(this, ref)
            endif
        endmethod

        method destroy takes nothing returns nothing
            call .deallocate()
        endmethod

        static method create takes real x, real y, real z returns Coordinates
            local thistype this = thistype.allocate()
            set ref = this
            call move(x, y, z)
            return this
        endmethod
    endstruct
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private module OnHit
        set o = origin
        set h = height
        set c = open
        set d = o.distance
        
        if .onHit.exists then
            if allocated and collision > 0 then
                call GroupEnumUnitsInRange(group, x, y, collision + COLLISION_SIZE, null)
                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if not HaveSavedBoolean(table, this, GetHandleId(u)) then
                            if IsUnitInRangeXY(u, x, y, collision) then
                                if collideZ then
                                    set dx = GetLocZ(GetUnitX(u), GetUnitY(u)) + GetUnitFlyHeight(u)
                                    set dy = GetUnitCollisionSize(u)
                                    if dx + dy >= z - collision and dx <= z + collision then
                                        call SaveBoolean(table, this, GetHandleId(u), true)
                                        if allocated and .onHit(u) then
                                            call terminate()
                                            exitwhen true
                                        endif
                                    endif
                                else
                                    call SaveBoolean(table, this, GetHandleId(u), true)
                                    if allocated and .onHit(u) then
                                        call terminate()
                                        exitwhen true
                                    endif
                                endif
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            endif
        endif
    endmodule
  
    private module OnMissile
        if .onMissile.exists then
            if allocated and collision > 0 then
                set k = 0
                loop
                    exitwhen k > count
                        set missile = collection[k]
                        if missile != this then
                            if not HaveSavedBoolean(table, this, missile) then
                                set dx = missile.x - x
                                set dy = missile.y - y
                                if SquareRoot(dx*dx + dy*dy) <= collision then
                                    call SaveBoolean(table, this, missile, true)
                                    if allocated and .onMissile(missile) then
                                        call terminate()
                                        exitwhen true
                                    endif
                                endif
                            endif
                        endif
                    set k = k + 1
                endloop
            endif
        endif
    endmodule
  
    private module OnDestructable
        if .onDestructable.exists then
            if allocated and collision > 0 then
                set dx = collision
                call SetRect(rect, x - dx, y - dx, x + dx, y + dx)
                call EnumDestructablesInRect(rect, null, function thistype.onDest)
            endif
        endif
    endmodule
  
    private module OnItem
        if .onItem.exists then
            if allocated and collision > 0 then
                set dx = collision
                call SetRect(rect, x - dx, y - dx, x + dx, y + dx)
                call EnumItemsInRect(rect, null, function thistype.onItems)
            endif
        endif
    endmodule
    
    private module OnCliff
        if .onCliff.exists then
            set dx = GetTerrainCliffLevel(nextX, nextY)
            set dy = GetTerrainCliffLevel(x, y) 
            if dy < dx and z  < (dx - GetMapCliffLevel())*bj_CLIFFHEIGHT then
                if allocated and .onCliff() then
                    call terminate()
                endif
            endif
        endif
    endmodule
    
    private module OnTerrain
        if .onTerrain.exists then
            if GetLocZ(x, y) > z then
                if allocated and .onTerrain() then
                    call terminate()
                endif
            endif
        endif
    endmodule
    
    private module OnTileset
        if .onTileset.exists then
            set k = GetTerrainType(x, y)
            if k != tileset then
                if allocated and .onTileset(k) then
                    call terminate()
                endif
            endif
            set tileset = k
        endif
    endmodule
    
    private module OnPeriod
        if .onPeriod.exists then
            if allocated and .onPeriod() then
                call terminate()
            endif
        endif
    endmodule
    
    private module OnOrient
        // Homing or not
        set u = target
        if u != null and GetUnitTypeId(u) != 0 then
            call impact.move(GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u) + toZ)
            set dx = impact.x - nextX
            set dy = impact.y - nextY
            set a = Atan2(dy, dx)
            set travel = o.distance - SquareRoot(dx*dx + dy*dy)
        else
            set a = o.angle
            set target = null
        endif
        
        // turn rate
        if turn != 0 and not (Cos(cA-a) >= Cos(turn)) then
            if Sin(a-cA) >= 0 then
                set cA = cA + turn
            else
                set cA = cA - turn
            endif
        else
            set cA = a
        endif

        set vel = veloc*dilation
        set yaw = cA*bj_RADTODEG
        set s = travel + vel
        set veloc = veloc + acceleration
        set travel = s
        set pitch  = origin.alpha
        set prevX = x
        set prevY = y
        set prevZ = z
        set x = nextX
        set y = nextY
        set z = nextZ
        set nextX = x + vel*Cos(cA)
        set nextY = y + vel*Sin(cA)

        // arc calculation
        if h != 0 or o.slope != 0 then
            set nextZ = 4*h*s*(d-s)/(d*d) + o.slope*s + o.z
            set pitch = pitch - Atan(((4*h)*(2*s - d))/(d*d))*bj_RADTODEG
        endif
    
        // curve calculation
        if c != 0 then
            set dx  = 4*c*s*(d-s)/(d*d)
            set a   = cA + bj_PI/2
            set x   = x + dx*Cos(a)
            set y   = y + dx*Sin(a)
            set yaw = (cA + Atan(-((4*c)*(2*s - d))/(d*d)))*bj_RADTODEG
        endif
    endmodule
    
    private module OnFinish
        if s >= d then
            set finished = true
            if .onFinish.exists then
                if allocated and .onFinish() then
                    call terminate()
                else
                    if travel > 0 and not paused then
                        call terminate()
                    endif
                endif
            else
                call terminate()
            endif
        endif

        call SetUnitAnimationByIndex(dummy, R2I(pitch + 90.5))
        call SetUnitFacing(dummy, yaw)
    endmodule
    
    private module OnBoundaries
        if not (x > WorldBounds.maxX or x < WorldBounds.minX or y > WorldBounds.maxY or y < WorldBounds.minY) then
            call SetUnitX(dummy, x)
            call SetUnitY(dummy, y)
            call SetUnitZ(dummy, z)
        else
            if .onBoundaries.exists then
                if allocated and .onBoundaries() then
                    call terminate()
                endif
            endif
        endif
    endmodule
    
    private module OnPause
        set pid = pid + 1
        set pkey = pid
        set frozen[pid] = this
        
        if .onPause.exists then
            if allocated and .onPause() then
                call terminate()
            endif
        endif
    endmodule
    
    private module OnResume
        local thistype aux
        
        set paused = flag
        if not paused and pkey != -1 then
            set id = id + 1
            set missiles[id] = this
            set aux = frozen[pid]
            set aux.pkey = pkey
            set frozen[pkey] = frozen[pid]
            set pid = pid - 1
            set pkey = -1

            if id + 1 > SWEET_SPOT and SWEET_SPOT > 0 then
                set dilation = (id + 1)/SWEET_SPOT
            else
                set dilation = 1.
            endif

            if id == 0 then
                call TimerStart(timer, PERIOD, true, function thistype.move)
            endif
            
            if .onResume.exists then
                if allocated and .onResume() then
                    call terminate()
                else
                    if finished then
                        call terminate()
                    endif
                endif
            else
                if finished then
                    call terminate()
                endif
            endif
        endif
    endmodule
    
    private module OnRemove
        local thistype aux
    
        if allocated and launched then
            set allocated = false
            
            if pkey != -1 then
                set aux = frozen[pid]
                set aux.pkey = pkey
                set frozen[pkey] = frozen[pid]
                set pid = pid - 1
                set pkey = -1
            endif
            
            if .onRemove.exists then
                call .onRemove()
            endif
            
            set aux = collection[count]
            set aux.index = index
            set collection[index] = collection[count]
            set count = count - 1
            set index = -1

            static if LIBRARY_DummyRecycler then
                call SetUnitOwner(dummy, Player(PLAYER_NEUTRAL_PASSIVE), false)
                call DummyAddRecycleTimer(dummy, RECYCLE_TIME)
            else
                call Pool.recycle(dummy, RECYCLE_TIME)
            endif
            call origin.destroy()
            call impact.destroy()
            call DestroyEffect(effect)
            call reset()
            call FlushChildHashtable(table, this)
        endif
    endmodule
    
    private module Operators
        /* -------------------------- Model of the missile -------------------------- */
        method operator model= takes string fxpath returns nothing
            call DestroyEffect(effect)
            set path = fxpath
            set effect  = AddSpecialEffectTarget(fxpath, dummy, "origin")
        endmethod
    
        method operator model takes nothing returns string
            return path
        endmethod
    
        /* ----------------------------- Curved movement ---------------------------- */
        method operator curve= takes real value returns nothing
            set open = Tan(value*bj_DEGTORAD)*origin.distance
        endmethod
    
        method operator curve takes nothing returns real
            return Atan(open/origin.distance)*bj_RADTODEG
        endmethod
    
        /* ----------------------------- Arced Movement ----------------------------- */
        method operator arc= takes real value returns nothing
            set height = Tan(value*bj_DEGTORAD)*origin.distance/4
        endmethod
    
        method operator arc takes nothing returns real
            return Atan(4*height/origin.distance)*bj_RADTODEG
        endmethod
    
        /* ------------------------------ Effect scale ------------------------------ */
        method operator scale= takes real v returns nothing
            call SetUnitScale(dummy, v, v, v)
            set size = v
        endmethod
    
        method operator scale takes nothing returns real
            return size
        endmethod

        /* ------------------------------ Missile Speed ----------------------------- */
        method operator speed= takes real newspeed returns nothing
            local real d = origin.distance
            local real s
            local real vel
        
            set veloc = newspeed*PERIOD
            set vel = veloc*dilation
            set s = travel + vel
            set nextX = x + vel*Cos(cA)
            set nextY = y + vel*Sin(cA)

            if height != 0 or origin.slope != 0 then
                set nextZ = 4*height*s*(d-s)/(d*d) + origin.slope*s + origin.z
                set z = nextZ
            endif
        endmethod

        method operator speed takes nothing returns real
            return veloc/PERIOD
        endmethod

        /* ------------------------------- Flight Time ------------------------------ */
        method operator duration= takes real flightTime returns nothing
            local real d = origin.distance
            local real s
            local real vel
        
            set veloc = RMaxBJ(0.00000001, (origin.distance - travel)*PERIOD/RMaxBJ(0.00000001, flightTime))
            set time = flightTime
            set vel = veloc*dilation
            set s = travel + vel
            set nextX = x + vel*Cos(cA)
            set nextY = y + vel*Sin(cA)

            if height != 0 or origin.slope != 0 then
                set nextZ = 4*height*s*(d-s)/(d*d) + origin.slope*s + origin.z
                set z = nextZ
            endif
        endmethod

        method operator duration takes nothing returns real
            return time
        endmethod
        
        /* ------------------------------- Sight Range ------------------------------ */
        method operator vision= takes real sightRange returns nothing
            set sight = sightRange
            
            if owner == null then
                if source != null then
                    call SetUnitOwner(dummy, GetOwningPlayer(source), false)
                endif
            else
                call SetUnitOwner(dummy, owner, false)
            endif
        endmethod
        
        method operator vision takes nothing returns real
            return sight
        endmethod
    endmodule
    
    private module Methods
        /* ---------------------------- Bound and Deflect --------------------------- */
        method bounce takes nothing returns nothing
            call origin.move(x, y, z - GetLocZ(x, y))
            
            set travel = 0
            set finished = false
        endmethod
        
        method deflect takes real tx, real ty, real tz returns nothing
            local real locZ = GetLocZ(x, y)
            
            set target = null
            set toZ = tz
            
            if z < locZ and .onTerrain.exists then
                set nextX = prevX
                set nextY = prevY
                set nextZ = prevZ
            endif
            
            call impact.move(tx, ty, tz)
            call origin.move(x, y, z - locZ)
            
            set travel = 0
            set finished = false
        endmethod
        
        method deflectTarget takes unit u returns nothing
            call deflect(GetUnitX(u), GetUnitY(u), toZ)
            set target = u
        endmethod

        /* ---------------------------- Flush hit targets --------------------------- */
        method flushAll takes nothing returns nothing
            call FlushChildHashtable(table, this)
        endmethod

        method flush takes widget w returns nothing
            if w != null then
                call RemoveSavedBoolean(table, this, GetHandleId(w))
            endif
        endmethod

        method hitted takes widget w returns boolean
            return HaveSavedBoolean(table, this, GetHandleId(w))
        endmethod

        /* ------------------------------ Missile Pause ----------------------------- */
        method pause takes boolean flag returns nothing
            implement OnResume
        endmethod

        /* ------------------------- Destructable hit method ------------------------ */
        static method onDest takes nothing returns nothing
            local thistype this  = temp
            local destructable d = GetEnumDestructable()
            local real dz
            local real tz

            if not HaveSavedBoolean(table, this, GetHandleId(d)) then
                if collideZ then
                    set dz = GetLocZ(GetWidgetX(d), GetWidgetY(d))
                    set tz = GetDestructableOccluderHeight(d)
                    if dz + tz >= z - collision and dz <= z + collision then
                        call SaveBoolean(table, this, GetHandleId(d), true)
                        if allocated and .onDestructable(d) then
                            set d = null
                            call terminate()
                            return
                        endif
                    endif
                else
                    call SaveBoolean(table, this, GetHandleId(d), true)
                    if allocated and .onDestructable(d) then
                        set d = null
                        call terminate()
                        return
                    endif
                endif
            endif

            set d = null
        endmethod

        /* -------------------------- Item collision method ------------------------- */
        static method onItems takes nothing returns nothing
            local thistype this  = temp
            local item i = GetEnumItem()
            local real dz

            if not HaveSavedBoolean(table, this, GetHandleId(i)) then
                if collideZ then
                    set dz = GetLocZ(GetItemX(i), GetItemY(i))
                    if dz + ITEM_SIZE >= z - collision and dz <= z + collision then
                        call SaveBoolean(table, this, GetHandleId(i), true)
                        if allocated and .onItem(i) then
                            set i = null
                            call terminate()
                            return
                        endif
                    endif
                else
                    call SaveBoolean(table, this, GetHandleId(i), true)
                    if allocated and .onItem(i) then
                        set i = null
                        call terminate()
                        return
                    endif
                endif
            endif

            set i = null
        endmethod

        /* -------------------------------- Terminate ------------------------------- */
        method terminate takes nothing returns nothing
            implement OnRemove
        endmethod
    endmodule
    
    struct Missiles extends MissileEvents
        private static timer timer = CreateTimer()
        private static group group = CreateGroup()
        private static rect rect = Rect(0., 0., 0., 0.)
        private static hashtable table = InitHashtable()
        private static integer last = 0 
        private static thistype temp = 0
        private static integer id = -1
        private static integer pid = -1
        private static real dilation = 1
        private static thistype array missiles
        private static thistype array frozen
        
        readonly static thistype array collection
        readonly static integer count = -1
        
        private real     cA     
        private effect   effect 
        private string   path   
        private real     size   
        private real     height 
        private real     open   
        private real     toZ    
        private real     time 
        private real     sight
        private integer  pkey
        private integer  index
        
        Coordinates      impact
        Coordinates      origin
        
        readonly real    x
        readonly real    y
        readonly real    z
        readonly real    prevX
        readonly real    prevY
        readonly real    prevZ
        readonly real    nextX
        readonly real    nextY
        readonly real    nextZ
        readonly real    turn
        readonly real    veloc
        readonly real    travel
        readonly unit    dummy
        readonly boolean launched
        readonly boolean allocated
        readonly boolean finished
        readonly boolean paused
        readonly integer tileset
        
        unit             source
        unit             target
        player           owner
        boolean          collideZ
        real             collision
        real             damage
        real             acceleration
        integer          data
        integer          type
    
        implement Operators
        implement Methods

        /* ------------------------------ Reset members ----------------------------- */
        private method reset takes nothing returns nothing
            set launched     = false
            set finished     = false
            set collideZ     = false
            set paused       = false
            set source       = null
            set target       = null
            set owner        = null
            set effect       = null
            set dummy        = null
            set path         = ""
            set open         = 0.
            set height       = 0.
            set veloc        = 0.
            set acceleration = 0.
            set collision    = 0.
            set damage       = 0.
            set travel       = 0.
            set turn         = 0.
            set size         = 0.
            set time         = 0.
            set sight        = 0.
            set data         = 0
            set type         = 0
            set tileset      = 0
            set pkey         = -1
            set index        = -1
        endmethod
        
        /* -------------------------- Destroys the missile -------------------------- */
        private method remove takes integer i returns integer
            if paused then
                implement OnPause
            else
                implement OnRemove
            endif
            
            set missiles[i] = missiles[id]
            set id = id - 1

            if id + 1 > SWEET_SPOT and SWEET_SPOT > 0 then
                set dilation = (id + 1)/SWEET_SPOT
            else
                set dilation = 1
            endif

            if id == -1 then
                call PauseTimer(timer)
            endif
            
            if not allocated then
                call deallocate()
            endif

            return i - 1
        endmethod
    
        /* ---------------------------- Missiles movement --------------------------- */
        private static method move takes nothing returns nothing
            local integer     j = 0
            local integer     i
            local integer     k
            local unit        u
            local real        a
            local real        d
            local real        s
            local real        h
            local real        c
            local real        dx
            local real        dy
            local real        vel
            local real        yaw
            local real        pitch
            local Missiles    missile
            local Coordinates o
            local thistype    this

            if SWEET_SPOT > 0 then
                set i = last
            else
                set i = 0
            endif
        
            loop
                exitwhen ((j >= SWEET_SPOT and SWEET_SPOT > 0) or j > id)
                set this = missiles[i]
                    set temp = this
                    if allocated and not paused then
                        implement OnHit
                        implement OnMissile
                        implement OnDestructable
                        implement OnItem
                        implement OnCliff
                        implement OnTerrain
                        implement OnTileset
                        implement OnPeriod
                        implement OnOrient
                        implement OnFinish
                        implement OnBoundaries
                    else
                        set i = remove(i)
                        set j = j - 1
                    endif
                set i = i + 1
                set j = j + 1

                if i > id and SWEET_SPOT > 0 then
                    set i = 0
                endif
            endloop
            set last = i

            set u = null
        endmethod
        
        /* --------------------------- Launch the Missile --------------------------- */
        method launch takes nothing returns nothing
            if not launched and allocated then
                set launched = true
                set id = id + 1
                set missiles[id] = this
                set count = count + 1
                set index = count
                set collection[count] = this
                
                if id + 1 > SWEET_SPOT and SWEET_SPOT > 0 then
                    set dilation = (id + 1)/SWEET_SPOT
                else
                    set dilation = 1.
                endif

                if id == 0 then
                    call TimerStart(timer, PERIOD, true, function thistype.move)
                endif
            endif
        endmethod

        /* --------------------------- Main Creator method -------------------------- */
        static method create takes real x, real y, real z, real toX, real toY, real toZ returns thistype
            local thistype this = thistype.allocate()
            local real face = Atan2(toY - y, toX - x)*bj_RADTODEG

            call .reset()
            set .origin = Coordinates.create(x, y, z)
            set .impact = Coordinates.create(toX, toY, toZ)
            call Coordinates.link(origin, impact)
            set .allocated = true
            set .cA = origin.angle
            set .x = x
            set .y = y
            set .z = impact.z
            set .prevX = x
            set .prevY = y
            set .prevZ = impact.z
            set .nextX = x
            set .nextY = y
            set .nextZ = impact.z
            set .toZ = toZ

            static if LIBRARY_DummyRecycler then
                set .dummy = GetRecycledDummy(x, y, z, face)
            else
                set .dummy = Pool.retrieve(x, y, z, face)
            endif

            return this
        endmethod
    endstruct
endlibrary

scope RelativisticMissilesTest initializer Init

    private struct TestMissile extends Missiles
        method onFinish takes nothing returns boolean
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\Mortar\\MortarMissile.mdl", x, y))
            call DisplayTextToPlayer(owner, 0., 0., "Relativistic Missiles 2.8: impacto completado.")
            return false
        endmethod
    endstruct

    private function OnChat takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer start = GetPlayerStartLocation(p)
        local real x = GetStartLocationX(start)
        local real y = GetStartLocationY(start)
        local TestMissile missile = TestMissile.create(x, y, 60., x + 700., y, 60.)

        set missile.model = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
        set missile.speed = 600.
        set missile.arc   = 30.
        set missile.owner = p
        call missile.launch()

        call DisplayTextToPlayer(p, 0., 0., "Relativistic Missiles 2.8 Classic: misil lanzado.")
        set p = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger command = CreateTrigger()
        local integer i = 0

        loop
            exitwhen i == bj_MAX_PLAYER_SLOTS
            call TriggerRegisterPlayerChatEvent(command, Player(i), "-rmtest", true)
            set i = i + 1
        endloop
        call TriggerAddAction(command, function OnChat)
        set command = null
    endfunction

endscope

