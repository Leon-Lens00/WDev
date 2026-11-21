#!/usr/bin/env python3
"""v17h (14/11/2026): presentación del jefe de ronda antes de que aparezca.

Leon (14/11/2026), con un vídeo de presentación de jefe: "a cambio del texto japones va el nombre del boss de ronda,
saldra el modelo del boss tambien ejecutando la animacion de ataque al aparecer en pantalla, se dibuja tambien como un
rayo al centro ... oscurecer algo el fondo y esas rafagas de viento"; y después: "al acabar con la ultima unidad para
que salga el jefe, antes de generar o hacer aparecer al jefe mostrara esa presentacion, al terminar recien dara spawn
el boss ... los movimientos de los elementos iguales al del video".

- La puerta del jefe (s__Wave_killGatePassed: sólo queda él por matar) arranca la presentación una vez y no deja salir
  al jefe hasta que termina (JefePres_Lista); la ronda la deja preparada al añadir su jefe.
- Tiempos medidos cuadro a cuadro en el vídeo (30 cuadros/s), en s desde el inicio:
  0-0,15 fondo oscuro, ráfagas y WARNING aparecen; 0,13-0,48 se enciende la franja del nombre;
  0,50-0,65 el nombre entra desde la izquierda y el jefe desde la derecha (frenando); 0,65-3,03 el nombre deriva a la
  derecha 25 px/s y el jefe a la izquierda 48 px/s; 0,70 tajo recto y trueno; 0,80 / 0,90 / 1,03 trazos ondulados;
  1,20-1,32 chispas; 3,03-3,18 todo sale y el fondo se aclara; 3,20 aparece el jefe.
- Piezas por jugador (alfa local, como el HUD; posiciones en HealthBarsUpdate con su cámara lógica), ordenadas por
  distancia: fondo oscuro 1500, ráfagas 1400 (aditivas), jefe 900, franja 450 (aditiva), rayo 430 (aditivo), WARNING y
  nombre 400. Sin filtro de cine: taparía también las piezas.
- El jefe es su modelo del juego girado a esta cámara y sin sombra ni niebla (jefe_modelos_v17h.py), en 'upj2'..'upjA'
  (objetos_v17h.py), con la animación de ataque ("spell" para 5, 6 y 8, como DevJefe_Llamar) al entrar.
Las medidas del jefe (escala y origen en pantalla) salen de los límites que imprime jefe_modelos_v17h.py.

Uso: v17h.py BASE.j LIMITES.json SALIDA.j [SALIDA-PRUEBA.j]
La de prueba añade el comando "-pres N" (N = ronda 2..10): sólo la presentación, sin tocar la oleada.
"""
from pathlib import Path
import json, sys

MODELOS = ['Lobstrokkred', 'SeaTurtleRange', 'MurgulTideWarrior', 'MurgulShadowCaster', 'Lobstrokkblue',
           'MurlocMutant', 'NagaSiren', 'GiantSeaTurtle', 'DragonSeaTurtle']
KH, KV = 0.544 / 718.18930543, 0.302 / 387.73819261   # unidades por px a distancia 1 (horizontal, vertical)
D_JEFE = 900.
ALTO, ANCHO, SUELO = 700., 640., 820.                # caja del jefe en px y su borde de abajo

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
limites = json.loads(Path(sys.argv[2]).read_text())
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')


def una(antes, despues):
    global j
    antes, despues = crlf(antes), crlf(despues)
    assert j.count(antes) == 1, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


medidas = []
for k, nombre in enumerate(MODELOS):
    m = limites[nombre]
    ancho = m['der'] - m['izq']
    s = min(ALTO * KV * D_JEFE / m['alto'], ANCHO * KH * D_JEFE / ancho)
    ox = -(m['izq'] + m['der']) / 2 * s / (KH * D_JEFE)          # origen respecto al centro de la caja, px
    oy = SUELO + m['abajo'] * s / (KV * D_JEFE)                   # origen en pantalla, px
    medidas.append(f'    set JefePres_Escala[{k + 2}] = {s:.4f}\n    set JefePres_OX[{k + 2}] = {ox:.1f}\n'
                   f'    set JefePres_OY[{k + 2}] = {oy:.1f}\n')

una('timer DevJefe_Carga= null\n', '''timer DevJefe_Carga= null
// v17h: presentación del jefe (JefePres_*).
boolean JefePres_Activa= false
boolean JefePres_Lista= false
boolean JefePres_EsDemo= false
boolean JefePres_Anim= false
boolean JefePres_Trueno= false
integer JefePres_Ronda= 0
integer JefePres_N= 2
timer JefePres_Reloj= null
unit JefePres_U= null
unit array JefePres_Pieza
real array JefePres_RX
real array JefePres_RY
real array JefePres_RL
real array JefePres_RV
real array JefePres_RA
real array JefePres_Escala
real array JefePres_OX
real array JefePres_OY
''')

