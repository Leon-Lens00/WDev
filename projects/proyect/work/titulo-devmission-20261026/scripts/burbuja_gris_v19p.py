#!/usr/bin/env python3
"""v19p (19/11/2026): burbuja gris opaca para las cartas cerradas (Leon: "una version opaca gris, que ira junto a los
cuadros desactivados", p. ej. Armas y Habilidades mientras la Mutación Evo es obligatoria).

Parte de CuaBurbuja.mdx (burbuja_v19p.py, ya horneada) y sólo cambia materiales, colores y el pulso; la forma es la misma.
- Piezas (material 1): tras las tres capas negras, el brillo gris (CuaBurbujaBrillo) pasa de aditivo a mezcla con alfa
  fijo 0,55: hexágonos grises opacos. Las demás capas aditivas (estrellas, nubes, Star7b, Dust) quedan al 15 %.
- Borde (material 0), anillo (2) y resplandor (3): al 30 %.
- Sin animaciones de textura (los brillos no corren ni giran) y sin pulso (Globe a 1,0).
- Colores de geoset en gris puro (saturación 0).
Uso: burbuja_gris_v19p.py CUABURBUJA_MDX SALIDA_MDX
"""
from colorsys import hsv_to_rgb, rgb_to_hsv
from pathlib import Path
import struct
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from aro_v19o import chunks, junta  # noqa: E402

BRILLO = 8                      # TEXS de war3mapImported\CuaBurbujaBrillo.blp
FACTOR = {0: .30, 1: .15, 2: .30, 3: .30}
OPACO = .55


def capa(d, m):
    """Reescribe una capa (bytes con su tamaño); devuelve los bytes nuevos."""
    sz, fm, sh, tid, tva, cid, al = struct.unpack_from('<IIIiiIf', d, 0)
    assert sz == len(d)
    resto = d[28:]
    kmta = b''
    if resto:
        assert resto[:4] == b'KMTA', resto[:4]
        nk, it, gs = struct.unpack_from('<IIi', resto, 4)
        per = 8 if it < 2 else 16
        assert len(resto) == 16 + nk * per, (len(resto), nk, it)
        claves = bytearray(resto[16:])
    if m == 1 and tid == BRILLO:
        fm, al, kmta = 2, OPACO, b''                    # mezcla, alfa fijo
    elif fm in (3, 4, 5):                                # aditivas: más tenues
        al *= FACTOR[m]
        if resto:
            for k in range(nk):
                o = k * per
                for j in range(1, per // 4):
                    struct.pack_into('<f', claves, o + 4 * j, struct.unpack_from('<f', claves, o + 4 * j)[0] * FACTOR[m])
            kmta = resto[:16] + bytes(claves)
    else:
        kmta = resto
    cuerpo = struct.pack('<IIiiIf', fm, sh, tid, -1, cid, al) + kmta
    return struct.pack('<I', len(cuerpo) + 4) + cuerpo


def materiales(d):
    out, q, m = bytearray(), 0, 0
    while q < len(d):
        sz, prio, fl = struct.unpack_from('<IiI', d, q)
        assert d[q + 12:q + 16] == b'LAYS'
        nl = struct.unpack_from('<I', d, q + 16)[0]
        r, capas = q + 20, b''
        for _ in range(nl):
            lsz = struct.unpack_from('<I', d, r)[0]
            capas += capa(bytes(d[r:r + lsz]), m)
            r += lsz
        assert r == q + sz
        cuerpo = struct.pack('<iI', prio, fl) + b'LAYS' + struct.pack('<I', nl) + capas
        out += struct.pack('<I', len(cuerpo) + 4) + cuerpo
        q += sz
        m += 1
    assert m == 4
    return out


def rehacer(src):
    cs = chunks(src)
    for c in cs:
        if c[0] == b'MTLS':
            c[1] = materiales(c[1])
        if c[0] == b'GEOA':
            q = 0
            while q < len(c[1]):
                sz = struct.unpack_from('<I', c[1], q)[0]
                h, s, v = rgb_to_hsv(*struct.unpack_from('<3f', c[1], q + 12))
                struct.pack_into('<3f', c[1], q + 12, *hsv_to_rgb(h, 0., v))
                q += sz
        if c[0] == b'HELP':
            q, n = 0, 0
            while q < len(c[1]):
                sz = struct.unpack_from('<I', c[1], q)[0]
                if bytes(c[1][q + 4:q + 84]).split(b'\0')[0] == b'Globe':
                    r = c[1].index(b'KGSC', q)
                    nk, it = struct.unpack_from('<II', c[1], r + 4)
                    assert it == 1
                    for k in range(nk):
                        struct.pack_into('<3f', c[1], r + 16 + 16 * k + 4, 1., 1., 1.)
                    n += 1
                q += sz
            assert n == 1
    return junta(cs)


if __name__ == '__main__':
    Path(sys.argv[2]).write_bytes(rehacer(Path(sys.argv[1]).read_bytes()))
    print('gris', sys.argv[2])
