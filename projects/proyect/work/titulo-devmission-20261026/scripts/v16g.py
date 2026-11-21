#!/usr/bin/env python3
"""v16g (08/11/2026): corrección de la oleada del tutorial tras la prueba de v16f (lat/v16f-1.txt).
En v16f los 5 primeros enemigos y el jefe acabaron rematados (96 tiros sin una baja); los 3 refuerzos, que van a
X+430, cayeron a tiros. Cambios:
- Destinos más cerca del Tauren: los 5 a X+420..480 (antes 560..640) y el jefe se para en X+500 (antes 650).
- El plazo para rematar es de 5 s y no corre mientras recarga (en v16f la recarga de 2,2 s se comía el plazo).
- Los enemigos neutrales se volvían solos tras llegar: cada uno guarda su destino, vuelve si se aleja y al llegar
  queda en holdposition. nmcf y nj02 sin huir (objetos_v16g.py).
- Notas para la prueba: al apuntar y al rematar, posición, vida y orden del objetivo.
Uso: v16g.py ENTRADA.j SALIDA.j (el j de v16f)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
assert '\r\n' in s

for y, x0, x1 in (('Tut_Y - 240.)', 560, 420), ('Tut_Y - 120.)', 640, 480), ('Tut_Y)', 560, 420),
                  ('Tut_Y + 120.)', 640, 480), ('Tut_Y + 240.)', 560, 420)):
    s = once(s, f'call IssuePointOrder(Tut_Nuevo, "move", Tut_X + {x0}., {y}\n',
             f'call IssuePointOrder(Tut_Nuevo, "move", Tut_X + {x1}., {y}\n')
s = once(s, 'call IssuePointOrder(Tut_Jefe, "move", Tut_X + 650., Tut_Y)', 'call IssuePointOrder(Tut_Jefe, "move", Tut_X + 500., Tut_Y)')

s = once(s, '''    if obj != Tut_Obj then
        set Tut_Obj = obj
        set Tut_ObjT = Tut_T
    elseif Tut_T > Tut_ObjT + 3.5 then
        call KillUnit(Tut_Enem[obj])
        call Tut_Nota("remate " + I2S(obj))
        return
    endif
''', '''    if obj != Tut_Obj then
        set Tut_Obj = obj
        set Tut_ObjT = Tut_T
        call Tut_Nota("apunta " + I2S(obj) + " xy " + I2S(R2I(GetUnitX(Tut_Enem[obj]))) + " " + I2S(R2I(GetUnitY(Tut_Enem[obj]))) + " vida " + R2S(GetWidgetLife(Tut_Enem[obj])) + " orden " + I2S(GetUnitCurrentOrder(Tut_Enem[obj])) + " t " + R2S(Tut_T))
    elseif Arm_Fin[Tut_P] > 0. then
        // v16g: el plazo no corre mientras recarga.
        set Tut_ObjT = Tut_ObjT + 0.02
    elseif Tut_T > Tut_ObjT + 5. then
        call Tut_Nota("remate " + I2S(obj) + " xy " + I2S(R2I(GetUnitX(Tut_Enem[obj]))) + " " + I2S(R2I(GetUnitY(Tut_Enem[obj]))) + " vida " + R2S(GetWidgetLife(Tut_Enem[obj])) + " orden " + I2S(GetUnitCurrentOrder(Tut_Enem[obj])) + " t " + R2S(Tut_T))
        call KillUnit(Tut_Enem[obj])
        return
    endif
''')
# Los enemigos neutrales se vuelven solos tras llegar (vídeo de v16f): cada uno guarda su destino; si se aleja se le
# manda de vuelta y al llegar se queda en "holdposition".
s = once(s, 'unit Tut_Nuevo= null\n', 'unit Tut_Nuevo= null\nreal array Tut_DX\nreal array Tut_DY\ninteger Tut_JefeK= -1\n')
s = once(s, """    set Tut_Enem[Tut_NEnem] = Tut_Nuevo
    set Tut_NEnem = Tut_NEnem + 1
""", """    set Tut_Enem[Tut_NEnem] = Tut_Nuevo
    set Tut_DX[Tut_NEnem] = x
    set Tut_DY[Tut_NEnem] = y
    set Tut_NEnem = Tut_NEnem + 1
""")
s = once(s, '// v16f: disparo real hacia una unidad.\n', """// v16g: destino del enemigo k; Tut_Sujetar lo mantiene allí.
function Tut_Destino takes integer k,real x,real y returns nothing
    set Tut_DX[k] = x
    set Tut_DY[k] = y
    call IssuePointOrder(Tut_Enem[k], "move", x, y)
endfunction

function Tut_Sujetar takes integer k returns nothing
    local unit u= Tut_Enem[k]
    local real dx= Tut_DX[k] - GetUnitX(u)
    local real dy= Tut_DY[k] - GetUnitY(u)
    if IsUnitPaused(u) then
        set u = null
        return
    endif
    if dx * dx + dy * dy > 60. * 60. then
        if GetUnitCurrentOrder(u) != OrderId("move") then
            call IssuePointOrder(u, "move", Tut_DX[k], Tut_DY[k])
        endif
    elseif GetUnitCurrentOrder(u) != OrderId("holdposition") then
        call IssueImmediateOrder(u, "holdposition")
    endif
    set u = null
endfunction

// v16f: disparo real hacia una unidad.
""")
n = s.count('call IssuePointOrder(Tut_Nuevo, "move", ')
assert n == 6, n
s = s.replace('call IssuePointOrder(Tut_Nuevo, "move", ', 'call Tut_Destino(Tut_NEnem - 1, ')
s = once(s, """    set Tut_Jefe = Tut_Nuevo
""", """    set Tut_Jefe = Tut_Nuevo
    set Tut_JefeK = Tut_NEnem - 1
""")
s = once(s, 'call IssuePointOrder(Tut_Jefe, "move", Tut_X + 500., Tut_Y)', 'call Tut_Destino(Tut_JefeK, Tut_X + 500., Tut_Y)')
s = once(s, """        if GetWidgetLife(Tut_Enem[k]) > 0.405 then
            set n = n + 1
""", """        if GetWidgetLife(Tut_Enem[k]) > 0.405 then
            set n = n + 1
            call Tut_Sujetar(k)
""")
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16g ok')
