#!/usr/bin/env python3
"""v14s: luz fija de Storm y niebla oscura. Parte del j de v14r.

En v14r cada destello creaba y destruía el efecto con luz (StormL1..3) y eso daba tirones de ~175 ms. Ahora:
- Cada jugador humano tiene una unidad 'h00S' persistente con StormLuz.mdx (la luz direccional dentro, apagada en la
  secuencia 0 «Stand»). Se crean en Storm_Iniciar, una vez, y no se destruyen.
- Un destello pone la secuencia 1 + (v-1)*61 + (cenit+90) y al apagarse vuelve a la 0. Sólo en el cliente del dueño
  de la tormenta (cambio de animación, visual); el resto de clientes la deja apagada.
- El acimut sigue siendo el giro de la unidad: SetUnitFacing al crear la tormenta y 0,25 s antes del primer destello.
- Niebla: al empezar la partida (tras Game_Enter) la base de Storm pasa a negra como en el mapa de OVOgenez (1000/3000
  con la cámara a 1650), escalada a la cámara de juego (distancia ~2856): 1730/5190, densidad 0, color 0 0 0. Los
  destellos le suman su color como antes. Los menús conservan la niebla de main.

Uso: v14s.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base


def u(x):
    return x.encode('utf-8').decode('latin-1')


def once(s, old, new):
    return base.once(s, u(old), u(new))


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
assert 'Storm_Luz' not in s

s = once(s, 'integer Storm_Lanzadas= 0\n', '''integer Storm_Lanzadas= 0
// v14s: unidad de luz persistente por jugador y cenit de cada tormenta.
unit array Storm_Luz
integer array s__Storm__TStorm_Zenith
''')

# La tormenta usa la unidad persistente del jugador: no la destruye.
s = once(s, '''    call s__Storm__TStorm_remove(this)
    if s__Storm__TStorm_Effect[this] != null then
        call DestroyEffect(s__Storm__TStorm_Effect[this])
    endif
    call RemoveUnit(s__Storm__TStorm_Unit[this])
    set s__Storm__TStorm_Effect[this] = null
''', '''    call s__Storm__TStorm_remove(this)
''')

s = once(s, '''                set s__Storm__TStorm_LIndex[this] = v
                if s__Storm__TStorm_Local[this] then
                    set s__Storm__TStorm_Effect[this] = AddSpecialEffectTarget(Storm__LightningPath[v], s__Storm__TStorm_Unit[this], "origin")
                else
                    set s__Storm__TStorm_Effect[this] = AddSpecialEffectTarget("", s__Storm__TStorm_Unit[this], "origin")
                endif
''', '''                set s__Storm__TStorm_LIndex[this] = v
                if s__Storm__TStorm_Local[this] then
                    call SetUnitAnimationByIndex(s__Storm__TStorm_Unit[this], 1 + (v - 1) * 61 + s__Storm__TStorm_Zenith[this] + 90)
                endif
''')
s = once(s, '''                call DestroyEffect(s__Storm__TStorm_Effect[this])
                set s__Storm__TStorm_Effect[this] = null
''', '''                if s__Storm__TStorm_Local[this] then
                    call SetUnitAnimationByIndex(s__Storm__TStorm_Unit[this], 0)
                endif
''')

s = once(s, '''    set s__Storm__TStorm_Time[this] = 0
    set s__Storm__TStorm_Mode[this] = false
    set s__Storm__TStorm_Unit[this] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), Storm__DUMMY_ID, GetUnitX(c), GetUnitY(c), azimuth)
    call SetUnitAnimationByIndex(s__Storm__TStorm_Unit[this], zenith + 90)
''', '''    // v14s: 0,25 s para que la unidad termine de girar antes del primer destello.
    set s__Storm__TStorm_Time[this] = 8 * s__Storm__TStorm_PERIOD
    set s__Storm__TStorm_Mode[this] = false
    set s__Storm__TStorm_Zenith[this] = zenith
    set s__Storm__TStorm_Unit[this] = Storm_Luz[p]
    call SetUnitX(Storm_Luz[p], GetUnitX(c))
    call SetUnitY(Storm_Luz[p], GetUnitY(c))
    call SetUnitFacing(Storm_Luz[p], azimuth)
''')
s = once(s, '''        if Camera_DummyUnit[p] != null and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then
''', '''        if Camera_DummyUnit[p] != null and Storm_Luz[p] != null and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then
''')

s = once(s, '''function Storm_Iniciar takes nothing returns nothing
    call Storm__Init()
''', '''// v14s: niebla negra de la partida (la de Storm, escalada a la cámara de juego). El periódico de Storm la aplica.
function Storm_Oscuro takes nothing returns nothing
    set Storm_TF_style = 0
    set Storm_TF_zstart = 1730.
    set Storm_TF_zend = 5190.
    set Storm_TF_density = 0.
    set Storm_TF_red = 0.
    set Storm_TF_green = 0.
    set Storm_TF_blue = 0.
endfunction

function Storm_Iniciar takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
            set Storm_Luz[p] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), Storm__DUMMY_ID, 0., 0., 0.)
        endif
        set p = p + 1
    endloop
    call Storm__Init()
''')

# Sin modelos de luz sueltos: la ruta queda vacía.
for i in (1, 2, 3):
    s = once(s, f'    set Storm__LightningPath[{i}] = "war3mapImported\\\\StormL{i}.mdx"\n', f'    set Storm__LightningPath[{i}] = ""\n')

# Precarga: ya no hay modelos de luz sueltos ni hace falta crear la unidad (las persistentes se crean al iniciar).
s = once(s, '''    // v14r: Storm (unidad, luces y truenos con volumen 0).
    call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'h00S', x, y, 0.))
    set i = 1
    loop
        exitwhen i > 3
        call DestroyEffect(AddSpecialEffect("war3mapImported\\\\StormL" + I2S(i) + ".mdx", x, y))
        call Preload''', '''    // v14s: truenos de Storm con volumen 0.
    set i = 1
    loop
        exitwhen i > 3
        call Preload''')

s = once(s, '    call Bot_Entrar()\n    call TimerStart(CreateTimer(), 3., false, function DevWave_Arrancar)\n',
         '    call Bot_Entrar()\n    call Storm_Oscuro()\n    call TimerStart(CreateTimer(), 3., false, function DevWave_Arrancar)\n')
assert 'StormL' not in s and 'AddSpecialEffectTarget(Storm__LightningPath' not in s
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v14s: luz persistente y niebla oscura')
