globals
//globals from RegisterPlayerUnitEvent:
constant boolean LIBRARY_RegisterPlayerUnitEvent=true
trigger array RegisterPlayerUnitEvent___t
//endglobals from RegisterPlayerUnitEvent
//globals from WorldBounds:
constant boolean LIBRARY_WorldBounds=true
//endglobals from WorldBounds
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
//globals from SpellEffectEvent:
constant boolean LIBRARY_SpellEffectEvent=true
//endglobals from SpellEffectEvent
    // Generated
trigger gg_trg_OrderIds= null
trigger gg_trg_World_Bounds= null
trigger gg_trg_Missile= null
trigger gg_trg_SpellEffectEvent= null
trigger gg_trg_RegisterPlayerUnitEvent= null
trigger gg_trg_HOW_TO_IMPORT= null
trigger gg_trg_Frozen_Orb= null
trigger gg_trg_Show= null
constant integer FrozenOrb___FROZEN_ORB_ABILITY= 'A001'
constant attacktype FrozenOrb___ATTACK_TYPE= ATTACK_TYPE_NORMAL
constant damagetype FrozenOrb___DAMAGE_TYPE= DAMAGE_TYPE_MAGIC
constant real FrozenOrb___MISSILE_FLY_HEIGHT= 50.00
constant string FrozenOrb___ON_BURST_SFX= "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl"
constant integer Show___MAX= 10
unit Show___u
constant integer Show___W= 200


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
constant integer si__Missile___RecycleBin=2
constant timer s__Missile___RecycleBin_t= CreateTimer()
integer s__Missile___RecycleBin_max= 0
unit array s__Missile___RecycleBin_dummy
real array s__Missile___RecycleBin_time
constant integer si__MissilePosition=3
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
constant integer si__Missile=4
integer s__Missile_Missile___MissileStructure__collectionCount= 0
integer s__Missile_Missile___MissileStructure__nodeCount= 0
integer array s__Missile_Missile___MissileStructure___list
integer array s__Missile_Missile___MissileStructure___next
integer array s__Missile_Missile___MissileStructure___prev
integer array s__Missile_Missile___MissileStructure___first
integer array s__Missile_Missile___MissileStructure___last
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
constant integer si__SpellEffectEvent___S=5
hashtable s__SpellEffectEvent___S_ht= InitHashtable()
constant integer si__FrozenOrb___Buff=6
constant integer s__FrozenOrb___Buff_CASTER_UNIT_ID= 'n000'
constant integer s__FrozenOrb___Buff_BUFF_ORDER_ID= 852226
constant integer s__FrozenOrb___Buff_BUFF_ABILITY= 'A002'
unit s__FrozenOrb___Buff_caster= null
constant integer si__FrozenOrb___IceBolt=7
constant real s__FrozenOrb___IceBolt_OFFSET= 32.
real array s__FrozenOrb___IceBolt_chance
constant integer si__FrozenOrb___FrozenOrb=8
constant real s__FrozenOrb___FrozenOrb_SPACING_ON_PERIOD= bj_PI * 3 / 5
constant real s__FrozenOrb___FrozenOrb_SPACING_ON_REMOVE= bj_PI / 4
integer array s__FrozenOrb___FrozenOrb_level
constant integer si__Show___X=9
real array s__Show___X_x
real array s__Show___X_y
integer array s__Show___X_i
integer array s__Show___X_t
player array s__Show___X_p

endglobals
native UnitAlive takes unit id returns boolean


//library RegisterPlayerUnitEvent:
    
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

//library RegisterPlayerUnitEvent ends
//library WorldBounds:
   
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

//library WorldBounds ends
//library Missile:

    
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
//#     static if Missile_WRITE_DELAYED_MISSILE_RECYCLING then
    
         
                function s__Missile___RecycleBin_onPeriodic takes nothing returns nothing
                    local integer dex= 0
                    loop
                        exitwhen dex == s__Missile___RecycleBin_max
                        set s__Missile___RecycleBin_time[dex]=s__Missile___RecycleBin_time[dex] - 1
                        if 0 >= s__Missile___RecycleBin_time[dex] then
                        
//#                         static if LIBRARY_MissileRecycler then
//#                             call RecycleMissile(Missile___RecycleBin.dummy[dex])
//#                     
//#                         elseif Dummy.create.exists and LIBRARY_Dummy then
//#                             call Dummy[Missile___RecycleBin.dummy[dex]].destroy()
//#                         
//#                         elseif LIBRARY_xedummy and xedummy.release.exists then
//#                             call xedummy.release(Missile___RecycleBin.dummy[dex])
//#                     
//#                         else
                                call RemoveUnit(s__Missile___RecycleBin_dummy[dex])
//#                         endif
                        
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
                    set s__Missile___RecycleBin_max=s__Missile___RecycleBin_max + 1
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
//Implemented from module Missile___MissileStructure:
        
//#         static if LIBRARY_ErrorMessage then
//#              private boolean Missile___MissileStructure__isNode
//#              private boolean Missile___MissileStructure__isCollection
//#         endif
        
        function s__Missile__get_list takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,    "MissileStructure", "list", "Missile", this, "Attempted To Read Null Node.")
//#                  call ThrowError(not Missile___MissileStructure__isNode,   "MissileStructure", "list", "Missile", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile___MissileStructure___list[this]
        endfunction
        
        function s__Missile__get_next takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,    "MissileStructure", "next", "Missile", this, "Attempted To Go Out Of Bounds.")
//#                  call ThrowError(not Missile___MissileStructure__isNode,   "MissileStructure", "next", "Missile", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile___MissileStructure___next[this]
        endfunction
        
        function s__Missile__get_prev takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,    "MissileStructure", "prev", "Missile", this, "Attempted To Go Out Of Bounds.")
