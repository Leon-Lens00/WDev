#!/usr/bin/env python3
"""v20y (21/11/2026): botones de compra de pulls ajustados y héroe fijo por color.
Leon (captura de v20w): los textos de los botones de compra salían corridos a la izquierda y por debajo de su botón.
- El texto se centra con su largo visible (sin los códigos de color) y sube al centro del botón; botón y trackable
  bajan 10 px (y 795) para separarse del borde de los cuadros.
Leon: sin selección de héroe por ahora; rojo Tauren, azul Cairne, morado Goku y así hasta Naruto; los que faltan de
8, Cairne y Tauren, para no repetir los de D.O.N.
- Tabla por jugador: 0 rojo Tauren, 1 azul Cairne, 2 verde azulado Tauren, 3 morado Goku, 4 amarillo Freezer,
  5 naranja Trunks, 6 verde Naruto, 7 rosa Cairne (Hero_Choice 0 Tauren, 1 Cairne, 2 Goku, 3-5 D.O.N).
Uso: v20y.py ENTRADA.j SALIDA.j [prueba]   (normal de v20x; prueba de v20x-prueba). La LAN usa el mapa normal.
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


# --- 1) botones de compra
cambia('''function HerC_Texto takes integer r returns string
''', '''// v20y: el mismo texto sin colores, para medir su ancho y centrarlo.
function HerC_Plano takes integer r returns string
    if r == 0 then
        return "Pull bajo - " + I2S(HerC_Precio(r))
    elseif r == 1 then
        return "Pull medio - " + I2S(HerC_Precio(r))
    endif
    return "Pull alto - " + I2S(HerC_Precio(r))
endfunction

function HerC_Texto takes integer r returns string
''')
for r, nom, col in ((0, 'bajo', 'd8d8d8'), (1, 'medio', '5aa0ff'), (2, 'alto', 'c070ff')):
    cambia('"|cff%sPull %s|r · |cffffcc00" + I2S(HerC_Precio(r)) + "|r"' % (col, nom),
           '"|cff%sPull %s|r - |cffffcc00" + I2S(HerC_Precio(r)) + "|r"' % (col, nom))
cambia('''                call Cua_Centro(p, Cua_TCompra[c], HerC_Texto(c), Cua_PX(2 + 2 * c), 785, 0.02)
''', '''                // v20y: centrado con el largo visible y a la altura del botón (y 795; el texto va 21 más arriba).
                call SetTextTagText(Cua_TCompra[c], HerC_Texto(c), 0.02)
                call Cua_At(Cua_TCompra[c], Cua_PX(2 + 2 * c), 774, 0.02, StringLength(HerC_Plano(c)) * 0.02 * 470.)
''')
cambia("        set Cua_CompBt[s] = Cua_Pic(Cua_PX(2 + 2 * s), 785, 170, 50, 399, 'DS0A')\n",
       "        set Cua_CompBt[s] = Cua_Pic(Cua_PX(2 + 2 * s), 795, 170, 50, 399, 'DS0A')\n")
cambia('Cua_PX(2 + 2 * s), 785, 50 + s)', 'Cua_PX(2 + 2 * s), 795, 50 + s)')

# --- 2) héroe fijo por color
cambia('''    local location start= GetStartLocationLoc(GetPlayerStartLocation(Player(p)))
    if k == 1 then
        set id='h006'
''', '''    local location start= GetStartLocationLoc(GetPlayerStartLocation(Player(p)))
    // v20y: sin selección de héroe, fijo por color: rojo Tauren, azul Cairne, morado Goku, amarillo Freezer,
    // naranja Trunks, verde Naruto; verde azulado Tauren y rosa Cairne (no se repiten los de D.O.N).
    if GetPlayerController(Player(p)) == MAP_CONTROL_USER then
        set k = 0
        if p == 1 or p == 7 then
            set k = 1
        elseif p == 3 then
            set k = 2
        elseif p == 4 then
            set k = 3
        elseif p == 5 then
            set k = 4
        elseif p == 6 then
            set k = 5
        endif
        set Hero_Choice[p] = k
        set Hero_Locked[p] = true
    endif
    if k == 1 then
        set id='h006'
''')

if prueba:
    for viejo, nuevo in (('lat\\\\v20x-', 'lat\\\\v20y-'), ('v20x-don.txt', 'v20y-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20y', 'prueba' if prueba else 'normal')
