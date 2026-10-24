"""One localized luminous sweep; all V7 textures are preserved verbatim."""
from pathlib import Path
from PIL import Image
import math, struct, hashlib, json

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/x3-v10'; EV=ROOT/'evidence/x3-v10'
size=256
# Index selects pink-to-white temperature; opacity remains independent.
palette=[(255,round(30+170*(i/255)**2),round(105+123*(i/255)**1.2)) for i in range(256)]
indices=[]; alphas=[]
for y in range(size):
 for x in range(size):
  u=(x+.5)/size; v=(y+.5)/size
  center=.5+.047*math.cos(2*math.pi*v)+.018*math.cos(6*math.pi*v)
  # Tapered trailing tongues and a narrower white ridge keep the blue readable.
  width=.15 if u<center else .23
  d=(u-center)/width
  body=max(0,1-d*d)**2
  hot=math.exp(-((u-center)/.046)**2)
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
records.append(dict(file=path.name,size=size,mips=len(mips),rgbaSha256=hashlib.sha256(rgba).hexdigest(),sha256=hashlib.sha256(raw).hexdigest(),origin='original procedural V10 pulse',headerPixelsAndMipBytes='PASS'))
(EV/'textures.json').write_text(json.dumps(records,indent=2)+'\n')
print('V10 localized pulse texture: Classic BLP1, transparent clamp borders, 9 mipmaps')

# Localized moving white mask; green color is in the geoset animation.
size=128
im=Image.new('RGBA',(size,size)); pixels=[]
for y in range(size):
 for x in range(size):
  u=(x+.5)/size;v=(y+.5)/size
  a=max(0,1-((u-.5)/.25)**2)**.65 * math.sin(math.pi*v)**.4
  pixels.append((255,255,255,round(255*a)))
im.putdata(pixels);im.save(OUT/'Arc.png')
mips=[];level=im
while True:
 data=list(level.get_flattened_data());mips.append(bytes([255])*len(data)+bytes(p[3] for p in data))
 if level.size==(1,1):break
 level=level.resize((max(1,level.width//2),max(1,level.height//2)),Image.Resampling.LANCZOS)
offsets=[0]*16;lengths=[0]*16;pos=1180
for i,data in enumerate(mips):offsets[i]=pos;lengths[i]=len(data);pos+=len(data)
raw=b'BLP1'+struct.pack('<6I',1,8,size,size,4,1)+struct.pack('<16I',*offsets)+struct.pack('<16I',*lengths)+bytes(c for i in range(256) for c in (i,i,i,255))+b''.join(mips)
path=OUT/'Arc.blp';path.write_bytes(raw)
assert struct.unpack_from('<6I',raw,4)==(1,8,size,size,4,1)
assert all(pixels[y*size][3]==pixels[y*size+size-1][3]==0 for y in range(size))
records=[r for r in records if r['file']!='Arc.blp']
records.append(dict(file=path.name,size=size,mips=len(mips),rgbaSha256=hashlib.sha256(im.tobytes()).hexdigest(),sha256=hashlib.sha256(raw).hexdigest(),origin='original procedural V10 lightning mask',headerPixelsAndMipBytes='PASS'))
(EV/'textures.json').write_text(json.dumps(records,indent=2)+'\n')
print('V10 lightning mask: Classic BLP1, transparent clamp borders, 8 mipmaps')
