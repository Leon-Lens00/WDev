#!/usr/bin/env python3
"""v14zf (06/11/2026): batería de la luz del héroe. Parte del j de v14ze (= v14zb).

- La luz del héroe pasa a ser la Luz 8 de v14zc (BatLuz5, luz_bateria.cjs) y depende de la batería: 100 s de carga
  que bajan 0,1 cada 0,10 s. Por encima del 10% la luz va entera; del 10% al 0% baja en cinco pasos (BatLuz4..0 = 80,
  60, 40, 20 y 10%) y a 0 se apaga como «-luz 0». Todas llevan Death, así que cada paso se apaga al momento.
- La batería no baja de día (sin luz) ni con la tienda abierta (el HUD está oculto). Shop_Open se fija en lo
  sincronizado (el clic de trackable viaja por la red), así que todos los clientes descuentan igual.
- Recargar batería (Aw0A, V) gasta una recarga y la deja llena. Se empieza con 3 y cada descanso suma 2
  (Ronda_AlTerminar, como el oro). Game_Volver no las repone: sólo se fijan al entrar en la partida.
- Barra: el marco HudBlindaje (Arm_Blindaje, bajo la vida) recibe el relleno de v15a (HudCarga DS0F, Bat_Barra a
  distancia 385 para quedar delante del marco) con su ancho según el porcentaje, amarillo y rojo al 10% o menos.
  Debajo, el texto «Batería N%   Recargas (V): C». Sólo cambia cuando cambia el porcentaje o las recargas.
- Game_Cuerpo fuerza a recrear la luz (Luz_Nivel -2): Game_Volver crea un héroe nuevo y antes se quedaba sin luz.

Uso: v14zf.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def u8(t):
    """El j se lee en latin-1 y es UTF-8: los acentos van como sus bytes UTF-8."""
    return t.encode('utf-8').decode('latin-1')


ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')

s = once(s, 'effect array Luz_Fx\n', u8('''effect array Luz_Fx
// v14zf: batería de la luz (v14zf.py).
integer array Luz_Nivel
real array Bat_T
integer array Bat_Cargas
integer array Bat_Visto
unit array Bat_Barra
integer array Bat_UI
timer Bat_Reloj= null
'''))

# Barra y texto, antes de Arm_Hud, que los coloca en el mismo tick que el resto del HUD.
s = once(s, 'function Arm_Hud takes integer p, integer cam returns nothing\n', u8(r'''// v14zf: como Arm_Foto sin cambiar la textura, que sólo prende al crear el dummy (Sob_Ancho de v15a). El relleno va a
// 385 y no a 399: lo translúcido se ordena por distancia a la cámara y a 399 el marco lo tapaba.
function Bat_Ancho takes unit u, real wpx, real hpx returns nothing
    local real w = wpx * (0.544 / 718.18930543) * 385.
    local real h = hpx * (0.302 / 387.73819261) * 385.
    local real a
    local integer anim = 0
    if h < w then
        set anim = IMinBJ(100, R2I(10 * (w / h - 1) + 0.5))
    else
        set a = 10 * (h / w - 1)
        if a >= 0.5 then
            set anim = 100 + IMinBJ(100, R2I(a + 0.5))
        endif
    endif
    call SetUnitScale(u, 0.5 * RMinBJ(w, h), 0.5 * RMinBJ(w, h), 0.5 * RMinBJ(w, h))
    call SetUnitAnimationByIndex(u, anim)
endfunction

// v14zf: el relleno ocupa el hueco del marco (156,6 px desde x 151,7) según la batería; el porcentaje se redondea hacia
// arriba para que sólo marque 0 cuando la luz ya está apagada. Ancho, color y texto sólo cambian con la clave.
function Bat_Hud takes integer p, integer cam returns nothing
    local integer pct = IMinBJ(100, R2I(Bat_T[p] + 0.999))
    local integer clave = pct * 1000 + Bat_Cargas[p]
    local integer a = 0
    local integer g = 210
    local integer b = 80
    if clave != Bat_Visto[p] then
        set Bat_Visto[p] = clave
        if pct <= 10 then
            set g = 60
            set b = 40
        endif
        if GetLocalPlayer() == Player(p) then
            set a = 255
        endif
        call SetUnitVertexColor(Bat_Barra[p], 255, g, b, a)
        call Bat_Ancho(Bat_Barra[p], RMaxBJ(1., 1.566 * pct), 21.2)
        call SetTextTagColor(s__UIText_text[Bat_UI[p]], 255, IMinBJ(255, g + 40), b + 40, 255)
        call Arm_Texto(Bat_UI[p], "Batería " + I2S(pct) + "%   Recargas (V): " + I2S(Bat_Cargas[p]), 0.015, 158.)
    endif
    if pct > 0 then
        call HealthBars__Place(Bat_Barra[p], cam, 151.7 + 0.783 * pct, 124., 385.)
    endif
endfunction

function Arm_Hud takes integer p, integer cam returns nothing
'''))
s = once(s, '''    call ShowUnit(Arm_Blindaje[p], shown)
    call s__UIText_show(Arm_NombreUI[p], shown, cam)
''', '''    call ShowUnit(Arm_Blindaje[p], shown)
    call ShowUnit(Bat_Barra[p], shown and Bat_T[p] > 0.)
    call s__UIText_show(Bat_UI[p], shown, cam)
    call s__UIText_show(Arm_NombreUI[p], shown, cam)
''')
s = once(s, '''        call HealthBars__Place(Arm_Blindaje[p], cam, 230., 124., 400.)
        set clave =''', '''        call HealthBars__Place(Arm_Blindaje[p], cam, 230., 124., 400.)
        call Bat_Hud(p, cam)
        set clave =''')
s = once(s, "    call Arm_Foto(Arm_Blindaje[p], 165., 20., 'DS0E')\n", """    call Arm_Foto(Arm_Blindaje[p], 165., 20., 'DS0E')
    set Bat_Barra[p] = HealthBars__Dummy('uidb', p)
    call UnitAddAbility(Bat_Barra[p], s__Interface_LOCUST_ID)
    call UnitRemoveAbility(Bat_Barra[p], s__Interface_LOCUST_ID)
    call Arm_Foto(Bat_Barra[p], 156.6, 21.2, 'DS0F')
    set Bat_UI[p] = s__UIText_createEx(Player(p), 0., 0., 1.)
    call SetTextTagPermanent(s__UIText_text[Bat_UI[p]], true)
    set Bat_Visto[p] = - 1
