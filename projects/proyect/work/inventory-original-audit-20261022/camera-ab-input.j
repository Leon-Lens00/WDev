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


// TerrainDev local instrumentation, Classic 1.27b. See docs/planes/multiboard-misiles.md.
// Hooks only observe: never kill, unpause, move or recycle gameplay objects.
library MissileDiagnostics initializer Init requires Table

struct MissileStats extends array
    // Public read-only snapshot. Death/timeout observations have <=1s latency.
    readonly static integer active = 0
    readonly static integer peakActive = 0
    readonly static integer created = 0
    readonly static integer retired = 0
    readonly static integer oldestSeconds = 0
    readonly static integer tracked = 0
    readonly static integer peakTracked = 0
    readonly static integer borrowed = 0
    readonly static integer pooled = 0
    readonly static integer deferred = 0
    readonly static integer pending = 0
    readonly static integer overdue = 0
    readonly static integer preloadTotal = 0
    readonly static integer newTotal = 0
    readonly static integer reusedTotal = 0
    readonly static integer adoptedTotal = 0
    readonly static integer disposed = 0
    readonly static integer lost = 0
    readonly static integer invalid = 0
    readonly static integer omitted = 0
    readonly static integer errors = 0
    readonly static integer inconsistent = 0
    readonly static integer alarms = 0
    readonly static integer capacity = 0
    readonly static integer checks = 0
    readonly static integer renders = 0
    readonly static multiboard board = null

    private static constant integer LIMIT = 8190
    private static constant real GRACE = 1.25
    private static constant integer OLD_AGE = 30
    private static Table index
    private static timer clock = CreateTimer()
    private static timer watcher = CreateTimer()
    private static timer painter = CreateTimer()
    private static boolean queued = false
    private static boolean initialized = false
    private static unit array units
    // 1 reserve; 2 borrowed; 3 waiting for fx; 4 timed-life disposal.
    private static integer array state
    private static real array deadline
    private static boolean array warned
    private static integer array nodeSlot
    private static integer array nodes
    private static real array born
    private static boolean array hidden
    private static string array cell
    private static string title = ""

    private static method value takes integer row, string text returns nothing
        local multiboarditem mbi
        if cell[row] != text then
            set cell[row] = text
            set mbi = MultiboardGetItem(board,row,1)
            call MultiboardSetItemValue(mbi,text)
            call MultiboardReleaseItem(mbi)
            set mbi = null
        endif
    endmethod

    private static method label takes integer row, string text returns nothing
        local multiboarditem mbi = MultiboardGetItem(board,row,0)
        call MultiboardSetItemValue(mbi,text)
        call MultiboardSetItemWidth(mbi,0.17)
        call MultiboardReleaseItem(mbi)
        set mbi = MultiboardGetItem(board,row,1)
        call MultiboardSetItemWidth(mbi,0.12)
        call MultiboardReleaseItem(mbi)
        set mbi = null
    endmethod

    private static method warning takes integer n returns string
        if n > 0 then
            return "|cffff5555"+I2S(n)+"|r"
        endif
        return I2S(n)
    endmethod

    private static method draw takes nothing returns nothing
        local string nextTitle
        set queued = false
        if board == null then
            set board = CreateMultiboard()
            call MultiboardSetRowCount(board,19)
            call MultiboardSetColumnCount(board,2)
            call MultiboardSetItemsStyle(board,true,false)
            call label(0,"Instancias / pico")
            call label(1,"Creadas / retiradas")
            call label(2,"Instancia mas antigua")
            call label(3,"Dummies vivos / pico")
            call label(4,"Dummies prestados")
            call label(5,"Reserva / capacidad")
            call label(6,"Esperando efectos")
            call label(7,"Descarte pendiente")
            call label(8,"Esperas vencidas")
            call label(9,"Precreados / nuevos")
            call label(10,"Reutilizaciones")
            call label(11,"Descartes expirados")
            call label(12,"Perdidas inesperadas")
            call label(13,"Reciclajes invalidos")
            call label(14,"Externos / omitidos")
            call label(15,"Inconsistencias / errores")
            call label(16,"Alarmas historicas")
            call label(17,"Revisiones de vida")
            call label(18,"Ver / ocultar")
            call MultiboardDisplay(board,true)
            call MultiboardMinimize(board,false)
        endif
        if overdue > 0 or lost > 0 or invalid > 0 or omitted > 0 or errors > 0 or inconsistent > 0 then
            set nextTitle = "|cffff5555Misiles: ALERTA|r"
        elseif alarms > 0 then
            set nextTitle = "|cffffcc44Misiles: revisar historial|r"
        elseif oldestSeconds >= OLD_AGE then
            set nextTitle = "|cffffcc44Misiles: revisar edad|r"
        elseif active > 0 or deferred > 0 or pending > 0 then
            set nextTitle = "|cff66ccffMisiles: actividad|r"
        else
            set nextTitle = "|cff66ff88Misiles: OK|r"
        endif
        if nextTitle != title then
            set title = nextTitle
            call MultiboardSetTitleText(board,title)
        endif
        call value(0,I2S(active)+" / "+I2S(peakActive))
        call value(1,I2S(created)+" / "+I2S(retired))
        call value(2,I2S(oldestSeconds)+" s (aviso 30)")
        call value(3,I2S(tracked)+" / "+I2S(peakTracked))
        call value(4,I2S(borrowed))
        call value(5,I2S(pooled)+" / "+I2S(capacity))
        call value(6,I2S(deferred))
        call value(7,I2S(pending))
        call value(8,warning(overdue))
        call value(9,I2S(preloadTotal)+" / "+I2S(newTotal))
        call value(10,I2S(reusedTotal))
        call value(11,I2S(disposed))
        call value(12,warning(lost))
        call value(13,warning(invalid))
        call value(14,I2S(adoptedTotal)+" / "+warning(omitted))
        call value(15,warning(inconsistent)+" / "+warning(errors))
        call value(16,I2S(alarms))
        call value(17,I2S(checks)+" (cada 1 s)")
        call value(18,"-misiles")
        set renders = renders+1
    endmethod

    private static method touch takes nothing returns nothing
        if initialized and not queued then
            set queued = true
            // Coalesce all hooks in this execution; no drawing in physics loops.
            call TimerStart(painter,0.,false,function thistype.draw)
        endif
    endmethod

    private static method error takes nothing returns nothing
        set errors = errors+1
        set alarms = alarms+1
        call touch()
    endmethod

    private static method changeState takes integer slot, integer nextState returns nothing
        if state[slot] == 1 then
            set pooled = pooled-1
        elseif state[slot] == 2 then
            set borrowed = borrowed-1
        elseif state[slot] == 3 then
            set deferred = deferred-1
        elseif state[slot] == 4 then
            set pending = pending-1
        endif
        set state[slot] = nextState
        set warned[slot] = false
        if nextState == 1 then
            set pooled = pooled+1
        elseif nextState == 2 then
            set borrowed = borrowed+1
        elseif nextState == 3 then
            set deferred = deferred+1
        elseif nextState == 4 then
            set pending = pending+1
        endif
    endmethod

    private static method track takes unit u returns integer
        local integer slot
        if u == null then
            call error()
            return 0
        endif
        set slot = index[GetHandleId(u)]
        if slot != 0 then
            return slot
        endif
        if tracked == LIMIT then
            set omitted = omitted+1
            set alarms = alarms+1
            call touch()
            return 0
        endif
        set tracked = tracked+1
        set slot = tracked
        set units[slot] = u
        set state[slot] = 0
        set deadline[slot] = 0.
        set warned[slot] = false
        set index[GetHandleId(u)] = slot
        if tracked > peakTracked then
            set peakTracked = tracked
        endif
        return slot
    endmethod

    // Called exactly once by the recycler initializer, then once per preload.
    static method configure takes integer slots returns nothing
        set capacity = slots
        call touch()
    endmethod
    static method preload takes unit u returns nothing
        local integer slot = track(u)
        set preloadTotal = preloadTotal+1
        if slot != 0 then
            call changeState(slot,1)
        endif
        call touch()
    endmethod

    static method acquire takes unit u, boolean reused returns nothing
        local integer slot = track(u)
        if reused then
            set reusedTotal = reusedTotal+1
        else
            set newTotal = newTotal+1
        endif
        if slot != 0 then
            call changeState(slot,2)
            set deadline[slot] = 0.
        endif
        call touch()
    endmethod

    static method returned takes unit u, boolean stored, real duration returns nothing
        local integer slot = index[GetHandleId(u)]
        if slot == 0 then
            set adoptedTotal = adoptedTotal+1
            set slot = track(u)
        endif
        if slot != 0 then
            if stored then
                call changeState(slot,1)
            else
                call changeState(slot,4)
            endif
            set deadline[slot] = TimerGetElapsed(clock)+duration
        endif
        call touch()
    endmethod

    static method delay takes unit u, real duration returns nothing
        local integer slot = index[GetHandleId(u)]
        if slot != 0 then
            call changeState(slot,3)
            set deadline[slot] = TimerGetElapsed(clock)+duration
        endif
        call touch()
    endmethod

    static method invalidReturn takes nothing returns nothing
        set invalid = invalid+1
        set alarms = alarms+1
        call touch()
    endmethod

    static method allocated takes integer node returns nothing
        // Classic arrays also support the core's last valid node ID, 8191.
        // LIMIT applies only to the separate unit-handle tracking table.
        if node < 1 or node > 8191 then
            set omitted = omitted+1
            call error()
            return
        endif
        if nodeSlot[node] != 0 then
            call error()
            return
        endif
        set active = active+1
        set created = created+1
        set nodes[active] = node
        set nodeSlot[node] = active
        set born[node] = TimerGetElapsed(clock)
        if active > peakActive then
            set peakActive = active
        endif
        call touch()
    endmethod

    static method released takes integer node returns nothing
        local integer slot = nodeSlot[node]
        if slot == 0 then
            call error()
            return
        endif
        set nodes[slot] = nodes[active]
        set nodeSlot[nodes[slot]] = slot
        set nodeSlot[node] = 0
        set nodes[active] = 0
        set active = active-1
        set retired = retired+1
        call touch()
    endmethod

    // Public for fixtures; the live observer also calls it once per second.
    static method inspect takes nothing returns nothing
        local integer i = 1
        local integer age
        local integer bad = 0
        local real now = TimerGetElapsed(clock)
        set oldestSeconds = 0
        set overdue = 0
        set inconsistent = 0
        loop
            exitwhen i > active
            set age = R2I(now-born[nodes[i]])
            if age > oldestSeconds then
                set oldestSeconds = age
            endif
            set i = i+1
        endloop
        set i = 1
        loop
            exitwhen i > tracked
            if GetUnitTypeId(units[i]) == 0 or GetWidgetLife(units[i]) <= 0.405 then
                if state[i] == 4 then
                    set disposed = disposed+1
                else
                    set lost = lost+1
                    set alarms = alarms+1
                endif
                call index.remove(GetHandleId(units[i]))
                call changeState(i,0)
                if i != tracked then
                    set units[i] = units[tracked]
                    set state[i] = state[tracked]
                    set deadline[i] = deadline[tracked]
                    set warned[i] = warned[tracked]
                    set index[GetHandleId(units[i])] = i
                endif
                set units[tracked] = null
                set state[tracked] = 0
                set deadline[tracked] = 0.
                set warned[tracked] = false
                set tracked = tracked-1
            else
                set bad = 0
                if (state[i] == 3 or state[i] == 4) and now > deadline[i]+GRACE then
                    set overdue = overdue+1
                    set bad = 1
                endif
                if state[i] == 1 and GetUnitUserData(units[i]) != -1 then
                    set inconsistent = inconsistent+1
                    set bad = 1
                endif
                if bad == 1 and not warned[i] then
                    set warned[i] = true
                    set alarms = alarms+1
                endif
                set i = i+1
            endif
        endloop
        if active != created-retired or tracked != pooled+borrowed+deferred+pending then
            set inconsistent = inconsistent+1
        endif
        set checks = checks+1
        call touch()
    endmethod

    private static method watch takes nothing returns nothing
        call inspect()
    endmethod

    private static method toggle takes nothing returns nothing
        local integer id = GetPlayerId(GetTriggerPlayer())
        set hidden[id] = not hidden[id]
        if GetLocalPlayer() == GetTriggerPlayer() then
            // Visual only: no handle creation, game-state writes or RNG here.
            call MultiboardDisplay(board,not hidden[id])
        endif
    endmethod

    static method initialize takes nothing returns nothing
        local trigger command = CreateTrigger()
        local integer i = 0
        set index = Table.create()
        call TimerStart(clock,1000000.,false,null)
        call TimerStart(watcher,1.,true,function thistype.watch)
        loop
            exitwhen i == bj_MAX_PLAYERS
            call TriggerRegisterPlayerChatEvent(command,Player(i),"-misiles",true)
            set i = i+1
        endloop
        call TriggerAddAction(command,function thistype.toggle)
        set command = null
        set initialized = true
        call touch()
    endmethod
endstruct

private function Init takes nothing returns nothing
    call MissileStats.initialize()
endfunction
endlibrary


library MissileRecycler initializer PreInit requires optional UnitIndexer, optional UnitDex, optional UnitIndexerGUI, optional MissileDiagnostics /*

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
            static if LIBRARY_MissileDiagnostics then
                call MissileStats.acquire(u,true)
            endif
            //call PauseUnit(u, false) -- you can disable "resets" that you don't need to worry about.
            debug call Print("Recycling")
        else
            debug call Print("Creating new")
            call ToggleIndexer(false)
            set u = CreateUnit(OWNER, DUMMY_ID, x, y, facing)
            call ToggleIndexer(true)
            call PauseUnit(u, true)
            static if LIBRARY_MissileDiagnostics then
                call MissileStats.acquire(u,false)
            endif
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
                static if LIBRARY_MissileDiagnostics then
                    call MissileStats.returned(u,false,DEATH_TIME)
                endif
                // TerrainDev / Classic 1.27b: paused units freeze timed life.
                // Only surplus units leave the paused pool before disposal.
                call PauseUnit(u, false)
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
            static if LIBRARY_MissileDiagnostics then
                call MissileStats.returned(u,true,DEATH_TIME)
            endif
        else
            static if LIBRARY_MissileDiagnostics then
                call MissileStats.invalidReturn()
            endif
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
        static if LIBRARY_MissileDiagnostics then
            call MissileStats.configure(ANG_N*ANG_STORAGE_MAX)
        endif
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
                static if LIBRARY_MissileDiagnostics then
                    call MissileStats.preload(u)
                endif
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
*       */ optional MissileDiagnostics /* TerrainDev: observable lifecycle counters, no motion changes.
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
                static if LIBRARY_MissileDiagnostics then
                    call MissileStats.released(this)
                endif
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
            static if LIBRARY_MissileDiagnostics then
                call MissileStats.allocated(this)
            endif
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
                static if LIBRARY_MissileDiagnostics then
                    // The existing bin advances in whole seconds; allow its next tick.
                    call MissileStats.delay(toRecycle,$AFTER_TIME$+1.)
                endif
                set thistype.max        = thistype.max + 1
            endmethod
    
        endstruct
    endif
    //! endtextmacro
    
// The end!
endlibrary


library InventoryCore initializer Init requires UserInterface, InventoryItem, PlayerUtils, TimerUtils
    
    struct Inventory
        //
        // configuration
        //
        
        // location of inventory
        static real X = 0.61
        static real Y = -0.3
        
        // size of the background wwindow
        static real SCALE = 0.228
        
        // location of the tooltip information
        static real TOOLTIP_X = -0.7
        static real TOOLTIP_Y = 0.0
        
        // max # of pages the inventory can have 
        static integer MAX_PAGES = 5
        
        // how many slots are on each row/column
        static constant integer BUTTON_ROWS = 6
        static constant integer BUTTON_COLS = 5
        
        // how fast the UI updates
        static constant real UI_REFRESH_RATE = 0.01
        
        // show errors
        static constant boolean SHOW_ERRORS = true

        // icon size
        static constant real SLOT_WIDTH  = 0.065
        static constant real SLOT_HEIGHT = 0.065 * SCREEN_ASPECT_RATIO
        static constant real SLOT_SPACING = 1.00 // 0%
        
        // icon offsets (from X,Y)
        static constant real SLOT_OFFSET_X  = -0.0485
        static constant real SLOT_OFFSET_Y  = 0.072
        
        // raw id's
        static constant integer ICON_EMPTY          = 'dbnk'
        static constant integer ICON_TRANSPARENT    = 'B00S'
        static constant integer ICON_PAGEUP         = 'B00U'
        static constant integer ICON_PAGEDOWN       = 'B00T'
        static constant integer ICON_SELL           = 'B011'
        static constant integer ICON_DROP           = 'B00N'
        
        static constant integer RACE_BORDERS_START = 'D201'
        
        static constant integer BACKGROUND = 'bwn2'
        
        //
        // don't edit below here unless you know what you're doing
        //
        
        static constant integer MAX_SLOTS = BUTTON_ROWS * BUTTON_COLS
        static constant integer MAX_ITEMS = MAX_SLOTS * MAX_PAGES
        
        readonly static hashtable Hashtable = InitHashtable()
        readonly static trigger ExecL = CreateTrigger()
        readonly static trigger ExecR = CreateTrigger()
        readonly static integer DisplayCount = 0
        readonly static timer UpdateTimer = CreateTimer()
        readonly static thistype array PlayerCurrent
        readonly static UIButton array buttons
        
        readonly integer itemCount
        readonly thistype next
        readonly thistype prev
        readonly integer pid
        readonly User user
        readonly unit owner
        
        static UIPicture array background
        static UIText array pageNum
        static UIButton array btnPageUp    
        static UIButton array btnPageDown
        static UIButton array btnSell
        static UIButton array btnDrop
        static UIPicture array selector
        
        Camera camera
        InventoryTable countTable
        integer currentPage
        
        readonly boolean displayed
        readonly integer freeSlot
        
        public static trigger onSell
        public static trigger onDrop
        
        public static key KEY_ITEMS
        public static key KEY_ITEM_ID
        public static key KeyUnit
        public static constant integer KEY_UNIT = INVENTORY_KEY_START + KeyUnit
        public static key KeyItemCount
        public static constant integer KEY_ITEM_COUNT = INVENTORY_KEY_START + KeyItemCount
    
        static method localInt takes integer pid, integer value, integer other returns integer
            if (User.Local != User(pid).handle) then
                set value = other
            endif
            return value
        endmethod
        
        static method err takes player p, string s returns nothing
            static if (Inventory.SHOW_ERRORS) then
                static if (LIBRARY_SimError) then
                    call SimError(p, s)
                else
                    call DisplayTimedTextToPlayer(p, 0, 0, 15, "Error: " + s)
                endif
            endif
        endmethod
        
        static method operator [] takes unit u returns thistype
            return thistype(LoadInteger(.Hashtable, KEY_UNIT, GetHandleId(u)))
        endmethod
        
        static method operator []= takes unit u, thistype value returns nothing
            call SaveInteger(.Hashtable, KEY_UNIT, GetHandleId(u), value)
        endmethod
 
        method getButton takes integer index returns UIButton
            return this.buttons[(this.pid * MAX_SLOTS) + index]
        endmethod
        
        method setButton takes integer index, UIButton value returns nothing
            set this.buttons[(this.pid * MAX_SLOTS) + index] = value
        endmethod
        
        method getItem takes integer index returns InvItem
            return LoadInteger(.Hashtable, this, (MAX_ITEMS * .KEY_ITEMS) + index)
        endmethod
        
        method itemsOfType takes integer id returns integer
            return this.countTable[id]
        endmethod
        
        static method addLeftClickHook takes code func returns nothing
            call TriggerAddAction(ExecL, func)
        endmethod
        
        static method addRightClickHook takes code func returns nothing
            call TriggerAddAction(ExecR, func)
        endmethod
        
        method getItemId takes integer index returns integer
            return LoadInteger(.Hashtable, this, (MAX_ITEMS * .KEY_ITEM_ID) + index)
        endmethod
        
        method setItem takes integer index, InvItem itm returns nothing
            local UIButton btn
            local integer slot = index
            local integer id = itm.id
            local integer icon = GetItemIcon(id)
            local InvItem oldItem
            
            if (this.currentPage > 0) then
                set slot = index - (.MAX_SLOTS*this.currentPage)
            endif
            
            set btn = this.getButton(slot)

            set oldItem = this.getItem(index)
            
            call SaveInteger(.Hashtable, this, (MAX_ITEMS * .KEY_ITEMS) + index, itm)
            
            if (itm.tempCustomId > 0) then
                call SaveInteger(.Hashtable, this, (MAX_ITEMS * .KEY_ITEM_ID) + index, itm.tempCustomId)
            endif
            
            set itm.tempCustomId = 0
            
            if (id == 0 and HaveSavedInteger(.Hashtable, this, (MAX_ITEMS * .KEY_ITEMS) + index)) then
                set id = oldItem.id
                
                set this.itemCount = this.itemCount - 1
                set this.countTable[id] = this.countTable[id] - 1
                
                call RemoveSavedInteger(.Hashtable, this, (MAX_ITEMS * .KEY_ITEMS) + index)
                
                // remove ability
                if (oldItem.ability > 0 and itemsOfType(id) <= 0) then
                    call UnitRemoveAbility(this.owner, oldItem.ability)
                endif
            elseif (id > 0) then
                set this.itemCount = this.itemCount + 1
                set this.countTable[id] = this.countTable[id] + 1
                
                // add ability
                if (itm.ability > 0 and itemsOfType(id) == 1) then
                    call UnitAddAbility(this.owner, itm.ability)
                endif
            endif
            
            call btn.setTexture(.localInt(this.pid, icon, ICON_TRANSPARENT))
            call btn.showPlayer(this.user.handle, this.displayed, this.camera)
        endmethod
        
        method findFreeSlot takes integer page returns integer //O(n)
            local integer i = 0
            loop
                exitwhen i == MAX_SLOTS
                if (this.getItem((MAX_SLOTS*page)+i) == 0) then
                    return i
                endif
                set i = i + 1
            endloop
            return -1
        endmethod

        method createButtons takes nothing returns nothing
            local integer row = 0
            local integer col = 0
            local UIButton btn = 0
            local integer i = 0

            if (btnPageUp[this.pid] == 0) then
                set btnPageUp[this.pid] = UIButton.create(X - 0.15, (Y + SLOT_OFFSET_Y) - (col * (SLOT_HEIGHT*SLOT_SPACING)), .SLOT_WIDTH, .SLOT_HEIGHT, 0.5, thistype.localInt(this.pid, ICON_PAGEUP, ICON_TRANSPARENT))
                set btnPageDown[this.pid] = UIButton.create(X - 0.15, (Y + SLOT_OFFSET_Y) - ((.BUTTON_COLS-1) * (SLOT_HEIGHT*SLOT_SPACING)), .SLOT_WIDTH, .SLOT_HEIGHT, 0.5, thistype.localInt(this.pid, ICON_PAGEDOWN, ICON_TRANSPARENT))
                set btnSell[this.pid] = UIButton.create(X - 0.15, (Y + SLOT_OFFSET_Y) - .300, .SLOT_WIDTH, .SLOT_HEIGHT, 0.5, thistype.localInt(this.pid, ICON_SELL, ICON_TRANSPARENT))
                set btnDrop[this.pid] = UIButton.create(X - 0.15, (Y + SLOT_OFFSET_Y) - .150, .SLOT_WIDTH, .SLOT_HEIGHT, 0.5, thistype.localInt(this.pid, ICON_DROP, ICON_TRANSPARENT))
                
                set btnPageUp[this.pid].onLeftClick = InvFuncLClickSlot
                set btnPageDown[this.pid].onLeftClick = InvFuncLClickSlot
                set btnSell[this.pid].onLeftClick = InvFuncLClickSlot
                set btnDrop[this.pid].onLeftClick = InvFuncLClickSlot
                
                set btnPageUp[this.pid].selectUnit = this.owner
                set btnPageDown[this.pid].selectUnit = this.owner
                set btnSell[this.pid].selectUnit = this.owner
                set btnDrop[this.pid].selectUnit = this.owner
                
                set selector[this.pid] = UIPicture.createEx(X - 0.15, (Y + SLOT_OFFSET_Y) - .250, 0, .55, 'e000', 1, 1, 0)
                set selector[this.pid].animIndex = 56
                call selector[this.user.id].show(false, this.camera)
                
                call AddSpecialEffectTarget("UI\\TRSHerolevel.mdx", selector[this.pid].picture, "origin")
            endif
            
            loop
                exitwhen col == BUTTON_COLS
                
                set row = 0
                
                loop
                    exitwhen row == BUTTON_ROWS
                    
                    if (this.getButton(i) == 0) then
                    
                        set btn = UIButton.create( (X + SLOT_OFFSET_X) + (row * (SLOT_WIDTH*SLOT_SPACING)), (Y + SLOT_OFFSET_Y) - (col * (SLOT_HEIGHT*SLOT_SPACING)), .SLOT_WIDTH, .SLOT_HEIGHT, 0.5, GetItemIcon(this.getItem(i).id))
                        
                        set btn.customValue = i
                        
                        set btn.selectUnit = this.owner
                        
                        set btn.onLeftClick = InvFuncLClickSlot
                        set btn.onRightClick = InvFuncRClickSlot
                        
                        call this.setButton(i, btn)

                        //call SetUnitVertexColor(.background[this.pid].picture, 255, 255, 255, thistype.localInt(this.pid, 255, 0))
                    endif
                    set i = i + 1
                    
                    set row = row + 1
                endloop
                
                set col = col + 1
            endloop
        endmethod
        
        implement InvPlugins
        
        static method create takes unit owner returns thistype
            local thistype this = thistype.allocate()
            local boolean showLocally
            local integer raceId
            local integer i = 0
            
            set this.itemCount = 0
            set this.owner = owner
            set this.freeSlot = 0
            set this.pid = GetPlayerId(GetOwningPlayer(this.owner))
            set this.user = User(this.pid)
            set this.countTable=InventoryTable.create()
            
            set raceId = GetHandleId(GetPlayerRace(User(this.pid).handle))-1
            
            set showLocally = (User.Local == User(this.pid).handle)
            
            call this.createButtons()
            
            static if (thistype.createTooltip.exists) then
                call thistype.createTooltip(this, raceId)
            endif
            
            if (this.pageNum[this.pid] == 0) then
                set this.pageNum[this.pid] = UIText.createEx(this.user.toPlayer(), X + 0.300, Y + .10, 1)
            endif
            
            set Inventory[this.owner] = this
            
            if (.background[this.pid] == 0) then
                set .background[this.pid] = UIPicture.createEx(X, Y, 2, SCALE, BACKGROUND, 70., 60, .localInt(this.pid, RACE_BORDERS_START + raceId, ICON_TRANSPARENT))
            endif

            set thistype(0).next.prev = this
            set this.next = thistype(0).next
            set thistype(0).next = this

            set this.prev = 0

            return this
        endmethod
        
        method addItem takes InvItem itm returns boolean
            local integer slot
            
            if (itm <= 0 or itm.id <= 0) then
                return false
            endif
            
            set slot = findFreeSlot(this.currentPage)
            
            if (slot == -1) then
                call err(User(this.pid).handle, "There are no free slots on this inventory page.")
                return false
            endif
            
            if (itm.icon == ICON_EMPTY) then
                return false
            endif
            
            call this.setItem((.MAX_SLOTS * this.currentPage) + slot, itm)
            
            return true
        endmethod
        
        method destroy takes nothing returns nothing
            set this.next.prev = this.prev
            set this.prev.next = this.next

            call this.deallocate()
        endmethod
        
        private static method onDisplay takes nothing returns nothing
            local thistype inv
            local real x
            local real y 
            local real z
            
            local User user = User(User.LocalId)
            
            set inv = Inventory.PlayerCurrent[user.id]
            
            if (inv == 0 or not inv.displayed) then
                return
            endif
            
            set x = GetUnitX(inv.owner)
            set y = GetUnitY(inv.owner)
            set z = GetTerrainZ(x, y) + GetUnitDefaultFlyHeight(inv.owner)
            
            call inv.camera.setPosition(x, y, z)
            
            if inv.camera.applyCameraForPlayer(user.handle, false) then
                call Interface.updateAll(true, true, true)
            endif

        endmethod
        
        method show takes boolean flag, Camera cam returns nothing
            local integer i
            local thistype equip
            local real timeout
            
            if this == 0 or (not flag and not this.displayed) then
                return
            endif

            if (this.currentPage >= .MAX_PAGES) then
                set this.currentPage = 0
            elseif (this.currentPage < 0) then
                set this.currentPage = .MAX_PAGES - 1
            endif
            
            if (flag) then
                if (not this.displayed) then
                    set .DisplayCount = .DisplayCount + 1
                endif
                
                if (PlayerCurrent[this.pid] > 0 and PlayerCurrent[this.pid] != this) then
                    call PlayerCurrent[this.pid].show(false, cam)
                endif
                
                set PlayerCurrent[this.pid] = this

                call PauseTimer(.UpdateTimer)
                call TimerStart(.UpdateTimer, UI_REFRESH_RATE, true, function thistype.onDisplay)
            else
                set .DisplayCount = .DisplayCount - 1
                
                if (DisplayCount == 0) then
                    call PauseTimer(.UpdateTimer)
                else
                    call TimerStart(.UpdateTimer, UI_REFRESH_RATE, true, function thistype.onDisplay)
                endif
                
                if (User.LocalId == this.pid) then
                    call ResetToGameCamera(0)
                endif
                
                set PlayerCurrent[this.pid] = 0
            endif
            
            set this.displayed = flag
            set this.camera = cam
            
            call this.btnPageUp[this.pid].show(flag, cam)
            call this.btnSell[this.pid].show(flag, cam)
            call this.btnDrop[this.pid].show(flag, cam)
            //call this.selector[this.pid].show(flag, cam)
            call this.btnPageDown[this.pid].show(flag, cam)
            call this.background[this.pid].show(flag, cam)

            static if thistype.showTooltip.exists then
                if (not flag) then
                    call thistype.showTooltip(this, flag)
                endif
            endif
            
            call SetTextTagText(this.pageNum[this.pid].text, I2S(this.currentPage + 1) + "/" + I2S(.MAX_PAGES), 10 * 0.0023)
            
            call this.pageNum[this.pid].show(flag, cam)
            
            set i = 0
            
            loop
                exitwhen i == .MAX_SLOTS
                
                call this.getButton(i).setTexture(thistype.localInt(this.pid, GetItemIcon(this.getItem((.MAX_SLOTS*this.currentPage) + i).id), ICON_TRANSPARENT))

                call this.getButton(i).showPlayer(this.user.handle, flag, this.camera)
                
                
                set i = i + 1
            endloop

        endmethod
        
        /*private static method onInit takes nothing returns nothing
        endmethod*/
    endstruct
    
    public function GracePeriod takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local UIButton but = UIButton(GetTimerData(t))
        
        set InvButtonDisabled[but] = false
        
        call ReleaseTimer(t)
    endfunction
    
    function DisableButtonIfUsingTimer takes UIButton but, real time returns nothing
        static if (Inventory.USE_LEFT_CLICK_TIMER) then
            call TimerStart(NewTimerEx(but), time, false, function GracePeriod)
            set InvButtonDisabled[but] = true
        endif
    endfunction
    
    private function LClickItemSlot takes nothing returns boolean
        local UIButton but = GetTriggerButton()
        local player p = GetClickingPlayer()
        local integer pid = GetPlayerId(p)
        local Inventory inv =  Inventory.PlayerCurrent[pid]
        local integer slot =  but.customValue
        local integer itemId = 0
        local integer icon = 0
        local integer last = InvPlayerLastSlot[inv.pid] - 1
        local integer lastItemId
        local InvItem lastItem
        local UIButton lastButton = InvPlayerLastButton[inv.pid]

        if (User.Local == p) then
            call SelectUnit(but.picture, false)
            call SelectUnit(inv.owner, true)
        endif
        
        if (InvButtonDisabled[but]) then
            return false
        endif
        
        // sell item
        if (but == Inventory.btnSell[inv.pid]) then
            set last = InvPlayerLastSlot[inv.pid] - 1
            
            if (last < 0) then
                return false 
            endif
            
           if (p != User(inv.pid).handle) then
                return false 
            endif
            
            // run onSell event
            set InvEventPlayer = User(inv.pid).handle
            set InvEventItem = inv.getItem((Inventory.MAX_SLOTS*inv.currentPage)+last)
            set InvEventSlot = (Inventory.MAX_SLOTS*inv.currentPage)+last
            
            if (Inventory.onSell != null and TriggerEvaluate(Inventory.onSell)) then
                call TriggerExecute(Inventory.onSell)
            endif
            
            call DisableButtonIfUsingTimer(but, 2)
            
            return false
        elseif (but == Inventory.btnDrop[inv.pid]) then
            set last = InvPlayerLastSlot[inv.pid] - 1
            
            if (last < 0) then
                return false 
            endif
            
           if (p != User(inv.pid).handle) then
                return false 
            endif
            
            // run onSell event
            set InvEventPlayer = User(inv.pid).handle
            set InvEventItem = inv.getItem((Inventory.MAX_SLOTS*inv.currentPage)+last)
            set InvEventSlot = (Inventory.MAX_SLOTS*inv.currentPage)+last
            
            if (Inventory.onDrop != null and TriggerEvaluate(Inventory.onDrop)) then
                call TriggerExecute(Inventory.onDrop)
                return false
            endif
            
            call DisableButtonIfUsingTimer(but, 2)
        elseif (but == Inventory.btnPageDown[inv.pid]) then
           if (p != User(inv.pid).handle) then
                return false
            endif
        
            set inv.currentPage = inv.currentPage + 1
            call inv.show(true, inv.camera)
            call DisableButtonIfUsingTimer(but, .6)
            return false
        elseif (but == Inventory.btnPageUp[inv.pid]) then
           if (p != User(inv.pid).handle) then
                return false
            endif
            
            set inv.currentPage = inv.currentPage - 1
            call inv.show(true, inv.camera)
            call DisableButtonIfUsingTimer(but, .6)
            return false
        else
            call Inventory.selector[inv.pid].show(true, inv.camera)
            call Inventory.selector[pid].setPosition(but.centerx - 0.004, but.centery + 0.0262)
            call Inventory.selector[pid].showPlayer(Player(pid), true, inv.camera)
        endif

        if (p != User(inv.pid).handle) then
            return false
        endif
        
        if (last + 1 != slot) then
            call inv.showLines(inv.pid, false, inv.camera)
        endif
        
        call TriggerExecute(Inventory.ExecL)
        
        // get item in slot
        set itemId = inv.getItem((Inventory.MAX_SLOTS*inv.currentPage)+slot).id
        
         // check for switch
        if (last+1 != 0) then

            call SetUnitVertexColor(lastButton.picture, 255, 255, 255, 255)
            call SetUnitVertexColor(but.picture, 255, 255, 255, 255)
            
            set InvPlayerLastSlot[inv.pid] = 0
            set InvPlayerLastButton[inv.pid] = but
                
            if (itemId == 0) then
                set last = (Inventory.MAX_SLOTS * inv.currentPage) + last
                
                set lastItem = inv.getItem(last)
            
                set lastItemId = lastItem.id
                
                set lastItem.tempCustomId = inv.getItemId(last)
            
                call inv.setItem((Inventory.MAX_SLOTS*inv.currentPage)+slot, lastItem)
                call inv.setItem(last, 0)
                
                call DisableButtonIfUsingTimer(but, 2)
            elseif (inv.getItem((Inventory.MAX_SLOTS * inv.currentPage) + last).isSocket) then
                
                set last = (Inventory.MAX_SLOTS * inv.currentPage) + last
                
                set lastItem = inv.getItem(last)
                set lastItem.tempCustomId = inv.getItemId(last)
                set slot = (Inventory.MAX_SLOTS*inv.currentPage)+slot
                
                if (Equipment.onSocket != null) then
                    if (lastItem.sockets <= lastItem.maxSockets) then
                        set SocketInv = inv
                        set SocketLast = last
                        set SocketSlot = slot
                        
                        if (not inv.getItem(slot).isSocket and Equipment.onSocket != null and TriggerEvaluate(Equipment.onSocket)) then
                            call TriggerExecute(Equipment.onSocket)
                            return false
                        endif
                    endif
                else
                    set inv.getItem(slot).tempCustomId = inv.getItemId(slot)
                    
                    if (inv.getItem(slot).addSocket(lastItem)) then
                        call inv.setItem(last, 0)
                    endif
                endif
    
            endif
        else//if (itemId != 0) then
            set InvPlayerLastSlot[inv.pid] = 0
            set InvPlayerLastButton[inv.pid] = but
        endif
        
        if (itemId == 0 or InvPlayerLastSlot[inv.pid] != 0) then
        else
            set InvPlayerLastSlot[inv.pid] = slot + 1
        endif
        
        if (but != lastButton) then
            call SetUnitVertexColor(lastButton.picture, 255, 255, 255, 255)
            call SetUnitVertexColor(but.picture, 175, 175, 175, 255)
        endif
        
        if (itemId > 0) then
            
            call inv.setTooltipTitle(GetObjectName(itemId))
            
            static if (InvItem.buildDescription.exists) then
                set GetInvItem(itemId).tempCustomId = inv.getItemId((Inventory.MAX_SLOTS*inv.currentPage)+slot)

                call GetInvItem(itemId).buildDescription(inv.owner)
            else
                call inv.setTooltipInfo(GetItemDescription(itemId))
            endif
            
            call inv.setTooltipCost("|cffffcc00" + I2S(GetInvItem(itemId).cost) + "|r")
            
            call inv.setTooltipIcon(inv.localInt(inv.pid, GetItemIcon(itemId), Inventory.ICON_TRANSPARENT))
        endif
        
        set Inventory.TOOLTIP_X = but.minx - 0.4
        set Inventory.TOOLTIP_Y = but.maxy + 0.4
        
        call inv.showTooltip(inv, itemId > 0)
        
        return false
    endfunction

    private function RClickItemSlot takes nothing returns boolean
        local UIButton but = GetTriggerButton()
        local player p = GetClickingPlayer()
        local integer pid = GetPlayerId(p)
        local Inventory inv =  Inventory.PlayerCurrent[pid]
        
        local integer slot =  but.customValue
        local integer itemId
 
        if (p != User(inv.pid).handle) then
            return false
        endif
        
        call TriggerExecute(Inventory.ExecR)
        
        set slot = (Inventory.MAX_SLOTS * inv.currentPage) + slot

        set itemId = inv.getItem(slot).id

        if (itemId == 0) then
            return false
        endif
        
        call inv.showTooltip(inv, false)
        
        /*call SetItemUserData(CreateItem(itemId, GetUnitX(inv.owner), GetUnitY(inv.owner)), inv.getItemId(slot))
        
        call inv.setItem(slot, 0)*/
        
        return false
    endfunction
    
    private function Init takes nothing returns nothing
        set InvFuncLClickSlot = Filter(function LClickItemSlot)
        set InvFuncRClickSlot = Filter(function RClickItemSlot)
    endfunction
    
