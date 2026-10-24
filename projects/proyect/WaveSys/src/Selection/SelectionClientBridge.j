library SelectionClientBridge requires WavePlayerUtils, MenuClient, PlayerHeroState

    function SelectionCreateClients takes nothing returns nothing
        local integer i = 0
        local WavePlayer u
        local unit hero
        local Client client

        loop
            exitwhen i == WavePlayer.AmountPlaying
            set u = WavePlayer.fromPlaying(i)
            set hero = PlayerHero[u.id]

            if hero != null and GetUnitTypeId(hero) != 0 then
                if Client[hero] == 0 then
                    set client = Client.create(hero)
                else
                    set client = Client[hero]
                endif
            endif

            set i = i + 1
        endloop
    endfunction

    function SelectionShowClients takes nothing returns nothing
        local integer i = 0
        local WavePlayer u
        local unit hero
        local Client client

        loop
            exitwhen i == WavePlayer.AmountPlaying
            set u = WavePlayer.fromPlaying(i)
            set hero = PlayerHero[u.id]

            if hero != null and GetUnitTypeId(hero) != 0 then
                set client = Client[hero]

                if client != 0 and PlayerCamera[u.id] != 0 then
                    call client.show(true, PlayerCamera[u.id])
                endif

                if WavePlayer.Local == u.handle then
                    call SelectUnit(hero, true)
                    call PanCameraToTimed(GetUnitX(hero), GetUnitY(hero), 0)
                endif
            endif

            set i = i + 1
        endloop
    endfunction

endlibrary