FUNCIONES = r'''
// v17h: presentación del jefe de ronda (scripts/v17h.py). Piezas por jugador en JefePres_Pieza[p * 32 + i]:
// 0 fondo, 1 franja, 2 WARNING, 3 nombre, 4 jefe, 5..9 rayo, 10..25 ráfagas. Todos los clientes crean y mueven las de
// todos (como HealthBars__Dummy); sólo el alfa es local.
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

// Como HealthBars__Dummy, invisible para todos hasta el primer JefePres_Poner; la textura sólo prende al crearlo.
function JefePres_Dummy takes integer kind, integer tex, real wpx, real hpx, real depth, real facing returns unit
    set JefePres_U = CreateUnit(CAMERA_DUMMY_PLAYER, kind, 0, 0, facing)
    call UnitAddAbility(JefePres_U, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(JefePres_U, s__Interface_DESTROYER_FORM_ID)
    call SetUnitInvulnerable(JefePres_U, true)
    call SetUnitBlendTime(JefePres_U, 0.)
    call SetUnitVertexColor(JefePres_U, 0, 0, 0, 0)
    if tex != 0 then
        call UserInterface_ApplySkin(JefePres_U, tex)
        call JefePres_Foto(JefePres_U, wpx, hpx, depth)
    endif
    return JefePres_U
endfunction

// Frenando (entrada) y acelerando (salida), con u recortado a 0..1.
function JefePres_Frena takes real u returns real
    set u = 1. - RMinBJ(1., RMaxBJ(0., u))
    return 1. - u * u * u
endfunction

function JefePres_Acelera takes real u returns real
    set u = RMinBJ(1., RMaxBJ(0., u))
    return u * u * u
endfunction

function JefePres_Medidas takes nothing returns nothing
@MEDIDAS@endfunction

function JefePres_Fin takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= 12 * 32
        if JefePres_Pieza[i] != null then
            call RemoveUnit(JefePres_Pieza[i])
            set JefePres_Pieza[i] = null
        endif
        set i = i + 1
    endloop
    set JefePres_Activa = false
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
        exitwhen k >= 16
        set JefePres_RL[k] = GetRandomReal(260., 900.)
        set JefePres_RX[k] = GetRandomReal(0., 2920.)
        set JefePres_RY[k] = GetRandomReal(10., 850.)
        set JefePres_RV[k] = GetRandomReal(2800., 4800.)
        set JefePres_RA[k] = GetRandomReal(70., 150.)
        set k = k + 1
    endloop
    loop
        exitwhen p > 11
        if HealthBars__Bound[p] then
            set b = p * 32
            set JefePres_Pieza[b] = JefePres_Dummy('uidb', 'DP00', 2000., 900., 1500., 270.)
            set JefePres_Pieza[b + 1] = JefePres_Dummy('uidg', 'DP02', 1500., 136.4, 450., 270.)
            set JefePres_Pieza[b + 2] = JefePres_Dummy('uidb', 'DP03', 848., 106., 400., 270.)
            set JefePres_Pieza[b + 3] = JefePres_Dummy('uidb', nombre, 960., 120., 400., 270.)
            set JefePres_Pieza[b + 4] = JefePres_Dummy(id, 0, 0., 0., 0., 0.)
            call SetUnitScale(JefePres_Pieza[b + 4], JefePres_Escala[JefePres_N], JefePres_Escala[JefePres_N], JefePres_Escala[JefePres_N])
            set k = 0
            loop
                exitwhen k >= 5
                set JefePres_Pieza[b + 5 + k] = JefePres_Dummy('uidg', 'DP04' + k, 420., 840., 430., 270.)
                set k = k + 1
            endloop
            set k = 0
            loop
                exitwhen k >= 16
                set JefePres_Pieza[b + 10 + k] = JefePres_Dummy('uidg', 'DP01', JefePres_RL[k], JefePres_RL[k] / 10., 1400., 270.)
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

// Una vez por repaso del HUD, igual en todos los clientes: animación del jefe al entrar y el trueno con el tajo.
function JefePres_Tick takes nothing returns nothing
    local integer p = 0
    local real t
    local sound s
    local string anim = "attack"
    if not JefePres_Activa then
        return
    endif
    set t = TimerGetElapsed(JefePres_Reloj)
    if not JefePres_Anim and t >= 0.50 then
        set JefePres_Anim = true
        if JefePres_N == 5 or JefePres_N == 6 or JefePres_N == 8 then
            set anim = "spell"
        endif
        loop
            exitwhen p > 11
            if JefePres_Pieza[p * 32 + 4] != null then
                call SetUnitAnimation(JefePres_Pieza[p * 32 + 4], anim)
                call QueueUnitAnimation(JefePres_Pieza[p * 32 + 4], "stand")
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
    local integer b = p * 32
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
    // Fondo: azul casi negro al 65 %.
    call HealthBars__Place(JefePres_Pieza[b], cam, 961., 432., 1500.)
    call JefePres_Alfa(p, JefePres_Pieza[b], R2I(165. * vis), false)
    // Ráfagas hacia la derecha; al salir por la derecha vuelven por la izquierda.
    set k = 0
    loop
        exitwhen k >= 16
        set x = ModuloReal(JefePres_RX[k] + JefePres_RV[k] * t, 2920.) - 500.
        call HealthBars__Place(JefePres_Pieza[b + 10 + k], cam, x, JefePres_RY[k], 1400.)
        call JefePres_Alfa(p, JefePres_Pieza[b + 10 + k], R2I(JefePres_RA[k] * vis), true)
        set k = k + 1
    endloop
    // Franja del nombre.
    call HealthBars__Place(JefePres_Pieza[b + 1], cam, 750., 418., 450.)
    call JefePres_Alfa(p, JefePres_Pieza[b + 1], R2I(255. * RMinBJ(1., RMaxBJ(0., (t - 0.13) / 0.35)) * fin), true)
    // WARNING, quieto.
    call HealthBars__Place(JefePres_Pieza[b + 2], cam, 636., 283., 400.)
    call JefePres_Alfa(p, JefePres_Pieza[b + 2], R2I(255. * RMinBJ(1., t / 0.10) * fin), false)
    // Nombre: entra desde la izquierda, deriva a la derecha y sale por la izquierda.
    if t < 3.03 then
        set x = -560. + 1074. * JefePres_Frena((t - 0.50) / 0.15) + 25. * RMaxBJ(0., t - 0.65)
    else
        set x = 573.5 - 1133.5 * JefePres_Acelera((t - 3.03) / 0.15)
    endif
    call HealthBars__Place(JefePres_Pieza[b + 3], cam, x, 418., 400.)
    set a = 0
    if t >= 0.50 and t < 3.18 then
        set a = 255
    endif
    call JefePres_Alfa(p, JefePres_Pieza[b + 3], a, false)
    // Jefe: entra desde la derecha, deriva a la izquierda y sale por la derecha.
    if t < 3.03 then
        set x = 2290. - 700. * JefePres_Frena((t - 0.50) / 0.15) - 48. * RMaxBJ(0., t - 0.65)
    else
        set x = 1475.76 + 814.24 * JefePres_Acelera((t - 3.03) / 0.15)
    endif
    call HealthBars__Place(JefePres_Pieza[b + 4], cam, x + JefePres_OX[JefePres_N], JefePres_OY[JefePres_N], 900.)
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
        call HealthBars__Place(JefePres_Pieza[b + 4 + k], cam, 895., 432., 430.)
        if k == r then
            call JefePres_Alfa(p, JefePres_Pieza[b + 4 + k], a, true)
        else
            call JefePres_Alfa(p, JefePres_Pieza[b + 4 + k], 0, true)
        endif
        set k = k + 1
    endloop
endfunction

function HealthBarsUpdate takes nothing returns nothing
'''.replace('@MEDIDAS@', ''.join(medidas))

