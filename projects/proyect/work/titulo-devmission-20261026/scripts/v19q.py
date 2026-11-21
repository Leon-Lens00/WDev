#!/usr/bin/env python3
"""v19q (19/11/2026): cartas más altas, cabecera con cuadro y burbuja, fondo de rayos y descanso de 60 s (Leon: "los
cuadros podrian ser mas grande o largos ya que tiene especio de sobre abajo, en la zona del titulo tambien apliquemos
el efecto de contorno junto a un cuadro, ajustemos el texto de la descripcion y de fondo apliquemos ese fondo de rayos
que sale en la intro", "ya no agregaremos el modelo de blanco opaco, solo sera ajusta el cuadro a un tono oscuro o
gris", "el fondo de de la intro start tambien ira junto a comprado de arma, y mejoras de heroe", "y sube a 60 el tiempo
de compra").
- Carta de 330 × 480 a 330 × 540 px, centrada en py 425 (155..695): recuadro del icono e icono a py 278, placa del
  nombre a 404 (nombre a 385), caja del texto de 116 a 150 px de alto a py 511, botón y su pista a 645. La burbuja,
  CuaBurbuja.mdx de burbuja_v19q.py (contorno 172 × 278), va a py 425.
- Descripción: tamaño 0,021 → 0,022, en la caja más alta (456 / 473 el héroe, 2 px por debajo de su borde como antes).
- Cabecera: el cuadro ancho de la tienda ('DS0B', ShopWide) de 760 × 80 a py 84, sin teñir, y su burbuja 'ubjC'
  (CuaBurbujaCab.mdx) teñida con el color de la pantalla, que antes teñía la banda 'DS1R'. Título a py 67.
- El pie baja de 722 a 748 para no tocar la burbuja de la carta.
- Cartas cerradas: fuera la burbuja gris 'ubjG'; quedan las piezas oscurecidas (110) y sin burbuja.
- Fondo: la nebulosa del título ('uidn', NebulaV8\\Nebula_PlusZ.mdx, sin billboards) detrás de la tienda de armas
  (X 2400) y de las cartas y mejoras del héroe (X 4800), a la misma profundidad bajo el ojo que en el título. Se crea
  una vez (código sincronizado) con escala 0; Fondo_Ver la muestra sólo en el cliente que mira esa pantalla (visual).
- Ronda_DESCANSO 45 → 60.
Uso: v19q.py ENTRADA.j SALIDA.j [prueba]   (normal de v19p; prueba de v19p-prueba)
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


# --- globales y descanso ---
cambia('unit array Cua_AroA\nunit array Cua_AroG\n', 'unit array Cua_AroA\nunit Cua_CabA = null\nunit array Fondo_Bg\n')
cambia('constant integer Ronda_DESCANSO = 45\n', 'constant integer Ronda_DESCANSO = 60\n')

# --- fondo de rayos ---
antes('function Shop_Mostrar takes integer p, boolean on returns nothing\n', '''// v19q: la nebulosa del título detrás de la pantalla k (1 tienda en X 2400, 2 cartas en X 4800), a la misma
// profundidad bajo el ojo que en el título (Title_BgHeight sobre el suelo de X 0). Se crea en código sincronizado
// con escala 0; sólo el cliente de p la muestra (visual).
function Fondo_Ver takes integer p, integer k, real x, boolean on returns nothing
    local unit u = Fondo_Bg[k]
    if u == null then
        set u = CreateUnit(CAMERA_DUMMY_PLAYER, 'uidn', x, 8700., 90)
        call UnitAddAbility(u, s__Interface_DESTROYER_FORM_ID)
        call UnitRemoveAbility(u, s__Interface_DESTROYER_FORM_ID)
        call UnitAddAbility(u, s__Interface_LOCUST_ID)
        call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
        call SetUnitInvulnerable(u, true)
        call SetUnitX(u, x)
        call SetUnitY(u, 8700.)
        call SetUnitFlyHeight(u, Title_BgHeight + UserInterface_GetTerrainZ(0., 8700.) - UserInterface_GetTerrainZ(x, 8700.), 0)
        call SetUnitScale(u, 0., 0., 0.)
        set Fondo_Bg[k] = u
    endif
    if GetLocalPlayer() == Player(p) then
        if on then
            call SetUnitScale(u, Title_BgScale, Title_BgScale, Title_BgScale)
        else
            call SetUnitScale(u, 0., 0., 0.)
        endif
    endif
    set u = null
endfunction

''')
cambia('''    if on then
        set Shop_Fondo[p] = AddSpecialEffect(path, Title_X(), Title_Y())
''', '''    call Fondo_Ver(p, 1, 2400., on)
    if on then
        set Shop_Fondo[p] = AddSpecialEffect(path, Title_X(), Title_Y())
''')
cambia('''    if on then
        set Cua_Fondo[p] = AddSpecialEffect(path, 4800., 8700.)
''', '''    call Fondo_Ver(p, 2, 4800., on)
    if on then
        set Cua_Fondo[p] = AddSpecialEffect(path, 4800., 8700.)
''')

# --- Cua_Construir ---
cambia("""            set Cua_Bg[s] = Cua_Pic(Cua_PX(s), 410, 330, 480, 430, 'DS1S')
            set Cua_Bt[s] = Cua_Pic(Cua_PX(s), 610, 170, 56, 399, 'DS0A')""",
       """            set Cua_Bg[s] = Cua_Pic(Cua_PX(s), 425, 330, 540, 430, 'DS1S')
            set Cua_Bt[s] = Cua_Pic(Cua_PX(s), 645, 170, 56, 399, 'DS0A')""")
cambia("""            set Cua_Et[s] = Cua_Pic(Cua_PX(s) + 0.6, 608.1, 125.23, 31.38, 397, 'DSE8')""",
       """            set Cua_Et[s] = Cua_Pic(Cua_PX(s) + 0.6, 643.1, 125.23, 31.38, 397, 'DSE8')""")
cambia("""            set Cua_Cel[s] = Cua_Pic(Cua_PX(s), 285, 206, 206, 404, 'DS03')
            set Cua_Placa[s] = Cua_Pic(Cua_PX(s), 405, 300, 36, 412, 'DS06')
            set Cua_Caja[s] = Cua_Pic(Cua_PX(s), 492, 300, 116, 414, 'DS04')""",
       """            set Cua_Cel[s] = Cua_Pic(Cua_PX(s), 278, 206, 206, 404, 'DS03')
            set Cua_Placa[s] = Cua_Pic(Cua_PX(s), 404, 300, 36, 412, 'DS06')
            set Cua_Caja[s] = Cua_Pic(Cua_PX(s), 511, 300, 150, 414, 'DS04')""")
cambia("""            set Cua_AroA[s] = Cua_Aro(Cua_PX(s), 410, 428, 'ubjB')
            set Cua_AroG[s] = Cua_Aro(Cua_PX(s), 410, 428, 'ubjG')
