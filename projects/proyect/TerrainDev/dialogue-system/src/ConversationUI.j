// Classic 1.27b single-player prototype. Unit camera; native Inventory.onDisplay order.
// Uses the native example Hpal owner, without Inventory, Equipment or demo items.
library ConversationUI initializer Init requires UserInterface, DialogueData, DialogueProjection, HealthBars
globals
    private real WantedX = 0
    private real WantedY = 0
    private real WantedZ = 0
    private real WantedFly = 0
    private integer DumpIndex = 0
    private boolean MetricsMode = false
    private integer MetricsPage = 0
    // Preserve the original camera vector; avoid incremental float drift in follow.
    private real EyeOffsetX
    private real EyeOffsetY
    private real EyeOffsetZ
    private Camera Cam
    private unit FollowUnit = null
    private unit ReferenceTauren = null
    private unit HealthEnemy = null
    private unit Frame = null
    private unit LeftPortrait = null
    private unit RightPortrait = null
    private boolean LeftTalking = false
    private boolean RightTalking = false
    private boolean PortraitVisible = false
    private integer PortraitProbe = -1
    private integer PortraitProjectionProbe = 0
    private integer LeftSequence = -1
    private integer RightSequence = -1
    private real PortraitTime = 0
    private real LeftIdleUntil = 0
    private real RightIdleUntil = 0
    private integer LeftIdleSlot = 0
    private integer RightIdleSlot = 0
    private boolean PendingClose = false
    private UIText Name
    private UIText array Body
    private UIText Hint
    private timer Clock = CreateTimer()
    private integer Page = 0
    private integer Cursor = 0
    private real Wait = 0
    private integer Opening = 0
    private integer Closing = 0
    private integer Blink = 0
    private boolean Active = false
    private boolean Paused = false
endglobals

// Same owner -> Camera -> Interface order as native Inventory.onDisplay.
private function FollowCamera takes nothing returns nothing
    local real x
    local real y
    local real z
    if FollowUnit != null and GetUnitTypeId(FollowUnit) != 0 then
        set x = GetUnitX(FollowUnit)
        set y = GetUnitY(FollowUnit)
        set z = UserInterface_GetTerrainZ(x,y)+GetUnitFlyHeight(FollowUnit)
        call Cam.setPosition(x,y,z)
        // Absolute reconstruction in this fixed-orientation adapter only.
        // Camera's original setPosition, axes and projection remain unchanged.
        set Cam.eye.x = x+EyeOffsetX
        set Cam.eye.y = y+EyeOffsetY
        set Cam.eye.z = z+EyeOffsetZ
    endif
    call Cam.applyCameraForPlayer(Player(0),true)
endfunction

// Public integration point; the demo binds its own selectable Hpal once.
function ConversationBindUnit takes unit u returns nothing
    set FollowUnit = u
    call FollowCamera()
endfunction

private function ProjectFrame takes nothing returns nothing
    local VECTOR3 pos = Cam.win2World(DialogueFrameX[Page],DialogueFrameY[Page],DIALOGUE_DEPTH)
    set WantedX = pos.x
    set WantedY = pos.y
    set WantedZ = pos.z
    set WantedFly = pos.z-UserInterface_GetTerrainZ(pos.x,pos.y)
    call SetUnitX(Frame,pos.x)
    call SetUnitY(Frame,pos.y)
    call SetUnitFlyHeight(Frame,WantedFly,0)
    call SetUnitScale(Frame,DialogueFrameScale[Page],DialogueFrameScale[Page],DialogueFrameScale[Page])
    call pos.destroy()
endfunction

private function ProjectPortrait takes unit actor, real offsetX, real offsetY, real scale returns nothing
    local real depth = DIALOGUE_DEPTH+2.*DialogueFrameScale[Page]
    local real x = DialogueFrameX[Page]+offsetX*DialogueFrameScale[Page]/(SCREEN_WIDTH*DIALOGUE_DEPTH)
    local real y = DialogueFrameY[Page]+offsetY*DialogueFrameScale[Page]/(SCREEN_HEIGHT*DIALOGUE_DEPTH)
    local VECTOR3 pos = Cam.win2World(x,y,depth)
    if PortraitProjectionProbe != 3 and PortraitProjectionProbe != 4 then
        call SetUnitX(actor,pos.x)
        call SetUnitY(actor,pos.y)
    endif
    if PortraitProjectionProbe != 2 and PortraitProjectionProbe != 4 then
        call SetUnitFlyHeight(actor,pos.z-UserInterface_GetTerrainZ(pos.x,pos.y),0)
    endif
    if PortraitProjectionProbe != 1 and PortraitProjectionProbe != 4 then
        call SetUnitScale(actor,scale*DialogueFrameScale[Page]*depth/DIALOGUE_DEPTH,scale*DialogueFrameScale[Page]*depth/DIALOGUE_DEPTH,scale*DialogueFrameScale[Page]*depth/DIALOGUE_DEPTH)
    endif
    call pos.destroy()