""")

# Luz según la batería.
s = once(s, '''function Luz_Poner takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        if Luz_Fx[p] != null then
            call DestroyEffect(Luz_Fx[p])
            set Luz_Fx[p] = null
        endif
        if Variante > 0 and GetUnitTypeId(Game_Hero[p]) != 0 then
            set Luz_Fx[p] = AddSpecialEffectTarget("war3mapImported\\\\LightWhite1500.mdx", Game_Hero[p], "origin")
        endif
        set p = p + 1
    endloop
endfunction
''', u8('''// v14zf: paso de luz según la batería: -1 sin luz, 5 entera (más del 10%), 4..0 del 10% al 0% (80, 60, 40, 20, 10%).
function Luz_NivelDe takes integer p returns integer
    if Variante == 0 or GetUnitTypeId(Game_Hero[p]) == 0 or Bat_T[p] <= 0. then
        return - 1
    elseif Bat_T[p] > 10. then
        return 5
    endif
    return IMinBJ(4, R2I(Bat_T[p] / 2.))
endfunction

// Cambia el efecto sólo si cambió el paso (o si se fuerza). Estado común: se llama igual en todos los clientes.
function Luz_Ajustar takes integer p, boolean forzar returns nothing
    local integer n = Luz_NivelDe(p)
    if n == Luz_Nivel[p] and not forzar then
        return
    endif
    set Luz_Nivel[p] = n
    if Luz_Fx[p] != null then
        call DestroyEffect(Luz_Fx[p])
        set Luz_Fx[p] = null
    endif
    if n >= 0 then
        set Luz_Fx[p] = AddSpecialEffectTarget("war3mapImported\\\\BatLuz" + I2S(n) + ".mdx", Game_Hero[p], "origin")
    endif
endfunction

function Luz_Poner takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        call Luz_Ajustar(p, true)
        set p = p + 1
    endloop
endfunction

// v14zf: 0,1 s de batería cada 0,10 s; no baja de día ni con la tienda abierta.
function Bat_Paso takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        if Bat_T[p] > 0. and Variante != 0 and GetUnitTypeId(Game_Hero[p]) != 0 and not Shop_Open[p] then
            set Bat_T[p] = RMaxBJ(0., Bat_T[p] - 0.1)
        endif
        call Luz_Ajustar(p, false)
        set p = p + 1
    endloop
endfunction

function Bat_Recargar takes nothing returns nothing
    local integer p = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
    if Bat_Cargas[p] <= 0 then
        call DisplayTimedTextToPlayer(Player(p), 0, 0, 3, "|cffff6040Sin recargas de batería: cada descanso da 2.|r")
    elseif Bat_T[p] >= 100. then
        call DisplayTimedTextToPlayer(Player(p), 0, 0, 3, "La batería ya está llena.")
    else
        set Bat_Cargas[p] = Bat_Cargas[p] - 1
        set Bat_T[p] = 100.
        call Luz_Ajustar(p, false)
    endif
endfunction
'''))

# Cada cuerpo nuevo lleva el botón y recrea la luz; la batería y las recargas se fijan al entrar en la partida.
s = once(s, '''    call Arm_Botones(p)
    call Silence_HideMove(Game_Ctrl[p])
''', '''    call Arm_Botones(p)
    call UnitAddAbility(Game_Ctrl[p], 'Aw0A')
    call Silence_HideMove(Game_Ctrl[p])
    set Luz_Nivel[p] = - 2
''')
s = once(s, '''    call Game_Cuerpo(p , GetLocationX(start) , GetLocationY(start))
''', '''    call Game_Cuerpo(p , GetLocationX(start) , GetLocationY(start))
    set Bat_T[p] = 100.
    set Bat_Cargas[p] = 3
    if Bat_Reloj == null then
        set Bat_Reloj = CreateTimer()
        call TimerStart(Bat_Reloj, 0.10, true, function Bat_Paso)
        call RegisterSpellEffectEvent('Aw0A', function Bat_Recargar)
    endif
''')
s = once(s, '''                call Oro_Dar(p, 40 * Ronda_Numero + 10 * Ronda_Numero * Ronda_Numero)
''', '''                call Oro_Dar(p, 40 * Ronda_Numero + 10 * Ronda_Numero * Ronda_Numero)
                set Bat_Cargas[p] = Bat_Cargas[p] + 2
''')
assert 'LightWhite1500' not in s
Path(sal).write_text(s, encoding='latin-1', newline='')
