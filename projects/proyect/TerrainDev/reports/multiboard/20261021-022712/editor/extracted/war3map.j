globals
//globals from DummyCaster:
constant boolean LIBRARY_DummyCaster=true
constant integer UNITS_DUMMY_CASTER= 'dcst'
   
    
constant player DummyCaster___PLAYER_OWNER= Player(15)
unit DummyCaster___u
//endglobals from DummyCaster
//globals from ErrorMessage:
constant boolean LIBRARY_ErrorMessage=true
//endglobals from ErrorMessage
//globals from IsDestructableTree:
constant boolean LIBRARY_IsDestructableTree=true
constant integer IsDestructableTree__HARVESTER_UNIT_ID= 'hpea'
constant integer IsDestructableTree__HARVEST_ABILITY= 'Ahrl'
constant integer IsDestructableTree__HARVEST_ORDER_ID= 0xD0032
constant player IsDestructableTree__NEUTRAL_PLAYER= Player(PLAYER_NEUTRAL_PASSIVE)
unit IsDestructableTree__harvester= null
//endglobals from IsDestructableTree
//globals from RegisterPlayerUnitEvent:
constant boolean LIBRARY_RegisterPlayerUnitEvent=true
trigger array RegisterPlayerUnitEvent__t
//endglobals from RegisterPlayerUnitEvent
//globals from Table:
constant boolean LIBRARY_Table=true
integer Table___less= 0
integer Table___more= 8190
    //Configure it if you use more than 8190 "key" variables in your map (this will never happen though).
   
hashtable Table___ht= InitHashtable()
constant integer Table___sizeK=22
constant integer Table___listK=127
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
//globals from MissileDiagnostics:
constant boolean LIBRARY_MissileDiagnostics=true
//endglobals from MissileDiagnostics
//globals from SpellEffectEvent:
constant boolean LIBRARY_SpellEffectEvent=true
//endglobals from SpellEffectEvent
//globals from MissileRecycler:
constant boolean LIBRARY_MissileRecycler=true
        //-------------------------------------------------------------------
        // You must configure the dummy unit with the one created from the
        // ObjectMerger statement above.
        //
constant integer MissileRecycler___DUMMY_ID= 'dumi'
player MissileRecycler___OWNER= Player(bj_PLAYER_NEUTRAL_EXTRA)

constant integer MissileRecycler___ANG_N= 8
constant integer MissileRecycler___ANG_STORAGE_MAX= 12

constant real MissileRecycler___DEATH_TIME= 2.
        //the unit to complete its "death" animation in this timeframe. Must
        //be higher than 0.74 seconds to allow the unit time to turn. This
        //number should not be lower than the maximum death-animation time of
        //your missile-units' effect attachments, just to be safe.
constant integer MissileRecycler___ANG_VAL= 360 / MissileRecycler___ANG_N
constant integer MissileRecycler___ANG_MID= MissileRecycler___ANG_VAL / 2

        //Misc vars
unit array MissileRecycler___stack
real array MissileRecycler___timeStamp
integer array MissileRecycler___queueNext
integer array MissileRecycler___queueLast
integer MissileRecycler___recycle= 0
timer MissileRecycler___gameTime= CreateTimer()
integer array MissileRecycler___queueStack
integer MissileRecycler___queueStackN= 0
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
        
        
constant real Missile__DELAYED_MISSILE_DEATH_ANIMATION_TIME= 2.

        
constant boolean Missile_USE_DESTRUCTABLE_FILTER= true
constant boolean Missile_USE_ITEM_FILTER= true
        // Core constant handle variables of Missile.
constant trigger Missile__CORE= CreateTrigger()
constant trigger Missile__MOVE= CreateTrigger()
constant timer Missile__TMR= CreateTimer()
constant location Missile__LOC= Location(0., 0.)
constant rect Missile__RECT= Rect(0., 0., 0., 0.)
constant group Missile__GROUP= CreateGroup()
constant hashtable Missile__HASH= InitHashtable()
        // For starting and stopping the timer.
integer Missile__active= 0
        // Arrays for data structure.
integer array Missile__instances
integer array Missile__missileList
boolexpr array Missile__expression
triggercondition array Missile__condition
integer array Missile__remove
boolean array Missile__destroying
boolean array Missile__recycling
integer array Missile__nextNode
integer array Missile__prevNode
        // Internal widget filter functions.
boolexpr Missile__destFilter
boolexpr Missile__itemFilter
boolexpr Missile__unitFilter
//endglobals from Missile
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
trigger gg_trg_WorldBounds= null
trigger gg_trg_ErrorMessage= null
trigger gg_trg_TimerUtils= null
trigger gg_trg_Table= null
trigger gg_trg_RegisterPlayerUnitEvent= null
trigger gg_trg_SpellEffectEvent= null
trigger gg_trg_IsDestructableTree= null
trigger gg_trg_DummyCaster= null
trigger gg_trg_MissileDiagnostics= null
trigger gg_trg_MissileRecycler= null
trigger gg_trg_Missile= null
unit gg_unit_ntrd_0023= null


//JASSHelper struct globals:
constant integer si__DummyCaster=1
constant integer si__ErrorMessage___Fields=2
constant string s__ErrorMessage___Fields_COLOR_RED= "|cffff0000"
constant string s__ErrorMessage___Fields_COLOR_YELLOW= "|cffffff00"
string s__ErrorMessage___Fields_lastError= null
constant integer si__IsDestructableTree__I=3
constant integer si__Table___dex=4
constant integer si__Table___handles=5
constant integer si__Table___agents=6
constant integer si__Table___reals=7
constant integer si__Table___booleans=8
constant integer si__Table___strings=9
constant integer si__Table___players=10
constant integer si__Table___widgets=11
constant integer si__Table___destructables=12
constant integer si__Table___items=13
constant integer si__Table___units=14
constant integer si__Table___abilitys=15
constant integer si__Table___timers=16
constant integer si__Table___triggers=17
constant integer si__Table___triggerconditions=18
constant integer si__Table___triggeractions=19
constant integer si__Table___events=20
constant integer si__Table___forces=21
constant integer si__Table___groups=22
constant integer si__Table___locations=23
constant integer si__Table___rects=24
constant integer si__Table___boolexprs=25
constant integer si__Table___sounds=26
constant integer si__Table___effects=27
constant integer si__Table___unitpools=28
constant integer si__Table___itempools=29
constant integer si__Table___quests=30
constant integer si__Table___questitems=31
constant integer si__Table___defeatconditions=32
constant integer si__Table___timerdialogs=33
constant integer si__Table___leaderboards=34
constant integer si__Table___multiboards=35
constant integer si__Table___multiboarditems=36
constant integer si__Table___trackables=37
constant integer si__Table___dialogs=38
constant integer si__Table___buttons=39
constant integer si__Table___texttags=40
constant integer si__Table___lightnings=41
constant integer si__Table___images=42
constant integer si__Table___ubersplats=43
constant integer si__Table___regions=44
constant integer si__Table___fogstates=45
constant integer si__Table___fogmodifiers=46
constant integer si__Table___hashtables=47
constant integer si__Table=48
constant integer si__TableArray=49
integer s__TableArray_tempTable
integer s__TableArray_tempEnd
constant integer si__WorldBounds=50
integer s__WorldBounds_maxX
integer s__WorldBounds_maxY
integer s__WorldBounds_minX
integer s__WorldBounds_minY
integer s__WorldBounds_centerX
integer s__WorldBounds_centerY
rect s__WorldBounds_world
region s__WorldBounds_worldRegion
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
constant integer si__SpellEffectEvent___S=52
integer s__SpellEffectEvent___S_tb
constant integer si__Missile__RecycleBin=53
constant timer s__Missile__RecycleBin_t= CreateTimer()
integer s__Missile__RecycleBin_max= 0
unit array s__Missile__RecycleBin_dummy
real array s__Missile__RecycleBin_time
constant integer si__MissilePosition=54
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
constant integer si__Missile=55
integer s__Missile_Missile__MissileStructure___collectionCount= 0
integer s__Missile_Missile__MissileStructure___nodeCount= 0
boolean array s__Missile_Missile__MissileStructure___isNode
boolean array s__Missile_Missile__MissileStructure___isCollection
integer array s__Missile_Missile__MissileStructure____list
integer array s__Missile_Missile__MissileStructure____next
integer array s__Missile_Missile__MissileStructure____prev
integer array s__Missile_Missile__MissileStructure____first
integer array s__Missile_Missile__MissileStructure____last
constant string s__Missile_ORIGIN= "origin"
constant real s__Missile_HIT_BOX= ( 2. / 3. )
boolean array s__Missile_launched
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
integer array s__TimerUtils__data
timer array s__TimerUtils__tT
trigger array st___prototype1

endglobals
    native UnitAlive takes unit id returns boolean

function sc___prototype1_execute takes integer i returns nothing

    call TriggerExecute(st___prototype1[i])
endfunction
function sc___prototype1_evaluate takes integer i returns nothing

    call TriggerEvaluate(st___prototype1[i])

endfunction


//Implemented from module DummyCaster___N:
        function s__DummyCaster_DummyCaster___N__onInit takes nothing returns nothing
//#             static if LIBRARY_UnitIndexer then
//#                 set UnitIndexer.enabled=false
//#                 set DummyCaster___u=CreateUnit(DummyCaster___PLAYER_OWNER,UNITS_DUMMY_CASTER,0,0,0)
//#                 set UnitIndexer.enabled=true
//#             else
                    set DummyCaster___u=CreateUnit(DummyCaster___PLAYER_OWNER, UNITS_DUMMY_CASTER, 0, 0, 0)
//#             endif
            call SetUnitPosition(DummyCaster___u, 32256, 32256)
        endfunction
        function s__DummyCaster_prep takes integer a,player p,integer l returns nothing
            call UnitAddAbility(DummyCaster___u, a)
            if ( 1 < l ) then
                call SetUnitAbilityLevel(DummyCaster___u, a, l)
            endif
            if ( null != p ) then
                call SetUnitOwner(DummyCaster___u, p, false)
            endif
        endfunction
        function s__DummyCaster_finish takes integer a returns nothing
            call SetUnitOwner(DummyCaster___u, DummyCaster___PLAYER_OWNER, false)
            call UnitRemoveAbility(DummyCaster___u, a)
        endfunction
        function s__DummyCaster_cast takes integer this,player p,integer level,integer order,real x,real y returns boolean
            local boolean b
            call SetUnitX(DummyCaster___u, x)
            call SetUnitY(DummyCaster___u, y)
            call s__DummyCaster_prep(this , p , level)
            set b=IssueImmediateOrderById(DummyCaster___u, order)
            call s__DummyCaster_finish(this)
            call SetUnitPosition(DummyCaster___u, 32256, 32256)
            return b
        endfunction
        function s__DummyCaster_castTarget takes integer this,player p,integer level,integer order,widget t returns boolean
            local boolean b
            call s__DummyCaster_prep(this , p , level)
            set b=IssueTargetOrderById(DummyCaster___u, order, t)
            call s__DummyCaster_finish(this)
            return b
        endfunction
        function s__DummyCaster_castPoint takes integer this,player p,integer level,integer order,real x,real y returns boolean
            local boolean b
            call s__DummyCaster_prep(this , p , level)
            set b=IssuePointOrderById(DummyCaster___u, order, x, y)
            call s__DummyCaster_finish(this)
            return b
        endfunction

