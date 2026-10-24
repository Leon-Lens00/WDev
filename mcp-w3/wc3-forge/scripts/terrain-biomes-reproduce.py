"""Reproduce the maps declared by a relocated, verified generation package.

World Editor saves remain separate manual evidence. Never launches the game.
"""
from pathlib import Path
import argparse, hashlib, json, subprocess

def read(p): return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,v):
    p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(v,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--package',type=Path,default=Path(__file__).resolve().parent)
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--install',type=Path,required=True,help='Existing Classic 1.27b installation; no downloads')
    args=ap.parse_args();package=args.package.resolve();out=args.out.resolve();install=args.install.resolve()
    if out.exists() and any(out.iterdir()): ap.error('--out must be empty')
    if out==package or package in out.parents: ap.error('--out must be outside package')
    contract=read(package/'reproduction-inputs.json')
    for p,h in contract['inputs'].items():
        if sha(package/p)!=h: raise ValueError('Input hash differs: '+p)
    for p,h in contract['installation'].items():
        if sha(install/p)!=h: raise ValueError('Classic installation differs: '+p)
    out.mkdir(parents=True,exist_ok=True)
    mapping=contract['path_map'];bound={};busy=set()
    pairs={'source':'source_sha256','review':'review_sha256','profile':'profile_sha256','library':'library_sha256','base_library':'base_sha256','path':'sha256'}
    def bind(original):
        if original in bound:return bound[original]
        if original in busy:raise ValueError('Cyclic input dependency: '+original)
        busy.add(original);relative=mapping[original];source=package/relative
        if source.suffix.lower()!='.json': result=source
        else:
            result=out/'config'/source.name
            def transform(v):
                if isinstance(v,list):return [transform(x) for x in v]
                if isinstance(v,dict):
                    d={k:transform(x) for k,x in v.items()}
                    for key,hashkey in pairs.items():
                        if isinstance(v.get(key),str) and v[key] in mapping and hashkey in v:
                            d[hashkey]=sha(bind(v[key]))
                    if 'install' in d:d['install']=str(install)
                    if 'dotnet' in d:d['dotnet']=str(package/'runtime/dotnet/dotnet.exe')
                    if 'host' in d:d['host']=str(package/'runtime/host/Host.dll')
                    return d
                if isinstance(v,str) and v in mapping:return str(bind(v))
                return v
            write(result,transform(read(source)))
        bound[original]=result;busy.remove(original);return result
    results=[]
    for case in contract['cases']:
        recipe=bind(case['recipe']);dest=out/case['id']
        cmd=[str(package/'bin/terrain-gen-biomes.exe'),case['command'],'-spec',str(recipe),'-out',str(dest)]
        if case['command']=='biome-generate':cmd+=['-seed',str(case['seed'])]
        with (out/(case['id']+'.log')).open('w',encoding='utf-8') as log:
            subprocess.run(cmd,cwd=package,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=600)
        generated=dest/case['output'];actual=sha(generated)
        if actual!=case['sha256']:raise ValueError('Generated map differs: '+case['id'])
        results.append(dict(id=case['id'],sha256=actual,exact=True,command=cmd))
        print(case['id'],actual,'exact',flush=True)
    write(out/'result.json',dict(passed=True,cases=results,game_executed=False,native_save_simulated=False))

if __name__=='__main__':main()
