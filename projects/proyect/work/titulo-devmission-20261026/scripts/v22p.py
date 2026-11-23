#!/usr/bin/env python3
"""v22p (23/11/2026): la Estampida crece con el tier (más filas, área más grande y kodos más rápidos); bases de
Guardianes y Estampida según el registro de v22o-prueba.

Leon tras v22o-prueba: "vale se ve bien, con la subida de tier agregara mas filas lo que hara el area mas grande
tambien, como aumentar su velocidad tambien".
- Ancho del anillo de kodos: 400 + 100 por tier sobre T1 (radio 250 a 650 en T1, a 1150 en T6).
- Kodos: 23 × ancho / 400 (23 en T1, 52 en T6), repartidos por igual en el tiempo de salida; así la densidad de kodos
  por fila y los golpes a un enemigo quedan como en T1 (la base no cambia con el tier).
- Velocidad: vuelta completa en 90 pasos en T1 y 6 menos por tier (60 en T6, 1,8 s); los kodos salen hasta 8 s menos
  una vuelta, así el último sigue acabando a los 8 s.
- Bases (registro "enemigo" de v22o-prueba, Cairne en T1): Espíritus guardianes 250 -> 750 (las 3 copias salen juntas
  y golpean al mismo enemigo: 750 en los 4 casos); Estampida 3600 -> 3000 (máximos 2159-3059 con enemigos que
  aguantan dentro).
Uso: v22p.py ENTRADA.j SALIDA.j [prueba]   (normal de v22o; prueba de v22o-prueba).
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


# 1) Generador: H = ancho del anillo, NT = pasos de una vuelta, V = kodos por paso, Rest = acumulado.
cambia('''// 15 Estampida (v22o, circular): 8 s; cada 8 pasos (hasta el 177) un kodo a 250-650 del centro (SX, SY) que da una
// vuelta completa en 90 pasos (tipo 17); el último acaba a los 8 s.
function Cop_T15 takes integer i returns nothing
    local integer j
    local real f
    local real r
    local real x
    local real y
    if ModuloInteger(Cop_K[i], 8) == 1 and Cop_K[i] <= 177 then
        set f = GetRandomReal(0., 2. * bj_PI)
        set r = GetRandomReal(250., 650.)
''', '''// 15 Estampida (v22o, circular): 8 s; kodos a 250..250+H del centro (SX, SY) que dan una vuelta completa en NT pasos
// (tipo 17). v22p: H, NT y el ritmo V (kodos por paso, acumulados en Rest) según el tier; salen hasta 267 - NT, así
// el último acaba a los 8 s.
function Cop_T15 takes integer i returns nothing
    local integer j
    local real f
    local real r
    local real x
    local real y
    if Cop_K[i] <= 267 - Cop_NT[i] then
        set Cop_Rest[i] = Cop_Rest[i] + Cop_V[i]
    endif
    loop
        exitwhen Cop_Rest[i] < 1.
        set Cop_Rest[i] = Cop_Rest[i] - 1.
        set f = GetRandomReal(0., 2. * bj_PI)
        set r = GetRandomReal(250., 250. + Cop_H[i])
''')
cambia('''                set Cop_V[j] = 2. * bj_PI / 90.
                set Cop_NT[j] = 90
''', '''                set Cop_V[j] = 2. * bj_PI / I2R(Cop_NT[i])
                set Cop_NT[j] = Cop_NT[i]
''')
cambia('''                call Cop_Proyectil(j, "Abilities\\\\Spells\\\\Other\\\\Stampede\\\\StampedeMissile.mdl", x, y, f + bj_PI / 2., 0.)
            endif
        endif
    endif
    if Cop_K[i] >= 178 then
        call Cop_Quitar(i)
    endif
endfunction
''', '''                call Cop_Proyectil(j, "Abilities\\\\Spells\\\\Other\\\\Stampede\\\\StampedeMissile.mdl", x, y, f + bj_PI / 2., 0.)
            endif
        endif
    endloop
    if Cop_K[i] > 267 - Cop_NT[i] then
        call Cop_Quitar(i)
    endif
endfunction
''')

# 2) Lanzador: parámetros según el tier de la Estampida (x 70).
cambia('''function Cop_Estampida takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    // v22o: los kodos rodean el punto (hasta 900).
    call Cop_Punto(0., 900.)
    call Cop_Gesto(p, 'hCp1', "stand victory", 40)
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\NightElf\\\\BattleRoar\\\\RoarCaster.mdl", Cop_PX, Cop_PY))
    call Cop_Anillo(Cop_PX, Cop_PY, 650., 14)
    set i = Cop_Nuevo(p, 15)
    if i >= 0 then
''', '''function Cop_Estampida takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    local integer t
    local real w
    if p < 0 then
        return
    endif
    // v22p: con el tier, más filas (anillo 400 + 100 por tier), más kodos (23 por cada 400 de ancho) y más rápidos.
    set t = IMinBJ(6, IMaxBJ(1, Tec_Niv[p * 200 + 70]))
    set w = 300. + 100. * I2R(t)
    // v22o: los kodos rodean el punto (hasta 900).
    call Cop_Punto(0., 900.)
    call Cop_Gesto(p, 'hCp1', "stand victory", 40)
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\NightElf\\\\BattleRoar\\\\RoarCaster.mdl", Cop_PX, Cop_PY))
    call Cop_Anillo(Cop_PX, Cop_PY, 250. + w, 12 + 2 * t)
    set i = Cop_Nuevo(p, 15)
    if i >= 0 then
        set Cop_H[i] = w
        set Cop_NT[i] = 96 - 6 * t
        set Cop_V[i] = 23. * w / 400. / I2R(268 - Cop_NT[i])
        set Cop_Rest[i] = 1.
''')

# 3) Bases medidas.
cambia('    set Tec_Base[70] = 3600.\n', '    set Tec_Base[70] = 3000.\n')
cambia('    set Tec_Base[76] = 250.\n', '    // v22p: las 3 copias golpean juntas al enemigo de al lado (750 en v22o-prueba).\n    set Tec_Base[76] = 750.\n')

if prueba:
    assert 'function Cop_Anotar' in src
    cambia('lat\\\\v22o-', 'lat\\\\v22p-', src.count('lat\\\\v22o-'))
    cambia('v22o-don.txt', 'v22p-don.txt', src.count('v22o-don.txt'))
    assert 'lat\\\\v22o-' not in src and 'v22o-don.txt' not in src, 'quedan registros v22o'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22p', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
