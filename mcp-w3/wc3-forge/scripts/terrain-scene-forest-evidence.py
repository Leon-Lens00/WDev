"""Measure the controlled experiment and freeze camera windows before final batch."""
import json,math,sys,hashlib
from pathlib import Path
root=Path(sys.argv[1]).resolve();ex=root/'experiments'; compact=sys.argv[2] if len(sys.argv)>2 else 'compact'; control=sys.argv[3] if len(sys.argv)>3 else 'control'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,v):p.write_text(json.dumps(v,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
def metrics(ds):
 pts=[d['Position'][:2] for d in ds]
 if len(pts)<2:return dict(n=len(pts))
 nn=sorted(min(math.dist(a,b) for j,b in enumerate(pts) if i!=j) for i,a in enumerate(pts))
 return dict(n=len(pts),quantiles=[nn[int((len(nn)-1)*p)] for p in [.25,.5,.75]],neighbors256=sum(sum(i!=j and math.dist(a,b)<=256 for j,b in enumerate(pts)) for i,a in enumerate(pts))/len(pts))
profile=read(root/'library/forest-profile-v1.json');source={d['CreationNumber']:d for d in read(root/'discovery/source-data/placements.json')}
runs={}
for name in ['compact','control']:
 folder=compact if name=='compact' else control
 ds=read(ex/folder/'extracted/placements.json');p={d['creation_id']:d for d in read(ex/folder/'placements-provenance.json')}
 runs[name]=dict(objects=ds,forest=[d for d in ds if p[d['CreationNumber']]['role']=='forest'],provenance=p,manifest=read(ex/folder/'manifest.json'))
same={n:runs['compact']['manifest']['members'][n]==runs['control']['manifest']['members'][n] for n in ['war3map.w3e','war3map.wpm','war3map.w3c','war3mapunits.doo','war3map.j']}
assert all(same.values())
nonforest=lambda r:[d for d in r['objects'] if r['provenance'][d['CreationNumber']]['role']!='forest']
assert nonforest(runs['compact'])==nonforest(runs['control'])
records=[]
for c in profile['cohorts']:
 ref=metrics([source[n] for n in c['source_ids']]);out=metrics([d for d in runs['compact']['forest'] if runs['compact']['provenance'][d['CreationNumber']]['instance']==c['id']])
 record=dict(cohort=c['id'],reference=ref,output=out,quantiles_pass=out['n']>=30 and all(abs(a-b)/b<=.25 for a,b in zip(out['quantiles'],ref['quantiles'])))
 records.append(record)
# Windows are chosen on tree COUNT alone, not on favorable distance statistics.
# Once written, they remain fixed for camera-matched A/B and final local views.
vp=ex/'forest-windows.json'
if vp.exists():windows=read(vp)
else:
 candidates=[]
 for y in range(-2048,6657,1024):
  for x in range(-10240,10241,1024):
   n=sum(abs(d['Position'][0]-x)<=1024 and abs(d['Position'][1]-y)<=1024 for d in runs['compact']['forest'])
   candidates.append((n,x,y))
 windows=[]
 for n,x,y in sorted(candidates,reverse=True):
  if all(math.dist([x,y],w['center'])>=2300 for w in windows):windows.append(dict(id='forest-'+str(len(windows)+1),center=[x,y],count=n,bounds=dict(min=[x-1024,y-1024,-180],max=[x+1024,y+1024,850])))
  if len(windows)==3:break
 write(vp,windows)
jobs=[]
for w in windows:
 for view in ['top','oblique']:
  job=dict(name=w['id']+'-'+view,bounds=w['bounds'],projection='orthographic' if view=='top' else 'perspective')
  if view=='top':job['view']='top'
  else:job.update(yaw=.6,pitch=1.0)
  jobs.append(job)
write(ex/'forest-views.json',jobs)
radii=profile['canopy']['radii_at_scale_one']
def canopy(ds,bounds):
 sample=covered=overlap=0
 for y in range(int(bounds['min'][1]),int(bounds['max'][1]),64):
  for x in range(int(bounds['min'][0]),int(bounds['max'][0]),64):
   n=sum(math.dist([x+32,y+32],d['Position'][:2])<=radii[d['TypeID']]*max(d['Scale'][:2]) for d in ds)
   sample+=1;covered+=n>0;overlap+=n>1
 return dict(coverage=covered/sample,overlap=overlap/sample,uncovered=1-covered/sample,method='64-unit samples, visually annotated crown radius; not pathing')
comparisons=[]
for w in windows:
 entry=dict(window=w)
 for name,run in runs.items():
  ds=[d for d in run['forest'] if abs(d['Position'][0]-w['center'][0])<=1024 and abs(d['Position'][1]-w['center'][1])<=1024]
  entry[name]=dict(metrics=metrics(ds),canopy=canopy(ds,w['bounds']))
 comparisons.append(entry)
write(ex/'forest-ab.json',dict(same_members=same,nonforest_objects_identical=True,cohorts=records,windows=comparisons,global_metrics={k:metrics(v['forest']) for k,v in runs.items()},visual_review='pending',criteria_frozen_before_batch=True))
print(json.dumps(dict(cohorts=records,windows=[(w['id'],w['count']) for w in windows])))
