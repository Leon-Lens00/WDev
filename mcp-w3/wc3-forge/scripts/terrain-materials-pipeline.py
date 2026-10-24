"""Create the finite, hash-resumable T batch/reproduction recipe (no UI approval)."""
from pathlib import Path
import json,hashlib,datetime
ROOT=Path(__file__).resolve().parents[2];T=ROOT/'artifacts/warcraft-terrain/contextual-materials-v1';P=ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1';REPO=ROOT/'wc3-forge'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,j):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(j,indent=2)+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
cli=REPO/'build/bin/terrain-gen-materials.exe';profile=T/'profile/profile-v3.json';criteria=read(T/'profile/criteria.json');original=read(T/'profile/source-statistics.json')
criteria['source_holdout']='Center samples from 16x16 blocks with (block_x+3*block_y)%5==0 are excluded from candidate pools; 5x5 neighborhoods near a split boundary can see adjacent blocks. Holdout is diagnostic, not a fully independent dataset.'
criteria['additional_patch_p95_limits']={k:max(16,4*v['p95']) for k,v in original['patches'].items() if k in ['Zdrt','Zdtr','Zdrg','Zsan','Arck','Agrd','Alvd']}
criteria['architectural_floor']='Zbkl preserved at all existing vertices, excluded from every synthesis pool; source floors classified as scene even under rocks.'
criteria['calibration']='F-01 rejected for architectural brick contamination. F-02 corrected, F-03 identical W3X with absolute source provenance. Native F audit passed before batch.'
write(T/'profile/criteria-frozen.json',criteria)
inputs=[cli,profile,T/'profile/criteria-frozen.json']
inputs+=list((REPO/'internal/terrainproc').glob('material*.go'))+[REPO/'internal/terrainproc/landscape.go',REPO/'internal/terrainproc/landscape_contract.go',REPO/'internal/terrainproc/spec.go',REPO/'cmd/terrain-gen/main.go']
inputs+=list((T/'config').glob('*.json'))
write(T/'baseline/frozen-before-batch.json',{'time':datetime.datetime.now(datetime.timezone.utc).isoformat(),'inputs':{str(p):sha(p) for p in inputs},'pilot_map_sha256':sha(T/'experiments/F-03/Tropical-F-54700-materials.w3x'),'native_audit':sha(T/'editor/F/audit.json')})
stages=[]
for b,start in [('D',52700),('E',53700),('F',54700)]:
 for seed in range(start,start+4):
  request=T/f'config/{b}-{seed}.json';q=read(request);out=T/f'runs/{b}/{seed}'
  stages.append({'id':f'paint-{b}-{seed}','inputs':[str(p) for p in [cli,profile,request,Path(q['map']),Path(q['layout'])]],'outputs':[str(out/f'Tropical-{b}-{seed}-materials.w3x'),str(out/'validation.json'),str(out/'materials.json')],'argv':[str(cli),'repaint-materials','-spec',str(request),'-out',str(out)]})
write(T/'reproduction/batch.pipeline.json',{'cwd':str(ROOT),'stages':stages})
stages=[]
for b,seed in [('D',52700),('E',53700),('F',54700)]:
 request=T/f'config/{b}-{seed}.json';q=read(request);out=T/f'reproduction/{b}/repaint'
 stages.append({'id':f'reproduce-{b}','inputs':[str(p) for p in [cli,profile,request,Path(q['map']),Path(q['layout'])]],'outputs':[str(out/f'Tropical-{b}-{seed}-materials.w3x'),str(out/'validation.json')],'argv':[str(cli),'repaint-materials','-spec',str(request),'-out',str(out)]})
 out=T/f'reproduction/{b}/integrated';spec=T/f'config/{b}-integrated.json';s=read(spec)
 deps=[cli,profile,spec,Path(s['source']),Path(s['host']),Path(s['scene']['library']),Path(s['landscape']['library'])]
 stages.append({'id':f'integrated-{b}','inputs':[str(p) for p in deps],'outputs':[str(out/f'Tropical-{b}-{seed}.w3x'),str(out/'validation.json')],'argv':[str(cli),'generate','-spec',str(spec),'-out',str(out)]})
write(T/'reproduction/finals.pipeline.json',{'cwd':str(ROOT),'stages':stages})
print('Frozen criteria and finite recipes written; no reviews fabricated.')
