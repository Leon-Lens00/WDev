#!/usr/bin/env python3
r"""v14p: seis tiers por arma con mejoras por tier (05/11/2026), sobre v14o.

Pedido de Leon: llenar las filas que quedaban en la tienda (el prototipo tenía seis) con armas nuevas. Cada tier mejora
el daño, el cargador, la reserva, la velocidad de la bala y los tiros por ráfaga de 1,5 s; la precisión es la misma en
todos los tiers de una categoría. Rifle y escopeta salen ya rápidos. Números en scripts/armas_v14p.py.
- Arma w = categoría × 6 + tier − 1 (antes × 3) en el juego, la tienda y el HUD.
- Colores por tier: Yellow, Green, Cyan, Blue, Purple y Red; el «T1».. de la tienda y del HUD lleva su color.
- Velocidad de la bala por arma (Arm_Vel); la granada también (900 a 1150).
- Tienda: seis filas; el tipo de daño pasa al hueco del panel izquierdo, porque las filas 4..6 ocupan el suyo.
- Habilidades de arma Aw00..Aw06 con seis niveles (objetos_v14p.py).
Uso: v14p.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base
from armas_v14p import ARMAS, COLORES, RGB, TIERS, DISP, ALC, intervalo, rasgo

N = '\r\n'


def u(x):
    # El script está en UTF-8 y se lee como latin-1: los acentos de lo insertado también.
    return x.encode('utf-8').decode('latin-1')


def once(s, old, new):
    return base.once(s, u(old), u(new))


def funcion(s, cabeza):
    """Inicio y fin (tras endfunction) de la función que empieza por cabeza."""
    c = cabeza.replace('\n', N)
    assert s.count(c) == 1, cabeza
    a = s.index(c)
    b = s.index(N + ('    ' if cabeza.startswith('    ') else '') + 'endfunction', a)
    return a, s.index(N, b + 2) + 2


def en(s, cabeza, old, new, veces=1):
    """Reemplazo dentro de una sola función; veces es cuántas apariciones debe haber."""
    a, b = funcion(s, cabeza)
    f = s[a:b]
    o, n = u(old).replace('\n', N), u(new).replace('\n', N)
    assert f.count(o) == veces, (cabeza, old, f.count(o))
    return s[:a] + f.replace(o, n) + s[b:]


def jstr(x):
    return '"' + x.replace('\\', '\\\\').replace('"', '\\"') + '"'


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')

# Datos: se quitan las líneas por arma de v14o (21 armas) y se escriben las 42 antes de los tipos de daño.
a, b = funcion(s, 'function Arm_Datos takes nothing returns nothing\n')
cuerpo = s[a:b]
lineas = cuerpo.split(N)
fuera = re.compile(r'    set Arm_(Nombre|Rasgo|Coment|Anio|Mag|Res|Perd|Precio|Perfora|Int|Dano|Disp|Rec|Crit|Area|Alc|Tipo)\[\d+\] = ')
quedan = [x for x in lineas if not fuera.match(x)]
assert len(lineas) - len(quedan) == 21 * 16 + 21, len(lineas) - len(quedan)
nuevas = []
for w, x in enumerate(ARMAS):
    c = w // TIERS
    nuevas += [f'    set Arm_Nombre[{w}] = {jstr(x[0])}', f'    set Arm_Rasgo[{w}] = {jstr(rasgo(c, x))}',
               f'    set Arm_Coment[{w}] = {jstr(x[13])}', f'    set Arm_Anio[{w}] = {x[1]}',
               f'    set Arm_Mag[{w}] = {x[5]}', f'    set Arm_Res[{w}] = {x[6]}', f'    set Arm_Perd[{w}] = {x[4]}',
               f'    set Arm_Precio[{w}] = {x[7]}', f'    set Arm_Perfora[{w}] = {x[9]}',
               f'    set Arm_Int[{w}] = {intervalo(c, x)}', f'    set Arm_Dano[{w}] = {x[3]}.',
               f'    set Arm_Disp[{w}] = {DISP[c]}.', f'    set Arm_Rec[{w}] = {x[8]}', f'    set Arm_Crit[{w}] = {x[10]}',
               f'    set Arm_Area[{w}] = {x[11]}.', f'    set Arm_Alc[{w}] = {ALC[c]}.', f'    set Arm_Vel[{w}] = {x[12]}.',
               f'    set Arm_Tipo[{w}] = 6']
k = quedan.index('    set Dano_Nombre[0] = "|cffe0b040Perforante|r"')
quedan[k:k] = [u(x) for x in nuevas]
s = s[:a] + N.join(quedan) + s[b:]
s = once(s, 'real array Arm_Alc\n', 'real array Arm_Alc\nreal array Arm_Vel\n')

# Índice del arma con seis tiers.
n = len(re.findall(r'(\bc|Shop_Cat\[p\]|Arm_Cat\[p\]) \* 3 \+', s))
assert n == 10, n
s = re.sub(r'(\bc|Shop_Cat\[p\]|Arm_Cat\[p\]) \* 3 \+', r'\1 * 6 +', s)
s = once(s, '        if w / 3 == 1 then\n            return 1. / Arm_Int[w]', '        if w / 6 == 1 then\n            return 1. / Arm_Int[w]')
s = once(s, 'call Arm_Bala(w / 3 , ModuloInteger(w, 3) + 1)', 'call Arm_Bala(w / 6 , ModuloInteger(w, 6) + 1)')
# HUD: la clave de refresco separaba tiers de 0 a 3 con × 4.
s = once(s, 'set clave = (c * 4 + Arm_Tier[i]) * 1000000', 'set clave = (c * 8 + Arm_Tier[i]) * 1000000')
s = once(s, 'Arm_Nombre[w] + " T" + I2S(Arm_Tier[i]), 0.017, 192.)', 'Arm_Nombre[w] + " " + Arm_TierTexto(Arm_Tier[i]), 0.017, 192.)')

# Colores y velocidad.
a, b = funcion(s, 'function Arm_ColorTier takes integer t, boolean teal returns string\n')
hexes = ''.join(f'''    elseif t == {t + 1} then
        return "|cff{RGB[col][0]:02x}{RGB[col][1]:02x}{RGB[col][2]:02x}T{t + 1}|r"
''' for t, col in enumerate(COLORES))
s = s[:a] + u(f'''// v14p: color del tier t para los nombres de los modelos; Firebrand tiene Teal para el Cyan.
function Arm_ColorTier takes integer t, boolean teal returns string
    if t == 1 then
        return "Yellow"
    elseif t == 2 then
        return "Green"
    elseif t == 3 and teal then
        return "Teal"
    elseif t == 3 then
        return "Cyan"
    elseif t == 4 then
        return "Blue"
    elseif t == 5 then
        return "Purple"
    endif
    return "Red"
endfunction

// v14p: «T1».. con el color de su tier, para la tienda y el HUD.
function Arm_TierTexto takes integer t returns string
    if t < 1 then
        return "T0"
{hexes}    endif
    return "T" + I2S(t)
endfunction
''').replace('\n', N) + s[b:]
s = once(s, '// v14o: color del tier t para los nombres de los modelos; Firebrand tiene Teal para el Cyan.\n// v14p', '// v14p')
s = en(s, 'function Arm_Bala takes integer c, integer t returns nothing\n',
       '    set Arm_BalaVel = 1200.\n', '    set Arm_BalaVel = Arm_Vel[c * 6 + t - 1]\n')
s = en(s, 'function Arm_Bala takes integer c, integer t returns nothing\n', '        set Arm_BalaVel = 900.\n', '')

# Tienda: seis filas. Textos 1..3 y 4..6 de las filas 1..3; 24..26 y 27..29 de las filas 4..6.
s = once(s, 'function Shop_Refrescar takes integer p returns nothing\n', '''// v14p: texttag del nombre (Shop_FilaN) y del precio (Shop_FilaP) de la fila k (0..5).
function Shop_FilaN takes integer k returns integer
    if k < 3 then
        return 1 + k
    endif
    return 21 + k
endfunction

function Shop_FilaP takes integer k returns integer
    if k < 3 then
        return 4 + k
    endif
    return 24 + k
endfunction

function Shop_Refrescar takes integer p returns nothing
''')
R = 'function Shop_Refrescar takes integer p returns nothing\n'
s = en(s, R, '        exitwhen k > 2\n        set x = c * 6 + k\n', '        exitwhen k > 5\n        set x = c * 6 + k\n')
s = en(s, R, 'Shop_T[1 + k]', 'Shop_T[Shop_FilaN(k)]', 3)
s = en(s, R, 'Shop_T[4 + k]', 'Shop_T[Shop_FilaP(k)]', 3)
s = en(s, R, '"T" + I2S(k + 1) + "  " + Arm_Nombre[x]', 'Arm_TierTexto(k + 1) + "  " + Arm_Nombre[x]')
# Tipo de daño: al hueco del panel izquierdo, debajo de las categorías (las filas 4..6 están donde iba). Sin eficaz ni
# débil, la descripción en dos renglones de 34 caracteres (Shop_Partir, como el golem).
s = en(s, R, '''    call Shop_Centro(p, Shop_T[21], "Daño " + Dano_Nombre[k] + ": " + Dano_Desc[k], 998.6, 330, 0.019)
    if Dano_Eficaz[k] == "" then
        set s = ""
    else
        set s = "|cff60ff60Eficaz|r contra " + Dano_Eficaz[k]
    endif
    call Shop_Centro(p, Shop_T[22], s, 998.6, 380, 0.019)
    if Dano_Debil[k] == "" then
        set s = ""
    else
        set s = "|cffff6060Débil|r contra " + Dano_Debil[k]
    endif
    call Shop_Centro(p, Shop_T[23], s, 998.6, 420, 0.019)
''', '''    call Shop_Izq(p, Shop_T[21], "Daño " + Dano_Nombre[k], 150, 612, 0.020)
    if Dano_Eficaz[k] == "" and Dano_Debil[k] == "" then
        call Shop_Partir(Dano_Desc[k])
        call Shop_Izq(p, Shop_T[22], Shop_L[0], 150, 648, 0.017)
        call Shop_Izq(p, Shop_T[23], Shop_L[1], 150, 678, 0.017)
    else
        set s = ""
        if Dano_Eficaz[k] != "" then
            set s = "|cff60ff60Eficaz|r contra " + Dano_Eficaz[k]
        endif
        call Shop_Izq(p, Shop_T[22], s, 150, 648, 0.017)
        set s = ""
        if Dano_Debil[k] != "" then
            set s = "|cffff6060Débil|r contra " + Dano_Debil[k]
        endif
        call Shop_Izq(p, Shop_T[23], s, 150, 678, 0.017)
    endif
''')
s = en(s, 'function Shop_Clic takes nothing returns nothing\n', '    elseif k <= 12 then\n', '    elseif k <= 15 then\n')
for f in ('function Shop_Textos takes nothing returns nothing\n', 'function Shop_TextosFuera takes nothing returns nothing\n'):
    s = en(s, f, '        exitwhen i > 23\n', '        exitwhen i > 29\n')
s = once(s, '// Sólo en el cliente de quien abre la tienda: 38 texttags', '// Sólo en el cliente de quien abre la tienda: 44 texttags')
C = 'function Shop_Construir takes nothing returns nothing\n'
s = en(s, C, '''        exitwhen i > 2
        call Shop_Pic(948, 156 + 58 * i, 716, 56, 399, 'DS08')''', '''        exitwhen i > 5
        call Shop_Pic(948, 156 + 58 * i, 716, 56, 399, 'DS08')''')
s = en(s, C, '''                exitwhen i > 2
                call Shop_Pista(p, "war3mapImported\\\\ShopHitRow.mdx"''', '''                exitwhen i > 5
                call Shop_Pista(p, "war3mapImported\\\\ShopHitRow.mdx"''')

Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
