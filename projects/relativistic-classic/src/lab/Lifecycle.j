library LabLifecycle requires LabSupport
    struct LabLife extends Missiles
        method onPeriod takes nothing returns boolean
            set RM_PERIODS[data] = RM_PERIODS[data] + 1
            if RM_CASE == 5 then
                call terminate()
                return false
            elseif RM_CASE == 6 then
                call terminate()
                return true
            endif
            return false
        endmethod
        method onFinish takes nothing returns boolean
            set RM_FINISH[data] = RM_FINISH[data] + 1
            return false
        endmethod
        method onPause takes nothing returns boolean
            set RM_PAUSE[data] = RM_PAUSE[data] + 1
            if RM_CASE == 47 then
                call pause(false)
                return true
            endif
            return false
        endmethod
        method onResume takes nothing returns boolean
            set RM_RESUME[data] = RM_RESUME[data] + 1
            return RM_CASE == 3 and data == 2
        endmethod
        method onRemove takes nothing returns nothing
            set RM_REMOVE[data] = RM_REMOVE[data] + 1
            set RM_DUMMY[data] = dummy
            set RM_X[data] = GetUnitX(dummy)
            set RM_Y[data] = GetUnitY(dummy)
        endmethod
    endstruct

    function RM_LifeStart takes nothing returns nothing
        local LabLife m = LabLife.create(0., 0., 100., 800., 0., 100.)
        call RM_Visual(m, 1)
        set RM_M[1] = m
        set m.speed = 400.
        if RM_CASE == 5 or RM_CASE == 6 then
            set RM_LIMIT = 4
        endif
        if RM_CASE == 1 then
            call m.terminate()
            call m.terminate()
            call RM_Check(not m.allocated, "created-disposed", "terminate before launch must dispose")
            call RM_Equal(RM_REMOVE[1], 1, "created-remove-once")
            set RM_M[2] = LabLife.create(0., 200., 100., 800., 200., 100.)
            call RM_Visual(RM_M[2], 2)
            call RM_Equal(RM_M[2], m, "created-slot-reclaimed")
        else
            if RM_CASE == 2 then
                set m.speed = 800.
            endif
            call m.launch()
            call m.launch()
            if RM_CASE == 3 then
                set RM_M[2] = LabLife.create(0., 200., 100., 800., 200., 100.)
                call RM_Visual(RM_M[2], 2)
                set RM_M[2].speed = 400.
                call RM_M[2].launch()
            endif
        endif
    endfunction

    function RM_LifeStep takes nothing returns nothing
        local Missiles m = RM_M[1]
        if RM_STAGE == 1 then
            if RM_CASE == 3 or RM_CASE == 4 or RM_CASE == 47 then
                call m.pause(true)
                if RM_CASE == 3 then
                    call RM_M[2].pause(true)
                endif
            endif
        elseif RM_STAGE == 2 then
            if RM_CASE == 3 or RM_CASE == 4 then
                set RM_SAVED = m.x
                set RM_OLD_ID = RM_PERIODS[1]
                call RM_Equal(RM_PAUSE[1], 1, "pause-callback-once")
            endif
        elseif RM_STAGE == 3 then
            if RM_CASE == 3 or RM_CASE == 4 then
                call RM_Near(m.x, RM_SAVED, .01, "frozen-position")
                call RM_Equal(RM_PERIODS[1], RM_OLD_ID, "frozen-no-period")
                if RM_CASE == 3 then
                    call m.pause(false)
                    call RM_M[2].pause(false)
                else
                    call m.terminate()
                    call m.terminate()
                    call RM_Equal(RM_REMOVE[1], 1, "frozen-remove-once")
                    // After disposal two creations must have distinct live identities.
                    set RM_M[2] = LabLife.create(0., 200., 100., 800., 200., 100.)
                    call RM_Visual(RM_M[2], 2)
                    call RM_Equal(RM_M[2], m, "frozen-slot-reclaimed")
                    call RM_M[2].launch()
                    set RM_M[3] = LabLife.create(0., 400., 100., 800., 400., 100.)
                    call RM_Visual(RM_M[3], 3)
                    call RM_M[3].launch()
                    call RM_Check(RM_M[2] != RM_M[3], "allocator-distinct", "two simultaneously live missiles")
                endif
            endif
        endif
        if RM_STAGE == RM_LIMIT then
            if RM_CASE == 2 then
                call RM_Equal(RM_FINISH[1], 1, "finish-once")
                call RM_Equal(RM_REMOVE[1], 1, "remove-once")
            elseif RM_CASE == 3 then
                call RM_Equal(RM_RESUME[1], 1, "resume-once")
                call RM_Equal(RM_RESUME[2], 1, "resume-true-once")
                call RM_Equal(RM_REMOVE[2], 1, "resume-true-removes-once")
                call RM_Check(m.x > RM_SAVED, "resumed-motion", "x advanced after resume")
            elseif RM_CASE == 5 or RM_CASE == 6 then
                call RM_Equal(RM_REMOVE[1], 1, "explicit-terminate-remove-once")
                call RM_Equal(RM_PERIODS[1], 1, "no-post-terminate-period")
                call RM_Near(GetUnitX(RM_DUMMY[1]), RM_X[1], .01, "no-post-remove-dummy-movement")
                call RM_Near(m.x, RM_X[1], .01, "no-post-remove-public-x-write")
            elseif RM_CASE == 47 then
                call RM_Equal(RM_PAUSE[1], 1, "reentry-pause-once")
                call RM_Equal(RM_RESUME[1], 1, "reentry-resume-once")
                call RM_Equal(RM_REMOVE[1], 1, "reentry-remove-once")
                set RM_M[2] = LabLife.create(0., 200., 100., 800., 200., 100.)
                call RM_Visual(RM_M[2], 2)
                call RM_M[2].launch()
                set RM_M[3] = LabLife.create(0., 400., 100., 800., 400., 100.)
                call RM_Visual(RM_M[3], 3)
                call RM_M[3].launch()
                call RM_Check(RM_M[2] != RM_M[3], "reentry-allocator-distinct", "resume plus true must not double-release")
            endif
        endif
    endfunction
endlibrary
