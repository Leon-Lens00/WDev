library RapidFireDemo initializer Init requires RapidFire, MissileDiagnostics
struct RapidDemo extends array
    readonly static RapidPair pair = 0
    private static boolean extended = false
    private static unit array targets
    private static method row takes integer r, string name, string value returns nothing
        local multiboarditem cell = MultiboardGetItem(MissileStats.board,r,0)
        call MultiboardSetItemStyle(cell,true,false)
        call MultiboardSetItemWidth(cell,0.17)
        call MultiboardSetItemValue(cell,name)
        call MultiboardReleaseItem(cell)
        set cell = MultiboardGetItem(MissileStats.board,r,1)
        call MultiboardSetItemStyle(cell,true,false)
        call MultiboardSetItemWidth(cell,0.12)
        call MultiboardSetItemValue(cell,value)
        call MultiboardReleaseItem(cell)
        set cell = null
    endmethod
    private static method panel takes nothing returns nothing
        if MissileStats.board != null then
            if not extended then
                call MultiboardSetRowCount(MissileStats.board,25)
                set extended = true
            endif
            call row(19,"Rafagas / pendientes",I2S(RapidPair.bursts)+" / "+I2S(RapidPair.remaining))
            call row(20,"Move art. / bloqueado",I2S(RapidPair.moving)+" / "+I2S(RapidPair.blocked))
            call row(21,"Tiros / recasts",I2S(RapidPair.emitted)+" / "+I2S(RapidPair.recasts))
            if RapidPair.minInterval == 99999. then
                call row(22,"Intervalo min / base","-- / 250 ms")
            else
                call row(22,"Intervalo min / base",I2S(R2I(RapidPair.minInterval*1000.+0.5))+" / 250 ms")
            endif
            call row(23,"Instantaneos / XY",I2S(GroundMotion.instantTransitions)+" / "+I2S(GroundMotion.xySteps))
            call row(24,"Retornos / proyectiles",I2S(GroundMotion.handoffs)+" / "+I2S(RapidBolt.live))
        endif
    endmethod
    static method setup takes nothing returns nothing
        local integer i = 0
        local real x = GetStartLocationX(0)+384.
        local real y = GetStartLocationY(0)-256.
        local real bx = x
        local real by = y
        local unit actor
        local unit controller
        loop
            exitwhen GroundCollision.clear(x,y,24.) or i == 100
            set x = bx+I2R(ModuloInteger(i,10))*96.
            set y = by+I2R(i/10)*96.
            set i = i+1
        endloop
        set actor = CreateUnit(Player(0),'rfex',x,y,0.)
        set controller = CreateUnit(Player(0),'rfct',WorldBounds.minX+256.,WorldBounds.minY+256.,0.)
        call SetUnitVertexColor(controller,255,255,255,0)
        set pair = RapidPair.create(controller,actor)
        set i = 0
        loop
            exitwhen i == 3
            set targets[i] = CreateUnit(Player(12),'rftg',x+450.+I2R(i)*180.,y+96.*I2R(i),180.)
            call PauseUnit(targets[i],true)
            set i = i+1
        endloop
        if GetLocalPlayer() == Player(0) then
            call ClearSelection()
            call SelectUnit(controller,true)
            call SetCameraTargetController(actor,0.,0.,false)
        endif
        call DisplayTimedTextToPlayer(Player(0),0.,0.,18.,"Rapid Fire: Q y apunta. Clic derecho en suelo para mover. Recast repone 6 sin reiniciar intervalo. -misiles muestra/oculta el panel.")
        set actor = null
        set controller = null
    endmethod
    private static method start takes nothing returns nothing
        call setup()
        call DestroyTimer(GetExpiredTimer())
    endmethod
    static method initialize takes nothing returns nothing
        call TimerStart(CreateTimer(),0.25,false,function thistype.start)
        call TimerStart(CreateTimer(),0.25,true,function thistype.panel)
    endmethod
endstruct
private function Init takes nothing returns nothing
    call RapidDemo.initialize()
endfunction
endlibrary
