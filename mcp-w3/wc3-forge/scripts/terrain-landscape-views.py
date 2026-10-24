"""Build graph-anchored camera jobs. This creates no visual acceptance."""
import json,sys,math
from pathlib import Path
run=Path(sys.argv[1]).resolve()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
layout=read(run/'layout.json');layers=read(run/'physical-layers.json');pieces=read(run/'height-and-module-evidence.json')['pieces']
views=read(run/'views.json');places={p['id']:p for p in layout['placements']}
def frame(name,points,margin=384,pitch=.85,yaw=.6,top=False):
 mn=[min(p[k] for p in points)-margin for k in [0,1]];mx=[max(p[k] for p in points)+margin for k in [0,1]]
 v=dict(name=name,bounds=dict(min=mn+[-220],max=mx+[900]),projection='orthographic')
 if top:v['view']='top'
 else:v.update(yaw=yaw,pitch=pitch)
 views.append(v)
for instance in places:
 p=places[instance]
 if 'access' in p['anchors']:frame(instance+'-entrance',[p['anchors']['access']],768,1.05)
 modules=[d['position'] for d in pieces if d['instance']==instance and d['module'] in ['independent-architectural-perimeter','curved-five-piece']]
 # Barricade module name is treated by family too, without relying on array order.
 if p['family']=='barricade-nw':modules=[d['position'] for d in pieces if d['instance']==instance and d['height_policy']=='ground-offset']
 if modules:
  frame(instance+'-modules-top',modules,192,top=True)
  frame(instance+'-modules-oblique',modules,192,.7,3.7)
for reach in layout['reaches']:
 points=reach['points'];frame(reach['id']+'-route',points,384,top=True)
 frame(reach['id']+'-outlet',[points[0],reach['outlet_connection_end']],512,.65)
for r in layout['routes']:
 if r['id'] not in places:frame(r['id']+'-access',r['trace'],256,top=True)
def xy(i):return [i%193*128-12288,i//193*128-4096]
eligible=[]
for i,dry in enumerate(layers['dry']):
 x,y=xy(i)
 if dry and layout['vertex_masks'][i]!='rigid' and all(not(p['core']['min'][0]-128<=x<=p['core']['max'][0]+128 and p['core']['min'][1]-128<=y<=p['core']['max'][1]+128) for p in places.values()):eligible.append(i)
anchors=[('interior-edge','circle-1',['forest-interior','forest-edge']),('access-clearing','temple-1' if 'temple-1' in places else 'circle-1',['access','clearing']),('coast-riparian','lagoon-1',['coast','riparian']),('slope','waterfall-1',['slope'])]
allowed=set(eligible);prefix={}
for habitat in {h for _,_,hs in anchors for h in hs}:
 grid=[[0]*194 for _ in range(98)]
 for y in range(97):
  for x in range(193):
   i=y*193+x;v=int(i in allowed and layout['vertex_habitats'][i]==habitat)
   grid[y+1][x+1]=v+grid[y][x+1]+grid[y+1][x]-grid[y][x]
 prefix[habitat]=grid
def counts_at(i,habitats):
 x,y=i%193,i//193;x0,x1=max(0,x-6),min(193,x+7);y0,y1=max(0,y-6),min(97,y+7)
 return {h:prefix[h][y1][x1]-prefix[h][y0][x1]-prefix[h][y1][x0]+prefix[h][y0][x0] for h in habitats}
windows=[]
for name,anchor,habitats in anchors:
 center=places[anchor]['center']
 if name=='access-clearing':center=places[anchor]['anchors']['access']
 else:
  candidates=[]
  for i in eligible:
   x,y=xy(i);counts=counts_at(i,habitats)
   if min(counts.values())>=8 and sum(counts.values())>=24:candidates.append((math.dist(center,[x,y]),i,[x,y]))
  if not candidates:raise RuntimeError('missing habitat window '+name)
  center=min(candidates)[2]
 windows.append(dict(id=name,anchor=anchor,center=center,habitats=habitats))
 frame('habitat-'+name+'-top',[center],1024,top=True)
 frame('habitat-'+name+'-oblique',[center],1024,.9)
(run/'acceptance-views.json').write_text(json.dumps(views,indent=2)+'\n')
(run/'habitat-windows.json').write_text(json.dumps(windows,indent=2)+'\n')
print(len(views),'camera jobs',run.name)
