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
        // Candidate padding for unit sizes and measured Classic widget-enumeration
        // omissions. Visitors retain the original logical collision geometry.
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
                    exitwhen u == null or not allocated
                        if not HaveSavedBoolean(table, this, GetHandleId(u)) then
                            if IsUnitInRangeXY(u, x, y, collision) then
                                if collideZ then
                                    set dx = GetLocZ(GetUnitX(u), GetUnitY(u)) + GetUnitFlyHeight(u)
                                    set dy = GetUnitCollisionSize(u)
                                    if dx + dy >= z - collision and dx <= z + collision then
                                        call SaveBoolean(table, this, GetHandleId(u), true)
                                        set stop = .onHit(u)
                                        if allocated and stop then
                                            call terminate()
                                        endif
                                        exitwhen not allocated
                                    endif
                                else
                                    call SaveBoolean(table, this, GetHandleId(u), true)
                                    set stop = .onHit(u)
                                    if allocated and stop then
                                        call terminate()
                                    endif
                                    exitwhen not allocated
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
                    exitwhen k > count or not allocated
                        set missile = collection[k]
                        if missile != this and missile.allocated then
                            if LoadInteger(missileHits, this, missile) != missile.generation then
                                set dx = missile.x - x
                                set dy = missile.y - y
                                if SquareRoot(dx*dx + dy*dy) <= collision then
                                    call SaveInteger(missileHits, this, missile, missile.generation)
                                    set stop = .onMissile(missile)
                                    if allocated and stop then
                                        call terminate()
                                    endif
                                    exitwhen not allocated
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
                set dx = collision + COLLISION_SIZE
                call SetRect(rect, x - dx, y - dx, x + dx, y + dx)
                call EnumDestructablesInRect(rect, null, function thistype.onDest)
            endif
        endif
    endmodule
  
    private module OnItem
        if .onItem.exists then
            if allocated and collision > 0 then
                set dx = collision + COLLISION_SIZE
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
                set stop = .onCliff()
                if allocated and stop then
                    call terminate()
                endif
            endif
        endif
    endmodule
    
    private module OnTerrain
        if .onTerrain.exists then
            if GetLocZ(x, y) > z then
                set stop = .onTerrain()
                if allocated and stop then
                    call terminate()
                endif
            endif
        endif
    endmodule
    
    private module OnTileset
        if .onTileset.exists then
            set k = GetTerrainType(x, y)
            if k != tileset then
                set stop = .onTileset(k)
                if allocated and stop then
                    call terminate()
                endif
            endif
            if allocated then
                set tileset = k
            endif
        endif
    endmodule
    
    private module OnPeriod
        if .onPeriod.exists then
            set stop = .onPeriod()
            if allocated and stop then
                call terminate()
            endif
        endif
    endmodule
    
    private module OnOrient
        // Refresh after callbacks: onPeriod may have moved the target.
        set u = target
        if u != null and GetUnitTypeId(u) != 0 then
            call impact.move(GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u) + toZ)
            set dx = impact.x - baseX
            set dy = impact.y - baseY
            set a = Atan2(dy, dx)
            set progress = origin.distance - SquareRoot(dx*dx + dy*dy)
        else
            set a = origin.angle
            set target = null
        endif
        set o = origin
        set d = o.distance
        set h = height
        set c = open
        if turn != 0 and not (Cos(cA-a) >= Cos(turn)) then
            if Sin(a-cA) >= 0 then
                set cA = cA + turn
            else
                set cA = cA - turn
            endif
        else
            set cA = a
        endif

        // Promote one complete XYZ sample, then predict the next one.
        call predict()
        set prevX = x
        set prevY = y
        set prevZ = z
        set x = nextX
        set y = nextY
        set z = nextZ
        set baseX = nextBaseX
        set baseY = nextBaseY
        set progress = nextProgress
        set s = progress
        set veloc = veloc + acceleration
        call predict()
        // Historical public travel convention: next progress during flight.
        set travel = nextProgress
        set pitch = o.alpha - Atan(4*h*(2*s-d)/(d*d))*bj_RADTODEG
        set yaw = (cA + Atan(-4*c*(2*s-d)/(d*d)))*bj_RADTODEG
        call refreshVision()
    endmodule

    private module OnFinish
        if s >= d then
            set finished = true
            if .onFinish.exists then
                set stop = .onFinish()
                if allocated then
                    if stop then
                        call terminate()
                    elseif travel > 0 and not paused then
                        call terminate()
                    endif
                endif
            else
                call terminate()
            endif
        endif

        if allocated then
            call SetUnitAnimationByIndex(dummy, R2I(pitch + 90.5))
            call SetUnitFacing(dummy, yaw)
        endif
    endmodule
    
    private module OnBoundaries
        if not (x > WorldBounds.maxX or x < WorldBounds.minX or y > WorldBounds.maxY or y < WorldBounds.minY) then
            call SetUnitX(dummy, x)
            call SetUnitY(dummy, y)
            call SetUnitZ(dummy, z)
        else
            if .onBoundaries.exists then
                set stop = .onBoundaries()
                if allocated and stop then
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
            set stop = .onPause()
            if allocated and stop then
                call terminate()
            endif
        endif
    endmodule
    
    private module OnResume
        local thistype aux
        local boolean stop

        if not allocated then
            return
        endif
        set paused = flag
        if not paused and pkey != -1 then
            // Keep this lifetime pinned across a callback that may terminate it.
            set pins = pins + 1
            set active = true
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
                set stop = .onResume()
                if allocated then
                    if stop or finished then
                        call terminate()
                    endif
                endif
            else
                if finished then
                    call terminate()
                endif
            endif
            set pins = pins - 1
            call release()
        endif
    endmodule
    
    private module OnRemove
        local thistype aux
    
        if allocated then
            // Block recursive terminate/launch before calling user code. Resources
            // stay readable until onRemove returns; no allocator reuse meanwhile.
            set allocated = false
            set pins = pins + 1
            
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
            
            if index != -1 then
                set aux = collection[count]
                set aux.index = index
                set collection[index] = collection[count]
                set count = count - 1
                set index = -1
            endif

            static if LIBRARY_DummyRecycler then
                call SetUnitOwner(dummy, Player(PLAYER_NEUTRAL_PASSIVE), false)
                call DummyAddRecycleTimer(dummy, RECYCLE_TIME)
            else
                call Pool.recycle(dummy, RECYCLE_TIME)
            endif
            call clearVision()
            call origin.destroy()
            call impact.destroy()
            call DestroyEffect(effect)
            call reset()
            call flushAll()
            set pins = pins - 1
            call release()
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
            call predict()
        endmethod
    
        method operator curve takes nothing returns real
            return Atan(open/origin.distance)*bj_RADTODEG
        endmethod
    
        /* ----------------------------- Arced Movement ----------------------------- */
        method operator arc= takes real value returns nothing
            set height = Tan(value*bj_DEGTORAD)*origin.distance/4
            call predict()
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
            set veloc = newspeed*PERIOD
            call predict()
        endmethod

        method operator speed takes nothing returns real
            return veloc/PERIOD
        endmethod

        /* ------------------------------- Flight Time ------------------------------ */
        method operator duration= takes real flightTime returns nothing
            set veloc = RMaxBJ(0.00000001, (origin.distance-progress)*PERIOD/RMaxBJ(0.00000001, flightTime))
            set time = flightTime
            call predict()
        endmethod

        method operator duration takes nothing returns real
            return time
        endmethod
        
        /* ------------------------------- Sight Range ------------------------------ */
        method operator vision= takes real sightRange returns nothing
            set sight = sightRange
            call refreshVision()
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
            set progress = 0.
            set baseX = x
            set baseY = y
            set cA = origin.angle
            set finished = false
            call predict()
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
            set progress = 0.
            set baseX = x
            set baseY = y
            set cA = origin.angle
            set finished = false
            call predict()
        endmethod
        
        method deflectTarget takes unit u returns nothing
            call deflect(GetUnitX(u), GetUnitY(u), toZ)
            set target = u
        endmethod

        /* ---------------------------- Flush hit targets --------------------------- */
        method flushAll takes nothing returns nothing
            call FlushChildHashtable(table, this)
            call FlushChildHashtable(missileHits, this)
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
            local boolean stop

            // Native enumeration continues visiting handles after termination.
            if not allocated then
                set d = null
                return
            endif
            // Padding only finds candidates; do not widen the logical square.
            if RAbsBJ(GetWidgetX(d)-x) > collision or RAbsBJ(GetWidgetY(d)-y) > collision then
                set d = null
                return
            endif
            if not HaveSavedBoolean(table, this, GetHandleId(d)) then
                if collideZ then
                    set dz = GetLocZ(GetWidgetX(d), GetWidgetY(d))
                    set tz = GetDestructableOccluderHeight(d)
                    if dz + tz >= z - collision and dz <= z + collision then
                        call SaveBoolean(table, this, GetHandleId(d), true)
                        set stop = .onDestructable(d)
                        if allocated and stop then
                            set d = null
                            call terminate()
                            return
                        endif
                    endif
                else
                    call SaveBoolean(table, this, GetHandleId(d), true)
                    set stop = .onDestructable(d)
                    if allocated and stop then
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
            local boolean stop

            if not allocated then
                set i = null
                return
            endif
            if RAbsBJ(GetItemX(i)-x) > collision or RAbsBJ(GetItemY(i)-y) > collision then
                set i = null
                return
            endif
            if not HaveSavedBoolean(table, this, GetHandleId(i)) then
                if collideZ then
                    set dz = GetLocZ(GetItemX(i), GetItemY(i))
                    if dz + ITEM_SIZE >= z - collision and dz <= z + collision then
                        call SaveBoolean(table, this, GetHandleId(i), true)
                        set stop = .onItem(i)
                        if allocated and stop then
                            set i = null
                            call terminate()
                            return
                        endif
                    endif
                else
                    call SaveBoolean(table, this, GetHandleId(i), true)
                    set stop = .onItem(i)
                    if allocated and stop then
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
        private static hashtable missileHits = InitHashtable()
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
        // Active scheduler membership owns the ID until remove detaches it.
        // Pins protect non-scheduler callback dispatch (pause/resume/remove).
        private boolean  active
        private integer  pins
        private integer  generation
        // Uncurved current sample; setters refresh prediction without advancing it.
        private real     progress
        private real     nextProgress
        private real     baseX
        private real     baseY
        private real     nextBaseX
        private real     nextBaseY
        private fogmodifier visionFog
        private player   visionOwner
        private real     visionRadius
        private real     visionX
        private real     visionY
        
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
    
        private method predict takes nothing returns nothing
            local real d = origin.distance
            local real q = progress + veloc*dilation
            local real advance
            local real lateral
            if not allocated then
                return
            endif
            if q > d then
                set q = d
            endif
            set advance = q-progress
            set nextProgress = q
            set nextBaseX = baseX + advance*Cos(cA)
            set nextBaseY = baseY + advance*Sin(cA)
            if q >= d then
                set nextBaseX = impact.x
                set nextBaseY = impact.y
            endif
            set lateral = 4*open*q*(d-q)/(d*d)
            set nextX = nextBaseX + lateral*Cos(cA+bj_PI/2)
            set nextY = nextBaseY + lateral*Sin(cA+bj_PI/2)
            set nextZ = origin.z + origin.slope*q + 4*height*q*(d-q)/(d*d)
        endmethod

        private method clearVision takes nothing returns nothing
            if visionFog != null then
                call FogModifierStop(visionFog)
                call DestroyFogModifier(visionFog)
                set visionFog = null
            endif
            set visionOwner = null
        endmethod

        // Explicit circular revelation; not unit sight or terrain/tree occlusion.
        private method refreshVision takes nothing returns nothing
            local player p = owner
            local boolean reveal = p != null
            if not allocated then
                call clearVision()
                set p = null
                return
            endif
            if p == null then
                if source != null and GetUnitTypeId(source) != 0 then
                    set p = GetOwningPlayer(source)
                    set reveal = true
                else
                    set p = Player(PLAYER_NEUTRAL_PASSIVE)
                endif
            endif
            if GetOwningPlayer(dummy) != p then
                call SetUnitOwner(dummy, p, false)
            endif
            // Neutral fallback owns the dummy, but absence of an owner grants no reveal.
            if sight <= 0. or not reveal then
                call clearVision()
            elseif visionFog == null or visionOwner != p or visionRadius != sight or visionX != x or visionY != y then
                call clearVision()
                set visionOwner = p
                set visionRadius = sight
                set visionX = x
                set visionY = y
                set visionFog = CreateFogModifierRadius(p, FOG_OF_WAR_VISIBLE, x, y, sight, true, false)
                call FogModifierStart(visionFog)
            endif
            set p = null
        endmethod

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
            set progress     = 0.
            set nextProgress = 0.
            set visionFog    = null
            set visionOwner  = null
            set visionRadius = 0.
            set data         = 0
            set type         = 0
            set tileset      = 0
            set pkey         = -1
            set index        = -1
        endmethod
        
        // The only Missiles allocator-release site. Cleanup and ID ownership are
        // separate: active terminal instances still occupy a scheduler slot.
        private method release takes nothing returns nothing
            if not allocated and not active and pins == 0 then
                call deallocate()
            endif
        endmethod

        /* -------------------------- Destroys the missile -------------------------- */
        private method remove takes integer i returns integer
            local boolean stop

            set pins = pins + 1
            // Detach BEFORE onPause: a nested resume owns a new active slot.
            set missiles[i] = missiles[id]
            set id = id - 1
            set active = false

            if id + 1 > SWEET_SPOT and SWEET_SPOT > 0 then
                set dilation = (id + 1)/SWEET_SPOT
            else
                set dilation = 1
            endif

            if id == -1 then
                call PauseTimer(timer)
            endif
            
            if allocated and paused then
                implement OnPause
            else
                implement OnRemove
            endif
            set pins = pins - 1
            call release()

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
            local boolean     stop

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
                        if allocated then
                            implement OnMissile
                        endif
                        if allocated then
                            implement OnDestructable
                        endif
                        if allocated then
                            implement OnItem
                        endif
                        if allocated then
                            implement OnCliff
                        endif
                        if allocated then
                            implement OnTerrain
                        endif
                        if allocated then
                            implement OnTileset
                        endif
                        if allocated then
                            implement OnPeriod
                        endif
                        if allocated then
                            implement OnOrient
                            implement OnFinish
                        endif
                        if allocated then
                            implement OnBoundaries
                        endif
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
                set active = true
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
            call .flushAll()
            set .active = false
            set .pins = 0
            // Never reset this slot's generation when a lifetime ends.
            set .generation = .generation + 1
            set .origin = Coordinates.create(x, y, z)
            set .impact = Coordinates.create(toX, toY, toZ)
            call Coordinates.link(origin, impact)
            set .allocated = true
            set .cA = origin.angle
            set .x = x
            set .y = y
            set .z = origin.z
            set .prevX = x
            set .prevY = y
            set .prevZ = origin.z
            set .nextX = x
            set .nextY = y
            set .nextZ = origin.z
            set .toZ = toZ
            set .baseX = x
            set .baseY = y
            set .nextBaseX = x
            set .nextBaseY = y

            static if LIBRARY_DummyRecycler then
                set .dummy = GetRecycledDummy(x, y, z, face)
            else
                set .dummy = Pool.retrieve(x, y, z, face)
            endif
            call SetUnitZ(.dummy, .origin.z)

            return this
        endmethod
    endstruct
endlibrary

