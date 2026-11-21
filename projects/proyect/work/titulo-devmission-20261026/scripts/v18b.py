#!/usr/bin/env python3
"""v18b (15/11/2026): v18a con el sonido original de la tirada de Dark Moon en vez del tic sacado del vídeo.

Leon: el tic de v18a "suena muy diferente al del dark moon". En el VPK de Dark Moon, hud_round_reward lanza
Game.EmitSound("BoostCreeps.Random") en cada cambio (cada 0,2 s); el evento (game_sounds_game_rounds) usa
sounds/ui/panorama/panorama_custom_lobby_drawer_slide_in_01 de Dota 2, que dura 0,69 s: en el original se solapan
hasta 4. v18a lo cortaba a 0,19 s y además promediaba colas solapadas. Cambios:
- SupTic.wav pasa a ser ese sonido tal cual (PCM 44,1 kHz estéreo, ver sonido_v18b.py).
- Leon: un sonido nuevo en cada cambio (uno solo reutilizado se corta y satura). Se crea en todos los clientes y
  sólo el volumen es local; KillSoundWhenDone lo libera. El Sup_TicSnd de v18a queda sólo para precargar el wav.
Prueba: registros en lat\\v18b-*.txt.
Uso: v18b.py v18a/war3map.j SALIDA.j [prueba]
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
u8 = lambda s: s.encode('utf-8').decode('latin-1')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(u8(antes)), crlf(u8(despues))
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


una('    call SetSoundDuration(Sup_TicSnd, 190)\n', '    call SetSoundDuration(Sup_TicSnd, 688)\n')
una('''function Sup_Hud takes integer p, integer cam returns nothing
    local boolean shown
''', '''function Sup_Hud takes integer p, integer cam returns nothing
    local boolean shown
    local sound snd
''')
una('''    // Tic de la tirada (vídeo de Dark Moon): sólo lo oye el jugador p y sólo si ve sus tarjetas.
    if tic and shown and GetLocalPlayer() == Player(p) then
        call StopSound(Sup_TicSnd, false, false)
        call SetSoundVolume(Sup_TicSnd, 100)
        call StartSound(Sup_TicSnd)
    endif
''', '''    // Sonido de la tirada (BoostCreeps.Random de Dark Moon). v18b, a petición de Leon: uno nuevo en cada cambio,
    // que suena entero encima de los anteriores y se libera solo al acabar. Se crea en todos los clientes (crear
    // handles sólo en uno desincroniza); sólo el volumen depende del cliente: lo oye el jugador p si ve sus tarjetas.
    if tic then
        set snd = CreateSound("war3mapImported\\\\SupTic.wav", false, false, false, 10, 10, "DefaultEAXON")
        call SetSoundDuration(snd, 688)
        call SetSoundChannel(snd, 0)
        call SetSoundVolume(snd, 0)
        if shown and GetLocalPlayer() == Player(p) then
            call SetSoundVolume(snd, 100)
        endif
        call StartSound(snd)
        call KillSoundWhenDone(snd)
        set snd = null
    endif
''')
if prueba:
    for n in ('super', 'precarga', 'cuadros'):
        una(f'call PreloadGenEnd("lat\\\\v18a-{n}.txt")', f'call PreloadGenEnd("lat\\\\v18b-{n}.txt")')
    assert 'lat\\\\v18a-' not in j
assert j.count('Sup_TicSnd') == 6, j.count('Sup_TicSnd')
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v18b: sonido original de la tirada, uno nuevo por cambio' + (' + registro' if prueba else ''))