endlibrary

library InventoryItem uses InventoryTable, optional InventoryBonus
    
    globals
        public constant integer SEED_START = 0
        public constant integer SEED_END   = 999
    endglobals
    
    struct InvItem
        readonly static InventoryTable InventoryTable
        
        integer id
        integer icon
        integer cost
        integer ability
        string info
        integer tempCustomId
        
        implement InvItemPlugins
        
        static if not thistype.buildDescriptionLines.exists then
            method buildDescriptionLines takes integer pid, integer startLine returns integer
                return buildDescriptionLines(GetPlayerId(GetOwningPlayer(forUnit)), 0)
            endmethod
        endif
        
        static if not thistype.buildDescription.exists then
            method buildDescription takes unit forUnit returns string
                return buildDescriptionLines(GetPlayerId(GetOwningPlayer(forUnit)), 0)
            endmethod
        endif
        
        private static method onInit takes nothing returns nothing
            set InvItem.InventoryTable = InventoryTable.create()
        endmethod
    endstruct
    
    function GetInvItem takes integer id returns InvItem
        return InvItem(InvItem.InventoryTable[id])
    endfunction
    
    function GetItemInfo takes integer id returns string
        return InvItem(InvItem.InventoryTable[id]).info
    endfunction
    
    function GetItemDescription takes integer id returns string
        return InvItem(InvItem.InventoryTable[id]).info
    endfunction
    
    function GetItemIcon takes integer id returns integer
        local integer icon = InvItem(InvItem.InventoryTable[id]).icon
        if (icon == 0) then
            return Inventory.ICON_EMPTY
        endif
        return icon
    endfunction
    
    function CreateInvItem takes integer id, integer icon, integer cost, integer abil, string info returns InvItem
        local InvItem itm = InvItem.create()
        set itm.id   = id
        set itm.icon = icon
        set itm.cost = cost
        set itm.info = info
        set itm.ability = abil
        set InvItem.InventoryTable[itm.id] = itm
        return itm
    endfunction
    
    struct InvCustomItem extends array
        static integer Counter = 1
        static InventoryTable SeedTable
        
        static method create takes nothing returns thistype
            local thistype this = Counter
            set SeedTable[this] = GetRandomInt(SEED_START, SEED_END)
            set Counter = Counter + 1
            return this
        endmethod
        
        method seed takes nothing returns integer
            return SeedTable[this]
        endmethod
        
        static method onInit takes nothing returns nothing
            set SeedTable = SeedTable.create()
        endmethod
    endstruct

endlibrary

library InventoryPlugins

    // add plugins here
    module InvPlugins
        implement InvTooltip
    endmodule
    
    module InvItemPlugins
        implement InvItemTooltip
        implement InvItemEquipment
        implement InvItemSocket
    endmodule

endlibrary

library InventoryTooltip

    module InvTooltip
        //
        // configuration
        //
        
        // about the length of tooltip line.
        // line lengths are resolution and char-width 
        // dependent for textags, so a new text tag
        // is created per-line.
        static constant integer TOOLTIP_LINE_LENGTH  = 32
        static constant integer TOOLTIP_LINES_MAX    = 16
        static constant integer TOOLTIP_TEXTURE      = 'B014'
        static constant real TOOLTIP_LINE_SPACING    = .05
        static constant real TOOLTIP_FONT_SIZE       = 7.5
        
        static constant integer ICON_TOOLTIP_GOLD  = 'B00H'
        static constant integer TOOLTIP_BACKGROUND = 'ttip'
        //
        // end config
        //
        
        readonly static UIText array ItemInfoTags[15][.TOOLTIP_LINES_MAX]
        static integer array RightSideStart
        
        static UIText array infoBoxTitle
        static UIText array infoBoxCost
        static UIText array infoBoxDesc
        static UIPicture array infoBox
        static UIPicture array infoIcon 
        static UIPicture array costIcon 
        
        method setTooltipTitle takes string title returns nothing
            call SetTextTagText(thistype.infoBoxTitle[this.pid].text, title, 10 * 0.0023)
        endmethod
        
        method setTooltipInfo takes string desc returns nothing
            call SetTextTagText(thistype.infoBoxTitle[this.pid].text, desc, TOOLTIP_FONT_SIZE * 0.0023)
        endmethod
        
        method setTooltipCost takes string value returns nothing
            call SetTextTagText(thistype.infoBoxCost[this.pid].text, value, 8 * 0.0023)
        endmethod
        
        method setTooltipIcon takes integer id returns nothing
            call this.infoIcon[this.pid].setTexture(id)
        endmethod
        
        static method setTooltipLine takes integer pid, integer line, string str returns nothing
            call SetTextTagText(Inventory.ItemInfoTags[pid][line].text, str, Inventory.TOOLTIP_FONT_SIZE * 0.0023)
        endmethod
        
        static method setTooltipSlot takes integer pid, integer line, string str returns nothing
            call SetTextTagText(Inventory.ItemInfoTags[pid][TOOLTIP_LINES_MAX-1].text, str, Inventory.TOOLTIP_FONT_SIZE * 0.0023)
        endmethod
        
        method showLines takes integer pid, boolean flag, Camera cam returns nothing
            local integer i = 0
            loop
                exitwhen i == TOOLTIP_LINES_MAX
                if (not flag) then
                    call SetTextTagText(Inventory.ItemInfoTags[pid][i].text, "", Inventory.TOOLTIP_FONT_SIZE * 0.0023)
                endif
                call Inventory.ItemInfoTags[pid][i].show(flag, cam)
                set i = i + 1
            endloop
        endmethod
        
        static method clearLines takes integer pid returns nothing
            local integer i = 0
            loop
                exitwhen i == TOOLTIP_LINES_MAX
                call SetTextTagText(Inventory.ItemInfoTags[pid][i].text, "", Inventory.TOOLTIP_FONT_SIZE * 0.0023)
                set i = i + 1
            endloop
        endmethod
        
        static method updateLines takes integer pid returns nothing
            local integer i = 0
            loop
                exitwhen i == TOOLTIP_LINES_MAX
                call Inventory.ItemInfoTags[pid][i].update()
                set i = i + 1
            endloop
        endmethod
        
        static method createTooltip takes thistype this, integer raceId returns nothing
            local boolean showLocally = (User.Local == User(this.pid).handle)
            local integer i = 0
        
            //if (showLocally) then
                if (thistype.infoBoxTitle[this.pid] == null) then
                    set thistype.infoBoxTitle[this.pid] = UIText.createEx(this.user.toPlayer(), TOOLTIP_X - 0.1, TOOLTIP_Y + .22, 1)
                    
                    set thistype.infoBoxDesc[this.pid] = UIText.createEx(this.user.toPlayer(), TOOLTIP_X - 0.1, TOOLTIP_Y + .25, 1)
                endif
                
                if (thistype.infoBoxCost[this.pid] == null) then
                    set thistype.infoBoxCost[this.pid] = UIText.createEx(this.user.toPlayer(), TOOLTIP_X - (0.065 - 0.), TOOLTIP_Y + .15, 1)
                endif
                
                
                // description lines
                if (ItemInfoTags[this.pid][0] == 0) then
                    loop
                        exitwhen i == TOOLTIP_LINES_MAX
                        
                        if (i == TOOLTIP_LINES_MAX-1) then
                            set ItemInfoTags[this.pid][i] = UIText.createEx(this.user.toPlayer(), TOOLTIP_X + 0.05, TOOLTIP_Y + .16, 1)
                        else
                            set ItemInfoTags[this.pid][i] = UIText.createEx(this.user.toPlayer(), TOOLTIP_X - 0.18, TOOLTIP_Y - (-.05 + (TOOLTIP_LINE_SPACING*i)), 1)
                        endif
                        
                        set i = i + 1
                    endloop
                endif
            //endif
            
            if (.infoIcon[this.pid] == 0) then  
                set .infoIcon[this.pid] = UIPicture.create(TOOLTIP_X - 0.18, TOOLTIP_Y + .28, 0.07, 0.07 * SCREEN_ASPECT_RATIO, 0.1, 0)
                set .costIcon[this.pid] = UIPicture.create(TOOLTIP_X - 0.1,  TOOLTIP_Y + .215, 0.03, 0.03 * SCREEN_ASPECT_RATIO, 0, 0)
                set .infoBox[this.pid] = UIPicture.createEx(TOOLTIP_X, TOOLTIP_Y, 0.20, 0.10, TOOLTIP_BACKGROUND, 120., 60., .localInt(this.pid, TOOLTIP_TEXTURE, ICON_TRANSPARENT))
            endif
            
            call .costIcon[this.pid].setTexture(Inventory.localInt(this.pid, ICON_TOOLTIP_GOLD, ICON_TRANSPARENT))
            call .infoIcon[this.pid].setTexture(Inventory.localInt(this.pid, ICON_TOOLTIP_GOLD, ICON_TRANSPARENT))
            
            call SetUnitVertexColor(.infoBox[this.pid].picture, 255, 255, 255, Inventory.localInt(this.pid, 255, 0))
        endmethod
        
        static method showTooltip takes thistype this, boolean flag returns nothing
            local integer i = 0
            
            loop
                exitwhen i == TOOLTIP_LINES_MAX
                if (i < Inventory.RightSideStart[this.pid]) then
                    call ItemInfoTags[this.pid][i].setPosition(TOOLTIP_X - 0.15, (TOOLTIP_Y - 0.05) - ((TOOLTIP_LINE_SPACING*i)))
                else
                    call ItemInfoTags[this.pid][i].setPosition(TOOLTIP_X + 0.175, (TOOLTIP_Y - 0.05) - ((TOOLTIP_LINE_SPACING*(i-Inventory.RightSideStart[this.pid]))))
                endif
                set i = i + 1
            endloop
                    
            call Inventory.ItemInfoTags[pid][TOOLTIP_LINES_MAX-1].setPosition(TOOLTIP_X + 0.175, TOOLTIP_Y + 0.05)
            
            call .infoBox[this.pid].setPosition(TOOLTIP_X, TOOLTIP_Y)
            call .infoBoxTitle[this.pid].setPosition(TOOLTIP_X - 0.15, TOOLTIP_Y + 0.1)
            call .infoBoxCost[this.pid].setPosition(TOOLTIP_X - 0.11, TOOLTIP_Y + 0.022)
            call .costIcon[this.pid].setPosition(TOOLTIP_X - 0.15 , TOOLTIP_Y + 0.1)

            call .infoBox[this.pid].show(flag, this.camera)
            //call .infoIcon[this.pid].show(flag, this.camera)
            call .infoBoxTitle[this.pid].show(flag, this.camera)
            call this.showLines(this.pid, flag, this.camera)
            call .infoBoxCost[this.pid].show(flag, this.camera)
            call .costIcon[this.pid].show(flag, this.camera)
        endmethod
        
        static method updateTooltip takes thistype this returns nothing
            local integer i = 0
            
            call .infoBox[this.pid].update()
            call .infoIcon[this.pid].update()
            call .infoBoxTitle[this.pid].update()
            call this.updateLines(this.pid)
            call .infoBoxCost[this.pid].update()
            call .costIcon[this.pid].update()
        endmethod
        
    endmodule
    
    module InvItemTooltip
        //
        // Tooltip building 
        //
        
        private static method getStringLine takes string str, integer line returns string
            local integer i = 0
            local integer l = StringLength(str)
            local string o = ""
            local integer c = 0
            loop
                exitwhen i > l
                if (SubString(str, i, i + 1) == "\n") then
                    set c = c + 1
                        
                    if (c == line) then
                        return o
                    else
                        set o = ""
                    endif
                endif

                set o = o + SubString(str, i, i + 1)
                set i = i + 1
            endloop
            return ""
        endmethod
        
        method lTrim takes string s returns string
            local integer i = 0
            loop
                exitwhen SubString(s, i, i + 1) != " "
                set s = SubString(s, 1, 9999)
                set i = i + 1
            endloop
            return s
        endmethod
        
        method buildDescriptionLines takes integer pid, integer startLine returns integer
            local integer i = 0
            local integer l = StringLength(this.info)
            local integer c = 0
            local integer j = 0
            local integer safeSpot = 0
            local string line = ""
            local string safe = ""
            local string char
        
            if (StringLength(.lTrim(this.info)) <= 0) then
                return startLine - 1
            endif
            
            loop
                exitwhen i > l
                
                set char = SubString(this.info, i, i + 1)

                if (char == "\n" or c >= Inventory.TOOLTIP_LINE_LENGTH) then
                    if (char != " " and char != "\n") then
                        set line = safe
                        
                        set i = safeSpot
                    endif
                    
                    call Inventory.setTooltipLine(pid, startLine + j, .lTrim(line))
    
                    set line = ""
                    
                    if (char != "\n") then
                        set i = i - 1
                    endif
                    
                    set char = ""
                    
                    set c = 0
                    set j = j + 1
                endif
                
                if (char == " ") then
                    set safe = line
                    set safeSpot = i
                endif
                
                set line = line + char
                
                set c = c + 1
                set i = i + 1
            endloop
            
            if (j == 0) then
                call Inventory.setTooltipLine(pid, startLine, .lTrim(line))
            elseif (line != "") then
                call Inventory.setTooltipLine(pid, startLine + j, .lTrim(line))
            endif
            
            return (startLine + j) + 1
        endmethod
    endmodule
    
endlibrary

library InventoryBonuses requires optional BonusMod, optional UnitMaxState
endlibrary

globals
    filterfunc InvFuncLClickSlot = null
    filterfunc InvFuncRClickSlot = null
    integer array InvPlayerLastSlot
    UIButton array InvPlayerLastButton
    boolean array InvButtonDisabled
    player InvEventPlayer = null
    InvItem InvEventItem = 0
    integer InvEventSlot = 0
    constant integer INVENTORY_KEY_START = 10000 // above 8191 
endglobals

library EquipmentCore initializer Init requires InventoryCore, EquipmentItem
    
    globals
        public filterfunc FuncLClickSlot = null
        public filterfunc FuncRClickSlot = null
        public integer array PlayerLastSlot 
    endglobals
    
    public /*constant*/ function HERO_WINDOW_NAME takes unit u returns string
        return User[GetOwningPlayer(u)].nameColored
        // return GetHeroProperName(u)
    endfunction
    
    struct Equipment
        //
        // configuration
        //
        static constant real X = 0.425
        static constant real Y = .93
        
        static constant real WINDOW_SIZE = 0.28
        
        static constant real SLOT_OFFSET_Y          = 0.065
        static constant real SLOT_OFFSET_ROWRIGHT_X = 0.460
        static constant real SLOT_OFFSET_ROWLEFT_X  = 0.105
        
        static constant real HERO_NAME_Y = 0.9
        
        static constant real CHARMODEL_OFFSET_X  = X + 0.32
        static constant real CHARMODEL_OFFSET_Y  = 0.200
        
        static constant integer MAX_SLOTS = 14
        static constant real SLOT_WIDTH   = 0.090
        static constant real SLOT_HEIGHT  = 0.090 * SCREEN_ASPECT_RATIO
        
        static constant integer MODEL_DUMMY  = 'e000' // for character model
        static constant integer WINDOW_DUMMY = 'ewin'
        //
        // end config
        //
        
        readonly static boolean Initialized = false
        readonly static integer DisplayCount = 0
        readonly static hashtable Hashtable
        readonly static timer UpdateTimer
        readonly static unit array PlayerCurrentUnit
        readonly static thistype array UnitsIndex
        
        static UIButton array buttons[.MAX_SLOTS]
        static UIPicture array slotButton[.MAX_SLOTS]
        InvItem array item[.MAX_SLOTS]
        integer array itemId[.MAX_SLOTS]
        static UIPicture array pictures[.MAX_SLOTS]
        static UIPicture array selector
        static UIText array title
        static trigger onSocket
        
        UIPicture charModel
        Camera camera
    
        unit unit
        player player
        User user
        
        readonly boolean displayed
        readonly thistype next
        readonly thistype prev
        
        static method operator [] takes unit u returns thistype
            return .UnitsIndex[GetUnitUserData(u)]
        endmethod
 
        method getButton takes integer index returns UIButton
            return this.buttons[(this.user.id * .MAX_SLOTS) + index]
        endmethod
        
        method setButton takes integer index, UIButton value returns nothing
            set this.buttons[(this.user.id * .MAX_SLOTS) + index] = value
        endmethod
        
        static method create takes unit u returns thistype
            local thistype this = thistype.allocate()
            local real x1 = X + SLOT_OFFSET_ROWLEFT_X
            local real x2 = X + SLOT_OFFSET_ROWRIGHT_X
            local real y1 = Y - SLOT_OFFSET_Y
            local integer i = 0

            set this.unit = u
            set this.player = GetOwningPlayer(u)
            set this.user = User[this.player]
            
            set .UnitsIndex[GetUnitUserData(u)] = this

            //
            // GEAR SLOTS
            //
            
            if (this.getButton(0) == 0) then
            
                set selector[this.user.id] = UIPicture.createEx(X - 0.15, (Y + SLOT_OFFSET_Y) - .250, 0, .70, 'e000', 1, 1, 0)
                set selector[this.user.id].animIndex = 56
                call selector[this.user.id].show(false, this.camera)

                call AddSpecialEffectTarget("UI\\TRSHerolevel.mdx", selector[this.user.id].picture, "origin")
                
                // middle
                call this.setButton(12, UIButton.create(x1 + (.SLOT_WIDTH*1.5), y1 - (.SLOT_HEIGHT*5), .SLOT_WIDTH, .SLOT_HEIGHT, 10, 'B005'))
                call this.setButton(13, UIButton.create(x2 - (.SLOT_WIDTH*1.5), y1 - (.SLOT_HEIGHT*5), .SLOT_WIDTH, .SLOT_HEIGHT, 10, 'B00B'))
                
                // left side
                call this.setButton(0, UIButton.create(x1, y1, .SLOT_WIDTH, .SLOT_HEIGHT, 10, 'B003'))
                call this.setButton(1, UIButton.create(x1, y1 - (.SLOT_HEIGHT*1), .SLOT_WIDTH, .SLOT_HEIGHT, 10, 'B004'))
                call this.setButton(2, UIButton.create(x1, y1 - (.SLOT_HEIGHT*2), .SLOT_WIDTH, .SLOT_HEIGHT, 10,'B006'))
                call this.setButton(3, UIButton.create(x1, y1 - (.SLOT_HEIGHT*3), .SLOT_WIDTH, .SLOT_HEIGHT, 10,'B007'))
                call this.setButton(4, UIButton.create(x1, y1 - (.SLOT_HEIGHT*4), .SLOT_WIDTH, .SLOT_HEIGHT, 10,'B008'))
                call this.setButton(5, UIButton.create(x1, y1 - (.SLOT_HEIGHT*5), .SLOT_WIDTH, .SLOT_HEIGHT, 10,'D05W'))
                
                // right side
                call this.setButton(6, UIButton.create(x2, y1, .SLOT_WIDTH, .SLOT_HEIGHT, 10, 'B009'))
                call this.setButton(7, UIButton.create(x2, y1 - (.SLOT_HEIGHT*1), .SLOT_WIDTH, .SLOT_HEIGHT, 10,'B00A'))
            
                call this.setButton(8, UIButton.create(x2, y1 - (.SLOT_HEIGHT*2), .SLOT_WIDTH, .SLOT_HEIGHT, 10,'B00C'))
                call this.setButton(9, UIButton.create(x2, y1 - (.SLOT_HEIGHT*3), .SLOT_WIDTH, .SLOT_HEIGHT, 10,'B00D'))
                call this.setButton(10, UIButton.create(x2, y1 - (.SLOT_HEIGHT*4), .SLOT_WIDTH, .SLOT_HEIGHT, 10,'B00E'))
                call this.setButton(11, UIButton.create(x2, y1 - (.SLOT_HEIGHT*5), .SLOT_WIDTH, .SLOT_HEIGHT, 10,'B00F'))
                            
                loop
                    exitwhen i == 14
                    set this.getButton(i).customValue = i
                    
                     set this.getButton(i).selectUnit = this.unit
                     
                    set this.getButton(i).onLeftClick = FuncLClickSlot
                    set this.getButton(i).onRightClick = FuncRClickSlot
                    
                    set this.slotButton[(this.user.id * MAX_SLOTS) + i] = UIPicture.create(this.getButton(i).minx + (.SLOT_WIDTH/6.3), this.getButton(i).maxy - 0.022, .SLOT_WIDTH * .7, .SLOT_HEIGHT * .7, 9, Inventory.ICON_EMPTY)
                    set this.slotButton[(this.user.id * MAX_SLOTS) + i].customValue = i

                    set i = i + 1
                endloop
                
                set .pictures[(this.user.id * MAX_SLOTS) + 0] = UIPicture.createEx(X, Y, 11, WINDOW_SIZE, .WINDOW_DUMMY, 140., 130., Inventory.localInt(this.user.id, Inventory.RACE_BORDERS_START+(GetHandleId(GetPlayerRace(this.player))-1), Inventory.ICON_TRANSPARENT))
                
            endif
            
            // unit model
            set i = EquipGetHeroModel(GetUnitTypeId(this.unit))
            
            set .charModel = UIPicture.createEx(CHARMODEL_OFFSET_X, .CHARMODEL_OFFSET_Y, 5, HeroModelData(i).scale, MODEL_DUMMY, 1, 1, 0)
            set .charModel.animIndex = 140
            call SetUnitColor(.charModel.picture, this.user.color)

            call AddSpecialEffectTarget(HeroModelData(i).path, .charModel.picture, "origin")

            set .title[this.user.id] = UIText.createEx(this.user.toPlayer(), X/1.4, 0.1, 1)

            set thistype(0).next.prev = this
            set this.next = thistype(0).next
            set thistype(0).next = this

            set this.prev = 0

            return this
        endmethod

        method equip takes InvItem itm, integer equipSlot returns boolean
            local integer slot = itm.slot - 1
            
            if (slot < 0) then
                return false
            endif
            
            if (this.item[equipSlot] != 0) then
                return false
            endif
            
            if (itm.slotAlt - 1 > 0) then
                if (equipSlot != slot and equipSlot != itm.slotAlt -1) then
                    call Inventory.err(this.player, "The item doesn't belong in that slot.")
                    return false
                endif
            else
                if (equipSlot != slot) then
                    call Inventory.err(this.player, "The item doesn't belong in that slot.")
                    return false
                endif
            endif
            
            if (itm.reqUnitType > 0 and GetUnitTypeId(this.unit) != itm.reqUnitType) then
                call Inventory.err(this.player, "Your unit type cannot equip this item.")
                return false
            endif
            
            if (itm.reqAbility > 0 and GetUnitAbilityLevel(this.unit, itm.reqAbility) < 0) then
                call Inventory.err(this.player, "Failed requirements.")
                return false
            endif
            
            if (GetHeroLevel(this.unit) < itm.reqLevel and GetUnitLevel(this.unit) < itm.reqLevel) then
                call Inventory.err(this.player, "Your level is too low to equip that item.")
                return false
            endif
            
            if (itm.equipCondition != null) then
                call TriggerClearConditions(InvItem.equipEval)
                call TriggerAddCondition(InvItem.equipEval, itm.equipCondition)
                set InvItem.eventUnit = this.unit
                if (not TriggerEvaluate(InvItem.equipEval)) then
                    return false
                endif
            endif

            set slot = equipSlot
            
            if (this.item[slot] != 0) then
                return false
            endif
            
            if (itm.equipAbility > 0) then
                call UnitAddAbility(this.unit, itm.equipAbility)
            endif
            
            set this.item[slot] = itm
            set this.itemId[slot] = itm.tempCustomId
            
            call this.slotButton[(this.user.id * .MAX_SLOTS) + slot].setTexture(Inventory.localInt(this.user.id, itm.icon, Inventory.ICON_TRANSPARENT))
            call this.slotButton[(this.user.id * .MAX_SLOTS) + slot].show(true, this.camera)

            set InvEventPlayer = this.player
            set InvEventItem = itm
            set InvEventSlot = equipSlot
            
            if (InvItem.onEquip != null and TriggerEvaluate(InvItem.onEquip)) then
                call TriggerExecute(InvItem.onEquip)
            endif
                    
            // add bonuses
            call itm.applyBonuses(this.unit)
            
            set itm.tempCustomId = 0
            
            return true
        endmethod
        
        method unequip takes InvItem itm, integer slot returns boolean
            local InvItem i2
            local integer i = 0
            local integer cid = itm.tempCustomId
            
            if (slot != itm.slot -1 and slot != itm.slotAlt - 1) then
                return false
            endif
            
            if (itm.equipAbility > 0) then
                call UnitRemoveAbility(this.unit, itm.equipAbility)
            endif
            
            // run unequip event
            set InvEventPlayer = this.player
            set InvEventItem = this.item[slot]
            set InvEventSlot = slot
                
            if (InvItem.onUnequip != null and TriggerEvaluate(InvItem.onUnequip)) then
                call TriggerExecute(InvItem.onUnequip)
            endif
            
            set this.item[slot] = 0

            call this.slotButton[(this.user.id * .MAX_SLOTS) + slot].setTexture(Inventory.ICON_EMPTY)
            call this.slotButton[(this.user.id * .MAX_SLOTS) + slot].show(false, this.camera)
            
            // remove bonuses
            call itm.removeBonuses(this.unit)

            return true
        endmethod
        
        method destroy takes nothing returns nothing
            set this.next.prev = this.prev
            set this.prev.next = this.next
            
            call this.charModel.destroy()
            
            call this.deallocate()
        endmethod

        private static method onDisplay takes nothing returns nothing
            local User user = User(User.LocalId)
            local thistype equipment = Equipment[Equipment.PlayerCurrentUnit[user.id]]
            local real x
            local real y 
            local real z
            
            if (equipment == 0 or not equipment.displayed or Inventory.PlayerCurrent[equipment.user.id] > 0 or User.Local != user.handle) then
                return
            endif
            
            set x = GetUnitX(equipment.unit)
            set y = GetUnitY(equipment.unit)
            set z = GetTerrainZ(x, y) + GetUnitDefaultFlyHeight(equipment.unit)
            
            call equipment.camera.setPosition(x, y, z)
            
            if equipment.camera.applyCameraForPlayer(user.handle, false) then
                call Interface.updateAll(true, true, true)
            endif
        endmethod
        
        method show takes boolean flag, Camera cam returns nothing
            local integer i = 0
            local thistype equip = 0
            local integer len
            local real timeout
            
            if this == 0 or (not flag and not this.displayed) then
                return
            endif
            if flag and not this.displayed then
                set .DisplayCount = .DisplayCount + 1
            endif
            set this.displayed = flag
            set this.camera = cam
            
            if (flag) then
                if (DisplayCount >= 1) then
                    call PauseTimer(.UpdateTimer)
                    
                    call TimerStart(.UpdateTimer, Inventory.UI_REFRESH_RATE, true, function thistype.onDisplay)
                endif
                
                if (.PlayerCurrentUnit[this.user.id] != null) then
                    set equip = Equipment[.PlayerCurrentUnit[this.user.id]]
                endif
                
                if (.PlayerCurrentUnit[this.user.id] != null and .PlayerCurrentUnit[this.user.id] != this.unit and equip != this) then
                    call equip.show(false, this.camera)
                endif
                
                set .PlayerCurrentUnit[this.user.id] = this.unit
                
                if (Inventory.PlayerCurrent[this.user.id] > 0 and Inventory.PlayerCurrent[this.user.id].owner != this.unit) then
                    call Inventory.PlayerCurrent[this.user.id].show(false, this.camera)
                endif

            else
                set .DisplayCount = .DisplayCount - 1
                set .PlayerCurrentUnit[this.user.id] = null
                
                if (DisplayCount == 0) then
                    call PauseTimer(.UpdateTimer)
                else
                    call PauseTimer(.UpdateTimer)
                    call TimerStart(.UpdateTimer, Inventory.UI_REFRESH_RATE, true, function thistype.onDisplay)
                endif
                if (User.Local == this.player) then
                    call ResetToGameCamera(0)
                endif
            endif
            
            call this.charModel.showPlayer(this.user.toPlayer(), flag, this.camera)
            //call this.selector[this.user.id].show(flag, cam)
            
            call SetUnitColor(.charModel.picture, this.user.color)

            // todo: make one line / recode
            set len = StringLength(this.user.name)
            
            call .title[this.user.id].setPosition(X + 0.10, HERO_NAME_Y)

            call SetTextTagText(.title[this.user.id].text, HERO_WINDOW_NAME(this.unit), 8 * 0.0023)
            
            call this.title[this.user.id].show(flag, this.camera)
            
            set i = 0 
            
            loop
                exitwhen i == thistype.MAX_SLOTS
                
                if (.getButton(i) != 0) then
                    call .getButton(i).showPlayer(this.user.handle, flag, this.camera)
                endif
                
                if (this.pictures[(this.user.id * .MAX_SLOTS) + i] != 0) then
                    call .pictures[(this.user.id * .MAX_SLOTS) + i].showPlayer(this.user.handle, flag, this.camera)
                endif
                
                if (this.item[i] > 0) then
                    call slotButton[(this.user.id * .MAX_SLOTS) + i].showPlayer(this.user.handle, flag, this.camera)
                endif
                
                set i = i + 1
            endloop
        endmethod
        
        private static method onInit takes nothing returns nothing
            set thistype.Hashtable = InitHashtable()
            set thistype.UpdateTimer = CreateTimer()
            set thistype.Initialized = true
        endmethod
        
    endstruct
    
    private function OnInventoryItemClick takes nothing returns nothing
        local UIButton but = GetTriggerButton()
        local player p = GetClickingPlayer()
        local integer pid = GetPlayerId(p)
        local Inventory inv =  Inventory.PlayerCurrent[pid]
        local integer slot =  but.customValue
        local integer itemId = 0
        local integer last = InvPlayerLastSlot[inv.pid] - 1
        local integer lastItemId
        local UIButton lastButton = InvPlayerLastButton[inv.pid]
        local Equipment gear = Equipment[Equipment.PlayerCurrentUnit[inv.pid]]
        local integer gearSlot
        local InvItem itm
        
        call Equipment.selector[inv.pid].show(false, inv.camera)
       
        if (gear <= 0) then
            return
        endif
        
        if (PlayerLastSlot[inv.pid] > 0) then
            
            set gearSlot = PlayerLastSlot[inv.pid] - 1

            if (inv.getItem(slot) == 0) then
                set gear.item[gearSlot].tempCustomId = gear.itemId[gearSlot]
                call inv.setItem(slot, gear.item[gearSlot])
                
                set gear.item[gearSlot].tempCustomId = gear.itemId[gearSlot]
                call gear.unequip(gear.item[gearSlot], gearSlot)
            endif
            
            set PlayerLastSlot[inv.pid] = 0
        else
            set itm = inv.getItem(slot)
            
            if (itm > 0 and not itm.isSocket) then
                set but = gear.getButton(itm.slot - 1)
                
                call Equipment.selector[inv.pid].show(true, inv.camera)
                call Equipment.selector[inv.pid].setPosition(but.centerx - 0.007, but.centery + 0.0272)
                call Equipment.selector[inv.pid].showPlayer(Player(inv.pid), true, inv.camera)
            endif
        endif
    endfunction
    
    private function OnInventoryItemRightClick takes nothing returns nothing
        local UIButton but = GetTriggerButton()
        local player p = GetClickingPlayer()
        local integer pid = GetPlayerId(p)
        local Inventory inv =  Inventory.PlayerCurrent[pid]
        local integer slot =  but.customValue
        local Equipment gear = Equipment[Equipment.PlayerCurrentUnit[inv.pid]]
        local InvItem itm = inv.getItem(slot)
        local integer gearSlot = itm.slot - 1
        local integer unequippedSlot = 0
        local InvItem unequipItem = 0
        local integer unequipId = 0
        
        if (gear <= 0 or itm <= 0) then
            return
        endif
        
        set itm.tempCustomId = inv.getItemId(slot)
        
        if (gear.item[gearSlot] > 0) then
            set unequipId = gear.itemId[gearSlot]
            set gear.item[gearSlot].tempCustomId = unequipId
            call gear.unequip(gear.item[gearSlot], gearSlot)
            set unequippedSlot = InvEventSlot
            set unequipItem = InvEventItem
        endif
        
        set itm.tempCustomId = inv.getItemId(slot)
        
        if (gear.equip(itm, itm.slot - 1)) then
            call inv.setItem(slot, 0)
            set unequipItem.tempCustomId = unequipId
            call inv.addItem(unequipItem)
        elseif (unequipItem > 0) then
            call gear.equip(unequipItem, unequippedSlot)
        endif
    endfunction

    private function RClickItemSlot takes nothing returns boolean
        local UIButton but   = GetTriggerButton()
        local unit u         = Equipment.PlayerCurrentUnit[GetPlayerId(GetClickingPlayer())]
        local Equipment gear = Equipment[u]
        local Inventory inv  = Inventory[u]
        local integer slot   = but.customValue
        local integer itemId
        local InvItem itm
        local integer cid
        
        if (GetClickingPlayer() != User(inv.pid).handle or gear.item[slot] <= 0) then
            return false
        endif

        // clear tooltip
        call inv.showLines(inv.pid, false, inv.camera)
        
        set itm = gear.item[slot]
        set itemId = itm.id
        set cid = gear.itemId[slot]
        
        set gear.item[slot].tempCustomId = cid
        
        if (gear.unequip(itm, slot)) then
            set itm.tempCustomId = cid
            if (not inv.addItem(itm)) then
                set gear.item[slot].tempCustomId = cid
                call gear.equip(itm, slot)
                return false
            endif
        else
            return false
        endif
    
        call Inventory.showTooltip(inv, false)
        
        return false
    endfunction
    
    private function LClickItemSlot takes nothing returns boolean
        local UIButton but = GetTriggerButton()
        local player p = GetClickingPlayer()
        local Equipment equip = Equipment[Equipment.PlayerCurrentUnit[GetPlayerId(p)]]
        local Inventory inv = Inventory.PlayerCurrent[equip.user.id]
        local integer slot =  but.customValue
        local integer last = InvPlayerLastSlot[inv.pid] - 1
        local integer itemId = 0
        local UIButton lastButton = InvPlayerLastButton[equip.user.id]
        local InvItem itm
        
        if (User.Local == p) then
            call SelectUnit(but.picture, false)
            call SelectUnit(equip.unit, true)
        endif
        
        if (p != equip.user.handle) then
            return false
        endif
        
        if (InvButtonDisabled[but]) then
            return false
        endif

        call inv.showLines(inv.pid, false, inv.camera)
        
        set PlayerLastSlot[equip.user.id] = slot + 1
        
        // equip item
        if (inv > 0 and last+1 > 0) then
        
            set last = (Inventory.MAX_SLOTS * inv.currentPage) + last
            
            set itm = inv.getItem(last)
            
            if (itm.slot - 1 == slot or itm.slotAlt - 1 == slot) then
                set itm.tempCustomId = inv.getItemId(last)
                
                if (equip.equip(itm, slot)) then
                    set PlayerLastSlot[inv.pid] = 0
                    call inv.setItem(last, 0)
            
                    call TimerStart(NewTimerEx(but), 2, false, function InventoryCore_GracePeriod)
                    set InvButtonDisabled[but] = true
                endif
            endif
        endif
        
        set InvPlayerLastButton[equip.user.id] = but
        set InvPlayerLastSlot[equip.user.id] = 0
        
        if (but != lastButton) then
            call SetUnitVertexColor(lastButton.picture, 255, 255, 255, 255)
            call SetUnitVertexColor(but.picture, 175, 175, 175, 255)
        endif
        
        set itemId = equip.item[slot].id
        
        call Inventory.selector[inv.pid].show(false, inv.camera)
        call Equipment.selector[inv.pid].setPosition(but.centerx - 0.007, but.centery + 0.0272)
        call Equipment.selector[inv.pid].showPlayer(Player(inv.pid), true, inv.camera)
        
        if (itemId > 0) then
            set equip.item[slot].tempCustomId = equip.itemId[slot]
            
            call inv.setTooltipTitle(GetObjectName(itemId))
            call GetInvItem(itemId).buildDescription(inv.owner)
            call inv.setTooltipCost("|cffffcc00" + I2S(GetInvItem(itemId).cost) + "|r")
            call inv.setTooltipIcon(inv.localInt(inv.pid, GetItemIcon(itemId), Inventory.ICON_TRANSPARENT))
            
            set equip.item[slot].tempCustomId = 0
        endif
        
        // display tooltip
        set Inventory.TOOLTIP_X = but.minx - 0.4
        set Inventory.TOOLTIP_Y = but.miny - 0.08
        
        call Inventory.showTooltip(inv, itemId > 0)

        return false
    endfunction
    
    private function Init takes nothing returns nothing
        set FuncLClickSlot = Filter(function LClickItemSlot)
        set FuncRClickSlot = Filter(function RClickItemSlot)
        call Inventory.addLeftClickHook(function OnInventoryItemClick)
        call Inventory.addRightClickHook(function OnInventoryItemRightClick)
    endfunction

