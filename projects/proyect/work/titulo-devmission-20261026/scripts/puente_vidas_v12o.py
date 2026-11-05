"""Puente de prueba de las vidas (Dev Mission v12o, 31/10/2026). NO integrar.

Sobre el puente de reaparicion: 3 vidas para ver la muerte final dentro de la ronda, y registro de vidas, selección e invulnerabilidad.
Uso: puente_vidas_v12o.py IN_J OUT_J CELDA [VIDAS]
"""
from pathlib import Path
import re
import subprocess
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

FUNCS = '''// TEMPORARY test bridge (scripts/puente_vidas_v12o.py).
function Vid_Elegido takes nothing returns string
    local group g = CreateGroup()
    local unit u
    local string s = ""
    call GroupEnumUnitsSelected(g, Player(0), null)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        set s = s + GetUnitName(u) + "/" + I2S(GetPlayerId(GetOwningPlayer(u))) + " "
    endloop
    call DestroyGroup(g)
    set g = null
    return s
endfunction

function Rev_Timer takes nothing returns nothing
'''

if __name__ == '__main__':
    j_in, j_out, celda = sys.argv[1:4]
    vidas = sys.argv[4] if len(sys.argv) > 4 else '3'
    subprocess.run([sys.executable, str(S / 'puente_revivir_v12n.py'), j_in, j_out, celda], check=True, cwd=S)
    s = Path(j_out).read_text(encoding='latin-1', newline='')
    s, n = re.subn(r'constant integer Vidas_INICIO = \d+\r\n', f'constant integer Vidas_INICIO = {vidas}\r\n', s)
    assert n == 1
    s = base.once(s, 'function Rev_Timer takes nothing returns nothing\n', FUNCS)
    s = base.once(s, '" ctrlvida " + R2S(GetWidgetLife(Game_Ctrl[0])))\n',
                  '" ctrlvida " + R2S(GetWidgetLife(Game_Ctrl[0])) + " vidas " + I2S(Vidas_Actual[0]) + " Arei " + I2S(GetUnitAbilityLevel(h, \'Arei\')) + " Avul " + I2S(GetUnitAbilityLevel(h, \'Avul\')) + " elegido " + Vid_Elegido())\n')
    s = base.once(s, ' + " sel " + I2S(IntegerTertiaryOp(IsUnitSelected(Game_Ctrl[0], Player(0)), 1, 0))\n',
                  ' + " sel " + I2S(IntegerTertiaryOp(IsUnitSelected(Game_Ctrl[0], Player(0)), 1, 0)) + " Avul " + I2S(GetUnitAbilityLevel(h, \'Avul\')) + " Arei " + I2S(GetUnitAbilityLevel(h, \'Arei\')) + " vidas " + I2S(Vidas_Actual[0])\n')
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
