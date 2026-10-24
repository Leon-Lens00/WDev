"""Prepare immutable material requests and finite source/target camera jobs."""
from pathlib import Path
import hashlib,json,math,sys
ROOT=Path(__file__).resolve().parents[2]
P=ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1'
T=ROOT/'artifacts/warcraft-terrain/contextual-materials-v1'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,j):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(j,indent=2)+'\n')
profile=Path(sys.argv[1]).resolve() if len(sys.argv)>1 else T/'profile/profile-initial.json'
p=read(profile)
for b,start in [('D',52700),('E',53700),('F',54700)]:
 for seed in range(start,start+4):
  base=P/f'runs/{b}/batch-v2/{seed}';mp=base/f'Tropical-{b}-{seed}.w3x';spec=read(base/'spec.json')
  request={'format':'wc3-material-repaint-v1','map':str(mp),'map_sha256':sha(mp),'doodads_sha256':read(base/'members.json')['members']['war3map.doo'],'layout':str(base/'layout.json'),'layout_sha256':sha(base/'layout.json'),'materials':{'profile':str(profile),'profile_sha256':sha(profile),'seed':(spec['landscape']['streams']['materials']+1729)%2147483647}}
  write(T/f'config/{b}-{seed}.json',request)
  if seed==start:
   spec['landscape']['materials']=request['materials']
   write(T/f'config/{b}-integrated.json',spec)
jobs=[];selected=[]
for c in range(1,8):
 candidates=[s for s in p['samples'] if s['context']==c]
 candidates.sort(key=lambda s:(-sum(v==c for v in s['context5']),s['source_vertex']))
 chosen=[]
 for s in candidates:
  i=s['source_vertex'];xy=[i%193*128-12288,i//193*128-4096]
  if all(math.dist(xy,z)>1400 for z in chosen):
   chosen.append(xy);name=p['contexts'][c]+'-'+str(len(chosen))
   jobs.append({'name':name,'bounds':{'min':[xy[0]-640,xy[1]-640,-200],'max':[xy[0]+640,xy[1]+640,750]},'projection':'orthographic','yaw':.6,'pitch':.95})
   selected.append({'name':name,'xy':xy,'sample':s,'reason':'High same-context neighborhood support; second example spatially separated.'})
  if len(chosen)==2:break
 assert len(chosen)==2,p['contexts'][c]
write(T/'source-atlas/views.json',jobs)
write(T/'source-atlas/selections.json',{'source_sha256':p['source_sha256'],'profile_sha256':sha(profile),'selections':selected})
write(T/'profile/criteria.json',{'format':'wc3-material-criteria-v1','profile_sha256':sha(profile),'tv_limit':.20,'tv_min_vertices':64,'improvement_factor_when_base_tv_exceeds_limit':.5,'max_grassy_patch':112,'invariants':['Only W3E ground texture/low five variation bits and derived minimap may change','Rigid/boundary/wet vertices unchanged','All objects and pathing unchanged','SHD zero'],'source_holdout':'16x16 spatial blocks selected by (block_x+3*block_y)%5==0, held out from synthesis neighborhoods','primary_reference':'Training context distribution; held-out TV reported separately, not claimed exact pixel coverage.'})
print(json.dumps({'samples':len(p['samples']),'context_counts':{n:sum(p['training_counts'][i]) for i,n in enumerate(p['contexts'])},'source_views':len(jobs),'requests':12}))
