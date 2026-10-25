library GameState

    globals
        integer array ManaPassiveUnit

        multiboard SwlsMultiboard
        sound SwlsSound
        trigger SwlsWaveStartTrigger
        integer SwlsSoundWaveVolume
        integer TargetWave
        sound error
        sound error_Neg
        string Message
        // TargetWave, WaveTgg e isWavez: solo RestTime los escribe (aqui solo el valor inicial); el resto los lee.
        string WaveTgg
        boolean array isTender[11]
        boolean isWavez = false
    endglobals

    function GameStateInitDefaults takes nothing returns nothing
        set TargetWave = 1
        set SwlsWaveStartTrigger = null
        set SwlsSoundWaveVolume = 80
    endfunction

endlibrary
