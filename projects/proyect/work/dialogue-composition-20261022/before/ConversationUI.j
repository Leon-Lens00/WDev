// Classic 1.27b single-player prototype. Camera projection inherited from UI Studio base.
// This demo does not instantiate Inventory, Equipment, items or their example hero.
library ConversationUI initializer Init requires UserInterface, DialogueData, DialogueProjection
globals
    private real WantedX = 0
    private real WantedY = 0
    private real WantedZ = 0
    private real WantedFly = 0
    private integer DumpIndex = 0
    private Camera Cam
    private unit Frame = null
    private UIText Name
    private UIText Line0
    private UIText Line1
    private UIText Line2
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

private function ProjectFrame takes nothing returns nothing
    local real ex = GetCameraEyePositionX()
    local real ey = GetCameraEyePositionY()
    local real ez = GetCameraEyePositionZ()
    local real yaw = GetCameraField(CAMERA_FIELD_ROTATION)
    local real pitch = GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK)
    local real dx = Cos(pitch)*Cos(yaw)
    local real dy = Cos(pitch)*Sin(yaw)
    local real dz = Sin(pitch)
    local real horizontal = SquareRoot(dx*dx+dy*dy)
    local real length = 1
    local real depth = DIALOGUE_DEPTH
    local real halfWidth = depth*Tan(GetCameraField(CAMERA_FIELD_FIELD_OF_VIEW)/2)
    local real upOffset = DIALOGUE_CENTER_Y*halfWidth/2.4
    local real x
    local real y
    local real z
    if length < 0.001 or horizontal < 0.001 then
        return
    endif
    set x = ex+depth*dx/length-upOffset*dx*dz/(horizontal*length)
    set y = ey+depth*dy/length-upOffset*dy*dz/(horizontal*length)
    set z = ez+depth*dz/length+upOffset*horizontal/length
    set WantedX = x
    set WantedY = y
    set WantedZ = z
    set WantedFly = z-UserInterface_GetTerrainZ(x,y)
    call SetUnitX(Frame,x)
    call SetUnitY(Frame,y)
    call SetUnitFlyHeight(Frame,z-UserInterface_GetTerrainZ(x,y),0)
    call SetUnitScale(Frame,DIALOGUE_FRUSTUM_WIDTH*2*halfWidth/DIALOGUE_MODEL_WIDTH,DIALOGUE_FRUSTUM_WIDTH*2*halfWidth/DIALOGUE_MODEL_WIDTH,DIALOGUE_FRUSTUM_WIDTH*2*halfWidth/DIALOGUE_MODEL_WIDTH)
endfunction

private function Render takes nothing returns nothing
    local integer r = 231
    local integer g = 134
    local integer b = 145
    if DialogueLeft[Page] then
        set r = 129
        set g = 200
        set b = 226
    endif
    call SetTextTagText(Name.text, DialogueSpeaker[Page], 0.037)
    call SetTextTagText(Line0.text, DialogueLine0[Cursor], 0.027)
    call SetTextTagText(Line1.text, DialogueLine1[Cursor], 0.027)
    call SetTextTagText(Line2.text, DialogueLine2[Cursor], 0.027)
    call SetTextTagColor(Line0.text,r,g,b,255)
    call SetTextTagColor(Line1.text,r,g,b,255)
    call SetTextTagColor(Line2.text,r,g,b,255)
endfunction

private function BeginPage takes nothing returns nothing
    set Cursor = DialogueStart[Page]
    set Wait = 0
    if DialogueLeft[Page] then
        call SetUnitAnimationByIndex(Frame,1)
    else
        call SetUnitAnimationByIndex(Frame,0)
    endif
    call Render()
endfunction

private function Close takes nothing returns nothing
    if Active and Closing == 0 then
        set Closing = 18
        call SetUnitAnimationByIndex(Frame,3)
        call Name.show(false,-1)
        call Line0.show(false,-1)
        call Line1.show(false,-1)
        call Line2.show(false,-1)
        call Hint.show(false,-1)
    endif
