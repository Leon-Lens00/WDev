"""Run Classic regressions with the original configs in their original locations."""
import json, os, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];REPO=ROOT/'wc3-forge'
P=ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1'
env=dict(os.environ)
env.pop('WC3_LANDSCAPE_NATIVE',None)
configs={
 'WC3FORGE_WC3_PATH':'C:/Users/Leon/Downloads/Warcraft III 1.27',
 'WC3_TERRAIN_SPEC':str(ROOT/'artifacts/warcraft-terrain/tropical-v1/runs/12700/spec.json'),
 'WC3_WHOLE_SPEC':str(ROOT/'artifacts/warcraft-terrain/whole-map-v1/release/spec.json'),
 'WC3_RECOMPOSE_SPEC':str(REPO/'examples/terrain/tropical-recompose.json'),
 'WC3_SCENE_SPEC':str(ROOT/'artifacts/warcraft-terrain/scene-generator-v1/release/finals/A/spec.json'),
 'WC3_LANDSCAPE_SPEC':str(P/'runs/F/batch-v2/54700/spec.json')}
env.update(configs);result={'iteration':'batch-v2','target':'Classic 1.27','configs':configs,'native_final_tests':'pending','runtime_executed':False}
for action,name in [('test','go-test-all-06.log'),('vet','go-vet-06.log')]:
 with (P/'experiments'/name).open('w') as log:
  r=subprocess.run(['C:/Program Files/Go/bin/go.exe',action,'./...'],cwd=REPO,env=env,stdout=log,stderr=subprocess.STDOUT)
 result[action+'_exit']=r.returncode
(P/'experiments/check-results-06.json').write_text(json.dumps(result,indent=2)+'\n')
assert result['test_exit']==0 and result['vet_exit']==0,result
print('Full Go tests, Classic v1/v2/v3/v4 integrations and vet passed; native finals remain pending.')
