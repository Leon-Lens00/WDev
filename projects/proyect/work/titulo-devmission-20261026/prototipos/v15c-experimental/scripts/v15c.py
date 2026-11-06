#!/usr/bin/env python3
r"""v15c (con v15b y v15d): colores de bala por tier, la tienda del prototipo de UI System y sus precios (05/11/2026).
Plan: Proyect/docs/planes/devmission-armas-sobrecarga-v15.md. Prototipo: Proyect/work/tienda-mejoras-20261105/.

v15b (bala del color del tier):
- Shot y Shot II tienen Cyan en el T3 (antes Blue) y la Daemonic Arrow los 7 colores. Son copias teñidas de
  TerrainDev/scripts/balas_colores.cjs (manifiesto en TerrainDev/assets/balas-colores).

v15c (tienda del prototipo):
- Cada arma tiene 7 modelos, uno por tier (Yellow, Green, Cyan, Blue, Orange, Red, Purple).
- En el tier t cada mejora tiene t niveles. Hay 4 mejoras en el T1, 5 en el T2 y 6 desde el T3.
- Completar todas las mejoras deja comprar el modelo siguiente; al comprarlo, sus mejoras empiezan en 0.
- Estadísticas efectivas en Arm_*[100 + p * 4 + c], calculadas por Mej_Calc. Parten del T1 de v15a (c * 3) y suben
  por modelo y por mejora. Arm_W devuelve ese índice, así que el disparo, la ráfaga y el HUD no cambian.
- La velocidad de la bala pasa a Arm_Velocidad (antes 1200 fijo en shootFamily): 1200 + 60 por modelo, más su mejora.
- Panel central del prototipo, en dos vistas:
  - Modelos: los 7 en fila con flechas, más la ficha del elegido con estadísticas y mejoras.
  - Árbol: el modelo en el centro y las mejoras en anillo, con Volver y Comprar.
- Los paneles izquierdo y derecho siguen siendo los del mapa: categorías y Salir; golem, kit, vida y sobrecarga.
- Las piezas son fijas. Mej_Pic no entra en Shop_Pz y Refrescar enciende las de la vista abierta.
- Los iconos son blancos y se tiñen por tier. Las texttags se crean al abrir y se destruyen al cerrar (43).
- Sin vista previa al pasar el ratón: el paso del ratón por un trackable viaja por la red. El primer clic en un modelo
  muestra su ficha y el segundo abre su árbol.

v15d (balance provisional):
- Nivel n+1 de una mejora: base_m × (1 + 0,5 n), con base_m = 20 × (1 + 0,5 m), redondeado a 5.
- Modelos 2..7: 200, 500, 900, 1300, 1750 y 2250 oro. Un arma hasta el T7 cuesta unos 28.200 oro, frente a los
  ~48.000 estimados de la partida.
- «Mejorar sobrecarga»: 150 × n (n = 1..7). El calor sube un 15 % por modelo; la mejora de sobrecarga del arma lo baja
  un 5 % por nivel.
Uso: v15c.py ENTRADA.j (v15a) SALIDA.j
"""
from pathlib import Path
import math
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

N = '\r\n'


def u(x):
    # El script está en UTF-8 y se lee como latin-1: los acentos de lo insertado también.
    return x.encode('utf-8').decode('latin-1')


def once(s, old, new):
    return base.once(s, u(old), u(new))


def funcion(s, cabeza):
    """Inicio y fin (tras endfunction) de la función que empieza por cabeza."""
    c = u(cabeza).replace('\n', N)
    assert s.count(c) == 1, cabeza
    a = s.index(c)
    b = s.index(N + 'endfunction', a) if not cabeza.startswith('    ') else s.index(N + '    endfunction', a)
    return a, s.index(N, b + 2) + 2


def en(s, cabeza, old, new):
    """once dentro de una sola función."""
    a, b = funcion(s, cabeza)
    return s[:a] + once(s[a:b], old, new) + s[b:]


def cambiar(s, cabeza, nuevo):
    """Sustituye la función entera."""
    a, b = funcion(s, cabeza)
    return s[:a] + u(nuevo).replace('\n', N) + s[b:]


def q(x):
    return f'{x:.1f}'


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')

# --- v15b: colores -----------------------------------------------------------------------------------------------
s = en(s, 'function Arm_ColorTier takes integer t, boolean teal returns string\n', '''    elseif t == 3 and teal then
        return "Teal"
''', '''    elseif t == 3 and teal then
        return "Teal"
    elseif t == 3 then
        return "Cyan"
''')
s = once(s, '// Color del tier t para los nombres de los modelos; Firebrand tiene Teal para el Cyan.',
         '// Color del tier t para los nombres de los modelos; Firebrand tiene Teal para el Cyan (v15b: Shot y Shot II, Cyan).')
s = en(s, 'function Arm_Bala takes integer c, integer t returns nothing\n', '''        // Daemonic Arrow movida en X (TerrainDev/scripts/daemonic_ajustada.cjs): la cabeza queda en +15.
        set Arm_BalaModelo = "DaemonicArrow\\\\Daemonic Arrow Purple.mdx"
''', '''        // Daemonic Arrow movida en X (TerrainDev/scripts/daemonic_ajustada.cjs), teñida por tier (v15b, balas_colores.cjs).
        set Arm_BalaModelo = "DaemonicArrow\\\\Daemonic Arrow " + Arm_ColorTier(t, false) + ".mdx"
''')

# --- Datos ---------------------------------------------------------------------------------------------------------
MODELOS = [['M9', 'M1911', 'DEXIX', 'Glock', 'Deagle', 'Raven', 'Orión'],
           ['MP5', 'Vektor', 'UZI', 'P90', 'Kriss', 'Spectre', 'Nébula'],
           ['Recortada', 'Sable', 'Bombeo', 'Doble cañón', 'Saiga', 'Furia', 'Volcán'],
           ['Halcón', 'Cóndor', 'Águila', 'Grifo', 'Fénix', 'Dragón', 'Abismo']]
PRECIO_MODELO = [0, 200, 500, 900, 1300, 1750, 2250]
TIERS = [('Yellow', (255, 225, 80), 'Energía inicial'), ('Green', (90, 230, 120), 'Energía estable'),
         ('Cyan', (80, 230, 240), 'Energía elevada'), ('Blue', (70, 140, 255), 'Energía concentrada'),
         ('Orange', (255, 150, 60), 'Energía destructiva'), ('Red', (255, 80, 80), 'Poder extremo'),
         ('Purple', (185, 110, 255), 'Poder sobrenatural')]
# Tipos de mejora: 0 daño, 1 sobrecarga, 2 alcance, 3 precisión, 4 cadencia, 5 velocidad, 6 perdigones, 7 perforación.
MEJORAS = [('Daño', 'Daño +8 % por nivel'), ('Refrigeración', 'Sobrecarga -5 % por nivel'),
           ('Alcance', 'Alcance +6 % por nivel'), ('Precisión', 'Dispersión -8 % por nivel'),
           ('Cadencia', 'Cadencia +6 % por nivel'), ('Velocidad de bala', 'Vel. bala +8 % por nivel'),
           ('Perdigones', '+1 perdigón cada 2 niveles'), ('Perforación', '+1 perforación cada 2 niveles')]
