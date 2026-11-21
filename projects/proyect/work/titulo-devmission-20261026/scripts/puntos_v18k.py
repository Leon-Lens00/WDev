#!/usr/bin/env python3
"""v18k (15/11/2026): textura del cuadro de puntuación al estilo "Round Score" de Dark Moon (vídeo de Leon
20261115_002900, s 19): título, tabla de jugadores (bajas, caídas, bolsas) y abajo cuatro casillas: bolsas recogidas,
bolsas perdidas, caídas del equipo (lápida) y nota de la ronda (las estrellas son las piezas 'DSP1'/'DSP2' de v18j).
Sin torres ni puntos (Dev Mission no los tiene).

- 'DSP3' PuntCuadro (512 × 512) para un cuadro de 600 × 470 px de pantalla (escala 512/600 × 512/470). Fondo casi
  negro translúcido como el de Dark Moon, franjas de fila y casillas algo más claras, etiquetas grises en mayúsculas.
- Las filas de la tabla van a la distancia entre renglones del texttag (1095 px por unidad de tamaño, medida en la
  grabación 20261115_161557, s 42: dos renglones a 0,021 separados 23 px) por dos, porque cada columna es un solo
  texttag con un renglón en blanco entre filas.
Disposición (px dentro del cuadro; en pantalla x = 660 + lx, y = 145 + ly): ver FILAS, COLS y CASILLAS; v18k.py
lee DIR/etiquetas.json para colocar textos y estrellas.
Uso (Pillow de plot-env): puntos_v18k.py FRIZQT__.ttf DIR_SALIDA
"""
from pathlib import Path
import json, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

FUENTE, OUT = sys.argv[1], Path(sys.argv[2])
sys.path.insert(0, "/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts")
sys.argv = [sys.argv[0], "texturas"]
from grid import blp

OUT.mkdir(exist_ok=True)
K = 4
W, H = 600, 470
TAM_FILA = 0.019                         # tamaño de los texttags de la tabla
PASO = 2 * 1095 * TAM_FILA               # 41,6 px por fila
FILAS = [112 + PASO * k for k in range(4)]
COLS = {'JUGADOR': 40, 'BAJAS': 345, 'CAÍDAS': 430, 'BOLSAS': 520}
CAJA_Y = (282, 452)
CASILLAS = [(18, 154), (162, 298), (306, 442), (450, 582)]
GRIS = (165, 170, 185)
BLANCO = (240, 238, 232)

