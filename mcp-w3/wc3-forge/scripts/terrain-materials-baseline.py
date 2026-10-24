"""Fingerprint the existing terrain work before contextual material edits."""
from pathlib import Path
import hashlib,json,os,subprocess,datetime
ROOT=Path(__file__).resolve().parents[2]
REPO=ROOT/'wc3-forge'
P=ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1'
T=ROOT/'artifacts/warcraft-terrain/contextual-materials-v1'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,j):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(j,indent=2)+'\n')
dest=T/'baseline/baseline.json'
if dest.exists():raise SystemExit('Baseline already exists; do not replace it.')
old=json.loads((P/'baseline/preservation-after-v2.json').read_text())['files']
protected={}
for rel,v in old.items():
 p=ROOT/rel
 assert sha(p)==v['sha256'],str(p)
 protected[str(p)]=v['sha256']
for folder in [P/'runs',P/'library',P/'reproduction',P/'baseline',P/'staged']:
 for p in folder.rglob('*'):
  if p.is_file():protected[str(p)]=sha(p)
code={}
for folder,dirs,files in os.walk(REPO):
 dirs[:]=[d for d in dirs if d not in {'.git','node_modules','build','bin','obj','.venv','__pycache__'}]
 for name in files:
  p=Path(folder)/name
  if p.suffix in {'.go','.py','.mjs','.cs','.json','.ts','.svelte','.md','.mod','.sum','.xml','.csproj'} or p.name in {'go.mod','go.sum'}:
   code[str(p)]=sha(p)
for rel in ['internal/terrainproc/landscape.go','internal/terrainproc/landscape_contract.go','internal/terrainproc/landscape_validate.go','cmd/terrain-gen/main.go']:
 p=REPO/rel; target=T/'baseline/code'/rel;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(p.read_bytes())
for name in ['source-atlas','profile','experiments','runs','visual','reproduction','editor/D','editor/E','editor/F']:(T/name).mkdir(parents=True,exist_ok=True)
write(dest,{'format':'wc3-material-baseline-v1','time':datetime.datetime.now(datetime.timezone.utc).isoformat(),'protected':protected,'code_before':code,'git_status':subprocess.check_output(['git','status','--short'],cwd=REPO,text=True),'sessions':{'forge_instances':0,'world_editor':'Classic 1.27 worldedit.exe, window 198960, staged/Tropical-F-54700.w3x, no unsaved asterisk; southeast waterfall view recorded','restore_required':True},'restrictions':['192x96 Classic 1.27b','zero SHD','no game','preserve geometry, water and every object']})
print(json.dumps({'protected':len(protected),'code_files':len(code),'baseline':str(dest)}))