//#                  call ThrowError(not Missile___MissileStructure__isNode,   "MissileStructure", "prev", "Missile", this, "Attempted To Read Invalid Node.")
//#             endif
            return s__Missile_Missile___MissileStructure___prev[this]
        endfunction
        
        function s__Missile__get_first takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,        "MissileStructure", "first", "Missile", this, "Attempted To Read Null List.")
//#                  call ThrowError(not Missile___MissileStructure__isCollection, "MissileStructure", "first", "Missile", this, "Attempted To Read Invalid List.")
//#             endif
            return s__Missile_Missile___MissileStructure___first[this]
        endfunction
        
        function s__Missile__get_last takes integer this returns integer
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,        "MissileStructure", "last", "Missile", this, "Attempted To Read Null List.")
//#                  call ThrowError(not Missile___MissileStructure__isCollection, "MissileStructure", "last", "Missile", this, "Attempted To Read Invalid List.")
//#             endif
            return s__Missile_Missile___MissileStructure___last[this]
        endfunction
        
        function s__Missile_allocateCollection takes nothing returns integer
            local integer this= s__Missile_Missile___MissileStructure___first[(0)]
            
            if ( 0 == this ) then
//#                 static if LIBRARY_ErrorMessage then
//#                      call ThrowError(Missile___MissileStructure__collectionCount == 8191, "MissileStructure", "allocateCollection", "Missile", 0, "Overflow.")
//#                 endif
                
                set this=s__Missile_Missile___MissileStructure__collectionCount + 1
                set s__Missile_Missile___MissileStructure__collectionCount=this
            else
                set s__Missile_Missile___MissileStructure___first[(0)]=s__Missile_Missile___MissileStructure___first[this]
            endif
            
//#             static if LIBRARY_ErrorMessage then
//#                  set Missile___MissileStructure__isCollection = true
//#             endif
            
            set s__Missile_Missile___MissileStructure___first[this]=0
            
            return this
        endfunction
        
        function s__Missile_allocateNode takes nothing returns integer
            local integer this= s__Missile_Missile___MissileStructure___next[(0)]
            
            if ( 0 == this ) then
//#                 static if LIBRARY_ErrorMessage then
//#                      call ThrowError(Missile___MissileStructure__nodeCount == 8191, "MissileStructure", "allocateNode", "Missile", 0, "Overflow.")
//#                 endif
                
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
            
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(this == 0,        "List", "push", "Missile", this, "Attempted To Push On To Null List.")
//#                  call ThrowError(not Missile___MissileStructure__isCollection, "List", "push", "Missile", this, "Attempted To Push On To Invalid List.")
//#                  set node.Missile___MissileStructure__isNode = true
//#             endif
            
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
            
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(node == 0,        "MissileStructure", "remove", "Missile", this, "Attempted To Remove Null Node.")
//#                  call ThrowError(not node.Missile___MissileStructure__isNode,  "MissileStructure", "remove", "Missile", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
//#                  set node.Missile___MissileStructure__isNode = false
//#             endif
            
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
                call s__Missile_Missile___remove(this)
                call s__MissilePosition_destroy(s__Missile_impact[this])
                call s__MissilePosition_destroy(s__Missile_origin[this])
            
                call DestroyEffect(s__Missile_sfx[this])
                call FlushChildHashtable(Missile___HASH, this)
                if GetUnitTypeId(s__Missile_dummy[this]) == Missile_DUMMY_UNIT_ID then
                    // MissileRecycler > Dummy > xe.
//#                     static if LIBRARY_MissileRecycler then
//#                         call RecycleMissile(dummy)
//#                     elseif LIBRARY_Dummy and Dummy.create.exists then
//#                         call Dummy[dummy].destroy()
//#                     elseif LIBRARY_xedummy and xedummy.release.exists then
//#                         call xedummy.release(dummy)
//#                     else
                            call RemoveUnit(s__Missile_dummy[this])
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
            call SaveUnitHandle(Missile___HASH, this, GetHandleId(missileDummy), missileDummy)
            //
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowWarning(GetUnitTypeId(missileDummy) == 0, "Missile", "createEx", "missileDummy", this, "Invalid missile dummy unit ( null )!")
//#             endif
             set s__Missile_launched[this]=false
            return this
        endfunction
    
        // Freaky static if ensures these libraries really don't exist.
//#         static if not LIBRARY_MissileRecycler and not LIBRARY_Dummy and not Dummy.create.exists and not LIBRARY_xe_dummy and not xe_dummy.new.exists then
                function s__Missile_newMissileUnit takes real x,real y,real z,real face returns unit
                    local boolean prev= Missile___ToogleUnitIndexer(false)
                    set bj_lastCreatedUnit=CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, x, y, face)
                    call Missile___ToogleUnitIndexer(prev)
                    call SetUnitX(bj_lastCreatedUnit, x)
                    call SetUnitY(bj_lastCreatedUnit, y)
                    call UnitAddAbility(bj_lastCreatedUnit, 'Amrf')
                    call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0.)
                    call PauseUnit(bj_lastCreatedUnit, true)
                    return bj_lastCreatedUnit
                endfunction
//#         endif
    
        // MissileRecylcer > Dummy > xe > Missile.
    
        // Wrapper to createEx.
        function s__Missile_create takes real x,real y,real z,real angle,real distance,real impactZ returns integer
            local real impactX= x + distance * Cos(angle)
            local real impactY= y + distance * Sin(angle)
            // Get the dummy unit.
//textmacro instance: MISSILE_GET_DUMMY_FROM_LIBRARY()
//#             static if LIBRARY_MissileRecycler then
//#                 return createEx(GetRecycledMissile(x, y, z, angle*bj_RADTODEG), impactX, impactY, impactZ)
//#         
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
                    return s__Missile_createEx(s__Missile_newMissileUnit(x , y , z , angle * bj_RADTODEG) , impactX , impactY , impactZ)
