#!/usr/bin/env python3
"""v14zt (07/11/2026): en las capturas de Leon de v14zs el retrato de la tarjeta asomaba por los lados de su cuadro.
- Cuadro del retrato más ancho (66 × 56 px, centro cx + 170,6) y un marco 'uidb' aparte ('DS19', RachaMarco.blp de
  tarjeta_v14zt.py) DELANTE del retrato (a 397, el retrato a 398), con una ventana de 48 × 44 px: tapa sus bordes.
- Retrato de 50 px de alto (antes 44), para que llene la ventana; el texto se centra en el cuadro del texto, que se
  acorta (cx − 36,4).
Uso: v14zt.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'real Racha_Y= 76.\n', 'real Racha_Y= 76.\nunit array Racha_Marco\n')
s = base.once(s, "            call Racha_Foto(Racha_Caja[p * 5 + i] , 410. , 56. , 'DS18')\n",
              """            call Racha_Foto(Racha_Caja[p * 5 + i] , 410. , 56. , 'DS18')
            set Racha_Marco[p * 5 + i] = HealthBars__Dummy('uidb', p)
            call UnitAddAbility(Racha_Marco[p * 5 + i], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(Racha_Marco[p * 5 + i], s__Interface_LOCUST_ID)
            call Racha_Foto(Racha_Marco[p * 5 + i] , 66. , 56. , 'DS19')
""")
s = base.once(s, '        call ShowUnit(Racha_Caja[v], vis)\n', '        call ShowUnit(Racha_Caja[v], vis)\n        call ShowUnit(Racha_Marco[v], vis)\n')
s = base.once(s, '                set e = 44. * ', '                set e = 50. * ')
s = base.once(s, '            call HealthBars__Place(Racha_Cara[v * 2 + j] , cam , cx + 177.8 + Racha_AjX , y + Racha_AjY , 398. + d)\n',
              '''            call HealthBars__Place(Racha_Cara[v * 2 + j] , cam , cx + 170.6 + Racha_AjX , y + Racha_AjY , 398. + d)
            call HealthBars__Place(Racha_Marco[v] , cam , cx + 170.6 , y , 397. + d)
''')
assert s.count('( cx - 28.4 - ') == 2
s = s.replace('( cx - 28.4 - ', '( cx - 36.4 - ')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
