"""Extract the installed Classic palette and neutralize the original blue glow mask.

Run with the project's isolated plot-env Python (Pillow). Stock inputs are extracted
from the installed 1.27b MPQ, never downloaded from a preview service.
"""
from pathlib import Path
from PIL import Image
import json
import struct
import hashlib

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets'
names = ['Red','Blue','Cyan','Purple','Yellow','Orange','Green','Pink','LightGray','LightBlue','Aqua','Brown']
labels = ['Rojo','Azul','Cian','Púrpura','Amarillo','Naranja','Verde','Rosa','Gris claro','Azul claro','Verde oscuro','Marrón']
palette = []
for i, (name,label) in enumerate(zip(names,labels)):
    p = ASSETS / f'TeamColor{i:02}.blp'
    im = Image.open(p).convert('RGB')
    rgb = list(im.getpixel((0,0)))
    assert all(list(px) == rgb for px in im.get_flattened_data())
    palette.append(dict(index=i,name=name,label=label,rgb=rgb,hex='#'+''.join(f'{c:02X}' for c in rgb),source=p.name,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))

def neutral_texture(source_name, target_name):
    source=Image.open(ASSETS/source_name).convert('RGBA')
    neutral=Image.new('RGBA',source.size)
    neutral.putdata([(max(r,g,b),)*3+(a,) for r,g,b,a in source.get_flattened_data()])
    neutral.save(ASSETS/(target_name+'.png'))
    # BLP1, palette, alpha 8, correct Classic pictureType/subType and full mip chain.
    mips=[]
    im=neutral
    while True:
        rgba=list(im.get_flattened_data())
        mips.append(bytes(px[0] for px in rgba)+bytes(px[3] for px in rgba))
        if im.size==(1,1): break
        im=im.resize((max(1,im.width//2),max(1,im.height//2)),Image.Resampling.LANCZOS)
    offsets=[0]*16;sizes=[0]*16;pos=156+1024
    for i,data in enumerate(mips): offsets[i]=pos;sizes[i]=len(data);pos+=len(data)
    header=b'BLP1'+struct.pack('<6I',1,8,*source.size,4,1)+struct.pack('<16I',*offsets)+struct.pack('<16I',*sizes)
    color_table=bytes(v for i in range(256) for v in (i,i,i,255))
    target=ASSETS/(target_name+'.blp')
    target.write_bytes(header+color_table+b''.join(mips))
    check=Image.open(target).convert('RGBA')
    assert check.tobytes()==neutral.tobytes()
    assert struct.unpack_from('<6I',target.read_bytes(),4)==(1,8,*source.size,4,1)
    for i,data in enumerate(mips):
        assert len(data)==sizes[i]
        assert offsets[i]+sizes[i]<=target.stat().st_size
    return dict(source=source_name,target=target.name,mips=len(mips),pixels='PASS',header='PASS',sha256=hashlib.sha256(target.read_bytes()).hexdigest())

textures=[neutral_texture(a,b) for a,b in [('Flare.blp','ShotFlareNeutral'),('star5tga.blp','ShotStarNeutral'),('Blue_Glow2.blp','ShotGlowNeutral')]]
(ASSETS/'palette.json').write_text(json.dumps(palette,ensure_ascii=False,indent=2)+'\n')
(ROOT/'evidence/textures.json').write_text(json.dumps(textures,indent=2)+'\n')
print(json.dumps({'colors':len(palette),'textures':textures}))
