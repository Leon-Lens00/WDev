#!/usr/bin/env python3
"""v20b (20/11/2026): correcciones de la prueba de v20a (vídeo de Leon del 19/11, oleada 9 → 10).
- Pantalla de inicio sin textos al volver de la tienda de armas: en el vídeo, al salir con Esc a 7 s del final del
  descanso, los cuadros Armas / Mutación Evo / Habilidades quedaron sin nombre ni descripción unos 4 s; sí se veían
  las pestañas, "Mejoras de tu héroe" y el reloj. Son justo los 10 últimos texttags que crea Cua_Textos (Cua_TN y
  Cua_TD): el patrón del tope de 100 texttags por cliente, en el que CreateTextTag devuelve el id 0 y pisa otro sin
  error (medido en v14f). v20a añadió 8 texttags fijos al cuadro de resultados (15 en total, siempre creados).
  Ahora los 15 textos del cuadro de resultados sólo existen mientras se ve: se crean al preparar el recuento y se
  destruyen al terminar (como las tarjetas de racha, Racha_TTCrear / Racha_TTQuitar). Quedan 15 libres en el
  descanso y en la tienda.
- Cartas de técnica viejas en los pasos extra: todas las cartas del descanso se reparten al cerrar el resultado, así
  que un paso posterior podía ofrecer una técnica ya al máximo ("Ya está al máximo (nivel 3)") o con el nivel viejo,
  o repetir la carta rara ya aprendida. Al abrir cada paso (4 en adelante) se revisan sus cartas: técnica al máximo
  o repetida, otra técnica disponible al azar o, si no queda, una carta común de la calidad del paso; el nivel de las
  técnicas se pone al día.
- Puntos de la oleada: el daño pesaba demasiado (241 580 de daño = 1610 puntos frente a 221 bajas). Daño / 1000.
- Aviso al empezar la oleada: "Mejoras del héroe:" (quitado "(aún sin efecto)", que ya no es cierto).
- Prueba: el diagnóstico de cuadros anota los ids de sus texttags (los repetidos o 0 delatan el tope) y se lanza
  también al ir a la tienda y al volver de ella.
Uso: v20b.py ENTRADA.j SALIDA.j [prueba]   (normal de v20a; prueba de v20a-prueba)
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


# --- 1. textos del cuadro de resultados sólo mientras se ve ---
cambia('''        set Punt_TT[p * 16 + k] = s__UIText_createEx(Player(p), 0., 0., 1.)
        call SetTextTagPermanent(s__UIText_text[Punt_TT[p * 16 + k]], true)
        call JefeTx_Color(Punt_TT[p * 16 + k], s__UIText_text[Punt_TT[p * 16 + k]], 240, 238, 232)
        set k = k + 1
    endloop
    call JefeTx_Color(Punt_TT[p * 16 + 7], s__UIText_text[Punt_TT[p * 16 + 7]], 255, 220, 140)
    set Punt_Visto[p] = 0
    set Punt_Ok[p] = true
endfunction
''', '''        set Punt_TT[p * 16 + k] = s__UIText_createEx(Player(p), 0., 0., 1.)
        // v20b: el texttag se suelta en seguida; Punt_TxPoner lo crea al preparar el recuento.
        call Racha_TTQuitar(Punt_TT[p * 16 + k])
        set k = k + 1
    endloop
    set Punt_Visto[p] = 0
    set Punt_Ok[p] = true
endfunction

// v20b: los 15 textos del cuadro de resultados existen sólo mientras se ve (tope de 100 texttags por cliente).
function Punt_TxPoner takes nothing returns nothing
    local integer p = 0
    local integer k
    local integer ui
    loop
        exitwhen p > 11
        if Punt_Ok[p] then
            set k = 0
            loop
                exitwhen k > 14
                set ui = Punt_TT[p * 16 + k]
                call Racha_TTCrear(p, ui)
                if k == 7 then
                    call JefeTx_Color(ui, s__UIText_text[ui], 255, 220, 140)
                else
                    call JefeTx_Color(ui, s__UIText_text[ui], 240, 238, 232)
                endif
                set k = k + 1
            endloop
            set Punt_Visto[p] = -1
        endif
        set p = p + 1
    endloop
endfunction

function Punt_TxQuitar takes nothing returns nothing
    local integer p = 0
    local integer k
    loop
        exitwhen p > 11
        if Punt_Ok[p] then
            set k = 0
            loop
                exitwhen k > 14
                call s__UIText_show(Punt_TT[p * 16 + k], false, -1)
                call Racha_TTQuitar(Punt_TT[p * 16 + k])
                set k = k + 1
            endloop
        endif
        set p = p + 1
    endloop
endfunction
''')
cambia('''    if Punt_T >= Punt_Sale + 0.5 then
        set Punt_T = -1.
        call Punt_BucleFin()
''', '''    if Punt_T >= Punt_Sale + 0.5 then
        set Punt_T = -1.
        call Punt_TxQuitar()
        call Punt_BucleFin()
''')
cambia('''    set Punt_ColO = ""
    set q = 0
''', '''    set Punt_ColO = ""
    call Punt_TxPoner()
    set q = 0
''')
cambia('''    set Punt_T = -1.
    call Punt_BucleFin()
    call Punt_Reiniciar()
''', '''    set Punt_T = -1.
    call Punt_TxQuitar()
    call Punt_BucleFin()
    call Punt_Reiniciar()
''')

# --- 2. cartas de cada paso al día al abrirlo ---
cambia('''// v18y: al cerrarse el cuadro de resultados (Ronda_DescansoEmpezar, por nombre): suerte, refrescos y cartas.
function Her_Sortear takes nothing returns nothing''', '''// v20b: x ya está entre las 4 cartas que empiezan en k.
function Her_EnMano takes integer k, integer x returns boolean
    return Cua_HCand[k] == x or Cua_HCand[k + 1] == x or Cua_HCand[k + 2] == x or Cua_HCand[k + 3] == x
endfunction

// v20b: al abrir un paso (4 en adelante) sus cartas, repartidas al empezar el descanso, se ponen al día: técnica al
// máximo o repetida de una carta anterior del paso, otra técnica disponible al azar o, si no queda, una carta común
// de la calidad del paso; carta rara ya aprendida, una común. El nivel de las técnicas se actualiza.
function Her_AlDia takes integer p returns nothing
    local integer array l
    local integer k
    local integer i = 0
    local integer j
    local integer x
    local integer y
    local integer n
    local integer minq = -1
    local boolean mal
    if Cua_Paso[p] < 4 or Cua_Paso[p] >= Her_FinDe(p) then
        return
    endif
    set k = Her_K(p, 0)
    if Cua_Paso[p] >= 5 then
        set minq = Her_ExMin[p * 8 + Cua_Paso[p] - 5]
    endif
    loop
        exitwhen i > 3
        set x = Cua_HCand[k + i]
        set mal = x == 85 and Rara_Rs[p]
        if Tec_Max[x] > 0 then
            set mal = Tec_Niv[p * 100 + x] >= Tec_Max[x]
            set j = 0
            loop
                exitwhen j >= i
                set mal = mal or Cua_HCand[k + j] == x
                set j = j + 1
            endloop
        endif
        if mal then
            set n = 0
            if Tec_Max[x] > 0 then
                call Tec_Rango(p)
                set y = Tec_A
                loop
                    exitwhen y >= Tec_A + Tec_N
                    if Tec_Niv[p * 100 + y] < Tec_Max[y] and not Her_EnMano(k, y) then
                        set l[n] = y
                        set n = n + 1
                    endif
                    set y = y + 1
                endloop
            endif
            if n > 0 then
                set x = l[GetRandomInt(0, n - 1)]
                set Cua_HCand[k + i] = x
                set Her_Cal[k + i] = IMinBJ(4, Tec_Niv[p * 100 + x])
            else
                loop
                    set x = Her_Pool[GetRandomInt(0, 9)]
                    exitwhen not Her_EnMano(k, x)
                endloop
                set Cua_HCand[k + i] = x
                set Her_Tipo[k + i] = Arm_TipoAzar(p, x)
                if minq >= 0 then
                    set Her_Cal[k + i] = IMaxBJ(minq, Her_TiraCalBruto(p))
                else
                    set Her_Cal[k + i] = Her_TiraCal(p)
                endif
            endif
        elseif Tec_Max[x] > 0 then
            set Her_Cal[k + i] = IMinBJ(4, Tec_Niv[p * 100 + x])
        endif
        set i = i + 1
    endloop
endfunction

// v18y: al cerrarse el cuadro de resultados (Ronda_DescansoEmpezar, por nombre): suerte, refrescos y cartas.
function Her_Sortear takes nothing returns nothing''')
cambia('''    set Cua_Paso[p] = Cua_Paso[p] + 1
    // v18m: al terminar''', '''    set Cua_Paso[p] = Cua_Paso[p] + 1
    call Her_AlDia(p)
    // v18m: al terminar''')

# --- 3. puntos: daño / 1000 ---
cambia('R2I(Mvp_Dano[q] / 150.)', 'R2I(Mvp_Dano[q] / 1000.)')

# --- 4. aviso de la oleada ---
cambia('"Mejoras del héroe (aún sin efecto): "', '"Mejoras del héroe: "')

if prueba:
    cambia('''        set t = t + " cab=" + Cua_B(Cua_TCab != null) + " tags=" + I2S(Shop_TzN)
    endif''', '''        set t = t + " cab=" + Cua_B(Cua_TCab != null) + " tags=" + I2S(Shop_TzN)
        // v20b-prueba: ids de los texttags de los cuadros (repetidos o 0: tope de 100).
        set t = t + " ids " + I2S(GetHandleId(Cua_TCab)) + " " + I2S(GetHandleId(Cua_TMut)) + " " + I2S(GetHandleId(Cua_RelojT)) + " pan"
        set s = 0
        loop
            exitwhen s > 9
            set t = t + " " + I2S(GetHandleId(Pan_TT[s]))
            set s = s + 1
        endloop
        set t = t + " nd"
        set s = 0
        loop
            exitwhen s > 4
            set t = t + " " + I2S(GetHandleId(Cua_TN[s])) + "/" + I2S(GetHandleId(Cua_TD[s]))
            set s = s + 1
        endloop
        if Shop_TzN > 0 then
            set t = t + " tienda " + I2S(GetHandleId(Shop_Tz[0])) + ".." + I2S(GetHandleId(Shop_Tz[Shop_TzN - 1]))
        endif
    endif''')
    # Esc desde la tienda a la pantalla de inicio y de ella a la tienda.
    cambia('''    set Cua_Open[p] = true
    call Shop_Camara(p)
    call Cua_Pintar(p)
    call Cua_Mostrar(p, true)
endfunction''', '''    set Cua_Open[p] = true
    call Shop_Camara(p)
    call Cua_Pintar(p)
    call Cua_Mostrar(p, true)
    call Cua_Diag(p)
endfunction''')
    cambia('''    call Shop_Mostrar(p, true)
    call Shop_Refrescar(p)
endfunction

// v18m: clic en un cuadro''', '''    call Shop_Mostrar(p, true)
    call Shop_Refrescar(p)
    call Cua_Diag(p)
endfunction

// v18m: clic en un cuadro''')
    for viejo, nuevo in (('lat\\\\v20a-', 'lat\\\\v20b-'), ('v20a-don.txt', 'v20b-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20b', 'prueba' if prueba else 'normal')
