"""Recursos de la tienda de v14a (01/11/2026), sin tocar ningún mapa.

Genera en v14a-recursos/: retrato del golem (render por software del RockGolem.mdx del juego, en pose de
reposo), iconos BTN de 64 para las siete categorías (siluetas del prototipo), barra de blindaje vacía y
textura del cono del cuchillo. Texturas potencia de dos, máximo 512.

Uso (con el python de plot-env): tienda_recursos.py W3_EXTRAIDO SALIDA
"""
from pathlib import Path
import struct, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts')
from grid import blp

W3, OUT = Path(sys.argv[1]), Path(sys.argv[2])
PROT = Path('/home/snz/Documentos/ChatGPT/Proyect/work/tienda-prototipo-20261101/texturas')
CATS = ['pistola', 'subfusil', 'rifle', 'francotirador', 'escopeta', 'melee', 'granada']


def geosets(path):
    """Vértices, UV y triángulos de cada GEOS de un MDX."""
    b = path.read_bytes()
    i, out = 4, []
    while i < len(b):
        t, n = b[i:i + 4], struct.unpack_from('<I', b, i + 4)[0]
        if t == b'GEOS':
            k, end = i + 8, i + 8 + n
            while k < end:
                size = struct.unpack_from('<I', b, k)[0]
                g, q = {}, k + 4
                q0 = k + size
                assert b[q:q + 4] == b'VRTX'
                c = struct.unpack_from('<I', b, q + 4)[0]; q += 8
                g['v'] = np.frombuffer(b, '<f4', c * 3, q).reshape(-1, 3); q += c * 12
                assert b[q:q + 4] == b'NRMS'
                c = struct.unpack_from('<I', b, q + 4)[0]; q += 8
                g['n'] = np.frombuffer(b, '<f4', c * 3, q).reshape(-1, 3); q += c * 12
                assert b[q:q + 4] == b'PTYP'
                c = struct.unpack_from('<I', b, q + 4)[0]; q += 8 + c * 4
                assert b[q:q + 4] == b'PCNT'
                c = struct.unpack_from('<I', b, q + 4)[0]; q += 8 + c * 4
                assert b[q:q + 4] == b'PVTX'
                c = struct.unpack_from('<I', b, q + 4)[0]; q += 8
                g['f'] = np.frombuffer(b, '<u2', c, q).reshape(-1, 3)
                u = b.index(b'UVBS', q, q0)
                c = struct.unpack_from('<I', b, u + 4)[0]
                g['uv'] = np.frombuffer(b, '<f4', c * 2, u + 8).reshape(-1, 2)
                out.append(g)
                k = q0
        i += 8 + n
    return out


