#!/usr/bin/env python3
"""v14c: interfaz de la tienda visible y cuadrada, armas manuales, giro antes de disparar, cuenta de recarga, oro y balas.

Tienda: CreateUnit aparta los paneles de los árboles de la zona, así que se llevan a su sitio con SetUnitX/Y. El ojo
medido en esta zona está a z 1865.66 (suelo 209.5): paneles y trackables se colocan con esa altura real. El golem se
deselecciona al abrir y la barra de vida, ronda y arma se ocultan mientras está abierta.
Armas: sólo subfusiles y rifles usan disparo rápido. Las demás disparan según los clics, sin intervalo. Sin disparo
rápido la unidad se detiene, gira y dispara al quedar de frente. El icono del HUD se pinta al crear (uno por categoría).
Economía: reservas mayores, recarga completa a (precio + 100) / 4 y oro que crece por ronda.

Uso: v14c.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import re, sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

RESERVA = [40, 64, 56, 320, 300, 320, 250, 300, 300, 30, 40, 50, 30, 50, 50, 0, 0, 0, 15, 20, 25]


def u(t):
    return t.encode('utf-8').decode('latin-1')


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')


def antes(marca, texto):
    global s
    s = base.once(s, marca, u(texto) + marca)


s = base.once(s, 'integer Shop_Pausa= 0\n',
              'integer Shop_Pausa= 0\nconstant real Shop_OJO = 1865.66\nboolean array Arm_Gira\nunit array Arm_Iconos\n')

# Reservas
for i, n in enumerate(RESERVA):
    s, k = re.subn(rf'set Arm_Res\[{i}\] = \d+\r\n', f'set Arm_Res[{i}] = {n}\r\n', s)
    assert k == 1, i

# Con el ojo real sobra el ajuste de Title_WX: medido, las piezas salen en y' = 0.9716 y + 6.6.
antes('function Shop_Pic takes real px, real py, real w, real h, real depth, integer tex returns unit\n', '''function Shop_PY takes real py returns real
    return (py - 6.6) / 0.9716
endfunction

''')

# Paneles y trackables
s = base.once(s, '''    local unit u = Title_Pic('uidb', px, py, w, h, depth, tex)
    call SetUnitVertexColor(u, 255, 255, 255, 0)
    set Shop_Pz[Shop_PzN] = u
''', u('''    local unit u = Title_Pic('uidb', px, py, w, h, depth, tex)
    local real x = Title_WX(Shop_PY(py), depth)
    local real y = Title_WY(px, depth)
    // CreateUnit los aparta de los árboles; la altura es la real de esta zona.
    call SetUnitX(u, x)
    call SetUnitY(u, y)
    call SetUnitFlyHeight(u, Shop_OJO - depth - UserInterface_GetTerrainZ(x, y), 0)
    call SetUnitVertexColor(u, 255, 255, 255, 0)
    set Shop_Pz[Shop_PzN] = u
'''))
s = base.once(s, '''    local string path = ""
    local real depth = Title_D() + Title_Eye - 14
    local trackable t
    if GetLocalPlayer() == Player(p) then
        set path = model
    endif
    set t = CreateTrackable(path, Title_WX(py, depth), Title_WY(px, depth), 0)
    call SaveInteger(Shop_HT, GetHandleId(t), 0, p)
''', u('''    local string path = ""
    local real depth = Shop_OJO - 14 - UserInterface_GetTerrainZ(Title_WX(Shop_PY(py), 1642.), Title_WY(px, 1642.))
    local trackable t
    if GetLocalPlayer() == Player(p) then
        set path = model
    endif
    set t = CreateTrackable(path, Title_WX(Shop_PY(py), depth), Title_WY(px, depth), 0)
    call SaveInteger(Shop_HT, GetHandleId(t), 0, p)
'''))

# El juego ordena lo translúcido por distancia al ojo, no por profundidad: los paneles van más hondos para quedar detrás
# de todo lo que tienen encima, y las gemas más cerca porque están lejos del centro de su fila.
for a in ('307, 442, 430, 784', '948, 442, 800, 784', '1601, 442, 454, 784'):
    s = base.once(s, f'call Shop_Pic({a}, 400,', f'call Shop_Pic({a}, 460,')
s = base.once(s, 'call Shop_Pic(166.5, 161 + 66 * i, 15, 26, 398,', 'call Shop_Pic(166.5, 161 + 66 * i, 15, 26, 370,')
s = base.once(s, 'call Shop_Pic(621.5, 156 + 58 * i, 15, 26, 398,', 'call Shop_Pic(621.5, 156 + 58 * i, 15, 26, 370,')

# Textos: medido en captura, en esta zona salen en x' = 0.9886 x + 8.6, y' = 0.96 y - 1.6.
antes('function Shop_Tag takes real px, real py, real size, real w, string s returns texttag\n', '''function Shop_At takes texttag t, real px, real py, real size, real w returns nothing
    local real x = px - w / 2 + 150 * size
    local real y = py + 810 * size
    call Tx_At(t, (x - 8.6) / 0.9886 + w / 2 - 150 * size, (y + 1.6) / 0.96 - 810 * size, size, w)
endfunction

''')
ini = s.index('function Shop_Tag takes')
fin = s.index('function Shop_Refrescar takes')
s = s[:ini] + s[ini:fin].replace('call Tx_At(', 'call Shop_At(') + s[fin:]

# Las filas no estiran más de 11:1: los precios van dentro.
s = base.once(s, 'call Shop_Der(p, Shop_T[4 + k], s, 1290,', 'call Shop_Der(p, Shop_T[4 + k], s, 1190,')
s = base.once(s, 'call Shop_Tag(1190, 96, 0.02, 0, "Precio")', 'call Shop_Tag(1140, 96, 0.02, 0, "Precio")')

s = base.once(s, "call Shop_Pic(621.5, 156 + 58 * i, 15, 26, 370, 'DS0C')", "call Shop_Pic(660, 156 + 58 * i, 15, 26, 370, 'DS0C')")
s = base.once(s, 'Arm_Nombre[x] + s, 644, 141 + k * 58, 0.022)', 'Arm_Nombre[x] + s, 678, 141 + k * 58, 0.022)')

# La opción elegida va en el azul del marco del panel: el blanco se confundía con el resto.
antes('function Shop_Luz takes integer p, unit u, boolean on returns nothing\n', '''function Shop_Elegida takes integer p, texttag t returns nothing
    if GetLocalPlayer() == Player(p) then
        call SetTextTagColor(t, 115, 200, 255, 255)
    endif
endfunction

''')
s = base.once(s, 'call Shop_Pinta(p, Shop_CatT[k], 255)', 'call Shop_Elegida(p, Shop_CatT[k])')
s = base.once(s, """        call Shop_Pinta(p, Shop_T[4 + k], g)
""", """        call Shop_Pinta(p, Shop_T[4 + k], g)
        if k + 1 == t then
            call Shop_Elegida(p, Shop_T[1 + k])
            call Shop_Elegida(p, Shop_T[4 + k])
        endif
