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

// TerrainDev Classic 1.27b. Hidden-item walkability technique: Rising_Dusk/BPower.
// Validates swept ground footprints; no mutation of actors or missile libraries.
library GroundCollision initializer Init requires WorldBounds, IsDestructableTree
struct GroundCollision extends array
    readonly static real x
    readonly static real y
    readonly static unit hit = null
    readonly static integer reason = 0 // 0 clear, 1 ground/destructible, 2 enemy
    private static item probe
    private static rect area = Rect(0.,0.,256.,256.)
    private static group targets = CreateGroup()
    private static location heightPoint = Location(0.,0.)
    private static item array hidden
    private static integer hiddenCount = 0
    private static real testX
    private static real testY
    private static real testRadius
    private static boolean destBlocked

    static method alive takes unit u returns boolean
        return GetUnitTypeId(u) != 0 and GetWidgetLife(u) > 0.405
    endmethod

    private static method hideItem takes nothing returns nothing
        local item it = GetEnumItem()
        if it != probe and IsItemVisible(it) then
            set hidden[hiddenCount] = it
            set hiddenCount = hiddenCount+1
            call SetItemVisible(it,false)
        endif
        set it = null
    endmethod

    private static method point takes real px, real py returns boolean
        local real dx
        local real dy
        if IsTerrainPathable(px,py,PATHING_TYPE_WALKABILITY) then
            return false
        endif
        call MoveRectTo(area,px,py)
        call EnumItemsInRect(area,null,function thistype.hideItem)
        call SetItemPosition(probe,px,py)
        set dx = GetItemX(probe)-px
        set dy = GetItemY(probe)-py
        call SetItemVisible(probe,false)
        loop
            exitwhen hiddenCount == 0
            set hiddenCount = hiddenCount-1
            call SetItemVisible(hidden[hiddenCount],true)
            set hidden[hiddenCount] = null
        endloop
        return dx*dx+dy*dy <= 1.
    endmethod

    private static method destructable takes nothing returns nothing
        local destructable d = GetEnumDestructable()
        local real dx = GetDestructableX(d)-testX
        local real dy = GetDestructableY(d)-testY
        if not destBlocked and GetWidgetLife(d) > 0.405 and dx*dx+dy*dy <= (testRadius+32.)*(testRadius+32.) then
            // Native pathing covers authored footprints. This also catches live
            // trees/solid tall destructibles with missing/small footprints.
            if GetDestructableOccluderHeight(d) >= 32. or IsTreeAlive(d) then
                set destBlocked = true
            endif
        endif
        set d = null
    endmethod

    static method height takes real px, real py returns real
        call MoveLocation(heightPoint,px,py)
        return GetLocationZ(heightPoint)
    endmethod

    static method clear takes real px, real py, real radius returns boolean
        local integer i = 0
        local real a
        if px-radius <= WorldBounds.minX or px+radius >= WorldBounds.maxX or py-radius <= WorldBounds.minY or py+radius >= WorldBounds.maxY then
            return false
        endif
        if not point(px,py) then
            return false
        endif
        loop
            exitwhen i == 8
            set a = I2R(i)*bj_PI/4.
            if not point(px+(radius+2.)*Cos(a),py+(radius+2.)*Sin(a)) then
                return false
            endif
            set i = i+1
        endloop
        set testX = px
        set testY = py
        set testRadius = radius
        set destBlocked = false
        call SetRect(area,px-radius-64.,py-radius-64.,px+radius+64.,py+radius+64.)
        call EnumDestructablesInRect(area,null,function thistype.destructable)
        // Restore the query rectangle size expected by the item probe.
        call SetRect(area,0.,0.,256.,256.)
        return not destBlocked
    endmethod

    static method trace takes real ax, real ay, real bx, real by, real radius, unit source, player owner, boolean units returns integer
        local real dx = bx-ax
        local real dy = by-ay
        local integer steps = R2I(SquareRoot(dx*dx+dy*dy)/8.)+1
        local integer i = 1
        local real nx
        local real ny
        local real lastZ = height(ax,ay)
        local real z
        local unit u
        set x = ax
        set y = ay
        set hit = null
        set reason = 0
        loop
            exitwhen i > steps
            set nx = ax+dx*I2R(i)/I2R(steps)
            set ny = ay+dy*I2R(i)/I2R(steps)
            set z = height(nx,ny)
            if not clear(nx,ny,radius) or RAbsBJ(z-lastZ) > 24. then
                set reason = 1
                return reason
            endif
            if units then
                call GroupEnumUnitsInRange(targets,nx,ny,radius+128.,null)
                loop
                    set u = FirstOfGroup(targets)
                    exitwhen u == null
                    call GroupRemoveUnit(targets,u)
                    if u != source and alive(u) and IsUnitEnemy(u,owner) and not IsUnitType(u,UNIT_TYPE_FLYING) and GetUnitTypeId(u) != 'dumi' and GetUnitTypeId(u) != 'dcst' and GetUnitTypeId(u) != 'rfct' then
                        if IsUnitInRangeXY(u,nx,ny,radius) then
                            set hit = u
                            set x = nx
                            set y = ny
                            set reason = 2
                            call GroupClear(targets)
                            set u = null
                            return reason
                        endif
                    endif
                endloop
            endif
            set x = nx
            set y = ny
            set lastZ = z
            set i = i+1
        endloop
        set u = null
        return 0
    endmethod

    static method initialize takes nothing returns nothing
        set probe = CreateItem('wolg',WorldBounds.minX+128.,WorldBounds.minY+128.)
        call SetItemVisible(probe,false)
    endmethod
endstruct
private function Init takes nothing returns nothing
    call GroundCollision.initialize()
endfunction
endlibrary

// Separate movement authority. Does not use/modify Missile.createEx or its timer.
library GroundMotion requires GroundCollision
struct GroundMotion
    readonly unit body
    readonly boolean artificial = false
    readonly boolean blocked = false
    readonly boolean hasGoal = false
    readonly real goalX
    readonly real goalY
    readonly static integer instantTransitions = 0
    readonly static integer xySteps = 0
    readonly static integer handoffs = 0
    real speed = 350.
    real radius = 24.

    static method create takes unit u returns thistype
        local thistype this = thistype.allocate()
        set body = u
        set artificial = false
        set blocked = false
        set hasGoal = false
        set speed = 350.
        set radius = 24.
        return this
    endmethod

    method destination takes real px, real py returns nothing
        set goalX = px
        set goalY = py
        set hasGoal = true
        set blocked = false
        if not artificial then
            call IssuePointOrder(body,"move",px,py)
        endif
    endmethod

    method enter takes nothing returns nothing
        local integer order = GetUnitCurrentOrder(body)
        if artificial then
            return
        endif
        set artificial = true
        set blocked = false
        call SetUnitPathing(body,false)
        if order == 851986 or order == 851971 or order == 851990 then
            // Initial zero-duration tick, before the first attack animation.
            // Proven in this 1.27b runtime to cancel native locomotion.
            call SetUnitPosition(body,GetUnitX(body),GetUnitY(body))
            set instantTransitions = instantTransitions+1
        endif
    endmethod

    method step takes real dt returns nothing
        local real ax = GetUnitX(body)
        local real ay = GetUnitY(body)
        local real dx
        local real dy
        local real distance
        local real advance
        local real nx
        local real ny
        if not artificial or not hasGoal or not GroundCollision.alive(body) then
            return
        endif
        set dx = goalX-ax
        set dy = goalY-ay
        set distance = SquareRoot(dx*dx+dy*dy)
        if distance <= 2. then
            set hasGoal = false
            set blocked = false
            return
        endif
        set advance = RMinBJ(speed*dt,distance)
        set blocked = GroundCollision.trace(ax,ay,ax+dx*advance/distance,ay+dy*advance/distance,radius,body,GetOwningPlayer(body),false) != 0
        set nx = GroundCollision.x
        set ny = GroundCollision.y
        call SetUnitX(body,nx)
        call SetUnitY(body,ny)
        set xySteps = xySteps+1
        if not blocked and distance <= advance+2. then
            set hasGoal = false
        endif
    endmethod

    method leave takes boolean resume returns nothing
        if artificial then
            set artificial = false
            set blocked = false
            call SetUnitPathing(body,true)
            if resume and hasGoal and GroundCollision.alive(body) then
                call IssuePointOrder(body,"move",goalX,goalY)
                set handoffs = handoffs+1
            endif
        endif
    endmethod

    method destroy takes nothing returns nothing
        call leave(false)
        set body = null
        set hasGoal = false
        call deallocate()
    endmethod
endstruct
endlibrary

library RapidFire initializer Init requires GroundMotion, Missile, Table, TimerUtils, SpellEffectEvent, RegisterPlayerUnitEvent
struct RapidBolt extends array
    // Collision stays independent of the decorative trail and death flash.
    static constant real HIT_RADIUS = 16.
    // Stand body width is 11.664 model units in all twelve unmodified variants.
    // Calibrated in game against the radius16 marker; glow/trail are decorative.
    static constant real VISUAL_SCALE = HIT_RADIUS/5.832
    private static unit array source
    private static player array owner
    readonly static integer live = 0
    readonly static integer hits = 0
    readonly static integer walls = 0

    private static method resolve takes Missile m returns boolean
        local integer result = GroundCollision.trace(m.prevX,m.prevY,m.x,m.y,HIT_RADIUS,source[m],owner[m],true)
        local unit target = GroundCollision.hit
        local unit caster = source[m]
        if result == 2 then
            set hits = hits+1
            if GetUnitTypeId(caster) != 0 then
                call UnitDamageTarget(caster,target,25.,false,false,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_MAGIC,null)
            endif
        elseif result == 1 or m.z < 0. then
            set walls = walls+1
            set result = 1
        endif
        set target = null
        set caster = null
        return result != 0
    endmethod
    static method onPeriod takes Missile m returns boolean
        return resolve(m)
    endmethod
    static method onFinish takes Missile m returns boolean
        call resolve(m)
        return true
    endmethod
    static method onRemove takes Missile m returns boolean
        set source[m] = null
        set owner[m] = null
        set live = live-1
        return false
    endmethod
    implement MissileStruct

    static method modelForColor takes playercolor value returns string
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
    endmethod

    static method shootColor takes unit caster, real px, real py, playercolor color returns Missile
        local real x = GetUnitX(caster)
        local real y = GetUnitY(caster)
        local real dx = px-x
        local real dy = py-y
        local real distance = SquareRoot(dx*dx+dy*dy)
        local real angle
        local real length
        local Missile m
        if distance < 8. then
            set angle = GetUnitFacing(caster)*bj_DEGTORAD
            set distance = 600.
            set dx = distance*Cos(angle)
            set dy = distance*Sin(angle)
        endif
        set length = RMinBJ(distance,1000.)
        set px = x+dx*length/distance
        set py = y+dy*length/distance
        call GroundCollision.trace(x,y,x+dx*24./distance,y+dy*24./distance,HIT_RADIUS,caster,GetOwningPlayer(caster),false)
        set m = Missile.createXYZ(GroundCollision.x,GroundCollision.y,70.,px,py,70.)
        set source[m] = caster
        set owner[m] = GetOwningPlayer(caster)
        set m.owner = owner[m]
        // Ability-specific swept collision chooses obstacles before damage;
        // it does not change the common module's callback ordering.
        set m.collision = 0.
        set m.model = modelForColor(color)
        set m.scale = VISUAL_SCALE
        call m.setMovementSpeed(1200.)
        set live = live+1
        call launch(m)
        return m
    endmethod
    // Existing consumers keep the same API and take the owner's current color.
    static method shoot takes unit caster, real px, real py returns Missile
        return shootColor(caster,px,py,GetPlayerColor(GetOwningPlayer(caster)))
    endmethod
endstruct

struct RapidPair
    readonly unit controller
    readonly unit actor
    readonly GroundMotion motion
    readonly boolean firing = false
    readonly integer pending = 0
    readonly real aimX
    readonly real aimY
    readonly real nextShot = 0.
    readonly real lastShot = -1000.
    readonly Missile lastMissile = 0 // diagnostic reference; valid only while allocated
    readonly static integer pairs = 0
    readonly static integer bursts = 0
    readonly static integer remaining = 0
    readonly static integer emitted = 0
    readonly static integer recasts = 0
    readonly static integer attacks = 0
    readonly static real minInterval = 99999.
    readonly static integer moving = 0
    readonly static integer blocked = 0
    private timer reset
    private playercolor tint
    private boolean hasTint
    private integer next
    private integer previous
    private static integer first = 0
    private static Table controls
    private static Table actors
    private static timer clock = CreateTimer()
    private static timer ticker = CreateTimer()
    static constant real INTERVAL = 0.25

    static method now takes nothing returns real
        return TimerGetElapsed(clock)
    endmethod
    static method fromController takes unit u returns thistype
        return controls[GetHandleId(u)]
    endmethod
    static method fromActor takes unit u returns thistype
        return actors[GetHandleId(u)]
    endmethod
    method color takes nothing returns playercolor
        if hasTint then
            return tint
        endif
        return GetPlayerColor(GetOwningPlayer(actor))
    endmethod
    // Classic has no GetUnitColor. Use this setter for individual/team overrides.
    // Red is enum0 (equal to null in Classic), so absence is a separate flag.
    method setColor takes playercolor value returns nothing
        set tint = value
        set hasTint = true
        call SetUnitColor(actor,color())
        call SetUnitColor(controller,color())
    endmethod
    method clearColor takes nothing returns nothing
        set hasTint = false
        set tint = null
        call SetUnitColor(actor,color())
        call SetUnitColor(controller,color())
    endmethod
    private method face takes nothing returns nothing
        local real dx = aimX-GetUnitX(actor)
        local real dy = aimY-GetUnitY(actor)
        if dx*dx+dy*dy > 0.01 then
            call SetUnitFacingTimed(actor,Atan2(dy,dx)*bj_RADTODEG,0.)
        endif
    endmethod
    private method emit takes nothing returns nothing
        local real gap = now()-lastShot
        if lastShot > -1. and gap < minInterval then
            set minInterval = gap
        endif
        set lastShot = now()
        set pending = pending-1
        set remaining = remaining-1
        set emitted = emitted+1
        call face()
        call SetUnitAnimation(actor,"attack")
        set attacks = attacks+1
        set lastMissile = RapidBolt.shootColor(actor,aimX,aimY,color())
    endmethod
    method cast takes real px, real py returns nothing
        if not GroundCollision.alive(actor) then
            return
        endif
        set aimX = px
        set aimY = py
        if firing then
            set remaining = remaining+6-pending
            set pending = 6
            set recasts = recasts+1
            return
        endif
        set firing = true
        set bursts = bursts+1
        set pending = 6
        set remaining = remaining+6
        // Initial instant transition, if needed, precedes the first attack.
        call motion.enter()
        call SetUnitTimeScale(actor,3.)
        set nextShot = now()+INTERVAL
        call emit()
    endmethod
    private method finish takes boolean resume returns nothing
        if firing then
            set firing = false
            set bursts = bursts-1
            set remaining = remaining-pending
            set pending = 0
            if GetUnitTypeId(actor) != 0 then
                call SetUnitTimeScale(actor,1.)
                call ResetUnitAnimation(actor)
            endif
            call motion.leave(resume)
        endif
    endmethod
    private static method park takes nothing returns nothing
        local thistype this = GetTimerData(GetExpiredTimer())
        call SetUnitPosition(controller,WorldBounds.minX+256.,WorldBounds.minY+256.)
    endmethod
    method move takes real px, real py returns nothing
        call motion.destination(px,py)
    endmethod
    static method create takes unit proxy, unit visible returns thistype
        local thistype this = thistype.allocate()
        set controller = proxy
        set actor = visible
        set firing = false
        set pending = 0
        set lastShot = -1000.
        set lastMissile = 0
        set tint = null
        set hasTint = false
        set aimX = GetUnitX(visible)+500.
        set aimY = GetUnitY(visible)
        set reset = NewTimerEx(this)
        set motion = GroundMotion.create(visible)
        set controls[GetHandleId(proxy)] = this
        set actors[GetHandleId(visible)] = this
        set previous = 0
        set next = first
        if first != 0 then
            set thistype(first).previous = this
        endif
        set first = this
        set pairs = pairs+1
        return this
    endmethod
    method destroy takes nothing returns nothing
        call finish(false)
        call motion.destroy()
        call controls.remove(GetHandleId(controller))
        call actors.remove(GetHandleId(actor))
        call ReleaseTimer(reset)
        call RemoveUnit(controller)
        if previous == 0 then
            set first = next
        else
            set thistype(previous).next = next
        endif
        if next != 0 then
            set thistype(next).previous = previous
        endif
        set controller = null
        set actor = null
        set reset = null
        set tint = null
        set hasTint = false
        set pairs = pairs-1
        call deallocate()
    endmethod
    private static method tick takes nothing returns nothing
        local thistype this = first
        local thistype following
        local real time = now()
        set moving = 0
        set blocked = 0
        loop
            exitwhen this == 0
            set following = next
            if not GroundCollision.alive(actor) or not GroundCollision.alive(controller) then
                call destroy()
            else
                call SetWidgetLife(controller,GetWidgetLife(actor))
                if firing then
                    call motion.step(1./32.)
                    call face()
                    if time+0.0001 >= nextShot then
                        if pending > 0 then
                            call emit()
                            set nextShot = nextShot+INTERVAL
                        else
                            call finish(true)
                        endif
                    endif
                    if motion.hasGoal then
                        set moving = moving+1
                    endif
                    if motion.blocked then
                        set blocked = blocked+1
                    endif
                endif
            endif
            set this = following
        endloop
    endmethod
    private static method pointOrder takes nothing returns nothing
        local thistype this = fromController(GetTriggerUnit())
        local integer order = GetIssuedOrderId()
        if this != 0 then
            // A new cast must not be cancelled by a queued proxy move reset.
            call PauseTimer(reset)
            if order == 851986 or order == 851971 then
                call move(GetOrderPointX(),GetOrderPointY())
                call TimerStart(reset,0.,false,function thistype.park)
            endif
        endif
    endmethod
    private static method spell takes nothing returns nothing
        local thistype this = fromController(GetTriggerUnit())
        if this != 0 then
            call cast(GetSpellTargetX(),GetSpellTargetY())
        endif
    endmethod
    private static method selected takes nothing returns nothing
        local thistype this = fromActor(GetTriggerUnit())
        if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
            // Selection only; all gameplay state is outside the local branch.
            call ClearSelection()
            call SelectUnit(controller,true)
        endif
    endmethod
    static method initialize takes nothing returns nothing
        set controls = Table.create()
        set actors = Table.create()
        call TimerStart(clock,1000000.,false,null)
        call TimerStart(ticker,1./32.,true,function thistype.tick)
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER,function thistype.pointOrder)
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED,function thistype.selected)
        call RegisterSpellEffectEvent('Arpf',function thistype.spell)
    endmethod
endstruct
private function Init takes nothing returns nothing
    call RapidPair.initialize()
endfunction
endlibrary

library RapidFireDemo initializer Init requires RapidFire, MissileDiagnostics
struct RapidDemo extends array
    readonly static RapidPair pair = 0
    private static boolean extended = false
    private static unit array targets
    private static method row takes integer r, string name, string value returns nothing
        local multiboarditem cell = MultiboardGetItem(MissileStats.board,r,0)
        call MultiboardSetItemStyle(cell,true,false)
        call MultiboardSetItemWidth(cell,0.17)
        call MultiboardSetItemValue(cell,name)
        call MultiboardReleaseItem(cell)
        set cell = MultiboardGetItem(MissileStats.board,r,1)
        call MultiboardSetItemStyle(cell,true,false)
        call MultiboardSetItemWidth(cell,0.12)
        call MultiboardSetItemValue(cell,value)
        call MultiboardReleaseItem(cell)
        set cell = null
    endmethod
    private static method panel takes nothing returns nothing
        if MissileStats.board != null then
            if not extended then
                call MultiboardSetRowCount(MissileStats.board,25)
                set extended = true
            endif
            call row(19,"Rafagas / pendientes",I2S(RapidPair.bursts)+" / "+I2S(RapidPair.remaining))
            call row(20,"Move art. / bloqueado",I2S(RapidPair.moving)+" / "+I2S(RapidPair.blocked))
            call row(21,"Tiros / recasts",I2S(RapidPair.emitted)+" / "+I2S(RapidPair.recasts))
            if RapidPair.minInterval == 99999. then
                call row(22,"Intervalo min / base","-- / 250 ms")
            else
                call row(22,"Intervalo min / base",I2S(R2I(RapidPair.minInterval*1000.+0.5))+" / 250 ms")
            endif
            call row(23,"Instantaneos / XY",I2S(GroundMotion.instantTransitions)+" / "+I2S(GroundMotion.xySteps))
            call row(24,"Retornos / proyectiles",I2S(GroundMotion.handoffs)+" / "+I2S(RapidBolt.live))
        endif
    endmethod
    static method setup takes nothing returns nothing
        local integer i = 0
        local real x = GetStartLocationX(0)+384.
        local real y = GetStartLocationY(0)-256.
        local real bx = x
        local real by = y
        local unit actor
        local unit controller
        loop
            exitwhen GroundCollision.clear(x,y,24.) or i == 100
            set x = bx+I2R(ModuloInteger(i,10))*96.
            set y = by+I2R(i/10)*96.
            set i = i+1
        endloop
        set actor = CreateUnit(Player(0),'rfex',x,y,0.)
        set controller = CreateUnit(Player(0),'rfct',WorldBounds.minX+256.,WorldBounds.minY+256.,0.)
        call SetUnitVertexColor(controller,255,255,255,0)
        set pair = RapidPair.create(controller,actor)
        set i = 0
        loop
            exitwhen i == 3
            set targets[i] = CreateUnit(Player(12),'rftg',x+450.+I2R(i)*180.,y+96.*I2R(i),180.)
            call PauseUnit(targets[i],true)
            set i = i+1
        endloop
        if GetLocalPlayer() == Player(0) then
            call ClearSelection()
            call SelectUnit(controller,true)
            call SetCameraTargetController(actor,0.,0.,false)
        endif
        call DisplayTimedTextToPlayer(Player(0),0.,0.,18.,"Rapid Fire: Q y apunta. Clic derecho en suelo para mover. Recast repone 6 sin reiniciar intervalo. -misiles muestra/oculta el panel.")
        set actor = null
        set controller = null
    endmethod
    private static method start takes nothing returns nothing
        call setup()
        call DestroyTimer(GetExpiredTimer())
    endmethod
    static method initialize takes nothing returns nothing
        call TimerStart(CreateTimer(),0.25,false,function thistype.start)
        call TimerStart(CreateTimer(),0.25,true,function thistype.panel)
    endmethod
endstruct
private function Init takes nothing returns nothing
    call RapidDemo.initialize()
endfunction
endlibrary

// Local mathematical port of observed X3 USA / Zero Project 4.1 motion.
// Oracle: labs/x3-snes; no ROM code or ROM assets are imported into this map.
library X3Kinematics
struct X3Kinematics extends array
    static constant integer ORIGINAL = 1
    static constant integer ZERO_PROJECT = 2
    static constant real FPS = 60.0988062658451
    static constant real SCALE = 2.
    private static real array wave

    static method formation takes integer profile returns real
        if profile == ZERO_PROJECT then
            return 8./FPS
        endif
        return 18./FPS
    endmethod
    static method pulseDelay takes integer profile returns real
        // Demonstration timing: observed birth of the second body relative to
        // the first carrier, not simulation of charging a controller button.
        if profile == ZERO_PROJECT then
            return 13./FPS
        endif
        return 17./FPS
    endmethod
    static method helixPixel takes integer n returns real
        local real k
        if n <= 15 then
            return 0.5*n+(1./32.)*n*(n+1)*0.5
        elseif n <= 32 then
            set k = I2R(n-15)
            return 11.25+0.96875*k+0.25*k*(k+1.)*0.5
        endif
        return 65.96875+5.25*I2R(n-32)
    endmethod
    private static method xPixel takes integer profile, integer form, integer n returns real
        local real initial = -6.
        local real accel = 96./256.
        local integer cap
        local real k
        if form == 4 then
            if profile == ZERO_PROJECT then
                // ROM stores 10, but clamps to 8 BEFORE its first displacement.
                return 8.*n
            endif
            set initial = 0.
            set accel = 24./256.
        elseif form == 5 or form == 8 then
            if profile == ZERO_PROJECT then
                set initial = 1.
                set accel = 48./256.
            else
                set initial = -8.
                set accel = 127./256.
            endif
        elseif profile == ZERO_PROJECT then
            set initial = -3.
        endif
        set cap = R2I((8.-initial)/accel)
        if I2R(cap)*accel < 8.-initial then
            set cap = cap+1
        endif
        if n <= cap then
            set k = I2R(n)
            return initial*k+accel*k*(k+1.)*0.5
        endif
        set k = I2R(cap)
        // The native limit precedes acceleration: the stable step is 8+a.
        return initial*k+accel*k*(k+1.)*0.5+(8.+accel)*I2R(n-cap)
    endmethod
    private static method yPixel takes integer profile, integer form, integer n returns real
        local real vy = 0.75
        local real ay = 0.
        local real k = I2R(n)
        if form == 4 then
            return 0.
        elseif form == 5 or form == 8 then
            set vy = 1.5
            if profile == ZERO_PROJECT then
                set vy = 5.
                set ay = 96./256.
            endif
        elseif profile == ZERO_PROJECT then
            set vy = 7.
            set ay = 112./256.
        endif
        if form == 7 or form == 8 then
            set vy = -vy
            set ay = -ay
        endif
        return -vy*k+ay*k*(k+1.)*0.5
    endmethod
    static method forward takes integer profile, integer form, real age returns real
        local real frame = RMaxBJ(0.,age*FPS)
        local integer n = R2I(frame)
        local real f = frame-I2R(n)
        local real a
        if form == 1 or form == 2 or form == 9 then
            set a = helixPixel(n)
            return SCALE*(a+(helixPixel(n+1)-a)*f)
        elseif form == 0 or form == 3 then
            // Four native steps of growth; step 5 first displaces by 8 pixels.
            return SCALE*8.*RMaxBJ(0.,frame-4.)
        endif
        set a = xPixel(profile,form,n)
        return SCALE*(a+(xPixel(profile,form,n+1)-a)*f)
    endmethod
    static method orbitForward takes integer form, real age returns real
        local real frame = RMaxBJ(0.,age*FPS)
        local integer n = R2I(frame)
        local real f = frame-I2R(n)
        local real offset = 4.
        local real a = I2R(R2I(0.5+helixPixel(n)))-0.5
        local real b = I2R(R2I(0.5+helixPixel(n+1)))-0.5
        if form == 2 then
            set offset = 8.
        elseif form == 9 then
            set offset = 0.
        endif
        return SCALE*(a+(b-a)*f+offset)
    endmethod
    private static method orbitY takes integer form, integer n returns real
        local integer phase = 0
        local integer i = 1
        local real y = -6.
        set n = ModuloInteger(n,16)
        if form == 2 then
            set phase = 4
            set y = 0.
        elseif form == 9 then
            set phase = 8
            set y = 7.
        endif
        loop
            exitwhen i > n
            set y = y-wave[ModuloInteger(phase+i,16)]
            set i = i+1
        endloop
        return y
    endmethod
    static method side takes integer profile, integer form, real age returns real
        local real frame = RMaxBJ(0.,age*FPS)
        local integer n = R2I(frame)
        local real f = frame-I2R(n)
        local real a
        if form == 1 or form == 2 or form == 9 then
            set a = orbitY(form,n)
            return -SCALE*(a+(orbitY(form,n+1)-a)*f)
        endif
        set a = yPixel(profile,form,n)
        // SNES screen-down is the opposite of Warcraft's left-perpendicular.
        return -SCALE*(a+(yPixel(profile,form,n+1)-a)*f)
    endmethod
    private static method onInit takes nothing returns nothing
        set wave[0] = -1.
        set wave[1] = -2.
        set wave[2] = -6.
        set wave[3] = -3.
        set wave[4] = -3.
        set wave[5] = -6.
        set wave[6] = -2.
        set wave[7] = -1.
        set wave[8] = 1.
        set wave[9] = 2.
        set wave[10] = 6.
        set wave[11] = 3.
        set wave[12] = 3.
        set wave[13] = 6.
        set wave[14] = 2.
        set wave[15] = 1.
    endmethod
endstruct
endlibrary

// Local Warcraft adaptation of the user-supplied X3 interaction, not SNES code.
library X3Buster requires Missile, GroundCollision, TimerUtils, X3Kinematics
private keyword X3Body

private struct X3Flash
    private unit dummy
    private effect art
    readonly static integer live = 0
    private static method finish takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local thistype this = GetTimerData(t)
        call DestroyEffect(art)
        call RecycleMissile(dummy)
        set art = null
        set dummy = null
        set live = live-1
        call ReleaseTimer(t)
        call deallocate()
        set t = null
    endmethod
    static method playFor takes real x, real y, real z, real duration returns nothing
        local thistype this = allocate()
        local timer t = NewTimerEx(this)
        set dummy = GetRecycledMissile(x,y,z,0.)
        set art = AddSpecialEffectTarget("X3Buster\\X3_Flash_Union.mdx",dummy,"origin")
        set live = live+1
        call TimerStart(t,duration,false,function thistype.finish)
        set t = null
    endmethod
    static method play takes real x, real y, real z returns nothing
        call playFor(x,y,z,0.18)
    endmethod
endstruct

