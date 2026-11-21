#!/usr/bin/env python3
"""Sólo prueba, v14zg: las de prueba_v14zf.py (vida ilimitada, «-bateria N», «-cargas N») con el registro en
lat\\v14zg-N.txt y el chat «-fin», que mata las unidades vivas de los dueños de oleada (WAVE_DEFAULT_OWNER_MIN..MAX)
para llegar antes al descanso; repetirlo hasta que acabe la oleada.
Uso: prueba_v14zg.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal = sys.argv[1:3]
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14zf.py')] + sys.argv[1:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
assert s.count('lat\\\\v14zf-') == 1
s = s.replace('lat\\\\v14zf-', 'lat\\\\v14zg-')
s = base.once(s, '''    elseif m == "-vaciar" then
''', '''    elseif m == "-fin" then
        call Prueba_Fin()
    elseif m == "-vaciar" then
''')
s = base.once(s, 'function Prueba_Chat takes nothing returns nothing\n', '''function Prueba_Fin takes nothing returns nothing
    local group g = CreateGroup()
    local integer o = WAVE_DEFAULT_OWNER_MIN
    local integer n = 0
    local unit u
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        call GroupEnumUnitsOfPlayer(g, Player(o), null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if GetWidgetLife(u) > 0.405 then
                call KillUnit(u)
                set n = n + 1
            endif
        endloop
        set o = o + 1
    endloop
    call DestroyGroup(g)
    set g = null
    call Prueba_Log("fin mata " + I2S(n))
endfunction

function Prueba_Chat takes nothing returns nothing
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