""", """            set Cua_AroA[s] = Cua_Aro(Cua_PX(s), 425, 428, 'ubjB')
""")
cambia("""                    set Cua_Ico[p * 9 + s] = Cua_Pic(Cua_PX(s), 285, 190, 190, 405, 'DC00')
                    call Shop_Pista(p, "war3mapImported\\\\CuaHitBtn.mdx", Cua_PX(s), 610, 40 + s)""",
       """                    set Cua_Ico[p * 9 + s] = Cua_Pic(Cua_PX(s), 278, 190, 190, 405, 'DC00')
                    call Shop_Pista(p, "war3mapImported\\\\CuaHitBtn.mdx", Cua_PX(s), 645, 40 + s)""")
cambia("""            set Cua_Ico[s] = Cua_Pic(Cua_PX(Cua_Slot(n, c)), 285, 190, 190, 405, tex)""",
       """            set Cua_Ico[s] = Cua_Pic(Cua_PX(Cua_Slot(n, c)), 278, 190, 190, 405, tex)""")
cambia("""    set Cua_PieP = Cua_Pic(948.1, 722.4, 500.94, 62.76, 397, 'DSEB')
    set Cua_CabP = Cua_Pic(960, 87, 1000, 64, 420, 'DS1R')
""", """    set Cua_PieP = Cua_Pic(948.1, 748.4, 500.94, 62.76, 397, 'DSEB')
    // v19q: cabecera en el cuadro ancho de la tienda, con su burbuja.
    set Cua_CabP = Cua_Pic(960, 84, 760, 80, 420, 'DS0B')
    set Cua_CabA = Cua_Aro(960, 84, 428, 'ubjC')
""")

# --- Cua_Ver ---
cambia("""            call Cua_AroVer(Cua_AroA[s], aro > 0, fa, r, g, b)
            // v19p: cuadro cerrado, burbuja gris opaca.
            call Cua_AroVer(Cua_AroG[s], a > 0 and inicio and ic != 255, a, 255, 255, 255)
""", """            call Cua_AroVer(Cua_AroA[s], aro > 0, fa, r, g, b)
""")
cambia("""    call SetUnitVertexColor(Cua_CabP, Her_R, Her_G, Her_B, a)
""", """    // v19q: el cuadro sin teñir; el color de la pantalla va en su burbuja.
    call SetUnitVertexColor(Cua_CabP, 255, 255, 255, a)
    call Cua_AroVer(Cua_CabA, a > 0, a, Her_R, Her_G, Her_B)
""")
cambia("""Cua_InicioCab(p), 960, 70, 0.03)""", """Cua_InicioCab(p), 960, 67, 0.03)""")
cambia("""Cua_Cabecera(p), 960, 70, 0.03)""", """Cua_Cabecera(p), 960, 67, 0.03)""")
cambia("""Her_Nombre(p, c), Cua_PX(s), 386, 0.025)""", """Her_Nombre(p, c), Cua_PX(s), 385, 0.025)""")
cambia("""Cua_Nom[Cua_Item(p, c)], Cua_PX(s), 386, 0.025)""", """Cua_Nom[Cua_Item(p, c)], Cua_PX(s), 385, 0.025)""")
cambia("""Her_Des(p, c), Cua_PX(s) - 138, 471, 0.021)""", """Her_Des(p, c), Cua_PX(s) - 138, 473, 0.022)""")
cambia("""Cua_InicioDes(p, c), Cua_PX(s) - 138, 454, 0.021)""", """Cua_InicioDes(p, c), Cua_PX(s) - 138, 456, 0.022)""")
cambia("""Cua_VotosTxt(p, c), Cua_PX(s) - 138, 454, 0.021)""", """Cua_VotosTxt(p, c), Cua_PX(s) - 138, 456, 0.022)""")
assert 'Cua_AroG' not in src and "'ubjG'" not in src

if prueba:
    for viejo, nuevo in (('lat\\\\v19p-', 'lat\\\\v19q-'), ('v19p-don.txt', 'v19q-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19q', 'prueba' if prueba else 'normal')
