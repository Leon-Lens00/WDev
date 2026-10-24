// Local mathematical port of observed X3 USA / Zero Project 4.1 motion.
// Oracle: labs/x3-snes; no ROM code or ROM assets are imported into this map.
library X3Kinematics
struct X3Kinematics extends array
    static constant integer ORIGINAL = 1
    static constant integer ZERO_PROJECT = 2
    static constant real FPS = 60.0988062658451
    static constant real SCALE = 2.
    private static real array wave

    static method formation takes integer profile returns real
        if profile == ZERO_PROJECT then
            return 8./FPS
        endif
        return 18./FPS
    endmethod
    static method pulseDelay takes integer profile returns real
        // Demonstration timing: observed birth of the second body relative to
        // the first carrier, not simulation of charging a controller button.
        if profile == ZERO_PROJECT then
            return 13./FPS
        endif
        return 17./FPS
    endmethod
    static method helixPixel takes integer n returns real
        local real k
        if n <= 15 then
            return 0.5*n+(1./32.)*n*(n+1)*0.5
        elseif n <= 32 then
            set k = I2R(n-15)
            return 11.25+0.96875*k+0.25*k*(k+1.)*0.5
        endif
        return 65.96875+5.25*I2R(n-32)
    endmethod
    private static method xPixel takes integer profile, integer form, integer n returns real
        local real initial = -6.
        local real accel = 96./256.
        local integer cap
        local real k
        if form == 4 then
            if profile == ZERO_PROJECT then
                // ROM stores 10, but clamps to 8 BEFORE its first displacement.
                return 8.*n
            endif
            set initial = 0.
            set accel = 24./256.
        elseif form == 5 or form == 8 then
            if profile == ZERO_PROJECT then
                set initial = 1.
                set accel = 48./256.
            else
                set initial = -8.
                set accel = 127./256.
            endif
        elseif profile == ZERO_PROJECT then
            set initial = -3.
        endif
        set cap = R2I((8.-initial)/accel)
        if I2R(cap)*accel < 8.-initial then
            set cap = cap+1
        endif
        if n <= cap then
            set k = I2R(n)
            return initial*k+accel*k*(k+1.)*0.5
        endif
        set k = I2R(cap)
        // The native limit precedes acceleration: the stable step is 8+a.
        return initial*k+accel*k*(k+1.)*0.5+(8.+accel)*I2R(n-cap)
    endmethod
    private static method yPixel takes integer profile, integer form, integer n returns real
        local real vy = 0.75
        local real ay = 0.
        local real k = I2R(n)
        if form == 4 then
            return 0.
        elseif form == 5 or form == 8 then
            set vy = 1.5
            if profile == ZERO_PROJECT then
                set vy = 5.
                set ay = 96./256.
            endif
        elseif profile == ZERO_PROJECT then
            set vy = 7.
            set ay = 112./256.
        endif
        if form == 7 or form == 8 then
            set vy = -vy
            set ay = -ay
        endif
        return -vy*k+ay*k*(k+1.)*0.5
    endmethod
    static method forward takes integer profile, integer form, real age returns real
        local real frame = RMaxBJ(0.,age*FPS)
        local integer n = R2I(frame)
        local real f = frame-I2R(n)
        local real a
        if form == 1 or form == 2 or form == 9 then
            set a = helixPixel(n)
            return SCALE*(a+(helixPixel(n+1)-a)*f)
        elseif form == 0 or form == 3 then
            // Four native steps of growth; step 5 first displaces by 8 pixels.
            return SCALE*8.*RMaxBJ(0.,frame-4.)
        endif
        set a = xPixel(profile,form,n)
        return SCALE*(a+(xPixel(profile,form,n+1)-a)*f)
    endmethod
    static method orbitForward takes integer form, real age returns real
        local real frame = RMaxBJ(0.,age*FPS)
        local integer n = R2I(frame)
        local real f = frame-I2R(n)
        local real offset = 4.
        local real a = I2R(R2I(0.5+helixPixel(n)))-0.5
        local real b = I2R(R2I(0.5+helixPixel(n+1)))-0.5
        if form == 2 then
            set offset = 8.
        elseif form == 9 then
            set offset = 0.
        endif
        return SCALE*(a+(b-a)*f+offset)
    endmethod
    private static method orbitY takes integer form, integer n returns real
        local integer phase = 0
        local integer i = 1
        local real y = -6.
        set n = ModuloInteger(n,16)
        if form == 2 then
            set phase = 4
            set y = 0.
        elseif form == 9 then
            set phase = 8
            set y = 7.
        endif
        loop
            exitwhen i > n
            set y = y-wave[ModuloInteger(phase+i,16)]
            set i = i+1
        endloop
        return y
    endmethod
    static method side takes integer profile, integer form, real age returns real
        local real frame = RMaxBJ(0.,age*FPS)
        local integer n = R2I(frame)
        local real f = frame-I2R(n)
        local real a
        if form == 1 or form == 2 or form == 9 then
            set a = orbitY(form,n)
            return -SCALE*(a+(orbitY(form,n+1)-a)*f)
        endif
        set a = yPixel(profile,form,n)
        // SNES screen-down is the opposite of Warcraft's left-perpendicular.
        return -SCALE*(a+(yPixel(profile,form,n+1)-a)*f)
    endmethod
    private static method onInit takes nothing returns nothing
        set wave[0] = -1.
        set wave[1] = -2.
        set wave[2] = -6.
        set wave[3] = -3.
        set wave[4] = -3.
        set wave[5] = -6.
        set wave[6] = -2.
        set wave[7] = -1.
        set wave[8] = 1.
        set wave[9] = 2.
        set wave[10] = 6.
        set wave[11] = 3.
        set wave[12] = 3.
        set wave[13] = 6.
        set wave[14] = 2.
        set wave[15] = 1.
    endmethod
endstruct
endlibrary
