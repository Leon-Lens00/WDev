#!/usr/bin/env python3
"""v16d (08/11/2026): correcciones del tutorial tras el vídeo de Leon de v16c (panel y consola 3 × 4 ya se ven).
- El Tauren seguía volviéndose a la izquierda a los ~6 s de llegar (la IA de las unidades neutrales; quitarle el punto
  de guardia no bastó). Ahora camina por guion: posición con SetUnitX/Y y animación walk/stand, y SetUnitPropWindow 0
  para que ninguna orden lo mueva.
- No sonaba nada: un sonido creado y lanzado en el mismo momento no llega a cargarse. Las voces del Tauren y los
  clics se registran (precargan en silencio) al empezar, con Racha_Registrar, y Racha_Sonar los reutiliza.
Uso: v16d.py ENTRADA.j SALIDA.j (el j de v16c)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = once(s, 'boolean Tut_SinA= false\n', '''boolean Tut_SinA= false
boolean Tut_Anda= false
real Tut_AX0= 0.
real Tut_AY0= 0.
real Tut_AX1= 0.
real Tut_AY1= 0.
real Tut_AT0= 0.
real Tut_ADur= 0.
''')
s = once(s, '// v16c: casilla i (fila i / 4', '''// v16d: el Tauren camina por guion a 300 por segundo hasta (x, y).
function Tut_Caminar takes real x,real y returns nothing
    set Tut_AX0 = GetUnitX(Tut_Tauren)
    set Tut_AY0 = GetUnitY(Tut_Tauren)
    set Tut_AX1 = x
    set Tut_AY1 = y
    set Tut_AT0 = Tut_T
    set Tut_ADur = RMaxBJ(0.05, SquareRoot(( x - Tut_AX0 ) * ( x - Tut_AX0 ) + ( y - Tut_AY0 ) * ( y - Tut_AY0 )) / 300.)
    call SetUnitFacing(Tut_Tauren, Atan2(y - Tut_AY0, x - Tut_AX0) * bj_RADTODEG)
    call SetUnitAnimation(Tut_Tauren, "walk")
    set Tut_Anda = true
endfunction

function Tut_Andar takes nothing returns nothing
    local real u
    if not Tut_Anda then
        return
    endif
    set u = RMinBJ(1., ( Tut_T - Tut_AT0 ) / Tut_ADur)
    call SetUnitX(Tut_Tauren, Tut_AX0 + ( Tut_AX1 - Tut_AX0 ) * u)
    call SetUnitY(Tut_Tauren, Tut_AY0 + ( Tut_AY1 - Tut_AY0 ) * u)
    if u >= 1. then
        set Tut_Anda = false
        call SetUnitAnimation(Tut_Tauren, "stand")
    endif
endfunction

// v16c: casilla i (fila i / 4''')
n = s.count('call IssuePointOrder(Tut_Tauren, "move", ')
assert n == 3, n
s = s.replace('call IssuePointOrder(Tut_Tauren, "move", ', 'call Tut_Caminar(')
s = once(s, '''    call Tut_Rejilla()
    call Tut_Guion()''', '''    call Tut_Andar()
    call Tut_Rejilla()
    call Tut_Guion()''')
# Disparar mientras camina: la animación vuelve a walk, no a stand.
s = once(s, '''    call SetUnitAnimation(Tut_Tauren, "attack")
    call QueueUnitAnimation(Tut_Tauren, "stand")''', '''    call SetUnitAnimation(Tut_Tauren, "attack")
    if Tut_Anda then
        call QueueUnitAnimation(Tut_Tauren, "walk")
    else
        call QueueUnitAnimation(Tut_Tauren, "stand")
    endif''')
s = once(s, '''    call RemoveGuardPosition(Tut_Tauren)
''', '''    call RemoveGuardPosition(Tut_Tauren)
    // v16d: ninguna orden lo mueve; camina sólo por guion (Tut_Caminar).
    call SetUnitPropWindow(Tut_Tauren, 0.)
    call IssueImmediateOrder(Tut_Tauren, "stop")
    // v16d: precarga en silencio de los sonidos del tutorial (si no, el primero no suena).
    call Racha_Registrar("Units\\\\Orc\\\\Tauren\\\\TaurenWhat1.wav")
    call Racha_Registrar("Units\\\\Orc\\\\Tauren\\\\TaurenReady1.wav")
    call Racha_Registrar("Units\\\\Orc\\\\Tauren\\\\TaurenYes3.wav")
    call Racha_Registrar("Sound\\\\Interface\\\\MouseClick1.wav")
    call Racha_Registrar("Sound\\\\Interface\\\\BigButtonClick.wav")
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16d ok')
