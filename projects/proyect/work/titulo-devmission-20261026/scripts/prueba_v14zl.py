#!/usr/bin/env python3
"""Sólo prueba, v14zl: las de prueba_v14zk.py con el registro en lat\\v14zl-N.txt, más:
- registro de cada evento de élites (tipo, jugadores, ronda, muertes/total, llamadas del jefe),
- registro de cada élite que aparece (tipo, vida máxima, ronda) y de cada llamada de refuerzos aplicada,
- «-llamar»: fuerza ya la llamada de refuerzos del jefe (DevJefe_Llamar, con su carga de 1,5 s).
Uso: prueba_v14zl.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal = sys.argv[1:3]
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14zk.py'), ent, sal, 'v14zl'] + sys.argv[3:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
assert s.count('lat\\\\v14zl-') == 1
# Registro accesible desde las funciones de oleada (Prueba_Log está definido más abajo).
s = base.once(s, '    function DevWave_Elite takes integer k returns nothing\n', '''function Prueba_LogW takes string s returns nothing
    set Prueba_N = Prueba_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\\\v14zl-" + I2S(Prueba_N) + ".txt")
endfunction

    function DevWave_Elite takes integer k returns nothing
''')
s = base.once(s, '''        if c > 0 and Ronda_Wave != 0 and not s__Wave_isDestroyed[Ronda_Wave] then
            call WaveUpsertSlotExByPlayer(Ronda_Wave , 900 + k''', '''        call Prueba_LogW("evento elite tipo " + I2S(k) + " jug " + I2S(c) + " ronda " + I2S(Ronda_Numero) + " ntipos " + I2S(DevWave_NTipos) + " muertos " + I2S(DevWave_Muertos) + "/" + I2S(DevWave_Total) + " E " + I2S(DevWave_EliteE) + " llamadas " + I2S(DevJefe_Llamadas))
        if c > 0 and Ronda_Wave != 0 and not s__Wave_isDestroyed[Ronda_Wave] then
            call WaveUpsertSlotExByPlayer(Ronda_Wave , 900 + k''')
s = base.once(s, '''        call SetWidgetLife(u, GetUnitState(u, UNIT_STATE_MAX_LIFE))
    endif
    call SaveEffectHandle(DevFuego_HT''', '''        call SetWidgetLife(u, GetUnitState(u, UNIT_STATE_MAX_LIFE))
        call Prueba_LogW("aparece elite tipo " + I2S(k) + " vida " + I2S(R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE))) + " ronda " + I2S(Ronda_Numero) + " jugador " + I2S(p))
    endif
    call SaveEffectHandle(DevFuego_HT''')
s = base.once(s, '''    if DevJefe_Llamadas == 1 then
        call DevWave_Elite(DevWave_NTipos - 1)
    endif
''', '''    call Prueba_LogW("llamada " + I2S(DevJefe_Llamadas) + " ronda " + I2S(Ronda_Numero) + " jefe vida " + I2S(R2I(GetUnitState(DevJefe, UNIT_STATE_MAX_LIFE))))
    if DevJefe_Llamadas == 1 then
        call DevWave_Elite(DevWave_NTipos - 1)
    endif
''')
s = base.once(s, '''    elseif m == "-fin" then
''', '''    elseif m == "-llamar" then
        call PauseTimer(DevJefe_Reloj)
        call DevJefe_Llamar()
    elseif m == "-fin" then
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
