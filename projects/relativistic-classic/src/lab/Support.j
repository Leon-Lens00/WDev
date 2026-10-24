library LabSupport initializer InitSnapshot requires LabConfig, Missiles
    globals
        private trigger snapshotTrigger = null
        private string array lines
        private integer lineCount = 0
        private integer checks = 0
        private integer failures = 0
        private integer skips = 0
        private integer cases = 0
        private string current = ""
        timer RM_CLOCK = CreateTimer()
        integer array RM_PERIODS
        integer array RM_FINISH
        integer array RM_REMOVE
        integer array RM_PAUSE
        integer array RM_RESUME
        integer array RM_HITS
        integer array RM_ITEMS
        integer array RM_DESTS
        integer array RM_MISSILES
        integer array RM_BOUNDS
        real array RM_X
        real array RM_Y
        real array RM_Z
        real array RM_TIME
        real array RM_SPEED
        unit array RM_DUMMY
        Missiles array RM_M
        unit RM_U = null
        item RM_I = null
        destructable RM_D = null
        real RM_T0 = 0.
        real RM_SAVED = 0.
        real RM_SAVED2 = 0.
        integer RM_OLD_ID = 0
        integer RM_NEW_ID = 0
        integer RM_STAGE = 0
        integer RM_CASE = 0
        integer RM_LIMIT = 8
    endglobals

    private function FlushSnapshot takes nothing returns boolean
        local integer i = 0
        // Same immediate cumulative snapshot, evaluated outside the caller context.
        call PreloadGenClear()
        call PreloadGenStart()
        loop
            exitwhen i >= lineCount
            call Preload(lines[i])
            set i = i + 1
        endloop
        call PreloadGenEnd(RM_LOG_FILE)
        return true
    endfunction

    private function InitSnapshot takes nothing returns nothing
        set snapshotTrigger = CreateTrigger()
        call TriggerAddCondition(snapshotTrigger, Condition(function FlushSnapshot))
    endfunction

    function RM_Log takes string text returns nothing
        set lines[lineCount] = "RM28|" + RM_RUN_ID + "|" + text
        set lineCount = lineCount + 1
        call TriggerEvaluate(snapshotTrigger)
    endfunction

    function RM_Begin takes nothing returns nothing
        call TimerStart(RM_CLOCK, 10000., false, null)
        call RM_Log("BEGIN|" + RM_SELECT)
    endfunction

    function RM_Case takes string id returns nothing
        set current = id
        set cases = cases + 1
        call RM_Log("CASE|" + id)
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 4., "RM28 " + RM_RUN_ID + " : " + id)
        call PanCameraToTimed(0., 0., .2)
    endfunction

    function RM_Record takes string status, string name, string detail returns nothing
        set checks = checks + 1
        if status == "FAIL" then
            set failures = failures + 1
        elseif status == "SKIP" then
            set skips = skips + 1
        endif
        call RM_Log("CHECK|" + current + "|" + status + "|" + name + "|" + detail)
    endfunction

    function RM_Check takes boolean ok, string name, string detail returns nothing
        if ok then
            call RM_Record("PASS", name, detail)
        else
            call RM_Record("FAIL", name, detail)
            call DisplayTimedTextToPlayer(Player(0), 0., 0., 5., "FAIL " + current + " " + name)
        endif
    endfunction

    function RM_Near takes real actual, real expected, real tolerance, string name returns nothing
        call RM_Check(RAbsBJ(actual-expected) <= tolerance, name, "expected=" + R2S(expected) + " actual=" + R2S(actual) + " tolerance=" + R2S(tolerance))
    endfunction

    function RM_Equal takes integer actual, integer expected, string name returns nothing
        call RM_Check(actual == expected, name, "expected=" + I2S(expected) + " actual=" + I2S(actual))
    endfunction

    function RM_Complete takes nothing returns nothing
        call RM_Log("COMPLETE|" + I2S(cases) + "|" + I2S(checks) + "|" + I2S(failures) + "|" + I2S(skips))
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 120., "RM28 COMPLETE " + RM_RUN_ID + " cases=" + I2S(cases) + " checks=" + I2S(checks) + " failures=" + I2S(failures) + " skips=" + I2S(skips))
        call PauseTimer(RM_CLOCK)
    endfunction

    function RM_Ground takes real x, real y returns real
        local location p = Location(x, y)
        local real z = GetLocationZ(p)
        call RemoveLocation(p)
        set p = null
        return z
    endfunction

    function RM_Visual takes Missiles m, integer tag returns nothing
        set m.data = tag
        set m.model = RM_MODEL
        set m.scale = 1.
        set m.owner = Player(0)
        set m.damage = 17.
        set m.type = 28
    endfunction

    function RM_Reset takes nothing returns nothing
        local integer i = 1
        loop
            exitwhen i > 400
            set RM_M[i] = 0
            set RM_PERIODS[i] = 0
            set RM_FINISH[i] = 0
            set RM_REMOVE[i] = 0
            set RM_PAUSE[i] = 0
            set RM_RESUME[i] = 0
            set RM_HITS[i] = 0
            set RM_ITEMS[i] = 0
            set RM_DESTS[i] = 0
            set RM_MISSILES[i] = 0
            set RM_BOUNDS[i] = 0
            set RM_X[i] = 0.
            set RM_Y[i] = 0.
            set RM_Z[i] = 0.
            set RM_TIME[i] = 0.
            set RM_SPEED[i] = 0.
            set RM_DUMMY[i] = null
            set i = i + 1
        endloop
        set RM_T0 = TimerGetElapsed(RM_CLOCK)
        set RM_LIMIT = 8
    endfunction

    function RM_Cleanup takes nothing returns nothing
        local integer i = 1
        local Missiles m
        loop
            exitwhen i > 400
            set m = RM_M[i]
            // Public disposal only; baseline may need launch/resume to dispose.
            if m != 0 and m.allocated then
                if not m.launched then
                    call m.launch()
                endif
                call m.pause(false)
                call m.terminate()
            endif
            set RM_M[i] = 0
            set i = i + 1
        endloop
        if RM_U != null then
            call RemoveUnit(RM_U)
            set RM_U = null
        endif
        if RM_I != null then
            call RemoveItem(RM_I)
            set RM_I = null
        endif
        if RM_D != null then
            call RemoveDestructable(RM_D)
            set RM_D = null
        endif
    endfunction
endlibrary
