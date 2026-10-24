"""Reuse existing mip levels exactly, avoiding recompression or alpha changes."""
from pathlib import Path
import struct,json,hashlib
root=Path(__file__).resolve().parents[1];ev=root/'evidence/x3-v15';records=[]
reduce={'Glow','Core','Band','Filament','Ring','Shell','Pulse'}
for job in json.loads((ev/'texture-jobs.json').read_text()):
 b=Path(job['input']).read_bytes();assert hashlib.sha256(b).hexdigest()==job['hash'];assert b[:4]==b'BLP1'
 compression,alpha,w,h,kind,sub=struct.unpack_from('<6I',b,4);offsets=struct.unpack_from('<16I',b,28);sizes=struct.unpack_from('<16I',b,92)
 drop=1 if job['baseName'] in reduce and w>=128 else 0
 if drop:
  assert (compression,alpha,kind,sub)==(1,8,4,1)
  levels=[b[o:o+n] for o,n in zip(offsets,sizes) if n];newLevels=levels[1:];ww=w//2;hh=h//2;newOffsets=[0]*16;newSizes=[0]*16;cursor=1180
  for i,level in enumerate(newLevels):
   assert len(level)==max(1,ww>>i)*max(1,hh>>i)*2
   newOffsets[i]=cursor;newSizes[i]=len(level);cursor+=len(level)
  assert len(newLevels)==max(ww,hh).bit_length()
  result=b'BLP1'+struct.pack('<6I',1,8,ww,hh,4,1)+struct.pack('<16I',*newOffsets)+struct.pack('<16I',*newSizes)+b[156:1180]+b''.join(newLevels)
  for i,level in enumerate(newLevels):assert result[newOffsets[i]:newOffsets[i]+newSizes[i]]==levels[i+1]
 else:result=b;ww=w;hh=h
 for dest in job['targets']:
  p=Path(dest);p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(result)
 records.append({'name':job['name'],'source':job['input'],'beforeBytes':len(b),'afterBytes':len(result),'beforeSize':[w,h],'afterSize':[ww,hh],'dropTopMip':bool(drop),'unchangedRemainingMipPixels':True,'sha256':hashlib.sha256(result).hexdigest(),'copies':len(job['targets'])})
(ev/'textures.json').write_text(json.dumps(records,indent=2));print(json.dumps(records,indent=2))
