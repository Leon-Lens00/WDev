// Engine laboratory only. The lane is selected from the real map, not flattened.
library X3Probe initializer Init requires X3BusterDemo
globals
    private integer checks = 0
    private integer failures = 0
    private integer stage = -1
    private integer search = 0
    private string array lines
    private real since
    private real sx = -4700.
    private real sy = 3024.
    private unit source
    private unit target
    private destructable tree
    private X3Buster shot
    private X3Buster second
    private integer baseline
    private integer births
    private integer hitBase
    private integer wallBase
    private integer satelliteBase
    private boolean one = false
    private timer ticker = CreateTimer()
    private timer showing = CreateTimer()
    private integer array capped
    private integer capIndex = 0
    private real facingImmediate
    private real facingSettled
    private real fallbackAngle
    private RapidPair nativePair
    private real firstDamage = 0.
    private real fusedDamage = 0.
    private trigger damageWatch
    private real catchX
    private real catchY
endglobals
private function Check takes boolean value, string label returns nothing
    set lines[checks] = "PASS "+label
    if not value then
        set lines[checks] = "FAIL "+label
        set failures = failures+1
    endif
    set checks = checks+1
endfunction
private function Save takes string status returns nothing
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("X3 @RUN@ "+status)
    loop
        exitwhen i == checks
        call Preload(lines[i])
        set i = i+1
    endloop
    call Preload("checks="+I2S(checks)+" failures="+I2S(failures)+" casts="+I2S(X3Buster.live)+" live="+I2S(X3Buster.projectiles)+" created="+I2S(X3Buster.created)+" retired="+I2S(X3Buster.retired)+" fusions="+I2S(X3Buster.fusions)+" flashes="+I2S(X3Buster.flashCount()))
    call Preload("facingImmediate="+R2S(facingImmediate)+" facingSettled="+R2S(facingSettled)+" fallbackDegrees="+R2S(fallbackAngle*bj_RADTODEG))
    call Preload("boundaryFirstDamage="+R2S(firstDamage)+" expectedFusedDamage="+R2S(fusedDamage))
    call PreloadGenEnd("Logs\\TerrainDev-@RUN@-x3.txt")
endfunction
private function Advance takes integer nextStage returns nothing
    set stage = nextStage
    set since = X3Buster.now()
    set one = false
    call Save("PROGRESS "+I2S(stage))
endfunction
private function Damage takes nothing returns nothing
    if firstDamage == 0. then
        set firstDamage = GetEventDamage()
    endif
