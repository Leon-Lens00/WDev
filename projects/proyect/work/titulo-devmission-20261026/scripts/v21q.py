#!/usr/bin/env python3
"""v21q (22/11/2026): Golden Form de Freezer con tiers T1-T6, como las demás técnicas.

Leon: "agregemosle tier tambien a la trasformacion golden para que haga buen danio al tier maximo".
- Explosión al transformarse: daño de tier en 600 alrededor (Fz_Area), T6 4350 por enemigo (cargador y medio rojo, entre
  la Q 2900 y la R 5800). Antes: 6 x fuerza en 500.
- Bono de armas mientras dura: 0,75 x curva del tier (T1 19 %, T2 26 %, T3 34 %, T4 45 %, T5 60 %, T6 75 %). Antes: 25 %
  por nivel de A0OH.
- Libro: Tec 50 con Tec_Max 6 y Tec_T6 4350 (cartas con color de tier y rondas de las armas); el nivel real de A0OH sigue
  hasta 3 (Tec_Tope), que es lo que usan A06T y A0G4.
Prueba: registro "freezer dano T" (Gk_Suma 8); -gt N ya incluye Golden.
Uso: v21q.py ENTRADA.j SALIDA.j [prueba]   (normal de v21p; prueba de v21p-prueba).
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


cambia('''set G2V_Damage2[7190]=(6*Gk_Fuerza(G2V_Caster[7190]))
set G2V_Group[7190]=GetUnitsInRangeOfLocMatching(500.,G2V_Point[7190],Condition(function G2F_Frieza_Golden_Transformation_Func014002003))
call ForGroupBJ(G2V_Group[7190],function G2F_Frieza_Golden_Transformation_Func015A)
call DestroyGroup(G2V_Group[7190])
''', '''// v21q: explosión de la transformación con tier (T6 4350 por enemigo, en 600).
call Fz_Area(fzc,GetLocationX(G2V_Point[7190]),GetLocationY(G2V_Point[7190]),600.,Gk_TDano(fzc,50,4350.),null,8,50)
''')
cambia("set Fz_Bono[fzp]=.25*I2R(GetUnitAbilityLevel(fzc,'A0OH'))\n",
       "// v21q: bono por tier, T6 +75 %.\n"
       "set Fz_Bono[fzp]=.75*Tec_Curva[IMinBJ(6,IMaxBJ(1,Tec_Niv[fzp*100+50]))]\n")
cambia('    set Tec_Max[50] = 3\n    set Tec_Tope[50] = 3\n',
       '    set Tec_Max[50] = 6\n    set Tec_Tope[50] = 3\n    set Tec_T6[50] = 4350.0\n')
cambia('    set Cua_Des[50] = "Forma dorada 35 s.|n+25 % de daño de armas por nivel."\n',
       '    set Cua_Des[50] = "Forma dorada 35 s: explota al transformarse|ny las armas hacen hasta +75 % en T6."\n')
if prueba:
    cambia('        set n = SubString("QWERX", s - 3, s - 2)\n', '        set n = SubString("QWERXT", s - 3, s - 2)\n')
    cambia('lat\\\\v21p-', 'lat\\\\v21q-', src.count('lat\\\\v21p-'))
    cambia('v21p-don.txt', 'v21q-don.txt', src.count('v21p-don.txt'))
    assert 'lat\\\\v21p-' not in src and 'v21p-don.txt' not in src, 'quedan registros v21p'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21q', 'prueba' if prueba else 'normal')