""")

# Sin golem seleccionado mientras la tienda está abierta
s = base.once(s, '''    call Shop_Mostrar(p, true)
    call Shop_Refrescar(p)
''', '''    set Arm_Gira[Game_Pair[p]] = false
    call Shop_Mostrar(p, true)
    if GetLocalPlayer() == Player(p) then
        call ClearSelection()
    endif
    call Shop_Refrescar(p)
''')
s = base.once(s, '''    elseif Shop_Open[p] and GetLocalPlayer() == Player(p) then
        call ClearSelection()
        call SelectUnit(Shop_Golem, true)
    endif
''', '''    elseif Shop_Open[p] and GetLocalPlayer() == Player(p) then
        call ClearSelection()
    endif
''')

# HUD fuera mientras la tienda está abierta
s = base.once(s, '            set shown=HealthBars__Visible and GetUnitTypeId(HealthBars__Heroes[p]) != 0\n',
              '            set shown=HealthBars__Visible and GetUnitTypeId(HealthBars__Heroes[p]) != 0 and not Shop_Open[p]\n')
s = base.once(s, '            set shown=HealthBars__Visible and HealthBars__Target != null and GetUnitTypeId(HealthBars__Target) != 0\n',
              '            set shown=HealthBars__Visible and HealthBars__Target != null and GetUnitTypeId(HealthBars__Target) != 0 and not Shop_Open[p]\n')
s = base.once(s, '    local boolean shown= HealthBars__Visible and Ronda_Activa\n',
              '    local boolean shown= HealthBars__Visible and Ronda_Activa and not Shop_Open[p]\n')
s = base.once(s, '    local boolean shown = HealthBars__Visible and GetUnitTypeId(HealthBars__Heroes[p]) != 0\n    local integer c = Arm_Cat[p]\n',
              '    local boolean shown = HealthBars__Visible and GetUnitTypeId(HealthBars__Heroes[p]) != 0 and not Shop_Open[p]\n    local integer c = Arm_Cat[p]\n')

# Icono del HUD: uno ya pintado por categoría
s = base.once(s, '''    call ShowUnit(Arm_Icono[p], shown)
    call ShowUnit(Arm_Blindaje[p], shown)
''', u('''    if Arm_IconoCat[p] != c + 1 then
        if GetLocalPlayer() == Player(p) then
            call SetUnitVertexColor(Arm_Icono[p], 255, 255, 255, 0)
            call SetUnitVertexColor(Arm_Iconos[i - c + c], 255, 255, 255, 255)
        endif
        set Arm_Icono[p] = Arm_Iconos[i]
        set Arm_IconoCat[p] = c + 1
    endif
    call ShowUnit(Arm_Icono[p], shown)
    call ShowUnit(Arm_Blindaje[p], shown)
''').replace('Arm_Iconos[i - c + c]', 'Arm_Iconos[i]'))
s = base.once(s, '''            if Arm_IconoCat[p] != c + 1 then
                set Arm_IconoCat[p] = c + 1
                call Arm_Foto(Arm_Icono[p], 108., 54., Cat_Tex[c])
            endif
''', '')
s = base.once(s, '''function Arm_HudCrear takes integer p returns nothing
    set Arm_Icono[p] = HealthBars__Dummy('uidb', p)
    set Arm_Blindaje[p] = HealthBars__Dummy('uidb', p)
    call UnitAddAbility(Arm_Icono[p], s__Interface_LOCUST_ID)
    call UnitRemoveAbility(Arm_Icono[p], s__Interface_LOCUST_ID)
''', u('''function Arm_HudCrear takes integer p returns nothing
    local integer c = 0
    // La textura sólo prende al crear el dummy, así que hay uno por categoría y se cambia con el alfa.
    loop
        exitwhen c > 6
        set Arm_Iconos[p * 7 + c] = HealthBars__Dummy('uidb', p)
        call SetUnitVertexColor(Arm_Iconos[p * 7 + c], 255, 255, 255, 0)
        call UnitAddAbility(Arm_Iconos[p * 7 + c], s__Interface_LOCUST_ID)
        call UnitRemoveAbility(Arm_Iconos[p * 7 + c], s__Interface_LOCUST_ID)
        call Arm_Foto(Arm_Iconos[p * 7 + c], 108., 54., Cat_Tex[c])
        set c = c + 1
    endloop
    set Arm_Icono[p] = Arm_Iconos[p * 7 + 6]
    set Arm_Blindaje[p] = HealthBars__Dummy('uidb', p)
'''))

# Cuenta de recarga
s = base.once(s, '''        if Arm_Fin[p] > 0 then
            set clave = - clave
        endif
''', '''        if Arm_Fin[p] > 0 then
            set clave = - 1 - R2I((Arm_Fin[p] - TimerGetElapsed(s__RapidPair_clock)) * 10.)
        endif
''')
s = base.once(s, '                set s = "Recargando"\n',
              '                set s = "Recargando " + R2SW(RMaxBJ(0., Arm_Fin[p] - TimerGetElapsed(s__RapidPair_clock)), 1, 1)\n')

# Disparo rápido sólo con armas automáticas; las manuales van según los clics
antes('    function Arm_Puede takes integer this returns boolean\n', '''    function Arm_Automatica takes integer p returns boolean
        return Arm_Cat[p] == 1 or Arm_Cat[p] == 2
    endfunction

''')
antes('    function s__RapidPair_cast takes integer this,real px,real py returns nothing\n', '''    // Gira hasta tener delante el punto del cast y entonces dispara.
    function Arm_Girar takes integer this returns nothing
        local unit a= s__RapidPair_actor[this]
        local integer p= GetPlayerId(GetOwningPlayer(a))
        local real d= Atan2(s__RapidPair_aimY[this] - GetUnitY(a), s__RapidPair_aimX[this] - GetUnitX(a)) - GetUnitFacing(a) * bj_DEGTORAD
        set d=Atan2(Sin(d), Cos(d)) * bj_RADTODEG
        // Medido: 412 grados por s es el tope con umvr 3, ya en el máximo; SetUnitTurnSpeed no lo sube.
        if RAbsBJ(d) > 25. then
            call SetUnitFacingTimed(a, GetUnitFacing(a) + RMaxBJ(-175., RMinBJ(175., d * 4.)), 0.)
        else
            call SetUnitFacingTimed(a, GetUnitFacing(a) + d, 0.)
            set Arm_Gira[this]=false
            if Arm_Fin[p] <= 0. and Arm_Puede(this) then
                set s__RapidPair_pending[this]=1
                set s__RapidPair_remaining=s__RapidPair_remaining + 1
                call s__RapidPair_emit(this)
            endif
        endif
        set a=null
    endfunction

    function Arm_Apuntar takes integer this returns nothing
        local unit a= s__RapidPair_actor[this]
        set s__GroundMotion_hasGoal[s__RapidPair_motion[this]]=false
        call IssueImmediateOrder(a, "stop")
        set Arm_Gira[this]=true
        call Arm_Girar(this)
        set a=null
    endfunction

''')
s = base.once(s, u('''        // Sin disparo rápido: una bala cuando el arma esté lista, sin movimiento artificial.
        if not Arm_Rapido[p] then
            if time + 0.0001 >= ready then
                set s__RapidPair_pending[this]=1
                set s__RapidPair_remaining=s__RapidPair_remaining + 1
                call s__RapidPair_emit(this)
            endif
            return
        endif
'''), u('''        // Sin disparo rápido: se detiene y gira. Las manuales no esperan intervalo; las automáticas sí.
        if not (Arm_Rapido[p] and Arm_Automatica(p)) then
            if not Arm_Automatica(p) or time + 0.0001 >= ready then
                call Arm_Apuntar(this)
            endif
            return
        endif
'''))
s = base.once(s, '''            if s__RapidPair_firing[this] then
                call s__RapidPair_showWalk(this)
                set s__RapidPair_nextShot[this]=RMaxBJ((TimerGetElapsed(s__RapidPair_clock)), Arm_Listo[p * 7 + c])
            endif
''', '''            if s__RapidPair_firing[this] then
                if Arm_Automatica(p) then
                    call s__RapidPair_showWalk(this)
                    set s__RapidPair_nextShot[this]=RMaxBJ((TimerGetElapsed(s__RapidPair_clock)), Arm_Listo[p * 7 + c])
                else
                    call s__RapidPair_finish(this,true)
                endif
            endif
''')
s = base.once(s, '''        local integer p= GetPlayerId(GetOwningPlayer(u))
        set Arm_Rapido[p]=not Arm_Rapido[p]
''', '''        local integer p= GetPlayerId(GetOwningPlayer(u))
        if not Arm_Automatica(p) then
            set u=null
            return
        endif
        set Arm_Rapido[p]=not Arm_Rapido[p]
''')
s = base.once(s, '''            set Arm_Fin[p]=(TimerGetElapsed(s__RapidPair_clock)) + Arm_Rec[w]
''', '''            set Arm_Fin[p]=(TimerGetElapsed(s__RapidPair_clock)) + Arm_Rec[w]
            set Arm_Gira[Game_Pair[p]]=false
''')
s = base.once(s, '''        set Arm_Fin[GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))]=0.
''', '''        set Arm_Fin[GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))]=0.
        set Arm_Gira[this]=false
''')
s = base.once(s, '''            if order == 851986 or order == 851971 then
                call s__GroundMotion_destination(''', '''            if order == 851986 or order == 851971 then
                set Arm_Gira[this]=false
                call s__GroundMotion_destination(''')
s = base.once(s, '''    call PauseTimer(s__RapidPair_reset[this])
    call s__RapidPair_finish(this,false)
    set s__GroundMotion_hasGoal[s__RapidPair_motion[this]] = false
''', '''    call PauseTimer(s__RapidPair_reset[this])
    call s__RapidPair_finish(this,false)
    set Arm_Gira[this] = false
    set s__GroundMotion_hasGoal[s__RapidPair_motion[this]] = false
''')
s = base.once(s, '''                if s__RapidPair_firing[this] then
                    if not s__GroundMotion_dashing[s__RapidPair_motion[this]] then
                        call s__GroundMotion_step(''', '''                if Arm_Gira[this] then
                    call Arm_Girar(this)
                endif
                if s__RapidPair_firing[this] then
                    if not s__GroundMotion_dashing[s__RapidPair_motion[this]] then
                        call s__GroundMotion_step(''')
s, k = re.subn(r'    call Shop_Izq\(p, Shop_T\[9\], I2S\(R2I\(60\. / Arm_Int\[w\] \+ 0\.5\)\) \+ " rpm  " \+ R2SW\(1\. / Arm_Int\[w\], 1, 1\) \+ "/s", (950, 632, [\d.]+)\)\r\n',
               r'''    if c == 1 or c == 2 then
        set s = I2S(R2I(60. / Arm_Int[w] + 0.5)) + " rpm  " + R2SW(1. / Arm_Int[w], 1, 1) + "/s"
    else
        set s = "Manual"
    endif
    call Shop_Izq(p, Shop_T[9], s, \1)
'''.replace('\n', '\r\n'), s)
assert k == 1

# Precio de la munición: la reserva entera vale (precio + 100) / 4
s = base.once(s, '''function Shop_CostoBala takes integer w returns integer
    return IMaxBJ(1, (Arm_Precio[w] + 100) / (Arm_Res[w] * 2))
endfunction
''', u('''function Shop_CostoBalas takes integer w, integer n returns integer
    return (n * ((Arm_Precio[w] + 100) / 4) + Arm_Res[w] - 1) / Arm_Res[w]
endfunction
'''))
s = base.once(s, 'I2S(falta * Shop_CostoBala(x)) + " oro"', 'I2S(Shop_CostoBalas(x, falta)) + " oro"')
s = base.once(s, '''    set costo = Shop_CostoBala(x)
    set n = IMinBJ(Arm_Res[x] - Arm_Rva[i], oro / costo)
''', '''    set n = IMinBJ(Arm_Res[x] - Arm_Rva[i], oro * Arm_Res[x] / ((Arm_Precio[x] + 100) / 4))
''')
s = base.once(s, '''    set Arm_Rva[i] = Arm_Rva[i] + n
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - n * costo)
''', '''    set costo = Shop_CostoBalas(x, n)
    set Arm_Rva[i] = Arm_Rva[i] + n
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - costo)
''')

# Oro: poco al principio, mucho en las últimas rondas
s = base.once(s, 'call Oro_Dar(k, IMaxBJ(3, R2I(GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) / 5.)))',
              'call Oro_Dar(k, IMaxBJ(3, R2I(GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) / 5.)) * (2 + Ronda_Numero) / 3)')
s = base.once(s, 'call Oro_Dar(p, 50 + 25 * Ronda_Numero)', 'call Oro_Dar(p, 40 * Ronda_Numero + 10 * Ronda_Numero * Ronda_Numero)')

Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
