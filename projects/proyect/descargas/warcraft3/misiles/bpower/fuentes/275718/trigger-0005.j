//TESH.scrollpos=45
//TESH.alwaysfold=0
function Trig_Fireball_Actions_Copy_Func005Func001C takes nothing returns boolean
    if ( not ( udg_Missile__EventId == udg_EVENT_MISSILE_COLLIDE_UNIT ) ) then
        return false
    endif
    if ( not ( IsUnitEnemy(udg_Missile__UnitHit, udg_Missile__Owner) == true ) ) then
        return false
    endif
    if ( not ( IsUnitAliveBJ(udg_Missile__UnitHit) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Fireball_Actions_Copy_Func005Func002Func002002003001 takes nothing returns boolean
    return ( IsUnitEnemy(GetFilterUnit(), udg_Missile__Owner) == true )
endfunction

function Trig_Fireball_Actions_Copy_Func005Func002Func002002003002 takes nothing returns boolean
    return ( IsUnitAliveBJ(GetFilterUnit()) == true )
endfunction

function Trig_Fireball_Actions_Copy_Func005Func002Func002002003 takes nothing returns boolean
    return GetBooleanAnd( Trig_Fireball_Actions_Copy_Func005Func002Func002002003001(), Trig_Fireball_Actions_Copy_Func005Func002Func002002003002() )
endfunction

function Trig_Fireball_Actions_Copy_Func005Func002Func003A takes nothing returns nothing
    call UnitDamageTargetBJ( udg_Missile__Source, GetEnumUnit(), udg_Missile__Damage, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL )
endfunction

function Trig_Fireball_Actions_Copy_Func005Func002C takes nothing returns boolean
    if ( not ( udg_Missile__Data == 1 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Fireball_Actions_Copy_Func005C takes nothing returns boolean
    if ( not ( udg_Missile__EventId == udg_EVENT_MISSILE_REMOVE ) ) then
        return false
    endif
    return true
endfunction

function Trig_Fireball_Actions_Copy_Actions takes nothing returns nothing
    // As you can see Missile__EventId allows you 
    // to identify which event trigger dispatched.
    // Therefore you can run all actions from one trigger function.
    // Of course you can also seperate triggers into different triggers.
    if ( Trig_Fireball_Actions_Copy_Func005C() ) then
        if ( Trig_Fireball_Actions_Copy_Func005Func002C() ) then
            // Create more fireballs
            // Reference to Missile__Dummy will be removed
            // Once you call Run Missile Configurate <gen>
            set udg_Missile__TempLoc = GetUnitLoc(udg_Missile__Dummy)
            set bj_forLoopAIndex = 1
            set bj_forLoopAIndexEnd = 6
            loop
                exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
                call TriggerExecute( gg_trg_Missile_Configurate )
                set udg_Missile__Origin = Location(GetLocationX(udg_Missile__TempLoc), GetLocationY(udg_Missile__TempLoc))
                set udg_Missile__Impact = PolarProjectionBJ(udg_Missile__Origin, 450.00, ( 60.00 * I2R(GetForLoopIndexA()) ))
                set udg_Missile__ImpactZ = 50.00
                set udg_Missile__Height = 350.00
                set udg_Missile__OriginZ = 50.00
                set udg_Missile__Speed = 500.00
                set udg_Missile__Damage = 150.00
                set udg_Missile__Source = udg_Missile_Source[udg_Missile__EventIndex]
                set udg_Missile__Owner = udg_Missile_Owner[udg_Missile__EventIndex]
                set udg_Missile__Model = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
                set udg_Missile__OnCollideUnit = gg_trg_Fireball_Actions
                set udg_Missile__OnRemove = gg_trg_Fireball_Actions
                set udg_Missile__Data = 2
                call TriggerExecute( gg_trg_Missile )
                set bj_forLoopAIndex = bj_forLoopAIndex + 1
            endloop
            call RemoveLocation(udg_Missile__TempLoc)
            set udg_Missile__TempLoc = null
        else
            set udg_Missile__TempLoc = GetUnitLoc(udg_Missile__Dummy)
            set udg_Temp_Group = GetUnitsInRangeOfLocMatching(128.00, udg_Missile__TempLoc, Condition(function Trig_Fireball_Actions_Copy_Func005Func002Func002002003))
            call ForGroupBJ( udg_Temp_Group, function Trig_Fireball_Actions_Copy_Func005Func002Func003A )
            call AddSpecialEffectLocBJ( udg_Missile__TempLoc, "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl" )
            call DestroyEffectBJ( GetLastCreatedEffectBJ() )
            call DestroyGroup(udg_Temp_Group)
            call RemoveLocation(udg_Missile__TempLoc)
            set udg_Missile__TempLoc = null
        endif
    else
        if ( Trig_Fireball_Actions_Copy_Func005Func001C() ) then
            // See how easy damaging got.
            call UnitDamageTargetBJ( udg_Missile__Source, udg_Missile__UnitHit, udg_Missile__Damage, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL )
            set udg_Missile__WantDestroy = true
        else
        endif
    endif
endfunction

//===========================================================================
function InitTrig_Fireball_Actions_Copy takes nothing returns nothing
    set gg_trg_Fireball_Actions_Copy = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Fireball_Actions_Copy, function Trig_Fireball_Actions_Copy_Actions )
endfunction

