#!/usr/bin/env python3
"""v14h: modelos de efecto. Necesita Pillow (python del runtime de Slendytubbies) para leer y cuantizar BLP.

- Burning Rage (Vinz, efectos/burning-rage): un color por ronda para élites y jefes, BurningRage1..10.mdx en este orden:
  verde, turquesa, azul, púrpura, rosa, amarillo, naranja, rojo, plata y violeta. Los 8 primeros son los originales;
  sus texturas propias van en la raíz con su nombre, como pide el readme.
  - Plata, desde el azul: saturación × 0,12 y el mismo brillo, así que los blancos y los grises no cambian.
  - Violeta, desde el púrpura (aditivo: más oscuro dejaría de verse): matiz 275° y brillo × 0,7 sólo en los colores saturados (S ≥ 0,2): las llamas
    quedan violeta oscuro, y los núcleos blancos y el humo negro, como estaban.
  La textura propia (AzureGlow5/RoyalGlow02) es un BLP JPEG con alfa de 8 bits y va en capas Blend: hay que conservar
  su alfa, o esas capas salen opacas (en 1.27b se vio un cráneo violeta macizo). Pillow lee esos BLP con alfa 255 y
  los colores mal: jpeg_blp los decodifica a mano.
  En los dos se recolorean los colores de geoset (GEOA, que el juego lee como R, G, B: el azul original es
  (0, 0,13, 0,45)), los de las partículas (PRE2) y las dos texturas de color: la propia y el brillo del juego
  (Blue_Glow2 / Purple_Glow, en texturas/burning-rage), que pasan a PlataGlow/VioletaGlow y PlataBrillo/VioletaBrillo.
- Radiance (Vinz, efectos/radiance): zonas de munición, RecargaVerde.mdx (Nature) y RecargaRoja.mdx (Crimson), sin
  cambios.
- TiendaEsfera.mdx: la esfera del jefe (esfera_v14g.py, plana frente a la cámara, delante del icono) con su azul
  original.

Uso: efectos_v14h.py DIR_PROYECTO BOSS_SHIELD_MDX DIR_SALIDA
"""
from colorsys import hsv_to_rgb, rgb_to_hsv
from pathlib import Path
import io
import shutil
import struct
import sys

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import esfera_v14g

COLORES = ['Green', 'Teal', 'Blue', 'Purple', 'Pink', 'Yellow', 'Orange', 'Red']


def plata(r, g, b):
    h, s, v = rgb_to_hsv(r, g, b)
    return hsv_to_rgb(h, s * .12, v)


def violeta(r, g, b):
    h, s, v = rgb_to_hsv(r, g, b)
    if s < .2:
        return r, g, b
    return hsv_to_rgb(275. / 360., s, v * .7)


def chunks(b):
    i = 4
    while i < len(b):
        n = struct.unpack_from('<I', b, i + 4)[0]
        yield b[i:i + 4], i + 8, n
        i += 8 + n


