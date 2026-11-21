"""Dibujos del misil de calor para v14zn (07/11/2026), con el estilo de las armas de la tienda (tienda-prototipo-20261101/
generar.py: silueta con degradado azul claro y halo) y del icono de botón BTNArma6 (fondo 16,22,34 y borde 120,170,215).
  misil-v14zn/Arma-misil.png/.blp  256 × 128, la foto de la tienda y del HUD (Cat_Tex[0])
  misil-v14zn/BTNMisil.png/.blp    64 × 64, el botón C (Aw00)
No lee ni escribe ningún mapa. Uso (Pillow de plot-env): iconos_v14zn.py
"""
from pathlib import Path
import sys
from PIL import Image, ImageDraw
sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/tienda-prototipo-20261101')
sys.argv = [sys.argv[0], 'texturas']
import generar
from generar import silhouette, blp

OUT = Path(__file__).resolve().parent.parent / 'misil-v14zn'
MISIL = [(18, 24), (64, 49), (156, 49), (170, 34), (184, 49), (196, 49), (240, 64), (196, 79), (184, 79), (170, 94),
         (156, 79), (64, 79), (18, 104), (32, 79), (32, 49)]
arma = silhouette(MISIL)
arma.save(OUT / 'Arma-misil.png')
print('Arma-misil', blp(arma, OUT / 'Arma-misil.blp')[:8])

btn = Image.new('RGBA', (64, 64), (120, 170, 215, 255))
ImageDraw.Draw(btn).rectangle([2, 2, 61, 61], fill=(16, 22, 34, 255))
caja = arma.getbbox()
s = arma.crop(caja)
k = 52 / max(s.size)
s = s.resize((round(s.width * k), round(s.height * k)), Image.Resampling.LANCZOS)
fondo = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
fondo.paste(s, ((64 - s.width) // 2, (64 - s.height) // 2))
btn = Image.alpha_composite(btn, fondo)
btn.save(OUT / 'BTNMisil.png')
print('BTNMisil', blp(btn, OUT / 'BTNMisil.blp')[:8])
