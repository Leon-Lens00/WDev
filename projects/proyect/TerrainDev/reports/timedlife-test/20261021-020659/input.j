library WorldBounds /* v2.0.0.0
************************************************************************************
*
*	struct WorldBounds extends array
*
*		Fields
*		-------------------------
*
*			readonly static integer maxX
*			readonly static integer maxY
*			readonly static integer minX
*			readonly static integer minY
*
*			readonly static integer centerX
*			readonly static integer centerY
*
*			readonly static rect world
*			readonly static region worldRegion
*
************************************************************************************/
	private module WorldBoundInit
		private static method onInit takes nothing returns nothing
			set world=GetWorldBounds()
			
			set maxX = R2I(GetRectMaxX(world))
			set maxY = R2I(GetRectMaxY(world))
			set minX = R2I(GetRectMinX(world))
			set minY = R2I(GetRectMinY(world))
			
			set centerX = R2I((maxX + minX)/2)
			set centerY = R2I((minY + maxY)/2)
			
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
		
		implement WorldBoundInit
	endstruct
endlibrary

library ErrorMessage /* v1.0.1.4
*************************************************************************************
*
*	Issue Compliant Error Messages
*
************************************************************************************
*
*	debug function ThrowError takes boolean expression, string libraryName, string functionName, string objectName, integer objectInstance, string description returns nothing
*		-	In the event of an error the game will be permanently paused
*
*	debug function ThrowWarning takes boolean expression, string libraryName, string functionName, string objectName, integer objectInstance, string description returns nothing
*
************************************************************************************/
	static if DEBUG_MODE then
		private struct Fields extends array
			static constant string COLOR_RED = "|cffff0000"
			static constant string COLOR_YELLOW = "|cffffff00"
			static string lastError = null
		endstruct
		
		private function Pause takes nothing returns nothing
			call PauseGame(true)
		endfunction
		
		private function ThrowMessage takes string libraryName, string functionName, string objectName, integer objectInstance, string description, string errorType, string color returns nothing
			local string str
			
			local string color_braces = "|cff66FF99"
			local string orange = "|cffff6600"
			
			set str = "->\n-> " + color_braces + "{|r " + "Library" + color_braces + "(" + orange + libraryName + color_braces + ")"
			if (objectName != null) then
				if (objectInstance > 0) then
					set str = str + "|r.Object" + color_braces + "(" + orange + objectName + color_braces + " (|rinstance = " + orange + I2S(objectInstance) + color_braces + ") )" + "|r." + "Method" + color_braces + "(" + orange + functionName + color_braces + ")"
				else
					set str = str + "|r.Object" + color_braces + "(" + orange + objectName + color_braces + ")|r." + "Method" + color_braces + "(" + orange + functionName + color_braces + ")"
				endif
			else
				set str = str + "|r." + "Function" + color_braces + "(" + orange + functionName + color_braces + ")"
			endif
			
			set str = str + color_braces + " }|r " + "has thrown an exception of type " + color_braces + "(" + color + errorType + color_braces + ")|r."
			
			set Fields.lastError = str + "\n->\n" + "->	" + color + description + "|r\n->"
		endfunction
		
		function ThrowError takes boolean expression, string libraryName, string functionName, string objectName, integer objectInstance, string description returns nothing
			if (Fields.lastError != null) then
				set objectInstance = 1/0
			endif
		
			if (expression) then
				call ThrowMessage(libraryName, functionName, objectName, objectInstance, description, "Error", Fields.COLOR_RED)
				call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,Fields.lastError)
				call TimerStart(CreateTimer(), 0, true, function Pause)
				set objectInstance = 1/0
			endif
		endfunction

		function ThrowWarning takes boolean expression, string libraryName, string functionName, string objectName, integer objectInstance, string description returns nothing
			if (Fields.lastError != null) then
				set objectInstance = 1/0
			endif
		
			if (expression) then
				call ThrowMessage(libraryName, functionName, objectName, objectInstance, description, "Warning", Fields.COLOR_YELLOW)
				call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60000,Fields.lastError)
				set Fields.lastError = null
			endif
		endfunction
	endif
endlibrary



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

library Table /* made by Bribe, special thanks to Vexorian & Nestharus, version 3.1.0.1
   
    One map, one hashtable. Welcome to NewTable 3.1
   
    This library was originally called NewTable so it didn't conflict with
    the API of Table by Vexorian. However, the damage is done and it's too
    late to change the library name now. To help with damage control, I
    have provided an extension library called TableBC, which bridges all
    the functionality of Vexorian's Table except for 2-D string arrays &
    the ".flush(integer)" method. I use ".flush()" to flush a child hash-
    table, because I wanted the API in NewTable to reflect the API of real
    hashtables (I thought this would be more intuitive).
   
    API
   
    ------------
    struct Table
    | static method create takes nothing returns Table
    |     create a new Table
    |    
    | method destroy takes nothing returns nothing
    |     destroy it
    |    
    | method flush takes nothing returns nothing
    |     flush all stored values inside of it
    |    
    | method remove takes integer key returns nothing
    |     remove the value at index "key"
    |    
    | method operator []= takes integer key, $TYPE$ value returns nothing
    |     assign "value" to index "key"
    |    
    | method operator [] takes integer key returns $TYPE$
    |     load the value at index "key"
    |    
    | method has takes integer key returns boolean
    |     whether or not the key was assigned
    |
    ----------------
    struct TableArray
    | static method operator [] takes integer array_size returns TableArray
    |     create a new array of Tables of size "array_size"
    |
    | method destroy takes nothing returns nothing
    |     destroy it
    |
    | method flush takes nothing returns nothing
    |     flush and destroy it
    |
    | method operator size takes nothing returns integer
    |     returns the size of the TableArray
    |
    | method operator [] takes integer key returns Table
    |     returns a Table accessible exclusively to index "key"
*/
   
globals
    private integer less = 0    //Index generation for TableArrays (below 0).
    private integer more = 8190 //Index generation for Tables.
    //Configure it if you use more than 8190 "key" variables in your map (this will never happen though).
   
    private hashtable ht = InitHashtable()
    private key sizeK
    private key listK
endglobals
   
private struct dex extends array
    static method operator size takes nothing returns Table
        return sizeK
    endmethod
    static method operator list takes nothing returns Table
        return listK
    endmethod
endstruct
   
private struct handles extends array
    method has takes integer key returns boolean
        return HaveSavedHandle(ht, this, key)
    endmethod
    method remove takes integer key returns nothing
        call RemoveSavedHandle(ht, this, key)
    endmethod
endstruct
   
private struct agents extends array
    method operator []= takes integer key, agent value returns nothing
        call SaveAgentHandle(ht, this, key, value)
    endmethod
endstruct
   
//! textmacro NEW_ARRAY_BASIC takes SUPER, FUNC, TYPE
private struct $TYPE$s extends array
    method operator [] takes integer key returns $TYPE$
        return Load$FUNC$(ht, this, key)
    endmethod
    method operator []= takes integer key, $TYPE$ value returns nothing
        call Save$FUNC$(ht, this, key, value)
    endmethod
    method has takes integer key returns boolean
        return HaveSaved$SUPER$(ht, this, key)
    endmethod
    method remove takes integer key returns nothing
        call RemoveSaved$SUPER$(ht, this, key)
    endmethod
endstruct
private module $TYPE$m
    method operator $TYPE$ takes nothing returns $TYPE$s
        return this
    endmethod
endmodule
//! endtextmacro
   
//! textmacro NEW_ARRAY takes FUNC, TYPE
private struct $TYPE$s extends array
    method operator [] takes integer key returns $TYPE$
        return Load$FUNC$Handle(ht, this, key)
    endmethod
    method operator []= takes integer key, $TYPE$ value returns nothing
        call Save$FUNC$Handle(ht, this, key, value)
    endmethod
endstruct
private module $TYPE$m
    method operator $TYPE$ takes nothing returns $TYPE$s
        return this
    endmethod
endmodule
//! endtextmacro
   
//Run these textmacros to include the entire hashtable API as wrappers.
//Don't be intimidated by the number of macros - Vexorian's map optimizer is
//supposed to kill functions which inline (all of these functions inline).
//! runtextmacro NEW_ARRAY_BASIC("Real", "Real", "real")
//! runtextmacro NEW_ARRAY_BASIC("Boolean", "Boolean", "boolean")
//! runtextmacro NEW_ARRAY_BASIC("String", "Str", "string")
   
//! runtextmacro NEW_ARRAY("Player", "player")
//! runtextmacro NEW_ARRAY("Widget", "widget")
//! runtextmacro NEW_ARRAY("Destructable", "destructable")
//! runtextmacro NEW_ARRAY("Item", "item")
//! runtextmacro NEW_ARRAY("Unit", "unit")
//! runtextmacro NEW_ARRAY("Ability", "ability")
//! runtextmacro NEW_ARRAY("Timer", "timer")
//! runtextmacro NEW_ARRAY("Trigger", "trigger")
//! runtextmacro NEW_ARRAY("TriggerCondition", "triggercondition")
//! runtextmacro NEW_ARRAY("TriggerAction", "triggeraction")
//! runtextmacro NEW_ARRAY("TriggerEvent", "event")
//! runtextmacro NEW_ARRAY("Force", "force")
//! runtextmacro NEW_ARRAY("Group", "group")
//! runtextmacro NEW_ARRAY("Location", "location")
//! runtextmacro NEW_ARRAY("Rect", "rect")
//! runtextmacro NEW_ARRAY("BooleanExpr", "boolexpr")
//! runtextmacro NEW_ARRAY("Sound", "sound")
//! runtextmacro NEW_ARRAY("Effect", "effect")
//! runtextmacro NEW_ARRAY("UnitPool", "unitpool")
//! runtextmacro NEW_ARRAY("ItemPool", "itempool")
//! runtextmacro NEW_ARRAY("Quest", "quest")
//! runtextmacro NEW_ARRAY("QuestItem", "questitem")
//! runtextmacro NEW_ARRAY("DefeatCondition", "defeatcondition")
//! runtextmacro NEW_ARRAY("TimerDialog", "timerdialog")
//! runtextmacro NEW_ARRAY("Leaderboard", "leaderboard")
//! runtextmacro NEW_ARRAY("Multiboard", "multiboard")
//! runtextmacro NEW_ARRAY("MultiboardItem", "multiboarditem")
//! runtextmacro NEW_ARRAY("Trackable", "trackable")
//! runtextmacro NEW_ARRAY("Dialog", "dialog")
//! runtextmacro NEW_ARRAY("Button", "button")
//! runtextmacro NEW_ARRAY("TextTag", "texttag")
//! runtextmacro NEW_ARRAY("Lightning", "lightning")
//! runtextmacro NEW_ARRAY("Image", "image")
//! runtextmacro NEW_ARRAY("Ubersplat", "ubersplat")
//! runtextmacro NEW_ARRAY("Region", "region")
//! runtextmacro NEW_ARRAY("FogState", "fogstate")
//! runtextmacro NEW_ARRAY("FogModifier", "fogmodifier")
//! runtextmacro NEW_ARRAY("Hashtable", "hashtable")
   
struct Table extends array
   
    // Implement modules for intuitive syntax (tb.handle; tb.unit; etc.)
    implement realm
    implement booleanm
    implement stringm
    implement playerm
    implement widgetm
    implement destructablem
    implement itemm
    implement unitm
    implement abilitym
    implement timerm
    implement triggerm
    implement triggerconditionm
    implement triggeractionm
    implement eventm
    implement forcem
    implement groupm
    implement locationm
    implement rectm
    implement boolexprm
    implement soundm
    implement effectm
    implement unitpoolm
    implement itempoolm
    implement questm
    implement questitemm
    implement defeatconditionm
    implement timerdialogm
    implement leaderboardm
    implement multiboardm
    implement multiboarditemm
    implement trackablem
    implement dialogm
    implement buttonm
    implement texttagm
    implement lightningm
    implement imagem
    implement ubersplatm
    implement regionm
    implement fogstatem
    implement fogmodifierm
    implement hashtablem
   
    method operator handle takes nothing returns handles
        return this
    endmethod
   
    method operator agent takes nothing returns agents
        return this
    endmethod
   
    //set this = tb[GetSpellAbilityId()]
    method operator [] takes integer key returns Table
        return LoadInteger(ht, this, key)
    endmethod
   
    //set tb[389034] = 8192
    method operator []= takes integer key, Table tb returns nothing
        call SaveInteger(ht, this, key, tb)
    endmethod
   
    //set b = tb.has(2493223)
    method has takes integer key returns boolean
        return HaveSavedInteger(ht, this, key)
    endmethod
   
    //call tb.remove(294080)
    method remove takes integer key returns nothing
        call RemoveSavedInteger(ht, this, key)
    endmethod
   
    //Remove all data from a Table instance
    method flush takes nothing returns nothing
        call FlushChildHashtable(ht, this)
    endmethod
   
    //local Table tb = Table.create()
    static method create takes nothing returns Table
        local Table this = dex.list[0]
       
        if this == 0 then
            set this = more + 1
            set more = this
        else
            set dex.list[0] = dex.list[this]
            call dex.list.remove(this) //Clear hashed memory
        endif
       
        debug set dex.list[this] = -1
        return this
    endmethod
   
    // Removes all data from a Table instance and recycles its index.
    //
    //     call tb.destroy()
    //
    method destroy takes nothing returns nothing
        debug if dex.list[this] != -1 then
            debug call BJDebugMsg("Table Error: Tried to double-free instance: " + I2S(this))
            debug return
        debug endif
       
        call this.flush()
       
        set dex.list[this] = dex.list[0]
        set dex.list[0] = this
    endmethod
   
    //! runtextmacro optional TABLE_BC_METHODS()
