"""Soft original masks for layered X3 energy; BLP1 alpha8 Classic."""
from pathlib import Path
from PIL import Image
import math,struct,json,hashlib
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/x3-v2';EV=ROOT/'evidence/x3-v2';OUT.mkdir(exist_ok=True,parents=True);EV.mkdir(exist_ok=True,parents=True)
records=[]
for name,size in [('Glow',128),('Core',128),('Band',128),('Filament',128),('Ring',64),('Ribbon',64),('Spark',64)]:
 im=Image.new('RGBA',(size,size));pixels=[]
 for y in range(size):
  for x in range(size):
   u=(x+.5)/size;v=(y+.5)/size;r=math.hypot(2*u-1,2*v-1)
   if name=='Glow':a=max(0,1-r*r)**3.6
   elif name=='Core':a=max(0,1-r*r)**1.7
   elif name=='Band':a=math.sin(math.pi*u)**1.3*math.sin(math.pi*v)**3.5
   elif name=='Filament':a=math.sin(math.pi*u)**.8*math.sin(math.pi*v)**5*(.75+.25*math.sin(9*math.pi*u+.4*math.sin(17*u)))
   elif name=='Ring':a=math.sin(math.pi*v)**3*(.87+.13*math.sin(6*math.pi*u))
   elif name=='Ribbon':a=math.sin(math.pi*v)**3*(1-u)**.65
   else:a=max(0,1-r*r)**4*max(math.exp(-abs(2*u-1)*22),math.exp(-abs(2*v-1)*22),.18)
   n=round(255*math.sqrt(max(0,a)));pixels.append((n,n,n,n))
 im.putdata(pixels);im.save(OUT/(name+'.png'));mips=[];level=im
 while True:
  data=list(level.get_flattened_data());mips.append(bytes(p[0] for p in data)+bytes(p[3] for p in data))
  if level.size==(1,1):break
  level=level.resize((max(1,level.width//2),max(1,level.height//2)),Image.Resampling.LANCZOS)
 offsets=[0]*16;lengths=[0]*16;pos=1180
 for i,data in enumerate(mips):offsets[i]=pos;lengths[i]=len(data);pos+=len(data)
 header=b'BLP1'+struct.pack('<6I',1,8,size,size,4,1)+struct.pack('<16I',*offsets)+struct.pack('<16I',*lengths)
 raw=header+bytes(c for i in range(256) for c in [i,i,i,255])+b''.join(mips);path=OUT/(name+'.blp');path.write_bytes(raw)
 base=offsets[0];count=size*size;rgba=bytes(c for i in range(count) for c in [raw[base+i]]*3+[raw[base+count+i]])
 assert rgba==im.tobytes();assert struct.unpack_from('<6I',raw,4)==(1,8,size,size,4,1)
 records.append({'file':path.name,'size':size,'mips':len(mips),'rgbaSha256':hashlib.sha256(rgba).hexdigest(),'sha256':hashlib.sha256(raw).hexdigest(),'headerPixelsAndMipBytes':'PASS','origin':'original procedural mask v2'})
(EV/'textures.json').write_text(json.dumps(records,indent=2)+'\n');print('7 original soft masks verified')
