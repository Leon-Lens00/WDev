#!/usr/bin/env python3
"""v18j (15/11/2026), fase 5: texturas del cuadro de puntuación de fin de ronda.
- 'DSP0' PuntPanel (512 × 256): panel 460 × 230 px de pantalla (escala 512/460 = 256/230). Lleva fondo azul oscuro,
  borde dorado, línea bajo el título y las etiquetas fijas "Bolsas recogidas" y "Caídas del equipo" (Friz a 0,018 ×
  985 px, como las etiquetas de v18f). El título con la ronda y los dos valores son texttags (cambian).
- 'DSP1' PuntEstrella (64 × 64): estrella dorada. 'DSP2' PuntEstrellaVacia: estrella apagada.
Disposición en px de pantalla, panel con esquina en (730, 60) y centro (960, 175), encima del héroe: título arriba,
estrellas en x 900/960/1020 e y 148, filas en y 205 y 250, valores desde x 1060 (v18j.py).
Salida: DIR/PuntPanel.blp, PuntEstrella.blp, PuntEstrellaVacia.blp (+ .png) y DIR/etiquetas.json (id, nombre).
Uso (Pillow de plot-env): puntos_v18j.py FRIZQT__.ttf DIR_SALIDA
"""
from pathlib import Path
import json, math, sys
from PIL import Image, ImageDraw, ImageFont

FUENTE, OUT = sys.argv[1], Path(sys.argv[2])
sys.path.insert(0, "/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts")
sys.argv = [sys.argv[0], "texturas"]
from grid import blp

OUT.mkdir(exist_ok=True)
K = 4
W, H = 460, 230
BLANCO = (235, 240, 245)
ORO = (230, 180, 70)

# Panel a 4× en px de pantalla, luego a 512 × 256.
img = Image.new('RGBA', (W * K, H * K), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
for y in range(H * K):
    t = y / (H * K)
    c = (int(16 + 10 * t), int(22 + 12 * t), int(52 + 22 * t), 225)
    d.line([(0, y), (W * K, y)], fill=c)
mascara = Image.new('L', img.size, 0)
ImageDraw.Draw(mascara).rounded_rectangle([0, 0, W * K - 1, H * K - 1], radius=14 * K, fill=255)
fondo = Image.new('RGBA', img.size, (0, 0, 0, 0))
fondo.paste(img, (0, 0), mascara)
img = fondo
d = ImageDraw.Draw(img)
d.rounded_rectangle([K, K, W * K - 1 - K, H * K - 1 - K], radius=13 * K, outline=ORO + (255,), width=3 * K)
d.line([(24 * K, 50 * K), ((W - 24) * K, 50 * K)], fill=ORO + (160,), width=K)
f = ImageFont.truetype(FUENTE, round(0.018 * 985 * K))
for texto, cy in (('Bolsas recogidas', 145), ('Caídas del equipo', 190)):
    d.text((40 * K, cy * K), texto, font=f, fill=BLANCO + (255,), anchor='lm', stroke_width=1, stroke_fill=BLANCO + (255,))
img.resize((512, 256), Image.Resampling.LANCZOS).save(OUT / 'PuntPanel.png')


def estrella(relleno, borde, brillo):
    s = 64 * K
    im = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    pts = []
    for i in range(10):
        r = (29 if i % 2 == 0 else 12.5) * K
        a = -math.pi / 2 + i * math.pi / 5
        pts.append((s / 2 + r * math.cos(a), s / 2 + 1.5 * K + r * math.sin(a)))
    dd = ImageDraw.Draw(im)
    dd.polygon(pts, fill=relleno + (255,), outline=borde + (255,), width=2 * K)
    if brillo:
        # Mitad superior izquierda más clara.
        luz = Image.new('RGBA', (s, s), (0, 0, 0, 0))
        ImageDraw.Draw(luz).polygon(pts, fill=(255, 245, 190, 110))
        m = Image.new('L', (s, s), 0)
        ImageDraw.Draw(m).polygon([(0, 0), (s, 0), (0, s)], fill=255)
        im.paste(luz, (0, 0), Image.composite(luz.getchannel('A'), Image.new('L', (s, s), 0), m))
        dd = ImageDraw.Draw(im)
        dd.polygon(pts, outline=borde + (255,), width=2 * K)
    return im.resize((64, 64), Image.Resampling.LANCZOS)


estrella((255, 196, 40), (120, 70, 0), True).save(OUT / 'PuntEstrella.png')
estrella((38, 44, 72), (110, 118, 150), False).save(OUT / 'PuntEstrellaVacia.png')
E = [{'id': 'DSP0', 'nombre': 'PuntPanel'}, {'id': 'DSP1', 'nombre': 'PuntEstrella'},
     {'id': 'DSP2', 'nombre': 'PuntEstrellaVacia'}]
for e in E:
    blp(Image.open(OUT / f"{e['nombre']}.png"), OUT / f"{e['nombre']}.blp")
(OUT / 'etiquetas.json').write_text(json.dumps({'etiquetas': E}, ensure_ascii=False, indent=1))
print('texturas:', ', '.join(e['nombre'] for e in E))
