#!/usr/bin/env python3
"""v19o (19/11/2026): contorno de las cartas a partir de las esferas de los indicadores (Leon: "tomarias ese modelo y lo
darias un rework para encierre correctamente un contorno rectangular alto").

Entrada: TiendaEsfera.mdx (azul, v14h) o JefeEsfera.mdx (rubí, v14g); los dos son la Ubershield Azure aplanada
(esfera_v14g.py): geosets 0 y 1 son discos de radio 66 con la textura proyectada en plano (uv = 0,5 + f·(y, -z));
el 2 es un cuadrado de 153,6 con el anillo ping4; el 3 está colapsado en el origen.

- Cada geoset 0-2 pasa a ser una franja que recorre un rectángulo de esquinas redondeadas del tamaño de la carta. Un
  punto de la franja (posición p en el perímetro, radio r del disco original) toma el uv que tenía el punto del disco
  con ángulo 2π·VUELTAS·p/L y radio r: los anillos de GenericGlow5, GenericGlowFaded y ping4 (anillos en la textura)
  quedan como líneas paralelas al borde, y las animaciones de textura (giros y desplazamientos) corren a lo largo de
  él. El radio r se coloca a (r − R0)·M px del borde de la carta: dentro si r < R0, fuera si r > R0.
- Unidades: 1 unidad = 1 px de pantalla en horizontal; en vertical, ×1,02789 (la escena de los cuadros pone 7,7860e-4
  de mundo por px vertical y 7,5747e-4 por px horizontal por unidad de profundidad). Escala de la unidad en el juego:
  7,5747e-4 × profundidad.
- Se escribe en el espacio del billboard (x hacia la cámara, y derecha, z arriba); luego mdx_sin_billboard.py lo hornea
  para la cámara de los menús (lejos de X 0 el billboard se tuerce) y aquí se rehacen las extensiones del modelo y de
  las secuencias para que el juego no lo descarte al dibujar.

Uso: aro_v19o.py ESFERA_MDX SALIDA_MDX   (el resultado aún con billboard; hacer-v19o.sh aplica mdx_sin_billboard.py)
     aro_v19o.py --extensiones MDX_HORNEADO
"""
from math import cos, pi, sin, sqrt
from pathlib import Path
import struct
import sys

A, B = 165., 240.          # media carta (330 × 480 px)
RC = 24.                   # radio de las esquinas del borde base
VY = 1.02789               # px vertical → unidades
R0, M = 60., 1.25          # radio del disco que cae en el borde y px por unidad de radio
VUELTAS = 3
N = 260                    # muestras en el perímetro
F = {0: 0.005683, 1: 0.003758, 2: 0.0065104}      # uv por unidad de cada geoset (ajuste lineal, error < 0,001)
RADIOS = {0: (44., 66.), 1: (50., 66.), 2: (56., 76.)}
ANILLOS = 5


def chunks(b):
    o, out = 4, []
    while o < len(b):
        t, n = b[o:o + 4], struct.unpack_from('<I', b, o + 4)[0]
        out.append([t, bytearray(b[o + 8:o + 8 + n])])
        o += 8 + n
    assert o == len(b)
    return out


def junta(cs):
    return b'MDLX' + b''.join(t + struct.pack('<I', len(d)) + bytes(d) for t, d in cs)


def perimetro():
    """Borde base (rectángulo A×B con esquinas de radio RC), en sentido antihorario desde el centro del lado derecho:
    lista de (y, z, ny, nz) uniforme en longitud."""
    a, b = A - RC, B - RC
    tramos = [('l', (A, -b), (A, b)), ('c', (a, b), 0.), ('l', (a, B), (-a, B)), ('c', (-a, b), pi / 2),
              ('l', (-A, b), (-A, -b)), ('c', (-a, -b), pi), ('l', (-a, -B), (a, -B)), ('c', (a, -b), 1.5 * pi)]
    largo = [sqrt((t[2][0] - t[1][0]) ** 2 + (t[2][1] - t[1][1]) ** 2) if t[0] == 'l' else pi / 2 * RC for t in tramos]
    L = sum(largo)
    # Empieza a mitad del lado derecho.
    pts = []
    for i in range(N):
        s = (i / N * L + largo[0] / 2) % L
        k = 0
        while s > largo[k]:
            s -= largo[k]
            k += 1
        t = tramos[k]
        if t[0] == 'l':
            f = s / largo[k]
            y, z = t[1][0] + f * (t[2][0] - t[1][0]), t[1][1] + f * (t[2][1] - t[1][1])
            dy, dz = t[2][0] - t[1][0], t[2][1] - t[1][1]
            n = sqrt(dy * dy + dz * dz)
            ny, nz = dz / n, -dy / n
        else:
            ang = t[2] + s / RC
            ny, nz = cos(ang), sin(ang)
            y, z = t[1][0] + RC * ny, t[1][1] + RC * nz
        pts.append((y, z, ny, nz))
    return pts, L


