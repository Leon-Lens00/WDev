#!/usr/bin/env python3
"""v22q (23/11/2026): Tauren: el área y la velocidad de la Roca y la velocidad del Bombardeo suben con el tier; la
pasiva lanza a veces una roca.

Leon tras v22p-prueba ("mucho mejor, ahora esta bien"): "con el tauren sun area de su roca tambien subira con los
tier, ya que ahora por defecto tiene area muy alta, tambien subira con los tier la velocidad de las rocas como
velocidad de llegada, como resultado terminaria mas rapido las R pero bien aprovechado, el tauren como pasiva tendra
tambien que de acuerdo al los disparos tendra una poca posibilidad de lanzar una roca".
- Roca (E, x 68): radio 250 + 50 por tier (300 en T1, 550 en T6; antes 540 siempre) guardado en Cop_V; vuelo de
  20 pasos en T1 y 2 menos por tier (10 en T6); los botes siguen al 75 % del vuelo anterior.
- Bombardeo (R, x 63): las mismas 88 rocas en espiral, pero caen 1 + 0,2 por tier sobre T1 veces más deprisa (cada 3
  pasos en T1; el doble en T6: 4 s) y vuelan 17 pasos en T1 y 2 menos por tier (7 en T6). Termina al lanzar la 88.ª.
  La copia anima más deprisa en proporción. Los golpes a un enemigo no cambian (misma base).
- Pasiva del Tauren: cuando salta Disparo encantado, un 25 % de las veces (como mucho una cada 4 s) lanza además una
  roca de la E hacia el blanco, con el tier y el factor de la E (T1 si no la tiene). Así sale en el 1-6 % de los
  impactos según el arma.
- Prueba: registro "pasiva roca" y su línea "enemigo Roca pasiva".
Uso: v22q.py ENTRADA.j SALIDA.j [prueba]   (normal de v22p; prueba de v22p-prueba).
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


cambia('real array Prc_Listo\n', 'real array Prc_Listo\n// v22q: la roca de la pasiva del Tauren, como mucho una cada 4 s.\nreal array Prc_Roca\n')

# 1) Roca: radio por pieza (Cop_V).
cambia('''        call Cop_Anillo(Cop_X[i], Cop_Y[i], 270., 6)
        call Cop_Anillo(Cop_X[i], Cop_Y[i], 500., 10)
        call Cop_Sumar(i, Cop_Area(Cop_P[i], null, 0., Cop_X[i], Cop_Y[i], 540., Cop_D[i]))
''', '''        // v22q: radio según el tier (Cop_V).
        call Cop_Anillo(Cop_X[i], Cop_Y[i], Cop_V[i] / 2., 6)
        call Cop_Anillo(Cop_X[i], Cop_Y[i], Cop_V[i] - 40., 10)
        call Cop_Sumar(i, Cop_Area(Cop_P[i], null, 0., Cop_X[i], Cop_Y[i], Cop_V[i], Cop_D[i]))
''')
cambia('''function Cop_Roca takes nothing returns nothing
    local integer p = Cop_Inicio()
    local integer i
    if p < 0 then
        return
    endif
    call Cop_Punto(150., 1000.)
    call Cop_Gesto(p, 'hCp0', "attack", 30)
    set i = Cop_Nuevo(p, 3)
    if i >= 0 then
        call Cop_Lanzar(i, "Abilities\\\\Weapons\\\\AncientProtectorMissile\\\\AncientProtectorMissile.mdl", 20, 350.)
        call SetUnitScale(Cop_U[i], 3., 3., 3.)
        set Cop_D[i] = 300.
        set Cop_Rest[i] = Cop_LD
    endif
    call Cop_Arrancar()
endfunction
''', '''// v22q: cuerpo de la Roca, desde el botón (Cop_Roca) o desde la pasiva (Prc_Golpe). Área y vuelo según el tier de la E.
function Cop_RocaHacer takes integer p returns nothing
    local integer i
    local integer t
    if p < 0 then
        return
    endif
    set t = IMinBJ(6, IMaxBJ(1, Tec_Niv[p * 200 + 68]))
    call Cop_Punto(150., 1000.)
    call Cop_Gesto(p, 'hCp0', "attack", 30)
    set i = Cop_Nuevo(p, 3)
    if i >= 0 then
        call Cop_Lanzar(i, "Abilities\\\\Weapons\\\\AncientProtectorMissile\\\\AncientProtectorMissile.mdl", 22 - 2 * t, 350.)
        call SetUnitScale(Cop_U[i], 3., 3., 3.)
        set Cop_D[i] = 300.
        set Cop_Rest[i] = Cop_LD
        set Cop_V[i] = 250. + 50. * I2R(t)
    endif
    call Cop_Arrancar()
endfunction

function Cop_Roca takes nothing returns nothing
    call Cop_RocaHacer(Cop_Inicio())
endfunction
''')

# 2) Bombardeo: ritmo (Cop_D, acumulado en Cop_TX) y vuelo (Cop_NT) según el tier; acaba con la 88.ª roca.
cambia('''function Cop_T6 takes integer i returns nothing
    local integer j
    local real a
    local real x
    local real y
    if ModuloInteger(Cop_K[i], 84) == 1 then
        call SetUnitAnimation(Cop_U[i], "attack slam")
    endif
    if ModuloInteger(Cop_K[i], 3) == 0 then
''', '''// v22q: con el tier caen más deprisa (Cop_D rocas por paso, acumuladas en Cop_TX) y vuelan menos (Cop_NT); 88 rocas.
function Cop_T6 takes integer i returns nothing
    local integer j
    local real a
    local real x
    local real y
    if ModuloInteger(Cop_K[i], 84) == 1 then
        call SetUnitAnimation(Cop_U[i], "attack slam")
    endif
    set Cop_TX[i] = Cop_TX[i] + Cop_D[i]
    loop
        exitwhen Cop_TX[i] < 1. or Cop_Gen[i] >= 88
        set Cop_TX[i] = Cop_TX[i] - 1.
''')
cambia('''                set Cop_NT[j] = 17
                set Cop_H[j] = 300.
                set Cop_D[j] = 180.
                call Cop_Proyectil(j, "Abilities\\\\Weapons\\\\AncientProtectorMissile\\\\AncientProtectorMissile.mdl", Cop_X[i], Cop_Y[i], a, 150.)
                call SetUnitScale(Cop_U[j], 3., 3., 3.)
            endif
        endif
    endif
    if Cop_K[i] >= 266 then
''', '''                set Cop_NT[j] = Cop_NT[i]
                set Cop_H[j] = 300.
                set Cop_D[j] = 180.
                call Cop_Proyectil(j, "Abilities\\\\Weapons\\\\AncientProtectorMissile\\\\AncientProtectorMissile.mdl", Cop_X[i], Cop_Y[i], a, 150.)
                call SetUnitScale(Cop_U[j], 3., 3., 3.)
            endif
        endif
    endloop
    if Cop_Gen[i] >= 88 then
''')
cambia('''        call Cop_Unidad(i, 'hCp0', Cop_PX, Cop_PY, Cop_LA)
        call SetUnitTimeScale(Cop_U[i], 0.5)
        set Cop_V[i] = Cop_LA * bj_RADTODEG
        set Cop_Rest[i] = 900.
''', '''        call Cop_Unidad(i, 'hCp0', Cop_PX, Cop_PY, Cop_LA)
        set Cop_V[i] = Cop_LA * bj_RADTODEG
        set Cop_Rest[i] = 900.
        // v22q: T1 una roca cada 3 pasos y vuelo de 17; cada tier +20 % de ritmo y 2 pasos menos de vuelo.
        set Cop_D[i] = (0.8 + 0.2 * I2R(IMinBJ(6, IMaxBJ(1, Tec_Niv[p * 200 + 63])))) / 3.
        set Cop_NT[i] = 19 - 2 * IMinBJ(6, IMaxBJ(1, Tec_Niv[p * 200 + 63]))
        set Cop_TX[i] = 0.001
        call SetUnitTimeScale(Cop_U[i], 1.5 * Cop_D[i])
''')

# 3) Pasiva del Tauren: a veces una roca de la E.
cambia('''        call Enc_Onda(Prc_C, Player(p), Prc_T, Prc_D, Prc_Tipo)
''', '''        call Enc_Onda(Prc_C, Player(p), Prc_T, Prc_D, Prc_Tipo)
        // v22q: un 25 % de las veces (como mucho una cada 4 s) lanza además una roca de la E hacia el blanco.
        if ahora >= Prc_Roca[p] and Cop_N < 190 and GetRandomReal(0., 1.) < 0.25 then
            set Prc_Roca[p] = ahora + 4.
            set Cop_HX = GetUnitX(h)
            set Cop_HY = GetUnitY(h)
            set Cop_PX = GetUnitX(Prc_T)
            set Cop_PY = GetUnitY(Prc_T)
            set Cop_LA = Atan2(Cop_PY - Cop_HY, Cop_PX - Cop_HX)
            set Cop_LD = SquareRoot((Cop_PX - Cop_HX) * (Cop_PX - Cop_HX) + (Cop_PY - Cop_HY) * (Cop_PY - Cop_HY))
            set Cop_Fac = Tec_FacAb(p, 'ATb3')
''' + ('            call Cop_LanNuevo("Roca pasiva")\n' if prueba else '') + '''            call Cop_RocaHacer(p)
            set Cop_Fac = 1.
''' + ('            set Cop_LanAct = 0\n' if prueba else '') + ('            call Dia_Anotar("pasiva roca j" + I2S(p) + " tier " + I2S(Tec_Niv[p * 200 + 68]))\n' if prueba else '')
       + '''        endif
''')
assert src.index('function Cop_RocaHacer') < src.index('function Prc_Golpe')

if prueba:
    assert 'function Cop_Anotar' in src
    cambia('lat\\\\v22p-', 'lat\\\\v22q-', src.count('lat\\\\v22p-'))
    cambia('v22p-don.txt', 'v22q-don.txt', src.count('v22p-don.txt'))
    assert 'lat\\\\v22p-' not in src and 'v22p-don.txt' not in src, 'quedan registros v22p'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22q', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
