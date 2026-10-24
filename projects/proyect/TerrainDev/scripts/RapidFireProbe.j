// Engine laboratory, excluded from the delivered map.
library RapidFireProbe initializer Init requires RapidFireDemo
globals
    private RapidPair p = 0
    private RapidPair q = 0
    private integer stage = 0
    private integer checks = 0
    private integer failures = 0
    private string array lines
    private integer count = 0
    private real since
    private real sx = -4700.
    private real sy = 3024.
    private integer baseline
    private integer createdBaseline
    private Missile oldFlight
    private integer instants
    private integer expectedHandoffs
    private integer expectedHits
    private integer expectedWalls
    private real startX
    private real startY
    private real expectedNext
    private real last = -1000.
    private real minimum = 99999.
    private integer observed = 0
    private boolean one = false
    private boolean two = false
    private unit target
    private destructable tree
    private timer t = null
    private real cx1 = 0.
    private real cy1 = 0.
    private real cx2 = 0.
    private real cy2 = 0.
    private integer cliffIndex = 0
    private real firstEmission = -1.
    private real firstEnd = -1.
endglobals
private function Note takes string s returns nothing
    set lines[count] = s
    set count = count+1
endfunction
private function Check takes boolean ok, string label returns nothing
    set checks = checks+1
    if ok then
        call Note("PASS "+label)
    else
        set failures = failures+1
        call Note("FAIL "+label)
    endif
endfunction
private function Save takes string status returns nothing
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("RAPID @RUN@ "+status)
    loop
        exitwhen i == count
        call Preload(lines[i])
        set i = i+1
    endloop
    call Preload("checks="+I2S(checks)+" failures="+I2S(failures)+" observed="+I2S(observed)+" minimum="+R2S(minimum)+" emitted="+I2S(RapidPair.emitted)+" live="+I2S(RapidBolt.live)+" pairs="+I2S(RapidPair.pairs))
    call PreloadGenEnd("Logs\\TerrainDev-@RUN@-rapid.txt")
endfunction
private function Advance takes integer value returns nothing
    set stage = value
    set since = RapidPair.now()
    set one = false
    set two = false
    call Save("PROGRESS stage="+I2S(stage))
endfunction
private function Body takes real x, real y returns RapidPair
    return RapidPair.create(CreateUnit(Player(0),'rfct',WorldBounds.minX+256.,WorldBounds.minY+256.,0.),CreateUnit(Player(0),'rfex',x,y,0.))
endfunction
private function Reset takes nothing returns nothing
    local unit body = p.actor
    call p.destroy()
    call RemoveUnit(body)
    set p = Body(sx,sy)
    set body = null