FRASES = ['Las cuatro son tuyas. Mejóralas una a una.', 'Mucho plomo, poca paciencia.', 'De cerca no perdona.',
          'Un disparo, un problema menos.']
extra = '    // v15c: modelos, tiers y mejoras de la tienda del prototipo.\n'
extra += ''.join(f'    set Mod_Nombre[{c * 7 + m}] = "{n}"\n' for c, fila in enumerate(MODELOS) for m, n in enumerate(fila))
extra += ''.join(f'    set Mod_Precio[{m}] = {x}\n' for m, x in enumerate(PRECIO_MODELO))
for t, (nombre, (r, g, b), lema) in enumerate(TIERS):
    extra += (f'    set Tier_Nombre[{t}] = "{nombre}"\n    set Tier_Lema[{t}] = "{lema}"\n'
              f'    set Tier_R[{t}] = {r}\n    set Tier_G[{t}] = {g}\n    set Tier_B[{t}] = {b}\n'
              f'    set Tier_Hex[{t}] = "|cff{r:02x}{g:02x}{b:02x}"\n')
extra += ''.join(f'    set Mej_Nombre[{k}] = "{n}"\n    set Mej_Efecto[{k}] = "{e}"\n' for k, (n, e) in enumerate(MEJORAS))
extra += ''.join(f'    set Mej_Frase[{c}] = "{f}"\n    set Mej_Tecla[{c}] = "{"QWER"[c]}"\n' for c, f in enumerate(FRASES))
s = once(s, '    set Shop_Frase[0] = ', extra + '    set Shop_Frase[0] = ')

s = once(s, 'real Arm_BalaRadio= 0.\n', '''real Arm_BalaRadio= 0.
// v15c: estadísticas efectivas por jugador en Arm_*[100 + p * 4 + c] (Mej_Calc); 160 + p, para la ficha de la tienda.
real array Arm_Vel
real Arm_Velocidad= 1200.
integer array Mej_N
integer array Shop_Vista
integer array Shop_Sel
string array Mod_Nombre
integer array Mod_Precio
string array Tier_Nombre
string array Tier_Lema
string array Tier_Hex
integer array Tier_R
integer array Tier_G
integer array Tier_B
string array Mej_Nombre
string array Mej_Efecto
string array Mej_Frase
string array Mej_Tecla
string array Mej_Linea
real array Mej_NX
real array Mej_NY
unit array Mej_Pz
integer Mej_PzN= 0
texttag array Shop_C
unit array Ms_Glow
unit array Ms_On
unit array Ms_Off
unit array Ms_Lock
unit array Ms_Ico
unit array Ms_Fle
unit array Mc_On
unit array Mc_Off
unit array Mc_Ico
unit Mw_On= null
unit Mw_Off= null
unit Mz_Glow= null
unit Mz_On= null
unit Mz_Off= null
unit Mz_Lock= null
unit array Mz_Ico
unit array Mn_Glow
unit array Mn_On
unit array Mn_Off
unit array Mn_Lock
unit array Mn_Marca
unit array Mn_Ico
unit array Mn_Fle
unit Mb_VolOn= null
unit Mb_VolOff= null
unit Mb_ComOn= null
unit Mb_ComOff= null
''')

# --- Estadísticas por modelo y mejora -------------------------------------------------------------------------------
s = cambiar(s, 'function Arm_W takes integer p returns integer\n', r'''// v15c: índice de las estadísticas efectivas del arma activa (Mej_Calc).
function Arm_W takes integer p returns integer
    return 100 + p * 4 + Arm_Cat[p]
endfunction

// Tipo de la mejora de la ranura i del modelo m (0..6). La ranura 3 cambia por arma: precisión; perdigones en la
// escopeta desde el modelo 2; perforación en el francotirador, que no tiene dispersión.
function Mej_Tipo takes integer c, integer m, integer i returns integer
    if i == 3 then
        if c == 3 then
            return 7
        elseif c == 2 and m >= 1 then
            return 6
        endif
        return 3
    endif
    return i
endfunction

function Mej_Cuantas takes integer m returns integer
    if m == 0 then
        return 4
    elseif m == 1 then
        return 5
    endif
    return 6
endfunction

// Niveles de la ranura i: los modelos anteriores al actual están completos y los siguientes, vacíos.
function Mej_Nivel takes integer p, integer c, integer m, integer i returns integer
    local integer own = Arm_Tier[p * 7 + c] - 1
    if i >= Mej_Cuantas(m) or m > own then
        return 0
    elseif m < own then
        return m + 1
    endif
    return Mej_N[(p * 4 + c) * 6 + i]
endfunction

function Mej_Hechas takes integer p, integer c, integer m returns integer
    local integer i = 0
    local integer n = 0
    loop
        exitwhen i > 5
        set n = n + Mej_Nivel(p, c, m, i)
        set i = i + 1
    endloop
    return n
endfunction

function Mej_Total takes integer m returns integer
    return Mej_Cuantas(m) * (m + 1)
endfunction

// v15d: nivel n+1 de una mejora del modelo m, redondeado a 5.
function Mej_Precio takes integer m, integer n returns integer
    local integer b = R2I(20. * (1. + 0.5 * m) / 5. + 0.5) * 5
    return R2I(b * (1. + 0.5 * n) / 5. + 0.5) * 5
endfunction

// Estadísticas del modelo m de la categoría c con las mejoras de p, en el índice w. Base: el T1 de v15a (c * 3).
function Mej_Calc takes integer p, integer c, integer m, integer w returns nothing
    local integer b = c * 3
    local integer i = 0
    local integer array lv
    loop
        exitwhen i > 5
        set lv[Mej_Tipo(c, m, i)] = Mej_Nivel(p, c, m, i)
        set i = i + 1
    endloop
    set Arm_Nombre[w] = Mod_Nombre[c * 7 + m]
    set Arm_Dano[w] = Arm_Dano[b] * (1. + 0.35 * m) * (1. + 0.08 * lv[0])
    set Arm_Calor[w] = Arm_Calor[b] * Pow(1.15, m) * (1. - 0.05 * lv[1])
    set Arm_Alc[w] = (Arm_Alc[b] + 40. * m) * (1. + 0.06 * lv[2])
    set Arm_Disp[w] = RMaxBJ(0., Arm_Disp[b] * (1. - 0.06 * m) * (1. - 0.08 * lv[3]))
    set Arm_Int[w] = Arm_Int[b] / ((1. + 0.06 * m) * (1. + 0.06 * lv[4]))
    set Arm_Vel[w] = (1200. + 60. * m) * (1. + 0.08 * lv[5])
    set Arm_Perd[w] = Arm_Perd[b] + (lv[6] + 1) / 2
    set Arm_Perfora[w] = Arm_Perfora[b] + (lv[7] + 1) / 2
    if m >= 4 then
        set Arm_Perfora[w] = Arm_Perfora[w] + 1
    endif
    set Arm_Crit[w] = Arm_Crit[b]
    set Arm_Area[w] = Arm_Area[b]
    set Arm_Tipo[w] = Arm_Tipo[b]
endfunction

function Arm_Recalc takes integer p, integer c returns nothing
    call Mej_Calc(p, c, Arm_Tier[p * 7 + c] - 1, 100 + p * 4 + c)
endfunction
''')
s = once(s, '''            set Sob_Kits[p]=Sob_KITS_INICIO()
''', '''            set Sob_Kits[p]=Sob_KITS_INICIO()
            call Arm_Recalc(p , 0)
            call Arm_Recalc(p , 1)
            call Arm_Recalc(p , 2)
            call Arm_Recalc(p , 3)
''')
s = once(s, '''        set Arm_Alcance=range
        call Arm_Bala(w / 3 , ModuloInteger(w, 3) + 1)
''', '''        set Arm_Alcance=range
        set Arm_Velocidad=Arm_Vel[w]
        call Arm_Bala(ModuloInteger(w - 100, 4) , Arm_Tier[( w - 100 ) / 4 * 7 + ModuloInteger(w - 100, 4)])
''')
s = once(s, '''        set Arm_BalaModelo=""
        set s__RapidPair_lastMissile[this]=m
''', '''        set Arm_BalaModelo=""
        set Arm_Velocidad=1200.
        set s__RapidPair_lastMissile[this]=m
''')
s = once(s, 'set s__Missile_speed[(m)]=((1200.)*1.0) * Missile_TIMER_TIMEOUT // INLINED!!',
         'set s__Missile_speed[(m)]=Arm_Velocidad * Missile_TIMER_TIMEOUT // v15c: antes 1200 fijo')

