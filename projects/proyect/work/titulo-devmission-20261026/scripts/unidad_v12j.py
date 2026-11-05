"""Dev Mission v12j (30/10/2026): Game_Enter creates 'h005' and 'h006' (objetos_v12j.py) instead of 'otau' and 'ocai'.

Applied on the v12i script. 'otau' keeps its hit shape and HealthBarsTarget entry for the boss.

Usage: unidad_v12j.py IN_J OUT_J
"""
from pathlib import Path
import sys

import puente_v12 as base

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    s = base.once(s, "    local integer id= 'otau'\n", "    local integer id= 'h005'\n")
    s = base.once(s, "        set id='ocai'\n", "        set id='h006'\n")
    s = base.once(s, "        call s__UnitHitShape_register('ocai' , 2. , 48.) // v12i: Cairne as a normal unit (objetos_v12g.py)\n",
                  "        call s__UnitHitShape_register('h005' , 1.6 , 48.) // v12j: the characters (objetos_v12j.py).\n"
                  "        call s__UnitHitShape_register('h006' , 2. , 48.)\n")
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
