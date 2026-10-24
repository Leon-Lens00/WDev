//TESH.scrollpos=44
//TESH.alwaysfold=0
scope HillGuard initializer Init 
    
    globals
        private unit REVENANT                    = null
        private boolean READY                    = true
        private Guard GUARDIAN                   = 0
    endglobals

    
// This is the big revenant on the hill. Right corner of the map.
private function cb takes nothing returns nothing
    call ReleaseTimer(GetExpiredTimer())
    set READY = true
endfunction

    struct Guard extends Hydra

    private static method onRemove takes Missile missile returns boolean
        return true
    endmethod
    
    private static method onTerrain takes Missile missile returns boolean
        return true
    endmethod

    private static method onCollide takes Missile missile, unit hit returns boolean
        if UnitAlive(hit) and IsUnitEnemy(hit, missile.owner) then
            return UnitDamageTarget(missile.source, hit, missile.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
        endif
        return false
    endmethod

    implement MissileStruct
    
    method onTargetFilter takes unit target, player owner returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) 
    endmethod
    
    private method onFire takes unit shooter, unit target, Missile missile returns nothing
        set missile.model      = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
        set missile.scale      = 1.
        set missile.damage     = GetRandomReal(50, 150)
        set missile.collision  = 32.
        set missile.collisionZ = 15.
        set missile.speed      = 27.  
        set missile.arc        = bj_PI/3
        set missile.curve      = GetRandomReal(-bj_PI/3, bj_PI/3)
        call thistype.launch(missile)
    endmethod

endstruct

private function enter takes nothing returns boolean
    local unit u   = GetTriggerUnit()
    local real x   = GetUnitX(u)
    local real y   = GetUnitY(u)
    local player p = GetOwningPlayer(u)
    if Player(0) == p and READY then
        if (GUARDIAN != 0) and GUARDIAN.summoned then
            call GUARDIAN.destroy()
            set GUARDIAN = 0
        endif
        set GUARDIAN                     = Guard.create(REVENANT, 'o002', x, y, 0, 225., 0.23)
        set GUARDIAN.headHeight          = 55.
        set GUARDIAN.scale               = 1.0
        set GUARDIAN.attackAnimationTime = .5
        set GUARDIAN.attackSpeed         = 3.2
        set GUARDIAN.attackPeriod        = .5
        set GUARDIAN.duration            = 0.00
        set GUARDIAN.attackRange         = 750.
        set GUARDIAN.heads               = 5
        set GUARDIAN.hasArcOrCurve       = true
        set GUARDIAN.birthAnimationTime  = 1.
        call GUARDIAN.summon()
        //----------------------------
        call SetUnitFacing(REVENANT, Atan2(y - GetUnitY(REVENANT), x - GetUnitX(REVENANT))*bj_RADTODEG)
        call SetUnitAnimation(REVENANT, "spell")
        call QueueUnitAnimation(REVENANT, "stand")
        set READY = false
        call TimerStart(NewTimer(), 4.00, false, function cb)
    endif
    set p = null
    set u = null
    return false
endfunction
    
    private function Init takes nothing returns nothing
        local region r  = CreateRegion()
        local trigger t = CreateTrigger()
        local rect c    = Rect(64, -2624, 384, -2336)

        call RegionAddRect(r, c)
        call TriggerRegisterEnterRegion(t, r, null)
        call TriggerAddCondition(t, Filter(function enter))
        set t = null
        set r = null
        set c = null
    
        set REVENANT = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'nlrv', 127., -3072., 0)
        call UnitAddAbility(REVENANT, 'Aloc')
        call UnitAddAbility(REVENANT, 'Abun')

    endfunction

endscope

