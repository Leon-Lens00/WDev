"""One full Go regression pass and vet with real Classic integration fixtures."""
from pathlib import Path
import os,json,subprocess
ROOT=Path(__file__).resolve().parents[2];R=ROOT/'wc3-forge';T=ROOT/'artifacts/warcraft-terrain/contextual-materials-v1';P=ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1'
env=dict(os.environ);env.pop('WC3_LANDSCAPE_NATIVE',None)
fixtures={'WC3FORGE_WC3_PATH':'C:/Users/Leon/Downloads/Warcraft III 1.27','WC3_TERRAIN_SPEC':str(ROOT/'artifacts/warcraft-terrain/tropical-v1/runs/12700/spec.json'),'WC3_WHOLE_SPEC':str(ROOT/'artifacts/warcraft-terrain/whole-map-v1/release/spec.json'),'WC3_RECOMPOSE_SPEC':str(R/'examples/terrain/tropical-recompose.json'),'WC3_SCENE_SPEC':str(ROOT/'artifacts/warcraft-terrain/scene-generator-v1/release/finals/A/spec.json'),'WC3_LANDSCAPE_SPEC':str(P/'runs/F/batch-v2/54700/spec.json'),'WC3_MATERIAL_REQUEST':str(T/'config/F-54700.json')}
env.update(fixtures);out=T/'reproduction'/os.environ.get('WC3_MATERIAL_TEST_RUN','tests');out.mkdir(parents=True,exist_ok=True);results={'fixtures':fixtures,'game_executed':False,'shadows_excluded':True}
for action in ['test','vet']:
 with (out/(action+'.log')).open('w') as log:
  r=subprocess.run(['C:/Program Files/Go/bin/go.exe',action,'./...'],cwd=R,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=1800)
 results[action+'_exit']=r.returncode
(out/'results.json').write_text(json.dumps(results,indent=2)+'\n');assert results['test_exit']==results['vet_exit']==0,results
print('Full Go tests and vet passed.')