endlibrary

library EquipmentItem initializer Init requires BonusMod, InventoryCore
    
    globals
        public string array BonusString
    endglobals

    public function Init takes nothing returns nothing
        set BonusString[BONUS_DAMAGE] = "Damage"
        set BonusString[BONUS_ARMOR] = "Armor"
        set BonusString[BONUS_STRENGTH] = "Strength"
        set BonusString[BONUS_AGILITY] = "Agility"
        set BonusString[BONUS_INTELLIGENCE] = "Intelligence"
        set BonusString[BONUS_ATTACK_SPEED] = "Attack Speed"
        set BonusString[BONUS_SIGHT_RANGE] = "Visibility"
        set BonusString[BONUS_LIFE_REGEN] = "Life Regen"
        set BonusString[BONUS_MANA_REGEN_PERCENT] = "% Mana Regen"
        set BonusString[BONUS_MOVEMENT_SPEED] = "Movement Speed"
        set BonusString[BONUS_LIFE]  = "Life"
        set BonusString[BONUS_MANA]  = "Mana"
    endfunction
    
    module InvItemEquipment
        //
        // configuration
        //
        
        public static constant integer MAX_BONUSES = 1000 // can be any number
        
        //
        // end config
        //
        
        static trigger onEquip = null
        static trigger onUnequip = null
        public static trigger equipEval = CreateTrigger()
        public static unit eventUnit = null
         
        integer slot
        integer slotAlt
        integer equipAbility
        integer reqLevel
        integer reqUnitType
        integer reqAbility
        string class
        boolexpr equipCondition
        string equipConditionStr
        string equipConditionStrPrefix
        
        static if (LIBRARY_BonusMod) then
            integer bonuses
            
            public static key KeyBonusType
            public static key KeyBonusAmount
            public static key KeyBonusMin
            public static key KeyBonusMax
            public static key KeyBonusRand
            
            public static integer KEY_BONUS_TYPE    = INVENTORY_KEY_START + KeyBonusType
            public static integer KEY_BONUS_AMOUNT  = INVENTORY_KEY_START + KeyBonusAmount
            public static integer KEY_BONUS_MIN     = INVENTORY_KEY_START + KeyBonusMin
            public static integer KEY_BONUS_MAX     = INVENTORY_KEY_START + KeyBonusMax
            public static integer KEY_BONUS_RND     = INVENTORY_KEY_START + KeyBonusRand
            
            method addBonusRange takes Bonus bonusType, integer base, integer min, integer max returns nothing
                call SaveInteger(Inventory.Hashtable, KEY_BONUS_TYPE,(this*.MAX_BONUSES)+this.bonuses, bonusType)
                call SaveInteger(Inventory.Hashtable, KEY_BONUS_AMOUNT,(this*.MAX_BONUSES)+this.bonuses, base)
                call SaveInteger(Inventory.Hashtable, KEY_BONUS_MIN,(this*.MAX_BONUSES)+this.bonuses, min)
                call SaveInteger(Inventory.Hashtable, KEY_BONUS_MAX,(this*.MAX_BONUSES)+this.bonuses, max)
                set this.bonuses = this.bonuses + 1
            endmethod
            
            method addBonus takes Bonus bonusType, integer amount returns nothing
                call SaveInteger(Inventory.Hashtable, KEY_BONUS_TYPE,(this*.MAX_BONUSES)+this.bonuses, bonusType)
                call SaveInteger(Inventory.Hashtable, KEY_BONUS_AMOUNT,(this*.MAX_BONUSES)+this.bonuses, amount)
                set this.bonuses = this.bonuses + 1
            endmethod
            
            method getBonus takes integer index returns Bonus
                return LoadInteger(Inventory.Hashtable, KEY_BONUS_TYPE, (this*.MAX_BONUSES)+index)
            endmethod
            
            method getBonusAmount takes integer index returns integer
                return LoadInteger(Inventory.Hashtable, KEY_BONUS_AMOUNT, (this*.MAX_BONUSES)+index)
            endmethod
            
            method getBonusMin takes integer index returns integer
                return LoadInteger(Inventory.Hashtable, KEY_BONUS_MIN, (this*.MAX_BONUSES)+index)
            endmethod
            
            method getBonusMax takes integer index returns integer
                return LoadInteger(Inventory.Hashtable, KEY_BONUS_MAX, (this*.MAX_BONUSES)+index)
            endmethod
            
            static method Bonus2S takes Bonus b returns string
                return BonusString[b]
            endmethod
            
            method getBonusTotal takes integer index returns integer
                local integer total = getBonusAmount(index)
                set bj_cineModeSavedSeed = GetRandomInt(0, 1000000)
                call SetRandomSeed(InvCustomItem(this.tempCustomId).seed())
                set total = total + (GetRandomInt(this.getBonusMin(index), this.getBonusMax(index)))
                call SetRandomSeed(bj_cineModeSavedSeed)
                return total
            endmethod
            
            method addBonusesMultiplier takes unit u, integer m returns nothing
                local integer i = 0
                local integer n = 0
                local integer total
                local InvItem itm
                
                loop
                    exitwhen i >= this.bonuses
                    
                    call BonusModStruct.addBonus(u, this.getBonus(i), this.getBonusTotal(i)*m)
                    
                    set i = i + 1
                endloop

                set i = 0
                
                loop
                    exitwhen i >= this.sockets
                    
                    set itm = this.getSocket(i)
                    set itm.tempCustomId = this.socketId(i)
                    
                    set n = 0
                    
                    loop
                        exitwhen n == itm.bonuses
                        
                        call BonusModStruct.addBonus(u, itm.getBonus(n), itm.getBonusTotal(n)*m)
                        
                        set n = n + 1
                    endloop
                    
                    set i = i + 1
                endloop
            endmethod
            
            method applyBonuses takes unit u returns nothing
                call addBonusesMultiplier(u, 1)
            endmethod
            
            method removeBonuses takes unit u returns nothing
                call addBonusesMultiplier(u, -1)
            endmethod
        endif
        
        static method GearSlotName takes integer slot returns string
            if (slot == 1) then
                return "Head"
            elseif (slot == 2) then
                return "Shoulder"
            elseif (slot == 8) then
                return "Earring"
            elseif (slot == 3) then
                return "Chest"
            elseif (slot == 4) then
                return "Belt"
            elseif (slot == 5) then
                return "Pants"
            elseif (slot == 6 or slot == 12) then
                return "Ring"
            elseif (slot == 7) then
                return "Amulet"
            elseif (slot == 9) then
                return "Gloves"
            elseif (slot == 10) then
                return "Bracers"
            elseif (slot == 11) then
                return "Boots"
            elseif (slot == 13) then
                return "Weapon"
            elseif (slot == 14) then
                return "Offhand"
            endif
            
            return ""
        endmethod

        method buildDescription takes unit forUnit returns string
            local integer i = 0
            local integer n = 0
            local string out = ""
            local string bonusName
            local integer lines = 0
            local integer pid = GetPlayerId(GetOwningPlayer(forUnit))
            local integer total
            local InvItem itm
            
            call EquipmentItem_Init.execute()
            
            call Inventory.clearLines(pid)
            
            // slot type
            set out = GearSlotName(this.slot)
            
            if (out != "") then
                set out = "|cffffcc00Slot:|r " + out

                call Inventory.setTooltipSlot(pid, lines, out)
                call Inventory.ItemInfoTags[pid][Inventory.TOOLTIP_LINES_MAX].show(true, Inventory.PlayerCurrent[pid].camera)
            endif
            
            // item description
            set lines = this.buildDescriptionLines(pid, 0)
            
            if (lines != 0) then
                set lines = lines + 1
            endif
            
            // item ability
            if (this.ability > 0) then
                set out = "|cfffedaac" + GetObjectName(this.ability) + "|r (Does not stack)\n"
                
                call Inventory.setTooltipLine(pid, lines, out)
                call Inventory.ItemInfoTags[pid][lines].show(true, Inventory.PlayerCurrent[pid].camera)
                
                set lines = lines + 1
            endif
            
            // equip ability
            if (this.equipAbility > 0) then
                set out = "|cfffedaac" + GetObjectName(this.equipAbility) + "|r\n"
                
                call Inventory.setTooltipLine(pid, lines, out)
                call Inventory.ItemInfoTags[pid][lines].show(true, Inventory.PlayerCurrent[pid].camera)
                
                set lines = lines + 1
            endif
            
            // equip bonuses
            static if (LIBRARY_BonusMod) then
                loop
                    exitwhen i >= this.bonuses
                    
                    set bonusName =  .Bonus2S(this.getBonus(i))
  
                    if (bonusName != null and bonusName != "") then
                        
                        set total = this.getBonusTotal(i)
                        
                        if (total > 0) then
                            set out = "|cfffedaac+" + I2S(total) + " to " + bonusName + "|r"
                            
                            call Inventory.setTooltipLine(pid, lines, out)
                            call Inventory.ItemInfoTags[pid][lines].show(true, Inventory.PlayerCurrent[pid].camera)
                            set lines = lines + 1
                        endif

                    endif
                    
                    set i = i + 1
                endloop
            endif
            
            set Inventory.RightSideStart[pid] = lines
            
            // level requirement
            if (this.reqLevel > 0) then
                if (GetHeroLevel(forUnit) < this.reqLevel and GetUnitLevel(forUnit) < this.reqLevel) then
                    set out = "|cffffcc00Level Req:|r |cffff0000" + I2S(this.reqLevel) + "|r"
                else
                    set out = "|cffffcc00Level Req:|r " + I2S(this.reqLevel)
                endif
                
                call Inventory.setTooltipLine(pid, lines, out)
                call Inventory.ItemInfoTags[pid][lines].show(true, Inventory.PlayerCurrent[pid].camera)
                
                set lines = lines + 1
            endif
            
            // unit type requirement
            if (this.reqUnitType > 0) then
                if (GetUnitTypeId(forUnit) != this.reqUnitType) then
                    set out = "|cffffcc00Usable:|r |cffff0000" + GetObjectName(this.reqUnitType) + "|r"
                else
                    set out = "|cffffcc00Usable:|r |cff2eb82e" + GetObjectName(this.reqUnitType) + "|r"
                endif
                
                call Inventory.setTooltipLine(pid, lines, out)
                call Inventory.ItemInfoTags[pid][lines].show(true, Inventory.PlayerCurrent[pid].camera)
                
                set lines = lines + 1
            endif
            
            // ability requirement
            if (this.reqAbility > 0) then
                if (GetUnitAbilityLevel(forUnit, this.reqAbility) < 0) then
                    set out = "|cffff0000Requires:|r |cffff0000" + GetObjectName(this.reqAbility) + "|r"
                else    
                    set out = "|cffffcc00Requires:|r " + GetObjectName(this.reqAbility)
                endif
                
                call Inventory.setTooltipLine(pid, lines, out)
                call Inventory.ItemInfoTags[pid][lines].show(true, Inventory.PlayerCurrent[pid].camera)
                
                set lines = lines + 1
            endif
            
            // custom
            if (this.equipCondition != null and this.equipConditionStr != null and this.equipConditionStr != "") then
                call TriggerClearConditions(InvItem.equipEval)
                call TriggerAddCondition(InvItem.equipEval, this.equipCondition)
                set InvItem.eventUnit = forUnit
                if (not TriggerEvaluate(InvItem.equipEval)) then
                    set out = "|cffffcc00" + this.equipConditionStrPrefix + ":|r " + this.equipConditionStr
                else
                    set out = "|cffffcc00" + this.equipConditionStrPrefix + ":|r " + this.equipConditionStr
                endif
                
                call Inventory.setTooltipLine(pid, lines, out)
                call Inventory.ItemInfoTags[pid][lines].show(true, Inventory.PlayerCurrent[pid].camera)
                
                set lines = lines + 1
            endif
            
            // sockets
            set i = 0
            
            if (this.maxSockets > 0) then
                if (Inventory.RightSideStart[pid] != lines) then
                    call Inventory.setTooltipLine(pid, lines, "")
                    call Inventory.ItemInfoTags[pid][lines].show(true, Inventory.PlayerCurrent[pid].camera)
                    set lines = lines + 1
                endif
                call Inventory.setTooltipLine(pid, lines, "Sockets: " + I2S(this.sockets) + "/" + I2S(this.maxSockets))
                call Inventory.ItemInfoTags[pid][lines].show(true, Inventory.PlayerCurrent[pid].camera)
                set lines = lines + 1
            endif
            
            loop
                exitwhen i >= this.maxSockets
                
                set itm = this.getSocket(i)
                
                if (itm > 0) then
                
                    set itm.tempCustomId = this.socketId(i)
                    
                    set n = 0
                    
                    loop
                        exitwhen n >= itm.bonuses
                    
                        set bonusName =  .Bonus2S(itm.getBonus(n))
   
                        if (bonusName != null and bonusName != "") then
                            
                            set total = itm.getBonusTotal(n)
                            
                            if (total > 0) then
                                set out = "|cff5566bb+" + I2S(total) + " to " + bonusName + "|r\n"
                                
                                call Inventory.setTooltipLine(pid, lines, out)
                                call Inventory.ItemInfoTags[pid][lines].show(true, Inventory.PlayerCurrent[pid].camera)
                                
                                set lines = lines + 1
                            endif
                        endif
                        
                        set n = n + 1
                    endloop
                endif
                
                set i = i + 1
            endloop

            return out
        endmethod
        
    endmodule
    
    function SetEquipItemStats takes integer slot, integer s2, integer ab, integer lvl, integer utype, integer rab, integer dmg, integer def, integer str, integer agi, integer it, integer as, integer sight, integer lreg, integer mreg, InvItem itm returns InvItem
        set itm.slot = slot
        set itm.slotAlt = s2
        set itm.reqUnitType = utype
        set itm.equipAbility = ab
        set itm.reqLevel = lvl
        set itm.reqUnitType = utype
        set itm.reqAbility = rab
        
        if (dmg != 0) then
            call itm.addBonus(BONUS_DAMAGE, dmg)
        endif
        
        if (def != 0) then
            call itm.addBonus(BONUS_ARMOR, def)
        endif
        
        if (str != 0) then
            call itm.addBonus(BONUS_STRENGTH, str)
        endif
        
        if (agi != 0) then
            call itm.addBonus(BONUS_AGILITY, agi)
        endif
        
        if (it != 0) then
            call itm.addBonus(BONUS_INTELLIGENCE, it)
        endif

        if (as != 0) then
            call itm.addBonus(BONUS_ATTACK_SPEED, as)
        endif
        
        if (sight != 0) then
            call itm.addBonus(BONUS_SIGHT_RANGE, sight)
        endif
        
        if (lreg != 0) then
            call itm.addBonus(BONUS_LIFE_REGEN, lreg)
        endif
        
        if (mreg != 0) then
            call itm.addBonus(BONUS_MANA_REGEN_PERCENT, lreg)
        endif
        
        return itm
    endfunction

    
endlibrary

library EquipmentSockets

    module InvItemSocket
        integer maxSockets
        boolean isSocket
        
        static hashtable SocketTable = InitHashtable()
        
        method operator sockets takes nothing returns integer
            return LoadInteger(.SocketTable, this.tempCustomId, KEY_SOCKETS_COUNT*100)
        endmethod
        
        method operator sockets= takes integer val returns nothing
            call SaveInteger(.SocketTable, this.tempCustomId, KEY_SOCKETS_COUNT*100, val)
        endmethod
        
        method socketId takes integer index returns integer
            return LoadInteger(.SocketTable, this.tempCustomId, (KEY_SOCKETS_ID*100) + index)
        endmethod
        
        private static key KEY_SOCKETS
        private static key KEY_SOCKETS_ID
        private static key KEY_SOCKETS_COUNT
        
        method addSocket takes InvItem socket returns boolean
            if this.isSocket then
                return false
            endif
            
            if (this.sockets >= this.maxSockets) then
                return false
            endif
            
            call SaveInteger(.SocketTable, this.tempCustomId, (KEY_SOCKETS*100) + this.sockets, socket)
            call SaveInteger(.SocketTable, this.tempCustomId, (KEY_SOCKETS_ID*100) + this.sockets, socket.tempCustomId)
            
            set this.sockets = this.sockets + 1
            
            return true
        endmethod
        
        method getSocket takes integer index returns InvItem
            if this.isSocket then
                return 0
            endif
            
            return LoadInteger(.SocketTable, this.tempCustomId, (KEY_SOCKETS*100) + index)
        endmethod
        
    endmodule

endlibrary

library EquipHeroModels initializer Init
    
    globals
        private InventoryTable HeroModels
        private string array Path
        private integer Models = 0
    endglobals
    
    struct HeroModelData
        string path
        real scale
    endstruct
    
    function EquipSetHeroModel takes integer utype, real scale, string path returns nothing
        local HeroModelData data = HeroModelData.create()
        set data.path = path
        set data.scale = scale
        set HeroModels[utype] = data
    endfunction
    
    function EquipGetHeroModel takes integer id returns HeroModelData
        return HeroModels[id]
    endfunction
    
    private function Init takes nothing returns nothing
        set HeroModels=InventoryTable.create()
        
        //
        // configuration
        //
        call EquipSetHeroModel('Hpal', 0.10, "units\\human\\HeroPaladin\\HeroPaladin.mdl")
        call EquipSetHeroModel('hfoo', 0.08, "units\\human\\Footman\\Footman.mdl")
        call EquipSetHeroModel('Ulic', 0.08, "units\\undead\\HeroLich\\HeroLich.mdl")
        call EquipSetHeroModel('Obla', 0.08, "units\\orc\\HeroBladeMaster\\HeroBladeMaster.mdl")
        call EquipSetHeroModel('Edem', 0.08, "units\\nightelf\\HeroDemonHunter\\HeroDemonHunter.mdl")
        //
        // end config
        //
    endfunction

endlibrary

library EquipItemParser requires EquipmentItem
    
    //
    // configuration
    //
    public function ParseTypeToSlot takes InvItem itm, string t returns nothing
        if (t == "weapon") then
            set itm.slot = 13
        elseif(t == "shield") then
            set itm.slot = 14
        elseif(t == "armor") then
            set itm.slot = 3
        elseif(t == "boots") then
            set itm.slot = 11
        elseif(t == "bracers") then
            set itm.slot = 10
        elseif(t == "gloves") then
            set itm.slot = 9
        elseif(t == "belt") then
            set itm.slot = 4
        elseif(t == "helm") then
            set itm.slot = 1
        elseif(t == "pauldron") then
            set itm.slot = 2
            set itm.slotAlt = 9
        elseif(t == "amulet") then
            set itm.slot = 7
        elseif(t == "pants") then
            set itm.slot = 5
        elseif(t == "ring") then
            set itm.slot = 6
            set itm.slotAlt = 12
        elseif(t == "shield") then
            set itm.slot = 14
        elseif(t == "socket" or t == "gem") then
            set itm.isSocket = true
        endif
    endfunction

    public function ParseClass takes InvItem itm, string c returns nothing
        if (c == "1h") then
            set itm.slotAlt = 14
        endif
    endfunction
    
    public function ParseBonusParam takes InvItem itm, string param, string value, string min, string max returns nothing
        if (param == "dmg") then
            call itm.addBonusRange(BONUS_DAMAGE, S2I(value), S2I(min), S2I(max))
        elseif (param == "def") then
            call itm.addBonusRange(BONUS_ARMOR, S2I(value), S2I(min), S2I(max))
        elseif (param == "str") then
            call itm.addBonusRange(BONUS_STRENGTH, S2I(value), S2I(min), S2I(max))
        elseif (param == "agi") then
            call itm.addBonusRange(BONUS_AGILITY, S2I(value), S2I(min), S2I(max))
        elseif (param == "int") then
            call itm.addBonusRange(BONUS_INTELLIGENCE, S2I(value), S2I(min), S2I(max))
        elseif (param == "ias") then
            call itm.addBonusRange(BONUS_ATTACK_SPEED, S2I(value), S2I(min), S2I(max))
        elseif (param == "hp" or param == "life") then
            call itm.addBonusRange(BONUS_LIFE, S2I(value), S2I(min), S2I(max))
        elseif (param == "mp" or param == "mana") then
            call itm.addBonusRange(BONUS_MANA, S2I(value), S2I(min), S2I(max))
        elseif (param == "manareg") then
            call itm.addBonusRange(BONUS_MANA_REGEN, S2I(value), S2I(min), S2I(max))
        elseif (param == "sight") then
            call itm.addBonusRange(BONUS_SIGHT_RANGE, S2I(value), S2I(min), S2I(max))
        elseif (param == "ms" or param == "move") then
            call itm.addBonusRange(BONUS_MOVEMENT_SPEED, S2I(value), S2I(min), S2I(max))
        elseif (param == "lifereg") then
            call itm.addBonusRange(BONUS_LIFE_REGEN, S2I(value), S2I(min), S2I(max))
        endif
    endfunction
    //
    // end
    //
    
    // String2Rawcode:
    public function Char2Id takes string c returns integer
        local integer i = 0
        local string abc = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        local string t

        loop
            set t = SubString(abc,i,i + 1)
            exitwhen t == null or t == c
            set i = i + 1
        endloop
        if i < 10 then
            return i + 48
        elseif i < 36 then
            return i + 65 - 10
        endif
        return i + 97 - 36
    endfunction

    public function String2Id takes string s returns integer
        return ((Char2Id(SubString(s,0,1)) * 256 + Char2Id(SubString(s,1,2))) * 256 + Char2Id(SubString(s,2,3))) * 256 + Char2Id(SubString(s,3,4))
    endfunction

    public function Id2Char takes integer i returns string
        local string abc = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

        if i >= 97 then
            return SubString(abc,i - 97 + 36,i - 96 + 36)
        elseif i >= 65 then
            return SubString(abc,i - 65 + 10,i - 64 + 10)
        endif
        return SubString(abc,i - 48,i - 47)
    endfunction

    public function Id2String takes integer id returns string
        local integer t = id / 256
        local string r = Id2Char(id - 256 * t)
        set id = t / 256
        set r = Id2Char(t - 256 * id) + r
        set t = id / 256
        return Id2Char(t) + Id2Char(id - 256 * t) + r
    endfunction
    // end
    
    public function ParseRawCodeStr takes string value returns integer
        local integer l = StringLength(value)
        
        if (l == 4 or l == 1 or l == 3 or l == 6) then
            
            if (SubString(value, 0, 1) == "'") then
                set value = SubString(value, 1, 9999)
                set l = l - 1
            endif
        
            if (SubString(value, l-1, l) == "'") then
                set value = SubString(value, 0, l-1)
            endif
            
            return String2Id(value)
        endif
        
        return S2I(value)
    endfunction
    
    private function ParseParam takes InvItem itm, string param, string value returns nothing
        if (param == "lvl") then
            set itm.reqLevel = S2I(value)
        elseif (param == "class") then
            call ParseClass(itm, value)
        elseif(param == "icon") then
            set itm.icon = ParseRawCodeStr(value)
        elseif(param == "utype") then
            set itm.reqUnitType = ParseRawCodeStr(value)
        elseif(param == "abil") then
            set itm.reqAbility = ParseRawCodeStr(value)
        elseif(param == "cost") then
            set itm.cost = S2I(value)
        elseif(param == "type") then
            call ParseTypeToSlot(itm, value)
        elseif(param == "maxsock") then
            set itm.maxSockets = S2I(value)
        endif
    endfunction
    
    globals
        public string TypeSlot
    endglobals
    
    function InitEquipItem takes integer itemId, string data returns InvItem
        local InvItem itm = InvItem.create()
        local integer len = StringLength(data)
        local integer i = 0
        local string desc = ""
        local string param = ""
        local string array value
        local integer curVal = 0
        
        local string s = ""
        local integer step = 0

        set itm.id = itemId
        set InvItem.InventoryTable[itm.id] = itm

        loop
            exitwhen i >= len
            
            set s = SubString(data, i, i + 1)
            
            if (step > 0 and s == " ") then
                // do nothing
            elseif (step == 0) then
                
                if (s == "^") then
                    set step = 1
                else
                    set desc = desc + s
                endif
            
            elseif (step == 1) then
            
                if (s == "^") then
                    set step = 3
                    set param = ""
                elseif (s == "=") then
                    set step = 2
                else
                    set param = param + s
                endif
                
            elseif (step == 2) then
            
                if (s == ";") then
                    call ParseParam(itm, StringCase(param, false), value[0])
                    
                    set param = ""
                    set value[0] = ""
                    set step = 1
                else
                    set value[0] = value[0] + s
                endif
                
            elseif (step == 3) then
            
                if (s == "=") then
                    set step = 4
                else
                    set param = param + s
                endif
                
            elseif (step == 4) then
            
                if (s == ";") then
                    set curVal = curVal + 1
                    
                    if (curVal >= 3) then
                        if (value[0] == "") then
                            set value[0] = "0"
                        elseif (value[1] == "") then
                            set value[0] = "0"
                      elseif (value[2] == "") then
                            set value[0] = "0"
                        endif
                        
                        call ParseBonusParam(itm, param, value[0], value[1], value[2])
                        
                        set step = 3
                        set curVal = 0
                        set value[0]=""
                        set value[1]=""
                        set value[2]=""
                        set param=""
                    endif
                    
                else
                    set value[curVal] = value[curVal] + s
                endif
                
            endif
                        
            set i = i + 1
        endloop
        
        set itm.info = desc
        
        return itm
    endfunction
    
