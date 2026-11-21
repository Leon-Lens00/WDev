"""Evalúa la medición de la tabla de daño de v14l (prueba_dano_v14l.py). Uso: leer-dano-v14l.py CARPETA_LAT

Las armas usan DAMAGE_TYPE_NORMAL (Dano_TipoArma): cada pérdida debe ser 10 × tabla (objetos_v14l.py) × (1 − 0,06d /
(1 + 0,06d)) con la defensa d de la unidad (±0,01). Las de prueba 'nda*' (d 0) comprueban la tabla pura; las reales, la
defensa. La columna M (Perforante con DAMAGE_TYPE_MAGIC, el de antes) debe ser la tabla sin defensa. Sale con 1 si
falta el FIN o falla alguna casilla.
"""
from pathlib import Path
import re
import sys

# Tabla y armaduras de objetos_v14l.py (sólo sus definiciones, antes de leer argumentos).
DEF = {'__file__': __file__}
exec((Path(__file__).resolve().parent / 'objetos_v14l.py').read_text().split('\nw_in, w_out')[0], DEF)
TABLA, ARMADURA = DEF['TABLA'], DEF['ARMADURA']
RANURAS = ['small', 'medium', 'large', 'fort', 'normal', 'hero', 'divine', 'none']
NOMBRE = dict(zip(RANURAS, ['Ágil', 'Acorazada', 'Caparazón', 'Pétrea', 'Jugador', 'Colosal', 'Escudo', 'Orgánica']))
# Letra del registro (Dano_Ataque 0..6) a fila de DamageBonus.
FILA = {'P': 'DamageBonusPierce', 'I': 'DamageBonusNormal', 'A': 'DamageBonusMagic', 'E': 'DamageBonusSiege',
        'H': 'DamageBonusHero', 'S': 'DamageBonusSpells', 'V': 'DamageBonusChaos'}
TIPO = dict(zip('PIAEHSV', ['Perforante', 'Impacto', 'Antiblindaje', 'Explosivo', 'Energía', 'Habilidad', 'Estándar']))
# Defensa (udef) de cada unidad según objetos_v14l.py; personajes y unidades de prueba sin defensa.
DEFENSA = dict(DEF['DEFENSA'], h005=0, h006=0)
DEFENSA.update({f'nda{k}': 0 for k in range(8)})
ARMADURA = dict(ARMADURA, **{f'nda{k}': r for k, r in enumerate(RANURAS)})

files = sorted(Path(sys.argv[1]).glob('dano-*.txt'), key=lambda p: int(re.findall(r'\d+', p.name)[-1]))
lineas = [l for f in files for l in re.findall(r'call Preload\( "(.*?)" \)', f.read_text(encoding='latin-1'))]
fin = any(l.startswith('FIN') for l in lineas)
fallos, reales = [], []
puras = {}
for l in lineas:
    m = re.match(r'(\w{4}) vida (\d+) (.*) \| M (\d+)', l)
    if not m:
        continue
    u, medido, normal = m.group(1), dict(zip(*[iter(m.group(3).split())] * 2)), int(m.group(4))
    col = RANURAS.index(ARMADURA[u])
    d = DEFENSA[u]
    f = 1 - 0.06 * d / (1 + 0.06 * d)
    if u.startswith('nda'):
        puras[ARMADURA[u]] = medido
        for k, v in medido.items():
            esperado = round(1000 * TABLA[FILA[k]][col])
            if abs(int(v) - esperado) > 1:
                fallos.append(f'{u} ({NOMBRE[ARMADURA[u]]}) {TIPO[k]}: medido {int(v) / 1000:.3f}, tabla {esperado / 1000:.3f}')
    else:
        for k, v in medido.items():
            esperado = round(1000 * TABLA[FILA[k]][col] * f)
            if abs(int(v) - esperado) > 1:
                fallos.append(f'{u} def {d} {TIPO[k]}: medido {int(v) / 100:.2f}, esperado {esperado / 100:.2f}')
        esperado_m = round(1000 * TABLA['DamageBonusPierce'][col])
        if abs(normal - esperado_m) > 1:
            fallos.append(f'{u} M (MAGIC): medido {normal / 100:.2f}, esperado {esperado_m / 100:.2f}')
        reales.append((u, NOMBRE[ARMADURA[u]], d, medido, normal, esperado_m, None))

print(f'Registros: {len(lineas)} líneas en {len(files)} archivos; FIN {"sí" if fin else "NO"}')
print('\nTabla pura (unidades sin defensa), % del daño base: medido (tabla si difiere)')
print(f'{"":14}' + ''.join(f'{NOMBRE[r]:>11}' for r in RANURAS))
for k in 'PIAEHSV':
    fila = ''
    for c, r in enumerate(RANURAS):
        if r not in puras:
            fila += f'{"falta":>11}'
            continue
        v, t = int(puras[r][k]) / 10, round(100 * TABLA[FILA[k]][c])
        fila += f'{v:>11.1f}' if abs(v - t) <= 0.1 else f'{f"{v:.1f}({t})":>11}'
    print(f'{TIPO[k]:14}' + fila)
print('\nUnidades reales: pérdida de 10 por tipo con defensa; V = Estándar, el de todas las armas ahora')
for u, n, d, medido, normal, esperado_n, casa in reales:
    resumen = ' '.join(f'{k}{int(v) / 100:.2f}' for k, v in medido.items())
    print(f'{u} {n:10} def {d}: {resumen};  Perforante MAGIC {normal / 100:.2f} (tabla {esperado_n / 100:.2f})')
faltan = [r for r in RANURAS if r not in puras]
if faltan:
    fallos.append('faltan unidades de prueba: ' + ', '.join(faltan))
if not fin:
    fallos.append('sin línea FIN')
print('\n' + ('FALLA\n' + '\n'.join(fallos) if fallos else f'OK: las 56 casillas de la tabla pura y las {7 * len(reales)} de las unidades reales con su defensa coinciden'))
sys.exit(1 if fallos else 0)