endstruct
   
//! runtextmacro optional TABLE_BC_STRUCTS()
   
struct TableArray extends array
   
    //Returns a new TableArray to do your bidding. Simply use:
    //
    //    local TableArray ta = TableArray[array_size]
    //
    static method operator [] takes integer array_size returns TableArray
        local Table tb = dex.size[array_size] //Get the unique recycle list for this array size
        local TableArray this = tb[0]         //The last-destroyed TableArray that had this array size
       
        debug if array_size <= 0 then
            debug call BJDebugMsg("TypeError: Invalid specified TableArray size: " + I2S(array_size))
            debug return 0
        debug endif
       
        if this == 0 then
            set this = less - array_size
            set less = this
        else
            set tb[0] = tb[this]  //Set the last destroyed to the last-last destroyed
            call tb.remove(this)  //Clear hashed memory
        endif
       
        set dex.size[this] = array_size //This remembers the array size
        return this
    endmethod
   
    //Returns the size of the TableArray
    method operator size takes nothing returns integer
        return dex.size[this]
    endmethod
   
    //This magic method enables two-dimensional[array][syntax] for Tables,
    //similar to the two-dimensional utility provided by hashtables them-
    //selves.
    //
    //ta[integer a].unit[integer b] = unit u
    //ta[integer a][integer c] = integer d
    //
    //Inline-friendly when not running in debug mode
    //
    method operator [] takes integer key returns Table
        static if DEBUG_MODE then
            local integer i = this.size
            if i == 0 then
                call BJDebugMsg("IndexError: Tried to get key from invalid TableArray instance: " + I2S(this))
                return 0
            elseif key < 0 or key >= i then
                call BJDebugMsg("IndexError: Tried to get key [" + I2S(key) + "] from outside TableArray bounds: " + I2S(i))
                return 0
            endif
        endif
        return this + key
    endmethod
   
    //Destroys a TableArray without flushing it; I assume you call .flush()
    //if you want it flushed too. This is a public method so that you don't
    //have to loop through all TableArray indices to flush them if you don't
    //need to (ie. if you were flushing all child-keys as you used them).
    //
    method destroy takes nothing returns nothing
        local Table tb = dex.size[this.size]
       
        debug if this.size == 0 then
            debug call BJDebugMsg("TypeError: Tried to destroy an invalid TableArray: " + I2S(this))
            debug return
        debug endif
       
        if tb == 0 then
            //Create a Table to index recycled instances with their array size
            set tb = Table.create()
            set dex.size[this.size] = tb
        endif
       
        call dex.size.remove(this) //Clear the array size from hash memory
       
        set tb[this] = tb[0]
        set tb[0] = this
    endmethod
   
    private static Table tempTable
    private static integer tempEnd
   
    //Avoids hitting the op limit
    private static method clean takes nothing returns nothing
        local Table tb = .tempTable
        local integer end = tb + 0x1000
        if end < .tempEnd then
            set .tempTable = end
            call ForForce(bj_FORCE_PLAYER[0], function thistype.clean)
        else
            set end = .tempEnd
        endif
        loop
            call tb.flush()
            set tb = tb + 1
            exitwhen tb == end
        endloop
    endmethod
   
    //Flushes the TableArray and also destroys it. Doesn't get any more
    //similar to the FlushParentHashtable native than this.
    //
    method flush takes nothing returns nothing
        debug if this.size == 0 then
            debug call BJDebugMsg("TypeError: Tried to flush an invalid TableArray instance: " + I2S(this))
            debug return
        debug endif
        set .tempTable = this
        set .tempEnd = this + this.size
        call ForForce(bj_FORCE_PLAYER[0], function thistype.clean)
        call this.destroy()
    endmethod
   
endstruct
   
endlibrary

/**************************************************************
*
*   RegisterPlayerUnitEvent
*   v5.1.0.1
*   By Magtheridon96
*
*   I would like to give a special thanks to Bribe, azlier
*   and BBQ for improving this library. For modularity, it only
*   supports player unit events.
*
*   Functions passed to RegisterPlayerUnitEvent must either
*   return a boolean (false) or nothing. (Which is a Pro)
*
*   Warning:
*   --------
*
*       - Don't use TriggerSleepAction inside registered code.
*       - Don't destroy a trigger unless you really know what you're doing.
*
*   API:
*   ----
*
*       - function RegisterPlayerUnitEvent takes playerunitevent whichEvent, code whichFunction returns nothing
*           - Registers code that will execute when an event fires.
*       - function RegisterPlayerUnitEventForPlayer takes playerunitevent whichEvent, code whichFunction, player whichPlayer returns nothing
*           - Registers code that will execute when an event fires for a certain player.
*       - function GetPlayerUnitEventTrigger takes playerunitevent whichEvent returns trigger
*           - Returns the trigger corresponding to ALL functions of a playerunitevent.
*
**************************************************************/
library RegisterPlayerUnitEvent // Special Thanks to Bribe and azlier
    globals
        private trigger array t
    endglobals
   
    function RegisterPlayerUnitEvent takes playerunitevent p, code c returns nothing
        local integer i = GetHandleId(p)
        local integer k = 15
        if t[i] == null then
            set t[i] = CreateTrigger()
            loop
                call TriggerRegisterPlayerUnitEvent(t[i], Player(k), p, null)
                exitwhen k == 0
                set k = k - 1
            endloop
        endif
        call TriggerAddCondition(t[i], Filter(c))
    endfunction
   
    function RegisterPlayerUnitEventForPlayer takes playerunitevent p, code c, player pl returns nothing
        local integer i = 16 * GetHandleId(p) + GetPlayerId(pl)
        if t[i] == null then
            set t[i] = CreateTrigger()
            call TriggerRegisterPlayerUnitEvent(t[i], pl, p, null)
        endif
        call TriggerAddCondition(t[i], Filter(c))
    endfunction
   
    function GetPlayerUnitEventTrigger takes playerunitevent p returns trigger
        return t[GetHandleId(p)]
    endfunction
endlibrary


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
library SpellEffectEvent requires RegisterPlayerUnitEvent, optional Table
 
//============================================================================
private module M
   
    static if LIBRARY_Table then
        static Table tb
    else
        static hashtable ht = InitHashtable()
    endif
   
    static method onCast takes nothing returns nothing
        static if LIBRARY_Table then
            call TriggerEvaluate(.tb.trigger[GetSpellAbilityId()])
        else
            call TriggerEvaluate(LoadTriggerHandle(.ht, 0, GetSpellAbilityId()))
        endif
    endmethod
 
    private static method onInit takes nothing returns nothing
        static if LIBRARY_Table then
            set .tb = Table.create()
        endif
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
    endmethod
endmodule
 
//============================================================================
private struct S extends array
    implement M
endstruct
 
//============================================================================
function RegisterSpellEffectEvent takes integer abil, code onCast returns nothing
    static if LIBRARY_Table then
        if not S.tb.handle.has(abil) then
            set S.tb.trigger[abil] = CreateTrigger()
        endif
        call TriggerAddCondition(S.tb.trigger[abil], Filter(onCast))
    else
        if not HaveSavedHandle(S.ht, 0, abil) then
            call SaveTriggerHandle(S.ht, 0, abil, CreateTrigger())
        endif
        call TriggerAddCondition(LoadTriggerHandle(S.ht, 0, abil), Filter(onCast))
    endif
endfunction
 
endlibrary

library IsDestructableTree uses optional UnitIndexer /* v1.3.1
*************************************************************************************
*
*   Detect whether a destructable is a tree or not.  
*
***************************************************************************
*
*   Credits
*
*       To PitzerMike
*       -----------------------
*
*           for IsDestructableTree
*
*************************************************************************************
*
*    Functions
*
*       function IsDestructableTree takes destructable d returns boolean
*
*       function IsDestructableAlive takes destructable d returns boolean
*
*       function IsDestructableDead takes destructable d returns boolean
*
*       function IsTreeAlive takes destructable tree returns boolean
*           - May only return true for trees.          
*
*       function KillTree takes destructable tree returns boolean
*           - May only kill trees.
*
*/
    globals
        private constant integer HARVESTER_UNIT_ID = 'hpea'//*  human peasant
        private constant integer HARVEST_ABILITY   = 'Ahrl'//*  ghoul harvest
        private constant integer HARVEST_ORDER_ID  = 0xD0032//* harvest order ( 852018 )
        private constant player  NEUTRAL_PLAYER    = Player(PLAYER_NEUTRAL_PASSIVE)
        private unit harvester                     = null
    endglobals
    function IsDestructableTree takes destructable d returns boolean
        //*  851973 is the order id for stunned, it will interrupt the preceding harvest order.
        return (IssueTargetOrderById(harvester, HARVEST_ORDER_ID, d)) and (IssueImmediateOrderById(harvester, 851973))
    endfunction
    function IsDestructableDead takes destructable d returns boolean
        return (GetWidgetLife(d) <= 0.405)
    endfunction
    function IsDestructableAlive takes destructable d returns boolean
        return (GetWidgetLife(d) > .405)
    endfunction
    function IsTreeAlive takes destructable tree returns boolean
        return IsDestructableAlive(tree) and IsDestructableTree(tree)
    endfunction
    function KillTree takes destructable tree returns boolean
        if (IsTreeAlive(tree)) then
            call KillDestructable(tree)
            return true
        endif
        return false
    endfunction
    private function Init takes nothing returns nothing
        static if LIBRARY_UnitIndexer then//*  You may adapt this to your own indexer.
            set UnitIndexer.enabled = false
        endif
        set harvester = CreateUnit(NEUTRAL_PLAYER, HARVESTER_UNIT_ID, 0, 0, 0)
        static if LIBRARY_UnitIndexer then
            set UnitIndexer.enabled = true
        endif
        call UnitAddAbility(harvester, HARVEST_ABILITY)
        call UnitAddAbility(harvester, 'Aloc')
        call ShowUnit(harvester, false)
    endfunction
    //*  Seriously?
    private module Inits
        private static method onInit takes nothing returns nothing
            call Init()
        endmethod
    endmodule
    private struct I extends array
        implement Inits
    endstruct
    
endlibrary

library DummyCaster /* v2.0.0.1
*************************************************************************************
*
*   Dummy caster for casting spells
*
*   Spells must have 0 cooldown, 92083 range, and cost 0 mana. Spells must be instant and
*   can't share the same order as other spells on the dummy caster.
*
*************************************************************************************
*
*   */uses/*
*       */ optional UnitIndexer /*       hiveworkshop.com/forums/jass-functions-413/unit-indexer-172090/
*
************************************************************************************
*   SETTINGS
*/
globals
    constant integer UNITS_DUMMY_CASTER = 'dcst'
   
    /*************************************************************************************
    *
    *                                   PLAYER_OWNER
    *
    *   Owner of dummy caster
    *
    *************************************************************************************/
    private constant player PLAYER_OWNER = Player(15)
