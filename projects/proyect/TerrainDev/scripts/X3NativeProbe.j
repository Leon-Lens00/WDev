// Test-only lifecycle/integration lab; mathematical expectations come from CSV.
library X3NativeProbe initializer Init requires X3Probe, X3Oracle
globals
    private integer checks = 0
    private integer failures = 0
    private string array lines
    private integer stage = -1
    private timer ticker = CreateTimer()
    private real since = 0.
    private real formationStarted
    private real sx
    private real sy
    private unit source
    private unit target
    private destructable tree
    private X3Buster shot
    private X3Buster second
    private RapidPair pair
    private integer births
    private integer merges
    private integer baseCreated
    private integer baseRetired
    private integer baseHits
    private integer baseWalls
    private boolean sawFormation
    private integer visualProfile = 1
    private timer showing = CreateTimer()
    private string diagnostics = ""
    private real targetBirthLife
    private real unionRecordX
    private real unionRecordY
    private real unionAngle
    private real targetX
    private real targetY
endglobals
private function Check takes boolean ok, string label returns nothing
    set lines[checks] = "PASS "+label
    if not ok then
        set lines[checks] = "FAIL "+label
        set failures = failures+1
        call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,lines[checks])
    endif
    set checks = checks+1
endfunction
private function Save takes string status returns nothing
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("NATIVE @RUN@ "+status)
    loop
        exitwhen i == checks
        call Preload(lines[i])
        set i = i+1
    endloop
    call Preload("checks="+I2S(checks)+" failures="+I2S(failures)+" oracle="+I2S(X3Oracle.valueChecks)+" oracleFailures="+I2S(X3Oracle.valueFailures)+" maxError="+R2S(X3Oracle.maxError))
    call Preload(diagnostics)
    call Preload("casts="+I2S(X3Buster.live)+" live="+I2S(X3Buster.projectiles)+" created="+I2S(X3Buster.created-baseCreated)+" retired="+I2S(X3Buster.retired-baseRetired)+" flashes="+I2S(X3Buster.flashCount()))
    call PreloadGenEnd("Logs\\TerrainDev-@RUN@-native.txt")
endfunction
private function Advance takes integer n returns nothing
    set stage = n
    set since = X3Buster.now()
    call Save("PROGRESS "+I2S(n))
endfunction
private function Position takes Missile m, integer form, real ox, real oy, real angle, integer profile returns boolean
    local real t = X3Buster.ageOf(m)
    local real x = X3Kinematics.forward(profile,form,t)
    local real y = X3Kinematics.side(profile,form,t)
    if form == 1 or form == 2 or form == 9 then
        set x = X3Kinematics.orbitForward(form,t)
    endif
    return RAbsBJ(GetUnitX(m.dummy)-(ox+x*Cos(angle)-y*Sin(angle))) < 0.15 and RAbsBJ(GetUnitY(m.dummy)-(oy+x*Sin(angle)+y*Cos(angle))) < 0.15