endfunction

private function PortraitState takes boolean speaking, boolean visible returns nothing
    local boolean left = speaking and DialogueLeft[Page]
    local boolean right = speaking and not DialogueLeft[Page]
    // Visibility changes can reset a native unit animation: show BEFORE selecting it.
    if visible != PortraitVisible then
        call ShowUnit(LeftPortrait,visible)
        call ShowUnit(RightPortrait,visible)
        set PortraitVisible = visible
    endif
    if PortraitProbe >= 0 then
        return
    endif
    if left != LeftTalking then
        set LeftTalking = left
        if left then
            set LeftSequence = DIALOGUE_LEFT_TALK
            call SetUnitAnimationByIndex(LeftPortrait,LeftSequence)
        else
            set LeftIdleSlot = 0
            set LeftIdleUntil = 0
        endif
    endif
    if right != RightTalking then
        set RightTalking = right
        if right then
            set RightSequence = DIALOGUE_RIGHT_TALK
            call SetUnitAnimationByIndex(RightPortrait,RightSequence)
        else
            set RightIdleSlot = 0
            set RightIdleUntil = 0
        endif
    endif
    // Whole original idle clips, in deterministic order; no synchronized RNG.
    if visible and not left and PortraitTime >= LeftIdleUntil then
        set LeftSequence = DialogueLeftIdle[LeftIdleSlot]
        call SetUnitAnimationByIndex(LeftPortrait,LeftSequence)
        set LeftIdleUntil = PortraitTime+DialogueLeftIdleDuration[LeftIdleSlot]
        set LeftIdleSlot = ModuloInteger(LeftIdleSlot+1,DIALOGUE_LEFT_IDLE_COUNT)
    endif
    if visible and not right and PortraitTime >= RightIdleUntil then
        set RightSequence = DialogueRightIdle[RightIdleSlot]
        call SetUnitAnimationByIndex(RightPortrait,RightSequence)
        set RightIdleUntil = PortraitTime+DialogueRightIdleDuration[RightIdleSlot]
        set RightIdleSlot = ModuloInteger(RightIdleSlot+1,DIALOGUE_RIGHT_IDLE_COUNT)
    endif
    if DialogueLeft[Page] then
        call SetUnitVertexColor(LeftPortrait,255,255,255,255)
        call SetUnitVertexColor(RightPortrait,166,166,166,255)
    else
        call SetUnitVertexColor(LeftPortrait,166,166,166,255)
        call SetUnitVertexColor(RightPortrait,255,255,255,255)
    endif
endfunction

private function Render takes nothing returns nothing
    local integer i = 0
    call SetTextTagText(Name.text,DialogueSpeaker[Page],DialogueFont[Page]*1.37)
    loop
        exitwhen i == DIALOGUE_BODY_TAGS
        call SetTextTagText(Body[i].text,DialogueText(i,Cursor),DialogueFont[Page])
        call SetTextTagColor(Body[i].text,DialogueR[Page],DialogueG[Page],DialogueB[Page],255)
        set i = i+1
    endloop
endfunction

private function BeginPage takes nothing returns nothing
    local integer i = 0
    call Name.setPosition(DialogueNameX[Page],DialogueNameY[Page])
    call Hint.setPosition(DialogueHintX[Page],DialogueHintY[Page])
    loop
        exitwhen i == DIALOGUE_BODY_TAGS
        call Body[i].setPosition(DialogueX(i,Page),DialogueY(i,Page))
        set i = i+1
    endloop
    set Cursor = DialogueStart[Page]
    set Wait = 1./DIALOGUE_SPEED
    if Opening == 0 and Closing == 0 then
      if DialogueLeft[Page] then
        call SetUnitAnimationByIndex(Frame,1)
    else
        call SetUnitAnimationByIndex(Frame,0)
      endif
    endif
    call Render()