//# 	static if true then
    		
      function ErrorMessage___Pause takes nothing returns nothing
    			call PauseGame(true)
    		endfunction
    		
      function ErrorMessage___ThrowMessage takes string libraryName,string functionName,string objectName,integer objectInstance,string description,string errorType,string color returns nothing
       local string str
    			
       local string color_braces= "|cff66FF99"
       local string orange= "|cffff6600"
    			
    			set str="->\n-> " + color_braces + "{|r Library" + color_braces + "(" + orange + libraryName + color_braces + ")"
    			if ( objectName != null ) then
    				if ( objectInstance > 0 ) then
    					set str=str + "|r.Object" + color_braces + "(" + orange + objectName + color_braces + " (|rinstance = " + orange + I2S(objectInstance) + color_braces + ") )|r.Method" + color_braces + "(" + orange + functionName + color_braces + ")"
    				else
    					set str=str + "|r.Object" + color_braces + "(" + orange + objectName + color_braces + ")|r.Method" + color_braces + "(" + orange + functionName + color_braces + ")"
    				endif
    			else
    				set str=str + "|r.Function" + color_braces + "(" + orange + functionName + color_braces + ")"
    			endif
    			
    			set str=str + color_braces + " }|r has thrown an exception of type " + color_braces + "(" + color + errorType + color_braces + ")|r."
    			
    			set s__ErrorMessage___Fields_lastError=str + "\n->\n->	" + color + description + "|r\n->"
    		endfunction
    		
      function ThrowError takes boolean expression,string libraryName,string functionName,string objectName,integer objectInstance,string description returns nothing
    			if ( s__ErrorMessage___Fields_lastError != null ) then
    				set objectInstance=1 / 0
    			endif
    		
    			if ( expression ) then
    				call ErrorMessage___ThrowMessage(libraryName , functionName , objectName , objectInstance , description , "Error" , s__ErrorMessage___Fields_COLOR_RED)
    				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, s__ErrorMessage___Fields_lastError)
    				call TimerStart(CreateTimer(), 0, true, function ErrorMessage___Pause)
    				set objectInstance=1 / 0
    			endif
    		endfunction
    
      function ThrowWarning takes boolean expression,string libraryName,string functionName,string objectName,integer objectInstance,string description returns nothing
    			if ( s__ErrorMessage___Fields_lastError != null ) then
    				set objectInstance=1 / 0
    			endif
    		
    			if ( expression ) then
    				call ErrorMessage___ThrowMessage(libraryName , functionName , objectName , objectInstance , description , "Warning" , s__ErrorMessage___Fields_COLOR_YELLOW)
    				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60000, s__ErrorMessage___Fields_lastError)
    				set s__ErrorMessage___Fields_lastError=null
    			endif
    		endfunction
//# 	endif

    function IsDestructableTree takes destructable d returns boolean
        //*  851973 is the order id for stunned, it will interrupt the preceding harvest order.
        return ( IssueTargetOrderById(IsDestructableTree__harvester, IsDestructableTree__HARVEST_ORDER_ID, d) ) and ( IssueImmediateOrderById(IsDestructableTree__harvester, 851973) )
    endfunction
    function IsDestructableDead takes destructable d returns boolean
        return ( GetWidgetLife(d) <= 0.405 )
    endfunction
    function IsDestructableAlive takes destructable d returns boolean
        return ( GetWidgetLife(d) > .405 )
    endfunction
    function IsTreeAlive takes destructable tree returns boolean
        return (GetWidgetLife((tree)) > .405) and (( IssueTargetOrderById(IsDestructableTree__harvester, IsDestructableTree__HARVEST_ORDER_ID, (tree)) ) and ( IssueImmediateOrderById(IsDestructableTree__harvester, 851973) )) // INLINED!!
    endfunction
    function KillTree takes destructable tree returns boolean
        if ( IsTreeAlive(tree) ) then
            call KillDestructable(tree)
            return true
        endif
        return false
    endfunction
    function IsDestructableTree__Init takes nothing returns nothing
//#         static if LIBRARY_UnitIndexer then//*  You may adapt this to your own indexer.
//#             set UnitIndexer.enabled = false
//#         endif
        set IsDestructableTree__harvester=CreateUnit(IsDestructableTree__NEUTRAL_PLAYER, IsDestructableTree__HARVESTER_UNIT_ID, 0, 0, 0)
//#         static if LIBRARY_UnitIndexer then
//#             set UnitIndexer.enabled = true
//#         endif
        call UnitAddAbility(IsDestructableTree__harvester, IsDestructableTree__HARVEST_ABILITY)
        call UnitAddAbility(IsDestructableTree__harvester, 'Aloc')
        call ShowUnit(IsDestructableTree__harvester, false)
    endfunction
    //*  Seriously?
//Implemented from module IsDestructableTree__Inits:
        function s__IsDestructableTree__I_IsDestructableTree__Inits___onInit takes nothing returns nothing
            call IsDestructableTree__Init()
        endfunction
    

   
    function RegisterPlayerUnitEvent takes playerunitevent p,code c returns nothing
        local integer i= GetHandleId(p)
        local integer k= 15
        if RegisterPlayerUnitEvent__t[i] == null then
            set RegisterPlayerUnitEvent__t[i]=CreateTrigger()
            loop
                call TriggerRegisterPlayerUnitEvent(RegisterPlayerUnitEvent__t[i], Player(k), p, null)
                exitwhen k == 0
                set k=k - 1
            endloop
        endif
        call TriggerAddCondition(RegisterPlayerUnitEvent__t[i], Filter(c))
    endfunction
   
    function RegisterPlayerUnitEventForPlayer takes playerunitevent p,code c,player pl returns nothing
        local integer i= 16 * GetHandleId(p) + GetPlayerId(pl)
        if RegisterPlayerUnitEvent__t[i] == null then
            set RegisterPlayerUnitEvent__t[i]=CreateTrigger()
            call TriggerRegisterPlayerUnitEvent(RegisterPlayerUnitEvent__t[i], pl, p, null)
        endif
        call TriggerAddCondition(RegisterPlayerUnitEvent__t[i], Filter(c))
    endfunction
   
    function GetPlayerUnitEventTrigger takes playerunitevent p returns trigger
        return RegisterPlayerUnitEvent__t[GetHandleId(p)]
    endfunction

   
   
    function s__Table___dex__get_size takes nothing returns integer
        return Table___sizeK
    endfunction
    function s__Table___dex__get_list takes nothing returns integer
        return Table___listK
    endfunction
   
    function s__Table___handles_has takes integer this,integer key returns boolean
        return HaveSavedHandle(Table___ht, this, key)
    endfunction
    function s__Table___handles_remove takes integer this,integer key returns nothing
        call RemoveSavedHandle(Table___ht, this, key)
    endfunction
   
    function s__Table___agents__setindex takes integer this,integer key,agent value returns nothing
        call SaveAgentHandle(Table___ht, this, key, value)
    endfunction
   
   
   
//Run these textmacros to include the entire hashtable API as wrappers.
//Don't be intimidated by the number of macros - Vexorian's map optimizer is
//supposed to kill functions which inline (all of these functions inline).
//textmacro instance: NEW_ARRAY_BASIC("Real", "Real", "real")
    function s__Table___reals__getindex takes integer this,integer key returns real
        return LoadReal(Table___ht, this, key)
    endfunction
    function s__Table___reals__setindex takes integer this,integer key,real value returns nothing
        call SaveReal(Table___ht, this, key, value)
    endfunction
    function s__Table___reals_has takes integer this,integer key returns boolean
        return HaveSavedReal(Table___ht, this, key)
    endfunction
    function s__Table___reals_remove takes integer this,integer key returns nothing
        call RemoveSavedReal(Table___ht, this, key)
    endfunction
//end of: NEW_ARRAY_BASIC("Real", "Real", "real")
//textmacro instance: NEW_ARRAY_BASIC("Boolean", "Boolean", "boolean")
    function s__Table___booleans__getindex takes integer this,integer key returns boolean
        return LoadBoolean(Table___ht, this, key)
    endfunction
    function s__Table___booleans__setindex takes integer this,integer key,boolean value returns nothing
        call SaveBoolean(Table___ht, this, key, value)
    endfunction
    function s__Table___booleans_has takes integer this,integer key returns boolean
        return HaveSavedBoolean(Table___ht, this, key)
    endfunction
    function s__Table___booleans_remove takes integer this,integer key returns nothing
        call RemoveSavedBoolean(Table___ht, this, key)
    endfunction
//end of: NEW_ARRAY_BASIC("Boolean", "Boolean", "boolean")
//textmacro instance: NEW_ARRAY_BASIC("String", "Str", "string")
    function s__Table___strings__getindex takes integer this,integer key returns string
        return LoadStr(Table___ht, this, key)
    endfunction
    function s__Table___strings__setindex takes integer this,integer key,string value returns nothing
        call SaveStr(Table___ht, this, key, value)
    endfunction
    function s__Table___strings_has takes integer this,integer key returns boolean
        return HaveSavedString(Table___ht, this, key)
    endfunction
    function s__Table___strings_remove takes integer this,integer key returns nothing
        call RemoveSavedString(Table___ht, this, key)
    endfunction
//end of: NEW_ARRAY_BASIC("String", "Str", "string")
   
//textmacro instance: NEW_ARRAY("Player", "player")
    function s__Table___players__getindex takes integer this,integer key returns player
        return LoadPlayerHandle(Table___ht, this, key)
    endfunction
    function s__Table___players__setindex takes integer this,integer key,player value returns nothing
        call SavePlayerHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Player", "player")
//textmacro instance: NEW_ARRAY("Widget", "widget")
    function s__Table___widgets__getindex takes integer this,integer key returns widget
        return LoadWidgetHandle(Table___ht, this, key)
    endfunction
    function s__Table___widgets__setindex takes integer this,integer key,widget value returns nothing
        call SaveWidgetHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Widget", "widget")
//textmacro instance: NEW_ARRAY("Destructable", "destructable")
    function s__Table___destructables__getindex takes integer this,integer key returns destructable
        return LoadDestructableHandle(Table___ht, this, key)
    endfunction
    function s__Table___destructables__setindex takes integer this,integer key,destructable value returns nothing
        call SaveDestructableHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Destructable", "destructable")
//textmacro instance: NEW_ARRAY("Item", "item")
    function s__Table___items__getindex takes integer this,integer key returns item
        return LoadItemHandle(Table___ht, this, key)
    endfunction
    function s__Table___items__setindex takes integer this,integer key,item value returns nothing
        call SaveItemHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Item", "item")
//textmacro instance: NEW_ARRAY("Unit", "unit")
    function s__Table___units__getindex takes integer this,integer key returns unit
        return LoadUnitHandle(Table___ht, this, key)
    endfunction
    function s__Table___units__setindex takes integer this,integer key,unit value returns nothing
        call SaveUnitHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Unit", "unit")
//textmacro instance: NEW_ARRAY("Ability", "ability")
    function s__Table___abilitys__getindex takes integer this,integer key returns ability
        return LoadAbilityHandle(Table___ht, this, key)
    endfunction
    function s__Table___abilitys__setindex takes integer this,integer key,ability value returns nothing
        call SaveAbilityHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Ability", "ability")
