#!/usr/bin/env python3
"""v19m (19/11/2026). Leon eligió "Todo lo propuesto" para el acabado visual de Mutación Evo y las mejoras del héroe:
- Marco por pantalla (CuaMarco, 'DS1Q', sobre el fondo de cada carta): rojo en la mejora del jefe (Mutación Evo y su
  resultado), dorado en las mejoras del héroe; sin marco en la pantalla de inicio.
- Banda de tipo encima de cada carta (CuaBanda, 'DS1P'): roja en las mutaciones; en las del héroe gris estadística,
  oro economía, morada maldita, verde purga, celeste técnica. La etiqueta de texto de v19l se conserva.
- Cabecera con banda (CuaCabecera, 'DS1R') y título por pantalla: "MEJORA DEL JEFE · …" / "TU HÉROE · …"; en la
  pantalla de inicio dice qué toca (primero el jefe, ahora tu héroe) con el color de esa fase.
- Al elegir: la carta elegida se ilumina (marco blanco) y las otras se oscurecen 0,3 s; después se aplica la elección
  (Cua_Hacer). Clics durante el destello no cuentan.
- Panel "Mutaciones activas" bajo la cabecera con su número (×2, ×3), por color de grupo (jefe, élites, comunes).
- Carta Purga (39, icono 'DM08'): 15 % en la 4.ª carta del héroe si no salió maldita y hay alguna mutación de élites o
  comunes; quita una al azar (las del jefe no se purgan) y lo avisa a todos.
Uso: v19m.py ENTRADA.j SALIDA.j [prueba]   (normal de v19l; prueba de v19l-prueba)
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


cambia('integer array Cua_IcoTex\n', 'integer array Cua_IcoTex\n'
       'unit array Cua_Marco\nunit array Cua_Banda\nunit Cua_CabP = null\ntexttag Cua_TMut = null\n'
       'integer array Cua_Fla\ninteger array Cua_FlaS\ninteger array Cua_FlaPaso\ntimer array Cua_FlaT\n')

# --- piezas ---
cambia("""            set Cua_Et[s] = Cua_Pic(Cua_PX(s) + 0.6, 608.1, 125.23, 31.38, 397, 'DSE8')
""", """            set Cua_Et[s] = Cua_Pic(Cua_PX(s) + 0.6, 608.1, 125.23, 31.38, 397, 'DSE8')
            // v19m: marco de la pantalla y banda del tipo de carta (texturas claras, se tiñen en Cua_Ver).
            set Cua_Marco[s] = Cua_Pic(Cua_PX(s), 410, 330, 480, 428, 'DS1Q')
            set Cua_Banda[s] = Cua_Pic(Cua_PX(s), 168, 300, 22, 415, 'DS1P')
""")
cambia("""    set Cua_PieP = Cua_Pic(948.1, 722.4, 500.94, 62.76, 397, 'DSEB')
""", """    set Cua_PieP = Cua_Pic(948.1, 722.4, 500.94, 62.76, 397, 'DSEB')
    set Cua_CabP = Cua_Pic(960, 66, 1000, 64, 420, 'DS1R')