struct X3Buster
    // GIF approximation, units/second. These are NOT extracted SNES constants.
    static constant real STEP = 1./32.
    static constant real ORBIT_SPEED = 260.
    static constant real PULSE_INITIAL = 650.
    static constant real PULSE_ACCEL = 1800.
    static constant real PULSE_SPEED = 1500.
    static constant real FUSED_INITIAL = 70.
    static constant real FUSED_ACCEL = 900.
    static constant real FUSED_SPEED = 1200.
    static constant real FORMATION_TIME = 0.09375
    static constant real GREEN_INITIAL = -626.
    static constant real GREEN_ACCEL = 4363.
    static constant real GREEN_SPEED = 1140.
    static constant real ORANGE_INITIAL = -400.
    static constant real ORANGE_ACCEL = 2666.666667
    static constant real ORANGE_SPEED = 1080.
    static constant real PULSE_DELAY = 0.375
    static constant real ORBIT_RADIUS = 32.
    static constant real ORBIT_HZ = 2.5
    static constant real RANGE = 1400.
    static constant real LIFETIME = 4.
    static constant integer LIMIT = 64
    static constant integer GIF = 0
    static constant integer ORIGINAL = 1
    static constant integer ZERO_PROJECT = 2
    readonly integer profile
    readonly boolean forming
    private timer formationTimer
    private real unionX
    private real unionY
    private real unionRemaining
    readonly unit caster
    readonly player owner
    readonly real originX
    readonly real originY
    readonly real angle
    readonly real born
    readonly integer state // 0 charged; 1 orbit/pulse; 2 fused; 3 cancelled; 4 forming
    readonly Missile green
    readonly Missile blue
    readonly Missile orange
    readonly Missile pulse
    readonly Missile fused
    readonly Missile sat1
    readonly Missile sat2
    readonly Missile sat3
    readonly Missile sat4
    readonly integer bodies
    readonly boolean waiting
    private boolean automatic
    private integer next
    private integer previous
    private static integer first = 0
    private static timer clock = CreateTimer()
    private static timer ticker = CreateTimer()
    readonly static integer live = 0
    readonly static integer projectiles = 0
    readonly static integer created = 0
    readonly static integer retired = 0
    readonly static integer fusions = 0
    readonly static integer hits = 0
    readonly static integer walls = 0
    readonly static integer pulses = 0
    readonly static integer satellites = 0
    readonly static real lastFusionX = 0.
    readonly static real lastFusionY = 0.
    readonly static real lastFusionAge = 0.

    static method now takes nothing returns real
        return TimerGetElapsed(clock)
    endmethod
    // Analytic integral: negative starting velocity, acceleration, then a cap.
    // Sampling its differences gives the same path without Euler drift.
    static method ramp takes real initial, real accel, real maximum, real age returns real
        local real cap = (maximum-initial)/accel
        if age <= 0. then
            return 0.
        elseif age <= cap then
            return initial*age+0.5*accel*age*age
        endif
        return initial*cap+0.5*accel*cap*cap+maximum*(age-cap)
    endmethod
    static method travel takes integer form, real age returns real
        if form == 1 or form == 2 then
            return ORBIT_SPEED*age
        elseif form == 0 or form == 3 then
            return ramp(PULSE_INITIAL,PULSE_ACCEL,PULSE_SPEED,age)
        endif
        set age = RMaxBJ(0.,age-FORMATION_TIME)
        if form == 4 then
            return ramp(FUSED_INITIAL,FUSED_ACCEL,FUSED_SPEED,age)
        elseif form == 5 or form == 8 then
            return ramp(GREEN_INITIAL,GREEN_ACCEL,GREEN_SPEED,age)
        endif
        return ramp(ORANGE_INITIAL,ORANGE_ACCEL,ORANGE_SPEED,age)
    endmethod
    static method lateral takes integer form, real age returns real
        local real offset
        set age = RMaxBJ(0.,age-FORMATION_TIME)
        if form == 5 or form == 8 then
            set offset = 20.+200.*age
        else
            set offset = 12.+100.*age
        endif
        if form == 5 or form == 6 then
            return -offset
        endif
        return offset
    endmethod
    method trajectory takes integer form, real t returns real
        if profile != GIF then
            return X3Kinematics.forward(profile,form,t)
        endif
        return travel(form,t)
    endmethod
    static method ageOf takes Missile m returns real
        return X3Body.ageOf(m)
    endmethod
    static method flashCount takes nothing returns integer
        return X3Flash.live
    endmethod
    method available takes Missile m returns boolean
        return m != 0 and m.allocated and not m.wantDestroy and m.data == this
    endmethod
    method track takes Missile m returns nothing
        set bodies = bodies+1
        set projectiles = projectiles+1
        set created = created+1
    endmethod
    method untrack takes Missile m returns nothing
        if green == m then
            set green = 0
        elseif orange == m then
            set orange = 0
        elseif blue == m then
            set blue = 0
        elseif pulse == m then
            set pulse = 0
        elseif fused == m then
            set fused = 0
        elseif sat1 == m then
            set sat1 = 0
        elseif sat2 == m then
            set sat2 = 0
        elseif sat3 == m then
            set sat3 = 0
        elseif sat4 == m then
            set sat4 = 0
        endif
        set bodies = bodies-1
        set projectiles = projectiles-1
        set retired = retired+1
    endmethod
    // Marks only this cast's bodies. onRemove remains their sole cleanup owner.
    method cancel takes nothing returns nothing
        set waiting = false
        if forming then
            set forming = false
            call ReleaseTimer(formationTimer)
            set formationTimer = null
        endif
        set state = 3
        if available(green) then
            call green.destroy()
        endif
        if available(orange) then
            call orange.destroy()
        endif
        if available(blue) then
            call blue.destroy()
        endif
        if available(pulse) then
            call pulse.destroy()
        endif
        if available(fused) then
            call fused.destroy()
        endif
        if available(sat1) then
            call sat1.destroy()
        endif
        if available(sat2) then
            call sat2.destroy()
        endif
        if available(sat3) then
            call sat3.destroy()
        endif
        if available(sat4) then
            call sat4.destroy()
        endif
    endmethod
    // Can also be called by a future manual second-release/charge controller.
    method releasePulse takes nothing returns boolean
        if not waiting or state != 1 then
            return false
        endif
        set waiting = false
        if not GroundCollision.alive(caster) then
            return false
        endif
        set pulse = X3Body.spawn(this,3,originX,originY,angle,RANGE)
        set pulses = pulses+1
        return true
    endmethod
    private method emitFusion takes nothing returns nothing
        local real shift = 0.
        set state = 2
        if profile == GIF then
            set shift = 24.
        endif
        set fused = X3Body.spawn(this,4,unionX,unionY,angle,unionRemaining)
        set sat1 = X3Body.spawn(this,5,unionX-shift*Cos(angle),unionY-shift*Sin(angle),angle,600.)
        set sat2 = X3Body.spawn(this,6,unionX-shift*Cos(angle),unionY-shift*Sin(angle),angle,600.)
        set sat3 = X3Body.spawn(this,7,unionX-shift*Cos(angle),unionY-shift*Sin(angle),angle,600.)
        set sat4 = X3Body.spawn(this,8,unionX-shift*Cos(angle),unionY-shift*Sin(angle),angle,600.)
        set satellites = satellites+4
    endmethod
    private static method finishFormation takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local thistype this = GetTimerData(t)
        set formationTimer = null
        set forming = false
        call ReleaseTimer(t)
        if state == 4 and GroundCollision.alive(caster) then
            call emitFusion()
        else
            call cancel()
        endif
        set t = null
    endmethod
    private method merge takes real x, real y returns nothing
        set unionRemaining = RMaxBJ(1.,RANGE-SquareRoot((x-originX)*(x-originX)+(y-originY)*(y-originY)))
        set unionX = x
        set unionY = y
        set state = 2
        set waiting = false
        call green.destroy()
        call orange.destroy()
        if available(blue) then
            call blue.destroy()
        endif
        call pulse.destroy()
        set fusions = fusions+1
        set lastFusionX = x
        set lastFusionY = y
        set lastFusionAge = now()-born
        if profile == GIF then
            call X3Flash.play(x,y,70.)
            call emitFusion()
        else
            // Snap to the second pulse; the five bodies do not exist during
            // formation. This timer is cancelled before this cast can be freed.
            set state = 4
            set forming = true
            set formationTimer = NewTimerEx(this)
            call X3Flash.playFor(x,y,70.,X3Kinematics.formation(profile))
            call TimerStart(formationTimer,X3Kinematics.formation(profile),false,function thistype.finishFormation)
        endif
    endmethod
    method tryFusion takes Missile m returns boolean
        local real oldGap
        local real gap
        local real fraction
        local real low = 0.
        local real high = 1.
        local integer i = 0
        local real reach = 0.
        if state != 1 or not available(green) or not available(orange) or not available(pulse) then
            return false
        endif
        if profile != GIF and not available(blue) then
            return false
        endif
        set oldGap = (green.prevX-m.prevX)*Cos(angle)+(green.prevY-m.prevY)*Sin(angle)
        set gap = (green.x-m.x)*Cos(angle)+(green.y-m.y)*Sin(angle)
        if profile == GIF and (oldGap <= 0. or gap > 0.) then
            return false
        endif
        // Both bodies moved before callbacks. Use their analytic within-step
        // trajectories: linear interpolation would shift an accelerating catch.
        call X3Body.prepare(green)
        call X3Body.prepare(orange)
        call X3Body.prepare(m)
        if profile != GIF then
            // A Warcraft fusion envelope calibrated from the observed native
            // encounter. It does not replace GroundCollision's world filters.
            set reach = 30.*X3Kinematics.SCALE
            set low = RMaxBJ(0.,(4./X3Kinematics.FPS-X3Body.ageOf(m)+STEP)/STEP)
            if low > 1. then
                return false
            endif
            if available(blue) then
                call X3Body.prepare(blue)
            endif
            set gap = (X3Body.centerX(green,1.)-X3Body.centerX(m,1.))*Cos(angle)+(X3Body.centerY(green,1.)-X3Body.centerY(m,1.))*Sin(angle)
            if gap > reach then
                return false
            endif
        endif
        loop
            exitwhen i == 16
            set fraction = (low+high)*0.5
            set gap = (X3Body.centerX(green,fraction)-X3Body.centerX(m,fraction))*Cos(angle)+(X3Body.centerY(green,fraction)-X3Body.centerY(m,fraction))*Sin(angle)
            if gap > reach then
                set low = fraction
            else
                set high = fraction
            endif
            set i = i+1
        endloop
        set fraction = high
        // Resolve only the part BEFORE the union. A later hit in this tick
        // belongs to the resulting shot and cannot cancel an earlier union.
        if X3Body.resolveAt(green,fraction) then
            call green.destroy()
        endif
        if X3Body.resolveAt(orange,fraction) then
            call orange.destroy()
        endif
        if profile != GIF and available(blue) and X3Body.resolveAt(blue,fraction) then
            call blue.destroy()
        endif
        if X3Body.resolveAt(m,fraction) then
            call m.destroy()
        endif
        if state != 1 or not available(green) or not available(orange) or not available(pulse) then
            return false
        endif
        if profile != GIF and not available(blue) then
            return false
        endif
        call merge(X3Body.centerX(m,fraction),X3Body.centerY(m,fraction))
        return true
    endmethod
    method countHit takes integer reason returns nothing
        if reason == 2 then
            set hits = hits+1
        elseif reason == 1 then
            set walls = walls+1
        endif
    endmethod
    private static method tick takes nothing returns nothing
        local thistype this = first
        local thistype following
        loop
            exitwhen this == 0
            set following = next
            if now()-born >= LIFETIME or GetUnitTypeId(caster) == 0 then
                call cancel()
            endif
            if waiting and automatic then
                if (profile == GIF and now()-born+0.0001 >= PULSE_DELAY) or (profile != GIF and now()-born+0.0001 >= X3Kinematics.pulseDelay(profile)) then
                    call releasePulse()
                endif
            endif
            if bodies == 0 and not waiting and not forming then
                if previous == 0 then
                    set first = next
                else
                    set thistype(previous).next = next
                endif
                if next != 0 then
                    set thistype(next).previous = previous
                endif
                set caster = null
                set owner = null
                set live = live-1
                call deallocate()
            endif
            set this = following
        endloop
        if first == 0 then
            call PauseTimer(ticker)
        endif
    endmethod
    // mode0: charged pulse; mode1: automatic cross shot; mode2: manual release API.
    static method fireProfile takes unit source, real tx, real ty, integer mode, integer selectedProfile returns thistype
        local thistype this
        local real x = GetUnitX(source)
        local real y = GetUnitY(source)
        local real dx = tx-x
        local real dy = ty-y
        if not GroundCollision.alive(source) or live >= LIMIT or mode < 0 or mode > 2 or selectedProfile < GIF or selectedProfile > ZERO_PROJECT then
            return 0
        endif
        set this = allocate()
        if dx*dx+dy*dy < 64. then
            set angle = GetUnitFacing(source)*bj_DEGTORAD
        else
            set angle = Atan2(dy,dx)
        endif
        // Reject a blocked muzzle before creating any body or crossing bounds.
        if GroundCollision.trace(x,y,x+24.*Cos(angle),y+24.*Sin(angle),29.,source,GetOwningPlayer(source),false) != 0 then
            call deallocate()
            return 0
        endif
        set originX = x+24.*Cos(angle)
        set originY = y+24.*Sin(angle)
        set caster = source
        set owner = GetOwningPlayer(source)
        set born = now()
        set profile = selectedProfile
        set forming = false
        set formationTimer = null
        set state = 0
        set bodies = 0
        set green = 0
        set orange = 0
        set blue = 0
        set pulse = 0
        set fused = 0
        set sat1 = 0
        set sat2 = 0
        set sat3 = 0
        set sat4 = 0
        set waiting = mode != 0
        set automatic = mode == 1
        set previous = 0
        set next = first
        if first != 0 then
            set thistype(first).previous = this
        else
            call TimerStart(ticker,1./32.,true,function thistype.tick)
        endif
        set first = this
        set live = live+1
        if mode == 0 then
            set pulse = X3Body.spawn(this,0,originX,originY,angle,RANGE)
        else
            set state = 1
            set green = X3Body.spawn(this,1,originX,originY,angle,RANGE)
            set orange = X3Body.spawn(this,2,originX,originY,angle,RANGE)
            if profile != GIF then
                set blue = X3Body.spawn(this,9,originX,originY,angle,RANGE)
            endif
        endif
        return this
    endmethod
    static method fire takes unit source, real tx, real ty, integer mode returns thistype
        return fireProfile(source,tx,ty,mode,GIF)
    endmethod
    private static method onInit takes nothing returns nothing
        call TimerStart(clock,1000000.,false,null)
    endmethod
endstruct

private struct X3Body extends array
    private static integer array kind
    private static real array lastX
    private static real array lastY
    private static real array processed
    private static boolean array blocked
    private static real array age
    private static boolean array prepared
    private static real array startX
    private static real array startY
    private static real array length

    // Called once per shared physical tick, including partial fusion sweeps.
    static method prepare takes Missile m returns nothing
        // A long-duration timer reading is not a unique physical tick ID.
        // The body's own callback consumes this flag after all partial sweeps.
        if not prepared[m] then
            set prepared[m] = true
            set age[m] = age[m]+X3Buster.STEP
        endif
    endmethod
    static method ageOf takes Missile m returns real
        return age[m]
    endmethod
    static method centerX takes Missile m, real fraction returns real
        local X3Buster s = m.data
        return startX[m]+RMinBJ(length[m],s.trajectory(kind[m],age[m]-X3Buster.STEP+X3Buster.STEP*fraction))*Cos(s.angle)
    endmethod
    static method centerY takes Missile m, real fraction returns real
        local X3Buster s = m.data
        return startY[m]+RMinBJ(length[m],s.trajectory(kind[m],age[m]-X3Buster.STEP+X3Buster.STEP*fraction))*Sin(s.angle)
    endmethod

    private static method sample takes Missile m, real sampleAge returns boolean
        local X3Buster s = m.data
        local real distance = RMinBJ(length[m],s.trajectory(kind[m],sampleAge))
        local real x = startX[m]+distance*Cos(s.angle)
        local real y = startY[m]+distance*Sin(s.angle)
        local real fraction = (sampleAge-age[m]+X3Buster.STEP)/X3Buster.STEP
        local real z = m.prevZ+(m.z-m.prevZ)*fraction
        local real phase
        local real side
        local real radius = 29.
        local real damage = 75.
        local integer result
        local unit target
        if s.profile != X3Buster.GIF and (kind[m] == 1 or kind[m] == 2 or kind[m] == 9) then
            set distance = RMinBJ(length[m],X3Kinematics.orbitForward(kind[m],sampleAge))
            set side = X3Kinematics.side(s.profile,kind[m],sampleAge)
            set x = startX[m]+distance*Cos(s.angle)-Sin(s.angle)*side
            set y = startY[m]+distance*Sin(s.angle)+Cos(s.angle)*side
            set radius = 12.65
            set damage = 35.
        elseif kind[m] == 1 or kind[m] == 2 then
            set phase = 2.*bj_PI*X3Buster.ORBIT_HZ*sampleAge
            if kind[m] == 2 then
                set phase = phase+bj_PI
            endif
            set side = X3Buster.ORBIT_RADIUS*Cos(phase)
            set x = x-Sin(s.angle)*side
            set y = y+Cos(s.angle)*side
            set z = z+X3Buster.ORBIT_RADIUS*Sin(phase)
            set radius = 12.65
            set damage = 35.
        elseif kind[m] == 4 then
            set radius = 41.25
            set damage = 150.
        elseif kind[m] >= 5 then
            if s.profile == X3Buster.GIF then
                set side = X3Buster.lateral(kind[m],sampleAge)
            else
                set side = X3Kinematics.side(s.profile,kind[m],sampleAge)
            endif
            set x = x-Sin(s.angle)*side
            set y = y+Cos(s.angle)*side
            set radius = 12.65
            set damage = 25.
        endif
        set result = GroundCollision.trace(lastX[m],lastY[m],x,y,radius,s.caster,s.owner,true)
        set target = GroundCollision.hit
        // Render the swept position, including backwards/lateral motion. The
        // central Missile coordinate remains the signed longitudinal carrier.
        call SetUnitX(m.dummy,GroundCollision.x)
        call SetUnitY(m.dummy,GroundCollision.y)
        call SetUnitFlyHeight(m.dummy,RMaxBJ(0.,z),0.)
        set lastX[m] = x
        set lastY[m] = y
        if result == 0 and z < 0. then
            set result = 1
        endif
        if result != 0 then
            set blocked[m] = true
            // Collision result/target are captured before damage can reenter.
            call s.countHit(result)
            if result == 2 and GetUnitTypeId(s.caster) != 0 then
                call UnitDamageTarget(s.caster,target,damage,false,false,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_MAGIC,null)
            endif
        endif
        set target = null
        return result != 0
    endmethod
    static method resolveAt takes Missile m, real fraction returns boolean
        local real untilAge
        local real nextAge
        local X3Buster s = m.data
        call prepare(m)
        set untilAge = age[m]-X3Buster.STEP+X3Buster.STEP*fraction
        if m.wantDestroy or blocked[m] then
            return true
        endif
        // Four curved-path substeps at most per full tick. They also detect a
        // backwards/forwards turn whose two endpoints might otherwise coincide.
        loop
            exitwhen processed[m]+0.0000001 >= untilAge
            set nextAge = RMinBJ(untilAge,processed[m]+X3Buster.STEP*0.25)
            if s.profile != X3Buster.GIF then
                set nextAge = RMinBJ(nextAge,I2R(R2I(processed[m]*X3Kinematics.FPS+0.00001)+1)/X3Kinematics.FPS)
            endif
            if sample(m,nextAge) then
                return true
            endif
            set processed[m] = nextAge
        endloop
        return false
    endmethod
    static method resolve takes Missile m returns boolean
        return resolveAt(m,1.)
    endmethod
    static method onPeriod takes Missile m returns boolean
        local X3Buster s = m.data
        call prepare(m)
        if kind[m] == 3 and s.tryFusion(m) then
            return true
        endif
        if resolve(m) then
            return true
        endif
        // Missile.speed is displacement per tick, not units/second.
        // Let Missile detect arrival using its own origin.distance. An external
        // rounded range can leave a zero-speed carrier just short of that end.
        // sample() clamps the rendered/swept position, including the last tick.
        set m.speed = s.trajectory(kind[m],age[m]+X3Buster.STEP)-s.trajectory(kind[m],age[m])
        set prepared[m] = false
        return false
    endmethod
    static method onFinish takes Missile m returns boolean
        call resolve(m)
        return true
    endmethod
    static method onRemove takes Missile m returns boolean
        local X3Buster s = m.data
        call s.untrack(m)
        set m.data = 0
        set blocked[m] = false
        return false
    endmethod
    implement MissileStruct

    static method spawn takes X3Buster s, integer form, real x, real y, real facing, real range returns Missile
        local Missile m = Missile.createXYZ(x,y,70.,x+range*Cos(facing),y+range*Sin(facing),70.)
        set m.data = s
        set m.owner = s.owner
        set m.collision = 0.
        set kind[m] = form
        set processed[m] = 0.
        set age[m] = 0.
        set prepared[m] = false
        set startX[m] = x
        set startY[m] = y
        set length[m] = m.origin.distance
        set blocked[m] = false
        set lastX[m] = x
        set lastY[m] = y
        if form == 1 or form == 2 or form >= 5 then
            if form == 1 or form == 5 or form == 8 or form == 9 then
                set m.model = "X3Buster\\X3_Orbe_Verde.mdx"
            else
                set m.model = "X3Buster\\X3_Orbe_Naranja.mdx"
            endif
            set m.scale = 0.55
        elseif form == 4 then
            set m.model = "X3Buster\\X3_Cross_Buster.mdx"
            set m.scale = 1.
        else
            set m.model = "X3Buster\\X3_Buster_Cargado.mdx"
            set m.scale = 1.
        endif
        set m.speed = s.trajectory(form,X3Buster.STEP)
        // Start each visual at its real lateral position; do not pop out of
        // the carrier center on its first callback. Check terrain before moving.
        if s.profile != X3Buster.GIF then
            set processed[m] = 0.
            if form == 1 or form == 2 or form == 9 then
                set processed[m] = X3Kinematics.side(s.profile,form,0.)
                set lastX[m] = x+X3Kinematics.orbitForward(form,0.)*Cos(facing)-Sin(facing)*processed[m]
                set lastY[m] = y+X3Kinematics.orbitForward(form,0.)*Sin(facing)+Cos(facing)*processed[m]
            endif
            if GroundCollision.trace(x,y,lastX[m],lastY[m],12.65,s.caster,s.owner,false) != 0 then
                set blocked[m] = true
                call s.countHit(1)
                call m.destroy()
            endif
            call SetUnitX(m.dummy,GroundCollision.x)
            call SetUnitY(m.dummy,GroundCollision.y)
        elseif form == 1 or form == 2 then
            if form == 1 then
                set processed[m] = X3Buster.ORBIT_RADIUS
            else
                set processed[m] = -X3Buster.ORBIT_RADIUS
            endif
        elseif form >= 5 then
            set processed[m] = X3Buster.lateral(form,0.)
        endif
        if s.profile == X3Buster.GIF and (form == 1 or form == 2 or form >= 5) then
            set lastX[m] = x-Sin(facing)*processed[m]
            set lastY[m] = y+Cos(facing)*processed[m]
            if GroundCollision.trace(x,y,lastX[m],lastY[m],12.65,s.caster,s.owner,false) != 0 then
                set blocked[m] = true
                call s.countHit(1)
                call m.destroy()
            endif
            call SetUnitX(m.dummy,GroundCollision.x)
            call SetUnitY(m.dummy,GroundCollision.y)
        endif
        set processed[m] = 0.
        call s.track(m)
        call launch(m)
        return m
    endmethod
endstruct
endlibrary

library X3BusterDemo initializer Init requires X3Buster, RapidFireDemo, SpellEffectEvent
// Compatibility fixtures may opt into GIF; delivered W/E use the USA profile.
struct X3Demo extends array
    static integer profile = X3Buster.ORIGINAL
endstruct
private function Cast takes nothing returns nothing
    local RapidPair pair = RapidPair.fromController(GetTriggerUnit())
    local X3Buster shot
    local integer mode = 0
    local integer profile = X3Demo.profile
    if pair != 0 then
        if GetSpellAbilityId() == 'Ax3s' or GetSpellAbilityId() == 'Ax3z' then
            set mode = 1
        endif
        if GetSpellAbilityId() == 'Ax3z' then
            set profile = X3Buster.ZERO_PROJECT
        endif
        set shot = X3Buster.fireProfile(pair.actor,GetSpellTargetX(),GetSpellTargetY(),mode,profile)
        if not pair.firing then
            call SetUnitFacingTimed(pair.actor,Atan2(GetSpellTargetY()-GetUnitY(pair.actor),GetSpellTargetX()-GetUnitX(pair.actor))*bj_RADTODEG,0.)
            call SetUnitAnimation(pair.actor,"attack")
        endif
    endif
endfunction
private function Init takes nothing returns nothing
    call RegisterSpellEffectEvent('Ax3c',function Cast)
    call RegisterSpellEffectEvent('Ax3s',function Cast)
    call RegisterSpellEffectEvent('Ax3z',function Cast)
endfunction
endlibrary

// Laboratory only: never imported into the delivered editable sources.
library ShotColorProbe initializer Init requires RapidFireDemo
globals
    private unit array displayUnit
    private effect array displayEffect
    private texttag array label
    private lightning array ring
    private integer displays = 0
    private integer rings = 0
    private integer checks = 0
    private integer failures = 0
    private string array lines
    private integer stage = 0
    private timer ticker = CreateTimer()
    private real since
    private RapidPair p
    private Missile prior
    private real nextTime
    private integer countBefore
    private string array expected
    private real originalX
    private real originalY
endglobals
private function Check takes boolean value, string message returns nothing
    if value then
        set lines[checks] = "PASS "+message
    else
        set lines[checks] = "FAIL "+message
        set failures = failures+1
    endif
    set checks = checks+1
endfunction
private function Clear takes nothing returns nothing
    loop
        exitwhen displays == 0
        set displays = displays-1
        call DestroyEffect(displayEffect[displays])
        call RemoveUnit(displayUnit[displays])
        call DestroyTextTag(label[displays])
        set displayEffect[displays] = null
        set displayUnit[displays] = null
        set label[displays] = null
    endloop
    loop
        exitwhen rings == 0
        set rings = rings-1
        call DestroyLightning(ring[rings])
        set ring[rings] = null
    endloop
endfunction
private function Display takes real x, real y, playercolor color, real scale, string text, boolean marker returns nothing
    local integer i = 0
    local real a
    local real b
    local real z = GroundCollision.height(x,y)+70.
    set displayUnit[displays] = CreateUnit(Player(0),'dumi',x,y,0.)
    call SetUnitX(displayUnit[displays],x)
    call SetUnitY(displayUnit[displays],y)
    call SetUnitFlyHeight(displayUnit[displays],70.,0.)
    call SetUnitScale(displayUnit[displays],scale,scale,scale)
    set displayEffect[displays] = AddSpecialEffectTarget(RapidBolt.modelForColor(color),displayUnit[displays],"origin")
    set label[displays] = CreateTextTag()
    call SetTextTagText(label[displays],text,0.022)
    call SetTextTagPos(label[displays],x-55.,y+48.,75.)
    set displays = displays+1
    if marker then
        loop
            exitwhen i == 24
            set a = I2R(i)*bj_PI/12.
            set b = I2R(i+1)*bj_PI/12.
            set ring[rings] = AddLightningEx("DRAL",false,x+16.*Cos(a),y+16.*Sin(a),z,x+16.*Cos(b),y+16.*Sin(b),z)
            call SetLightningColor(ring[rings],1.,1.,1.,0.8)
            set rings = rings+1
            set i = i+1
        endloop
    endif
endfunction
private function Camera takes nothing returns nothing
    call SetCameraTargetController(null,0.,0.,false)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,1650.,0.)
    call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK,295.,0.)
    call PanCameraToTimed(-4310.,3040.,0.)
    call FogEnable(false)
    call FogMaskEnable(false)
    call SetTimeOfDay(12.)
    call SuspendTimeOfDay(true)
    call MultiboardDisplay(MissileStats.board,false)
    call ClearTextMessages()
endfunction
private function Calibrate takes nothing returns nothing
    call Clear()
    call Camera()
    call Display(-4400.,3260.,PLAYER_COLOR_CYAN,1.,"1.00 x",true)
    call Display(-4400.,3040.,PLAYER_COLOR_CYAN,1.5,"1.50 x",true)
    call Display(-4400.,2820.,PLAYER_COLOR_CYAN,2.7434842,"2.74 x",true)
    call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"CALIBRACION: circulo radio16 en el origen/punta; estela hacia atras. Grosor del cuerpo, halo y Death son distintos.")
endfunction
private function Palette takes nothing returns nothing
    local integer i = 0
    call Clear()
    call Camera()
    loop
        exitwhen i == 12
        call Display(-4670.+I2R(ModuloInteger(i,3))*340.,3340.-I2R(i/3)*190.,ConvertPlayerColor(i),RapidBolt.VISUAL_SCALE,I2S(i),false)
        set i = i+1
    endloop
    call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"PALETA CLASSIC: 0 rojo,1 azul,2 cian,3 purpura,4 amarillo,5 naranja,6 verde,7 rosa,8 gris,9 azul claro,10 aqua,11 marron.")
endfunction
private function Save takes nothing returns nothing
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("COLOR 20261023-145002 COMPLETE")
    loop
        exitwhen i == checks
        call Preload(lines[i])
        set i = i+1
    endloop
    call Preload("checks="+I2S(checks)+" failures="+I2S(failures)+" live="+I2S(RapidBolt.live)+" created="+I2S(MissileStats.created)+" retired="+I2S(MissileStats.retired)+" scale="+R2S(RapidBolt.VISUAL_SCALE))
    call PreloadGenEnd("Logs\\TerrainDev-20261023-145002-colors.txt")
endfunction
private function Tick takes nothing returns nothing
    local real elapsed = RapidPair.now()-since
    if stage == 1 and elapsed >= 0.25 then
        call Check(RapidBolt.live==0,"all twelve direct shots retired")
        call SetPlayerColor(Player(0),PLAYER_COLOR_ORANGE)
        set prior = RapidBolt.shoot(p.actor,-3800.,3024.)
        call Check(prior.model==expected[5],"owner color differs from player slot")
        call prior.destroy()
        call p.setColor(PLAYER_COLOR_RED)
        call p.cast(-3800.,3024.)
        set prior = p.lastMissile
        call Check(prior.model==expected[0],"explicit red override wins over orange owner")
        set since = RapidPair.now()
        set stage = 2
    elseif stage == 2 and elapsed >= 0.125 then
        set nextTime = p.nextShot
        set countBefore = RapidPair.emitted
        call p.setColor(PLAYER_COLOR_PINK)
        call p.cast(-3800.,3024.)
        call Check(p.pending==6 and p.nextShot==nextTime and RapidPair.emitted==countBefore,"colored recast preserves next shot and replenishes six")
        set stage = 3
    elseif stage == 3 and elapsed >= 0.28125 then
        call Check(p.lastMissile.model==expected[7],"next recast shot uses updated override")
        call Check(prior.allocated and prior.model==expected[0],"flying shot keeps previous red color")
        call SetPlayerColor(Player(0),PLAYER_COLOR_YELLOW)
        call p.clearColor()
        call p.cast(-3800.,3024.)
        set since = RapidPair.now()
        set stage = 4
    elseif stage == 4 and elapsed >= 0.28125 then
        call Check(p.lastMissile.model==expected[4],"cleared override follows changed owner color")
        call p.setColor(PLAYER_COLOR_GREEN)
        call p.cast(-3800.,3024.)
        set since = RapidPair.now()
        set stage = 5
    elseif stage == 5 and elapsed >= 0.28125 then
        call Check(p.lastMissile.model==expected[6],"explicit team color overrides player color")
        call SetPlayerColor(Player(1),PLAYER_COLOR_PURPLE)
        call SetUnitOwner(p.actor,Player(1),true)
        call p.clearColor()
        call p.cast(-3800.,3024.)
        set since = RapidPair.now()
        set stage = 6
    elseif stage == 6 and elapsed >= 0.28125 then
        call Check(p.lastMissile.model==expected[3],"changed owner selects its current color")
        call Check(RAbsBJ(p.lastMissile.scale-RapidBolt.VISUAL_SCALE)<0.0001,"scale applied on reused projectile dummy")
        call Check(RapidPair.minInterval>=0.249,"color changes do not shorten firing interval")
        call SetUnitOwner(p.actor,Player(0),true)
        call SetPlayerColor(Player(0),PLAYER_COLOR_RED)
        call SetPlayerColor(Player(1),PLAYER_COLOR_BLUE)
        call p.clearColor()
        set since = RapidPair.now()
        set stage = 7
    elseif stage == 7 and elapsed >= 4. then
        call Check(not p.firing and p.pending==0 and RapidBolt.live==0,"burst finishes with zero pending/live")
        call Check(MissileStats.created==MissileStats.retired,"all real missile instances retired")
        // Do not leave a collidable demo actor at the next laboratory's spawn.
        call SetUnitPosition(p.actor,originalX,originalY)
        call IssueImmediateOrder(p.actor,"stop")
        call Save()
        call PauseTimer(ticker)
        call ClearTextMessages()
        call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"COLOR COMPLETE: "+I2S(checks)+" checks / "+I2S(failures)+" failures. -palette / -calibrate")
    endif
endfunction
private function Tests takes nothing returns nothing
    local integer i = 0
    local Missile m
    if stage != 0 then
        return
    endif
    set p = RapidDemo.pair
    set originalX = GetUnitX(p.actor)
    set originalY = GetUnitY(p.actor)
    call SetUnitPosition(p.actor,-4700.,3024.)
    call IssueImmediateOrder(p.actor,"stop")
    loop
        exitwhen i == 12
        call SetPlayerColor(Player(0),ConvertPlayerColor(i))
        set m = RapidBolt.shoot(p.actor,-3800.,3024.)
        call Check(m.model==expected[i],"model for owner color "+I2S(i))
        call Check(RAbsBJ(m.scale-RapidBolt.VISUAL_SCALE)<0.0001,"scale for owner color "+I2S(i))
        call m.destroy()
        set i = i+1
    endloop
    call Check(PLAYER_COLOR_RED==null and RapidBolt.modelForColor(PLAYER_COLOR_RED)==expected[0],"Classic red enum0 remains a valid explicit color")
    call Check(RapidBolt.modelForColor(ConvertPlayerColor(12))==expected[8],"neutral color fallback gray")
    call Check(RapidBolt.HIT_RADIUS==16.,"collision radius unchanged")
    set stage = 1
    set since = RapidPair.now()
    call TimerStart(ticker,1./32.,true,function Tick)