endlibrary

scope InvItemSetups initializer Init
    
    function CustomItemCondition takes nothing returns boolean
        local integer id = GetUnitTypeId(InvItem.eventUnit)
        return (id == 'Hpal' or id == 'Obla') // Paladin or Blademaster
    endfunction
    
    private function Init takes nothing returns nothing
        local InvItem itm
        
        // The more verbose way to delcare items:
        // Crown of Kings +5
        set itm = CreateInvItem('ckng', 'B00G', 1000, 0, "Increases the Strength, Intelligence, and Agility of the Hero by 5 when worn.")
        set itm.slot = 1 
        set itm.reqUnitType = 'Hpal'
        set itm.reqLevel = 3
        set itm.maxSockets = 1
        
        call itm.addBonus(BONUS_STRENGTH, 5)
        call itm.addBonus(BONUS_AGILITY, 5)
        call itm.addBonus(BONUS_INTELLIGENCE, 5)
        
        // with string parser
        // Claws of Attack +15
        call InitEquipItem.execute('ratf', "Increases the attack damage of the Hero by 15 when worn.^type=weapon; class=1h; maxsock=1; icon='D009'; cost=28; ^dmg=15;0;0;")
        
        // Robe of the Last Guardian
        call InitEquipItem.execute('I007', "Powerful magic robe.^type=armor; lvl=10; icon=B00Z; utype='Ulic'; cost=600; maxsock=2; ^def=0;10;20; int=20;0;5; life=300;0;0;")
        
        // Gems
        call InitEquipItem.execute('I009', "Can be socketed..^type=gem; icon=B012; cost=600; ^life=0;10;50;")
        call InitEquipItem.execute('I00A', "Can be socketed..^type=gem; icon=B013; cost=600; ^mana=0;5;35;")
        
        // two lines
        // Mask of Death
        set itm = CreateInvItem('modt', 'D02Z', 1000, 0, "While wearing this mask, a Hero will recover hit points equal to 50% of the attack damage dealt to an enemy unit.")
        set itm = SetEquipItemStats(/*slot=*/1, /*slot2=*/0, /*abil=*/'AIva', /*lvl=*/0, /*utype=*/0, /*reqAbil=*/0, /*dmg=*/0, /*def=*/0, /*str=*/0, /*agi=*/0, /*int=*/0, /*atckspd=*/0, /*sight=*/0, /*lifereg=*/0, /*manareg=*/0, itm)
        set itm.maxSockets = 1
        
        // Orb of Frost
        set itm = CreateInvItem('ofro', 'D04U', 1000, 'A003', " Adds 6 bonus cold damage to the attack of a Hero when carried. The Hero's attacks also become ranged when attacking air and slow the movement speed and attack rate of the enemy for 1 second.")
    
        // Boots of Quel'Thalas +6
        set itm = CreateInvItem('belv', 'B00I', 500, 0, " Increases the Agility of the Hero by 6 when worn.")
        set itm.slot = 11
        call itm.addBonus(BONUS_AGILITY, 6)
        set itm.maxSockets = 1
        
        // Belt of Giant Strength +6
        set itm = CreateInvItem('bgst', 'B00J', 500, 0, " Increases the Strength of the Hero by 6 when worn.")
        set itm.slot = 4
        call itm.addBonus(BONUS_STRENGTH, 6)
        set itm.maxSockets = 1
        
        // Gauntlets of Ogre Strength +3
        set itm = CreateInvItem('rst1', 'B00K', 100, 0, " Increases the Strength of the Hero by 3 when worn.")
        set itm.slot = 9
        call itm.addBonus(BONUS_STRENGTH, 3)
        set itm.maxSockets = 1
        
        // Necklace of Spell Immunity
        set itm = CreateInvItem('nspi', 'B00L', 1000, 0, " Renders the Hero invulnerable to magic.")
        set itm.slot = 7
        set itm.equipAbility = 'AImx'
        set itm.maxSockets = 1
        
        // Runed Bracers
        set itm = CreateInvItem('brac', 'B00M',  400, 0, " Reduces Magic damage dealt to the Hero by 33%.")
        set itm.slot = 10
        set itm.equipAbility = 'AIsr'
        set itm.maxSockets = 1
        
        // Ring of Protection +4
        set itm = CreateInvItem('rde3', 'B00O',  500, 0, " Increases the armor of the Hero by 4 when worn.")
        set itm.slot = 6
        set itm.slotAlt = 12
        call itm.addBonus(BONUS_ARMOR, 4)
        set itm.maxSockets = 1
        
        // Pauldron
        set itm = CreateInvItem('V001', 'B00P',  600, 0, " Increases the armor of the Hero by 4 when worn.")
        set itm.slot = 2
        set itm.slotAlt = 8
        call itm.addBonus(BONUS_ARMOR, 4)
        set itm.maxSockets = 1
        
        // Battlescarred Shoulderplate
        set itm = CreateInvItem('I003', 'B00V',  600, 0, " Increases the armor by 4 and strenght by 2 when worn.")
        set itm.slot = 2
        set itm.slotAlt = 8
        set itm.reqUnitType = 'Hpal'
        set itm.reqLevel = 3
        call itm.addBonus(BONUS_ARMOR, 4)
        call itm.addBonus(BONUS_STRENGTH, 2)
        set itm.maxSockets = 1
        
        // Lich Mantle
        set itm = CreateInvItem('I006', 'B00Y',  600, 0, " Increases Intelligence by 3 and Health by 50 when worn.")
        set itm.slot = 2
        set itm.slotAlt = 8
        set itm.reqUnitType = 'Ulic'
        set itm.reqLevel = 3
        call itm.addBonus(BONUS_INTELLIGENCE, 3)
        call itm.addBonus(BONUS_LIFE, 50)
        set itm.maxSockets = 1
        
        // Armor
        set itm = CreateInvItem('I001', 'B00Q',  600, 0, " Increases armor by 8 and life by 100 when worn.")
        set itm.slot = 3
        call itm.addBonus(BONUS_ARMOR, 8)
        call itm.addBonus(BONUS_LIFE, 100)
        set itm.maxSockets = 1
        
        // Silverhand Cuirass
        set itm = CreateInvItem('I004', 'B00W',  600, 0, " Increases armor by 10 and life by 150 when worn.")
        set itm.slot = 3
        set itm.reqUnitType = 'Hpal'
        set itm.reqLevel = 2
        call itm.addBonus(BONUS_ARMOR, 10)
        call itm.addBonus(BONUS_LIFE, 150)
        set itm.maxSockets = 2
        
        // Pants
        set itm = CreateInvItem('I002', 'B00R',  600, 0, "Increases Strength by 3 when worn.")
        set itm.slot = 5
        call itm.addBonus(BONUS_STRENGTH, 3)
        set itm.maxSockets = 1
        
        // Golden Legguards
        set itm = CreateInvItem('I005', 'B00X',  600, 0, "Increases Strength by 3 and Armor by 1 when worn.")
        set itm.slot = 5
        set itm.reqUnitType = 'Hpal'
        call itm.addBonus(BONUS_STRENGTH, 2)
        call itm.addBonus(BONUS_ARMOR, 1)
        set itm.maxSockets = 2
        
        // Kel'Thuzard's Robe
        set itm = CreateInvItem('I008', 'B010',  600, 0, "Increases Intelligence by 5, Health by 40, and Mana by 50 when worn.")
        set itm.slot = 3
        set itm.reqUnitType = 'Ulic'
        call itm.addBonus(BONUS_INTELLIGENCE, 5)
        call itm.addBonus(BONUS_LIFE, 40)
        call itm.addBonus(BONUS_MANA, 50)
        set itm.maxSockets = 1
        
        // Searing Blade
        set itm = CreateInvItem('srbd', 'V000',  1650, 0, "Adds 10 bonus fire damage to the attack of a Hero when carried. The Hero's attacks also do splash damage to nearby enemy units.")
        set itm.slot = 13
        set itm.equipAbility = 'AIfw'
        set itm.equipCondition = Filter(function CustomItemCondition)
        set itm.equipConditionStrPrefix = "Usable"
        set itm.equipConditionStr = "PL or BM"
        set itm.maxSockets = 3
        
        // Shield of Honor
        set itm = CreateInvItem('shhn', 'B001',  3350, 0, "|cff8b00ffUnique|r\nGrants nearby friendly units a 10% bonus to attack damage. Also increases the armor of the Hero by 8 when worn.")
        set itm.slot = 14
        set itm.equipAbility = 'AIcd'
        call itm.addBonus(BONUS_ARMOR, 8)
        set itm.maxSockets = 2
        
        // Dagger of Escape
        set itm = CreateInvItem('desc', 'B002',  400, 0, "Allows the Hero to teleport a short distance.")
        set itm.slot = 13
        set itm.slotAlt = 14
        set itm.reqUnitType = 'Edem'
        set itm.equipAbility = 'AIbk'
        set itm.maxSockets = 1
    endfunction
    
endscope

scope AcquireItem initializer Init
    
    private function Actions takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local item itm = GetManipulatedItem()
        local Inventory inv = Inventory[u]
        local InvItem itemData
        local InvCustomItem data
        
        if (inv == 0) then
            return
        endif
        
        set itemData = GetInvItem(GetItemTypeId(itm))
        if (itemData <= 0) then
            return
        endif
        
        set data = GetItemUserData(itm)
        
        if (data == 0) then
            set data = InvCustomItem.create()
            call SetItemUserData(itm, data)
        endif
        
        set itemData.tempCustomId = data
        
        if (inv.addItem(itemData)) then
            call RemoveItem(itm)
        else
            call UnitRemoveItem(u, itm)
        endif
        
        set itm = null
        set u = null
    endfunction

    //===========================================================================
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM)
        call TriggerAddAction(t, function Actions)
    endfunction

endscope

scope EquipItem initializer Init

    function IsInvItm2H takes InvItem itm returns boolean
        return (itm.slot == 13 and itm.slotAlt == 0)
    endfunction
    
    private function Actions takes nothing returns nothing
        local InvItem itm = InvEventItem
        local player p = InvEventPlayer
        local unit u = Equipment.PlayerCurrentUnit[User[p].id]
        local Inventory inv = Inventory[u]
        local Equipment gear = Equipment[u]
        local boolean is2h = IsInvItm2H(itm)
        
        // 2H weapon conditions
        if (is2h) then
        
            if (gear.item[14-1] > 0) then
                call SimError(p, "You cannot equip a two-handed weapon with an offhand item.")
                call gear.unequip(gear.item[itm.slot-1], itm.slot-1)
                
                if (inv > 0) then
                    call inv.addItem(itm)
                else
                    call SetItemUserData(UnitAddItemById(u, itm.id), itm.tempCustomId)
                    set itm.tempCustomId = 0
                endif
            endif
            
        elseif (itm.slot == 14 or itm.slotAlt == 14) then
        
            if (gear.item[13-1] > 0 and IsInvItm2H(gear.item[13-1])) then
                call SimError(p, "You cannot equip an offhand item with a two-handed weapon.")
                call gear.unequip(gear.item[14-1], 14-1)
                
                if (inv > 0) then
                    call inv.addItem(itm)
                else
                    call SetItemUserData(UnitAddItemById(u, itm.id), itm.tempCustomId)
                    set itm.tempCustomId = 0
                endif
            
            endif
            
        endif
        
        set u = null
    endfunction

    //===========================================================================
    private function Init takes nothing returns nothing
        set InvItem.onEquip = CreateTrigger()
        call TriggerAddAction(InvItem.onEquip, function Actions)
    endfunction

endscope

scope UnequipItem initializer Init

    private function Actions takes nothing returns nothing
        //call BJDebugMsg(GetPlayerName(InvEquipPlayer) + " unequipped " + GetObjectName(InvEquipItem.id))
    endfunction

    //===========================================================================
    private function Init takes nothing returns nothing
        set InvItem.onUnequip = CreateTrigger()
        call TriggerAddAction(InvItem.onUnequip, function Actions)
    endfunction

endscope

scope SellItem initializer Init

    globals
        private InvItem array SellItem
        private integer array SellSlot
        private Inventory array SellInv
    endglobals 
    
    private function OnAgree takes nothing returns boolean
        local User user = User[GetTriggerPlayer()]
        local InvItem itm = SellItem[user.id]
        local integer slot = SellSlot[user.id]
        local Inventory inv = SellInv[user.id] 
        
        call inv.setItem(slot, 0)
        call SetPlayerState(inv.user.toPlayer(), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(inv.user.toPlayer(), PLAYER_STATE_RESOURCE_GOLD) + itm.cost)
        call DisplayTimedTextToPlayer(inv.user.toPlayer(), 0, 0, 15, "You sold \"" + GetObjectName(itm.id) + "\" for |cffffcc00" + I2S(itm.cost) + "|r gold.")
        
        return false
    endfunction
    
    private function Actions takes nothing returns nothing
        local InvItem itm = InvEventItem
        local player p = InvEventPlayer
        local Inventory inv = Inventory.PlayerCurrent[User[p].id]
        local integer slot = InvEventSlot
        
        if (itm <= 0) then
            return
        endif
        
        set SellItem[inv.user.id] = itm
        set SellSlot[inv.user.id] = slot
        set SellInv[inv.user.id] = inv
        
        call inv.showTooltip(inv, false)
        
        call ShowYesNoDialog("Sell " + GetObjectName(itm.id) + "?", inv.user, Filter(function OnAgree))
    endfunction

    //===========================================================================
    private function Init takes nothing returns nothing
        set Inventory.onSell = CreateTrigger()
        call TriggerAddAction(Inventory.onSell, function Actions)
    endfunction

endscope

scope DropItem initializer Init

    globals
        private InvItem array DropItem
        private integer array DropSlot
        private Inventory array DropInv
    endglobals 
    
    private function OnAgree takes nothing returns boolean
        local User user = User[GetTriggerPlayer()]
        local InvItem itm = DropItem[user.id]
        local integer slot = DropSlot[user.id]
        local Inventory inv = DropInv[user.id] 
        
        call SetItemUserData(CreateItem(itm.id, GetUnitX(inv.owner), GetUnitY(inv.owner)), inv.getItemId(slot))
        call inv.setItem(slot, 0)
        
        call DisplayTimedTextToPlayer(user.toPlayer(), 0, 0, 15, "You dropped \"" + GetObjectName(itm.id) + "\".")
        
        return false
    endfunction
    
    private function Actions takes nothing returns nothing
        local InvItem itm = InvEventItem
        local player p = InvEventPlayer
        local Inventory inv = Inventory.PlayerCurrent[User[p].id]
        local integer slot = InvEventSlot
        
        if (itm <= 0) then
            return
        endif
        
        set DropItem[inv.user.id] = itm
        set DropSlot[inv.user.id] = slot
        set DropInv[inv.user.id] = inv
        
        call inv.showTooltip(inv, false)
        
        call ShowYesNoDialog("Drop " + GetObjectName(itm.id) + "?", inv.user, Filter(function OnAgree))
    endfunction

    //===========================================================================
    private function Init takes nothing returns nothing
        set Inventory.onDrop = CreateTrigger()
        call TriggerAddAction(Inventory.onDrop, function Actions)
    endfunction

endscope

scope SocketItem initializer Init

    globals
        private InvItem array SockItem
        private integer array SockSlot
        private Inventory array SockInv
        private integer array SockLast
        
        integer SocketLast
        integer SocketSlot
        Inventory SocketInv
    endglobals 
    
    private function OnAgree takes nothing returns boolean
        local User user = User[GetTriggerPlayer()]
        local InvItem itm = SockItem[user.id]
        local integer slot = SockSlot[user.id]
        local Inventory inv = SockInv[user.id] 
        local InvItem socketItm = inv.getItem(slot)
        
        set socketItm.tempCustomId = inv.getItemId(slot)
        
        if (socketItm.addSocket(itm)) then
        
            static if (InvItem.buildDescription.exists) then
                set socketItm.tempCustomId = inv.getItemId((Inventory.MAX_SLOTS*inv.currentPage)+slot)

                call socketItm.buildDescription(inv.owner)
            else
                call inv.setTooltipInfo(GetItemDescription(socketItm.id))
            endif
            
            call inv.setTooltipTitle(GetObjectName(socketItm.id))
            call inv.setTooltipCost("|cffffcc00" + I2S(GetInvItem(socketItm.id).cost) + "|r")
            call inv.setTooltipIcon(inv.localInt(inv.pid, GetItemIcon(socketItm.id), Inventory.ICON_TRANSPARENT))
            
            call inv.showTooltip(inv, true)
            
            call inv.setItem(SockLast[user.id], 0)
        endif
        
        return false
    endfunction
    
    private function Actions takes nothing returns nothing
        local Inventory inv = SocketInv
        local InvItem itm = inv.getItem(SocketLast)
        local InvItem socketItm = inv.getItem(SocketSlot)
        
        set SockItem[inv.user.id] = itm
        set SockSlot[inv.user.id] = SocketSlot
        set SockInv[inv.user.id] = SocketInv
        set SockLast[inv.user.id] = SocketLast
        
        call inv.showTooltip(inv, false)
        
        call ShowYesNoDialog("Socket " + GetObjectName(itm.id) + " into " + GetObjectName(socketItm.id) + "?", inv.user, Filter(function OnAgree))
    endfunction

    //===========================================================================
    private function Init takes nothing returns nothing
        set Equipment.onSocket = CreateTrigger()
        call TriggerAddAction(Equipment.onSocket, function Actions)
    endfunction

endscope

scope HideInventory initializer Init

    private function OnIndex takes nothing returns boolean
        local unit u = GetIndexedUnit()
        local Inventory inv = Inventory[u]
        local unit u2 = Equipment[Equipment.PlayerCurrentUnit[inv.pid]].unit

        if inv == 0 then
            set u = null
            return false
        endif

        if (u == u2 and u != null) then
            call Equipment[u2].show(false, PlayerCamera[inv.pid])
        endif
        
        if (Inventory.PlayerCurrent[inv.pid] == inv) then
            call inv.show(false, PlayerCamera[inv.pid])
        endif
        
        return false
    endfunction
    
    private function OnDeath takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local Inventory inv = Inventory[u]
        local unit u2 = Equipment[Equipment.PlayerCurrentUnit[inv.pid]].unit
        
        if inv == 0 then
            set u = null
            return
        endif

        if (u == u2 and u != null) then
            call Equipment[u2].show(false, PlayerCamera[inv.pid])
        endif
        
        if (Inventory.PlayerCurrent[inv.pid] == inv) then
            call inv.show(false, PlayerCamera[inv.pid])
        endif
    endfunction
    
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
        call TriggerAddAction(t, function OnDeath)
        
        call OnUnitDeindex(function OnIndex)
    endfunction

endscope

library YesNoDialog requires UserInterface

    globals
        dialog array Dialog
        private button array YesBtn
        private filterfunc array YesCallback
        player YesNoPlayer
    endglobals
    
    private function OnClick takes nothing returns nothing
        local User user = User.first
        local button btn = GetClickedButton()

        loop
            exitwhen user == User.NULL
            
            if (YesCallback[user.id] != null and YesBtn[user.id] == btn) then
                set YesNoPlayer = user.toPlayer()
                call UserInterface_Eval(YesCallback[user.id])
            endif
            
            set user = user.next 
        endloop
    endfunction
    
    private keyword INITS
    
    struct YesNoDialog extends array
        implement INITS
    endstruct
    
    function ShowYesNoDialog takes string title, User user, filterfunc callback returns nothing
        set YesCallback[user.id] = callback
        call DialogSetMessage(Dialog[user.id], title)
        call DialogDisplay(user.toPlayer(), Dialog[user.id], true)
    endfunction
    
    private module INITS
        private static method onInit takes nothing returns nothing
            local User user = User.first
            local trigger t = CreateTrigger()
            
            loop
                exitwhen user == User.NULL
                
                set YesCallback[user.id] = null
                set Dialog[user.id] = DialogCreate()
                set YesBtn[user.id] = DialogAddButton(Dialog[user.id], "Yes", 89)
                call DialogAddButton(Dialog[user.id], "No", 0)
                call TriggerRegisterDialogEvent(t, Dialog[user.id])
                set user = user.next 
            endloop
            
            call TriggerAddAction(t, function OnClick)
        endmethod
    endmodule
endlibrary


