"""Assemble B generation inputs. Does not certify native saves or visual review."""
from pathlib import Path
import hashlib,json,re,shutil

ROOT=Path(__file__).resolve().parents[2];R=ROOT/'wc3-forge';B=ROOT/'artifacts/warcraft-terrain/reusable-biomes-v1'
P=B/'release/generator-package-v1'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,v):
    p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
def copy(a,b):b.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(a,b)

def main():
    if P.exists() and any(P.iterdir()):raise ValueError('Package already exists; preserve previous attempt and choose a new version')
    P.mkdir(parents=True,exist_ok=True);mapping={};visited=set()
    def collect(path):
        original=str(path);path=Path(path)
        relative='inputs/'+sha(path)[:12]+'-'+path.name
        mapping[original]=relative
        if path in visited:return
        visited.add(path);copy(path,P/relative)
        if path.suffix.lower()!='.json':return
        def walk(v):
            if isinstance(v,dict):
                for k,x in v.items():
                    if k not in ['install','dotnet','host']:walk(x)
            elif isinstance(v,list):
                for x in v:walk(x)
            elif isinstance(v,str) and len(v)<512 and re.match(r'^[A-Za-z]:[\\/]',v) and Path(v).is_file():
                mapping[v]='inputs/'+sha(Path(v))[:12]+'-'+Path(v).name
                collect(v)
        walk(read(path))
    cases=[]
    for case,seed in [('riberas',62100),('claros',63100)]:
        recipe=B/f'recipes/{case}-forest-v3.json';collect(recipe)
        run=read(B/f'runs/cohorts-final-v3/{case}/{seed}/run.json')
        cases.append(dict(id=case,seed=seed,recipe=str(recipe),command='biome-generate',output='paint/'+Path(run['map']).name,sha256=run['map_sha256']))
    recipe=B/'recipes/tropical-D-v2.json';collect(recipe)
    cases.append(dict(id='tropical-D',seed=52700,recipe=str(recipe),command='generate',output='Tropical-D-52700.w3x',sha256=sha(B/'runs/tropical-D/Tropical-D-52700.w3x')))
    copy(R/'build/bin/terrain-gen-biomes.exe',P/'bin/terrain-gen-biomes.exe')
    copy(R/'scripts/terrain-biomes-reproduce.py',P/'reproduce.py')
    runtime=R/'.tools/dotnet'
    copy(runtime/'dotnet.exe',P/'runtime/dotnet/dotnet.exe')
    for name in ['host/fxr/10.0.12','shared/Microsoft.NETCore.App/10.0.12']:
        shutil.copytree(runtime/name,P/'runtime/dotnet'/name)
    for name in ['LICENSE.txt','ThirdPartyNotices.txt']:
        if (runtime/name).is_file():copy(runtime/name,P/'runtime/dotnet'/name)
    shutil.copytree(R/'generators/markovjunior-host/bin/Release/net10.0',P/'runtime/host')
    install=Path(read(recipe)['install'])
    archives={p.name:sha(p) for p in sorted(install.glob('*.mpq'))}
    write(P/'reproduction-inputs.json',dict(format='wc3-biome-portable-inputs-v1',cases=cases,path_map=mapping,installation=archives,
        inputs={str(p.relative_to(P)).replace('\\','/'):sha(p) for p in P.rglob('*') if p.is_file()},
        external_dependencies=['Windows x64','Python 3.10+','Existing Warcraft III Classic 1.27b installation matching archive hashes'],
        native_saves='Not reproduced by this launcher; actual editor evidence delivered separately'))
    print(P,len(mapping),'input references')

if __name__=='__main__':main()