def retrato(size=(660, 536)):
    tex = np.asarray(Image.open(W3 / 'Units/Creeps/RockGolem/RockGolem2.blp').convert('RGB'), float) / 255
    th, tw = tex.shape[:2]
    W, H = size
    z = np.full((H, W), 1e9)
    img = np.zeros((H, W, 3))
    yaw = np.radians(28)
    rot = np.array([[np.cos(yaw), -np.sin(yaw), 0], [np.sin(yaw), np.cos(yaw), 0], [0, 0, 1]])
    gs = geosets(W3 / 'Units/Creeps/RockGolem/RockGolem.mdx')
    vs = np.concatenate([g['v'] for g in gs])
    top = vs[:, 2].max()
    light = np.array([0.75, 0.25, 0.6]); light /= np.linalg.norm(light)
    # Encuadre de retrato: pecho y cabeza.
    cz = top * 0.80
    span = top * 0.33
    dist = top * 3
    for g in gs:
        v = g['v'] @ rot.T
        n = g['n'] @ rot.T
        depth = dist - v[:, 0]
        f = dist / depth * (H / 2) / span
        sx = W / 2 + v[:, 1] * f
        sy = H / 2 - (v[:, 2] - cz) * f
        for a, b_, c in g['f']:
            xs, ys = sx[[a, b_, c]], sy[[a, b_, c]]
            x0, x1 = int(max(0, xs.min())), int(min(W - 1, xs.max()) + 1)
            y0, y1 = int(max(0, ys.min())), int(min(H - 1, ys.max()) + 1)
            if x0 >= x1 or y0 >= y1:
                continue
            area = (xs[1] - xs[0]) * (ys[2] - ys[0]) - (xs[2] - xs[0]) * (ys[1] - ys[0])
            if abs(area) < 1e-6:
                continue
            X, Y = np.meshgrid(np.arange(x0, x1), np.arange(y0, y1))
            w1 = ((X - xs[0]) * (ys[2] - ys[0]) - (xs[2] - xs[0]) * (Y - ys[0])) / area
            w2 = ((xs[1] - xs[0]) * (Y - ys[0]) - (X - xs[0]) * (ys[1] - ys[0])) / area
            w0 = 1 - w1 - w2
            m = (w0 >= 0) & (w1 >= 0) & (w2 >= 0)
            if not m.any():
                continue
            d = w0 * depth[a] + w1 * depth[b_] + w2 * depth[c]
            m &= d < z[y0:y1, x0:x1]
            if not m.any():
                continue
            uv = (w0[..., None] * g['uv'][a] + w1[..., None] * g['uv'][b_] + w2[..., None] * g['uv'][c])
            tx = (uv[..., 0] % 1 * tw).astype(int) % tw
            ty = (uv[..., 1] % 1 * th).astype(int) % th
            nor = w0[..., None] * n[a] + w1[..., None] * n[b_] + w2[..., None] * n[c]
            nor /= np.maximum(np.linalg.norm(nor, axis=-1, keepdims=True), 1e-6)
            sh = 0.30 + 0.80 * np.clip(nor @ light, 0, 1)
            col = tex[ty, tx] * sh[..., None]
            z[y0:y1, x0:x1][m] = d[m]
            img[y0:y1, x0:x1][m] = col[m]
    # Fondo azul oscuro de la ventana, como en la maqueta.
    gy = np.linspace(0.20, 0.05, H)[:, None]
    fondo = np.stack([gy * 0.35, gy * 0.55, gy], -1).repeat(W, 1)
    img = np.where((z < 1e9)[..., None], img, fondo)
    return Image.fromarray((np.clip(img, 0, 1) * 255).astype('uint8')).convert('RGBA')


def boton(cat):
    src = Image.open(PROT / f'Arma-{cat}.png').convert('RGBA')
    bg = Image.new('RGBA', (64, 64), (16, 22, 34, 255))
    d = ImageDraw.Draw(bg)
    d.rectangle((0, 0, 63, 63), outline=(120, 170, 215, 255), width=2)
    src = src.crop(src.getbbox())
    r = min(54 / src.width, 44 / src.height)
    im = src.resize((max(1, round(src.width * r)), max(1, round(src.height * r))), Image.Resampling.LANCZOS)
    bg.alpha_composite(im, ((64 - im.width) // 2, (64 - im.height) // 2))
    return bg


def barra():
    im = Image.new('RGBA', (256, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((1, 1, 254, 30), 4, fill=(8, 14, 24, 215), outline=(150, 200, 235, 255), width=2)
    d.rectangle((6, 7, 249, 24), fill=(18, 28, 42, 255))
    return im


def cono(n=256, grados=120):
    """Vértice en el centro, abre hacia +u (derecha de la imagen)."""
    y, x = np.mgrid[0:n, 0:n] + 0.5
    x, y = x / n - 0.5, y / n - 0.5
    r = np.hypot(x, y) * 2
    a = np.degrees(np.abs(np.arctan2(y, x)))
    medio = grados / 2
    borde = np.clip((medio - a) / 3, 0, 1) * np.clip((0.985 - r) * 60, 0, 1)
    fino = (np.clip(1 - np.abs(a - medio) / 2.2, 0, 1) + np.clip(1 - np.abs(r - 0.96) * 70, 0, 1)) * (r <= 0.99) * (a <= medio + 1)
    alpha = borde * (0.10 + 0.20 * r) + np.clip(fino, 0, 1) * 0.65
    rgba = np.zeros((n, n, 4))
    rgba[..., 0], rgba[..., 1], rgba[..., 2] = 0.45, 0.85, 1.0
    rgba[..., 3] = np.clip(alpha, 0, 1)
    return Image.fromarray((rgba * 255).astype('uint8'), 'RGBA')


def guardar(nombre, im):
    im.save(OUT / f'{nombre}.png')
    blp(im, OUT / f'{nombre}.blp')


OUT.mkdir(exist_ok=True)
r = retrato()
r.save(OUT / 'golem-vista.png')
guardar('ShopGolem', r.resize((512, 512), Image.Resampling.LANCZOS))
for i, c in enumerate(CATS):
    guardar(f'BTNArma{i}', boton(c))
guardar('HudBlindaje', barra())
guardar('ConoCuchillo', cono())
