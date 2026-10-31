// Test-only lab for X3Charge. Not imported into production; run after -x3test
// so the lane chosen from the real map is available.
library X3ChargeProbe initializer Init requires X3Probe, X3Charge
globals
    private integer checks = 0
    private integer failures = 0
    private string array lines
    private integer stage = -1
    private timer ticker = CreateTimer()
    private real since = 0.
    private real sx
    private real sy
    private RapidPair pairA
    private RapidPair pairB
    private RapidPair pairC
    private X3Buster shot
    private integer births
    private integer merges
    private integer baseCreated
    private integer baseRetired
    private integer baseBegins
    private integer baseEmpty
    private unit corpse
    private integer slot
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
    call Preload("CHARGE @RUN@ "+status)
    loop
        exitwhen i == checks
        call Preload(lines[i])
        set i = i+1
    endloop
    call Preload("checks="+I2S(checks)+" failures="+I2S(failures))
    call Preload("begins="+I2S(X3Charge.begins)+" charged="+I2S(X3Charge.charged)+" full="+I2S(X3Charge.full)+" empty="+I2S(X3Charge.empty)+" seconds="+I2S(X3Charge.seconds)+" rejected="+I2S(X3Charge.rejected))
    call Preload("casts="+I2S(X3Buster.live)+" live="+I2S(X3Buster.projectiles)+" created="+I2S(X3Buster.created-baseCreated)+" retired="+I2S(X3Buster.retired-baseRetired)+" flashes="+I2S(X3Buster.flashCount()))
    call PreloadGenEnd("Logs\\TerrainDev-@RUN@-charge.txt")
endfunction
private function Advance takes integer n returns nothing
    set stage = n
    set since = X3Buster.now()
    call Save("PROGRESS "+I2S(n))
endfunction
private function NewPair takes real x returns RapidPair
    return RapidPair.create(CreateUnit(Player(0),'rfct',WorldBounds.minX+256.,WorldBounds.minY+256.,0.),CreateUnit(Player(0),'rfex',x,sy,0.))
endfunction
private function Thresholds takes nothing returns boolean
    local real f = 1./X3Kinematics.FPS
    return X3Charge.levelAt(0.) == 0 and X3Charge.levelAt(f) == 2 and X3Charge.levelAt(20.*f) == 2 and X3Charge.levelAt(21.*f) == 4 and X3Charge.levelAt(80.*f) == 4 and X3Charge.levelAt(81.*f) == 6 and X3Charge.levelAt(140.*f) == 6 and X3Charge.levelAt(141.*f) == 8 and X3Charge.levelAt(200.*f) == 8 and X3Charge.levelAt(201.*f) == 10
