"""Puente de prueba de las rondas (Dev Mission v12q, 31/10/2026). NO integrar.

Sobre el puente de vidas: 2 rondas y 8 s de descanso, y limpia la oleada para no depender de la puntería.
MODO 1: limpia a los 12 s de cada ronda, con 3 vidas; termina en victoria.
MODO 2: 1 vida; limpia 1 s después de la muerte real, dentro de la espera de la derrota. En la ronda 2 no limpia: termina en derrota.
Uso: puente_rondas_v12q.py IN_J OUT_J CELDA MODO
"""
from pathlib import Path
import subprocess
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

FUNCS = '''// TEMPORARY test bridge (scripts/puente_rondas_v12q.py).
function Rnd_Filtro takes nothing returns boolean
    return UnitAlive(GetFilterUnit())
endfunction

function Rnd_Limpiar takes nothing returns nothing
    local integer o = 8
    local group g = CreateGroup()
    local unit u
    loop
        exitwhen o > 13
        call GroupEnumUnitsOfPlayer(g, Player(o), Condition(function Rnd_Filtro))
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            call KillUnit(u)
        endloop
        set o = o + 1
    endloop
    call DestroyGroup(g)
    set g = null
endfunction

function Rnd_Mira takes nothing returns nothing
    local string e = "ronda " + I2S(Ronda_Numero) + " descanso " + I2S(IntegerTertiaryOp(Ronda_Descanso, 1, 0)) + " enpie " + I2S(Vidas_EnPie) + " par " + I2S(s__RapidPair_pairs) + " sel " + I2S(IntegerTertiaryOp(IsUnitSelected(Game_Ctrl[0], Player(0)), 1, 0)) + " vidas " + I2S(Vidas_Actual[0]) + " Arei " + I2S(GetUnitAbilityLevel(Game_Hero[0], 'Arei')) + " Avul " + I2S(GetUnitAbilityLevel(Game_Hero[0], 'Avul'))
    set Rnd_Dt = Rnd_Dt + 0.05
    if e != Rnd_Antes then
        set Rnd_Antes = e
        call Sonda_Log("estado t " + R2S(Rnd_Dt) + " " + e + " life " + I2S(R2I(GetWidgetLife(Game_Hero[0]))) + " mana " + I2S(R2I(GetUnitState(Game_Ctrl[0], UNIT_STATE_MANA))) + " tokill " + I2S(s__Wave_toKillRemaining[Ronda_Wave]))
    endif
    if Ronda_Descanso then
        set Rnd_Base = Rnd_Dt
        set Rnd_Muerte = -1.
    elseif Rnd_Modo == 1 then
        if Ronda_Activa and Rnd_Dt - Rnd_Base >= 12. then
            call Rnd_Limpiar()
        endif
    elseif Ronda_Activa and Ronda_Numero == 1 and not Vidas_EnPartida[0] then
        if Rnd_Muerte < 0. then
            set Rnd_Muerte = Rnd_Dt
            call Sonda_Log("muerte real t " + R2S(Rnd_Dt) + " enpie " + I2S(Vidas_EnPie))
        elseif Rnd_Dt - Rnd_Muerte >= 1. then
            call Rnd_Limpiar()
        endif
    endif
endfunction

function Rev_Timer takes nothing returns nothing
'''
START = '    call TimerStart(GetExpiredTimer(), 0.05, true, function Rev_Timer)\n'

if __name__ == '__main__':
    j_in, j_out, celda, modo = sys.argv[1:5]
    vidas = '3' if modo == '1' else '1'
    subprocess.run([sys.executable, str(S / 'puente_vidas_v12o.py'), j_in, j_out, celda, vidas], check=True, cwd=S)
    s = Path(j_out).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'constant integer Ronda_TOTAL = 10\n', 'constant integer Ronda_TOTAL = 2\n')
    s = base.once(s, 'constant integer Ronda_DESCANSO = 45\n', f'''constant integer Ronda_DESCANSO = 8
integer Rnd_Modo = {modo}
real Rnd_Dt = 0.
real Rnd_Base = 0.
real Rnd_Muerte = -1.
string Rnd_Antes = ""
''')
    s = base.once(s, 'function Rev_Timer takes nothing returns nothing\n', FUNCS)
    s = base.once(s, START, '    call TimerStart(CreateTimer(), 0.05, true, function Rnd_Mira)\n' + START)
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
