#!/usr/bin/env python3
"""Sólo prueba, v14zo: las de prueba_v14zn.py con el registro en lat\\v14zo-N.txt, más:
- «-sumar N»: N bajas del jugador directamente en Racha_Muerte (umbrales y cola sin matar a nadie).
- «-matar N»: mata hasta N enemigos de oleada con el personaje como autor (pasa por Oro_Muerte, como una baja real).
- «-caer»: Racha_Romper del jugador (lo que hace s__RapidPair_fall al caer), sin perder una vida.
- «-rachas»: escribe en un registro los anuncios que salieron (T tipo, p jugador, sonido, reloj en centésimas; V voz del
  personaje), el estado de cada jugador y las celdas del marcador.
Uso: prueba_v14zo.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal = sys.argv[1:3]
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14zn.py')] + sys.argv[1:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
assert s.count('lat\\\\v14zn-') == 3
s = s.replace('lat\\\\v14zn-', 'lat\\\\v14zo-')
s = base.once(s, 'boolean array Racha_TablaVista\n', 'boolean array Racha_TablaVista\nstring Prueba_Racha= ""\n')
reloj = 'I2S(R2I(100. * TimerGetElapsed(s__RapidPair_clock)))'
s = base.once(s, '''        call Racha_Sonar(Racha_ColaSon[0])
''', '''        call Racha_Sonar(Racha_ColaSon[0])
        set Prueba_Racha = Prueba_Racha + " T" + I2S(Racha_ColaTipo[0]) + "p" + I2S(Racha_ColaPid[0]) + ":" + SubString(Racha_ColaSon[0], 16, StringLength(Racha_ColaSon[0]) - 4) + "@" + ''' + reloj + '''
''')
s = base.once(s, '''            call Racha_VozDe(Racha_VozPid)
''', '''            call Racha_VozDe(Racha_VozPid)
            set Prueba_Racha = Prueba_Racha + " V" + I2S(Racha_VozPid) + "@" + ''' + reloj + '''
''')
s = base.once(s, 'function Prueba_Chat takes nothing returns nothing\n', '''function Prueba_LogLargo takes string s returns nothing
    set Prueba_N = Prueba_N + 1
    call PreloadGenClear()
    loop
        exitwhen StringLength(s) == 0
        call Preload(SubString(s, 0, 240))
        set s = SubString(s, 240, StringLength(s))
    endloop
    call PreloadGenEnd("lat\\\\v14zo-" + I2S(Prueba_N) + ".txt")
endfunction
function Prueba_Matar takes integer p,integer n returns integer
    local integer o= WAVE_DEFAULT_OWNER_MIN
    local integer k= 0
    local group g= CreateGroup()
    local unit u
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX or k >= n
        call GroupEnumUnitsOfPlayer(g, Player(o), null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if k < n and GetWidgetLife(u) > 0.405 and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                call UnitDamageTarget(Game_Hero[p], u, 1000000., true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_UNIVERSAL, null)
                if GetWidgetLife(u) <= 0.405 then
                    set k = k + 1
                endif
            endif
        endloop
        set o = o + 1
    endloop
    call DestroyGroup(g)
    set g = null
    return k
endfunction
function Prueba_RachaLog takes nothing returns nothing
    local integer p= 0
    local string s= "rachas cola " + I2S(Racha_ColaN) + " filas [" + Racha_Fila[0] + "][" + Racha_Fila[1] + "][" + Racha_Fila[2] + "]"
    loop
        exitwhen p > 7
        if Racha_EnTabla[p] then
            set s = s + " | p" + I2S(p) + " total " + I2S(Racha_Total[p]) + " racha " + I2S(Racha_N[p]) + " tier " + I2S(Racha_Tier[p]) + " multi " + I2S(Racha_Multi[p]) + "/" + I2S(Racha_MultiTier[p]) + " vidas " + I2S(Vidas_Actual[p]) + " celdas " + Racha_Celda[p * 4 + 1] + "/" + Racha_Celda[p * 4 + 2] + "/" + Racha_Celda[p * 4 + 3] + " fila " + I2S(Racha_TablaFila[p])
        endif
        set p = p + 1
    endloop
    call Prueba_LogLargo(s + " | eventos" + Prueba_Racha)
endfunction
function Prueba_Chat takes nothing returns nothing
''')
s = base.once(s, '''    elseif m == "-llamar" then
''', '''    elseif SubString(m, 0, 7) == "-sumar " then
        set c = S2I(SubString(m, 7, StringLength(m)))
        loop
            exitwhen c <= 0
            call Racha_Muerte(p)
            set c = c - 1
        endloop
    elseif SubString(m, 0, 7) == "-matar " then
        call Prueba_Log("matar " + I2S(Prueba_Matar(p, S2I(SubString(m, 7, StringLength(m))))))
    elseif m == "-caer" then
        call Racha_Romper(p)
    elseif m == "-rachas" then
        call Prueba_RachaLog()
    elseif m == "-llamar" then
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
