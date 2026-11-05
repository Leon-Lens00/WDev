"""Puente de prueba de un jugador (Dev Mission v12k, 30/10/2026). NO integrar.

Registra cada segundo el estado del controlador y las ordenes que recibe, para observar los botones y el clic real.
Uso: puente_botones_v12k.py IN_J OUT_J [CELDA]
"""
from pathlib import Path
import sys

import puente_v12 as base

GLOBALS = '''// TEMPORARY test bridge (scripts/puente_botones_v12k.py).
integer Sonda_Paso = 0
integer Sonda_N = 0
unit Sonda_Blanco = null
'''
FUNCS = '''// TEMPORARY test bridge (scripts/puente_botones_v12k.py).
function Sonda_Log takes string s returns nothing
    set Sonda_N = Sonda_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\\\\\\\j1-" + I2S(Sonda_N) + ".txt")
endfunction

function Sonda_Orden takes nothing returns nothing
    call Sonda_Log("orden " + I2S(GetIssuedOrderId()) + " punto " + I2S(R2I(GetOrderPointX())) + "," + I2S(R2I(GetOrderPointY())) + " paso " + I2S(Sonda_Paso))
endfunction

function Sonda_Hechizo takes nothing returns nothing
    call Sonda_Log("hechizo " + I2S(GetSpellAbilityId()) + " paso " + I2S(Sonda_Paso))
endfunction

function Sonda_Timer takes nothing returns nothing
    local unit h = Game_Hero[0]
    local unit c = Game_Ctrl[0]
    local trigger t
    if h == null then
        return
    endif
    set Sonda_Paso = Sonda_Paso + 1
    if Sonda_Paso == 1 then
        set Sonda_Blanco = CreateUnit(Player(12), 'hfoo', GetUnitX(h) - 260, GetUnitY(h), 0)
        call PauseUnit(Sonda_Blanco, true)
        set t = CreateTrigger()
        call TriggerRegisterUnitEvent(t, c, EVENT_UNIT_ISSUED_POINT_ORDER)
        call TriggerRegisterUnitEvent(t, c, EVENT_UNIT_ISSUED_ORDER)
        call TriggerRegisterUnitEvent(t, c, EVENT_UNIT_ISSUED_TARGET_ORDER)
        call TriggerAddAction(t, function Sonda_Orden)
        set t = CreateTrigger()
        call TriggerRegisterUnitEvent(t, c, EVENT_UNIT_SPELL_CAST)
        call TriggerAddAction(t, function Sonda_Hechizo)
        set t = null
    endif
    call Sonda_Log("paso " + I2S(Sonda_Paso) + " heroe " + I2S(R2I(GetUnitX(h))) + "," + I2S(R2I(GetUnitY(h))) + " ctrl " + I2S(R2I(GetUnitX(c))) + "," + I2S(R2I(GetUnitY(c))) + " orden " + I2S(GetUnitCurrentOrder(c)) + " Amov " + I2S(GetUnitAbilityLevel(c, 'Amov')) + " HDHD " + I2S(GetUnitAbilityLevel(c, 'HDHD')) + " Aro1 " + I2S(GetUnitAbilityLevel(c, 'Aro1')) + " AInv " + I2S(GetUnitAbilityLevel(c, 'AInv')) + " vivo " + I2S(R2I(GetWidgetLife(c))) + " tiros " + I2S(s__RapidPair_emitted) + " golpes " + I2S(s__RapidBolt_hits))
    if Sonda_Paso == 30 then
        call Sonda_Log("trigger move " + I2S(Sonda_Paso) + " " + I2S(1 + R2I(0 * GetUnitX(c))))
        if IssuePointOrderById(c, 851986, GetUnitX(h), GetUnitY(h) + 300) then
            call Sonda_Log("move aceptada")
        else
            call Sonda_Log("move rechazada")
        endif
    elseif Sonda_Paso == 33 then
        if IssuePointOrderById(c, 851971, GetUnitX(h), GetUnitY(h) - 300) then
            call Sonda_Log("smart aceptada")
        else
            call Sonda_Log("smart rechazada")
        endif
    endif
    if Sonda_Paso == 90 then
        call DestroyTimer(GetExpiredTimer())
    endif
    set h = null
    set c = null
endfunction

function Puente_Juego takes nothing returns nothing
    call Title_Exit()
    set Hero_Choice[0] = CELDA
    call Title_Black(255, 0, 0.2)
    call DestroyTimer(GetExpiredTimer())
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'function Title_Init takes nothing returns nothing\n', FUNCS.replace('CELDA', sys.argv[3] if len(sys.argv) > 3 else '0') + 'function Title_Init takes nothing returns nothing\n')
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + GLOBALS.replace('\n', base.N) + s[i:]
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)\n',
                  '    call TimerStart(CreateTimer(), 0.1, false, function Puente_Juego)\n'
                  '    call TimerStart(CreateTimer(), 1., true, function Sonda_Timer)\n')
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