//textmacro instance: NEW_ARRAY("Timer", "timer")
    function s__Table___timers__getindex takes integer this,integer key returns timer
        return LoadTimerHandle(Table___ht, this, key)
    endfunction
    function s__Table___timers__setindex takes integer this,integer key,timer value returns nothing
        call SaveTimerHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Timer", "timer")
//textmacro instance: NEW_ARRAY("Trigger", "trigger")
    function s__Table___triggers__getindex takes integer this,integer key returns trigger
        return LoadTriggerHandle(Table___ht, this, key)
    endfunction
    function s__Table___triggers__setindex takes integer this,integer key,trigger value returns nothing
        call SaveTriggerHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Trigger", "trigger")
//textmacro instance: NEW_ARRAY("TriggerCondition", "triggercondition")
    function s__Table___triggerconditions__getindex takes integer this,integer key returns triggercondition
        return LoadTriggerConditionHandle(Table___ht, this, key)
    endfunction
    function s__Table___triggerconditions__setindex takes integer this,integer key,triggercondition value returns nothing
        call SaveTriggerConditionHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TriggerCondition", "triggercondition")
//textmacro instance: NEW_ARRAY("TriggerAction", "triggeraction")
    function s__Table___triggeractions__getindex takes integer this,integer key returns triggeraction
        return LoadTriggerActionHandle(Table___ht, this, key)
    endfunction
    function s__Table___triggeractions__setindex takes integer this,integer key,triggeraction value returns nothing
        call SaveTriggerActionHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TriggerAction", "triggeraction")
//textmacro instance: NEW_ARRAY("TriggerEvent", "event")
    function s__Table___events__getindex takes integer this,integer key returns event
        return LoadTriggerEventHandle(Table___ht, this, key)
    endfunction
    function s__Table___events__setindex takes integer this,integer key,event value returns nothing
        call SaveTriggerEventHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TriggerEvent", "event")
//textmacro instance: NEW_ARRAY("Force", "force")
    function s__Table___forces__getindex takes integer this,integer key returns force
        return LoadForceHandle(Table___ht, this, key)
    endfunction
    function s__Table___forces__setindex takes integer this,integer key,force value returns nothing
        call SaveForceHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Force", "force")
//textmacro instance: NEW_ARRAY("Group", "group")
    function s__Table___groups__getindex takes integer this,integer key returns group
        return LoadGroupHandle(Table___ht, this, key)
    endfunction
    function s__Table___groups__setindex takes integer this,integer key,group value returns nothing
        call SaveGroupHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Group", "group")
//textmacro instance: NEW_ARRAY("Location", "location")
    function s__Table___locations__getindex takes integer this,integer key returns location
        return LoadLocationHandle(Table___ht, this, key)
    endfunction
    function s__Table___locations__setindex takes integer this,integer key,location value returns nothing
        call SaveLocationHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Location", "location")
//textmacro instance: NEW_ARRAY("Rect", "rect")
    function s__Table___rects__getindex takes integer this,integer key returns rect
        return LoadRectHandle(Table___ht, this, key)
    endfunction
    function s__Table___rects__setindex takes integer this,integer key,rect value returns nothing
        call SaveRectHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Rect", "rect")
//textmacro instance: NEW_ARRAY("BooleanExpr", "boolexpr")
    function s__Table___boolexprs__getindex takes integer this,integer key returns boolexpr
        return LoadBooleanExprHandle(Table___ht, this, key)
    endfunction
    function s__Table___boolexprs__setindex takes integer this,integer key,boolexpr value returns nothing
        call SaveBooleanExprHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("BooleanExpr", "boolexpr")
//textmacro instance: NEW_ARRAY("Sound", "sound")
    function s__Table___sounds__getindex takes integer this,integer key returns sound
        return LoadSoundHandle(Table___ht, this, key)
    endfunction
    function s__Table___sounds__setindex takes integer this,integer key,sound value returns nothing
        call SaveSoundHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Sound", "sound")
//textmacro instance: NEW_ARRAY("Effect", "effect")
    function s__Table___effects__getindex takes integer this,integer key returns effect
        return LoadEffectHandle(Table___ht, this, key)
    endfunction
    function s__Table___effects__setindex takes integer this,integer key,effect value returns nothing
        call SaveEffectHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Effect", "effect")
//textmacro instance: NEW_ARRAY("UnitPool", "unitpool")
    function s__Table___unitpools__getindex takes integer this,integer key returns unitpool
        return LoadUnitPoolHandle(Table___ht, this, key)
    endfunction
    function s__Table___unitpools__setindex takes integer this,integer key,unitpool value returns nothing
        call SaveUnitPoolHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("UnitPool", "unitpool")
//textmacro instance: NEW_ARRAY("ItemPool", "itempool")
    function s__Table___itempools__getindex takes integer this,integer key returns itempool
        return LoadItemPoolHandle(Table___ht, this, key)
    endfunction
    function s__Table___itempools__setindex takes integer this,integer key,itempool value returns nothing
        call SaveItemPoolHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("ItemPool", "itempool")
//textmacro instance: NEW_ARRAY("Quest", "quest")
    function s__Table___quests__getindex takes integer this,integer key returns quest
        return LoadQuestHandle(Table___ht, this, key)
    endfunction
    function s__Table___quests__setindex takes integer this,integer key,quest value returns nothing
        call SaveQuestHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Quest", "quest")
//textmacro instance: NEW_ARRAY("QuestItem", "questitem")
    function s__Table___questitems__getindex takes integer this,integer key returns questitem
        return LoadQuestItemHandle(Table___ht, this, key)
    endfunction
    function s__Table___questitems__setindex takes integer this,integer key,questitem value returns nothing
        call SaveQuestItemHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("QuestItem", "questitem")
//textmacro instance: NEW_ARRAY("DefeatCondition", "defeatcondition")
    function s__Table___defeatconditions__getindex takes integer this,integer key returns defeatcondition
        return LoadDefeatConditionHandle(Table___ht, this, key)
    endfunction
    function s__Table___defeatconditions__setindex takes integer this,integer key,defeatcondition value returns nothing
        call SaveDefeatConditionHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("DefeatCondition", "defeatcondition")
//textmacro instance: NEW_ARRAY("TimerDialog", "timerdialog")
    function s__Table___timerdialogs__getindex takes integer this,integer key returns timerdialog
        return LoadTimerDialogHandle(Table___ht, this, key)
    endfunction
    function s__Table___timerdialogs__setindex takes integer this,integer key,timerdialog value returns nothing
        call SaveTimerDialogHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TimerDialog", "timerdialog")
//textmacro instance: NEW_ARRAY("Leaderboard", "leaderboard")
    function s__Table___leaderboards__getindex takes integer this,integer key returns leaderboard
        return LoadLeaderboardHandle(Table___ht, this, key)
    endfunction
    function s__Table___leaderboards__setindex takes integer this,integer key,leaderboard value returns nothing
        call SaveLeaderboardHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Leaderboard", "leaderboard")
//textmacro instance: NEW_ARRAY("Multiboard", "multiboard")
    function s__Table___multiboards__getindex takes integer this,integer key returns multiboard
        return LoadMultiboardHandle(Table___ht, this, key)
    endfunction
    function s__Table___multiboards__setindex takes integer this,integer key,multiboard value returns nothing
        call SaveMultiboardHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Multiboard", "multiboard")
//textmacro instance: NEW_ARRAY("MultiboardItem", "multiboarditem")
    function s__Table___multiboarditems__getindex takes integer this,integer key returns multiboarditem
        return LoadMultiboardItemHandle(Table___ht, this, key)
    endfunction
    function s__Table___multiboarditems__setindex takes integer this,integer key,multiboarditem value returns nothing
        call SaveMultiboardItemHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("MultiboardItem", "multiboarditem")
//textmacro instance: NEW_ARRAY("Trackable", "trackable")
    function s__Table___trackables__getindex takes integer this,integer key returns trackable
        return LoadTrackableHandle(Table___ht, this, key)
    endfunction
    function s__Table___trackables__setindex takes integer this,integer key,trackable value returns nothing
        call SaveTrackableHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Trackable", "trackable")
//textmacro instance: NEW_ARRAY("Dialog", "dialog")
    function s__Table___dialogs__getindex takes integer this,integer key returns dialog
        return LoadDialogHandle(Table___ht, this, key)
    endfunction
    function s__Table___dialogs__setindex takes integer this,integer key,dialog value returns nothing
        call SaveDialogHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Dialog", "dialog")
//textmacro instance: NEW_ARRAY("Button", "button")
    function s__Table___buttons__getindex takes integer this,integer key returns button
        return LoadButtonHandle(Table___ht, this, key)
    endfunction
    function s__Table___buttons__setindex takes integer this,integer key,button value returns nothing
        call SaveButtonHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Button", "button")
//textmacro instance: NEW_ARRAY("TextTag", "texttag")
    function s__Table___texttags__getindex takes integer this,integer key returns texttag
        return LoadTextTagHandle(Table___ht, this, key)
    endfunction
    function s__Table___texttags__setindex takes integer this,integer key,texttag value returns nothing
        call SaveTextTagHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("TextTag", "texttag")
//textmacro instance: NEW_ARRAY("Lightning", "lightning")
    function s__Table___lightnings__getindex takes integer this,integer key returns lightning
        return LoadLightningHandle(Table___ht, this, key)
    endfunction
    function s__Table___lightnings__setindex takes integer this,integer key,lightning value returns nothing
        call SaveLightningHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Lightning", "lightning")
//textmacro instance: NEW_ARRAY("Image", "image")
    function s__Table___images__getindex takes integer this,integer key returns image
        return LoadImageHandle(Table___ht, this, key)
    endfunction
    function s__Table___images__setindex takes integer this,integer key,image value returns nothing
        call SaveImageHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Image", "image")
//textmacro instance: NEW_ARRAY("Ubersplat", "ubersplat")
    function s__Table___ubersplats__getindex takes integer this,integer key returns ubersplat
        return LoadUbersplatHandle(Table___ht, this, key)
    endfunction
    function s__Table___ubersplats__setindex takes integer this,integer key,ubersplat value returns nothing
        call SaveUbersplatHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Ubersplat", "ubersplat")
//textmacro instance: NEW_ARRAY("Region", "region")
    function s__Table___regions__getindex takes integer this,integer key returns region
        return LoadRegionHandle(Table___ht, this, key)
    endfunction
    function s__Table___regions__setindex takes integer this,integer key,region value returns nothing
        call SaveRegionHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Region", "region")
//textmacro instance: NEW_ARRAY("FogState", "fogstate")
    function s__Table___fogstates__getindex takes integer this,integer key returns fogstate
        return LoadFogStateHandle(Table___ht, this, key)
    endfunction
    function s__Table___fogstates__setindex takes integer this,integer key,fogstate value returns nothing
        call SaveFogStateHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("FogState", "fogstate")
//textmacro instance: NEW_ARRAY("FogModifier", "fogmodifier")
    function s__Table___fogmodifiers__getindex takes integer this,integer key returns fogmodifier
        return LoadFogModifierHandle(Table___ht, this, key)
    endfunction
    function s__Table___fogmodifiers__setindex takes integer this,integer key,fogmodifier value returns nothing
        call SaveFogModifierHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("FogModifier", "fogmodifier")
