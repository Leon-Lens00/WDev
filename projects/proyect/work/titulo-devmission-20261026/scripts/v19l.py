#!/usr/bin/env python3
"""v19l (19/11/2026). Leon: "de momento torrres afuera, no las usaremos aun. dificultad siempre en nightmare, agrega mas
malditas de acuerdo a nuestra jugabilidad, las habilidades como carta de las habilidades que ya desarrollamos de cairne y
tauren, mas cartas de economia, ... como darle un mejor acabado visual al apartado de mejorar al boss y mejoras de
jugador, ya que no se ven bien vistosas y se puede confundir".
- Iconos de los cuadros: desde v17s todas las cartas mostraban 'DC00' (la tortuga verde) porque el cambio de textura
  con "grabtree" (Title_Skin) no surtía efecto en los iconos ya colocados (grabación 20261115_212510: Mutación Evo,
  Tienda y Mejoras del héroe con el mismo icono). Cua_Pintar ahora rehace la pieza del icono con su textura (la textura
  de creación sí se aplica), sólo cuando cambia; código común.
- Etiqueta de tipo en la primera línea de cada carta del héroe: Estadística, Economía, Maldita, Técnica nueva / Técnica.
- Técnicas de Tauren (63-69) y Cairne (70-77) como cartas, del más fuerte al más ligero. Al empezar sólo Lanzar roca /
  Lanza ancestral. Niveles 1-3 en las activas (+30 % de daño por nivel sobre el 1.º, con Cop_Fac en Cop_Area); las
  pasivas (Disparo encantado, Espíritus guardianes, Réplica) se aprenden una vez y hasta entonces no actúan.
- Malditas (una vez cada una; 12 % en la 4.ª carta, al azar entre las que quedan): Pacto maldito (ya estaba), Sed de
  sangre (+50 % de daño de armas; las runas de vida no te curan), Codicia (+100 % de oro de bolsas; la suerte baja a 0 y
  las bolsas ya no la suben), Pacto mutante (+8 % de daño por cada Mutación Evo activa; entra una más al azar), Ruleta
  (+10 % de crítico y el crítico hace ×3; -20 % de vida máxima).
- Economía con calidad (T1..T5), en el sorteo con las de estadística: Reembolso (devuelve 5/8/12/16/20 % de lo gastado
  en armas y munición, tope 50 %), Imán (+40/60/85/115/150 de radio para coger bolsas), Interés (al empezar el descanso,
  +3/4/6/8/10 % del oro que tienes, tope 250 por descanso), Bolsa doble (8/12/17/23/30 % de que una bolsa valga doble).
- Índice de técnicas por jugador p * 100 + x (v19k usaba 64; con las cartas hasta 77 se solaparía).
- Prueba: registros lat\\v19l-*; "-tec" también para Tauren y Cairne.
Uso: v19l.py ENTRADA.j SALIDA.j [prueba]   (normal de v19k; prueba de v19k-prueba)
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


# índice por jugador
n64 = src.count('p * 64 + ')
assert n64 == (9 if prueba else 8), n64
src = src.replace('p * 64 + ', 'p * 100 + ')
cambia('''    if not Tec_Listo[p] and Tec_N > 0 then
        set Tec_Listo[p] = true
''', '''    if not Tec_Listo[p * 100 + Tec_A] and Tec_N > 0 then
        set Tec_Listo[p * 100 + Tec_A] = true
''')

# --- globales ---
cambia('integer Tec_N = 0\n', 'integer Tec_N = 0\n'
       'real Cop_Fac = 1.\nreal array Cop_Mul\ninteger array Her_Pool\ninteger Cua_ActN = 0\n'
       'boolean array Her_Mald\nboolean array Her_Sed\nboolean array Her_Codicia\nreal array Her_Mutante\n'
       'real array Her_Ruleta\nreal array Her_Reembolso\nreal array Her_Iman\ninteger array Her_Interes\n'
       'real array Her_Doble\ninteger array Cua_IcoTex\n')

# --- Tauren y Cairne: nivel de la técnica = factor de daño de sus piezas ---
TEC2 = [  # x, puente, máximo, tecla, nombre, icono, inicial
    ('ATb4', 3, 'R', 'Bombardeo', 'DL00', 0), ('ATb6', 3, 'S', 'Rugido desafiante', 'DL01', 0),
    ('ATb1', 3, 'Q', 'Embestida espiritual', 'DL02', 0), ('ATb5', 3, 'A', 'Garra espiritual', 'DL03', 0),
    ('ATb2', 3, 'W', 'Tótem arrojado', 'DL04', 0), ('ATb3', 3, 'E', 'Lanzar roca', 'DL05', 1),
    ('ATbP', 1, '', 'Disparo encantado', 'DL06', 0),
    ('ACb4', 3, 'R', 'Estampida', 'DL07', 0), ('ACb6', 3, 'S', 'Marca ancestral', 'DL08', 0),
    ('ACb1', 3, 'Q', 'Grieta ancestral', 'DL09', 0), ('ACb5', 3, 'A', 'Tótem del trueno', 'DL0A', 0),
    ('ACb3', 3, 'E', 'Espíritu ancestral', 'DL0B', 0), ('ACb2', 3, 'W', 'Lanza ancestral', 'DL0C', 1),
    ('ACbQ', 1, '', 'Espíritus guardianes', 'DL0D', 0), ('ACbP', 1, '', 'Réplica', 'DL0E', 0),
]
assert len(TEC2) == 15
for t in TEC2:  # las pasivas sólo están en el w3a (libros ALTb/ALCb)
    assert t[2] == '' or ("'%s'" % t[0]) in src, t
antes('function Cop_Inicio takes nothing returns integer\n', '''// v19l: factor de daño de la técnica a de Tauren/Cairne según su nivel aprendido (1, 1,3, 1,6).
function Tec_FacAb takes integer p, integer a returns real
    local integer x = 63
    loop
        exitwhen x > 77
        if Tec_Puente[x] == a then
            return 1. + 0.3 * IMaxBJ(0, Tec_Niv[p * 100 + x] - 1)
        endif
        set x = x + 1
    endloop
    return 1.
endfunction

''')
cambia('''    set Cop_LD = SquareRoot((Cop_PX - Cop_HX) * (Cop_PX - Cop_HX) + (Cop_PY - Cop_HY) * (Cop_PY - Cop_HY))
    return p
''', '''    set Cop_LD = SquareRoot((Cop_PX - Cop_HX) * (Cop_PX - Cop_HX) + (Cop_PY - Cop_HY) * (Cop_PY - Cop_HY))
    set Cop_Fac = Tec_FacAb(p, GetSpellAbilityId())
    return p
''')
cambia('''    set Cop_Golpes[i] = 0
    set Cop_Total[i] = 0.
    return i
''', '''    set Cop_Golpes[i] = 0
    set Cop_Total[i] = 0.
    set Cop_Mul[i] = Cop_Fac
    return i
''')
cambia('''            set Cop_K[i] = Cop_K[i] + 1
            set t = Cop_T[i]
''', '''            set Cop_K[i] = Cop_K[i] + 1
            set t = Cop_T[i]
            set Cop_Fac = Cop_Mul[i]
''')
cambia('''    call Cop_EstadosTick()
    if Cop_N == 0 and Emp_N == 0''', '''    set Cop_Fac = 1.
    call Cop_EstadosTick()
    if Cop_N == 0 and Emp_N == 0''')
cambia('    set Cop_oSuma = 0.\n', '    set dano = dano * Cop_Fac\n    set Cop_oSuma = 0.\n')
cambia('''            set d = Her_Dano(p, 150.)
            call UnitDamageTarget(src, u, d, false, false, Dano_Ataque(6), Dano_TipoArma, null)''', '''            set d = Her_Dano(p, 150. * Cop_Fac)
            call UnitDamageTarget(src, u, d, false, false, Dano_Ataque(6), Dano_TipoArma, null)''')
# pasivas sólo aprendidas
cambia("""        if GetUnitTypeId(Game_Hero[GetPlayerId(s__RapidBolt_owner[m])]) == 'h005' then""",
       """        if GetUnitTypeId(Game_Hero[GetPlayerId(s__RapidBolt_owner[m])]) == 'h005' and Tec_Niv[GetPlayerId(s__RapidBolt_owner[m]) * 100 + 69] > 0 then""")
cambia("""    if GetUnitTypeId(h) == 'h006' and UnitAlive(h) then
        call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Orc\\\\WarStomp\\\\WarStompCaster.mdl\"""",
       """    if GetUnitTypeId(h) == 'h006' and UnitAlive(h) and Tec_Niv[p * 100 + 77] > 0 then
        call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Orc\\\\WarStomp\\\\WarStompCaster.mdl\"""")
cambia('''        if h != null and GetUnitTypeId(h) == 'h006' then
            if Gua_Rise[p] then''', '''        if h != null and GetUnitTypeId(h) == 'h006' then
            if Tec_Niv[p * 100 + 76] == 0 then
                set Gua_Rise[p] = false
            endif
            set Cop_Fac = 1.
            if Gua_Rise[p] then''')
cambia('''            elseif Gua_Ronda[p] != Ronda_Numero and UnitAlive(h) and GetWidgetLife(h)''',
       '''            elseif Gua_Ronda[p] != Ronda_Numero and Tec_Niv[p * 100 + 76] > 0 and UnitAlive(h) and GetWidgetLife(h)''')
# rango de técnicas
cambia('''    elseif t == 'hNar' or t == 'hNaK' then
        set Tec_A = 57
        set Tec_N = 6
    endif
endfunction
''', '''    elseif t == 'hNar' or t == 'hNaK' then
        set Tec_A = 57
        set Tec_N = 6
    elseif t == 'h005' then
        set Tec_A = 63
        set Tec_N = 7
    elseif t == 'h006' then
        set Tec_A = 70
        set Tec_N = 8
    endif
endfunction
''')
cambia('''    if n >= Tec_Max[x] then
        return "Ya está al máximo|n(nivel " + I2S(n) + ")."
    elseif n == 0 then''', '''    if n >= Tec_Max[x] then
        return "Ya está al máximo|n(nivel " + I2S(n) + ")."
    elseif Tec_Tecla[x] == "" then
        return "Pasiva: siempre activa|nal aprenderla."
    elseif Tec_Real[x] == 0 and n == 0 then
        return "Aprende la técnica.|nTecla " + Tec_Tecla[x] + " en el libro V."
    elseif Tec_Real[x] == 0 then
        return "Nivel " + I2S(n + 1) + " de " + I2S(Tec_Max[x]) + ": +30 %|nde daño. Tecla " + Tec_Tecla[x] + "."
    elseif n == 0 then''')

# --- datos (en Tec_Init) ---
datos = ''
for k, (pu, mx, te, no, ic, ini) in enumerate(TEC2):
    x = 63 + k
    datos += (f"    set Tec_Puente[{x}] = '{pu}'\n    set Tec_Real[{x}] = 0\n    set Tec_Max[{x}] = {mx}\n"
              f"    set Tec_Tecla[{x}] = \"{te}\"\n    set Tec_Ini[{x}] = {ini}\n    set Cua_Nom[{x}] = \"{no}\"\n"
              f"    set Cua_Des[{x}] = \"Técnica.\"\n    set Cua_Tex[{x}] = '{ic}'\n")
NUEVAS = [  # x, nombre, descripción fija, icono, valores T1..T5 (economía)
    (33, 'Sed de sangre', '+50 % de daño de armas;|nlas runas de vida no curan.', 'DM00', None),
    (34, 'Codicia', '+100 % de oro de bolsas;|nsuerte a 0 y no sube.', 'DM01', None),
    (35, 'Pacto mutante', '+8 % de daño por Mutación|nactiva; entra una más.', 'DM02', None),
    (36, 'Ruleta', 'Crítico ×3 y +10 %;|n-20 % de vida máxima.', 'DM03', None),
    (18, 'Reembolso', '', 'DM04', (5, 8, 12, 16, 20)),
    (19, 'Imán', '', 'DM05', (40, 60, 85, 115, 150)),
    (37, 'Interés', '', 'DM06', (3, 4, 6, 8, 10)),
    (38, 'Bolsa doble', '', 'DM07', (8, 12, 17, 23, 30)),
]
for x, no, de, ic, vals in NUEVAS:
    datos += f'    set Cua_Nom[{x}] = "{no}"\n    set Cua_Des[{x}] = "{de}"\n    set Cua_Tex[{x}] = \'{ic}\'\n'
    if vals:
        for q, v in enumerate(vals):
            datos += f'    set Her_Tabla[{x * 5 + q}] = {v}\n'
for k, x in enumerate((20, 21, 22, 23, 26, 27, 18, 19, 37, 38)):
    datos += f'    set Her_Pool[{k}] = {x}\n'
cambia('''    local trigger t = CreateTrigger()
    local integer i = 0
    set Tec_Puente[40] = 'AGk3'
''', '''    local trigger t = CreateTrigger()
    local integer i = 0
''' + datos + '''    set Tec_Puente[40] = 'AGk3'
''')

# --- helpers de las cartas del héroe (antes de Her_Valor) ---
antes('function Her_Valor takes integer x, integer q returns integer\n', '''// v19l: malditas (una vez cada una) y tipo de carta.
function Her_EsMaldita takes integer x returns boolean
    return x == 28 or (x >= 33 and x <= 36)
endfunction

function Her_Etiqueta takes integer x returns string
    if x >= 40 then
        return "|cff60e0ffTécnica|r|n"
    elseif Her_EsMaldita(x) then
        return "|cffff70d0Maldita|r|n"
    elseif x == 18 or x == 19 or x == 26 or x == 37 or x == 38 then
        return "|cffffcc00Economía|r|n"
    endif
    return "|cffd8d8d8Estadística|r|n"
endfunction

function Her_Maldita takes integer p returns integer
    local integer array l
    local integer n = 0
    local integer x = 33
    if not Her_Mald[p * 40 + 28] then
        set l[0] = 28
        set n = 1
    endif
    loop
        exitwhen x > 36
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

function Eco_Des takes integer x, integer v returns string
    if x == 18 then
        return "Te devuelve el " + I2S(v) + " % de lo|nque gastes en armas."
    elseif x == 19 then
        return "+" + I2S(v) + " de radio para|ncoger bolsas."
    elseif x == 37 then
        return "Al empezar el descanso,|n+" + I2S(v) + " % de tu oro."
    endif
    return I2S(v) + " % de que una|nbolsa valga doble."
endfunction

''')
cambia('''            set x = 20 + GetRandomInt(0, 5)
            if x >= 24 then
                set x = x + 2
            endif
''', '''            set x = Her_Pool[GetRandomInt(0, 9)]
''')
cambia('''    if GetRandomInt(1, 100) <= 8 then
        set Cua_HCand[k + 3] = 28
        set Her_Cal[k + 3] = 0
    endif
''', '''    if GetRandomInt(1, 100) <= 12 and Her_Maldita(p) > 0 then
        set Cua_HCand[k + 3] = Her_Maldita(p)
        set Her_Cal[k + 3] = 0
    endif
''')
cambia('''        if Her_Cal[k + i] >= 3 and Cua_HCand[k + i] != 28 and Cua_HCand[k + i] < 40 then''',
       '''        if Her_Cal[k + i] >= 3 and not Her_EsMaldita(Cua_HCand[k + i]) and Cua_HCand[k + i] < 40 then''')
cambia('''    if Cua_HCand[Her_K(p, c)] == 28 then
        call Her_ColorTxt(5)''', '''    if Her_EsMaldita(Cua_HCand[Her_K(p, c)]) then
        call Her_ColorTxt(5)''')
cambia('''    if Cua_HCand[Her_K(p, c)] == 28 then
        set Her_R = 95''', '''    if Her_EsMaldita(Cua_HCand[Her_K(p, c)]) then
        set Her_R = 95''')
cambia('''    if x >= 40 then
        return Tec_Des(p, x)
    endif
    set v = Her_Valor(x, Her_Cal[Her_K(p, c)])
''', '''    if x >= 40 then
        return Her_Etiqueta(x) + Tec_Des(p, x)
    endif
    set v = Her_Valor(x, Her_Cal[Her_K(p, c)])
    if x == 18 or x == 19 or x == 37 or x == 38 then
        return Her_Etiqueta(x) + Eco_Des(x, v)
    endif
    if x != 28 and Her_EsMaldita(x) then
        return Her_Etiqueta(x) + Cua_Des[x]
    endif
    set Her_Txt = Her_Etiqueta(x)
''')
for a in ('"+" + I2S(v) + " % de daño|nde tus armas."', '"+" + I2S(v) + " de vida|nmáxima."',
          '"+" + I2S(v) + " de velocidad|nde movimiento."', '"+" + I2S(v) + " % de golpe|ncrítico (daño ×2)."',
          '"+" + I2S(v) + " % de oro|nde las bolsas."', '"+" + I2S(v) + " % de probab.|nde esquivar golpes."',
          '"+40 % de daño, pero|n-25 % de vida máxima."'):
    cambia('        return ' + a + '\n', '        return Her_Txt + ' + a + '\n')
cambia('string array Tec_Tecla\n', 'string array Tec_Tecla\nstring Her_Txt = ""\n')
# efectos
cambia('''    elseif x >= 40 then
        call Tec_Aprender(p, x)
    endif
''', '''    elseif x == 33 then
        set Her_Filo[p] = Her_Filo[p] + 0.5
        set Her_Sed[p] = true
    elseif x == 34 then
        set Her_Botin[p] = Her_Botin[p] + 1.
        set Her_Suerte[p] = 0
        set Her_Codicia[p] = true
    elseif x == 35 then
        set Her_Mutante[p] = Her_Mutante[p] + 0.08
        set e = GetRandomInt(0, 17)
        set Cua_Activa[e] = Cua_Activa[e] + 1
        set Cua_ActN = Cua_ActN + 1
    elseif x == 36 and u != null then
        set Her_Crit[p] = Her_Crit[p] + 0.1
        set Her_Ruleta[p] = 1.
        set hp = GetUnitState(u, UNIT_STATE_MAX_LIFE)
        call BM_VidaMax(u, - R2I(hp * 0.2 + 0.5))
        call SetWidgetLife(u, RMinBJ(GetWidgetLife(u), GetUnitState(u, UNIT_STATE_MAX_LIFE)))
    elseif x == 18 then
        set Her_Reembolso[p] = RMinBJ(0.5, Her_Reembolso[p] + v / 100.)
    elseif x == 19 then
        set Her_Iman[p] = Her_Iman[p] + v
    elseif x == 37 then
        set Her_Interes[p] = Her_Interes[p] + v
    elseif x == 38 then
        set Her_Doble[p] = Her_Doble[p] + v / 100.
    elseif x >= 40 then
        call Tec_Aprender(p, x)
    endif
    if Her_EsMaldita(x) then
        set Her_Mald[p * 40 + x] = true
    endif
''')
cambia('''        set Cua_Activa[Cua_Gana[k]] = Cua_Activa[Cua_Gana[k]] + 1
''', '''        set Cua_Activa[Cua_Gana[k]] = Cua_Activa[Cua_Gana[k]] + 1
        set Cua_ActN = Cua_ActN + 1
''')
cambia('''        set d=d * ( 1. + Her_Filo[p] )
        if Her_Crit[p] > 0. and GetRandomReal(0., 1.) < Her_Crit[p] then
            set d=d * 2.
''', '''        set d=d * ( 1. + Her_Filo[p] + Her_Mutante[p] * Cua_ActN )
        if Her_Crit[p] > 0. and GetRandomReal(0., 1.) < Her_Crit[p] then
            set d=d * ( 2. + Her_Ruleta[p] )
''')
cambia('''    if Cur_Tipo[i] == 0 then
        set m = GetUnitState(h, UNIT_STATE_MAX_LIFE)''', '''    if Cur_Tipo[i] == 0 and Her_Sed[p] then
        set h = null
        set c = null
        return false
    endif
    if Cur_Tipo[i] == 0 then
        set m = GetUnitState(h, UNIT_STATE_MAX_LIFE)''')
cambia('''    set Bolsa_Oro[i] = R2I(Bolsa_Oro[i] * (1. + Her_Botin[p]) + 0.5)
''', '''    set Bolsa_Oro[i] = R2I(Bolsa_Oro[i] * (1. + Her_Botin[p]) + 0.5)
    if Her_Doble[p] > 0. and GetRandomReal(0., 1.) < Her_Doble[p] then
        set Bolsa_Oro[i] = Bolsa_Oro[i] * 2
    endif
''')
cambia('''    if ModuloInteger(Punt_BolsasJ[p], 5) == 0 then
        set Her_Suerte[p]''', '''    if ModuloInteger(Punt_BolsasJ[p], 5) == 0 and not Her_Codicia[p] then
        set Her_Suerte[p]''')
cambia('''                if dx * dx + dy * dy <= 25600. then
                    set cogida = true
                    call Bolsa_Coger(i, p)''', '''                if dx * dx + dy * dy <= (160. + Her_Iman[p]) * (160. + Her_Iman[p]) then
                    set cogida = true
                    call Bolsa_Coger(i, p)''')
cambia('''            set Her_Suerte[p] = Her_Suerte[p] + IMaxBJ(0, Punt_Estrellas)
''', '''            set Her_Suerte[p] = Her_Suerte[p] + IMaxBJ(0, Punt_Estrellas)
            if Her_Codicia[p] then
                set Her_Suerte[p] = 0
            endif
            if Her_Interes[p] > 0 then
                call Oro_Dar(p, IMinBJ(250, GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD) * Her_Interes[p] / 100))
            endif
''')
cambia('''    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - Arm_Precio[w])
''', '''    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - Arm_Precio[w])
    call Oro_Dar(p, R2I(Arm_Precio[w] * Her_Reembolso[p]))
''')
cambia('''    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - costo)
    call UI_Click(p)
''', '''    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - costo)
    call Oro_Dar(p, R2I(costo * Her_Reembolso[p]))
    call UI_Click(p)
''')
cambia('''    if gasto == 0 then
        call UI_Error(p)
        return
    endif
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro)
''', '''    if gasto == 0 then
        call UI_Error(p)
        return
    endif
    set oro = oro + R2I(gasto * Her_Reembolso[p])
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro)
''')

# la etiqueta añade un renglón y el texttag crece hacia arriba: bajar el bloque uno (810 × 0,021 px) para no pisar el nombre
cambia('''                call Cua_Izq(p, Cua_TD[c], Her_Des(p, c), Cua_PX(s) - 150, 440, 0.021)''',
       '''                call Cua_Izq(p, Cua_TD[c], Her_Des(p, c), Cua_PX(s) - 150, 457, 0.021)''')

# --- iconos: rehacer la pieza con la textura nueva ---
cambia('''    loop
        exitwhen c >= n
        if Cua_Ico[p * 9 + Cua_Slot(n, c)] != null then
            call Title_Skin(Cua_Ico[p * 9 + Cua_Slot(n, c)], Cua_Tex[Cua_Item(p, c)])
        endif
        set c = c + 1
    endloop
endfunction
''', '''    // v19l: el cambio con Title_Skin no se veía (todas en 'DC00'); se rehace la pieza con la textura nueva.
    loop
        exitwhen c >= n
        set s = p * 9 + Cua_Slot(n, c)
        set tex = Cua_Tex[Cua_Item(p, c)]
        if Cua_Ico[s] != null and Cua_IcoTex[s] != tex then
            call FlushChildHashtable(Title_HT, GetHandleId(Cua_Ico[s]))
            call RemoveUnit(Cua_Ico[s])
            set Title_CX = 4800.
            set Cua_Ico[s] = Cua_Pic(Cua_PX(Cua_Slot(n, c)), 275, 190, 190, 405, tex)
            set Title_CX = cx
            set Cua_IcoTex[s] = tex
        endif
        set c = c + 1
    endloop
endfunction
''')
cambia('''function Cua_Pintar takes integer p returns nothing
    local integer n = Cua_Cuantos(p)
    local integer c = 0
''', '''function Cua_Pintar takes integer p returns nothing
    local integer n = Cua_Cuantos(p)
    local integer c = 0
    local integer s
    local integer tex
    local real cx = Title_CX
''')
# La pieza nueva nace con alfa 0: todos los que llaman a Cua_Pintar con el menú abierto llaman después a Cua_Ver
# (directo o por Cua_Mostrar), que le da su alfa.
if prueba:
    for viejo, nuevo in (('lat\\\\v19k-', 'lat\\\\v19l-'), ('v19k-don.txt', 'v19l-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19l', 'prueba' if prueba else 'normal')
