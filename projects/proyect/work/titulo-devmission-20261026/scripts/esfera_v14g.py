#!/usr/bin/env python3
"""v14g: la esfera del localizador del jefe, JefeEsfera.mdx, a partir de BossShield.mdx (Ubershield Azure del tablero
de estrategia), sin PIL.

- Redonda en cualquier punto de la pantalla: las dos esferas (geosets 0 y 1) cuelgan de huesos billboard (Pods, Blau),
  que se orientan con la cámara; en 3D, cerca de la cámara y fuera del centro, la perspectiva las estiraba. Se conserva
  la mitad x ≥ 0 de cada una y se aplana a x = 0: un disco paralelo a la pantalla se proyecta siempre como círculo.
  El brillo plano (geoset 2) ya está en x = 0. El anillo oscuro (geoset 3) no es billboard y saldría elíptico: se
  colapsa en el origen.
- Rubí: matiz 348° conservando la saturación y el brillo de cada color, en los colores de geoset (GEOA) y en la
  textura Blue_Glow2 (texturas/jefe-esfera/Blue_Glow2.ppm, decodificada del original de War3x.mpq), que pasa a
  war3mapImported\\JefeEsferaBrillo.blp (BLP1 con paleta). Los blancos y tonos claros quedan claros.
- Planos de prioridad + 4 (0-1 → 4-5): el HUD se ordena por ese plano y la esfera va delante del icono (plano 3).

Uso: esfera_v14g.py BOSS_SHIELD_MDX BLUE_GLOW2_PPM SALIDA_MDX SALIDA_BLP
"""
from colorsys import hsv_to_rgb, rgb_to_hsv
from pathlib import Path
import struct
import sys

MATIZ = 348. / 360.
TEXTURA = 'war3mapImported\\JefeEsferaBrillo.blp'


def rubi(r, g, b):
    h, s, v = rgb_to_hsv(r, g, b)
    return hsv_to_rgb(MATIZ, s, v)


def chunks(d):
    i = 4
    while i < len(d):
        n = struct.unpack_from('<I', d, i + 4)[0]
        yield d[i:i + 4], i + 8, n
        i += 8 + n


def geoset(b, o):
    """Sub-bloques de un geoset: posición de datos y cuenta de cada uno."""
    q, g = o + 4, {}
    for tag, el in ((b'VRTX', 12), (b'NRMS', 12), (b'PTYP', 4), (b'PCNT', 4), (b'PVTX', 2)):
        assert b[q:q + 4] == tag, (tag, b[q:q + 4])
        c = struct.unpack_from('<I', b, q + 4)[0]
        g[tag] = (q, c)
        q += 8 + c * el
    return g


