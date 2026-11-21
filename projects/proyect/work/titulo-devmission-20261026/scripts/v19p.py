#!/usr/bin/env python3
"""v19p (19/11/2026): la esfera del indicador entera, en forma de rectángulo alto con puntas redondeadas, cubre cada
carta y toma su color (Leon: "tomar ese mismo modelo, ajustarlo para que tenga una forma rectangular alta y cubra bien
los cuadros, y colorearlas segun los tonos tier, su forma seria con puntas redondeadas para no sacrificarlo mucho").
- Una burbuja 'ubjB' (burbuja_v19p.py, gris teñible) por carta en lugar de los contornos azul y carmesí de v19o. Profundidad
  428: delante del fondo de la carta (430) y detrás del recuadro del icono, la placa del nombre, la caja del texto, el
  icono y el botón, que siguen legibles.
- Color: el de la carta (los r, g, b de Cua_Ver): calidad (tier) en las cartas del héroe, azul/carmesí/verde de Armas,
  Mutación y Habilidades en la pantalla de inicio, carmesí del jefe en la Mutación Evo. Los cerrados no la llevan; con
  el destello de la elección, la de las otras cartas baja al 25 % como en v19o.
- Cartas cerradas (Leon: "una version opaca gris, que ira junto a los cuadros desactivados"): burbuja 'ubjG' gris opaca
  (burbuja_gris_v19p.py), sin tinte, sin pulso. Son los cuadros de inicio cerrados: Armas y Habilidades mientras la
  Mutación Evo es obligatoria, y cada cuadro ya hecho.
- Colores de calidad (Her_Tinte): 1 verde (100, 230, 40), 2 cian (30, 200, 225), 3 azul (50, 90, 235), 4 violeta
  (150, 60, 235), 5 oro (230, 205, 40); Purga (35, 150, 100), maldita (95, 25, 125), refresco (90, 110, 150) o
  (70, 70, 80) sin usos.
Uso: v19p.py ENTRADA.j SALIDA.j [prueba]   (normal de v19o; prueba de v19o-prueba)
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


cambia('unit array Cua_AroA\nunit array Cua_AroR\n', 'unit array Cua_AroA\nunit array Cua_AroG\n')
cambia('''function Cua_AroVer takes unit u, boolean on, integer al returns nothing
    if on and al > 0 then
        call SetUnitScale(u, Cua_AroK, Cua_AroK, Cua_AroK)
        call SetUnitVertexColor(u, 255, 255, 255, al)
''', '''// v19p: burbuja gris teñida con el color de la carta.
function Cua_AroVer takes unit u, boolean on, integer al, integer cr, integer cg, integer cb returns nothing
    if on and al > 0 then
        call SetUnitScale(u, Cua_AroK, Cua_AroK, Cua_AroK)
        call SetUnitVertexColor(u, cr, cg, cb, al)
''')
cambia("""            set Cua_AroA[s] = Cua_Aro(Cua_PX(s), 410, 426, 'ubjA')
            set Cua_AroR[s] = Cua_Aro(Cua_PX(s), 410, 426, 'ubjR')
""", """            // v19p: la burbuja de la carta (esfera del indicador en rectángulo), detrás de las piezas.
            set Cua_AroA[s] = Cua_Aro(Cua_PX(s), 410, 428, 'ubjB')
            set Cua_AroG[s] = Cua_Aro(Cua_PX(s), 410, 428, 'ubjG')
""")
cambia("set Cua_AroK = (0.544 / 718.18930543) * 426.", "set Cua_AroK = (0.544 / 718.18930543) * 428.")
cambia("""            call Cua_AroVer(Cua_AroA[s], aro == 1, fa)
            call Cua_AroVer(Cua_AroR[s], aro == 2, fa)
""", """            call Cua_AroVer(Cua_AroA[s], aro > 0, fa, r, g, b)
            // v19p: cuadro cerrado, burbuja gris opaca.
            call Cua_AroVer(Cua_AroG[s], a > 0 and inicio and ic != 255, a, 255, 255, 255)
""")
assert 'Cua_AroR' not in src and "'ubjA'" not in src and "'ubjR'" not in src

if prueba:
    for viejo, nuevo in (('lat\\\\v19o-', 'lat\\\\v19p-'), ('v19o-don.txt', 'v19p-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19p', 'prueba' if prueba else 'normal')
