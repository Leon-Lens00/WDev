from pathlib import Path
import json, csv, hashlib, sys
ROOT=Path(__file__).resolve().parent
# Bounded research interpreter, not a SNES emulator. Only executes documented
# integer-motion blocks; no rendering, collisions, scheduler, sound or CX4.
class CPU:
 def __init__(self,rom):
  self.rom=rom;self.ram=bytearray(65536);self.a=0;self.x=0;self.p=0x30;self.dp=0x1000;self.db=6;self.stack=[];self.calls=[];self.pc=0;self.trace=[]
 def read(self,a,n):
  if a<65536 and a<0x8000:return int.from_bytes(self.ram[a:a+n],'little')
  off=((a>>16)&127)*32768+(a&32767)
  return int.from_bytes(self.rom[off:off+n],'little')
 def write(self,a,v,n):self.ram[a:a+n]=(v&((1<<(8*n))-1)).to_bytes(n,'little')
 def obj(self,o,n=2):return self.read(self.dp+o,n)
 def put(self,o,v,n=2):self.write(self.dp+o,v,n)
 def flag(self,b,v):self.p=(self.p&~b)|(b if v else 0)
 def nz(self,v,n):self.flag(2,v==0);self.flag(128,v&(1<<(n*8-1)))
 def run(self,start,stop=None):
  self.pc=start;self.calls=[];count=0
  while self.pc!=stop:
   count+=1;assert count<2000
   pc=self.pc;op=self.read(pc,1);n=1 if self.p&32 else 2;mask=(1<<(8*n))-1;aval=self.a&mask
   self.trace.append(pc);self.pc+=1
   def operand(k):
    v=self.read(self.pc,k);self.pc+=k;return v
   def load(v):self.a=(self.a&~mask)|(v&mask);self.nz(v&mask,n)
   if op==0xa5:load(self.read(self.dp+operand(1),n))
   elif op==0xa9:load(operand(n))
   elif op==0xbd:load(self.read((self.db<<16)|((operand(2)+self.x)&65535),n))
   elif op==0x05:load(aval|self.read(self.dp+operand(1),n))
   elif op==0x85:self.write(self.dp+operand(1),aval,n)
   elif op==0x9c:self.write(operand(2),0,n)
   elif op==0xce:
    a=operand(2);v=(self.read(a,n)-1)&mask;self.write(a,v,n);self.nz(v,n)
   elif op==0x08:self.stack.append(self.p)
   elif op==0x28:self.p=self.stack.pop()
   elif op==0xc2:self.p&=~operand(1)
   elif op==0xe2:self.p|=operand(1)
   elif op==0x18:self.p&=~1
   elif op==0x38:self.p|=1
   elif op==0xaa:
    k=1 if self.p&16 else 2;self.x=self.a&((1<<(k*8))-1);self.nz(self.x,k)
   elif op==0x0a:self.flag(1,aval&(1<<(n*8-1)));load(aval<<1)
   elif op in (0x1a,0x3a):load(aval+(1 if op==0x1a else -1))
   elif op in (0x29,0x09,0x49):
    b=operand(n);load(aval&b if op==0x29 else aval|b if op==0x09 else aval^b)
   elif op in (0x24,0x89):
    b=self.read(self.dp+operand(1),n) if op==0x24 else operand(n)
    self.flag(2,(aval&b)==0)
    if op==0x24:self.flag(128,b&(1<<(n*8-1)));self.flag(64,b&(1<<(n*8-2)))
   elif op in (0xe5,0x65,0xed,0xc5):
    b=self.read(operand(2),n) if op==0xed else self.read(self.dp+operand(1),n)
    if op==0xc5:
     r=aval-b;self.flag(1,r>=0);self.nz(r&mask,n)
    elif op==0x65:
     r=aval+b+(self.p&1);self.flag(64,~(aval^b)&(aval^r)&(1<<(n*8-1)));self.flag(1,r>mask);load(r)
    else:
     r=aval-b-(0 if self.p&1 else 1);self.flag(64,(aval^b)&(aval^r)&(1<<(n*8-1)));self.flag(1,r>=0);load(r)
   elif op in (0x80,0xf0,0x50,0x70,0x30,0x10):
    delta=operand(1);delta=delta-256 if delta>=128 else delta
    take=op==0x80 or (op==0xf0 and self.p&2) or (op==0x50 and not self.p&64) or (op==0x70 and self.p&64) or (op==0x30 and self.p&128) or (op==0x10 and not self.p&128)
    if take:self.pc=(self.pc&0xff0000)|((self.pc+delta)&65535)
   elif op==0x22:
    dest=operand(3);self.calls.append(self.pc);self.pc=dest
   elif op==0x6b:
    if self.calls:self.pc=self.calls.pop()
    else:break
   elif op==0xea:pass
   else:raise ValueError(f'unimplemented {op:02x} at {pc:06x}')
  return count

