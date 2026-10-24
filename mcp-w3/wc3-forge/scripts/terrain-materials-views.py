"""Choose camera windows from immutable geometry/object contexts, not output colors."""
from pathlib import Path
import json,sys,math
ROOT=Path(__file__).resolve().parents[2];P=ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1';T=ROOT/'artifacts/warcraft-terrain/contextual-materials-v1'
run=Path(sys.argv[1]).resolve();b=sys.argv[2];seed={'D':52700,'E':53700,'F':54700}[b]
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
layout=read(P/f'runs/{b}/batch-v2/{seed}/layout.json');features=read(run/'materials.json')['features']
jobs=[{'name':'top','bounds':{'min':[-12288,-4096,-220],'max':[12288,8192,850]},'view':'top','projection':'orthographic'}]
selections=[];chosen=[]
for name,context in [('forest',4),('edge-clearing',5),('coast',1),('rock-isolated',3),('rock-slope',2)]:
 candidates=[]
 for i,f in enumerate(features):
  if f['context']!=context or layout['vertex_masks'][i]=='rigid':continue
  x,y=i%193*128-12288,i//193*128-4096
  if any(math.dist((x,y),p)<1400 for p in chosen):continue
  if name=='coast' and f['trees_256']==0:continue
  support=sum(features[xx+yy*193]['context']==context for yy in range(max(0,i//193-3),min(96,i//193+3)+1) for xx in range(max(0,i%193-3),min(192,i%193+3)+1))
  candidates.append((support+min(f['trees_256'],5)*.2,-i,i,x,y))
 assert candidates,name
 _,_,i,x,y=max(candidates);chosen.append((x,y))
 jobs.append({'name':name,'bounds':{'min':[x-760,y-760,-200],'max':[x+760,y+760,850]},'projection':'orthographic','yaw':.6,'pitch':.95})
 selections.append({'name':name,'vertex':i,'xy':[x,y],'feature':features[i]})
scene=next(p for p in layout['placements'] if p['id']==('temple-1' if b!='F' else 'circle-1'))
x,y=scene['center'];jobs.append({'name':'scene-access','bounds':{'min':[x-1000,y-1000,-220],'max':[x+1000,y+1000,1000]},'projection':'orthographic','yaw':.6,'pitch':.95})
out=T/f'visual/{b}';out.mkdir(parents=True,exist_ok=True)
(out/'views.json').write_text(json.dumps(jobs,indent=2)+'\n');(out/'selection.json').write_text(json.dumps(selections,indent=2)+'\n')
print(out/'views.json')
