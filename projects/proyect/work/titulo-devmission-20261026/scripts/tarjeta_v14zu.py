"""Texturas de la tarjeta de rachas para v14zu (07/11/2026). En v14zt el retrato aún asomaba por la izquierda
del marco: marco de 80 px de ancho (antes 66) con la misma ventana, y cuadro del texto más corto.
  RachaCaja.blp  512 × 64, en pantalla 410 × 56: cuadro del texto x 1..400 (centro en pantalla cx − 44,4) y fondo oscuro
                 del retrato x 408..510 (centro cx + 163, 82 px de ancho), ya sin borde (lo pone el marco).
  RachaMarco.blp 128 × 128, en pantalla 80 × 56: oscuro alrededor, borde dorado y ventana transparente de 48 × 44 px.
No lee ni escribe ningún mapa. Uso (Pillow de plot-env): tarjeta_v14zt.py
"""
from pathlib import Path
import sys
from PIL import Image, ImageDraw
sys.path.insert(0, "/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts")
sys.argv = [sys.argv[0], "texturas"]
from grid import blp

OUT = Path(__file__).resolve().parent.parent / 'racha-v14zu'
OUT.mkdir(exist_ok=True)
K = 4
borde, fondo, oscuro, oro = (120, 170, 215, 255), (16, 22, 34, 215), (8, 10, 18, 245), (255, 204, 0, 255)

img = Image.new('RGBA', (512 * K, 64 * K), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
d.rounded_rectangle([1 * K, 3 * K, 400 * K, 60 * K], radius=7 * K, fill=fondo, outline=borde, width=2 * K)
d.line([14 * K, 27 * K, 387 * K, 27 * K], fill=(120, 170, 215, 120), width=K)
d.rounded_rectangle([408 * K, 1 * K, 510 * K, 62 * K], radius=5 * K, fill=oscuro)
img = img.resize((512, 64), Image.Resampling.LANCZOS)
img.save(OUT / 'RachaCaja.png')
print("RachaCaja", blp(img, OUT / "RachaCaja.blp")[:12])

# Marco: 80 × 56 px en pantalla sobre 128 × 128 de textura (x × 128/80, y × 128/56).
sx, sy = 128 / 80, 128 / 56
m = Image.new('RGBA', (128 * K, 128 * K), oscuro)
d = ImageDraw.Draw(m)
ventana = [16 * sx * K, 6 * sy * K, (80 - 16) * sx * K, (56 - 6) * sy * K]
d.rounded_rectangle(ventana, radius=3 * sx * K, fill=(0, 0, 0, 0))
d.rounded_rectangle([v + (-1.5 if i < 2 else 1.5) * (sx if i % 2 == 0 else sy) * K for i, v in enumerate(ventana)],
                    radius=4 * sx * K, outline=oro, width=int(2 * sx * K))
d.rounded_rectangle([1 * sx * K, 1 * sy * K, 79 * sx * K, 55 * sy * K], radius=5 * sx * K, outline=oro, width=int(2 * sx * K))
m = m.resize((128, 128), Image.Resampling.LANCZOS)
m.save(OUT / 'RachaMarco.png')
print("RachaMarco", blp(m, OUT / "RachaMarco.blp")[:12])
