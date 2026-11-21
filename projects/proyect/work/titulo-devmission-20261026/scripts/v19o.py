#!/usr/bin/env python3
"""v19o (19/11/2026): cartas con las ventanas de la tienda y el contorno de los indicadores (Leon: "con las ventanas
nativas que tenemos, ese mismo formato de ventanas y cuadros que tiene la tienda de armas, el color le daremos con ese
efecto azul que encierra el indicador de tienda o rojo carmesi que encierra el indicador del boss").
- Carta: ventana 'DS1S' (CuaCarta, marco de la tienda sin estirar) sin teñir, en vez de 'DS01' teñida. Encima, como en
  la tienda: recuadro del icono 'DS03' (ShopWindow), placa del nombre 'DS06' (ShopCatOff) y caja del texto 'DS04'
  (ShopCell). El icono baja de py 275 a 285, el nombre sube de 392 a 386 y el texto baja 14 px y entra 12, para que quepan.
- Color: contorno animado alrededor de la carta, 'ubjA' azul (esfera de la tienda) para el héroe y los cuadros de Armas
  y Habilidades, 'ubjR' carmesí (esfera del jefe) para la Mutación Evo. Los cerrados no tienen contorno. Con el destello
  de la elección, el de las otras cartas baja al 25 %. Se muestra en el cliente del jugador con la escala (visual).
- Fuera el marco plano 'DS1Q' y la banda del tipo 'DS1P' de v19m (las texturas siguen en el mapa, sin uso).
Uso: v19o.py ENTRADA.j SALIDA.j [prueba]   (normal de v19n; prueba de v19n-prueba)
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


def antes(marca, nuevo):
    cambia(marca, nuevo + marca)


# --- globales ---
cambia('unit array Cua_Banda\n', '''unit array Cua_Banda
unit array Cua_Cel
unit array Cua_Placa
unit array Cua_Caja
unit array Cua_AroA
unit array Cua_AroR
real Cua_AroK = 0.
''')

# --- contorno: creación y visibilidad ---
antes('function Cua_Construir takes nothing returns nothing\n', '''// v19o: contorno animado de la carta (aro_v19o.py: 1 unidad = 1 px a la profundidad d). Nace con escala 0; Cua_AroVer
// lo muestra sólo en el cliente que mira las cartas.
function Cua_Aro takes real px, real py, real d, integer raw returns unit
    local real x = Title_WX(Shop_PY(py), d)
    local real y = Title_WY(px, d)
    local unit u = CreateUnit(CAMERA_DUMMY_PLAYER, raw, x, y, 270.)
    call UnitAddAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitAddAbility(u, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
    call SetUnitInvulnerable(u, true)
    call SetUnitX(u, x)
    call SetUnitY(u, y)
    call SetUnitFlyHeight(u, Shop_OJO - d - UserInterface_GetTerrainZ(x, y), 0)
    call SetUnitScale(u, 0., 0., 0.)
    call SetUnitVertexColor(u, 255, 255, 255, 0)
    set bj_lastCreatedUnit = u
    set u = null
    return bj_lastCreatedUnit
endfunction

''')
antes('function Cua_Ver takes integer p returns nothing\n', '''// v19o: sólo visual, en el cliente local (Cua_Ver ya filtra por GetLocalPlayer).
function Cua_AroVer takes unit u, boolean on, integer al returns nothing
    if on and al > 0 then
        call SetUnitScale(u, Cua_AroK, Cua_AroK, Cua_AroK)
        call SetUnitVertexColor(u, 255, 255, 255, al)
    else
        call SetUnitScale(u, 0., 0., 0.)
        call SetUnitVertexColor(u, 255, 255, 255, 0)
    endif
endfunction

''')

# --- Cua_Construir ---
cambia("""            set Cua_Bg[s] = Cua_Pic(Cua_PX(s), 410, 330, 480, 430, 'DS01')""",
       """            set Cua_Bg[s] = Cua_Pic(Cua_PX(s), 410, 330, 480, 430, 'DS1S')""")
cambia("""            // v19m: marco de la pantalla y banda del tipo de carta (texturas claras, se tiñen en Cua_Ver).
            set Cua_Marco[s] = Cua_Pic(Cua_PX(s), 410, 330, 480, 428, 'DS1Q')
            set Cua_Banda[s] = Cua_Pic(Cua_PX(s), 168, 300, 22, 415, 'DS1P')
""", """            // v19o: recuadro del icono, placa del nombre y caja del texto, como en la tienda; contorno azul y carmesí.
            set Cua_Cel[s] = Cua_Pic(Cua_PX(s), 285, 206, 206, 404, 'DS03')
            set Cua_Placa[s] = Cua_Pic(Cua_PX(s), 405, 300, 36, 412, 'DS06')
            set Cua_Caja[s] = Cua_Pic(Cua_PX(s), 492, 300, 116, 414, 'DS04')
            set Cua_AroA[s] = Cua_Aro(Cua_PX(s), 410, 426, 'ubjA')
            set Cua_AroR[s] = Cua_Aro(Cua_PX(s), 410, 426, 'ubjR')
