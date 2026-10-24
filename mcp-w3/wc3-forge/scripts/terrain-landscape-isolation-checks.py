"""Audit seed independence and bare/decorated isolation from validated exports."""
import hashlib, json, math
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
P=ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1'
def read(p): return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,j): p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(j,indent=2)+'\n')
def load(run):
    names=['spec','layout','placements','placements-provenance','physical-layers','members','height-and-module-evidence','validation','catalog']
    return {n:read(run/(n+'.json')) for n in names}
def pieces(d,role=None):
    prov={p['creation_id']:p for p in d['placements-provenance']}
    return {(prov[x['CreationNumber']]['instance'],prov[x['CreationNumber']]['source_id']):{k:v for k,v in x.items() if k!='CreationNumber'} for x in d['placements'] if prov[x['CreationNumber']]['role'] in ('essential','ornament') and (role is None or prov[x['CreationNumber']]['role']==role)}
def nonforest(d):
    prov={p['creation_id']:p for p in d['placements-provenance']}
    return {x['CreationNumber']:x for x in d['placements'] if prov[x['CreationNumber']]['role']!='forest'}
def members(a,b,allowed):
    a,b=a['members']['members'],b['members']['members']
    assert a.keys()==b.keys(),'archive inventory changed'
    changed=[k for k in a if a[k]!=b[k]]
    assert set(changed)<=set(allowed),changed
    return changed
def validated(d):
    assert d['validation']['passed'] and not d['validation']['failures']
    assert d['validation']['map_sha256']==d['members']['map_sha256']
def point_segment(p,a,b):
    dx,dy=b[0]-a[0],b[1]-a[1]
    t=max(0,min(1,((p[0]-a[0])*dx+(p[1]-a[1])*dy)/max(dx*dx+dy*dy,1e-10)))
    return math.hypot(p[0]-a[0]-t*dx,p[1]-a[1]-t*dy)

