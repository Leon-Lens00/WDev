#!/usr/bin/env python3
"""v21z (22/11/2026): la Bijuu Dama de Kurama choca con árboles y precipicios y estalla ahí.

Leon tras v21y-prueba: "funciona bien, solo seria ajustar el ulti que esta traspasando arboles y pendientes".
La onda de la R la mueve G2F_WAVE (código común con Freezer) con SetUnitX/Y, sin choque. Para la pieza de Kurama (hKu0)
cada paso se traza con GroundCollision como Don_Pon (v21u, radio 24): si choca, se queda en el último punto libre y
muere; G2F_Bijuu_Dama_sfx ve la pieza muerta y hace la explosión (700, 3480 en T6) en ese punto. Las ondas de Freezer
no cambian.
Registro (sólo prueba): "kurama R choca en X Y".
Uso: v21z.py ENTRADA.j SALIDA.j [prueba]   (normal de v21y; prueba de v21y-prueba).
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


cambia('''    local real dx
    local real dy
    loop
        exitwhen i > G2V_WaveIndex
        set u = G2V_WaveDummy[i]
''', '''    local real dx
    local real dy
    local boolean choca
    loop
        exitwhen i > G2V_WaveIndex
        set u = G2V_WaveDummy[i]
''')
cambia('''                set y = GetUnitY(u) + I2R(G2V_WaveSpeed[i]) * Sin(a)
                if x < GetRectMinX(bj_mapInitialPlayableArea)''', '''                set y = GetUnitY(u) + I2R(G2V_WaveSpeed[i]) * Sin(a)
                // v21z: la Bijuu Dama de Kurama (hKu0) para en árboles y precipicios, como Don_Pon (v21u).
                set choca = false
                if GetUnitTypeId(u) == 'hKu0' and s__GroundCollision_trace(GetUnitX(u), GetUnitY(u), x, y, 24., u, GetOwningPlayer(u), false) != 0 then
                    set choca = true
                    set x = s__GroundCollision_x
                    set y = s__GroundCollision_y
''' + ('''                    set Cop_Log = "kurama R choca en " + I2S(R2I(x)) + " " + I2S(R2I(y))
                    call ExecuteFunc("Cop_Anotar")
''' if prueba else '') + '''                endif
                if x < GetRectMinX(bj_mapInitialPlayableArea)''')
cambia('''                    call SetUnitX(u, x)
                    call SetUnitY(u, y)
                    set c = null
                    if IsUnitInGroup(u, G2V_Group3[$A7]) then
''', '''                    call SetUnitX(u, x)
                    call SetUnitY(u, y)
                    if choca then
                        call KillUnit(u)
                    endif
                    set c = null
                    if IsUnitInGroup(u, G2V_Group3[$A7]) then
''')
if prueba:
    cambia('lat\\\\v21y-', 'lat\\\\v21z-', src.count('lat\\\\v21y-'))
    cambia('v21y-don.txt', 'v21z-don.txt', src.count('v21y-don.txt'))
    assert 'lat\\\\v21y-' not in src and 'v21y-don.txt' not in src, 'quedan registros v21y'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21z', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
