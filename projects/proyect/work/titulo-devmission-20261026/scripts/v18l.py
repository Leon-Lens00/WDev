#!/usr/bin/env python3
"""v18l (15/11/2026): correcciones del cuadro de puntuación tras la prueba de v18k (grabación 20261115_172554).

- Leon: el sonido al salir el cuadro pasa a ser el nativo de misión completada (etiqueta "QuestCompleted" de
  UISounds, el mismo que bj_questCompletedSound de Blizzard.j), en lugar de la fanfarria de Dark Moon.
- Entrada: en la grabación el juego se queda quieto ~0,15-0,25 s justo al acabar la ronda (37,27-37,40 s) y el cuadro
  aparece ya casi en su sitio: la caída de 0,4 s pasó durante el parón. Ahora el cuadro espera 0,25 s oculto y cae en
  0,5 s (termina a 0,75 s; el recuento empieza a 1 s, como antes). La fanfarria suena al empezar la caída.
- Los 6 wav del recuento se precargan con el resto de la precarga (BM), para no leerlos del disco en mitad del cuadro.
- Las barras sobre las unidades (nombre y vida, texttags del mundo) se dibujan siempre delante de las piezas del HUD:
  se ocultan para el jugador que tiene el cuadro a la vista (Barras_Visible, sólo visual y local).
- Prueba: registros renombrados v18k -> v18l.
Uso: v18l.py ENTRADA.j SALIDA.j [prueba]
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')  # sin traducir finales de línea (CRLF con algunos LF/CR sueltos)
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'


def cambia(viejo, nuevo, veces=1):
    global src
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:80])
    src = src.replace(viejo, nuevo)


ESPERA, CAIDA = 0.25, 0.5
# Sonido nativo de misión completada, sólo audible para quien ve el cuadro.
cambia('function Punt_BucleFin takes nothing returns nothing\n',
       '// v18l: sonido nativo de misión completada (UISounds "QuestCompleted"), como bj_questCompletedSound.\n'
       'function Punt_SonarMision takes nothing returns nothing\n'
       '    local sound snd = CreateSoundFromLabel("QuestCompleted", false, false, false, 10000, 10000)\n'
       '    if not Punt_Visible(GetPlayerId(GetLocalPlayer())) then\n'
       '        call SetSoundVolume(snd, 0)\n'
       '    endif\n'
       '    call StartSound(snd)\n'
       '    call KillSoundWhenDone(snd)\n'
       '    set snd = null\n'
       'endfunction\n\n'
       'function Punt_BucleFin takes nothing returns nothing\n')
cambia('    if Punt_Son[0] == 0 then\n        set Punt_Son[0] = 1\n'
       '        call Punt_Sonar("war3mapImported\\\\PuntFanfarria.wav", 6400, 114)\n',
       f'    if Punt_Son[0] == 0 and Punt_T >= {ESPERA} then\n        set Punt_Son[0] = 1\n'
       '        call Punt_SonarMision()\n')
# Entrada retrasada y más larga.
cambia('    set shown = Punt_Visible(p)\n    if Punt_Visto[p] != Punt_Ver then\n',
       f'    set shown = Punt_Visible(p) and Punt_T >= {ESPERA}\n    if Punt_Visto[p] != Punt_Ver then\n')
cambia('    // Entrada desde arriba en 0,4 s (frenando) y salida hacia abajo en 0,5 s (acelerando).\n'
       '    if Punt_T < 0.4 then\n        set a = 1. - Punt_T / 0.4\n',
       '    // v18l: espera 0,25 s oculto (el parón del fin de ronda), entra desde arriba en 0,5 s (frenando) y sale\n'
       '    // hacia abajo en 0,5 s (acelerando).\n'
       f'    if Punt_T < {ESPERA + CAIDA} then\n        set a = RMaxBJ(0., 1. - (Punt_T - {ESPERA}) / {CAIDA})\n')
# Precarga de los wav del recuento.
WAV = ['PuntSube', 'PuntSubeFin', 'PuntPerdida', 'PuntTic', 'PuntEstrella1', 'PuntEstrella2']
cambia('    call BM_Marca(18, "fin")\n',
       ''.join(f'    call Preload("war3mapImported\\\\{w}.wav")\n' for w in WAV) + '    call BM_Marca(18, "fin")\n')
# Barras del mundo ocultas mientras el cuadro está a la vista.
cambia('    return not Shop_Open[GetPlayerId(l)] and not IsUnitHidden(u) and IsUnitVisible(u, l)\n',
       '    return not Shop_Open[GetPlayerId(l)] and not IsUnitHidden(u) and IsUnitVisible(u, l) and not (Punt_Visible(GetPlayerId(l)) and Punt_T >= '
       f'{ESPERA})\n')
assert 'PuntFanfarria' not in src
if prueba:
    n = src.count('lat\\\\v18k-')
    assert n == 4, n
    src = src.replace('lat\\\\v18k-', 'lat\\\\v18l-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18l', 'prueba' if prueba else 'normal')
