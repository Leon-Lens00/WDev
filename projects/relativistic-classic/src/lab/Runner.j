library LabRunner requires LabLifecycle, LabMotion, LabContact, LabEnvironment, LabLoad
    globals
        private constant integer CASE_COUNT = 47
        private timer runner = CreateTimer()
        private boolean started = false
        private integer drain = 0
        private integer removedAtDrain = 0
    endglobals

    private function CaseID takes integer n returns string
        if n <= 6 then
            return "L0" + I2S(n)
        elseif n <= 19 then
            return "M" + I2S(n)
        elseif n <= 26 then
            return "C" + I2S(n)
        elseif n <= 29 then
            return "E" + I2S(n)
        elseif n <= 32 then
            return "P" + I2S(n)
        elseif n == 33 then
            return "M33"
        elseif n == 34 then
            return "P34"
        elseif n <= 44 then
            return "C" + I2S(n)
        elseif n == 45 then
            return "M45"
        elseif n == 46 then
            return "E46"
        endif
        return "L99"
    endfunction

    private function Group takes integer n returns string
        if n <= 6 or n == CASE_COUNT then
            return "lifecycle"
        elseif n <= 19 or n == 33 or n == 45 then
            return "motion"
        elseif n <= 26 or (n >= 35 and n <= 44) then
            return "contact"
        elseif n <= 29 or n == 46 then
            return "environment"
        endif
        return "load"
    endfunction

    private function Selected takes integer n returns boolean
        return RM_SELECT == "all" or RM_SELECT == CaseID(n) or RM_SELECT == Group(n)
    endfunction

    private function RemovalSum takes nothing returns integer
        local integer i = 1
        local integer sum = 0
        loop
            exitwhen i > 400
            set sum = sum + RM_REMOVE[i]
            set i = i + 1
        endloop
        return sum
    endfunction

    private function StartCase takes nothing returns nothing
        if RM_CASE <= 6 or RM_CASE == CASE_COUNT then
            call RM_LifeStart()
        elseif RM_CASE <= 19 or RM_CASE == 33 then
            call RM_MotionStart()
        elseif RM_CASE <= 26 then
            call RM_ContactStart()
        elseif RM_CASE <= 29 then
            call RM_EnvironmentStart()
        elseif RM_CASE <= 32 or RM_CASE == 34 then
            call RM_LoadStart()
        elseif RM_CASE <= 44 then
            call RM_ContactRuleStart()
        elseif RM_CASE == 45 then
            call RM_CoordinatesStart()
        else
            call RM_TilesStart()
        endif
    endfunction

    private function StepCase takes nothing returns nothing
        if RM_CASE <= 6 or RM_CASE == CASE_COUNT then
            call RM_LifeStep()
        elseif RM_CASE <= 19 or RM_CASE == 33 then
            call RM_MotionStep()
        elseif RM_CASE <= 26 then
            call RM_ContactStep()
        elseif RM_CASE <= 29 then
            call RM_EnvironmentStep()
        elseif RM_CASE <= 32 or RM_CASE == 34 then
            call RM_LoadStep()
        elseif RM_CASE <= 44 then
            call RM_ContactRuleStep()
        elseif RM_CASE == 45 then
            call RM_CoordinatesStep()
        else
            call RM_TilesStep()
        endif
    endfunction

    private function Next takes nothing returns nothing
        set RM_CASE = RM_CASE + 1
        loop
            exitwhen RM_CASE > CASE_COUNT or Selected(RM_CASE)
            set RM_CASE = RM_CASE + 1
        endloop
        if RM_CASE > CASE_COUNT then
            call PauseTimer(runner)
            call RM_Complete()
            return
        endif
        set RM_STAGE = 0
        call RM_Reset()
        call RM_Case(CaseID(RM_CASE))
        call StartCase()
    endfunction

    private function Tick takes nothing returns nothing
        if drain > 0 then
            set drain = drain - 1
            if drain == 0 then
                call RM_Equal(RemovalSum(), removedAtDrain, "idle-no-extra-remove")
                call Next()
            endif
            return
        endif
        set RM_STAGE = RM_STAGE + 1
        call StepCase()
        if RM_STAGE == RM_LIMIT then
            if RM_CASE >= 35 and RM_CASE <= 44 then
                call RM_ContactRuleCleanup()
            endif
            call RM_Cleanup()
            set removedAtDrain = RemovalSum()
            // Two ticks let public termination drain scheduler; no internal counters read.
            set drain = 2
        endif
    endfunction

    private function Delayed takes nothing returns nothing
        call RM_Begin()
        call Next()
        if RM_CASE <= CASE_COUNT then
            call TimerStart(runner, .25, true, function Tick)
        endif
    endfunction

    private function ValidID takes nothing returns boolean
        local integer i = 0
        local integer j
        local string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.-"
        local string c
        if RM_RUN_ID == "UNCONFIGURED" or StringLength(RM_RUN_ID) == 0 or StringLength(RM_RUN_ID) > 80 then
            return false
        endif
        loop
            exitwhen i >= StringLength(RM_RUN_ID)
            set c = SubString(RM_RUN_ID, i, i+1)
            set j = 0
            loop
                exitwhen j >= StringLength(alphabet) or c == SubString(alphabet, j, j+1)
                set j = j + 1
            endloop
            if j >= StringLength(alphabet) or (i == 0 and j >= 62) then
                return false
            endif
            set i = i + 1
        endloop
        return true
    endfunction

    function LabRun takes nothing returns nothing
        local integer i = 1
        local boolean validSelection = false
        if started then
            call DisplayTimedTextToPlayer(Player(0), 0., 0., 10., "RM28 already started; use a new map run and unique ID")
            return
        endif
        loop
            exitwhen i > CASE_COUNT
            set validSelection = validSelection or Selected(i)
            set i = i + 1
        endloop
        if not ValidID() or not validSelection then
            call DisplayTimedTextToPlayer(Player(0), 0., 0., 120., "RM28 configure safe unique RM_RUN_ID and RM_SELECT before building")
            return
        endif
        set started = true
        // Public entry is called from RCStartHarness after InitBlizzard, not chat.
        call TimerStart(runner, .5, false, function Delayed)
    endfunction
endlibrary
