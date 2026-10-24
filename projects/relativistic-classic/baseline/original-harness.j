scope RelativisticMissilesTest initializer Init

    private struct TestMissile extends Missiles
        method onFinish takes nothing returns boolean
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\Mortar\\MortarMissile.mdl", x, y))
            call DisplayTextToPlayer(owner, 0., 0., "Relativistic Missiles 2.8: impacto completado.")
            return false
        endmethod
    endstruct

    private function OnChat takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer start = GetPlayerStartLocation(p)
        local real x = GetStartLocationX(start)
        local real y = GetStartLocationY(start)
        local TestMissile missile = TestMissile.create(x, y, 60., x + 700., y, 60.)

        set missile.model = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
        set missile.speed = 600.
        set missile.arc   = 30.
        set missile.owner = p
        call missile.launch()

        call DisplayTextToPlayer(p, 0., 0., "Relativistic Missiles 2.8 Classic: misil lanzado.")
        set p = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger command = CreateTrigger()
        local integer i = 0

        loop
            exitwhen i == bj_MAX_PLAYER_SLOTS
            call TriggerRegisterPlayerChatEvent(command, Player(i), "-rmtest", true)
            set i = i + 1
        endloop
        call TriggerAddAction(command, function OnChat)
        set command = null
    endfunction

endscope

