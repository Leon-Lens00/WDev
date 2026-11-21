#!/usr/bin/env python3
"""v17t (14/11/2026): v17s con el ancla de la ventana de cuadros fijada en su sitio y diagnóstico de la escena.

Leon probó v17s-prueba: "se muestra negro de momento" (vídeo del 14/11 22:50: al pulsar Esc la pantalla queda negra
del todo, sin cuadros ni textos; el registro sólo tiene el sorteo). Sin piezas ni texttags a la vista, la cámara no
mira a (4800, 8700). Sospecha sin confirmar: el ancla 'dumi' que crea CreateUnit no queda en su punto.
- Menu_Ancla[2] se coloca con SetUnitX/SetUnitY tras crearla (no pasa por la búsqueda de sitio libre).
- Prueba: 0,5 s después de abrir la ventana se anota en lat\\v17s-cuadros.txt dónde está el ancla, a dónde mira la
  cámara de ese cliente, si (4800, 8700) está enmascarado o en niebla para él y si ve un fondo de cuadro, con su
  posición, su altura de vuelo y la altura del terreno. Lo mismo al abrir la tienda, para comparar con la escena que
  sí se ve.
Uso: v17t.py v17s/war3map.j SALIDA.j [prueba]
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
u8 = lambda s: s.encode('utf-8').decode('latin-1')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(u8(antes)), crlf(u8(despues))
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


una('''    set Menu_Ancla[2] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'dumi', 4800., 8700., 0.)
''', '''    set Menu_Ancla[2] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'dumi', 4800., 8700., 0.)
    call SetUnitX(Menu_Ancla[2], 4800.)
    call SetUnitY(Menu_Ancla[2], 8700.)
''')

if prueba:
    una('''integer Cua_LN = 0
''', '''integer Cua_LN = 0
integer Cua_DiagP = 0
timer Cua_DiagT = null
''')
    diag = '''// v17t-prueba: qué ve el cliente 0,5 s después de abrir la ventana o la tienda (valores locales, sólo al registro).
function Cua_B takes boolean b returns string
    if b then
        return "1"
    endif
    return "0"
endfunction

function Cua_DiagFin takes nothing returns nothing
    local integer p = Cua_DiagP
    local integer s = 0
    local unit a = Menu_Ancla[1]
    local real cx = 2400.
    local unit u = Shop_Pz[0]
    local string t
    if Cua_Open[p] then
        set a = Menu_Ancla[2]
        set cx = 4800.
        set u = null
        loop
            exitwhen s > 8 or u != null
            if Cua_SlotUsa[s] then
                set u = Cua_Bg[s]
            endif
            set s = s + 1
        endloop
    endif
    set t = "diag j" + I2S(p) + " cuadros=" + Cua_B(Cua_Open[p]) + " tienda=" + Cua_B(Shop_Open[p]) + " ancla=" + Cua_B(a != null) + " " + R2S(GetUnitX(a)) + "," + R2S(GetUnitY(a))
    if GetLocalPlayer() == Player(p) then
        set t = t + " camara=" + R2S(GetCameraTargetPositionX()) + "," + R2S(GetCameraTargetPositionY()) + "," + R2S(GetCameraTargetPositionZ()) + " ojo=" + R2S(GetCameraEyePositionX()) + "," + R2S(GetCameraEyePositionY()) + "," + R2S(GetCameraEyePositionZ())
    endif
    set t = t + " mascara=" + Cua_B(IsMaskedToPlayer(cx, 8700., Player(p))) + " niebla=" + Cua_B(IsFoggedToPlayer(cx, 8700., Player(p))) + " pieza=" + Cua_B(u != null)
    if u != null then
        set t = t + " visible=" + Cua_B(IsUnitVisible(u, Player(p))) + " oculta=" + Cua_B(IsUnitHidden(u)) + " en " + R2S(GetUnitX(u)) + "," + R2S(GetUnitY(u)) + " vuelo=" + R2S(GetUnitFlyHeight(u)) + " suelo=" + R2S(UserInterface_GetTerrainZ(GetUnitX(u), GetUnitY(u)))
    endif
    if GetLocalPlayer() == Player(p) then
        set t = t + " cab=" + Cua_B(Cua_TCab != null) + " tags=" + I2S(Shop_TzN)
    endif
    call Cua_Anotar(t)
    set a = null
    set u = null
endfunction

function Cua_Diag takes integer p returns nothing
    if Cua_DiagT == null then
        set Cua_DiagT = CreateTimer()
    endif
    set Cua_DiagP = p
    call TimerStart(Cua_DiagT, 0.5, false, function Cua_DiagFin)
endfunction

'''
    una('''// Clic en el botón de la posición s (0-8).''', diag + '''// Clic en el botón de la posición s (0-8).''')
    una('''        call Cua_Mostrar(p, true)
        return
    endif
    call Shop_Camara(p)
    if GetLocalPlayer() == Player(p) then
        call Shop_Textos()
    endif
    call Shop_Mostrar(p, true)
    if GetLocalPlayer() == Player(p) then
        call ClearSelection()
    endif
    call Shop_Refrescar(p)
''', '''        call Cua_Mostrar(p, true)
        call Cua_Diag(p)
        return
    endif
    call Shop_Camara(p)
    if GetLocalPlayer() == Player(p) then
        call Shop_Textos()
    endif
    call Shop_Mostrar(p, true)
    if GetLocalPlayer() == Player(p) then
        call ClearSelection()
    endif
    call Shop_Refrescar(p)
    call Cua_Diag(p)
''')
    una('''    call Shop_Mostrar(p, true)
    call Shop_Refrescar(p)
endfunction
''', '''    call Shop_Mostrar(p, true)
    call Shop_Refrescar(p)
    call Cua_Diag(p)
endfunction
''')
    una('call PreloadGenEnd("lat\\\\v17s-cuadros.txt")', 'call PreloadGenEnd("lat\\\\v17t-cuadros.txt")')

Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17t: ancla fijada' + (' + diagnóstico' if prueba else ''))
