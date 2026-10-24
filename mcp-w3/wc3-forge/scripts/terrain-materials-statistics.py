"""Read actual W3E files: texture components, contacts, variations and contexts."""
from pathlib import Path
from collections import Counter
import json,struct,hashlib,sys,math
def read(p):return json.loads(Path(p).read_text(encoding='utf-8-sig'))
def terrain(path):
 b=Path(path).read_bytes();assert b[:4]==b'W3E!' and struct.unpack_from('<I',b,4)[0]==11
 n=struct.unpack_from('<I',b,13)[0];palette=[b[17+i*4:21+i*4].decode() for i in range(n)];off=17+n*4
 n=struct.unpack_from('<I',b,off)[0];off+=4+n*4
 w,h,ox,oy=struct.unpack_from('<IIff',b,off);off+=16;assert (w,h)==(193,97)
 pts=[]
 for i in range(w*h):
  g,a,f,v,m=struct.unpack_from('<hHBBB',b,off+i*7)
  z=(g-8192)/4+((m&15)-2)*128;water=((a&16383)-8192)/4-89.6 if f&64 else float('-inf')
  pts.append({'tex':f&15,'variation':v&31,'dry':z>=water,'boundary':bool(a&16384),'z':z})
 return palette,pts
def neighbors(i):
 if i%193:yield i-1
 if i%193<192:yield i+1
 if i>=193:yield i-193
 if i<193*96:yield i+193
def statistics(path,features=None,masks=None):
 palette,pts=terrain(path);dry=[i for i,t in enumerate(pts) if t['dry']];patches={};contacts=Counter()
 for tex,name in enumerate(palette):
  todo={i for i in dry if pts[i]['tex']==tex};sizes=[]
  while todo:
   start=todo.pop();q=[start]
   for i in q:
    for j in neighbors(i):
     if j in todo:todo.remove(j);q.append(j)
   sizes.append(len(q))
  sizes.sort();patches[name]={'components':len(sizes),'vertices':sum(sizes),'singleton_components':sizes.count(1),'p50':sizes[min(len(sizes)-1,int((len(sizes)-1)*.5))] if sizes else 0,'p90':sizes[min(len(sizes)-1,int((len(sizes)-1)*.9))] if sizes else 0,'p95':sizes[min(len(sizes)-1,int((len(sizes)-1)*.95))] if sizes else 0,'max':max(sizes,default=0)}
 for i in dry:
  for j in neighbors(i):
   if j>i and pts[j]['dry']:contacts['/'.join(sorted([palette[pts[i]['tex']],palette[pts[j]['tex']]]))]+=1
 counts=Counter(palette[pts[i]['tex']] for i in dry)
 result={'w3e_sha256':hashlib.sha256(Path(path).read_bytes()).hexdigest(),'population':'all dry vertices; texture assignments, not visible pixel area','dry_count':len(dry),'counts':dict(counts),'percent':{n:100*counts[n]/len(dry) for n in palette},'patches':patches,'contacts':dict(sorted(contacts.items())),'variations':{n:dict(Counter(pts[i]['variation'] for i in dry if pts[i]['tex']==t)) for t,n in enumerate(palette)}}
 if features:
  result['tree_density_strata']={}
  for name,test in [('trees-0',lambda n:n==0),('trees-1-2',lambda n:0<n<3),('trees-3plus',lambda n:n>=3)]:
   indices=[i for i in dry if test(features[i]['trees_256']) and (masks is None or masks[i]!='rigid') and not pts[i]['boundary']]
   result['tree_density_strata'][name]={'n':len(indices),'counts':dict(Counter(palette[pts[i]['tex']] for i in indices))}
 return result
if __name__=='__main__':
 path,out=sys.argv[1:3];features=read(sys.argv[3])['features'] if len(sys.argv)>3 else None
 r=statistics(path,features);Path(out).write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'percent':r['percent'],'patches':r['patches']}))