def recolor_mdx(src, f, texturas):
    """Colores de GEOA y PRE2 con f; texturas: {ruta vieja: ruta nueva} en TEXS."""
    b = bytearray(src)
    vistos = set()
    for tag, o, n in chunks(b):
        if tag == b'GEOA':
            q = o
            while q < o + n:
                sz = struct.unpack_from('<I', b, q)[0]
                struct.pack_into('<3f', b, q + 12, *f(*struct.unpack_from('<3f', b, q + 12)))
                q += sz
        elif tag == b'PRE2':
            q = o
            while q < o + n:
                sz = struct.unpack_from('<I', b, q)[0]
                p = q + 4 + struct.unpack_from('<I', b, q + 4)[0]  # fin del nodo
                for k in range(3):  # 8 reales, filtro, filas, columnas, cabeza/cola, largo y tiempo: 56 bytes
                    struct.pack_into('<3f', b, p + 56 + 12 * k, *f(*struct.unpack_from('<3f', b, p + 56 + 12 * k)))
                q += sz
        elif tag == b'TEXS':
            for k in range(n // 268):
                c = o + 268 * k + 4
                ruta = b[c:c + 260].split(b'\0')[0].decode()
                if ruta in texturas:
                    b[c:c + 260] = texturas[ruta].encode().ljust(260, b'\0')
                    vistos.add(ruta)
    assert vistos == set(texturas), (vistos, texturas)
    return bytes(b)


def jpeg_blp(ruta):
    """Primer mipmap de un BLP1 JPEG como RGBA. El JPEG guarda B, G, R y A en sus cuatro canales; Pillow los da
    invertidos (CMYK)."""
    b = Path(ruta).read_bytes()
    assert b[:4] == b'BLP1' and struct.unpack_from('<I', b, 4)[0] == 0, ruta
    off, sz = struct.unpack_from('<I', b, 28)[0], struct.unpack_from('<I', b, 92)[0]
    n = struct.unpack_from('<I', b, 156)[0]
    c = [ch.point(lambda x: 255 - x) for ch in Image.open(io.BytesIO(b[160:160 + n] + b[off:off + sz])).split()]
    return Image.merge('RGBA', (c[2], c[1], c[0], c[3]))


def recolor_img(im, f):
    """Recolorea el RGB y conserva el alfa, si lo hay."""
    alfa = im.getchannel('A') if im.mode == 'RGBA' else None
    rgb = im.convert('RGB')
    px = [tuple(min(255, round(c * 255)) for c in f(*(x / 255 for x in p))) for p in rgb.getdata()]
    out = Image.new('RGB', im.size)
    out.putdata(px)
    if alfa:
        out.putalpha(alfa)
    return out


def blp1(im):
    """BLP1 con paleta de 256 colores y mipmaps hasta 1×1. Con RGBA guarda alfa de 8 bits; sin alfa, como los brillos
    del juego (aditivos)."""
    w, h = im.size
    alfa = im.mode == 'RGBA'
    rgb = im.convert('RGB')
    q = rgb.quantize(256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    pal = q.getpalette()[:768]
    pal += [0] * (768 - len(pal))
    bgra = b''.join(bytes((pal[3 * i + 2], pal[3 * i + 1], pal[3 * i], 0)) for i in range(256))
    niveles, img = [], im
    while True:
        n = img.convert('RGB').quantize(palette=q, dither=Image.Dither.NONE).tobytes()
        niveles.append(n + img.getchannel('A').tobytes() if alfa else n)
        if img.size == (1, 1):
            break
        img = img.resize((max(1, img.size[0] // 2), max(1, img.size[1] // 2)), Image.Resampling.BOX)
    offs, p = [], 156 + 1024
    for n in niveles:
        offs.append(p)
        p += len(n)
    head = b'BLP1' + struct.pack('<6I', 1, 8 if alfa else 0, w, h, 4 if alfa else 5, 1)
    head += struct.pack('<16I', *(offs + [0] * (16 - len(offs))))
    head += struct.pack('<16I', *([len(n) for n in niveles] + [0] * (16 - len(niveles))))
    return head + bgra + b''.join(niveles)


if __name__ == '__main__':
    proyecto, shield, out = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
    br, ra, tx = proyecto / 'efectos/burning-rage', proyecto / 'efectos/radiance', proyecto / 'texturas/burning-rage'
    out.mkdir(parents=True, exist_ok=True)
    for k, c in enumerate(COLORES):
        shutil.copyfile(br / f'Burning Rage {c}.mdx', out / f'BurningRage{k + 1}.mdx')
    for t in ('AzureGlow5', 'VerdantGlow3', 'EmberGlow7', 'CrimsonGlow2', 'RoyalGlow02'):
        shutil.copyfile(br / f'{t}.blp', out / f'{t}.blp')
    for k, (desde, f, nombre, propia, juego) in enumerate([
            ('Blue', plata, 'Plata', 'AzureGlow5', 'Blue_Glow2'),
            ('Purple', violeta, 'Violeta', 'RoyalGlow02', 'Purple_Glow')]):
        (out / f'BurningRage{9 + k}.mdx').write_bytes(recolor_mdx((br / f'Burning Rage {desde}.mdx').read_bytes(), f, {
            f'{propia}.blp': f'{nombre}Glow.blp', f'Textures\\{juego}.blp': f'war3mapImported\\{nombre}Brillo.blp'}))
        (out / f'{nombre}Glow.blp').write_bytes(blp1(recolor_img(jpeg_blp(br / f'{propia}.blp'), f)))
        (out / f'{nombre}Brillo.blp').write_bytes(blp1(recolor_img(Image.open(tx / f'{juego}-original.blp'), f)))
    shutil.copyfile(ra / 'Radiance Nature.mdx', out / 'RecargaVerde.mdx')
    shutil.copyfile(ra / 'Radiance Crimson.mdx', out / 'RecargaRoja.mdx')
    (out / 'TiendaEsfera.mdx').write_bytes(esfera_v14g.modelo(shield.read_bytes(), rubi_si=False))
    print('ok', sorted(p.name for p in out.iterdir()))
