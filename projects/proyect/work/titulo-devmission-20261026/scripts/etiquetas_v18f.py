#!/usr/bin/env python3
"""v18f (15/11/2026), fase 3: las 8 etiquetas fijas de la tienda pasan de texttag a textura.

Textos de Shop_Textos que nunca cambian: "Categorías", "Precio", "Daño", "Cargador", "Cadencia", "Precisión", "Oro" y
"Salir (Esc)". Los nombres de categoría no entran: cambian de color al elegirlos (Shop_Elegida/Shop_Pinta).

Medidas (grabación de Leon 20261115_020522, s 62, tienda de v18d abierta, 1919 × 1080):
- Letra: el texttag de 1.27b mide como Friz Quadrata (FRIZQT__.ttf) a ~985 px por unidad de tamaño (Precio 0,02 →
  57 px de ancho; Salir (Esc) 0,024 → 105; Cargador 0,017 → 74).
- Centro de la tinta de cada etiqueta (píxeles claros, min(r, g, b) > 140), que es donde va el centro de su pieza.
- Shop_Pic no cae en sus coordenadas: las 13 gemas 'DS0C' (x 166,5 y 660; y 161 + 66 f y 156 + 58 i) dan
  x_pantalla = AX + BX·px e y_pantalla = AY + BY·py (mínimos cuadrados, abajo). Se invierte para colocar las piezas.
- "Categorías" (0,026) sale más grande que la regla: se ajusta a su ancho medido, 137 px.
- El texttag pinta algo más grueso que Friz: se dibuja a 4× con trazo de 1 (un cuarto de píxel) y se reduce.
Cada textura es 1:1 con la pantalla (potencia de dos, transparente) y la pieza mide su tamaño / BX, / BY.
Salida: DIR/TiendaEt<n>.blp y .png, y DIR/etiquetas.json con id, px, py, w, h por etiqueta.
No lee ni escribe ningún mapa. Uso (Pillow de plot-env): etiquetas_v18f.py FRIZQT__.ttf DIR_SALIDA
"""
from pathlib import Path
import json, sys
from PIL import Image, ImageDraw, ImageFont

FUENTE, OUT = sys.argv[1], Path(sys.argv[2])
sys.path.insert(0, "/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts")
sys.argv = [sys.argv[0], "texturas"]
from grid import blp

OUT.mkdir(exist_ok=True)
PX_POR_TAM = 985.
K = 4
COLOR = (235, 240, 245)          # Shop_Tag: SetTextTagColor(t, 235, 240, 245, 255)
FONDO = (20, 28, 60)             # azul oscuro de los paneles, sólo para medir la tinta como en la captura

# Gemas: (px o py de Shop_Pic, coordenada medida en pantalla).
GX = [(166.5, 147.6), (660., 652.0)]
GY = [(161 + 66 * f, y) for f, y in enumerate([166.5, 232., 299., 367., 433.5, 502., 569.])] + \
     [(156 + 58 * i, y) for i, y in enumerate([159.5, 219., 277.5, 337.5, 396.5, 456.])]


def recta(pts):
    n = len(pts); mx = sum(a for a, _ in pts) / n; my = sum(b for _, b in pts) / n
    b = sum((a - mx) * (c - my) for a, c in pts) / sum((a - mx) ** 2 for a, _ in pts)
    return my - b * mx, b


AX, BX = recta(GX)
AY, BY = recta(GY)
res = max(abs(AY + BY * a - c) for a, c in GY)

# (id, texto, tamaño del texttag, centro medido de la tinta en pantalla)
ETIQUETAS = [('DSE0', 'Categorías', 0.026, 183.0, 112.0), ('DSE1', 'Precio', 0.02, 1178.5, 111.0),
             ('DSE2', 'Daño', 0.017, 974.5, 550.5), ('DSE3', 'Cargador', 0.017, 1186.5, 552.5),
             ('DSE4', 'Cadencia', 0.017, 989.5, 637.0), ('DSE5', 'Precisión', 0.017, 1183.5, 637.5),
             ('DSE6', 'Oro', 0.024, 1465.0, 593.5), ('DSE7', 'Salir (Esc)', 0.024, 283.0, 798.5)]


def p2(n):
    v = 16
    while v < n:
        v *= 2
    return v


def tinta(img):
    """Caja de los píxeles que la medida de la captura cuenta como tinta, sobre el fondo de los paneles."""
    fondo = Image.new('RGB', img.size, FONDO)
    fondo.paste(img, (0, 0), img)
    xs, ys = [], []
    px = fondo.load()
    for y in range(img.size[1]):
        for x in range(img.size[0]):
            r, g, b = px[x, y]
            if min(r, g, b) > 140 and abs(r - b) < 60:
                xs.append(x); ys.append(y)
    return min(xs), min(ys), max(xs), max(ys)


salida = []
for n, (rid, texto, tam, cx, cy) in enumerate(ETIQUETAS):
    px = tam * PX_POR_TAM
    if texto == 'Categorías':
        b = ImageFont.truetype(FUENTE, 100).getbbox(texto)
        px = 100 * 137 / (b[2] - b[0])
    f = ImageFont.truetype(FUENTE, round(px * K))
    b = f.getbbox(texto, stroke_width=1)
    w, h = p2((b[2] - b[0]) / K + 8), p2((b[3] - b[1]) / K + 8)
    img = Image.new('RGBA', (w * K, h * K), COLOR + (0,))
    ImageDraw.Draw(img).text(((w * K - (b[2] - b[0])) / 2 - b[0], (h * K - (b[3] - b[1])) / 2 - b[1]), texto, font=f,
                             fill=COLOR + (255,), stroke_width=1, stroke_fill=COLOR + (255,))
    img = img.resize((w, h), Image.Resampling.LANCZOS)
    # Centrar la tinta medida igual que en la captura en el centro de la textura.
    x0, y0, x1, y1 = tinta(img)
    dx, dy = round(w / 2 - (x0 + x1) / 2), round(h / 2 - (y0 + y1) / 2)
    img = img.transform(img.size, Image.Transform.AFFINE, (1, 0, -dx, 0, 1, -dy))
    x0, y0, x1, y1 = tinta(img)
    nombre = f'TiendaEt{n}'
    img.save(OUT / f'{nombre}.png')
    blp(img, OUT / f'{nombre}.blp')
    salida.append({'id': rid, 'texto': texto, 'nombre': nombre, 'tex': [w, h], 'tinta': [x1 - x0 + 1, y1 - y0 + 1],
                   'px': round((cx - AX) / BX, 1), 'py': round((cy - AY) / BY, 1),
                   'w': round(w / BX, 2), 'h': round(h / BY, 2)})
(OUT / 'etiquetas.json').write_text(json.dumps({'AX': AX, 'BX': BX, 'AY': AY, 'BY': BY, 'resto_y': res,
                                                'etiquetas': salida}, ensure_ascii=False, indent=1))
print(f'x = {AX:.2f} + {BX:.4f} px; y = {AY:.2f} + {BY:.4f} py (resto máx {res:.1f} px)')
for e in salida:
    print(e['id'], e['texto'], e['tex'], 'tinta', e['tinta'], '->', e['px'], e['py'], e['w'], e['h'])
