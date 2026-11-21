#!/usr/bin/env python3
"""Sólo prueba, v14zf: las de prueba_v14zb.py (MODO intro o directa, VARIANTE dia|tarde|noche) con el registro en
lat\\v14zf-N.txt y además:
- Vida ilimitada: cada 0,03 s el héroe de cada jugador vuelve a su vida máxima (no se usa invulnerabilidad, que
  bloquea la IA de salto de los enemigos). Regla de las pruebas de Leon desde v14zf.
- Chat «-bateria N» deja la batería en N segundos (0..100) y «-cargas N» fija las recargas.
- El registro de cada 2 s añade « bat T cargas C luz L» (L: paso de luz, -1 apagada, 5 entera).
Uso: prueba_v14zf.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal, modo = sys.argv[1:4]
assert modo in ('intro', 'directa')
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14zb.py'), ent, sal, modo] + sys.argv[4:5], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
assert s.count('lat\\\\v14zb-') == 1
s = s.replace('lat\\\\v14zb-', 'lat\\\\v14zf-')
s = base.once(s, '''    elseif m == "-vaciar" then
''', '''    elseif SubString(m, 0, 9) == "-bateria " then
        set Bat_T[p] = RMinBJ(100., RMaxBJ(0., S2R(SubString(m, 9, StringLength(m)))))
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 10, "Bateria " + R2S(Bat_T[p]))
    elseif SubString(m, 0, 8) == "-cargas " then
        set Bat_Cargas[p] = IMaxBJ(0, S2I(SubString(m, 8, StringLength(m))))
    elseif m == "-vaciar" then
''')
s = base.once(s, '''    call Prueba_Log("t " + I2S(Prueba_T) + " tienda "''', '''    call Prueba_Log("t " + I2S(Prueba_T) + " bat " + R2S(Bat_T[p]) + " cargas " + I2S(Bat_Cargas[p]) + " luz " + I2S(Luz_Nivel[p]) + " vida " + I2S(R2I(GetWidgetLife(Game_Hero[p]))) + " tienda "''')
s = base.once(s, 'function Prueba_Iniciar takes nothing returns nothing\n', '''function Prueba_Vida takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        if GetUnitTypeId(Game_Hero[p]) != 0 and GetWidgetLife(Game_Hero[p]) > 0.405 then
            call SetWidgetLife(Game_Hero[p], GetUnitState(Game_Hero[p], UNIT_STATE_MAX_LIFE))
        endif
        set p = p + 1
    endloop
endfunction

function Prueba_Iniciar takes nothing returns nothing
''')
s = base.once(s, '    call TimerStart(CreateTimer(), 2., true, function Prueba_Tick)\n',
              '    call TimerStart(CreateTimer(), 2., true, function Prueba_Tick)\n'
              '    call TimerStart(CreateTimer(), 0.03, true, function Prueba_Vida)\n')
Path(sal).write_text(s, encoding='latin-1', newline='')
