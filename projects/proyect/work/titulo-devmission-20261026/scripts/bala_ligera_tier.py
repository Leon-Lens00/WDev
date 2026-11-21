#!/usr/bin/env python3
"""v17b (14/11/2026): balas ligeras con el color de cada tier y el tamaño de la bala original de cada arma.

Leon: "implementa la ligera, obviamente tendra sus tonos de tier con escalas diferentes de acuerdo a la bala original".
Base: ligera1 (bala_ligera.py) = Toy Bullet2 (Toy Soldiers) sin emisores: 2 cuadrados que giran hacia la cámara
(hueso con billboard sobre X). Geoset 0 = trazo (material 0, textura 1); geoset 1 = brillo (material 1, Flare).
- Textura 1: GenericGlow2_64_blue -> GenericGlow64 (blanca, War3x.mpq) para poder teñir el trazo.
- Color estático de cada GEOA (orden B, G, R; flag 2 ya activo): brillo = color del tier; trazo = mitad blanco.
- Tamaño por arma, medido en los modelos originales (punta en +tip, cola en tip - L, ancho W):
  Sub (MP5, Shot) 110 x 12, punta +5; Fus (SCAR, Shot II) 217 x 36, +17; Fra (Daemonic Arrow) 300 x 50, +30;
  Esc (Firebrand Grande x5/3: estela y brillo) 400 x 90, +60.
- Límites (MODL, GEOS y sus extents) con la caja nueva para que el motor no la recorte antes de tiempo.
Salida: DIR/BalaLigera/<Arma>_<Color>.mdx, 4 armas x 6 colores (Yellow Green Cyan Blue Purple Red).
Uso: bala_ligera_tier.py LIGERA1.mdx DIR
"""
from pathlib import Path
import struct, sys, math

b = Path(sys.argv[1]).read_bytes()
out = Path(sys.argv[2]) / 'BalaLigera'
out.mkdir(parents=True, exist_ok=True)
ARMAS = {'Sub': (110, 12, 5), 'Fus': (217, 36, 17), 'Fra': (300, 50, 30), 'Esc': (400, 90, 60)}
COLORES = {'Yellow': 0xfdea00, 'Green': 0x65fd00, 'Cyan': 0x00e3fd, 'Blue': 0x0045fd, 'Purple': 0x7200fd, 'Red': 0xfd0006}


def trozos(b):
    i, r = 4, []
    while i < len(b):
        tag, n = b[i:i + 4], struct.unpack_from('<I', b, i + 4)[0]
        r.append([tag, bytearray(b[i + 8:i + 8 + n])]); i += 8 + n
    return r


def caja(xs, zs):
    mn, mx = (min(xs), -1., min(zs)), (max(xs), 1., max(zs))
    rad = math.sqrt(sum(((a - c) / 2) ** 2 for a, c in zip(mn, mx)))
    return rad, mn, mx


def hacer(L, W, tip, rgb):
    ch = trozos(b)
    r, g, bl = ((rgb >> 16) & 255) / 255, ((rgb >> 8) & 255) / 255, (rgb & 255) / 255
    trazo = [(c + 1) / 2 for c in (r, g, bl)]
    hz = max(1.5, W * 0.12)          # medio alto del trazo
    gz = max(10., W * 0.6)           # medio alto del brillo
    geo = [((tip - L, tip), (-hz, hz)), ((tip - L * 1.1, tip + W * 0.6), (-gz, gz))]
    todas_x = [v for g_ in geo for v in g_[0]]
    todas_z = [v for g_ in geo for v in g_[1]]
    total = caja(todas_x, todas_z)
    for x in ch:
        t, d = x
        if t == b'TEXS':
            assert len(d) == 3 * 268
            p = d[268 + 4:268 + 264].split(b'\0')[0]
            assert p == b'Textures\\GenericGlow2_64_blue.blp', p
            nuevo = b'Textures\\GenericGlow64.blp'
            d[268 + 4:268 + 264] = nuevo + b'\0' * (260 - len(nuevo))
        elif t == b'MODL':
            struct.pack_into('<7f', d, 80 + 260, total[0], *total[1], *total[2])
        elif t == b'SEQS':
            for q in range(len(d) // 132):
                struct.pack_into('<7f', d, q * 132 + 104, total[0], *total[1], *total[2])
        elif t == b'GEOS':
            o, gi = 0, 0
            while o < len(d):
                sz = struct.unpack_from('<I', d, o)[0]; k = o + 4
                (x0, x1), (z0, z1) = geo[gi]
                rad, mn, mx = caja([x0, x1], [z0, z1])
                while k < o + sz:
                    tg, c = d[k:k + 4], struct.unpack_from('<I', d, k + 4)[0]
                    if tg == b'VRTX':
                        assert c == 4
                        for q in range(4):
                            vx, vy, vz = struct.unpack_from('<3f', d, k + 8 + 12 * q)
                            struct.pack_into('<3f', d, k + 8 + 12 * q, x1 if vx > 0 else x0, vy, z1 if vz > 0 else z0)
                        k += 8 + 12 * c
                    elif tg in (b'NRMS',): k += 8 + 12 * c
                    elif tg in (b'PTYP', b'PCNT', b'MTGC'): k += 8 + 4 * c
                    elif tg == b'PVTX': k += 8 + 2 * c
                    elif tg == b'GNDX': k += 8 + c
                    elif tg == b'MATS':
                        k += 8 + 4 * c
                        ne = struct.unpack_from('<I', d, k + 40)[0]
                        struct.pack_into('<7f', d, k + 12, rad, *mn, *mx)
                        for e in range(ne):
                            struct.pack_into('<7f', d, k + 44 + 28 * e, rad, *mn, *mx)
                        k += 44 + 28 * ne
                    elif tg == b'UVAS': k += 8
                    elif tg == b'UVBS': k += 8 + 8 * c
                    else: raise SystemExit(f'bloque inesperado {tg}')
                o += sz; gi += 1
            assert gi == 2
        elif t == b'GEOA':
            o, gi = 0, 0
            while o < len(d):
                sz = struct.unpack_from('<I', d, o)[0]
                fl, = struct.unpack_from('<I', d, o + 8); assert fl & 2
                col = trazo if gi == 0 else (r, g, bl)
                struct.pack_into('<3f', d, o + 12, col[2], col[1], col[0])
                o += sz; gi += 1
    return b'MDLX' + b''.join(t + struct.pack('<I', len(d)) + bytes(d) for t, d in ch)


for arma, (L, W, tip) in ARMAS.items():
    for nom, rgb in COLORES.items():
        (out / f'{arma}_{nom}.mdx').write_bytes(hacer(L, W, tip, rgb))
print('balas ligeras:', len(list(out.glob('*.mdx'))))
