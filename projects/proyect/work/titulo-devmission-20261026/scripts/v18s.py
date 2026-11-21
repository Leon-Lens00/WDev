#!/usr/bin/env python3
"""v18s (15/11/2026): correcciones de la prueba de v18r (Leon, grabación 20261115_212510).

- Sonidos del recuento de bolsas: no faltaba la precarga. PuntSube.wav y PuntSubeFin.wav tienen una media de -23 y
  -25 dB (las estrellas, -10 dB) y sonaban a volumen 38 y 51 (las estrellas, 102): unos 20 dB por debajo, tapados por
  el ambiente en todas las rondas. Los .wav se suben (+12 dB, +12 dB y +16 dB PuntPerdida, con limitador; hacer-v18s.sh)
  y el bucle pasa a 90 y el final a 127.
- Barras del mundo (nombre y vida del héroe) ocultas mientras se ve el cuadro de la Mutación Evo: se dibujaban encima
  del cuadro central.
Prueba/lan: registros v18r -> v18s.  Uso: v18s.py ENTRADA.j SALIDA.j [prueba|lan]
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
modo = sys.argv[3] if len(sys.argv) > 3 else ''


def cambia(viejo, nuevo, veces=1):
    global src
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('IsUnitVisible(u, l) and not (Punt_Visible(GetPlayerId(l)) and Punt_T >= 0.25)\n',
       'IsUnitVisible(u, l) and not (Punt_Visible(GetPlayerId(l)) and Punt_T >= 0.25) and Mut_T < 0.\n')
cambia('            call SetSoundVolume(Punt_Bucle, 38)\n', '            call SetSoundVolume(Punt_Bucle, 90)\n')
cambia('call Punt_Sonar("war3mapImported\\\\PuntSubeFin.wav", 1311, 51)', 'call Punt_Sonar("war3mapImported\\\\PuntSubeFin.wav", 1311, 127)')

if modo in ('prueba', 'lan'):
    viejo = '-v18r-' if modo == 'lan' else 'lat\\\\v18r-'
    assert src.count(viejo) == 4, src.count(viejo)
    src = src.replace(viejo, viejo.replace('v18r', 'v18s'))
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18s', modo or 'normal')
