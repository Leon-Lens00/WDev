#!/usr/bin/env python3
"""v16t-rpm (13/11/2026): menos balas por segundo; el tier mejora el daño de la bala en lugar del ritmo.

Leon (13/11/2026): "ahora vamos a reducir sus rpm o intervalo de ataque para no causar mucho lag, en la escopeta sera
siempre 5 perdigones en abanico" y "dejemos de momento la rpm del tier 1, ahora el dano mejorara directo en la bala en
lugar del rpm y la velocidad fija en tier 1 tambien, el intervalo de la escopeta sera como el rifle franco, muy lenta".

- Subfusil, fusil de asalto y granada: intervalo y velocidad de bala del tier 1 en los seis tiers.
- Francotirador y misiles: ya tenían el mismo intervalo; velocidad del tier 1.
- Escopeta: intervalo 1,0 s (el del francotirador), 5 perdigones en abanico fijo de -disp a +disp, velocidad del tier 1.
- Daño por bala: el que conserva el daño por segundo de cada tier (daño × perdigones / intervalo), redondeado.
- Cuchillo sin cambios (no dispara balas).
- Textos de rasgo: "bala N" y "N perdigones" con los valores nuevos.
Uso: rpm_v16t.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import re
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')


def leer(campo, i):
    m = re.findall(rf'\n    set Arm_{campo}\[{i}\] = ([^\r\n]+)\r\n', j)
    assert len(m) == 1, (campo, i, m)
    return m[0]


def poner(campo, i, valor):
    global j
    a = f'\n    set Arm_{campo}[{i}] = {leer(campo, i)}\r\n'
    assert j.count(a) == 1, a
    j = j.replace(a, f'\n    set Arm_{campo}[{i}] = {valor}\r\n')


def num(s):
    return float(s.rstrip('.'))


fmt = lambda x: f'{x:.4f}'.rstrip('0') if x != int(x) else f'{int(x)}.'
cambios = []
for c in (0, 1, 2, 3, 4, 6):
    w1 = c * 6
    int1, vel1 = num(leer('Int', w1)), num(leer('Vel', w1))
    nuevo_int = 1.0 if c == 4 else int1
    for t in range(6):
        w = w1 + t
        it, vel, perd, dano = num(leer('Int', w)), num(leer('Vel', w)), int(leer('Perd', w)), num(leer('Dano', w))
        perd_n = 5 if c == 4 else perd
        dps = dano * perd / it
        dano_n = round(dps * nuevo_int / perd_n)
        poner('Int', w, fmt(nuevo_int))
        poner('Vel', w, fmt(vel1))
        poner('Perd', w, str(perd_n))
        poner('Dano', w, fmt(float(dano_n)))
        # rasgo: bala N y perdigones
        r = leer('Rasgo', w)
        r2 = re.sub(r'bala \d+', f'bala {int(vel1)}', r)
        r2 = re.sub(r'\d+ perdigones', '5 perdigones, en abanico', r2) if c == 4 else r2
        if r2 != r:
            poner('Rasgo', w, r2)
        cambios.append((w, leer('Nombre', w), f'{60 / it:.0f}->{60 / nuevo_int:.0f} rpm', f'{perd}->{perd_n} perd',
                        f'{dano:g}->{dano_n} daño', f'{vel:g}->{vel1:g} vel', f'dps {dps:.0f}->{dano_n * perd_n / nuevo_int:.0f}'))

# --- escopeta: abanico fijo en lugar de desvío al azar ---
a = """        loop
            exitwhen n >= Arm_Perd[w]
            call Arm_Tiro(this , w , angle + GetRandomReal(- disp, disp) * bj_DEGTORAD , range)
            set n=n + 1
        endloop
"""
b = """        loop
            exitwhen n >= Arm_Perd[w]
            if c == 4 and Arm_Perd[w] > 1 then
                // v16t-rpm: abanico fijo de -disp a +disp
                call Arm_Tiro(this , w , angle + ( - disp + 2. * disp * I2R(n) / I2R(Arm_Perd[w] - 1) ) * bj_DEGTORAD , range)
            else
                call Arm_Tiro(this , w , angle + GetRandomReal(- disp, disp) * bj_DEGTORAD , range)
            endif
            set n=n + 1
        endloop
"""
a, b = a.replace('\n', '\r\n'), b.replace('\n', '\r\n')
assert j.count(a) == 1
j = j.replace(a, b)
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
for x in cambios:
    print(*x, sep='  ')
