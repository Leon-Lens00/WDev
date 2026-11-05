"""Resume el registro oculto del test general. Uso: leer-general-v12t.py CARPETA_LAT [paso_bot]"""
from pathlib import Path
import re
import sys

files = sorted(Path(sys.argv[1]).glob('j1-*'), key=lambda p: int(re.findall(r'\d+', p.name)[1]))
lines = []
for f in files:
    lines += re.findall(r'call Preload\( "(.*?)" \)', f.read_text(encoding='latin-1'))
print('lineas', len(lines))
for l in lines:
    if l.startswith(('pantalla', 'eleccion', 'cuerpos', 'FIN', 'censo', 'dash', 'flecha', 'evento', 'muerte', 'derrota')):
        print(l[:170])
bot = [l for l in lines if l.startswith('bot ')]
print('lineas bot', len(bot))
for l in bot[::int(sys.argv[2]) if len(sys.argv) > 2 else 40]:
    print(l[4:170])
