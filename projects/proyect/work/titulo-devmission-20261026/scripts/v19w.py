#!/usr/bin/env python3
"""v19w (19/11/2026), fase 4 del plan devmission-v20-mutaciones-rachas-mvp.md: dash por cargas, sin maná.
- 2 cargas de base; se recarga una cada vez, 6 s por carga. Sin carga: sonido de error y no sale. Todo en código común
  (el lanzamiento de 'Ard1' es sincronizado; Dash_Tick es un reloj de 0,1 s que corre en todos los clientes).
- El descanso entre oleadas (Ronda_Reponer) llena las cargas, como antes el maná.
- HUD: icono del dash (BTNBootsOfSpeed, 'DC0N') bajo el arma, con dos textos locales: cargas ("x2") y recarga
  ("4.3 s", vacío con todas). Icono gris sin cargas (color de vértice local).
- 4 mejoras del héroe, que salen pocas veces (un hueco de 11 en la tirada, Her_Pool[10] = 24, que elige entre las que
  no están al máximo; si todas lo están, sale otra carta normal):
  24 Impulso extra +1 carga (máx. 4) · 25 Enfriamiento -6/8/10/12/15 % recarga (mín. 3,5 s) ·
  78 Dash largo +6/8/10/12/15 % distancia (máx. +36 %) · 79 Dash veloz -5/7/9/11/13 % duración (máx. -30 %).
  24 y 25 eran Pisotón y Onda de choque, que no estaban en la tirada; 78/79 quedan fuera del rango de técnicas (40-77).
- Bot (desactivado): mira cargas en lugar de maná y da la orden de 'Ard1' ("shockwave" a un punto); antes daba
  "thunderclap"/"stomp" sin blanco, que no corresponden a 'Ard1'.
- Prueba: Mut_Anotar añade por oleada dashes hechos y fallidos sin carga; Her_Log, cargas/recarga/distancia/duración.
Uso: v19w.py ENTRADA.j SALIDA.j [prueba]   (normal de v19v; prueba de v19v-prueba)
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
cambia('integer array Her_Zancada\n', '''integer array Her_Zancada
// v19w: dash por cargas.
timer Dash_Reloj = null
integer array Dash_Gastadas
integer array Dash_Extra
real array Dash_Rec
real array Dash_RecRed
real array Dash_DistB
real array Dash_DurB
integer array Dash_Usos
integer array Dash_Fallos
unit array Dash_Ico
integer array Dash_CargaUI
integer array Dash_RecUI
integer array Dash_Clave
''')

# --- núcleo de cargas y HUD (antes de Arm_Hud, que va antes del dash de RapidPair y de las cartas) ---
cambia('''function Arm_Hud takes integer p, integer cam returns nothing
''', '''// v19w: dash por cargas (código común).
function Dash_Max takes integer p returns integer
    return 2 + Dash_Extra[p]
endfunction

function Dash_Recarga takes integer p returns real
    return RMaxBJ(3.5, 6. * (1. - Dash_RecRed[p]))
endfunction

function Dash_Tick takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        if Dash_Gastadas[p] > 0 then
            set Dash_Rec[p] = Dash_Rec[p] - 0.1
            if Dash_Rec[p] <= 0.001 then
                set Dash_Gastadas[p] = Dash_Gastadas[p] - 1
                set Dash_Rec[p] = 0.
                if Dash_Gastadas[p] > 0 then
                    set Dash_Rec[p] = Dash_Recarga(p)
                endif
            endif
        endif
        set p = p + 1
    endloop
endfunction

// Gasta una carga de p; sin carga suena el error y devuelve false.
function Dash_Gastar takes integer p returns boolean
    if Dash_Reloj == null then
        set Dash_Reloj = CreateTimer()
        call TimerStart(Dash_Reloj, 0.1, true, function Dash_Tick)
    endif
    if Dash_Gastadas[p] >= Dash_Max(p) then
        set Dash_Fallos[p] = Dash_Fallos[p] + 1
        if GetLocalPlayer() == Player(p) and UI_ErrorSnd != null then
            call StopSound(UI_ErrorSnd, false, false)
            call StartSound(UI_ErrorSnd)
        endif
        return false
    endif
    if Dash_Gastadas[p] == 0 then
        set Dash_Rec[p] = Dash_Recarga(p)
    endif
    set Dash_Gastadas[p] = Dash_Gastadas[p] + 1
    set Dash_Usos[p] = Dash_Usos[p] + 1
    return true
endfunction

// Carta de mejora del dash al azar entre las que no están al máximo; si ninguna, una carta normal.
function Dash_Carta takes integer p returns integer
    local integer array l
    local integer n = 0
    if Dash_Extra[p] < 2 then
        set l[n] = 24
        set n = n + 1
    endif
    if Dash_RecRed[p] < 0.41 then
        set l[n] = 25
        set n = n + 1
    endif
    if Dash_DistB[p] < 0.355 then
        set l[n] = 78
        set n = n + 1
    endif
    if Dash_DurB[p] < 0.295 then
        set l[n] = 79
        set n = n + 1
    endif
    if n == 0 then
        return Her_Pool[GetRandomInt(0, 9)]
    endif
    return l[GetRandomInt(0, n - 1)]
endfunction

// Textos del dash en el HUD (locales: UIText sólo crea el texto en el cliente de p).
function Dash_Hud takes integer p returns nothing
    local integer n = Dash_Max(p) - Dash_Gastadas[p]
    local integer clave = n * 1000 + R2I(Dash_Rec[p] * 10. + 0.999)
    local string s = ""
    if Dash_Gastadas[p] <= 0 then
        set clave = n * 1000
    endif
    if clave == Dash_Clave[p] then
        return
    endif
    set Dash_Clave[p] = clave
    call s__UIText_setPosition(Dash_CargaUI[p], (92. - 960.) / 728., (420. - 256.) / 390.)
    call JefeTx_Texto(Dash_CargaUI[p], s__UIText_text[Dash_CargaUI[p]], "x" + I2S(n), 0.022)
    if Dash_Gastadas[p] > 0 then
        set s = R2SW(RMaxBJ(0., Dash_Rec[p]), 1, 1) + " s"
    endif
    call s__UIText_setPosition(Dash_RecUI[p], (92. - 960.) / 728., (420. - 280.) / 390.)
    call JefeTx_Texto(Dash_RecUI[p], s__UIText_text[Dash_RecUI[p]], s, 0.015)
    if GetLocalPlayer() == Player(p) then
        if n <= 0 then
            call SetUnitVertexColor(Dash_Ico[p], 110, 110, 110, 255)
        else
            call SetUnitVertexColor(Dash_Ico[p], 255, 255, 255, 255)
        endif
    endif
endfunction

function Arm_Hud takes integer p, integer cam returns nothing
''')
cambia('''    call s__UIText_show(Arm_BalasUI[p], shown, cam)
    if shown then
        call HealthBars__Place(Arm_Icono[p], cam, 90., 215., 400.)
        call HealthBars__Place(Arm_Blindaje[p], cam, 230., 124., 400.)
        call Bat_Hud(p, cam)''', '''    call s__UIText_show(Arm_BalasUI[p], shown, cam)
    // v19w: dash por cargas bajo el arma.
    call Hud_Ver(Dash_Ico[p], shown)
    call s__UIText_show(Dash_CargaUI[p], shown, cam)
    call s__UIText_show(Dash_RecUI[p], shown, cam)
    if shown then
        call HealthBars__Place(Arm_Icono[p], cam, 90., 215., 400.)
        call HealthBars__Place(Arm_Blindaje[p], cam, 230., 124., 400.)
        call HealthBars__Place(Dash_Ico[p], cam, 62., 276., 400.)
        call Dash_Hud(p)
        call Bat_Hud(p, cam)''')
cambia('''    set Arm_Clave[p] = - 1
    set Arm_IconoCat[p] = 0
endfunction''', '''    set Arm_Clave[p] = - 1
    set Arm_IconoCat[p] = 0
    // v19w: icono y textos del dash.
    set Dash_Ico[p] = HealthBars__Dummy('uidb', p)
    call UnitAddAbility(Dash_Ico[p], s__Interface_LOCUST_ID)
    call UnitRemoveAbility(Dash_Ico[p], s__Interface_LOCUST_ID)
    call Arm_Foto(Dash_Ico[p], 46., 46., 'DC0N')
    set Dash_CargaUI[p] = s__UIText_createEx(Player(p), 0., 0., 1.)
    set Dash_RecUI[p] = s__UIText_createEx(Player(p), 0., 0., 1.)
    call SetTextTagPermanent(s__UIText_text[Dash_CargaUI[p]], true)
    call SetTextTagPermanent(s__UIText_text[Dash_RecUI[p]], true)
    call JefeTx_Color(Dash_CargaUI[p], s__UIText_text[Dash_CargaUI[p]], 255, 255, 255)
    call JefeTx_Color(Dash_RecUI[p], s__UIText_text[Dash_RecUI[p]], 180, 205, 230)
    set Dash_Clave[p] = - 1
endfunction''')

# --- lanzamiento: gasta carga; distancia y duración con mejoras ---
cambia('''        if this != 0 and not IsUnitPaused(s__RapidPair_actor[this]) then
            call s__RapidPair_dash(this,GetSpellTargetX() , GetSpellTargetY())''',
       '''        // v19w: sólo con carga (y con el cuerpo vivo, para no gastarla en balde).
        if this != 0 and not IsUnitPaused(s__RapidPair_actor[this]) and s__GroundCollision_alive(s__RapidPair_actor[this]) and Dash_Gastar(GetPlayerId(GetOwningPlayer(GetTriggerUnit()))) then
            call s__RapidPair_dash(this,GetSpellTargetX() , GetSpellTargetY())''')
cambia('call s__GroundMotion_dash(s__RapidPair_motion[this],angle,s__RapidPair_DASH_DISTANCE,s__RapidPair_DASH_TIME)',
       'call s__GroundMotion_dash(s__RapidPair_motion[this],angle,s__RapidPair_DASH_DISTANCE * ( 1. + Dash_DistB[GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))] ),s__RapidPair_DASH_TIME * ( 1. - Dash_DurB[GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))] ))')
cambia('''                call SetUnitState(Game_Ctrl[p], UNIT_STATE_MANA, GetUnitState(Game_Ctrl[p], UNIT_STATE_MAX_MANA))
''', '''                call SetUnitState(Game_Ctrl[p], UNIT_STATE_MANA, GetUnitState(Game_Ctrl[p], UNIT_STATE_MAX_MANA))
                // v19w: el descanso llena las cargas del dash.
                set Dash_Gastadas[p] = 0
                set Dash_Rec[p] = 0.
''')

# --- bot ---
cambia('    local real m = GetUnitState(Game_Ctrl[Bot_P], UNIT_STATE_MANA)\n    if t < Bot_DashListo or m < 1. or',
       '    local integer m = Dash_Max(Bot_P) - Dash_Gastadas[Bot_P]\n    if t < Bot_DashListo or m < 1 or')
cambia('return IssueImmediateOrder(Game_Ctrl[Bot_P], "thunderclap")',
       'return IssuePointOrder(Game_Ctrl[Bot_P], "shockwave", Bot_X + 450. * Cos(a), Bot_Y + 450. * Sin(a))')
cambia('elseif Bot_Dist > Bot_ACERCAR and m >= 3. and', 'elseif Bot_Dist > Bot_ACERCAR and m >= 2 and')
cambia('return IssueImmediateOrder(Game_Ctrl[Bot_P], "stomp")',
       'return IssuePointOrder(Game_Ctrl[Bot_P], "shockwave", Bot_X + 450. * Cos(a), Bot_Y + 450. * Sin(a))')

# --- cartas ---
cambia('''    set Cua_Nom[24] = "Pisotón"
    set Cua_Des[24] = "Habilidad de Cairne:|naturde alrededor."
    set Cua_Tex[24] = 'DC0D'
    set Cua_Nom[25] = "Onda de choque"
    set Cua_Des[25] = "Habilidad de Cairne:|nonda en línea."
    set Cua_Tex[25] = 'DC0F'
''', '''    // v19w: mejoras del dash (Pisotón y Onda de choque no estaban en la tirada).
    set Cua_Nom[24] = "Impulso extra"
    set Cua_Des[24] = "Una carga más|nde dash."
    set Cua_Tex[24] = 'DC0K'
    set Cua_Nom[25] = "Enfriamiento"
    set Cua_Des[25] = "El dash recarga|nmás rápido."
    set Cua_Tex[25] = 'DC0L'
    set Cua_Nom[78] = "Dash largo"
    set Cua_Des[78] = "El dash llega|nmás lejos."
    set Cua_Tex[78] = 'DC0M'
    set Cua_Nom[79] = "Dash veloz"
    set Cua_Des[79] = "El dash dura|nmenos."
    set Cua_Tex[79] = 'DC0N'
''')
tabla = {24: [1, 1, 1, 1, 1], 25: [6, 8, 10, 12, 15], 78: [6, 8, 10, 12, 15], 79: [5, 7, 9, 11, 13]}
for x in tabla:
    assert f'Her_Tabla[{x * 5}] =' not in src, x
cambia('    set Her_Pool[9] = 38\n', '    set Her_Pool[9] = 38\n    set Her_Pool[10] = 24\n'
       + ''.join(f'    set Her_Tabla[{x * 5 + q}] = {v}\n' for x, vs in tabla.items() for q, v in enumerate(vs)))
cambia('''            set x = Her_Pool[GetRandomInt(0, 9)]
''', '''            set x = Her_Pool[GetRandomInt(0, 10)]
            if x == 24 then
                set x = Dash_Carta(p)
            endif
''')
cambia('and Cua_HCand[k + i] < 39 then', 'and (Cua_HCand[k + i] < 39 or Cua_HCand[k + i] >= 78) then')
cambia('''function Her_Etiqueta takes integer x returns string
    if x >= 40 then''', '''function Her_Etiqueta takes integer x returns string
    if x == 24 or x == 25 or x == 78 or x == 79 then
        return "|cffff9c40Dash|r|n"
    elseif x >= 40 then''')
cambia('''    set Her_B = 205
    if x >= 40 then''', '''    set Her_B = 205
    if x == 24 or x == 25 or x == 78 or x == 79 then
        set Her_R = 255
        set Her_G = 156
        set Her_B = 64
    elseif x >= 40 then''')
cambia('''    if x >= 40 then
        return Her_Etiqueta(x) + Tec_Des(p, x)''', '''    if x >= 40 and x < 78 then
        return Her_Etiqueta(x) + Tec_Des(p, x)''', 2)
cambia('''    elseif x == 28 then
        return Her_Txt + "+40 % de daño''', '''    elseif x == 24 then
        return Her_Txt + "+1 carga de dash|n(máximo 4)."
    elseif x == 25 then
        return Her_Txt + "-" + I2S(v) + " % de recarga|ndel dash (mín. 3,5 s)."
    elseif x == 78 then
        return Her_Txt + "+" + I2S(v) + " % de distancia|ndel dash (máx. +36 %)."
    elseif x == 79 then
        return Her_Txt + "-" + I2S(v) + " % de duración|ndel dash (máx. -30 %)."
    elseif x == 28 then
        return Her_Txt + "+40 % de daño''', 2)
cambia('''    elseif x == 39 then
        call Mut_Purgar()
    elseif x >= 40 then''', '''    elseif x == 24 then
        set Dash_Extra[p] = IMinBJ(2, Dash_Extra[p] + 1)
    elseif x == 25 then
        set Dash_RecRed[p] = RMinBJ(1. - 3.5 / 6., Dash_RecRed[p] + v / 100.)
    elseif x == 78 then
        set Dash_DistB[p] = RMinBJ(0.36, Dash_DistB[p] + v / 100.)
    elseif x == 79 then
        set Dash_DurB[p] = RMinBJ(0.3, Dash_DurB[p] + v / 100.)
    elseif x == 39 then
        call Mut_Purgar()
    elseif x >= 40 and x < 78 then''')
cambia('''" vel " + I2S(350 + Her_Zancada[p])
    set u = null''', '''" vel " + I2S(350 + Her_Zancada[p]) + " dash " + I2S(Dash_Max(p)) + " rec " + R2SW(Dash_Recarga(p), 1, 2) + " dist " + R2SW(450. * (1. + Dash_DistB[p]), 1, 0) + " dur " + R2SW(0.375 * (1. - Dash_DurB[p]), 1, 3)
    set u = null''')

if prueba:
    cambia('''        set Esp_Total[i] = 0.
        set i = i + 1
    endloop
    call Bolsa_Anotar(s)
endfunction''', '''        set Esp_Total[i] = 0.
        set i = i + 1
    endloop
    // v19w-prueba: dashes de cada jugador en la oleada y los que no salieron por falta de carga.
    set i = 0
    loop
        exitwhen i > 11
        if Dash_Usos[i] > 0 or Dash_Fallos[i] > 0 then
            set s = s + "; dash j" + I2S(i) + " " + I2S(Dash_Usos[i]) + " sin carga " + I2S(Dash_Fallos[i]) + " max " + I2S(Dash_Max(i)) + " rec " + R2SW(Dash_Recarga(i), 1, 2)
        endif
        set Dash_Usos[i] = 0
        set Dash_Fallos[i] = 0
        set i = i + 1
    endloop
    call Bolsa_Anotar(s)
endfunction''')
    for viejo, nuevo in (('lat\\\\v19v-', 'lat\\\\v19w-'), ('v19v-don.txt', 'v19w-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v19w', 'prueba' if prueba else 'normal')
