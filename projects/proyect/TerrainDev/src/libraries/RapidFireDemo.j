library RapidFireDemo initializer Init requires RapidFire, MissileDiagnostics, UnitHitShape
struct RapidDemo extends array
    readonly static RapidPair pair = 0
    private static boolean extended = false
    private static unit array targets
    private static integer targetCount = 0
    // Largest offset where IsUnitInRangeXY(u, point, 0) is still true: the body
    // radius the native range test uses (bisection to 0.25).
    private static method rangeBody takes unit u returns real
        local real lo = 0.
        local real hi = 400.
        loop
            exitwhen hi-lo < 0.25
            if IsUnitInRangeXY(u,GetUnitX(u)+(lo+hi)*0.5,GetUnitY(u),0.) then
                set lo = (lo+hi)*0.5
            else
                set hi = (lo+hi)*0.5
            endif
        endloop
        return lo
    endmethod
    private static method report takes unit u, string name returns nothing
        call DisplayTimedTextToPlayer(Player(0),0.,0.,90.,name+": IsUnitInRangeXY radio "+R2SW(rangeBody(u),1,1)+", circulo de impacto "+R2SW(UnitHitShape.radius(u),1,1))
    endmethod
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
        local integer i = 0
        // Test targets of several native sizes stay alive for repeated shots.
        loop
            exitwhen i == targetCount
            if GroundCollision.alive(targets[i]) then
                call SetWidgetLife(targets[i],GetUnitState(targets[i],UNIT_STATE_MAX_LIFE))
            endif
            set i = i+1
        endloop
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
        // Seven sizes, selection scale 1 to 2.25 (UnitHitShape table).
        set targets[0] = CreateUnit(Player(12),'rftg',x+420.,y-80.,180.)
        set targets[1] = CreateUnit(Player(12),'ugho',x+650.,y-80.,180.)
        set targets[2] = CreateUnit(Player(12),'hkni',x+880.,y-80.,180.)
        set targets[3] = CreateUnit(Player(12),'otau',x+1120.,y-80.,180.)
        set targets[4] = CreateUnit(Player(12),'ucry',x+480.,y+240.,180.)
        set targets[5] = CreateUnit(Player(12),'uabo',x+780.,y+240.,180.)
        set targets[6] = CreateUnit(Player(12),'okod',x+1100.,y+240.,180.)
        // Missile models at scale 1 with selection scale = their hit radius / 36.
        // Owned by red (user request) so the native circle shows green; they are not hit.
        set targets[7] = CreateUnit(Player(0),'rfm1',x+420.,y-360.,180.)
        set targets[8] = CreateUnit(Player(0),'rfm2',x+700.,y-360.,180.)
        set targets[9] = CreateUnit(Player(0),'rfm3',x+1000.,y-360.,180.)
        // Bosses: model scale 2 / 3 by object data, and a plain abomination scaled
        // to 2 at runtime (its type keeps selection 2.1 / collision 48).
        set targets[10] = CreateUnit(Player(12),'rbs2',x+450.,y+620.,180.)
        set targets[11] = CreateUnit(Player(12),'rbs3',x+950.,y+620.,180.)
        set targets[12] = CreateUnit(Player(12),'uabo',x+1400.,y+620.,180.)
        call SetUnitScale(targets[12],2.,2.,2.)
        set targetCount = 13
        // Rest each centred model on the ground: fly height = its radius (umvh in
        // rapid_objects.py, Crow Form trick), so the circle and model can be compared.
        set i = 7
        loop
            exitwhen i == 10
            if UnitAddAbility(targets[i],'Amrf') then
                call UnitRemoveAbility(targets[i],'Amrf')
            endif
            call SetUnitFlyHeight(targets[i],GetUnitDefaultFlyHeight(targets[i]),0.)
            // Not paused: a paused unit freezes before the missile's Stand sequence
            // (bolt hidden). They cannot attack (uaen 0); speed 1, no orders.
            call SetUnitAnimation(targets[i],"stand")
            set i = i+1
        endloop
        set i = 0
        loop
            exitwhen i == 7
            call PauseUnit(targets[i],true)
            set i = i+1
        endloop
        call PauseUnit(targets[10],true)
        call PauseUnit(targets[11],true)
        call PauseUnit(targets[12],true)

        if GetLocalPlayer() == Player(0) then
            call ClearSelection()
            call SelectUnit(controller,true)
            call SetCameraTargetController(actor,0.,0.,false)
        endif
        call DisplayTimedTextToPlayer(Player(0),0.,0.,18.,"Rafagas: Q Firebrand (en el mapa principal W Shots I, R Shots II). Clic derecho en suelo para mover. Recast repone 6 sin reiniciar intervalo. -misiles muestra/oculta el panel. -color 0..11 cambia el color (misil y Windwalk); -color solo vuelve al del jugador.")
        call DisplayTimedTextToPlayer(Player(0),0.,0.,30.,"Blancos: el impacto usa el circulo de seleccion nativo (36 x escala de seleccion). Arrastra la seleccion sobre ellos para verlo.")
        // Native range body of each size (collision 24 / 32 / 48 / 96 / 144).
        call report(targets[0],"Blanco ucol 24")
        call report(targets[2],"Caballero ucol 32")
        call report(targets[5],"Abominacion ucol 48")
        call report(targets[10],"Jefe x2 ucol 96")
        call report(targets[11],"Jefe x3 ucol 144")
        call report(targets[12],"Abominacion SetUnitScale 2")
        set actor = null
        set controller = null
    endmethod
    // "-color N" (0..11) tints the pair like player color N; "-color" alone restores
    // the owner's. Lets one player check every missile/Windwalk color.
    private static method recolor takes nothing returns nothing
        local string text = GetEventPlayerChatString()
        local integer n
        if pair == 0 then
            return
        endif
        if StringLength(text) <= 7 then
            call pair.clearColor()
            return
        endif
        set n = S2I(SubString(text,7,StringLength(text)))
        if n >= 0 and n <= 11 then
            call pair.setColor(ConvertPlayerColor(n))
            call DisplayTimedTextToPlayer(GetTriggerPlayer(),0.,0.,6.,"Color "+I2S(n)+": misil Firebrand "+RapidBolt.firebrandColor(pair.color())+", Shots "+RapidBolt.originalColor(pair.color()))
        endif
    endmethod
    private static method start takes nothing returns nothing
        call setup()
        call DestroyTimer(GetExpiredTimer())
    endmethod
    static method initialize takes nothing returns nothing
        local trigger t
        call TimerStart(CreateTimer(),0.25,false,function thistype.start)
        call TimerStart(CreateTimer(),0.25,true,function thistype.panel)
        set t = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(t,Player(0),"-color",false)
        call TriggerAddAction(t,function thistype.recolor)
        set t = null
    endmethod
endstruct
private function Init takes nothing returns nothing
    call RapidDemo.initialize()
endfunction
endlibrary
