//TESH.scrollpos=452
//TESH.alwaysfold=0
library Missile /* v1.4 
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
*       to use for everyone. I promise it. Be aware that Missile does not compile
*       when Cohadar's JassHelper is checked. Please use Vexorian's JassHelper instead.
*
*       Do the setup at: 
*
*           1.) Import instruction  
*           2.) Configuration       
*   
*   Credits to Dirac, emjlr3, AceHart
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
*   add safety mechanims, decrease overhead and optimize handle management.  
*   For a better overview I put them into blocks.
*
*   I recommend to use one per block in your map.
*
*   a) For best debug results:
*       */ optional ErrorMessage    /* [url]https://github.com/nestharus/JASS/tree/master/jass/Systems/ErrorMessage[/url]  
*   
*   b) Fatal error protection ( Case: unit out of world bounds ):   
*           - WorldBounds adds more overhead than BoundSentinel.
*       */ optional WorldBounds     /* [url]https://raw.githubusercontent.com/nestharus/JASS/master/jass/Systems/WorldBounds/script.j[/url]
*       */ optional BoundSentinel   /* [url]http://www.wc3c.net/showthread.php?t=102576[/url]
*       
*   c) Dummy recycling ( Speed gain, memory management ):
*           - Uses MissileRecylcer over Dummy. 
*           - Due to positive user feedbacks I highly recommend to use MissileRecycler.  
*       */ optional MissileRecycler /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/system-missilerecycler-206086/[/url]
*       */ optional Dummy           /* [url]https://github.com/nestharus/JASS/blob/master/jass/Systems/Dummy/Dummy.w3x[/url]
*       */ optional xedummy         /* [url]http://www.wc3c.net/showthread.php?t=101150[/url]
*
*   d) Group handle recycling ( Speed gain ) 
*       */ optional GroupUtils      /* [url]http://www.wc3c.net/showthread.php?t=104464[/url]
*
*   e) Misc ( Absolutely not needed, just listed to avoid an onIndex event. )
*       */ optional UnitIndexer     /* [url]https://github.com/nestharus/JASS/tree/master/jass/Systems/Unit%20Indexer[/url]
*
************************************************************************************
*
*   1. Import instruction
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       You need a dummy unit, using Vexorians "dummy.mdx".
*       If you are using water terrain in your map, the movement type has to be "Hover".
*       This unit must use the locust and crow form ability. (Aloc & Amrf)
*                 ¯¯¯¯
*       Copy Missile into to your map.
*       Libraries listed as optional may improve Missile, 
*       however aren't mandatory to have.
*
*   2. Configuration   
*   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*       Eight constants and two functions to setup and Missile is ready to use!
*/
    globals
    
        /**
        *   Missiles are moved periodically. 1/32 is recommended.
        *       - Small values may cause performance issues.
        *       - Large values may look fishy.
        */
        public constant real TIMER_TIMEOUT                        = 0.031250000
        
        /**
        *   Owner of all Missile dummies. Should be a neutral player in your map.
        */ 
        public constant player NEUTRAL_PASSIVE                    = Player(PLAYER_NEUTRAL_PASSIVE)
        
        /**
        *   Raw code of the dummy unit. Object Editor (F6)
        *   Must be correct, otherwise you will experience lags as game time goes by.
        *   Units having other type ids will not be thrown into the recycler bin.
        *   In DEBUG_MODE you'll recieve an error, if the setup is incorrect.
        */
        public constant integer DUMMY_UNIT_ID                     = 'h000'
    
        /**
        *   The maximum collision size used in your map. If unsure use 197.
        *   Applies for units and destructables.
        *   A precise value can improve Missile's performance,
        *   since smaller values enumerate less widgtes per loop per missile.
        *   In DEBUG_MODE you'll recieve an error, if the setup is incorrect.
        */
        public constant real MAXIMUM_COLLISION_SIZE               = 197.
        
        
//      Set booleans listed below to "true" and the compiler will write 
//      the feature into your map. Otherwise this code is completly ignored.                                        
//          o Yay, I want that           --> "true"
//          o Naah that's useless for me --> "false"

        /**
        *   Set USE_DESTRUCTABLE_FILTER to "true" to:
        *       - Enable destructable collision for Missiles.
        */
        public constant boolean USE_DESTRUCTABLE_FILTER           = true
        
        /**
        *   Enables z axis collision for Missiles. Normally it is only in x and y axis.
        *   This toggle will add overhead! Use when you need:
        *       - Missiles fly over or under widgets.
        *       - Determine between flying and walking units.
        */
        public constant boolean USE_COLLISION_Z_FILTER            = true
        
        /**
        *   Set WRITE_DELAYED_MISSILE_RECYCLING to "true", to write a delayed dummy
        *   recycling system into library Missile. Very recommended in two cases:
        *
        *       - You use a dummy recycling library like Dummy, xedummy.
        *       - You want to display death animations of the effect added to your missiles.
        *       - You DON'T need this, when using MissileRecycler!!!
        */
        public constant boolean WRITE_DELAYED_MISSILE_RECYCLING   = true
        
        /**
        *   Relates to WRITE_DELAYED_MISSILE_RECYCLING. It's the approximated
        *   death animation time for every effect you use on Missiles. Doesn't have to be precise.
        */
        private constant real DELAYED_MISSILE_DEATH_ANIMATION_TIME = 2.
    endglobals

    /**
    *   Only required when USE_COLLSION_Z_FILTER = true.
    *   To detect z collision, every unit needs a body size value.
    *   How you reference these values is up to you: (Hashtable + HandleId/UnitTypeId, constant value for all units...)
    *   In the example I placed a constant value (100) for all units.
    *
    *   If you don't want to use this feature, then return 0.
    */
    function GetUnitBodySize takes unit whichUnit returns real
        return 100. // LoadReal(hash, GetHandleId(whichUnit), KEY_UNIT_BODY_SIZE)<- Example
    endfunction

    /**
    *   Only required when USE_COLLSION_Z_FILTER = true.
    *   Same as GetUnitBodySize, but for destructables.
    */
    function GetDestructableHeight takes destructable whichDestructable returns real
        return GetDestructableOccluderHeight(whichDestructable)
    endfunction
    
