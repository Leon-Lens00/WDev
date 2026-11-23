#!/usr/bin/env python3
"""v20v (20/11/2026): Armas por cartas (plan docs/planes/devmission-armas-cartas-v20v.md).
Leon: guardar la tienda de compra desactivada; la sección Armas pasa a selección por cartas: subir tier y aprender
armas nuevas, respetando el límite de tier por ronda (Arm_Req: T6 tras la ronda 8); siempre una carta de subir tier y
otra de arma nueva si se puede; las mejoras de tipo de arma sólo de armas que se tienen; las cartas de armas, daño y
ataque salen de las del héroe y pasan aquí. 2 elecciones gratis por oleada (1 la primera vez), 4 cartas sin
refresco; si no se eligen se pierden. Vida: carta de +1 vida. Munición: se llena sola al terminar cada oleada.
- Tienda vieja intacta, apagada con ArmC_TiendaVieja = false (Cua_IrArmas sigue ahí).
- Modo de cuadros nuevo Cua_Modo 3 con las cartas en Cua_HCand[p*40+35..38] (Her_K), sin tocar los pasos del héroe.
- Cartas nuevas: 86 Subir tier, 87 Arma nueva (icono = foto de la categoría), 88 Vida extra.
- A Armas pasan Filo (20), Golpe de suerte (23), Calibre (83), Cargador ágil (84) y las malditas de daño: Pacto maldito
  (28), Sed de sangre (33), Ruleta (36) y Pacto de sombras (80). El héroe se queda con estadísticas, economía, dash y
  linterna, y con las malditas Codicia (34) y Mutante (35).
Uso: v20v.py ENTRADA.j SALIDA.j [prueba]   (normal de v20u; prueba de v20u-prueba)
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


# --- globales
cambia('integer Jun_PP= 0\n', '''integer Jun_PP= 0
// v20v: Armas por cartas. Tienda de compra vieja apagada; elecciones que quedan y total de la oleada.
boolean ArmC_TiendaVieja= false
integer array ArmC_Quedan
integer array ArmC_Total
''')

# --- Cua_Cuantos / Cua_Item: modo 3 (antes de Her_K)
cambia('''function Cua_Cuantos takes integer p returns integer
    if Cua_Modo[p] != 1 then''', '''// v20v: pantalla de cartas con calidad (héroe, pasos 3 en adelante, o Armas, modo 3).
function Cua_EsCarta takes integer p returns boolean
    return (Cua_Modo[p] == 1 and Cua_Paso[p] >= 3) or Cua_Modo[p] == 3
endfunction

function Cua_Cuantos takes integer p returns integer
    if Cua_Modo[p] == 3 then
        return 4
    endif
    if Cua_Modo[p] != 1 then''')
cambia('''function Cua_Item takes integer p, integer c returns integer
    if Cua_Modo[p] == 2 then''', '''function Cua_Item takes integer p, integer c returns integer
    if Cua_Modo[p] == 3 then
        return Cua_HCand[p * 40 + 35 + c]
    endif
    if Cua_Modo[p] == 2 then''')

# --- icono: foto de la categoría (2:1) en Subir tier / Arma nueva
cambia('''        set tex = Cua_Tex[Cua_Item(p, c)]
        if Cua_Ico[s] != null and Cua_IcoTex[s] != tex then
            call FlushChildHashtable(Title_HT, GetHandleId(Cua_Ico[s]))
            call RemoveUnit(Cua_Ico[s])
            set Title_CX = 4800.
            set Cua_Ico[s] = Cua_Pic(Cua_PX(Cua_Slot(n, c)), 333, 190, 190, 405, tex)''',
       '''        set tex = Cua_Tex[Cua_Item(p, c)]
        // v20v: en Armas, Subir tier y Arma nueva llevan la foto de su categoría (2:1).
        if Cua_Modo[p] == 3 and (Cua_Item(p, c) == 86 or Cua_Item(p, c) == 87) then
            set tex = Cat_Tex[IMaxBJ(0, IMinBJ(6, Her_Tipo[p * 40 + 35 + c]))]
        endif
        if Cua_Ico[s] != null and Cua_IcoTex[s] != tex then
            call FlushChildHashtable(Title_HT, GetHandleId(Cua_Ico[s]))
            call RemoveUnit(Cua_Ico[s])
            set Title_CX = 4800.
            if tex >= 'DS11' and tex <= 'DS17' then
                set Cua_Ico[s] = Cua_Pic(Cua_PX(Cua_Slot(n, c)), 333, 190, 95, 405, tex)
            else
                set Cua_Ico[s] = Cua_Pic(Cua_PX(Cua_Slot(n, c)), 333, 190, 190, 405, tex)
            endif''')

# --- malditas del héroe: sólo Codicia y Mutante (las de daño pasan a Armas)
i = src.index(U('function Her_Maldita takes integer p returns integer\n'))
j = src.index('endfunction\n', i) + len('endfunction\n')
src = src[:i] + U('''function Her_Maldita takes integer p returns integer
    // v20v: las malditas de daño (28, 33, 36, 80) salen en Armas (ArmC_Maldita); al héroe le quedan 34 y 35.
    local integer array l
    local integer n = 0
    local integer x = 34
    loop
        exitwhen x > 35
        if not Her_Mald[p * 40 + x] then
            set l[n] = x
            set n = n + 1
        endif
        set x = x + 1
    endloop
    if n == 0 then
        return 0
    endif
    return l[GetRandomInt(0, n - 1)]
endfunction

// v20v: maldita de daño para Armas (0 si ya las tiene todas).
function ArmC_Maldita takes integer p returns integer
    local integer array l
    local integer n = 0
    if not Her_Mald[p * 40 + 28] then
        set l[n] = 28
        set n = n + 1
    endif
    if not Her_Mald[p * 40 + 33] then
        set l[n] = 33
        set n = n + 1
    endif
    if not Her_Mald[p * 40 + 36] then
        set l[n] = 36
        set n = n + 1
    endif
    if not Her_Mald[p * 40 + 80] then
        set l[n] = 80
        set n = n + 1
    endif
    if n == 0 then
        return 0
    endif
    return l[GetRandomInt(0, n - 1)]
endfunction
''') + src[j:]

# --- etiqueta y banda de tipo de las cartas nuevas
cambia('''function Her_Etiqueta takes integer x returns string
    if x == 24''', '''function Her_Etiqueta takes integer x returns string
    if x == 86 then
        return "|cff78aaffMejora de arma|r|n"
    elseif x == 87 then
        return "|cff78aaffArma nueva|r|n"
    elseif x == 88 then
        return "|cff5ae678Vida|r|n"
    elseif x == 24''')
cambia('''    if x == 24 or x == 25 or x == 78 or x == 79 then
        set Her_R = 255
        set Her_G = 156
        set Her_B = 64
    elseif x == 81 or x == 82 then''', '''    if x == 24 or x == 25 or x == 78 or x == 79 then
        set Her_R = 255
        set Her_G = 156
        set Her_B = 64
    elseif x == 86 or x == 87 then
        set Her_R = 120
        set Her_G = 170
        set Her_B = 255
    elseif x == 88 then
        set Her_R = 90
        set Her_G = 230
        set Her_B = 120
    elseif x == 81 or x == 82 then''')

# --- color de calidad 6 = T6 (rojo) en nombre y fondo
cambia('''    elseif q == 5 then
        set Her_R = 192
        set Her_G = 112
        set Her_B = 255
    endif
endfunction
''', '''    elseif q == 5 then
        set Her_R = 192
        set Her_G = 112
        set Her_B = 255
    elseif q == 6 then
        set Her_R = 253
        set Her_G = 40
        set Her_B = 40
    endif
endfunction
''')
cambia('''    elseif q == 4 then
        set Her_R = 150
        set Her_G = 60
        set Her_B = 235
    else''', '''    elseif q == 4 then
        set Her_R = 150
        set Her_G = 60
        set Her_B = 235
    elseif q == 6 then
        set Her_R = 225
        set Her_G = 30
        set Her_B = 35
    else''')

# --- Her_K en modo 3; descripción de las cartas nuevas
cambia('''function Her_K takes integer p, integer c returns integer
    return p * 40''', '''function Her_K takes integer p, integer c returns integer
    if Cua_Modo[p] == 3 then
        return p * 40 + 35 + c
    endif
    return p * 40''')
cambia('''function Her_Nombre takes integer p, integer c returns string
''', '''// v20v: descripción de Subir tier (86), Arma nueva (87) y Vida extra (88) para la categoría e.
function ArmC_Des takes integer p, integer x, integer e returns string
    local integer t
    if x == 88 then
        return Her_Etiqueta(x) + "+1 vida.|nTienes " + I2S(Vidas_Actual[p]) + "."
    endif
    set e = IMaxBJ(0, IMinBJ(6, e))
    set t = IMinBJ(6, Arm_Tier[p * 7 + e] + 1)
    if x == 87 then
        set t = 1
    endif
    return Her_Etiqueta(x) + Arm_TierTexto(t) + " " + Arm_Nombre[e * 6 + t - 1] + "|n(" + Cat_Nombre[e] + ")."
endfunction

function Her_Nombre takes integer p, integer c returns string
''')
cambia('''    set x = Cua_HCand[Her_K(p, c)]
    set Her_TipoTxt = Cat_Nombre[IMaxBJ(0, Her_Tipo[Her_K(p, c)])]
''', '''    set x = Cua_HCand[Her_K(p, c)]
    set Her_TipoTxt = Cat_Nombre[IMaxBJ(0, Her_Tipo[Her_K(p, c)])]
    if x == 86 or x == 87 or x == 88 then
        return ArmC_Des(p, x, Her_Tipo[Her_K(p, c)])
    endif
''')

# --- cabecera, pantalla de inicio
cambia('''function Cua_Cabecera takes integer p returns string
    if Cua_Modo[p] == 2 then''', '''function Cua_Cabecera takes integer p returns string
    if Cua_Modo[p] == 3 then
        return "Armas (" + I2S(ArmC_Total[p] - ArmC_Quedan[p] + 1) + "/" + I2S(ArmC_Total[p]) + ") · suerte " + I2S(Her_Suerte[p])
    endif
    if Cua_Modo[p] == 2 then''')
cambia('''        return Cua_Paso[p] < 3 or Cua_Paso[p] >= Her_FinDe(p)
    endif
    return Cua_Paso[p] < 3
endfunction''', '''        return Cua_Paso[p] < 3 or Cua_Paso[p] >= Her_FinDe(p)
    endif
    return Cua_Paso[p] < 3 or (not ArmC_TiendaVieja and ArmC_Quedan[p] <= 0)
endfunction''')
cambia('''    if k == 0 then
        return "Mejora tus armas|ny compra munición."''', '''    if k == 0 and not ArmC_TiendaVieja then
        if ArmC_Quedan[p] <= 0 then
            return "|cff909090Hecho: ya elegiste|nlas de tus armas.|r"
        endif
        return "Elige " + I2S(ArmC_Quedan[p]) + " mejoras de|ntus armas."
    elseif k == 0 then
        return "Mejora tus armas|ny compra munición."''')
cambia('''    if c == 0 then
        call Cua_IrArmas(p)
        return
    endif''', '''    if c == 0 and ArmC_TiendaVieja then
        call Cua_IrArmas(p)
        return
    elseif c == 0 then
        // v20v: Armas por cartas (la tienda de compra vieja queda apagada).
        set Cua_Modo[p] = 3
        call Cua_Pintar(p)
        call Cua_Ver(p)
        return
    endif''')

# --- Cua_Ver: modo 3 como pantalla de cartas, cabecera azul
i = src.index('function Cua_Ver takes integer p returns nothing\n')
j = src.index('\nendfunction\n', i)
cuerpo = src[i:j]
cuerpo = cuerpo.replace('local boolean ver = Cua_Open[p] and (inicio or Cua_Modo[p] == 2 or Cua_Paso[p] < Her_FinDe(p))',
                        'local boolean ver = Cua_Open[p] and (inicio or Cua_Modo[p] == 2 or (Cua_Modo[p] == 3 and ArmC_Quedan[p] > 0) or (Cua_Modo[p] == 1 and Cua_Paso[p] < Her_FinDe(p)))', 1)
n1 = cuerpo.count('Cua_Paso[p] >= 3 and Cua_Modo[p] == 1')
n2 = cuerpo.count('Cua_Modo[p] == 1 and Cua_Paso[p] >= 3')
assert (n1, n2) == (1, 6), (n1, n2)
cuerpo = cuerpo.replace('Cua_Paso[p] >= 3 and Cua_Modo[p] == 1', 'Cua_EsCarta(p)').replace('Cua_Modo[p] == 1 and Cua_Paso[p] >= 3', 'Cua_EsCarta(p)')
viejo = '''    elseif Cua_EsCarta(p) then
        set Her_R = 235
        set Her_G = 175
        set Her_B = 40'''
assert cuerpo.count(viejo) == 1
cuerpo = cuerpo.replace(viejo, '''    elseif Cua_Modo[p] == 3 then
        set Her_R = 60
        set Her_G = 120
        set Her_B = 215
''' + viejo)
assert 'ArmC_Quedan' in cuerpo
src = src[:i] + cuerpo + src[j:]

# --- reparto: pool del héroe sin las de armas; cartas de Armas
cambia('''    set Her_Pool[0] = 20
    set Her_Pool[1] = 21
    set Her_Pool[2] = 22
    set Her_Pool[3] = 23
    set Her_Pool[4] = 26
    set Her_Pool[5] = 27
    set Her_Pool[6] = 18
    set Her_Pool[7] = 19
    set Her_Pool[8] = 37
    set Her_Pool[9] = 38
    set Her_Pool[10] = 24
    set Her_Pool[11] = 81
    set Her_Pool[12] = 83
    set Her_Pool[13] = 84
''', '''    // v20v: Filo (20), Golpe de suerte (23), Calibre (83) y Cargador ágil (84) pasan a Armas.
    set Her_Pool[0] = 21
    set Her_Pool[1] = 22
    set Her_Pool[2] = 26
    set Her_Pool[3] = 27
    set Her_Pool[4] = 18
    set Her_Pool[5] = 19
    set Her_Pool[6] = 37
    set Her_Pool[7] = 38
    set Her_Pool[8] = 24
    set Her_Pool[9] = 81
''')
# estadísticas y economía (0-7) en los repuestos de dash/linterna, pulls extra y puesta al día; 0-9 en el reparto
cambia('Her_Pool[GetRandomInt(0, 9)]', 'Her_Pool[GetRandomInt(0, 7)]', 4)
cambia('set x = Her_Pool[GetRandomInt(0, 13)]', 'set x = Her_Pool[GetRandomInt(0, 9)]')

nota = (lambda s: f'    set Cop_Log = {s}\n    call ExecuteFunc("Cop_Anotar")\n')
cambia('''// v18y: al cerrarse el cuadro de resultados (Ronda_DescansoEmpezar, por nombre): suerte, refrescos y cartas.
function Her_Sortear takes nothing returns nothing''', '''// v20v: carta i de Armas de p: x con su categoría e y su calidad (Subir tier: color del tier nuevo, 6 = T6 rojo).
function ArmC_Poner takes integer p, integer i, integer x, integer e returns nothing
    local integer k = p * 40 + 35 + i
    local integer t
    set Cua_HCand[k] = x
    set Her_Tipo[k] = e
    if x == 86 then
        set t = Arm_Tier[p * 7 + e] + 1
        set Her_Cal[k] = t - 1
        if t >= 6 then
            set Her_Cal[k] = 6
        endif
    elseif x == 87 or Her_EsMaldita(x) then
        set Her_Cal[k] = 0
    elseif x == 88 then
        set Her_Cal[k] = 1
    else
        set Her_Cal[k] = Her_TiraCal(p)
    endif
endfunction

// v20v: 4 cartas de Armas para p. Primero, si se puede, Subir tier de un arma que tiene (con la ronda que pide el
// tier: Arm_Req) y Arma nueva de una categoría que no tiene; el resto al azar sin repetir entre Subir tier de otra,
// Arma nueva de otra, Filo, Golpe de suerte, Calibre y Cargador ágil (de un arma que tiene) y Vida extra.
// 12 % de que la cuarta sea una maldita de daño.
function ArmC_Cartas takes integer p returns nothing
    local integer array lx
    local integer array lt
    local integer array u
    local integer array w
    local integer n = 0
    local integer nu = 0
    local integer nw = 0
    local integer i = 0
    local integer j
    local integer c = 0
    local integer t
    local integer su = -1
    local integer sw = -1
    local integer x
    loop
        exitwhen c > 6
        set t = Arm_Tier[p * 7 + c]
        if t <= 0 then
            set w[nw] = c
            set nw = nw + 1
        elseif t < 6 and Ronda_Pasadas() >= Arm_Req(t + 1) then
            set u[nu] = c
            set nu = nu + 1
        endif
        set c = c + 1
    endloop
    if nu > 0 then
        set su = u[GetRandomInt(0, nu - 1)]
        call ArmC_Poner(p, i, 86, su)
        set i = i + 1
    endif
    if nw > 0 then
        set sw = w[GetRandomInt(0, nw - 1)]
        call ArmC_Poner(p, i, 87, sw)
        set i = i + 1
    endif
    set j = 0
    loop
        exitwhen j >= nu
        if u[j] != su then
            set lx[n] = 86
            set lt[n] = u[j]
            set n = n + 1
        endif
        set j = j + 1
    endloop
    set j = 0
    loop
        exitwhen j >= nw
        if w[j] != sw then
            set lx[n] = 87
            set lt[n] = w[j]
            set n = n + 1
        endif
        set j = j + 1
    endloop
    set lx[n] = 20
    set lt[n] = -1
    set lx[n + 1] = 23
    set lt[n + 1] = -1
    set lx[n + 2] = 88
    set lt[n + 2] = -1
    set n = n + 3
    set t = Arm_TipoAzar(p, 83)
    if t >= 0 then
        set lx[n] = 83
        set lt[n] = t
        set n = n + 1
    endif
    set t = Arm_TipoAzar(p, 84)
    if t >= 0 then
        set lx[n] = 84
        set lt[n] = t
        set n = n + 1
    endif
    loop
        exitwhen i > 3 or n <= 0
        set j = GetRandomInt(0, n - 1)
        call ArmC_Poner(p, i, lx[j], lt[j])
        set n = n - 1
        set lx[j] = lx[n]
        set lt[j] = lt[n]
        set i = i + 1
    endloop
    loop
        exitwhen i > 3
        call ArmC_Poner(p, i, 88, -1)
        set i = i + 1
    endloop
    set x = ArmC_Maldita(p)
    if x > 0 and GetRandomInt(1, 100) <= 12 then
        call ArmC_Poner(p, 3, x, -1)
    endif
''' + nota('"armas cartas j" + I2S(p) + ": " + I2S(Cua_HCand[p * 40 + 35]) + " " + I2S(Cua_HCand[p * 40 + 36]) + " " + I2S(Cua_HCand[p * 40 + 37]) + " " + I2S(Cua_HCand[p * 40 + 38]) + " quedan " + I2S(ArmC_Quedan[p])') + '''endfunction

// v20v: munición llena en todas las armas al terminar cada oleada (desde Ronda_AlTerminar, por nombre).
function ArmC_Municion takes nothing returns nothing
    local integer p = 0
    local integer c
    local integer i
    loop
        exitwhen p > 11
        set c = 0
        loop
            exitwhen c > 6
            set i = p * 7 + c
            if c != 5 and Arm_Tier[i] > 0 then
                set Arm_Clip[i] = Arm_Mag[c * 6 + Arm_Tier[i] - 1]
                set Arm_Rva[i] = Arm_Res[c * 6 + Arm_Tier[i] - 1]
            endif
            set c = c + 1
        endloop
        set p = p + 1
    endloop
''' + nota('"armas municion llena"') + '''endfunction

// v18y: al cerrarse el cuadro de resultados (Ronda_DescansoEmpezar, por nombre): suerte, refrescos y cartas.
function Her_Sortear takes nothing returns nothing''')
cambia('''            set g = Her_SinOro[p] >= 3
            set Her_Alta = false''', '''            // v20v: 2 elecciones de Armas por oleada (1 la primera vez); las que no se eligen se pierden.
            if not Her_Ok then
                set ArmC_Total[p] = 1
            else
                set ArmC_Total[p] = 2
            endif
            set ArmC_Quedan[p] = ArmC_Total[p]
            call ArmC_Cartas(p)
            set g = Her_SinOro[p] >= 3
            set Her_Alta = false''')

# --- elegir una carta de Armas
cambia('''// v18y: quinta carta del paso del héroe: cambia las 4 cartas (cuesta 1 de suerte).
function Her_Refrescar takes integer p returns nothing''', '''// v20v: sube un tier el arma de la categoría e de p (T1 si no la tenía), como la compra vieja pero sin oro.
function ArmC_Subir takes integer p, integer e returns nothing
    local integer i = p * 7 + e
    local integer t = Arm_Tier[i] + 1
    local integer w = e * 6 + t - 1
    if e < 0 or e > 6 or t > 6 then
        return
    endif
    if t == 1 then
        call UnitAddAbility(Game_Ctrl[p], 'Aw00' + e)
    endif
    call SetUnitAbilityLevel(Game_Ctrl[p], 'Aw00' + e, t)
    set Arm_Tier[i] = t
    set Arm_Clip[i] = Arm_Mag[w]
    set Arm_Rva[i] = Arm_Res[w]
    call Son_Ui(p, Son_TiendaSnd, 127)
endfunction

// v20v: aplica la carta c de Armas de p (código común, desde el clic sincronizado) y reparte la siguiente mano.
function ArmC_Hacer takes integer p, integer c returns nothing
    local integer k = p * 40 + 35 + c
    local integer x = Cua_HCand[k]
    local integer e = Her_Tipo[k]
    if ArmC_Quedan[p] <= 0 then
        return
    endif
    if x == 86 or x == 87 then
        call ArmC_Subir(p, e)
    elseif x == 88 then
        set Vidas_Actual[p] = Vidas_Actual[p] + 1
        if GetUnitAbilityLevel(Game_Hero[p], 'Arei') == 0 then
            call UnitAddAbility(Game_Hero[p], 'Arei')
        endif
    else
        set Her_TipoSel = e
        call Her_Aplicar(p, x, Her_Cal[k])
        call Pan_Registrar(p, x, Her_Cal[k])
    endif
    if StringLength(Cua_Resumen[p]) > 0 then
        set Cua_Resumen[p] = Cua_Resumen[p] + ", "
    endif
    if x == 86 or x == 87 then
        set Cua_Resumen[p] = Cua_Resumen[p] + Arm_TierTexto(Arm_Tier[p * 7 + e]) + " " + Arm_Nombre[e * 6 + Arm_Tier[p * 7 + e] - 1]
    else
        set Cua_Resumen[p] = Cua_Resumen[p] + "|cff78f08c" + Cua_Nom[x] + "|r"
    endif
''' + nota('"armas elige j" + I2S(p) + " carta " + I2S(x) + " cat " + I2S(e) + " tier " + I2S(Arm_Tier[p * 7 + IMaxBJ(0, e)]) + " vidas " + I2S(Vidas_Actual[p])') + '''    set ArmC_Quedan[p] = ArmC_Quedan[p] - 1
    if ArmC_Quedan[p] > 0 then
        call ArmC_Cartas(p)
    else
        set Cua_Modo[p] = 0
    endif
    call Cua_Pintar(p)
    call Cua_Ver(p)
endfunction

// v18y: quinta carta del paso del héroe: cambia las 4 cartas (cuesta 1 de suerte).
function Her_Refrescar takes integer p returns nothing''')
cambia('''    local integer q = 0
    set Cua_Elegido[p * 12 + Cua_Paso[p]] = x
''', '''    local integer q = 0
    if Cua_Modo[p] == 3 then
        call ArmC_Hacer(p, c / 2)
        return
    endif
    set Cua_Elegido[p * 12 + Cua_Paso[p]] = x
''')
cambia('    if Cua_Open[p] and Cua_Modo[p] == 1 and Cua_Paso[p] == Cua_FlaPaso[p] then\n        call Cua_Hacer(p, Cua_FlaS[p])',
       '    if Cua_Open[p] and ((Cua_Modo[p] == 1 and Cua_Paso[p] == Cua_FlaPaso[p]) or (Cua_Modo[p] == 3 and ArmC_Quedan[p] > 0)) then\n        call Cua_Hacer(p, Cua_FlaS[p])')
cambia('    if Cua_Paso[p] >= Her_FinDe(p) or c < 0 or ModuloInteger(c, 2) != 0 or c / 2 >= n then',
       '    if (Cua_Modo[p] == 1 and Cua_Paso[p] >= Her_FinDe(p)) or (Cua_Modo[p] == 3 and ArmC_Quedan[p] <= 0) or c < 0 or ModuloInteger(c, 2) != 0 or c / 2 >= n then')
cambia('    if Cua_Paso[p] >= 3 and c / 2 == 4 then\n        if Cua_Fla[p] > 0 then',
       '    if Cua_Modo[p] == 1 and Cua_Paso[p] >= 3 and c / 2 == 4 then\n        if Cua_Fla[p] > 0 then')

# --- nombres e iconos de las cartas nuevas
cambia('''    set Cua_Tex[85] = Cua_Tex[60]
''', '''    set Cua_Tex[85] = Cua_Tex[60]
    // v20v: cartas de Armas.
    set Cua_Nom[86] = "Subir tier"
    set Cua_Des[86] = ""
    set Cua_Tex[86] = 'DS11'
    set Cua_Nom[87] = "Arma nueva"
    set Cua_Des[87] = ""
    set Cua_Tex[87] = 'DS11'
    set Cua_Nom[88] = "Vida extra"
    set Cua_Des[88] = ""
    set Cua_Tex[88] = 'DC09'
''')

assert U("set Cua_Tex[21] = 'DC09'") in src and U("set Cat_Tex[1] = 'DS11'") in src

# --- munición al terminar la oleada
cambia('call Frm_Fin()\n', 'call Frm_Fin()\n        call ExecuteFunc("ArmC_Municion")\n')

if prueba:
    for viejo, nuevo in (('lat\\\\v20u-', 'lat\\\\v20v-'), ('v20u-don.txt', 'v20v-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20v', 'prueba' if prueba else 'normal')