endfunction

function ConversationAdvance takes nothing returns nothing
    if not Active or Opening > 0 or Closing > 0 then
        return
    endif
    if Cursor < DialogueEnd[Page] then
        set Cursor = DialogueEnd[Page]
        call Render()
    elseif Page+1 < DIALOGUE_COUNT then
        set Page = Page+1
        call BeginPage()
    else
        call Close()
    endif
endfunction

private function Tick takes nothing returns nothing
    // Actual native eye, rotation/pitch and FOV, refreshed every 10 ms.
    call Cam.applyCameraForPlayer(Player(0),true)
    call Interface.updateAll(false,false,true)
    call ProjectFrame()
    if Closing > 0 then
        set Closing = Closing-1
        if Closing == 0 then
            call ShowUnit(Frame,false)
            call PauseTimer(Clock)
            call ShowInterface(true,0)
            call ResetToGameCamera(0)
            set Active = false
        endif
        return
    endif
    if Opening > 0 then
        set Opening = Opening-1
        if Opening == 0 then
            call Name.show(true,Cam)
            call Line0.show(true,Cam)
            call Line1.show(true,Cam)
            call Line2.show(true,Cam)
            call Hint.show(true,Cam)
            call BeginPage()
        endif
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
    set Blink = ModuloInteger(Blink+1,100)
    if Cursor == DialogueEnd[Page] and Blink < 65 then
        call SetTextTagText(Hint.text,">  [Esc]",0.017)
    else
        call SetTextTagText(Hint.text,"",0.017)
    endif
endfunction

function ConversationOpen takes nothing returns nothing
    if Active or Frame == null then
        return
    endif
    set Page = 0
    set Paused = false
    set Active = true
    set Opening = 18
    set Closing = 0
    set Cursor = DialogueStart[0]
    call ShowInterface(false,0)
    call EnableUserUI(true)
    call EnableUserControl(true)
    call ProjectFrame()
    call ShowUnit(Frame,true)
    call SetUnitAnimationByIndex(Frame,2)
    call TimerStart(Clock,0.01,true,function Tick)
endfunction

private function Key takes nothing returns nothing
    call ConversationAdvance()
endfunction

// Explicit development command: records projection data; no per-tick file writes.
private function Dump takes nothing returns nothing
    local rect bounds = GetWorldBounds()
    set DumpIndex = DumpIndex+1
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("eye="+R2S(GetCameraEyePositionX())+","+R2S(GetCameraEyePositionY())+","+R2S(GetCameraEyePositionZ()))
    call Preload("target="+R2S(GetCameraTargetPositionX())+","+R2S(GetCameraTargetPositionY())+","+R2S(GetCameraTargetPositionZ()))
    call Preload("angles="+R2S(GetCameraField(CAMERA_FIELD_ROTATION))+","+R2S(GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK))+","+R2S(GetCameraField(CAMERA_FIELD_FIELD_OF_VIEW)))
    call Preload("requested="+R2S(WantedX)+","+R2S(WantedY)+","+R2S(WantedZ)+" fly="+R2S(WantedFly))
    call Preload("actual="+R2S(GetUnitX(Frame))+","+R2S(GetUnitY(Frame))+","+R2S(GetUnitFlyHeight(Frame)+UserInterface_GetTerrainZ(GetUnitX(Frame),GetUnitY(Frame)))+" fly="+R2S(GetUnitFlyHeight(Frame)))
    call Preload("bounds="+R2S(GetRectMinX(bounds))+","+R2S(GetRectMinY(bounds))+","+R2S(GetRectMaxX(bounds))+","+R2S(GetRectMaxY(bounds)))
    call Preload("depth="+R2S(DIALOGUE_DEPTH)+" width="+R2S(DIALOGUE_FRUSTUM_WIDTH)+" y="+R2S(DIALOGUE_CENTER_Y)+" page="+I2S(Page)+" cursor="+I2S(Cursor))
    call PreloadGenEnd("Logs\\DialogueProjection-"+I2S(DumpIndex)+".txt")
    call RemoveRect(bounds)
    set bounds = null
