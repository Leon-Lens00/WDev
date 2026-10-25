library TheEnd requires RestTimeAudio, RestTimeCountdown, RestTimeEndFlow

    function CloseTenderForActivePlayers takes nothing returns nothing
        call RestTimeCloseTenderForActivePlayers()
    endfunction

    // Inicio de partida: RestTime guarda la funcion de la primera oleada y abre la cuenta atras inicial.
    function StartMatchCountdown takes string firstWaveFunc returns nothing
        set WaveTgg = firstWaveFunc
        call RestTimeBeginCountdown(REST_INITIAL_WAVE_COUNTDOWN, REST_PHASE_INITIAL)
    endfunction

    function StartPurchaseCountdown takes nothing returns nothing
        call RestTimeBeginCountdown(REST_PURCHASE_COUNTDOWN, REST_PHASE_PURCHASE)
    endfunction

endlibrary
