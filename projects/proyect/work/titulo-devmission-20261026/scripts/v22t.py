#!/usr/bin/env python3
"""v22t (23/11/2026): seis cartas nuevas del héroe, con niveles.

Leon tras v22s: "perfecto, siguiente fase" (fase v22t del plan de barajas: cartas nuevas de habilidades).
- 121 Regeneración: +vida por segundo (BonusMod regeneración en el héroe).
- 122 Armadura: +armadura (BonusMod armadura en el héroe).
- 123 Robo de vida: te curas un % del daño que haces a las unidades de la oleada (armas y técnicas; en Mvp_Golpe,
  con el daño real, como mucho la vida que le quedaba al enemigo).
- 124 Curación al matar: +vida por cada baja (junto a la batería, Bat_Matar).
- 125 Segundo aliento: al empezar cada oleada te curas un % de la vida máxima (Ronda_Lanzar).
- 126 Trébol: +suerte fija para la calidad de las cartas (no se pierde como la suerte de racha).
- Entran en la mano del héroe con las demás (Her_Pool 10-15); la calidad da el valor, el tope los niveles.
- Fuera de esta fase: recarga y poder de técnicas; la recarga y el daño de cada técnica están en sus datos de objeto,
  no en el script.
Uso: v22t.py ENTRADA.j SALIDA.j [prueba]   (normal de v22s; prueba de v22s-prueba).
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


# id, nombre, icono, tope, T1..T5
CARTAS = [(121, 'Regeneración', 'DC09', 4, [2, 3, 5, 8, 12]),
          (122, 'Armadura', 'DC00', 4, [1, 2, 3, 4, 6]),
          (123, 'Robo de vida', 'DM00', 4, [1, 2, 3, 4, 5]),
          (124, 'Curación al matar', 'DC0C', 4, [3, 5, 8, 12, 16]),
          (125, 'Segundo aliento', 'DC02', 3, [10, 15, 20, 30, 40]),
          (126, 'Trébol', 'DM03', 3, [2, 3, 4, 6, 8])]

# 0) Globales.
cambia('integer Pan_TipoV = 0\n', '''integer Pan_TipoV = 0
// v22t: cartas nuevas del héroe: robo de vida (fracción), vida por baja, curación al empezar la oleada (fracción de
// la vida máxima) y suerte fija.
real array Her_Robo
integer array Her_CuraK
real array Her_Aliento
integer array Her_Trebol
''')

# 1) Mano del héroe: 6 cartas más en Her_Pool (10-15); las bonificaciones sin tope siguen detrás.
cambia('''    loop
        exitwhen c > 13
        if c <= 9 then
            set x = Her_Pool[c]
''', '''    // v22t: Her_Pool 0-15 (121-126 nuevas); después, si no hay ninguna, las bonificaciones sin tope.
    loop
        exitwhen c > 19
        if c <= 15 then
            set x = Her_Pool[c]
''')
cambia('''        elseif c == 13 then
            set x = 110
        else
            set x = 95 + c
        endif
''', '''        elseif c == 19 then
            set x = 110
        else
            set x = 89 + c
        endif
''')
cambia('    set Her_Pool[9] = 81\n', '    set Her_Pool[9] = 81\n' + ''.join(
    f'    set Her_Pool[{10 + i}] = {c[0]}\n' for i, c in enumerate(CARTAS)))

# 2) Textos.
cambia('function Her_Etiqueta takes integer x returns string\n', '''// v22t: cartas nuevas del héroe (121-126).
function Car_EsHer takes integer x returns boolean
    return x >= 121 and x <= 126
endfunction

function Car_HerDes takes integer x, integer v returns string
    if x == 121 then
        return "+" + I2S(v) + " de vida|npor segundo."
    elseif x == 122 then
        return "+" + I2S(v) + " de armadura."
    elseif x == 123 then
        return "Te curas el " + I2S(v) + " % del|ndaño que haces."
    elseif x == 124 then
        return "+" + I2S(v) + " de vida por|ncada baja."
    elseif x == 125 then
        return "Al empezar la oleada,|nte curas el " + I2S(v) + " % de vida."
    endif
    return "+" + I2S(v) + " de suerte para|nla calidad de las cartas."
endfunction

function Her_Etiqueta takes integer x returns string
''')
cambia('''    elseif Car_EsArm(x) then
        return Her_Etiqueta(x) + Car_ArmDes(x, v)
''', '''    elseif Car_EsHer(x) then
        return Her_Etiqueta(x) + Car_HerDes(x, v)
    elseif Car_EsArm(x) then
        return Her_Etiqueta(x) + Car_ArmDes(x, v)
''')
cambia('''    elseif Car_EsArm(x) then
        // v22s: categoría guardada en el panel (Pan_HT).
''', '''    elseif Car_EsHer(x) then
        return Her_Etiqueta(x) + Car_HerDes(x, v)
    elseif Car_EsArm(x) then
        // v22s: categoría guardada en el panel (Pan_HT).
''')

# 3) Efectos (Car_Contar ya cuenta el nivel al empezar Her_Aplicar).
cambia('function Her_Aplicar takes integer p, integer x, integer q returns nothing\n', '''// v22t: efecto de la carta nueva del héroe x de valor v.
function Car_HerAplicar takes integer p, integer x, integer v returns nothing
    local unit u = Game_Hero[p]
    if x == 121 then
        if u != null then
            call BM_Add(u, 2, v)
        endif
    elseif x == 122 then
        if u != null then
            call BM_Add(u, 0, v)
        endif
    elseif x == 123 then
        set Her_Robo[p] = Her_Robo[p] + v / 100.
    elseif x == 124 then
        set Her_CuraK[p] = Her_CuraK[p] + v
    elseif x == 125 then
        set Her_Aliento[p] = Her_Aliento[p] + v / 100.
    else
        set Her_Trebol[p] = Her_Trebol[p] + v
    endif
    set u = null
endfunction

function Her_Aplicar takes integer p, integer x, integer q returns nothing
''')
cambia('''    elseif Car_EsArm(x) then
        // v22s: cartas nuevas de una categoría.
''', '''    elseif Car_EsHer(x) then
        call Car_HerAplicar(p, x, v)
    elseif Car_EsArm(x) then
        // v22s: cartas nuevas de una categoría.
''')
# Robo de vida: con el daño real a una unidad de la oleada.
cambia('''            if d > 0. then
                set Mvp_Dano[k] = Mvp_Dano[k] + d
            endif
''', '''            if d > 0. then
                set Mvp_Dano[k] = Mvp_Dano[k] + d
                // v22t: Robo de vida.
                if Her_Robo[k] > 0. and UnitAlive(Game_Hero[k]) then
                    call SetWidgetLife(Game_Hero[k], GetWidgetLife(Game_Hero[k]) + d * Her_Robo[k])
                endif
            endif
''')
# Curación al matar.
cambia('        call Bat_Matar(p)\n', '''        call Bat_Matar(p)
        // v22t: Curación al matar.
        if Her_CuraK[p] > 0 and UnitAlive(Game_Hero[p]) then
            call SetWidgetLife(Game_Hero[p], GetWidgetLife(Game_Hero[p]) + Her_CuraK[p])
        endif
''')
# Segundo aliento.
cambia('''            call SetUnitInvulnerable(Game_Hero[p], false)
            call DevWave_AddTarget(Game_Hero[p])
''', '''            call SetUnitInvulnerable(Game_Hero[p], false)
            call DevWave_AddTarget(Game_Hero[p])
            // v22t: Segundo aliento.
            if Her_Aliento[p] > 0. and UnitAlive(Game_Hero[p]) then
                call SetWidgetLife(Game_Hero[p], GetWidgetLife(Game_Hero[p]) + GetUnitState(Game_Hero[p], UNIT_STATE_MAX_LIFE) * Her_Aliento[p])
            endif
''')
# Trébol.
cambia('    local integer r = GetRandomInt(1, 100) + IMinBJ(30, 2 * Her_Suerte[p]) + 5 * IMaxBJ(0, Punt_Estrellas - 1)\n',
       '    // v22t: + Trébol.\n'
       '    local integer r = GetRandomInt(1, 100) + IMinBJ(30, 2 * Her_Suerte[p]) + Her_Trebol[p] + 5 * IMaxBJ(0, Punt_Estrellas - 1)\n')

# 4) Datos.
d = '    // v22t: cartas nuevas del héroe (121-126): tope, nombre, icono y valores T1..T5.\n'
for x, nom, tex, m, vals in CARTAS:
    d += f'    set Car_Max[{x}] = {m}\n'
    d += f'    set Cua_Nom[{x}] = "{nom}"\n    set Cua_Des[{x}] = ""\n    set Cua_Tex[{x}] = \'{tex}\'\n'
    d += ''.join(f'    set Her_Tabla[{x * 5 + q}] = {v}\n' for q, v in enumerate(vals))
cambia('    // v18y: quinta carta del paso del héroe.\n', d + '    // v18y: quinta carta del paso del héroe.\n')

assert src.index('function BM_Add') < src.index('function Car_HerAplicar') < src.index('function Her_Aplicar ')
assert src.index('function Car_EsHer') < src.index('function Her_Des ') < src.index('function Pan_HDes')
assert src.index('function Mvp_Golpe') > src.index('endglobals')

if prueba:
    assert 'function Cop_Anotar' in src
    cambia('lat\\\\v22s-', 'lat\\\\v22t-', src.count('lat\\\\v22s-'))
    cambia('v22s-don.txt', 'v22t-don.txt', src.count('v22s-don.txt'))
    assert 'lat\\\\v22s-' not in src and 'v22s-don.txt' not in src, 'quedan registros v22s'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22t', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
