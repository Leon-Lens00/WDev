#!/usr/bin/env python3
"""v17r (14/11/2026): las piezas de interfaz con Langosta no se quedan seleccionadas.

Leon con una captura (el icono de vida 'hbi0', "Health icon HealthIconTauren", seleccionado en partida): "parece lo que
no son tipo boton, su dummys permanecen con langosta, osea no seleccionable ... si son necesarios como seleccionables?";
"si, ya que muchos elementos se puede seleccionar, y en el sistema original me parece no pasaba".
Las piezas de vida tienen 'Aloc' en el w3u; lo probable es que al ocultarlas y mostrarlas (ShowUnit en HealthBars y
Hud_Ver) se puedan coger con el recuadro. Ninguna pieza con 'Aloc' necesita selección (los botones del inventario,
e000/e001, no la tienen y no cambian).
- Shop_Seleccion (EVENT_PLAYER_UNIT_SELECTED, ya registrado): si la unidad seleccionada tiene 'Aloc', en el cliente de
  quien la seleccionó se limpia la selección y se vuelve a seleccionar su personaje (Game_Ctrl), como ya se hacía con
  el golem de la tienda. Con la tienda abierta sólo se limpia, como antes.
- Variante de prueba (tercer argumento "prueba"): cada pieza seleccionada se anota (hasta 60) en
  CustomMapData\\lat\\v17r-seleccion.txt con el tiempo de partida, el jugador, el nombre, si estaba oculta y su posición.
Uso: v17r.py v17q/war3map.j SALIDA.j [prueba]   (v17q usa el j de v17p)
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(antes), crlf(despues)
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


registro = ''
globales = ''
if prueba:
    globales = '''integer Sel_N = 0
string array Sel_L
timer Sel_Reloj = null
'''
    registro = '''// v17r-prueba: anota cada pieza con Langosta seleccionada (CustomMapData\\\\lat\\\\v17r-seleccion.txt).
function Sel_Anotar takes unit u, integer p returns nothing
    local integer i = 0
    if Sel_Reloj == null then
        set Sel_Reloj = CreateTimer()
        call TimerStart(Sel_Reloj, 100000., false, null)
    endif
    if Sel_N >= 60 then
        return
    endif
    set Sel_L[Sel_N] = R2S(TimerGetElapsed(Sel_Reloj)) + " j" + I2S(p) + " " + GetUnitName(u) + " oculta=" + I2S(IntegerTertiaryOp(IsUnitHidden(u), 1, 0)) + " x=" + R2S(GetUnitX(u)) + " y=" + R2S(GetUnitY(u))
    set Sel_N = Sel_N + 1
    call PreloadGenClear()
    loop
        exitwhen i >= Sel_N
        call Preload(Sel_L[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("lat\\\\v17r-seleccion.txt")
endfunction

'''
    if 'function IntegerTertiaryOp' not in j:
        registro = registro.replace('I2S(IntegerTertiaryOp(IsUnitHidden(u), 1, 0))', 'Sel_Oculta(u)')
        registro = '''function Sel_Oculta takes unit u returns string
    if IsUnitHidden(u) then
        return "1"
    endif
    return "0"
endfunction

''' + registro

una('unit array Game_Ctrl\n', 'unit array Game_Ctrl\n' + globales)
una('''function Shop_Seleccion takes nothing returns nothing
    local integer p = GetPlayerId(GetTriggerPlayer())
    if GetTriggerUnit() == Shop_Golem then
        if GetLocalPlayer() == Player(p) then
            call ClearSelection()
            call SelectUnit(Game_Ctrl[p], true)
        endif
    elseif Shop_Open[p] and GetLocalPlayer() == Player(p) then
''', registro + '''function Shop_Seleccion takes nothing returns nothing
    local integer p = GetPlayerId(GetTriggerPlayer())
    if GetTriggerUnit() == Shop_Golem then
        if GetLocalPlayer() == Player(p) then
            call ClearSelection()
            call SelectUnit(Game_Ctrl[p], true)
        endif
    // v17r: una pieza de interfaz con Langosta no se queda seleccionada (sólo cambia la selección de ese cliente).
    elseif GetUnitAbilityLevel(GetTriggerUnit(), 'Aloc') > 0 then
''' + ('''        call Sel_Anotar(GetTriggerUnit(), p)
''' if prueba else '') + '''        if GetLocalPlayer() == Player(p) then
            call ClearSelection()
            if not Shop_Open[p] and Game_Ctrl[p] != null then
                call SelectUnit(Game_Ctrl[p], true)
            endif
        endif
    elseif Shop_Open[p] and GetLocalPlayer() == Player(p) then
''')
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17r: selección de piezas con Langosta' + (' + registro' if prueba else ''))
