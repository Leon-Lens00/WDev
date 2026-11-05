"""v12: quita las letras de las texturas; el texto pasa a texttags (texttags_v12.py).
clear: la pieza entera era texto (queda transparente, la unidad sigue de ancla).
cols: columnas de texto a alfa 0, se conservan los ornamentos.
rows: rellena fila a fila entre los bordes del texto (fondos con degradado vertical).
copy: tapa el texto con las filas de debajo (fondos con grano)."""
import json, sys
from pathlib import Path
import numpy as np
from PIL import Image
sys.path.insert(0, 'scripts'); sys.argv = sys.argv[:1] + ['.', '.']
import texturas_heroe as th

P = [
 ('HeroTitleL','v9k','cols',(.43,1.01)), ('HeroTitleR','v9k','cols',(-.01,.53)),
 ('BossTitleL','v9j','cols',(.44,1.01)), ('BossTitleR','v9j','cols',(-.01,.50)),
 ('StratTitle','v9v','cols',(.225,.75)),
 ('BossLabel','v9j','clear',None), ('BossName','v9j','clear',None),
 ('StratLabel','v9t','clear',None), ('StratEnter','v9t','clear',None),
 ('ModeTitle','v8','clear',None), ('ModeName','v8','clear',None),
 ('ModeDesc','v8','clear',None),
 ('HeroPanelB','v9k','rows',(.2,.8,.74,.92)), ('LockGlow','v9i','rows',(.22,.78,.2,.8)),
 ('BossPick','v9r','rows',(.22,.78,.25,.75)), ('BossPickGlow','v9r','rows',(.22,.78,.2,.8)),
 ('TitleStart','v8e','rows',(.28,.72,.25,.75)), ('TitleStartHover','v8e','rows',(.28,.72,.25,.75)),
 ('StratInfo','v9u','copy',(.25,.75,.12,.5)),
]
out = Path('v12/texturas'); info = {}
for name, ver, how, a in P:
    im = np.array(Image.open(f'{ver}/texturas/{name}.png').convert('RGBA')).astype(float)
    h, w = im.shape[:2]
    if how == 'clear':
        ys, xs = np.where(im[..., 3] > 60)
        info[name] = [int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max()), w, h]
        im[..., 3] = 0
    elif how == 'cols':
        x0, x1 = int(a[0] * w), int(a[1] * w)
        x0, x1 = max(x0, 0), min(x1, w)
        sub = im[:, x0:x1, 3]
        ys, xs = np.where(sub > 60)
        info[name] = [int(xs.min()) + x0, int(ys.min()), int(xs.max()) + x0, int(ys.max()), w, h]
        im[:, x0:x1, 3] = 0
    else:
        rx0, rx1, ry0, ry1 = int(a[0]*w), int(a[1]*w), int(a[2]*h), int(a[3]*h)
        lum = im[ry0:ry1, rx0:rx1, :3].mean(2)
        ys, xs = np.where(lum > lum.max() * .55)
        m = 7
        x0, x1 = max(xs.min()+rx0-m, 1), min(xs.max()+rx0+m, w-5)
        y0, y1 = ys.min()+ry0-m, ys.max()+ry0+m
        info[name] = [int(xs.min()+rx0), int(ys.min()+ry0), int(xs.max()+rx0), int(ys.max()+ry0), w, h]
        if how == 'rows':
            for y in range(y0, y1 + 1):
                l = im[y, x0-4:x0].mean(0); r = im[y, x1+1:x1+5].mean(0)
                t = np.linspace(0, 1, x1 - x0 + 1)[:, None]
                im[y, x0:x1+1] = l * (1 - t) + r * t
        else:
            hh = y1 - y0 + 1
            patch = im[y1 + 2:y1 + 2 + hh, x0:x1 + 1].copy()
            f = np.minimum(np.minimum(np.arange(hh), np.arange(hh)[::-1]) / 5., 1)[:, None]
            g = np.minimum(np.minimum(np.arange(x1-x0+1), np.arange(x1-x0+1)[::-1]) / 8., 1)[None, :]
            mask = (f * g)[..., None]
            im[y0:y1+1, x0:x1+1] = im[y0:y1+1, x0:x1+1] * (1-mask) + patch * mask
    res = Image.fromarray(np.clip(im, 0, 255).astype('uint8'), 'RGBA')
    res.save(out / f'{name}.png')
    th.blp(res, out / f'{name}.blp')
json.dump(info, open('v12/texturas/cajas.json', 'w'), indent=0)
print(info)
# hoja de control sobre verde
names = [p[0] for p in P if p[2] != 'clear']
sheet = Image.new('RGB', (1500, 780), (30, 70, 35)); x = y = 0
for n in names:
    i = Image.open(out / f'{n}.png'); i.thumbnail((360, 360))
    if x + i.width > 1500: x = 0; y += 200
    sheet.paste(i, (x, y), i); x += i.width + 10
sheet.save(out / 'control.png')
