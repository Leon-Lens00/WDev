#!/usr/bin/env python3
"""v14za: luz radial en el héroe, tarde más oscura y otra vez todo el campo de juego visible. Parte del j de v14z.

- Luz_Poner (la llama Variante_Aplicar) pega war3mapImported\\LightWhite700.mdx («Light - Lights», DarknessFalls003,
  hiveworkshop.com/threads/light-lights.368691: una omni blanca de alcance 700) en "origin" de cada Game_Hero[p] con la
  Tarde o la Noche, y la quita con el Día. Estado común, sin GetLocalPlayer.
- Tarde a las 19:00 (sol de Dark Nights ~0,15, antes ~0,3), misma niebla marrón. La Noche queda como v14z.
- Vuelve el FOG_OF_WAR_VISIBLE del campo de juego en Game_Enter y FogEnable(false), como hasta v14x.
Uso: v14za.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, '    call FogModifierStart(CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, Rect(800.0, 7700.0, 4000.0, 9700.0), true, true))\n',
              '    call FogModifierStart(CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, Rect(-7296.0, -7296.0, 5888.0, 5632.0), true, true))\n'
              '    call FogModifierStart(CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, Rect(800.0, 7700.0, 4000.0, 9700.0), true, true))\n')
s = base.once(s, '''    call FogEnable(true)
    call FogMaskEnable(true)
''', '''    call FogEnable(false)
    call FogMaskEnable(true)
''')
s = base.once(s, 'call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 18.85)\n', 'call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 19.)\n')
s = base.once(s, 'integer Variante= 1\n', 'integer Variante= 1\neffect array Luz_Fx\n')
s = base.once(s, 'function Variante_Aplicar takes integer v returns nothing\n', '''function Luz_Poner takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        if Luz_Fx[p] != null then
            call DestroyEffect(Luz_Fx[p])
            set Luz_Fx[p] = null
        endif
        if Variante > 0 and GetUnitTypeId(Game_Hero[p]) != 0 then
            set Luz_Fx[p] = AddSpecialEffectTarget("war3mapImported\\\\LightWhite700.mdx", Game_Hero[p], "origin")
        endif
        set p = p + 1
    endloop
endfunction

function Variante_Aplicar takes integer v returns nothing
''')
s = base.once(s, '''        set Storm_TF_blue = 0.35
    endif
endfunction
''', '''        set Storm_TF_blue = 0.35
    endif
    call Luz_Poner()
endfunction
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
