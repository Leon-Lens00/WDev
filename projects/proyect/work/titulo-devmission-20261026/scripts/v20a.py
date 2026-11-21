#!/usr/bin/env python3
"""v20a (19/11/2026), fase 8 (primera parte) del plan devmission-v20-mutaciones-rachas-mvp.md: resultado de la
oleada para 8 jugadores con puntuación y MVP.
- Cuadro nuevo en dos piezas (puntos_v20a.py): tabla 'DSP4' 600 × 470 centrada en x 805 y lado 'DSP5' 300 × 470 en
  x 1265. Tabla de hasta 8 jugadores con bajas, élites, daño, bolsas, caídas y puntos; abajo las mismas casillas de
  bolsas, caídas del equipo y estrellas que antes.
- Datos nuevos por jugador (sincronizados): élites muertas y golpe final al jefe (Oro_Muerte), daño hecho a las
  unidades de la oleada (un disparador EVENT_UNIT_DAMAGED por oleada con cada unidad que aparece; daño hasta la vida
  que le quedaba, sin contar el sobrante).
- Puntos = bajas + 5 × élites + 25 × golpe final al jefe + daño / 150 + 3 × bolsas − 20 × caídas (mínimo 0). MVP el
  que más (empate: más daño); "menos puntos" el que menos, sólo con 2 o más jugadores.
- Secuencia (igual en todos los clientes; sólo textos y sonidos por cliente): tras las bolsas y las estrellas, cada
  columna pasa 1,5 s con números al azar (sin el RNG del juego: una mezcla del tiempo) y el sonido de recoger oro, y
  luego el valor real; los puntos, 2,5 s mientras los cuadros MVP y menos puntos pasan los nombres. Se fijan con el
  MVP en verde y el otro en rojo, GoodJob.wav a los 0,5 s con la recompensa y QuestFailed.wav a los 2 s.
- Recompensa del MVP (con 2 o más jugadores): un pull extra de las cartas del héroe, T3 o T4, en el descanso, como el
  de first blood ("MVP · TN+").
- Los modelos de los héroes en los cuadros MVP / menos puntos quedan para v20b.
- Prueba: registro de la tabla de cada oleada (mvp ronda N; jP bajas élites daño bolsas caídas puntos).
Uso: v20a.py ENTRADA.j SALIDA.j [prueba]   (normal de v19z; prueba de v19z-prueba)
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


def funcion(nombre, nuevo):
    """Sustituye la función entera (de 'function NOMBRE takes' a su endfunction)."""
    global src
    m = list(re.finditer(r'^function %s takes .*?^endfunction\n' % re.escape(nombre), src, re.S | re.M))
    assert len(m) == 1, (nombre, len(m))
    src = src[:m[0].start()] + U(nuevo) + src[m[0].end():]


# --- globales ---
cambia('group Rs_Grupo = null\n', '''group Rs_Grupo = null
// v20a: puntuación de la oleada y MVP.
unit array Punt_Lado
integer array Mvp_Elites
integer array Mvp_Jefe
real array Mvp_Dano
trigger Mvp_Tr = null
integer Mvp_TrRonda = -1
group Mvp_Reg = CreateGroup()
integer Mvp_N = 0
integer array Mvp_Fila
string array Mvp_Nom
integer array Mvp_Val
integer Mvp_Gana = -1
integer Mvp_Pierde = -1
boolean Mvp_Premio = false
boolean array Her_MVP
integer array Her_ExTipo
real Mvp_Ini = 0.
real Mvp_Fija = 0.
integer Mvp_Cubo = -1
integer array Mvp_Son
string array Mvp_Txt
integer array Mvp_TxtV
real array Mvp_Tam
''')

# --- HUD: piezas y textos ---
funcion('Punt_HudCrear', '''// v20a: tabla 'DSP4' y lado 'DSP5' (puntos_v20a.py), 3 estrellas llenas y 3 apagadas, y 15 textos locales:
// 0-5 columnas de datos, 6 nombres, 7-9 cifras de abajo, 10-14 lado (puntos y nombre del MVP, recompensa, puntos y
// nombre de quien menos).
function Punt_HudCrear takes integer p returns nothing
    local integer k = 0
    set Punt_Cuadro[p] = Punt_Pieza(p, 600. * 412. / 400., 470. * 412. / 400., 'DSP4')
    set Punt_Lado[p] = Punt_Pieza(p, 300. * 412. / 400., 470. * 412. / 400., 'DSP5')
    loop
        exitwhen k > 2
        set Punt_Est[p * 6 + k] = Punt_Pieza(p, 38. * 380. / 400., 38. * 380. / 400., 'DSP1')
        set Punt_Est[p * 6 + 3 + k] = Punt_Pieza(p, 38. * 380. / 400., 38. * 380. / 400., 'DSP2')
        set k = k + 1
    endloop
    set k = 0
    loop
        exitwhen k > 14
        set Punt_TT[p * 16 + k] = s__UIText_createEx(Player(p), 0., 0., 1.)
        call SetTextTagPermanent(s__UIText_text[Punt_TT[p * 16 + k]], true)
        call JefeTx_Color(Punt_TT[p * 16 + k], s__UIText_text[Punt_TT[p * 16 + k]], 240, 238, 232)
        set k = k + 1
    endloop
    call JefeTx_Color(Punt_TT[p * 16 + 7], s__UIText_text[Punt_TT[p * 16 + 7]], 255, 220, 140)
    set Punt_Visto[p] = 0
    set Punt_Ok[p] = true
endfunction
''')

funcion('Punt_Hud', '''function Punt_Hud takes integer p, integer cam returns nothing
    local boolean shown
    local integer k = 0
    local integer v
    local integer n
    local real dy = 0.
    local real a
    local boolean txt
    if not Punt_Ok[p] then
        return
    endif
    set shown = Punt_Visible(p) and Punt_T >= 0.25
    if Punt_Visto[p] != Punt_Ver then
        set Punt_Visto[p] = Punt_Ver
        loop
            exitwhen k > 15
            set Punt_Mostr[p * 16 + k] = -1
            set k = k + 1
        endloop
    endif
    // v18l: espera 0,25 s oculto (el parón del fin de ronda), entra desde arriba en 0,5 s (frenando) y sale
    // hacia abajo en 0,5 s (acelerando).
    if Punt_T < 0.75 then
        set a = RMaxBJ(0., 1. - (Punt_T - 0.25) / 0.5)
        set dy = -640. * a * a * a
    elseif Punt_T > Punt_Sale then
        set a = RMinBJ(1., (Punt_T - Punt_Sale) / 0.5)
        set dy = 960. * a * a
    endif
    set txt = shown and dy > -380.
    call Hud_Ver(Punt_Cuadro[p], shown)
    call Hud_Ver(Punt_Lado[p], shown)
    set n = Punt_Val(Punt_Ini[4], 0.4, Punt_Estrellas)
    set k = 0
    loop
        exitwhen k > 2
        call Hud_Ver(Punt_Est[p * 6 + k], txt and k < n)
        call Hud_Ver(Punt_Est[p * 6 + 3 + k], txt and k >= n)
        set k = k + 1
    endloop
    set k = 0
    loop
        exitwhen k > 14
        call s__UIText_show(Punt_TT[p * 16 + k], txt, cam)
        set k = k + 1
    endloop
    if not shown then
        return
    endif
    call HealthBars__Place(Punt_Cuadro[p], cam, 805.0, 380.0 + dy, 412.)
    call HealthBars__Place(Punt_Lado[p], cam, 1265.0, 380.0 + dy, 412.)
    set k = 0
    loop
        exitwhen k > 2
        call HealthBars__Place(Punt_Est[p * 6 + k], cam, 981.0 + 40. * k, 517 + dy, 380.)
        call HealthBars__Place(Punt_Est[p * 6 + 3 + k], cam, 981.0 + 40. * k, 517 + dy, 380.)
        set k = k + 1
    endloop
    // v20a: textos de la tabla y del lado (Mvp_Tick, iguales en todos los clientes) cuando cambian.
    set k = 0
    loop
        exitwhen k > 11
        set n = k
        if k > 6 then
            set n = k + 3
        endif
        if Punt_Mostr[p * 16 + n] != Mvp_TxtV[k] then
            set Punt_Mostr[p * 16 + n] = Mvp_TxtV[k]
            call JefeTx_Texto(Punt_TT[p * 16 + n], s__UIText_text[Punt_TT[p * 16 + n]], Mvp_Txt[k], Mvp_Tam[k])
        endif
        set k = k + 1
    endloop
    call Punt_Pos(Punt_TT[p * 16], 741.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 1], 797.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 2], 857.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 3], 917.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 4], 981.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 5], 1043.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 6], 539.0, 243.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 10], 1139.0, 240.0 + dy, 0.030)
    call Punt_Pos(Punt_TT[p * 16 + 11], 1139.0, 300.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 12], 1139.0, 340.0 + dy, 0.014)
    call Punt_Pos(Punt_TT[p * 16 + 13], 1139.0, 472.0 + dy, 0.030)
    call Punt_Pos(Punt_TT[p * 16 + 14], 1139.0, 532.0 + dy, 0.019)
    // Cifras de abajo: el texto sólo cambia con el recuento.
    set v = Punt_Val(Punt_Ini[1], Punt_Paso[1], Punt_Cogidas)
    if v != Punt_Mostr[p * 16 + 7] then
        set Punt_Mostr[p * 16 + 7] = v
        call JefeTx_Texto(Punt_TT[p * 16 + 7], s__UIText_text[Punt_TT[p * 16 + 7]], I2S(v), 0.028)
    endif
    call Punt_PosC(Punt_TT[p * 16 + 7], v, 591.0, 563 + dy, 0.028)
    set v = Punt_Val(Punt_Ini[2], Punt_Paso[2], Punt_Perdidas)
    if v != Punt_Mostr[p * 16 + 8] then
        set Punt_Mostr[p * 16 + 8] = v
        call JefeTx_Texto(Punt_TT[p * 16 + 8], s__UIText_text[Punt_TT[p * 16 + 8]], I2S(v), 0.028)
    endif
    call Punt_PosC(Punt_TT[p * 16 + 8], v, 735.0, 563 + dy, 0.028)
    set v = Punt_Val(Punt_Ini[3], Punt_Paso[3], Punt_Caidas)
    if v != Punt_Mostr[p * 16 + 9] then
        set Punt_Mostr[p * 16 + 9] = v
        call JefeTx_Texto(Punt_TT[p * 16 + 9], s__UIText_text[Punt_TT[p * 16 + 9]], I2S(v), 0.028)
    endif
    call Punt_PosC(Punt_TT[p * 16 + 9], v, 879.0, 538 + dy, 0.028)
endfunction
''')

# --- recuento de la tabla (antes de Punt_Tick) ---
cambia('''// Una vez por tick del HUD (0,01 s), igual en todos los clientes: sonidos del recuento (orden de Dark Moon).''', '''// v20a: texto k de la tabla o del lado; sube su versión si cambia.
function Mvp_Pon takes integer k, string s returns nothing
    if s != Mvp_Txt[k] then
        set Mvp_Txt[k] = s
        set Mvp_TxtV[k] = Mvp_TxtV[k] + 1
    endif
endfunction

// Número "al azar" del recuento sin el RNG del juego (mezcla del tiempo, la fila y la columna).
function Mvp_Azar takes integer b, integer f, integer c, integer v returns integer
    return ModuloInteger(b * 7919 + f * 104729 + c * 1299709, IMaxBJ(9, v * 2) + 1)
endfunction

function Mvp_Celda takes integer f, integer c, integer b returns string
    local integer v = Mvp_Val[f * 8 + c]
    local real s = Mvp_Ini + 1.5 * c
    local real e = s + 1.5
    if c == 5 then
        set e = Mvp_Fija
    endif
    if Punt_T < s then
        return "-"
    elseif Punt_T < e then
        return I2S(Mvp_Azar(b, f, c, v))
    elseif c == 5 and f == Mvp_Gana then
        return "|cff50ff50" + I2S(v) + "|r"
    elseif c == 5 and f == Mvp_Pierde then
        return "|cffff5050" + I2S(v) + "|r"
    endif
    return I2S(v)
endfunction

// Una vez por tick, desde Punt_Tick: textos (cada 0,06 s) y sonidos del recuento de la tabla.
function Mvp_Tick takes nothing returns nothing
    local integer b
    local integer c = 0
    local integer f
    local string s
    if Punt_T < 0. or Mvp_N <= 0 then
        return
    endif
    set b = R2I(Punt_T / 0.06)
    if b != Mvp_Cubo then
        set Mvp_Cubo = b
        loop
            exitwhen c > 5
            set s = ""
            set f = 0
            loop
                exitwhen f >= Mvp_N
                if f > 0 then
                    set s = s + "|n"
                endif
                set s = s + Mvp_Celda(f, c, b)
                set f = f + 1
            endloop
            call Mvp_Pon(c, s)
            set c = c + 1
        endloop
        if Punt_T < Mvp_Ini + 7.5 then
            call Mvp_Pon(7, "")
            call Mvp_Pon(8, "")
            call Mvp_Pon(9, "")
            call Mvp_Pon(10, "")
            call Mvp_Pon(11, "")
        elseif Punt_T < Mvp_Fija then
            call Mvp_Pon(7, I2S(Mvp_Azar(b, 9, 6, Mvp_Val[Mvp_Gana * 8 + 5])))
            call Mvp_Pon(8, Mvp_Nom[ModuloInteger(b / 2, Mvp_N)])
            if Mvp_Pierde >= 0 then
                call Mvp_Pon(10, I2S(Mvp_Azar(b, 10, 7, Mvp_Val[Mvp_Gana * 8 + 5])))
                call Mvp_Pon(11, Mvp_Nom[ModuloInteger(b / 2 + 1, Mvp_N)])
            endif
        else
            call Mvp_Pon(7, "|cff50ff50" + I2S(Mvp_Val[Mvp_Gana * 8 + 5]) + " puntos|r")
            call Mvp_Pon(8, Mvp_Nom[Mvp_Gana])
            if Punt_T >= Mvp_Fija + 0.5 then
                if Mvp_Premio then
                    call Mvp_Pon(9, "|cffffcc00Recompensa: carta extra|nT3+ en el descanso.|r")
                else
                    call Mvp_Pon(9, "|cff909090Sin recompensa con|nun solo jugador.|r")
                endif
            endif
            if Mvp_Pierde >= 0 then
                call Mvp_Pon(10, "|cffff5050" + I2S(Mvp_Val[Mvp_Pierde * 8 + 5]) + " puntos|r")
                call Mvp_Pon(11, Mvp_Nom[Mvp_Pierde])
            endif
        endif
    endif
    set c = 0
    loop
        exitwhen c > 5
        if Mvp_Son[c] == 0 and Punt_T >= Mvp_Ini + 1.5 * c then
            set Mvp_Son[c] = 1
            call Punt_Sonar("Sound\\\\Interface\\\\ReceiveGold.wav", 589, 110)
        endif
        set c = c + 1
    endloop
    if Mvp_Son[6] == 0 and Punt_T >= Mvp_Fija + 0.5 then
        set Mvp_Son[6] = 1
        call Punt_Sonar("Sound\\\\Interface\\\\GoodJob.wav", 2548, 120)
    endif
    if Mvp_Son[7] == 0 and Mvp_Pierde >= 0 and Punt_T >= Mvp_Fija + 2. then
        set Mvp_Son[7] = 1
        call Punt_Sonar("Sound\\\\Interface\\\\QuestFailed.wav", 4690, 120)
    endif
endfunction

// Una vez por tick del HUD (0,01 s), igual en todos los clientes: sonidos del recuento (orden de Dark Moon).''')
cambia('''    set Punt_T = Punt_T + 0.01
    if Punt_T >= Punt_Sale + 0.5 then''', '''    call Mvp_Tick()
    set Punt_T = Punt_T + 0.01
    if Punt_T >= Punt_Sale + 0.5 then''')

# --- datos por jugador y tabla (antes de Punt_Preparar) ---
cambia('''// v18k: tiempos del recuento (Punt_Ini, Punt_Paso, Punt_Sale) y columnas de la tabla, igual en todos los clientes.''',
       '''// v20a: daño a las unidades de la oleada, por jugador (hasta la vida que les quedaba).
function Mvp_Golpe takes nothing returns nothing
    local unit s = GetEventDamageSource()
    local integer k
    local real d
    if s != null and not Ronda_Descanso then
        set k = GetPlayerId(GetOwningPlayer(s))
        if k >= 0 and k < 8 then
            set d = RMinBJ(GetEventDamage(), GetWidgetLife(GetTriggerUnit()))
            if d > 0. then
                set Mvp_Dano[k] = Mvp_Dano[k] + d
            endif
        endif
    endif
    set s = null
endfunction

// Cada unidad que aparece en la oleada (RegisterWaveSpawnEvent); un disparador nuevo por oleada.
function Mvp_Alta takes nothing returns nothing
    local unit u = GetWaveEventUnit()
    if Mvp_TrRonda != Ronda_Numero or Mvp_Tr == null then
        if Mvp_Tr != null then
            call DestroyTrigger(Mvp_Tr)
        endif
        set Mvp_Tr = CreateTrigger()
        call TriggerAddAction(Mvp_Tr, function Mvp_Golpe)
        set Mvp_TrRonda = Ronda_Numero
        call GroupClear(Mvp_Reg)
    endif
    if u != null and not IsUnitInGroup(u, Mvp_Reg) then
        call GroupAddUnit(Mvp_Reg, u)
        call TriggerRegisterUnitEvent(Mvp_Tr, u, EVENT_UNIT_DAMAGED)
    endif
    set u = null
endfunction

// Élites y golpe final al jefe (desde Oro_Muerte, con el jugador que mata).
function Mvp_Muerte takes integer k, unit u returns nothing
    local integer id = GetUnitTypeId(u)
    if id >= 'ne00' and id <= 'ne09' then
        set Mvp_Elites[k] = Mvp_Elites[k] + 1
    elseif (DevJefe != null and u == DevJefe) or (id >= 'nj00' and id <= 'nj0A') then
        set Mvp_Jefe[k] = 1
    endif
endfunction

// Fila a mejor que fila b: más puntos; empate, más daño.
function Mvp_Mejor takes integer a, integer b returns boolean
    if Mvp_Val[a * 8 + 5] != Mvp_Val[b * 8 + 5] then
        return Mvp_Val[a * 8 + 5] > Mvp_Val[b * 8 + 5]
    endif
    return Mvp_Val[a * 8 + 2] > Mvp_Val[b * 8 + 2]
endfunction

// Tabla, MVP, recompensa y tiempos del recuento (tras las estrellas), igual en todos los clientes.
function Mvp_Preparar takes nothing returns nothing
    local integer q = 0
    local integer f = 0
    local integer v
    local string nom = ""
    set Mvp_Gana = -1
    set Mvp_Pierde = -1
    loop
        exitwhen q > 7
        set Her_MVP[q] = false
        if Game_On[q] then
            set Mvp_Fila[f] = q
            set Mvp_Nom[f] = Racha_NombreJ(q)
            set Mvp_Val[f * 8] = Punt_BajasJ[q]
            set Mvp_Val[f * 8 + 1] = Mvp_Elites[q]
            set Mvp_Val[f * 8 + 2] = R2I(Mvp_Dano[q])
            set Mvp_Val[f * 8 + 3] = Punt_BolsasJ[q]
            set Mvp_Val[f * 8 + 4] = Punt_CaidasJ[q]
            set v = Punt_BajasJ[q] + 5 * Mvp_Elites[q] + 25 * Mvp_Jefe[q] + R2I(Mvp_Dano[q] / 150.) + 3 * Punt_BolsasJ[q] - 20 * Punt_CaidasJ[q]
            set Mvp_Val[f * 8 + 5] = IMaxBJ(0, v)
            if Mvp_Gana < 0 or Mvp_Mejor(f, Mvp_Gana) then
                set Mvp_Gana = f
            endif
            if Mvp_Pierde < 0 or Mvp_Mejor(Mvp_Pierde, f) then
                set Mvp_Pierde = f
            endif
            if f > 0 then
                set nom = nom + "|n"
            endif
            set nom = nom + Mvp_Nom[f]
            set f = f + 1
        endif
        set q = q + 1
    endloop
    set Mvp_N = f
    if f < 2 then
        set Mvp_Pierde = -1
    elseif Mvp_Pierde == Mvp_Gana then
        set Mvp_Pierde = ModuloInteger(Mvp_Gana + 1, f)
    endif
    set Mvp_Premio = f >= 2
    if Mvp_Premio then
        set Her_MVP[Mvp_Fila[Mvp_Gana]] = true
    endif
    set Mvp_Ini = Punt_Ini[4] + 0.4 * Punt_Estrellas + 0.6
    set Mvp_Fija = Mvp_Ini + 10.
    set Punt_Sale = Mvp_Fija + 5.
    set Mvp_Cubo = -1
    set q = 0
    loop
        exitwhen q > 11
        call Mvp_Pon(q, "")
        set Mvp_Tam[q] = 0.019
        set q = q + 1
    endloop
    set q = 0
    loop
        exitwhen q > 7
        set Mvp_Son[q] = 0
        set q = q + 1
    endloop
    set Mvp_Tam[7] = 0.030
    set Mvp_Tam[9] = 0.014
    set Mvp_Tam[10] = 0.030
    call Mvp_Pon(6, nom)
endfunction

// v18k: tiempos del recuento (Punt_Ini, Punt_Paso, Punt_Sale) y columnas de la tabla, igual en todos los clientes.''')
cambia('''            set sep = "|n|n"
            set f = f + 1
        endif
        set q = q + 1
    endloop
endfunction''', '''            set sep = "|n|n"
            set f = f + 1
        endif
        set q = q + 1
    endloop
    call Mvp_Preparar()
endfunction''')
cambia('''        set Punt_BolsasJ[q] = 0
        set q = q + 1''', '''        set Punt_BolsasJ[q] = 0
        set Mvp_Elites[q] = 0
        set Mvp_Jefe[q] = 0
        set Mvp_Dano[q] = 0.
        set q = q + 1''')
cambia('''            call Racha_Muerte(k)
        endif''', '''            call Racha_Muerte(k)
            call Mvp_Muerte(k, GetTriggerUnit())
        endif''')
cambia('    call RegisterWaveDeathEvent(function DevJefe_Muere)\n',
       '    call RegisterWaveDeathEvent(function DevJefe_Muere)\n    call RegisterWaveSpawnEvent(function Mvp_Alta)\n')

# --- recompensa: pull extra del MVP ---
cambia('''            if Her_FB[p] then
                set Her_ExMin[p * 8] = 2
                call Her_CartasExtra(p, p * 40 + 10, 2)
                set Her_Extra[p] = 1
            endif
''', '''            if Her_FB[p] then
                set Her_ExMin[p * 8] = 2
                set Her_ExTipo[p * 8] = 1
                call Her_CartasExtra(p, p * 40 + 10, 2)
                set Her_Extra[p] = 1
            endif
            // v20a: MVP de la oleada (con 2 o más jugadores): pull extra T3 o T4.
            if Her_MVP[p] then
                set Her_ExMin[p * 8 + Her_Extra[p]] = GetRandomInt(2, 3)
                set Her_ExTipo[p * 8 + Her_Extra[p]] = 2
                call Her_CartasExtra(p, p * 40 + (2 + Her_Extra[p]) * 5, Her_ExMin[p * 8 + Her_Extra[p]])
                set Her_Extra[p] = Her_Extra[p] + 1
                set Her_MVP[p] = false
            endif
''')
cambia('''                set Her_ExMin[p * 8 + Her_Extra[p]] = q
''', '''                set Her_ExMin[p * 8 + Her_Extra[p]] = q
                set Her_ExTipo[p * 8 + Her_Extra[p]] = 0
''')
cambia('''    elseif k == 2 and Her_ExFB[p] then
        return "First blood · T3+"
    endif''', '''    elseif Her_ExTipo[p * 8 + k - 2] == 1 then
        return "First blood · T3+"
    elseif Her_ExTipo[p * 8 + k - 2] == 2 then
        return "MVP · T" + I2S(Her_ExMin[p * 8 + k - 2] + 1) + "+"
    endif''')
cambia('if not (Her_ExFB[p] and Cua_Paso[p] == 5) then', 'if Her_ExTipo[p * 8 + Cua_Paso[p] - 5] == 0 then')
assert 'Punt_TT[p * 8' not in src

if prueba:
    cambia('''    call Mvp_Pon(6, nom)
endfunction''', '''    call Mvp_Pon(6, nom)
    // v20a-prueba: tabla de la oleada.
    set nom = "mvp ronda " + I2S(Ronda_Numero) + " gana " + I2S(Mvp_Gana) + " pierde " + I2S(Mvp_Pierde)
    set q = 0
    loop
        exitwhen q >= Mvp_N
        set nom = nom + "; j" + I2S(Mvp_Fila[q]) + " b " + I2S(Mvp_Val[q * 8]) + " e " + I2S(Mvp_Val[q * 8 + 1]) + " d " + I2S(Mvp_Val[q * 8 + 2]) + " o " + I2S(Mvp_Val[q * 8 + 3]) + " c " + I2S(Mvp_Val[q * 8 + 4]) + " jefe " + I2S(Mvp_Jefe[Mvp_Fila[q]]) + " pts " + I2S(Mvp_Val[q * 8 + 5])
        set q = q + 1
    endloop
    call Bolsa_Anotar(nom)
endfunction''')
    for viejo, nuevo in (('lat\\\\v19z-', 'lat\\\\v20a-'), ('v19z-don.txt', 'v20a-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20a', 'prueba' if prueba else 'normal')
