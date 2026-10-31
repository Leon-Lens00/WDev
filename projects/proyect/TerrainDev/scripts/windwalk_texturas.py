"""Recolor the stock Ghost2.blp (blue) for each tinted Windwalk color.

Same per-pixel gradient as ModelEditor/src/textures-gradient.py: the neutral part
of each pixel is kept and its chroma moves to the target hue; alpha is exact.
Run with the isolated Pillow Python, after windwalk_colores.cjs palette:
../work/shots-vol-i-origen-20261022/plot-env/bin/python -I scripts/windwalk_texturas.py
"""
from pathlib import Path
from PIL import Image
import colorsys, hashlib, io, json, struct

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT/'assets/windwalk-originales/Textures/Ghost2.blp'
OUT = ROOT/'assets/windwalk-colores'
assert hashlib.sha256(SOURCE.read_bytes()).hexdigest() == '0225ffcefdfe95fd308cf12881b142cd8a1656dbfc282748a73a01d82987c18c'

def read_jpeg_blp(path):
    # Ghost2 is a JPEG BLP1: the JPEG holds four inverted channels, B G R A.
    # Pillow decodes them as CMYK and drops the 4th (the alpha) into black ink,
    # which made the first recolor opaque with dark borders (black squares in game).
    data = path.read_bytes()
    assert data[:4] == b'BLP1' and struct.unpack('<I', data[4:8])[0] == 0
    offset, size = struct.unpack('<I', data[28:32])[0], struct.unpack('<I', data[92:96])[0]
    header = struct.unpack('<I', data[156:160])[0]
    jpeg = Image.open(io.BytesIO(data[160:160+header]+data[offset:offset+size]))
    assert jpeg.mode == 'CMYK'
    b, g, r, a = (ch.point(lambda v: 255-v) for ch in jpeg.split())
    return Image.merge('RGBA', (r, g, b, a))


source = read_jpeg_blp(SOURCE)
assert source.getchannel('A').getextrema() == (0, 255)
(OUT/'Windwalk').mkdir(parents=True, exist_ok=True)
records = []
for color in json.loads((OUT/'palette.json').read_text()):
    if color['reused']:
        continue
    th, ts, tv = colorsys.rgb_to_hsv(*(x/255 for x in color['rgb']))
    pixels = []
    for r, g, b, a in source.get_flattened_data():
        h, s, v = colorsys.rgb_to_hsv(r/255, g/255, b/255)
        shape = colorsys.hsv_to_rgb(th, 1, 1)
        pixels.append(tuple(round(255*(v*(1-s)+v*s*tv*((1-ts)+ts*x))) for x in shape)+(a,))
    im = Image.new('RGBA', source.size)
    im.putdata(pixels)
    # BLP1 paletted with 8-bit alpha and full mip chain; the palette is shared by all mips.
    pal = im.convert('RGB').quantize(colors=256, method=Image.Quantize.MEDIANCUT, kmeans=8)
    table = pal.getpalette()
    table = table+[0]*(768-len(table))
    mips = []
    level = im
    while True:
        indices = level.convert('RGB').quantize(palette=pal, dither=Image.Dither.NONE).tobytes()
        mips.append(indices+level.getchannel('A').tobytes())
        if level.size == (1, 1):
            break
        level = level.resize((max(1, level.width//2), max(1, level.height//2)), Image.Resampling.LANCZOS)
    offsets = [0]*16
    sizes = [0]*16
    pos = 1180
    for i, data in enumerate(mips):
        offsets[i] = pos
        sizes[i] = len(data)
        pos += len(data)
    header = b'BLP1'+struct.pack('<6I', 1, 8, *im.size, 4, 1)+struct.pack('<16I', *offsets)+struct.pack('<16I', *sizes)
    table = bytes(v for i in range(256) for v in (table[3*i+2], table[3*i+1], table[3*i], 255))
    p = OUT/'Windwalk'/f'Ghost2 {color["name"]}.blp'
    p.write_bytes(header+table+b''.join(mips))
    # Read back with our own decoder: Pillow ignores the alpha bytes of paletted BLP1.
    raw = p.read_bytes()
    count = im.width*im.height
    assert raw[1180+count:1180+2*count] == source.getchannel('A').tobytes()
    bgra = raw[156:1180]
    check = bytes(bgra[4*i+k] for i in raw[1180:1180+count] for k in (2, 1, 0))
    error = max(abs(a-b) for a, b in zip(check, im.convert('RGB').tobytes()))
    assert error <= 12, error
    data = p.read_bytes()
    for i, mip in enumerate(mips):
        assert sizes[i] == 2*max(1, im.width >> i)*max(1, im.height >> i)
        assert data[offsets[i]:offsets[i]+sizes[i]] == mip
    records.append({'name': color['name'], 'internal': f'Windwalk\\Ghost2 {color["name"]}.blp', 'file': f'Windwalk/Ghost2 {color["name"]}.blp',
                    'source': 'Textures/Ghost2.blp', 'sha256': hashlib.sha256(data).hexdigest(), 'maxChannelQuantizationError': error,
                    'mips': len(mips), 'alpha': 'exact'})
(OUT/'textures.json').write_text(json.dumps(records, indent=2)+'\n')
print(json.dumps({'textures': len(records), 'maxError': max(x['maxChannelQuantizationError'] for x in records)}))
