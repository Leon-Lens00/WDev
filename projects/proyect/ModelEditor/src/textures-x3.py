"""Original procedural masks for the X3 study: grayscale BLP1, not game rips."""
from pathlib import Path
from PIL import Image
import math,struct,json,hashlib
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/x3-v1';OUT.mkdir(parents=True,exist_ok=True)
records=[]
for name,size,kind in [('Glow',64,'glow'),('Band',64,'band'),('Solid',8,'solid'),('Spark',32,'spark')]:
 im=Image.new('RGBA',(size,size));pixels=[]
 for y in range(size):
  for x in range(size):
   u=(x+.5)/size;v=(y+.5)/size;r=math.hypot(2*u-1,2*v-1)
   if kind=='solid':value=1
   elif kind=='band':value=(math.sin(math.pi*u)**.22)*(math.sin(math.pi*v)**.45)
   elif kind=='spark':value=max(0,1-r)**1.5*max(math.exp(-abs(2*u-1)*18),math.exp(-abs(2*v-1)*18),.25)
   else:value=max(0,1-r*r)**2.8
   n=round(255*value);pixels.append((n,n,n,255 if n else 0))
 im.putdata(pixels);mips=[];level=im
 while True:
  px=list(level.get_flattened_data());mips.append(bytes(p[0] for p in px)+bytes(p[3] for p in px))
  if level.size==(1,1):break
  level=level.resize((max(1,level.width//2),max(1,level.height//2)),Image.Resampling.LANCZOS)
 off=[0]*16;lengths=[0]*16;pos=1180
 for i,data in enumerate(mips):off[i]=pos;lengths[i]=len(data);pos+=len(data)
 header=b'BLP1'+struct.pack('<6I',1,8,size,size,4,1)+struct.pack('<16I',*off)+struct.pack('<16I',*lengths)
 palette=bytes(x for n in range(256) for x in (n,n,n,255))
 path=OUT/(name+'.blp');path.write_bytes(header+palette+b''.join(mips));im.save(OUT/(name+'.png'))
 assert Image.open(path).convert('RGB').tobytes()==im.convert('RGB').tobytes()
 data=path.read_bytes();pixels=size*size;base=off[0]
 rgba=bytes(c for i in range(pixels) for c in (data[base+i],data[base+i],data[base+i],data[base+pixels+i]))
 assert rgba==im.tobytes()
 assert struct.unpack_from('<6I',path.read_bytes(),4)==(1,8,size,size,4,1)
 for i,data in enumerate(mips):assert path.read_bytes()[off[i]:off[i]+lengths[i]]==data
 records.append({'file':path.name,'rgbaSha256':hashlib.sha256(im.tobytes()).hexdigest(),'size':size,'mips':len(mips),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'headerPixelsAndMipBytes':'PASS','origin':'original procedural mask'})
(ROOT/'evidence/x3-v1/textures.json').write_text(json.dumps(records,indent=2)+'\n');print(json.dumps(records))
