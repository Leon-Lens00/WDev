#!/usr/bin/env python3
"""v21m (22/11/2026): tiers de las técnicas de Goku, como las armas.

Leon: "al igual que las armas esta tendra tier", "a tier maximo debera tener un danio bien alto a nivel de un cartucho
completo", "el kameha tier maximo no seria como la ultimate R a tier maximo, debe haber ese plus adicional". Cifras
aceptadas ("Sí, con esas cifras"), ver docs/planes/devmission-tiers-habilidades-goku.md.

- Q, W y R de Goku suben de T1 a T6 (amarillo a rojo) con las cartas de técnica. La carta lleva el color del tier nuevo
  y respeta la misma puerta por ronda que las armas (T2 tras la ronda 1, T3 tras la 2, T4 tras la 4, T5 tras la 6,
  T6 tras la 8).
- Daño por enemigo y lanzamiento en T6: Q 2900 (un cargador rojo), W 2000, R 5800 en todas las formas. Curva por tier
  25/35/45/60/80/100 %. El daño ya no depende de Gk_Fuerza. Las técnicas de varios golpes reparten: Big Bang /5 (como
  en D.O.N), Super Kamehameha /40 por tick (D.O.N /20, pero aquí casi siempre hay enemigos cerca y el rayo frena).
- Kaioken: bono a las armas 1,5 x curva (+37,5 % en T1 a +150 % en T6).
- El nivel real de A0O6/A0IA/A0BZ se limita a sus niveles de objeto (4/4/3).
- Recargas y maná: objetos_v21m.py.
Registro (sólo prueba): por lanzamiento, daño bruto máximo a un enemigo y enemigos tocados (6 s después del primer golpe).
Uso: v21m.py ENTRADA.j SALIDA.j [prueba]   (normal de v21l; prueba de v21l-prueba).
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


# --- Globales ---
cambia('''integer Kam_Parada = 0
''', '''integer Kam_Parada = 0
real array Tec_Curva
real array Tec_T6
integer array Tec_Tope
''' + ('''hashtable Gk_DH = InitHashtable()
real array Gk_DMax
integer array Gk_DN
integer array Gk_DX
''' if prueba else ''))

# --- Daño por tier ---
cambia('''function Gk_Fuerza takes unit u returns integer
    return R2I(25. + 3.5 * I2R(Gk_Nivel - 1))
endfunction
''', '''function Gk_Fuerza takes unit u returns integer
    return R2I(25. + 3.5 * I2R(Gk_Nivel - 1))
endfunction

// v21m: daño de la técnica x de Goku según su tier (1-6) para el dueño de u: total en T6 x curva del tier.
function Gk_TDano takes unit u, integer x, real total returns real
    local integer p = GetPlayerId(GetOwningPlayer(u))
    local integer t = 1
    if p >= 0 and p < 12 then
        set t = IMinBJ(6, IMaxBJ(1, Tec_Niv[p * 100 + x]))
    endif
    return total * Tec_Curva[t]
endfunction
''' + ('''
// v21m (prueba): daño bruto por enemigo de cada lanzamiento (s: 0 Q, 1 W, 2 R).
function Gk_DFin takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer s = LoadInteger(Gk_DH, 9, GetHandleId(t))
    local string n = "Q"
    if s == 1 then
        set n = "W"
    elseif s == 2 then
        set n = "R forma " + I2S(G2V_Int[7160])
    endif
    set Cop_Log = "goku dano " + n + " T" + I2S(Gk_DX[s]) + " max " + R2S(Gk_DMax[s]) + " enemigos " + I2S(Gk_DN[s])
    call ExecuteFunc("Cop_Anotar")
    call FlushChildHashtable(Gk_DH, s)
    call RemoveSavedInteger(Gk_DH, 9, GetHandleId(t))
    set Gk_DMax[s] = 0.
    set Gk_DN[s] = 0
    call DestroyTimer(t)
    set t = null
endfunction

function Gk_Suma takes integer s, integer x, unit src, unit u, real d returns nothing
    local integer h = GetHandleId(u)
    local real v = LoadReal(Gk_DH, s, h)
    local timer t
    local integer p = GetPlayerId(GetOwningPlayer(src))
    if Gk_DN[s] == 0 then
        set t = CreateTimer()
        call SaveInteger(Gk_DH, 9, GetHandleId(t), s)
        call TimerStart(t, 6., false, function Gk_DFin)
        set t = null
        set Gk_DX[s] = 0
        if p >= 0 and p < 12 then
            set Gk_DX[s] = Tec_Niv[p * 100 + x]
        endif
    endif
    if v == 0. then
        set Gk_DN[s] = Gk_DN[s] + 1
    endif
    set v = v + d
    call SaveReal(Gk_DH, s, h, v)
    if v > Gk_DMax[s] then
        set Gk_DMax[s] = v
    endif
endfunction
''' if prueba else ''))


def golpe(linea, s, x, src_, tgt, dmg, veces=1):
    if prueba:
        cambia(linea + '\n', linea + '\ncall Gk_Suma(%d,%d,%s,%s,I2R(%s))\n' % (s, x, src_, tgt, dmg), veces)


# --- Fórmulas ---
cambia('''set G2V_Damage[7150]=((100*GetUnitAbilityLevelSwapped('A0O6',G2V_QC))+(Gk_Fuerza(G2V_QC)*2))
''', '''set G2V_Damage[7150]=R2I(Gk_TDano(G2V_QC,43,2900.))
''')
cambia('''set G2V_Damage2[5850]=($F+((75*GetUnitAbilityLevelSwapped('A0IA',G2V_Caster[5850]))+(3*Gk_Fuerza(G2V_Caster[5850]))))
''', '''set G2V_Damage2[5850]=R2I(Gk_TDano(G2V_Caster[5850],42,2000.))
''')
cambia('''set G2V_Damage[4410]=(((300*GetUnitAbilityLevelSwapped('A0BZ',G2V_Caster[4410]))+(3*Gk_Fuerza(G2V_Caster[4410])))/20)
''', '''set G2V_Damage[4410]=R2I(Gk_TDano(G2V_Caster[4410],40,5800.)/40.)
''')
cambia('''set G2V_Damage[4410]=((300*GetUnitAbilityLevelSwapped('A0BZ',G2V_Caster[4410]))+(4*Gk_Fuerza(G2V_Caster[4410])))
''', '''set G2V_Damage[4410]=R2I(Gk_TDano(G2V_Caster[4410],40,5800.))
''')
cambia('''set G2V_Damage[4410]=(((300*GetUnitAbilityLevelSwapped('A0BZ',G2V_Caster[4410]))+(3*Gk_Fuerza(G2V_Caster[4410])))/5)
''', '''set G2V_Damage[4410]=R2I(Gk_TDano(G2V_Caster[4410],40,5800.)/5.)
''')
cambia('''set G2V_Damage[4410]=((400*GetUnitAbilityLevelSwapped('A0BZ',G2V_Caster[4410]))+(5*Gk_Fuerza(G2V_Caster[4410])))
''', '''set G2V_Damage[4410]=R2I(Gk_TDano(G2V_Caster[4410],40,5800.))
''')
cambia('''set G2V_SFDamage=(($FA*GetUnitAbilityLevelSwapped('A0BZ',G2V_SFCaster))+(3*Gk_Fuerza(G2V_SFCaster)))
''', '''set G2V_SFDamage=R2I(Gk_TDano(G2V_SFCaster,40,5800.))
''')
cambia('''call Gk_TT(("|cffff0000"+I2S(((400*GetUnitAbilityLevelSwapped('A0BZ',G2V_Caster[4410]))+((G2V_Int[4415]*Gk_Fuerza(G2V_Caster[4410]))+GetRandomInt(100,$C8))))),''',
       '''call Gk_TT(("|cffff0000"+I2S(G2V_Damage[4410])),''')
cambia('''set Kai_Bono[GetPlayerId(GetOwningPlayer(G2V_Caster[7150]))]=.5+.5*I2R(GetUnitAbilityLevelSwapped('A0BZ',G2V_Caster[4410]))
''', '''// v21m: el bono sube con el tier de la R (1,5 x curva: +37,5 % en T1 a +150 % en T6).
set Kai_Bono[GetPlayerId(GetOwningPlayer(G2V_Caster[7150]))]=Gk_TDano(G2V_Caster[4410],40,1.5)
''')

# Registro de prueba tras cada golpe.
golpe('call UnitDamageTargetBJ(G2V_QC,GetEnumUnit(),I2R(G2V_Damage[7150]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      0, 43, 'G2V_QC', 'GetEnumUnit()', 'G2V_Damage[7150]')
golpe('call UnitDamageTargetBJ(G2V_Caster[5850],G2V_Caster[5855],I2R(G2V_Damage2[5850]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      1, 42, 'G2V_Caster[5850]', 'G2V_Caster[5855]', 'G2V_Damage2[5850]')
golpe('call UnitDamageTargetBJ(G2V_Caster[4410],GetEnumUnit(),I2R(G2V_Damage[4410]),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      2, 40, 'G2V_Caster[4410]', 'GetEnumUnit()', 'G2V_Damage[4410]', 4)
golpe('call UnitDamageTargetBJ(G2V_SFCaster,GetEnumUnit(),I2R(G2V_SFDamage),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)',
      2, 40, 'G2V_SFCaster', 'GetEnumUnit()', 'G2V_SFDamage')

# --- Libro: tope del nivel real ---
cambia('''        call SetPlayerAbilityAvailable(Player(p), Tec_Puente[x], v)
        if n > 0 and GetUnitAbilityLevel(Game_Hero[p], Tec_Real[x]) > 0 then''', '''        call SetPlayerAbilityAvailable(Player(p), Tec_Puente[x], v)
        // v21m: con tiers (hasta 6) el nivel real no pasa de los niveles del objeto.
        if Tec_Tope[x] > 0 then
            set n = IMinBJ(n, Tec_Tope[x])
        endif
        if n > 0 and GetUnitAbilityLevel(Game_Hero[p], Tec_Real[x]) > 0 then''')

# --- Cartas: puerta por ronda, color del tier y descripción ---
cambia('''function Tec_Aprender takes integer p, integer x returns nothing
''', '''// v21m: ¿puede salir la carta de x? Con tier, el siguiente tier necesita las rondas de las armas (Arm_Req).
function Tec_Puede takes integer p, integer x returns boolean
    local integer t = Tec_Niv[p * 100 + x] + 1
    local integer r = Ronda_Numero - 1
    local integer q = 0
    if Tec_Niv[p * 100 + x] >= Tec_Max[x] then
        return false
    elseif Tec_T6[x] <= 0. then
        return true
    endif
    if Ronda_Descanso then
        set r = Ronda_Numero
    endif
    if t <= 1 then
        set q = 0
    elseif t <= 3 then
        set q = t - 1
    else
        set q = 2 * (t - 2)
    endif
    return r >= q
endfunction

// v21m: color de la carta de x: con tier, el del tier nuevo (0 amarillo .. 4 morado, 6 rojo), como Subir tier de armas.
function Tec_Cal takes integer p, integer x returns integer
    local integer t = Tec_Niv[p * 100 + x] + 1
    if Tec_T6[x] <= 0. then
        return IMinBJ(4, Tec_Niv[p * 100 + x])
    elseif t >= 6 then
        return 6
    endif
    return IMaxBJ(0, t - 1)
endfunction

function Tec_Aprender takes integer p, integer x returns nothing
''')
cambia('''    if n >= Tec_Max[x] then
        return "Ya está al máximo|n(nivel " + I2S(n) + ")."
''', '''    if Tec_T6[x] > 0. and n >= Tec_Max[x] then
        return "Ya está en " + Arm_TierTexto(n) + ", el máximo."
    elseif Tec_T6[x] > 0. then
        // v21m: técnica con tier: daño por enemigo del tier nuevo.
        return "Sube a " + Arm_TierTexto(n + 1) + ": " + I2S(R2I(Tec_T6[x] * Tec_Curva[n + 1])) + " de daño|npor enemigo. Tecla " + Tec_Tecla[x] + "."
    elseif n >= Tec_Max[x] then
        return "Ya está al máximo|n(nivel " + I2S(n) + ")."
''')
cambia('''        if Tec_Niv[p * 100 + x] < Tec_Max[x] then
            set l[n] = x''', '''        if Tec_Puede(p, x) then
            set l[n] = x''')
cambia('''        set Her_Cal[k + s] = IMinBJ(4, Tec_Niv[p * 100 + x])
''', '''        set Her_Cal[k + s] = Tec_Cal(p, x)
''')
cambia('''                    if Tec_Niv[p * 100 + y] < Tec_Max[y] and not Her_EnMano(k, y) then''',
       '''                    if Tec_Puede(p, y) and not Her_EnMano(k, y) then''')
cambia('''                set Her_Cal[k + i] = IMinBJ(4, Tec_Niv[p * 100 + x])
''', '''                set Her_Cal[k + i] = Tec_Cal(p, x)
''')
cambia('''            set Her_Cal[k + i] = IMinBJ(4, Tec_Niv[p * 100 + x])
''', '''            set Her_Cal[k + i] = Tec_Cal(p, x)
''')

# --- Datos ---
for x, mx in ((40, 3), (42, 4), (43, 4)):
    cambia('''    set Tec_Max[%d] = %d
''' % (x, mx), '''    set Tec_Max[%d] = 6
    set Tec_Tope[%d] = %d
''' % (x, x, mx))
cambia('''    set Tec_Puente[40] = 'AGk3'
''', '''    // v21m: tiers de Goku: daño por enemigo en T6 y curva de los rifles (25/35/45/60/80/100 %).
    set Tec_Curva[1] = .25
    set Tec_Curva[2] = .35
    set Tec_Curva[3] = .45
    set Tec_Curva[4] = .6
    set Tec_Curva[5] = .8
    set Tec_Curva[6] = 1.
    set Tec_T6[40] = 5800.
    set Tec_T6[42] = 2000.
    set Tec_T6[43] = 2900.
    set Tec_Puente[40] = 'AGk3'
''')

if prueba:
    # -gt N (sólo prueba): Q, W y R de Goku del jugador en el tier N (1-6), sin esperar rondas ni cartas.
    cambia('''function Tec_Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer i = 0
    call TimerStart(CreateTimer(), 0.25, true, function Tec_Vigila)
''', '''function Tec_GtComando takes nothing returns nothing
    local string s = GetEventPlayerChatString()
    local integer p = GetPlayerId(GetTriggerPlayer())
    local integer n = S2I(SubString(s, 4, StringLength(s)))
    if SubString(s, 0, 4) != "-gt " or n < 1 or n > 6 then
        return
    endif
    set Tec_Niv[p * 100 + 40] = n
    set Tec_Niv[p * 100 + 42] = n
    set Tec_Niv[p * 100 + 43] = n
    call Tec_Aplicar(p)
    call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 5., "Goku: Q, W y R en " + Arm_TierTexto(n))
    set Cop_Log = "goku tiers -gt " + I2S(n)
    call ExecuteFunc("Cop_Anotar")
endfunction

function Tec_Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer i = 0
    local trigger gt = CreateTrigger()
    loop
        exitwhen i > 11
        call TriggerRegisterPlayerChatEvent(gt, Player(i), "-gt ", false)
        set i = i + 1
    endloop
    set i = 0
    call TriggerAddAction(gt, function Tec_GtComando)
    set gt = null
    call TimerStart(CreateTimer(), 0.25, true, function Tec_Vigila)
''')
    cambia('lat\\\\v21l-', 'lat\\\\v21m-', src.count('lat\\\\v21l-'))
    cambia('v21l-don.txt', 'v21m-don.txt', src.count('v21l-don.txt'))
assert not prueba or ('lat\\\\v21l-' not in src and 'v21l-don.txt' not in src), 'quedan registros v21l'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21m', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
