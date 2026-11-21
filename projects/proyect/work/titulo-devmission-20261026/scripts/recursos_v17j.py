#!/usr/bin/env python3
"""Texturas de la presentación de jefe v17j (14/11/2026): recursos_v17i.py con el WARNING del vídeo de referencia, el
nombre en la fuente y los colores del HUD, ráfagas y franja como las del vídeo y el rayo en el ritmo del vídeo.

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
v17j, con Leon tras probar v17i: "el warning traigamos el de la misma fuente del video"; "a la fuente del nombre ...
dale una mejor fuente y paleta de colores de nuestro HUD"; "las rafagas en esa muestra son como algo mas anchas, y hay
una grande al centro que va a la par con el nombre".
- JefeAviso: el WARNING de fuentes/presentacion/jefe/warning-mediana.png (mediana de 30 cuadros del vídeo, ver su
  LEEME), separado del fondo por el rojo y en rojo liso.
- JefeNombre2..10: Friz Quadrata (FRIZQT__.ttf, la del texto del juego y del HUD), relleno blanco a celeste del HUD
  (199, 247, 255), borde azul marino y halo azul.
- JefeRafaga: núcleo plano de unos 6 px con bordes suaves, gris lavanda, como las del vídeo.
- JefeBarra: banda ancha (unos 45 px en pantalla) y suave detrás del nombre, fuerte a la izquierda.
- Rayo: JefeRayo1 tajo recto grueso, JefeRayo2 grieta fina, JefeRayo3 y JefeRayo4 dos rayos ondulados distintos,
  JefeRayo5 chispas.
Uso (python con numpy y Pillow): recursos_v17j.py SALIDA_DIR
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
F_NOMBRE = '/home/snz/Documentos/ChatGPT/Proyect/work/tienda-mejoras-20261105/FRIZQT__.ttf'
RAIZ = Path(__file__).resolve().parent.parent

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
v = 0.85 * np.clip((4.0 - np.abs(y - 32)) / 1.5, 0, 1) + 0.25 * np.exp(-((y - 32) / 7.0) ** 2)
h = np.clip(np.minimum(x, 1 - x) / 0.15, 0, 1) ** 1.3
guardar(aditiva(v[:, None] * h[None, :], (215, 215, 240)), 'JefeRafaga')

# --- franja del nombre ---
v = 0.75 * np.clip((15.0 - np.abs(y - 32)) / 6.0, 0, 1) + 0.25 * np.exp(-((y - 32) / 5.0) ** 2)
h = np.clip((1 - x) / 0.6, 0, 1) ** 1.2 * np.clip(x / 0.03, 0, 1)
guardar(aditiva(v[:, None] * h[None, :], (235, 228, 255)), 'JefeBarra')


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
ref = np.asarray(Image.open(RAIZ / 'fuentes/presentacion/jefe/warning-mediana.png').convert('RGB'), float)
rojo = np.clip((ref[..., 0] - np.maximum(ref[..., 1], ref[..., 2]) - 25) / 110, 0, 1)
ys, xs = np.where(rojo > 0.3)
rojo = rojo[ys.min() - 2:ys.max() + 3, xs.min() - 2:xs.max() + 3]
alto = 62
ancho = round(rojo.shape[1] * alto / rojo.shape[0])
a = np.asarray(Image.fromarray((rojo * 255).round().astype('uint8'), 'L').resize((ancho, alto), Image.LANCZOS))
rgba = np.zeros((64, 512, 4), 'uint8')
rgba[1:1 + alto, 10:10 + ancho, 0] = 238
rgba[1:1 + alto, 10:10 + ancho, 1] = 16
rgba[1:1 + alto, 10:10 + ancho, 2] = 20
rgba[1:1 + alto, 10:10 + ancho, 3] = a
guardar(Image.fromarray(rgba, 'RGBA'), 'JefeAviso')

# --- nombres: Friz Quadrata con los colores del HUD ---
grad = np.linspace(0, 1, 64 * K)[:, None]
for k, nombre in enumerate(NOMBRES):
    f, b = texto_ajustado(F_NOMBRE, nombre, 42 * K, 470 * K)
    tx, ty = 16 * K - b[0], (64 * K - (b[3] - b[1])) // 2 - b[1]
    im = Image.new('RGBA', (512 * K, 64 * K), (0, 0, 0, 0))
    halo = Image.new('RGBA', im.size, (0, 0, 0, 0))
    ImageDraw.Draw(halo).text((tx, ty), nombre, font=f, fill=(40, 140, 255, 230), stroke_width=6 * K,
                              stroke_fill=(40, 140, 255, 230))
    im.alpha_composite(halo.filter(ImageFilter.GaussianBlur(4 * K)))
    borde = Image.new('RGBA', im.size, (0, 0, 0, 0))
    ImageDraw.Draw(borde).text((tx, ty), nombre, font=f, fill=(8, 24, 64, 255), stroke_width=int(2.5 * K),
                               stroke_fill=(8, 24, 64, 255))
    im.alpha_composite(borde)
    mascara = Image.new('L', im.size, 0)
    ImageDraw.Draw(mascara).text((tx, ty), nombre, font=f, fill=255, stroke_width=int(0.6 * K), stroke_fill=255)
    color = (np.array((255, 255, 255)) * (1 - grad[..., None]) + np.array((199, 247, 255)) * grad[..., None])
    relleno = np.zeros((64 * K, 512 * K, 4), 'uint8')
    relleno[..., :3] = np.broadcast_to(color, (64 * K, 512 * K, 3)).round().astype('uint8')
    relleno[..., 3] = np.asarray(mascara)
    im.alpha_composite(Image.fromarray(relleno, 'RGBA'))
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
    lum = np.clip(n + 2.6 * g, 0, 1)
    # núcleo blanco, halo rosado
    rgba = np.zeros((512, 256, 4), 'uint8')
    mezcla = np.clip(n * 1.5, 0, 1)
    for c, (blanco, rosa) in enumerate(((255, 255), (255, 150), (255, 220))):
        rgba[..., c] = (lum * (blanco * mezcla + rosa * (1 - mezcla))).round().astype('uint8')
    rgba[..., 3] = (lum * 255).round().astype('uint8')
    guardar(Image.fromarray(rgba, 'RGBA'), nombre)


cuadro([([(0.16, 1.0), (0.84, 0.0)], 7.0, False)], 'JefeRayo1')
cuadro([([(0.20, 1.0), (0.27, 0.86), (0.33, 0.80), (0.38, 0.64), (0.46, 0.56), (0.50, 0.40), (0.60, 0.30),
          (0.64, 0.16), (0.74, 0.08), (0.80, 0.0)], 2.0, False)], 'JefeRayo2')
cuadro([([(0.62, 0.0), (0.70, 0.12), (0.48, 0.22), (0.72, 0.36), (0.58, 0.50), (0.30, 0.62), (0.22, 0.74),
          (0.36, 0.80), (0.30, 0.90)], 7.0, True),
        ([(0.24, 0.94), (0.18, 0.98), (0.24, 1.0)], 4.0, True)], 'JefeRayo3')
cuadro([([(0.92, 0.04), (0.80, 0.0), (0.70, 0.08), (0.84, 0.20), (0.62, 0.30), (0.40, 0.36), (0.30, 0.46),
          (0.52, 0.54), (0.48, 0.66), (0.30, 0.76), (0.40, 0.86), (0.28, 0.96)], 6.0, True),
        ([(0.48, 0.66), (0.62, 0.72), (0.58, 0.80)], 2.0, True),
        ([(0.40, 0.86), (0.50, 0.92), (0.46, 0.98)], 3.0, True)], 'JefeRayo4')
chispas = []
for (cx, cy, rr, a0, a1) in ((0.60, 0.10, 0.06, 200, 320), (0.70, 0.30, 0.05, 30, 150), (0.45, 0.55, 0.05, 250, 360),
                             (0.40, 0.80, 0.07, 120, 230), (0.62, 0.78, 0.05, 300, 400), (0.30, 0.93, 0.04, 0, 110)):
    chispas.append(([(cx + rr * math.cos(math.radians(a)), cy + rr * 0.5 * math.sin(math.radians(a)))
                     for a in np.linspace(a0, a1, 7)], 3.5, True))
cuadro(chispas, 'JefeRayo5')
print('ok', len(list(out.glob('*.blp'))), 'texturas')
