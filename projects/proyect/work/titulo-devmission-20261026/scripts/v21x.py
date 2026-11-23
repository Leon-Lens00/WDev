#!/usr/bin/env python3
"""v21x (22/11/2026): el efecto de la transformación de Trunks le sigue, como el de Goku (v21h).
Leon jugó v21w-prueba: "al igual que goku hace falta que el efecto especial de transformación siga a trunks".
En D.O.N (G2F_Saian_Trunks) las dos auras se ponían en el suelo (AddSpecialEffectLocBJ) y la pieza h0G1 quedaba en el
punto de inicio. Ahora las auras cuelgan del origen del cuerpo y la pieza se mueve con él en cada paso de la carga
(G2F_Saian_Trunks2, 0,04 s). Por muertes no hay pieza (null): no se mueve nada.
Uso: v21x.py ENTRADA.j SALIDA.j [prueba]   (normal de v21w; prueba de v21w-prueba).
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


cambia('''call AddSpecialEffectLocBJ(G2V_Point[5630],"war3mapImported\\\\BitchAura.mdx")
set G2V_Effect[5630]=bj_lastCreatedEffect
call AddSpecialEffectLocBJ(G2V_Point[5630],"war3mapImported\\\\SaianAura.mdx")
set G2V_Effect[5631]=bj_lastCreatedEffect
''', '''// v21x: las auras siguen a Trunks, como las de Goku.
call AddSpecialEffectTargetUnitBJ("origin",G2V_Caster[$CEE],"war3mapImported\\\\BitchAura.mdx")
set G2V_Effect[5630]=bj_lastCreatedEffect
call AddSpecialEffectTargetUnitBJ("origin",G2V_Caster[$CEE],"war3mapImported\\\\SaianAura.mdx")
set G2V_Effect[5631]=bj_lastCreatedEffect
''')
cambia('''set G2V_Int[5637]=(G2V_Int[5637]-1)
set G2V_Int[5632]=(G2V_Int[5632]+1)
''', '''set G2V_Int[5637]=(G2V_Int[5637]-1)
set G2V_Int[5632]=(G2V_Int[5632]+1)
// v21x: la pieza de la carga sigue a Trunks (v21h en Goku).
if G2V_Caster[5630]!=null then
call SetUnitX(G2V_Caster[5630],GetUnitX(G2V_Caster[$CEE]))
call SetUnitY(G2V_Caster[5630],GetUnitY(G2V_Caster[$CEE]))
endif
''')
if prueba:
    cambia('lat\\\\v21w-', 'lat\\\\v21x-', src.count('lat\\\\v21w-'))
    cambia('v21w-don.txt', 'v21x-don.txt', src.count('v21w-don.txt'))
    assert 'lat\\\\v21w-' not in src and 'v21w-don.txt' not in src, 'quedan registros v21w'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21x', 'prueba' if prueba else 'normal')
