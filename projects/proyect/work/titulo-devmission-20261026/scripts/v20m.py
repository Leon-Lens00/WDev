#!/usr/bin/env python3
"""v20m (20/11/2026): el modelo del cuadro MVP / menos puntos lleva las piezas de forma del héroe.
Leon: "cuando salia goku no se mostraba su cabeza". El cuerpo de Goku de D.O.N (Goku_squished.mdx) no tiene cabeza:
se la pone una habilidad de objeto con arte en "head" (A069 normal, A06A SS, A06B SS3, A0JO SS4), igual que la cabeza
y la espada de Trunks (A07X, A03Z) y los ojos de Naruto (A0AO). La copia 'hMf*' del cuadro no lleva habilidades, así
que salía sin ellas. Ahora se pegan las mismas piezas que tenga el héroe en ese momento, como efectos con el modelo
sólo en el cliente que mira el cuadro (como la luz de v20d); los demás clientes crean el efecto sin modelo.
Las auras de forma (A0G4, A00Y, A0HX) no se copian: taparían el cuadro.
Uso: v20m.py ENTRADA.j SALIDA.j [prueba]   (normal de v20l; prueba de v20l-prueba)
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


PIEZAS = [('A069', 'GokuHead_SS_squished.mdx', 'head'), ('A06A', 'GokuHead_SS_squished.mdx', 'head'),
          ('A06B', 'GokuHead_SS3_squished.mdx', 'head'), ('A0JO', 'GokuHeadSS4.mdx', 'head'),
          ('A07X', 'Future Trunks Super Saiyan Head_squished.mdx', 'head'),
          ('A03Z', 'VikingSwordbyKitabatake_squished.mdx', 'hand right'), ('A0AO', 'SageEyesAura.mdx', 'origin')]

cambia('effect array Mvp_Luz\n', '''effect array Mvp_Luz
// v20m: piezas de forma (cabezas, espada, ojos) de cada modelo, 3 por modelo, sólo con modelo en el cliente que lo ve.
effect array Mvp_Pz
''')
cambia('''        if Mvp_Mod[i] != null then
            call RemoveUnit(Mvp_Mod[i])
            set Mvp_Mod[i] = null
        endif
''', '''        set k = i * 3
        loop
            exitwhen k >= i * 3 + 3
            if Mvp_Pz[k] != null then
                call DestroyEffect(Mvp_Pz[k])
                set Mvp_Pz[k] = null
            endif
            set k = k + 1
        endloop
        if Mvp_Mod[i] != null then
            call RemoveUnit(Mvp_Mod[i])
            set Mvp_Mod[i] = null
        endif
''')
cambia('''function Mvp_ModQuitar takes nothing returns nothing
    local integer i = 0
''', '''function Mvp_ModQuitar takes nothing returns nothing
    local integer i = 0
    local integer k
''')
llamadas = ''.join(f'    set k = Mvp_Pieza(p, h, i, k, \'{a}\', "war3mapImported\\\\{m}", "{s}")\n' for a, m, s in PIEZAS)
cambia('''// v20c: al fijarse el resultado, los modelos; con GoodJob, ataque del MVP; con QuestFailed, muerte del otro.
function Mvp_ModTick takes nothing returns nothing''', f'''// v20m: pega al modelo i del cuadro de p una pieza de forma del héroe h si la lleva (habilidad a con su arte m en el
// punto s). El modelo del efecto sólo existe en el cliente de p. Devuelve cuántas piezas lleva ya el modelo.
function Mvp_Pieza takes integer p, unit h, integer i, integer k, integer a, string m, string s returns integer
    if k >= 3 or GetUnitAbilityLevel(h, a) <= 0 then
        return k
    endif
    if GetLocalPlayer() != Player(p) then
        set m = ""
    endif
    set Mvp_Pz[i * 3 + k] = AddSpecialEffectTarget(m, Mvp_Mod[i], s)
    return k + 1
endfunction

// v20m: las piezas de forma que tenga el héroe h (cabezas de Goku y Trunks, espada, ojos de Naruto).
function Mvp_Piezas takes integer p, integer i, unit h returns nothing
    local integer k = 0
    if Mvp_Mod[i] == null or h == null then
        return
    endif
{llamadas}endfunction

// v20c: al fijarse el resultado, los modelos; con GoodJob, ataque del MVP; con QuestFailed, muerte del otro.
function Mvp_ModTick takes nothing returns nothing''')
cambia('''                if Mvp_Mod[p * 2 + 1] != null then
                    set Mvp_Luz[p * 2 + 1] = AddSpecialEffectTarget(luz, Mvp_Mod[p * 2 + 1], "origin")
                endif
''', '''                if Mvp_Mod[p * 2 + 1] != null then
                    set Mvp_Luz[p * 2 + 1] = AddSpecialEffectTarget(luz, Mvp_Mod[p * 2 + 1], "origin")
                endif
                call Mvp_Piezas(p, p * 2, Game_Hero[Mvp_Fila[Mvp_Gana]])
                if Mvp_Pierde >= 0 then
                    call Mvp_Piezas(p, p * 2 + 1, Game_Hero[Mvp_Fila[Mvp_Pierde]])
                endif
''')
if prueba:
    for viejo, nuevo in (('lat\\\\v20l-', 'lat\\\\v20m-'), ('v20l-don.txt', 'v20m-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20m', 'prueba' if prueba else 'normal')