//#             endif
//end of: MISSILE_GET_DUMMY_FROM_LIBRARY()
        endfunction
        
        // Wrapper to createEx.
        function s__Missile_createXYZ takes real x,real y,real z,real impactX,real impactY,real impactZ returns integer
            local real angle= Atan2(impactY - y, impactX - x)
            // Get the dummy unit.
//textmacro instance: MISSILE_GET_DUMMY_FROM_LIBRARY()
//#             static if LIBRARY_MissileRecycler then
//#                 return createEx(GetRecycledMissile(x, y, z, angle*bj_RADTODEG), impactX, impactY, impactZ)
//#         
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
                    return s__Missile_createEx(s__Missile_newMissileUnit(x , y , z , angle * bj_RADTODEG) , impactX , impactY , impactZ)
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
                    set b=s__Missile_isWidgetInRange(s__Missile_temp,d , GetDestructableHeight(d) , s__Missile_collision[s__Missile_temp])
                else
                    set b=s__Missile_isWidgetInRectangle(s__Missile_temp,d , GetDestructableHeight(d) , s__Missile_collision[s__Missile_temp])
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

//# static if Missile_WRITE_DELAYED_MISSILE_RECYCLING then
        function s__Missile_nullBefore takes integer this returns nothing
            set s__Missile_dummy[this]=null
        endfunction
//# endif

// Does not check for 'Aloc' and 'Amrf' as they could be customized.
        function s__Missile_onInit takes nothing returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  local boolean prev = Missile___ToogleUnitIndexer(false)
//#                  local unit dummy = CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, 0., 0., 0.)
//#                  call Missile___ToogleUnitIndexer(prev)
//#                 //
//#                  call ThrowError((GetUnitTypeId(dummy) != Missile_DUMMY_UNIT_ID), "Missile", "DEBUG_MISSILE", "type id",    0, "Global setup for public integer DUMMY_UNIT_ID is incorrect! This map currently can't use Missile!")
//#                  call ThrowError((Missile_MAXIMUM_COLLISION_SIZE < 0),            "Missile", "DEBUG_MISSILE", "collision",  0, "Global setup for public real MAXIMUM_COLLISION_SIZE is incorrect, below zero! This map currently can't use Missile!")
//#                  call RemoveUnit(dummy)
//#                  set dummy = null
//#             endif
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
//#             static if true and LIBRARY_ErrorMesssage then
//#                 if not TriggerEvaluate(Missile___CORE) then
//#                     call ThrowWarning(true, "Missile", "Fire", "op limit", 0, "You just ran into a op limit!\nThe op limit protection of Missile is insufficient for your map.\nThe code of the missile module can't run in one thread and must be splitted.\nIf unsure make a post in the official 'The Hive Workshop' forum thread of Missile!")
//#                 endif
//#             else
                    call TriggerEvaluate(Missile___CORE)
//#             endif
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

//library Missile ends
//library SpellEffectEvent:
 
//============================================================================
 
//============================================================================
//Implemented from module SpellEffectEvent___M:
    
//#     static if LIBRARY_Table then
//#         static Table tb
//#     else
//#     endif
    
    function s__SpellEffectEvent___S_onCast takes nothing returns nothing
//#         static if LIBRARY_Table then
//#             call TriggerEvaluate(.tb.trigger[GetSpellAbilityId()])
//#         else
                call TriggerEvaluate(LoadTriggerHandle(s__SpellEffectEvent___S_ht, 0, GetSpellAbilityId()))
//#         endif
    endfunction
 
    function s__SpellEffectEvent___S_SpellEffectEvent___M__onInit takes nothing returns nothing
//#         static if LIBRARY_Table then
//#             set .tb = Table.create()
//#         endif
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT , function s__SpellEffectEvent___S_onCast)
    endfunction
 
//============================================================================
function RegisterSpellEffectEvent takes integer abil,code onCast returns nothing
//#     static if LIBRARY_Table then
//#         if not SpellEffectEvent___S.tb.handle.has(abil) then
//#             set SpellEffectEvent___S.tb.trigger[abil] = CreateTrigger()
//#         endif
//#         call TriggerAddCondition(SpellEffectEvent___S.tb.trigger[abil], Filter(onCast))
//#     else
            if not HaveSavedHandle(s__SpellEffectEvent___S_ht, 0, abil) then
                call SaveTriggerHandle(s__SpellEffectEvent___S_ht, 0, abil, CreateTrigger())
            endif
            call TriggerAddCondition(LoadTriggerHandle(s__SpellEffectEvent___S_ht, 0, abil), Filter(onCast))
//#     endif
endfunction
 

//library SpellEffectEvent ends
//===========================================================================
// 
// Frozen Orb
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Date: Fri Mar 25 13:05:08 2016
//   Map Author: Unknown
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
//*  Triggers
//*
//***************************************************************************

//===========================================================================
// Trigger: World Bounds
//===========================================================================
//TESH.scrollpos=2
//TESH.alwaysfold=0
// Trigger: Missile
//===========================================================================
//TESH.scrollpos=79
//TESH.alwaysfold=0
// Trigger: SpellEffectEvent
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0
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
// Trigger: RegisterPlayerUnitEvent
//===========================================================================
//TESH.scrollpos=0
//TESH.alwaysfold=0

// Trigger: Frozen Orb
//===========================================================================
//TESH.scrollpos=7
//TESH.alwaysfold=0


// scope FrozenOrb begins
//=========================================================================
// Name: Frozen Orb; ©Blizzard Entertainment, Diablo II
// Version: 2.1
// Author: BPower
// Requirements: Missile, SpellEffectEvent
// Credits: Bribe for SpellEffectEvent 
//=========================================================================
// Description:
// A pulsating orb that shreds an area with Ice Bolts. 
// Each Bolt deals damage and has chance to burst dying enemies,
// leaving no corpse behind. 
//=========================================================================

