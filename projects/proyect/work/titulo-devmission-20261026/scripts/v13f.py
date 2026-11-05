#!/usr/bin/env python3
"""v13f: como v13e, con las canciones de DevTest6 y su velocidad y volumen por oleada.

Uso: v13f.py IN_J OUT_J TEMAS
TEMAS tiene una línea por ronda: número y volumen.
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import v13e

PITCH = '1.07'


def crear(temas):
    s = 'function Ronda_Temas takes nothing returns nothing\n'
    for n, volumen in temas:
        s += f'    set Ronda_Tema[{n}] = CreateSound("war3mapImported\\\\OleadaTema{n}.mp3", true, false, false, 12700, 12700, "")\n'
        s += f'    call SetSoundPitch(Ronda_Tema[{n}], {PITCH})\n'
        s += f'    call SetSoundVolume(Ronda_Tema[{n}], {volumen})\n'
    return s + 'endfunction\n\n'


if __name__ == '__main__':
    v13e.aplicar(*sys.argv[1:4], crear)
