// External-source executable test bootstrap; no original demonstration triggers.
globals
    rect RC_TEST_REGION = null
endglobals
function InitCustomPlayerSlots takes nothing returns nothing

    // Player 0
    call SetPlayerStartLocation( Player(0), 0 )
    call SetPlayerColor( Player(0), ConvertPlayerColor(0) )
    call SetPlayerRacePreference( Player(0), RACE_PREF_HUMAN )
    call SetPlayerRaceSelectable( Player(0), true )
    call SetPlayerController( Player(0), MAP_CONTROL_USER )

    // Player 1
    call SetPlayerStartLocation( Player(1), 1 )
    call SetPlayerColor( Player(1), ConvertPlayerColor(1) )
    call SetPlayerRacePreference( Player(1), RACE_PREF_ORC )
    call SetPlayerRaceSelectable( Player(1), true )
    call SetPlayerController( Player(1), MAP_CONTROL_USER )

    // Player 2
    call SetPlayerStartLocation( Player(2), 2 )
    call SetPlayerColor( Player(2), ConvertPlayerColor(2) )
    call SetPlayerRacePreference( Player(2), RACE_PREF_UNDEAD )
    call SetPlayerRaceSelectable( Player(2), true )
    call SetPlayerController( Player(2), MAP_CONTROL_USER )

    // Player 3
    call SetPlayerStartLocation( Player(3), 3 )
    call SetPlayerColor( Player(3), ConvertPlayerColor(3) )
    call SetPlayerRacePreference( Player(3), RACE_PREF_NIGHTELF )
    call SetPlayerRaceSelectable( Player(3), true )
    call SetPlayerController( Player(3), MAP_CONTROL_USER )

endfunction

function InitAllyPriorities takes nothing returns nothing

    call SetStartLocPrioCount( 0, 1 )
    call SetStartLocPrio( 0, 0, 3, MAP_LOC_PRIO_HIGH )

    call SetStartLocPrioCount( 1, 1 )
    call SetStartLocPrio( 1, 0, 2, MAP_LOC_PRIO_HIGH )

    call SetStartLocPrioCount( 2, 1 )
    call SetStartLocPrio( 2, 0, 1, MAP_LOC_PRIO_HIGH )

    call SetStartLocPrioCount( 3, 1 )
    call SetStartLocPrio( 3, 0, 0, MAP_LOC_PRIO_HIGH )
endfunction

function config takes nothing returns nothing
    call SetMapName( "TRIGSTR_020" )
    call SetMapDescription( "TRIGSTR_022" )
    call SetPlayers( 4 )
    call SetTeams( 4 )
    call SetGamePlacement( MAP_PLACEMENT_TEAMS_TOGETHER )

    call DefineStartLocation( 0, -2112.0, 4608.0 )
    call DefineStartLocation( 1, 5376.0, -2112.0 )
    call DefineStartLocation( 2, 2624.0, -5248.0 )
    call DefineStartLocation( 3, -5248.0, 1600.0 )

    // Player setup
    call InitCustomPlayerSlots(  )
    call SetPlayerSlotAvailable( Player(0), MAP_CONTROL_USER )
    call SetPlayerSlotAvailable( Player(1), MAP_CONTROL_USER )
    call SetPlayerSlotAvailable( Player(2), MAP_CONTROL_USER )
    call SetPlayerSlotAvailable( Player(3), MAP_CONTROL_USER )
    call InitGenericPlayerSlots(  )
    call InitAllyPriorities(  )
endfunction

function main takes nothing returns nothing
    call SetCameraBounds( -6656.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -6784.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 6656.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 6528.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -6656.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 6528.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 6656.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -6784.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM) )
    call SetDayNightModels( "Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl" )
    call NewSoundEnvironment( "Default" )
    call SetAmbientDaySound( "LordaeronSummerDay" )
    call SetAmbientNightSound( "LordaeronSummerNight" )
    call SetMapMusic( "Music", true, 0 )
    call InitBlizzard()
    set RC_TEST_REGION = Rect(-1024., -1024., 1024., 1024.)
    call PanCameraTo(0., 0.)
    call RCStartHarness()
endfunction
