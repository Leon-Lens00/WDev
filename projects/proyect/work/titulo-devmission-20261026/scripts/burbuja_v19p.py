#!/usr/bin/env python3
"""v19p (19/11/2026): la esfera del indicador como burbuja de la carta: rectángulo alto con puntas redondeadas que
encierra la carta, gris para teñirla con el color de cada carta (Leon: "tomar ese mismo modelo, ajustarlo para que
tenga una forma rectangular alta y cubra bien los cuadros, y colorearlas segun los tonos tier, su forma seria con puntas
redondeadas"). Segunda pasada tras ver el Stand en el visor ("afinemos mas los contornos y esquinas para que el cuadro
quepa bien", "que no se expanda mucho", "hacer los hexagonos mas pequenios").

Entrada: TiendaEsfera.mdx (v14h): la Ubershield aplanada de esfera_v14g.py. Geosets 0 y 1: piezas hexagonales sueltas
en un disco de radio 66 (uv = 0,5 + f·(y, −z)); 2: cuadrado de 153,6 con el anillo ping4 (radio ≈ 66); 3: colapsado.

- Contorno: rectángulo de A × B = 172 × 248 px (medio ancho y medio alto) con esquinas de radio 20; la carta mide
  165 × 240 y queda dentro con 7-8 px de margen en reposo. Cada dirección θ del disco original se lleva a ese contorno
  por escala radial: r = 66 cae justo en el borde (ρ(θ) = distancia del centro al contorno en esa dirección).
- Piezas (geosets 0 y 1): en lugar de las 89 piezas de la esfera, que al estirarse quedaban grandes y deformadas hacia
  el centro, una rejilla regular de hexágonos de 15 px de radio con 18 % de hueco, recortada por el contorno; cada
  vértice toma el uv del punto del disco original del que viene (escala radial inversa), así que brillos, estrellas y
  nubes y sus animaciones siguen igual.
- Anillo (geoset 2): rejilla de 32 × 32 sobre el cuadrado original, llevada al contorno por la misma escala radial.
- Pulso: el ayudante Globe escala 1,0 → 1,1 → 1,0 cada 4 s (secuencia global 3); se conserva el tiempo y el máximo
  baja a PULSO = 1,03 (medio ancho máximo 177 px: entre cartas a 360 px quedan ≥ 5 px).
- Color: los colores de geoset pierden la saturación (× 0,12, mismo brillo) y Blue_Glow2 pasa a una copia gris,
  war3mapImported\\CuaBurbujaBrillo.blp; el juego la tiñe con SetUnitVertexColor.
- Unidades: 1 = 1 px horizontal; vertical × 1,02789 (como aro_v19o.py). Después, mdx_sin_billboard.py y
  aro_v19o.py --extensiones.

Uso: burbuja_v19p.py TIENDA_ESFERA_MDX BLUE_GLOW2_BLP SALIDA_MDX SALIDA_BLP   (BLP con Pillow: plot-env)
"""
from colorsys import hsv_to_rgb, rgb_to_hsv
from math import atan2, cos, hypot, pi, sin, sqrt
from pathlib import Path
import struct
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from aro_v19o import F, chunks, junta, leer_geoset, caja  # noqa: E402

A, B, RC = 172., 248., 20.
R = 66.
VY = 1.02789
HEX, HUECO = 15., .18
PULSO = 1.03
TEXTURA = 'war3mapImported\\CuaBurbujaBrillo.blp'


def gris(r, g, b):
    h, s, v = rgb_to_hsv(r, g, b)
    return hsv_to_rgb(h, s * .12, v)


def rho(t):
    """Distancia del centro al contorno (px) en la dirección t."""
    c, s = abs(cos(t)), abs(sin(t))
    d = min(A / c if c > 1e-9 else 1e9, B / s if s > 1e-9 else 1e9)
    y, z = d * c, d * s
    if y > A - RC and z > B - RC:
        cy, cz = A - RC, B - RC
        bb = c * cy + s * cz
        d = bb + sqrt(bb * bb - (cy * cy + cz * cz - RC * RC))
    return d


def forma(y, z):
    """Disco original (y, z) → px."""
    r = hypot(y, z)
    if r < 1e-9:
        return 0., 0.
    k = rho(atan2(z, y)) / R
    return y * k, z * k


def disco(y, z):
    """px → disco original."""
    r = hypot(y, z)
    if r < 1e-9:
        return 0., 0.
    k = R / rho(atan2(z, y))
    return y * k, z * k


