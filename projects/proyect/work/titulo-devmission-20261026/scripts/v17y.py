#!/usr/bin/env python3
"""v17y (14/11/2026): tarjetas de la súper élite en escalera y sus iconos al frente.

Leon, tras v17x-prueba (con grabación): revisar los iconos (se veían oscuros) y que los cuadros de bonus "salgan en
tipo escalera cada una desde fuera de la pantalla hasta la zona visible, y ocultarse con el mismo proceso".
- Iconos: en la grabación se ven tapados por el fondo 'DS18' (fondo a 400 y icono a 398 de la cámara). El fondo pasa a
  412, con el tamaño corregido (×412/400) para verse igual, como Racha_Caja/Racha_Marco (10 de separación).
- Escalera: cada tarjeta entra desde la izquierda (420 px fuera) en 0,25 s, una tras otra cada 0,08 s; la cabecera
  con la primera. Al morir la súper élite, al acabar la oleada o al cambiar a otra, salen igual, en el mismo orden;
  si hay otra que mostrar, entra después. La tienda y el HUD oculto siguen ocultando al momento.
- Sup_Pintar ya no crea iconos para todos: sólo avisa (Sup_Ver); cada jugador carga su contenido en Sup_Cargar
  cuando sus tarjetas están fuera (llamado desde HealthBarsUpdate, igual para todos los jugadores, sin GetLocalPlayer).
Prueba: anota carga, entrada, salida y fuera por jugador en lat\\v17y-super.txt; cuadros en lat\\v17y-cuadros.txt.
Uso: v17y.py v17x/war3map.j SALIDA.j [prueba]
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


def funcion(nombre, nueva):
    global j
    ini = j.index('function ' + nombre + ' takes')
    fin = j.index('endfunction', ini) + len('endfunction')
    j = j[:ini] + crlf(u8(nueva)) + j[fin:]


anota = lambda s: ('    call Sup_Anotar(' + s + ')\n') if prueba else ''

una('''integer array Sup_Visto
''', '''integer array Sup_Visto
integer array Sup_Fase
real array Sup_Tm
integer array Sup_Mio
''')

funcion('Sup_Pintar', '''function Sup_Pintar takes nothing returns nothing
    // v17y: sólo avisa del cambio; cada jugador lo carga en Sup_Cargar cuando sus tarjetas han salido.
    set Sup_Ver = Sup_Ver + 1
''' + anota('"tarjetas: super " + I2S(Sup_Vista)') + '''endfunction''')

una('''        call Arm_Foto(u, 300., 56., 'DS18')
''', '''        // v17y: fondo a 412 de la cámara (icono a 398), tamaño ×412/400 para verse igual que a 400.
        call Arm_Foto(u, 309., 57.68, 'DS18')
''')
una('''    set Sup_Visto[p] = -1
    set Sup_HudOk[p] = true
''', '''    set Sup_Visto[p] = -1
    set Sup_Mio[p] = -1
    set Sup_Fase[p] = 0
    set Sup_HudOk[p] = true
''')

funcion('Sup_Hud', '''// v17y: iconos y textos de la súper élite Sup_Vista para el jugador p (sus tarjetas están fuera).
function Sup_Cargar takes integer p returns nothing
    local integer i = Sup_Vista
    local integer k = 0
    local integer c = 0
    local integer tex
    local real y
    local unit u
    set Sup_Visto[p] = Sup_Ver
    set Sup_Mio[p] = i
    loop
        exitwhen k > 3
        if Sup_Ico[p * 4 + k] != null then
            call RemoveUnit(Sup_Ico[p * 4 + k])
            set Sup_Ico[p * 4 + k] = null
        endif
        if i >= 0 then
            if k < 2 then
                set tex = Sup_Tex[Sup_St[i * 2 + k]]
            else
                set tex = Sup_Tex[7 + Sup_Pa[i * 2 + k - 2]]
            endif
            set u = HealthBars__Dummy('uidb', p)
            call UnitAddAbility(u, s__Interface_LOCUST_ID)
            call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
            call Arm_Foto(u, 46., 46., tex)
            call ShowUnit(u, false)
            set Sup_Ico[p * 4 + k] = u
            set c = c + 1
        endif
        set k = k + 1
    endloop
    if i >= 0 then
        call Sup_Texto(Sup_TT[p * 5], "Súper élite: vida y daño ×" + R2SW(Sup_M[i], 1, 2), 30. - 420., 296., 0.017)
        set k = 0
        loop
            exitwhen k > 3
            set y = 345. + 62. * k - 11.
            if k < 2 then
                call Sup_Texto(Sup_TT[p * 5 + 1 + k], "+" + I2S(Sup_Val[i * 2 + k]) + Sup_StNom[Sup_St[i * 2 + k]], 92. - 420., y, 0.017)
            else
                call Sup_Texto(Sup_TT[p * 5 + 1 + k], Sup_PaNom[Sup_Pa[i * 2 + k - 2]], 92. - 420., y, 0.017)
            endif
            set k = k + 1
        endloop
    endif
''' + anota('"j" + I2S(p) + " carga super " + I2S(i) + ", iconos " + I2S(c)') + '''    set u = null
endfunction

// v17y: desplazamiento (px, negativo = a la izquierda) de la tarjeta k: entra o sale en 0,25 s, cada una 0,08 s
// después de la anterior; entrada frenando, salida acelerando.
function Sup_Desliz takes integer p, integer k returns real
    local real f
    if Sup_Fase[p] == 2 then
        return 0.
    elseif Sup_Fase[p] == 0 then
        return - 420.
    endif
    set f = RMinBJ(1., RMaxBJ(0., (Sup_Tm[p] - 0.08 * k) / 0.25))
    if Sup_Fase[p] == 1 then
        return - 420. * (1. - f) * (1. - f)
    endif
    return - 420. * f * f
endfunction

// Tarjetas de la súper élite a la izquierda: fase 0 fuera, 1 entrando, 2 dentro, 3 saliendo (cada 0,01 s).
function Sup_Hud takes integer p, integer cam returns nothing
    local boolean shown
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
        if Sup_Tm[p] >= 0.25 + 0.08 * 3 then
            if Sup_Fase[p] == 1 then
                set Sup_Fase[p] = 2
            else
                set Sup_Fase[p] = 0
''' + anota('"j" + I2S(p) + " tarjetas fuera"') + '''            endif
        endif
    endif
    if Sup_Visto[p] != Sup_Ver then
        if Sup_Fase[p] == 0 then
            call Sup_Cargar(p)
        elseif Sup_Fase[p] != 3 then
            set Sup_Fase[p] = 3
            set Sup_Tm[p] = 0.
''' + anota('"j" + I2S(p) + " tarjetas salen"') + '''        endif
    endif
    if Sup_Fase[p] == 0 and Sup_Mio[p] >= 0 then
        set Sup_Fase[p] = 1
        set Sup_Tm[p] = 0.
''' + anota('"j" + I2S(p) + " tarjetas entran"') + '''    endif
    set i = Sup_Mio[p]
    set shown = Sup_Fase[p] != 0 and i >= 0 and HealthBars__Visible and Game_On[p] and not Shop_Open[p]
    call s__UIText_show(Sup_TT[p * 5], shown, cam)
    if shown then
        call s__UIText_setPosition(Sup_TT[p * 5], (30. + Sup_Desliz(p, 0) - 960.) / 728., (420. - 296.) / 390.)
    endif
    loop
        exitwhen k > 3
        set y = 345. + 62. * k
        set u = Sup_Ico[p * 4 + k]
        call Hud_Ver(Sup_Bg[p * 4 + k], shown)
        call Hud_Ver(u, shown and u != null)
        call s__UIText_show(Sup_TT[p * 5 + 1 + k], shown, cam)
        if shown then
            set dx = Sup_Desliz(p, k)
            call HealthBars__Place(Sup_Bg[p * 4 + k], cam, 180. + dx, y, 412.)
            if u != null then
                call HealthBars__Place(u, cam, 60. + dx, y, 398.)
            endif
            call s__UIText_setPosition(Sup_TT[p * 5 + 1 + k], (92. + dx - 960.) / 728., (420. - (y - 11.)) / 390.)
        endif
        set k = k + 1
    endloop
    set u = null
endfunction''')

if prueba:
    una('call PreloadGenEnd("lat\\\\v17x-super.txt")', 'call PreloadGenEnd("lat\\\\v17y-super.txt")')
    una('call PreloadGenEnd("lat\\\\v17x-cuadros.txt")', 'call PreloadGenEnd("lat\\\\v17y-cuadros.txt")')
    una('call PreloadGenEnd("lat\\\\v17x-precarga.txt")', 'call PreloadGenEnd("lat\\\\v17y-precarga.txt")')
assert 'lat\\\\v17x-' not in j
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17y: tarjetas en escalera' + (' + registro' if prueba else ''))
