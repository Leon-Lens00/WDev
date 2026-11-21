#!/usr/bin/env python3
r"""v14o: bala por categoría con el color del tier, granada en arco y ajustes de armas (05/11/2026), sobre v14n.

Pedidos de Leon:
- Bala por categoría; el tier sólo cambia el color (T1 Yellow, T2 Green, T3 Cyan, los tres primeros de la paleta de tiers
  de TerrainDev/assets/balas-colores): Pistola Shot, Subfusil Shot II, Rifle y Francotirador la Daemonic Arrow ajustada
  (Vinz y Daemonic Sword, Hive 337124), Escopeta Firebrand (Teal para el Cyan) y Explosivos la Chain Grenade de Vinz
  (Hive 315385; Yellow y Cyan teñidas en TerrainDev/scripts/chain_grenade_colores.cjs). El Windwalk y el dash siguen
  con el color del jugador.
- Explosivos: la granada va en arco al punto del lanzamiento (hasta su alcance) y sólo daña al caer; ya no choca con
  enemigos ni paredes por el camino. La explosión es la animación Death de la granada.
- Ráfaga medida en tiempo: 1,5 s al ritmo del arma (Arm_Rafaga, como en v15a). Antes eran 6 tiros fijos.
- Rifle: cada tiro de una ráfaga sostenida abre 0,8° más la dispersión (hasta 12° extra), aunque se relance; vuelve a
  la del arma al dejar de disparar (fin de ráfaga, recarga) o con el dash.
- Francotirador: un tiro cada 0,50 s (3 por ráfaga como máximo), más daño (240/320/450) y atraviesa 2/3/4 enemigos.
- Subfusil: animación de ataque al ritmo del arma (1 / intervalo, antes 4) y 2° más de dispersión.
- Pistola: más tiros por ráfaga, 7/8/9 (intervalo 0,2143/0,1875/0,1667).
El reciclador de dummies (MissileRecycler) ya estaba activo en v14n: no cambia.
Uso: v14o.py ENTRADA.j SALIDA.j
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
    c = cabeza.replace('\n', N)
    assert s.count(c) == 1, cabeza
    a = s.index(c)
    b = s.index(N + ('    ' if cabeza.startswith('    ') else '') + 'endfunction', a)
    return a, s.index(N, b + 2) + 2


def en(s, cabeza, old, new):
    """once dentro de una sola función."""
    a, b = funcion(s, cabeza)
    return s[:a] + once(s[a:b], old, new) + s[b:]


def dato(s, campo, i, valor):
    old = f'    set Arm_{campo}[{i}] = '
    assert s.count(old) == 1, (campo, i)
    a = s.index(old) + len(old)
    return s[:a] + valor + s[s.index(N, a):]


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')

# Datos.
for i, v in ((0, '0.2143'), (1, '0.1875'), (2, '0.1667')):
    s = dato(s, 'Int', i, v)
for i, v in ((3, '8.'), (4, '5.'), (5, '5.')):
    s = dato(s, 'Disp', i, v)
for i, d, p in ((9, '240.', '2'), (10, '320.', '3'), (11, '450.', '4')):
    s = dato(s, 'Int', i, '0.5000')
    s = dato(s, 'Dano', i, d)
    s = dato(s, 'Perfora', i, p)

s = once(s, 'real Arm_Alcance= 1350.\n', '''real Arm_Alcance= 1350.
string Arm_BalaModelo= ""
real Arm_BalaRadio= 0.
real Arm_BalaZ= 70.
real Arm_BalaArco= 0.
real Arm_BalaVel= 1200.
real array Arm_Desvio
''')

s = once(s, 'function Arm_Error takes integer p returns nothing\n', r'''// v14o: color del tier t para los nombres de los modelos; Firebrand tiene Teal para el Cyan.
function Arm_ColorTier takes integer t, boolean teal returns string
    if t == 1 then
        return "Yellow"
    elseif t == 2 then
        return "Green"
    elseif teal then
        return "Teal"
    endif
    return "Cyan"
endfunction

// v14o: modelo, radio y vuelo de la bala de la categoría c en el tier t (radios de RapidBolt_radiusFor).
function Arm_Bala takes integer c, integer t returns nothing
    set Arm_BalaZ = s__RapidBolt_HEIGHT
    set Arm_BalaArco = 0.
    set Arm_BalaVel = 1200.
    if c == 0 then
        set Arm_BalaModelo = "ShotsAjustados\\Shot " + Arm_ColorTier(t, false) + ".mdx"
        set Arm_BalaRadio = 6. * s__RapidBolt_SHOTS_SCALE
    elseif c == 1 then
        set Arm_BalaModelo = "ShotsAjustados\\Shot II " + Arm_ColorTier(t, false) + ".mdx"
        set Arm_BalaRadio = 18. * s__RapidBolt_SHOTS_II_SCALE
        if t == 2 then
            set Arm_BalaRadio = 16.2 * s__RapidBolt_SHOTS_II_SCALE
        endif
    elseif c == 2 or c == 3 then
        // Daemonic Arrow movida en X (TerrainDev/scripts/daemonic_ajustada.cjs): la cabeza queda en +15.
        set Arm_BalaModelo = "DaemonicArrow\\Daemonic Arrow " + Arm_ColorTier(t, false) + ".mdx"
        set Arm_BalaRadio = 15.
    elseif c == 4 then
        set Arm_BalaModelo = "FirebrandShots\\Firebrand Shot " + Arm_ColorTier(t, true) + ".mdx"
        set Arm_BalaRadio = s__RapidBolt_HIT_RADIUS
    else
        // Granada: arco hasta el suelo del punto de caída; no choca por el camino (RapidBolt_resolve).
        set Arm_BalaModelo = "ChainGrenade\\Chain Grenade " + Arm_ColorTier(t, false) + ".mdx"
        set Arm_BalaRadio = 10.
        set Arm_BalaZ = 15.
        set Arm_BalaArco = 0.85
        set Arm_BalaVel = 900.
    endif
endfunction

function Arm_Error takes integer p returns nothing
''')

# Bala: modelo, radio, altura final, arco y velocidad de Arm_Bala.
s = once(s, '''        local integer m
        if distance < 8. then''', '''        local integer m
        local real r= s__RapidBolt_radiusFor(color , f)
        if Arm_BalaModelo != "" then
            set r=Arm_BalaRadio
        endif
        if distance < 8. then''')
s = once(s, 'call s__GroundCollision_trace(x , y , x + dx * 24. / distance , y + dy * 24. / distance , s__RapidBolt_radiusFor(color , f) , caster',
         'call s__GroundCollision_trace(x , y , x + dx * 24. / distance , y + dy * 24. / distance , r , caster')
s = once(s, 'set m=s__Missile_createXYZ(s__GroundCollision_x , s__GroundCollision_y , s__RapidBolt_HEIGHT , px , py , s__RapidBolt_HEIGHT)',
         'set m=s__Missile_createXYZ(s__GroundCollision_x , s__GroundCollision_y , s__RapidBolt_HEIGHT , px , py , Arm_BalaZ)')
s = once(s, '''        set s__RapidBolt_hitRadius[m]=s__RapidBolt_radiusFor(color , f)
        call s__Missile__set_model(m,s__RapidBolt_modelOf(color , f))
        call s__Missile__set_scale(m,s__RapidBolt_scaleOf(f))
        set s__Missile_speed[(m)]=((1200.)*1.0) * Missile_TIMER_TIMEOUT // INLINED!!
''', '''        set s__RapidBolt_hitRadius[m]=r
        if Arm_BalaModelo != "" then
            call s__Missile__set_model(m,Arm_BalaModelo)
        else
            call s__Missile__set_model(m,s__RapidBolt_modelOf(color , f))
        endif
        call s__Missile__set_scale(m,s__RapidBolt_scaleOf(f))
        if Arm_BalaArco > 0. then
            call s__Missile__set_arc(m,Arm_BalaArco)
        endif
        set s__Missile_speed[(m)]=Arm_BalaVel * Missile_TIMER_TIMEOUT
''')
s = once(s, '''        set Arm_Alcance=range
        set m=s__RapidBolt_shootFamily(''', '''        set Arm_Alcance=range
        call Arm_Bala(w / 3 , ModuloInteger(w, 3) + 1)
        set m=s__RapidBolt_shootFamily(''')
s = once(s, '''        set Arm_Alcance=s__RapidBolt_RANGE
        set s__RapidPair_lastMissile[this]=m
''', '''        set Arm_Alcance=s__RapidBolt_RANGE
        set Arm_BalaModelo=""
        set Arm_BalaZ=s__RapidBolt_HEIGHT
        set Arm_BalaArco=0.
        set Arm_BalaVel=1200.
        set s__RapidPair_lastMissile[this]=m
''')

# La granada no choca: sólo explota al llegar (onFinish).
s = once(s, '''        local unit caster= s__RapidBolt_source[m]
        loop
            set result=s__RapidBolt_sweep(m)''', '''        local unit caster= s__RapidBolt_source[m]
        if Bala_Area[m] > 0. then
            set caster=null
            return false
        endif
        loop
            set result=s__RapidBolt_sweep(m)''')
s = en(s, '    function Arm_Explotar takes integer m,unit caster,real x,real y returns nothing\n',
       '        call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Other\\\\Incinerate\\\\FireLordDeathExplode.mdl", x, y))\n',
       '        // v14o: la explosión es la animación Death de la granada.\n')

# Ráfaga de 1,5 s y escala de animación (subfusil al ritmo del arma).
s = once(s, '''    // Sin balas no se espera el intervalo entero: el error llega enseguida.
''', '''    // v14o: tiros de una ráfaga, 1,5 s al ritmo del arma.
    function Arm_Rafaga takes integer w returns integer
        return IMaxBJ(1, R2I(1.5 / Arm_Int[w] + 0.01))
    endfunction

    // v14o: el subfusil repite la animación de ataque a su ritmo; las demás armas, a 4 como antes.
    function Arm_Escala takes integer w returns real
        if w / 3 == 1 then
            return 1. / Arm_Int[w]
        endif
        return 4.
    endfunction

    // Sin balas no se espera el intervalo entero: el error llega enseguida.
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
s = en(s, '    function s__RapidPair_cast takes integer this,real px,real py returns nothing\n',
       '        call SetUnitTimeScale(s__RapidPair_actor[this], 4.)\n',
       '        call SetUnitTimeScale(s__RapidPair_actor[this], Arm_Escala(Arm_W(p)))\n')
s = en(s, '    function Arm_Elegir takes integer p,integer c returns nothing\n', '''                call s__RapidPair_showWalk(this)
''', '''                call s__RapidPair_showWalk(this)
                call SetUnitTimeScale(s__RapidPair_actor[this], Arm_Escala(Arm_W(p)))
''')

# Dispersión: el rifle la abre con cada tiro; la granada apunta al punto exacto.
s = en(s, '    function Arm_Emitir takes integer this returns nothing\n', '''        local real range= Arm_Alc[w]
''', '''        local real range= Arm_Alc[w]
        local real disp= Arm_Disp[w]
''')
s = en(s, '    function Arm_Emitir takes integer this returns nothing\n', '''            set range=RMaxBJ(150., RMinBJ(range, SquareRoot(x * x + y * y)))
        endif
''', '''            set range=RMaxBJ(150., RMinBJ(range, SquareRoot(x * x + y * y)))
            if x * x + y * y > 64. then
                set angle=Atan2(y, x)
            endif
        elseif c == 2 then
            set disp=disp + Arm_Desvio[p]
            set Arm_Desvio[p]=RMinBJ(Arm_Desvio[p] + 0.8, 12.)
        endif
''')
s = en(s, '    function Arm_Emitir takes integer this returns nothing\n',
       'GetRandomReal(- Arm_Disp[w], Arm_Disp[w])', 'GetRandomReal(- disp, disp)')
s = en(s, '    function s__RapidPair_finish takes integer this,boolean resume returns nothing\n', '''                call ResetUnitAnimation(s__RapidPair_actor[this])
''', '''                call ResetUnitAnimation(s__RapidPair_actor[this])
                // v14o: dejar de disparar (o el dash, que pasa por aquí) cierra la dispersión del rifle.
                set Arm_Desvio[GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))]=0.
''')

assert '\n' not in s.replace(N, '')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
