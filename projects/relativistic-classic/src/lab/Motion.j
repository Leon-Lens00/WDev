library LabMotion requires LabSupport
    struct LabMotionMissile extends Missiles
        method onPeriod takes nothing returns boolean
            set RM_PERIODS[data] = RM_PERIODS[data] + 1
            if RM_CASE == 13 and RM_PERIODS[data] == 79 then
                // Deterministic reentry: core cached old d=800 before onPeriod.
                // nextX790 + step10 reaches old d but not new target2000.
                call SetUnitX(RM_U, 2000.)
            endif
            if RM_CASE == 11 and RM_PERIODS[data] > 1 then
                call RM_Near(prevY, RM_Y[data], .01, "curve-previous-promotes-current")
                call RM_Near(y, RM_SAVED, .01, "curve-current-promotes-next")
            endif
            if RM_CASE == 11 then
                set RM_SAVED = nextY
            endif
            // Sample before finish/reset through public coordinates, no core storage.
            set RM_X[data] = x
            set RM_Y[data] = y
            set RM_Z[data] = z
            set RM_SPEED[data] = speed
            return false
        endmethod
        method onFinish takes nothing returns boolean
            set RM_FINISH[data] = RM_FINISH[data] + 1
            set RM_TIME[data] = TimerGetElapsed(RM_CLOCK)-RM_T0
            set RM_X[data] = x
            set RM_Y[data] = y
            set RM_Z[data] = z
            if RM_CASE == 12 then
                call RM_Near(x, nextX, .01, "vertical-terminal-x-sample")
                call RM_Near(y, nextY, .01, "vertical-terminal-y-sample")
                call RM_Near(z, nextZ, .01, "vertical-terminal-z-sample")
                call RM_Near(z, impact.z, .01, "vertical-terminal-impact-z")
            endif
            return RM_CASE == 12
        endmethod
        method onRemove takes nothing returns nothing
            set RM_REMOVE[data] = RM_REMOVE[data] + 1
        endmethod
    endstruct

    function RM_MotionStart takes nothing returns nothing
        local LabMotionMissile m
        local real expected
        if RM_CASE == 7 or RM_CASE == 8 then
            set m = LabMotionMissile.create(0., 0., 50., 800., 0., 250.)
        elseif RM_CASE == 12 then
            set m = LabMotionMissile.create(0., 0., 50., 0., 0., 250.)
        else
            set m = LabMotionMissile.create(0., 0., 100., 800., 0., 100.)
        endif
        call RM_Visual(m, 1)
        set RM_M[1] = m
        if RM_CASE == 7 then
            call RM_Near(m.z, m.origin.z, .01, "initial-origin-z")
            call RM_Near(m.prevZ, m.origin.z, .01, "initial-prev-z")
            call RM_Near(m.nextZ, m.origin.z, .01, "initial-next-z")
        endif
        set m.speed = 400.
        if RM_CASE == 8 then
            call RM_Near(m.z, m.origin.z, .01, "speed-does-not-move-current-z")
            call RM_Near(m.nextX, 10., .01, "next-x-speed-period")
            set expected = m.origin.z+(m.impact.z-m.origin.z)*10./m.origin.distance
            call RM_Near(m.nextZ, expected, .02, "next-z-linear-slope")
            set m.arc = 30.
            set expected = Tan(30.*bj_DEGTORAD)*10.*(m.origin.distance-10.)/m.origin.distance+(m.impact.z-m.origin.z)*10./m.origin.distance+m.origin.z
            call RM_Near(m.nextZ, expected, .02, "speed-then-arc-coherent-next")
            set m.speed = 400.
            call RM_Near(m.z, m.origin.z, .01, "arc-speed-does-not-move-current")
            call RM_Near(m.nextZ, expected, .02, "arc-next-equation")
            call RM_Near(m.prevZ, m.origin.z, .01, "setters-preserve-previous-z")
            call RM_Near(m.travel, 0., .001, "setters-do-not-advance-travel")
            set m.arc = 0.
            set m.arc = 30.
            call RM_Near(m.nextZ, expected, .02, "arc-order-independent-next")
            set m.duration = m.origin.distance/400.
            call RM_Near(m.nextZ, expected, .02, "duration-preserves-arc-next")
            call RM_Near(m.z, m.origin.z, .01, "duration-preserves-current-z")
        elseif RM_CASE == 10 then
            set m.arc = 30.
        elseif RM_CASE == 11 then
            set m.curve = 20.
        elseif RM_CASE == 12 then
            set m.duration = 1.
        elseif RM_CASE == 14 then
            // Duration uses the exposed remaining planar distance, not ideal sqrt.
            // Native SquareRoot(640000) is not exactly800 in the real1.27b run.
            set expected = (m.origin.distance-m.travel)/1.
            call RM_Near(m.origin.x, 0., .001, "duration-origin-x")
            call RM_Near(m.impact.x, 800., .001, "duration-impact-x-no-nudge")
            call RM_Near(m.origin.distance, SquareRoot(800.*800.), .01, "duration-native-distance")
            call RM_Record("OBS", "duration-distance-input", "distance=" + R2S(m.origin.distance) + " native-sqrt=" + R2S(SquareRoot(800.*800.)) + " travel=" + R2S(m.travel))
            set m.duration = 1.
            call RM_Near(m.duration, 1., .001, "duration-getter")
            call RM_Near(m.speed, expected, .01, "duration-distance-over-time")
        elseif RM_CASE == 17 then
            // acceleration is velocity increment PER processed callback (world units/tick).
            set m.acceleration = .25
        endif
        if RM_CASE == 13 or RM_CASE == 18 or RM_CASE == 19 or RM_CASE == 33 then
            set RM_U = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), RM_UNIT, 800., 0., 0.)
            call PauseUnit(RM_U, true)
            if RM_CASE != 33 then
                set m.target = RM_U
            endif
            call RM_Check(GetUnitTypeId(RM_U) == RM_UNIT, "target-fixture", "source-declared ntrg")
        endif
        if RM_CASE == 13 then
            set RM_LIMIT = 24
        endif
        call m.launch()
        call RM_Check(m.model == RM_MODEL and m.scale == 1. and m.damage == 17. and m.type == 28 and m.data == 1, "property-roundtrip", "model scale damage type data")
    endfunction

    function RM_MotionStep takes nothing returns nothing
        local Missiles m = RM_M[1]
        local real s
        local real d
        local real expected
        if RM_STAGE == 1 then
            if RM_CASE == 33 then
                call SetUnitY(RM_U, 800.)
                call m.deflectTarget(RM_U)
                call RM_Check(m.target == RM_U, "deflect-target-binding", "public target equals requested unit")
            elseif RM_CASE == 15 then
                call m.deflect(0., 800., 100.)
                call RM_Check(m.target == null and not m.finished, "deflect-reset", "target cleared and flight reopened")
            elseif RM_CASE == 16 then
                set RM_SAVED = m.x
                call m.bounce()
                call RM_Near(m.travel, 0., .001, "bounce-travel-zero")
                call RM_Near(m.origin.x, RM_SAVED, .01, "bounce-origin-current")
            elseif RM_CASE == 18 then
                call KillUnit(RM_U)
            elseif RM_CASE == 19 then
                call RemoveUnit(RM_U)
                set RM_U = null
            endif
        elseif RM_STAGE == 2 then
            if RM_CASE == 9 then
                call RM_Near(m.nextX-m.x, 10., .05, "straight-next-current")
                call RM_Near(m.nextY-m.y, 0., .01, "straight-y")
                call RM_Near(m.x-m.prevX, 10., .05, "straight-current-previous")
            elseif RM_CASE == 10 then
                set s = m.travel
                set d = m.origin.distance
                set expected = Tan(30.*bj_DEGTORAD)*s*(d-s)/d+m.origin.z+(m.impact.z-m.origin.z)*s/d
                call RM_Near(m.nextZ, expected, .1, "arc-parabola")
                call RM_Near(m.arc, 30., .01, "arc-degrees")
            elseif RM_CASE == 11 then
                set s = m.travel
                set d = m.origin.distance
                set expected = 4.*Tan(20.*bj_DEGTORAD)*s*(d-s)/d
                // travel denotes NEXT progress, just as in M10's Z equation.
                call RM_Near(m.nextY, expected, .1, "curve-parabola")
                call RM_Near(m.curve, 20., .01, "curve-degrees")
            elseif RM_CASE == 17 then
                call RM_Near(m.speed, 400.+RM_PERIODS[1]*.25/Missiles_PERIOD, .1, "acceleration-units")
            elseif RM_CASE == 19 then
                call RM_Check(m.target == null, "removed-target-fallback", "removed handle cleared on update")
            endif
        endif
        if RM_STAGE == RM_LIMIT then
            if RM_CASE == 12 then
                call RM_Equal(RM_FINISH[1], 1, "vertical-finish")
                call RM_Equal(RM_REMOVE[1], 1, "vertical-remove-once")
                call RM_Near(RM_Z[1], RM_Ground(0., 0.)+250., 6., "vertical-impact-height")
            elseif RM_CASE == 13 then
                call RM_Equal(RM_FINISH[1], 1, "moving-target-finish-once")
                call RM_Near(RM_X[1], 2000., 20., "homing-current-distance-not-stale-origin")
            elseif RM_CASE == 14 then
                call RM_Near(RM_TIME[1], 1., .075, "duration-seconds-rounded-to-tick")
                call RM_Equal(RM_FINISH[1], 1, "duration-finish-once")
            elseif RM_CASE == 33 then
                call RM_Check(RM_Y[1] > 200., "deflect-target-motion", "motion toward new target Y")
            elseif RM_CASE == 15 then
                call RM_Check(RM_Y[1] > 200., "deflect-new-heading", "public Y advanced toward new impact")
            elseif RM_CASE == 16 then
                call RM_Check(RM_X[1] > RM_SAVED, "bounce-continues", "motion after reset")
            elseif RM_CASE == 18 or RM_CASE == 19 then
                call RM_Check(RM_PERIODS[1] > 1, "target-loss-no-stall", "periods observed after target loss")
            else
                call RM_Check(RM_PERIODS[1] > 1, "motion-periods", "timer processed scenario")
            endif
        endif
    endfunction

    private function CheckCoordinateAngle takes real actual, real expected, string name returns nothing
        local real error = Atan2(Sin(actual-expected), Cos(actual-expected))
        call RM_Check(RAbsBJ(error) <= .001, name, "expected-radians=" + R2S(expected) + " actual=" + R2S(actual) + " wrapped-error=" + R2S(error))
    endfunction

    private function CheckCoordinateLink takes Missiles m, real ox, real oy, real oz, real ix, real iy, real iz returns nothing
        local real dx = ix-ox
        local real dy = iy-oy
        local real square = dx*dx+dy*dy
        local real distance = SquareRoot(square)
        local real angle = Atan2(dy, dx)
        local real slope = (iz-oz)/distance
        call RM_Near(m.origin.x, ox, .01, "origin-x-independent")
        call RM_Near(m.origin.y, oy, .01, "origin-y-independent")
        call RM_Near(m.origin.z, oz, .01, "origin-z-independent")
        call RM_Near(m.impact.x, ix, .01, "impact-x-independent")
        call RM_Near(m.impact.y, iy, .01, "impact-y-independent")
        call RM_Near(m.impact.z, iz, .01, "impact-z-independent")
        call RM_Near(m.origin.square, square, 1., "origin-square-equation")
        call RM_Near(m.impact.square, square, 1., "impact-square-equation")
        call RM_Near(m.origin.distance, distance, .01, "origin-distance-equation")
        call RM_Near(m.impact.distance, distance, .01, "impact-distance-equation")
        call CheckCoordinateAngle(m.origin.angle, angle, "origin-angle-radians-equation")
        call CheckCoordinateAngle(m.impact.angle, angle+bj_PI, "impact-reverse-angle-equation")
        call RM_Near(m.origin.slope, slope, .001, "origin-slope-equation")
        call RM_Near(m.impact.slope, -slope, .001, "impact-slope-equation")
        call RM_Near(m.origin.alpha, Atan(slope)*bj_RADTODEG, .01, "origin-alpha-degrees-equation")
        call RM_Near(m.impact.alpha, -Atan(slope)*bj_RADTODEG, .01, "impact-alpha-degrees-equation")
    endfunction

    function RM_CoordinatesStart takes nothing returns nothing
        local LabMotionMissile m = LabMotionMissile.create(100., 200., 50., 400., 600., 250.)
        local real oz = RM_Ground(100., 200.)+50.
        local real iz = RM_Ground(400., 600.)+250.
        call RM_Visual(m, 1)
        set RM_M[1] = m
        set RM_LIMIT = 4
        call RM_Near(m.x, 100., .01, "initial-current-x-independent")
        call RM_Near(m.y, 200., .01, "initial-current-y-independent")
        call RM_Near(m.z, oz, .01, "initial-current-z-independent")
        call RM_Near(m.prevX, 100., .01, "initial-previous-x-independent")
        call RM_Near(m.prevY, 200., .01, "initial-previous-y-independent")
        call RM_Near(m.prevZ, oz, .01, "initial-previous-z-independent")
        call RM_Near(m.nextX, 100., .01, "initial-next-x-independent")
        call RM_Near(m.nextY, 200., .01, "initial-next-y-independent")
        call RM_Near(m.nextZ, oz, .01, "initial-next-z-independent")
        call RM_Near(m.arc, 0., .001, "initial-arc-zero")
        call RM_Near(m.curve, 0., .001, "initial-curve-zero")
        call RM_Near(m.turn, 0., .001, "readonly-turn-reset")
        call RM_Near(m.travel, 0., .001, "initial-travel-zero")
        call RM_Check(m.allocated and not m.launched and not m.paused and not m.finished, "created-public-flags", "allocated only")
        set m.speed = 500.
        call RM_Near(m.veloc, 12.5, .001, "velocity-speed-times-period")
        call RM_Near(m.nextX, 107.5, .01, "diagonal-next-x-equation")
        call RM_Near(m.nextY, 210., .01, "diagonal-next-y-equation")
        call RM_Near(m.nextZ, oz+(iz-oz)*.025, .02, "diagonal-next-z-equation")
        call RM_Near(m.z, oz, .01, "speed-preserves-current-z-independent")
        set m.speed = 0.
        call m.launch()
        call RM_Check(m.launched and not m.finished and not m.paused, "launched-public-flags", "public launch flags")
    endfunction

    function RM_CoordinatesStep takes nothing returns nothing
        local Missiles m = RM_M[1]
        // Split cold getter assertions across checkpoints, not one huge log thread.
        if RM_STAGE == 1 then
            call CheckCoordinateLink(m, 100., 200., RM_Ground(100., 200.)+50., 400., 600., RM_Ground(400., 600.)+250.)
        elseif RM_STAGE == 2 then
            call m.impact.move(600., 200., 100.)
            call CheckCoordinateLink(m, 100., 200., RM_Ground(100., 200.)+50., 600., 200., RM_Ground(600., 200.)+100.)
        elseif RM_STAGE == 3 then
            call m.origin.move(100., 300., 50.)
            call CheckCoordinateLink(m, 100., 300., RM_Ground(100., 300.)+50., 600., 200., RM_Ground(600., 200.)+100.)
        endif
        if RM_STAGE == RM_LIMIT then
            call RM_Check(RM_PERIODS[1] > 1, "coordinate-fixture-live", "zero-speed missile processed without finishing")
        endif
    endfunction
endlibrary
