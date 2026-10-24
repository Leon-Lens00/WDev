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
