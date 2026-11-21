#!/usr/bin/env python3
"""v18g (15/11/2026), fase 3, segundo lote: más textos fijos de texttag a textura (método de etiquetas_v18f.py).

- "Elegir" de los botones de los cuadros (Cua_TB, 0,022) y el pie "Esc: salir (se guarda hasta la oleada)" (Cua_TPie,
  0,018): piezas Cua_Pic, misma correspondencia que Shop_Pic (x = AX + BX·px, y = AY + BY·py de etiquetas_v18f).
- Aviso de la tienda (DevTienda_Aviso, 0,026, degradado azul → blanco → rojo letra a letra, 2 variantes): pieza del HUD
  ('uidb' con Arm_Foto, HealthBars__Place a 400) cuyo centro se da en píxeles de pantalla.
Medidas (grabación de Leon 20261115_161557, 1920 × 1080):
- s 42, cuadros abiertos (3): tinta de "Elegir" 58 × 23, centro 0,6 px a la derecha del botón y en y 621; pie 298 de
  ancho, centro (946,5, 737,5).
- s 40,5: "Press [ESC] to buy supplies" de x 774 a 1098 y de y 516 a 539 (con p, y). El texttag empieza en
  960 − 6,882 n (n = 27 → 774,2): la variante "[ESC] Pick up Ammo" (n = 18) empieza 61,9 px más a la derecha.
  El texttag lleva sombra oscura abajo a la derecha (se nota sobre el terreno): se pinta sólo en el aviso.
Salida: DIR/TiendaEt8..11.blp y .png y DIR/etiquetas.json. No lee ni escribe ningún mapa.
Uso (Pillow de plot-env): etiquetas_v18g.py FRIZQT__.ttf DIR_V18F DIR_SALIDA
"""
from pathlib import Path
import json, re, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

FUENTE, V18F, OUT = sys.argv[1], Path(sys.argv[2]), Path(sys.argv[3])
sys.path.insert(0, "/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts")
sys.argv = [sys.argv[0], "texturas"]
from grid import blp

OUT.mkdir(exist_ok=True)
fit = json.loads((V18F / 'etiquetas.json').read_text())
AX, BX, AY, BY = fit['AX'], fit['BX'], fit['AY'], fit['BY']
K = 4
BLANCO = (235, 240, 245)
FONDO = (20, 28, 60)

AVISO = ["|cff73c8ffP|cff7ccbfer|cff85cefde|cff8fd1fds|cff98d4fcs|cffa1d7fb |cffaadafa[|cffb4defaE|cffbde1f9S"
         "|cffc6e4f8C|cffcfe7f7]|cffd9eaf7 |cffe2edf6t|cffebf0f5o|cffede1e6 |cffeed2d7b|cfff0c4c8u|cfff1b5b8y"
         "|cfff3a6a9 |cfff4979as|cfff6898bu|cfff77a7cp|cfff96b6dp|cfffa5c5dl|cfffc4e4ei|cfffd3f3fe|cffff3030s|r",
         "|cff73c8ff[|cff81cdfeE|cff8fd1fdS|cff9dd6fbC|cffabdbfa]|cffbae0f9 |cffc8e4f8P|cffd6e9f7i|cffe4eef6c"
         "|cffece5e9k|cffefced2 |cfff1b8bbu|cfff3a1a4p|cfff68a8d |cfff87476A|cfffa5d5em|cfffd4747m|cffff3030o|r"]


def letras(s):
    return [(c, tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))) for h, c in re.findall(r'\|cff(\w{6})(.)', s)]


def p2(n):
    v = 16
    while v < n:
        v *= 2
    return v


def tinta(img):
    fondo = Image.new('RGB', img.size, FONDO)
    fondo.paste(img, (0, 0), img)
    px = fondo.load()
    xs, ys = [], []
    for y in range(img.size[1]):
        for x in range(img.size[0]):
            r, g, b = px[x, y]
            if max(r, g, b) > 150:
                xs.append(x); ys.append(y)
    return min(xs), min(ys), max(xs), max(ys)


def ancho_tinta(f, texto):
    b = f.getbbox(texto)
    return b[2] - b[0]


def pintar(lets, tam, w, h, pen, sombra):
    """Letras de colores con la pluma (en px de pantalla, línea base) en pen; devuelve la textura w × h."""
    f = ImageFont.truetype(FUENTE, round(tam * K))
    img = Image.new('RGBA', (w * K, h * K), (0, 0, 0, 0))
    if sombra:
        sm = Image.new('L', img.size, 0)
        d = ImageDraw.Draw(sm)
        x = pen[0] * K
        for c, _ in lets:
            d.text((x + 1.2 * K, pen[1] * K + 1.2 * K), c, font=f, fill=200, anchor='ls', stroke_width=K, stroke_fill=200)
            x += f.getlength(c)
        sm = sm.filter(ImageFilter.GaussianBlur(K * 0.6))
        img.paste(Image.new('RGBA', img.size, (0, 0, 8, 255)), (0, 0), sm)
    d = ImageDraw.Draw(img)
    x = pen[0] * K
    for c, col in lets:
        d.text((x, pen[1] * K), c, font=f, fill=col + (255,), anchor='ls', stroke_width=1, stroke_fill=col + (255,))
        x += f.getlength(c)
    return img.resize((w, h), Image.Resampling.LANCZOS)


