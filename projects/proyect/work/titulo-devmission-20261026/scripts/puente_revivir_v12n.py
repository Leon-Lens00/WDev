"""Puente de prueba de la reaparicion (Dev Mission v12n, 31/10/2026). NO integrar.

Parte del puente de la oleada sin su curacion, y anota cada cambio de estado del personaje con su instante.
Uso: puente_revivir_v12n.py IN_J OUT_J CELDA
"""
from pathlib import Path
import subprocess
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

GLOBALS = '''// TEMPORARY test bridge (scripts/puente_revivir_v12n.py).
string Rev_Antes = ""
integer Rev_Muertes = 0
boolean Rev_Hecho = false
'''
FUNCS = '''// TEMPORARY test bridge (scripts/puente_revivir_v12n.py).
function Rev_Bajo takes nothing returns string
    if s__RapidPair_down[Game_Pair[0]] then
        return " down 1"
    endif
    return " down 0"
endfunction

function Rev_Muerte takes nothing returns nothing
    if GetTriggerUnit() == Game_Hero[0] or GetTriggerUnit() == Game_Ctrl[0] then
        set Rev_Muertes = Rev_Muertes + 1
        call Sonda_Log("evento muerte " + I2S(Rev_Muertes) + " " + GetUnitName(GetTriggerUnit()) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)))
    endif
endfunction

function Rev_Orden takes nothing returns nothing
    local unit h = Game_Hero[0]
    call Sonda_Log("heroe orden " + I2S(GetIssuedOrderId()) + " vivo " + I2S(IntegerTertiaryOp(UnitAlive(h), 1, 0)) + " life " + R2S(GetWidgetLife(h)) + " id " + I2S(GetUnitId(h)) + " indexado " + I2S(IntegerTertiaryOp(IsUnitIndexed(h), 1, 0)) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)))
    set h = null
endfunction

function Rev_Estado takes nothing returns nothing
    call Sonda_Log("heroe estado life " + R2S(GetWidgetLife(Game_Hero[0])) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)))
endfunction

function Rev_Timer takes nothing returns nothing
    local unit h = Game_Hero[0]
    local string e
    local trigger t
    if h == null then
        return
    endif
    if not Rev_Hecho then
        set Rev_Hecho = true
        set t = CreateTrigger()
        call TriggerRegisterUnitEvent(t, h, EVENT_UNIT_ISSUED_ORDER)
        call TriggerRegisterUnitEvent(t, h, EVENT_UNIT_ISSUED_POINT_ORDER)
        call TriggerAddAction(t, function Rev_Orden)
        set t = CreateTrigger()
        call TriggerRegisterUnitStateEvent(t, h, UNIT_STATE_LIFE, LESS_THAN, 0.405)
        call TriggerAddAction(t, function Rev_Estado)
        set t = null
    endif
    set e = "vivo " + I2S(IntegerTertiaryOp(UnitAlive(h), 1, 0)) + " dead " + I2S(IntegerTertiaryOp(IsUnitType(h, UNIT_TYPE_DEAD), 1, 0)) + " vida>0 " + I2S(IntegerTertiaryOp(GetWidgetLife(h) > 0.405, 1, 0)) + Rev_Bajo() + " pausa " + I2S(IntegerTertiaryOp(IsUnitPaused(Game_Ctrl[0]), 1, 0)) + " par " + I2S(s__RapidPair_pairs) + " sel " + I2S(IntegerTertiaryOp(IsUnitSelected(Game_Ctrl[0], Player(0)), 1, 0))
    if e != Rev_Antes then
        set Rev_Antes = e
        call Sonda_Log("rev t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " " + e + " life " + R2S(GetWidgetLife(h)) + " heroe " + I2S(R2I(GetUnitX(h))) + "," + I2S(R2I(GetUnitY(h))) + " ctrlvida " + R2S(GetWidgetLife(Game_Ctrl[0])))
    endif
    set h = null
endfunction

function Rev_Inicio takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(t, function Rev_Muerte)
    call TimerStart(GetExpiredTimer(), 0.05, true, function Rev_Timer)
    set t = null
endfunction

'''

if __name__ == '__main__':
    j_in, j_out, celda = sys.argv[1:4]
    subprocess.run([sys.executable, str(S / 'oleada_v12m/puente_oleada.py'), j_in, j_out, celda], check=True, cwd=S)
    s = Path(j_out).read_text(encoding='latin-1', newline='')
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.1, true, function Ole_Cura)\n', '    call TimerStart(CreateTimer(), 0.2, false, function Rev_Inicio)\n')
    s = base.once(s, 'function Sonda_Orden takes nothing returns nothing\n', 'FWD')
    a = s.index('function Sonda_Timer takes nothing')
    s = s[:a] + FUNCS.replace('\n', base.N).replace('function Rev_Inicio', 'function Rev_Inicio') + s[a:]
    # Rev_Bajo must exist before the probes that call it.
    b0 = s.index('function Rev_Bajo'); b1 = s.index('function Rev_Muerte')
    bajo = s[b0:b1]
    s = s[:b0] + s[b1:]
    s = s.replace('FWD', bajo + 'function Sonda_Orden takes nothing returns nothing' + base.N)
    s = s.replace('" paso " + I2S(Sonda_Paso))' + base.N, '" paso " + I2S(Sonda_Paso) + Rev_Bajo())' + base.N)
    i = s.index('globals' + base.N) + len('globals' + base.N)
    s = s[:i] + GLOBALS.replace('\n', base.N) + s[i:]
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
