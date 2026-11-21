#!/usr/bin/env python3
"""Texturas de la presentación de jefe v17i (14/11/2026), recursos_v17h.py con ráfagas más gruesas y más halo en el rayo, dibujadas aquí (no se copian del vídeo de referencia).

Leon (14/11/2026) con un vídeo de presentación de jefe: "a cambio del texto japones va el nombre del boss de ronda ...
se dibuja tambien como un rayo al centro ... si puedes recrear esos materiales como oscurecer algo el fondo y esas
rafagas de viento".

Todas en potencia de dos y con la proporción de dibujo <= 11 (tope de los dummies 'uidb'/'uidg'):
- JefeOscuro 64x64: azul casi negro opaco; el script le da el alfa (fondo oscurecido, 'uidb').
- JefeRafaga 512x64: línea fina blanca azulada con puntas que se desvanecen ('uidg', aditiva); se dibuja con
  proporción 10, así la línea engorda un poco en las ráfagas largas.
- JefeBarra 512x64: franja de brillo bajo el nombre, fuerte a la izquierda y apagándose a la derecha ('uidg').
- JefeAviso 512x64: "WARNING" rojo en cursiva gruesa con subrayado ('uidb').
- JefeNombre2..10 512x64: nombre del jefe de la ronda 2..10, blanco con borde y halo rosa ('uidb').
- JefeRayo1..5 256x512: el rayo del centro cuadro a cuadro: tajo recto, tres trazos ondulados y chispas sueltas
  ('uidg').
v17i, tras la prueba de Leon ("hace falta reforzar las rafagas"): la ráfaga pasa de un núcleo de 1,1 px a 2 px con
halo más ancho; el rayo, de halo de 5 px a 9 px y el doble de brillo de halo, rosado.
Uso (python con numpy y Pillow): recursos_v17i.py SALIDA_DIR
"""
from pathlib import Path
import math, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont
sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts')
from grid import blp

NOMBRES = ['Makrura Prawn', 'Sea Turtle Hatchling', "Mur'gul Tidewarrior", "Mur'gul Snarecaster", 'Makrura Deepseer',
           'Murloc Mutant', 'Naga Siren', 'Gargantuan Sea Turtle', 'Dragon Turtle']
F_AVISO = '/usr/share/fonts/TTF/FiraSansCompressed-HeavyItalic.ttf'
F_NOMBRE = '/usr/share/fonts/TTF/FiraSansCondensed-SemiBoldItalic.ttf'

out = Path(sys.argv[1])
out.mkdir(parents=True, exist_ok=True)


def guardar(im, nombre):
    im.save(out / f'{nombre}.png')
    blp(im, out / f'{nombre}.blp')


def aditiva(lum, color):
    """Textura aditiva: RGB = color x luminancia, alfa = luminancia."""
    lum = np.clip(lum, 0, 1)
    rgba = np.zeros(lum.shape + (4,), 'uint8')
    for c in range(3):
        rgba[..., c] = (lum * color[c]).round().astype('uint8')
    rgba[..., 3] = (lum * 255).round().astype('uint8')
    return Image.fromarray(rgba, 'RGBA')


# --- fondo ---
guardar(Image.new('RGBA', (64, 64), (11, 16, 34, 255)), 'JefeOscuro')

# --- ráfaga: núcleo de 1,5 px y halo, puntas de 12 % ---
y = np.arange(64) + 0.5
x = (np.arange(512) + 0.5) / 512
v = np.exp(-((y - 32) / 2.0) ** 2) + 0.5 * np.exp(-((y - 32) / 6.0) ** 2)
h = np.clip(np.minimum(x, 1 - x) / 0.12, 0, 1) ** 1.5
guardar(aditiva(v[:, None] * h[None, :], (200, 220, 255)), 'JefeRafaga')

# --- franja del nombre ---
v = np.exp(-((y - 32) / 2.2) ** 2) + 0.45 * np.exp(-((y - 32) / 7) ** 2)
h = np.clip((1 - x) / 0.45, 0, 1) ** 1.3 * np.clip(x / 0.02, 0, 1)
guardar(aditiva(0.8 * v[:, None] * h[None, :], (255, 250, 255)), 'JefeBarra')


# --- WARNING ---
def texto_ajustado(fuente, texto, alto, ancho_max):
    t = alto
    while True:
        f = ImageFont.truetype(fuente, t)
        b = f.getbbox(texto)
        if b[2] - b[0] <= ancho_max:
            return f, b
        t -= 1


K = 4  # dibujo a 4x y reducción, para bordes suaves
im = Image.new('RGBA', (512 * K, 64 * K), (0, 0, 0, 0))
d = ImageDraw.Draw(im)
f, b = texto_ajustado(F_AVISO, 'WARNING', 62 * K, 470 * K)
tx, ty = 14 * K - b[0], 4 * K - b[1]
sombra = Image.new('RGBA', im.size, (0, 0, 0, 0))
ImageDraw.Draw(sombra).text((tx, ty), 'WARNING', font=f, fill=(70, 0, 0, 200), stroke_width=3 * K,
                            stroke_fill=(70, 0, 0, 200))
im.alpha_composite(sombra.filter(ImageFilter.GaussianBlur(2 * K)))
d = ImageDraw.Draw(im)
d.text((tx, ty), 'WARNING', font=f, fill=(232, 20, 28, 255))
ancho = b[2] - b[0]
d.polygon([(8 * K, 54 * K), (14 * K + ancho + 10 * K, 54 * K), (14 * K + ancho + 8 * K, 58 * K), (6 * K, 58 * K)],
          fill=(232, 20, 28, 255))
guardar(im.resize((512, 64), Image.LANCZOS), 'JefeAviso')

