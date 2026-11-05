"""Puente de prueba LAN de RapidFire (Dev Mission v12i, 30/10/2026). NO integrar.

Dos jugadores van directo a la zona de juego (A Tauren, B Cairne) con blancos quietos. Las ordenes salen de timers iguales en
ambos clientes y pasan por los eventos reales de orden y habilidad. Cada 4 s se escribe un chequeo que debe coincidir.
Uso: puente_rapid_v12i.py IN_J OUT_J
"""
from pathlib import Path
import sys

import puente_v12 as base

GLOBALS = '''// TEMPORARY test bridge (scripts/puente_rapid_v12i.py).
integer Sonda_Paso = 0
integer Sonda_N = 0
integer Sonda_Dir = 0
unit array Sonda_Blanco
'''
FUNCS = '''// TEMPORARY test bridge (scripts/puente_rapid_v12i.py).
function Sonda_Log takes string s returns nothing
    set Sonda_N = Sonda_N + 1
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, s)
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\\\j" + I2S(GetPlayerId(GetLocalPlayer()) + 1) + "-" + I2S(Sonda_N) + ".txt")
endfunction

function Sonda_B takes boolean b returns integer
    if b then
        return 1
    endif
    return 0
endfunction

function Sonda_Local takes nothing returns nothing
    local integer p = GetPlayerId(GetLocalPlayer())
    call Sonda_Log("J" + I2S(p + 1) + " controlador seleccionado " + I2S(Sonda_B(IsUnitSelected(Game_Ctrl[p], GetLocalPlayer()))) + " actor " + I2S(Sonda_B(IsUnitSelected(Game_Hero[p], GetLocalPlayer()))))
endfunction

function Sonda_Chequeo takes nothing returns nothing
    local unit a = Game_Hero[0]
    local unit b = Game_Hero[1]
    local integer t = R2I(GetUnitX(a) + GetUnitY(a) * 3 + GetUnitX(b) * 5 + GetUnitY(b) * 7 + GetWidgetLife(Sonda_Blanco[0]) * 11 + GetWidgetLife(Sonda_Blanco[1]) * 13)
    call Sonda_Log("paso " + I2S(Sonda_Paso) + " chequeo " + I2S(t) + " tiros " + I2S(s__RapidPair_emitted) + " golpes " + I2S(s__RapidBolt_hits) + " muros " + I2S(s__RapidBolt_walls) + " vivos " + I2S(s__RapidBolt_live) + " rafagas " + I2S(s__RapidPair_bursts) + " recast " + I2S(s__RapidPair_recasts))
    set a = null
    set b = null
endfunction

function Sonda_Traza takes nothing returns nothing
    local unit u = Game_Hero[Sonda_Dir / 8]
    local real ax = GetUnitX(u)
    local real ay = GetUnitY(u)
    local real c = ModuloInteger(Sonda_Dir, 8) * bj_PI / 4.
    local integer r = s__GroundCollision_trace(ax, ay, ax + 1350. * Cos(c), ay + 1350. * Sin(c), 16., null, Player(15), false)
    local real sx = s__GroundCollision_x
    local real sy = s__GroundCollision_y
    local real px = sx + 12. * Cos(c)
    local real py = sy + 12. * Sin(c)
    call Sonda_Log("traza " + I2S(Sonda_Dir / 8) + " dir " + I2S(ModuloInteger(Sonda_Dir, 8) * 45) + " desde " + I2S(R2I(ax)) + "," + I2S(R2I(ay)) + " corta " + I2S(R2I(SquareRoot((sx - ax) * (sx - ax) + (sy - ay) * (sy - ay)))) + " razon " + I2S(r) + " nopisable " + I2S(Sonda_B(IsTerrainPathable(px, py, PATHING_TYPE_WALKABILITY))) + " sonda " + I2S(Sonda_B(s__GroundCollision_point(px, py))) + " dz " + I2S(R2I(s__GroundCollision_height(px, py) - s__GroundCollision_height(sx, sy))))
    set Sonda_Dir = Sonda_Dir + 1
    if Sonda_Dir == 16 then
        call DestroyTimer(GetExpiredTimer())
    endif
    set u = null
endfunction

function Sonda_Timer takes nothing returns nothing
    local unit a = Game_Ctrl[0]
    local unit b = Game_Ctrl[1]
    local real ax = GetUnitX(Game_Hero[0])
    local real ay = GetUnitY(Game_Hero[0])
    local real bx = GetUnitX(Game_Hero[1])
    local real by = GetUnitY(Game_Hero[1])
    if Game_Hero[1] == null then
        return
    endif
    set Sonda_Paso = Sonda_Paso + 1
    if Sonda_Paso == 1 then
        set Sonda_Blanco[0] = CreateUnit(Player(12), 'hfoo', ax + 500, ay, 180)
        set Sonda_Blanco[1] = CreateUnit(Player(12), 'otau', bx - 500, by, 0)
        call PauseUnit(Sonda_Blanco[0], true)
        call PauseUnit(Sonda_Blanco[1], true)
        call TimerStart(CreateTimer(), 0.15, true, function Sonda_Traza)
        call Sonda_Local()
    elseif Sonda_Paso == 3 then
        call IssuePointOrder(a, "move", ax + 150, ay + 100)
        call IssuePointOrder(b, "move", bx - 150, by - 100)
    elseif Sonda_Paso == 5 then
        call Sonda_Local()
        call IssuePointOrder(a, "channel", ax + 500, ay)
        call IssuePointOrder(b, "carrionswarm", bx - 500, by)
    elseif Sonda_Paso == 6 then
        call IssuePointOrder(a, "move", ax, ay - 250)
    elseif Sonda_Paso == 7 then
        call IssuePointOrder(a, "breathoffire", ax + 500, ay)
    elseif Sonda_Paso == 10 then
        // Volver a seleccionar al personaje debe pasar la seleccion al controlador.
        if GetLocalPlayer() == Player(1) then
            call ClearSelection()
            call SelectUnit(Game_Hero[1], true)
        endif
    elseif Sonda_Paso == 12 then
        call Sonda_Local()
    elseif Sonda_Paso == 14 then
        call KillUnit(Game_Hero[1])
    elseif Sonda_Paso == 16 then
        call Sonda_Log("J2 muerto: pares " + I2S(s__RapidPair_pairs) + " controlador " + I2S(GetUnitTypeId(Game_Ctrl[1])))
    elseif Sonda_Paso == 18 then
        call DestroyTimer(GetExpiredTimer())
    endif
    if ModuloInteger(Sonda_Paso, 2) == 0 then
        call Sonda_Chequeo()
    endif
    set a = null
    set b = null
endfunction

function Puente_Juego takes nothing returns nothing
    call Title_Exit()
    set Hero_Choice[0] = 0
    set Hero_Choice[1] = 1
    call Title_Black(255, 0, 0.2)
    call DestroyTimer(GetExpiredTimer())
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'function Title_Init takes nothing returns nothing\n', FUNCS + 'function Title_Init takes nothing returns nothing\n')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + GLOBALS.replace('\n', base.N) + s[i:]
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
                  '    call TimerStart(CreateTimer(), 0.1, false, function Puente_Juego)\n'
                  '    call TimerStart(CreateTimer(), 2., true, function Sonda_Timer)\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
