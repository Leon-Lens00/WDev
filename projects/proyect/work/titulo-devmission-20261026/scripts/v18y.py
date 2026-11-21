#!/usr/bin/env python3
"""v18y (15/11/2026): fase 9, mejoras del héroe al estilo PVZ (Leon: "vamos con las siguientes").

- 2 elecciones por descanso (pasos 3 y 4 de la tienda), 4 cartas cada una + una quinta, "Refrescar". Las cartas se
  sacan al cerrarse el cuadro de resultados (Ronda_DescansoEmpezar), con las estrellas de esa ronda ya contadas.
- Calidad de cada carta con los colores de tier de la tienda (T1 amarillo .. T5 morado): tirada 1-100 + suerte
  (2 por punto, tope 30) + 5 por estrella sobre 1; corte 45 / 72 / 88 / 97. Fondo y nombre con su color.
- Suerte por jugador: + estrellas de la ronda, +1 cada 5 bolsas recogidas, -1 al refrescar (mínimo 0). Se ve en
  la cabecera. Garantía: tras 3 descansos sin carta épica (T4) o mejor, la primera carta lo es.
- Refrescos: 2 al empezar, +1 cada 2 rondas; cambian las 4 cartas del paso.
- Maldita: "Pacto maldito" sale con un 8 % en lugar de la 4.ª carta, fondo morado oscuro y sin calidad.
- Efectos reales (valores revisables, por calidad T1..T5): Filo +6/9/13/18/25 % de daño de armas; Vitalidad
  +80/120/170/230/300 de vida; Zancada +10/15/20/26/34 de movimiento; Golpe de suerte +4/6/8/11/15 % de crítico
  (daño ×2, en balas, explosiones y cuchillo); Botín +8/12/17/23/30 % de oro de bolsas; Evasión +5/5/10/10/15 %
  (tope 50); Pacto maldito +40 % de daño y -25 % de vida máxima.
- Pisotón y Onda de choque (habilidades de Cairne) salen del sorteo hasta la fase 10, donde tendrán efecto.
Prueba: cada elección se anota (lat\\v18y-bolsas.txt). Registros v18x -> v18y.  Uso: v18y.py ENTRADA.j SALIDA.j [prueba]
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
modo = sys.argv[3] if len(sys.argv) > 3 else ''
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


cambia('integer array Cua_Activa\n', 'integer array Cua_Activa\n'
       'real array Her_Filo\nreal array Her_Crit\nreal array Her_Botin\ninteger array Her_Evasion\n'
       'integer array Her_Tabla\ninteger array Her_Suerte\ninteger array Her_Refrescos\ninteger array Her_SinOro\ninteger array Her_Cal\n'
       'boolean Her_Ok = false\nboolean Her_Alta = false\ninteger Her_R = 0\ninteger Her_G = 0\ninteger Her_B = 0\n'
       'string Her_Log = ""\n')

# 1. Daño de las armas: Filo y crítico del héroe.
cambia('    function Arm_Impacto takes integer m,unit caster,unit target returns nothing\n', '''    // v18y: Filo (más daño) y Golpe de suerte (crítico ×2) del jugador p. Código común, como el crítico del arma.
    function Her_Dano takes integer p,real d returns real
        if p < 0 or p > 11 then
            return d
        endif
        set d=d * ( 1. + Her_Filo[p] )
        if Her_Crit[p] > 0. and GetRandomReal(0., 1.) < Her_Crit[p] then
            set d=d * 2.
        endif
        return d
    endfunction

    function Arm_Impacto takes integer m,unit caster,unit target returns nothing
''')
cambia('''            set d=d * 2.
        endif
        call UnitDamageTarget(caster, target, d, false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)
''', '''            set d=d * 2.
        endif
        set d=Her_Dano(GetPlayerId(s__RapidBolt_owner[m]) , d)
        call UnitDamageTarget(caster, target, d, false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)
''')
cambia('                    call UnitDamageTarget(caster, u, Bala_Dano[m], false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)\n',
       '                    call UnitDamageTarget(caster, u, Her_Dano(GetPlayerId(owner) , Bala_Dano[m]), false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)\n')
cambia('                    call UnitDamageTarget(a, u, Arm_Dano[w], false, false, Dano_Ataque(Arm_Tipo[w]), Dano_TipoArma, null)\n',
       '                    call UnitDamageTarget(a, u, Her_Dano(p , Arm_Dano[w]), false, false, Dano_Ataque(Arm_Tipo[w]), Dano_TipoArma, null)\n')

# 2. Botín y suerte por bolsas.
cambia('''    call Oro_Dar(p, Bolsa_Oro[i])
    set Punt_Cogidas = Punt_Cogidas + 1
    set Punt_BolsasJ[p] = Punt_BolsasJ[p] + 1
''', '''    // v18y: Botín (más oro) y +1 de suerte cada 5 bolsas.
    set Bolsa_Oro[i] = R2I(Bolsa_Oro[i] * (1. + Her_Botin[p]) + 0.5)
    call Oro_Dar(p, Bolsa_Oro[i])
    set Punt_Cogidas = Punt_Cogidas + 1
    set Punt_BolsasJ[p] = Punt_BolsasJ[p] + 1
    if ModuloInteger(Punt_BolsasJ[p], 5) == 0 then
        set Her_Suerte[p] = Her_Suerte[p] + 1
    endif
''')

# 3. Cartas: textos, colores, sorteo, efecto y refresco.
HER1 = r'''// v18y, fase 9: valor de la mejora x en la calidad q (0..4 = T1..T5).
function Her_Valor takes integer x, integer q returns integer
    return Her_Tabla[x * 5 + q]
endfunction

// Color del texto del nombre (Her_R/G/B) por calidad; Pacto maldito lila.
function Her_ColorTxt takes integer q returns nothing
    set Her_R = 253
    set Her_G = 234
    set Her_B = 0
    if q == 1 then
        set Her_R = 101
        set Her_G = 253
        set Her_B = 0
    elseif q == 2 then
        set Her_R = 0
        set Her_G = 227
        set Her_B = 253
    elseif q == 3 then
        set Her_R = 74
        set Her_G = 125
        set Her_B = 255
    elseif q == 4 then
        set Her_R = 176
        set Her_G = 96
        set Her_B = 255
    elseif q == 5 then
        set Her_R = 192
        set Her_G = 112
        set Her_B = 255
    endif
endfunction

// Carta c del paso actual de p (paso 3 o 4): índice en Cua_HCand / Her_Cal.
function Her_K takes integer p, integer c returns integer
    return p * 10 + (Cua_Paso[p] - 3) * 5 + c
endfunction

function Her_Nombre takes integer p, integer c returns string
    if c == 4 then
        call Her_ColorTxt(2)
        return Cua_Nom[29]
    endif
    if Cua_HCand[Her_K(p, c)] == 28 then
        call Her_ColorTxt(5)
    else
        call Her_ColorTxt(Her_Cal[Her_K(p, c)])
    endif
    return Cua_Nom[Cua_HCand[Her_K(p, c)]]
endfunction

function Her_Des takes integer p, integer c returns string
    local integer x
    local integer v
    if c == 4 then
        if Her_Refrescos[p] <= 0 then
            return "|cff909090Sin refrescos.|nLa suerte: " + I2S(Her_Suerte[p]) + ".|r"
        endif
        return "Cambia las 4 cartas.|nQuedan " + I2S(Her_Refrescos[p]) + " (-1 suerte)."
    endif
    set x = Cua_HCand[Her_K(p, c)]
    set v = Her_Valor(x, Her_Cal[Her_K(p, c)])
    if x == 20 then
        return "+" + I2S(v) + " % de daño|nde tus armas."
    elseif x == 21 then
        return "+" + I2S(v) + " de vida|nmáxima."
    elseif x == 22 then
        return "+" + I2S(v) + " de velocidad|nde movimiento."
    elseif x == 23 then
        return "+" + I2S(v) + " % de golpe|ncrítico (daño ×2)."
    elseif x == 26 then
        return "+" + I2S(v) + " % de oro|nde las bolsas."
    elseif x == 27 then
        return "+" + I2S(v) + " % de probab.|nde esquivar golpes."
    elseif x == 28 then
        return "+40 % de daño, pero|n-25 % de vida máxima."
    endif
    return Cua_Des[x]
endfunction

// Color del fondo de la carta c (Her_R/G/B): calidad, maldita morado oscuro, refresco gris azulado.
function Her_Tinte takes integer p, integer c returns nothing
    local integer q
    if c == 4 then
        set Her_R = 90
        set Her_G = 110
        set Her_B = 150
        if Her_Refrescos[p] <= 0 then
            set Her_R = 70
            set Her_G = 70
            set Her_B = 80
        endif
        return
    endif
    if Cua_HCand[Her_K(p, c)] == 28 then
        set Her_R = 95
        set Her_G = 25
        set Her_B = 125
        return
    endif
    set q = Her_Cal[Her_K(p, c)]
    if q == 1 then
        set Her_R = 100
        set Her_G = 230
        set Her_B = 40
    elseif q == 2 then
        set Her_R = 30
        set Her_G = 200
        set Her_B = 225
    elseif q == 3 then
        set Her_R = 50
        set Her_G = 90
        set Her_B = 235
    elseif q == 4 then
        set Her_R = 150
        set Her_G = 60
        set Her_B = 235
    else
        set Her_R = 230
        set Her_G = 205
        set Her_B = 40
    endif
endfunction

'''
cambia('// v18o: votos al candidato x del paso k de Mutación Evo:', HER1 + '// v18o: votos al candidato x del paso k de Mutación Evo:')

HER2 = r'''// v18y: calidad de una carta para p (código común).
function Her_TiraCal takes integer p returns integer
    local integer r = GetRandomInt(1, 100) + IMinBJ(30, 2 * Her_Suerte[p]) + 5 * IMaxBJ(0, Punt_Estrellas - 1)
    if r > 97 then
        return 4
    elseif r > 88 then
        return 3
    elseif r > 72 then
        return 2
    elseif r > 45 then
        return 1
    endif
    return 0
endfunction

// v18y: 4 cartas distintas de las 6 de estadística (20-23, 26, 27); 8 % de que la 4.ª sea Pacto maldito (28).
function Her_Cartas takes integer p, integer k, boolean garantia returns nothing
    local integer i = 0
    local integer j
    local integer x
    local boolean rep
    loop
        exitwhen i > 3
        loop
            set x = 20 + GetRandomInt(0, 5)
            if x >= 24 then
                set x = x + 2
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
        set Her_Cal[k + i] = Her_TiraCal(p)
        set i = i + 1
    endloop
    if GetRandomInt(1, 100) <= 8 then
        set Cua_HCand[k + 3] = 28
        set Her_Cal[k + 3] = 0
    endif
    if garantia and Her_Cal[k] < 3 then
        set Her_Cal[k] = 3
    endif
    set i = 0
    loop
        exitwhen i > 3
        if Her_Cal[k + i] >= 3 and Cua_HCand[k + i] != 28 then
            set Her_Alta = true
        endif
        set i = i + 1
    endloop
endfunction

// v18y: al cerrarse el cuadro de resultados (Ronda_DescansoEmpezar, por nombre): suerte, refrescos y cartas.
function Her_Sortear takes nothing returns nothing
    local integer p = 0
    local boolean g
    loop
        exitwhen p > 11
        if Game_On[p] then
            if not Her_Ok then
                set Her_Refrescos[p] = 2
            elseif ModuloInteger(Ronda_Numero, 2) == 0 then
                set Her_Refrescos[p] = Her_Refrescos[p] + 1
            endif
            set Her_Suerte[p] = Her_Suerte[p] + IMaxBJ(0, Punt_Estrellas)
            set g = Her_SinOro[p] >= 3
            set Her_Alta = false
            call Her_Cartas(p, p * 10, g)
            call Her_Cartas(p, p * 10 + 5, false)
            if Her_Alta then
                set Her_SinOro[p] = 0
            else
                set Her_SinOro[p] = Her_SinOro[p] + 1
            endif
            call Cua_Pintar(p)
            call Cua_Ver(p)
        endif
        set p = p + 1
    endloop
    set Her_Ok = true
endfunction

// v18y: efecto de la mejora x de calidad q en el héroe de p (código común, desde el clic sincronizado).
function Her_Aplicar takes integer p, integer x, integer q returns nothing
    local unit u = Game_Hero[p]
    local integer v = Her_Valor(x, q)
    local integer e
    local real hp
    if x == 20 then
        set Her_Filo[p] = Her_Filo[p] + v / 100.
    elseif x == 21 and u != null then
        call BM_VidaMax(u, v)
        call SetWidgetLife(u, GetWidgetLife(u) + v)
    elseif x == 22 and u != null then
        call SetUnitMoveSpeed(u, GetUnitMoveSpeed(u) + v)
    elseif x == 23 then
        set Her_Crit[p] = Her_Crit[p] + v / 100.
    elseif x == 26 then
        set Her_Botin[p] = Her_Botin[p] + v / 100.
    elseif x == 27 and u != null then
        set e = IMinBJ(50, Her_Evasion[p] + v)
        if Her_Evasion[p] >= 5 then
            call UnitRemoveAbility(u, 'SpE0' + Her_Evasion[p] / 5 - 1)
        endif
        set Her_Evasion[p] = e
        call UnitAddAbility(u, 'SpE0' + e / 5 - 1)
        call UnitMakeAbilityPermanent(u, true, 'SpE0' + e / 5 - 1)
    elseif x == 28 and u != null then
        set Her_Filo[p] = Her_Filo[p] + 0.4
        set hp = GetUnitState(u, UNIT_STATE_MAX_LIFE)
        call BM_VidaMax(u, - R2I(hp * 0.25 + 0.5))
        call SetWidgetLife(u, RMinBJ(GetWidgetLife(u), GetUnitState(u, UNIT_STATE_MAX_LIFE)))
    endif
    set Her_Log = "heroe " + I2S(p) + ": " + Cua_Nom[x] + " T" + I2S(q + 1) + " +" + I2S(v) + " suerte " + I2S(Her_Suerte[p]) + " refrescos " + I2S(Her_Refrescos[p])
    set u = null
endfunction

// v18y: quinta carta del paso del héroe: cambia las 4 cartas (cuesta 1 de suerte).
function Her_Refrescar takes integer p returns nothing
    if Her_Refrescos[p] <= 0 then
        call UI_Error(p)
        return
    endif
    call UI_Click(p)
    set Her_Refrescos[p] = Her_Refrescos[p] - 1
    set Her_Suerte[p] = IMaxBJ(0, Her_Suerte[p] - 1)
    call Her_Cartas(p, Her_K(p, 0), false)
    call Cua_Pintar(p)
    call Cua_Ver(p)
endfunction

'''
cambia('// Clic en el botón de la posición s (0-8).', HER2 + '// Clic en el botón de la posición s (0-8).')

# 4. Cuadros del paso del héroe: 5 (4 cartas + refresco); item 29; colores y textos.
cambia('''    if Cua_Paso[p] < 3 then
        return Cua_Cnt[Cua_Paso[p]]
    endif
    return 4
endfunction
''', '''    if Cua_Paso[p] < 3 then
        return Cua_Cnt[Cua_Paso[p]]
    endif
    // v18y: 4 cartas y el refresco.
    return 5
endfunction
''')
cambia('''    return Cua_HCand[p * 10 + (Cua_Paso[p] - 3) * 5 + c]
endfunction
''', '''    if c == 4 then
        return 29
    endif
    return Cua_HCand[p * 10 + (Cua_Paso[p] - 3) * 5 + c]
endfunction
''')
cambia('''    return Cua_PasoNom[Cua_Paso[p]]
endfunction
''', '''    if Cua_Paso[p] >= 3 and Cua_Paso[p] < 5 then
        return Cua_PasoNom[Cua_Paso[p]] + " · suerte " + I2S(Her_Suerte[p])
    endif
    return Cua_PasoNom[Cua_Paso[p]]
endfunction
''')
cambia('''            if ver and c >= 0 and ModuloInteger(c, 2) == 0 and c / 2 < n then
                set a = 255
''', '''            if ver and c >= 0 and ModuloInteger(c, 2) == 0 and c / 2 < n then
                set a = 255
                // v18y: color de calidad de cada carta del héroe.
                if not inicio and Cua_Modo[p] == 1 and Cua_Paso[p] >= 3 then
                    call Her_Tinte(p, c / 2)
                    set r = Her_R
                    set g = Her_G
                    set b = Her_B
                endif
''')
cambia('''            call Cua_Centro(p, Cua_TN[c], Cua_Nom[Cua_Item(p, c)], Cua_PX(s), 392, 0.025)
            if inicio then
                call Cua_Izq(p, Cua_TD[c], Cua_InicioDes(p, c), Cua_PX(s) - 150, 440, 0.021)
            else
''', '''            if not inicio and Cua_Modo[p] == 1 and Cua_Paso[p] >= 3 then
                // v18y: nombre con el color de su calidad y valor en la descripción.
                call Cua_Centro(p, Cua_TN[c], Her_Nombre(p, c), Cua_PX(s), 392, 0.025)
                call SetTextTagColor(Cua_TN[c], Her_R, Her_G, Her_B, 255)
                call Cua_Izq(p, Cua_TD[c], Her_Des(p, c), Cua_PX(s) - 150, 440, 0.021)
            else
                call Cua_Centro(p, Cua_TN[c], Cua_Nom[Cua_Item(p, c)], Cua_PX(s), 392, 0.025)
                call SetTextTagColor(Cua_TN[c], 235, 240, 245, 255)
            endif
            if inicio then
                call Cua_Izq(p, Cua_TD[c], Cua_InicioDes(p, c), Cua_PX(s) - 150, 440, 0.021)
            elseif Cua_Modo[p] == 1 and Cua_Paso[p] >= 3 then
            else
''')
# Clic: refresco y efecto.
cambia('''    set x = Cua_Item(p, c / 2)
    call UI_Click(p)
    set Cua_Elegido[p * 5 + Cua_Paso[p]] = x
''', '''    set x = Cua_Item(p, c / 2)
    // v18y: la quinta carta del héroe refresca; las otras aplican su mejora.
    if Cua_Paso[p] >= 3 and c / 2 == 4 then
        call Her_Refrescar(p)
        return
    endif
    call UI_Click(p)
    set Cua_Elegido[p * 5 + Cua_Paso[p]] = x
    if Cua_Paso[p] >= 3 then
        call Her_Aplicar(p, x, Her_Cal[Her_K(p, c / 2)])
    endif
''')
# Sorteo del héroe: ya no al acabar la oleada, sino al cerrarse el cuadro.
cambia('''            call Cua_Elegir(20, 9, 4, true, p * 10)
            call Cua_Elegir(20, 9, 4, true, p * 10 + 5)
''', '')
cambia('''function Ronda_DescansoEmpezar takes nothing returns nothing
    if Ronda_Fase != 2 or not Ronda_Descanso then
        return
    endif
''', '''function Ronda_DescansoEmpezar takes nothing returns nothing
    if Ronda_Fase != 2 or not Ronda_Descanso then
        return
    endif
    // v18y: cartas del héroe con las estrellas de esta ronda.
    call ExecuteFunc("Her_Sortear")
''')
cambia('''    set Cua_Tex[28] = 'DC0C'
''', '''    set Cua_Tex[28] = 'DC0C'
    // v18y: quinta carta del paso del héroe.
    set Cua_Nom[29] = "Refrescar"
    set Cua_Des[29] = ""
    set Cua_Tex[29] = 'DC0F'
    // v18y: valores de las mejoras del héroe por calidad (T1..T5).
    set Her_Tabla[100] = 6\n    set Her_Tabla[101] = 9\n    set Her_Tabla[102] = 13\n    set Her_Tabla[103] = 18\n    set Her_Tabla[104] = 25\n    set Her_Tabla[105] = 80\n    set Her_Tabla[106] = 120\n    set Her_Tabla[107] = 170\n    set Her_Tabla[108] = 230\n    set Her_Tabla[109] = 300\n    set Her_Tabla[110] = 10\n    set Her_Tabla[111] = 15\n    set Her_Tabla[112] = 20\n    set Her_Tabla[113] = 26\n    set Her_Tabla[114] = 34\n    set Her_Tabla[115] = 4\n    set Her_Tabla[116] = 6\n    set Her_Tabla[117] = 8\n    set Her_Tabla[118] = 11\n    set Her_Tabla[119] = 15\n    set Her_Tabla[130] = 8\n    set Her_Tabla[131] = 12\n    set Her_Tabla[132] = 17\n    set Her_Tabla[133] = 23\n    set Her_Tabla[134] = 30\n    set Her_Tabla[135] = 5\n    set Her_Tabla[136] = 5\n    set Her_Tabla[137] = 10\n    set Her_Tabla[138] = 10\n    set Her_Tabla[139] = 15\n''')

if modo == 'prueba':
    cambia('''    if Cua_Paso[p] >= 3 then
        call Her_Aplicar(p, x, Her_Cal[Her_K(p, c / 2)])
    endif
''', '''    if Cua_Paso[p] >= 3 then
        call Her_Aplicar(p, x, Her_Cal[Her_K(p, c / 2)])
        call ExecuteFunc("Her_Anotar")
    endif
''')
    cambia('// v18x-prueba: activas y unidades que recibió cada mutación', '''// v18y-prueba: la última mejora del héroe aplicada.
function Her_Anotar takes nothing returns nothing
    call Bolsa_Anotar(Her_Log)
endfunction

// v18x-prueba: activas y unidades que recibió cada mutación''')
    assert src.count('lat\\\\v18x-') == 4, src.count('lat\\\\v18x-')
    src = src.replace('lat\\\\v18x-', 'lat\\\\v18y-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18y', modo or 'normal')
