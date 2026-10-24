library RFNativeProbe requires RFPathingCandidate
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
        private real itemX = 0.
        private real itemY = 0.
        private real hiddenX = 0.
        private real hiddenY = 0.
        private real ox = 0.
        private real oy = 0.
        private real sx = 0.
        private real sy = 0.
        private boolean savedWalkBlocked = false
        private integer stage = 0
        private boolean castSeen = false
        private integer castAbility = 0
        private unit castSource = null
        private real castX = 0.
        private real castY = 0.
        private real castActorX = 0.
        private real castActorY = 0.
        private real castFacing = 0.
        private integer castOrder = 0
        private integer castWait = 0
        private integer cliffRow = 0
        private real cliffX = 0.
        private real cliffY = 0.
        private boolean cliffFound = false
    endglobals

    private function ActorSame takes real x, real y, real facing, integer order, string name returns nothing
        call RF_Check(GetUnitX(actor)==x and GetUnitY(actor)==y and GetUnitFacing(actor)==facing and GetUnitCurrentOrder(actor)==order, name, "actual="+R2S(GetUnitX(actor))+","+R2S(GetUnitY(actor))+" previous="+R2S(x)+","+R2S(y)+" facing="+R2S(GetUnitFacing(actor))+" previousFacing="+R2S(facing)+" order="+I2S(GetUnitCurrentOrder(actor))+" previousOrder="+I2S(order))
    endfunction

    private function ItemsSame takes nothing returns nothing
        if visibleItem != null then
            call RF_Check(IsItemVisible(visibleItem) and not IsItemVisible(hiddenItem),"public-item-visibility-restored","visible="+RF_Bool(IsItemVisible(visibleItem))+" hidden="+RF_Bool(IsItemVisible(hiddenItem)))
            call RF_Check(GetItemX(visibleItem)==itemX and GetItemY(visibleItem)==itemY and GetItemX(hiddenItem)==hiddenX and GetItemY(hiddenItem)==hiddenY,"public-item-coordinates-unchanged","visible="+R2S(GetItemX(visibleItem))+","+R2S(GetItemY(visibleItem))+" hidden="+R2S(GetItemX(hiddenItem))+","+R2S(GetItemY(hiddenItem)))
        endif
    endfunction

    private function Query takes string name, real x, real y, integer expected returns nothing
        local real ax = GetUnitX(actor)
        local real ay = GetUnitY(actor)
        local real facing = GetUnitFacing(actor)
        local integer order = GetUnitCurrentOrder(actor)
        local boolean eligible = RF_Eligible(actor,controller,x,y)
        local string detail = "query="+R2S(x)+","+R2S(y)+" eligible="+RF_Bool(eligible)+" nativeWalkBlocked="+RF_Bool(IsTerrainPathable(x,y,PATHING_TYPE_WALKABILITY))+" cliff="+I2S(GetTerrainCliffLevel(x,y))
        if expected < 0 then
            call RF_Record("OBS",name,detail)
        else
            call RF_Check(eligible==(expected==1),name,detail)
        endif
        call ActorSame(ax,ay,facing,order,"query-actor-public-state-unchanged")
        call ItemsSame()
    endfunction

    private function Step takes boolean expected, real x, real y returns nothing
        local real ax = GetUnitX(actor)
        local real ay = GetUnitY(actor)
        local real facing = GetUnitFacing(actor)
        local integer order = GetUnitCurrentOrder(actor)
        local boolean accepted = RF_TryStep(actor,controller,x,y)
        call RF_Check(accepted==expected,"bounded-step-result","accepted="+RF_Bool(accepted)+" previous="+R2S(ax)+","+R2S(ay)+" target="+R2S(x)+","+R2S(y)+" actual="+R2S(GetUnitX(actor))+","+R2S(GetUnitY(actor)))
        if not expected then
            call ActorSame(ax,ay,facing,order,"rejected-step-public-state-unchanged")
        else
            call RF_Check(GetUnitX(actor)==x and GetUnitY(actor)==y and GetUnitFacing(actor)==facing and GetUnitCurrentOrder(actor)==order,"accepted-step-only-xy","actual="+R2S(GetUnitX(actor))+","+R2S(GetUnitY(actor))+" facing="+R2S(GetUnitFacing(actor))+" order="+I2S(GetUnitCurrentOrder(actor)))
        endif
        call ItemsSame()
    endfunction

    private function FindOpen takes nothing returns boolean
        local integer x = -512
        local integer y
        local integer i
        local integer j
        local boolean ready
        loop
            exitwhen x > 512
            set y = -512
            loop
                exitwhen y > 512
                set ready = true
                set i = -1
                loop
                    exitwhen i > 1
                    set j = -1
                    loop
                        exitwhen j > 1
                        if IsTerrainPathable(x+i*512.,y+j*512.,PATHING_TYPE_WALKABILITY) or IsTerrainPathable(x-768.+i*16.,y+j*16.,PATHING_TYPE_WALKABILITY) or GetTerrainCliffLevel(x+i*512.,y+j*512.) != GetTerrainCliffLevel(x,y) then
                            set ready = false
                        endif
                        set j = j+1
                    endloop
                    set i = i+1
                endloop
                if ready then
                    set ox = x
                    set oy = y
                    return true
                endif
                set y = y+256
            endloop
            set x = x+256
        endloop
        return false
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

    private function UnitObservation takes unit u, string name returns nothing
        call RF_Record("OBS",name,"type="+I2S(GetUnitTypeId(u))+" actual="+R2S(GetUnitX(u))+","+R2S(GetUnitY(u))+" life="+R2S(GetWidgetLife(u))+" range16="+RF_Bool(IsUnitInRangeXY(u,ox,oy,16.))+" structure="+RF_Bool(IsUnitType(u,UNIT_TYPE_STRUCTURE))+" flying="+RF_Bool(IsUnitType(u,UNIT_TYPE_FLYING)))
    endfunction

    private function Gap takes real width returns nothing
        call Query("positive-before-gap-blockers",ox,oy,1)
        // Verified stock Footman radius31; requested clearance, not fake actualXY.
        set blocker = CreateUnit(Player(0),'hfoo',ox,oy-31.-width*.5,0.)
        set wall = CreateUnit(Player(0),'hfoo',ox,oy+31.+width*.5,0.)
        call UnitObservation(blocker,"gap-lower-native")
        call UnitObservation(wall,"gap-upper-native")
        call RF_Record("OBS","gap-actual-clearance","requested="+R2S(width)+" actualYGap="+R2S(GetUnitY(wall)-GetUnitY(blocker)-62.)+" actorDiameter=32")
        call RF_Check(RAbsBJ(GetUnitX(blocker)-ox)<1. and RAbsBJ(GetUnitX(wall)-ox)<1. and RAbsBJ(GetUnitY(blocker)-(oy-31.-width*.5))<1. and RAbsBJ(GetUnitY(wall)-(oy+31.+width*.5))<1.,"gap-placement-ready","nativeCoordinatesRecorded=true")
    endfunction

    private function RemoveGap takes nothing returns nothing
        call RemoveUnit(blocker)
        call RemoveUnit(wall)
        set blocker = null
        set wall = null
    endfunction

    private function CliffRow takes nothing returns nothing
        local rect bounds = GetWorldBounds()
        local real x = GetRectMinX(bounds)+256.
        local real y = GetRectMinY(bounds)+256.+cliffRow*256.
        local integer i
        if y > GetRectMaxY(bounds)-256. then
            set cliffRow = 64
        else
            loop
                exitwhen x > GetRectMaxX(bounds)-256. or cliffFound
                if GetTerrainCliffLevel(x,y)!=GetTerrainCliffLevel(x+128.,y) or GetTerrainCliffLevel(x,y)!=GetTerrainCliffLevel(x,y+128.) then
                    set i = 0
                    loop
                        exitwhen i > 16 or cliffFound
                        if IsTerrainPathable(x+i*8.,y,PATHING_TYPE_WALKABILITY) then
                            set cliffX = x+i*8.
                            set cliffY = y
                            set cliffFound = true
                        elseif IsTerrainPathable(x,y+i*8.,PATHING_TYPE_WALKABILITY) then
                            set cliffX = x
                            set cliffY = y+i*8.
                            set cliffFound = true
                        endif
                        set i = i+1
                    endloop
                    if cliffFound then
                        call RF_Record("OBS","native-cliff-edge","left="+I2S(GetTerrainCliffLevel(x,y))+" right="+I2S(GetTerrainCliffLevel(x+128.,y))+" above="+I2S(GetTerrainCliffLevel(x,y+128.))+" blockedActual="+R2S(cliffX)+","+R2S(cliffY))
                    endif
                endif
                set x = x+256.
            endloop
            set cliffRow = cliffRow+1
        endif
        call RemoveRect(bounds)
        set bounds = null
    endfunction

    private function Finish takes nothing returns nothing
        if actor != null then
            call RemoveUnit(actor)
            call RemoveUnit(controller)
            call RF_PathCleanup()
        endif
        call DestroyTrigger(castTrigger)
        call PauseTimer(clock)
        call DestroyTimer(clock)
        set actor = null
        set controller = null
        set castSource = null
        set castTrigger = null
        set clock = null
        call RF_Record("SKIP","multiplayer-and-visual-animation","single-client prerequisite only; S17 keeps4/s300percent and restarts each shot; no visual getter or burst implemented")
        call RF_Complete()
    endfunction

    private function Tick takes nothing returns nothing
        local boolean ready
        local rect bounds
        if stage == 0 then
            call RF_Case("O01-open")
            set ready = FindOpen()
            call RF_Check(ready,"static-open-origin-found","origin="+R2S(ox)+","+R2S(oy))
            if not ready then
                call Finish()
                return
            endif
            // Keep deliberate blocker fixtures outside the actor's footprint.
            set actor = CreateUnit(Player(0),'o000',ox-768.,oy,90.)
            set controller = CreateUnit(Player(0),'o001',-5500.,-5500.,0.)
            call RF_PathInit()
            call PanCameraTo(GetUnitX(actor),GetUnitY(actor))
            call UnitObservation(actor,"actor-native-created")
            call UnitObservation(controller,"controller-native-created")
            call RF_Check(GetUnitAbilityLevel(actor,'Ablo')==0 and GetUnitAbilityLevel(actor,'Alsh')==0 and GetUnitAbilityLevel(actor,'Apg2')==0 and GetUnitAbilityLevel(actor,'Aion')==0 and GetUnitAbilityLevel(actor,'A00G')==0,"actor-no-inherited-abilities","Ablo="+I2S(GetUnitAbilityLevel(actor,'Ablo'))+" Alsh="+I2S(GetUnitAbilityLevel(actor,'Alsh'))+" Apg2="+I2S(GetUnitAbilityLevel(actor,'Apg2'))+" Aion="+I2S(GetUnitAbilityLevel(actor,'Aion')))
            call RF_Check(GetUnitAbilityLevel(controller,'A00G')==1 and GetUnitAbilityLevel(controller,'Ablo')==0 and GetUnitAbilityLevel(controller,'Alsh')==0 and GetUnitAbilityLevel(controller,'Apg2')==0 and GetUnitAbilityLevel(controller,'Aion')==0,"controller-only-owned-channel","Channel="+I2S(GetUnitAbilityLevel(controller,'A00G'))+" inheritedAbilitiesExpectedZero=true")
            call RF_Check(GetPlayerController(Player(0))==MAP_CONTROL_USER and GetPlayerController(Player(1))==MAP_CONTROL_NONE,"runtime-controller-config","p0user="+RF_Bool(GetPlayerController(Player(0))==MAP_CONTROL_USER)+" p1none="+RF_Bool(GetPlayerController(Player(1))==MAP_CONTROL_NONE))
        elseif stage == 1 then
            call Query("open-positive",ox,oy,1)
            call Step(true,GetUnitX(actor)+8.,GetUnitY(actor))
            call RF_Case("S02-static-step")
            set sx = GetUnitX(actor)+8.
            set sy = GetUnitY(actor)
            call Query("positive-before-static-blocker",sx,sy,1)
            set savedWalkBlocked = IsTerrainPathable(sx,sy,PATHING_TYPE_WALKABILITY)
            call SetTerrainPathable(sx,sy,PATHING_TYPE_WALKABILITY,false)
        elseif stage == 2 then
            call RF_Check(IsTerrainPathable(sx,sy,PATHING_TYPE_WALKABILITY),"native-static-blocker-ready","walkBlocked="+RF_Bool(IsTerrainPathable(sx,sy,PATHING_TYPE_WALKABILITY)))
            call Query("static-negative",sx,sy,0)
            call Step(false,sx,sy)
            call SetTerrainPathable(sx,sy,PATHING_TYPE_WALKABILITY,not savedWalkBlocked)
        elseif stage == 3 then
            call RF_Check(IsTerrainPathable(sx,sy,PATHING_TYPE_WALKABILITY)==savedWalkBlocked,"static-flags-restored","actual="+RF_Bool(IsTerrainPathable(sx,sy,PATHING_TYPE_WALKABILITY)))
            call Query("positive-after-static-restoration",sx,sy,1)
            call RF_Case("D03-tree")
            call Query("positive-before-tree",ox,oy,1)
            set tree = CreateDestructable('LTlt',ox,oy,0.,1.,0)
            call RF_Record("OBS","native-tree-created","actual="+R2S(GetDestructableX(tree))+","+R2S(GetDestructableY(tree))+" life="+R2S(GetDestructableLife(tree)))
        elseif stage == 4 then
            call RF_Check(GetDestructableLife(tree)>0.,"tree-alive-ready","life="+R2S(GetDestructableLife(tree)))
            call Query("tree-alive-negative",ox,oy,0)
            call KillDestructable(tree)
        elseif stage == 5 then
            call RF_Record("OBS","tree-dead-native-life","life="+R2S(GetDestructableLife(tree)))
            call Query("tree-dead-positive",ox,oy,1)
            call RemoveDestructable(tree)
            set tree = null
        elseif stage == 6 then
            call Query("tree-removed-positive",ox,oy,1)
            call RF_Case("U04-ground-unit")
            call Query("positive-before-unit",ox,oy,1)
            set blocker = CreateUnit(Player(0),'hfoo',ox,oy,0.)
        elseif stage == 7 then
            call UnitObservation(blocker,"ground-unit-ready")
            call Query("ground-unit-negative",ox,oy,0)
            call RemoveUnit(blocker)
            set blocker = null
        elseif stage == 8 then
            call Query("unit-removed-positive",ox,oy,1)
            call RF_Case("B05-building")
            call Query("positive-before-building-center",ox,oy,1)
            call Query("positive-before-building-edge",ox+240.,oy,1)
            call Query("positive-before-building-corner",ox+240.,oy+240.,1)
            call Query("positive-before-building-outside",ox+304.,oy,1)
            set blocker = CreateUnit(Player(0),'htow',ox,oy,0.)
        elseif stage == 9 then
            call UnitObservation(blocker,"building-native-ready")
            call RF_Check(GetUnitX(blocker)==ox and GetUnitY(blocker)==oy,"building-placement-ready","native="+R2S(GetUnitX(blocker))+","+R2S(GetUnitY(blocker)))
            call Query("building-center-negative",ox,oy,0)
            call Query("building-edge-negative",ox+240.,oy,0)
            call Query("building-corner-negative",ox+240.,oy+240.,0)
            call Query("building-outside-positive",ox+304.,oy,1)
            call RemoveUnit(blocker)
            set blocker = null
        elseif stage == 10 then
            call Query("building-edge-removed-positive",ox+240.,oy,1)
            call Query("building-corner-removed-positive",ox+240.,oy+240.,1)
            call RF_Case("G06-gap16")
            call Gap(16.)
        elseif stage == 11 then
            call Query("gap16-negative",ox,oy,0)
            call RemoveGap()
        elseif stage == 12 then
            call Query("gap16-removed-positive",ox,oy,1)
            call RF_Case("G07-gap32")
            call Gap(32.)
        elseif stage == 13 then
            call Query("gap32-boundary-measurement",ox,oy,-1)
            call RemoveGap()
        elseif stage == 14 then
            call Query("gap32-removed-positive",ox,oy,1)
            call RF_Case("G08-gap64")
            call Gap(64.)
        elseif stage == 15 then
            call Query("gap64-positive",ox,oy,1)
            call RemoveGap()
        elseif stage == 16 then
            call Query("gap64-removed-positive",ox,oy,1)
            call RF_Case("I09-items")
            call Query("positive-before-items",ox,oy,1)
            set visibleItem = CreateItem('ratf',ox,oy)
            set hiddenItem = CreateItem('ratf',ox+32.,oy)
            call SetItemVisible(hiddenItem,false)
            set itemX = GetItemX(visibleItem)
            set itemY = GetItemY(visibleItem)
            set hiddenX = GetItemX(hiddenItem)
            set hiddenY = GetItemY(hiddenItem)
        elseif stage == 17 then
            call Query("item-interference-positive",ox,oy,1)
            call Step(false,GetUnitX(actor)+16.,GetUnitY(actor))
            call RemoveItem(visibleItem)
            call RemoveItem(hiddenItem)
            set visibleItem = null
            set hiddenItem = null
        elseif stage == 18 then
            call Query("items-removed-positive",ox,oy,1)
            call RF_Case("L10-bounds")
            set bounds = GetWorldBounds()
            call Query("inbounds-edge-measurement",GetRectMinX(bounds)+16.,oy,-1)
            call Query("footprint-crosses-edge-negative",GetRectMinX(bounds)+8.,oy,0)
            call Query("out-of-bounds-negative",GetRectMinX(bounds)-1.,oy,0)
            call RemoveRect(bounds)
            set bounds = null
            call RF_Case("C11-cliff")
            call Query("open-cliff-positive-control",ox,oy,1)
        elseif stage == 19 then
            call CliffRow()
            if not cliffFound and cliffRow < 64 then
                return
            endif
            call RF_Check(cliffFound,"native-cliff-fixture-found","rows="+I2S(cliffRow)+" found="+RF_Bool(cliffFound))
            if cliffFound then
                call Query("cliff-static-negative",cliffX,cliffY,0)
            endif
        elseif stage == 20 then
            call RF_Case("A12-channel")
            set castActorX = GetUnitX(actor)
            set castActorY = GetUnitY(actor)
            set castFacing = GetUnitFacing(actor)
            set castOrder = GetUnitCurrentOrder(actor)
            call RF_Record("OBS","point-order-target","target="+R2S(ox+96.)+","+R2S(oy+160.)+" controller="+R2S(GetUnitX(controller))+","+R2S(GetUnitY(controller)))
            call RF_Check(IssuePointOrder(controller,"channel",ox+96.,oy+160.),"native-channel-order-accepted","order=channel")
        elseif stage == 21 then
            set castWait = castWait+1
            if not castSeen and castWait < 8 then
                return
            endif
            call RF_Check(castSeen,"channel-effect-before-deadline","seen="+RF_Bool(castSeen)+" elapsed="+R2S(castWait*.25)+" deadline=2.000")
            if castSeen then
                call RF_Check(castSource==controller and castAbility=='A00G' and RAbsBJ(castX-(ox+96.))<.01 and RAbsBJ(castY-(oy+160.))<.01,"public-spell-effect-readback","ability="+I2S(castAbility)+" actualTarget="+R2S(castX)+","+R2S(castY))
            endif
            call RF_Check(RAbsBJ(GetUnitX(controller)-ox)>3000. or RAbsBJ(GetUnitY(controller)-oy)>3000.,"controller-off-camera-separation","actual="+R2S(GetUnitX(controller))+","+R2S(GetUnitY(controller))+" actorCameraTarget="+R2S(GetUnitX(actor))+","+R2S(GetUnitY(actor)))
            call ActorSame(castActorX,castActorY,castFacing,castOrder,"controller-cast-leaves-actor-state")
            call Finish()
            return
        endif
        set stage = stage+1
    endfunction

    function RF_Start takes nothing returns nothing
        call RF_Begin()
        set castTrigger = CreateTrigger()
        call TriggerRegisterPlayerUnitEvent(castTrigger,Player(0),EVENT_PLAYER_UNIT_SPELL_EFFECT,null)
        call TriggerAddAction(castTrigger,function Cast)
        set clock = CreateTimer()
        call TimerStart(clock,.25,true,function Tick)
    endfunction
endlibrary
