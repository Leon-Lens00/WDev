#!/usr/bin/env python3
"""v17i (14/11/2026): ajustes de la presentación del jefe tras la prueba de v17h.

Leon tras probar v17h-prueba (vídeo y capturas): "hace falta reforzar las rafagas, adicional los jefes deben estar algo
mas centrados ... se muestran algo muy abajo, otro el hud de nuestra barra de vida como la barra de heroe textag, se
muestran hacia adelante cuando deberian ser cubiertos por ese fondo oscuro ... podriamos simular el efecto evaluando de
que color tomarian los textag si realmente se podria cubrirlos"; más lo evaluado en la prueba (jefe seleccionable, su
salida brusca, franja dura, rayo sin brillo).

- Toda la presentación pasa delante del HUD (sus piezas van a 384-401): fondo 380, ráfagas 376, jefe 260, franja 222,
  rayo 215, WARNING y nombre 200. Así el fondo oscuro tapa barras, iconos y marcos del HUD.
- Textos (texttags) del HUD y barras sobre los héroes: su profundidad no se puede cambiar y el alfa de un texttag visible
  no hace nada (Mode_Out); cada color (el base y los |c del texto) pasa a c × (1 - f) + fondo × f, el color que tendría
  bajo el fondo (11, 16, 34) con su alfa 165 (f = 0,647), en 8 pasos durante la entrada y la salida (JefeTx_*).
- Jefe más pequeño y centrado: caja de 560 × 560 px centrada en (1480, 430) (antes 640 × 700 con el pie en 820).
- Las piezas llevan Locust (el jefe se podía seleccionar). Salidas con aceleración cuadrática (se ven moverse).
- Ráfagas: 28 (antes 16), más brillantes, textura más gruesa (recursos_v17i.py). Franja más corta (1100 px) y suave.
  Rayo con más halo (recursos_v17i.py).
Uso: v17i.py v17h/war3map.j LIMITES.json SALIDA.j [SALIDA-PRUEBA.j]
"""
from pathlib import Path
import json, re, sys

MODELOS = ['Lobstrokkred', 'SeaTurtleRange', 'MurgulTideWarrior', 'MurgulShadowCaster', 'Lobstrokkblue',
           'MurlocMutant', 'NagaSiren', 'GiantSeaTurtle', 'DragonSeaTurtle']
KH, KV = 0.544 / 718.18930543, 0.302 / 387.73819261
D_JEFE = 260.
ALTO, ANCHO, CY = 560., 560., 430.

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
limites = json.loads(Path(sys.argv[2]).read_text())
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(antes), crlf(despues)
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


medidas = []
for k, nombre in enumerate(MODELOS):
    m = limites[nombre]
    s = min(ALTO * KV * D_JEFE / m['alto'], ANCHO * KH * D_JEFE / (m['der'] - m['izq']))
    ox = -(m['izq'] + m['der']) / 2 * s / (KH * D_JEFE)
    alto_px = m['alto'] * s / (KV * D_JEFE)
    oy = CY + alto_px / 2 + m['abajo'] * s / (KV * D_JEFE)       # pie de la caja en CY + alto / 2
    medidas.append(f'    set JefePres_Escala[{k + 2}] = {s:.4f}\n    set JefePres_OX[{k + 2}] = {ox:.1f}\n'
                   f'    set JefePres_OY[{k + 2}] = {oy:.1f}\n')

# --- globales ---
una('real array JefePres_OY\n', '''real array JefePres_OY
// v17i: textos tapados por el fondo de la presentación (JefeTx_*).
integer JefeTx_N= 0
integer JefeTx_Lv= 0
real JefeTx_F= 0.
integer array JefeTx_Clave
boolean array JefeTx_En
boolean array JefeTx_Vivo
boolean array JefeTx_ConTexto
texttag array JefeTx_T
string array JefeTx_S
real array JefeTx_Z
integer array JefeTx_R
integer array JefeTx_G
integer array JefeTx_B
''')

