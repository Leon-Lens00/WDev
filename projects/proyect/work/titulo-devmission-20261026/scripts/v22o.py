#!/usr/bin/env python3
"""v22o (23/11/2026): técnicas del Tauren y de Cairne con tiers (T1-T6) y Estampida circular de 8 s.

Leon: "hace falta balancea los danios y cartas de las habilidades de nuestro tauren y de Cairne" (aceptó la propuesta:
"si") y "demos un rework a su R, este deberia ser circular ahora, van como rodeando en circulo, debera durar como la
del tauren".
- Tiers como Goku (v21m): Q/W/E/R del Tauren (63, 65, 67, 68) y de Cairne (70, 72, 73, 74) pasan a Tec_Max 6 con
  Tec_T6 (daño máximo a un enemigo por lanzamiento en T6: Q 2900, W 2000, E 2000, R 5800). Marca ancestral (71) y
  Espíritus guardianes (76) son pasivas con tier (1500 en T6), como Death Saucer y Afterimage; Marca empieza en T1 y
  no se muestra en el libro (sigue saliendo sola al acertar con las armas). Disparo encantado y Réplica no cambian.
- Tec_FacAb: factor = Tec_T6 / Tec_Base × Tec_Curva[tier]. Tec_Base es el máximo a un enemigo por lanzamiento con
  factor 1 (calculado del código; se calibra con el registro de la prueba): Bombardeo 5040 (28 piedras de 180 a 500
  del centro), Embestida 800, Tótem 450, Roca 886 (300 y 3 botes al 80 % en 540), Estampida 3600 (unos 20 kodos de
  180), Grieta 250 (más el % de vida, que no escala), Tótem del trueno 1950 (150 y 12 rayos de 150 si hay 3 o
  menos), Espíritu 600, Marca 500, Guardianes 250.
- Cop_Quitar no copiaba Cop_Mul al compactar: una pieza podía quedarse con el factor de otra. Corregido.
- Prc_Golpe y Gua_Tick usan el factor de Marca y de Guardianes (antes 1 fijo en los Guardianes).
- Estampida (ACb4): el centro es el punto (hasta 900). Durante 8 s, cada 8 pasos (hasta el paso 177) sale un kodo en
  un punto al azar a 250-650 del centro y da una vuelta completa (90 pasos, 2,7 s) en sentido antihorario: 180 una
  vez a cada enemigo que toca (120) y lo empuja. El último termina a los 8 s, como el Bombardeo.
- Prueba: registro "enemigo HAB fac F max M golpes G enemigos E base B" al acabar cada lanzamiento (todas sus piezas):
  máximo de daño (antes de Her_Dano) a un mismo enemigo, golpes que recibió, enemigos tocados y base = M / F.
Uso: v22o.py ENTRADA.j SALIDA.j [prueba]   (normal de v22n; prueba de v22n-prueba).
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


# 1) Globales.
cambia('real array Tec_T6\n', 'real array Tec_T6\n// v22o: daño máximo a un enemigo por lanzamiento con factor 1 (Tauren y Cairne).\nreal array Tec_Base\n')
if prueba:
    cambia('real array Cop_Mul\n', '''real array Cop_Mul
// v22o-prueba: lanzamiento de cada pieza y daño por enemigo de cada lanzamiento.
integer Cop_LanAct = 0
integer Cop_LanSig = 0
integer array Cop_Lan
integer array Cop_LanVivos
real array Cop_LanMax
integer array Cop_LanGol
integer array Cop_LanEne
string array Cop_LanNom
real array Cop_LanFac
hashtable Cop_LanH = InitHashtable()
''')

# 2) Prueba: funciones del registro por enemigo (antes de Cop_Area).
if prueba:
    cambia('function Cop_Area takes integer p, group g, real a, real x, real y, real r, real dano returns integer\n', '''// v22o-prueba: nuevo lanzamiento (las piezas que se creen hasta el siguiente son suyas).
function Cop_LanNuevo takes string nom returns nothing
    local integer l = ModuloInteger(Cop_LanSig, 500) + 1
    set Cop_LanSig = l
    call FlushChildHashtable(Cop_LanH, l)
    set Cop_LanVivos[l] = 0
    set Cop_LanMax[l] = 0.
    set Cop_LanGol[l] = 0
    set Cop_LanEne[l] = 0
    set Cop_LanNom[l] = nom
    set Cop_LanFac[l] = Cop_Fac
    set Cop_LanAct = l
endfunction

// v22o-prueba: d (sin Her_Dano) a u en el lanzamiento actual.
function Cop_LanGolpe takes unit u, real d returns nothing
    local integer l = Cop_LanAct
    local integer k
    local real s
    local integer g
    if l <= 0 then
        return
    endif
    set k = GetHandleId(u)
    set s = LoadReal(Cop_LanH, l, k)
    if s <= 0. then
        set Cop_LanEne[l] = Cop_LanEne[l] + 1
    endif
    set s = s + d
    set g = LoadInteger(Cop_LanH, l, -k) + 1
    call SaveReal(Cop_LanH, l, k, s)
    call SaveInteger(Cop_LanH, l, -k, g)
    if s > Cop_LanMax[l] then
        set Cop_LanMax[l] = s
        set Cop_LanGol[l] = g
    endif
endfunction

function Cop_LanFin takes integer l returns nothing
    local real b = 0.
    if Cop_LanFac[l] > 0. then
        set b = Cop_LanMax[l] / Cop_LanFac[l]
    endif
    set Cop_Log = "enemigo " + Cop_LanNom[l] + " fac " + R2S(Cop_LanFac[l]) + " max " + I2S(R2I(Cop_LanMax[l])) + " golpes " + I2S(Cop_LanGol[l]) + " enemigos " + I2S(Cop_LanEne[l]) + " base " + I2S(R2I(b))
    call ExecuteFunc("Cop_Anotar")
    call FlushChildHashtable(Cop_LanH, l)
endfunction

function Cop_Area takes integer p, group g, real a, real x, real y, real r, real dano returns integer
''')
    cambia('''            if d > 0. then
                set d = Her_Dano(p, d)
''', '''            if d > 0. then
                call Cop_LanGolpe(u, d)
                set d = Her_Dano(p, d)
''')
    cambia('            set d = Her_Dano(p, 150. * Cop_Fac)\n', '            call Cop_LanGolpe(u, 150. * Cop_Fac)\n            set d = Her_Dano(p, 150. * Cop_Fac)\n')

# 3) Cop_Nombre: kodo circular.
cambia('''    elseif t == 16 then
        return "corredor"
    endif''', '''    elseif t == 16 then
        return "corredor"
    elseif t == 17 then
        return "kodo"
    endif''')

# 4) Cop_Nuevo / Cop_Quitar: lanzamiento (prueba) y factor al compactar.
if prueba:
    cambia('    set Cop_Mul[i] = Cop_Fac\n    return i\n', '''    set Cop_Mul[i] = Cop_Fac
    set Cop_Lan[i] = Cop_LanAct
    if Cop_LanAct > 0 then
        set Cop_LanVivos[Cop_LanAct] = Cop_LanVivos[Cop_LanAct] + 1
    endif
    return i
''')
    cambia('''        call ExecuteFunc("Cop_Anotar")
    endif
    if Cop_E[i] != null then
        call DestroyEffect(Cop_E[i])
    endif
    if Cop_U[i] != null then
        call RemoveUnit(Cop_U[i])
    endif''', '''        call ExecuteFunc("Cop_Anotar")
    endif
    if Cop_Lan[i] > 0 then
        set Cop_LanVivos[Cop_Lan[i]] = Cop_LanVivos[Cop_Lan[i]] - 1
        if Cop_LanVivos[Cop_Lan[i]] <= 0 then
            call Cop_LanFin(Cop_Lan[i])
        endif
    endif
    if Cop_E[i] != null then
        call DestroyEffect(Cop_E[i])
    endif
    if Cop_U[i] != null then
        call RemoveUnit(Cop_U[i])
    endif''')
cambia('    set Cop_Total[i] = Cop_Total[j]\n    set Cop_SX[i] = Cop_SX[j]\n',
       '    set Cop_Total[i] = Cop_Total[j]\n    // v22o: el factor de la pieza también se mueve al compactar.\n    set Cop_Mul[i] = Cop_Mul[j]\n'
       + ('    set Cop_Lan[i] = Cop_Lan[j]\n' if prueba else '') + '    set Cop_SX[i] = Cop_SX[j]\n')

# 5) Estampida circular: generador (15) y kodo (17).
cambia('''// 15 Estampida: cada 4 pasos un kodo espiritual desde detrás de Cairne (frente de 700), 14 en total.
function Cop_T15 takes integer i returns nothing
    local integer j
    local real off
    local real c = Cos(Cop_A[i])
    local real n = Sin(Cop_A[i])
    local real x
    local real y
    if ModuloInteger(Cop_K[i], 4) == 1 then
        set Cop_Gen[i] = Cop_Gen[i] + 1
        set off = GetRandomReal(-350., 350.)
        set x = Cop_SX[i] - 200. * c - off * n
        set y = Cop_SY[i] - 200. * n + off * c
        if Cop_Dentro(x, y) then
            set j = Cop_Nuevo(Cop_P[i], 16)
            if j >= 0 then
                set Cop_Rest[j] = 1600.
                set Cop_V[j] = 30.
                set Cop_D[j] = 180.
                set Cop_H[j] = 60.
                set Cop_G[j] = CreateGroup()
                call Cop_Proyectil(j, "Abilities\\\\Spells\\\\Other\\\\Stampede\\\\StampedeMissile.mdl", x, y, Cop_A[i], 0.)
            endif
        endif
    endif
    if Cop_Gen[i] >= 14 then
        call Cop_Quitar(i)
    endif
endfunction
''', '''// 15 Estampida (v22o, circular): 8 s; cada 8 pasos (hasta el 177) un kodo a 250-650 del centro (SX, SY) que da una
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
        set x = Cop_SX[i] + r * Cos(f)
        set y = Cop_SY[i] + r * Sin(f)
        if Cop_Dentro(x, y) then
            set j = Cop_Nuevo(Cop_P[i], 17)
            if j >= 0 then
                set Cop_SX[j] = Cop_SX[i]
                set Cop_SY[j] = Cop_SY[i]
                set Cop_H[j] = r
                set Cop_TX[j] = f
                set Cop_V[j] = 2. * bj_PI / 90.
                set Cop_NT[j] = 90
                set Cop_D[j] = 180.
                set Cop_G[j] = CreateGroup()
                call Cop_Proyectil(j, "Abilities\\\\Spells\\\\Other\\\\Stampede\\\\StampedeMissile.mdl", x, y, f + bj_PI / 2., 0.)
            endif
        endif
    endif
    if Cop_K[i] >= 178 then
        call Cop_Quitar(i)
    endif
endfunction
''')
cambia('''function Cop_Tick takes nothing returns nothing
''', '''// v22o: 17 kodo de la Estampida circular: vuelta antihoraria a radio H del centro (SX, SY), ángulo en TX, V por paso;
// D una vez a cada enemigo que toca (120) y lo empuja 40.
function Cop_T17 takes integer i returns nothing
    local real x
    local real y
    set Cop_TX[i] = Cop_TX[i] + Cop_V[i]
    set x = Cop_SX[i] + Cop_H[i] * Cos(Cop_TX[i])
    set y = Cop_SY[i] + Cop_H[i] * Sin(Cop_TX[i])
    if Cop_K[i] > Cop_NT[i] or not Cop_Dentro(x, y) then
        call Cop_Quitar(i)
        return
    endif
    set Cop_X[i] = x
    set Cop_Y[i] = y
    set Cop_A[i] = Cop_TX[i] + bj_PI / 2.
    call SetUnitX(Cop_U[i], x)
    call SetUnitY(Cop_U[i], y)
    call SetUnitFacing(Cop_U[i], Cop_A[i] * bj_RADTODEG)
    call Cop_Opc()
    set Cop_oEmp = 40.
    call Cop_Sumar(i, Cop_Area(Cop_P[i], Cop_G[i], Cop_A[i], x, y, 120., Cop_D[i]))
endfunction

function Cop_Tick takes nothing returns nothing
''')
cambia('''            elseif t == 16 then
                call Cop_T16(i)
            else''', '''            elseif t == 16 then
                call Cop_T16(i)
            elseif t == 17 then
                call Cop_T17(i)
            else''')
if prueba:
    cambia('            set Cop_Fac = Cop_Mul[i]\n', '            set Cop_Fac = Cop_Mul[i]\n            set Cop_LanAct = Cop_Lan[i]\n')
    cambia('    set Cop_Fac = 1.\n    call Cop_EstadosTick()\n', '    set Cop_Fac = 1.\n    set Cop_LanAct = 0\n    call Cop_EstadosTick()\n')
cambia('''    call Cop_Gesto(p, 'hCp1', "stand victory", 40)
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\NightElf\\\\BattleRoar\\\\RoarCaster.mdl", Cop_HX, Cop_HY))
    set i = Cop_Nuevo(p, 15)
    if i >= 0 then
        set Cop_A[i] = Cop_LA
        set Cop_SX[i] = Cop_HX
        set Cop_SY[i] = Cop_HY
    endif
''', '''    // v22o: los kodos rodean el punto (hasta 900).
    call Cop_Punto(0., 900.)
    call Cop_Gesto(p, 'hCp1', "stand victory", 40)
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\NightElf\\\\BattleRoar\\\\RoarCaster.mdl", Cop_PX, Cop_PY))
    call Cop_Anillo(Cop_PX, Cop_PY, 650., 14)
    set i = Cop_Nuevo(p, 15)
    if i >= 0 then
        set Cop_A[i] = Cop_LA
        set Cop_SX[i] = Cop_PX
        set Cop_SY[i] = Cop_PY
        set Cop_X[i] = Cop_PX
        set Cop_Y[i] = Cop_PY
    endif
''')

# 6) Factor por tier.
cambia('''// v19l: factor de daño de la técnica a de Tauren/Cairne según su nivel aprendido (1, 1,3, 1,6).
function Tec_FacAb takes integer p, integer a returns real
    local integer x = 63
    loop
        exitwhen x > 77
        if Tec_Puente[x] == a then
            return 1. + 0.3 * IMaxBJ(0, Tec_Niv[p * 200 + x] - 1)
        endif''', '''// v19l: factor de daño de la técnica a de Tauren/Cairne según su nivel aprendido (1, 1,3, 1,6).
// v22o: con tier, T6 / base × curva del tier (25/35/45/60/80/100 %).
function Tec_FacAb takes integer p, integer a returns real
    local integer x = 63
    loop
        exitwhen x > 77
        if Tec_Puente[x] == a then
            if Tec_T6[x] > 0. and Tec_Base[x] > 0. then
                return Tec_T6[x] / Tec_Base[x] * Tec_Curva[IMinBJ(6, IMaxBJ(1, Tec_Niv[p * 200 + x]))]
            endif
            return 1. + 0.3 * IMaxBJ(0, Tec_Niv[p * 200 + x] - 1)
        endif''')
if prueba:
    cambia('    set Cop_Fac = Tec_FacAb(p, GetSpellAbilityId())\n    return p\n',
           '    set Cop_Fac = Tec_FacAb(p, GetSpellAbilityId())\n    call Cop_LanNuevo(GetObjectName(GetSpellAbilityId()))\n    return p\n')

# 7) Pasivas: Marca (Prc_Golpe) y Guardianes (Gua_Tick) con su factor.
cambia('''        set Cop_Fac = Tec_FacAb(p, 'ACb6')
        call Cop_MarcaHacer(p)
''', '''        set Cop_Fac = Tec_FacAb(p, 'ACb6')
''' + ('        call Cop_LanNuevo("Marca ancestral")\n' if prueba else '') + '''        call Cop_MarcaHacer(p)
        set Cop_Fac = 1.
''' + ('        set Cop_LanAct = 0\n' if prueba else ''))
cambia('''            set Cop_Fac = 1.
            if Gua_Rise[p] then''', '''            // v22o: daño de Espíritus guardianes según su tier.
            set Cop_Fac = Tec_FacAb(p, 'ACbQ')
            if Gua_Rise[p] then''')
if prueba:
    cambia('''    local real a = GetUnitFacing(h) * bj_DEGTORAD
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Orc\\\\AncestralSpirit\\\\AncestralSpiritCaster.mdl", GetUnitX(h), GetUnitY(h)))
''', '''    local real a = GetUnitFacing(h) * bj_DEGTORAD
    call Cop_LanNuevo("Espiritus guardianes")
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Orc\\\\AncestralSpirit\\\\AncestralSpiritCaster.mdl", GetUnitX(h), GetUnitY(h)))
''')

# 8) Libro: Marca ancestral es pasiva y no tiene botón.
cambia('''        elseif x == 59 then
            set v = n > 0 and GetUnitTypeId(Game_Hero[p]) != 'hNaK'
        endif''', '''        elseif x == 59 then
            set v = n > 0 and GetUnitTypeId(Game_Hero[p]) != 'hNaK'
        elseif x == 71 then
            // v22o: Marca ancestral es pasiva con tier (sale al acertar con las armas): sin botón en el libro.
            set v = false
        endif''')

# 9) Tiers de las técnicas (Tec_Init).
T6 = {63: (5800, 5040), 65: (2900, 800), 67: (2000, 450), 68: (2000, 886),
      70: (5800, 3600), 72: (2900, 250), 73: (2000, 1950), 74: (2000, 600)}
for x, (t6, base) in T6.items():
    cambia(f'    set Tec_Max[{x}] = 3\n', f'    set Tec_Max[{x}] = 6\n    set Tec_T6[{x}] = {t6}.\n    set Tec_Base[{x}] = {base}.\n')
cambia('''    set Tec_Max[71] = 0
    set Tec_Tecla[71] = "S"
    set Tec_Ini[71] = 0
''', '''    // v22o: pasiva con tier desde T1 (1500 en T6).
    set Tec_Max[71] = 6
    set Tec_T6[71] = 1500.
    set Tec_Base[71] = 500.
    set Tec_Tecla[71] = ""
    set Tec_Ini[71] = 1
''')
cambia('    set Cua_Des[71] = "Técnica."\n', '    set Cua_Des[71] = "Pasiva: al acertar con las armas|nmarca al enemigo con más vida."\n')
cambia('''    set Tec_Max[76] = 1
''', '''    // v22o: pasiva con tier (1500 en T6).
    set Tec_Max[76] = 6
    set Tec_T6[76] = 1500.
    set Tec_Base[76] = 250.
''')
cambia('    set Cua_Des[76] = "Técnica."\n', '    set Cua_Des[76] = "Pasiva: al reaparecer o bajar|ndel 25 % salen 3 copias."\n')
assert src.index('set Tec_Curva[6] = 1.') > src.index('function Tec_FacAb')

if prueba:
    assert 'function Cop_Anotar' in src
    cambia('lat\\\\v22n-', 'lat\\\\v22o-', src.count('lat\\\\v22n-'))
    cambia('v22n-don.txt', 'v22o-don.txt', src.count('v22n-don.txt'))
    assert 'lat\\\\v22n-' not in src and 'v22n-don.txt' not in src, 'quedan registros v22n'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22o', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
