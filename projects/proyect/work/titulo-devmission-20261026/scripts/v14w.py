#!/usr/bin/env python3
"""v14w: variantes Día, Tarde y Noche (sólo visuales). Parte del j de v14v.

Variante (0 Día, 1 Tarde, 2 Noche) fija al entrar la hora de Dark Nights, la niebla y la frecuencia de tormentas:
- Día: 12:00 (sol 1,3); niebla gris azulada lejana 2500/8000; sin tormentas.
- Tarde: 18:15 (sol ~0,86); niebla naranja 1900/6000; una tormenta cada 25-50 s.
- Noche: 0:00 (sol 0,05); niebla negra 1730/5190, la de v14s; una tormenta cada 12-25 s.
Variante_Aplicar es todo estado común: lo llaman Storm_Oscuro al entrar y, en las de prueba, «-variante».
Más adelante la elegirá el anfitrión en la selección. Por defecto queda la Tarde.

Uso: v14w.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base


def once(s, old, new):
    return base.once(s, old.encode('utf-8').decode('latin-1'), new.encode('utf-8').decode('latin-1'))


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = once(s, 'timer Storm_Reloj= null\n', 'timer Storm_Reloj= null\ninteger Variante= 1\n')
s = once(s, '''// Una tormenta cada 15–40 s durante la oleada.
function Storm_Tick takes nothing returns nothing
    if Ronda_Activa and not Ronda_Descanso then
        call Storm_Rayo(0)
    endif
    call TimerStart(Storm_Reloj, GetRandomReal(15., 40.), false, function Storm_Tick)
endfunction

// v14v: niebla negra de la partida (la de Storm escalada a la cámara de juego, como v14s) y atardecer fijo de Dark
// Nights (18:15). El periódico de Storm aplica la niebla.
function Storm_Oscuro takes nothing returns nothing
    call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 18.25)
    call SuspendTimeOfDay(true)
    set Storm_TF_style = 0
    set Storm_TF_zstart = 1730.
    set Storm_TF_zend = 5190.
    set Storm_TF_density = 0.
    set Storm_TF_red = 0.
    set Storm_TF_green = 0.
    set Storm_TF_blue = 0.
endfunction
''', '''// v14w: hora de Dark Nights y niebla de la variante v (0 Día, 1 Tarde, 2 Noche). El periódico de Storm aplica la
// niebla. Estado común: se llama igual en todos los clientes.
function Variante_Aplicar takes integer v returns nothing
    set Variante = v
    set Storm_TF_style = 0
    set Storm_TF_density = 0.
    if v == 0 then
        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12.)
        set Storm_TF_zstart = 2500.
        set Storm_TF_zend = 8000.
        set Storm_TF_red = 0.55
        set Storm_TF_green = 0.62
        set Storm_TF_blue = 0.72
    elseif v == 1 then
        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 18.25)
        set Storm_TF_zstart = 1900.
        set Storm_TF_zend = 6000.
        set Storm_TF_red = 0.95
        set Storm_TF_green = 0.5
        set Storm_TF_blue = 0.18
    else
        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 0.)
        set Storm_TF_zstart = 1730.
        set Storm_TF_zend = 5190.
        set Storm_TF_red = 0.
        set Storm_TF_green = 0.
        set Storm_TF_blue = 0.
    endif
endfunction

// Durante la oleada: sin tormentas de día, una cada 25-50 s de tarde y cada 12-25 s de noche.
function Storm_Tick takes nothing returns nothing
    if Ronda_Activa and not Ronda_Descanso and Variante != 0 then
        call Storm_Rayo(0)
    endif
    if Variante == 2 then
        call TimerStart(Storm_Reloj, GetRandomReal(12., 25.), false, function Storm_Tick)
    else
        call TimerStart(Storm_Reloj, GetRandomReal(25., 50.), false, function Storm_Tick)
    endif
endfunction

// v14w: al entrar en la partida, la variante elegida con la hora parada.
function Storm_Oscuro takes nothing returns nothing
    call Variante_Aplicar(Variante)
    call SuspendTimeOfDay(true)
endfunction
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v14w: variantes Día, Tarde y Noche')
