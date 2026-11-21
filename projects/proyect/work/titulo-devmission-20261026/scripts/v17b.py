#!/usr/bin/env python3
"""v17b (14/11/2026): balas ligeras por jugador (comando -bl) y ritmo en rps, un 25 % más ligero.

Leon (14/11/2026): "implementa la ligera, obviamente tendra sus tonos de tier con escalas diferentes de acuerdo a la
bala original, de momento se activara con un comando corto, ahora en cuanto a nuestras balas rpm, cambiaremos ello en
la descripcion por una de balas por segundo abreviado, rps [...] del tier 1 al 6 se aligerara los rps". Respuestas:
-25 % en todos, mismo daño por segundo, base v17a + reserva + armas de antes.

Se aplica sobre v17a/war3map.j ya pasado por perfora_v16t, shots_v16t, relojes_v16t, reserva32 y armas_antes.
- Arm_Bala fija también Arm_BalaLigera: BalaLigera\\<Sub|Fus|Fra|Esc>_<color del tier>.mdx (subfusil, fusil de asalto,
  francotirador, escopeta). Misiles y granadas no tienen versión ligera.
- -bl: 0 normal, 1 balas de los demás ligeras, 2 todas ligeras; "-bl" solo pasa al siguiente. Lig_Nivel[p] se escribe
  por el evento de chat (igual en todos los clientes); cada cliente elige el modelo que dibuja con GetLocalPlayer. Las
  dos rutas se arman en todos los clientes antes (Arm_Bala), así que lo local sólo elige entre cadenas ya existentes y
  sólo cambia el efecto que se ve (AddSpecialEffectTarget; Missile_path no se lee en ningún sitio).
- Ritmo: subfusil, fusil de asalto y granada, intervalo / 0,75 (rps x0,75) en los seis tiers; daño por bala / 0,75
  redondeado (mismo daño por segundo). Francotirador, escopeta y misil ya van a 1-1,2 rps: sin cambio.
- Tienda y tutorial: "N rpm  X/s" -> "X rps".
- Precarga de las 24 balas ligeras junto a la de Shot.
Uso: v17b.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
N = '\r\n'


def leer(campo, i):
    m = re.findall(rf'\n    set Arm_{campo}\[{i}\] = ([^\r\n]+)\r\n', s)
    assert len(m) == 1, (campo, i, m)
    return m[0]


def poner(campo, i, valor):
    global s
    a = f'\n    set Arm_{campo}[{i}] = {leer(campo, i)}\r\n'
    assert s.count(a) == 1, a
    s = s.replace(a, f'\n    set Arm_{campo}[{i}] = {valor}\r\n')


num = lambda x: float(x.rstrip('.'))
fmt = lambda x: f'{x:.4f}'.rstrip('0') if x != int(x) else f'{int(x)}.'

# --- ritmo -25 % con el mismo daño por segundo ---
tabla = []
for c in (1, 2, 6):
    for t in range(6):
        w = c * 6 + t
        it, dano = num(leer('Int', w)), num(leer('Dano', w))
        it2, dano2 = it / 0.75, float(round(dano / 0.75))
        poner('Int', w, fmt(round(it2, 4)))
        poner('Dano', w, fmt(dano2))
        tabla.append(f'w{w} T{t + 1}: {1 / it:.1f} -> {1 / it2:.1f} rps, daño {dano:g} -> {dano2:g}')

# --- rps en la tienda y el tutorial ---
s = once(s, '    set s = I2S(R2I(60. / Arm_Int[w] + 0.5)) + " rpm  " + R2SW(1. / Arm_Int[w], 1, 1) + "/s"\n',
         '    set s = R2SW(1. / Arm_Int[w], 1, 1) + " rps"\n')
s = once(s, 'call Tut_SEscribir(Tut_SV[2], I2S(R2I(60. / Arm_Int[w] + 0.5)) + " rpm  " + R2SW(1. / Arm_Int[w], 1, 1) + "/s", ',
         'call Tut_SEscribir(Tut_SV[2], R2SW(1. / Arm_Int[w], 1, 1) + " rps", ')

# --- balas ligeras ---
s = once(s, 'string Arm_BalaModelo= ""\n', '''string Arm_BalaModelo= ""
// v17b: bala ligera del arma y tier actuales ("" si no tiene); nivel por jugador: 0 normal, 1 ajenas, 2 todas.
string Arm_BalaLigera= ""
integer array Lig_Nivel
string array Lig_Texto
''')
s = once(s, '''function Arm_Bala takes integer c, integer t returns nothing
    set Arm_BalaZ = s__RapidBolt_HEIGHT
''', '''function Arm_Bala takes integer c, integer t returns nothing
    set Arm_BalaZ = s__RapidBolt_HEIGHT
    // v17b: versión ligera (BalaLigera\\\\<arma>_<color>.mdx) para el subfusil, el fusil de asalto, el francotirador y la escopeta.
    set Arm_BalaLigera = ""
    if c == 1 then
        set Arm_BalaLigera = "BalaLigera\\\\Sub_" + Arm_ColorTier(t, false) + ".mdx"
    elseif c == 2 then
        set Arm_BalaLigera = "BalaLigera\\\\Fus_" + Arm_ColorTier(t, false) + ".mdx"
    elseif c == 3 then
        set Arm_BalaLigera = "BalaLigera\\\\Fra_" + Arm_ColorTier(t, false) + ".mdx"
    elseif c == 4 then
        set Arm_BalaLigera = "BalaLigera\\\\Esc_" + Arm_ColorTier(t, false) + ".mdx"
    endif
''')
s = once(s, '''        if Arm_BalaModelo != "" then
            call s__Missile__set_model(m,Arm_BalaModelo)
''', '''        if Arm_BalaModelo != "" then
            // v17b: cada cliente dibuja la ligera según su -bl (las dos rutas ya existen en todos; sólo cambia lo que se ve).
            if Arm_BalaLigera != "" and ( Lig_Nivel[GetPlayerId(GetLocalPlayer())] == 2 or ( Lig_Nivel[GetPlayerId(GetLocalPlayer())] == 1 and s__RapidBolt_owner[m] != GetLocalPlayer() ) ) then
                call s__Missile__set_model(m,Arm_BalaLigera)
            else
                call s__Missile__set_model(m,Arm_BalaModelo)
            endif
''')
s = once(s, '// ---- fin de v16t-goku ----\n', '''// ---- fin de v16t-goku ----

// ---- v17b: -bl, balas ligeras (0 normales, 1 las de los demás ligeras, 2 todas ligeras; "-bl" pasa a la siguiente) ----
function Lig_Comando takes nothing returns nothing
    local string s = GetEventPlayerChatString()
    local integer p = GetPlayerId(GetTriggerPlayer())
    local integer n
    if SubString(s, 0, 3) != "-bl" then
        return
    endif
    if StringLength(s) > 3 and SubString(s, 3, 4) != " " then
        return
    endif
    set n = S2I(SubString(s, 4, StringLength(s)))
    if StringLength(s) <= 4 then
        set n = ModuloInteger(Lig_Nivel[p] + 1, 3)
    endif
    if n >= 0 and n <= 2 then
        set Lig_Nivel[p] = n
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 5., Lig_Texto[n])
    endif
endfunction

function Lig_Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer i = 0
    set Lig_Texto[0] = "Balas: normales (-bl 1 ligeras las de los demás, -bl 2 todas)"
    set Lig_Texto[1] = "Balas: las de los demás ligeras, las tuyas normales"
    set Lig_Texto[2] = "Balas: todas ligeras"
    loop
        exitwhen i > 11
        set Lig_Nivel[i] = 0
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-bl", false)
        set i = i + 1
    endloop
    call TriggerAddAction(t, function Lig_Comando)
    set t = null
endfunction
''')
s = once(s, '    call ExecuteFunc("Gk_Init")\n', '    call ExecuteFunc("Gk_Init")\n    call ExecuteFunc("Lig_Init")\n')
pre = ''.join(f'    call Preload("BalaLigera\\\\{a}_{c}.mdx")\n' for a in ('Sub', 'Fus', 'Fra', 'Esc')
              for c in ('Yellow', 'Green', 'Cyan', 'Blue', 'Purple', 'Red'))
s = once(s, '    call Preload("ShotsAjustados\\\\Shot Blue.mdx")\n', '    // v17b: balas ligeras\n' + pre + '    call Preload("ShotsAjustados\\\\Shot Blue.mdx")\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('\n'.join(tabla))
