// TerrainDev local instrumentation, Classic 1.27b. See docs/planes/multiboard-misiles.md.
// Hooks only observe: never kill, unpause, move or recycle gameplay objects.
library MissileDiagnostics initializer Init requires Table

struct MissileStats extends array
    // Public read-only snapshot. Death/timeout observations have <=1s latency.
    readonly static integer active = 0
    readonly static integer peakActive = 0
    readonly static integer created = 0
    readonly static integer retired = 0
    readonly static integer oldestSeconds = 0
    readonly static integer tracked = 0
    readonly static integer peakTracked = 0
    readonly static integer borrowed = 0
    readonly static integer pooled = 0
    readonly static integer deferred = 0
    readonly static integer pending = 0
    readonly static integer overdue = 0
    readonly static integer preloadTotal = 0
    readonly static integer newTotal = 0
    readonly static integer reusedTotal = 0
    readonly static integer adoptedTotal = 0
    readonly static integer disposed = 0
    readonly static integer lost = 0
    readonly static integer invalid = 0
    readonly static integer omitted = 0
    readonly static integer errors = 0
    readonly static integer inconsistent = 0
    readonly static integer alarms = 0
    readonly static integer capacity = 0
    readonly static integer checks = 0
    readonly static integer renders = 0
    readonly static multiboard board = null

    private static constant integer LIMIT = 8190
    private static constant real GRACE = 1.25
    private static constant integer OLD_AGE = 30
    private static Table index
    private static timer clock = CreateTimer()
    private static timer watcher = CreateTimer()
    private static timer painter = CreateTimer()
    private static boolean queued = false
    private static boolean initialized = false
    private static unit array units
    // 1 reserve; 2 borrowed; 3 waiting for fx; 4 timed-life disposal.
    private static integer array state
    private static real array deadline
    private static boolean array warned
    private static integer array nodeSlot
    private static integer array nodes
    private static real array born
    private static boolean array hidden
    private static string array cell
    private static string title = ""

    private static method value takes integer row, string text returns nothing
        local multiboarditem mbi
        if cell[row] != text then
            set cell[row] = text
            set mbi = MultiboardGetItem(board,row,1)
            call MultiboardSetItemValue(mbi,text)
            call MultiboardReleaseItem(mbi)
            set mbi = null
        endif
    endmethod

    private static method label takes integer row, string text returns nothing
        local multiboarditem mbi = MultiboardGetItem(board,row,0)
        call MultiboardSetItemValue(mbi,text)
        call MultiboardSetItemWidth(mbi,0.17)
        call MultiboardReleaseItem(mbi)
        set mbi = MultiboardGetItem(board,row,1)
        call MultiboardSetItemWidth(mbi,0.12)
        call MultiboardReleaseItem(mbi)
        set mbi = null
    endmethod

    private static method warning takes integer n returns string
        if n > 0 then
            return "|cffff5555"+I2S(n)+"|r"
        endif
        return I2S(n)
    endmethod

    private static method draw takes nothing returns nothing
        local string nextTitle
        set queued = false
        if board == null then
            set board = CreateMultiboard()
            call MultiboardSetRowCount(board,19)
            call MultiboardSetColumnCount(board,2)
            call MultiboardSetItemsStyle(board,true,false)
            call label(0,"Instancias / pico")
            call label(1,"Creadas / retiradas")
            call label(2,"Instancia mas antigua")
            call label(3,"Dummies vivos / pico")
            call label(4,"Dummies prestados")
            call label(5,"Reserva / capacidad")
            call label(6,"Esperando efectos")
            call label(7,"Descarte pendiente")
            call label(8,"Esperas vencidas")
            call label(9,"Precreados / nuevos")
            call label(10,"Reutilizaciones")
            call label(11,"Descartes expirados")
            call label(12,"Perdidas inesperadas")
            call label(13,"Reciclajes invalidos")
            call label(14,"Externos / omitidos")
            call label(15,"Inconsistencias / errores")
            call label(16,"Alarmas historicas")
            call label(17,"Revisiones de vida")
            call label(18,"Ver / ocultar")
            call MultiboardDisplay(board,true)
            call MultiboardMinimize(board,false)
        endif
        if overdue > 0 or lost > 0 or invalid > 0 or omitted > 0 or errors > 0 or inconsistent > 0 then
            set nextTitle = "|cffff5555Misiles: ALERTA|r"
        elseif alarms > 0 then
            set nextTitle = "|cffffcc44Misiles: revisar historial|r"
        elseif oldestSeconds >= OLD_AGE then
            set nextTitle = "|cffffcc44Misiles: revisar edad|r"
        elseif active > 0 or deferred > 0 or pending > 0 then
            set nextTitle = "|cff66ccffMisiles: actividad|r"
        else
            set nextTitle = "|cff66ff88Misiles: OK|r"
        endif
        if nextTitle != title then
            set title = nextTitle
            call MultiboardSetTitleText(board,title)
        endif
        call value(0,I2S(active)+" / "+I2S(peakActive))
        call value(1,I2S(created)+" / "+I2S(retired))
        call value(2,I2S(oldestSeconds)+" s (aviso 30)")
        call value(3,I2S(tracked)+" / "+I2S(peakTracked))
        call value(4,I2S(borrowed))
        call value(5,I2S(pooled)+" / "+I2S(capacity))
        call value(6,I2S(deferred))
        call value(7,I2S(pending))
        call value(8,warning(overdue))
        call value(9,I2S(preloadTotal)+" / "+I2S(newTotal))
        call value(10,I2S(reusedTotal))
        call value(11,I2S(disposed))
        call value(12,warning(lost))
        call value(13,warning(invalid))
        call value(14,I2S(adoptedTotal)+" / "+warning(omitted))
        call value(15,warning(inconsistent)+" / "+warning(errors))
        call value(16,I2S(alarms))
        call value(17,I2S(checks)+" (cada 1 s)")
        call value(18,"-misiles")
        set renders = renders+1
    endmethod

    private static method touch takes nothing returns nothing
        if initialized and not queued then
            set queued = true
            // Coalesce all hooks in this execution; no drawing in physics loops.
            call TimerStart(painter,0.,false,function thistype.draw)
        endif
    endmethod

    private static method error takes nothing returns nothing
        set errors = errors+1
        set alarms = alarms+1
        call touch()
    endmethod

    private static method changeState takes integer slot, integer nextState returns nothing
        if state[slot] == 1 then
            set pooled = pooled-1
        elseif state[slot] == 2 then
            set borrowed = borrowed-1
        elseif state[slot] == 3 then
            set deferred = deferred-1
        elseif state[slot] == 4 then
            set pending = pending-1
        endif
        set state[slot] = nextState
        set warned[slot] = false
        if nextState == 1 then
            set pooled = pooled+1
        elseif nextState == 2 then
            set borrowed = borrowed+1
        elseif nextState == 3 then
            set deferred = deferred+1
        elseif nextState == 4 then
            set pending = pending+1
        endif
    endmethod

    private static method track takes unit u returns integer
        local integer slot
        if u == null then
            call error()
            return 0
        endif
        set slot = index[GetHandleId(u)]
        if slot != 0 then
            return slot
        endif
        if tracked == LIMIT then
            set omitted = omitted+1
            set alarms = alarms+1
            call touch()
            return 0
        endif
        set tracked = tracked+1
        set slot = tracked
        set units[slot] = u
        set state[slot] = 0
        set deadline[slot] = 0.
        set warned[slot] = false
        set index[GetHandleId(u)] = slot
        if tracked > peakTracked then
            set peakTracked = tracked
        endif
        return slot
    endmethod

    // Called exactly once by the recycler initializer, then once per preload.
    static method configure takes integer slots returns nothing
        set capacity = slots
        call touch()
    endmethod
    static method preload takes unit u returns nothing
        local integer slot = track(u)
        set preloadTotal = preloadTotal+1
        if slot != 0 then
            call changeState(slot,1)
        endif
        call touch()
    endmethod

    static method acquire takes unit u, boolean reused returns nothing
        local integer slot = track(u)
        if reused then
            set reusedTotal = reusedTotal+1
        else
            set newTotal = newTotal+1
        endif
        if slot != 0 then
            call changeState(slot,2)
            set deadline[slot] = 0.
        endif
        call touch()
    endmethod

    static method returned takes unit u, boolean stored, real duration returns nothing
        local integer slot = index[GetHandleId(u)]
        if slot == 0 then
            set adoptedTotal = adoptedTotal+1
            set slot = track(u)
        endif
        if slot != 0 then
            if stored then
                call changeState(slot,1)
            else
                call changeState(slot,4)
            endif
            set deadline[slot] = TimerGetElapsed(clock)+duration
        endif
        call touch()
    endmethod

    static method delay takes unit u, real duration returns nothing
        local integer slot = index[GetHandleId(u)]
        if slot != 0 then
            call changeState(slot,3)
            set deadline[slot] = TimerGetElapsed(clock)+duration
        endif
        call touch()
    endmethod

    static method invalidReturn takes nothing returns nothing
        set invalid = invalid+1
        set alarms = alarms+1
        call touch()
    endmethod

    static method allocated takes integer node returns nothing
        // Classic arrays also support the core's last valid node ID, 8191.
        // LIMIT applies only to the separate unit-handle tracking table.
        if node < 1 or node > 8191 then
            set omitted = omitted+1
            call error()
            return
        endif
        if nodeSlot[node] != 0 then
            call error()
            return
        endif
        set active = active+1
        set created = created+1
        set nodes[active] = node
        set nodeSlot[node] = active
        set born[node] = TimerGetElapsed(clock)
        if active > peakActive then
            set peakActive = active
        endif
        call touch()
    endmethod

    static method released takes integer node returns nothing
        local integer slot = nodeSlot[node]
        if slot == 0 then
            call error()
            return
        endif
        set nodes[slot] = nodes[active]
        set nodeSlot[nodes[slot]] = slot
        set nodeSlot[node] = 0
        set nodes[active] = 0
        set active = active-1
        set retired = retired+1
        call touch()
    endmethod

    // Public for fixtures; the live observer also calls it once per second.
    static method inspect takes nothing returns nothing
        local integer i = 1
        local integer age
        local integer bad = 0
        local real now = TimerGetElapsed(clock)
        set oldestSeconds = 0
        set overdue = 0
        set inconsistent = 0
        loop
            exitwhen i > active
            set age = R2I(now-born[nodes[i]])
            if age > oldestSeconds then
                set oldestSeconds = age
            endif
            set i = i+1
        endloop
        set i = 1
        loop
            exitwhen i > tracked
            if GetUnitTypeId(units[i]) == 0 or GetWidgetLife(units[i]) <= 0.405 then
                if state[i] == 4 then
                    set disposed = disposed+1
                else
                    set lost = lost+1
                    set alarms = alarms+1
                endif
                call index.remove(GetHandleId(units[i]))
                call changeState(i,0)
                if i != tracked then
                    set units[i] = units[tracked]
                    set state[i] = state[tracked]
                    set deadline[i] = deadline[tracked]
                    set warned[i] = warned[tracked]
                    set index[GetHandleId(units[i])] = i
                endif
                set units[tracked] = null
                set state[tracked] = 0
                set deadline[tracked] = 0.
                set warned[tracked] = false
                set tracked = tracked-1
            else
                set bad = 0
                if (state[i] == 3 or state[i] == 4) and now > deadline[i]+GRACE then
                    set overdue = overdue+1
                    set bad = 1
                endif
                if state[i] == 1 and GetUnitUserData(units[i]) != -1 then
                    set inconsistent = inconsistent+1
                    set bad = 1
                endif
                if bad == 1 and not warned[i] then
                    set warned[i] = true
                    set alarms = alarms+1
                endif
                set i = i+1
            endif
        endloop
        if active != created-retired or tracked != pooled+borrowed+deferred+pending then
            set inconsistent = inconsistent+1
        endif
        set checks = checks+1
        call touch()
    endmethod

    private static method watch takes nothing returns nothing
        call inspect()
    endmethod

    private static method toggle takes nothing returns nothing
        local integer id = GetPlayerId(GetTriggerPlayer())
        set hidden[id] = not hidden[id]
        if GetLocalPlayer() == GetTriggerPlayer() then
            // Visual only: no handle creation, game-state writes or RNG here.
            call MultiboardDisplay(board,not hidden[id])
        endif
    endmethod

    static method initialize takes nothing returns nothing
        local trigger command = CreateTrigger()
        local integer i = 0
        set index = Table.create()
        call TimerStart(clock,1000000.,false,null)
        call TimerStart(watcher,1.,true,function thistype.watch)
        loop
            exitwhen i == bj_MAX_PLAYERS
            call TriggerRegisterPlayerChatEvent(command,Player(i),"-misiles",true)
            set i = i+1
        endloop
        call TriggerAddAction(command,function thistype.toggle)
        set command = null
        set initialized = true
        call touch()
    endmethod
endstruct

private function Init takes nothing returns nothing
    call MissileStats.initialize()
endfunction
endlibrary
