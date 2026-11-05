#!/usr/bin/env python3
"""v13e: un tema por ronda sobre v13d, como en IziPizi; suena en la ronda y calla en el descanso.

Uso: v13e.py IN_J OUT_J TEMAS
TEMAS tiene una línea por ronda: número y duración en milisegundos.
"""
from pathlib import Path
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

TEMA = '''function Ronda_TemaEmpezar takes nothing returns nothing
    set Ronda_TemaActual = Ronda_Tema[Ronda_Numero]
    call StartSound(Ronda_TemaActual)
SONDA_INICIO
endfunction

function Ronda_TemaParar takes nothing returns nothing
    if Ronda_TemaActual != null then
        call StopSound(Ronda_TemaActual, false, false)
        set Ronda_TemaActual = null
    endif
endfunction

'''
# Sound state differs per client, so it is only read for the hidden log.
SONDA = '''function Ronda_TemaSonda takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    if Ronda_TemaActual != null then
        call Sonda_Log("tema ronda " + I2S(Ronda_Numero) + " suena " + I2S(IntegerTertiaryOp(GetSoundIsPlaying(Ronda_TemaActual), 1, 0)) + " cargando " + I2S(IntegerTertiaryOp(GetSoundIsLoading(Ronda_TemaActual), 1, 0)))
    endif
endfunction

'''


def crear(temas):
    s = 'function Ronda_Temas takes nothing returns nothing\n'
    for n, ms in temas:
        s += f'    set Ronda_Tema[{n}] = CreateSound("war3mapImported\\\\OleadaTema{n}.mp3", true, false, false, 10, 10, "DefaultEAXON")\n'
        s += f'    call SetSoundDuration(Ronda_Tema[{n}], {ms})\n'
        s += f'    call SetSoundChannel(Ronda_Tema[{n}], 0)\n'
        s += f'    call SetSoundVolume(Ronda_Tema[{n}], 127)\n'
    return s + 'endfunction\n\n'


def aplicar(j_in, j_out, temas, crear):
    temas = [l.split() for l in Path(temas).read_text().splitlines()]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    registro = 'function Sonda_Log takes' in s
    s = base.once(s, 'constant integer Ronda_DESCANSO = 45\n',
                  'constant integer Ronda_DESCANSO = 45\nsound array Ronda_Tema\nsound Ronda_TemaActual = null\n')
    bloque = crear(temas) + (SONDA if registro else '')
    sonda = '    call TimerStart(CreateTimer(), 1., false, function Ronda_TemaSonda)' if registro else ''
    bloque += TEMA.replace('SONDA_INICIO\n', sonda + '\n' if sonda else '')
    t = 'function Vidas_Derrota takes nothing returns nothing\n'
    s = base.once(s, t, bloque + t)
    s = base.once(s, '    call DevWave_Start(Ronda_Numero)\n', '    call DevWave_Start(Ronda_Numero)\n    call Ronda_TemaEmpezar()\n')
    s = base.once(s, '        set Ronda_Descanso = true\n        set Ronda_Resta = Ronda_DESCANSO\n',
                  '        set Ronda_Descanso = true\n        call Ronda_TemaParar()\n        set Ronda_Resta = Ronda_DESCANSO\n')
    s = base.once(s, '    set Vidas_Perdida = true\n', '    set Vidas_Perdida = true\n    call Ronda_TemaParar()\n')
    s = base.once(s, '    call DevWave_Marcadores()\n', '    call DevWave_Marcadores()\n    call Ronda_Temas()\n')
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))


if __name__ == '__main__':
    aplicar(*sys.argv[1:4], crear)
