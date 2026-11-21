#!/usr/bin/env python3
"""v18w (15/11/2026): Leon oye QuestCompleted y el tic al empezar la partida.

- Son los calentados por etiqueta que v18v añadió en Son_Calentar (1 s y 3 s): CreateSoundFromLabel con
  SetSoundVolume 0 antes de StartSound suena igual (la etiqueta parece imponer su volumen al arrancar). Los .wav
  creados por ruta sí respetan el 0 y no se oyen.
- Ahora se calientan por ruta (Son_Cero), mismo archivo: Sound\\Interface\\QuestCompleted.wav y BattleNetTick.wav.
Uso: v18w.py ENTRADA.j SALIDA.j [prueba]   (prueba: registros v18v -> v18w)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
modo = sys.argv[3] if len(sys.argv) > 3 else ''
viejo = ('    call Son_CeroEtiqueta("QuestCompleted")\n    call Son_CeroEtiqueta("ChatroomTimerTick")\n')
nuevo = ('    // v18w: por ruta; por etiqueta sonaban aunque el volumen fuera 0.\n'
         '    call Son_Cero("Sound\\\\Interface\\\\QuestCompleted.wav")\n'
         '    call Son_Cero("Sound\\\\Interface\\\\BattleNetTick.wav")\n')
for a, b in ((viejo, nuevo), (viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n'))):
    if src.count(a):
        assert src.count(a) == 1
        src = src.replace(a, b)
        break
else:
    raise SystemExit('no encontrado')
if modo == 'prueba':
    assert src.count('lat\\\\v18v-') == 4
    src = src.replace('lat\\\\v18v-', 'lat\\\\v18w-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18w', modo or 'normal')