endfunction

private function ShowText takes boolean flag returns nothing
    local integer i = 0
    call Name.show(flag,Cam)
    call Hint.show(flag,Cam)
    loop
        exitwhen i == DIALOGUE_BODY_TAGS
        call Body[i].show(flag,Cam)
        set i = i+1
    endloop
endfunction

private function Close takes nothing returns nothing
    if Active and Closing == 0 then
        call ShowText(false)
        if Opening > 0 then
            set PendingClose = true
            return
        endif
        set PendingClose = false
        set Closing = DIALOGUE_LOSS+DIALOGUE_FOLD+DIALOGUE_LINECLOSE
        if DialogueLeft[Page] then
            call SetUnitAnimationByIndex(Frame,5)
        else
            call SetUnitAnimationByIndex(Frame,3)
        endif
        call PortraitState(false,true)
    endif
endfunction

function ConversationAdvance takes nothing returns nothing
    if not Active or Opening > 0 or Closing > 0 or PendingClose then
        return
    endif
    if Cursor < DialogueEnd[Page] then
        set Cursor = DialogueEnd[Page]
        call Render()
        call PortraitState(false,true)
    elseif Page+1 < DIALOGUE_COUNT then
        set Page = Page+1
        call BeginPage()
    else
        call Close()
    endif
endfunction

private function Tick takes nothing returns nothing
    set PortraitTime = PortraitTime+0.01
    // Follow even while closed; opening never changes the viewport or camera mode.
    call FollowCamera()
    call HealthBarsUpdate()
    call Interface.updateAll(false,false,true)
    if MetricsMode then
        call ShowText(true)
        call SetTextTagText(Hint.text,"",0.017)
        return
    endif
    if not Active then
        return
    endif
    call ProjectFrame()
    call ProjectPortrait(LeftPortrait,-49.+DIALOGUE_LEFT_X,11.051890+DIALOGUE_LEFT_Y,DIALOGUE_LEFT_SCALE)
    call ProjectPortrait(RightPortrait,49.42+DIALOGUE_RIGHT_X,11.051890+DIALOGUE_RIGHT_Y,DIALOGUE_RIGHT_SCALE)
    if Closing > 0 then
        set Closing = Closing-1
        call PortraitState(false,Closing > DIALOGUE_FOLD+DIALOGUE_LINECLOSE)
        if Closing == 0 then
            call ShowUnit(Frame,false)
            set Active = false
        endif
        return
    endif
    if Opening > 0 then
        set Opening = Opening-1
        call PortraitState(false,Opening <= DIALOGUE_ACQUIRE)
        if Opening == DIALOGUE_ACQUIRE and not PendingClose then
            call ShowText(true)
        endif
        if Opening == 0 then
            if DialogueLeft[Page] then
                call SetUnitAnimationByIndex(Frame,1)
            else
                call SetUnitAnimationByIndex(Frame,0)
            endif
            if PendingClose then
                call Close()
                return
            endif
        elseif Opening > DIALOGUE_ACQUIRE then
            return
        endif
    endif
    if PendingClose then
        return
    endif
    if not Paused and Cursor < DialogueEnd[Page] then
        set Wait = Wait-0.01
        if Wait <= 0 then
            set Cursor = Cursor+1
            // Retain fractional elapsed time: 30 graphemes/sec, punctuation pause x6.
            set Wait = Wait+I2R(DialoguePause[Cursor])/DIALOGUE_SPEED
            call Render()
        endif
    endif
    call PortraitState(not Paused and Cursor < DialogueEnd[Page],true)
    set Blink = ModuloInteger(Blink+1,100)
    if Cursor == DialogueEnd[Page] and Blink < 65 then
        call SetTextTagText(Hint.text,">  [Esc]",0.017)
    else
        call SetTextTagText(Hint.text,"",0.017)
    endif
endfunction