# --- nombres ---
for k, nombre in enumerate(NOMBRES):
    im = Image.new('RGBA', (512 * K, 64 * K), (0, 0, 0, 0))
    f, b = texto_ajustado(F_NOMBRE, nombre, 44 * K, 470 * K)
    tx, ty = 14 * K - b[0], (64 * K - (b[3] - b[1])) // 2 - b[1]
    halo = Image.new('RGBA', im.size, (0, 0, 0, 0))
    ImageDraw.Draw(halo).text((tx, ty), nombre, font=f, fill=(255, 60, 160, 255), stroke_width=5 * K,
                              stroke_fill=(255, 60, 160, 255))
    im.alpha_composite(halo.filter(ImageFilter.GaussianBlur(3 * K)))
    d = ImageDraw.Draw(im)
    d.text((tx, ty), nombre, font=f, fill=(255, 255, 255, 255), stroke_width=int(1.5 * K),
           stroke_fill=(255, 90, 175, 255))
    guardar(im.resize((512, 64), Image.LANCZOS), f'JefeNombre{k + 2}')


# --- rayo: 5 cuadros ---
def curva(puntos, n=200):
    """Catmull-Rom por los puntos."""
    p = [puntos[0]] + puntos + [puntos[-1]]
    out = []
    for i in range(1, len(p) - 2):
        p0, p1, p2, p3 = (np.array(q, float) for q in p[i - 1:i + 3])
        for t in np.linspace(0, 1, n // (len(p) - 3), endpoint=False):
            out.append(0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t
                              + (-p0 + 3 * p1 - 3 * p2 + p3) * t ** 3))
    out.append(np.array(puntos[-1], float))
    return [tuple(q) for q in out]


def trazo(d, pts, ancho):
    d.line(pts, fill=255, width=ancho, joint='curve')
    r = ancho / 2
    for q in (pts[0], pts[-1]):
        d.ellipse((q[0] - r, q[1] - r, q[0] + r, q[1] + r), fill=255)


def cuadro(trazos, nombre):
    """trazos: [(puntos en 0..1 del cuadro 256x512, ancho del núcleo en px, ¿curva?)]."""
    W, H = 256 * K, 512 * K
    nucleo = Image.new('L', (W, H), 0)
    d = ImageDraw.Draw(nucleo)
    for pts, ancho, suave in trazos:
        p = [(a * W, b * H) for a, b in pts]
        trazo(d, curva(p) if suave else p, int(ancho * K))
    halo = nucleo.filter(ImageFilter.GaussianBlur(9 * K))
    n = np.asarray(nucleo.resize((256, 512), Image.LANCZOS), float) / 255
    g = np.asarray(halo.resize((256, 512), Image.LANCZOS), float) / 255
    lum = np.clip(n + 3.2 * g, 0, 1)
    # núcleo blanco, halo rosado
    rgba = np.zeros((512, 256, 4), 'uint8')
    mezcla = np.clip(n * 1.5, 0, 1)
    for c, (blanco, rosa) in enumerate(((255, 255), (255, 150), (255, 220))):
        rgba[..., c] = (lum * (blanco * mezcla + rosa * (1 - mezcla))).round().astype('uint8')
    rgba[..., 3] = (lum * 255).round().astype('uint8')
    guardar(Image.fromarray(rgba, 'RGBA'), nombre)


cuadro([([(0.18, 1.0), (0.82, 0.0)], 3.5, False)], 'JefeRayo1')
cuadro([([(0.62, 0.0), (0.70, 0.12), (0.48, 0.22), (0.72, 0.36), (0.58, 0.50), (0.30, 0.62), (0.22, 0.74),
          (0.36, 0.80), (0.30, 0.90)], 9.0, True),
        ([(0.24, 0.94), (0.18, 0.98), (0.24, 1.0)], 5.0, True)], 'JefeRayo2')
cuadro([([(0.52, 0.0), (0.56, 0.06), (0.40, 0.18), (0.70, 0.28), (0.84, 0.34), (0.62, 0.44), (0.40, 0.52),
          (0.26, 0.62), (0.38, 0.70), (0.30, 0.80)], 9.0, True),
        ([(0.44, 0.40), (0.36, 0.46), (0.42, 0.50)], 2.0, True),
        ([(0.30, 0.84), (0.26, 0.92), (0.34, 0.96)], 5.0, True)], 'JefeRayo3')
cuadro([([(0.74, 0.08), (0.66, 0.02), (0.86, 0.10), (0.92, 0.22), (0.66, 0.34), (0.52, 0.46), (0.60, 0.56),
          (0.50, 0.70), (0.58, 0.80), (0.46, 0.88), (0.40, 0.96)], 7.0, True),
        ([(0.58, 0.78), (0.70, 0.84), (0.66, 0.90)], 2.0, True),
        ([(0.40, 0.86), (0.30, 0.90), (0.36, 0.95)], 4.5, True)], 'JefeRayo4')
chispas = []
for (cx, cy, rr, a0, a1) in ((0.60, 0.10, 0.06, 200, 320), (0.70, 0.30, 0.05, 30, 150), (0.45, 0.55, 0.05, 250, 360),
                             (0.40, 0.80, 0.07, 120, 230), (0.62, 0.78, 0.05, 300, 400), (0.30, 0.93, 0.04, 0, 110)):
    chispas.append(([(cx + rr * math.cos(math.radians(a)), cy + rr * 0.5 * math.sin(math.radians(a)))
                     for a in np.linspace(a0, a1, 7)], 3.5, True))
cuadro(chispas, 'JefeRayo5')
print('ok', len(list(out.glob('*.blp'))), 'texturas')