salida = []

# 1. Aviso: tamaño ajustado al ancho medido (325) de la variante 1.
lets0 = letras(AVISO[0])
t0 = ''.join(c for c, _ in lets0)
f100 = ImageFont.truetype(FUENTE, 100)
tam = 100 * 325 / ancho_tinta(f100, t0)
f = ImageFont.truetype(FUENTE, 100)
b = f.getbbox(t0, anchor='ls')                     # respecto a la pluma (izquierda, línea base) a 100 px
izq0 = b[0] * tam / 100                             # tinta de "P" a la derecha de la pluma
base = 516 - b[1] * tam / 100                       # y de pantalla de la línea base (arriba medida 516)
abajo = base + b[3] * tam / 100
pluma = [774 - izq0, 774 - izq0 + 61.9]
for v, s in enumerate(AVISO):
    lets = letras(s)
    w, h = 512, 64
    # La pluma a 16 px del borde izquierdo de la textura y la línea base a 42 px de arriba.
    img = pintar(lets, tam, w, h, (16, 42), True)
    nombre = f'TiendaEt{9 + v}'
    img.save(OUT / f'{nombre}.png'); blp(img, OUT / f'{nombre}.blp')
    x0, y0, x1, y1 = tinta(img)
    salida.append({'id': f'DSE{"9A"[v]}', 'texto': ''.join(c for c, _ in lets), 'nombre': nombre, 'tex': [w, h],
                   'tinta': [x1 - x0 + 1, y1 - y0 + 1], 'hud': True,
                   'cx': round(pluma[v] - 16 + w / 2, 1), 'cy': round(base - 42 + h / 2, 1), 'w': w, 'h': h})

# 2. "Elegir" y el pie de los cuadros (blancos, sin sombra, como v18f).
for rid, n, texto, tam_tt, ancho, cx, cy, hh in (('DSE8', 8, 'Elegir', 0.022, 58, None, 621., 32),
                                                ('DSEB', 11, 'Esc: salir (se guarda hasta la oleada)', 0.018, 298,
                                                 946.5, 737.5, 64)):
    px = 100 * ancho / ancho_tinta(f100, texto)
    ff = ImageFont.truetype(FUENTE, round(px * K))
    bb = ff.getbbox(texto, stroke_width=1)
    w = p2((bb[2] - bb[0]) / K + 8)
    h = hh
    img = Image.new('RGBA', (w * K, h * K), BLANCO + (0,))
    ImageDraw.Draw(img).text(((w * K - (bb[2] - bb[0])) / 2 - bb[0], (h * K - (bb[3] - bb[1])) / 2 - bb[1]), texto,
                             font=ff, fill=BLANCO + (255,), stroke_width=1, stroke_fill=BLANCO + (255,))
    img = img.resize((w, h), Image.Resampling.LANCZOS)
    x0, y0, x1, y1 = tinta(img)
    dx, dy = round(w / 2 - (x0 + x1) / 2), round(h / 2 - (y0 + y1) / 2)
    img = img.transform(img.size, Image.Transform.AFFINE, (1, 0, -dx, 0, 1, -dy))
    x0, y0, x1, y1 = tinta(img)
    nombre = f'TiendaEt{n}'
    img.save(OUT / f'{nombre}.png'); blp(img, OUT / f'{nombre}.blp')
    e = {'id': rid, 'texto': texto, 'nombre': nombre, 'tex': [w, h], 'tinta': [x1 - x0 + 1, y1 - y0 + 1],
         'py': round((cy - AY) / BY, 1), 'w': round(w / BX, 2), 'h': round(h / BY, 2)}
    if cx is None:
        e['dpx'] = round(0.6 / BX, 1)              # a la derecha del centro del botón (Cua_PX)
    else:
        e['px'] = round((cx - AX) / BX, 1)
    salida.append(e)

(OUT / 'etiquetas.json').write_text(json.dumps({'tam_aviso': tam, 'base_aviso': base, 'abajo_aviso': abajo,
                                                'etiquetas': salida}, ensure_ascii=False, indent=1))
print(f'aviso: {tam:.2f} px, línea base y {base:.1f}, abajo {abajo:.1f} (medido 539)')
for e in salida:
    print(e)
