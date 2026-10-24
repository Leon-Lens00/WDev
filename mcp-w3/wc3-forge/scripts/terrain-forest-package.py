"""Package the opt-in forest correction and its verified source references."""
from pathlib import Path
import argparse,hashlib,json,re,shutil

def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,v):
    p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,indent=2)+'\n',encoding='utf-8')
def copy(a,b):b.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(a,b)

ap=argparse.ArgumentParser(description=__doc__)
ap.add_argument('--stage',type=Path,required=True)
ap.add_argument('--out',type=Path,required=True)
a=ap.parse_args();stage=a.stage.resolve();package=a.out.resolve();repo=Path(__file__).resolve().parents[1]
if package.exists() and any(package.iterdir()):raise ValueError('Preserve existing package; choose an empty output')
mapping={};visited=set()
def collect(path):
    original=str(path);path=Path(path);relative='inputs/'+sha(path)[:12]+'-'+path.name
    mapping[original]=relative
    if path in visited:return
    visited.add(path);copy(path,package/relative)
    if path.suffix.lower()!='.json':return
    def walk(v):
        if isinstance(v,dict):
            for k,x in v.items():
                if k not in ['install','dotnet','host']:walk(x)
        elif isinstance(v,list):
            for x in v:walk(x)
        elif isinstance(v,str) and len(v)<512 and re.match(r'^[A-Za-z]:[\\/]',v) and Path(v).is_file():collect(v)
    walk(read(path))
cases=[]
for name,seed in [('riberas',62100),('claros',63100)]:
    recipe=stage/f'recipes/{name}.json';collect(recipe)
    run=read(stage/f'runs/pilot/{name}/{seed}/run.json')
    cases.append(dict(id=name,seed=seed,recipe=str(recipe),command='biome-generate',output='paint/'+Path(run['map']).name,sha256=run['map_sha256']))
copy(repo/'build/bin/terrain-gen-forest.exe',package/'bin/terrain-gen-biomes.exe')
copy(repo/'scripts/terrain-biomes-reproduce.py',package/'reproduce.py')
profile=read(stage/'profiles/ashenvale-coverage-v1.json');install=Path(profile['install'])
write(package/'reproduction-inputs.json',dict(format='wc3-biome-portable-inputs-v1',cases=cases,path_map=mapping,
    installation={p.name:sha(p) for p in sorted(install.glob('*.mpq'))},
    inputs={str(p.relative_to(package)).replace('\\','/'):sha(p) for p in package.rglob('*') if p.is_file()},
    external_dependencies=['Windows x64','Python 3.10+','Existing matching Warcraft III Classic 1.27b installation'],
    native_saves='Actual editor saves are delivered separately; no UI or game simulation.'))
print(package,len(mapping),'input references')
