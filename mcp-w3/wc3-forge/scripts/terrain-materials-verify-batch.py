"""Measure all frozen bases, verify clean reproduction, and exercise an alternate material seed."""
from pathlib import Path
import json,hashlib,subprocess,importlib.util,shutil
ROOT=Path(__file__).resolve().parents[2];R=ROOT/'wc3-forge';T=ROOT/'artifacts/warcraft-terrain/contextual-materials-v1';P=ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1';cli=R/'build/bin/terrain-gen-materials.exe'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,j):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(j,indent=2)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(*args):subprocess.run([str(cli),*map(str,args)],check=True,cwd=ROOT,timeout=180)
sp=importlib.util.spec_from_file_location('stats',R/'scripts/terrain-materials-statistics.py');stats=importlib.util.module_from_spec(sp);sp.loader.exec_module(stats)
criteria=read(T/'profile/criteria-frozen.json');results=[];repros=[]
for b,start in [('D',52700),('E',53700),('F',54700)]:
 for seed in range(start,start+4):
  out=T/f'runs/{b}/{seed}';mp=out/f'Tropical-{b}-{seed}-materials.w3x';base=P/f'runs/{b}/batch-v2/{seed}';v=read(out/'validation.json');assert v['passed']
  shutil.copyfile(base/'placements-provenance.json',out/'placements-provenance.json')
  run('resource','-map',mp,'-install','C:/Users/Leon/Downloads/Warcraft III 1.27','-resource','war3map.w3e','-out',out/'terrain.w3e')
  result=stats.statistics(out/'terrain.w3e',read(out/'materials.json')['features'],read(out/'layout.json')['vertex_masks']);write(out/'statistics.json',result)
  for k,lim in criteria['additional_patch_p95_limits'].items():assert result['patches'][k]['p95']<=lim,(b,seed,k,result['patches'][k],lim)
  result.update(brief=b,seed=seed,map_sha256=sha(mp),worst_tv=max(x['after_tv'] for x in v['contexts'] if x['output_count']>=64 and x['source_count']>=64),contextual_validation=sha(out/'validation.json'))
  results.append(result)
  if seed==start:
   repeat=T/f'reproduction/{b}/repaint/Tropical-{b}-{seed}-materials.w3x';integrated=T/f'reproduction/{b}/integrated/Tropical-{b}-{seed}.w3x'
   assert sha(mp)==sha(repeat)==sha(integrated),(b,'reproduction mismatch')
   repros.append({'brief':b,'sha256':sha(mp),'repaint_exact':True,'integrated_exact':True})
write(T/'reproduction/batch-results.json',results);write(T/'reproduction/exact.json',repros)
q=read(T/'config/F-54700.json');q['materials']['seed']+=1;alt=T/'reproduction/alternate-F/request.json';write(alt,q)
run('repaint-materials','-spec',alt,'-out',alt.parent)
a=read(T/'runs/F/54700/materials.json');b=read(alt.parent/'materials.json');assert a['output_terrain_sha256']!=b['output_terrain_sha256'];assert a['input_doodads_sha256']==b['input_doodads_sha256'];assert read(alt.parent/'validation.json')['passed']
write(T/'reproduction/seed-independence.json',{'base_seed':a['seed'],'alternate_seed':b['seed'],'terrain_differs':True,'same_input_objects':True,'invariants_passed':True,'base_terrain_sha256':a['output_terrain_sha256'],'alternate_terrain_sha256':b['output_terrain_sha256']})
print(json.dumps({'twelve_passed':len(results),'exact_reproductions':repros,'worst_context':max(results,key=lambda x:x['worst_tv'])['seed'],'largest_grassy_patch':max(results,key=lambda x:x['patches']['Zdrg']['max'])['seed']}))