# v15d: «Mejorar sobrecarga» a 150 × n.
s = cambiar(s, 'function Sob_Precio takes integer n returns integer\n', '''// v15d: precio del nivel n de «Mejorar sobrecarga»: 150, 300... 1050.
function Sob_Precio takes integer n returns integer
    return 150 * n
endfunction
''')
s = once(s, '// Precio del nivel n de «Mejorar sobrecarga»: 75, 150, 300... 4800.\n', '')

# --- Tienda --------------------------------------------------------------------------------------------------------
CX, CY, RX, RY = 948, 330, 250, 165
ANG = [-90, -30, 30, 90, 150, 210]
nodos, flechas = [], []
for a in ANG:
    dx, dy = math.cos(math.radians(a)), math.sin(math.radians(a))
    nx, ny = CX + RX * dx, CY + RY * dy
    sx, sy, ex, ey = CX + dx * 92, CY + dy * 72, nx - dx * 56, ny - dy * 52
    th = math.degrees(math.atan2(ey - sy, ex - sx))
    nodos.append((nx, ny))
    # Pantalla: derecha +Y y abajo +X; la flecha (punta a la derecha con giro 270) gira con el facing: 270 - ángulo.
    flechas.append(((sx + ex) / 2, (sy + ey) / 2, math.hypot(ex - sx, ey - sy), (270 - th) % 360))
TEX = {'NodeOn': 'DS17', 'NodeOff': 'DS18', 'ModelOn': 'DS19', 'ModelOff': 'DS1A', 'NodeGlow': 'DS1B',
       'Mejora-velocidad': 'DS1C', 'Mejora-dano': 'DS1D', 'Mejora-alcance': 'DS1E', 'Mejora-precision': 'DS1F',
       'Mejora-cadencia': 'DS1G', 'Mejora-recarga': 'DS1I', 'Mejora-perforacion': 'DS1J', 'Mejora-perdigones': 'DS1K',
       'Flecha': 'DS1L', 'Marca': 'DS1M', 'Candado': 'DS1N', 'Modelo-pistola': 'DS1O', 'Modelo-subfusil': 'DS1P',
       'Modelo-escopeta': 'DS1Q', 'Modelo-francotirador': 'DS1R'}
TIPO_TEX = ['Mejora-dano', 'Mejora-recarga', 'Mejora-alcance', 'Mejora-precision', 'Mejora-cadencia',
            'Mejora-velocidad', 'Mejora-perdigones', 'Mejora-perforacion']
textex = ''.join(f"    {'if' if k == 0 else 'elseif'} tp == {k} then\n        return '{TEX[n]}'\n" for k, n in enumerate(TIPO_TEX))
construir = []
for i, (nx, ny) in enumerate(nodos):
    construir.append(f'    set Mej_NX[{i}] = {q(nx)}\n    set Mej_NY[{i}] = {q(ny)}\n')
for i, (fx, fy, ln, fa) in enumerate(flechas):
    construir.append(f"    set Mn_Fle[{i}] = Mej_Pic({q(fx)}, {q(fy)}, {q(ln)}, 14, 395, 'DS1L', {q(fa)})\n")