endfunction
private function Init takes nothing returns nothing
    local trigger a = CreateTrigger()
    local trigger b = CreateTrigger()
    local trigger c = CreateTrigger()
    set expected[0] = "ShotsTeam\\Shot_00_Red.mdx"
    set expected[1] = "ShotsTeam\\Shot_01_Blue.mdx"
    set expected[2] = "ShotsTeam\\Shot_02_Cyan.mdx"
    set expected[3] = "ShotsTeam\\Shot_03_Purple.mdx"
    set expected[4] = "ShotsTeam\\Shot_04_Yellow.mdx"
    set expected[5] = "ShotsTeam\\Shot_05_Orange.mdx"
    set expected[6] = "ShotsTeam\\Shot_06_Green.mdx"
    set expected[7] = "ShotsTeam\\Shot_07_Pink.mdx"
    set expected[8] = "ShotsTeam\\Shot_08_LightGray.mdx"
    set expected[9] = "ShotsTeam\\Shot_09_LightBlue.mdx"
    set expected[10] = "ShotsTeam\\Shot_10_Aqua.mdx"
    set expected[11] = "ShotsTeam\\Shot_11_Brown.mdx"
    call TriggerRegisterPlayerChatEvent(a,Player(0),"-calibrate",true)
    call TriggerAddAction(a,function Calibrate)
    call TriggerRegisterPlayerChatEvent(b,Player(0),"-palette",true)
    call TriggerAddAction(b,function Palette)
    call TriggerRegisterPlayerChatEvent(c,Player(0),"-testcolors",true)
    call TriggerAddAction(c,function Tests)
    set a = null
    set b = null
    set c = null
endfunction
endlibrary

// Engine laboratory, excluded from the delivered map.
library RapidFireProbe initializer Init requires RapidFireDemo
globals
    private RapidPair p = 0
    private RapidPair q = 0
    private integer stage = 0
    private integer checks = 0
    private integer failures = 0
    private string array lines
    private integer count = 0
    private real since
    private real sx = -4700.
    private real sy = 3024.
    private integer baseline
    private integer createdBaseline
    private Missile oldFlight
    private integer instants
    private integer expectedHandoffs
    private integer expectedHits
    private integer expectedWalls
    private real startX
    private real startY
    private real expectedNext
    private real last = -1000.
    private real minimum = 99999.
    private integer observed = 0
    private boolean one = false
    private boolean two = false
    private unit target
    private destructable tree
    private timer t = null
    private real cx1 = 0.
    private real cy1 = 0.
    private real cx2 = 0.
    private real cy2 = 0.
    private integer cliffIndex = 0
    private real firstEmission = -1.
    private real firstEnd = -1.
endglobals
private function Note takes string s returns nothing
    set lines[count] = s
    set count = count+1
endfunction
private function Check takes boolean ok, string label returns nothing
    set checks = checks+1
    if ok then
        call Note("PASS "+label)
    else
        set failures = failures+1
        call Note("FAIL "+label)
    endif
endfunction
private function Save takes string status returns nothing
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("RAPID 20261023-145002 "+status)
    loop
        exitwhen i == count
        call Preload(lines[i])
        set i = i+1
    endloop
    call Preload("checks="+I2S(checks)+" failures="+I2S(failures)+" observed="+I2S(observed)+" minimum="+R2S(minimum)+" emitted="+I2S(RapidPair.emitted)+" live="+I2S(RapidBolt.live)+" pairs="+I2S(RapidPair.pairs))
    call PreloadGenEnd("Logs\\TerrainDev-20261023-145002-rapid.txt")
endfunction
private function Advance takes integer value returns nothing
    set stage = value
    set since = RapidPair.now()
    set one = false
    set two = false
    call Save("PROGRESS stage="+I2S(stage))
endfunction
private function Body takes real x, real y returns RapidPair
    return RapidPair.create(CreateUnit(Player(0),'rfct',WorldBounds.minX+256.,WorldBounds.minY+256.,0.),CreateUnit(Player(0),'rfex',x,y,0.))
endfunction
private function Reset takes nothing returns nothing
    local unit body = p.actor
    call p.destroy()
    call RemoveUnit(body)
    set p = Body(sx,sy)
    set body = null
endfunction
private function CliffCase takes integer i returns nothing
    if i == 0 then
        set cx1 = -3168.
        set cy1 = -5632.
        set cx2 = -2848.
        set cy2 = -5632.
    elseif i == 1 then
        set cx1 = -1760.
        set cy1 = -4480.
        set cx2 = -1440.
        set cy2 = -4480.
    elseif i == 2 then
        set cx1 = -5504.
        set cy1 = -3424.
        set cx2 = -5504.
        set cy2 = -3104.
    elseif i == 3 then
        set cx1 = -5376.
        set cy1 = -3424.
        set cx2 = -5376.
        set cy2 = -3104.
    elseif i == 4 then
        set cx1 = 2048.
        set cy1 = -2784.
        set cx2 = 2048.
        set cy2 = -2464.
    elseif i == 5 then
        set cx1 = 2176.
        set cy1 = 800.
        set cx2 = 2176.
        set cy2 = 1120.
    elseif i == 6 then
        set cx1 = 2304.
        set cy1 = 800.
        set cx2 = 2304.
        set cy2 = 1120.
    elseif i == 7 then
        set cx1 = 2432.
        set cy1 = 800.
        set cx2 = 2432.
        set cy2 = 1120.
    elseif i == 8 then
        set cx1 = 1824.
        set cy1 = 1152.
        set cx2 = 2144.
        set cy2 = 1152.
    elseif i == 9 then
        set cx1 = -2944.
        set cy1 = 1184.
        set cx2 = -2944.
        set cy2 = 1504.
    elseif i == 10 then
        set cx1 = -2816.
        set cy1 = 1184.
        set cx2 = -2816.
        set cy2 = 1504.
    elseif i == 11 then
        set cx1 = -2688.
        set cy1 = 1184.
        set cx2 = -2688.
        set cy2 = 1504.
    elseif i == 12 then
        set cx1 = -3680.
        set cy1 = 1920.
        set cx2 = -3360.
        set cy2 = 1920.
    elseif i == 13 then
        set cx1 = 1536.
        set cy1 = 1824.
        set cx2 = 1536.
        set cy2 = 2144.
    elseif i == 14 then
        set cx1 = 1664.
        set cy1 = 1824.
        set cx2 = 1664.
        set cy2 = 2144.
    elseif i == 15 then
        set cx1 = -3680.
        set cy1 = 2048.
        set cx2 = -3360.
        set cy2 = 2048.
    elseif i == 16 then
        set cx1 = -5248.
        set cy1 = 5280.
        set cx2 = -5248.
        set cy2 = 5600.
    elseif i == 17 then
        set cx1 = -2016.
        set cy1 = 5504.
        set cx2 = -1696.
        set cy2 = 5504.
    elseif i == 18 then
        set cx1 = -2688.
        set cy1 = 5664.
        set cx2 = -2688.
        set cy2 = 5984.
    elseif i == 19 then
        set cx1 = -2016.
        set cy1 = 5888.
        set cx2 = -1696.
        set cy2 = 5888.
    elseif i == 20 then
        set cx1 = -2016.
        set cy1 = 6016.
        set cx2 = -1696.
        set cy2 = 6016.
    endif
endfunction
private function Tick takes nothing returns nothing
    local real elapsed = RapidPair.now()-since
    local real travelled
    local real angle
    local integer result
    local unit body
    if stage == 1 and p.firing and firstEmission < 0. then
        set firstEmission = p.lastShot
    endif
    if stage == 1 and not p.firing and firstEmission > 0. and firstEnd < 0. then
        set firstEnd = RapidPair.now()
    endif
    if p != 0 and p.lastShot != last and p.lastShot > 0. then
        if last > 0. and p.lastShot-last < minimum then
            set minimum = p.lastShot-last
        endif
        set last = p.lastShot
        set observed = observed+1
        call Note("SHOT stage="+I2S(stage)+" time="+R2S(last)+" pending="+I2S(p.pending)+" aim="+R2S(p.aimX)+","+R2S(p.aimY))
    endif
    if stage == 0 then
        call Save("BEFORE BODY")
        set p = Body(sx,sy)
        call Save("BEFORE TRACE")
        call Check(GroundCollision.trace(sx,sy,sx+320.,sy,24.,p.actor,Player(0),false)==0,"open lane 320 ground units")
        call Save("AFTER TRACE")
        call Check(GetUnitAbilityLevel(p.controller,'Arpf')==1 and GetUnitAbilityLevel(p.actor,'Arpf')==0,"ability only on controller")
        set baseline = RapidPair.emitted
        set createdBaseline = MissileStats.created
        call Check(IssuePointOrder(p.controller,"channel",sx+900.,sy),"native point cast accepted")
        call Advance(1)
    elseif stage == 1 and elapsed > 2.1 then
        call Check(RapidPair.emitted-baseline==6,"native cast emitted exactly six")
        call Check(MissileStats.created-createdBaseline==6 and RapidBolt.live==0,"six real Missile instances created and retired")
        call Check(not p.firing and p.pending==0,"initial burst tail ended")
        call Check(RAbsBJ(firstEnd-firstEmission-1.5)<0.032,"burst protection ends 1.5 seconds after first emission")
        call Note("WINDOW first="+R2S(firstEmission)+" end="+R2S(firstEnd))
        set baseline = RapidPair.emitted
        call p.cast(sx+900.,sy)
        set oldFlight = p.lastMissile
        call Advance(2)
    elseif stage == 2 then
        if elapsed >= 0.125 and not one then
            set expectedNext = p.nextShot
            set expectedHits = RapidPair.emitted
            call p.cast(sx,sy+600.)
            call Check(p.pending==6 and p.nextShot==expectedNext and RapidPair.emitted==expectedHits,"early recast six, same clock, no extra shot")
            call Check(oldFlight.allocated and oldFlight.impact.x==sx+900. and oldFlight.impact.y==sy,"already launched missile keeps its original aim")
            set one = true
        endif
        if elapsed >= 0.28125 and not two then
            call Check(p.lastMissile.impact.y==sy+600. and p.lastMissile.impact.x==sx,"next missile uses new aim")
            set expectedNext = p.nextShot
            set expectedHits = RapidPair.emitted
            call p.cast(sx+800.,sy+100.)
            call Check(p.pending==6 and p.nextShot==expectedNext and RapidPair.emitted==expectedHits,"late recast six, same clock, new aim")
            set two = true
        endif
        if elapsed > 2.2 then
            call Check(RapidPair.emitted-baseline==8 and not p.firing,"two recasts produced eight scheduled emissions")
            call Reset()
            call p.move(sx+1050.,sy)
            call Advance(3)
        endif
    elseif stage == 3 and elapsed > 0.3 then
        call Check(GetUnitCurrentOrder(p.actor)==851986 and GetUnitX(p.actor)>sx+30.,"native locomotion before cast")
        set instants = GroundMotion.instantTransitions
        set expectedHandoffs = GroundMotion.handoffs
        call p.cast(GetUnitX(p.actor),sy+600.)
        set startX = GetUnitX(p.actor)
        set startY = GetUnitY(p.actor)
        call Check(GetUnitCurrentOrder(p.actor)==0 and GroundMotion.instantTransitions==instants+1,"instant first tick cancels native move")
        call Advance(4)
    elseif stage == 4 then
        if elapsed > 0.2 and not one then
            set travelled = GetUnitX(p.actor)-startX
            call Note("MOVE distance="+R2S(travelled)+" seconds="+R2S(elapsed)+" facing="+R2S(GetUnitFacing(p.actor)))
            call Check(RAbsBJ(travelled-350.*elapsed)<15. and RAbsBJ(GetUnitY(p.actor)-startY)<1.,"artificial speed 350 without double native travel")
            call Check(GetUnitFacing(p.actor)>80. and GetUnitFacing(p.actor)<115.,"aim facing independent of movement")
            set expectedNext = p.nextShot
            call p.cast(sx+1000.,sy+500.)
            call Check(p.nextShot==expectedNext and GroundMotion.instantTransitions==instants+1,"moving recast does not repeat instant transition")
            call Check(IssuePointOrder(p.controller,"move",sx+1050.,sy+32.),"proxy point move accepted during burst")
            call Check(p.motion.goalY==sy+32.,"new move target captured")
            set one = true
        endif
        if elapsed > 2. then
            call Check(not p.firing and GroundMotion.handoffs==expectedHandoffs+1 and GetUnitCurrentOrder(p.actor)==851986,"one native handoff for unfinished route")
            call Reset()
            set expectedHandoffs = GroundMotion.handoffs
            call p.cast(sx+900.,sy)
            call p.move(sx+40.,sy)
            call Advance(5)
        endif
    elseif stage == 5 and elapsed > 1.7 then
        call Check(not p.motion.hasGoal and RAbsBJ(GetUnitX(p.actor)-(sx+40.))<3.,"short artificial route arrived")
        call Check(GroundMotion.handoffs==expectedHandoffs and GetUnitCurrentOrder(p.actor)==0,"no native move after arrival")
        call Reset()
        set target = CreateUnit(Player(12),'rftg',sx+160.,sy,0.)
        call PauseUnit(target,true)
        set expectedHits = RapidBolt.hits
        call RapidBolt.shoot(p.actor,sx+500.,sy)
        call Advance(6)
    elseif stage == 6 and elapsed > 0.6 then
        call Check(RapidBolt.hits==expectedHits+1 and GetWidgetLife(target)<2000. and GetWidgetLife(target)>1960.,"projectile expectedHits enemy once and retires")
        call RemoveUnit(target)
        set target = CreateUnit(Player(0),'rftg',sx+110.,sy,0.)
        call PauseUnit(target,true)
        call p.cast(sx+600.,sy)
        call p.move(sx+250.,sy)
        call Advance(7)
    elseif stage == 7 and elapsed > 1.7 then
        call Check(GetUnitX(p.actor)>sx+245.,"artificial movement ignores unit collision")
        call RemoveUnit(target)
        call Reset()
        set tree = CreateDestructable('LTlt',sx+180.,sy,0.,1.,0)
        set target = CreateUnit(Player(12),'rftg',sx+360.,sy,0.)
        call PauseUnit(target,true)
        set expectedWalls = RapidBolt.walls
        set expectedHits = RapidBolt.hits
        call p.cast(sx+600.,sy)
        call p.move(sx+500.,sy)
        call Advance(8)
    elseif stage == 8 and elapsed > 1.4 then
        call Check(p.motion.blocked and GetUnitX(p.actor)<sx+150.,"live tree blocks artificial movement")
        call Check(RapidBolt.walls>expectedWalls and RapidBolt.hits==expectedHits and GetWidgetLife(target)==2000.,"tree stops projectiles before target behind it")
        call KillDestructable(tree)
        call Advance(9)
    elseif stage == 9 and elapsed > 1.2 then
        call Check(not GroundCollision.alive(null),"null units rejected")
        call Check(GetUnitX(p.actor)>sx+200.,"native travel can continue after dead tree")
        call RemoveDestructable(tree)
        call RemoveUnit(target)
        call Reset()
        set q = Body(sx,sy-48.)
        call p.cast(sx+600.,sy)
        call q.cast(sx+600.,sy-48.)
        set expectedNext = q.nextShot
        call p.cast(sx,sy+500.)
        call Check(q.nextShot==expectedNext and q.pending==5 and q.aimY==sy-48.,"two pairs isolated during recast")
        call Advance(10)
    elseif stage == 10 and elapsed > 2. then
        call Check(not p.firing and not q.firing and RapidBolt.live==0 and MissileStats.active==0,"two concurrent emitters and real projectiles drain")
        set body = q.actor
        call q.cast(sx+600.,sy)
        call KillUnit(body)
        set q = 0
        call Advance(11)
    elseif stage == 11 and elapsed > 1.5 then
        call Check(RapidPair.pairs==2 and RapidPair.bursts==0 and RapidPair.remaining==0 and RapidBolt.live==0,"death cleans controller, emitter, pending and projectile state")
        call Check(minimum>=0.249 and minimum<=0.282 and observed>=30,"positive emission coverage with clean intervals")
        call Check(MultiboardGetRowCount(MissileStats.board)==25,"diagnostics extended to 25 rows")
        call Advance(12)
    elseif stage == 12 then
        call CliffCase(cliffIndex)
        if GroundCollision.clear(cx1,cy1,24.) and GroundCollision.clear(cx2,cy2,24.) and RAbsBJ(GroundCollision.height(cx1,cy1)-GroundCollision.height(cx2,cy2))>64. then
            call Note("CLIFF from="+R2S(cx1)+","+R2S(cy1)+" to="+R2S(cx2)+","+R2S(cy2)+" levels="+I2S(GetTerrainCliffLevel(cx1,cy1))+","+I2S(GetTerrainCliffLevel(cx2,cy2)))
            call Check(true,"authored cliff endpoints are walkable with real elevation change")
            call Check(GroundCollision.trace(cx1,cy1,cx2,cy2,24.,p.actor,Player(0),false)==1,"authored cliff blocks swept movement first direction")
            call Check(GroundCollision.trace(cx2,cy2,cx1,cy1,24.,p.actor,Player(0),false)==1,"authored cliff blocks swept movement reverse direction")
            call Advance(13)
        else
            set cliffIndex = cliffIndex+1
            if cliffIndex >= 21 then
                call Check(false,"positive authored cliff coverage was not found")
                call Advance(13)
            endif
        endif
    elseif stage == 13 then
        call Note("RAMP heights="+R2S(GroundCollision.height(-1600.,-4992.))+","+R2S(GroundCollision.height(-1344.,-4992.)))
        call Check(RAbsBJ(GroundCollision.height(-1600.,-4992.)-GroundCollision.height(-1344.,-4992.))>64.,"authored ramp has real elevation change")
        call Check(GroundCollision.trace(-1600.,-4992.,-1344.,-4992.,24.,p.actor,Player(0),false)==0,"authored descending ramp remains walkable")
        call Check(GroundCollision.trace(-1344.,-4992.,-1600.,-4992.,24.,p.actor,Player(0),false)==0,"authored ascending ramp remains walkable")
        call Advance(14)
    elseif stage == 14 then
        call SetTerrainPathable(sx+160.,sy,PATHING_TYPE_WALKABILITY,false)
        call Check(IsTerrainPathable(sx+160.,sy,PATHING_TYPE_WALKABILITY),"native wall pathing really blocked")
        call Check(GroundCollision.trace(sx,sy,sx+320.,sy,24.,p.actor,Player(0),false)==1 and GroundCollision.x<sx+160.,"narrow pathing wall stops a segment spanning both sides")
        call SetTerrainPathable(sx+160.,sy,PATHING_TYPE_WALKABILITY,true)
        call Check(not IsTerrainPathable(sx+160.,sy,PATHING_TYPE_WALKABILITY),"native wall removed before endpoint test")
        call Check(GroundCollision.trace(WorldBounds.maxX-96.,WorldBounds.maxY-96.,WorldBounds.maxX+32.,WorldBounds.maxY+32.,24.,p.actor,Player(0),false)==1,"world edge blocks movement")
        call Reset()
        set target = CreateUnit(Player(12),'rftg',sx+450.,sy,0.)
        call PauseUnit(target,true)
        set expectedHits = RapidBolt.hits
        call RapidBolt.shoot(p.actor,sx+450.,sy)
        call Advance(15)
    elseif stage == 15 and elapsed > 0.6 then
        call Check(RapidBolt.hits==expectedHits+1 and GetWidgetLife(target)<2000.,"target at final missile endpoint is not skipped")
        call RemoveUnit(target)
        call Save("COMPLETE")
        call PauseTimer(t)
        call DestroyTimer(t)
        call DisplayTimedTextToPlayer(Player(0),0.,0.,30.,"RAPID TEST COMPLETE checks="+I2S(checks)+" failures="+I2S(failures))
    endif
    set body = null
endfunction
private function Begin takes nothing returns nothing
    call Note("BEGIN timer="+I2S(GetHandleId(t))+" clock="+R2S(RapidPair.now()))
    call Save("BEGIN")
    set since = RapidPair.now()
    set t = CreateTimer()
    call TimerStart(t,1./32.,true,function Tick)
    call Note("AFTER START timer="+I2S(GetHandleId(t))+" timeout="+R2S(TimerGetTimeout(t))+" expired="+I2S(GetHandleId(GetExpiredTimer())))
    call Save("STARTED")
    call DestroyTimer(GetExpiredTimer())
endfunction
private function Queue takes nothing returns nothing
    call TimerStart(CreateTimer(),0.03125,false,function Begin)
endfunction
private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-rapid",true)
    call TriggerAddAction(t,function Queue)
    set t = null
endfunction
endlibrary

// Engine laboratory only. The lane is selected from the real map, not flattened.
library X3Probe initializer Init requires X3BusterDemo
globals
    private integer checks = 0
    private integer failures = 0
    private integer stage = -1
    private integer search = 0
    private string array lines
    private real since
    private real sx = -4700.
    private real sy = 3024.
    private unit source
    private unit target
    private destructable tree
    private X3Buster shot
    private X3Buster second
    private integer baseline
    private integer births
    private integer hitBase
    private integer wallBase
    private integer satelliteBase
    private boolean one = false
    private timer ticker = CreateTimer()
    private timer showing = CreateTimer()
    private integer array capped
    private integer capIndex = 0
    private real facingImmediate
    private real facingSettled
    private real fallbackAngle
    private RapidPair nativePair
    private real firstDamage = 0.
    private real fusedDamage = 0.
    private trigger damageWatch
    private real catchX
    private real catchY
    private real sampleGreen
    private real sampleOrange
    private real sampleCore
    private real sampleSpeed
    private real reverseExpected = 0.
    private real boundaryDamage = 0.
    private real previousClock = -1.
    private integer repeatedClock = 0
    private integer physicalCallbacks = 0
    private real greenBirthX = 0.
    private real greenMinimumX = 0.
    private real greenRetreat = 0.
    private real finalGreenSpeed = 0.
    private real finalOrangeSpeed = 0.
    private integer damageEvents = 0
endglobals
private function Check takes boolean value, string label returns nothing
    set lines[checks] = "PASS "+label
    if not value then
        set lines[checks] = "FAIL "+label
        set failures = failures+1
    endif
    set checks = checks+1
endfunction
private function Save takes string status returns nothing
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("X3 20261023-145002 "+status)
    loop
        exitwhen i == checks
        call Preload(lines[i])
        set i = i+1
    endloop
    call Preload("checks="+I2S(checks)+" failures="+I2S(failures)+" casts="+I2S(X3Buster.live)+" live="+I2S(X3Buster.projectiles)+" created="+I2S(X3Buster.created)+" retired="+I2S(X3Buster.retired)+" fusions="+I2S(X3Buster.fusions)+" flashes="+I2S(X3Buster.flashCount()))
    call Preload("facingImmediate="+R2S(facingImmediate)+" facingSettled="+R2S(facingSettled)+" fallbackDegrees="+R2S(fallbackAngle*bj_RADTODEG))
    call Preload("boundaryFirstDamage="+R2S(boundaryDamage)+" expectedFusedDamage="+R2S(fusedDamage)+" reverseFirstDamage="+R2S(firstDamage)+" reverseExpected="+R2S(reverseExpected))
    call Preload("physicalCallbacks="+I2S(physicalCallbacks)+" repeatedClockReadings="+I2S(repeatedClock))
    call Preload("greenRetreat="+R2S(greenRetreat)+" greenFinalSpeed="+R2S(finalGreenSpeed)+" orangeFinalSpeed="+R2S(finalOrangeSpeed)+" reverseDamageEvents="+I2S(damageEvents))
    call PreloadGenEnd("Logs\\TerrainDev-20261023-145002-x3.txt")
endfunction
private function Advance takes integer nextStage returns nothing
    set stage = nextStage
    set since = X3Buster.now()
    set one = false
    call Save("PROGRESS "+I2S(stage))
endfunction
private function Damage takes nothing returns nothing
    set damageEvents = damageEvents+1
    if firstDamage == 0. then
        set firstDamage = GetEventDamage()
    endif
