#!/usr/bin/env python3
"""v16t-perfora (13/11/2026): precisión de ráfaga, misil algo más lento, escopeta de 3 perdigones grandes y perforación.

Leon (13/11/2026): "reduscamos un poquito la velocidad del misil, y otro en las armas de rafaga aumentemos su presicion,
tendra su ligera falta de precision para que este realista los disparos, en la escopeta quiero que sean solo 3 balas
ahora, pero seria escalar el area de impacto junto al modelo [...] escala lo suficiente para que cubra en como seria 5
disparos en abanico actual, escopeta podra atravezar enemigos segun el tier, tier 1 0, tier 2, 1 adicional, y asi
sucesivamente, rifle franco atravesara a nivel de la escopeta, con 2 base y subiendo 1 por tier, la rifle en la cual
esta la scar, como base tendra 1, no sube con tier".

- Misiles: bala 1200 -> 1000.
- Subfusil: desvío 12 -> 4 grados. Fusil de asalto: desvío 6 -> 2 y el desvío que crece en ráfaga +0,8 hasta 12 ->
  +0,3 hasta 4.
- Escopeta: 3 perdigones (daño por perdigón x5/3: mismo daño total), abanico ±8 grados, radio de choque 30 -> 50 y
  modelo x5/3 con partículas y estelas (FirebrandShots\\Grande\\, scripts/escalar_mdx.cjs). Con radio 50 los tres
  cubren a 400 de distancia lo mismo que los cinco de radio 30 en ±10 grados (unos 210 de ancho, sin huecos).
- Atraviesa: escopeta tier - 1 (0..5); fusil de asalto 1 en todos; francotirador ya era 2..7 (sin cambio).
Uso: perfora_v16t.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import re
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
K = 5 / 3


def leer(campo, i):
    m = re.findall(rf'\n    set Arm_{campo}\[{i}\] = ([^\r\n]+)\r\n', j)
    assert len(m) == 1, (campo, i, m)
    return m[0]


def poner(campo, i, valor):
    global j
    a = f'\n    set Arm_{campo}[{i}] = {leer(campo, i)}\r\n'
    assert j.count(a) == 1, a
    j = j.replace(a, f'\n    set Arm_{campo}[{i}] = {valor}\r\n')


def una(a, b):
    global j
    a, b = a.replace('\n', '\r\n'), b.replace('\n', '\r\n')
    assert j.count(a) == 1, (a, j.count(a))
    j = j.replace(a, b)


num = lambda s: float(s.rstrip('.'))
fmt = lambda x: f'{x:.4f}'.rstrip('0') if x != int(x) else f'{int(x)}.'
for t in range(6):
    # misiles
    w = t
    assert num(leer('Vel', w)) == 1200.
    poner('Vel', w, '1000.')
    poner('Rasgo', w, leer('Rasgo', w).replace('bala 1200', 'bala 1000'))
    # subfusil y fusil de asalto
    assert num(leer('Disp', 6 + t)) == 12. and num(leer('Disp', 12 + t)) == 6.
    poner('Disp', 6 + t, '4.')
    poner('Disp', 12 + t, '2.')
    w = 12 + t
    poner('Perfora', w, '1')
    r = re.sub(r', atraviesa \d+', '', leer('Rasgo', w))
    poner('Rasgo', w, r.replace('|r, ', '|r, atraviesa 1, ', 1))
    # francotirador: ya 2 + (t - 1)
    assert int(leer('Perfora', 18 + t)) == 2 + t
    # escopeta
    w = 24 + t
    assert int(leer('Perd', w)) == 5 and num(leer('Disp', w)) == 10.
    poner('Perd', w, '3')
    poner('Dano', w, fmt(float(round(num(leer('Dano', w)) * K))))
    poner('Disp', w, '8.')
    poner('Perfora', w, str(t))
    r = leer('Rasgo', w).replace('5 perdigones, en abanico', '3 perdigones grandes, en abanico')
    if t:
        r = r.replace('|r, ', f'|r, atraviesa {t}, ', 1)
    assert '3 perdigones grandes' in r
    poner('Rasgo', w, r)
    print('tier', t + 1, 'misil', leer('Vel', t), '| smg disp', leer('Disp', 6 + t), '| scar disp', leer('Disp', 12 + t),
          'perf', leer('Perfora', 12 + t), '| franco perf', leer('Perfora', 18 + t), '| escopeta perd', leer('Perd', 24 + t),
          'daño', leer('Dano', 24 + t), 'perf', leer('Perfora', 24 + t))

# desvío creciente del fusil de asalto
una('            set Arm_Desvio[p]=RMinBJ(Arm_Desvio[p] + 0.8, 12.)\n',
    '            // v16t-perfora: ráfaga más precisa (+0,3 hasta 4).\n'
    '            set Arm_Desvio[p]=RMinBJ(Arm_Desvio[p] + 0.3, 4.)\n')
# escopeta: modelo grande y radio 50
una('''        set Arm_BalaModelo = "FirebrandShots\\\\Firebrand Shot " + Arm_ColorTier(t, true) + ".mdx"
        set Arm_BalaRadio = s__RapidBolt_HIT_RADIUS
''', '''        // v16t-perfora: 3 perdigones x5/3 (modelo con partículas y estelas escaladas; radio 30 -> 50).
        set Arm_BalaModelo = "FirebrandShots\\\\Grande\\\\Firebrand Shot " + Arm_ColorTier(t, true) + ".mdx"
        set Arm_BalaRadio = s__RapidBolt_HIT_RADIUS * 5. / 3.
''')
# precarga de los modelos grandes junto a los de siempre
cols = ['Blue', 'Green', 'Orange', 'Pink', 'Purple', 'Red', 'Silver', 'Teal', 'Yellow']
una('    call Preload("FirebrandShots\\\\Firebrand Shot Yellow.mdx")\n',
    '    call Preload("FirebrandShots\\\\Firebrand Shot Yellow.mdx")\n'
    + ''.join(f'    call Preload("FirebrandShots\\\\Grande\\\\Firebrand Shot {c}.mdx")\n' for c in cols))
una('    call DestroyEffect(AddSpecialEffect("FirebrandShots\\\\Firebrand Shot Yellow.mdx", x, y))\n',
    '    call DestroyEffect(AddSpecialEffect("FirebrandShots\\\\Firebrand Shot Yellow.mdx", x, y))\n'
    + ''.join(f'    call DestroyEffect(AddSpecialEffect("FirebrandShots\\\\Grande\\\\Firebrand Shot {c}.mdx", x, y))\n' for c in cols))
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
