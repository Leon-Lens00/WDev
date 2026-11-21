#!/usr/bin/env python3
"""v19v (19/11/2026): cartas de Mutación Evo con la ventana de los paneles de la tienda (Leon: "con el diseño de los
cuadros de mejora ... y otro cuadro debajo con la descripción del cambio al enemigo").
Mismo método que texturas_v19r.py (ShopPanelL en nueve partes), con las esquinas y bordes a escala f para que quepan en
cuadros más bajos:
- CuaMutCarta: 270 × 250 px (icono y nombre), f 0,75, con gema.
- CuaMutDes: 270 × 130 px (descripción), f 0,5, sin gema.
Necesita Pillow (plot-env). Uso: texturas_v19v.py DIR_TEXTURAS_TIENDA DIR_SALIDA
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


def ventana(W, H, f, gema):
    TX, TY = 512 / W, 512 / H
    tam = lambda w, h: (max(1, round(w * SX * TX * f)), max(1, round(h * SY * TY * f)))
    out = Image.new('RGBA', (512, 512))
    cw, ch = tam(CW, CH)
    gh = tam(0, GEMA[1] - GEMA[0])[1]
    assert 2 * ch < 512 and 2 * cw < 512, (cw, ch)
    out.paste(im.crop((CW, CH, 512 - CW, 512 - CH)).resize((512 - 2 * cw, 512 - 2 * ch), Image.LANCZOS), (cw, ch))
    out.paste(im.crop((CW, 0, 512 - CW, CH)).resize((512 - 2 * cw, ch), Image.LANCZOS), (cw, 0))
    out.paste(im.crop((CW, 512 - CH, 512 - CW, 512)).resize((512 - 2 * cw, ch), Image.LANCZOS), (cw, 512 - ch))
    for x0, xd in ((0, 0), (512 - CW, 512 - cw)):
        out.paste(im.crop((x0, CH, x0 + CW, GEMA[0])).resize((cw, 512 - 2 * ch), Image.LANCZOS), (xd, ch))
        if gema:
            out.paste(im.crop((x0, GEMA[0], x0 + CW, GEMA[1])).resize((cw, gh), Image.LANCZOS), (xd, (512 - gh) // 2))
    for x0, y0 in ((0, 0), (512 - CW, 0), (0, 512 - CH), (512 - CW, 512 - CH)):
        out.paste(im.crop((x0, y0, x0 + CW, y0 + CH)).resize((cw, ch), Image.LANCZOS),
                  (0 if x0 == 0 else 512 - cw, 0 if y0 == 0 else 512 - ch))
    return out, (cw, ch)


for nom, (w, h), f, gema in (('CuaMutCarta', (270, 250), 0.75, True), ('CuaMutDes', (270, 130), 0.5, False)):
    out, esq = ventana(w, h, f, gema)
    out.save(dst / f'{nom}.png')
    # Vista con la proporción real, para revisarla.
    out.resize((w * 2, h * 2), Image.LANCZOS).save(dst / f'{nom}-vista.png')
    print(nom, (w, h), 'esquina', esq, grid.blp(out, dst / f'{nom}.blp')[:12])