endglobals
/*
************************************************************************************
*
*   Dummy at position 32256,32256
*
*    struct DummyCaster extends array
*
*       method cast takes player castingPlayer, integer abilityLevel, integer order, real x, real y returns boolean
*           -   call DummyCaster[abilityId].cast(...)
*       method castTarget takes player castingPlayer, integer abilityLevel, integer order, widget t returns boolean
*           -   call DummyCaster[abilityId].castTarget(...)
*       method castPoint takes player castingPlayer, integer abilityLevel, integer order, real x, real y returns boolean
*           -   call DummyCaster[abilityId].castPoint(...)
*
************************************************************************************/
    globals
        private unit u
    endglobals
    private module N
        private static method onInit takes nothing returns nothing
            static if LIBRARY_UnitIndexer then
                set UnitIndexer.enabled=false
                set u=CreateUnit(PLAYER_OWNER,UNITS_DUMMY_CASTER,0,0,0)
                set UnitIndexer.enabled=true
            else
                set u=CreateUnit(PLAYER_OWNER,UNITS_DUMMY_CASTER,0,0,0)
            endif
            call SetUnitPosition(u,32256,32256)
        endmethod
    endmodule
    struct DummyCaster extends array
        implement N
        private static method prep takes integer a, player p, integer l returns nothing
            call UnitAddAbility(u, a)
            if (1 < l) then
                call SetUnitAbilityLevel(u, a, l)
            endif
            if (null != p) then
                call SetUnitOwner(u, p, false)
            endif
        endmethod
        private static method finish takes integer a returns nothing
            call SetUnitOwner(u, PLAYER_OWNER, false)
            call UnitRemoveAbility(u, a)
        endmethod
        method cast takes player p, integer level, integer order, real x, real y returns boolean
            local boolean b
            call SetUnitX(u, x)
            call SetUnitY(u, y)
            call prep(this, p, level)
            set b = IssueImmediateOrderById(u,order)
            call finish(this)
            call SetUnitPosition(u, 32256, 32256)
            return b
        endmethod
        method castTarget takes player p, integer level, integer order, widget t returns boolean
            local boolean b
            call prep(this, p, level)
            set b = IssueTargetOrderById(u,order,t)
            call finish(this)
            return b
        endmethod
        method castPoint takes player p, integer level, integer order, real x, real y returns boolean
            local boolean b
            call prep(this, p, level)
            set b = IssuePointOrderById(u,order,x,y)
            call finish(this)
            return b
        endmethod
    endstruct
endlibrary


library MissileRecycler initializer PreInit requires optional UnitIndexer, optional UnitDex, optional UnitIndexerGUI /*

    MissileRecycler v 1.4.5.2
    =========================================================================
    Credits:
    -------------------------------------------------------------------------
    Written by Bribe
    Vexorian, Anitarf and iNfraNe for the dummy.mdx model file
    Nestharus for the Queue data structure and for finding that paused units
        consume very few CPU resources.

=========================================================================
    Introduction:
    -------------------------------------------------------------------------
    Recycling dummy units is important because the CreateUnit call is one of,
    if not the, most processor-intensive native in the entire game. Creating
    just a couple dozen dummy units in a single thread causes a visible frame
    glitch for that instant. The overhead is even higher if you are using a
    Unit Indexing library in the map which causes some extra evaluations per
    new unit.

    There are also reports of removed units leaving a little trail of RAM
    surplus in their wake. I have not been able to reproduce this so I don't
    know how serious it is.

    I was motivated to create this system because removed units might be un-
    safe in very large numbers and CreateUnit is a very heavy process.

    The thing that makes this system different than others is the fact that
    it considers the facing angle of the dummies being recycled, which I have
    never seen another system even attempt before this. Since then,
    MissileRecycler has inspired Anitarf to update XE with the same angle-retaining
    capability and Nestharus has created Dummy. Considering the facing angle is
    important because it takes 0.73 seconds for the unit to turn around,
    which - when overlooked - looks especially weird if you are creating a unit-trail
    or if you are shooting arrow-shaped objects as projectiles. For fireball effects or
    effects that generally don't depend on facing angle, this system would be
    a bit wasteful.

    With default settings and the worst-case-scenario, it will take 0.09 seconds for
    the projectile to turn to the angle you need. This is 1/8 of the normal worst case
    scenario if you weren't recycling dummies considering facing. On average, it takes
    roughly 0.045 seconds to turn to the angle you need (which is not noticable).
    However, I have made this completely configurable and you are
    able to change the values to whatever needs you have.

    =========================================================================
    Calibration Guide:
    -------------------------------------------------------------------------
    The thing that surprised me the most about this system was, no matter how
    complex it turned out, it became very configurable. So I should let you
    know what the constants do so you know if/how much you want to modify.
  
    constant real DEATH_TIME = 2.0 //seconds

    - Should not be less than the maximum time a death animation needs to play.
    Should not be lower than .73 to ensure enough time to turn.
    Should not be too high otherwise the dummies will take too long to recycle.

    constant integer ANG_N = 8

    -   How many different angles are recognized by the system. Don't do
    360 different angles because then you're going to have thousands of dummy
    units stored and that's ridiculous, the game lags enough at 1000 units.
    Increasing ANG_N increases realism but decreases the chance that a dummy
    unit will be available to be recycled. I don't recommend making this any
    lower, and the max I'd recommend would be 16.

    constant integer ANG_STORAGE_MAX = 12

    -   How many dummy units are stored per angle. This limit is important
    because you might have a spike at one point in the game where many units
    are created, which could result in too high of a dummy population.
        In general, I advise that the product of ANG_N x ANG_STORAGE_MAX does
    not exceed 100 or 200. More than that is excessive, but you can
    hypothetically have it up to 8190 if Warcraft 3's memory management
    were better.
  
        Preloads ANG_N x ANG_STORAGE_MAX dummy units. Preloading dummies is
    useful as it dumps a lot of CreateUnit calls in initialization where you
    won't see a frame glitch. In the 1.4 update, preloading is done 0 seconds
    into the game to ensure any Indexers have already initialized.

    private function ToggleIndexer takes boolean flag returns nothing
    -   Put what you need in here to disable/enable any indexer in your
    map. if flag is true, enable indexer. If false, disable.

    =========================================================================
    API Guide:
    -------------------------------------------------------------------------
    You obviously need some functions so you can get a recycled dummy unit or
    recycle it. Therefore I provide these:

    function GetRecycledMissile
        takes real x, real y, real z, real facing
            returns unit

        Returns a new dummy unit that acts as a projectile missile. The args
        are simply the last three arguments you'd use for a CreateUnit call,
        with the addition of a z parameter to represent the flying height -
        it isn't the absolute z but relative to the ground because it uses
        SetUnitFlyHeight on that value directly.

    function RecycleMissile
        takes unit u
            returns nothing

        When you are done with that dummy unit, recycle it via this function.
        This function is pretty intelligent and resets that unit's animation
        and its facing angle so you don't have to.
*/
    //=======================================================================
    // Save the map, then delete the exclaimation mark in the following line.
    // Make sure that you don't have an object in your map with the rawcode
    // 'dumi' and also configure the model path (war3mapImported\dummy.mdl)
    // to the dummy.mdx model created by Vexorian.
    // ObjectMerger disabled: dumi is supplied by the TerrainDev object-data build.

    //Thanks to Vexorian that Optimizer 5.0 no longer kills natives
    native UnitAlive takes unit id returns boolean

    globals
        //-------------------------------------------------------------------
        // You must configure the dummy unit with the one created from the
        // ObjectMerger statement above.
        //
        private constant integer DUMMY_ID = 'dumi'      //The rawcode of the dummy unit.
        private          player  OWNER    = Player(bj_PLAYER_NEUTRAL_EXTRA)  //The owner of the dummy unit.

        private constant integer ANG_N = 8              //# of indexed angles. Higher value increases realism but decreases recycle frequency.
        private constant integer ANG_STORAGE_MAX = 12   //Max dummies per indexed angle. I recommend lowering this if you increase ANG_N.

        private constant real DEATH_TIME = 2. //Allow the special effect on
        //the unit to complete its "death" animation in this timeframe. Must
        //be higher than 0.74 seconds to allow the unit time to turn. This
        //number should not be lower than the maximum death-animation time of
        //your missile-units' effect attachments, just to be safe.
    endglobals

    private function ToggleIndexer takes boolean flag returns nothing
        static if LIBRARY_UnitIndexer then
            set UnitIndexer.enabled = flag
        elseif LIBRARY_UnitIndexerGUI then
            set udg_UnitIndexerEnabled = flag
        elseif LIBRARY_UnitDex then
            set UnitDex.Enabled = flag
        endif
    endfunction

    globals
        private constant integer ANG_VAL = 360 / ANG_N //Generate angle value from ANG_N.
        private constant integer ANG_MID = ANG_VAL / 2 //The middle value of angle value.

        //Misc vars
        private unit array stack       //Recycled dummy units.
        private real array timeStamp   //Prevents early recycling of units.
        private integer array queueNext
        private integer array queueLast
        private integer recycle = 0
        private timer gameTime  = CreateTimer() //Used for visual continuity.
        private integer array queueStack
        private integer queueStackN = 0 //Used to avoid searching the queues.
    endglobals

    static if DEBUG_MODE then
        private function Print takes string s returns nothing
            //Un-comment this next line if you want to know how the system works:
            //call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 999, "[MissileRecycler] " + s)
        endfunction
    endif

    //=======================================================================
    // Get a recycled dummy missile unit. If there are no recycled dummies
    // that are already facing the angle you need, it creates a new dummy for
    // you.
    //
    function GetRecycledMissile takes real x, real y, real z, real facing returns unit
        local integer i = ModuloInteger(R2I(facing), 360) / ANG_VAL
        local integer this = queueNext[i]
        local unit u
        if this != 0 and TimerGetElapsed(gameTime) >= timeStamp[this] then
            //Dequeue this
            set queueNext[i] = queueNext[this]
            if queueNext[i] == 0 then
                set queueLast[i] = i
            endif
            //Recycle this index
            set queueLast[this] = recycle
            set recycle = this
            //Add queue index to available stack
            set queueStack[queueStackN] = i
            set queueStackN = queueStackN + 1
            //Old unit will return as new
            set u = stack[this]
            call SetUnitFacing(u, facing)
            call SetUnitUserData(u, 0)
            //Reset the dummy's properties.
            call SetUnitVertexColor(u, 255, 255, 255, 255)
            call SetUnitAnimationByIndex(u, 90)
            call SetUnitScale(u, 1, 0, 0)
            //call PauseUnit(u, false) -- you can disable "resets" that you don't need to worry about.
            debug call Print("Recycling")
        else
            debug call Print("Creating new")
            call ToggleIndexer(false)
            set u = CreateUnit(OWNER, DUMMY_ID, x, y, facing)
            call ToggleIndexer(true)
            call PauseUnit(u, true)
        endif
        call SetUnitX(u, x)
        call SetUnitY(u, y)
        call SetUnitFlyHeight(u, z, 0)
        set bj_lastCreatedUnit = u
        set u = null
        return bj_lastCreatedUnit
    endfunction

    //=======================================================================
    // You should recycle the dummy missile unit when its job is done.
    //
    function RecycleMissile takes unit u returns nothing
        local integer i
        local integer this = recycle
        if GetUnitTypeId(u) == DUMMY_ID and UnitAlive(u) and GetUnitUserData(u) != -1 then
            if queueStackN == 0 then
                debug call Print("Stack is full - removing surplus unit")
                call UnitApplyTimedLife(u, 'BTLF', DEATH_TIME)
                return
            endif
            //Recycle this
            set recycle = queueLast[this]
            //Index the dummy unit to an available facing angle.
            //Get the last vacant angle index.
            set queueStackN = queueStackN - 1
            set i = queueStack[queueStackN]
            //Enqueue this
            set queueNext[queueLast[i]] = this
            set queueLast[i] = this
            set queueNext[this] = 0
            //Allow a time barrier for the effect to destroy/turn to complete.
            set timeStamp[this] = TimerGetElapsed(gameTime) + DEATH_TIME
            set stack[this] = u
            call SetUnitFacing(u, i * ANG_VAL + ANG_MID)
            call SetUnitOwner(u, OWNER, false)
            //Prevent double-free of this unit.
            call SetUnitUserData(u, -1)
        debug else
            debug call BJDebugMsg("[MissileRecycler] Error: Attempt to recycle invalid unit.")
        endif
    endfunction

    //=======================================================================
    // I didn't need this function after all
    //
    function RecycleMissileDelayed takes unit u, real r returns nothing
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
    private function Init takes nothing returns nothing
        local integer end
        local integer i = ANG_N
        local integer n = i
        local integer angle
        local real x = GetRectMaxX(bj_mapInitialPlayableArea)
        local real y = GetRectMaxY(bj_mapInitialPlayableArea)
        local unit u
        call ToggleIndexer(false)
        loop
            set i = i - 1
            set queueNext[i] = n
            set angle = i * ANG_VAL + ANG_MID
            set end = n + ANG_STORAGE_MAX
            set queueLast[i] = end - 1
            loop
                set queueNext[n] = n + 1
                set u = CreateUnit(OWNER, DUMMY_ID, x, y, angle)
                set stack[n] = u
                call PauseUnit(u, true)
                call SetUnitUserData(u, -1)
                set n = n + 1
                exitwhen n == end
            endloop
            set queueNext[n - 1] = 0
            exitwhen i == 0
        endloop
        call ToggleIndexer(true)
        call TimerStart(gameTime, 1000000., false, null)
        set u = null
    endfunction

    private function PreInit takes nothing returns nothing
        static if LIBRARY_UnitIndexerGUI then
            call OnUnitIndexerInitialized(function Init)
        else
            call Init()
        endif
    endfunction

