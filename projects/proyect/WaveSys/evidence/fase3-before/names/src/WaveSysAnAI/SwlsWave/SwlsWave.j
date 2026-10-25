
library WaveTest initializer Init requires Table, TimerUtils
    /*
    ==========================================================================
    WaveTest (SwlsWave) - nucleo de oleadas
    ==========================================================================

    Una Wave es una instancia independiente de aparicion PvE con su propio
    temporizador, slots, reservas, contadores y eventos. El nucleo solo depende
    de Table y TimerUtils; la partida (descansos, tablero, jugadores, efectos)
    se conecta desde fuera escuchando eventos.

    FLUJO
    1) set w = Wave.create(perPlayerLimit, nearChancePercent, intervalSec, waveIndex, waveTotal)
    2) call w.addPoint(x, y) / call w.addNearUnit(u)
    3) call w.addSlot(...) / w.addSlotEx(...) / w.addSlotGrouped(slotGroupId, ...)
    4) call w.start()

    SLOTS
    uId, amount, lim (activas simultaneas del slot), prio (mayor sale antes;
    cualquier entero), fxId (dato opaco para la presentacion, >= 0), killGate
    (-1 sin bloqueo; >= 0 exige totalKilled <= killGate), isBoss, owner,
    aiProfileId, laneId, behaviorFlags, threatWeight.
    addSlotGrouped amplia un slot existente del mismo grupo/owner/tipo.
    Duenos por defecto y escalado por jugadores: libreria WaveOwnerPolicy.

    EVENTOS (RegisterWave<Evento>Event)
    Start, Pause, Resume, Finish, Reserve, Spawn, Death, External.
    Contexto: GetWaveEventWave/Unit/Killer/Slot, IsWaveEventBoss/External/Retired,
    GetWaveEventUnitTypeId, GetWaveEventX/Y (Reserve).
    - Death tambien cubre la retirada sin muerte (IsWaveEventRetired, killer null).
    - Finish: fin natural o fin de terminate; destroyWave directo no lo emite.
    - Un evento disparado dentro de otro no altera el contexto del exterior.

    PAUSA: congela nuevas reservas y las ya creadas (conservan su tiempo restante).
    */

    globals
        constant boolean WAVE_DEBUG_ENABLED = false
        constant string WAVE_DEBUG_PREFIX = "[WaveDebug]"

        Table WaveByUnit = 0
        Table WaveByTimer = 0
        Table SlotByUnit = 0
        Table ExternalIsBoss = 0
        Table WaveActiveUnitByKey = 0
        Table WaveActivePosByUnit = 0
        Table WaveAffiliateWaveByUnit = 0
        Table WaveAffiliateModeByUnit = 0
        Table WaveExternalOwnerPidByUnit = 0

        constant integer WAVE_MAX_SLOTS = 100
        constant integer WAVE_MAX_POINTS = 100
        constant integer WAVE_MAX_NEAR_UNITS = 100
        constant integer WAVE_TRACKED_PLAYER_SLOTS = 20
        constant integer WAVE_ACTIVE_STRIDE = 4096

        trigger WaveEvtStart = null
        trigger WaveEvtPause = null
        trigger WaveEvtResume = null
        trigger WaveEvtFinish = null
        trigger WaveEvtSpawn = null
        trigger WaveEvtDeath = null
        trigger WaveEvtExternal = null
        trigger WaveEvtReserve = null

        integer WaveEventWaveId = 0
        unit WaveEventUnit = null
        unit WaveEventKiller = null
        integer WaveEventSlotId = 0
        boolean WaveEventIsBoss = false
        boolean WaveEventIsExternal = false
        boolean WaveEventIsRetired = false
        integer WaveEventUnitTypeId = 0
        real WaveEventX = 0.
        real WaveEventY = 0.
        // Tipo registrado: permite filtrar una retirada aunque el motor ya haya eliminado la unidad.
        Table WaveUnitTypeByUnit = 0
        // Unidades cuya salida se esta procesando: un listener de Death no puede liberarlas otra vez.
        Table WaveReleasingByUnit = 0

        integer WaveTokenSeed = 0
    endglobals

    private function WavePushEventContext takes integer w, unit u, unit killer, integer s, boolean isBoss, boolean isExternal returns nothing
        set WaveEventWaveId = w
        set WaveEventUnit = u
        set WaveEventKiller = killer
        set WaveEventSlotId = s
        set WaveEventIsBoss = isBoss
        set WaveEventIsExternal = isExternal
    endfunction


    function WaveDebugBoolToInt takes boolean b returns integer
        if b then
            return 1
        endif
        return 0
    endfunction

    function WaveDebugUnitSummary takes unit u returns string
        local integer hid
        local integer ownerPid
        if u == null then
            return "null"
        endif
        set hid = GetHandleId(u)
        set ownerPid = GetPlayerId(GetOwningPlayer(u))
        return GetUnitName(u) + " ut=" + I2S(GetUnitTypeId(u)) + " hid=" + I2S(hid) + " ownerPid=" + I2S(ownerPid)
    endfunction

    function WaveDebugLog takes string msg returns nothing
        if WAVE_DEBUG_ENABLED then
            call BJDebugMsg(WAVE_DEBUG_PREFIX + " " + msg)
        endif
    endfunction

    function WaveDeathDebugContextSummary takes nothing returns string
        return "w=" + I2S(WaveEventWaveId) + " unit=" + WaveDebugUnitSummary(WaveEventUnit) + " killer=" + WaveDebugUnitSummary(WaveEventKiller) + " slot=" + I2S(WaveEventSlotId) + " external=" + I2S(WaveDebugBoolToInt(WaveEventIsExternal)) + " boss=" + I2S(WaveDebugBoolToInt(WaveEventIsBoss))
    endfunction

    private function WaveExecEvent takes trigger t returns nothing
        local integer waveId
        local integer slotId
        local unit eventUnit
        local unit eventKiller
        local boolean eventBoss
        local boolean eventExternal
        if t != null then
            if WAVE_DEBUG_ENABLED and t == WaveEvtDeath then
                set waveId = WaveEventWaveId
                set slotId = WaveEventSlotId
                set eventUnit = WaveEventUnit
                set eventKiller = WaveEventKiller
                set eventBoss = WaveEventIsBoss
                set eventExternal = WaveEventIsExternal
                call WaveDebugLog("WaveExecEvent enter WaveEvtDeath w=" + I2S(waveId) + " unit=" + WaveDebugUnitSummary(eventUnit) + " killer=" + WaveDebugUnitSummary(eventKiller) + " slot=" + I2S(slotId) + " external=" + I2S(WaveDebugBoolToInt(eventExternal)) + " boss=" + I2S(WaveDebugBoolToInt(eventBoss)))
            endif
            call TriggerExecute(t)
            if WAVE_DEBUG_ENABLED and t == WaveEvtDeath then
                call WaveDebugLog("WaveExecEvent exit WaveEvtDeath w=" + I2S(waveId) + " unit=" + WaveDebugUnitSummary(eventUnit) + " killer=" + WaveDebugUnitSummary(eventKiller) + " slot=" + I2S(slotId) + " external=" + I2S(WaveDebugBoolToInt(eventExternal)) + " boss=" + I2S(WaveDebugBoolToInt(eventBoss)))
            endif
            set eventUnit = null
            set eventKiller = null
        endif
    endfunction

    // Despacha un evento y despues restaura el contexto exterior: un listener puede disparar otro evento
    // (p. ej. Start -> pause) y los listeners siguientes del evento exterior deben conservar su contexto.
    private function WaveDispatchEvent takes trigger t, integer w, unit u, unit killer, integer s, boolean isBoss, boolean isExternal, boolean retired, integer unitTypeId, real x, real y returns nothing
        local integer outerWave = WaveEventWaveId
        local unit outerUnit = WaveEventUnit
        local unit outerKiller = WaveEventKiller
        local integer outerSlot = WaveEventSlotId
        local boolean outerBoss = WaveEventIsBoss
        local boolean outerExternal = WaveEventIsExternal
        local boolean outerRetired = WaveEventIsRetired
        local integer outerType = WaveEventUnitTypeId
        local real outerX = WaveEventX
        local real outerY = WaveEventY
        call WavePushEventContext(w, u, killer, s, isBoss, isExternal)
        set WaveEventIsRetired = retired
        set WaveEventUnitTypeId = unitTypeId
        set WaveEventX = x
        set WaveEventY = y
        call WaveExecEvent(t)
        call WavePushEventContext(outerWave, outerUnit, outerKiller, outerSlot, outerBoss, outerExternal)
        set WaveEventIsRetired = outerRetired
        set WaveEventUnitTypeId = outerType
        set WaveEventX = outerX
        set WaveEventY = outerY
        set outerUnit = null
        set outerKiller = null
    endfunction

    private function WaveFireStart takes integer w returns nothing
        call WaveDispatchEvent(WaveEvtStart, w, null, null, 0, false, false, false, 0, 0., 0.)
    endfunction

    private function WaveFirePause takes integer w returns nothing
        call WaveDispatchEvent(WaveEvtPause, w, null, null, 0, false, false, false, 0, 0., 0.)
    endfunction

    private function WaveFireResume takes integer w returns nothing
        call WaveDispatchEvent(WaveEvtResume, w, null, null, 0, false, false, false, 0, 0., 0.)
    endfunction

    private function WaveFireFinish takes integer w returns nothing
        call WaveDispatchEvent(WaveEvtFinish, w, null, null, 0, false, false, false, 0, 0., 0.)
    endfunction

    private function WaveFireSpawn takes integer w, unit u, integer s, boolean isBoss, boolean isExternal returns nothing
        call WaveDispatchEvent(WaveEvtSpawn, w, u, null, s, isBoss, isExternal, false, 0, 0., 0.)
    endfunction

    // Salida de una entidad: muerte (retired=false) o retirada sin muerte (retired=true, killer=null).
    private function WaveFireDeath takes integer w, unit u, unit killer, integer s, boolean isBoss, boolean isExternal, boolean retired, integer unitTypeId returns nothing
        call WaveDispatchEvent(WaveEvtDeath, w, u, killer, s, isBoss, isExternal, retired, unitTypeId, 0., 0.)
    endfunction

    private function WaveFireExternal takes integer w, unit u, integer s, boolean isBoss, boolean isExternal returns nothing
        call WaveDispatchEvent(WaveEvtExternal, w, u, null, s, isBoss, isExternal, false, 0, 0., 0.)
    endfunction

    // Reserva creada (antes de materializar): la presentacion puede marcar la posicion.
    private function WaveFireReserve takes integer w, integer s, boolean isBoss, real x, real y returns nothing
        call WaveDispatchEvent(WaveEvtReserve, w, null, null, s, isBoss, false, false, 0, x, y)
    endfunction

    private function WaveHandleAffiliateDeath takes integer hid returns nothing
        local Wave aw
        local integer terminateMode = 0
        if WaveAffiliateWaveByUnit.has(hid) then
            set aw = Wave(WaveAffiliateWaveByUnit[hid])
            if WaveAffiliateModeByUnit.has(hid) then
                set terminateMode = WaveAffiliateModeByUnit[hid]
            endif
            call WaveAffiliateWaveByUnit.remove(hid)
            call WaveAffiliateModeByUnit.remove(hid)
            if (aw != 0) and (not aw.isDestroyed) then
                if aw.affiliateUnitHid == hid then
                    set aw.affiliateUnitHid = 0
                    set aw.affiliateTerminateMode = 0
                endif
                call aw.terminate(terminateMode == 1)
            endif
        endif
    endfunction

    //==================================================
    // Callback del timer
    //==================================================
    function Wave_onTick takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer hid = GetHandleId(t)
        local Wave w

        if WaveByTimer.has(hid) then
            set w = Wave(WaveByTimer[hid])
            call w.onTick() 
        endif
        set t = null
    endfunction

    //==================================================
    // Spawn
    //==================================================
    function PendingSpawn_execute takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local PendingSpawn ps = GetTimerData(t)
            local unit u

            if (ps == 0) then
                call ReleaseTimer(t)
                set t = null
                return
            endif
            // waveToken identifica la instancia: si no coincide, el id se reutilizo y ni la Wave ni ps.slot son de esta reserva.
            if (ps.wave == 0) or ps.wave.isDestroyed or (ps.wave.waveToken != ps.waveToken) then
                call ReleaseTimer(t)
                set ps.t = null
                call ps.destroy()
                set t = null
                return
            endif
            // Pausa (E09): la reserva queda congelada. pause() ya detiene estos temporizadores; esto cubre un disparo residual.
            if (ps.wave.pendingEpoch == ps.epoch) and ps.wave.isPaused and (not ps.wave.terminateRequested) then
                call TimerStart(t, 0.01, false, function PendingSpawn_execute)
                call PauseTimer(t)
                set t = null
                return
            endif
            call ps.wave.unlinkPending(ps)
            set ps.wave.pendingReservations = ps.wave.pendingReservations - 1
            // Misma instancia, epoca distinta: terminate cancelo las reservas anteriores.
            if ps.wave.pendingEpoch != ps.epoch then
                call ps.wave.cancelReservedSpawn(ps.slot, ps.pid, (not ps.wave.cancelPendingPermanently))
                call ps.wave.tryDestroyAfterTermination()
                call ReleaseTimer(t)
                set ps.t = null
                call ps.destroy()
                set t = null
                return
            endif

            set u = CreateUnit(ps.slot.owner, ps.slot.unitId, ps.x, ps.y, 270.0)
            if (u == null) or (GetUnitTypeId(u) == 0) then
                call ps.wave.cancelReservedSpawn(ps.slot, ps.pid, true)
                call ReleaseTimer(t)
                set ps.t = null
                call ps.destroy()
                set t = null
                set u = null
                return
            endif
            call ps.wave.registerWaveUnit(u, ps.slot, ps.slot.isBoss, false)

            call ReleaseTimer(t)
            set ps.t = null
            call ps.destroy()

            set t = null
            set u = null
    endfunction

    struct WaveSlot
        integer unitId
        integer remaining
        integer active
        integer limit
        integer priority
        integer fxId
        integer total
        boolean isBoss
        integer killGate
        player owner
        integer slotGroupId
        // Metadata IA (opcional)
        integer aiProfileId
        integer laneId
        integer behaviorFlags
        real threatWeight
    endstruct

    struct PendingSpawn
        Wave wave
        WaveSlot slot
        integer pid
        integer waveToken
        integer epoch
        PendingSpawn nextPending
        PendingSpawn prevPending
        real x
        real y
        timer t
    endstruct

    // Referencia del indice activo: un campo de struct conserva el handle aunque el motor elimine la unidad,
    // mientras que cargarla desde el hashtable devuelve null y no permitiria reconciliar la retirada.
    struct WaveEntityRef
        unit u
    endstruct

    struct Wave
        
        integer slotCount
        WaveSlot array slots[100]

        integer perPlayerLimit
        integer array activeByPlayer[20] 

        integer activeOnMap
        integer activeTrackedCount

        //Timer
        real interval 
        timer loopTimer

        integer pointCount
        real array pointX[100]
        real array pointY[100]

        // --- NUEVO: spawn cerca de unidad ---
        integer nearUnitChance   // 0–100
        integer nearUnitCount
        unit array nearUnits[100]

        // --- cache del punto elegido ---
        real spawnX
        real spawnY

        // --- Referenciales ---
        integer waveIndex
        integer waveTotal

        // --- Totales ---
        integer totalToSpawn

        integer totalUnits
        integer totalBosses

        // --- Dinámicos ---
        integer remainingToSpawn
        
        integer remainingUnits
        integer remainingBosses

        integer activeBosses
        integer activeUnits

        // Compatibilidad heredada: estos 3 campos representan "objetivos restantes".
        integer totalKilled
        integer totalKilledUnits
        integer totalKilledBoss

        // Contadores acumulados reales (IA/UI)
        integer killsDone
        integer killsDoneUnits
        integer killsDoneBoss

        boolean isRunning
        boolean isPaused
        boolean isFinishing
        boolean isDestroyed
        boolean terminateRequested
        boolean cancelPendingPermanently
        boolean finishEventFired
        integer affiliateUnitHid
        integer affiliateTerminateMode
        integer tickCounter
        integer waveToken
        integer pendingEpoch
        integer pendingReservations
        integer retiredCount
        integer untrackedOverflow
        // Reservas pendientes de esta instancia: pause/resume detienen y reanudan sus temporizadores.
        PendingSpawn pendingHead
        
        static method operator [] takes unit u returns thistype
            local integer hid
            if u == null then
                return 0
            endif
            set hid = GetHandleId(u)
            if WaveByUnit.has(hid) then
                return WaveByUnit[hid]
            endif
            return 0
        endmethod 

        static method create takes integer PlayerLim, integer nearChance, real sec, integer wIndex, integer wTotal returns Wave
            local Wave this = Wave.allocate()
            local integer i = 0

            set WaveTokenSeed = WaveTokenSeed + 1
            set this.waveToken = WaveTokenSeed
            set this.pendingEpoch = 0
            set this.pendingReservations = 0
            set this.retiredCount = 0
            set this.untrackedOverflow = 0
            set this.pendingHead = 0
            set this.isDestroyed = false
            set this.waveIndex = wIndex
            set this.waveTotal = wTotal

            set this.pointCount = 0
            if nearChance < 0 then
                set nearChance = 0
            elseif nearChance > 100 then
                set nearChance = 100
            endif
            set this.nearUnitChance = nearChance
            set this.nearUnitCount  = 0
            set this.slotCount = 0
            set this.activeOnMap = 0
            set this.activeTrackedCount = 0
            set this.perPlayerLimit = PlayerLim
            if this.perPlayerLimit < 1 then
                set this.perPlayerLimit = 1
            endif
            if sec <= 0.0 then
                set sec = 0.25
            endif
            set this.interval  = sec

            set this.totalToSpawn      = 0
            set this.totalUnits        = 0
            set this.totalBosses       = 0

            set this.remainingToSpawn  = 0
            set this.remainingUnits    = 0
            set this.remainingBosses   = 0

            set this.activeBosses      = 0
            set this.activeUnits       = 0

            set this.totalKilled       = 0
            set this.totalKilledUnits  = 0
            set this.totalKilledBoss   = 0

            set this.killsDone      = 0
            set this.killsDoneUnits = 0
            set this.killsDoneBoss  = 0

            set this.isRunning = false
            set this.isPaused = false
            set this.isFinishing = false
            set this.terminateRequested = false
            set this.cancelPendingPermanently = false
            set this.finishEventFired = false
            set this.affiliateUnitHid = 0
            set this.affiliateTerminateMode = 0
            set this.tickCounter = 0

            loop
                exitwhen i >= WAVE_TRACKED_PLAYER_SLOTS
                set this.activeByPlayer[i] = 0
                set i = i + 1
            endloop

            return this
        endmethod

        private method findSlotByGroupForOwner takes integer slotGroupId, integer uId, boolean isBoss, player p returns WaveSlot
            local integer i = 0
            local WaveSlot s

            if slotGroupId <= 0 or p == null then
                return 0
            endif

            loop
                exitwhen i >= this.slotCount
                set s = this.slots[i]
                if s != 0 and s.slotGroupId == slotGroupId and s.owner == p and s.unitId == uId and s.isBoss == isBoss then
                    return s
                endif
                set i = i + 1
            endloop

            return 0
        endmethod

        private method extendSlotInternal takes WaveSlot s, integer amount returns nothing
            if s == 0 or amount <= 0 then
                return
            endif

            set s.remaining = s.remaining + amount
            set s.total = s.total + amount

            set this.totalToSpawn     = this.totalToSpawn + amount
            set this.remainingToSpawn = this.remainingToSpawn + amount
            set this.totalKilled      = this.totalKilled + amount

            if s.isBoss then
                set this.totalBosses     = this.totalBosses + amount
                set this.remainingBosses = this.remainingBosses + amount
                set this.totalKilledBoss = this.totalKilledBoss + amount
            else
                set this.totalUnits      = this.totalUnits + amount
                set this.remainingUnits  = this.remainingUnits + amount
                set this.totalKilledUnits = this.totalKilledUnits + amount
            endif

            call this.clampCoreCounters()
        endmethod

        // Agregar un tipo de unidad (base interna)
        private method addSlotInternal takes integer slotGroupId, integer uId, integer amount, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss, player p, integer aiProfileId, integer laneId, integer behaviorFlags, real threatWeight returns nothing  
            local WaveSlot s

            if this.isDestroyed or this.isFinishing or this.terminateRequested then
                return
            endif

            if slotGroupId > 0 then
                set s = this.findSlotByGroupForOwner(slotGroupId, uId, isBoss, p)
                if s != 0 then
                    call this.extendSlotInternal(s, amount)
                    return
                endif
            endif

            set s = WaveSlot.create()

            if this.slotCount >= WAVE_MAX_SLOTS then
                call s.destroy()
                return
            endif
            if (uId == 0) or (amount <= 0) or (p == null) then
                call s.destroy()
                return
            endif
            if lim < 1 then
                set lim = 1
            endif
            if fxId < 0 then
                set fxId = 0
            endif

            set s.unitId    = uId
            set s.remaining = amount
            set s.active    = 0
            set s.limit     = lim
            set s.owner     = p
            set s.priority = prio
            set s.fxId = fxId
            set s.killGate  = killGate

            set s.total     = amount
            set s.slotGroupId = slotGroupId
            
            set s.isBoss    = isBoss
            set s.aiProfileId = aiProfileId
            set s.laneId = laneId
            set s.behaviorFlags = behaviorFlags
            if threatWeight <= 0.0 then
                set threatWeight = 1.0
            endif
            set s.threatWeight = threatWeight

            set this.slots[this.slotCount] = s
            set this.slotCount = this.slotCount + 1

            // Global
            set this.totalToSpawn     = this.totalToSpawn + amount
            set this.remainingToSpawn = this.remainingToSpawn + amount

            set this.totalKilled     = this.totalKilled + amount

            if isBoss then
                // Boss
                set this.totalBosses     = this.totalBosses + amount
                set this.remainingBosses = this.remainingBosses + amount
                set this.totalKilledBoss     = this.totalKilledBoss + amount
            else
                // Unidades normales
                set this.totalUnits     = this.totalUnits + amount
                set this.remainingUnits = this.remainingUnits + amount
                set this.totalKilledUnits     = this.totalKilledUnits + amount
            endif
        endmethod

        // Agregar un tipo de unidad (compatibilidad actual)
        method addSlot takes integer uId, integer amount, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss, player p returns nothing
            call this.addSlotInternal(0, uId, amount, lim, prio, fxId, killGate, isBoss, p, 0, 0, 0, 1.0)
        endmethod

        // VersiÃ³n extendida para IA: perfil/carril/banderas/peso
        method addSlotEx takes integer uId, integer amount, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss, player p, integer aiProfileId, integer laneId, integer behaviorFlags, real threatWeight returns nothing
            call this.addSlotInternal(0, uId, amount, lim, prio, fxId, killGate, isBoss, p, aiProfileId, laneId, behaviorFlags, threatWeight)
        endmethod

        // Alta o ampliacion por grupo: con slotGroupId > 0 amplia el slot del mismo grupo/owner/tipo.
        method addSlotGrouped takes integer slotGroupId, integer uId, integer amount, integer lim, integer prio, integer fxId, integer killGate, boolean isBoss, player p, integer aiProfileId, integer laneId, integer behaviorFlags, real threatWeight returns nothing
            call this.addSlotInternal(slotGroupId, uId, amount, lim, prio, fxId, killGate, isBoss, p, aiProfileId, laneId, behaviorFlags, threatWeight)
        endmethod

        method registerWaveUnit takes unit u, WaveSlot s, boolean isBoss, boolean isExternal returns nothing
            local integer hid
            if (u == null) or (GetUnitTypeId(u) == 0) then
                return
            endif
            set hid = GetHandleId(u)
            set WaveByUnit[hid] = this
            set WaveUnitTypeByUnit[hid] = GetUnitTypeId(u)
            if s != 0 then
                set SlotByUnit[hid] = s
                call ExternalIsBoss.remove(hid)
            else
                call SlotByUnit.remove(hid)
                if isExternal then
                    if isBoss then
                        set ExternalIsBoss[hid] = 1
                    else
                        set ExternalIsBoss[hid] = 0
                    endif
                else
                    call ExternalIsBoss.remove(hid)
                endif
            endif
            call this.trackActiveUnit(u)
            call WaveFireSpawn(this, u, s, isBoss, isExternal)
            if isExternal then
                call WaveFireExternal(this, u, s, isBoss, true)
            endif
        endmethod

        method registerExternalUnit takes unit source, unit summoned, boolean isBoss returns nothing
            local integer srcId = GetHandleId(source)
            local integer summonedId = GetHandleId(summoned)
            local Wave w
            local integer ownerPid

            if (source == null) or (summoned == null) then
                call WaveDebugLog("registerExternalUnit reject reason=null_source_or_summoned source=" + WaveDebugUnitSummary(source) + " summoned=" + WaveDebugUnitSummary(summoned) + " boss=" + I2S(WaveDebugBoolToInt(isBoss)))
                return
            endif
            if GetUnitTypeId(summoned) == 0 then
                call WaveDebugLog("registerExternalUnit reject reason=summoned_type_zero source=" + WaveDebugUnitSummary(source) + " summoned=" + WaveDebugUnitSummary(summoned) + " boss=" + I2S(WaveDebugBoolToInt(isBoss)))
                return
            endif

            // El invocador NO pertenece a ninguna wave ? ignorar
            if not WaveByUnit.has(srcId) then
                call WaveDebugLog("registerExternalUnit reject reason=source_not_tracked source=" + WaveDebugUnitSummary(source) + " summoned=" + WaveDebugUnitSummary(summoned) + " boss=" + I2S(WaveDebugBoolToInt(isBoss)))
                return
            endif

            set w = Wave(WaveByUnit[srcId])
            if (w == 0) or w.isDestroyed then
                call WaveDebugLog("registerExternalUnit reject reason=wave_invalid source=" + WaveDebugUnitSummary(source) + " summoned=" + WaveDebugUnitSummary(summoned) + " wave=" + I2S(w) + " boss=" + I2S(WaveDebugBoolToInt(isBoss)))
                return
            endif

            // Seguridad extra: no doble registro
            if WaveByUnit.has(GetHandleId(summoned)) then
                call WaveDebugLog("registerExternalUnit reject reason=summoned_already_tracked source=" + WaveDebugUnitSummary(source) + " summoned=" + WaveDebugUnitSummary(summoned) + " wave=" + I2S(w) + " boss=" + I2S(WaveDebugBoolToInt(isBoss)))
                return
            endif

            set ownerPid = GetPlayerId(GetOwningPlayer(summoned))
            if (ownerPid >= 0) and (ownerPid < WAVE_TRACKED_PLAYER_SLOTS) then
                set w.activeByPlayer[ownerPid] = w.activeByPlayer[ownerPid] + 1
            endif

            set w.activeOnMap = w.activeOnMap + 1
            set w.totalToSpawn = w.totalToSpawn + 1
            set w.totalKilled = w.totalKilled + 1

            if isBoss then
                //set w.remainingBosses = w.remainingBosses + 1
                set w.totalBosses = w.totalBosses + 1
                set w.totalKilledBoss = w.totalKilledBoss + 1
                set w.activeBosses    = w.activeBosses + 1
            else
                //set w.remainingUnits = w.remainingUnits + 1
                set w.totalUnits = w.totalUnits + 1
                set w.totalKilledUnits = w.totalKilledUnits + 1
                set w.activeUnits    = w.activeUnits + 1
            endif

            if ownerPid >= 0 then
                set WaveExternalOwnerPidByUnit[summonedId] = ownerPid
            endif

            call w.registerWaveUnit(summoned, 0, isBoss, true)
            call WaveDebugLog("registerExternalUnit wave=" + I2S(w) + " source=" + WaveDebugUnitSummary(source) + " summoned=" + WaveDebugUnitSummary(summoned) + " ownerPid=" + I2S(ownerPid) + " external=1 boss=" + I2S(WaveDebugBoolToInt(isBoss)))

        endmethod


        method addPoint takes real x, real y returns nothing
            if this.pointCount >= WAVE_MAX_POINTS then
                return
            endif
            set this.pointX[this.pointCount] = x
            set this.pointY[this.pointCount] = y
            set this.pointCount = this.pointCount + 1
        endmethod

        method addNearUnit takes unit u returns nothing
            if this.nearUnitCount >= WAVE_MAX_NEAR_UNITS then
                return
            endif
            if (u == null) or (GetUnitTypeId(u) == 0) then
                return
            endif
            set this.nearUnits[this.nearUnitCount] = u
            set this.nearUnitCount = this.nearUnitCount + 1
        endmethod

        method clearAffiliateUnit takes nothing returns nothing
            if this.affiliateUnitHid <= 0 then
                return
            endif
            if WaveAffiliateWaveByUnit.has(this.affiliateUnitHid) and (WaveAffiliateWaveByUnit[this.affiliateUnitHid] == this) then
                call WaveAffiliateWaveByUnit.remove(this.affiliateUnitHid)
                call WaveAffiliateModeByUnit.remove(this.affiliateUnitHid)
            endif
            set this.affiliateUnitHid = 0
            set this.affiliateTerminateMode = 0
        endmethod

        // Vincula esta wave a una unidad externa.
        // Cuando esa unidad muera, la wave se termina:
        //   forceKillOnDeath = false -> terminate(false)
        //   forceKillOnDeath = true  -> terminate(true)
        method setAffiliateUnit takes unit anchor, boolean forceKillOnDeath returns nothing
            local integer hid
            local Wave oldWave

            call this.clearAffiliateUnit()
            if (anchor == null) or (GetUnitTypeId(anchor) == 0) then
                return
            endif

            set hid = GetHandleId(anchor)
            if WaveAffiliateWaveByUnit.has(hid) then
                set oldWave = Wave(WaveAffiliateWaveByUnit[hid])
                if (oldWave != 0) and (oldWave != this) then
                    set oldWave.affiliateUnitHid = 0
                    set oldWave.affiliateTerminateMode = 0
                endif
            endif

            set WaveAffiliateWaveByUnit[hid] = this
            if forceKillOnDeath then
                set WaveAffiliateModeByUnit[hid] = 1
                set this.affiliateTerminateMode = 1
            else
                set WaveAffiliateModeByUnit[hid] = 0
                set this.affiliateTerminateMode = 0
            endif
            set this.affiliateUnitHid = hid
        endmethod

        private method activeKey takes integer index returns integer
            return this*WAVE_ACTIVE_STRIDE + index
        endmethod

        private method trackActiveUnit takes unit u returns nothing
            local integer hid
            local integer index
            local WaveEntityRef ref
            if u == null then
                return
            endif
            if this.activeTrackedCount >= (WAVE_ACTIVE_STRIDE - 1) then
                // Fuera del indice no se puede reconciliar una retirada.
                set this.untrackedOverflow = this.untrackedOverflow + 1
                return
            endif
            set hid = GetHandleId(u)
            if WaveActivePosByUnit.has(hid) then
                return
            endif
            set index = this.activeTrackedCount + 1
            set this.activeTrackedCount = index
            set ref = WaveEntityRef.create()
            set ref.u = u
            set WaveActiveUnitByKey[this.activeKey(index)] = ref
            set WaveActivePosByUnit[hid] = index
        endmethod

        method untrackUnitByHandle takes integer hid returns nothing
            local integer index
            local integer last
            local integer key
            local integer movedKey
            local WaveEntityRef gone
            local WaveEntityRef moved
            if not WaveActivePosByUnit.has(hid) then
                return
            endif
            set index = WaveActivePosByUnit[hid]
            set last = this.activeTrackedCount
            if (index <= 0) or (index > last) then
                call WaveActivePosByUnit.remove(hid)
                return
            endif

            set key = this.activeKey(index)
            set movedKey = this.activeKey(last)
            set gone = WaveEntityRef(WaveActiveUnitByKey[key])
            if index != last then
                set moved = WaveEntityRef(WaveActiveUnitByKey[movedKey])
                set WaveActiveUnitByKey[key] = moved
                if moved != 0 then
                    set WaveActivePosByUnit[GetHandleId(moved.u)] = index
                endif
            endif

            call WaveActiveUnitByKey.remove(movedKey)
            call WaveActivePosByUnit.remove(hid)
            set this.activeTrackedCount = last - 1
            if gone != 0 then
                set gone.u = null
                call gone.destroy()
            endif
        endmethod

        method getActiveIndexedCount takes nothing returns integer
            return this.activeTrackedCount
        endmethod

        method getActiveIndexedUnit takes integer index returns unit
            local WaveEntityRef ref
            if (index < 1) or (index > this.activeTrackedCount) then
                return null
            endif
            set ref = WaveEntityRef(WaveActiveUnitByKey[this.activeKey(index)])
            if ref == 0 then
                return null
            endif
            return ref.u
        endmethod

        private method clampCoreCounters takes nothing returns nothing
            if this.activeOnMap < 0 then
                set this.activeOnMap = 0
            endif
            if this.activeUnits < 0 then
                set this.activeUnits = 0
            endif
            if this.activeBosses < 0 then
                set this.activeBosses = 0
            endif
            if this.remainingToSpawn < 0 then
                set this.remainingToSpawn = 0
            endif
            if this.remainingUnits < 0 then
                set this.remainingUnits = 0
            endif
            if this.remainingBosses < 0 then
                set this.remainingBosses = 0
            endif
            if this.totalToSpawn < 0 then
                set this.totalToSpawn = 0
            endif
            if this.totalUnits < 0 then
                set this.totalUnits = 0
            endif
            if this.totalBosses < 0 then
                set this.totalBosses = 0
            endif
            if this.totalKilled < 0 then
                set this.totalKilled = 0
            endif
            if this.totalKilledUnits < 0 then
                set this.totalKilledUnits = 0
            endif
            if this.totalKilledBoss < 0 then
                set this.totalKilledBoss = 0
            endif
        endmethod

        private method cancelSlotRemaining takes WaveSlot s returns nothing
            local integer canceled
            if s == 0 then
                return
            endif
            set canceled = s.remaining
            if canceled <= 0 then
                return
            endif
            set s.remaining = 0
            set this.remainingToSpawn = this.remainingToSpawn - canceled
            set this.totalToSpawn = this.totalToSpawn - canceled
            set this.totalKilled = this.totalKilled - canceled
            if s.isBoss then
                set this.remainingBosses = this.remainingBosses - canceled
                set this.totalBosses = this.totalBosses - canceled
                set this.totalKilledBoss = this.totalKilledBoss - canceled
            else
                set this.remainingUnits = this.remainingUnits - canceled
                set this.totalUnits = this.totalUnits - canceled
                set this.totalKilledUnits = this.totalKilledUnits - canceled
            endif
        endmethod

        private method cancelAllPendingSlots takes nothing returns nothing
            local integer i = 0
            loop
                exitwhen i >= this.slotCount
                call this.cancelSlotRemaining(this.slots[i])
                set i = i + 1
            endloop
            call this.clampCoreCounters()
        endmethod

        method cancelReservedSpawn takes WaveSlot s, integer pid, boolean restoreRemaining returns nothing
            if s == 0 then
                return
            endif

            set s.active = s.active - 1
            if s.active < 0 then
                set s.active = 0
            endif

            if (pid >= 0) and (pid < WAVE_TRACKED_PLAYER_SLOTS) then
                set this.activeByPlayer[pid] = this.activeByPlayer[pid] - 1
                if this.activeByPlayer[pid] < 0 then
                    set this.activeByPlayer[pid] = 0
                endif
            endif

            set this.activeOnMap = this.activeOnMap - 1
            if s.isBoss then
                set this.activeBosses = this.activeBosses - 1
            else
                set this.activeUnits = this.activeUnits - 1
            endif

            if restoreRemaining then
                set s.remaining = s.remaining + 1
                set this.remainingToSpawn = this.remainingToSpawn + 1
                if s.isBoss then
                    set this.remainingBosses = this.remainingBosses + 1
                else
                    set this.remainingUnits = this.remainingUnits + 1
                endif
            else
                set this.totalToSpawn = this.totalToSpawn - 1
                set this.totalKilled = this.totalKilled - 1
                if s.isBoss then
                    set this.totalBosses = this.totalBosses - 1
                    set this.totalKilledBoss = this.totalKilledBoss - 1
                else
                    set this.totalUnits = this.totalUnits - 1
                    set this.totalKilledUnits = this.totalKilledUnits - 1
                endif
            endif
            call this.clampCoreCounters()
        endmethod

        method tryDestroyAfterTermination takes nothing returns nothing
            if this.isDestroyed then
                return
            endif
            if this.terminateRequested and this.activeOnMap <= 0 then
                call this.fireFinishEventOnce()
                call this.destroyWave()
            endif
        endmethod

        private method killAllTrackedUnits takes nothing returns nothing
            local integer i = this.getActiveIndexedCount()
            local unit u
            loop
                exitwhen i < 1 or this.isDestroyed
                set u = this.getActiveIndexedUnit(i)
                if (u != null) and (GetUnitTypeId(u) != 0) and (not IsUnitType(u, UNIT_TYPE_DEAD)) then
                    call KillUnit(u)
                endif
                set i = i - 1
            endloop
            set u = null
        endmethod

        // modeKillAlive = false:
        //   cancela por completo lo pendiente y espera a que mueran las unidades vivas.
        // modeKillAlive = true:
        //   cancela pendiente y mata todas las unidades vivas de la instancia.
        method terminate takes boolean modeKillAlive returns nothing
            if this.isDestroyed then
                return
            endif
            // Reservas congeladas por una pausa: deben dispararse para cancelarse por epoca y drenar la instancia.
            if this.isPaused then
                call this.setPendingTimersPaused(false)
            endif
            set this.terminateRequested = true
            set this.cancelPendingPermanently = true
            set this.isRunning = false
            set this.isPaused = true
            set this.isFinishing = true

            // El temporizador sigue activo para reconciliar retiradas mientras se drena.
            call this.cancelAllPendingSlots()
            set this.pendingEpoch = this.pendingEpoch + 1

            if modeKillAlive then
                call this.killAllTrackedUnits()
            endif

            call this.tryDestroyAfterTermination()
        endmethod

        private method compactNearUnits takes nothing returns nothing
            local integer i = 0
            local integer write = 0
            local unit u
            loop
                exitwhen i >= this.nearUnitCount
                set u = this.nearUnits[i]
                if (u != null) and (GetUnitTypeId(u) != 0) then
                    set this.nearUnits[write] = u
                    set write = write + 1
                endif
                set i = i + 1
            endloop
            set this.nearUnitCount = write
            set u = null
        endmethod

        method getRandomPointIndex takes nothing returns integer
            if this.pointCount == 0 then
                call WaveDebugLog("getRandomPointIndex reject reason=no_points")
                return -1
            endif
            return GetRandomInt(0, this.pointCount - 1)
        endmethod

        method tryGetNearUnitPoint takes real radius returns boolean
            local integer tries = 10
            local integer index
            local unit u
            local real angle
            local real dist
            local real x
            local real y           

            if this.nearUnitCount == 0 then
                return false
            endif

            loop
                exitwhen tries <= 0

                set index = GetRandomInt(0, this.nearUnitCount - 1)
                set u = this.nearUnits[index]

                if u != null and GetUnitTypeId(u) != 0 and (not IsUnitType(u, UNIT_TYPE_DEAD)) then
                    set angle = GetRandomReal(0.0, 6.28318)
                    set dist  = GetRandomReal(64.0, radius)

                    set x = GetUnitX(u) + dist * Cos(angle)
                    set y = GetUnitY(u) + dist * Sin(angle)

                    // false = caminable
                    if not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
                        set this.spawnX = x
                        set this.spawnY = y
                        return true
                    endif
                endif

                set tries = tries - 1
            endloop

            return false
        endmethod

        method selectSpawnPoint takes real radius returns boolean
            local integer roll
            local integer pIndex

            set roll = GetRandomInt(1, 100)

            // Intentar spawn cerca de unidad
            if roll <= this.nearUnitChance then
                if this.tryGetNearUnitPoint(radius) then
                    return true
                endif
            endif

            // Fallback a puntos base
            set pIndex = this.getRandomPointIndex()
            if pIndex >= 0 then
                set this.spawnX = this.pointX[pIndex]
                set this.spawnY = this.pointY[pIndex]
                return true
            endif

            return false
        endmethod

        // Iniciar la wave
        method start takes nothing returns nothing
            // Una Wave terminada (aunque nunca arrancara) no vuelve a arrancar.
            if this.isDestroyed or this.terminateRequested or (this.loopTimer != null) then
                return
            endif
            set this.loopTimer = NewTimer()
            call SetTimerDebugTag(this.loopTimer, TIMER_DEBUG_TAG_WAVE_CORE)
            set WaveByTimer[GetHandleId(this.loopTimer)] = this
            call TimerStart(this.loopTimer, this.interval, true, function Wave_onTick)
            set this.isRunning = true
            set this.isPaused = false
            set this.isFinishing = false
            set this.tickCounter = 0
            call WaveFireStart(this)
        endmethod

        method unlinkPending takes PendingSpawn ps returns nothing
            if ps.prevPending != 0 then
                set ps.prevPending.nextPending = ps.nextPending
            elseif this.pendingHead == ps then
                set this.pendingHead = ps.nextPending
            endif
            if ps.nextPending != 0 then
                set ps.nextPending.prevPending = ps.prevPending
            endif
            set ps.nextPending = 0
            set ps.prevPending = 0
        endmethod

        // ResumeTimer conserva el tiempo restante de cada reserva congelada.
        private method setPendingTimersPaused takes boolean paused returns nothing
            local PendingSpawn ps = this.pendingHead
            loop
                exitwhen ps == 0
                if paused then
                    call PauseTimer(ps.t)
                else
                    call ResumeTimer(ps.t)
                endif
                set ps = ps.nextPending
            endloop
        endmethod

        method pause takes nothing returns nothing
            if this.isDestroyed or (not this.isRunning) or this.isPaused then
                return
            endif
            // El temporizador sigue activo: los ticks en pausa solo reconcilian retiradas.
            // Las reservas ya creadas tambien se congelan: ninguna unidad aparece hasta resume (E09).
            call this.setPendingTimersPaused(true)
            set this.isPaused = true
            call WaveFirePause(this)
        endmethod

        method resume takes nothing returns nothing
            if this.isDestroyed or (not this.isRunning) or (not this.isPaused) then
                return
            endif
            call this.setPendingTimersPaused(false)
            set this.isPaused = false
            call WaveFireResume(this)
        endmethod

        //==================================================
        private method isTrackedPid takes integer pid returns boolean
            return (pid >= 0) and (pid < WAVE_TRACKED_PLAYER_SLOTS)
        endmethod

        private method killGatePassed takes WaveSlot s returns boolean
            if s.killGate == -1 then
                return true
            endif
            return this.totalKilled <= s.killGate
        endmethod

        //==================================================
        // Elegir slot ()
        //==================================================
        method pickSlot takes nothing returns WaveSlot
            local integer i = 0
            local integer validCount = 0
            local integer pick
            local WaveSlot s
            local integer pid
            local integer maxPrio = 0
            // Cualquier prioridad entera es valida (tambien negativa): no usar -1 como centinela.
            local boolean found = false

            // 1. Encontrar prioridad más alta válida
            loop
                exitwhen i >= this.slotCount
                set s = this.slots[i]
                set pid = GetPlayerId(s.owner)

                if this.isTrackedPid(pid) and s.remaining > 0 and s.active < s.limit and this.activeByPlayer[pid] < this.perPlayerLimit then
                    if this.killGatePassed(s) then
                        if (not found) or (s.priority > maxPrio) then
                            set maxPrio = s.priority
                            set found = true
                        endif
                    endif
                endif

                set i = i + 1
            endloop

            if not found then
                return 0
            endif


            // 2. Contar slots con esa prioridad
            set i = 0
            loop
                exitwhen i >= this.slotCount
                set s = this.slots[i]
                set pid = GetPlayerId(s.owner)

                if this.isTrackedPid(pid) and s.priority == maxPrio and s.remaining > 0 and s.active < s.limit and this.activeByPlayer[pid] < this.perPlayerLimit then
                    if this.killGatePassed(s) then
                        set validCount = validCount + 1
                    endif
                endif

                set i = i + 1
            endloop

            // 3. Elegir random entre ellos
            if validCount <= 0 then
                return 0
            endif
            set pick = GetRandomInt(1, validCount)

            set i = 0
            loop
                exitwhen i >= this.slotCount
                set s = this.slots[i]
                set pid = GetPlayerId(s.owner)

                if this.isTrackedPid(pid) and s.priority == maxPrio and s.remaining > 0 and s.active < s.limit and this.activeByPlayer[pid] < this.perPlayerLimit then
                    if this.killGatePassed(s) then
                        set pick = pick - 1
                        if pick == 0 then
                            return s
                        endif
                    endif
                endif

                set i = i + 1
            endloop

            return 0 // seguridad
        endmethod

        //==================================================
        method trySpawn takes nothing returns nothing
            local WaveSlot s
            local integer pid
            local PendingSpawn ps
            
            set s = this.pickSlot()

            if s == 0 then
                return 
            endif

            if not this.selectSpawnPoint(256.0) then
                return
            endif

            set pid = GetPlayerId(s.owner)
            if not this.isTrackedPid(pid) then
                return
            endif

            set this.activeByPlayer[pid] = this.activeByPlayer[pid] + 1
            set s.remaining              = s.remaining - 1
            set s.active                 = s.active + 1
            set this.activeOnMap         = this.activeOnMap + 1

            set this.remainingToSpawn = this.remainingToSpawn - 1

            if s.isBoss then
                set this.remainingBosses = this.remainingBosses - 1
                set this.activeBosses    = this.activeBosses + 1
            else
                set this.remainingUnits = this.remainingUnits - 1
                set this.activeUnits    = this.activeUnits + 1
            endif

            // 2. Crear pending spawn
            set ps = PendingSpawn.create()
            set ps.wave = this
            set ps.slot = s
            set ps.pid  = pid
            set ps.waveToken = this.waveToken
            set ps.epoch = this.pendingEpoch
            set ps.prevPending = 0
            set ps.nextPending = this.pendingHead
            if this.pendingHead != 0 then
                set this.pendingHead.prevPending = ps
            endif
            set this.pendingHead = ps
            set this.pendingReservations = this.pendingReservations + 1
            set ps.x    = this.spawnX
            set ps.y    = this.spawnY

            // 4. Timer de spawn real
            set ps.t = NewTimer()
            call SetTimerDebugTag(ps.t, TIMER_DEBUG_TAG_WAVE_CORE)
            call SetTimerData(ps.t, ps)
            call TimerStart(ps.t, 1.50, false, function PendingSpawn_execute)

            // Ultimo paso: un listener de Reserve puede pausar o destruir la Wave; la reserva ya esta completa.
            call WaveFireReserve(this, s, s.isBoss, ps.x, ps.y)

        endmethod

        //==================================================
        // Unica salida de una entidad registrada. retired=true: baja sin muerte (cumple objetivo, no cuenta kill).
        method releaseEntity takes unit u, unit killer, boolean retired returns nothing
            local integer hid = GetHandleId(u)
            local WaveSlot s = 0
            local integer pid = -1
            local integer unitTypeId = 0
            local boolean isBoss = false
            local boolean isExternal = false

            // Salida unica: si un listener de Death retira o mata esta misma unidad, la segunda salida se ignora.
            if WaveReleasingByUnit.has(hid) then
                return
            endif
            set WaveReleasingByUnit[hid] = 1

            if WaveUnitTypeByUnit.has(hid) then
                set unitTypeId = WaveUnitTypeByUnit[hid]
            endif
            set this.activeOnMap = this.activeOnMap - 1
            set this.totalKilled = this.totalKilled - 1
            if retired then
                set this.retiredCount = this.retiredCount + 1
            else
                set this.killsDone = this.killsDone + 1
            endif

            if SlotByUnit.has(hid) then
                set s = WaveSlot(SlotByUnit[hid])
                if s.owner != null then
                    set pid = GetPlayerId(s.owner)
                endif
                if (pid >= 0) and (pid < WAVE_TRACKED_PLAYER_SLOTS) then
                    set this.activeByPlayer[pid] = this.activeByPlayer[pid] - 1
                endif
                set s.active = s.active - 1
                set isBoss = s.isBoss
            elseif ExternalIsBoss.has(hid) then
                set isExternal = true
                if WaveExternalOwnerPidByUnit.has(hid) then
                    set pid = WaveExternalOwnerPidByUnit[hid]
                    if (pid >= 0) and (pid < WAVE_TRACKED_PLAYER_SLOTS) then
                        set this.activeByPlayer[pid] = this.activeByPlayer[pid] - 1
                        if this.activeByPlayer[pid] < 0 then
                            set this.activeByPlayer[pid] = 0
                        endif
                    endif
                endif
                set isBoss = ExternalIsBoss[hid] == 1
            endif

            if isBoss then
                set this.activeBosses = this.activeBosses - 1
                set this.totalKilledBoss = this.totalKilledBoss - 1
                if not retired then
                    set this.killsDoneBoss = this.killsDoneBoss + 1
                endif
            elseif (s != 0) or isExternal then
                set this.activeUnits = this.activeUnits - 1
                set this.totalKilledUnits = this.totalKilledUnits - 1
                if not retired then
                    set this.killsDoneUnits = this.killsDoneUnits + 1
                endif
            endif

            if WAVE_DEBUG_ENABLED then
                call WaveDebugLog("releaseEntity w=" + I2S(this) + " retired=" + I2S(WaveDebugBoolToInt(retired)) + " unit=" + WaveDebugUnitSummary(u) + " killer=" + WaveDebugUnitSummary(killer) + " external=" + I2S(WaveDebugBoolToInt(isExternal)) + " boss=" + I2S(WaveDebugBoolToInt(isBoss)) + " ownerPid=" + I2S(pid) + " type=" + I2S(unitTypeId) + " hid=" + I2S(hid))
            endif

            call this.untrackUnitByHandle(hid)
            call WaveFireDeath(this, u, killer, s, isBoss, isExternal, retired, unitTypeId)

            call WaveByUnit.remove(hid)
            call SlotByUnit.remove(hid)
            call ExternalIsBoss.remove(hid)
            call WaveExternalOwnerPidByUnit.remove(hid)
            call WaveUnitTypeByUnit.remove(hid)
            call WaveReleasingByUnit.remove(hid)
            call this.tryDestroyAfterTermination()
        endmethod

        // Entidades indexadas que el motor ya elimino sin evento de muerte (RemoveUnit).
        method reconcileRetired takes nothing returns nothing
            local integer i = this.activeTrackedCount
            local unit u
            loop
                exitwhen i < 1 or this.isDestroyed
                set u = this.getActiveIndexedUnit(i)
                if (u != null) and (GetUnitTypeId(u) == 0) then
                    call this.releaseEntity(u, null, true)
                endif
                set i = i - 1
            endloop
            set u = null
        endmethod

        //==================================================
        method allSlotsEmpty takes nothing returns boolean
            local integer i = 0
            loop
                exitwhen i >= this.slotCount
                if this.slots[i].remaining > 0 then
                    return false
                endif
                set i = i + 1
            endloop
            return true
        endmethod

        // API semÃ¡ntica para IA/UI (sin romper legacy)
        method getToKillRemaining takes nothing returns integer
            return this.totalKilled
        endmethod

        method getToKillUnitsRemaining takes nothing returns integer
            return this.totalKilledUnits
        endmethod

        method getToKillBossRemaining takes nothing returns integer
            return this.totalKilledBoss
        endmethod

        method getKillsDone takes nothing returns integer
            return this.killsDone
        endmethod

        method getKillsDoneUnits takes nothing returns integer
            return this.killsDoneUnits
        endmethod

        method getKillsDoneBoss takes nothing returns integer
            return this.killsDoneBoss
        endmethod

        method isOperational takes nothing returns boolean
            return this.isRunning and (not this.isPaused) and (not this.isDestroyed)
        endmethod

        //==================================================
        method onTick takes nothing returns nothing
            if this.isDestroyed then
                return
            endif
            call this.reconcileRetired()
            if this.isDestroyed or this.isPaused or this.terminateRequested then
                return
            endif
            set this.tickCounter = this.tickCounter + 1
            if ModuloInteger(this.tickCounter, 16) == 0 then
                call this.compactNearUnits()
            endif
            call this.trySpawn()

            if this.allSlotsEmpty() and this.activeOnMap <= 0 then
                call this.finish()
            endif
        endmethod

        //==================================================
        private method fireFinishEventOnce takes nothing returns nothing
            if this.finishEventFired then
                return
            endif
            set this.finishEventFired = true
            call WaveFireFinish(this)
        endmethod

        //==================================================
        method finish takes nothing returns nothing
            if this.isDestroyed or this.isFinishing then
                return
            endif
            set this.isFinishing = true
            call this.fireFinishEventOnce()
            call this.destroyWave()
        endmethod

        method destroyWave takes nothing returns nothing
            local integer i = 0
            local integer hid
            local integer key
            local unit u
            local WaveEntityRef ref
            local PendingSpawn ps
            local PendingSpawn nextPs

            if this.isDestroyed then
                return
            endif
            set this.isDestroyed = true
            set this.isRunning = false
            set this.isPaused = false

            // Reservas pendientes: se liberan ya (una congelada no volveria a dispararse).
            set ps = this.pendingHead
            loop
                exitwhen ps == 0
                set nextPs = ps.nextPending
                call ReleaseTimer(ps.t)
                set ps.t = null
                set ps.nextPending = 0
                set ps.prevPending = 0
                call ps.destroy()
                set ps = nextPs
            endloop
            set this.pendingHead = 0
            set this.pendingReservations = 0

            // Timer
            if this.loopTimer != null then
                call PauseTimer(this.loopTimer)
                call ReleaseTimer(this.loopTimer)
                call WaveByTimer.remove(GetHandleId(this.loopTimer))
                set this.loopTimer = null
            endif

            // Active units index cleanup
            set i = 1
            loop
                exitwhen i > this.activeTrackedCount
                set key = this.activeKey(i)
                set ref = WaveEntityRef(WaveActiveUnitByKey[key])
                set u = null
                if ref != 0 then
                    set u = ref.u
                    set ref.u = null
                    call ref.destroy()
                endif
                if u != null then
                    set hid = GetHandleId(u)
                    call WaveByUnit.remove(hid)
                    call SlotByUnit.remove(hid)
                    call ExternalIsBoss.remove(hid)
                    call WaveExternalOwnerPidByUnit.remove(hid)
                    call WaveActivePosByUnit.remove(hid)
                    call WaveUnitTypeByUnit.remove(hid)
                endif
                call WaveActiveUnitByKey.remove(key)
                set i = i + 1
            endloop
            set this.activeTrackedCount = 0
            set u = null

            // Slots
            set i = 0
            loop
                exitwhen i >= this.slotCount
                call this.slots[i].destroy()
                set this.slots[i] = 0
                set i = i + 1
            endloop

            set this.nearUnitCount = 0
            set this.pointCount = 0
            call this.clearAffiliateUnit()

            call this.destroy()
        endmethod
    endstruct

    function GetWaveEventWave takes nothing returns Wave
        return Wave(WaveEventWaveId)
    endfunction

    function GetWaveEventUnit takes nothing returns unit
        return WaveEventUnit
    endfunction

    function GetWaveEventKiller takes nothing returns unit
        return WaveEventKiller
    endfunction

    function GetWaveEventSlot takes nothing returns WaveSlot
        return WaveSlot(WaveEventSlotId)
    endfunction

    function IsWaveEventBoss takes nothing returns boolean
        return WaveEventIsBoss
    endfunction

    function IsWaveEventExternal takes nothing returns boolean
        return WaveEventIsExternal
    endfunction

    function GetWaveSlotByUnit takes unit u returns WaveSlot
        local integer hid
        if u == null then
            return 0
        endif
        set hid = GetHandleId(u)
        if SlotByUnit.has(hid) then
            return SlotByUnit[hid]
        endif
        return 0
    endfunction

    function IsWaveEventRetired takes nothing returns boolean
        return WaveEventIsRetired
    endfunction

    // Tipo vivo si la unidad existe; si ya fue eliminada, el tipo registrado.
    function GetWaveEventUnitTypeId takes nothing returns integer
        local integer t = GetUnitTypeId(WaveEventUnit)
        if t != 0 then
            return t
        endif
        return WaveEventUnitTypeId
    endfunction

    function IsWaveManagedUnit takes unit u returns boolean
        if u == null then
            return false
        endif
        return WaveByUnit.has(GetHandleId(u))
    endfunction

    function RegisterWaveStartEvent takes code c returns nothing
        if WaveEvtStart == null then
            set WaveEvtStart = CreateTrigger()
        endif
        call TriggerAddAction(WaveEvtStart, c)
    endfunction

    function RegisterWavePauseEvent takes code c returns nothing
        if WaveEvtPause == null then
            set WaveEvtPause = CreateTrigger()
        endif
        call TriggerAddAction(WaveEvtPause, c)
    endfunction

    function RegisterWaveResumeEvent takes code c returns nothing
        if WaveEvtResume == null then
            set WaveEvtResume = CreateTrigger()
        endif
        call TriggerAddAction(WaveEvtResume, c)
    endfunction

    function RegisterWaveFinishEvent takes code c returns nothing
        if WaveEvtFinish == null then
            set WaveEvtFinish = CreateTrigger()
        endif
        call TriggerAddAction(WaveEvtFinish, c)
    endfunction

    function RegisterWaveSpawnEvent takes code c returns nothing
        if WaveEvtSpawn == null then
            set WaveEvtSpawn = CreateTrigger()
        endif
        call TriggerAddAction(WaveEvtSpawn, c)
    endfunction

    function RegisterWaveDeathEvent takes code c returns nothing
        if WaveEvtDeath == null then
            set WaveEvtDeath = CreateTrigger()
        endif
        call TriggerAddAction(WaveEvtDeath, c)
    endfunction

    function RegisterWaveReserveEvent takes code c returns nothing
        if WaveEvtReserve == null then
            set WaveEvtReserve = CreateTrigger()
        endif
        call TriggerAddAction(WaveEvtReserve, c)
    endfunction

    function GetWaveEventX takes nothing returns real
        return WaveEventX
    endfunction

    function GetWaveEventY takes nothing returns real
        return WaveEventY
    endfunction

    function RegisterWaveExternalEvent takes code c returns nothing
        if WaveEvtExternal == null then
            set WaveEvtExternal = CreateTrigger()
        endif
        call TriggerAddAction(WaveEvtExternal, c)
    endfunction

    function PauseWave takes Wave w returns nothing
        if w != 0 then
            call w.pause()
        endif
    endfunction

    function ResumeWave takes Wave w returns nothing
        if w != 0 then
            call w.resume()
        endif
    endfunction

    function BindWaveToUnitDeath takes Wave w, unit anchor, boolean forceKillOnDeath returns nothing
        if w != 0 then
            call w.setAffiliateUnit(anchor, forceKillOnDeath)
        endif
    endfunction

    function UnbindWaveFromUnitDeath takes Wave w returns nothing
        if w != 0 then
            call w.clearAffiliateUnit()
        endif
    endfunction

    function TerminateWaveInstanceGraceful takes integer waveId returns nothing
        local Wave w = Wave(waveId)
        if w != 0 then
            call w.terminate(false)
        endif
    endfunction

    function TerminateWaveInstanceForceKill takes integer waveId returns nothing
        local Wave w = Wave(waveId)
        if w != 0 then
            call w.terminate(true)
        endif
    endfunction

    function BindWaveInstanceToUnitDeath takes integer waveId, unit anchor, boolean forceKillOnDeath returns nothing
        local Wave w = Wave(waveId)
        if w != 0 then
            call w.setAffiliateUnit(anchor, forceKillOnDeath)
        endif
    endfunction

    function UnbindWaveInstanceFromUnitDeath takes integer waveId returns nothing
        local Wave w = Wave(waveId)
        if w != 0 then
            call w.clearAffiliateUnit()
        endif
    endfunction

    //==================================================
    // Trigger de muerte
    //==================================================
    private function OnUnitDeath takes nothing returns nothing
        local unit u = GetDyingUnit()
        local unit killer = GetKillingUnit()
        local integer hid = GetHandleId(u)
        local Wave w

        if WaveByUnit.has(hid) then
            set w = Wave(WaveByUnit[hid])
            if w == 0 then
                call WaveDebugLog("OnUnitDeath reject reason=wave_missing unit=" + WaveDebugUnitSummary(u) + " killer=" + WaveDebugUnitSummary(killer) + " hid=" + I2S(hid))
                call WaveByUnit.remove(hid)
                call SlotByUnit.remove(hid)
                call ExternalIsBoss.remove(hid)
                call WaveExternalOwnerPidByUnit.remove(hid)
                call WaveUnitTypeByUnit.remove(hid)
                call WaveHandleAffiliateDeath(hid)
                set u = null
                set killer = null
                return
            endif
            if w.isDestroyed then
                call WaveDebugLog("OnUnitDeath reject reason=wave_destroyed unit=" + WaveDebugUnitSummary(u) + " killer=" + WaveDebugUnitSummary(killer) + " wave=" + I2S(w) + " hid=" + I2S(hid))
                call w.untrackUnitByHandle(hid)
                call WaveByUnit.remove(hid)
                call SlotByUnit.remove(hid)
                call ExternalIsBoss.remove(hid)
                call WaveExternalOwnerPidByUnit.remove(hid)
                call WaveUnitTypeByUnit.remove(hid)
                call WaveHandleAffiliateDeath(hid)
                set u = null
                set killer = null
                return
            endif
            call w.releaseEntity(u, killer, false)
        endif

        call WaveHandleAffiliateDeath(hid)

        set killer = null
        set u = null
    endfunction

    // Retirada explicita (p. ej. antes de RemoveUnit): baja sin muerte e inmediata.
    function WaveRetireUnit takes unit u returns boolean
        local integer hid
        local Wave w
        if u == null then
            return false
        endif
        set hid = GetHandleId(u)
        if not WaveByUnit.has(hid) then
            return false
        endif
        set w = Wave(WaveByUnit[hid])
        if (w == 0) or w.isDestroyed or WaveReleasingByUnit.has(hid) then
            return false
        endif
        call w.releaseEntity(u, null, true)
        return true
    endfunction

    function registerExternalUnit takes unit source, unit summoned, boolean isBoss returns nothing
            local integer srcId = GetHandleId(source)
            local Wave w

            if not WaveByUnit.has(srcId) then
                return
            endif
            set w = Wave(WaveByUnit[srcId])
            if w == 0 then
                return
            endif
            call w.registerExternalUnit(source, summoned, isBoss)
    endfunction

    function GetWaveByUnit takes unit u returns Wave
        if u == null then
            return 0
        endif
        if not WaveByUnit.has(GetHandleId(u)) then
            return 0
        endif
        return Wave(WaveByUnit[GetHandleId(u)])
    endfunction

    //==================================================
    // Init
    //==================================================
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer i = 0

        set WaveByUnit = Table.create()
        set WaveByTimer = Table.create()
        set SlotByUnit = Table.create()
        set ExternalIsBoss = Table.create()
        set WaveActiveUnitByKey = Table.create()
        set WaveActivePosByUnit = Table.create()
        set WaveAffiliateWaveByUnit = Table.create()
        set WaveAffiliateModeByUnit = Table.create()
        set WaveExternalOwnerPidByUnit = Table.create()
        set WaveUnitTypeByUnit = Table.create()
        set WaveReleasingByUnit = Table.create()
        set WaveEvtStart = CreateTrigger()
        set WaveEvtPause = CreateTrigger()
        set WaveEvtResume = CreateTrigger()
        set WaveEvtFinish = CreateTrigger()
        set WaveEvtSpawn = CreateTrigger()
        set WaveEvtDeath = CreateTrigger()
        set WaveEvtExternal = CreateTrigger()
        set WaveEvtReserve = CreateTrigger()

        loop
            exitwhen i >= bj_MAX_PLAYER_SLOTS
            call TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_UNIT_DEATH, null)
            set i = i + 1
        endloop

        call TriggerAddAction(t, function OnUnitDeath)
    endfunction 
endlibrary