/**  
*   2. API
*   ¯¯¯¯¯¯
*       struct Missile extends array
*
*           Methods to create a new Missile instance:
*
*               static method create takes real x, real y, real z, real angleInRadians, real distanceToTravel, real endZ returns Missile
*                   - Basic creator functions of Missile
*
*               static method createXYZ takes real x, real y, real z, real impactX, real impactY, real impactZ returns Missile
*                   - Converts arguments to fit into create(), then calls create. 
*
*               static method createEx takes unit missileDummy, real impactX, real impactY, real impactZ returns Missile
*                   - May launch any unit. Be aware that units of type Missile_DUMMY_UNIT_ID get recycled in the end.
*
*       
*           Members you can configurate:     
*       
*                   - source
*                   - target
*                   - real speed
*                   - real acceleration
*                   - real turn
*                   - real open     --> use curve=
*                   - real height   --> use arc=
*                   - string model
*                   - integer data
*                   - real collision
*                   - real collisionZ ( only available, if USE_COLLISION_Z_FILTER = true )
*           
*           Methods and operator overloading:
*   
*               method operator arc=   takes real value returns nothing
*               method operator curve= takes real value returns nothing
*                   - Only use radians in both methods!!
*
*               method operator arc    takes nothing returns real
*               method operator curve  takes nothing returns real
*
*               method operator scale= takes real value returns nothing
*               method operator scale  takes nothing returns real
*
*               method bounce    takes nothing returns nothing 
*               method deflect   takes real x, real y returns nothing 
*               method deflectEx takes real x, real y, real z returns nothing 
*
*               method destroy   takes nothing returns nothing
*                   - deallocates a Missile.
*
*       Missile offers various "optional" static methods, which can be written into
*       any struct you implement the MissileStruct module in.
*
*   Important:     
*
*       All of them return a boolean, which determines the future of that Missile instance.
*           -   return true  --> destroy the Missile.
*           -   return false --> keep the Missile flying.
*       
*   Available static methods:
*
*       static method onCollide takes Missile missile, unit hit returns boolean
*           -   Runs every time the missile collides with a unit.
*
*  
*       static method onPeriod takes Missile missile returns boolean
*           -   Runs every Missile_TIMER_TIMEOUT seconds.
*
*
*       static method onFinish takes Missile missile returns boolean
*           -   Runs whenever the missile finishes it's course.
*           -   Runs before the missile is destroyed.
*           -   Does not run, if a Missile is destroyed by another method.
*
*
*       static method onRemove takes Missile missile returns boolean
*           -   Runs whenever the missile is deallocated.
*           -   Return true will recycle a Missile delayed ( only if WRITE_DELAYED_MISSILE_RECYCLING = true )
*           -   Return false will recycle a Missile right away.
*           -   Runs always, if declared!!
*
*
*       static method onDestructableFilter takes nothing returns boolean
*           -   Runs before onDestructable.
*           -   May create a better filter for enumerated destructables.
*           -   Only method which has no impact on the Missile instance.
*
*
*       static method onDestructable takes Missile missile, destructable hit returns boolean
*           -   Runs every time the missile collides with a destructable.
*           -   Can use onDestructableFilter ( optional ) 
*           -   Runs after onDestructableFilter ( if filter is declared )
*
*
*   module MissileStruct
*
*       static method launch takes Missile toLaunch returns nothing
*           -   Well ... launches a Missile.
*           -   Example: call Fireball.launch( toLaunch ) 
*             
************************************************************************************************/

