#!/usr/bin/env python3
"""v17n (14/11/2026): barra del jefe con porcentaje, de derecha a izquierda y tapada; vida de las oleadas ×2.

Leon tras probar v17m: "hace falta colocar su porcentaje en la zona de debajo de la barra, adicional la barra debe crecer
de derecha hacia la izquierda ... necesitamos ajustar la vidas de las unidades y boss y elites un adicional mas".
- Porcentaje bajo el icono del jefe, en espejo del de la barra del jugador (centro del icono 1853 px; el del jugador
  queda 17,8 px a la derecha de su icono): también mientras se carga.
- Relleno de derecha a izquierda: modelos de jefe_barras_v17n.py.
- La barra del jefe se oscurece con la presentación como las del jugador (en v17m quedaba brillante si coincidían).
- La vida de las oleadas va ×2 (objetos_v17n.py); el oro por muerte, que sale de la vida máxima / 5, pasa a / 10 para
  dar lo mismo que antes.
Uso: v17n.py v17m/war3map.j SALIDA.j (y v17m-prueba/war3map.j para la de prueba)
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


una('''    if JefeBarra_Estado >= 2 and JefeBarra_Visto then
        set pct = HealthBars__Percent(DevJefe)
        set label = I2S(pct) + "%"
    endif
''', '''    if JefeBarra_Estado >= 2 and JefeBarra_Visto then
        set pct = HealthBars__Percent(DevJefe)
    endif
    set label = I2S(pct) + "%"
''')
una('(1837.2 + dx - I2R(StringLength(label)) * 4.5 - 960.) / 728.', '(1870.8 + dx - I2R(StringLength(label)) * 4.5 - 960.) / 728.')
una('''            if HealthBars__EnemyBars[i] != null then
                call SetUnitVertexColor(HealthBars__EnemyBars[i], R2I(255. * (1. - JefeTx_F) + 11. * JefeTx_F), R2I(255. * (1. - JefeTx_F) + 16. * JefeTx_F), R2I(255. * (1. - JefeTx_F) + 34. * JefeTx_F), 255)
            endif
''', '''            if HealthBars__EnemyBars[i] != null then
                call SetUnitVertexColor(HealthBars__EnemyBars[i], R2I(255. * (1. - JefeTx_F) + 11. * JefeTx_F), R2I(255. * (1. - JefeTx_F) + 16. * JefeTx_F), R2I(255. * (1. - JefeTx_F) + 34. * JefeTx_F), 255)
            endif
            // v17n: la barra del jefe también.
            if JefeBarra_Pieza[i] != null then
                call SetUnitVertexColor(JefeBarra_Pieza[i], R2I(255. * (1. - JefeTx_F) + 11. * JefeTx_F), R2I(255. * (1. - JefeTx_F) + 16. * JefeTx_F), R2I(255. * (1. - JefeTx_F) + 34. * JefeTx_F), 255)
            endif
''')
una('''            call Oro_Dar(k, IMaxBJ(3, R2I(GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) / 5.)) * (2 + Ronda_Numero) / 3)
''', '''            // v17n: la vida de las oleadas va ×2 (objetos_v17n.py); / 10 da el mismo oro que antes.
            call Oro_Dar(k, IMaxBJ(3, R2I(GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) / 10.)) * (2 + Ronda_Numero) / 3)
''')
una('// v17h: presentación del jefe de ronda (scripts/v17h.py); v17m',
    '// v17h: presentación del jefe de ronda (scripts/v17h.py); v17n (scripts/v17n.py): porcentaje y relleno a la izquierda\n// en la barra del jefe, tapada con el fondo; v17m')
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17n: barra del jefe y vida ×2')
