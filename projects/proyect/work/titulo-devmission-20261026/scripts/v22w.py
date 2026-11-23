#!/usr/bin/env python3
"""v22w (23/11/2026): Segundo aliento (carta 125) cura poco a poco al salir el jefe; el tier sube la duración.

Leon tras saber que no hacía nada (el fin de cada oleada ya llena la vida, así que curar al empezar la siguiente no
sumaba): "podria ser esa coracion adicional de poco a poco, pero se activaria al empezar el jefe, con los tier podria
subir la duracion".
- Al salir el jefe de la oleada (DevJefe_Aparece), cada héroe con la carta recupera el 2 % de su vida máxima por
  segundo (1 % cada 0,5 s) durante N segundos. N según la calidad: T1 5, T2 7, T3 10, T4 14, T5 20 s (10-40 % en
  total, como antes). Tomarla otra vez suma segundos (tope 3).
- Se quita la curación de Ronda_Lanzar.
- Prueba: registro "aliento jP N s" al activarse.
Uso: v22w.py ENTRADA.j SALIDA.j [prueba]   (normal de v22v; prueba de v22v-prueba).
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


VALS = [5, 7, 10, 14, 20]

# 0) Globales: fin de la curación de cada jugador y su reloj.
cambia('real array Her_Aliento\n', '''real array Her_Aliento
// v22w: Segundo aliento: segundos de curación (Her_Aliento), hasta cuándo (Ali_Fin) y reloj de 0,5 s.
real array Ali_Fin
timer Ali_Reloj = null
''')

# 1) Fuera la curación al empezar la oleada.
cambia('''            // v22t: Segundo aliento.
            if Her_Aliento[p] > 0. and UnitAlive(Game_Hero[p]) then
                call SetWidgetLife(Game_Hero[p], GetWidgetLife(Game_Hero[p]) + GetUnitState(Game_Hero[p], UNIT_STATE_MAX_LIFE) * Her_Aliento[p])
            endif
''', '')

# 2) Curación poco a poco desde que sale el jefe.
cambia('function DevJefe_Aparece takes nothing returns nothing\n', '''// v22w: Segundo aliento: 1 % de la vida máxima cada 0,5 s mientras dure (código común).
function Ali_Tic takes nothing returns nothing
    local integer p = 0
    local real ahora = TimerGetElapsed(s__RapidPair_clock)
    local boolean sigue = false
    local unit h
    loop
        exitwhen p > 11
        if Ali_Fin[p] > ahora then
            set sigue = true
            set h = Game_Hero[p]
            if h != null and UnitAlive(h) then
                call SetWidgetLife(h, GetWidgetLife(h) + GetUnitState(h, UNIT_STATE_MAX_LIFE) * 0.01)
            endif
        endif
        set p = p + 1
    endloop
    if not sigue then
        call PauseTimer(Ali_Reloj)
    endif
    set h = null
endfunction

function DevJefe_Aparece takes nothing returns nothing
''')
cambia('''    call DevJefe_Limpiar()
    set DevJefe=GetWaveEventUnit()
    set DevJefe_Llamadas=0
''', '''    call DevJefe_Limpiar()
    set DevJefe=GetWaveEventUnit()
    set DevJefe_Llamadas=0
    // v22w: Segundo aliento al salir el jefe.
    loop
        exitwhen p > 11
        if Game_On[p] and Her_Aliento[p] > 0. then
            set Ali_Fin[p] = TimerGetElapsed(s__RapidPair_clock) + Her_Aliento[p]
            if Ali_Reloj == null then
                set Ali_Reloj = CreateTimer()
            endif
            call TimerStart(Ali_Reloj, 0.5, true, function Ali_Tic)
''' + ('''            set Cop_Log = "aliento j" + I2S(p) + " " + R2S(Her_Aliento[p]) + " s"
            call ExecuteFunc("Cop_Anotar")
''' if prueba else '') + '''        endif
        set p = p + 1
    endloop
    set p = 0
''')

# 3) Valor: segundos.
cambia('        set Her_Aliento[p] = Her_Aliento[p] + v / 100.\n', '        set Her_Aliento[p] = Her_Aliento[p] + v\n')
cambia('''        return "Al empezar la oleada,|nte curas el " + I2S(v) + " % de vida."''',
       '''        return "Al salir el jefe, recuperas|n2 % de vida por segundo|ndurante " + I2S(v) + " s."''')
for q, (v0, v) in enumerate(zip([10, 15, 20, 30, 40], VALS)):
    cambia(f'    set Her_Tabla[{125 * 5 + q}] = {v0}\n', f'    set Her_Tabla[{125 * 5 + q}] = {v}\n')

assert src.index('function Ali_Tic') < src.index('function DevJefe_Aparece')
assert src.index('real array Ali_Fin') < src.index('endglobals')

if prueba:
    assert 'function Cop_Anotar' in src
    cambia('lat\\\\v22v-', 'lat\\\\v22w-', src.count('lat\\\\v22v-'))
    cambia('v22v-don.txt', 'v22w-don.txt', src.count('v22v-don.txt'))
    assert 'lat\\\\v22v-' not in src and 'v22v-don.txt' not in src, 'quedan registros v22v'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22w', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
