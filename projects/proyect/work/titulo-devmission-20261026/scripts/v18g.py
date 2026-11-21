#!/usr/bin/env python3
"""v18g (15/11/2026), fase 3, segundo lote: "Elegir", el pie de los cuadros y el aviso de la tienda a textura.

Texturas y medidas en etiquetas_v18g.py (DIR/etiquetas.json):
- Cuadros: "Elegir" (Cua_TB, 5 texttags) pasa a una pieza 'DSE8' por ranura (Cua_Et, delante del botón, a 397) y el
  pie "Esc: salir (se guarda hasta la oleada)" (Cua_TPie) a la pieza 'DSEB' (Cua_PieP). Se ven con el mismo alfa
  local que el botón en Cua_Ver. Texttags con la ventana abierta: de 18 a 12.
- Aviso de la tienda: el UIText DevTienda_Aviso deja de crearse; dos piezas del HUD por jugador ('uidb' con Arm_Foto,
  'DSE9' "Press [ESC] to buy supplies" y 'DSEA' "[ESC] Pick up Ammo"), colocadas con HealthBars__Place a 400 donde
  estaba el texto. Se muestran con ShowUnit en código común (la cámara lógica y DevTienda_AvisoK son iguales en todos
  los clientes, como DevJefe_Poner); sólo su dueño las ve (alfa local de HealthBars__Dummy). El oscurecimiento de la
  presentación del jefe (JefeTx_F) se aplica con el color de vértice en el cliente del dueño, como las barras (v17j).
Prueba: registros en lat\\v18g-*.txt.
Uso: v18g.py v18f/war3map.j SALIDA.j DIR_ETIQUETAS [prueba]
"""
from pathlib import Path
import json, sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
E = {e['id']: e for e in json.loads((Path(sys.argv[3]) / 'etiquetas.json').read_text())['etiquetas']}
prueba = len(sys.argv) > 4 and sys.argv[4] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
u8 = lambda s: s.encode('utf-8').decode('latin-1')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(u8(antes)), crlf(u8(despues))
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


el, pie, a1, a2 = E['DSE8'], E['DSEB'], E['DSE9'], E['DSEA']
assert a1['cy'] == a2['cy'] and (a1['w'], a1['h']) == (a2['w'], a2['h'])

# Globales.
una('texttag Cua_TPie = null\n', 'texttag Cua_TPie = null\nunit array Cua_Et\nunit Cua_PieP = null\n')
una('integer array DevTienda_AvisoK\n', 'integer array DevTienda_AvisoK\nunit array DevTienda_Pieza\n')

# --- Cuadros ---
una('// Sólo en el cliente de quien abre la ventana: 18 texttags que se quitan al cerrarla.',
    '// Sólo en el cliente de quien abre la ventana: 12 texttags que se quitan al cerrarla ("Elegir" y el pie son\n'
    '// piezas desde v18g).')
una('''    set Cua_TCab = Cua_Tag()
    set Cua_TPie = Cua_Tag()
''', '''    set Cua_TCab = Cua_Tag()
''')
una('''        set Cua_TD[i] = Cua_Tag()
        set Cua_TB[i] = Cua_Tag()
''', '''        set Cua_TD[i] = Cua_Tag()
''')
una('''    call DestroyTextTag(Cua_TPie)
''', '')
una('''    set Cua_TPie = null
''', '')
una('''        call DestroyTextTag(Cua_TB[i])
''', '')
una('''        set Cua_TB[i] = null
''', '')
una('''            call SetUnitVertexColor(Cua_Bt[s], 255, 255, 255, a)
''', '''            call SetUnitVertexColor(Cua_Bt[s], 255, 255, 255, a)
            call SetUnitVertexColor(Cua_Et[s], 255, 255, 255, a)
''')
una('''        set s = s + 1
    endloop
    if Cua_TCab == null or Cua_Paso[p] >= 5 then
''', '''        set s = s + 1
    endloop
    // v18g: el pie, textura 'DSEB'.
    set a = 0
    if Cua_Open[p] and Cua_Paso[p] < 5 then
        set a = 255
    endif
    call SetUnitVertexColor(Cua_PieP, 255, 255, 255, a)
    if Cua_TCab == null or Cua_Paso[p] >= 5 then
''')
una('''    call Cua_Centro(p, Cua_TPie, "Esc: salir (se guarda hasta la oleada)", 960, 700, 0.018)
''', '')
una('''            call Cua_Centro(p, Cua_TB[c], "Elegir", Cua_PX(s), 586, 0.022)
''', '')
una('''            call SetTextTagVisibility(Cua_TB[c], true)
''', '')
una('''            call SetTextTagVisibility(Cua_TB[c], false)
''', '')
una('''            set Cua_Bt[s] = Cua_Pic(Cua_PX(s), 610, 170, 56, 399, 'DS0A')
''', f'''            set Cua_Bt[s] = Cua_Pic(Cua_PX(s), 610, 170, 56, 399, 'DS0A')
            // v18g: "Elegir" en textura (etiquetas_v18g.py), donde se veía el texttag.
            set Cua_Et[s] = Cua_Pic(Cua_PX(s) + {el['dpx']}, {el['py']}, {el['w']}, {el['h']}, 397, 'DSE8')
''')
una('''        set s = s + 1
    endloop
    set Title_CX = 2400.
    set u = null
endfunction
''', f'''        set s = s + 1
    endloop
    // v18g: pie de la ventana en textura.
    set Cua_PieP = Cua_Pic({pie['px']}, {pie['py']}, {pie['w']}, {pie['h']}, 397, 'DSEB')
    set Title_CX = 2400.
    set u = null
endfunction
''')