// User settings:
// ==============

        
    // Set the maximum fly distance for the main orb.
    constant function FrozenOrb___GetOrbMaxDistance takes integer level returns real
        return 800. + level * 0.
    endfunction
    
    // Set the maximum fly distance for the ice bolts.
    constant function FrozenOrb___GetIceBoltMaxDistance takes integer level returns real
        return 400. + level * 0.
    endfunction

    // Set the amount of ice bolts created when the main orb explodes.
    constant function FrozenOrb___GetIceBoltCountOnExplode takes integer level returns integer
        return 12
    endfunction
    
    // You have full access granted to all members and methods from library Missile.
    // However missile.data, missile.source and missile.owner are reserved.
    function FrozenOrb___CustomizeFrozenOrb takes integer orb,integer level returns nothing
        set s__Missile_speed[orb]=13.
        call s__Missile__set_model(orb,"Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl")
        call s__Missile__set_scale(orb,.75)
    endfunction
    
    // Same as CustomizeFrozenOrb, but for ice bolts.
    function FrozenOrb___CustomizeIceBolt takes integer bolt,integer level returns nothing
        set s__Missile_speed[bolt]=20.
        call s__Missile__set_model(bolt,"Abilities\\Weapons\\LichMissile\\LichMissile.mdl")
        call s__Missile__set_scale(bolt,.65)
        set s__Missile_damage[bolt]=10. + 20. * level
        set s__Missile_collision[bolt]=48.
    endfunction
        
    // Filter which units are hit by ice bolts.
    function FrozenOrb___TargetFilter takes unit target,player owner returns boolean
        return not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(target, UNIT_TYPE_STRUCTURE) and UnitAlive(target) and IsUnitEnemy(target, owner)
    endfunction
    
    // Set the chance to burst an enemy to ice. Real comparison in range of 0 - 100.
    // Return smaller or equal to 0 if you don't need this feature.
    constant function FrozenOrb___GetBurstChance takes integer level returns real
        return 5. + 5. * level
    endfunction
        
    // Filter out all units which shouldn't be removed from the game on burst. Heroes, .. etc
    // Those units who pass the filter get removed from the game and are inevitably gone.
    function FrozenOrb___ExplodeFilter takes unit target returns boolean
        return not IsUnitType(target, UNIT_TYPE_MECHANICAL) and not IsUnitType(target, UNIT_TYPE_HERO)
    endfunction

    // The following struct "Buff" creates the buff- and frostnova effect of Frozen Orb.
    // Adjust the constants to your needs.
        
        // Buff type settings. 
        
        
        function s__FrozenOrb___Buff_castTarget takes player owner,unit target returns nothing
            call SetUnitOwner(s__FrozenOrb___Buff_caster, owner, false)
            call IssueTargetOrderById(s__FrozenOrb___Buff_caster, s__FrozenOrb___Buff_BUFF_ORDER_ID, target)
            call SetUnitOwner(s__FrozenOrb___Buff_caster, Missile_NEUTRAL_PASSIVE, false)
        endfunction
    
        function s__FrozenOrb___Buff_onInit takes nothing returns nothing
            set s__FrozenOrb___Buff_caster=CreateUnit(Missile_NEUTRAL_PASSIVE, s__FrozenOrb___Buff_CASTER_UNIT_ID, 0., 0., 0.)
            call SetUnitPosition(s__FrozenOrb___Buff_caster, 2147483647, 2147483647)
            call UnitAddAbility(s__FrozenOrb___Buff_caster, s__FrozenOrb___Buff_BUFF_ABILITY)
            call ShowUnit(s__FrozenOrb___Buff_caster, false)
        endfunction
    
//=====================================================================
// Frozen orb source code. Make changes carefully.
//=====================================================================
// You can extend struct IceBolt and / or struct FrozenOrb with 
// available Missile API, such as onDestructable, onTerrain ...
    
                                         // directly from the center of the orb.
        
        function s__FrozenOrb___IceBolt_onRemove takes integer missile returns boolean
            return true
        endfunction
                              // Runs when a missile collides with a unit.
        function s__FrozenOrb___IceBolt_onCollide takes integer missile,unit hit returns boolean
            local integer this= (missile)
            
            if FrozenOrb___TargetFilter(hit , s__Missile_owner[missile]) then
                call s__FrozenOrb___Buff_castTarget(s__Missile_owner[missile] , hit)
                call UnitDamageTarget(s__Missile_source[missile], hit, s__Missile_damage[missile], false, false, FrozenOrb___ATTACK_TYPE, FrozenOrb___DAMAGE_TYPE, null)
                
                if GetUnitTypeId(hit) != 0 and GetRandomReal(0., 100.) < s__FrozenOrb___IceBolt_chance[this] and FrozenOrb___ExplodeFilter(hit) then
                    call DestroyEffect(AddSpecialEffect(FrozenOrb___ON_BURST_SFX, s__Missile_x[missile], s__Missile_y[missile]))
                    call RemoveUnit(hit)
                endif
                return true // returning true will destroy the missile instance.
            endif
            return false // returning false will keep the missile flying.
        endfunction
        
//Implemented from module MissileStruct:
        function s__FrozenOrb___IceBolt_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "FrozenOrb___IceBolt", "launch", "missile.launched", missile, "This missile was already launched before!")
//#             endif
             set s__Missile_launched[missile]=true
            //
            call s__Missile_insertFront(Missile___missileList[si__FrozenOrb___IceBolt],missile)
            call Missile___StartPeriodic(si__FrozenOrb___IceBolt)
        endfunction
        // Called from missileIterate. "P" to avoid code collision.
        function s__FrozenOrb___IceBolt_missileTerminateP takes integer node returns nothing
            if s__Missile_allocated[node] then