//textmacro instance: NEW_ARRAY("Hashtable", "hashtable")
    function s__Table___hashtables__getindex takes integer this,integer key returns hashtable
        return LoadHashtableHandle(Table___ht, this, key)
    endfunction
    function s__Table___hashtables__setindex takes integer this,integer key,hashtable value returns nothing
        call SaveHashtableHandle(Table___ht, this, key, value)
    endfunction
//end of: NEW_ARRAY("Hashtable", "hashtable")
   
   
    // Implement modules for intuitive syntax (tb.handle; tb.unit; etc.)
//Implemented from module Table___realm:
    function s__Table__get_real takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___booleanm:
    function s__Table__get_boolean takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___stringm:
    function s__Table__get_string takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___playerm:
    function s__Table__get_player takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___widgetm:
    function s__Table__get_widget takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___destructablem:
    function s__Table__get_destructable takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___itemm:
    function s__Table__get_item takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___unitm:
    function s__Table__get_unit takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___abilitym:
    function s__Table__get_ability takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___timerm:
    function s__Table__get_timer takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___triggerm:
    function s__Table__get_trigger takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___triggerconditionm:
    function s__Table__get_triggercondition takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___triggeractionm:
    function s__Table__get_triggeraction takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___eventm:
    function s__Table__get_event takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___forcem:
    function s__Table__get_force takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___groupm:
    function s__Table__get_group takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___locationm:
    function s__Table__get_location takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___rectm:
    function s__Table__get_rect takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___boolexprm:
    function s__Table__get_boolexpr takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___soundm:
    function s__Table__get_sound takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___effectm:
    function s__Table__get_effect takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___unitpoolm:
    function s__Table__get_unitpool takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___itempoolm:
    function s__Table__get_itempool takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___questm:
    function s__Table__get_quest takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___questitemm:
    function s__Table__get_questitem takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___defeatconditionm:
    function s__Table__get_defeatcondition takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___timerdialogm:
    function s__Table__get_timerdialog takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___leaderboardm:
    function s__Table__get_leaderboard takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___multiboardm:
    function s__Table__get_multiboard takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___multiboarditemm:
    function s__Table__get_multiboarditem takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___trackablem:
    function s__Table__get_trackable takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___dialogm:
    function s__Table__get_dialog takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___buttonm:
    function s__Table__get_button takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___texttagm:
    function s__Table__get_texttag takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___lightningm:
    function s__Table__get_lightning takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___imagem:
    function s__Table__get_image takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___ubersplatm:
    function s__Table__get_ubersplat takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___regionm:
    function s__Table__get_region takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___fogstatem:
    function s__Table__get_fogstate takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___fogmodifierm:
    function s__Table__get_fogmodifier takes integer this returns integer
        return this
    endfunction
//Implemented from module Table___hashtablem:
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
        return LoadInteger(Table___ht, this, key)
    endfunction
   
    //set tb[389034] = 8192
    function s__Table__setindex takes integer this,integer key,integer tb returns nothing
        call SaveInteger(Table___ht, this, key, tb)
    endfunction
   
    //set b = tb.has(2493223)
    function s__Table_has takes integer this,integer key returns boolean
        return HaveSavedInteger(Table___ht, this, key)
    endfunction
   
    //call tb.remove(294080)
    function s__Table_remove takes integer this,integer key returns nothing
        call RemoveSavedInteger(Table___ht, this, key)
    endfunction
   
    //Remove all data from a Table instance
    function s__Table_flush takes integer this returns nothing
        call FlushChildHashtable(Table___ht, this)
    endfunction
   
    //local Table tb = Table.create()
    function s__Table_create takes nothing returns integer
        local integer this= (LoadInteger(Table___ht, ((Table___listK)), (0))) // INLINED!!
       
        if this == 0 then
            set this=Table___more + 1
            set Table___more=this
        else
            call SaveInteger(Table___ht, ((Table___listK)), (0), ( (LoadInteger(Table___ht, ((Table___listK)), (this))))) // INLINED!!
            call RemoveSavedInteger(Table___ht, ((Table___listK)), (this)) //Clear hashed memory // INLINED!!
        endif
       
         call SaveInteger(Table___ht, ((Table___listK)), (this), ( - 1)) // INLINED!!
        return this
    endfunction
   
    // Removes all data from a Table instance and recycles its index.
    //
    //     call tb.destroy()
    //
    function s__Table_destroy takes integer this returns nothing
         if (LoadInteger(Table___ht, ((Table___listK)), (this))) != - 1 then // INLINED!!
             call BJDebugMsg("Table Error: Tried to double-free instance: " + I2S(this))
             return
         endif
       
        call FlushChildHashtable(Table___ht, (this)) // INLINED!!
       
        call SaveInteger(Table___ht, ((Table___listK)), (this), ( (LoadInteger(Table___ht, ((Table___listK)), (0))))) // INLINED!!
        call SaveInteger(Table___ht, ((Table___listK)), (0), ( this)) // INLINED!!
    endfunction
   
//ignored textmacro command: TABLE_BC_METHODS()
   
//ignored textmacro command: TABLE_BC_STRUCTS()
   
   
    //Returns a new TableArray to do your bidding. Simply use:
    //
    //    local TableArray ta = TableArray[array_size]
    //
    function s__TableArray__staticgetindex takes integer array_size returns integer
        local integer tb= (LoadInteger(Table___ht, ((Table___sizeK)), (array_size))) // INLINED!!
        local integer this= (LoadInteger(Table___ht, (tb), (0))) // INLINED!!
       
         if array_size <= 0 then
             call BJDebugMsg("TypeError: Invalid specified TableArray size: " + I2S(array_size))
             return 0
         endif
       
        if this == 0 then
            set this=Table___less - array_size
            set Table___less=this
        else
            call SaveInteger(Table___ht, (tb), (0), ( (LoadInteger(Table___ht, (tb), (this))))) //Set the last destroyed to the last-last destroyed // INLINED!!
            call RemoveSavedInteger(Table___ht, (tb), (this)) //Clear hashed memory // INLINED!!
        endif
       
        call SaveInteger(Table___ht, ((Table___sizeK)), (this), ( array_size)) //This remembers the array size // INLINED!!
        return this
    endfunction
   
    //Returns the size of the TableArray
    function s__TableArray__get_size takes integer this returns integer
        return (LoadInteger(Table___ht, ((Table___sizeK)), (this))) // INLINED!!
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
//#         static if true then
                local integer i= (LoadInteger(Table___ht, ((Table___sizeK)), ((this)))) // INLINED!!
                if i == 0 then
                    call BJDebugMsg("IndexError: Tried to get key from invalid TableArray instance: " + I2S(this))
                    return 0
                elseif key < 0 or key >= i then
                    call BJDebugMsg("IndexError: Tried to get key [" + I2S(key) + "] from outside TableArray bounds: " + I2S(i))
                    return 0
                endif
//#         endif
        return this + key
    endfunction
   
    //Destroys a TableArray without flushing it; I assume you call .flush()
    //if you want it flushed too. This is a public method so that you don't
    //have to loop through all TableArray indices to flush them if you don't
    //need to (ie. if you were flushing all child-keys as you used them).
    //
    function s__TableArray_destroy takes integer this returns nothing
        local integer tb= (LoadInteger(Table___ht, ((Table___sizeK)), ((LoadInteger(Table___ht, ((Table___sizeK)), ((this))))))) // INLINED!!
       
         if (LoadInteger(Table___ht, ((Table___sizeK)), ((this)))) == 0 then // INLINED!!
             call BJDebugMsg("TypeError: Tried to destroy an invalid TableArray: " + I2S(this))
             return
         endif
       
        if tb == 0 then
            //Create a Table to index recycled instances with their array size
            set tb=s__Table_create()
            call SaveInteger(Table___ht, ((Table___sizeK)), ((LoadInteger(Table___ht, ((Table___sizeK)), ((this))))), ( tb)) // INLINED!!
        endif
       
        call RemoveSavedInteger(Table___ht, ((Table___sizeK)), (this)) //Clear the array size from hash memory // INLINED!!
       
        call SaveInteger(Table___ht, (tb), (this), ( (LoadInteger(Table___ht, (tb), (0))))) // INLINED!!
        call SaveInteger(Table___ht, (tb), (0), ( this)) // INLINED!!
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
            call FlushChildHashtable(Table___ht, (tb)) // INLINED!!
            set tb=tb + 1
            exitwhen tb == end
        endloop
    endfunction
   
    //Flushes the TableArray and also destroys it. Doesn't get any more
    //similar to the FlushParentHashtable native than this.
    //
    function s__TableArray_flush takes integer this returns nothing
         if (LoadInteger(Table___ht, ((Table___sizeK)), ((this)))) == 0 then // INLINED!!
             call BJDebugMsg("TypeError: Tried to flush an invalid TableArray instance: " + I2S(this))
             return
         endif
        set s__TableArray_tempTable=this
        set s__TableArray_tempEnd=this + (LoadInteger(Table___ht, ((Table___sizeK)), ((this)))) // INLINED!!
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
//#         static if TimerUtils__USE_HASH_TABLE  then
                // new blue
                call SaveInteger(TimerUtils__ht, 0, GetHandleId(t), value)
                
//#         elseif (TimerUtils__USE_FLEXIBLE_OFFSET) then
//#             // orange
//#             static if  true  then
//#                 if(GetHandleId(t)-TimerUtils__VOFFSET<0) then
//#                     call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
//#                 endif
//#             endif
//#             set TimerUtils__data[GetHandleId(t)-TimerUtils__VOFFSET]=value
//#         else
//#             // new red
//#             static if  true  then
//#                 if(GetHandleId(t)-TimerUtils__OFFSET<0) then
//#                     call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
//#                 endif
//#             endif
//#             set TimerUtils__data[GetHandleId(t)-TimerUtils__OFFSET]=value
//#         endif        
    endfunction

    function GetTimerData takes timer t returns integer
//#         static if TimerUtils__USE_HASH_TABLE  then
                // new blue
                return LoadInteger(TimerUtils__ht, 0, GetHandleId(t))
                
//#         elseif (TimerUtils__USE_FLEXIBLE_OFFSET) then
//#             // orange
//#             static if  true  then
//#                 if(GetHandleId(t)-TimerUtils__VOFFSET<0) then
//#                     call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
//#                 endif
//#             endif
//#             return TimerUtils__data[GetHandleId(t)-TimerUtils__VOFFSET]
//#         else
//#             // new red
//#             static if  true  then
//#                 if(GetHandleId(t)-TimerUtils__OFFSET<0) then
//#                     call BJDebugMsg("SetTimerData: Wrong handle id, only use SetTimerData on timers created by NewTimer")
//#                 endif
//#             endif
//#             return TimerUtils__data[GetHandleId(t)-TimerUtils__OFFSET]
//#         endif        
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
                call TriggerEvaluate(st___prototype1[(1)]) // INLINED!!
                set TimerUtils__tN=TimerUtils__tN - 1
            else
                //If this happens then the QUANTITY rule has already been broken, try to fix the
                // issue, else fail.
                 call BJDebugMsg("NewTimer: Warning, Exceeding TimerUtils_QUANTITY, make sure all timers are getting recycled correctly")
                set s__TimerUtils__tT[0]= CreateTimer()
