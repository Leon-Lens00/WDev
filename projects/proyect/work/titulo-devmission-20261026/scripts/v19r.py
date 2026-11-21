#!/usr/bin/env python3
"""v19r (19/11/2026): textos dentro de sus cuadros, sin el pie de Esc, pantalla más abajo y paneles de mejoras en la
pantalla de inicio de la tienda (Leon: "hace falta ajustar los textos y ves tocar el borde del cuadro, adicional quitar
ese texto de blanco de abajo que dice esc, y ajustar con ese espacio libre los cuadros que estan muy apilados hacia
arriba, adicional en el menu donde se encuentra para elegir mejora de boss y jugador estara un cuadro a la izquierda
superior de ver mejoras de boss en rojo y a la derecha en verde ver mejoras de jugador, el formato sera habran varios
icono mostrando solo los elegidos, al click a uno debajo abra un cuadro grande con contorno que copiara el icono y
aplicara la descripcion de la mejora, al inicio estara vacio hasta que seleccione una, saldra tambien en la parte
superior 3 rectangulos peques para seleccionar y alternar entre mejoras de boss elite y comunes").
- Textos: la descripción entra 12 px más (px − 126) y se centra en la caja (el texttag se ancla por abajo: 546 con 2
  renglones, 559 el héroe con 3). Cabecera a 0,027 y textos más cortos ("Tienda · primero, el jefe", "Tienda · ahora,
  tu héroe"): a 0,03 el texttag partía en dos renglones a partir de ~33 caracteres y subía sobre el cuadro.
- Fuera el pie 'DSEB' ("Esc: salir…").
- Todo baja: cabecera a py 96 (título a 77), cartas a py 480 (210..750) con sus piezas, textos, botón y pista 55 px más
  abajo.
- Paneles (sólo en la pantalla de inicio, Cua_Modo 0):
  - Izquierda, mutaciones (burbuja roja): 3 pestañas Jefe / Élite / Comunes ('DS06'/'DS05' de la tienda, 100 × 34) y
    los iconos de las mutaciones activas de esa pestaña (Cua_Activa > 0), 5 por fila, 52 px cada 60.
  - Derecha, mejoras del héroe (burbuja verde): placa con "Mejoras de tu héroe" y los iconos de cada mejora elegida
    (Pan_Registrar desde Cua_Hacer, hasta 20).
  - Debajo de cada uno, un cuadro de detalle con burbuja: vacío hasta pulsar un icono; luego el icono grande, el nombre
    (con su calidad en el héroe, × n en mutaciones repetidas) y la descripción.
  - Ventanas CuaPanel 'DS1T' (340 × 310, py 325) y CuaDetalle 'DS1U' (340 × 290, py 656); burbujas 'ubjP' y 'ubjD'.
  - Clics: trackables por jugador (Shop_Pista) 60-62 pestañas, 70-79 iconos de mutación, 80-99 iconos del héroe;
    Shop_Clic los pasa a Pan_Clic. Los iconos de mutación (uno por mutación) se ordenan en código sincronizado
    (Pan_Ordenar, al abrir la pantalla y tras cada mejora del héroe); el icono del detalle se rehace al pulsar. Todo lo
    que se ve depende de Pan_Ver, en el cliente local, dentro de Cua_Ver.
  - "Mutaciones activas: …" ya no sale en la pantalla de inicio (lo muestra el panel); sigue en las de cartas.
Uso: v19r.py ENTRADA.j SALIDA.j [prueba]   (normal de v19q; prueba de v19q-prueba)
"""
import re
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
cambia('unit array Fondo_Bg\n', '''unit array Fondo_Bg
unit array Pan_Pz
integer Pan_PzN = 0
unit array Pan_Aro
unit array Pan_TabOff
unit array Pan_TabOn
unit array Pan_MIco
integer array Pan_MSlot
integer array Pan_Cnt
unit array Pan_HIco
integer array Pan_HX
integer array Pan_HQ
integer array Pan_HN
unit array Pan_DIco
integer array Pan_DTex
integer array Pan_Tab
integer array Pan_SelM
integer array Pan_SelH
texttag array Pan_TT
''')