TIENDA = r'''// v15c: tienda del prototipo de UI System. Las piezas, como Shop_Pic, pero fuera de Shop_Pz (Shop_Mostrar no las
// enciende) y con giro: la pieza es plana y la cámara cenital, así que el facing la gira en pantalla.
function Mej_Pic takes real px, real py, real wpx, real hpx, real depth, integer tex, real facing returns unit
    local real w = wpx * (0.544 / 718.18930543) * depth
    local real h = hpx * (0.302 / 387.73819261) * depth
    local real a
    local integer anim = 0
    local real x = Title_WX(Shop_PY(py), depth)
    local real y = Title_WY(px, depth)
    local unit u = CreateUnit(CAMERA_DUMMY_PLAYER, 'uids', x, y, facing)
    if h < w then
        set anim = IMinBJ(100, R2I(10 * (w / h - 1) + 0.5))
    else
        set a = 10 * (h / w - 1)
        if a >= 0.5 then
            set anim = 100 + IMinBJ(100, R2I(a + 0.5))
        endif
    endif
    call SaveInteger(Title_HT, GetHandleId(u), 0, anim)
    call SaveReal(Title_HT, GetHandleId(u), 1, 0.5 * RMinBJ(w, h))
    call SaveReal(Title_HT, GetHandleId(u), 2, depth)
    call UnitAddAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitAddAbility(u, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
    call Title_Height(u)
    call Title_Skin(u, tex)
    call Title_Show(u, true)
    call SetUnitX(u, x)
    call SetUnitY(u, y)
    call SetUnitFlyHeight(u, Shop_OJO - depth - UserInterface_GetTerrainZ(x, y), 0)
    call SetUnitVertexColor(u, 255, 255, 255, 0)
    set Mej_Pz[Mej_PzN] = u
    set Mej_PzN = Mej_PzN + 1
    set bj_lastCreatedUnit = u
    set u = null
    return bj_lastCreatedUnit
endfunction

function Mej_TexTipo takes integer tp returns integer
@TEXTEX@    endif
    return 'DS1D'
endfunction

// Pieza del icono de la ranura i con el tipo tp: tres por ranura; la 3 usa una por tipo (precisión, perdigones, perforación).
function Mej_Pieza takes integer i, integer tp returns integer
    if i != 3 then
        return i * 3
    elseif tp == 6 then
        return 10
    elseif tp == 7 then
        return 11
    endif
    return 9
endfunction

function Mej_Construir takes nothing returns nothing
    local integer m = 0
    local integer c
    local integer i
    local real x
    loop
        exitwhen m > 6
        set x = 646 + 101 * m
        set Ms_Glow[m] = Mej_Pic(x, 182, 108, 92, 399.6, 'DS1B', 270)
        set Ms_On[m] = Mej_Pic(x, 182, 88, 72, 399, 'DS19', 270)
        set Ms_Off[m] = Mej_Pic(x, 182, 88, 72, 399, 'DS1A', 270)
        set c = 0
        loop
            exitwhen c > 3
            set Ms_Ico[c * 7 + m] = Mej_Pic(x, 181, 68, 34, 390, 'DS1O' + c, 270)
            set c = c + 1
        endloop
        set Ms_Lock[m] = Mej_Pic(x, 182, 30, 30, 380, 'DS1N', 270)
        if m < 6 then
            set Ms_Fle[m] = Mej_Pic(x + 51, 182, 12, 10, 395, 'DS1L', 270)
        endif
        set m = m + 1
    endloop
    set i = 0
    loop
        exitwhen i > 5
        set x = 648 + 112 * i
        set Mc_On[i] = Mej_Pic(x, 584, 64, 64, 399, 'DS17', 270)
        set Mc_Off[i] = Mej_Pic(x, 584, 64, 64, 399, 'DS18', 270)
        set Mn_Glow[i] = Mej_Pic(Mej_NX[i], Mej_NY[i], 120, 120, 399.6, 'DS1B', 270)
        set Mn_On[i] = Mej_Pic(Mej_NX[i], Mej_NY[i], 88, 88, 399, 'DS17', 270)
        set Mn_Off[i] = Mej_Pic(Mej_NX[i], Mej_NY[i], 88, 88, 399, 'DS18', 270)
        set Mn_Lock[i] = Mej_Pic(Mej_NX[i] + 25, Mej_NY[i] + 23, 30, 30, 380, 'DS1N', 270)
        set Mn_Marca[i] = Mej_Pic(Mej_NX[i] + 26, Mej_NY[i] + 26, 28, 28, 380, 'DS1M', 270)
        // Un icono por ranura; la 3, uno por cada tipo que puede tener (precisión 3, perdigones 6, perforación 7).
        set c = i
        loop
            set Mc_Ico[Mej_Pieza(i, c)] = Mej_Pic(x, 584, 40, 40, 390, Mej_TexTipo(c), 270)
            set Mn_Ico[Mej_Pieza(i, c)] = Mej_Pic(Mej_NX[i], Mej_NY[i], 60, 60, 390, Mej_TexTipo(c), 270)
            exitwhen i != 3 or c == 7
            if c == 3 then
                set c = 6
            else
                set c = 7
            endif
        endloop
        set i = i + 1
    endloop
    set Mz_Glow = Mej_Pic(948, 330, 192, 160, 399.6, 'DS1B', 270)
    set Mz_On = Mej_Pic(948, 330, 164, 132, 399, 'DS19', 270)
    set Mz_Off = Mej_Pic(948, 330, 164, 132, 399, 'DS1A', 270)
    set c = 0
    loop
        exitwhen c > 3
        set Mz_Ico[c] = Mej_Pic(948, 326, 136, 68, 390, 'DS1O' + c, 270)
        set c = c + 1
    endloop
    set Mz_Lock = Mej_Pic(948, 330, 44, 44, 380, 'DS1N', 270)
    set Mw_Off = Mej_Pic(948, 773, 716, 62, 399, 'DS0B', 270)
    set Mw_On = Mej_Pic(948, 773, 716, 62, 398.5, 'DS07', 270)
    set Mb_VolOff = Mej_Pic(700, 773, 220, 62, 399, 'DS0A', 270)
    set Mb_VolOn = Mej_Pic(700, 773, 220, 62, 398.5, 'DS09', 270)
    set Mb_ComOff = Mej_Pic(1068, 773, 476, 62, 399, 'DS0B', 270)
    set Mb_ComOn = Mej_Pic(1068, 773, 476, 62, 398.5, 'DS07', 270)
endfunction

// Visual y sólo en el cliente de quien tiene la tienda abierta.
function Mej_Ver takes integer p, unit u, integer r, integer g, integer b, integer a returns nothing
    if GetLocalPlayer() == Player(p) then
        call SetUnitVertexColor(u, r, g, b, a)
    endif
endfunction

function Mej_Tier takes integer p, unit u, integer t, integer a returns nothing
    call Mej_Ver(p, u, Tier_R[t], Tier_G[t], Tier_B[t], a)
endfunction

function Mej_Ocultar takes integer p returns nothing
    local integer i = 0
    if GetLocalPlayer() == Player(p) then
        loop
            exitwhen i >= Mej_PzN
            call SetUnitVertexColor(Mej_Pz[i], 255, 255, 255, 0)
            set i = i + 1
        endloop
    endif
endfunction

// Texto k del panel central; al: 0 izquierda, 1 centro, 2 derecha. col: tier 0..6, -1 claro, -2 gris, -3 apagado, -4 rojo.
function Mej_Txt takes integer p, integer k, string s, real px, real py, real size, integer al, integer col returns nothing
    local texttag t = Shop_C[k]
    if al == 1 then
        call Shop_Centro(p, t, s, px, py, size)
    elseif al == 2 then
        call Shop_Der(p, t, s, px, py, size)
    else
        call Shop_Izq(p, t, s, px, py, size)
    endif
    if GetLocalPlayer() == Player(p) then
        if col >= 0 then
            call SetTextTagColor(t, Tier_R[col], Tier_G[col], Tier_B[col], 255)
        elseif col == - 2 then
            call SetTextTagColor(t, 143, 169, 200, 255)
        elseif col == - 3 then
            call SetTextTagColor(t, 108, 127, 156, 255)
        elseif col == - 4 then
            call SetTextTagColor(t, 220, 110, 110, 255)
        else
            call SetTextTagColor(t, 235, 240, 245, 255)
        endif
    endif
    set t = null
endfunction

// 0 tuyo, 1 se puede comprar (el actual está completo), 2 bloqueado.
function Mej_Estado takes integer p, integer c, integer m returns integer
    local integer own = Arm_Tier[p * 7 + c] - 1
    if m <= own then
        return 0
    elseif m == own + 1 and Mej_Hechas(p, c, own) == Mej_Total(own) then
        return 1
    endif
    return 2
endfunction

function Mej_Bono takes integer t, integer pct, boolean menos returns string
    if pct <= 0 then
        return ""
    elseif menos then
        return "  " + Tier_Hex[t] + "-" + I2S(pct) + " %|r"
    endif
    return "  " + Tier_Hex[t] + "+" + I2S(pct) + " %|r"
endfunction

// Seis estadísticas del modelo m en Shop_C[13..18], en cols columnas.
function Mej_Stats takes integer p, integer c, integer m, real x0, real y0, integer cols, real cw, real rh returns nothing
    local integer w = 160 + p
    local integer i = 0
    local integer array lv
    local string s
    local string g = "|cff8fa9c8"
    loop
        exitwhen i > 5
        set lv[Mej_Tipo(c, m, i)] = Mej_Nivel(p, c, m, i)
        set i = i + 1
    endloop
    call Mej_Calc(p, c, m, w)
    if Arm_Perd[w] > 1 then
        set s = I2S(Arm_Perd[w]) + " x " + I2S(R2I(Arm_Dano[w] + 0.5))
    else
        set s = I2S(R2I(Arm_Dano[w] + 0.5))
    endif
    set Mej_Linea[0] = g + "Daño|r  " + s + Mej_Bono(m, 8 * lv[0], false)
    set Mej_Linea[1] = g + "Cadencia|r  " + R2SW(1. / Arm_Int[w], 1, 1) + "/s" + Mej_Bono(m, 6 * lv[4], false)
    set Mej_Linea[2] = g + "Vel. bala|r  " + I2S(R2I(Arm_Vel[w] + 0.5)) + Mej_Bono(m, 8 * lv[5], false)
    set Mej_Linea[3] = g + "Alcance|r  " + I2S(R2I(Arm_Alc[w] + 0.5)) + Mej_Bono(m, 6 * lv[2], false)
    if c == 3 then
        set Mej_Linea[4] = g + "Perforación|r  " + I2S(Arm_Perfora[w])
    else
        set Mej_Linea[4] = g + "Precisión|r  " + I2S(IMaxBJ(0, 100 - R2I(Arm_Disp[w] * 6.))) + "%"
    endif
    set Mej_Linea[5] = g + "Sobrecarga|r  " + R2SW(Arm_Calor[w], 1, 1) + Mej_Bono(m, 5 * lv[1], true)
    set i = 0
    loop
        exitwhen i > 5
        call Mej_Txt(p, 13 + i, Mej_Linea[i], x0 + ModuloInteger(i, cols) * cw, y0 + (i / cols) * rh, 0.019, 0, - 1)
        set i = i + 1
    endloop
endfunction

// Vista de modelos: los 7 en fila y la ficha del elegido (Shop_Ver).
function Mej_Modelos takes integer p, integer c, integer own, integer m, integer e, integer oro returns nothing
    local integer j = 0
    local integer ej
    local integer col
    local integer n
    local integer x
    local boolean ok = false
    local string s
    call Mej_Txt(p, 0, Cat_Nombre[c] + "  ·  [" + Mej_Tecla[c] + "]", 596, 92, 0.026, 0, - 1)
    call Mej_Txt(p, 1, "Modelos", 1252, 100, 0.017, 2, - 2)
    loop
        exitwhen j > 6
        set ej = Mej_Estado(p, c, j)
        if j < 6 then
            if j < own or (j == own and Mej_Hechas(p, c, j) == Mej_Total(j)) then
                call Mej_Tier(p, Ms_Fle[j], j, 255)
            else
                call Mej_Ver(p, Ms_Fle[j], 90, 105, 130, 255)
            endif
        endif
        if ej == 0 then
            if j == m then
                call Mej_Ver(p, Ms_Glow[j], 255, 255, 255, 255)
            else
                call Mej_Tier(p, Ms_Glow[j], j, 190)
            endif
        elseif j == m then
            call Mej_Ver(p, Ms_Glow[j], 200, 215, 255, 128)
        endif
        if ej == 2 then
            call Mej_Ver(p, Ms_Off[j], 255, 255, 255, 255)
            call Mej_Ver(p, Ms_Ico[c * 7 + j], 70, 80, 100, 255)
            call Mej_Ver(p, Ms_Lock[j], 255, 255, 255, 255)
            set col = - 3
        else
            call Mej_Ver(p, Ms_On[j], 255, 255, 255, 255)
            call Mej_Tier(p, Ms_Ico[c * 7 + j], j, 255)
            set col = j
        endif
        call Mej_Txt(p, 2 + j, I2S(j + 1), 646 + 101 * j, 228, 0.017, 1, col)
        set j = j + 1
    endloop
    call Mej_Txt(p, 9, Mod_Nombre[c * 7 + m], 596, 282, 0.028, 0, - 1)
    call Mej_Txt(p, 10, "Tier " + I2S(m + 1) + " · " + Tier_Nombre[m], 1252, 280, 0.019, 2, m)
    call Mej_Txt(p, 11, Tier_Lema[m], 1252, 306, 0.017, 2, - 2)
    if e == 0 then
        call Mej_Txt(p, 12, "Mejoras " + I2S(Mej_Hechas(p, c, m)) + "/" + I2S(Mej_Total(m)), 596, 322, 0.019, 0, m)
    elseif e == 1 then
        call Mej_Txt(p, 12, I2S(Mod_Precio[m]) + " oro", 596, 322, 0.019, 0, m)
    else
        call Mej_Txt(p, 12, "Bloqueado", 596, 322, 0.019, 0, - 3)
    endif
    call Mej_Stats(p, c, m, 596, 380, 3, 236., 66.)
    if m == 0 then
        set s = "1 nivel"
    else
        set s = I2S(m + 1) + " niveles"
    endif
    call Mej_Txt(p, 19, "Mejoras · " + s + " cada una", 596, 520, 0.017, 0, - 2)
    set j = 0
    loop
        exitwhen j >= Mej_Cuantas(m)
        set n = Mej_Nivel(p, c, m, j)
        set x = Mej_Pieza(j, Mej_Tipo(c, m, j))
        if e == 2 then
            call Mej_Ver(p, Mc_Off[j], 255, 255, 255, 255)
        else
            call Mej_Ver(p, Mc_On[j], 255, 255, 255, 255)
        endif
        if n > 0 then
            call Mej_Tier(p, Mc_Ico[x], m, 255)
            set col = m
        elseif e == 2 then
            call Mej_Ver(p, Mc_Ico[x], 70, 80, 100, 255)
            set col = - 3
        else
            call Mej_Ver(p, Mc_Ico[x], 230, 240, 255, 255)
            set col = - 2
        endif
        call Mej_Txt(p, 20 + j, I2S(n) + "/" + I2S(m + 1), 648 + 112 * j, 624, 0.016, 1, col)
        set j = j + 1
    endloop
    if e == 0 then
        set s = "Ver mejoras del " + Mod_Nombre[c * 7 + m]
        set ok = true
    elseif e == 1 then
        set ok = oro >= Mod_Precio[m]
        if ok then
            set s = "Comprar " + Mod_Nombre[c * 7 + m] + " · " + I2S(Mod_Precio[m]) + " oro"
        else
            set s = "Oro insuficiente · " + I2S(Mod_Precio[m])
        endif
    else
        set s = "Completa el " + Mod_Nombre[c * 7 + m - 1] + " (" + I2S(Mej_Hechas(p, c, m - 1)) + "/" + I2S(Mej_Total(m - 1)) + ")"
    endif
    call Mej_Ver(p, Mw_Off, 255, 255, 255, 255)
    if ok then
        call Mej_Ver(p, Mw_On, 255, 255, 255, 255)
        call Mej_Txt(p, 26, s, 948, 758, 0.022, 1, - 1)
    else
        call Mej_Txt(p, 26, s, 948, 758, 0.022, 1, - 3)
    endif
endfunction

// Vista de árbol: el modelo Shop_Ver en el centro y sus mejoras en anillo; Shop_Sel es la elegida.
function Mej_Arbol takes integer p, integer c, integer own, integer m, integer e, integer oro returns nothing
    local boolean lock = e != 0
    local integer j = 0
    local integer n
    local integer x
    local integer col
    local integer tp
    local boolean ok = false
    local integer sel = Shop_Sel[p]
    local integer hech = Mej_Hechas(p, c, m)
    local string s
    call Mej_Txt(p, 0, Cat_Nombre[c] + "  ·  " + Mod_Nombre[c * 7 + m], 596, 92, 0.026, 0, - 1)
    call Mej_Txt(p, 1, "Tier " + I2S(m + 1) + " · " + Tier_Nombre[m], 1252, 98, 0.019, 2, m)
    loop
        exitwhen j >= Mej_Cuantas(m)
        set n = Mej_Nivel(p, c, m, j)
        set x = Mej_Pieza(j, Mej_Tipo(c, m, j))
        if n > 0 then
            call Mej_Tier(p, Mn_Fle[j], m, 255)
        elseif lock then
            call Mej_Ver(p, Mn_Fle[j], 60, 70, 90, 255)
        else
            call Mej_Ver(p, Mn_Fle[j], 120, 135, 165, 255)
        endif
        if sel == j then
            call Mej_Ver(p, Mn_Glow[j], 255, 255, 255, 255)
        elseif n >= m + 1 then
            call Mej_Tier(p, Mn_Glow[j], m, 255)
        elseif n > 0 then
            call Mej_Tier(p, Mn_Glow[j], m, 140)
        endif
        if lock then
            call Mej_Ver(p, Mn_Off[j], 255, 255, 255, 255)
            call Mej_Ver(p, Mn_Ico[x], 70, 80, 100, 255)
            call Mej_Ver(p, Mn_Lock[j], 255, 255, 255, 255)
        else
            call Mej_Ver(p, Mn_On[j], 255, 255, 255, 255)
            if n > 0 then
                call Mej_Tier(p, Mn_Ico[x], m, 255)
            else
                call Mej_Ver(p, Mn_Ico[x], 230, 240, 255, 255)
            endif
        endif
        set s = I2S(n) + "/" + I2S(m + 1)
        set col = - 2
        if n > 0 then
            set col = m
        endif
        if n >= m + 1 then
            call Mej_Tier(p, Mn_Marca[j], m, 255)
        elseif not lock then
            set s = s + "   " + I2S(Mej_Precio(m, n))
            if oro < Mej_Precio(m, n) then
                set col = - 4
            endif
        endif
        if j == 0 then
            // El nodo de arriba lleva la etiqueta a su derecha: debajo la tapa la flecha del centro.
            call Mej_Txt(p, 3 + j, s, Mej_NX[j] + 56, Mej_NY[j], 0.017, 0, col)
        else
            call Mej_Txt(p, 3 + j, s, Mej_NX[j], Mej_NY[j] + 50, 0.017, 1, col)
        endif
        set j = j + 1
    endloop
    if lock then
        call Mej_Ver(p, Mz_Off, 255, 255, 255, 255)
        call Mej_Ver(p, Mz_Ico[c], 70, 80, 100, 255)
        call Mej_Ver(p, Mz_Lock, 255, 255, 255, 255)
    else
        call Mej_Tier(p, Mz_Glow, m, 205)
        call Mej_Ver(p, Mz_On, 255, 255, 255, 255)
        call Mej_Tier(p, Mz_Ico[c], m, 255)
    endif
    call Mej_Txt(p, 2, I2S(hech) + "/" + I2S(Mej_Total(m)), 866, 404, 0.019, 0, m)
    if sel >= 0 and sel < Mej_Cuantas(m) then
        set tp = Mej_Tipo(c, m, sel)
        set n = Mej_Nivel(p, c, m, sel)
        call Mej_Txt(p, 9, Mej_Nombre[tp], 596, 616, 0.022, 0, - 1)
        call Mej_Txt(p, 10, Mej_Efecto[tp], 596, 650, 0.019, 0, m)
        call Mej_Txt(p, 11, "Nivel " + I2S(n) + "/" + I2S(m + 1), 596, 680, 0.017, 0, - 2)
    elseif lock then
        call Mej_Txt(p, 9, "Modelo bloqueado", 596, 630, 0.022, 0, - 2)
    else
        call Mej_Txt(p, 9, "Elige una mejora", 596, 630, 0.022, 0, - 2)
    endif
    call Mej_Stats(p, c, m, 890, 608, 2, 210., 34.)
    call Mej_Ver(p, Mb_VolOff, 255, 255, 255, 255)
    call Mej_Ver(p, Mb_VolOn, 255, 255, 255, 255)
    call Mej_Txt(p, 19, "<  Volver", 700, 758, 0.022, 1, - 1)
    if e == 1 then
        set ok = oro >= Mod_Precio[m]
        if ok then
            set s = "Comprar " + Mod_Nombre[c * 7 + m] + " · " + I2S(Mod_Precio[m]) + " oro"
        else
            set s = "Oro insuficiente · " + I2S(Mod_Precio[m])
        endif
    elseif lock then
        set s = "Completa el " + Mod_Nombre[c * 7 + m - 1] + " (" + I2S(Mej_Hechas(p, c, m - 1)) + "/" + I2S(Mej_Total(m - 1)) + ")"
    elseif sel >= 0 and sel < Mej_Cuantas(m) and m == own then
        set n = Mej_Nivel(p, c, m, sel)
        if n >= m + 1 then
            set s = "Al máximo"
        else
            set ok = oro >= Mej_Precio(m, n)
            if ok then
                set s = Mej_Nombre[Mej_Tipo(c, m, sel)] + " nivel " + I2S(n + 1) + " · " + I2S(Mej_Precio(m, n))
            else
                set s = "Oro insuficiente · " + I2S(Mej_Precio(m, n))
            endif
        endif
    elseif hech == Mej_Total(m) and m < 6 and m == own then
        set ok = oro >= Mod_Precio[m + 1]
        if ok then
            set s = "Comprar " + Mod_Nombre[c * 7 + m + 1] + " · " + I2S(Mod_Precio[m + 1]) + " oro"
        else
            set s = Mod_Nombre[c * 7 + m + 1] + " · oro insuficiente"
        endif
    elseif hech == Mej_Total(m) and m == 6 then
        set s = "Modelo final completo"
    elseif hech == Mej_Total(m) then
        set s = "Completo"
    else
        set s = "Elige una mejora"
    endif
    call Mej_Ver(p, Mb_ComOff, 255, 255, 255, 255)
    if ok then
        call Mej_Ver(p, Mb_ComOn, 255, 255, 255, 255)
        call Mej_Txt(p, 26, s, 1068, 758, 0.021, 1, - 1)
    else
        call Mej_Txt(p, 26, s, 1068, 758, 0.021, 1, - 3)
    endif
endfunction

'''
TIENDA = TIENDA.replace('@TEXTEX@', textex)
a = TIENDA.index('function Mej_Construir takes nothing returns nothing\n')
b = TIENDA.index('    loop\n', a)
TIENDA = TIENDA[:b] + ''.join(construir) + TIENDA[b:]
s = once(s, 'function Shop_Refrescar takes integer p returns nothing\n', TIENDA + 'function Shop_Refrescar takes integer p returns nothing\n')

