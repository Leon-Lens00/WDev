#!/usr/bin/env python3
"""v14zm (07/11/2026): fase 4 de docs/planes/devmission-armas-rachas-v14zj.md (cuchillo nuevo). Parte del j de v14zl.

- Golpes alternos por jugador (Cuch_N): A por delante y B en área. Con el intervalo de v14zj (1,5 / (4 + 2 (t − 1)))
  salen 2 A + 2 B por 1,5 s en T1 y dos golpes más por tier (14 en T6). El daño por golpe sigue en Arm_Dano.
- A: cono con semiángulo 60° + 8° × (t − 1) (60° en T1, 100° en T6) y alcance Arm_Area. B: círculo completo de radio
  Arm_Area alrededor del héroe.
- Cada golpe pone su efecto en una unidad ficticia (objetos_v14zm.py) mirando hacia donde apunta el héroe:
  'hkA0' + t (Culling Cleave del color del tier) o 'hkB0' + t (Culling Slash). Escala Arm_Area / 150 (Cleave) y
  Arm_Area / 180 (Slash): a escala 1 su alcance visible medio (ponderado por alfa) es 153 y 172; la parte más
  brillante es la del principio, más pequeña, y con 190/215 se veían a la mitad del área en el juego. El modelo sólo se ve en sus primeros 0,3 s: se acelera
  (SetUnitTimeScale) por encima de 1 sólo cuando el mismo golpe se repite antes (T5 y T6), y la unidad se quita
  pasados 0,35 s / escala.
- La animación de ataque del héroe va al ritmo de los golpes: escala de tiempo 1,4 / intervalo (el Attack del Tauren
  y de Cairne dura 1,33 a 1,47 s).

Uso: v14zm.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def u8(t):
    return t.encode('utf-8').decode('latin-1')


ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')

s = once(s, 'integer DevWave_EliteE= 0\n', '''integer DevWave_EliteE= 0
integer array Cuch_N
hashtable Cuch_HT= InitHashtable()
''')

s = once(s, '''    function Arm_Escala takes integer w returns real
        if w / 6 == 1 then
            return 1. / Arm_Int[w]
        endif
''', u8('''    function Arm_Escala takes integer w returns real
        if w / 6 == 1 then
            return 1. / Arm_Int[w]
        elseif w / 6 == 5 then
            // v14zm: un ataque (1,33 a 1,47 s) por golpe del cuchillo.
            return 1.4 / Arm_Int[w]
        endif
'''))

s = once(s, '    function Arm_Golpe takes integer this,integer w returns nothing\n', u8('''    // v14zm: quita la unidad del efecto del cuchillo.
    function Cuch_Quitar takes nothing returns nothing
        local timer t= GetExpiredTimer()
        local integer h= GetHandleId(t)
        call RemoveUnit(LoadUnitHandle(Cuch_HT, h, 0))
        call FlushChildHashtable(Cuch_HT, h)
        call DestroyTimer(t)
        set t=null
    endfunction

    // v14zm: efecto del golpe (A: Culling Cleave; B: Culling Slash) del tier t en una unidad ficticia que mira a angle.
    function Cuch_Efecto takes real x,real y,real angle,integer w,boolean b returns nothing
        local integer t= ModuloInteger(w, 6) + 1
        local real k= RMaxBJ(1., 0.15 / Arm_Int[w])
        local real e= Arm_Area[w] / 150.
        local unit u
        local timer r= CreateTimer()
        if b then
            set u=CreateUnit(Player(15), 'hkB0' + t, x, y, angle * bj_RADTODEG)
            set e=Arm_Area[w] / 180.
        else
            set u=CreateUnit(Player(15), 'hkA0' + t, x, y, angle * bj_RADTODEG)
        endif
        call SetUnitScale(u, e, e, e)
        call SetUnitTimeScale(u, k)
        call SaveUnitHandle(Cuch_HT, GetHandleId(r), 0, u)
        call TimerStart(r, 0.35 / k, false, function Cuch_Quitar)
        set u=null
        set r=null
    endfunction

    function Arm_Golpe takes integer this,integer w returns nothing
'''))
s = once(s, '''        local real angle= Atan2(s__RapidPair_aimY[this] - y, s__RapidPair_aimX[this] - x)
        local real d
        local unit u
        set s__GroundCollision_shaped=true
        call GroupEnumUnitsInRange(Arm_Enum, x, y, Arm_Area[w] + 128., null)
''', u8('''        local real angle= Atan2(s__RapidPair_aimY[this] - y, s__RapidPair_aimX[this] - x)
        local real d
        local unit u
        local integer p= GetPlayerId(owner)
        local boolean b= ModuloInteger(Cuch_N[p], 2) == 1
        local real lim= Cos(( 60. + 8. * ModuloInteger(w, 6) ) * bj_DEGTORAD)
        set Cuch_N[p]=Cuch_N[p] + 1
        call Cuch_Efecto(x , y , angle , w , b)
        set s__GroundCollision_shaped=true
        call GroupEnumUnitsInRange(Arm_Enum, x, y, Arm_Area[w] + 128., null)
'''))
s = once(s, '''                set d=Atan2(GetUnitY(u) - y, GetUnitX(u) - x) - angle
                if Cos(d) >= 0.5 then
''', '''                set d=Atan2(GetUnitY(u) - y, GetUnitX(u) - x) - angle
                if b or Cos(d) >= lim then
''')
pre = ''.join('    call Preload("war3mapImported\\\\Culling%s%d.mdx")\n' % (n, t) for n in ('Cleave', 'Slash') for t in range(1, 7))
s = once(s, '    call Preload("war3mapImported\\\\ConoCuchillo.mdx")\n    call Preload("war3mapImported\\\\DangerousCircle.mdx")\n',
         '    call Preload("war3mapImported\\\\ConoCuchillo.mdx")\n' + pre + '    call Preload("war3mapImported\\\\DangerousCircle.mdx")\n')
assert s.index('function Cuch_Efecto takes') < s.index('function Arm_Golpe takes')
Path(sal).write_text(s, encoding='latin-1', newline='')
