    constant string IL_RUN = "@RUN_ID@"
    string array IL_Lines
    integer IL_LineCount = 0
    trigger IL_Persist = null
    trigger IL_Work = null
    timer IL_Next = null
    timer IL_Watch = null
    integer IL_Case = 0
    integer IL_Cases = 0
    string IL_Current = "-"
    integer IL_Pass = 0
    integer IL_Fail = 0
    integer IL_Obs = 0
    integer IL_Skip = 0
    integer IL_CP = 0
    integer IL_CF = 0
    integer IL_CO = 0
    integer IL_CS = 0
    boolean IL_Active = false
    boolean IL_LogFault = false
    boolean IL_Ready = false
    boolean IL_Empty = false
    boolean IL_Equipped = false
    unit IL_Hero = null
    integer IL_Inv = 0
    integer IL_Gear = 0
    integer IL_Fixture = 0
    integer IL_BaseStr = 0
    integer IL_BaseAgi = 0
    integer IL_BaseInt = 0
    integer array IL_Saved
    integer array IL_Custom
    integer array IL_InitialCustom
    integer IL_SavedCount = 0
    integer IL_SavedZero = 0
    integer IL_SavedStr = 0
    integer IL_SavedAgi = 0
    integer IL_SavedInt = 0
    boolean array IL_Owned
    item IL_Physical = null
    integer IL_PickEvents = 0
    trigger IL_PickTrigger = null
