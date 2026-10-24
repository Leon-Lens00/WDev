"""Verify actual clean exports and compile generated JASS; no runtime or UI approval."""
import json, hashlib, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REPO = ROOT/'wc3-forge'
P = ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1'
CLI = REPO/'build/bin/terrain-gen-landscape-v4.exe'
INSTALL = Path('C:/Users/Leon/Downloads/Warcraft III 1.27')
PJASS = Path('C:/Users/Leon/Documents/W3/build/HiveWE-reference/data/tools/pjass.exe')
JASS = ROOT/'artifacts/warcraft-terrain/tropical-v1/game-test-v3'

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p): return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p, j): p.parent.mkdir(parents=True,exist_ok=True); p.write_text(json.dumps(j,indent=2)+'\n')

def reproduction():
    report={'accepted':False,'cases':[],'excluded':['report.duration_ms','report.map (output path)']}
    for brief,seed in [('D',52700),('E',53700),('F',54700)]:
        a=P/f'runs/{brief}/batch-v2/{seed}'; b=P/f'reproduction/clean-v2/{brief}'
        names=[f'Tropical-{brief}-{seed}.w3x','layout.json','members.json','placements.json','placements-provenance.json','height-and-module-evidence.json','physical-layers.json','forest-metrics.json','catalog.json','engine/result.json','engine/result.xml','engine/resources/samples/terrain.png']
        files={name:{'original':sha(a/name),'repeat':sha(b/name)} for name in names}
        assert all(x['original']==x['repeat'] for x in files.values()), (brief,files)
        ra,rb=read(a/'report.json'),read(b/'report.json')
        for j in [ra,rb]:
            for field in ['duration_ms','map']:j.pop(field,None)
        assert ra==rb, (brief,'deterministic report fields changed')
        report['cases'].append(dict(brief=brief,seed=seed,files=files,report_effective_equal=True))
    report['accepted']=True;write(P/'reproduction/determinism-v2.json',report);print('Three exact W3X and deterministic evidence reproductions pass.')

def compile_scripts(native=False):
    report={'accepted':False,'runtime_executed':False,'cases':[],'compiler_sha256':sha(PJASS),'common_sha256':sha(JASS/'common.j'),'blizzard_sha256':sha(JASS/'blizzard.j')}
    mode='native' if native else 'generated'
    for brief,seed in [('D',52700),('E',53700),('F',54700)]:
        mp=P/f'editor/{brief}/Tropical-{brief}-native.w3x' if native else P/f'runs/{brief}/batch-v2/{seed}/Tropical-{brief}-{seed}.w3x'
        out=P/f'reproduction/pjass-v2/{mode}/{brief}';out.mkdir(parents=True,exist_ok=True); script=out/'war3map.j'
        with (out/'extract.log').open('w') as f:subprocess.run([str(CLI),'resource','--map',str(mp),'--install',str(INSTALL),'--resource','war3map.j','--out',str(script)],cwd=REPO,stdout=f,stderr=subprocess.STDOUT,check=True)
        with (out/'pjass.log').open('w') as f:subprocess.run([str(PJASS),str(JASS/'common.j'),str(JASS/'blizzard.j'),str(script)],cwd=REPO,stdout=f,stderr=subprocess.STDOUT,check=True)
        report['cases'].append(dict(brief=brief,map=str(mp),map_sha256=sha(mp),script_sha256=sha(script),log_sha256=sha(out/'pjass.log'),exit_code=0))
    report['accepted']=True;write(P/f'reproduction/pjass-v2/{mode}.json',report);print(mode+': three pJASS compilations pass (no game launch).')

if __name__=='__main__':
    if sys.argv[1]=='reproduction':reproduction()
    elif sys.argv[1]=='pjass':compile_scripts('--native' in sys.argv)
    else:raise SystemExit('Expected reproduction or pjass [--native]')
