"""Puente de prueba del dash con teclas reales (Dev Mission v12r, 31/10/2026). NO integrar.

Sobre el puente de rondas (modo 1): registra cada dash con posición, cara, maná y estado; las teclas E y D las pulsa el script de prueba.
Uso: puente_dash_solo_v12r.py IN_J OUT_J CELDA
"""
from pathlib import Path
import subprocess
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

FUNCS = '''// TEMPORARY test bridge (scripts/puente_dash_solo_v12r.py).
function Dsh_Mira takes nothing returns nothing
    local unit h = Game_Hero[0]
    local integer m = s__RapidPair_motion[Game_Pair[0]]
    local string e = I2S(s__RapidPair_dashes) + " " + I2S(IntegerTertiaryOp(s__GroundMotion_dashing[m], 1, 0))
    if h != null and e != Dsh_Antes then
        set Dsh_Antes = e
        call Sonda_Log("dash " + e + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " x " + I2S(R2I(GetUnitX(h))) + " y " + I2S(R2I(GetUnitY(h))) + " cara " + I2S(R2I(GetUnitFacing(h))) + " mana " + I2S(R2I(GetUnitState(Game_Ctrl[0], UNIT_STATE_MANA))) + " sel " + I2S(IntegerTertiaryOp(IsUnitSelected(Game_Ctrl[0], Player(0)), 1, 0)) + " muros " + I2S(s__RapidPair_dashWalls))
    endif
    set h = null
endfunction

function Dsh_Flecha takes nothing returns nothing
    set Dsh_Flechas = Dsh_Flechas + 1
    call Sonda_Log("flecha " + I2S(Dsh_Flechas) + " t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " dashes " + I2S(s__RapidPair_dashes) + " caido " + I2S(IntegerTertiaryOp(s__RapidPair_down[Game_Pair[0]], 1, 0)) + " sel " + I2S(IntegerTertiaryOp(IsUnitSelected(Game_Ctrl[0], Player(0)), 1, 0)))
endfunction

function Rnd_Mira takes nothing returns nothing
'''
START = '    call TimerStart(CreateTimer(), 0.05, true, function Rnd_Mira)\n'

if __name__ == '__main__':
    j_in, j_out, celda = sys.argv[1:4]
    subprocess.run([sys.executable, str(S / 'puente_rondas_v12q.py'), j_in, j_out, celda, '1'], check=True, cwd=S)
    s = Path(j_out).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'real Rnd_Muerte = -1.\n', 'real Rnd_Muerte = -1.\nstring Dsh_Antes = ""\ninteger Dsh_Flechas = 0\ntrigger Dsh_Tecla = null\n')
    s = base.once(s, 'function Rnd_Mira takes nothing returns nothing\n', FUNCS)
    s = base.once(s, START, '''    set Dsh_Tecla = CreateTrigger()
    call TriggerRegisterPlayerEvent(Dsh_Tecla, Player(0), EVENT_PLAYER_ARROW_LEFT_DOWN)
    call TriggerAddAction(Dsh_Tecla, function Dsh_Flecha)
    call TimerStart(CreateTimer(), 0.05, true, function Dsh_Mira)
''' + START)
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