s = cambiar(s, 'function Shop_Refrescar takes integer p returns nothing\n', r'''function Shop_Refrescar takes integer p returns nothing
    local integer c = Shop_Cat[p]
    local integer own = Arm_Tier[p * 7 + c] - 1
    local integer m = Shop_Ver[p]
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    local integer k = 0
    local integer x
    local string s
    loop
        exitwhen k > 3
        call Shop_Luz(p, Shop_CatOn[k], k == c)
        if k == c then
            call Shop_Elegida(p, Shop_CatT[k])
        else
            call Shop_Pinta(p, Shop_CatT[k], 170)
        endif
        set k = k + 1
    endloop
    call Mej_Ocultar(p)
    set k = 0
    loop
        exitwhen k > 26
        call Mej_Txt(p, k, "", 960, 400, 0.02, 0, - 1)
        set k = k + 1
    endloop
    if Shop_Vista[p] == 0 then
        call Mej_Modelos(p, c, own, m, Mej_Estado(p, c, m), oro)
    else
        call Mej_Arbol(p, c, own, m, Mej_Estado(p, c, m), oro)
    endif
    if Sob_Nivel[p] >= Sob_NIVELES() then
        set s = "Sobrecarga al máximo"
        call Shop_Luz(p, Shop_RecOn, false)
    else
        set x = Sob_Precio(Sob_Nivel[p] + 1)
        set s = "Mejorar sobrecarga " + I2S(Sob_Nivel[p] + 1) + "/" + I2S(Sob_NIVELES()) + ": " + I2S(x) + " oro"
        call Shop_Luz(p, Shop_RecOn, oro >= x)
    endif
    call Shop_Centro(p, Shop_T[13], s, 1601, 758, 0.021)
    call Shop_Izq(p, Shop_T[14], I2S(oro), 1490, 556, 0.026)
    call Shop_TodoTexto(p)
    call Shop_Centro(p, Shop_T[19], "Vida: " + I2S(Shop_VIDA) + " oro  (tienes " + I2S(Vidas_Actual[p]) + ")", 1601, 691, 0.021)
    call Shop_Luz(p, Shop_VidaOn, oro >= Shop_VIDA)
    call Shop_Cara(p, 0)
endfunction

function Mej_Decir takes integer p, string s returns nothing
    call Shop_Hablar(p, "Golem de roca", s)
    call Shop_Cara(p, 0)
endfunction

// Primer clic: ficha del modelo; segundo clic en el mismo: su árbol.
function Mej_Ranura takes integer p, integer j returns nothing
    local integer c = Shop_Cat[p]
    local integer e = Mej_Estado(p, c, j)
    call UI_Click(p)
    if Shop_Ver[p] == j then
        set Shop_Vista[p] = 1
        set Shop_Sel[p] = - 1
    else
        set Shop_Ver[p] = j
    endif
    call Shop_Refrescar(p)
    if e == 2 then
        call Mej_Decir(p, "Primero exprime el " + Mod_Nombre[c * 7 + j - 1] + ". Luego hablamos.")
    elseif e == 1 then
        call Mej_Decir(p, "El " + Mod_Nombre[c * 7 + j] + " ya está a tu alcance.")
    else
        call Mej_Decir(p, "El " + Mod_Nombre[c * 7 + j] + ". Veamos qué le falta.")
    endif
endfunction

function Mej_Nodo takes integer p, integer j returns nothing
    local integer c = Shop_Cat[p]
    local integer m = Shop_Ver[p]
    local integer n
    if j >= Mej_Cuantas(m) then
        return
    endif
    set n = Mej_Nivel(p, c, m, j)
    set Shop_Sel[p] = j
    call UI_Click(p)
    call Shop_Refrescar(p)
    if Mej_Estado(p, c, m) != 0 then
        call Mej_Decir(p, "Bloqueada. Termina el modelo anterior.")
    elseif n >= m + 1 then
        call Mej_Decir(p, "Esa ya está al máximo.")
    elseif m < Arm_Tier[p * 7 + c] - 1 then
        call Mej_Decir(p, "Ese modelo ya lo dejaste atrás.")
    else
        call Mej_Decir(p, Mej_Nombre[Mej_Tipo(c, m, j)] + ", nivel " + I2S(n + 1) + ": " + I2S(Mej_Precio(m, n)) + " oro.")
    endif
endfunction

// Compra el modelo m de la categoría activa: sus mejoras empiezan en 0.
function Mej_ComprarModelo takes integer p, integer m returns nothing
    local integer c = Shop_Cat[p]
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    local integer i = 0
    if m > 6 or Mej_Estado(p, c, m) != 1 or oro < Mod_Precio[m] then
        call UI_Error(p)
        return
    endif
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - Mod_Precio[m])
    set Arm_Tier[p * 7 + c] = m + 1
    loop
        exitwhen i > 5
        set Mej_N[(p * 4 + c) * 6 + i] = 0
        set i = i + 1
    endloop
    call Arm_Recalc(p, c)
    set Shop_Ver[p] = m
    set Shop_Vista[p] = 1
    set Shop_Sel[p] = - 1
    call UI_Click(p)
    call Shop_Refrescar(p)
    if Hero_Choice[p] == 1 then
        call Shop_Hablar(p, "Cairne", "Nuevo modelo, nuevo color. El " + Mod_Nombre[c * 7 + m] + " es tuyo.")
    else
        call Shop_Hablar(p, "Tauren", "Nuevo modelo, nuevo color. El " + Mod_Nombre[c * 7 + m] + " es tuyo.")
    endif
    call Shop_Voz_Comprar(p)
endfunction

// Comprar del árbol: el nivel siguiente de la mejora elegida o, con el modelo completo, el modelo siguiente.
function Mej_Comprar takes integer p returns nothing
    local integer c = Shop_Cat[p]
    local integer m = Shop_Ver[p]
    local integer own = Arm_Tier[p * 7 + c] - 1
    local integer j = Shop_Sel[p]
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    local integer n
    local integer x
    if Mej_Estado(p, c, m) == 1 then
        call Mej_ComprarModelo(p, m)
        return
    elseif m != own then
        call UI_Error(p)
        return
    endif
    if j >= 0 and j < Mej_Cuantas(m) then
        set n = Mej_N[(p * 4 + c) * 6 + j]
        set x = Mej_Precio(m, n)
        if n >= m + 1 or oro < x then
            call UI_Error(p)
            return
        endif
        call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - x)
        set Mej_N[(p * 4 + c) * 6 + j] = n + 1
        call Arm_Recalc(p, c)
        call UI_Click(p)
        call Shop_Refrescar(p)
        if Mej_Hechas(p, c, m) == Mej_Total(m) and m < 6 then
            call Mej_Decir(p, "Completo. El " + Mod_Nombre[c * 7 + m + 1] + " ya se puede comprar.")
        else
            call Mej_Decir(p, "Hecho. Se nota en la mano.")
        endif
    elseif Mej_Hechas(p, c, m) == Mej_Total(m) and m < 6 then
        call Mej_ComprarModelo(p, m + 1)
    else
        call UI_Error(p)
    endif
endfunction
''')

