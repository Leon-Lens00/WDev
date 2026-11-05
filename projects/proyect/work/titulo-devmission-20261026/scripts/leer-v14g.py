"""Resume el registro oculto de la prueba de v14g. Uso: leer-v14g.py CARPETA_LAT"""
from pathlib import Path
import re
import struct
import sys

def raw(m):
    return struct.pack('>i', int(m.group(1))).decode('latin-1')

files = sorted(Path(sys.argv[1]).glob('v14g-*.txt'), key=lambda p: int(re.findall(r'\d+', p.name)[-1]))
for f in files:
    for l in re.findall(r'call Preload\( "(.*?)" \)', f.read_text(encoding='latin-1')):
        print(re.sub(r'id=(-?\d+)', lambda m: 'id=' + raw(m), l))
