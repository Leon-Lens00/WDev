#!/usr/bin/env python3
"""v19r (19/11/2026): ventanas de los paneles de mejoras (Leon: "un cuadro a la izquierda superior de ver mejoras de boss
en rojo y a la derecha en verde ver mejoras de jugador ... al click a uno debajo abra un cuadro grande con contorno").
Mismo método que texturas_v19o.py (ShopPanelL en nueve partes; esquinas, bordes y gema con el tamaño de la tienda):
- CuaPanel: 340 × 310 px (iconos elegidos).
- CuaDetalle: 340 × 290 px (icono grande y descripción).
Necesita Pillow (plot-env). Uso: texturas_v19r.py DIR_TEXTURAS_TIENDA DIR_SALIDA
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
SX, SY = 430 / 512, 784 / 512
CW, CH = 96, 64
GEMA = (216, 296)


def ventana(W, H):
    TX, TY = 512 / W, 512 / H
    tam = lambda w, h: (max(1, round(w * SX * TX)), max(1, round(h * SY * TY)))
    out = Image.new('RGBA', (512, 512))
    cw, ch = tam(CW, CH)
    gh = tam(0, GEMA[1] - GEMA[0])[1]
    out.paste(im.crop((CW, CH, 512 - CW, 512 - CH)).resize((512 - 2 * cw, 512 - 2 * ch), Image.LANCZOS), (cw, ch))
    out.paste(im.crop((CW, 0, 512 - CW, CH)).resize((512 - 2 * cw, ch), Image.LANCZOS), (cw, 0))
    out.paste(im.crop((CW, 512 - CH, 512 - CW, 512)).resize((512 - 2 * cw, ch), Image.LANCZOS), (cw, 512 - ch))
    for x0, xd in ((0, 0), (512 - CW, 512 - cw)):
        out.paste(im.crop((x0, CH, x0 + CW, GEMA[0])).resize((cw, 512 - 2 * ch), Image.LANCZOS), (xd, ch))
        out.paste(im.crop((x0, GEMA[0], x0 + CW, GEMA[1])).resize((cw, gh), Image.LANCZOS), (xd, (512 - gh) // 2))
    for x0, y0 in ((0, 0), (512 - CW, 0), (0, 512 - CH), (512 - CW, 512 - CH)):
        out.paste(im.crop((x0, y0, x0 + CW, y0 + CH)).resize((cw, ch), Image.LANCZOS),
                  (0 if x0 == 0 else 512 - cw, 0 if y0 == 0 else 512 - ch))
    return out, (cw, ch), gh


for nom, (w, h) in (('CuaPanel', (340, 310)), ('CuaDetalle', (340, 290))):
    out, esq, gh = ventana(w, h)
    out.save(dst / f'{nom}.png')
    print(nom, (w, h), 'esquina', esq, 'gema', gh, grid.blp(out, dst / f'{nom}.blp')[:12])