s = cambiar(s, 'function Shop_Textos takes nothing returns nothing\n', r'''// Sólo en el cliente de quien abre la tienda: 43 texttags (v15c) que quedan libres para el juego al cerrarla.
function Shop_Textos takes nothing returns nothing
    local integer i = 0
    if Shop_TzN > 0 then
        return
    endif
    loop
        exitwhen i > 3
        set Shop_CatT[i] = Shop_Tag(187, 146 + 66 * i, 0.022, 0, Cat_Nombre[i])
        set i = i + 1
    endloop
    call Shop_Tag(137, 92, 0.026, 0, "Armas")
    call Shop_Tag(1424, 562, 0.024, 0, "Oro")
    call Shop_Tag(250, 758, 0.024, 0, "Salir (Esc)")
    set Shop_RelojT = Shop_Tag(1601, 88, 0.024, 0, "")
    set Shop_RelojVisto = ""
    set Shop_RelojRojo = false
    set i = 13
    loop
        exitwhen i > 20
        set Shop_T[i] = Shop_Tag(960, 400, 0.02, 0, "")
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 26
        set Shop_C[i] = Shop_Tag(960, 400, 0.02, 0, "")
        set i = i + 1
    endloop
endfunction
''')
s = once(s, '// Sólo en el cliente de quien abre la tienda: 35 texttags que quedan libres para el juego al cerrarla.\n', '')
s = en(s, 'function Shop_TextosFuera takes nothing returns nothing\n', '''    set i = 0
    loop
        exitwhen i > 6
        set Shop_CatT[i] = null
        set i = i + 1
    endloop
''', '''    set i = 0
    loop
        exitwhen i > 6
        set Shop_CatT[i] = null
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 26
        set Shop_C[i] = null
        set i = i + 1
    endloop
''')
s = en(s, 'function Shop_Abrir takes integer p returns nothing\n', '''    set Shop_Ver[p] = IMaxBJ(1, Arm_Tier[p * 7 + Arm_Cat[p]])
''', '''    set Shop_Ver[p] = Arm_Tier[p * 7 + Arm_Cat[p]] - 1
    set Shop_Vista[p] = 0
    set Shop_Sel[p] = - 1
''')
s = en(s, 'function Shop_Abrir takes integer p returns nothing\n', '''    call Shop_Refrescar(p)
endfunction''', '''    call Shop_Refrescar(p)
    call Mej_Decir(p, Mej_Frase[Shop_Cat[p]])
endfunction''')
s = en(s, 'function Shop_Cerrar takes integer p returns nothing\n', '''    call Shop_Mostrar(p, false)
''', '''    call Shop_Mostrar(p, false)
    call Mej_Ocultar(p)
''')

