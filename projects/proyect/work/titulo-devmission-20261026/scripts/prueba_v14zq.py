#!/usr/bin/env python3
"""Sólo prueba, v14zq: las de prueba_v14zo.py («-sumar N», «-matar N», «-caer», «-rachas»), con el registro en
lat\\v14zq-N.txt, más los ajustes de la tarjeta de rachas:
- «-ajuste dx dy s n l»: retrato corrido dx, dy px y escalado ×s; nombre y texto corridos n y l px hacia abajo
  (por defecto «-ajuste 0 0 1 0 0»). Vale para la tarjeta siguiente.
- «-alto Y»: centro de la tarjeta a Y px de arriba (por defecto 150).
- «-cara 0», «-cara 1», «-cara -1»: fuerza el retrato y la voz de Tauren, de Cairne, o vuelve al del personaje.
«-rachas» describe ahora las dos tarjetas (activa, sale, jugador, y, fin, habla, texto) y los ajustes.
Uso: prueba_v14zq.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

sal = sys.argv[2]
subprocess.run([sys.executable, '-I', str(Path(__file__).resolve().parent / 'prueba_v14zo.py')] + sys.argv[1:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
n = s.count('lat\\\\v14zo-')
assert n == 4, n
s = s.replace('lat\\\\v14zo-', 'lat\\\\v14zq-')
s = base.once(s, 'real Racha_AjL= 0.\n', 'real Racha_AjL= 0.\ninteger Prueba_Cara= -1\n')
s = base.once(s, '''function Racha_EsCairne takes integer p returns boolean
    return GetUnitTypeId(Game_Hero[p]) == 'h006'
''', '''function Racha_EsCairne takes integer p returns boolean
    if Prueba_Cara >= 0 then
        return Prueba_Cara == 1
    endif
    return GetUnitTypeId(Game_Hero[p]) == 'h006'
''')
s = base.once(s, '''" filas [" + Racha_Fila[0] + "][" + Racha_Fila[1] + "][" + Racha_Fila[2] + "]"''',
              '''" tarjetas" + Prueba_Tarjeta(0) + Prueba_Tarjeta(1) + " ajuste " + R2S(Racha_AjX) + " " + R2S(Racha_AjY) + " " + R2S(Racha_AjS) + " " + R2S(Racha_AjN) + " " + R2S(Racha_AjL) + " alto " + R2S(Racha_Y) + " cara " + I2S(Prueba_Cara)''')
s = base.once(s, 'function Prueba_RachaLog takes nothing returns nothing\n', '''function Prueba_Tarjeta takes integer k returns string
    return " [" + I2S(k) + " activa " + I2S(IntegerTertiaryOp(Racha_CActiva[k], 1, 0)) + " sale " + I2S(IntegerTertiaryOp(Racha_CSale[k], 1, 0)) + " p" + I2S(Racha_CPid[k]) + " y " + R2S(Racha_CY[k]) + " fin " + R2S(Racha_CFin[k]) + " habla " + R2S(Racha_CHabla[k]) + " cairne " + I2S(IntegerTertiaryOp(Racha_CCairne[k], 1, 0)) + " " + Racha_CTexto[k] + "]"
endfunction
// La palabra n (0 la primera) de m, separada por espacios.
function Prueba_Campo takes string m,integer n returns string
    local integer i= 0
    local integer a= 0
    local integer l= StringLength(m)
    loop
        exitwhen i > l
        if i == l or SubString(m, i, i + 1) == " " then
            if n == 0 then
                return SubString(m, a, i)
            endif
            set n = n - 1
            set a = i + 1
        endif
        set i = i + 1
    endloop
    return ""
endfunction
function Prueba_RachaLog takes nothing returns nothing
''')
s = base.once(s, '''    elseif m == "-llamar" then
''', '''    elseif SubString(m, 0, 8) == "-ajuste " then
        set Racha_AjX = S2R(Prueba_Campo(m, 1))
        set Racha_AjY = S2R(Prueba_Campo(m, 2))
        set Racha_AjS = S2R(Prueba_Campo(m, 3))
        set Racha_AjN = S2R(Prueba_Campo(m, 4))
        set Racha_AjL = S2R(Prueba_Campo(m, 5))
        if Racha_AjS <= 0. then
            set Racha_AjS = 1.
        endif
        call Prueba_Log("ajuste " + R2S(Racha_AjX) + " " + R2S(Racha_AjY) + " " + R2S(Racha_AjS) + " " + R2S(Racha_AjN) + " " + R2S(Racha_AjL))
    elseif SubString(m, 0, 6) == "-alto " then
        set Racha_Y = S2R(SubString(m, 6, StringLength(m)))
    elseif SubString(m, 0, 6) == "-cara " then
        set Prueba_Cara = S2I(SubString(m, 6, StringLength(m)))
    elseif m == "-llamar" then
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
