#!/usr/bin/env python3
"""v18k (15/11/2026): cuadro de puntuación al estilo "Round Score" de Dark Moon y libro de habilidades (fase 6).

Cuadro (Leon: formato del vídeo original 20261115_002900 con sus sonidos, en el centro, entra desde arriba y al irse
baja hasta no verse). Sustituye al de v18j; las notas y su cálculo (Punt_Calcular) no cambian.
- Pieza 'DSP3' (puntos_v18k.py, 600 × 470 px, centro (960, 380)) a 412 y las estrellas 'DSP1'/'DSP2' de v18j a 380
  en la casilla "Nota de la ronda".
- Tabla de jugadores (hasta 4 filas, por orden de jugador): nombre, bajas, caídas y bolsas de la oleada. Cada columna
  es un texttag con un renglón en blanco entre filas (1095 px por unidad de tamaño entre renglones, medido).
- Abajo: bolsas recogidas, bolsas perdidas, caídas del equipo (sobre la lápida) y las estrellas.
- Recuento por pasos como holdout_scoreboard.js de Dark Moon (orden y sonidos del original): al abrir "RoundSuccess"
  (fanfarria); recogidas de una en una (paso 0,2 s, o menos si son muchas: la fase dura a lo sumo 2,4 s) con
  "GoldRising" en bucle y "GoldRisingEnd" al llegar; perdidas con "Item.DropWorld" por cada una; caídas con
  "TowerCountUp" por cada una; estrellas cada 0,4 s con "StarLevel" (bigtreant_step 01/02). 3 s quieto y se va.
  Volumen = 127 × el del evento de Dark Moon. Los sonidos se crean en todos los clientes; sólo suenan para quien ve
  el cuadro (volumen local, como el tic de v18a).
- Animación: entra en 0,4 s desde encima de la pantalla (frenando) y sale en 0,5 s hacia abajo (acelerando).
- Textos: el centro de mayúsculas y cifras queda en cy con la posición cy − 150 × tamaño (corrige los ~14 px de
  más arriba medidos en la prueba de v18j-prueba). Texttags por cliente: 7 (antes 3).
Libro (fase 6, Leon: las 6 de D.O.N dentro del libro y siguen funcionando; el del Tauren con Onda de choque y Pisotón
sin efecto): el controlador recibe un 'Aspb' (objetos_v18k.py) en la casilla (3,2) en vez de los botones puente.
Prueba: registros lat\\v18k-*.txt.
Uso: v18k.py v18j/war3map.j SALIDA.j DIR_PUNTOS_V18K [prueba]
"""
from pathlib import Path
import json, sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
C = json.loads((Path(sys.argv[3]) / 'etiquetas.json').read_text())['cuadro']
prueba = len(sys.argv) > 4 and sys.argv[4] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
u8 = lambda s: s.encode('utf-8').decode('latin-1')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(u8(antes)), crlf(u8(despues))
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


X0, Y0, W, H = C['x0'], C['y0'], C['w'], C['h']
CX, CY = X0 + W / 2, Y0 + H / 2
TF = C['tam_fila']
FILA0 = Y0 + C['filas'][0]
COL = {k: X0 + v for k, v in C['cols'].items()}
CAS = [X0 + (a + b) / 2 for a, b in C['casillas']]
NUMY = Y0 + C['num_y']
LAPY = Y0 + C['lapida'][1]
ESTY = Y0 + C['estrellas_y']
TN = 0.028                                    # cifras de abajo
SON = {  # archivo, duración en ms, volumen (127 × el de Dark Moon)
    'fan': ('PuntFanfarria', 6400, 114), 'sube': ('PuntSube', 2802, 38), 'subefin': ('PuntSubeFin', 1311, 51),
    'pierde': ('PuntPerdida', 971, 127), 'tic': ('PuntTic', 997, 127), 'est1': ('PuntEstrella1', 1459, 102),
    'est2': ('PuntEstrella2', 1469, 102)}
ruta = lambda k: f'war3mapImported\\\\{SON[k][0]}.wav'

una('integer array Punt_TT\n', '''integer array Punt_TT
unit array Punt_Cuadro
integer array Punt_BajasJ
integer array Punt_CaidasJ
integer array Punt_BolsasJ
integer array Punt_Mostr
integer array Punt_Son
real array Punt_Ini
real array Punt_Paso
real Punt_Sale = 0.
sound Punt_Bucle = null
string Punt_ColN = ""
string Punt_ColB = ""
string Punt_ColC = ""
string Punt_ColO = ""
''')