endlibrary

library Missile /* version 2.5.1
*************************************************************************************
*
*   Creating custom projectiles in Warcraft III.
*   
*   Major goal: 
*       No unessary external requirements. 
*       Implements code optional.
*   
*   Philosophy:
*       I want that feature --> Compiler writes that code into your map script.
*       I don't want that   --> Compiler ignores that code completly.
*
*   Important:
*       Take yourself 2 minutes time to setup Missile correctly. 
*       Otherwise I can't guarantee, that Missile works the way you want.
*       Once the setup is done, you can check out some examples and Missile will be easy
*       to use for everyone. I promise it. 
*
*       Do the setup at: 
*
*           1.) Import instruction  
*           2.) Global configuration
*           3.) Function configuration       
*   
*   Credits to Dirac, emjlr3, AceHart, Bribe, Wietlol, 
*              Nestharus, Maghteridon96, Vexorian and Zwiebelchen.
*
*************************************************************************************
*
*   */ requires /*
*
*       - Missile requires nothing.
*
*************************************************************************************
*
*   Optional requirements listed can reduce overall code generation,
*   add safety mechanisms, decrease overhead and optimize handle management.  
*   For a better overview I put them into blocks.
*
*   I recommend to use at least one per block in your map.
*       
*   a) For best debug results: ( Useful )
*       */ optional ErrorMessage    /* github.com/nestharus/JASS/tree/master/jass/Systems/ErrorMessage  
*   
*   b) Fatal error protection: ( Case: unit out moves of world bounds )   
*           - WorldBounds is safer than BoundSentinel.
*           - WorldBounds adds more overhead than BoundSentinel.
*           - Using none of these two forces Missile to switch from SetUnitX/Y to the SetUnitPosition native.
*       */ optional WorldBounds     /* githubusercontent.com/nestharus/JASS/master/jass/Systems/WorldBounds/script.j
*       */ optional BoundSentinel   /* wc3c.net/showthread.php?t=102576
*       
*   c) Handle recycling: ( Performace gain, memory management )
*           - uses MissileRecylcer > Dummy > xedummy. 
*       */ optional MissileRecycler /* hiveworkshop.com/forums/jass-resources-412/system-missilerecycler-206086/
*       */ optional Dummy           /* github.com/nestharus/JASS/blob/master/jass/Systems/Dummy/Dummy.w3x
*       */ optional xedummy         /* wc3c.net/showthread.php?t=101150
*
*   d) Unit indexing: ( Avoid an onIndex event )
*           - not required for Missile. Only if you use one already.
*       */ optional UnitIndexer     /* github.com/nestharus/JASS/tree/master/jass/Systems/Unit%20Indexer
*
************************************************************************************
*
*   1. Import instruction
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       • Copy Missile into to your map. 
*       • You need a dummy unit, using Vexorians "dummy.mdx".
*         This unit must use the locust and crow form ability. ( Aloc & Amrf )
*                   ¯¯¯¯
*
*   2. Global configuration   
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       Seven constants to setup!
*/
    globals
    
        /**
        *   Missiles are moved periodically. An interval of 1./32. is recommended.
        *       • Too short timeout intervals may cause performance issues.
        *       • Too large timeout intervals may look fishy.
        */
        public constant real TIMER_TIMEOUT                        = 1./32.
        
        /**
        *   Owner of all Missile dummies. Should be a neutral player in your map.
        */ 
        public constant player NEUTRAL_PASSIVE                    = Player(15)
        
        /**
        *   Raw code of the dummy unit. Object Editor ( F6 )
        *       • Must be correct, otherwise missile dummies can neither be recycled nor destroyed.
        *       • Units of other type ids will not be thrown into the recycler bin.
        */
        public constant integer DUMMY_UNIT_ID                     = 'dumi'
    
        /**
        *   The maximum collision size used in your map. If unsure use 197. ( Town hall collision )
        *       • Applies for all types of widgets.
        *       • A precise value can improve Missile's performance,
        *         since smaller values enumerate less widgtes per loop per missile.
        */
        public constant real MAXIMUM_COLLISION_SIZE               = 197.
        
        /**
        *   Collision types for missiles. ( Documentation only )
        *   Missile decides internally each loop which type of collision is required.
        *       • Uses circular collision dectection for speed < collision. ( Good accuracy, best performance )
        *       • Uses rectangle collision for speed >= collision. ( Best accuracy, normal performance )
        */
        public constant integer COLLISION_TYPE_CIRCLE     = 0 
        public constant integer COLLISION_TYPE_RECTANGLE  = 1 
    
        /**
        *   Determine when rectangle collision is required to detect nearby widgets. 
        *       • The smaller the factor the earlier rectangle collision is used. ( by default 1. ) 
        *       • Formula: speed >= collision*Missile_COLLISION_ACCURACY_FACTOR
        */
        public constant real    COLLISION_ACCURACY_FACTOR = 1. 
    
// Optional toogles:
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//      Set booleans listed below to "true" and the compiler will write 
//      the feature into your map. Otherwise this code is completly ignored.                                        
//          • Yay, I want that           --> "true"
//          • Naah that's useless for me --> "false"
        
        /**
        *   USE_COLLISION_Z_FILTER enables z axis checks for widget collision. ( Adds minimal overhead ) 
        *   Use it when you need:
        *       • Missiles flying over or under widgets.
        *       • Determine between flying and walking units.
        */
        public constant boolean USE_COLLISION_Z_FILTER             = true
        
        /**
        *   WRITE_DELAYED_MISSILE_RECYCLING enables a delayed dummy recycling system. ( Very recommended )
        *   Use it if:
        *       • You use a dummy recycling library like MissileRecycler, Dummy or xedummy.
        *       • You want to properly display death animations of effects added to missiles.
        */
        public constant boolean WRITE_DELAYED_MISSILE_RECYCLING    = true
        
        /**
        *   DELAYED_MISSILE_DEATH_ANIMATION_TIME is the delay in seconds
        *   Missile holds back a dummy, before recycling it.
        *       • The time value does not have to be precise.
        *       • Requires WRITE_DELAYED_MISSILE_RECYCLING = true 
        */
        private constant real DELAYED_MISSILE_DEATH_ANIMATION_TIME = 2.

        /**
        *   USE_DESTRUCTABLE_FILTER and USE_ITEM_FILTER are redundant constants from previous Missile versions.
        *   They do nothing, but remain for backwards compatibilty.
        *   From Missile version 1.5 on all widget collisions are always enabled.
        */
        public constant boolean USE_DESTRUCTABLE_FILTER            = true
        public constant boolean USE_ITEM_FILTER                    = true
    endglobals
/*    
*  3. Function configuration   
*  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       Four functions to setup!
*/
    /**
    *   GetUnitBodySize(unit) returns a fictional value for z - axis collision.
    *   You have two options:
    *       • One constant value shared over all units. 
    *       • Dynamic values based on handle id, type id, unit user data, scaling or other parameters.
    */
    function GetUnitBodySize takes unit whichUnit returns real
        return 100.// Other example: return LoadReal(hash, GetHandleId(whichUnit), KEY_UNIT_BODY_SIZE)
    endfunction

    /**
    *   Same as GetUnitBodySize, but for destructables.
    *   Using occluder height is an idea of mine. Of course you can use your own values.
    */
    function GetDestructableHeight takes destructable d returns real
        return GetDestructableOccluderHeight(d)// Other example: return 100.
    endfunction

    /**
    *   Same as GetUnitBodySize, but for items.
    *   Again it's up to you to figure out a fictional item height.
    */
    function GetItemHeight takes item i returns real
        return 16.
    endfunction
    
    /**
    *   Unit indexers and missiles ( Only if you don't use a dummy recycling library )
    *   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    *   It is most likely intended that projectiles don't run through a unit indexing process.
    *   ToogleUnitIndexer runs:
    *       • Directly before a dummy is created.
    *       • Directly after dummy unit creation.
    *
    *   Please return the previous setup of your indexing tool ( enabled, disabled ),
    *   so Missile can properly reset it to the original state.
    */
    private function ToogleUnitIndexer takes boolean enable returns boolean
        local boolean prev = true//UnitIndexer.enabled
        // set UnitIndexer.enabled = enable
        return prev
    endfunction
    
