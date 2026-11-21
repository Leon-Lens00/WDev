#!/usr/bin/env python3
"""v19y (19/11/2026), fase 6 del plan devmission-v20-mutaciones-rachas-mvp.md: rachas, pull de racha, first blood,
tiers fuertes y mejoras por tipo de arma. Cifras del plan, aún sin calibrar con registros de partidas.
- Rachas más difíciles: sin morir 40/90/150/220/300/390/490/600 (antes cada 25; tras la última, cada 100 más);
  multi-kill 12/22/35/55 en 3 s (antes 8/15/25/40). "Perdió su racha" desde 40.
- Cada tier nuevo alcanzado durante la oleada suma 1 punto de racha. Al abrirse las cartas del héroe del descanso hay
  1 pull extra por cada 2 puntos (máx. 2), con calidad mínima T2, T3 si el tier más alto fue 4+ y T4 si fue 7+.
- First blood (por oleada; Her_FB_CADA_OLEADA = false lo deja una vez por partida): un pull extra de calidad T3+, sin
  malditas ni Purga.
- Los pulls extra son pasos nuevos de las cartas del héroe (paso 5, 6 y 7) con su refresco; las cartas de cada jugador
  pasan de p*10 a p*40 y Cua_Elegido de p*5 a p*12.
- Tiers fuertes: Filo, Vitalidad, Zancada, Golpe de suerte, Botín y Bolsa doble valen ×1 / ×1,5 / ×2,5 / ×4 / ×5 del
  valor T1. Las tiradas normales no pasan de T3 (y la garantía tras 3 descansos da T3); T4-T5 sólo salen en los pulls
  extra.
- Mejoras por tipo de arma (tipo al azar entre las categorías que tiene el jugador; se suman al bono general):
  83 "Calibre" +10/15/25/40/50 % de daño de ese tipo; 84 "Cargador ágil" −8/12/20/32/40 % de recarga de ese tipo
  (máx. −60 %; nunca cuerpo a cuerpo). Daño en Arm_Impacto, explosiones y cuerpo a cuerpo; recarga en
  Arm_BotonRecarga. Hueco Her_Pool[12..13].
- Prueba: al repartir las cartas se anotan pulls extra, puntos de racha, tier más alto y first blood de cada jugador.
Uso: v19y.py ENTRADA.j SALIDA.j [prueba]   (normal de v19x; prueba de v19x-prueba)
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


# --- globales ---
cambia('real array Bat_Total\n', '''real array Bat_Total
// v19y: rachas, pulls extra y mejoras por tipo de arma.
constant boolean Her_FB_CADA_OLEADA = true
boolean Her_FBDado = false
boolean array Her_FB
boolean array Her_ExFB
integer array Her_Extra
integer array Her_ExMin
integer array Racha_Pts
integer array Racha_Max
integer array Racha_TierUmbral
integer array Her_Tipo
integer Her_TipoSel = 0
string Her_TipoTxt = ""
real array Arm_Calibre
real array Arm_Agil
integer array Arm_UltTipo
''')

# --- rachas ---
cambia('''    set t = IMinBJ(8, Racha_N[p] / 25)
    if t > Racha_Tier[p] or ( t == 8 and Racha_N[p] >= Racha_TierN[p] + 25 ) then
        set Racha_Tier[p] = t''', '''    // v19y: umbrales de Racha_TierUmbral (40 ... 600); tras el último, cada 100.
    set t = 8
    loop
        exitwhen t == 0 or Racha_N[p] >= Racha_TierUmbral[t]
        set t = t - 1
    endloop
    if t > Racha_Tier[p] or ( t == 8 and Racha_N[p] >= Racha_TierN[p] + 100 ) then
        if Ronda_Activa and not Ronda_Descanso then
            set Racha_Pts[p] = Racha_Pts[p] + 1
            set Racha_Max[p] = IMaxBJ(Racha_Max[p], t)
        endif
        set Racha_Tier[p] = t''')
cambia('''    if t > Racha_MultiTier[p] or ( t == 4 and Racha_Multi[p] >= Racha_MultiN[p] + 15 ) then
        set Racha_MultiTier[p] = t''', '''    if t > Racha_MultiTier[p] or ( t == 4 and Racha_Multi[p] >= Racha_MultiN[p] + 15 ) then
        if Ronda_Activa and not Ronda_Descanso then
            set Racha_Pts[p] = Racha_Pts[p] + 1
            set Racha_Max[p] = IMaxBJ(Racha_Max[p], t)
        endif
        set Racha_MultiTier[p] = t''')
cambia('''        set Racha_PrimeraRonda = Ronda_Numero
''', '''        set Racha_PrimeraRonda = Ronda_Numero
        // v19y: first blood da un pull extra de calidad T3+ en el próximo descanso.
        if Her_FB_CADA_OLEADA or not Her_FBDado then
            set Her_FB[p] = true
            set Her_FBDado = true
        endif
''')
for viejo, nuevo in ((8, 12), (15, 22), (25, 35), (40, 55)):
    k = (8, 15, 25, 40).index(viejo) + 1
    cambia(f'        set Racha_MultiUmbral[{k}] = {viejo}\n', f'        set Racha_MultiUmbral[{k}] = {nuevo}\n')
cambia('        set Racha_MultiUmbral[4] = 55\n', '        set Racha_MultiUmbral[4] = 55\n' + ''.join(
    f'        set Racha_TierUmbral[{i + 1}] = {v}\n' for i, v in enumerate((40, 90, 150, 220, 300, 390, 490, 600))))
cambia('''    if Racha_N[p] >= 25 then
        call Racha_Poner("|cffff6666perdió su racha|r''', '''    if Racha_N[p] >= 40 then
        call Racha_Poner("|cffff6666perdió su racha|r''')

# --- tiers fuertes (×1 / ×1,5 / ×2,5 / ×4 / ×5 de T1) ---
for x in (20, 21, 22, 23, 26, 38):
    base = int(re.search(r'set Her_Tabla\[%d\] = (\d+)\n' % (x * 5), src).group(1))
    for q, f in enumerate((1, 1.5, 2.5, 4, 5)):
        pat = re.compile(r'set Her_Tabla\[%d\] = \d+\n' % (x * 5 + q))
        assert len(pat.findall(src)) == 1, (x, q)
        src = pat.sub('set Her_Tabla[%d] = %d\n' % (x * 5 + q, int(base * f + 0.5)), src)
cambia('''// v18y: calidad de una carta para p (código común).
function Her_TiraCal takes integer p returns integer''', '''// v18y: calidad de una carta para p (código común). v19y: sin tope (sólo pulls extra); Her_TiraCal hasta T3.
function Her_TiraCalBruto takes integer p returns integer''')
cambia('''// v18y: 4 cartas distintas''', '''function Her_TiraCal takes integer p returns integer
    return IMinBJ(2, Her_TiraCalBruto(p))
endfunction

// v18y: 4 cartas distintas''')
cambia('''    if garantia and Her_Cal[k] < 3 then
        set Her_Cal[k] = 3
    endif''', '''    if garantia and Her_Cal[k] < 2 then
        set Her_Cal[k] = 2
    endif''')
cambia('if Her_Cal[k + i] >= 3 and not Her_EsMaldita(Cua_HCand[k + i])', 'if Her_Cal[k + i] >= 2 and not Her_EsMaldita(Cua_HCand[k + i])')

# --- tipo de arma ---
cambia('''// Textos del dash en el HUD''', '''// v19y: categoría al azar entre las que tiene p (Cargador ágil, 84, sin cuerpo a cuerpo); -1 si no hay.
function Arm_TipoAzar takes integer p, integer x returns integer
    local integer array l
    local integer n = 0
    local integer c = 0
    loop
        exitwhen c > 6
        if Arm_Tier[p * 7 + c] > 0 and not (x == 84 and c == 5) then
            set l[n] = c
            set n = n + 1
        endif
        set c = c + 1
    endloop
    if n == 0 then
        return -1
    endif
    return l[GetRandomInt(0, n - 1)]
endfunction

function Arm_Carta takes integer p, integer x returns integer
    if x == 84 and Arm_TipoAzar(p, 84) < 0 then
        return 83
    endif
    return x
endfunction

// Textos del dash en el HUD''')
cambia('''    // v18y: Filo (más daño) y Golpe de suerte''', '''    // v19y: Calibre del tipo de arma en la mano.
    function Arm_Calibrar takes integer p,real d returns real
        if p < 0 or p > 11 then
            return d
        endif
        return d * ( 1. + Arm_Calibre[p * 7 + Arm_Cat[p]] )
    endfunction

    // v18y: Filo (más daño) y Golpe de suerte''')
cambia('set d=Her_Dano(GetPlayerId(s__RapidBolt_owner[m]) , d)',
       'set d=Arm_Calibrar(GetPlayerId(s__RapidBolt_owner[m]) , Her_Dano(GetPlayerId(s__RapidBolt_owner[m]) , d))')
cambia('Her_Dano(GetPlayerId(owner) , Bala_Dano[m])', 'Arm_Calibrar(GetPlayerId(owner) , Her_Dano(GetPlayerId(owner) , Bala_Dano[m]))')
cambia('Her_Dano(p , Arm_Dano[w])', 'Arm_Calibrar(p , Her_Dano(p , Arm_Dano[w]))')
cambia('set Arm_Fin[p]=(TimerGetElapsed(s__RapidPair_clock)) + Arm_Rec[w]\n',
       'set Arm_Fin[p]=(TimerGetElapsed(s__RapidPair_clock)) + Arm_Rec[w] * ( 1. - Arm_Agil[i] )\n')

# --- cartas nuevas ---
cambia('    set Her_Pool[11] = 81\n', '    set Her_Pool[11] = 81\n    set Her_Pool[12] = 83\n    set Her_Pool[13] = 84\n'
       + ''.join(f'    set Her_Tabla[{x * 5 + q}] = {v}\n' for x, vs in ((83, (10, 15, 25, 40, 50)), (84, (8, 12, 20, 32, 40)))
                 for q, v in enumerate(vs)))
cambia('''    set Cua_Tex[82] = 'DC0Q'
''', '''    set Cua_Tex[82] = 'DC0Q'
    // v19y: mejoras por tipo de arma.
    set Cua_Nom[83] = "Calibre"
    set Cua_Des[83] = "Más daño de|nun tipo de arma."
    set Cua_Tex[83] = 'DC0R'
    set Cua_Nom[84] = "Cargador ágil"
    set Cua_Des[84] = "Menos recarga de|nun tipo de arma."
    set Cua_Tex[84] = 'DC0S'
''')
cambia('''            set x = Her_Pool[GetRandomInt(0, 11)]
            if x == 24 then
                set x = Dash_Carta(p)
            elseif x == 81 then
                set x = Bat_Carta(p)
            endif''', '''            set x = Her_Pool[GetRandomInt(0, 13)]
            if x == 24 then
                set x = Dash_Carta(p)
            elseif x == 81 then
                set x = Bat_Carta(p)
            elseif x == 83 or x == 84 then
                set x = Arm_Carta(p, x)
            endif''')
cambia('''        set Cua_HCand[k + i] = x
        set Her_Cal[k + i] = Her_TiraCal(p)''', '''        set Cua_HCand[k + i] = x
        set Her_Tipo[k + i] = Arm_TipoAzar(p, x)
        set Her_Cal[k + i] = Her_TiraCal(p)''')
cambia('''    elseif x == 81 or x == 82 then
        return "|cffffe680Linterna|r|n"''', '''    elseif x == 81 or x == 82 then
        return "|cffffe680Linterna|r|n"
    elseif x == 83 or x == 84 then
        return "|cffff7070Arma|r|n"''')
cambia('''    elseif x == 81 or x == 82 then
        set Her_R = 255
        set Her_G = 230
        set Her_B = 128''', '''    elseif x == 81 or x == 82 then
        set Her_R = 255
        set Her_G = 230
        set Her_B = 128
    elseif x == 83 or x == 84 then
        set Her_R = 255
        set Her_G = 112
        set Her_B = 112''')
cambia('''    set x = Cua_HCand[Her_K(p, c)]
    if x >= 40 and x < 78 then''', '''    set x = Cua_HCand[Her_K(p, c)]
    set Her_TipoTxt = Cat_Nombre[IMaxBJ(0, Her_Tipo[Her_K(p, c)])]
    if x >= 40 and x < 78 then''')
cambia('''function Pan_HDes takes integer p, integer x, integer q returns string
    local integer v
''', '''function Pan_HDes takes integer p, integer x, integer q returns string
    local integer v
    set Her_TipoTxt = Cat_Nombre[Arm_UltTipo[p * 2 + IMaxBJ(0, IMinBJ(1, x - 83))]]
''')
cambia('''    elseif x == 81 then
        return Her_Txt + "La batería dura +25 %|n(hasta 3 veces)."''', '''    elseif x == 83 then
        return Her_Txt + "+" + I2S(v) + " % de daño|nde " + Her_TipoTxt + "."
    elseif x == 84 then
        return Her_Txt + "-" + I2S(v) + " % de recarga|nde " + Her_TipoTxt + "."
    elseif x == 81 then
        return Her_Txt + "La batería dura +25 %|n(hasta 3 veces)."''', 2)
cambia('''    elseif x == 81 then
        set Bat_Pilas[p] = IMinBJ(3, Bat_Pilas[p] + 1)''', '''    elseif x == 83 or x == 84 then
        // v19y: tipo de arma de la carta elegida (Her_TipoSel, de Cua_Hacer).
        set e = Her_TipoSel
        if e < 0 or e > 6 then
            set e = 1
        endif
        set Arm_UltTipo[p * 2 + x - 83] = e
        if x == 83 then
            set Arm_Calibre[p * 7 + e] = Arm_Calibre[p * 7 + e] + v / 100.
        else
            set Arm_Agil[p * 7 + e] = RMinBJ(0.6, Arm_Agil[p * 7 + e] + v / 100.)
        endif
    elseif x == 81 then
        set Bat_Pilas[p] = IMinBJ(3, Bat_Pilas[p] + 1)''')
cambia('''    if Cua_Paso[p] >= 3 then
        call Her_Aplicar(p, x, Her_Cal[Her_K(p, c / 2)])''', '''    if Cua_Paso[p] >= 3 then
        set Her_TipoSel = Her_Tipo[Her_K(p, c / 2)]
        call Her_Aplicar(p, x, Her_Cal[Her_K(p, c / 2)])''')

# --- pasos extra de las cartas del héroe ---
cambia('''function Cua_Cuantos takes integer p returns integer''', '''// v19y: paso en que terminan las cartas del héroe de p (5 + pulls extra de racha y first blood).
function Her_FinDe takes integer p returns integer
    return 5 + Her_Extra[p]
endfunction

function Her_PasoNom takes integer p returns string
    local integer k = Cua_Paso[p] - 3
    if k < 2 then
        return "Mejora del héroe (" + I2S(k + 1) + "/2)"
    elseif k == 2 and Her_ExFB[p] then
        return "First blood · T3+"
    endif
    return "Pull de racha · T" + I2S(Her_ExMin[p * 8 + k - 2] + 1) + "+"
endfunction

function Cua_Cuantos takes integer p returns integer''')
cambia('return Cua_HCand[p * 10 + (Cua_Paso[p] - 3) * 5 + c]', 'return Cua_HCand[p * 40 + (Cua_Paso[p] - 3) * 5 + c]')
cambia('    return p * 10 + (Cua_Paso[p] - 3) * 5 + c\n', '    return p * 40 + (Cua_Paso[p] - 3) * 5 + c\n')
cambia('if Game_On[p] and Cua_Paso[p] > k and Cua_Elegido[p * 5 + k] == x then', 'if Game_On[p] and Cua_Paso[p] > k and Cua_Elegido[p * 12 + k] == x then')
cambia('set Cua_Elegido[p * 5 + Cua_Paso[p]] = x', 'set Cua_Elegido[p * 12 + Cua_Paso[p]] = x')
cambia('    if Cua_Paso[p] >= 5 and Cua_Modo[p] == 1 then\n        return', '    if Cua_Paso[p] >= Her_FinDe(p) and Cua_Modo[p] == 1 then\n        return')
cambia('''    if Cua_Paso[p] >= 3 and Cua_Paso[p] < 5 then
        return Cua_PasoNom[Cua_Paso[p]] + " · suerte "''', '''    if Cua_Paso[p] >= 3 and Cua_Paso[p] < Her_FinDe(p) then
        return Her_PasoNom(p) + " · suerte "''')
cambia('''    elseif Cua_Paso[p] < 5 then
        set Her_R = 255
        set Her_G = 210''', '''    elseif Cua_Paso[p] < Her_FinDe(p) then
        set Her_R = 255
        set Her_G = 210''')
cambia('return Cua_Paso[p] < 3 or Cua_Paso[p] >= 5', 'return Cua_Paso[p] < 3 or Cua_Paso[p] >= Her_FinDe(p)')
cambia('''    elseif Cua_Paso[p] < 5 then
        return "Elige 2 mejoras de|ntu héroe (" + I2S(Cua_Paso[p] - 3) + "/2)."
    endif
    return "|cff909090Hecho: ya elegiste|nlas 2 mejoras.|r"''', '''    elseif Cua_Paso[p] < Her_FinDe(p) then
        return "Elige " + I2S(2 + Her_Extra[p]) + " mejoras de|ntu héroe (" + I2S(Cua_Paso[p] - 3) + "/" + I2S(2 + Her_Extra[p]) + ")."
    endif
    return "|cff909090Hecho: ya elegiste|ntus mejoras.|r"''')
cambia('local boolean ver = Cua_Open[p] and (inicio or Cua_Modo[p] == 2 or Cua_Paso[p] < 5)',
       'local boolean ver = Cua_Open[p] and (inicio or Cua_Modo[p] == 2 or Cua_Paso[p] < Her_FinDe(p))')
cambia('''        call Cua_InicioCab(p)
        if Cua_Paso[p] >= 5 then''', '''        call Cua_InicioCab(p)
        if Cua_Paso[p] >= Her_FinDe(p) then''')
cambia('    if Cua_Paso[p] == 3 or Cua_Paso[p] >= 5 then\n        set Cua_Modo[p] = 0',
       '    if Cua_Paso[p] == 3 or Cua_Paso[p] >= Her_FinDe(p) then\n        set Cua_Modo[p] = 0')
cambia('if Cua_Paso[p] >= 5 or c < 0 or ModuloInteger(c, 2) != 0 or c / 2 >= n then',
       'if Cua_Paso[p] >= Her_FinDe(p) or c < 0 or ModuloInteger(c, 2) != 0 or c / 2 >= n then')
assert 'Cua_Paso[p] >= 5' not in src and 'Cua_Paso[p] < 5' not in src

cambia('''// v18y: al cerrarse el cuadro de resultados (Ronda_DescansoEmpezar, por nombre): suerte, refrescos y cartas.''',
       '''// v19y: 4 cartas de un pull extra: sin malditas ni Purga, calidad mínima minq y sin el tope de las tiradas normales.
function Her_CartasExtra takes integer p, integer k, integer minq returns nothing
    local integer i = 0
    local integer j
    local integer x
    local boolean alta = Her_Alta
    call Her_Cartas(p, k, false)
    set Her_Alta = alta
    loop
        exitwhen i > 3
        set x = Cua_HCand[k + i]
        if x == 39 or Her_EsMaldita(x) then
            loop
                set x = Her_Pool[GetRandomInt(0, 9)]
                set j = 0
                loop
                    exitwhen j > 3 or Cua_HCand[k + j] == x
                    set j = j + 1
                endloop
                exitwhen j > 3
            endloop
            set Cua_HCand[k + i] = x
            set Her_Tipo[k + i] = Arm_TipoAzar(p, x)
        endif
        if x < 40 or x >= 78 then
            set Her_Cal[k + i] = IMaxBJ(minq, Her_TiraCalBruto(p))
        endif
        set i = i + 1
    endloop
endfunction

// v18y: al cerrarse el cuadro de resultados (Ronda_DescansoEmpezar, por nombre): suerte, refrescos y cartas.''')
cambia('''function Her_Sortear takes nothing returns nothing
    local integer p = 0
    local boolean g
''', '''function Her_Sortear takes nothing returns nothing
    local integer p = 0
    local boolean g
    local integer e
    local integer q
''')
cambia('''            call Her_Cartas(p, p * 10, g)
            call Her_Cartas(p, p * 10 + 5, false)
            if Her_Alta then
                set Her_SinOro[p] = 0
            else
                set Her_SinOro[p] = Her_SinOro[p] + 1
            endif
''', '''            call Her_Cartas(p, p * 40, g)
            call Her_Cartas(p, p * 40 + 5, false)
            if Her_Alta then
                set Her_SinOro[p] = 0
            else
                set Her_SinOro[p] = Her_SinOro[p] + 1
            endif
            // v19y: pulls extra (first blood y rachas de la oleada).
            set Her_Extra[p] = 0
            set Her_ExFB[p] = Her_FB[p]
            if Her_FB[p] then
                set Her_ExMin[p * 8] = 2
                call Her_CartasExtra(p, p * 40 + 10, 2)
                set Her_Extra[p] = 1
            endif
            set q = 1
            if Racha_Max[p] >= 7 then
                set q = 3
            elseif Racha_Max[p] >= 4 then
                set q = 2
            endif
            set e = IMinBJ(2, Racha_Pts[p] / 2)
            loop
                exitwhen e <= 0
                set Her_ExMin[p * 8 + Her_Extra[p]] = q
                call Her_CartasExtra(p, p * 40 + (2 + Her_Extra[p]) * 5, q)
                set Her_Extra[p] = Her_Extra[p] + 1
                set e = e - 1
            endloop
            set Her_PullLog = Her_PullLog + "; j" + I2S(p) + " extra " + I2S(Her_Extra[p]) + " fb " + I2S(IntegerTertiaryOp(Her_FB[p], 1, 0)) + " pts " + I2S(Racha_Pts[p]) + " max " + I2S(Racha_Max[p])
            set Her_FB[p] = false
            set Racha_Pts[p] = 0
            set Racha_Max[p] = 0
''')
cambia('''    call Her_Cartas(p, Her_K(p, 0), false)
    call Cua_Pintar(p)''', '''    if Cua_Paso[p] >= 5 then
        call Her_CartasExtra(p, Her_K(p, 0), Her_ExMin[p * 8 + Cua_Paso[p] - 5])
    else
        call Her_Cartas(p, Her_K(p, 0), false)
    endif
    call Cua_Pintar(p)''')
cambia('string Her_TipoTxt = ""\n', 'string Her_TipoTxt = ""\nstring Her_PullLog = ""\n')

if prueba:
    cambia('''    set Her_Ok = true
''', '''    set Her_Ok = true
    // v19y-prueba: pulls extra de cada jugador.
    call Bolsa_Anotar("pulls ronda " + I2S(Ronda_Numero) + Her_PullLog)
    set Her_PullLog = ""
''')
else:
    cambia('''    set Her_Ok = true
''', '''    set Her_Ok = true
    set Her_PullLog = ""
''')
    for viejo, nuevo in ():
        pass
if prueba:
    for viejo, nuevo in (('lat\\\\v19x-', 'lat\\\\v19y-'), ('v19x-don.txt', 'v19y-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19y', 'prueba' if prueba else 'normal')
