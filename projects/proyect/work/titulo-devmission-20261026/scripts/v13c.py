#!/usr/bin/env python3
"""v13c: los puntos de oleada salen de los marcadores 'nPto' del mapa guardado en el editor.

El script de v13b ya no crea marcadores en partida: las posiciones se escriben al construir.
Uso: v13c.py IN_J OUT_J war3mapUnits.doo
"""
from pathlib import Path
import re
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base
from puntos_editor_v13b import leer

if __name__ == '__main__':
    j_in, j_out, unidades = sys.argv[1:4]
    puntos = list(leer(unidades))
    assert 0 < len(puntos) <= 100
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    s = base.once(s, "    call CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'nPto', -192.0, -512.0, 270.)\n", '')
    cuerpo = ''.join(f'        set DevWave_MarcaX[{i}] = {x}\n        set DevWave_MarcaY[{i}] = {y}\n' for i, (x, y) in enumerate(puntos))
    cuerpo += f'        set DevWave_Marcas = {len(puntos)}\n'
    s, n = re.subn(r"    // Reads and removes the 'nPto' markers[^\r\n]*\r\n(    function DevWave_Marcadores takes nothing returns nothing\r\n).*?(    endfunction\r\n)",
                   lambda m: "    // Wave spawn points: the 'nPto' markers of puntos/Swamped-Puntos.w3x.\r\n" + m[1] + cuerpo.replace('\n', '\r\n') + m[2], s, count=1, flags=re.S)
    assert n == 1
    Path(j_out).write_text(s, encoding='latin-1', newline='')
    print('ok', len(puntos))
