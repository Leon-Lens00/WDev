#!/usr/bin/env python3
"""v17g (14/11/2026): el trueno ya no baja la música; destaca por su archivo (sonidos_v17g.py).

Leon (14/11/2026), tras probar v17f ("fue bien la prueba ahora si"): "sin bajar la music, el rayo debera destacar por si
solo". Se quitan VolumeGroupSetVolume(MUSIC, 0.45) y el reloj que la devolvía; el trueno sigue a volumen 95.
Uso: v17g.py v17f/war3map.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')


def una(antes, despues):
    global j
    antes, despues = crlf(antes), crlf(despues)
    assert j.count(antes) == 1, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


una('                call VolumeGroupSetVolume(SOUND_VOLUMEGROUP_MUSIC, 0.45)\n', '')
una('            call TimerStart(Son_Musica, 4., false, function Son_MusicaVuelve)\n', '')
una('por turno (igual en todos los clientes); la música baja 4 s.', 'por turno (igual en todos los clientes). v17g: sin bajar la música.')
assert 'VolumeGroupSetVolume(SOUND_VOLUMEGROUP_MUSIC, 0.45)' not in j
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17g: trueno sin bajar la música')
