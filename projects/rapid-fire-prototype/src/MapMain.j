// Standalone external-source prerequisite map; original demonstration not called.
// Inherited W3I decoded through War3Net map-info: MeleeMap=false,
// FixedPlayerSettings=false, UseCustomForces=false. The script can configure one
// runtime P0 controller. W3I retains four slot records: NOT editor/MP certification.
function config takes nothing returns nothing
    local integer i = 1
    call SetMapName("Rapid Fire Native Prerequisite Probe")
    call SetMapDescription("rf-pathing-20261019-06: fresh real-cliff fixture and retained sampled transit limits")
    call SetPlayers(1)
    call SetTeams(1)
    call SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
    call DefineStartLocation(0,0.,0.)
    call SetPlayerStartLocation(Player(0),0)
    call ForcePlayerStartLocation(Player(0),0)
    call SetPlayerTeam(Player(0),0)
    call SetPlayerColor(Player(0),PLAYER_COLOR_RED)
    call SetPlayerRacePreference(Player(0),RACE_PREF_ORC)
    call SetPlayerRaceSelectable(Player(0),false)
    call SetPlayerController(Player(0),MAP_CONTROL_USER)
    call SetPlayerSlotAvailable(Player(0),MAP_CONTROL_USER)
    loop
        exitwhen i >= 12
        call SetPlayerController(Player(i),MAP_CONTROL_NONE)
        call SetPlayerSlotAvailable(Player(i),MAP_CONTROL_NONE)
        set i = i+1
    endloop
endfunction

function main takes nothing returns nothing
    call SetCameraBounds(-6656.+GetCameraMargin(CAMERA_MARGIN_LEFT),-6784.+GetCameraMargin(CAMERA_MARGIN_BOTTOM),6656.-GetCameraMargin(CAMERA_MARGIN_RIGHT),6528.-GetCameraMargin(CAMERA_MARGIN_TOP),-6656.+GetCameraMargin(CAMERA_MARGIN_LEFT),6528.-GetCameraMargin(CAMERA_MARGIN_TOP),6656.-GetCameraMargin(CAMERA_MARGIN_RIGHT),-6784.+GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl","Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl")
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("LordaeronSummerDay")
    call SetAmbientNightSound("LordaeronSummerNight")
    call InitBlizzard()
    call PanCameraTo(0.,0.)
    call RCStartHarness()
endfunction