/**  
*   4. API
*   ¯¯¯¯¯¯
*/
//! novjass ( Disables the compiler until the next endnovjass )

        // Custom type Missile for your projectile needs.
        struct Missile extends array

        // Constants:
        // ==========
            //
            readonly static constant string ORIGIN = "origin"
            //  • Attach point name for fxs on dummies.

            readonly static constant real   HIT_BOX = (2./3.)
            //  • Fictional hit box for homing missiles.
            //    while 0 would be the toe and 1 the head of a unit.
            
        // Available creators:
        // ===================
            // 
            static method createEx takes unit missileDummy, real impactX, real impactY, real impactZ returns Missile
            //  • Core creator method.
            //  • May launches any unit. 
            //  • Units of type Missile_DUMMY_UNIT_ID get recycled in the end.
            
            static method create takes real x, real y, real z, real angleInRadians, real distanceToTravel, real endZ returns Missile
            //  • Converts arguments to fit into createEx, then calls createEx.

            static method createXYZ takes real x, real y, real z, real impactX, real impactY, real impactZ returns Missile
            //  • Converts arguments to fit into createEx, then calls createEx. 
            
        // Available destructors:
        // ======================
            //
            return true
            //  • Core destructor.
            //  • Returning true in any of the interface methods of the MissileStruct module
            //    will destroy that instance instantly.
            
            method destroy   takes nothing returns nothing
            //  • Destroys the missile during the next timer callback. 
            
            method terminate takes nothing returns nothing
            //  • Destroys the missile instantly. 
            
        // Fields you can set and read directly:
        // =====================================
            //
            unit       source
            unit       target      // For homing missiles.
            real       distance    // Distance traveled.
            player     owner       // Pseudo owner for faster onCollide evaluation. The proper dummy owner remains PLAYER_NEUTRAL_PASSIVE.
            real       speed       // Vector lenght for missile movement in plane x / y. ( DOES NOT TAKE THE TIMER TIMEOUT IN ACCOUNT )
            real       acceleration
            real       damage
            real       turn        // Set a turn rate for missiles.
            integer    data        // For data transfer set and read data.  
            boolean    recycle     // Is automatically set to true, when a Missile reaches it's destination.
            boolean    wantDestroy // Set wantDestroy to true, to destroy a missile during the next timer callback.
            
            // Neither collision nor collisionZ accept values below zero.
            real       collision   // Collision size in plane x / y.
            real       collisionZ  // Collision size in z - axis. ( deprecated )
            
        // Fields you can only read:
        // =========================      
            //
            readonly boolean         allocated        
            readonly unit            dummy// The dummy unit of this missile.
        
            // Position members for you needs.
            readonly MissilePosition origin// Grants access to readonly members of MissilePosition,
            readonly MissilePosition impact// which are "x", "y", "z", "angle", "distance", "slope" and the pitch angle "alpha". 
                                           // Furthermore method origin.move(x, y, z) and impact.move(x, y, z).
            readonly real            terrainZ
            readonly real            x
            readonly real            y
            readonly real            z
            readonly real            angle// Current angle in radians.

        // Method operators for set and read:
        // ==================================
            //
            method operator model= takes string modelFile returns nothing
            method operator model  takes nothing returns string
            //  • Adds an effect handle on a missile dummy to it's "origin".
            //  • You can read the file path.
            //  • For multiple effects access "this.dummy" in your struct.
             
            method operator scale= takes real value returns nothing
            method operator scale  takes nothing returns real
            //  • Set and read the scaling of the dummy unit.  
            
            method operator curve= takes real value returns nothing
            method operator curve  takes nothing returns real
            //  • Enables curved movement for your missile. ( Pass in radians, NOT degrees )
            //  • Do not pass in PI/2.
       
            method operator arc=   takes real value returns nothing
            method operator arc    takes nothing returns real
            //  • Enables arcing movement for your missile. ( Pass in radians, NOT degrees )
            //  • Do not pass in PI/2.
                        
        // Methods for missile movement:
        // =============================
            //
            method bounce           takes nothing returns nothing
            //  • Moves the MissilePosition "origin" to the current missile coordinates.
            //  • Resets the distance traveled to 0.
            
            method deflect          takes real tx, real ty returns nothing
            //  • Deflect the missile towards tx, ty. Then calls bounce.        
            
            method deflectEx        takes real tx, real ty, real tz returns nothing
            //  • Deflect the missile towards tx, ty, tz. Then calls bounce.
    
            method flightTime2Speed takes real duration returns nothing
            //  • Converts a fly time to a vector lenght for member "speed".
            //  • Does not take acceleration into account. ( Disclaimer )
        
            method setMovementSpeed takes real value returns nothing
            //  • Converts Warcraft III movement speed to a vector lenght for member "speed".
       
        // Methods for missile collision: ( all are hashtable entries )
        // ==============================
            // By default a widget can only be hit once per missile.
            //
            method hitWidget        takes widget w returns nothing
            //  • Saves a widget in the memory as hit by this instance.
        
            method hasHitWidget     takes widget w returns boolean
            //  • Returns true, if "w" has been hit by this instance.
        
            method removeHitWidget  takes widget w returns nothing
            //  • Removes a widget from this missile's memory for widget collision. ( Can hit "w" again )
            
            method flushHitWidgets  takes nothing returns nothing
            //  • Flushes a missile's memory for widget collision. ( All widgets can be hit again )
            
            method enableHitAfter   takes widget w, real seconds returns nothing
            //  • Automatically calls removeHitWidget(w) after "seconds" time. ( Can hit "w" again after given time )
            
        // Module MissileStruct:
        // =====================
            //
            module MissileLaunch // ( optional )
            module MissileStruct
            //  • Enables the entire missile interface for that struct.
            
        // Interface in structs: ( Must implement module MissileStruct ) 
        // =====================
            // 
            //  • Write one, many or all of the static method below into your struct.
            //  • Missiles launched in this struct will run those methods, when their events fire.
            //
            //  • All of those static methods must return a boolean. 
            //      a) return true  --> destroys the missile instance instantly.
            //      b) return false --> keep on flying.

        // Available static method:  
        // ========================
            //
            static method onCollide            takes Missile missile, unit hit returns boolean
            //  • Runs for units in collision range of a missile.

            static method onDestructable       takes Missile missile, destructable hit returns boolean
            //  • Runs for destructables in collision range of a missile.

            static method onItem               takes Missile missile, item hit returns boolean
            //  • Runs for items in collision range of a missile.
            
            static method onTerrain takes Missile missile returns boolean
            //  • Runs when a missile collides with the terrain. ( Ground and cliffs )
            
            static method onFinish  takes Missile missile returns boolean
            //  • Runs only when a missile reaches it's destination. 
            //  • However does not run, if a Missile is destroyed in another method. 
            
            static method onPeriod  takes Missile missile returns boolean
            //  • Runs every Missile_TIMER_TIMEOUT seconds.

            static method onRemove takes Missile missile returns boolean
            //  • Runs when a missile is destroyed. 
            //  • Unlike onFinish, onRemove will runs ALWAYS when a missile is destroyed!!!
            //  
            //  For onRemove the returned boolean has a unique meaning:
            //  • Return true will recycle this missile delayed. ( Only if WRITE_DELAYED_MISSILE_RECYCLING = true )
            //  • Return false will recycle this missile right away.
            
            static method launch takes Missile toLaunch returns nothing
            //  • Well ... Launches this Missile.
            //  • Missile "toLaunch" will behave as declared in the struct. ( static methods from above )
            
    // Misc: ( From the global setup )
    // =====
        //
        // Constants:
        // ==========
            //
            public constant real    TIMER_TIMEOUT                 
            public constant player  NEUTRAL_PASSIVE             
            public constant integer DUMMY_UNIT_ID                
            public constant real    MAXIMUM_COLLISION_SIZE          
            public constant boolean USE_COLLISION_Z_FILTER             
            public constant boolean WRITE_DELAYED_MISSILE_RECYCLING    
            public constant boolean USE_DESTRUCTABLE_FILTER            
            public constant boolean USE_ITEM_FILTER  
            
            readonly static constant string ORIGIN 
            readonly static constant real   HIT_BOX 
        
        // Functions:
        // ==========
            //
            public function GetLocZ               takes real x, real y returns real
                   function GetUnitBodySize       takes unit whichUnit returns real
                   function GetDestructableHeight takes destructable d returns real
                   function GetItemHeight         takes item i returns real
          
//========================================================================
// Missile system. Make changes carefully.
//========================================================================

//! endnovjass ( Enables the compiler )