endfunction
private function Tick takes nothing returns nothing
    local real elapsed = X3Buster.now()-since
    local real gy
    local real oy
    local integer i
    local X3Buster c
    set physicalCallbacks = physicalCallbacks+1
    if previousClock == X3Buster.now() then
        set repeatedClock = repeatedClock+1
    endif
    set previousClock = X3Buster.now()
    if stage >= 40 and stage <= 43 and shot.sat1 != 0 then
        set greenMinimumX = RMinBJ(greenMinimumX,GetUnitX(shot.sat1.dummy))
    endif
    if stage == 0 then
        if GroundCollision.trace(sx,sy,sx+850.,sy,78.,null,Player(0),false) == 0 then
            set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
            call Check(true,"real unobstructed lane found")
            set shot = X3Buster.fire(source,sx+1400.,sy,0)
            call Check(shot != 0 and shot.bodies == 1,"charged shot creates one body")
            call Check(shot.pulse.model == "X3Buster\\X3_Buster_Cargado.mdx","charged model A selected")
            call Check(RAbsBJ(shot.pulse.scale-1.) < 0.001,"charged width58 matches radius29")
            call Advance(1)
        else
            set search = search+1
            set sy = sy-160.
            if search == 35 then
                call Check(false,"real unobstructed lane found")
                call Save("COMPLETE")
                call PauseTimer(ticker)
            endif
        endif
    elseif stage == 1 and elapsed >= 0.2 then
        call Check(shot.pulse.x > sx+160. and shot.pulse.x < sx+270.,"charged advances with accelerating pulse trajectory")
        call Check(shot.pulse.speed/X3Buster.STEP > X3Buster.PULSE_INITIAL+200. and shot.pulse.speed/X3Buster.STEP < X3Buster.PULSE_SPEED,"charged pulse gains speed below its cap")
        call Check(RAbsBJ(shot.pulse.y-sy) < 0.01,"charged flight remains straight")
        call Check(RAbsBJ(GetUnitX(source)-sx) < 0.01,"physics does not move caster")
        call shot.cancel()
        call Advance(2)
    elseif stage == 2 and elapsed >= 0.125 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0,"cancel retires charged body and cast")
        set baseline = X3Buster.fusions
        set births = X3Buster.created
        set satelliteBase = X3Buster.satellites
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        call Check(shot.bodies == 2 and shot.pulse == 0 and shot.waiting,"two orbs precede delayed pulse")
        call Advance(3)
    elseif stage == 3 then
        if elapsed >= 0.125 and not one then
            set one = true
            set gy = GetUnitY(shot.green.dummy)
            set oy = GetUnitY(shot.orange.dummy)
            call Check(RAbsBJ(gy-oy) > 1.,"two bodies orbit independently in XY")
            call Check(RAbsBJ(gy+oy-2.*sy) < 0.1,"orb offsets remain opposite")
            call Check(GetUnitFlyHeight(shot.green.dummy) > GetUnitFlyHeight(shot.orange.dummy)+1.,"orbit includes opposite height offsets")
            call Check(shot.pulse == 0,"no early second pulse")
            call Check(shot.green.x < sx+100.,"initial orbs travel slowly ahead of the pulse")
        endif
        if elapsed >= 0.44 then
            call Check(shot.pulse != 0 and shot.pulse.x < shot.green.x,"second pulse launches behind orbs")
            call Check(X3Buster.fusions == baseline,"separation alone cannot trigger fusion")
            call Advance(4)
        endif
    elseif stage == 4 and shot.state == 2 then
        call Check(shot.state == 2 and X3Buster.fusions == baseline+1,"catching pulse produces exactly one fusion")
        call Check(shot.green == 0 and shot.orange == 0 and shot.pulse == 0,"three precursor bodies retired after union")
        call Check(shot.fused != 0 and shot.fused.model == "X3Buster\\X3_Cross_Buster.mdx","union produces model C")
        call Check(X3Buster.satellites == satelliteBase+4,"union emits four satellites")
        call Check(X3Buster.created == births+8,"bounded emission budget eight bodies per super shot")
        call Check(X3Buster.lastFusionX > sx+130. and X3Buster.lastFusionX < sx+230.,"fusion occurs at actual catch location")
        call Check(X3Buster.lastFusionAge > 0.45 and X3Buster.lastFusionAge < 0.70,"catch timing matches accelerating relative motion")
        call Check(GetUnitY(shot.sat1.dummy) < GetUnitY(shot.sat4.dummy),"satellites separate on opposite curved paths")
        set sampleGreen = GetUnitX(shot.sat1.dummy)
        set greenBirthX = sampleGreen
        set greenMinimumX = sampleGreen
        set sampleOrange = GetUnitX(shot.sat2.dummy)
        set sampleCore = shot.fused.x
        call Advance(40)
    elseif stage == 40 and elapsed >= 0.09375 then
        call Check(GetUnitX(shot.sat1.dummy) < sampleGreen-6.,"green satellite really travels backwards after union")
        call Check(GetUnitX(shot.sat2.dummy) < sampleOrange-3.,"orange satellite really travels backwards after union")
        call Check(shot.sat1.speed < 0. and shot.sat2.speed < 0.,"satellite longitudinal velocity starts negative")
        call Check(shot.fused.x > sampleCore and shot.fused.x < sampleCore+40.,"core starts gently without a backwards jump")
        set sampleGreen = GetUnitX(shot.sat1.dummy)
        set sampleSpeed = shot.fused.speed
        call Advance(41)
    elseif stage == 41 and elapsed >= 0.125 then
        set sampleGreen = RMinBJ(sampleGreen,GetUnitX(shot.sat1.dummy))
        call Advance(42)
    elseif stage == 42 and elapsed >= 0.125 then
        call Check(GetUnitX(shot.sat1.dummy) > sampleGreen+5.,"satellite turns around and accelerates forwards")
        call Check(shot.sat1.speed > 0. and shot.sat2.speed > 0.,"both satellite families reverse their velocity")
        call Check(shot.fused.speed > sampleSpeed+3.,"core accelerates after formation")
        call Check(RAbsBJ(GetUnitY(shot.sat1.dummy)+GetUnitY(shot.sat4.dummy)-2.*sy) < 0.1 and RAbsBJ(GetUnitY(shot.sat1.dummy)-sy) > RAbsBJ(GetUnitY(shot.sat2.dummy)-sy)+8.,"green and orange paths spread symmetrically at different rates")
        call Advance(43)
    elseif stage == 43 and elapsed >= 0.375 then
        set greenRetreat = greenBirthX-greenMinimumX
        set finalGreenSpeed = shot.sat1.speed/X3Buster.STEP
        set finalOrangeSpeed = shot.sat2.speed/X3Buster.STEP
        call Check(RAbsBJ(shot.sat1.speed/X3Buster.STEP-X3Buster.GREEN_SPEED) < 0.2,"green satellite reaches its sustained speed limit")
        call Check(RAbsBJ(shot.sat2.speed/X3Buster.STEP-X3Buster.ORANGE_SPEED) < 0.2,"orange satellite reaches its sustained speed limit")
        call Advance(5)
    elseif stage == 5 and elapsed >= 1.7 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0,"complete super shot leaves no active bodies")
        call Check(X3Buster.flashCount() == 0,"union flash cleans up its own timer and dummy")
        call Check(X3Buster.created == X3Buster.retired,"all emitted bodies retired exactly once")
        set baseline = X3Buster.fusions
        set shot = X3Buster.fire(source,sx+1400.,sy,2)
        call Advance(6)
    elseif stage == 6 and elapsed >= 0.16 then
        call Check(shot.pulse == 0 and shot.waiting,"manual API waits for release")
        call Check(shot.releasePulse(),"manual release emits one pulse")
        call Check(not shot.releasePulse(),"duplicate release is rejected")
        call Advance(7)
    elseif stage == 7 and elapsed >= 0.5 then
        call Check(X3Buster.fusions == baseline+1,"manual second pulse can fuse")
        call shot.cancel()
        call Advance(8)
    elseif stage == 8 and elapsed >= 0.125 then
        set baseline = X3Buster.fusions
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        call shot.green.destroy()
        call Advance(9)
    elseif stage == 9 and elapsed >= 0.8 then
        call Check(X3Buster.fusions == baseline and shot.fused == 0,"missing orb prevents fusion")
        call shot.cancel()
        call Advance(10)
    elseif stage == 10 and elapsed >= 0.125 then
        set baseline = X3Buster.fusions
        set hitBase = X3Buster.hits
        set target = CreateUnit(Player(12),'rftg',sx+120.,sy,180.)
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        call Advance(11)
    elseif stage == 11 and elapsed >= 0.9 then
        call Check(X3Buster.hits > hitBase and GetWidgetLife(target) < 2000.,"real enemy collision applies damage")
        call Check(X3Buster.fusions == baseline,"enemy impact before union prevents fusion")
        call RemoveUnit(target)
        set target = null
        call shot.cancel()
        call Advance(12)
    elseif stage == 12 and elapsed >= 0.125 then
        set baseline = X3Buster.fusions
        set wallBase = X3Buster.walls
        set tree = CreateDestructable('LTlt',sx+130.,sy,0.,1.,0)
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        call Advance(13)
    elseif stage == 13 and elapsed >= 0.9 then
        call Check(X3Buster.walls > wallBase,"real destructible blocks projectile sweeps")
        call Check(X3Buster.fusions == baseline,"obstacle before union prevents fusion")
        call RemoveDestructable(tree)
        set tree = null
        call shot.cancel()
        call Advance(14)
    elseif stage == 14 and elapsed >= 0.125 then
        set baseline = X3Buster.fusions
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        set second = X3Buster.fire(source,sx+1400.,sy,1)
        call Advance(15)
    elseif stage == 15 and elapsed >= 0.75 then
        call Check(X3Buster.fusions == baseline+2,"simultaneous casts fuse only their own components")
        call Check(shot.fused != second.fused and shot.state == 2 and second.state == 2,"independent resulting missiles per cast")
        call shot.cancel()
        call second.cancel()
        call Advance(16)
    elseif stage == 16 and elapsed >= 0.125 then
        call SetUnitFacing(source,90.)
        set facingImmediate = GetUnitFacing(source)
        set shot = X3Buster.fire(source,sx,sy,0)
        set fallbackAngle = shot.angle
        call Check(RAbsBJ(shot.angle-facingImmediate*bj_DEGTORAD) < 0.01,"zero-distance aim falls back to unit facing")
        call shot.cancel()
        call Advance(17)
    elseif stage == 17 and elapsed >= 0.5 then
        set facingSettled = GetUnitFacing(source)
        call Check(RAbsBJ(facingSettled-90.) < 0.1,"native facing reaches requested angle after motor ticks")
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        call RemoveUnit(source)
        set source = null
        call Advance(18)
    elseif stage == 18 and elapsed >= 0.2 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0,"removed caster cancels pending and flying bodies")
        call Check(X3Buster.created == X3Buster.retired,"interrupted casts preserve balanced lifecycle")
        set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
        set capIndex = 0
        call Advance(19)
    elseif stage == 19 then
        set i = 0
        loop
            exitwhen i == 4
            set capped[capIndex] = X3Buster.fire(source,sx+1400.,sy,2)
            set capIndex = capIndex+1
            set i = i+1
        endloop
        if capIndex < 64 then
            return
        endif
        set c = X3Buster.fire(source,sx+1400.,sy,2)
        call Check(c == 0 and X3Buster.live == 64,"concurrent cast limit rejects overflow")
        set i = 0
        loop
            exitwhen i == 64
            call X3Buster(capped[i]).cancel()
            set i = i+1
        endloop
        call Advance(20)
    elseif stage == 20 and elapsed >= 0.5 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0,"all capped and cancelled casts retire")
        call Check(X3Buster.created == X3Buster.retired,"final created equals retired")
        call Check(X3Buster.flashCount() == 0,"final flash count zero")
        call RemoveUnit(source)
        set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
        set nativePair = RapidPair.create(CreateUnit(Player(0),'rfct',WorldBounds.minX+256.,WorldBounds.minY+256.,0.),source)
        set births = X3Buster.created
        call Check(IssuePointOrder(nativePair.controller,"carrionswarm",sx+1400.,sy),"native W order accepted by controller")
        call Advance(21)
    elseif stage == 21 and elapsed >= 0.25 then
        call Check(X3Buster.created == births+1,"native W spell event creates charged physics")
        call Check(GetUnitCurrentOrder(source) == 0,"visible executor receives no spell order")
        call Advance(22)
    elseif stage == 22 and elapsed >= 1.5 then
        set births = X3Buster.created
        set baseline = X3Buster.fusions
        call Check(IssuePointOrder(nativePair.controller,"shockwave",sx+1400.,sy),"native E order accepted by controller")
        call Advance(23)
    elseif stage == 23 and elapsed >= 0.75 then
        call Check(X3Buster.fusions == baseline+1 and X3Buster.created == births+8,"native E spell event completes cross-shot sequence")
        call Advance(24)
    elseif stage == 24 and elapsed >= 2.2 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0 and X3Buster.created == X3Buster.retired,"native abilities leave balanced zero-active state")
        call nativePair.destroy()
        set baseline = X3Buster.fusions
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        call Advance(25)
    elseif stage == 25 then
        if shot.pulse != 0 then
            set gy = shot.green.x-shot.pulse.x
            if gy > 0. and gy <= shot.pulse.speed-shot.green.speed then
                set catchX = shot.green.x+gy*shot.green.speed/(shot.pulse.speed-shot.green.speed)
                set catchY = sy
                set target = CreateUnit(Player(12),'rftg',catchX+50.,catchY,180.)
                set i = 0
                loop
                    call SetUnitX(target,catchX+50.+I2R(i)*2.)
                    exitwhen (GroundCollision.trace(shot.pulse.x,sy,catchX,sy,29.,source,Player(0),true) == 0 and GroundCollision.trace(shot.pulse.x,sy,shot.pulse.x+shot.pulse.speed,sy,29.,source,Player(0),true) == 2) or i == 25
                    set i = i+1
                endloop
                call Check(i < 25,"boundary fixture clear before union and enemy later in same tick")
                set damageWatch = CreateTrigger()
                call TriggerRegisterUnitEvent(damageWatch,target,EVENT_UNIT_DAMAGED)
                call TriggerAddAction(damageWatch,function Damage)
                // Calibrate native armor/resistance before observing the shot.
                call UnitDamageTarget(source,target,150.,false,false,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_MAGIC,null)
                set fusedDamage = firstDamage
                set firstDamage = 0.
                call SetWidgetLife(target,2000.)
                call Advance(26)
            endif
        endif
        if elapsed > 1. then
            call Check(false,"boundary fixture clear before union and enemy later in same tick")
            call Advance(26)
        endif
    elseif stage == 26 and elapsed >= 0.3 then
        set boundaryDamage = firstDamage
        call Check(X3Buster.fusions == baseline+1 and fusedDamage > 0. and RAbsBJ(firstDamage-fusedDamage) < 0.1,"fusion precedes later enemy impact inside the same tick")
        call DestroyTrigger(damageWatch)
        set damageWatch = null
        call RemoveUnit(target)
        set target = null
        call shot.cancel()
        call Advance(27)
    elseif stage == 27 and elapsed >= 0.2 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0 and X3Buster.created == X3Buster.retired,"boundary case cleanup remains balanced")
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        set hitBase = X3Buster.hits
        call Advance(28)
    elseif stage == 28 and shot.state == 2 then
        set target = CreateUnit(Player(12),'rftg',X3Buster.lastFusionX-80.,sy-55.,180.)
        call Check(GroundCollision.trace(X3Buster.lastFusionX,sy,X3Buster.lastFusionX+150.,sy,41.25,source,Player(0),true) == 0,"backwards-collision target stays clear of the forward core")
        set firstDamage = 0.
        set damageWatch = CreateTrigger()
        call TriggerRegisterUnitEvent(damageWatch,target,EVENT_UNIT_DAMAGED)
        call TriggerAddAction(damageWatch,function Damage)
        call UnitDamageTarget(source,target,25.,false,false,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_MAGIC,null)
        set reverseExpected = firstDamage
        set firstDamage = 0.
        set damageEvents = 0
        call SetWidgetLife(target,2000.)
        call Advance(29)
    elseif stage == 29 and elapsed >= 0.45 then
        call Check(X3Buster.hits > hitBase and reverseExpected > 0. and RAbsBJ(firstDamage-reverseExpected) < 0.1 and damageEvents == 1,"retreating satellite sweeps its real path and damages once")
        call DestroyTrigger(damageWatch)
        set damageWatch = null
        call RemoveUnit(target)
        set target = null
        call shot.cancel()
        call Advance(30)
    elseif stage == 30 and elapsed >= 0.2 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0 and X3Buster.created == X3Buster.retired,"retrograde collision leaves balanced zero-active state")
        call RemoveUnit(source)
        set source = null
        call Save("COMPLETE")
        call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"X3 COMPLETE "+I2S(checks)+" checks / "+I2S(failures)+" failures. -x3show para demostracion.")
        call PauseTimer(ticker)
        set stage = -2
    endif
endfunction
private function Begin takes nothing returns nothing
    if stage != -1 then
        return
    endif
    set stage = 0
    set since = X3Buster.now()
    call TimerStart(ticker,1./32.,true,function Tick)
endfunction
private function Repeat takes nothing returns nothing
    local X3Buster s = X3Buster.fire(source,sx+1400.,sy,1)
endfunction
private function Show takes nothing returns nothing
    if stage != -2 then
        return
    endif
    set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
    call SetCameraTargetController(null,0.,0.,false)
    call PanCameraToTimed(sx+450.,sy,0.)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,1350.,0.)
    call FogEnable(false)
    call FogMaskEnable(false)
    call SetTimeOfDay(12.)
    call SuspendTimeOfDay(true)
    call MultiboardDisplay(MissileStats.board,false)
    call ClearTextMessages()
    call TimerStart(showing,2.5,true,function Repeat)
    call Repeat()
endfunction
function X3ProbeLaneX takes nothing returns real
    return sx
endfunction
function X3ProbeLaneY takes nothing returns real
    return sy
endfunction
private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    set X3Demo.profile = X3Buster.GIF
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-x3test",true)
    call TriggerAddAction(t,function Begin)
    set t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-x3show",true)
    call TriggerAddAction(t,function Show)
    set t = null
endfunction
endlibrary

