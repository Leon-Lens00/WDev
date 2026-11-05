"""Puente y sondas temporales de prueba LAN (Dev Mission v12h, 30/10/2026). NO integrar.

Dos jugadores reales en la misma partida, sin intro ni teclado. Las jugadas se simulan con timers en todos los clientes, asi
que son el mismo orden sincronizado que dan los trackables:
- Seleccion: A pasa por la celda 0, despues B por la 1, cada uno elige (A Tauren, B Cairne) y confirma.
- Boss: A y B pasan y marcan un "?" distinto, despues A elige el jefe real y B mas tarde.
- Juego: mueve a los dos, cambia sus vidas, abre y cierra la barra enemiga y escribe un chequeo que debe coincidir en ambos.

Uso: puente_lan_v12h.py IN_J OUT_J
"""
from pathlib import Path
import sys

import puente_v12 as base

GLOBALS = '''// TEMPORARY test bridge (scripts/puente_lan_v12h.py).
integer Puente_Paso = 0
boolean Puente_Listo = false
integer Sonda_Paso = 0
unit Sonda_Jefe = null
'''
FUNCS = '''// TEMPORARY test bridge (scripts/puente_lan_v12h.py).
function Puente_Marca takes string s returns nothing
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 3, s)
endfunction

function Puente_Sim takes nothing returns nothing
    if Puente_Paso == 0 and Puente_Listo then
        set Puente_Paso = 1
        call Mode_Start()
        call Hero_Begin()
    elseif Puente_Paso == 1 and Hero_Ready and Hero_Left <= 17 then
        set Puente_Paso = 2
        call Puente_Marca("Hover de A en celda 0")
        call Hero_OnTrack(0, 100)
    elseif Puente_Paso == 2 and Hero_Left <= 14 then
        set Puente_Paso = 3
        call Puente_Marca("Hover de B en celda 1")
        call Hero_OnTrack(0, -1)
        call Hero_OnTrack(1, 101)
    elseif Puente_Paso == 3 and Hero_Left <= 11 then
        set Puente_Paso = 4
        call Puente_Marca("A elige Tauren, B elige Cairne")
        call Hero_OnTrack(1, -1)
        call Hero_OnHit(0, 100)
        call Hero_OnHit(1, 101)
    elseif Puente_Paso == 4 and Hero_Left <= 8 then
        set Puente_Paso = 5
        call Puente_Marca("A y B confirman")
        call Hero_OnHit(0, 140)
        call Hero_OnHit(1, 140)
    elseif Puente_Paso == 5 and Boss_Ready and Boss_Left <= 13 then
        set Puente_Paso = 6
        call Puente_Marca("Boss: hover de A")
        call Boss_OnTrack(0, 205)
    elseif Puente_Paso == 6 and Boss_Left <= 10 then
        set Puente_Paso = 7
        call Puente_Marca("Boss: hover de B")
        call Boss_OnTrack(0, -1)
        call Boss_OnTrack(1, 206)
    elseif Puente_Paso == 7 and Boss_Left <= 7 then
        set Puente_Paso = 8
        call Puente_Marca("Boss: A marca ? 5, B marca ? 6")
        call Boss_OnTrack(1, -1)
        call Boss_OnHit(0, 205)
        call Boss_OnHit(1, 206)
    elseif Puente_Paso == 8 and Boss_Left <= 4 then
        set Puente_Paso = 9
        call Puente_Marca("Boss: solo A elige")
        call Boss_OnHit(0, 200)
        call Boss_OnHit(0, 240)
    elseif Puente_Paso == 9 and Boss_Left <= 2 then
        set Puente_Paso = 10
        call Puente_Marca("Boss: B elige")
        call Boss_OnHit(1, 200)
        call Boss_OnHit(1, 240)
    endif
endfunction

function Puente_Directo takes nothing returns nothing
    set Title_Registered[0] = true
    set Title_Registered[1] = true
    set Title_Count = 2
    set Title_Left = 999
    call Title_Begin()
endfunction

function Sonda_Texto takes string s, real dur returns nothing
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, dur, s)
endfunction

function Sonda_Chequeo takes string s returns nothing
    local unit a = Game_Hero[0]
    local unit b = Game_Hero[1]
    local integer t = R2I(GetUnitX(a) + GetUnitY(a) * 3 + GetUnitX(b) * 5 + GetUnitY(b) * 7 + GetWidgetLife(a) * 11 + GetWidgetLife(b) * 13)
    call Sonda_Texto(s + " yo J" + I2S(GetPlayerId(GetLocalPlayer()) + 1) + " chequeo " + I2S(t), 14)
    set a = null
    set b = null
endfunction

function Sonda_Paso1 takes nothing returns nothing
    local unit a = Game_Hero[0]
    local unit b = Game_Hero[1]
    set Sonda_Paso = Sonda_Paso + 1
    if Sonda_Paso == 1 then
        call Sonda_Texto("J1 dueno " + I2S(GetPlayerId(GetOwningPlayer(a))) + " tipo " + UnitId2String(GetUnitTypeId(a)) + "; J2 dueno " + I2S(GetPlayerId(GetOwningPlayer(b))) + " tipo " + I2S(GetUnitTypeId(b)), 14)
        call Sonda_Chequeo("Inicio")
    elseif Sonda_Paso == 2 then
        call IssuePointOrder(a, "move", GetUnitX(a) + 300, GetUnitY(a) - 100)
        call IssuePointOrder(b, "move", GetUnitX(b) - 300, GetUnitY(b) + 100)
    elseif Sonda_Paso == 4 then
        call SetWidgetLife(a, GetUnitState(a, UNIT_STATE_MAX_LIFE) * 0.6)
        call SetWidgetLife(b, GetUnitState(b, UNIT_STATE_MAX_LIFE) * 0.3)
        call Sonda_Chequeo("Vidas")
    elseif Sonda_Paso == 6 then
        set Sonda_Jefe = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'otau', GetUnitX(a) + 500, GetUnitY(a), 180)
        call PauseUnit(Sonda_Jefe, true)
        call HealthBarsTarget(Sonda_Jefe)
    elseif Sonda_Paso == 8 then
        call HealthBarsTarget(null)
        call RemoveUnit(Sonda_Jefe)
        call Sonda_Chequeo("Sin jefe")
    elseif Sonda_Paso == 10 then
        call Sonda_Chequeo("Fin")
        call DestroyTimer(GetExpiredTimer())
    endif
    set a = null
    set b = null
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'function ConversationUI___Start takes nothing returns nothing\n',
                  FUNCS.split('function Sonda_Texto')[1].join(['function Sonda_Texto', '']) +
                  'function ConversationUI___Start takes nothing returns nothing\n')
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.10, false, function ConversationUI___CalibrateCamera)\n',
                  '    call TimerStart(CreateTimer(), 0.10, false, function ConversationUI___CalibrateCamera)\n'
                  '    call TimerStart(CreateTimer(), 2.5, true, function Sonda_Paso1)\n')
    s = base.once(s, 'function Title_Init takes nothing returns nothing\n',
                  FUNCS.split('function Sonda_Texto')[0] + 'function Title_Init takes nothing returns nothing\n')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + GLOBALS.replace('\n', base.N) + s[i:]
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
                  '    call TimerStart(CreateTimer(), 0.25, true, function Puente_Sim)\n'
                  '    call TimerStart(CreateTimer(), 0.1, false, function Puente_Directo)\n')
    # La entrada del titulo acaba en Title_Restart, que borra el registro y el estado: el salto va despues.
    s = base.once(s, '    set Title_Active = true\n',
                  '    set Title_Active = true\n    set Title_Registered[0] = true\n    set Title_Registered[1] = true\n'
                  '    set Title_Count = 2\n    set Title_Left = 999\n    set Puente_Listo = true\n')
    for old, new in [('call TimerStart(CreateTimer(), 5.6, false, function Hero_Show)', 'call TimerStart(CreateTimer(), 0.3, false, function Hero_Show)'),
                     ('call TimerStart(GetExpiredTimer(), 2.4, false, function Hero_Go)', 'call TimerStart(GetExpiredTimer(), 0.3, false, function Hero_Go)'),
                     ('call TimerStart(CreateTimer(), 5.6, false, function Panel_Logo)', 'call TimerStart(CreateTimer(), 0.2, false, function Panel_Logo)'),
                     ('call TimerStart(GetExpiredTimer(), 2.4, false, function Panel_Entry)', 'call TimerStart(GetExpiredTimer(), 0.2, false, function Panel_Entry)'),
                     ('    set Hero_Left = 60\n', '    set Hero_Left = 20\n'),
                     ('    set Boss_Left = 30\n', '    set Boss_Left = 16\n')]:
        s = base.once(s, old, new)
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
