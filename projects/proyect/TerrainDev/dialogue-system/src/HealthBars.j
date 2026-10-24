// Classic 1.27b: two projected MDX800 units, native icon registry, actual life.
// Single-player adapter. No Frame API, no camera changes, no local handle creation.
library HealthBars initializer Init requires UserInterface, optional MissileDiagnostics
globals
    private Camera BarCamera = 0
    private unit Hero = null
    private unit Target = null
    private unit HeroBar = null
    private unit EnemyBar = null
    private integer EnemyType = 0
    private integer HeroPercent = -1
    private integer EnemyPercent = -1
    private real PollTime = 0
    private UIText HeroValue
    private UIText EnemyValue
    private boolean Ready = false
    private boolean Visible = true
    private boolean DiagnosticVisible = false
endglobals

private function Percent takes unit u returns integer
    local real maximum
    local real life
    if u == null or GetUnitTypeId(u) == 0 then
        return 0
    endif
    set maximum = GetUnitState(u,UNIT_STATE_MAX_LIFE)
    set life = GetWidgetLife(u)
    if maximum <= 0 or life <= 0.405 then
        return 0
    endif
    return IMaxBJ(1,IMinBJ(100,R2I(life/maximum*100.+0.5)))
endfunction

private function Dummy takes integer rawcode returns unit
    local unit u = CreateUnit(CAMERA_DUMMY_PLAYER,rawcode,0,0,270)
    call UnitAddAbility(u,Interface.DESTROYER_FORM_ID)
    call UnitRemoveAbility(u,Interface.DESTROYER_FORM_ID)
    call SetUnitInvulnerable(u,true)
    call SetUnitBlendTime(u,0.)
    return u
endfunction

private function Place takes unit u, real px, real py returns nothing
    // Measured model-plane fit, shared with dialogue-calibration.js, 1920x1080.
    local VECTOR3 v = BarCamera.win2World((px-961.)/718.18930543,(432.323669-py)/387.73819261,400.)
    call SetUnitX(u,v.x)
    call SetUnitY(u,v.y)
    call SetUnitFlyHeight(u,v.z-UserInterface_GetTerrainZ(v.x,v.y),0)
    call v.destroy()
endfunction

function HealthBarsTarget takes unit u returns boolean
    local integer kind = 0
    local boolean supported = true
    if u != null and GetUnitTypeId(u) == 'otau' then
        set kind = 'hbet'
    elseif u != null and GetUnitTypeId(u) == 'Hpal' then
        set kind = 'hbep'
    elseif u != null then
        // Unregistered unit: hide instead of displaying the wrong native icon.
        set supported = false
        set u = null
    endif
    if kind != EnemyType then
        if EnemyBar != null then
            call RemoveUnit(EnemyBar)
            set EnemyBar = null
        endif
        set EnemyType = kind
        if kind != 0 then
            set EnemyBar = Dummy(kind)
        endif
    endif
    set Target = u
    set EnemyPercent = -1
    return supported
endfunction

function HealthBarsSetVisible takes boolean flag returns nothing
    set Visible = flag
    if Ready then
        call ShowUnit(HeroBar,flag)
        call HeroValue.show(flag,BarCamera)
        if EnemyBar != null then
            call ShowUnit(EnemyBar,flag)
        endif
        call EnemyValue.show(flag and Target != null,BarCamera)
    endif
endfunction

function HealthBarsUpdate takes nothing returns nothing
    local integer p
    local string label
    local boolean enemyShown
    if not Ready then
        return
    endif
    call ShowUnit(HeroBar,Visible and Hero != null and GetUnitTypeId(Hero) != 0)
    call HeroValue.show(Visible and Hero != null and GetUnitTypeId(Hero) != 0,BarCamera)
    if Hero != null and GetUnitTypeId(Hero) != 0 then
        call Place(HeroBar,24.,48.6)
    endif
    set enemyShown = Visible and Target != null and GetUnitTypeId(Target) != 0
    if EnemyBar != null then
        call Place(EnemyBar,1358.4,48.6)
        call ShowUnit(EnemyBar,enemyShown)
    endif
    call EnemyValue.show(enemyShown,BarCamera)
    set PollTime = PollTime+0.01
    if PollTime < 0.05 then
        return
    endif
    set PollTime = 0
    set p = Percent(Hero)
    if p != HeroPercent then
        set HeroPercent = p
        call SetUnitAnimationByIndex(HeroBar,p)
        set label = I2S(p)+"%"
        call HeroValue.setPosition((82.8-I2R(StringLength(label))*4.5-960.)/728.,(420.-159.)/390.)
        call SetTextTagText(HeroValue.text,label,0.017)
    endif
    if EnemyBar != null then
        set p = Percent(Target)
        if p != EnemyPercent then
            set EnemyPercent = p
            call SetUnitAnimationByIndex(EnemyBar,p)
            set label = I2S(p)+"%"
            call EnemyValue.setPosition((1837.2-I2R(StringLength(label))*4.5-960.)/728.,(420.-159.)/390.)
            call SetTextTagText(EnemyValue.text,label,0.017)
        endif
    endif
endfunction

function HealthBarsBind takes Camera cam, unit hero, unit target returns nothing
    set BarCamera = cam
    set Hero = hero
    if not Ready then
        set HeroBar = Dummy('hbhr')
        // UIText has its own measured client fit, as in the dialogue editor.
        set HeroValue = UIText.create((328.-960.)/728.,(420.-88.)/390.,1.)
        set EnemyValue = UIText.create((1824.-960.)/728.,(420.-151.)/390.,1.)
        call SetTextTagPermanent(HeroValue.text,true)
        call SetTextTagPermanent(EnemyValue.text,true)
        call SetTextTagColor(HeroValue.text,199,247,255,255)
        call SetTextTagColor(EnemyValue.text,199,247,255,255)
        set Ready = true
    endif
    call HealthBarsTarget(target)
    set HeroPercent = -1
    call HealthBarsSetVisible(true)
    static if LIBRARY_MissileDiagnostics then
        if GetLocalPlayer() == Player(0) then
            call MultiboardDisplay(MissileStats.board,false)
        endif
    endif
    call HealthBarsUpdate()
endfunction

function HealthBarsDemoLife takes boolean hero, integer percent returns nothing
    local unit u = Target
    if hero then
        set u = Hero
    endif
    if u != null then
        call SetWidgetLife(u,GetUnitState(u,UNIT_STATE_MAX_LIFE)*I2R(IMaxBJ(0,IMinBJ(100,percent)))/100.)
    endif
    set u = null
endfunction

private function Selected takes nothing returns nothing
    local unit u = GetTriggerUnit()
    if IsUnitEnemy(u,Player(0)) then
        call HealthBarsTarget(u)
    endif
    set u = null
endfunction

// Own visual override keeps the existing -misiles toggle useful after hiding at load.
private function Diagnostics takes nothing returns nothing
    set DiagnosticVisible = not DiagnosticVisible
    static if LIBRARY_MissileDiagnostics then
        if GetLocalPlayer() == Player(0) then
            call MultiboardDisplay(MissileStats.board,DiagnosticVisible)
        endif
    endif
endfunction

private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    local trigger chat = CreateTrigger()
    call TriggerRegisterPlayerUnitEvent(t,Player(0),EVENT_PLAYER_UNIT_SELECTED,null)
    call TriggerAddAction(t,function Selected)
    call TriggerRegisterPlayerChatEvent(chat,Player(0),"-misiles",true)
    call TriggerAddAction(chat,function Diagnostics)
endfunction
endlibrary