# --- Pan_HDes: la descripción de Her_Des para una mejora ya elegida (x, calidad q) ---
m = re.search(r'function Her_Des takes integer p, integer c returns string\n.*?\nendfunction\n', src, re.S)
hd = m.group(0)
hd = hd.replace('function Her_Des takes integer p, integer c returns string\n',
                'function Pan_HDes takes integer p, integer x, integer q returns string\n')
hd = hd.replace('    local integer x\n', '', 1)
i = hd.index('    if c == 4 then\n')
j = hd.index('\n    endif\n', i) + len('\n    endif\n')
hd = hd[:i] + hd[j:]
for viejo, nuevo in (('    set x = Cua_HCand[Her_K(p, c)]\n', ''), ('Her_Valor(x, Her_Cal[Her_K(p, c)])', 'Her_Valor(x, q)')):
    assert hd.count(viejo) == 1, viejo
    hd = hd.replace(viejo, nuevo)
assert 'Her_K' not in hd and ' c ' not in hd and '(c' not in hd
src = src.replace(m.group(0), m.group(0) + '\n// v19r: descripción de una mejora del héroe ya elegida (panel de la derecha).\n' + hd, 1)

# --- funciones del panel (antes de Cua_Ver: las usa Cua_Ver y Cua_Mostrar) ---
antes('function Cua_Ver takes integer p returns nothing\n', '''// v19r: paneles de mejoras de la pantalla de inicio. k = 0 izquierda (mutaciones), 1 derecha (héroe).
function Pan_CX takes integer k returns real
    if k == 0 then
        return 210.
    endif
    return 1710.
endfunction

function Pan_IcoX takes integer k, integer i returns real
    return Pan_CX(k) + (ModuloInteger(i, 5) - 2) * 60.
endfunction

function Pan_IcoY takes integer i returns real
    return 262. + (i / 5) * 60.
endfunction

function Pan_TabX takes integer i returns real
    return 210. + (i - 1) * 108.
endfunction

function Pan_Grupo takes integer x returns integer
    if x < 4 then
        return 0
    elseif x < 8 then
        return 1
    endif
    return 2
endfunction

function Pan_Tex takes integer x returns integer
    if Cua_Tex[x] == 0 then
        return 'DC00'
    endif
    return Cua_Tex[x]
endfunction

// Lleva una pieza ya creada a (px, py) a la profundidad dada en la escena de las cartas (código sincronizado).
function Pan_Mover takes unit u, real px, real py, real depth returns nothing
    local real cx = Title_CX
    local real x
    local real y
    set Title_CX = 4800.
    set x = Title_WX(Shop_PY(py), depth)
    set y = Title_WY(px, depth)
    set Title_CX = cx
    call SetUnitX(u, x)
    call SetUnitY(u, y)
    call SetUnitFlyHeight(u, Shop_OJO - depth - UserInterface_GetTerrainZ(x, y), 0)
endfunction

// Coloca en orden los iconos de las mutaciones activas de cada grupo (código sincronizado; Cua_Activa es común).
function Pan_Ordenar takes nothing returns nothing
    local integer x = 0
    local integer g
    set Pan_Cnt[0] = 0
    set Pan_Cnt[1] = 0
    set Pan_Cnt[2] = 0
    loop
        exitwhen x > 17
        set Pan_MSlot[x] = -1
        if Cua_Activa[x] > 0 and Pan_MIco[x] != null then
            set g = Pan_Grupo(x)
            if Pan_Cnt[g] < 10 then
                set Pan_MSlot[x] = Pan_Cnt[g]
                call Pan_Mover(Pan_MIco[x], Pan_IcoX(0, Pan_Cnt[g]), Pan_IcoY(Pan_Cnt[g]), 405)
                set Pan_Cnt[g] = Pan_Cnt[g] + 1
            endif
        endif
        set x = x + 1
    endloop
endfunction

// Una mejora del héroe elegida por p: su icono en el panel de la derecha (código sincronizado, desde Cua_Hacer).
function Pan_Registrar takes integer p, integer x, integer q returns nothing
    local integer i = Pan_HN[p]
    local real cx = Title_CX
    if i < 20 then
        set Pan_HX[p * 20 + i] = x
        set Pan_HQ[p * 20 + i] = q
        set Title_CX = 4800.
        set Pan_HIco[p * 20 + i] = Cua_Pic(Pan_IcoX(1, i), Pan_IcoY(i), 52, 52, 405, Pan_Tex(x))
        set Title_CX = cx
        set Pan_HN[p] = i + 1
    endif
    call Pan_Ordenar()
endfunction

// El icono grande del detalle k de p, rehecho con la textura elegida (código sincronizado, desde el clic).
function Pan_Detalle takes integer p, integer k, integer tex returns nothing
    local integer s = p * 2 + k
    local real cx = Title_CX
    if Pan_DIco[s] != null and Pan_DTex[s] == tex then
        return
    endif
    if Pan_DIco[s] != null then
        call FlushChildHashtable(Title_HT, GetHandleId(Pan_DIco[s]))
        call RemoveUnit(Pan_DIco[s])
    endif
    set Title_CX = 4800.
    set Pan_DIco[s] = Cua_Pic(Pan_CX(k), 586, 120, 120, 405, tex)
    set Title_CX = cx
    set Pan_DTex[s] = tex
endfunction

// Sólo visual, en el cliente local (lo llama Cua_Ver, que ya filtra por GetLocalPlayer).
function Pan_Ver takes integer p, boolean on returns nothing
    local integer a = 0
    local integer i = 0
    local integer x
    local integer c
    local integer n = 0
    local string s
    if on then
        set a = 255
    endif
    loop
        exitwhen i >= Pan_PzN
        call SetUnitVertexColor(Pan_Pz[i], 255, 255, 255, a)
        set i = i + 1
    endloop
    call Cua_AroVer(Pan_Aro[0], on, 255, 225, 45, 70)
    call Cua_AroVer(Pan_Aro[1], on, 255, 70, 205, 95)
    call Cua_AroVer(Pan_Aro[2], on, 255, 225, 45, 70)
    call Cua_AroVer(Pan_Aro[3], on, 255, 70, 205, 95)
    set i = 0
    loop
        exitwhen i > 2
        call SetUnitVertexColor(Pan_TabOff[i], 255, 255, 255, a)
        if on and Pan_Tab[p] == i then
            call SetUnitVertexColor(Pan_TabOn[i], 255, 255, 255, 255)
        else
            call SetUnitVertexColor(Pan_TabOn[i], 255, 255, 255, 0)
        endif
        set i = i + 1
    endloop
    set x = 0
    loop
        exitwhen x > 17
        set c = 0
        if on and Cua_Activa[x] > 0 and Pan_MSlot[x] >= 0 and Pan_Grupo(x) == Pan_Tab[p] then
            set c = 255
            set n = n + 1
        endif
        set i = 170
        if Pan_SelM[p] == x + 1 then
            set i = 255
        endif
        call SetUnitVertexColor(Pan_MIco[x], i, i, i, c)
        set x = x + 1
    endloop
    set i = 0
    loop
        exitwhen i >= Pan_HN[p]
        set c = 170
        if Pan_SelH[p] == i + 1 then
            set c = 255
        endif
        call SetUnitVertexColor(Pan_HIco[p * 20 + i], c, c, c, a)
        set i = i + 1
    endloop
    set x = Pan_SelM[p] - 1
    set c = 0
    if on and x >= 0 and Cua_Activa[x] > 0 then
        set c = 255
    endif
    if Pan_DIco[p * 2] != null then
        call SetUnitVertexColor(Pan_DIco[p * 2], 255, 255, 255, c)
    endif
    if Pan_DIco[p * 2 + 1] != null then
        if on and Pan_SelH[p] > 0 then
            call SetUnitVertexColor(Pan_DIco[p * 2 + 1], 255, 255, 255, 255)
        else
            call SetUnitVertexColor(Pan_DIco[p * 2 + 1], 255, 255, 255, 0)
        endif
    endif
    if Pan_TT[0] == null then
        return
    endif
    if not on then
        set i = 0
        loop
            exitwhen i > 9
            call SetTextTagVisibility(Pan_TT[i], false)
            set i = i + 1
        endloop
        return
    endif
    set i = 0
    loop
        exitwhen i > 2
        set s = "Jefe"
        if i == 1 then
            set s = "Élite"
        elseif i == 2 then
            set s = "Comunes"
        endif
        call Cua_Centro(p, Pan_TT[i], s, Pan_TabX(i), 193, 0.019)
        if Pan_Tab[p] == i then
            call SetTextTagColor(Pan_TT[i], 255, 236, 200, 255)
        else
            call SetTextTagColor(Pan_TT[i], 150, 155, 165, 255)
        endif
        call SetTextTagVisibility(Pan_TT[i], true)
        set i = i + 1
    endloop
    call Cua_Centro(p, Pan_TT[3], "Mejoras de tu héroe", 1710, 192, 0.02)
    call SetTextTagColor(Pan_TT[3], 200, 255, 210, 255)
    call SetTextTagVisibility(Pan_TT[3], true)
    call Cua_Centro(p, Pan_TT[4], "Ninguna todavía.", 210, 288, 0.019)
    call SetTextTagColor(Pan_TT[4], 140, 140, 150, 255)
    call SetTextTagVisibility(Pan_TT[4], n == 0)
    call Cua_Centro(p, Pan_TT[5], "Ninguna todavía.", 1710, 288, 0.019)
    call SetTextTagColor(Pan_TT[5], 140, 140, 150, 255)
    call SetTextTagVisibility(Pan_TT[5], Pan_HN[p] == 0)
    // Detalle de la izquierda: mutación elegida.
    if c > 0 then
        set s = Cua_Nom[x]
        if Cua_Activa[x] > 1 then
            set s = s + " ×" + I2S(Cua_Activa[x])
        endif
        call Cua_Centro(p, Pan_TT[6], s, 210, 650, 0.024)
        call SetTextTagColor(Pan_TT[6], 255, 120, 130, 255)
        set s = "|cffff6070Jefe|r|n"
        if x >= 8 then
            set s = "|cffe8e8e8Comunes|r|n"
        elseif x >= 4 then
            set s = "|cffffa040Élite|r|n"
        endif
        call Cua_Izq(p, Pan_TT[8], s + Cua_Des[x], 60, 722, 0.021)
    endif
    call SetTextTagVisibility(Pan_TT[6], c > 0)
    call SetTextTagVisibility(Pan_TT[8], c > 0)
    // Detalle de la derecha: mejora del héroe elegida, con el color de su calidad.
    if Pan_SelH[p] > 0 then
        set i = p * 20 + Pan_SelH[p] - 1
        if Her_EsMaldita(Pan_HX[i]) then
            call Her_ColorTxt(5)
        else
            call Her_ColorTxt(Pan_HQ[i])
        endif
        call Cua_Centro(p, Pan_TT[7], Cua_Nom[Pan_HX[i]], 1710, 650, 0.024)
        call SetTextTagColor(Pan_TT[7], Her_R, Her_G, Her_B, 255)
        call Cua_Izq(p, Pan_TT[9], Pan_HDes(p, Pan_HX[i], Pan_HQ[i]), 1560, 722, 0.021)
    endif
    call SetTextTagVisibility(Pan_TT[7], Pan_SelH[p] > 0)
    call SetTextTagVisibility(Pan_TT[9], Pan_SelH[p] > 0)
endfunction

''')

