// Laboratory only: never imported into TerrainDev.w3x.
library TerrainDevProbe initializer Init requires Missile, Table, TimerUtils, WorldBounds, DummyCaster, IsDestructableTree
globals
    private integer created = 0
    private integer removed = 0
    private integer finished = 0
    private integer collided = 0
    private integer cancelled = 0
    private integer failed = 0
    private integer callbacks = 0
    private integer timerChecks = 0
    private integer reused = 0
    private integer array mode
    private integer array age
    private unit array firstDummy
    private unit array trackedDummy
    private unit hitTarget
    private unit homeTarget
    private real sx
    private real sy
endglobals

private struct Flight extends array
    static method onFinish takes Missile m returns boolean
        set finished = finished + 1
        return true
    endmethod
    static method onCollide takes Missile m, unit hit returns boolean
        if mode[m] == 1 and hit == hitTarget then
            set collided = collided + 1
            return true
        endif
        return false
    endmethod
    static method onPeriod takes Missile m returns boolean
        set callbacks = callbacks + 1
        set age[m] = age[m] + 1
        if mode[m] == 3 and age[m] == 8 then
            set cancelled = cancelled + 1
            call m.destroy()
        endif
        return false
    endmethod
    static method onRemove takes Missile m returns boolean
        set removed = removed + 1
        return false
    endmethod
    implement MissileStruct
endstruct

private function Spawn takes integer kind, integer count returns nothing
    local integer i = 0
    local integer j
    local real y = sy + I2R(kind)*300.
    local Missile m
    loop
        exitwhen i == count
        set m = Missile.createXYZ(sx, y, 50., sx+1000., y, 50.)
        set created = created + 1
        set trackedDummy[created] = m.dummy
        set mode[m] = kind
        set age[m] = 0
        set m.model = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
        call m.setMovementSpeed(1000.)
        set m.owner = Player(0)
        if kind == 0 then
            if i < 10 then
                set m.arc = 0.3
            elseif i < 20 then
                set m.curve = 0.3
            endif
            if created <= 30 then
                set firstDummy[i] = m.dummy
            else
                set j = 0
                loop
                    exitwhen j == 30
                    if firstDummy[j] == m.dummy then
                        set reused = reused + 1
                        exitwhen true
                    endif
                    set j = j+1
                endloop
            endif
        elseif kind == 1 then
            set m.collision = 80.
        elseif kind == 2 then
            set m.target = homeTarget
            set m.turn = 0.2
        endif
        call Flight.launch(m)
        set i = i+1
    endloop
endfunction

