"""Hue-shift the stock glow; preserve the original Flare/star and all source alpha."""
from pathlib import Path
from PIL import Image
import colorsys,json,struct,hashlib,shutil
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/brillo-gradiente';OUT.mkdir(exist_ok=True)
palette=json.loads((ROOT/'assets/palette.json').read_text())
source=Image.open(ROOT/'assets/Blue_Glow2.blp').convert('RGBA')
records=[]
for color in palette:
    th,ts,tv=colorsys.rgb_to_hsv(*(x/255 for x in color['rgb']))
    pixels=[]
    for r,g,b,a in source.get_flattened_data():
        h,s,v=colorsys.rgb_to_hsv(r/255,g/255,b/255)
        hue=h if color['index']==1 else th
        shape=colorsys.hsv_to_rgb(hue%1,1,1)
        pixels.append(tuple(round(255*(v*(1-s)+v*s*tv*((1-ts)+ts*x))) for x in shape)+(a,))
    im=Image.new('RGBA',source.size);im.putdata(pixels)
    # Palette shared by all mips; color quantization never changes the alpha bytes.
    pal=im.convert('RGB').quantize(colors=256,method=Image.Quantize.MEDIANCUT)
    table=pal.getpalette();table=table+[0]*(768-len(table));mips=[];level=im
    while True:
        indices=level.convert('RGB').quantize(palette=pal,dither=Image.Dither.NONE).tobytes()
        mips.append(indices+level.getchannel('A').tobytes())
        if level.size==(1,1):break
        level=level.resize((max(1,level.width//2),max(1,level.height//2)),Image.Resampling.LANCZOS)
    offsets=[0]*16;sizes=[0]*16;pos=1180
    for i,data in enumerate(mips):offsets[i]=pos;sizes[i]=len(data);pos+=len(data)
    header=b'BLP1'+struct.pack('<6I',1,8,*im.size,4,1)+struct.pack('<16I',*offsets)+struct.pack('<16I',*sizes)
    table=bytes(v for i in range(256) for v in (table[3*i+2],table[3*i+1],table[3*i],255))
    p=OUT/f'Glow_{color["index"]:02}.blp';p.write_bytes(header+table+b''.join(mips))
    check=Image.open(p).convert('RGBA');assert check.getchannel('A').tobytes()==source.getchannel('A').tobytes()
    error=max(abs(a-b) for a,b in zip(check.convert('RGB').tobytes(),im.convert('RGB').tobytes()))
    assert error<=12,error
    assert struct.unpack_from('<6I',p.read_bytes(),4)==(1,8,*im.size,4,1)
    data=p.read_bytes()
    for i,mip in enumerate(mips):
        assert sizes[i]==2*max(1,im.width>>i)*max(1,im.height>>i)
        assert data[offsets[i]:offsets[i]+sizes[i]]==mip
    records.append({'color':color['index'],'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'maxChannelQuantizationError':error,'mips':len(mips),'alpha':'exact'})
for name in ['Flare.blp','star5tga.blp']:shutil.copy2(ROOT/'assets'/name,OUT/name)
(ROOT/'evidence/brillo/gradient-textures.json').write_text(json.dumps(records,indent=2)+'\n')
print(json.dumps({'textures':len(records),'maxError':max(x['maxChannelQuantizationError'] for x in records),'alpha':'exact','header':'PASS'}))
