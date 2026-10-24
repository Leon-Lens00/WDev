// WaveSys player registry. Warcraft III Classic 1.27b, no UI dependencies.
library WavePlayerUtils initializer Init

    // A dense set of Classic playable slot ids (0..11). Each position is
    // encoded as index+1, so player 0 and dense position 0 remain valid.
    // One live roster is used by WavePlayer; other rosters are independent.
    struct WavePlayerRoster
        private integer array ids[12]
        private integer array positions[12]
        readonly integer count = 0

        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.count = 0
            return this
        endmethod

        method contains takes integer pid returns boolean
            if pid < 0 or pid >= 12 then
                return false
            endif
            return this.positions[pid] != 0
        endmethod

        method at takes integer index returns integer
            if index < 0 or index >= this.count then
                return -1
            endif
            return this.ids[index]
        endmethod

        method add takes integer pid returns boolean
            if pid < 0 or pid >= 12 then
                return false
            endif
            if this.positions[pid] != 0 then
                return false
            endif
            set this.ids[this.count] = pid
            set this.positions[pid] = this.count + 1
            set this.count = this.count + 1
            return true
        endmethod

        method remove takes integer pid returns boolean
            local integer index
            local integer moved
            if not this.contains(pid) then
                return false
            endif
            set index = this.positions[pid] - 1
            set this.count = this.count - 1
            if index != this.count then
                set moved = this.ids[this.count]
                set this.ids[index] = moved
                set this.positions[moved] = index + 1
            endif
            set this.positions[pid] = 0
            set this.ids[this.count] = -1
            return true
        endmethod

        method clear takes nothing returns nothing
            local integer i = 0
            loop
                exitwhen i >= this.count
                set this.positions[this.ids[i]] = 0
                set this.ids[i] = -1
                set i = i + 1
            endloop
            set this.count = 0
        endmethod

        method destroy takes nothing returns nothing
            call this.clear()
            call this.deallocate()
        endmethod
    endstruct

    globals
        private WavePlayerRoster ActivePlayers = 0
        private string array ColorHex
    endglobals

    // Slot identity is stable; dense enumeration order may change on leave.
    // No linked list, hooks, cached names or UI ownership are shared with User.
    struct WavePlayer extends array
        static constant integer NULL = -1
        readonly static player Local
        readonly static integer LocalId

        static method operator AmountPlaying takes nothing returns integer
            return ActivePlayers.count
        endmethod

        static method fromIndex takes integer pid returns thistype
            if pid < 0 or pid >= bj_MAX_PLAYER_SLOTS then
                return thistype.NULL
            endif
            return thistype(pid)
        endmethod

        static method fromPlaying takes integer index returns thistype
            return thistype(ActivePlayers.at(index))
        endmethod

        static method operator [] takes player p returns thistype
            if p == null then
                return thistype.NULL
            endif
            return thistype.fromIndex(GetPlayerId(p))
        endmethod

        method operator id takes nothing returns integer
            return this
        endmethod

        method operator handle takes nothing returns player
            if integer(this) < 0 or integer(this) >= bj_MAX_PLAYER_SLOTS then
                return null
            endif
            return Player(this)
        endmethod

        method toPlayer takes nothing returns player
            return this.handle
        endmethod

        method operator isPlaying takes nothing returns boolean
            return ActivePlayers.contains(this)
        endmethod

        method operator name takes nothing returns string
            if this.handle == null then
                return ""
            endif
            return GetPlayerName(this.handle)
        endmethod

        method operator nameColored takes nothing returns string
            local integer colorId
            if this.handle == null then
                return ""
            endif
            // PLAYER_COLOR_RED has handle id 0 in Classic; zero is valid.
            set colorId = GetHandleId(GetPlayerColor(this.handle))
            if colorId < 0 or colorId >= 12 then
                return "|cFF808080" + this.name + "|r"
            endif
            return ColorHex[colorId] + this.name + "|r"
        endmethod

        private static method onInit takes nothing returns nothing
            set thistype.Local = GetLocalPlayer()
            set thistype.LocalId = GetPlayerId(thistype.Local)
        endmethod
    endstruct

    private function OnLeave takes nothing returns boolean
        call ActivePlayers.remove(GetPlayerId(GetTriggerPlayer()))
        return false
    endfunction

    private function Init takes nothing returns nothing
        local trigger leaves = CreateTrigger()
        local integer pid = 0
        local player p
        set ActivePlayers = WavePlayerRoster.create()
        set ColorHex[0] = "|cFFFF0303"
        set ColorHex[1] = "|cFF0042FF"
        set ColorHex[2] = "|cFF1CE6B9"
        set ColorHex[3] = "|cFF540081"
        set ColorHex[4] = "|cFFFFFC01"
        set ColorHex[5] = "|cFFFE8A0E"
        set ColorHex[6] = "|cFF20C000"
        set ColorHex[7] = "|cFFE55BB0"
        set ColorHex[8] = "|cFF959697"
        set ColorHex[9] = "|cFF7EBFF1"
        set ColorHex[10] = "|cFF106246"
        set ColorHex[11] = "|cFF4E2A04"
        loop
            exitwhen pid >= 12
            set p = Player(pid)
            if GetPlayerController(p) == MAP_CONTROL_USER and GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING then
                call ActivePlayers.add(pid)
                call TriggerRegisterPlayerEvent(leaves, p, EVENT_PLAYER_LEAVE)
            endif
            set pid = pid + 1
        endloop
        call TriggerAddCondition(leaves, Condition(function OnLeave))
        set p = null
        set leaves = null
    endfunction
endlibrary