def modelo(src, rubi_si=True):
    """rubi_si=False deja los colores y la textura del original (la esfera azul de la tienda, v14h)."""
    b = bytearray(src)
    geos = next((o, n) for tag, o, n in chunks(b) if tag == b'GEOS')
    salida, o, k = bytearray(), geos[0], 0
    while o < geos[0] + geos[1]:
        sz = struct.unpack_from('<I', b, o)[0]
        g = bytearray(b[o:o + sz])
        s = geoset(g, 0)
        (vq, nv), (pq, nt) = s[b'VRTX'], s[b'PVTX']
        v = [struct.unpack_from('<3f', g, vq + 8 + 12 * i) for i in range(nv)]
        if k in (0, 1):
            assert struct.unpack_from('<I', g, s[b'PTYP'][0] + 8)[0] == 4  # triángulos
            t = struct.unpack_from(f'<{nt}H', g, pq + 8)
            tris = [t[i:i + 3] for i in range(0, nt, 3) if sum(v[j][0] for j in t[i:i + 3]) >= 0.]
            for i, (x, y, z) in enumerate(v):
                struct.pack_into('<3f', g, vq + 8 + 12 * i, 0., y, z)
            nuevo = struct.pack('<I', 3 * len(tris)) + b''.join(struct.pack('<3H', *x) for x in tris)
            struct.pack_into('<I', g, s[b'PCNT'][0] + 8, 3 * len(tris))
            g[pq + 4:pq + 8 + 2 * nt] = nuevo
            struct.pack_into('<I', g, 0, len(g))
        elif k == 3:
            for i in range(nv):
                struct.pack_into('<3f', g, vq + 8 + 12 * i, 0., 0., 0.)
        salida += g
        o += sz
        k += 1
    assert k == 4, k
    b[geos[0] - 4:geos[0]] = struct.pack('<I', len(salida))
    b[geos[0]:geos[0] + geos[1]] = salida
    for tag, o, n in chunks(b):
        if tag == b'MTLS':  # delante del icono del jefe (plano 3, objetos_v14g.py): planos 0-1 pasan a 4-5
            q = o
            while q < o + n:
                struct.pack_into('<i', b, q + 4, struct.unpack_from('<i', b, q + 4)[0] + 4)
                q += struct.unpack_from('<I', b, q)[0]
        if tag == b'GEOA' and rubi_si:
            q = o
            while q < o + n:
                sz = struct.unpack_from('<I', b, q)[0]
                struct.pack_into('<3f', b, q + 12, *rubi(*struct.unpack_from('<3f', b, q + 12)))
                q += sz
        if tag == b'TEXS' and rubi_si:
            i = b.index(b'Textures\\Blue_Glow2.blp', o)
            assert i < o + n
            b[i:i + 260] = TEXTURA.encode().ljust(260, b'\0')
    return bytes(b)


def ppm(path):
    d = Path(path).read_bytes()
    partes = d.split(maxsplit=4)
    assert partes[0] == b'P6' and partes[3] == b'255'
    w, h = int(partes[1]), int(partes[2])
    px = partes[4]
    return w, h, [tuple(px[i:i + 3]) for i in range(0, 3 * w * h, 3)]


def blp(w, h, px):
    """BLP1 con paleta, sin alfa (como el original: aditivo), con mipmaps hasta 1×1."""
    q = [tuple(min(255, round(c * 255)) for c in rubi(*(x / 255 for x in p))) for p in px]
    q = [tuple((c >> 2) * 255 // 63 for c in p) for p in q]
    paleta = sorted(set(q))
    assert len(paleta) <= 256, len(paleta)
    idx = {c: i for i, c in enumerate(paleta)}
    bgra = b''.join(bytes((c[2], c[1], c[0], 0)) for c in paleta) + bytes(4 * (256 - len(paleta)))
    niveles, img = [], q
    while True:
        niveles.append(bytes(idx[min(paleta, key=lambda c: sum((a - b) ** 2 for a, b in zip(c, p)))] if p not in idx else idx[p] for p in img))
        if w == 1 and h == 1:
            break
        nw, nh = max(1, w // 2), max(1, h // 2)
        img = [tuple(sum(img[(2 * y + dy) * w + 2 * x + dx][c] for dy in (0, 1) for dx in (0, 1)) // 4 for c in range(3))
               for y in range(nh) for x in range(nw)]
        w, h = nw, nh
    w0, h0 = int(len(px) ** .5), int(len(px) ** .5)
    offs, p = [], 156 + 1024
    for n in niveles:
        offs.append(p)
        p += len(n)
    head = b'BLP1' + struct.pack('<6I', 1, 0, w0, h0, 5, 1)
    head += struct.pack('<16I', *(offs + [0] * (16 - len(offs))))
    head += struct.pack('<16I', *([len(n) for n in niveles] + [0] * (16 - len(niveles))))
    return head + bgra + b''.join(niveles)


if __name__ == '__main__':
    Path(sys.argv[3]).write_bytes(modelo(Path(sys.argv[1]).read_bytes()))
    w, h, px = ppm(sys.argv[2])
    assert w == h
    Path(sys.argv[4]).write_bytes(blp(w, h, px))