function ConversationOpen takes nothing returns nothing
    if Active or MetricsMode or Frame == null then
        return
    endif
    set Page = 0
    set Paused = false
    set Active = true
    set Opening = DIALOGUE_LINEOPEN+DIALOGUE_UNFOLD+DIALOGUE_ACQUIRE
    set Closing = 0
    set PendingClose = false
    set LeftIdleSlot = 0
    set RightIdleSlot = 0
    set LeftIdleUntil = 0
    set RightIdleUntil = 0
    call PortraitState(false,false)
    call ShowText(false)
    set Cursor = DialogueStart[0]
    call BeginPage()
    call FollowCamera()
    call ProjectFrame()
    call ShowUnit(Frame,true)
    if DialogueLeft[Page] then
        call SetUnitAnimationByIndex(Frame,4)
    else
        call SetUnitAnimationByIndex(Frame,2)
    endif
endfunction

function ConversationRestart takes nothing returns nothing
    if MetricsMode then
        return
    endif
    call ShowText(false)
    set Active = false
    call ConversationOpen()
endfunction

// Development-only calibration: reuse the same pool, one sample per slot.
private function ShowMetrics takes nothing returns nothing
    local integer i = 0
    local integer glyph = MetricsPage*DIALOGUE_BODY_TAGS
    local real x
    local real y
    call ShowUnit(Frame,false)
    call SetTextTagText(Name.text,"METRICAS "+I2S(MetricsPage+1),0.02)
    call Name.setPosition(-1.15,0.6)
    call Name.show(true,Cam)
    call Hint.show(false,Cam)
    loop
        exitwhen i == DIALOGUE_BODY_TAGS
        set x = (100.+440.*I2R(ModuloInteger(i,4))-960.)/728.
        set y = (420.-180.-180.*I2R(i/4))/390.
        call Body[i].setPosition(x,y)
        if glyph+i < DIALOGUE_METRIC_COUNT then
            call SetTextTagText(Body[i].text,DialogueMetricGlyph[glyph+i],0.027)
        else
            call SetTextTagText(Body[i].text,"",0.027)
        endif
        call SetTextTagColor(Body[i].text,255,40,220,255)
        call Body[i].show(true,Cam)
        set i = i+1
    endloop
endfunction

// Explicit development command: records projection data; no per-tick file writes.
private function Dump takes nothing returns nothing
    local rect bounds = GetWorldBounds()
    set DumpIndex = DumpIndex+1
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("logicalEye="+R2S(Cam.eye.x)+","+R2S(Cam.eye.y)+","+R2S(Cam.eye.z))
    call Preload("logicalAt="+R2S(Cam.at.x)+","+R2S(Cam.at.y)+","+R2S(Cam.at.z)+" deltaZ="+R2S(GetCameraDeltaZ()))
    call Preload("terrainRef="+R2S(UserInterface_GetTerrainZ(CHECK_DELTAZ_X,CHECK_DELTAZ_Y))+" dummy="+R2S(UserInterface_GetTerrainZ(0,0))+" owner="+R2S(UserInterface_GetTerrainZ(GetUnitX(FollowUnit),GetUnitY(FollowUnit))))
    call Preload("eye="+R2S(GetCameraEyePositionX())+","+R2S(GetCameraEyePositionY())+","+R2S(GetCameraEyePositionZ()))
    call Preload("target="+R2S(GetCameraTargetPositionX())+","+R2S(GetCameraTargetPositionY())+","+R2S(GetCameraTargetPositionZ()))
    call Preload("zoffset="+R2S(GetCameraField(CAMERA_FIELD_ZOFFSET)))
    call Preload("angles="+R2S(GetCameraField(CAMERA_FIELD_ROTATION))+","+R2S(GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK))+","+R2S(GetCameraField(CAMERA_FIELD_FIELD_OF_VIEW)))
    call Preload("requested="+R2S(WantedX)+","+R2S(WantedY)+","+R2S(WantedZ)+" fly="+R2S(WantedFly))
    call Preload("actual="+R2S(GetUnitX(Frame))+","+R2S(GetUnitY(Frame))+","+R2S(GetUnitFlyHeight(Frame)+UserInterface_GetTerrainZ(GetUnitX(Frame),GetUnitY(Frame)))+" fly="+R2S(GetUnitFlyHeight(Frame)))
    call Preload("bounds="+R2S(GetRectMinX(bounds))+","+R2S(GetRectMinY(bounds))+","+R2S(GetRectMaxX(bounds))+","+R2S(GetRectMaxY(bounds)))
    call Preload("owner="+R2S(GetUnitX(FollowUnit))+","+R2S(GetUnitY(FollowUnit))+" scale="+R2S(DialogueFrameScale[Page]))
    call Preload("depth="+R2S(DIALOGUE_DEPTH)+" width="+R2S(DialogueFrameWidth[Page])+" y="+R2S(DialogueFrameY[Page])+" page="+I2S(Page)+" cursor="+I2S(Cursor))
    call Preload("heroOwner="+I2S(GetPlayerId(GetOwningPlayer(FollowUnit)))+" order="+I2S(GetUnitCurrentOrder(FollowUnit))+" mana="+R2S(GetUnitState(FollowUnit,UNIT_STATE_MANA))+" referenceLife="+R2S(GetWidgetLife(ReferenceTauren)))
    if GetPlayerAlliance(GetOwningPlayer(FollowUnit),Player(0),ALLIANCE_SHARED_CONTROL) then
        call Preload("sharedControl=1")
    else
        call Preload("sharedControl=0")
    endif
    call Preload("portraitTime="+R2S(PortraitTime)+" leftSequence="+I2S(LeftSequence)+" rightSequence="+I2S(RightSequence))
    call Preload("leftIdleUntil="+R2S(LeftIdleUntil)+" rightIdleUntil="+R2S(RightIdleUntil))
    call PreloadGenEnd("Logs\\DialogueProjection-"+I2S(DumpIndex)+".txt")
    call RemoveRect(bounds)
    set bounds = null
