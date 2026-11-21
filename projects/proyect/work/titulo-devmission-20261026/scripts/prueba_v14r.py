#!/usr/bin/env python3
"""Sólo prueba, v14r. MODO intro y directa: los de prueba_v14q.py con el registro en lat\\v14r-N.txt y el chat «-rayo N»
(tormenta de la variante N, 1..3; otro valor la elige al azar).
MODO rayos (no se entrega): entrada directa; con la ronda activa lanza una tormenta cada 4 s (variantes 1, 2, 3 por
turno) y registra «rayo K variante V activas A dummies D lanzadas L». Tras 12 tormentas espera 10 s y registra «fin
activas A dummies D» y COMPLETE: al final no debe quedar ninguna tormenta ni unidad 'h00S'.
Uso: prueba_v14r.py ENTRADA.j SALIDA.j MODO
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal, modo = sys.argv[1:4]
assert modo in ('intro', 'directa', 'rayos')
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14q.py'), ent, sal, 'intro' if modo == 'intro' else 'directa', 'v14r'],
               check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
s = base.once(s, '''    elseif m == "-vaciar" then
''', '''    elseif SubString(m, 0, 6) == "-rayo " then
        call Storm_Rayo(S2I(SubString(m, 6, StringLength(m))))
    elseif m == "-vaciar" then
''')
if modo == 'rayos':
    s = base.once(s, 'integer Prueba_N= 0\n', 'integer Prueba_N= 0\ninteger Prueba_K= 0\ninteger Prueba_Espera= 0\n')
    s = base.once(s, '    call TimerStart(CreateTimer(), 2., true, function Prueba_Tick)\n',
                  '    call TimerStart(CreateTimer(), 4., true, function Prueba_Rayos)\n')
    s = base.once(s, 'function Prueba_Iniciar takes nothing returns nothing\n', r'''function Prueba_Dummies takes nothing returns string
    local integer n = 0
    local unit u
    call GroupEnumUnitsOfPlayer(Prueba_G, Player(PLAYER_NEUTRAL_PASSIVE), null)
    loop
        set u = FirstOfGroup(Prueba_G)
        exitwhen u == null
        call GroupRemoveUnit(Prueba_G, u)
        if GetUnitTypeId(u) == 'h00S' then
            set n = n + 1
        endif
    endloop
    return " activas " + I2S(s__Storm__TStorm_SIZE) + " dummies " + I2S(n)
endfunction

function Prueba_Rayos takes nothing returns nothing
    if not Ronda_Activa or Ronda_Descanso then
        return
    endif
    if Prueba_K < 12 then
        set Prueba_K = Prueba_K + 1
        call Storm_Rayo(ModuloInteger(Prueba_K - 1, 3) + 1)
        call Prueba_Log("rayo " + I2S(Prueba_K) + " variante " + I2S(ModuloInteger(Prueba_K - 1, 3) + 1) + Prueba_Dummies() + " lanzadas " + I2S(Storm_Lanzadas))
    elseif Prueba_Espera < 3 then
        set Prueba_Espera = Prueba_Espera + 1
        if Prueba_Espera == 3 then
            call Prueba_Log("fin" + Prueba_Dummies() + " lanzadas " + I2S(Storm_Lanzadas))
            call Prueba_Log("COMPLETE")
        endif
    endif
endfunction

function Prueba_Iniciar takes nothing returns nothing
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