# --- El cuadro de v18j se sustituye entero (creación, reloj y colocación) ---
i = j.index(crlf('// v18j: piezas y textos del cuadro de puntuación de fin de ronda del jugador p.\n'.encode('utf-8')
                 .decode('latin-1')))
f = j.index(crlf("// Fondos ('DSC0' desde v18c, dorado o violeta) y 5 textos locales por jugador; los iconos, en "
                 "Sup_Pintar.\n"), i)
nuevo = f'''// v18j: piezas del cuadro de puntuación de fin de ronda del jugador p.
function Punt_Pieza takes integer p, real w, real h, integer tex returns unit
    local unit u = HealthBars__Dummy('uidb', p)
    call UnitAddAbility(u, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
    call Arm_Foto(u, w, h, tex)
    call ShowUnit(u, false)
    return u
endfunction

// v18k: cuadro 'DSP3' (puntos_v18k.py), 3 estrellas llenas y 3 apagadas, y 7 textos locales: 4 columnas de la tabla
// (nombre, bajas, caídas, bolsas) y las cifras de bolsas recogidas, perdidas y caídas del equipo.
function Punt_HudCrear takes integer p returns nothing
    local integer k = 0
    set Punt_Cuadro[p] = Punt_Pieza(p, {W}. * 412. / 400., {H}. * 412. / 400., 'DSP3')
    loop
        exitwhen k > 2
        set Punt_Est[p * 6 + k] = Punt_Pieza(p, 38. * 380. / 400., 38. * 380. / 400., 'DSP1')
        set Punt_Est[p * 6 + 3 + k] = Punt_Pieza(p, 38. * 380. / 400., 38. * 380. / 400., 'DSP2')
        set k = k + 1
    endloop
    set k = 0
    loop
        exitwhen k > 6
        set Punt_TT[p * 8 + k] = s__UIText_createEx(Player(p), 0., 0., 1.)
        call SetTextTagPermanent(s__UIText_text[Punt_TT[p * 8 + k]], true)
        call JefeTx_Color(Punt_TT[p * 8 + k], s__UIText_text[Punt_TT[p * 8 + k]], 240, 238, 232)
        set k = k + 1
    endloop
    call JefeTx_Color(Punt_TT[p * 8 + 4], s__UIText_text[Punt_TT[p * 8 + 4]], 255, 220, 140)
    set Punt_Visto[p] = 0
    set Punt_Ok[p] = true
endfunction

function Punt_Visible takes integer p returns boolean
    return Punt_T >= 0. and Punt_Ok[p] and HealthBars__Visible and Game_On[p] and not Shop_Open[p] and not Cua_Open[p]
endfunction

// Valor del recuento en el instante Punt_T: 0 antes de s, luego uno más cada st hasta n.
function Punt_Val takes real s, real st, integer n returns integer
    if Punt_T < s or n <= 0 then
        return 0
    endif
    return IMinBJ(n, 1 + R2I((Punt_T - s) / st + 0.001))
endfunction

// Sonido del cuadro: se crea en todos los clientes; sólo lo oye quien ve el cuadro.
function Punt_Sonar takes string f, integer dur, integer vol returns nothing
    local sound snd = CreateSound(f, false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(snd, dur)
    call SetSoundChannel(snd, 0)
    call SetSoundVolume(snd, 0)
    if Punt_Visible(GetPlayerId(GetLocalPlayer())) then
        call SetSoundVolume(snd, vol)
    endif
    call StartSound(snd)
    call KillSoundWhenDone(snd)
    set snd = null
endfunction

function Punt_BucleFin takes nothing returns nothing
    if Punt_Bucle != null then
        call StopSound(Punt_Bucle, false, false)
    endif
endfunction

// Una vez por tick del HUD (0,01 s), igual en todos los clientes: sonidos del recuento (orden de Dark Moon).
function Punt_Tick takes nothing returns nothing
    local integer v
    if Punt_T < 0. then
        return
    endif
    if Punt_Son[0] == 0 then
        set Punt_Son[0] = 1
        call Punt_Sonar("{ruta('fan')}", {SON['fan'][1]}, {SON['fan'][2]})
    endif
    // 1. Bolsas recogidas: bucle mientras sube y final al llegar.
    set v = Punt_Val(Punt_Ini[1], Punt_Paso[1], Punt_Cogidas)
    if v > 0 and Punt_Son[1] == 0 then
        if Punt_Bucle == null then
            set Punt_Bucle = CreateSound("{ruta('sube')}", true, false, false, 10, 10, "DefaultEAXON")
            call SetSoundDuration(Punt_Bucle, {SON['sube'][1]})
            call SetSoundChannel(Punt_Bucle, 0)
        endif
        call SetSoundVolume(Punt_Bucle, 0)
        if Punt_Visible(GetPlayerId(GetLocalPlayer())) then
            call SetSoundVolume(Punt_Bucle, {SON['sube'][2]})
        endif
        call StartSound(Punt_Bucle)
    endif
    if v > Punt_Son[1] then
        set Punt_Son[1] = v
    endif
    if Punt_Son[5] == 0 and Punt_T >= Punt_Ini[1] + Punt_Paso[1] * Punt_Cogidas then
        set Punt_Son[5] = 1
        call Punt_BucleFin()
        call Punt_Sonar("{ruta('subefin')}", {SON['subefin'][1]}, {SON['subefin'][2]})
    endif
    // 2. Bolsas perdidas, 3. caídas del equipo y 4. estrellas: un sonido por paso.
    if Punt_Son[2] < Punt_Val(Punt_Ini[2], Punt_Paso[2], Punt_Perdidas) then
        set Punt_Son[2] = Punt_Son[2] + 1
        call Punt_Sonar("{ruta('pierde')}", {SON['pierde'][1]}, {SON['pierde'][2]})
    endif
    if Punt_Son[3] < Punt_Val(Punt_Ini[3], Punt_Paso[3], Punt_Caidas) then
        set Punt_Son[3] = Punt_Son[3] + 1
        call Punt_Sonar("{ruta('tic')}", {SON['tic'][1]}, {SON['tic'][2]})
    endif
    if Punt_Son[4] < Punt_Val(Punt_Ini[4], 0.4, Punt_Estrellas) then
        set Punt_Son[4] = Punt_Son[4] + 1
        if Punt_Son[4] == 2 then
            call Punt_Sonar("{ruta('est2')}", {SON['est2'][1]}, {SON['est2'][2]})
        else
            call Punt_Sonar("{ruta('est1')}", {SON['est1'][1]}, {SON['est1'][2]})
        endif
    endif
    set Punt_T = Punt_T + 0.01
    if Punt_T >= Punt_Sale + 0.5 then
        set Punt_T = -1.
        call Punt_BucleFin()
    endif
endfunction

// Texto con el centro de mayúsculas y cifras en (x izquierda, cy) de pantalla.
function Punt_Pos takes integer ui, real x, real cy, real size returns nothing
    call s__UIText_setPosition(ui, (x - 960.) / 728., (420. - (cy - 150. * size)) / 390.)
endfunction

// Cifra centrada en cx (Friz: ~0,55 de ancho por cifra).
function Punt_PosC takes integer ui, integer v, real cx, real cy, real size returns nothing
    call Punt_Pos(ui, cx - StringLength(I2S(v)) * 271. * size, cy, size)
endfunction

function Punt_Hud takes integer p, integer cam returns nothing
    local boolean shown
    local integer k = 0
    local integer v
    local integer n
    local real dy = 0.
    local real a
    if not Punt_Ok[p] then
        return
    endif
    set shown = Punt_Visible(p)
    if Punt_Visto[p] != Punt_Ver then
        set Punt_Visto[p] = Punt_Ver
        call JefeTx_Texto(Punt_TT[p * 8], s__UIText_text[Punt_TT[p * 8]], Punt_ColN, {TF})
        call JefeTx_Texto(Punt_TT[p * 8 + 1], s__UIText_text[Punt_TT[p * 8 + 1]], Punt_ColB, {TF})
        call JefeTx_Texto(Punt_TT[p * 8 + 2], s__UIText_text[Punt_TT[p * 8 + 2]], Punt_ColC, {TF})
        call JefeTx_Texto(Punt_TT[p * 8 + 3], s__UIText_text[Punt_TT[p * 8 + 3]], Punt_ColO, {TF})
        set Punt_Mostr[p * 8 + 4] = -1
        set Punt_Mostr[p * 8 + 5] = -1
        set Punt_Mostr[p * 8 + 6] = -1
    endif
    // Entrada desde arriba en 0,4 s (frenando) y salida hacia abajo en 0,5 s (acelerando).
    if Punt_T < 0.4 then
        set a = 1. - Punt_T / 0.4
        set dy = -640. * a * a * a
    elseif Punt_T > Punt_Sale then
        set a = RMinBJ(1., (Punt_T - Punt_Sale) / 0.5)
        set dy = 960. * a * a
    endif
    call Hud_Ver(Punt_Cuadro[p], shown)
    set n = Punt_Val(Punt_Ini[4], 0.4, Punt_Estrellas)
    loop
        exitwhen k > 2
        call Hud_Ver(Punt_Est[p * 6 + k], shown and k < n)
        call Hud_Ver(Punt_Est[p * 6 + 3 + k], shown and k >= n)
        set k = k + 1
    endloop
    set k = 0
    loop
        exitwhen k > 6
        call s__UIText_show(Punt_TT[p * 8 + k], shown, cam)
        set k = k + 1
    endloop
    if not shown then
        return
    endif
    call HealthBars__Place(Punt_Cuadro[p], cam, {CX}, {CY} + dy, 412.)
    set k = 0
    loop
        exitwhen k > 2
        call HealthBars__Place(Punt_Est[p * 6 + k], cam, {CAS[3] - 40} + 40. * k, {ESTY} + dy, 380.)
        call HealthBars__Place(Punt_Est[p * 6 + 3 + k], cam, {CAS[3] - 40} + 40. * k, {ESTY} + dy, 380.)
        set k = k + 1
    endloop
    call Punt_Pos(Punt_TT[p * 8], {COL['JUGADOR']}, {FILA0} + dy, {TF})
    call Punt_Pos(Punt_TT[p * 8 + 1], {COL['BAJAS'] - 6}, {FILA0} + dy, {TF})
    call Punt_Pos(Punt_TT[p * 8 + 2], {COL['CAÍDAS'] - 6}, {FILA0} + dy, {TF})
    call Punt_Pos(Punt_TT[p * 8 + 3], {COL['BOLSAS'] - 6}, {FILA0} + dy, {TF})
    // Cifras de abajo: el texto sólo cambia con el recuento.
    set v = Punt_Val(Punt_Ini[1], Punt_Paso[1], Punt_Cogidas)
    if v != Punt_Mostr[p * 8 + 4] then
        set Punt_Mostr[p * 8 + 4] = v
        call JefeTx_Texto(Punt_TT[p * 8 + 4], s__UIText_text[Punt_TT[p * 8 + 4]], I2S(v), {TN})
    endif
    call Punt_PosC(Punt_TT[p * 8 + 4], v, {CAS[0]}, {NUMY} + dy, {TN})
    set v = Punt_Val(Punt_Ini[2], Punt_Paso[2], Punt_Perdidas)
    if v != Punt_Mostr[p * 8 + 5] then
        set Punt_Mostr[p * 8 + 5] = v
        call JefeTx_Texto(Punt_TT[p * 8 + 5], s__UIText_text[Punt_TT[p * 8 + 5]], I2S(v), {TN})
    endif
    call Punt_PosC(Punt_TT[p * 8 + 5], v, {CAS[1]}, {NUMY} + dy, {TN})
    set v = Punt_Val(Punt_Ini[3], Punt_Paso[3], Punt_Caidas)
    if v != Punt_Mostr[p * 8 + 6] then
        set Punt_Mostr[p * 8 + 6] = v
        call JefeTx_Texto(Punt_TT[p * 8 + 6], s__UIText_text[Punt_TT[p * 8 + 6]], I2S(v), {TN})
    endif
    call Punt_PosC(Punt_TT[p * 8 + 6], v, {CAS[2]}, {LAPY} + dy, {TN})
endfunction

'''
j = j[:i] + crlf(u8(nuevo)) + j[f:]