//#                 static if FrozenOrb___IceBolt.onRemove.exists then
//#                     static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile___RecycleBin.recycle.exists then
                            if s__FrozenOrb___IceBolt_onRemove(node) and GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID then
                                call s__Missile___RecycleBin_recycle(s__Missile_dummy[node])
                                call s__Missile_nullBefore(node)
                            endif
//#                     else
//#                         call FrozenOrb___IceBolt.onRemove(node)
//#                     endif
//#                 endif
            
                call s__Missile_terminate(node)
                call Missile___StopPeriodic(si__FrozenOrb___IceBolt)
            endif
        endfunction

//# static if true then
        // Runs check during compile time.
//#     static if FrozenOrb___IceBolt.onMissile.exists then
//#         Error Message from library Missile in struct FrozenOrb___IceBolt !
//#         FrozenOrb___IceBolt.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#         FrozenOrb___IceBolt.onMissile is currently not supported by library Missile. 
//#         Please delete or re-name that method.
//#     endif
//# endif

//#     static if FrozenOrb___IceBolt.onItem.exists then
//#         private static method MissileAction__missileActionItem takes nothing returns nothing
//#             local item i = GetEnumItem()
//#             local Missile this = Missile.temp
//#             if this.allocated then
//#                 call SaveItemHandle(Missile___HASH, this, GetHandleId(i), i) 
//#                 if FrozenOrb___IceBolt.onItem(this, i) then
//#                     call missileTerminateP(this)
//#                 endif
//#             endif
//#             set i = null
//#         endmethod
//#     endif
        
//#     static if FrozenOrb___IceBolt.onDestructable.exists then
//#         private static method MissileAction__missileActionDest takes nothing returns nothing
//#             local destructable d = GetEnumDestructable()
//#             local Missile this = Missile.temp
//#             if this.allocated then
//#                 call SaveDestructableHandle(Missile___HASH, this, GetHandleId(d), d) 
//#                 if FrozenOrb___IceBolt.onDestructable(this, d) then
//#                     call missileTerminateP(this)
//#                 endif
//#             endif
//#             set d = null
//#         endmethod
//#     endif
    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__FrozenOrb___IceBolt_missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile___missileList[si__FrozenOrb___IceBolt])
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            loop
                exitwhen 0 == this
                set node=s__Missile__get_next(this) // The linked list should not lose the next node.
               
                if s__Missile_wantDestroy[this] then
                    call s__FrozenOrb___IceBolt_missileTerminateP(this)
                else
                    if s__Missile_stackSize[this] > 0 then
                        call s__Missile_updateStack(this)
                    endif
                    
                    // Runs unit collision.
//#                     static if FrozenOrb___IceBolt.onCollide.exists then
                            if s__Missile_allocated[this] and 0. < s__Missile_collision[this] then
                                set b=s__Missile_collisionType[this] == Missile_COLLISION_TYPE_RECTANGLE
                                if b then
                                    call s__Missile_groupEnumUnitsRectangle(this)
                                else
                                    call GroupEnumUnitsInRange(Missile___GROUP, s__Missile_x[this], s__Missile_y[this], s__Missile_collision[this] + Missile_MAXIMUM_COLLISION_SIZE, null)
                                endif
                                loop
                                    set u=FirstOfGroup(Missile___GROUP)
                                    exitwhen u == null
                                    call GroupRemoveUnit(Missile___GROUP, u)
                                    if not HaveSavedHandle(Missile___HASH, this, GetHandleId(u)) then
                                        if IsUnitInRange(u, s__Missile_dummy[this], s__Missile_collision[this]) or b then
                                            // Eventually run z collision checks.
//#                                         static if Missile_USE_COLLISION_Z_FILTER then
                                                set collideZ=Missile_GetLocZ(GetUnitX(u) , GetUnitY(u)) + GetUnitFlyHeight(u) - s__Missile_terrainZ[this]
                                                if ( collideZ + GetUnitBodySize(u) >= s__Missile_z[this] - s__Missile__get_collisionZ(this) ) and ( collideZ <= s__Missile_z[this] + s__Missile__get_collisionZ(this) ) then
                                                    // Mark as hit.
                                                    call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
                                                    if s__FrozenOrb___IceBolt_onCollide(this , u) then
                                                        call s__FrozenOrb___IceBolt_missileTerminateP(this)
                                                        exitwhen true
                                                    endif
                                                endif
        
//#                                         else
//#                                             // Runs unit collision without z collision checks.
//#                                             call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
//#                                             if FrozenOrb___IceBolt.onCollide(this, u) then
//#                                                 call FrozenOrb___IceBolt.missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                         endif
                                        endif
                                    endif
                                endloop
                            endif
//#                     endif
                    
                    // Runs destructable collision.
//#                     static if FrozenOrb___IceBolt.onDestructable.exists then
//#                         // Check if the missile is not terminated.
//#                         if this.allocated and 0. < this.collision then
//#                             call this.checkDestCollision(function FrozenOrb___IceBolt.MissileAction__missileActionDest)
//#                         endif
//#                     endif
                    
                    // Runs item collision.
//#                     static if FrozenOrb___IceBolt.onItem.exists then
//#                         //  Check if the missile is not terminated.
//#                         if this.allocated and 0. < this.collision then
//#                             call this.checkItemCollision(function FrozenOrb___IceBolt.MissileAction__missileActionItem)
//#                         endif
//#                     endif
                
                    // Runs when the destination is reached.
                    if s__Missile_recycle[this] and s__Missile_allocated[this] then
//#                         static if FrozenOrb___IceBolt.onFinish.exists then
//#                             if FrozenOrb___IceBolt.onFinish(this) then
//#                                 call FrozenOrb___IceBolt.missileTerminateP(this)
//#                             endif
//#                         else
                                call s__FrozenOrb___IceBolt_missileTerminateP(this)
