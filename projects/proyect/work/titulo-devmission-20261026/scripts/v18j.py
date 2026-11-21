#!/usr/bin/env python3
"""v18j (15/11/2026), fase 5: puntuación de fin de ronda con 1-3 estrellas, como "Round Score" de Dark Moon.

Notas (mínimo de las dos, como Dark Moon):
- Bolsas: de las que cayeron en la ronda, las caducadas. 3 si perdidas × 40 <= 3 × caídas (Dark Moon: <= 3 de 40),
  1 si perdidas × 40 >= 8 × caídas (>= 8 de 40), 2 en otro caso. Sin bolsas, 3.
- Caídas del equipo durante la oleada (s__RapidPair_fall; el héroe no muere, cae y se levanta con Reencarnación).
  Con J jugadores: 3 si caídas <= J / 4; 2 si caídas <= max(1, 3J / 4); 1 si más. Con J = 4 da los umbrales de Dark
  Moon (<= 1, <= 3, > 3); solo: 0 → 3, 1 → 2, 2 o más → 1.
Cuándo: la ronda se puntúa cuando ya no queda ninguna bolsa suya en el suelo (recogidas o caducadas; los cofres del
jefe caen al terminar), a lo sumo 36 s después del final y nunca pasado el descanso. Punt_Hist[ronda] guarda las
estrellas para la fase 9 (calidad de las mejoras del héroe).
Cuadro: pieza 'DSP0' (panel con las etiquetas fijas) a 412, 3 estrellas 'DSP1'/'DSP2' a 380 que aparecen una a una cada
0,3 s con el tic de la tirada (SupTic.wav) por cada estrella ganada, y 3 texttags (UIText) por jugador: título con la
ronda, bolsas recogidas / caídas, caídas del equipo. Se ve 8 s; se oculta con la tienda o los cuadros abiertos.
Las piezas se muestran con ShowUnit en código común (estado sincronizado); sólo su dueño las ve (HealthBars__Dummy).
Texttags por cliente: +3 fijos.
Prueba: las notas van al registro de bolsas, que pasa a lat\\v18j-bolsas.txt (y el resto a lat\\v18j-*.txt).
Uso: v18j.py v18i/war3map.j SALIDA.j [prueba]
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


# Disposición en px de pantalla (puntos_v18j.py).
PX, PY = 960, 175
EY, EX = 148, (900, 960, 1020)
F1, F2 = 205, 250
TX, VX = 754, 1060

una('unit array DevTienda_Pieza\n', '''unit array DevTienda_Pieza
integer Punt_Caidas = 0
integer Punt_Soltadas = 0
integer Punt_Cogidas = 0
integer Punt_Perdidas = 0
integer Punt_Estrellas = 0
integer Punt_Ronda = 0
integer Punt_Ver = 0
integer array Punt_Hist
integer array Punt_Visto
real Punt_T = -1.
real Punt_Espera = 0.
timer Punt_Reloj = null
boolean array Punt_Ok
unit array Punt_Fondo
unit array Punt_Est
integer array Punt_TT
''')

# --- Cuadro: creación, reloj de 0,01 s y colocación (antes de Sup_HudCrear, que va antes de su uso) ---
una('// Fondos (\'DSC0\' desde v18c, dorado o violeta) y 5 textos locales por jugador; los iconos, en Sup_Pintar.\n'
    'function Sup_HudCrear takes integer p returns nothing', f'''// v18j: piezas y textos del cuadro de puntuación de fin de ronda del jugador p.
function Punt_Pieza takes integer p, real w, real h, integer tex returns unit
    local unit u = HealthBars__Dummy('uidb', p)
    call UnitAddAbility(u, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
    call Arm_Foto(u, w, h, tex)
    call ShowUnit(u, false)
    return u
endfunction

function Punt_HudCrear takes integer p returns nothing
    local integer k = 0
    set Punt_Fondo[p] = Punt_Pieza(p, 460. * 412. / 400., 230. * 412. / 400., 'DSP0')
    loop
        exitwhen k > 2
        set Punt_Est[p * 6 + k] = Punt_Pieza(p, 54. * 380. / 400., 54. * 380. / 400., 'DSP1')
        set Punt_Est[p * 6 + 3 + k] = Punt_Pieza(p, 54. * 380. / 400., 54. * 380. / 400., 'DSP2')
        set Punt_TT[p * 3 + k] = s__UIText_createEx(Player(p), 0., 0., 1.)
        call SetTextTagPermanent(s__UIText_text[Punt_TT[p * 3 + k]], true)
        set k = k + 1
    endloop
    call JefeTx_Color(Punt_TT[p * 3], s__UIText_text[Punt_TT[p * 3]], 255, 220, 140)
    call JefeTx_Color(Punt_TT[p * 3 + 1], s__UIText_text[Punt_TT[p * 3 + 1]], 255, 220, 140)
    set Punt_Visto[p] = 0
    set Punt_Ok[p] = true
endfunction

function Punt_Visible takes integer p returns boolean
    return Punt_T >= 0. and Punt_Ok[p] and HealthBars__Visible and Game_On[p] and not Shop_Open[p] and not Cua_Open[p]
endfunction

// Una vez por tick del HUD (0,01 s), igual en todos los clientes; el tic de cada estrella ganada sólo suena para quien
// ve el cuadro (el sonido se crea en todos, sólo cambia el volumen).
function Punt_Tick takes nothing returns nothing
    local integer k = 0
    local sound snd
    if Punt_T < 0. then
        return
    endif
    loop
        exitwhen k >= Punt_Estrellas
        if Punt_T < 0.3 + 0.3 * k and Punt_T + 0.01 >= 0.3 + 0.3 * k then
            set snd = CreateSound("war3mapImported\\\\SupTic.wav", false, false, false, 10, 10, "DefaultEAXON")
            call SetSoundDuration(snd, 688)
            call SetSoundChannel(snd, 0)
            call SetSoundVolume(snd, 0)
            if Punt_Visible(GetPlayerId(GetLocalPlayer())) then
                call SetSoundVolume(snd, 110)
            endif
            call StartSound(snd)
            call KillSoundWhenDone(snd)
            set snd = null
        endif
        set k = k + 1
    endloop
    set Punt_T = Punt_T + 0.01
    if Punt_T >= 8. then
        set Punt_T = -1.
    endif
endfunction

function Punt_Texto takes integer ui, string s, real x, real cy, real size returns nothing
    call s__UIText_setPosition(ui, (x - 960.) / 728., (420. - (cy - 650. * size)) / 390.)
    call JefeTx_Texto(ui, s__UIText_text[ui], s, size)
endfunction

function Punt_Hud takes integer p, integer cam returns nothing
    local boolean shown
    local boolean b
    local integer k = 0
    if not Punt_Ok[p] then
        return
    endif
    set shown = Punt_Visible(p)
    if Punt_Visto[p] != Punt_Ver then
        set Punt_Visto[p] = Punt_Ver
        call Punt_Texto(Punt_TT[p * 3], "Puntuación de la ronda " + I2S(Punt_Ronda), {TX}., {PY - 115 + 30}., 0.022)
        call Punt_Texto(Punt_TT[p * 3 + 1], I2S(Punt_Cogidas) + " / " + I2S(Punt_Soltadas), {VX}., {F1}., 0.02)
        if Punt_Caidas > 0 then
            call JefeTx_Color(Punt_TT[p * 3 + 2], s__UIText_text[Punt_TT[p * 3 + 2]], 255, 120, 120)
        else
            call JefeTx_Color(Punt_TT[p * 3 + 2], s__UIText_text[Punt_TT[p * 3 + 2]], 150, 235, 150)
        endif
        call Punt_Texto(Punt_TT[p * 3 + 2], I2S(Punt_Caidas), {VX}., {F2}., 0.02)
    endif
    call Hud_Ver(Punt_Fondo[p], shown)
    if shown then
        call HealthBars__Place(Punt_Fondo[p], cam, {PX}., {PY}., 412.)
    endif
    loop
        exitwhen k > 2
        set b = shown and Punt_T >= 0.3 + 0.3 * k
        call Hud_Ver(Punt_Est[p * 6 + k], b and k < Punt_Estrellas)
        call Hud_Ver(Punt_Est[p * 6 + 3 + k], b and k >= Punt_Estrellas)
        if b then
            call HealthBars__Place(Punt_Est[p * 6 + k], cam, {EX[0]}. + 60. * k, {EY}., 380.)
            call HealthBars__Place(Punt_Est[p * 6 + 3 + k], cam, {EX[0]}. + 60. * k, {EY}., 380.)
        endif
        call s__UIText_show(Punt_TT[p * 3 + k], shown, cam)
        set k = k + 1
    endloop
endfunction

// Fondos ('DSC0' desde v18c, dorado o violeta) y 5 textos locales por jugador; los iconos, en Sup_Pintar.
function Sup_HudCrear takes integer p returns nothing''')
una('    call Sup_HudCrear(p)\n', '    call Sup_HudCrear(p)\n    call Punt_HudCrear(p)\n')
una('    call JefeBarra_Tick()\n', '    call JefeBarra_Tick()\n    call Punt_Tick()\n')
una('            call Sup_Hud(p , cam)\n', '            call Sup_Hud(p , cam)\n            call Punt_Hud(p , cam)\n')

# --- Recuento ---
una('    call Racha_Romper(p)\n', '''    call Racha_Romper(p)
    // v18j: caídas del equipo durante la oleada, para las estrellas.
    if not Ronda_Descanso then
        set Punt_Caidas = Punt_Caidas + 1
    endif
''')
una('    set Bolsa_T[Bolsa_N] = 35.\n', '    set Bolsa_T[Bolsa_N] = 35.\n    set Punt_Soltadas = Punt_Soltadas + 1\n')
una('    call Oro_Dar(p, Bolsa_Oro[i])\n', '    call Oro_Dar(p, Bolsa_Oro[i])\n    set Punt_Cogidas = Punt_Cogidas + 1\n')
una('        elseif Bolsa_T[i] <= 0. then\n', '        elseif Bolsa_T[i] <= 0. then\n            set Punt_Perdidas = Punt_Perdidas + 1\n')

# --- Nota al acabar ---
anota = ('    call Bolsa_Anotar("puntuacion r" + I2S(Punt_Ronda) + ": bolsas " + I2S(Punt_Soltadas) + ", recogidas " + '
         'I2S(Punt_Cogidas) + ", perdidas " + I2S(Punt_Perdidas) + " -> " + I2S(rb) + "; caidas " + I2S(Punt_Caidas) + '
         '" con J " + I2S(jug) + " -> " + I2S(rc) + "; estrellas " + I2S(Punt_Estrellas) + " a los " + '
         'R2SW(Punt_Espera, 1, 1) + " s del final")\n') if prueba else ''
una('function Ronda_Lanzar takes nothing returns nothing\n', f'''// v18j: estrellas de la ronda que acaba de terminar (ver v18j.py).
function Punt_Calcular takes nothing returns nothing
    local integer jug = IMaxBJ(1, DevWave_Jug)
    local integer rb = 2
    local integer rc = 1
    if Punt_Perdidas * 40 <= 3 * Punt_Soltadas then
        set rb = 3
    elseif Punt_Perdidas * 40 >= 8 * Punt_Soltadas then
        set rb = 1
    endif
    if Punt_Caidas <= jug / 4 then
        set rc = 3
    elseif Punt_Caidas <= IMaxBJ(1, 3 * jug / 4) then
        set rc = 2
    endif
    set Punt_Estrellas = IMinBJ(rb, rc)
    set Punt_Ronda = Ronda_Numero
    set Punt_Hist[Ronda_Numero] = Punt_Estrellas
    set Punt_Ver = Punt_Ver + 1
    set Punt_T = 0.
{anota}endfunction

// Cada 0,5 s desde el final de la oleada: puntúa cuando no quedan bolsas en el suelo (a lo sumo 36 s).
function Punt_Esperar takes nothing returns nothing
    set Punt_Espera = Punt_Espera + 0.5
    if Bolsa_N > 0 and Punt_Espera < 36. and Ronda_Descanso then
        return
    endif
    call PauseTimer(Punt_Reloj)
    call Punt_Calcular()
endfunction

function Ronda_Lanzar takes nothing returns nothing
''')
una('    call Bolsa_Ronda()\n', '''    call Bolsa_Ronda()
    set Punt_Caidas = 0
    set Punt_Soltadas = 0
    set Punt_Cogidas = 0
    set Punt_Perdidas = 0
    set Punt_T = -1.
''')
una('        set Ronda_Resta = Ronda_DESCANSO\n', '''        set Punt_Espera = 0.
        if Punt_Reloj == null then
            set Punt_Reloj = CreateTimer()
        endif
        call TimerStart(Punt_Reloj, 0.5, true, function Punt_Esperar)
        set Ronda_Resta = Ronda_DESCANSO
''')

if prueba:
    for n in ('super', 'precarga', 'bolsas', 'cuadros'):
        una(f'call PreloadGenEnd("lat\\\\v18i-{n}.txt")', f'call PreloadGenEnd("lat\\\\v18j-{n}.txt")')
    assert 'PreloadGenEnd("lat\\\\v18i-' not in j
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v18j: puntuación de fin de ronda con estrellas' + (' + registro' if prueba else ''))