s = cambiar(s, 'function Shop_Clic takes nothing returns nothing\n', r'''// v15c: categorías 0..3, modelos 30..36, nodos 40..45, Comprar 20, Volver 25 (en la vista de modelos, los dos son
// el botón ancho), sobrecarga 21, Salir 22, vida 23 y kit 24.
function Shop_Clic takes nothing returns nothing
    local integer h = GetHandleId(GetTriggeringTrackable())
    local integer p = LoadInteger(Shop_HT, h, 0)
    local integer k = LoadInteger(Shop_HT, h, 1)
    if not Shop_Open[p] then
        return
    endif
    // Se solapan el modelo 4 (33) con el nodo de arriba, el 2 con el de arriba a la izquierda y el 6 con el de la derecha.
    if Shop_Vista[p] == 1 then
        if k == 33 then
            set k = 40
        elseif k == 31 then
            set k = 45
        elseif k == 35 then
            set k = 41
        endif
    elseif k == 40 then
        set k = 33
    elseif k == 45 then
        set k = 31
    elseif k == 41 then
        set k = 35
    endif
    if k <= 3 then
        call UI_Click(p)
        set Shop_Cat[p] = k
        set Shop_Vista[p] = 0
        set Shop_Ver[p] = Arm_Tier[p * 7 + k] - 1
        set Shop_Sel[p] = - 1
        call Shop_Refrescar(p)
        call Mej_Decir(p, Mej_Frase[k])
    elseif k >= 30 and k <= 36 then
        if Shop_Vista[p] == 0 then
            call Mej_Ranura(p, k - 30)
        endif
    elseif k >= 40 and k <= 45 then
        if Shop_Vista[p] == 1 then
            call Mej_Nodo(p, k - 40)
        endif
    elseif k == 20 or k == 25 then
        if Shop_Vista[p] == 0 then
            if Mej_Estado(p, Shop_Cat[p], Shop_Ver[p]) == 0 then
                call UI_Click(p)
                set Shop_Vista[p] = 1
                set Shop_Sel[p] = - 1
                call Shop_Refrescar(p)
            else
                call Mej_ComprarModelo(p, Shop_Ver[p])
            endif
        elseif k == 25 then
            call UI_Click(p)
            set Shop_Vista[p] = 0
            set Shop_Sel[p] = - 1
            call Shop_Refrescar(p)
        else
            call Mej_Comprar(p)
        endif
    elseif k == 21 then
        call Shop_Sobrecarga(p)
    elseif k == 23 then
        call Shop_Vida(p)
    elseif k == 24 then
        call Shop_Kit(p)
    elseif k == 22 then
        call UI_Click(p)
        call Shop_Cerrar(p)
    endif
endfunction
''')

