#!/usr/bin/env python3
"""Build the inventory copy without writing the TerrainDev delivery or external demo."""
from pathlib import Path
import sys, json, re, shutil, datetime, struct, importlib.util
ROOT = Path(__file__).resolve().parent
PROJECT = ROOT.parent
spec=importlib.util.spec_from_file_location('terrain_foundation',ROOT/'build_support.py')
foundation=importlib.util.module_from_spec(spec)
spec.loader.exec_module(foundation)

def object_data(data, extended=False):
    r=foundation.Reader(data)
    assert r.int()==2
    tables=[]
    for _ in range(2):
        records=[]
        for _ in range(r.int()):
            base,new,count=r.take(4),r.take(4),r.int()
            mods=[]
            for _ in range(count):
                field,kind=r.take(4),r.int()
                extra=r.take(8) if extended else b''
                assert kind in (0,1,2,3)
                value=r.string() if kind==3 else r.take(4)
                mods.append((field,kind,extra,value,r.take(4)))
            records.append((base,new,mods))
        tables.append(records)
    assert r.pos==len(data)
    assert encode_objects(tables)==data
    return tables

def encode_objects(tables):
    i=foundation.integer
    return i(2)+b''.join(i(len(t))+b''.join(base+new+i(len(mods))+b''.join(
        field+i(kind)+extra+value+end for field,kind,extra,value,end in mods)
        for base,new,mods in t) for t in tables)

def inline_strings(tables, strings):
    result=[]
    for t in tables:
        records=[]
        for base,new,mods in t:
            out=[]
            for field,kind,extra,value,end in mods:
                if kind==3:
                    match=re.fullmatch(rb'TRIGSTR_(\d+)\0',value)
                    if match:
                        value=strings[int(match[1])].encode('utf8')+b'\0'
                    value=value.replace(b'war3mapImported\\dummy.mdl',b'UI\\InventoryDummy.mdl')
                out.append((field,kind,extra,value,end))
            records.append((base,new,out))
        result.append(records)
    return result

def merge_objects(dest, src):
    for table in range(2):
        ids={(new if new!=b'\0'*4 else base):n for n,(base,new,_) in enumerate(dest[table])}
        for base,new,mods in src[table]:
            key=new if new!=b'\0'*4 else base
            if key in ids:
                assert table==0, f'Custom ID collision: {key}'
                n=ids[key]; old=dest[table][n]
                fields={(f,e) for f,_,e,_,_ in mods}
                dest[table][n]=(base,new,[m for m in old[2] if (m[0],m[2]) not in fields]+mods)
            else:
                dest[table].append((base,new,mods))
    return dest

def prepare_sources():
    src=ROOT/'src';src.mkdir(exist_ok=True)
    metadata=json.loads((ROOT/'triggers.json').read_text())['Triggers']
    names=[]
    # StartGame and the two GUI entry points are replaced by TerrainInventory.
    for path in sorted((ROOT/'upstream').glob('*.j')):
        idx=int(path.name[:2]);body=path.read_text()
        if not metadata[idx]['Enabled'] or not body.strip() or idx in (0,15,16,32):continue
        body=re.sub(r'\bTable\b','InventoryTable',body)
        body=body.replace("'I000'","'V001'").replace("'B000'","'V000'").replace('icon=B000','icon=V000')
        if idx==27:
            body=body.replace('/*static method onFilter takes unit u returns boolean\n            return true\n        endmethod*/',
                "static method onFilter takes unit u returns boolean\n            return GetUnitTypeId(u) != 'dumi' and GetUnitTypeId(u) != 'dcst'\n        endmethod")
            assert "!= 'dumi'" in body
        if idx==37:
            # Abilities already exist in the demo object data. Never run ObjectMerger.
            body=re.sub(r'^\s*//! (?:externalblock|endexternalblock|i ).*$', '// Object generation omitted; bundled Classic objects imported.',body,flags=re.M)
        body=body.replace('//! external','// external').replace('//! endexternal','// endexternal')
        name='Inventory_'+re.sub(r'\W+','_',path.stem)
        target=src/f'{name}.j'
        if not target.exists():target.write_text(body)
        names.append(name)
    return names

