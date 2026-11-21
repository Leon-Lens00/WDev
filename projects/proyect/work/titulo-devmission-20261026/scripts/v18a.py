#!/usr/bin/env python3
"""v18a (15/11/2026): tarjetas de la súper élite como "Super Creep Random Boost" de Dark Moon, con tirada y sonido.

Leon envió una grabación de Dark Moon (Videocaptura de pantalla_20261115_002900.mp4) y pidió seguirla: "vamos con esta
update"; el sonido sacado del original y que "suene en cada baraja en lugar de un solo audio". Medido en el vídeo a 60 fps:
el panel entra en bloque desde la izquierda en ~0,1 s; las 4 cartas cambian a la vez cada 0,2 s (13 cambios, ~2,4 s) y
el último las fija; luego se quedan a la vista. Cada cambio suena un tic (scripts/sonido_v18a.py → SupTic.wav).
- Entrada y salida en bloque en 0,12 s (sustituye la escalera de v17y).
- Tirada: al entrar, un cambio cada 0,2 s con valores e iconos al azar; el 13.º (2,4 s) pone los de la súper élite.
  Se sortea en el tick del HUD, igual en todos los clientes (como la escalera), así que GetRandomInt no desincroniza.
- Tic: SupTic.wav sólo en el cliente del jugador (GetLocalPlayer), y sólo si las tarjetas se ven.
- Iconos: los 7 posibles de cada ranura se crean en Sup_HudCrear (28 por jugador) y la tirada sólo cambia cuál se ve:
  la textura de un dummy sólo prende al crearlo. Siguen a 380 de la cámara (v17z).
- Se ocultan como antes: al morir la súper élite, al acabar la oleada, al cambiar a otra; tienda/HUD oculto al momento.
Prueba: entrada, cada cambio, fijado, salida y fuera en lat\\v18a-super.txt; precarga y cuadros en lat\\v18a-*.txt.
Uso: v18a.py v17z/war3map.j SALIDA.j [prueba]
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


def log(s):
    return f'        call Sup_Anotar({s})\n' if prueba else ''


una('integer array Sup_Fase\n', '''integer array Sup_Fase
unit array Sup_IcoT
integer array Sup_Tiro
real array Sup_Rt
sound Sup_TicSnd = null
''')

# Sonido: cargado al iniciar, primer uso a volumen 0 (como los Son_*).
una('    call StartSound(Son_CajaSnd)\n', '''    call StartSound(Son_CajaSnd)
    set Sup_TicSnd = CreateSound("war3mapImported\\\\SupTic.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(Sup_TicSnd, 190)
    call SetSoundChannel(Sup_TicSnd, 0)
    call SetSoundVolume(Sup_TicSnd, 0)
    call StartSound(Sup_TicSnd)
''')

# Iconos ya creados: 7 por ranura (ranuras 0-1 estadísticas, 2-3 pasivas).
una('''        set Sup_Bg[p * 4 + k] = u
        set Sup_Ico[p * 4 + k] = null
        set k = k + 1
    endloop
    set k = 0
''', '''        set Sup_Bg[p * 4 + k] = u
        set Sup_Ico[p * 4 + k] = null
        set k = k + 1
    endloop
    // v18a: los 7 iconos posibles de cada ranura; la tirada sólo elige cuál se ve.
    set k = 0
    loop
        exitwhen k > 27
        set u = HealthBars__Dummy('uidb', p)
        call UnitAddAbility(u, s__Interface_LOCUST_ID)
        call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
        if k < 14 then
            call Arm_Foto(u, 46. * 380. / 400., 46. * 380. / 400., Sup_Tex[ModuloInteger(k, 7)])
        else
            call Arm_Foto(u, 46. * 380. / 400., 46. * 380. / 400., Sup_Tex[7 + ModuloInteger(k, 7)])
        endif
        call ShowUnit(u, false)
        set Sup_IcoT[p * 28 + k] = u
        set k = k + 1
    endloop
    set k = 0
''')

ini = j.index(u8('// v17y: iconos y textos de la súper élite Sup_Vista para el jugador p (sus tarjetas están fuera).'))
fin = j.index(u8('// Inversa de win2World con la cámara lógica'))
assert ini < fin and j[ini:fin].count('function ') == 3, 'región de Sup_Cargar/Sup_Desliz/Sup_Hud'
nuevo = '''// v18a: contenido de la súper élite Sup_Vista para el jugador p (sus tarjetas están fuera). Los iconos y textos de
// las tarjetas los pone la tirada (Sup_Barajar) al entrar.
function Sup_Cargar takes integer p returns nothing
    local integer i = Sup_Vista
    local integer k = 0
    set Sup_Visto[p] = Sup_Ver
    set Sup_Mio[p] = i
    loop
        exitwhen k > 3
        call Hud_Ver(Sup_Ico[p * 4 + k], false)
        set Sup_Ico[p * 4 + k] = null
        set k = k + 1
    endloop
    if i >= 0 then
        call Sup_Texto(Sup_TT[p * 5], "Súper élite: vida y daño ×" + R2SW(Sup_M[i], 1, 2), 30. - 420., 296., 0.017)
    endif
''' + log('"j" + I2S(p) + " carga super " + I2S(i)') + '''endfunction

// v18a: la tarjeta k del jugador p muestra el icono t de su ranura (7 por ranura, Sup_HudCrear) y el texto s.
function Sup_Poner takes integer p, integer k, integer t, string s returns nothing
    local unit u = Sup_IcoT[p * 28 + k * 7 + t]
    if Sup_Ico[p * 4 + k] != u then
        call Hud_Ver(Sup_Ico[p * 4 + k], false)
        set Sup_Ico[p * 4 + k] = u
    endif
    call Sup_Texto(Sup_TT[p * 5 + 1 + k], s, 92. - 420., 345. + 62. * k - 11., 0.017)
    set u = null
endfunction

// v18a: un cambio de la tirada. Al azar (estadística y valor, pasiva) o, con fin, lo real de la súper élite Sup_Mio.
function Sup_Barajar takes integer p, boolean fin returns nothing
    local integer i = Sup_Mio[p]
    local integer k = 0
    local integer t
    local integer v
    loop
        exitwhen k > 3
        if fin then
            if k < 2 then
                set t = Sup_St[i * 2 + k]
                call Sup_Poner(p, k, t, "+" + I2S(Sup_Val[i * 2 + k]) + Sup_StNom[t])
            else
                set t = Sup_Pa[i * 2 + k - 2]
                call Sup_Poner(p, k, t, Sup_PaNom[t])
            endif
        else
            set t = GetRandomInt(0, 6)
            if k < 2 then
                if t == 2 or t == 4 then
                    set v = 5 * GetRandomInt(1, 10)
                else
                    set v = GetRandomInt(1, 60)
                endif
                call Sup_Poner(p, k, t, "+" + I2S(v) + Sup_StNom[t])
            else
                call Sup_Poner(p, k, t, Sup_PaNom[t])
            endif
        endif
        set k = k + 1
    endloop
endfunction

// v18a: desplazamiento de todas las tarjetas (px, negativo = a la izquierda): entran o salen en bloque en 0,12 s.
function Sup_Desliz takes integer p returns real
    local real f = RMinBJ(1., Sup_Tm[p] / 0.12)
    if Sup_Fase[p] == 1 then
        return - 420. * (1. - f) * (1. - f)
    elseif Sup_Fase[p] == 3 then
        return - 420. * f * f
    elseif Sup_Fase[p] == 0 then
        return - 420.
    endif
    return 0.
endfunction

// Tarjetas de la súper élite a la izquierda: fase 0 fuera, 1 entrando, 2 dentro, 3 saliendo (cada 0,01 s).
// v18a: al entrar empieza la tirada: Sup_Tiro cambios hechos, uno cada 0,2 s (Sup_Rt); el 13.º fija lo real.
function Sup_Hud takes integer p, integer cam returns nothing
    local boolean shown
    local boolean tic = false
    local integer k = 0
    local integer i
    local real y
    local real dx
    local unit u
    if not Sup_HudOk[p] then
        return
    endif
    if Sup_Fase[p] == 1 or Sup_Fase[p] == 3 then
        set Sup_Tm[p] = Sup_Tm[p] + 0.01
        if Sup_Tm[p] >= 0.12 then
            if Sup_Fase[p] == 1 then
                set Sup_Fase[p] = 2
            else
                set Sup_Fase[p] = 0
''' + log('"j" + I2S(p) + " tarjetas fuera"').replace('        call', '                call') + '''            endif
        endif
    endif
    if Sup_Visto[p] != Sup_Ver then
        if Sup_Fase[p] == 0 then
            call Sup_Cargar(p)
        elseif Sup_Fase[p] != 3 then
            set Sup_Fase[p] = 3
            set Sup_Tm[p] = 0.
''' + log('"j" + I2S(p) + " tarjetas salen"').replace('        call', '            call') + '''        endif
    endif
    if Sup_Fase[p] == 0 and Sup_Mio[p] >= 0 then
        set Sup_Fase[p] = 1
        set Sup_Tm[p] = 0.
        set Sup_Rt[p] = 0.
        set Sup_Tiro[p] = 1
        call Sup_Barajar(p, false)
        set tic = true
''' + log('"j" + I2S(p) + " tarjetas entran, cambio 1"') + '''    elseif (Sup_Fase[p] == 1 or Sup_Fase[p] == 2) and Sup_Tiro[p] < 13 then
        set Sup_Rt[p] = Sup_Rt[p] + 0.01
        if Sup_Rt[p] >= 0.2 * Sup_Tiro[p] - 0.005 then
            set Sup_Tiro[p] = Sup_Tiro[p] + 1
            call Sup_Barajar(p, Sup_Tiro[p] == 13)
            set tic = true
''' + log('"j" + I2S(p) + " cambio " + I2S(Sup_Tiro[p])').replace('        call', '            call') + '''        endif
    endif
    set i = Sup_Mio[p]
    set shown = Sup_Fase[p] != 0 and i >= 0 and HealthBars__Visible and Game_On[p] and not Shop_Open[p]
    // Tic de la tirada (vídeo de Dark Moon): sólo lo oye el jugador p y sólo si ve sus tarjetas.
    if tic and shown and GetLocalPlayer() == Player(p) then
        call StopSound(Sup_TicSnd, false, false)
        call SetSoundVolume(Sup_TicSnd, 100)
        call StartSound(Sup_TicSnd)
    endif
    set dx = Sup_Desliz(p)
    call s__UIText_show(Sup_TT[p * 5], shown, cam)
    if shown then
        call s__UIText_setPosition(Sup_TT[p * 5], (30. + dx - 960.) / 728., (420. - 296.) / 390.)
    endif
    loop
        exitwhen k > 3
        set y = 345. + 62. * k
        set u = Sup_Ico[p * 4 + k]
        call Hud_Ver(Sup_Bg[p * 4 + k], shown)
        call Hud_Ver(u, shown and u != null)
        call s__UIText_show(Sup_TT[p * 5 + 1 + k], shown, cam)
        if shown then
            call HealthBars__Place(Sup_Bg[p * 4 + k], cam, 180. + dx, y, 412.)
            if u != null then
                // v17z: a 380; a 398 quedaba detrás del fondo en distancia real a la cámara.
                call HealthBars__Place(u, cam, 60. + dx, y, 380.)
            endif
            call s__UIText_setPosition(Sup_TT[p * 5 + 1 + k], (92. + dx - 960.) / 728., (420. - (y - 11.)) / 390.)
        endif
        set k = k + 1
    endloop
    set u = null
endfunction

'''
j = j[:ini] + crlf(u8(nuevo)) + j[fin:]

if prueba:
    for n in ('super', 'precarga', 'cuadros'):
        una(f'call PreloadGenEnd("lat\\\\v17z-{n}.txt")', f'call PreloadGenEnd("lat\\\\v18a-{n}.txt")')
    assert 'lat\\\\v17z-' not in j

assert 'Sup_Desliz(p, ' not in j and 'RemoveUnit(Sup_Ico' not in j
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v18a: tarjetas con tirada y tic' + (' + registro' if prueba else ''))
