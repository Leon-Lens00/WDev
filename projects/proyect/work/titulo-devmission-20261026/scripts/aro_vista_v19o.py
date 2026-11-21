"""Vista previa aproximada (estática, KMTA=1, sin animaciones de textura) de la carta con el contorno."""
import sys, struct
from math import pi
import numpy as np
from PIL import Image
sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026/scripts')
import aro_v19o as a
S = sys.argv[1]; color = sys.argv[2]; out = sys.argv[3]
T = S + '/tex/'
texs = ['ping4', 'Stars3', 'Clouds8x8Mod', 'Star7b', 'GenericGlowFaded', 'GenericGlow5', 'Dust5ABlack', 'ShockwaveWater1Black', 'Blue_Glow2', 'GenericGlow2b']
img = {k: np.asarray(Image.open(T + n + '.blp').convert('RGBA'), dtype=np.float32) / 255 for k, n in enumerate(texs)}
if color == 'rojo':
    import colorsys
    t = img[8]; h = t[..., :3].reshape(-1, 3)
    img[8] = np.concatenate([np.array([colorsys.hsv_to_rgb(348 / 360, *colorsys.rgb_to_hsv(*p)[1:]) for p in h]).reshape(t.shape[:2] + (3,)), t[..., 3:]], -1)
mdx = open(f'{S}/aro/CuaAro{"Azul" if color == "azul" else "Rojo"}.mdx', 'rb').read()
cs = dict((bytes(t), d) for t, d in a.chunks(mdx))
ALFA = {(0, 0): .5, (0, 1): .44, (0, 2): .7, (1, 3): 0., (1, 4): .8, (1, 5): .6, (1, 6): .5, (1, 7): .08, (2, 0): .65, (3, 0): .07}
# materiales
mats = []; d = cs[b'MTLS']; q = 0
while q < len(d):
    sz = struct.unpack_from('<I', d, q)[0]; r = q + 12; nl = struct.unpack_from('<I', d, r + 4)[0]; r += 8; L = []
    for _ in range(nl):
        lsz, fm, sh, tid = struct.unpack_from('<IIIi', d, r); L.append((fm, tid, ALFA.get((len(mats), len(L)), 1.))); r += lsz
    mats.append(L); q += sz
d = cs[b'GEOA']; q = 0; col = {}
while q < len(d):
    sz = struct.unpack_from('<I', d, q)[0]; c = struct.unpack_from('<3f', d, q + 12); g = struct.unpack_from('<I', d, q + 24)[0]
    col[g] = np.array(c, dtype=np.float32); q += sz   # GEOA guarda B, G, R
Wd, Hd = 1100, 700
yy, zz = np.meshgrid(np.arange(Wd) - Wd / 2 + .5, -(np.arange(Hd) - Hd / 2 + .5))
# posición sobre el borde base: muestra más cercana
pts, L = a.perimetro(); P = np.array([(p[0], p[1]) for p in pts]); Nn = np.array([(p[2], p[3]) for p in pts])
def mapa(cx):
    y = yy - cx; z = zz
    qx = np.abs(y) - (a.A - a.RC); qz = np.abs(z) - (a.B - a.RC)
    dist = np.hypot(np.maximum(qx, 0), np.maximum(qz, 0)) + np.minimum(np.maximum(qx, qz), 0) - a.RC
    best = np.zeros(y.shape, int); bd = np.full(y.shape, 1e9)
    for i in range(len(P)):
        dd = (y - P[i, 0]) ** 2 + (z - P[i, 1]) ** 2
        m = dd < bd; bd[m] = dd[m]; best[m] = i
    th = 2 * pi * a.VUELTAS * best / a.N
    r = a.R0 + dist / a.M
    return th, r
base = Image.new('RGBA', (Wd, Hd), (8, 8, 12, 255))
carta = Image.open('texturas-v19o/CuaCarta.png').convert('RGBA').resize((330, 480), Image.LANCZOS)
cxs = [-360, 0, 360]
for cx in cxs:
    base.alpha_composite(carta, (int(Wd / 2 + cx - 165), int(Hd / 2 - 240)))
dst = np.asarray(base, dtype=np.float32)[..., :3] / 255
def muestra(t, u, v):
    h, w = t.shape[:2]
    x = np.clip((u * w).astype(int), 0, w - 1); y = np.clip((v * h).astype(int), 0, h - 1)
    return t[y, x]
for cx in cxs:
    th, r = mapa(cx)
    for g in (1, 0, 2):
        r0, r1 = a.RADIOS[g]; dentro = (r >= r0) & (r <= r1)
        u = 0.5 + a.F[g] * r * np.cos(th); v = 0.5 - a.F[g] * r * np.sin(th)
        for fm, tid, k in mats[g]:
            px = muestra(img[tid], u, v); c = px[..., :3] * col[g]; al = px[..., 3:] * dentro[..., None] * k
            if fm == 2:
                dst = dst * (1 - al) + c * al
            else:
                dst = dst + c * al
Image.fromarray((np.clip(dst, 0, 1) * 255).astype(np.uint8)).save(out)
