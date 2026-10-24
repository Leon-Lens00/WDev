// ITL owns only fixtures and telemetry; original globals remain untouched.
    string ITL_RUN = "@RUN_ID@"
    integer ITL_Mode = 0
    integer ITL_Camera = 0
    integer array ITL_Ids
    unit array ITL_Units
    real array ITL_X
    real array ITL_Y
    real array ITL_BulkX
    real array ITL_BulkY
    boolean ITL_Ready = false
    boolean ITL_ProjectionReady = false
    boolean ITL_Stop = false
    integer ITL_Pair = 0
    integer ITL_Case = 0
    integer ITL_Cases = 0
    string ITL_Current = "-"
    integer ITL_LineCount = 0
    string array ITL_Lines
    boolean ITL_LogFault = false
    integer array ITL_Total
    integer array ITL_Local
    boolean ITL_Active = false
    string ITL_Payload = ""
    trigger ITL_Validator = null
    trigger ITL_Persist = null
    trigger ITL_Work = null
    timer ITL_Next = null
    timer ITL_Watch = null
    timer ITL_PhaseTimer = null
    timer ITL_Clock = null
    integer ITL_Phase = 0
    integer ITL_Beat = 0
    integer ITL_StartBeat = 0
    timer ITL_Heartbeat = null
    integer ITL_OwnedButton = 0
    integer ITL_Generation = 0
    integer ITL_TimerCount = 0
    timer array ITL_Timers
    integer array ITL_TimerGeneration
    boolean array ITL_CleanupAttempted
    boolean array ITL_Retired
    boolean array ITL_Fired
    integer ITL_Acquired = 0
    integer ITL_ExpiredCount = 0
    integer ITL_Released = 0
    integer ITL_Destroyed = 0
    integer ITL_CleanupRetired = 0
    integer ITL_Clicks = 0
    integer ITL_FirstAcquired = 0
    integer ITL_FirstClicks = 0
    boolean ITL_HarnessCleanup = false
    string ITL_LastBoundary = "none"
