#!/usr/bin/env python3
"""v19m (19/11/2026): texturas claras de los cuadros, pensadas para teñirse con SetUnitVertexColor (sólo blancos y
grises, con alfa): el tinte decide el color de cada pantalla y tipo de carta.
- CuaBanda (256 × 32): pestaña redondeada con brillo arriba, encima de cada carta (tipo de la carta).
- CuaMarco (256 × 512): marco de 7 px con esquinas reforzadas y resplandor interior, centro transparente (pantalla).
- CuaCabecera (512 × 64): banda de título que se desvanece a los lados, filetes arriba y abajo.
Salida: DIR/CuaBanda|CuaMarco|CuaCabecera.png y .blp (BLP1 con paleta, grid.blp como TiendaEt*). No toca mapas.
Uso (Pillow de plot-env): texturas_v19m.py DIR_SALIDA
"""
from pathlib import Path
import sys
from PIL import Image, ImageChops, ImageDraw, ImageFilter

OUT = Path(sys.argv[1])
sys.path.insert(0, "/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts")
sys.argv = [sys.argv[0], "texturas"]
from grid import blp

OUT.mkdir(exist_ok=True)
K = 4  # sobremuestreo para bordes suaves


def guardar(im, nombre, w, h):
    im = im.resize((w, h), Image.Resampling.LANCZOS)
    im.save(OUT / f'{nombre}.png')
    print(nombre, blp(im, OUT / f'{nombre}.blp')[:12])


# banda
w, h = 256 * K, 32 * K
a = Image.new('L', (w, h), 0)
ImageDraw.Draw(a).rounded_rectangle((2 * K, 3 * K, w - 2 * K, h - 3 * K), radius=12 * K, fill=255)
c = Image.new('L', (w, h), 0)
d = ImageDraw.Draw(c)
for y in range(h):
    t = y / (h - 1)
    d.line((0, y, w, y), fill=int(255 - 70 * t if t > 0.35 else 255))
d.rounded_rectangle((2 * K, 3 * K, w - 2 * K, h - 3 * K), radius=12 * K, outline=150, width=2 * K)
im = Image.merge('RGBA', (c, c, c, a))
guardar(im, 'CuaBanda', 256, 32)

# marco
w, h = 256 * K, 512 * K
a = Image.new('L', (w, h), 0)
d = ImageDraw.Draw(a)
d.rounded_rectangle((3 * K, 3 * K, w - 3 * K, h - 3 * K), radius=10 * K, outline=255, width=7 * K)
glow = Image.new('L', (w, h), 0)
ImageDraw.Draw(glow).rounded_rectangle((10 * K, 10 * K, w - 10 * K, h - 10 * K), radius=8 * K, outline=110, width=6 * K)
glow = glow.filter(ImageFilter.GaussianBlur(5 * K))

a = ImageChops.lighter(a, glow)
d = ImageDraw.Draw(a)
L = 34 * K
for x0, y0, sx, sy in ((3, 3, 1, 1), (253, 3, -1, 1), (3, 509, 1, -1), (253, 509, -1, -1)):
    x0, y0 = x0 * K, y0 * K
    d.line((x0, y0, x0 + sx * L, y0), fill=255, width=12 * K)
    d.line((x0, y0, x0, y0 + sy * L), fill=255, width=12 * K)
c = Image.new('L', (w, h), 235)
im = Image.merge('RGBA', (c, c, c, a))
guardar(im, 'CuaMarco', 256, 512)

# cabecera
w, h = 512 * K, 64 * K
a = Image.new('L', (w, h), 0)
d = ImageDraw.Draw(a)
for x in range(w):
    t = abs(x - w / 2) / (w / 2)
    v = int(200 * max(0., min(1., (1 - t) / 0.35)))
    d.line((x, 10 * K, x, h - 10 * K), fill=v)
    lv = int(255 * max(0., min(1., (1 - t) / 0.2)))
    d.line((x, 5 * K, x, 7 * K), fill=lv)
    d.line((x, h - 7 * K, x, h - 5 * K), fill=lv)
c = Image.new('L', (w, h), 0)
d = ImageDraw.Draw(c)
for y in range(h):
    d.line((0, y, w, y), fill=int(255 - 80 * abs(y - h / 2) / (h / 2)))
im = Image.merge('RGBA', (c, c, c, a))
guardar(im, 'CuaCabecera', 512, 64)
