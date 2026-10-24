// Separate movement authority. Does not use/modify Missile.createEx or its timer.
library GroundMotion requires GroundCollision
struct GroundMotion
    readonly unit body
    readonly boolean artificial = false
    readonly boolean blocked = false
    readonly boolean hasGoal = false
    readonly real goalX
    readonly real goalY
    readonly static integer instantTransitions = 0
    readonly static integer xySteps = 0
    readonly static integer handoffs = 0
    real speed = 350.
    real radius = 24.

    static method create takes unit u returns thistype
        local thistype this = thistype.allocate()
        set body = u
        set artificial = false
        set blocked = false
        set hasGoal = false
        set speed = 350.
        set radius = 24.
        return this
    endmethod

    method destination takes real px, real py returns nothing
        set goalX = px
        set goalY = py
        set hasGoal = true
        set blocked = false
        if not artificial then
            call IssuePointOrder(body,"move",px,py)
        endif
    endmethod

    method enter takes nothing returns nothing
        local integer order = GetUnitCurrentOrder(body)
        if artificial then
            return
        endif
        set artificial = true
        set blocked = false
        call SetUnitPathing(body,false)
        if order == 851986 or order == 851971 or order == 851990 then
            // Initial zero-duration tick, before the first attack animation.
            // Proven in this 1.27b runtime to cancel native locomotion.
            call SetUnitPosition(body,GetUnitX(body),GetUnitY(body))
            set instantTransitions = instantTransitions+1
        endif
    endmethod

    method step takes real dt returns nothing
        local real ax = GetUnitX(body)
        local real ay = GetUnitY(body)
        local real dx
        local real dy
        local real distance
        local real advance
        local real nx
        local real ny
        if not artificial or not hasGoal or not GroundCollision.alive(body) then
            return
        endif
        set dx = goalX-ax
        set dy = goalY-ay
        set distance = SquareRoot(dx*dx+dy*dy)
        if distance <= 2. then
            set hasGoal = false
            set blocked = false
            return
        endif
        set advance = RMinBJ(speed*dt,distance)
        set blocked = GroundCollision.trace(ax,ay,ax+dx*advance/distance,ay+dy*advance/distance,radius,body,GetOwningPlayer(body),false) != 0
        set nx = GroundCollision.x
        set ny = GroundCollision.y
        call SetUnitX(body,nx)
        call SetUnitY(body,ny)
        set xySteps = xySteps+1
        if not blocked and distance <= advance+2. then
            set hasGoal = false
        endif
    endmethod

    method leave takes boolean resume returns nothing
        if artificial then
            set artificial = false
            set blocked = false
            call SetUnitPathing(body,true)
            if resume and hasGoal and GroundCollision.alive(body) then
                call IssuePointOrder(body,"move",goalX,goalY)
                set handoffs = handoffs+1
            endif
        endif
    endmethod

    method destroy takes nothing returns nothing
        call leave(false)
        set body = null
        set hasGoal = false
        call deallocate()
    endmethod
endstruct
endlibrary
