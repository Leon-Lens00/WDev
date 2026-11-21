#!/usr/bin/env python3
"""v16t-shots (13/11/2026): MP5 (subfusil) con las balas de Shot vol. 1 y el fusil de asalto con Shot II (vol. 2).
Leon: "si colocamos ahora la mp5 con balas del shot vol 1 y la scar ya se queda con el shot vol 2". Viene del estrés:
con Daemonic Arrow el fusil de asalto daba 45 fps, con Shot II 56 (v16t-perfora-estres3).
- Subfusil: ShotsAjustados\\Shot <color>.mdx; el radio de choque sigue en 18 (16,2 en el tier 2), como con Shot II.
- Fusil de asalto: ShotsAjustados\\Shot II <color>.mdx y su radio 18 (antes Daemonic Arrow, 15).
- Francotirador sigue con Daemonic Arrow. Precarga de Shot Yellow, Purple y Red (Blue, Cyan y Green ya estaban).
Uso: shots_v16t.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes()


def una(a, b):
    global j
    a, b = a.replace(b'\n', b'\r\n'), b.replace(b'\n', b'\r\n')
    assert j.count(a) == 1, (a, j.count(a))
    j = j.replace(a, b)


una(b'''    elseif c == 1 then
        set Arm_BalaModelo = "ShotsAjustados\\\\Shot II " + Arm_ColorTier(t, false) + ".mdx"
        set Arm_BalaRadio = 18. * s__RapidBolt_SHOTS_II_SCALE
        if t == 2 then
            set Arm_BalaRadio = 16.2 * s__RapidBolt_SHOTS_II_SCALE
        endif
    elseif c == 2 or c == 3 then
''', b'''    elseif c == 1 or c == 2 then
        // v16t-shots: fusil de asalto con Shot II; subfusil con Shot (vol. 1) y el mismo radio de choque.
        set Arm_BalaModelo = "ShotsAjustados\\\\Shot II " + Arm_ColorTier(t, false) + ".mdx"
        if c == 1 then
            set Arm_BalaModelo = "ShotsAjustados\\\\Shot " + Arm_ColorTier(t, false) + ".mdx"
        endif
        set Arm_BalaRadio = 18. * s__RapidBolt_SHOTS_II_SCALE
        if t == 2 then
            set Arm_BalaRadio = 16.2 * s__RapidBolt_SHOTS_II_SCALE
        endif
    elseif c == 3 then
''')
una(b'    call Preload("ShotsAjustados\\\\Shot Green.mdx")\n',
    b'    call Preload("ShotsAjustados\\\\Shot Green.mdx")\n'
    b'    call Preload("ShotsAjustados\\\\Shot Purple.mdx")\n'
    b'    call Preload("ShotsAjustados\\\\Shot Red.mdx")\n'
    b'    call Preload("ShotsAjustados\\\\Shot Yellow.mdx")\n')
Path(sys.argv[2]).write_bytes(j)
print('v16t-shots: MP5 Shot, fusil de asalto Shot II')
