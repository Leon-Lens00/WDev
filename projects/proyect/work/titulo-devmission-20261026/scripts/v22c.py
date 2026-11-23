#!/usr/bin/env python3
"""v22c (23/11/2026): la X de Vegeta (y la de Trunks) ya no dejan temblor; la pieza de la carga sigue a Vegeta.

Leon tras v22b-prueba: "se esta repitiendo el problema de las X, que el efecto no sigue al personajes, y que la
trasformacion deja un shake interminable".
- Efecto: G2F_Saian_Bejita crea la pieza h0G1 (Caster[5721]) en el punto de partida y nunca la movía; ahora cada paso
  de la carga (Bejita2, 0,04 s) la pone en Vegeta, como Trunks desde v21x y Goku desde v21h.
- Temblor: la carga llama Gk_SacudeEQ(5) (Sacude_Mag = 10) a todos los cuerpos en 1500 y en 2.1a nunca se quita
  (D.O.N no la limpiaba en esta técnica). Ve_XFin y Tr_XFin (G2F_Saian_Trunks hace lo mismo) quitan ahora la
  sacudida de 10 de todos los jugadores al acabar la carga, como G2_SacudeFin en Goku (v21h).
Registro (sólo prueba): "vegeta X temblor fuera N" / "trunks X temblor fuera N" con el número de jugadores limpiados.
Uso: v22c.py ENTRADA.j SALIDA.j [prueba]   (normal de v22b; prueba de v22b-prueba).
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


# 1) La pieza de la carga sigue a Vegeta.
cambia('''set G2V_Int[5722]=(G2V_Int[5722]+1)
set G2V_Point[5720]=GetUnitLoc(G2V_Caster[5720])
''', '''set G2V_Int[5722]=(G2V_Int[5722]+1)
// v22c: la pieza de la carga sigue a Vegeta (v21x en Trunks).
if G2V_Caster[5721]!=null then
call SetUnitX(G2V_Caster[5721],GetUnitX(G2V_Caster[5720]))
call SetUnitY(G2V_Caster[5721],GetUnitY(G2V_Caster[5720]))
endif
set G2V_Point[5720]=GetUnitLoc(G2V_Caster[5720])
''')

# 2) Quitar la sacudida de la carga (2 x 5) al acabarla, en Vegeta y en Trunks.
ayuda = '''// v22c: la carga de la X (Vegeta, Trunks) pone Gk_SacudeEQ(5) = 10 a los cuerpos cercanos y 2.1a nunca la quita.
// Se quita al acabar la carga sólo donde sigue siendo la de la X (otra técnica pudo poner la suya después).
function Gk_SacudeFinX takes nothing returns integer
    local integer j = 0
    local integer n = 0
    loop
        exitwhen j >= 12
        if Sacude_Mag[j] == 10. then
            set Sacude_Mag[j] = 0.
            set n = n + 1
        endif
        set j = j + 1
    endloop
    return n
endfunction

'''
cambia('function Gk_TT takes string s, unit u,', ayuda + 'function Gk_TT takes string s, unit u,')

for quien, fin in (('vegeta', 'function Ve_XFin takes nothing returns nothing\n    local unit b = G2V_Caster[5720]\n'),
                   ('trunks', 'function Tr_XFin takes nothing returns nothing\n    local unit b = G2V_Caster[$CEE]\n')):
    i = src.index(U(fin))
    j = src.index('    call DestroyTimer(GetExpiredTimer())\n', i)
    assert j - i < 2500, quien
    if prueba:
        poner = ('    set Cop_Log = "' + quien + ' X temblor fuera " + I2S(Gk_SacudeFinX())\n'
                 '    call ExecuteFunc("Cop_Anotar")\n')
    else:
        poner = '    call Gk_SacudeFinX()\n'
    src = src[:j] + poner + src[j:]

if prueba:
    assert 'set Cop_Log = ' in src and 'function Cop_Anotar' in src, 'Cop_Anotar en prueba'
    cambia('lat\\\\v22b-', 'lat\\\\v22c-', src.count('lat\\\\v22b-'))
    cambia('v22b-don.txt', 'v22c-don.txt', src.count('v22b-don.txt'))
    assert 'lat\\\\v22b-' not in src and 'v22b-don.txt' not in src, 'quedan registros v22b'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22c', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
