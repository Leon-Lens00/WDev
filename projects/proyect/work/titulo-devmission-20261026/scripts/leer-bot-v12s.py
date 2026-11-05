"""Resume el registro de una prueba del bot. Uso: leer-bot-v12s.py CARPETA_LAT"""
from pathlib import Path
import re
import sys

files = sorted(Path(sys.argv[1]).iterdir(), key=lambda p: [int(x) for x in re.findall(r'\d+', p.name)])
lines = []
for f in files:
    for m in re.finditer(r'call Preload\( "(.*?)" \)', f.read_text(encoding='latin-1')):
        lines.append(m.group(1))
seen, uniq = set(), []
for l in lines:
    if l not in seen:
        seen.add(l)
        uniq.append(l)
sale = [l for l in uniq if l.startswith('sale ')]
print('apariciones', len(sale), 'no pasables', sum(' pasable 0 ' in l for l in sale))
for r in sorted({re.search(r'ronda (\d+)', l).group(1) for l in sale}):
    xy = [(int(a), int(b)) for a, b in re.findall(r'ronda ' + r + r' x (-?\d+) y (-?\d+)', '\n'.join(sale))]
    print(' ronda', r, len(xy), 'x', min(p[0] for p in xy), max(p[0] for p in xy), 'y', min(p[1] for p in xy), max(p[1] for p in xy))
for l in uniq:
    if l.startswith(('dash ', 'flecha ', 'evento', 'muerte', 'derrota', 'estado ')):
        print(l[:120])
bot = [l for l in uniq if l.startswith('bot ')]
print('lineas bot', len(bot))
for l in bot[::int(sys.argv[2]) if len(sys.argv) > 2 else 8]:
    print(l[4:190])
if bot:
    print('ULTIMA', bot[-1][4:190])
mira = [l for l in uniq if l.startswith('mira ')]
print('lineas mira', len(mira))
for l in mira[::int(sys.argv[2]) if len(sys.argv) > 2 else 8]:
    print(l[5:230])
if mira:
    print('ULTIMA', mira[-1][5:230])
