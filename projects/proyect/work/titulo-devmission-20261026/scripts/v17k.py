#!/usr/bin/env python3
"""v17k (14/11/2026): ajustes de la presentación del jefe tras la prueba de v17j.

Leon: "mejoremos ese apartado, en caso que subas mas oscuridad al fondo, seria tambien aplicar el nuevo color a los
textag" (banda del nombre, salto del Snarecaster, nombres largos pequeños y fondo más oscuro, evaluados en su prueba).
- Fondo al 80 % (alfa 205, antes 165) y los textos y barras con ese mismo tapado: f = 205 / 255 = 0,804 (antes 0,647).
- Banda del nombre de 1210 × 110 px (antes 1100 × 100), con el centro 50 px a la derecha del nombre: empieza un poco a
  su izquierda y cruza hasta pasado el centro de la pantalla, como en el vídeo (textura en recursos_v17k.py).
- Mur'gul Snarecaster (ronda 5) al 75 % con el pie en el mismo sitio: su ataque salta unos 270 px sobre la pose de
  reposo y se le cortaba la cabeza arriba (medido en el vídeo de v17j).
Uso: v17k.py v17j/war3map.j SALIDA.j (y v17j-prueba/war3map.j para la de prueba)
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(antes), crlf(despues)
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


una('    set JefeTx_F = 0.647 * lv / 8.\n', '    set JefeTx_F = 0.804 * lv / 8.\n')
una('    call JefePres_Alfa(p, JefePres_Pieza[b], R2I(165. * vis), false)\n',
    '    call JefePres_Alfa(p, JefePres_Pieza[b], R2I(205. * vis), false)\n')
una("            set JefePres_Pieza[b + 1] = JefePres_Dummy('uidg', 'DP02', 1100., 100., 222., 270.)\n",
    "            set JefePres_Pieza[b + 1] = JefePres_Dummy('uidg', 'DP02', 1210., 110., 222., 270.)\n")
una('    call HealthBars__Place(JefePres_Pieza[b + 1], cam, x - 22., 418., 222.)\n',
    '    call HealthBars__Place(JefePres_Pieza[b + 1], cam, x + 50., 418., 222.)\n')
una('    set JefePres_Escala[5] = 1.1375\n    set JefePres_OX[5] = 35.5\n',
    '    set JefePres_Escala[5] = 0.8531\n    set JefePres_OX[5] = 26.6\n')
una('// v17h: presentación del jefe de ronda (scripts/v17h.py); v17j (scripts/v17j.py)',
    '// v17h: presentación del jefe de ronda (scripts/v17h.py); v17k (scripts/v17k.py): fondo al 80 %, banda larga,\n'
    '// Snarecaster al 75 %; v17j (scripts/v17j.py)')
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17k: fondo, banda y Snarecaster')