//#                 static if  not TimerUtils__USE_HASH_TABLE  then
//#                      call BJDebugMsg("In case of errors, please increase it accordingly, or set TimerUtils_USE_HASH_TABLE to true")
//#                     static if  TimerUtils__USE_FLEXIBLE_OFFSET  then
//#                         if (GetHandleId(TimerUtils__tT[0])-TimerUtils__VOFFSET<0) or (GetHandleId(TimerUtils__tT[0])-TimerUtils__VOFFSET>=TimerUtils__ARRAY_SIZE) then
//#                             //all right, couldn't fix it
//#                             call BJDebugMsg("NewTimer: Unable to allocate a timer, you should probably set TimerUtils_USE_HASH_TABLE to true or fix timer leaks.")
//#                             return null
//#                         endif
//#                     else
//#                         if (GetHandleId(TimerUtils__tT[0])-TimerUtils__OFFSET<0) or (GetHandleId(TimerUtils__tT[0])-TimerUtils__OFFSET>=TimerUtils__ARRAY_SIZE) then
//#                             //all right, couldn't fix it
//#                             call BJDebugMsg("NewTimer: Unable to allocate a timer, you should probably set TimerUtils_USE_HASH_TABLE to true or fix timer leaks.")
//#                             return null
//#                         endif
//#                     endif
//#                 endif
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
             call BJDebugMsg("Warning: attempt to release a null timer")
            return
        endif
        if ( TimerUtils__tN == TimerUtils__ARRAY_SIZE ) then
             call BJDebugMsg("Warning: Timer stack is full, destroying timer!!")

            //stack is full, the map already has much more troubles than the chance of bug
            call DestroyTimer(t)
        else
            call PauseTimer(t)
            if ( (LoadInteger(TimerUtils__ht, 0, GetHandleId((t)))) == TimerUtils__HELD ) then // INLINED!!
                 call BJDebugMsg("Warning: ReleaseTimer: Double free!")
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
     
//#         static if  TimerUtils__USE_HASH_TABLE   then
                set TimerUtils__ht=InitHashtable()
                loop
                    exitwhen ( i == TimerUtils__QUANTITY )
                    set s__TimerUtils__tT[i]= CreateTimer()
                    call SaveInteger(TimerUtils__ht, 0, GetHandleId((s__TimerUtils__tT[i] )), ( TimerUtils__HELD)) // INLINED!!
                    set i=i + 1
                endloop
                set TimerUtils__tN=TimerUtils__QUANTITY
//#         else
//#             loop
//#                 set i=0
//#                 loop
//#                     exitwhen (i==TimerUtils__QUANTITY)
//#                     set TimerUtils__tT[i] = CreateTimer()
//#                     if(i==0) then
//#                         set TimerUtils__VOFFSET = GetHandleId(TimerUtils__tT[i])
//#                         static if TimerUtils__USE_FLEXIBLE_OFFSET  then
//#                             set o=TimerUtils__VOFFSET
//#                         else
//#                             set o=TimerUtils__OFFSET
//#                         endif
//#                     endif
//#                     if (GetHandleId(TimerUtils__tT[i])-o>=TimerUtils__ARRAY_SIZE) then
//#                         exitwhen true
//#                     endif
//#                     if (GetHandleId(TimerUtils__tT[i])-o>=0)  then
//#                         set i=i+1
//#                     endif
//#                 endloop
//#                 set TimerUtils__tN = i
//#                 exitwhen(TimerUtils__tN == TimerUtils__QUANTITY)
//#                 set oops = true
//#                 exitwhen not TimerUtils__USE_FLEXIBLE_OFFSET
//#                  call BJDebugMsg("TimerUtils_init: Failed a initialization attempt, will try again")               
//#             endloop
//#             
//#             if(oops) then
//#                 static if   TimerUtils__USE_FLEXIBLE_OFFSET  then
//#                      call BJDebugMsg("The problem has been fixed.")
//#                     //If this message doesn't appear then there is so much
//#                     //handle id fragmentation that it was impossible to preload
//#                     //so many timers and the thread crashed! Therefore this
//#                     //debug message is useful.
//#                 elseif true  then
//#                     call BJDebugMsg("There were problems and the new timer limit is "+I2S(i))
//#                     call BJDebugMsg("This is a rare ocurrence, if the timer limit is too low:")
//#                     call BJDebugMsg("a) Change USE_FLEXIBLE_OFFSET to true (reduces performance a little)")
//#                     call BJDebugMsg("b) or try changing OFFSET to "+I2S(TimerUtils__VOFFSET) )
//#                 endif
//#             endif
//#         endif

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
			
			set s__WorldBounds_worldRegion=CreateRegion()
			
			call RegionAddRect(s__WorldBounds_worldRegion, s__WorldBounds_world)
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
        set slot=(LoadInteger(Table___ht, (s__MissileStats_index), (GetHandleId(u)))) // INLINED!!
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
        call SaveInteger(Table___ht, (s__MissileStats_index), (GetHandleId(u)), ( slot)) // INLINED!!
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
        local integer slot= (LoadInteger(Table___ht, (s__MissileStats_index), (GetHandleId(u)))) // INLINED!!
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
        local integer slot= (LoadInteger(Table___ht, (s__MissileStats_index), (GetHandleId(u)))) // INLINED!!
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
                call RemoveSavedInteger(Table___ht, (s__MissileStats_index), (GetHandleId(s__MissileStats_units[i]))) // INLINED!!
                call s__MissileStats_changeState(i , 0)
                if i != s__MissileStats_tracked then
                    set s__MissileStats_units[i]=s__MissileStats_units[s__MissileStats_tracked]
                    set s__MissileStats_state[i]=s__MissileStats_state[s__MissileStats_tracked]
                    set s__MissileStats_deadline[i]=s__MissileStats_deadline[s__MissileStats_tracked]
                    set s__MissileStats_warned[i]=s__MissileStats_warned[s__MissileStats_tracked]
                    call SaveInteger(Table___ht, (s__MissileStats_index), (GetHandleId(s__MissileStats_units[i])), ( i)) // INLINED!!
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

function MissileDiagnostics__Init takes nothing returns nothing
    call s__MissileStats_initialize()
endfunction

 
//============================================================================
 
//============================================================================
//Implemented from module SpellEffectEvent___M:
   
//#     static if LIBRARY_Table then
//#     else
//#         static hashtable ht = InitHashtable()
//#     endif
   
    function s__SpellEffectEvent___S_onCast takes nothing returns nothing
//#         static if LIBRARY_Table then
                call TriggerEvaluate((LoadTriggerHandle(Table___ht, (((s__SpellEffectEvent___S_tb))), (GetSpellAbilityId())))) // INLINED!!
//#         else
//#             call TriggerEvaluate(LoadTriggerHandle(.ht, 0, GetSpellAbilityId()))
//#         endif
    endfunction
 
    function s__SpellEffectEvent___S_SpellEffectEvent___M__onInit takes nothing returns nothing
//#         static if LIBRARY_Table then
                set s__SpellEffectEvent___S_tb=s__Table_create()
//#         endif
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT , function s__SpellEffectEvent___S_onCast)
    endfunction
 
//============================================================================
function RegisterSpellEffectEvent takes integer abil,code onCast returns nothing
//#     static if LIBRARY_Table then
            if not (HaveSavedHandle(Table___ht, (((s__SpellEffectEvent___S_tb))), (abil))) then // INLINED!!
                call SaveTriggerHandle(Table___ht, (((s__SpellEffectEvent___S_tb))), (abil), ( CreateTrigger())) // INLINED!!
            endif
            call TriggerAddCondition((LoadTriggerHandle(Table___ht, (((s__SpellEffectEvent___S_tb))), (abil))), Filter(onCast)) // INLINED!!
//#     else
//#         if not HaveSavedHandle(SpellEffectEvent___S.ht, 0, abil) then
//#             call SaveTriggerHandle(SpellEffectEvent___S.ht, 0, abil, CreateTrigger())
//#         endif
//#         call TriggerAddCondition(LoadTriggerHandle(SpellEffectEvent___S.ht, 0, abil), Filter(onCast))
//#     endif
endfunction
 

    //=======================================================================
    // Save the map, then delete the exclaimation mark in the following line.
    // Make sure that you don't have an object in your map with the rawcode
    // 'dumi' and also configure the model path (war3mapImported\dummy.mdl)
    // to the dummy.mdx model created by Vexorian.
    // ObjectMerger disabled: dumi is supplied by the TerrainDev object-data build.

    //Thanks to Vexorian that Optimizer 5.0 no longer kills natives



    function MissileRecycler___ToggleIndexer takes boolean flag returns nothing
//#         static if LIBRARY_UnitIndexer then
//#             set UnitIndexer.enabled = flag
//#         elseif LIBRARY_UnitIndexerGUI then
//#             set udg_UnitIndexerEnabled = flag
//#         elseif LIBRARY_UnitDex then
//#             set UnitDex.Enabled = flag
//#         endif
    endfunction


//#     static if true then
            function MissileRecycler___Print takes string s returns nothing
                //Un-comment this next line if you want to know how the system works:
                //call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 999, "[MissileRecycler] " + s)
            endfunction
//#     endif

    //=======================================================================
    // Get a recycled dummy missile unit. If there are no recycled dummies
    // that are already facing the angle you need, it creates a new dummy for
    // you.
    //
    function GetRecycledMissile takes real x,real y,real z,real facing returns unit
        local integer i= ModuloInteger(R2I(facing), 360) / MissileRecycler___ANG_VAL
        local integer this= MissileRecycler___queueNext[i]
        local unit u
        if this != 0 and TimerGetElapsed(MissileRecycler___gameTime) >= MissileRecycler___timeStamp[this] then
            //Dequeue this
            set MissileRecycler___queueNext[i]=MissileRecycler___queueNext[this]
            if MissileRecycler___queueNext[i] == 0 then
                set MissileRecycler___queueLast[i]=i
            endif
            //Recycle this index
            set MissileRecycler___queueLast[this]=MissileRecycler___recycle
            set MissileRecycler___recycle=this
            //Add queue index to available stack
            set MissileRecycler___queueStack[MissileRecycler___queueStackN]=i
            set MissileRecycler___queueStackN=MissileRecycler___queueStackN + 1
            //Old unit will return as new
            set u=MissileRecycler___stack[this]
            call SetUnitFacing(u, facing)
            call SetUnitUserData(u, 0)
            //Reset the dummy's properties.
            call SetUnitVertexColor(u, 255, 255, 255, 255)
            call SetUnitAnimationByIndex(u, 90)
            call SetUnitScale(u, 1, 0, 0)
//#             static if LIBRARY_MissileDiagnostics then
                    call s__MissileStats_acquire(u , true)
//#             endif
            //call PauseUnit(u, false) -- you can disable "resets" that you don't need to worry about.
             call MissileRecycler___Print("Recycling")
        else
             call MissileRecycler___Print("Creating new")
            call MissileRecycler___ToggleIndexer(false)
            set u=CreateUnit(MissileRecycler___OWNER, MissileRecycler___DUMMY_ID, x, y, facing)
            call MissileRecycler___ToggleIndexer(true)
            call PauseUnit(u, true)
