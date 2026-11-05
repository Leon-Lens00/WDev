// Dev Mission v12m: minimal test wave on top of WaveSys. Replaces stage1, which needs PlayerHero[], HeroLives and RestTime.
library TenderSystem
    // Dev Mission has no tender: WaveAI falls back to its registered targets.
    function GetTenderUnit takes nothing returns unit
        return null
    endfunction
endlibrary

library DevWave requires WaveCore, WaveOwnerPolicy, WaveDifficulty, WaveAI, WaveAIProfiles, AllianceConfig
    globals
        private constant real POINT_OFFSET = 600.
        private constant integer AMOUNT = 1
        private unit First = null
        private unit array Targets
        private integer Count = 0
    endglobals

    // Takes the visible character, never its controller: the controller is parked in the corner.
    function DevWave_AddTarget takes unit u returns nothing
        if First == null then
            set First = u
        endif
        set Targets[Count] = u
        set Count = Count + 1
    endfunction

    function DevWave_Start takes nothing returns nothing
        local integer i = 0
        local real x = GetUnitX(First)
        local real y = GetUnitY(First)
        local Wave w
        call InitHostileNeutralAlliances()
        call WaveDifficultySetLevel(1)
        set w = Wave.create(WaveDifficultyOwnerCap(), 15, 0.25, 1, 1)
        call w.addPoint(x - POINT_OFFSET, y)
        call w.addPoint(x + POINT_OFFSET, y)
        call w.addPoint(x, y + POINT_OFFSET)
        call w.addPoint(x, y - POINT_OFFSET)
        loop
            exitwhen i == Count
            call WaveAIRegisterTarget(Targets[i])
            call w.addNearUnit(Targets[i])
            set i = i + 1
        endloop
        call WaveAddSlotExByPlayers(w, 'hpea', AMOUNT, false, WaveDifficultyOwnerCap(), 1, 0, -1, false, AI_PROFILE_MELEE, 0, 0, 1.)
        call WaveAddSlotExByPlayers(w, 'hfoo', AMOUNT, false, WaveDifficultyOwnerCap(), 1, 0, -1, false, AI_PROFILE_MELEE, 0, 0, 1.)
        call w.start()
    endfunction
endlibrary