# --- JefeTx, antes del primer uso (Ronda_Texto) ---
una('function Ronda_Texto takes integer ui,string s,real size,real y returns nothing\n', r'''// v17i: los textos del HUD y de las barras de los héroes quedan "tapados" por el fondo de la presentación del jefe. Su
// profundidad no se puede cambiar y el alfa de un texttag visible no hace nada (Mode_Out): cada color, el base y los
// |cAARRGGBB del texto, pasa a c × (1 - f) + fondo × f, con el fondo (11, 16, 34) y f = 0,647 × nivel / 8 (el alfa
// 165 del fondo). Cada texto se registra con una clave igual en todos los clientes (UIText o 7000 + p / 7100 + i para
// las barras); el texttag puede ser null en los demás clientes.
function JefeTx_Hex takes string c returns integer
    local integer i = 0
    loop
        exitwhen i > 15
        if c == SubString("0123456789abcdef", i, i + 1) or c == SubString("0123456789ABCDEF", i, i + 1) then
            return i
        endif
        set i = i + 1
    endloop
    return 0
endfunction

function JefeTx_Dos takes integer v returns string
    return SubString("0123456789abcdef", v / 16, v / 16 + 1) + SubString("0123456789abcdef", ModuloInteger(v, 16), ModuloInteger(v, 16) + 1)
endfunction

function JefeTx_Mezcla takes integer c, integer d returns integer
    return IMinBJ(255, IMaxBJ(0, R2I(c * (1. - JefeTx_F) + d * JefeTx_F + 0.5)))
endfunction

function JefeTx_Par takes string s, integer i, integer d returns string
    return JefeTx_Dos(JefeTx_Mezcla(JefeTx_Hex(SubString(s, i, i + 1)) * 16 + JefeTx_Hex(SubString(s, i + 1, i + 2)), d))
endfunction

function JefeTx_Tinte takes string s returns string
    local integer n = StringLength(s)
    local integer i = 0
    local integer a = 0
    local string o = ""
    local string c
    if JefeTx_Lv <= 0 then
        return s
    endif
    loop
        exitwhen i + 10 > n
        set c = SubString(s, i, i + 2)
        if c == "|c" or c == "|C" then
            set o = o + SubString(s, a, i + 4) + JefeTx_Par(s, i + 4, 11) + JefeTx_Par(s, i + 6, 16) + JefeTx_Par(s, i + 8, 34)
            set i = i + 10
            set a = i
        else
            set i = i + 1
        endif
    endloop
    return o + SubString(s, a, n)
endfunction

function JefeTx_Alta takes integer key, texttag t returns nothing
    if not JefeTx_En[key] then
        set JefeTx_En[key] = true
        set JefeTx_Clave[JefeTx_N] = key
        set JefeTx_N = JefeTx_N + 1
        set JefeTx_R[key] = 255
        set JefeTx_G[key] = 255
        set JefeTx_B[key] = 255
    endif
    set JefeTx_T[key] = t
    set JefeTx_Vivo[key] = true
endfunction

function JefeTx_Texto takes integer key, texttag t, string s, real size returns nothing
    call JefeTx_Alta(key, t)
    set JefeTx_ConTexto[key] = true
    set JefeTx_S[key] = s
    set JefeTx_Z[key] = size
    call SetTextTagText(t, JefeTx_Tinte(s), size)
endfunction

function JefeTx_Color takes integer key, texttag t, integer r, integer g, integer b returns nothing
    call JefeTx_Alta(key, t)
    set JefeTx_R[key] = r
    set JefeTx_G[key] = g
    set JefeTx_B[key] = b
    call SetTextTagColor(t, JefeTx_Mezcla(r, 11), JefeTx_Mezcla(g, 16), JefeTx_Mezcla(b, 34), 255)
endfunction

// El texttag vivo de cada clave: los de UIText se destruyen y recrean (Racha_TTQuitar, UIText.destroy) y su id se
// recicla, así que nunca se usa el guardado.
function JefeTx_Tag takes integer k returns texttag
    if k >= 7100 then
        return Barras_Tag[k - 7100]
    elseif k >= 7000 then
        return Barras_Heroe[k - 7000]
    endif
    return s__UIText_text[k]
endfunction

// Nivel 0..8 del fondo; sólo rehace los textos cuando cambia.
function JefeTx_Aplicar takes integer lv returns nothing
    local integer i = 0
    local integer k
    local texttag t
    if lv == JefeTx_Lv then
        return
    endif
    set JefeTx_Lv = lv
    set JefeTx_F = 0.647 * lv / 8.
    loop
        exitwhen i >= JefeTx_N
        set k = JefeTx_Clave[i]
        set t = JefeTx_Tag(k)
        if JefeTx_Vivo[k] and t != null then
            if JefeTx_ConTexto[k] then
                call SetTextTagText(t, JefeTx_Tinte(JefeTx_S[k]), JefeTx_Z[k])
            endif
            call SetTextTagColor(t, JefeTx_Mezcla(JefeTx_R[k], 11), JefeTx_Mezcla(JefeTx_G[k], 16), JefeTx_Mezcla(JefeTx_B[k], 34), 255)
        endif
        set i = i + 1
    endloop
    set t = null
endfunction

function Ronda_Texto takes integer ui,string s,real size,real y returns nothing
''')

