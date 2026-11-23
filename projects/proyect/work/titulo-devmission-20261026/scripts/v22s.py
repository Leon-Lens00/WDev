#!/usr/bin/env python3
"""v22s (23/11/2026): diez cartas nuevas de Armas, de una categoría, con niveles; y el resultado de la votación de
Mutación Evo con los iconos de las ganadoras para todos.

Leon: "siguiente fase? adicional al momento de dar resultados, mostraba diferentes cartas a los jugadores, debe mostrar
a todos las mismas del ganador de la votacion y sepan que sale".
- Resultado de la votación: los nombres y textos ya salían de Cua_Gana (igual en todos), pero el icono de cada cuadro
  (Mut_Ico) sólo toma la textura al crear la pieza; Arm_Foto no la cambiaba y quedaba la de antes. Ahora los 3 iconos
  se rehacen con la textura de la ganadora al empezar la muestra (código común).
- Cartas nuevas (Armas; categoría al azar entre las que tiene y admiten la carta; la calidad da el valor T1..T5):
  111 Cadencia (todas), 112 Alcance, 113 Bala rápida, 114 Calibre grueso (área de golpe o explosión, radio de choque y
  tamaño de la bala; todas), 115 Cargador ampliado (+1 por nivel como mínimo), 116 Cartuchos extra (reserva),
  117 Perforación (subfusiles, rifles, francotiradores, escopetas), 118 Perdigones (escopetas), 119 Precisión
  (subfusiles, rifles, escopetas), 120 Puntería letal (crítico ×2). Sin cuerpo a cuerpo donde no tiene sentido.
- Cuentas por categoría: Car_TomC pasa a p × 112 + e × 16 + hueco (16 huecos por categoría; antes 8).
- El panel guarda la categoría de cada carta (Pan_HT) para describirla.
- Iconos: se reutilizan los de otras cartas (no hay texturas nuevas).
Uso: v22s.py ENTRADA.j SALIDA.j [prueba]   (normal de v22r; prueba de v22r-prueba).
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


# id, nombre, icono, hueco (Car_S), tope, T1..T5
CARTAS = [(111, 'Cadencia', 'DC0L', 3, 5, [4, 6, 8, 11, 14]),
          (112, 'Alcance', 'DC06', 4, 4, [5, 8, 11, 15, 20]),
          (113, 'Bala rápida', 'DC0N', 5, 4, [6, 9, 13, 18, 24]),
          (114, 'Calibre grueso', 'DC05', 6, 4, [6, 9, 13, 18, 24]),
          (115, 'Cargador ampliado', 'DC0S', 7, 4, [8, 12, 16, 22, 30]),
          (116, 'Cartuchos extra', 'DC0H', 8, 4, [10, 15, 20, 28, 36]),
          (117, 'Perforación', 'DC0D', 9, 3, [1, 1, 1, 2, 2]),
          (118, 'Perdigones', 'DC03', 10, 3, [1, 1, 1, 2, 2]),
          (119, 'Precisión', 'DC08', 11, 3, [10, 15, 20, 28, 36]),
          (120, 'Puntería letal', 'DC0B', 12, 4, [3, 4, 6, 8, 10])]

# 0) Globales.
cambia('integer Mut_Tope = 3\n', '''integer Mut_Tope = 3
// v22s: bonos por jugador y categoría (p * 7 + c) de las cartas 111-120; Pan_HT: categoría de cada carta del panel.
real array Arm_BCad
real array Arm_BAlc
real array Arm_BVel
real array Arm_BArea
real array Arm_BMag
real array Arm_BRes
real array Arm_BPrec
real array Arm_BCrit
integer array Arm_NMag
integer array Arm_BPerf
integer array Arm_BPerd
integer array Pan_HT
integer Pan_TipoV = 0
real Cuch_Mul = 1.
''')

# 1) Cuentas por categoría: 16 huecos.
cambia('p * 56 + e * 8 + Car_S[x] - 1', 'p * 112 + e * 16 + Car_S[x] - 1', 5)

# 2) Funciones de las cartas nuevas, antes de Arm_TipoAzar.
cambia('// v19y: categoría al azar entre las que tiene p (Cargador ágil, 84, sin cuerpo a cuerpo); -1 si no hay.\n', '''// v22s: cartas de Armas de una categoría (111-120).
function Car_EsArm takes integer x returns boolean
    return x >= 111 and x <= 120
endfunction

// v22s: la carta x vale para la categoría c (0 misiles, 1 subfusiles, 2 rifles, 3 francotiradores, 4 escopetas,
// 5 cuerpo a cuerpo, 6 explosivos).
function Car_ArmVale takes integer x, integer c returns boolean
    if x == 117 then
        return c >= 1 and c <= 4
    elseif x == 118 then
        return c == 4
    elseif x == 119 then
        return c == 1 or c == 2 or c == 4
    elseif x == 84 or x == 112 or x == 113 or x == 115 or x == 116 or x == 120 then
        return c != 5
    endif
    return true
endfunction

// v22s: efecto de la carta x (valor v) en la categoría e de p.
function Car_ArmAplicar takes integer p, integer x, integer v, integer e returns nothing
    local integer i = p * 7 + e
    local real f = v / 100.
    if x == 111 then
        set Arm_BCad[i] = Arm_BCad[i] + f
    elseif x == 112 then
        set Arm_BAlc[i] = Arm_BAlc[i] + f
    elseif x == 113 then
        set Arm_BVel[i] = Arm_BVel[i] + f
    elseif x == 114 then
        set Arm_BArea[i] = Arm_BArea[i] + f
    elseif x == 115 then
        set Arm_BMag[i] = Arm_BMag[i] + f
        set Arm_NMag[i] = Arm_NMag[i] + 1
    elseif x == 116 then
        set Arm_BRes[i] = Arm_BRes[i] + f
    elseif x == 117 then
        set Arm_BPerf[i] = Arm_BPerf[i] + v
    elseif x == 118 then
        set Arm_BPerd[i] = Arm_BPerd[i] + v
    elseif x == 119 then
        set Arm_BPrec[i] = RMinBJ(0.8, Arm_BPrec[i] + f)
    elseif x == 120 then
        set Arm_BCrit[i] = Arm_BCrit[i] + f
    endif
endfunction

// v22s: descripción de la carta x de valor v (Her_TipoTxt: la categoría).
function Car_ArmDes takes integer x, integer v returns string
    local string t = Her_TipoTxt
    if x == 111 then
        return "+" + I2S(v) + " % de cadencia|nde " + t + "."
    elseif x == 112 then
        return "+" + I2S(v) + " % de alcance|nde " + t + "."
    elseif x == 113 then
        return "+" + I2S(v) + " % de velocidad|nde bala de " + t + "."
    elseif x == 114 then
        return "+" + I2S(v) + " % de área y tamaño|nde bala de " + t + "."
    elseif x == 115 then
        return "+" + I2S(v) + " % de cargador de|n" + t + " (mín. +1)."
    elseif x == 116 then
        return "+" + I2S(v) + " % de reserva|nde " + t + "."
    elseif x == 117 then
        return "Las balas de " + t + "|natraviesan +" + I2S(v) + " enemigo."
    elseif x == 118 then
        return "+" + I2S(v) + " perdigón por|ndisparo de " + t + "."
    elseif x == 119 then
        return "-" + I2S(v) + " % de dispersión|nde " + t + "."
    endif
    return "+" + I2S(v) + " % de crítico (×2)|nde " + t + "."
endfunction

// v19y: categoría al azar entre las que tiene p (Cargador ágil, 84, sin cuerpo a cuerpo); -1 si no hay.
''')
cambia('        if Arm_Tier[p * 7 + c] > 0 and not (x == 84 and c == 5) and Car_Disp(p, x, c) then\n',
       '        // v22s: Car_ArmVale (antes sólo Cargador ágil sin cuerpo a cuerpo).\n'
       '        if Arm_Tier[p * 7 + c] > 0 and Car_ArmVale(x, c) and Car_Disp(p, x, c) then\n')

# 3) Cargador y reserva con sus cartas (antes de Arm_IntJ, que va antes de todos los usos).
cambia('''    // v21v: intervalo del arma w para p, Frm_CAD más rápido por forma.
    function Arm_IntJ takes integer p,integer w returns real
        return Arm_Int[w] / ( 1. + Frm_CAD * I2R(Frm_Nivel(p)) )
    endfunction
''', '''    // v22s: cargador del arma w para p con Cargador ampliado (al menos +1 por nivel) y reserva con Cartuchos extra.
    function Arm_MagJ takes integer p,integer w returns integer
        local integer i= p * 7 + w / 6
        return Arm_Mag[w] + IMaxBJ(Arm_NMag[i], R2I(I2R(Arm_Mag[w]) * Arm_BMag[i] + 0.5))
    endfunction

    function Arm_ResJ takes integer p,integer w returns integer
        return Arm_Res[w] + R2I(I2R(Arm_Res[w]) * Arm_BRes[p * 7 + w / 6] + 0.5)
    endfunction

    // v21v: intervalo del arma w para p, Frm_CAD más rápido por forma.
    // v22s: y Cadencia de su categoría.
    function Arm_IntJ takes integer p,integer w returns real
        return Arm_Int[w] / ( 1. + Frm_CAD * I2R(Frm_Nivel(p)) ) / ( 1. + Arm_BCad[p * 7 + w / 6] )
    endfunction
''')
cambia('        elseif Arm_Fin[p] <= 0. and Arm_Clip[i] < Arm_Mag[w] then\n',
       '        elseif Arm_Fin[p] <= 0. and Arm_Clip[i] < Arm_MagJ(p, w) then\n')
cambia('Arm_Mag[Arm_W(p)]', 'Arm_MagJ(p, Arm_W(p))', 2)
cambia('''                set Arm_Clip[i] = Arm_Mag[c * 6 + Arm_Tier[i] - 1]
                set Arm_Rva[i] = Arm_Res[c * 6 + Arm_Tier[i] - 1]
''', '''                set Arm_Clip[i] = Arm_MagJ(p, c * 6 + Arm_Tier[i] - 1)
                set Arm_Rva[i] = Arm_ResJ(p, c * 6 + Arm_Tier[i] - 1)
''')
cambia('''    set Arm_Clip[i] = Arm_Mag[w]
    set Arm_Rva[i] = Arm_Res[w]
''', '''    set Arm_Clip[i] = Arm_MagJ(p, w)
    set Arm_Rva[i] = Arm_ResJ(p, w)
''', 2)
cambia('''            set Arm_Clip[i]=Arm_Mag[w]
            set Arm_Rva[i]=IMinBJ(Arm_Res[w], Arm_Rva[i] + Arm_Mag[w])
''', '''            set Arm_Clip[i]=Arm_MagJ(p, w)
            set Arm_Rva[i]=IMinBJ(Arm_ResJ(p, w), Arm_Rva[i] + Arm_MagJ(p, w))
''')
cambia('            set Shop_Falta[c] = IMaxBJ(0, Arm_Res[x] - Arm_Rva[i])\n',
       '            set Shop_Falta[c] = IMaxBJ(0, Arm_ResJ(p, x) - Arm_Rva[i])\n')
cambia('        set falta = Arm_Res[x] - Arm_Rva[i]\n', '        set falta = Arm_ResJ(p, x) - Arm_Rva[i]\n')
cambia('    set n = IMinBJ(Arm_Res[x] - Arm_Rva[i], oro * Arm_Res[x] / ((Arm_Precio[x] + 100) / 4))\n',
       '    set n = IMinBJ(Arm_ResJ(p, x) - Arm_Rva[i], oro * Arm_Res[x] / ((Arm_Precio[x] + 100) / 4))\n')

# 4) Disparo: velocidad, área y tamaño, crítico y perforación (Arm_Tiro); alcance, precisión y perdigones (Arm_Emitir).
cambia('''    function Arm_Tiro takes integer this,integer w,real angle,real range returns nothing
        local unit a= s__RapidPair_actor[this]
        local integer m
        set Arm_Alcance=range
        call Arm_Bala(w / 6 , ModuloInteger(w, 6) + 1)
        set m=''', '''    function Arm_Tiro takes integer this,integer w,real angle,real range returns nothing
        local unit a= s__RapidPair_actor[this]
        local integer m
        local integer i= GetPlayerId(GetOwningPlayer(a)) * 7 + w / 6
        set Arm_Alcance=range
        call Arm_Bala(w / 6 , ModuloInteger(w, 6) + 1)
        // v22s: Bala rápida y Calibre grueso (radio de choque).
        set Arm_BalaVel=Arm_BalaVel * ( 1. + Arm_BVel[i] )
        set Arm_BalaRadio=Arm_BalaRadio * ( 1. + Arm_BArea[i] )
        set m=''')
cambia('''        set Bala_Crit[m]=Arm_Crit[w]
        set Bala_Area[m]=Arm_Area[w]
        set Bala_Perfora[m]=Arm_Perfora[w]
        if Arm_Perfora[w] > 0 then
            set Bala_Grupo[m]=CreateGroup()
        endif
        if w / 6 == 0 then
            set Bala_Calor[m]=true
            set Bala_Cima[m]=false
            set Calor_Vivos=Calor_Vivos + 1
            call s__Missile__set_scale(m,Arm_Area[w] / 160.)
        endif
''', '''        // v22s: Puntería letal, Calibre grueso (área y tamaño) y Perforación de la categoría.
        set Bala_Crit[m]=Arm_Crit[w] + Arm_BCrit[i]
        set Bala_Area[m]=Arm_Area[w] * ( 1. + Arm_BArea[i] )
        set Bala_Perfora[m]=Arm_Perfora[w] + Arm_BPerf[i]
        if Bala_Perfora[m] > 0 then
            set Bala_Grupo[m]=CreateGroup()
        endif
        if w / 6 == 0 then
            set Bala_Calor[m]=true
            set Bala_Cima[m]=false
            set Calor_Vivos=Calor_Vivos + 1
            call s__Missile__set_scale(m,Bala_Area[m] / 160.)
        elseif Arm_BArea[i] > 0. then
            call s__Missile__set_scale(m,s__RapidBolt_scaleOf(s__RapidPair_family[this]) * ( 1. + Arm_BArea[i] ))
        endif
''')
cambia('''        local real e= Arm_Area[w] / 150.
        local unit u
        local timer r= CreateTimer()
        if b then
            set u=CreateUnit(Player(15), 'hkB0' + t, x, y, angle * bj_RADTODEG)
            set e=Arm_Area[w] / 180.
''', '''        local real e= Arm_Area[w] * Cuch_Mul / 150.
        local unit u
        local timer r= CreateTimer()
        if b then
            set u=CreateUnit(Player(15), 'hkB0' + t, x, y, angle * bj_RADTODEG)
            set e=Arm_Area[w] * Cuch_Mul / 180.
''')
cambia('''        local real lim= Cos(( 60. + 8. * ModuloInteger(w, 6) ) * bj_DEGTORAD)
        set Cuch_N[p]=Cuch_N[p] + 1
        call Cuch_Efecto(x , y , angle , w , b)
        set s__GroundCollision_shaped=true
        call GroupEnumUnitsInRange(Arm_Enum, x, y, Arm_Area[w] + 128., null)
''', '''        local real lim= Cos(( 60. + 8. * ModuloInteger(w, 6) ) * bj_DEGTORAD)
        // v22s: Calibre grueso del cuerpo a cuerpo: golpe y efecto más grandes.
        local real ar= Arm_Area[w] * ( 1. + Arm_BArea[p * 7 + 5] )
        set Cuch_N[p]=Cuch_N[p] + 1
        set Cuch_Mul=1. + Arm_BArea[p * 7 + 5]
        call Cuch_Efecto(x , y , angle , w , b)
        set Cuch_Mul=1.
        set s__GroundCollision_shaped=true
        call GroupEnumUnitsInRange(Arm_Enum, x, y, ar + 128., null)
''')
cambia('            if s__GroundCollision_isTarget(u , a , owner) and s__GroundCollision_touches(u , x , y , Arm_Area[w]) then\n',
       '            if s__GroundCollision_isTarget(u , a , owner) and s__GroundCollision_touches(u , x , y , ar) then\n')
cambia('''        local real range= Arm_Alc[w]
        local real disp= Arm_Disp[w]
''', '''        // v22s: Alcance, Precisión y Perdigones de la categoría.
        local real range= Arm_Alc[w] * ( 1. + Arm_BAlc[p * 7 + c] )
        local real disp= Arm_Disp[w]
        local integer np= Arm_Perd[w] + Arm_BPerd[p * 7 + c]
''')
cambia('''            set Arm_Desvio[p]=RMinBJ(Arm_Desvio[p] + 0.3, 4.)
        endif
        loop
            exitwhen n >= Arm_Perd[w]
            if c == 4 and Arm_Perd[w] > 1 then
                // v16t-rpm: abanico fijo de -disp a +disp
                call Arm_Tiro(this , w , angle + ( - disp + 2. * disp * I2R(n) / I2R(Arm_Perd[w] - 1) ) * bj_DEGTORAD , range)
''', '''            set Arm_Desvio[p]=RMinBJ(Arm_Desvio[p] + 0.3, 4.)
        endif
        set disp=disp * ( 1. - Arm_BPrec[p * 7 + c] )
        loop
            exitwhen n >= np
            if c == 4 and np > 1 then
                // v16t-rpm: abanico fijo de -disp a +disp
                call Arm_Tiro(this , w , angle + ( - disp + 2. * disp * I2R(n) / I2R(np - 1) ) * bj_DEGTORAD , range)
''')

# 5) Mano de Armas: las cartas nuevas con su categoría.
cambia('''    set t = Arm_TipoAzar(p, 84)
    if t >= 0 then
        set lx[n] = 84
        set lt[n] = t
        set n = n + 1
    endif
''', '''    set t = Arm_TipoAzar(p, 84)
    if t >= 0 then
        set lx[n] = 84
        set lt[n] = t
        set n = n + 1
    endif
    // v22s: cartas nuevas de una categoría (111-120).
    set x = 111
    loop
        exitwhen x > 120
        set t = Arm_TipoAzar(p, x)
        if t >= 0 then
            set lx[n] = x
            set lt[n] = t
            set n = n + 1
        endif
        set x = x + 1
    endloop
''')

# 6) Efecto (Car_Contar ya lleva la cuenta al empezar Her_Aplicar).
cambia('''    elseif x == 109 then
        // v22r: Calibre menor, sin tope.
''', '''    elseif Car_EsArm(x) then
        // v22s: cartas nuevas de una categoría.
        set e = Her_TipoSel
        if e < 0 or e > 6 then
            set e = 1
        endif
        call Car_ArmAplicar(p, x, v, e)
    elseif x == 109 then
        // v22r: Calibre menor, sin tope.
''')

# 7) Textos: etiqueta y color de "Arma", descripción en la mano y en el panel.
cambia('''    elseif x == 83 or x == 84 then
        return "|cffff7070Arma|r|n"
''', '''    elseif x == 83 or x == 84 or Car_EsArm(x) then
        return "|cffff7070Arma|r|n"
''')
cambia('''    elseif x == 83 or x == 84 then
        set Her_R = 255
        set Her_G = 112
''', '''    elseif x == 83 or x == 84 or Car_EsArm(x) then
        set Her_R = 255
        set Her_G = 112
''')
cambia('''    if Car_EsInf(x) then
        return Her_Etiqueta(x) + Car_InfDes(x, v, false)
    endif
''', '''    if Car_EsInf(x) then
        return Her_Etiqueta(x) + Car_InfDes(x, v, false)
    elseif Car_EsArm(x) then
        return Her_Etiqueta(x) + Car_ArmDes(x, v)
    endif
''')
cambia('''    if Car_EsInf(x) then
        return Her_Etiqueta(x) + Car_InfDes(x, v, true)
    endif
''', '''    if Car_EsInf(x) then
        return Her_Etiqueta(x) + Car_InfDes(x, v, true)
    elseif Car_EsArm(x) then
        // v22s: categoría guardada en el panel (Pan_HT).
        set Her_TipoTxt = Cat_Nombre[Pan_TipoV]
        return Her_Etiqueta(x) + Car_ArmDes(x, v)
    endif
''')
cambia('''        set Pan_HX[p * 60 + i] = x
        set Pan_HQ[p * 60 + i] = q
''', '''        set Pan_HX[p * 60 + i] = x
        set Pan_HQ[p * 60 + i] = q
        set Pan_HT[p * 60 + i] = Her_TipoSel
''')
cambia('        call Cua_Izq(p, Pan_TT[9], Pan_HDes(p, Pan_HX[i], Pan_HQ[i]), 1586, 722, 0.021)\n',
       '        set Pan_TipoV = IMaxBJ(0, IMinBJ(6, Pan_HT[i]))\n'
       '        call Cua_Izq(p, Pan_TT[9], Pan_HDes(p, Pan_HX[i], Pan_HQ[i]), 1586, 722, 0.021)\n')

# 8) Resultado de la votación: iconos rehechos con la textura de la ganadora (la textura sólo prende al crear).
cambia('            call Arm_Foto(Mut_Ico[p * 3 + k], 128. * 398. / 400., 128. * 398. / 400., Cua_Tex[Cua_Gana[k]])\n', '')
cambia('''                if Mut_DT[p * 3 + k] == 0 then
                    set Mut_DT[p * 3 + k] = s__UIText_createEx(Player(p), 0., 0., 1.)
''', '''                // v22s: icono de la ganadora para todos: la pieza se rehace (la textura sólo prende al crearla).
                call RemoveUnit(Mut_Ico[p * 3 + k])
                set Mut_Ico[p * 3 + k] = Punt_Pieza(p, 128. * 398. / 400., 128. * 398. / 400., Cua_Tex[Cua_Gana[k]])
                if Mut_DT[p * 3 + k] == 0 then
                    set Mut_DT[p * 3 + k] = s__UIText_createEx(Player(p), 0., 0., 1.)
''')

# 9) Datos.
d = '    // v22s: cartas de Armas de una categoría (111-120): hueco, tope, nombre, icono y valores T1..T5.\n'
for x, nom, tex, s, m, vals in CARTAS:
    d += f'    set Car_S[{x}] = {s}\n    set Car_Max[{x}] = {m}\n'
    d += f'    set Cua_Nom[{x}] = "{nom}"\n    set Cua_Des[{x}] = ""\n    set Cua_Tex[{x}] = \'{tex}\'\n'
    d += ''.join(f'    set Her_Tabla[{x * 5 + q}] = {v}\n' for q, v in enumerate(vals))
cambia('    // v18y: quinta carta del paso del héroe.\n', d + '    // v18y: quinta carta del paso del héroe.\n')

assert src.index('function Car_ArmVale') < src.index('function Arm_TipoAzar')
assert src.index('function Car_EsArm') < src.index('function Her_Etiqueta')
assert src.index('function Arm_MagJ') < src.index('function Arm_Botones')
assert src.index('function Punt_Pieza') < src.index('function Cua_MuestraEmpezar')
assert 'Arm_Foto(Mut_Ico' not in src

if prueba:
    assert 'function Cop_Anotar' in src
    cambia('lat\\\\v22r-', 'lat\\\\v22s-', src.count('lat\\\\v22r-'))
    cambia('v22r-don.txt', 'v22s-don.txt', src.count('v22r-don.txt'))
    assert 'lat\\\\v22r-' not in src and 'v22r-don.txt' not in src, 'quedan registros v22r'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22s', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