def contorno(n=96):
    """Polígono convexo del contorno (antihorario), para recortar."""
    return [(rho(2 * pi * i / n) * cos(2 * pi * i / n), rho(2 * pi * i / n) * sin(2 * pi * i / n)) for i in range(n)]


def recorta(pol, clip):
    for i in range(len(clip)):
        a, b = clip[i], clip[(i + 1) % len(clip)]
        dentro = lambda p: (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0]) >= 0
        out = []
        for j in range(len(pol)):
            p, q = pol[j], pol[(j + 1) % len(pol)]
            if dentro(p):
                out.append(p)
            if dentro(p) != dentro(q):
                dx, dy = q[0] - p[0], q[1] - p[1]
                ex, ey = b[0] - a[0], b[1] - a[1]
                t = ((a[0] - p[0]) * ey - (a[1] - p[1]) * ex) / (dx * ey - dy * ex)
                out.append((p[0] + t * dx, p[1] + t * dy))
        pol = out
        if not pol:
            break
    return pol


def area(pol):
    return sum(pol[i][0] * pol[(i + 1) % len(pol)][1] - pol[(i + 1) % len(pol)][0] * pol[i][1]
               for i in range(len(pol))) / 2


def piezas():
    """Hexágonos (punta arriba) en px, recortados por el contorno; antihorario."""
    clip = contorno()
    r = HEX * (1 - HUECO)
    hexa = [(r * cos(pi / 6 + k * pi / 3), r * sin(pi / 6 + k * pi / 3)) for k in range(6)]
    lleno = area(hexa)
    dx, dz = sqrt(3) * HEX, 1.5 * HEX
    out = []
    for j in range(-int(B / dz) - 2, int(B / dz) + 3):
        for i in range(-int(A / dx) - 2, int(A / dx) + 3):
            cy, cz = (i + (.5 if j % 2 else 0.)) * dx, j * dz
            pol = recorta([(cy + p[0], cz + p[1]) for p in hexa], clip)
            if len(pol) >= 3 and area(pol) > .3 * lleno:
                out.append(pol)
    return out


def geo_piezas(g):
    v, uv, tri = [], [], []
    for pol in piezas():
        c = (sum(p[0] for p in pol) / len(pol), sum(p[1] for p in pol) / len(pol))
        base = len(v)
        for p in [c] + pol:
            v.append(p)
            y0, z0 = disco(*p)
            uv.append((0.5 + F[g] * y0, 0.5 - F[g] * z0))
        for k in range(len(pol)):
            tri += [base, base + 1 + k, base + 1 + (k + 1) % len(pol)]
    return v, uv, tri


def rejilla(v, uv, n=32):
    """Cuadrado del geoset 2 en n × n (coordenadas del disco), llevado al contorno."""
    lo = [min(p[k] for p in v) for k in (1, 2)]
    hi = [max(p[k] for p in v) for k in (1, 2)]
    u0 = [min(t[k] for t in uv) for k in (0, 1)]
    u1 = [max(t[k] for t in uv) for k in (0, 1)]
    k0 = max(range(4), key=lambda i: v[i][1] + v[i][2])
    su, sv = uv[k0][0] > 0.5, uv[k0][1] > 0.5
    nv, nuv, nt = [], [], []
    for j in range(n + 1):
        for i in range(n + 1):
            fy, fz = i / n, j / n
            nv.append(forma(lo[0] + (hi[0] - lo[0]) * fy, lo[1] + (hi[1] - lo[1]) * fz))
            nuv.append((u0[0] + (u1[0] - u0[0]) * (fy if su else 1 - fy), u0[1] + (u1[1] - u0[1]) * (fz if sv else 1 - fz)))
    for j in range(n):
        for i in range(n):
            a, b, c, d = j * (n + 1) + i, j * (n + 1) + i + 1, (j + 1) * (n + 1) + i + 1, (j + 1) * (n + 1) + i
            nt += [a, b, c, a, c, d]
    return nv, nuv, nt


def nx(p, q, r):
    return (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])


