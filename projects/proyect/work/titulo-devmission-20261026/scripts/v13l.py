#!/usr/bin/env python3
"""v13l: v13k con descanso de 10 s, canciones a nivel de IziPizi y persecución corregida.

Volumen: los archivos ya miden unos -8 LUFS como los de IziPizi; lo que los bajaba era
SetSoundVolume 40-80. Se igualan a -8 LUFS sin pasar del tope de 127.
Enemigos: el script conoce la posición del personaje, pero los dueños 8-13 no lo veían
y la orden nativa de ataque seguía el último punto visto. Cada ronda comparten visión del
personaje, y quien persigue de lejos renueva la orden cada 2 s para recalcular el camino.

Uso: v13l.py IN_J OUT_J
"""
from pathlib import Path
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

VOLUMENES = {1: (40, 125), 2: (60, 127), 3: (60, 127), 4: (60, 95), 5: (80, 117), 6: (80, 127)}
RENOVAR_DISTANCIA = 500.
RENOVAR_TICKS = 20


def aplicar(j_in, j_out):
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'constant integer Ronda_DESCANSO = 45\n', 'constant integer Ronda_DESCANSO = 10\n')
    for n, (antes, ahora) in VOLUMENES.items():
        s = base.once(s, f'    call SetSoundVolume(Ronda_Tema[{n}], {antes})\n',
                      f'    call SetSoundChannel(Ronda_Tema[{n}], 0)\n    call SetSoundVolume(Ronda_Tema[{n}], {ahora})\n')
    s = base.once(s, '''            call DevWave_AddTarget(Game_Hero[p])
''', '''            call DevWave_AddTarget(Game_Hero[p])
            set o = WAVE_DEFAULT_OWNER_MIN
            loop
                exitwhen o > WAVE_DEFAULT_OWNER_MAX
                call UnitShareVision(Game_Hero[p], Player(o), true)
                set o = o + 1
            endloop
''')
    s = base.once(s, 'function Ronda_Lanzar takes nothing returns nothing\n',
                  'function Ronda_Lanzar takes nothing returns nothing\n    local integer o\n')
    s = base.once(s, '''        elseif GetUnitCurrentOrder(s__WaveAI__WaveAIUnit_u[this]) == WaveAI__OrderAttack then
            set s__WaveAI__WaveAIUnit_lostStreak[this]=0
''', f'''        elseif GetUnitCurrentOrder(s__WaveAI__WaveAIUnit_u[this]) == WaveAI__OrderAttack then
            set s__WaveAI__WaveAIUnit_lostStreak[this]=0
            if currentD > {RENOVAR_DISTANCIA} * {RENOVAR_DISTANCIA} and WaveAI__TickNo >= s__WaveAI__WaveAIUnit_nextReorder[this] then
                call s__WaveAI__WaveAIUnit_attack(this,best)
                set s__WaveAI__WaveAIUnit_nextReorder[this]=WaveAI__TickNo + {RENOVAR_TICKS}
            endif
''')
    Path(j_out).write_text(s, encoding='latin-1', newline='')


if __name__ == '__main__':
    aplicar(sys.argv[1], sys.argv[2])