endfunction
private function Tick takes nothing returns nothing
    local real elapsed = X3Buster.now()-since
    if elapsed > 9. then
        call Check(false,"bounded stage timeout "+I2S(stage))
        call Save("TIMEOUT")
        call PauseTimer(ticker)
        return
    endif
    if stage == 0 then
        call X3Oracle.step()
        if X3Oracle.done then
            call Check(X3Oracle.valueChecks == 5259 and X3Oracle.valueFailures == 0,"5259 ROM CSV values match vJASS within 0.012 world units")
            set sx = X3ProbeLaneX()
            set sy = X3ProbeLaneY()
            set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
            set births = X3Buster.created
            set merges = X3Buster.fusions
            set shot = X3Buster.fireProfile(source,sx+1400.,sy,2,X3Buster.ORIGINAL)
            call Check(shot != 0 and shot.profile == 1 and shot.bodies == 3 and shot.blue != 0,"USA starts three owned helix components")
            call Check(Position(shot.green,1,shot.originX,shot.originY,shot.angle,1) and Position(shot.orange,2,shot.originX,shot.originY,shot.angle,1) and Position(shot.blue,9,shot.originX,shot.originY,shot.angle,1),"three components start at their native offsets")
            call Advance(1)
        endif
    elseif stage == 1 and elapsed >= 0.18 then
        call Check(Position(shot.green,1,shot.originX,shot.originY,shot.angle,1) and Position(shot.orange,2,shot.originX,shot.originY,shot.angle,1) and Position(shot.blue,9,shot.originX,shot.originY,shot.angle,1),"three rendered helix paths follow native knots")
        call Check(shot.releasePulse(),"manual USA second pulse accepted")
        call Advance(2)
    elseif stage == 2 and shot.forming then
        set formationStarted = X3Buster.now()
        call Check(shot.state == 4 and shot.fused == 0 and X3Buster.created == births+4,"USA union retires four precursors before five-body emission")
        call Check(X3Buster.fusions == merges+1 and X3Buster.flashCount() == 1,"USA union has exactly one flash and one fusion")
        call Check(RAbsBJ(X3Buster.lastFusionX-shot.originX) < 0.15,"union relocates to the still-growing second pulse")
        call Advance(3)
    elseif stage == 3 and elapsed >= 0.09 then
        call Check(shot.forming and shot.fused == 0 and X3Buster.projectiles == 0,"USA formation retains cast with zero missile bodies")
        call Advance(4)
    elseif stage == 4 and not shot.forming then
        call Check(shot.state == 2 and shot.bodies == 5 and X3Buster.created == births+9,"USA emits core plus four satellites exactly once")
        call Check(RAbsBJ(X3Buster.now()-formationStarted-X3Kinematics.formation(1)) < 0.05,"USA formation lasts native 18 frames within engine tick tolerance")
        call Advance(5)
    elseif stage == 5 and elapsed >= 0.12 then
        call Check(Position(shot.fused,4,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,1),"USA core render follows native acceleration")
        call Check(Position(shot.sat1,5,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,1) and Position(shot.sat2,6,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,1) and Position(shot.sat3,7,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,1) and Position(shot.sat4,8,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,1),"USA four rendered satellites follow native retreat and separation")
        call Check(GetUnitX(shot.sat1.dummy) < X3Buster.lastFusionX-40.,"USA first pair visibly retreats before accelerating")
        call shot.cancel()
        call Advance(6)
    elseif stage == 6 and elapsed >= 0.3 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0,"USA cancellation retires every body")
        call SetUnitX(source,sx+750.)
        set births = X3Buster.created
        set merges = X3Buster.fusions
        set shot = X3Buster.fireProfile(source,sx-650.,sy,1,2)
        call Check(shot != 0 and shot.profile == 2 and shot.bodies == 3,"Zero Project starts independently facing left")
        call Advance(7)
    elseif stage == 7 and shot.forming then
        set formationStarted = X3Buster.now()
        call Check(X3Buster.fusions == merges+1 and X3Buster.created == births+4 and shot.fused == 0,"Zero Project automatic second pulse enters formation")
        call Advance(8)
    elseif stage == 8 and not shot.forming then
        call Check(shot.state == 2 and shot.bodies == 5 and X3Buster.created == births+9,"Zero Project emits five bodies")
        call Check(RAbsBJ(X3Buster.now()-formationStarted-X3Kinematics.formation(2)) < 0.05,"Zero Project formation lasts native 8 frames within engine tick tolerance")
        call Advance(9)
    elseif stage == 9 and elapsed >= 0.15 then
        call Check(Position(shot.fused,4,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,2),"Zero Project core has immediate native capped speed")
        call Check(Position(shot.sat1,5,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,2) and Position(shot.sat2,6,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,2) and Position(shot.sat3,7,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,2) and Position(shot.sat4,8,X3Buster.lastFusionX,X3Buster.lastFusionY,shot.angle,2),"Zero Project four curved trajectories rotate correctly to left")
        call shot.cancel()
        call Advance(10)
    elseif stage == 10 and elapsed >= 0.3 then
        call SetUnitX(source,sx)
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,2,1)
        call shot.releasePulse()
        call Advance(11)
    elseif stage == 11 and shot.forming then
        set births = X3Buster.created
        call shot.cancel()
        call Advance(12)
    elseif stage == 12 and elapsed >= 0.5 then
        call Check(X3Buster.created == births and X3Buster.live == 0 and X3Buster.projectiles == 0 and X3Buster.flashCount() == 0,"cancelling formation releases its timer without delayed emission or flash leak")
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,2,1)
        set merges = X3Buster.fusions
        call shot.blue.destroy()
        call shot.releasePulse()
        call Advance(13)
    elseif stage == 13 and elapsed >= 0.6 then
        call Check(X3Buster.fusions == merges and not shot.forming,"missing third helix component prevents native union")
        call shot.cancel()
        call Advance(14)
    elseif stage == 14 and elapsed >= 0.2 then
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,2,2)
        call shot.releasePulse()
        call Advance(15)
    elseif stage == 15 and shot.forming then
        set births = X3Buster.created
        call KillUnit(source)
        call Advance(16)
    elseif stage == 16 and elapsed >= 0.4 then
        call Check(X3Buster.created == births and X3Buster.live == 0 and X3Buster.projectiles == 0,"dead source during formation cannot emit delayed bodies")
        call RemoveUnit(source)
        set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
        set births = X3Buster.created
        set merges = X3Buster.fusions
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,1,1)
        set second = X3Buster.fireProfile(source,sx+1400.,sy,1,2)
        call Advance(17)
    elseif stage == 17 and elapsed >= 0.85 then
        call Check(X3Buster.fusions == merges+2 and X3Buster.created == births+18,"simultaneous USA and mod casts keep separate pairs and formation timers")
        call Check(shot.profile == 1 and second.profile == 2,"profile remains immutable for each live cast")
        call shot.cancel()
        call second.cancel()
        call Advance(18)
    elseif stage == 18 and elapsed >= 0.3 then
        set pair = RapidPair.create(CreateUnit(Player(0),'rfct',WorldBounds.minX+256.,WorldBounds.minY+256.,0.),source)
        set X3Demo.profile = 1
        set births = X3Buster.created
        set merges = X3Buster.fusions
        call Check(IssuePointOrder(pair.controller,"shockwave",sx+1400.,sy),"controller accepts native E USA order")
        call Advance(19)
    elseif stage == 19 and elapsed >= 0.85 then
        call Check(X3Buster.fusions == merges+1 and X3Buster.created == births+9,"native E selects the three-component USA sequence")
        call Check(GetUnitCurrentOrder(source) == 0,"native E does not issue a spell order to visible actor")
        call Advance(20)
    elseif stage == 20 and elapsed >= 3.8 then
        set births = X3Buster.created
        set merges = X3Buster.fusions
        call Check(IssuePointOrder(pair.controller,"breathoffire",sx+1400.,sy),"controller accepts native R Zero Project order")
        call Advance(21)
    elseif stage == 21 and elapsed >= 0.8 then
        call Check(X3Buster.fusions == merges+1 and X3Buster.created == births+9,"native R selects Zero Project without conflicting with E or Rapid Fire")
        call Check(GetUnitCurrentOrder(source) == 0,"native R leaves visible actor without a spell order")
        call Advance(22)
    elseif stage == 22 and elapsed >= 3.8 then
        call pair.destroy()
        set baseHits = X3Buster.hits
        set target = CreateUnit(Player(12),'rftg',sx+230.,sy,180.)
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,0,1)
        call Advance(23)
    elseif stage == 23 and elapsed >= 0.65 then
        call Check(X3Buster.hits == baseHits+1 and GetWidgetLife(target) < GetUnitState(target,UNIT_STATE_MAX_LIFE),"native charged pulse sweeps enemy and damages once")
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0,"native charged enemy impact retires pulse")
        call RemoveUnit(target)
        set tree = CreateDestructable('LTlt',sx+230.,sy,0.,1.,0)
        set baseWalls = X3Buster.walls
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,0,2)
        call Advance(24)
    elseif stage == 24 and elapsed >= 0.65 then
        call Check(X3Buster.walls == baseWalls+1 and X3Buster.live == 0,"native charged pulse stops at destructible tree")
        call RemoveDestructable(tree)
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,2,1)
        call shot.releasePulse()
        call Advance(25)
    elseif stage == 25 and shot.forming then
        set baseHits = X3Buster.hits
        set baseWalls = X3Buster.walls
        set unionRecordX = X3Buster.lastFusionX
        set target = CreateUnit(Player(12),'rftg',unionRecordX-90.,sy+20.,0.)
        set targetBirthLife = GetWidgetLife(target)
        set diagnostics = "baselineBehind="+I2S(GroundCollision.trace(unionRecordX,sy,unionRecordX-120.,sy+36.,12.65,source,Player(0),false))+" requested="+R2S(unionRecordX-90.)+","+R2S(sy+20.)+" actual="+R2S(GetUnitX(target))+","+R2S(GetUnitY(target))
        call Advance(26)
    elseif stage == 26 and elapsed >= 0.5 then
        set diagnostics = diagnostics+" unionY="+R2S(X3Buster.lastFusionY)+" angle="+R2S(shot.angle)+" maxLife="+R2S(GetUnitState(target,UNIT_STATE_MAX_LIFE))+" hits="+I2S(X3Buster.hits-baseHits)+" walls="+I2S(X3Buster.walls-baseWalls)+" life="+R2S(targetBirthLife)+"->"+R2S(GetWidgetLife(target))
        call shot.cancel()
        call RemoveUnit(target)
        call Advance(27)
    elseif stage == 27 and elapsed >= 0.5 then
        call SetUnitX(source,sx+300.)
        set shot = X3Buster.fireProfile(source,sx+1400.,sy,2,1)
        call shot.releasePulse()
        call Advance(28)
    elseif stage == 28 and shot.forming then
        set baseHits = X3Buster.hits
        set baseWalls = X3Buster.walls
        set unionRecordX = X3Buster.lastFusionX
        set unionRecordY = X3Buster.lastFusionY
        set unionAngle = shot.angle
        set targetX = unionRecordX-90.*Cos(unionAngle)-20.*Sin(unionAngle)
        set targetY = unionRecordY-90.*Sin(unionAngle)+20.*Cos(unionAngle)
        set target = CreateUnit(Player(12),'rftg',targetX,targetY,0.)
        // CreateUnit may displace a body to avoid another test's actor. Place the
        // target exactly on the real cast axis, then verify its terrain/position.
        call SetUnitX(target,targetX)
        call SetUnitY(target,targetY)
        set targetBirthLife = GetWidgetLife(target)
        call Check(GroundCollision.trace(unionRecordX,unionRecordY,unionRecordX-120.*Cos(unionAngle)-36.*Sin(unionAngle),unionRecordY-120.*Sin(unionAngle)+36.*Cos(unionAngle),12.65,source,Player(0),false) == 0 and RAbsBJ(GetUnitX(target)-targetX) < 1. and RAbsBJ(GetUnitY(target)-targetY) < 1.,"native retreat fixture has clear terrain and undisplaced target")
        set diagnostics = diagnostics+" correctTarget="+R2S(targetX)+","+R2S(targetY)+" actualUnion="+R2S(unionRecordX)+","+R2S(unionRecordY)+" actualAngle="+R2S(unionAngle)
        call Advance(29)
    elseif stage == 29 and elapsed >= 0.5 then
        call Check(X3Buster.hits > baseHits and GetWidgetLife(target) < targetBirthLife,"native retreating satellites sweep enemies behind union point")
        set diagnostics = diagnostics+" relocatedHits="+I2S(X3Buster.hits-baseHits)+" relocatedWalls="+I2S(X3Buster.walls-baseWalls)+" relocatedLife="+R2S(targetBirthLife)+"->"+R2S(GetWidgetLife(target))
        call shot.cancel()
        call RemoveUnit(target)
        call Advance(30)
    elseif stage == 30 and elapsed >= 0.5 then
        call Check(X3Buster.live == 0 and X3Buster.projectiles == 0 and X3Buster.flashCount() == 0,"native tests finish with zero casts projectiles and flashes")
        call Check(X3Buster.created-baseCreated == X3Buster.retired-baseRetired,"all native created bodies retire exactly once")
        call RemoveUnit(source)
        set source = null
        call Save("COMPLETE")
        call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"NATIVE COMPLETE "+I2S(checks)+" checks / "+I2S(failures)+" failures; oracle "+I2S(X3Oracle.valueFailures)+". -usa / -zero para ver.")
        call PauseTimer(ticker)
        set stage = -2
    endif