# --- UIText.destroy olvida la clave (su instancia y su texttag se reciclan) ---
una('            call DestroyTextTag(s__UIText_text[this])\n            call RemoveUnit(s__UIText_dummy[this])\n',
    '            call DestroyTextTag(s__UIText_text[this])\n            set JefeTx_Vivo[this] = false\n            set JefeTx_ConTexto[this] = false\n'
    '            set JefeTx_R[this] = 255\n            set JefeTx_G[this] = 255\n            set JefeTx_B[this] = 255\n'
    '            call RemoveUnit(s__UIText_dummy[this])\n')

# --- textos y colores del HUD a través de JefeTx ---
una('    call SetTextTagText(s__UIText_text[ui], s, size)\n', '    call JefeTx_Texto(ui, s__UIText_text[ui], s, size)\n', 3)
una('call SetTextTagText(s__UIText_text[ui], s, 0.026)', 'call JefeTx_Texto(ui, s__UIText_text[ui], s, 0.026)')
for clave, resto in (('Racha_TT[v * 2]', 'Racha_CNombre[k], 0.015'), ('Racha_TT[v * 2 + 1]', 'Racha_CTexto[k], 0.020'),
                     ('HealthBars__HeroValues[p]', 'label, 0.017'), ('HealthBars__EnemyValues[p]', 'label, 0.017')):
    una(f'call SetTextTagText(s__UIText_text[{clave}], {resto})', f'call JefeTx_Texto({clave}, s__UIText_text[{clave}], {resto})')
una('call SetTextTagText(Barras_Heroe[p], Barras_Nombre(p), 0.018)', 'call JefeTx_Texto(7000 + p, Barras_Heroe[p], Barras_Nombre(p), 0.018)')
una('call SetTextTagText(Barras_Heroe[p], Barras_Nombre(p) + "\\n" + Barras_Txt[e], 0.018)',
    'call JefeTx_Texto(7000 + p, Barras_Heroe[p], Barras_Nombre(p) + "\\n" + Barras_Txt[e], 0.018)')
una('call SetTextTagText(Barras_Tag[i], Barras_Txt[n], 0.017)', 'call JefeTx_Texto(7100 + i, Barras_Tag[i], Barras_Txt[n], 0.017)')
una('        call SetTextTagColor(s__UIText_text[ui], 255, 255, 255, 255)\n',
    '        call JefeTx_Color(ui, s__UIText_text[ui], 255, 255, 255)\n')
