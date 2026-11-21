#!/usr/bin/env python3
"""v16t-relojes (14/11/2026): la interfaz sigue a 0,01 s sólo en lo que mueve; lo demás, sólo cuando cambia o a 0,05 s.

Leon (14/11/2026): "hagamoz la mejora de relojes" (0,01 s sólo para posición; la lógica en relojes más ligeros).

En el tick de 100 Hz (ConversationUI___Tick → HealthBarsUpdate), por cada jugador:
- ShowUnit de barras, iconos, arma, blindaje, batería y tarjetas de racha: antes en cada tick aunque no cambiara;
  ahora sólo cuando cambia (Hud_Ver compara con IsUnitHidden).
- UIText.show: SetTextTagVisibility sólo cuando cambia la visibilidad (antes en cada llamada).
- Ronda_Hud (armar «Wave N» y la cifra) y el aviso de tienda/munición de DevTienda_Hud (distancia a 20 zonas y al golem):
  a 0,05 s, con el mismo sondeo que ya usaba el porcentaje de vida (HealthBars__Lento).
- Siguen a 0,01 s: cámara, colocación (Place, setPosition, UIText_updateAll), indicadores de borde del jefe y la tienda,
  animación de entrada de las tarjetas de racha y el resto de ConversationUI.
Uso: relojes_v16t.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')


def una(a, b, n=1):
    global j
    a, b = a.replace('\n', '\r\n'), b.replace('\n', '\r\n')
    assert j.count(a) == n, (a[:80], j.count(a))
    j = j.replace(a, b)


una('real HealthBars__PollTime= 0\n', 'real HealthBars__PollTime= 0\n// v16t-relojes: true en el tick de sondeo (cada 0,05 s).\nboolean HealthBars__Lento= false\n')
una('function Racha_Mover takes nothing returns nothing\n', '''// v16t-relojes: mostrar u ocultar sólo si cambia (antes ShowUnit en cada tick de 0,01 s).
function Hud_Ver takes unit u, boolean b returns nothing
    if u != null and IsUnitHidden(u) == b then
        call ShowUnit(u, b)
    endif
endfunction

function Racha_Mover takes nothing returns nothing
''')
# HealthBarsUpdate
una('''    if poll then
        set HealthBars__PollTime=0
    endif
    call Racha_Mover()
''', '''    if poll then
        set HealthBars__PollTime=0
    endif
    set HealthBars__Lento=poll
    call Racha_Mover()
''')
for u in ('HealthBars__HeroBars[p], shown', 'HealthBars__Icons[p], shown', 'HealthBars__EnemyBars[p], shown',
          'Arm_Icono[p], shown', 'Arm_Blindaje[p], shown', 'Bat_Barra[p], shown and Bat_T[p] > 0.',
          'Racha_Caja[v], vis', 'Racha_Marco[v], vis', 'Ronda_Icono[p], false'):
    una(f'call ShowUnit({u})', f'call Hud_Ver({u})')
# UIText.show (y su copia para .evaluate)
una('''            call SetTextTagVisibility(s__UIText_text[this], show)
            if show != s__UIText_displayed[this] then
''', '''            if show != s__UIText_displayed[this] then
                // v16t-relojes: sólo cuando cambia.
                call SetTextTagVisibility(s__UIText_text[this], show)
''')
una('''            call SetTextTagVisibility(s__UIText_text[this], show)
            
            if show != s__UIText_displayed[this] then
''', '''            if show != s__UIText_displayed[this] then
                // v16t-relojes: sólo cuando cambia.
                call SetTextTagVisibility(s__UIText_text[this], show)
''')
# Ronda_Hud: contenido a 0,05 s
una('''    call s__UIText_show(Ronda_Cifra[p],shown , cam)
    if shown then
''', '''    call s__UIText_show(Ronda_Cifra[p],shown , cam)
    // v16t-relojes: textos a 0,05 s (sólo escriben si cambian).
    if shown and HealthBars__Lento then
''')
# DevTienda_Hud: aviso a 0,05 s
una('''    call DevTienda_Poner(p , cam)
    if HealthBars__Visible and not Shop_Open[p] then
''', '''    call DevTienda_Poner(p , cam)
    // v16t-relojes: distancias del aviso a 0,05 s.
    if not HealthBars__Lento then
        call s__UIText_show(DevTienda_Aviso[p],DevTienda_AvisoK[p] != 0 , cam)
        return
    endif
    if HealthBars__Visible and not Shop_Open[p] then
''')
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v16t-relojes: ShowUnit y visibilidad sólo al cambiar; ronda y aviso a 0,05 s')
