"""Dev Mission v12l (31/10/2026): the controller is a second unit of the character's own type.

Keeps the name, icon and portrait of Tauren and Cairne in the command panel without another object. The abilities go on the
controller instance only, so the character keeps 'Amov' and has no Q, W or R. The controller keeps the mana of its type: abilities spend it.
'Hmgd' brings 'AInv', which would show the inventory label, so the controller loses it.

Usage: controlador_v12l.py IN_J OUT_J
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

import puente_v12 as base

CREATE = "    set Game_Ctrl[p]=CreateUnit(Player(p), 'rfct', s__WorldBounds_minX + 256., s__WorldBounds_minY + 256., 0.)\n"
NEW = """    set Game_Ctrl[p]=CreateUnit(Player(p), id, s__WorldBounds_minX + 256., s__WorldBounds_minY + 256., 0.)
    call UnitRemoveAbility(Game_Ctrl[p], 'AInv')
    call UnitAddAbility(Game_Ctrl[p], 'Avul')
    call UnitAddAbility(Game_Ctrl[p], 'Arpf')
    call UnitAddAbility(Game_Ctrl[p], 'Arp1')
    call UnitAddAbility(Game_Ctrl[p], 'Arp3')
"""
# The alpha turned the panel portrait black; the controller is parked off screen and 'uhom' hides it from the minimap.
ALPHA = "    call SetUnitVertexColor(Game_Ctrl[p], 255, 255, 255, 0)\n"


if __name__ == '__main__':
    j_in, j_out = sys.argv[1:3]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    Path(j_out).write_text(base.once(base.once(s, CREATE, NEW), ALPHA, ''), encoding='latin-1', newline='')
    print('ok')
