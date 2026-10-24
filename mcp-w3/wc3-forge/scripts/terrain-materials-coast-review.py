"""Resolve the atlas ambiguity: original coast windows were mostly rigid islets."""
from pathlib import Path
import json,subprocess,os,sys
ROOT=Path(__file__).resolve().parents[2];R=ROOT/'wc3-forge';T=ROOT/'artifacts/warcraft-terrain/contextual-materials-v1';P=ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,j):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(j,indent=2)+'\n')
for b,seed in [('D',52700),('E',53700),('E',53701)]:
 run=T/f'runs/{b}/{seed}';m=read(run/'materials.json');layout=read(run/'layout.json');changed={c['vertex'] for c in m['changes'] if c['context']=='coast' and c['before_texture']!=c['after_texture']};pool=[]
 for i,f in enumerate(m['features']):
  if f['context']!=1 or layout['vertex_masks'][i]=='rigid' or f['trees_256']==0:continue
  window=[x+y*193 for y in range(max(0,i//193-5),min(96,i//193+5)+1) for x in range(max(0,i%193-5),min(192,i%193+5)+1)]
  if sum(layout['vertex_masks'][j]=='rigid' for j in window)>20:continue
  pool.append((sum(j in changed for j in window),-i,i))
 score,_,i=max(pool);x,y=i%193*128-12288,i//193*128-4096
 out=T/f'visual/{b if seed!=53701 else "E-53701"}/coast-extra';views=[{'name':'coast-mutable','bounds':{'min':[x-760,y-760,-200],'max':[x+760,y+760,850]},'projection':'orthographic','yaw':.6,'pitch':.95}]
 write(out/'views.json',views);write(out/'selection.json',{'reason':'Initial coast windows contain mostly inherited rigid islet; this adds a predominantly mutable coastal window with palms. Same camera before and after.','vertex':i,'xy':[x,y],'changed_coast_vertices':score})
 modes=['after'] if seed==53701 else ['before','after']
 for mode in modes:
  mp=run/f'Tropical-{b}-{seed}-materials.w3x' if mode=='after' else P/f'runs/{b}/batch-v2/{seed}/Tropical-{b}-{seed}.w3x'
  folder=out/mode;folder.mkdir(parents=True,exist_ok=True);env=dict(os.environ);env.pop('TERRAIN_VIEWS',None)
  with (folder/'capture.log').open('w') as log:subprocess.run(['node',str(R/'mcp/scripts/terrain-preview.mjs'),str(R/'build/bin/wc3-forge-landscape.exe'),sys.argv[1],str(mp),str(T/f'config/{b}-integrated.json'),str(folder),str(out/'views.json')],cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=120)
  print(folder,flush=True)