endfunction
private function CliffCase takes integer i returns nothing
    if i == 0 then
        set cx1 = -3168.
        set cy1 = -5632.
        set cx2 = -2848.
        set cy2 = -5632.
    elseif i == 1 then
        set cx1 = -1760.
        set cy1 = -4480.
        set cx2 = -1440.
        set cy2 = -4480.
    elseif i == 2 then
        set cx1 = -5504.
        set cy1 = -3424.
        set cx2 = -5504.
        set cy2 = -3104.
    elseif i == 3 then
        set cx1 = -5376.
        set cy1 = -3424.
        set cx2 = -5376.
        set cy2 = -3104.
    elseif i == 4 then
        set cx1 = 2048.
        set cy1 = -2784.
        set cx2 = 2048.
        set cy2 = -2464.
    elseif i == 5 then
        set cx1 = 2176.
        set cy1 = 800.
        set cx2 = 2176.
        set cy2 = 1120.
    elseif i == 6 then
        set cx1 = 2304.
        set cy1 = 800.
        set cx2 = 2304.
        set cy2 = 1120.
    elseif i == 7 then
        set cx1 = 2432.
        set cy1 = 800.
        set cx2 = 2432.
        set cy2 = 1120.
    elseif i == 8 then
        set cx1 = 1824.
        set cy1 = 1152.
        set cx2 = 2144.
        set cy2 = 1152.
    elseif i == 9 then
        set cx1 = -2944.
        set cy1 = 1184.
        set cx2 = -2944.
        set cy2 = 1504.
    elseif i == 10 then
        set cx1 = -2816.
        set cy1 = 1184.
        set cx2 = -2816.
        set cy2 = 1504.
    elseif i == 11 then
        set cx1 = -2688.
        set cy1 = 1184.
        set cx2 = -2688.
        set cy2 = 1504.
    elseif i == 12 then
        set cx1 = -3680.
        set cy1 = 1920.
        set cx2 = -3360.
        set cy2 = 1920.
    elseif i == 13 then
        set cx1 = 1536.
        set cy1 = 1824.
        set cx2 = 1536.
        set cy2 = 2144.
    elseif i == 14 then
        set cx1 = 1664.
        set cy1 = 1824.
        set cx2 = 1664.
        set cy2 = 2144.
    elseif i == 15 then
        set cx1 = -3680.
        set cy1 = 2048.
        set cx2 = -3360.
        set cy2 = 2048.
    elseif i == 16 then
        set cx1 = -5248.
        set cy1 = 5280.
        set cx2 = -5248.
        set cy2 = 5600.
    elseif i == 17 then
        set cx1 = -2016.
        set cy1 = 5504.
        set cx2 = -1696.
        set cy2 = 5504.
    elseif i == 18 then
        set cx1 = -2688.
        set cy1 = 5664.
        set cx2 = -2688.
        set cy2 = 5984.
    elseif i == 19 then
        set cx1 = -2016.
        set cy1 = 5888.
        set cx2 = -1696.
        set cy2 = 5888.
    elseif i == 20 then
        set cx1 = -2016.
        set cy1 = 6016.
        set cx2 = -1696.
        set cy2 = 6016.
    endif