endfunction

private function Key takes nothing returns nothing
    if GetTriggerEventId() == EVENT_PLAYER_ARROW_UP_DOWN then
        call Dump()
        return
    endif
    if MetricsMode then
        set MetricsPage = MetricsPage+1
        if MetricsPage*DIALOGUE_BODY_TAGS < DIALOGUE_METRIC_COUNT then
            call ShowMetrics()
        else
            set MetricsMode = false
            call ShowText(false)
        endif
        return
    endif
    call ConversationAdvance()
endfunction

private function ViewStart takes integer i returns nothing
    local real x = GetStartLocationX(i)
    local real y = GetStartLocationY(i)
    // Development teleport moves the bound unit, never detaches its camera.
    call SetUnitPosition(FollowUnit,x,y)
    call FollowCamera()
endfunction

private function Chat takes nothing returns nothing
    local string s = GetEventPlayerChatString()
    if s == "-controlbasico" then
        call SetPlayerAlliance(Player(10),Player(0),ALLIANCE_SHARED_ADVANCED_CONTROL,false)
    elseif s == "-controlavanzado" then
        call SetPlayerAlliance(Player(10),Player(0),ALLIANCE_SHARED_ADVANCED_CONTROL,true)
    elseif SubString(s,0,11) == "-vidaheroe " then
        call HealthBarsDemoLife(true,S2I(SubString(s,11,StringLength(s))))
    elseif SubString(s,0,13) == "-vidaenemigo " then
        call HealthBarsDemoLife(false,S2I(SubString(s,13,StringLength(s))))
    elseif s == "-barrasocultar" then
        call HealthBarsSetVisible(false)
    elseif s == "-barrasmostrar" then
        call HealthBarsSetVisible(true)
    elseif s == "-barrasobjetivopaladin" then
        call HealthBarsTarget(FollowUnit)
    elseif s == "-barrasobjetivotauren" then
        call HealthBarsTarget(HealthEnemy)
    elseif SubString(s,0,15) == "-retratoprueba " then
        set PortraitProbe = S2I(SubString(s,15,StringLength(s)))
        if PortraitProbe < 0 or PortraitProbe > 4 then
            set PortraitProbe = 0
        endif
        call SetUnitTimeScale(LeftPortrait,1.)
        call SetUnitTimeScale(RightPortrait,1.)
        call SetUnitAnimationByIndex(LeftPortrait,PortraitProbe)
        call SetUnitAnimationByIndex(RightPortrait,PortraitProbe)
        call DisplayTimedTextToPlayer(Player(0),0,0,5,"Retrato: indice "+I2S(PortraitProbe)+"; controlador automatico suspendido.")
    elseif SubString(s,0,18) == "-retratoproyectar " then
        set PortraitProjectionProbe = S2I(SubString(s,18,StringLength(s)))
        call DisplayTimedTextToPlayer(Player(0),0,0,5,"Proyeccion de retrato: modo "+I2S(PortraitProjectionProbe))
    elseif s == "-retratoauto" then
        set PortraitProbe = -1
        set PortraitProjectionProbe = 0
        set LeftIdleUntil = 0
        set RightIdleUntil = 0
        set LeftTalking = false
        set RightTalking = false
    elseif s == "-metricas" and not Active then
        set MetricsMode = true
        set MetricsPage = 0
        call FollowCamera()
        call ShowMetrics()
        call TimerStart(Clock,0.01,true,function Tick)
    elseif s == "-taurenhud" then
        call SetUnitPosition(ReferenceTauren,GetUnitX(FollowUnit)+180,GetUnitY(FollowUnit))
        if GetLocalPlayer() == Player(0) then
            call ClearSelection()
            call SelectUnit(ReferenceTauren,true)
        endif
    elseif s == "-paladinhud" then
        if GetLocalPlayer() == Player(0) then
            call ClearSelection()
            call SelectUnit(FollowUnit,true)
        endif
    elseif s == "-caminardialogo" then
        // Development check: native pathfinding, independent of desktop pointer.
        call IssuePointOrder(FollowUnit,"move",GetUnitX(FollowUnit)+350,GetUnitY(FollowUnit)+650)
    elseif s == "-patrullardialogo" then
        call IssuePointOrder(FollowUnit,"patrol",GetUnitX(FollowUnit)+350,GetUnitY(FollowUnit)+650)
    elseif s == "-parardialogo" then
        call IssueImmediateOrder(FollowUnit,"stop")
    elseif s == "-dialogodiag" then
        call Dump()
    elseif s == "-vista0" then
        call ViewStart(0)
    elseif s == "-vista1" then
        call ViewStart(1)
    elseif s == "-dialogo" then
        call ConversationOpen()
    elseif s == "-reiniciardialogo" then
        call ConversationRestart()
    elseif s == "-siguiente" then
        call ConversationAdvance()
    elseif s == "-pausadialogo" then
        set Paused = not Paused
    elseif s == "-cerrardialogo" then
        call Close()
    endif
