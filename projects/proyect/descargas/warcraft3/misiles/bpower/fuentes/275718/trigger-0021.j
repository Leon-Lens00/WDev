//TESH.scrollpos=0
//TESH.alwaysfold=0

function Tower_P takes nothing returns nothing
    call TriggerExecute(gg_trg_Missile_Configurate)
    set udg_Missile__Origin  = Location(GetUnitX(gg_unit_hgtw_0019), GetUnitY(gg_unit_hgtw_0019))
    set udg_Missile__Impact  = PolarProjectionBJ(udg_Missile__Origin, 700, GetRandomReal(-bj_PI, bj_PI)*bj_RADTODEG)
    set udg_Missile__Speed   = 500.
    set udg_Missile__OriginZ = 50
    set udg_Missile__ImpactZ = 50
    set udg_Missile__Model   = "Abilities\\Weapons\\GuardTowerMissile\\GuardTowerMissile.mdl"
    call TriggerExecute(gg_trg_Missile)
endfunction



function Trig_Stress_Tester_Actions takes nothing returns nothing
    if GetTriggerEventId() == EVENT_UNIT_SELECTED then
        call TimerStart(udg_TowerTest, .01, true, function Tower_P) 
    else
        call PauseTimer(udg_TowerTest)
    endif
endfunction

//===========================================================================
function InitTrig_Stress_Tester takes nothing returns nothing
    set gg_trg_Stress_Tester = CreateTrigger(  )
    call TriggerRegisterUnitEvent( gg_trg_Stress_Tester, gg_unit_hgtw_0019, EVENT_UNIT_SELECTED )
    call TriggerRegisterUnitEvent( gg_trg_Stress_Tester, gg_unit_hgtw_0019, EVENT_UNIT_DESELECTED )
    call TriggerAddAction( gg_trg_Stress_Tester, function Trig_Stress_Tester_Actions )
endfunction

