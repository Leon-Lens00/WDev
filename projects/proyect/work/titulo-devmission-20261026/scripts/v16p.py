#!/usr/bin/env python3
"""v16p (08/11/2026): en la escena del cuchillo el foco seguía fijo en el centro de la pantalla (960, 300), donde lo
deja el icono central, mientras el Tauren caminaba hacia el enemigo (vídeo de Leon de v16o). Desde la fase 126 el
foco sigue al Tauren: cada tick se acerca un 25 % a su punto de pantalla (pecho, Tut_Z + 60) y se abre a radio 125
para abarcar el cono del cuchillo. Se suelta en la fase 133 y en Tut_Soltar.
Uso: v16p.py ENTRADA.j SALIDA.j (el j de v16o o v16o-prueba)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = once(s, 'integer Tut_CenEt= 0\n', 'integer Tut_CenEt= 0\nboolean Tut_FocoHeroe= false\n')
s = once(s, '''function Tut_Soltar takes nothing returns nothing
    local integer i= Tut_P * 7
    local integer k= 0
    local integer c= 0
''', '''function Tut_Soltar takes nothing returns nothing
    local integer i= Tut_P * 7
    local integer k= 0
    local integer c= 0
    set Tut_FocoHeroe = false
''')
s = once(s, '''        call ShowUnit(Tut_Mano, false)
        call Tut_CentroVolver()
        call Tut_Decir("No gasta balas,''', '''        call ShowUnit(Tut_Mano, false)
        call Tut_CentroVolver()
        // v16p: el foco deja el centro y sigue al Tauren mientras usa el cuchillo.
        set Tut_FocoHeroe = true
        set Tut_Dur[1] = 0.
        call Tut_Mover(2, 125., 1., 0.7)
        call Tut_Decir("No gasta balas,''')
s = once(s, '''        call Tut_Nota("fase 133 " + R2S(Tut_T))
        call ShowUnit(Tut_Foco, false)
''', '''        call Tut_Nota("fase 133 " + R2S(Tut_T))
        set Tut_FocoHeroe = false
        call ShowUnit(Tut_Foco, false)
''')
s = once(s, '''    set r = RMaxBJ(1., Tut_PX[2])
    call Tut_Escala(Tut_Foco,''', '''    if Tut_FocoHeroe then
        call Tut_Pantalla(GetUnitX(Tut_Tauren), GetUnitY(Tut_Tauren), Tut_Z + 60.)
        set Tut_PX[1] = Tut_PX[1] + ( Tut_PuntoX - Tut_PX[1] ) * 0.25
        set Tut_PY[1] = Tut_PY[1] + ( Tut_PuntoY - Tut_PY[1] ) * 0.25
    endif
    set r = RMaxBJ(1., Tut_PX[2])
    call Tut_Escala(Tut_Foco,''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16p ok')
