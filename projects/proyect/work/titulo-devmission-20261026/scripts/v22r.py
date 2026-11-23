#!/usr/bin/env python3
"""v22r (23/11/2026): cartas con nivel máximo que no se repiten, bonificaciones sin tope de relleno y fuera el texto de
mutaciones en Armas y Habilidades.

Leon tras evaluar la tienda de barajas: "la mejora tomada ya no vuelve a salir, a menos que tenga niveles maximos ...
con los boss o mutacion evo tambien"; el texto superior de Armas y Habilidades sobra (el panel del menú ya lo muestra).
Al aceptar: "un tier alto puede dar una bonificacion independiente del que tienes niveles ... en caso de no haber
cartas ... seria una bonificacion infinita pero en baja proporcion ... para vida danio y demas".
- Texto "Mutaciones activas" (Cua_TMut): sólo en la votación de Mutación Evo y en la muestra; fuera en Armas y en los
  pasos del héroe.
- Niveles máximos (Car_Max; cuenta por jugador en Car_Tom y, por categoría de arma, en Car_TomC):
  héroe Vitalidad 5, Zancada 4, Botín 4, Evasión 5, Reembolso 3, Imán 3, Interés 3, Bolsa doble 3 (dash y linterna
  siguen con sus topes); armas Filo 5, Golpe de suerte 4, Vida extra 3, Calibre 4 y Cargador ágil 3 por categoría.
  Una carta al máximo no sale en ninguna mano (también al poner al día las manos guardadas y las compradas).
  La calidad (T1-T5) sigue marcando el valor de cada nivel.
- Bonificaciones sin tope, con valor bajo según la calidad; sólo salen si faltan cartas: héroe Fortaleza (105, vida),
  Paso ligero (106, velocidad), Fortuna (107, oro de bolsas), Recolector (110, radio de bolsas); armas Afilado (108,
  daño de las armas) y Calibre menor (109, daño de una categoría). Ya no se rellena con Vida extra.
- Mutación Evo: cada mutación hasta 3 niveles; al máximo deja de salir mientras su grupo tenga otras; con menos
  candidatas, menos cuadros. Pacto mutante elige una mutación que no esté al máximo.
- Las cartas muestran "Nivel n/máx" (o "Sin tope") y las mutaciones ya activas su nivel.
- Prueba: registro "carta jP X nivel N/M" al tomar cada carta con tope.
Uso: v22r.py ENTRADA.j SALIDA.j [prueba]   (normal de v22q; prueba de v22q-prueba).
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


# 0) Globales.
cambia('integer Her_TipoSel = 0\n', '''integer Her_TipoSel = 0
// v22r: nivel máximo de cada carta (0 = sin tope), veces tomada por jugador (p * 200 + x) y, para las cartas de una
// categoría de arma (Car_S = hueco + 1), por categoría (p * 56 + e * 8 + hueco). Mut_Tope: tope de la mutación al
// sortear (3, o 99 si su grupo ya está entero al máximo).
integer array Car_Max
integer array Car_S
integer array Car_Tom
integer array Car_TomC
integer Mut_Tope = 3
''')

# 1) Funciones base, antes de Arm_TipoAzar (sólo usan globales).
LOG = ('''    set Cop_Log = "carta j" + I2S(p) + " " + Cua_Nom[x] + " nivel " + I2S(n) + "/" + I2S(Car_Max[x])
    call ExecuteFunc("Cop_Anotar")
''' if prueba else '')
cambia('// v19y: categoría al azar entre las que tiene p (Cargador ágil, 84, sin cuerpo a cuerpo); -1 si no hay.\n', '''// v22r: la carta x (categoría e, -1 si aún no se sabe) puede salir para p: dash y linterna por su estado; las demás
// mientras no lleguen a Car_Max.
function Car_Disp takes integer p, integer x, integer e returns boolean
    if x == 24 then
        return Dash_Extra[p] < 2
    elseif x == 25 then
        return Dash_RecRed[p] < 0.41
    elseif x == 78 then
        return Dash_DistB[p] < 0.355
    elseif x == 79 then
        return Dash_DurB[p] < 0.295
    elseif x == 81 then
        return Bat_Limitada[p] and Bat_Pilas[p] < 3
    elseif x == 82 then
        return Bat_Limitada[p] and Bat_Rapida[p] < 2
    elseif Car_S[x] > 0 then
        if e < 0 or e > 6 then
            return true
        endif
        return Car_TomC[p * 56 + e * 8 + Car_S[x] - 1] < Car_Max[x]
    elseif Car_Max[x] > 0 then
        return Car_Tom[p * 200 + x] < Car_Max[x]
    endif
    return true
endfunction

// v22r: p tomó la carta x (categoría e): un nivel más.
function Car_Contar takes integer p, integer x, integer e returns nothing
    local integer n = 0
    if Car_S[x] > 0 then
        if e < 0 or e > 6 then
            set e = 1
        endif
        set Car_TomC[p * 56 + e * 8 + Car_S[x] - 1] = Car_TomC[p * 56 + e * 8 + Car_S[x] - 1] + 1
        set n = Car_TomC[p * 56 + e * 8 + Car_S[x] - 1]
    elseif Car_Max[x] > 0 then
        set Car_Tom[p * 200 + x] = Car_Tom[p * 200 + x] + 1
        set n = Car_Tom[p * 200 + x]
    else
        return
    endif
''' + LOG + '''endfunction

// v22r: bonificación sin tope (105-110).
function Car_EsInf takes integer x returns boolean
    return x >= 105 and x <= 110
endfunction

// v22r: Filo si aún puede subir; si no, Afilado.
function Car_Filo takes integer p returns integer
    if Car_Disp(p, 20, -1) then
        return 20
    endif
    return 108
endfunction

// v22r: carta del dash que no esté al máximo, al azar (0 si ninguna).
function Dash_Libre takes integer p returns integer
    local integer array l
    local integer n = 0
    local integer x = 0
    loop
        exitwhen x > 3
        if Car_Disp(p, Dash_Ids(x), -1) then
            set l[n] = Dash_Ids(x)
            set n = n + 1
        endif
        set x = x + 1
    endloop
    if n == 0 then
        return 0
    endif
    return l[GetRandomInt(0, n - 1)]
endfunction

// v22r: carta de la linterna (sólo con el pacto) que no esté al máximo (0 si ninguna).
function Bat_Libre takes integer p returns integer
    if Car_Disp(p, 81, -1) and (not Car_Disp(p, 82, -1) or GetRandomInt(0, 1) == 0) then
        return 81
    elseif Car_Disp(p, 82, -1) then
        return 82
    endif
    return 0
endfunction

// v22r: carta del héroe para el hueco i de la mano que empieza en k: de la baraja (Her_Pool) sin las que están al
// máximo ni las i primeras de la mano; si no queda ninguna, una bonificación sin tope que no esté en la mano.
function Car_Heroe takes integer p, integer k, integer i returns integer
    local integer array l
    local integer n = 0
    local integer c = 0
    local integer x
    local integer j
    local boolean rep
    loop
        exitwhen c > 13
        if c <= 9 then
            set x = Her_Pool[c]
            if x == 24 then
                set x = Dash_Libre(p)
            elseif x == 81 then
                set x = Bat_Libre(p)
            elseif not Car_Disp(p, x, -1) then
                set x = 0
            endif
        elseif n > 0 then
            set x = 0
        elseif c == 13 then
            set x = 110
        else
            set x = 95 + c
        endif
        if x > 0 then
            set rep = false
            set j = 0
            loop
                exitwhen j >= i
                set rep = rep or Cua_HCand[k + j] == x
                set j = j + 1
            endloop
            if not rep then
                set l[n] = x
                set n = n + 1
            endif
        endif
        set c = c + 1
    endloop
    if n == 0 then
        return 105
    endif
    return l[GetRandomInt(0, n - 1)]
endfunction

// v22r: mutación al azar que no esté al máximo (Pacto mutante); si todas lo están, cualquiera.
function Car_MutLibre takes nothing returns integer
    local integer e = GetRandomInt(0, 17)
    local integer t = 0
    loop
        exitwhen Cua_Activa[e] < 3 or t >= 40
        set e = GetRandomInt(0, 17)
        set t = t + 1
    endloop
    return e
endfunction

// v22r: descripción de una bonificación sin tope de valor v (en el panel, sin la categoría de Calibre menor).
function Car_InfDes takes integer x, integer v, boolean panel returns string
    if x == 105 then
        return "+" + I2S(v) + " de vida|nmáxima."
    elseif x == 106 then
        return "+" + I2S(v) + " de velocidad|nde movimiento."
    elseif x == 107 then
        return "+" + I2S(v) + " % de oro|nde las bolsas."
    elseif x == 108 then
        return "+" + I2S(v) + " % de daño|nde tus armas."
    elseif x == 109 and panel then
        return "+" + I2S(v) + " % de daño de|nuna categoría de arma."
    elseif x == 109 then
        return "+" + I2S(v) + " % de daño|nde " + Her_TipoTxt + "."
    endif
    return "+" + I2S(v) + " de radio para|ncoger bolsas."
endfunction

// v19y: categoría al azar entre las que tiene p (Cargador ágil, 84, sin cuerpo a cuerpo); -1 si no hay.
''')
# Dash_Ids: los 4 del dash en orden (función, para no declarar otro array).
cambia('function Car_Disp takes integer p, integer x, integer e returns boolean\n', '''function Dash_Ids takes integer i returns integer
    if i == 0 then
        return 24
    elseif i == 1 then
        return 25
    elseif i == 2 then
        return 78
    endif
    return 79
endfunction

function Car_Disp takes integer p, integer x, integer e returns boolean
''')
# Categorías: sin las que ya tienen la carta al máximo.
cambia('        if Arm_Tier[p * 7 + c] > 0 and not (x == 84 and c == 5) then\n',
       '        // v22r: sin las categorías con la carta al máximo.\n'
       '        if Arm_Tier[p * 7 + c] > 0 and not (x == 84 and c == 5) and Car_Disp(p, x, c) then\n')

# 2) Mano del héroe.
cambia('''        loop
            set x = Her_Pool[GetRandomInt(0, 9)]
            if x == 24 then
                set x = Dash_Carta(p)
            elseif x == 81 then
                set x = Bat_Carta(p)
            elseif x == 83 or x == 84 then
                set x = Arm_Carta(p, x)
            endif
            set rep = false
            set j = 0
            loop
                exitwhen j >= i
                set rep = rep or Cua_HCand[k + j] == x
                set j = j + 1
            endloop
            exitwhen not rep
        endloop
        set Cua_HCand[k + i] = x
''', '''        // v22r: sin cartas al máximo; bonificación sin tope si no quedan.
        set x = Car_Heroe(p, k, i)
        set Cua_HCand[k + i] = x
''')
cambia('''            loop
                set x = Her_Pool[GetRandomInt(0, 7)]
                set j = 0
                loop
                    exitwhen j > 3 or Cua_HCand[k + j] == x
                    set j = j + 1
                endloop
                exitwhen j > 3
            endloop
            set Cua_HCand[k + i] = x
''', '''            // v22r: sin cartas al máximo.
            set x = Car_Heroe(p, k, 4)
            set Cua_HCand[k + i] = x
''')
# Al abrir un paso: también las cartas que llegaron al máximo.
cambia('''        endif
        if mal then
''', '''        elseif not Car_Disp(p, x, Her_Tipo[k + i]) then
            // v22r: carta que llegó al máximo después de repartirse.
            set mal = true
        endif
        if mal then
''')
cambia('''                loop
                    set x = Her_Pool[GetRandomInt(0, 7)]
                    exitwhen not Her_EnMano(k, x)
                endloop
''', '''                set x = Car_Heroe(p, k, 4)
''')

# 3) Armas.
cambia('''    set lx[n] = 20
    set lt[n] = -1
    set lx[n + 1] = 23
    set lt[n + 1] = -1
    set lx[n + 2] = 88
    set lt[n + 2] = -1
    set n = n + 3
''', '''    // v22r: Filo, Golpe de suerte y Vida extra mientras no estén al máximo.
    set j = 0
    loop
        exitwhen j > 2
        set x = 20
        if j == 1 then
            set x = 23
        elseif j == 2 then
            set x = 88
        endif
        if Car_Disp(p, x, -1) then
            set lx[n] = x
            set lt[n] = -1
            set n = n + 1
        endif
        set j = j + 1
    endloop
''')
cambia('''    loop
        exitwhen i > 3
        call ArmC_Poner(p, i, 88, -1)
        set i = i + 1
    endloop
''', '''    // v22r: si faltan cartas, bonificaciones sin tope: Afilado y Calibre menor de cada categoría que tiene.
    set n = 0
    if i <= 3 then
        set lx[0] = 108
        set lt[0] = -1
        set n = 1
        set c = 0
        loop
            exitwhen c > 6
            if Arm_Tier[p * 7 + c] > 0 then
                set lx[n] = 109
                set lt[n] = c
                set n = n + 1
            endif
            set c = c + 1
        endloop
    endif
    loop
        exitwhen i > 3
        if n > 0 then
            set j = GetRandomInt(0, n - 1)
            call ArmC_Poner(p, i, lx[j], lt[j])
            set n = n - 1
            set lx[j] = lx[n]
            set lt[j] = lt[n]
        else
            call ArmC_Poner(p, i, 108, -1)
        endif
        set i = i + 1
    endloop
''')
cambia('''    elseif x == 88 then
        set Vidas_Actual[p] = Vidas_Actual[p] + 1
''', '''    elseif x == 88 then
        call Car_Contar(p, 88, -1)
        set Vidas_Actual[p] = Vidas_Actual[p] + 1
''')
# Mano comprada: rehacer si alguna carta llegó al máximo; cambio de maldita sin cartas al máximo.
cambia('''            elseif x == 87 and Arm_Tier[p * 7 + HerC_AT[b + c]] > 0 then
                set rehacer = true
            endif
''', '''            elseif x == 87 and Arm_Tier[p * 7 + HerC_AT[b + c]] > 0 then
                set rehacer = true
            elseif not Car_Disp(p, x, HerC_AT[b + c]) then
                // v22r: carta que llegó al máximo.
                set rehacer = true
            endif
''')
cambia('''    if not f then
        return 20
    elseif not g then
        return 23
    endif
    return 88
endfunction
''', '''    // v22r: sin cartas al máximo; si no queda ninguna, Afilado.
    if not f and Car_Disp((k - 35) / 40, 20, -1) then
        return 20
    elseif not g and Car_Disp((k - 35) / 40, 23, -1) then
        return 23
    elseif Car_Disp((k - 35) / 40, 88, -1) then
        return 88
    endif
    return 108
endfunction
''')
cambia('''            set x = 20
            set Her_Cal[k] = IMinBJ(4, Her_Cal[k])
''', '''            set x = Car_Filo(p)
            set Her_Cal[k] = IMinBJ(4, Her_Cal[k])
''')

# 4) Efectos: cuenta de niveles y bonificaciones sin tope.
cambia('''    local integer v = Her_Valor(x, q)
    local integer e
    local real hp
    if x == 20 then
''', '''    local integer v = Her_Valor(x, q)
    local integer e
    local real hp
    call Car_Contar(p, x, Her_TipoSel)
    if x == 20 or x == 108 then
''')
cambia('    elseif x == 21 and u != null then\n        call BM_VidaMax(u, v)\n',
       '    elseif (x == 21 or x == 105) and u != null then\n        call BM_VidaMax(u, v)\n')
cambia('    elseif x == 22 and u != null then\n        // v19u:', '    elseif (x == 22 or x == 106) and u != null then\n        // v19u:')
cambia('    elseif x == 26 then\n        set Her_Botin[p] = Her_Botin[p] + v / 100.\n',
       '    elseif x == 26 or x == 107 then\n        set Her_Botin[p] = Her_Botin[p] + v / 100.\n')
cambia('    elseif x == 19 then\n        set Her_Iman[p] = Her_Iman[p] + v\n',
       '    elseif x == 19 or x == 110 then\n        set Her_Iman[p] = Her_Iman[p] + v\n')
cambia('''    elseif x == 81 then
        set Bat_Pilas[p] = IMinBJ(3, Bat_Pilas[p] + 1)
''', '''    elseif x == 109 then
        // v22r: Calibre menor, sin tope.
        set e = Her_TipoSel
        if e < 0 or e > 6 then
            set e = 1
        endif
        set Arm_Calibre[p * 7 + e] = Arm_Calibre[p * 7 + e] + v / 100.
    elseif x == 81 then
        set Bat_Pilas[p] = IMinBJ(3, Bat_Pilas[p] + 1)
''')
cambia('''        set e = GetRandomInt(0, 17)
        set Cua_Activa[e] = Cua_Activa[e] + 1
''', '''        // v22r: una que no esté al máximo.
        set e = Car_MutLibre()
        set Cua_Activa[e] = Cua_Activa[e] + 1
''')

# 5) Textos de las cartas.
cambia('''function Her_Etiqueta takes integer x returns string
    if x == 86 then
''', '''function Her_Etiqueta takes integer x returns string
    if Car_EsInf(x) then
        return "|cffffd27fBonificación|r|n"
    elseif x == 86 then
''')
cambia('    set v = Her_Valor(x, Her_Cal[Her_K(p, c)])\n', '''    set v = Her_Valor(x, Her_Cal[Her_K(p, c)])
    if Car_EsInf(x) then
        return Her_Etiqueta(x) + Car_InfDes(x, v, false)
    endif
''')
cambia('''    set v = Her_Valor(x, q)
    if x == 18 or x == 19 or x == 37 or x == 38 then
''', '''    set v = Her_Valor(x, q)
    if Car_EsInf(x) then
        return Her_Etiqueta(x) + Car_InfDes(x, v, true)
    endif
    if x == 18 or x == 19 or x == 37 or x == 38 then
''')
cambia('function Cua_VotosTxt takes integer p, integer c returns string\n', '''// v22r: nivel que daría la carta c de la mano de p ("Nivel n/máx"), o "Sin tope" en las bonificaciones.
function Car_NivTxt takes integer p, integer c returns string
    local integer k = Her_K(p, c)
    local integer x = Cua_HCand[k]
    local integer e = Her_Tipo[k]
    local integer n
    if (c == 4 and Cua_Modo[p] != 3) or Tec_EsTec(x) then
        return ""
    elseif Car_EsInf(x) then
        return "|n|cffffd27fSin tope|r"
    elseif Car_S[x] > 0 and e >= 0 and e <= 6 then
        set n = Car_TomC[p * 56 + e * 8 + Car_S[x] - 1]
    elseif Car_Max[x] > 0 and Car_S[x] == 0 then
        set n = Car_Tom[p * 200 + x]
    else
        return ""
    endif
    return "|n|cffffcc00Nivel " + I2S(n + 1) + "/" + I2S(Car_Max[x]) + "|r"
endfunction

// v22r: nivel de la mutación x: el que tendría al votarla (si ya está activa) o el que tiene en la muestra.
function Mut_NivTxt takes integer p, integer x returns string
    if x < 0 or x > 17 then
        return ""
    elseif Cua_Modo[p] == 2 then
        if Cua_Activa[x] > 1 then
            return "|n|cffffcc00Nivel " + I2S(Cua_Activa[x]) + "/3|r"
        endif
        return ""
    elseif Cua_Activa[x] > 0 then
        return "|n|cffffcc00Nivel " + I2S(Cua_Activa[x] + 1) + "/3|r"
    endif
    return ""
endfunction

function Cua_VotosTxt takes integer p, integer c returns string
''')
cambia('call Cua_Izq(p, Cua_TD[c], Her_Des(p, c), Cua_PX(s) - 126, 559, 0.022)',
       'call Cua_Izq(p, Cua_TD[c], Her_Des(p, c) + Car_NivTxt(p, c), Cua_PX(s) - 126, 559, 0.022)')
cambia('Cua_Des[Cua_Item(p, c)] + Cua_VotosTxt(p, c)', 'Cua_Des[Cua_Item(p, c)] + Mut_NivTxt(p, Cua_Item(p, c)) + Cua_VotosTxt(p, c)')

# 6) Texto de mutaciones: sólo en la votación y en la muestra.
cambia('''    if Cua_TMut != null then
        if not inicio then
            call Cua_Izq(p, Cua_TMut, Cua_MutTxt(), 150, 140, 0.017)
        endif
        call SetTextTagVisibility(Cua_TMut, not inicio)
    endif
''', '''    if Cua_TMut != null then
        // v22r: fuera en Armas y en Habilidades (el panel del menú ya las muestra).
        if not inicio and not Cua_EsCarta(p) then
            call Cua_Izq(p, Cua_TMut, Cua_MutTxt(), 150, 140, 0.017)
        endif
        call SetTextTagVisibility(Cua_TMut, not inicio and not Cua_EsCarta(p))
    endif
''')

# 7) Mutación Evo: tope de 3 niveles.
cambia('''function Cua_Usado takes integer x, integer k, integer i returns boolean
    local integer j = 0
''', '''function Cua_Usado takes integer x, integer k, integer i returns boolean
    local integer j = 0
    // v22r: al máximo (Mut_Tope, que fija Cua_Libres).
    if Cua_Activa[x] >= Mut_Tope then
        return true
    endif
''')
cambia('''                set j = j + 1
            endloop
            exitwhen not rep
        endloop
        if heroe then
''', '''                set j = j + 1
            endloop
            // v22r: mutación al máximo.
            if not heroe and Cua_Activa[x] >= Mut_Tope then
                set rep = true
            endif
            exitwhen not rep
        endloop
        if heroe then
''')
cambia('// Al empezar el descanso (Ronda_AlTerminar, por nombre): candidatos nuevos y pasos a cero.\n', '''// v22r: mutaciones del grupo [ini, ini + tam) por debajo de 3 niveles; fija Mut_Tope (99 si no queda ninguna: entonces
// valen todas).
function Cua_Libres takes integer ini, integer tam returns integer
    local integer n = 0
    local integer x = ini
    loop
        exitwhen x >= ini + tam
        if Cua_Activa[x] < 3 then
            set n = n + 1
        endif
        set x = x + 1
    endloop
    set Mut_Tope = 3
    if n == 0 then
        set Mut_Tope = 99
        return tam
    endif
    return n
endfunction

// Al empezar el descanso (Ronda_AlTerminar, por nombre): candidatos nuevos y pasos a cero.
''')
cambia('''    set Cua_Cnt[0] = IMinBJ(Cua_NE, 4)
    set Cua_Cnt[1] = IMinBJ(Cua_NE, 4)
    set Cua_Cnt[2] = Cua_NE
    call Cua_Elegir(0, 4, Cua_Cnt[0], false, 0)
    call Cua_Elegir(4, 4, Cua_Cnt[1], false, 5)
    call Cua_ElegirPeso(8, 10, Cua_Cnt[2], 10)
''', '''    // v22r: sin mutaciones al máximo (3 niveles); menos cuadros si quedan menos.
    set Cua_Cnt[0] = IMinBJ(IMinBJ(Cua_NE, 4), Cua_Libres(0, 4))
    call Cua_Elegir(0, 4, Cua_Cnt[0], false, 0)
    set Cua_Cnt[1] = IMinBJ(IMinBJ(Cua_NE, 4), Cua_Libres(4, 4))
    call Cua_Elegir(4, 4, Cua_Cnt[1], false, 5)
    set Cua_Cnt[2] = IMinBJ(Cua_NE, Cua_Libres(8, 10))
    call Cua_ElegirPeso(8, 10, Cua_Cnt[2], 10)
    set Mut_Tope = 3
''')

# 8) Datos: topes, nombres, iconos y valores (T1..T5) de las bonificaciones.
TOPES = {21: 5, 22: 4, 26: 4, 27: 5, 18: 3, 19: 3, 37: 3, 38: 3, 20: 5, 23: 4, 88: 3, 83: 4, 84: 3}
INF = [(105, 'Fortaleza', 'DC09', [25, 40, 60, 90, 120]), (106, 'Paso ligero', 'DC01', [3, 5, 8, 12, 15]),
       (107, 'Fortuna', 'DC0G', [2, 4, 6, 9, 12]), (108, 'Afilado', 'DC04', [2, 3, 5, 7, 9]),
       (109, 'Calibre menor', 'DC0R', [3, 5, 8, 12, 15]), (110, 'Recolector', 'DM05', [10, 15, 20, 30, 40])]
d = '    // v22r: niveles máximos de las cartas y bonificaciones sin tope (105-110).\n'
d += ''.join(f'    set Car_Max[{x}] = {m}\n' for x, m in TOPES.items())
d += '    set Car_S[83] = 1\n    set Car_S[84] = 2\n'
for x, nom, tex, vals in INF:
    d += f'    set Cua_Nom[{x}] = "{nom}"\n    set Cua_Des[{x}] = ""\n    set Cua_Tex[{x}] = \'{tex}\'\n'
    d += ''.join(f'    set Her_Tabla[{x * 5 + q}] = {v}\n' for q, v in enumerate(vals))
cambia('    // v18y: quinta carta del paso del héroe.\n', d + '    // v18y: quinta carta del paso del héroe.\n')
assert src.index('function Car_Disp') < src.index('function Arm_TipoAzar') < src.index('function Her_Cartas')
assert src.index('function Car_NivTxt') > src.index('function Her_K ')

if prueba:
    assert 'function Cop_Anotar' in src
    cambia('lat\\\\v22q-', 'lat\\\\v22r-', src.count('lat\\\\v22q-'))
    cambia('v22q-don.txt', 'v22r-don.txt', src.count('v22q-don.txt'))
    assert 'lat\\\\v22q-' not in src and 'v22q-don.txt' not in src, 'quedan registros v22q'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22r', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