library UserInterface initializer Init requires optional UnitDex/*or any unit indexer*/, Camera
/***************************************************************
*
*   v1.0.6, by TriggerHappy
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*
*   - Create UI elements based on dummy units. 
*
*   - Elements are overlay onto the current camera keeping you in gameplay. 
*
*   - The camera can be modified to any view including third person, however
*     it must be locked.
*
*   - Dynamic textures are applied to dummies through an ability based off
*     off War Clib, using destructables with their replaceable texture field 
*     set to the desired texture. (more: http://www.wc3c.net/showthread.php?p=1043980)
*
*   - Detect left and right clicks.
*
*   - Works in multiplayer (and single) without lag.
*   _________________________________________________________________________
*   1. Installation
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       1. Copy the script to your map and save it (requires JassHelper *or* JNGP)
*       2. Copy the object editor data and paste the correct raw codes into the configuration.
*   _________________________________________________________________________
*   2. API
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       struct UIButton
*
*           static method create takes real minx, real maxy, real W, real H, real z, integer texture returns thistype
*           static method updateAll takes nothing returns nothing
*           static method click takes unit u, boolean isLeft returns boolean
*           static method clickEx takes real x, real y, boolean isLeft returns boolean
*           static method clickPeriodicSelect takes player p, boolean isLeft returns boolean
*
*           method destroy takes nothing returns nothing
*           method update takes nothing returns nothing
*           method show takes boolean flag, Camera Cam returns nothing
*           method showPlayer takes player p, boolean flag, Camera cam returns nothing
*           method isClicked takes real x, real y returns boolean
*           method clickL takes nothing returns nothing
*           method clickR takes nothing returns nothing
*           method setPosition takes real minx, real maxy returns nothing
*           method setTexture takes integer texture returns nothing
*
*           -----------------------
*
*           integer customValue
*           integer animIndex
*           trigger triggerL
*           trigger triggerR
*           filterfunc onLeftClick
*           filterfunc onRightClick
*
*
*       struct UIPicture
*
*           static method create takes real minx, real maxy, real w, real h, real z, integer texture returns thistype
*           static method createEx takes real minx, real maxy, real z, real scale, integer unitId, real modelWidth, real modelHeight, integer texture returns thistype
*           static method updateAll takes nothing returns nothing

*           method destroy takes nothing returns nothing
*           method update takes nothing returns nothing
*           method show takes boolean show, Camera Cam returns nothing
*           method showPlayer takes player p, boolean flag, Camera cam returns nothing
*           method setPosition takes real minx, real maxy returns nothing
*           method setTexture takes integer texture returns nothing
*
*           -----------------------
*
*           integer customValue
*           integer animIndex
*
*       struct UIText
*   
*           static method create takes real minx, real maxy, real z returns thistype
*           static method updateAll takes nothing returns nothing
*
*           method destroy takes nothing returns nothing
*           method update takes nothing returns nothing
*           method setPosition takes real minx, real maxy returns nothing
*           method show takes boolean show, Camera Cam returns nothing
*
*           -----------------------
*
*           integer customValue
*
*       function GetTriggerButton takes nothing returns UIButton
*       function GetClickingPlayer takes nothing returns player
*       function GetCameraDeltaZ takes nothing returns real
*       function CreateWindow takes real x, real y, real size, real width, real height, race playerRace returns UIPicture
*
*       public function ApplySkin takes unit u, integer texture returns boolean
*
***************************************************************/

    // configuration
    private module InterfaceConfig
    
        // dummy unit with pitch angle animations
        static constant integer DUMMY_TYPE          = 'uidm'
        
        // model used in CreateWindow function
        static constant integer WINDOW_DUMMY        = 'bwn2'
        
        // destructable ID of the human border texture. the
        // rest of the races should have consecutive ids.
        static constant integer RACE_BORDERS_START  = 'D201'
        
        // run a timer to check for unit selections.
        // faster but more cpu intensive.
        static constant boolean LEFT_CLICK_TIMER    = true

            // really low timer intervals remove the flicker
            // effect, most of the time.
            static constant real LEFT_CLICK_TIMER_RATE  = 0.01

            // in multiplayer, IsUnitSelected is synchronous
            // so it doesn't instantly return false when you use
            // SelectUnit(u, false). So we must disable the button
            // for the clicking player for a brief period or else
            // the event will be spammed.
            static constant real LEFT_CLICK_DELAY   = 0.6
        
        // ability id's
        static constant integer DESTROYER_FORM_ID   = 'Aave'
        static constant integer LOCUST_ID           = 'Aloc'
        
        // ability used to change dummy unit textures
        static constant integer SKIN_CHANGE_ABILITY = 'Skin'
        
        // removes pathing and possibly other things from the unit.
        // similar to locust, but allows clicking.
        static constant integer GHOST_ABILITY       = 'Aeth'

        // dummy player
        static constant player PLAYER               = CAMERA_DUMMY_PLAYER // from Camera library
    endmodule
    // end configuration

    globals
        public destructable DummyTree = null
        private trigger Trig = CreateTrigger()
        private UIButton ClickedButton = 0
        private player ClickingPlayer = null
        private location DummyLoc = Location(0,0)
    endglobals

    function GetTriggerButton takes nothing returns UIButton
        return ClickedButton
    endfunction
    
    function GetClickingPlayer takes nothing returns player
        return ClickingPlayer
    endfunction

    public function Eval takes filterfunc func returns boolean
        call TriggerClearConditions(Trig)
        call TriggerAddCondition(Trig, func)
        return TriggerEvaluate(Trig)
    endfunction

    public function GetTerrainZ takes real x, real y returns real
        call MoveLocation(DummyLoc, x, y)
        return GetLocationZ(DummyLoc)
    endfunction
    
    // adjusts 
    public function FindModelAnimIndex takes real w, real h, real z returns integer
        local real W = w*SCREEN_WIDTH*z
        local real H = h*SCREEN_HEIGHT*z
        local real anim
        if (H<W) then
            set anim = 10*(W/H-1)
            return UIMath_R2I_N(anim)
        else
            set anim = 10*(H/W-1)
            if anim >= 0.5 then
                return 100+UIMath_R2I_N(anim)
            endif
        endif
        return 0
    endfunction

    public function FindModelSize takes real w, real h, real z returns real
        local real W = w*SCREEN_WIDTH*z
        local real H = h*SCREEN_HEIGHT*z
        if (H<W) then
            return 0.5*H
        endif
        return 0.5*W
    endfunction

    private function LocalReal takes player p, real forPlayer, real default returns real
        if (User.Local == p) then
            return forPlayer
        endif
        return default
    endfunction
    
    public function ApplySkin takes unit u, integer texture returns boolean
        local boolean out = false
        
        if (texture != 0) then
            
            call UnitAddAbility(u, Interface.SKIN_CHANGE_ABILITY)
            set DummyTree = CreateDestructable(texture,GetUnitX(u),GetUnitY(u),0,0,1)
            set out = IssueTargetOrder(u, "grabtree", DummyTree)
            call RemoveDestructable(DummyTree)
            set DummyTree = null
            call UnitRemoveAbility(u, Interface.SKIN_CHANGE_ABILITY)
        endif
        
        return out
    endfunction

    struct UIButton
        integer customValue
        integer animIndex
        trigger triggerL
        trigger triggerR
        filterfunc onLeftClick
        filterfunc onRightClick
        boolean disabled
        unit selectUnit

        static boolean useDelay = false

        readonly static thistype array AllShow
        readonly static integer CountShow = 0

        readonly integer index
        readonly Camera camera
        
        readonly real scale
        readonly real centerx
        readonly real centery
        readonly real minx
        readonly real maxx
        readonly real miny
        readonly real maxy
        readonly real width
        readonly real height
        readonly real z
        readonly unit picture
        readonly effect model
        
        readonly boolean displayed
        readonly integer texture 
        
        private timer clickTimer
        private integer unitId
        private static thistype array Unit2Button
        
        static method create takes real minx, real maxy, real W, real H, real z, integer texture returns thistype
            local thistype this = thistype.allocate()

            set .clickTimer      = null
            set .texture        = texture
            set .customValue    = 0
            set .camera         = 0
            set .width          = W
            set .height         = H
            set .minx           = minx
            set .maxx           = minx+W
            set .maxy           = maxy
            set .miny           = maxy-H
            set .z              = 100.2+z
            set .centerx        = minx+W/2.0
            set .centery        = maxy-H/2.0
            set .displayed      = false
            set .scale          = FindModelSize(W, H, .z)
            set .triggerL       = null
            set .triggerR       = null
            set .onLeftClick    = null
            set .onRightClick   = null
            set .selectUnit     = null
            set .picture        = CreateUnit(Interface.PLAYER, Interface.DUMMY_TYPE, 0, 0, 0)
            
            // apply texture
            call ApplySkin(.picture, texture)
            
            set .animIndex = FindModelAnimIndex(W, H, .z)
            call SetUnitAnimationByIndex(.picture, .animIndex)
            call UnitAddAbility(.picture, Interface.DESTROYER_FORM_ID)
            call UnitRemoveAbility(.picture, Interface.DESTROYER_FORM_ID)
            call UnitAddAbility(.picture, Interface.SKIN_CHANGE_ABILITY)
            call UnitAddAbility(.picture, Interface.GHOST_ABILITY)
            
            set this.unitId = GetUnitUserData(.picture)
            set Unit2Button[this.unitId] = this
            
            call SetUnitScale(.picture, 0, 0, 0)
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            call this.show(false, -1)
            set Unit2Button[this.unitId] = 0
            if this.clickTimer != null then
                call PauseTimer(this.clickTimer)
                call ReleaseTimer(this.clickTimer)
                set this.clickTimer = null
            endif
            call RemoveUnit(.picture)
            set .picture = null
            set .selectUnit = null
            call this.deallocate()
        endmethod

        method update takes nothing returns nothing
            local VECTOR3 Pos
            
            if (.displayed) then
                set Pos = .camera.win2World(.centerx, .centery, .z)
                call SetUnitX(.picture, Pos.x)
                call SetUnitY(.picture, Pos.y)
                call SetUnitFlyHeight(.picture, Pos.z-GetTerrainZ(Pos.x, Pos.y), 0)
                call Pos.destroy()
            endif
        endmethod
        
        method show takes boolean flag, Camera Cam returns nothing
            if Cam != -1 then
                set .camera = Cam
            endif
            
            if flag != .displayed then
                if flag then
                    set .AllShow[.CountShow] = this
                    set .index = .CountShow
                    set .CountShow = .CountShow + 1
                    call .update()
                    call SetUnitAnimationByIndex(.picture, .animIndex)
                    
                    call SetUnitScale(.picture, .scale, 0, 0)
                else
                    set .CountShow = .CountShow - 1
                    set .AllShow[.index] = .AllShow[.CountShow]
                    set .AllShow[.index].index = .index
                    
                    call SetUnitX(.picture, 0)
                    call SetUnitY(.picture, 0)
                    
                    call SetUnitScale(.picture, 0, 0, 0)
                endif
            endif
            
            set .displayed = flag
        endmethod
        
        method showPlayer takes player p, boolean flag, Camera cam returns nothing
            call .show(flag, cam)
            
            if (flag) then
                call SetUnitScale(.picture, LocalReal(p, .scale, 0), 0, 0)
                // War Club needs the visible model refreshed after zero-scale hiding.
                call ApplySkin(.picture, .texture)
                call SetUnitAnimationByIndex(.picture, .animIndex)
            endif
        endmethod

        method isClicked takes real x, real y returns boolean
            return .minx < x and x < .maxx and .miny < y  and y < .maxy
        endmethod
        
        method clickL takes nothing returns nothing
            set ClickedButton = this

            if (.triggerL != null and TriggerEvaluate(.triggerL)) then
                call TriggerExecute(.triggerL)
            endif

            if (.onLeftClick != null) then
                 call Eval(.onLeftClick)
            endif
        endmethod
        
        method clickR takes nothing returns nothing
            set ClickedButton = this

            if (.triggerR != null and TriggerEvaluate(.triggerR)) then
                call TriggerExecute(.triggerR)
            endif
            
            if (.onRightClick != null) then
                 call Eval(.onRightClick)
            endif
        endmethod
        
        method setPosition takes real minx, real maxy returns nothing
            set .minx = minx
            set .maxx = minx+.width
            set .maxy = maxy
            set .miny = maxy-.height
            set .centerx = minx+.width/2.0
            set .centery = maxy-.height/2.0
            
            if .displayed then
                call .update()
            endif
        endmethod
        
        method setTexture takes integer texture returns nothing
            call SetUnitX(.picture, 0)
            call SetUnitY(.picture, 0)
            call ApplySkin(.picture, texture)
            
            if .displayed then
                call .update()
            endif
            
            set .texture = texture
        endmethod
        
        static method updateAll takes nothing returns nothing
            local integer i = .CountShow - 1
            loop
                exitwhen i < 0
                call .AllShow[i].update()
                set i = i - 1
            endloop
        endmethod
        
        static method click takes unit u, boolean isLeft returns boolean
            local thistype b
            
            if GetUnitTypeId(u) == Interface.DUMMY_TYPE then
                set b = Unit2Button[GetUnitUserData(u)]

                if b > 0 and b.displayed then
                    call SelectUnit(u, false)

                    if isLeft then
                        call b.clickL()
                    else
                        call b.clickR()
                    endif
                    
                    return true
                endif
            endif
            
            return false
        endmethod
        
        static method clickEx takes real x, real y, boolean isLeft returns boolean
            local integer i = .CountShow - 1
            
            loop
                exitwhen i < 0

                if .AllShow[i].isClicked(x, y) then
                    if isLeft then
                        call .AllShow[i].clickL()
                    else
                        call .AllShow[i].clickR()
                    endif
                    
                    return true
                endif
                
                set i = i - 1
            endloop
            
            return false
        endmethod
        
        private static method enableButtonCallback takes nothing returns nothing
            local timer t = GetExpiredTimer()

            static if (LIBRARY_TimerUtils) then
                local thistype btn = thistype(GetTimerData(t))
            else
                local thistype btn = thistype(R2I(TimerGetRemaining(t) + 0.5))
            endif

            if btn.clickTimer == t then
                set btn.disabled = false
                set btn.clickTimer = null
            endif
            static if (LIBRARY_TimerUtils) then
                call ReleaseTimer(t)
            else
                call DestroyTimer(t)
            endif
            set t = null
        endmethod

        static method clickPeriodicSelect takes player p, boolean isLeft returns boolean
            local integer i = .CountShow - 1
            local timer t
            
            loop
                exitwhen i < 0

                if (IsUnitSelected(.AllShow[i].picture, p)) then
                    
                    if (not .AllShow[i].disabled) then

                        if isLeft then
                            call .AllShow[i].clickL()
                        else
                            call .AllShow[i].clickR()
                        endif

                        
                        if (thistype.useDelay) then // static if doesn't work..
                            set .AllShow[i].disabled = true

                            static if (LIBRARY_TimerUtils) then
                                set .AllShow[i].clickTimer = NewTimerEx(.AllShow[i])
                                call TimerStart(.AllShow[i].clickTimer, Interface.LEFT_CLICK_DELAY, false, function thistype.enableButtonCallback)
                            else
                                set t = CreateTimer()
                                call TimerStart(t, .AllShow[i], false, null)
                                call PauseTimer(t)
                                call TimerStart(t, Interface.LEFT_CLICK_DELAY, false, function thistype.enableButtonCallback)
                                set t = null
                            endif
                        endif
                        
                        return true
                    endif

                    call SelectUnit(.AllShow[i].picture, false)

                    if (.AllShow[i].selectUnit != null and User.Local == p) then
                        call SelectUnit(.AllShow[i].selectUnit, true)
                    endif

                endif
                
                set i = i - 1
            endloop
            
            return false
        endmethod

    endstruct

    struct UIPicture
        integer customValue
        integer animIndex
        
        readonly static thistype array AllShow
        readonly static integer CountShow = 0
        
        readonly integer index
        readonly Camera camera
        
        readonly real scale
        readonly real centerx
        readonly real centery
        readonly real width
        readonly real height
        readonly real z
        readonly unit picture
        readonly boolean displayed
        readonly integer texture 

        static method create takes real minx, real maxy, real w, real h, real z, integer texture returns thistype
            local thistype this = thistype.allocate()

            set .texture        = texture
            set .customValue    = 0
            set .camera         = 0
            set .width          = w
            set .height         = h
            set .centerx        = minx+w/2.0
            set .centery        = maxy-h/2.0
            set .z              = 100.2+z
            set .displayed      = false
            set .picture        = CreateUnit(Interface.PLAYER, Interface.DUMMY_TYPE, 0, 0, 0)
            set .animIndex      = FindModelAnimIndex(w, h, .z)
            set .scale          = FindModelSize(w, h, .z)
            
            call ApplySkin(.picture, texture)
            
            call SetUnitAnimationByIndex(.picture, .animIndex)
            
            call UnitAddAbility(.picture, Interface.DESTROYER_FORM_ID)
            call UnitRemoveAbility(.picture, Interface.DESTROYER_FORM_ID)
            call UnitAddAbility(.picture, Interface.LOCUST_ID)
            call UnitRemoveAbility(.picture, Interface.LOCUST_ID)
            
            // hide unit
            call SetUnitScale(.picture, 0, 0, 0)
            
            return this
        endmethod
        
        static method createEx takes real minx, real maxy, real z, real scale, integer unitId, real modelWidth, real modelHeight, integer texture returns thistype
            local thistype this = thistype.allocate()

            set .customValue    = 0
            set .camera         = 0
            set .z              = 100.2 + z
            set .width          = (modelWidth*scale) / (SCREEN_WIDTH*.z)
            set .height         = (modelHeight*scale) / (SCREEN_HEIGHT*.z)
            set .scale          = scale
            set .centerx        = minx+.width/2.0
            set .centery        = maxy-.height/2.0
            set .displayed      = false
            set .picture        = CreateUnit(Interface.PLAYER, unitId, 0, 0, 270)
            
            call ApplySkin(.picture, texture)
            
            call UnitAddAbility(.picture, Interface.DESTROYER_FORM_ID)
            call UnitRemoveAbility(.picture, Interface.DESTROYER_FORM_ID)
            call UnitAddAbility(.picture, Interface.LOCUST_ID)
            call UnitRemoveAbility(.picture, Interface.LOCUST_ID)
            
            // hide unit
            call SetUnitScale(.picture, 0, 0, 0)
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            call this.show(false, -1)
            call RemoveUnit(.picture)
            set .picture = null
            call this.deallocate()
        endmethod

        method update takes nothing returns nothing
            local VECTOR3 Pos

            if (this.displayed) then
                set Pos = this.camera.win2World(.centerx, .centery, .z)
                call SetUnitX(.picture, Pos.x)
                call SetUnitY(.picture, Pos.y)
                call SetUnitFlyHeight(.picture, Pos.z - GetTerrainZ(Pos.x, Pos.y), 0)
                call Pos.destroy()
            endif
        endmethod
        
        method show takes boolean show, Camera Cam returns nothing
            if Cam != -1 then
                set this.camera = Cam
            endif

            if show != .displayed then
                if show then
                    set .AllShow[.CountShow] = this
                    set .index = .CountShow
                    set .CountShow = .CountShow + 1
                    call .update()
                    call SetUnitAnimationByIndex(.picture, .animIndex)
                    call SetUnitScale(.picture, .scale, 0, 0)
                else
                    set .CountShow = .CountShow - 1
                    set .AllShow[.index] = .AllShow[.CountShow]
                    set .AllShow[.index].index = .index
                    call SetUnitX(.picture, 0)
                    call SetUnitY(.picture, 0)
                    call SetUnitScale(.picture, 0, 0, 0)
                endif
            endif
            
            set .displayed = show
        endmethod
        
        method showPlayer takes player p, boolean flag, Camera cam returns nothing
            call .show(flag, cam)
            
            if (flag) then
                call SetUnitScale(.picture, LocalReal(p, .scale, 0), 0, 0)
                // War Club needs the visible model refreshed after zero-scale hiding.
                call ApplySkin(.picture, .texture)
                call SetUnitAnimationByIndex(.picture, .animIndex)
            endif
        endmethod
        
        method setPosition takes real minx, real maxy returns nothing
            set .centerx = minx+.width/2.0
            set .centery = maxy-.height/2.0
            if .displayed then
                call .update()
            endif
        endmethod
        
        method setTexture takes integer texture returns nothing
            call SetUnitX(.picture, 0)
            call SetUnitY(.picture, 0)
            call ApplySkin(.picture, texture)
            
            if .displayed then
                call .update()
            endif
            
            set .texture = texture
        endmethod
        
        static method updateAll takes nothing returns nothing
            local integer i = .CountShow - 1

            loop
                exitwhen i < 0
                call .AllShow[i].update()
                set i = i - 1
            endloop
        endmethod

    endstruct

    struct UIText
        integer customValue
        
        readonly unit dummy
        readonly static thistype array AllShow
        readonly static integer CountShow = 0
        readonly integer index
        readonly Camera camera
        readonly real minx
        readonly real maxy
        readonly real z
        readonly texttag text
        readonly boolean displayed
        
        static method create takes real minx, real maxy, real z returns thistype
            local thistype this = thistype.allocate()
            
            set .customValue    = 0
            set .camera         = 0
            set .minx           = minx
            set .maxy           = maxy
            set .z              = 100 + z
            set .displayed      = false
            set .text           = CreateTextTag()
            set .dummy          = CreateUnit(Interface.PLAYER, Interface.DUMMY_TYPE, 0, 0, 0)

            call SetUnitScale(.dummy, 0, 0, 0)

            call UnitAddAbility(.dummy, Interface.LOCUST_ID)
            call UnitRemoveAbility(.dummy, Interface.LOCUST_ID)
            
            call SetTextTagVisibility(.text, false)
            call SetTextTagPosUnit(.text, .dummy, 0)
            
            return this
        endmethod
        
        static method createEx takes player p, real minx, real maxy, real z returns thistype
            local thistype this = thistype.allocate()
            
            set .customValue    = 0
            set .camera         = 0
            set .minx           = minx
            set .maxy           = maxy
            set .z              = 100 + z
            set .displayed      = false
            set .dummy          = CreateUnit(Interface.PLAYER, Interface.DUMMY_TYPE, 0, 0, 0)

            if (User.Local == p) then
                set .text = CreateTextTag()
            endif
            
            call SetUnitScale(.dummy, 0, 0, 0)

            call UnitAddAbility(.dummy, Interface.LOCUST_ID)
            call UnitRemoveAbility(.dummy, Interface.LOCUST_ID)
            
            call SetTextTagVisibility(.text, false)
            call SetTextTagPosUnit(.text, .dummy, 0)
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            call this.show(false, -1)
            call DestroyTextTag(.text)
            call RemoveUnit(.dummy)
            set .text = null
            set .dummy = null
            call this.deallocate()
        endmethod
        
        method update takes nothing returns nothing
            local VECTOR3 Pos = .camera.win2World(.minx, .maxy, .z)
            call SetUnitX(.dummy, Pos.x)
            call SetUnitY(.dummy, Pos.y)
            call SetTextTagPosUnit(.text, .dummy, (Pos.z-GetTerrainZ(Pos.x,Pos.y))-14.8)
            call Pos.destroy()
        endmethod
        
        method setPosition takes real minx, real maxy returns nothing
            set .minx = minx
            set .maxy = maxy
            
            if .displayed then
                call .update()
            endif
        endmethod
        
        method show takes boolean show, Camera Cam returns nothing
            if Cam != -1 then
                set .camera = Cam
            endif
            
            call SetTextTagVisibility(.text, show)
            
            if show != .displayed then
                if show then
                    set .AllShow[.CountShow] = this
                    set .index = .CountShow
                    set .CountShow = .CountShow + 1
                    call .update()
                else
                    set .CountShow = .CountShow - 1
                    set .AllShow[.index] = .AllShow[.CountShow]
                    set .AllShow[.index].index = .index
                endif
            endif
            
            set .displayed = show
        endmethod
        
        static method updateAll takes nothing returns nothing
            local integer i = .CountShow - 1
            loop
                exitwhen i < 0
                call .AllShow[i].update()
                set i = i - 1
            endloop
        endmethod

    endstruct

    struct Interface extends array
        
        implement InterfaceConfig
        
       static method getRaceBorders takes race r returns integer
            return RACE_BORDERS_START + (GetHandleId(r)-1)
        endmethod
        
        static method updateAll takes boolean but, boolean pic, boolean tex returns nothing
            if but then
                call UIButton.updateAll()
            endif
            if pic then
                call UIPicture.updateAll()
            endif
            if tex then
                call UIText.updateAll()
            endif
        endmethod

    endstruct

    function CreateWindow takes real x, real y, real size, real width, real height, race playerRace returns UIPicture
        return UIPicture.createEx(x, y, /*z=*/2, size, Interface.WINDOW_DUMMY, width, height, Interface.getRaceBorders(playerRace))
    endfunction
    
    private function InterfaceClickR takes nothing returns nothing
        local unit clicker = GetTriggerUnit()
        local unit btnUnit = GetOrderTargetUnit()
        
        set ClickingPlayer = GetOwningPlayer(clicker)
        
        if (UIButton.click(btnUnit, false)) then
            call PauseUnit(clicker, true)
            call IssueImmediateOrderById(clicker, 851973)
            call PauseUnit(clicker, false)
        endif
        
        set clicker = null
    endfunction
    
    private function InterfaceClickL takes nothing returns nothing
        set ClickingPlayer = GetTriggerPlayer()
        call UIButton.click(GetTriggerUnit(), true)
    endfunction

    private function InterfaceClickL_Timer takes nothing returns nothing
        local integer i = 0
        local integer c = UIButton.CountShow
        local User user = User.first
        
        loop
            exitwhen user == User.NULL
  
            set ClickingPlayer = user.handle
            
            call UIButton.clickPeriodicSelect(user.handle, true)

            set user = user.next
        endloop
    endfunction
    
    private function Init takes nothing returns nothing
         local trigger t = CreateTrigger()
         local trigger t2 = CreateTrigger()
         local integer i = 0
         local User user = User.first
        
         loop
            exitwhen user == User.NULL
            
            call TriggerRegisterPlayerUnitEvent(t, user.handle, EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null)
            
            static if (not Interface.LEFT_CLICK_TIMER) then
                call TriggerRegisterPlayerUnitEvent(t2, user.handle, EVENT_PLAYER_UNIT_SELECTED, null)
            endif
            
            set user = user.next
        endloop

        call TriggerAddAction(t, function InterfaceClickR)
        
        static if (Interface.LEFT_CLICK_TIMER) then
            call TimerStart(CreateTimer(), Interface.LEFT_CLICK_TIMER_RATE, true, function InterfaceClickL_Timer)
        else
            call TriggerAddAction(t2, function InterfaceClickL)
        endif

        set UIButton.useDelay = Interface.LEFT_CLICK_TIMER
    endfunction
    
endlibrary

library UnitDex uses optional WorldBounds, optional GroupUtils
/***************************************************************
*
*   v1.2.1, by TriggerHappy
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*   UnitDex assigns every unit an unique integer. It attempts to make that number within the 
*   maximum array limit so you can associate it with one.
*   _________________________________________________________________________
*   1. Installation
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*   Copy the script to your map, save it, then restart the editor and comment out the line below. 
*/
    /// external ObjectMerger w3a Adef uDex anam "Detect Leave" ansf "(UnitDex)" aart "" acat "" arac 0 
/*  ________________________________________________________________________
*   2. Configuration
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
*/  
    private module UnitDexConfig
    
        // The raw code of the leave detection ability.
        static constant integer DETECT_LEAVE_ABILITY = 'uDex'
        
        // Allow debug messages (debug mode must also be on)
        static constant boolean ALLOW_DEBUGGING      = true
        
        // Uncomment the lines below to define a filter for units being indexed
        
        static method onFilter takes unit u returns boolean
            return GetUnitTypeId(u) != 'dumi' and GetUnitTypeId(u) != 'dcst'
        endmethod
        
    endmodule 
/*  _________________________________________________________________________
*   3. Function API
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*   Every function inlines except for UnitDexRemove
*
*       function GetUnitId takes unit whichUnit returns integer
*       function GetUnitById takes integer index returns unit
*    
*       function UnitDexEnable takes boolean flag returns nothing
*       function UnitDexRemove takes unit u, boolean runEvents returns boolean
*
*       function IsUnitIndexed takes unit u returns boolean
*       function IsIndexingEnabled takes nothing returns boolean
*
*       function GetIndexedUnit takes nothing returns unit
*       function GetIndexedUnitId takes nothing returns integer
*       
*       function RegisterUnitIndexEvent takes boolexpr func, integer eventtype returns indexevent
*       function RemoveUnitIndexEvent takes triggercondition c, integer eventtype returns nothing
*       function TriggerRegisterUnitIndexEvent takes trigger t, integer eventtype returns nothing
*
*       function OnUnitIndex takes code func returns triggercondition
*       function OnUnitDeidex takes code func returns triggercondition 
*   _________________________________________________________________________
*   4. Struct API
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       UnitDex.Enabled = false // toggle the indexer
*       UnitDex.Initialized     // returns true if the preload timer has finished
*       UnitDex.Count           // returns the amount of units indexed
*       UnitDex.Unit[0]         // access the UnitDex array directly
*       UnitDex.Group           // a unit group containing every indexed unit (for enumeration)
*       UnitDex.LastIndex       // returns the last indexed unit's id
*   _________________________________________________________________________
*   5. Public Variables
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       These are to be used with the "eventtype" argument of the event API:
*
*           constant integer EVENT_UNIT_INDEX     = 0
*           constant integer EVENT_UNIT_DEINDEX   = 1
*   _________________________________________________________________________
*   6. Examples
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       1. Associate a unit with a variable
*
*           set UnitFlag[GetUnitId(yourUnit)] = true
*
*       2. Allocate a struct instance using a units assigned ID
*
*           local somestruct data = GetUnitId(yourUnit)
*   
*       3. Detect when a unit leaves the map
*
*           function Exit takes nothing returns nothing
*               call BJDebugMsg("The unit " + GetUnitName(GetIndexedUnit()) + " has left the map.")
*           endfunction
*
*           call OnUnitDeindex(function Exit)
*           // or 
*           call RegisterUnitIndexEvent(Filter(function Exit), EVENT_UNIT_DEINDEX)
*
*
*   _________________________________________________________________________
*   7. How it works
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       1. Enumerate all preplaced units
*       2. TriggerRegisterEnterRegion native to detect when a unit enters the map
*       3. Assign each unit that enters the map a unique integer
*       4. Give every unit an ability based off of defend. There is no native to accurately 
*          detect when a unit leaves the map but when a unit dies or is removed from the game 
*          they are issued the "undefend" order
*       5. Catch the "undefend" order and remove unit from the queue
*   _________________________________________________________________________
*   8. Notes
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       - This system is compatable with GUI because it utilizes UnitUserData (custom values for units).
*       - The object merger line should be commented out after saving and restarting.
*       - All public functions are inlined except UnitDexRemove.
*
*   -http://www.hiveworkshop.com/forums/submissions-414/unitdex-lightweight-unit-indexer-248209/
*
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
*/
    
    globals
        // Event types
        constant integer EVENT_UNIT_INDEX     = 0
        constant integer EVENT_UNIT_DEINDEX   = 1
        
        // System variables
        private trigger array IndexTrig
        private integer Index = 0
        private real E=-1
        private boolexpr FilterEnter
    endglobals
    
    function GetUnitId takes unit whichUnit returns integer
        return GetUnitUserData(whichUnit)
    endfunction
    
    function GetUnitById takes integer index returns unit
        return UnitDex.Unit[index]
    endfunction
    
    function GetIndexedUnit takes nothing returns unit
        return UnitDex.Unit[UnitDex.LastIndex]
    endfunction
    
    function GetIndexedUnitId takes nothing returns integer
        return UnitDex.LastIndex
    endfunction
    
    function IsUnitIndexed takes unit u returns boolean
        return (GetUnitById(GetUnitId(u)) != null)
    endfunction
    
    function UnitDexEnable takes boolean flag returns nothing
        set UnitDex.Enabled = flag
    endfunction
    
    function IsIndexingEnabled takes nothing returns boolean
        return UnitDex.Enabled
    endfunction
    
    function RegisterUnitIndexEvent takes boolexpr func, integer eventtype returns triggercondition
        return TriggerAddCondition(IndexTrig[eventtype], func)
    endfunction
    
    function RemoveUnitIndexEvent takes triggercondition c, integer eventtype returns nothing
        call TriggerRemoveCondition(IndexTrig[eventtype], c)
    endfunction
    
    function TriggerRegisterUnitIndexEvent takes trigger t, integer eventtype returns nothing
        call TriggerRegisterVariableEvent(t, SCOPE_PRIVATE + "E", EQUAL, eventtype)
    endfunction
    
    function OnUnitIndex takes code func returns triggercondition
        return TriggerAddCondition(IndexTrig[EVENT_UNIT_INDEX], Filter(func))
    endfunction

    function OnUnitDeindex takes code func returns triggercondition
        return TriggerAddCondition(IndexTrig[EVENT_UNIT_DEINDEX], Filter(func))
    endfunction
    
    function UnitDexRemove takes unit u, boolean runEvents returns boolean
        return UnitDex.Remove(u, runEvents)
    endfunction
    
    /****************************************************************/
    
    private keyword UnitDexCore
    
    struct UnitDex extends array
        static boolean Enabled = true
        
        readonly static integer LastIndex
        readonly static boolean Initialized=false
        readonly static group Group=CreateGroup()
        readonly static unit array Unit
        readonly static integer Count = 0
        readonly static integer array List
        
        implement UnitDexConfig
        
        private static integer Counter = 0
        
        implement UnitDexCore
    endstruct
    
    /****************************************************************/
     
    private module UnitDexCore
    
        static method Remove takes unit u, boolean runEvents returns boolean
            local integer i
            
            if (IsUnitIndexed(u)) then
                set i = GetUnitId(u)
                set UnitDex.List[i] = Index
                set Index = i
                
                call GroupRemoveUnit(UnitDex.Group, u)
                call SetUnitUserData(u, 0)
            
                if (runEvents) then
                    set UnitDex.LastIndex = i
                    set E = EVENT_UNIT_DEINDEX
                    call TriggerEvaluate(IndexTrig[EVENT_UNIT_DEINDEX])
                    set E = -1
                endif
                
                set UnitDex.Unit[i] = null
                set UnitDex.Count = UnitDex.Count - 1
                
                return true
            endif
            
            return false
        endmethod
        
        private static method onGameStart takes nothing returns nothing
            local integer i = 0
            static if (not LIBRARY_GroupUtils) then // Check if GroupUtils exists so we can use it's enumeration group.
                local group ENUM_GROUP = CreateGroup() // If not, create the group.
            endif
            
            // Index preplaced units
            loop
                call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(i), FilterEnter)
                
                set i = i + 1
                
                exitwhen i == bj_MAX_PLAYER_SLOTS
            endloop
            
            static if (not LIBRARY_GroupUtils) then
                call DestroyGroup(ENUM_GROUP)
                set ENUM_GROUP = null
            endif
            
            // run init triggers
            set i = 1
            loop
                exitwhen i > Counter
                
                set LastIndex = i
                
                call TriggerEvaluate(IndexTrig[EVENT_UNIT_INDEX])
                set E = EVENT_UNIT_INDEX
                set E = -1
                
                set i = i + 1
            endloop

            set LastIndex   = Counter
            set Initialized = true
            set FilterEnter = null
            
            call DestroyTimer(GetExpiredTimer())
        endmethod
        
        private static method onEnter takes nothing returns boolean
            local unit    u = GetFilterUnit()
            local integer i = GetUnitId(u)
            local integer t = Index
            
            if (i == 0 and thistype.Enabled) then
                
                // If a filter was defined pass the unit through it.
                static if (thistype.onFilter.exists) then
                    if (not thistype.onFilter(u)) then
                        set u = null
                        return false // check failed
                    endif
                endif
                
                // Handle debugging
                static if (thistype.DEBUG_MODE and thistype.ALLOW_DEBUGGING) then
                    if (t == 0 and Counter+1 >= JASS_MAX_ARRAY_SIZE) then
                        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "UnitDex: Maximum number of units reached!")
                        set u = null
                        return false
                    endif
                endif
                
                // Add to group of indexed units
                call GroupAddUnit(thistype.Group, u)
                
                // Give unit the leave detection ability
                call UnitAddAbility(u, thistype.DETECT_LEAVE_ABILITY)
                call UnitMakeAbilityPermanent(u, true, thistype.DETECT_LEAVE_ABILITY)
                
                // Allocate index
                if (Index != 0) then
                    set Index = List[t]
                else
                    set Counter = Counter + 1
                    set t = Counter
                endif
                
                set List[t] = -1
                set LastIndex = t
                set thistype.Unit[t] = u
                set Count = Count + 1
                
                // Store the index
                call SetUnitUserData(u, t)
                
                if (thistype.Initialized) then
                    // Execute custom events registered with RegisterUnitIndexEvent
                    call TriggerEvaluate(IndexTrig[EVENT_UNIT_INDEX])
                    
                    // Handle TriggerRegisterUnitIndexEvent
                    set E = EVENT_UNIT_INDEX

                    // Reset so the event can occur again
                    set E = -1
                endif
            endif
            
            set u = null
            
            return false
        endmethod

        private static method onLeave takes nothing returns boolean
            local unit    u
            local integer i
            
            // Check if order is undefend.
            if (thistype.Enabled and GetIssuedOrderId() == 852056) then
                
                set u = GetTriggerUnit()
                
                // If unit was killed (not removed) then don't continue
                if (GetUnitAbilityLevel(u, thistype.DETECT_LEAVE_ABILITY) != 0) then
                    set u = null
                    return false
                endif
                
                set i = GetUnitId(u)

                // If unit has been indexed then deindex it
                if (i > 0 and i <= Counter and u == GetUnitById(i)) then
                    
                    // Recycle the index
                    set List[i]   = Index
                    set Index     = i
                    set LastIndex = i
                    
                    // Remove to group of indexed units
                    call GroupRemoveUnit(thistype.Group, u)
                
                    // Execute custom events without any associated triggers
                    call TriggerEvaluate(IndexTrig[EVENT_UNIT_DEINDEX])
                    
                    // Handle TriggerRegisterUnitIndexEvent
                    set E = EVENT_UNIT_DEINDEX
                    
                    // Remove entry
                    call SetUnitUserData(u, 0)
                    set thistype.Unit[i] = null
                    
                    // Decrement unit count
                    set Count = Count - 1
               
                    // Reset so the event can occur again
                    set E = -1
                endif
                
                set u = null
            endif
            
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            local trigger t         = CreateTrigger()
            local integer i         = 0
            local player p
            local unit u
            
            static if (not LIBRARY_WorldBounds) then // Check if WorldBounts exists, if not then define the necessary vars
                local region reg = CreateRegion() // If WorldBounds wasn't found, create the region manually
                local rect world = GetWorldBounds()
            endif
            
            set FilterEnter = Filter(function thistype.onEnter)
            
            // Begin to index units when they enter the map
            static if (LIBRARY_WorldBounds) then
                call TriggerRegisterEnterRegion(CreateTrigger(), WorldBounds.worldRegion, FilterEnter)
            else
                call RegionAddRect(reg, world)
                call TriggerRegisterEnterRegion(CreateTrigger(), reg, FilterEnter)
                call RemoveRect(world)
                set world = null
            endif
            
            call TriggerAddCondition(t, Filter(function thistype.onLeave))
            
            set IndexTrig[EVENT_UNIT_INDEX] = CreateTrigger()
            set IndexTrig[EVENT_UNIT_DEINDEX] = CreateTrigger()
            
            loop
                set p = Player(i)
                
                // Detect "undefend"
                call TriggerRegisterPlayerUnitEvent(t, p, EVENT_PLAYER_UNIT_ISSUED_ORDER, null)
                
                // Hide the detect ability from players
                call SetPlayerAbilityAvailable(p, thistype.DETECT_LEAVE_ABILITY, false)
                
                set i = i + 1
                exitwhen i == bj_MAX_PLAYER_SLOTS
            endloop
            
            call TimerStart(CreateTimer(), 0, false, function thistype.onGameStart)
        endmethod
    
    endmodule
    
endlibrary

