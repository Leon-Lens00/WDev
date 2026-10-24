// Integration of TriggerHappy's InventorySys 1.4.1 into the TerrainDev copy.
// Original terrain, placed units, melee initialization and missile sources retained.
scope TerrainInventory initializer Init
    globals
        Camera array PlayerCamera
        unit array PlayerHero
    endglobals

    private function ToggleInventory takes integer pid returns nothing
        local Inventory inv = Inventory[PlayerHero[pid]]
        if inv != 0 then
            call inv.show(not inv.displayed, PlayerCamera[pid])
        endif
    endfunction

    private function ToggleEquipment takes integer pid returns nothing
        local Equipment eq = Equipment[PlayerHero[pid]]
        if eq != 0 then
            call eq.show(not eq.displayed, PlayerCamera[pid])
        endif
    endfunction

    private function Spell takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local integer pid = GetPlayerId(GetOwningPlayer(u))
        if u == PlayerHero[pid] then
            if GetSpellAbilityId() == 'A001' then
                call ToggleEquipment(pid)
            elseif GetSpellAbilityId() == 'A002' then
                call ToggleInventory(pid)
            endif
        endif
        set u = null
    endfunction

    private function Chat takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        local string s = GetEventPlayerChatString()
        if s == "-inventario" then
            call ToggleInventory(pid)
        elseif s == "-equipo" then
            call ToggleEquipment(pid)
        elseif s == "-ui" then
            call ToggleInventory(pid)
            call ToggleEquipment(pid)
        elseif s == "-ayudaui" then
            call DisplayTimedTextToPlayer(GetTriggerPlayer(),0,0,30,"Inventario: -inventario / Equipo: -equipo / Ambos: -ui. Clic izquierdo: seleccionar. Clic derecho: equipar o quitar. Botones laterales: paginas, soltar y vender. Los requisitos del objeto se conservan.")
        endif
    endfunction

    private function CalibrateCameras takes nothing returns nothing
        local integer pid = 0
        loop
            exitwhen pid == 12
            if PlayerHero[pid] != null then
                call PlayerCamera[pid].calibrateHeightForPlayer(Player(pid))
                call PlayerCamera[pid].applyCameraForPlayer(Player(pid),true)
            endif
            set pid = pid+1
        endloop
        call DestroyTimer(GetExpiredTimer())
    endfunction

    private function Start takes nothing returns nothing
        local integer pid = 0
        local unit u
        local Equipment eq
        local Inventory inv
        local real x
        local real y
        loop
            exitwhen pid == 12
            if GetPlayerSlotState(Player(pid)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(pid)) == MAP_CONTROL_USER then
                set x = GetStartLocationX(GetPlayerStartLocation(Player(pid)))
                set y = GetStartLocationY(GetPlayerStartLocation(Player(pid)))
                set PlayerCamera[pid] = Camera.create()
                set u = CreateUnit(Player(pid), 'Hpal', x+220, y, 270)
                set PlayerHero[pid] = u
                set eq = Equipment.create(u)
                set inv = Inventory.create(u)
                call UnitAddAbility(u, 'A001')
                call UnitAddAbility(u, 'A002')
                call UnitAddItemById(u, 'ckng')
                call UnitAddItemById(u, 'ratf')
                call UnitAddItemById(u, 'belv')
                call UnitAddItemById(u, 'bgst')
                call UnitAddItemById(u, 'rde3')
                call UnitAddItemById(u, 'I004')
                call UnitAddItemById(u, 'I009')
                call UnitAddItemById(u, 'I00A')
                call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_EXTRA), Player(pid), bj_ALLIANCE_ALLIED_VISION)
                call SetPlayerAllianceStateBJ(Player(pid), Player(bj_PLAYER_NEUTRAL_EXTRA), bj_ALLIANCE_ALLIED_VISION)
                if GetLocalPlayer() == Player(pid) then
                    call ClearSelection()
                    call SelectUnit(u, true)
                    // The shared camera controller is primed below before calibration.
                endif
                call PlayerCamera[pid].setPosition(GetUnitX(u),GetUnitY(u),GetTerrainZ(GetUnitX(u),GetUnitY(u))+GetUnitFlyHeight(u))
                call PlayerCamera[pid].applyCameraForPlayer(Player(pid),true)
                call DisplayTimedTextToPlayer(Player(pid),0,0,25,"TerrainDev + InventorySys 1.4.1. -ui abre inventario y equipo; -ayudaui muestra controles. Heroe de integracion con ocho objetos de la demo.")
            endif
            set pid = pid+1
        endloop
        call TimerStart(CreateTimer(),0.10,false,function CalibrateCameras)
        call DestroyTimer(GetExpiredTimer())
        set u = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local trigger c = CreateTrigger()
        local integer i = 0
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(t,function Spell)
        loop
            exitwhen i == 12
            call TriggerRegisterPlayerChatEvent(c,Player(i),"-",false)
            set i = i+1
        endloop
        call TriggerAddAction(c,function Chat)
        // Wait until native melee setup and original item definitions have run.
        call TimerStart(CreateTimer(),0.20,false,function Start)
    endfunction
endscope
