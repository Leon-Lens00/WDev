#!/usr/bin/env python3
"""v21r (22/11/2026): regla de área para Goku.

Leon: "pasala a area" (regla: las técnicas que eligen un blanco al explotar o al hacer daño deben dañar en área para que
ayuden en las oleadas). Revisión de v21q: Kamehameha (400 en la punta), Ultimate/Homing (300), Super Kamehameha (400),
Ultra Instinct (400/700) y el Spirit Final (1000) ya dañan a todos los del radio. Elegían un solo enemigo:
- Warp Kamehameha (W): 20 golpes, cada uno a un enemigo al azar en 450 sin repetir. Ahora cada golpe hace el daño de
  tier en 250 alrededor de ese enemigo; cada enemigo sigue recibiendo el golpe una sola vez por lanzamiento.
- Dragon Fist (R, Ultimate): cada 0,04 s un enemigo al azar en 400 sin repetir. Ahora cada puñetazo hace su daño en 200
  alrededor de ese enemigo, también una vez por enemigo.
Prueba: Fz_Area suma en el registro de Goku (W ranura 1, R ranura 2) como antes; registros lat\\v21r-*.
Uso: v21r.py ENTRADA.j SALIDA.j [prueba]   (normal de v21q; prueba de v21q-prueba).
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


suma_w = 'call Gk_Suma(1,42,G2V_Caster[5850],G2V_Caster[5855],I2R(G2V_Damage2[5850]))\n' if prueba else ''
cambia('call UnitDamageTargetBJ(G2V_Caster[5850],G2V_Caster[5855],I2R(G2V_Damage2[5850]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n'
       + suma_w,
       '// v21r: golpe en área (250) alrededor del enemigo elegido, una vez por enemigo.\n'
       'call Fz_Area(G2V_Caster[5850],GetUnitX(G2V_Caster[5855]),GetUnitY(G2V_Caster[5855]),250.,I2R(G2V_Damage2[5850]),G2V_Group3[56],1,42)\n')
suma_r = 'call Gk_Suma(2,40,G2V_Caster[4410],GetEnumUnit(),I2R(G2V_Damage[4410]))\n' if prueba else ''
cambia('function G2F_DragonFist2_Func005A takes nothing returns nothing\n'
       'call GroupAddUnit(G2V_Group2[43],GetEnumUnit())\n'
       'call UnitDamageTargetBJ(G2V_Caster[4410],GetEnumUnit(),I2R(G2V_Damage[4410]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)\n'
       + suma_r,
       'function G2F_DragonFist2_Func005A takes nothing returns nothing\n'
       '// v21r: puñetazo en área (200) alrededor del enemigo elegido, una vez por enemigo.\n'
       'call Fz_Area(G2V_Caster[4410],GetUnitX(GetEnumUnit()),GetUnitY(GetEnumUnit()),200.,I2R(G2V_Damage[4410]),G2V_Group2[43],2,40)\n')
if prueba:
    cambia('lat\\\\v21q-', 'lat\\\\v21r-', src.count('lat\\\\v21q-'))
    cambia('v21q-don.txt', 'v21r-don.txt', src.count('v21q-don.txt'))
    assert 'lat\\\\v21q-' not in src and 'v21q-don.txt' not in src, 'quedan registros v21q'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21r', 'prueba' if prueba else 'normal')
