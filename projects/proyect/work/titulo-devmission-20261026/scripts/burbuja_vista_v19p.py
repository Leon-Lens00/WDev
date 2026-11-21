"""Vista previa aproximada (estática, sin animaciones de textura) de la burbuja v19p sobre tres cartas, teñida.
Invierte la deformación de burbuja_v19p.py: cada píxel vuelve al disco original y se mira si cae en una pieza.
Uso: plot-env python burbuja_vista_v19p.py DIR_TEX TIENDA_ESFERA_MDX BRILLO_GRIS_BLP SALIDA_PNG"""
import sys, struct
import numpy as np
from PIL import Image, ImageDraw
sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026/scripts')
import aro_v19o as a
import burbuja_v19p as bu
T, mdxp, brillo, out = sys.argv[1:5]
texs = ['ping4', 'Stars3', 'Clouds8x8Mod', 'Star7b', 'GenericGlowFaded', 'GenericGlow5', 'Dust5ABlack', 'ShockwaveWater1Black', 'Blue_Glow2', 'GenericGlow2b']
img = {k: np.asarray(Image.open(T + '/' + n + '.blp').convert('RGBA'), dtype=np.float32) / 255 for k, n in enumerate(texs)}
img[8] = np.asarray(Image.open(brillo).convert('RGBA'), dtype=np.float32) / 255
mdx = open(mdxp, 'rb').read()
cs = dict((bytes(t), d) for t, d in a.chunks(mdx))
ALFA = {(0, 0): .5, (0, 1): .44, (0, 2): .7, (1, 3): 0., (1, 4): .8, (1, 5): .6, (1, 6): .5, (1, 7): .08, (2, 0): .65, (3, 0): .07}
mats = []; d = cs[b'MTLS']; q = 0
while q < len(d):
    sz = struct.unpack_from('<I', d, q)[0]; r = q + 12; nl = struct.unpack_from('<I', d, r + 4)[0]; r += 8; L = []
    for _ in range(nl):
        lsz, fm, sh, tid = struct.unpack_from('<IIIi', d, r); L.append((fm, tid, ALFA.get((len(mats), len(L)), 1.))); r += lsz
    mats.append(L); q += sz
d = cs[b'GEOA']; q = 0; col = {}
while q < len(d):
    sz = struct.unpack_from('<I', d, q)[0]; c = bu.gris(*struct.unpack_from('<3f', d, q + 12)); g = struct.unpack_from('<I', d, q + 24)[0]
    col[g] = np.array(c, dtype=np.float32); q += sz
# Máscara de las piezas de los geosets 0 y 1 en el disco original (4 px por unidad).
K, RM = 4, 90
geos = cs[b'GEOS']; o = 0; mask = {}; g = 0
while o < len(geos):
    n = struct.unpack_from('<I', geos, o)[0]; dd = bytes(geos[o:o + n])
    if g in (0, 1):
        partes = a.leer_geoset(dd)[0]
        v = [struct.unpack_from('<3f', partes[b'VRTX'], 12 * i) for i in range(partes[b'VRTXn'])]
        tri = struct.unpack(f'<{partes[b"PVTXn"]}H', partes[b'PVTX'])
        m = Image.new('L', (2 * RM * K, 2 * RM * K)); dr = ImageDraw.Draw(m)
        for i in range(0, len(tri), 3):
            dr.polygon([((v[x][1] + RM) * K, (RM - v[x][2]) * K) for x in tri[i:i + 3]], fill=255)
        mask[g] = np.asarray(m, dtype=np.float32) / 255
    o += n; g += 1
Wd, Hd = 1100, 700
yy, zz = np.meshgrid(np.arange(Wd) - Wd / 2 + .5, -(np.arange(Hd) - Hd / 2 + .5))
base = Image.new('RGBA', (Wd, Hd), (8, 8, 12, 255))
carta = Image.open('texturas-v19o/CuaCarta.png').convert('RGBA').resize((330, 480), Image.LANCZOS)
cxs = [(-360, (100, 230, 40)), (0, (50, 90, 235)), (360, (225, 45, 70))]
for cx, _ in cxs:
    base.alpha_composite(carta, (int(Wd / 2 + cx - 165), int(Hd / 2 - 240)))
dst = np.asarray(base, dtype=np.float32)[..., :3] / 255
def muestra(t, u, v):
    h, w = t.shape[:2]
    x = np.clip((u * w).astype(int), 0, w - 1); y = np.clip((v * h).astype(int), 0, h - 1)
    return t[y, x]
for cx, tinte in cxs:
    y = yy - cx; z = zz / bu.VY
    th = np.arctan2(z, y)
    rho = (np.abs(np.cos(th) / bu.A) ** bu.NS + np.abs(np.sin(th) / bu.B) ** bu.NS) ** (-1 / bu.NS)
    s = bu.R / rho; y0, z0 = y * s, z * s
    tn = np.array(tinte, dtype=np.float32) / 255
    for g in (1, 0, 2):
        if g == 2:
            dentro = (np.abs(y0) <= 76.8) & (np.abs(z0) <= 76.8)
            cob = dentro.astype(np.float32)
        else:
            xi = np.clip(((y0 + RM) * K).astype(int), 0, 2 * RM * K - 1); zi = np.clip(((RM - z0) * K).astype(int), 0, 2 * RM * K - 1)
            cob = mask[g][zi, xi] * (np.hypot(y0, z0) < RM)
        u = 0.5 + a.F[g] * y0; v = 0.5 - a.F[g] * z0
        for fm, tid, k in mats[g]:
            px = muestra(img[tid], u, v); c = px[..., :3] * col[g] * tn; al = px[..., 3:] * cob[..., None] * k
            dst = dst * (1 - al) + c * al if fm == 2 else dst + c * al
Image.fromarray((np.clip(dst, 0, 1) * 255).astype(np.uint8)).save(out)
print(out)
