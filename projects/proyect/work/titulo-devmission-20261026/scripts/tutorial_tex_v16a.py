"""Texturas del tutorial v16a (08/11/2026). No lee ni escribe ningún mapa.
  TutFoco.blp   512 × 512: oscuro translúcido (alfa 175) con un hueco circular transparente de radio 8 px en el centro y
                borde suave hasta 11 px. En pantalla mide 64 × el radio del hueco, así tapa toda la pantalla.
  TutPanel.blp  512 × 128: panel del narrador, en pantalla 640 × 160; fondo del retrato a la izquierda.
  TutMano.blp, TutMira.blp 64 × 64: mano y mira del cursor orco del juego (UI\\Cursor\\OrcCursor.blp de war3.mpq,
                cuadros de 32 × 32: fila 0 y fila 2), ampliados al doble.
Uso (Pillow de plot-env): tutorial_tex_v16a.py
"""
from pathlib import Path
import math, sys
from PIL import Image, ImageDraw
sys.path.insert(0, "/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts")
sys.argv = [sys.argv[0], "texturas"]
from grid import blp

OUT = Path(__file__).resolve().parent.parent / 'tutorial-v16a'
OUT.mkdir(exist_ok=True)

# Foco
n = 512
f = Image.new('RGBA', (n, n))
px = f.load()
for y in range(n):
    for x in range(n):
        d = math.hypot(x + 0.5 - n / 2, y + 0.5 - n / 2)
        t = min(1.0, max(0.0, (d - 8.0) / 3.0))
        px[x, y] = (6, 8, 14, int(175 * t * t * (3 - 2 * t)))
f.save(OUT / 'TutFoco.png')
print('TutFoco', blp(f, OUT / 'TutFoco.blp')[:12])

# Panel: 640 × 160 en pantalla -> × 0.8 en la textura.
K = 4
p = Image.new('RGBA', (512 * K, 128 * K), (0, 0, 0, 0))
d = ImageDraw.Draw(p)
borde, fondo, oscuro = (120, 170, 215, 255), (16, 22, 34, 225), (8, 10, 18, 245)
d.rounded_rectangle([2 * K, 2 * K, 509 * K, 125 * K], radius=10 * K, fill=fondo, outline=borde, width=2 * K)
d.rounded_rectangle([10 * K, 10 * K, 128 * K, 117 * K], radius=6 * K, fill=oscuro)
d.line([140 * K, 40 * K, 498 * K, 40 * K], fill=(120, 170, 215, 120), width=K)
p = p.resize((512, 128), Image.Resampling.LANCZOS)
p.save(OUT / 'TutPanel.png')
print('TutPanel', blp(p, OUT / 'TutPanel.blp')[:12])

# Cursor
c = Image.open(OUT / 'OrcCursor-origen.png').convert('RGBA')
for nombre, caja in (('TutMano', (0, 0, 32, 32)), ('TutMira', (0, 64, 32, 96))):
    im = c.crop(caja).resize((64, 64), Image.Resampling.LANCZOS)
    im.save(OUT / f'{nombre}.png')
    print(nombre, blp(im, OUT / f'{nombre}.blp')[:12])
