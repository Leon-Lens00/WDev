#!/usr/bin/env python3
"""Sólo prueba, v14j: entrada directa para fotografiar el minimapa en partida y con la tienda abierta. NO integrar.
Mata la primera oleada; en el descanso, con la tienda abajo, lleva al héroe a su lado, la abre 12 s (como ESC) y FIN.
Registro oculto en lat\\vista-N.txt. Uso: vista_v14j.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)', 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
s = base.once(s, 'real Title_CX=', 'integer Vista_N= 0\ninteger Vista_T= 0\ninteger Vista_A= 0\nunit Vista_U= null\ngroup Vista_G= CreateGroup()\nreal Title_CX=')
s = base.once(s, 'function Shop_Construir takes nothing returns nothing\n', r'''// TEMPORARY test bridge (scripts/vista_v14j.py).
function Vista_Log takes string s returns nothing
    set Vista_N = Vista_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\vista-" + I2S(Vista_N) + ".txt")
endfunction

function Vista_Limites takes string q returns nothing
    call Vista_Log(q + " limites " + R2S(GetCameraBoundMinX()) + " " + R2S(GetCameraBoundMaxX()) + " " + R2S(GetCameraBoundMinY()) + " " + R2S(GetCameraBoundMaxY()) + " inicial " + R2S(GetRectMinX(bj_mapInitialCameraBounds)) + " " + R2S(GetRectMaxX(bj_mapInitialCameraBounds)) + " " + R2S(GetRectMinY(bj_mapInitialCameraBounds)) + " " + R2S(GetRectMaxY(bj_mapInitialCameraBounds)) + " margenes " + R2S(GetCameraMargin(CAMERA_MARGIN_LEFT)) + " " + R2S(GetCameraMargin(CAMERA_MARGIN_RIGHT)) + " " + R2S(GetCameraMargin(CAMERA_MARGIN_BOTTOM)) + " " + R2S(GetCameraMargin(CAMERA_MARGIN_TOP)))
endfunction

function Vista_Tick takes nothing returns nothing
    local integer o
    local unit u
    set Vista_T = Vista_T + 1
    if Game_Hero[0] != null then
        call SetWidgetLife(Game_Hero[0], GetUnitState(Game_Hero[0], UNIT_STATE_MAX_LIFE))
    endif
    if Vista_T == 1 then
        call Vista_Log("mundo " + R2S(GetRectMinX(GetWorldBounds())) + " " + R2S(GetRectMaxX(GetWorldBounds())) + " " + R2S(GetRectMinY(GetWorldBounds())) + " " + R2S(GetRectMaxY(GetWorldBounds())))
    elseif Vista_T >= 3 and Vista_T <= 7 then
        // Pings en puntos conocidos para medir qué zona cubre el minimapa: centro, esquinas del juego y bordes del ancho.
        call PingMinimapEx(0., 0., 1.5, 255, 255, 255, false)
        call PingMinimapEx(-7296., -7296., 1.5, 255, 0, 0, false)
        call PingMinimapEx(5888., 5632., 1.5, 255, 0, 0, false)
        call PingMinimapEx(-13440., 0., 1.5, 0, 255, 0, false)
        call PingMinimapEx(12032., 0., 1.5, 0, 255, 0, false)
        call PingMinimapEx(0., 9728., 1.5, 0, 128, 255, false)
    endif
    if Vista_T <= 4 then
        call Vista_Limites("t " + I2S(Vista_T))
    endif
    if Vista_T == 6 then
        call Vista_Log("juego t " + I2S(Vista_T) + " camara " + R2S(GetCameraBoundMinX()) + " " + R2S(GetCameraBoundMaxX()) + " " + R2S(GetCameraBoundMinY()) + " " + R2S(GetCameraBoundMaxY()) + " jugable " + R2S(GetRectMinX(bj_mapInitialPlayableArea)) + " " + R2S(GetRectMaxX(bj_mapInitialPlayableArea)))
    endif
    // Ronda: mata a los de la oleada; descanso con la tienda abajo: héroe al lado, abre (como ESC) 12 s y cierra.
    if Ronda_Activa and not Ronda_Descanso then
        set o = WAVE_DEFAULT_OWNER_MIN
        loop
            exitwhen o > WAVE_DEFAULT_OWNER_MAX
            call GroupEnumUnitsOfPlayer(Vista_G, Player(o), null)
            loop
                set u = FirstOfGroup(Vista_G)
                exitwhen u == null
                call GroupRemoveUnit(Vista_G, u)
                if GetWidgetLife(u) > 0.405 then
                    call KillUnit(u)
                endif
            endloop
            set o = o + 1
        endloop
    elseif Ronda_Descanso and DevTienda_Estado == 2 and Vista_A == 0 then
        call SetUnitPosition(Game_Hero[0], GetUnitX(Shop_Golem) + 200., GetUnitY(Shop_Golem))
        set Vista_A = Vista_T
    elseif Vista_A > 0 and Vista_T == Vista_A + 2 then
        call Shop_Abrir(0)
        call Vista_Log("tienda t " + I2S(Vista_T) + " abierta " + I2S(IntegerTertiaryOp(Shop_Open[0], 1, 0)))
    elseif Vista_A > 0 and Vista_T == Vista_A + 6 then
        // Prueba: límites en un rectángulo mayor que la vista y cámara fijada a un dummy en el centro de la tienda.
        set Vista_U = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'dumi', 2400., 8700., 0.)
        if GetLocalPlayer() == Player(0) then
            call SetCameraBounds(2400. - 900., 8700. - 1400., 2400. + 900., 8700. + 1400., 2400. - 900., 8700. + 1400., 2400. + 900., 8700. - 1400.)
            call SetCameraTargetController(Vista_U, 0., 0., false)
        endif
        call Vista_Log("bloqueo t " + I2S(Vista_T) + " cam " + R2S(GetCameraTargetPositionX()) + " " + R2S(GetCameraTargetPositionY()) + " margenes " + R2S(GetCameraMargin(CAMERA_MARGIN_LEFT)) + " " + R2S(GetCameraMargin(CAMERA_MARGIN_RIGHT)) + " " + R2S(GetCameraMargin(CAMERA_MARGIN_BOTTOM)) + " " + R2S(GetCameraMargin(CAMERA_MARGIN_TOP)))
    elseif Vista_A > 0 and Vista_T > Vista_A + 6 and Vista_T < Vista_A + 14 then
        call Vista_Log("cam t " + I2S(Vista_T) + " " + R2S(GetCameraTargetPositionX()) + " " + R2S(GetCameraTargetPositionY()) + " ojo " + R2S(GetCameraEyePositionX()) + " " + R2S(GetCameraEyePositionY()) + " " + R2S(GetCameraEyePositionZ()))
    elseif Vista_A > 0 and Vista_T == Vista_A + 14 then
        call Shop_Cerrar(0)
        call Vista_Log("cerrada t " + I2S(Vista_T))
    elseif Vista_A > 0 and Vista_T == Vista_A + 18 then
        call Vista_Log("FIN t " + I2S(Vista_T))
    endif
    set u = null
endfunction

function Vista_Iniciar takes nothing returns nothing
    call Vista_Limites("inicio")
    call TimerStart(CreateTimer(), 1., true, function Vista_Tick)
endfunction

function Shop_Construir takes nothing returns nothing
''')
s = base.once(s, '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n',
              '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n    call ExecuteFunc("Vista_Iniciar")\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
