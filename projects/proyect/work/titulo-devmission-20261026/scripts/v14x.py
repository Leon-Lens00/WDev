#!/usr/bin/env python3
"""v14x: linterna en Tarde y Noche. Parte del j de v14w.

Linterna.mdx (scripts/linterna.cjs, sin haz) son sólo cuatro luces omni con los valores de FlashLightBeamMax.mdx de
OVOgenez: un círculo en el héroe y tres delante, a 300, 600 y 900. Pegada en "origin" de Game_Hero[p], sigue su giro.
Variante_Aplicar la pone en todos los cuerpos con Variante 1 o 2 y la quita con el Día. Es un efecto pegado y lo ven todos (estado común, sin GetLocalPlayer).

Uso: v14x.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'integer Variante= 1\n', 'integer Variante= 1\neffect array Linterna_Fx\n')
s = base.once(s, 'function Variante_Aplicar takes integer v returns nothing\n', '''function Linterna_Poner takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        if Linterna_Fx[p] != null then
            call DestroyEffect(Linterna_Fx[p])
            set Linterna_Fx[p] = null
        endif
        if Variante > 0 and GetUnitTypeId(Game_Hero[p]) != 0 then
            set Linterna_Fx[p] = AddSpecialEffectTarget("war3mapImported\\\\Linterna.mdx", Game_Hero[p], "origin")
        endif
        set p = p + 1
    endloop
endfunction

function Variante_Aplicar takes integer v returns nothing
''')
s = base.once(s, '''        set Storm_TF_blue = 0.
    endif
endfunction
''', '''        set Storm_TF_blue = 0.
    endif
    call Linterna_Poner()
endfunction
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