endfunction
private function Tick takes nothing returns nothing
    local real elapsed = X3Buster.now()-since
    local unit u
    if elapsed > 9. then
        call Check(false,"bounded stage timeout "+I2S(stage))
        call Save("TIMEOUT")
        call PauseTimer(ticker)
        return
    endif
    if stage == 0 then
        call Check(Thresholds(),"levelAt matches the 1/21/81/141/201 native frame thresholds")
        set pairA = NewPair(sx)
        call Check(X3Charge.stateOf(pairA) == X3Charge.IDLE and X3Charge.level(pairA) == 0,"new pair starts without charge")
        set births = X3Buster.created
        set baseEmpty = X3Charge.empty
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.BEGAN,"first press begins charge")
        call Check(not X3Charge.begin(pairA,X3Buster.ORIGINAL),"begin is rejected while already charging")
        call Advance(1)
    elseif stage == 1 and elapsed >= 1.0 then
        call Check(X3Charge.level(pairA) == 4,"about 60 native frames gives level 4")
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.EMPTY and X3Buster.created == births and X3Charge.empty == baseEmpty+1,"release below level 8 fires nothing")
        call Check(X3Charge.stateOf(pairA) == X3Charge.IDLE,"empty release leaves the pair idle")
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.BEGAN,"next press begins a new charge")
        call Advance(2)
    elseif stage == 2 and elapsed >= 2.5 then
        call Check(X3Charge.level(pairA) == 8,"about 150 native frames gives level 8")
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.FIRED and X3Buster.created == births+1,"level 8 release fires one charged pulse")
        call Check(X3Charge.stateOf(pairA) == X3Charge.IDLE,"level 8 release stores no second pulse")
        call Advance(3)
    elseif stage == 3 and elapsed >= 1.8 then
        set births = X3Buster.created
        set merges = X3Buster.fusions
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.BEGAN,"charge for the full sequence begins")
        call Advance(4)
    elseif stage == 4 and elapsed >= 3.5 then
        call Check(X3Charge.level(pairA) == 10,"about 210 native frames gives level 10")
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.FIRED and X3Buster.created == births+3,"level 10 release launches the three helix components")
        call Check(X3Charge.stateOf(pairA) == X3Charge.STORED,"level 10 release stores the second pulse")
        call Advance(5)
    elseif stage == 5 and elapsed >= 0.25 then
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.SECOND,"next press releases the stored pulse")
        call Check(not X3Charge.second(pairA),"repeated second release is rejected")
        call Advance(6)
    elseif stage == 6 and elapsed >= 0.8 then
        call Check(X3Buster.fusions == merges+1 and X3Buster.created == births+9,"stored pulse fuses with its helix into five bodies")
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.BEGAN,"charge for the expiry case begins")
        call Advance(7)
    elseif stage == 7 and elapsed >= 3.5 then
        set births = X3Buster.created
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.FIRED and X3Charge.stateOf(pairA) == X3Charge.STORED,"expiry case stores a pulse")
        call Advance(8)
    elseif stage == 8 and elapsed >= X3Buster.LIFETIME+0.3 then
        set baseBegins = X3Charge.begins
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.BEGAN and X3Buster.created == births+3 and X3Charge.begins == baseBegins+1,"pulse stored past the cast lifetime is dropped and the press begins a new charge")
        call X3Charge.cancel(pairA)
        call Check(X3Charge.stateOf(pairA) == X3Charge.IDLE,"cancel clears the charge")
        // Profile is fixed at begin: release with the other key keeps Zero Project.
        call Check(X3Charge.begin(pairA,X3Buster.ZERO_PROJECT),"Zero Project charge begins")
        call Advance(9)
    elseif stage == 9 and elapsed >= 3.5 then
        set births = X3Buster.created
        set merges = X3Buster.fusions
        set shot = X3Charge.release(pairA,sx+1400.,sy)
        call Check(shot != 0 and shot.profile == X3Buster.ZERO_PROJECT and X3Charge.stateOf(pairA) == X3Charge.STORED,"release keeps the profile chosen at begin")
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.SECOND,"the other charge key releases the stored pulse")
        call Advance(10)
    elseif stage == 10 and elapsed >= 0.8 then
        call Check(X3Buster.fusions == merges+1 and X3Buster.created == births+9,"Zero Project stored pulse fuses")
        set births = X3Buster.created
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.BEGAN,"charge before actor death begins")
        set corpse = pairA.actor
        call KillUnit(corpse)
        call Advance(11)
    elseif stage == 11 and elapsed >= 2.6 then
        call Check(X3Charge.stateOf(pairA) == X3Charge.IDLE and X3Charge.level(pairA) == 0,"dead actor discards the charge")
        call Check(X3Charge.press(pairA,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.REJECTED and X3Buster.created == births,"dead actor cannot fire or begin")
        // RapidPair.tick already destroyed pair A when its actor died.
        call RemoveUnit(corpse)
        set corpse = null
        set pairB = NewPair(sx)
        call Check(X3Charge.begin(pairB,X3Buster.ORIGINAL),"pair B charge begins")
        set slot = pairB
        set u = pairB.actor
        call pairB.destroy()
        call RemoveUnit(u)
        set pairC = NewPair(sx)
        call Check(pairC == slot and X3Charge.stateOf(pairC) == X3Charge.IDLE and X3Charge.level(pairC) == 0,"recycled pair slot does not inherit a charge")
        call Check(X3Charge.press(pairC,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.BEGAN,"recycled pair begins its own charge")
        set pairB = NewPair(sx-300.)
        call Check(X3Charge.press(pairB,X3Buster.ZERO_PROJECT,sx+1400.,sy) == X3Charge.BEGAN,"second simultaneous pair begins")
        // Rapid Fire on the same pair while it charges.
        call pairC.cast(sx+1400.,sy)
        call Check(pairC.firing and X3Charge.stateOf(pairC) == X3Charge.CHARGING,"Rapid Fire during charge keeps the charge")
        call Advance(12)
    elseif stage == 12 and elapsed >= 3.5 then
        set births = X3Buster.created
        set merges = X3Buster.fusions
        call Check(X3Charge.press(pairC,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.FIRED and X3Charge.press(pairB,X3Buster.ZERO_PROJECT,sx+1400.,sy) == X3Charge.FIRED,"two pairs release independent full charges")
        call Check(X3Charge.stateOf(pairC) == X3Charge.STORED and X3Charge.stateOf(pairB) == X3Charge.STORED and X3Buster.created == births+6,"each pair stores its own pulse")
        call Advance(13)
    elseif stage == 13 and elapsed >= 0.25 then
        call Check(X3Charge.press(pairC,X3Buster.ORIGINAL,sx+1400.,sy) == X3Charge.SECOND and X3Charge.press(pairB,X3Buster.ZERO_PROJECT,sx+1400.,sy) == X3Charge.SECOND,"each pair releases only its own stored pulse")
        call Advance(14)
    elseif stage == 14 and elapsed >= 0.8 then
        call Check(X3Buster.fusions == merges+2 and X3Buster.created == births+18,"two simultaneous sequences fuse separately")
        // Native order path: W begins, R at level 8 releases with the USA profile.
        set births = X3Buster.created
        call Check(IssuePointOrder(pairC.controller,"carrionswarm",sx+1400.,sy),"native W order accepted")
        call Advance(15)
    elseif stage == 15 and elapsed >= 0.25 then
        call Check(X3Charge.stateOf(pairC) == X3Charge.CHARGING and X3Buster.created == births,"native W begins the charge")
        call Advance(16)
    elseif stage == 16 and elapsed >= 2.2 then
        call Check(IssuePointOrder(pairC.controller,"breathoffire",sx+1400.,sy),"native R order accepted while W charges")
        call Advance(17)
    elseif stage == 17 and elapsed >= 0.25 then
        call Check(X3Buster.created == births+1 and X3Charge.stateOf(pairC) == X3Charge.IDLE,"native R releases the level 8 charge begun with W")
        call Advance(18)
    elseif stage == 18 and X3Buster.live == 0 and X3Buster.projectiles == 0 then
        call Check(X3Buster.created-baseCreated == X3Buster.retired-baseRetired and X3Buster.flashCount() == 0,"all charge casts retire to a balanced zero-active state")
        set u = pairB.actor
        call pairB.destroy()
        call RemoveUnit(u)
        set u = pairC.actor
        call pairC.destroy()
        call RemoveUnit(u)
        call PauseTimer(ticker)
        call Save("COMPLETE")
        call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"CHARGE COMPLETE "+I2S(checks)+" checks / "+I2S(failures)+" failures.")
    endif
    set u = null
endfunction
private function Begin takes nothing returns nothing
    if stage != -1 then
        return
    endif
    set sx = X3ProbeLaneX()
    set sy = X3ProbeLaneY()
    // Earlier labs may leave the demo on GIF; W must use the delivered USA profile.
    set X3Demo.profile = X3Buster.ORIGINAL
    set baseCreated = X3Buster.created
    set baseRetired = X3Buster.retired
    call Advance(0)
    call TimerStart(ticker,1./32.,true,function Tick)
endfunction
private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t,Player(0),"-charge",true)
    call TriggerAddAction(t,function Begin)
    set t = null
endfunction
endlibrary
