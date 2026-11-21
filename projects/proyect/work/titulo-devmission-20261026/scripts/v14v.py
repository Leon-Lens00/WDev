#!/usr/bin/env python3
"""v14v: marcos de la tienda de vuelta y Dark Nights al atardecer. Parte del j de v14u.

- Desde v14q la tienda perdía sus marcos (paneles, filas, botones y el marco del retrato) aunque las 61 piezas se creaban
  y las 88 texturas se aplicaban. Lo provocaba Preload() de las texturas en Precarga_Todo: con las .blp precargadas,
  las piezas que toman la textura de un destructible ('DSxx', grabtree) no se dibujan. Sin la lista de Preload vuelven
  (prueba v14q-q2). Quitar sólo las .blp/.tga no bastó (v14v primera
  prueba); se quitan también los Preload de los modelos de esas piezas (TitleDummyAdd/Blend/Flat.mdl). El resto de
  modelos, sonidos y los efectos de precarga siguen igual.
- Hora fija al entrar: 18:15 (atardecer de Dark Nights: sol a ~0,86 frente a 1,3 de día y 0,05 de noche).

Uso: v14v.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
i = s.index('function Precarga_Todo takes')
j = s.index('endfunction', i)
patron = r'    call Preload\("(?:[^"]*\.(?:blp|tga)|war3mapImported\\\\TitleDummy(?:Add|Blend|Flat)\.mdl)"\)\r\n'
n = len(re.findall(patron, s[i:j]))
assert n == 346, n
s = s[:i] + re.sub(patron, '', s[i:j]) + s[j:]
s = base.once(s, '''// v14u: niebla negra de la partida (la de Storm escalada a la cámara de juego, como v14s) y noche fija de Dark Nights.
// El periódico de Storm aplica la niebla.
function Storm_Oscuro takes nothing returns nothing
    call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 0.)
'''.encode('utf-8').decode('latin-1'), '''// v14v: niebla negra de la partida (la de Storm escalada a la cámara de juego, como v14s) y atardecer fijo de Dark
// Nights (18:15). El periódico de Storm aplica la niebla.
function Storm_Oscuro takes nothing returns nothing
    call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 18.25)
'''.encode('utf-8').decode('latin-1'))
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v14v: quitados', n, 'Preload de texturas y piezas; hora 18:15')