# --- Recuento por jugador ---
una('    set Racha_Total[p] = Racha_Total[p] + 1\n', '''    set Racha_Total[p] = Racha_Total[p] + 1
    if not Ronda_Descanso then
        set Punt_BajasJ[p] = Punt_BajasJ[p] + 1
    endif
''')
una('''    if not Ronda_Descanso then
        set Punt_Caidas = Punt_Caidas + 1
''', '''    if not Ronda_Descanso then
        set Punt_Caidas = Punt_Caidas + 1
        set Punt_CaidasJ[p] = Punt_CaidasJ[p] + 1
''')
una('    set Punt_Cogidas = Punt_Cogidas + 1\n', '''    set Punt_Cogidas = Punt_Cogidas + 1
    set Punt_BolsasJ[p] = Punt_BolsasJ[p] + 1
''')

# --- Tiempos del recuento y textos de la tabla, al puntuar; reinicio al empezar la oleada ---
una('// v18j: estrellas de la ronda que acaba de terminar (ver v18j.py).\n', '''// v18k: tiempos del recuento (Punt_Ini, Punt_Paso, Punt_Sale) y columnas de la tabla, igual en todos los clientes.
function Punt_Preparar takes nothing returns nothing
    local integer q = 0
    local integer f = 0
    local string sep = ""
    set Punt_Ini[1] = 1.
    set Punt_Paso[1] = RMinBJ(0.2, 2.4 / IMaxBJ(1, Punt_Cogidas))
    set Punt_Ini[2] = Punt_Ini[1] + Punt_Paso[1] * Punt_Cogidas + 0.4
    set Punt_Paso[2] = RMinBJ(0.2, 2. / IMaxBJ(1, Punt_Perdidas))
    set Punt_Ini[3] = Punt_Ini[2] + Punt_Paso[2] * Punt_Perdidas + 0.4
    set Punt_Paso[3] = RMinBJ(0.2, 2. / IMaxBJ(1, Punt_Caidas))
    set Punt_Ini[4] = Punt_Ini[3] + Punt_Paso[3] * Punt_Caidas + 0.4
    set Punt_Sale = Punt_Ini[4] + 0.4 * Punt_Estrellas + 3.
    loop
        exitwhen q > 5
        set Punt_Son[q] = 0
        set q = q + 1
    endloop
    call Punt_BucleFin()
    set Punt_ColN = ""
    set Punt_ColB = ""
    set Punt_ColC = ""
    set Punt_ColO = ""
    set q = 0
    loop
        exitwhen q > 7 or f >= 4
        if Game_On[q] then
            set Punt_ColN = Punt_ColN + sep + Racha_NombreJ(q)
            set Punt_ColB = Punt_ColB + sep + I2S(Punt_BajasJ[q])
            set Punt_ColC = Punt_ColC + sep + I2S(Punt_CaidasJ[q])
            set Punt_ColO = Punt_ColO + sep + I2S(Punt_BolsasJ[q])
            set sep = "|n|n"
            set f = f + 1
        endif
        set q = q + 1
    endloop
endfunction

function Punt_Reiniciar takes nothing returns nothing
    local integer q = 0
    loop
        exitwhen q > 7
        set Punt_BajasJ[q] = 0
        set Punt_CaidasJ[q] = 0
        set Punt_BolsasJ[q] = 0
        set q = q + 1
    endloop
endfunction

// v18j: estrellas de la ronda que acaba de terminar (ver v18j.py).
''')
una('    set Punt_T = 0.\n', '    call Punt_Preparar()\n    set Punt_T = 0.\n')
una('''    set Punt_Perdidas = 0
    set Punt_T = -1.
''', '''    set Punt_Perdidas = 0
    set Punt_T = -1.
    call Punt_BucleFin()
    call Punt_Reiniciar()
''')