endfunction
private function Tick takes nothing returns nothing
    local real elapsed = RapidPair.now()-since
    local real travelled
    local real angle
    local integer result
    local unit body
    if stage == 1 and p.firing and firstEmission < 0. then
        set firstEmission = p.lastShot
    endif
    if stage == 1 and not p.firing and firstEmission > 0. and firstEnd < 0. then
        set firstEnd = RapidPair.now()
    endif
    if p != 0 and p.lastShot != last and p.lastShot > 0. then
        if last > 0. and p.lastShot-last < minimum then
            set minimum = p.lastShot-last
        endif
        set last = p.lastShot
        set observed = observed+1
        call Note("SHOT stage="+I2S(stage)+" time="+R2S(last)+" pending="+I2S(p.pending)+" aim="+R2S(p.aimX)+","+R2S(p.aimY))
    endif
    if stage == 0 then
        call Save("BEFORE BODY")
        set p = Body(sx,sy)
        call Save("BEFORE TRACE")
        call Check(GroundCollision.trace(sx,sy,sx+320.,sy,24.,p.actor,Player(0),false)==0,"open lane 320 ground units")
        call Save("AFTER TRACE")
        call Check(GetUnitAbilityLevel(p.controller,'Arpf')==1 and GetUnitAbilityLevel(p.actor,'Arpf')==0,"ability only on controller")
        set baseline = RapidPair.emitted
        set createdBaseline = MissileStats.created
        call Check(IssuePointOrder(p.controller,"channel",sx+900.,sy),"native point cast accepted")
        call Advance(1)
    elseif stage == 1 and elapsed > 2.1 then
        call Check(RapidPair.emitted-baseline==6,"native cast emitted exactly six")
        call Check(MissileStats.created-createdBaseline==6 and RapidBolt.live==0,"six real Missile instances created and retired")
        call Check(not p.firing and p.pending==0,"initial burst tail ended")
        call Check(RAbsBJ(firstEnd-firstEmission-1.5)<0.032,"burst protection ends 1.5 seconds after first emission")
        call Note("WINDOW first="+R2S(firstEmission)+" end="+R2S(firstEnd))
        set baseline = RapidPair.emitted
        call p.cast(sx+900.,sy)
        set oldFlight = p.lastMissile
        call Advance(2)
    elseif stage == 2 then
        if elapsed >= 0.125 and not one then
            set expectedNext = p.nextShot
            set expectedHits = RapidPair.emitted
            call p.cast(sx,sy+600.)
            call Check(p.pending==6 and p.nextShot==expectedNext and RapidPair.emitted==expectedHits,"early recast six, same clock, no extra shot")
            call Check(oldFlight.allocated and oldFlight.impact.x==sx+900. and oldFlight.impact.y==sy,"already launched missile keeps its original aim")
            set one = true
        endif
        if elapsed >= 0.28125 and not two then
            call Check(p.lastMissile.impact.y==sy+600. and p.lastMissile.impact.x==sx,"next missile uses new aim")
            set expectedNext = p.nextShot
            set expectedHits = RapidPair.emitted
            call p.cast(sx+800.,sy+100.)
            call Check(p.pending==6 and p.nextShot==expectedNext and RapidPair.emitted==expectedHits,"late recast six, same clock, new aim")
            set two = true
        endif
        if elapsed > 2.2 then
            call Check(RapidPair.emitted-baseline==8 and not p.firing,"two recasts produced eight scheduled emissions")
            call Reset()
            call p.move(sx+1050.,sy)
            call Advance(3)
        endif
    elseif stage == 3 and elapsed > 0.3 then
        call Check(GetUnitCurrentOrder(p.actor)==851986 and GetUnitX(p.actor)>sx+30.,"native locomotion before cast")
        set instants = GroundMotion.instantTransitions
        set expectedHandoffs = GroundMotion.handoffs
        call p.cast(GetUnitX(p.actor),sy+600.)
        set startX = GetUnitX(p.actor)
        set startY = GetUnitY(p.actor)
        call Check(GetUnitCurrentOrder(p.actor)==0 and GroundMotion.instantTransitions==instants+1,"instant first tick cancels native move")
        call Advance(4)
    elseif stage == 4 then
        if elapsed > 0.2 and not one then
            set travelled = GetUnitX(p.actor)-startX
            call Note("MOVE distance="+R2S(travelled)+" seconds="+R2S(elapsed)+" facing="+R2S(GetUnitFacing(p.actor)))
            call Check(RAbsBJ(travelled-350.*elapsed)<15. and RAbsBJ(GetUnitY(p.actor)-startY)<1.,"artificial speed 350 without double native travel")
            call Check(GetUnitFacing(p.actor)>80. and GetUnitFacing(p.actor)<115.,"aim facing independent of movement")
            set expectedNext = p.nextShot
            call p.cast(sx+1000.,sy+500.)
            call Check(p.nextShot==expectedNext and GroundMotion.instantTransitions==instants+1,"moving recast does not repeat instant transition")
            call Check(IssuePointOrder(p.controller,"move",sx+1050.,sy+32.),"proxy point move accepted during burst")
            call Check(p.motion.goalY==sy+32.,"new move target captured")
            set one = true
        endif
        if elapsed > 2. then
            call Check(not p.firing and GroundMotion.handoffs==expectedHandoffs+1 and GetUnitCurrentOrder(p.actor)==851986,"one native handoff for unfinished route")
            call Reset()
            set expectedHandoffs = GroundMotion.handoffs
            call p.cast(sx+900.,sy)
            call p.move(sx+40.,sy)
            call Advance(5)
        endif
    elseif stage == 5 and elapsed > 1.7 then
        call Check(not p.motion.hasGoal and RAbsBJ(GetUnitX(p.actor)-(sx+40.))<3.,"short artificial route arrived")
        call Check(GroundMotion.handoffs==expectedHandoffs and GetUnitCurrentOrder(p.actor)==0,"no native move after arrival")
        call Reset()
        set target = CreateUnit(Player(12),'rftg',sx+160.,sy,0.)
        call PauseUnit(target,true)
        set expectedHits = RapidBolt.hits
        call RapidBolt.shoot(p.actor,sx+500.,sy)
        call Advance(6)
    elseif stage == 6 and elapsed > 0.6 then
        call Check(RapidBolt.hits==expectedHits+1 and GetWidgetLife(target)<2000. and GetWidgetLife(target)>1960.,"projectile expectedHits enemy once and retires")
        call RemoveUnit(target)
        set target = CreateUnit(Player(0),'rftg',sx+110.,sy,0.)
        call PauseUnit(target,true)
        call p.cast(sx+600.,sy)
        call p.move(sx+250.,sy)
        call Advance(7)
    elseif stage == 7 and elapsed > 1.7 then
        call Check(GetUnitX(p.actor)>sx+245.,"artificial movement ignores unit collision")
        call RemoveUnit(target)
        call Reset()
        set tree = CreateDestructable('LTlt',sx+180.,sy,0.,1.,0)
        set target = CreateUnit(Player(12),'rftg',sx+360.,sy,0.)
        call PauseUnit(target,true)
        set expectedWalls = RapidBolt.walls
        set expectedHits = RapidBolt.hits
        call p.cast(sx+600.,sy)
        call p.move(sx+500.,sy)
        call Advance(8)
    elseif stage == 8 and elapsed > 1.4 then
        call Check(p.motion.blocked and GetUnitX(p.actor)<sx+150.,"live tree blocks artificial movement")
        call Check(RapidBolt.walls>expectedWalls and RapidBolt.hits==expectedHits and GetWidgetLife(target)==2000.,"tree stops projectiles before target behind it")
        call KillDestructable(tree)
        call Advance(9)
    elseif stage == 9 and elapsed > 1.2 then
        call Check(not GroundCollision.alive(null),"null units rejected")
        call Check(GetUnitX(p.actor)>sx+200.,"native travel can continue after dead tree")
        call RemoveDestructable(tree)
        call RemoveUnit(target)
        call Reset()
        set q = Body(sx,sy-48.)
        call p.cast(sx+600.,sy)
        call q.cast(sx+600.,sy-48.)
        set expectedNext = q.nextShot
        call p.cast(sx,sy+500.)
        call Check(q.nextShot==expectedNext and q.pending==5 and q.aimY==sy-48.,"two pairs isolated during recast")
        call Advance(10)
    elseif stage == 10 and elapsed > 2. then
        call Check(not p.firing and not q.firing and RapidBolt.live==0 and MissileStats.active==0,"two concurrent emitters and real projectiles drain")
        set body = q.actor
        call q.cast(sx+600.,sy)
        call KillUnit(body)
        set q = 0
        call Advance(11)
    elseif stage == 11 and elapsed > 1.5 then
        call Check(RapidPair.pairs==2 and RapidPair.bursts==0 and RapidPair.remaining==0 and RapidBolt.live==0,"death cleans controller, emitter, pending and projectile state")
        call Check(minimum>=0.249 and minimum<=0.282 and observed>=30,"positive emission coverage with clean intervals")
        call Check(MultiboardGetRowCount(MissileStats.board)==25,"diagnostics extended to 25 rows")
        call Advance(12)
    elseif stage == 12 then
        call CliffCase(cliffIndex)
        if GroundCollision.clear(cx1,cy1,24.) and GroundCollision.clear(cx2,cy2,24.) and RAbsBJ(GroundCollision.height(cx1,cy1)-GroundCollision.height(cx2,cy2))>64. then
            call Note("CLIFF from="+R2S(cx1)+","+R2S(cy1)+" to="+R2S(cx2)+","+R2S(cy2)+" levels="+I2S(GetTerrainCliffLevel(cx1,cy1))+","+I2S(GetTerrainCliffLevel(cx2,cy2)))
            call Check(true,"authored cliff endpoints are walkable with real elevation change")
            call Check(GroundCollision.trace(cx1,cy1,cx2,cy2,24.,p.actor,Player(0),false)==1,"authored cliff blocks swept movement first direction")
            call Check(GroundCollision.trace(cx2,cy2,cx1,cy1,24.,p.actor,Player(0),false)==1,"authored cliff blocks swept movement reverse direction")
            call Advance(13)
        else
            set cliffIndex = cliffIndex+1
            if cliffIndex >= 21 then
                call Check(false,"positive authored cliff coverage was not found")
                call Advance(13)
            endif
        endif
    elseif stage == 13 then
        call Note("RAMP heights="+R2S(GroundCollision.height(-1600.,-4992.))+","+R2S(GroundCollision.height(-1344.,-4992.)))
        call Check(RAbsBJ(GroundCollision.height(-1600.,-4992.)-GroundCollision.height(-1344.,-4992.))>64.,"authored ramp has real elevation change")
        call Check(GroundCollision.trace(-1600.,-4992.,-1344.,-4992.,24.,p.actor,Player(0),false)==0,"authored descending ramp remains walkable")
        call Check(GroundCollision.trace(-1344.,-4992.,-1600.,-4992.,24.,p.actor,Player(0),false)==0,"authored ascending ramp remains walkable")
        call Advance(14)
    elseif stage == 14 then
        call SetTerrainPathable(sx+160.,sy,PATHING_TYPE_WALKABILITY,false)
        call Check(IsTerrainPathable(sx+160.,sy,PATHING_TYPE_WALKABILITY),"native wall pathing really blocked")
        call Check(GroundCollision.trace(sx,sy,sx+320.,sy,24.,p.actor,Player(0),false)==1 and GroundCollision.x<sx+160.,"narrow pathing wall stops a segment spanning both sides")
        call SetTerrainPathable(sx+160.,sy,PATHING_TYPE_WALKABILITY,true)
        call Check(not IsTerrainPathable(sx+160.,sy,PATHING_TYPE_WALKABILITY),"native wall removed before endpoint test")
        call Check(GroundCollision.trace(WorldBounds.maxX-96.,WorldBounds.maxY-96.,WorldBounds.maxX+32.,WorldBounds.maxY+32.,24.,p.actor,Player(0),false)==1,"world edge blocks movement")
        call Reset()
        set target = CreateUnit(Player(12),'rftg',sx+450.,sy,0.)
        call PauseUnit(target,true)
        set expectedHits = RapidBolt.hits
        call RapidBolt.shoot(p.actor,sx+450.,sy)
        call Advance(15)
    elseif stage == 15 and elapsed > 0.6 then
        call Check(RapidBolt.hits==expectedHits+1 and GetWidgetLife(target)<2000.,"target at final missile endpoint is not skipped")
        call RemoveUnit(target)
        call Save("COMPLETE")
        call PauseTimer(t)
        call DestroyTimer(t)
        call DisplayTimedTextToPlayer(Player(0),0.,0.,30.,"RAPID TEST COMPLETE checks="+I2S(checks)+" failures="+I2S(failures))
    endif
    set body = null
endfunction
private function Begin takes nothing returns nothing
    call Note("BEGIN timer="+I2S(GetHandleId(t))+" clock="+R2S(RapidPair.now()))
    call Save("BEGIN")
    set since = RapidPair.now()
    set t = CreateTimer()
    call TimerStart(t,1./32.,true,function Tick)
    call Note("AFTER START timer="+I2S(GetHandleId(t))+" timeout="+R2S(TimerGetTimeout(t))+" expired="+I2S(GetHandleId(GetExpiredTimer())))
    call Save("STARTED")
    call DestroyTimer(GetExpiredTimer())
endfunction
private function Init takes nothing returns nothing
    call TimerStart(CreateTimer(),2.,false,function Begin)
endfunction
endlibrary
