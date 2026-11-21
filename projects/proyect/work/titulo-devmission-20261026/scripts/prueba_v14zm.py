#!/usr/bin/env python3
"""Sólo prueba, v14zm: las de prueba_v14zl.py con el registro en lat\\v14zm-N.txt, más:
- «-cuchillo T»: elige el cuchillo y le pone el tier T (como «-tier»).
- «-ataque»: una ráfaga del arma activa hacia 300 al este del héroe (RapidPair_cast, como la orden de disparo).
- cada golpe del cuchillo apunta en Prueba_Golpes «A|B tier reloj dañados» y 2 s después de «-ataque» se escribe una
  línea con todos (un registro por golpe costaría ~170 ms cada uno y movería el ritmo).
Uso: prueba_v14zm.py ENTRADA.j SALIDA.j MODO [VARIANTE]
"""
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ent, sal = sys.argv[1:3]
aqui = Path(__file__).resolve().parent
subprocess.run([sys.executable, '-I', str(aqui / 'prueba_v14zl.py')] + sys.argv[1:], check=True)
s = Path(sal).read_text(encoding='latin-1', newline='')
assert s.count('lat\\\\v14zl-') == 2
s = s.replace('lat\\\\v14zl-', 'lat\\\\v14zm-')
s = base.once(s, 'integer array Cuch_N\n', 'integer array Cuch_N\nstring Prueba_Golpes= ""\ninteger Prueba_Danados= 0\n')
s = base.once(s, '''                if b or Cos(d) >= lim then
                    call UnitDamageTarget(a, u, Arm_Dano[w], false, false, Dano_Ataque(Arm_Tipo[w]), Dano_TipoArma, null)
''', '''                if b or Cos(d) >= lim then
                    set Prueba_Danados = Prueba_Danados + 1
                    call UnitDamageTarget(a, u, Arm_Dano[w], false, false, Dano_Ataque(Arm_Tipo[w]), Dano_TipoArma, null)
''')
# Al final de Arm_Golpe (después del bucle de daño, antes de Arm_Emitir) se apunta el golpe.
s = base.once(s, '''        set s__GroundCollision_shaped=false
        set a=null
        set owner=null
    endfunction

    function Arm_Emitir takes integer this returns nothing
''', '''        if b then
            set Prueba_Golpes = Prueba_Golpes + " B"
        else
            set Prueba_Golpes = Prueba_Golpes + " A"
        endif
        set Prueba_Golpes = Prueba_Golpes + I2S(ModuloInteger(w, 6) + 1) + "@" + I2S(R2I(100. * TimerGetElapsed(s__RapidPair_clock))) + ":" + I2S(Prueba_Danados)
        set Prueba_Danados = 0
        set s__GroundCollision_shaped=false
        set a=null
        set owner=null
    endfunction

    function Arm_Emitir takes integer this returns nothing
''')
s = base.once(s, '''    elseif m == "-llamar" then
''', '''    elseif SubString(m, 0, 10) == "-cuchillo " then
        set c = IMinBJ(6, IMaxBJ(1, S2I(SubString(m, 10, StringLength(m)))))
        call Arm_Elegir(p, 5)
        set Arm_Tier[p * 7 + 5] = c
        call SetUnitAbilityLevel(Game_Ctrl[p], 'Aw05', c)
        call Arm_Pareja(p)
    elseif m == "-ataque" then
        set Prueba_Golpes = ""
        call s__RapidPair_cast(Game_Pair[p], GetUnitX(Game_Hero[p]) + 300., GetUnitY(Game_Hero[p]))
        call TimerStart(CreateTimer(), 2., false, function Prueba_GolpesLog)
    elseif m == "-llamar" then
''')
s = base.once(s, 'function Prueba_Chat takes nothing returns nothing\n', '''function Prueba_GolpesLog takes nothing returns nothing
    call DestroyTimer(GetExpiredTimer())
    call Prueba_Log("golpes" + Prueba_Golpes + " escala " + R2S(Arm_Escala(Arm_W(0))) + " int " + R2S(Arm_Int[Arm_W(0)]))
endfunction
function Prueba_Chat takes nothing returns nothing
''')
Path(sal).write_text(s, encoding='latin-1', newline='')