a=load(P/'runs/D/batch-v2/52700');validated(a)
result={'accepted':False,'base_map_sha256':a['members']['map_sha256'],'cases':{},'inputs':{}}
for stream in ['vegetation','ornaments','variants']:
    run=P/f'reproduction/seed-isolation-v2/{stream}'; b=load(run);validated(b)
    streams_a=a['spec']['landscape']['streams'];streams_b=b['spec']['landscape']['streams']
    assert [k for k in streams_a if streams_a[k]!=streams_b[k]]==[stream]
    pa,pb=pieces(a),pieces(b); assert pa.keys()==pb.keys()
    changed=[k for k in pa if pa[k]!=pb[k]]
    allowed=['war3map.doo','war3mapmap.blp']
    report={'map_sha256':b['members']['map_sha256'],'changed_nonforest':changed,'validation_sha256':sha(run/'validation.json')}
    if stream=='vegetation':
        assert not changed
        assert nonforest(a)==nonforest(b)
        assert a['layout']==b['layout']
        assert a['members']['members']['war3map.w3e']==b['members']['members']['war3map.w3e']
        assert a['members']['members']['war3map.wpm']==b['members']['members']['war3map.wpm']
        assert a['placements']!=b['placements'],'vegetation seed had no effect'
        report['unchanged']=['W3E','static WPM','full layout','all nonforest objects']
    elif stream=='ornaments':
        assert a['layout']==b['layout']
        assert pieces(a,'essential')==pieces(b,'essential')
        na,nb=nonforest(a),nonforest(b); assert na.keys()==nb.keys()
        for cid in na:
            assert {f:v for f,v in na[cid].items() if f!='Rotation'}=={f:v for f,v in nb[cid].items() if f!='Rotation'}
        for k in changed:
            assert pa[k]['Position']==pb[k]['Position']
            assert {f:v for f,v in pa[k].items() if f!='Rotation'}=={f:v for f,v in pb[k].items() if f!='Rotation'}
            asset=b['catalog']['assets'][pa[k]['TypeID']]
            assert asset['fields'].get('pathtex','').lower() in ('','none','_')
            delta=(pb[k]['Rotation']-pa[k]['Rotation'])/(math.pi/2)
            assert abs(delta-round(delta))<1e-5
        assert changed,'ornament seed had no effect'
        report['unchanged']=['W3E','static WPM','full layout','essential objects','positions/scales of all nonforest objects']
    else:
        allowed+=['war3map.w3e','war3map.wpm']
        la,lb=a['layout'],b['layout']
        for field in ['bodies','routes','islets','land_connections','start']:
            assert la[field]==lb[field],field
        aa={x['id']:x for x in la['placements']}; bb={x['id']:x for x in lb['placements']}
        for k in aa:
            assert {f:v for f,v in aa[k].items() if f!='variant'}=={f:v for f,v in bb[k].items() if f!='variant'}
        lib=read(Path(a['spec']['landscape']['library']))
        modules={(m['family'],sid):(m,index) for m in lib['modules'] for index,sid in enumerate(m['members'])}
        changed_positions=[]
        for k in changed:
            old,new=pa[k],pb[k]; family=aa[k[0]]['family']
            assert {f:v for f,v in old.items() if f not in ('Position','Flags')}=={f:v for f,v in new.items() if f not in ('Position','Flags')}
            assert (family,k[1]) in modules,(k,'changed outside modules')
            module,index=modules[family,k[1]]
            va,vb=aa[k[0]].get('variant',0),bb[k[0]].get('variant',0)
            assert old['Flags'] & ~4 == new['Flags'] & ~4
            assert bool(new['Flags'] & 4)==any(module['variant_shifts'][vb][index])
            for axis in [0,1]:
                expected=module['variant_shifts'][vb][index][axis]-module['variant_shifts'][va][index][axis]
                assert abs(new['Position'][axis]-old['Position'][axis]-expected)<.002
            changed_positions.append(k)
        # Only the declared adaptable watershed may change relief/water. WFC may
        # change materials outside rigid cores when its constraint mask changes.
        phy_a,phy_b=a['physical-layers'],b['physical-layers']; changes={}
        reaches=la['reaches']+lb['reaches']
        for field in ['dry','ground_heights','ground_textures']:
            ids=[i for i,(x,y) in enumerate(zip(phy_a[field],phy_b[field])) if x!=y]
            changes[field]=len(ids)
            for i in ids:
                assert la['vertex_masks'][i]!='rigid' and lb['vertex_masks'][i]!='rigid',(field,i,'rigid change')
                if field!='ground_textures':
                    xy=[i%193*128-12288,i//193*128-4096]
                    assert any(min(point_segment(xy,u,v) for u,v in zip(r['points'],r['points'][1:]))<=r['width']/2+384+128 for r in reaches),(field,i,'outside watershed')
        assert phy_a['palette']==phy_b['palette']
        report.update(changed_module_positions=changed_positions,changed_vertices=changes,unchanged=['territorial bodies','scene centers/cores/ports','routes','rigid terrain'],authorized_derivatives=['adaptable outlet watershed W3E/WPM','WFC materials outside rigid cores','habitat masks, environmental ground decoration and free vegetation responding to changed water/materials'])
    report['changed_members']=members(a,b,allowed)
    report['passed']=True;result['cases'][stream]=report
    for name in ['spec','members','layout','placements','placements-provenance','physical-layers','height-and-module-evidence','validation']:
        result['inputs'][str((run/(name+'.json')).relative_to(P))]=sha(run/(name+'.json'))
result['accepted']=True
write(P/'reproduction/seed-isolation-v2/audit.json',result)

bare_result={'accepted':False,'cases':[]}
for brief,seed in [('D',52700),('E',53700),('F',54700)]:
    full=P/f'runs/{brief}/batch-v2/{seed}'
    bare=P/'experiments/habitats-04/bare' if brief=='D' else P/f'experiments/landform-finals-v2/{brief}'
    a,b=load(full),load(bare)
    # Bare deliberately omits optional/environment objects and configured trees.
    # All remaining structural pieces must be an identical subset, modulo ids.
    pa,pb=pieces(a),pieces(b)
    assert pb.keys()<=pa.keys()
    assert all(pa[k]==pb[k] for k in pb),'bare changed structural pieces'
    roles={(q['instance'],q['source_id']):q['role'] for q in a['placements-provenance'] if q['role'] in ('essential','ornament')}
    for k in pa.keys()-pb.keys():
        assert roles[k]=='ornament' or pa[k]['TypeID'] in a['spec']['trees'],'bare removed mandatory architecture'
    assert a['layout']==b['layout']
    changed=members(a,b,['war3map.doo','war3mapmap.blp'])
    bare_result['cases'].append(dict(brief=brief,decorated_map_sha256=a['members']['map_sha256'],bare_map_sha256=b['members']['map_sha256'],changed_members=changed,retained_structural_count=len(pb),identical=['W3E','WPM','layout','all retained structural pieces'],omitted=['forest','environment','ornaments','configured tree rawcodes']))
bare_result['accepted']=True
write(P/'experiments/landform-finals-v2/isolation.json',bare_result)
print('Seed isolation and three bare/decorated artifact comparisons passed.')