library X3Oracle requires X3Kinematics
struct X3Oracle extends array
    static integer valueChecks = 0
    static integer valueFailures = 0
    static real maxError = 0.
    static boolean done = false
    private static integer batch = 0
    private static method Scalar takes real actual, real expected returns nothing
        local real error = RAbsBJ(actual-expected)
        set valueChecks = valueChecks+1
        set maxError = RMaxBJ(maxError,error)
        if error > 0.012 then
            set valueFailures = valueFailures+1
            if valueFailures < 8 then
                call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"ORACLE FAIL "+I2S(valueChecks)+" actual "+R2S(actual)+" expected "+R2S(expected))
            endif
        endif
    endmethod
    private static method Combined takes integer p, integer form, integer n, real x, real y, real vx, real vy returns nothing
        local real t = I2R(n)/X3Kinematics.FPS
        local real previous = I2R(n-1)/X3Kinematics.FPS
        call Scalar(X3Kinematics.forward(p,form,t),x)
        call Scalar(X3Kinematics.side(p,form,t),y)
        call Scalar(X3Kinematics.forward(p,form,t)-X3Kinematics.forward(p,form,previous),vx)
        call Scalar(X3Kinematics.side(p,form,t)-X3Kinematics.side(p,form,previous),vy)
    endmethod
    private static method Orb takes integer form, integer n, real x, real y returns nothing
        call Scalar(X3Kinematics.orbitForward(form,I2R(n)/X3Kinematics.FPS),x)
        call Scalar(X3Kinematics.side(1,form,I2R(n)/X3Kinematics.FPS),y)
    endmethod
    private static method Batch0 takes nothing returns nothing
        call Combined(1,7,1,-11.25000000,-1.50000000,-11.25000000,-1.50000000)
        call Combined(1,6,1,-11.25000000,1.50000000,-11.25000000,1.50000000)
        call Combined(1,8,1,-15.00781250,-3.00000000,-15.00781250,-3.00000000)
        call Combined(1,5,1,-15.00781250,3.00000000,-15.00781250,3.00000000)
        call Combined(1,4,1,0.18750000,-0.00000000,0.18750000,0.00000000)
        call Combined(1,7,2,-21.75000000,-3.00000000,-10.50000000,-1.50000000)
        call Combined(1,6,2,-21.75000000,3.00000000,-10.50000000,1.50000000)
        call Combined(1,8,2,-29.02343750,-6.00000000,-14.01562500,-3.00000000)
        call Combined(1,5,2,-29.02343750,6.00000000,-14.01562500,3.00000000)
        call Combined(1,4,2,0.56250000,-0.00000000,0.37500000,0.00000000)
        call Combined(1,7,3,-31.50000000,-4.50000000,-9.75000000,-1.50000000)
        call Combined(1,6,3,-31.50000000,4.50000000,-9.75000000,1.50000000)
        call Combined(1,8,3,-42.04687500,-9.00000000,-13.02343750,-3.00000000)
        call Combined(1,5,3,-42.04687500,9.00000000,-13.02343750,3.00000000)
        call Combined(1,4,3,1.12500000,-0.00000000,0.56250000,0.00000000)
        call Combined(1,7,4,-40.50000000,-6.00000000,-9.00000000,-1.50000000)
        call Combined(1,6,4,-40.50000000,6.00000000,-9.00000000,1.50000000)
        call Combined(1,8,4,-54.07812500,-12.00000000,-12.03125000,-3.00000000)
        call Combined(1,5,4,-54.07812500,12.00000000,-12.03125000,3.00000000)
        call Combined(1,4,4,1.87500000,-0.00000000,0.75000000,0.00000000)
    endmethod
    private static method Batch1 takes nothing returns nothing
        call Combined(1,7,5,-48.75000000,-7.50000000,-8.25000000,-1.50000000)
        call Combined(1,6,5,-48.75000000,7.50000000,-8.25000000,1.50000000)
        call Combined(1,8,5,-65.11718750,-15.00000000,-11.03906250,-3.00000000)
        call Combined(1,5,5,-65.11718750,15.00000000,-11.03906250,3.00000000)
        call Combined(1,4,5,2.81250000,-0.00000000,0.93750000,0.00000000)
        call Combined(1,7,6,-56.25000000,-9.00000000,-7.50000000,-1.50000000)
        call Combined(1,6,6,-56.25000000,9.00000000,-7.50000000,1.50000000)
        call Combined(1,8,6,-75.16406250,-18.00000000,-10.04687500,-3.00000000)
        call Combined(1,5,6,-75.16406250,18.00000000,-10.04687500,3.00000000)
        call Combined(1,4,6,3.93750000,-0.00000000,1.12500000,0.00000000)
        call Combined(1,7,7,-63.00000000,-10.50000000,-6.75000000,-1.50000000)
        call Combined(1,6,7,-63.00000000,10.50000000,-6.75000000,1.50000000)
        call Combined(1,8,7,-84.21875000,-21.00000000,-9.05468750,-3.00000000)
        call Combined(1,5,7,-84.21875000,21.00000000,-9.05468750,3.00000000)
        call Combined(1,4,7,5.25000000,-0.00000000,1.31250000,0.00000000)
        call Combined(1,7,8,-69.00000000,-12.00000000,-6.00000000,-1.50000000)
        call Combined(1,6,8,-69.00000000,12.00000000,-6.00000000,1.50000000)
        call Combined(1,8,8,-92.28125000,-24.00000000,-8.06250000,-3.00000000)
        call Combined(1,5,8,-92.28125000,24.00000000,-8.06250000,3.00000000)
        call Combined(1,4,8,6.75000000,-0.00000000,1.50000000,0.00000000)
    endmethod
    private static method Batch2 takes nothing returns nothing
        call Combined(1,7,9,-74.25000000,-13.50000000,-5.25000000,-1.50000000)
        call Combined(1,6,9,-74.25000000,13.50000000,-5.25000000,1.50000000)
        call Combined(1,8,9,-99.35156250,-27.00000000,-7.07031250,-3.00000000)
        call Combined(1,5,9,-99.35156250,27.00000000,-7.07031250,3.00000000)
        call Combined(1,4,9,8.43750000,-0.00000000,1.68750000,0.00000000)
        call Combined(1,7,10,-78.75000000,-15.00000000,-4.50000000,-1.50000000)
        call Combined(1,6,10,-78.75000000,15.00000000,-4.50000000,1.50000000)
        call Combined(1,8,10,-105.42968750,-30.00000000,-6.07812500,-3.00000000)
        call Combined(1,5,10,-105.42968750,30.00000000,-6.07812500,3.00000000)
        call Combined(1,4,10,10.31250000,-0.00000000,1.87500000,0.00000000)
        call Combined(1,7,11,-82.50000000,-16.50000000,-3.75000000,-1.50000000)
        call Combined(1,6,11,-82.50000000,16.50000000,-3.75000000,1.50000000)
        call Combined(1,8,11,-110.51562500,-33.00000000,-5.08593750,-3.00000000)
        call Combined(1,5,11,-110.51562500,33.00000000,-5.08593750,3.00000000)
        call Combined(1,4,11,12.37500000,-0.00000000,2.06250000,0.00000000)
        call Combined(1,7,12,-85.50000000,-18.00000000,-3.00000000,-1.50000000)
        call Combined(1,6,12,-85.50000000,18.00000000,-3.00000000,1.50000000)
        call Combined(1,8,12,-114.60937500,-36.00000000,-4.09375000,-3.00000000)
        call Combined(1,5,12,-114.60937500,36.00000000,-4.09375000,3.00000000)
        call Combined(1,4,12,14.62500000,-0.00000000,2.25000000,0.00000000)
    endmethod
    private static method Batch3 takes nothing returns nothing
        call Combined(1,7,13,-87.75000000,-19.50000000,-2.25000000,-1.50000000)
        call Combined(1,6,13,-87.75000000,19.50000000,-2.25000000,1.50000000)
        call Combined(1,8,13,-117.71093750,-39.00000000,-3.10156250,-3.00000000)
        call Combined(1,5,13,-117.71093750,39.00000000,-3.10156250,3.00000000)
        call Combined(1,4,13,17.06250000,-0.00000000,2.43750000,0.00000000)
        call Combined(1,7,14,-89.25000000,-21.00000000,-1.50000000,-1.50000000)
        call Combined(1,6,14,-89.25000000,21.00000000,-1.50000000,1.50000000)
        call Combined(1,8,14,-119.82031250,-42.00000000,-2.10937500,-3.00000000)
        call Combined(1,5,14,-119.82031250,42.00000000,-2.10937500,3.00000000)
        call Combined(1,4,14,19.68750000,-0.00000000,2.62500000,0.00000000)
        call Combined(1,7,15,-90.00000000,-22.50000000,-0.75000000,-1.50000000)
        call Combined(1,6,15,-90.00000000,22.50000000,-0.75000000,1.50000000)
        call Combined(1,8,15,-120.93750000,-45.00000000,-1.11718750,-3.00000000)
        call Combined(1,5,15,-120.93750000,45.00000000,-1.11718750,3.00000000)
        call Combined(1,4,15,22.50000000,-0.00000000,2.81250000,0.00000000)
        call Combined(1,7,16,-90.00000000,-24.00000000,0.00000000,-1.50000000)
        call Combined(1,6,16,-90.00000000,24.00000000,0.00000000,1.50000000)
        call Combined(1,8,16,-121.06250000,-48.00000000,-0.12500000,-3.00000000)
        call Combined(1,5,16,-121.06250000,48.00000000,-0.12500000,3.00000000)
        call Combined(1,4,16,25.50000000,-0.00000000,3.00000000,0.00000000)
    endmethod
    private static method Batch4 takes nothing returns nothing
        call Combined(1,7,17,-89.25000000,-25.50000000,0.75000000,-1.50000000)
        call Combined(1,6,17,-89.25000000,25.50000000,0.75000000,1.50000000)
        call Combined(1,8,17,-120.19531250,-51.00000000,0.86718750,-3.00000000)
        call Combined(1,5,17,-120.19531250,51.00000000,0.86718750,3.00000000)
        call Combined(1,4,17,28.68750000,-0.00000000,3.18750000,0.00000000)
        call Combined(1,7,18,-87.75000000,-27.00000000,1.50000000,-1.50000000)
        call Combined(1,6,18,-87.75000000,27.00000000,1.50000000,1.50000000)
        call Combined(1,8,18,-118.33593750,-54.00000000,1.85937500,-3.00000000)
        call Combined(1,5,18,-118.33593750,54.00000000,1.85937500,3.00000000)
        call Combined(1,4,18,32.06250000,-0.00000000,3.37500000,0.00000000)
        call Combined(1,7,19,-85.50000000,-28.50000000,2.25000000,-1.50000000)
        call Combined(1,6,19,-85.50000000,28.50000000,2.25000000,1.50000000)
        call Combined(1,8,19,-115.48437500,-57.00000000,2.85156250,-3.00000000)
        call Combined(1,5,19,-115.48437500,57.00000000,2.85156250,3.00000000)
        call Combined(1,4,19,35.62500000,-0.00000000,3.56250000,0.00000000)
        call Combined(1,7,20,-82.50000000,-30.00000000,3.00000000,-1.50000000)
        call Combined(1,6,20,-82.50000000,30.00000000,3.00000000,1.50000000)
        call Combined(1,8,20,-111.64062500,-60.00000000,3.84375000,-3.00000000)
        call Combined(1,5,20,-111.64062500,60.00000000,3.84375000,3.00000000)
        call Combined(1,4,20,39.37500000,-0.00000000,3.75000000,0.00000000)
    endmethod
    private static method Batch5 takes nothing returns nothing
        call Combined(1,7,21,-78.75000000,-31.50000000,3.75000000,-1.50000000)
        call Combined(1,6,21,-78.75000000,31.50000000,3.75000000,1.50000000)
        call Combined(1,8,21,-106.80468750,-63.00000000,4.83593750,-3.00000000)
        call Combined(1,5,21,-106.80468750,63.00000000,4.83593750,3.00000000)
        call Combined(1,4,21,43.31250000,-0.00000000,3.93750000,0.00000000)
        call Combined(1,7,22,-74.25000000,-33.00000000,4.50000000,-1.50000000)
        call Combined(1,6,22,-74.25000000,33.00000000,4.50000000,1.50000000)
        call Combined(1,8,22,-100.97656250,-66.00000000,5.82812500,-3.00000000)
        call Combined(1,5,22,-100.97656250,66.00000000,5.82812500,3.00000000)
        call Combined(1,4,22,47.43750000,-0.00000000,4.12500000,0.00000000)
        call Combined(1,7,23,-69.00000000,-34.50000000,5.25000000,-1.50000000)
        call Combined(1,6,23,-69.00000000,34.50000000,5.25000000,1.50000000)
        call Combined(1,8,23,-94.15625000,-69.00000000,6.82031250,-3.00000000)
        call Combined(1,5,23,-94.15625000,69.00000000,6.82031250,3.00000000)
        call Combined(1,4,23,51.75000000,-0.00000000,4.31250000,0.00000000)
        call Combined(1,7,24,-63.00000000,-36.00000000,6.00000000,-1.50000000)
        call Combined(1,6,24,-63.00000000,36.00000000,6.00000000,1.50000000)
        call Combined(1,8,24,-86.34375000,-72.00000000,7.81250000,-3.00000000)
        call Combined(1,5,24,-86.34375000,72.00000000,7.81250000,3.00000000)
        call Combined(1,4,24,56.25000000,-0.00000000,4.50000000,0.00000000)
    endmethod
    private static method Batch6 takes nothing returns nothing
        call Combined(1,7,25,-56.25000000,-37.50000000,6.75000000,-1.50000000)
        call Combined(1,6,25,-56.25000000,37.50000000,6.75000000,1.50000000)
        call Combined(1,8,25,-77.53906250,-75.00000000,8.80468750,-3.00000000)
        call Combined(1,5,25,-77.53906250,75.00000000,8.80468750,3.00000000)
        call Combined(1,4,25,60.93750000,-0.00000000,4.68750000,0.00000000)
        call Combined(1,7,26,-48.75000000,-39.00000000,7.50000000,-1.50000000)
        call Combined(1,6,26,-48.75000000,39.00000000,7.50000000,1.50000000)
        call Combined(1,8,26,-67.74218750,-78.00000000,9.79687500,-3.00000000)
        call Combined(1,5,26,-67.74218750,78.00000000,9.79687500,3.00000000)
        call Combined(1,4,26,65.81250000,-0.00000000,4.87500000,0.00000000)
        call Combined(1,7,27,-40.50000000,-40.50000000,8.25000000,-1.50000000)
        call Combined(1,6,27,-40.50000000,40.50000000,8.25000000,1.50000000)
        call Combined(1,8,27,-56.95312500,-81.00000000,10.78906250,-3.00000000)
        call Combined(1,5,27,-56.95312500,81.00000000,10.78906250,3.00000000)
        call Combined(1,4,27,70.87500000,-0.00000000,5.06250000,0.00000000)
        call Combined(1,7,28,-31.50000000,-42.00000000,9.00000000,-1.50000000)
        call Combined(1,6,28,-31.50000000,42.00000000,9.00000000,1.50000000)
        call Combined(1,8,28,-45.17187500,-84.00000000,11.78125000,-3.00000000)
        call Combined(1,5,28,-45.17187500,84.00000000,11.78125000,3.00000000)
        call Combined(1,4,28,76.12500000,-0.00000000,5.25000000,0.00000000)
    endmethod
    private static method Batch7 takes nothing returns nothing
        call Combined(1,7,29,-21.75000000,-43.50000000,9.75000000,-1.50000000)
        call Combined(1,6,29,-21.75000000,43.50000000,9.75000000,1.50000000)
        call Combined(1,8,29,-32.39843750,-87.00000000,12.77343750,-3.00000000)
        call Combined(1,5,29,-32.39843750,87.00000000,12.77343750,3.00000000)
        call Combined(1,4,29,81.56250000,-0.00000000,5.43750000,0.00000000)
        call Combined(1,7,30,-11.25000000,-45.00000000,10.50000000,-1.50000000)
        call Combined(1,6,30,-11.25000000,45.00000000,10.50000000,1.50000000)
        call Combined(1,8,30,-18.63281250,-90.00000000,13.76562500,-3.00000000)
        call Combined(1,5,30,-18.63281250,90.00000000,13.76562500,3.00000000)
        call Combined(1,4,30,87.18750000,-0.00000000,5.62500000,0.00000000)
        call Combined(1,7,31,0.00000000,-46.50000000,11.25000000,-1.50000000)
        call Combined(1,6,31,0.00000000,46.50000000,11.25000000,1.50000000)
        call Combined(1,8,31,-3.87500000,-93.00000000,14.75781250,-3.00000000)
        call Combined(1,5,31,-3.87500000,93.00000000,14.75781250,3.00000000)
        call Combined(1,4,31,93.00000000,-0.00000000,5.81250000,0.00000000)
        call Combined(1,7,32,12.00000000,-48.00000000,12.00000000,-1.50000000)
        call Combined(1,6,32,12.00000000,48.00000000,12.00000000,1.50000000)
        call Combined(1,8,32,11.87500000,-96.00000000,15.75000000,-3.00000000)
        call Combined(1,5,32,11.87500000,96.00000000,15.75000000,3.00000000)
        call Combined(1,4,32,99.00000000,-0.00000000,6.00000000,0.00000000)
    endmethod
    private static method Batch8 takes nothing returns nothing
        call Combined(1,7,33,24.75000000,-49.50000000,12.75000000,-1.50000000)
        call Combined(1,6,33,24.75000000,49.50000000,12.75000000,1.50000000)
        call Combined(1,8,33,28.61718750,-99.00000000,16.74218750,-3.00000000)
        call Combined(1,5,33,28.61718750,99.00000000,16.74218750,3.00000000)
        call Combined(1,4,33,105.18750000,-0.00000000,6.18750000,0.00000000)
        call Combined(1,7,34,38.25000000,-51.00000000,13.50000000,-1.50000000)
        call Combined(1,6,34,38.25000000,51.00000000,13.50000000,1.50000000)
        call Combined(1,8,34,45.60937500,-102.00000000,16.99218750,-3.00000000)
        call Combined(1,5,34,45.60937500,102.00000000,16.99218750,3.00000000)
        call Combined(1,4,34,111.56250000,-0.00000000,6.37500000,0.00000000)
        call Combined(1,7,35,52.50000000,-52.50000000,14.25000000,-1.50000000)
        call Combined(1,6,35,52.50000000,52.50000000,14.25000000,1.50000000)
        call Combined(1,8,35,62.60156250,-105.00000000,16.99218750,-3.00000000)
        call Combined(1,5,35,62.60156250,105.00000000,16.99218750,3.00000000)
        call Combined(1,4,35,118.12500000,-0.00000000,6.56250000,0.00000000)
        call Combined(1,7,36,67.50000000,-54.00000000,15.00000000,-1.50000000)
        call Combined(1,6,36,67.50000000,54.00000000,15.00000000,1.50000000)
        call Combined(1,8,36,79.59375000,-108.00000000,16.99218750,-3.00000000)
        call Combined(1,5,36,79.59375000,108.00000000,16.99218750,3.00000000)
        call Combined(1,4,36,124.87500000,-0.00000000,6.75000000,0.00000000)
    endmethod
    private static method Batch9 takes nothing returns nothing
        call Combined(1,7,37,83.25000000,-55.50000000,15.75000000,-1.50000000)
        call Combined(1,6,37,83.25000000,55.50000000,15.75000000,1.50000000)
        call Combined(1,8,37,96.58593750,-111.00000000,16.99218750,-3.00000000)
        call Combined(1,5,37,96.58593750,111.00000000,16.99218750,3.00000000)
        call Combined(1,4,37,131.81250000,-0.00000000,6.93750000,0.00000000)
        call Combined(1,7,38,99.75000000,-57.00000000,16.50000000,-1.50000000)
        call Combined(1,6,38,99.75000000,57.00000000,16.50000000,1.50000000)
        call Combined(1,8,38,113.57812500,-114.00000000,16.99218750,-3.00000000)
        call Combined(1,5,38,113.57812500,114.00000000,16.99218750,3.00000000)
        call Combined(1,4,38,138.93750000,-0.00000000,7.12500000,0.00000000)
        call Combined(1,7,39,116.50000000,-58.50000000,16.75000000,-1.50000000)
        call Combined(1,6,39,116.50000000,58.50000000,16.75000000,1.50000000)
        call Combined(1,8,39,130.57031250,-117.00000000,16.99218750,-3.00000000)
        call Combined(1,5,39,130.57031250,117.00000000,16.99218750,3.00000000)
        call Combined(1,4,39,146.25000000,-0.00000000,7.31250000,0.00000000)
        call Combined(1,7,40,133.25000000,-60.00000000,16.75000000,-1.50000000)
        call Combined(1,6,40,133.25000000,60.00000000,16.75000000,1.50000000)
        call Combined(1,8,40,147.56250000,-120.00000000,16.99218750,-3.00000000)
        call Combined(1,5,40,147.56250000,120.00000000,16.99218750,3.00000000)
        call Combined(1,4,40,153.75000000,-0.00000000,7.50000000,0.00000000)
    endmethod
    private static method Batch10 takes nothing returns nothing
        call Combined(1,7,41,150.00000000,-61.50000000,16.75000000,-1.50000000)
        call Combined(1,6,41,150.00000000,61.50000000,16.75000000,1.50000000)
        call Combined(1,8,41,164.55468750,-123.00000000,16.99218750,-3.00000000)
        call Combined(1,5,41,164.55468750,123.00000000,16.99218750,3.00000000)
        call Combined(1,4,41,161.43750000,-0.00000000,7.68750000,0.00000000)
        call Combined(1,7,42,166.75000000,-63.00000000,16.75000000,-1.50000000)
        call Combined(1,6,42,166.75000000,63.00000000,16.75000000,1.50000000)
        call Combined(1,8,42,181.54687500,-126.00000000,16.99218750,-3.00000000)
        call Combined(1,5,42,181.54687500,126.00000000,16.99218750,3.00000000)
        call Combined(1,4,42,169.31250000,-0.00000000,7.87500000,0.00000000)
        call Combined(1,7,43,183.50000000,-64.50000000,16.75000000,-1.50000000)
        call Combined(1,6,43,183.50000000,64.50000000,16.75000000,1.50000000)
        call Combined(1,8,43,198.53906250,-129.00000000,16.99218750,-3.00000000)
        call Combined(1,5,43,198.53906250,129.00000000,16.99218750,3.00000000)
        call Combined(1,4,43,177.37500000,-0.00000000,8.06250000,0.00000000)
        call Combined(1,7,44,200.25000000,-66.00000000,16.75000000,-1.50000000)
        call Combined(1,6,44,200.25000000,66.00000000,16.75000000,1.50000000)
        call Combined(1,8,44,215.53125000,-132.00000000,16.99218750,-3.00000000)
        call Combined(1,5,44,215.53125000,132.00000000,16.99218750,3.00000000)
        call Combined(1,4,44,185.62500000,-0.00000000,8.25000000,0.00000000)
    endmethod
    private static method Batch11 takes nothing returns nothing
        call Combined(1,7,45,217.00000000,-67.50000000,16.75000000,-1.50000000)
        call Combined(1,6,45,217.00000000,67.50000000,16.75000000,1.50000000)
        call Combined(1,8,45,232.52343750,-135.00000000,16.99218750,-3.00000000)
        call Combined(1,5,45,232.52343750,135.00000000,16.99218750,3.00000000)
        call Combined(1,4,45,194.06250000,-0.00000000,8.43750000,0.00000000)
        call Combined(1,7,46,233.75000000,-69.00000000,16.75000000,-1.50000000)
        call Combined(1,6,46,233.75000000,69.00000000,16.75000000,1.50000000)
        call Combined(1,8,46,249.51562500,-138.00000000,16.99218750,-3.00000000)
        call Combined(1,5,46,249.51562500,138.00000000,16.99218750,3.00000000)
        call Combined(1,4,46,202.68750000,-0.00000000,8.62500000,0.00000000)
        call Combined(1,7,47,250.50000000,-70.50000000,16.75000000,-1.50000000)
        call Combined(1,6,47,250.50000000,70.50000000,16.75000000,1.50000000)
        call Combined(1,8,47,266.50781250,-141.00000000,16.99218750,-3.00000000)
        call Combined(1,5,47,266.50781250,141.00000000,16.99218750,3.00000000)
        call Combined(1,4,47,211.50000000,-0.00000000,8.81250000,0.00000000)
        call Combined(1,7,48,267.25000000,-72.00000000,16.75000000,-1.50000000)
        call Combined(1,6,48,267.25000000,72.00000000,16.75000000,1.50000000)
        call Combined(1,8,48,283.50000000,-144.00000000,16.99218750,-3.00000000)
        call Combined(1,5,48,283.50000000,144.00000000,16.99218750,3.00000000)
        call Combined(1,4,48,220.50000000,-0.00000000,9.00000000,0.00000000)
    endmethod
    private static method Batch12 takes nothing returns nothing
        call Combined(1,7,49,284.00000000,-73.50000000,16.75000000,-1.50000000)
        call Combined(1,6,49,284.00000000,73.50000000,16.75000000,1.50000000)
        call Combined(1,8,49,300.49218750,-147.00000000,16.99218750,-3.00000000)
        call Combined(1,5,49,300.49218750,147.00000000,16.99218750,3.00000000)
        call Combined(1,4,49,229.68750000,-0.00000000,9.18750000,0.00000000)
        call Combined(1,7,50,300.75000000,-75.00000000,16.75000000,-1.50000000)
        call Combined(1,6,50,300.75000000,75.00000000,16.75000000,1.50000000)
        call Combined(1,8,50,317.48437500,-150.00000000,16.99218750,-3.00000000)
        call Combined(1,5,50,317.48437500,150.00000000,16.99218750,3.00000000)
        call Combined(1,4,50,239.06250000,-0.00000000,9.37500000,0.00000000)
        call Combined(1,7,51,317.50000000,-76.50000000,16.75000000,-1.50000000)
        call Combined(1,6,51,317.50000000,76.50000000,16.75000000,1.50000000)
        call Combined(1,8,51,334.47656250,-153.00000000,16.99218750,-3.00000000)
        call Combined(1,5,51,334.47656250,153.00000000,16.99218750,3.00000000)
        call Combined(1,4,51,248.62500000,-0.00000000,9.56250000,0.00000000)
        call Combined(1,7,52,334.25000000,-78.00000000,16.75000000,-1.50000000)
        call Combined(1,6,52,334.25000000,78.00000000,16.75000000,1.50000000)
        call Combined(1,8,52,351.46875000,-156.00000000,16.99218750,-3.00000000)
        call Combined(1,5,52,351.46875000,156.00000000,16.99218750,3.00000000)
        call Combined(1,4,52,258.37500000,-0.00000000,9.75000000,0.00000000)
    endmethod
    private static method Batch13 takes nothing returns nothing
        call Combined(1,7,53,351.00000000,-79.50000000,16.75000000,-1.50000000)
        call Combined(1,6,53,351.00000000,79.50000000,16.75000000,1.50000000)
        call Combined(1,4,53,268.31250000,-0.00000000,9.93750000,0.00000000)
        call Combined(1,4,54,278.43750000,-0.00000000,10.12500000,0.00000000)
        call Combined(1,4,55,288.75000000,-0.00000000,10.31250000,0.00000000)
        call Combined(1,4,56,299.25000000,-0.00000000,10.50000000,0.00000000)
        call Combined(1,4,57,309.93750000,-0.00000000,10.68750000,0.00000000)
        call Combined(1,4,58,320.81250000,-0.00000000,10.87500000,0.00000000)
        call Combined(1,4,59,331.87500000,-0.00000000,11.06250000,0.00000000)
        call Combined(1,4,60,343.12500000,-0.00000000,11.25000000,0.00000000)
        call Combined(2,7,1,-5.25000000,-13.12500000,-5.25000000,-13.12500000)
        call Combined(2,6,1,-5.25000000,13.12500000,-5.25000000,13.12500000)
        call Combined(2,8,1,2.37500000,-9.25000000,2.37500000,-9.25000000)
        call Combined(2,5,1,2.37500000,9.25000000,2.37500000,9.25000000)
        call Combined(2,4,1,16.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,2,-9.75000000,-25.37500000,-4.50000000,-12.25000000)
        call Combined(2,6,2,-9.75000000,25.37500000,-4.50000000,12.25000000)
        call Combined(2,8,2,5.12500000,-17.75000000,2.75000000,-8.50000000)
        call Combined(2,5,2,5.12500000,17.75000000,2.75000000,8.50000000)
        call Combined(2,4,2,32.00000000,-0.00000000,16.00000000,0.00000000)
    endmethod
    private static method Batch14 takes nothing returns nothing
        call Combined(2,7,3,-13.50000000,-36.75000000,-3.75000000,-11.37500000)
        call Combined(2,6,3,-13.50000000,36.75000000,-3.75000000,11.37500000)
        call Combined(2,8,3,8.25000000,-25.50000000,3.12500000,-7.75000000)
        call Combined(2,5,3,8.25000000,25.50000000,3.12500000,7.75000000)
        call Combined(2,4,3,48.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,4,-16.50000000,-47.25000000,-3.00000000,-10.50000000)
        call Combined(2,6,4,-16.50000000,47.25000000,-3.00000000,10.50000000)
        call Combined(2,8,4,11.75000000,-32.50000000,3.50000000,-7.00000000)
        call Combined(2,5,4,11.75000000,32.50000000,3.50000000,7.00000000)
        call Combined(2,4,4,64.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,5,-18.75000000,-56.87500000,-2.25000000,-9.62500000)
        call Combined(2,6,5,-18.75000000,56.87500000,-2.25000000,9.62500000)
        call Combined(2,8,5,15.62500000,-38.75000000,3.87500000,-6.25000000)
        call Combined(2,5,5,15.62500000,38.75000000,3.87500000,6.25000000)
        call Combined(2,4,5,80.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,6,-20.25000000,-65.62500000,-1.50000000,-8.75000000)
        call Combined(2,6,6,-20.25000000,65.62500000,-1.50000000,8.75000000)
        call Combined(2,8,6,19.87500000,-44.25000000,4.25000000,-5.50000000)
        call Combined(2,5,6,19.87500000,44.25000000,4.25000000,5.50000000)
        call Combined(2,4,6,96.00000000,-0.00000000,16.00000000,0.00000000)
    endmethod
    private static method Batch15 takes nothing returns nothing
        call Combined(2,7,7,-21.00000000,-73.50000000,-0.75000000,-7.87500000)
        call Combined(2,6,7,-21.00000000,73.50000000,-0.75000000,7.87500000)
        call Combined(2,8,7,24.50000000,-49.00000000,4.62500000,-4.75000000)
        call Combined(2,5,7,24.50000000,49.00000000,4.62500000,4.75000000)
        call Combined(2,4,7,112.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,8,-21.00000000,-80.50000000,0.00000000,-7.00000000)
        call Combined(2,6,8,-21.00000000,80.50000000,0.00000000,7.00000000)
        call Combined(2,8,8,29.50000000,-53.00000000,5.00000000,-4.00000000)
        call Combined(2,5,8,29.50000000,53.00000000,5.00000000,4.00000000)
        call Combined(2,4,8,128.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,9,-20.25000000,-86.62500000,0.75000000,-6.12500000)
        call Combined(2,6,9,-20.25000000,86.62500000,0.75000000,6.12500000)
        call Combined(2,8,9,34.87500000,-56.25000000,5.37500000,-3.25000000)
        call Combined(2,5,9,34.87500000,56.25000000,5.37500000,3.25000000)
        call Combined(2,4,9,144.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,10,-18.75000000,-91.87500000,1.50000000,-5.25000000)
        call Combined(2,6,10,-18.75000000,91.87500000,1.50000000,5.25000000)
        call Combined(2,8,10,40.62500000,-58.75000000,5.75000000,-2.50000000)
        call Combined(2,5,10,40.62500000,58.75000000,5.75000000,2.50000000)
        call Combined(2,4,10,160.00000000,-0.00000000,16.00000000,0.00000000)
    endmethod
    private static method Batch16 takes nothing returns nothing
        call Combined(2,7,11,-16.50000000,-96.25000000,2.25000000,-4.37500000)
        call Combined(2,6,11,-16.50000000,96.25000000,2.25000000,4.37500000)
        call Combined(2,8,11,46.75000000,-60.50000000,6.12500000,-1.75000000)
        call Combined(2,5,11,46.75000000,60.50000000,6.12500000,1.75000000)
        call Combined(2,4,11,176.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,12,-13.50000000,-99.75000000,3.00000000,-3.50000000)
        call Combined(2,6,12,-13.50000000,99.75000000,3.00000000,3.50000000)
        call Combined(2,8,12,53.25000000,-61.50000000,6.50000000,-1.00000000)
        call Combined(2,5,12,53.25000000,61.50000000,6.50000000,1.00000000)
        call Combined(2,4,12,192.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,13,-9.75000000,-102.37500000,3.75000000,-2.62500000)
        call Combined(2,6,13,-9.75000000,102.37500000,3.75000000,2.62500000)
        call Combined(2,8,13,60.12500000,-61.75000000,6.87500000,-0.25000000)
        call Combined(2,5,13,60.12500000,61.75000000,6.87500000,0.25000000)
        call Combined(2,4,13,208.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,14,-5.25000000,-104.12500000,4.50000000,-1.75000000)
        call Combined(2,6,14,-5.25000000,104.12500000,4.50000000,1.75000000)
        call Combined(2,8,14,67.37500000,-61.25000000,7.25000000,0.50000000)
        call Combined(2,5,14,67.37500000,61.25000000,7.25000000,-0.50000000)
        call Combined(2,4,14,224.00000000,-0.00000000,16.00000000,0.00000000)
    endmethod
    private static method Batch17 takes nothing returns nothing
        call Combined(2,7,15,0.00000000,-105.00000000,5.25000000,-0.87500000)
        call Combined(2,6,15,0.00000000,105.00000000,5.25000000,0.87500000)
        call Combined(2,8,15,75.00000000,-60.00000000,7.62500000,1.25000000)
        call Combined(2,5,15,75.00000000,60.00000000,7.62500000,-1.25000000)
        call Combined(2,4,15,240.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,16,6.00000000,-105.00000000,6.00000000,0.00000000)
        call Combined(2,6,16,6.00000000,105.00000000,6.00000000,0.00000000)
        call Combined(2,8,16,83.00000000,-58.00000000,8.00000000,2.00000000)
        call Combined(2,5,16,83.00000000,58.00000000,8.00000000,-2.00000000)
        call Combined(2,4,16,256.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,17,12.75000000,-104.12500000,6.75000000,0.87500000)
        call Combined(2,6,17,12.75000000,104.12500000,6.75000000,-0.87500000)
        call Combined(2,8,17,91.37500000,-55.25000000,8.37500000,2.75000000)
        call Combined(2,5,17,91.37500000,55.25000000,8.37500000,-2.75000000)
        call Combined(2,4,17,272.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,18,20.25000000,-102.37500000,7.50000000,1.75000000)
        call Combined(2,6,18,20.25000000,102.37500000,7.50000000,-1.75000000)
        call Combined(2,8,18,100.12500000,-51.75000000,8.75000000,3.50000000)
        call Combined(2,5,18,100.12500000,51.75000000,8.75000000,-3.50000000)
        call Combined(2,4,18,288.00000000,-0.00000000,16.00000000,0.00000000)
    endmethod
    private static method Batch18 takes nothing returns nothing
        call Combined(2,7,19,28.50000000,-99.75000000,8.25000000,2.62500000)
        call Combined(2,6,19,28.50000000,99.75000000,8.25000000,-2.62500000)
        call Combined(2,8,19,109.25000000,-47.50000000,9.12500000,4.25000000)
        call Combined(2,5,19,109.25000000,47.50000000,9.12500000,-4.25000000)
        call Combined(2,4,19,304.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,20,37.50000000,-96.25000000,9.00000000,3.50000000)
        call Combined(2,6,20,37.50000000,96.25000000,9.00000000,-3.50000000)
        call Combined(2,8,20,118.75000000,-42.50000000,9.50000000,5.00000000)
        call Combined(2,5,20,118.75000000,42.50000000,9.50000000,-5.00000000)
        call Combined(2,4,20,320.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,21,47.25000000,-91.87500000,9.75000000,4.37500000)
        call Combined(2,6,21,47.25000000,91.87500000,9.75000000,-4.37500000)
        call Combined(2,8,21,128.62500000,-36.75000000,9.87500000,5.75000000)
        call Combined(2,5,21,128.62500000,36.75000000,9.87500000,-5.75000000)
        call Combined(2,4,21,336.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,22,57.75000000,-86.62500000,10.50000000,5.25000000)
        call Combined(2,6,22,57.75000000,86.62500000,10.50000000,-5.25000000)
        call Combined(2,8,22,138.87500000,-30.25000000,10.25000000,6.50000000)
        call Combined(2,5,22,138.87500000,30.25000000,10.25000000,-6.50000000)
        call Combined(2,7,23,69.00000000,-80.50000000,11.25000000,6.12500000)
    endmethod
    private static method Batch19 takes nothing returns nothing
        call Combined(2,6,23,69.00000000,80.50000000,11.25000000,-6.12500000)
        call Combined(2,8,23,149.50000000,-23.00000000,10.62500000,7.25000000)
        call Combined(2,5,23,149.50000000,23.00000000,10.62500000,-7.25000000)
        call Combined(2,7,24,81.00000000,-73.50000000,12.00000000,7.00000000)
        call Combined(2,6,24,81.00000000,73.50000000,12.00000000,-7.00000000)
        call Combined(2,8,24,160.50000000,-15.00000000,11.00000000,8.00000000)
        call Combined(2,5,24,160.50000000,15.00000000,11.00000000,-8.00000000)
        call Combined(2,7,25,93.75000000,-65.62500000,12.75000000,7.87500000)
        call Combined(2,6,25,93.75000000,65.62500000,12.75000000,-7.87500000)
        call Combined(2,8,25,171.87500000,-6.25000000,11.37500000,8.75000000)
        call Combined(2,5,25,171.87500000,6.25000000,11.37500000,-8.75000000)
        call Combined(2,7,26,107.25000000,-56.87500000,13.50000000,8.75000000)
        call Combined(2,6,26,107.25000000,56.87500000,13.50000000,-8.75000000)
        call Combined(2,8,26,183.62500000,3.25000000,11.75000000,9.50000000)
        call Combined(2,5,26,183.62500000,-3.25000000,11.75000000,-9.50000000)
        call Combined(2,7,27,121.50000000,-47.25000000,14.25000000,9.62500000)
        call Combined(2,6,27,121.50000000,47.25000000,14.25000000,-9.62500000)
        call Combined(2,8,27,195.75000000,13.50000000,12.12500000,10.25000000)
        call Combined(2,5,27,195.75000000,-13.50000000,12.12500000,-10.25000000)
        call Combined(2,7,28,136.50000000,-36.75000000,15.00000000,10.50000000)
    endmethod
    private static method Batch20 takes nothing returns nothing
        call Combined(2,6,28,136.50000000,36.75000000,15.00000000,-10.50000000)
        call Combined(2,8,28,208.25000000,24.50000000,12.50000000,11.00000000)
        call Combined(2,5,28,208.25000000,-24.50000000,12.50000000,-11.00000000)
        call Combined(2,7,29,152.25000000,-25.37500000,15.75000000,11.37500000)
        call Combined(2,6,29,152.25000000,25.37500000,15.75000000,-11.37500000)
        call Combined(2,8,29,221.12500000,36.25000000,12.87500000,11.75000000)
        call Combined(2,5,29,221.12500000,-36.25000000,12.87500000,-11.75000000)
        call Combined(2,7,30,168.75000000,-13.12500000,16.50000000,12.25000000)
        call Combined(2,6,30,168.75000000,13.12500000,16.50000000,-12.25000000)
        call Combined(2,8,30,234.37500000,48.75000000,13.25000000,12.50000000)
        call Combined(2,5,30,234.37500000,-48.75000000,13.25000000,-12.50000000)
        call Combined(2,7,31,185.50000000,-0.00000000,16.75000000,13.12500000)
        call Combined(2,6,31,185.50000000,-0.00000000,16.75000000,-13.12500000)
        call Combined(2,8,31,248.00000000,62.00000000,13.62500000,13.25000000)
        call Combined(2,5,31,248.00000000,-62.00000000,13.62500000,-13.25000000)
        call Combined(2,7,32,202.25000000,14.00000000,16.75000000,14.00000000)
        call Combined(2,6,32,202.25000000,-14.00000000,16.75000000,-14.00000000)
        call Combined(2,8,32,262.00000000,76.00000000,14.00000000,14.00000000)
        call Combined(2,5,32,262.00000000,-76.00000000,14.00000000,-14.00000000)
        call Combined(2,7,33,219.00000000,28.87500000,16.75000000,14.87500000)
    endmethod
    private static method Batch21 takes nothing returns nothing
        call Combined(2,6,33,219.00000000,-28.87500000,16.75000000,-14.87500000)
        call Combined(2,8,33,276.37500000,90.75000000,14.37500000,14.75000000)
        call Combined(2,5,33,276.37500000,-90.75000000,14.37500000,-14.75000000)
        call Combined(2,7,34,235.75000000,44.62500000,16.75000000,15.75000000)
        call Combined(2,6,34,235.75000000,-44.62500000,16.75000000,-15.75000000)
        call Combined(2,8,34,291.12500000,106.25000000,14.75000000,15.50000000)
        call Combined(2,5,34,291.12500000,-106.25000000,14.75000000,-15.50000000)
        call Combined(2,7,35,252.50000000,61.25000000,16.75000000,16.62500000)
        call Combined(2,6,35,252.50000000,-61.25000000,16.75000000,-16.62500000)
        call Combined(2,8,35,306.25000000,122.50000000,15.12500000,16.25000000)
        call Combined(2,5,35,306.25000000,-122.50000000,15.12500000,-16.25000000)
        call Combined(2,7,36,269.25000000,78.75000000,16.75000000,17.50000000)
        call Combined(2,6,36,269.25000000,-78.75000000,16.75000000,-17.50000000)
        call Combined(2,8,36,321.75000000,139.50000000,15.50000000,17.00000000)
        call Combined(2,5,36,321.75000000,-139.50000000,15.50000000,-17.00000000)
        call Combined(2,7,37,286.00000000,97.12500000,16.75000000,18.37500000)
        call Combined(2,6,37,286.00000000,-97.12500000,16.75000000,-18.37500000)
        call Combined(2,8,37,337.62500000,157.25000000,15.87500000,17.75000000)
        call Combined(2,5,37,337.62500000,-157.25000000,15.87500000,-17.75000000)
        call Combined(2,7,38,302.75000000,116.37500000,16.75000000,19.25000000)
    endmethod
    private static method Batch22 takes nothing returns nothing
        call Combined(2,6,38,302.75000000,-116.37500000,16.75000000,-19.25000000)
        call Combined(2,7,39,319.50000000,136.50000000,16.75000000,20.12500000)
        call Combined(2,6,39,319.50000000,-136.50000000,16.75000000,-20.12500000)
        call Combined(2,7,40,336.25000000,157.50000000,16.75000000,21.00000000)
        call Combined(2,6,40,336.25000000,-157.50000000,16.75000000,-21.00000000)
        call Combined(1,7,1,-11.25000000,-1.50000000,-11.25000000,-1.50000000)
        call Combined(1,6,1,-11.25000000,1.50000000,-11.25000000,1.50000000)
        call Combined(1,8,1,-15.00781250,-3.00000000,-15.00781250,-3.00000000)
        call Combined(1,5,1,-15.00781250,3.00000000,-15.00781250,3.00000000)
        call Combined(1,4,1,0.18750000,-0.00000000,0.18750000,0.00000000)
        call Combined(1,7,2,-21.75000000,-3.00000000,-10.50000000,-1.50000000)
        call Combined(1,6,2,-21.75000000,3.00000000,-10.50000000,1.50000000)
        call Combined(1,8,2,-29.02343750,-6.00000000,-14.01562500,-3.00000000)
        call Combined(1,5,2,-29.02343750,6.00000000,-14.01562500,3.00000000)
        call Combined(1,4,2,0.56250000,-0.00000000,0.37500000,0.00000000)
        call Combined(1,7,3,-31.50000000,-4.50000000,-9.75000000,-1.50000000)
        call Combined(1,6,3,-31.50000000,4.50000000,-9.75000000,1.50000000)
        call Combined(1,8,3,-42.04687500,-9.00000000,-13.02343750,-3.00000000)
        call Combined(1,5,3,-42.04687500,9.00000000,-13.02343750,3.00000000)
        call Combined(1,4,3,1.12500000,-0.00000000,0.56250000,0.00000000)
    endmethod
    private static method Batch23 takes nothing returns nothing
        call Combined(1,7,4,-40.50000000,-6.00000000,-9.00000000,-1.50000000)
        call Combined(1,6,4,-40.50000000,6.00000000,-9.00000000,1.50000000)
        call Combined(1,8,4,-54.07812500,-12.00000000,-12.03125000,-3.00000000)
        call Combined(1,5,4,-54.07812500,12.00000000,-12.03125000,3.00000000)
        call Combined(1,4,4,1.87500000,-0.00000000,0.75000000,0.00000000)
        call Combined(1,7,5,-48.75000000,-7.50000000,-8.25000000,-1.50000000)
        call Combined(1,6,5,-48.75000000,7.50000000,-8.25000000,1.50000000)
        call Combined(1,8,5,-65.11718750,-15.00000000,-11.03906250,-3.00000000)
        call Combined(1,5,5,-65.11718750,15.00000000,-11.03906250,3.00000000)
        call Combined(1,4,5,2.81250000,-0.00000000,0.93750000,0.00000000)
        call Combined(1,7,6,-56.25000000,-9.00000000,-7.50000000,-1.50000000)
        call Combined(1,6,6,-56.25000000,9.00000000,-7.50000000,1.50000000)
        call Combined(1,8,6,-75.16406250,-18.00000000,-10.04687500,-3.00000000)
        call Combined(1,5,6,-75.16406250,18.00000000,-10.04687500,3.00000000)
        call Combined(1,4,6,3.93750000,-0.00000000,1.12500000,0.00000000)
        call Combined(1,7,7,-63.00000000,-10.50000000,-6.75000000,-1.50000000)
        call Combined(1,6,7,-63.00000000,10.50000000,-6.75000000,1.50000000)
        call Combined(1,8,7,-84.21875000,-21.00000000,-9.05468750,-3.00000000)
        call Combined(1,5,7,-84.21875000,21.00000000,-9.05468750,3.00000000)
        call Combined(1,4,7,5.25000000,-0.00000000,1.31250000,0.00000000)
    endmethod
    private static method Batch24 takes nothing returns nothing
        call Combined(1,7,8,-69.00000000,-12.00000000,-6.00000000,-1.50000000)
        call Combined(1,6,8,-69.00000000,12.00000000,-6.00000000,1.50000000)
        call Combined(1,8,8,-92.28125000,-24.00000000,-8.06250000,-3.00000000)
        call Combined(1,5,8,-92.28125000,24.00000000,-8.06250000,3.00000000)
        call Combined(1,4,8,6.75000000,-0.00000000,1.50000000,0.00000000)
        call Combined(1,7,9,-74.25000000,-13.50000000,-5.25000000,-1.50000000)
        call Combined(1,6,9,-74.25000000,13.50000000,-5.25000000,1.50000000)
        call Combined(1,8,9,-99.35156250,-27.00000000,-7.07031250,-3.00000000)
        call Combined(1,5,9,-99.35156250,27.00000000,-7.07031250,3.00000000)
        call Combined(1,4,9,8.43750000,-0.00000000,1.68750000,0.00000000)
        call Combined(1,7,10,-78.75000000,-15.00000000,-4.50000000,-1.50000000)
        call Combined(1,6,10,-78.75000000,15.00000000,-4.50000000,1.50000000)
        call Combined(1,8,10,-105.42968750,-30.00000000,-6.07812500,-3.00000000)
        call Combined(1,5,10,-105.42968750,30.00000000,-6.07812500,3.00000000)
        call Combined(1,4,10,10.31250000,-0.00000000,1.87500000,0.00000000)
        call Combined(1,7,11,-82.50000000,-16.50000000,-3.75000000,-1.50000000)
        call Combined(1,6,11,-82.50000000,16.50000000,-3.75000000,1.50000000)
        call Combined(1,8,11,-110.51562500,-33.00000000,-5.08593750,-3.00000000)
        call Combined(1,5,11,-110.51562500,33.00000000,-5.08593750,3.00000000)
        call Combined(1,4,11,12.37500000,-0.00000000,2.06250000,0.00000000)
    endmethod
    private static method Batch25 takes nothing returns nothing
        call Combined(1,7,12,-85.50000000,-18.00000000,-3.00000000,-1.50000000)
        call Combined(1,6,12,-85.50000000,18.00000000,-3.00000000,1.50000000)
        call Combined(1,8,12,-114.60937500,-36.00000000,-4.09375000,-3.00000000)
        call Combined(1,5,12,-114.60937500,36.00000000,-4.09375000,3.00000000)
        call Combined(1,4,12,14.62500000,-0.00000000,2.25000000,0.00000000)
        call Combined(1,7,13,-87.75000000,-19.50000000,-2.25000000,-1.50000000)
        call Combined(1,6,13,-87.75000000,19.50000000,-2.25000000,1.50000000)
        call Combined(1,8,13,-117.71093750,-39.00000000,-3.10156250,-3.00000000)
        call Combined(1,5,13,-117.71093750,39.00000000,-3.10156250,3.00000000)
        call Combined(1,4,13,17.06250000,-0.00000000,2.43750000,0.00000000)
        call Combined(1,7,14,-89.25000000,-21.00000000,-1.50000000,-1.50000000)
        call Combined(1,6,14,-89.25000000,21.00000000,-1.50000000,1.50000000)
        call Combined(1,8,14,-119.82031250,-42.00000000,-2.10937500,-3.00000000)
        call Combined(1,5,14,-119.82031250,42.00000000,-2.10937500,3.00000000)
        call Combined(1,4,14,19.68750000,-0.00000000,2.62500000,0.00000000)
        call Combined(1,7,15,-90.00000000,-22.50000000,-0.75000000,-1.50000000)
        call Combined(1,6,15,-90.00000000,22.50000000,-0.75000000,1.50000000)
        call Combined(1,8,15,-120.93750000,-45.00000000,-1.11718750,-3.00000000)
        call Combined(1,5,15,-120.93750000,45.00000000,-1.11718750,3.00000000)
        call Combined(1,4,15,22.50000000,-0.00000000,2.81250000,0.00000000)
    endmethod
    private static method Batch26 takes nothing returns nothing
        call Combined(1,7,16,-90.00000000,-24.00000000,-0.00000000,-1.50000000)
        call Combined(1,6,16,-90.00000000,24.00000000,-0.00000000,1.50000000)
        call Combined(1,8,16,-121.06250000,-48.00000000,-0.12500000,-3.00000000)
        call Combined(1,5,16,-121.06250000,48.00000000,-0.12500000,3.00000000)
        call Combined(1,4,16,25.50000000,-0.00000000,3.00000000,0.00000000)
        call Combined(1,7,17,-89.25000000,-25.50000000,0.75000000,-1.50000000)
        call Combined(1,6,17,-89.25000000,25.50000000,0.75000000,1.50000000)
        call Combined(1,8,17,-120.19531250,-51.00000000,0.86718750,-3.00000000)
        call Combined(1,5,17,-120.19531250,51.00000000,0.86718750,3.00000000)
        call Combined(1,4,17,28.68750000,-0.00000000,3.18750000,0.00000000)
        call Combined(1,7,18,-87.75000000,-27.00000000,1.50000000,-1.50000000)
        call Combined(1,6,18,-87.75000000,27.00000000,1.50000000,1.50000000)
        call Combined(1,8,18,-118.33593750,-54.00000000,1.85937500,-3.00000000)
        call Combined(1,5,18,-118.33593750,54.00000000,1.85937500,3.00000000)
        call Combined(1,4,18,32.06250000,-0.00000000,3.37500000,0.00000000)
        call Combined(1,7,19,-85.50000000,-28.50000000,2.25000000,-1.50000000)
        call Combined(1,6,19,-85.50000000,28.50000000,2.25000000,1.50000000)
        call Combined(1,8,19,-115.48437500,-57.00000000,2.85156250,-3.00000000)
        call Combined(1,5,19,-115.48437500,57.00000000,2.85156250,3.00000000)
        call Combined(1,4,19,35.62500000,-0.00000000,3.56250000,0.00000000)
    endmethod
    private static method Batch27 takes nothing returns nothing
        call Combined(1,7,20,-82.50000000,-30.00000000,3.00000000,-1.50000000)
        call Combined(1,6,20,-82.50000000,30.00000000,3.00000000,1.50000000)
        call Combined(1,8,20,-111.64062500,-60.00000000,3.84375000,-3.00000000)
        call Combined(1,5,20,-111.64062500,60.00000000,3.84375000,3.00000000)
        call Combined(1,4,20,39.37500000,-0.00000000,3.75000000,0.00000000)
        call Combined(1,7,21,-78.75000000,-31.50000000,3.75000000,-1.50000000)
        call Combined(1,6,21,-78.75000000,31.50000000,3.75000000,1.50000000)
        call Combined(1,8,21,-106.80468750,-63.00000000,4.83593750,-3.00000000)
        call Combined(1,5,21,-106.80468750,63.00000000,4.83593750,3.00000000)
        call Combined(1,4,21,43.31250000,-0.00000000,3.93750000,0.00000000)
        call Combined(1,7,22,-74.25000000,-33.00000000,4.50000000,-1.50000000)
        call Combined(1,6,22,-74.25000000,33.00000000,4.50000000,1.50000000)
        call Combined(1,8,22,-100.97656250,-66.00000000,5.82812500,-3.00000000)
        call Combined(1,5,22,-100.97656250,66.00000000,5.82812500,3.00000000)
        call Combined(1,4,22,47.43750000,-0.00000000,4.12500000,0.00000000)
        call Combined(1,7,23,-69.00000000,-34.50000000,5.25000000,-1.50000000)
        call Combined(1,6,23,-69.00000000,34.50000000,5.25000000,1.50000000)
        call Combined(1,8,23,-94.15625000,-69.00000000,6.82031250,-3.00000000)
        call Combined(1,5,23,-94.15625000,69.00000000,6.82031250,3.00000000)
        call Combined(1,4,23,51.75000000,-0.00000000,4.31250000,0.00000000)
    endmethod
    private static method Batch28 takes nothing returns nothing
        call Combined(1,7,24,-63.00000000,-36.00000000,6.00000000,-1.50000000)
        call Combined(1,6,24,-63.00000000,36.00000000,6.00000000,1.50000000)
        call Combined(1,8,24,-86.34375000,-72.00000000,7.81250000,-3.00000000)
        call Combined(1,5,24,-86.34375000,72.00000000,7.81250000,3.00000000)
        call Combined(1,4,24,56.25000000,-0.00000000,4.50000000,0.00000000)
        call Combined(1,7,25,-56.25000000,-37.50000000,6.75000000,-1.50000000)
        call Combined(1,6,25,-56.25000000,37.50000000,6.75000000,1.50000000)
        call Combined(1,8,25,-77.53906250,-75.00000000,8.80468750,-3.00000000)
        call Combined(1,5,25,-77.53906250,75.00000000,8.80468750,3.00000000)
        call Combined(1,4,25,60.93750000,-0.00000000,4.68750000,0.00000000)
        call Combined(1,7,26,-48.75000000,-39.00000000,7.50000000,-1.50000000)
        call Combined(1,6,26,-48.75000000,39.00000000,7.50000000,1.50000000)
        call Combined(1,8,26,-67.74218750,-78.00000000,9.79687500,-3.00000000)
        call Combined(1,5,26,-67.74218750,78.00000000,9.79687500,3.00000000)
        call Combined(1,4,26,65.81250000,-0.00000000,4.87500000,0.00000000)
        call Combined(1,7,27,-40.50000000,-40.50000000,8.25000000,-1.50000000)
        call Combined(1,6,27,-40.50000000,40.50000000,8.25000000,1.50000000)
        call Combined(1,8,27,-56.95312500,-81.00000000,10.78906250,-3.00000000)
        call Combined(1,5,27,-56.95312500,81.00000000,10.78906250,3.00000000)
        call Combined(1,4,27,70.87500000,-0.00000000,5.06250000,0.00000000)
    endmethod
    private static method Batch29 takes nothing returns nothing
        call Combined(1,7,28,-31.50000000,-42.00000000,9.00000000,-1.50000000)
        call Combined(1,6,28,-31.50000000,42.00000000,9.00000000,1.50000000)
        call Combined(1,8,28,-45.17187500,-84.00000000,11.78125000,-3.00000000)
        call Combined(1,5,28,-45.17187500,84.00000000,11.78125000,3.00000000)
        call Combined(1,4,28,76.12500000,-0.00000000,5.25000000,0.00000000)
        call Combined(1,7,29,-21.75000000,-43.50000000,9.75000000,-1.50000000)
        call Combined(1,6,29,-21.75000000,43.50000000,9.75000000,1.50000000)
        call Combined(1,8,29,-32.39843750,-87.00000000,12.77343750,-3.00000000)
        call Combined(1,5,29,-32.39843750,87.00000000,12.77343750,3.00000000)
        call Combined(1,4,29,81.56250000,-0.00000000,5.43750000,0.00000000)
        call Combined(1,7,30,-11.25000000,-45.00000000,10.50000000,-1.50000000)
        call Combined(1,6,30,-11.25000000,45.00000000,10.50000000,1.50000000)
        call Combined(1,8,30,-18.63281250,-90.00000000,13.76562500,-3.00000000)
        call Combined(1,5,30,-18.63281250,90.00000000,13.76562500,3.00000000)
        call Combined(1,4,30,87.18750000,-0.00000000,5.62500000,0.00000000)
        call Combined(1,7,31,-0.00000000,-46.50000000,11.25000000,-1.50000000)
        call Combined(1,6,31,-0.00000000,46.50000000,11.25000000,1.50000000)
        call Combined(1,8,31,-3.87500000,-93.00000000,14.75781250,-3.00000000)
        call Combined(1,5,31,-3.87500000,93.00000000,14.75781250,3.00000000)
        call Combined(1,4,31,93.00000000,-0.00000000,5.81250000,0.00000000)
    endmethod
    private static method Batch30 takes nothing returns nothing
        call Combined(1,7,32,12.00000000,-48.00000000,12.00000000,-1.50000000)
        call Combined(1,6,32,12.00000000,48.00000000,12.00000000,1.50000000)
        call Combined(1,8,32,11.87500000,-96.00000000,15.75000000,-3.00000000)
        call Combined(1,5,32,11.87500000,96.00000000,15.75000000,3.00000000)
        call Combined(1,4,32,99.00000000,-0.00000000,6.00000000,0.00000000)
        call Combined(1,7,33,24.75000000,-49.50000000,12.75000000,-1.50000000)
        call Combined(1,6,33,24.75000000,49.50000000,12.75000000,1.50000000)
        call Combined(1,8,33,28.61718750,-99.00000000,16.74218750,-3.00000000)
        call Combined(1,5,33,28.61718750,99.00000000,16.74218750,3.00000000)
        call Combined(1,4,33,105.18750000,-0.00000000,6.18750000,0.00000000)
        call Combined(1,7,34,38.25000000,-51.00000000,13.50000000,-1.50000000)
        call Combined(1,6,34,38.25000000,51.00000000,13.50000000,1.50000000)
        call Combined(1,8,34,45.60937500,-102.00000000,16.99218750,-3.00000000)
        call Combined(1,5,34,45.60937500,102.00000000,16.99218750,3.00000000)
        call Combined(1,4,34,111.56250000,-0.00000000,6.37500000,0.00000000)
        call Combined(1,7,35,52.50000000,-52.50000000,14.25000000,-1.50000000)
        call Combined(1,6,35,52.50000000,52.50000000,14.25000000,1.50000000)
        call Combined(1,8,35,62.60156250,-105.00000000,16.99218750,-3.00000000)
        call Combined(1,5,35,62.60156250,105.00000000,16.99218750,3.00000000)
        call Combined(1,4,35,118.12500000,-0.00000000,6.56250000,0.00000000)
    endmethod
    private static method Batch31 takes nothing returns nothing
        call Combined(1,7,36,67.50000000,-54.00000000,15.00000000,-1.50000000)
        call Combined(1,6,36,67.50000000,54.00000000,15.00000000,1.50000000)
        call Combined(1,8,36,79.59375000,-108.00000000,16.99218750,-3.00000000)
        call Combined(1,5,36,79.59375000,108.00000000,16.99218750,3.00000000)
        call Combined(1,4,36,124.87500000,-0.00000000,6.75000000,0.00000000)
        call Combined(1,7,37,83.25000000,-55.50000000,15.75000000,-1.50000000)
        call Combined(1,6,37,83.25000000,55.50000000,15.75000000,1.50000000)
        call Combined(1,8,37,96.58593750,-111.00000000,16.99218750,-3.00000000)
        call Combined(1,5,37,96.58593750,111.00000000,16.99218750,3.00000000)
        call Combined(1,4,37,131.81250000,-0.00000000,6.93750000,0.00000000)
        call Combined(1,7,38,99.75000000,-57.00000000,16.50000000,-1.50000000)
        call Combined(1,6,38,99.75000000,57.00000000,16.50000000,1.50000000)
        call Combined(1,8,38,113.57812500,-114.00000000,16.99218750,-3.00000000)
        call Combined(1,5,38,113.57812500,114.00000000,16.99218750,3.00000000)
        call Combined(1,4,38,138.93750000,-0.00000000,7.12500000,0.00000000)
        call Combined(1,7,39,116.50000000,-58.50000000,16.75000000,-1.50000000)
        call Combined(1,6,39,116.50000000,58.50000000,16.75000000,1.50000000)
        call Combined(1,8,39,130.57031250,-117.00000000,16.99218750,-3.00000000)
        call Combined(1,5,39,130.57031250,117.00000000,16.99218750,3.00000000)
        call Combined(1,4,39,146.25000000,-0.00000000,7.31250000,0.00000000)
    endmethod
    private static method Batch32 takes nothing returns nothing
        call Combined(1,7,40,133.25000000,-60.00000000,16.75000000,-1.50000000)
        call Combined(1,6,40,133.25000000,60.00000000,16.75000000,1.50000000)
        call Combined(1,8,40,147.56250000,-120.00000000,16.99218750,-3.00000000)
        call Combined(1,5,40,147.56250000,120.00000000,16.99218750,3.00000000)
        call Combined(1,4,40,153.75000000,-0.00000000,7.50000000,0.00000000)
        call Combined(1,7,41,150.00000000,-61.50000000,16.75000000,-1.50000000)
        call Combined(1,6,41,150.00000000,61.50000000,16.75000000,1.50000000)
        call Combined(1,8,41,164.55468750,-123.00000000,16.99218750,-3.00000000)
        call Combined(1,5,41,164.55468750,123.00000000,16.99218750,3.00000000)
        call Combined(1,4,41,161.43750000,-0.00000000,7.68750000,0.00000000)
        call Combined(1,7,42,166.75000000,-63.00000000,16.75000000,-1.50000000)
        call Combined(1,6,42,166.75000000,63.00000000,16.75000000,1.50000000)
        call Combined(1,8,42,181.54687500,-126.00000000,16.99218750,-3.00000000)
        call Combined(1,5,42,181.54687500,126.00000000,16.99218750,3.00000000)
        call Combined(1,4,42,169.31250000,-0.00000000,7.87500000,0.00000000)
        call Combined(1,7,43,183.50000000,-64.50000000,16.75000000,-1.50000000)
        call Combined(1,6,43,183.50000000,64.50000000,16.75000000,1.50000000)
        call Combined(1,8,43,198.53906250,-129.00000000,16.99218750,-3.00000000)
        call Combined(1,5,43,198.53906250,129.00000000,16.99218750,3.00000000)
        call Combined(1,4,43,177.37500000,-0.00000000,8.06250000,0.00000000)
    endmethod
    private static method Batch33 takes nothing returns nothing
        call Combined(1,7,44,200.25000000,-66.00000000,16.75000000,-1.50000000)
        call Combined(1,6,44,200.25000000,66.00000000,16.75000000,1.50000000)
        call Combined(1,8,44,215.53125000,-132.00000000,16.99218750,-3.00000000)
        call Combined(1,5,44,215.53125000,132.00000000,16.99218750,3.00000000)
        call Combined(1,4,44,185.62500000,-0.00000000,8.25000000,0.00000000)
        call Combined(1,7,45,217.00000000,-67.50000000,16.75000000,-1.50000000)
        call Combined(1,6,45,217.00000000,67.50000000,16.75000000,1.50000000)
        call Combined(1,4,45,194.06250000,-0.00000000,8.43750000,0.00000000)
        call Combined(1,4,46,202.68750000,-0.00000000,8.62500000,0.00000000)
        call Combined(1,4,47,211.50000000,-0.00000000,8.81250000,0.00000000)
        call Combined(2,7,1,-5.25000000,-13.12500000,-5.25000000,-13.12500000)
        call Combined(2,6,1,-5.25000000,13.12500000,-5.25000000,13.12500000)
        call Combined(2,8,1,2.37500000,-9.25000000,2.37500000,-9.25000000)
        call Combined(2,5,1,2.37500000,9.25000000,2.37500000,9.25000000)
        call Combined(2,4,1,16.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,2,-9.75000000,-25.37500000,-4.50000000,-12.25000000)
        call Combined(2,6,2,-9.75000000,25.37500000,-4.50000000,12.25000000)
        call Combined(2,8,2,5.12500000,-17.75000000,2.75000000,-8.50000000)
        call Combined(2,5,2,5.12500000,17.75000000,2.75000000,8.50000000)
        call Combined(2,4,2,32.00000000,-0.00000000,16.00000000,0.00000000)
    endmethod
    private static method Batch34 takes nothing returns nothing
        call Combined(2,7,3,-13.50000000,-36.75000000,-3.75000000,-11.37500000)
        call Combined(2,6,3,-13.50000000,36.75000000,-3.75000000,11.37500000)
        call Combined(2,8,3,8.25000000,-25.50000000,3.12500000,-7.75000000)
        call Combined(2,5,3,8.25000000,25.50000000,3.12500000,7.75000000)
        call Combined(2,4,3,48.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,4,-16.50000000,-47.25000000,-3.00000000,-10.50000000)
        call Combined(2,6,4,-16.50000000,47.25000000,-3.00000000,10.50000000)
        call Combined(2,8,4,11.75000000,-32.50000000,3.50000000,-7.00000000)
        call Combined(2,5,4,11.75000000,32.50000000,3.50000000,7.00000000)
        call Combined(2,4,4,64.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,5,-18.75000000,-56.87500000,-2.25000000,-9.62500000)
        call Combined(2,6,5,-18.75000000,56.87500000,-2.25000000,9.62500000)
        call Combined(2,8,5,15.62500000,-38.75000000,3.87500000,-6.25000000)
        call Combined(2,5,5,15.62500000,38.75000000,3.87500000,6.25000000)
        call Combined(2,4,5,80.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,6,-20.25000000,-65.62500000,-1.50000000,-8.75000000)
        call Combined(2,6,6,-20.25000000,65.62500000,-1.50000000,8.75000000)
        call Combined(2,8,6,19.87500000,-44.25000000,4.25000000,-5.50000000)
        call Combined(2,5,6,19.87500000,44.25000000,4.25000000,5.50000000)
        call Combined(2,4,6,96.00000000,-0.00000000,16.00000000,0.00000000)
    endmethod
    private static method Batch35 takes nothing returns nothing
        call Combined(2,7,7,-21.00000000,-73.50000000,-0.75000000,-7.87500000)
        call Combined(2,6,7,-21.00000000,73.50000000,-0.75000000,7.87500000)
        call Combined(2,8,7,24.50000000,-49.00000000,4.62500000,-4.75000000)
        call Combined(2,5,7,24.50000000,49.00000000,4.62500000,4.75000000)
        call Combined(2,4,7,112.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,8,-21.00000000,-80.50000000,-0.00000000,-7.00000000)
        call Combined(2,6,8,-21.00000000,80.50000000,-0.00000000,7.00000000)
        call Combined(2,8,8,29.50000000,-53.00000000,5.00000000,-4.00000000)
        call Combined(2,5,8,29.50000000,53.00000000,5.00000000,4.00000000)
        call Combined(2,4,8,128.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,9,-20.25000000,-86.62500000,0.75000000,-6.12500000)
        call Combined(2,6,9,-20.25000000,86.62500000,0.75000000,6.12500000)
        call Combined(2,8,9,34.87500000,-56.25000000,5.37500000,-3.25000000)
        call Combined(2,5,9,34.87500000,56.25000000,5.37500000,3.25000000)
        call Combined(2,4,9,144.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,10,-18.75000000,-91.87500000,1.50000000,-5.25000000)
        call Combined(2,6,10,-18.75000000,91.87500000,1.50000000,5.25000000)
        call Combined(2,8,10,40.62500000,-58.75000000,5.75000000,-2.50000000)
        call Combined(2,5,10,40.62500000,58.75000000,5.75000000,2.50000000)
        call Combined(2,4,10,160.00000000,-0.00000000,16.00000000,0.00000000)
    endmethod
    private static method Batch36 takes nothing returns nothing
        call Combined(2,7,11,-16.50000000,-96.25000000,2.25000000,-4.37500000)
        call Combined(2,6,11,-16.50000000,96.25000000,2.25000000,4.37500000)
        call Combined(2,8,11,46.75000000,-60.50000000,6.12500000,-1.75000000)
        call Combined(2,5,11,46.75000000,60.50000000,6.12500000,1.75000000)
        call Combined(2,4,11,176.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,12,-13.50000000,-99.75000000,3.00000000,-3.50000000)
        call Combined(2,6,12,-13.50000000,99.75000000,3.00000000,3.50000000)
        call Combined(2,8,12,53.25000000,-61.50000000,6.50000000,-1.00000000)
        call Combined(2,5,12,53.25000000,61.50000000,6.50000000,1.00000000)
        call Combined(2,4,12,192.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,13,-9.75000000,-102.37500000,3.75000000,-2.62500000)
        call Combined(2,6,13,-9.75000000,102.37500000,3.75000000,2.62500000)
        call Combined(2,8,13,60.12500000,-61.75000000,6.87500000,-0.25000000)
        call Combined(2,5,13,60.12500000,61.75000000,6.87500000,0.25000000)
        call Combined(2,4,13,208.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,14,-5.25000000,-104.12500000,4.50000000,-1.75000000)
        call Combined(2,6,14,-5.25000000,104.12500000,4.50000000,1.75000000)
        call Combined(2,8,14,67.37500000,-61.25000000,7.25000000,0.50000000)
        call Combined(2,5,14,67.37500000,61.25000000,7.25000000,-0.50000000)
        call Combined(2,7,15,-0.00000000,-105.00000000,5.25000000,-0.87500000)
    endmethod
    private static method Batch37 takes nothing returns nothing
        call Combined(2,6,15,-0.00000000,105.00000000,5.25000000,0.87500000)
        call Combined(2,8,15,75.00000000,-60.00000000,7.62500000,1.25000000)
        call Combined(2,5,15,75.00000000,60.00000000,7.62500000,-1.25000000)
        call Combined(2,7,16,6.00000000,-105.00000000,6.00000000,0.00000000)
        call Combined(2,6,16,6.00000000,105.00000000,6.00000000,0.00000000)
        call Combined(2,8,16,83.00000000,-58.00000000,8.00000000,2.00000000)
        call Combined(2,5,16,83.00000000,58.00000000,8.00000000,-2.00000000)
        call Combined(2,7,17,12.75000000,-104.12500000,6.75000000,0.87500000)
        call Combined(2,6,17,12.75000000,104.12500000,6.75000000,-0.87500000)
        call Combined(2,8,17,91.37500000,-55.25000000,8.37500000,2.75000000)
        call Combined(2,5,17,91.37500000,55.25000000,8.37500000,-2.75000000)
        call Combined(2,7,18,20.25000000,-102.37500000,7.50000000,1.75000000)
        call Combined(2,6,18,20.25000000,102.37500000,7.50000000,-1.75000000)
        call Combined(2,8,18,100.12500000,-51.75000000,8.75000000,3.50000000)
        call Combined(2,5,18,100.12500000,51.75000000,8.75000000,-3.50000000)
        call Combined(2,7,19,28.50000000,-99.75000000,8.25000000,2.62500000)
        call Combined(2,6,19,28.50000000,99.75000000,8.25000000,-2.62500000)
        call Combined(2,8,19,109.25000000,-47.50000000,9.12500000,4.25000000)
        call Combined(2,5,19,109.25000000,47.50000000,9.12500000,-4.25000000)
        call Combined(2,7,20,37.50000000,-96.25000000,9.00000000,3.50000000)
    endmethod
    private static method Batch38 takes nothing returns nothing
        call Combined(2,6,20,37.50000000,96.25000000,9.00000000,-3.50000000)
        call Combined(2,8,20,118.75000000,-42.50000000,9.50000000,5.00000000)
        call Combined(2,5,20,118.75000000,42.50000000,9.50000000,-5.00000000)
        call Combined(2,7,21,47.25000000,-91.87500000,9.75000000,4.37500000)
        call Combined(2,6,21,47.25000000,91.87500000,9.75000000,-4.37500000)
        call Combined(2,8,21,128.62500000,-36.75000000,9.87500000,5.75000000)
        call Combined(2,5,21,128.62500000,36.75000000,9.87500000,-5.75000000)
        call Combined(2,7,22,57.75000000,-86.62500000,10.50000000,5.25000000)
        call Combined(2,6,22,57.75000000,86.62500000,10.50000000,-5.25000000)
        call Combined(2,8,22,138.87500000,-30.25000000,10.25000000,6.50000000)
        call Combined(2,5,22,138.87500000,30.25000000,10.25000000,-6.50000000)
        call Combined(2,7,23,69.00000000,-80.50000000,11.25000000,6.12500000)
        call Combined(2,6,23,69.00000000,80.50000000,11.25000000,-6.12500000)
        call Combined(2,8,23,149.50000000,-23.00000000,10.62500000,7.25000000)
        call Combined(2,5,23,149.50000000,23.00000000,10.62500000,-7.25000000)
        call Combined(2,7,24,81.00000000,-73.50000000,12.00000000,7.00000000)
        call Combined(2,6,24,81.00000000,73.50000000,12.00000000,-7.00000000)
        call Combined(2,8,24,160.50000000,-15.00000000,11.00000000,8.00000000)
        call Combined(2,5,24,160.50000000,15.00000000,11.00000000,-8.00000000)
        call Combined(2,7,25,93.75000000,-65.62500000,12.75000000,7.87500000)
    endmethod
    private static method Batch39 takes nothing returns nothing
        call Combined(2,6,25,93.75000000,65.62500000,12.75000000,-7.87500000)
        call Combined(2,8,25,171.87500000,-6.25000000,11.37500000,8.75000000)
        call Combined(2,5,25,171.87500000,6.25000000,11.37500000,-8.75000000)
        call Combined(2,7,26,107.25000000,-56.87500000,13.50000000,8.75000000)
        call Combined(2,6,26,107.25000000,56.87500000,13.50000000,-8.75000000)
        call Combined(2,8,26,183.62500000,3.25000000,11.75000000,9.50000000)
        call Combined(2,5,26,183.62500000,-3.25000000,11.75000000,-9.50000000)
        call Combined(2,7,27,121.50000000,-47.25000000,14.25000000,9.62500000)
        call Combined(2,6,27,121.50000000,47.25000000,14.25000000,-9.62500000)
        call Combined(2,8,27,195.75000000,13.50000000,12.12500000,10.25000000)
        call Combined(2,5,27,195.75000000,-13.50000000,12.12500000,-10.25000000)
        call Combined(2,7,28,136.50000000,-36.75000000,15.00000000,10.50000000)
        call Combined(2,6,28,136.50000000,36.75000000,15.00000000,-10.50000000)
        call Combined(2,8,28,208.25000000,24.50000000,12.50000000,11.00000000)
        call Combined(2,5,28,208.25000000,-24.50000000,12.50000000,-11.00000000)
        call Combined(2,7,29,152.25000000,-25.37500000,15.75000000,11.37500000)
        call Combined(2,6,29,152.25000000,25.37500000,15.75000000,-11.37500000)
        call Combined(2,7,30,168.75000000,-13.12500000,16.50000000,12.25000000)
        call Combined(2,6,30,168.75000000,13.12500000,16.50000000,-12.25000000)
        call Combined(2,7,31,185.50000000,-0.00000000,16.75000000,13.12500000)
    endmethod
    private static method Batch40 takes nothing returns nothing
        call Combined(2,6,31,185.50000000,-0.00000000,16.75000000,-13.12500000)
        call Combined(2,7,32,202.25000000,14.00000000,16.75000000,14.00000000)
        call Combined(2,6,32,202.25000000,-14.00000000,16.75000000,-14.00000000)
        call Combined(2,7,33,219.00000000,28.87500000,16.75000000,14.87500000)
        call Combined(2,6,33,219.00000000,-28.87500000,16.75000000,-14.87500000)
        call Combined(1,7,1,-11.25000000,-1.50000000,-11.25000000,-1.50000000)
        call Combined(1,6,1,-11.25000000,1.50000000,-11.25000000,1.50000000)
        call Combined(1,8,1,-15.00781250,-3.00000000,-15.00781250,-3.00000000)
        call Combined(1,5,1,-15.00781250,3.00000000,-15.00781250,3.00000000)
        call Combined(1,4,1,0.18750000,-0.00000000,0.18750000,0.00000000)
        call Combined(1,7,2,-21.75000000,-3.00000000,-10.50000000,-1.50000000)
        call Combined(1,6,2,-21.75000000,3.00000000,-10.50000000,1.50000000)
        call Combined(1,8,2,-29.02343750,-6.00000000,-14.01562500,-3.00000000)
        call Combined(1,5,2,-29.02343750,6.00000000,-14.01562500,3.00000000)
        call Combined(1,4,2,0.56250000,-0.00000000,0.37500000,0.00000000)
        call Combined(1,7,3,-31.50000000,-4.50000000,-9.75000000,-1.50000000)
        call Combined(1,6,3,-31.50000000,4.50000000,-9.75000000,1.50000000)
        call Combined(1,8,3,-42.04687500,-9.00000000,-13.02343750,-3.00000000)
        call Combined(1,5,3,-42.04687500,9.00000000,-13.02343750,3.00000000)
        call Combined(1,4,3,1.12500000,-0.00000000,0.56250000,0.00000000)
    endmethod
    private static method Batch41 takes nothing returns nothing
        call Combined(1,7,4,-40.50000000,-6.00000000,-9.00000000,-1.50000000)
        call Combined(1,6,4,-40.50000000,6.00000000,-9.00000000,1.50000000)
        call Combined(1,8,4,-54.07812500,-12.00000000,-12.03125000,-3.00000000)
        call Combined(1,5,4,-54.07812500,12.00000000,-12.03125000,3.00000000)
        call Combined(1,4,4,1.87500000,-0.00000000,0.75000000,0.00000000)
        call Combined(1,7,5,-48.75000000,-7.50000000,-8.25000000,-1.50000000)
        call Combined(1,6,5,-48.75000000,7.50000000,-8.25000000,1.50000000)
        call Combined(1,8,5,-65.11718750,-15.00000000,-11.03906250,-3.00000000)
        call Combined(1,5,5,-65.11718750,15.00000000,-11.03906250,3.00000000)
        call Combined(1,4,5,2.81250000,-0.00000000,0.93750000,0.00000000)
        call Combined(1,7,6,-56.25000000,-9.00000000,-7.50000000,-1.50000000)
        call Combined(1,6,6,-56.25000000,9.00000000,-7.50000000,1.50000000)
        call Combined(1,8,6,-75.16406250,-18.00000000,-10.04687500,-3.00000000)
        call Combined(1,5,6,-75.16406250,18.00000000,-10.04687500,3.00000000)
        call Combined(1,4,6,3.93750000,-0.00000000,1.12500000,0.00000000)
        call Combined(1,7,7,-63.00000000,-10.50000000,-6.75000000,-1.50000000)
        call Combined(1,6,7,-63.00000000,10.50000000,-6.75000000,1.50000000)
        call Combined(1,8,7,-84.21875000,-21.00000000,-9.05468750,-3.00000000)
        call Combined(1,5,7,-84.21875000,21.00000000,-9.05468750,3.00000000)
        call Combined(1,4,7,5.25000000,-0.00000000,1.31250000,0.00000000)
    endmethod
    private static method Batch42 takes nothing returns nothing
        call Combined(1,7,8,-69.00000000,-12.00000000,-6.00000000,-1.50000000)
        call Combined(1,6,8,-69.00000000,12.00000000,-6.00000000,1.50000000)
        call Combined(1,8,8,-92.28125000,-24.00000000,-8.06250000,-3.00000000)
        call Combined(1,5,8,-92.28125000,24.00000000,-8.06250000,3.00000000)
        call Combined(1,4,8,6.75000000,-0.00000000,1.50000000,0.00000000)
        call Combined(1,7,9,-74.25000000,-13.50000000,-5.25000000,-1.50000000)
        call Combined(1,6,9,-74.25000000,13.50000000,-5.25000000,1.50000000)
        call Combined(1,8,9,-99.35156250,-27.00000000,-7.07031250,-3.00000000)
        call Combined(1,5,9,-99.35156250,27.00000000,-7.07031250,3.00000000)
        call Combined(1,4,9,8.43750000,-0.00000000,1.68750000,0.00000000)
        call Combined(1,7,10,-78.75000000,-15.00000000,-4.50000000,-1.50000000)
        call Combined(1,6,10,-78.75000000,15.00000000,-4.50000000,1.50000000)
        call Combined(1,8,10,-105.42968750,-30.00000000,-6.07812500,-3.00000000)
        call Combined(1,5,10,-105.42968750,30.00000000,-6.07812500,3.00000000)
        call Combined(1,4,10,10.31250000,-0.00000000,1.87500000,0.00000000)
        call Combined(1,7,11,-82.50000000,-16.50000000,-3.75000000,-1.50000000)
        call Combined(1,6,11,-82.50000000,16.50000000,-3.75000000,1.50000000)
        call Combined(1,8,11,-110.51562500,-33.00000000,-5.08593750,-3.00000000)
        call Combined(1,5,11,-110.51562500,33.00000000,-5.08593750,3.00000000)
        call Combined(1,4,11,12.37500000,-0.00000000,2.06250000,0.00000000)
    endmethod
    private static method Batch43 takes nothing returns nothing
        call Combined(1,7,12,-85.50000000,-18.00000000,-3.00000000,-1.50000000)
        call Combined(1,6,12,-85.50000000,18.00000000,-3.00000000,1.50000000)
        call Combined(1,8,12,-114.60937500,-36.00000000,-4.09375000,-3.00000000)
        call Combined(1,5,12,-114.60937500,36.00000000,-4.09375000,3.00000000)
        call Combined(1,4,12,14.62500000,-0.00000000,2.25000000,0.00000000)
        call Combined(1,7,13,-87.75000000,-19.50000000,-2.25000000,-1.50000000)
        call Combined(1,6,13,-87.75000000,19.50000000,-2.25000000,1.50000000)
        call Combined(1,8,13,-117.71093750,-39.00000000,-3.10156250,-3.00000000)
        call Combined(1,5,13,-117.71093750,39.00000000,-3.10156250,3.00000000)
        call Combined(1,4,13,17.06250000,-0.00000000,2.43750000,0.00000000)
        call Combined(1,7,14,-89.25000000,-21.00000000,-1.50000000,-1.50000000)
        call Combined(1,6,14,-89.25000000,21.00000000,-1.50000000,1.50000000)
        call Combined(1,8,14,-119.82031250,-42.00000000,-2.10937500,-3.00000000)
        call Combined(1,5,14,-119.82031250,42.00000000,-2.10937500,3.00000000)
        call Combined(1,4,14,19.68750000,-0.00000000,2.62500000,0.00000000)
        call Combined(1,7,15,-90.00000000,-22.50000000,-0.75000000,-1.50000000)
        call Combined(1,6,15,-90.00000000,22.50000000,-0.75000000,1.50000000)
        call Combined(1,8,15,-120.93750000,-45.00000000,-1.11718750,-3.00000000)
        call Combined(1,5,15,-120.93750000,45.00000000,-1.11718750,3.00000000)
        call Combined(1,4,15,22.50000000,-0.00000000,2.81250000,0.00000000)
    endmethod
    private static method Batch44 takes nothing returns nothing
        call Combined(1,7,16,-90.00000000,-24.00000000,0.00000000,-1.50000000)
        call Combined(1,6,16,-90.00000000,24.00000000,0.00000000,1.50000000)
        call Combined(1,8,16,-121.06250000,-48.00000000,-0.12500000,-3.00000000)
        call Combined(1,5,16,-121.06250000,48.00000000,-0.12500000,3.00000000)
        call Combined(1,4,16,25.50000000,-0.00000000,3.00000000,0.00000000)
        call Combined(1,7,17,-89.25000000,-25.50000000,0.75000000,-1.50000000)
        call Combined(1,6,17,-89.25000000,25.50000000,0.75000000,1.50000000)
        call Combined(1,8,17,-120.19531250,-51.00000000,0.86718750,-3.00000000)
        call Combined(1,5,17,-120.19531250,51.00000000,0.86718750,3.00000000)
        call Combined(1,4,17,28.68750000,-0.00000000,3.18750000,0.00000000)
        call Combined(1,7,18,-87.75000000,-27.00000000,1.50000000,-1.50000000)
        call Combined(1,6,18,-87.75000000,27.00000000,1.50000000,1.50000000)
        call Combined(1,8,18,-118.33593750,-54.00000000,1.85937500,-3.00000000)
        call Combined(1,5,18,-118.33593750,54.00000000,1.85937500,3.00000000)
        call Combined(1,4,18,32.06250000,-0.00000000,3.37500000,0.00000000)
        call Combined(1,7,19,-85.50000000,-28.50000000,2.25000000,-1.50000000)
        call Combined(1,6,19,-85.50000000,28.50000000,2.25000000,1.50000000)
        call Combined(1,8,19,-115.48437500,-57.00000000,2.85156250,-3.00000000)
        call Combined(1,5,19,-115.48437500,57.00000000,2.85156250,3.00000000)
        call Combined(1,4,19,35.62500000,-0.00000000,3.56250000,0.00000000)
    endmethod
    private static method Batch45 takes nothing returns nothing
        call Combined(1,7,20,-82.50000000,-30.00000000,3.00000000,-1.50000000)
        call Combined(1,6,20,-82.50000000,30.00000000,3.00000000,1.50000000)
        call Combined(1,8,20,-111.64062500,-60.00000000,3.84375000,-3.00000000)
        call Combined(1,5,20,-111.64062500,60.00000000,3.84375000,3.00000000)
        call Combined(1,4,20,39.37500000,-0.00000000,3.75000000,0.00000000)
        call Combined(1,7,21,-78.75000000,-31.50000000,3.75000000,-1.50000000)
        call Combined(1,6,21,-78.75000000,31.50000000,3.75000000,1.50000000)
        call Combined(1,8,21,-106.80468750,-63.00000000,4.83593750,-3.00000000)
        call Combined(1,5,21,-106.80468750,63.00000000,4.83593750,3.00000000)
        call Combined(1,4,21,43.31250000,-0.00000000,3.93750000,0.00000000)
        call Combined(1,7,22,-74.25000000,-33.00000000,4.50000000,-1.50000000)
        call Combined(1,6,22,-74.25000000,33.00000000,4.50000000,1.50000000)
        call Combined(1,8,22,-100.97656250,-66.00000000,5.82812500,-3.00000000)
        call Combined(1,5,22,-100.97656250,66.00000000,5.82812500,3.00000000)
        call Combined(1,4,22,47.43750000,-0.00000000,4.12500000,0.00000000)
        call Combined(1,7,23,-69.00000000,-34.50000000,5.25000000,-1.50000000)
        call Combined(1,6,23,-69.00000000,34.50000000,5.25000000,1.50000000)
        call Combined(1,8,23,-94.15625000,-69.00000000,6.82031250,-3.00000000)
        call Combined(1,5,23,-94.15625000,69.00000000,6.82031250,3.00000000)
        call Combined(1,4,23,51.75000000,-0.00000000,4.31250000,0.00000000)
    endmethod
    private static method Batch46 takes nothing returns nothing
        call Combined(1,7,24,-63.00000000,-36.00000000,6.00000000,-1.50000000)
        call Combined(1,6,24,-63.00000000,36.00000000,6.00000000,1.50000000)
        call Combined(1,8,24,-86.34375000,-72.00000000,7.81250000,-3.00000000)
        call Combined(1,5,24,-86.34375000,72.00000000,7.81250000,3.00000000)
        call Combined(1,4,24,56.25000000,-0.00000000,4.50000000,0.00000000)
        call Combined(1,7,25,-56.25000000,-37.50000000,6.75000000,-1.50000000)
        call Combined(1,6,25,-56.25000000,37.50000000,6.75000000,1.50000000)
        call Combined(1,8,25,-77.53906250,-75.00000000,8.80468750,-3.00000000)
        call Combined(1,5,25,-77.53906250,75.00000000,8.80468750,3.00000000)
        call Combined(1,4,25,60.93750000,-0.00000000,4.68750000,0.00000000)
        call Combined(1,7,26,-48.75000000,-39.00000000,7.50000000,-1.50000000)
        call Combined(1,6,26,-48.75000000,39.00000000,7.50000000,1.50000000)
        call Combined(1,8,26,-67.74218750,-78.00000000,9.79687500,-3.00000000)
        call Combined(1,5,26,-67.74218750,78.00000000,9.79687500,3.00000000)
        call Combined(1,4,26,65.81250000,-0.00000000,4.87500000,0.00000000)
        call Combined(1,7,27,-40.50000000,-40.50000000,8.25000000,-1.50000000)
        call Combined(1,6,27,-40.50000000,40.50000000,8.25000000,1.50000000)
        call Combined(1,8,27,-56.95312500,-81.00000000,10.78906250,-3.00000000)
        call Combined(1,5,27,-56.95312500,81.00000000,10.78906250,3.00000000)
        call Combined(1,4,27,70.87500000,-0.00000000,5.06250000,0.00000000)
    endmethod
    private static method Batch47 takes nothing returns nothing
        call Combined(1,7,28,-31.50000000,-42.00000000,9.00000000,-1.50000000)
        call Combined(1,6,28,-31.50000000,42.00000000,9.00000000,1.50000000)
        call Combined(1,8,28,-45.17187500,-84.00000000,11.78125000,-3.00000000)
        call Combined(1,5,28,-45.17187500,84.00000000,11.78125000,3.00000000)
        call Combined(1,4,28,76.12500000,-0.00000000,5.25000000,0.00000000)
        call Combined(1,7,29,-21.75000000,-43.50000000,9.75000000,-1.50000000)
        call Combined(1,6,29,-21.75000000,43.50000000,9.75000000,1.50000000)
        call Combined(1,8,29,-32.39843750,-87.00000000,12.77343750,-3.00000000)
        call Combined(1,5,29,-32.39843750,87.00000000,12.77343750,3.00000000)
        call Combined(1,4,29,81.56250000,-0.00000000,5.43750000,0.00000000)
        call Combined(1,7,30,-11.25000000,-45.00000000,10.50000000,-1.50000000)
        call Combined(1,6,30,-11.25000000,45.00000000,10.50000000,1.50000000)
        call Combined(1,8,30,-18.63281250,-90.00000000,13.76562500,-3.00000000)
        call Combined(1,5,30,-18.63281250,90.00000000,13.76562500,3.00000000)
        call Combined(1,4,30,87.18750000,-0.00000000,5.62500000,0.00000000)
        call Combined(1,7,31,0.00000000,-46.50000000,11.25000000,-1.50000000)
        call Combined(1,6,31,0.00000000,46.50000000,11.25000000,1.50000000)
        call Combined(1,8,31,-3.87500000,-93.00000000,14.75781250,-3.00000000)
        call Combined(1,5,31,-3.87500000,93.00000000,14.75781250,3.00000000)
        call Combined(1,4,31,93.00000000,-0.00000000,5.81250000,0.00000000)
    endmethod
    private static method Batch48 takes nothing returns nothing
        call Combined(1,7,32,12.00000000,-48.00000000,12.00000000,-1.50000000)
        call Combined(1,6,32,12.00000000,48.00000000,12.00000000,1.50000000)
        call Combined(1,8,32,11.87500000,-96.00000000,15.75000000,-3.00000000)
        call Combined(1,5,32,11.87500000,96.00000000,15.75000000,3.00000000)
        call Combined(1,4,32,99.00000000,-0.00000000,6.00000000,0.00000000)
        call Combined(1,7,33,24.75000000,-49.50000000,12.75000000,-1.50000000)
        call Combined(1,6,33,24.75000000,49.50000000,12.75000000,1.50000000)
        call Combined(1,8,33,28.61718750,-99.00000000,16.74218750,-3.00000000)
        call Combined(1,5,33,28.61718750,99.00000000,16.74218750,3.00000000)
        call Combined(1,4,33,105.18750000,-0.00000000,6.18750000,0.00000000)
        call Combined(1,7,34,38.25000000,-51.00000000,13.50000000,-1.50000000)
        call Combined(1,6,34,38.25000000,51.00000000,13.50000000,1.50000000)
        call Combined(1,8,34,45.60937500,-102.00000000,16.99218750,-3.00000000)
        call Combined(1,5,34,45.60937500,102.00000000,16.99218750,3.00000000)
        call Combined(1,4,34,111.56250000,-0.00000000,6.37500000,0.00000000)
        call Combined(1,7,35,52.50000000,-52.50000000,14.25000000,-1.50000000)
        call Combined(1,6,35,52.50000000,52.50000000,14.25000000,1.50000000)
        call Combined(1,8,35,62.60156250,-105.00000000,16.99218750,-3.00000000)
        call Combined(1,5,35,62.60156250,105.00000000,16.99218750,3.00000000)
        call Combined(1,4,35,118.12500000,-0.00000000,6.56250000,0.00000000)
    endmethod
    private static method Batch49 takes nothing returns nothing
        call Combined(1,7,36,67.50000000,-54.00000000,15.00000000,-1.50000000)
        call Combined(1,6,36,67.50000000,54.00000000,15.00000000,1.50000000)
        call Combined(1,8,36,79.59375000,-108.00000000,16.99218750,-3.00000000)
        call Combined(1,5,36,79.59375000,108.00000000,16.99218750,3.00000000)
        call Combined(1,4,36,124.87500000,-0.00000000,6.75000000,0.00000000)
        call Combined(1,7,37,83.25000000,-55.50000000,15.75000000,-1.50000000)
        call Combined(1,6,37,83.25000000,55.50000000,15.75000000,1.50000000)
        call Combined(1,8,37,96.58593750,-111.00000000,16.99218750,-3.00000000)
        call Combined(1,5,37,96.58593750,111.00000000,16.99218750,3.00000000)
        call Combined(1,4,37,131.81250000,-0.00000000,6.93750000,0.00000000)
        call Combined(1,7,38,99.75000000,-57.00000000,16.50000000,-1.50000000)
        call Combined(1,6,38,99.75000000,57.00000000,16.50000000,1.50000000)
        call Combined(1,8,38,113.57812500,-114.00000000,16.99218750,-3.00000000)
        call Combined(1,5,38,113.57812500,114.00000000,16.99218750,3.00000000)
        call Combined(1,4,38,138.93750000,-0.00000000,7.12500000,0.00000000)
        call Combined(1,7,39,116.50000000,-58.50000000,16.75000000,-1.50000000)
        call Combined(1,6,39,116.50000000,58.50000000,16.75000000,1.50000000)
        call Combined(1,8,39,130.57031250,-117.00000000,16.99218750,-3.00000000)
        call Combined(1,5,39,130.57031250,117.00000000,16.99218750,3.00000000)
        call Combined(1,4,39,146.25000000,-0.00000000,7.31250000,0.00000000)
    endmethod
    private static method Batch50 takes nothing returns nothing
        call Combined(1,7,40,133.25000000,-60.00000000,16.75000000,-1.50000000)
        call Combined(1,6,40,133.25000000,60.00000000,16.75000000,1.50000000)
        call Combined(1,8,40,147.56250000,-120.00000000,16.99218750,-3.00000000)
        call Combined(1,5,40,147.56250000,120.00000000,16.99218750,3.00000000)
        call Combined(1,4,40,153.75000000,-0.00000000,7.50000000,0.00000000)
        call Combined(1,7,41,150.00000000,-61.50000000,16.75000000,-1.50000000)
        call Combined(1,6,41,150.00000000,61.50000000,16.75000000,1.50000000)
        call Combined(1,8,41,164.55468750,-123.00000000,16.99218750,-3.00000000)
        call Combined(1,5,41,164.55468750,123.00000000,16.99218750,3.00000000)
        call Combined(1,4,41,161.43750000,-0.00000000,7.68750000,0.00000000)
        call Combined(1,7,42,166.75000000,-63.00000000,16.75000000,-1.50000000)
        call Combined(1,6,42,166.75000000,63.00000000,16.75000000,1.50000000)
        call Combined(1,8,42,181.54687500,-126.00000000,16.99218750,-3.00000000)
        call Combined(1,5,42,181.54687500,126.00000000,16.99218750,3.00000000)
        call Combined(1,4,42,169.31250000,-0.00000000,7.87500000,0.00000000)
        call Combined(1,7,43,183.50000000,-64.50000000,16.75000000,-1.50000000)
        call Combined(1,6,43,183.50000000,64.50000000,16.75000000,1.50000000)
        call Combined(1,8,43,198.53906250,-129.00000000,16.99218750,-3.00000000)
        call Combined(1,5,43,198.53906250,129.00000000,16.99218750,3.00000000)
        call Combined(1,4,43,177.37500000,-0.00000000,8.06250000,0.00000000)
    endmethod
    private static method Batch51 takes nothing returns nothing
        call Combined(1,7,44,200.25000000,-66.00000000,16.75000000,-1.50000000)
        call Combined(1,6,44,200.25000000,66.00000000,16.75000000,1.50000000)
        call Combined(1,8,44,215.53125000,-132.00000000,16.99218750,-3.00000000)
        call Combined(1,5,44,215.53125000,132.00000000,16.99218750,3.00000000)
        call Combined(1,4,44,185.62500000,-0.00000000,8.25000000,0.00000000)
        call Combined(1,7,45,217.00000000,-67.50000000,16.75000000,-1.50000000)
        call Combined(1,6,45,217.00000000,67.50000000,16.75000000,1.50000000)
        call Combined(1,8,45,232.52343750,-135.00000000,16.99218750,-3.00000000)
        call Combined(1,5,45,232.52343750,135.00000000,16.99218750,3.00000000)
        call Combined(1,4,45,194.06250000,-0.00000000,8.43750000,0.00000000)
        call Combined(1,7,46,233.75000000,-69.00000000,16.75000000,-1.50000000)
        call Combined(1,6,46,233.75000000,69.00000000,16.75000000,1.50000000)
        call Combined(1,8,46,249.51562500,-138.00000000,16.99218750,-3.00000000)
        call Combined(1,5,46,249.51562500,138.00000000,16.99218750,3.00000000)
        call Combined(1,4,46,202.68750000,-0.00000000,8.62500000,0.00000000)
        call Combined(1,7,47,250.50000000,-70.50000000,16.75000000,-1.50000000)
        call Combined(1,6,47,250.50000000,70.50000000,16.75000000,1.50000000)
        call Combined(1,8,47,266.50781250,-141.00000000,16.99218750,-3.00000000)
        call Combined(1,5,47,266.50781250,141.00000000,16.99218750,3.00000000)
        call Combined(1,4,47,211.50000000,-0.00000000,8.81250000,0.00000000)
    endmethod
    private static method Batch52 takes nothing returns nothing
        call Combined(1,7,48,267.25000000,-72.00000000,16.75000000,-1.50000000)
        call Combined(1,6,48,267.25000000,72.00000000,16.75000000,1.50000000)
        call Combined(1,8,48,283.50000000,-144.00000000,16.99218750,-3.00000000)
        call Combined(1,5,48,283.50000000,144.00000000,16.99218750,3.00000000)
        call Combined(1,4,48,220.50000000,-0.00000000,9.00000000,0.00000000)
        call Combined(1,7,49,284.00000000,-73.50000000,16.75000000,-1.50000000)
        call Combined(1,6,49,284.00000000,73.50000000,16.75000000,1.50000000)
        call Combined(1,8,49,300.49218750,-147.00000000,16.99218750,-3.00000000)
        call Combined(1,5,49,300.49218750,147.00000000,16.99218750,3.00000000)
        call Combined(1,4,49,229.68750000,-0.00000000,9.18750000,0.00000000)
        call Combined(1,7,50,300.75000000,-75.00000000,16.75000000,-1.50000000)
        call Combined(1,6,50,300.75000000,75.00000000,16.75000000,1.50000000)
        call Combined(1,4,50,239.06250000,-0.00000000,9.37500000,0.00000000)
        call Combined(1,4,51,248.62500000,-0.00000000,9.56250000,0.00000000)
        call Combined(1,4,52,258.37500000,-0.00000000,9.75000000,0.00000000)
        call Combined(1,4,53,268.31250000,-0.00000000,9.93750000,0.00000000)
        call Combined(1,4,54,278.43750000,-0.00000000,10.12500000,0.00000000)
        call Combined(1,4,55,288.75000000,-0.00000000,10.31250000,0.00000000)
        call Combined(2,7,1,-5.25000000,-13.12500000,-5.25000000,-13.12500000)
        call Combined(2,6,1,-5.25000000,13.12500000,-5.25000000,13.12500000)
    endmethod
    private static method Batch53 takes nothing returns nothing
        call Combined(2,8,1,2.37500000,-9.25000000,2.37500000,-9.25000000)
        call Combined(2,5,1,2.37500000,9.25000000,2.37500000,9.25000000)
        call Combined(2,4,1,16.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,2,-9.75000000,-25.37500000,-4.50000000,-12.25000000)
        call Combined(2,6,2,-9.75000000,25.37500000,-4.50000000,12.25000000)
        call Combined(2,8,2,5.12500000,-17.75000000,2.75000000,-8.50000000)
        call Combined(2,5,2,5.12500000,17.75000000,2.75000000,8.50000000)
        call Combined(2,4,2,32.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,3,-13.50000000,-36.75000000,-3.75000000,-11.37500000)
        call Combined(2,6,3,-13.50000000,36.75000000,-3.75000000,11.37500000)
        call Combined(2,8,3,8.25000000,-25.50000000,3.12500000,-7.75000000)
        call Combined(2,5,3,8.25000000,25.50000000,3.12500000,7.75000000)
        call Combined(2,4,3,48.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,4,-16.50000000,-47.25000000,-3.00000000,-10.50000000)
        call Combined(2,6,4,-16.50000000,47.25000000,-3.00000000,10.50000000)
        call Combined(2,8,4,11.75000000,-32.50000000,3.50000000,-7.00000000)
        call Combined(2,5,4,11.75000000,32.50000000,3.50000000,7.00000000)
        call Combined(2,4,4,64.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,5,-18.75000000,-56.87500000,-2.25000000,-9.62500000)
        call Combined(2,6,5,-18.75000000,56.87500000,-2.25000000,9.62500000)
    endmethod
    private static method Batch54 takes nothing returns nothing
        call Combined(2,8,5,15.62500000,-38.75000000,3.87500000,-6.25000000)
        call Combined(2,5,5,15.62500000,38.75000000,3.87500000,6.25000000)
        call Combined(2,4,5,80.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,6,-20.25000000,-65.62500000,-1.50000000,-8.75000000)
        call Combined(2,6,6,-20.25000000,65.62500000,-1.50000000,8.75000000)
        call Combined(2,8,6,19.87500000,-44.25000000,4.25000000,-5.50000000)
        call Combined(2,5,6,19.87500000,44.25000000,4.25000000,5.50000000)
        call Combined(2,4,6,96.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,7,-21.00000000,-73.50000000,-0.75000000,-7.87500000)
        call Combined(2,6,7,-21.00000000,73.50000000,-0.75000000,7.87500000)
        call Combined(2,8,7,24.50000000,-49.00000000,4.62500000,-4.75000000)
        call Combined(2,5,7,24.50000000,49.00000000,4.62500000,4.75000000)
        call Combined(2,4,7,112.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,8,-21.00000000,-80.50000000,0.00000000,-7.00000000)
        call Combined(2,6,8,-21.00000000,80.50000000,0.00000000,7.00000000)
        call Combined(2,8,8,29.50000000,-53.00000000,5.00000000,-4.00000000)
        call Combined(2,5,8,29.50000000,53.00000000,5.00000000,4.00000000)
        call Combined(2,4,8,128.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,9,-20.25000000,-86.62500000,0.75000000,-6.12500000)
        call Combined(2,6,9,-20.25000000,86.62500000,0.75000000,6.12500000)
    endmethod
    private static method Batch55 takes nothing returns nothing
        call Combined(2,8,9,34.87500000,-56.25000000,5.37500000,-3.25000000)
        call Combined(2,5,9,34.87500000,56.25000000,5.37500000,3.25000000)
        call Combined(2,4,9,144.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,10,-18.75000000,-91.87500000,1.50000000,-5.25000000)
        call Combined(2,6,10,-18.75000000,91.87500000,1.50000000,5.25000000)
        call Combined(2,8,10,40.62500000,-58.75000000,5.75000000,-2.50000000)
        call Combined(2,5,10,40.62500000,58.75000000,5.75000000,2.50000000)
        call Combined(2,4,10,160.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,11,-16.50000000,-96.25000000,2.25000000,-4.37500000)
        call Combined(2,6,11,-16.50000000,96.25000000,2.25000000,4.37500000)
        call Combined(2,8,11,46.75000000,-60.50000000,6.12500000,-1.75000000)
        call Combined(2,5,11,46.75000000,60.50000000,6.12500000,1.75000000)
        call Combined(2,4,11,176.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,12,-13.50000000,-99.75000000,3.00000000,-3.50000000)
        call Combined(2,6,12,-13.50000000,99.75000000,3.00000000,3.50000000)
        call Combined(2,8,12,53.25000000,-61.50000000,6.50000000,-1.00000000)
        call Combined(2,5,12,53.25000000,61.50000000,6.50000000,1.00000000)
        call Combined(2,4,12,192.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,13,-9.75000000,-102.37500000,3.75000000,-2.62500000)
        call Combined(2,6,13,-9.75000000,102.37500000,3.75000000,2.62500000)
    endmethod
    private static method Batch56 takes nothing returns nothing
        call Combined(2,8,13,60.12500000,-61.75000000,6.87500000,-0.25000000)
        call Combined(2,5,13,60.12500000,61.75000000,6.87500000,0.25000000)
        call Combined(2,4,13,208.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,14,-5.25000000,-104.12500000,4.50000000,-1.75000000)
        call Combined(2,6,14,-5.25000000,104.12500000,4.50000000,1.75000000)
        call Combined(2,8,14,67.37500000,-61.25000000,7.25000000,0.50000000)
        call Combined(2,5,14,67.37500000,61.25000000,7.25000000,-0.50000000)
        call Combined(2,4,14,224.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,15,0.00000000,-105.00000000,5.25000000,-0.87500000)
        call Combined(2,6,15,0.00000000,105.00000000,5.25000000,0.87500000)
        call Combined(2,8,15,75.00000000,-60.00000000,7.62500000,1.25000000)
        call Combined(2,5,15,75.00000000,60.00000000,7.62500000,-1.25000000)
        call Combined(2,4,15,240.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,16,6.00000000,-105.00000000,6.00000000,0.00000000)
        call Combined(2,6,16,6.00000000,105.00000000,6.00000000,0.00000000)
        call Combined(2,8,16,83.00000000,-58.00000000,8.00000000,2.00000000)
        call Combined(2,5,16,83.00000000,58.00000000,8.00000000,-2.00000000)
        call Combined(2,4,16,256.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,17,12.75000000,-104.12500000,6.75000000,0.87500000)
        call Combined(2,6,17,12.75000000,104.12500000,6.75000000,-0.87500000)
    endmethod
    private static method Batch57 takes nothing returns nothing
        call Combined(2,8,17,91.37500000,-55.25000000,8.37500000,2.75000000)
        call Combined(2,5,17,91.37500000,55.25000000,8.37500000,-2.75000000)
        call Combined(2,4,17,272.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,18,20.25000000,-102.37500000,7.50000000,1.75000000)
        call Combined(2,6,18,20.25000000,102.37500000,7.50000000,-1.75000000)
        call Combined(2,8,18,100.12500000,-51.75000000,8.75000000,3.50000000)
        call Combined(2,5,18,100.12500000,51.75000000,8.75000000,-3.50000000)
        call Combined(2,4,18,288.00000000,-0.00000000,16.00000000,0.00000000)
        call Combined(2,7,19,28.50000000,-99.75000000,8.25000000,2.62500000)
        call Combined(2,6,19,28.50000000,99.75000000,8.25000000,-2.62500000)
        call Combined(2,8,19,109.25000000,-47.50000000,9.12500000,4.25000000)
        call Combined(2,5,19,109.25000000,47.50000000,9.12500000,-4.25000000)
        call Combined(2,7,20,37.50000000,-96.25000000,9.00000000,3.50000000)
        call Combined(2,6,20,37.50000000,96.25000000,9.00000000,-3.50000000)
        call Combined(2,8,20,118.75000000,-42.50000000,9.50000000,5.00000000)
        call Combined(2,5,20,118.75000000,42.50000000,9.50000000,-5.00000000)
        call Combined(2,7,21,47.25000000,-91.87500000,9.75000000,4.37500000)
        call Combined(2,6,21,47.25000000,91.87500000,9.75000000,-4.37500000)
        call Combined(2,8,21,128.62500000,-36.75000000,9.87500000,5.75000000)
        call Combined(2,5,21,128.62500000,36.75000000,9.87500000,-5.75000000)
    endmethod
    private static method Batch58 takes nothing returns nothing
        call Combined(2,7,22,57.75000000,-86.62500000,10.50000000,5.25000000)
        call Combined(2,6,22,57.75000000,86.62500000,10.50000000,-5.25000000)
        call Combined(2,8,22,138.87500000,-30.25000000,10.25000000,6.50000000)
        call Combined(2,5,22,138.87500000,30.25000000,10.25000000,-6.50000000)
        call Combined(2,7,23,69.00000000,-80.50000000,11.25000000,6.12500000)
        call Combined(2,6,23,69.00000000,80.50000000,11.25000000,-6.12500000)
        call Combined(2,8,23,149.50000000,-23.00000000,10.62500000,7.25000000)
        call Combined(2,5,23,149.50000000,23.00000000,10.62500000,-7.25000000)
        call Combined(2,7,24,81.00000000,-73.50000000,12.00000000,7.00000000)
        call Combined(2,6,24,81.00000000,73.50000000,12.00000000,-7.00000000)
        call Combined(2,8,24,160.50000000,-15.00000000,11.00000000,8.00000000)
        call Combined(2,5,24,160.50000000,15.00000000,11.00000000,-8.00000000)
        call Combined(2,7,25,93.75000000,-65.62500000,12.75000000,7.87500000)
        call Combined(2,6,25,93.75000000,65.62500000,12.75000000,-7.87500000)
        call Combined(2,8,25,171.87500000,-6.25000000,11.37500000,8.75000000)
        call Combined(2,5,25,171.87500000,6.25000000,11.37500000,-8.75000000)
        call Combined(2,7,26,107.25000000,-56.87500000,13.50000000,8.75000000)
        call Combined(2,6,26,107.25000000,56.87500000,13.50000000,-8.75000000)
        call Combined(2,8,26,183.62500000,3.25000000,11.75000000,9.50000000)
        call Combined(2,5,26,183.62500000,-3.25000000,11.75000000,-9.50000000)
    endmethod
    private static method Batch59 takes nothing returns nothing
        call Combined(2,7,27,121.50000000,-47.25000000,14.25000000,9.62500000)
        call Combined(2,6,27,121.50000000,47.25000000,14.25000000,-9.62500000)
        call Combined(2,8,27,195.75000000,13.50000000,12.12500000,10.25000000)
        call Combined(2,5,27,195.75000000,-13.50000000,12.12500000,-10.25000000)
        call Combined(2,7,28,136.50000000,-36.75000000,15.00000000,10.50000000)
        call Combined(2,6,28,136.50000000,36.75000000,15.00000000,-10.50000000)
        call Combined(2,8,28,208.25000000,24.50000000,12.50000000,11.00000000)
        call Combined(2,5,28,208.25000000,-24.50000000,12.50000000,-11.00000000)
        call Combined(2,7,29,152.25000000,-25.37500000,15.75000000,11.37500000)
        call Combined(2,6,29,152.25000000,25.37500000,15.75000000,-11.37500000)
        call Combined(2,8,29,221.12500000,36.25000000,12.87500000,11.75000000)
        call Combined(2,5,29,221.12500000,-36.25000000,12.87500000,-11.75000000)
        call Combined(2,7,30,168.75000000,-13.12500000,16.50000000,12.25000000)
        call Combined(2,6,30,168.75000000,13.12500000,16.50000000,-12.25000000)
        call Combined(2,8,30,234.37500000,48.75000000,13.25000000,12.50000000)
        call Combined(2,5,30,234.37500000,-48.75000000,13.25000000,-12.50000000)
        call Combined(2,7,31,185.50000000,-0.00000000,16.75000000,13.12500000)
        call Combined(2,6,31,185.50000000,-0.00000000,16.75000000,-13.12500000)
        call Combined(2,8,31,248.00000000,62.00000000,13.62500000,13.25000000)
        call Combined(2,5,31,248.00000000,-62.00000000,13.62500000,-13.25000000)
    endmethod
    private static method Batch60 takes nothing returns nothing
        call Combined(2,7,32,202.25000000,14.00000000,16.75000000,14.00000000)
        call Combined(2,6,32,202.25000000,-14.00000000,16.75000000,-14.00000000)
        call Combined(2,8,32,262.00000000,76.00000000,14.00000000,14.00000000)
        call Combined(2,5,32,262.00000000,-76.00000000,14.00000000,-14.00000000)
        call Combined(2,7,33,219.00000000,28.87500000,16.75000000,14.87500000)
        call Combined(2,6,33,219.00000000,-28.87500000,16.75000000,-14.87500000)
        call Combined(2,8,33,276.37500000,90.75000000,14.37500000,14.75000000)
        call Combined(2,5,33,276.37500000,-90.75000000,14.37500000,-14.75000000)
        call Combined(2,7,34,235.75000000,44.62500000,16.75000000,15.75000000)
        call Combined(2,6,34,235.75000000,-44.62500000,16.75000000,-15.75000000)
        call Combined(2,8,34,291.12500000,106.25000000,14.75000000,15.50000000)
        call Combined(2,5,34,291.12500000,-106.25000000,14.75000000,-15.50000000)
        call Combined(2,7,35,252.50000000,61.25000000,16.75000000,16.62500000)
        call Combined(2,6,35,252.50000000,-61.25000000,16.75000000,-16.62500000)
        call Combined(2,7,36,269.25000000,78.75000000,16.75000000,17.50000000)
        call Combined(2,6,36,269.25000000,-78.75000000,16.75000000,-17.50000000)
        call Combined(2,7,37,286.00000000,97.12500000,16.75000000,18.37500000)
        call Combined(2,6,37,286.00000000,-97.12500000,16.75000000,-18.37500000)
        call Combined(2,7,38,302.75000000,116.37500000,16.75000000,19.25000000)
        call Combined(2,6,38,302.75000000,-116.37500000,16.75000000,-19.25000000)
    endmethod
    private static method Batch61 takes nothing returns nothing
        call Scalar(X3Kinematics.forward(1,1,I2R(1)/X3Kinematics.FPS),1.06250000)
        call Orb(9,1,1.00000000,-10.00000000)
        call Orb(2,1,17.00000000,-12.00000000)
        call Orb(1,1,9.00000000,8.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(2)/X3Kinematics.FPS),2.18750000)
        call Orb(9,2,1.00000000,2.00000000)
        call Orb(2,2,17.00000000,-16.00000000)
        call Orb(1,2,9.00000000,-4.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(3)/X3Kinematics.FPS),3.37500000)
        call Orb(9,3,3.00000000,8.00000000)
        call Orb(2,3,19.00000000,-18.00000000)
        call Orb(1,3,11.00000000,-10.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(4)/X3Kinematics.FPS),4.62500000)
        call Orb(9,4,3.00000000,14.00000000)
        call Orb(2,4,19.00000000,-16.00000000)
        call Orb(1,4,11.00000000,-16.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(5)/X3Kinematics.FPS),5.93750000)
        call Orb(9,5,5.00000000,26.00000000)
        call Orb(2,5,21.00000000,-12.00000000)
        call Orb(1,5,13.00000000,-28.00000000)
    endmethod
    private static method Batch62 takes nothing returns nothing
        call Scalar(X3Kinematics.forward(1,1,I2R(6)/X3Kinematics.FPS),7.31250000)
        call Orb(9,6,7.00000000,30.00000000)
        call Orb(2,6,23.00000000,-0.00000000)
        call Orb(1,6,15.00000000,-32.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(7)/X3Kinematics.FPS),8.75000000)
        call Orb(9,7,7.00000000,32.00000000)
        call Orb(2,7,23.00000000,6.00000000)
        call Orb(1,7,15.00000000,-34.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(8)/X3Kinematics.FPS),10.25000000)
        call Orb(9,8,9.00000000,30.00000000)
        call Orb(2,8,25.00000000,12.00000000)
        call Orb(1,8,17.00000000,-32.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(9)/X3Kinematics.FPS),11.81250000)
        call Orb(9,9,11.00000000,26.00000000)
        call Orb(2,9,27.00000000,24.00000000)
        call Orb(1,9,19.00000000,-28.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(10)/X3Kinematics.FPS),13.43750000)
        call Orb(9,10,13.00000000,14.00000000)
        call Orb(2,10,29.00000000,28.00000000)
        call Orb(1,10,21.00000000,-16.00000000)
    endmethod
    private static method Batch63 takes nothing returns nothing
        call Scalar(X3Kinematics.forward(1,1,I2R(11)/X3Kinematics.FPS),15.12500000)
        call Orb(9,11,15.00000000,8.00000000)
        call Orb(2,11,31.00000000,30.00000000)
        call Orb(1,11,23.00000000,-10.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(12)/X3Kinematics.FPS),16.87500000)
        call Orb(9,12,15.00000000,2.00000000)
        call Orb(2,12,31.00000000,28.00000000)
        call Orb(1,12,23.00000000,-4.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(13)/X3Kinematics.FPS),18.68750000)
        call Orb(9,13,17.00000000,-10.00000000)
        call Orb(2,13,33.00000000,24.00000000)
        call Orb(1,13,25.00000000,8.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(14)/X3Kinematics.FPS),20.56250000)
        call Orb(9,14,19.00000000,-14.00000000)
        call Orb(2,14,35.00000000,12.00000000)
        call Orb(1,14,27.00000000,12.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(15)/X3Kinematics.FPS),22.50000000)
        call Orb(9,15,21.00000000,-16.00000000)
        call Orb(2,15,37.00000000,6.00000000)
        call Orb(1,15,29.00000000,14.00000000)
    endmethod
    private static method Batch64 takes nothing returns nothing
        call Scalar(X3Kinematics.forward(1,1,I2R(16)/X3Kinematics.FPS),24.93750000)
        call Orb(9,16,23.00000000,-14.00000000)
        call Orb(2,16,39.00000000,-0.00000000)
        call Orb(1,16,31.00000000,12.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(17)/X3Kinematics.FPS),27.87500000)
        call Orb(9,17,27.00000000,-10.00000000)
        call Orb(2,17,43.00000000,-12.00000000)
        call Orb(1,17,35.00000000,8.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(18)/X3Kinematics.FPS),31.31250000)
        call Orb(9,18,31.00000000,2.00000000)
        call Orb(2,18,47.00000000,-16.00000000)
        call Orb(1,18,39.00000000,-4.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(19)/X3Kinematics.FPS),35.25000000)
        call Orb(9,19,35.00000000,8.00000000)
        call Orb(2,19,51.00000000,-18.00000000)
        call Orb(1,19,43.00000000,-10.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(20)/X3Kinematics.FPS),39.68750000)
        call Orb(9,20,39.00000000,14.00000000)
        call Orb(2,20,55.00000000,-16.00000000)
        call Orb(1,20,47.00000000,-16.00000000)
    endmethod
    private static method Batch65 takes nothing returns nothing
        call Scalar(X3Kinematics.forward(1,1,I2R(21)/X3Kinematics.FPS),44.62500000)
        call Orb(9,21,43.00000000,26.00000000)
        call Orb(2,21,59.00000000,-12.00000000)
        call Orb(1,21,51.00000000,-28.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(22)/X3Kinematics.FPS),50.06250000)
        call Orb(9,22,49.00000000,30.00000000)
        call Orb(2,22,65.00000000,-0.00000000)
        call Orb(1,22,57.00000000,-32.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(23)/X3Kinematics.FPS),56.00000000)
        call Orb(9,23,55.00000000,32.00000000)
        call Orb(2,23,71.00000000,6.00000000)
        call Orb(1,23,63.00000000,-34.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(24)/X3Kinematics.FPS),62.43750000)
        call Orb(9,24,61.00000000,30.00000000)
        call Orb(2,24,77.00000000,12.00000000)
        call Orb(1,24,69.00000000,-32.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(25)/X3Kinematics.FPS),69.37500000)
        call Orb(9,25,69.00000000,26.00000000)
        call Orb(2,25,85.00000000,24.00000000)
        call Orb(1,25,77.00000000,-28.00000000)
    endmethod
    private static method Batch66 takes nothing returns nothing
        call Scalar(X3Kinematics.forward(1,1,I2R(26)/X3Kinematics.FPS),76.81250000)
        call Orb(9,26,75.00000000,14.00000000)
        call Orb(2,26,91.00000000,28.00000000)
        call Orb(1,26,83.00000000,-16.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(27)/X3Kinematics.FPS),84.75000000)
        call Orb(9,27,83.00000000,8.00000000)
        call Orb(2,27,99.00000000,30.00000000)
        call Orb(1,27,91.00000000,-10.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(28)/X3Kinematics.FPS),93.18750000)
        call Orb(9,28,93.00000000,2.00000000)
        call Orb(2,28,109.00000000,28.00000000)
        call Orb(1,28,101.00000000,-4.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(29)/X3Kinematics.FPS),102.12500000)
        call Orb(9,29,101.00000000,-10.00000000)
        call Orb(2,29,117.00000000,24.00000000)
        call Orb(1,29,109.00000000,8.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(30)/X3Kinematics.FPS),111.56250000)
        call Orb(9,30,111.00000000,-14.00000000)
        call Orb(2,30,127.00000000,12.00000000)
        call Orb(1,30,119.00000000,12.00000000)
    endmethod
    private static method Batch67 takes nothing returns nothing
        call Scalar(X3Kinematics.forward(1,1,I2R(31)/X3Kinematics.FPS),121.50000000)
        call Orb(9,31,121.00000000,-16.00000000)
        call Orb(2,31,137.00000000,6.00000000)
        call Orb(1,31,129.00000000,14.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(32)/X3Kinematics.FPS),131.93750000)
        call Orb(9,32,131.00000000,-14.00000000)
        call Orb(2,32,147.00000000,-0.00000000)
        call Orb(1,32,139.00000000,12.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(33)/X3Kinematics.FPS),142.43750000)
        call Orb(9,33,141.00000000,-10.00000000)
        call Orb(2,33,157.00000000,-12.00000000)
        call Orb(1,33,149.00000000,8.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(34)/X3Kinematics.FPS),152.93750000)
        call Orb(9,34,151.00000000,2.00000000)
        call Orb(2,34,167.00000000,-16.00000000)
        call Orb(1,34,159.00000000,-4.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(35)/X3Kinematics.FPS),163.43750000)
        call Orb(9,35,163.00000000,8.00000000)
        call Orb(2,35,179.00000000,-18.00000000)
        call Orb(1,35,171.00000000,-10.00000000)
    endmethod
    private static method Batch68 takes nothing returns nothing
        call Scalar(X3Kinematics.forward(1,1,I2R(36)/X3Kinematics.FPS),173.93750000)
        call Orb(9,36,173.00000000,14.00000000)
        call Orb(2,36,189.00000000,-16.00000000)
        call Orb(1,36,181.00000000,-16.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(37)/X3Kinematics.FPS),184.43750000)
        call Orb(9,37,183.00000000,26.00000000)
        call Orb(2,37,199.00000000,-12.00000000)
        call Orb(1,37,191.00000000,-28.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(38)/X3Kinematics.FPS),194.93750000)
        call Orb(9,38,193.00000000,30.00000000)
        call Orb(2,38,209.00000000,-0.00000000)
        call Orb(1,38,201.00000000,-32.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(39)/X3Kinematics.FPS),205.43750000)
        call Orb(9,39,205.00000000,32.00000000)
        call Orb(2,39,221.00000000,6.00000000)
        call Orb(1,39,213.00000000,-34.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(40)/X3Kinematics.FPS),215.93750000)
        call Orb(9,40,215.00000000,30.00000000)
        call Orb(2,40,231.00000000,12.00000000)
        call Orb(1,40,223.00000000,-32.00000000)
    endmethod
    private static method Batch69 takes nothing returns nothing
        call Scalar(X3Kinematics.forward(1,1,I2R(41)/X3Kinematics.FPS),226.43750000)
        call Orb(9,41,225.00000000,26.00000000)
        call Orb(2,41,241.00000000,24.00000000)
        call Orb(1,41,233.00000000,-28.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(42)/X3Kinematics.FPS),236.93750000)
        call Orb(9,42,235.00000000,14.00000000)
        call Orb(2,42,251.00000000,28.00000000)
        call Orb(1,42,243.00000000,-16.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(43)/X3Kinematics.FPS),247.43750000)
        call Orb(9,43,247.00000000,8.00000000)
        call Orb(2,43,263.00000000,30.00000000)
        call Orb(1,43,255.00000000,-10.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(44)/X3Kinematics.FPS),257.93750000)
        call Orb(9,44,257.00000000,2.00000000)
        call Orb(2,44,273.00000000,28.00000000)
        call Orb(1,44,265.00000000,-4.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(45)/X3Kinematics.FPS),268.43750000)
        call Orb(9,45,267.00000000,-10.00000000)
        call Orb(2,45,283.00000000,24.00000000)
        call Orb(1,45,275.00000000,8.00000000)
    endmethod
    private static method Batch70 takes nothing returns nothing
        call Scalar(X3Kinematics.forward(1,1,I2R(46)/X3Kinematics.FPS),278.93750000)
        call Orb(9,46,277.00000000,-14.00000000)
        call Orb(2,46,293.00000000,12.00000000)
        call Orb(1,46,285.00000000,12.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(47)/X3Kinematics.FPS),289.43750000)
        call Orb(9,47,289.00000000,-16.00000000)
        call Orb(2,47,305.00000000,6.00000000)
        call Orb(1,47,297.00000000,14.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(48)/X3Kinematics.FPS),299.93750000)
        call Orb(9,48,299.00000000,-14.00000000)
        call Orb(2,48,315.00000000,-0.00000000)
        call Orb(1,48,307.00000000,12.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(49)/X3Kinematics.FPS),310.43750000)
        call Orb(9,49,309.00000000,-10.00000000)
        call Orb(2,49,325.00000000,-12.00000000)
        call Orb(1,49,317.00000000,8.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(50)/X3Kinematics.FPS),320.93750000)
        call Orb(9,50,319.00000000,2.00000000)
        call Orb(2,50,335.00000000,-16.00000000)
        call Orb(1,50,327.00000000,-4.00000000)
    endmethod
    private static method Batch71 takes nothing returns nothing
        call Scalar(X3Kinematics.forward(1,1,I2R(51)/X3Kinematics.FPS),331.43750000)
        call Orb(9,51,331.00000000,8.00000000)
        call Orb(1,51,339.00000000,-10.00000000)
        call Scalar(X3Kinematics.forward(1,1,I2R(52)/X3Kinematics.FPS),341.93750000)
        call Orb(9,52,341.00000000,14.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(5)/X3Kinematics.FPS),16.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(6)/X3Kinematics.FPS),32.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(7)/X3Kinematics.FPS),48.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(8)/X3Kinematics.FPS),64.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(9)/X3Kinematics.FPS),80.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(10)/X3Kinematics.FPS),96.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(11)/X3Kinematics.FPS),112.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(12)/X3Kinematics.FPS),128.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(13)/X3Kinematics.FPS),144.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(14)/X3Kinematics.FPS),160.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(15)/X3Kinematics.FPS),176.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(16)/X3Kinematics.FPS),192.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(17)/X3Kinematics.FPS),208.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(18)/X3Kinematics.FPS),224.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(19)/X3Kinematics.FPS),240.00000000)
    endmethod
    private static method Batch72 takes nothing returns nothing
        call Scalar(X3Kinematics.forward(1,3,I2R(20)/X3Kinematics.FPS),256.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(21)/X3Kinematics.FPS),272.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(22)/X3Kinematics.FPS),288.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(23)/X3Kinematics.FPS),304.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(24)/X3Kinematics.FPS),320.00000000)
        call Scalar(X3Kinematics.forward(1,3,I2R(25)/X3Kinematics.FPS),336.00000000)
    endmethod
    static method step takes nothing returns nothing
        if batch == 0 then
            call Batch0()
        elseif batch == 1 then
            call Batch1()
        elseif batch == 2 then
            call Batch2()
        elseif batch == 3 then
            call Batch3()
        elseif batch == 4 then
            call Batch4()
        elseif batch == 5 then
            call Batch5()
        elseif batch == 6 then
            call Batch6()
        elseif batch == 7 then
            call Batch7()
        elseif batch == 8 then
            call Batch8()
        elseif batch == 9 then
            call Batch9()
        elseif batch == 10 then
            call Batch10()
        elseif batch == 11 then
            call Batch11()
        elseif batch == 12 then
            call Batch12()
        elseif batch == 13 then
            call Batch13()
        elseif batch == 14 then
            call Batch14()
        elseif batch == 15 then
            call Batch15()
        elseif batch == 16 then
            call Batch16()
        elseif batch == 17 then
            call Batch17()
        elseif batch == 18 then
            call Batch18()
        elseif batch == 19 then
            call Batch19()
        elseif batch == 20 then
            call Batch20()
        elseif batch == 21 then
            call Batch21()
        elseif batch == 22 then
            call Batch22()
        elseif batch == 23 then
            call Batch23()
        elseif batch == 24 then
            call Batch24()
        elseif batch == 25 then
            call Batch25()
        elseif batch == 26 then
            call Batch26()
        elseif batch == 27 then
            call Batch27()
        elseif batch == 28 then
            call Batch28()
        elseif batch == 29 then
            call Batch29()
        elseif batch == 30 then
            call Batch30()
        elseif batch == 31 then
            call Batch31()
        elseif batch == 32 then
            call Batch32()
        elseif batch == 33 then
            call Batch33()
        elseif batch == 34 then
            call Batch34()
        elseif batch == 35 then
            call Batch35()
        elseif batch == 36 then
            call Batch36()
        elseif batch == 37 then
            call Batch37()
        elseif batch == 38 then
            call Batch38()
        elseif batch == 39 then
            call Batch39()
        elseif batch == 40 then
            call Batch40()
        elseif batch == 41 then
            call Batch41()
        elseif batch == 42 then
            call Batch42()
        elseif batch == 43 then
            call Batch43()
        elseif batch == 44 then
            call Batch44()
        elseif batch == 45 then
            call Batch45()
        elseif batch == 46 then
            call Batch46()
        elseif batch == 47 then
            call Batch47()
        elseif batch == 48 then
            call Batch48()
        elseif batch == 49 then
            call Batch49()
        elseif batch == 50 then
            call Batch50()
        elseif batch == 51 then
            call Batch51()
        elseif batch == 52 then
            call Batch52()
        elseif batch == 53 then
            call Batch53()
        elseif batch == 54 then
            call Batch54()
        elseif batch == 55 then
            call Batch55()
        elseif batch == 56 then
            call Batch56()
        elseif batch == 57 then
            call Batch57()
        elseif batch == 58 then
            call Batch58()
        elseif batch == 59 then
            call Batch59()
        elseif batch == 60 then
            call Batch60()
        elseif batch == 61 then
            call Batch61()
        elseif batch == 62 then
            call Batch62()
        elseif batch == 63 then
            call Batch63()
        elseif batch == 64 then
            call Batch64()
        elseif batch == 65 then
            call Batch65()
        elseif batch == 66 then
            call Batch66()
        elseif batch == 67 then
            call Batch67()
        elseif batch == 68 then
            call Batch68()
        elseif batch == 69 then
            call Batch69()
        elseif batch == 70 then
            call Batch70()
        elseif batch == 71 then
            call Batch71()
        elseif batch == 72 then
            call Batch72()
        else
            set done = true
        endif
        set batch = batch+1
    endmethod
