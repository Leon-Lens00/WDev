"""Original energy masks: compact shell, soft fringe and animated motes for X3V6."""
from pathlib import Path
from PIL import Image
import math,struct,hashlib,json
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/x3-v6';EV=ROOT/'evidence/x3-v6';OUT.mkdir(parents=True,exist_ok=True);EV.mkdir(parents=True,exist_ok=True)
records=[]
for name,size in [('Glow',128),('Core',128),('Band',128),('Filament',128),('Ring',128),('Ribbon',64),('Spark',64),('Motes',128),('Shell',128),('Flow',128)]:
 im=Image.new('RGBA',(size,size));pixels=[]
 for y in range(size):
  for x in range(size):
   u=(x+.5)/size;v=(y+.5)/size;r=math.hypot(2*u-1,2*v-1)
   if name=='Glow':a=max(0,1-r*r)**4.2
   elif name=='Core':a=max(0,1-r*r)**1.8
   elif name=='Band':a=math.sin(math.pi*v)**1.6*math.sin(math.pi*u)**.45*(.12+.88*u**.9)
   elif name=='Filament':a=math.sin(math.pi*v)**3.0*math.sin(math.pi*u)**.7*(.82+.18*math.cos(5*math.pi*u))
   elif name=='Ring':a=math.sin(math.pi*v)**2.1*(.68+.32*math.sin(4*math.pi*u)**2)
   elif name=='Ribbon':a=math.sin(math.pi*v)**3.0*(1-u)**.85
   elif name=='Flow':a=math.sin(math.pi*v)**2.0*(.12+.88*max(0,math.sin(2*math.pi*u+.65*math.sin(v*math.pi*2)))**5)
   elif name=='Shell':a=math.sin(math.pi*u)**.5*(.18+.82*u**.7)*(.98+.02*math.sin(v*math.pi*12)**2)
   elif name=='Spark':a=max(0,1-r*r)**3*max(math.exp(-abs(2*u-1)*26),math.exp(-abs(2*v-1)*26),.07)
   else:
    cell=int(u*4)+int(v*4)*4;xx=(u*4%1)*2-1;yy=(v*4%1)*2-1
    rad=math.hypot(xx+.12*math.sin(cell),yy+.12*math.cos(cell));angle=math.atan2(yy,xx)
    a=max(0,1-rad*rad)**3.2*(.6+.4*math.sin(angle*3+cell*.7+rad*8)**2)
   n=round(255*math.sqrt(max(0,a)));pixels.append((n,n,n,n))
 im.putdata(pixels);im.save(OUT/(name+'.png'));mips=[];level=im
 while True:
  data=list(level.get_flattened_data());mips.append(bytes(p[0] for p in data)+bytes(p[3] for p in data))
  if level.size==(1,1):break
  level=level.resize((max(1,level.width//2),max(1,level.height//2)),Image.Resampling.LANCZOS)
 offsets=[0]*16;lengths=[0]*16;pos=1180
 for i,data in enumerate(mips):offsets[i]=pos;lengths[i]=len(data);pos+=len(data)
 raw=b'BLP1'+struct.pack('<6I',1,8,size,size,4,1)+struct.pack('<16I',*offsets)+struct.pack('<16I',*lengths)+bytes(c for i in range(256) for c in [i,i,i,255])+b''.join(mips)
 path=OUT/(name+'.blp');path.write_bytes(raw);base=offsets[0];count=size*size;rgba=bytes(c for i in range(count) for c in [raw[base+i]]*3+[raw[base+count+i]]);assert rgba==im.tobytes();assert struct.unpack_from('<6I',raw,4)==(1,8,size,size,4,1)
 records.append({'file':path.name,'size':size,'mips':len(mips),'rgbaSha256':hashlib.sha256(im.tobytes()).hexdigest(),'sha256':hashlib.sha256(raw).hexdigest(),'origin':'original procedural V6','headerPixelsAndMipBytes':'PASS'})
(EV/'textures.json').write_text(json.dumps(records,indent=2)+'\n');print('10 original masks: headers, pixels and mips verified')
