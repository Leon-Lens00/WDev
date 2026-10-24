//TESH.scrollpos=665
//TESH.alwaysfold=0
library Missile /* v2.0.2
*************************************************************************************
*
*   Creating custom projectiles in Warcraft III
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
*   Credits to Dirac, emjlr3, AceHart, Bribe, Nestharus, Maghteridon96 and Vexorian.
*
*************************************************************************************
*
*   */ requires /*
*
*       - Missile requires nothing
*
*************************************************************************************
*
*   Optional requirements listed can reduce overall code generation,
*   add safety mechanisms, decrease overhead and optimize handle management.  
*   For a better overview I put them into blocks.
*
*   I recommend to use at least one per block in your map.
*       
*   a). For best debug results: ( Useful for Missile )
*       */ optional ErrorMessage    /* github.com/nestharus/JASS/tree/master/jass/Systems/ErrorMessage  
*   
*   b). Fatal error protection ( Case: unit out of world bounds )   
*           - WorldBounds is safer than BoundSentinel.
*           - WorldBounds adds more overhead than BoundSentinel.
*       */ optional WorldBounds     /* githubusercontent.com/nestharus/JASS/master/jass/Systems/WorldBounds/script.j
*       */ optional BoundSentinel   /* wc3c.net/showthread.php?t=102576
*       
*   c). Handle recycling ( Speed gain, memory management ):
*           - uses MissileRecylcer > Dummy > xedummy. 
*       */ optional MissileRecycler /* hiveworkshop.com/forums/jass-resources-412/system-missilerecycler-206086/
*       */ optional Dummy           /* github.com/nestharus/JASS/blob/master/jass/Systems/Dummy/Dummy.w3x
*       */ optional xedummy         /* wc3c.net/showthread.php?t=101150
*
*   d). Misc ( Absolutely not needed, just listed to avoid an onIndex event )
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
*   2. Global configuration   
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       Seven constants to setup!
*/
    globals
    
        /**
        *   Missiles are moved periodically. 1./32. is recommended.
        *       • Too short timeout values may cause performance issues.
        *       • Too large timeout values may look fishy.
        */
        public constant real TIMER_TIMEOUT                        = 1./32.
        
        /**
        *   Owner of all Missile dummies. Should be a neutral player in your map.
        */ 
        public constant player NEUTRAL_PASSIVE                    = Player(15)
        
        /**
        *   Raw code of the dummy unit. Object Editor ( F6 )
        *       • Must be correct, otherwise missiles can neither be recycled nor destroyed.
        *       • Units of other type ids will not be thrown into the recycler bin.
        */
        public constant integer DUMMY_UNIT_ID                     = 'dumi'
    
        /**
        *   The maximum collision size used in your map. If unsure use 197. ( town hall collision )
        *       • Applies for all types of widgets.
        *       • A precise value can improve Missile's performance,
        *         since smaller values enumerate less widgtes per loop per missile.
        */
        public constant real MAXIMUM_COLLISION_SIZE               = 197.
        
        /**
        *   Collision types for missiles. ( Documentation only )
        *   Missile decides internally each loop which type of collision is used.
        *       • Uses circular collision dectection for speed < collision. ( good accuracy, best performance )
        *       • Uses rectangle collision for speed >= collision. ( best accuracy, bad performance )
        */
        public constant integer COLLISION_TYPE_CIRCLE     = 0 
        public constant integer COLLISION_TYPE_RECTANGLE  = 1 
    
        /**
        *   Determines when rectangle collision is used to detect nearby widgets. 
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
        *   DELAYED_MISSILE_DEATH_ANIMATION_TIME is delay in seconds,
        *   Missile holds back a dummy, before recycling it.
        *       • The time does not have to be precises.
        *       • Requires WRITE_DELAYED_MISSILE_RECYCLING = true 
        */
        private constant real DELAYED_MISSILE_DEATH_ANIMATION_TIME = 2.

        /**
        *   USE_DESTRUCTABLE_FILTER and USE_ITEM_FILTER are redundant constants from previous Missile versions.
        *   They do nothing, but remain for backwards compatibilty.
        *   From Missile version 1.5 on any widget collision is always enabled.
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
    *   Using occluder height is an idea of mine. Of course you can use your own value.
    */
    function GetDestructableHeight takes destructable d returns real
        return GetDestructableOccluderHeight(d)// Other example: return 100.
    endfunction

    /**
    *   Same as GetUnitBodySize, but for items.
    *   Again it is up to you to figure out a fictional item height.
    */
    function GetItemHeight takes item i returns real
        return 20.
    endfunction
    
    /**
    *   Unit indexers and missiles: ( Only if you do not use a dummy recycling library )
    *   ===========================
    *   It is most likely intended that projectiles do not run through a unit indexing snippet.
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
            integer    data        // For data transfer set and read data.  
            boolean    recycle     // Is automatically set to true, when a Missile reaches it's destination.
            real       turn        // Set a turn rate for missiles.
            
            // Neither collision nor collisionZ accept values below zero.
            real       collision   // Collision size in plane x / y.
            real       collisionZ  // Collision size in z - axis.
            
        // Fields you can only read:
        // =========================      
            //
            readonly boolean         allocated        
            readonly unit            dummy// The dummy unit of this missile.
        
            // Position members for you needs.
            readonly MissilePosition origin// Grants access to readonly members of MissilePosition,
            readonly MissilePosition impact// which are "x", "y", "z", "angle", "distance", "slope" and the pitch angle "alpha". 
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
            //  • Runs after onDestructableFilter ( if a filter is declared )

            static method onDestructableFilter takes nothing returns boolean
            //  • Runs before onDestructable as filter function.
            //  • Runs for destructables in collision range + Missile_MAX_COLLISION_RANGE.
            //  • Get the filter destructable via "GetFilterDestructable()" 
            //  • Designed only for improving code read-ability.

            static method onItem               takes Missile missile, item hit returns boolean
            //  • Runs for items in collision range of a missile.
            //  • Runs after onItemFilter ( if a filter is declared )

            static method onDestructableFilter takes nothing returns boolean
            //  • Runs before onItem as filter function.
            //  • Runs for items in collision range + Missile_MAX_COLLISION_RANGE.
            //  • Get the filter item via "GetFilterItem()" 
            //  • Designed only for improving code read-ability.            
            
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
            //
            //  • Return true will recycle this missile delayed. ( only if WRITE_DELAYED_MISSILE_RECYCLING = true )
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
// can easily understand how the code gets compiled and evaluated.
//
// Let's go!
        
    globals
        // Core constant handle variables of Missile.
        private constant trigger   CORE  = CreateTrigger()
        private constant timer     TMR   = CreateTimer()
        private constant location  LOC   = Location(0., 0.)
        private constant rect      RECT  = Rect(0., 0., 0., 0.)
        private constant group     GROUP = CreateGroup()
        private constant hashtable HASH  = InitHashtable()
        // For starting and stopping the timer.
        private integer active = 0
        // Arrays for data structure.
        private integer          array   instances
        private Missile          array   missileStack
        private boolexpr         array   expression
        private triggercondition array   condition
        private integer          array   remove
        // Arrays for widgets filter functions in structs.
        private boolexpr         array   destFilter
        private boolexpr         array   itemFilter
        // Rectangle filter functions in Missile.
        private boolexpr unitFilter
    endglobals
    
    public function GetLocZ takes real x, real y returns real
        call MoveLocation(LOC, x, y)
        return GetLocationZ(LOC)
    endfunction
    
    // For WRITE_DELAYED_MISSILE_RECYCLING = true Missile will hold back dummy for DELAYED_MISSILE_DEATH_ANIMATION_TIME,
    // until the are recylced. ( placed in a static if )
    //
    //! runtextmacro optional WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")
    
    // The code of this macro boxes a missiles position and does the required trigonometry.
    //
    //! runtextmacro WRITE_MISSILE_POSITION_CODE()
    
    // Missiles structure works like a linked list with the folling methods:
    // allocateCollection(), allocateNode(), insertEnd(node) and remove()
    //
    private keyword MissileStructure
    struct Missile extends array
        implement MissileStructure

        // Constants:
        // ==========
        //
        // Attach point name for effects created via model=. 
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
        // Readable x / y / z for your needs and xPrivate / yPrivate for cool mathematics.
        private real xPrivate
        private real yPrivate
        private real xPrev
        private real yPrev
        
        // Readonly members:
        // =================
        //
        // Prevents a double free case.
        readonly boolean allocated
        
        // The dummy unit.
        readonly unit    dummy
        
        // Position members for you needs.
        readonly MissilePosition origin// Grants access to readonly members of MissilePosition,
        readonly MissilePosition impact// which are "x", "y", "z", "angle", "distance", "slope" and "alpha". 
        readonly real            terrainZ
        readonly real            x
        readonly real            y
        readonly real            z
        readonly real            angle// Current angle

        // Collision detection type. ( Evaluated new in each loop )
        readonly integer         collisionType// Current collision type ( circular or rectangle )
        
        // Members you can set:
        // ====================
        //
        unit       source
        unit       target      // For homing missiles.
        real       distance    // Distance traveled.
        player     owner       // Pseudo owner for faster onCollide evaluation. The proper dummy owner is PLAYER_NEUTRAL_PASSIVE
        real       speed       // Vector lenght for missile movement in plane x / y.
        real       acceleration
        real       damage
        integer    data        // For data transfer set and read data.  
        boolean    recycle     // Is set to true, when a Missile reaches it's destination.
        real       turn        // Set a turn rate for a missile. 
        
        // Members which are monitored: ( DEBUG_MODE )
        // ============================
        //
static if not DEBUG_MODE then
        
        real       collision     // Collision size in plane x / y.
        real       collisionZ    // Collision size in z - axis.
else
        // Check for collision < 0.
        debug private real collisionDebug
        method operator collision= takes real value returns nothing
            static if LIBRARY_ErrorMessage then
                debug call ThrowError((value < 0), "Missile", "collision=", "collision", this, "Found collision below zero [" + R2S(value) + "]!")
            endif
            debug set collisionDebug = value
        endmethod
        method operator collision takes nothing returns real
            debug return collisionDebug
        endmethod
        
        // Check for collisionZ < 0.
        debug private real collisionZDebug
        method operator collisionZ= takes real value returns nothing
            static if LIBRARY_ErrorMessage then
                debug call ThrowError((value < 0), "Missile", "collisionZ=", "collisionZ", this, "found collisionZ below zero [" + R2S(value) + "]!")
            endif
            debug set collisionZDebug = value
        endmethod
        method operator collisionZ takes nothing returns real
            debug return collisionZDebug
        endmethod   
endif
        // Operator overloading:
        // =====================
        //
        // Effect handle on a missile dummy. For multiple effects attaching, access "dummy" in your struct.
        private effect sfx
        private string path
        method operator model= takes string modelFile returns nothing
            if (sfx != null) then
                call DestroyEffect(sfx)
            endif

            set path = modelFile
            set sfx  = AddSpecialEffectTarget(modelFile, dummy, ORIGIN)
        endmethod
        method operator model takes nothing returns string
            return path
        endmethod
       
        real open
       // Enables curved movement for your missile. PI/2 is not allowed.
        method operator curve= takes real value returns nothing
            set open = Tan(value)*origin.distance
        endmethod
        method operator curve takes nothing returns real
            if (origin.distance == 0.) then
                return 0.// It's a limit of sequence and crashes the thread. Intuitively chosen 0 as return value.
            endif
            return Atan(open/origin.distance)
        endmethod
       
        real height
        // Enables arcing movement for your missile. PI/2 is not allowed.
        method operator arc= takes real value returns nothing
            set height = Tan(value)*origin.distance/4.
        endmethod
        method operator arc takes nothing returns real
            if (origin.distance == 0.) then
                return 0.// It's a limit of sequence and crashes the thread. Intuitively chosen 0 as return value.
            endif
            return Atan(4.*height/origin.distance)
        endmethod
       
        private real scaleValue 
        method operator scale= takes real value returns nothing
            call SetUnitScale(dummy, value, 1., 1.)
            set scaleValue = value
        endmethod
        method operator scale takes nothing returns real
            return scaleValue
        endmethod
        
        // Methods:
        // ========
        //
        method bounce takes nothing returns nothing
            call origin.move(xPrivate, yPrivate, z)
            set distance = 0.
        endmethod
       
        method deflect takes real tx, real ty returns nothing
            local real a = 2.*Atan2(ty - yPrivate, tx - xPrivate) + bj_PI - angle
            call impact.move(xPrivate + (origin.distance - distance)*Cos(a), yPrivate + (origin.distance - distance)*Sin(a), impact.z)
            call bounce()
        endmethod
        
        method deflectEx takes real tx, real ty, real tz returns nothing
            call impact.move(impact.x, impact.y, tz)
            call deflect(tx, ty)
        endmethod
    
        // Please do not pass in 0.
        method flightTime2Speed takes real duration returns nothing
            set speed = RMaxBJ(0.00000001, (origin.distance - distance)*Missile_TIMER_TIMEOUT/duration)
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
            set allocated = false
            call remove()// Throws an error for invalid nodes.
            call impact.destroy()
            call origin.destroy()
            //
            call DestroyEffect(sfx)
            call FlushChildHashtable(HASH, this)
            if (GetUnitTypeId(dummy) == Missile_DUMMY_UNIT_ID) then
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
            //
            set sfx = null
            set source = null
            set target = null
            set dummy = null
            set owner = null
        endmethod
        
        // Runs in createEx.
        //! textmacro MISSILE_RESET_ALL_MEMBERS
            set path = null
            set speed = 0.
            set acceleration = 0.
            set distance = 0.
            set height = 0.
            set turn = 0.
            set open = 0.
            set collision = 0.
            set collisionZ = 0.
            set collisionType = 0
            set scaleValue = 1.
            set wantDestroy = false
            set recycle = false
        //! endtextmacro
    
        // Launches a dummy of your choice.
        static method createEx takes unit missileDummy, real impactX, real impactY, real impactZ returns thistype
            local thistype this = thistype.allocateNode()
            local real originX  = GetUnitX(missileDummy)
            local real originY  = GetUnitY(missileDummy)
            local real originZ  = GetUnitFlyHeight(missileDummy)
            set allocated       = true
            //
            //! runtextmacro MISSILE_RESET_ALL_MEMBERS()
            //
            set origin = MissilePosition.create(originX, originY, originZ)
            set impact = MissilePosition.create(impactX, impactY, impactZ)
            call MissilePosition.link(origin, impact)
                        
            set xPrivate  = originX
            set yPrivate  = originY
            set x         = originX
            set y         = originY
            set z         = originZ
            set angle     = origin.angle
            set dummy     = missileDummy
            set stackSize = 0
            
            call SetUnitFlyHeight(missileDummy, origin.z - Missile_GetLocZ(originX, originY), 0.)   
            //
            static if LIBRARY_ErrorMessage then
                debug call ThrowError((GetUnitTypeId(missileDummy) == 0), "Missile", "createEx", "missileDummy", this, "Invalid missile dummy unit (null)!")
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
            // Get Dummy.
            //! runtextmacro MISSILE_GET_DUMMY_FROM_LIBRARY()
        endmethod
        
        // Wrapper to createEx.
        static method createXYZ takes real x, real y, real z, real impactX, real impactY, real impactZ returns thistype
            local real angle = Atan2(impactY - y, impactX - x)
            // Get Dummy.
            //! runtextmacro MISSILE_GET_DUMMY_FROM_LIBRARY()
        endmethod
    
        // Called from each active struct every Missile_TIMER_TIMEOUT seconds. 
        // In this method performance matters.
        //  • Locals used for faster multiple lookups.
        //  • Short variable names. 
        method move takes nothing returns nothing
            local MissilePosition loc
            local real a 
            local real d
            local real s
            local real v
            local unit u
            
            local real h    
            local real tx
            local real ty 
            local real dex
            
            loop
                exitwhen (0 == this)
                set loc = origin
                set h   = height
                
                // Missile target.
                set u = target
                if (u != null) then
                    if (0 != GetUnitTypeId(u)) then
                        set tx = GetUnitX(u)
                        set ty = GetUnitY(u)
                        set a  = Atan2(ty - yPrivate, tx - xPrivate)
                        // 
                        // Uses a fictional hit box of GetUnitBodySize()*HIT_BOX  for the z offset.
                        call origin.move(x, y, z)
                        call impact.move(tx, ty, GetUnitFlyHeight(u) + GetUnitBodySize(u)*Missile.HIT_BOX)
                        set distance = loc.distance - SquareRoot((tx - xPrivate)*(tx - xPrivate) + (ty - yPrivate)*(ty - yPrivate))
                    else
                        set a = loc.angle
                        set target = null
                    endif
                else
                    set a = loc.angle
                endif
                set u = dummy
                
                // Missile turn.
                if (0 != turn) and (Cos(angle - a) < Cos(turn)) then
                    if (Sin(a - angle) >= 0) then
                        set angle = angle + turn
                    else
                        set angle = angle - turn
                    endif
                else
                    set angle = a
                endif
                
                // Update position members.
                set v = speed
                set d = loc.distance
                //call BJDebugMsg(R2S(d))
                if (distance + v > d) then
                    set s = d + 0.000001
                else
                    set s = distance + v
                endif
                set distance = s
                //
                set tx       = xPrivate + v*Cos(angle)
                set ty       = yPrivate + v*Sin(angle)
                set speed    = v        + acceleration
                set xPrivate = tx
                set yPrivate = ty
                
                // Detect the collision type.
                if (v < collision*Missile_COLLISION_ACCURACY_FACTOR) then
                    set collisionType = Missile_COLLISION_TYPE_CIRCLE
                else
                    set collisionType = Missile_COLLISION_TYPE_RECTANGLE
                endif
                
                // Missile curve.
                if (open != 0) then
                    set a  = 4*open*s*(d - s)/(d*d)
                    set tx = tx + a*Cos(angle + 1.57)
                    set ty = ty + a*Sin(angle + 1.57)
                    call SetUnitFacing(u, (angle + Atan(-((4*open)*(2*s - d))/(d*d)))*bj_RADTODEG)
                else
                    call SetUnitFacing(u, angle*bj_RADTODEG)
                endif
                
                // Missile arc.
                call MoveLocation(LOC, tx, ty)
                set terrainZ  = GetLocationZ(LOC)
                if (h != 0) or (loc.slope != 0) then
                    set z = loc.z - terrainZ + loc.slope*s 
                    set dex = loc.alpha
                    if (h != 0) then
                        set z = z + (4*h*s*(d - s)/(d*d))
                        set dex = dex - Atan(((4*h)*(2*s - d))/(d*d))*bj_RADTODEG
                    endif
                    if (GetUnitTypeId(u) == Missile_DUMMY_UNIT_ID) then
                        call SetUnitAnimationByIndex(u, R2I(dex + 90.5))
                    endif
                else
                    set z = loc.z - terrainZ
                endif
                
                // Missile position.
                static if not LIBRARY_BoundSentinel and LIBRARY_WorldBounds then
                    if (tx > WorldBounds.maxX) or (tx < WorldBounds.minX) or (ty > WorldBounds.maxY) or (ty < WorldBounds.minY) then
                        // set wantDestroy = true
                    else
                        call SetUnitX(u, tx)
                        call SetUnitY(u, ty)
                    endif
                else
                    call SetUnitX(u, tx)
                    call SetUnitY(u, ty)
                endif
                call SetUnitFlyHeight(u, z, 0.)
               
                // Update missile x / y ( readonly )
                set xPrev = x
                set yPrev = y
                set x = tx
                set y = ty
               
                // Check for destination reached.
                if (s >= d) then
                    set recycle = true
                endif
               
                set this = next
            endloop
            set u = null
        endmethod
            
        // Widget collision API:
        // =====================
        //
        // Runs automatically on widget collision.
        method hitWidget takes widget w returns nothing
            call SaveWidgetHandle(HASH, this, GetHandleId(w), w)
        endmethod
        
        // All widget which have been hit return true.
        method hasHitWidget takes widget w returns boolean
            return HaveSavedHandle(HASH, this, GetHandleId(w))
        endmethod
        
        // Removes a widget from the missile's memory of hit widgets. ( This widget can be hit again )
        method removeHitWidget takes widget w returns nothing
            call RemoveSavedHandle(HASH, this, GetHandleId(w))
        endmethod
        
        // Flushes a missile's memory for collision. ( All widgets can be hit again )
        method flushHitWidgets takes nothing returns nothing
            call FlushChildHashtable(HASH, this)
        endmethod
        
        // Tells missile to call removeHitWidget(w) after "seconds" time.
        // Does not apply to widgets, which are already hit by this missile.
        readonly integer stackSize
        method enableHitAfter takes widget w, real seconds returns nothing
            local integer id = GetHandleId(w)
            local integer dex
            if (id == 0) then
                return
            endif
            if HaveSavedInteger(HASH, this, id) then
                set dex = LoadInteger(HASH, this, id)
            else
                set dex = stackSize
                set stackSize = stackSize + 1
                call SaveInteger(HASH, this, id, dex)
                call SaveInteger(HASH, this, dex, id)
            endif
            call SaveReal(HASH, this, id, seconds)// Set time.
        endmethod
        
        method updateStack takes nothing returns nothing
            local integer dex = 0
            local integer id
            local real time
            loop
                exitwhen (dex == stackSize)
                set id = LoadInteger(HASH, this, dex)
                set time = LoadReal(HASH, this, id) - Missile_TIMER_TIMEOUT
                if (time <= 0.) or not HaveSavedHandle(HASH, this, id) then
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
                    set dex = dex - 1
                else
                    call SaveReal(HASH, this, id, time)
                endif
                set dex = dex + 1
            endloop
        endmethod
    
        // Widget collision code:
        // ======================
        //
        // Transfer data to action functions.                  
        private static Missile temp   = 0
        private static boolean circle = true
        //
        // 1.) Rectangle collision for fast moving missiles with small collision radius.
        //        
        // Runs for destructables and items in a rectangle.
        // Checks if widget w is in collision range of a missile.
        // Is not precise in z - axis collision.
        private method checkWidgetRectangle takes widget w, real height returns boolean
            local real wx = GetWidgetX(w)
            local real wy = GetWidgetY(w)
            local real wz = Missile_GetLocZ(wx, wy) - terrainZ
            local real dx = x - xPrev
            local real dy = y - yPrev
            local real s  = (dx*(wx - xPrev) + dy*(wy - yPrev))/(dx*dx + dy*dy)  
static if Missile_USE_COLLISION_Z_FILTER then
            local real cz = collisionZ
else
            local real cz = collision
endif       //
            if (s < 0) then
                set s = 0.
            elseif (s > 1) then
                set s = 1.
            endif
            set dx = (xPrev + s*dx) - wx
            set dy = (yPrev + s*dy) - wy
            set s  =  dx*dx + dy*dy
            if (s < bj_enumDestructableRadius) and (wz + height >= z - cz) and (wz <= z + cz) then
                set bj_enumDestructableRadius = s
                return true
            endif
            return false
        endmethod        
        //
        // 2.) Circular collision detection for all other missiles.
        //
        // Runs for destructables and items in a circle.
        // Z - axis collision is precise.
        private method checkWidgetCircle takes widget w, real height returns boolean
            local real wx = GetWidgetX(w)
            local real wy = GetWidgetY(w)
            local real wz = Missile_GetLocZ(wx, wy) - terrainZ
            local real d  = (x - wx)*(x - wx) + (y - wy)*(y - wy) 
static if Missile_USE_COLLISION_Z_FILTER then
            local real cz = collisionZ
else
            local real cz = collision
endif       //
            if (d < bj_enumDestructableRadius) and (wz + height >= z - cz) and (wz <= z + cz) then
                set bj_enumDestructableRadius = d
                return true
            endif        
            return false
        endmethod
        //
        //  3.) Action functions inside the widget enumeration thread.
        //
        // Runs for every enumerated destructable.
        //  • Searches the closest available destructables
        //  • Distance formula based on the Pythagorean theorem.
        //                         
        private static method enumDests takes nothing returns nothing
            local destructable d = GetEnumDestructable()
            if HaveSavedHandle(HASH, temp, GetHandleId(d)) then
                set d = null 
                return 
            endif
            if (circle) then
                if temp.checkWidgetCircle(d, GetDestructableHeight(d)) then
                    set bj_destRandomCurrentPick = d
                endif
            // Runs rectangle collision check.
            elseif temp.checkWidgetRectangle(d, GetDestructableHeight(d)) then
                set bj_destRandomCurrentPick = d
            endif
            set d = null
        endmethod
        //
        // Runs for every enumerated item.
        //  • Searches the closest available item.
        //  • Distance formula based on the Pythagorean theorem.
        // 
        private static method enumItems takes nothing returns nothing
            local item i = GetEnumItem()
            if HaveSavedHandle(HASH, temp, GetHandleId(i)) then
                set i = null 
                return 
            endif
            if (circle) then
                if temp.checkWidgetCircle(i, GetItemHeight(i)) then
                    set bj_itemRandomCurrentPick = i
                endif
            // Runs rectangle collision check.
            elseif temp.checkWidgetRectangle(i, GetItemHeight(i)) then
                set bj_itemRandomCurrentPick = i
            endif
            set i = null
        endmethod
        //
        //  4.) Filter function for rectangle unit collision.
        //
        // Runs for every enumerated units.
        //  • Filters out units which are not in collision range in plane x / y.
        //
        private static method filterUnits takes nothing returns boolean
            local thistype this = thistype.temp
            //
            local unit u = GetFilterUnit()
            local real a 
            local real b 
            local real s 
            local boolean is
            // Missile knows this unit already.
            if HaveSavedBoolean(HASH, this, GetHandleId(u)) then
                set u = null
                return false
            endif
            //
            set a = x - xPrev
            set b = y - yPrev
            set s = (a*(GetUnitX(u) - xPrev) + b*(GetUnitY(u)- yPrev))/(a*a + b*b)
            if(s < 0) then
                set s = 0.
            elseif(s > 1) then
                set s = 1.
            endif
            set is = IsUnitInRangeXY(u, xPrev + s*a, yPrev + s*b, collision) 
            set u = null
            return is
        endmethod
        //
        // 5.) Proper rect preparation.
        //
        // For rectangle.
        private method prepareRectRectangle takes nothing returns nothing
            local real x1 = xPrev 
            local real y1 = yPrev 
            local real x2 = x
            local real y2 = y
            local real d = collision + Missile_MAXIMUM_COLLISION_SIZE
            // What is min, what is max ...
            if(x1 < x2) then
                if( y1 < y2) then
                    call SetRect(RECT, x1 - d, y1 - d, x2 + d, y2 + d)
                else
                    call SetRect(RECT, x1 - d, y2 - d, x2 + d, y1 + d)
                endif
            else
                if( y1 < y2) then
                    call SetRect(RECT, x2 - d, y1 - d, x1 + d, y2 + d)
                else
                    call SetRect(RECT, x2 - d, y2 - d, x1 + d, y1 + d)
                endif
            endif 
        endmethod
        //
        // For circular.
        private method prepareRectCircle takes nothing returns nothing
            local real d = collision + Missile_MAXIMUM_COLLISION_SIZE
            call SetRect(RECT, x - d, y - d, x + d, y + d)
        endmethod
        //
        // 6.) API for the MissileStruct iteration.
        //
        method groupEnumUnitsRectangle takes nothing returns nothing
            call prepareRectRectangle()
            set thistype.temp = this
            call GroupEnumUnitsInRect(GROUP, RECT, unitFilter)
        endmethod
        //
        // Prepares destructable enumeration, then runs enumDests.
        method checkDestCollision takes boolexpr expr returns nothing
            set circle = (collisionType == Missile_COLLISION_TYPE_CIRCLE)
            if (circle) then
                call prepareRectCircle()
            else
                call prepareRectRectangle()
            endif
            //
            set thistype.temp = this
            set bj_destRandomCurrentPick = null
            set bj_enumDestructableRadius = collision*collision + 1.
            call EnumDestructablesInRect(RECT, expr, function thistype.enumDests)
        endmethod
        //
        // Prepares item enumeration, then runs enumItems.
        method checkItemCollision takes boolexpr expr returns nothing
            set circle = (collisionType == Missile_COLLISION_TYPE_CIRCLE)
            if (circle) then
                call prepareRectCircle()
            else
                call prepareRectRectangle()
            endif
            //
            set thistype.temp = this
            set bj_itemRandomCurrentPick  = null
            set bj_enumDestructableRadius = collision*collision + 1.
            call EnumItemsInRect(RECT, expr, function thistype.enumItems)
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
                debug local unit dummy = CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, 0, 0, 0)
                debug call ToogleUnitIndexer(prev)
                //
                debug call ThrowError((GetUnitTypeId(dummy) != Missile_DUMMY_UNIT_ID), "Missile", "DEBUG_MISSILE", "typeid",    0, "Global setup for public integer DUMMY_UNIT_ID is incorrect! This map currently can't use Missile!")
                debug call ThrowError((Missile_MAXIMUM_COLLISION_SIZE < 0),            "Missile", "DEBUG_MISSILE", "collision", 0, "Global setup for public real MAXIMUM_COLLISION_SIZE is incorrect, below zero! This map currently can't use Missile!")
                debug call RemoveUnit(dummy)
                debug set dummy = null
            endif
            //
            set unitFilter = Filter(function thistype.filterUnits) 
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
            
            return this
        endmethod
        
        method insertEnd takes thistype node returns thistype
            
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(this == 0,        "MissileStructure", "enqueue", "thistype", this, "Attempted To Enqueue On To Null List.")
                debug call ThrowError(not isCollection, "MissileStructure", "enqueue", "thistype", this, "Attempted To Enqueue On To Invalid List.")
                debug set node.isNode = true
            endif
            
            
            set node._list = this
        
            if (_first == 0) then
                set _first = node
                set _last = node
                set node._prev = 0
            else
                set _last._next = node
                set node._prev = _last
                set _last = node
            endif
            
            set node._next = 0
            
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
        endmethod
    endmodule
    
    // Boolean expressions per struct:
    // ===============================
    // 
    // Filter function for item enumeration. ( Runs only if a filter is declared in the struct )
    private function MissileCreateItemFilter takes integer structId, code func returns nothing
        set itemFilter[structId] = Filter(func)
    endfunction
    
    // Filter function for destructable enumeration. ( Runs only if a filter is declared in the struct ) 
    private function MissileCreateDestructableFilter takes integer structId, code func returns nothing
        set destFilter[structId] = Filter(func)
    endfunction
    
    // Condition function for the core trigger evaluation. ( Runs for all struct using module MissileStruct )
    private function MissileCreateExpression takes integer structId, code func returns nothing
        set expression[structId] = Condition(func)
    endfunction
    
    // Creates a collection for a struct. ( Runs for all struct using module MissileStruct )
    private function MissileCreateCollection takes integer structId returns nothing
        set missileStack[structId] = Missile.allocateCollection()
    endfunction
    
    // Core:
    // =====
    //
    // Fires every Missile_TIMER_TIMEOUT.
    private function Fire takes nothing returns nothing
        local integer i = remove[0]
        set remove[0] = 0
        loop
            exitwhen i == 0
            if (instances[i] == 0) and (condition[i] != null) then
                call TriggerRemoveCondition(CORE, condition[i])
                set condition[i] = null
                set active = active - 1
            endif
            set i = remove[i]
        endloop
        if (active == 0) then
            call PauseTimer(TMR)
        else
            call TriggerEvaluate(CORE)
        endif
    endfunction
    
    // Conditionally starts the timer.
    private function StartPeriodic takes integer structId returns nothing
        if (instances[structId] == 0) then
            if (active == 0) then
                call TimerStart(TMR, Missile_TIMER_TIMEOUT, true, function Fire)
            endif
            if (condition[structId] == null) then
                set condition[structId] = TriggerAddCondition(CORE, expression[structId])
                set active = active + 1
            endif
        endif
        set instances[structId] = instances[structId] + 1
    endfunction
    
    // Conditionally stops the timer.
    private function StopPeriodic takes integer structId returns nothing
        set instances[structId] = instances[structId] - 1
        if (instances[structId] == 0) then
            set remove[structId] = remove[0]
            set remove[0] = structId
        endif
    endfunction
    
    // Module:
    // =======
    //
    module MissileStruct
        
// Runs check during compile time.
static if DEBUG_MODE then
    static if thistype.onMissile.exists then
        Error Message from library Missile in struct thistype !
        thistype.onMissile is a reserved name for Missile, once you implemented MissileStruct.
        thistype.onMissile is currently not supported by library Missile. 
        Please delete or re-name that method.
    endif
endif
        
        // Called from missileIterate. "P" to avoid code collision.
        private static method missileTerminateP takes Missile node returns nothing
            static if thistype.onRemove.exists then
                static if Missile_WRITE_DELAYED_MISSILE_RECYCLING and RecycleBin.recycle.exists then
                    if thistype.onRemove(node) and (GetUnitTypeId(node.dummy) == Missile_DUMMY_UNIT_ID) then
                        call RecycleBin.recycle(node.dummy)
                        call node.nullBefore()
                    endif
                else
                    call thistype.onRemove(node)
                endif
            endif
            
            call node.terminate()
            call StopPeriodic(thistype.typeid)
        endmethod
    
        // Runs every Missile_TIMER_TIMEOUT for this struct.
        private static method missileIterateP takes nothing returns boolean
            local Missile this = missileStack[thistype.typeid].first 
            local Missile node
            local real collideZ
            local boolean b
            local unit u
            
            call this.move()// Moves all missiles of this collection. 
            loop
                exitwhen (0 == this)
                set node = this.next// The linked list should not lose the next node.
               
                if (this.wantDestroy) then
                    static if thistype.onFinish.exists then
                        if thistype.onFinish(this) then
                            call thistype.missileTerminateP(this)
                        endif
                    else
                        call thistype.missileTerminateP(this)
                    endif
                else
                    if (this.stackSize > 0) then
                        call this.updateStack()
                    endif
                    
                    // Runs unit collision.
                    static if thistype.onCollide.exists then
                        if (this.allocated) and (0 != this.collision) then
                            set b = (this.collisionType == Missile_COLLISION_TYPE_RECTANGLE)  
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
                                    if ((IsUnitInRange(u, this.dummy, this.collision)) or (b)) then  
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
                        if (this.allocated) and (0 != this.collision) then
                            call this.checkDestCollision(destFilter[thistype.typeid])
                            if (bj_destRandomCurrentPick != null) then 
                                call SaveDestructableHandle(HASH, this, GetHandleId(bj_destRandomCurrentPick), bj_destRandomCurrentPick) 
                                if thistype.onDestructable(this, bj_destRandomCurrentPick) then
                                    call missileTerminateP(this)
                                endif
                            endif
                        endif
                    endif
                    
                    // Runs item collision.
                    static if thistype.onItem.exists then
                        //  Check if the missile is not terminated.
                        if (this.allocated) and (0 != this.collision) then
                            call this.checkItemCollision(itemFilter[thistype.typeid])
                            if (bj_itemRandomCurrentPick != null) then 
                                call SaveItemHandle(HASH, this, GetHandleId(bj_itemRandomCurrentPick), bj_itemRandomCurrentPick) 
                                if thistype.onItem(this, bj_itemRandomCurrentPick) then
                                    call missileTerminateP(this)
                                endif
                            endif
                        endif
                    endif
                
                    // Runs when the destination is reached.
                    if (this.recycle) and (this.allocated) then
                        static if thistype.onFinish.exists then
                            if thistype.onFinish(this) then
                                call thistype.missileTerminateP(this)
                            else
                                set this.recycle = false
                            endif
                        else
                            call thistype.missileTerminateP(this)
                        endif
                    endif
                
                    // Runs on terrian collision.
                    static if thistype.onTerrain.exists then
                        if (this.allocated) and (this.z < 0) and thistype.onTerrain(this) then
                            call missileTerminateP(this)
                        endif
                    endif
                
                    // Runs every Missile_TIMER_TIMEOUT.
                    static if thistype.onPeriod.exists then
                        if (this.allocated) and thistype.onPeriod(this) then
                            call missileTerminateP(this)
                        endif
                    endif
                endif
                set this = node
            endloop
           
            set u = null
            return false
        endmethod
    
        // Places the launcher in your struct.
        static method launch takes Missile missile returns nothing
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(missile.launched, "thistype", "launch", "missile.launched", missile, "This missile was already launched before!")
            endif
            debug set missile.launched = true
            //
            call missileStack[thistype.typeid].insertEnd(missile)
            call StartPeriodic(thistype.typeid)
        endmethod
    
        // Runs onInit. Creates the collection, trigger condition and widget filters.
        private static method onInit takes nothing returns nothing
            call MissileCreateCollection(thistype.typeid)
            call MissileCreateExpression(thistype.typeid, function thistype.missileIterateP)
            static if thistype.onDestructableFilter.exists and thistype.onDestructable.exists then
                call MissileCreateDestructableFilter(thistype.typeid, function thistype.onDestructableFilter)
            endif
            static if thistype.onItemFilter.exists and thistype.onItem.exists then
                call MissileCreateItemFilter(thistype.typeid, function thistype.onItemFilter)
            endif
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
            readonly real slope
            readonly real alpha
            
            // Creates an origin - impact link.
            private thistype ref
            
            private static method math takes thistype a, thistype b returns boolean
                // Set a.
                set a.angle     = Atan2(b.y - a.y, b.x - a.x)
                set a.distance  = SquareRoot((b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y))
                if (a.distance != 0) then
                    set a.slope = (b.z - a.z)/a.distance
                else// For distance == 0 the thread crashes! 
                    set a.x     = a.x + .0001
                    return false// Runs the thread again.
                endif
                set a.alpha     = Atan(a.slope)*bj_RADTODEG
                // Set b.
                set b.angle     = a.angle + bj_PI
                set b.distance  = a.distance
                set b.slope     = -a.slope
                set b.alpha     = -a.alpha
                return true
            endmethod
            
            static method link takes thistype a, thistype b returns nothing
                set a.ref = b
                set b.ref = a
                loop
                    exitwhen math(a, b)
                endloop
            endmethod
            
            method move takes real toX, real toY, real toZ returns nothing
                set x = toX
                set y = toY
                set z = toZ + Missile_GetLocZ(toX, toY)
                if (ref != this) then
                    loop
                        exitwhen math(this, ref)
                    endloop
                endif
            endmethod
    
            method destroy takes nothing returns nothing
                set recycler[this] = recycler[0]
                set recycler[0]    = this
            endmethod
    
            static method create takes real x, real y, real z returns MissilePosition
                local thistype this = recycler[0]
                 if (0 == this) then
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
                    if (0 >= thistype.time[dex]) then
                    
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
                    
                        if (0 == thistype.max) then
                            call PauseTimer(thistype.t)
                        endif
                    
                    endif
                    set dex = dex + 1
                endloop
            endmethod
    
            static method recycle takes unit toRecycle returns nothing
                if (0 == thistype.max) then
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