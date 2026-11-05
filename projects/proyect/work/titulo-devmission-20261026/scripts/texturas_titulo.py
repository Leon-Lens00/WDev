"""Textures for the Dev Mission title screen, first step (user mockup, 26/10/2026).

The pictures are UI-system dummies ('uidm', UI\\dummy.mdl) whose material is FilterMode Transparent (alpha
test), so every texture here has hard alpha (0 or 255) and its edge colours are darkened instead of blended.
The quad is stretched to the on-screen aspect by the dummy's sequence, so each texture is drawn at the
displayed aspect and then resized to a power-of-two canvas (at most 512).

- TitleLogo: the old map's DevMission.tga (512 x 256, real alpha), cropped to its opaque area.
- TitleStart / TitleStartHover: blue button with a gold frame and "Start", as in the mockup.
- TitleGemGrey and TitleGem1..8: rhombus with a metal frame; grey and the eight 1.27b player colours.

Usage: texturas_titulo.py LOGO_TGA OUT_DIR
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import json, sys
sys.path.insert(0, '/home/snz/Documentos/ChatGPT/Proyect/work/hud-calibracion-20261025/scripts')
from grid import blp

LOGO, OUT = Path(sys.argv[1]), Path(sys.argv[2])
FONT = '/usr/share/fonts/TTF/OpenSans-SemiBold.ttf'
PLAYERS = [(255, 3, 3), (0, 66, 255), (28, 230, 185), (84, 0, 129),
           (255, 252, 1), (254, 138, 14), (32, 192, 0), (229, 91, 176)]
GREY = (92, 96, 104)


def harden(im, cut=150):
    """Alpha test: keep pixels at or above cut, darken the colour of the soft ones that survive."""
    im = im.convert('RGBA')
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a < cut:
                px[x, y] = (0, 0, 0, 0)
            else:
                k = a / 255
                px[x, y] = (int(r * k), int(g * k), int(b * k), 255)
    return im


def logo():
    src = Image.open(LOGO).convert('RGBA')
    box = src.getchannel('A').point(lambda a: 255 if a >= 150 else 0).getbbox()
    crop = src.crop(box)
    return crop, harden(crop.resize((512, 256), Image.Resampling.LANCZOS))


def vgrad(size, top, bottom):
    w, h = size
    im = Image.new('RGBA', size)
    d = ImageDraw.Draw(im)
    for y in range(h):
        t = y / max(1, h - 1)
        d.line([(0, y), (w, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(top, bottom)) + (255,))
    return im


def button(hover):
    # Drawn at 4x the displayed 199 x 62 px, then stretched to 256 x 128.
    W, H, r = 796, 248, 18
    base = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    mask = Image.new('L', (W, H), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, W - 1, H - 1], r, fill=255)
    gold = vgrad((W, H), (255, 236, 160) if hover else (236, 200, 110), (150, 96, 30) if hover else (120, 76, 22))
    base.paste(gold, (0, 0), mask)
    d = ImageDraw.Draw(base)
    d.rounded_rectangle([0, 0, W - 1, H - 1], r, outline=(30, 18, 6, 255), width=6)
    inner = [22, 22, W - 23, H - 23]
    d.rounded_rectangle(inner, 8, fill=(20, 14, 6, 255))
    fill = vgrad((inner[2] - inner[0] - 8, inner[3] - inner[1] - 8),
                 (44, 92, 200) if hover else (26, 60, 150), (10, 30, 92) if hover else (6, 18, 64))
    fmask = Image.new('L', fill.size, 0)
    ImageDraw.Draw(fmask).rounded_rectangle([0, 0, fill.width - 1, fill.height - 1], 6, fill=255)
    base.paste(fill, (inner[0] + 4, inner[1] + 4), fmask)
    # Gloss on the upper half of the blue face.
    gloss = Image.new('RGBA', (fill.width, fill.height // 2), (255, 255, 255, 34 if hover else 22))
    gm = Image.new('L', gloss.size, 0)
    ImageDraw.Draw(gm).rounded_rectangle([0, 0, gloss.width - 1, gloss.height + 10], 6, fill=255)
    base.alpha_composite(Image.composite(gloss, Image.new('RGBA', gloss.size), gm), (inner[0] + 4, inner[1] + 4))
    font = ImageFont.truetype(FONT, 104)
    text = 'Start'
    tw = d.textlength(text, font=font)
    x, y = (W - tw) / 2, H / 2 - 4
    shadow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).text((x + 4, y + 5), text, font=font, fill=(0, 0, 0, 200), anchor='lm')
    base.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(3)))
    d.text((x, y), text, font=font, fill=(255, 250, 225, 255) if hover else (238, 232, 210, 255), anchor='lm')
    return base, harden(base.resize((256, 128), Image.Resampling.LANCZOS))


def gem(colour):
    # Displayed about 56 x 65 px: drawn at 448 x 520, stretched to 128 x 128.
    W, H = 448, 520
    cx, cy = W / 2, H / 2
    im = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    outer = [(cx, 6), (W - 6, cy), (cx, H - 6), (6, cy)]
    d.polygon(outer, fill=(24, 22, 20, 255))
    frame = [(cx, 26), (W - 30, cy), (cx, H - 26), (30, cy)]
    d.polygon(frame, fill=(150, 146, 140, 255))
    # Bevel: light upper-left edges, dark lower-right edges.
    d.polygon([(cx, 26), (30, cy), (62, cy), (cx, 62)], fill=(214, 210, 200, 255))
    d.polygon([(cx, H - 26), (W - 30, cy), (W - 62, cy), (cx, H - 62)], fill=(70, 66, 62, 255))
    d.polygon([(cx, 26), (W - 30, cy), (W - 62, cy), (cx, 62)], fill=(176, 172, 164, 255))
    d.polygon([(cx, H - 26), (30, cy), (62, cy), (cx, H - 62)], fill=(104, 100, 94, 255))
    stone = [(cx, 74), (W - 74, cy), (cx, H - 74), (74, cy)]
    d.polygon(stone, fill=(12, 10, 10, 255))
    r, g, b = colour
    dark = (int(r * 0.35), int(g * 0.35), int(b * 0.35), 255)
    mid = (int(r * 0.75), int(g * 0.75), int(b * 0.75), 255)
    lite = tuple(min(255, int(c * 0.55 + 255 * 0.45)) for c in colour) + (255,)
    s = [(cx, 84), (W - 84, cy), (cx, H - 84), (84, cy)]
    centre = (cx, cy)
    d.polygon([s[0], s[1], centre], fill=mid)
    d.polygon([s[1], s[2], centre], fill=dark)
    d.polygon([s[2], s[3], centre], fill=(int(r * 0.55), int(g * 0.55), int(b * 0.55), 255))
    d.polygon([s[3], s[0], centre], fill=lite)
    # Table facet and a highlight.
    t = [(cx, cy - 92), (cx + 70, cy), (cx, cy + 92), (cx - 70, cy)]
    d.polygon(t, fill=tuple(min(255, int(c * 0.85 + 40)) for c in colour) + (255,))
    d.polygon([(cx - 40, cy - 60), (cx - 14, cy - 98), (cx - 4, cy - 70), (cx - 30, cy - 34)], fill=(255, 255, 255, 200))
    return im, harden(im.resize((128, 128), Image.Resampling.LANCZOS))


if __name__ == '__main__':
    OUT.mkdir(parents=True, exist_ok=True)
    report = {}
    items = [('TitleLogo', logo()), ('TitleStart', button(False)), ('TitleStartHover', button(True)),
             ('TitleGemGrey', gem(GREY))]
    items += [(f'TitleGem{n + 1}', gem(c)) for n, c in enumerate(PLAYERS)]
    for name, (preview, tex) in items:
        preview.save(OUT / f'{name}-previa.png')
        tex.save(OUT / f'{name}.png')
        report[name] = {'size': tex.size, 'blp_sha256': blp(tex, OUT / f'{name}.blp')}
    (OUT / 'texturas.json').write_text(json.dumps(report, indent=2))
    print(json.dumps(report, indent=2))