//#             static if LIBRARY_MissileDiagnostics then
                    call s__MissileStats_acquire(u , false)
//#             endif
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
        local integer this= MissileRecycler___recycle
        if GetUnitTypeId(u) == MissileRecycler___DUMMY_ID and UnitAlive(u) and GetUnitUserData(u) != - 1 then
            if MissileRecycler___queueStackN == 0 then
                 call MissileRecycler___Print("Stack is full - removing surplus unit")
//#                 static if LIBRARY_MissileDiagnostics then
                        call s__MissileStats_returned(u , false , MissileRecycler___DEATH_TIME)
//#                 endif
                // TerrainDev / Classic 1.27b: paused units freeze timed life.
                // Only surplus units leave the paused pool before disposal.
                call PauseUnit(u, false)
                call UnitApplyTimedLife(u, 'BTLF', MissileRecycler___DEATH_TIME)
                return
            endif
            //Recycle this
            set MissileRecycler___recycle=MissileRecycler___queueLast[this]
            //Index the dummy unit to an available facing angle.
            //Get the last vacant angle index.
            set MissileRecycler___queueStackN=MissileRecycler___queueStackN - 1
            set i=MissileRecycler___queueStack[MissileRecycler___queueStackN]
            //Enqueue this
            set MissileRecycler___queueNext[MissileRecycler___queueLast[i]]=this
            set MissileRecycler___queueLast[i]=this
            set MissileRecycler___queueNext[this]=0
            //Allow a time barrier for the effect to destroy/turn to complete.
            set MissileRecycler___timeStamp[this]=TimerGetElapsed(MissileRecycler___gameTime) + MissileRecycler___DEATH_TIME
            set MissileRecycler___stack[this]=u
            call SetUnitFacing(u, i * MissileRecycler___ANG_VAL + MissileRecycler___ANG_MID)
            call SetUnitOwner(u, MissileRecycler___OWNER, false)
            //Prevent double-free of this unit.
            call SetUnitUserData(u, - 1)
//#             static if LIBRARY_MissileDiagnostics then
                    call s__MissileStats_returned(u , true , MissileRecycler___DEATH_TIME)
//#             endif
        else
//#             static if LIBRARY_MissileDiagnostics then
                    call s__MissileStats_invalidReturn()
//#             endif
             call BJDebugMsg("[MissileRecycler] Error: Attempt to recycle invalid unit.")
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
    function MissileRecycler___Init takes nothing returns nothing
        local integer end
        local integer i= MissileRecycler___ANG_N
        local integer n= i
        local integer angle
        local real x= GetRectMaxX(bj_mapInitialPlayableArea)
        local real y= GetRectMaxY(bj_mapInitialPlayableArea)
        local unit u
//#         static if LIBRARY_MissileDiagnostics then
                call s__MissileStats_configure(MissileRecycler___ANG_N * MissileRecycler___ANG_STORAGE_MAX)
//#         endif
        call MissileRecycler___ToggleIndexer(false)
        loop
            set i=i - 1
            set MissileRecycler___queueNext[i]=n
            set angle=i * MissileRecycler___ANG_VAL + MissileRecycler___ANG_MID
            set end=n + MissileRecycler___ANG_STORAGE_MAX
            set MissileRecycler___queueLast[i]=end - 1
            loop
                set MissileRecycler___queueNext[n]=n + 1
                set u=CreateUnit(MissileRecycler___OWNER, MissileRecycler___DUMMY_ID, x, y, angle)
                set MissileRecycler___stack[n]=u
                call PauseUnit(u, true)
                call SetUnitUserData(u, - 1)
//#                 static if LIBRARY_MissileDiagnostics then
                        call s__MissileStats_preload(u)
//#                 endif
                set n=n + 1
                exitwhen n == end
            endloop
            set MissileRecycler___queueNext[n - 1]=0
            exitwhen i == 0
        endloop
        call MissileRecycler___ToggleIndexer(true)
        call TimerStart(MissileRecycler___gameTime, 1000000., false, null)
        set u=null
    endfunction

    function MissileRecycler___PreInit takes nothing returns nothing
//#         static if LIBRARY_UnitIndexerGUI then
//#             call OnUnitIndexerInitialized(function MissileRecycler___Init)
//#         else
                call MissileRecycler___Init()
//#         endif
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
    
    
    function Missile__ToogleUnitIndexer takes boolean enable returns boolean
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
        call MoveLocation(Missile__LOC, x, y)
        return GetLocationZ(Missile__LOC)
    endfunction
    
    // For WRITE_DELAYED_MISSILE_RECYCLING = true Missile will hold back
    // dummies for DELAYED_MISSILE_DEATH_ANIMATION_TIME before they are recylced. ( Code placed in a static if )
    //
//textmacro instance: WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")
//#     static if Missile_WRITE_DELAYED_MISSILE_RECYCLING then
    
         
                function s__Missile__RecycleBin_onPeriodic takes nothing returns nothing
                    local integer dex= 0
                    loop
                        exitwhen dex == s__Missile__RecycleBin_max
                        set s__Missile__RecycleBin_time[dex]=s__Missile__RecycleBin_time[dex] - 1
                        if 0 >= s__Missile__RecycleBin_time[dex] then
                        
//#                         static if LIBRARY_MissileRecycler then
                                call RecycleMissile(s__Missile__RecycleBin_dummy[dex])
                        
//#                         elseif Dummy.create.exists and LIBRARY_Dummy then
//#                             call Dummy[Missile__RecycleBin.dummy[dex]].destroy()
//#                         
//#                         elseif LIBRARY_xedummy and xedummy.release.exists then
//#                             call xedummy.release(Missile__RecycleBin.dummy[dex])
//#                     
//#                         else
//#                             call RemoveUnit(Missile__RecycleBin.dummy[dex])
//#                         endif
                        
                            set s__Missile__RecycleBin_dummy[dex]=null
                            set s__Missile__RecycleBin_max=s__Missile__RecycleBin_max - 1
                            set s__Missile__RecycleBin_dummy[dex]=s__Missile__RecycleBin_dummy[s__Missile__RecycleBin_max]
                            set s__Missile__RecycleBin_time[dex]=s__Missile__RecycleBin_time[s__Missile__RecycleBin_max]
                            set s__Missile__RecycleBin_dummy[s__Missile__RecycleBin_max]=null
                            set dex=dex - 1
                        
                            if 0 == s__Missile__RecycleBin_max then
                                call PauseTimer(s__Missile__RecycleBin_t)
                            endif
                        
                        endif
                        set dex=dex + 1
                    endloop
                endfunction
        
                function s__Missile__RecycleBin_recycle takes unit toRecycle returns nothing
                    if 0 == s__Missile__RecycleBin_max then
                        call TimerStart(s__Missile__RecycleBin_t, 1., true, function s__Missile__RecycleBin_onPeriodic)
                    endif
                    set s__Missile__RecycleBin_dummy[s__Missile__RecycleBin_max]=toRecycle
                    set s__Missile__RecycleBin_time[s__Missile__RecycleBin_max]=Missile__DELAYED_MISSILE_DEATH_ANIMATION_TIME + TimerGetRemaining(s__Missile__RecycleBin_t)
//#                 static if LIBRARY_MissileDiagnostics then
                        // The existing bin advances in whole seconds; allow its next tick.
                        call s__MissileStats_delay(toRecycle , Missile__DELAYED_MISSILE_DEATH_ANIMATION_TIME + 1.)
//#                 endif
                    set s__Missile__RecycleBin_max=s__Missile__RecycleBin_max + 1
                endfunction
        
//#     endif
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
//Implemented from module Missile__MissileStructure:
        
