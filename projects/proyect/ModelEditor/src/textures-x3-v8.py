"""One localized luminous sweep; all V7 textures are preserved verbatim."""
from pathlib import Path
from PIL import Image
import math, struct, hashlib, json

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/x3-v8'; EV=ROOT/'evidence/x3-v8'
size=256
# Index selects pink-to-white temperature; opacity remains independent.
palette=[(255,round(30+170*(i/255)**2),round(105+123*(i/255)**1.2)) for i in range(256)]
indices=[]; alphas=[]
for y in range(size):
 for x in range(size):
  u=(x+.5)/size; v=(y+.5)/size
  center=.5+.028*math.cos(2*math.pi*v)+.009*math.cos(6*math.pi*v)
  d=(u-center)/.19
  body=max(0,1-d*d)**2
  hot=math.exp(-((u-center)/.060)**2)
  edge=math.sin(math.pi*v)**.65
  indices.append(round(255*hot))
  alphas.append(round(255*body*edge))
im=Image.frombytes('RGBA',(size,size),bytes(c for i,a in zip(indices,alphas) for c in (*palette[i],a)))
im.save(OUT/'Pulse.png')
mips=[]; level=im
while True:
 data=list(level.get_flattened_data())
 # Quantize only the color ramp; alpha stays full 8-bit at every mip.
 ix=bytes(min(range(256),key=lambda j:sum((palette[j][k]-p[k])**2 for k in range(3))) for p in data)
 mips.append(ix+bytes(p[3] for p in data))
 if level.size==(1,1):break
 level=level.resize((max(1,level.width//2),max(1,level.height//2)),Image.Resampling.LANCZOS)
offsets=[0]*16; lengths=[0]*16; pos=1180
for i,data in enumerate(mips):offsets[i]=pos;lengths[i]=len(data);pos+=len(data)
raw=b'BLP1'+struct.pack('<6I',1,8,size,size,4,1)+struct.pack('<16I',*offsets)+struct.pack('<16I',*lengths)+bytes(c for r,g,b in palette for c in (b,g,r,255))+b''.join(mips)
path=OUT/'Pulse.blp';path.write_bytes(raw)
base=offsets[0];count=size*size
rgba=bytes(c for i in range(count) for c in (*palette[raw[base+i]],raw[base+count+i]))
assert rgba==im.tobytes()
assert struct.unpack_from('<6I',raw,4)==(1,8,size,size,4,1)
assert all(alphas[y*size]==alphas[y*size+size-1]==0 for y in range(size))
records=json.loads((EV/'textures.json').read_text())
records=[r for r in records if r['file']!='Pulse.blp']
records.append(dict(file=path.name,size=size,mips=len(mips),rgbaSha256=hashlib.sha256(rgba).hexdigest(),sha256=hashlib.sha256(raw).hexdigest(),origin='original procedural V8 pulse',headerPixelsAndMipBytes='PASS'))
(EV/'textures.json').write_text(json.dumps(records,indent=2)+'\n')
print('V8 localized pulse texture: Classic BLP1, transparent clamp borders, 9 mipmaps')
