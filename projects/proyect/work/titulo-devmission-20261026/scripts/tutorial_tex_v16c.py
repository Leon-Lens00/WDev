"""Textura del tutorial v16c (08/11/2026): TutCasilla.blp 64 × 64, casilla vacía de la consola del tutorial (oscura,
borde azul gris, esquinas redondeadas); en pantalla 72 × 72. No lee ni escribe ningún mapa.
Uso (Pillow de plot-env): tutorial_tex_v16c.py
"""
from pathlib import Path
import sys
from PIL import Image, ImageDraw
sys.path.insert(0, "/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts")
sys.argv = [sys.argv[0], "texturas"]
from grid import blp

OUT = Path(__file__).resolve().parent.parent / 'tutorial-v16c'
OUT.mkdir(exist_ok=True)
K = 4
c = Image.new('RGBA', (64 * K, 64 * K), (0, 0, 0, 0))
d = ImageDraw.Draw(c)
d.rounded_rectangle([1 * K, 1 * K, 62 * K, 62 * K], radius=6 * K, fill=(10, 13, 22, 205), outline=(80, 105, 140, 255), width=2 * K)
c = c.resize((64, 64), Image.Resampling.LANCZOS)
c.save(OUT / 'TutCasilla.png')
print('TutCasilla', blp(c, OUT / 'TutCasilla.blp')[:12])