def franja(g):
    """Vértices (billboard), uv y triángulos de la franja del geoset g."""
    pts, L = perimetro()
    r0, r1 = RADIOS[g]
    v, uv, tri = [], [], []
    for i, (y, z, ny, nz) in enumerate(pts):
        th = 2 * pi * VUELTAS * i / N
        for j in range(ANILLOS):
            r = r0 + (r1 - r0) * j / (ANILLOS - 1)
            d = (r - R0) * M
            v.append((0., y + d * ny, (z + d * nz) * VY))
            uv.append((0.5 + F[g] * r * cos(th), 0.5 - F[g] * r * sin(th)))
    for i in range(N):
        i2 = (i + 1) % N
        for j in range(ANILLOS - 1):
            a, b, c, d = i * ANILLOS + j, i2 * ANILLOS + j, i2 * ANILLOS + j + 1, i * ANILLOS + j + 1
            # Normal +x (hacia la cámara del billboard), como los triángulos del disco original: el perímetro va en
            # sentido antihorario en (y, z), así que se recorre al revés.
            tri += [a, c, b, a, d, c]
    return v, uv, tri


def caja(v):
    lo = [min(p[k] for p in v) for k in range(3)]
    hi = [max(p[k] for p in v) for k in range(3)]
    return max(sqrt(sum(x * x for x in p)) for p in v), lo, hi


def leer_geoset(d):
    p, partes = 4, {}
    while True:
        t, n = bytes(d[p:p + 4]), struct.unpack_from('<I', d, p + 4)[0]
        step = {b'VRTX': 12, b'NRMS': 12, b'PTYP': 4, b'PCNT': 4, b'PVTX': 2, b'GNDX': 1, b'MTGC': 4, b'MATS': 4}[t]
        partes[t] = bytes(d[p + 8:p + 8 + n * step])
        partes[t + b'n'] = n
        p += 8 + n * step
        if t == b'MATS':
            break
    mat, grupo, sel = struct.unpack_from('<3I', d, p)
    p += 12 + 28
    nex = struct.unpack_from('<I', d, p)[0]
    p += 4 + 28 * nex
    assert d[p:p + 4] == b'UVAS'
    return partes, mat, grupo, sel, nex


def nuevo_geoset(d, g):
    partes, mat, grupo, sel, nex = leer_geoset(d)
    assert partes[b'MTGCn'] == 1 and partes[b'PTYP'] == struct.pack('<I', 4), g
    v, uv, tri = franja(g)
    rad, lo, hi = caja(v)
    ext = struct.pack('<7f', rad, *lo, *hi)
    tag = lambda t, n, datos: t + struct.pack('<I', n) + datos
    out = (tag(b'VRTX', len(v), b''.join(struct.pack('<3f', *p) for p in v)) +
           tag(b'NRMS', len(v), struct.pack('<3f', 1., 0., 0.) * len(v)) +
           tag(b'PTYP', 1, struct.pack('<I', 4)) + tag(b'PCNT', 1, struct.pack('<I', len(tri))) +
           tag(b'PVTX', len(tri), struct.pack(f'<{len(tri)}H', *tri)) + tag(b'GNDX', len(v), bytes(len(v))) +
           tag(b'MTGC', 1, struct.pack('<I', 1)) + tag(b'MATS', partes[b'MATSn'], partes[b'MATS']) +
           struct.pack('<3I', mat, grupo, sel) + ext + struct.pack('<I', nex) + ext * nex +
           b'UVAS' + struct.pack('<I', 1) + tag(b'UVBS', len(uv), b''.join(struct.pack('<2f', *t) for t in uv)))
    return struct.pack('<I', len(out) + 4) + out


def rehacer(src):
    cs = chunks(src)
    geos = next(d for t, d in cs if t == b'GEOS')
    o, k, salida = 0, 0, bytearray()
    while o < len(geos):
        n = struct.unpack_from('<I', geos, o)[0]
        d = geos[o:o + n]
        salida += nuevo_geoset(d, k) if k in (0, 1, 2) else d
        o += n
        k += 1
    assert k == 4, k
    for c in cs:
        if c[0] == b'GEOS':
            c[1] = salida
    return junta(cs)


def extensiones(b):
    """Tras hornear: caja de todo el modelo en MODL y en cada secuencia."""
    cs = chunks(b)
    geos = next(d for t, d in cs if t == b'GEOS')
    o, v = 0, []
    while o < len(geos):
        n = struct.unpack_from('<I', geos, o)[0]
        p = geos.index(b'VRTX', o)
        c = struct.unpack_from('<I', geos, p + 4)[0]
        v += [struct.unpack_from('<3f', geos, p + 8 + 12 * i) for i in range(c)]
        o += n
    rad, lo, hi = caja(v)
    lo[2], hi[2] = -10., 10.
    ext = struct.pack('<7f', rad, *lo, *hi)
    for t, d in cs:
        if t == b'MODL':
            d[340:368] = ext
        if t == b'SEQS':
            for i in range(len(d) // 132):
                d[132 * i + 104:132 * i + 132] = ext
    return junta(cs), (rad, lo, hi)


if __name__ == '__main__':
    if sys.argv[1] == '--extensiones':
        out, e = extensiones(Path(sys.argv[2]).read_bytes())
        Path(sys.argv[2]).write_bytes(out)
        print('extensiones', [round(x, 1) for x in (e[0], *e[1], *e[2])])
    else:
        Path(sys.argv[2]).write_bytes(rehacer(Path(sys.argv[1]).read_bytes()))
        print('franjas', sys.argv[2])