""")
cambia('''    set Cua_TCab = Cua_Tag()
''', '''    set Cua_TCab = Cua_Tag()
    set Cua_TMut = Cua_Tag()
''')
cambia('''    call DestroyTextTag(Cua_TCab)
''', '''    call DestroyTextTag(Cua_TCab)
    call DestroyTextTag(Cua_TMut)
    set Cua_TMut = null
''')

# --- helpers (antes de Her_Valor) ---
antes('function Her_Valor takes integer x, integer q returns integer\n', '''// v19m: color de la banda de tipo (Her_R/G/B) de la carta del héroe x.
function Her_TipoColor takes integer x returns nothing
    set Her_R = 190
    set Her_G = 195
    set Her_B = 205
    if x >= 40 then
        set Her_R = 80
        set Her_G = 200
        set Her_B = 255
    elseif x == 39 then
        set Her_R = 90
        set Her_G = 230
        set Her_B = 150
    elseif Her_EsMaldita(x) then
        set Her_R = 200
        set Her_G = 80
        set Her_B = 230
    elseif x == 18 or x == 19 or x == 26 or x == 37 or x == 38 then
        set Her_R = 255
        set Her_G = 200
        set Her_B = 0
    endif
endfunction

// v19m: mutaciones que se pueden purgar (élites 4-7 y comunes 8-17; las del jefe 0-3 no).
function Mut_Purgables takes nothing returns integer
    local integer x = 4
    local integer n = 0
    loop
        exitwhen x > 17
        if Cua_Activa[x] > 0 then
            set n = n + 1
        endif
        set x = x + 1
    endloop
    return n
endfunction

function Mut_Purgar takes nothing returns nothing
    local integer array l
    local integer n = 0
    local integer x = 4
    loop
        exitwhen x > 17
        if Cua_Activa[x] > 0 then
            set l[n] = x
            set n = n + 1
        endif
        set x = x + 1
    endloop
    if n == 0 then
        return
    endif
    set x = l[GetRandomInt(0, n - 1)]
    set Cua_Activa[x] = Cua_Activa[x] - 1
    set Cua_ActN = IMaxBJ(0, Cua_ActN - 1)
    call DisplayTimedTextToForce(GetPlayersAll(), 6., "|cff9cffb0Purga|r: se quita " + Cua_Nom[x] + ".")
endfunction

// v19m: panel de mutaciones activas (jefe rojo, élites naranja, comunes claro).
function Cua_MutTxt takes nothing returns string
    local integer x = 0
    local integer n = 0
    local string s = ""
    local string col
    loop
        exitwhen x > 17
        if Cua_Activa[x] > 0 then
            if n > 0 and ModuloInteger(n, 6) == 0 then
                set s = s + "|n"
            elseif n > 0 then
                set s = s + "   "
            endif
            set col = "|cffe8e8e8"
            if x < 4 then
                set col = "|cffff6070"
            elseif x < 8 then
                set col = "|cffffa040"
            endif
            set s = s + col + Cua_Nom[x] + "|r"
            if Cua_Activa[x] > 1 then
                set s = s + " |cffffcc00×" + I2S(Cua_Activa[x]) + "|r"
            endif
            set n = n + 1
        endif
        set x = x + 1
    endloop
    if n == 0 then
        return "|cff909090Mutaciones activas: ninguna.|r"
    endif
    return "|cffff7080Mutaciones activas:|r   " + s
endfunction

''')
# purga como carta
cambia('''    if GetRandomInt(1, 100) <= 12 and Her_Maldita(p) > 0 then
        set Cua_HCand[k + 3] = Her_Maldita(p)
        set Her_Cal[k + 3] = 0
    endif
''', '''    if GetRandomInt(1, 100) <= 12 and Her_Maldita(p) > 0 then
        set Cua_HCand[k + 3] = Her_Maldita(p)
        set Her_Cal[k + 3] = 0
    elseif Mut_Purgables() > 0 and GetRandomInt(1, 100) <= 15 then
        set Cua_HCand[k + 3] = 39
        set Her_Cal[k + 3] = 0
    endif
''')
cambia('''        if Her_Cal[k + i] >= 3 and not Her_EsMaldita(Cua_HCand[k + i]) and Cua_HCand[k + i] < 40 then''',
       '''        if Her_Cal[k + i] >= 3 and not Her_EsMaldita(Cua_HCand[k + i]) and Cua_HCand[k + i] < 39 then''')
cambia('''    if x >= 40 then
        return "|cff60e0ffTécnica|r|n"
''', '''    if x >= 40 then
        return "|cff60e0ffTécnica|r|n"
    elseif x == 39 then
        return "|cff9cffb0Purga|r|n"
''')
cambia('''    if x != 28 and Her_EsMaldita(x) then
        return Her_Etiqueta(x) + Cua_Des[x]''', '''    if x == 39 or (x != 28 and Her_EsMaldita(x)) then
        return Her_Etiqueta(x) + Cua_Des[x]''')
cambia('''    if Her_EsMaldita(Cua_HCand[Her_K(p, c)]) then
        set Her_R = 95''', '''    if Cua_HCand[Her_K(p, c)] == 39 then
        set Her_R = 35
        set Her_G = 150
        set Her_B = 100
        return
    endif
    if Her_EsMaldita(Cua_HCand[Her_K(p, c)]) then
        set Her_R = 95''')
cambia('''    elseif x >= 40 then
        call Tec_Aprender(p, x)
    endif
''', '''    elseif x == 39 then
        call Mut_Purgar()
    elseif x >= 40 then
        call Tec_Aprender(p, x)
    endif
''')
antes("    set Tec_Puente[40] = 'AGk3'\n", '''    set Cua_Nom[39] = "Purga"
    set Cua_Des[39] = "Quita una Mutación Evo|nde élites o comunes."
    set Cua_Tex[39] = 'DM08'
''')

# --- cabeceras ---
cambia('''    if Cua_Modo[p] == 2 then
        return "Mutación Evo · oleada " + I2S(Ronda_Numero + 1)
    endif
    if Cua_Paso[p] >= 3 and Cua_Paso[p] < 5 then
        return Cua_PasoNom[Cua_Paso[p]] + " · suerte " + I2S(Her_Suerte[p])
    endif
    return Cua_PasoNom[Cua_Paso[p]]
endfunction
''', '''    if Cua_Modo[p] == 2 then
        return "MEJORA DEL JEFE · Mutación Evo · oleada " + I2S(Ronda_Numero + 1)
    endif
    if Cua_Paso[p] >= 3 and Cua_Paso[p] < 5 then
        return "TU HÉROE · " + Cua_PasoNom[Cua_Paso[p]] + " · suerte " + I2S(Her_Suerte[p])
    endif
    if Cua_Paso[p] < 3 then
        return "MEJORA DEL JEFE · " + Cua_PasoNom[Cua_Paso[p]]
    endif
    return Cua_PasoNom[Cua_Paso[p]]
endfunction

// v19m: título de la pantalla de inicio según lo que falta, con su color en Her_R/G/B.
function Cua_InicioCab takes integer p returns string
    if Cua_Paso[p] < 3 then
        set Her_R = 255
        set Her_G = 90
        set Her_B = 100
        return "Tienda · primero, la mejora del jefe"
    elseif Cua_Paso[p] < 5 then
        set Her_R = 255
        set Her_G = 210
        set Her_B = 90
        return "Tienda · ahora, las mejoras de tu héroe"
    endif
    set Her_R = 240
    set Her_G = 238
    set Her_B = 232
    return Cua_PasoNom[5]
endfunction
''')

# --- Cua_Ver ---
cambia('''    local integer sinBoton = 1
    if Cua_Modo[p] == 2 then
        set sinBoton = 0
    endif
''', '''    local integer sinBoton = 1
    local integer k
    local integer fa
    local integer ba
    local integer fr = 255
    local integer fg = 200
    local integer fb = 60
    if Cua_Modo[p] == 2 then
        set sinBoton = 0
    endif
''')
cambia('''            call SetUnitVertexColor(Cua_Ico[p * 9 + s], ic, ic, ic, a)
        endif
        set s = s + 1
    endloop
''', '''            call SetUnitVertexColor(Cua_Ico[p * 9 + s], ic, ic, ic, a)
            // v19m: marco de la pantalla, banda del tipo y destello de la carta elegida.
            set k = (s - (5 - n)) / 2
            set fa = 0
            set ba = 0
            if a > 0 and not inicio then
                set fa = a
                if Cua_Modo[p] == 1 and Cua_Paso[p] >= 3 then
                    set fr = 255
                    set fg = 200
                    set fb = 60
                    if k < 4 then
                        call Her_TipoColor(Cua_HCand[Her_K(p, k)])
                        set ba = a
                    endif
                else
                    set fr = 230
                    set fg = 50
                    set fb = 60
                    set Her_R = 235
                    set Her_G = 60
                    set Her_B = 60
                    set ba = a
                endif
                if Cua_Fla[p] > 0 then
                    if k == Cua_Fla[p] - 1 then
                        set fr = 255
                        set fg = 255
                        set fb = 255
                    else
                        set fa = fa * 30 / 100
                        set ba = ba * 30 / 100
                        call SetUnitVertexColor(Cua_Bg[s], r * 35 / 100, g * 35 / 100, b * 35 / 100, a)
                        call SetUnitVertexColor(Cua_Ico[p * 9 + s], 90, 90, 90, a)
                    endif
                endif
            endif
            call SetUnitVertexColor(Cua_Marco[s], fr, fg, fb, fa)
            call SetUnitVertexColor(Cua_Banda[s], Her_R, Her_G, Her_B, ba)
        endif
        set s = s + 1
    endloop
''')
cambia('''    call SetUnitVertexColor(Cua_PieP, 255, 255, 255, a)
    if Cua_TCab == null or not ver then
        return
    endif
    if inicio then
        call Cua_Centro(p, Cua_TCab, Cua_PasoNom[5], 960, 70, 0.03)
        call SetTextTagColor(Cua_TCab, 240, 238, 232, 255)
    else''', '''    call SetUnitVertexColor(Cua_PieP, 255, 255, 255, a)
    // v19m: banda de la cabecera con el color de la pantalla.
    if inicio then
        call Cua_InicioCab(p)
        if Cua_Paso[p] >= 5 then
            set Her_R = 90
            set Her_G = 130
            set Her_B = 220
        endif
    elseif Cua_Modo[p] == 1 and Cua_Paso[p] >= 3 then
        set Her_R = 235
        set Her_G = 175
        set Her_B = 40
    else
        set Her_R = 200
        set Her_G = 35
        set Her_B = 50
    endif
    call SetUnitVertexColor(Cua_CabP, Her_R, Her_G, Her_B, a)
    if Cua_TCab == null or not ver then
        return
    endif
    if Cua_TMut != null then
        call Cua_Izq(p, Cua_TMut, Cua_MutTxt(), 150, 140, 0.017)
        call SetTextTagVisibility(Cua_TMut, true)
    endif
    if inicio then
        call Cua_Centro(p, Cua_TCab, Cua_InicioCab(p), 960, 70, 0.03)
        call SetTextTagColor(Cua_TCab, Her_R, Her_G, Her_B, 255)
    else''')

# --- elección con destello: Cua_Clic valida y enciende; Cua_Hacer aplica a los 0,3 s ---
i = src.index('function Cua_Clic takes integer p, integer s returns nothing\n')
j = src.index('\nendfunction\n', i) + len('\nendfunction\n')
f = src[i:j]
corte = '    call UI_Click(p)\n    set Cua_Elegido[p * 5 + Cua_Paso[p]] = x\n'
assert f.count(corte) == 1
cab, resto = f.split(corte)
hacer = ('// v19m: aplica la elección de la carta en la posición s (tras el destello).\n'
         'function Cua_Hacer takes integer p, integer s returns nothing\n'
         '    local integer n = Cua_Cuantos(p)\n    local integer c = s - (5 - n)\n'
         '    local integer x = Cua_Item(p, c / 2)\n    local integer q = 0\n'
         '    set Cua_Elegido[p * 5 + Cua_Paso[p]] = x\n' + resto)
fin = U('''function Cua_FlaFin takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer p = 0
    loop
        exitwhen p > 11 or Cua_FlaT[p] == t
        set p = p + 1
    endloop
    set t = null
    if p > 11 then
        return
    endif
    set Cua_Fla[p] = 0
    if Cua_Open[p] and Cua_Modo[p] == 1 and Cua_Paso[p] == Cua_FlaPaso[p] then
        call Cua_Hacer(p, Cua_FlaS[p])
    elseif Cua_Open[p] then
        call Cua_Ver(p)
    endif
endfunction

''')
clic = cab.replace('    local integer q = 0\n', '') + U('''    if Cua_Fla[p] > 0 then
        return
    endif
    call UI_Click(p)
    if Cua_FlaT[p] == null then
        set Cua_FlaT[p] = CreateTimer()
    endif
    set Cua_Fla[p] = c / 2 + 1
    set Cua_FlaS[p] = s
    set Cua_FlaPaso[p] = Cua_Paso[p]
    call Cua_Ver(p)
    call TimerStart(Cua_FlaT[p], 0.3, false, function Cua_FlaFin)
endfunction
''')
assert 'local integer q' in f and 'set q = q + 1' in resto
# los refrescos del héroe no pasan por el destello, pero tampoco durante uno
clic = clic.replace(U('''    if Cua_Paso[p] >= 3 and c / 2 == 4 then
        call Her_Refrescar(p)'''), U('''    if Cua_Paso[p] >= 3 and c / 2 == 4 then
        if Cua_Fla[p] > 0 then
            return
        endif
        call Her_Refrescar(p)'''))
assert clic.count('Cua_Fla[p] > 0') == 2
src = src[:i] + hacer + '\n' + fin + clic + src[j:]

if prueba:
    for viejo, nuevo in (('lat\\\\v19l-', 'lat\\\\v19m-'), ('v19l-don.txt', 'v19m-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19m', 'prueba' if prueba else 'normal')