//#                         endif
                    endif
                
                    // Runs on terrian collision.
//#                     static if FrozenOrb___IceBolt.onTerrain.exists then
//#                         if this.allocated and 0. > this.z and FrozenOrb___IceBolt.onTerrain(this) then
//#                             call missileTerminateP(this)
//#                         endif
//#                     endif
                
                    // Runs every Missile_TIMER_TIMEOUT.
//#                     static if FrozenOrb___IceBolt.onPeriod.exists then
//#                         if this.allocated and FrozenOrb___IceBolt.onPeriod(this) then
//#                             call missileTerminateP(this)
//#                         endif
//#                     endif
                endif
                set this=node
            endloop
            
            set u=null
//#             static if true and LIBRARY_ErrorMessage then
//#                 return true
//#             else
                    return false
//#             endif
        endfunction
        
        function s__FrozenOrb___IceBolt_MissileStruct__onInit takes nothing returns nothing
            call Missile___MissileCreateCollection(si__FrozenOrb___IceBolt)
            call Missile___MissileCreateExpression(si__FrozenOrb___IceBolt , function s__FrozenOrb___IceBolt_missileIterateP)
        endfunction
    
    function FrozenOrb___CreateIceBolt takes integer orb,real angle,integer level returns nothing
        local real x= s__Missile_x[orb] + s__FrozenOrb___IceBolt_OFFSET * Cos(angle)
        local real y= s__Missile_y[orb] + s__FrozenOrb___IceBolt_OFFSET * Sin(angle)
        local integer missile= s__Missile_create(x , y , FrozenOrb___MISSILE_FLY_HEIGHT , angle , FrozenOrb___GetIceBoltMaxDistance(level) , FrozenOrb___MISSILE_FLY_HEIGHT)
    
        set s__FrozenOrb___IceBolt_chance[(missile)]=FrozenOrb___GetBurstChance(level)
        call FrozenOrb___CustomizeIceBolt(missile , level)
        set s__Missile_source[missile]=s__Missile_source[orb]
        set s__Missile_owner[missile]=s__Missile_owner[orb]
        call s__FrozenOrb___IceBolt_launch(missile)
    endfunction
    
        
                      // When the main orb gets deallocated.
        function s__FrozenOrb___FrozenOrb_onRemove takes integer missile returns boolean
            local integer this= (missile)
            local integer index= 0
            local integer count= FrozenOrb___GetIceBoltCountOnExplode(s__FrozenOrb___FrozenOrb_level[this])
            local real space= 2 * bj_PI / count
            
            loop
                exitwhen index >= count
                call FrozenOrb___CreateIceBolt(missile , index * space + s__FrozenOrb___FrozenOrb_SPACING_ON_REMOVE , s__FrozenOrb___FrozenOrb_level[this])
                set index=index + 1
            endloop
            
            return true
        endfunction
                      // Every Missile_TIMER_TIMEOUT interval.
        function s__FrozenOrb___FrozenOrb_onPeriod takes integer missile returns boolean
            local integer this= (missile)
            
            call FrozenOrb___CreateIceBolt(missile , s__FrozenOrb___FrozenOrb_SPACING_ON_PERIOD * s__Missile_data[missile] , s__FrozenOrb___FrozenOrb_level[this])
            set s__Missile_data[missile]=s__Missile_data[missile] + 1
            return false
        endfunction
    
//Implemented from module MissileStruct:
        function s__FrozenOrb___FrozenOrb_launch takes integer missile returns nothing
//#             static if LIBRARY_ErrorMessage then
//#                  call ThrowError(missile.launched, "FrozenOrb___FrozenOrb", "launch", "missile.launched", missile, "This missile was already launched before!")
//#             endif
             set s__Missile_launched[missile]=true
            //
            call s__Missile_insertFront(Missile___missileList[si__FrozenOrb___FrozenOrb],missile)
            call Missile___StartPeriodic(si__FrozenOrb___FrozenOrb)
        endfunction
        // Called from missileIterate. "P" to avoid code collision.
        function s__FrozenOrb___FrozenOrb_missileTerminateP takes integer node returns nothing
            if s__Missile_allocated[node] then
//#                 static if FrozenOrb___FrozenOrb.onRemove.exists then
//#                     static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and Missile___RecycleBin.recycle.exists then
                            if s__FrozenOrb___FrozenOrb_onRemove(node) and GetUnitTypeId(s__Missile_dummy[node]) == Missile_DUMMY_UNIT_ID then
                                call s__Missile___RecycleBin_recycle(s__Missile_dummy[node])
                                call s__Missile_nullBefore(node)
                            endif
//#                     else
//#                         call FrozenOrb___FrozenOrb.onRemove(node)
//#                     endif
//#                 endif
            
                call s__Missile_terminate(node)
                call Missile___StopPeriodic(si__FrozenOrb___FrozenOrb)
            endif
        endfunction

//# static if true then
        // Runs check during compile time.
//#     static if FrozenOrb___FrozenOrb.onMissile.exists then
//#         Error Message from library Missile in struct FrozenOrb___FrozenOrb !
//#         FrozenOrb___FrozenOrb.onMissile is a reserved name for Missile, once you implemented MissileStruct.
//#         FrozenOrb___FrozenOrb.onMissile is currently not supported by library Missile. 
//#         Please delete or re-name that method.
//#     endif
//# endif

//#     static if FrozenOrb___FrozenOrb.onItem.exists then
//#         private static method MissileAction__missileActionItem takes nothing returns nothing
//#             local item i = GetEnumItem()
//#             local Missile this = Missile.temp
//#             if this.allocated then
//#                 call SaveItemHandle(Missile___HASH, this, GetHandleId(i), i) 
//#                 if FrozenOrb___FrozenOrb.onItem(this, i) then
//#                     call missileTerminateP(this)
//#                 endif
//#             endif
//#             set i = null
//#         endmethod
//#     endif
        