// Hello and welcome to Missile.
// I wrote a guideline for every piece of code inside Missile, so you 
// can easily understand how the code gets compiled and evaluated.
//
// Let's go!
       
    // If you set WRITE_DELAYED_MISSILE_RECYCLING from the configs to true, the compiler will write
    // a recycler bin, doing delayed dummy unit recycling, into Missle. 
    // If set to false, no code is created here as the code is ignored via "static if".
    //
    // The code of the macro is located at the bottom of Missile, as it would hurt read-ability if placed here.
    //! runtextmacro WRITE_MISSILE_RECYCLE_BIN("WRITE_DELAYED_MISSILE_RECYCLING", "DELAYED_MISSILE_DEATH_ANIMATION_TIME")
    
    public function GetLocZ takes real x, real y returns real
        call MoveLocation(MissilePosition.loc, x, y)
        return GetLocationZ(MissilePosition.loc)
    endfunction
    
    // This macro boxes a missiles positions and does the required trigonometry.
    //
    // The code of the macro is located at the bottom of Missile, as it would hurt read-ability if placed here.
    //! runtextmacro WRITE_MISSILE_POSITION_CODE()
    
    // keywords are replaced directives for a scope.
    // Missiles structure works like a list with the folling methods:
    // allocateCollection(), allocateNode(), insertEnd(node) and remove()
    //
    // MissileStructure is implemented as a module
    // The code is located at the bottom of Missile, as it would also hurt read-ability if placed here.
    private keyword MissileStructure
    struct Missile extends array
        implement MissileStructure
        
        // I included enormous debug safety to Missile, 
        // in order to eradicate wrong user usage.
        // You should do this with every system you write. 
        //
        // Set MORE_SAFETY to false, once major mistakes are
        // purged from your code. It will create a more realistic
        // performance to a non DEBUG_MODE code, because many
        // error checks are then excluded via "static if".
        // 
        // Placed here on purpose, to ensure that less experienced users
        // recieve the full range of debug features. Basically they will
        // never find this constant boolean :)!
        debug static constant boolean MORE_SAFETY = false
        
        // launched prevents double launching! Very logical. DEBUG_MODE only.
        debug boolean launched 
        
        // Effect attach point name. Read-only for shared usage in your map.
        // Of course only if you read until here :)!
        readonly static constant string ORIGIN = "origin"
        
        // Defines a default unit hit box in range of 0 to 1,
        // while 0 is the toe and 1 the head of a unit.
        readonly static constant real HIT_BOX  = (2./3.)
        
        // Please do not use this group from somewhere else,
        // as it may conflict with Missiles code execution.
        // Rather go with bj_lastCreatedGroup.
        readonly static group enumGroup        = CreateGroup()
        
        // Prevents a double free case.
        readonly boolean allocated
        
        // Useful struct members. Names chosen to be self-explaining.
        private effect sfx
        private string path
        
        private real missileScale
        
        readonly real angle// current angle
        
        // For curved missiles the position of a missile is not
        // equal to the x/y required by Missiles trigonometry.
        // Therefore we need this member two times.
        // x/y/z for your needs and xPrivate/yPrivate for cool mathematics.
        private real xPrivate
        private real yPrivate
        
        readonly MissilePosition origin
        readonly MissilePosition impact
        readonly real  terrainZ
        readonly real  x
        readonly real  y
        readonly real  z
        readonly unit  dummy
        readonly group unitsHit

        // wantDestroy deallocates an instance on the next
        // timer callback. 100% safe to use.
        boolean wantDestroy
        
        // recycle is set to true, when a missile reached
        // it's destination. Then it may be destroyed.
        boolean recycle
        
        // distance traveled.
        real    distance
        
        // Members for your needs.
        // No operator overloading, expect in a few cases.
        unit    target
        unit    source
        
        // As the dummy always belongs to the neutral player.
        // You can add a pseudo owner for faster onCollide evaluation.
        // No monitoring or nulling included. Use carefully.
        player owner 

// I really don't know how wc3 works with negative collision values. (bug free???)
// So I decided to monitor collision and eventually collisionZ.

static if DEBUG_MODE and LIBRARY_ErrorMessage and Missile.MORE_SAFETY then

        // operators allow us to check for invalid arguments like value < 0
        debug private real collisionDebug
        method operator collision= takes real value returns nothing
            debug call ThrowError((value < 0), "Missile", "collision=", "collision", this, "Found Collision Below Zero [" + R2S(value) + "]!")
            debug set collisionDebug = value
        endmethod
        method operator collision takes nothing returns real
            debug return collisionDebug
        endmethod
        
        // Same applies for collisionZ
        static if Missile_USE_COLLISION_Z_FILTER then
            debug private real collisionZDebug
            method operator collisionZ= takes real value returns nothing
                debug call ThrowError((value < 0), "Missile", "collisionZ=", "collisionZ", this, "Found CollisionZ Below Zero [" + R2S(value) + "]!")
                debug set collisionZDebug = value
            endmethod
            method operator collisionZ takes nothing returns real
                debug return collisionZDebug
            endmethod        
        endif
else

// Without debug mode we give a shit on monitoring!

        real    collision
    static if Missile_USE_COLLISION_Z_FILTER then
        real    collisionZ
    endif
endif

// Speed determines the lenght of our vector for Missile movement.
// Non positive values and zero are invalid. So let's monitor again.

static if DEBUG_MODE and LIBRARY_ErrorMessage then
        debug private real speedDebug
        method operator speed= takes real value returns nothing
            debug call ThrowError((value <= 0), "Missile", "speed=", "speed", this, "Speed Values Below Or Equal To Zero Are Not Allowed [" + R2S(value) + "]!")
            set speedDebug = value
        endmethod
        method operator speed takes nothing returns real
            return speedDebug
        endmethod
else
        real    speed