img = Image.new('RGBA', (W * K, H * K), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
d.rounded_rectangle([0, 0, W * K - 1, H * K - 1], radius=6 * K, fill=(6, 6, 12, 228))
d.rounded_rectangle([K, K, W * K - 1 - K, H * K - 1 - K], radius=6 * K, outline=(70, 70, 90, 255), width=K)


def letras(texto, tam, xy, anchor, color=GRIS, esp=0.):
    """Texto con espaciado extra entre letras (px), como las etiquetas de Dark Moon."""
    f = ImageFont.truetype(FUENTE, round(tam * K))
    if not esp:
        d.text((xy[0] * K, xy[1] * K), texto, font=f, fill=color + (255,), anchor=anchor)
        return
    ancho = sum(f.getlength(c) for c in texto) + esp * K * (len(texto) - 1)
    x = xy[0] * K - (ancho / 2 if anchor[0] == 'm' else 0)
    for c in texto:
        d.text((x, xy[1] * K), c, font=f, fill=color + (255,), anchor='l' + anchor[1])
        x += f.getlength(c) + esp * K


# Título con sombra.
f = ImageFont.truetype(FUENTE, 31 * K)
sombra = Image.new('L', img.size, 0)
ImageDraw.Draw(sombra).text((W / 2 * K + 2 * K, 38 * K + 2 * K), 'PUNTUACIÓN DE LA RONDA', font=f, fill=200, anchor='mm')
img.paste(Image.new('RGBA', img.size, (0, 0, 0, 255)), (0, 0), sombra.filter(ImageFilter.GaussianBlur(2 * K)))
d = ImageDraw.Draw(img)
d.text((W / 2 * K, 38 * K), 'PUNTUACIÓN DE LA RONDA', font=f, fill=BLANCO + (255,), anchor='mm')
for nombre, x in COLS.items():
    letras(nombre, 12, (x, 80), 'lm' if nombre == 'JUGADOR' else 'mm', esp=1.5)
# Franjas de fila, como la tabla de Dark Moon.
for k, cy in enumerate(FILAS):
    c = (30, 28, 42, 245) if k % 2 == 0 else (20, 19, 30, 245)
    d.rectangle([20 * K, (cy - 18) * K, (W - 20) * K, (cy + 18) * K], fill=c)
d.line([(20 * K, 270 * K), ((W - 20) * K, 270 * K)], fill=(70, 70, 90, 255), width=K)

# Casillas de abajo.
for x0, x1 in CASILLAS:
    d.rectangle([x0 * K, CAJA_Y[0] * K, x1 * K, CAJA_Y[1] * K], fill=(26, 24, 36, 235), outline=(52, 50, 66, 255),
                width=K)
ETIQ = [('BOLSAS', 'RECOGIDAS'), ('BOLSAS', 'PERDIDAS'), ('CAÍDAS', 'DEL EQUIPO'), ('NOTA', 'DE LA RONDA')]
for (x0, x1), (a, b) in zip(CASILLAS, ETIQ):
    cx = (x0 + x1) / 2
    letras(a, 11, (cx, 300), 'mm', esp=1.5)
    letras(b, 11, (cx, 315), 'mm', esp=1.5)


def monedas(cx, cy, oro):
    """Montón de monedas (el icono de la bolsa de Dark Moon), dorado o gris."""
    c1, c2, c3 = ((255, 205, 70), (190, 130, 20), (255, 240, 170)) if oro else ((150, 152, 160), (90, 92, 100),
                                                                             (205, 207, 215))
    pilas = [(-14, 10, 4), (0, 6, 6), (14, 12, 3)]
    for dx, base, n in pilas:
        for i in range(n):
            y = cy + base - i * 5
            d.ellipse([(cx + dx - 11) * K, (y - 4) * K, (cx + dx + 11) * K, (y + 4) * K], fill=c2 + (255,))
            d.ellipse([(cx + dx - 11) * K, (y - 6) * K, (cx + dx + 11) * K, (y + 2) * K], fill=c1 + (255,),
                      outline=c2 + (255,), width=K)
        y = cy + base - (n - 1) * 5
        d.ellipse([(cx + dx - 6) * K, (y - 4) * K, (cx + dx + 2) * K, (y - 1) * K], fill=c3 + (200,))


monedas(86, 360, True)
monedas(230, 360, False)
# Lápida con sitio para el número (texttag encima, centro y 393).
lx = 374
d.rounded_rectangle([(lx - 40) * K, 424 * K, (lx + 40) * K, 438 * K], radius=2 * K, fill=(95, 98, 108, 255))
d.rounded_rectangle([(lx - 32) * K, 354 * K, (lx + 32) * K, 428 * K], radius=4 * K, fill=(150, 154, 164, 255),
                    outline=(80, 82, 92, 255), width=2 * K)
d.pieslice([(lx - 32) * K, 334 * K, (lx + 32) * K, 382 * K], 180, 360, fill=(150, 154, 164, 255))
d.arc([(lx - 32) * K, 334 * K, (lx + 32) * K, 382 * K], 180, 360, fill=(80, 82, 92, 255), width=2 * K)
d.rounded_rectangle([(lx - 22) * K, 374 * K, (lx + 22) * K, 414 * K], radius=3 * K, fill=(110, 114, 124, 255))

img.resize((512, 512), Image.Resampling.LANCZOS).save(OUT / 'PuntCuadro.png')
blp(Image.open(OUT / 'PuntCuadro.png'), OUT / 'PuntCuadro.blp')
E = {'etiquetas': [{'id': 'DSP3', 'nombre': 'PuntCuadro'}],
     'cuadro': {'w': W, 'h': H, 'x0': 960 - W / 2, 'y0': 145, 'tam_fila': TAM_FILA, 'filas': FILAS, 'cols': COLS,
                'casillas': CASILLAS, 'num_y': 418, 'lapida': [lx, 393], 'estrellas_y': 372}}
(OUT / 'etiquetas.json').write_text(json.dumps(E, ensure_ascii=False, indent=1))
print('PuntCuadro 512 × 512 para', W, '×', H, 'px; filas', [round(y, 1) for y in FILAS])
