library RFProbeLog
    globals
        constant string RF_RUN_ID = "rf-pathing-20261019-06"
        constant string RF_LOG_FILE = "Logs\\RF-rf-pathing-20261019-06.txt"
        private string array rows
        private integer count = 0
        private integer cases = 0
        private integer checks = 0
        private integer failures = 0
        private integer skips = 0
        private string current = ""
        private trigger writer = null
    endglobals

    private function Snapshot takes nothing returns boolean
        local integer i = 0
        call PreloadGenClear()
        call PreloadGenStart()
        loop
            exitwhen i >= count
            call Preload(rows[i])
            set i = i + 1
        endloop
        call PreloadGenEnd(RF_LOG_FILE)
        return true
    endfunction

    private function Log takes string text returns nothing
        // Finite bounded fixture, not a production logger or wall-clock guarantee.
        set rows[count] = "RM28|" + RF_RUN_ID + "|" + text
        set count = count + 1
        call TriggerEvaluate(writer)
    endfunction

    function RF_Begin takes nothing returns nothing
        set writer = CreateTrigger()
        call TriggerAddCondition(writer, Condition(function Snapshot))
        call Log("BEGIN|RFPathing")
    endfunction

    function RF_Case takes string id returns nothing
        set current = id
        set cases = cases + 1
        call Log("CASE|" + id)
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 3., "RF " + id)
    endfunction

    function RF_Record takes string status, string name, string detail returns nothing
        set checks = checks + 1
        if status == "FAIL" then
            set failures = failures + 1
        elseif status == "SKIP" then
            set skips = skips + 1
        endif
        call Log("CHECK|" + current + "|" + status + "|" + name + "|" + detail)
    endfunction

    function RF_Check takes boolean ok, string name, string detail returns nothing
        if ok then
            call RF_Record("PASS", name, detail)
        else
            call RF_Record("FAIL", name, detail)
        endif
    endfunction

    function RF_Bool takes boolean value returns string
        if value then
            return "true"
        endif
        return "false"
    endfunction

    function RF_Complete takes nothing returns nothing
        call Log("COMPLETE|" + I2S(cases) + "|" + I2S(checks) + "|" + I2S(failures) + "|" + I2S(skips))
        call DisplayTimedTextToPlayer(Player(0), 0., 0., 120., "RF COMPLETE failures=" + I2S(failures))
        call DestroyTrigger(writer)
        set writer = null
    endfunction
endlibrary
