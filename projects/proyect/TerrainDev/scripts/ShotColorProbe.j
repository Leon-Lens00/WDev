// Laboratory only: never imported into the delivered editable sources.
library ShotColorProbe initializer Init requires RapidFireDemo
globals
    private unit array displayUnit
    private effect array displayEffect
    private texttag array label
    private lightning array ring
    private integer displays = 0
    private integer rings = 0
    private integer checks = 0
    private integer failures = 0
    private string array lines
    private integer stage = 0
    private timer ticker = CreateTimer()
    private real since
    private RapidPair p
    private Missile prior
    private real nextTime
    private integer countBefore
    private string array expected
    private real originalX
    private real originalY
endglobals
private function Check takes boolean value, string message returns nothing
    if value then
        set lines[checks] = "PASS "+message
    else
        set lines[checks] = "FAIL "+message
        set failures = failures+1
    endif
    set checks = checks+1
endfunction
private function Clear takes nothing returns nothing
    loop
        exitwhen displays == 0
        set displays = displays-1
        call DestroyEffect(displayEffect[displays])
        call RemoveUnit(displayUnit[displays])
        call DestroyTextTag(label[displays])
        set displayEffect[displays] = null
        set displayUnit[displays] = null
        set label[displays] = null
    endloop
    loop
        exitwhen rings == 0
        set rings = rings-1
        call DestroyLightning(ring[rings])
        set ring[rings] = null
    endloop
endfunction
private function Display takes real x, real y, playercolor color, real scale, string text, boolean marker returns nothing
    local integer i = 0
    local real a
    local real b
    local real z = GroundCollision.height(x,y)+70.
    set displayUnit[displays] = CreateUnit(Player(0),'dumi',x,y,0.)
    call SetUnitX(displayUnit[displays],x)
    call SetUnitY(displayUnit[displays],y)
    call SetUnitFlyHeight(displayUnit[displays],70.,0.)
    call SetUnitScale(displayUnit[displays],scale,scale,scale)
    set displayEffect[displays] = AddSpecialEffectTarget(RapidBolt.modelForColor(color),displayUnit[displays],"origin")
    set label[displays] = CreateTextTag()
    call SetTextTagText(label[displays],text,0.022)
    call SetTextTagPos(label[displays],x-55.,y+48.,75.)
    set displays = displays+1
    if marker then
        loop
            exitwhen i == 24
            set a = I2R(i)*bj_PI/12.
            set b = I2R(i+1)*bj_PI/12.
            set ring[rings] = AddLightningEx("DRAL",false,x+16.*Cos(a),y+16.*Sin(a),z,x+16.*Cos(b),y+16.*Sin(b),z)
            call SetLightningColor(ring[rings],1.,1.,1.,0.8)
            set rings = rings+1
            set i = i+1
        endloop
    endif
endfunction
private function Camera takes nothing returns nothing
    call SetCameraTargetController(null,0.,0.,false)
    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,1650.,0.)
    call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK,295.,0.)
    call PanCameraToTimed(-4310.,3040.,0.)
    call FogEnable(false)
    call FogMaskEnable(false)
    call SetTimeOfDay(12.)
    call SuspendTimeOfDay(true)
    call MultiboardDisplay(MissileStats.board,false)
    call ClearTextMessages()
endfunction
private function Calibrate takes nothing returns nothing
    call Clear()
    call Camera()
    call Display(-4400.,3260.,PLAYER_COLOR_CYAN,1.,"1.00 x",true)
    call Display(-4400.,3040.,PLAYER_COLOR_CYAN,1.5,"1.50 x",true)
    call Display(-4400.,2820.,PLAYER_COLOR_CYAN,2.7434842,"2.74 x",true)
    call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"CALIBRACION: circulo radio16 en el origen/punta; estela hacia atras. Grosor del cuerpo, halo y Death son distintos.")
