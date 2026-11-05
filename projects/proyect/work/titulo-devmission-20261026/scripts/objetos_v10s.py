"""Objects and imports of v10s (Dev Mission title, 29/10/2026).

- destructable texture (w3b_modos.add): DT3N PresNombre, the boss's name for the end of the presentation
  (texturas_v10s.py);
- imports: war3mapImported\\PresNombre.blp, and the 11 textures of the radial nebula V7 that v10q put in the
  archive without listing them (NebulaRadialV7\\*.blp, at the paths its model names).
Fails if an id or path is already used.

Usage: objetos_v10s.py IN_W3B OUT_W3B IN_IMP OUT_IMP
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w3b_modos

TEXTURES = [('DT3N', 'PresNombre')]
NEBULA = [f'NebulaRadialV7\\{n}.blp' for n in ('Dust', 'Envelope', 'Gas', 'Halo', 'Light', 'PolarDust', 'PolarFlow',
                                               'PolarVein', 'Solid', 'Streak', 'TurbulentWisp')]
IMPORTS = [f'war3mapImported\\{n}.blp' for _, n in TEXTURES] + NEBULA

if __name__ == '__main__':
    w3b_modos.add(TEXTURES, IMPORTS, sys.argv)
    print(len(IMPORTS), 'imports')
