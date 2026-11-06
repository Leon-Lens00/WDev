#!/usr/bin/env python3
r"""v15a: cuatro armas fijas y sobrecarga en lugar de munición (05/11/2026). Plan: docs/planes/devmission-armas-sobrecarga-v15.md.

Pedidos de Leon:
- Se quitan la munición (cargador, reserva, zonas nPtB, «Abastecer todo» y la munición suelta) y las demás categorías.
  El jugador tiene desde el inicio Pistola (Q), Subfusil (W), Escopeta (E) y Francotirador (R).
  Para eso se cambian en los datos las categorías 2 y 4: la Escopeta pasa a la 2 (Aw02, E) y los Rifles, ocultos, a la 4.
  Cuerpo a cuerpo (5) y Explosivos (6) quedan sin dar; sus comprobaciones por número siguen valiendo.
- Ráfaga medida en tiempo: 1,5 s al ritmo del arma (Arm_Rafaga). Escopeta y francotirador disparan cada 0,50 s (3 tiros
  por ráfaga); sus tiers 2 y 3 bajan a 0,45 y 0,40.
- Bala con el color del tier (Yellow, Green, Cyan, Blue, Orange, Red, Purple), aparte del color del jugador, que siguen
  el Windwalk y el dash: Pistola Shot, Subfusil Shot II, Escopeta Firebrand y Francotirador Daemonic Arrow
  (Vinz y Daemonic Sword, Hive 337124). Provisional hasta v15b: Shot y Shot II no tienen Cyan y usan Blue en el T3; la
  flecha sólo tiene su morado original.
- Sonido de disparo de ShootingGay 0.7ENG por arma, en 3D en la posición del que dispara.
- Sobrecarga: cada disparo suma Arm_Calor del arma; cada 0,10 s baja Sob_Refresco (0,8 más 0,2 por nivel de «Mejorar
  sobrecarga», el botón de abajo de la tienda). Al llegar a 100 el arma se bloquea hasta bajar de 60 (valor provisional,
  sin respuesta de Leon). La barra de blindaje se llena con HudCarga (DS0F) y lleva debajo el texttag «Sobrecarga»;
  ambos pasan de verde a rojo. El calor sube un 15 % por tier.
- Refrescar sobrecarga en F (Aw08, la antigua recarga; tecla provisional): gasta un kit y en 2 s deja la sobrecarga a 0.
  El dash y disparar lo cancelan sin gastar el kit. Los kits se compran en la tienda, en el botón de «Abastecer todo».

La tienda sigue siendo la de v14l hasta v15c (la del prototipo): sólo enseña las 4 categorías, el calor por disparo en
lugar del cargador, «Mejorar sobrecarga» y «Kit de refresco». Sus texttags se crean al abrir y se destruyen al cerrar.
Uso: v15a.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

N = '\r\n'


def u(x):
    # El script está en UTF-8 y se lee como latin-1: los acentos de lo insertado también.
    return x.encode('utf-8').decode('latin-1')


def once(s, old, new):
    return base.once(s, u(old), u(new))


def funcion(s, cabeza):
    """Inicio y fin (tras endfunction) de la función que empieza por cabeza."""
    a = s.index(cabeza.replace('\n', N))
    assert s.count(cabeza.replace('\n', N)) == 1, cabeza
    b = s.index(N + 'endfunction', a) if not cabeza.startswith('    ') else s.index(N + '    endfunction', a)
    return a, s.index(N, b + 2) + 2


def en(s, cabeza, old, new):
    """once dentro de una sola función."""
    a, b = funcion(s, cabeza)
    return s[:a] + once(s[a:b], old, new) + s[b:]


def cambiar(s, cabeza, nuevo):
    """Sustituye la función entera."""
    a, b = funcion(s, cabeza)
    return s[:a] + u(nuevo).replace('\n', N) + s[b:]


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')

# Datos: Rifles (2) y Escopetas (4) cambian de lugar.
a, b = funcion(s, 'function Arm_Datos takes nothing returns nothing\n')
datos = s[a:b]
CAMBIO = {2: 4, 4: 2} | {6 + k: 12 + k for k in range(3)} | {12 + k: 6 + k for k in range(3)}


def mover(m):
    nombre, i = m.group(1), int(m.group(2))
    if nombre.startswith('Cat_'):
        i = {2: 4, 4: 2}.get(i, i)
    else:
        i = CAMBIO.get(i, i) if i >= 6 else i
    return f'set {nombre}[{i}] ='


datos = re.sub(r'set (Cat_\w+|Arm_\w+)\[(\d+)\] =', mover, datos)
s = s[:a] + datos + s[b:]

RASGOS = ['Básica, poca sobrecarga', 'Más daño', 'Atraviesa 1',
          'Cadencia alta', 'Cadencia muy alta', 'Menos dispersión, crítico 15%',
          'Cinco perdigones, corta distancia', 'Seis perdigones', 'Seis perdigones, cono cerrado',
          'Sin dispersión', 'Atraviesa 2', 'Atraviesa 2, crítico 25%']
# Calor por disparo (no por perdigón) en el T1; +15 % por tier. Con el refresco base de 8 por segundo, la pistola T1
# (4 tiros/s) se mantiene; el subfusil, la escopeta y el francotirador suben. Valores para calibrar en v15d.
CALOR = [2.0, 1.5, 6.0, 8.0]
SONIDO = ['PistolShoot.wav', 'MachineGunShoot.wav', 'ShotGunShoot.mp3', 'SniperRifleShoot.mp3']
extra = '    // v15a: las 4 armas fijas.\n'
extra += ''.join(f'    set Cat_Nombre[{c}] = "{n}"\n' for c, n in enumerate(['Pistola', 'Subfusil', 'Escopeta', 'Francotirador']))
extra += ''.join(f'    set Arm_Rasgo[{w}] = "{r}"\n' for w, r in enumerate(RASGOS))
extra += ''.join(f'    set Arm_Int[{c * 3 + t}] = {0.50 - 0.05 * t:.2f}\n' for c in (2, 3) for t in range(3))
extra += ''.join(f'    set Arm_Calor[{c * 3 + t}] = {CALOR[c] * 1.15 ** t:.2f}\n' for c in range(4) for t in range(3))
extra += ''.join(f'    set Arm_SonidoRuta[{c}] = "war3mapImported\\\\{n}"\n' for c, n in enumerate(SONIDO))
s = once(s, '    set Shop_Frase[0] = ', extra + '    set Shop_Frase[0] = ')

s = once(s, 'integer array Arm_Clip\n', '''integer array Arm_Clip
// v15a: sobrecarga por jugador (0..100), bloqueo, nivel de refresco, kits y su HUD; calor por disparo de cada arma.
real array Sob_Valor
boolean array Sob_Bloq
integer array Sob_Nivel
integer array Sob_Kits
integer array Sob_Visto
unit array Sob_Barra
integer array Sob_UI
real array Arm_Calor
string array Arm_SonidoRuta
// v15a: bala del disparo en curso (color del tier); vacía, shootFamily usa el color del jugador como antes.
string Arm_BalaModelo= ""
real Arm_BalaRadio= 0.
''')

s = cambiar(s, 'function Arm_Familia takes integer tier returns integer\n', r'''// v15a: familia de bala por categoría (antes por tier): Shot, Shot II, Firebrand y, aparte, Daemonic Arrow (4).
function Arm_Familia takes integer c returns integer
    if c == 1 then
        return 3
    elseif c == 2 then
        return 0
    elseif c == 3 then
        return 4
    endif
    return 1
endfunction
''')

SOB = r'''// v15a: sobrecarga (sustituye a la munición). Cada disparo suma Arm_Calor; cada 0,10 s baja Sob_Refresco. Al llegar a
// 100 el arma se bloquea hasta bajar de Sob_DESBLOQUEO. Refrescar (F) gasta un kit y la deja a 0 en Sob_TIEMPO.
constant function Sob_DESBLOQUEO takes nothing returns real
    return 60.
endfunction

constant function Sob_TIEMPO takes nothing returns real
    return 2.
endfunction

constant function Sob_NIVELES takes nothing returns integer
    return 7
endfunction

constant function Sob_KIT takes nothing returns integer
    return 60
endfunction

constant function Sob_KITS_INICIO takes nothing returns integer
    return 1
endfunction

constant function Sob_KITS_MAX takes nothing returns integer
    return 5
endfunction

function Sob_Refresco takes integer p returns real
    return 0.8 + 0.2 * Sob_Nivel[p]
endfunction

// Precio del nivel n de «Mejorar sobrecarga»: 75, 150, 300... 4800.
function Sob_Precio takes integer n returns integer
    local integer x = 75
    loop
        exitwhen n <= 1
        set x = x * 2
        set n = n - 1
    endloop
    return x
endfunction

function Sob_Paso takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        if Sob_Valor[p] > 0. then
            set Sob_Valor[p] = RMaxBJ(0., Sob_Valor[p] - Sob_Refresco(p))
        endif
        if Sob_Bloq[p] and Sob_Valor[p] < Sob_DESBLOQUEO() then
            set Sob_Bloq[p] = false
        endif
        set p = p + 1
    endloop
endfunction

// Color del tier t para los nombres de los modelos; Firebrand tiene Teal para el Cyan.
function Arm_ColorTier takes integer t, boolean teal returns string
    if t == 1 then
        return "Yellow"
    elseif t == 2 then
        return "Green"
    elseif t == 3 and teal then
        return "Teal"
    elseif t <= 4 then
        return "Blue"
    elseif t == 5 then
        return "Orange"
    elseif t == 6 then
        return "Red"
    endif
    return "Purple"
endfunction

// Modelo y radio de la bala de la categoría c en el tier t (los radios son los de RapidBolt_radiusFor).
function Arm_Bala takes integer c, integer t returns nothing
    if c == 0 then
        set Arm_BalaModelo = "ShotsAjustados\\Shot " + Arm_ColorTier(t, false) + ".mdx"
        set Arm_BalaRadio = 6. * s__RapidBolt_SHOTS_SCALE
    elseif c == 1 then
        set Arm_BalaModelo = "ShotsAjustados\\Shot II " + Arm_ColorTier(t, false) + ".mdx"
        set Arm_BalaRadio = 18. * s__RapidBolt_SHOTS_II_SCALE
        if t == 2 then
            set Arm_BalaRadio = 16.2 * s__RapidBolt_SHOTS_II_SCALE
        endif
    elseif c == 2 then
        set Arm_BalaModelo = "FirebrandShots\\Firebrand Shot " + Arm_ColorTier(t, true) + ".mdx"
        set Arm_BalaRadio = s__RapidBolt_HIT_RADIUS
    else
        // Daemonic Arrow movida en X (TerrainDev/scripts/daemonic_ajustada.cjs): la cabeza queda en +15.
        set Arm_BalaModelo = "DaemonicArrow\\Daemonic Arrow Purple.mdx"
        set Arm_BalaRadio = 15.
    endif
endfunction

// Un sonido por disparo, en 3D donde está el que dispara; se libera al acabar.
function Arm_Sonido takes integer c, real x, real y returns nothing
    local sound snd
    if Arm_SonidoRuta[c] == null then
        return
    endif
    set snd = CreateSound(Arm_SonidoRuta[c], false, true, true, 10, 10, "DefaultEAXON")
    call SetSoundVolume(snd, 110)
    call SetSoundDistances(snd, 1000., 4000.)
    call SetSoundDistanceCutoff(snd, 3500.)
    call SetSoundPosition(snd, x, y, 60.)
    call StartSound(snd)
    call KillSoundWhenDone(snd)
    set snd = null
endfunction

// Como Arm_Foto sin cambiar la textura, que sólo prende al crear el dummy: el ancho del relleno de la barra.
// El relleno va a 385 y no a 399: lo translúcido se ordena por distancia a la cámara y, con el centro más a la izquierda
// que el del marco, a 399 quedaba más lejos que él y el marco lo tapaba (visto en v15a-auto con la sobrecarga al 58%).
function Sob_Ancho takes unit u, real wpx, real hpx returns nothing
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

'''
s = once(s, 'function Arm_Hud takes integer p, integer cam returns nothing\n',
         SOB + 'function Arm_Hud takes integer p, integer cam returns nothing\n')

s = cambiar(s, 'function Arm_Hud takes integer p, integer cam returns nothing\n', r'''function Arm_Hud takes integer p, integer cam returns nothing
    local boolean shown = HealthBars__Visible and GetUnitTypeId(HealthBars__Heroes[p]) != 0 and not Shop_Open[p]
    local integer c = Arm_Cat[p]
    local integer i = p * 7 + c
    local integer w
    local integer clave
    local integer pct = IMinBJ(100, R2I(Sob_Valor[p] + 0.5))
    local integer r
    local integer g
    local integer a = 0
    local string s
    if Arm_Icono[p] == null then
        return
    endif
    if Arm_IconoCat[p] != c + 1 then
        if GetLocalPlayer() == Player(p) then
            call SetUnitVertexColor(Arm_Icono[p], 255, 255, 255, 0)
            call SetUnitVertexColor(Arm_Iconos[i], 255, 255, 255, 255)
        endif
        set Arm_Icono[p] = Arm_Iconos[i]
        set Arm_IconoCat[p] = c + 1
    endif
    call ShowUnit(Arm_Icono[p], shown)
    call ShowUnit(Arm_Blindaje[p], shown)
    call ShowUnit(Sob_Barra[p], shown and pct > 0)
    call s__UIText_show(Arm_NombreUI[p], shown, cam)
    call s__UIText_show(Arm_BalasUI[p], shown, cam)
    call s__UIText_show(Sob_UI[p], shown, cam)
    if shown then
        call HealthBars__Place(Arm_Icono[p], cam, 90., 215., 400.)
        call HealthBars__Place(Arm_Blindaje[p], cam, 230., 124., 400.)
        // v15a: el relleno ocupa el hueco de la barra (156,6 px desde x 151,7) según la sobrecarga, delante del marco.
        if pct * 2 + IntegerTertiaryOp(Sob_Bloq[p], 1, 0) != Sob_Visto[p] then
            set Sob_Visto[p] = pct * 2 + IntegerTertiaryOp(Sob_Bloq[p], 1, 0)
            set r = IMinBJ(255, pct * 51 / 10)
            set g = IMinBJ(255, (100 - pct) * 51 / 10)
            if GetLocalPlayer() == Player(p) then
                set a = 255
            endif
            call SetUnitVertexColor(Sob_Barra[p], r, g, 40, a)
            call Sob_Ancho(Sob_Barra[p], RMaxBJ(1., 1.566 * pct), 21.2)
            call SetTextTagColor(s__UIText_text[Sob_UI[p]], IMinBJ(255, r + 40), IMinBJ(255, g + 40), 80, 255)
            if Sob_Bloq[p] then
                set s = "Sobrecarga " + I2S(pct) + "%  bloqueada"
            else
                set s = "Sobrecarga " + I2S(pct) + "%"
            endif
            call Arm_Texto(Sob_UI[p], s, 0.015, 158.)
        endif
        if pct > 0 then
            call HealthBars__Place(Sob_Barra[p], cam, 151.7 + 0.783 * pct, 124., 385.)
        endif
        set clave = (c * 8 + Arm_Tier[i]) * 1000 + Sob_Kits[p]
        if Arm_Fin[p] > 0 then
            set clave = - 1 - R2I((Arm_Fin[p] - TimerGetElapsed(s__RapidPair_clock)) * 10.)
        endif
        if clave != Arm_Clave[p] then
            set Arm_Clave[p] = clave
            set w = Arm_W(p)
            call Arm_Texto(Arm_NombreUI[p], Arm_Nombre[w] + " T" + I2S(Arm_Tier[i]), 0.017, 192.)
            if Arm_Fin[p] > 0 then
                set s = "Refrescando " + R2SW(RMaxBJ(0., Arm_Fin[p] - TimerGetElapsed(s__RapidPair_clock)), 1, 1)
            else
                set s = "Kits de refresco (F): " + I2S(Sob_Kits[p])
            endif
            call Arm_Texto(Arm_BalasUI[p], s, 0.017, 222.)
        endif
    endif
endfunction
''')

s = once(s, "    call Arm_Foto(Arm_Blindaje[p], 165., 20., 'DS0E')\n", """    call Arm_Foto(Arm_Blindaje[p], 165., 20., 'DS0E')
    set Sob_Barra[p] = HealthBars__Dummy('uidb', p)
    call UnitAddAbility(Sob_Barra[p], s__Interface_LOCUST_ID)
    call UnitRemoveAbility(Sob_Barra[p], s__Interface_LOCUST_ID)
    call Arm_Foto(Sob_Barra[p], 156.6, 21.2, 'DS0F')
    set Sob_UI[p] = s__UIText_createEx(Player(p), 0., 0., 1.)
    call SetTextTagPermanent(s__UIText_text[Sob_UI[p]], true)
    set Sob_Visto[p] = - 1
