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
        private real ox = 0.
        private real oy = 0.
        private real proposalX = -1280.
        private real proposalY = -512.
        private boolean restAnchored = false
        private boolean layoutReady = false
        private real regionMinX
        private real regionMinY
        private real regionMaxX
        private real regionMaxY
        private real cx
        private real cy
        private real lowerX
        private real lowerY
        private real upperX
        private real upperY
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

    // Spawn-placement precondition ONLY, not walkability/transit truth.
    // Restoration polls placement (<=2s), never candidate until ready/removed.
    // Candidate positive is a separate discrete assertion at these coordinates.
    private function Positive takes real x, real y, boolean restoration returns integer
        local boolean clear
        if gate == 0 then
            set bodyReady = RF_PlacementAt(x,y)
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
            call RF_Record("FAIL","spawn-positive-readiness","x="+R2S(x)+" y="+R2S(y)+" attempts="+I2S(gateWait))
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

    // Parent's owned-base WPM/W3E selection, not native clearance evidence.
    // World rectangles are upper-exclusive; varying raw heights are permitted.
    private function SelectRegion takes nothing returns boolean
        local boolean ready
        if site == 0 then
            set proposalX = -1440.
            set proposalY = 4352.
            set regionMinX = -3008.
            set regionMinY = 3648.
            set regionMaxX = -128.
            set regionMaxY = 5248.
        elseif site == 1 then
            set proposalX = 2464.
            set proposalY = -5184.
            set regionMinX = 1280.
            set regionMinY = -6144.
            set regionMaxX = 3392.
            set regionMaxY = -4032.
        else
            set proposalX = 4352.
            set proposalY = 3776.
            set regionMinX = 3200.
            set regionMinY = 2880.
            set regionMaxX = 5248.
            set regionMaxY = 4864.
        endif
        // Reference starts at nominalX-64; include its radius16 and target.
        set ready = proposalX-80.>=regionMinX and proposalY-16.>=regionMinY and proposalX+16.<regionMaxX and proposalY+16.<regionMaxY
        call RF_Record("OBS","static-proposal-region","site="+I2S(site)+" nominal="+R2S(proposalX)+","+R2S(proposalY)+" worldMin="+R2S(regionMinX)+","+R2S(regionMinY)+" worldMaxExclusive="+R2S(regionMaxX)+","+R2S(regionMaxY)+" referenceStartInside="+RF_Bool(ready)+" source=parent-owned-base-WPM-W3E; bit64=no-water; layer1; not-native-clearance")
        return ready
    endfunction

    private function ActualLayoutReady takes nothing returns boolean
        // Current local fixture envelope: actor-768 +/-16; grid +/-320 +/-16;
        // building actual center +/-128, positive axis/diagonal rays384 +/-16.
        // Thus X[-784,+528],Y[-336,+528]. No negative building rays added.
        // Remote static/cliff/bounds negatives, broadphase/item enumeration and
        // off-camera controller are NOT claims of open-region qualification.
        local boolean ready = ox-784.>=regionMinX and oy-336.>=regionMinY and ox+528.<regionMaxX and oy+528.<regionMaxY
        call RF_Record("OBS","static-actual-anchor-layout","site="+I2S(site)+" actualRest="+R2S(ox)+","+R2S(oy)+" admissibleMin="+R2S(regionMinX+784.)+","+R2S(regionMinY+336.)+" admissibleMaxExclusive="+R2S(regionMaxX-528.)+","+R2S(regionMaxY-528.)+" envelopeX=-784..528 envelopeY=-336..528 inside="+RF_Bool(ready)+" status=static-only-before-spawn-placement")
        return ready
    endfunction

    private function Open takes nothing returns nothing
        local integer result
        local integer gridSample
        local real x
        local real y
        if phase == 0 then
            // Three actual-data-derived regions; native gates remain mandatory.
            set restAnchored = false
            set layoutReady = false
            set bodyReady = SelectRegion()
            if bodyReady then
                set bodyReady = RF_ReferenceMove(proposalX,proposalY)
            endif
            set phase = 1
            if not bodyReady then
                call RF_ReferenceRemove()
                set phase = 4
            endif
        elseif phase == 1 then
            set result = RF_ReferencePoll()
            if result != 0 then
                set bodyReady = result==1
                if bodyReady then
                    set ox = RF_ReferenceRestX()
                    set oy = RF_ReferenceRestY()
                    set restAnchored = true
                    set layoutReady = ActualLayoutReady()
                    set bodyReady = layoutReady
                    call RF_Record("OBS","fixture-anchor-provenance","nominalProposal="+R2S(proposalX)+","+R2S(proposalY)+" actualNativeRest="+R2S(ox)+","+R2S(oy)+" subsequentGeometry=offsets-from-this-actual-point")
                endif
                set phase = 2
                set sample = 0
            endif
        elseif phase == 2 then
            if not restAnchored then
                set bodyReady = false
            endif
            if not RF_ReferenceClear(ox,oy) then
                set bodyReady = false
            endif
            if not bodyReady then
                set phase = 4
                return
            endif
            // All targets derive from the captured ACTUAL rest, not proposalXY.
            // Native Move/rest covers opening only. These twelve additional
            // samples check spawn placement, NOT traversal or continuous area.
            if sample == 0 then
                // Strict SAME-point body placement is measured first.
                set x = ox
                set y = oy
            elseif sample < 9 then
                // Then visit the other eight original grid points, unchanged.
                set gridSample = sample-1
                if gridSample >= 4 then
                    set gridSample = gridSample+1
                endif
                set x = ox+(ModuloInteger(gridSample,3)-1)*320.
                set y = oy+(gridSample/3-1)*320.
            else
                set x = ox-768.+(sample-9)*8.
                set y = oy
            endif
            set bodyReady = RF_PlacementAt(x,y)
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
                    call RF_Record("FAIL","actor-placement-readiness","actor coordinates differ from recorded spawn-placement sample")
                    call Finish()
                    return
                endif
                call PanCameraTo(GetUnitX(actor),GetUnitY(actor))
                if not Query("opening-rest-and-placement-candidate-positive",ox,oy,1) then
                    call RF_Record("FAIL","open-candidate-abort","spawn-placement checks ready but candidate false; no transit inferred")
                    call Finish()
                    return
                endif
                call Step(8.,true)
                call Next()
            endif
        elseif phase == 4 then
            if restAnchored and not layoutReady then
                call RF_Record("OBS","proposed-patch-not-qualified","site="+I2S(site)+" actualRest="+R2S(ox)+","+R2S(oy)+" status=rest-outside-static-admissible-region; no body/candidate qualification")
            elseif restAnchored then
                call RF_Record("OBS","proposed-patch-not-qualified","site="+I2S(site)+" nominal="+R2S(proposalX)+","+R2S(proposalY)+" actualRest="+R2S(ox)+","+R2S(oy)+" status=rest-observed-neighborhood-not-qualified")
            else
                call RF_Record("OBS","proposed-patch-not-qualified","site="+I2S(site)+" nominal="+R2S(proposalX)+","+R2S(proposalY)+" actualRest=unavailable status=reference-failed")
            endif
            set site = site+1
            if site >= 3 then
                call RF_Record("FAIL","open-fixture-aborted","no independent native local patch within three proposals")
                call Finish()
            else
                set phase = 0
            endif
        endif
    endfunction

    private function Tree takes nothing returns nothing
        local integer result
        if phase == 0 then
            set tree = CreateDestructable('LTlt',ox,oy,0.,1.,0)
            set cx = GetDestructableX(tree)
            set cy = GetDestructableY(tree)
            call RF_Record("OBS","tree-calibration-actual","actual="+R2S(cx)+","+R2S(cy)+" life="+R2S(GetDestructableLife(tree)))
            if GetDestructableTypeId(tree)!='LTlt' or GetDestructableLife(tree)<=0. or cx-16.<regionMinX or cy-16.<regionMinY or cx+16.>=regionMaxX or cy+16.>=regionMaxY then
                call AbortFixture("actual tree calibration outside selected region or invalid")
                return
            endif
            call RemoveDestructable(tree)
            set phase = 1
        elseif phase == 1 then
            set gateWait = gateWait+1
            call RF_Record("OBS","tree-calibration-removal","remainingType="+I2S(GetDestructableTypeId(tree))+" wait="+I2S(gateWait))
            if GetDestructableTypeId(tree)==0 then
                set tree = null
                set gateWait = 0
                set phase = 2
            elseif gateWait>=16 then
                call AbortFixture("tree calibration removal deadline")
            endif
        elseif phase == 2 then
            set result = Positive(cx,cy,true)
            if result == -1 then
                call AbortFixture("actual tree coordinate restoration/positive unavailable")
            elseif result == 1 then
                set tree = CreateDestructable('LTlt',cx,cy,0.,1.,0)
                call RF_Record("OBS","tree-repeatable-actual","wanted="+R2S(cx)+","+R2S(cy)+" actual="+R2S(GetDestructableX(tree))+","+R2S(GetDestructableY(tree))+" life="+R2S(GetDestructableLife(tree)))
                if GetDestructableTypeId(tree)!='LTlt' or GetDestructableLife(tree)<=0. or GetDestructableX(tree)!=cx or GetDestructableY(tree)!=cy then
                    call AbortFixture("tree not repeatable at calibrated ACTUAL point")
                else
                    set phase = 3
                endif
            endif
        elseif phase == 3 then
            if GetDestructableX(tree)!=cx or GetDestructableY(tree)!=cy or GetDestructableLife(tree)<=0. then
                call AbortFixture("actual live tree changed before query")
                return
            endif
            call Query("actual-tree-alive-negative",cx,cy,0)
            call KillDestructable(tree)
            call RF_Record("OBS","tree-after-kill","life="+R2S(GetDestructableLife(tree)))
            set phase = 4
        elseif phase == 4 then
            set result = Positive(cx,cy,true)
            if result == -1 then
                call AbortFixture("actual dead-tree positive unavailable")
            elseif result == 1 then
                call RemoveDestructable(tree)
                set phase = 5
            endif
        elseif phase == 5 then
            set gateWait = gateWait+1
            if GetDestructableTypeId(tree)==0 then
                set tree = null
                set gateWait = 0
                set phase = 6
            elseif gateWait>=16 then
                call AbortFixture("actual tree removal deadline")
            endif
        elseif phase == 6 then
            set result = Positive(cx,cy,true)
            if result == -1 then
                call AbortFixture("actual removed-tree positive unavailable")
            elseif result == 1 then
                call Next()
            endif
        endif
    endfunction

    private function TreeUnit takes nothing returns nothing
        local integer result
        if which == 3 then
            call Tree()
            return
        endif
        if phase == 0 then
            set blocker = CreateUnit(Player(0),'hfoo',ox,oy,0.)
            set cx = GetUnitX(blocker)
            set cy = GetUnitY(blocker)
            call PlaceObservation(blocker,"ground-calibration-actual")
            if GetUnitTypeId(blocker)!='hfoo' or RAbsBJ(cx-ox)>1. or RAbsBJ(cy-oy)>1. then
                call AbortFixture("ground calibration outside bounded actual placement")
                return
            endif
            call RemoveUnit(blocker)
            set phase = 1
        elseif phase == 1 or phase == 4 then
            set gateWait = gateWait+1
            call RF_Record("OBS","ground-unit-removal","remainingType="+I2S(GetUnitTypeId(blocker)))
            if GetUnitTypeId(blocker)==0 then
                set blocker = null
                set gateWait = 0
                set phase = phase+1
            elseif gateWait>=16 then
                call AbortFixture("ground-unit removal deadline")
            endif
        elseif phase == 2 then
            set result = Positive(cx,cy,true)
            if result == -1 then
                call AbortFixture("actual ground center prepositive unavailable")
            elseif result == 1 then
                set blocker = CreateUnit(Player(0),'hfoo',cx,cy,0.)
                call PlaceObservation(blocker,"ground-native-placement")
                if GetUnitTypeId(blocker)!='hfoo' or GetUnitX(blocker)!=cx or GetUnitY(blocker)!=cy then
                    call AbortFixture("ground center placement not repeatable")
                else
                    set phase = 3
                endif
            endif
        elseif phase == 3 then
            call RF_Record("OBS","ground-unit-range-control","range16="+RF_Bool(IsUnitInRangeXY(blocker,cx,cy,16.)))
            if GetWidgetLife(blocker)<=.405 or GetUnitX(blocker)!=cx or GetUnitY(blocker)!=cy or not IsUnitInRangeXY(blocker,cx,cy,16.) then
                call AbortFixture("actual ground-unit overlap control unavailable")
                return
            endif
            call Query("actual-blocker-negative",cx,cy,0)
            call RemoveUnit(blocker)
            set phase = 4
        elseif phase == 5 then
            set result = Positive(cx,cy,true)
            if result == -1 then
                call AbortFixture("removed ground-unit positive unavailable")
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
            // Calibration records placement, removes it, then pairs actual
            // spawn/query baselines. This does NOT establish movement truth.
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
            // Center, twelve axial/diagonal placement/query positive controls.
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
            set bodyReady = RF_PlacementAt(x,y)
            if sample < 12 then
                if not bodyReady and outsideEdge == 0. then
                    set edge = radius
                elseif bodyReady and outsideEdge == 0. then
                    set outsideEdge = radius
                elseif not bodyReady then
                    call AbortFixture("axial spawn placement did not form a single bracket")
                    return
                endif
            else
                if not bodyReady and outsideCorner == 0. then
                    set corner = radius
                elseif bodyReady and outsideCorner == 0. then
                    set outsideCorner = radius
                elseif not bodyReady then
                    call AbortFixture("diagonal spawn placement did not form a single bracket")
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
                    call AbortFixture("no spawn-placement bracket within384 units")
                else
                    call RF_Record("OBS","building-spawn-placement-brackets","axis="+R2S(edge)+".."+R2S(outsideEdge)+" diagonal="+R2S(corner)+".."+R2S(outsideCorner)+" resolution=32; spawn-correlated, NOT movement boundaries")
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

    private function GapTransitInside takes nothing returns boolean
        return cx-144.>=regionMinX and cx+144.<regionMaxX and cy-16.>=regionMinY and cy+16.<regionMaxY
    endfunction

    private function GapMeasurementPair takes nothing returns nothing
        set blocker = CreateUnit(Player(0),'hfoo',lowerX,lowerY,0.)
        set wall = CreateUnit(Player(0),'hfoo',upperX,upperY,0.)
        call PlaceObservation(blocker,"gap-lower-repeatable-actual")
        call PlaceObservation(wall,"gap-upper-repeatable-actual")
        set phase = 4
    endfunction

    private function Gap takes nothing returns nothing
        local real width = 16.
        local integer result
        local real actualGap
        local boolean lowerOverlap
        local boolean upperOverlap
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
                call AbortFixture("gap baseline placement/candidate unavailable")
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
                return
            endif
            set lowerX = GetUnitX(blocker)
            set lowerY = GetUnitY(blocker)
            set upperX = GetUnitX(wall)
            set upperY = GetUnitY(wall)
            set cx = (lowerX+upperX)*.5
            set cy = (lowerY+upperY)*.5
            // Remove calibration pair BEFORE exact actual-midpoint positive.
            call RemoveUnit(blocker)
            call RemoveUnit(wall)
            set phase = 7
        elseif phase == 7 or phase == 10 then
            set gateWait = gateWait+1
            call RF_Record("OBS","gap-pair-removal","lowerType="+I2S(GetUnitTypeId(blocker))+" upperType="+I2S(GetUnitTypeId(wall)))
            if GetUnitTypeId(blocker)==0 and GetUnitTypeId(wall)==0 then
                set blocker = null
                set wall = null
                set gateWait = 0
                if phase == 7 then
                    set phase = 8
                else
                    set phase = 6
                endif
            elseif gateWait>=16 then
                call AbortFixture("gap pair removal deadline")
            endif
        elseif phase == 8 then
            set result = Positive(cx,cy,true)
            if result == -1 then
                call AbortFixture("actual gap midpoint prepositive unavailable")
            elseif result == 1 then
                if which == 8 then
                    set phase = 12
                else
                    call GapMeasurementPair()
                endif
            endif
        elseif phase == 12 then
            if not GapTransitInside() then
                call AbortFixture("actual baseline transit start/goal outside selected region")
                return
            endif
            call RF_Record("OBS","native-transit-context","gap64-before-blockers; candidate prepositive already observed at same actual midpoint")
            if RF_TransitStart(cx,cy) then
                set phase = 13
            else
                set phase = 14
            endif
        elseif phase == 13 then
            set result = RF_TransitPoll()
            if result != 0 then
                set phase = 14
            endif
        elseif phase == 14 then
            // Prior callback removed trace; Tick clearance runs before creation.
            call GapMeasurementPair()
        elseif phase == 4 then
            if GetUnitTypeId(blocker)!='hfoo' or GetUnitTypeId(wall)!='hfoo' or GetWidgetLife(blocker)<=.405 or GetWidgetLife(wall)<=.405 or GetUnitX(blocker)!=lowerX or GetUnitY(blocker)!=lowerY or GetUnitX(wall)!=upperX or GetUnitY(wall)!=upperY then
                call AbortFixture("actual gap placement not repeatable before geometry")
                return
            endif
            set lowerOverlap = IsUnitInRangeXY(blocker,cx,cy,16.)
            set upperOverlap = IsUnitInRangeXY(wall,cx,cy,16.)
            call RF_Record("OBS","gap-native-circle-controls","mid="+R2S(cx)+","+R2S(cy)+" lowerRange16="+RF_Bool(lowerOverlap)+" upperRange16="+RF_Bool(upperOverlap)+" not-spawn-or-transit-truth")
            if (which==6 and not (lowerOverlap and upperOverlap)) or (which==8 and (lowerOverlap or upperOverlap)) then
                call AbortFixture("native local circle controls unavailable for requested gap")
                return
            endif
            if which == 7 then
                call Query("gap32-discrete-contact-observation",cx,cy,-1)
            elseif which == 6 then
                call Query("actual-gap16-negative",cx,cy,0)
            elseif not Query("actual-gap64-discrete-positive",cx,cy,1) then
                call AbortFixture("candidate gap64 disagreed with qualified local circle control")
                return
            endif
            if which == 8 then
                // Trace start/goal +/-128 plus radius16. Strict actual bounds,
                // entirely inside existing R envelope; actor speed untouched.
                if not GapTransitInside() then
                    call AbortFixture("actual gap transit start/goal outside selected region")
                    return
                endif
                call RF_Record("OBS","native-transit-context","gap64-with-blockers; local circle/candidate geometry separate from transit scope")
                set bodyReady = RF_TransitStart(cx,cy)
                if bodyReady then
                    set phase = 9
                    return
                endif
                // Start failure is unavailable transit, NOT a blocked-point oracle.
                set phase = 11
            else
                set phase = 11
            endif
        elseif phase == 9 then
            call RF_Record("OBS","native-transit-gap-witness","lower="+R2S(GetUnitX(blocker))+","+R2S(GetUnitY(blocker))+" upper="+R2S(GetUnitX(wall))+","+R2S(GetUnitY(wall)))
            if GetUnitTypeId(blocker)!='hfoo' or GetUnitTypeId(wall)!='hfoo' or GetWidgetLife(blocker)<=.405 or GetWidgetLife(wall)<=.405 or GetUnitX(blocker)!=lowerX or GetUnitY(blocker)!=lowerY or GetUnitX(wall)!=upperX or GetUnitY(wall)!=upperY then
                call RF_Record("OBS","native-transit-unavailable","gap blocker witness changed; not straight-gap or blocked-point proof")
                call RF_ReferenceRemove()
                set phase = 11
            else
                set result = RF_TransitPoll()
                if result != 0 then
                    set phase = 11
                endif
            endif
        elseif phase == 11 then
            // Tick's public reference clearance must run first after trace removal.
            call RemoveUnit(blocker)
            call RemoveUnit(wall)
            set phase = 10
        elseif phase == 6 then
            set result = Positive(cx,cy,true)
            if result == -1 then
                call AbortFixture("actual gap midpoint removal positive unavailable")
            elseif result == 1 then
                call Next()
            endif
        endif
    endfunction

    // Parent-owned WPM/W3E cell-centre proposals, NOT native level truth.
    // Candidate-first, at most six in one callback; no scan, wait or terrain edit.
    private function Cliff takes nothing returns nothing
        local integer result
        local integer i = 1
        local real x
        local real y
        local real nx
        local real ny
        local integer rawSample
        local integer rawNeighbor
        local integer level
        local integer neighborLevel
        local boolean blocked
        local boolean neighborBlocked
        local boolean inside
        local rect bounds
        if phase == 0 then
            set result = Positive(ox,oy,false)
            if result == -1 then
                call AbortFixture("static/cliff positive control failed")
            elseif result == 1 then
                set phase = 1
            endif
            return
        endif
        call RF_Record("OBS","cliff-static-provenance","parent-owned-base=ff34f3fcea03281163c81bdcb11a6f7285f12c289c7160f640d4fa242adfb3b3 WPM=ce71d9f00f8c242dc827c9834aee329272385009c9ad902638c6e4858d2c51ab W3E=f815e2d090116731f8f7d88e69980edc40c18bccf67f2b23a67d806f85698c2f; rawSW/min proxies NOT native levels")
        set bounds = GetWorldBounds()
        loop
            exitwhen i > 6
            if i == 1 then
                set x = -2640.
                set y = 5648.
                set nx = -2768.
                set ny = 5648.
                set rawSample = 1
                set rawNeighbor = 0
            elseif i == 2 then
                set x = -3216.
                set y = 4336.
                set nx = -3216.
                set ny = 4464.
                set rawSample = 0
                set rawNeighbor = 1
            elseif i == 3 or i == 4 then
                set x = -3216.
                set y = 4080.-(i-3)*256.
                set nx = -3088.
                set ny = y
                set rawSample = 0
                set rawNeighbor = 1
            elseif i == 5 then
                set x = -3440.
                set y = 4464.
                set nx = -3440.
                set ny = 4592.
                set rawSample = 0
                set rawNeighbor = 1
            else
                set x = -3472.
                set y = 4720.
                set nx = -3344.
                set ny = 4720.
                set rawSample = 0
                set rawNeighbor = 1
            endif
            set blocked = IsTerrainPathable(x,y,PATHING_TYPE_WALKABILITY)
            set neighborBlocked = IsTerrainPathable(nx,ny,PATHING_TYPE_WALKABILITY)
            set level = GetTerrainCliffLevel(x,y)
            set neighborLevel = GetTerrainCliffLevel(nx,ny)
            // Remote NEGATIVE fixture: actual world bounds, not open-region claims.
            set inside = x-16.>=GetRectMinX(bounds) and x+16.<GetRectMaxX(bounds) and y-16.>=GetRectMinY(bounds) and y+16.<GetRectMaxY(bounds) and nx-16.>=GetRectMinX(bounds) and nx+16.<GetRectMaxX(bounds) and ny-16.>=GetRectMinY(bounds) and ny+16.<GetRectMaxY(bounds)
            call RF_Record("OBS","actual-cliff-pair-reference","pair="+I2S(i)+" sample="+R2S(x)+","+R2S(y)+" walkBlocked="+RF_Bool(blocked)+" nativeCliff="+I2S(level)+" neighbor="+R2S(nx)+","+R2S(ny)+" neighborWalkBlocked="+RF_Bool(neighborBlocked)+" neighborNativeCliff="+I2S(neighborLevel)+" rawSWandMin="+I2S(rawSample)+"->"+I2S(rawNeighbor)+" bothFootprintsInsideWorld="+RF_Bool(inside)+" source=cliff-static-provenance; no raw/native equality assumed")
            if inside and blocked and level!=neighborLevel then
                call RemoveRect(bounds)
                set bounds = null
                call Query("native-flag-qualified-real-cliff-negative",x,y,0)
                call Next()
                return
            endif
            set i = i+1
        endloop
        call RemoveRect(bounds)
        set bounds = null
        call AbortFixture("no fresh native restricted unequal-level cliff pair within six parent-selected candidates")
    endfunction

    private function Tick takes nothing returns nothing
        local integer result
        local real x
        local real y
        local rect bounds
        local boolean staticBlocked
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
        elseif which == 11 then
            call Cliff()
        elseif which == 2 then
            if phase == 0 then
                set result = Positive(ox,oy,false)
                if result == -1 then
                    call AbortFixture("static/cliff positive control failed")
                elseif result == 1 then
                    set phase = 1
                endif
            elseif phase == 1 then
                // Fresh PUBLIC restriction/levels before ANY guard, no spawn oracle.
                set staticBlocked = IsTerrainPathable(1792.,-6656.,PATHING_TYPE_WALKABILITY)
                call RF_Record("OBS","actual-static-cliff-reference","x=1792 y=-6656 walkBlocked="+RF_Bool(staticBlocked)+" cliff="+I2S(GetTerrainCliffLevel(1792.,-6656.))+" neighborCliff="+I2S(GetTerrainCliffLevel(1920.,-6656.)))
                if staticBlocked then
                    call Query("native-flag-qualified-static-negative",1792.,-6656.,0)
                else
                    call RF_Record("FAIL","static-subfixture-aborted","fresh flag not restricted; no static negative accepted; local blocked-step control independent")
                endif
                set phase = 2
            elseif phase == 2 then
                // O01 recorded spawn placement at both actor-step points before
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
            // Actor-step goals had spawn-placement checks before actor
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