""")
cambia("""    set Title_CX = 4800.
    set Menu_Ancla[2] = CreateUnit(""", """    set Title_CX = 4800.
    set Cua_AroK = (0.544 / 718.18930543) * 426.
    set Menu_Ancla[2] = CreateUnit(""")
cambia("""                    set Cua_Ico[p * 9 + s] = Cua_Pic(Cua_PX(s), 275, 190, 190, 405, 'DC00')""",
       """                    set Cua_Ico[p * 9 + s] = Cua_Pic(Cua_PX(s), 285, 190, 190, 405, 'DC00')""")
cambia("""            set Cua_Ico[s] = Cua_Pic(Cua_PX(Cua_Slot(n, c)), 275, 190, 190, 405, tex)""",
       """            set Cua_Ico[s] = Cua_Pic(Cua_PX(Cua_Slot(n, c)), 285, 190, 190, 405, tex)""")

# --- Cua_Ver ---
cambia("""    local integer fb = 60
    if Cua_Modo[p] == 2 then
        set sinBoton = 0""", """    local integer fb = 60
    local integer aro = 0
    local integer cv = 255
    if Cua_Modo[p] == 2 then
        set sinBoton = 0""")
cambia("""            call SetUnitVertexColor(Cua_Bg[s], r, g, b, a)
            call SetUnitVertexColor(Cua_Bt[s], ic, ic, ic, a * sinBoton)""",
       """            call SetUnitVertexColor(Cua_Bg[s], ic, ic, ic, a)
            call SetUnitVertexColor(Cua_Bt[s], ic, ic, ic, a * sinBoton)""")
cambia("""                        call SetUnitVertexColor(Cua_Bg[s], r * 35 / 100, g * 35 / 100, b * 35 / 100, a)""",
       """                        call SetUnitVertexColor(Cua_Bg[s], 90, 90, 90, a)""")
cambia("""            call SetUnitVertexColor(Cua_Marco[s], fr, fg, fb, fa)
            call SetUnitVertexColor(Cua_Banda[s], Her_R, Her_G, Her_B, ba)
""", """            // v19o: piezas de la tienda y contorno: azul para el héroe, Armas y Habilidades; carmesí para el jefe.
            set cv = ic
            set aro = 0
            if a > 0 then
                if inicio then
                    if ic == 255 then
                        set aro = 1
                        if k == 1 then
                            set aro = 2
                        endif
                    endif
                elseif Cua_Modo[p] == 1 and Cua_Paso[p] >= 3 then
                    set aro = 1
                else
                    set aro = 2
                endif
                if not inicio and Cua_Fla[p] > 0 and k != Cua_Fla[p] - 1 then
                    set cv = 90
                endif
            endif
            call SetUnitVertexColor(Cua_Cel[s], cv, cv, cv, a)
            call SetUnitVertexColor(Cua_Placa[s], cv, cv, cv, a)
            call SetUnitVertexColor(Cua_Caja[s], cv, cv, cv, a)
            set fa = a
            if cv == 90 then
                set fa = a * 25 / 100
            endif
            call Cua_AroVer(Cua_AroA[s], aro == 1, fa)
            call Cua_AroVer(Cua_AroR[s], aro == 2, fa)
""")
# Textos: nombre 6 px más arriba; descripción 14 px más abajo y 12 a la derecha, dentro de la caja.
cambia("""Her_Nombre(p, c), Cua_PX(s), 392, 0.025)""", """Her_Nombre(p, c), Cua_PX(s), 386, 0.025)""")
cambia("""Cua_Nom[Cua_Item(p, c)], Cua_PX(s), 392, 0.025)""", """Cua_Nom[Cua_Item(p, c)], Cua_PX(s), 386, 0.025)""")
cambia("""Her_Des(p, c), Cua_PX(s) - 150, 457, 0.021)""", """Her_Des(p, c), Cua_PX(s) - 138, 471, 0.021)""")
cambia("""Cua_InicioDes(p, c), Cua_PX(s) - 150, 440, 0.021)""", """Cua_InicioDes(p, c), Cua_PX(s) - 138, 454, 0.021)""")
cambia("""Cua_VotosTxt(p, c), Cua_PX(s) - 150, 440, 0.021)""", """Cua_VotosTxt(p, c), Cua_PX(s) - 138, 454, 0.021)""")

if prueba:
    for viejo, nuevo in (('lat\\\\v19n-', 'lat\\\\v19o-'), ('v19n-don.txt', 'v19o-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19o', 'prueba' if prueba else 'normal')