def geoset_nuevo(d, g):
    partes, mat, grupo, sel, nex = leer_geoset(d)
    assert partes[b'MTGCn'] == 1 and partes[b'PTYP'] == struct.pack('<I', 4), g
    v0 = [struct.unpack_from('<3f', partes[b'VRTX'], 12 * i) for i in range(partes[b'VRTXn'])]
    t0 = struct.unpack(f'<{partes[b"PVTXn"]}H', partes[b'PVTX'])
    p = d.index(b'UVBS')
    uv0 = [struct.unpack_from('<2f', d, p + 8 + 8 * i) for i in range(partes[b'VRTXn'])]
    signo = nx(*((v0[x][1], v0[x][2]) for x in t0[:3])) > 0
    v, uv, tri = geo_piezas(g) if g in (0, 1) else rejilla(v0, uv0)
    # Mismo sentido de giro que el original (normal +x), triángulo a triángulo.
    for k in range(0, len(tri), 3):
        if (nx(*(v[x] for x in tri[k:k + 3])) > 0) != signo:
            tri[k + 1], tri[k + 2] = tri[k + 2], tri[k + 1]
    v = [(0., y, z * VY) for y, z in v]
    assert len(v) < 65536
    rad, lo, hi = caja(v)
    ext = struct.pack('<7f', rad, *lo, *hi)
    tag = lambda t, n, datos: t + struct.pack('<I', n) + datos
    out = (tag(b'VRTX', len(v), b''.join(struct.pack('<3f', *q) for q in v)) +
           tag(b'NRMS', len(v), struct.pack('<3f', 1., 0., 0.) * len(v)) +
           tag(b'PTYP', 1, struct.pack('<I', 4)) + tag(b'PCNT', 1, struct.pack('<I', len(tri))) +
           tag(b'PVTX', len(tri), struct.pack(f'<{len(tri)}H', *tri)) + tag(b'GNDX', len(v), bytes(len(v))) +
           tag(b'MTGC', 1, struct.pack('<I', 1)) + tag(b'MATS', partes[b'MATSn'], partes[b'MATS']) +
           struct.pack('<3I', mat, grupo, sel) + ext + struct.pack('<I', nex) + ext * nex +
           b'UVAS' + struct.pack('<I', 1) + tag(b'UVBS', len(uv), b''.join(struct.pack('<2f', *t) for t in uv)))
    return struct.pack('<I', len(out) + 4) + out, len(v), len(tri) // 3


def pulso(help_):
    """Globe: KGSC 1,0 → 1,1 → 1,0 (global 3, 4 s) → 1,0 → PULSO → 1,0, mismos tiempos."""
    q, hecho = 0, 0
    while q < len(help_):
        sz = struct.unpack_from('<I', help_, q)[0]
        if bytes(help_[q + 4:q + 84]).split(b'\0')[0] == b'Globe':
            r = help_.index(b'KGSC', q)
            nk, it, gs = struct.unpack_from('<IIi', help_, r + 4)
            assert (nk, it) == (3, 1), (nk, it)
            for k in range(nk):
                o = r + 16 + 16 * k
                s = struct.unpack_from('<3f', help_, o + 4)
                assert all(abs(x - (1.1 if k == 1 else 1.)) < 1e-4 for x in s), s
                if k == 1:
                    struct.pack_into('<3f', help_, o + 4, PULSO, PULSO, PULSO)
            hecho += 1
        q += sz
    assert hecho == 1


def rehacer(src):
    cs = chunks(src)
    geos = next(d for t, d in cs if t == b'GEOS')
    o, k, salida, info = 0, 0, bytearray(), []
    while o < len(geos):
        n = struct.unpack_from('<I', geos, o)[0]
        d = bytes(geos[o:o + n])
        if k in (0, 1, 2):
            nuevo, nv, nt = geoset_nuevo(d, k)
            salida += nuevo
            info.append((k, nv, nt))
        else:
            salida += d
        o += n
        k += 1
    assert k == 4, k
    for c in cs:
        if c[0] == b'GEOS':
            c[1] = salida
        if c[0] == b'GEOA':
            q = 0
            while q < len(c[1]):
                sz = struct.unpack_from('<I', c[1], q)[0]
                struct.pack_into('<3f', c[1], q + 12, *gris(*struct.unpack_from('<3f', c[1], q + 12)))
                q += sz
        if c[0] == b'TEXS':
            i = c[1].index(b'Textures\\Blue_Glow2.blp')
            c[1][i:i + 260] = TEXTURA.encode().ljust(260, b'\0')
        if c[0] == b'HELP':
            pulso(c[1])
    return junta(cs), info


if __name__ == '__main__':
    out, info = rehacer(Path(sys.argv[1]).read_bytes())
    Path(sys.argv[3]).write_bytes(out)
    from PIL import Image
    sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts')
    import grid
    im = Image.open(sys.argv[2]).convert('RGB')
    px = [tuple(round(c * 255) for c in gris(*(x / 255 for x in p))) for p in im.getdata()]
    g = Image.new('RGB', im.size)
    g.putdata(px)
    print('burbuja', info, 'piezas', len(piezas()), 'brillo', grid.blp(g.convert('RGBA'), Path(sys.argv[4]))[:12])