// Hello and welcome to Missile.
// I wrote a guideline for every piece of code inside Missile, so you 
// can easily understand how the it gets compiled and evaluated.
//
// Let's go!
        
    globals
        // Core constant handle variables of Missile.
        private constant trigger   CORE  = CreateTrigger()
        private constant trigger   MOVE  = CreateTrigger()
        private constant timer     TMR   = CreateTimer()
        private constant location  LOC   = Location(0., 0.)
        private constant rect      RECT  = Rect(0., 0., 0., 0.)
        private constant group     GROUP = CreateGroup()
        private constant hashtable HASH  = InitHashtable()
        // For starting and stopping the timer.
        private integer active = 0
        // Arrays for data structure.
        private integer          array   instances
        private Missile          array   missileList
        private boolexpr         array   expression
        private triggercondition array   condition
        private integer          array   remove
        private boolean          array   destroying
        private boolean          array   recycling
        private integer          array   nextNode
        private integer          array   prevNode
        // Internal widget filter functions.
        private boolexpr destFilter
        private boolexpr itemFilter
        private boolexpr unitFilter
    endglobals
    
    public function GetLocZ takes real x, real y returns real
        call MoveLocation(LOC, x, y)
        return GetLocationZ(LOC)
    endfunction
    
    // For WRITE_DELAYED_MISSILE_RECYCLING = true Missile will hold back
    // dummies for DELAYED_MISSILE_DEATH_ANIMATION_TIME before they are recylced. ( Code placed in a static if )
    //
    //! runtextmacro optional WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")
    
    // The code of WRITE_MISSILE_POSITION_CODE boxes a missiles position and does the required trigonometry.
    //
    //! runtextmacro WRITE_MISSILE_POSITION_CODE()
    
    // Missiles structure works like a linked list with the folling methods:
    // allocateCollection(), allocateNode(), insertFront(node) and remove()
    //
    private keyword MissileStructure
    struct Missile extends array
        implement MissileStructure

        // Constants:
        // ==========
        //
        // Attach point name for effects created by model=. 
        readonly static constant string ORIGIN = "origin"
        
        // Set a ficitional hit box in range of 0 to 1,
        // while 0 is the toe and 1 the head of a unit.
        readonly static constant real HIT_BOX  = (2./3.)
        
        // DEBUG_MODE only members:
        // ========================
        //
        // Checks for double launching. Throws an error message. 
        debug boolean launched 

        // Private members:
        // ================
        //        
        // The position of a missile using curve= does not
        // match the position used by Missile's trigonometry.
        // Therefore we need this member two times.
        // Readable x / y / z for your needs and posX / posY for cool mathematics.
        private real posX
        private real posY
        private real dist// distance
        
        // Readonly members:
        // =================
        //
        // Prevents a double free case.
        readonly boolean allocated
        
        // The dummy unit.
        readonly unit    dummy
        
        // Position members for your needs.
        readonly MissilePosition origin// Grants access to readonly members of MissilePosition,
        readonly MissilePosition impact// which are "x", "y", "z", "angle", "distance", "slope" and "alpha". 
        readonly real            terrainZ
        readonly real            x
        readonly real            y
        readonly real            z
        readonly real            angle// Current angle
        readonly real            prevX
        readonly real            prevY
        readonly real            prevZ
        
        // Collision detection type. ( Evaluated new in each loop )
        readonly integer         collisionType// Current collision type ( circular or rectangle )
        
        // Members you can set:
        // ====================
        //
        unit       source
        unit       target      // For homing missiles.
        real       distance    // Distance traveled.
        player     owner       // Pseudo owner for faster onCollide evaluation. The proper dummy owner is PLAYER_NEUTRAL_PASSIVE.
        real       speed       // Vector lenght for missile movement in plane x / y.
        real       acceleration
        real       damage
        integer    data        // For data transfer set and read data.  
        boolean    recycle     // Is set to true, when a Missile reaches it's destination.
        real       turn        // Sets a turn rate for a missile. 
        real       collision   // Collision size in plane x / y.

        // Setting collision z is deprecated since Missile v2.5. 
        method operator collisionZ= takes real value returns nothing
        endmethod
        method operator collisionZ takes nothing returns real
            return collision
        endmethod
        
        // Operator overloading:
        // =====================
        //
        // Special effect on the missile dummy. For multiple effect attaching, access unit "dummy" directly.
        private effect sfx
        private string path
        method operator model= takes string file returns nothing
            if sfx != null then
                call DestroyEffect(sfx)
                set sfx = null
            endif
                                    // null and ""
            if StringLength(file) > 0 then
                set sfx = AddSpecialEffectTarget(file, dummy, ORIGIN)
                set path = file
            else
                set path = null
            endif
        endmethod
        method operator model takes nothing returns string
            return path
        endmethod
       
        real open
       // Enables curved movement for your missile. 
       // Remember that the result of Tan(PI/2) is infinity.
        method operator curve= takes real value returns nothing
            set open = Tan(value)*origin.distance
        endmethod
        method operator curve takes nothing returns real
            return Atan(open/origin.distance)
        endmethod
       
        real height
        // Enables arcing movement for your missile.
        method operator arc= takes real value returns nothing
            set height = Tan(value)*origin.distance/4
        endmethod
        method operator arc takes nothing returns real
            return Atan(4*height/origin.distance)
        endmethod
       
        private real scaling 
        method operator scale= takes real value returns nothing
            call SetUnitScale(dummy, value, 0., 0.)
            set scaling = value
        endmethod
        method operator scale takes nothing returns real
            return scaling
        endmethod
        
        // Methods:
        // ========
        //
        method bounce takes nothing returns nothing
            call origin.move(x, y, z)
            set dist = 0.
        endmethod
       
        method deflect takes real tx, real ty returns nothing
            local real a = 2.*Atan2(ty - y, tx - x) + bj_PI - angle
            call impact.move(x + (origin.distance - dist)*Cos(a), y + (origin.distance - dist)*Sin(a), impact.z)
            call bounce()
        endmethod
        
        method deflectEx takes real tx, real ty, real tz returns nothing
            call impact.move(impact.x, impact.y, tz)
            call deflect(tx, ty)
        endmethod
    
        method flightTime2Speed takes real duration returns nothing
            set speed = RMaxBJ(0.00000001, (origin.distance - dist)*Missile_TIMER_TIMEOUT/RMaxBJ(0.00000001, duration))
        endmethod
        
        method setMovementSpeed takes real value returns nothing
            set speed = value*Missile_TIMER_TIMEOUT
        endmethod
    
        boolean wantDestroy// For "true" a missile is destroyed on the next timer callback. 100% safe.
        method destroy takes nothing returns nothing
            set wantDestroy = true
        endmethod

        // Instantly destroys a missile.
        method terminate takes nothing returns nothing
            if allocated then
                call remove()
                call impact.destroy()
                call origin.destroy()
            
                call DestroyEffect(sfx)
                call FlushChildHashtable(HASH, this)
                if GetUnitTypeId(dummy) == Missile_DUMMY_UNIT_ID then
                    // MissileRecycler > Dummy > xe.
                    static if LIBRARY_MissileRecycler then
                        call RecycleMissile(dummy)
                    elseif LIBRARY_Dummy and Dummy.create.exists then
                        call Dummy[dummy].destroy()
                    elseif LIBRARY_xedummy and xedummy.release.exists then
                        call xedummy.release(dummy)
                    else
                        call RemoveUnit(dummy)
                    endif
                endif
                set sfx = null
                set source = null
                set target = null
                set dummy = null
                set owner = null
            endif
        endmethod
        
        // Runs in createEx.
        //! textmacro MISSILE_RESET_ALL_MEMBERS
            set path = null
            set speed = 0.
            set acceleration = 0.
            set distance = 0.
            set dist = 0
            set dist = 0.
            set height = 0.
            set turn = 0.
            set open = 0.
            set collision = 0.
            set collisionType = 0
            set stackSize = 0
            set scaling = 1.
            set wantDestroy = false
            set recycle = false
        //! endtextmacro
    
        // Launches a dummy of your choice.
        static method createEx takes unit missileDummy, real impactX, real impactY, real impactZ returns thistype
            local thistype this = thistype.allocateNode()
            local real originX  = GetUnitX(missileDummy)
            local real originY  = GetUnitY(missileDummy)
            local real originZ  = GetUnitFlyHeight(missileDummy)
            //
            //! runtextmacro MISSILE_RESET_ALL_MEMBERS()
            //
            set origin = MissilePosition.create(originX, originY, originZ)
            set impact = MissilePosition.create(impactX, impactY, impactZ)
            call MissilePosition.link(origin, impact)
                        
            set posX      = originX
            set posY      = originY
            set x         = originX
            set y         = originY
            set z         = originZ
            set angle     = origin.angle
            set dummy     = missileDummy
            
            call SetUnitFlyHeight(missileDummy, originZ, 0.)   
            call SaveUnitHandle(HASH, this, GetHandleId(missileDummy), missileDummy)
            //
            static if LIBRARY_ErrorMessage then
                debug call ThrowWarning(GetUnitTypeId(missileDummy) == 0, "Missile", "createEx", "missileDummy", this, "Invalid missile dummy unit ( null )!")
            endif
            debug set launched = false
            return this
        endmethod
    
        // Freaky static if ensures these libraries really don't exist.
        static if not LIBRARY_MissileRecycler and not LIBRARY_Dummy and not Dummy.create.exists and not LIBRARY_xe_dummy and not xe_dummy.new.exists then
            private static method newMissileUnit takes real x, real y, real z, real face returns unit
                local boolean prev = ToogleUnitIndexer(false)
                set bj_lastCreatedUnit = CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID , x, y, face)
                call ToogleUnitIndexer(prev)
                call SetUnitX(bj_lastCreatedUnit, x)
                call SetUnitY(bj_lastCreatedUnit, y)
                call UnitAddAbility(bj_lastCreatedUnit, 'Amrf')
                call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0.)
                call PauseUnit(bj_lastCreatedUnit, true)
                return bj_lastCreatedUnit
            endmethod
        endif
    
        // MissileRecylcer > Dummy > xe > Missile.
        //! textmacro MISSILE_GET_DUMMY_FROM_LIBRARY
            static if LIBRARY_MissileRecycler then
                return createEx(GetRecycledMissile(x, y, z, angle*bj_RADTODEG), impactX, impactY, impactZ)
        
            elseif LIBRARY_Dummy and Dummy.create.exists then
                local Dummy dummy = Dummy.create(x, y, angle*bj_RADTODEG)
                call SetUnitFlyHeight(dummy.unit, z, 0.)
                return createEx(dummy.unit, impactX, impactY, impactZ)
        
            elseif LIBRARY_xedummy and xedummy.new.exists then
                set bj_lastCreatedUnit = xedummy.new(Missile_NEUTRAL_PASSIVE, x, y, angle*bj_RADTODEG)
                call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0.)
                return createEx(bj_lastCreatedUnit, impactX, impactY, impactZ)
            
            else
                return createEx(Missile.newMissileUnit(x, y, z, angle*bj_RADTODEG), impactX, impactY, impactZ)
            endif
        //! endtextmacro
    
        // Wrapper to createEx.
        static method create takes real x, real y, real z, real angle, real distance, real impactZ returns thistype
            local real impactX = x + distance*Cos(angle)
            local real impactY = y + distance*Sin(angle)
            // Get the dummy unit.
            //! runtextmacro MISSILE_GET_DUMMY_FROM_LIBRARY()
        endmethod
        
        // Wrapper to createEx.
        static method createXYZ takes real x, real y, real z, real impactX, real impactY, real impactZ returns thistype
            local real angle = Atan2(impactY - y, impactX - x)
            // Get the dummy unit.
            //! runtextmacro MISSILE_GET_DUMMY_FROM_LIBRARY()
        endmethod
    
        // Missile motion takes place every Missile_TIMER_TIMEOUT
        // before accessing each active struct.
        static Missile temp = 0
        static method move takes nothing returns boolean
            local integer loops = 0   // Current iteration.
            local integer limit = 150 // Set iteration border per trigger evaluation to avoid hitting the operation limit.
            local thistype this = thistype.temp
            
            local MissilePosition p
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
                set p = origin
                
                // Save previous, respectively current missile position.
                set prevX = x
                set prevY = y
                set prevZ = z
                
                // Evaluate the collision type.
                set vel = speed
                set speed = vel + acceleration
                if vel < collision*Missile_COLLISION_ACCURACY_FACTOR then
                    set collisionType = Missile_COLLISION_TYPE_CIRCLE
                else
                    set collisionType = Missile_COLLISION_TYPE_RECTANGLE
                endif
                
                // Update missile guidance to its intended target.
                set u = target
                if u != null then
                    if 0 == GetUnitTypeId(u) then
                        set target = null 
                    else
                        call origin.move(x, y, z)
                        call impact.move(GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u) + GetUnitBodySize(u)*Missile.HIT_BOX)
                        set dist = 0
                        set height = 0
                        set curve = 0
                    endif
                endif
                set a = p.angle
                
                // Update the missile facing angle depending on the turn ratio.
                if 0. != turn and Cos(angle - a) < Cos(turn) then
                    if 0. > Sin(a - angle) then
                        set angle = angle - turn
                    else
                        set angle = angle + turn
                    endif
                else
                    set angle = a
                endif
                
                // Update the missile position on the parabola.
                set d = p.distance// origin - impact distance.
                
                set recycle = dist + vel >= d 
                if recycle then// Maximum distance reached. 
                    set point = d
                    set distance = distance + d - dist
                else
                    set distance = distance + vel
                    set point = dist + vel
                endif
                set dist = point
                
                set newX  = posX + vel*Cos(angle)
                set newY  = posY + vel*Sin(angle)
                set posX  = newX
                set posY  = newY
                
                // Update point(x/y) if a curving trajectory is defined.
                set u = dummy
                if 0. != open and target == null then
                    set vel = 4*open*point*(d - point)/p.square
                    set a = angle + bj_PI/2
                    set newX = newX + vel*Cos(a)
                    set newY = newY + vel*Sin(a)
                    set a = angle + Atan(-((4*open)*(2*point - d))/p.square)
                else
                    set a = angle
                endif
                set x = newX
                set y = newY
                
                // Update pos z if an arc or height is set.
                call MoveLocation(LOC, newX, newY)
                set terrainZ = GetLocationZ(LOC)
                set pitch = p.alpha
                if 0. == height and 0. == pitch then
                    set z = p.z - terrainZ
                else
                    set z = p.z - terrainZ + p.slope*point 
                    if 0. != height and target == null then
                        set z = z + (4*height*point*(d - point)/p.square)
                        set pitch = pitch - Atan(((4*height)*(2*point - d))/p.square)*bj_RADTODEG
                    endif
                endif
                // Update the pitch angle of the dummy unit. 
                if GetUnitTypeId(u) == Missile_DUMMY_UNIT_ID then
                    call SetUnitAnimationByIndex(u, R2I(pitch + 90.5))
                endif
                
                // Move the missile dummy via native.
                call SetUnitFlyHeight(u, z, 0.)
                call SetUnitFacing(u, a*bj_RADTODEG)
                
                // WorldBounds > BoundSentinel.
                static if not LIBRARY_BoundSentinel and not LIBRARY_WorldBounds then
                    if RectContainsCoords(bj_mapInitialPlayableArea, newX, newY) then
                        call SetUnitX(u, newX)
                        call SetUnitY(u, newY)
                    endif                    
                elseif LIBRARY_WorldBounds then
                    if newX < WorldBounds.maxX and newX > WorldBounds.minX and newY < WorldBounds.maxY and newY > WorldBounds.minY then
                        call SetUnitX(u, newX)
                        call SetUnitY(u, newY)
                    endif                
                else
                    call SetUnitX(u, newX)
                    call SetUnitY(u, newY)
                endif
                
                set loops = loops + 1
                set this = nextNode[this]
            endloop
            
            set u = null
            set thistype.temp = this
            return this == 0
        endmethod
            
        // Widget collision API:
        // =====================
        //
        // Runs automatically on widget collision.
        method hitWidget takes widget w returns nothing
            if w != null then
                call SaveWidgetHandle(HASH, this, GetHandleId(w), w)
            endif
        endmethod
        
        // All widget which have been hit return true.
        method hasHitWidget takes widget w returns boolean
            return HaveSavedHandle(HASH, this, GetHandleId(w))
        endmethod
        
        // Removes a widget from the missile's memory of hit widgets. ( This widget can be hit again )
        method removeHitWidget takes widget w returns nothing
            if w != null then
                call RemoveSavedHandle(HASH, this, GetHandleId(w))
            endif
        endmethod
        
        // Flushes a missile's memory for collision. ( All widgets can be hit again )
        method flushHitWidgets takes nothing returns nothing
            call FlushChildHashtable(HASH, this)
            call hitWidget(dummy)
        endmethod
        
        // Tells missile to call removeHitWidget(w) after "seconds" time.
        // Does not apply to widgets, which are already hit by this missile.
        readonly integer stackSize
        method enableHitAfter takes widget w, real seconds returns nothing
            local integer id = GetHandleId(w)
            if w != null then
                if not HaveSavedInteger(HASH, this, id) then
                    call SaveInteger(HASH, this, id, stackSize)
                    call SaveInteger(HASH, this, stackSize, id)
                    set stackSize = stackSize + 1
                endif
                call SaveReal(HASH, this, id, seconds)// Set time.
            endif
        endmethod
        
        method updateStack takes nothing returns nothing
            local integer dex = 0
            local integer id
            local real time
            loop
                exitwhen dex == stackSize
                set id = LoadInteger(HASH, this, dex)
                set time = LoadReal(HASH, this, id) - Missile_TIMER_TIMEOUT
                if time <= 0. or not HaveSavedHandle(HASH, this, id) then
                    set stackSize = stackSize - 1
                    set id = LoadInteger(HASH, this, stackSize)
                    call SaveInteger(HASH, this, dex, id)
                    call SaveInteger(HASH, this, id, dex)
                    // Enables hit.
                    call RemoveSavedHandle(HASH, this, id)
                    // Remove data from stack.
                    call RemoveSavedReal(HASH, this, id)
                    call RemoveSavedInteger(HASH, this, id)
                    call RemoveSavedInteger(HASH, this, stackSize)
                else
                    call SaveReal(HASH, this, id, time)
                    set dex = dex + 1
                endif
            endloop
        endmethod
    
        // Widget collision code:
        // ======================
        //
        private static boolean circle = true
        //
        // 1.) Rectangle collision for fast moving missiles with small collision radius.
        //        
        // Runs for destructables and items in a rectangle.
        // Checks if widget w is in collision range of a missile.
        // Is not precise in z - axis collision.
        private method isWidgetInRectangle takes widget w, real wz, real distance returns boolean
            local real wx = GetWidgetX(w)
            local real wy = GetWidgetY(w)
            local real dz = Missile_GetLocZ(wx, wy) - terrainZ
            local real dx = x - prevX
            local real dy = y - prevY
            local real s  = (dx*(wx - prevX) + dy*(wy - prevY))/(dx*dx + dy*dy)  
            
            if s < 0. then
                set s = 0.
            elseif s > 1 then
                set s = 1.
            endif
            set dx = (prevX + s*dx) - wx
            set dy = (prevY + s*dy) - wy

            return dx*dx + dy*dy <= distance*distance and dz + wz >= z - distance and dz <= z + distance 
        endmethod        
        //
        // 2.) Circular collision detection for all other missiles.
        //
        // Returns true for widgets in a xyz collision range. 
        private method isWidgetInRange takes widget w, real wz, real distance returns boolean
            local real wx = GetWidgetX(w) 
            local real wy = GetWidgetY(w) 
            local real dz = Missile_GetLocZ(wx, wy) - terrainZ
            //     collision in plane x and y,            collision in z axis.
            return IsUnitInRangeXY(dummy, wx, wy, distance) and dz + wz >= z - distance and dz <= z + distance 
        endmethod        
        //
        //  3.) Action functions inside the widget enumeration thread.
        //
        // Runs for every enumerated destructable.
        //  • Directly filters out already hit destructables.
        //  • Distance formula based on the Pythagorean theorem.
        //                         
        private static method filterDests takes nothing returns boolean
            local destructable d = GetFilterDestructable()
            local boolean b = false
            if not HaveSavedHandle(HASH, temp, GetHandleId(d)) then
                if circle then                          
                    set b = temp.isWidgetInRange(d, GetDestructableHeight(d), temp.collision)
                else
                    set b = temp.isWidgetInRectangle(d, GetDestructableHeight(d), temp.collision) 
                endif
            endif
            set d = null
            return b
        endmethod
        //
        // Runs for every enumerated item.
        //  • Directly filters out already hit items.
        //  • Distance formula based on the Pythagorean theorem.
        //  • Items have a fix collision size of 16.
        // 
        private static method filterItems takes nothing returns boolean
            local item i = GetFilterItem()
            local boolean b = false
            if not HaveSavedHandle(HASH, temp, GetHandleId(i)) then
                if circle then                                        // Item in missile collision size or item pathing in missile range.
                    set b = temp.isWidgetInRange(i, GetItemHeight(i), RMaxBJ(temp.collision, 16.))
                else
                    set b = temp.isWidgetInRectangle(i, GetItemHeight(i), RMaxBJ(temp.collision, 16.)) 
                endif
            endif
            set i = null
            return b
        endmethod
        //
        //  4.) Filter function for rectangle unit collision.
        //
        // Runs for every enumerated units.
        //  • Filters out units which are not in collision range in plane x / y.
        //  • Inlined and therefore a bit faster than item and destructable collision.
        //
        private static method filterUnits takes nothing returns boolean
            local thistype this = thistype.temp
            local unit u = GetFilterUnit()
            local real dx 
            local real dy
            local real s 
            local boolean is = false
            
            if not HaveSavedHandle(HASH, this, GetHandleId(u)) then
                set dx = x - prevX
                set dy = y - prevY
                set s = (dx*(GetUnitX(u) - prevX) + dy*(GetUnitY(u)- prevY))/(dx*dx + dy*dy)
                if s < 0. then
                    set s = 0.
                elseif s > 1. then
                    set s = 1.
                endif
                set is = IsUnitInRangeXY(u, prevX + s*dx, prevY + s*dy, collision) 
            endif
            
            set u = null
            return is
        endmethod
        //
        // 5.) Proper rect preparation.
        //
        // For rectangle.
        private method prepareRectRectangle takes nothing returns nothing
            local real x1 = prevX 
            local real y1 = prevY 
            local real x2 = x
            local real y2 = y
            local real d = collision + Missile_MAXIMUM_COLLISION_SIZE
            // What is min, what is max ...
            if x1 < x2 then
                if y1 < y2 then
                    call SetRect(RECT, x1 - d, y1 - d, x2 + d, y2 + d)
                else
                    call SetRect(RECT, x1 - d, y2 - d, x2 + d, y1 + d)
                endif
            elseif y1 < y2 then
                call SetRect(RECT, x2 - d, y1 - d, x1 + d, y2 + d)
            else
                call SetRect(RECT, x2 - d, y2 - d, x1 + d, y1 + d)
            endif 
        endmethod
        //
        // For circular.
        private method prepareRectCircle takes nothing returns nothing
            local real d = collision + Missile_MAXIMUM_COLLISION_SIZE
            call SetRect(RECT, x - d, y - d, x + d, y + d)
        endmethod
        //
        // 5.) API for the MissileStruct iteration.
        //
        method groupEnumUnitsRectangle takes nothing returns nothing
            call prepareRectRectangle()
            set thistype.temp = this
            call GroupEnumUnitsInRect(GROUP, RECT, unitFilter)
        endmethod
        //
        // Prepares destructable enumeration, then runs enumDests.
        method checkDestCollision takes code func returns nothing
            set circle = collisionType == Missile_COLLISION_TYPE_CIRCLE
            if circle then
                call prepareRectCircle()
            else
                call prepareRectRectangle()
            endif
            //
            set thistype.temp = this
            call EnumDestructablesInRect(RECT, destFilter, func)
        endmethod
        //
        // Prepares item enumeration, then runs enumItems.
        method checkItemCollision takes code func returns nothing
            set circle = collisionType == Missile_COLLISION_TYPE_CIRCLE 
            if circle then
                call prepareRectCircle()
            else
                call prepareRectRectangle()
            endif
            //
            set thistype.temp = this
            call EnumItemsInRect(RECT, itemFilter, func)
        endmethod