endfunction

private function CalibrateCamera takes nothing returns nothing
    call Cam.calibrateHeightForPlayer(Player(0))
    call FollowCamera()
    call DestroyTimer(GetExpiredTimer())
endfunction

private function Start takes nothing returns nothing
    local integer i = 0
    local location start = GetStartLocationLoc(GetPlayerStartLocation(Player(0)))
    local real x = GetLocationX(start)
    local real y = GetLocationY(start)
    set Cam = Camera.create()
    set EyeOffsetX = Cam.eye.x-Cam.at.x
    set EyeOffsetY = Cam.eye.y-Cam.at.y
    set EyeOffsetZ = Cam.eye.z-Cam.at.z
    call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_EXTRA),Player(0),bj_ALLIANCE_ALLIED_VISION)
    call SetPlayerAllianceStateBJ(Player(0),Player(bj_PLAYER_NEUTRAL_EXTRA),bj_ALLIANCE_ALLIED_VISION)
    // Native Hpal example with a dedicated shared owner; no inventory/items instantiated.
    // Dedicated owner10 is outside the two configured user slots. Share only its units.
    call SetPlayerAlliance(Player(10),Player(0),ALLIANCE_PASSIVE,true)
    call SetPlayerAlliance(Player(0),Player(10),ALLIANCE_PASSIVE,true)
    call SetPlayerAlliance(Player(10),Player(0),ALLIANCE_SHARED_VISION,true)
    call SetPlayerAlliance(Player(0),Player(10),ALLIANCE_SHARED_VISION,true)
    call SetPlayerAlliance(Player(10),Player(0),ALLIANCE_SHARED_CONTROL,true)
    call SetPlayerAlliance(Player(10),Player(0),ALLIANCE_SHARED_ADVANCED_CONTROL,false)
    set FollowUnit = CreateUnit(Player(10),'Hpal',x+220,y,270)
    call SetUnitColor(FollowUnit,GetPlayerColor(Player(0)))
    // A learned native skill for the shared-control input test.
    call SelectHeroSkill(FollowUnit,'AHhb')
    call SetUnitInvulnerable(FollowUnit,true)
    // Unmodified standard otau: native model/portrait for visual reference.
    set ReferenceTauren = CreateUnit(Player(0),'otau',x+400,y,270)
    call SetUnitInvulnerable(ReferenceTauren,true)
    call SetWidgetLife(ReferenceTauren,500.)
    call IssueImmediateOrder(ReferenceTauren,"holdposition")
    call FollowCamera()
    if GetLocalPlayer() == Player(0) then
        call ClearSelection()
        call SelectUnit(FollowUnit,true)
    endif
    // Native UI dummy settings (uidm/float + Aave height unlock), no zero-scale hiding.
    // 140 x 58.32132 model; scale and anchor use the same camera plane as UIText.
    set Frame = CreateUnit(CAMERA_DUMMY_PLAYER,'dlog',x,y,270)
    call SetUnitInvulnerable(Frame,true)
    call UnitAddAbility(Frame,Interface.DESTROYER_FORM_ID)
    call UnitRemoveAbility(Frame,Interface.DESTROYER_FORM_ID)
    call ProjectFrame()
    call ShowUnit(Frame,false)
    set LeftPortrait = CreateUnit(CAMERA_DUMMY_PLAYER,DIALOGUE_LEFT_TYPE,x,y,270)
    set RightPortrait = CreateUnit(CAMERA_DUMMY_PLAYER,DIALOGUE_RIGHT_TYPE,x,y,270)
    call UnitAddAbility(LeftPortrait,Interface.DESTROYER_FORM_ID)
    call UnitRemoveAbility(LeftPortrait,Interface.DESTROYER_FORM_ID)
    call UnitAddAbility(RightPortrait,Interface.DESTROYER_FORM_ID)
    call UnitRemoveAbility(RightPortrait,Interface.DESTROYER_FORM_ID)
    call SetUnitAnimationByIndex(LeftPortrait,DIALOGUE_LEFT_IDLE)
    call SetUnitAnimationByIndex(RightPortrait,DIALOGUE_RIGHT_IDLE)
    call ShowUnit(LeftPortrait,false)
    call ShowUnit(RightPortrait,false)
    set Name = UIText.create(-0.60,-0.33,1)
    loop
        exitwhen i == DIALOGUE_BODY_TAGS
        set Body[i] = UIText.create(0,0,1)
        call SetTextTagPermanent(Body[i].text,true)
        set i = i+1
    endloop
    set Hint = UIText.create(0.86,-0.87,1)
    call SetTextTagPermanent(Name.text,true)
    call SetTextTagPermanent(Hint.text,true)
    call SetTextTagColor(Name.text,255,255,255,255)
    call SetTextTagColor(Hint.text,255,255,255,255)
    set HealthEnemy = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE),'otau',x+800,y+300,270)
    call SetUnitInvulnerable(HealthEnemy,true)
    call PauseUnit(HealthEnemy,true)
    call HealthBarsBind(Cam,FollowUnit,HealthEnemy)
    call RemoveLocation(start)
    set start = null
    call TimerStart(Clock,0.01,true,function Tick)
    call TimerStart(CreateTimer(),0.10,false,function CalibrateCamera)
    call DisplayTimedTextToPlayer(Player(0),0,0,25,"Camara de unidad activa. Mueve al paladin con clic derecho. -dialogo abre; -reiniciardialogo reinicia; -cerrardialogo cierra. Esc/derecha avanza. HUD normal visible.")
    call DestroyTimer(GetExpiredTimer())
endfunction

private function Init takes nothing returns nothing
    local trigger key = CreateTrigger()
    local trigger chat = CreateTrigger()
    call TriggerRegisterPlayerEvent(key,Player(0),EVENT_PLAYER_ARROW_UP_DOWN)
    call TriggerRegisterPlayerEvent(key,Player(0),EVENT_PLAYER_ARROW_RIGHT_DOWN)
    call TriggerRegisterPlayerEvent(key,Player(0),EVENT_PLAYER_END_CINEMATIC)
    call TriggerAddAction(key,function Key)
    call TriggerRegisterPlayerChatEvent(chat,Player(0),"-",false)
    call TriggerAddAction(chat,function Chat)
    call TimerStart(CreateTimer(),0.2,false,function Start)
endfunction
endlibrary
