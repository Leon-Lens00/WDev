// Recording-only input driver. Production libraries are included byte-for-byte.
library VideoDemo initializer Init requires RapidFireDemo
globals
    private RapidPair p
    private integer frame = 0
    private boolean running = false
    private timer clock = CreateTimer()
    private unit target
    private destructable tree = null
endglobals
private function Caption takes string s returns nothing
    call ClearTextMessages()
    call DisplayTimedTextToPlayer(Player(0),0.,0.18,6.,s)
endfunction
private function Scene takes real x, real y returns nothing
    call IssueImmediateOrder(p.actor,"stop")
    call SetUnitPosition(p.actor,x,y)
    call p.move(x,y)
    call IssueImmediateOrder(p.actor,"stop")
    call SetUnitFacing(p.actor,0.)
    call PanCameraToTimed(x+300.,y,0.)
endfunction
private function Tick takes nothing returns nothing
    set frame = frame+1
    if frame == 24 then
        call Caption("1. RAFAGA | 6 proyectiles: primer tiro inmediato; intervalo 0.25 s")
    elseif frame == 32 then
        call IssuePointOrder(p.controller,"channel",-3850.,3024.)
    elseif frame == 72 then
        call Caption("2. RECAST | Repone 6 y cambia el objetivo sin juntar disparos")
    elseif frame == 80 then
        call IssuePointOrder(p.controller,"channel",-3850.,3024.)
    elseif frame == 86 then
        call IssuePointOrder(p.controller,"channel",-4000.,3330.)
    elseif frame == 120 then
        call Scene(-4700.,3024.)
        call Caption("3. MOVER + DISPARAR | Transicion a movimiento artificial; velocidad 350")
    elseif frame == 128 then
        call IssuePointOrder(p.controller,"move",-3700.,3024.)
    elseif frame == 132 then
        call IssuePointOrder(p.controller,"channel",-5200.,3024.)
    elseif frame == 138 then
        call IssuePointOrder(p.controller,"channel",-5000.,3300.)
    elseif frame == 143 then
        call IssuePointOrder(p.controller,"move",-3800.,3024.)
    elseif frame == 144 then
        call Caption("Apunta hacia atras mientras avanza. Recast conserva el proximo tiro")
    elseif frame == 152 then
        call Caption("Fin de rafaga: recupera la orden de mover para completar el recorrido")
    elseif frame == 184 then
        call Scene(-4700.,3024.)
        set tree = CreateDestructable('LTlt',-4420.,3024.,0.,1.,0)
        call Caption("4. ARBOL | Bloquea al personaje y detiene los proyectiles")
    elseif frame == 192 then
        call IssuePointOrder(p.controller,"channel",-4050.,3024.)
        call IssuePointOrder(p.controller,"move",-4050.,3024.)
    elseif frame == 202 then
        call IssuePointOrder(p.controller,"channel",-4050.,3024.)
    elseif frame == 224 then
        call RemoveDestructable(tree)
        set tree = null
        call Caption("Obstaculo retirado: vuelve a pasar y los misiles alcanzan el blanco")
        call IssuePointOrder(p.controller,"move",-4150.,3024.)
        call IssuePointOrder(p.controller,"channel",-4050.,3024.)
    elseif frame == 256 then
        call Scene(-1760.,-4480.)
        call Caption("5. DESNIVEL | El movimiento artificial no atraviesa el borde del cliff")
    elseif frame == 264 then
        call IssuePointOrder(p.controller,"channel",-1440.,-4480.)
        call IssuePointOrder(p.controller,"move",-1440.,-4480.)
    elseif frame == 273 then
        call IssuePointOrder(p.controller,"channel",-1440.,-4480.)
    elseif frame == 296 then
        call Scene(-4700.,3024.)
        call Caption("6. DIAGNOSTICO | Rafagas y proyectiles activos vuelven a cero")
        call MultiboardDisplay(MissileStats.board,true)
    elseif frame == 336 then
        call PreloadGenClear()
        call PreloadGenStart()
        call Preload("VIDEO COMPLETE emitted="+I2S(RapidPair.emitted)+" recasts="+I2S(RapidPair.recasts)+" live="+I2S(RapidBolt.live)+" pending="+I2S(RapidPair.remaining))
        call PreloadGenEnd("Logs\\TerrainDev-video-demo-20261021.txt")
        call PauseTimer(clock)
    endif
endfunction
private function Start takes nothing returns nothing
    if running then
        return
    endif
    set running = true
    set p = RapidDemo.pair
    call SetGameSpeed(MAP_SPEED_NORMAL)
    call SetTimeOfDay(12.)
    call SuspendTimeOfDay(true)
    call SetCameraTargetController(null,0.,0.,false)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,1550.,0.)
    call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK,310.,0.)
    call Scene(-4700.,3024.)
    set target = CreateUnit(Player(12),'rftg',-4050.,3024.,180.)
    call PauseUnit(target,true)
    call SetUnitScale(p.actor,1.3,1.3,1.3)
    call MultiboardDisplay(MissileStats.board,false)
    call Caption("TERRAINDEV | Warcraft III Classic 1.27b | Demostracion del sistema real")
    call TimerStart(clock,0.125,true,function Tick)
endfunction
private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-video",true)
    call TriggerAddAction(t,function Start)
    set t = null
endfunction
endlibrary