# Clic en el panel (código sincronizado: el clic de un trackable llega a todos).
antes('function Shop_Clic takes nothing returns nothing\n', '''// v19r: k 60-62 pestañas, 70-79 iconos de mutación de la pestaña, 80-99 iconos del héroe.
function Pan_Clic takes integer p, integer k returns nothing
    local integer x = 0
    local integer i
    if Cua_Modo[p] != 0 then
        return
    endif
    if k <= 62 then
        call UI_Click(p)
        set Pan_Tab[p] = k - 60
    elseif k <= 79 then
        set i = k - 70
        loop
            exitwhen x > 17
            if Cua_Activa[x] > 0 and Pan_Grupo(x) == Pan_Tab[p] and Pan_MSlot[x] == i then
                call UI_Click(p)
                set Pan_SelM[p] = x + 1
                call Pan_Detalle(p, 0, Pan_Tex(x))
            endif
            set x = x + 1
        endloop
    else
        set i = k - 80
        if i < Pan_HN[p] then
            call UI_Click(p)
            set Pan_SelH[p] = i + 1
            call Pan_Detalle(p, 1, Pan_Tex(Pan_HX[p * 20 + i]))
        endif
    endif
    call Cua_Ver(p)
endfunction

''')
cambia('''    local integer k = LoadInteger(Shop_HT, h, 1)
    if k >= 40 then
''', '''    local integer k = LoadInteger(Shop_HT, h, 1)
    if k >= 60 then
        if Cua_Open[p] then
            call Pan_Clic(p, k)
        endif
        return
    endif
    if k >= 40 then
''')