//#     static if FrozenOrb___FrozenOrb.onDestructable.exists then
//#         private static method MissileAction__missileActionDest takes nothing returns nothing
//#             local destructable d = GetEnumDestructable()
//#             local Missile this = Missile.temp
//#             if this.allocated then
//#                 call SaveDestructableHandle(Missile___HASH, this, GetHandleId(d), d) 
//#                 if FrozenOrb___FrozenOrb.onDestructable(this, d) then
//#                     call missileTerminateP(this)
//#                 endif
//#             endif
//#             set d = null
//#         endmethod
//#     endif
    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        function s__FrozenOrb___FrozenOrb_missileIterateP takes nothing returns boolean
            local integer this= s__Missile__get_first(Missile___missileList[si__FrozenOrb___FrozenOrb])
            local integer node
            local real collideZ
            local boolean b
            local unit u
            
            loop
                exitwhen 0 == this
                set node=s__Missile__get_next(this) // The linked list should not lose the next node.
               
                if s__Missile_wantDestroy[this] then
                    call s__FrozenOrb___FrozenOrb_missileTerminateP(this)
                else
                    if s__Missile_stackSize[this] > 0 then
                        call s__Missile_updateStack(this)
                    endif
                    
                    // Runs unit collision.
//#                     static if FrozenOrb___FrozenOrb.onCollide.exists then
//#                         if this.allocated and 0. < this.collision then
//#                             set b = this.collisionType == Missile_COLLISION_TYPE_RECTANGLE  
//#                             if b then
//#                                 call this.groupEnumUnitsRectangle()
//#                             else
//#                                 call GroupEnumUnitsInRange(Missile___GROUP, this.x, this.y, this.collision + Missile_MAXIMUM_COLLISION_SIZE, null)
//#                             endif
//#                             loop
//#                                 set u = FirstOfGroup(Missile___GROUP)
//#                                 exitwhen u == null
//#                                 call GroupRemoveUnit(Missile___GROUP, u)
//#                                 if not HaveSavedHandle(Missile___HASH, this, GetHandleId(u)) then
//#                                     if IsUnitInRange(u, this.dummy, this.collision) or b then  
//#                                         // Eventually run z collision checks.
//#                                         static if Missile_USE_COLLISION_Z_FILTER then
//#                                             set collideZ = Missile_GetLocZ(GetUnitX(u), GetUnitY(u)) + GetUnitFlyHeight(u) - this.terrainZ
//#                                             if (collideZ + GetUnitBodySize(u) >= this.z - this.collisionZ) and (collideZ <= this.z + this.collisionZ) then
//#                                                 // Mark as hit.
//#                                                 call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
//#                                                 if FrozenOrb___FrozenOrb.onCollide(this, u) then
//#                                                     call FrozenOrb___FrozenOrb.missileTerminateP(this)
//#                                                     exitwhen true
//#                                                 endif
//#                                             endif
//#     
//#                                         else
//#                                             // Runs unit collision without z collision checks.
//#                                             call SaveUnitHandle(Missile___HASH, this, GetHandleId(u), u)
//#                                             if FrozenOrb___FrozenOrb.onCollide(this, u) then
//#                                                 call FrozenOrb___FrozenOrb.missileTerminateP(this)
//#                                                 exitwhen true
//#                                             endif
//#                                         endif
//#                                     endif                                    
//#                                 endif
//#                             endloop
//#                         endif
//#                     endif
                    
                    // Runs destructable collision.
//#                     static if FrozenOrb___FrozenOrb.onDestructable.exists then
//#                         // Check if the missile is not terminated.
//#                         if this.allocated and 0. < this.collision then
//#                             call this.checkDestCollision(function FrozenOrb___FrozenOrb.MissileAction__missileActionDest)
//#                         endif
//#                     endif
                    
                    // Runs item collision.
//#                     static if FrozenOrb___FrozenOrb.onItem.exists then
//#                         //  Check if the missile is not terminated.
//#                         if this.allocated and 0. < this.collision then
//#                             call this.checkItemCollision(function FrozenOrb___FrozenOrb.MissileAction__missileActionItem)
//#                         endif
//#                     endif
                
                    // Runs when the destination is reached.
                    if s__Missile_recycle[this] and s__Missile_allocated[this] then
//#                         static if FrozenOrb___FrozenOrb.onFinish.exists then
//#                             if FrozenOrb___FrozenOrb.onFinish(this) then
//#                                 call FrozenOrb___FrozenOrb.missileTerminateP(this)
//#                             endif
//#                         else
                                call s__FrozenOrb___FrozenOrb_missileTerminateP(this)
//#                         endif
                    endif
                
                    // Runs on terrian collision.
//#                     static if FrozenOrb___FrozenOrb.onTerrain.exists then
//#                         if this.allocated and 0. > this.z and FrozenOrb___FrozenOrb.onTerrain(this) then
//#                             call missileTerminateP(this)
//#                         endif
//#                     endif
                
                    // Runs every Missile_TIMER_TIMEOUT.
//#                     static if FrozenOrb___FrozenOrb.onPeriod.exists then
                            if s__Missile_allocated[this] and s__FrozenOrb___FrozenOrb_onPeriod(this) then
                                call s__FrozenOrb___FrozenOrb_missileTerminateP(this)
                            endif
//#                     endif
                endif
                set this=node
            endloop
            
            set u=null
//#             static if true and LIBRARY_ErrorMessage then
//#                 return true
//#             else
                    return false
