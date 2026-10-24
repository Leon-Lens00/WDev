library WaveOwnerConfig requires WavePlayerUtils

    function InitDefaultWaveOwnerResearches takes nothing returns nothing
        local integer i = 8
        local integer researchedLevel = WavePlayer.AmountPlaying

        loop
            exitwhen i > 12
            call SetPlayerTechResearched(Player(i), 'Rhar', researchedLevel)
            set i = i + 1
        endloop
    endfunction

endlibrary
