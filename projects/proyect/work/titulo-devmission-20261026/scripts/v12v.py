"""Dev Mission v12v (31/10/2026): colisiones solo por paso, sin emblema y oleadas aliadas entre sí.

Misil, dash y movimiento artificial ya no paran por altura: sigue `GroundCollision.clear`, que corta en precipicios, árboles y sólidos.
Uso: v12v.py IN_J OUT_J
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

import puente_v12 as base

CAMBIOS = (
    # Height no longer stops anything: slopes pass, cliff tiles stay unwalkable.
    ('            if not s__GroundCollision_clear(nx , ny , radius) or RAbsBJ(z - lastZ) > 24. then\n',
     '            if not s__GroundCollision_clear(nx , ny , radius) then\n'),
    ('        elseif result == 1 or s__Missile_z[m] < 0. then\n', '        elseif result == 1 then\n'),
    # Emblem out for now: the texts go up, right under the top bar.
    ('    call ShowUnit(Ronda_Icono[p], shown)\n', '    call ShowUnit(Ronda_Icono[p], false)\n'),
    ('        call HealthBars__Place(Ronda_Icono[p] , cam , Ronda_ICONO_X , Ronda_ICONO_Y , 402.)\n', ''),
    ('constant real Ronda_TITULO_Y = 88.\n', 'constant real Ronda_TITULO_Y = 58.\n'),
    ('constant real Ronda_CIFRA_Y = 116.\n', 'constant real Ronda_CIFRA_Y = 84.\n'),
    # v12s cut the alliance of owners 8 to 11 among themselves too.
    ('            // Only the 8 player slots: 8 to 11 own wave units, which must stay hostile.\n            if i != j and i < 8 and j < 8 then\n',
     '            // Players with players, wave owners 8 to 11 with each other; both sides stay hostile.\n            if i != j and (i < 8) == (j < 8) then\n'),
)

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
    for old, new in CAMBIOS:
        s = base.once(s, old, new)
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok')
