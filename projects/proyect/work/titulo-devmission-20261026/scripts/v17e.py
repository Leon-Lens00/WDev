#!/usr/bin/env python3
"""v17e (14/11/2026): truenos y cambio de arma un 25 % más bajos.

Leon (14/11/2026): "solo seria reducir un 25% a los rayos y audio al cambiar de arma". Volumen 127 → 95 en el trueno de
Storm y en SonCambio (Son_Ui recibe el volumen; caja y tienda siguen a 127). Los archivos nuevos (sonidos_v17e.py)
sustituyen a los de v17d con el mismo nombre.
Uso: v17e.py v17d/war3map.j SALIDA.j
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


una('''function Son_Ui takes integer p, sound s returns nothing
    if GetLocalPlayer() == Player(p) then
        call StopSound(s, false, false)
        call SetSoundVolume(s, 127)
''', '''function Son_Ui takes integer p, sound s, integer v returns nothing
    if GetLocalPlayer() == Player(p) then
        call StopSound(s, false, false)
        call SetSoundVolume(s, v)
''')
una('    call Son_Ui(p , Son_CajaSnd)\n', '    call Son_Ui(p , Son_CajaSnd , 127)\n')
una('    call Son_Ui(p, Son_TiendaSnd)\n', '    call Son_Ui(p, Son_TiendaSnd, 127)\n')
una('        call Son_Ui(p , Son_CambioSnd)\n', '        // v17e: 25 % más bajo.\n        call Son_Ui(p , Son_CambioSnd , 95)\n')
una('''            call SetSoundVolume(s, 127)
            call SetSoundPitch(s, GetRandomReal(0.9, 1.1))
''', '''            // v17e: 25 % más bajo.
            call SetSoundVolume(s, 95)
            call SetSoundPitch(s, GetRandomReal(0.9, 1.1))
''')
assert j.count('call Son_Ui(') == 3
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17e: truenos y cambio de arma a 95')
