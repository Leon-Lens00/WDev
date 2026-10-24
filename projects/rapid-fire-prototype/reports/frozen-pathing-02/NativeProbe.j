library RFNativeProbe requires RFPathingCandidate, RFNativeReference
    globals
        private timer clock = null
        private trigger castTrigger = null
        private unit actor = null
        private unit controller = null
        private unit blocker = null
        private unit wall = null
        private destructable tree = null
        private item visibleItem = null
        private item hiddenItem = null
        private real itemX
        private real itemY
        private real hiddenX
        private real hiddenY
        private integer which = 1
        private integer phase = 0
        private integer ticks = 0
        private integer gate = 0
        private integer gateWait = 0
        private boolean bodyReady = false
        private real ox = -1280.
        private real oy = -512.
        private real cx
        private real cy
        private integer site = 0
        private integer sample = 0
        private real edge = 0.
        private real corner = 0.
        private real outsideEdge = 0.
        private real outsideCorner = 0.
        private boolean castSeen = false
        private real castX
        private real castY
        private unit castSource = null
        private integer castAbility = 0
        private integer castWait = 0
        private string array ids
    endglobals

    private function ActorSame takes real x, real y, real facing, integer order returns nothing
        call RF_Check(GetUnitX(actor)==x and GetUnitY(actor)==y and GetUnitFacing(actor)==facing and GetUnitCurrentOrder(actor)==order,"actor-public-state-unchanged","actual="+R2S(GetUnitX(actor))+","+R2S(GetUnitY(actor))+" previous="+R2S(x)+","+R2S(y)+" facing="+R2S(GetUnitFacing(actor))+" previousFacing="+R2S(facing)+" order="+I2S(GetUnitCurrentOrder(actor))+" previousOrder="+I2S(order))
    endfunction

    private function ItemsSame takes nothing returns nothing
        if visibleItem != null then
            call RF_Check(IsItemVisible(visibleItem) and not IsItemVisible(hiddenItem) and GetItemX(visibleItem)==itemX and GetItemY(visibleItem)==itemY and GetItemX(hiddenItem)==hiddenX and GetItemY(hiddenItem)==hiddenY,"fixture-items-public-state-restored","visible="+RF_Bool(IsItemVisible(visibleItem))+" hidden="+RF_Bool(IsItemVisible(hiddenItem))+" actual="+R2S(GetItemX(visibleItem))+","+R2S(GetItemY(visibleItem)))
        endif
    endfunction

    private function Query takes string name, real x, real y, integer expected returns boolean
        local real ax = GetUnitX(actor)
        local real ay = GetUnitY(actor)
        local real facing = GetUnitFacing(actor)
        local integer order = GetUnitCurrentOrder(actor)
        local boolean eligible = RF_Eligible(actor,controller,x,y)
        local string detail = "query="+R2S(x)+","+R2S(y)+" eligible="+RF_Bool(eligible)+" walkBlocked="+RF_Bool(IsTerrainPathable(x,y,PATHING_TYPE_WALKABILITY))+" cliff="+I2S(GetTerrainCliffLevel(x,y))
        if not RF_HelperReady() then
            call RF_Record("FAIL","query-invalid-helper-state",detail+"; no negative geometry PASS")
            set eligible = false
        elseif expected < 0 then
            call RF_Record("OBS",name,detail)
        else
            call RF_Check(eligible==(expected==1),name,detail)
        endif
        call ActorSame(ax,ay,facing,order)
        call ItemsSame()
        return eligible
    endfunction

    private function Step takes real distance, boolean expected returns boolean
        local real x = GetUnitX(actor)
        local real y = GetUnitY(actor)
        local real facing = GetUnitFacing(actor)
        local integer order = GetUnitCurrentOrder(actor)
        local boolean accepted = RF_TryStep(actor,controller,x+distance,y)
        call RF_Check(accepted==expected,"actor-step-result","distance="+R2S(distance)+" accepted="+RF_Bool(accepted)+" cap=10.9375")
        if not expected or not accepted then
            call ActorSame(x,y,facing,order)
        else
            call RF_Check(GetUnitX(actor)==x+distance and GetUnitY(actor)==y and GetUnitFacing(actor)==facing and GetUnitCurrentOrder(actor)==order,"accepted-step-xy-only","actual="+R2S(GetUnitX(actor))+","+R2S(GetUnitY(actor))+" order="+I2S(GetUnitCurrentOrder(actor)))
        endif
        call ItemsSame()
        return accepted
    endfunction

    private function CleanupFixture takes nothing returns nothing
        if blocker != null then
            call RemoveUnit(blocker)
        endif
        if wall != null then
            call RemoveUnit(wall)
        endif
        if tree != null then
            call RemoveDestructable(tree)
        endif
        if visibleItem != null then
            call RemoveItem(visibleItem)
            call RemoveItem(hiddenItem)
        endif
        set blocker = null
        set wall = null
        set tree = null
        set visibleItem = null
        set hiddenItem = null
        call RF_ReferenceRemove()
    endfunction

    private function Next takes nothing returns nothing
        call CleanupFixture()
        set which = which+1
        set phase = 0
        set gate = 0
        set gateWait = 0
        if which <= 12 then
            call RF_Case(ids[which])
        endif
    endfunction

    private function AbortFixture takes string reason returns nothing
        call RF_Record("FAIL","fixture-aborted",reason+"; no geometry assertions accepted")
        call Next()
    endfunction

    // Independent native body occupancy precedes every candidate positive.
    // Restoration polls ONLY the native reference (<=2s), never the candidate.
    // The candidate is evaluated ONCE after body readiness and next-tick removal.
    private function Positive takes real x, real y, boolean restoration returns integer
        local boolean clear
        if gate == 0 then
            set bodyReady = RF_BodyOccupies(x,y)
            set gate = 1
            set gateWait = gateWait+1
            return 0
        endif
        set clear = RF_ReferenceClear(x,y)
        set gate = 0
        if not clear then
            return -1
        endif
        if not bodyReady then
            if restoration and gateWait < 8 then
                return 0
            endif
            call RF_Record("FAIL","native-positive-readiness","x="+R2S(x)+" y="+R2S(y)+" attempts="+I2S(gateWait))
            return -1
        endif
        set gateWait = 0
        if not Query("paired-positive-control",x,y,1) then
            return -1
        endif
        return 1
    endfunction

    private function Cast takes nothing returns nothing
        if GetTriggerUnit()==controller and GetSpellAbilityId()=='A00G' then
            set castSeen = true
            set castSource = GetTriggerUnit()
            set castAbility = GetSpellAbilityId()
            set castX = GetSpellTargetX()
            set castY = GetSpellTargetY()
        endif
    endfunction

    private function Finish takes nothing returns nothing
        call CleanupFixture()
        call RF_ReferenceCleanup()
        call RF_PathCleanup()
        call RemoveUnit(actor)
        call RemoveUnit(controller)
        call DestroyTrigger(castTrigger)
        call PauseTimer(clock)
        call DestroyTimer(clock)
        set actor = null
        set controller = null
        set castSource = null
        set castTrigger = null
        set clock = null
        call RF_Record("SKIP","multiplayer-and-production-animation","one bounded prerequisite; no production350loop Stop takeover resume burst or visual300percent proof")
        call RF_Complete()
    endfunction

    private function PlaceObservation takes unit u, string name returns nothing
        call RF_Record("OBS",name,"actual="+R2S(GetUnitX(u))+","+R2S(GetUnitY(u))+" type="+I2S(GetUnitTypeId(u))+" range16="+RF_Bool(IsUnitInRangeXY(u,ox,oy,16.)))
    endfunction

    private function Open takes nothing returns nothing
        local integer result
        local real x
        local real y
        if phase == 0 then
            // Three finite proposed local patches. Run01's accepted step is only
            // a starting hint. No static-flag-only selection or world scan.
            if site == 1 then
                set oy = -1024.
            elseif site == 2 then
                set ox = -2048.
                set oy = -512.
            endif
            set bodyReady = RF_ReferenceMove(ox,oy)
            set phase = 1
            if not bodyReady then
                call RF_ReferenceRemove()
                set phase = 4
            endif
        elseif phase == 1 then
            set result = RF_ReferencePoll()
            if result != 0 then
                set bodyReady = result==1
                set phase = 2
                set sample = 0
            endif
        elseif phase == 2 then
            if not RF_ReferenceClear(ox,oy) then
                set bodyReady = false
            endif
            if not bodyReady then
                set phase = 4
                return
            endif
            // Nine local640-wide body controls and three actor-step occupancy
            // points. These are measured occupancy, not continuous-area proof.
            if sample < 9 then
                set x = ox+(ModuloInteger(sample,3)-1)*320.
                set y = oy+(sample/3-1)*320.
            else
                set x = ox-768.+(sample-9)*8.
                set y = oy
            endif
            set bodyReady = RF_BodyOccupies(x,y)
            set sample = sample+1
            set phase = 3
        elseif phase == 3 then
            if not RF_ReferenceClear(ox,oy) then
                set bodyReady = false
            endif
            if not bodyReady then
                set phase = 4
            elseif sample < 12 then
                set phase = 2
            else
                set actor = CreateUnit(Player(0),'o000',ox-768.,oy,90.)
                call PlaceObservation(actor,"actor-native-placement")
                if RAbsBJ(GetUnitX(actor)-(ox-768.))>1. or RAbsBJ(GetUnitY(actor)-oy)>1. then
                    call RF_Record("FAIL","actor-placement-readiness","native coordinates differ from independently occupied goal")
                    call Finish()
                    return
                endif
                call PanCameraTo(GetUnitX(actor),GetUnitY(actor))
                if not Query("independently-qualified-open",ox,oy,1) then
                    call RF_Record("FAIL","open-candidate-abort","native reference ready but candidate false; geometry not interpreted")
                    call Finish()
                    return
                endif
                call Step(8.,true)
                call Next()
            endif
        elseif phase == 4 then
            call RF_Record("OBS","proposed-patch-not-qualified","site="+I2S(site)+" center="+R2S(ox)+","+R2S(oy))
            set site = site+1
            if site >= 3 then
                call RF_Record("FAIL","open-fixture-aborted","no independent native local patch within three proposals")
                call Finish()
            else
                set phase = 0
            endif
        endif
    endfunction

    private function TreeUnit takes nothing returns nothing
        local integer result
        if phase == 0 then
            set result = Positive(ox,oy,false)
            if result == -1 then
                call AbortFixture("baseline not ready")
            elseif result == 1 then
                if which == 3 then
                    set tree = CreateDestructable('LTlt',ox,oy,0.,1.,0)
                    set cx = GetDestructableX(tree)
                    set cy = GetDestructableY(tree)
                    call RF_Record("OBS","tree-native-placement","actual="+R2S(cx)+","+R2S(cy)+" life="+R2S(GetDestructableLife(tree)))
                else
                    set blocker = CreateUnit(Player(0),'hfoo',ox,oy,0.)
                    set cx = GetUnitX(blocker)
                    set cy = GetUnitY(blocker)
                    call PlaceObservation(blocker,"ground-native-placement")
                endif
                if RAbsBJ(cx-ox)>1. or RAbsBJ(cy-oy)>1. then
                    call AbortFixture("actual blocker was not at the positively qualified point")
                else
                    set phase = 1
                endif
            endif
        elseif phase == 1 then
            set bodyReady = RF_BodyOccupies(cx,cy)
            set phase = 2
        elseif phase == 2 then
            if not RF_ReferenceClear(cx,cy) or bodyReady then
                call AbortFixture("negative native-body occupancy was not established")
                return
            endif
            call Query("actual-blocker-negative",cx,cy,0)
            if which == 3 then
                call KillDestructable(tree)
                call RF_Record("OBS","tree-after-kill","life="+R2S(GetDestructableLife(tree)))
                set phase = 3
            else
                call RemoveUnit(blocker)
                set blocker = null
                set phase = 4
            endif
        elseif phase == 3 then
            set result = Positive(cx,cy,true)
            if result == -1 then
                call AbortFixture("dead-tree native readiness or paired candidate failed")
            elseif result == 1 then
                call RemoveDestructable(tree)
                set tree = null
                set phase = 4
            endif
        elseif phase == 4 then
            set result = Positive(cx,cy,true)
            if result == -1 then
                call AbortFixture("removed blocker reference or positive failed")
            elseif result == 1 then
                call Next()
            endif
        endif
    endfunction

    private function Building takes nothing returns nothing
        local integer result
        local integer ray
        local real radius
        local real x
        local real y
        if phase == 0 then
            // Calibration observes native placement, removes it, then proves
            // the ACTUAL layout before creating the measured building again.
            set blocker = CreateUnit(Player(0),'htow',ox,oy,0.)
            set cx = GetUnitX(blocker)
            set cy = GetUnitY(blocker)
            call PlaceObservation(blocker,"building-calibration-actual")
            call RemoveUnit(blocker)
            set blocker = null
            if RAbsBJ(cx-ox)>128. or RAbsBJ(cy-oy)>128. then
                call AbortFixture("building moved outside the bounded local calibration patch")
                return
            endif
            set sample = 0
            set edge = 0.
            set corner = 0.
            set outsideEdge = 0.
            set outsideCorner = 0.
            set phase = 1
        elseif phase == 1 then
            // Center, twelve axial and twelve diagonal body/query positives.
            set ray = sample/12
            set radius = (ModuloInteger(sample,12)+1)*32.
            set x = cx+radius
            set y = cy
            if ray == 1 then
                set y = cy+radius
            endif
            if sample == 24 then
                set x = cx
            endif
            set result = Positive(x,y,true)
            if result == -1 then
                call AbortFixture("actual building-layout baseline not ready")
            elseif result == 1 then
                set sample = sample+1
                if sample > 24 then
                    set blocker = CreateUnit(Player(0),'htow',cx,cy,0.)
                    call PlaceObservation(blocker,"building-measurement-actual")
                    if RAbsBJ(GetUnitX(blocker)-cx)>1. or RAbsBJ(GetUnitY(blocker)-cy)>1. then
                        call AbortFixture("native placement was not repeatable at calibrated coordinates")
                    else
                        set sample = 0
                        set phase = 2
                    endif
                endif
            endif
        elseif phase == 2 then
            set radius = (ModuloInteger(sample,12)+1)*32.
            set x = GetUnitX(blocker)+radius
            set y = GetUnitY(blocker)
            if sample >= 12 then
                set y = y+radius
            endif
            set bodyReady = RF_BodyOccupies(x,y)
            if sample < 12 then
                if not bodyReady and outsideEdge == 0. then
                    set edge = radius
                elseif bodyReady and outsideEdge == 0. then
                    set outsideEdge = radius
                elseif not bodyReady then
                    call AbortFixture("axial occupancy was not a single measured boundary")
                    return
                endif
            else
                if not bodyReady and outsideCorner == 0. then
                    set corner = radius
                elseif bodyReady and outsideCorner == 0. then
                    set outsideCorner = radius
                elseif not bodyReady then
                    call AbortFixture("diagonal occupancy was not a single measured boundary")
                    return
                endif
            endif
            set phase = 3
        elseif phase == 3 then
            if not RF_ReferenceClear(cx,cy) then
                call AbortFixture("reference still contaminates building measurement")
            else
                set sample = sample+1
                if sample < 24 then
                    set phase = 2
                elseif edge==0. or corner==0. or outsideEdge==0. or outsideCorner==0. then
                    call AbortFixture("no native body boundary bracket within384 units")
                else
                    call RF_Record("OBS","building-body-boundary-brackets","axis="+R2S(edge)+".."+R2S(outsideEdge)+" diagonal="+R2S(corner)+".."+R2S(outsideCorner)+" resolution=32; not an invented pathing texture shape")
                    call Query("building-native-edge-negative",cx+edge,cy,0)
                    call Query("building-native-corner-negative",cx+corner,cy+corner,0)
                    call Query("building-native-outside-positive",cx+outsideEdge,cy,1)
                    call Query("building-native-diagonal-outside-positive",cx+outsideCorner,cy+outsideCorner,1)
                    call RemoveUnit(blocker)
                    set blocker = null
                    set phase = 4
                endif
            endif
        elseif phase == 4 then
            set result = Positive(cx+edge,cy,true)
            if result == -1 then
                call AbortFixture("building edge removal positive failed")
            elseif result == 1 then
                set phase = 5
            endif
        elseif phase == 5 then
            set result = Positive(cx+corner,cy+corner,true)
            if result == -1 then
                call AbortFixture("building corner removal positive failed")
            elseif result == 1 then
                call Next()
            endif
        endif
    endfunction

    private function Gap takes nothing returns nothing
        local real width = 16.
        local integer result
        local real actualGap
        if which == 7 then
            set width = 32.
        elseif which == 8 then
            set width = 64.
        endif
        if phase <= 2 then
            set cy = oy
            if phase == 1 then
                set cy = oy-31.-width*.5
            elseif phase == 2 then
                set cy = oy+31.+width*.5
            endif
            set result = Positive(ox,cy,false)
            if result == -1 then
                call AbortFixture("gap center or actual-placement site not ready")
            elseif result == 1 then
                set phase = phase+1
            endif
        elseif phase == 3 then
            set blocker = CreateUnit(Player(0),'hfoo',ox,oy-31.-width*.5,0.)
            set wall = CreateUnit(Player(0),'hfoo',ox,oy+31.+width*.5,0.)
            call PlaceObservation(blocker,"gap-lower-actual")
            call PlaceObservation(wall,"gap-upper-actual")
            set actualGap = GetUnitY(wall)-GetUnitY(blocker)-62.
            call RF_Record("OBS","gap-actual-clearance","requested="+R2S(width)+" measured="+R2S(actualGap)+" verifiedFootmanRadius=31 actorRadius=16")
            if RAbsBJ(GetUnitX(blocker)-ox)>1. or RAbsBJ(GetUnitX(wall)-ox)>1. or RAbsBJ(actualGap-width)>1. or RAbsBJ((GetUnitY(wall)+GetUnitY(blocker))*.5-oy)>1. then
                call AbortFixture("requested gap not established; no nominal-width geometry accepted")
            else
                set cx = (GetUnitX(blocker)+GetUnitX(wall))*.5
                set cy = (GetUnitY(blocker)+GetUnitY(wall))*.5
                set phase = 4
            endif
        elseif phase == 4 then
            set bodyReady = RF_BodyOccupies(cx,cy)
            set phase = 5
        elseif phase == 5 then
            if not RF_ReferenceClear(cx,cy) or (which==6 and bodyReady) or (which==8 and not bodyReady) then
                call AbortFixture("independent body reference disagrees with intended gap control")
            else
                if which == 7 then
                    call Query("gap32-body-contact-boundary-observation",cx,cy,-1)
                elseif which == 6 then
                    call Query("actual-gap16-negative",cx,cy,0)
                else
                    call Query("actual-gap64-positive",cx,cy,1)
                endif
                call RemoveUnit(blocker)
                call RemoveUnit(wall)
                set blocker = null
                set wall = null
                set phase = 6
            endif
        elseif phase == 6 then
            set result = Positive(cx,cy,true)
            if result == -1 then
                call AbortFixture("gap removal positive failed")
            elseif result == 1 then
                call Next()
            endif
        endif
    endfunction

    private function Tick takes nothing returns nothing
        local integer result
        local real x
        local real y
        local rect bounds
        set ticks = ticks+1
        if not RF_HelperReady() then
            call RF_Record("FAIL","helper-cleanup-abort","public helper removal or neighbor restoration failed; no future placement")
            call Finish()
            return
        endif
        // Always observe removal on a later engine tick, including abort paths,
        // before any new reference, query, or blocker can be created.
        if not RF_ReferenceClear(ox,oy) then
            call RF_Record("FAIL","uncleared-native-reference-abort","no subsequent fixture geometry evaluated")
            call Finish()
            return
        endif
        if ticks >= 440 then
            call RF_Record("FAIL","global-native-budget-abort","elapsed=55.000; unreached geometry is not accepted")
            call Finish()
            return
        endif
        if which == 1 then
            call Open()
        elseif which == 2 or which == 11 then
            if phase == 0 then
                set result = Positive(ox,oy,false)
                if result == -1 then
                    call AbortFixture("static/cliff positive control failed")
                elseif result == 1 then
                    set bodyReady = RF_BodyOccupies(1792.,-6656.)
                    set phase = 1
                endif
            elseif phase == 1 then
                if not RF_ReferenceClear(1792.,-6656.) or bodyReady or not IsTerrainPathable(1792.,-6656.,PATHING_TYPE_WALKABILITY) then
                    call AbortFixture("run01 static/cliff sample not independently blocked in02")
                else
                    call RF_Record("OBS","actual-static-cliff-reference","x=1792 y=-6656 walkBlocked="+RF_Bool(IsTerrainPathable(1792.,-6656.,PATHING_TYPE_WALKABILITY))+" cliff="+I2S(GetTerrainCliffLevel(1792.,-6656.))+" neighborCliff="+I2S(GetTerrainCliffLevel(1920.,-6656.)))
                    call Query("native-qualified-static-negative",1792.,-6656.,0)
                    if which == 2 then
                        set phase = 2
                    else
                        call Next()
                    endif
                endif
            elseif phase == 2 then
                // O01 independently occupied both actor-step points before
                // actor creation. A radius31 blocker52 units away must NOT
                // overlap the current radius16 body, but must overlap goal+8.
                // This is deliberate obstacle geometry, not a reference helper.
                if not Query("short-step-positive-before-blocker",GetUnitX(actor)+8.,GetUnitY(actor),1) then
                    call AbortFixture("short-step positive baseline failed")
                    return
                endif
                set cx = GetUnitX(actor)+52.
                set cy = GetUnitY(actor)
                set blocker = CreateUnit(Player(0),'hfoo',cx,cy,0.)
                call PlaceObservation(blocker,"short-step-blocker-actual")
                call RF_Record("OBS","short-step-native-overlap-controls","current="+RF_Bool(IsUnitInRangeXY(blocker,GetUnitX(actor),GetUnitY(actor),16.))+" goal="+RF_Bool(IsUnitInRangeXY(blocker,GetUnitX(actor)+8.,GetUnitY(actor),16.)))
                if RAbsBJ(GetUnitX(blocker)-cx)>1. or RAbsBJ(GetUnitY(blocker)-cy)>1. or GetUnitX(actor)!=cx-52. or GetUnitY(actor)!=cy or IsUnitInRangeXY(blocker,GetUnitX(actor),GetUnitY(actor),16.) or not IsUnitInRangeXY(blocker,GetUnitX(actor)+8.,GetUnitY(actor),16.) then
                    call AbortFixture("short-step actual placement/current clearance/goal overlap not ready")
                else
                    set phase = 3
                endif
            elseif phase == 3 then
                if RAbsBJ(GetUnitX(blocker)-cx)>1. or RAbsBJ(GetUnitY(blocker)-cy)>1. or IsUnitInRangeXY(blocker,GetUnitX(actor),GetUnitY(actor),16.) or not IsUnitInRangeXY(blocker,GetUnitX(actor)+8.,GetUnitY(actor),16.) then
                    call AbortFixture("short-step overlap witness changed before query")
                    return
                endif
                call Query("known-short-step-goal-negative",GetUnitX(actor)+8.,GetUnitY(actor),0)
                if Step(8.,false) then
                    call AbortFixture("candidate accepted independently range-blocked short step")
                    return
                endif
                call RemoveUnit(blocker)
                set phase = 4
            else
                if GetUnitTypeId(blocker)!=0 then
                    set gateWait = gateWait+1
                    if gateWait >= 16 then
                        call AbortFixture("short-step blocker native removal deadline")
                    endif
                    return
                endif
                set blocker = null
                if not Query("short-step-blocker-removed-positive",GetUnitX(actor)+8.,GetUnitY(actor),1) then
                    call AbortFixture("short-step removal positive failed")
                else
                    call Next()
                endif
            endif
        elseif which == 3 or which == 4 then
            call TreeUnit()
        elseif which == 5 then
            call Building()
        elseif which >= 6 and which <= 8 then
            call Gap()
        elseif which == 9 then
            // Actor-step goals were independently body-qualified before actor
            // creation in O01. No reference is spawned on top of the actor.
            set x = GetUnitX(actor)+8.
            set y = GetUnitY(actor)
            if phase == 0 then
                if not Query("item-step-positive-before-items",x,y,1) then
                    call AbortFixture("item-step baseline candidate false")
                    return
                endif
                set visibleItem = CreateItem('ratf',x,y)
                set hiddenItem = CreateItem('ratf',x+32.,y)
                call SetItemVisible(hiddenItem,false)
                set itemX = GetItemX(visibleItem)
                set itemY = GetItemY(visibleItem)
                set hiddenX = GetItemX(hiddenItem)
                set hiddenY = GetItemY(hiddenItem)
                set phase = 1
            elseif phase == 1 then
                // Controller-only fixture order. Query immediately while the
                // public native Move order is active, then controller Stop.
                call RF_Check(IssuePointOrder(actor,"move",GetUnitX(actor)+64.,y),"active-native-move-order-issued","actualOrder="+I2S(GetUnitCurrentOrder(actor)))
                call RF_Record("OBS","active-native-move-order-readback","order="+I2S(GetUnitCurrentOrder(actor)))
                if GetUnitCurrentOrder(actor)!=OrderId("move") then
                    call IssueImmediateOrder(actor,"stop")
                    call AbortFixture("native Move order not active for query witness")
                    return
                endif
                if not Query("item-query-during-native-move",x,y,1) then
                    call IssueImmediateOrder(actor,"stop")
                    call AbortFixture("item-query positive failed; no accepted item-step claimed")
                    return
                endif
                call IssueImmediateOrder(actor,"stop")
                call Step(8.,true)
                call Step(16.,false)
                call RemoveItem(visibleItem)
                call RemoveItem(hiddenItem)
                set visibleItem = null
                set hiddenItem = null
                set phase = 2
            else
                call Query("items-removed-positive",GetUnitX(actor),GetUnitY(actor),1)
                call Next()
            endif
        elseif which == 10 then
            set result = Positive(ox,oy,false)
            if result == -1 then
                call AbortFixture("bounds positive control failed")
            elseif result == 1 then
                set bounds = GetWorldBounds()
                call Query("inbounds-edge-observation",GetRectMinX(bounds)+16.,oy,-1)
                call Query("footprint-crosses-world-bound-negative",GetRectMinX(bounds)+8.,oy,0)
                call Query("out-of-world-bound-negative",GetRectMinX(bounds)-1.,oy,0)
                call RemoveRect(bounds)
                set bounds = null
                call Next()
            endif
        elseif which == 12 then
            if phase == 0 then
                call RF_Check(IssuePointOrder(controller,"channel",ox+96.,oy+160.),"native-channel-order-accepted","target="+R2S(ox+96.)+","+R2S(oy+160.))
                set phase = 1
            else
                set castWait = castWait+1
                if not castSeen and castWait < 16 then
                    return
                endif
                call RF_Check(castSeen and castSource==controller and castAbility=='A00G' and RAbsBJ(castX-(ox+96.))<.01 and RAbsBJ(castY-(oy+160.))<.01,"public-channel-readback","seen="+RF_Bool(castSeen)+" elapsed="+R2S(castWait*.125)+" actual="+R2S(castX)+","+R2S(castY))
                call RF_Record("OBS","controller-off-camera-position","actual="+R2S(GetUnitX(controller))+","+R2S(GetUnitY(controller)))
                call Finish()
            endif
        endif
    endfunction

    function RF_Start takes nothing returns nothing
        call RF_Begin()
        call RF_PathInit()
        call RF_ReferenceInit()
        set ids[1] = "O01-open"
        set ids[2] = "S02-static-step"
        set ids[3] = "D03-tree"
        set ids[4] = "U04-ground-unit"
        set ids[5] = "B05-building"
        set ids[6] = "G06-gap16"
        set ids[7] = "G07-gap32"
        set ids[8] = "G08-gap64"
        set ids[9] = "I09-items"
        set ids[10] = "L10-bounds"
        set ids[11] = "C11-cliff"
        set ids[12] = "A12-channel"
        set controller = CreateUnit(Player(0),'o001',-5500.,-5500.,0.)
        set castTrigger = CreateTrigger()
        call TriggerRegisterPlayerUnitEvent(castTrigger,Player(0),EVENT_PLAYER_UNIT_SPELL_EFFECT,null)
        call TriggerAddAction(castTrigger,function Cast)
        call RF_Case(ids[1])
        set clock = CreateTimer()
        call TimerStart(clock,.125,true,function Tick)
    endfunction
endlibrary
