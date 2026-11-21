#!/usr/bin/env python3
"""v19v (19/11/2026), fase 3 del plan devmission-v20-mutaciones-rachas-mvp.md: cartas de Mutación Evo del inicio de
oleada con la ventana de los paneles de la tienda y un cuadro debajo con la descripción (Leon: "con el diseño de los
cuadros de mejora ... y otro cuadro debajo con la descripción del cambio al enemigo").
- Mut_Bg: 'DS01' carmesí 230 × 300 → 'DS1V' CuaMutCarta 270 × 250 (texturas_v19v.py), sin tinte.
- Mut_Caja: 'DS1W' CuaMutDes 270 × 130 debajo de cada carta.
- Cartas a 290 px entre centros (antes 260); ventana en py 395, icono 360, nombre 478, cuadro 600, título 230.
- Descripciones (Cua_Des, dos renglones) en 3 texttags locales por jugador (Mut_DT) que sólo existen mientras dura la
  muestra: se crean en Cua_MuestraEmpezar y se destruyen en Cua_MuestraFin, así no gastan presupuesto el resto del juego.
Uso: v19v.py ENTRADA.j SALIDA.j [prueba]   (normal de v19u; prueba de v19u-prueba)
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


cambia('unit array Mut_Bg\n', '''unit array Mut_Bg
// v19v: cuadro de descripción bajo cada carta y sus textos (sólo durante la muestra).
unit array Mut_Caja
integer array Mut_DT
''')

# --- piezas ---
cambia('''        set Mut_Bg[p * 3 + k] = Punt_Pieza(p, 230. * 412. / 400., 300. * 412. / 400., 'DS01')
        call SetUnitVertexColor(Mut_Bg[p * 3 + k], 225, 45, 70, a)''', '''        set Mut_Bg[p * 3 + k] = Punt_Pieza(p, 270. * 412. / 400., 250. * 412. / 400., 'DS1V')
        call SetUnitVertexColor(Mut_Bg[p * 3 + k], 255, 255, 255, a)
        set Mut_Caja[p * 3 + k] = Punt_Pieza(p, 270. * 412. / 400., 130. * 412. / 400., 'DS1W')
        call SetUnitVertexColor(Mut_Caja[p * 3 + k], 255, 255, 255, a)
        set Mut_DT[p * 3 + k] = 0''')

# --- textos de descripción: viven sólo durante la muestra ---
cambia('''    // v18r: cuadro central de interfaz (Mut_Hud); la cámara sigue en el héroe.
    set Mut_Ver = Mut_Ver + 1''', '''    // v19v: textos de las descripciones de las cartas (locales; UIText crea su pieza en todos los clientes).
    set p = 0
    loop
        exitwhen p > 11
        if Mut_Ok[p] then
            set k = 0
            loop
                exitwhen k > 2
                if Mut_DT[p * 3 + k] == 0 then
                    set Mut_DT[p * 3 + k] = s__UIText_createEx(Player(p), 0., 0., 1.)
                    call SetTextTagPermanent(s__UIText_text[Mut_DT[p * 3 + k]], true)
                    call JefeTx_Color(Mut_DT[p * 3 + k], s__UIText_text[Mut_DT[p * 3 + k]], 225, 228, 240)
                endif
                set k = k + 1
            endloop
        endif
        set p = p + 1
    endloop
    // v18r: cuadro central de interfaz (Mut_Hud); la cámara sigue en el héroe.
    set Mut_Ver = Mut_Ver + 1''')
cambia('''function Cua_MuestraEmpezar takes nothing returns nothing
    local integer p = 0
''', '''function Cua_MuestraEmpezar takes nothing returns nothing
    local integer p = 0
    local integer k
''')
cambia('''    set Mut_T = -1.
    // v19u: disparador de Espinas''', '''    set Mut_T = -1.
    // v19v: fuera los textos de las descripciones de la muestra.
    set p = 0
    loop
        exitwhen p > 35
        if Mut_DT[p] != 0 then
            call s__UIText_destroy(Mut_DT[p])
            set Mut_DT[p] = 0
        endif
        set p = p + 1
    endloop
    set p = 0
    // v19u: disparador de Espinas''')

# --- Mut_Hud ---
cambia('''            call JefeTx_Texto(Mut_TT[p * 4 + 1 + k], s__UIText_text[Mut_TT[p * 4 + 1 + k]], Cua_Nom[Cua_Gana[k]], 0.02)
            set k = k + 1''', '''            call JefeTx_Texto(Mut_TT[p * 4 + 1 + k], s__UIText_text[Mut_TT[p * 4 + 1 + k]], Cua_Nom[Cua_Gana[k]], 0.02)
            if Mut_DT[p * 3 + k] != 0 then
                call JefeTx_Texto(Mut_DT[p * 3 + k], s__UIText_text[Mut_DT[p * 3 + k]], Cua_Des[Cua_Gana[k]], 0.016)
            endif
            set k = k + 1''')
cambia('''        call Hud_Ver(Mut_Ico[p * 3 + k], shown)
        call s__UIText_show(Mut_TT[p * 4 + 1 + k], txt, cam)''', '''        call Hud_Ver(Mut_Ico[p * 3 + k], shown)
        call Hud_Ver(Mut_Caja[p * 3 + k], shown)
        call s__UIText_show(Mut_TT[p * 4 + 1 + k], txt, cam)
        if Mut_DT[p * 3 + k] != 0 then
            call s__UIText_show(Mut_DT[p * 3 + k], txt, cam)
        endif''')
cambia('''        set cx = 960. + 260. * (k - 1)
        call HealthBars__Place(Mut_Bg[p * 3 + k], cam, cx, 420. + dy, 412.)
        call HealthBars__Place(Mut_Ico[p * 3 + k], cam, cx, 385. + dy, 398.)
        set s = Cua_Nom[Cua_Gana[k]]
        call Punt_Pos(Mut_TT[p * 4 + 1 + k], cx - StringLength(s) * 0.02 * 235., 505. + dy, 0.02)
        set k = k + 1
    endloop
    call Punt_Pos(Mut_TT[p * 4], 960. - 12. * 0.03 * 235., 245. + dy, 0.03)''', '''        // v19v: ventana de la tienda con icono y nombre, y debajo el cuadro de la descripción.
        set cx = 960. + 290. * (k - 1)
        call HealthBars__Place(Mut_Bg[p * 3 + k], cam, cx, 395. + dy, 412.)
        call HealthBars__Place(Mut_Ico[p * 3 + k], cam, cx, 360. + dy, 398.)
        call HealthBars__Place(Mut_Caja[p * 3 + k], cam, cx, 600. + dy, 412.)
        set s = Cua_Nom[Cua_Gana[k]]
        call Punt_Pos(Mut_TT[p * 4 + 1 + k], cx - StringLength(s) * 0.02 * 235., 478. + dy, 0.02)
        if Mut_DT[p * 3 + k] != 0 then
            call Punt_Pos(Mut_DT[p * 3 + k], cx - 112., 588. + dy, 0.016)
        endif
        set k = k + 1
    endloop
    call Punt_Pos(Mut_TT[p * 4], 960. - 12. * 0.03 * 235., 230. + dy, 0.03)''')

if prueba:
    for viejo, nuevo in (('lat\\\\v19u-', 'lat\\\\v19v-'), ('v19u-don.txt', 'v19v-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19v', 'prueba' if prueba else 'normal')
