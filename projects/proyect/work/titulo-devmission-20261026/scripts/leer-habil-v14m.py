"""Evalúa la prueba v14m-habil (prueba_habil_v14m.py). Uso: leer-habil-v14m.py CARPETA_LAT

Comprueba: embestidas de los tres niveles (aviso y fin), el jefe con 3 seguidas, golpes con su daño (8, 18 y 30 a
ronda 1-2), Endurecer, los pulsos de élite y jefe, y en cada refuerzo la pérdida de 10 de daño Estándar con la defensa
base (objetos_v14l.py) más la del refuerzo: 10 × (1 − 0,06d / (1 + 0,06d)). Sale con 1 si falta algo o falla.
"""
from pathlib import Path
import re
import struct
import sys

DEF = {'__file__': __file__}
exec((Path(__file__).resolve().parent / 'objetos_v14l.py').read_text().split('\nw_in, w_out')[0], DEF)
DEFENSA = DEF['DEFENSA']
NIVEL = ['normal', 'élite', 'jefe']
DANO = [800, 1800, 3000]

files = sorted(Path(sys.argv[1]).glob('v14m-hab-*.txt'), key=lambda p: int(re.findall(r'\d+', p.name)[-1]))
lineas = [l for f in files for l in re.findall(r'call Preload\( "(.*?)" \)', f.read_text(encoding='latin-1'))]
fallos = []
avisos = {0: [], 1: [], 2: []}
fines = {0: 0, 1: 0, 2: 0}
golpes = {0: 0, 1: 0, 2: 0}
pulsos = {1: [], 2: []}
endurecer = 0
medidas = []
for l in lineas:
    m = re.match(r't ([\d.]+) (.*)', l)
    if not m:
        continue
    t, r = float(m.group(1)), m.group(2)
    if (a := re.match(r'aviso (\d)', r)):
        avisos[int(a.group(1))].append(t)
    elif (a := re.match(r'fin (\d)', r)):
        fines[int(a.group(1))] += 1
    elif (a := re.match(r'golpe (\d) p (\d+) dano (\d+) esperado (\d+)', r)):
        n, d, e = int(a.group(1)), int(a.group(3)), int(a.group(4))
        golpes[n] += 1
        if e != DANO[n] or abs(d - e) > 1:
            fallos.append(f'golpe {NIVEL[n]} t {t}: daño {d / 100}, esperado {e / 100} (debe {DANO[n] / 100})')
    elif (a := re.match(r'pulso (\d) unidades (\d+)', r)):
        pulsos[int(a.group(1))].append(int(a.group(2)))
    elif r.startswith('endurecer'):
        endurecer += 1
    elif (a := re.match(r'medir (-?\d+) extra (\d+) perdida (\d+)', r)):
        u = struct.pack('>i', int(a.group(1))).decode('latin-1')
        d = DEFENSA[u] + int(a.group(2))
        esperado = round(1000 * (1 - 0.06 * d / (1 + 0.06 * d)))
        medidas.append((t, u, d, int(a.group(3)), esperado))
        if int(a.group(2)) == 0 or abs(int(a.group(3)) - esperado) > 1:
            fallos.append(f'medir {u} t {t}: extra {a.group(2)}, pérdida {int(a.group(3)) / 100}, esperada {esperado / 100} (def {d})')

print(f'Registros: {len(lineas)} líneas; FIN {"sí" if "FIN" in " ".join(lineas) else "NO"}')
for n in range(3):
    print(f'{NIVEL[n]:7} avisos {len(avisos[n])} fines {fines[n]} golpes {golpes[n]}  t: {", ".join(f"{t:g}" for t in avisos[n][:12])}')
    if not avisos[n] or not golpes[n]:
        fallos.append(f'{NIVEL[n]}: sin embestidas o sin golpes')
    if fines[n] < len(avisos[n]) - 1:
        fallos.append(f'{NIVEL[n]}: embestidas sin terminar')
seguidas = max((sum(1 for u in avisos[2] if t <= u <= t + 4.5) for t in avisos[2]), default=0)
print(f'jefe: máximo de embestidas en 4,5 s: {seguidas}')
if seguidas < 3:
    fallos.append('jefe: no hizo 3 embestidas seguidas')
print(f'endurecer {endurecer}; pulsos élite {pulsos[1]}; pulsos jefe {pulsos[2]}')
if endurecer < 1 or not pulsos[1] or not pulsos[2]:
    fallos.append('falta algún refuerzo (endurecer, pulso de élite o de jefe)')
print('medidas de defensa (unidad, defensa total, pérdida ×100, esperada):')
for t, u, d, p, e in medidas:
    print(f'  t {t:6g} {u} def {d}: {p} ({e})')
if not medidas:
    fallos.append('sin medidas de defensa')
if not any(l == 't ' + l.split(' ')[1] + ' FIN' for l in lineas if l.startswith('t ')):
    fallos.append('sin línea FIN')
print('\n' + ('FALLA\n' + '\n'.join(fallos) if fallos else 'OK'))
sys.exit(1 if fallos else 0)