//#         static if LIBRARY_ErrorMessage then
//#         endif
        
        function s__Missile__get_list takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
                     call ThrowError(this == 0 , "MissileStructure" , "list" , "Missile" , this , "Attempted To Read Null Node.")
                     call ThrowError(not s__Missile_Missile__MissileStructure___isNode[this] , "MissileStructure" , "list" , "Missile" , this , "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile__MissileStructure____list[this]
        endfunction
        
        function s__Missile__get_next takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
                     call ThrowError(this == 0 , "MissileStructure" , "next" , "Missile" , this , "Attempted To Go Out Of Bounds.")
                     call ThrowError(not s__Missile_Missile__MissileStructure___isNode[this] , "MissileStructure" , "next" , "Missile" , this , "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile__MissileStructure____next[this]
        endfunction
        
        function s__Missile__get_prev takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
                     call ThrowError(this == 0 , "MissileStructure" , "prev" , "Missile" , this , "Attempted To Go Out Of Bounds.")
                     call ThrowError(not s__Missile_Missile__MissileStructure___isNode[this] , "MissileStructure" , "prev" , "Missile" , this , "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile__MissileStructure____prev[this]
        endfunction
        
        function s__Missile__get_first takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
                     call ThrowError(this == 0 , "MissileStructure" , "first" , "Missile" , this , "Attempted To Read Null List.")
                     call ThrowError(not s__Missile_Missile__MissileStructure___isCollection[this] , "MissileStructure" , "first" , "Missile" , this , "Attempted To Read Invalid List.")
//#             endif
            return s__Missile_Missile__MissileStructure____first[this]
        endfunction
        
        function s__Missile__get_last takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
                     call ThrowError(this == 0 , "MissileStructure" , "last" , "Missile" , this , "Attempted To Read Null List.")
                     call ThrowError(not s__Missile_Missile__MissileStructure___isCollection[this] , "MissileStructure" , "last" , "Missile" , this , "Attempted To Read Invalid List.")
//#             endif
            return s__Missile_Missile__MissileStructure____last[this]
        endfunction
        
        function s__Missile_allocateCollection takes nothing returns integer
            local integer this= s__Missile_Missile__MissileStructure____first[(0)]
            
            if ( 0 == this ) then
//#                 static if LIBRARY_ErrorMessage then
                         call ThrowError(s__Missile_Missile__MissileStructure___collectionCount == 8191 , "MissileStructure" , "allocateCollection" , "Missile" , 0 , "Overflow.")
//#                 endif
                
                set this=s__Missile_Missile__MissileStructure___collectionCount + 1
                set s__Missile_Missile__MissileStructure___collectionCount=this
            else
                set s__Missile_Missile__MissileStructure____first[(0)]=s__Missile_Missile__MissileStructure____first[this]
            endif
            
//#             static if LIBRARY_ErrorMessage then
                     set s__Missile_Missile__MissileStructure___isCollection[this]=true
//#             endif
            
            set s__Missile_Missile__MissileStructure____first[this]=0
            
            return this
        endfunction
        
        function s__Missile_allocateNode takes nothing returns integer
            local integer this= s__Missile_Missile__MissileStructure____next[(0)]
            
            if ( 0 == this ) then
//#                 static if LIBRARY_ErrorMessage then
                         call ThrowError(s__Missile_Missile__MissileStructure___nodeCount == 8191 , "MissileStructure" , "allocateNode" , "Missile" , 0 , "Overflow.")
//#                 endif
                
                set this=s__Missile_Missile__MissileStructure___nodeCount + 1
                set s__Missile_Missile__MissileStructure___nodeCount=this
            else
                set s__Missile_Missile__MissileStructure____next[(0)]=s__Missile_Missile__MissileStructure____next[this]
            endif
            
            set s__Missile_allocated[this]=true
            
            return this
        endfunction
        
        function s__Missile_insertFront takes integer this,integer node returns integer
            
            // Extra static unique list for missile motion.
            set Missile__nextNode[node]=0
            set Missile__prevNode[node]=Missile__prevNode[0]
            set Missile__nextNode[Missile__prevNode[0]]=node
            set Missile__prevNode[0]=node
            
//#             static if LIBRARY_ErrorMessage then
                     call ThrowError(this == 0 , "List" , "push" , "Missile" , this , "Attempted To Push On To Null List.")
                     call ThrowError(not s__Missile_Missile__MissileStructure___isCollection[this] , "List" , "push" , "Missile" , this , "Attempted To Push On To Invalid List.")
                     set s__Missile_Missile__MissileStructure___isNode[node]=true
//#             endif
            
            set s__Missile_Missile__MissileStructure____list[node]=this
        
            if ( s__Missile_Missile__MissileStructure____first[this] == 0 ) then
                set s__Missile_Missile__MissileStructure____first[this]=node
                set s__Missile_Missile__MissileStructure____last[this]=node
                set s__Missile_Missile__MissileStructure____next[node]=0
            else
                set s__Missile_Missile__MissileStructure____prev[s__Missile_Missile__MissileStructure____first[this]]=node
                set s__Missile_Missile__MissileStructure____next[node]=s__Missile_Missile__MissileStructure____first[this]
                set s__Missile_Missile__MissileStructure____first[this]=node
            endif
            
            set s__Missile_Missile__MissileStructure____prev[node]=0
            
            return node
        endfunction
      
        function s__Missile_Missile__remove takes integer this returns nothing
            local integer node= this
            set this=s__Missile_Missile__MissileStructure____list[node]
            
//#             static if LIBRARY_ErrorMessage then
                     call ThrowError(node == 0 , "MissileStructure" , "remove" , "Missile" , this , "Attempted To Remove Null Node.")
                     call ThrowError(not s__Missile_Missile__MissileStructure___isNode[node] , "MissileStructure" , "remove" , "Missile" , this , "Attempted To Remove Invalid Node (" + I2S(node) + ").")
                     set s__Missile_Missile__MissileStructure___isNode[node]=false
//#             endif
            
            set s__Missile_Missile__MissileStructure____list[node]=0
        
            if ( 0 == s__Missile_Missile__MissileStructure____prev[node] ) then
                set s__Missile_Missile__MissileStructure____first[this]=s__Missile_Missile__MissileStructure____next[node]
            else
                set s__Missile_Missile__MissileStructure____next[s__Missile_Missile__MissileStructure____prev[node]]=s__Missile_Missile__MissileStructure____next[node]
            endif
            if ( 0 == s__Missile_Missile__MissileStructure____next[node] ) then
                set s__Missile_Missile__MissileStructure____last[this]=s__Missile_Missile__MissileStructure____prev[node]
            else
                set s__Missile_Missile__MissileStructure____prev[s__Missile_Missile__MissileStructure____next[node]]=s__Missile_Missile__MissileStructure____prev[node]
            endif
            
            set s__Missile_Missile__MissileStructure____next[node]=s__Missile_Missile__MissileStructure____next[(0)]
            set s__Missile_Missile__MissileStructure____next[(0)]=node
            
            set s__Missile_allocated[node]=false
            
            // Static unique list for missile motion.
            set Missile__nextNode[Missile__prevNode[node]]=Missile__nextNode[node]
            set Missile__prevNode[Missile__nextNode[node]]=Missile__prevNode[node]
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
//#                 static if LIBRARY_MissileDiagnostics then
                        call s__MissileStats_released(this)
//#                 endif
                call s__Missile_Missile__remove(this)
                call s__MissilePosition_destroy(s__Missile_impact[this])
                call s__MissilePosition_destroy(s__Missile_origin[this])
            
                call DestroyEffect(s__Missile_sfx[this])
                call FlushChildHashtable(Missile__HASH, this)
                if GetUnitTypeId(s__Missile_dummy[this]) == Missile_DUMMY_UNIT_ID then
                    // MissileRecycler > Dummy > xe.
//#                     static if LIBRARY_MissileRecycler then
                            call RecycleMissile(s__Missile_dummy[this])
//#                     elseif LIBRARY_Dummy and Dummy.create.exists then
//#                         call Dummy[dummy].destroy()
//#                     elseif LIBRARY_xedummy and xedummy.release.exists then
//#                         call xedummy.release(dummy)
//#                     else
//#                         call RemoveUnit(dummy)
//#                     endif
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
            call SaveUnitHandle(Missile__HASH, this, GetHandleId(missileDummy), missileDummy)
            //
//#             static if LIBRARY_ErrorMessage then
                     call ThrowWarning(GetUnitTypeId(missileDummy) == 0 , "Missile" , "createEx" , "missileDummy" , this , "Invalid missile dummy unit ( null )!")
//#             endif
             set s__Missile_launched[this]=false
//#             static if LIBRARY_MissileDiagnostics then
                    call s__MissileStats_allocated(this)
//#             endif
            return this
        endfunction
    
        // Freaky static if ensures these libraries really don't exist.
//#         static if not LIBRARY_MissileRecycler and not LIBRARY_Dummy and not Dummy.create.exists and not LIBRARY_xe_dummy and not xe_dummy.new.exists then
//#             private static method newMissileUnit takes real x, real y, real z, real face returns unit
//#                 local boolean prev = Missile__ToogleUnitIndexer(false)
//#                 set bj_lastCreatedUnit = CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID , x, y, face)
//#                 call Missile__ToogleUnitIndexer(prev)
//#                 call SetUnitX(bj_lastCreatedUnit, x)
//#                 call SetUnitY(bj_lastCreatedUnit, y)
//#                 call UnitAddAbility(bj_lastCreatedUnit, 'Amrf')
//#                 call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0.)
//#                 call PauseUnit(bj_lastCreatedUnit, true)
//#                 return bj_lastCreatedUnit
//#             endmethod
//#         endif
    
        // MissileRecylcer > Dummy > xe > Missile.
    
        // Wrapper to createEx.
        function s__Missile_create takes real x,real y,real z,real angle,real distance,real impactZ returns integer
            local real impactX= x + distance * Cos(angle)
            local real impactY= y + distance * Sin(angle)
            // Get the dummy unit.
//textmacro instance: MISSILE_GET_DUMMY_FROM_LIBRARY()
//#             static if LIBRARY_MissileRecycler then
                    return s__Missile_createEx(GetRecycledMissile(x , y , z , angle * bj_RADTODEG) , impactX , impactY , impactZ)
            
//#             elseif LIBRARY_Dummy and Dummy.create.exists then
//#                 local Dummy dummy = Dummy.create(x, y, angle*bj_RADTODEG)
//#                 call SetUnitFlyHeight(dummy.unit, z, 0.)
//#                 return createEx(dummy.unit, impactX, impactY, impactZ)
//#         
//#             elseif LIBRARY_xedummy and xedummy.new.exists then
//#                 set bj_lastCreatedUnit = xedummy.new(Missile_NEUTRAL_PASSIVE, x, y, angle*bj_RADTODEG)
//#                 call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0.)
//#                 return createEx(bj_lastCreatedUnit, impactX, impactY, impactZ)
//#             
//#             else
//#                 return createEx(Missile.newMissileUnit(x, y, z, angle*bj_RADTODEG), impactX, impactY, impactZ)
//#             endif
//end of: MISSILE_GET_DUMMY_FROM_LIBRARY()
        endfunction
        
        // Wrapper to createEx.
        function s__Missile_createXYZ takes real x,real y,real z,real impactX,real impactY,real impactZ returns integer
            local real angle= Atan2(impactY - y, impactX - x)
            // Get the dummy unit.
//textmacro instance: MISSILE_GET_DUMMY_FROM_LIBRARY()
//#             static if LIBRARY_MissileRecycler then
                    return s__Missile_createEx(GetRecycledMissile(x , y , z , angle * bj_RADTODEG) , impactX , impactY , impactZ)
            
//#             elseif LIBRARY_Dummy and Dummy.create.exists then
//#                 local Dummy dummy = Dummy.create(x, y, angle*bj_RADTODEG)
//#                 call SetUnitFlyHeight(dummy.unit, z, 0.)
//#                 return createEx(dummy.unit, impactX, impactY, impactZ)
//#         
//#             elseif LIBRARY_xedummy and xedummy.new.exists then
//#                 set bj_lastCreatedUnit = xedummy.new(Missile_NEUTRAL_PASSIVE, x, y, angle*bj_RADTODEG)
//#                 call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0.)
//#                 return createEx(bj_lastCreatedUnit, impactX, impactY, impactZ)
//#             
//#             else
//#                 return createEx(Missile.newMissileUnit(x, y, z, angle*bj_RADTODEG), impactX, impactY, impactZ)
//#             endif
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
                call MoveLocation(Missile__LOC, newX, newY)
                set s__Missile_terrainZ[this]=GetLocationZ(Missile__LOC)
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
//#                 static if not LIBRARY_BoundSentinel and not LIBRARY_WorldBounds then
//#                     if RectContainsCoords(bj_mapInitialPlayableArea, newX, newY) then
//#                         call SetUnitX(u, newX)
//#                         call SetUnitY(u, newY)
//#                     endif                    
//#                 elseif LIBRARY_WorldBounds then
                        if newX < s__WorldBounds_maxX and newX > s__WorldBounds_minX and newY < s__WorldBounds_maxY and newY > s__WorldBounds_minY then
                            call SetUnitX(u, newX)
                            call SetUnitY(u, newY)
                        endif
//#                 else
//#                     call SetUnitX(u, newX)
//#                     call SetUnitY(u, newY)
//#                 endif
                
                set loops=loops + 1
                set this=Missile__nextNode[this]
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
                call SaveWidgetHandle(Missile__HASH, this, GetHandleId(w), w)
            endif
        endfunction
        
        // All widget which have been hit return true.
        function s__Missile_hasHitWidget takes integer this,widget w returns boolean
            return HaveSavedHandle(Missile__HASH, this, GetHandleId(w))
        endfunction
        
        // Removes a widget from the missile's memory of hit widgets. ( This widget can be hit again )
        function s__Missile_removeHitWidget takes integer this,widget w returns nothing
            if w != null then
                call RemoveSavedHandle(Missile__HASH, this, GetHandleId(w))
            endif
        endfunction
        
        // Flushes a missile's memory for collision. ( All widgets can be hit again )
        function s__Missile_flushHitWidgets takes integer this returns nothing
            call FlushChildHashtable(Missile__HASH, this)
            call s__Missile_hitWidget(this,s__Missile_dummy[this])
        endfunction
        
        // Tells missile to call removeHitWidget(w) after "seconds" time.
        // Does not apply to widgets, which are already hit by this missile.
        function s__Missile_enableHitAfter takes integer this,widget w,real seconds returns nothing
            local integer id= GetHandleId(w)
            if w != null then
                if not HaveSavedInteger(Missile__HASH, this, id) then
                    call SaveInteger(Missile__HASH, this, id, s__Missile_stackSize[this])
                    call SaveInteger(Missile__HASH, this, s__Missile_stackSize[this], id)
                    set s__Missile_stackSize[this]=s__Missile_stackSize[this] + 1
                endif
                call SaveReal(Missile__HASH, this, id, seconds) // Set time.
            endif
        endfunction
        
        function s__Missile_updateStack takes integer this returns nothing
            local integer dex= 0
            local integer id
            local real time
            loop
                exitwhen dex == s__Missile_stackSize[this]
                set id=LoadInteger(Missile__HASH, this, dex)
                set time=LoadReal(Missile__HASH, this, id) - Missile_TIMER_TIMEOUT
                if time <= 0. or not HaveSavedHandle(Missile__HASH, this, id) then
                    set s__Missile_stackSize[this]=s__Missile_stackSize[this] - 1
                    set id=LoadInteger(Missile__HASH, this, s__Missile_stackSize[this])
                    call SaveInteger(Missile__HASH, this, dex, id)
                    call SaveInteger(Missile__HASH, this, id, dex)
                    // Enables hit.
                    call RemoveSavedHandle(Missile__HASH, this, id)
                    // Remove data from stack.
                    call RemoveSavedReal(Missile__HASH, this, id)
                    call RemoveSavedInteger(Missile__HASH, this, id)
                    call RemoveSavedInteger(Missile__HASH, this, s__Missile_stackSize[this])
                else
                    call SaveReal(Missile__HASH, this, id, time)
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
            if not HaveSavedHandle(Missile__HASH, s__Missile_temp, GetHandleId(d)) then
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
            if not HaveSavedHandle(Missile__HASH, s__Missile_temp, GetHandleId(i)) then
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
            
            if not HaveSavedHandle(Missile__HASH, this, GetHandleId(u)) then
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
                    call SetRect(Missile__RECT, x1 - d, y1 - d, x2 + d, y2 + d)
                else
                    call SetRect(Missile__RECT, x1 - d, y2 - d, x2 + d, y1 + d)
                endif
            elseif y1 < y2 then
                call SetRect(Missile__RECT, x2 - d, y1 - d, x1 + d, y2 + d)
            else
                call SetRect(Missile__RECT, x2 - d, y2 - d, x1 + d, y1 + d)
            endif
        endfunction
        //
        // For circular.
        function s__Missile_prepareRectCircle takes integer this returns nothing
            local real d= s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE
            call SetRect(Missile__RECT, s__Missile_x[this] - d, s__Missile_y[this] - d, s__Missile_x[this] + d, s__Missile_y[this] + d)
        endfunction
        //
        // 5.) API for the MissileStruct iteration.
        //
        function s__Missile_groupEnumUnitsRectangle takes integer this returns nothing
            call s__Missile_prepareRectRectangle(this)
            set s__Missile_temp=this
            call GroupEnumUnitsInRect(Missile__GROUP, Missile__RECT, Missile__unitFilter)
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
            call EnumDestructablesInRect(Missile__RECT, Missile__destFilter, func)
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
            call EnumItemsInRect(Missile__RECT, Missile__itemFilter, func)
        endfunction

//# static if Missile_WRITE_DELAYED_MISSILE_RECYCLING then
        function s__Missile_nullBefore takes integer this returns nothing
            set s__Missile_dummy[this]=null
        endfunction
//# endif

// Does not check for 'Aloc' and 'Amrf' as they could be customized.
        function s__Missile_onInit takes nothing returns nothing
//#             static if LIBRARY_ErrorMessage then
                     local boolean prev= Missile__ToogleUnitIndexer(false)
                     local unit dummy= CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, 0., 0., 0.)
                     call Missile__ToogleUnitIndexer(prev)
                    //
                     call ThrowError(( GetUnitTypeId(dummy) != Missile_DUMMY_UNIT_ID ) , "Missile" , "DEBUG_MISSILE" , "type id" , 0 , "Global setup for public integer DUMMY_UNIT_ID is incorrect! This map currently can't use Missile!")
                     call ThrowError(( Missile_MAXIMUM_COLLISION_SIZE < 0 ) , "Missile" , "DEBUG_MISSILE" , "collision" , 0 , "Global setup for public real MAXIMUM_COLLISION_SIZE is incorrect, below zero! This map currently can't use Missile!")
                     call RemoveUnit(dummy)
                     set dummy=null
//#             endif
            //
            set Missile__unitFilter=Filter(function s__Missile_filterUnits)
            set Missile__destFilter=Filter(function s__Missile_filterDests)
            set Missile__itemFilter=Filter(function s__Missile_filterItems)
            call TriggerAddCondition(Missile__MOVE, Condition(function s__Missile_move))
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
    function Missile__MissileCreateExpression takes integer structId,code func returns nothing
        set Missile__expression[structId]=Condition(func)
    endfunction
    
    // Creates a collection for a struct. ( Runs for all struct using module MissileStruct )
    function Missile__MissileCreateCollection takes integer structId returns nothing
        set Missile__missileList[structId]=s__Missile_allocateCollection()
    endfunction
    
    // Core:
    // =====
    //
    // Fires every Missile_TIMER_TIMEOUT.
    function Missile__Fire takes nothing returns nothing
        local integer i= Missile__remove[0]
        set Missile__remove[0]=0
        loop
            exitwhen 0 == i
            if Missile__recycling[i] then
                call TriggerRemoveCondition(Missile__CORE, Missile__condition[i])
                set Missile__condition[i]=null
                set Missile__active=Missile__active - 1
            endif
            set Missile__destroying[i]=false
            set Missile__recycling[i]=false
            set i=Missile__remove[i]
        endloop
        
        if 0 == Missile__active then
            call PauseTimer(Missile__TMR)
        else
            // Move all launched missiles.
            set s__Missile_temp=Missile__nextNode[0]
            set i=0
            loop
                exitwhen TriggerEvaluate(Missile__MOVE)
                exitwhen i == 60 // Moved over 8910 missiles, something buggy happened.
                set i=i + 1 // This case is impossible, hence never happens. But if I'm wrong, which also never happens 
            endloop // then the map 100% crashes. i == 66 will prevent the game crash and Missile will start to 
                                // to debug itself over the next iterations.
        
            // Access all structs using module MissileStruct. 
//#             static if true and LIBRARY_ErrorMesssage then
//#                 if not TriggerEvaluate(Missile__CORE) then
//#                     call ThrowWarning(true, "Missile", "Fire", "op limit", 0, "You just ran into a op limit!\nThe op limit protection of Missile is insufficient for your map.\nThe code of the missile module can't run in one thread and must be splitted.\nIf unsure make a post in the official 'The Hive Workshop' forum thread of Missile!")
//#                 endif
//#             else
                    call TriggerEvaluate(Missile__CORE)
//#             endif
        endif
    endfunction
    
    // Conditionally starts the timer.
    function Missile__StartPeriodic takes integer structId returns nothing
        if 0 == Missile__instances[structId] or Missile__destroying[structId] then
            if Missile__destroying[structId] then
                set Missile__recycling[structId]=false
            else
                if 0 == Missile__active then
                    call TimerStart(Missile__TMR, Missile_TIMER_TIMEOUT, true, function Missile__Fire)
                endif
                set Missile__active=Missile__active + 1
                set Missile__condition[structId]=TriggerAddCondition(Missile__CORE, Missile__expression[structId])
            endif
        endif
        set Missile__instances[structId]=Missile__instances[structId] + 1
    endfunction
    
    // Conditionally stops the timer in the next callback.
    function Missile__StopPeriodic takes integer structId returns nothing
        set Missile__instances[structId]=Missile__instances[structId] - 1
        if 0 == Missile__instances[structId] and Missile__condition[structId] != null then
            if not Missile__destroying[structId] and not Missile__recycling[structId] then
                set Missile__destroying[structId]=true
                set Missile__recycling[structId]=true
                set Missile__remove[structId]=Missile__remove[0]
                set Missile__remove[0]=structId
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

//===========================================================================
// 
// Swamped Temple_v2
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Date: Wed Oct 21 02:44:20 2026
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
// Trigger: WorldBounds
//
// TerrainDev foundation; original author credits in code.
//===========================================================================
// Trigger: ErrorMessage
//
// TerrainDev foundation; original author credits in code.
//===========================================================================

//===========================================================================
// Trigger: TimerUtils
//
// TerrainDev foundation; original author credits in code.
//===========================================================================
// Trigger: Table
//
// TerrainDev foundation; original author credits in code.
//===========================================================================
// Trigger: RegisterPlayerUnitEvent
//
// TerrainDev foundation; original author credits in code.
//===========================================================================

//===========================================================================
// Trigger: SpellEffectEvent
//
// TerrainDev foundation; original author credits in code.
//===========================================================================
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
// Trigger: IsDestructableTree
//
// TerrainDev foundation; original author credits in code.
//===========================================================================
// Trigger: DummyCaster
//
// TerrainDev foundation; original author credits in code.
//===========================================================================
//===========================================================================
// Trigger: MissileDiagnostics
//
// TerrainDev foundation; original author credits in code.
//===========================================================================
// TerrainDev local instrumentation, Classic 1.27b. See docs/planes/multiboard-misiles.md.
// Hooks only observe: never kill, unpause, move or recycle gameplay objects.
//===========================================================================
// Trigger: MissileRecycler
//
// TerrainDev foundation; original author credits in code.
//===========================================================================
//===========================================================================
// Trigger: Missile
//
// TerrainDev foundation; original author credits in code.
//===========================================================================
//===========================================================================
function InitCustomTriggers takes nothing returns nothing
    call InitTrig_Melee_Initialization()
    call InitTrig_TurtleNet()
    //Function not found: call InitTrig_WorldBounds()
    //Function not found: call InitTrig_ErrorMessage()
    //Function not found: call InitTrig_TimerUtils()
    //Function not found: call InitTrig_Table()
    //Function not found: call InitTrig_RegisterPlayerUnitEvent()
    //Function not found: call InitTrig_SpellEffectEvent()
    //Function not found: call InitTrig_IsDestructableTree()
    //Function not found: call InitTrig_DummyCaster()
    //Function not found: call InitTrig_MissileDiagnostics()
    //Function not found: call InitTrig_MissileRecycler()
    //Function not found: call InitTrig_Missile()
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

    call ExecuteFunc("jasshelper__init4215")

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

//Functions for BigArrays:
function sa___prototype1_TimerUtils__init takes nothing returns boolean

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

function jasshelper__init4215 takes nothing returns nothing
    set st___prototype1[1]=CreateTrigger()
    call TriggerAddAction(st___prototype1[1],function sa___prototype1_TimerUtils__init)
    call TriggerAddCondition(st___prototype1[1],Condition(function sa___prototype1_TimerUtils__init))


call ExecuteFunc("s__DummyCaster_DummyCaster___N__onInit")
//------------------------------------
call ExecuteFunc("s__IsDestructableTree__I_IsDestructableTree__Inits___onInit")
//------------------------------------
call ExecuteFunc("TimerUtils__init")
//------------------------------------
call ExecuteFunc("s__WorldBounds_WorldBounds__WorldBoundInit___onInit")
//------------------------------------
call ExecuteFunc("MissileDiagnostics__Init")
//------------------------------------
call ExecuteFunc("s__SpellEffectEvent___S_SpellEffectEvent___M__onInit")
//------------------------------------
call ExecuteFunc("MissileRecycler___PreInit")
//------------------------------------
call ExecuteFunc("s__Missile_onInit")
//------------------------------------

endfunction

