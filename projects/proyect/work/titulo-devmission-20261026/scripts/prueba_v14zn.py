#!/usr/bin/env python3
"""Sólo prueba, v14zn: las de prueba_v14zm.py con el registro en lat\\v14zn-N.txt, más:
- «-misil T»: elige el misil de calor con el tier T y el cargador lleno (como «-cuchillo T»).
- «-tiro D»: un disparo del arma activa hacia D al este del héroe (RapidPair_cast, como la orden de disparo); 5 s después
  se escribe en una línea lo que hizo cada misil: L lanzado, C pasó la cima, O tomó objetivo (a la distancia del misil
  en ese momento), P perdió el objetivo (murió), E explotó (dañados). Cada evento lleva el número del misil y el reloj
  en centésimas. Un registro por evento costaría ~170 ms cada uno: por eso se junta.
- «-lluvia N»: N misiles de golpe del tier activo en abanico (300 a 1000 del héroe), para medir el rendimiento con el
  tope de 24 en vuelo superado; 8 s después escribe la línea de eventos y el máximo de misiles vivos.
Uso: prueba_v14zn.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal = sys.argv[1:3]
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14zm.py')] + sys.argv[1:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
assert s.count('lat\\\\v14zm-') == 2
assert s.index('function Prueba_Log takes') < s.index('function Prueba_Chat takes')
s = s.replace('lat\\\\v14zm-', 'lat\\\\v14zn-')
s = base.once(s, 'integer Calor_Vivos= 0\n', 'integer Calor_Vivos= 0\nstring Prueba_Misil= ""\ninteger Prueba_MisilMax= 0\ninteger Prueba_Danados2= 0\n')


def ev(letra, extra=''):
    return '            set Prueba_Misil = Prueba_Misil + " %s" + I2S(m) + "@" + I2S(R2I(100. * TimerGetElapsed(s__RapidPair_clock)))%s\n' % (letra, extra)


s = base.once(s, '''            set Calor_Vivos=Calor_Vivos + 1
            call s__Missile__set_scale(m,Arm_Area[w] / 160.)
''', '''            set Calor_Vivos=Calor_Vivos + 1
            call s__Missile__set_scale(m,Arm_Area[w] / 160.)
''' + ev('L', ' + ":" + I2S(R2I(range))') + '''            set Prueba_MisilMax = IMaxBJ(Prueba_MisilMax, Calor_Vivos)
''')
s = base.once(s, '''            set s__Missile_target[m]=null
            set t=null
        endif
''', '''            set s__Missile_target[m]=null
            set t=null
''' + ev('P') + '''        endif
''')
s = base.once(s, '''            set Bala_Cima[m]=s__Missile_dist[m] * 2. >= s__MissilePosition_distance[s__Missile_origin[m]]
''', '''            set Bala_Cima[m]=s__Missile_dist[m] * 2. >= s__MissilePosition_distance[s__Missile_origin[m]]
            if Bala_Cima[m] then
''' + ev('C', ' + ":" + I2S(R2I(s__Missile_z[m]))') + '''            endif
''')
s = base.once(s, '''            if mejor != null then
                set s__Missile_target[m]=mejor
''', '''            if mejor != null then
                set s__Missile_target[m]=mejor
''' + ev('O', ' + ":" + I2S(R2I(SquareRoot(dm)))'))
# Dañados por la explosión de cada misil (Arm_Explotar corre antes de RapidBolt_onRemove).
s = base.once(s, '''                if s__GroundCollision_isTarget(u , caster , owner) and s__GroundCollision_touches(u , x , y , area) then
                    call UnitDamageTarget(caster, u, Bala_Dano[m], false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)
''', '''                if s__GroundCollision_isTarget(u , caster , owner) and s__GroundCollision_touches(u , x , y , area) then
                    set Prueba_Danados2 = Prueba_Danados2 + 1
                    call UnitDamageTarget(caster, u, Bala_Dano[m], false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)
''')
s = base.once(s, '''            set s__GroundCollision_shaped=false
        endif
        set owner=null
    endfunction
''', '''            set s__GroundCollision_shaped=false
        endif
        if Bala_Calor[m] then
''' + ev('E', ' + ":" + I2S(Prueba_Danados2)').replace('            ', '        ', 1) + '''        endif
        set Prueba_Danados2 = 0
        set owner=null
    endfunction
''')
s = base.once(s, '''    elseif m == "-llamar" then
''', '''    elseif SubString(m, 0, 7) == "-misil " then
        set c = IMinBJ(6, IMaxBJ(1, S2I(SubString(m, 7, StringLength(m)))))
        if Arm_Tier[p * 7] == 0 then
            call UnitAddAbility(Game_Ctrl[p], 'Aw00')
        endif
        set Arm_Tier[p * 7] = c
        set Arm_Clip[p * 7] = Arm_Mag[c - 1]
        set Arm_Rva[p * 7] = Arm_Res[c - 1]
        call SetUnitAbilityLevel(Game_Ctrl[p], 'Aw00', c)
        call Arm_Elegir(p, 0)
        call Arm_Pareja(p)
    elseif SubString(m, 0, 6) == "-tiro " then
        set Prueba_Misil = ""
        set Prueba_MisilMax = 0
        call s__RapidPair_cast(Game_Pair[p], GetUnitX(Game_Hero[p]) + S2R(SubString(m, 6, StringLength(m))), GetUnitY(Game_Hero[p]))
        call TimerStart(CreateTimer(), 5., false, function Prueba_MisilLog)
    elseif SubString(m, 0, 8) == "-lluvia " then
        set Prueba_Misil = ""
        set Prueba_MisilMax = 0
        set c = S2I(SubString(m, 8, StringLength(m)))
        loop
            exitwhen c <= 0
            call Arm_Tiro(Game_Pair[p], Arm_W(p), GetRandomReal(- 0.6, 0.6), GetRandomReal(300., 1000.))
            set c = c - 1
        endloop
        call TimerStart(CreateTimer(), 8., false, function Prueba_MisilLog)
    elseif m == "-llamar" then
''')
s = base.once(s, 'function Prueba_Chat takes nothing returns nothing\n', '''function Prueba_MisilLog takes nothing returns nothing
    local string s= "misil max " + I2S(Prueba_MisilMax) + " vivos " + I2S(Calor_Vivos) + " w " + I2S(Arm_W(0)) + " |" + Prueba_Misil
    call DestroyTimer(GetExpiredTimer())
    // Preload corta cada línea hacia los 259 caracteres: varias líneas de 240 en un mismo archivo.
    set Prueba_N = Prueba_N + 1
    call PreloadGenClear()
    loop
        exitwhen StringLength(s) == 0
        call Preload(SubString(s, 0, 240))
        set s = SubString(s, 240, StringLength(s))
    endloop
    call PreloadGenEnd("lat\\\\v14zn-" + I2S(Prueba_N) + ".txt")
endfunction
function Prueba_Chat takes nothing returns nothing
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