endstruct
endlibrary

// Test-only lifecycle/integration lab; mathematical expectations come from CSV.
library X3NativeProbe initializer Init requires X3Probe, X3Oracle
globals
    private integer checks = 0
    private integer failures = 0
    private string array lines
    private integer stage = -1
    private timer ticker = CreateTimer()
    private real since = 0.
    private real formationStarted
    private real sx
    private real sy
    private unit source
    private unit target
    private destructable tree
    private X3Buster shot
    private X3Buster second
    private RapidPair pair
    private integer births
    private integer merges
    private integer baseCreated
    private integer baseRetired
    private integer baseHits
    private integer baseWalls
    private boolean sawFormation
    private integer visualProfile = 1
    private timer showing = CreateTimer()
    private string diagnostics = ""
    private real targetBirthLife
    private real unionRecordX
endglobals
private function Check takes boolean ok, string label returns nothing
    set lines[checks] = "PASS "+label
    if not ok then
        set lines[checks] = "FAIL "+label
        set failures = failures+1
        call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,lines[checks])
    endif
    set checks = checks+1
endfunction
private function Save takes string status returns nothing
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("NATIVE 20261023-145002 "+status)
    loop
        exitwhen i == checks
        call Preload(lines[i])
        set i = i+1
    endloop
    call Preload("checks="+I2S(checks)+" failures="+I2S(failures)+" oracle="+I2S(X3Oracle.valueChecks)+" oracleFailures="+I2S(X3Oracle.valueFailures)+" maxError="+R2S(X3Oracle.maxError))
    call Preload(diagnostics)
    call Preload("casts="+I2S(X3Buster.live)+" live="+I2S(X3Buster.projectiles)+" created="+I2S(X3Buster.created-baseCreated)+" retired="+I2S(X3Buster.retired-baseRetired)+" flashes="+I2S(X3Buster.flashCount()))
    call PreloadGenEnd("Logs\\TerrainDev-20261023-145002-native.txt")
