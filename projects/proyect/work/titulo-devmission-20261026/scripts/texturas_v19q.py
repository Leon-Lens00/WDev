#!/usr/bin/env python3
"""v19q (19/11/2026): la ventana de la carta de v19o, ahora de 330 × 540 px (Leon: "los cuadros podrian ser mas grande o
largos"). Mismo método que texturas_v19o.py:

v19o: ventana de la carta con el mismo marco que las ventanas de la tienda (Leon: "con las ventanas
nativas que tenemos, ese mismo formato de ventanas y cuadros que tiene la tienda de armas").

CuaCarta: ShopPanelL (tienda-prototipo-20261101) en nueve partes, para 330 × 540 px en pantalla. Esquinas, bordes y la
gema de media altura conservan el tamaño con que se ven en la tienda (ShopPanelL se dibuja a 430 × 784, es decir
0,84 × 1,531 px de pantalla por píxel de textura); los bordes se estiran sólo a lo largo y el fondo al tamaño que
queda. La textura es de 512 × 512 y el juego la estira a 330 × 540.

Necesita Pillow (plot-env). Uso: texturas_v19q.py DIR_TEXTURAS_TIENDA DIR_SALIDA
Escribe CuaCarta.png y CuaCarta.blp (BLP con grid.py de hud-calibracion-20261025).
"""
from pathlib import Path
import sys

from PIL import Image

sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts')
import grid  # noqa: E402

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
dst.mkdir(parents=True, exist_ok=True)
im = Image.open(src / 'ShopPanelL.png').convert('RGBA')
assert im.size == (512, 512)
SX, SY = 430 / 512, 784 / 512          # pantalla por píxel de la textura, en la tienda
W, H = 330, 540                         # carta en pantalla
TX, TY = 512 / W, 512 / H               # textura de la carta por píxel de pantalla
CW, CH = 96, 64                         # esquina en la fuente
GEMA = (216, 296)                       # gema de los lados en la fuente (alto)


def tam(w, h):
    return max(1, round(w * SX * TX)), max(1, round(h * SY * TY))


out = Image.new('RGBA', (512, 512))
cw, ch = tam(CW, CH)
gh = tam(0, GEMA[1] - GEMA[0])[1]
# Fondo.
out.paste(im.crop((CW, CH, 512 - CW, 512 - CH)).resize((512 - 2 * cw, 512 - 2 * ch), Image.LANCZOS), (cw, ch))
# Bordes de arriba y abajo.
out.paste(im.crop((CW, 0, 512 - CW, CH)).resize((512 - 2 * cw, ch), Image.LANCZOS), (cw, 0))
out.paste(im.crop((CW, 512 - CH, 512 - CW, 512)).resize((512 - 2 * cw, ch), Image.LANCZOS), (cw, 512 - ch))
# Lados: borde liso (sin la gema) estirado y la gema en el centro.
for x0, xd in ((0, 0), (512 - CW, 512 - cw)):
    liso = im.crop((x0, CH, x0 + CW, GEMA[0]))
    out.paste(liso.resize((cw, 512 - 2 * ch), Image.LANCZOS), (xd, ch))
    gema = im.crop((x0, GEMA[0], x0 + CW, GEMA[1])).resize((cw, gh), Image.LANCZOS)
    out.paste(gema, (xd, (512 - gh) // 2))
# Esquinas.
for x0, y0 in ((0, 0), (512 - CW, 0), (0, 512 - CH), (512 - CW, 512 - CH)):
    out.paste(im.crop((x0, y0, x0 + CW, y0 + CH)).resize((cw, ch), Image.LANCZOS),
              (0 if x0 == 0 else 512 - cw, 0 if y0 == 0 else 512 - ch))
out.save(dst / 'CuaCarta.png')
print('CuaCarta', out.size, 'esquina', (cw, ch), 'gema', gh, grid.blp(out, dst / 'CuaCarta.blp')[:12])
