#!/usr/bin/env python3
"""Sólo prueba, v14zk: las de prueba_v14zj.py con el registro en lat\\<NOMBRE>-N.txt, más «-efectos»: pone (o quita)
24 efectos alrededor del héroe (los 14 Shot y Shot II, los 9 Valiant Charge y RecargaRoja), en un anillo de 300.
Con las luces de v14zj son 24 luces además de la linterna; sin ellas sólo queda la linterna.
Uso: prueba_v14zk.py ENTRADA.j SALIDA.j NOMBRE MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal, nombre = sys.argv[1:4]
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14zj.py'), ent, sal] + sys.argv[4:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
assert s.count('lat\\\\v14zj-') == 1
s = s.replace('lat\\\\v14zj-', 'lat\\\\' + nombre + '-')
colores = ['Blue', 'Cyan', 'Green', 'Orange', 'Purple', 'Red', 'Yellow']
mods = ['ShotsAjustados\\\\Shot %s.mdx' % c for c in colores] + ['ShotsAjustados\\\\Shot II %s.mdx' % c for c in colores]
mods += ['ValiantCharge\\\\Valiant Charge %s.mdx' % c for c in ['Blue', 'Green', 'Orange', 'Pink', 'Purple', 'Red', 'Silver', 'Teal', 'Yellow']]
mods += ['war3mapImported\\\\RecargaRoja.mdx']
assert len(mods) == 24
s = base.once(s, 'real Title_CX=', 'effect array Prueba_Ef\nboolean Prueba_EfOn= false\nreal Title_CX=')
lineas = ''.join('''        set Prueba_Ef[%d] = AddSpecialEffect("%s", x + 300. * Cos(%d * 0.2618), y + 300. * Sin(%d * 0.2618))
''' % (i, m, i, i) for i, m in enumerate(mods))
s = base.once(s, '''    elseif m == "-fin" then
''', '''    elseif m == "-efectos" then
        set c = 0
        loop
            exitwhen c > 23
            if Prueba_Ef[c] != null then
                call DestroyEffect(Prueba_Ef[c])
                set Prueba_Ef[c] = null
            endif
            set c = c + 1
        endloop
        set Prueba_EfOn = not Prueba_EfOn
        if Prueba_EfOn then
            call Prueba_Efectos(GetUnitX(Game_Hero[p]), GetUnitY(Game_Hero[p]))
        endif
    elseif m == "-fin" then
''')
s = base.once(s, 'function Prueba_Chat takes nothing returns nothing\n', '''function Prueba_Efectos takes real x, real y returns nothing
''' + lineas + '''endfunction
function Prueba_Chat takes nothing returns nothing
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