library PlayerUtils
/**************************************************************
*
*   v1.2.8 by TriggerHappy
*
*   This library provides a struct which caches data about players
*   as well as provides functionality for manipulating player colors.
*
*   Constants
*   ------------------
*
*       force FORCE_PLAYING - Player group of everyone who is playing.
*
*   Struct API
*   -------------------
*     struct User
*
*       static method fromIndex takes integer i returns User
*       static method fromLocal takes nothing returns User
*       static method fromPlaying takes integer id returns User
*
*       static method operator []    takes integer id returns User
*       static method operator count takes nothing returns integer
*
*       method operator name         takes nothing returns string
*       method operator name=        takes string name returns nothing
*       method operator color        takes nothing returns playercolor
*       method operator color=       takes playercolor c returns nothing
*       method operator defaultColor takes nothing returns playercolor
*       method operator hex          takes nothing returns string
*       method operator nameColored  takes nothing returns string
*
*       method toPlayer takes nothing returns player
*       method colorUnits takes playercolor c returns nothing
*
*       readonly string originalName
*       readonly boolean isPlaying
*       readonly static player Local
*       readonly static integer LocalId
*       readonly static integer AmountPlaying
*       readonly static playercolor array Color
*       readonly static player array PlayingPlayer
*
**************************************************************/

    globals
        // automatically change unit colors when changing player color
        private constant boolean AUTO_COLOR_UNITS = true
   
        // use an array for name / color lookups (instead of function calls)
        private constant boolean ARRAY_LOOKUP     = false
   
        // this only applies if ARRAY_LOOKUP is true
        private constant boolean HOOK_SAFETY      = false // disable for speed, but only use the struct to change name/color safely
   
        constant force FORCE_PLAYING = CreateForce()
   
        private string array Name
        private string array Hex
        private string array OriginalHex
        private playercolor array CurrentColor
    endglobals

    private keyword PlayerUtilsInit

    struct User extends array
     
        static constant integer NULL = 15
       
        readonly player handle
        readonly integer id
        readonly thistype next
        readonly thistype prev

        readonly string originalName
        readonly boolean isPlaying
   
        readonly static thistype first
        readonly static thistype last
        readonly static player Local
        readonly static integer LocalId
        readonly static integer AmountPlaying = 0
        readonly static playercolor array Color

        static if not (LIBRARY_GroupUtils) then
            readonly static group ENUM_GROUP = CreateGroup()
        endif

        private static thistype array PlayingPlayer
        private static integer array PlayingPlayerIndex
   
        // similar to Player(#)
        static method fromIndex takes integer i returns thistype
            return thistype(i)
        endmethod
   
        // similar to GetLocalPlayer
        static method fromLocal takes nothing returns thistype
            return thistype(thistype.LocalId)
        endmethod
   
        // access active players array
        static method fromPlaying takes integer index returns thistype
            return PlayingPlayer[index]
        endmethod
   
        static method operator [] takes player p returns thistype
            return thistype(GetPlayerId(p))
        endmethod
   
        method toPlayer takes nothing returns player
            return this.handle
        endmethod
     
        method operator name takes nothing returns string
            static if (ARRAY_LOOKUP) then
                return Name[this]
            else
                return GetPlayerName(this.handle)
            endif
        endmethod
   
        method operator name= takes string newName returns nothing
            call SetPlayerName(this.handle, newName)
            static if (ARRAY_LOOKUP) then
                static if not (HOOK_SAFETY) then
                    set Name[this] = newName
                endif
            endif
        endmethod
   
        method operator color takes nothing returns playercolor
            static if (ARRAY_LOOKUP) then
                return CurrentColor[this]
            else
                return GetPlayerColor(this.handle)
            endif
        endmethod
   
        method operator hex takes nothing returns string
            return OriginalHex[GetHandleId(this.color)]
        endmethod
   
        method operator color= takes playercolor c returns nothing
            call SetPlayerColor(this.handle, c)
       
            static if (ARRAY_LOOKUP) then
                set CurrentColor[this] = c
                static if not (HOOK_SAFETY) then
                    static if (AUTO_COLOR_UNITS) then
                        call this.colorUnits(color)
                    endif
                endif
            endif
        endmethod
   
        method operator defaultColor takes nothing returns playercolor
            return Color[this]
        endmethod
   
        method operator nameColored takes nothing returns string
            return hex + this.name + "|r"
        endmethod
   
        method colorUnits takes playercolor c returns nothing
            local unit u
       
            call GroupEnumUnitsOfPlayer(ENUM_GROUP, this.handle, null)
       
            loop
                set u = FirstOfGroup(ENUM_GROUP)
                exitwhen u == null
                call SetUnitColor(u, c)
                call GroupRemoveUnit(ENUM_GROUP, u)
            endloop
        endmethod
   
        static method onLeave takes nothing returns boolean
            local thistype p  = thistype[GetTriggerPlayer()]
            local integer i   = .PlayingPlayerIndex[p.id]
       
            // clean up
            call ForceRemovePlayer(FORCE_PLAYING, p.toPlayer())
       
            // recycle index
            set .AmountPlaying = .AmountPlaying - 1
            set .PlayingPlayerIndex[i] = .PlayingPlayerIndex[.AmountPlaying]
            set .PlayingPlayer[i] = .PlayingPlayer[.AmountPlaying]
           
            if (.AmountPlaying == 1) then
                set p.prev.next = User.NULL
                set p.next.prev = User.NULL
            else
                set p.prev.next = p.next
                set p.next.prev = p.prev
            endif

            set .last = .PlayingPlayer[.AmountPlaying]
           
            set p.isPlaying = false
       
            return false
        endmethod
   
        implement PlayerUtilsInit
   
    endstruct

    private module PlayerUtilsInit
        private static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()
            local integer i = 0
            local thistype p
       
            set thistype.Local   = GetLocalPlayer()
            set thistype.LocalId = GetPlayerId(thistype.Local)
       
            set OriginalHex[0]  = "|cffff0303"
            set OriginalHex[1]  = "|cff0042ff"
            set OriginalHex[2]  = "|cff1ce6b9"
            set OriginalHex[3]  = "|cff540081"
            set OriginalHex[4]  = "|cfffffc01"
            set OriginalHex[5]  = "|cfffe8a0e"
            set OriginalHex[6]  = "|cff20c000"
            set OriginalHex[7]  = "|cffe55bb0"
            set OriginalHex[8]  = "|cff959697"
            set OriginalHex[9]  = "|cff7ebff1"
            set OriginalHex[10] = "|cff106246"
            set OriginalHex[11] = "|cff4e2a04"
         
            set thistype.first = User.NULL

            loop
                exitwhen i == 12

                set p         = User(i)
                set p.handle  = Player(i)
                set p.id      = i
           
                set thistype.Color[i] = GetPlayerColor(p.handle)
                set CurrentColor[i] = thistype.Color[i]
             
                if (GetPlayerController(p.handle) == MAP_CONTROL_USER and GetPlayerSlotState(p.handle) == PLAYER_SLOT_STATE_PLAYING) then

                    set .PlayingPlayer[AmountPlaying] = p
                    set .PlayingPlayerIndex[i] = .AmountPlaying
                   
                   set .last = i
                   
                    if (.first == User.NULL) then
                        set .first = i
                        set User(i).next = User.NULL
                        set User(i).prev = User.NULL
                    else
                        set User(i).prev = PlayingPlayer[AmountPlaying-1].id
                        set PlayingPlayer[AmountPlaying-1].next = User(i)
                        set User(i).next = User.NULL
                    endif

                    set p.isPlaying = true
               
                    call TriggerRegisterPlayerEvent(t, p.handle, EVENT_PLAYER_LEAVE)
                    call ForceAddPlayer(FORCE_PLAYING, p.handle)
               
                    set Hex[p] = OriginalHex[GetHandleId(thistype.Color[i])]
               
                    set .AmountPlaying = .AmountPlaying + 1

                endif
           
                set Name[p] = GetPlayerName(p.handle)
                set p.originalName=Name[p]
           
                set i = i + 1
            endloop
       
            call TriggerAddCondition(t, Filter(function thistype.onLeave))
        endmethod
    endmodule

    //===========================================================================


    static if (ARRAY_LOOKUP) then
        static if (HOOK_SAFETY) then
            private function SetPlayerNameHook takes player whichPlayer, string name returns nothing
                set Name[GetPlayerId(whichPlayer)] = name
            endfunction
       
            private function SetPlayerColorHook takes player whichPlayer, playercolor color returns nothing
                local User p = User[whichPlayer]
           
                set Hex[p] = OriginalHex[GetHandleId(color)]
                set CurrentColor[p] = color
           
                static if (AUTO_COLOR_UNITS) then
                    call p.colorUnits(color)
                endif
            endfunction
       
            hook SetPlayerName SetPlayerNameHook
            hook SetPlayerColor SetPlayerColorHook
        endif 
    endif

endlibrary

library Camera requires UIMath, PlayerUtils

    globals
        boolean CameraAuditStoredEye = false
        // configuration   
        
        // location on the map where the terrain is the default level
        constant real CHECK_DELTAZ_X = -1200
        constant real CHECK_DELTAZ_Y = 950
        
        constant real SCREEN_WIDTH  = 0.544
        constant real SCREEN_HEIGHT = 0.302
        
        constant real SCREEN_ASPECT_RATIO = SCREEN_WIDTH/SCREEN_HEIGHT
        
        constant integer CAMERA_DUMMY_TYPE  = 'e001'
        constant player CAMERA_DUMMY_PLAYER = Player(bj_PLAYER_NEUTRAL_EXTRA)
        
        private real DeltaZ = 0
        // endconfig
        
        public unit array DummyUnit
        public location DummyLoc = Location(0,0)
    endglobals

    function GetTerrainZ takes real x, real y returns real
        call MoveLocation(DummyLoc, x, y)
        return GetLocationZ(DummyLoc)
    endfunction
    
    function GetCameraDeltaZ takes nothing returns real
        return DeltaZ
    endfunction
    
    private function Matrix4Perspective1 takes MATRIX4 Output, real fovy, real Aspect, real zn, real zf returns MATRIX4
        return Output.SetValues(2*zn/fovy,0,0,0,0,2*zn/Aspect,0,0,0,0,zf/(zf-zn),1,0,0,zn*zf/(zn-zf),0)
    endfunction

    private function Matrix4Perspective2 takes MATRIX4 Output, real n, real f, real r, real l, real t, real b returns MATRIX4
        return Output.SetValues(2*n/(r-l), 0, (r+l)/(r-l), 0, 0, 2*n/(t-b), (t+b)/(t-b), 0, 0, 0, -(f+n)/(f-n), -2*f*n/(f-n), 0, 0, -1, 0)
    endfunction

    private function Matrix4Look takes MATRIX4 Output, VECTOR3 PosCamera, VECTOR3 AxisX, VECTOR3 AxisY, VECTOR3 AxisZ returns MATRIX4
        return Output.SetValues(AxisX.x,AxisY.x,AxisZ.x,0,AxisX.y,AxisY.y,AxisZ.y,0,AxisX.z,AxisY.z,AxisZ.z,0,-Vec3Dot(AxisX, PosCamera),-Vec3Dot(AxisY, PosCamera),-Vec3Dot(AxisZ, PosCamera),1)
    endfunction

    struct Camera
        VECTOR3 eye
        VECTOR3 at
        unit target
        real distance
        real yaw
        real pitch
        real roll
        VECTOR3 axisX
        VECTOR3 axisY
        VECTOR3 axisZ
        private MATRIX4 view
        private MATRIX4 projection
        private boolean change
        integer customValue
        
        method win2World takes real X, real Y, real Range returns VECTOR3
            local VECTOR3 Output = VECTOR3.create()
            if CameraAuditStoredEye then
                set Output.x = .eye.x+.axisZ.x*Range+X*.axisX.x*SCREEN_WIDTH*Range+Y*.axisY.x*SCREEN_HEIGHT*Range
                set Output.y = .eye.y+.axisZ.y*Range+X*.axisX.y*SCREEN_WIDTH*Range+Y*.axisY.y*SCREEN_HEIGHT*Range
                set Output.z = .eye.z+.axisZ.z*Range+X*.axisX.z*SCREEN_WIDTH*Range+Y*.axisY.z*SCREEN_HEIGHT*Range
            else
            set Output.x = GetCameraEyePositionX()+.axisZ.x*Range+X*.axisX.x*SCREEN_WIDTH*Range+Y*.axisY.x*SCREEN_HEIGHT*Range
            set Output.y = GetCameraEyePositionY()+.axisZ.y*Range+X*.axisX.y*SCREEN_WIDTH*Range+Y*.axisY.y*SCREEN_HEIGHT*Range
            set Output.z = GetCameraEyePositionZ()+.axisZ.z*Range+X*.axisX.z*SCREEN_WIDTH*Range+Y*.axisY.z*SCREEN_HEIGHT*Range
            endif
            return Output
        endmethod

        method world2Win takes real X, real Y, real Z returns VECTOR3
            local VECTOR3 Pos = VECTOR3.New_1(X, Y, Z)
            local boolean b
            call Vec3Transform_2(Pos, Pos, .view)
            set b = Pos.z < 0
            call Vec3Transform_2(Pos, Pos, .projection)
            if b then
                set Pos.z = -Pos.z
            endif
            return Pos
        endmethod
        
        private method updateDistanceYawPitch takes nothing returns nothing
            local real dx = .at.x-.eye.x
            local real dy = .at.y-.eye.y
            local real dz = .at.z-.eye.z
            local real len2d
            set .distance = SquareRoot(dx*dx+dy*dy+dz*dz)
            set .yaw = Atan2(dy, dx)
            set len2d = SquareRoot(dx*dx+dy*dy)
            set .pitch = Atan2(dz, len2d)
        endmethod
        
        private method updateAxisMatrix takes nothing returns nothing
            local MATRIX3 mat
            call Vec3Normalize(.axisZ, Vec3Subtract(.axisZ, .at, .eye))
            set mat = Matrix3RotationAxis(MATRIX3.create(), .axisZ, -.roll)
            call Vec3Normalize(.axisX, Vec3Cross(.axisX, .axisZ, VECTOR3.oneZ))
            call Vec3Transform_1(.axisY, Vec3Cross(.axisY, .axisX, .axisZ), mat)
            call Vec3Transform_1(.axisX, .axisX, mat)
            call Matrix4Look(.view, .eye, .axisX, .axisY, .axisZ)
            call mat.destroy()
        endmethod

        method applyCameraForPlayer takes player p, boolean ignoreChange returns boolean
            if GetLocalPlayer() == p then
                call SetCameraField(CAMERA_FIELD_ROTATION, .yaw*bj_RADTODEG, 0)
                call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, .pitch*bj_RADTODEG, 0)
                call SetCameraField(CAMERA_FIELD_ROLL, .roll*bj_RADTODEG, 0)
                call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, .distance, 0)
                call SetCameraTargetController(DummyUnit[GetPlayerId(p)], .at.x, .at.y, false)
                call SetCameraField(CAMERA_FIELD_ZOFFSET, .at.z-DeltaZ, 0)
            endif
            if .change or ignoreChange then
                set .change = false
                return true
            endif
            return false
        endmethod

        method setPosition takes real x, real y, real z returns nothing
            local real dx = x-.at.x
            local real dy = y-.at.y
            local real dz = z-.at.z
            set .eye.x = .eye.x+dx
            set .eye.y = .eye.y+dy
            set .eye.z = .eye.z+dz
            set .at.x = x
            set .at.y = y
            set .at.z = z
            set .change = true
        endmethod
        
        method setEyeAndAt takes real ex, real ey, real ez, real tx, real ty, real tz returns nothing
            set .eye.x = ex
            set .eye.y = ey
            set .eye.z = ez
            set .at.x = tx
            set .at.y = ty
            set .at.z = tz
            call .updateDistanceYawPitch()
            call .updateAxisMatrix()
            set .change = true
        endmethod
        
        method setYawPitchRoll takes real yaw, real pitch, real roll, boolean EyeLock returns nothing
            local real Z = .distance*Sin(pitch)
            local real XY = .distance*Cos(pitch)
            local real X = XY*Cos(yaw)
            local real Y = XY*Sin(yaw)
            set .yaw = yaw
            set .pitch = pitch
            set .roll = roll
            if EyeLock then
                set .at.x = .eye.x+X
                set .at.y = .eye.y+Y
                set .at.z = .eye.z+Z
            else
                set .eye.x = .at.x-X
                set .eye.y = .at.y-Y
                set .eye.z = .at.z-Z
            endif
            call .updateAxisMatrix()
            set .change = true
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            
            set .customValue = 0
            set .change = true
            set .eye = VECTOR3.New_1(0.0,-922.668,DeltaZ+1367.912)
            set .at = VECTOR3.New_1(0, 0, DeltaZ)
            set .distance = 0
            set .yaw = 0
            set .pitch = 0
            set .roll = 0
            set .axisX = VECTOR3.create()
            set .axisY = VECTOR3.create()
            set .axisZ = VECTOR3.create()
            set .view  = MATRIX4.create()
            set .projection = Matrix4Perspective2(MATRIX4.create(), 0.5, 10000, -SCREEN_WIDTH/2, SCREEN_WIDTH/2, -SCREEN_HEIGHT/2, SCREEN_HEIGHT/2)
            call .updateDistanceYawPitch()
            call .updateAxisMatrix()
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            call .eye.destroy()
            call .at.destroy()
            call .axisX.destroy()
            call .axisY.destroy()
            call .axisZ.destroy()
            call .view.destroy()
            call .projection.destroy()
            call this.deallocate()
        endmethod
        
    endstruct

    private module CamInitModule
        private static method onInit takes nothing returns nothing
            local integer i = 0
            local User user
            
            loop
                exitwhen i == User.AmountPlaying
                
                set user = User.fromPlaying(i)
                
                set DummyUnit[user.id] = CreateUnit(CAMERA_DUMMY_PLAYER, CAMERA_DUMMY_TYPE, 0, 0, 0)
                call ShowUnit(DummyUnit[user.id], false)
                call PauseUnit(DummyUnit[user.id], true)
                
                set i = i + 1
            endloop
            
            // init delta z
            call SetCameraPosition(CHECK_DELTAZ_X, CHECK_DELTAZ_Y)
            set DeltaZ = GetCameraTargetPositionZ() - 6
        endmethod
    endmodule
    
    private struct CamInit
        implement CamInitModule
    endstruct
    
endlibrary

library UIMath initializer Init

    public function R2I_N takes real r returns integer
        local integer i = R2I(r)
        if (r < I2R(i)+0.5) then
            return i
        else
            return i+1
        endif
    endfunction

    struct VECTOR3
        static VECTOR3 Zero
        static VECTOR3 oneX
        static VECTOR3 oneY
        static VECTOR3 oneZ
        real x
        real y
        real z
        
        static method New_0 takes nothing returns VECTOR3
            local VECTOR3 this = VECTOR3.create()
            set .x = 0
            set .y = 0
            set .z = 0
            return this
        endmethod
        
        static method New_1 takes real x, real y, real z returns VECTOR3
            local VECTOR3 this = VECTOR3.create()
            set .x = x
            set .y = y
            set .z = z
            return this
        endmethod
        
        static method New_2 takes VECTOR3 v returns VECTOR3
            local VECTOR3 this = VECTOR3.create()
            set .x = v.x
            set .y = v.y
            set .z = v.z
            return this
        endmethod
        
        method SetValues takes real x, real y, real z returns VECTOR3
            set .x = x
            set .y = y
            set .z = z
            return this
        endmethod
        
        method Length takes nothing returns real
            return SquareRoot(.x*.x+.y*.y+.z*.z)
        endmethod
        
        method LengthSq takes nothing returns real
            return .x*.x+.y*.y+.z*.z
        endmethod
        
        method ToString takes nothing returns string
            return "Vector3 id "+I2S(this) + "\nx = "+R2S(.x)+"   y = "+R2S(.y)+"   z = "+R2S(.z)
        endmethod
        
    endstruct

    function Vec3Add takes VECTOR3 Output, VECTOR3 v1, VECTOR3 v2 returns VECTOR3
        set Output.x = v1.x + v2.x
        set Output.y = v1.y + v2.y
        set Output.z = v1.z + v2.z
        return Output
    endfunction

    function Vec3Subtract takes VECTOR3 Output, VECTOR3 v1, VECTOR3 v2 returns VECTOR3
        set Output.x = v1.x - v2.x
        set Output.y = v1.y - v2.y
        set Output.z = v1.z - v2.z
        return Output
    endfunction
        
    function Vec3Scale takes VECTOR3 Output, VECTOR3 v, real r returns VECTOR3
        set Output.x = v.x * r
        set Output.y = v.y * r
        set Output.z = v.z * r
        return Output
    endfunction
        
    function Vec3Division takes VECTOR3 Output, VECTOR3 v, real r returns VECTOR3
        set Output.x = v.x / r
        set Output.y = v.y / r
        set Output.z = v.z / r
        return Output
    endfunction

    function Vec3Length takes VECTOR3 v returns real
        return SquareRoot(v.x*v.x+v.y*v.y+v.z*v.z)
    endfunction

    function Vec3LengthSq takes VECTOR3 v returns real
        return v.x*v.x+v.y*v.y+v.z*v.z
    endfunction

    function Vec3Normalize takes VECTOR3 Output, VECTOR3 v returns VECTOR3
        local real len = SquareRoot(v.x*v.x+v.y*v.y+v.z*v.z)
        set Output.x = v.x/len
        set Output.y = v.y/len
        set Output.z = v.z/len
        return Output
    endfunction

    function Vec3Dot takes VECTOR3 v1, VECTOR3 v2 returns real
        return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z
    endfunction

    function Vec3Cross takes VECTOR3 Output, VECTOR3 v1, VECTOR3 v2 returns VECTOR3
        local real y  = v1.z * v2.x - v1.x * v2.z
        local real z = v1.x * v2.y - v1.y * v2.x
        set Output.x = v1.y * v2.z - v1.z * v2.y
        set Output.y = y
        set Output.z = z
        return Output
    endfunction

    function Vec3Transform_1 takes VECTOR3 Output, VECTOR3 v, MATRIX3 m returns VECTOR3
        local real y = v.x*m.m12+v.y*m.m22+v.z*m.m32
        local real z = v.x*m.m13+v.y*m.m23+v.z*m.m33
        set Output.x = v.x*m.m11+v.y*m.m21+v.z*m.m31
        set Output.y = y
        set Output.z = z
        return Output
    endfunction

    function Vec3Transform_2 takes VECTOR3 Output, VECTOR3 v, MATRIX4 m returns VECTOR3
        local real y = v.x*m.m12+v.y*m.m22+v.z*m.m32+m.m42
        local real z = v.x*m.m13+v.y*m.m23+v.z*m.m33+m.m43
        local real w = v.x*m.m14+v.y*m.m24+v.z*m.m34+m.m44
        set Output.x = (v.x*m.m11+v.y*m.m21+v.z*m.m31+m.m41)/w
        set Output.y = y/w
        set Output.z = z/w
        return Output
    endfunction


    struct MATRIX3
        static MATRIX3 Zero
        static MATRIX3 E
        real m11
        real m12
        real m13
        real m21
        real m22
        real m23
        real m31
        real m32
        real m33
        
        static method New_0 takes nothing returns MATRIX3
            local MATRIX3 this = MATRIX3.create()
            set .m11 = 0
            set .m12 = 0
            set .m13 = 0
            set .m21 = 0
            set .m22 = 0
            set .m23 = 0
            set .m31 = 0
            set .m32 = 0
            set .m33 = 0
            return this
        endmethod
        
        static method New_1 takes real r11, real r12, real r13, real r21, real r22, real r23, real r31, real r32, real r33 returns MATRIX3
            local MATRIX3 this = MATRIX3.create()
            set .m11 = r11
            set .m12 = r12
            set .m13 = r13
            set .m21 = r21
            set .m22 = r22
            set .m23 = r23
            set .m31 = r31
            set .m32 = r32
            set .m33 = r33
            return this
        endmethod
        
        static method New_2 takes MATRIX3 m returns MATRIX3
            local MATRIX3 this = MATRIX3.create()
            set .m11 = m.m11
            set .m12 = m.m12
            set .m13 = m.m13
            set .m21 = m.m21
            set .m22 = m.m22
            set .m23 = m.m23
            set .m31 = m.m31
            set .m32 = m.m32
            set .m33 = m.m33
            return this
        endmethod
        
        method SetValues takes real r11, real r12, real r13, real r21, real r22, real r23, real r31, real r32, real r33 returns MATRIX3
            set .m11 = r11
            set .m12 = r12
            set .m13 = r13
            set .m21 = r21
            set .m22 = r22
            set .m23 = r23
            set .m31 = r31
            set .m32 = r32
            set .m33 = r33
            return this
        endmethod
     
        method ToString takes nothing returns string
            return "Matrux3 id "+I2S(this)+"\n"+R2S(.m11)+"  "+R2S(.m12)+"  "+R2S(.m13)+"\n"+R2S(.m21)+"  "+R2S(.m22)+"  "+R2S(.m23)+"\n"+R2S(.m31)+"  "+R2S(.m32)+"  "+R2S(.m33)
        endmethod
        
    endstruct

    function Matrix3Multiply takes MATRIX3 Output, MATRIX3 M1, MATRIX3 M2 returns MATRIX3  
        return Output.SetValues(M1.m11*M2.m11+M1.m21*M2.m12+M1.m31*M2.m13,M1.m12*M2.m11+M1.m22*M2.m12+M1.m32*M2.m13,M1.m13*M2.m11+M1.m23*M2.m12+M1.m33*M2.m13,M1.m11*M2.m21+M1.m21*M2.m22+M1.m31*M2.m23,M1.m12*M2.m21+M1.m22*M2.m22+M1.m32*M2.m23,M1.m13*M2.m21+M1.m23*M2.m22+M1.m33*M2.m23,M1.m11*M2.m31+M1.m21*M2.m32+M1.m31*M2.m33,M1.m12*M2.m31+M1.m22*M2.m32+M1.m32*M2.m33,M1.m13*M2.m31+M1.m23*M2.m32+M1.m33*M2.m33)
    endfunction

    function Matrix3Scaling takes MATRIX3 Output, real x, real y, real z returns MATRIX3
        return Output.SetValues(x,0,0,0,y,0,0,0,z)
    endfunction

    function Matrix3RotationX takes MATRIX3 Output, real a returns MATRIX3
        return Output.SetValues(1,0,0,0,Cos(a),-Sin(a),0,Sin(a),Cos(a))
    endfunction

    function Matrix3RotationY takes MATRIX3 Output, real a returns MATRIX3
        return Output.SetValues(Cos(a),0,Sin(a),0,1,0,-Sin(a),0,Cos(a))
    endfunction

    function Matrix3RotationZ takes MATRIX3 Output, real a returns MATRIX3
        return Output.SetValues(Cos(a),-Sin(a),0,Sin(a),Cos(a),0,0,0,1)
    endfunction

    function Matrix3RotationAxis takes MATRIX3 Output, VECTOR3 v, real a returns MATRIX3
        local real cosa = Cos(a)
        local real sina = Sin(a)
        return Output.SetValues(cosa+(1-cosa)*v.x*v.x,(1-cosa)*v.x*v.y-sina*v.z,(1-cosa)*v.x*v.z+sina*v.y,(1-cosa)*v.y*v.x+sina*v.z,cosa+(1-cosa)*v.y*v.y,(1-cosa)*v.y*v.z-sina*v.x,(1-cosa)*v.z*v.x-sina*v.y,(1-cosa)*v.z*v.y+sina*v.x,cosa+(1-cosa)*v.z*v.z)
    endfunction

    function Matrix3RotationYawPitchRoll takes MATRIX3 Output, real Yaw, real Pitch, real Roll returns MATRIX3
        local real cosa = Cos(Yaw)
        local real sina = Sin(Yaw)
        local real cosb = Cos(Pitch)
        local real sinb = Sin(Pitch)
        local real cosy = Cos(Roll)
        local real siny = Sin(Roll)
        return Output.SetValues(cosa*cosb,cosa*sinb*siny-sina*cosy,cosa*sinb*cosy+sina*siny,sina*cosb,sina*sinb*siny+cosa*cosy,sina*sinb*cosy-cosa*siny,-sinb,cosb*siny,cosb*cosy)
    endfunction

    struct MATRIX4
        static MATRIX4 Zero
        static MATRIX4 E
        real m11
        real m12
        real m13
        real m14
        real m21
        real m22
        real m23
        real m24
        real m31
        real m32
        real m33
        real m34
        real m41
        real m42
        real m43
        real m44
        
        static method New_0 takes nothing returns MATRIX4
            local MATRIX4 this = MATRIX4.create()
            set .m11 = 0
            set .m12 = 0
            set .m13 = 0
            set .m14 = 0
            set .m21 = 0
            set .m22 = 0
            set .m23 = 0
            set .m24 = 0
            set .m31 = 0
            set .m32 = 0
            set .m33 = 0
            set .m34 = 0
            set .m41 = 0
            set .m42 = 0
            set .m43 = 0
            set .m44 = 0
            return this
        endmethod
        
        static method New_1 takes real r11, real r12, real r13, real r14, real r21, real r22, real r23, real r24, real r31, real r32, real r33, real r34, real r41, real r42, real r43, real r44 returns MATRIX4
            local MATRIX4 this = MATRIX4.create()
            set .m11 = r11
            set .m12 = r12
            set .m13 = r13
            set .m14 = r14
            set .m21 = r21
            set .m22 = r22
            set .m23 = r23
            set .m24 = r24
            set .m31 = r31
            set .m32 = r32
            set .m33 = r33
            set .m34 = r34
            set .m41 = r41
            set .m42 = r42
            set .m43 = r43
            set .m44 = r44
            return this
        endmethod
        
        static method New_2 takes MATRIX4 m returns MATRIX4
            local MATRIX4 this = MATRIX4.create()
            set .m11 = m.m11
            set .m12 = m.m12
            set .m13 = m.m13
            set .m14 = m.m14
            set .m21 = m.m21
            set .m22 = m.m22
            set .m23 = m.m23
            set .m24 = m.m24
            set .m31 = m.m31
            set .m32 = m.m32
            set .m33 = m.m33
            set .m34 = m.m34
            set .m41 = m.m41
            set .m42 = m.m42
            set .m43 = m.m43
            set .m44 = m.m44
            return this
        endmethod
        
        static method New_3 takes MATRIX3 m returns MATRIX4
            local MATRIX4 this = MATRIX4.create()
            set .m11 = m.m11
            set .m12 = m.m12
            set .m13 = m.m13
            set .m14 = 0
            set .m21 = m.m21
            set .m22 = m.m22
            set .m23 = m.m23
            set .m24 = 0
            set .m31 = m.m31
            set .m32 = m.m32
            set .m33 = m.m33
            set .m34 = 0
            set .m41 = 0
            set .m42 = 0
            set .m43 = 0
            set .m44 = 1
            return this
        endmethod
        
        method SetValues takes real r11, real r12, real r13, real r14, real r21, real r22, real r23, real r24, real r31, real r32, real r33, real r34, real r41, real r42, real r43, real r44 returns MATRIX4
            set .m11 = r11
            set .m12 = r12
            set .m13 = r13
            set .m14 = r14
            set .m21 = r21
            set .m22 = r22
            set .m23 = r23
            set .m24 = r24
            set .m31 = r31
            set .m32 = r32
            set .m33 = r33
            set .m34 = r34
            set .m41 = r41
            set .m42 = r42
            set .m43 = r43
            set .m44 = r44
            return this
        endmethod
     
        method ToString takes nothing returns string
            return "Matrux4 id "+I2S(this)+"\n"+R2S(.m11)+"  "+R2S(.m12)+"  "+R2S(.m13)+"  "+R2S(.m14)+"\n"+R2S(.m21)+"  "+R2S(.m22)+"  "+R2S(.m23)+"  "+R2S(.m24)+"\n"+R2S(.m31)+"  "+R2S(.m32)+"  "+R2S(.m33)+"  "+R2S(.m34)+"\n"+R2S(.m41)+"  "+R2S(.m42)+"  "+R2S(.m43)+"  "+R2S(.m44)
        endmethod
        
    endstruct

    function Matrix4Multiply takes MATRIX4 Output, MATRIX4 M1, MATRIX4 M2 returns MATRIX4
        return Output.SetValues(M1.m11*M2.m11+M1.m21*M2.m12+M1.m31*M2.m13+M1.m41*M2.m14,M1.m12*M2.m11+M1.m22*M2.m12+M1.m32*M2.m13+M1.m42*M2.m14,M1.m13*M2.m11+M1.m23*M2.m12+M1.m33*M2.m13+M1.m43*M2.m14,M1.m14*M2.m11+M1.m24*M2.m12+M1.m34*M2.m13+M1.m44*M2.m14,M1.m11*M2.m21+M1.m21*M2.m22+M1.m31*M2.m23+M1.m41*M2.m24,M1.m12*M2.m21+M1.m22*M2.m22+M1.m32*M2.m23+M1.m42*M2.m24,M1.m13*M2.m21+M1.m23*M2.m22+M1.m33*M2.m23+M1.m43*M2.m24,M1.m14*M2.m21+M1.m24*M2.m22+M1.m34*M2.m23+M1.m44*M2.m24,M1.m11*M2.m31+M1.m21*M2.m32+M1.m31*M2.m33+M1.m41*M2.m34,M1.m12*M2.m31+M1.m22*M2.m32+M1.m32*M2.m33+M1.m42*M2.m34,M1.m13*M2.m31+M1.m23*M2.m32+M1.m33*M2.m33+M1.m43*M2.m34,M1.m14*M2.m31+M1.m24*M2.m32+M1.m34*M2.m33+M1.m44*M2.m34,M1.m11*M2.m41+M1.m21*M2.m42+M1.m31*M2.m43+M1.m41*M2.m44,M1.m12*M2.m41+M1.m22*M2.m42+M1.m32*M2.m43+M1.m42*M2.m44,M1.m13*M2.m41+M1.m23*M2.m42+M1.m33*M2.m43+M1.m43*M2.m44,M1.m14*M2.m41+M1.m24*M2.m42+M1.m34*M2.m43+M1.m44*M2.m44)
    endfunction

    private function Init takes nothing returns nothing
       set VECTOR3.Zero = VECTOR3.New_0()
       set VECTOR3.oneX = VECTOR3.New_1(1,0,0)
       set VECTOR3.oneY = VECTOR3.New_1(0,1,0)
       set VECTOR3.oneZ = VECTOR3.New_1(0,0,1)
       set MATRIX3.Zero = MATRIX3.New_0()
       set MATRIX3.E = MATRIX3.New_1(1,0,0,0,1,0,0,0,1)
       set MATRIX4.Zero = MATRIX4.New_0()
       set MATRIX4.E = MATRIX4.New_1(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1)
    endfunction

endlibrary

library InventoryTable
//***************************************************************
//* InventoryTable object 3.1
//* ------------
//*
//*   set t=InventoryTable.create() - instanceates a new table object
//*   call t.destroy()     - destroys it
//*   t[1234567]           - Get value for key 1234567
//*                          (zero if not assigned previously)
//*   set t[12341]=32      - Assigning it.
//*   call t.flush(12341)  - Flushes the stored value, so it
//*                          doesn't use any more memory
//*   t.exists(32)         - Was key 32 assigned? Notice
//*                          that flush() unassigns values.
//*   call t.reset()       - Flushes the whole contents of the
//*                          InventoryTable.
//*
//*   call t.destroy()     - Does reset() and also recycles the id.
//*
//*   If you use HandleTable instead of InventoryTable, it is the same
//* but it uses handles as keys, the same with StringTable.
//*
//*  You can use InventoryTable on structs' onInit  if the struct is
//* placed in a library that requires InventoryTable or outside a library.
//*
//*  You can also do 2D array syntax if you want to touch
//* mission keys directly, however, since this is shared space
//* you may want to prefix your mission keys accordingly:
//*
//*  set InventoryTable["thisstring"][ 7 ] = 2
//*  set InventoryTable["thisstring"][ 5 ] = InventoryTable["thisstring"][7]
//*
//***************************************************************