def signed(v,bits):return v-(1<<bits) if v&(1<<(bits-1)) else v
original=(ROOT/'private/original.sfc').read_bytes();patched=(ROOT/'private/zero-project-v4.1.sfc').read_bytes()
rows=[]; checks=[];tables=[]
for variant,rom in [('original',original),('zero-project-v4.1',patched)]:
 off=((0x86&127)*32768)+0x3ba0
 for body in range(5):
  data=rom[off+8*body:off+8*body+8]
  tables.append({'variant':variant,'body':body,'hex':data.hex(),'ay_raw':signed(data[0],8),'ax_raw':signed(data[1],8),'vx_raw':signed(int.from_bytes(data[2:4],'little'),16),'vy_raw':signed(int.from_bytes(data[4:6],'little'),16),'palette':data[6]})
  for direction in (1,-1):
   c=CPU(rom);c.put(0x0b,body,1);c.put(0x10,0xff,1);c.put(0x11,0x46 if direction==1 else 6,1)
   c.put(4,512*256,3);c.put(7,512*256,3)
   c.run(0x81c5a6,0x81c5db)
   # Independent recurrence derived from the table and the three motion blocks.
   ax=-direction*signed(data[1],8);ay=signed(data[0],8) # original ay == 0; mod removes direction transform
   vx=-direction*signed(int.from_bytes(data[2:4],'little'),16);vy=signed(int.from_bytes(data[4:6],'little'),16)
   assert c.obj(0x1a)==vx&65535 and c.obj(0x1c)==vy&65535
   assert c.obj(0x1e,1)==ay&255 and c.obj(0x1f,1)==ax&255
   x=y=512*256
   for tick in range(1,121):
    c.run(0x81c610,0x81c62a);c.run(0x82d7c2)
    vx=(min(vx,2048) if direction==1 else max(vx,-2048))-ax;vx=signed(vx&65535,16)
    vy=signed((vy-ay)&65535,16);x=(x+vx)&0xffffff;y=(y-vy)&0xffffff
    assert c.obj(0x1a)==vx&65535 and c.obj(0x1c)==vy&65535 and c.obj(4,3)==x and c.obj(7,3)==y
    rows.append({'variant':variant,'body':body,'direction':direction,'tick':tick,'x_px':signed((x-512*256)&0xffffff,24)/256,'y_px':signed((y-512*256)&0xffffff,24)/256,'vx_px_tick':vx/256,'vy_up_px_tick':vy/256})
   checks.append({'variant':variant,'body':body,'direction':direction,'matched_ticks':120,'instructions':len(c.trace),'pcs':sorted(set(f'{a:06X}' for a in c.trace))})
with (ROOT/'motion-isolated.csv').open('w') as f:
 w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
(ROOT/'table-decoded.json').write_text(json.dumps(tables,indent=2));(ROOT/'isolated-checks.json').write_text(json.dumps({'scope':'actual ROM instruction blocks only; not a full game or native emulator trace','runs':checks,'matched_ticks':sum(x['matched_ticks'] for x in checks)},indent=2))
metrics=[]
for variant in ('original','zero-project-v4.1'):
 for body in range(5):
  r=[x for x in rows if x['variant']==variant and x['body']==body and x['direction']==1]
  minimum=min([{'x_px':0,'tick':0}]+r,key=lambda v:v['x_px']);turn=next((v['tick'] for v in r if v['vx_px_tick']>=0),None)
  metrics.append({'variant':variant,'body':body,'initial_vx':-next(x['vx_raw'] for x in tables if x['variant']==variant and x['body']==body)/256,'minimum_x_px':minimum['x_px'],'minimum_tick':minimum['tick'],'first_nonnegative_vx_tick':turn,'velocity_tick120':r[-1]['vx_px_tick']})
(ROOT/'motion-metrics.json').write_text(json.dumps(metrics,indent=2))
print(json.dumps(metrics,indent=2));print('MATCHED',len(rows),'ticks; independent recurrence vs instruction blocks')