endfunction
private function Advance takes integer n returns nothing
    set stage = n
    set since = X3Buster.now()
    call Save("PROGRESS "+I2S(n))
endfunction
private function Position takes Missile m, integer form, real ox, real oy, real angle, integer profile returns boolean
    local real t = X3Buster.ageOf(m)
    local real x = X3Kinematics.forward(profile,form,t)
    local real y = X3Kinematics.side(profile,form,t)
    if form == 1 or form == 2 or form == 9 then
        set x = X3Kinematics.orbitForward(form,t)
    endif
    return RAbsBJ(GetUnitX(m.dummy)-(ox+x*Cos(angle)-y*Sin(angle))) < 0.15 and RAbsBJ(GetUnitY(m.dummy)-(oy+x*Sin(angle)+y*Cos(angle))) < 0.15
endfunction
private function Tick takes nothing returns nothing
    local real elapsed = X3Buster.now()-since
    if elapsed > 9. then
        call Check(false,"bounded stage timeout "+I2S(stage))
        call Save("TIMEOUT")
        call PauseTimer(ticker)
        return
    endif
    if stage == 0 then
        call X3Oracle.step()
        if X3Oracle.done then
            call Check(X3Oracle.valueChecks == 5259 and X3Oracle.valueFailures == 0,"5259 ROM CSV values match vJASS within 0.012 world units")
            set sx = X3ProbeLaneX()
            set sy = X3ProbeLaneY()
            set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
            set births = X3Buster.created
            set merges = X3Buster.fusions
            set shot = X3Buster.fireProfile(source,sx+1400.,sy,2,X3Buster.ORIGINAL)
            call Check(shot != 0 and shot.profile == 1 and shot.bodies == 3 and shot.blue != 0,"USA starts three owned helix components")
            call Check(Position(shot.green,1,shot.originX,shot.originY,shot.angle,1) and Position(shot.orange,2,shot.originX,shot.originY,shot.angle,1) and Position(shot.blue,9,shot.originX,shot.originY,shot.angle,1),"three components start at their native offsets")
            call Advance(1)
        endif
    elseif stage == 1 and elapsed >= 0.18 then
        call Check(Position(shot.green,1,shot.originX,shot.originY,shot.angle,1) and Position(shot.orange,2,shot.originX,shot.originY,shot.angle,1) and Position(shot.blue,9,shot.originX,shot.originY,shot.angle,1),"three rendered helix paths follow native knots")
        call Check(shot.releasePulse(),"manual USA second pulse accepted")
        call Advance(2)
    elseif stage == 2 and shot.forming then
        set formationStarted = X3Buster.now()
        call Check(shot.state == 4 and shot.fused == 0 and X3Buster.created == births+4,"USA union retires four precursors before five-body emission")
        call Check(X3Buster.fusions == merges+1 and X3Buster.flashCount() == 1,"USA union has exactly one flash and one fusion")
        call Check(RAbsBJ(X3Buster.lastFusionX-shot.originX) < 0.15,"union relocates to the still-growing second pulse")
        call Advance(3)
    elseif stage == 3 and elapsed >= 0.09 then
        call Check(shot.forming and shot.fused == 0 and X3Buster.projectiles == 0,"USA formation retains cast with zero missile bodies")
        call Advance(4)
    elseif stage == 4 and not shot.forming then
        call Check(shot.state == 2 and shot.bodies == 5 and X3Buster.created == births+9,"USA emits core plus four satellites exactly once")
        call Check(RAbsBJ(X3Buster.now()-formationStarted-X3Kinematics.formation(1)) < 0.05,"USA formation lasts native 18 frames within engine tick tolerance")
        call Advance(5)
    elseif stage == 5 and elapsed >= 0.12 then
        call Check(Position(shot.fused,4,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,1),"USA core render follows native acceleration")
        call Check(Position(shot.sat1,5,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,1) and Position(shot.sat2,6,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,1) and Position(shot.sat3,7,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,1) and Position(shot.sat4,8,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,1),"USA four rendered satellites follow native retreat and separation")
        call Check(GetUnitX(shot.sat1.dummy) < X3Buster.lastFusionX-40.,"USA first pair visibly retreats before accelerating")
        call shot.cancel()
        call Advance(6)
    elseif stage == 6 and elapsed >= 0.3 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0,"USA cancellation retires every body")
        call SetUnitX(source,sx+750.)
        set births = X3Buster.created
        set merges = X3Buster.fusions
        set shot = X3Buster.fireProfile(source,sx-650.,sy,1,2)
        call Check(shot != 0 and shot.profile == 2 and shot.bodies == 3,"Zero Project starts independently facing left")
        call Advance(7)
    elseif stage == 7 and shot.forming then
        set formationStarted = X3Buster.now()
        call Check(X3Buster.fusions == merges+1 and X3Buster.created == births+4 and shot.fused == 0,"Zero Project automatic second pulse enters formation")
        call Advance(8)
    elseif stage == 8 and not shot.forming then
        call Check(shot.state == 2 and shot.bodies == 5 and X3Buster.created == births+9,"Zero Project emits five bodies")
        call Check(RAbsBJ(X3Buster.now()-formationStarted-X3Kinematics.formation(2)) < 0.05,"Zero Project formation lasts native 8 frames within engine tick tolerance")
        call Advance(9)
    elseif stage == 9 and elapsed >= 0.15 then
        call Check(Position(shot.fused,4,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,2),"Zero Project core has immediate native capped speed")
        call Check(Position(shot.sat1,5,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,2) and Position(shot.sat2,6,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,2) and Position(shot.sat3,7,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,2) and Position(shot.sat4,8,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,2),"Zero Project four curved trajectories rotate correctly to left")
        call shot.cancel()
        call Advance(10)
    elseif stage == 10 and elapsed >= 0.3 then
        call SetUnitX(source,sx)
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,2,1)
        call shot.releasePulse()
        call Advance(11)
    elseif stage == 11 and shot.forming then
        set births = X3Buster.created
        call shot.cancel()
        call Advance(12)
    elseif stage == 12 and elapsed >= 0.5 then
        call Check(X3Buster.created == births and X3Buster.live == 0 and X3Buster.projectiles == 0 and X3Buster.flashCount() == 0,"cancelling formation releases its timer without delayed emission or flash leak")
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,2,1)
        set merges = X3Buster.fusions
        call shot.blue.destroy()
        call shot.releasePulse()
        call Advance(13)
    elseif stage == 13 and elapsed >= 0.6 then
        call Check(X3Buster.fusions == merges and not shot.forming,"missing third helix component prevents native union")
        call shot.cancel()
        call Advance(14)
    elseif stage == 14 and elapsed >= 0.2 then
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,2,2)
        call shot.releasePulse()
        call Advance(15)
    elseif stage == 15 and shot.forming then
        set births = X3Buster.created
        call KillUnit(source)
        call Advance(16)
    elseif stage == 16 and elapsed >= 0.4 then
        call Check(X3Buster.created == births and X3Buster.live == 0 and X3Buster.projectiles == 0,"dead source during formation cannot emit delayed bodies")
        call RemoveUnit(source)
        set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
        set births = X3Buster.created
        set merges = X3Buster.fusions
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,1,1)
        set second = X3Buster.fireProfile(source,sx+1400.,sy,1,2)
        call Advance(17)
    elseif stage == 17 and elapsed >= 0.85 then
        call Check(X3Buster.fusions == merges+2 and X3Buster.created == births+18,"simultaneous USA and mod casts keep separate pairs and formation timers")
        call Check(shot.profile == 1 and second.profile == 2,"profile remains immutable for each live cast")
        call shot.cancel()
        call second.cancel()
        call Advance(18)
    elseif stage == 18 and elapsed >= 0.3 then
        set pair = RapidPair.create(CreateUnit(Player(0),'rfct',WorldBounds.minX+256.,WorldBounds.minY+256.,0.),source)
        set X3Demo.profile = 1
        set births = X3Buster.created
        set merges = X3Buster.fusions
        call Check(IssuePointOrder(pair.controller,"shockwave",sx+1400.,sy),"controller accepts native E USA order")
        call Advance(19)
    elseif stage == 19 and elapsed >= 0.85 then
        call Check(X3Buster.fusions == merges+1 and X3Buster.created == births+9,"native E selects the three-component USA sequence")
        call Check(GetUnitCurrentOrder(source) == 0,"native E does not issue a spell order to visible actor")
        call Advance(20)
    elseif stage == 20 and elapsed >= 3.8 then
        set births = X3Buster.created
        set merges = X3Buster.fusions
        call Check(IssuePointOrder(pair.controller,"breathoffire",sx+1400.,sy),"controller accepts native R Zero Project order")
        call Advance(21)
    elseif stage == 21 and elapsed >= 0.8 then
        call Check(X3Buster.fusions == merges+1 and X3Buster.created == births+9,"native R selects Zero Project without conflicting with E or Rapid Fire")
        call Check(GetUnitCurrentOrder(source) == 0,"native R leaves visible actor without a spell order")
        call Advance(22)
    elseif stage == 22 and elapsed >= 3.8 then
        call pair.destroy()
        set baseHits = X3Buster.hits
        set target = CreateUnit(Player(12),'rftg',sx+230.,sy,180.)
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,0,1)
        call Advance(23)
    elseif stage == 23 and elapsed >= 0.65 then
        call Check(X3Buster.hits == baseHits+1 and GetWidgetLife(target) < GetUnitState(target,UNIT_STATE_MAX_LIFE),"native charged pulse sweeps enemy and damages once")
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0,"native charged enemy impact retires pulse")
        call RemoveUnit(target)
        set tree = CreateDestructable('LTlt',sx+230.,sy,0.,1.,0)
        set baseWalls = X3Buster.walls
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,0,2)
        call Advance(24)
    elseif stage == 24 and elapsed >= 0.65 then
        call Check(X3Buster.walls == baseWalls+1 and X3Buster.live == 0,"native charged pulse stops at destructible tree")
        call RemoveDestructable(tree)
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,2,1)
        call shot.releasePulse()
        call Advance(25)
    elseif stage == 25 and shot.forming then
        set baseHits = X3Buster.hits
        set baseWalls = X3Buster.walls
        set unionRecordX = X3Buster.lastFusionX
        set target = CreateUnit(Player(12),'rftg',unionRecordX-90.,sy+20.,0.)
        set targetBirthLife = GetWidgetLife(target)
        set diagnostics = "baselineBehind="+I2S(GroundCollision.trace(unionRecordX,sy,unionRecordX-120.,sy+36.,12.65,source,Player(0),false))+" requested="+R2S(unionRecordX-90.)+","+R2S(sy+20.)+" actual="+R2S(GetUnitX(target))+","+R2S(GetUnitY(target))
        call Advance(26)
    elseif stage == 26 and elapsed >= 0.5 then
        set diagnostics = diagnostics+" hits="+I2S(X3Buster.hits-baseHits)+" walls="+I2S(X3Buster.walls-baseWalls)+" life="+R2S(targetBirthLife)+"->"+R2S(GetWidgetLife(target))
        call shot.cancel()
        call RemoveUnit(target)
        call Advance(27)
    elseif stage == 27 and elapsed >= 0.5 then
        call SetUnitX(source,sx+300.)
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,2,1)
        call shot.releasePulse()
        call Advance(28)
    elseif stage == 28 and shot.forming then
        set baseHits = X3Buster.hits
        set baseWalls = X3Buster.walls
        set unionRecordX = X3Buster.lastFusionX
        set target = CreateUnit(Player(12),'rftg',unionRecordX-90.,sy+20.,0.)
        set targetBirthLife = GetWidgetLife(target)
        call Check(GroundCollision.trace(unionRecordX,sy,unionRecordX-120.,sy+36.,12.65,source,Player(0),false) == 0 and RAbsBJ(GetUnitX(target)-(unionRecordX-90.)) < 1. and RAbsBJ(GetUnitY(target)-(sy+20.)) < 1.,"native retreat fixture has clear terrain and undisplaced target")
        call Advance(29)
    elseif stage == 29 and elapsed >= 0.5 then
        call Check(X3Buster.hits > baseHits and GetWidgetLife(target) < targetBirthLife,"native retreating satellites sweep enemies behind union point")
        set diagnostics = diagnostics+" relocatedHits="+I2S(X3Buster.hits-baseHits)+" relocatedWalls="+I2S(X3Buster.walls-baseWalls)+" relocatedLife="+R2S(targetBirthLife)+"->"+R2S(GetWidgetLife(target))
        call shot.cancel()
        call RemoveUnit(target)
        call Advance(30)
    elseif stage == 30 and elapsed >= 0.5 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0 and X3Buster.flashCount() == 0,"native tests finish with zero casts projectiles and flashes")
        call Check(X3Buster.created-baseCreated == X3Buster.retired-baseRetired,"all native created bodies retire exactly once")
        call RemoveUnit(source)
        set source = null
        call Save("COMPLETE")
        call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"NATIVE COMPLETE "+I2S(checks)+" checks / "+I2S(failures)+" failures; oracle "+I2S(X3Oracle.valueFailures)+". -usa / -zero para ver.")
        call PauseTimer(ticker)
        set stage = -2
    endif
