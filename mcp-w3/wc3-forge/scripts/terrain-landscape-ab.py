"""Measure isolated free-forest changes and select semantic windows without using results."""
import json,math,sys,hashlib,struct
from pathlib import Path
root=Path(sys.argv[1]).resolve()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,v):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
workspace=Path(__file__).resolve().parents[2]
profile=read(workspace/'artifacts/warcraft-terrain/scene-generator-v1/library/forest-profile-v1.json')
radii=profile['canopy']['radii_at_scale_one']
mesh_evidence={}
for f in (root.parent/'canopy').glob('*.mdx'):
 raw=f.read_bytes();off=4;vertices=[]
 while off+8<=len(raw):
  tag,n=struct.unpack_from('<4sI',raw,off);off+=8
  if tag==b'GEOS':
   at=off
   while at<off+n:
    size=struct.unpack_from('<I',raw,at)[0];assert size>12 and raw[at+4:at+8]==b'VRTX'
    count=struct.unpack_from('<I',raw,at+8)[0];vertices.extend(struct.iter_unpack('<fff',raw[at+12:at+12+count*12]));at+=size
  off+=n
 radius=max(math.hypot(x,y) for x,y,z in vertices);radii[f.stem]=radius
 mesh_evidence[f.stem]=dict(model_sha256=sha(f),vertices=len(vertices),xy_radius_at_scale_one=radius)
write(root/'canopy-profile.json',dict(method='Conservative XY envelope of MDX bind-pose vertices, multiplied by each DOO scale; includes lean. Visual proxy, not exact leaf coverage or pathing.',models=mesh_evidence,radii=radii))
runs={}
for mode in ['habitat','s-control']:
 p=root/mode;objects=read(p/'placements.json');prov={x['creation_id']:x for x in read(p/'placements-provenance.json')}
 runs[mode]=dict(objects=objects,forest=[d for d in objects if prov[d['CreationNumber']]['role']=='forest'],nonforest=[d for d in objects if prov[d['CreationNumber']]['role']!='forest'],members=read(p/'members.json'))
a,b=runs['habitat'],runs['s-control'];same={k:a['members']['members'][k]==b['members']['members'][k] for k in a['members']['members'] if k not in ['war3map.doo','war3mapmap.blp']}
assert all(same.values()),same
assert a['nonforest']==b['nonforest'],'non-forest objects changed'
layout=read(root/'habitat/layout.json');layers=read(root/'habitat/physical-layers.json');places={p['id']:p for p in layout['placements']}
def xy(i):return [i%193*128-12288,i//193*128-4096]
def valid(i):
 x,y=xy(i)
 return layers['dry'][i] and layout['vertex_masks'][i]!='rigid' and all(not(p['core']['min'][0]-128<=x<=p['core']['max'][0]+128 and p['core']['min'][1]-128<=y<=p['core']['max'][1]+128) for p in places.values())
eligible=[i for i in range(len(layers['dry'])) if valid(i)]
anchors=[('interior-edge','circle-1',['forest-interior','forest-edge']),('access-clearing','temple-1' if 'temple-1' in places else 'circle-1',['access','clearing']),('coast-riparian','lagoon-1',['coast','riparian']),('slope','waterfall-1',['slope'])]
windows=[]
for name,anchor,habitats in anchors:
 center=places[anchor]['center'];candidates=[]
 if name=='access-clearing':
  x,y=places[anchor]['anchors']['access'];windows.append(dict(id=name,anchor=anchor+'/access',center=[x,y],habitats=habitats,eligible_counts={},bounds=dict(min=[x-1024,y-1024,-180],max=[x+1024,y+1024,850])));continue
 for i in eligible:
  x,y=xy(i)
  if i%193%2 or i//193%2 or layout['vertex_habitats'][i] not in habitats:continue
  cells=[j for j in eligible if abs(xy(j)[0]-x)<=1024 and abs(xy(j)[1]-y)<=1024]
  counts={h:sum(layout['vertex_habitats'][j]==h for j in cells) for h in habitats}
  if min(counts.values())<8 or sum(counts.values())<24:continue
  candidates.append((math.dist([x,y],center),x,y,counts))
 if not candidates:raise ValueError('No semantic window for '+name)
 _,x,y,counts=min(candidates)
 windows.append(dict(id=name,anchor=anchor,center=[x,y],habitats=habitats,eligible_counts=counts,bounds=dict(min=[x-1024,y-1024,-180],max=[x+1024,y+1024,850])))
write(root/'windows.json',dict(selection='Nearest valid patch to predeclared scene anchor; only habitat area, never forest counts/statistics',windows=windows))
jobs=[]
for w in windows:
 for angle in ['top','oblique']:
  v=dict(name=w['id']+'-'+angle,bounds=w['bounds'],projection='orthographic')
  if angle=='top':v['view']='top'
  else:v.update(yaw=.6,pitch=.9)
  jobs.append(v)
write(root/'views.json',jobs)
def coverage(forest,indices):
 covered=set();by={}
 for i in indices:
  x,y=xy(i);hit=any((x-d['Position'][0])**2+(y-d['Position'][1])**2<=(radii[d['TypeID']]*max(d['Scale'][:2]))**2 for d in forest)
  if hit:covered.add(i)
  h=layout['vertex_habitats'][i];v=by.setdefault(h,dict(samples=0,covered=0));v['samples']+=1;v['covered']+=hit
 for v in by.values():v['coverage']=v['covered']/v['samples'];v['uncovered']=1-v['coverage']
 gaps=set(i for i in indices if layout['vertex_habitats'][i]=='forest-interior' and i not in covered);sizes=[]
 while gaps:
  q=[gaps.pop()]
  for i in q:
   for j in [i-1,i+1,i-193,i+193]:
    if j in gaps and (abs(j-i)!=1 or i//193==j//193):gaps.remove(j);q.append(j)
  sizes.append(len(q))
 return dict(habitats=by,largest_interior_gap_vertices=max(sizes,default=0),interior_gap_components=len(sizes))
result=dict(format='wc3-landscape-ab-v1',same_members=same,nonforest_identical=True,method='128-unit physical ground samples; measured MDX XY envelopes multiplied by DOO scale, free trees only; excludes structural reservations and water; intentional clearings reported separately',canopy_profile_sha256=sha(root/'canopy-profile.json'),map_hashes={k:v['members']['map_sha256'] for k,v in runs.items()},global_metrics={},windows=[])
for k,r in runs.items():result['global_metrics'][k]=coverage(r['forest'],eligible)
for w in windows:
 cells=[i for i in eligible if abs(xy(i)[0]-w['center'][0])<=1024 and abs(xy(i)[1]-w['center'][1])<=1024]
 result['windows'].append(dict(window=w,**{k:coverage(r['forest'],cells) for k,r in runs.items()}))
write(root/'comparison.json',result)
print(json.dumps(result['global_metrics'],indent=2))
