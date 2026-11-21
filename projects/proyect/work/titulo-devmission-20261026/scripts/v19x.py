#!/usr/bin/env python3
"""v19x (19/11/2026), fase 5 del plan devmission-v20-mutaciones-rachas-mvp.md: Pacto de sombras y batería limitada.
- Carta maldita 80 "Pacto de sombras" (una vez, como las demás malditas; sale en la casilla de maldita):
  +20 % de daño de las armas y +10 % de velocidad (+35 sobre los 350 de GroundMotion, como Zancada); a cambio la
  linterna pasa a batería limitada (Bat_Limitada, de v19t).
- Batería limitada:
  - Gasta 0,1 cada 0,1 s durante la oleada (como antes), dividido por las Pilas reforzadas.
  - Al empezar el descanso ya no se llena: suma 45 s, hasta 100.
  - Matar: 1 s cada 12 enemigos, con tope de 8 s por oleada (Recarga rápida sube ambos un 50 % por carta).
  - Sin recargas con G: nunca llega de golpe a cantidades grandes. El texto del HUD ya no habla de G.
- Con la batería limitada salen en la tirada del héroe (hueco Her_Pool[11] = 81; sin pacto sale una carta normal):
  81 "Pilas reforzadas": la batería dura +25 % (gasta 1 / (1 + 0,25 n)), hasta 3 veces.
  82 "Recarga rápida": +50 % de lo ganado al matar y de su tope, hasta 2 veces.
- Etiquetas: el pacto lila de maldita; 81/82 amarillo "Linterna". Corrige que Her_Etiqueta/Her_TipoColor tomaran
  como técnica todo x >= 40 (ahora 40-77).
- Prueba: Mut_Anotar añade por oleada la batería de cada jugador con pacto y lo ganado al matar; Her_Log, pilas y
  recarga.
Uso: v19x.py ENTRADA.j SALIDA.j [prueba]   (normal de v19w; prueba de v19w-prueba)
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


# --- globales ---
cambia('integer array Dash_Clave\n', '''integer array Dash_Clave
// v19x: batería limitada (Pacto de sombras).
integer array Bat_Pilas
integer array Bat_Rapida
integer array Bat_Bajas
real array Bat_Ganado
real array Bat_Total
''')

# --- ganancia al matar (antes de Racha_Muerte) ---
cambia('''function Racha_Muerte takes integer p returns nothing
''', '''// v19x: con batería limitada, 1 s cada 12 muertes y tope de 8 s por oleada (+50 % cada Recarga rápida).
function Bat_Matar takes integer p returns nothing
    local real f
    local real g
    if not Bat_Limitada[p] then
        return
    endif
    set Bat_Bajas[p] = Bat_Bajas[p] + 1
    if Bat_Bajas[p] < 12 then
        return
    endif
    set Bat_Bajas[p] = 0
    set f = 1. + 0.5 * Bat_Rapida[p]
    set g = RMinBJ(f, 8. * f - Bat_Ganado[p])
    set g = RMinBJ(g, 100. - Bat_T[p])
    if g > 0. then
        set Bat_T[p] = Bat_T[p] + g
        set Bat_Ganado[p] = Bat_Ganado[p] + g
        set Bat_Total[p] = Bat_Total[p] + g
    endif
endfunction

function Racha_Muerte takes integer p returns nothing
''')
cambia('''    if not Ronda_Descanso then
        set Punt_BajasJ[p] = Punt_BajasJ[p] + 1
    endif''', '''    if not Ronda_Descanso then
        set Punt_BajasJ[p] = Punt_BajasJ[p] + 1
        call Bat_Matar(p)
    endif''')

# --- gasto, descanso, G y HUD ---
cambia('set Bat_T[p] = RMaxBJ(0., Bat_T[p] - 0.1)', 'set Bat_T[p] = RMaxBJ(0., Bat_T[p] - 0.1 / (1. + 0.25 * Bat_Pilas[p]))')
cambia('''                set Bat_Cargas[p] = Bat_Cargas[p] + 2
                set Bat_T[p] = 100.
''', '''                set Bat_Cargas[p] = Bat_Cargas[p] + 2
                // v19x: con el pacto la batería no se llena: +45 s, hasta 100.
                if Bat_Limitada[p] then
                    set Bat_T[p] = RMinBJ(100., Bat_T[p] + 45.)
                else
                    set Bat_T[p] = 100.
                endif
                set Bat_Ganado[p] = 0.
                set Bat_Bajas[p] = 0
''')
cambia('''    if Bat_Limitada[p] then
        call UnitAddAbility(Game_Ctrl[p], 'Aw0A')
    endif
''', '''    // v19x: sin recargas con G (Pacto de sombras: la batería no vuelve de golpe).
''')
cambia('"Batería " + I2S(pct) + "%   Recargas (G): " + I2S(Bat_Cargas[p])', '"Batería " + I2S(pct) + "%"')

# --- cartas ---
cambia('''// Textos del dash en el HUD''', '''// v19x: carta de la linterna (sólo con el pacto) entre las que no están al máximo; si no, una carta normal.
function Bat_Carta takes integer p returns integer
    if Bat_Limitada[p] then
        if Bat_Pilas[p] < 3 and (Bat_Rapida[p] >= 2 or GetRandomInt(0, 1) == 0) then
            return 81
        elseif Bat_Rapida[p] < 2 then
            return 82
        endif
    endif
    return Her_Pool[GetRandomInt(0, 9)]
endfunction

// Textos del dash en el HUD''')
cambia('''            set x = Her_Pool[GetRandomInt(0, 10)]
            if x == 24 then
                set x = Dash_Carta(p)
            endif''', '''            set x = Her_Pool[GetRandomInt(0, 11)]
            if x == 24 then
                set x = Dash_Carta(p)
            elseif x == 81 then
                set x = Bat_Carta(p)
            endif''')
cambia('    set Her_Pool[10] = 24\n', '''    set Her_Pool[10] = 24
    set Her_Pool[11] = 81
''' + ''.join(f'    set Her_Tabla[{x * 5 + q}] = {v}\n' for x, v in ((80, 20), (81, 25), (82, 50)) for q in range(5)))
for x in (80, 81, 82):
    assert f'Her_Tabla[{x * 5}] =' not in src.replace(U(f'    set Her_Tabla[{x * 5}] = '), '', 1), x
cambia('''    set Cua_Tex[79] = 'DC0N'
''', '''    set Cua_Tex[79] = 'DC0N'
    // v19x: linterna.
    set Cua_Nom[80] = "Pacto de sombras"
    set Cua_Des[80] = "+20 % daño, +10 % vel.;|nla batería se agota."
    set Cua_Tex[80] = 'DC0O'
    set Cua_Nom[81] = "Pilas reforzadas"
    set Cua_Des[81] = "La batería|ndura más."
    set Cua_Tex[81] = 'DC0P'
    set Cua_Nom[82] = "Recarga rápida"
    set Cua_Des[82] = "Más batería|nal matar."
    set Cua_Tex[82] = 'DC0Q'
''')
cambia('return x == 28 or (x >= 33 and x <= 36)', 'return x == 28 or (x >= 33 and x <= 36) or x == 80')
cambia('''        set x = x + 1
    endloop
    if n == 0 then
        return 0
    endif
    return l[GetRandomInt(0, n - 1)]''', '''        set x = x + 1
    endloop
    // v19x: Pacto de sombras.
    if not Her_Mald[p * 40 + 80] then
        set l[n] = 80
        set n = n + 1
    endif
    if n == 0 then
        return 0
    endif
    return l[GetRandomInt(0, n - 1)]''')
cambia('''        return "|cffff9c40Dash|r|n"
    elseif x >= 40 then''', '''        return "|cffff9c40Dash|r|n"
    elseif x == 81 or x == 82 then
        return "|cffffe680Linterna|r|n"
    elseif x >= 40 and x < 78 then''')
cambia('''        set Her_B = 64
    elseif x >= 40 then''', '''        set Her_B = 64
    elseif x == 81 or x == 82 then
        set Her_R = 255
        set Her_G = 230
        set Her_B = 128
    elseif x >= 40 and x < 78 then''')
cambia('''    elseif x == 24 then
        return Her_Txt + "+1 carga de dash|n(máximo 4)."''', '''    elseif x == 81 then
        return Her_Txt + "La batería dura +25 %|n(hasta 3 veces)."
    elseif x == 82 then
        return Her_Txt + "+50 % de batería al|nmatar (hasta 2 veces)."
    elseif x == 24 then
        return Her_Txt + "+1 carga de dash|n(máximo 4)."''', 2)
cambia('''    elseif x == 24 then
        set Dash_Extra[p] = IMinBJ(2, Dash_Extra[p] + 1)''', '''    elseif x == 80 then
        // v19x: Pacto de sombras.
        set Her_Filo[p] = Her_Filo[p] + 0.2
        set Her_Zancada[p] = Her_Zancada[p] + 35
        if u != null then
            call SetUnitMoveSpeed(u, GetUnitMoveSpeed(u) + 35)
        endif
        if Game_Pair[p] != 0 then
            set s__GroundMotion_speed[s__RapidPair_motion[Game_Pair[p]]] = 350. + Her_Zancada[p]
        endif
        set Bat_Limitada[p] = true
    elseif x == 81 then
        set Bat_Pilas[p] = IMinBJ(3, Bat_Pilas[p] + 1)
    elseif x == 82 then
        set Bat_Rapida[p] = IMinBJ(2, Bat_Rapida[p] + 1)
    elseif x == 24 then
        set Dash_Extra[p] = IMinBJ(2, Dash_Extra[p] + 1)''')
cambia('''" dur " + R2SW(0.375 * (1. - Dash_DurB[p]), 1, 3)
    set u = null''', '''" dur " + R2SW(0.375 * (1. - Dash_DurB[p]), 1, 3) + " pilas " + I2S(Bat_Pilas[p]) + " recarga " + I2S(Bat_Rapida[p])
    set u = null''')

if prueba:
    cambia('''        set Dash_Usos[i] = 0
        set Dash_Fallos[i] = 0
        set i = i + 1
    endloop
    call Bolsa_Anotar(s)''', '''        set Dash_Usos[i] = 0
        set Dash_Fallos[i] = 0
        set i = i + 1
    endloop
    // v19x-prueba: batería de quien tiene el pacto y lo ganado al matar en la oleada.
    set i = 0
    loop
        exitwhen i > 11
        if Bat_Limitada[i] then
            set s = s + "; bat j" + I2S(i) + " " + R2SW(Bat_T[i], 1, 1) + " ganado " + R2SW(Bat_Total[i], 1, 1) + " pilas " + I2S(Bat_Pilas[i]) + " recarga " + I2S(Bat_Rapida[i])
        endif
        set Bat_Total[i] = 0.
        set i = i + 1
    endloop
    call Bolsa_Anotar(s)''')
    for viejo, nuevo in (('lat\\\\v19w-', 'lat\\\\v19x-'), ('v19w-don.txt', 'v19x-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19x', 'prueba' if prueba else 'normal')
