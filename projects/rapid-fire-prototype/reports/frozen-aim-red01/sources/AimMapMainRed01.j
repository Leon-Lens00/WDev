// Separate external-source executable. Inherited W3I/WCT/WTG are unchanged;
// one runtime P0, not an editor-save or multiplayer certificate.
function config takes nothing returns nothing
    local integer i = 1
    call SetMapName("Rapid Fire Aim RED B01 B02 R03 R04 R05")
    call SetMapDescription("rf-burst-aim-red-20261020-01: new-aim native RED with existing-flight regression")
    call SetPlayers(1)
    call SetTeams(1)
    call SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
    call DefineStartLocation(0,-2223.5,4352.)
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
    call PanCameraTo(-2223.5,4352.)
    call RCStartHarness()
endfunction
