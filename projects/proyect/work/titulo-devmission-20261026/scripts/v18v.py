#!/usr/bin/env python3
"""v18v (15/11/2026): sonidos del cuadro de resultados que no sonaban la primera vez (Leon, grabación 20261115_214358).

- Medido en v18u-prueba (dos "-punt 20" seguidos, correlación del audio con cada .wav): en el primer cuadro no se
  oyeron PuntSubeFin (≤ 0,10) ni la 2.ª y 3.ª estrella (0,19-0,36, frente a 0,99 de la 1.ª); en el segundo cuadro
  sonaron todos (0,59-0,73).
- Son_Cero los calentaba desde v18o, pero dentro de Son_Init, que corre en la carga (Precarga_Todo): un StartSound
  antes de empezar la partida no llega a cargar el sonido. Hipótesis de esta versión, a confirmar con la prueba.
- Arreglo: Son_Calentar, 1 s y 3 s después de empezar la partida, crea cada sonido del cuadro con los mismos
  parámetros que Punt_Sonar (duración, canal 0) a volumen 0; las estrellas, dos a la vez (se solapan cada 0,4 s).
  También el tic y QuestCompleted por etiqueta.
Uso: v18v.py ENTRADA.j SALIDA.j [prueba]   (prueba parte de v18u-prueba: registros v18u -> v18v)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
modo = sys.argv[3] if len(sys.argv) > 3 else ''
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


CAL = '''// v18v: primer uso real, ya en partida, con los mismos parámetros que Punt_Sonar y a volumen 0.
function Son_CeroP takes string f, integer dur returns nothing
    local sound s = CreateSound(f, false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(s, dur)
    call SetSoundChannel(s, 0)
    call SetSoundVolume(s, 0)
    call StartSound(s)
    call KillSoundWhenDone(s)
    set s = null
endfunction

function Son_CeroEtiqueta takes string l returns nothing
    local sound s = CreateSoundFromLabel(l, false, false, false, 10000, 10000)
    call SetSoundVolume(s, 0)
    call StartSound(s)
    call KillSoundWhenDone(s)
    set s = null
endfunction

// v18v: en Son_Init (carga) el StartSound no basta; esto corre 1 s y 3 s después de empezar la partida.
function Son_Calentar takes nothing returns nothing
    local sound s = CreateSound("war3mapImported\\\\PuntSube.wav", true, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(s, 2802)
    call SetSoundChannel(s, 0)
    call SetSoundVolume(s, 0)
    call StartSound(s)
    call StopSound(s, true, false)
    set s = null
    call Son_CeroP("war3mapImported\\\\PuntSubeFin.wav", 1311)
    call Son_CeroP("war3mapImported\\\\PuntPerdida.wav", 971)
    call Son_CeroP("war3mapImported\\\\PuntPerdida.wav", 971)
    call Son_CeroP("war3mapImported\\\\PuntTic.wav", 997)
    call Son_CeroP("war3mapImported\\\\PuntTic.wav", 997)
    call Son_CeroP("war3mapImported\\\\PuntEstrella1.wav", 1459)
    call Son_CeroP("war3mapImported\\\\PuntEstrella1.wav", 1459)
    call Son_CeroP("war3mapImported\\\\PuntEstrella2.wav", 1469)
    call Son_CeroP("war3mapImported\\\\PuntEstrella2.wav", 1469)
    call Son_CeroEtiqueta("QuestCompleted")
    call Son_CeroEtiqueta("ChatroomTimerTick")
endfunction

function Son_CalentarOtra takes nothing returns nothing
    call Son_Calentar()
    call DestroyTimer(GetExpiredTimer())
endfunction

'''
cambia('function Son_Init takes nothing returns nothing\n', CAL + 'function Son_Init takes nothing returns nothing\n')
cambia('    call Son_Cero("Sound\\\\Interface\\\\BattleNetTick.wav")\nendfunction\n',
       '    call Son_Cero("Sound\\\\Interface\\\\BattleNetTick.wav")\n'
       '    // v18v: calentado otra vez ya en partida (los temporizadores corren al empezar).\n'
       '    call TimerStart(CreateTimer(), 1., false, function Son_CalentarOtra)\n'
       '    call TimerStart(CreateTimer(), 3., false, function Son_CalentarOtra)\n'
       'endfunction\n')

if modo == 'prueba':
    assert src.count('lat\\\\v18u-') == 4, src.count('lat\\\\v18u-')
    src = src.replace('lat\\\\v18u-', 'lat\\\\v18v-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18v', modo or 'normal')
