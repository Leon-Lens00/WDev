#!/usr/bin/env python3
"""Sólo prueba, v14q. MODO intro y directa: los de prueba_v14p.py (los de Leon) con el registro en lat\\v14q-N.txt.
MODO estres (no se entrega): entrada directa, la primera ronda pasa a ser la 9 (nueve tipos nuevos a la vez), el héroe
recupera la vida cada 0,1 s y cada 10 s mueren de golpe 30 unidades de la oleada (daño del héroe, como en partida).
Sirve para comparar cuadros con el mismo puente sobre v14p y v14q (prefijo del registro: el tercer argumento).

Registro de estres: 1 s después de cada matanza, «matanza K en T muertas N vivas V cadaveres C» (T es el segundo de
juego de la matanza; el registro va 1 s después para que su escritura no caiga en el mismo cuadro). Al final COMPLETE.
Uso: prueba_v14q.py ENTRADA.j SALIDA.j MODO [PREFIJO]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal, modo = sys.argv[1:4]
pref = sys.argv[4] if len(sys.argv) > 4 else 'v14q'
assert modo in ('intro', 'directa', 'estres')
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14p.py'), ent, sal, 'intro' if modo == 'intro' else 'directa'],
               check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call PreloadGenEnd("lat\\\\v14p-" + I2S(Prueba_N) + ".txt")',
              'call PreloadGenEnd("lat\\\\' + pref + '-" + I2S(Prueba_N) + ".txt")')
if modo == 'estres':
    # Sin el registro de cada 2 s: cada escritura cuesta un cuadro.
    s = base.once(s, '    call TimerStart(CreateTimer(), 2., true, function Prueba_Tick)\n',
                  '    call TimerStart(CreateTimer(), 0.1, true, function Prueba_Vida)\n'
                  '    call TimerStart(CreateTimer(), 0.5, true, function Prueba_Estres)\n')
    s = base.once(s, 'integer Prueba_N= 0\n', 'integer Prueba_N= 0\ninteger Prueba_K= 0\nreal Prueba_S= 0.\ninteger Prueba_M= 0\n')
    s = base.once(s, '    call DevWave_Start(Ronda_Numero)\n', '    set Ronda_Numero = IMaxBJ(Ronda_Numero, 9)\n    call DevWave_Start(Ronda_Numero)\n')
    s = base.once(s, 'function Prueba_Iniciar takes nothing returns nothing\n', r'''function Prueba_Vida takes nothing returns nothing
    if Game_Hero[0] != null and GetWidgetLife(Game_Hero[0]) > 0.405 then
        call SetWidgetLife(Game_Hero[0], GetUnitState(Game_Hero[0], UNIT_STATE_MAX_LIFE))
    endif
endfunction

// Cuenta vivas y cadáveres de los dueños de las oleadas; con matar > 0 mata esas vivas con daño del héroe.
function Prueba_Contar takes integer matar returns string
    local integer o = WAVE_DEFAULT_OWNER_MIN
    local integer vivas = 0
    local integer cad = 0
    local integer n = 0
    local unit u
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        call GroupEnumUnitsOfPlayer(Prueba_G, Player(o), null)
        loop
            set u = FirstOfGroup(Prueba_G)
            exitwhen u == null
            call GroupRemoveUnit(Prueba_G, u)
            if GetWidgetLife(u) > 0.405 then
                if n < matar then
                    call UnitDamageTarget(Game_Hero[0], u, 1000000., true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, null)
                    set n = n + 1
                else
                    set vivas = vivas + 1
                endif
            else
                set cad = cad + 1
            endif
        endloop
        set o = o + 1
    endloop
    if matar > 0 then
        set Prueba_M = n
    endif
    set u = null
    return " vivas " + I2S(vivas) + " cadaveres " + I2S(cad)
endfunction

function Prueba_Estres takes nothing returns nothing
    local string c
    if not Ronda_Activa or Ronda_Descanso or Game_Hero[0] == null then
        return
    endif
    set Prueba_S = Prueba_S + 0.5
    if Prueba_S == 2. then
        call Prueba_Log("ronda " + I2S(Ronda_Numero) + " limite " + I2S(DevWave_Limite) + " total " + I2S(DevWave_Total))
    elseif ModuloInteger(R2I(Prueba_S * 2.), 20) == 0 and Prueba_S <= 150. then
        set Prueba_K = Prueba_K + 1
        call Prueba_Contar(30)
    elseif ModuloInteger(R2I(Prueba_S * 2.), 20) == 2 and Prueba_K > 0 and Prueba_S <= 151. then
        set c = Prueba_Contar(0)
        call Prueba_Log("matanza " + I2S(Prueba_K) + " en " + R2S(Prueba_S - 1.) + " muertas " + I2S(Prueba_M) + c)
    elseif Prueba_S == 155. then
        call Prueba_Log("fin" + Prueba_Contar(0))
        call Prueba_Log("COMPLETE")
    endif
endfunction

function Prueba_Iniciar takes nothing returns nothing
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