endif

        real    height
        real    turn
        real    open
        real    damage
        real    acceleration
        
        // You can attach any data to a missile.
        integer data
        
        // Dummy is readonly so you can add more than one model.
        method operator model= takes string modelFile returns nothing
            if (sfx != null) then
                call DestroyEffect(sfx)
            endif
            set path = modelFile
            set sfx  = AddSpecialEffectTarget(modelFile, dummy, Missile.ORIGIN)
        endmethod
        method operator model takes nothing returns string
            return path
        endmethod
       
        // Simple trigonometry, some values will freak out the missile movement.
        method operator curve= takes real value returns nothing
            set open = Tan(value)*origin.distance
        endmethod
        method operator curve takes nothing returns real
            if (origin.distance == 0) then
                return 0.// It's a limit of sequence and crashes the thread. Intuitively  chosen 0.
            endif
            return Atan(open/origin.distance)
        endmethod
       
        // Simple trigonometry, some values will freak out the missile movement.
        method operator arc= takes real value returns nothing
            set height = Tan(value)*origin.distance/4
        endmethod
        method operator arc takes nothing returns real
            if (origin.distance == 0) then
                return 0.// It's a limit of sequence and crashes the thread. Intuitively  chosen 0.
            endif
            return Atan(4*height/origin.distance)
        endmethod
       
        method operator scale= takes real value returns nothing
            call SetUnitScale(dummy, value, 1., 1.)
            set missileScale = value
        endmethod
        method operator scale takes nothing returns real
            return missileScale
        endmethod
    
        method bounce takes nothing returns nothing
            call origin.move(xPrivate, yPrivate, z)
            set distance = 0
        endmethod
       
        method deflect takes real tx, real ty returns nothing
            local real a = 2*Atan2(ty - yPrivate, tx - xPrivate) + bj_PI - angle
            call impact.move(xPrivate + (origin.distance - distance)*Cos(a), yPrivate + (origin.distance - distance)*Sin(a), impact.z)
            call bounce()
        endmethod
        
        method deflectEx takes real tx, real ty, real tz returns nothing
            call impact.move(impact.x, impact.y, tz)
            call deflect(tx, ty)
        endmethod
    
        method flightTime2Speed takes real duration returns nothing
            set speed = RMaxBJ(0.00000001, (origin.distance - distance)*Missile_TIMER_TIMEOUT/duration)
        endmethod
    
        // I would expect more from a destroy method :)!
        method destroy takes nothing returns nothing
            set wantDestroy = true
        endmethod
    
        // As user you shouldn't have access to .remove(), so you can use .terminate() instead.
        method terminate takes nothing returns nothing
            set allocated   = false
            call DestroyEffect(sfx)
            
            static if LIBARARY_GroupUtils then
                call ReleaseGroup(unitsHit)
            else
                call DestroyGroup(unitsHit)
            endif
           
            if (GetUnitTypeId(dummy) == Missile_DUMMY_UNIT_ID) then
                static if LIBRARY_MissileRecycler then
                    call RecycleMissile(dummy)
                
                elseif Dummy.create.exists and LIBRARY_Dummy then
                    call Dummy[dummy].destroy()
                    
                elseif LIBRARY_xedummy and xedummy.release.exists then
                    call xedummy.release(dummy)
                    
                else
                    call RemoveUnit(dummy)
                endif
            endif
           
            set recycle  = false
            set sfx      = null
            set unitsHit = null
            set source   = null
            set target   = null
            set dummy    = null
           
            call impact.destroy()
            call origin.destroy()
           
            call remove()
        endmethod
    
        // Freaky static if ensures these libraries really don't exist.
        static if not LIBRARY_MissileRecycler and not LIBRARY_Dummy and not Dummy.create.exists and not LIBRARY_xe_dummy and not xe_dummy.new.exists then
            private static method newMissileUnit takes real x, real y, real face returns unit
                // Just in case you have UnitIndexer.
                static if LIBRARY_UnitIndexer then
                    set UnitIndexer.enabled = false
                endif
                set bj_lastCreatedUnit = CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID , x, y, face)
                call SetUnitX(bj_lastCreatedUnit, x)
                call SetUnitY(bj_lastCreatedUnit, y)
                call PauseUnit(bj_lastCreatedUnit, true)
                static if LIBRARY_UnitIndexer then
                    set UnitIndexer.enabled = true
                endif
                return bj_lastCreatedUnit
            endmethod
        endif
    
        static method create takes real originX, real originY, real originZ, real angleP, real distanceP, real impactZ returns thistype
            local thistype this = thistype.allocateNode()
            set origin          = MissilePosition.create(originX, originY, originZ)
            set impact          = MissilePosition.create(originX + distanceP*Cos(angleP), originY + distanceP*Sin(angleP), impactZ)
            call MissilePosition.link(origin, impact)
            
            set collision       = 0
            static if Missile_USE_COLLISION_Z_FILTER then
                set collisionZ  = 0
            endif
            
            set acceleration    = 0
            set height          = 0
            set turn            = 0
            set open            = 0
            
            set recycle         = false
            set wantDestroy     = false
            set path            = ""
            
            set xPrivate        = originX
            set yPrivate        = originY
            set z               = origin.z
            set angle           = angleP
            set distance        = 0
            
            static if LIBRARY_MissileRecycler then
                set dummy = GetRecycledMissile(originX, originY, originZ, angleP*bj_RADTODEG)

            elseif LIBRARY_Dummy and Dummy.create.exists then
                set dummy = Dummy.create(originX, originY, angleP*bj_RADTODEG).unit

            elseif LIBRARY_xedummy and xedummy.new.exists then
                set dummy = xedummy.new(Missile_NEUTRAL_PASSIVE, originX, originY, angleP*bj_RADTODEG)
            
            else
                set dummy = Missile.newMissileUnit(originX, originY, angleP*bj_RADTODEG)
            endif

            set allocated       = true
            
            static if LIBRARY_GroupUtils then
                set unitsHit    = NewGroup()
            else
                set unitsHit    = CreateGroup()
            endif
            
            call MoveLocation(MissilePosition.loc, originX, originY)
            call SetUnitFlyHeight(dummy, origin.z - GetLocationZ(MissilePosition.loc), 0.)   
            
            debug set launched = false
            return this
        endmethod
    
        // Currently a private method. In future updates it will be public again and similiar
        // to create(), but you can pass in any existing unit, instead poping a dummy unit from the stack.
         static method createEx takes unit missileDummy, real impactX, real impactY, real impactZ returns thistype
            local thistype this = thistype.allocateNode()
            local real originX  = GetUnitX(missileDummy)
            local real originY  = GetUnitY(missileDummy)
            local real originZ  = GetUnitFlyHeight(missileDummy)
            set origin          = MissilePosition.create(originX, originY, originZ)
            set impact          = MissilePosition.create(impactX, impactY, impactZ)
            
            call MissilePosition.link(origin, impact)
            static if DEBUG_MODE and LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
                debug call ThrowError((GetUnitTypeId(missileDummy) == 0), "Missile", "createEx", "missileDummy", this, "Invalid Missile Dummy Unit (null)!")
            endif

            set collision       = 0
            static if Missile_USE_COLLISION_Z_FILTER then
                set collisionZ  = 0
            endif
            
            set acceleration    = 0
            set height          = 0
            set turn            = 0
            set open            = 0
            
            set recycle         = false
            set wantDestroy     = false
            set path            = ""
            
            set xPrivate        = originX
            set yPrivate        = originY
            set z               = originZ
            set angle           = origin.angle
            set distance        = 0
            set dummy           = missileDummy
            set allocated       = true
            
            static if LIBRARY_GroupUtils then
                set unitsHit    = NewGroup()
            else
                set unitsHit    = CreateGroup()
            endif
            
            call MoveLocation(MissilePosition.loc, originX, originY)
            call SetUnitFlyHeight(missileDummy, origin.z - GetLocationZ(MissilePosition.loc), 0.)   
            
            debug set launched = false
            return this
        endmethod
        
        // This one is new. I think it is useful.
        static method createXYZ takes real x, real y, real z, real impactX, real impactY, real impactZ returns thistype
            local real angleP   = Atan2(impactY - y, impactX - x)
            local real distance = SquareRoot((x - impactX)*(x - impactX) + (y - impactY)*(y - impactY))
            return thistype.create(x, y, z, angleP, distance, impactZ)
        endmethod
    
        // Periodic loop every 1/32 seconds. Runs once per active missile struct.
        method move takes nothing returns nothing
            local MissilePosition loc
            local real a 
            local real d
            local real s
            local unit u
            
            local real h    
            local real tx
            local real ty 
            local real index
            
            loop
                exitwhen (this == 0)
                set loc = origin
                set u   = target
                set h   = height
                
                // Missile target.
                if (u != null) then
                    if (0 != GetUnitTypeId(u)) then
                        set tx       = GetUnitX(u)
                        set ty       = GetUnitY(u)
                        set a        = Atan2(ty - yPrivate, tx - xPrivate)
                        // Does not hit the toe, but hits the chest.
                        // Why so? Because of HIT_BOX and GetUnitBodySize(u)
                        call impact.move(tx, ty, GetUnitFlyHeight(u) + GetUnitBodySize(u)*Missile.HIT_BOX)
                        set distance = loc.distance - SquareRoot((tx - xPrivate)*(tx - xPrivate) + (ty - yPrivate)*(ty - yPrivate))
                    else
                        set target   = null
                    endif
                else
                    set a      = loc.angle
                endif
            
                // Missile turn
                if (0 != turn) and (Cos(angle - a) < Cos(turn)) then
                    if (Sin(a - angle) >= 0) then
                        set angle = angle + turn
                    else
                        set angle = angle - turn
                    endif
                else
                    set angle = a
                endif
                
                set d        = loc.distance
                set s        = distance + speed
                set distance = s
               
                set u        = dummy
               
                set tx       = xPrivate + speed*Cos(angle)
                set ty       = yPrivate + speed*Sin(angle)
                set speed    = speed    + acceleration
                set xPrivate = tx
                set yPrivate = ty
            
                // Missile curve
                if (open != 0) then
                    set a  = 4*open*s*(d - s)/(d*d)
                    set tx = tx + a*Cos(angle + 1.57)
                    set ty = ty + a*Sin(angle + 1.57)
                    call SetUnitFacing(u, (angle + Atan(-((4*open)*(2*s - d))/(d*d)))*bj_RADTODEG)
                else
                    call SetUnitFacing(u, angle*bj_RADTODEG)
                endif
                
                // Missile x/y
                set x     = tx
                set y     = ty
                
                static if not LIBRARY_BoundSentinel and LIBRARY_WorldBounds then
                    if (tx>WorldBounds.maxX) or (tx<WorldBounds.minX) or (ty>WorldBounds.maxY) or (ty<WorldBounds.minY) then
                        set wantDestroy = true
                    else
                        call SetUnitX(u, tx)
                        call SetUnitY(u, ty)
                    endif
                else
                    call SetUnitX(u, tx)
                    call SetUnitY(u, ty)
                endif

                // Missile z
                call MoveLocation(MissilePosition.loc, tx, ty)
                set terrainZ  = GetLocationZ(MissilePosition.loc)
                if (h != 0) or (loc.slope != 0) then
                    set z     =  loc.z - terrainZ + loc.slope*s 
                    set index = loc.alpha
                    if (h != 0) then
                        set z     = z + (4*h*s*(d - s)/(d*d))
                        set index = index - Atan(((4*h)*(2*s - d))/(d*d))*bj_RADTODEG
                    endif
                    call SetUnitAnimationByIndex(u, R2I(index + 90.5))
                else
                    set z = loc.z - terrainZ
                endif
                call SetUnitFlyHeight(u, z, 0)
               
                if (s >= d) then
                    set recycle = true
                endif
               
                set this = next
            endloop
            set u = null
        endmethod
        