# Construcción (con Title_CX = 4800, dentro de Cua_Construir).
antes('function Cua_Construir takes nothing returns nothing\n', '''// v19r: piezas, burbujas, iconos de mutación y trackables de los paneles de la pantalla de inicio.
function Pan_Construir takes nothing returns nothing
    local integer p = 0
    local integer i
    set Pan_Pz[0] = Cua_Pic(210, 325, 340, 310, 430, 'DS1T')
    set Pan_Pz[1] = Cua_Pic(1710, 325, 340, 310, 430, 'DS1T')
    set Pan_Pz[2] = Cua_Pic(210, 656, 340, 290, 430, 'DS1U')
    set Pan_Pz[3] = Cua_Pic(1710, 656, 340, 290, 430, 'DS1U')
    set Pan_Pz[4] = Cua_Pic(210, 586, 132, 132, 404, 'DS03')
    set Pan_Pz[5] = Cua_Pic(1710, 586, 132, 132, 404, 'DS03')
    set Pan_Pz[6] = Cua_Pic(1710, 205, 316, 34, 412, 'DS06')
    set Pan_PzN = 7
    set Pan_Aro[0] = Cua_Aro(210, 325, 428, 'ubjP')
    set Pan_Aro[1] = Cua_Aro(1710, 325, 428, 'ubjP')
    set Pan_Aro[2] = Cua_Aro(210, 656, 428, 'ubjD')
    set Pan_Aro[3] = Cua_Aro(1710, 656, 428, 'ubjD')
    set i = 0
    loop
        exitwhen i > 2
        set Pan_TabOff[i] = Cua_Pic(Pan_TabX(i), 205, 100, 34, 412, 'DS06')
        set Pan_TabOn[i] = Cua_Pic(Pan_TabX(i), 205, 100, 34, 411.5, 'DS05')
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 17
        set Pan_MIco[i] = Cua_Pic(Pan_IcoX(0, 0), Pan_IcoY(0), 52, 52, 405, Pan_Tex(i))
        set Pan_MSlot[i] = -1
        set i = i + 1
    endloop
    loop
        exitwhen p > 11
        if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
            set i = 0
            loop
                exitwhen i > 2
                call Shop_Pista(p, "war3mapImported\\\\CuaHitTab.mdx", Pan_TabX(i), 205, 60 + i)
                set i = i + 1
            endloop
            set i = 0
            loop
                exitwhen i > 19
                if i < 10 then
                    call Shop_Pista(p, "war3mapImported\\\\CuaHitIco.mdx", Pan_IcoX(0, i), Pan_IcoY(i), 70 + i)
                endif
                call Shop_Pista(p, "war3mapImported\\\\CuaHitIco.mdx", Pan_IcoX(1, i), Pan_IcoY(i), 80 + i)
                set i = i + 1
            endloop
        endif
        set p = p + 1
    endloop
endfunction

''')