# --- Libro de habilidades (fase 6) ---
una('''function Gk_Botones takes integer p returns nothing
    call UnitAddAbility(Game_Ctrl[p], 'AGk1')
    call UnitAddAbility(Game_Ctrl[p], 'AGk2')
    call UnitAddAbility(Game_Ctrl[p], 'AGk3')
    call UnitAddAbility(Game_Ctrl[p], 'AGk4')
    call UnitAddAbility(Game_Ctrl[p], 'AGk5')
endfunction''', '''// v18k: los 5 puentes van dentro del libro 'ALGk' (objetos_v18k.py).
function Gk_Botones takes integer p returns nothing
    call UnitAddAbility(Game_Ctrl[p], 'ALGk')
endfunction''')
for P, uid in (('Fz', 'hFrz'), ('Tr', 'hTrk'), ('Na', 'hNar')):
    una(f'''    if id == '{uid}' then
''' + ''.join(f"        call UnitAddAbility(Game_Ctrl[p], 'A{P}{k}')\n" for k in range(1, 7)) + '''    endif
''', f'''    if id == '{uid}' then
        call UnitAddAbility(Game_Ctrl[p], 'AL{P}')
    endif
''')
una('''function Don_Botones takes integer p, integer id returns nothing
''', '''// v18k: los 6 puentes de cada héroe de D.O.N van dentro de su libro; el Tauren lleva el suyo con Onda de choque y
// Pisotón de guerra sólo como iconos (objetos_v18k.py).
function Don_Botones takes integer p, integer id returns nothing
    if id != 'hGok' and id != 'hFrz' and id != 'hTrk' and id != 'hNar' then
        call UnitAddAbility(Game_Ctrl[p], 'ALTa')
    endif
''')
assert "UnitAddAbility(Game_Ctrl[p], 'AFz1')" not in j and "'AGk1')\r\n    call UnitAddAbility" not in j

if prueba:
    for n in ('super', 'precarga', 'bolsas', 'cuadros'):
        una(f'call PreloadGenEnd("lat\\\\v18j-{n}.txt")', f'call PreloadGenEnd("lat\\\\v18k-{n}.txt")')
    assert 'PreloadGenEnd("lat\\\\v18j-' not in j
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v18k: cuadro de puntuación al estilo Dark Moon y libro de habilidades' + (' + registro' if prueba else ''))
