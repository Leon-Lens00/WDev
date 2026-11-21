#!/usr/bin/env python3
"""v14zp (07/11/2026): la música de cada oleada (Ronda_Tema 1..10) a la mitad de su volumen de v14zo, y los sonidos
de rachas y voces con un sonido fijo por archivo, calentado al entrar (Racha_Registrar).
Uso: v14zp.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
antes = {1: 125, 2: 127, 3: 127, 4: 95, 5: 117, 6: 127, 7: 127, 8: 127, 9: 127, 10: 127}
for i, v in antes.items():
    s = base.once(s, 'call SetSoundVolume(Ronda_Tema[%d], %d)\n' % (i, v), 'call SetSoundVolume(Ronda_Tema[%d], %d)\n' % (i, (v + 1) // 2))
assert len(re.findall(r'SetSoundVolume\(Ronda_Tema\[', s)) == 10
# Sonidos de rachas y voces: uno fijo por archivo, creado al entrar el primer jugador y sonado una vez a volumen 0
# (calienta el archivo; un sonido creado y arrancado en el mismo instante puede no oírse la primera vez).
s = base.once(s, 'multiboard Racha_Tabla= null\n', 'multiboard Racha_Tabla= null\nstring array Racha_SonF\nsound array Racha_SonH\ninteger Racha_SonN= 0\n')
s = base.once(s, '''function Racha_Sonar takes string f returns nothing
    local sound x= CreateSound(f, false, false, false, 10, 10, "")
    call SetSoundVolume(x, 127)
    call StartSound(x)
    call KillSoundWhenDone(x)
    set x = null
endfunction
''', '''function Racha_Registrar takes string f returns nothing
    set Racha_SonF[Racha_SonN] = f
    set Racha_SonH[Racha_SonN] = CreateSound(f, false, false, false, 10, 10, "")
    call SetSoundVolume(Racha_SonH[Racha_SonN], 0)
    call StartSound(Racha_SonH[Racha_SonN])
    set Racha_SonN = Racha_SonN + 1
endfunction

function Racha_Sonar takes string f returns nothing
    local integer i= 0
    local sound x
    loop
        exitwhen i >= Racha_SonN
        if Racha_SonF[i] == f then
            call StopSound(Racha_SonH[i], false, false)
            call SetSoundVolume(Racha_SonH[i], 127)
            call StartSound(Racha_SonH[i])
            return
        endif
        set i = i + 1
    endloop
    set x = CreateSound(f, false, false, false, 10, 10, "")
    call SetSoundVolume(x, 127)
    call StartSound(x)
    call KillSoundWhenDone(x)
    set x = null
endfunction
''')
s = base.once(s, '''        set Racha_Reloj = CreateTimer()
        call TimerStart(Racha_Reloj, 0.05, true, function Racha_Paso)
''', '''        set i = 1
        loop
            exitwhen i > 14
            if i <= 8 or i >= 11 then
                call Racha_Registrar(Racha_Son[i])
            endif
            set i = i + 1
        endloop
        call Racha_Registrar("war3mapImported\\\\announcer_1stblood_01.wav")
        call Racha_Registrar("war3mapImported\\\\RDK_RompeRacha.mp3")
        set i = 0
        loop
            exitwhen i > 14
            if i <= 3 or i >= 10 then
                call Racha_Registrar(Racha_Voz[i])
            endif
            set i = i + 1
        endloop
        set i = 0
        set Racha_Reloj = CreateTimer()
        call TimerStart(Racha_Reloj, 0.05, true, function Racha_Paso)
''')
assert s.count('call Racha_Registrar(') == 4
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