// Optional code stays optional.
static if Missile_USE_DESTRUCTABLE_FILTER then

        readonly static rect enumRect   = Rect(0., 0., 0., 0.)                    
        static Missile temp             = 0
        static real tempDist            = 0
        // After several test it turned out, that the square used in EnumDestructablesInRect leaves out
        // destructables which are within an appropriate range of the projectile.
        // Sadly there is no IsDestructableInRange native!!!
        static method actionFuncDest takes nothing returns nothing
            local destructable d = GetEnumDestructable()
            local real xd        = GetDestructableX(d)
            local real yd        = GetDestructableY(d)
            local real dist      = (temp.x - xd)*(temp.x - xd) + (temp.y - yd)*(temp.y - yd)
            static if Missile_USE_COLLISION_Z_FILTER then
                local real collideZ  = Missile_GetLocZ(xd, yd) - temp.terrainZ 
                if (dist <= bj_enumDestructableRadius) and (collideZ + GetDestructableHeight(d) >= temp.z - temp.collisionZ) and (collideZ <= temp.z + temp.collisionZ) then
                    if (dist < Missile.tempDist) then
                        set Missile.tempDist         = dist
                        set bj_destRandomCurrentPick = d
                    endif
                endif
            else
                if (dist <= bj_enumDestructableRadius) then
                    if (dist < Missile.tempDist) then
                        set Missile.tempDist         = dist
                        set bj_destRandomCurrentPick = d
                    endif
                endif                    
            endif
            set d = null
        endmethod
