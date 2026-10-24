"""Capture the corrected finite batch serially; no visual approval is produced."""
import json, os, subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
P = ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1'
REPO = ROOT/'wc3-forge'
def read(p): return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,j): p.write_text(json.dumps(j,indent=2)+'\n')
def capture(mp,spec,out,jobs,names=''):
    out.mkdir(parents=True,exist_ok=True)
    env=dict(os.environ,TERRAIN_VIEWS=names)
    with (out/'capture.log').open('w') as log:
        subprocess.run(['node',str(REPO/'mcp/scripts/terrain-preview.mjs'),str(REPO/'build/bin/wc3-forge-landscape.exe'),'8448',str(mp),str(spec),str(out),str(jobs)],cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
    print(str(out.relative_to(P)),flush=True)

for b,start in [('D',52700),('E',53700),('F',54700)]:
    for seed in range(start,start+4):
        run=P/f'runs/{b}/batch-v2/{seed}'
        capture(run/f'Tropical-{b}-{seed}.w3x',run/'spec.json',run/'overview',run/'views.json','top')
for b,seed in [('D',52700),('E',53700),('F',54700)]:
    run=P/f'runs/{b}/batch-v2/{seed}'
    subprocess.run(['python',str(REPO/'scripts/terrain-landscape-views.py'),str(run)],check=True)
    subprocess.run(['python',str(REPO/'scripts/terrain-landscape-metrics.py'),str(run)],check=True)
    jobs=read(run/'acceptance-views.json')
    places={p['id']:p for p in read(run/'layout.json')['placements']}
    for name in ['broken-statue-hill-1','hut-islet-1','rock-pillar-1']:
        x,y=places[name]['center']
        jobs.append(dict(name=name+'-close-opposite',bounds=dict(min=[x-640,y-640,-220],max=[x+640,y+640,900]),projection='orthographic',yaw=3.75,pitch=.85))
    write(run/'acceptance-views.json',jobs)
    capture(run/f'Tropical-{b}-{seed}.w3x',run/'spec.json',run/'acceptance-views',run/'acceptance-views.json')
    bare=P/'experiments/habitats-04/bare' if b=='D' else P/f'experiments/landform-finals-v2/{b}'
    mp=next(bare.glob('*.w3x'))
    capture(mp,bare/'spec.json',bare/'paired-views',run/'acceptance-views.json','top,lagoon-1,waterfall-1')
