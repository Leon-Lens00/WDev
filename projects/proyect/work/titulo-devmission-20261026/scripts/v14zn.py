#!/usr/bin/env python3
"""v14zn (07/11/2026): fase 5 de docs/planes/devmission-armas-rachas-v14zj.md (misil de calor). Parte del j de v14zm.

- La categoría 0 (antes pistolas, oculta desde v14zj) pasa a ser «Misiles», en la última fila de la tienda
  (Shop_CatFila 6) y en el botón C (Aw00, objetos_v14zn.py). No se da al empezar: se compra.
- Datos (tabla de precios aprobada): daño 114 / 171 / 251 / 342 / 456 / 593 en área 180 / 200 / 220 / 240 / 260 / 280;
  precio 250 / 600 / 1200 / 2200 / 3600 / 5500; 1 misil cada 0,8 s, cargador 4, recarga 2,5 s. Elección del agente:
  alcance 1100, velocidad 1200, reserva 16 + 4 (t − 1), radio de búsqueda 350 igual en todos los tiers.
- Vuelo: Interceptor Shell (Vinz) del color del tier, sin luz (efectos_v14zn.cjs), escala Arm_Area / 160 (la
  explosión del modelo mide unos 150 de radio a escala 1). Cae en el punto elegido como la granada (150 a 1100) con un
  arco de 1,1 rad: la altura es tan(1,1) × d / 4 ≈ 0,49 × d, así que crece con la distancia. No choca por el camino.
- Búsqueda (Calor_Guiar, cada 1/32 s): pasada la cima del arco, si no persigue a nadie, toma al enemigo vivo más
  cercano a 350 o menos (el mismo filtro que la explosión) y lo persigue con la guía de la biblioteca Missile (vuela
  recto hacia él y pierde el arco). Si el objetivo muere, sigue hacia donde estaba y puede tomar otro por el camino.
  Explota al llegar (al objetivo o al suelo del punto) con Arm_Explotar y la animación Death del modelo.
- Tope: 24 misiles en vuelo entre todos los jugadores (Calor_Vivos); con el tope lleno, el arma da el error de sin
  balas hasta que explote alguno.

Uso: v14zn.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def u8(t):
    return t.encode('utf-8').decode('latin-1')


ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')

from v14zn_datos import MISILES, DANO, AREA, PRECIO, ALC, VEL, rasgo

i = s.index('function Arm_Datos takes nothing returns nothing')
e = s.index('endfunction', i)
b = s[i:e]


def poner(b, campo, w, valor):
    pat = re.compile(r'(    set %s\[%d\] = )[^\r\n]*' % (campo, w))
    b, n = pat.subn(lambda m: m.group(1) + valor, b)
    assert n == 1, (campo, w, n)
    return b


b = poner(b, 'Cat_Nombre', 0, '"Misiles"')
b = poner(b, 'Cat_Tex', 0, "'DS17'")
for t, (nombre, anio, coment) in enumerate(MISILES):
    datos = {'Arm_Nombre': '"%s"' % nombre,
             'Arm_Rasgo': u8('"%s"' % rasgo(t)),
             'Arm_Coment': u8('"%s"' % coment), 'Arm_Anio': str(anio), 'Arm_Mag': '4', 'Arm_Res': str(16 + 4 * t),
             'Arm_Perd': '1', 'Arm_Precio': str(PRECIO[t]), 'Arm_Perfora': '0', 'Arm_Int': '0.8',
             'Arm_Dano': '%d.' % DANO[t], 'Arm_Disp': '0.', 'Arm_Rec': '2.5', 'Arm_Crit': '0',
             'Arm_Area': '%d.' % AREA[t], 'Arm_Alc': '%d.' % ALC, 'Arm_Vel': '%d.' % VEL, 'Arm_Tipo': '6'}
    for campo, valor in datos.items():
        b = poner(b, campo, t, valor)
s = s[:i] + b + s[e:]

s = once(s, 'hashtable Cuch_HT= InitHashtable()\n', '''hashtable Cuch_HT= InitHashtable()
boolean array Bala_Calor
boolean array Bala_Cima
integer Calor_Vivos= 0
''')

# Tienda: la categoría 0 vuelve, en la última fila.
s = once(s, '''function Shop_CatFila takes integer k returns integer
    if k == 0 then
        return - 1
    endif
''', '''function Shop_CatFila takes integer k returns integer
    if k == 0 then
        return 6
    endif
''')

# Modelo y arco del misil.
s = once(s, '''    if c == 0 then
        set Arm_BalaModelo = "ShotsAjustados\\\\Shot " + Arm_ColorTier(t, false) + ".mdx"
        set Arm_BalaRadio = 6. * s__RapidBolt_SHOTS_SCALE
    elseif c == 1 then''', u8('''    if c == 0 then
        // v14zn: misil de calor (Interceptor Shell sin luz, color del tier); arco alto hasta el punto de caída.
        set Arm_BalaModelo = "war3mapImported\\\\InterceptorShell" + I2S(t) + ".mdx"
        set Arm_BalaRadio = 10.
        set Arm_BalaZ = 15.
        set Arm_BalaArco = 1.1
    elseif c == 1 then'''))

# Tope de misiles en vuelo.
s = once(s, '''        return Arm_Cat[p] == 5 or Arm_Clip[p * 7 + Arm_Cat[p]] > 0
''', '''        return Arm_Cat[p] == 5 or ( Arm_Clip[p * 7 + Arm_Cat[p]] > 0 and ( Arm_Cat[p] != 0 or Calor_Vivos < 24 ) )
''')

# Cae en el punto elegido, como la granada.
s = once(s, '''        if c == 6 then
            set x=s__RapidPair_pickX[this] - x
''', '''        if c == 6 or c == 0 then
            set x=s__RapidPair_pickX[this] - x
''')

s = once(s, '''        if Arm_Perfora[w] > 0 then
            set Bala_Grupo[m]=CreateGroup()
        endif
        set a=null
    endfunction
''', '''        if Arm_Perfora[w] > 0 then
            set Bala_Grupo[m]=CreateGroup()
        endif
        if w / 6 == 0 then
            set Bala_Calor[m]=true
            set Bala_Cima[m]=false
            set Calor_Vivos=Calor_Vivos + 1
            call s__Missile__set_scale(m,Arm_Area[w] / 160.)
        endif
        set a=null
    endfunction
''')

# Búsqueda y persecución, antes de RapidBolt_resolve.
s = once(s, '    function s__RapidBolt_resolve takes integer m returns boolean\n', u8('''    // v14zn: guía del misil de calor (ver v14zn.py). Corre en cada paso de RapidBolt_resolve.
    function Calor_Guiar takes integer m returns nothing
        local unit t= s__Missile_target[m]
        local unit u
        local unit mejor= null
        local real dm= 350. * 350.
        local real d
        local real x= s__Missile_x[m]
        local real y= s__Missile_y[m]
        if t != null and not s__GroundCollision_alive(t) then
            // Sigue hacia donde estaba (la biblioteca conserva ese punto de llegada).
            set s__Missile_target[m]=null
            set t=null
        endif
        if not Bala_Cima[m] then
            set Bala_Cima[m]=s__Missile_dist[m] * 2. >= s__MissilePosition_distance[s__Missile_origin[m]]
        endif
        if t == null and Bala_Cima[m] then
            call GroupEnumUnitsInRange(Arm_Enum, x, y, 350., null)
            loop
                set u=FirstOfGroup(Arm_Enum)
                exitwhen u == null
                call GroupRemoveUnit(Arm_Enum, u)
                if s__GroundCollision_isTarget(u , s__RapidBolt_source[m] , s__RapidBolt_owner[m]) then
                    set d=( GetUnitX(u) - x ) * ( GetUnitX(u) - x ) + ( GetUnitY(u) - y ) * ( GetUnitY(u) - y )
                    if d < dm then
                        set dm=d
                        set mejor=u
                    endif
                endif
            endloop
            if mejor != null then
                set s__Missile_target[m]=mejor
            endif
        endif
        set t=null
        set mejor=null
    endfunction

    function s__RapidBolt_resolve takes integer m returns boolean
'''))
s = once(s, '''        local unit caster= s__RapidBolt_source[m]
        if Bala_Area[m] > 0. then
            set caster=null
            return false
        endif
''', '''        local unit caster= s__RapidBolt_source[m]
        if Bala_Area[m] > 0. then
            if Bala_Calor[m] then
                call Calor_Guiar(m)
            endif
            set caster=null
            return false
        endif
''')
s = once(s, '''        set Bala_Perfora[m]=0
        set Bala_Area[m]=0.
        set s__RapidBolt_source[m]=null
''', '''        set Bala_Perfora[m]=0
        set Bala_Area[m]=0.
        if Bala_Calor[m] then
            set Bala_Calor[m]=false
            set Calor_Vivos=Calor_Vivos - 1
        endif
        set s__RapidBolt_source[m]=null
''')
pre = ''.join('    call Preload("war3mapImported\\\\InterceptorShell%d.mdx")\n' % t for t in range(1, 7))
s = once(s, '    call Preload("war3mapImported\\\\ConoCuchillo.mdx")\n', '    call Preload("war3mapImported\\\\ConoCuchillo.mdx")\n' + pre)
assert s.index('function Calor_Guiar takes') < s.index('function s__RapidBolt_resolve takes')
Path(sal).write_text(s, encoding='latin-1', newline='')
