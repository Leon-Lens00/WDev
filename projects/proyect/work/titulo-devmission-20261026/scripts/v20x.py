#!/usr/bin/env python3
"""v20x (21/11/2026): recarga por inactividad (plan docs/planes/devmission-armas-libro-economia-v20w.md).
Leon: recargar también sin vaciar el cargador si no se dispara durante un rato; se cancela si el jugador vuelve a
disparar.
- Tras 1,5 s sin disparar (ni cambiar de arma), con el cargador sin llenar y reserva, empieza la recarga normal.
- Esa recarga (Arm_Ocio) se corta al disparar si queda munición en el cargador; la del cargador vacío no se corta.
Uso: v20x.py ENTRADA.j SALIDA.j [prueba]   (normal de v20w; prueba de v20w-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('integer array HerS_Desde\n', '''integer array HerS_Desde
// v20x: último disparo o cambio de arma; la recarga en curso es por inactividad (se corta al disparar).
real array Arm_UltTiro
boolean array Arm_Ocio
real Arm_OCIO_ESPERA= 1.5
''')
# último disparo y cambio de arma
cambia('        set Arm_Listo[p * 7 + c]=(TimerGetElapsed(s__RapidPair_clock)) + Arm_Int[w]\n',
       '        set Arm_Listo[p * 7 + c]=(TimerGetElapsed(s__RapidPair_clock)) + Arm_Int[w]\n'
       '        set Arm_UltTiro[p]=(TimerGetElapsed(s__RapidPair_clock))\n')
cambia('        set Arm_Cat[p]=c\n', '        set Arm_Cat[p]=c\n        set Arm_UltTiro[p]=(TimerGetElapsed(s__RapidPair_clock))\n')
# disparar corta la recarga por inactividad
cambia('''        if Arm_Fin[p] > 0. then
            return
        endif
''', '''        // v20x: volver a disparar corta la recarga por inactividad si queda munición en el cargador.
        if Arm_Fin[p] > 0. and Arm_Ocio[p] and Arm_Clip[p * 7 + Arm_Cat[p]] > 0 then
            set Arm_Fin[p]=0.
            set Arm_Ocio[p]=false
        endif
        if Arm_Fin[p] > 0. then
            return
        endif
''')
cambia('                set Arm_Fin[p]=0.\n', '                set Arm_Fin[p]=0.\n                set Arm_Ocio[p]=false\n')
cambia('''                call s__RapidPair_finish(Game_Pair[p],true)
                set Arm_Fin[p]=time + Arm_Rec[Arm_W(p)] * ( 1. - Arm_Agil[i] )
            endif
''', '''                call s__RapidPair_finish(Game_Pair[p],true)
                set Arm_Fin[p]=time + Arm_Rec[Arm_W(p)] * ( 1. - Arm_Agil[i] )
                set Arm_Ocio[p]=false
            // v20x: sin disparar 1,5 s, con el cargador sin llenar y reserva: recarga que se corta al disparar.
            elseif Arm_Fin[p] <= 0. and Game_Pair[p] != 0 and Arm_Cat[p] != 5 and Arm_Tier[i] > 0 and Arm_Clip[i] < Arm_Mag[Arm_W(p)] and Arm_Rva[i] > 0 and not s__RapidPair_firing[Game_Pair[p]] and time >= Arm_UltTiro[p] + Arm_OCIO_ESPERA then
                set Arm_Fin[p]=time + Arm_Rec[Arm_W(p)] * ( 1. - Arm_Agil[i] )
                set Arm_Ocio[p]=true
            endif
''')

if prueba:
    for viejo, nuevo in (('lat\\\\v20w-', 'lat\\\\v20x-'), ('v20w-don.txt', 'v20x-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20x', 'prueba' if prueba else 'normal')