endfunction
private function Begin takes nothing returns nothing
    if stage != -1 then
        return
    endif
    set baseCreated = X3Buster.created
    set baseRetired = X3Buster.retired
    call Advance(0)
    call TimerStart(ticker,1./32.,true,function Tick)
endfunction
private function Repeat takes nothing returns nothing
    local X3Buster s = X3Buster.fireProfile(source,sx+1400.,sy,1,visualProfile)
    call SetUnitAnimation(source,"attack")
endfunction
private function Show takes nothing returns nothing
    if stage != -2 then
        return
    endif
    if source == null then
        set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
    endif
    set visualProfile = 1
    if GetEventPlayerChatString() == "-zero" then
        set visualProfile = 2
    endif
    call SetCameraTargetController(null,0.,0.,false)
    call PanCameraToTimed(sx+400.,sy,0.)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,1000.,0.)
    call FogEnable(false)
    call FogMaskEnable(false)
    call SetTimeOfDay(12.)
    call SuspendTimeOfDay(true)
    call MultiboardDisplay(MissileStats.board,false)
    call ClearTextMessages()
    call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"Perfil "+I2S(visualProfile)+" : 1 USA / 2 Zero Project")
    call TimerStart(showing,2.5,true,function Repeat)
endfunction
private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-native",true)
    call TriggerAddAction(t,function Begin)
    set t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-usa",true)
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-zero",true)
    call TriggerAddAction(t,function Show)
    set t = null
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

