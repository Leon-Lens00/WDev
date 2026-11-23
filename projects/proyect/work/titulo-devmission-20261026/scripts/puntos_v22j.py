#!/usr/bin/env python3
"""v22j (23/11/2026): igual que puntos_v20a.py con la columna de daño más ancha (ver COLS).
v20a (19/11/2026), fase 8: cuadro de resultados para 8 jugadores con puntuación y MVP.
- 'DSP4' PuntTabla (512 × 512) para 600 × 470 px de pantalla: mismo estilo y casillas de abajo que 'DSP3' (v18k),
  con 8 filas de un renglón (texttags de 0,019: 1095 × 0,019 = 20,8 px por fila) y 7 columnas: jugador, bajas,
  élites, daño, bolsas, caídas y puntos.
- 'DSP5' PuntLado (256 × 512) para 300 × 470 px, a la derecha (10 px de separación): cuadro del MVP arriba (dorado) y
  de quien menos puntos hizo abajo (rojo). Sitio libre para el modelo del héroe (v20b).
Disposición (px dentro de cada pieza; pantalla: tabla x = 505 + lx, lado x = 1115 + lx, y = 145 + ly): ver COLS,
FILAS y LADO; v20a.py usa las mismas cifras.
Uso (Pillow de plot-env): puntos_v20a.py FRIZQT__.ttf DIR_SALIDA
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
TAM_FILA = 0.019
PASO = 1095 * TAM_FILA                   # 20,8 px por fila
FILAS = [98 + PASO * k for k in range(8)]
# v22j: la columna de daño pasa de ~60 a ~110 px (cifras de 6-7 dígitos); el nombre cede ~25 px.
COLS = {'JUGADOR': 34, 'BAJAS': 222, 'ÉLITES': 276, 'DAÑO': 350, 'BOLSAS': 436, 'CAÍDAS': 494, 'PUNTOS': 552}
CAJA_Y = (282, 452)
CASILLAS = [(18, 154), (162, 298), (306, 442), (450, 582)]
GRIS = (165, 170, 185)
BLANCO = (240, 238, 232)


def lienzo(w, h):
    img = Image.new('RGBA', (w * K, h * K), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, w * K - 1, h * K - 1], radius=6 * K, fill=(6, 6, 12, 228))
    d.rounded_rectangle([K, K, w * K - 1 - K, h * K - 1 - K], radius=6 * K, outline=(70, 70, 90, 255), width=K)
    return img, d


def letras(d, texto, tam, xy, anchor, color=GRIS, esp=0.):
    f = ImageFont.truetype(FUENTE, round(tam * K))
    if not esp:
        d.text((xy[0] * K, xy[1] * K), texto, font=f, fill=color + (255,), anchor=anchor)
        return
    ancho = sum(f.getlength(c) for c in texto) + esp * K * (len(texto) - 1)
    x = xy[0] * K - (ancho / 2 if anchor[0] == 'm' else 0)
    for c in texto:
        d.text((x, xy[1] * K), c, font=f, fill=color + (255,), anchor='l' + anchor[1])
        x += f.getlength(c) + esp * K


def titulo(img, w, texto, y, tam):
    f = ImageFont.truetype(FUENTE, tam * K)
    sombra = Image.new('L', img.size, 0)
    ImageDraw.Draw(sombra).text((w / 2 * K + 2 * K, y * K + 2 * K), texto, font=f, fill=200, anchor='mm')
    img.paste(Image.new('RGBA', img.size, (0, 0, 0, 255)), (0, 0), sombra.filter(ImageFilter.GaussianBlur(2 * K)))
    d = ImageDraw.Draw(img)
    d.text((w / 2 * K, y * K), texto, font=f, fill=BLANCO + (255,), anchor='mm')
    return d


# --- tabla ---
img, d = lienzo(W, H)
d = titulo(img, W, 'PUNTUACIÓN DE LA RONDA', 36, 30)
for nombre, x in COLS.items():
    letras(d, nombre, 11, (x, 76), 'lm' if nombre == 'JUGADOR' else 'mm', esp=1.)
for k, cy in enumerate(FILAS):
    c = (30, 28, 42, 245) if k % 2 == 0 else (20, 19, 30, 245)
    d.rectangle([20 * K, (cy - PASO / 2) * K, (W - 20) * K, (cy + PASO / 2) * K], fill=c)
d.line([(20 * K, 270 * K), ((W - 20) * K, 270 * K)], fill=(70, 70, 90, 255), width=K)
for x0, x1 in CASILLAS:
    d.rectangle([x0 * K, CAJA_Y[0] * K, x1 * K, CAJA_Y[1] * K], fill=(26, 24, 36, 235), outline=(52, 50, 66, 255),
                width=K)
ETIQ = [('BOLSAS', 'RECOGIDAS'), ('BOLSAS', 'PERDIDAS'), ('CAÍDAS', 'DEL EQUIPO'), ('NOTA', 'DE LA RONDA')]
for (x0, x1), (a, b) in zip(CASILLAS, ETIQ):
    cx = (x0 + x1) / 2
    letras(d, a, 11, (cx, 300), 'mm', esp=1.5)
    letras(d, b, 11, (cx, 315), 'mm', esp=1.5)


def monedas(cx, cy, oro):
    c1, c2, c3 = ((255, 205, 70), (190, 130, 20), (255, 240, 170)) if oro else ((150, 152, 160), (90, 92, 100),
                                                                             (205, 207, 215))
    for dx, base, n in [(-14, 10, 4), (0, 6, 6), (14, 12, 3)]:
        for i in range(n):
            y = cy + base - i * 5
            d.ellipse([(cx + dx - 11) * K, (y - 4) * K, (cx + dx + 11) * K, (y + 4) * K], fill=c2 + (255,))
            d.ellipse([(cx + dx - 11) * K, (y - 6) * K, (cx + dx + 11) * K, (y + 2) * K], fill=c1 + (255,),
                      outline=c2 + (255,), width=K)
        y = cy + base - (n - 1) * 5
        d.ellipse([(cx + dx - 6) * K, (y - 4) * K, (cx + dx + 2) * K, (y - 1) * K], fill=c3 + (200,))


monedas(86, 360, True)
monedas(230, 360, False)
lx = 374
d.rounded_rectangle([(lx - 40) * K, 424 * K, (lx + 40) * K, 438 * K], radius=2 * K, fill=(95, 98, 108, 255))
d.rounded_rectangle([(lx - 32) * K, 354 * K, (lx + 32) * K, 428 * K], radius=4 * K, fill=(150, 154, 164, 255),
                    outline=(80, 82, 92, 255), width=2 * K)
d.pieslice([(lx - 32) * K, 334 * K, (lx + 32) * K, 382 * K], 180, 360, fill=(150, 154, 164, 255))
d.arc([(lx - 32) * K, 334 * K, (lx + 32) * K, 382 * K], 180, 360, fill=(80, 82, 92, 255), width=2 * K)
d.rounded_rectangle([(lx - 22) * K, 374 * K, (lx + 22) * K, 414 * K], radius=3 * K, fill=(110, 114, 124, 255))
img.resize((512, 512), Image.Resampling.LANCZOS).save(OUT / 'PuntTabla.png')
blp(Image.open(OUT / 'PuntTabla.png'), OUT / 'PuntTabla.blp')

# --- lado: MVP y menos puntos ---
LW = 300
LADO = {'mvp': (12, 226), 'menos': (244, 458)}
img, d = lienzo(LW, H)
for (clave, (y0, y1)), borde, etiq, col in (
        (('mvp', LADO['mvp']), (230, 180, 60, 255), 'MVP', (255, 210, 90)),
        (('menos', LADO['menos']), (170, 60, 60, 255), 'MENOS PUNTOS', (255, 120, 110))):
    d.rounded_rectangle([12 * K, y0 * K, (LW - 12) * K, y1 * K], radius=5 * K, fill=(24, 22, 34, 240), outline=borde,
                        width=2 * K)
    letras(d, etiq, 15, (LW / 2, y0 + 20), 'mm', color=col, esp=2.)
img.resize((256, 512), Image.Resampling.LANCZOS).save(OUT / 'PuntLado.png')
blp(Image.open(OUT / 'PuntLado.png'), OUT / 'PuntLado.blp')

E = {'etiquetas': [{'id': 'DSP4', 'nombre': 'PuntTabla'}, {'id': 'DSP5', 'nombre': 'PuntLado'}],
     'tabla': {'w': W, 'h': H, 'x0': 505, 'y0': 145, 'tam_fila': TAM_FILA, 'filas': FILAS, 'cols': COLS},
     'lado': {'w': LW, 'h': H, 'x0': 1115, 'y0': 145, 'cajas': LADO}}
(OUT / 'etiquetas.json').write_text(json.dumps(E, ensure_ascii=False, indent=1))
print('PuntTabla 512 × 512 y PuntLado 256 × 512; filas', [round(y, 1) for y in FILAS])