endfunction
private function Palette takes nothing returns nothing
    local integer i = 0
    call Clear()
    call Camera()
    loop
        exitwhen i == 12
        call Display(-4670.+I2R(ModuloInteger(i,3))*340.,3340.-I2R(i/3)*190.,ConvertPlayerColor(i),RapidBolt.VISUAL_SCALE,I2S(i),false)
        set i = i+1
    endloop
    call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"PALETA CLASSIC: 0 rojo,1 azul,2 cian,3 purpura,4 amarillo,5 naranja,6 verde,7 rosa,8 gris,9 azul claro,10 aqua,11 marron.")
endfunction
private function Save takes nothing returns nothing
    local integer i = 0
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("COLOR @RUN@ COMPLETE")
    loop
        exitwhen i == checks
        call Preload(lines[i])
        set i = i+1
    endloop
    call Preload("checks="+I2S(checks)+" failures="+I2S(failures)+" live="+I2S(RapidBolt.live)+" created="+I2S(MissileStats.created)+" retired="+I2S(MissileStats.retired)+" scale="+R2S(RapidBolt.VISUAL_SCALE))
    call PreloadGenEnd("Logs\\TerrainDev-@RUN@-colors.txt")
endfunction
private function Tick takes nothing returns nothing
    local real elapsed = RapidPair.now()-since
    if stage == 1 and elapsed >= 0.25 then
        call Check(RapidBolt.live==0,"all twelve direct shots retired")
        call SetPlayerColor(Player(0),PLAYER_COLOR_ORANGE)
        set prior = RapidBolt.shoot(p.actor,-3800.,3024.)
        call Check(prior.model==expected[5],"owner color differs from player slot")
        call prior.destroy()
        call p.setColor(PLAYER_COLOR_RED)
        call p.cast(-3800.,3024.)
        set prior = p.lastMissile
        call Check(prior.model==expected[0],"explicit red override wins over orange owner")
        set since = RapidPair.now()
        set stage = 2
    elseif stage == 2 and elapsed >= 0.125 then
        set nextTime = p.nextShot
        set countBefore = RapidPair.emitted
        call p.setColor(PLAYER_COLOR_PINK)
        call p.cast(-3800.,3024.)
        call Check(p.pending==6 and p.nextShot==nextTime and RapidPair.emitted==countBefore,"colored recast preserves next shot and replenishes six")
        set stage = 3
    elseif stage == 3 and elapsed >= 0.28125 then
        call Check(p.lastMissile.model==expected[7],"next recast shot uses updated override")
        call Check(prior.allocated and prior.model==expected[0],"flying shot keeps previous red color")
        call SetPlayerColor(Player(0),PLAYER_COLOR_YELLOW)
        call p.clearColor()
        call p.cast(-3800.,3024.)
        set since = RapidPair.now()
        set stage = 4
    elseif stage == 4 and elapsed >= 0.28125 then
        call Check(p.lastMissile.model==expected[4],"cleared override follows changed owner color")
        call p.setColor(PLAYER_COLOR_GREEN)
        call p.cast(-3800.,3024.)
        set since = RapidPair.now()
        set stage = 5
    elseif stage == 5 and elapsed >= 0.28125 then
        call Check(p.lastMissile.model==expected[6],"explicit team color overrides player color")
        call SetPlayerColor(Player(1),PLAYER_COLOR_PURPLE)
        call SetUnitOwner(p.actor,Player(1),true)
        call p.clearColor()
        call p.cast(-3800.,3024.)
        set since = RapidPair.now()
        set stage = 6
    elseif stage == 6 and elapsed >= 0.28125 then
        call Check(p.lastMissile.model==expected[3],"changed owner selects its current color")
        call Check(RAbsBJ(p.lastMissile.scale-RapidBolt.VISUAL_SCALE)<0.0001,"scale applied on reused projectile dummy")
        call Check(RapidPair.minInterval>=0.249,"color changes do not shorten firing interval")
        call SetUnitOwner(p.actor,Player(0),true)
        call SetPlayerColor(Player(0),PLAYER_COLOR_RED)
        call SetPlayerColor(Player(1),PLAYER_COLOR_BLUE)
        call p.clearColor()
        set since = RapidPair.now()
        set stage = 7
    elseif stage == 7 and elapsed >= 4. then
        call Check(not p.firing and p.pending==0 and RapidBolt.live==0,"burst finishes with zero pending/live")
        call Check(MissileStats.created==MissileStats.retired,"all real missile instances retired")
        // Do not leave a collidable demo actor at the next laboratory's spawn.
        call SetUnitPosition(p.actor,originalX,originalY)
        call IssueImmediateOrder(p.actor,"stop")
        call Save()
        call PauseTimer(ticker)
        call ClearTextMessages()
        call DisplayTimedTextToPlayer(Player(0),0.,0.,60.,"COLOR COMPLETE: "+I2S(checks)+" checks / "+I2S(failures)+" failures. -palette / -calibrate")
    endif
