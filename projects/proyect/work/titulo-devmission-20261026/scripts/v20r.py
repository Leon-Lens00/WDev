#!/usr/bin/env python3
"""v20r (20/11/2026), fase 1 del rework de habilidades (docs/planes/devmission-rework-habilidades-v20r.md).
- Las cartas ya no ofrecen lo que salió del libro (Tec_Max 0): Power Up de Goku/Freezer/Trunks, Finish Sign,
  Destructo Disc, Kage Bunshin, Garra y Rugido del Tauren, Lanza y Marca de Cairne. Volverán como transformación por
  muertes (fase 2) o como pasiva por impacto (fase 3).
- Teclas nuevas en las cartas: Spirit Bomb E, Senpuu W, Chakra Blast W, Tótem del trueno W.
- Kyuubi Chakra Blast sigue al nivel de Senpuu (sin carta propia); el botón W muestra Senpuu fuera del Kyuubi y Chakra
  Blast dentro. Un reloj de 0,25 s reaplica el libro cuando el tipo del héroe cambia (hNar <-> hNaK).
- Pasivas del Tauren (Disparo encantado) y Cairne (Espíritus guardianes, Réplica) activas desde el inicio.
Uso: v20r.py ENTRADA.j SALIDA.j [prueba]   (normal de v20q; prueba de v20q-prueba)
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


for i, m in ((44, 1), (46, 1), (50, 1), (52, 1), (56, 1), (62, 1), (64, 3), (66, 3), (71, 3), (75, 3)):
    cambia(f'    set Tec_Max[{i}] = {m}\n', f'    set Tec_Max[{i}] = 0\n')
cambia('    set Tec_Max[58] = 1\n', '    set Tec_Max[58] = 0\n')
for i, a, b in ((41, 'T', 'E'), (58, 'D', 'W'), (59, 'T', 'W'), (73, 'A', 'W')):
    cambia(f'    set Tec_Tecla[{i}] = "{a}"\n', f'    set Tec_Tecla[{i}] = "{b}"\n')
for i in (69, 76, 77):
    cambia(f'    set Tec_Ini[{i}] = 0\n', f'    set Tec_Ini[{i}] = 1\n')
cambia('integer array Tec_Niv\n', 'integer array Tec_Niv\n// v20r: tipo del héroe visto por el reloj del libro (Naruto / Kyuubi).\ninteger array Tec_Visto\n')
cambia('''        set n = Tec_Niv[p * 100 + x]
        call SetPlayerAbilityAvailable(Player(p), Tec_Puente[x], n > 0)
''', '''        set n = Tec_Niv[p * 100 + x]
        set v = n > 0
        // v20r: la W de Naruto es Senpuu fuera del Kyuubi y Chakra Blast (mismo nivel) dentro.
        if x == 58 then
            set n = IMinBJ(1, Tec_Niv[p * 100 + 59])
            set Tec_Niv[p * 100 + 58] = n
            set v = n > 0 and GetUnitTypeId(Game_Hero[p]) == 'hNaK'
        elseif x == 59 then
            set v = n > 0 and GetUnitTypeId(Game_Hero[p]) != 'hNaK'
        endif
        call SetPlayerAbilityAvailable(Player(p), Tec_Puente[x], v)
''')
cambia('''function Tec_Aplicar takes integer p returns nothing
    local integer x
    local integer n
''', '''function Tec_Aplicar takes integer p returns nothing
    local integer x
    local integer n
    local boolean v
''')
cambia('''function Tec_Empezar takes integer p returns nothing''', '''// v20r: reaplica el libro al entrar o salir del Kyuubi (cambia el tipo del héroe).
function Tec_Vigila takes nothing returns nothing
    local integer p = 0
    local integer t
    loop
        exitwhen p >= 12
        if Game_Hero[p] != null then
            set t = GetUnitTypeId(Game_Hero[p])
            if t != Tec_Visto[p] then
                set Tec_Visto[p] = t
                if t == 'hNar' or t == 'hNaK' then
                    call Tec_Aplicar(p)
                endif
            endif
        endif
        set p = p + 1
    endloop
endfunction

function Tec_Empezar takes integer p returns nothing''')
cambia('''function Tec_Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer i = 0
''', '''function Tec_Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer i = 0
    call TimerStart(CreateTimer(), 0.25, true, function Tec_Vigila)
''')
if prueba:
    for viejo, nuevo in (('lat\\\\v20q-', 'lat\\\\v20r-'), ('v20q-don.txt', 'v20r-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20r', 'prueba' if prueba else 'normal')