//=============================================================
    globals
        private constant integer MAX_INSTANCES=8100 //400000
        //Feel free to change max instances if necessary, it will only affect allocation
        //speed which shouldn't matter that much.

    //=========================================================
        private hashtable ht = InitHashtable()
    endglobals

    private struct GTable[MAX_INSTANCES]

        method reset takes nothing returns nothing
            call FlushChildHashtable(ht, integer(this) )
        endmethod

        private method onDestroy takes nothing returns nothing
            call this.reset()
        endmethod

    endstruct

    //Hey: Don't instanciate other people's textmacros that you are not supposed to, thanks.
    //! textmacro Table__make takes name, type, key
    struct $name$ extends GTable

        method operator [] takes $type$ key returns integer
            return LoadInteger(ht, integer(this), $key$)
        endmethod

        method operator []= takes $type$ key, integer value returns nothing
            call SaveInteger(ht,  integer(this)  ,$key$, value)
        endmethod

        method flush takes $type$ key returns nothing
            call RemoveSavedInteger(ht, integer(this), $key$)
        endmethod

        method exists takes $type$ key returns boolean
            return HaveSavedInteger( ht,  integer(this)  ,$key$)
        endmethod

        static method flush2D takes string firstkey returns nothing
            call $name$(- StringHash(firstkey)).reset()
        endmethod

        static method operator [] takes string firstkey returns $name$
            return $name$(- StringHash(firstkey) )
        endmethod

    endstruct
    //! endtextmacro

    //! runtextmacro Table__make("InventoryTable","integer","key" )
    //! runtextmacro Table__make("StringTable","string", "StringHash(key)" )
    //! runtextmacro Table__make("HandleTable","handle","GetHandleId(key)" )

endlibrary

library SimError initializer init
//**************************************************************************************************
//*
//*  SimError
//*
//*     Mimic an interface error message
//*       call SimError(ForPlayer, msg)
//*         ForPlayer : The player to show the error
//*         msg       : The error
//*    
//*     To implement this function, copy this trigger and paste it in your map.
//* Unless of course you are actually reading the library from wc3c's scripts section, then just
//* paste the contents into some custom text trigger in your map.
//*
//**************************************************************************************************

//==================================================================================================
    globals
        private sound error
    endglobals
    //====================================================================================================

    function SimError takes player ForPlayer, string msg returns nothing
        set msg="\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n|cffffcc00"+msg+"|r"
        if (GetLocalPlayer() == ForPlayer) then
            call ClearTextMessages()
            call DisplayTimedTextToPlayer( ForPlayer, 0.52, 0.96, 2.00, msg )
            call StartSound( error )
        endif
    endfunction

    private function init takes nothing returns nothing
         set error=CreateSoundFromLabel("InterfaceError",false,false,false,10,10)
         //call StartSound( error ) //apparently the bug in which you play a sound for the first time
                                    //and it doesn't work is not there anymore in patch 1.22
    endfunction

endlibrary

//TESH.scrollpos=0
//TESH.alwaysfold=0
library BonusMod  requires optional AbilityPreload, optional xepreload

// modified by triggerhappy, module initializer

private keyword AbilityBonus
////////////////////////////////////////////////////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ BonusMod - v3.3.1
//@=============================================================================
//@ Credits:
//@-----------------------------------------------------------------------------
//@    Written by:
//@        Earth-Fury
//@    Based on the work of:
//@        weaaddar
//@-----------------------------------------------------------------------------
//@ If you use this system, please at least credit weaaddar. Without him, this
//@ system would not exist. I would be happy if you credited me as well.
//@=============================================================================
//@ Requirements:
//@-----------------------------------------------------------------------------
//@ This library is written in vJass and thus requires JASS Helper in order to
//@ function correctly. This library also uses the ObjectMerger created by
//@ PitzerMike. The ObjectMerger must be configured as an external tool for
//@ JASS Helper.
//@ 
//@ All of these things are present in the NewGen world editor.
//@ 
//@=============================================================================
//@ Introduction:
//@-----------------------------------------------------------------------------
//@ BonusMod is a system for applying reversible bonuses to certain stats, such
//@ as attack speed or mana regen, for specific units. Most of the bonuses
//@ provided by BonusMod show green or red numbers in the command card, exactly
//@ like the bonuses provided by items.
//@
//@ BonusMod has two kinds of bonuses:
//@   1. Ability based bonuses
//@   2. Code based bonuses
//@ 
//@ All of the bonuses in the configuration section for the basic BonusMod
//@ library are ability-based bonuses. Code-based bonuses are provided by
//@ additional libraries.
//@ 
//@ Ability based bonuses have a limit to how much of a bonus they can apply.
//@ The actual limit depends on the number of abilities that type of bonus uses.
//@ See the "Default bonuses" section of this readme for the default limits
//@ of the bonuses that come with BonusMod. For changing the limits of the
//@ default bonuses, or for adding new types of bonuses, see the below
//@ configuration section.
//@ 
//@ Code based bonuses may or may not have a limit to how much of a bonus they
//@ can apply. The limits for code based bonuses depend entirely on how the
//@ bonus is implemented. See their documentation for more information.
//@
//@=============================================================================
//@ Adding BonusMod to your map:
//@-----------------------------------------------------------------------------
//@ First, you must place the BonusMod library in a custom-text trigger in your
//@ map.
//@
//@ You must then save your map with ability generation enabled. After you save
//@ your map with ability generation enabled, you must close your map in the
//@ editor, and reopen it. You can then disable ability generation.
//@ See the configuration section for information on how to enable and disable
//@ ability generation.
//@
//@=============================================================================
//@ Default bonuses:
//@-----------------------------------------------------------------------------
//@ 
//@      +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//@      | Bonus Type constants:       | Minimum bonus: | Maximum bonus: |
//@      +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//@      | BONUS_SIGHT_RANGE           |   -2048        |   +2047        |
//@      | BONUS_ATTACK_SPEED          |   -512         |   +511         |
//@      | BONUS_ARMOR                 |   -1024        |   +1023        |
//@      | BONUS_MANA_REGEN_PERCENT    |   -512%        |   +511%        |
//@      | BONUS_LIFE_REGEN            |   -256         |   +255         |
//@      | BONUS_DAMAGE                |   -1024        |   +1023        |
//@      | BONUS_STRENGTH              |   -256         |   +255         |
//@      | BONUS_AGILITY               |   -256         |   +255         |
//@      | BONUS_INTELLIGENCE          |   -256         |   +255         |
//@      +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//@
//@      Notes:
//@         - The bonuses for stength, agility, and intelligence can only be
//@           applied to heroes. Attempting to add them to normal units will
//@           fail to work completely.
//@         - Using a negative BONUS_STRENGTH bonus can give a unit negative
//@           maximum life. Don't do that. It really messes stuff up.
//@         - Using a negative BONUS_INTELLIGENCE bonus can remove a hero's
//@           mana. This is not a big issue, as mana will return when the
//@           bonus is removed.
//@         - The maximum effective sight range for a unit is 1800.
//@         - There is a maximum attack speed. I have no idea what it is.
//@ 
//@ See the configuration section for information on how to change the range of
//@ bonuses, as well as how to add new ability-based bonuses, and remove unused
//@ ones.
//@ 
//@=============================================================================
//@ Public API / Function list:
//@-----------------------------------------------------------------------------
//@ Note that BonusMod will only output error messages if JASS Helper is set to
//@ compile in debug mode.
//@
//@ Bonus constants such as BONUS_DAMAGE have .min and .max properties which
//@ are the minimum and maximum bonus that type of bonus can apply. Note that
//@ for code based bonuses, these constants may not reflect the minimum or
//@ maximum bonus for a specific unit. Use the IsBonusValid() function to check
//@ if the given bonus value is okay for a given unit.
//@
//@ function SetUnitBonus
//@ takes unit u, Bonus bonusType, integer amount
//@ returns integer
//@ 
//@     This function sets the bonus of the type bonusType for the given unit to
//@     the given amount. The returned integer is the unit's actual current
//@     bonus, after it has been changed. If the given amount is above the
//@     maximum possible bonus for this type, then the maximum possible bonus
//@     is applied to the unit. The same is true if the given value is below
//@     the minimum possible bonus.
//@
//@ function GetUnitBonus
//@ takes unit u, Bonus bonusType
//@ returns integer
//@
//@     Returns the given unit's current bonus of bonusType. A value of 0 means
//@     that the given unit does not have a bonus of the given type.
//@ 
//@ function AddUnitBonus
//@ takes unit u, Bonus bonusType, integer amount
//@ returns integer
//@ 
//@     Increases the unit's bonus by the given amount. You can use a negitive
//@     amount to subtract from the unit's current bonus. Note that the same
//@     rules SetUnitBonus has apply for going over/under the maximum bonus.
//@     The returned value is the unit's actual new bonus.
//@ 
//@ function RemoveUnitBonus
//@ takes unit u, Bonus bonusType
//@ returns nothing
//@ 
//@     Sets the bonus of the type bonusType to 0 for the given unit. This
//@     function is faster then using SetUnitBonus(u, bonusType, 0).
//@
//@ function IsBonusValid
//@ takes unit u, Bonus abstractBonus, integer value
//@ returns boolean
//@
//@     Returns true if the given value is a valid bonus value for the given
//@     unit. This will also return false if the given bonus type is a hero-
//@     only bonus type, and the given unit is not a hero.
//@ 
//@=============================================================================
//@ Writing code-based bonuses:
//@-----------------------------------------------------------------------------
//@ This section of the readme tells you how to create your own bonus types
//@ that apply their bonuses using vJass code instead of abilities. You do not
//@ need to read or understand this to use BonusMod as-is.
//@
//@ Creating a new bonus type is simple. Extend the Bonus struct, implement the
//@ methods provided within it, and create a single instance of your struct
//@ within a variable named BONUS_YOUR_BONUS_TYPES_NAME of the type Bonus.
//@ 
//@ The methods you must implement are:
//@
//@ method setBonus takes unit u, integer amount returns integer
//@     This method sets the given unit's current bonus to amount, returning
//@     the actual bonus that was applied. If the given amount is higher then
//@     the maximum amount your bonus type can apply to a unit, you must apply
//@     the maximum possible bonus, and return that amount. The same holds true
//@     for the minimum bonus.
//@
//@ method getBonus takes unit u returns integer
//@     This method returns the current bonus the given unit has.
//@
//@ method removeBonus takes unit u returns nothing
//@     This method sets the current bonus of the given unit to 0.
//@
//@ method isValueInRange takes integer value returns boolean
//@     This method returns true if the given integer is a valid bonus amount
//@     for this bonus type, and false otherwise.
//@
//@ Note that it is your responsibility to do any clean up in the event a unit
//@ dies or is removed with an active bonus on it. There is no guarantee that
//@ removeBonus() will be called before a unit dies or is removed.
//@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Configuration:
//==============================================================================

//------------------------------------------------------------------------------
// If the following constant is set to true, the abilities used by this library
// will be preloaded at map initialization. This will slightly increase loading
// time, but will prevent a slight to medium lag spike the first time a bonus
// of a type is applied.
// 
// Note that your map must contain either the xepreload library, or the
// AbilityPreload library for preloading to work.
// 
// It is highly recommended that you do not set this to false.
//------------------------------------------------------------------------------
globals
    private constant boolean PRELOAD_ABILITIES = true
    public boolean Init
endglobals

//------------------------------------------------------------------------------
// The BonusMod_BeginBonuses macro takes a single boolean type parameter.
// If set to true, bonus abilities will be created (or recreated) on save.
// If set to false, abilities will not be generated.
// 
// If you modify any of the bonus declaration macros, or add new ones, you must
// regenerate abilities.
// 
// Note that if you remove a bonus, the abilities it had created will not be
// automatically removed. This is also true of reducing the number of abilities
// a bonus uses.
// 
// After you generate abilities, you must close your map and reopen it in the
// editor. You can then disable ability generation until the next time you
// modify the bonus types.
//------------------------------------------------------------------------------
//! runtextmacro BonusMod_BeginBonuses("false")
    //--------------------------------------------------------------------------
    // Below are where bonus types are defined.
    // 
    // The first parameter is the name of the bonus type. A constant will be
    // generated for each bonus type, that will take the form: BONUS_NAME
    // 
    // The second parameter is the maximum power of 2 the bonus type can add
    // to a unit. For example, 8 abilities gives a range of -256 to +255.
    // 
    // The third parameter is the base ability. The base ability must give the
    // desired effect when the given field is changed.
    // 
    // The fourth parameter is the rawcode prefix of the bonuses generated
    // abilities. The prefix must be 3 characters long. Your map must not
    // already contain bonuses which start with the given prefix.
    // 
    // The fifth parameter is the object field to modify for each generated
    // ability.
    // 
    // The sixth parameter must be true of the bonus should only work on hero
    // units, and false otherwise.
    // 
    // The final parameter is the icon that will be displayed in the object
    // editor. This has no effect on anything ingame.
    //--------------------------------------------------------------------------
    
    //                                    |     NAME     |ABILITY|SOURCE |PREFIX|FIELD  | HERO   |  ICON
    //                                    |              | COUNT |ABILITY|      |       |  ONLY  |
    //! runtextmacro BonusMod_DeclareBonus("ARMOR",        "10",  "AId1", "(A)", "Idef", "false", "BTNHumanArmorUpOne.blp")
    //! runtextmacro BonusMod_DeclareBonus("DAMAGE",       "10",  "AItg", "(B)", "Iatt", "false", "BTNSteelMelee.blp")
    //! runtextmacro BonusMod_DeclareBonus("SIGHT_RANGE",  "11",  "AIsi", "(C)", "Isib", "false", "BTNTelescope.blp")
    //! runtextmacro BonusMod_DeclareBonus("LIFE_REGEN",   "8",   "Arel", "(E)", "Ihpr", "false", "BTNRingSkull.blp")
    //! runtextmacro BonusMod_DeclareBonus("STRENGTH",     "8",   "AIa1", "(F)", "Istr", "true" , "BTNGoldRing.blp")
    //! runtextmacro BonusMod_DeclareBonus("AGILITY",      "8",   "AIa1", "(G)", "Iagi", "true" , "BTNGoldRing.blp")
    //! runtextmacro BonusMod_DeclareBonus("INTELLIGENCE", "8",   "AIa1", "(H)", "Iint", "true" , "BTNGoldRing.blp")
    
    //                                           |     NAME          |ABILITY|SOURCE |PREFIX|FIELD  |HERO   |  ICON
    //                                           |                   | COUNT |ABILITY|      |       | ONLY  |
    //! runtextmacro BonusMod_DeclarePercentBonus("ATTACK_SPEED",       "9", "AIsx",  "(I)", "Isx1", "false", "BTNGlove.blp")
    //! runtextmacro BonusMod_DeclarePercentBonus("MANA_REGEN_PERCENT", "9", "AIrm",  "(D)", "Imrp", "false", "BTNSobiMask.blp")
    
//! runtextmacro BonusMod_EndBonuses()

//==============================================================================
// End of configuration
//==============================================================================

//! textmacro BonusMod_BeginBonuses takes SHOULD_GENERATE_ABILITIES
    private function Setup takes nothing returns nothing
        set Init=true
    // The following is a lua script for the ObjectMerger, used to generate abilities
    //*
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
    // */
//! endtextmacro

//! textmacro BonusMod_DeclareBonus takes NAME, ABILITY_COUNT, SOURCE_ABILITY, RAWCODE_PREFIX, FIELD, HERO_ONLY, ICON
// Object generation omitted; bundled Classic objects imported.
    globals
        Bonus BONUS_$NAME$
    endglobals
    set BONUS_$NAME$ = AbilityBonus.create('$RAWCODE_PREFIX$a', $ABILITY_COUNT$, '$RAWCODE_PREFIX$-', $HERO_ONLY$)
//! endtextmacro

//! textmacro BonusMod_DeclarePercentBonus takes NAME, ABILITY_COUNT, SOURCE_ABILITY, RAWCODE_PREFIX, FIELD, HERO_ONLY, ICON
// Object generation omitted; bundled Classic objects imported.
    globals
        Bonus BONUS_$NAME$
    endglobals
    set BONUS_$NAME$ = AbilityBonus.create('$RAWCODE_PREFIX$a', $ABILITY_COUNT$, '$RAWCODE_PREFIX$-', $HERO_ONLY$)
//! endtextmacro

//! textmacro BonusMod_EndBonuses
    //*
// Object generation omitted; bundled Classic objects imported.
// Object generation omitted; bundled Classic objects imported.
    // */
    
    endfunction
//! endtextmacro

// ===
//  Precomputed integer powers of 2
// ===

globals
    private integer array powersOf2
    private integer powersOf2Count = 0
endglobals

// ===
//  Utility functions
// ===