//#             endif
        endfunction
        
        function s__FrozenOrb___FrozenOrb_MissileStruct__onInit takes nothing returns nothing
            call Missile___MissileCreateCollection(si__FrozenOrb___FrozenOrb)
            call Missile___MissileCreateExpression(si__FrozenOrb___FrozenOrb , function s__FrozenOrb___FrozenOrb_missileIterateP)
        endfunction
                     // EVENT_PLAYER_UNIT_SPELL_EFFECT.
    function FrozenOrb___OnEffect takes nothing returns nothing
        local unit source= GetTriggerUnit()
        local real x= GetUnitX(source)
        local real y= GetUnitY(source)
        local real angle= Atan2(GetSpellTargetY() - y, GetSpellTargetX() - x)
        local integer level= GetUnitAbilityLevel(source, FrozenOrb___FROZEN_ORB_ABILITY)
        local integer missile= s__Missile_create(x , y , FrozenOrb___MISSILE_FLY_HEIGHT , angle , FrozenOrb___GetOrbMaxDistance(level) , FrozenOrb___MISSILE_FLY_HEIGHT)
        
        set s__FrozenOrb___FrozenOrb_level[(missile)]=level
        call FrozenOrb___CustomizeFrozenOrb(missile , level)
        set s__Missile_source[missile]=source
        set s__Missile_owner[missile]=GetTriggerPlayer()
        call s__FrozenOrb___FrozenOrb_launch(missile)
        
        set source=null
    endfunction
    
    function FrozenOrb___Init takes nothing returns nothing
        call RegisterSpellEffectEvent(FrozenOrb___FROZEN_ORB_ABILITY , function FrozenOrb___OnEffect)
    endfunction
    
// scope FrozenOrb ends
// Trigger: Show
//===========================================================================
//TESH.scrollpos=4
//TESH.alwaysfold=0
// scope Show begins

    
    
    
        
        
        function s__Show___X_init takes nothing returns nothing
            local integer i= 0
            set Show___u=CreateUnit(Player(0), 'Ulic', 0, 0, 0)
            call SetHeroLevel(Show___u, 10, false)
            call CreateFogModifierRectBJ(true, Player(0), FOG_OF_WAR_VISIBLE, s__WorldBounds_world)
            loop
                exitwhen i == Show___MAX
                call CreateUnit(Player(1), 'hfoo', 1000, 1000, 0)
                set i=i + 1
            endloop
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 20, "Press ESC to spawn footmans")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 20, "---------------------------")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 20, "-----------HINT------------")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 20, "Make use of Missile API to extend")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 20, "Frozen Orb projectile behaviour!!")
        endfunction
        
        function s__Show___X_revive takes nothing returns boolean
            local integer i= 0
            loop
                exitwhen i == Show___MAX
                call CreateUnit(Player(1), 'hfoo', 1000, 1000, 0)
                set i=i + 1
            endloop
            return false
        endfunction
            
//Implemented from module Show___I:
        function s__Show___X_Show___I__onInit takes nothing returns nothing
            local trigger t= CreateTrigger()
            call TriggerRegisterPlayerEvent(t, Player(0), EVENT_PLAYER_END_CINEMATIC)
            call TriggerAddCondition(t, Condition(function s__Show___X_revive))
            call s__Show___X_init()
            call PanCameraTo(0, 0)
        endfunction
        
// scope Show ends
function InitCustomTriggers takes nothing returns nothing
    //Function not found: call InitTrig_World_Bounds()
    //Function not found: call InitTrig_Missile()
    //Function not found: call InitTrig_SpellEffectEvent()
    //Function not found: call InitTrig_RegisterPlayerUnitEvent()
    //Function not found: call InitTrig_Frozen_Orb()
    //Function not found: call InitTrig_Show()
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
    call SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(0), true)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)

    // Player 1
    call SetPlayerStartLocation(Player(1), 1)
    call SetPlayerColor(Player(1), ConvertPlayerColor(1))
    call SetPlayerRacePreference(Player(1), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(1), true)
    call SetPlayerController(Player(1), MAP_CONTROL_COMPUTER)

endfunction

function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_002
    call SetPlayerTeam(Player(0), 0)

    // Force: TRIGSTR_022
    call SetPlayerTeam(Player(1), 1)

endfunction

//***************************************************************************
//*
//*  Main Initialization
//*
//***************************************************************************

//===========================================================================
function main takes nothing returns nothing
    call SetCameraBounds(- 3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("LordaeronSummerDay")
    call SetAmbientNightSound("LordaeronSummerNight")
    call SetMapMusic("Music", true, 0)
    call InitBlizzard()

call ExecuteFunc("jasshelper__initstructs22213718")
call FrozenOrb___Init()

    call InitGlobals()
    call InitCustomTriggers()

endfunction

//***************************************************************************
//*
//*  Map Configuration
//*
//***************************************************************************

function config takes nothing returns nothing
    call SetMapName("TRIGSTR_034")
    call SetMapDescription("TRIGSTR_036")
    call SetPlayers(2)
    call SetTeams(2)
    call SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)

    call DefineStartLocation(0, - 2688.0, - 3200.0)
    call DefineStartLocation(1, 576.0, - 1152.0)

    // Player setup
    call InitCustomPlayerSlots()
    call InitCustomTeams()
endfunction




//Struct method generated initializers/callers:

function jasshelper__initstructs22213718 takes nothing returns nothing

call ExecuteFunc("s__WorldBounds_WorldBounds___WorldBoundInit__onInit")




call ExecuteFunc("s__SpellEffectEvent___S_SpellEffectEvent___M__onInit")


call ExecuteFunc("s__FrozenOrb___IceBolt_MissileStruct__onInit")

call ExecuteFunc("s__FrozenOrb___FrozenOrb_MissileStruct__onInit")

call ExecuteFunc("s__Show___X_Show___I__onInit")

    call ExecuteFunc("s__Missile_onInit")
    call ExecuteFunc("s__FrozenOrb___Buff_onInit")
endfunction