# --- Cua_Construir: todo más abajo, sin pie, con paneles ---
cambia("""            set Cua_Bg[s] = Cua_Pic(Cua_PX(s), 425, 330, 540, 430, 'DS1S')
            set Cua_Bt[s] = Cua_Pic(Cua_PX(s), 645, 170, 56, 399, 'DS0A')""",
       """            set Cua_Bg[s] = Cua_Pic(Cua_PX(s), 480, 330, 540, 430, 'DS1S')
            set Cua_Bt[s] = Cua_Pic(Cua_PX(s), 700, 170, 56, 399, 'DS0A')""")
cambia("""            set Cua_Et[s] = Cua_Pic(Cua_PX(s) + 0.6, 643.1, 125.23, 31.38, 397, 'DSE8')""",
       """            set Cua_Et[s] = Cua_Pic(Cua_PX(s) + 0.6, 698.1, 125.23, 31.38, 397, 'DSE8')""")
cambia("""            set Cua_Cel[s] = Cua_Pic(Cua_PX(s), 278, 206, 206, 404, 'DS03')
            set Cua_Placa[s] = Cua_Pic(Cua_PX(s), 404, 300, 36, 412, 'DS06')
            set Cua_Caja[s] = Cua_Pic(Cua_PX(s), 511, 300, 150, 414, 'DS04')""",
       """            set Cua_Cel[s] = Cua_Pic(Cua_PX(s), 333, 206, 206, 404, 'DS03')
            set Cua_Placa[s] = Cua_Pic(Cua_PX(s), 459, 300, 36, 412, 'DS06')
            set Cua_Caja[s] = Cua_Pic(Cua_PX(s), 566, 300, 150, 414, 'DS04')""")
