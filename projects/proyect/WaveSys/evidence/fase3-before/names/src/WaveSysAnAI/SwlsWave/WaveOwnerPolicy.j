// Politica de duenos de oleada del mapa: owners por defecto Player(8..12), escalado por jugadores activos
// y ayudantes para crear unidades desde esos owners. Usa solo la API publica del nucleo WaveTest.
library WaveOwnerPolicy requires WaveTest, WaveSpawnFx
    globals
        constant integer WAVE_DEFAULT_OWNER_MIN = 8
        constant integer WAVE_DEFAULT_OWNER_MAX = 12
        // Porcentaje adicional por jugador de cada instancia; el token evita heredarlo en un id reciclado.
        private real array PerPlayerPct
        private integer array PerPlayerPctToken
    endglobals

    function WaveCountPlayingUsers takes nothing returns integer
        local integer i = 0
        local integer count = 0
        local player p
        loop
            exitwhen i >= bj_MAX_PLAYER_SLOTS
            set p = Player(i)
            if (GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING) and (GetPlayerController(p) == MAP_CONTROL_USER) then
                set count = count + 1
            endif
            set i = i + 1
        endloop
        set p = null
        if count < 1 then
            set count = 1
        endif
        return count
    endfunction

    function WaveIsDefaultOwnerPlayerId takes integer pid returns boolean
        return (pid >= WAVE_DEFAULT_OWNER_MIN) and (pid <= WAVE_DEFAULT_OWNER_MAX) and (pid < bj_MAX_PLAYER_SLOTS)
    endfunction

    function WaveGetDefaultOwnerCount takes nothing returns integer
        return WAVE_DEFAULT_OWNER_MAX - WAVE_DEFAULT_OWNER_MIN + 1
    endfunction

    function WaveSetAdditionalPerPlayerPercent takes Wave w, real pct returns nothing
        if w == 0 then
            return
        endif
        if pct < 0.0 then
            set pct = 0.0
        endif
        set PerPlayerPct[w] = pct
        set PerPlayerPctToken[w] = w.waveToken
    endfunction

    function WaveGetAdditionalPerPlayerPercent takes Wave w returns real
        if w != 0 and PerPlayerPctToken[w] == w.waveToken then
            return PerPlayerPct[w]
        endif
        return 100.0
    endfunction

    function WaveComputeScaledAmount takes integer baseAmount, integer playersCount, real pct returns integer
        local real addPerPlayer
        local integer extraPlayers
        local integer amount
        if baseAmount <= 0 then
            return 0
        endif
        if playersCount < 1 then
            set playersCount = 1
        endif
        if pct < 0.0 then
            set pct = 0.0
        endif
        set extraPlayers = playersCount - 1
        if extraPlayers <= 0 then
            return baseAmount
        endif
        set addPerPlayer = I2R(baseAmount) * (pct * 0.01)
        set amount = baseAmount + R2I(I2R(extraPlayers) * addPerPlayer + 0.5)
        if amount < baseAmount then
            set amount = baseAmount
        endif
        return amount
    endfunction

    private function ScaledAmount takes Wave w, integer baseAmount, real pct, boolean scaleWithActivePlayers returns integer
        if scaleWithActivePlayers then
            return WaveComputeScaledAmount(baseAmount, WaveCountPlayingUsers(), pct)
        endif
        return baseAmount
    endfunction

    private function AddForDefaultOwners takes Wave w, integer slotGroupId, integer uId, integer baseAmount, real pct, boolean scaleWithActivePlayers, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss, integer aiProfileId, integer laneId, integer behaviorFlags, real threatWeight returns nothing
        local integer ownerId = WAVE_DEFAULT_OWNER_MIN
        local integer amount = ScaledAmount(w, baseAmount, pct, scaleWithActivePlayers)
        if w == 0 then
            return
        endif
        loop
            exitwhen ownerId > WAVE_DEFAULT_OWNER_MAX
            call w.addSlotGrouped(slotGroupId, uId, amount, lim, prio, fxId, killGate, isBoss, Player(ownerId), aiProfileId, laneId, behaviorFlags, threatWeight)
            set ownerId = ownerId + 1
        endloop
    endfunction

    // Un slot por cada owner por defecto; scaleWithActivePlayers solo decide si escala la cantidad.
    function WaveAddSlotByPlayers takes Wave w, integer uId, integer baseAmount, boolean scaleWithActivePlayers, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss returns nothing
        call AddForDefaultOwners(w, 0, uId, baseAmount, WaveGetAdditionalPerPlayerPercent(w), scaleWithActivePlayers, lim, prio, fxId, killGate, isBoss, 0, 0, 0, 1.0)
    endfunction

    function WaveAddSlotByPlayersPct takes Wave w, integer uId, integer baseAmount, real pct, boolean scaleWithActivePlayers, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss returns nothing
        call AddForDefaultOwners(w, 0, uId, baseAmount, pct, scaleWithActivePlayers, lim, prio, fxId, killGate, isBoss, 0, 0, 0, 1.0)
    endfunction

    function WaveAddSlotExByPlayers takes Wave w, integer uId, integer baseAmount, boolean scaleWithActivePlayers, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss, integer aiProfileId, integer laneId, integer behaviorFlags, real threatWeight returns nothing
        call AddForDefaultOwners(w, 0, uId, baseAmount, WaveGetAdditionalPerPlayerPercent(w), scaleWithActivePlayers, lim, prio, fxId, killGate, isBoss, aiProfileId, laneId, behaviorFlags, threatWeight)
    endfunction

    function WaveUpsertSlotExByPlayers takes Wave w, integer slotGroupId, integer uId, integer baseAmount, boolean scaleWithActivePlayers, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss, integer aiProfileId, integer laneId, integer behaviorFlags, real threatWeight returns nothing
        if slotGroupId < 0 then
            set slotGroupId = 0
        endif
        call AddForDefaultOwners(w, slotGroupId, uId, baseAmount, WaveGetAdditionalPerPlayerPercent(w), scaleWithActivePlayers, lim, prio, fxId, killGate, isBoss, aiProfileId, laneId, behaviorFlags, threatWeight)
    endfunction

    // Variantes por owner puntual.
    function WaveAddSlotByPlayer takes Wave w, integer uId, integer baseAmount, boolean scaleWithActivePlayers, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss, player p returns nothing
        if w != 0 then
            call w.addSlotGrouped(0, uId, ScaledAmount(w, baseAmount, WaveGetAdditionalPerPlayerPercent(w), scaleWithActivePlayers), lim, prio, fxId, killGate, isBoss, p, 0, 0, 0, 1.0)
        endif
    endfunction

    function WaveAddSlotByPlayerPct takes Wave w, integer uId, integer baseAmount, real pct, boolean scaleWithActivePlayers, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss, player p returns nothing
        if w != 0 then
            call w.addSlotGrouped(0, uId, ScaledAmount(w, baseAmount, pct, scaleWithActivePlayers), lim, prio, fxId, killGate, isBoss, p, 0, 0, 0, 1.0)
        endif
    endfunction

    function WaveAddSlotExByPlayer takes Wave w, integer uId, integer baseAmount, boolean scaleWithActivePlayers, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss, player p, integer aiProfileId, integer laneId, integer behaviorFlags, real threatWeight returns nothing
        if w != 0 then
            call w.addSlotGrouped(0, uId, ScaledAmount(w, baseAmount, WaveGetAdditionalPerPlayerPercent(w), scaleWithActivePlayers), lim, prio, fxId, killGate, isBoss, p, aiProfileId, laneId, behaviorFlags, threatWeight)
        endif
    endfunction

    function WaveUpsertSlotExByPlayer takes Wave w, integer slotGroupId, integer uId, integer baseAmount, boolean scaleWithActivePlayers, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss, player p, integer aiProfileId, integer laneId, integer behaviorFlags, real threatWeight returns nothing
        if slotGroupId < 0 then
            set slotGroupId = 0
        endif
        if w != 0 then
            call w.addSlotGrouped(slotGroupId, uId, ScaledAmount(w, baseAmount, WaveGetAdditionalPerPlayerPercent(w), scaleWithActivePlayers), lim, prio, fxId, killGate, isBoss, p, aiProfileId, laneId, behaviorFlags, threatWeight)
        endif
    endfunction

    // Owner por defecto con menos activas que no haya llegado al limite por owner; -1 si ninguno.
    function WavePickDefaultOwnerPid takes Wave w returns integer
        local integer pid = WAVE_DEFAULT_OWNER_MIN
        local integer bestPid = -1
        local integer bestCount = 0
        if w == 0 then
            return -1
        endif
        loop
            exitwhen pid > WAVE_DEFAULT_OWNER_MAX
            if pid < WAVE_TRACKED_PLAYER_SLOTS then
                if w.activeByPlayer[pid] < w.perPlayerLimit then
                    if bestPid < 0 or w.activeByPlayer[pid] < bestCount then
                        set bestPid = pid
                        set bestCount = w.activeByPlayer[pid]
                    endif
                endif
            endif
            set pid = pid + 1
        endloop
        return bestPid
    endfunction

    function WaveCanSpawnUnitFromDefaultOwnerPid takes unit source, integer pid returns boolean
        local Wave w
        if source == null or GetUnitTypeId(source) == 0 then
            return false
        endif
        if not WaveIsDefaultOwnerPlayerId(pid) or pid >= WAVE_TRACKED_PLAYER_SLOTS then
            return false
        endif
        set w = GetWaveByUnit(source)
        if w == 0 or w.isDestroyed then
            return false
        endif
        return w.activeByPlayer[pid] < w.perPlayerLimit
    endfunction

    // Crea la unidad (con efectos heredados del origen); registrarla en la Wave es un segundo paso explicito.
    function WaveSpawnUnitFromDefaultOwnerPid takes unit source, integer unitTypeId, integer pid, real x, real y returns unit
        local unit summoned
        local integer fxId
        if unitTypeId == 0 then
            return null
        endif
        if not WaveCanSpawnUnitFromDefaultOwnerPid(source, pid) then
            return null
        endif
        set fxId = WaveGetSpawnFxIdForUnit(source)
        call WaveSpawnFxIn(fxId, x, y)
        set summoned = CreateUnit(Player(pid), unitTypeId, x, y, 270.0)
        if summoned == null or GetUnitTypeId(summoned) == 0 then
            set summoned = null
            return null
        endif
        call WaveSpawnFxOut(fxId, summoned)
        call WaveSetSpawnFxIdForUnit(summoned, fxId)
        return summoned
    endfunction

    function WaveSpawnUnitFromDefaultOwners takes unit source, integer unitTypeId, real x, real y returns unit
        local Wave w
        local integer pid
        if source == null or GetUnitTypeId(source) == 0 or unitTypeId == 0 then
            return null
        endif
        set w = GetWaveByUnit(source)
        if w == 0 or w.isDestroyed then
            return null
        endif
        set pid = WavePickDefaultOwnerPid(w)
        if pid < 0 then
            return null
        endif
        return WaveSpawnUnitFromDefaultOwnerPid(source, unitTypeId, pid, x, y)
    endfunction
endlibrary
