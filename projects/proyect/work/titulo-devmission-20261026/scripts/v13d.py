#!/usr/bin/env python3
"""v13d: seis rondas con unidades del pantano sobre v13c.

Uso: v13d.py IN_J OUT_J COLISIONES
COLISIONES tiene una línea por tipo: rawcode, escala de selección y colisión de 1.27.
"""
from pathlib import Path
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base
from objetos_v13d import UNIDADES

RONDAS = (
    (('nmcf', 2, 'MELEE'),),
    (('nlpr', 2, 'MELEE'), ('ntrh', 1, 'RANGED')),
    (('nmtw', 3, 'MELEE'), ('nmsn', 1, 'RANGED')),
    (('nmmu', 1, 'MELEE'), ('nmtw', 2, 'MELEE'), ('nlds', 1, 'RANGED')),
    (('ntrg', 1, 'MELEE'), ('nlpr', 2, 'MELEE'), ('nnsw', 1, 'RANGED')),
    (('nlpr', 3, 'MELEE'),),
)
SLOT = '''    function DevWave_Slot takes integer w,integer id,integer amount,integer profile returns nothing
        call WaveAddSlotExByPlayers(w , id , amount , false , WaveDifficultyOwnerCap() , 1 , 0 , - 1 , false , profile , 0 , 0 , 1.)
    endfunction
    // One entry per round; the amounts are per wave owner (6 owners).
    function DevWave_Slots takes integer w,integer n returns nothing
'''


def slots():
    s = SLOT
    for i, ronda in enumerate(RONDAS, 1):
        s += f'        {"if" if i == 1 else "elseif"} n == {i} then\n'
        for tipo, cuantos, perfil in ronda:
            s += f"            call DevWave_Slot(w, '{tipo}', {cuantos}, AI_PROFILE_{perfil})\n"
        if i == len(RONDAS):
            s += "            call WaveAddSlotExByPlayer(w , 'ntrd' , 1 , false , WaveDifficultyOwnerCap() , 1 , 0 , - 1 , false , Player(WAVE_DEFAULT_OWNER_MIN) , AI_PROFILE_MELEE , 0 , 0 , 1.)\n"
    return s + '        endif\n    endfunction\n'


if __name__ == '__main__':
    j_in, j_out, colisiones = sys.argv[1:4]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'constant integer Ronda_TOTAL = 3\n', f'constant integer Ronda_TOTAL = {len(RONDAS)}\n')
    s = base.once(s, "        call WaveAddSlotExByPlayers(w , 'hpea' , n , false , WaveDifficultyOwnerCap() , 1 , 0 , - 1 , false , AI_PROFILE_MELEE , 0 , 0 , 1.)\n"
                     "        call WaveAddSlotExByPlayers(w , 'hfoo' , n , false , WaveDifficultyOwnerCap() , 1 , 0 , - 1 , false , AI_PROFILE_MELEE , 0 , 0 , 1.)\n",
                  '        call DevWave_Slots(w, n)\n')
    s = base.once(s, '    function DevWave_Start takes integer n returns nothing\n', slots() + '    function DevWave_Start takes integer n returns nothing\n')
    formas = ''
    for linea in Path(colisiones).read_text().splitlines():
        t, escala, col = linea.split()
        formas += f"        call s__UnitHitShape_register('{t}' , {escala} , {col})\n"
    h = "        call s__UnitHitShape_register('h006' , 2. , 48.)\n"
    s = base.once(s, h, h + "        // v13d: the swamp wave units.\n" + formas)
    # The first spawn of a type would load its model mid round.
    carga = ''.join(f"    call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), '{t.decode()}', 0., 0., 0.))\n" for t in UNIDADES)
    s = base.once(s, '    call DevWave_Marcadores()\n', '    call DevWave_Marcadores()\n' + carga)
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
