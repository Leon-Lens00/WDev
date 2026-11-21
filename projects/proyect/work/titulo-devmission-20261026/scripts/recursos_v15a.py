#!/usr/bin/env python3
"""Recursos de v15a (05/11/2026): HudCarga, el relleno de la barra de sobrecarga, y los DISBTN de las armas.

Blanco (el script lo tiñe de verde a rojo con SetUnitVertexColor) en la franja central de 32 de alto de una textura de
256 x 64, con bordes suaves; el resto transparente. El cuadro se dibuja a 156,6 x 21,2 px (el hueco de HudBlindaje a 165
x 20) y la franja ocupa su mitad central: así la proporción del cuadro queda por debajo de 11, el tope del dummy.

Los iconos BTNArma0..4 no tenían versión desactivada desde que se importaron: con el juego en pausa salían como cuadros
verdes. DISBTNArmaN es el mismo icono en gris al 45%, en ReplaceableTextures\\CommandButtonsDisabled\\, donde lo busca el juego.

Uso (con el python de plot-env): recursos_v15a.py SALIDA_DIR [BTN_DIR con BTNArma0..4.blp extraídos de v14n]
"""
from pathlib import Path
import sys
import numpy as np
from PIL import Image
sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts')
from grid import blp

out = Path(sys.argv[1])
out.mkdir(parents=True, exist_ok=True)
y = np.arange(64) + 0.5
a = np.clip(np.minimum(y - 16, 48 - y) / 1.5, 0, 1)
x = np.arange(256) + 0.5
ax = np.clip(np.minimum(x, 256 - x) / 1.5, 0, 1)
alpha = (a[:, None] * ax[None, :] * 255).astype('uint8')
brillo = (215 + 40 * (1 - np.abs(y - 28) / 20).clip(0, 1)).astype('uint8')
rgba = np.zeros((64, 256, 4), 'uint8')
rgba[..., 0] = rgba[..., 1] = rgba[..., 2] = brillo[:, None]
rgba[..., 3] = alpha
im = Image.fromarray(rgba, 'RGBA')
im.save(out / 'HudCarga.png')
blp(im, out / 'HudCarga.blp')
print('ok', (out / 'HudCarga.blp').stat().st_size)

if len(sys.argv) > 2:
    for i in range(5):
        b = Image.open(Path(sys.argv[2]) / f'BTNArma{i}.blp').convert('RGBA')
        g = b.convert('L').point(lambda v: int(v * 0.45))
        # Pillow no lee el alfa de estos BLP1 (lo da a 0); los iconos de botón son opacos.
        d = Image.merge('RGBA', (g, g, g, Image.new('L', b.size, 255)))
        blp(d, out / f'DISBTNArma{i}.blp')
    print('disbtn 5')