endfunction

private function ViewStart takes integer i returns nothing
    local real x = GetStartLocationX(i)
    local real y = GetStartLocationY(i)
    call Cam.setPosition(x,y,UserInterface_GetTerrainZ(x,y))
    call Cam.applyCameraForPlayer(Player(0),true)
endfunction

private function Chat takes nothing returns nothing
    local string s = GetEventPlayerChatString()
    if s == "-dialogodiag" then
        call Dump()
    elseif s == "-vista0" then
        call ViewStart(0)
    elseif s == "-vista1" then
        call ViewStart(1)
    elseif s == "-dialogo" then
        call ConversationOpen()
    elseif s == "-siguiente" then
        call ConversationAdvance()
    elseif s == "-pausadialogo" then
        set Paused = not Paused
    elseif s == "-cerrardialogo" then
        call Close()
    endif
endfunction

private function OpenDelayed takes nothing returns nothing
    call ConversationOpen()
    call DestroyTimer(GetExpiredTimer())
endfunction

private function Start takes nothing returns nothing
    local location start = GetStartLocationLoc(GetPlayerStartLocation(Player(0)))
    local real x = GetLocationX(start)
    local real y = GetLocationY(start)
    set Cam = Camera.create()
    call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_EXTRA),Player(0),bj_ALLIANCE_ALLIED_VISION)
    call SetPlayerAllianceStateBJ(Player(0),Player(bj_PLAYER_NEUTRAL_EXTRA),bj_ALLIANCE_ALLIED_VISION)
    call Cam.setPosition(x,y,GetLocationZ(start))
    call Cam.applyCameraForPlayer(Player(0),true)
    // A dedicated flying dummy uses ShowUnit, keeping scale and pose intact.
    // 140 x 58.32132 model; scale is derived from FOV in ProjectFrame.
    set Frame = CreateUnit(CAMERA_DUMMY_PLAYER,'dlog',x,y,270)
    call SetUnitInvulnerable(Frame,true)
    call ProjectFrame()
    call ShowUnit(Frame,false)
    set Name = UIText.create(-0.60,-0.33,1)
    set Line0 = UIText.create(-0.60,-0.53,1)
    set Line1 = UIText.create(-0.60,-0.63,1)
    set Line2 = UIText.create(-0.60,-0.73,1)
    set Hint = UIText.create(0.86,-0.87,1)
    call SetTextTagPermanent(Name.text,true)
    call SetTextTagPermanent(Line0.text,true)
    call SetTextTagPermanent(Line1.text,true)
    call SetTextTagPermanent(Line2.text,true)
    call SetTextTagPermanent(Hint.text,true)
    call SetTextTagColor(Name.text,255,255,255,255)
    call SetTextTagColor(Hint.text,255,255,255,255)
    call RemoveLocation(start)
    set start = null
    // Prepare projection before the first visible opening.
    call TimerStart(CreateTimer(),1.8,false,function OpenDelayed)
    call DestroyTimer(GetExpiredTimer())
endfunction

private function Init takes nothing returns nothing
    local trigger key = CreateTrigger()
    local trigger chat = CreateTrigger()
    call TriggerRegisterPlayerEvent(key,Player(0),EVENT_PLAYER_ARROW_RIGHT_DOWN)
    call TriggerRegisterPlayerEvent(key,Player(0),EVENT_PLAYER_END_CINEMATIC)
    call TriggerAddAction(key,function Key)
    call TriggerRegisterPlayerChatEvent(chat,Player(0),"-",false)
    call TriggerAddAction(chat,function Chat)
    call TimerStart(CreateTimer(),0.2,false,function Start)
endfunction
endlibrary
