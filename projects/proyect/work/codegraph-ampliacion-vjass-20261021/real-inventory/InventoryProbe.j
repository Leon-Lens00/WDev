scope InventoryProbe initializer Init
    globals
        private integer failures=0
        private integer checks=0
        private integer arrivals=0
    endglobals
    private struct Flight extends array
        static method onFinish takes Missile m returns boolean
            set arrivals=arrivals+1
            return true
        endmethod
        implement MissileStruct
    endstruct
    private function Check takes boolean ok,string label returns nothing
        set checks=checks+1
        if ok then
            call Preload("PASS "+label)
        else
            set failures=failures+1
            call Preload("FAIL "+label)
        endif
    endfunction
    private function Tests takes nothing returns nothing
        local unit u=PlayerHero[0]
        local Inventory inv=Inventory[u]
        local Equipment eq=Equipment[u]
        local InvItem crown=GetInvItem('ckng')
        local integer strength=GetHeroStr(u,true)
        local integer i=0
        local UIButton b
        local Missile m
        call PreloadGenClear()
        call PreloadGenStart()
        call Check(inv.itemCount==8,"eight initial items")
        call Check(Inventory.DisplayCount==1,"inventory show count")
        call Check(Equipment.DisplayCount==1,"equipment show count")
        call Check(GetUnitUserData(u)>0,"hero indexed")
        call UIButton.click(inv.btnPageDown[0].picture,true)
        call Check(GetTriggerButton()==inv.btnPageDown[0],"page down button mapping")
        call UIButton.click(inv.btnPageUp[0].picture,true)
        call Check(GetTriggerButton()==inv.btnPageUp[0],"page up button mapping")
        loop
            exitwhen i==30
            set b=inv.getButton(i)
            call Check(b.texture==GetItemIcon(inv.getItem(i).id),"texture metadata "+I2S(i))
            call UIButton.click(b.picture,true)
            call Check(GetTriggerButton()==b,"button index mapping "+I2S(i))
            set i=i+1
        endloop
        call Check(not eq.equip(crown,0),"level requirement rejects crown")
        call SetHeroLevel(u,3,false)
        set strength=GetHeroStr(u,true)
        call Check(eq.equip(crown,0),"level three equips crown")
        call Check(GetHeroStr(u,true)==strength+5,"strength bonus applied")
        call Check(eq.unequip(crown,0),"crown removed")
        call Check(GetHeroStr(u,true)==strength,"strength bonus restored")
        call inv.show(false,PlayerCamera[0])
        call inv.show(false,PlayerCamera[0])
        call Check(Inventory.DisplayCount==0,"repeated hide is idempotent")
        call inv.show(true,PlayerCamera[0])
        set inv.currentPage=1
        call inv.show(true,PlayerCamera[0])
        call Check(inv.getItem(30)==0 and inv.currentPage==1,"second page accessible")
        set inv.currentPage=0
        call inv.show(true,PlayerCamera[0])
        set m=Missile.createXYZ(GetUnitX(u),GetUnitY(u),80,GetUnitX(u)+500,GetUnitY(u),80)
        call Check(GetUnitUserData(m.dummy)==0,"missile dummy excluded from UnitDex")
        call m.setMovementSpeed(1000)
        call Flight.launch(m)
        call Preload("checks="+I2S(checks)+" failures="+I2S(failures))
        call PreloadGenEnd("Logs\\InventoryProbe-tests.txt")
    endfunction
    private function Final takes nothing returns nothing
        local Inventory inv=Inventory[PlayerHero[0]]
        local UIButton b=inv.getButton(0)
        call PreloadGenClear()
        call PreloadGenStart()
        call Check(arrivals==1,"missile reached endpoint")
        call Check(MissileStats.active==0 and MissileStats.borrowed==0,"missile returned to recycler")
        call Check(MissileStats.alarms==0 and MissileStats.inconsistent==0,"missile diagnostics clean")
        call Preload("checks="+I2S(checks)+" failures="+I2S(failures)+" arrivals="+I2S(arrivals))
        call PreloadGenEnd("Logs\\InventoryProbe-final.txt")
        if GetLocalPlayer()==Player(0) then
            call MultiboardDisplay(MissileStats.board,false)
        endif
        call DestroyTimer(GetExpiredTimer())
    endfunction
    private function PageResult takes nothing returns nothing
        local Inventory inv=Inventory[PlayerHero[0]]
        call PreloadGenClear()
        call PreloadGenStart()
        call Preload("currentPage="+I2S(inv.currentPage)+" selected="+I2S(GetUnitTypeId(GetTriggerUnit())))
        call Check(inv.currentPage==1,"page down through real selection event")
        call Preload("checks="+I2S(checks)+" failures="+I2S(failures))
        call PreloadGenEnd("Logs\\InventoryProbe-page.txt")
        call DestroyTimer(GetExpiredTimer())
    endfunction
    private function SelectPage takes nothing returns nothing
        if GetLocalPlayer()==Player(0) then
            call ClearSelection()
            call SelectUnit(Inventory[PlayerHero[0]].btnPageDown[0].picture,true)
        endif
        call TimerStart(CreateTimer(),1,false,function PageResult)
        call DestroyTimer(GetExpiredTimer())
    endfunction
    private function Dump takes nothing returns nothing
        local unit u = PlayerHero[0]
        local Inventory inv = Inventory[u]
        local Equipment eq = Equipment[u]
        local Camera cam = PlayerCamera[0]
        local UIButton btn = inv.getButton(0)
        local UIPicture pic = inv.background[0]
        call PreloadGenClear()
        call PreloadGenStart()
        call Preload("hero="+I2S(GetUnitTypeId(u))+" userdata="+I2S(GetUnitUserData(u))+" inv="+I2S(inv)+" eq="+I2S(eq)+" count="+I2S(inv.itemCount))
        call Preload("user="+I2S(User.LocalId)+" amount="+I2S(User.AmountPlaying)+" display="+I2S(Inventory.DisplayCount)+" current="+I2S(Inventory.PlayerCurrent[0]))
        call Preload("heroXYZ="+R2S(GetUnitX(u))+","+R2S(GetUnitY(u))+","+R2S(GetTerrainZ(GetUnitX(u),GetUnitY(u))))
        call Preload("delta="+R2S(GetCameraDeltaZ())+" actualEye="+R2S(GetCameraEyePositionX())+","+R2S(GetCameraEyePositionY())+","+R2S(GetCameraEyePositionZ()))
        call Preload("camEye="+R2S(cam.eye.x)+","+R2S(cam.eye.y)+","+R2S(cam.eye.z)+" at="+R2S(cam.at.x)+","+R2S(cam.at.y)+","+R2S(cam.at.z))
        call Preload("camAngles="+R2S(cam.pitch)+","+R2S(cam.yaw)+" btn="+I2S(btn)+" type="+I2S(GetUnitTypeId(btn.picture))+" idx="+I2S(GetUnitUserData(btn.picture)))
        call Preload("btnPos="+R2S(GetUnitX(btn.picture))+","+R2S(GetUnitY(btn.picture))+","+R2S(GetUnitFlyHeight(btn.picture))+" scale="+R2S(btn.scale)+" life="+R2S(GetWidgetLife(btn.picture)))
        call Preload("pic="+I2S(pic)+" type="+I2S(GetUnitTypeId(pic.picture))+" pos="+R2S(GetUnitX(pic.picture))+","+R2S(GetUnitY(pic.picture))+","+R2S(GetUnitFlyHeight(pic.picture)))
        call Preload("first="+I2S(inv.getItem(0).id)+" itemData="+I2S(GetInvItem('ckng'))+" tables="+I2S(InvItem.InventoryTable))
        call Preload("shown="+I2S(UIButton.CountShow)+","+I2S(UIPicture.CountShow)+","+I2S(UIText.CountShow))
        call Preload("texture="+I2S(btn.texture)+" expected="+I2S(GetItemIcon(inv.getItem(0).id))+" local="+I2S(GetPlayerId(User.Local))+" owner="+I2S(GetPlayerId(inv.user.handle)))
        call Preload("firstXY="+R2S(btn.minx)+","+R2S(btn.maxy)+" second="+R2S(inv.getButton(1).minx)+","+R2S(inv.getButton(1).maxy))
        call Preload("applySkin="+R2S(GetUnitFlyHeight(btn.picture)))
        call PreloadGenEnd("Logs\\InventoryProbe.txt")
    endfunction
    private function Cmd takes nothing returns nothing
        call Dump()
    endfunction
    private function Start takes nothing returns nothing
        call Inventory[PlayerHero[0]].show(true,PlayerCamera[0])
        call Equipment[PlayerHero[0]].show(true,PlayerCamera[0])
        call TimerStart(CreateTimer(),2,false,function Dump)
        call TimerStart(CreateTimer(),3,false,function Tests)
        call TimerStart(CreateTimer(),8,false,function Final)
        call TimerStart(CreateTimer(),10,false,function SelectPage)
        call DestroyTimer(GetExpiredTimer())
    endfunction
    private function Init takes nothing returns nothing
        local trigger t=CreateTrigger()
        call TriggerRegisterPlayerChatEvent(t,Player(0),"-dump",true)
        call TriggerAddAction(t,function Cmd)
        call TimerStart(CreateTimer(),2,false,function Start)
    endfunction
endscope