cambia("""            set Cua_AroA[s] = Cua_Aro(Cua_PX(s), 425, 428, 'ubjB')""",
       """            set Cua_AroA[s] = Cua_Aro(Cua_PX(s), 480, 428, 'ubjB')""")
cambia("""                    set Cua_Ico[p * 9 + s] = Cua_Pic(Cua_PX(s), 278, 190, 190, 405, 'DC00')
                    call Shop_Pista(p, "war3mapImported\\\\CuaHitBtn.mdx", Cua_PX(s), 645, 40 + s)""",
       """                    set Cua_Ico[p * 9 + s] = Cua_Pic(Cua_PX(s), 333, 190, 190, 405, 'DC00')
                    call Shop_Pista(p, "war3mapImported\\\\CuaHitBtn.mdx", Cua_PX(s), 700, 40 + s)""")
cambia("""            set Cua_Ico[s] = Cua_Pic(Cua_PX(Cua_Slot(n, c)), 278, 190, 190, 405, tex)""",
       """            set Cua_Ico[s] = Cua_Pic(Cua_PX(Cua_Slot(n, c)), 333, 190, 190, 405, tex)""")
cambia("""    set Cua_PieP = Cua_Pic(948.1, 748.4, 500.94, 62.76, 397, 'DSEB')
    // v19q: cabecera en el cuadro ancho de la tienda, con su burbuja.
    set Cua_CabP = Cua_Pic(960, 84, 760, 80, 420, 'DS0B')
    set Cua_CabA = Cua_Aro(960, 84, 428, 'ubjC')
""", """    // v19r: sin el pie ("Esc: salir…"); cabecera 12 px más abajo y paneles de mejoras.
    set Cua_CabP = Cua_Pic(960, 96, 760, 80, 420, 'DS0B')
    set Cua_CabA = Cua_Aro(960, 96, 428, 'ubjC')
    call Pan_Construir()
""")