endif

static if Missile_WRITE_DELAYED_MISSILE_RECYCLING then
    method nullBefore takes nothing returns nothing
        set dummy = null
    endmethod
endif

// Does not check for 'Aloc' and 'Amrf' as they could be customized.
static if Missile.MORE_SAFETY and DEBUG_MODE and LIBRARY_ErrorMessage then
    private static method onInit takes nothing returns nothing
        static if LIBRARY_UnitIndexer then
            debug set UnitIndexer.enabled = false
        endif
        debug set bj_lastCreatedUnit      = CreateUnit(Missile_NEUTRAL_PASSIVE, Missile_DUMMY_UNIT_ID, 0, 0, 0)
        debug call ThrowError((GetUnitTypeId(bj_lastCreatedUnit) != Missile_DUMMY_UNIT_ID), "Missile", "DEBUG_MISSILE", "typeid",    0, "Missile Setup For DUMMY_UNIT_ID Is Incorrect! Map Can't Use Missile!")
        debug call ThrowError((Missile_MAXIMUM_COLLISION_SIZE < 0),                         "Missile", "DEBUG_MISSILE", "collision", 0, "Missile Setup For MAXIMUM_COLLISION_SIZE Is Incorrect, Below Zero! Map Can't Use Missile!")
        debug call RemoveUnit(bj_lastCreatedUnit)
        debug set bj_lastCreatedUnit      = null
        static if LIBRARY_UnitIndexer then
            debug set UnitIndexer.enabled = true
        endif
    endmethod
