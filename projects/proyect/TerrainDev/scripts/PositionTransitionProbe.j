library PositionTransitionProbe initializer Init
globals
    private unit array bodies
    private real array beforeX
    private integer array beforeOrder
    private integer array afterOrder
endglobals
private function Finish takes nothing returns nothing
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("POSITION @RUN@ COMPLETE")
    loop
        exitwhen i == 3
        call Preload("mode="+I2S(i)+" beforeOrder="+I2S(beforeOrder[i])+" afterOrder="+I2S(afterOrder[i])+" travelled="+R2S(GetUnitX(bodies[i])-beforeX[i]))
        call RemoveUnit(bodies[i])
        set bodies[i] = null
        set i = i+1
    endloop
    call PreloadGenEnd("Logs\\TerrainDev-@RUN@-position.txt")
    call DestroyTimer(GetExpiredTimer())
endfunction
private function Transition takes nothing returns nothing
    local integer i = 0
    local location p
    loop
        exitwhen i == 3
        set beforeOrder[i] = GetUnitCurrentOrder(bodies[i])
        set beforeX[i] = GetUnitX(bodies[i])+8.
        if i == 0 then
            call SetUnitX(bodies[i],beforeX[i])
            call SetUnitY(bodies[i],GetUnitY(bodies[i]))
        elseif i == 1 then
            call SetUnitPosition(bodies[i],beforeX[i],GetUnitY(bodies[i]))
        else
            set p = Location(beforeX[i],GetUnitY(bodies[i]))
            call SetUnitPositionLoc(bodies[i],p)
            call RemoveLocation(p)
        endif
        set afterOrder[i] = GetUnitCurrentOrder(bodies[i])
        set i = i+1
    endloop
    call TimerStart(CreateTimer(),0.75,false,function Finish)
    call DestroyTimer(GetExpiredTimer())
    set p = null
endfunction
private function Begin takes nothing returns nothing
    local integer i = 0
    local real x = GetStartLocationX(0)+600.
    local real y = GetStartLocationY(0)+300.
    loop
        exitwhen i == 3
        set bodies[i] = CreateUnit(Player(0),'hfoo',x,y+I2R(i)*128.,0.)
        call SetUnitPathing(bodies[i],false)
        call SetUnitMoveSpeed(bodies[i],350.)
        call IssuePointOrder(bodies[i],"move",x+1500.,y+I2R(i)*128.)
        set i = i+1
    endloop
    call PanCameraToTimed(x+500.,y,0.)
    call TimerStart(CreateTimer(),0.5,false,function Transition)
    call DestroyTimer(GetExpiredTimer())
endfunction
private function Init takes nothing returns nothing
    call TimerStart(CreateTimer(),1.,false,function Begin)
endfunction
endlibrary