# Construcción: fuera la ventana del arma, las filas de tier y el botón ancho; entran las piezas y trackables nuevos.
s = en(s, 'function Shop_Construir takes nothing returns nothing\n', '''    call Shop_Pic(755, 594, 330, 196, 399, 'DS04')
''', '')
s = en(s, 'function Shop_Construir takes nothing returns nothing\n', '''        set Shop_ArmaPic[i] = Shop_Pic(755, 594, 300, 150, 398, Cat_Tex[i])
''', '')
s = en(s, 'function Shop_Construir takes nothing returns nothing\n', '''    set i = 0
    loop
        exitwhen i > 2
        call Shop_Pic(948, 156 + 58 * i, 716, 56, 399, 'DS08')
        set Shop_RowOn[i] = Shop_Pic(948, 156 + 58 * i, 716, 56, 398.5, 'DS07')
        call Shop_Pic(660, 156 + 58 * i, 15, 26, 370, 'DS0C')
        set i = i + 1
    endloop
    call Shop_Pic(948, 773, 716, 62, 399, 'DS0B')
    set Shop_BuyOn = Shop_Pic(948, 773, 716, 62, 398.5, 'DS07')
''', '''    // Hilo propio: son unas 140 piezas.
    call ExecuteFunc("Mej_Construir")
''')
s = en(s, 'function Shop_Construir takes nothing returns nothing\n', '''            set i = 0
            loop
                exitwhen i > 2
                call Shop_Pista(p, "war3mapImported\\\\ShopHitRow.mdx", 948, 156 + 58 * i, 10 + i)
                set i = i + 1
            endloop
            call Shop_Pista(p, "war3mapImported\\\\ShopHitWide.mdx", 948, 773, 20)
''', '''            set i = 0
            loop
                exitwhen i > 6
                call Shop_Pista(p, "war3mapImported\\\\ShopHitModelo.mdx", 646 + 101 * i, 182, 30 + i)
                if i < 6 then
                    call Shop_Pista(p, "war3mapImported\\\\ShopHitNodo.mdx", Mej_NX[i], Mej_NY[i], 40 + i)
                endif
                set i = i + 1
            endloop
            call Shop_Pista(p, "war3mapImported\\\\ShopHitVolver.mdx", 700, 773, 25)
            call Shop_Pista(p, "war3mapImported\\\\ShopHitComprar.mdx", 1068, 773, 20)
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
