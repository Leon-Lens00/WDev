"""Additional support/forest views after occlusion was found in release review."""
import json, os, subprocess, sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
P=ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1'
def read(p): return json.loads(p.read_text(encoding='utf-8-sig'))
for b,seed in [('D',52700),('E',53700),('F',54700)]:
    if len(sys.argv)>1 and b not in sys.argv[1:]: continue
    run=P/f'runs/{b}/batch-v2/{seed}'
    hut=next(x for x in read(run/'height-and-module-evidence.json')['pieces'] if x['instance']=='hut-islet-1' and x['source_id']==2200)
    x,y,z=hut['position']; jobs=[]
    for name,yaw in [('hut-support-north',1.57),('hut-support-south',4.71)]:
        jobs.append(dict(name=name,bounds=dict(min=[x-340,y-340,z-40],max=[x+340,y+340,z+240]),projection='orthographic',yaw=yaw,pitch=.3))
    if b=='F':
        layout=read(run/'layout.json')
        # Largest semantic interior component, chosen by mask, not by tree outcome.
        remaining={i for i,h in enumerate(layout['vertex_habitats']) if h=='forest-interior'}
        components=[]
        while remaining:
            seed_index=min(remaining);remaining.remove(seed_index);component=[seed_index];todo=[seed_index]
            while todo:
                i=todo.pop()
                for j in [i-193,i+193,i-1,i+1]:
                    if j in remaining and (abs(j-i)==193 or j//193==i//193):
                        remaining.remove(j);component.append(j);todo.append(j)
            components.append(component)
        component=max(components,key=len)
        x=sum(i%193*128-12288 for i in component)/len(component)
        y=sum(i//193*128-4096 for i in component)/len(component)
        for name,pitch in [('interior-component-top',1.5707963267948966),('interior-component-oblique',.95)]:
            jobs.append(dict(name=name,bounds=dict(min=[x-900,y-900,-150],max=[x+900,y+900,700]),projection='orthographic',yaw=.6,pitch=pitch))
    out=run/'detail-views';out.mkdir(exist_ok=True)
    jobs_path=run/'detail-views.json';jobs_path.write_text(json.dumps(jobs,indent=2)+'\n')
    with (out/'capture.log').open('w') as log:
        subprocess.run(['node',str(ROOT/'wc3-forge/mcp/scripts/terrain-preview.mjs'),str(ROOT/'wc3-forge/build/bin/wc3-forge-landscape.exe'),'8448',str(run/f'Tropical-{b}-{seed}.w3x'),str(run/'spec.json'),str(out),str(jobs_path)],cwd=ROOT,env=dict(os.environ,TERRAIN_VIEWS=''),stdout=log,stderr=subprocess.STDOUT,check=True)
    print(b,len(jobs),'detail views captured',flush=True)