def main():
    probe='--probe' in sys.argv
    stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
    work=ROOT/'build'/stamp;work.mkdir(parents=True)
    run=lambda args,name: foundation.run(args,work/f'{name}.json')
    baseline=ROOT/'baseline.w3x'
    latest=json.loads((ROOT/'baseline-build.json').read_text())
    assert foundation.digest(baseline.read_bytes())==latest['sha256']
    run(['wc3ctl','extract',baseline,'--all','--out',work/'base','--json'],'extract')
    base=work/'base';demo=ROOT/'source-demo'
    names=prepare_sources()+['TerrainInventory']
    original_names=latest['libraries']
    original_bodies=[(ROOT/'foundation-src'/f'{n}.j').read_bytes() for n in original_names]
    assert all(foundation.digest(b)==latest['library_sha256'][n] for n,b in zip(original_names,original_bodies))
    bodies=[(ROOT/'src'/f'{n}.j').read_bytes() for n in names]
    original_script=(Path(latest['build_directory'])/'base/war3map.j').read_bytes()
    source=work/'input.j'
    extras=[(ROOT/'InventoryProbe.j').read_bytes()] if probe else []
    source.write_bytes(b'\n\n'.join(original_bodies+bodies+extras)+b'\n\n'+original_script)
    run(['vjass',source,work/'compiled.j'],'compile')
    changes={'war3map.j':(work/'compiled.j').read_bytes()}
    # Required by the dummy's Aave transformation. Keep target gameplay balance.
    misc=(base/'war3mapMisc.txt').read_text(encoding='utf-8-sig')
    assert 'MorphAlternateDisable' not in misc
    if '[Misc]' in misc:misc=misc.replace('[Misc]','[Misc]\nMorphAlternateDisable=0',1)
    else:misc+='\n[Misc]\nMorphAlternateDisable=0\n'
    changes['war3mapMisc.txt']=misc.encode('utf8')
    strings={int(k):v.strip('\r\n') for k,v in re.findall(r'STRING (\d+)[^{]*\{\r?\n(.*?)\r?\n\}',(demo/'war3map.wts').read_text(encoding='utf-8-sig'),re.S)}
    object_counts={}
    for ext in ('w3u','w3t','w3a','w3b','w3h'):
        member=f'war3map.{ext}'
        source_objects=inline_strings(object_data((demo/member).read_bytes(),ext in ('w3a','w3d')),strings)
        remap={b'I000':b'V001'} if ext=='w3t' else ({b'B000':b'V000'} if ext=='w3b' else {})
        source_objects=[[(a,remap.get(b,b),m) for a,b,m in t] for t in source_objects]
        dest=object_data((base/member).read_bytes(),ext in ('w3a','w3d')) if (base/member).exists() else [[],[]]
        object_counts[ext]={'base_modifications':len(source_objects[0]),'custom':len(source_objects[1])}
        changes[member]=encode_objects(merge_objects(dest,source_objects))
    # Append WTG/WCT to the immutable original: exact same first two GUI records.
    original=Path(latest['build_directory'])/'base'
    changes['war3map.wtg']=foundation.triggers((original/'war3map.wtg').read_bytes(),original_names+names)
    changes['war3map.wct']=foundation.custom_text((original/'war3map.wct').read_bytes(),original_bodies+bodies)
    imports=[]
    for folder in ('UI','war3mapImported'):
        for f in (demo/folder).rglob('*'):
            if not f.is_file():continue
            internal=str(f.relative_to(demo)).replace('/','\\')
            if internal=='war3mapImported\\dummy.mdx':internal='UI\\InventoryDummy.mdx'
            existing=base/internal.replace('\\','/')
            if existing.exists():
                assert existing.read_bytes()==f.read_bytes(), f'Import collision: {internal}'
            else:changes[internal]=f.read_bytes()
            imports.append(internal)
    # Build explicit full-path import entries, retaining every baseline import.
    r=foundation.Reader((base/'war3map.imp').read_bytes());assert r.int()==1
    entries=[]
    for _ in range(r.int()):entries.append(r.take(1)+r.string())
    assert r.pos==len(r.data)
    entries.extend(bytes([13])+foundation.cstring(s) for s in imports)
    changes['war3map.imp']=foundation.integer(1)+foundation.integer(len(entries))+b''.join(entries)
    current=baseline
    for n,(internal,payload) in enumerate(changes.items()):
        f=work/f'payload-{n}.bin';f.write_bytes(payload)
        out=work/f'stage-{n}.w3x'
        run(['wc3ctl','file','set',current,internal,f,'-o',out,'--json'],f'pack-{n}')
        current=out
    run(['wc3ctl','extract',current,'--all','--out',work/'verified','--json'],'reextract')
    for f in base.rglob('*'):
        if f.is_file() and f.name not in ('(listfile)','(attributes)'):
            internal=str(f.relative_to(base)).replace('/','\\')
            assert (work/'verified'/f.relative_to(base)).read_bytes()==changes.get(internal,f.read_bytes()),internal
    for internal,payload in changes.items():assert (work/'verified'/internal.replace('\\','/')).read_bytes()==payload,internal
    assert current.read_bytes()[:512]==baseline.read_bytes()[:512]
    run(['pjass',work/'verified/war3map.j'],'pjass-final')
    out=ROOT/('TerrainDev-Inventory-probe.w3x' if probe else 'TerrainDev-Inventory.w3x')
    if out.exists():shutil.copy2(out,work/'previous-output.w3x')
    shutil.copy2(current,out)
    result={'map':str(out),'sha256':foundation.digest(out.read_bytes()),'baseline_sha256':latest['sha256'],
      'demo_sha256':foundation.digest(Path('/home/snz/Documentos/WarDatsPy/Inventory  Equipment System v1.4.1/InventorySys v1.4.1.w3x').read_bytes()),
      'build':str(work),'sources':original_names+names,'object_counts':object_counts,'imports':imports,
      'preserved_baseline_members':True,'header_preserved':True,'compiled':True,'pjass':True,'game_tested':False,'editor_tested':False}
    (ROOT/('latest-probe.json' if probe else 'latest-build.json')).write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))

if __name__=='__main__':main()
