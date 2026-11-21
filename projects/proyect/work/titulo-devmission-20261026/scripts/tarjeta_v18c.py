"""v18c (15/11/2026): fondo propio de las tarjetas de la súper élite, SupCaja.blp ('DSC0').
Hasta v18b usaban RachaCaja.blp (tarjeta de rachas, tarjeta_v14zu.py), que guarda a la derecha (x 408..510) el fondo
oscuro del retrato de la racha: en la súper élite se veía como un cuadro negro al lado de cada mejora.
SupCaja.blp 512 × 64, en pantalla 309 × 57,68 (Arm_Foto): un solo cuadro redondeado de lado a lado, con el mismo
relleno y borde que la caja de rachas; el tinte dorado o violeta lo sigue poniendo SetUnitVertexColor.
No lee ni escribe ningún mapa. Uso (Pillow de plot-env): tarjeta_v18c.py DIR_SALIDA
"""
from pathlib import Path
import sys
from PIL import Image, ImageDraw
OUT = Path(sys.argv[1])
sys.path.insert(0, "/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts")
sys.argv = [sys.argv[0], "texturas"]
from grid import blp

OUT.mkdir(exist_ok=True)
K = 4
borde, fondo = (120, 170, 215, 255), (16, 22, 34, 215)
img = Image.new('RGBA', (512 * K, 64 * K), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
d.rounded_rectangle([1 * K, 3 * K, 510 * K, 60 * K], radius=7 * K, fill=fondo, outline=borde, width=2 * K)
img = img.resize((512, 64), Image.Resampling.LANCZOS)
img.save(OUT / 'SupCaja.png')
print("SupCaja", blp(img, OUT / "SupCaja.blp")[:12])