static if Missile_WRITE_DELAYED_MISSILE_RECYCLING then
    method nullBefore takes nothing returns nothing
        set dummy = null
    endmethod
endif

// Does not check for 'Aloc' and 'Amrf' as they could be customized.
        private static method onInit takes nothing returns nothing
            static if LIBRARY_ErrorMessage then
                debug local boolean prev = ToogleUnitIndexer(false)
                debug local unit dummy = CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, 0., 0., 0.)
                debug call ToogleUnitIndexer(prev)
                //
                debug call ThrowError((GetUnitTypeId(dummy) != Missile_DUMMY_UNIT_ID), "Missile", "DEBUG_MISSILE", "type id",    0, "Global setup for public integer DUMMY_UNIT_ID is incorrect! This map currently can't use Missile!")
                debug call ThrowError((Missile_MAXIMUM_COLLISION_SIZE < 0),            "Missile", "DEBUG_MISSILE", "collision",  0, "Global setup for public real MAXIMUM_COLLISION_SIZE is incorrect, below zero! This map currently can't use Missile!")
                debug call RemoveUnit(dummy)
                debug set dummy = null
            endif
            //
            set unitFilter = Filter(function thistype.filterUnits) 
            set destFilter = Filter(function thistype.filterDests) 
            set itemFilter = Filter(function thistype.filterItems) 
            call TriggerAddCondition(MOVE, Condition(function thistype.move))
        endmethod
        
    endstruct
    // You made it to the end of Missile, but we are not finished.
    // Do you remember about the data structure, the delayed recycler
    // and of course our interface module "MissileStruct"
    //
    // This comes now!
    
    // Debug code taken from List ( full credits to Nestharus )
    private module MissileStructure
        private static thistype collectionCount = 0
        private static thistype nodeCount       = 0
        
        static if LIBRARY_ErrorMessage then
            debug private boolean isNode
            debug private boolean isCollection
        endif
        
        private thistype _list
        method operator list takes nothing returns thistype
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,    "MissileStructure", "list", "thistype", this, "Attempted To Read Null Node.")
                debug call ThrowError(not isNode,   "MissileStructure", "list", "thistype", this, "Attempted To Read Invalid Node.")
            endif
            return _list
        endmethod
        
        private thistype _next
        method operator next takes nothing returns thistype
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,    "MissileStructure", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
                debug call ThrowError(not isNode,   "MissileStructure", "next", "thistype", this, "Attempted To Read Invalid Node.")
            endif
            return _next
        endmethod
        
        private thistype _prev
        method operator prev takes nothing returns thistype
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,    "MissileStructure", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
                debug call ThrowError(not isNode,   "MissileStructure", "prev", "thistype", this, "Attempted To Read Invalid Node.")
            endif
            return _prev
        endmethod
        
        private thistype _first
        method operator first takes nothing returns thistype
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,        "MissileStructure", "first", "thistype", this, "Attempted To Read Null List.")
                debug call ThrowError(not isCollection, "MissileStructure", "first", "thistype", this, "Attempted To Read Invalid List.")
            endif
            return _first
        endmethod
        
        private thistype _last
        method operator last takes nothing returns thistype
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,        "MissileStructure", "last", "thistype", this, "Attempted To Read Null List.")
                debug call ThrowError(not isCollection, "MissileStructure", "last", "thistype", this, "Attempted To Read Invalid List.")
            endif
            return _last
        endmethod
        
        static method allocateCollection takes nothing returns thistype
            local thistype this = thistype(0)._first
            
            if (0 == this) then
                static if LIBRARY_ErrorMessage then
                    debug call ThrowError(collectionCount == 8191, "MissileStructure", "allocateCollection", "thistype", 0, "Overflow.")
                endif
                
                set this = collectionCount + 1
                set collectionCount = this
            else
                set thistype(0)._first = _first
            endif
            
            static if LIBRARY_ErrorMessage then
                debug set isCollection = true
            endif
            
            set _first = 0
            
            return this
        endmethod
        
        static method allocateNode takes nothing returns thistype
            local thistype this = thistype(0)._next
            
            if (0 == this) then
                static if LIBRARY_ErrorMessage then
                    debug call ThrowError(nodeCount == 8191, "MissileStructure", "allocateNode", "thistype", 0, "Overflow.")
                endif
                
                set this = nodeCount + 1
                set nodeCount = this
            else
                set thistype(0)._next = _next
            endif
            
            set allocated = true
            
            return this
        endmethod
        
        method insertFront takes thistype node returns thistype
            
            // Extra static unique list for missile motion.
            set nextNode[node] = 0
            set prevNode[node] = prevNode[0]
            set nextNode[prevNode[0]] = node
            set prevNode[0] = node
            
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,        "List", "push", "thistype", this, "Attempted To Push On To Null List.")
                debug call ThrowError(not isCollection, "List", "push", "thistype", this, "Attempted To Push On To Invalid List.")
                debug set node.isNode = true
            endif
            
            set node._list = this
        
            if (_first == 0) then
                set _first = node
                set _last = node
                set node._next = 0
            else
                set _first._prev = node
                set node._next = _first
                set _first = node
            endif
            
            set node._prev = 0
            
            return node
        endmethod
      
        method remove takes nothing returns nothing
            local thistype node = this
            set this = node._list
            
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(node == 0,        "MissileStructure", "remove", "thistype", this, "Attempted To Remove Null Node.")
                debug call ThrowError(not node.isNode,  "MissileStructure", "remove", "thistype", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
                debug set node.isNode = false
            endif
            
            set node._list = 0
        
            if (0 == node._prev) then
                set _first = node._next
            else
                set node._prev._next = node._next
            endif
            if (0 == node._next) then
                set _last = node._prev
            else
                set node._next._prev = node._prev
            endif
            
            set node._next = thistype(0)._next
            set thistype(0)._next = node
            
            set node.allocated = false
            
            // Static unique list for missile motion.
            set nextNode[prevNode[node]] = nextNode[node]
            set prevNode[nextNode[node]] = prevNode[node]
        endmethod
    endmodule

    // Boolean expressions per struct:
    // ===============================
    //     
    // Condition function for the core trigger evaluation. ( Runs for all struct using module MissileStruct )
    private function MissileCreateExpression takes integer structId, code func returns nothing
        set expression[structId] = Condition(func)
    endfunction
    
    // Creates a collection for a struct. ( Runs for all struct using module MissileStruct )
    private function MissileCreateCollection takes integer structId returns nothing
        set missileList[structId] = Missile.allocateCollection()
    endfunction
    
    // Core:
    // =====
    //
    // Fires every Missile_TIMER_TIMEOUT.
    private function Fire takes nothing returns nothing
        local integer i = remove[0]
        set remove[0] = 0
        loop
            exitwhen 0 == i
            if recycling[i] then
                call TriggerRemoveCondition(CORE, condition[i])
                set condition[i] = null
                set active = active - 1
            endif
            set destroying[i] = false
            set recycling[i] = false
            set i = remove[i]
        endloop
        
        if 0 == active then
            call PauseTimer(TMR)
        else
            // Move all launched missiles.
            set Missile.temp = nextNode[0]
            set i = 0
            loop
                exitwhen TriggerEvaluate(MOVE)
                exitwhen i == 60// Moved over 8910 missiles, something buggy happened.
                set i = i + 1   // This case is impossible, hence never happens. But if I'm wrong, which also never happens 
            endloop             // then the map 100% crashes. i == 66 will prevent the game crash and Missile will start to 
                                // to debug itself over the next iterations.
        
            // Access all structs using module MissileStruct. 
            static if DEBUG_MODE and LIBRARY_ErrorMesssage then
                if not TriggerEvaluate(CORE) then
                    call ThrowWarning(true, "Missile", "Fire", "op limit", 0, /*
*/"You just ran into a op limit!
The op limit protection of Missile is insufficient for your map.
The code of the missile module can't run in one thread and must be splitted.
If unsure make a post in the official 'The Hive Workshop' forum thread of Missile!")
                endif
            else
                call TriggerEvaluate(CORE)
            endif
        endif
    endfunction
    
    // Conditionally starts the timer.
    private function StartPeriodic takes integer structId returns nothing
        if 0 == instances[structId] or destroying[structId] then            
            if destroying[structId] then
                set recycling[structId] = false
            else
                if 0 == active then
                    call TimerStart(TMR, Missile_TIMER_TIMEOUT, true, function Fire)
                endif
                set active = active + 1
                set condition[structId] = TriggerAddCondition(CORE, expression[structId])
            endif
        endif
        set instances[structId] = instances[structId] + 1
    endfunction
    
    // Conditionally stops the timer in the next callback.
    private function StopPeriodic takes integer structId returns nothing
        set instances[structId] = instances[structId] - 1
        if 0 == instances[structId] and condition[structId] != null then
            if not destroying[structId] and not recycling[structId] then
                set destroying[structId] = true
                set recycling[structId] = true
                set remove[structId] = remove[0]
                set remove[0] = structId
            endif
        endif
    endfunction
    
    // Modules:
    // ========
    //
    // You want to place module MissileLaunch at the very top of your struct.
    module MissileLaunch
        static method launch takes Missile missile returns nothing
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(missile.launched, "thistype", "launch", "missile.launched", missile, "This missile was already launched before!")
            endif
            debug set missile.launched = true
            //
            call missileList[thistype.typeid].insertFront(missile)
            call StartPeriodic(thistype.typeid)
        endmethod
    endmodule
    
    module MissileTerminate
        // Called from missileIterate. "P" to avoid code collision.
        static method missileTerminateP takes Missile node returns nothing
            if node.allocated then
                static if thistype.onRemove.exists then
                    static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and RecycleBin.recycle.exists then
                        if thistype.onRemove(node) and GetUnitTypeId(node.dummy) == Missile_DUMMY_UNIT_ID then
                            call RecycleBin.recycle(node.dummy)
                            call node.nullBefore()
                        endif
                    else
                        call thistype.onRemove(node)
                    endif
                endif
            
                call node.terminate()
                call StopPeriodic(thistype.typeid)
            endif
        endmethod
    endmodule
    
    // Allows you to inject missile in certain stages of the motion process.
    module MissileAction

static if DEBUG_MODE then
    // Runs check during compile time.
    static if thistype.onMissile.exists then
        Error Message from library Missile in struct thistype !
        thistype.onMissile is a reserved name for Missile, once you implemented MissileStruct.
        thistype.onMissile is currently not supported by library Missile. 
        Please delete or re-name that method.
    endif
endif

    static if thistype.onItem.exists then
        private static method missileActionItem takes nothing returns nothing
            local item i = GetEnumItem()
            local Missile this = Missile.temp
            if this.allocated then
                call SaveItemHandle(HASH, this, GetHandleId(i), i) 
                if thistype.onItem(this, i) then
                    call missileTerminateP(this)
                endif
            endif
            set i = null
        endmethod
    endif
        
    static if thistype.onDestructable.exists then
        private static method missileActionDest takes nothing returns nothing
            local destructable d = GetEnumDestructable()
            local Missile this = Missile.temp
            if this.allocated then
                call SaveDestructableHandle(HASH, this, GetHandleId(d), d) 
                if thistype.onDestructable(this, d) then
                    call missileTerminateP(this)
                endif
            endif
            set d = null
        endmethod
    endif
    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        static method missileIterateP takes nothing returns boolean
            local Missile this = missileList[thistype.typeid].first 
            local Missile node
            local real collideZ
            local boolean b
            local unit u
            
            loop
                exitwhen 0 == this
                set node = this.next// The linked list should not lose the next node.
               
                if this.wantDestroy then
                    call thistype.missileTerminateP(this)
                else
                    if this.stackSize > 0 then
                        call this.updateStack()
                    endif
                    
                    // Runs unit collision.
                    static if thistype.onCollide.exists then
                        if this.allocated and 0. < this.collision then
                            set b = this.collisionType == Missile_COLLISION_TYPE_RECTANGLE  
                            if b then
                                call this.groupEnumUnitsRectangle()
                            else
                                call GroupEnumUnitsInRange(GROUP, this.x, this.y, this.collision + Missile_MAXIMUM_COLLISION_SIZE, null)
                            endif
                            loop
                                set u = FirstOfGroup(GROUP)
                                exitwhen u == null
                                call GroupRemoveUnit(GROUP, u)
                                if not HaveSavedHandle(HASH, this, GetHandleId(u)) then
                                    if IsUnitInRange(u, this.dummy, this.collision) or b then  
                                        // Eventually run z collision checks.
                                        static if Missile_USE_COLLISION_Z_FILTER then
                                            set collideZ = Missile_GetLocZ(GetUnitX(u), GetUnitY(u)) + GetUnitFlyHeight(u) - this.terrainZ
                                            if (collideZ + GetUnitBodySize(u) >= this.z - this.collisionZ) and (collideZ <= this.z + this.collisionZ) then
                                                // Mark as hit.
                                                call SaveUnitHandle(HASH, this, GetHandleId(u), u)
                                                if thistype.onCollide(this, u) then
                                                    call thistype.missileTerminateP(this)
                                                    exitwhen true
                                                endif
                                            endif
    
                                        else
                                            // Runs unit collision without z collision checks.
                                            call SaveUnitHandle(HASH, this, GetHandleId(u), u)
                                            if thistype.onCollide(this, u) then
                                                call thistype.missileTerminateP(this)
                                                exitwhen true
                                            endif
                                        endif
                                    endif                                    
                                endif
                            endloop
                        endif
                    endif
                    
                    // Runs destructable collision.
                    static if thistype.onDestructable.exists then
                        // Check if the missile is not terminated.
                        if this.allocated and 0. < this.collision then
                            call this.checkDestCollision(function thistype.missileActionDest)
                        endif
                    endif
                    
                    // Runs item collision.
                    static if thistype.onItem.exists then
                        //  Check if the missile is not terminated.
                        if this.allocated and 0. < this.collision then
                            call this.checkItemCollision(function thistype.missileActionItem)
                        endif
                    endif
                
                    // Runs when the destination is reached.
                    if this.recycle and this.allocated then
                        static if thistype.onFinish.exists then
                            if thistype.onFinish(this) then
                                call thistype.missileTerminateP(this)
                            endif
                        else
                            call thistype.missileTerminateP(this)
                        endif
                    endif
                
                    // Runs on terrian collision.
                    static if thistype.onTerrain.exists then
                        if this.allocated and 0. > this.z and thistype.onTerrain(this) then
                            call missileTerminateP(this)
                        endif
                    endif
                
                    // Runs every Missile_TIMER_TIMEOUT.
                    static if thistype.onPeriod.exists then
                        if this.allocated and thistype.onPeriod(this) then
                            call missileTerminateP(this)
                        endif
                    endif
                endif
                set this = node
            endloop
            
            set u = null
            static if DEBUG_MODE and LIBRARY_ErrorMessage then
                return true
            else
                return false
            endif
        endmethod
    endmodule
    
    module MissileStruct
        implement MissileLaunch
        implement MissileTerminate
        implement MissileAction
        
        private static method onInit takes nothing returns nothing
            call MissileCreateCollection(thistype.typeid)
            call MissileCreateExpression(thistype.typeid, function thistype.missileIterateP)
        endmethod
    endmodule
    
    // Missile position:
    // =================
    //
    // Simple trigonometry.
    //! textmacro WRITE_MISSILE_POSITION_CODE 
        struct MissilePosition extends array
            private static integer array recycler
            private static integer alloc = 0
            
            // Readonly members you can access.
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
                    set b.z = b.z - Missile_GetLocZ(b.x -.01, b.y) + Missile_GetLocZ(b.x, b.y)
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
                set z = toZ + Missile_GetLocZ(toX, toY)
                if ref != this then
                    call math(this, ref)
                endif
            endmethod
    
            method destroy takes nothing returns nothing
                set recycler[this] = recycler[0]
                set recycler[0]    = this
            endmethod
    
            static method create takes real x, real y, real z returns MissilePosition
                local thistype this = recycler[0]
                 if 0 == this then
                    set alloc = alloc + 1
                    set this  = alloc
                else
                    set recycler[0] = recycler[this]
                endif
                set ref = this
                call move(x, y, z)
                return this
            endmethod
    
        endstruct
    //! endtextmacro 
    
    // Delayed dummy recycling:
    // ========================
    //
    // Ensures proper fx death animations.
    //! textmacro WRITE_MISSILE_RECYCLE_BIN takes DO_THIS, AFTER_TIME 
    static if $DO_THIS$ then

        private struct RecycleBin extends array
            private static constant timer t = CreateTimer()
            private static integer max = 0
            private static unit array dummy
            private static real array time
     
            private static method onPeriodic takes nothing returns nothing
                local integer dex = 0
                loop
                    exitwhen dex == thistype.max
                    set thistype.time[dex] = thistype.time[dex] - 1
                    if 0 >= thistype.time[dex] then
                    
                        static if LIBRARY_MissileRecycler then
                            call RecycleMissile(thistype.dummy[dex])
                    
                        elseif Dummy.create.exists and LIBRARY_Dummy then
                            call Dummy[thistype.dummy[dex]].destroy()
                        
                        elseif LIBRARY_xedummy and xedummy.release.exists then
                            call xedummy.release(thistype.dummy[dex])
                    
                        else
                            call RemoveUnit(thistype.dummy[dex])
                        endif
                    
                        set thistype.dummy[dex]          = null
                        set thistype.max                 = thistype.max - 1
                        set thistype.dummy[dex]          = thistype.dummy[thistype.max]
                        set thistype.time[dex]           = thistype.time[thistype.max]
                        set thistype.dummy[thistype.max] = null
                        set dex                          = dex - 1
                    
                        if 0 == thistype.max then
                            call PauseTimer(thistype.t)
                        endif
                    
                    endif
                    set dex = dex + 1
                endloop
            endmethod
    
            static method recycle takes unit toRecycle returns nothing
                if 0 == thistype.max then
                    call TimerStart(thistype.t, 1., true, function thistype.onPeriodic)
                endif
                set thistype.dummy[max] = toRecycle
                set thistype.time[max]  = $AFTER_TIME$ + TimerGetRemaining(thistype.t)
                set thistype.max        = thistype.max + 1
            endmethod
    
        endstruct
    endif
    //! endtextmacro
    
// The end!
endlibrary


// Diagnostic laboratory: isolate timed life on the imported dummy object.
library TimedLifeProbe initializer Init
globals
    private unit pausedDummy
    private unit runningDummy
    private unit resumedDummy
endglobals
private function Finish takes nothing returns nothing
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("TIMEDLIFE 20261021-020659 COMPLETE")
    call Preload("pausedAlive="+I2S(B2I(UnitAlive(pausedDummy)))+" runningAlive="+I2S(B2I(UnitAlive(runningDummy)))+" resumedAlive="+I2S(B2I(UnitAlive(resumedDummy))))
    call PreloadGenEnd("Logs\\TerrainDev-20261021-020659-timedlife.txt")
    call RemoveUnit(pausedDummy)
    call RemoveUnit(runningDummy)
    call RemoveUnit(resumedDummy)
    call DestroyTimer(GetExpiredTimer())
endfunction
private function Begin takes nothing returns nothing
    local real x = GetStartLocationX(0)
    local real y = GetStartLocationY(0)
    set pausedDummy = CreateUnit(Player(14),'dumi',x,y,0.)
    set runningDummy = CreateUnit(Player(14),'dumi',x+100.,y,0.)
    set resumedDummy = CreateUnit(Player(14),'dumi',x+200.,y,0.)
    call PauseUnit(pausedDummy,true)
    call PauseUnit(resumedDummy,true)
    call PauseUnit(resumedDummy,false)
    call UnitApplyTimedLife(pausedDummy,'BTLF',2.)
    call UnitApplyTimedLife(runningDummy,'BTLF',2.)
    call UnitApplyTimedLife(resumedDummy,'BTLF',2.)
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("TIMEDLIFE 20261021-020659 START types="+I2S(GetUnitTypeId(pausedDummy))+","+I2S(GetUnitTypeId(runningDummy))+","+I2S(GetUnitTypeId(resumedDummy)))
    call PreloadGenEnd("Logs\\TerrainDev-20261021-020659-timedlife-start.txt")
    call TimerStart(CreateTimer(),4.,false,function Finish)
    call DestroyTimer(GetExpiredTimer())
endfunction
private function Init takes nothing returns nothing
    call TimerStart(CreateTimer(),1.,false,function Begin)
endfunction
endlibrary


globals
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

endglobals


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
    call ConditionalTriggerExecute(gg_trg_Melee_Initialization)
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

    call ExecuteFunc("jasshelper__init3735")

    call InitGlobals()
    call InitCustomTriggers()
    call ConditionalTriggerExecute(gg_trg_Melee_Initialization) // INLINED!!

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

