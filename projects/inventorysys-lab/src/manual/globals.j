// Recorder-owned state only. The demo remains the owner of all gameplay state.
    constant string ILM_BUILD = "@RUN_ID@"
    constant integer ILM_CHUNK_ROWS = 128
    constant integer ILM_MAX_CHUNKS = 64
    constant integer ILM_QUEUE_ROWS = 256
    boolean ILM_Active = false
    boolean ILM_Used = false
    boolean ILM_EndPending = false
    boolean ILM_SavePending = false
    boolean ILM_ChunkDirty = false
    boolean ILM_Dirty = false
    string ILM_Session = ""
    string ILM_Reason = ""
    integer ILM_Dropped = 0
    integer ILM_Sequence = 0
    integer ILM_Head = 0
    integer ILM_Tail = 0
    integer ILM_Queued = 0
    string array ILM_Queue
    string array ILM_Chunk
    integer ILM_ChunkIndex = 0
    integer ILM_ChunkCount = 0
    integer ILM_LastSample = -1000
    integer array ILM_Items
    integer array ILM_Custom
    integer ILM_Str = -1
    integer ILM_Agi = -1
    integer ILM_Int = -1
    integer ILM_Gold = -1
    unit ILM_Hero = null
    integer ILM_Inventory = 0
    timer ILM_Clock = null
    timer ILM_Poll = null
    trigger ILM_Work = null
    trigger ILM_Chat = null
