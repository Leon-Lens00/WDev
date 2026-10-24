//TESH.scrollpos=458
//TESH.alwaysfold=0
library AutoIndex
//===========================================================================
// Information:
//==============
//
//     AutoIndex is a very simple script to utilize. Just call GetUnitId(unit) to
// get get the unique value assigned to a particular unit. AutoIndex differs from
// other unit indexing libraries because it automatically assigns an ID to each
// unit as it enters the map, and automatically frees that ID as the unit leaves
// the map. This gives you several advantages as the user:
//
// 1.) The GetUnitId function inlines directly to a GetUnitUserData call (or a
//     LoadInteger call if UseUnitUserData is disabled.)
// 2.) You don't need to manually free IDs as units leave the map.
// 3.) Detecting removing units to free their indexes is O(1), and less costly
//     performance-wise than a timer scanning the map for removed units.
//
//     If you turn on debug mode, AutoIndex will become slower, but it will show
// you a variety of helpful error messages. It can detect the following problems:
//   -Passing a null unit to GetUnitId
//   -Passing a removed or decayed unit to GetUnitId
//   -Code outside of AutoIndex has overwritten a unit's UserData value.
//   -GetUnitId was used on a filtered unit (a unit you don't want indexed).
//
//     AutoIndex also provides events upon indexing or deindexing units. This
// effectively allows you to notice when units enter or leave the game, and
// handle the creation or destruction of attached data or other things.
//
//===========================================================================
// How to install AutoIndex:
//===========================
//
// 1.) Copy and paste this script into your map.
// 2.) Save it to allow the ObjectMerger macro to generate the "Leave Detect"
//     ability for you. Close and re-open the map. After that, disable the macro
//     to prevent the save delay.
//
//===========================================================================
// How to use AutoIndex:
//=======================
//
//     So you can get a unique integer for each unit, but how do you use that to
// attach data to a unit? GetUnitId will always return a number in the range of
// 1-8190. This means it can be used as an array index, as demonstrated below:
//
// globals
//     integer array IntegerData
//     real array RealData
//     SomeStruct array SomeStructData
// englobals
//
// function Example takes nothing returns nothing
//     local unit u = CreateUnit(...)
//     local integer id = GetUnitId(u)
//         //You now have a unique index for the unit, so you can
//         //attach or retrieve data about the unit using arrays.
//         set IntegerData[id] = 5
//         set RealData[id] = 25.0
//         set SomeStructData[id] = SomeStruct.create()
//         //If you have access to the same unit in another function, you can
//         //retrieve the data by using GetUnitId() and reading the arrays.
// endfunction
//
//     The UnitFilter function in the config section is provided so that you can
// make AutoIndex completely ignore any unit-types that don't want to be indexed.
// You may want to ignore dummy casters or system-private units, especially ones
// that use UnitUserData internally. You don't need to worry about xe dummy units,
// as those are automatically filtered.
//
//===========================================================================
// How to use OnUnitIndexed / OnUnitDeindexed:
//=============================================
//
//     AutoIndex will fire the OnUnitIndexed event when a unit enters the map,
// and the OnUnitDeindexed event when a unit leaves the map. Functions used
// as events must take a unit and return nothing. An example is given below:
//
// function UnitEntersMap takes unit u returns nothing
//     call BJDebugMsg(GetUnitName(u)+" was indexed with the ID "+I2S(GetUnitId(u)))
// endfunction
//
// function UnitLeavesMap takes unit u returns nothing
//     call BJDebugMsg(GetUnitName(u)+" was deindexed with the ID "+I2S(GetUnitId(u)))
// endfunction
//
// function Init takes nothing returns nothing
//     call OnUnitIndexed(UnitEntersMap)
//     call OnUnitDeindexed(UnitLeavesMap)
// endfunction
//
//     As you can see, it works perfectly fine to call GetUnitId() on a unit
// during either of these events.
//
//     If you call OnUnitIndexed during map initialization, every existing
// unit will be considered as entering the map. This saves you from needing
// to manually enumerate preplaced units (or units created by initialization
// code that ran before OnUnitIndexed was called).
//
//     OnUnitDeindexed runs while a unit still exists, which means you can
// still do things such as destroy special effects attached to the unit.
// The unit will cease to exist immediately after the event is over.
//
//===========================================================================
// AutoIndex API:
//================
//
// GetUnitId(unit) -> integer
//   This function returns a unique ID in the range of 1-8190 for the
//   specified unit. Use it to attach data to the unit. This function
//   inlines directly to GetUnitUserData or LoadInteger if debug mode
//   is disabled. If debug mode is enabled, it can display error mess-
//   ages when passed a null, decayed or filtered unit.
//
// IsUnitIndexed(unit) -> boolean
//   This function returns a boolean indicating whether the specified
//   unit is indexed or not. A unit would not be indexed if you ignored
//   it using the UnitFilter function, or if it is a xe dummy unit.
//
// OnUnitIndexed(IndexFunc)
//   This function accepts an IndexFunc, which must take a unit and
//   return nothing. The IndexFunc will be fired instantly whenever
//   a unit enters the map. You may use GetUnitId on the unit. When
//   you call this function during map initialization, every existing
//   unit will be considered as entering the map.
//
// OnUnitDeindexed(IndexFunc)
//   Same as above, but runs whenever a unit is leaving the map. When
//   this event runs, the unit still exists, but it will cease to exist
//   as soon as the event ends. You may use GetUnitId on the unit.
//
//===========================================================================
// Configuration:
//================