endfunction
private function Tests takes nothing returns nothing
    local integer i = 0
    local Missile m
    if stage != 0 then
        return
    endif
    set p = RapidDemo.pair
    set originalX = GetUnitX(p.actor)
    set originalY = GetUnitY(p.actor)
    call SetUnitPosition(p.actor,-4700.,3024.)
    call IssueImmediateOrder(p.actor,"stop")
    loop
        exitwhen i == 12
        call SetPlayerColor(Player(0),ConvertPlayerColor(i))
        set m = RapidBolt.shoot(p.actor,-3800.,3024.)
        call Check(m.model==expected[i],"model for owner color "+I2S(i))
        call Check(RAbsBJ(m.scale-RapidBolt.VISUAL_SCALE)<0.0001,"scale for owner color "+I2S(i))
        call m.destroy()
        set i = i+1
    endloop
    call Check(PLAYER_COLOR_RED==null and RapidBolt.modelForColor(PLAYER_COLOR_RED)==expected[0],"Classic red enum0 remains a valid explicit color")
    call Check(RapidBolt.modelForColor(ConvertPlayerColor(12))==expected[8],"neutral color fallback gray")
    call Check(RapidBolt.HIT_RADIUS==16.,"collision radius unchanged")
    set stage = 1
    set since = RapidPair.now()
    call TimerStart(ticker,1./32.,true,function Tick)
endfunction
private function Init takes nothing returns nothing
    local trigger a = CreateTrigger()
    local trigger b = CreateTrigger()
    local trigger c = CreateTrigger()
    set expected[0] = "ShotsTeam\\Shot_00_Red.mdx"
    set expected[1] = "ShotsTeam\\Shot_01_Blue.mdx"
    set expected[2] = "ShotsTeam\\Shot_02_Cyan.mdx"
    set expected[3] = "ShotsTeam\\Shot_03_Purple.mdx"
    set expected[4] = "ShotsTeam\\Shot_04_Yellow.mdx"
    set expected[5] = "ShotsTeam\\Shot_05_Orange.mdx"
    set expected[6] = "ShotsTeam\\Shot_06_Green.mdx"
    set expected[7] = "ShotsTeam\\Shot_07_Pink.mdx"
    set expected[8] = "ShotsTeam\\Shot_08_LightGray.mdx"
    set expected[9] = "ShotsTeam\\Shot_09_LightBlue.mdx"
    set expected[10] = "ShotsTeam\\Shot_10_Aqua.mdx"
    set expected[11] = "ShotsTeam\\Shot_11_Brown.mdx"
    call TriggerRegisterPlayerChatEvent(a,Player(0),"-calibrate",true)
    call TriggerAddAction(a,function Calibrate)
    call TriggerRegisterPlayerChatEvent(b,Player(0),"-palette",true)
    call TriggerAddAction(b,function Palette)
    call TriggerRegisterPlayerChatEvent(c,Player(0),"-testcolors",true)
    call TriggerAddAction(c,function Tests)
    set a = null
    set b = null
    set c = null
endfunction
endlibrary
