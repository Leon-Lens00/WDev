"""Measure extracted scene batches. Visual/native decisions remain separate."""
import pathlib, json, math, sys, collections, itertools
root = pathlib.Path(sys.argv[1]).resolve()
read = lambda p: json.loads(p.read_text(encoding='utf-8-sig'))
def metrics(ds):
    pts = [d['Position'][:2] for d in ds]
    nn = sorted(min(math.dist(a,b) for j,b in enumerate(pts) if i != j) for i,a in enumerate(pts))
    return dict(n=len(pts), quantiles=[nn[int((len(nn)-1)*p)] for p in [.25,.5,.75]],
                neighbors256=sum(sum(i != j and math.dist(a,b)<=256 for j,b in enumerate(pts)) for i,a in enumerate(pts))/len(pts))
def land(terrain):
    # Same physical sea surface and sampling convention as recomposition validation.
    return {(x,y) for y in range(96) for x in range(192)
            if (terrain['Tiles'][y*193+x]['GroundHeight']-8192)/4 +
            (terrain['Tiles'][y*193+x]['LayerHeight']-2)*128 >= -89.6}
def components(mask):
    unseen = set(mask); sizes=[]
    while unseen:
        q=[unseen.pop()]; count=0
        while q:
            x,y=q.pop();count+=1
            for p in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
                if p in unseen:unseen.remove(p);q.append(p)
        sizes.append(count)
    return sorted(sizes, reverse=True)
source = {d['CreationNumber']:d for d in read(root/'discovery/source-data/placements.json')}
lib = read(root/'library/library-v2.json')
reference = {c['id']:metrics([source[i] for i in c['source_ids']]) for c in lib['forest_cohorts']}
records=[]; masks={}
for p in sorted(root.glob('runs/*/batch-v1/*/validation.json')):
    run=p.parent;v=read(p);layout=read(run/'layout.json');spec=read(run/'spec.json')
    provenance={d['creation_id']:d for d in read(run/'placements-provenance.json')}
    ds=read(run/'extracted/placements.json');cohorts=[]
    for name,ref in reference.items():
        out=metrics([d for d in ds if provenance[d['CreationNumber']]['role']=='forest' and provenance[d['CreationNumber']]['instance']==name])
        cohorts.append(dict(id=name,reference=ref,output=out,passed=out['n']>=30 and all(abs(a-b)/b<=.25 for a,b in zip(out['quantiles'],ref['quantiles']))))
    mask=land(read(run/'extracted/terrain.json'));masks[spec['seed']]=mask;cc=components(mask)
    assert len(mask)==layout['output_land_cells']
    instances=spec['scene']['instances']
    records.append(dict(brief=spec['scene']['brief']['id'],seed=spec['seed'],source_iou=v['source_land_iou'],land_cells=len(mask),land_area=len(mask)*128*128,components=cc,largest_land_fraction=cc[0]/len(mask),forest=v['forest'],cohorts=cohorts,counts=dict(collections.Counter(i['family'] for i in instances)),changed_pairs=v['changed_distance_pairs'],instances=instances,structural_status=v['status'],visual_review='separate explicit record'))
finals=[42700,43702,44700]
pairs={f'{a}:{b}':len(masks[a]&masks[b])/len(masks[a]|masks[b]) for a,b in itertools.combinations(finals,2)}
assert all(v<=.8 for v in pairs.values())
out=dict(format='wc3-scene-batch-acceptance-v1',cases=records,finalist_candidates=finals,pairwise_land_iou=pairs,physical_land_definition='192x96 lower-left vertex samples; FinalZ >= -89.6; 4-neighbor components')
(root/'experiments/batch-acceptance.json').write_text(json.dumps(out,indent=2),encoding='utf-8')
for v in records:print(v['seed'], 'land',v['land_cells'],'largest',round(v['largest_land_fraction'],3),'cohorts',[(c['id'],c['passed'],c['output']['n']) for c in v['cohorts']])
print('Pair IoU', pairs)
