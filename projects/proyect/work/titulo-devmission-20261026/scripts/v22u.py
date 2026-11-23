#!/usr/bin/env python3
"""v22u (23/11/2026): doce mutaciones nuevas de Mutación Evo (jefe, élites, comunes y oleada).

Leon tras v22t: "siguiente fase," (fase v22u del plan de barajas: más mutaciones de jefe, élites, comunes y oleada).
- Ids 130-141 (18 en adelante los usan las cartas del héroe). Lista virtual Mut_V (jefe v 0-6, élites 7-13, comunes
  14-29) para el sorteo; Mut_Grupo y Mut_Es reemplazan los rangos 0-3 / 4-7 / 8-17.
- Jefe: 130 Caparazón (+5 armadura), 131 Sangre eterna (0,5 % de vida/s), 132 Embestida (ataque +20 %, carrera +15 %).
- Élites: 133 Élite robusta (+40 % vida), 134 Élite furiosa (+30 % daño), 135 Élite ágil (carrera y ataque +20 %).
- Comunes: 136 Coraza (+2 armadura), 137 Colmillos (+20 % daño), 138 Frenesí (ataque +15 %), 139 Vanguardia (cuerpo a
  cuerpo +35 % vida, +10 % carrera), 140 Marea creciente (los que salen pasados 30 s: +30 % vida, +20 % daño),
  141 Estallido (el 10 % de los comunes explota al morir cerca de los héroes).
- Todo por nivel (hasta 3, como las demás). Iconos reutilizados.
Uso: v22u.py ENTRADA.j SALIDA.j [prueba]   (normal de v22t; prueba de v22t-prueba).
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


# id, nombre, descripción, icono
MUTS = [(130, 'Caparazón', 'El jefe tiene|n+5 de armadura.', 'DC00'),
        (131, 'Sangre eterna', 'El jefe recupera|n0,5 % de vida por segundo.', 'DC09'),
        (132, 'Embestida', 'El jefe ataca un 20 %|ny corre un 15 % más.', 'DC01'),
        (133, 'Élite robusta', 'Las élites tienen|n+40 % de vida.', 'DC05'),
        (134, 'Élite furiosa', 'Las élites hacen|nun 30 % más de daño.', 'DC04'),
        (135, 'Élite ágil', 'Las élites corren y|natacan un 20 % más.', 'DC01'),
        (136, 'Coraza', 'Los comunes tienen|n+2 de armadura.', 'DC00'),
        (137, 'Colmillos', 'Los comunes hacen|nun 20 % más de daño.', 'DC04'),
        (138, 'Frenesí', 'Los comunes atacan|nun 15 % más rápido.', 'DC06'),
        (139, 'Vanguardia', 'Cuerpo a cuerpo: +35 %|nde vida y +10 % carrera.', 'DC03'),
        (140, 'Marea creciente', 'Pasados 30 s, los que salen|ntienen +30 % vida y +20 % daño.', 'DC08'),
        (141, 'Estallido', 'El 10 % de los comunes|nexplota al morir.', 'DC0C')]
# Lista virtual: jefe, élites, comunes (orden del sorteo).
MUT_V = [0, 1, 2, 3, 130, 131, 132, 4, 5, 6, 7, 133, 134, 135] + list(range(8, 18)) + list(range(136, 142))
assert len(MUT_V) == 30

# 0) Globales.
cambia('integer array Her_Trebol\n', '''integer array Her_Trebol
// v22u: lista virtual de mutaciones para el sorteo (jefe 0-6, élites 7-13, comunes 14-29).
integer array Mut_V
''')

# 1) Grupo de una mutación y mutación al azar del Pacto mutante.
cambia('// v22r: mutación al azar que no esté al máximo (Pacto mutante); si todas lo están, cualquiera.\n', '''// v22u: ¿x es una mutación? (0-17 y 130-141).
function Mut_Es takes integer x returns boolean
    return (x >= 0 and x <= 17) or (x >= 130 and x <= 141)
endfunction

// v22u: grupo de la mutación x: 0 jefe, 1 élites, 2 comunes y oleada.
function Mut_Grupo takes integer x returns integer
    if x < 4 or (x >= 130 and x <= 132) then
        return 0
    elseif x < 8 or (x >= 133 and x <= 135) then
        return 1
    endif
    return 2
endfunction

// v22r: mutación al azar que no esté al máximo (Pacto mutante); si todas lo están, cualquiera.
''')
cambia('GetRandomInt(0, 17)', 'Mut_V[GetRandomInt(0, 29)]', 2)

# 2) Bucles 0..17 -> 0..141 (Cua_Activa vale 0 fuera de las mutaciones).
cambia('exitwhen x > 17', 'exitwhen x > 141', 6)
for _ in range(2):
    cambia('''    local integer x = 4
    local integer n = 0
    loop
        exitwhen x > 141
        if Cua_Activa[x] > 0 then
''' if _ == 0 else '''    local integer n = 0
    local integer x = 4
    loop
        exitwhen x > 141
        if Cua_Activa[x] > 0 then
''', ('''    local integer x = 0
    local integer n = 0
    loop
        exitwhen x > 141
        if Cua_Activa[x] > 0 and Mut_Grupo(x) > 0 then
''' if _ == 0 else '''    local integer n = 0
    local integer x = 0
    loop
        exitwhen x > 141
        if Cua_Activa[x] > 0 and Mut_Grupo(x) > 0 then
'''))
cambia('''            set col = "|cffe8e8e8"
            if x < 4 then
                set col = "|cffff6070"
            elseif x < 8 then
''', '''            set col = "|cffe8e8e8"
            if Mut_Grupo(x) == 0 then
                set col = "|cffff6070"
            elseif Mut_Grupo(x) == 1 then
''')
cambia('    if x < 0 or x > 17 then\n', '    if not Mut_Es(x) then\n')
cambia('''function Pan_Grupo takes integer x returns integer
    if x < 4 then
        return 0
    elseif x < 8 then
        return 1
    endif
    return 2
endfunction
''', '''function Pan_Grupo takes integer x returns integer
    return Mut_Grupo(x)
endfunction
''')
cambia('''        if x >= 8 then
            set s = "|cffe8e8e8Comunes|r|n"
        elseif x >= 4 then
''', '''        if Mut_Grupo(x) == 2 then
            set s = "|cffe8e8e8Comunes|r|n"
        elseif Mut_Grupo(x) == 1 then
''')
cambia('''        exitwhen i > 17
        set Pan_MIco[i] = Cua_Pic(Pan_IcoX(0, 0), Pan_IcoY(0), 52, 52, 393, Pan_Tex(i))
''', '''        exitwhen i > 141
        // v22u: sólo las mutaciones (0-17 y 130-141).
        if Mut_Es(i) then
            set Pan_MIco[i] = Cua_Pic(Pan_IcoX(0, 0), Pan_IcoY(0), 52, 52, 393, Pan_Tex(i))
        endif
''')

# 3) Sorteo por la lista virtual.
cambia('            set x = ini + GetRandomInt(0, tam - 1)\n', '            set x = Mut_V[ini + GetRandomInt(0, tam - 1)]\n')
cambia('''// v18o: como Cua_Elegir (Mutación Evo), con el peso de Cua_Peso. Código común.
function Cua_ElegirPeso takes integer ini, integer tam, integer c, integer k returns nothing
    local integer i = 0
    local integer x
    local integer tot
    local integer r
    loop
        exitwhen i >= c
        set tot = 0
        set x = ini
        loop
            exitwhen x >= ini + tam
            if not Cua_Usado(x, k, i) then
                set tot = tot + Cua_Peso(x)
            endif
            set x = x + 1
        endloop
        set r = GetRandomInt(1, tot)
        set x = ini
        loop
            if not Cua_Usado(x, k, i) then
                set r = r - Cua_Peso(x)
            endif
            exitwhen r <= 0
            set x = x + 1
        endloop
        set Cua_Cand[k + i] = x
''', '''// v18o: como Cua_Elegir (Mutación Evo), con el peso de Cua_Peso. Código común. v22u: [ini, ini + tam) en Mut_V.
function Cua_ElegirPeso takes integer ini, integer tam, integer c, integer k returns nothing
    local integer i = 0
    local integer v
    local integer x
    local integer tot
    local integer r
    loop
        exitwhen i >= c
        set tot = 0
        set v = ini
        loop
            exitwhen v >= ini + tam
            if not Cua_Usado(Mut_V[v], k, i) then
                set tot = tot + Cua_Peso(Mut_V[v])
            endif
            set v = v + 1
        endloop
        set r = GetRandomInt(1, tot)
        set v = ini
        loop
            set x = Mut_V[v]
            if not Cua_Usado(x, k, i) then
                set r = r - Cua_Peso(x)
            endif
            exitwhen r <= 0 or v >= ini + tam - 1
            set v = v + 1
        endloop
        set Cua_Cand[k + i] = x
''')
cambia('''function Cua_Libres takes integer ini, integer tam returns integer
    local integer n = 0
    local integer x = ini
    loop
        exitwhen x >= ini + tam
        if Cua_Activa[x] < 3 then
            set n = n + 1
        endif
        set x = x + 1
    endloop
''', '''function Cua_Libres takes integer ini, integer tam returns integer
    local integer n = 0
    local integer v = ini
    // v22u: [ini, ini + tam) en Mut_V.
    loop
        exitwhen v >= ini + tam
        if Cua_Activa[Mut_V[v]] < 3 then
            set n = n + 1
        endif
        set v = v + 1
    endloop
''')
cambia('''    set Cua_Cnt[0] = IMinBJ(IMinBJ(Cua_NE, 4), Cua_Libres(0, 4))
    call Cua_Elegir(0, 4, Cua_Cnt[0], false, 0)
    set Cua_Cnt[1] = IMinBJ(IMinBJ(Cua_NE, 4), Cua_Libres(4, 4))
    call Cua_Elegir(4, 4, Cua_Cnt[1], false, 5)
    set Cua_Cnt[2] = IMinBJ(Cua_NE, Cua_Libres(8, 10))
    call Cua_ElegirPeso(8, 10, Cua_Cnt[2], 10)
''', '''    // v22u: por la lista virtual Mut_V (jefe 0-6, élites 7-13, comunes 14-29).
    set Cua_Cnt[0] = IMinBJ(IMinBJ(Cua_NE, 4), Cua_Libres(0, 7))
    call Cua_Elegir(0, 7, Cua_Cnt[0], false, 0)
    set Cua_Cnt[1] = IMinBJ(IMinBJ(Cua_NE, 4), Cua_Libres(7, 7))
    call Cua_Elegir(7, 7, Cua_Cnt[1], false, 5)
    set Cua_Cnt[2] = IMinBJ(Cua_NE, Cua_Libres(14, 16))
    call Cua_ElegirPeso(14, 16, Cua_Cnt[2], 10)
''')

# 4) Efectos al salir cada unidad.
cambia('''        call Mut_Vida(u, f)
        set u = null
        return
    endif
    if id >= 'ne00' and id <= 'ne09' then
''', '''        call Mut_Vida(u, f)
        // v22u: Caparazón, Sangre eterna (con la vida ya ajustada) y Embestida.
        if Cua_Activa[130] > 0 then
            set Mut_Cuenta[130] = Mut_Cuenta[130] + 1
            call BM_Add(u, 0, 5 * Cua_Activa[130])
        endif
        if Cua_Activa[131] > 0 then
            set Mut_Cuenta[131] = Mut_Cuenta[131] + 1
            call BM_Add(u, 2, IMaxBJ(1, R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE) * 0.005 * Cua_Activa[131] + 0.5)))
        endif
        if Cua_Activa[132] > 0 then
            set Mut_Cuenta[132] = Mut_Cuenta[132] + 1
            call BM_Add(u, 3, 20 * Cua_Activa[132])
            call Mut_Velocidad(u, 1. + 0.15 * Cua_Activa[132])
        endif
        set u = null
        return
    endif
    if id >= 'ne00' and id <= 'ne09' then
        // v22u: Élite robusta, Élite furiosa y Élite ágil.
        if Cua_Activa[133] > 0 then
            set Mut_Cuenta[133] = Mut_Cuenta[133] + 1
            call Mut_Vida(u, 0.4 * Cua_Activa[133])
        endif
        if Cua_Activa[134] > 0 then
            set Mut_Cuenta[134] = Mut_Cuenta[134] + 1
            call BM_Add(u, 1, R2I(Sup_Base(id) * 0.3 * Cua_Activa[134] + 0.5))
        endif
        if Cua_Activa[135] > 0 then
            set Mut_Cuenta[135] = Mut_Cuenta[135] + 1
            call BM_Add(u, 3, 20 * Cua_Activa[135])
            call Mut_Velocidad(u, 1. + 0.2 * Cua_Activa[135])
        endif
''')
cambia('''    call Mut_Vida(u, f)
    if d > 0. then
        call BM_Add(u, 1, R2I(Sup_Base(id) * d + 0.5))
    endif
''', '''    // v22u: Coraza, Colmillos, Frenesí, Vanguardia (cuerpo a cuerpo: sin los tipos 2, 4, 5 y 7) y Marea creciente.
    if Cua_Activa[136] > 0 then
        set Mut_Cuenta[136] = Mut_Cuenta[136] + 1
        call BM_Add(u, 0, 2 * Cua_Activa[136])
    endif
    if Cua_Activa[137] > 0 then
        set Mut_Cuenta[137] = Mut_Cuenta[137] + 1
        set d = d + 0.2 * Cua_Activa[137]
    endif
    if Cua_Activa[138] > 0 then
        set Mut_Cuenta[138] = Mut_Cuenta[138] + 1
        call BM_Add(u, 3, 15 * Cua_Activa[138])
    endif
    if Cua_Activa[139] > 0 and k != 2 and k != 4 and k != 5 and k != 7 then
        set Mut_Cuenta[139] = Mut_Cuenta[139] + 1
        set f = f + 0.35 * Cua_Activa[139]
        set v = v * (1. + 0.1 * Cua_Activa[139])
    endif
    if Cua_Activa[140] > 0 and TimerGetElapsed(s__RapidPair_clock) - Mut_Inicio >= 30. then
        set Mut_Cuenta[140] = Mut_Cuenta[140] + 1
        set f = f + 0.3 * Cua_Activa[140]
        set d = d + 0.2 * Cua_Activa[140]
    endif
    call Mut_Vida(u, f)
    if d > 0. then
        call BM_Add(u, 1, R2I(Sup_Base(id) * d + 0.5))
    endif
''')

# 5) Estallido al morir un común.
cambia('''    if WaveEventIsRetired or u == null or Cua_Activa[7] <= 0 or id < 'ne00' or id > 'ne09' then
''', '''    // v22u: Estallido: el 10 % por nivel de los comunes explota al morir (daño a los héroes a 200).
    if not WaveEventIsRetired and u != null and Cua_Activa[141] > 0 and Mut_Comun(id) >= 0 and GetRandomInt(1, 100) <= 10 * Cua_Activa[141] then
        set Mut_Cuenta[141] = Mut_Cuenta[141] + 1
        set x = GetUnitX(u)
        set y = GetUnitY(u)
        set dano = (8. + 4. * Ronda_Numero) * Cua_Activa[141]
        call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Other\\\\Incinerate\\\\FireLordDeathExplode.mdl", x, y))
        loop
            exitwhen p > 11
            if Game_On[p] and Game_Hero[p] != null and UnitAlive(Game_Hero[p]) and IsUnitInRangeXY(Game_Hero[p], x, y, 200.) then
                call UnitDamageTarget(u, Game_Hero[p], dano, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
            endif
            set p = p + 1
        endloop
        set p = 0
    endif
    if WaveEventIsRetired or u == null or Cua_Activa[7] <= 0 or id < 'ne00' or id > 'ne09' then
''')

# 6) Datos y lista virtual.
d = '    // v22u: mutaciones nuevas (130-141) y lista virtual del sorteo.\n'
for x, nom, des, tex in MUTS:
    d += f'    set Cua_Nom[{x}] = "{nom}"\n    set Cua_Des[{x}] = "{des}"\n    set Cua_Tex[{x}] = \'{tex}\'\n'
d += ''.join(f'    set Mut_V[{i}] = {x}\n' for i, x in enumerate(MUT_V))
cambia("    set Cua_Tex[17] = 'DC09'\n", "    set Cua_Tex[17] = 'DC09'\n" + d)

assert src.index('function Mut_Grupo') < src.index('function Car_MutLibre') < src.index('function Mut_Purgables')
assert src.index('function Mut_Comun') < src.index('function Mut_Muere')
assert 'exitwhen x > 17' not in src

if prueba:
    assert 'function Cop_Anotar' in src
    cambia('''        exitwhen i > 17
        if Cua_Activa[i] > 0 or Mut_Cuenta[i] > 0 then
''', '''        exitwhen i > 141
        if Cua_Activa[i] > 0 or Mut_Cuenta[i] > 0 then
''')
    cambia('lat\\\\v22t-', 'lat\\\\v22u-', src.count('lat\\\\v22t-'))
    cambia('v22t-don.txt', 'v22u-don.txt', src.count('v22t-don.txt'))
    assert 'lat\\\\v22t-' not in src and 'v22t-don.txt' not in src, 'quedan registros v22t'
assert 'exitwhen i > 17' not in src
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22u', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
