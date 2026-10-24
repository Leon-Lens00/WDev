"""Neutral value mask of Vinz's blue glow, keeping its exact alpha and mip chain."""
from pathlib import Path
from PIL import Image
import struct, hashlib, json
root=Path(__file__).resolve().parents[1]
src=root/'assets/x3-v12/Blue_Glow2.blp'
im=Image.open(src).convert('RGBA')
out=Image.new('RGBA',im.size)
out.putdata([(max(r,g,b),)*3+(a,) for r,g,b,a in im.get_flattened_data()])
pal=Image.new('P',(1,1));pal.putpalette([v for i in range(256) for v in (i,i,i)])
levels=[];sizes=[];offsets=[];cursor=1180
level=out
while True:
    rgb=level.getchannel('R')
    data=rgb.tobytes()+level.getchannel('A').tobytes()
    levels.append(data);sizes.append(len(data));offsets.append(cursor);cursor+=len(data)
    if level.size==(1,1):break
    level=out.resize((max(1,level.width//2),max(1,level.height//2)),Image.Resampling.LANCZOS)
header=b'BLP1'+struct.pack('<6I',1,8,*out.size,4,1)
header+=struct.pack('<16I',*(offsets+[0]*(16-len(offsets))))+struct.pack('<16I',*(sizes+[0]*(16-len(sizes))))
data=header+bytes([v for i in range(256) for v in (i,i,i,255)])+b''.join(levels)
dest=root/'assets/x3-v13/White_Glow2.blp';dest.write_bytes(data)
decoded=Image.open(dest).convert('RGBA')
assert decoded.getchannel('A').tobytes()==im.getchannel('A').tobytes()
assert decoded.tobytes()==out.tobytes()
(root/'evidence/x3-v13/texture-neutral.json').write_text(json.dumps({'source':str(src),'sourceSha256':hashlib.sha256(src.read_bytes()).hexdigest(),'output':str(dest),'sha256':hashlib.sha256(data).hexdigest(),'mips':len(levels),'alphaExact':True,'method':'RGB=max(R,G,B), preserved alpha; grayscale BLP1 palette'},indent=2))
print(dest)
