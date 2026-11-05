#!/usr/bin/env python3
"""v13g: v13e sin reciclar dummies de misil.

Sin reserva inicial, GetRecycledMissile siempre crea y RecycleMissile siempre toma la salida
de sobrantes: tiempo de vida de 2 s, igual que cuando la reserva se llenaba.

Uso: v13g.py IN_J OUT_J
"""
from pathlib import Path
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base


def sin_reserva(s):
    ini = s.index('function MissileRecycler___Init takes nothing returns nothing')
    a = s.index('        set s__UnitDex_Enabled=(false) // INLINED!!', ini)
    b = s.index('        call TimerStart(MissileRecycler___gameTime', a)
    assert 'exitwhen n == end' in s[a:b] and s[a:b].count('CreateUnit(') == 1
    return s[:a] + s[b:]


if __name__ == '__main__':
    j_in, j_out = sys.argv[1:3]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    s = sin_reserva(s)
    s = base.once(s, 'call s__MissileStats_configure(MissileRecycler___ANG_N * MissileRecycler___ANG_STORAGE_MAX)\n',
                  'call s__MissileStats_configure(0)\n')
    # Without the pool the first shot would load the dummy model.
    s = base.once(s, '    call Ronda_Temas()\n',
                  "    call Ronda_Temas()\n    call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'dumi', 0., 0., 0.))\n")
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