# --- Cua_Hacer y Cua_Mostrar (sincronizados) ---
cambia("""        call Her_Aplicar(p, x, Her_Cal[Her_K(p, c / 2)])
""", """        call Her_Aplicar(p, x, Her_Cal[Her_K(p, c / 2)])
        call Pan_Registrar(p, x, Her_Cal[Her_K(p, c / 2)])
""")
cambia("""    call Fondo_Ver(p, 2, 4800., on)
""", """    call Fondo_Ver(p, 2, 4800., on)
    if on then
        call Pan_Ordenar()
    endif
""")

# --- textos locales del panel ---
cambia("""    set Cua_RelojT = Cua_Tag()
    set Cua_RelojVisto = ""
""", """    set Cua_RelojT = Cua_Tag()
    set Cua_RelojVisto = ""
    loop
        exitwhen i > 9
        set Pan_TT[i] = Cua_Tag()
        set i = i + 1
    endloop
    set i = 0
""")
cambia("""    set Cua_TCab = null
    set Cua_RelojT = null
""", """    set Cua_TCab = null
    set Cua_RelojT = null
    loop
        exitwhen i > 9
        call DestroyTextTag(Pan_TT[i])
        set Pan_TT[i] = null
        set i = i + 1
    endloop
    set i = 0
""")

# --- Cua_Ver ---
cambia("""    call SetUnitVertexColor(Cua_PieP, 255, 255, 255, a)
""", "")
cambia("""    call Cua_AroVer(Cua_CabA, a > 0, a, Her_R, Her_G, Her_B)
    if Cua_TCab == null or not ver then
""", """    call Cua_AroVer(Cua_CabA, a > 0, a, Her_R, Her_G, Her_B)
    call Pan_Ver(p, ver and inicio)
    if Cua_TCab == null or not ver then
""")
cambia("""    if Cua_TMut != null then
        call Cua_Izq(p, Cua_TMut, Cua_MutTxt(), 150, 140, 0.017)
        call SetTextTagVisibility(Cua_TMut, true)
    endif""", """    if Cua_TMut != null then
        if not inicio then
            call Cua_Izq(p, Cua_TMut, Cua_MutTxt(), 150, 140, 0.017)
        endif
        call SetTextTagVisibility(Cua_TMut, not inicio)
    endif""")
cambia("""Cua_InicioCab(p), 960, 67, 0.03)""", """Cua_InicioCab(p), 960, 77, 0.027)""")
cambia("""Cua_Cabecera(p), 960, 67, 0.03)""", """Cua_Cabecera(p), 960, 77, 0.027)""")
cambia('''        return "Tienda · primero, la mejora del jefe"''', '''        return "Tienda · primero, el jefe"''')
cambia('''        return "Tienda · ahora, las mejoras de tu héroe"''', '''        return "Tienda · ahora, tu héroe"''')
cambia("""Her_Nombre(p, c), Cua_PX(s), 385, 0.025)""", """Her_Nombre(p, c), Cua_PX(s), 440, 0.025)""")
cambia("""Cua_Nom[Cua_Item(p, c)], Cua_PX(s), 385, 0.025)""", """Cua_Nom[Cua_Item(p, c)], Cua_PX(s), 440, 0.025)""")
cambia("""Her_Des(p, c), Cua_PX(s) - 138, 473, 0.022)""", """Her_Des(p, c), Cua_PX(s) - 126, 559, 0.022)""")
cambia("""Cua_InicioDes(p, c), Cua_PX(s) - 138, 456, 0.022)""", """Cua_InicioDes(p, c), Cua_PX(s) - 126, 546, 0.022)""")
cambia("""Cua_VotosTxt(p, c), Cua_PX(s) - 138, 456, 0.022)""", """Cua_VotosTxt(p, c), Cua_PX(s) - 126, 546, 0.022)""")
assert 'set Cua_PieP' not in src and 'Cua_PieP,' not in src

if prueba:
    for viejo, nuevo in (('lat\\\\v19q-', 'lat\\\\v19r-'), ('v19q-don.txt', 'v19r-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19r', 'prueba' if prueba else 'normal')
