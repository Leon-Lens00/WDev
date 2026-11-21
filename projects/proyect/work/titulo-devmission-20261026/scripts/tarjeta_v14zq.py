"""Tarjeta del anuncio de rachas para v14zq (07/11/2026), con los colores del HUD de la tienda (fondo 16,22,34 y borde
120,170,215): un cuadro rectangular para el nombre (arriba) y el texto de la racha (abajo) y, al final, un cuadro pequeño
con borde dorado donde va el retrato. En pantalla se dibuja a 480 × 60 px (8:1, como la textura).
  textura x 1..440: cuadro del texto (centro en pantalla 720 + 220,5 × 0,9375 = 926,7)
  textura x 446..510: cuadro del retrato (centro en pantalla 720 + 478 × 0,9375 = 1168,1)
  racha-v14zq/RachaCaja.png/.blp  512 × 64
No lee ni escribe ningún mapa. Uso (Pillow de plot-env): tarjeta_v14zq.py
"""
from pathlib import Path
import sys
from PIL import Image, ImageDraw
sys.path.insert(0, "/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts")
sys.argv = [sys.argv[0], "texturas"]
from grid import blp

OUT = Path(__file__).resolve().parent.parent / 'racha-v14zq'
OUT.mkdir(exist_ok=True)
K = 4
img = Image.new('RGBA', (512 * K, 64 * K), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
borde, fondo, cara = (120, 170, 215, 255), (16, 22, 34, 215), (8, 10, 18, 240)
d.rounded_rectangle([1 * K, 3 * K, 440 * K, 60 * K], radius=7 * K, fill=fondo, outline=borde, width=2 * K)
d.rounded_rectangle([446 * K, 1 * K, 510 * K, 62 * K], radius=5 * K, fill=cara, outline=(255, 204, 0, 255), width=2 * K)
# Línea fina entre el nombre y el texto.
d.line([14 * K, 27 * K, 426 * K, 27 * K], fill=(120, 170, 215, 120), width=K)
img = img.resize((512, 64), Image.Resampling.LANCZOS)
img.save(OUT / 'RachaCaja.png')
print("RachaCaja", blp(img, OUT / "RachaCaja.blp")[:12])