//! external ObjectMerger w3a Adef lvdt anam "Leave Detect" aart "" arac 0
//Save your map with this Object Merger call enabled, then close and reopen your
//map. Disable it by removing the exclamation to remove the delay while saving.

globals
    private constant integer LeaveDetectAbilityID = 'lvdt'
    //This rawcode must match the parameter after "Adef" in the
    //ObjectMergermacro above. You can change both if you want.
    
    private constant boolean UseUnitUserData = true
    //If this is set to true, UnitUserData will be used. You should only set
    //this to false if something else in your map already uses UnitUserData.
    //A hashtable will be used instead, but it is about 60% slower.
endglobals

public function UnitFilter takes nothing returns boolean
    return true
endfunction
//Any units you filter out in this function will not be indexed.
//Use GetFilterUnit() to refer to the filtered unit. You do not
//need to filter out xe dummy units; they are already filtered.

//===========================================================================
// User functions:
//=================

function GetUnitId takes unit u returns integer
    static if DEBUG_MODE then
        return AutoIndex.getIndexDebug(u)
    else
        return AutoIndex.getIndex(u)
    endif
endfunction

function IsUnitIndexed takes unit u returns boolean
    return AutoIndex.isUnitIndexed(u)
endfunction

function interface IndexFunc takes unit u returns nothing

function OnUnitIndexed takes IndexFunc func returns nothing
    call AutoIndex.onUnitIndexed(func)
endfunction

function OnUnitDeindexed takes IndexFunc func returns nothing
    call AutoIndex.onUnitDeindexed(func)
endfunction

//===========================================================================

hook RemoveUnit AutoIndex.hook_RemoveUnit
hook ReplaceUnitBJ AutoIndex.hook_ReplaceUnitBJ
debug hook SetUnitUserData AutoIndex.hook_SetUnitUserData

