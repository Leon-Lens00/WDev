#!/usr/bin/env python3
"""v16b (08/11/2026): correcciones del tutorial tras el vídeo de Leon de v16a.
- El panel, el retrato y el icono junto a la consola no se veían: las piezas quedan a ~400 del ojo de la cámara, fuera
  del rectángulo con visión, y la máscara las tapa. La visión del tutorial baja hasta Tut_Y - 2000 y los jugadores
  comparten visión con el dueño de las piezas desde el inicio (como hace luego ConversationUI___Start).
- El Tauren volvía hacia donde nació (punto de guardia de las unidades neutrales): RemoveGuardPosition.
- Cámara más cerca (distancia ~1610, mismo ángulo): el Tauren se veía muy pequeño.
Uso: v16b.py ENTRADA.j SALIDA.j (el j de v16a)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = once(s, 'local rect zona= Rect(Tut_X - 2400., Tut_Y - 1300., Tut_X + 2400., Tut_Y + 1400.)',
         'local rect zona= Rect(Tut_X - 2600., Tut_Y - 2000., Tut_X + 2600., Tut_Y + 1400.)')
s = once(s, '''        set Tut_Vista[p] = CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, zona, true, true)
        call FogModifierStart(Tut_Vista[p])
''', '''        set Tut_Vista[p] = CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, zona, true, true)
        call FogModifierStart(Tut_Vista[p])
        // v16b: las piezas del tutorial son del jugador de las piezas de interfaz; sin su visión no se ven.
        call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_EXTRA), Player(p), bj_ALLIANCE_ALLIED_VISION)
        call SetPlayerAllianceStateBJ(Player(p), Player(bj_PLAYER_NEUTRAL_EXTRA), bj_ALLIANCE_ALLIED_VISION)
''')
s = once(s, '    call s__Camera_setPosition(Tut_Cam, Tut_X, Tut_Y, Tut_Z)\n',
         '    // v16b: más cerca que la cámara por defecto (2856), mismo ángulo de unos 56 grados.\n'
         '    call s__Camera_setEyeAndAt(Tut_Cam, Tut_X, Tut_Y - 900., Tut_Z + 1333., Tut_X, Tut_Y, Tut_Z)\n')
s = once(s, '    call SetUnitMoveSpeed(Tut_Tauren, 300.)\n',
         '    call SetUnitMoveSpeed(Tut_Tauren, 300.)\n    // v16b: sin punto de guardia no vuelve a donde nació.\n    call RemoveGuardPosition(Tut_Tauren)\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16b ok')