endfunction
private function Begin takes nothing returns nothing
    if stage != -1 then
        return
    endif
    set baseCreated = X3Buster.created
    set baseRetired = X3Buster.retired
    call Advance(0)
    call TimerStart(ticker,1./32.,true,function Tick)
endfunction
private function Repeat takes nothing returns nothing
    local X3Buster s = X3Buster.fireProfile(source,sx+1400.,sy,1,visualProfile)
    call SetUnitAnimation(source,"attack")
endfunction
private function Show takes nothing returns nothing
    if stage != -2 then
        return
    endif
    if source == null then
        set source = CreateUnit(Player(0),'rfex',sx,sy,0.)
    endif
    set visualProfile = 1
    if GetEventPlayerChatString() == "-zero" then
        set visualProfile = 2
    endif
    call SetCameraTargetController(null,0.,0.,false)
    call PanCameraToTimed(sx+400.,sy,0.)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,1000.,0.)
    call FogEnable(false)
    call FogMaskEnable(false)
    call SetTimeOfDay(12.)
    call SuspendTimeOfDay(true)
    call MultiboardDisplay(MissileStats.board,false)
    call ClearTextMessages()
    call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"Perfil "+I2S(visualProfile)+" : 1 USA / 2 Zero Project")
    call TimerStart(showing,2.5,true,function Repeat)
endfunction
private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-native",true)
    call TriggerAddAction(t,function Begin)
    set t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-usa",true)
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-zero",true)
    call TriggerAddAction(t,function Show)
    set t = null
endfunction
endlibrary
