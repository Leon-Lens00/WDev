// Diagnostic laboratory: isolate timed life on the imported dummy object.
library TimedLifeProbe initializer Init
globals
    private unit pausedDummy
    private unit runningDummy
    private unit resumedDummy
endglobals
private function AliveFlag takes unit u returns string
    if UnitAlive(u) then
        return "1"
    endif
    return "0"
endfunction
private function Finish takes nothing returns nothing
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("TIMEDLIFE @RUN@ COMPLETE")
    call Preload("pausedAlive="+AliveFlag(pausedDummy)+" runningAlive="+AliveFlag(runningDummy)+" resumedAlive="+AliveFlag(resumedDummy))
    call PreloadGenEnd("Logs\\TerrainDev-@RUN@-timedlife.txt")
    call RemoveUnit(pausedDummy)
    call RemoveUnit(runningDummy)
    call RemoveUnit(resumedDummy)
    call DestroyTimer(GetExpiredTimer())
endfunction
private function Begin takes nothing returns nothing
    local real x = GetStartLocationX(0)
    local real y = GetStartLocationY(0)
    set pausedDummy = CreateUnit(Player(14),'dumi',x,y,0.)
    set runningDummy = CreateUnit(Player(14),'dumi',x+100.,y,0.)
    set resumedDummy = CreateUnit(Player(14),'dumi',x+200.,y,0.)
    call PauseUnit(pausedDummy,true)
    call PauseUnit(resumedDummy,true)
    call PauseUnit(resumedDummy,false)
    call UnitApplyTimedLife(pausedDummy,'BTLF',2.)
    call UnitApplyTimedLife(runningDummy,'BTLF',2.)
    call UnitApplyTimedLife(resumedDummy,'BTLF',2.)
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("TIMEDLIFE @RUN@ START types="+I2S(GetUnitTypeId(pausedDummy))+","+I2S(GetUnitTypeId(runningDummy))+","+I2S(GetUnitTypeId(resumedDummy)))
    call PreloadGenEnd("Logs\\TerrainDev-@RUN@-timedlife-start.txt")
    call TimerStart(CreateTimer(),4.,false,function Finish)
    call DestroyTimer(GetExpiredTimer())
endfunction
private function Init takes nothing returns nothing
    call TimerStart(CreateTimer(),1.,false,function Begin)
endfunction
endlibrary
