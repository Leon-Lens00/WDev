#!/usr/bin/env python3
"""Build a new conversation copy; retain originals and both base GUI triggers."""
from pathlib import Path
import importlib.util, datetime, json, shutil, subprocess, sys, copy
ROOT=Path(__file__).resolve().parent
INV=ROOT.parent/'inventory-integration'
spec=importlib.util.spec_from_file_location('inventory_builder',INV/'build.py')
inv=importlib.util.module_from_spec(spec);spec.loader.exec_module(inv)
f=inv.foundation

def main():
    lab = sys.argv[1:] == ['--texttag-lab']
    if sys.argv[1:] and not lab:raise SystemExit('Usage: build.py [--texttag-lab]')
    work=ROOT/'build'/datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f');work.mkdir(parents=True)
    run=lambda args,name:f.run(args,work/(name+'.json'))
    prepare=subprocess.run(['node',str(ROOT/('tools/texttag-fixtures.mjs' if lab else 'tools/story.mjs'))],capture_output=True,text=True)
    (work/'prepare-design.json').write_text(json.dumps({'command':['node',str(ROOT/('tools/texttag-fixtures.mjs' if lab else 'tools/story.mjs'))],'returncode':prepare.returncode,'stdout':prepare.stdout,'stderr':prepare.stderr},indent=2))
    if prepare.returncode:raise RuntimeError('Preparing dialogue failed; see '+str(work/'prepare-design.json'))
    if not lab:
        model=subprocess.run(['node',str(ROOT/'tools/model.cjs')],capture_output=True,text=True)
        (work/'prepare-model.json').write_text(json.dumps({'returncode':model.returncode,'stdout':model.stdout,'stderr':model.stderr},indent=2))
        if model.returncode:raise RuntimeError('Preparing model failed; see '+str(work/'prepare-model.json'))
    if not lab:
        health=subprocess.run(['node',str(ROOT/'tools/healthbar-models.cjs')],capture_output=True,text=True)
        (work/'prepare-healthbars.json').write_text(json.dumps({'returncode':health.returncode,'stdout':health.stdout,'stderr':health.stderr},indent=2))
        if health.returncode:raise RuntimeError('Preparing health bars failed; see '+str(work/'prepare-healthbars.json'))
    manifest=json.loads((INV/'latest-build.json').read_text())
    base_map=Path(manifest['map']);assert f.digest(base_map.read_bytes())==manifest['sha256']
    run(['wc3ctl','extract',base_map,'--all','--out',work/'base','--json'],'extract')
    base=work/'base'
    baseline=json.loads((INV/'baseline-build.json').read_text())
    foundation_names=baseline['libraries']
    # Keep the frozen terrain libraries and only the five required UI utilities.
    # No Inventory/Equipment initialization, item setups or example entrypoint.
    utility_names=['Inventory_25_UserInterface','Inventory_27_UnitDex','Inventory_28_PlayerUtils','Inventory_29_Camera','Inventory_30_Math']
    own_names=['TextTagCases','TextTagLab'] if lab else ['DialogueProjection','DialogueData','HealthBars','ConversationUI']
    paths=[INV/'foundation-src'/f'{n}.j' for n in foundation_names]+[INV/'src'/f'{n}.j' for n in utility_names]+[ROOT/'src'/f'{n}.j' for n in own_names]
    bodies=[p.read_bytes() for p in paths]
    for name,body in zip(foundation_names,bodies):assert f.digest(body)==baseline['library_sha256'][name]
    original=Path(baseline['build_directory'])/'base'
    original_script=(original/'war3map.j').read_bytes()
    (work/'input.j').write_bytes(b'\n\n'.join(bodies)+b'\n\n'+original_script)
    run(['vjass',work/'input.j',work/'compiled.j'],'compile')
    names=foundation_names+utility_names+own_names
    changes={'war3map.j':(work/'compiled.j').read_bytes(),
      'war3map.wtg':f.triggers((original/'war3map.wtg').read_bytes(),names),
      'war3map.wct':f.custom_text((original/'war3map.wct').read_bytes(),bodies)}
    objects=inv.object_data((base/'war3map.w3u').read_bytes())
    assert b'dlog' not in [b for table in objects for _,b,_ in table]
    template=next(r for r in objects[1] if r[1]==b'uidm')
    record={'base':template[0],'id':b'dlog','mods':[(a,k,v,e) for a,k,x,v,e in template[2]]}
    for key,kind,value in [('umdl',3,r'UI\Dialogue\Conversation.mdx'),('unam',3,'Conversation frame'),('ushb',3,''),('ushu',3,''),('uabi',3,'Aloc,Avul'),('umvt',3,'float'),('ufyh',2,0.0),('ufmh',2,0.0),('usca',1,1.0),('umvs',0,1),('ucol',2,0.0)]:f.set_field(record,key,kind,value)
    objects[1].append((record['base'],record['id'],[(a,k,b'',v,e) for a,k,v,e in record['mods']]))
    if not lab:
        for actor in json.loads((ROOT/'evidence/portrait-registry.json').read_text()).values():
            actor_id=actor['rawcode'].encode('ascii')
            assert actor_id not in [b for table in objects for _,b,_ in table]
            actor_record=copy.deepcopy(record);actor_record['id']=actor_id
            f.set_field(actor_record,'umdl',3,actor['file'])
            f.set_field(actor_record,'unam',3,'Dialogue portrait '+actor['name'])
            # uidm deliberately has zero blending for flat UI; portraits need pose transitions.
            f.set_field(actor_record,'uble',1,0.20)
            objects[1].append((actor_record['base'],actor_id,[(a,k,b'',v,e) for a,k,v,e in actor_record['mods']]))
    if not lab:
        for rawcode,model in [('hbhr','HealthHero'),('hbet','HealthEnemyTauren'),('hbep','HealthEnemyPaladin')]:
            bar=copy.deepcopy(record);bar['id']=rawcode.encode('ascii')
            assert bar['id'] not in [b for table in objects for _,b,_ in table]
            f.set_field(bar,'umdl',3,'UI\\HealthBarsHorizontal\\'+model+'.mdx')
            f.set_field(bar,'unam',3,'Health bar '+model)
            f.set_field(bar,'uble',1,0.0)
            objects[1].append((bar['base'],bar['id'],[(a,k,b'',v,e) for a,k,v,e in bar['mods']]))
    changes['war3map.w3u']=inv.encode_objects(objects)
    imports=[]
    for p in sorted((ROOT/'assets').rglob('*')):
        if p.is_file() and p.suffix in ('.mdx','.blp'):
            name=str(p.relative_to(ROOT/'assets')).replace('/','\\');changes[name]=p.read_bytes();imports.append(name)
    reader=f.Reader((base/'war3map.imp').read_bytes());assert reader.int()==1
    entries=[reader.take(1)+reader.string() for _ in range(reader.int())];assert reader.pos==len(reader.data)
    entries.extend(bytes([13])+f.cstring(n) for n in imports)
    changes['war3map.imp']=f.integer(1)+f.integer(len(entries))+b''.join(entries)
    current=base_map
    for i,(member,payload) in enumerate(changes.items()):
        p=work/f'payload-{i}.bin';p.write_bytes(payload)
        out=work/f'stage-{i}.w3x';run(['wc3ctl','file','set',current,member,p,'-o',out,'--json'],f'pack-{i}');current=out
    run(['wc3ctl','extract',current,'--all','--out',work/'verified','--json'],'reextract')
    for p in base.rglob('*'):
        if p.is_file() and p.name not in ('(listfile)','(attributes)'):
            member=str(p.relative_to(base)).replace('/','\\')
            assert (work/'verified'/p.relative_to(base)).read_bytes()==changes.get(member,p.read_bytes()),member
    for name,payload in changes.items():assert (work/'verified'/name.replace('\\','/')).read_bytes()==payload,name
    assert current.read_bytes()[:512]==base_map.read_bytes()[:512]
    run(['pjass',work/'verified/war3map.j'],'pjass-final')
    output=ROOT/('TerrainDev-TextTagLab.w3x' if lab else 'TerrainDev-Dialogue.w3x')
    if output.exists():shutil.copy2(output,work/'previous-output.w3x')
    shutil.copy2(current,output)
    result={'map':str(output),'sha256':f.digest(output.read_bytes()),'base_sha256':manifest['sha256'],'build':str(work),'sources':[str(p) for p in paths],'imports':imports,'compiled':True,'pjass':True,'members_preserved':True,'header_preserved':True,'inventory_demo_enabled':False,'game_tested':False,'editor_roundtrip':False,'multiplayer_tested':False}
    (ROOT/('latest-texttag-build.json' if lab else 'latest-build.json')).write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))

if __name__=='__main__':main()
