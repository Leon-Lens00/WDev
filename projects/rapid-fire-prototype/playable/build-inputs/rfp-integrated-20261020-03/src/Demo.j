library RFDemo requires RFBurstPair, RFControls
    globals
        private unit visible = null
        private unit logical = null
        private unit array targets
        private trigger shots = null
        private trigger chat = null
        private timer hud = null
        private integer fired = 0
        private boolean started = false
    endglobals

    private function OnShot takes nothing returns boolean
        set fired = fired+1
        return false
    endfunction

    private function Instructions takes nothing returns nothing
        call DisplayTimedTextToPlayer(Player(0),0.,0.,25.,"RAPID FIRE | Q + point: fire / retarget. Right-click or M: move. S: stop.\n4 shots, 4/s, physical10, range1500, speed1200. Script move350 while firing.\nAttack restarts at300%; last gesture normalizes at exhaustion.\n-rf reset: respawn pair / targets. -rf help: instructions. Controller stays off-camera.")
    endfunction

    private function Spawn takes nothing returns nothing
        local integer i = 0
        call RB_Dispose()
        call RemoveUnit(visible)
        call RemoveUnit(logical)
        loop
            exitwhen i >= 3
            call RemoveUnit(targets[i])
            set i = i+1
        endloop
        set visible = CreateUnit(Player(0),'o000',-3136.,2624.,0.)
        set logical = CreateUnit(Player(0),'o001',-5500.,-5500.,0.)
        set targets[0] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'o000',-2624.,2624.,180.)
        set targets[1] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'o000',-2368.,3008.,180.)
        set targets[2] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'o000',-2368.,2240.,180.)
        set i = 0
        loop
            exitwhen i >= 3
            call PauseUnit(targets[i],true)
            set i = i+1
        endloop
        set fired = 0
        if RB_InitializePair(visible,logical,shots) then
            call RF_StartControls()
        else
            call DisplayTimedTextToPlayer(Player(0),0.,0.,120.,"PAIR INIT FAILED: check o000/o001/A00G playable object overlay.")
        endif
        call Instructions()
    endfunction

    private function OnChat takes nothing returns boolean
        if GetEventPlayerChatString() == "-rf reset" then
            call Spawn()
        else
            call Instructions()
        endif
        return false
    endfunction

    private function Status takes nothing returns nothing
        local string move = "native / idle"
        if RB_IsScriptMoving() then
            set move = "script350"
        endif
        if RB_IsBlocked() then
            set move = "blocked; native resume at exhaustion"
        endif
        if GetWidgetLife(visible) <= .405 then
            set move = "DEAD: -rf reset"
        endif
        call DisplayTimedTextToPlayer(Player(0),0.,.01,.55,"Remaining "+I2S(RB_GetRemaining())+" | fired "+I2S(fired)+" | "+move+" | commanded animation x"+R2S(RB_GetCommandedScale()))
    endfunction

    function RF_StartDemo takes nothing returns nothing
        if started then
            return
        endif
        set started = true
        set shots = CreateTrigger()
        call TriggerAddCondition(shots,Condition(function OnShot))
        set chat = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(chat,Player(0),"-rf",false)
        call TriggerAddCondition(chat,Condition(function OnChat))
        // Own live trees beside the firing lane, not on the clear starting lane.
        call CreateDestructable('LTlt',-2880.,2112.,0.,1.,0)
        call CreateDestructable('LTlt',-2752.,2112.,0.,1.,0)
        set hud = CreateTimer()
        call Spawn()
        call TimerStart(hud,.5,true,function Status)
    endfunction
endlibrary
