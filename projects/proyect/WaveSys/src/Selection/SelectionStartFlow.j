library SelectionStartFlow requires TheEnd, GameState, InitialWaveMultiboard, SelectionClientBridge

    function SelectionStartGameAfterAllSelected takes nothing returns nothing
        call SelectionCreateClients()
        call SelectionShowClients()
        call ShowInitialWaveMultiboard()
        call StartMatchCountdown("Trig_w1_Actions")
    endfunction

endlibrary
