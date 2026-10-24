"""Choose reproducible material-contact views from a real re-extracted W3E."""
import json,struct,sys,hashlib,math
from pathlib import Path
root=Path(sys.argv[1]).resolve();run=Path(sys.argv[2]).resolve()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
raw=(root/'terrain.w3e').read_bytes();assert raw[:4]==b'W3E!' and struct.unpack_from('<I',raw,4)[0]==11
n=struct.unpack_from('<I',raw,13)[0];off=17;palette=[raw[off+4*i:off+4*i+4].decode() for i in range(n)];off+=n*4
n=struct.unpack_from('<I',raw,off)[0];off+=4+4*n
w,h,ox,oy=struct.unpack_from('<IIff',raw,off);off+=16;assert (w,h)==(193,97)
tiles=[]
for i in range(w*h):
 gh,wl,tf,var,misc=struct.unpack_from('<hHBBB',raw,off+i*7)
 z=(gh-8192)/4+((misc&15)-2)*128;water=(wl&16383)/4-2048-89.6
 tiles.append(dict(xy=[ox+(i%w)*128,oy+(i//w)*128],z=z,tex=tf&15,wet=bool(tf&64) and water>z))
layout=read(run/'layout.json');places={p['id']:p for p in layout['placements']}
views=[];contacts=[]
for name,a,b,anchor in [('beach-soil',3,2,'lagoon-1'),('soil-vegetation',2,8,'circle-1'),('rock-soil',5,2,'waterfall-1'),('ruin-ground',None,None,'temple-1'),('bed-bank',3,3,'lagoon-1')]:
 center=places[anchor]['anchors'].get('access',places[anchor]['center'])
 if a is not None:
  candidates=[]
  for i,t in enumerate(tiles):
   if t['tex']!=a:continue
   for j in [i+1,i+w]:
    if j>=len(tiles) or j==i+1 and j//w!=i//w:continue
    u=tiles[j]
    if u['tex']!=b or name=='bed-bank' and t['wet']==u['wet']:continue
    if name!='bed-bank' and (t['wet'] or u['wet']):continue
    xy=[(t['xy'][k]+u['xy'][k])/2 for k in [0,1]]
    candidates.append((math.dist(xy,center),i,j,xy))
  _,i,j,center=min(candidates);samples=[dict(index=k,**tiles[k]) for k in [i,j]]
 else:samples=[]
 x,y=center;bounds=dict(min=[x-640,y-640,-180],max=[x+640,y+640,500])
 views.append(dict(name=name,bounds=bounds,projection='orthographic',yaw=.6,pitch=.95))
 contacts.append(dict(id=name,anchor=anchor,center=center,samples=samples,policy={'beach-soil':'Zsan 3 to Zdrg 2, blended shore band','soil-vegetation':'Zdrg 2 buffer before Avin 8','rock-soil':'Arck 5 to Zdrg 2; no direct Avin 8 outside protected core','ruin-ground':'Preserve authored temple model floor and its ground; no palette reorder','bed-bank':'Zsan 3 on bed and bank, physical constant water -89.6; source inlet preserved'}[name]))
write(root/'views.json',views)
write(root/'atlas.json',dict(format='wc3-material-contacts-v1',map=str(next(root.glob('*.w3x'))),map_sha256=sha(next(root.glob('*.w3x'))),terrain_sha256=sha(root/'terrain.w3e'),palette=palette,contacts=contacts,visual='pending'))