private function ErrorMsg takes string func, string s returns nothing
    call BJDebugMsg("|cffFF0000BonusMod Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

private function LoadAbility takes integer abilityId returns nothing
    static if PRELOAD_ABILITIES then
        static if LIBRARY_xepreload then
            call XE_PreloadAbility(abilityId)
        else
            static if LIBRARY_AbilityPreload then
                call AbilityPreload(abilityId)
            endif
        endif
    endif
endfunction

// ===
//  Bonus Types
// ===

private interface BonusInterface
    integer minBonus = 0
    integer maxBonus = 0
    private method destroy takes nothing returns nothing defaults nothing
endinterface

private keyword isBonusObject

struct Bonus extends BonusInterface
    boolean isBonusObject = false
    
    public static method create takes nothing returns thistype
        local thistype this = thistype.allocate()
        
        set this.isBonusObject = true
        
        return this
    endmethod
    
    stub method setBonus takes unit u, integer amount returns integer
        debug call ErrorMsg("Bonus.setBonus()", "I have no idea how or why you did this, but don't do it.")
        return 0
    endmethod
    
    stub method getBonus takes unit u returns integer
        debug call ErrorMsg("Bonus.getBonus()", "I have no idea how or why you did this, but don't do it.")
        return 0
    endmethod
    
    stub method removeBonus takes unit u returns nothing
        call this.setBonus(u, 0)
    endmethod
    
    stub method isValidBonus takes unit u, integer value returns boolean
        return true
    endmethod
    
    method operator min takes nothing returns integer
        return this.minBonus
    endmethod
    
    method operator max takes nothing returns integer
        return this.maxBonus
    endmethod
endstruct

private struct AbilityBonus extends Bonus
    public integer count
    
    public integer rawcode
    public integer negativeRawcode
    
    public integer minBonus = 0
    public integer maxBonus = 0
    
    public boolean heroesOnly
    
    public static method create takes integer rawcode, integer count, integer negativeRawcode, boolean heroesOnly returns thistype
        local thistype bonus = thistype.allocate()
        local integer i
        debug local boolean error = false
        
        // Error messages
        static if DEBUG_MODE then
            if rawcode == 0 then
                call ErrorMsg("AbilityBonus.create()", "Bonus constructed with a rawcode of 0?!")
                call bonus.destroy()
                return 0
            endif
            
            if count < 0 or count == 0 then
                call ErrorMsg("AbilityBonus.create()", "Bonus constructed with an ability count <= 0?!")
                call bonus.destroy()
                return 0
            endif
        endif
        
        // Grow powers of 2
        if powersOf2Count < count then
            set i = powersOf2Count
            loop
                exitwhen i > count
                
                set powersOf2[i] = 2 * powersOf2[i - 1]

                set i = i + 1
            endloop
            set powersOf2Count = count
        endif
        
        // Preload this bonus' abilities
        static if PRELOAD_ABILITIES then
            set i = 0
            loop
                exitwhen i == count
                
                call LoadAbility(rawcode + i)
                
                set i = i + 1
            endloop
            
            if negativeRawcode != 0 then
                call LoadAbility(negativeRawcode)
            endif
        endif
        
        // Set up this bonus object
        set bonus.count = count
        set bonus.negativeRawcode = negativeRawcode
        set bonus.rawcode = rawcode
        set bonus.heroesOnly = heroesOnly
        
        // Calculate the minimum and maximum bonuses
        if negativeRawcode != 0 then
            set bonus.minBonus = -powersOf2[count]
        else
            set bonus.minBonus = 0
        endif
        set bonus.maxBonus = powersOf2[count] - 1
        
        // Return the bonus object
        return bonus
    endmethod
    
    // Interface methods:
    
    method setBonus takes unit u, integer amount returns integer
        return SetUnitBonus.evaluate(u, this, amount)
    endmethod
    
    method getBonus takes unit u returns integer
        return GetUnitBonus.evaluate(u, this)
    endmethod
    
    method removeBonus takes unit u returns nothing
        call RemoveUnitBonus.evaluate(u, this)
    endmethod
    
    public method isValidBonus takes unit u, integer value returns boolean
        return (value >= this.minBonus) and (value <= this.maxBonus)
    endmethod
endstruct

// ===
//  Public API
// ===

function IsBonusValid takes unit u, Bonus abstractBonus, integer value returns boolean
    local AbilityBonus bonus = AbilityBonus(abstractBonus)
    
    static if DEBUG_MODE then
        if not abstractBonus.isBonusObject then
            call ErrorMsg("IsBonusValid()", "Invalid bonus type given")
        endif
    endif
    
    if abstractBonus.min > value or abstractBonus.max < value then
        return false
    endif
    
    if abstractBonus.getType() != AbilityBonus.typeid then
        return abstractBonus.isValidBonus(u, value)
    endif
    
    if bonus.heroesOnly and not IsUnitType(u, UNIT_TYPE_HERO) then
        return false
    endif
    
    return (value >= bonus.minBonus) and (value <= bonus.maxBonus)
endfunction

function RemoveUnitBonus takes unit u, Bonus abstractBonus returns nothing
    local integer i = 0
    local AbilityBonus bonus = AbilityBonus(abstractBonus)

    static if DEBUG_MODE then
        if not abstractBonus.isBonusObject then
            call ErrorMsg("RemoveUnitBonus()", "Invalid bonus type given")
        endif
    endif
    
    if abstractBonus.getType() != AbilityBonus.typeid then
        call abstractBonus.removeBonus(u)
        return
    endif
    
    if bonus.heroesOnly and not IsUnitType(u, UNIT_TYPE_HERO) then
        debug call ErrorMsg("RemoveUnitBonus()", "Trying to remove a hero-only bonus from a non-hero unit")
        return
    endif
    
    call UnitRemoveAbility(u, bonus.negativeRawcode)
    
    loop
        exitwhen i == bonus.count
        
        call UnitRemoveAbility(u, bonus.rawcode + i)

        set i = i + 1
    endloop
endfunction

function SetUnitBonus takes unit u, Bonus abstractBonus, integer amount returns integer
    local integer i
    local integer output = 0
    local AbilityBonus bonus = AbilityBonus(abstractBonus)
    local boolean applyMinBonus = false
    
    static if DEBUG_MODE then
        if not abstractBonus.isBonusObject then
            call ErrorMsg("SetUnitBonus()", "Invalid bonus type given")
        endif
    endif
    
    if amount == 0 then
        call RemoveUnitBonus(u, bonus)
        return 0
    endif
    
    if abstractBonus.getType() != AbilityBonus.typeid then
        return abstractBonus.setBonus(u, amount)
    endif
    
    if bonus.heroesOnly and not IsUnitType(u, UNIT_TYPE_HERO) then
        debug call ErrorMsg("SetUnitBonus()", "Trying to set a hero-only bonus on a non-hero unit")
        return 0
    endif
    
    if amount < bonus.minBonus then
        debug call ErrorMsg("SetUnitBonus()", "Attempting to set a bonus to below its min value")
        set amount = bonus.minBonus
    elseif amount > bonus.maxBonus then
        debug call ErrorMsg("SetUnitBonus()", "Attempting to set a bonus to above its max value")
        set amount = bonus.maxBonus
    endif
    
    if amount < 0 then
        set amount = -(bonus.minBonus - amount)
        set applyMinBonus = true
    endif
    
    call UnitRemoveAbility(u, bonus.negativeRawcode)
    
    set i = bonus.count - 1
    loop
        exitwhen i < 0
        if amount >= powersOf2[i] then
            
            call UnitAddAbility(u, bonus.rawcode + i)
            call UnitMakeAbilityPermanent(u, true, bonus.rawcode + i)
            
            static if DEBUG_MODE then
                if GetUnitAbilityLevel(u, bonus.rawcode + i) <= 0 then
                    call ErrorMsg("SetUnitBonus()", "Failed to give the 2^" + I2S(i) + " ability to the unit!")
                endif
            endif
            
            set amount = amount - powersOf2[i]
            set output = output + powersOf2[i]
        else
            
            call UnitRemoveAbility(u, bonus.rawcode + i)
            static if DEBUG_MODE then
                if GetUnitAbilityLevel(u, bonus.rawcode + i) > 0 then
                    call ErrorMsg("SetUnitBonus()", "Unit still has the 2^" + I2S(i) + " ability after it was removed!")
                endif
            endif
        endif

        set i = i - 1
    endloop
    
    if applyMinBonus then
        call UnitAddAbility(u, bonus.negativeRawcode)
        call UnitMakeAbilityPermanent(u, true, bonus.negativeRawcode)
    else
        call UnitRemoveAbility(u, bonus.negativeRawcode)
    endif
    
    return output
endfunction

function GetUnitBonus takes unit u, Bonus abstractBonus returns integer
    local integer i = 0
    local integer amount = 0
    local AbilityBonus bonus = AbilityBonus(abstractBonus)

    static if DEBUG_MODE then
        if not abstractBonus.isBonusObject then
            call ErrorMsg("GetUnitBonus()", "Invalid bonus type given")
        endif
    endif
    
    if abstractBonus.getType() != AbilityBonus.typeid then
        return abstractBonus.getBonus(u)
    endif
    
    if bonus.heroesOnly and not IsUnitType(u, UNIT_TYPE_HERO) then
        debug call ErrorMsg("GetUnitBonus()", "Trying to get a hero-only bonus from a non-hero unit")
        return 0
    endif
    
    if GetUnitAbilityLevel(u, bonus.negativeRawcode) > 0 then
        set amount = bonus.minBonus
    endif

    loop
        exitwhen i == bonus.count
        
        if GetUnitAbilityLevel(u, bonus.rawcode + i) > 0 then
            set amount = amount + powersOf2[i]
        endif

        set i = i + 1
    endloop

    return amount
endfunction

function AddUnitBonus takes unit u, Bonus bonus, integer amount returns integer
    return SetUnitBonus(u, bonus, GetUnitBonus(u, bonus) + amount)
endfunction

// ===
//  Initialization
// ===
private module BonusModInitModule

    private static method onInit takes nothing returns nothing
        local integer i
        
        // Set up powers of 2
        set powersOf2[0] = 1
        set powersOf2Count = 1
        
        static if DEBUG_MODE and PRELOAD_ABILITIES and not LIBRARY_xepreload and not LIBRARY_AbilityPreload then
            call ErrorMsg("Initialization", "PRELOAD_ABILITIES is set to true, but neither usable preloading library is detected")
        endif
        
        // Setup bonuses
        call Setup()
    endmethod

endmodule

struct BonusModStruct extends array
    implement BonusModInitModule
    
    static method addBonus takes unit u, Bonus bonus, integer amount returns integer
        return SetUnitBonus(u, bonus, GetUnitBonus(u, bonus) + amount)
    endmethod
endstruct

endlibrary

//TESH.scrollpos=172
//TESH.alwaysfold=0
library RegenBonuses initializer OnInit requires BonusMod, AutoIndex
////////////////////////////////////////////////////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ RegenBonuses for BonusMod
//@=============================================================================
//@ Credits:
//@-----------------------------------------------------------------------------
//@    Written by:
//@        Earth-Fury
//@=============================================================================
//@ Requirements:
//@-----------------------------------------------------------------------------
//@ This library requires the BonusMod library, and the AutoIndex library.
//@
//@=============================================================================
//@ Readme:
//@-----------------------------------------------------------------------------
//@ This library provides two new bonus types:
//@
//@   - BONUS_MANA_REGEN
//@         Regenerates an absolute amount of mana every second
//@
//@   - BONUS_LIFE_REGEN_PERCENT
//@         Regenerates a percent of a unit's maximum life every second
//@ 
//@ Any value is a valid bonus. There are no limits.
//@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Configuration:
//==============================================================================

//------------------------------------------------------------------------------
// The following constant determines how often the life and mana bonuses are
// applied to units. Note that this will not effect the values of the bonuses.
// The values of the bonuses will always be mana per second/percentage of life
// per second. This constant simply determines how often the values are updated.
//------------------------------------------------------------------------------
globals
    private real REGEN_PERIOD = 0.32
endglobals

//==============================================================================
// End of configuration
//==============================================================================

globals
    Bonus BONUS_MANA_REGEN
    Bonus BONUS_LIFE_REGEN_PERCENT
endglobals

private function ErrorMsg takes string func, string s returns nothing
    call BJDebugMsg("|cffFF0000RegenBonuses Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

globals
    private timer regenTimer = CreateTimer()
endglobals

private keyword BonusValues

private function DoRegen takes nothing returns nothing
    local integer i
    local BonusValues values
    
    // Loop over all active bonuses
    set i = 0
    loop
        exitwhen i == BonusValues.count
        
        set values = BonusValues.all[i]
        
        if GetWidgetLife(values.owner) > 0.0 then
            if values.manaRegen > 0 then
                // Do mana regen:
                call SetUnitState(values.owner, UNIT_STATE_MANA, GetUnitState(values.owner, UNIT_STATE_MANA) + (values.manaRegen * REGEN_PERIOD))
            endif
            
            if values.lifeRegen > 0 then
                // Do life regen:
                call SetUnitState(values.owner, UNIT_STATE_LIFE, GetUnitState(values.owner, UNIT_STATE_LIFE) + (GetUnitState(values.owner, UNIT_STATE_MAX_LIFE) * (values.lifeRegen / 100.0)) * REGEN_PERIOD)
            endif
        endif
        
        set i = i + 1
    endloop
endfunction

private struct BonusValues
    public integer manaRegen = 0
    public integer lifeRegen = 0
    
    public unit owner
    
    private static thistype array owners
    
    public static thistype array all
    public static integer count = 0
    public integer index
    
    private static method create takes unit u returns thistype
        local thistype this = thistype.allocate()
        
        set this.owner = u
        
        set thistype.owners[GetUnitId(u)] = this
        
        if thistype.count == 0 then
            call TimerStart(regenTimer, REGEN_PERIOD, true, function DoRegen)
        endif
        
        set thistype.all[thistype.count] = this
        set this.index = thistype.count
        set thistype.count = thistype.count + 1
        
        return this
    endmethod
    
    private method onDestroy takes nothing returns nothing
        set thistype.owners[GetUnitId(this.owner)] = thistype(0)
        
        set thistype.all[this.index] = thistype.all[thistype.count]
        set thistype.count = thistype.count - 1
        
        if thistype.count == 0 then
            call PauseTimer(regenTimer)
        endif
        
        set this.owner = null
    endmethod
    
    public static method getInstance takes unit u returns thistype
        if thistype.owners[GetUnitId(u)] == 0 then
            return thistype.create(u)
        else
            return thistype.owners[GetUnitId(u)]
        endif
    endmethod
    
    public static method operator[] takes unit u returns thistype
        return thistype.owners[GetUnitId(u)]
    endmethod
    
    public static method operator[]= takes unit u, thistype i returns nothing
        set thistype.owners[GetUnitId(u)] = i
    endmethod
endstruct

//! textmacro RegenBonuses_RegenBonusDefine takes NAME
private struct RegenBonus_$NAME$ extends Bonus
    integer minBonus = -2147483648
    integer maxBonus =  2147483647
    
    method setBonus takes unit u, integer amount returns integer
        local BonusValues values
        
        if not IsUnitIndexed(u) then
            debug call ErrorMsg("RegenBonus_$NAME$.setBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values = BonusValues.getInstance(u)
        set values.$NAME$Regen = amount
        
        return amount
    endmethod
    
    method getBonus takes unit u returns integer
        local BonusValues values
        
        if not IsUnitIndexed(u) then
            debug call ErrorMsg("RegenBonus_$NAME$.getBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values = BonusValues[u]
        
        if values == 0 then
            return 0
        endif
        
        return values.$NAME$Regen
    endmethod
    
    method removeBonus takes unit u returns nothing
        call this.setBonus(u, 0)
    endmethod
    
    method isValidBonus takes unit u, integer value returns boolean
        return IsUnitIndexed(u)
    endmethod
endstruct
//! endtextmacro

//! runtextmacro RegenBonuses_RegenBonusDefine("life")
//! runtextmacro RegenBonuses_RegenBonusDefine("mana")

private function OnLeaveMap takes unit u returns nothing
    if BonusValues[u] != 0 then
        call BonusValues[u].destroy()
    endif
endfunction

private function OnInit takes nothing returns nothing
    call OnUnitDeindexed(OnLeaveMap)
    
    set BONUS_MANA_REGEN         = RegenBonus_mana.create()
    set BONUS_LIFE_REGEN_PERCENT = RegenBonus_life.create()
endfunction
endlibrary

//TESH.scrollpos=0
//TESH.alwaysfold=0
library UnitMaxStateBonuses requires BonusMod, UnitMaxState, AutoIndex
////////////////////////////////////////////////////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ UnitMaxStateBonuses for BonusMod
//@=============================================================================
//@ Credits:
//@-----------------------------------------------------------------------------
//@    Written by:
//@        Earth-Fury
//@=============================================================================
//@ Requirements:
//@-----------------------------------------------------------------------------
//@ This library requires the BonusMod library, the UnitMaxState library by
//@ Earth-Fury, and the AutoIndex library by grim001.
//@
//@=============================================================================
//@ Readme:
//@-----------------------------------------------------------------------------
//@ This library provides two new bonus types:
//@
//@   - BONUS_LIFE
//@   - BONUS_MANA
//@ 
//@ These bonuses, of course, raise a unit's maximum life and mana.
//@ 
//@ Note that if you simply wish to permanently increase or decrease the maximum
//@ life or mana of a unit, you are likely best off using UnitMaxState directly.
//@
//@ The minimum life and mana bonuses are 1 more than -(unit's max state).
//@ That is to say, these bonuses can not fully remove a unit's life or mana.
//@
//@ There is no maximum bonus.
//@
//@ There is nothing to configure.
//@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
////////////////////////////////////////////////////////////////////////////////

globals
    Bonus BONUS_LIFE
    Bonus BONUS_MANA
endglobals

private function ErrorMsg takes string func, string s returns nothing
    call BJDebugMsg("|cffFF0000UnitMaxStateBonus Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

private struct BonusValues
    public integer mana = 0
    public integer life = 0
    
    public unit owner
    
    private static thistype array owners
    
    private static method create takes unit u returns thistype
        local thistype this = thistype.allocate()
        
        set this.owner = u
        
        set thistype.owners[GetUnitId(u)] = this
        
        return this
    endmethod
    
    private method onDestroy takes nothing returns nothing
        set thistype.owners[GetUnitId(this.owner)] = thistype(0)
        set this.owner = null
    endmethod
    
    public static method getInstance takes unit u returns thistype
        if thistype.owners[GetUnitId(u)] == 0 then
            return thistype.create(u)
        else
            return thistype.owners[GetUnitId(u)]
        endif
    endmethod
    
    public static method operator[] takes unit u returns thistype
        return thistype.owners[GetUnitId(u)]
    endmethod
    
    public static method operator[]= takes unit u, thistype i returns nothing
        set thistype.owners[GetUnitId(u)] = i
    endmethod
endstruct

//! textmacro UnitMaxStateBonus_DefineBonus takes NAME, STATE, MIN
private struct MaxStateBonus_$NAME$ extends Bonus
    integer minBonus = -2147483648
    integer maxBonus =  2147483647
    
    method setBonus takes unit u, integer amount returns integer
        local BonusValues values
        local integer actual
        local integer new
        local real factor
        
        if not IsUnitIndexed(u) then
            debug call ErrorMsg("MaxStateBonus_$NAME$.setBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values = BonusValues.getInstance(u)
        
        set actual = R2I(GetUnitState(u, UNIT_STATE_MAX_$STATE$)) - values.$NAME$
        set new = actual + amount
        
        set factor = GetUnitState(u, UNIT_STATE_$STATE$) / GetUnitState(u, UNIT_STATE_MAX_$STATE$)
        
        if new < $MIN$ then
            if actual < $MIN$ then
                set values.$NAME$ = 0
            else
                set values.$NAME$ = -actual + $MIN$
            endif
            
            call SetUnitState(u, UNIT_STATE_$STATE$, $MIN$)
            call SetUnitMaxState(u, UNIT_STATE_MAX_$STATE$, $MIN$)
            return values.$NAME$
        else
            set values.$NAME$ = amount
            
            call SetUnitMaxState(u, UNIT_STATE_MAX_$STATE$, new)
            call SetUnitState(u, UNIT_STATE_$STATE$, new * factor)
            
            return values.$NAME$
        endif
    endmethod
    
    method getBonus takes unit u returns integer
        local BonusValues values
        local integer actual
        local integer new
        local real factor
        
        if not IsUnitIndexed(u) then
            debug call ErrorMsg("MaxStateBonus_$NAME$.getBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values = BonusValues[u]
        
        if values == 0 then
            return 0
        endif
        
        set values.$NAME$ = R2I(GetUnitState(u, UNIT_STATE_MAX_$STATE$)) - (R2I(GetUnitState(u, UNIT_STATE_MAX_$STATE$)) - values.$NAME$)
        
        return values.$NAME$
    endmethod
    
    method removeBonus takes unit u returns nothing
        call this.setBonus(u, 0)
    endmethod
    
    method isValidBonus takes unit u, integer value returns boolean
        local integer currentBonus
        
        if not IsUnitIndexed(u) then
            return false
        endif
        
        set currentBonus = this.getBonus(u)
        
        return R2I(GetUnitState(u, UNIT_STATE_MAX_$STATE$)) - currentBonus + value >= $MIN$
    endmethod
endstruct
//! endtextmacro

//! runtextmacro UnitMaxStateBonus_DefineBonus("life", "LIFE", "1")
//! runtextmacro UnitMaxStateBonus_DefineBonus("mana", "MANA", "1")

private function OnLeaveMap takes unit u returns nothing
    if BonusValues[u] != 0 then
        call BonusValues[u].destroy()
    endif
endfunction

private module StateInit
private static method onInit takes nothing returns nothing
    set BONUS_LIFE = MaxStateBonus_life.create()
    set BONUS_MANA = MaxStateBonus_mana.create()
    
    call OnUnitDeindexed(OnLeaveMap)
endmethod

endmodule

private struct Data
    implement StateInit
endstruct


endlibrary

//TESH.scrollpos=9
//TESH.alwaysfold=0
library MovementBonus initializer OnInit requires BonusMod, AutoIndex
////////////////////////////////////////////////////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ MovementBonus for BonusMod
//@=============================================================================
//@ Credits:
//@-----------------------------------------------------------------------------
//@    Written by:
//@        Earth-Fury
//@=============================================================================
//@ Requirements:
//@-----------------------------------------------------------------------------
//@ This library requires the BonusMod library, and the AutoIndex library.
//@
//@=============================================================================
//@ Readme:
//@-----------------------------------------------------------------------------
//@ This library provides one new bonus type:
//@
//@   - BONUS_MOVEMENT_SPEED
//@         Modifies a unit's movement speed. 
//@ 
//@ A unit's movement speed can never go below or above the values configured
//@ in the gameplay constants for a map.
//@ 
//@ You should not modify a unit's movement speed any way other than via
//@ BonusMod. Doing so will cause issues.
//@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Configuration:
//==============================================================================

//------------------------------------------------------------------------------
// The following constants must be equal to the equivalent gameplay constants.
// By default, these are set to the default vlues for the gameplay constants.
//------------------------------------------------------------------------------
globals
    constant integer MAX_UNIT_MOVEMENT = 400
    constant integer MIN_UNIT_MOVEMENT = 150
    constant integer MAX_BUILDING_MOVEMENT = 400
    constant integer MIN_BUILDING_MOVEMENT = 25
endglobals

//==============================================================================
// End of configuration
//==============================================================================
globals
    Bonus BONUS_MOVEMENT_SPEED
endglobals

private function ErrorMsg takes string func, string s returns nothing
    call BJDebugMsg("|cffFF0000MovementBonus Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

private struct BonusValue
    public integer speed = 0
    
    public unit owner
    
    private static thistype array owners
    
    public static thistype array all
    public static integer count = 0
    public integer index
    
    private static method create takes unit u returns thistype
        local thistype this = thistype.allocate()
        
        set this.owner = u
        
        set thistype.owners[GetUnitId(u)] = this
        
        set thistype.all[thistype.count] = this
        set this.index = thistype.count
        set thistype.count = thistype.count + 1
        
        return this
    endmethod
    
    private method onDestroy takes nothing returns nothing
        set thistype.owners[GetUnitId(this.owner)] = thistype(0)
        
        set thistype.all[this.index] = thistype.all[thistype.count]
        set thistype.count = thistype.count - 1
        
        set this.owner = null
    endmethod
    
    public static method getInstance takes unit u returns thistype
        if thistype.owners[GetUnitId(u)] == 0 then
            return thistype.create(u)
        else
            return thistype.owners[GetUnitId(u)]
        endif
    endmethod
    
    public static method operator[] takes unit u returns thistype
        return thistype.owners[GetUnitId(u)]
    endmethod
    
    public static method operator[]= takes unit u, thistype i returns nothing
        set thistype.owners[GetUnitId(u)] = i
    endmethod
endstruct

private struct MovementBonus extends Bonus
    integer minBonus
    integer maxBonus
    
    static method create takes integer min, integer max returns thistype
        local thistype this = allocate()
        
        set this.minBonus = min
        set this.maxBonus = max
        
        return this
    endmethod
    
    method setBonus takes unit u, integer amount returns integer
        local BonusValue value
        local integer min
        local integer max
        
        local integer actualSpeed
        
        if not IsUnitIndexed(u) then
            debug call ErrorMsg("MovementBonus.setBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set value = BonusValue.getInstance(u)
        
        if IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            set min = MIN_BUILDING_MOVEMENT
            set max = MAX_BUILDING_MOVEMENT
        else
            set min = MIN_UNIT_MOVEMENT
            set max = MAX_UNIT_MOVEMENT
        endif
        
        set actualSpeed = R2I(GetUnitMoveSpeed(u)) - value.speed
        
        if actualSpeed + amount < min then
            debug call ErrorMsg("MovementBonus.setBonus()", "Attempting to set a unit's speed below it's minimum")
            set amount = -actualSpeed + min
        elseif actualSpeed + amount > max then
            debug call ErrorMsg("MovementBonus.setBonus()", "Ateempting to set a unit's speed above it's maximum")
            set amount = max - actualSpeed
        endif
        
        call SetUnitMoveSpeed(u, actualSpeed + amount)
        set value.speed = amount
        
        return amount
    endmethod
    
    method getBonus takes unit u returns integer
        local BonusValue value
        
        if not IsUnitIndexed(u) then
            debug call ErrorMsg("MovementBonus.getBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set value = BonusValue[u]
        
        if value == 0 then
            return 0
        endif
        
        return value.speed
    endmethod
    
    method removeBonus takes unit u returns nothing
        call this.setBonus(u, 0)
    endmethod
    
    method isValidBonus takes unit u, integer value returns boolean
        local integer min
        local integer max
        
        local integer currentBonus
        local integer actualSpeed
        
        if not IsUnitIndexed(u) then
            return false
        endif
        
        if IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            set min = MIN_BUILDING_MOVEMENT
            set max = MAX_BUILDING_MOVEMENT
        else
            set min = MIN_UNIT_MOVEMENT
            set max = MAX_UNIT_MOVEMENT
        endif
        
        set actualSpeed = R2I(GetUnitMoveSpeed(u)) - this.getBonus(u)
        
        if actualSpeed + value < min then
            return false
        elseif actualSpeed + value > max then
            return false
        else
            return true
        endif
    endmethod
endstruct

private function OnLeaveMap takes unit u returns nothing
    if BonusValue[u] != 0 then
        call BonusValue[u].destroy()
    endif
endfunction

private function OnInit takes nothing returns nothing
    local integer min
    local integer max
    
    call OnUnitDeindexed(OnLeaveMap)
    
    if MAX_UNIT_MOVEMENT > MAX_BUILDING_MOVEMENT then
        set max = MAX_UNIT_MOVEMENT
    else
        set max = MAX_BUILDING_MOVEMENT
    endif
    
    if MIN_UNIT_MOVEMENT < MIN_BUILDING_MOVEMENT then
        set min = MIN_UNIT_MOVEMENT
    else
        set min = MIN_BUILDING_MOVEMENT
    endif
    
    set BONUS_MOVEMENT_SPEED = MovementBonus.create(min, max)
endfunction
endlibrary

//TESH.scrollpos=9
//TESH.alwaysfold=0
library UnitMaxState requires optional AbilityPreload, optional xepreload
//==============================================================================
// UnitMaxState v2.1
//==============================================================================
// Credits:
//------------------------------------------------------------------------------
// Written By:
//     Earth-Fury
// 
// Original System By:
//     Blade.dk
// 
// Intermittent Version By:
//     Deaod
//
// With Thanks To:
//     - weaaddar for BonusMod and thus inspiration
//     - PitzerMike for the ObjectMerger
//     - Vexorian for vJass and Jass Helper
//     - PipeDream for Grimoire
//     - SFilip for TESH
//     - MindWorX for maintaining NewGen
//------------------------------------------------------------------------------
// If you use this library in your map, please at least give credit to Blade.dk.
// Without him, this library would not exist.
//==============================================================================
// Introduction:
//------------------------------------------------------------------------------
// UnitMaxState is a library which allows you to modify a unit's maximum life,
// or maximum mana. To achieve this, the library abuses a bug with the AIlf and
// AImz abilities, which is too complex to explain here.
// 
// I do believe it was indeed Blade.dk who initially found this bug. If not,
// it's still his system I stole and rewrote. Further, let me thank Deaod for
// writing up his version of this system, which inspired both the reality of
// this rewrite, and the method abilities are handled within it.
// 
//==============================================================================
// Requirements:
//------------------------------------------------------------------------------
// UnitMaxState is written in vJass and requires the NewGen editor, or
// Jass Helper with PitzerMike's Object Merger configured for it.
// 
// UnitMaxState requires the latest version of Jass Helper.
// 
// Preloading of abilities requires either AbilityPreload or xepreload. Neither
// are required for the library to function; however, having one or the other
// will remove the slight delay the first time a unit's max state is changed.
// 
//==============================================================================
// Using UnitMaxState:
//------------------------------------------------------------------------------
// UnitMaxState comes with two useful functions:
// 
// nothing SetUnitMaxState(unit <target>, unitstate <state>, real <value>)
//     Changes <target>'s unitstate <state> to be equal to <value>.
//
// nothing AddUnitMaxState(unit <target>, unitstate <state>, real <value>)
//     Adds <value> to <target>'s <state> unitstate. Note that you can use
//     negative values with this function.
//
// Both of these functions accept unitstate's other than UNIT_STATE_MAX_LIFE and
// UNIT_STATE_MAX_MANA. There is a small performance penalty in using these over
// direct usage of SetUnitState.
// 
// You must not use life/mana boosting upgrades in combination with this system.
// 
// Attempting to set a unit's maximum life below 1, or mana below 0 will do
// nothing. A debug message will be output if the script is compiled in
// debug mode.
//==============================================================================



//==============================================================================
// Configuration:
//------------------------------------------------------------------------------
// The below textmacro call is an all-in-one configuration line.
//------------------------------------------------------------------------------
// The first parameter is a boolean.
// 
// If true, the abilities used by this system will be created on save. This adds
// a slight delay to saving your map. You only ever have to create the abilities
// the first time this library is added to your map, or if you modify any of
// the other configuration options.
// 
// Note that to make the ability creation permanent, you must save with ability
// creation enabled, close your map, and reopen it in the editor. You can then
// disable ability creation, as the abilities will be permanently in your map.
//------------------------------------------------------------------------------
// The second parameter is an integer.
// 
// This is the number of abilities this system will use for adding/removing
// life/mana. Note that this system uses four sets of abilities, so the actual
// number of abilities generated and used will be the value you pass here,
// multiplied by 4.
// 
// The higher this number, the faster large bonuses will be added. This number
// should never have to go above 13. Between 3 and 5 will work fine for most
// maps.
//------------------------------------------------------------------------------
// The fourth and fifth parameters are 3 character prefixes for rawcodes.
//
// The first one is for the life-modifying abilities, while the second is for
// the mana-modifying abilities.
// 
// Please, make sure your map has no abilities whose rawcodes begin with either
// of these prefixes before saving! Otherwise, those abilities will be
// overwritten. You can change these to any 3 character combination, if your
// map does already contain abilities whose rawcodes begin with these prefixes.
//------------------------------------------------------------------------------

//! runtextmacro UnitMaxState_Configuration("false", "3", "ZxL", "ZxM")

//------------------------------------------------------------------------------
// End of configuration
//------------------------------------------------------------------------------

//! textmacro UnitMaxState_Configuration takes LOAD_ABILITIES, ABILITY_COUNT, LIFE_PREFIX, MANA_PREFIX
    //*
    // externalblock extension=lua ObjectMerger $FILENAME$
    //! i function CreateAbilities(baseAbility, rawcodePrefix, field, name, icon)
    //! i     k = 0
    //! i     for sign = -1, 1, 2 do
    //! i         signStr = "+"
    //! i         if sign < 0 then
    //! i             signStr = "-"
    //! i         end
    //! i         j = 0
    //! i         for i = 0, (abilityCount - 1) * 3, 3 do
    //! i             j = j + 1
    //! i             createobject(baseAbility, rawcodePrefix .. string.sub(Chars, k + 1, k + 1))
    //! i             makechange(current, "anam", "UnitMaxState - " .. name)
    //! i             makechange(current, "ansf", "(" .. signStr .. tostring(j) .. ")")
    //! i             makechange(current, "aart", "ReplaceableTextures\\CommandButtons\\" .. icon)
    //! i             makechange(current, "aite", 0)
    //! i             makechange(current, "alev", 4)
    //! i             makechange(current, field, 1, 0)
    //! i             makechange(current, field, 2, 2^(i + 0) * sign)
    //! i             makechange(current, field, 3, 2^(i + 1) * sign)
    //! i             makechange(current, field, 4, 2^(i + 2) * sign)
    //! i             k = k + 1
    //! i         end
    //! i     end
    //! i end
    //! i if $LOAD_ABILITIES$ then
    //! i     setobjecttype("abilities")
    //! i     abilityCount = $ABILITY_COUNT$
    //! i     Chars = "abcdefghijklmnopqrstuvwxyz"
    //! i     CreateAbilities("AIlf", "$LIFE_PREFIX$", "Ilif", "Life", "BTNHealthStone.blp")
    //! i     CreateAbilities("AImz", "$MANA_PREFIX$", "Iman", "Mana", "BTNManaStone.blp")
    //! i end
    // endexternalblock
    // */
    
    globals
        private constant integer RAWCODE_LIFE = '$LIFE_PREFIX$a'
        private constant integer RAWCODE_MANA = '$MANA_PREFIX$a'
        
        public constant integer ABILITY_COUNT = $ABILITY_COUNT$
    endglobals
//! endtextmacro
globals
    private constant boolean PRELOAD_ABILITIES = false
    
    private integer array POWERS_OF_2
endglobals

private function ErrorMsg takes string s returns nothing
    debug call BJDebugMsg("SetUnitMaxState: " + s)
endfunction

function SetUnitMaxState takes unit target, unitstate state, real targetValue returns nothing
    local integer difference
    local integer rawcode
    
    local integer abilityId
    local integer abilityLevel
    
    local integer currentAbility
    
    if state == UNIT_STATE_MAX_LIFE then
        set rawcode = RAWCODE_LIFE
        
        if targetValue < 1 then
            call ErrorMsg("You can not set a unit's max life to below 1")
            return
        endif
    elseif state == UNIT_STATE_MAX_MANA then
        set rawcode = RAWCODE_MANA
        
        if targetValue < 0 then
            call ErrorMsg("You can not set a unit's max mana to below 0")
            return
        endif
    else
        call SetUnitState(target, state, targetValue)
        return
    endif
    
    set difference = R2I(targetValue) - R2I(GetUnitState(target, state))
    
    if difference < 0 then
        set difference = -difference
        set rawcode = rawcode + ABILITY_COUNT
    endif
    
    set abilityId = ABILITY_COUNT - 1
    set abilityLevel = 4
    set currentAbility = rawcode + abilityId
    loop
        exitwhen difference == 0
        
        if difference >= POWERS_OF_2[abilityId * 3 + (abilityLevel - 2)] then
            call UnitAddAbility(target, currentAbility)
            call SetUnitAbilityLevel(target, currentAbility, abilityLevel)
            call UnitRemoveAbility(target, currentAbility)
            
            set difference = difference - POWERS_OF_2[abilityId * 3 + (abilityLevel - 2)]
        else
            set abilityLevel = abilityLevel - 1
            if abilityLevel <= 1 then
                set abilityId = abilityId - 1
                set abilityLevel = 4
                set currentAbility = rawcode + abilityId
            endif
        endif
    endloop
endfunction

function AddUnitMaxState takes unit target, unitstate state, real additionalValue returns nothing
    call SetUnitMaxState(target, state, GetUnitState(target, state) + additionalValue)
endfunction

//! textmacro UnitMaxState_Preload takes RAWCODE
    set i = 0
    loop
        exitwhen i == ABILITY_COUNT * 2 - 1
        
        static if LIBRARY_AbilityPreload then
            call AbilityPreload($RAWCODE$ + i)
        elseif LIBRARY_xepreload then
            call XE_PreloadAbility($RAWCODE$ + i)
        endif
        
        set i = i + 1
    endloop
//! endtextmacro

private module UnitStatInit
private static method onInit takes nothing returns nothing
    local integer i
    local integer k
    
    set i = 1
    set POWERS_OF_2[0] = 1
    loop
        exitwhen i == ABILITY_COUNT * 2 * 2 * 3 + 1
        
        set POWERS_OF_2[i] = POWERS_OF_2[i - 1] * 2
        set i = i + 1
    endloop
    
    static if DEBUG_MODE and PRELOAD_ABILITIES and not LIBRARY_AbilityPreload and not LIBRARY_xepreload then
        call ErrorMsg("Ability preloading was enabled, but neither of the supported preload libraries are present")
    elseif PRELOAD_ABILITIES then
        //! runtextmacro UnitMaxState_Preload("RAWCODE_LIFE")
        //! runtextmacro UnitMaxState_Preload("RAWCODE_MANA")
    endif
endmethod
endmodule


private struct Data
    implement UnitStatInit
endstruct

endlibrary

//TESH.scrollpos=0
//TESH.alwaysfold=0
library AutoIndex requires UnitDex

    function interface IndexFunc takes unit u returns nothing
    
    struct AutoIndex
    
        private static IndexFunc array indexfuncs
        private static integer indexfuncs_n = -1
        private static IndexFunc array deindexfuncs
        private static integer deindexfuncs_n = -1
        private static IndexFunc indexfunc
    
        static method getIndex takes unit u returns integer
            return GetUnitId(u)
        endmethod
        
        static method isUnitIndexed takes unit u returns boolean
            return u != null and UnitDex.Unit[GetUnitId(u)] == u
        endmethod
    
        static method getIndexDebug takes unit u returns integer
            if u == null then
                return 0
            elseif GetUnitTypeId(u) == 0 then
                   call BJDebugMsg("AutoIndex error: Removed or decayed unit passed to GetUnitId.")
            elseif UnitDex.Unit[GetUnitId(u)] != u and GetIssuedOrderId() != 852056 then
                call BJDebugMsg("AutoIndex error: "+GetUnitName(u)+" is a filtered unit.")
            endif
            
            return getIndex(u)
        endmethod
        
        private static method onUnitIndexed_sub takes nothing returns nothing
            call indexfunc.evaluate(GetEnumUnit())
        endmethod
        
        static method onUnitIndexed takes IndexFunc func returns nothing
            set indexfuncs_n = indexfuncs_n + 1
            set indexfuncs[indexfuncs_n] = func
            if UnitDex.Initialized then //During initialization, evaluate the indexfunc for every preplaced unit.
                set indexfunc = func
                call ForGroup(UnitDex.Group, function AutoIndex.onUnitIndexed_sub)
            endif
        endmethod
        
        static method onUnitDeindexed takes IndexFunc func returns nothing
            set deindexfuncs_n = deindexfuncs_n + 1
            set deindexfuncs[deindexfuncs_n] = func
        endmethod
    endstruct
    
    function OnUnitIndexed takes IndexFunc func returns nothing
        call AutoIndex.onUnitIndexed(func)
    endfunction

    function OnUnitDeindexed takes IndexFunc func returns nothing
        call AutoIndex.onUnitDeindexed(func)
    endfunction

endlibrary

library xebasic
//**************************************************************************
//
// xebasic 0.4
// =======
// XE_DUMMY_UNITID : Rawcode of the dummy unit in your map. It should
//                   use the dummy.mdx model, so remember to import it as
//                   well, just use copy&paste to copy the dummy from the
//                   xe map to yours, then change the rawcode.
//
// XE_HEIGHT_ENABLER: Medivh's raven form ability, you may need to change
//                    this rawcode to another spell that morphs into a flier
//                    in case you modified medivh's spell in your map.
//
// XE_TREE_RECOGNITION: The ancients' Eat tree ability, same as with medivh
//                      raven form, you might have to change it.
//
// XE_ANIMATION_PERIOD: The global period of animation used by whatever
//                      timer that depends on it, if you put a low value
//                      the movement will look good but it may hurt your
//                      performance, if instead you use a high value it
//                      will not lag but will be fast.
//
// XE_MAX_COLLISION_SIZE: The maximum unit collision size in your map, if
//                        you got a unit bigger than 197.0 it would be
//                        a good idea to update this constant, since some
//                        enums will not find it. Likewise, if none of
//                        your units can go bellow X and X is much smaller
//                        than 197.0, it would be a good idea to update
//                        as well, since it will improve the performance
//                        those enums.
//
// Notice you probably don't have to update this library, unless I specify
// there are new constants which would be unlikely. 
//
//**************************************************************************

//===========================================================================
globals
   constant integer XE_DUMMY_UNITID       = 'e001'
   constant integer XE_HEIGHT_ENABLER     = 'Amrf'
   constant integer XE_TREE_RECOGNITION   = 'Aeat'
   constant real    XE_ANIMATION_PERIOD   =  0.025
   constant real    XE_MAX_COLLISION_SIZE =  197.0
endglobals

endlibrary


//TESH.scrollpos=0
//TESH.alwaysfold=0
library xepreload requires xebasic, optional TimerUtils
//************************************************************************
// xepreload 0.7 // modified by triggerhappy, module initialiazer
// ---------
// Ah, the joy of preloading abilities, it is such a necessary evil...
// Notice you are not supposed to use this system in places outside map init
//
// This one does the preloading and tries to minimize the hit on loading time
// for example, it only needs one single native call per ability preloaded.
//
//************************************************************************

//===========================================================================================================
    globals
        private unit dum=null
        private constant boolean ALLOW_DEBUGGING=true
    endglobals
    private keyword DebugIdInteger2IdString

    //inline friendly (when debug mode is off..)
    function XE_PreloadAbility takes integer abilid returns nothing
        call UnitAddAbility(dum, abilid)
        static if DEBUG_MODE then
            static if ALLOW_DEBUGGING then
                if GetUnitAbilityLevel(dum, abilid) == 0 then
                    call BJDebugMsg("XE_PreloadAbility: Ability "+ GetObjectName(abilid) + " " + DebugIdInteger2IdString.evaluate(abilid)+" does not exist.")
                endif
            endif
        endif
    endfunction
    // ................................................................................

    //================================================================================
    // Convert a integer id value into a 4-letter id code.
    // * Taken from cheats.j so I don't have to code it again.
    // * Used only on debug so making a whole library for it seemed silly
    // * Private so people don't begin using xepreload just to call this function....
    // * It will not work correctly if you paste this code in the custom script section
    //   due to the infamous % bug. Then again, if you do that then you probably 
    // deserve it....
    //
    private function DebugIdInteger2IdString takes integer value returns string
     local string charMap = ".................................!.#$%&'()*+,-./0123456789:;<=>.@ABCDEFGHIJKLMNOPQRSTUVWXYZ[.]^_`abcdefghijklmnopqrstuvwxyz{|}~................................................................................................................................."
     local string result = ""
     local integer remainingValue = value
     local integer charValue
     local integer byteno

     set byteno = 0
     loop
         set charValue = ModuloInteger(remainingValue, 256)
         set remainingValue = remainingValue / 256
         set result = SubString(charMap, charValue, charValue + 1) + result
 
         set byteno = byteno + 1
         exitwhen byteno == 4
     endloop
     return result
    endfunction

    //--------------------------------
    private function kill takes nothing returns nothing
        call RemoveUnit(dum)
        set dum=null
        static if (LIBRARY_TimerUtils ) then
            call ReleaseTimer( GetExpiredTimer() )
        else
            call DestroyTimer(GetExpiredTimer())
        endif
    endfunction

    private module PreloadInit
        private static method onInit takes nothing returns nothing
            local timer t
            set dum = CreateUnit( Player(15), XE_DUMMY_UNITID, 0,0,0)
            if( dum == null) then
                debug call BJDebugMsg("xePreload : XE_DUMMY_UNITID ("+DebugIdInteger2IdString.evaluate(XE_DUMMY_UNITID)+") not added correctly to the map.")
            endif
            static if (LIBRARY_TimerUtils) then
                set t=NewTimer()
            else
                set t=CreateTimer()
            endif
            call TimerStart(t,0.0,false,function kill)
            set t=null
        endmethod
    endmodule

    private struct Init extends array
        implement PreloadInit
    endstruct
    
endlibrary


// Integration of TriggerHappy's InventorySys 1.4.1 into the TerrainDev copy.
// Original terrain, placed units, melee initialization and missile sources retained.
scope TerrainInventory initializer Init
    globals
        Camera array PlayerCamera
        unit array PlayerHero
    endglobals

    private function ToggleInventory takes integer pid returns nothing
        local Inventory inv = Inventory[PlayerHero[pid]]
        if inv != 0 then
            call inv.show(not inv.displayed, PlayerCamera[pid])
        endif
    endfunction

    private function ToggleEquipment takes integer pid returns nothing
        local Equipment eq = Equipment[PlayerHero[pid]]
        if eq != 0 then
            call eq.show(not eq.displayed, PlayerCamera[pid])
        endif
    endfunction

    private function Spell takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local integer pid = GetPlayerId(GetOwningPlayer(u))
        if u == PlayerHero[pid] then
            if GetSpellAbilityId() == 'A001' then
                call ToggleEquipment(pid)
            elseif GetSpellAbilityId() == 'A002' then
                call ToggleInventory(pid)
            endif
        endif
        set u = null
    endfunction

    private function Chat takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        local string s = GetEventPlayerChatString()
        if s == "-audit-original" then
            set CameraAuditStoredEye = true
            call DisplayTimedTextToPlayer(GetTriggerPlayer(),0,0,8,"AUDIT: original stored eye")
        elseif s == "-audit-local" then
            set CameraAuditStoredEye = false
            call DisplayTimedTextToPlayer(GetTriggerPlayer(),0,0,8,"AUDIT: local native eye")
        elseif s == "-inventario" then
            call ToggleInventory(pid)
        elseif s == "-equipo" then
            call ToggleEquipment(pid)
        elseif s == "-ui" then
            call ToggleInventory(pid)
            call ToggleEquipment(pid)
        elseif s == "-ayudaui" then
            call DisplayTimedTextToPlayer(GetTriggerPlayer(),0,0,30,"Inventario: -inventario / Equipo: -equipo / Ambos: -ui. Clic izquierdo: seleccionar. Clic derecho: equipar o quitar. Botones laterales: paginas, soltar y vender. Los requisitos del objeto se conservan.")
        endif
    endfunction

    private function Start takes nothing returns nothing
        local integer pid = 0
        local unit u
        local Equipment eq
        local Inventory inv
        local real x
        local real y
        loop
            exitwhen pid == 12
            if GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(pid)) == MAP_CONTROL_USER then
                set x = GetStartLocationX(GetPlayerStartLocation(Player(pid)))
                set y = GetStartLocationY(GetPlayerStartLocation(Player(pid)))
                set PlayerCamera[pid] = Camera.create()
                set u = CreateUnit(Player(pid), 'Hpal', x+220, y, 270)
                set PlayerHero[pid] = u
                set eq = Equipment.create(u)
                set inv = Inventory.create(u)
                call UnitAddAbility(u, 'A001')
                call UnitAddAbility(u, 'A002')
                call UnitAddItemById(u, 'ckng')
                call UnitAddItemById(u, 'ratf')
                call UnitAddItemById(u, 'belv')
                call UnitAddItemById(u, 'bgst')
                call UnitAddItemById(u, 'rde3')
                call UnitAddItemById(u, 'I004')
                call UnitAddItemById(u, 'I009')
                call UnitAddItemById(u, 'I00A')
                call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_EXTRA), Player(pid), bj_ALLIANCE_ALLIED_VISION)
                call SetPlayerAllianceStateBJ(Player(pid), Player(bj_PLAYER_NEUTRAL_EXTRA), bj_ALLIANCE_ALLIED_VISION)
                if GetLocalPlayer() == Player(pid) then
                    call ClearSelection()
                    call SelectUnit(u, true)
                    call PanCameraToTimed(x+220,y,0)
                endif
                call DisplayTimedTextToPlayer(Player(pid),0,0,25,"TerrainDev + InventorySys 1.4.1. -ui abre inventario y equipo; -ayudaui muestra controles. Heroe de integracion con ocho objetos de la demo.")
            endif
            set pid = pid+1
        endloop
        call DestroyTimer(GetExpiredTimer())
        set u = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local trigger c = CreateTrigger()
        local integer i = 0
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(t,function Spell)
        loop
            exitwhen i == 12
            call TriggerRegisterPlayerChatEvent(c,Player(i),"-",false)
            set i = i+1
        endloop
        call TriggerAddAction(c,function Chat)
        // Wait until native melee setup and original item definitions have run.
        call TimerStart(CreateTimer(),0.20,false,function Start)
    endfunction
endscope


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

