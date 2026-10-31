// Accumulated X3 charge per RapidPair. Classic 1.27b has no key-up event for
// ability hotkeys, so the demo toggles: press to begin, press to release,
// press again for the stored second pulse. Thresholds: labs/x3-snes frames.csv.
library X3Charge requires X3Buster, RapidFire, GroundCollision, X3Kinematics
struct X3Charge extends array
    static constant integer IDLE = 0
    static constant integer CHARGING = 1
    static constant integer STORED = 2
    // press() results.
    static constant integer REJECTED = 0
    static constant integer BEGAN = 1
    static constant integer FIRED = 2
    static constant integer EMPTY = 3
    static constant integer SECOND = 4
    private static integer array state
    private static unit array actor
    private static real array started
    private static integer array chargeProfile
    private static X3Buster array shot
    private static real array shotBorn
    readonly static integer begins = 0
    readonly static integer charged = 0
    readonly static integer full = 0
    readonly static integer empty = 0
    readonly static integer seconds = 0
    readonly static integer rejected = 0

    // Native frames after pressing: 1/21/81/141/201 -> levels 2/4/6/8/10.
    static method levelAt takes real elapsed returns integer
        local real frames = elapsed*X3Kinematics.FPS+0.0001
        if frames >= 201. then
            return 10
        elseif frames >= 141. then
            return 8
        elseif frames >= 81. then
            return 6
        elseif frames >= 21. then
            return 4
        elseif frames >= 1. then
            return 2
        endif
        return 0
    endmethod
    // Pair slots are recycled; state belongs only to the actor that began it.
    private static method owned takes RapidPair pair returns boolean
        return pair != 0 and state[pair] != IDLE and actor[pair] == pair.actor and GroundCollision.alive(pair.actor)
    endmethod
    static method stateOf takes RapidPair pair returns integer
        if not owned(pair) then
            return IDLE
        endif
        return state[pair]
    endmethod
    static method level takes RapidPair pair returns integer
        if stateOf(pair) != CHARGING then
            return 0
        endif
        return levelAt(X3Buster.now()-started[pair])
    endmethod
    static method cancel takes RapidPair pair returns nothing
        set state[pair] = IDLE
        set actor[pair] = null
        set shot[pair] = 0
    endmethod
    static method begin takes RapidPair pair, integer profile returns boolean
        if pair == 0 or not GroundCollision.alive(pair.actor) or stateOf(pair) != IDLE then
            set rejected = rejected+1
            return false
        endif
        set state[pair] = CHARGING
        set actor[pair] = pair.actor
        set started[pair] = X3Buster.now()
        set chargeProfile[pair] = profile
        set shot[pair] = 0
        set begins = begins+1
        return true
    endmethod
    // Level 10 launches the helix and stores its pulse; level 8 the charged
    // pulse; lower levels discard the charge without firing.
    static method release takes RapidPair pair, real x, real y returns X3Buster
        local integer lvl = level(pair)
        local X3Buster s = 0
        if stateOf(pair) != CHARGING then
            set rejected = rejected+1
            return 0
        endif
        call cancel(pair)
        if lvl >= 10 then
            set s = X3Buster.fireProfile(pair.actor,x,y,2,chargeProfile[pair])
            if s != 0 then
                set state[pair] = STORED
                set actor[pair] = pair.actor
                set shot[pair] = s
                set shotBorn[pair] = s.born
                set full = full+1
            endif
        elseif lvl >= 8 then
            set s = X3Buster.fireProfile(pair.actor,x,y,0,chargeProfile[pair])
            if s != 0 then
                set charged = charged+1
            endif
        else
            set empty = empty+1
            return 0
        endif
        if s == 0 then
            set rejected = rejected+1
        endif
        return s
    endmethod
    // A finished sequence slot may already belong to another cast.
    private static method storedAlive takes RapidPair pair returns boolean
        local X3Buster s = shot[pair]
        return stateOf(pair) == STORED and s != 0 and s.waiting and s.caster == pair.actor and s.born == shotBorn[pair]
    endmethod
    static method second takes RapidPair pair returns boolean
        local X3Buster s = shot[pair]
        if not storedAlive(pair) then
            set rejected = rejected+1
            return false
        endif
        call cancel(pair)
        if s.releasePulse() then
            set seconds = seconds+1
            return true
        endif
        set rejected = rejected+1
        return false
    endmethod
    // Toggle adapter: one hotkey press drives the current state.
    static method press takes RapidPair pair, integer profile, real x, real y returns integer
        if pair == 0 then
            return REJECTED
        endif
        if state[pair] != IDLE and not owned(pair) then
            call cancel(pair)
        endif
        if state[pair] == STORED then
            if storedAlive(pair) then
                if second(pair) then
                    return SECOND
                endif
                return REJECTED
            endif
            call cancel(pair)
        endif
        if state[pair] == CHARGING then
            if release(pair,x,y) != 0 then
                return FIRED
            endif
            if state[pair] == IDLE and levelAt(X3Buster.now()-started[pair]) < 8 then
                return EMPTY
            endif
            return REJECTED
        endif
        if begin(pair,profile) then
            return BEGAN
        endif
        return REJECTED
    endmethod
endstruct
endlibrary
