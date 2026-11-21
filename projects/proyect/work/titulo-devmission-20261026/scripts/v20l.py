#!/usr/bin/env python3
"""v20l (20/11/2026): modelos del cuadro MVP / menos puntos de frente, elegido por Leon en v20k-prueba ("usemos 0").
- Cada personaje usa su copia 'hMf0'..'hMf6' (objetos_v20i.py, mvp_frente.cjs sin grados): el modelo cuelga de un
  hueso billboard en los pies y mira a la cámara, como el retrato de las tarjetas de racha; sin sombra ni niebla.
  Otro tipo de personaje usa su propio modelo, como antes.
- Valores ajustados en la partida de v20i/v20k: escala 0,27, x 1262, pies a y 358 (MVP) y 590 (menos puntos).
  El giro ya no cuenta (billboard).
Uso: v20l.py ENTRADA.j SALIDA.j [prueba]   (normal de v20g; prueba de v20g-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('constant real MVP_MOD_ESCALA = 0.22\n', 'constant real MVP_MOD_ESCALA = 0.27\n')
cambia('constant real MVP_MOD_X = 1310.\n', 'constant real MVP_MOD_X = 1262.\n')
cambia('MVP_MOD_X, 300.0 + dy, MVP_MOD_RANGO', 'MVP_MOD_X, 358.0 + dy, MVP_MOD_RANGO')
cambia('MVP_MOD_X, 532.0 + dy, MVP_MOD_RANGO', 'MVP_MOD_X, 590.0 + dy, MVP_MOD_RANGO')
cambia('''// v20c: copia del personaje h para el cuadro de p (igual en todos los clientes; sólo p la ve).
function Mvp_Modelo takes integer p, unit h returns unit''', '''// v20l: tipo con el modelo de frente (hueso billboard, como el retrato de las rachas).
function Mvp_TipoFrente takes integer id returns integer
    if id == 'h005' then
        return 'hMf0'
    elseif id == 'h006' then
        return 'hMf1'
    elseif id == 'hGok' then
        return 'hMf2'
    elseif id == 'hFrz' then
        return 'hMf3'
    elseif id == 'hTrk' then
        return 'hMf4'
    elseif id == 'hNar' then
        return 'hMf5'
    elseif id == 'hNaK' then
        return 'hMf6'
    endif
    return id
endfunction

// v20c: copia del personaje h para el cuadro de p (igual en todos los clientes; sólo p la ve).
function Mvp_Modelo takes integer p, unit h returns unit''')
cambia('set u = CreateUnit(CAMERA_DUMMY_PLAYER, GetUnitTypeId(h), 0., 0., MVP_MOD_GIRO)',
       'set u = CreateUnit(CAMERA_DUMMY_PLAYER, Mvp_TipoFrente(GetUnitTypeId(h)), 0., 0., MVP_MOD_GIRO)')
if prueba:
    for viejo, nuevo in (('lat\\\\v20g-', 'lat\\\\v20l-'), ('v20g-don.txt', 'v20l-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20l', 'prueba' if prueba else 'normal')
