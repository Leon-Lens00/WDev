library LabLoad requires LabSupport
    globals
        private integer population = 0
        private integer wave = 0
        private integer created = 0
    endglobals
    struct LabLoadMissile extends Missiles
        method onPeriod takes nothing returns boolean
            set RM_PERIODS[data] = RM_PERIODS[data] + 1
            set RM_SPEED[data] = speed
            return false
        endmethod
        method onFinish takes nothing returns boolean
            set RM_FINISH[data] = RM_FINISH[data] + 1
            set RM_TIME[data] = TimerGetElapsed(RM_CLOCK)-RM_T0
            set RM_X[data] = x
            return false
        endmethod
        method onRemove takes nothing returns nothing
            set RM_REMOVE[data] = RM_REMOVE[data] + 1
        endmethod
    endstruct

    private function PrepareBatch takes nothing returns nothing
        local integer stop = IMinBJ(created+25, population)
        local LabLoadMissile m
        // Bounded setup avoids one 300-create thread exhausting classic op budget.
        loop
            exitwhen created >= stop
            set created = created + 1
            set m = LabLoadMissile.create(0., 0., 100., 800., 0., 100.)
            call RM_Visual(m, created)
            set m.speed = 0.
            set RM_M[created] = m
            call m.launch()
        endloop
    endfunction

    private function ArmWave takes nothing returns nothing
        local integer i = 1
        set RM_T0 = TimerGetElapsed(RM_CLOCK)
        loop
            exitwhen i > population
            set RM_PERIODS[i] = 0
            set RM_M[i].speed = 400.
            if wave == 1 then
                set RM_M[i].acceleration = .05
            endif
            set i = i + 1
        endloop
    endfunction

    function RM_LoadStart takes nothing returns nothing
        set RM_LIMIT = 44
        set wave = 0
        set created = 0
        if RM_CASE == 30 then
            set population = 150
        elseif RM_CASE == 31 then
            set population = 151
        elseif RM_CASE == 32 then
            set population = 300
        else
            set population = 100
        endif
    endfunction

    function RM_LoadStep takes nothing returns nothing
        local integer i = 1
        local integer finished = 0
        local integer removed = 0
        local integer badTime = 0
        local integer badPosition = 0
        local integer badAcceleration = 0
        local integer badPeriods = 0
        local integer minPeriods = 100000
        local integer maxPeriods = 0
        local real minTime = 1000.
        local real maxTime = 0.
        local real dilation = RMaxBJ(1., population/Missiles_SWEET_SPOT)
        local real tolerance = .025*(dilation+2.)
        local integer phase = RM_STAGE-wave*22
        if phase <= 12 then
            call PrepareBatch()
            if phase == 12 then
                call ArmWave()
            endif
        endif
        if phase == 22 then
            loop
                exitwhen i > population
                set finished = finished + RM_FINISH[i]
                set removed = removed + RM_REMOVE[i]
                if RM_FINISH[i] != 1 or RM_REMOVE[i] != 1 then
                    set badPeriods = badPeriods + 1
                endif
                if wave == 0 and RAbsBJ(RM_TIME[i]-2.) > tolerance then
                    set badTime = badTime + 1
                endif
                if RAbsBJ(RM_X[i]-800.) > 10.*dilation+1. then
                    set badPosition = badPosition + 1
                endif
                // onPeriod precedes orientation's velocity increment, hence n-1.
                if wave == 1 and RAbsBJ(RM_SPEED[i]-(400.+(RM_PERIODS[i]-1)*.05/Missiles_PERIOD)) > .1 then
                    set badAcceleration = badAcceleration + 1
                endif
                set minTime = RMinBJ(minTime, RM_TIME[i])
                set maxTime = RMaxBJ(maxTime, RM_TIME[i])
                set minPeriods = IMinBJ(minPeriods, RM_PERIODS[i])
                set maxPeriods = IMaxBJ(maxPeriods, RM_PERIODS[i])
                set i = i + 1
            endloop
            call RM_Equal(finished, population, "wave-" + I2S(wave) + "-finish-count")
            call RM_Equal(removed, population, "wave-" + I2S(wave) + "-remove-count")
            call RM_Equal(badPeriods, 0, "wave-" + I2S(wave) + "-per-instance-once")
            call RM_Record("OBS", "wave-" + I2S(wave) + "-elapsed-range", "min=" + R2S(minTime) + " max=" + R2S(maxTime) + " nominal-period=.025 population=" + I2S(population))
            call RM_Record("OBS", "wave-" + I2S(wave) + "-callback-range", "min=" + I2S(minPeriods) + " max=" + I2S(maxPeriods) + " normalized-budget=" + R2S(dilation))
            if wave == 0 then
                call RM_Equal(badTime, 0, "equal-duration-contract")
                call RM_Equal(badPosition, 0, "equal-impact-position-contract")
                // New wave only after old scheduler drained, not inside a callback.
                call RM_Reset()
                set RM_LIMIT = 44
                set wave = 1
                set created = 0
            else
                call RM_Equal(badAcceleration, 0, "acceleration-per-processed-callback-contract")
                call RM_Record("OBS", "acceleration-load-limit", ".05 world units per processed velocity tick; not elapsed-time acceleration; physical time may differ")
            endif
        endif
        if RM_CASE == 34 and RM_STAGE == 44 then
            call RM_Record("OBS", "repetition", "100 missiles repeated twice; subsequent runner drain/idle checkpoint required")
        endif
    endfunction
endlibrary
