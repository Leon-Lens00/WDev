//TESH.scrollpos=4
//TESH.alwaysfold=0
scope Show

    globals 
        private constant integer MAX = 10
        private unit u
        private constant integer W   = 200
    endglobals
    
    private module I 
        private static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()
            call TriggerRegisterPlayerEvent(t, Player(0),EVENT_PLAYER_END_CINEMATIC)
            call TriggerAddCondition(t, Condition(function thistype.revive))
            call init()
            call PanCameraTo(0,0)
        endmethod
    endmodule
    
    private struct X extends array
    
        real x
        real y
        integer i
        integer t
        player p
        
        
        private static method init takes nothing returns nothing
            local integer i = 0
            set u = CreateUnit(Player(0), 'Ulic', 0,0,0)
            call SetHeroLevel(u,10,false)
            call CreateFogModifierRectBJ( true, Player(0), FOG_OF_WAR_VISIBLE, WorldBounds.world)
            loop 
                exitwhen i == MAX
                call CreateUnit(Player(1),'hfoo',1000,1000,0)
                set i = i + 1
            endloop
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0,0,20, "Press ESC to spawn footmans")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0,0,20, "---------------------------")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0,0,20, "-----------HINT------------")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0,0,20, "Make use of Missile API to extend")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0,0,20, "Frozen Orb projectile behaviour!!")
        endmethod
        
        private static method revive takes nothing returns boolean
            local integer i = 0
            loop 
                exitwhen i == MAX
                call CreateUnit(Player(1),'hfoo',1000,1000,0)
                set i = i + 1
            endloop
            return false
        endmethod
            
        implement I
        
    endstruct
endscope