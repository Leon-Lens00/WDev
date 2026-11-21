#!/usr/bin/env python3
"""Sólo prueba, v14l: mide en el motor la tabla de daño (05/11/2026). NO integrar.

Entrada directa. A los 3 s crea, pausada y para el jugador pasivo, primero las 8 unidades de prueba sin defensa
(objetos_dano_prueba.py, una por ranura de armadura: miden la tabla pura) y después cada unidad de oleada, élite, jefe
y los dos personajes; les quita 10 de daño con cada tipo (Dano_Ataque 0..6, con Dano_TipoArma como las armas) y uno más con
Perforante y DAMAGE_TYPE_MAGIC (el de antes, para comparar); registra la vida perdida × 100 y la quita. Una línea por unidad en lat\\dano-N.txt:
"nmcf vida 60 P 1500 I ... | M ..."; la evalúa leer-dano-v14l.py. Sin armadura (udef 0) la pérdida es 10 × tabla; con udef d, × (1 − 0,06d/(1+0,06d))
si el motor la aplica a este tipo de daño.
Uso: prueba_dano_v14l.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

UNIDADES = [f'nda{k}' for k in range(8)] + ['nmcf', 'nlpr', 'ntrh', 'nmtw', 'nmsn', 'nlds', 'nmmu', 'nnsw', 'ntrg', 'ntrd'] + \
           [f'ne0{k}' for k in range(10)] + [f'nj0{c}' for c in '23456789A'] + ['h005', 'h006']

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'real Title_CX=', 'integer Dano_N= 0\nreal Title_CX=')
lista = ''.join(f"    call Dano_Medir('{u}', \"{u}\", f)\n" for u in UNIDADES)
s = base.once(s, 'function Intro_Begin takes nothing returns nothing\n', r'''// TEMPORARY test bridge (scripts/prueba_dano_v14l.py).
function Dano_Log takes string s returns nothing
    set Dano_N = Dano_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\dano-" + I2S(Dano_N) + ".txt")
endfunction

function Dano_Uno takes unit f, unit u, attacktype a, damagetype d returns string
    local real v = GetUnitState(u, UNIT_STATE_MAX_LIFE)
    call SetWidgetLife(u, v)
    call UnitDamageTarget(f, u, 10., false, false, a, d, null)
    return I2S(R2I((v - GetWidgetLife(u)) * 100. + 0.5))
endfunction

function Dano_Medir takes integer id, string nombre, unit f returns nothing
    local unit u = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), id, GetUnitX(f) + 300., GetUnitY(f), 0.)
    local string s = nombre + " vida " + I2S(R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE)))
    local integer k = 0
    call PauseUnit(u, true)
    loop
        exitwhen k > 6
        set s = s + " " + SubString("PIAEHSV", k, k + 1) + " " + Dano_Uno(f, u, Dano_Ataque(k), Dano_TipoArma)
        set k = k + 1
    endloop
    set s = s + " | M " + Dano_Uno(f, u, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_MAGIC)
    call Dano_Log(s)
    call RemoveUnit(u)
    set u = null
endfunction

function Dano_Prueba takes nothing returns nothing
    local unit f = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'nmcf', GetCameraTargetPositionX(), GetCameraTargetPositionY(), 0.)
    call PauseUnit(f, true)
    call ShowUnit(f, false)
''' + lista + r'''    call Dano_Log("FIN " + I2S(Dano_N))
    call RemoveUnit(f)
    set f = null
endfunction

function Intro_Begin takes nothing returns nothing
''')
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)',
              'call TimerStart(CreateTimer(), 3., false, function Dano_Prueba)\n    call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