COLORES = ['Ronda_Titulo[p]', 'Ronda_Cifra[p]', 'Bat_UI[p]', 'DevTienda_Aviso[p]', 'HealthBars__HeroValues[p]',
           'HealthBars__EnemyValues[p]', 'Arm_NombreUI[p]', 'Arm_BalasUI[p]']
n_col = 0
ARG = r'((?:[^,()]|\([^()]*\))+)'
for clave in COLORES:
    patron = re.compile(r'call SetTextTagColor\(s__UIText_text\[' + re.escape(clave) + r'\], ' + ARG + ', ' + ARG + ', ' + ARG + r', 255\)')
    j, k = patron.subn(lambda m: f'call JefeTx_Color({clave}, s__UIText_text[{clave}], {m[1]}, {m[2]}, {m[3]})', j)
    assert k >= 1, clave
    n_col += k
assert n_col == 11, n_col

# --- bloque de la presentación, nuevo entero ---
ini = j.index('// v17h: presentaci\xf3n del jefe de ronda (scripts/v17h.py)')
fin = j.index('function HealthBarsUpdate takes nothing returns nothing')
BLOQUE = r'''// v17h: presentación del jefe de ronda (scripts/v17h.py); v17i (scripts/v17i.py): delante del HUD, jefe centrado,
// 28 ráfagas, Locust y textos tapados (JefeTx). Piezas por jugador en JefePres_Pieza[p * 48 + i]: 0 fondo, 1 franja,
// 2 WARNING, 3 nombre, 4 jefe, 5..9 rayo, 10..37 ráfagas. Todos los clientes crean y mueven las de todos (como
// HealthBars__Dummy); sólo el alfa es local. Distancias: fondo 380 (el HUD va a 384-401), ráfagas 376, jefe 260,
// franja 222, rayo 215, textos 200.
function JefePres_Alfa takes integer p, unit u, integer a, boolean aditiva returns nothing
    if GetLocalPlayer() == Player(p) then
        if aditiva then
            call SetUnitVertexColor(u, a, a, a, a)
        else
            call SetUnitVertexColor(u, 255, 255, 255, a)
        endif
    endif
endfunction

// Como Bat_Ancho a la distancia dada.
function JefePres_Foto takes unit u, real wpx, real hpx, real depth returns nothing
    local real w = wpx * (0.544 / 718.18930543) * depth
    local real h = hpx * (0.302 / 387.73819261) * depth
    local real a
    local integer anim = 0
    if h < w then
        set anim = IMinBJ(100, R2I(10 * (w / h - 1) + 0.5))
    else
        set a = 10 * (h / w - 1)
        if a >= 0.5 then
            set anim = 100 + IMinBJ(100, R2I(a + 0.5))
        endif
    endif
    call SetUnitScale(u, 0.5 * RMinBJ(w, h), 0.5 * RMinBJ(w, h), 0.5 * RMinBJ(w, h))
    call SetUnitAnimationByIndex(u, anim)
endfunction

// Como HealthBars__Dummy con Locust (v17i: el jefe se podía seleccionar), invisible para todos hasta el primer
// JefePres_Poner; la textura sólo prende al crearlo.
function JefePres_Dummy takes integer kind, integer tex, real wpx, real hpx, real depth, real facing returns unit
    set JefePres_U = CreateUnit(CAMERA_DUMMY_PLAYER, kind, 0, 0, facing)
    call UnitAddAbility(JefePres_U, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(JefePres_U, s__Interface_DESTROYER_FORM_ID)
    call UnitAddAbility(JefePres_U, s__Interface_LOCUST_ID)
    call SetUnitInvulnerable(JefePres_U, true)
    call SetUnitBlendTime(JefePres_U, 0.)
    call SetUnitVertexColor(JefePres_U, 0, 0, 0, 0)
    if tex != 0 then
        call UserInterface_ApplySkin(JefePres_U, tex)
        call JefePres_Foto(JefePres_U, wpx, hpx, depth)
    endif
    return JefePres_U
endfunction

// Entrada frenando (cúbica) y salida acelerando (cuadrática, v17i: con la cúbica casi no se veía moverse).
function JefePres_Frena takes real u returns real
    set u = 1. - RMinBJ(1., RMaxBJ(0., u))
    return 1. - u * u * u
endfunction

function JefePres_Acelera takes real u returns real
    set u = RMinBJ(1., RMaxBJ(0., u))
    return u * u
endfunction

// Escala y origen en pantalla del jefe de cada ronda (caja de 560 x 560 px centrada en (1480, 430)).
function JefePres_Medidas takes nothing returns nothing
@MEDIDAS@endfunction

function JefePres_Fin takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= 12 * 48
        if JefePres_Pieza[i] != null then
            call RemoveUnit(JefePres_Pieza[i])
            set JefePres_Pieza[i] = null
        endif
        set i = i + 1
    endloop
    set JefePres_Activa = false
    call JefeTx_Aplicar(0)
    if not JefePres_EsDemo then
        set JefePres_Lista = true
    endif
    set JefePres_EsDemo = false
endfunction

function JefePres_Iniciar takes nothing returns nothing
    local integer p = 0
    local integer b
    local integer k = 0
    local integer id = 'upj0' + JefePres_N
    local integer nombre = 'DPN0' + JefePres_N
    if JefePres_N == 10 then
        set id = 'upjA'
        set nombre = 'DPNA'
    endif
    if JefePres_Reloj == null then
        set JefePres_Reloj = CreateTimer()
    endif
    call JefePres_Medidas()
    set JefePres_Activa = true
    set JefePres_Anim = false
    set JefePres_Trueno = false
    // Ráfagas: largo, x inicial, altura, velocidad (hacia la derecha) y brillo; iguales para todos los jugadores.
    loop
        exitwhen k >= 28
        set JefePres_RL[k] = GetRandomReal(300., 1000.)
        set JefePres_RX[k] = GetRandomReal(0., 2920.)
        set JefePres_RY[k] = GetRandomReal(10., 850.)
        set JefePres_RV[k] = GetRandomReal(2800., 4800.)
        set JefePres_RA[k] = GetRandomReal(110., 230.)
        set k = k + 1
    endloop
    loop
        exitwhen p > 11
        if HealthBars__Bound[p] then
            set b = p * 48
            set JefePres_Pieza[b] = JefePres_Dummy('uidb', 'DP00', 2000., 900., 380., 270.)
            set JefePres_Pieza[b + 1] = JefePres_Dummy('uidg', 'DP02', 1100., 100., 222., 270.)
            set JefePres_Pieza[b + 2] = JefePres_Dummy('uidb', 'DP03', 848., 106., 200., 270.)
            set JefePres_Pieza[b + 3] = JefePres_Dummy('uidb', nombre, 960., 120., 200., 270.)
            set JefePres_Pieza[b + 4] = JefePres_Dummy(id, 0, 0., 0., 0., 0.)
            call SetUnitScale(JefePres_Pieza[b + 4], JefePres_Escala[JefePres_N], JefePres_Escala[JefePres_N], JefePres_Escala[JefePres_N])
            set k = 0
            loop
                exitwhen k >= 5
                set JefePres_Pieza[b + 5 + k] = JefePres_Dummy('uidg', 'DP04' + k, 420., 840., 215., 270.)
                set k = k + 1
            endloop
            set k = 0
            loop
                exitwhen k >= 28
                set JefePres_Pieza[b + 10 + k] = JefePres_Dummy('uidg', 'DP01', JefePres_RL[k], JefePres_RL[k] / 10., 376., 270.)
                set k = k + 1
            endloop
        endif
        set p = p + 1
    endloop
    call TimerStart(JefePres_Reloj, 3.20, false, function JefePres_Fin)
endfunction

// Desde la puerta del jefe (ExecuteFunc: hilo propio para crear las piezas).
function JefePres_Empezar takes nothing returns nothing
    set JefePres_N = IMinBJ(10, IMaxBJ(2, JefePres_Ronda))
    set JefePres_EsDemo = false
    call JefePres_Iniciar()
endfunction

// Una vez por repaso del HUD, igual en todos los clientes: animación del jefe al entrar, el trueno con el tajo y el
// nivel de los textos tapados.
function JefePres_Tick takes nothing returns nothing
    local integer p = 0
    local real t
    local sound s
    local string anim = "attack"
    if not JefePres_Activa then
        return
    endif
    set t = TimerGetElapsed(JefePres_Reloj)
    call JefeTx_Aplicar(R2I(8. * RMinBJ(RMinBJ(1., t / 0.15), RMaxBJ(0., RMinBJ(1., (3.18 - t) / 0.15))) + 0.5))
    if not JefePres_Anim and t >= 0.50 then
        set JefePres_Anim = true
        if JefePres_N == 5 or JefePres_N == 6 or JefePres_N == 8 then
            set anim = "spell"
        endif
        loop
            exitwhen p > 11
            if JefePres_Pieza[p * 48 + 4] != null then
                call SetUnitAnimation(JefePres_Pieza[p * 48 + 4], anim)
                call QueueUnitAnimation(JefePres_Pieza[p * 48 + 4], "stand")
            endif
            set p = p + 1
        endloop
    endif
    if not JefePres_Trueno and t >= 0.70 then
        set JefePres_Trueno = true
        set s = CreateSound(Son_Trueno[9], false, false, false, 10, 10, "DefaultEAXON")
        call SetSoundVolume(s, 110)
        call StartSound(s)
        call KillSoundWhenDone(s)
        set s = null
    endif
endfunction

function JefePres_Poner takes integer p, integer cam returns nothing
    local integer b = p * 48
    local integer k
    local integer a
    local integer r = 0
    local real t
    local real fin
    local real vis
    local real x
    if not JefePres_Activa or JefePres_Pieza[b] == null then
        return
    endif
    set t = TimerGetElapsed(JefePres_Reloj)
    set fin = RMaxBJ(0., RMinBJ(1., (3.18 - t) / 0.15))
    set vis = RMinBJ(RMinBJ(1., t / 0.15), fin)
    // Fondo: azul casi negro al 65 %, delante del HUD.
    call HealthBars__Place(JefePres_Pieza[b], cam, 961., 432., 380.)
    call JefePres_Alfa(p, JefePres_Pieza[b], R2I(165. * vis), false)
    // Ráfagas hacia la derecha; al salir por la derecha vuelven por la izquierda.
    set k = 0
    loop
        exitwhen k >= 28
        set x = ModuloReal(JefePres_RX[k] + JefePres_RV[k] * t, 2920.) - 500.
        call HealthBars__Place(JefePres_Pieza[b + 10 + k], cam, x, JefePres_RY[k], 376.)
        call JefePres_Alfa(p, JefePres_Pieza[b + 10 + k], R2I(JefePres_RA[k] * vis), true)
        set k = k + 1
    endloop
    // Franja del nombre, suave.
    call HealthBars__Place(JefePres_Pieza[b + 1], cam, 550., 418., 222.)
    call JefePres_Alfa(p, JefePres_Pieza[b + 1], R2I(150. * RMinBJ(1., RMaxBJ(0., (t - 0.13) / 0.35)) * fin), true)
    // WARNING, quieto.
    call HealthBars__Place(JefePres_Pieza[b + 2], cam, 636., 283., 200.)
    call JefePres_Alfa(p, JefePres_Pieza[b + 2], R2I(255. * RMinBJ(1., t / 0.10) * fin), false)
    // Nombre: entra desde la izquierda, deriva a la derecha y sale por la izquierda.
    if t < 3.03 then
        set x = -560. + 1074. * JefePres_Frena((t - 0.50) / 0.15) + 25. * RMaxBJ(0., t - 0.65)
    else
        set x = 573.5 - 1133.5 * JefePres_Acelera((t - 3.03) / 0.15)
    endif
    call HealthBars__Place(JefePres_Pieza[b + 3], cam, x, 418., 200.)
    set a = 0
    if t >= 0.50 and t < 3.18 then
        set a = 255
    endif
    call JefePres_Alfa(p, JefePres_Pieza[b + 3], a, false)
    // Jefe: entra desde la derecha, deriva a la izquierda y sale por la derecha.
    if t < 3.03 then
        set x = 2260. - 780. * JefePres_Frena((t - 0.50) / 0.15) - 48. * RMaxBJ(0., t - 0.65)
    else
        set x = 1365.76 + 894.24 * JefePres_Acelera((t - 3.03) / 0.15)
    endif
    call HealthBars__Place(JefePres_Pieza[b + 4], cam, x + JefePres_OX[JefePres_N], JefePres_OY[JefePres_N], 260.)
    call JefePres_Alfa(p, JefePres_Pieza[b + 4], a, false)
    // Rayo cuadro a cuadro: tajo, tres trazos y chispas que se apagan.
    if t >= 0.70 and t < 1.32 then
        if t < 0.80 then
            set r = 1
        elseif t < 0.90 then
            set r = 2
        elseif t < 1.03 then
            set r = 3
        elseif t < 1.20 then
            set r = 4
        else
            set r = 5
        endif
    endif
    set a = 255
    if r == 5 then
        set a = R2I(255. * (1.32 - t) / 0.12)
    endif
    set k = 1
    loop
        exitwhen k > 5
        call HealthBars__Place(JefePres_Pieza[b + 4 + k], cam, 895., 432., 215.)
        if k == r then
            call JefePres_Alfa(p, JefePres_Pieza[b + 4 + k], a, true)
        else
            call JefePres_Alfa(p, JefePres_Pieza[b + 4 + k], 0, true)
        endif
        set k = k + 1
    endloop
endfunction

'''.replace('@MEDIDAS@', ''.join(medidas))
j = j[:ini] + crlf(BLOQUE) + j[fin:]
una('if JefePres_Pieza[p * 32 + 4]', 'if JefePres_Pieza[p * 32 + 4]', 0)
assert 'p * 32' not in j[j.index('// v17h: presentaci\xf3n del jefe de ronda'):j.index('function HealthBarsUpdate takes nothing')]
Path(sys.argv[3]).write_bytes(j.encode('latin-1'))

if len(sys.argv) > 4:
    una('function HealthBarsUpdate takes nothing returns nothing\n', '''// v17h-prueba: "-pres N" muestra la presentación del jefe de la ronda N (2..10) sin tocar la oleada.
function JefePres_Comando takes nothing returns nothing
    local integer n = S2I(SubString(GetEventPlayerChatString(), 6, 8))
    if JefePres_Activa then
        return
    endif
    if n < 2 or n > 10 then
        set n = 2
    endif
    set JefePres_N = n
    set JefePres_EsDemo = true
    call JefePres_Iniciar()
endfunction

function JefePres_Registrar takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer p = 0
    loop
        exitwhen p > 11
        call TriggerRegisterPlayerChatEvent(t, Player(p), "-pres", false)
        set p = p + 1
    endloop
    call TriggerAddAction(t, function JefePres_Comando)
    set t = null
endfunction

function HealthBarsUpdate takes nothing returns nothing
''')
    una('    call Son_Init()\n', '    call Son_Init()\n    call JefePres_Registrar()\n')
    Path(sys.argv[4]).write_bytes(j.encode('latin-1'))
print('v17i: presentación ajustada, textos tapados' + (' y -pres' if len(sys.argv) > 4 else ''))