""")

# Disparo: bloqueo por sobrecarga, ráfaga de 1,5 s, calor, sonido y bala del tier.
s = once(s, '''        return Arm_Cat[p] == 5 or Arm_Clip[p * 7 + Arm_Cat[p]] > 0
    endfunction
''', '''        return Arm_Cat[p] == 5 or not Sob_Bloq[p]
    endfunction

    // v15a: tiros de una ráfaga, 1,5 s al ritmo del arma.
    function Arm_Rafaga takes integer w returns integer
        return IMaxBJ(1, R2I(1.5 / Arm_Int[w] + 0.01))
    endfunction
''')
s = once(s, '''        set Arm_Alcance=range
        set m=s__RapidBolt_shootFamily(''', '''        set Arm_Alcance=range
        call Arm_Bala(w / 3 , ModuloInteger(w, 3) + 1)
        set m=s__RapidBolt_shootFamily(''')
s = once(s, '''        set Arm_Alcance=s__RapidBolt_RANGE
        set s__RapidPair_lastMissile[this]=m
''', '''        set Arm_Alcance=s__RapidBolt_RANGE
        set Arm_BalaModelo=""
        set s__RapidPair_lastMissile[this]=m
''')
s = once(s, '''        set Arm_Clip[p * 7 + c]=Arm_Clip[p * 7 + c] - 1
''', '''        set Sob_Valor[p]=Sob_Valor[p] + Arm_Calor[w]
        if Sob_Valor[p] >= 100. then
            set Sob_Valor[p]=100.
            set Sob_Bloq[p]=true
        endif
        call Arm_Sonido(c , x , y)
''')
s = once(s, '''        local integer m
        if distance < 8. then''', '''        local integer m
        local real r= s__RapidBolt_radiusFor(color , f)
        if Arm_BalaModelo != "" then
            set r=Arm_BalaRadio
        endif
        if distance < 8. then''')
s = once(s, 'call s__GroundCollision_trace(x , y , x + dx * 24. / distance , y + dy * 24. / distance , s__RapidBolt_radiusFor(color , f) , caster',
         'call s__GroundCollision_trace(x , y , x + dx * 24. / distance , y + dy * 24. / distance , r , caster')
s = once(s, '''        set s__RapidBolt_hitRadius[m]=s__RapidBolt_radiusFor(color , f)
        call s__Missile__set_model(m,s__RapidBolt_modelOf(color , f))
''', '''        set s__RapidBolt_hitRadius[m]=r
        if Arm_BalaModelo != "" then
            call s__Missile__set_model(m,Arm_BalaModelo)
        else
            call s__Missile__set_model(m,s__RapidBolt_modelOf(color , f))
        endif
''')
# Disparar cancela el refresco (antes no se podía disparar mientras se recargaba).
s = once(s, '''        call s__RapidPair_aimAt(this,px , py)
        if Arm_Fin[p] > 0. then
            return
        endif
''', '''        call s__RapidPair_aimAt(this,px , py)
        set Arm_Fin[p]=0.
''')
s = once(s, '''            set s__RapidPair_remaining=s__RapidPair_remaining + 6 - s__RapidPair_pending[this]
            set s__RapidPair_pending[this]=6
''', '''            set s__RapidPair_remaining=s__RapidPair_remaining + Arm_Rafaga(Arm_W(p)) - s__RapidPair_pending[this]
            set s__RapidPair_pending[this]=Arm_Rafaga(Arm_W(p))
''')
s = once(s, '''        set s__RapidPair_pending[this]=6
        set s__RapidPair_remaining=s__RapidPair_remaining + 6
''', '''        set s__RapidPair_pending[this]=Arm_Rafaga(Arm_W(p))
        set s__RapidPair_remaining=s__RapidPair_remaining + Arm_Rafaga(Arm_W(p))
''')

# Botones: las 4 armas desde el inicio, sin cuerpo a cuerpo; F (Aw08) es Refrescar sobrecarga.
s = once(s, '''            set Arm_Tier[p * 7]=1
            set Arm_Clip[p * 7]=Arm_Mag[0]
            set Arm_Rva[p * 7]=Arm_Res[0]
            set Arm_Tier[p * 7 + 5]=1
        endif
''', '''            set Arm_Tier[p * 7]=1
            set Arm_Tier[p * 7 + 1]=1
            set Arm_Tier[p * 7 + 2]=1
            set Arm_Tier[p * 7 + 3]=1
            set Sob_Kits[p]=Sob_KITS_INICIO()
        endif
''')
s = en(s, '    function Arm_Botones takes integer p returns nothing\n', '            exitwhen c > 6\n', '            exitwhen c > 3\n')
s = once(s, 'set s__RapidPair_family[Game_Pair[p]]=Arm_Familia(Arm_Tier[p * 7 + Arm_Cat[p]])',
         'set s__RapidPair_family[Game_Pair[p]]=Arm_Familia(Arm_Cat[p])')
s = once(s, 'set s__RapidPair_family[this]=Arm_Familia(Arm_Tier[p * 7 + c])', 'set s__RapidPair_family[this]=Arm_Familia(c)')
s = once(s, 'GetSpellTargetY() , Arm_Familia(Arm_Tier[p * 7 + Arm_Cat[p]]))', 'GetSpellTargetY() , Arm_Familia(Arm_Cat[p]))')
# Cambiar de arma ya no cancela: el refresco es de la barra, no del arma.
s = once(s, '''        set Arm_Fin[p]=0.
        set Arm_Cat[p]=c
''', '''        set Arm_Cat[p]=c
''')
s = cambiar(s, '    function Arm_BotonRecarga takes nothing returns nothing\n', '''    // v15a: Refrescar sobrecarga (F). El kit se gasta al terminar (Arm_Latido); cancelado, se conserva.
    function Arm_BotonRecarga takes nothing returns nothing
        local integer p= GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        if Sob_Kits[p] <= 0 or Sob_Valor[p] <= 0. then
            call Arm_Error(p)
        elseif Arm_Fin[p] <= 0. then
            if Game_Pair[p] != 0 then
                call s__RapidPair_finish(Game_Pair[p],true)
            endif
            set Arm_Fin[p]=(TimerGetElapsed(s__RapidPair_clock)) + Sob_TIEMPO()
        endif
    endfunction
''')
s = once(s, '''                set Arm_Fin[p]=0.
                set i=p * 7 + Arm_Cat[p]
                set n=IMinBJ(Arm_Mag[Arm_W(p)] - Arm_Clip[i], Arm_Rva[i])
                set Arm_Clip[i]=Arm_Clip[i] + n
                set Arm_Rva[i]=Arm_Rva[i] - n
''', '''                set Arm_Fin[p]=0.
                set Sob_Valor[p]=0.
                set Sob_Bloq[p]=false
                set Sob_Kits[p]=Sob_Kits[p] - 1
''')
s = once(s, '        call TimerStart(Arm_Reloj, 0.05, true, function Arm_Latido)\n',
         '        call TimerStart(Arm_Reloj, 0.05, true, function Arm_Latido)\n        call TimerStart(CreateTimer(), 0.10, true, function Sob_Paso)\n')
# Sin zonas de munición: no se encienden, así que tampoco se pintan ni se toman con ESC.
s = once(s, '    call Recarga_Ronda()\n', '    // v15a: sin zonas de munición (Recarga_Ronda).\n')

# Tienda provisional (la del prototipo llega en v15c): 4 categorías y los botones de sobrecarga.
s = en(s, 'function Shop_Textos takes nothing returns nothing\n', '        exitwhen i > 6\n', '        exitwhen i > 3\n')
s = once(s, 'call Shop_Tag(1140, 522, 0.017, 0, "Cargador")', 'call Shop_Tag(1140, 522, 0.017, 0, "Sobrecarga")')
s = once(s, '// Sólo en el cliente de quien abre la tienda: 38 texttags', '// Sólo en el cliente de quien abre la tienda: 35 texttags')
s = en(s, 'function Shop_Construir takes nothing returns nothing\n', '''        exitwhen i > 6
        call Shop_Pic(307, 161 + 66 * i''', '''        exitwhen i > 3
        call Shop_Pic(307, 161 + 66 * i''')
s = en(s, 'function Shop_Construir takes nothing returns nothing\n', '''                exitwhen i > 6
                call Shop_Pista(p, "war3mapImported\\\\ShopHitCat.mdx"''', '''                exitwhen i > 3
                call Shop_Pista(p, "war3mapImported\\\\ShopHitCat.mdx"''')
s = en(s, 'function Shop_Refrescar takes integer p returns nothing\n', '        exitwhen k > 6\n', '        exitwhen k > 3\n')
s = once(s, '''    if c == 5 then
        set s = "Sin balas"
    else
        set s = I2S(Arm_Mag[w]) + " / " + I2S(Arm_Res[w])
    endif
    call Shop_Izq(p, Shop_T[8], s, 1140, 548, 0.026)
''', '''    call Shop_Izq(p, Shop_T[8], R2SW(Arm_Calor[w], 1, 1) + " por disparo", 1140, 548, 0.022)
''')
s = once(s, '''    set s = "Munición completa"
    call Shop_Luz(p, Shop_RecOn, false)
    if c == 5 then
        set s = "No usa munición"
    elseif have == 0 then
        set s = "Compra el arma primero"
    else
        set x = c * 3 + have - 1
        set falta = Arm_Res[x] - Arm_Rva[i]
        if falta > 0 then
            set s = I2S(falta) + " balas: " + I2S(Shop_CostoBalas(x, falta)) + " oro"
            call Shop_Luz(p, Shop_RecOn, true)
        endif
    endif
''', '''    if Sob_Nivel[p] >= Sob_NIVELES() then
        set s = "Sobrecarga al máximo"
        call Shop_Luz(p, Shop_RecOn, false)
    else
        set x = Sob_Precio(Sob_Nivel[p] + 1)
        set s = "Mejorar sobrecarga " + I2S(Sob_Nivel[p] + 1) + "/" + I2S(Sob_NIVELES()) + ": " + I2S(x) + " oro"
        call Shop_Luz(p, Shop_RecOn, GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD) >= x)
    endif
''')
s = cambiar(s, 'function Shop_TodoTexto takes integer p returns nothing\n', '''// v15a: kits de Refrescar sobrecarga, en el lugar de «Abastecer todo».
function Shop_TodoTexto takes integer p returns nothing
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    local string s = "Kit de refresco: " + I2S(Sob_KIT()) + " oro  (" + I2S(Sob_Kits[p]) + "/" + I2S(Sob_KITS_MAX()) + ")"
    call Shop_Centro(p, Shop_T[20], s, 1601, 624, 0.021)
    call Shop_Luz(p, Shop_TodoOn, oro >= Sob_KIT() and Sob_Kits[p] < Sob_KITS_MAX())
endfunction
''')
s = once(s, 'function Shop_Clic takes nothing returns nothing\n', '''function Shop_Sobrecarga takes integer p returns nothing
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    local integer x = Sob_Precio(Sob_Nivel[p] + 1)
    if Sob_Nivel[p] >= Sob_NIVELES() or oro < x then
        call UI_Error(p)
        return
    endif
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - x)
    set Sob_Nivel[p] = Sob_Nivel[p] + 1
    call UI_Click(p)
    call Shop_Refrescar(p)
endfunction

function Shop_Kit takes integer p returns nothing
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    if oro < Sob_KIT() or Sob_Kits[p] >= Sob_KITS_MAX() then
        call UI_Error(p)
        return
    endif
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - Sob_KIT())
    set Sob_Kits[p] = Sob_Kits[p] + 1
    call UI_Click(p)
    call Shop_Refrescar(p)
endfunction

function Shop_Clic takes nothing returns nothing
''')
s = en(s, 'function Shop_Clic takes nothing returns nothing\n', '        call Shop_Balas(p)\n', '        call Shop_Sobrecarga(p)\n')
s = en(s, 'function Shop_Clic takes nothing returns nothing\n', '        call Shop_Todo(p)\n', '        call Shop_Kit(p)\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
