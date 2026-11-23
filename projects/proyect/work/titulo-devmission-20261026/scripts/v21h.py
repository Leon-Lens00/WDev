#!/usr/bin/env python3
"""v21h (22/11/2026): carga de la transformación de Goku tras la prueba de v21g-prueba.

1. Leon: "los dummy de trasformacion o X deben seguir al original, se quedan ahora en donde se castea". En D.O.N el
   héroe queda quieto durante la carga; aquí sigue libre. La pieza h0EY (G2V_Caster[7160]) se mueve con Goku cada tick
   (las chispas h0D3/hG2d salen de ella) y las auras BitchAura/SaianAura se cuelgan del héroe en vez del suelo.
2. Leon: "al trasformarse genera sacudidas, deberia solo se un poco no siempre". La carga ponía una sacudida 3 y la
   llegada a Ultra Instinto otra 8 que nada quitaba (Gk_SacudeEQ dura hasta Gk_SacudeQuitar). Ahora las dos son 3 y se
   quitan 0,5 s después de llegar a la forma (sólo a quien conserva esa sacudida de 3).
Uso: v21h.py ENTRADA.j SALIDA.j [prueba]   (normal de v21g; prueba de v21g-prueba).
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


# --- 1. Las piezas de la carga siguen a Goku ---
cambia('''set G2V_Int[7167]=(G2V_Int[7167]-1)
set G2V_Point[7160]=GetUnitLoc(G2V_Caster[7160])
''', '''set G2V_Int[7167]=(G2V_Int[7167]-1)
// v21h: la pieza de la carga sigue a Goku (en D.O.N el héroe quedaba quieto).
call SetUnitX(G2V_Caster[7160],GetUnitX(G2V_Caster[7150]))
call SetUnitY(G2V_Caster[7160],GetUnitY(G2V_Caster[7150]))
set G2V_Point[7160]=GetUnitLoc(G2V_Caster[7160])
''')
for m in ('BitchAura', 'SaianAura'):
    cambia('call AddSpecialEffectLocBJ(G2V_Point[7160],"war3mapImported\\\\%s.mdx")\n' % m,
           'call AddSpecialEffectTargetUnitBJ("origin",G2V_Caster[7150],"war3mapImported\\\\%s.mdx")\n' % m)

# --- 2. Sacudida corta y suave ---
cambia('''function G2F_Saian_Goku_God2_Func001Func008Func002Func002Func006Func045Func002Func054A takes nothing returns nothing
call Gk_SacudeEQ(GetOwningPlayer(GetEnumUnit()),8.)
''', '''function G2F_Saian_Goku_God2_Func001Func008Func002Func002Func006Func045Func002Func054A takes nothing returns nothing
call Gk_SacudeEQ(GetOwningPlayer(GetEnumUnit()),3.)
''')
cambia('''function G2F_Saian_Goku_God_Func001Func029002003 takes nothing returns boolean
''', '''// v21h: quita la sacudida de 3 de la transformación (Gk_SacudeEQ guarda 2 x 3) medio segundo después de la forma.
function G2_SacudeFin takes nothing returns nothing
    local integer j = 0
    loop
        exitwhen j >= 12
        if Sacude_Mag[j] == 6. then
            set Sacude_Mag[j] = 0.
        endif
        set j = j + 1
    endloop
    call DestroyTimer(GetExpiredTimer())
endfunction
function G2F_Saian_Goku_God_Func001Func029002003 takes nothing returns boolean
''')
cambia('''if(G2F_Saian_Goku_God2_Func001Func008C())then
set G2V_Int[7160]=(G2V_Int[7160]+1)
''', '''if(G2F_Saian_Goku_God2_Func001Func008C())then
set G2V_Int[7160]=(G2V_Int[7160]+1)
call TimerStart(CreateTimer(),.5,false,function G2_SacudeFin)
''')
if prueba:
    cambia('lat\\\\v21g-', 'lat\\\\v21h-', src.count('lat\\\\v21g-'))
    cambia('v21g-don.txt', 'v21h-don.txt', src.count('v21g-don.txt'))
assert not prueba or ('lat\\\\v21g-' not in src and 'v21g-don.txt' not in src), 'quedan registros v21g'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v21h', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
