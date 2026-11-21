#!/usr/bin/env python3
"""v14zv (07/11/2026): con las capturas de Leon de v14zt, la tarjeta de la izquierda se veía bien pero en la de la
derecha el retrato tapaba las líneas del marco: con sólo 1 unidad entre marco (397) y retrato (398) el orden de dibujo no
es seguro. El marco pasa a 390 (8 unidades delante) con su tamaño compensado (× 390/400), y se vuelve a las medidas de
v14zt, que se vieron bien: marco de 66 × 56 en cx + 170,6 y texto en cx − 36,4 (texturas de racha-v14zt).
Uso: v14zv.py ENTRADA.j SALIDA.j   (ENTRADA: el j de v14zu)
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, "Racha_Foto(Racha_Marco[p * 5 + i] , 80. , 56. , 'DS19')",
              "Racha_Foto(Racha_Marco[p * 5 + i] , 66. * 390. / 400. , 56. * 390. / 400. , 'DS19')")
s = base.once(s, 'call HealthBars__Place(Racha_Marco[v] , cam , cx + 163. , y , 397. + d)',
              'call HealthBars__Place(Racha_Marco[v] , cam , cx + 170.6 , y , 390. + d)')
assert s.count('cx + 163.') == 1 and s.count('( cx - 44.4 - ') == 2
s = s.replace('cx + 163.', 'cx + 170.6').replace('( cx - 44.4 - ', '( cx - 36.4 - ')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
