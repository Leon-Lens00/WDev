"""Convert reference art to Classic paletted BLP1; no creative edits."""
from pathlib import Path
from PIL import Image
import struct, json, hashlib

ROOT = Path(__file__).resolve().parents[1]
ART = Path('/home/snz/Documentos/WarDatsPy/ui-studio/dist/assets/dialogue')
OUT = ROOT / 'assets/UI/Dialogue'

def blp(image, name):
    image = image.convert('RGBA')
    rgb = image.convert('RGB').quantize(colors=256)
    palette = rgb.getpalette()[:768]
    palette += [0] * (768-len(palette))
    bgra = b''.join(bytes((palette[i+2],palette[i+1],palette[i],0)) for i in range(0,768,3))
    levels=[]
    w,h=image.size
    while True:
        mip=image.resize((w,h),Image.Resampling.LANCZOS)
        indices=mip.convert('RGB').quantize(palette=rgb,dither=Image.Dither.NONE).tobytes()
        levels.append(indices+mip.getchannel('A').tobytes())
        if w==1 and h==1:break
        w=max(1,w//2);h=max(1,h//2)
    offsets=[];p=156+1024
    for level in levels:offsets.append(p);p+=len(level)
    header=b'BLP1'+struct.pack('<6I',1,8,*image.size,4,1)
    header+=struct.pack('<16I',*(offsets+[0]*(16-len(offsets))))
    header+=struct.pack('<16I',*([len(x) for x in levels]+[0]*(16-len(levels))))
    payload=header+bgra+b''.join(levels)
    target=OUT/name;target.write_bytes(payload)
    # Pillow's BLP1 decoder reads palette alpha, not the separate alpha plane.
    # Verify that plane here; the independent JS reader checks decoded pixels.
    assert payload[offsets[0]+image.width*image.height:offsets[0]+2*image.width*image.height]==image.getchannel('A').tobytes()
    image.getchannel('A').save(OUT/(name+'.alpha.png'))
    return {'path':str(target),'sha256':hashlib.sha256(payload).hexdigest(),'dimensions':image.size,'mips':len(levels),'alphaBits':8,'compression':1}

if __name__ == "__main__":
    OUT.mkdir(parents=True,exist_ok=True)
    result=[]
    for source,name in [('conversation-frame-v1.png','FrameRed.blp'),('conversation-frame-blue-v1.png','FrameBlue.blp')]:
        result.append(blp(Image.open(ART/source).resize((1024,512),Image.Resampling.LANCZOS),name))
    reference=Image.open(ART/'megaman-reference.png')
    for name,box in [('PortraitX.blp',(144,148,329,294)),('PortraitAlia.blp',(866,148,1051,294))]:
        result.append(blp(reference.crop(box).resize((256,256),Image.Resampling.NEAREST),name))
    (ROOT/'evidence/textures.json').write_text(json.dumps(result,indent=2))
    print(json.dumps(result,indent=2))
