library RFBurstLog
    // Same snapshot/counter protocol as Burst/Aim; isolated new run and group.
    globals
        constant string RB_RUN_ID = "rf-burst-tree-red-20261020-04"
        private string array rows
        private integer count = 0
        private integer cases = 0
        private integer checks = 0
        private integer failures = 0
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
            set i = i+1
        endloop
        call PreloadGenEnd("Logs\\RF-rf-burst-tree-red-20261020-04.txt")
        return true
    endfunction

    private function Log takes string text returns nothing
        set rows[count] = "RM28|"+RB_RUN_ID+"|"+text
        set count = count+1
        call TriggerEvaluate(writer)
    endfunction

    function RB_LogBegin takes nothing returns nothing
        set writer = CreateTrigger()
        call TriggerAddCondition(writer,Condition(function Snapshot))
        call Log("BEGIN|RFBurstTree")
    endfunction

    function RB_LogCase takes string id returns nothing
        set current = id
        set cases = cases+1
        call Log("CASE|"+id)
    endfunction

    function RB_LogRecord takes string status, string name, string detail returns nothing
        set checks = checks+1
        if status == "FAIL" then
            set failures = failures+1
        endif
        call Log("CHECK|"+current+"|"+status+"|"+name+"|"+detail)
    endfunction

    function RB_LogCheck takes boolean ok, string name, string detail returns nothing
        if ok then
            call RB_LogRecord("PASS",name,detail)
        else
            call RB_LogRecord("FAIL",name,detail)
        endif
    endfunction

    function RB_LogComplete takes nothing returns nothing
        call Log("COMPLETE|"+I2S(cases)+"|"+I2S(checks)+"|"+I2S(failures)+"|0")
        call DisplayTimedTextToPlayer(Player(0),0.,0.,120.,"Tree RED observation complete: failures="+I2S(failures))
        call DestroyTrigger(writer)
        set writer = null
    endfunction
endlibrary