struct AutoIndex
    private static trigger   enter      = CreateTrigger()
    private static trigger   status     = CreateTrigger()
    private static trigger   creepdeath = CreateTrigger()
    private static group     preplaced  = CreateGroup()
    private static timer     allowdecay = CreateTimer()
    private static hashtable ht

    private static boolean array dead
    private static boolean array summoned
    private static boolean array animated
    private static boolean array nodecay
    private static boolean array removing
    
    private static IndexFunc array indexfuncs
    private static integer indexfuncs_n = -1
    private static IndexFunc array deindexfuncs
    private static integer deindexfuncs_n = -1
    private static IndexFunc indexfunc
    
    private static unit array allowdecayunit
    private static integer allowdecay_n = -1
    
    private static boolean duringinit = true
    private static boolean array altered
    private static unit array idunit
    
    //===========================================================================

    static method getIndex takes unit u returns integer
        static if UseUnitUserData then
            return GetUnitUserData(u)
        else
            return LoadInteger(ht, 0, GetHandleId(u))
        endif
    endmethod
    //Resolves to an inlinable one-liner after the static if.
    
    static method getIndexDebug takes unit u returns integer
        local integer index = getIndex(u)
            if u == null then
                call BJDebugMsg("AutoIndex error: Null unit passed to GetUnitId.")
            elseif GetUnitTypeId(u) == 0 then
                call BJDebugMsg("AutoIndex error: Removed or decayed unit passed to GetUnitId.")
            elseif idunit[index] != u then
                call BJDebugMsg("AutoIndex error: "+GetUnitName(u)+" is a filtered unit.")
            endif
        return index
    endmethod
    //If debug mode is enabled, use the getIndex method that shows errors.
    
    static method setIndex takes unit u, integer index returns nothing
        static if UseUnitUserData then
            call SetUnitUserData(u, index)
        else
            call SaveInteger(ht, 0, GetHandleId(u), index)
        endif
    endmethod
    //Resolves to an inlinable one-liner after the static if.
    
    //===========================================================================
    
    static method isUnitAnimateDead takes unit u returns boolean
        return animated[getIndex(u)]
    endmethod
    //Don't use this; use IsUnitAnimateDead from StatusEvents instead.
    
    static method isUnitIndexed takes unit u returns boolean
        return u != null and idunit[getIndex(u)] == u
    endmethod
    
    //===========================================================================
    
    private static method onUnitIndexed_sub takes nothing returns nothing
        call indexfunc.evaluate(GetEnumUnit())
    endmethod
    //During initialization, evaluate the indexfunc for every preplaced unit.
    
    static method onUnitIndexed takes IndexFunc func returns nothing
        set indexfuncs_n = indexfuncs_n + 1
        set indexfuncs[indexfuncs_n] = func
        if duringinit then
            set indexfunc = func
            call ForGroup(preplaced, function AutoIndex.onUnitIndexed_sub)
        endif
    endmethod
    static method onUnitDeindexed takes IndexFunc func returns nothing
        set deindexfuncs_n = deindexfuncs_n + 1
        set deindexfuncs[deindexfuncs_n] = func
    endmethod
    
    //===========================================================================
    
    private static method hook_RemoveUnit takes unit whichUnit returns nothing
        set removing[getIndex(whichUnit)] = true
    endmethod
    private static method hook_ReplaceUnitBJ takes unit whichUnit, integer newUnitId, integer unitStateMethod returns nothing
        set removing[getIndex(whichUnit)] = true
    endmethod
    //Intercepts whenever RemoveUnit or ReplaceUnitBJ is called and sets a flag.
    
    private static method hook_SetUnitUserData takes unit whichUnit, integer data returns nothing
        static if UseUnitUserData then
            if IsUnitIndexed(whichUnit) then
                if getIndex(whichUnit) == data then
                    call BJDebugMsg("AutoIndex error: Code outside AutoIndex attempted to alter "+GetUnitName(whichUnit)+"'s index.")
                else
                    call BJDebugMsg("AutoIndex error: Code outside AutoIndex altered "+GetUnitName(whichUnit)+"'s index.")
                    if idunit[data] != null then
                        call BJDebugMsg("AutoIndex error: "+GetUnitName(whichUnit)+" and "+GetUnitName(idunit[data])+" now have the same index.")
                    endif
                    set altered[data] = true
                endif
            endif
        endif
    endmethod
    //In debug mode, intercepts whenever SetUnitUserData is used on an indexed unit.
    //Displays an error message if outside code tries to alter a unit's index.
    
    //===========================================================================
    
    private static method allowDecay takes nothing returns nothing
        local integer n = allowdecay_n
            loop
                exitwhen n < 0
                set nodecay[getIndex(allowdecayunit[n])] = false
                set allowdecayunit[n] = null
                set n = n - 1
            endloop
            set allowdecay_n = -1
    endmethod
    //Iterate through all the units in the stack and allow them to decay again.
    
    private static method detectStatus takes nothing returns boolean
        local unit u = GetTriggerUnit()
        local integer index = getIndex(u)
        local integer n
            
            if idunit[index] == u then //Ignore non-indexed units.
                if not IsUnitType(u, UNIT_TYPE_DEAD) then
                
                    if dead[index] then //The unit was dead, but now it's alive.
                        set dead[index] = false //The unit has been resurrected.
                        
                        //! runtextmacro optional RunStatusEvent("Resurrect")
                        //If StatusEvents is in the map, run the resurrection events.
                            
                        if IsUnitType(u, UNIT_TYPE_SUMMONED) and not summoned[index] then
                            set summoned[index] = true //If the unit gained the summoned flag,
                            set animated[index] = true //it's been raised with Animate Dead.
                                
                            //! runtextmacro optional RunStatusEvent("AnimateDead")
                            //If StatusEvents is in the map, run the Animate Dead events.
                        endif
                    endif
                else
                
                    if not removing[index] and not dead[index] and not animated[index] then
                        set dead[index] = true    //The unit was alive, but now it's dead.
                        set nodecay[index] = true //A dead unit can't decay for at least 0. seconds.
                        set allowdecay_n = allowdecay_n + 1  //Add the unit to a stack. After the timer
                        set allowdecayunit[allowdecay_n] = u //expires, allow the unit to decay again.
                        call TimerStart(allowdecay, 0., false, function AutoIndex.allowDecay)
                        
                        //! runtextmacro optional RunStatusEvent("Death")
                        //If StatusEvents is in the map, run the Death events.
                        //! runtextmacro optional TransportUnload()
                        //If TransportEvents is in the map, remove the dead unit from whatever transport it's in.
                        
                    elseif removing[index] or (dead[index] and not nodecay[index]) or (not dead[index] and animated[index]) then
                        //If .nodecay was false and the unit is dead and was previously dead, the unit decayed.
                        //If .animated was true and the unit is dead, the unit died and exploded.
                        //If .removing was true, the unit is being removed or replaced.
                        
                        //! runtextmacro optional TransportUnload()
                        //If TransportEvents is in the map, remove the leaving unit from whatever transport it's in.
                        
                        set n = deindexfuncs_n
                        loop //Run the OnUnitDeindexed events.
                            exitwhen n < 0
                            call deindexfuncs[n].evaluate(u)
                            set n = n - 1
                        endloop
                        
                        //! runtextmacro optional TransportClean()
                        //If TransportEvents is in the map, and the leaving unit is a
                        //transport, clean the transport- related data from the unit.
                        
                        call AutoIndex(index).destroy() //Free the index by destroying the AutoIndex struct.
                        set idunit[index] = null //Null this unit reference to prevent a leak.
                    endif
                endif
            endif
            
        set u = null
        return false
    endmethod
    
    private static method isUndefendOrder takes nothing returns boolean
            //! runtextmacro optional TransportUnloadCheck()
            //If TransportEvents is in the map, check whether a unit is unloading.
        return GetIssuedOrderId() == 852056
    endmethod
    
    //===========================================================================
    
    private static method unitEntersMap takes unit u returns nothing
        local integer index
        local integer n = 0
            if getIndex(u) != 0 then //If a unit already has an ID, don't assign a new one.
                return               //This only happens if a unit leaves the entire map area.
            endif
            set index = create()
            call setIndex(u, index) //Assign an index to the entering unit.
            
            call UnitAddAbility(u, LeaveDetectAbilityID) //Add the leave detect ability to the entering unit.
            call UnitMakeAbilityPermanent(u, true, LeaveDetectAbilityID) //Prevent it from disappearing on morph.
            
            set dead[index] = IsUnitType(u, UNIT_TYPE_DEAD)         //Reset all of the flags for the entering
            set summoned[index] = IsUnitType(u, UNIT_TYPE_SUMMONED) //unit. These flags are necessary to detect
            set animated[index] = false                             //when the unit leaves the map.
            set nodecay[index] = false
            set removing[index] = false
            debug set altered[index] = false //In debug mode, this flag tracks wheter a unit's index was altered.
            set idunit[index] = u            //Attach the unit that is supposed to have this index to the index.

            loop //Run the OnUnitIndexed events.
                exitwhen n > indexfuncs_n
                call indexfuncs[n].evaluate(u)
                set n = n + 1
            endloop
    endmethod
    
    private static method initPreplacedUnit takes nothing returns nothing
            static if LIBRARY_xebasic then
                if GetUnitTypeId(GetEnumUnit()) == XE_DUMMY_UNITID then
                    return //Don't index xe dummy units, and don't add
                endif      //them to the group of preplaced units.
            endif
            call GroupAddUnit(preplaced, GetEnumUnit()) //Assemble a group of all the preplaced units.
            call unitEntersMap(GetEnumUnit()) //Initialize each preplaced unit.
        return
    endmethod
    
    private static method initEnteringUnit takes nothing returns boolean
            static if LIBRARY_xebasic then
                if GetUnitTypeId(GetFilterUnit()) == XE_DUMMY_UNITID then
                    return false //Don't index xe dummy units, and don't add
                endif            //them to the group of preplaced units.
            endif
            if duringinit then
                call GroupAddUnit(preplaced, GetFilterUnit())
                //Add units that are created during initialization to the preplaced units group.
                //This ensures that all units are noticed by OnUnitIndexed during initialization.
            endif
            call unitEntersMap(GetFilterUnit()) //Initialize each unit that enters the map.
        return false
    endmethod
    
    //===========================================================================
    
    private static method afterInit takes nothing returns nothing
        set duringinit = false //Initialization is over; set a flag.
        call DestroyTimer(GetExpiredTimer()) //Destroy the timer.
        call GroupClear(preplaced)   //The preplaced units group is
        call DestroyGroup(preplaced) //no longer needed, so clean it.
        set preplaced = null
    endmethod
    
    private static method onInit takes nothing returns nothing
        local region maparea = CreateRegion()
        local rect bounds = GetWorldBounds()
        local group g = CreateGroup()
        local integer i = 15
            static if not UseUnitUserData then
                set ht = InitHashtable() //Only create a hashtable if it will be used.
            endif
        
            loop
                exitwhen i < 0
                call SetPlayerAbilityAvailable(Player(i), LeaveDetectAbilityID, false)
                //Make the LeaveDetect ability unavailable so that it doesn't show up on the command card of every unit.
                call TriggerRegisterPlayerUnitEvent(status, Player(i), EVENT_PLAYER_UNIT_ISSUED_ORDER, function UnitFilter)
                //Register the "EVENT_PLAYER_UNIT_ISSUED_ORDER" event to notice Undefend orders. Ignore filtered units.
                
                call GroupEnumUnitsOfPlayer(g, Player(i), Condition(function UnitFilter))
                call ForGroup(g, function AutoIndex.initPreplacedUnit)
                //Enum every non-filtered unit on the map during initialization and assign it a unique
                //index. By using GroupEnumUnitsOfPlayer, even units with Locust can be detected.
                set i = i - 1
            endloop
            call TriggerAddCondition(status, And(function AutoIndex.isUndefendOrder, function AutoIndex.detectStatus))
            //The detectStatus method will fire every time a non-filtered unit recieves an undefend order.
            //And() is used here to avoid using a trigger action, which starts a new thread and is slower.
            
            call TriggerRegisterPlayerUnitEvent(creepdeath, Player(12), EVENT_PLAYER_UNIT_DEATH, function UnitFilter)
            call TriggerAddCondition(creepdeath, function AutoIndex.detectStatus)
            //The detectStatus method must also fire when a neutral hostile creep dies, in case it was
            //sleeping. Sleeping creeps don't fire undefend orders on non-damaging deaths.
            
            call RegionAddRect(maparea, bounds) //GetWorldBounds() contains the entire map area, including the shaded boundry areas.
            call TriggerRegisterEnterRegion(enter, maparea, And(function UnitFilter, function AutoIndex.initEnteringUnit))
            //Only the filter function of an EnterRegion trigger runs instantly when a unit is created.
            //Using And() lets both the UnitFilter and indexing function run when a unit enters the map.
            
            call TimerStart(CreateTimer(), 0., false, function AutoIndex.afterInit)
            //After any time elapses, perform after-initialization actions.
            
        call GroupClear(g)
        call DestroyGroup(g)
        call RemoveRect(bounds)
        set g = null
        set bounds = null
    endmethod
    
endstruct

endlibrary
