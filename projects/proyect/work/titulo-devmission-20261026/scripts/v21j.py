#!/usr/bin/env python3
"""v21j (22/11/2026): el rayo del Kamehameha y de la Super Kamehameha no cruza árboles ni pendientes.

Leon: "me parece el kameha traspasa arboles". La cabeza sí se frena (Don_Pon traza el paso y la deja en el choque),
pero el cuerpo del rayo (h00D/h00F) se creaba antes, en el punto sin corregir: en el Kamehameha ese punto es el origen
+ 55 x tick, así que el rayo seguía alargándose detrás del árbol mientras la cabeza quedaba quieta. En la Super
Kamehameha (R en SSJ) el punto es la cabeza + 50, y sobresalía 50.
Ahora la cabeza se mueve primero y, si chocó (Don_Choco, que fija Don_Pon), no se añade tramo de rayo. La regla de
choque sigue igual: la técnica se queda en el punto del choque hasta su tiempo y explota.
Uso: v21j.py ENTRADA.j SALIDA.j [prueba]   (normal de v21i; prueba de v21i-prueba).
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


cambia('''real array Kai_Bono
''', '''real array Kai_Bono
boolean Don_Choco = false
''')
cambia('''        if dx * dx + dy * dy <= 160000. and s__GroundCollision_trace(''', '''        set Don_Choco = false
        if dx * dx + dy * dy <= 160000. and s__GroundCollision_trace(''')
cambia('''            call MoveLocation(L, s__GroundCollision_x, s__GroundCollision_y)
        endif
    endif
    call SetUnitPositionLoc(u, L)''', '''            call MoveLocation(L, s__GroundCollision_x, s__GroundCollision_y)
            // v21j: Don_Choco avisa del choque a quien dibuja el rayo detrás.
            set Don_Choco = true
        endif
    endif
    call SetUnitPositionLoc(u, L)''')

# --- Kamehameha (Q) ---
cambia('''set G2V_Point[7155]=PolarProjectionBJ(G2V_Point[7150],(I2R(G2V_Int[7150])*55.),G2V_Angle[7150])
if(G2F_kamehameha_goku_god2_Func004C())then
call CreateNUnitsAtLoc(1,'h00D',GetOwningPlayer(G2V_QC),G2V_Point[7155],G2V_Angle[7150])
call SetUnitVertexColorBJ(bj_lastCreatedUnit,100.,30.,30.,10.)
else
call CreateNUnitsAtLoc(1,'h00F',GetOwningPlayer(G2V_QC),G2V_Point[7155],G2V_Angle[7150])
call G2_Color(bj_lastCreatedUnit,60.,60.,80.,10.)
endif
call SetUnitScalePercent(bj_lastCreatedUnit,450.,450.,450.)
call GroupAddUnit(G2V_Group3[$EB],bj_lastCreatedUnit)
call Don_Pon(G2V_Caster[7155],G2V_Point[7155])
''', '''set G2V_Point[7155]=PolarProjectionBJ(G2V_Point[7150],(I2R(G2V_Int[7150])*55.),G2V_Angle[7150])
// v21j: primero la cabeza; si choca con árbol o pendiente no se alarga el rayo.
set Don_Choco=false
call Don_Pon(G2V_Caster[7155],G2V_Point[7155])
if not Don_Choco then
if(G2F_kamehameha_goku_god2_Func004C())then
call CreateNUnitsAtLoc(1,'h00D',GetOwningPlayer(G2V_QC),G2V_Point[7155],G2V_Angle[7150])
call SetUnitVertexColorBJ(bj_lastCreatedUnit,100.,30.,30.,10.)
else
call CreateNUnitsAtLoc(1,'h00F',GetOwningPlayer(G2V_QC),G2V_Point[7155],G2V_Angle[7150])
call G2_Color(bj_lastCreatedUnit,60.,60.,80.,10.)
endif
call SetUnitScalePercent(bj_lastCreatedUnit,450.,450.,450.)
call GroupAddUnit(G2V_Group3[$EB],bj_lastCreatedUnit)
endif
''')

# --- Super Kamehameha (R en Super Saiyan) ---
n0 = src.index(U('function G2F_Superkamehameha_goku_god_Actions takes nothing returns nothing\n'))
n1 = src.index('\nendfunction\n', n0)
cuerpo = src[n0:n1]
viejo = 'set G2V_Point[4415]=PolarProjectionBJ(G2V_Point[4416],I2R(G2V_Int[4412]),G2V_Angle[4410])\nif(G2F_Superkamehameha_goku_god_Func009C())then\n'
i = cuerpo.index(viejo)
j = cuerpo.index('call Don_Pon(G2V_Caster[4410],G2V_Point[4410])\ncall Don_Pon(G2V_Caster[4415],G2V_Point[4415])\ncall Don_Pon(G2V_Caster[4416],G2V_Point[4415])\n', i)
dibujo = cuerpo[i + len(viejo) - len('if(G2F_Superkamehameha_goku_god_Func009C())then\n'):j]
assert dibujo.startswith('if(G2F_Superkamehameha_goku_god_Func009C())then\n') and dibujo.count('CreateNUnitsAtLoc') == 2, dibujo
nuevo = ('set G2V_Point[4415]=PolarProjectionBJ(G2V_Point[4416],I2R(G2V_Int[4412]),G2V_Angle[4410])\n'
         '// v21j: primero la cabeza; si choca con árbol o pendiente no se alarga el rayo.\n'
         'set Don_Choco=false\n'
         'call Don_Pon(G2V_Caster[4416],G2V_Point[4415])\n'
         'if not Don_Choco then\n' + dibujo + 'endif\n'
         'call Don_Pon(G2V_Caster[4410],G2V_Point[4410])\n'
         'call Don_Pon(G2V_Caster[4415],G2V_Point[4415])\n')
cuerpo = cuerpo[:i] + nuevo + cuerpo[j + len('call Don_Pon(G2V_Caster[4410],G2V_Point[4410])\ncall Don_Pon(G2V_Caster[4415],G2V_Point[4415])\ncall Don_Pon(G2V_Caster[4416],G2V_Point[4415])\n'):]
src = src[:n0] + cuerpo + src[n1:]

if prueba:
    cambia('lat\\\\v21i-', 'lat\\\\v21j-', src.count('lat\\\\v21i-'))
    cambia('v21i-don.txt', 'v21j-don.txt', src.count('v21i-don.txt'))
assert not prueba or ('lat\\\\v21i-' not in src and 'v21i-don.txt' not in src), 'quedan registros v21i'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21j', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