# --- Aviso de la tienda ---
una('''// Aviso en el centro (sólo en el cliente del jugador, UIText local) y el localizador de la tienda.
function DevTienda_Hud takes integer p, integer cam returns nothing''', f'''// v18g: el aviso en textura. Pieza v (0 tienda, 1 munición) visible si DevTienda_AvisoK[p] == v + 1; en su sitio y
// oscurecida como las barras durante la presentación del jefe (JefeTx_F, sólo en el cliente del dueño).
function DevTienda_AvisoVer takes integer p, integer cam returns nothing
    local integer v = 0
    local unit u
    local boolean b
    loop
        exitwhen v > 1
        set u = DevTienda_Pieza[p * 2 + v]
        set b = DevTienda_AvisoK[p] == v + 1
        call Hud_Ver(u, b)
        if b then
            if v == 0 then
                call HealthBars__Place(u, cam, {a1['cx']}, {a1['cy']}, 400.)
            else
                call HealthBars__Place(u, cam, {a2['cx']}, {a2['cy']}, 400.)
            endif
            if GetLocalPlayer() == Player(p) then
                call SetUnitVertexColor(u, R2I(255. * (1. - JefeTx_F) + 11. * JefeTx_F), R2I(255. * (1. - JefeTx_F) + 16. * JefeTx_F), R2I(255. * (1. - JefeTx_F) + 34. * JefeTx_F), 255)
            endif
        endif
        set v = v + 1
    endloop
    set u = null
endfunction

// Aviso en el centro (pieza con textura desde v18g, sólo la ve el jugador) y el localizador de la tienda.
function DevTienda_Hud takes integer p, integer cam returns nothing''')
una('''        set DevTienda_Aviso[p]=s__UIText_createEx(Player(p) , 0. , 0. , 1.)
        call SetTextTagPermanent(s__UIText_text[DevTienda_Aviso[p]], true)
        call JefeTx_Color(DevTienda_Aviso[p], s__UIText_text[DevTienda_Aviso[p]], 255, 255, 255)
''', f'''        // v18g: el aviso son dos piezas con textura (antes un UIText con el texto en degradado).
        set DevTienda_Pieza[p * 2]=HealthBars__Dummy('uidb' , p)
        call UnitAddAbility(DevTienda_Pieza[p * 2], s__Interface_LOCUST_ID)
        call UnitRemoveAbility(DevTienda_Pieza[p * 2], s__Interface_LOCUST_ID)
        call Arm_Foto(DevTienda_Pieza[p * 2], {a1['w']}., {a1['h']}., 'DSE9')
        call ShowUnit(DevTienda_Pieza[p * 2], false)
        set DevTienda_Pieza[p * 2 + 1]=HealthBars__Dummy('uidb' , p)
        call UnitAddAbility(DevTienda_Pieza[p * 2 + 1], s__Interface_LOCUST_ID)
        call UnitRemoveAbility(DevTienda_Pieza[p * 2 + 1], s__Interface_LOCUST_ID)
        call Arm_Foto(DevTienda_Pieza[p * 2 + 1], {a2['w']}., {a2['h']}., 'DSEA')
        call ShowUnit(DevTienda_Pieza[p * 2 + 1], false)
''')
una('''    if not HealthBars__Lento then
        call s__UIText_show(DevTienda_Aviso[p],DevTienda_AvisoK[p] != 0 , cam)
        return
    endif
''', '''    if not HealthBars__Lento then
        call DevTienda_AvisoVer(p, cam)
        return
    endif
''')
i = j.index(crlf('    if k != DevTienda_AvisoK[p] then\r\n'))
f = j.index(crlf('    call s__UIText_show(DevTienda_Aviso[p],k != 0 , cam)\r\n'), i)
fin = f + len(crlf('    call s__UIText_show(DevTienda_Aviso[p],k != 0 , cam)\r\n'))
j = j[:i] + crlf('''    set DevTienda_AvisoK[p]=k
    call DevTienda_AvisoVer(p, cam)
''') + j[fin:]
assert 'DevTienda_Aviso[p]' not in j and 'Cua_TB[' not in j and 'Cua_TPie' in j

if prueba:
    for n in ('super', 'precarga', 'cuadros'):
        una(f'call PreloadGenEnd("lat\\\\v18f-{n}.txt")', f'call PreloadGenEnd("lat\\\\v18g-{n}.txt")')
    assert 'lat\\\\v18f-' not in j
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v18g: "Elegir", pie de los cuadros y aviso de la tienda en textura' + (' + registro' if prueba else ''))
