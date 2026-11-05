#!/usr/bin/env python3
"""v13i: registros de rendimiento sobre la copia con registro de v13h. Nada se muestra en pantalla.

Una vez por segundo escribe un pulso con el estado del juego y cuántas veces corrió cada sistema.
Uso: v13i.py IN_J OUT_J
"""
from pathlib import Path
import re
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

CONTADOR = (
    ('fire', 'function Missile__Fire takes nothing returns nothing'),
    ('pair', 'function s__RapidPair_tick takes nothing returns nothing'),
    ('conv', 'function ConversationUI___Tick takes nothing returns nothing'),
    ('aitk', 'function WaveAI__OnTick takes nothing returns nothing'),
    ('wave', 'function Wave_onTick takes nothing returns nothing'),
    ('barr', 'function HealthBars__Place takes unit u,integer cam,real px,real py,real range returns nothing'),
    ('spwn', 'function WaveAI__OnRegister takes nothing returns nothing'),
    ('muer', 'function WaveAI__OnDeath takes nothing returns nothing'),
    ('pens', 'function s__WaveAI__WaveAIUnit_think takes integer this returns boolean'),
    ('hide', 'function Title_HideBoard takes nothing returns nothing'),
)
ORDEN = len(CONTADOR)
ORDENES = (
    '        if IssueTargetOrder(s__WaveAI__WaveAIUnit_u[this], "attack", t) then\n',
    '        call IssueImmediateOrder(s__WaveAI__WaveAIUnit_u[this], "stop")\n',
    '        call IssuePointOrder(s__WaveAI__WaveAIUnit_u[this], "move", ',
)
N = '\r\n'


def contar(s, cabecera, k):
    i = s.index(cabecera)
    assert s.count(cabecera) == 1, cabecera
    fin = s.index(N, i) + 2
    while re.match(r'\s*(local |//|$)', s[fin:s.index(N, fin)]):
        fin = s.index(N, fin) + 2
    return s[:fin] + f'    set Lg_C[{k}] = Lg_C[{k}] + 1{N}' + s[fin:]


PULSO = '''function Lg_Pulso takes real t returns nothing
    local location l = Location(0., 0.)
    local integer h = GetHandleId(l)
    local integer i = 0
    local string s = "pulso t " + I2S(R2I(t)) + " r " + I2S(Ronda_Numero) + " d " + I2S(IntegerTertiaryOp(Ronda_Descanso, 1, 0)) + " e " + I2S(s__Wave_toKillRemaining[Ronda_Wave]) + " ai " + I2S(s__WaveAI__WaveAIUnit_count) + " mis " + I2S(s__MissileStats_active) + " dn " + I2S(s__MissileStats_newTotal) + " tir " + I2S(s__RapidPair_emitted) + " h " + I2S(h)
    call RemoveLocation(l)
    set l = null
    loop
        exitwhen i > ''' + str(ORDEN) + '''
        set s = s + " " + I2S(Lg_C[i] - Lg_P[i])
        set Lg_P[i] = Lg_C[i]
        set i = i + 1
    endloop
    call Sonda_Log(s)
endfunction

'''


if __name__ == '__main__':
    j_in, j_out = sys.argv[1:3]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    s = base.once(s, 'integer Sonda_N = 0\n', 'integer Sonda_N = 0\ninteger array Lg_C\ninteger array Lg_P\ninteger Lg_Latido = 0\n')
    for k, (_, cabecera) in enumerate(CONTADOR):
        s = contar(s, cabecera, k)
    uno = f'set Lg_C[{ORDEN}] = Lg_C[{ORDEN}] + 1'
    for o in ORDENES:
        o = o.replace('\n', N)
        assert s.count(o) == 1, o
        sangria = o[:len(o) - len(o.lstrip())]
        s = s.replace(o, sangria + uno + N + o)
    s = base.once(s, 'function Lg_Tick takes nothing returns nothing\n', PULSO + 'function Lg_Tick takes nothing returns nothing\n')
    s = base.once(s, '        if t >= Lg_Muestra then\n',
                  '        if t >= Lg_Latido then\n            set Lg_Latido = R2I(t) + 1\n            call Lg_Pulso(t)\n        endif\n        if t >= Lg_Muestra then\n')
    s = base.once(s, '    call StartSound(Ronda_TemaActual)\n',
                  '    call Sonda_Log("evento tema inicia " + I2S(Ronda_Numero))\n    call StartSound(Ronda_TemaActual)\n')
    s = base.once(s, '        call StopSound(Ronda_TemaActual, false, false)\n',
                  '        call Sonda_Log("evento tema para " + I2S(Ronda_Numero))\n        call StopSound(Ronda_TemaActual, false, false)\n')
    s = base.once(s, '    call DevWave_Start(Ronda_Numero)\n', '    call Sonda_Log("evento oleada inicia " + I2S(Ronda_Numero))\n    call DevWave_Start(Ronda_Numero)\n')
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