private function Finish takes nothing returns nothing
    local group g = CreateGroup()
    local unit u
    local integer dummyCount = 0
    local integer pooled = 0
    local integer casterCount = 0
    local integer overflow = 0
    local integer liveUnpooled = 0
    local integer i = 1
    local Table seen = Table.create()
    // Locust units are not covered by GroupEnumUnitsInRect. Observe the handles
    // actually returned by Missile instead, deduplicating reused handles.
    loop
        exitwhen i > created
        set u = trackedDummy[i]
        if not seen.boolean[GetHandleId(u)] then
            set seen.boolean[GetHandleId(u)] = true
            set dummyCount = dummyCount+1
            if GetUnitUserData(u) == -1 and UnitAlive(u) then
                set pooled = pooled+1
            elseif not UnitAlive(u) then
                set overflow = overflow+1
            else
                set liveUnpooled = liveUnpooled+1
            endif
        endif
        set i = i+1
    endloop
    call seen.destroy()
    // The caster uses Locust too; its inherited building type is enumerable.
    call GroupEnumUnitsInRect(g, WorldBounds.world, null)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g,u)
        if GetUnitTypeId(u) == 'dcst' then
            set casterCount = casterCount+1
        endif
    endloop
    call DestroyGroup(g)
    if created != 90 or removed != 90 or finished != 70 or collided != 10 or cancelled != 10 then
        set failed = failed+1
    endif
    // Angle buckets have a fixed capacity and legitimately discard surplus.
    // Require observed reuse, no live unpooled leftovers, and full accounting.
    if pooled < 1 or reused < 1 or pooled+overflow != dummyCount or liveUnpooled != 0 or casterCount != 1 or timerChecks != 1 or callbacks == 0 then
        set failed = failed+1
    endif
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("TERRAINDEV RUN @RUN@ COMPLETE")
    call Preload("created="+I2S(created)+" removed="+I2S(removed)+" finished="+I2S(finished)+" collided="+I2S(collided)+" cancelled="+I2S(cancelled))
    call Preload("dummies="+I2S(dummyCount)+" pooled="+I2S(pooled)+" overflow="+I2S(overflow)+" liveUnpooled="+I2S(liveUnpooled)+" casters="+I2S(casterCount)+" reused="+I2S(reused)+" timerChecks="+I2S(timerChecks)+" callbacks="+I2S(callbacks))
    call Preload("failures="+I2S(failed))
    call PreloadGenEnd("Logs\\TerrainDev-@RUN@-result.txt")
    call BJDebugMsg("TerrainDev integration: failures="+I2S(failed)+" removed="+I2S(removed)+"/90")
    call DestroyTimer(GetExpiredTimer())
    set u = null
    set g = null
endfunction

private function SecondBatch takes nothing returns nothing
    call Spawn(0,30)
    call Spawn(1,10)
    call Spawn(2,10)
    call Spawn(3,10)
    call SetUnitX(homeTarget,sx+850.)
    call SetUnitY(homeTarget,sy+700.)
    call DestroyTimer(GetExpiredTimer())
endfunction

private function TimerCheck takes nothing returns nothing
    if GetTimerData(GetExpiredTimer()) == 127 then
        set timerChecks = timerChecks+1
    endif
    call ReleaseTimer(GetExpiredTimer())
endfunction

private function Begin takes nothing returns nothing
    local Table table = Table.create()
    local timer t = NewTimerEx(127)
    set table[127] = 251
    if table[127] != 251 or WorldBounds.maxX <= WorldBounds.minX or IsDestructableTree(null) then
        set failed = failed+1
    endif
    call table.remove(127)
    if table.has(127) then
        set failed = failed+1
    endif
    call table.destroy()
    call TimerStart(t,0.1,false,function TimerCheck)
    set sx = GetStartLocationX(0)
    set sy = GetStartLocationY(0)
    set hitTarget = CreateUnit(Player(15),'hfoo',sx+500.,sy+300.,0.)
    set homeTarget = CreateUnit(Player(15),'hfoo',sx+1000.,sy+600.,0.)
    call UnitAddAbility(hitTarget,'Avul')
    call UnitAddAbility(homeTarget,'Avul')
    call SetUnitPathing(hitTarget,false)
    call SetUnitPathing(homeTarget,false)
    call SetUnitX(hitTarget,sx+500.)
    call SetUnitY(hitTarget,sy+300.)
    call SetUnitX(homeTarget,sx+1000.)
    call SetUnitY(homeTarget,sy+600.)
    call PanCameraToTimed(sx+500.,sy+400.,0.)
    call FogEnable(false)
    call FogMaskEnable(false)
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("TERRAINDEV RUN @RUN@ START")
    call PreloadGenEnd("Logs\\TerrainDev-@RUN@-start.txt")
    call Spawn(0,30)
    // DEATH_TIME=2 starts when the first batch returns; allow that barrier.
    call TimerStart(CreateTimer(),6.,false,function SecondBatch)
    call TimerStart(CreateTimer(),14.,false,function Finish)
    call DestroyTimer(GetExpiredTimer())
    set t = null
endfunction

private function Init takes nothing returns nothing
    call TimerStart(CreateTimer(),1.,false,function Begin)
endfunction
endlibrary
