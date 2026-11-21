#!/usr/bin/env python3
"""Sólo prueba (13/11/2026): repetición de la prueba de oleadas (oleadas_v16t.py) con los relojes corregidos.
En la primera, PauseTimer + ResumeTimer dejó de repetir el reloj periódico de WaveAI (y quizá el de ConversationUI):
aquí cada tramo los vuelve a arrancar con TimerStart. Además cuenta en «ordenes» las órdenes de punto (las de ataque
de la IA, que llegan a s__RapidPair_pointOrder) junto a las órdenes sin objetivo.
Uso: oleadas2_v16t.py v16t-shots-oleadas/war3map.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')


def una(a, b):
    global j
    a, b = a.replace('\n', '\r\n'), b.replace('\n', '\r\n')
    assert j.count(a) == 1, (a, j.count(a))
    j = j.replace(a, b)


una('''    call ResumeTimer(ConversationUI___Clock)
    call ResumeTimer(WaveAI__Clock)
''', '''    // oleadas2: TimerStart en lugar de ResumeTimer (reanudar dejaba de repetir el reloj periódico).
    call TimerStart(ConversationUI___Clock, 0.01, true, function ConversationUI___Tick)
    call TimerStart(WaveAI__Clock, WaveAI__WAVE_AI_TICK, true, function WaveAI__OnTick)
''')
una('''        local integer order= GetIssuedOrderId()
        if this != 0 and not s__RapidPair_down[this] then
''', '''        local integer order= GetIssuedOrderId()
        set Est_Ordenes = Est_Ordenes + 1
        if this != 0 and not s__RapidPair_down[this] then
''')
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('oleadas2: relojes con TimerStart, órdenes de punto contadas')
