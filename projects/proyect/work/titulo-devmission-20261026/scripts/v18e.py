#!/usr/bin/env python3
"""v18e (15/11/2026): sobre v18d, a petición de Leon tras probar v18d-prueba.

- El multiplicador de vida y daño de las élites también se baraja, con sumas más grandes: el real es la base de la
  ronda (1,25 + 0,05 por ronda) más 0,05 × (0..12), es decir hasta +0,60, con tope ×3. Cada uno de los 12 cambios de
  la tirada muestra en la cabecera un multiplicador al azar del mismo rango (Sup_RM, sorteado en código común: igual
  para todos); el 13.º fija el real.
- Élites al 35 % de la vida del jefe de la ronda (Leon: "sumemos 15%"; creía que estaban al 20 %). La fórmula vieja
  tomaba 0,20 × 800 × (1 + 0,75 (r − 1)) − 160 sobre la base 320 del w3u, que es el 11-16 % del jefe real
  (w3u: nj02 2800 … nj0A 12400 = 400 + 1200 r, con un jugador). Ahora 0,35 × (400 + 1200 r): 980 en la ronda 2,
  4340 en la 10. Las 'ALh0'..'ALhA' (11 bits de 10) llegan a 20470: sobra.
Prueba: registros en lat\\v18e-*.txt.
Uso: v18e.py v18d/war3map.j SALIDA.j [prueba]
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
u8 = lambda s: s.encode('utf-8').decode('latin-1')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(u8(antes)), crlf(u8(despues))
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


MULT = 'RMinBJ(3., 1.25 + 0.05 * (r - 1) + 0.05 * GetRandomInt(0, 12))'

una('hashtable Sup_HT = InitHashtable()\n', 'hashtable Sup_HT = InitHashtable()\nreal array Sup_RM\n')

# Multiplicador real con suma al azar.
una('    set Sup_M[i] = RMinBJ(2.25, 1.25 + 0.05 * (r - 1))\n', f'''    // v18e: base de la ronda más una suma al azar de 0 a 0,60 (tope ×3).
    set Sup_M[i] = {MULT}
''')
# Multiplicadores de los 12 cambios de la tirada.
una('''        exitwhen b > 11
        set t = GetRandomInt(0, 6)
        set Sup_RT[i * 48 + b * 4] = t
''', f'''        exitwhen b > 11
        set Sup_RM[i * 12 + b] = {MULT}
        set t = GetRandomInt(0, 6)
        set Sup_RT[i * 48 + b * 4] = t
''')
# La cabecera cambia con cada cambio de la tirada.
una('''function Sup_Barajar takes integer p, boolean fin returns nothing
    local integer i = Sup_Mio[p]
    local integer k = 0
    local integer t
    local integer v
''', '''function Sup_Barajar takes integer p, boolean fin returns nothing
    local integer i = Sup_Mio[p]
    local integer k = 0
    local integer t
    local integer v
    local real m = Sup_M[i]
    // v18e: el multiplicador también se baraja (Sup_RM, sorteado en Sup_Crear); el último cambio fija el real.
    if not fin then
        set m = Sup_RM[i * 12 + Sup_Tiro[p] - 1]
    endif
    call Sup_Texto(Sup_TT[p * 5], "Élites: vida y daño ×" + R2SW(m, 1, 2), 30. - 420., 296., 0.017)
''')

# Élites: al 35 % de la vida del jefe de la ronda (el comentario viejo decía 0,40 y no casaba con el código).
una("// Vida de élite 0,40 × 800 × (1 + 0,75 (r − 1)), sin jugadores (sale una por jugador): base 320 del w3u",
    "// Vida de élite (v18e) 0,35 × (400 + 1200 r), la del jefe de la ronda, sin jugadores (sale una por jugador): base 320 del w3u")
una('        set n=R2I(( 0.20 * I2R(R2I(800. * ( 1. + 0.75 * ( Ronda_Numero - 1 ) ) + 0.5)) - 160. ) / 10. + 0.5)\n',
    '''        // v18e: 35 % de la vida del jefe de la ronda (w3u: 400 + 1200 r con un jugador) sobre la base 320, a petición
        // de Leon. Antes 0,20 × 800 × (1 + 0,75 (r − 1)) − 160, que daba el 11-16 % del jefe.
        set n=R2I(( 0.35 * ( 400. + 1200. * Ronda_Numero ) - 320. ) / 10. + 0.5)
''')

if prueba:
    for n in ('super', 'precarga', 'cuadros'):
        una(f'call PreloadGenEnd("lat\\\\v18d-{n}.txt")', f'call PreloadGenEnd("lat\\\\v18e-{n}.txt")')
    assert 'lat\\\\v18d-' not in j
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v18e: multiplicador barajado con suma al azar, élites al 35 % del jefe' + (' + registro' if prueba else ''))