endfunction
private function Tick takes nothing returns nothing
    local real elapsed = X3Buster.now()-since
    local real gy
    local real oy
    local integer i
    local X3Buster c
    if stage == 0 then
        if GroundCollision.trace(sx,sy,sx+850.,sy,78.,null,Player(0),false) == 0 then
            set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
            call Check(true,"real unobstructed lane found")
            set shot = X3Buster.fire(source,sx+1400.,sy,0)
            call Check(shot != 0 and shot.bodies == 1,"charged shot creates one body")
            call Check(shot.pulse.model == "X3Buster\\X3_Buster_Cargado.mdx","charged model A selected")
            call Check(RAbsBJ(shot.pulse.scale-1.) < 0.001,"charged width58 matches radius29")
            call Advance(1)
        else
            set search = search+1
            set sy = sy-160.
            if search == 35 then
                call Check(false,"real unobstructed lane found")
                call Save("COMPLETE")
                call PauseTimer(ticker)
            endif
        endif
    elseif stage == 1 and elapsed >= 0.2 then
        call Check(shot.pulse.x > sx+180. and shot.pulse.x < sx+310.,"charged advances at1100 per second")
        call Check(RAbsBJ(shot.pulse.y-sy) < 0.01,"charged flight remains straight")
        call Check(RAbsBJ(GetUnitX(source)-sx) < 0.01,"physics does not move caster")
        call shot.cancel()
        call Advance(2)
    elseif stage == 2 and elapsed >= 0.125 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0,"cancel retires charged body and cast")
        set baseline = X3Buster.fusions
        set births = X3Buster.created
        set satelliteBase = X3Buster.satellites
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        call Check(shot.bodies == 2 and shot.pulse == 0 and shot.waiting,"two orbs precede delayed pulse")
        call Advance(3)
    elseif stage == 3 then
        if elapsed >= 0.125 and not one then
            set one = true
            set gy = GetUnitY(shot.green.dummy)
            set oy = GetUnitY(shot.orange.dummy)
            call Check(RAbsBJ(gy-oy) > 1.,"two bodies orbit independently in XY")
            call Check(RAbsBJ(gy+oy-2.*sy) < 0.1,"orb offsets remain opposite")
            call Check(GetUnitFlyHeight(shot.green.dummy) > GetUnitFlyHeight(shot.orange.dummy)+1.,"orbit includes opposite height offsets")
            call Check(shot.pulse == 0,"no early second pulse")
        endif
        if elapsed >= 0.32 then
            call Check(shot.pulse != 0 and shot.pulse.x < shot.green.x,"second pulse launches behind orbs")
            call Check(X3Buster.fusions == baseline,"separation alone cannot trigger fusion")
            call Advance(4)
        endif
    elseif stage == 4 and elapsed >= 0.35 then
        call Check(shot.state == 2 and X3Buster.fusions == baseline+1,"catching pulse produces exactly one fusion")
        call Check(shot.green == 0 and shot.orange == 0 and shot.pulse == 0,"three precursor bodies retired after union")
        call Check(shot.fused != 0 and shot.fused.model == "X3Buster\\X3_Cross_Buster.mdx","union produces model C")
        call Check(X3Buster.satellites == satelliteBase+4,"union emits four satellites")
        call Check(X3Buster.created == births+8,"bounded emission budget eight bodies per super shot")
        call Check(X3Buster.lastFusionX > sx+300. and X3Buster.lastFusionX < sx+430.,"fusion occurs at actual catch location")
        call Check(X3Buster.lastFusionAge > 0.48 and X3Buster.lastFusionAge < 0.68,"catch timing matches relative speeds")
        call Check(shot.sat1.y < shot.sat4.y,"satellites separate in a fan")
        call Advance(5)
    elseif stage == 5 and elapsed >= 1.7 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0,"complete super shot leaves no active bodies")
        call Check(X3Buster.flashCount() == 0,"union flash cleans up its own timer and dummy")
        call Check(X3Buster.created == X3Buster.retired,"all emitted bodies retired exactly once")
        set baseline = X3Buster.fusions
        set shot = X3Buster.fire(source,sx+1400.,sy,2)
        call Advance(6)
    elseif stage == 6 and elapsed >= 0.16 then
        call Check(shot.pulse == 0 and shot.waiting,"manual API waits for release")
        call Check(shot.releasePulse(),"manual release emits one pulse")
        call Check(not shot.releasePulse(),"duplicate release is rejected")
        call Advance(7)
    elseif stage == 7 and elapsed >= 0.5 then
        call Check(X3Buster.fusions == baseline+1,"manual second pulse can fuse")
        call shot.cancel()
        call Advance(8)
    elseif stage == 8 and elapsed >= 0.125 then
        set baseline = X3Buster.fusions
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        call shot.green.destroy()
        call Advance(9)
    elseif stage == 9 and elapsed >= 0.8 then
        call Check(X3Buster.fusions == baseline and shot.fused == 0,"missing orb prevents fusion")
        call shot.cancel()
        call Advance(10)
    elseif stage == 10 and elapsed >= 0.125 then
        set baseline = X3Buster.fusions
        set hitBase = X3Buster.hits
        set target = CreateUnit(Player(12),'rftg',sx+120.,sy,180.)
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        call Advance(11)
    elseif stage == 11 and elapsed >= 0.9 then
        call Check(X3Buster.hits > hitBase and GetWidgetLife(target) < 2000.,"real enemy collision applies damage")
        call Check(X3Buster.fusions == baseline,"enemy impact before union prevents fusion")
        call RemoveUnit(target)
        set target = null
        call shot.cancel()
        call Advance(12)
    elseif stage == 12 and elapsed >= 0.125 then
        set baseline = X3Buster.fusions
        set wallBase = X3Buster.walls
        set tree = CreateDestructable('LTlt',sx+130.,sy,0.,1.,0)
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        call Advance(13)
    elseif stage == 13 and elapsed >= 0.9 then
        call Check(X3Buster.walls > wallBase,"real destructible blocks projectile sweeps")
        call Check(X3Buster.fusions == baseline,"obstacle before union prevents fusion")
        call RemoveDestructable(tree)
        set tree = null
        call shot.cancel()
        call Advance(14)
    elseif stage == 14 and elapsed >= 0.125 then
        set baseline = X3Buster.fusions
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        set second = X3Buster.fire(source,sx+1400.,sy,1)
        call Advance(15)
    elseif stage == 15 and elapsed >= 0.75 then
        call Check(X3Buster.fusions == baseline+2,"simultaneous casts fuse only their own components")
        call Check(shot.fused != second.fused and shot.state == 2 and second.state == 2,"independent resulting missiles per cast")
        call shot.cancel()
        call second.cancel()
        call Advance(16)
    elseif stage == 16 and elapsed >= 0.125 then
        call SetUnitFacing(source,90.)
        set facingImmediate = GetUnitFacing(source)
        set shot = X3Buster.fire(source,sx,sy,0)
        set fallbackAngle = shot.angle
        call Check(RAbsBJ(shot.angle-facingImmediate*bj_DEGTORAD) < 0.01,"zero-distance aim falls back to unit facing")
        call shot.cancel()
        call Advance(17)
    elseif stage == 17 and elapsed >= 0.5 then
        set facingSettled = GetUnitFacing(source)
        call Check(RAbsBJ(facingSettled-90.) < 0.1,"native facing reaches requested angle after motor ticks")
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        call RemoveUnit(source)
        set source = null
        call Advance(18)
    elseif stage == 18 and elapsed >= 0.2 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0,"removed caster cancels pending and flying bodies")
        call Check(X3Buster.created == X3Buster.retired,"interrupted casts preserve balanced lifecycle")
        set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
        set capIndex = 0
        call Advance(19)
    elseif stage == 19 then
        set i = 0
        loop
            exitwhen i == 4
            set capped[capIndex] = X3Buster.fire(source,sx+1400.,sy,2)
            set capIndex = capIndex+1
            set i = i+1
        endloop
        if capIndex < 64 then
            return
        endif
        set c = X3Buster.fire(source,sx+1400.,sy,2)
        call Check(c == 0 and X3Buster.live == 64,"concurrent cast limit rejects overflow")
        set i = 0
        loop
            exitwhen i == 64
            call X3Buster(capped[i]).cancel()
            set i = i+1
        endloop
        call Advance(20)
    elseif stage == 20 and elapsed >= 0.5 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0,"all capped and cancelled casts retire")
        call Check(X3Buster.created == X3Buster.retired,"final created equals retired")
        call Check(X3Buster.flashCount() == 0,"final flash count zero")
        call RemoveUnit(source)
        set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
        set nativePair = RapidPair.create(CreateUnit(Player(0),'rfct',WorldBounds.minX+256.,WorldBounds.minY+256.,0.),source)
        set births = X3Buster.created
        call Check(IssuePointOrder(nativePair.controller,"carrionswarm",sx+1400.,sy),"native W order accepted by controller")
        call Advance(21)
    elseif stage == 21 and elapsed >= 0.25 then
        call Check(X3Buster.created == births+1,"native W spell event creates charged physics")
        call Check(GetUnitCurrentOrder(source) == 0,"visible executor receives no spell order")
        call Advance(22)
    elseif stage == 22 and elapsed >= 1.5 then
        set births = X3Buster.created
        set baseline = X3Buster.fusions
        call Check(IssuePointOrder(nativePair.controller,"shockwave",sx+1400.,sy),"native E order accepted by controller")
        call Advance(23)
    elseif stage == 23 and elapsed >= 0.75 then
        call Check(X3Buster.fusions == baseline+1 and X3Buster.created == births+8,"native E spell event completes cross-shot sequence")
        call Advance(24)
    elseif stage == 24 and elapsed >= 1. then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0 and X3Buster.created == X3Buster.retired,"native abilities leave balanced zero-active state")
        call nativePair.destroy()
        set baseline = X3Buster.fusions
        set shot = X3Buster.fire(source,sx+1400.,sy,1)
        call Advance(25)
    elseif stage == 25 then
        if shot.pulse != 0 then
            set gy = shot.green.x-shot.pulse.x
            if gy > 0. and gy <= (X3Buster.PULSE_SPEED-X3Buster.ORBIT_SPEED)/32. then
                set catchX = shot.green.x+gy*X3Buster.ORBIT_SPEED/(X3Buster.PULSE_SPEED-X3Buster.ORBIT_SPEED)
                set catchY = sy
                set target = CreateUnit(Player(12),'rftg',catchX+50.,catchY,180.)
                set i = 0
                loop
                    call SetUnitX(target,catchX+50.+I2R(i)*2.)
                    exitwhen (GroundCollision.trace(shot.pulse.x,sy,catchX,sy,29.,source,Player(0),true) == 0 and GroundCollision.trace(shot.pulse.x,sy,shot.pulse.x+X3Buster.PULSE_SPEED/32.,sy,29.,source,Player(0),true) == 2) or i == 25
                    set i = i+1
                endloop
                call Check(i < 25,"boundary fixture clear before union and enemy later in same tick")
                set damageWatch = CreateTrigger()
                call TriggerRegisterUnitEvent(damageWatch,target,EVENT_UNIT_DAMAGED)
                call TriggerAddAction(damageWatch,function Damage)
                // Calibrate native armor/resistance before observing the shot.
                call UnitDamageTarget(source,target,150.,false,false,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_MAGIC,null)
                set fusedDamage = firstDamage
                set firstDamage = 0.
                call SetWidgetLife(target,2000.)
                call Advance(26)
            endif
        endif
        if elapsed > 1. then
            call Check(false,"boundary fixture clear before union and enemy later in same tick")
            call Advance(26)
        endif
    elseif stage == 26 and elapsed >= 0.3 then
        call Check(X3Buster.fusions == baseline+1 and fusedDamage > 0. and RAbsBJ(firstDamage-fusedDamage) < 0.1,"fusion precedes later enemy impact inside the same tick")
        call DestroyTrigger(damageWatch)
        set damageWatch = null
        call RemoveUnit(target)
        set target = null
        call shot.cancel()
        call Advance(27)
    elseif stage == 27 and elapsed >= 0.2 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0 and X3Buster.created == X3Buster.retired,"boundary case cleanup remains balanced")
        call RemoveUnit(source)
        set source = null
        call Save("COMPLETE")
        call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"X3 COMPLETE "+I2S(checks)+" checks / "+I2S(failures)+" failures. -x3show para demostracion.")
        call PauseTimer(ticker)
        set stage = -2
    endif
endfunction
private function Begin takes nothing returns nothing
    if stage != -1 then
        return
    endif
    set stage = 0
    set since = X3Buster.now()
    call TimerStart(ticker,1./32.,true,function Tick)
endfunction
private function Repeat takes nothing returns nothing
    local X3Buster s = X3Buster.fire(source,sx+1400.,sy,1)
endfunction
private function Show takes nothing returns nothing
    if stage != -2 then
        return
    endif
    set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
    call SetCameraTargetController(null,0.,0.,false)
    call PanCameraToTimed(sx+450.,sy,0.)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,1350.,0.)
    call FogEnable(false)
    call FogMaskEnable(false)
    call SetTimeOfDay(12.)
    call SuspendTimeOfDay(true)
    call MultiboardDisplay(MissileStats.board,false)
    call ClearTextMessages()
    call TimerStart(showing,2.5,true,function Repeat)
    call Repeat()
endfunction
private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-x3test",true)
    call TriggerAddAction(t,function Begin)
    set t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-x3show",true)
    call TriggerAddAction(t,function Show)
    set t = null
endfunction
endlibrary
