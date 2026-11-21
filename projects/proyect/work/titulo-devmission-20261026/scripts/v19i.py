#!/usr/bin/env python3
"""v19i (19/11/2026), tras v19h-prueba (lat\\v19h-don.txt, 3000 líneas): de 858 restos quitados a los 15 s, 855
eran piezas YA MUERTAS (vida temporal agotada). 92 tipos de pieza de D.O.N se basan en 'hpea'/'hfoo' y 77 dejan
cadáver que se descompone (udea 3): el modelo del efecto sigue en el suelo hasta que se pudre (polvo de Rasen
Shuriken h0D3, Purge h05X, sol rojo h0H2, fuegos h0DL/h06G…). Sólo 3 vivas (h01M, explosión con regeneración -6).
- Barrido: una pieza muerta se quita en cuanto pasa su tiempo de muerte (udtm del w3u o 'death' de UnitData.slk de
  su base) + 0,5 s, es decir, al acabar su animación de muerte, que es lo que D.O.N quiere mostrar. Las vivas siguen
  con el límite de 15 s.
- Prueba: ya no anota cada cadáver (llenó el registro); cuenta los quitados y escribe el total cada 20 s si cambió.
  "pieza larga" sólo para piezas vivas. Registro en lat\\v19i-don.txt.
Uso: v19i.py ENTRADA.j SALIDA.j MUERTE.json [prueba]   (normal de v19h; prueba de v19h-prueba)
MUERTE.json: {tipo: [base, tiempo_de_muerte, udea]} de los 92 tipos (sacado del w3u de v19h y UnitData.slk).
"""
import json, sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
info = json.load(open(sys.argv[3]))
prueba = len(sys.argv) > 4 and sys.argv[4] == 'prueba'
U = lambda s: s.encode('utf-8').decode('latin-1')
assert len(info) == 92
crlf = '\r\n' in src
if crlf:
    src = src.replace('\r\n', '\n')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('integer Dres_T = 0\n', 'integer Dres_T = 0\ninteger Dres_Cad = 0\ninteger Dres_CadVisto = 0\n')
cambia('''        call RemoveSavedInteger(Dres_H, 0, GetHandleId(u))
''', '''        call RemoveSavedInteger(Dres_H, 0, GetHandleId(u))
        call RemoveSavedInteger(Dres_H, 2, GetHandleId(u))
''')
# función de barrido entera
i = src.index('function Dres_Tick takes nothing returns nothing\n')
j = src.index('endfunction\n', i) + len('endfunction\n')
if prueba:
    larga = '''                    if e == 16 and UnitAlive(u) then
                        call Dia_Anotar("pieza larga " + Dia_Id(GetUnitTypeId(u)) + " j" + I2S(p) + " 8 s en " + I2S(R2I(GetUnitX(u))) + " " + I2S(R2I(GetUnitY(u))) + " oculta " + Dia_B(IsUnitHidden(u)))
                    endif
'''
    resto = '''                        call Dia_Anotar("resto vivo " + Dia_Id(GetUnitTypeId(u)) + " j" + I2S(p) + " quitado a los " + I2S(e / 2) + " s en " + I2S(R2I(GetUnitX(u))) + " " + I2S(R2I(GetUnitY(u))) + " oculta " + Dia_B(IsUnitHidden(u)))
'''
    total = '''    if ModuloInteger(Dres_T, 40) == 0 and Dres_Cad != Dres_CadVisto then
        set Dres_CadVisto = Dres_Cad
        call Dia_Anotar("cadaveres de piezas quitados " + I2S(Dres_Cad))
    endif
'''
else:
    larga = resto = total = ''
src = src[:i] + '''function Dres_Tick takes nothing returns nothing
    local integer p = 0
    local integer e
    local integer h
    local unit u
    set Dres_T = Dres_T + 1
    call ForGroup(Dres_G, function Dres_Purga)
    loop
        exitwhen p > 5
        call GroupEnumUnitsOfPlayer(Dres_E, Player(p), null)
        loop
            set u = FirstOfGroup(Dres_E)
            exitwhen u == null
            call GroupRemoveUnit(Dres_E, u)
            if HaveSavedBoolean(Dres_H, 1, GetUnitTypeId(u)) then
                set h = GetHandleId(u)
                if not IsUnitInGroup(u, Dres_G) then
                    call GroupAddUnit(Dres_G, u)
                    call SaveInteger(Dres_H, 0, h, Dres_T)
                endif
                set e = Dres_T - LoadInteger(Dres_H, 0, h)
                if not UnitAlive(u) then
                    // v19i: muerta; fuera al acabar su animación de muerte, antes de que el cadáver se quede pudriendo.
                    if not HaveSavedInteger(Dres_H, 2, h) then
                        call SaveInteger(Dres_H, 2, h, Dres_T)
                    elseif I2R(Dres_T - LoadInteger(Dres_H, 2, h)) * 0.5 >= LoadReal(Dres_H, 3, GetUnitTypeId(u)) + 0.5 then
                        set Dres_Cad = Dres_Cad + 1
                        call RemoveUnit(u)
                    endif
                else
''' + larga + '''                    if e >= 30 then
''' + resto + '''                        call RemoveUnit(u)
                    endif
                endif
            endif
        endloop
        set p = p + 1
    endloop
''' + total + '''    set u = null
endfunction
''' + src[j:]
reales = ''.join("    call SaveReal(Dres_H, 3, '%s', %s)\n" % (k, repr(float(v[1]))) for k, v in sorted(info.items()))
cambia('''    call TimerStart(CreateTimer(), 0.5, true, function Dres_Tick)
''', reales + '''    call TimerStart(CreateTimer(), 0.5, true, function Dres_Tick)
''')
if prueba:
    for viejo, nuevo in (('lat\\\\v19h-', 'lat\\\\v19i-'), ('v19h-don.txt', 'v19i-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19i', 'prueba' if prueba else 'normal')