una('\nfunction HealthBarsUpdate takes nothing returns nothing\n', FUNCIONES)
una('''    call Racha_Mover()
    loop
        exitwhen p > 11
        if HealthBars__Bound[p] then''', '''    call Racha_Mover()
    call JefePres_Tick()
    loop
        exitwhen p > 11
        if HealthBars__Bound[p] then''')
una('            call DevJefe_Poner(p , cam)\n', '            call DevJefe_Poner(p , cam)\n            call JefePres_Poner(p , cam)\n')
una('''            return s__Wave_toKillRemaining[this] <= s__WaveSlot_killGate[s]
        endfunction''', '''            if s__Wave_toKillRemaining[this] > s__WaveSlot_killGate[s] then
                return false
            endif
            // v17h: el jefe espera a su presentación, que se lanza una sola vez por ronda.
            if s__WaveSlot_isBoss[s] and not JefePres_Lista then
                if not JefePres_Activa then
                    call ExecuteFunc("JefePres_Empezar")
                endif
                return false
            endif
            return true
        endfunction''')
una('''        if n >= 2 then
            call WaveAddSlotExByPlayer(w , DevJefe_Tipo(n)''', '''        if n >= 2 then
            set JefePres_Ronda=n
            set JefePres_Lista=false
            call WaveAddSlotExByPlayer(w , DevJefe_Tipo(n)''')

assert 'ExecuteFunc("JefePres_Empezar")' in j and 'function JefePres_Empezar takes nothing' in j
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
print('v17h: presentación del jefe' + (' y -pres' if len(sys.argv) > 4 else ''))
