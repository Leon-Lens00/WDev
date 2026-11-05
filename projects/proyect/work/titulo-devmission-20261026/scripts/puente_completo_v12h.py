"""Copia de prueba del flujo completo con mouse real (Dev Mission v12h, 30/10/2026). NO integrar.

Sin saltos ni jugadas simuladas: solo da mas tiempo a cada panel y escribe cada 5 s un chequeo de sincronia en la zona de juego.
Uso: puente_completo_v12h.py IN_J OUT_J
"""
from pathlib import Path
import sys

import puente_v12 as base

CHECK = '''// TEMPORARY test check (scripts/puente_completo_v12h.py).
function Sonda_Chequeo takes nothing returns nothing
    local unit a = Game_Hero[0]
    local unit b = Game_Hero[1]
    local integer t = R2I(GetUnitX(a) + GetUnitY(a) * 3 + GetUnitX(b) * 5 + GetUnitY(b) * 7 + GetWidgetLife(a) * 11 + GetWidgetLife(b) * 13)
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 4.5, "J" + I2S(GetPlayerId(GetLocalPlayer()) + 1) + " chequeo " + I2S(t) + " tiempo " + I2S(R2I(TimerGetElapsed(bj_gameStartedTimer))))
    set a = null
    set b = null
endfunction

'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'function ConversationUI___Start takes nothing returns nothing\n', CHECK + 'function ConversationUI___Start takes nothing returns nothing\n')
    s = base.once(s, '    call TimerStart(CreateTimer(), 0.10, false, function ConversationUI___CalibrateCamera)\n',
                  '    call TimerStart(CreateTimer(), 0.10, false, function ConversationUI___CalibrateCamera)\n'
                  '    call TimerStart(CreateTimer(), 5, true, function Sonda_Chequeo)\n')
    for old, new in [('    set Title_Left = 5\n', '    set Title_Left = 40\n'),
                     ('        set Mode_Left = 5\n', '        set Mode_Left = 40\n'),
                     ('    set Hero_Left = 60\n', '    set Hero_Left = 120\n'),
                     ('    set Boss_Left = 30\n', '    set Boss_Left = 90\n'),
                     ('    set Strat_Left = 5\n', '    set Strat_Left = 30\n')]:
        s = base.once(s, old, new)
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
