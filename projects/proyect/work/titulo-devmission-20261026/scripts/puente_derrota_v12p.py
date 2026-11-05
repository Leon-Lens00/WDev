"""Puente de prueba de la derrota (Dev Mission v12p, 31/10/2026). NO integrar.

Sobre el puente de vidas. Con FANTASMA=1 cuenta un segundo jugador en pie que se retira 6 s después, para ver sin LAN que la derrota espera al último.
Uso: puente_derrota_v12p.py IN_J OUT_J CELDA FANTASMA
"""
from pathlib import Path
import subprocess
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

FUNCS = '''// TEMPORARY test bridge (scripts/puente_derrota_v12p.py).
function Der_Otro takes nothing returns nothing
    call Sonda_Log("segundo jugador sin vidas t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " en pie " + I2S(Vidas_EnPie))
    call Vidas_Retirar(1)
endfunction

function Der_Mira takes nothing returns nothing
    if Der_Fase == 0 and Game_On[0] and not Vidas_EnPartida[0] then
        set Der_Fase = 1
        call Sonda_Log("jugador 0 fuera t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " en pie " + I2S(Vidas_EnPie) + " perdida " + I2S(IntegerTertiaryOp(Vidas_Perdida, 1, 0)))
        if Vidas_EnPartida[1] then
            call TimerStart(CreateTimer(), 6., false, function Der_Otro)
        endif
    elseif Der_Fase == 1 and Vidas_Perdida then
        set Der_Fase = 2
        call Sonda_Log("derrota general t " + R2S(TimerGetElapsed(s__RapidPair_clock)) + " en pie " + I2S(Vidas_EnPie))
    endif
endfunction

function Rev_Timer takes nothing returns nothing
'''
START = '    call TimerStart(GetExpiredTimer(), 0.05, true, function Rev_Timer)\n'

if __name__ == '__main__':
    j_in, j_out, celda, fantasma = sys.argv[1:5]
    subprocess.run([sys.executable, str(S / 'puente_vidas_v12o.py'), j_in, j_out, celda], check=True, cwd=S)
    s = Path(j_out).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'boolean Vidas_Perdida = false\n', 'boolean Vidas_Perdida = false\ninteger Der_Fase = 0\n')
    s = base.once(s, 'function Rev_Timer takes nothing returns nothing\n', FUNCS)
    extra = '    call TimerStart(CreateTimer(), 0.05, true, function Der_Mira)\n'
    if fantasma == '1':
        extra += '    set Vidas_EnPartida[1] = true\n    set Vidas_EnPie = Vidas_EnPie + 1\n'
    s = base.once(s, START, extra + START)
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
