// Laboratory only. Loaded beside the existing independent 90-missile fixture.
library DiagnosticsProbe initializer Init requires Missile, MissileDiagnostics
globals
    private integer failures = 0
    private boolean normalDone = false
    private boolean delayStarted = false
    private boolean delayDone = false
    private unit stuck = null
endglobals

private function Log takes string stage returns nothing
    call MissileStats.inspect()
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("DIAGNOSTICS @RUN@ "+stage)
    call Preload("active="+I2S(MissileStats.active)+" peak="+I2S(MissileStats.peakActive)+" created="+I2S(MissileStats.created)+" retired="+I2S(MissileStats.retired))
    call Preload("tracked="+I2S(MissileStats.tracked)+" pooled="+I2S(MissileStats.pooled)+" borrowed="+I2S(MissileStats.borrowed)+" deferred="+I2S(MissileStats.deferred)+" pending="+I2S(MissileStats.pending)+" overdue="+I2S(MissileStats.overdue))
    call Preload("preloaded="+I2S(MissileStats.preloadTotal)+" new="+I2S(MissileStats.newTotal)+" reused="+I2S(MissileStats.reusedTotal)+" disposed="+I2S(MissileStats.disposed)+" lost="+I2S(MissileStats.lost))
    call Preload("invalid="+I2S(MissileStats.invalid)+" errors="+I2S(MissileStats.errors)+" inconsistent="+I2S(MissileStats.inconsistent)+" omitted="+I2S(MissileStats.omitted)+" adopted="+I2S(MissileStats.adoptedTotal)+" alarms="+I2S(MissileStats.alarms)+" probeFailures="+I2S(failures))
    call Preload("board="+MultiboardGetTitleText(MissileStats.board))
    call PreloadGenEnd("Logs\\TerrainDev-@RUN@-diagnostics-"+stage+".txt")
endfunction

private function Idle takes nothing returns nothing
    call MissileStats.inspect()
    if MissileStats.active != 0 or MissileStats.pooled != 96 or MissileStats.tracked != 96 or MissileStats.preloadTotal != 96 or MissileStats.alarms != 0 then
        set failures = failures+1
    endif
    if MissileStats.board == null or MultiboardGetRowCount(MissileStats.board) != 25 or MultiboardGetColumnCount(MissileStats.board) != 2 then
        set failures = failures+1
    endif
    call Log("idle")
    call DestroyTimer(GetExpiredTimer())
endfunction

private function Normal takes nothing returns nothing
    call MissileStats.inspect()
    if MissileStats.active != 0 or MissileStats.created != 90 or MissileStats.retired != 90 or MissileStats.peakActive != 60 then
        set failures = failures+1
    endif
    if MissileStats.tracked != 96 or MissileStats.pooled != 96 or MissileStats.borrowed != 0 or MissileStats.pending != 0 or MissileStats.deferred != 0 then
        set failures = failures+1
    endif
    if MissileStats.newTotal != 66 or MissileStats.reusedTotal != 24 or MissileStats.disposed != 66 or MissileStats.alarms != 0 or MissileStats.omitted != 0 then
        set failures = failures+1
    endif
    set normalDone = true
    call Log("normal")
    call BJDebugMsg("Panel listo: -diag-diferido, -diag-negativo, -diag-recuperar")
    call DestroyTimer(GetExpiredTimer())
endfunction

private struct Delayed extends array
    static method onFinish takes Missile m returns boolean
        return true
    endmethod
    static method onRemove takes Missile m returns boolean
        return true
    endmethod
    implement MissileStruct
endstruct

private function DelayedCheck takes nothing returns nothing
    call MissileStats.inspect()
    if MissileStats.deferred != 1 or MissileStats.active != 0 or MissileStats.pooled != 95 or MissileStats.borrowed != 0 then
        set failures = failures+1
    endif
    call Log("deferred")
    call DestroyTimer(GetExpiredTimer())
endfunction

private function DelayedDone takes nothing returns nothing
    call MissileStats.inspect()
    if MissileStats.deferred != 0 or MissileStats.active != 0 or MissileStats.pooled != 96 or MissileStats.alarms != 0 then
        set failures = failures+1
    endif
    set delayDone = true
    call Log("deferred-done")
    call DestroyTimer(GetExpiredTimer())
endfunction

private function StartDelay takes nothing returns nothing
    local real x = GetStartLocationX(0)
    local real y = GetStartLocationY(0)
    local Missile m
    if not normalDone or delayStarted then
        return
    endif
    set delayStarted = true
    set m = Missile.createXYZ(x,y,50.,x+300.,y,50.)
    call m.setMovementSpeed(1000.)
    call Delayed.launch(m)
    call TimerStart(CreateTimer(),1.,false,function DelayedCheck)
    call TimerStart(CreateTimer(),6.,false,function DelayedDone)
endfunction

private function OverdueCheck takes nothing returns nothing
    call MissileStats.inspect()
    if MissileStats.pending != 1 or MissileStats.overdue != 1 or MissileStats.alarms != 1 or MissileStats.adoptedTotal != 1 then
        set failures = failures+1
    endif
    call Log("overdue")
    call DestroyTimer(GetExpiredTimer())
endfunction

private function Negative takes nothing returns nothing
    if not delayDone or stuck != null then
        return
    endif
    // Reproduce the original lifetime bug only in this diagnostic fixture.
    set stuck = CreateUnit(Player(14),'dumi',GetStartLocationX(0),GetStartLocationY(0),0.)
    call RecycleMissile(stuck)
    call PauseUnit(stuck,true)
    call TimerStart(CreateTimer(),6.,false,function OverdueCheck)
endfunction

private function RecoveredCheck takes nothing returns nothing
    call MissileStats.inspect()
    if MissileStats.pending != 0 or MissileStats.overdue != 0 or MissileStats.tracked != 96 or MissileStats.pooled != 96 or MissileStats.disposed != 67 or MissileStats.alarms != 1 then
        set failures = failures+1
    endif
    set stuck = null
    call Log("recovered")
    call DestroyTimer(GetExpiredTimer())
endfunction

private function Recover takes nothing returns nothing
    if stuck == null then
        return
    endif
    call PauseUnit(stuck,false)
    call TimerStart(CreateTimer(),4.,false,function RecoveredCheck)
endfunction

private function Invalid takes nothing returns nothing
    call RecycleMissile(null)
    if MissileStats.invalid != 1 or MissileStats.alarms != 2 then
        set failures = failures+1
    endif
    call Log("invalid")
endfunction

private function Hidden takes nothing returns nothing
    if IsMultiboardDisplayed(MissileStats.board) then
        set failures = failures+1
    endif
    call Log("hidden")
endfunction

private function Visible takes nothing returns nothing
    if not IsMultiboardDisplayed(MissileStats.board) then
        set failures = failures+1
    endif
    call Log("visible")
endfunction

private function Register takes string text, code action returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t,Player(0),text,true)
    call TriggerAddAction(t,action)
    set t = null
endfunction

private function Init takes nothing returns nothing
    call TimerStart(CreateTimer(),0.5,false,function Idle)
    call TimerStart(CreateTimer(),17.,false,function Normal)
    call Register("-diag-diferido",function StartDelay)
    call Register("-diag-negativo",function Negative)
    call Register("-diag-recuperar",function Recover)
    call Register("-diag-invalido",function Invalid)
    call Register("-diag-oculto",function Hidden)
    call Register("-diag-visible",function Visible)
endfunction
endlibrary
