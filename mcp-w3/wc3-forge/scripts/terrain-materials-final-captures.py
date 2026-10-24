"""Finite serial camera capture jobs; screenshots still need actual review."""
from pathlib import Path
import json,subprocess,os,sys,shutil,hashlib
ROOT=Path(__file__).resolve().parents[2];R=ROOT/'wc3-forge';T=ROOT/'artifacts/warcraft-terrain/contextual-materials-v1';P=ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,j):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(j,indent=2)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
pid=sys.argv[1];exe=R/'build/bin/wc3-forge-landscape.exe';cli=R/'build/bin/terrain-gen-materials.exe'
def capture(mp,spec,out,views,selected=None):
 out.mkdir(parents=True,exist_ok=True);env=dict(os.environ);env.pop('TERRAIN_VIEWS',None)
 if selected:env['TERRAIN_VIEWS']=selected
 with (out/'capture.log').open('w') as log:subprocess.run(['node',str(R/'mcp/scripts/terrain-preview.mjs'),str(exe),pid,str(mp),str(spec),str(out),str(views)],cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=180)
 print(str(out),flush=True)
for b,seed in [('D',52700),('E',53700)]:
 view=T/f'visual/{b}/views.json';spec=T/f'config/{b}-integrated.json';final=T/f'runs/{b}/{seed}/Tropical-{b}-{seed}-materials.w3x'
 capture(P/f'runs/{b}/batch-v2/{seed}/Tropical-{b}-{seed}.w3x',spec,T/f'visual/{b}/before',view)
 bare=T/f'visual/{b}/{b}-bare.w3x';subprocess.run([str(cli),'material-diagnostic','-map',str(final),'-out',str(bare)],cwd=ROOT,check=True,stdout=subprocess.DEVNULL)
 capture(bare,spec,T/f'visual/{b}/bare',view,'forest,rock-isolated')
# Reuse byte-identical F pilot evidence without inventing a recapture.
assert sha(T/'experiments/F-02/Tropical-F-54700-materials.w3x')==sha(T/'runs/F/54700/Tropical-F-54700-materials.w3x')
for source,dest in [('visual','after'),('bare-visual','bare')]:
 out=T/f'visual/F/{dest}';out.mkdir(parents=True,exist_ok=True)
 for p in (T/f'experiments/F-02/{source}').iterdir():
  if p.suffix in ['.png','.json']:shutil.copy2(p,out/p.name)
write(T/'visual/F/reused-pilot.json',{'map_sha256':sha(T/'runs/F/54700/Tropical-F-54700-materials.w3x'),'source':'experiments/F-02','same_archive':True,'note':'Previously captured and visually inspected; camera metadata retains original source path.'})
# Additional seed selected by worst contextual discrepancy, not visual preference.
run=T/'runs/E/53701';validation=read(run/'validation.json');features=read(run/'materials.json')['features'];layout=read(run/'layout.json')
worst=max(validation['contexts'],key=lambda c:c['after_tv']);contexts=read(T/'profile/profile-v3.json')['contexts'];ci=contexts.index(worst['name'])
pool=[]
for i,f in enumerate(features):
 if f['context']!=ci or layout['vertex_masks'][i]=='rigid':continue
 support=sum(features[x+y*193]['context']==ci for y in range(max(0,i//193-3),min(96,i//193+3)+1) for x in range(max(0,i%193-3),min(192,i%193+3)+1))
 pool.append((support,-i,i))
i=max(pool)[2];x,y=i%193*128-12288,i//193*128-4096
views=[read(T/'visual/E/views.json')[0],{'name':'worst-context','bounds':{'min':[x-760,y-760,-200],'max':[x+760,y+760,850]},'projection':'orthographic','yaw':.6,'pitch':.95}]
out=T/'visual/E-53701';write(out/'views.json',views);write(out/'selection.json',{'reason':'worst batch contextual TV','context':worst,'vertex':i,'xy':[x,y]})
capture(run/'Tropical-E-53701-materials.w3x',T/'config/E-integrated.json',out/'after',out/'views.json')