endif

    endstruct
    // You made it to the end of Missile, but we are not finished.
    // Do you remember about the data structure, the delayed recycler
    // and of course our interface module "MissileStruct"
    //
    // This comes now!
    
    
    // Debug code taken from List (credits to Nestharus)
    private module MissileStructure
        private static thistype collectionCount = 0
        private static thistype nodeCount       = 0
        
        static if LIBRARY_ErrorMessage then
            debug private boolean isNode
            debug private boolean isCollection
        endif
        
        private thistype _list
        method operator list takes nothing returns thistype
            static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
                debug call ThrowError(this == 0,    "MissileStructure", "list", "thistype", this, "Attempted To Read Null Node.")
                debug call ThrowError(not isNode,   "MissileStructure", "list", "thistype", this, "Attempted To Read Invalid Node.")
            endif
            return _list
        endmethod
        
        private thistype _next
        method operator next takes nothing returns thistype
            static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
                debug call ThrowError(this == 0,    "MissileStructure", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
                debug call ThrowError(not isNode,   "MissileStructure", "next", "thistype", this, "Attempted To Read Invalid Node.")
            endif
            return _next
        endmethod
        
        private thistype _prev
        method operator prev takes nothing returns thistype
            static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
                debug call ThrowError(this == 0,    "MissileStructure", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
                debug call ThrowError(not isNode,   "MissileStructure", "prev", "thistype", this, "Attempted To Read Invalid Node.")
            endif
            return _prev
        endmethod
        
        private thistype _first
        method operator first takes nothing returns thistype
            static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
                debug call ThrowError(this == 0,        "MissileStructure", "first", "thistype", this, "Attempted To Read Null List.")
                debug call ThrowError(not isCollection, "MissileStructure", "first", "thistype", this, "Attempted To Read Invalid List.")
            endif
            return _first
        endmethod
        
        private thistype _last
        method operator last takes nothing returns thistype
            static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
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
            
            static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
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
            
            static if LIBRARY_ErrorMessage and Missile.MORE_SAFETY then
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
    
    // Can private as the MissileStruct module is written here.
    globals
        private trigger core   = CreateTrigger()
        private timer clock    = CreateTimer()
        private integer active = 0
        
        private integer             array   instances
        private Missile             array   missileStack
        private boolexpr            array   expression
        private triggercondition    array   condition
    endglobals
    
    private function Fire takes nothing returns nothing
        call TriggerEvaluate(core)
    endfunction
    
    private function MissileCreateExpression takes integer structId, code func returns nothing
        set expression[structId] = Condition(func)
    endfunction
    
    // Start timer if not already running.
    private function StartPeriodic takes integer structId returns nothing
        if (instances[structId] == 0) then
            set condition[structId] = TriggerAddCondition(core, expression[structId])
            if (active == 0) then
                call TimerStart(clock, Missile_TIMER_TIMEOUT, true, function Fire)
            endif
            set active    = active + 1
        endif
        set instances[structId] = instances[structId] + 1
    endfunction
    
    // And stops it.
    private function StopPeriodic takes integer structId returns nothing
        set instances[structId] = instances[structId] - 1
        if (instances[structId] == 0) then
            set active = active - 1
            if (active == 0) then
                call PauseTimer(clock)
            endif
            call TriggerRemoveCondition(core, condition[structId])
            set condition[structId] = null
        endif
    endfunction
    
    // Now the popular MissileStruct.
    // How is it working? Let's see!
    //
    // P in the end of all methods hopefully prevents
    // any conflicting code.
    module MissileStruct
        
// Why not run some debug checks first.
static if DEBUG_MODE then

        static if not Missile_USE_DESTRUCTABLE_FILTER and thistype.onDestructable.exists then
            Error Message from library Missile in struct thistype !
            thistype.onDestructable is a reserved name for Missile, once you implemented MissileStruct.
            Either you forgot to set USE_DESTRUCTABLE_FILTER = true in library Missile or re-name that method. 
        endif
        
        static if not Missile_USE_DESTRUCTABLE_FILTER and thistype.onDestructableFilter.exists then
            Error Message from library Missile in struct thistype !
            thistype.onDestructableFilter is a reserved name for Missile, once you implemented MissileStruct.
            Either you forget to set USE_DESTRUCTABLE_FILTER = true in library Missile or re-name that method. 
        endif

        static if Missile_USE_DESTRUCTABLE_FILTER and thistype.onDestructableFilter.exists and not thistype.onDestructable.exists then
            Error Message from library Missile in struct thistype !
            thistype.onDestructableFilter only be used, when thistype.onDestructable is also declared.
        endif
        
        static if thistype.onMissile.exists then
            Error Message from library Missile in struct thistype !
            thistype.onMissile is a reserved name for Missile, once you implemented MissileStruct.
            thistype.onMissile is currently not supported by library Missile. 
            Please delete or re-name that method.
        endif
endif
        
        static if Missile_USE_DESTRUCTABLE_FILTER and thistype.onDestructableFilter.exists then
            // Stupid name chosen, to be unique in that struct ... hopefully.
            private static boolexpr destConditionP = null
        endif
        
        // Stupid name ensures not to be called accidently.
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
    
        // Returns boolean to be compile-able with Cohadars JassHelper.
        private static method missileIterateP takes nothing returns boolean
            local Missile this = missileStack[.typeid].first 
            local Missile node
            local real collideZ
            local unit u
            
            // Move the whole stack.
            call this.move()
            loop
                exitwhen this == 0
                set node      = this.next
               
                if (this.wantDestroy) then
                    static if thistype.onFinish.exists then
                        if thistype.onFinish(this) then
                            call thistype.missileTerminateP(this)
                        endif
                    else
                        call thistype.missileTerminateP(this)
                    endif
                else
                
                    static if thistype.onCollide.exists then
                        if (0 != this.collision) then
                            call GroupEnumUnitsInRange(Missile.enumGroup, this.x, this.y, this.collision + Missile_MAXIMUM_COLLISION_SIZE, null)
                            loop
                                set u = FirstOfGroup(Missile.enumGroup)
                                exitwhen u == null
                                call GroupRemoveUnit(Missile.enumGroup, u)
                                if (u != this.target) and IsUnitInRange(u, this.dummy, this.collision) then  
                                    
                                    static if Missile_USE_COLLISION_Z_FILTER then
                                        set collideZ = Missile_GetLocZ(GetUnitX(u), GetUnitY(u)) + GetUnitFlyHeight(u) - this.terrainZ
                                        if (collideZ + GetUnitBodySize(u) >= this.z - this.collisionZ) and (collideZ <= this.z + this.collisionZ) then
                                            if not (IsUnitInGroup(u, this.unitsHit)) then
                                                if thistype.onCollide(this, u) then
                                                    call thistype.missileTerminateP(this)
                                                    exitwhen true
                                                endif
                                    
                                                call GroupAddUnit(this.unitsHit, u)
                                            endif
                                        endif
                                    
                                    else
                                    
                                        if not (IsUnitInGroup(u, this.unitsHit)) then
                                            if thistype.onCollide(this, u) then
                                                call thistype.missileTerminateP(this)
                                                exitwhen true
                                            endif
                                    
                                            call GroupAddUnit(this.unitsHit, u)
                                        endif                                    
                                    
                                    endif
                                endif
                            endloop
                        endif
                    endif
                        
                    static if thistype.onDestructable.exists then
                        // Check if the missile is not terminated.
                        if (this.allocated) and (0 != this.collision) then
                            set bj_enumDestructableRadius = this.collision + Missile_MAXIMUM_COLLISION_SIZE
                            set bj_destRandomCurrentPick  = null
                            call SetRect(Missile.enumRect, this.x - bj_enumDestructableRadius, this.y - bj_enumDestructableRadius, this.x + bj_enumDestructableRadius, this.y + bj_enumDestructableRadius)
                            set bj_enumDestructableRadius = this.collision*this.collision
                            set Missile.temp              = this
                            set Missile.tempDist          = bj_enumDestructableRadius + 1
                            static if thistype.onDestructableFilter.exists then
                                call EnumDestructablesInRect(Missile.enumRect, thistype.destConditionP, function Missile.actionFuncDest)
                            else
                                call EnumDestructablesInRect(Missile.enumRect, null, function Missile.actionFuncDest)
                            endif
                            if (bj_destRandomCurrentPick != null) and thistype.onDestructable(this, bj_destRandomCurrentPick) then
                                call missileTerminateP(this)
                            endif
                        endif
                    endif
                
                    if (this.recycle) and (this.allocated) then
                        static if thistype.onCollide.exists then
                            static if thistype.onFinish.exists then
                                if (this.target == null) then
                                    if thistype.onFinish(this) then
                                        call thistype.missileTerminateP(this)
                                    else
                                        set this.recycle = false
                                    endif
                                    
                                elseif thistype.onCollide(this, this.target) then
                                    call thistype.missileTerminateP(this)
                                else
                                    set this.recycle = false
                                endif
                            else
                                if (this.target == null) then
                                    call thistype.missileTerminateP(this)
                                elseif thistype.onCollide(this, this.target) then
                                    call thistype.missileTerminateP(this)
                                else
                                    set this.recycle = false
                                endif
                            endif
                        else
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
                    endif
                
                    static if thistype.onTerrain.exists then
                        if (this.allocated) and (this.z < 0) and thistype.onTerrain(this) then
                            static if thistype.onFinish.exists then
                                if thistype.onFinish(this) then
                                    call missileTerminateP(this)
                                endif
                            else
                                call missileTerminateP(this)
                            endif
                        endif
                    endif
                
                    // Runs last
                    static if thistype.onPeriod.exists then
                        if (this.allocated) and thistype.onPeriod(this) then
                            static if thistype.onFinish.exists then
                                if thistype.onFinish(this) then
                                    call missileTerminateP(this)
                                endif
                            else
                                call missileTerminateP(this)
                            endif 
                        endif
                    endif
                endif
                set this = node
            endloop
           
            set u = null
            return false
        endmethod
    
        static method launch takes Missile missile returns nothing
            static if LIBRARY_ErrorMessage then
                debug call ThrowError(missile.launched, "thistype", "launch", "missile.launched", missile, "Missile Was Already Launched Before!")
            endif
        
            call missileStack[thistype.typeid].insertEnd(missile)
            call StartPeriodic(thistype.typeid)
            debug set missile.launched = true
        endmethod
    
        private static method onInit takes nothing returns nothing
            set missileStack[thistype.typeid] = Missile.allocateCollection()
            call MissileCreateExpression(thistype.typeid, function thistype.missileIterateP)
            static if thistype.onDestructableFilter.exists then
                set thistype.destConditionP  = Condition(function thistype.onDestructableFilter)
            endif
        endmethod
    
    endmodule
    
    //! textmacro WRITE_MISSILE_POSITION_CODE 
        struct MissilePosition extends array
            private static integer array recycler
            private static integer alloc = 0
            readonly static location loc = Location(0., 0.)
            readonly real x
            readonly real y
            readonly real z
            readonly real angle
            readonly real distance
            readonly real slope
            readonly real alpha
            
            private thistype ref
            
            
            private static method math takes thistype a, thistype b returns boolean
                set a.angle     = Atan2(b.y - a.y, b.x - a.x)
                set a.distance  = SquareRoot((b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y))
                if (a.distance != 0) then
                    set a.slope = (b.z - a.z)/a.distance
                else// Error! I decide we do this math again!
                    set a.x     = a.x + .0001
                    return false
                endif
                set a.alpha     = Atan(a.slope)*bj_RADTODEG
                
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
                call MoveLocation(MissilePosition.loc, toX, toY)
                set x = toX
                set y = toY
                set z = toZ + GetLocationZ(MissilePosition.loc)
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
                set ref       = this
                call move(x, y, z)
                return this
            endmethod
    
        endstruct
    //! endtextmacro 
    
    //! textmacro WRITE_MISSILE_RECYCLE_BIN takes DO_THIS, AFTER_TIME 
    static if $DO_THIS$ then
        // In order to play a proper death animation,
        // RecycleBin to recycles missiles after 
        // DEFAULT_DEATH_ANIMATION_TIME
        private struct RecycleBin extends array
            private static timer t                  = CreateTimer()
            private static integer alloc            = 0
            private static unit array dummy
            private static real array time
     
            private static method handlerFunc takes nothing returns nothing
                local integer index = 0
                loop
                    exitwhen index == thistype.alloc
                    set thistype.time[index] = thistype.time[index] - 1
                    if (0 >= thistype.time[index]) then
                    
                        static if LIBRARY_MissileRecycler then
                            call RecycleMissile(thistype.dummy[index])
                    
                        elseif Dummy.create.exists and LIBRARY_Dummy then
                            call Dummy[thistype.dummy[index]].destroy()
                        
                        elseif LIBRARY_xedummy and xedummy.release.exists then
                            call xedummy.release(thistype.dummy[index])
                    
                        else
                            call RemoveUnit(thistype.dummy[index])
                        endif
                    
                        set thistype.dummy[index]          = null
                        set thistype.alloc                 = thistype.alloc - 1
                        set thistype.dummy[index]          = thistype.dummy[thistype.alloc]
                        set thistype.time[index]           = thistype.time[thistype.alloc]
                        set thistype.dummy[thistype.alloc] = null
                        set index                          = index - 1
                    
                        if (0 == thistype.alloc) then
                            call PauseTimer(thistype.t)
                        endif
                    
                    endif
                    set index = index + 1
                endloop
            endmethod
    
            static method recycle takes unit toRecycle returns nothing
                if (0 == thistype.alloc) then
                    call TimerStart(thistype.t, 1., true, function thistype.handlerFunc)
                endif
                set thistype.dummy[alloc] = toRecycle
                set thistype.time[alloc]  = $AFTER_TIME$     + TimerGetRemaining(thistype.t)
                set thistype.alloc        = thistype.alloc   + 1
            endmethod
    
        endstruct
    endif
    //! endtextmacro
    
// The end!
endlibrary